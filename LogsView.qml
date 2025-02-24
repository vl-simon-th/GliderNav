import QtQuick
import QtLocation
import QtPositioning

import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import GliderNav

Item {
    id: root

    ListView {
        id: listView
        anchors.fill: parent

        model: Controller.logList.logs

        property string dateFormat: "dd.MM.yyyy HH:mm:ss"

        spacing: 20

        delegate: RowLayout {
            id: delegate
            property FlightLog flightLog: modelData

            anchors.left: parent.left
            anchors.right: parent.right

            height: Math.max(30, dateText.implicitHeight, viewButton.implicitHeight)
            clip: true

            Text {
                id: dateText
                text: Qt.formatDateTime(delegate.flightLog.startTime, root.dateFormat) + " - " +
                      Qt.formatDateTime(delegate.flightLog.endTime, root.dateFormat)

                wrapMode: Text.WordWrap

                Layout.fillHeight: true
                Layout.fillWidth: true

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            ToolButton {
                id: viewButton

                onClicked: {
                    logAirMap.currentFlightLog = delegate.flightLog
                    logAirMap.visible = true
                }

                display: AbstractButton.IconOnly
                icon.source: "icons/eye.svg"
                icon.height: 25
                icon.width: 25
            }

            ToolButton {
                id: deleteButton

                enabled: delegate.flightLog !== Controller.currentLog

                MessageDialog {
                    id: deleteDialog
                    text: qsTr("Do you really want to delete this log?")
                    buttons: MessageDialog.Yes | MessageDialog.No

                    onAccepted: Controller.logList.deleteLog(delegate.flightLog)
                }

                onClicked: {
                    if(delegate.flightLog !== Controller.currentLog) {
                        deleteDialog.open()
                    }
                }

                display: AbstractButton.IconOnly
                icon.source: "icons/trash-3.svg"
                icon.height: 25
                icon.width: 25
            }
        }
    }


    AirMap  {
        id: logAirMap

        anchors.fill: parent
        visible: false

        Button {
            id: backButton

            text: qsTr("Back")

            display: AbstractButton.IconOnly
            icon.source: "icons/arrow-left-circle.svg"
            icon.height: 30
            icon.width: 30

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 8

            onClicked: {
                logAirMap.visible = false
            }
        }

        onVisibleChanged: {
            var shape = QtPositioning.polygon(currentFlightLog.path)
            console.log(shape.boundingGeoRectangle().path)
            map.visibleRegion = shape.boundingGeoRectangle()
        }

        onCurrentFlightLogChanged: {
            var shape = QtPositioning.polygon(currentFlightLog.path)
            map.visibleRegion = shape.boundingGeoRectangle()
        }
    }
}
