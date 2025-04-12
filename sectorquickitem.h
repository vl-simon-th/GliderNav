#ifndef SECTORQUICKITEM_H
#define SECTORQUICKITEM_H

#include <QQuickPaintedItem>
#include <QColor>
#include <QPen>
#include <QPainter>

#include <QList>
#include <QGeoCoordinate>

class SectorQuickItem : public QQuickPaintedItem
{
    Q_OBJECT
    QML_NAMED_ELEMENT(SectorItem)
public:
    SectorQuickItem(QQuickItem *parent = nullptr);

    int getAngle() const;
    void setAngle(int newAngle);

    int getStartAngle() const;
    void setStartAngle(int newStartAngle);

    QColor getColor() const;
    void setColor(const QColor &newColor);

    int getBorderWidth() const;
    void setBorderWidth(int newBorderWidth);

    void paint(QPainter *painter) override;

    const QList<QGeoCoordinate> &getCoordinates() const;
    void setCoordinates(const QList<QGeoCoordinate> &newCoordinates);

signals:
    void angleChanged();
    void colorChanged();
    void startAngleChanged();
    void borderWidthChanged();

    void coordinatesChanged();

private:
    int angle;
    int startAngle;
    QColor color;
    int borderWidth;

    QList<QGeoCoordinate> coordinates;

    Q_PROPERTY(QColor color READ getColor WRITE setColor NOTIFY colorChanged FINAL)
    Q_PROPERTY(int borderWidth READ getBorderWidth WRITE setBorderWidth NOTIFY borderWidthChanged FINAL)
    Q_PROPERTY(QList<QGeoCoordinate> coordinates READ getCoordinates WRITE setCoordinates NOTIFY coordinatesChanged FINAL)
};

#endif // SECTORQUICKITEM_H
