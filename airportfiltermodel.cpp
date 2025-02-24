#include "airportfiltermodel.h"

#include "roles.h"

AirportFilterModel::AirportFilterModel(QObject *parent)
    : QSortFilterProxyModel{parent}
{
}

bool AirportFilterModel::validStylesContains(int style)
{
    return validStyles.contains(style);
}

void AirportFilterModel::updateValidStyle(int style, bool show)
{
    if(show) {
        validStyles.insert(style);
    } else {
        validStyles.remove(style);
    }
    invalidateFilter();
}

void AirportFilterModel::updateViewArea(const QGeoShape &newViewArea)
{
    viewArea = newViewArea;
    invalidateFilter();
}

void AirportFilterModel::updateZoomLevel(const double &newZoomLevel)
{
    zoomLevel = newZoomLevel;
    invalidateFilter();
}

bool AirportFilterModel::filterAcceptsRow(int row, const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    const QModelIndex idx = sourceModel()->index(row, 0, parent);

    if(zoomLevel < 8) return false;

    int style = idx.data(Roles::StyleRole).value<int>();
    if(!validStyles.contains(style)) return false;

    QGeoCoordinate pos = idx.data(Roles::PositionRole).value<QGeoCoordinate>();

    return viewArea.contains(pos);
}
