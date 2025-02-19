import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 320
    height: 540
    visible: true
    title: qsTr("Glider Nav")

    SwipeView {
        id: swipeView
        anchors.fill: parent

        //enabled: false

        TasksView {
            id: tasksView
            onToMovingMap: swipeView.setCurrentIndex(1)
        }

        MovingMap {
            id: movingMap

            visible: swipeView.currentIndex === 1
        }

        LogsView {
            id: logsView
        }

        SettingsView {
            id: settingsView
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            id: tasksButton

            text: qsTr("Tasks")
            onClicked: swipeView.setCurrentIndex(0)

            display: AbstractButton.IconOnly
            icon.source: "icons/stopwatch.svg"
            icon.width: 30
            icon.height: 30
        }

        TabButton {
            id: mapButton

            text: qsTr("Map")
            onClicked: swipeView.setCurrentIndex(1)

            display: AbstractButton.IconOnly
            icon.source: "icons/map-marker-1.svg"
            icon.width: 30
            icon.height: 30
        }
        TabButton {
            id: logsButton

            text: qsTr("Logs")
            onClicked: swipeView.setCurrentIndex(2)

            display: AbstractButton.IconOnly
            icon.source: "icons/route-1.svg"
            icon.width: 30
            icon.height: 30
        }
        TabButton {
            id: settingsButton

            text: qsTr("Settings")
            onClicked: swipeView.setCurrentIndex(3)

            display: AbstractButton.IconOnly
            icon.source: "icons/gear-1.svg"
            icon.width: 30
            icon.height: 30
        }
    }
}
