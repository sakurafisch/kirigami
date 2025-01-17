/*
 *  SPDX-FileCopyrightText: 2018 by Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami

/**
 * Implements a drag handle supposed to be in items in ListViews to reorder items
 * The ListView must visualize a model which supports item reordering,
 * such as ListModel.move() or QAbstractItemModel  instances with moveRows() correctly implemented.
 * In order for ListItemDragHandle to work correctly, the listItem that is being dragged
 * should not directly be the delegate of the ListView, but a child of it.
 *
 * It is recommended to use DelagateRecycler as base delegate like the following code:
 * @code
 *   ...
 *   Component {
 *       id: delegateComponent
 *       Kirigami.AbstractListItem {
 *           id: listItem
 *           contentItem: RowLayout {
 *               Kirigami.ListItemDragHandle {
 *                   listItem: listItem
 *                   listView: mainList
 *                   onMoveRequested: listModel.move(oldIndex, newIndex, 1)
 *               }
 *               Controls.Label {
 *                   text: model.label
 *               }
 *           }
 *       }
 *   }
 *   ListView {
 *       id: mainList
 *
 *       model: ListModel {
 *           id: listModel
 *           ListItem {
 *               lablel: "Item 1"
 *           }
 *           ListItem {
 *               lablel: "Item 2"
 *           }
 *           ListItem {
 *               lablel: "Item 3"
 *           }
 *       }
 *       //this is optional to make list items animated when reordered
 *       moveDisplaced: Transition {
 *           YAnimator {
 *               duration: Kirigami.Units.longDuration
 *               easing.type: Easing.InOutQuad
 *           }
 *       }
 *       delegate: Kirigami.DelegateRecycler {
 *           width: mainList.width
 *           sourceComponent: delegateComponent
 *       }
 *   }
 *   ...
 * @endcode
 *
 * @inherit QtQuick.Item
 * @since 2.5
 */
Item {
    id: root

    /**
     * listItem: Item
     * The id of the delegate that we want to drag around, which *must*
     * be a child of the actual ListView's delegate
     */
    property Item listItem

    /**
     * listView: Listview
     * The id of the ListView the delegates belong to.
     */
    property ListView listView

    /**
     * Emitted when the drag handle wants to move the item in the model
     * The following example does the move in the case a ListModel is used
     * @code
     *  onMoveRequested: listModel.move(oldIndex, newIndex, 1)
     * @endcode
     * @param oldIndex the index the item is currently at
     * @param newIndex the index we want to move the item to
     */
    signal moveRequested(int oldIndex, int newIndex)

    /**
     * Emitted when the drag operation is complete and the item has been
     * dropped in the new final position
     */
    signal dropped()

    implicitWidth: Kirigami.Units.iconSizes.smallMedium
    implicitHeight: implicitWidth

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        drag {
            target: listItem
            axis: Drag.YAxis
            minimumY: 0
        }
        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        Kirigami.Icon {
            id: internal
            source: "handle-sort"
            property int startY
            property int mouseDownY
            property Item originalParent
            opacity: mouseArea.pressed || (!Kirigami.Settings.tabletMode && listItem.hovered) ? 1 : 0.6
            property int listItemLastY
            property bool draggingUp

            function arrangeItem() {
                var newIndex = listView.indexAt(1, listView.contentItem.mapFromItem(mouseArea, 0, internal.mouseDownY).y);

                if (newIndex > -1 && ((internal.draggingUp && newIndex < index) || (!internal.draggingUp && newIndex > index))) {
                    root.moveRequested(index, newIndex);
                }
            }

            anchors.fill: parent
        }
        preventStealing: true


        onPressed: {
            internal.originalParent = listItem.parent;
            listItem.parent = listView;
            listItem.y = internal.originalParent.mapToItem(listItem.parent, listItem.x, listItem.y).y;
            internal.originalParent.z = 99;
            internal.startY = listItem.y;
            internal.listItemLastY = listItem.y;
            internal.mouseDownY = mouse.y;
            // while dragging listItem's height could change
            // we want a const maximumY during the dragging time
            mouseArea.drag.maximumY = listView.height - listItem.height;
        }

        onPositionChanged: {
            if (!pressed || listItem.y === internal.listItemLastY) {
                return;
            }

            internal.draggingUp = listItem.y < internal.listItemLastY
            internal.listItemLastY = listItem.y;

            internal.arrangeItem();

             // autoscroll when the dragging item reaches the listView's top/bottom boundary
            scrollTimer.running = (listView.contentHeight > listView.height)
                               && ( (listItem.y === 0 && !listView.atYBeginning) ||
                                    (listItem.y === mouseArea.drag.maximumY && !listView.atYEnd) );
        }
        onReleased: {
            listItem.y = internal.originalParent.mapFromItem(listItem, 0, 0).y;
            listItem.parent = internal.originalParent;
            dropAnimation.running = true;
            scrollTimer.running = false;
            root.dropped();
        }
        onCanceled: released()
        SequentialAnimation {
            id: dropAnimation
            YAnimator {
                target: listItem
                from: listItem.y
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
            PropertyAction {
                target: listItem.parent
                property: "z"
                value: 0
            }
        }
        Timer {
            id: scrollTimer
            interval: 50
            repeat: true
            onTriggered: {
                if (internal.draggingUp) {
                    listView.contentY -= Kirigami.Units.gridUnit;
                    if (listView.atYBeginning) {
                        listView.positionViewAtBeginning();
                        stop();
                    }
                } else {
                    listView.contentY += Kirigami.Units.gridUnit;
                    if (listView.atYEnd) {
                        listView.positionViewAtEnd();
                        stop();
                    }
                }
                internal.arrangeItem();
            }
        }
    }
}

