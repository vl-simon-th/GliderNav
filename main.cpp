#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml/qqmlextensionplugin.h>
#include <QtQuickControls2/qquickstyle.h>

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setAttribute(Qt::AA_QtQuickUseDefaultSizePolicy);

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/main.qml"_s);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.addImportPath(":/");

    engine.load(url);
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
