import QtQuick
import QtLocation
import QtPositioning

Item {
    id: root

    PositionSource {
        id: positionSource
    }

    Plugin {
        id: osmMapPlugin
        name: "osm"
    }

    AirMap {
        id: map

        anchors.fill: parent
    }
}
