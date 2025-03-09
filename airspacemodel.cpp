#include "airspacemodel.h"
#include "roles.h"

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
    case Roles::TypeRole:
        return airspace->getType();
    case Roles::NameRole:
        return airspace->getName();
    case Roles::LowerAltitudeRole:
        return airspace->getLowerAltitude();
    case Roles::UpperAltitudeRole:
        return airspace->getUpperAltitude();
    case Roles::LowerAltitudeUnitsRole:
        return QVariant::fromValue(airspace->getLowerAltitudeUnits());
    case Roles::UpperAltitudeUnitsRole:
        return QVariant::fromValue(airspace->getUpperAltitudeUnits());
    case Roles::CoordinatesRole:
        return QVariant::fromValue(airspace->getCoordinates());
    case Roles::GeoBoundingRect:
        return QVariant::fromValue(airspace->getGeoBoundingRect());
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> AirspaceModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Roles::TypeRole] = "type";
    roles[Roles::NameRole] = "name";
    roles[Roles::LowerAltitudeRole] = "lowerAltitude";
    roles[Roles::UpperAltitudeRole] = "upperAltitude";
    roles[Roles::LowerAltitudeUnitsRole] = "lowerAltitudeUnits";
    roles[Roles::UpperAltitudeUnitsRole] = "upperAltitudeUnits";
    roles[Roles::CoordinatesRole] = "coordinates";
    roles[Roles::GeoBoundingRect] = "geoBoundingRect";
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

    addAvailableType(type);

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
        if(!(line == "")) {
            if(!line.startsWith("*")) {
                currentAS += line + '\n';
            }
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

void AirspaceModel::reloadAirspaces(const QDir &dir)
{
    foreach (Airspace *airspace, airspaces) {
        airspace->deleteLater();
    }
    airspaces.clear();
    emit airspacesChanged();
    importAirspacesFromDir(dir);
}

QList<QString> AirspaceModel::getAvailableTypes() const
{
    return availableTypes;
}

void AirspaceModel::setAvailableTypes(const QList<QString> &newAvailableTypes)
{
    if (availableTypes == newAvailableTypes)
        return;
    availableTypes = newAvailableTypes;
    std::sort(availableTypes.begin(), availableTypes.end(), [](const QString &a, const QString &b) {
        if (a.length() == b.length()) {
            return a < b; // Alphabetical order
        }
        return a.length() < b.length(); // Length order
    });
    emit availableTypesChanged();
}

void AirspaceModel::addAvailableType(const QString &type)
{
    if(type == "" || availableTypes.contains(type)) return;
    availableTypes.append(type);
    std::sort(availableTypes.begin(), availableTypes.end(), [](const QString &a, const QString &b) {
        if (a.length() == b.length()) {
            return a < b; // Alphabetical order
        }
        return a.length() < b.length(); // Length order
    });
    emit availableTypesChanged();
}
