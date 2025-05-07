import QtQuick
import QtLocation
import QtPositioning

import QtQuick.Controls
import QtQuick.Dialogs
import QtCore

import QtQuick.Layouts

import QtQuick.Effects

import GliderNav

Item {
    id: root

    required property var safeAreaMargins

    AirMap {
        id: airMap

        safeAreaMargins: root.safeAreaMargins

        anchors.fill: parent

        posSourceActive: true

        currentTask: Controller.currentTask
        currentFlightLog: Controller.currentLog

        property bool reCenter : false

        onMovedByHand: reCenter = false
        onCenterButtonClicked: reCenter = true
        centerButtonVisible: true

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
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }
                MultiEffect {
                    anchors.fill: userPositionImage
                    source: userPositionImage
                    brightness: 1
                    colorization: 1
                    colorizationColor: "deeppink"

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
                airMap.center = userPos.coordinate
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

        width: 55
        height: 55

        anchors.top: infoLayout.bottom
        anchors.left: parent.left
        anchors.leftMargin: Math.max(8, 2 + root.safeAreaMargins.left)
        anchors.topMargin: 8

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

        width: 55
        height: 55

        anchors.top: leftSpacer.width > 75 ? infoLayout.top : infoLayout.bottom
        anchors.left: parent.left
        anchors.leftMargin: Math.max(8, 2 + root.safeAreaMargins.left)
        anchors.topMargin: 8

        onClicked: {
            Controller.currentLog = flightLogFactory.createObject()
            Controller.logList.addLog(Controller.currentLog)
        }
    }

    RowLayout {
        id: infoLayout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Math.max(8, root.safeAreaMargins.top + 2)
        anchors.leftMargin: 4 + root.safeAreaMargins.left
        anchors.rightMargin: 4 + root.safeAreaMargins.right

        property int maxWidth: 75
        property int prefWidth: (width - (children.length - 1) *spacing) / (children.length-2)

        spacing: 6

        Item {
            id: leftSpacer
            Layout.fillWidth: true
        }

        Label {
            id: heightLabel
            text: airMap.userPos.altitudeValid ? Math.round(airMap.userPos.coordinate.altitude) + " m" : "--- m"
            font.pixelSize: 16

            Layout.preferredHeight: width
            Layout.maximumWidth: infoLayout.maxWidth
            Layout.preferredWidth: infoLayout.prefWidth

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

                        gr = Math.round(d_x / -d_h)

                        if(gr < 0 || gr > 100) gr = "-"
                    }
                } else {
                    gr = "-"
                }

                glideRatioLabel.text = gr + " : 1"
            }

            text: "- : 1"
            font.pixelSize: 16

            Layout.preferredHeight: width
            Layout.maximumWidth: infoLayout.maxWidth
            Layout.preferredWidth: infoLayout.prefWidth

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
            Layout.preferredHeight: width
            Layout.maximumWidth: infoLayout.maxWidth
            Layout.preferredWidth: infoLayout.prefWidth

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
            id: distToGoalLabel

            text: airMap.userPos && airMap.goal && airMap.goal.isValid ? Math.round(airMap.userPos.coordinate.distanceTo(airMap.goal)/1000) + " km" : "- km"

            Layout.preferredHeight: width
            Layout.maximumWidth: infoLayout.maxWidth
            Layout.preferredWidth: infoLayout.prefWidth

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
            Layout.preferredHeight: width
            Layout.maximumWidth: infoLayout.maxWidth
            Layout.preferredWidth: infoLayout.prefWidth

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter


            background: Rectangle {
                radius: 4
                border.color: "grey"
                border.width: 2
                color: "white"
            }
        }

        Item {
            Layout.fillWidth: true
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
