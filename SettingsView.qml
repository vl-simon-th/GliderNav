import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import GliderNav

import QtCore

Flickable {
    id: root

    flickableDirection: Flickable.VerticalFlick

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.margins: 6

        Button {
            text: "Download German AptAs Data"
            onClicked: {
                Controller.downloadAptFile(Qt.url(AppSettings.aptAsDataLocation + "de_apt.cup"));
                Controller.downloadAsFile(Qt.url(AppSettings.aptAsDataLocation + "de_asp.txt"));
            }
        }

        Text {
            id: airspaceHeader
            text: qsTr("Airspace")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 24

            Layout.fillWidth: true
        }

        ListView {
            id: validAsTypesListView

            clip: true

            interactive: true

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: Controller.airspaceModel.availableTypes

            delegate: SwitchDelegate {
                text: modelData

                anchors.left: parent ? parent.left : undefined
                anchors.right: parent ? parent.right : undefined

                checked: Controller.airspaceFilterModel.validTypesContains(modelData)

                onToggled: {
                    Controller.airspaceFilterModel.updateValidTypes(modelData, checked)
                }
            }
        }

        Text {
            id: airportHeader
            text: qsTr("Airports")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 24

            Layout.fillWidth: true
        }

        ListView {
            id: validAptStyleListView

            clip: true

            interactive: true

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: Controller.airportModel.availableStyles

            delegate: SwitchDelegate {
                text: validAptStyleListView.resolveStyle(modelData)

                anchors.left: parent ? parent.left : undefined
                anchors.right: parent ? parent.right : undefined

                checked: Controller.airportFilterModel.validStylesContains(modelData)

                onToggled: {
                    Controller.airportFilterModel.updateValidStyle(modelData, checked)
                }
            }

            function resolveStyle(style) {
                switch (style) {
                    case 0:
                        return "Unknown";
                    case 1:
                        return "Waypoint";
                    case 2:
                        return "Airfield with grass surface runway";
                    case 3:
                        return "Outlanding";
                    case 4:
                        return "Gliding airfield";
                    case 5:
                        return "Airfield with solid surface runway";
                    case 6:
                        return "Mountain Pass";
                    case 7:
                        return "Mountain Top";
                    case 8:
                        return "Transmitter Mast";
                    case 9:
                        return "VOR";
                    case 10:
                        return "NDB";
                    case 11:
                        return "Cooling Tower";
                    case 12:
                        return "Dam";
                    case 13:
                        return "Tunnel";
                    case 14:
                        return "Bridge";
                    case 15:
                        return "Power Plant";
                    case 16:
                        return "Castle";
                    case 17:
                        return "Intersection";
                    case 18:
                        return "Marker";
                    case 19:
                        return "Control/Reporting Point";
                    case 20:
                        return "PG Take Off";
                    case 21:
                        return "PG Landing Zone";
                    default:
                        return style;
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Layout.maximumHeight: 25

            Label {
                id: mapTypeLabel
                text: qsTr("Map Type")

                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            SpinBox {
                id: mapTypeSpinBox
                from: 0
                to: 5
                value: AppSettings.mapTypeIndex

                onValueChanged: AppSettings.mapTypeIndex = value
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }


    }
}
