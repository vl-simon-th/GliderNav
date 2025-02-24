import QtQuick
import QtLocation
import QtPositioning

import QtQuick.Controls
import QtQuick.Dialogs
import QtCore

import GliderNav

Item {
    id: root

    LocationPermission {
        id: permission
        accuracy: LocationPermission.Precise
        availability: LocationPermission.WhenInUse

        Component.onCompleted: {
            if(permission.status !== Qt.Granted) {
                permission.request()
            }
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 3000
        active: permission.status === Qt.Granted

        onPositionChanged: {
            if(Controller.currentLog) {
                Controller.currentLog.writeToDir()
                Controller.currentLog.addPoint(positionSource.position.coordinate)
            }
        }
    }

    AirMap {
        id: airMap

        anchors.fill: parent

        currentTask: Controller.currentTask
        currentFlightLog: Controller.currentLog

        MapQuickItem {
            id: userPositionMapQuickItem

            coordinate: positionSource.position.coordinate

            sourceItem: Image {
                x: width/-2
                y: height/-2
                id: userPositionImage
                source: "icons/glider.svg"

                transform: Rotation {
                    origin.x: width/2
                    origin.y: height/2
                    angle: positionSource.position.direction ? positionSource.position.direction : 0
                }
            }

            Component.onCompleted: airMap.map.addMapItem(userPositionMapQuickItem)
        }

        Component.onCompleted: map.center = positionSource.position.coordinate
    }

    Button {
        id: centerButton

        text: qsTr("Center")

        display: AbstractButton.IconOnly
        icon.source: "icons/location-arrow-right.svg"
        icon.height: 30
        icon.width: 30

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 8

        onClicked: {
            airMap.map.center = positionSource.position.coordinate
        }
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

    Component {
        id: flightLogFactory
        FlightLog {
            Component.onCompleted: {
                setStartTimeNow()
            }
        }
    }

    Component.onDestruction: {
        if(Controller.currentLog) {
            Controller.currentLog.setEndTimeNow()
            Controller.currentLog.writeToDir()
        }
    }
}
