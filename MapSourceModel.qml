pragma Singleton
import QtQml
import QtQml.Models
import QtQuick

ListModel {
    id: root

    property color defaultAptColor: Qt.color("darkviolet")
    property color defaultAsColor: Qt.color("deepskyblue")

    ListElement {
        name: "OpenStreetMap"
        url: "http://b.tile.openstreetmap.org/"
        attribution: "© OpenStreetMap contributors"
        cache: true
        aptColor: "black"
        asColor: "deepskyblue"
        maxZoomLevel: 16.5
    }
    ListElement {
        name: "OpenTopoMap"
        url: "https://a.tile.opentopomap.org/"
        attribution: "© OpenTopoMap contributors"
        cache: true
        aptColor: "black"
        asColor: "deepskyblue"
        maxZoomLevel: 16.5
    }
    ListElement {
        name: qsTr("None")
        url: ""
        attribution: ""
        cache: false
        aptColor: "lightgreen"
        asColor: "darkblue"
        maxZoomLevel: 16.5
    }

    function resolveName(name) {
        for(var i = 0; i < count; i++) {
            if(get(i).name === name) return get(i)
        }
        return get(0)
    }

    function resolveNameToUrl(name) {
        return resolveName(name).url
    }

    function cache(name) {
        return resolveName(name).cache
    }

    function maxZoomLevel(name) {
        return resolveName(name).maxZoomLevel
    }
}
