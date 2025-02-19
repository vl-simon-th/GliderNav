#ifndef AIRSPACEMODEL_H
#define AIRSPACEMODEL_H

#include <QAbstractListModel>
#include <QQmlEngine>
#include <QList>
#include <QDir>
#include "airspace.h"

#include <QFile>
#include <QTextStream>

class AirspaceModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int size READ rowCount NOTIFY sizeChanged)
    QML_ELEMENT

public:
    explicit AirspaceModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE Airspace *createAirspaceFromLine(const QString &line);
    Q_INVOKABLE void importAirspacesFromFile(const QString &filePath);
    Q_INVOKABLE void importAirspacesFromDir(const QDir &dir);

signals:
    void airspacesChanged();
    void sizeChanged();

private:
    QList<Airspace *> airspaces;
};

#endif // AIRSPACEMODEL_H
