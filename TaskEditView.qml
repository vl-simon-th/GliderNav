import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import GliderNav

import QtPositioning
import QtLocation

Page {
    id: root
    property Task task : Task{}
    signal close()

    TextField {
        id: nameTextField

        text: task ? task.name : ""

        z:2

        anchors.margins: 6
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        placeholderText: qsTr("Enter Task Name")
    }

    AirMap {
        id: airMap

        anchors.fill: parent
        currentTask: task

        TapHandler {
            id: tapHandler

            onSingleTapped: {
                task.addTurnPoint(airMap.map.toCoordinate(tapHandler.point.position), 1000)
            }
        }
    }

    footer: ToolBar {
        RowLayout {
            spacing: 8
            anchors.fill: parent
            ToolButton {
                id: cancelButton

                display: AbstractButton.IconOnly
                icon.source: "icons/xmark-circle.svg"
                icon.height: 25
                icon.width: 25

                Layout.fillWidth: true

                onClicked: {
                    if(task.name === "") {
                        Controller.tasksList.removeTask(task)
                    }

                    root.close()
                }
            }

            ToolButton {
                id: acceptButton

                display: AbstractButton.IconOnly
                icon.source: "icons/check-circle-1.svg"
                icon.height: 25
                icon.width: 25

                Layout.fillWidth: true

                onClicked: {
                    if(nameTextField.text !== "") {
                        task.name = nameTextField.text
                        root.close()
                    } else {
                        dialog.open()
                    }
                }

                MessageDialog {
                    id: dialog
                    buttons: MessageDialog.Ok
                    text: qsTr("Every Task needs a name.")
                }
            }
        }
    }
}
