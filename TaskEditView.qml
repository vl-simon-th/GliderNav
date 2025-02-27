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

    header: RowLayout {
        spacing: 6
        TextField {
            id: nameTextField

            Layout.fillHeight: true
            Layout.fillWidth: true

            text: task ? task.name : ""

            placeholderText: qsTr("Enter Task Name")
        }

        Text {
            id: aatText

            Layout.fillHeight: true

            text: qsTr("AAT")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Switch {
            id: taskTypeSwitch

            Layout.fillHeight: true

            onCheckedChanged: {
                if(!checked) {
                    task.taskType = 0
                } else {
                    task.taskType = 1
                }
            }

            checked: task && task.taskType === 0 ? false : true
        }

        Text {
            id: rtText

            Layout.fillHeight: true

            text: qsTr("RT")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    AirMap {
        id: airMap

        editTask: true

        anchors.fill: parent
        currentTask: task

        TapHandler {
            id: tapHandler

            onSingleTapped: {
                task.addTurnPoint(airMap.toCoordinate(tapHandler.point.position), 1000)
            }
        }

        MapItemView {
            id: tpMarkerMapItemView
            model: task ? task.turnPoints : []

            delegate: MapQuickItem {
                id: tpMarkerMapQuickItem
                coordinate: modelData
                sourceItem: AbstractButton {
                    height: 30

                    x: height/-2
                    y: height/-2
                    width: height
                    Rectangle {
                        anchors.fill: parent
                        radius: height/2

                        color: "pink"
                    }

                    onClicked: task.addTurnPoint(tpMarkerMapQuickItem.coordinate, 1000)
                    onDoubleClicked: task.removeTurnPoint(tpMarkerMapQuickItem.coordinate)
                }
            }

            Component.onCompleted: airMap.addMapItemView(tpMarkerMapItemView)
        }

        onAirportClicked: (coordinate) => {
                              task.addTurnPoint(coordinate, 1000)
                          }

        onAirportDoubleClicked: (coordinate) => {
                                    task.removeTurnPoint(coordinate)
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
                        task.writeToDir()
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
