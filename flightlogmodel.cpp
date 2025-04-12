#include "flightlogmodel.h"
#include "roles.h"

FlightLogModel::FlightLogModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int FlightLogModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    if(log) {
        return visiblePathIndices.count()-1;
    } else {
        return 0;
    }
}

QVariant FlightLogModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    switch (role) {
    case Roles::PointRole:
        return QVariant::fromValue(log->getPath().at(visiblePathIndices.at(index.row())));
    case Roles::NextPointRole:
        return QVariant::fromValue(log->getPath().at(visiblePathIndices.at(index.row()+1)));
    case Roles::ColorRole:
        return log->getColors().at(visiblePathIndices.at(index.row()));
    default:
        return QVariant();
    }
    return QVariant();
}

QHash<int, QByteArray> FlightLogModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Roles::PointRole] = "point";
    roles[Roles::NextPointRole] = "nextPoint";
    roles[Roles::ColorRole] = "color";
    return roles;
}

FlightLog *FlightLogModel::getLog() const
{
    return log;
}

void FlightLogModel::setLog(FlightLog *newLog)
{
    if (log == newLog)
        return;
    if(log) {
        log->disconnect(log, &FlightLog::pathChanged, this, &FlightLogModel::updateModel);
    }
    log = newLog;
    if(log) {
        log->connect(log, &FlightLog::pathChanged, this, &FlightLogModel::updateModel);
    }
    visiblePathIndices.clear();
    emit logChanged();
}

void FlightLogModel::updateViewArea(const QGeoShape &newViewArea)
{
    viewArea = newViewArea;
    if(log) {
        updateModel();
    }
}

void FlightLogModel::updateModel()
{
    visiblePathIndices.clear();

    QList<QList<int>> newVisiblePathIndicesList;
    newVisiblePathIndicesList.append(QList<int>());

    bool nextListCreated = true;

    bool insertNext = false;
    if(log->getPath().length() > 1)
        insertNext = viewArea.contains(log->getPath().at(0));
    bool insertCurrent = false;
    int lastInsert = -100; // smaller than anything that makes sense

    int pathLengthm1 = log->getPath().length()-1; //optimization
    for(int i = 0; i < pathLengthm1; i++) {
        insertCurrent = insertNext;
        insertNext = viewArea.contains(log->getPath().at(i+1));

        if(insertCurrent) {
            nextListCreated = false;
            newVisiblePathIndicesList.last().append(i);
            lastInsert = i;
        } else if(insertNext || lastInsert == i-1) {
            nextListCreated = false;
            newVisiblePathIndicesList.last().append(i);
        } else if(!nextListCreated){
            newVisiblePathIndicesList.append(QList<int>());
            nextListCreated = true;
        }
    }
    if(insertNext || lastInsert == pathLengthm1-1)
        newVisiblePathIndicesList.last().append(pathLengthm1);

    if(newVisiblePathIndicesList.last().isEmpty()) newVisiblePathIndicesList.removeLast();

    int points = 0;
    for(int i = 0; i < newVisiblePathIndicesList.length(); i++) {
        points += newVisiblePathIndicesList.at(i).length();
    }
    int skip = floor(points / 250.0);
    if(skip < 1) skip = 1;

    QList<int> newVisiblePathIndices;
    for(int i = 0; i < newVisiblePathIndicesList.length(); i++) {
        //add points
        for(int j = 0; j < newVisiblePathIndicesList.at(i).length(); j+=skip) {
            newVisiblePathIndices.append(newVisiblePathIndicesList.at(i).at(j));
        }
        if(newVisiblePathIndices.last() != newVisiblePathIndicesList.at(i).last())
            newVisiblePathIndices.append(newVisiblePathIndicesList.at(i).last());

        //inbetween
        if(i != newVisiblePathIndicesList.length()-1)
            newVisiblePathIndices.append((newVisiblePathIndicesList.at(i).last() + newVisiblePathIndicesList.at(i+1).first()) / 2);
    }

    visiblePathIndices = newVisiblePathIndices;

    emit visiblePathChanged();
}
