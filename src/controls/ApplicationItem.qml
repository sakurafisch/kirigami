/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import "templates/private"
import org.kde.kirigami 2.4 as Kirigami

/**
 * An item that provides the features of ApplicationWindow without the window itself.
 * This allows embedding into a larger application.
 *
 * It's based around the PageRow component that allows adding/removing of pages.
 *
 * Example usage:
 * @code
 * import org.kde.kirigami 2.4 as Kirigami
 *
 * Kirigami.ApplicationItem {
 *     globalDrawer: Kirigami.GlobalDrawer {
 *         actions: [
 *            Kirigami.Action {
 *                text: "View"
 *                icon.name: "view-list-icons"
 *                Kirigami.Action {
 *                        text: "action 1"
 *                }
 *                Kirigami.Action {
 *                        text: "action 2"
 *                }
 *                Kirigami.Action {
 *                        text: "action 3"
 *                }
 *            },
 *            Kirigami.Action {
 *                text: "Sync"
 *                icon.name: "folder-sync"
 *            }
 *         ]
 *     }
 *
 *     contextDrawer: Kirigami.ContextDrawer {
 *         id: contextDrawer
 *     }
 *
 *     pageStack.initialPage: Kirigami.Page {
 *         mainAction: Kirigami.Action {
 *             icon.name: "edit"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         }
 *         contextualActions: [
 *             Kirigami.Action {
 *                 icon.name: "edit"
 *                 text: "Action text"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             },
 *             Kirigami.Action {
 *                 icon.name: "edit"
 *                 text: "Action text"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             }
 *         ]
 *         // ...
 *     }
 * }
 * @endcode
 *
*/
AbstractApplicationItem {
    id: root

    /**
     * @property QtQuick.StackView ApplicationItem::pageStack
     *
     * @brief This property holds the PageRow used to allocate the pages and
     * manage the transitions between them.
     *
     * It's using a PageRow, while having the same API as PageStack,
     * it positions the pages as adjacent columns, with as many columns
     * as can fit in the screen. An handheld device would usually have a single
     * fullscreen column, a tablet device would have many tiled columns.
     *
     * @warning This property is readonly.
     */
    property alias pageStack: __pageStack // TODO KF6 make readonly

    // Redefines here as here we can know a pointer to PageRow
    wideScreen: width >= applicationWindow().pageStack.defaultColumnWidth * 2

    Component.onCompleted: {
        if (pageStack.currentItem) {
            pageStack.currentItem.forceActiveFocus();
        }
    }

    PageRow {
        id: __pageStack
        anchors {
            fill: parent
            //HACK: workaround a bug in android iOS keyboard management
            bottomMargin: ((Qt.platform.os == "android" || Qt.platform.os == "ios") || !Qt.inputMethod.visible) ? 0 : Qt.inputMethod.keyboardRectangle.height
            onBottomMarginChanged: {
                if (bottomMargin > 0) {
                    root.reachableMode = false;
                }
            }
        }
        //FIXME
        onCurrentIndexChanged: root.reachableMode = false;

        function goBack() {
            //NOTE: drawers are handling the back button by themselves
            const backEvent = {accepted: false}
            if (root.pageStack.currentIndex >= 1) {
                root.pageStack.currentItem.backRequested(backEvent);
                if (!backEvent.accepted) {
                    root.pageStack.flickBack();
                    backEvent.accepted = true;
                }
            }

            if (Kirigami.Settings.isMobile && !backEvent.accepted && Qt.platform.os !== "ios") {
                Qt.quit();
            }
        }
        function goForward() {
            root.pageStack.currentIndex = Math.min(root.pageStack.depth - 1, root.pageStack.currentIndex + 1);
        }
        Keys.onBackPressed: {
            goBack();
            event.accepted = true;
        }
        Shortcut {
            sequences: [StandardKey.Forward]
            onActivated: __pageStack.goForward();
        }
        Shortcut {
            sequences: [StandardKey.Back]
            onActivated: __pageStack.goBack();
        }

        background: Rectangle {
            color: root.color
        }

        focus: true
    }
}
