/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.10 as Kirigami
import "private"
import QtQuick.Templates 2.1 as T2
import QtQuick.Controls 2.1 as QQC2

/**
 * Page is a container for all the app pages: everything pushed to the
 * ApplicationWindow's pageStack should be a Page.
 *
 * @see ScrollablePage
 * For content that should be scrollable, such as ListViews, use ScrollablePage instead.
 * @inherit QtQuick.Controls.Page
 */
QQC2.Page {
    id: root

    /**
     * The default content padding is 1 gridUnit.
     * // TODO this is not displayed in the generated api doc.
     */
    padding: Kirigami.Units.gridUnit

    /**
     * The bottom content padding. Bound to verticalPadding or the height of floating action buttons (when present) by default.
     * // TODO this is not displayed in the generated api doc.
     */
    bottomPadding: actionButtons.item ? actionButtons.height : verticalPadding

    /**
     * @brief If the central element of the page is a Flickable
     * (ListView and Gridview as well) you can set it there.
     *
     * Normally, you wouldn't need to do that, but just use the
     * ScrollablePage element instead.
     *
     * @see ScrollablePage
     * Use this if your flickable has some non standard properties, such as not covering the whole Page.
     */
    property Flickable flickable

    /**
     * @property list<QtQml.QtObject> actions.contextualActions
     * @brief Defines the contextual actions for the page:
     * an easy way to assign actions in the right sliding panel
     *
     * Example usage:
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     contextDrawer: Kirigami.ContextDrawer {
     *         id: contextDrawer
     *     }
     *  [...]
     * }
     * @endcode
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     *
     * Kirigami.Page {
     *   [...]
     *     actions.contextualActions: [
     *         Kirigami.Action {
     *             icon.name: "edit"
     *             text: "Action text"
     *             onTriggered: {
     *                 // do stuff
     *             }
     *         },
     *         Kirigami.Action {
     *             icon.name: "edit"
     *             text: "Action text"
     *             onTriggered: {
     *                 // do stuff
     *             }
     *         }
     *     ]
     *   [...]
     * }
     * @endcode
     */
    //TODO: remove
    property alias contextualActions: actionsGroup.contextualActions

    /**
     * @property Action mainAction
     * @brief An optional single action for the action button.
     * it can be a Kirigami.Action or a QAction
     *
     * Example usage:
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions.main: Kirigami.Action {
     *         icon.name: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     */
    //TODO: remove
    property alias mainAction: actionsGroup.main

    /**
     * @property Action leftAction
     * @brief An optional extra action at the left of the main action button.
     * it can be a Kirigami.Action or a QAction
     *
     * Example usage:
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions.left: Kirigami.Action {
     *         icon.name: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     */
    //TODO: remove
    property alias leftAction: actionsGroup.left

    /**
     * @property Action rightAction
     * @brief An optional extra action at the right of the main action button.
     * it can be a Kirigami.Action or a QAction
     *
     * Example usage:
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions.right: Kirigami.Action {
     *         icon.name: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     */
    //TODO: remove
    property alias rightAction: actionsGroup.right

    /**
     * Actions properties are grouped.
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions {
     *         main: Kirigami.Action {...}
     *         left: Kirigami.Action {...}
     *         right: Kirigami.Action {...}
     *         contextualActions: [
     *             Kirigami.Action {...},
     *             Kirigami.Action {...}
     *         ]
     *     }
     * }
     * @endcode
     */
    readonly property alias actions: actionsGroup

    /**
     * Emitted when a visualization for the actions is about to be shown,
     * such as the toolbar menu or the contextDrawer
     * @since 2.7
     */
    signal contextualActionsAboutToShow

    /**
     * Specifies if it's the currently selected page in the window's pages row, or if layers
     * are used whether this is the topmost item on the layers stack. If the page is
     * not attached to either a column view or a stack view, expect this to be true.
     *
     * @since 2.1
     */
    //TODO KF6: remove this or at least all the assumptions about the internal tree structure of items
    readonly property bool isCurrentPage: Kirigami.ColumnView.view
            ? (Kirigami.ColumnView.index == Kirigami.ColumnView.view.currentIndex && Kirigami.ColumnView.view.parent.parent.currentItem === Kirigami.ColumnView.view.parent)
            : (parent && parent instanceof QQC2.StackView
                ? parent.currentItem === root
                : true)

    /**
     * @property Item overlay
     * an item which stays on top of every other item in the page,
     * if you want to make sure some elements are completely in a
     * layer on top of the whole content, parent items to this one.
     * It's a "local" version of ApplicationWindow's overlay
     * @since 2.5
     */
    readonly property alias overlay: overlayItem

    /**
     * @property variant icon
     *
     * The icon that represents this page.
     */
    property ActionIconGroup icon: ActionIconGroup {}

    /**
     * Whether this page needs user attention.
     */
    property bool needsAttention

    /**
     * @property real progress
     *
     * Progress of a task this page is doing. Set to undefined to indicate
     * that there are no ongoing tasks.
     */
    property var progress: undefined

    /**
     * The delegate which will be used to draw the page title. It can be customized to put any kind of Item in there.
     * @since 2.7
     */
    property Component titleDelegate: Component {
        id: defaultTitleDelegate
        Kirigami.Heading {
            level: 1
            Layout.fillWidth: true
            Layout.maximumWidth: implicitWidth + 1 // The +1 is to make sure we do not trigger eliding at max width
            Layout.minimumWidth: 0
            opacity: root.isCurrentPage ? 1 : 0.4
            maximumLineCount: 1
            elide: Text.ElideRight
            text: root.title
        }
    }

    /**
     * Emitted when the application requests a Back action
     * For instance a global "back" shortcut or the Android
     * Back button has been pressed.
     * The page can manage the back event by itself,
     * and if it set event.accepted = true, it will stop the main
     * application to manage the back event.
     */
    signal backRequested(var event);


    // Look for sheets and cose them
    //FIXME: port Sheets to Popup?
    onBackRequested: {
        for(var i in root.resources) {
            var item = root.resources[i];
            if (item.hasOwnProperty("close") && item.hasOwnProperty("sheetOpen") && item.sheetOpen) {
                item.close()
                event.accepted = true;
                return;
            }
        }
    }

    /**
     * The item used as global toolbar for the page
     * present only if we are in a PageRow as a page or as a layer,
     * and the style is either Titles or ToolBar
     * @since 2.5
     */
    readonly property Item globalToolBarItem: globalToolBar.item

    /**
     * The style for the automatically generated global toolbar: by default the Page toolbar is the one set globally in the PageRow in its globalToolBar.style property.
     * A single page can override the application toolbar style for itself.
     * It is discouraged to use this, except very specific exceptions, like a chat
     * application which can't have controls on the bottom except the text field.
     * If the Page is not in a PageRow, by default the toolbar will be invisible,
     * so has to be explicitly set to Kirigami.ApplicationHeaderStyle.ToolBar if
     * desired to be used in that case.
     */
    property int globalToolBarStyle: {
        if (globalToolBar.row && !globalToolBar.stack) {
            return globalToolBar.row.globalToolBar.actualStyle;
        } else if (globalToolBar.stack) {
            return Kirigami.Settings.isMobile ? Kirigami.ApplicationHeaderStyle.Titles : Kirigami.ApplicationHeaderStyle.ToolBar;
        } else {
            return Kirigami.ApplicationHeaderStyle.None;
        }
    }

    //NOTE: contentItem will be created if not existing (and contentChildren of Page would become its children) This with anchors enforces the geometry we want, where globalToolBar is a super-header, on top of header
    contentItem: Item {
        anchors {
            top: root.header
                    ? root.header.bottom
                    : (globalToolBar.visible ? globalToolBar.bottom : parent.top)
            topMargin: root.topPadding + root.spacing
            bottom: root.footer ? root.footer.top : parent.bottom
            bottomMargin: root.bottomPadding + root.spacing
        }
    }

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }

    implicitHeight: (header ? header.implicitHeight : 0) + (footer ? footer.implicitHeight : 0) + contentItem.implicitHeight + topPadding + bottomPadding
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding

    //FIXME: on material the shadow would bleed over
    clip: root.header != null;

    onHeaderChanged: {
        if (header) {
            header.anchors.top = Qt.binding(function() {return globalToolBar.visible ? globalToolBar.bottom : root.top});
        }
    }

    Component.onCompleted: {
        headerChanged();
        parentChanged(root.parent);
        globalToolBar.syncSource();
        actionButtons.pageComplete = true
    }

    onParentChanged: {
        if (!parent) {
            return;
        }
        globalToolBar.stack = null;
        globalToolBar.row = null;

        if (root.Kirigami.ColumnView.view) {
            globalToolBar.row = root.Kirigami.ColumnView.view.__pageRow;
        }
        if (root.T2.StackView.view) {
            globalToolBar.stack = root.T2.StackView.view;
            globalToolBar.row = root.T2.StackView.view ? root.T2.StackView.view.parent : null;
        }
        if (globalToolBar.row) {
            root.globalToolBarStyleChanged.connect(globalToolBar.syncSource);
            globalToolBar.syncSource();
        }
    }

    //in data in order for them to not be considered for contentItem, contentChildren, contentData
    data: [
        PageActionPropertyGroup {
            id: actionsGroup
        },

        Item {
            id: overlayItem
            parent: root
            z: 9997
            anchors {
                fill: parent
                topMargin: globalToolBar.height
            }
        },
        //global top toolbar if we are in a PageRow (in the row or as a layer)
        Loader {
            id: globalToolBar
            z: 9999
            height: item ? item.implicitHeight : 0
            anchors {
                left:  parent.left
                right: parent.right
                top: parent.top
            }
            property Kirigami.PageRow row
            property T2.StackView stack

            // don't load async so that on slower devices we don't have the page content height changing while loading in
            // otherwise, it looks unpolished and jumpy
            asynchronous: false

            visible: active
            active: (root.titleDelegate !== defaultTitleDelegate || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.Titles)
            onActiveChanged: {
                if (active) {
                    syncSource();
                }
            }

            function syncSource() {
                if (root.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.ToolBar &&
                    root.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.Titles &&
                    root.titleDelegate !== defaultTitleDelegate) {
                    sourceComponent = root.titleDelegate;
                } else if (active) {
                    setSource(Qt.resolvedUrl(root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar ? "private/globaltoolbar/ToolBarPageHeader.qml" : "private/globaltoolbar/TitlesPageHeader.qml"),
                    //TODO: find container reliably, remove assumption
                    {"pageRow": Qt.binding(function() {return row}),
                    "page": root,
                    "current": Qt.binding(function() {
                        if (!row && !stack) {
                            return true;
                        } else if (stack) {
                            return stack;
                        } else {
                            return row.currentIndex === root.Kirigami.ColumnView.level;
                        }
                    })});
                }
            }
        },
        //bottom action buttons
        Loader {
            id: actionButtons
            z: 9999
            parent: root
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            //if the page doesn't inherit, assume it has custom colors we want to use them here too
            Kirigami.Theme.inherit: !root.Kirigami.Theme.inherit
            Kirigami.Theme.colorSet: Kirigami.Theme.Button

            //It should be T2.Page, Qt 5.7 doesn't like it
            property Item page: root
            height: item ? item.implicitHeight : 0

            asynchronous: true

            property bool pageComplete: false

            active: {
                // Important! Do not do anything until the page has been
                // completed, so we are sure what the globalToolBarStyle is,
                // otherwise we risk creating the content and then discarding it.
                if (!pageComplete) {
                    return false;
                }

                // Note: Do not use root.globalToolBarStyle here as it is
                // evaluated too late and will cause active to be true for a
                // brief period, triggering the loading process.
                if (globalToolBar.row && globalToolBar.row.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.ToolBar) {
                    return false;
                }

                if (!root.actions.main && !root.actions.left && !root.actions.right && root.actions.contextualActions.length == 0) {
                    return false;
                }

                // Legacy
                if (typeof applicationWindow === "undefined") {
                    return true;
                }

                if (applicationWindow().header && applicationWindow().header.toString().indexOf("ToolBarApplicationHeader") !== -1) {
                    return false;
                }

                if (applicationWindow().footer && applicationWindow().footer.toString().indexOf("ToolBarApplicationHeader") !== -1) {
                    return false;
                }

                return true;
            }

            source: Qt.resolvedUrl("./private/ActionButton.qml")
        }
    ]

    Layout.fillWidth: true
}
