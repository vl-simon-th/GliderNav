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

    GridLayout {
        id: topLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        rows: 2
        columns: 4
        rowSpacing: 0
        columnSpacing: 6

        z: 3

        TextField {
            id: nameTextField

            Layout.row: 0
            Layout.column: 0

            Layout.fillHeight: true
            Layout.fillWidth: true

            text: task ? task.name : ""

            placeholderText: qsTr("Enter Task Name")

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -topLayout.columnSpacing
                color: "white"
                z: -1
            }
        }

        Text {
            id: aatText

            Layout.row: 0
            Layout.column: 1
            Layout.fillHeight: true

            text: qsTr("AAT")
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -topLayout.columnSpacing
                color: "white"
                z: -1
            }
        }

        Switch {
            id: taskTypeSwitch

            Layout.row: 0
            Layout.column: 2
            Layout.fillHeight: true

            onCheckedChanged: {
                if(!checked) {
                    task.taskType = 0
                } else {
                    task.taskType = 1
                }
            }

            checked: task && task.taskType === 0 ? false : true

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -topLayout.columnSpacing
                color: "white"
                z: -1
            }
        }

        Text {
            id: rtText

            Layout.row: 0
            Layout.column: 3
            Layout.fillHeight: true

            text: qsTr("RT")
            verticalAlignment: Text.AlignVCenter

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -topLayout.columnSpacing
                color: "white"
                z: -1
            }
        }

        ListView {
            id: aatDistancesListView

            interactive: false

            Layout.row: 1
            Layout.column: 1
            Layout.columnSpan: 3

            Layout.fillWidth: true
            Layout.leftMargin: -parent.columnSpacing

            height: count * 30

            model: task.distancesToPoint

            visible: task.taskType === 0

            delegate: RowLayout {
                spacing: 0
                Text {
                    id: indexText
                    text: model.index
                    font.pointSize: 11
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    Layout.fillHeight: true

                    Layout.minimumWidth: height

                    Rectangle {
                        color: "white"
                        anchors.fill: parent
                        z:-1
                    }
                }
                TextField {
                    id: distanceTextField
                    text: modelData

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    onAccepted: task.distancesToPoint[model.index] = text

                    Rectangle {
                        color: "white"
                        anchors.fill: parent
                        z: -1
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if(visible) {
            airMap.fitToTask()
        }
    }

    AirMap {
        id: airMap

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
