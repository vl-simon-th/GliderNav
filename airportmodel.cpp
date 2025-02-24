#include "airportmodel.h"

#include "roles.h"

AirportModel::AirportModel(QObject *parent)
    : QAbstractListModel(parent)
{}

int AirportModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return airports.size();
}

QVariant AirportModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    Airport *airport = airports.at(index.row());

    switch (role) {
    case Roles::NameRole:
        return airport->getName();
    case Roles::CodeRole:
        return airport->getCode();
    case Roles::CountryRole:
        return airport->getCountry();
    case Roles::PositionRole:
        return QVariant::fromValue(airport->getPosition());
    case Roles::ElevationRole:
        return airport->getElevation();
    case Roles::StyleRole:
        return airport->getStyle();
    case Roles::RwdirRole:
        return airport->getRwdir();
    case Roles::RwlenRole:
        return airport->getRwlen();
    case Roles::RwwidthRole:
        return airport->getRwwidth();
    case Roles::FreqRole:
        return airport->getFreq();
    case Roles::DescRole:
        return airport->getDesc();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> AirportModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Roles::NameRole] = "name";
    roles[Roles::CodeRole] = "code";
    roles[Roles::CountryRole] = "country";
    roles[Roles::PositionRole] = "position";
    roles[Roles::ElevationRole] = "elevation";
    roles[Roles::StyleRole] = "style";
    roles[Roles::RwdirRole] = "rwdir";
    roles[Roles::RwlenRole] = "rwlen";
    roles[Roles::RwwidthRole] = "rwwidth";
    roles[Roles::FreqRole] = "freq";
    roles[Roles::DescRole] = "desc";
    return roles;
}

Airport *AirportModel::createAirportFromLine(const QString &line)
{
    QStringList fields = line.split(',');

    if (fields.size() < 12) {
        qWarning() << "Invalid line format:" << line;
        return nullptr;
    }

    QString name = fields[0].remove('"');
    QString code = fields[1].remove('"');
    QString country = fields[2].remove('"');
    QString lat = fields[3].remove('"');
    QString lon = fields[4].remove('"');
    QString elev = fields[5].remove('"');
    int style = fields[6].toInt();
    int rwdir = fields[7].toInt();
    QString rwlen = fields[8].remove('"');
    QString rwwidth = fields[9].remove('"');
    QString freq = fields[10].remove('"');
    QString desc = fields[11].remove('"');

    addAvailableStyle(style);

    return new Airport(name, code, country, lat, lon, elev, style, rwdir, rwlen, rwwidth, freq, desc, this);
}

void AirportModel::importAirportsFromCup(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Unable to open file:" << filePath;
        return;
    }

    QTextStream in(&file);
    in.readLine(); //skip first with description
    while (!in.atEnd()) {
        QString line = in.readLine();
        if (line.isEmpty()) continue;

        Airport *airport = createAirportFromLine(line);
        if (airport) {
            airports.append(airport);
        }
    }

    emit airportsChanged();
    emit sizeChanged();
}

void AirportModel::importAirportsFromDir(const QDir &dir)
{
    QStringList filters;
    filters << "*.cup";
    QFileInfoList fileInfoList = dir.entryInfoList(filters, QDir::Files);

    foreach (const QFileInfo& fileInfo, fileInfoList) {
        importAirportsFromCup(fileInfo.absoluteFilePath());
    }
}

void AirportModel::relaodAirports(const QDir &dir)
{
    foreach (Airport *airport, airports) {
        airport->deleteLater();
    }
    airports.clear();
    emit airportsChanged();
    importAirportsFromDir(dir);
}

QList<int> AirportModel::getAvailableStyles() const
{
    return availableStyles;
}

void AirportModel::setAvailableStyles(const QList<int> &newAvailableStyles)
{
    if (availableStyles == newAvailableStyles)
        return;
    availableStyles = newAvailableStyles;
    std::sort(availableStyles.begin(), availableStyles.end());
    emit availableStylesChanged();
}

void AirportModel::addAvailableStyle(int style)
{
    if(availableStyles.contains(style)) return;
    availableStyles.append(style);
    std::sort(availableStyles.begin(), availableStyles.end());
    emit availableStylesChanged();
}
