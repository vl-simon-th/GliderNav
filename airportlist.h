#ifndef AIRPORTLIST_H
#define AIRPORTLIST_H

#include <QObject>
#include <QQmlEngine>

#include <QList>
#include "airport.h"

#include <QDir>

class AirportList : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit AirportList(QObject *parent = nullptr);

    QList<Airport *> getAirports() const;
    void setAirports(const QList<Airport *> &newAirports);
    Q_INVOKABLE void addAirport(Airport *newAirport);
    Q_INVOKABLE void removeAirport(Airport *airport);

    Q_INVOKABLE Airport *createAirportFromLine(const QString &line);
    Q_INVOKABLE void importAirportsFromCup(const QString &filePath);
    Q_INVOKABLE void importAirportsFromDir(const QDir &dir);

signals:

    void airportsChanged();

private:
    QList<Airport *> airports;
    Q_PROPERTY(QList<Airport *> airports READ getAirports WRITE setAirports NOTIFY airportsChanged FINAL)
};

#endif // AIRPORTLIST_H
