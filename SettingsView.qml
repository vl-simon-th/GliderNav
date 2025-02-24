import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import GliderNav

import QtCore

Flickable {
    id: root

    flickableDirection: Flickable.VerticalFlick

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
