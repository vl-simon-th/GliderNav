#include "task.h"

Task::Task(QObject *parent)
    : QObject{parent}
{
}

QList<QGeoCoordinate> Task::getTurnPoints() const
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

QList<double> Task::getDistancesToPoint() const
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
    int index = turnPoints.indexOf(turnPoint);
    turnPoints.removeAt(index);
    distancesToPoint.removeAt(index);
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
