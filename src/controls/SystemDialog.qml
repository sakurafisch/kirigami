/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.18 as Kirigami
import "private" as Private

/**
 * Component to create fullscreen dialogs that come from the system.
 */
Kirigami.AbstractApplicationWindow {
    id: root
    visible: false
    
    flags: Qt.FramelessWindowHint | Qt.Dialog
    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false
    color: visible && visibility === 5 ? Qt.rgba(0, 0, 0, 0.5) : "transparent" // darken when fullscreen
    
    x: root.transientParent.x + root.transientParent.width / 2 - root.width / 2
    y: root.transientParent.y + root.transientParent.height / 2 - root.height / 2
    modality: visibility !== 5 ? Qt.WindowModal : Qt.NonModal // darken parent window when not fullscreen
    
    Behavior on color {
        ColorAnimation { 
            duration: 500
            easing.type: Easing.InOutQuad
        } 
    }
    
    /**
     * This property holds the dialog's contents.
     * 
     * The initial height and width of the dialog is calculated from the 
     * `implicitWidth` and `implicitHeight` of this item.
     */
    default property Item mainItem
    
    /**
     * This property holds the absolute maximum height the dialog can be
     * (including the header and footer).
     * 
     * The height restriction is solely applied on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     * 
     * This is the window height, subtracted by largeSpacing on both the top 
     * and bottom.
     */
    readonly property real absoluteMaximumHeight: height - Kirigami.Units.gridUnit * 2
    
    /**
     * This property holds the absolute maximum width the dialog can be.
     * 
     * By default, it is the window width, subtracted by largeSpacing on both 
     * the top and bottom.
     */
    readonly property real absoluteMaximumWidth: width - Kirigami.Units.gridUnit * 2
    
    /**
     * This property holds the maximum height the dialog can be (including
     * the header and footer).
     * 
     * The height restriction is solely enforced on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     * 
     * By default, this is `absoluteMaximumHeight`.
     */
    property real maximumHeight: absoluteMaximumHeight
    
    /**
     * This property holds the maximum width the dialog can be.
     * 
     * By default, this is `absoluteMaximumWidth`.
     */
    property real maximumWidth: absoluteMaximumWidth
    
    /**
     * This property holds the preferred height of the dialog.
     * 
     * The content will receive a hint for how tall it should be to have
     * the dialog to be this height.
     * 
     * If the content, header or footer require more space, then the height
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredHeight: -1
    
    /**
     * This property holds the preferred width of the dialog.
     * 
     * The content will receive a hint for how wide it should be to have
     * the dialog be this wide.
     * 
     * If the content, header or footer require more space, then the width
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredWidth: -1
    
    /**
     * This property holds the default padding of the content.
     */
    property real padding: Kirigami.Units.smallSpacing
    
    /**
     * This property holds the left padding of the content. If not specified, it uses `padding`.
     */
    property real leftPadding: padding
    
    /**
     * This property holds the right padding of the content. If not specified, it uses `padding`.
     */
    property real rightPadding: padding
    
    /**
     * This property holds the top padding of the content. If not specified, it uses `padding`.
     */
    property real topPadding: padding
    
    /**
     * This property holds the bottom padding of the content. If not specified, it uses `padding`.
     */
    property real bottomPadding: padding
    
    /**
     * Title of the dialog.
     */
    property string title: ""
    
    /**
     * Subtitle of the dialog.
     */
    property string subtitle: ""
    
    property real dialogCornerRadius: Kirigami.Units.smallSpacing * 2
    
    /**
     * This property holds the list of actions for this dialog.
     *
     * Each action will be rendered as a button that the user will be able
     * to click.
     */
    property list<Kirigami.Action> actions
    
    enum ActionLayout {
        Row,
        Column
    }
    
    /**
     * The layout of the action buttons in the footer of the dialog.
     * 
     * By default, if there are more than 3 actions, it will have `SystemDialog.Column`.
     * 
     * Otherwise, with zero to 2 actions, it will have `SystemDialog.Row`.
     */
    property int layout: actions.length > 3 ? 1 : 0
    
    width: loader.item.implicitWidth
    height: loader.item.implicitWidth
    
    // load in async to speed up load times (especially on embedded devices)
    Loader {
        id: loader
        anchors.fill: parent
        asynchronous: true
        
        sourceComponent: Item {
            implicitWidth: control.implicitWidth + Kirigami.Units.gridUnit * 2
            implicitHeight: control.implicitHeight + Kirigami.Units.gridUnit * 2
            
            RectangularGlow {
                anchors.topMargin: 1 
                anchors.fill: control
                cached: true
                glowRadius: 2
                cornerRadius: Kirigami.Units.gridUnit
                spread: 0.1
                color: Qt.rgba(0, 0, 0, 0.4)
            }
            
            Control {
                id: control
                anchors.centerIn: parent
            
                background: Item {
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        radius: dialogCornerRadius
                        Kirigami.Theme.colorSet: Kirigami.Theme.Window
                        Kirigami.Theme.inherit: false
                        color: Qt.darker(Kirigami.Theme.backgroundColor, 1.2)
                    }
                    Rectangle {
                        anchors.fill: parent
                        radius: dialogCornerRadius
                        
                        Kirigami.Theme.colorSet: Kirigami.Theme.Window
                        Kirigami.Theme.inherit: false
                        color: Kirigami.Theme.backgroundColor
                    }
                }
                
                topPadding: 0
                bottomPadding: 0
                rightPadding: 0
                leftPadding: 0
                
                contentItem: ColumnLayout {
                    spacing: 0
                    
                    // header
                    Control {
                        id: header
                        Layout.fillWidth: true
                        Layout.maximumWidth: root.maximumWidth
                        Layout.preferredWidth: root.preferredWidth
                        
                        Layout.bottomMargin: Kirigami.Units.largeSpacing
                        
                        topPadding: Kirigami.Units.largeSpacing
                        leftPadding: Kirigami.Units.largeSpacing
                        rightPadding: Kirigami.Units.largeSpacing
                        bottomPadding: Kirigami.Units.largeSpacing
                        
                        background: Item {}
                        
                        contentItem: RowLayout {
                            Layout.topMargin: Kirigami.Units.largeSpacing
                            spacing: 0
                            
                            Kirigami.Heading {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                level: 2
                                text: root.title
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                    
                    // content
                    Control {
                        id: content
                        
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.maximumWidth: root.maximumWidth
                        Layout.preferredWidth: root.preferredWidth
                        
                        leftPadding: 0
                        rightPadding: 0
                        topPadding: Kirigami.Units.smallSpacing
                        bottomPadding: 0
                        
                        background: Item {}
                        
                        contentItem: ColumnLayout {
                            spacing: 0
                            Label {
                                Layout.fillWidth: true
                                Layout.leftMargin: Kirigami.Units.gridUnit * 3
                                Layout.rightMargin: Kirigami.Units.gridUnit * 3
                                Layout.bottomMargin: Kirigami.Units.largeSpacing
                                visible: root.subtitle !== ""
                                horizontalAlignment: Text.AlignHCenter
                                text: root.subtitle
                                wrapMode: Label.Wrap
                            }
                            Control {
                                Layout.preferredWidth: root.preferredWidth
                                Layout.fillWidth: true
                                leftPadding: root.leftPadding; rightPadding: root.rightPadding
                                topPadding: root.topPadding; bottomPadding: root.bottomPadding
                                contentItem: root.mainItem
                            }
                        }
                    }
                    
                    Kirigami.Separator {
                        Layout.fillWidth: true
                    }
                    
                    // footer
                    Control {
                        id: footer
                        Layout.fillWidth: true
                        Layout.maximumWidth: root.maximumWidth
                        Layout.preferredWidth: root.preferredWidth
                        
                        background: Kirigami.ShadowedRectangle {
                            Kirigami.Theme.colorSet: Kirigami.Theme.Window
                            Kirigami.Theme.inherit: false
                            color: Kirigami.Theme.backgroundColor
                            corners.bottomRightRadius: dialogCornerRadius
                            corners.bottomLeftRadius: dialogCornerRadius
                        }
                        
                        topPadding: 0
                        bottomPadding: 0
                        leftPadding: 0
                        rightPadding: 0
                    
                        Component {
                            id: horizontalButtons
                            RowLayout {
                                id: horizontalRowLayout
                                spacing: 0
                                
                                Repeater {
                                    model: actions
                                    
                                    delegate: RowLayout {
                                        spacing: 0
                                        Layout.fillHeight: true
                                        
                                        Kirigami.Separator {
                                            id: separator
                                            property real fullWidth: width
                                            visible: model.index !== 0
                                            Layout.fillHeight: true
                                        }
                                        
                                        Private.SystemDialogButton {
                                            Layout.fillWidth: true
                                            // ensure consistent widths for all buttons
                                            Layout.maximumWidth: (horizontalRowLayout.width - Math.max(0, root.actions.length - 1) * separator.fullWidth) / root.actions.length
                                            
                                            corners.bottomLeftRadius: model.index === 0 ? root.dialogCornerRadius : 0
                                            corners.bottomRightRadius: model.index === root.actions.length - 1 ? root.dialogCornerRadius : 0
                                            
                                            text: modelData.text
                                            icon: modelData.icon
                                            onClicked: modelData.trigger()
                                        }
                                    }
                                }
                            }
                        }
                        
                        Component {
                            id: verticalButtons
                            ColumnLayout {
                                spacing: 0
                                
                                Repeater {
                                    model: actions
                                    
                                    delegate: ColumnLayout {
                                        spacing: 0
                                        Layout.fillWidth: true
                                        
                                        Kirigami.Separator {
                                            visible: model.index !== 0
                                            Layout.fillWidth: true
                                        }
                                        
                                        Private.SystemDialogButton {
                                            Layout.fillWidth: true
                                            corners.bottomLeftRadius: model.index === root.actions.length - 1 ? root.dialogCornerRadius : 0
                                            corners.bottomRightRadius: model.index === root.actions.length - 1 ? root.dialogCornerRadius : 0
                                            text: modelData.text
                                            icon: modelData.icon
                                            onClicked: modelData.trigger()
                                        }
                                    }
                                }
                            }
                        }
                    
                        contentItem: Loader {
                            active: true
                            sourceComponent: layout === 0 ? horizontalButtons : verticalButtons
                        }
                    }
                }
            }
        }
    }
}
