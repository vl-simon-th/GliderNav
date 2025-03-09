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
    plugin: osmMapPlugin
    copyrightsVisible: false

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

    MapItemView {
        id: flightLogMapItemView

        model: currentFlightLog && currentFlightLog.path.length > 1 ? currentFlightLog.path.length : []

        add: Transition {}
        remove: Transition {}

        z: 6

        function numberToColor(value) {
            value = Math.max(-5, Math.min(5, value)); // Ensure the value is within the range

            let normalized = (value + 5) / 10.0; // Normalize the value to a range of 0 to 1
            let r, g, b;

            if (value < 0) {
                // Red to Orange
                r = 1.0;
                g = normalized * 2;
                b = 0.0;
            } else {
                // Orange to Green
                r = 2 * (1 - normalized);
                g = 1.0;
                b = 0.0;
            }

            // Convert to 0-255 range
            r = Math.round(r * 255);
            g = Math.round(g * 255);
            b = Math.round(b * 255);

            return Qt.rgba(r / 255, g / 255, b / 255, 1.0);
        }

        delegate: MapPolyline {
            id: flightLogMapPolyline

            property geoCoordinate p1: currentFlightLog.path[model.index]
            property geoCoordinate p2: model.index !== currentFlightLog.path.length-1 ? currentFlightLog.path[model.index +1] : QtPositioning.coordinate()

            path: p2.isValid ? [p1, p2] : []

            line.color: flightLogMapItemView.numberToColor((p2.altitude-p1.altitude)*5/p1.distanceTo(p2))
            line.width: 4
        }

        Component.onCompleted: root.addMapItemView(flightLogMapItemView)
    }

    MapItemGroup {
        id: taskMapItemGroup

        z: 2

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
                property double distance : root.currentTask && root.currentTask.distancesToPoint[index] ? root.currentTask.distancesToPoint[index] : 0

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

        z: 0

        delegate: MapQuickItem {
            id: airportMapQuickItem
            coordinate: model.position

            autoFadeIn: false

            sourceItem: Item {
                Text {
                    id: airportNameText
                    text: model.name
                    font.bold: true
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                    y: -30
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.zoomLevel > 10.35
                }
                AbstractButton {
                    height: root.zoomLevel > 7 ? 40 : 30
                    width: height
                    anchors.centerIn: parent
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

                    rotation: model.rwdir

                    onClicked: {
                        airportClicked(airportMapQuickItem.coordinate)
                    }

                    onDoubleClicked: {
                        airportDoubleClicked(airportMapQuickItem.coordinate)
                    }
                }
            }
        }
    }

    MapItemView {
        id: airspaceDescItemView

        model: ListModel {}

        z: 1

        delegate: MapQuickItem {

            coordinate: model.pos

            sourceItem: Text {
                x: -width/2
                y: model.angle > 90 && model.angle < 270 ? -height : 0
                text: model.text
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
                color: "blue"
                transform: Rotation {
                    origin.x: width/2
                    origin.y: model.angle > 90 && model.angle < 270 ? height : 0
                    angle: model.angle > 90 && model.angle < 270 ? model.angle - 180 : model.angle
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

        z: 0

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

                                        var text = airspacePolyline.type + "\n"

                                        var upperUnit = Controller.unitToString(airspacePolyline.upperAltitudeUnits)
                                        var lowerUnit = Controller.unitToString(airspacePolyline.lowerAltitudeUnits)

                                        if(upperUnit === "FL") text += "FL " + airspacePolyline.upperAltitude + "\n"
                                        else if(upperUnit === "MSL") text += airspacePolyline.upperAltitude + " MSL\n"
                                        else if(upperUnit === "GND" && airspacePolyline.upperAltitude !== 0) text += airspacePolyline.upperAltitude + " GND\n"
                                        else text += "GND\n"

                                        if(lowerUnit === "FL") text += "FL " + airspacePolyline.lowerAltitude + ""
                                        else if(lowerUnit === "MSL") text += airspacePolyline.lowerAltitude + " MSL"
                                        else if(lowerUnit === "GND" && airspacePolyline.lowerAltitude !== 0) text += airspacePolyline.lowerAltitude + " GND"
                                        else text += "GND"

                                        labelModel.push({"pos": pos, "angle": azimuth+90, "text": text})
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

        z: 10
    }

    function fitToTask() {
        fitViewportToMapItems({taskPath})
    }
}
