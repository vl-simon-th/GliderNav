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
        maxZoomLevel: 15.5
    }
    ListElement {
        name: "OpenTopoMap"
        url: "https://a.tile.opentopomap.org/"
        attribution: "© OpenTopoMap contributors"
        cache: true
        aptColor: "black"
        asColor: "deepskyblue"
        maxZoomLevel: 15.5
    }
    ListElement {
        name: "WeGlideMap"
        url: "https://dmt-wgld.b-cdn.net/dmt_hypsometric/dmt_hypsometric/"
        attribution: "WeGlide"
        cache: true
        aptColor: "black"
        asColor: "deepskyblue"
        maxZoomLevel: 15.5
    }
    ListElement {
        name: "Satellite Google"
        url: "https://mt1.google.com/vt/lyrs=s&x=%x&y=%y&z=%z"
        attribution: "Google"
        cache: true
        aptColor: "black"
        asColor: "deepskyblue"
        maxZoomLevel: 18
    }
    ListElement {
        name: "Hybrid Google"
        url: "https://mt1.google.com/vt/lyrs=y&x=%x&y=%y&z=%z"
        attribution: "Google"
        cache: true
        aptColor: "black"
        asColor: "deepskyblue"
        maxZoomLevel: 18
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
