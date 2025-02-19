#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QQmlEngine>

#include "task.h"
#include "taskslist.h"

#include "flightlog.h"
#include "flightloglist.h"

#include "airportmodel.h"
#include "airspacemodel.h"

#include <QDir>
#include <QStandardPaths>

class Controller : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit Controller(QObject *parent = nullptr);

    Task *getCurrentTask() const;
    void setCurrentTask(Task *newCurrentTask);

    TasksList *getTasksList() const;

    FlightLog *getCurrentLog() const;
    void setCurrentLog(FlightLog *newCurrentLog);

    FlightLogList *getLogList() const;

    AirportModel *getAirportModel() const;

    AirspaceModel *getAirspaceModel() const;

signals:

    void currentTaskChanged();
    void currentLogChanged();

private:
    Task *currentTask;
    TasksList *tasksList;

    Q_PROPERTY(Task *currentTask READ getCurrentTask WRITE setCurrentTask NOTIFY currentTaskChanged FINAL)
    Q_PROPERTY(TasksList *tasksList READ getTasksList CONSTANT FINAL)

    FlightLog *currentLog;
    FlightLogList *logList;
    Q_PROPERTY(FlightLog *currentLog READ getCurrentLog WRITE setCurrentLog NOTIFY currentLogChanged FINAL)
    Q_PROPERTY(FlightLogList *logList READ getLogList CONSTANT FINAL)

    AirportModel *airportModel;
    AirspaceModel *airspaceModel;
    Q_PROPERTY(AirportModel *airportModel READ getAirportModel CONSTANT FINAL)
    Q_PROPERTY(AirspaceModel *airspaceModel READ getAirspaceModel CONSTANT FINAL)
};

#endif // CONTROLLER_H
