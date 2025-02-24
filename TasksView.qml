import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import GliderNav

ListView {
    id: root
    signal toMovingMap()

    spacing: 6

    model: Controller.tasksList.tasks

    delegate: Rectangle {
        id: delegate

        property Task task: modelData

        anchors.left: parent.left
        anchors.right: parent.right

        height: rowLayout.implicitHeight

        RowLayout {
            id: rowLayout

            anchors.fill: parent

            spacing: 8

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

                display: AbstractButton.IconOnly
                icon.source: "icons/share-2.svg"
                icon.height: 25
                icon.width: 25
            }

            ToolButton {
                id: editButton

                onClicked: {
                    taskEditViewLoader.sourceComponent = taskEditViewComponent
                    taskEditViewLoader.item.task = task
                }

                display: AbstractButton.IconOnly
                icon.source: "icons/pencil-1.svg"
                icon.height: 25
                icon.width: 25
            }

            ToolButton {
                id: deleteButton

                onClicked: Controller.tasksList.removeTask(task)

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
        anchors.margins: 8

        onClicked: {
            taskEditViewLoader.sourceComponent = taskEditViewComponent
            taskEditViewLoader.item.task = taskFactory.createObject()
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

    Loader {
        id: taskEditViewLoader
        anchors.fill: parent
        z: 2

        sourceComponent: undefined
    }

    Component {
        id: taskEditViewComponent
        TaskEditView {
            id: taskEditView

            anchors.fill: root

            onClose: taskEditViewLoader.sourceComponent = undefined
        }
    }
}
