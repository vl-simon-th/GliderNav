import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import GliderNav

import QtCore

Flickable {
    id: root

    flickableDirection: Flickable.VerticalFlick

    contentWidth: width
    contentHeight: mainLayout.height + 20

    ColumnLayout {
        id: mainLayout
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
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

            interactive: false

            property int delHeight : 40
            implicitHeight: count * delHeight

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: Controller.airspaceModel.availableTypes

            delegate: SwitchDelegate {
                id: asDelegate
                text: modelData

                height: validAsTypesListView.delHeight

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

            interactive: false

            property int delHeight : 40
            implicitHeight: count * delHeight

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: Controller.airportModel.availableStyles

            delegate: SwitchDelegate {
                id: aptDelegate
                text: validAptStyleListView.resolveStyle(modelData)

                height: validAptStyleListView.delHeight

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

        MapSourceModel {
            id: mapSourceModel
        }

        Text {
            id: mapTypeLabel
            text: qsTr("Map Source")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 24

            Layout.fillWidth: true
        }

        ComboBox {
            id: mapSourceCombo
            Layout.fillWidth: true
            model: mapSourceModel
            textRole: "name"

            property string previousSource: ""

            Component.onCompleted: {
                for(var i = 0; i < mapSourceModel.count; i++) {
                    if(mapSourceModel.get(i).url === AppSettings.mapSource) {
                        currentIndex = i;
                        previousSource = AppSettings.mapSource;
                        break;
                    }
                }
            }

            onActivated: {
                var newSource = mapSourceModel.get(currentIndex).url;
                if (newSource !== previousSource) {
                    AppSettings.mapSource = newSource;
                    restartDialog.open();
                }
            }

            MessageDialog {
                id: restartDialog
                text: qsTr("Changing the map source requires restarting the application.\nDo you want to restart now?")
                buttons: MessageDialog.Yes | MessageDialog.No

                onAccepted: Controller.restart();

                onRejected: {
                    // Revert the combo box to the previous selection
                    for(var i = 0; i < mapSourceModel.count; i++) {
                        if(mapSourceModel.get(i).url === mapSourceCombo.previousSource) {
                            mapSourceCombo.currentIndex = i;
                            break;
                        }
                    }
                }
            }
        }
    }
}
