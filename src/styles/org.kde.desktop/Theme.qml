/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.4
import org.kde.kirigami 2.16 as Kirigami

pragma Singleton

Kirigami.BasicThemeDefinition {
    id: theme

    textColor: palette.windowText
    disabledTextColor: disabledPalette.windowText

    highlightColor: palette.highlight
    highlightedTextColor: palette.highlightedText
    backgroundColor: palette.window
    alternateBackgroundColor: Qt.darker(palette.window, 1.05)
    activeTextColor: palette.highlight
    activeBackgroundColor: palette.highlight
    linkColor: "#2980B9"
    linkBackgroundColor: "#2980B9"
    visitedLinkColor: "#7F8C8D"
    visitedLinkBackgroundColor: "#7F8C8D"
    hoverColor: palette.highlight
    focusColor: palette.highlight
    negativeTextColor: "#DA4453"
    negativeBackgroundColor: "#DA4453"
    neutralTextColor: "#F67400"
    neutralBackgroundColor: "#F67400"
    positiveTextColor: "#27AE60"
    positiveBackgroundColor: "#27AE60"

    buttonTextColor: palette.buttonText
    buttonBackgroundColor: palette.button
    buttonAlternateBackgroundColor: Qt.darker(palette.button, 1.05)
    buttonHoverColor: palette.highlight
    buttonFocusColor: palette.highlight

    viewTextColor: palette.text
    viewBackgroundColor: palette.base
    viewAlternateBackgroundColor: palette.alternateBase
    viewHoverColor: palette.highlight
    viewFocusColor: palette.highlight

    selectionTextColor: palette.highlightedText
    selectionBackgroundColor: palette.highlight
    selectionAlternateBackgroundColor: Qt.darker(palette.highlight, 1.05)
    selectionHoverColor: palette.highlight
    selectionFocusColor: palette.highlight

    tooltipTextColor: palette.base
    tooltipBackgroundColor: palette.text
    tooltipAlternateBackgroundColor: Qt.darker(palette.text, 1.05)
    tooltipHoverColor: palette.highlight
    tooltipFocusColor: palette.highlight

    complementaryTextColor: palette.base
    complementaryBackgroundColor: palette.text
    complementaryAlternateBackgroundColor: Qt.darker(palette.text, 1.05)
    complementaryHoverColor: palette.highlight
    complementaryFocusColor: palette.highlight

    headerTextColor: palette.text
    headerBackgroundColor: palette.base
    headerAlternateBackgroundColor: palette.alternateBase
    headerHoverColor: palette.highlight
    headerFocusColor: palette.highlight

    property font defaultFont: fontMetrics.font

    property list<QtObject> children: [
        TextMetrics {
            id: fontMetrics
        },
        SystemPalette {
            id: palette
            colorGroup: SystemPalette.Active
        },
        SystemPalette {
            id: disabledPalette
            colorGroup: SystemPalette.Disabled
        }
    ]

    function __propagateColorSet(object, context) {}

    function __propagateTextColor(object, color) {}
    function __propagateBackgroundColor(object, color) {}
    function __propagatePrimaryColor(object, color) {}
    function __propagateAccentColor(object, color) {}
}
