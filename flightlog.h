#ifndef FLIGHTLOG_H
#define FLIGHTLOG_H

#include <QObject>
#include <QQmlEngine>

#include <QList>
#include <QGeoCoordinate>

#include <QDateTime>

#include <QDir>
#include <QStandardPaths>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QTextStream>

class FlightLog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit FlightLog(QObject *parent = nullptr);

    QList<QGeoCoordinate> getPath() const;
    void setPath(const QList<QGeoCoordinate> &newPath);
    Q_INVOKABLE void addPoint(const QGeoCoordinate &point);

    QDateTime getStartTime() const;
    void setStartTime(const QDateTime &newStartTime);
    Q_INVOKABLE void setStartTimeNow();

    QDateTime getEndTime() const;
    void setEndTime(const QDateTime &newEndTime);
    Q_INVOKABLE void setEndTimeNow();

    Q_INVOKABLE void writeToDir();
    Q_INVOKABLE void deleteDir();
    static FlightLog *readFromDir(const QDir &dir);

signals:

    void pathChanged();

    void startTimeChanged();

    void endTimeChanged();

private:
    QList<QGeoCoordinate> path;
    Q_PROPERTY(QList<QGeoCoordinate> path READ getPath WRITE setPath NOTIFY pathChanged FINAL)

    QDateTime startTime;
    QDateTime endTime;
    Q_PROPERTY(QDateTime startTime READ getStartTime WRITE setStartTime NOTIFY startTimeChanged FINAL)
    Q_PROPERTY(QDateTime endTime READ getEndTime WRITE setEndTime NOTIFY endTimeChanged FINAL)
};

#endif // FLIGHTLOG_H
