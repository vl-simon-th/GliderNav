import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GliderNav

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

        Text {
            text: qsTr("Download Airport and Airspace Data")
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 16

            Layout.fillWidth: true
        }

        AptAsMenuSection {
            id: europeSection
            headerText: qsTr("Europe")
            items: [
                {text: "Albania", code: "al", checked: false},
                {text: "Andorra", code: "ad", checked: false},
                {text: "Austria", code: "at", checked: false},
                {text: "Belarus", code: "by", checked: false},
                {text: "Belgium", code: "be", checked: false},
                {text: "Bosnia and Herzegovina", code: "ba", checked: false},
                {text: "Bulgaria", code: "bg", checked: false},
                {text: "Croatia", code: "hr", checked: false},
                {text: "Cyprus", code: "cy", checked: false},
                {text: "Czech Republic", code: "cz", checked: false},
                {text: "Denmark", code: "dk", checked: false},
                {text: "Estonia", code: "ee", checked: false},
                {text: "Finland", code: "fi", checked: false},
                {text: "France", code: "fr", checked: false},
                {text: "Germany", code: "de", checked: false},
                {text: "Greece", code: "gr", checked: false},
                {text: "Hungary", code: "hu", checked: false},
                {text: "Iceland", code: "is", checked: false},
                {text: "Ireland", code: "ie", checked: false},
                {text: "Italy", code: "it", checked: false},
                {text: "Latvia", code: "lv", checked: false},
                {text: "Liechtenstein", code: "li", checked: false},
                {text: "Lithuania", code: "lt", checked: false},
                {text: "Luxembourg", code: "lu", checked: false},
                {text: "North Macedonia", code: "mk", checked: false},
                {text: "Malta", code: "mt", checked: false},
                {text: "Moldova", code: "md", checked: false},
                {text: "Monaco", code: "mc", checked: false},
                {text: "Montenegro", code: "me", checked: false},
                {text: "Netherlands", code: "nl", checked: false},
                {text: "Norway", code: "no", checked: false},
                {text: "Poland", code: "pl", checked: false},
                {text: "Portugal", code: "pt", checked: false},
                {text: "Romania", code: "ro", checked: false},
                {text: "Russia", code: "ru", checked: false},
                {text: "San Marino", code: "sm", checked: false},
                {text: "Serbia", code: "rs", checked: false},
                {text: "Slovakia", code: "sk", checked: false},
                {text: "Slovenia", code: "si", checked: false},
                {text: "Spain", code: "es", checked: false},
                {text: "Sweden", code: "se", checked: false},
                {text: "Switzerland", code: "ch", checked: false},
                {text: "Turkey", code: "tr", checked: false},
                {text: "Ukraine", code: "ua", checked: false},
                {text: "United Kingdom", code: "gb", checked: false},
                {text: "Vatican City", code: "va", checked: false}
            ]
        }

        AptAsMenuSection {
            id: africaSection
            headerText: qsTr("Africa")
            items: [
                {text: "Algeria", code: "dz", checked: false},
                {text: "Angola", code: "ao", checked: false},
                {text: "Benin", code: "bj", checked: false},
                {text: "Botswana", code: "bw", checked: false},
                {text: "Burkina Faso", code: "bf", checked: false},
                {text: "Burundi", code: "bi", checked: false},
                {text: "Cabo Verde", code: "cv", checked: false},
                {text: "Cameroon", code: "cm", checked: false},
                {text: "Central African Republic", code: "cf", checked: false},
                {text: "Chad", code: "td", checked: false},
                {text: "Comoros", code: "km", checked: false},
                {text: "Republic of the Congo", code: "cg", checked: false},
                {text: "Democratic Republic of the Congo", code: "cd", checked: false},
                {text: "Djibouti", code: "dj", checked: false},
                {text: "Egypt", code: "eg", checked: false},
                {text: "Equatorial Guinea", code: "gq", checked: false},
                {text: "Eritrea", code: "er", checked: false},
                {text: "Eswatini", code: "sz", checked: false},
                {text: "Ethiopia", code: "et", checked: false},
                {text: "Gabon", code: "ga", checked: false},
                {text: "Gambia", code: "gm", checked: false},
                {text: "Ghana", code: "gh", checked: false},
                {text: "Guinea", code: "gn", checked: false},
                {text: "Guinea-Bissau", code: "gw", checked: false},
                {text: "Ivory Coast", code: "ci", checked: false},
                {text: "Kenya", code: "ke", checked: false},
                {text: "Lesotho", code: "ls", checked: false},
                {text: "Liberia", code: "lr", checked: false},
                {text: "Libya", code: "ly", checked: false},
                {text: "Madagascar", code: "mg", checked: false},
                {text: "Malawi", code: "mw", checked: false},
                {text: "Mali", code: "ml", checked: false},
                {text: "Mauritania", code: "mr", checked: false},
                {text: "Mauritius", code: "mu", checked: false},
                {text: "Morocco", code: "ma", checked: false},
                {text: "Mozambique", code: "mz", checked: false},
                {text: "Namibia", code: "na", checked: false},
                {text: "Niger", code: "ne", checked: false},
                {text: "Nigeria", code: "ng", checked: false},
                {text: "Rwanda", code: "rw", checked: false},
                {text: "São Tomé and Príncipe", code: "st", checked: false},
                {text: "Senegal", code: "sn", checked: false},
                {text: "Seychelles", v: "sc", checked: false},
                {text: "Sierra Leone", code: "sl", checked: false},
                {text: "Somalia", code: "so", checked: false},
                {text: "South Africa", code: "za", checked: false},
                {text: "South Sudan", code: "ss", checked: false},
                {text: "Sudan", code: "sd", checked: false},
                {text: "Tanzania", code: "tz", checked: false},
                {text: "Togo", code: "tg", checked: false},
                {text: "Tunisia", code: "tn", checked: false},
                {text: "Uganda", code: "ug", checked: false},
                {text: "Zambia", code: "zm", checked: false},
                {text: "Zimbabwe", code: "zw", checked: false}
            ]
        }

        AptAsMenuSection {
            id: northernAmericaSection
            headerText: qsTr("Northern America")
            items: [
                {text: "Canada", code: "ca", checked: false},
                {text: "Greenland", code: "gl", checked: false},
                {text: "United States", code: "us", checked: false}
            ]
        }

        Component.onCompleted: {
            var sections = [europeSection, africaSection, northernAmericaSection]

            Controller.findCurrentAptAsCodes()

            for(var i = 0; i < sections.length; i++) {
                for(var j = 0; j < sections[i].items.length; j++) {
                    sections[i].items[j].checked = Controller.aptAsCodes.includes(sections[i].items[j].code)
                }
                sections[i].reloadChecked()
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: qsTr("Cancel")

                onClicked: close()
            }

            Button {
                text: qsTr("Apply")

                onClicked: {
                    var sections = [europeSection, africaSection, northernAmericaSection]

                    Controller.clearAirportDir()
                    Controller.clearAirspaceDir()

                    for(var i = 0; i < sections.length; i++) {
                        for(var j = 0; j < sections[i].items.length; j++) {
                            if(sections[i].items[j].checked) {
                                Controller.downloadAptFile(Qt.url(AppSettings.aptAsDataLocation + sections[i].items[j].code + "_apt.cup"));
                                Controller.downloadAsFile(Qt.url(AppSettings.aptAsDataLocation + sections[i].items[j].code + "_asp.txt"));
                            }
                        }
                    }

                    Controller.reloadAirports()
                    Controller.reloadAirspaces()

                    close()
                }
            }
        }
    }
}
