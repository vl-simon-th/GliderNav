cmake_minimum_required(VERSION 3.16)

project(GliderNav VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Positioning)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(GliderNav
    main.cpp
)

qt_add_resources(GliderNav "configuration"
    PREFIX "/"
    FILES
        qtquickcontrols2.conf
)

qt_add_qml_module(GliderNav
    URI GliderNav
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES MovingMap.qml
        QML_FILES
        QML_FILES TasksView.qml
        QML_FILES LogsView.qml
        SOURCES task.h task.cpp
        SOURCES taskslist.h taskslist.cpp
        SOURCES controller.h controller.cpp

        RESOURCES
            icons/aeroplane-1.svg
            icons/check-circle-1.svg
            icons/gear-1.svg
            icons/map-marker-1.svg
            icons/pencil-1.svg
            icons/plus.svg
            icons/route-1.svg
            icons/share-2.svg
            icons/stopwatch.svg
            icons/trash-3.svg
            icons/xmark-circle.svg

        SOURCES flightlog.h flightlog.cpp
        QML_FILES TaskEditView.qml
        SOURCES flightloglist.h flightloglist.cpp
        QML_FILES AirMap.qml
        QML_FILES SettingsView.qml
        SOURCES airport.h airport.cpp
        SOURCES airspace.h airspace.cpp
        SOURCES airportlist.h airportlist.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(GliderNav PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appGliderNav
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(GliderNav
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Positioning
)

include(GNUInstallDirs)
install(TARGETS GliderNav
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
