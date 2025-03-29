import QtQuick
import QtQuick.Window
import QtQuick.Controls

ApplicationWindow {
    width: 390
    height: 844
    visible: true
    title: qsTr("Glider Nav")

    flags: Qt.Window | Qt.MaximizeUsingFullscreenGeometryHint

    SwipeView {
        id: swipeView
        width: parent.width
        height: parent.height

        interactive: false

        currentIndex: 1

        TasksView {
            id: tasksView
            onToMovingMap: swipeView.setCurrentIndex(1)
        }

        MovingMap {
            id: movingMap
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
