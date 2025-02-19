#ifndef AIRSPACEFILTERMODEL_H
#define AIRSPACEFILTERMODEL_H

#include <QQmlEngine>
#include <QSortFilterProxyModel>

#include <QList>
#include <QGeoCoordinate>
#include <QGeoPolygon>
#include <QGeoRectangle>
#include <QGeoShape>

class AirspaceFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit AirspaceFilterModel(QObject *parent = nullptr);

public slots:
    void updateViewArea(const QGeoShape &newViewArea);
    void updateZoomLevel(const double &newZoomLevel);

protected:
    bool filterAcceptsRow(int row, const QModelIndex &parent) const override;

private:
    QGeoShape viewArea;
    QGeoRectangle viewAreaBoundingRect;
    double zoomLevel;
};

#endif // AIRSPACEFILTERMODEL_H
