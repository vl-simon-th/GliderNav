#ifndef AIRSPACEFILTERMODEL_H
#define AIRSPACEFILTERMODEL_H

#include <QQmlEngine>
#include <QSortFilterProxyModel>

#include <QSet>
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

    Q_INVOKABLE bool validTypesContains(const QString &type);

public slots:
    void updateValidTypes(const QString &type, bool show);
    void updateViewArea(const QGeoShape &newViewArea);
    void updateZoomLevel(const double &newZoomLevel);

protected:
    bool filterAcceptsRow(int row, const QModelIndex &parent) const override;

private:
    QSet<QString> validTypes = {"C", "D", "CTR", "R", "RMZ", "TMZ"};
    QGeoShape viewArea;
    QGeoRectangle viewAreaBoundingRect;
    double zoomLevel;
};

#endif // AIRSPACEFILTERMODEL_H
