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

void FlightLogList::deleteLog(FlightLog *flightLog)
{
    flightLog->deleteDir();
    flightLog->deleteLater();
    logs.removeAll(flightLog);
    emit logsChanged();
}

void FlightLogList::writeLogsToDir()
{
    foreach (FlightLog *fl, logs) {
        fl->writeToDir();
    }
}

void FlightLogList::importLogsFromDir()
{
    QDir dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    if (!dir.exists("logs")) {
        qWarning() << "Logs directory does not exist:" << dir.absoluteFilePath("logs");
        return;
    }

    dir.cd("logs");

    // Clear out any existing list items if desired:
    // m_flightLogs.clear();

    // Look for subdirectories within "logs"
    QFileInfoList subDirs = dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    foreach (const QFileInfo &info, subDirs) {
        QDir subDir(info.absoluteFilePath());
        // Attempt to read a FlightLog from each subdirectory
        FlightLog *log = FlightLog::readFromDir(subDir);
        if (log) {
            logs.append(log);
            qDebug() << "Imported log from:" << subDir.absolutePath();
        }
    }

    emit logsChanged();
}
