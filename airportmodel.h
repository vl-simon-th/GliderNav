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

    QList<int> getAvailableStyles() const;
    void setAvailableStyles(const QList<int> &newAvailableStyles);
    Q_INVOKABLE void addAvailableStyle(int style);

signals:
    void airportsChanged();
    void sizeChanged();

    void availableStylesChanged();

private:
    QList<Airport *> airports;
    QList<int> availableStyles;
    Q_PROPERTY(QList<int> availableStyles READ getAvailableStyles WRITE setAvailableStyles NOTIFY availableStylesChanged FINAL)
};

#endif // AIRPORTMODEL_H
