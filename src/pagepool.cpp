/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "pagepool.h"

#include <QDebug>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQmlProperty>

#include "loggingcategory.h"

PagePool::PagePool(QObject *parent)
    : QObject(parent)
{
}

PagePool::~PagePool()
{
}

QUrl PagePool::lastLoadedUrl() const
{
    return m_lastLoadedUrl;
}

QQuickItem *PagePool::lastLoadedItem() const
{
    return m_lastLoadedItem;
}

QList<QObject *> PagePool::items() const
{
    auto items = m_itemForUrl.values();
    return QList<QObject *>(items.cbegin(), items.cend());
}

QList<QUrl> PagePool::urls() const
{
    return m_urlForItem.values();
}

void PagePool::setCachePages(bool cache)
{
    if (cache == m_cachePages) {
        return;
    }

    if (cache) {
        clear();
    }

    m_cachePages = cache;
    Q_EMIT cachePagesChanged();
}

bool PagePool::cachePages() const
{
    return m_cachePages;
}

QQuickItem *PagePool::loadPage(const QString &url, QJSValue callback)
{
    return loadPageWithProperties(url, QVariantMap(), callback);
}

QQuickItem *PagePool::loadPageWithProperties(const QString &url, const QVariantMap &properties, QJSValue callback)
{
    Q_ASSERT(qmlEngine(this));
    QQmlContext *ctx = QQmlEngine::contextForObject(this);
    Q_ASSERT(ctx);

    const QUrl actualUrl = resolvedUrl(url);

    auto found = m_itemForUrl.find(actualUrl);
    if (found != m_itemForUrl.end()) {
        m_lastLoadedUrl = found.key();
        m_lastLoadedItem = found.value();

        if (callback.isCallable()) {
            QJSValueList args = {qmlEngine(this)->newQObject(found.value())};
            callback.call(args);
            Q_EMIT lastLoadedUrlChanged();
            Q_EMIT lastLoadedItemChanged();
            // We could return the item, but for api coherence return null
            return nullptr;

        } else {
            Q_EMIT lastLoadedUrlChanged();
            Q_EMIT lastLoadedItemChanged();
            return found.value();
        }
    }

    QQmlComponent *component = m_componentForUrl.value(actualUrl);

    if (!component) {
        component = new QQmlComponent(qmlEngine(this), actualUrl, QQmlComponent::PreferSynchronous);
    }

    if (component->status() == QQmlComponent::Loading) {
        if (!callback.isCallable()) {
            component->deleteLater();
            m_componentForUrl.remove(actualUrl);
            return nullptr;
        }

        connect(component, &QQmlComponent::statusChanged, this, [this, component, callback, properties](QQmlComponent::Status status) mutable {
            if (status != QQmlComponent::Ready) {
                qCWarning(KirigamiLog) << component->errors();
                m_componentForUrl.remove(component->url());
                component->deleteLater();
                return;
            }
            QQuickItem *item = createFromComponent(component, properties);
            if (item) {
                QJSValueList args = {qmlEngine(this)->newQObject(item)};
                callback.call(args);
            }

            if (m_cachePages) {
                component->deleteLater();
            } else {
                m_componentForUrl[component->url()] = component;
            }
        });

        return nullptr;

    } else if (component->status() != QQmlComponent::Ready) {
        qCWarning(KirigamiLog) << component->errors();
        return nullptr;
    }

    QQuickItem *item = createFromComponent(component, properties);
    if (!item) {
        return nullptr;
    }

    if (m_cachePages) {
        component->deleteLater();
        QQmlEngine::setObjectOwnership(item, QQmlEngine::CppOwnership);
        m_itemForUrl[component->url()] = item;
        m_urlForItem[item] = component->url();
        Q_EMIT itemsChanged();
        Q_EMIT urlsChanged();

    } else {
        m_componentForUrl[component->url()] = component;
        QQmlEngine::setObjectOwnership(item, QQmlEngine::JavaScriptOwnership);
    }

    m_lastLoadedUrl = actualUrl;
    m_lastLoadedItem = item;
    Q_EMIT lastLoadedUrlChanged();
    Q_EMIT lastLoadedItemChanged();

    if (callback.isCallable()) {
        QJSValueList args = {qmlEngine(this)->newQObject(item)};
        callback.call(args);
        // We could return the item, but for api coherence return null
        return nullptr;
    }
    return item;
}

QQuickItem *PagePool::createFromComponent(QQmlComponent *component, const QVariantMap &properties)
{
    QQmlContext *ctx = QQmlEngine::contextForObject(this);
    Q_ASSERT(ctx);

    QObject *obj = component->createWithInitialProperties(properties, ctx);

    if (!obj || component->isError()) {
        qCWarning(KirigamiLog) << component->errors();
        if (obj) {
            obj->deleteLater();
        }
        return nullptr;
    }

    QQuickItem *item = qobject_cast<QQuickItem *>(obj);
    if (!item) {
        qCWarning(KirigamiLog) << "Storing Non-QQuickItem in PagePool not supported";
        obj->deleteLater();
        return nullptr;
    }

    return item;
}

QUrl PagePool::resolvedUrl(const QString &stringUrl) const
{
    Q_ASSERT(qmlEngine(this));
    QQmlContext *ctx = QQmlEngine::contextForObject(this);
    Q_ASSERT(ctx);

    QUrl actualUrl(stringUrl);
    if (actualUrl.scheme().isEmpty()) {
        actualUrl = ctx->resolvedUrl(actualUrl);
    }
    return actualUrl;
}

bool PagePool::isLocalUrl(const QUrl &url)
{
    return url.isLocalFile() || url.scheme().isEmpty() || url.scheme() == QStringLiteral("qrc");
}

QUrl PagePool::urlForPage(QQuickItem *item) const
{
    return m_urlForItem.value(item);
}

QQuickItem *PagePool::pageForUrl(const QUrl &url) const
{
    return m_itemForUrl.value(resolvedUrl(url.toString()), nullptr);
}

bool PagePool::contains(const QVariant &page) const
{
    if (page.canConvert<QQuickItem *>()) {
        return m_urlForItem.contains(page.value<QQuickItem *>());

    } else if (page.canConvert<QString>()) {
        const QUrl actualUrl = resolvedUrl(page.value<QString>());
        return m_itemForUrl.contains(actualUrl);

    } else {
        return false;
    }
}

void PagePool::deletePage(const QVariant &page)
{
    if (!contains(page)) {
        return;
    }

    QQuickItem *item;
    if (page.canConvert<QQuickItem *>()) {
        item = page.value<QQuickItem *>();
    } else if (page.canConvert<QString>()) {
        QString url = page.value<QString>();
        if (url.isEmpty()) {
            return;
        }
        const QUrl actualUrl = resolvedUrl(page.value<QString>());

        item = m_itemForUrl.value(actualUrl);
    } else {
        return;
    }

    if (!item) {
        return;
    }

    const QUrl url = m_urlForItem.value(item);

    if (url.isEmpty()) {
        return;
    }

    m_itemForUrl.remove(url);
    m_urlForItem.remove(item);
    item->deleteLater();

    Q_EMIT itemsChanged();
    Q_EMIT urlsChanged();
}

void PagePool::clear()
{
    for (auto *c : qAsConst(m_componentForUrl)) {
        c->deleteLater();
    }
    m_componentForUrl.clear();

    for (auto *i : qAsConst(m_itemForUrl)) {
        // items that had been deparented are safe to delete
        if (!i->parentItem()) {
            i->deleteLater();
        }
        QQmlEngine::setObjectOwnership(i, QQmlEngine::JavaScriptOwnership);
    }
    m_itemForUrl.clear();
    m_urlForItem.clear();
    m_lastLoadedUrl = QUrl();
    m_lastLoadedItem = nullptr;

    Q_EMIT lastLoadedUrlChanged();
    Q_EMIT lastLoadedItemChanged();
    Q_EMIT itemsChanged();
    Q_EMIT urlsChanged();
}

#include "moc_pagepool.cpp"
