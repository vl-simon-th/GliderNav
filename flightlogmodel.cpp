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
    for(int i = 0; i < log->getPath().length(); i++) {
        if(viewArea.contains(log->getPath().at(i))) {
            visiblePathIndices.append(i);
        }
    }

    if(visiblePathIndices.length() > 30) {
        QList<int> newVisiblePathIndices;
        int skip = ceil(visiblePathIndices.length() / 30.0);

        for(int i = 0; i < visiblePathIndices.length(); i += skip) {
            newVisiblePathIndices.append(visiblePathIndices.at(i));
        }

        visiblePathIndices = newVisiblePathIndices;
    }

    emit visiblePathChanged();
}
