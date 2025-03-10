import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GliderNav

Item {
    id: root
    property Airport airport : defaultAirport
    property alias defaultAirport : defaultAirport

    Airport {
        id: defaultAirport
    }

    Rectangle {
        id: background
        color: "white"

        anchors.left: parent.left
        anchors.right: parent.right

        height: mainLayout.implicitHeight + 20
        state: root.airport.position.isValid ? "active" : "inactive"

        radius: 6
        Rectangle {
            id: bottomBackground
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 6
        }

        GridLayout {
            id: mainLayout

            anchors.fill: parent
            anchors.margins: 6

            rows: 4
            columns: 3

            Button {
                id: backButton

                Layout.row: 0
                Layout.column: 0

                display: AbstractButton.IconOnly
                icon.source: "icons/arrow-left-circle.svg"

                onClicked: root.airport = defaultAirport
            }

            Text {
                id: nameText
                Layout.row: 0
                Layout.column: 1
                Layout.columnSpan: 2

                Layout.fillHeight: true
                Layout.fillWidth: true

                text: root.airport.name
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 12
            }

            Text {
                id: codeText

                Layout.row: 1
                Layout.column: 1

                Layout.fillHeight: true
                Layout.fillWidth: true

                text: root.airport.code
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: freqText

                Layout.row: 1
                Layout.column: 2

                Layout.fillHeight: true
                Layout.fillWidth: true

                text: root.airport.freq
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: elevText

                Layout.row: 2
                Layout.column: 1

                Layout.fillHeight: true
                Layout.fillWidth: true

                text: root.airport.elevation + "m"
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: styleText

                Layout.row: 2
                Layout.column: 2

                Layout.fillHeight: true
                Layout.fillWidth: true

                text: qsTr(root.resolveStyle(root.airport.style))
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: rwLenText

                Layout.row: 3
                Layout.column: 1

                Layout.fillHeight: true
                Layout.fillWidth: true

                text: root.airport.rwlen !== 0 ? qsTr("len") + ": " + root.airport.rwlen + "m" : ""
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: rwWidthText

                Layout.row: 3
                Layout.column: 2

                Layout.fillHeight: true
                Layout.fillWidth: true

                text: root.airport.rwwidth !== 0 ? qsTr("width") + ": " + root.airport.rwwidth + "m" : ""
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: descText

                Layout.row: 4
                Layout.column: 1
                Layout.columnSpan: 2

                Layout.fillHeight: true
                Layout.fillWidth: true

                text: root.airport.desc
            }
        }

        states: [
            State {
                name: "active"
                PropertyChanges {
                    background.y: -background.height
                }
            },
            State {
                name: "inactive"
                PropertyChanges {
                    background.y: 0
                }
            }
        ]
        transitions: [
            Transition {
                NumberAnimation {
                    property: "y"
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        ]
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
