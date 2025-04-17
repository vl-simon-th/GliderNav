import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts
import QtPositioning

Dialog {
    id: root
    modal: true

    closePolicy: Popup.NoAutoClose

    popupType: Popup.Native

    property geoCoordinate coord : QtPositioning.coordinate()

    property int format : 0

    onOpened: {
        latDeg.recalcText()
        latMin.recalcText()
        latSec.recalcText()
        lonDeg.recalcText()
        lonMin.recalcText()
        lonSec.recalcText()
    }

    GridLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: 6

        rows: 3
        columns: 4

        ComboBox {
            id: formatComboBox
            model: [qsTr("Degrees"), qsTr("Degrees, Minutes"), qsTr("Degrees, Minutes, Seconds")]

            currentIndex: format
            onCurrentIndexChanged: {
                format = currentIndex
                latDeg.recalcText()
                latMin.recalcText()
                latSec.recalcText()
                lonDeg.recalcText()
                lonMin.recalcText()
                lonSec.recalcText()
            }

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.columnSpan: 4
            Layout.row: 0
            Layout.column: 0

            implicitContentWidthPolicy: ComboBox.WidestText
        }

        TextField {
            id: latDeg

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: implicitWidth
            Layout.row: 1
            Layout.column: 0
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignRight

            validator: RegularExpressionValidator {
                regularExpression: /^[0-9]*[.,]?[0-9]*$/
            }

            function recalcText() {
                text = format === 0 ? (Math.abs(coord.latitude)).toFixed(5) : Math.floor(Math.abs(coord.latitude))
            }

            Layout.columnSpan: format === 0 ? 3 : 1

            onTextEdited: updateLat()
        }

        TextField {
            id: latMin

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: implicitWidth
            Layout.row: 1
            Layout.column: 1
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignRight

            validator: RegularExpressionValidator {
                regularExpression: /^[0-9]*[.,]?[0-9]*$/
            }

            function recalcText() {
                text = format === 1 ? ((Math.abs(coord.latitude) - Math.floor(Math.abs(coord.latitude))) * 60).toFixed(5) :
                                    Math.floor((Math.abs(coord.latitude) - Math.floor(Math.abs(coord.latitude))) * 60)
            }

            visible: format !== 0

            Layout.columnSpan: format === 1 ? 2 : 1

            onTextEdited: updateLat()
        }

        TextField {
            id: latSec

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.row: 1
            Layout.column: 2
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignRight

            visible: format === 2

            validator: RegularExpressionValidator {
                regularExpression: /^[0-9]*[.,]?[0-9]*$/
            }

            function recalcText() {
                text = (((Math.abs(coord.latitude) - Math.floor(Math.abs(coord.latitude))) *
                        60 - Math.floor((Math.abs(coord.latitude) - Math.floor(Math.abs(coord.latitude))) * 60)) * 60).toFixed(3)
            }

            onTextEdited: updateLat()
        }

        ComboBox {
            id: latHemisphereComboBox
            model: [qsTr("N"), qsTr("S")]

            currentIndex: coord.latitude < 0 ? 1 : 0

            Layout.row: 1
            Layout.column: 3
            Layout.fillHeight: true
            Layout.maximumWidth: 100

            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: lonDeg

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: implicitWidth
            Layout.row: 2
            Layout.column: 0
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignRight

            validator: RegularExpressionValidator {
                regularExpression: /^[0-9]*[.,]?[0-9]*$/
            }

            function recalcText() {
                text = format === 0 ? (Math.abs(coord.longitude)).toFixed(5) : Math.floor(Math.abs(coord.longitude))
            }

            Layout.columnSpan: format === 0 ? 3 : 1

            onTextEdited: updateLon()
        }

        TextField {
            id: lonMin

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: implicitWidth
            Layout.row: 2
            Layout.column: 1
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignRight

            validator: RegularExpressionValidator {
                regularExpression: /^[0-9]*[.,]?[0-9]*$/
            }

            function recalcText() {
                text = format === 1 ? ((Math.abs(coord.longitude) - Math.floor(Math.abs(coord.longitude))) * 60).toFixed(5) :
                                    Math.floor((Math.abs(coord.longitude) - Math.floor(Math.abs(coord.longitude))) * 60)
            }

            visible: format !== 0

            Layout.columnSpan: format === 1 ? 2 : 1

            onTextEdited: updateLon()
        }

        TextField {
            id: lonSec

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.row: 2
            Layout.column: 2
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignRight

            visible: format === 2

            validator: RegularExpressionValidator {
                regularExpression: /^[0-9]*[.,]?[0-9]*$/
            }

            function recalcText() {
                text = (((Math.abs(coord.longitude) - Math.floor(Math.abs(coord.longitude))) *
                        60 - Math.floor((Math.abs(coord.longitude) - Math.floor(Math.abs(coord.longitude))) * 60)) * 60).toFixed(3)
            }

            onTextEdited: updateLon()
        }

        ComboBox {
            id: lonHemisphereComboBox
            model: [qsTr("E"), qsTr("W")]

            currentIndex: coord.longitude < 0 ? 1 : 0

            Layout.row: 2
            Layout.column: 3
            Layout.fillHeight: true
            Layout.maximumWidth: 100

            Layout.alignment: Qt.AlignVCenter
        }
    }

    standardButtons: Dialog.Ok | Dialog.Cancel

    function degMinToDeg(deg, min) {
        // Convert degrees and minutes to decimal degrees
        console.log(deg)
        console.log((min / 60))
        return deg + (min / 60)
    }

    function degMinSecToDeg(deg, min, sec, max) {
        // Convert degrees, minutes, and seconds to decimal degrees
        return deg + (min / 60) + (sec / 3600)
    }

    function updateLat() {
        if(format === 0) {
            coord.latitude = parseFloat(latDeg.text)
        } else if(format === 1) {
            coord.latitude = degMinToDeg(parseFloat(latDeg.text), parseFloat(latMin.text))
        } else {
            coord.latitude = degMinSecToDeg(parseFloat(latDeg.text), parseFloat(latMin.text), parseFloat(latSec.text))
        }
        if(latHemisphereComboBox.currentIndex === 1) coord.latitude = -coord.latitude
    }

    function updateLon() {
        if (format === 0) {
            coord.longitude = parseFloat(lonDeg.text);
        } else if (format === 1) {
            coord.longitude = degMinToDeg(parseFloat(lonDeg.text), parseFloat(lonMin.text));
        } else {
            coord.longitude = degMinSecToDeg(parseFloat(lonDeg.text), parseFloat(lonMin.text), parseFloat(lonSec.text));
        }
        if(lonHemisphereComboBox.currentIndex === 1) coord.longitude = -coord.longitude
    }
}
