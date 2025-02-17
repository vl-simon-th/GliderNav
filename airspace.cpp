#include "airspace.h"

Airspace::Airspace(const QString &type, const QString &name, double lowerAltitude, double upperAltitude,
                   AltitudeUnit lowerAltitudeUnits, AltitudeUnit upperAltitudeUnits,
                   const QList<QGeoCoordinate> &coordinates)

    : type(type), name(name), lowerAltitude(lowerAltitude), upperAltitude(upperAltitude),
    lowerAltitudeUnits(lowerAltitudeUnits), upperAltitudeUnits(upperAltitudeUnits), coordinates(coordinates)
{

}

QString Airspace::getType() const {
    return type;
}

QString Airspace::getName() const {
    return name;
}

double Airspace::getLowerAltitude() const {
    return lowerAltitude;
}

double Airspace::getUpperAltitude() const {
    return upperAltitude;
}

AltitudeUnit Airspace::getLowerAltitudeUnits() const {
    return lowerAltitudeUnits;
}

AltitudeUnit Airspace::getUpperAltitudeUnits() const {
    return upperAltitudeUnits;
}

QList<QGeoCoordinate> Airspace::getCoordinates() const {
    return coordinates;
}
