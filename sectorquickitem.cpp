#include "sectorquickitem.h"

SectorQuickItem::SectorQuickItem(QQuickItem *parent)
    :QQuickPaintedItem(parent)
{}

int SectorQuickItem::getAngle() const
{
    return angle;
}

void SectorQuickItem::setAngle(int newAngle)
{
    if (angle == newAngle)
        return;
    angle = newAngle;
    update();
    emit angleChanged();
}

int SectorQuickItem::getStartAngle() const
{
    return startAngle;
}

void SectorQuickItem::setStartAngle(int newStartAngle)
{
    if (startAngle == newStartAngle)
        return;
    update();
    startAngle = newStartAngle;
    emit startAngleChanged();
}


QColor SectorQuickItem::getColor() const
{
    return color;
}

void SectorQuickItem::setColor(const QColor &newColor)
{
    if (color == newColor)
        return;
    color = newColor;
    update();
    emit colorChanged();
}

int SectorQuickItem::getBorderWidth() const
{
    return borderWidth;
}

void SectorQuickItem::setBorderWidth(int newBorderWidth)
{
    if (borderWidth == newBorderWidth)
        return;
    borderWidth = newBorderWidth;
    update();
    emit widthChanged();
}

void SectorQuickItem::paint(QPainter *painter)
{
    QPen pen(color, borderWidth);
    painter->setPen(pen);
    painter->setRenderHints(QPainter::Antialiasing, true);
    painter->drawPie(boundingRect().adjusted(1, 1, -1, -1), startAngle, angle);
}

const QList<QGeoCoordinate> &SectorQuickItem::getCoordinates() const
{
    return coordinates;
}

void SectorQuickItem::setCoordinates(const QList<QGeoCoordinate> &newCoordinates)
{
    if (coordinates == newCoordinates)
        return;
    coordinates = newCoordinates;

    double deg = coordinates[1].azimuthTo(coordinates[0]) - coordinates[1].azimuthTo(coordinates[2]);
    if(deg > 180) deg = -(360-deg);
    if(deg < -180) deg = 360+deg;

    angle = deg * 16;
    emit angleChanged();

    startAngle = (90.0 - coordinates[0].azimuthTo(coordinates[1])) * 16;
    emit startAngleChanged();

    update();
    emit coordinatesChanged();
}
