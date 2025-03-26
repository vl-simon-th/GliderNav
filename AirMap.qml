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

    //Maps
    Loader {
        id: mapLoader
        anchors.fill: parent

        z: root.z-1

        sourceComponent: Map {
            id: backgroundMap

            center: root.center
            minimumFieldOfView: root.minimumFieldOfView
            maximumFieldOfView: root.maximumFieldOfView
            minimumTilt: root.minimumTilt
            maximumTilt: root.maximumTilt
            minimumZoomLevel: root.minimumZoomLevel
            maximumZoomLevel: root.maximumZoomLevel
            zoomLevel: Math.min(root.zoomLevel, maximumZoomLevel)
            tilt: root.tilt;
            bearing: root.bearing
            fieldOfView: root.fieldOfView
            z: root.z - 1
            color: AppSettings.mapSourceName.startsWith("SoaringWeatherEurope") ? "transparent" : "darkgrey"

            activeMapType: supportedMapTypes[supportedMapTypes.length-1]

            Plugin {
                id: osmMapPlugin
                name: "osm"

                PluginParameter { name: "osm.mapping.custom.host"; value: MapSourceModel.resolveNameToUrl(AppSettings.mapSourceName)}
                PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: true }

                PluginParameter { name: "osm.mapping.cache.directory";
                    value: (StandardPaths.writableLocation(StandardPaths.writableLocation(StandardPaths.GenericCacheLocation) !== "" ?
                               StandardPaths.GenericCacheLocation : StandardPaths.CacheLocation) + "/QtLocation/" + AppSettings.mapSourceName).slice(6)}
                PluginParameter { name: "osm.mapping.cache.disk.cost_strategy"; value: "unitary"}
                PluginParameter { name: "osm.mapping.cache.disk.size"; value: MapSourceModel.cache(AppSettings.mapSourceName) ? 1000 : 0}
            }

            plugin: osmMapPlugin

            Loader {
                id: backgroundMapLoader

                anchors.fill: parent
                active: AppSettings.mapSourceName.startsWith("SoaringWeatherEurope")

                z: backgroundMap.z-1

                sourceComponent: Map {
                    center: root.center
                    minimumFieldOfView: root.minimumFieldOfView
                    maximumFieldOfView: root.maximumFieldOfView
                    minimumTilt: root.minimumTilt
                    maximumTilt: root.maximumTilt
                    minimumZoomLevel: root.minimumZoomLevel
                    maximumZoomLevel: root.maximumZoomLevel
                    zoomLevel: root.zoomLevel
                    tilt: root.tilt;
                    bearing: root.bearing
                    fieldOfView: root.fieldOfView
                    z: backgroundMap.z - 1

                    activeMapType: supportedMapTypes[supportedMapTypes.length-1]

                    plugin: Plugin {
                        name: "osm"

                        PluginParameter { name: "osm.mapping.custom.host"; value: MapSourceModel.resolveNameToUrl("WeGlideMap")}
                        PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: true }

                        PluginParameter { name: "osm.mapping.cache.directory";
                            value: (StandardPaths.writableLocation(StandardPaths.writableLocation(StandardPaths.GenericCacheLocation) !== "" ?
                                       StandardPaths.GenericCacheLocation : StandardPaths.CacheLocation) + "/QtLocation/WeGlideMap").slice(6)}
                    }
                }
            }
        }
    }

    Connections {
        target: AppSettings
        function onMapSourceNameChanged() {
            mapLoader.active = false
            mapLoader.active = true
        }

        function satelliteUpdate() {
            mapLoader.active = false
            mapLoader.active = true
            console.log("Satellite Update")
        }
    }

    //Items
    Plugin {
        id: overlayPlugin
        name: "itemsoverlay"
    }
    plugin: overlayPlugin

    copyrightsVisible: false

    center: QtPositioning.coordinate(48.689878, 9.221964) // Stuttgart
    zoomLevel: 10
    maximumZoomLevel: MapSourceModel.maxZoomLevel(AppSettings.mapSourceName)
    color: 'transparent'
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

    FlightLogModel {
        id: currentLogModel
        log: currentFlightLog

        onLogChanged: {
            logMapItemView.model = null
            logMapItemView.model = currentLogModel
        }

        onVisiblePathChanged: {
            logMapItemView.model = null
            logMapItemView.model = currentLogModel
        }
    }

    MapItemView {
        id: logMapItemView

        model: currentLogModel

        add: Transition {}
        remove: Transition {}

        delegate: MapPolyline {
            path: [model.point, model.nextPoint]

            line.color: model.color
            line.width: 3
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

        property color sectorColor: "orange"

        MapItemView {
            model: currentTask ? currentTask.turnPoints.slice(1, -1) : []

            add: Transition {}
            remove: Transition {}

            delegate: MapQuickItem {
                id: sector
                coordinate: modelData

                sourceItem: SectorItem {
                    x: -width/2
                    y: -height/2

                    coordinates: currentTask.turnPoints[index] && currentTask.turnPoints[index+1] && currentTask.turnPoints[index + 2] ?
                                     [currentTask.turnPoints[index], currentTask.turnPoints[index+1], currentTask.turnPoints[index + 2]] :
                                     [QtPositioning.coordinate(0,0), QtPositioning.coordinate(0,0), QtPositioning.coordinate(0,0)]

                    color: taskMapItemGroup.sectorColor
                    borderWidth: 3

                    height: width
                    width: 75
                }
            }
        }

        MapQuickItem {
            id: startLine

            coordinate: currentTask && currentTask.turnPoints[0] ? currentTask.turnPoints[0] : QtPositioning.coordinate()

            sourceItem: Item {

                x: -width/2
                y: -height/2

                width: 50
                height: 3

                Rectangle {

                    anchors.fill: parent

                    color: taskMapItemGroup.sectorColor

                    rotation: currentTask && currentTask.turnPoints[0] && currentTask.turnPoints[1] ?
                                  currentTask.turnPoints[0].azimuthTo(currentTask.turnPoints[1]) : 10
                }
            }
        }

        MapCircle {
            center: currentTask && currentTask.turnPoints[0] ? currentTask.turnPoints[0] : QtPositioning.coordinate()

            radius: 1000
            color: "transparent"

            border.color: taskMapItemGroup.sectorColor
            border.width: 2
        }

        MapCircle {
            center: currentTask && currentTask.turnPoints.length > 1 ? currentTask.turnPoints[currentTask.turnPoints.length-1] : QtPositioning.coordinate()

            radius: 1000
            color: "transparent"

            border.color: taskMapItemGroup.sectorColor
            border.width: 2
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

                    color: MapSourceModel.resolveName(AppSettings.mapSourceName).aptColor
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
                        border.color: MapSourceModel.resolveName(AppSettings.mapSourceName).aptColor
                        border.width: root.zoomLevel > 7 ? 4 : 2

                        radius: height/2
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        height: parent.height
                        width: parent.width / 4.5
                        color: "transparent"
                        border.color: MapSourceModel.resolveName(AppSettings.mapSourceName).aptColor
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
                color: MapSourceModel.resolveName(AppSettings.mapSourceName).asColor

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

            line.color: MapSourceModel.resolveName(AppSettings.mapSourceName).asColor
            line.width: 2

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

        Controller.airportFilterModel.updateZoomLevel(root.zoomLevel);
        Controller.airspaceFilterModel.updateZoomLevel(root.zoomLevel);

        Controller.airportFilterModel.updateViewArea(root.visibleRegion);
        Controller.airspaceFilterModel.updateViewArea(root.visibleRegion);

        currentLogModel.updateViewArea(root.visibleRegion);

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

        currentLogModel.updateViewArea(root.visibleRegion);

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
