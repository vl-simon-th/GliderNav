#ifndef AIRSPACE_H
#define AIRSPACE_H

#include <QGeoCoordinate>
#include <QList>
#include <QString>
#include <QQmlEngine>

enum class AltitudeUnit {
    GND,
    MSL,
    FL,
    UNKNOWN
};

class Airspace {
    Q_ENUM(AltitudeUnit)

    Q_GADGET
    Q_PROPERTY(QString type READ getType CONSTANT)
    Q_PROPERTY(QString name READ getName CONSTANT)
    Q_PROPERTY(double lowerAltitude READ getLowerAltitude CONSTANT)
    Q_PROPERTY(double upperAltitude READ getUpperAltitude CONSTANT)
    Q_PROPERTY(AltitudeUnit lowerAltitudeUnits READ getLowerAltitudeUnits CONSTANT)
    Q_PROPERTY(AltitudeUnit upperAltitudeUnits READ getUpperAltitudeUnits CONSTANT)
    Q_PROPERTY(QList<QGeoCoordinate> coordinates READ getCoordinates CONSTANT)

public:
    Airspace(const QString &type, const QString &name, double lowerAltitude, double upperAltitude,
             AltitudeUnit lowerAltitudeUnits, AltitudeUnit upperAltitudeUnits,
             const QList<QGeoCoordinate> &coordinates);

    QString getType() const;
    QString getName() const;
    double getLowerAltitude() const;
    double getUpperAltitude() const;
    AltitudeUnit getLowerAltitudeUnits() const;
    AltitudeUnit getUpperAltitudeUnits() const;
    QList<QGeoCoordinate> getCoordinates() const;

private:
    const QString type;
    const QString name;
    const double lowerAltitude;
    const double upperAltitude;
    const AltitudeUnit lowerAltitudeUnits;
    const AltitudeUnit upperAltitudeUnits;
    const QList<QGeoCoordinate> coordinates;
};

#endif // AIRSPACE_H
