import QtQuick
import QtLocation
import QtPositioning

import QtQuick.Controls
import QtQuick.Dialogs
import QtCore

import GliderNav

Map {
    id: root

    property Task currentTask

    property FlightLog currentFlightLog

    signal airportClicked(var coordinate)
    signal airportDoubleClicked(var coordinate)

    Plugin {
        id: osmMapPlugin
        name: "osm"
    }

    //center: QtPositioning.coordinate(59.91, 10.75) // Oslo
    center: QtPositioning.coordinate(48.689878, 9.221964) // Stuttgart
    zoomLevel: 14
    property geoCoordinate startCentroid

    PinchHandler {
        id: pinch
        target: null
        onActiveChanged: if (active) {
            root.startCentroid = root.toCoordinate(pinch.centroid.position, false)
        }
        onScaleChanged: (delta) => {
            root.zoomLevel += Math.log2(delta)
            root.alignCoordinateToPoint(root.startCentroid, pinch.centroid.position)
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
        onTranslationChanged: (delta) => root.pan(-delta.x, -delta.y)
    }
    Shortcut {
        enabled: root.zoomLevel < root.maximumZoomLevel
        sequence: StandardKey.ZoomIn
        onActivated: root.zoomLevel = Math.round(root.zoomLevel + 1)
    }
    Shortcut {
        enabled: zoomLevel > minimumZoomLevel
        sequence: StandardKey.ZoomOut
        onActivated: root.zoomLevel = Math.round(root.zoomLevel - 1)
    }

    plugin: osmMapPlugin
    copyrightsVisible: false

    MapPolyline {
        id: flightLogMapPolyline

        path: currentFlightLog ? currentFlightLog.path : []

        line.color: "green"
        line.width: 4
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
                property double distance : root.currentTask ? root.currentTask.distancesToPoint[index] : 0

                radius: distance
                color: "transparent"

                border.color: "red"
                border.width: 2
            }
        }
    }

    MapItemView {
        id: airportMapItemView
        model: Controller.airportFilterModel

        delegate: MapQuickItem {
            id: airportMapQuickItem
            coordinate: model.position

            autoFadeIn: false

            sourceItem: AbstractButton {
                x: height / -2
                y: height / -2
                height: root.zoomLevel > 7 ? 40 : 30
                width: height
                Rectangle {
                    anchors.centerIn: parent
                    height: parent.height / 2
                    width: height
                    color: "transparent"
                    border.color: "black"
                    border.width: root.zoomLevel > 7 ? 4 : 2

                    radius: height/2
                }

                Rectangle {
                    anchors.centerIn: parent
                    height: parent.height
                    width: parent.width / 4.5
                    color: "transparent"
                    border.color: "black"
                    border.width: root.zoomLevel > 7 ? 3 : 1.5
                }

                transform: Rotation {
                    origin.x: width/2
                    origin.y: height/2
                    angle: model.rwdir
                }

                onClicked: {
                    airportClicked(airportMapQuickItem.coordinate)
                }

                onDoubleClicked: {
                    airportDoubleClicked(airportMapQuickItem.coordinate)
                }
            }
        }
    }


    MapItemView {
        id: airspacesItemView

        model: Controller.airspaceFilterModel

        delegate: MapPolyline {
            id: airspacePolyline
            line.color: "blue"
            line.width: 1.5

            path: model.coordinates

            MapItemView {
                id: airspaceDescItemView

                model: ListModel {}

                Component.onCompleted: {
                    var labelDist = 25000

                    var dist = 0
                    var c = 0

                    var labelModel = []
                    for(var i = 0; i < airspacePolyline.path.length - 1; i++) {
                        dist += airspacePolyline.path[i].distanceTo(airspacePolyline.path[i+1])

                        if(dist > c) {
                            var next = 1;
                            while (i+next < airspacePolyline.path.length-1 &&
                                   airspacePolyline.path[i].distanceTo(airspacePolyline.path[i+next]) < 1000) next++;

                            var azimuth = airspacePolyline.path[i].azimuthTo(airspacePolyline.path[i+next]);
                            var distToNext = airspacePolyline.path[i].distanceTo(airspacePolyline.path[i+next]);

                            airspaceDescItemView.model.append({"coordinate": airspacePolyline.path[i].atDistanceAndAzimuth(distToNext/2, azimuth),
                                                                  "angle": azimuth + 90})
                            c = dist + labelDist
                        }
                    }

                    root.addMapItemView(airspaceDescItemView)
                }

                delegate: MapQuickItem {
                    coordinate: model.coordinate
                    sourceItem: Label {
                        x: width/-2
                        y: height/-2
                        text: "Description"
                        color: "blue"
                        transform: Rotation {
                            origin.x: width/2
                            origin.y: height/2
                            //angle: model.angle
                        }

                        visible: root.zoomLevel > 10
                    }
                }
            }
        }
    }

    onZoomLevelChanged: {
        Controller.airportFilterModel.updateZoomLevel(root.zoomLevel);
        Controller.airspaceFilterModel.updateZoomLevel(root.zoomLevel);

        Controller.airportFilterModel.updateViewArea(root.visibleRegion);
        Controller.airspaceFilterModel.updateViewArea(root.visibleRegion);
    }

    onCenterChanged: {
        Controller.airportFilterModel.updateViewArea(root.visibleRegion);
        Controller.airspaceFilterModel.updateViewArea(root.visibleRegion);
    }

    Component.onCompleted: {
        Controller.airportFilterModel.updateZoomLevel(root.zoomLevel);
        Controller.airspaceFilterModel.updateZoomLevel(root.zoomLevel);

        Controller.airportFilterModel.updateViewArea(root.visibleRegion);
        Controller.airspaceFilterModel.updateViewArea(root.visibleRegion);
    }

    LocationPermission {
        id: permission
        accuracy: LocationPermission.Precise
        availability: LocationPermission.WhenInUse

        Component.onCompleted: {
            if(permission.status !== Qt.Granted) {
                permission.request()
            }
        }
    }

    signal positionChanged(var pos)
    PositionSource {
        id: positionSource
        updateInterval: 3000
        active: permission.status === Qt.Granted

        onPositionChanged: {
            root.positionChanged(positionSource.position)
        }
    }

    Button {
        id: centerButton

        text: qsTr("Center")

        display: AbstractButton.IconOnly
        icon.source: "icons/location-arrow-right.svg"
        icon.height: 30
        icon.width: 30

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 8

        onClicked: {
            root.center = positionSource.position.coordinate
        }
    }

    function fitToTask() {
        fitViewportToMapItems({taskPath})
    }
}
