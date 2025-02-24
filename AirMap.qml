import QtQuick
import QtLocation
import QtPositioning

import QtQuick.Controls

import GliderNav

Item {
    id: mapView

    property Task currentTask
    property bool editTask : false

    property alias map: map

    property FlightLog currentFlightLog

    signal airportClicked(var coordinate)

    Plugin {
        id: osmMapPlugin
        name: "osm"
    }

    Map {
        id: map
        anchors.fill: parent
        //center: QtPositioning.coordinate(59.91, 10.75) // Oslo
        zoomLevel: 14
        property geoCoordinate startCentroid

        PinchHandler {
            id: pinch
            target: null
            onActiveChanged: if (active) {
                map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
            }
            onScaleChanged: (delta) => {
                map.zoomLevel += Math.log2(delta)
                map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
            }
            grabPermissions: PointerHandler.CanTakeOverFromAnything
        }
        WheelHandler {
            id: wheel
            // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
            // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
            // and we don't yet distinguish mice and trackpads on Wayland either
            acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                             ? PointerDevice.Mouse | PointerDevice.TouchPad
                             : PointerDevice.Mouse
            rotationScale: 1/120
            property: "zoomLevel"
        }
        DragHandler {
            id: drag
            target: null
            onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
        }
        Shortcut {
            enabled: map.zoomLevel < map.maximumZoomLevel
            sequence: StandardKey.ZoomIn
            onActivated: map.zoomLevel = Math.round(map.zoomLevel + 1)
        }
        Shortcut {
            enabled: map.zoomLevel > map.minimumZoomLevel
            sequence: StandardKey.ZoomOut
            onActivated: map.zoomLevel = Math.round(map.zoomLevel - 1)
        }
    }

    map.plugin: osmMapPlugin
    map.copyrightsVisible: false

    MapPolyline {
        id: flightLogMapPolyline

        path: currentFlightLog ? currentFlightLog.path : []

        line.color: "green"
        line.width: 4

        Component.onCompleted: mapView.map.addMapItem(flightLogMapPolyline)
    }

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
                    origin.x: width/2
                    origin.y: height/2
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
