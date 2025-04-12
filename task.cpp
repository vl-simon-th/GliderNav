#include "task.h"

Task::Task(QObject *parent)
    : QObject{parent}
{
    connect(this, &Task::turnPointsChanged, this, &Task::calcLength);
}

const QList<QGeoCoordinate> &Task::getTurnPoints() const
{
    return turnPoints;
}

void Task::setTurnPoints(const QList<QGeoCoordinate> &newTurnPoints)
{
    if (turnPoints == newTurnPoints)
        return;
    turnPoints = newTurnPoints;
    emit turnPointsChanged();
}

const QList<double> &Task::getDistancesToPoint() const
{
    return distancesToPoint;
}

void Task::setDistancesToPoint(const QList<double> &newDistancesToPoint)
{
    if (distancesToPoint == newDistancesToPoint)
        return;
    distancesToPoint = newDistancesToPoint;
    emit distancesToPointChanged();
}

void Task::addTurnPoint(const QGeoCoordinate &newTurnPoint, const double &distance)
{
    if(turnPoints.size() > 0 && turnPoints.last() == newTurnPoint) return;

    turnPoints.append(newTurnPoint);
    distancesToPoint.append(distance);
    emit turnPointsChanged();
    emit distancesToPointChanged();
}

void Task::removeTurnPoint(const QGeoCoordinate &turnPoint)
{
    for(int i = 0; i < turnPoints.length(); i++) {
        if(turnPoints.at(i) == turnPoint) {
            turnPoints.removeAt(i);
            distancesToPoint.removeAt(i);
        }
    }
    emit turnPointsChanged();
    emit distancesToPointChanged();
}

double Task::calculateDistance()
{
    double distance = 0;

    for(int i = 1; i < turnPoints.size(); i++) {
        distance += turnPoints.at(i-1).distanceTo(turnPoints.at(i));
    }

    return distance;
}

TaskType Task::getTaskType() const
{
    return taskType;
}

void Task::setTaskType(TaskType newTaskType)
{
    if (taskType == newTaskType)
        return;
    taskType = newTaskType;
    emit taskTypeChanged();
}

void Task::writeToDir()
{
    QDir dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    dir.mkdir("tasks");
    dir.cd("tasks");
    dir.mkdir(name);
    dir.cd(name);

    // Construct a JSON object
    QJsonObject root;
    // Path
    QJsonArray turnPointsArray;
    foreach (const QGeoCoordinate &coord, turnPoints) {
        QJsonObject coordObj;
        coordObj["latitude"] = coord.latitude();
        coordObj["longitude"] = coord.longitude();
        coordObj["altitude"] = coord.altitude();
        turnPointsArray.append(coordObj);
    }
    root["turnPoints"] = turnPointsArray;

    QJsonArray distancesArray;
    foreach (double d, distancesToPoint) {
        distancesArray.append(d);
    }
    root["distances"] = distancesArray;

    //Name and Type
    root["name"] = name;
    root["type"] = (taskType == TaskType::AAT ? "AAT" : "RT");

    // Write JSON to file
    QFile file(dir.absoluteFilePath("task.json"));
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QJsonDocument doc(root);
        file.write(doc.toJson(QJsonDocument::Indented));
        file.close();
    }
    else {
        qWarning() << "Could not open file for writing:" << file.fileName();
    }
}

void Task::deleteDir()
{
    QDir dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    if (!dir.exists("tasks")) {
        qWarning() << "Tasks directory does not exist:" << dir.absoluteFilePath("tasks");
        return;
    }
    dir.cd("tasks");

    if (!dir.exists(name)) {
        qWarning() << "Task directory does not exist:" << dir.absoluteFilePath(name);
        return;
    }
    dir.cd(name);

    dir.removeRecursively();
}

Task *Task::readFromDir(const QDir &dir)
{
    if (!dir.exists())
        return nullptr;

    QFile file(dir.absoluteFilePath("task.json"));
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

    Task *task = new Task();

    // Parse path
    QJsonValue turnPointsValue = root.value("turnPoints");
    if (turnPointsValue.isArray()) {
        QList<QGeoCoordinate> newTurnPoints;
        QJsonArray turnPointsArray = turnPointsValue.toArray();
        foreach (const QJsonValue &coordValue, turnPointsArray) {
            if (!coordValue.isObject()) continue;
            QJsonObject coordObj = coordValue.toObject();
            double lat = coordObj.value("latitude").toDouble();
            double lon = coordObj.value("longitude").toDouble();
            double alt = coordObj.value("altitude").toDouble();
            newTurnPoints.append(QGeoCoordinate(lat, lon, alt));
        }
        task->setTurnPoints(newTurnPoints);
    }

    // Parse distances
    QJsonValue distancesValue = root.value("distances");
    if(distancesValue.isArray()) {
        QList<double> newDistancesToPoint;
        QJsonArray distancesArray = distancesValue.toArray();

        foreach (const QJsonValue &dValue, distancesArray) {
            if (!dValue.isDouble()) continue;
            newDistancesToPoint.append(dValue.toDouble());
        }
        task->setDistancesToPoint(newDistancesToPoint);
    }

    // Parse name
    if (root.contains("name")) {
        QString name = root.value("name").toString();
        task->setName(name);
    }

    // Parse type
    if (root.contains("type")) {
        QString typeString = root.value("type").toString();
        task->setTaskType(typeString == "AAT" ? TaskType::AAT : TaskType::RT);
    }

    return task;
}

double Task::getLength() const
{
    return length;
}

void Task::setLength(double newLength)
{
    if (qFuzzyCompare(length, newLength))
        return;
    length = newLength;
    emit lengthChanged();
}

void Task::calcLength()
{
    length = 0;
    for(int i = 0; i < turnPoints.length()-1; i++) {
        length += turnPoints[i].distanceTo(turnPoints[i+1]);
    }
    emit lengthChanged();
}

QString Task::getName() const
{
    return name;
}

void Task::setName(const QString &newName)
{
    if (name == newName)
        return;
    name = newName;
    emit nameChanged();
}
