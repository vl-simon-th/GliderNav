#ifndef AIRPORTMODEL_H
#define AIRPORTMODEL_H

#include <QAbstractListModel>
#include <QQmlEngine>

#include <QList>
#include "airport.h"

#include <QDir>
#include <QString>

class AirportModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int size READ rowCount NOTIFY sizeChanged)
    QML_ELEMENT

public:
    explicit AirportModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE Airport *createAirportFromLine(const QString &line);
    Q_INVOKABLE void importAirportsFromCup(const QString &filePath);
    Q_INVOKABLE void importAirportsFromDir(const QDir &dir);

    Q_INVOKABLE void relaodAirports(const QDir &dir);

signals:
    void airportsChanged();
    void sizeChanged();

private:
    QList<Airport *> airports;
};

#endif // AIRPORTMODEL_H
