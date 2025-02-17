#include "flightlog.h"

FlightLog::FlightLog(QObject *parent)
    : QObject{parent}
{}

QList<QGeoCoordinate> FlightLog::getPath() const
{
    return path;
}

void FlightLog::setPath(const QList<QGeoCoordinate> &newPath)
{
    if (path == newPath)
        return;
    path = newPath;
    emit pathChanged();
}

void FlightLog::addPoint(const QGeoCoordinate &point)
{
    path.append(point);
    emit pathChanged();
}
