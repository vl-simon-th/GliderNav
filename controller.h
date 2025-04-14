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

#include "airportfiltermodel.h"
#include "airspacefiltermodel.h"

#include <QDir>
#include <QStandardPaths>

#include <QList>
#include <QUrl>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

#include <QCoreApplication>

#include <QVariantMap>
#include <QQuickWindow>

#include <QScreen>

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

    AirportFilterModel *getAirportFilterModel() const;

    AirspaceFilterModel *getAirspaceFilterModel() const;

    Q_INVOKABLE void copyFilesToApt(const QList<QUrl> &files);
    Q_INVOKABLE void copyFilesToAs(const QList<QUrl> &files);

    Q_INVOKABLE void downloadAptFile(const QUrl &url);
    Q_INVOKABLE void downloadAsFile(const QUrl &url);

    Q_INVOKABLE void reloadAirports();
    Q_INVOKABLE void reloadAirspaces();

    Q_INVOKABLE void clearAirspaceDir();
    Q_INVOKABLE void clearAirportDir();

    Q_INVOKABLE static QString unitToString(AltitudeUnit unit);

    Q_INVOKABLE static void quit();

    const QList<QString> &getAptAsCodes() const;
    void setAptAsCodes(const QList<QString> &newAptAsCodes);
    Q_INVOKABLE void addAptAsCode(const QString &code);
    Q_INVOKABLE void findCurrentAptAsCodes();

public slots:
    void aptFileDownloaded(QNetworkReply *reply);
    void asFileDownloaded(QNetworkReply *reply);

signals:

    void currentTaskChanged();
    void currentLogChanged();

    void aptAsCodesChanged();

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

    AirportFilterModel *airportFilterModel;
    AirspaceFilterModel *airspaceFilterModel;
    Q_PROPERTY(AirportFilterModel *airportFilterModel READ getAirportFilterModel CONSTANT FINAL)
    Q_PROPERTY(AirspaceFilterModel *airspaceFilterModel READ getAirspaceFilterModel CONSTANT FINAL)

    QDir aptDir;
    QDir asDir;
    QList<QString> aptAsCodes;
    Q_PROPERTY(QList<QString> aptAsCodes READ getAptAsCodes WRITE setAptAsCodes NOTIFY aptAsCodesChanged FINAL)

    QNetworkAccessManager *aptNetworkManager;
    QNetworkAccessManager *asNetworkManager;
};

#endif // CONTROLLER_H
