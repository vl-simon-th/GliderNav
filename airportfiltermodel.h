#ifndef AIRPORTFILTERMODEL_H
#define AIRPORTFILTERMODEL_H

#include <QQmlEngine>
#include <QSortFilterProxyModel>

#include <QGeoCoordinate>
#include <QGeoPolygon>

#include <QList>

class AirportFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit AirportFilterModel(QObject *parent = nullptr);

public slots:
    void updateValidStyle(const QList<int> &newValidStyles);
    void updateViewArea(const QGeoShape &newViewArea);
    void updateZoomLevel(const double &newZoomLevel);

protected:
    bool filterAcceptsRow(int row, const QModelIndex &parent) const override;

private:
    QList<int> validStyles = {2,4,5};
    QGeoShape viewArea;
    double zoomLevel;
};

#endif // AIRPORTFILTERMODEL_H
