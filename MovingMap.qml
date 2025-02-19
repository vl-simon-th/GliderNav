import QtQuick
import QtLocation
import QtPositioning

import GliderNav

Item {
    id: root

    PositionSource {
        id: positionSource
    }

    AirMap {
        id: map

        anchors.fill: parent

        currentTask: Controller.currentTask
    }
}
