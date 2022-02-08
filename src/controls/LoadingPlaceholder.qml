// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.19 as Kirigami

/**
 * A placeholder for loading pages.
 *
 * @code{.qml}
 *     Kirigami.Page {
 *         Kirigami.LoadingPlaceholder {
 *             anchors.centerIn: parent
 *         }
 *     }
 * @endcode
 *
 * @inherit org::kde::kirigami::PlaceholderMessage
 */
Kirigami.PlaceholderMessage {
    id: loadingPlaceholder

    text: qsTr("Loading…")

    QQC2.BusyIndicator {
        Layout.alignment: Qt.AlignHCenter
        running: loadingPlaceholder.visible
        opacity: 0.5
    }
}
