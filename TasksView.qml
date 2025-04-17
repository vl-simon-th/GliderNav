import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GliderNav

ListView {
    id: root
    signal toMovingMap()

    required property var safeAreaMargins

    spacing: 6

    model: Controller.tasksList.tasks

    header: Item {
        height: root.safeAreaMargins.top
    }

    delegate: Rectangle {
        id: delegate

        property Task task: modelData

        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: root.safeAreaMargins.left
        anchors.rightMargin: root.safeAreaMargins.right

        height: rowLayout.implicitHeight

        RowLayout {
            id: rowLayout

            anchors.fill: parent

            Text {
                id: nameText
                text: task.name
                font.pointSize: 16

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            ToolButton {
                id: loadButton

                onClicked: {
                    Controller.currentTask = task
                    root.toMovingMap()
                }

                Layout.fillHeight: true
                width: height

                display: AbstractButton.IconOnly
                icon.source: "icons/share-2.svg"
                icon.height: 25
                icon.width: 25
            }

            ToolButton {
                id: editButton

                onClicked: {
                    taskEditView.task = task
                    taskEditView.visible = true
                }

                Layout.fillHeight: true
                width: height

                display: AbstractButton.IconOnly
                icon.source: "icons/pencil-1.svg"
                icon.height: 25
                icon.width: 25
            }

            ToolButton {
                id: deleteButton

                onClicked: Controller.tasksList.removeTask(task)

                Layout.fillHeight: true
                width: height

                display: AbstractButton.IconOnly
                icon.source: "icons/trash-3.svg"
                icon.height: 25
                icon.width: 25
            }
        }
    }

    Button {
        id: addButton
        text: qsTr("Add")

        display: AbstractButton.IconOnly
        icon.source: "icons/plus.svg"
        icon.height: 30
        icon.width: 30

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 8
        anchors.rightMargin: root.safeAreaMargins.right + 8

        onClicked: {
            taskEditView.visible = true
            taskEditView.task = taskFactory.createObject()
        }

        Component {
            id:taskFactory
            Task {
                id: task
                Component.onCompleted: {
                    taskType = 1
                    Controller.tasksList.addTask(task)
                }
            }
        }
    }


    TaskEditView {
        id: taskEditView

        anchors.fill: root
        visible: false
        z: 2

        safeAreaMargins: root.safeAreaMargins

        onClose: visible = false
    }
}
