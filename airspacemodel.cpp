#include "airspacemodel.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

AirspaceModel::AirspaceModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int AirspaceModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return airspaces.size();
}

QVariant AirspaceModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    Airspace *airspace = airspaces.at(index.row());

    switch (role) {
    case TypeRole:
        return airspace->getType();
    case AirspaceNameRole:
        return airspace->getName();
    case LowerAltitudeRole:
        return airspace->getLowerAltitude();
    case UpperAltitudeRole:
        return airspace->getUpperAltitude();
    case LowerAltitudeUnitsRole:
        return QVariant::fromValue(airspace->getLowerAltitudeUnits());
    case UpperAltitudeUnitsRole:
        return QVariant::fromValue(airspace->getUpperAltitudeUnits());
    case CoordinatesRole:
        return QVariant::fromValue(airspace->getCoordinates());
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> AirspaceModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TypeRole] = "type";
    roles[AirspaceNameRole] = "name";
    roles[LowerAltitudeRole] = "lowerAltitude";
    roles[UpperAltitudeRole] = "upperAltitude";
    roles[LowerAltitudeUnitsRole] = "lowerAltitudeUnits";
    roles[UpperAltitudeUnitsRole] = "upperAltitudeUnits";
    roles[CoordinatesRole] = "coordinates";
    return roles;
}

Airspace *AirspaceModel::createAirspaceFromLine(const QString &line)
{
    QString type;
    QString name;
    QString lowerAltitude;
    QString upperAltitude;
    QString coordinates;

    foreach (QString linePart, line.split('\n')) {
        if(linePart.startsWith("AC")) {
            type = linePart.sliced(3);
        } else if(linePart.startsWith("AN")) {
            name = linePart.sliced(3);
        } else if(linePart.startsWith("AL")) {
            lowerAltitude = linePart.sliced(3);
        } else if(linePart.startsWith("AH")) {
            upperAltitude = linePart.sliced(3);
        } else {
            coordinates += linePart + '\n';
        }
    }

    return new Airspace(type, name, lowerAltitude, upperAltitude, coordinates, this);
}

void AirspaceModel::importAirspacesFromFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Unable to open file:" << filePath;
        return;
    }

    QTextStream in(&file);

    QString currentAS;

    while(!in.atEnd()) {
        QString line = in.readLine();
        if(!line.startsWith("*")) {
            currentAS += line + '\n';
        } else if (currentAS != "") {
            airspaces.append(createAirspaceFromLine(currentAS));
            currentAS = "";
        }
    }

    emit airspacesChanged();
    emit sizeChanged();
}

void AirspaceModel::importAirspacesFromDir(const QDir &dir)
{
    QStringList filters;
    filters << "*.txt";
    QFileInfoList fileInfoList = dir.entryInfoList(filters, QDir::Files);

    foreach (const QFileInfo& fileInfo, fileInfoList) {
        importAirspacesFromFile(fileInfo.absoluteFilePath());
    }
}
