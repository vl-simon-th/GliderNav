#include "airport.h"

Airport::Airport(QObject *parent)
    : QObject {parent}
{
}

Airport::Airport(const QString& name, const QString& code, const QString& country,
                 const QString& lat, const QString& lon, const QString& elev,
                 int style, int rwdir, const QString& rwlen, const QString& rwwidth,
                 const QString& freq, const QString& desc, QObject *parent)
    : QObject{parent}, name(name), code(code), country(country),
    elevation(parseElevation(elev)),
    position(parseCoordinate(lat, lon, parseElevation(elev))),
    style(style), rwdir(rwdir), rwlen(parseLength(rwlen)),
    rwwidth(parseLength(rwwidth)), freq(freq), desc(desc)
{
}

QString Airport::getName() const { return name; }
void Airport::setName(const QString& name) {
    if (this->name != name) {
        this->name = name;
        emit nameChanged();
    }
}

QString Airport::getCode() const { return code; }
void Airport::setCode(const QString& code) {
    if (this->code != code) {
        this->code = code;
        emit codeChanged();
    }
}

QString Airport::getCountry() const { return country; }
void Airport::setCountry(const QString& country) {
    if (this->country != country) {
        this->country = country;
        emit countryChanged();
    }
}

QGeoCoordinate Airport::getPosition() const { return position; }
void Airport::setPosition(const QGeoCoordinate& position) {
    if (this->position != position) {
        this->position = position;
        emit positionChanged();
    }
}

double Airport::getElevation() const { return elevation; }
void Airport::setElevation(double elevation) {
    if (this->elevation != elevation) {
        this->elevation = elevation;
        emit elevationChanged();
    }
}

int Airport::getStyle() const { return style; }
void Airport::setStyle(int style) {
    if (this->style != style) {
        this->style = style;
        emit styleChanged();
    }
}

int Airport::getRwdir() const { return rwdir; }
void Airport::setRwdir(int rwdir) {
    if (this->rwdir != rwdir) {
        this->rwdir = rwdir;
        emit rwdirChanged();
    }
}

double Airport::getRwlen() const { return rwlen; }
void Airport::setRwlen(double rwlen) {
    if (this->rwlen != rwlen) {
        this->rwlen = rwlen;
        emit rwlenChanged();
    }
}

double Airport::getRwwidth() const { return rwwidth; }
void Airport::setRwwidth(double rwwidth) {
    if (this->rwwidth != rwwidth) {
        this->rwwidth = rwwidth;
        emit rwwidthChanged();
    }
}

QString Airport::getFreq() const { return freq; }
void Airport::setFreq(const QString& freq) {
    if (this->freq != freq) {
        this->freq = freq;
        emit freqChanged();
    }
}

QString Airport::getDesc() const { return desc; }
void Airport::setDesc(const QString& desc) {
    if (this->desc != desc) {
        this->desc = desc;
        emit descChanged();
    }
}

bool Airport::operator==(const Airport &o)
{
    return position == o.getPosition();
}

QGeoCoordinate Airport::parseCoordinate(const QString& lat, const QString& lon, double elevation) const
{
    bool latPositive = lat.endsWith('N');
    bool lonPositive = lon.endsWith('E');

    QString latStr = lat.first(lat.length() - 1);
    QString lonStr = lon.first(lon.length() - 1);

    if(latStr.length() < 8 || lonStr.length() < 9) {
        return QGeoCoordinate();
    }

    double latDegrees = latStr.first(2).toDouble();
    double latMinutes = latStr.sliced(2).toDouble();
    double lonDegrees = lonStr.first(3).toDouble();
    double lonMinutes = lonStr.sliced(3).toDouble();

    double latitude = latDegrees + latMinutes / 60.0;
    double longitude = lonDegrees + lonMinutes / 60.0;

    if (!latPositive)
        latitude = -latitude;
    if (!lonPositive)
        longitude = -longitude;

    return QGeoCoordinate(latitude, longitude, elevation);
}

double Airport::parseLength(const QString& length) const
{
    if (length.endsWith("m"))
        return length.first(length.length() - 1).toDouble();
    return 0.0;
}

double Airport::parseElevation(const QString& elev) const
{
    if (elev.endsWith("m"))
        return elev.first(elev.length() - 1).toDouble();
    return 0.0;
}
