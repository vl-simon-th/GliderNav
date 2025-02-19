import QtQuick
import QtLocation
import QtPositioning

import QtQuick.Controls

import GliderNav

MapView {
    id: mapView

    property Task currentTask

    Plugin {
        id: osmMapPlugin
        name: "osm"
    }

    map.plugin: osmMapPlugin

    MapItemGroup {
        id: taskMapItemGroup

        MapPolyline {
            id: taskPath

            path: currentTask ? currentTask.turnPoints : []

            line.color: "green"
            line.width: 2
        }

        MapItemView {
            model: currentTask ? currentTask.turnPoints : []

            delegate: MapCircle {
                property double distance : currentTask.distancesToPoint[index] ? currentTask.distancesToPoint[index] : 0
                center: modelData
                border.color: "pink"
                border.width: 2

                color: "pink"
                opacity: 50

                /*
                MouseArea {
                    anchors.fill: parent
                    onClicked: {console.log("clicked")}
                    Rectangle {
                        anchors.fill: parent
                        color: "red"
                    }
                }*/

                Component.onCompleted: radius = distance
            }
        }

        Component.onCompleted: mapView.map.addMapItemGroup(taskMapItemGroup)
    }

    MapItemView {
        id: airportMapItemView
        model: Controller.airportModel

        delegate: MapCircle {
            id: airportCircle
            center: model.position
            radius: 1000
            color: "blue"
        }

        Component.onCompleted: mapView.map.addMapItemView(airportMapItemView)
    }


    MapItemView {
        id: airspaceMapItemView
        model: Controller.airspaceModel

        delegate: MapPolyline {
            path: model.coordinates
            line.width: 1.5
            line.color: model.type === "C" || model.type === "D" ? "red" : "blue"
        }
    }

    property bool aptAsLoaded : true
    map.onZoomLevelChanged: {
        if (zoomLevel > 7 && !aptAsLoaded) {
            map.addMapItemView(airportMapItemView)
            map.addMapItemView(airspaceMapItemView)
            aptAsLoaded = true
        } else if (zoomLevel <= 7 && aptAsLoaded) {
            map.removeMapItemView(airportMapItemView)
            map.removeMapItemView(airspaceMapItemView)
            aptAsLoaded = false
        }
    }
}
