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

#include <QColor>

class FlightLog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit FlightLog(QObject *parent = nullptr);

    static QColor numberToColor(double value);

    const QList<QGeoCoordinate> &getPath() const;
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

    const QList<QDateTime> &getTimestamps() const;
    void setTimestamps(const QList<QDateTime> &newTimestamps);

    const QList<QColor> &getColors() const;
    void setColors(const QList<QColor> &newColors);

signals:

    void pathChanged();
    void startTimeChanged();
    void endTimeChanged();
    void timestampsChanged();
    void colorsChanged();

private:
    QList<QGeoCoordinate> path;
    Q_PROPERTY(QList<QGeoCoordinate> path READ getPath WRITE setPath NOTIFY pathChanged FINAL)

    QList<QDateTime> timestamps;
    Q_PROPERTY(QList<QDateTime> timestamps READ getTimestamps WRITE setTimestamps NOTIFY timestampsChanged FINAL)

    QList<QColor> colors;
    Q_PROPERTY(QList<QColor> colors READ getColors WRITE setColors NOTIFY colorsChanged FINAL)

    QDateTime startTime;
    QDateTime endTime;
    Q_PROPERTY(QDateTime startTime READ getStartTime WRITE setStartTime NOTIFY startTimeChanged FINAL)
    Q_PROPERTY(QDateTime endTime READ getEndTime WRITE setEndTime NOTIFY endTimeChanged FINAL)
};

#endif // FLIGHTLOG_H
