 #ifndef TASK_H
#define TASK_H

#include <QObject>
#include <QQmlEngine>

#include <QList>
#include <QGeoCoordinate>

#include <QString>

#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>

#include <QDir>
#include <QStandardPaths>

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

    const QList<QGeoCoordinate> &getTurnPoints() const;
    void setTurnPoints(const QList<QGeoCoordinate> &newTurnPoints);

    QString getName() const;
    void setName(const QString &newName);

    const QList<double> &getDistancesToPoint() const;
    void setDistancesToPoint(const QList<double> &newDistancesToPoint);

    Q_INVOKABLE void addTurnPoint(const QGeoCoordinate &newTurnPoint, const double &distance);
    Q_INVOKABLE void removeTurnPoint(const QGeoCoordinate &turnPoint);

    Q_INVOKABLE double calculateDistance();

    TaskType getTaskType() const;
    void setTaskType(TaskType newTaskType);

    Q_INVOKABLE void writeToDir();
    Q_INVOKABLE void deleteDir();
    static Task *readFromDir(const QDir &dir);

    double getLength() const;
    void setLength(double newLength);

signals:

    void turnPointsChanged();
    void distancesToPointChanged();

    void nameChanged();

    void taskTypeChanged();

    void lengthChanged();

public slots:
    void calcLength();

private:
    QString name;
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged FINAL)

    QList<QGeoCoordinate> turnPoints;
    QList<double> distancesToPoint;

    Q_PROPERTY(QList<QGeoCoordinate> turnPoints READ getTurnPoints WRITE setTurnPoints NOTIFY turnPointsChanged FINAL)
    Q_PROPERTY(QList<double> distancesToPoint READ getDistancesToPoint WRITE setDistancesToPoint NOTIFY distancesToPointChanged FINAL)

    double length = 0;

    TaskType taskType;
    Q_PROPERTY(TaskType taskType READ getTaskType WRITE setTaskType NOTIFY taskTypeChanged FINAL)
    Q_PROPERTY(double length READ getLength WRITE setLength NOTIFY lengthChanged FINAL)
};

#endif // TASK_H
