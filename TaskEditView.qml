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
        columns: 5
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
            id: lengthText

            Layout.row: 0
            Layout.column: 1

            Layout.fillHeight: true

            text: "- " + Math.floor(task.length/1000) + "km"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

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
            Layout.column: 2
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
            Layout.column: 3
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
            Layout.column: 4
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
            Layout.column: 2
            Layout.columnSpan: 3

            Layout.fillWidth: true
            Layout.leftMargin: -parent.columnSpacing

            model: task.distancesToPoint.length

            Layout.minimumHeight: currentItem ? task.distancesToPoint.length * currentItem.height : 0

            visible: task.taskType === 0

            Rectangle {
                anchors.fill: parent
                color: "white"
                z: -1

                radius: 4
            }

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 4
                color: "white"
                z: -1
            }

            delegate: RowLayout {
                spacing: 0
                anchors.left: parent.left
                anchors.right: parent.right
                Text {
                    id: indexText
                    text: model.index + 1
                    font.pointSize: 11
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    Layout.fillHeight: true

                    Layout.minimumWidth: height
                }
                TextField {
                    id: distanceTextField
                    text: (task.distancesToPoint[model.index] / 1000.0)

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    onTextEdited: {
                        if(!(text === "" || text.endsWith("."))) {
                            task.distancesToPoint[model.index] = parseFloat(text) * 1000
                        }
                    }

                    onTextChanged: {
                        if (text === "nan" || text === "inf") {
                            text = "0"
                        }
                    }

                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: RegularExpressionValidator {regularExpression: /(\d+(\.\d{1,3})?|\.\d{1,3})/}
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
        posSourceActive: root.visible

        TapHandler {
            id: tapHandler

            onSingleTapped: {
                task.addTurnPoint(airMap.toCoordinate(tapHandler.point.position), 10000)
            }
        }

        MapItemView {
            id: tpMarkerMapItemView
            model: task ? task.turnPoints : []

            z: 1

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

                    onClicked: task.addTurnPoint(tpMarkerMapQuickItem.coordinate, 10000)
                    onDoubleClicked: task.removeTurnPoint(tpMarkerMapQuickItem.coordinate)
                }
            }

            Component.onCompleted: airMap.addMapItemView(tpMarkerMapItemView)
        }

        onAirportClicked: (coordinate) => {
                              task.addTurnPoint(coordinate, 10000)
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
