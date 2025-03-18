pragma Singleton
import QtQml
import QtQml.Models
import QtQuick

Item {
    id: root

    property ListModel model: listModel

    ListModel {
        id: listModel
    }

    function getCurrentDateTime() {
        var date = new Date(); // Get the current date and time
        var year = date.getUTCFullYear();
        var month = ("0" + (date.getUTCMonth() + 1)).slice(-2);
        var day = ("0" + date.getUTCDate()).slice(-2);
        var hour = ("0" + date.getUTCHours()).slice(-2);
        var minute = ("0" + date.getUTCMinutes()).slice(-2);

        return year + "/" + month + "/" + day + "/" + hour + minute;
    }

    property color defaultAptColor: Qt.color("black")
    property color defaultAsColor: Qt.color("blue")

    property var data : [{
        "name": "OpenStreetMap",
        "url": "http://b.tile.openstreetmap.org/",
        "attribution": "© OpenStreetMap contributors",
        "cache": true,
        "aptColor": root.defaultAptColor,
        "asColor": root.defaultAsColor,
    },
    {
        "name": "OpenTopoMap",
        "url": "https://a.tile.opentopomap.org/",
        "attribution": "© OpenTopoMap contributors",
        "cache": true,
        "aptColor": root.defaultAptColor,
        "asColor": root.defaultAsColor,
    },
    {
        "name": "WeGlideMap",
        "url": "https://dmt-wgld.b-cdn.net/dmt_hypsometric/dmt_hypsometric/",
        "attribution": "WeGlide",
        "cache": true,
        "aptColor": root.defaultAptColor,
        "asColor": root.defaultAsColor,
    },
    {
        "name": "SkySightSatellite",
        "url": "https://satellite.skysight.io/tiles/%z/%x/%y?date="+ root.getCurrentDateTime() +"&mtg=true.png",
        "attribution": "SkySight",
        "cache": false,
        "aptColor": root.defaultAptColor,
        "asColor": root.defaultAsColor,
    },
    {
        "name": "SoaringWeatherEurope",
        "url": "https://rasp.skyltdirect.se/scandinavia/dtiles/curr+0/%z/%x/%y.dist.1400.png",
        "attribution": "SoaringWeatherEurope",
        "cache": false,
        "aptColor": Qt.color("orange"),
        "asColor": root.defaultAsColor,
    }
    ]

    Component.onCompleted: {
        for(var i = 0; i < data.length; i++) {
            model.append(root.data[i])
        }
    }

    signal satelliteUpdate()
    /*
    Timer {
        interval: 5 * 60 * 1000
        repeat: true

        running: AppSettings.mapSourceName === "SkySightSatellite"
        triggeredOnStart: true

        onTriggered: {
            for(var i = 0; i < data.length; i++) {
                if(data[i].name === "SkySightSatellite") {
                    data[i].url = "https://satellite.skysight.io/tiles/%z/%x/%y?date="+ root.getCurrentDateTime() +"&mtg=true.png"
                    model.clear()
                    for(var j = 0; j < data.length; j++) {
                        model.append(root.data[j])
                    }
                    break
                }
                root.satelliteUpdate()
            }
        }
    }*/

    function resolveName(name) {
        for(var i = 0; i < data.length; i++) {
            if(data[i].name === name) return data[i]
        }
        return 0
    }

    function resolveNameToUrl(name) {
        return resolveName(name).url
    }

    function cache(name) {
        return resolveName(name).cache
    }
}
