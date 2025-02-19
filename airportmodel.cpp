#include "airportmodel.h"

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
    case AirportNameRole:
        return airport->getName();
    case CodeRole:
        return airport->getCode();
    case CountryRole:
        return airport->getCountry();
    case PositionRole:
        return QVariant::fromValue(airport->getPosition());
    case ElevationRole:
        return airport->getElevation();
    case StyleRole:
        return airport->getStyle();
    case RwdirRole:
        return airport->getRwdir();
    case RwlenRole:
        return airport->getRwlen();
    case RwwidthRole:
        return airport->getRwwidth();
    case FreqRole:
        return airport->getFreq();
    case DescRole:
        return airport->getDesc();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> AirportModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[AirportNameRole] = "name";
    roles[CodeRole] = "code";
    roles[CountryRole] = "country";
    roles[PositionRole] = "position";
    roles[ElevationRole] = "elevation";
    roles[StyleRole] = "style";
    roles[RwdirRole] = "rwdir";
    roles[RwlenRole] = "rwlen";
    roles[RwwidthRole] = "rwwidth";
    roles[FreqRole] = "freq";
    roles[DescRole] = "desc";
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
