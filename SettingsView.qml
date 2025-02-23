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

        RowLayout {
            Layout.fillWidth: true

            FileDialog {
                id: aptFileDialog
                acceptLabel: qsTr("Import APT Data")
                fileMode: FileDialog.OpenFiles
                nameFilters: ["SeeYou CUP (*.cup)"]
                flags: FileDialog.ReadOnly
                onAccepted: {
                    Controller.copyFilesToApt(selectedFiles)
                }
            }

            Button {
                id: importAptButton
                text: qsTr("Import APT Data")

                Layout.fillWidth: true
                Layout.fillHeight: true

                onClicked: {
                    aptFileDialog.open()
                }
            }

            FileDialog {
                id: asFileDialog
                acceptLabel: qsTr("Import AS Data")
                fileMode: FileDialog.OpenFiles
                nameFilters: ["Open Air (*.txt)"]
                onAccepted: {
                    Controller.copyFilesToAs(selectedFiles)
                }
            }

            Button {
                id: importAsButton
                text: qsTr("Import AS Data")

                Layout.fillWidth: true
                Layout.fillHeight: true

                onClicked: {
                    asFileDialog.open()
                }
            }
        }
    }
}
