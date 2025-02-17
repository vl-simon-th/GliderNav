#ifndef AIRPORT_H
#define AIRPORT_H

#include <QObject>
#include <QQmlEngine>
#include <QGeoCoordinate>

class Airport : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString code READ getCode WRITE setCode NOTIFY codeChanged)
    Q_PROPERTY(QString country READ getCountry WRITE setCountry NOTIFY countryChanged)
    Q_PROPERTY(QGeoCoordinate position READ getPosition WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(double elevation READ getElevation WRITE setElevation NOTIFY elevationChanged)
    Q_PROPERTY(int style READ getStyle WRITE setStyle NOTIFY styleChanged)
    Q_PROPERTY(int rwdir READ getRwdir WRITE setRwdir NOTIFY rwdirChanged)
    Q_PROPERTY(double rwlen READ getRwlen WRITE setRwlen NOTIFY rwlenChanged)
    Q_PROPERTY(double rwwidth READ getRwwidth WRITE setRwwidth NOTIFY rwwidthChanged)
    Q_PROPERTY(QString freq READ getFreq WRITE setFreq NOTIFY freqChanged)
    Q_PROPERTY(QString desc READ getDesc WRITE setDesc NOTIFY descChanged)
    QML_ELEMENT

public:
    Airport(QObject *parent = nullptr);
    Airport(const QString& name, const QString& code, const QString& country,
            const QString& lat, const QString& lon, const QString& elev,
            int style, int rwdir, const QString& rwlen, const QString& rwwidth,
            const QString& freq, const QString& desc, QObject *parent = nullptr);

    QString getName() const;
    void setName(const QString& name);

    QString getCode() const;
    void setCode(const QString& code);

    QString getCountry() const;
    void setCountry(const QString& country);

    QGeoCoordinate getPosition() const;
    void setPosition(const QGeoCoordinate& position);

    double getElevation() const;
    void setElevation(double elevation);

    int getStyle() const;
    void setStyle(int style);

    int getRwdir() const;
    void setRwdir(int rwdir);

    double getRwlen() const;
    void setRwlen(double rwlen);

    double getRwwidth() const;
    void setRwwidth(double rwwidth);

    QString getFreq() const;
    void setFreq(const QString& freq);

    QString getDesc() const;
    void setDesc(const QString& desc);

    bool operator==(const Airport &o);

signals:
    void nameChanged();
    void codeChanged();
    void countryChanged();
    void positionChanged();
    void elevationChanged();
    void styleChanged();
    void rwdirChanged();
    void rwlenChanged();
    void rwwidthChanged();
    void freqChanged();
    void descChanged();

private:
    QString name;
    QString code;
    QString country;
    QGeoCoordinate position;
    double elevation;
    int style;
    int rwdir;
    double rwlen;
    double rwwidth;
    QString freq;
    QString desc;

    QGeoCoordinate parseCoordinate(const QString& lat, const QString& lon, double elevation) const;
    double parseLength(const QString& length) const;
    double parseElevation(const QString& elevation) const;
};

#endif // AIRPORT_H
