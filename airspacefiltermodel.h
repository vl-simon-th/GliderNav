#ifndef AIRSPACEFILTERMODEL_H
#define AIRSPACEFILTERMODEL_H

#include <QQmlEngine>
#include <QSortFilterProxyModel>

#include <QList>
#include <QString>
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
    void updateValidTypes(const QList<QString> &newValidTypes);
    void updateViewArea(const QGeoShape &newViewArea);
    void updateZoomLevel(const double &newZoomLevel);

protected:
    bool filterAcceptsRow(int row, const QModelIndex &parent) const override;

private:
    QList<QString> validTypes = {"A", "B", "C", "D", "E", "F"};
    QGeoShape viewArea;
    QGeoRectangle viewAreaBoundingRect;
    double zoomLevel;
};

#endif // AIRSPACEFILTERMODEL_H
