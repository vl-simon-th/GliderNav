#ifndef FLIGHTLOGMODEL_H
#define FLIGHTLOGMODEL_H

#include <QQmlEngine>
#include <QAbstractListModel>

#include "flightlog.h"

#include <QGeoShape>
#include <QGeoRectangle>
#include <QGeoCoordinate>

#include <QList>

class FlightLogModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit FlightLogModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    FlightLog *getLog() const;
    void setLog(FlightLog *newLog);

public slots:
    void updateViewArea(const QGeoShape &newViewArea);
    void updateModel();

private slots:
    void connectLog();

signals:
    void logChanged();
    void visiblePathChanged();

private:
    FlightLog *log;
    Q_PROPERTY(FlightLog *log READ getLog WRITE setLog NOTIFY logChanged FINAL)

    QList<int> visiblePathIndices;

    QGeoShape viewArea;
};

#endif // FLIGHTLOGMODEL_H
