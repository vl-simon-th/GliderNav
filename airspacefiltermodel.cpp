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

    //check if visible possible
    if(!asBoundingRect.intersects(viewAreaBoundingRect))
        return false;


    //check if actually visible
    bool pathIntersectsViewArea = false;

    QList<QGeoCoordinate> coords = idx.data(Roles::CoordinatesRole).value<QList<QGeoCoordinate>>();
    foreach(QGeoCoordinate p, coords) {
        if(viewAreaBoundingRect.contains(p)) {
            pathIntersectsViewArea = true;
            break;
        }
    }

    int i = 0;
    while (!pathIntersectsViewArea && i < coords.length() - 1) {
        bool c1Top = coords[i].latitude() > viewAreaBoundingRect.topLeft().latitude();
        bool c1Bottom = coords[i].latitude() < viewAreaBoundingRect.bottomRight().latitude();
        bool c1Right = coords[i].longitude() > viewAreaBoundingRect.bottomRight().longitude();
        bool c1Left = coords[i].longitude() < viewAreaBoundingRect.topLeft().longitude();

        bool c2Top = coords[i + 1].latitude() > viewAreaBoundingRect.topLeft().latitude();
        bool c2Bottom = coords[i + 1].latitude() < viewAreaBoundingRect.bottomRight().latitude();
        bool c2Right = coords[i + 1].longitude() > viewAreaBoundingRect.bottomRight().longitude();
        bool c2Left = coords[i + 1].longitude() < viewAreaBoundingRect.topLeft().longitude();

        if ((c1Top && !c2Top && !(c1Right && c2Right) && !(c1Left && c2Left)) ||
            (c1Right && !c2Right && !(c1Top && c2Top) && !(c1Bottom && c2Bottom)) ||
            (c1Bottom && !c2Bottom && !(c1Right && c2Right) && !(c1Left && c2Left)) ||
            (c1Left && !c2Left && !(c1Top && c2Top) && !(c1Bottom && c2Bottom))) {
            pathIntersectsViewArea = true;
        }

        i++;
    }

    return pathIntersectsViewArea;
}
