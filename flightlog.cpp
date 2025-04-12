#include "flightlog.h"

FlightLog::FlightLog(QObject *parent)
    : QObject{parent}
{
}

QColor FlightLog::numberToColor(double value) {
    // Clamp the value to the range [-5, 5]
    value = qBound(-5.0, value, 5.0);

    // Map the value to a range [0, 1]
    double normalizedValue = (value + 5.0) / 10.0;

    // Interpolate the color based on the normalized value
    int red, green, blue;

    if (normalizedValue <= 0.5) {
        // Interpolate between red (255, 0, 0) and yellow (255, 255, 0)
        double t = normalizedValue / 0.5;
        red = 255;
        green = static_cast<int>(t * 255);
        blue = 0;
    } else {
        // Interpolate between yellow (255, 255, 0) and green (119, 255, 0)
        double t = (normalizedValue - 0.5) / 0.5;
        red = static_cast<int>(255 - t * (255 - 119));
        green = 255;
        blue = 0;
    }

    // Return the interpolated color
    return QColor(red, green, blue);
}

const QList<QGeoCoordinate> &FlightLog::getPath() const
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
    QDateTime currentTime = QDateTime::currentDateTime();
    if(path.length() > 0) {
        colors.append(numberToColor(
            (point.altitude()-path.last().altitude())/
            timestamps.last().secsTo(currentTime)));
    }

    path.append(point);
    timestamps.append(currentTime);
    writeToDir();

    emit colorsChanged();
    emit pathChanged();
    emit timestampsChanged();
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
    emit startTimeChanged();
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
    emit endTimeChanged();
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

    QJsonArray timestampsArray;
    foreach (const QDateTime &time, timestamps) {
        timestampsArray.append(time.toString(Qt::ISODate));
    }

    root["timestamps"] = timestampsArray;

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
    QList<QGeoCoordinate> newPath;
    if (pathValue.isArray()) {
        QJsonArray pathArray = pathValue.toArray();
        foreach (const QJsonValue &coordValue, pathArray) {
            if (!coordValue.isObject()) continue;
            QJsonObject coordObj = coordValue.toObject();
            double lat = coordObj.value("latitude").toDouble();
            double lon = coordObj.value("longitude").toDouble();
            double alt = coordObj.value("altitude").toDouble();
            newPath.append(QGeoCoordinate(lat, lon, alt));
        }
    }

    QJsonValue timestampsValue = root.value("timestamps");
    QList<QDateTime> newTimestamps;
    if(timestampsValue.isArray()) {
        QJsonArray timestampsArray = timestampsValue.toArray();
        foreach(const QJsonValue &timeValue, timestampsArray) {
            if(!timeValue.isString()) continue;
            newTimestamps.append(QDateTime::fromString(timeValue.toString(), Qt::ISODate));
        }
    }


    //usually this should not be needed as the length is the same
    while(newPath.length() > newTimestamps.length()) {
        newTimestamps.append(QDateTime(newTimestamps.last()).addSecs(3));
    }
    if(newTimestamps.length() > newPath.length()) {
        newTimestamps = newTimestamps.first(newPath.length());
    }

    //setting after checks
    flightLog->setPath(newPath);
    flightLog->setTimestamps(newTimestamps);


    QList<QColor> newColors;
    for(int i = 0; i < newPath.length()-1; i++) {
        newColors.append(numberToColor(
            newPath[i+1].altitude()-newPath[i].altitude()/
            newTimestamps[i].secsTo(newTimestamps[i+1])
            ));
    }
    flightLog->setColors(newColors);

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

const QList<QDateTime> &FlightLog::getTimestamps() const
{
    return timestamps;
}

void FlightLog::setTimestamps(const QList<QDateTime> &newTimestamps)
{
    if (timestamps == newTimestamps)
        return;
    timestamps = newTimestamps;
    emit timestampsChanged();
}

const QList<QColor> &FlightLog::getColors() const
{
    return colors;
}

void FlightLog::setColors(const QList<QColor> &newColors)
{
    if (colors == newColors)
        return;
    colors = newColors;
    emit colorsChanged();
}
