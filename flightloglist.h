#ifndef FLIGHTLOGLIST_H
#define FLIGHTLOGLIST_H

#include <QObject>
#include <QQmlEngine>

#include <QList>
#include "flightlog.h"

#include <QDir>
#include <QStandardPaths>

class FlightLogList : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit FlightLogList(QObject *parent = nullptr);

    QList<FlightLog *> getLogs() const;
    void setLogs(const QList<FlightLog *> &newLogs);
    Q_INVOKABLE void addLog(FlightLog *newLog);
    Q_INVOKABLE void deleteLog(FlightLog *flightLog);

    Q_INVOKABLE void writeLogsToDir();
    Q_INVOKABLE void importLogsFromDir();

signals:

    void logsChanged();

private:
    QList<FlightLog *> logs;
    Q_PROPERTY(QList<FlightLog *> logs READ getLogs WRITE setLogs NOTIFY logsChanged FINAL)
};

#endif // FLIGHTLOGLIST_H
