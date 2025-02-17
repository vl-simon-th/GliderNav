#ifndef TASKSLIST_H
#define TASKSLIST_H

#include <QObject>
#include <QQmlEngine>

#include <QList>

#include "task.h"

class TasksList : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit TasksList(QObject *parent = nullptr);

    QList<Task *> getTasks() const;
    void setTasks(const QList<Task *> &newTasks);
    Q_INVOKABLE void addTask(Task *newTask);
    Q_INVOKABLE void removeTask(Task *task);

signals:

    void tasksChanged();

private:
    QList<Task *> tasks;
    Q_PROPERTY(QList<Task *> tasks READ getTasks WRITE setTasks NOTIFY tasksChanged FINAL)
};

#endif // TASKSLIST_H
