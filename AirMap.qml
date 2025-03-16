import QtQuick
import QtCore
import QtLocation
import QtPositioning

import QtQuick.Controls
import QtQuick.Dialogs

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
        PluginParameter { name: "osm.useragent"; value: "GliderNav" }
        PluginParameter { name: "osm.mapping.custom.host"; value: AppSettings.mapSource }
        PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: true }
        PluginParameter { name: "osm.mapping.cache.directory";
            value: (StandardPaths.writableLocation(StandardPaths.writableLocation(StandardPaths.GenericCacheLocation) !== "" ?
                       StandardPaths.GenericCacheLocation : StandardPaths.CacheLocation) + "/QtLocation/" + encodeURIComponent(AppSettings.mapSource)).slice(6)}
    }
    plugin: osmMapPlugin
    activeMapType: supportedMapTypes[supportedMapTypes.length - 1]

    copyrightsVisible: false

    center: QtPositioning.coordinate(48.689878, 9.221964) // Stuttgart
    zoomLevel: 10
    maximumZoomLevel: 14.5
    property geoCoordinate startCentroid

    PinchHandler {
        id: pinch
        target: null
        onActiveChanged: {
            if (active) {
                root.startCentroid = root.toCoordinate(pinch.centroid.position, false)
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
    }
    DragHandler {
        id: drag
        target: null
        onTranslationChanged: (delta) => root.pan(-delta.x, -delta.y)
        grabPermissions: PointerHandler.CanTakeOverFromAnything
    }
    Shortcut {
        enabled: root.zoomLevel < root.maximumZoomLevel
        sequence: StandardKey.ZoomIn
        onActivated: {
            root.zoomLevel = Math.round(root.zoomLevel + 1)
        }
    }
    Shortcut {
        enabled: zoomLevel > minimumZoomLevel
        sequence: StandardKey.ZoomOut
        onActivated: {
            root.zoomLevel = Math.round(root.zoomLevel - 1)
        }
    }

    property list<MapPolyline> logPolylines : []

    function resetLogPolylines() {
        for(var i = 0; i < logPolylines.length; i++) {
            root.removeMapItem(logPolylines[i])
        }
        logPolylines = []
    }

    Component {
        id: logPolylineAddFactory
        MapPolyline {
            id: logPolyline
            required property int pathIndex
            line.width: 3

            Component.onCompleted: {
                logPolyline.path = [currentFlightLog.path[logPolyline.pathIndex], currentFlightLog.path[logPolyline.pathIndex+1]]
                logPolyline.line.color = currentFlightLog.colors[logPolyline.pathIndex]
            }
        }
    }
    function addLatestLogLine() {
        var logPolyline = logPolylineAddFactory.createObject(root, {pathIndex: currentFlightLog.path.length-2})
        logPolylines.push(logPolyline)
        root.addMapItem(logPolyline)
    }

    function loadAllLogPoints() {
        for(var i = 0; i < currentFlightLog.path.length-2; i++) {
            var logPolyline = logPolylineAddFactory.createObject(root, {pathIndex: i})
            logPolylines.push(logPolyline)
            root.addMapItem(logPolyline)
        }
    }

    Connections {
        target: currentFlightLog
        function onPathChanged() {
            if(currentFlightLog.path.length > 1) {
                addLatestLogLine()
            }
        }
    }
    onCurrentFlightLogChanged: {
        resetLogPolylines()
        if(currentFlightLog) {
            loadAllLogPoints()
        }
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

        add: Transition{}
        remove: Transition{}

        z: 1

        delegate: MapQuickItem {

            coordinate: model.pos

            sourceItem: Text {
                x: -width/2
                y: model.angle > 90 && model.angle < 270 ? -height : 0

                text: model.text
                styleColor: "white"
                style: Text.Outline
                font.pixelSize: 16

                horizontalAlignment: Text.AlignHCenter
                color: "blue"

                transform: Rotation {
                    origin.x: width/2
                    origin.y: model.angle > 90 && model.angle < 270 ? height : 0
                    angle: model.angle > 90 && model.angle < 270 ? model.angle - 180 : model.angle
                }
            }
        }
    }

    signal updateAsLabelsSignal()
    function updateAsLabels() {
        airspaceDescItemView.model.clear()
        updateAsLabelsSignal()
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

                                    var pos = root.toCoordinate(p, true);
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
                function onUpdateAsLabelsSignal() {
                    airspacePolyline.updateLabelModel()
                }
            }
        }
    }

    property int lastZoomLevelStep : 0
    onZoomLevelChanged: {
        if(root.zoomLevel > 16) root.zoomLevel = 16

        Controller.airportFilterModel.updateZoomLevel(root.zoomLevel);
        Controller.airspaceFilterModel.updateZoomLevel(root.zoomLevel);

        Controller.airportFilterModel.updateViewArea(root.visibleRegion);
        Controller.airspaceFilterModel.updateViewArea(root.visibleRegion);

        var zoomLevelStep = Math.pow(root.zoomLevel-7, 2) * 0.2
        if(root.lastZoomLevelStep !== Math.round(zoomLevelStep)) {
            root.lastZoomLevelStep = Math.round(zoomLevelStep)
            root.updateAsLabels()
        }
    }

    property geoCoordinate lastCenter : QtPositioning.coordinate(0, 0)
    onCenterChanged: {
        Controller.airportFilterModel.updateViewArea(root.visibleRegion);
        Controller.airspaceFilterModel.updateViewArea(root.visibleRegion);

        var p1 = root.fromCoordinate(lastCenter, false)
        var p2 = root.fromCoordinate(root.center, false)

        var dx = p2.x - p1.x
        var dy = p2.y - p1.y

        var dist = Math.sqrt(dx**2 + dy**2)

        if(dist > 100) {
            root.lastCenter = root.center
            root.updateAsLabels()
        }
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
    property bool posSourceActive : false
    PositionSource {
        id: positionSource
        updateInterval: 3000
        active: root.posSourceActive && permission.status === Qt.Granted

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
