import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

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
                    taskEditView.currentTask = task

                    taskEditView.task.name = task.name
                    taskEditView.originalName = task.name
                    taskEditView.task.taskType = task.taskType
                    taskEditView.task.turnPoints = task.turnPoints
                    taskEditView.task.distancesToPoint = task.distancesToPoint

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

                onClicked: confrimDeleteDialog.open()

                Layout.fillHeight: true
                width: height

                display: AbstractButton.IconOnly
                icon.source: "icons/trash-3.svg"
                icon.height: 25
                icon.width: 25
            }

            MessageDialog {
                id: confrimDeleteDialog

                text: qsTr("Are you sure you want to delete \"" + task.name + "\" ?")
                buttons: MessageDialog.Cancel | MessageDialog.Yes

                onAccepted: Controller.tasksList.removeTask(task)
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
            taskEditView.currentTask = null

            taskEditView.task.name = ""
            taskEditView.originalName = ""
            taskEditView.task.taskType = 1
            taskEditView.task.turnPoints = []
            taskEditView.task.distancesToPoint = []

            taskEditView.visible = true
        }
    }


    TaskEditView {
        id: taskEditView

        anchors.fill: root
        visible: false
        z: 2

        safeAreaMargins: root.safeAreaMargins

        property Task currentTask

        onAccepted: {
            visible = false

            if(currentTask && currentTask.name !== task.name) {
                currentTask.deleteDir() //delete dir with old name and create new instead of overwriting the old one
            }

            if(!currentTask) {
                currentTask = taskFactory.createObject()
            }

            currentTask.name = task.name
            currentTask.taskType = task.taskType
            currentTask.turnPoints = task.turnPoints
            currentTask.distancesToPoint = task.distancesToPoint

            currentTask.writeToDir()
        }

        onRejected: visible = false

        Component {
            id:taskFactory
            Task {
                id: task
                Component.onCompleted: {
                    Controller.tasksList.addTask(task)
                }
            }
        }
    }
}
