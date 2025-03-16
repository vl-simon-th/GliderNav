#ifndef FLIGHTLOGMODEL_H
#define FLIGHTLOGMODEL_H

#include <QAbstractListModel>

class FlightLogModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit FlightLogModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
};

#endif // FLIGHTLOGMODEL_H
