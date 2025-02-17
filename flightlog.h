#ifndef FLIGHTLOG_H
#define FLIGHTLOG_H

#include <QObject>
#include <QQmlEngine>

#include <QList>
#include <QGeoCoordinate>

class FlightLog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit FlightLog(QObject *parent = nullptr);

    QList<QGeoCoordinate> getPath() const;
    void setPath(const QList<QGeoCoordinate> &newPath);
    Q_INVOKABLE void addPoint(const QGeoCoordinate &point);

signals:

    void pathChanged();

private:
    QList<QGeoCoordinate> path;
    Q_PROPERTY(QList<QGeoCoordinate> path READ getPath WRITE setPath NOTIFY pathChanged FINAL)
};

#endif // FLIGHTLOG_H
