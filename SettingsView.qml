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
        anchors.fill: parent

        Button {
            text: "Download German AptAs Data"
            onClicked: {
                Controller.downloadAptFile(Qt.url(AppSettings.aptAsDataLocation + "de_apt.cup"));
                Controller.downloadAsFile(Qt.url(AppSettings.aptAsDataLocation + "de_asp.txt"));
            }
        }

        ListView {
            id: validAsTypesListView

            clip: true

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: AsTypeModel{}

            delegate: SwitchDelegate {
                text: model.name

                anchors.left: parent ? parent.left : undefined
                anchors.right: parent ? parent.right : undefined

                checked: Controller.airspaceFilterModel.validTypesContains(model.name)

                onToggled: {
                    Controller.airspaceFilterModel.updateValidTypes(model.name, checked)
                }
            }
        }
    }
}
