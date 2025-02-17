#ifndef TASK_H
#define TASK_H

#include <QObject>
#include <QQmlEngine>

#include <QList>
#include <QGeoCoordinate>

#include <QString>

class Task : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit Task(QObject *parent = nullptr);

    QList<QGeoCoordinate> getTurnPoints() const;
    void setTurnPoints(const QList<QGeoCoordinate> &newTurnPoints);

    QString getName() const;
    void setName(const QString &newName);

    QList<double> getDistancesToPoint() const;
    void setDistancesToPoint(const QList<double> &newDistancesToPoint);

    Q_INVOKABLE void addTurnPoint(const QGeoCoordinate &newTurnPoint, const double &distance);
    Q_INVOKABLE void removeTurnPoint(const int &index);

    Q_INVOKABLE double calculateDistance();

signals:

    void turnPointsChanged();
    void distancesToPointChanged();

    void nameChanged();

private:
    QString name;
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged FINAL)

    QList<QGeoCoordinate> turnPoints;
    QList<double> distancesToPoint;

    Q_PROPERTY(QList<QGeoCoordinate> turnPoints READ getTurnPoints WRITE setTurnPoints NOTIFY turnPointsChanged FINAL)
    Q_PROPERTY(QList<double> distancesToPoint READ getDistancesToPoint WRITE setDistancesToPoint NOTIFY distancesToPointChanged FINAL)
};

#endif // TASK_H
