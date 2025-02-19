#ifndef TASK_H
#define TASK_H

#include <QObject>
#include <QQmlEngine>

#include <QList>
#include <QGeoCoordinate>

#include <QString>

enum class TaskType {
    RT,
    AAT
};

class Task : public QObject
{
    Q_ENUM(TaskType)

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
    Q_INVOKABLE void removeTurnPoint(const QGeoCoordinate &turnPoint);

    Q_INVOKABLE double calculateDistance();

    TaskType getTaskType() const;
    void setTaskType(TaskType newTaskType);

signals:

    void turnPointsChanged();
    void distancesToPointChanged();

    void nameChanged();

    void taskTypeChanged();

private:
    QString name;
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged FINAL)

    QList<QGeoCoordinate> turnPoints;
    QList<double> distancesToPoint;

    Q_PROPERTY(QList<QGeoCoordinate> turnPoints READ getTurnPoints WRITE setTurnPoints NOTIFY turnPointsChanged FINAL)
    Q_PROPERTY(QList<double> distancesToPoint READ getDistancesToPoint WRITE setDistancesToPoint NOTIFY distancesToPointChanged FINAL)

    TaskType taskType;
    Q_PROPERTY(TaskType taskType READ getTaskType WRITE setTaskType NOTIFY taskTypeChanged FINAL)
};

#endif // TASK_H
