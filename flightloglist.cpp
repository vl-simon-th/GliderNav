#include "flightloglist.h"

FlightLogList::FlightLogList(QObject *parent)
    : QObject{parent}
{}

QList<FlightLog *> FlightLogList::getLogs() const
{
    return logs;
}

void FlightLogList::setLogs(const QList<FlightLog *> &newLogs)
{
    if (logs == newLogs)
        return;
    logs = newLogs;
    emit logsChanged();
}

void FlightLogList::addLog(FlightLog *newLog)
{
    logs.append(newLog);
    emit logsChanged();
}
