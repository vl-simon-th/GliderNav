import QtQuick
import QtLocation
import QtPositioning

import QtQuick.Controls
import QtQuick.Dialogs
import QtCore

import QtQuick.Layouts

import GliderNav

Item {
    id: root

    AirMap {
        id: airMap

        anchors.fill: parent

        posSourceActive: true

        currentTask: Controller.currentTask
        currentFlightLog: Controller.currentLog

        property bool reCenter : false

        onMovedByHand: reCenter = false
        onCenterButtonClicked: reCenter = true

        property Position userPos : Position{}
        property list<geoCoordinate> lastUserPosCoords : []

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
            line.width: 3

            path: airMap.goal.isValid ? [airMap.userPos.coordinate, airMap.goal] : []
            Component.onCompleted: airMap.addMapItem(goalPolyline)

            z: 5
        }

        onPositionChanged: function(pos) {
            userPos = pos
            if(Controller.currentLog) {
                Controller.currentLog.addPoint(pos.coordinate)
            }
            lastUserPosCoords.push(pos.coordinate)

            if(lastUserPosCoords.length > 10) {
                lastUserPosCoords.shift()
            }

            glideRatioLabel.updateCurrentGlideRatio(lastUserPosCoords)

            if(reCenter) {
                airMap.center = userPos
            }
        }

        onAirportClicked: (pos) => {airportMenu.airport = Controller.airportModel.findAirport(pos)}

        onAirportDoubleClicked: (pos) => {
                                    if(goal.altitude === pos.altitude && goal.longitude === pos.longitude) {
                                        goal = QtPositioning.coordinate()
                                        airportMenu.airport = airportMenu.defaultAirport
                                    } else {
                                        goal = pos
                                    }
                                }
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

    ColumnLayout {
        id: infoLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 4

        Label {
            id: heightLabel
            text: airMap.userPos.altitudeValid ? Math.round(airMap.userPos.coordinate.altitude) + " m" : "--- m"

            Layout.preferredHeight: startLogButton.height
            Layout.minimumWidth: Math.max(startLogButton.width, contentWidth + 8)
            Layout.fillWidth: true

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter


            background: Rectangle {
                radius: 4
                border.color: "grey"
                border.width: 2
                color: "white"
            }
        }

        Label {
            id: glideRatioLabel

            function updateCurrentGlideRatio(posList) {
                var gr = ""
                if(posList.length > 1) {
                    if(posList[posList.length-1].altitude === posList[0].altitude) {
                        gr = "-"
                    } else {
                        var d_h = posList[posList.length-1].altitude - posList[0].altitude
                        var d_x = posList[posList.length-1].distanceTo(posList[0])

                        gr = Math.round(d_x / d_h)
                    }
                } else {
                    gr = "-"
                }

                glideRatioLabel.text = gr + " : 1"
            }

            text: "- : 1"

            Layout.preferredHeight: startLogButton.height
            Layout.minimumWidth: Math.max(startLogButton.width, contentWidth + 8)
            Layout.fillWidth: true

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter


            background: Rectangle {
                radius: 4
                border.color: "grey"
                border.width: 2
                color: "white"
            }
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
