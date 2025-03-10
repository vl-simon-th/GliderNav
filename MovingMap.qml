import QtQuick
import QtLocation
import QtPositioning

import QtQuick.Controls
import QtQuick.Dialogs
import QtCore

import GliderNav

Item {
    id: root

    AirMap {
        id: airMap

        anchors.fill: parent

        currentTask: Controller.currentTask
        currentFlightLog: Controller.currentLog

        property Position userPos : Position{}
        property geoCoordinate goal: QtPositioning.coordinate()

        MapQuickItem {
            id: userPositionMapQuickItem

            coordinate: airMap.userPos.coordinate

            z: 5

            sourceItem: Item {
                Image {
                    id: userPositionImage

                    anchors.centerIn: parent
                    source: "icons/glider.svg"

                    rotation: airMap.userPos.direction ? airMap.userPos.direction : 0
                }
            }

            Component.onCompleted: airMap.addMapItem(userPositionMapQuickItem)
        }

        MapPolyline {
            id: goalPolyline

            line.color: "purple"
            line.width: 4

            path: [airMap.userPos.coordinate, airMap.goal]
            Component.onCompleted: airMap.addMapItem(goalPolyline)

            z: 5
        }

        onPositionChanged: function(pos) {
            userPos = pos
            if(Controller.currentLog) {
                Controller.currentLog.addPoint(pos.coordinate)
            }
        }

        onAirportClicked: (pos) => {airportMenu.airport = Controller.airportModel.findAirport(pos)}

        onAirportDoubleClicked: (pos) => {goal = pos}
    }

    AirportMenu {
        id: airportMenu

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Button {
        id: stopLogButton

        text: qsTr("Stop Log")

        visible: airMap.currentFlightLog

        display: AbstractButton.IconOnly
        icon.source: "icons/refresh-circle-1-clockwise.svg"
        icon.height: 30
        icon.width: 30

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8

        z: 10

        MessageDialog {
            id: taskResetDialog
            text: qsTr("Do you really want to stop the flight log?")
            buttons: MessageDialog.Reset | MessageDialog.Cancel

            onButtonClicked: (button, role) => {
                switch(button) {
                    case MessageDialog.Reset:
                        Controller.currentLog.setEndTimeNow()
                        Controller.currentLog.writeToDir()
                        Controller.currentLog = null
                }
            }
        }

        onClicked: taskResetDialog.open()
    }

    Button {
        id: startLogButton

        text: qsTr("Start Log")

        visible: !airMap.currentFlightLog

        z: 10

        display: AbstractButton.IconOnly
        icon.source: "icons/play.svg"
        icon.height: 30
        icon.width: 30

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8

        onClicked: {
            Controller.currentLog = flightLogFactory.createObject()
            Controller.logList.addLog(Controller.currentLog)
        }
    }

    Label {
        id: heightLabel
        text: airMap.userPos.altitudeValid ? Math.round(airMap.userPos.coordinate.altitude) + " m" : "--- m"

        height: startLogButton.height
        width: Math.max(startLogButton.width, contentWidth + 10)

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 4

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter


        background: Rectangle {
            radius: 4
            border.color: "grey"
            border.width: 2
            color: "white"
        }
    }

    Component {
        id: flightLogFactory
        FlightLog {
            Component.onCompleted: {
                setStartTimeNow()
            }
        }
    }

    Component.onDestruction: {
        if(false && Controller.currentLog) {
            Controller.currentLog.setEndTimeNow()
            Controller.currentLog.writeToDir()
        }
    }
}
