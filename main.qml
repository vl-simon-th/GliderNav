import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

import GliderNav

Window {
    id: root
    width: 390
    height: 844
    visible: true
    title: qsTr("Glider Nav")

    flags: Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 0

        SwipeView {
            id: swipeView

            Layout.fillHeight: true
            Layout.fillWidth: true

            interactive: false

            currentIndex: 1

            TasksView {
                id: tasksView
                safeAreaMargins: root.SafeArea.margins
                onToMovingMap: swipeView.setCurrentIndex(1)
            }

            MovingMap {
                id: movingMap
                safeAreaMargins: root.SafeArea.margins
            }

            LogsView {
                id: logsView
                safeAreaMargins: root.SafeArea.margins
            }

            SettingsView {
                id: settingsView
                safeAreaMargins: root.SafeArea.margins
            }
        }

        Component.onCompleted: {
            for(var i = 0; i < AppSettings.validAsTypes.length; i++) {
                Controller.airspaceFilterModel.updateValidTypes(AppSettings.validAsTypes[i], true)
            }
            for(i = 0; i < AppSettings.validAptStyles.length; i++) {
                Controller.airportFilterModel.updateValidStyle(AppSettings.validAptStyles[i], true)
            }

            root.setW
        }

        TabBar {
            id: tabBar

            property var safeArea: root.SafeArea

            currentIndex: swipeView.currentIndex

            Layout.fillWidth: true
            Layout.preferredHeight: root.hideTabBar ? 0 : 40 + root.SafeArea.margins.bottom
            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: 300 // Animation duration in milliseconds
                    easing.type: Easing.InOutQuad // Easing curve for smooth animation
                }
            }

            position: TabBar.Footer

            Component.onCompleted: {
                if(Qt.platform.os === "osx") {
                    background = osxBackground
                }
            }

            Rectangle {
                id: osxBackground
                color: "lightgrey"
            }

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

    property bool hideTabBar : false

    ToolButton {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: tabBar.height

        icon.source: !hideTabBar ? "icons/arrow-downward.svg" : "icons/arrow-upward.svg"
        icon.width: 30
        icon.height: 30

        visible: swipeView.currentIndex === 1

        width: 40
        height: 40

        z: 10

        onClicked: hideTabBar = !hideTabBar
    }
}
