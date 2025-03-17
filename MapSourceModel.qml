import QtQuick

ListModel {
    id: mapSourceModel

    // Default map providers
    ListElement {
        name: "OpenStreetMap"
        url: "http://b.tile.openstreetmap.org/"
        attribution: "© OpenStreetMap contributors"
    }
    ListElement {
        name: "OpenTopoMap"
        url: "https://a.tile.opentopomap.org/"
        attribution: "© OpenTopoMap contributors"
    }
    ListElement {
        name: "WeGlideMap"
        url: "https://dmt-wgld.b-cdn.net/dmt_hypsometric/dmt_hypsometric/"
        attribution: "I found that in f12"
    }
    ListElement {
        name: "SkySightSatellite"
        url: "https://satellite.skysight.io/tiles/%z/%x/%y?date=2025/03/17/1600&mtg=true.png"
        attribution: "I found that in f12"
    }
}
