/*
 *  SPDX-FileCopyrightText: 2009 Alan Alpert <alan.alpert@nokia.com>
 *  SPDX-FileCopyrightText: 2010 Ménard Alexis <menard@kde.org>
 *  SPDX-FileCopyrightText: 2010 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef KIRIGAMIPLUGIN_H
#define KIRIGAMIPLUGIN_H

#include <QUrl>

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

#ifdef KIRIGAMI_BUILD_TYPE_STATIC
#include <QDebug>
#endif

class KirigamiPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    KirigamiPlugin(QObject *parent = nullptr);
    void registerTypes(const char *uri) override;
    void initializeEngine(QQmlEngine *engine, const char *uri) override;

#ifdef KIRIGAMI_BUILD_TYPE_STATIC
    static KirigamiPlugin &getInstance()
    {
        static KirigamiPlugin instance;
        return instance;
    }

    static void registerTypes(QQmlEngine *engine = nullptr)
    {
        Q_INIT_RESOURCE(shaders);
        if (engine) {
            engine->addImportPath(QLatin1String(":/"));
        } else {
            qCWarning(KirigamiLog)
                << "Registering Kirigami on a null QQmlEngine instance - you likely want to pass a valid engine, or you will want to manually add the "
                   "qrc root path :/ to your import paths list so the engine is able to load the plugin";
        }
    }
#endif

Q_SIGNALS:
    void languageChangeEvent();

private:
    QUrl componentUrl(const QString &fileName) const;
};

#endif
