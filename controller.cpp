#include "controller.h"

Controller::Controller(QObject *parent)
    : QObject{parent}
{
    tasksList = new TasksList(this);
    logList = new FlightLogList(this);

    QDir baseDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if(!baseDir.exists()) baseDir.mkpath("./");

    QDir aptDir = QDir(baseDir.filePath("apt"));
    if(!aptDir.exists()) aptDir.mkpath("./");
    airportList = new AirportList(this);
    airportList->importAirportsFromDir(aptDir);
}

Task *Controller::getCurrentTask() const
{
    return currentTask;
}

void Controller::setCurrentTask(Task *newCurrentTask)
{
    if (currentTask == newCurrentTask)
        return;
    currentTask = newCurrentTask;
    emit currentTaskChanged();
}

TasksList *Controller::getTasksList() const
{
    return tasksList;
}

FlightLog *Controller::getCurrentLog() const
{
    return currentLog;
}

void Controller::setCurrentLog(FlightLog *newCurrentLog)
{
    if (currentLog == newCurrentLog)
        return;
    currentLog = newCurrentLog;
    emit currentLogChanged();
}

FlightLogList *Controller::getLogList() const
{
    return logList;
}

AirportList *Controller::getAirportList() const
{
    return airportList;
}
