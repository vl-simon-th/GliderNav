import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var items: []
    property bool headerChecked: false
    property string headerText: ""

    width: parent.width

    property bool hide: true

    RowLayout {
        Button {
            id: hideButton

            icon.source: hide ? "icons/angle-double-right.svg" : "icons/angle-double-down.svg"

            onClicked: hide = !hide
        }

        CheckBox {
            id: headerCheckBox
            text: headerText
            font.pixelSize: 16

            checked: root.headerChecked
            tristate: true

            onCheckStateChanged: {
                if(checkState !== Qt.PartiallyChecked) {
                    for(var i = 0; i < itemRepeater.count; i++) {
                        itemRepeater.itemAt(i).checked = checked
                    }
                }

                root.headerChecked = checked
            }

            nextCheckState: function() {
                if (checkState === Qt.Checked)
                    return Qt.Unchecked
                else
                    return Qt.Checked
            }
        }
    }

    RowLayout {
        Item {
            id: spacer
            Layout.preferredWidth: 25
        }

        Frame {

            visible: !hide

            ColumnLayout {
                spacing: 5

                Repeater {
                    id: itemRepeater
                    model: root.items

                    delegate: CheckBox {
                        id: delegate
                        text: modelData.text
                        checked: modelData.checked

                        onCheckedChanged: root.items[index].checked = checked

                        Connections {
                            target: root

                            function onReloadCheckedSignal() {
                                delegate.checked = root.items[index].checked
                            }
                        }

                        onClicked: {
                            let allChecked = true
                            let someChecked = false
                            for (let i = 0; i < root.items.length; i++) {
                                if (!root.items[i].checked) {
                                    allChecked = false

                                    if(someChecked) {
                                        break;
                                    }
                                } else {
                                    someChecked = true

                                    if(!allChecked) {
                                        break;
                                    }
                                }
                            }
                            headerCheckBox.checkState = allChecked ? Qt.Checked : someChecked ? Qt.PartiallyChecked : Qt.Unchecked
                        }
                    }
                }
            }
        }
    }

    signal reloadCheckedSignal

    function reloadChecked() {
        reloadCheckedSignal()

        let allChecked = true
        let someChecked = false
        for (let i = 0; i < root.items.length; i++) {
            if (!root.items[i].checked) {
                allChecked = false

                if(someChecked) {
                    break;
                }
            } else {
                someChecked = true

                if(!allChecked) {
                    break;
                }
            }
        }
        headerCheckBox.checkState = allChecked ? Qt.Checked : someChecked ? Qt.PartiallyChecked : Qt.Unchecked
    }
}
