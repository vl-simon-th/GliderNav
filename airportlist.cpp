#include "airportlist.h"

AirportList::AirportList(QObject *parent)
    : QObject{parent}
{}

QList<Airport *> AirportList::getAirports() const
{
    return airports;
}

void AirportList::setAirports(const QList<Airport *> &newAirports)
{
    airports = newAirports;
    emit airportsChanged();
}

void AirportList::addAirport(Airport *newAirport)
{
    airports.append(newAirport);
    emit airportsChanged();
}

void AirportList::removeAirport(Airport *airport)
{
    airports.removeAll(airport);
    delete airport;
    emit airportsChanged();
}

Airport *AirportList::createAirportFromLine(const QString &line)
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

    return new Airport(name, code, country, lat, lon, elev, style, rwdir, rwlen, rwwidth, freq, desc);
}

void AirportList::importAirportsFromCup(const QString &filePath)
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
}

void AirportList::importAirportsFromDir(const QDir &dir)
{
    QStringList filters;
    filters << "*.cup";
    QFileInfoList fileInfoList = dir.entryInfoList(filters, QDir::Files);

    foreach (const QFileInfo& fileInfo, fileInfoList) {
        importAirportsFromCup(fileInfo.absoluteFilePath());
    }
}
