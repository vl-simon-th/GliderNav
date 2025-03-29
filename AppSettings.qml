pragma Singleton
import QtCore

import GliderNav

Settings {
    property string aptAsDataLocation: "https://storage.googleapis.com/29f98e10-a489-4c82-ae5e-489dbcd4912f/"
    property string mapSourceName: "OpenStreetMap"

    property list<string> validAsTypes: ["D", "CTR", "TMA", "TMZ", "R"]

    property list<int> validAptStyles: [2,4,5]
}
