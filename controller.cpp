#include "controller.h"

Controller::Controller(QObject *parent)
    : QObject{parent}
{
    tasksList = new TasksList(this);
    logList = new FlightLogList(this);
    logList->importLogsFromDir();

    QDir baseDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if(!baseDir.exists()) baseDir.mkpath("./");

    aptDir = QDir(baseDir.filePath("apt"));
    if(!aptDir.exists()) aptDir.mkpath("./");
    airportModel = new AirportModel(this);
    airportModel->importAirportsFromDir(aptDir);

    asDir = QDir(baseDir.filePath("as"));
    if(!asDir.exists()) asDir.mkpath("./");
    airspaceModel = new AirspaceModel(this);
    airspaceModel->importAirspacesFromDir(asDir);


    airportFilterModel = new AirportFilterModel(this);
    airportFilterModel->setSourceModel(airportModel);

    airspaceFilterModel = new AirspaceFilterModel(this);
    airspaceFilterModel->setSourceModel(airspaceModel);

    aptNetworkManager = new QNetworkAccessManager(this);
    connect(aptNetworkManager, &QNetworkAccessManager::finished, this, &Controller::aptFileDownloaded);
    asNetworkManager = new QNetworkAccessManager(this);
    connect(asNetworkManager, &QNetworkAccessManager::finished, this, &Controller::asFileDownloaded);
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

AirportModel *Controller::getAirportModel() const
{
    return airportModel;
}

AirspaceModel *Controller::getAirspaceModel() const
{
    return airspaceModel;
}

AirportFilterModel *Controller::getAirportFilterModel() const
{
    return airportFilterModel;
}

AirspaceFilterModel *Controller::getAirspaceFilterModel() const
{
    return airspaceFilterModel;
}



//does not work for ios :(
void Controller::copyFilesToApt(const QList<QUrl> &files)
{
    QDir baseDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir aptDir = QDir(baseDir.filePath("apt"));
    if(!aptDir.exists()) aptDir.mkpath("./");

    foreach (QUrl file, files) {
        QFile::copy(file.toLocalFile(), aptDir.filePath(file.fileName()));
        airportModel->importAirportsFromCup(aptDir.filePath(file.fileName()));
    }

    airportFilterModel->invalidate();
}

void Controller::copyFilesToAs(const QList<QUrl> &files)
{
    QDir baseDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir asDir = QDir(baseDir.filePath("as"));
    if(!asDir.exists()) asDir.mkpath("./");

    foreach (QUrl file, files) {
        QFile::copy(file.toLocalFile(), asDir.filePath(file.fileName()));
        airspaceModel->importAirspacesFromFile(asDir.filePath(file.fileName()));
    }

    airspaceFilterModel->invalidate();
}

void Controller::downloadAptFile(const QUrl &url)
{
    qDebug() << url;
    QNetworkRequest request(url);
    aptNetworkManager->get(request);
}

void Controller::downloadAsFile(const QUrl &url)
{
    QNetworkRequest request(url);
    asNetworkManager->get(request);
}

void Controller::reloadAirports()
{
    airportModel->relaodAirports(aptDir);
    airportFilterModel->invalidate();
}

void Controller::reloadAirspaces()
{
    airspaceModel->reloadAirspaces(asDir);
    airspaceFilterModel->invalidate();
}

//PUBLIC SLOTS

void Controller::aptFileDownloaded(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        // Get the data location path
        QString dataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir dir(dataLocation);
        if (!dir.exists("apt"))
        {
            dir.mkpath("apt");
        }

        // Construct the file path
        QString filePath = dir.filePath("apt/" + QFileInfo(reply->url().path()).fileName());
        QFile file(filePath);

        // Open the file and write the data
        if (file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        {
            file.write(reply->readAll());
            file.close();
            reloadAirports();
            qDebug() << "File downloaded successfully to:" << filePath;
        }
        else
        {
            qWarning() << "Could not open file for writing:" << filePath;
        }
    }
    else
    {
        qWarning() << "Download failed:" << reply->errorString();
    }

    reply->deleteLater();
}

void Controller::asFileDownloaded(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        // Get the data location path
        QString dataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir dir(dataLocation);
        if (!dir.exists("as"))
        {
            dir.mkpath("as");
        }

        // Construct the file path
        QString filePath = dir.filePath("as/" + QFileInfo(reply->url().path()).fileName());
        QFile file(filePath);

        // Open the file and write the data
        if (file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        {
            file.write(reply->readAll());
            file.close();
            reloadAirspaces();
            qDebug() << "File downloaded successfully to:" << filePath;
        }
        else
        {
            qWarning() << "Could not open file for writing:" << filePath;
        }
    }
    else
    {
        qWarning() << "Download failed:" << reply->errorString();
    }

    reply->deleteLater();
}
