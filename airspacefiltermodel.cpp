#include "airspacefiltermodel.h"
#include "roles.h"

AirspaceFilterModel::AirspaceFilterModel(QObject *parent)
    : QSortFilterProxyModel{parent}
{}

bool AirspaceFilterModel::validTypesContains(const QString &type)
{
    return validTypes.contains(type);
}

void AirspaceFilterModel::updateValidTypes(const QString &type, bool show)
{
    if(show) {
        validTypes.insert(type);
    } else {
        validTypes.remove(type);
    }
    invalidateFilter();
}

void AirspaceFilterModel::updateViewArea(const QGeoShape &newViewArea)
{
    viewArea = newViewArea;
    viewAreaBoundingRect = viewArea.boundingGeoRectangle();
    invalidateFilter();
}

void AirspaceFilterModel::updateZoomLevel(const double &newZoomLevel)
{
    zoomLevel = newZoomLevel;
    invalidateFilter();
}

bool AirspaceFilterModel::filterAcceptsRow(int row, const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    const QModelIndex idx = sourceModel()->index(row, 0, parent);

    if(zoomLevel < 7) return false;

    QString type = idx.data(Roles::TypeRole).value<QString>();
    if(!validTypes.contains(type)) return false;

    QGeoRectangle asBoundingRect = idx.data(Roles::GeoBoundingRect).value<QGeoRectangle>();

    return asBoundingRect.intersects(viewAreaBoundingRect);
}
