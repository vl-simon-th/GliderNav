#ifndef AIRSPACE_H
#define AIRSPACE_H

#include <QGeoCoordinate>
#include <QList>
#include <QString>
#include <QQmlEngine>
#include <QObject>

enum class AltitudeUnit {
    GND,
    MSL,
    FL,
    UNKNOWN
};

class Airspace : public QObject {
    Q_ENUM(AltitudeUnit)

    Q_OBJECT
    Q_PROPERTY(QString type READ getType WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(double lowerAltitude READ getLowerAltitude WRITE setLowerAltitude NOTIFY lowerAltitudeChanged)
    Q_PROPERTY(double upperAltitude READ getUpperAltitude WRITE setUpperAltitude NOTIFY upperAltitudeChanged)
    Q_PROPERTY(AltitudeUnit lowerAltitudeUnits READ getLowerAltitudeUnits WRITE setLowerAltitudeUnits NOTIFY lowerAltitudeUnitsChanged)
    Q_PROPERTY(AltitudeUnit upperAltitudeUnits READ getUpperAltitudeUnits WRITE setUpperAltitudeUnits NOTIFY upperAltitudeUnitsChanged)
    Q_PROPERTY(QList<QGeoCoordinate> coordinates READ getCoordinates WRITE setCoordinates NOTIFY coordinatesChanged)
    QML_ELEMENT

public:
    explicit Airspace(QObject *parent = nullptr);
    Airspace(const QString &type, const QString &name, double lowerAltitude, double upperAltitude,
             AltitudeUnit lowerAltitudeUnits, AltitudeUnit upperAltitudeUnits,
             const QList<QGeoCoordinate> &coordinates, QObject *parent = nullptr);
    Airspace(const QString &type, const QString &name, const QString &lowerAltitude, const QString &upperAltitude,
             const QString &coordinates, QObject *parent = nullptr);

    QString getType() const;
    void setType(const QString &type);

    QString getName() const;
    void setName(const QString &name);

    double getLowerAltitude() const;
    void setLowerAltitude(double lowerAltitude);

    double getUpperAltitude() const;
    void setUpperAltitude(double upperAltitude);

    AltitudeUnit getLowerAltitudeUnits() const;
    void setLowerAltitudeUnits(AltitudeUnit lowerAltitudeUnits);

    AltitudeUnit getUpperAltitudeUnits() const;
    void setUpperAltitudeUnits(AltitudeUnit upperAltitudeUnits);

    QList<QGeoCoordinate> getCoordinates() const;
    void setCoordinates(const QList<QGeoCoordinate> &coordinates);

signals:
    void typeChanged();
    void nameChanged();
    void lowerAltitudeChanged();
    void upperAltitudeChanged();
    void lowerAltitudeUnitsChanged();
    void upperAltitudeUnitsChanged();
    void coordinatesChanged();

private:
    QString type;
    QString name;
    double lowerAltitude;
    double upperAltitude;
    AltitudeUnit lowerAltitudeUnits;
    AltitudeUnit upperAltitudeUnits;
    QList<QGeoCoordinate> coordinates;

    double parseAltitude(const QString &altitude, AltitudeUnit &unit) const;
    QList<QGeoCoordinate> parseCoordinates(const QString &coordinates) const;
};

#endif // AIRSPACE_H
