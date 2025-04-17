
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
    required property var safeAreaMargins

    signal close()

    onVisibleChanged: {
        if(visible) {
            airMap.fitToTask()
            footerRoot.height = footerFlickable.contentHeight + 6
        }
    }

    onHeightChanged: {
        if (footerRoot.height > root.height - mover.height - root.safeAreaMargins.top) {
            footerRoot.height = root.height - mover.height - root.safeAreaMargins.top
        }
    }

    AirMap {
        id: airMap

        safeAreaMargins: root.safeAreaMargins

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
            model: task ? task.turnPoints.length : 0

            z: 1

            delegate: MapQuickItem {
                id: tpMarkerMapQuickItem
                coordinate: task.turnPoints[model.index] ? task.turnPoints[model.index] : null
                sourceItem: Item {
                    id: tpMarkerRoot
                    height: 30
                    x: height/-2
                    y: height/-2
                    width: height

                    MessageDialog {
                        id: deleteTpDialog

                        text: qsTr("Do you really want to delete TP ") + model.index + " ?"

                        buttons: MessageDialog.Yes | MessageDialog.No
                        onAccepted: task.removeTurnPoint(model.index)
                    }

                    function coordToString(coord) {
                        return Math.abs(coord.latitude).toFixed(5) + "° " + (coord.latitude < 0 ? "S" : "N") + ", " +
                                Math.abs(coord.longitude).toFixed(5) + "° " + (coord.latitude < 0 ? "W" : "E")
                    }

                    function openDeleteTpDialog() {
                        deleteTpDialog.informativeText = qsTr("TP ") + model.index + qsTr(" is at ") +
                                (task.turnPoints[model.index] ? Controller.airportModel.findAirport(task.turnPoints[model.index]) ?
                                    Controller.airportModel.findAirport(task.turnPoints[model.index]).name :
                                    coordToString(task.turnPoints[model.index]) : "")
                        deleteTpDialog.open()
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: 10

                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onPressAndHold: tpMarkerRoot.openDeleteTpDialog()

                        onClicked: function(mouse) {
                            if(mouse.button === Qt.LeftButton) {
                                task.addTurnPoint(tpMarkerMapQuickItem.coordinate, 10000)
                            } else if(mouse.button === Qt.RightButton) {
                                tpMarkerRoot.openDeleteTpDialog()
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: height/2

                        color: "pink"

                        DragHandler {
                            id: tpDragHandler
                            target: null
                            onTranslationChanged: function (delta) {
                                var p = airMap.fromCoordinate(tpMarkerMapQuickItem.coordinate, false)
                                p.x += delta.x
                                p.y += delta.y
                                task.turnPoints[model.index] = airMap.toCoordinate(p, false)
                            }
                            onActiveChanged: {
                                if(!active) {
                                    var minDist = 9999999999
                                    var coord = QtPositioning.coordinate()
                                    var tp = false

                                    for(var i = 0; i < task.turnPoints.length; i++) {
                                        if(i !== model.index) {
                                            var distTp = task.turnPoints[model.index].distanceTo(task.turnPoints[i])
                                            if(distTp !== 0 && distTp < minDist) {
                                                minDist = distTp
                                                coord = task.turnPoints[i]
                                                tp = true
                                            }
                                        }
                                    }

                                    for(i = 0; i < Controller.airportModel.airports.length; i++) {
                                        var dist = task.turnPoints[model.index].distanceTo(Controller.airportModel.airports[i].position)
                                        if(dist !== 0 && dist < minDist) {
                                            minDist = dist
                                            coord = Controller.airportModel.airports[i].position
                                            tp = false
                                        }
                                    }

                                    if(coord.isValid && minDist < (tp ? 1000 : 2000)) {
                                        task.turnPoints[model.index] = coord
                                    }
                                }
                            }

                            grabPermissions: PointHandler.CanTakeOverFromAnything
                        }
                    }
                }
            }
            Component.onCompleted: airMap.addMapItemView(tpMarkerMapItemView)
        }

        onAirportClicked: (coordinate) => {
                              task.addTurnPoint(coordinate, 10000)
                          }
    }

    footer: Item {
        id: footerRoot

        Component.onCompleted: height = footerFlickable.contentHeight + 6

        Rectangle {
            id: mover
            anchors.bottom: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            anchors.bottomMargin: -6
            radius: 6

            height: 30

            color: "white"

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 30
                anchors.rightMargin: 30
                anchors.bottomMargin: 12

                height: 6
                radius: 3

                color: "darkgrey"
            }

            DragHandler {
                id: footerDragHandler
                target: null
                onTranslationChanged: (delta) => {
                                          footerRoot.height += -delta.y
                                          if(footerRoot.height < 0) {
                                              footerRoot.height = 0
                                          } else if (footerRoot.height > root.height - mover.height - root.safeAreaMargins.top) {
                                              footerRoot.height = root.height - mover.height - root.safeAreaMargins.top
                                          } else if (footerRoot.height > footerFlickable.contentHeight + 6) {
                                              footerRoot.height = footerFlickable.contentHeight + 6
                                          }
                                      }
                grabPermissions: PointerHandler.CanTakeOverFromAnything
            }
        }

        Flickable {
            id: footerFlickable

            anchors.fill: parent

            contentWidth: width
            contentHeight: footerLayout.implicitHeight

            flickableDirection: Flickable.VerticalFlick
            clip: true

            ColumnLayout {
                id: footerLayout

                anchors.left: parent.left
                anchors.right: parent.right

                anchors.leftMargin: Math.max(8, root.safeAreaMargins.left + 2)
                anchors.rightMargin: Math.max(8, root.safeAreaMargins.right + 2)

                spacing: 6

                Item {
                    height: 8
                }

                TextField {
                    id: nameTextField

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    text: task ? task.name : ""

                    placeholderText: qsTr("Enter Task Name")
                }

                Text {
                    id: taskTypeText

                    text: qsTr("Type")
                }

                ComboBox {
                    id: taskTypeComboBox

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    model: ["AAT", "RT"]

                    onCurrentIndexChanged: {
                        task.taskType = taskTypeComboBox.currentIndex
                    }

                    currentIndex: task && task.taskType === 0 ? 0 : 1
                }

                RowLayout {
                    Layout.fillWidth:true

                    Text {
                        id: turnPointsText

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight

                        text: qsTr("Turnpoints")
                    }

                    Text {
                        id: lengthText

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight

                        text: Math.floor(task ? task.length/1000 : 0) + " km"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    ToolButton {
                        id: topAddButton

                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        Layout.minimumWidth: height
                        Layout.alignment: Qt.AlignCenter

                        display: AbstractButton.IconOnly
                        icon.source: "icons/plus.svg"
                        icon.height: 25
                        icon.width: 25

                        onClicked: {
                            addDialog.pos = 0
                            addDialog.open()
                        }
                    }
                }

                ListView {
                    id: turnPointsListView

                    interactive: false

                    implicitHeight: 75*count + 6*Math.max(count-1, 0)

                    Layout.fillWidth: true
                    model: task ? task.turnPoints.length : []

                    spacing: 6

                    TurnpointDialog {
                        id: turnpointDialog

                        anchors.centerIn: Overlay.overlay

                        property int currentEdit : -1
                        onAccepted: {
                            var minDist = 999999999
                            var minDistIndex = -1
                            for(var i = 0; i < Controller.airportModel.airports.length; i++) {
                                var dist = coord.distanceTo(Controller.airportModel.airports[i].position)
                                if(dist !== 0 && dist < minDist) {
                                    minDist = dist
                                    minDistIndex = i
                                }
                            }
                            if(minDist < 100) {
                                coord = Controller.airportModel.airports[minDistIndex].position
                            }

                            if(currentEdit !== -1) {
                                task.turnPoints[currentEdit] = coord
                            }
                        }
                    }

                    TurnpointDialog {
                        id: addDialog

                        anchors.centerIn: Overlay.overlay

                        property int pos: 0

                        coord: QtPositioning.coordinate(0, 0)

                        onOpened: {
                            coord = QtPositioning.coordinate(0, 0)
                        }

                        onAccepted: {
                            task.insertTurnPoint(coord, 10000, pos)
                        }
                    }

                    delegate: GridLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        height: 75

                        rows: 2
                        columns: 3

                        Text {
                            id: indexText

                            text: qsTr("TP ") + model.index
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: 16

                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Layout.row: 0
                            Layout.column: 0
                        }

                        ToolButton {
                            id: editButton

                            onClicked: {
                                turnpointDialog.currentEdit = model.index
                                turnpointDialog.coord = task.turnPoints[model.index]
                                turnpointDialog.open()
                            }

                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            Layout.minimumWidth: height
                            Layout.alignment: Qt.AlignCenter

                            display: AbstractButton.IconOnly
                            icon.source: "icons/pencil-1.svg"
                            icon.height: 25
                            icon.width: 25

                            Layout.row: 0
                            Layout.column: 1
                        }

                        ToolButton {
                            id: deleteButton

                            onClicked: task.removeTurnPoint(model.index)

                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            Layout.minimumWidth: height
                            Layout.alignment: Qt.AlignCenter

                            display: AbstractButton.IconOnly
                            icon.source: "icons/trash-3.svg"
                            icon.height: 25
                            icon.width: 25

                            Layout.row: 0
                            Layout.column: 2
                        }

                        TextField {
                            id: distanceTextField
                            text: (task.distancesToPoint[model.index] / 1000.0)

                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            visible: task.taskType === 0

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

                            Layout.row: 1
                            Layout.column: 0
                        }

                        Text {
                            id: kmText
                            text: qsTr("km")
                            verticalAlignment: Text.AlignVCenter
                            visible: task.taskType === 0

                            Layout.row: 1
                            Layout.column: 1
                        }

                        function coordToString(coord) {
                            return Math.abs(coord.latitude).toFixed(5) + "° " + (coord.latitude < 0 ? "S" : "N") + ", " + Math.abs(coord.longitude).toFixed(5) + "° " + (coord.latitude < 0 ? "W" : "E")
                        }

                        Text {
                            id: tpNameText
                            text: Controller.airportModel.findAirport(task.turnPoints[model.index]) ? Controller.airportModel.findAirport(task.turnPoints[model.index]).name : coordToString(task.turnPoints[model.index])
                            visible: task.taskType === 1

                            Layout.row: 1
                            Layout.column: 0
                        }

                        ToolButton {
                            id: addButton

                            onClicked: {
                                addDialog.pos = model.index + 1
                                addDialog.open()
                            }

                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            Layout.minimumWidth: height
                            Layout.alignment: Qt.AlignCenter

                            display: AbstractButton.IconOnly
                            icon.source: "icons/plus.svg"
                            icon.height: 25
                            icon.width: 25
                        }
                    }
                }

                ToolBar {
                    Layout.fillWidth: true
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

                Item {
                    height: 8
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "white"
            z: -1
        }
    }
}
