import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import GliderNav

import QtCore

Item {
    id: root
    required property var safeAreaMargins
    StackView {
        id: stackView

        anchors.fill: parent
        anchors.topMargin: root.safeAreaMargins.top
        anchors.leftMargin: root.safeAreaMargins.left
        anchors.rightMargin: root.safeAreaMargins.right
        anchors.bottomMargin: root.safeAreaMargins.bottom

        topPadding: 100

        clip: true

        initialItem: ListView {
            id: mainListView

            model: ListModel {
                ListElement { name: "Download Airspace and Airport Data"; icon : "icons/cloud-download.svg" }
                ListElement { name: "Airspace and Airport Options"; icon : "icons/clipboard.svg" }
                ListElement { name: "Map Source"; icon : "icons/layout-26.svg" }
            }

            spacing: 6

            delegate: ItemDelegate {
                id: mainItemDelegate

                icon.source: model.icon

                text: model.name
                font.pixelSize: 18
                font.bold: true
                anchors.left: parent.left
                anchors.right: parent.right

                onClicked: {
                    if(model.index === 0) {
                        stackView.pushItem(aptAsDataDownloadViewComponent)
                    } else if (model.index === 1) {
                        stackView.pushItem(aptAsOptionsViewComponent)
                    } else if (model.index === 2) {
                        stackView.pushItem(mapSourceComponent)
                    }
                }
            }
        }

        Component {
            id: aptAsDataDownloadViewComponent
            AptAsDataDownloadView {
                id: aptAsDataDownloadView

                onClose: stackView.pop()
            }
        }

        Component {
            id: aptAsOptionsViewComponent
            AptAsOptionsView {
                id: aptasOptionsView

                onClose: stackView.pop()
            }
        }

        Component {
            id: mapSourceComponent
            Item {
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8

                    Button {
                        id: backButton

                        icon.source: "icons/arrow-left-circle.svg"
                        display: AbstractButton.IconOnly
                        icon.width: 30
                        icon.height: 30

                        Layout.alignment: Qt.AlignLeft

                        onClicked: stackView.pop()
                    }

                    Text {
                        id: mapTypeLabel
                        text: qsTr("Map Source")
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pointSize: 24

                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ComboBox {
                            id: mapSourceCombo
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            model: MapSourceModel
                            textRole: "name"

                            Component.onCompleted: {
                                for(var i = 0; i < MapSourceModel.count; i++) {
                                    if(MapSourceModel.get(i).name === AppSettings.mapSourceName) {
                                        currentIndex = i;
                                        break;
                                    }
                                }
                            }

                            onActivated: {
                                AppSettings.mapSourceName = MapSourceModel.get(currentIndex).name;
                            }
                        }
                    }
                }
            }
        }
    }
}
