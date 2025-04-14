import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


Flickable {
    id: root

    signal close

    contentWidth: width
    contentHeight: mainLayout.implicitHeight

    flickableDirection: Flickable.VerticalFlick

    ColumnLayout {
        id: mainLayout

        anchors.left: parent.left
        anchors.right: parent.right

        anchors.margins: 8

        Button {
            id: backButton

            icon.source: "icons/arrow-left-circle.svg"
            display: AbstractButton.IconOnly
            icon.width: 30
            icon.height: 30

            Layout.alignment: Qt.AlignLeft

            onClicked: close()
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

                    if(checked) {
                        if(!AppSettings.validAsTypes.includes(modelData)) {
                            AppSettings.validAsTypes.push(modelData)
                        }
                    } else {
                        var index = AppSettings.validAsTypes.indexOf(modelData);
                        if (index !== -1) {
                          AppSettings.validAsTypes.splice(index, 1);
                        }
                    }
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

                    if(checked) {
                        if(!AppSettings.validAptStyles.includes(modelData)) {
                            AppSettings.validAptStyles.push(modelData)
                        }
                    } else {
                        var index = AppSettings.validAptStyles.indexOf(modelData);
                        if (index !== -1) {
                          AppSettings.validAptStyles.splice(index, 1);
                        }
                    }
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
    }
}
