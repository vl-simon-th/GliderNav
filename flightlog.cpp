#include "flightlog.h"

FlightLog::FlightLog(QObject *parent)
    : QObject{parent}
{
}

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
    writeToDir();

    emit pathChanged();
}

QDateTime FlightLog::getStartTime() const
{
    return startTime;
}

void FlightLog::setStartTime(const QDateTime &newStartTime)
{
    if (startTime == newStartTime)
        return;
    startTime = newStartTime;
    emit startTimeChanged();
}

void FlightLog::setStartTimeNow()
{
    startTime = QDateTime::currentDateTimeUtc();
}

QDateTime FlightLog::getEndTime() const
{
    return endTime;
}

void FlightLog::setEndTime(const QDateTime &newEndTime)
{
    if (endTime == newEndTime)
        return;
    endTime = newEndTime;
    emit endTimeChanged();
}

void FlightLog::setEndTimeNow()
{
    endTime = QDateTime::currentDateTimeUtc();
}

void FlightLog::writeToDir()
{
    QDir dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    dir.mkdir("logs");
    dir.cd("logs");
    dir.mkdir(startTime.toString(Qt::ISODate));
    dir.cd(startTime.toString(Qt::ISODate));

    // Construct a JSON object
    QJsonObject root;
    // Path
    QJsonArray pathArray;
    foreach (const QGeoCoordinate &coord, path) {
        QJsonObject coordObj;
        coordObj["latitude"] = coord.latitude();
        coordObj["longitude"] = coord.longitude();
        coordObj["altitude"] = coord.altitude();
        pathArray.append(coordObj);
    }
    root["path"] = pathArray;

    // Start time
    root["startTime"] = startTime.toString(Qt::ISODate);

    // End time
    root["endTime"] = endTime.toString(Qt::ISODate);

    // Write JSON to file
    QFile file(dir.absoluteFilePath("flightlog.json"));
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QJsonDocument doc(root);
        file.write(doc.toJson(QJsonDocument::Indented));
        file.close();
    }
    else {
        qWarning() << "Could not open file for writing:" << file.fileName();
    }
}

void FlightLog::deleteDir()
{
    QDir dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    if (!dir.exists("logs")) {
        qWarning() << "Logs directory does not exist:" << dir.absoluteFilePath("dir");
        return;
    }
    dir.cd("logs");

    if (!dir.exists(startTime.toString(Qt::ISODate))) {
        qWarning() << "FlightLog directory does not exist:" << dir.absoluteFilePath("dir");
        return;
    }
    dir.cd(startTime.toString(Qt::ISODate));

    dir.removeRecursively();
}

FlightLog *FlightLog::readFromDir(const QDir &dir)
{
    if (!dir.exists())
        return nullptr;

    QFile file(dir.absoluteFilePath("flightlog.json"));
    if (!file.exists() || !file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file for reading:" << file.fileName();
        return nullptr;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (doc.isNull() || !doc.isObject()) {
        qWarning() << "Invalid JSON structure.";
        return nullptr;
    }

    QJsonObject root = doc.object();

    auto *flightLog = new FlightLog();

    // Parse path
    QJsonValue pathValue = root.value("path");
    if (pathValue.isArray()) {
        QList<QGeoCoordinate> newPath;
        QJsonArray pathArray = pathValue.toArray();
        foreach (const QJsonValue &coordValue, pathArray) {
            if (!coordValue.isObject()) continue;
            QJsonObject coordObj = coordValue.toObject();
            double lat = coordObj.value("latitude").toDouble();
            double lon = coordObj.value("longitude").toDouble();
            double alt = coordObj.value("altitude").toDouble();
            newPath.append(QGeoCoordinate(lat, lon, alt));
        }
        flightLog->setPath(newPath);
    }

    // Parse start time
    if (root.contains("startTime")) {
        QString startTimeString = root.value("startTime").toString();
        flightLog->setStartTime(QDateTime::fromString(startTimeString, Qt::ISODate));
    }

    // Parse end time
    if (root.contains("endTime")) {
        QString endTimeString = root.value("endTime").toString();
        flightLog->setEndTime(QDateTime::fromString(endTimeString, Qt::ISODate));
    }

    return flightLog;
}
