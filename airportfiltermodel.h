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

    Q_INVOKABLE bool validStylesContains(int style);

public slots:
    void updateValidStyle(int style, bool show);
    void updateViewArea(const QGeoShape &newViewArea);
    void updateZoomLevel(const double &newZoomLevel);

protected:
    bool filterAcceptsRow(int row, const QModelIndex &parent) const override;

private:
    QSet<int> validStyles;
    QGeoShape viewArea;
    double zoomLevel;
};

#endif // AIRPORTFILTERMODEL_H
