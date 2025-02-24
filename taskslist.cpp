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
    task->deleteDir();
    task->deleteLater();
    emit tasksChanged();
}

void TasksList::writeTasksToDir()
{
    foreach (Task *t, tasks) {
        t->writeToDir();
    }
}

void TasksList::importTasksFromDir()
{
    QDir dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    if (!dir.exists("tasks")) {
        qWarning() << "Logs directory does not exist:" << dir.absoluteFilePath("tasks");
        return;
    }

    dir.cd("tasks");


    // Look for subdirectories within "tasks"
    QFileInfoList subDirs = dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot);
    foreach (const QFileInfo &info, subDirs) {
        QDir subDir(info.absoluteFilePath());
        // Attempt to read a FlightLog from each subdirectory
        Task *task = Task::readFromDir(subDir);
        if (task) {
            tasks.append(task);
            qDebug() << "Imported log from:" << subDir.absolutePath();
        }
    }

    emit tasksChanged();
}


