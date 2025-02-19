#ifndef ROLES_H
#define ROLES_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

namespace Roles {
Q_NAMESPACE
enum AsAptModelRoles {
    NameRole = Qt::UserRole + 1,

    //Airport
    CodeRole,
    CountryRole,
    PositionRole,
    ElevationRole,
    StyleRole,
    RwdirRole,
    RwlenRole,
    RwwidthRole,
    FreqRole,
    DescRole,

    //Airspace
    TypeRole,
    LowerAltitudeRole,
    UpperAltitudeRole,
    LowerAltitudeUnitsRole,
    UpperAltitudeUnitsRole,
    CoordinatesRole,
    GeoBoundingRect
};
Q_ENUM_NS(AsAptModelRoles)
QML_NAMED_ELEMENT(Roles)
}

#endif // ROLES_H
