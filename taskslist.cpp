#include "taskslist.h"

TasksList::TasksList(QObject *parent)
    : QObject{parent}
{}

QList<Task *> TasksList::getTasks() const
{
    return tasks;
}

void TasksList::setTasks(const QList<Task *> &newTasks)
{
    if (tasks == newTasks)
        return;
    tasks = newTasks;
    emit tasksChanged();
}

void TasksList::addTask(Task *newTask)
{
    tasks.append(newTask);
    emit tasksChanged();
}

void TasksList::removeTask(Task *task)
{
    if(!tasks.contains(task)) return;
    tasks.removeAll(task);
    task->deleteLater();
    emit tasksChanged();
}
