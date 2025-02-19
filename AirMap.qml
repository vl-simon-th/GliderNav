import QtQuick
import QtLocation
import QtPositioning

import QtQuick.Controls

import GliderNav

MapView {
    id: mapView

    property Task currentTask
    property bool editTask : false

    signal airportClicked(var coordinate)

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

            line.color: "yellow"
            line.width: 4
        }

        MapItemView {
            model: currentTask && currentTask.taskType === 0 ? currentTask.turnPoints : []

            delegate: MapCircle {
                center: modelData
                property double distance : currentTask.distancesToPoint[index] ? currentTask.distancesToPoint[index] : 0

                radius: distance ? distance : 0
                color: "transparent"

                border.color: "red"
                border.width: 2
            }
        }

        Component.onCompleted: mapView.map.addMapItemGroup(taskMapItemGroup)
    }

    MapItemView {
        id: airportMapItemView
        model: Controller.airportFilterModel

        delegate: MapQuickItem {
            id: airportMapQuickItem
            coordinate: model.position

            autoFadeIn: false

            sourceItem: AbstractButton {
                enabled: mapView.editTask
                x: height / -2
                y: height / -2
                height: mapView.map.zoomLevel > 7 ? 40 : 30
                width: height
                Rectangle {
                    anchors.centerIn: parent
                    height: parent.height / 2
                    width: height
                    color: "transparent"
                    border.color: "black"
                    border.width: mapView.map.zoomLevel > 7 ? 4 : 2

                    radius: height/2
                }

                Rectangle {
                    anchors.centerIn: parent
                    height: parent.height
                    width: parent.width / 4.5
                    color: "transparent"
                    border.color: "black"
                    border.width: mapView.map.zoomLevel > 7 ? 3 : 1.5
                }

                transform: Rotation {
                    origin.x: 20
                    origin.y: 20
                    angle: model.rwdir
                }

                onClicked: {
                    airportClicked(airportMapQuickItem.coordinate)
                }
            }
        }

        Component.onCompleted: mapView.map.addMapItemView(airportMapItemView)
    }


    MapItemView {
        id: airspaceMapItemView
        model: Controller.airspaceFilterModel

        delegate: MapPolyline {
            path: model.coordinates
            line.width: 1.5
            line.color: model.type === "C" || model.type === "D" ? "red" : "blue"
        }

        Component.onCompleted: mapView.map.addMapItemView(airspaceMapItemView)
    }

    map.onZoomLevelChanged: {
        Controller.airportFilterModel.updateZoomLevel(map.zoomLevel);
        Controller.airspaceFilterModel.updateZoomLevel(map.zoomLevel);

        Controller.airportFilterModel.updateViewArea(map.visibleRegion);
        Controller.airspaceFilterModel.updateViewArea(map.visibleRegion);
    }

    map.onCenterChanged: {
        Controller.airportFilterModel.updateViewArea(map.visibleRegion);
        Controller.airspaceFilterModel.updateViewArea(map.visibleRegion);
    }

    Component.onCompleted: {
        Controller.airportFilterModel.updateZoomLevel(map.zoomLevel);
        Controller.airspaceFilterModel.updateZoomLevel(map.zoomLevel);

        Controller.airportFilterModel.updateViewArea(map.visibleRegion);
        Controller.airspaceFilterModel.updateViewArea(map.visibleRegion);
    }
}
