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

    signal updateAsLabels()

    Plugin {
        id: osmMapPlugin
        name: "osm"
    }

    //center: QtPositioning.coordinate(59.91, 10.75) // Oslo
    center: QtPositioning.coordinate(48.689878, 9.221964) // Stuttgart
    zoomLevel: 14
    activeMapType: supportedMapTypes[AppSettings.mapTypeIndex]
    property geoCoordinate startCentroid

    PinchHandler {
        id: pinch
        target: null
        onActiveChanged: {
            if (active) {
                root.startCentroid = root.toCoordinate(pinch.centroid.position, false)
            } else {
                airspaceDescItemView.model.clear()
                root.updateAsLabels()
            }
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
        onActiveChanged: {
            if(!active) {
                airspaceDescItemView.model.clear()
                root.updateAsLabels()
            }
        }
    }
    DragHandler {
        id: drag
        target: null
        onTranslationChanged: (delta) => root.pan(-delta.x, -delta.y)
        onActiveChanged: {
            if(!active) {
                airspaceDescItemView.model.clear()
                root.updateAsLabels()
            }
        }
    }
    Shortcut {
        enabled: root.zoomLevel < root.maximumZoomLevel
        sequence: StandardKey.ZoomIn
        onActivated: {
            root.zoomLevel = Math.round(root.zoomLevel + 1)
            airspaceDescItemView.model.clear()
            root.updateAsLabels()
        }
    }
    Shortcut {
        enabled: zoomLevel > minimumZoomLevel
        sequence: StandardKey.ZoomOut
        onActivated: {
            root.zoomLevel = Math.round(root.zoomLevel - 1)
            airspaceDescItemView.model.clear()
            root.updateAsLabels()
        }
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
        id: airspaceDescItemView

        model: ListModel {}

        delegate: MapQuickItem {

            coordinate: model.pos

            sourceItem: Text {
                x: -width/2
                y: 0
                text: model.text
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
                color: "blue"
                transform: Rotation {
                    origin.x: width/2
                    origin.y: 0
                    angle: model.angle
                }

                Rectangle {
                    anchors.fill: parent
                    z: -3
                    color: "orange"
                    opacity: 0.7
                }
            }
        }
    }

    MapItemView {
        id: airspacesItemView

        model: Controller.airspaceFilterModel

        delegate: MapPolyline {
            id: airspacePolyline

            required property double lowerAltitude
            required property double upperAltitude
            required property int lowerAltitudeUnits
            required property int upperAltitudeUnits
            required property list<geoCoordinate> coordinates
            required property string type

            line.color: "blue"
            line.width: 1.5

            path: coordinates

            function updateLabelModel() {
                var labelModel = []

                if(root.zoomLevel > 10) {
                    var labelPixelDist = 400

                    var dist = 0;
                    var next = labelPixelDist;

                    var boundingRect = root.visibleRegion.boundingGeoRectangle()
                    for(var i = 0; i < airspacePolyline.path.length-1; i++) {
                        var p1 = root.fromCoordinate(airspacePolyline.path[i], false)
                        var p2 = root.fromCoordinate(airspacePolyline.path[i+1], false)

                        var dx = p2.x - p1.x
                        var dy = p2.y - p1.y

                        dist += Math.sqrt(dx**2 + dy**2)

                        if(dist > next) {
                            var occurrences = Math.ceil((dist-next)/labelPixelDist)

                            if(boundingRect.intersects(QtPositioning.rectangle([airspacePolyline.path[i], airspacePolyline.path[i+1]]))) {
                                for(var j = 1; j < occurrences+1; j++) {
                                    var p = Qt.point(p1.x + dx*j/(occurrences+1), p1.y + dy*j/(occurrences+1))

                                    var pos = root.toCoordinate(p, false);
                                    if(pos.isValid) {
                                        var azimuth = airspacePolyline.path[i].azimuthTo(airspacePolyline.path[i+1]);

                                        labelModel.push({"pos": pos, "angle": azimuth + 90,
                                                "text": airspacePolyline.upperAltitude + " " + Controller.unitToString(airspacePolyline.upperAltitudeUnits) + "\n" +
                                                airspacePolyline.lowerAltitude + " " + Controller.unitToString(airspacePolyline.lowerAltitudeUnits) + "\n" +
                                                airspacePolyline.type})
                                    }
                                }
                            }

                            next += labelPixelDist * occurrences
                        }
                    }
                }

                for(var k = 0; k < labelModel.length; k++) {
                    airspaceDescItemView.model.append(labelModel[k]);
                }
            }

            Component.onCompleted: updateLabelModel()

            Connections {
                target: root
                function onUpdateAsLabels() {
                    airspacePolyline.updateLabelModel()
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
