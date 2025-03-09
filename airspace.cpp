#include "airspace.h"

Airspace::Airspace(QObject *parent)
    : QObject{parent}, lowerAltitude(0), upperAltitude(0),
    lowerAltitudeUnits(AltitudeUnit::UNKNOWN), upperAltitudeUnits(AltitudeUnit::UNKNOWN)
{
}

Airspace::Airspace(const QString &type, const QString &name, double lowerAltitude, double upperAltitude,
                   AltitudeUnit lowerAltitudeUnits, AltitudeUnit upperAltitudeUnits,
                   const QList<QGeoCoordinate> &coordinates, QObject *parent)
    : QObject{parent}, type(type), name(name), lowerAltitude(lowerAltitude), upperAltitude(upperAltitude),
    lowerAltitudeUnits(lowerAltitudeUnits), upperAltitudeUnits(upperAltitudeUnits), coordinates(coordinates)
{
    geoBoundingRect = QGeoPolygon(this->coordinates).boundingGeoRectangle();
}

Airspace::Airspace(const QString &type, const QString &name, const QString &lowerAltitude, const QString &upperAltitude,
                   const QString &coordinates, QObject *parent)
    : QObject(parent), type(type), name(name), lowerAltitude(parseAltitude(lowerAltitude, lowerAltitudeUnits)),
    upperAltitude(parseAltitude(upperAltitude, upperAltitudeUnits)), coordinates(parseCoordinates(coordinates))
{
    geoBoundingRect = QGeoPolygon(this->coordinates).boundingGeoRectangle();
}

QString Airspace::getType() const {
    return type;
}

void Airspace::setType(const QString &type) {
    if (this->type != type) {
        this->type = type;
        emit typeChanged();
    }
}

QString Airspace::getName() const {
    return name;
}

void Airspace::setName(const QString &name) {
    if (this->name != name) {
        this->name = name;
        emit nameChanged();
    }
}

double Airspace::getLowerAltitude() const {
    return lowerAltitude;
}

void Airspace::setLowerAltitude(double lowerAltitude) {
    if (this->lowerAltitude != lowerAltitude) {
        this->lowerAltitude = lowerAltitude;
        emit lowerAltitudeChanged();
    }
}

double Airspace::getUpperAltitude() const {
    return upperAltitude;
}

void Airspace::setUpperAltitude(double upperAltitude) {
    if (this->upperAltitude != upperAltitude) {
        this->upperAltitude = upperAltitude;
        emit upperAltitudeChanged();
    }
}

AltitudeUnit Airspace::getLowerAltitudeUnits() const {
    return lowerAltitudeUnits;
}

void Airspace::setLowerAltitudeUnits(AltitudeUnit lowerAltitudeUnits) {
    if (this->lowerAltitudeUnits != lowerAltitudeUnits) {
        this->lowerAltitudeUnits = lowerAltitudeUnits;
        emit lowerAltitudeUnitsChanged();
    }
}

AltitudeUnit Airspace::getUpperAltitudeUnits() const {
    return upperAltitudeUnits;
}

void Airspace::setUpperAltitudeUnits(AltitudeUnit upperAltitudeUnits) {
    if (this->upperAltitudeUnits != upperAltitudeUnits) {
        this->upperAltitudeUnits = upperAltitudeUnits;
        emit upperAltitudeUnitsChanged();
    }
}

QList<QGeoCoordinate> Airspace::getCoordinates() const {
    return coordinates;
}

void Airspace::setCoordinates(const QList<QGeoCoordinate> &coordinates) {
    if (this->coordinates != coordinates) {
        this->coordinates = coordinates;
        geoBoundingRect = QGeoPolygon(this->coordinates).boundingGeoRectangle();
        emit coordinatesChanged();
    }
}

QGeoRectangle Airspace::getGeoBoundingRect() const
{
    return geoBoundingRect;
}

QString Airspace::unitToString(AltitudeUnit unit)
{
    switch (unit) {
    case AltitudeUnit::FL:
        return "FL";
    case AltitudeUnit::GND:
        return "GND";
    case AltitudeUnit::MSL:
        return "MSL";
    case AltitudeUnit::UNKNOWN:
        return "UNKNOWN";
    default:
        return "";
    }
}

double Airspace::parseAltitude(const QString &altitudeString, AltitudeUnit &unit) const {
    if (altitudeString.endsWith("GND")) {
        unit = AltitudeUnit::GND;
        if(!altitudeString.startsWith("GND")) {
            return altitudeString.first(altitudeString.length() - 6).toDouble(); // Remove "GND"
        }
        return 0.0;
    } else if (altitudeString.endsWith("ft MSL")) {
        unit = AltitudeUnit::MSL;
        return altitudeString.first(altitudeString.length() - 6).toDouble(); // Remove "ft MSL"
    } else if (altitudeString.startsWith("FL")) {
        unit = AltitudeUnit::FL;
        return altitudeString.sliced(2).toDouble(); // Remove "FL"
    } else {
        unit = AltitudeUnit::UNKNOWN;
        return 0.0;
    }
}

QList<QGeoCoordinate> Airspace::parseCoordinates(const QString &coordinatesString) const {
    QList<QGeoCoordinate> coordinatesList;
    QStringList lines = coordinatesString.split('\n', Qt::SkipEmptyParts);
    foreach (const QString &line, lines) {
        QString trimmedLine = line.trimmed();
        if (trimmedLine.startsWith("DP ")) {
            QStringList parts = trimmedLine.sliced(3).split(' ');
            if (parts.size() == 4) {
                QString latPart = parts[0];
                QString lonPart = parts[2];

                bool latOk, lonOk;
                double latDegrees = latPart.first(latPart.indexOf(':')).toDouble(&latOk);
                double latMinutes = latPart.sliced(latPart.indexOf(':') + 1, 2).toDouble();
                double latSeconds = latPart.sliced(latPart.lastIndexOf(':') + 1).toDouble();

                double lonDegrees = lonPart.first(lonPart.indexOf(':')).toDouble(&lonOk);
                double lonMinutes = lonPart.sliced(lonPart.indexOf(':') + 1, 2).toDouble();
                double lonSeconds = lonPart.sliced(lonPart.lastIndexOf(':') + 1).toDouble();

                double latitude = latDegrees + latMinutes / 60.0 + latSeconds / 3600.0;
                double longitude = lonDegrees + lonMinutes / 60.0 + lonSeconds / 3600.0;

                if (parts[1] == "S") latitude = -latitude;
                if (parts[3] == "W") longitude = -longitude;

                if (latOk && lonOk) {
                    coordinatesList.append(QGeoCoordinate(latitude, longitude));
                }
            }
        }
    }
    return coordinatesList;
}
