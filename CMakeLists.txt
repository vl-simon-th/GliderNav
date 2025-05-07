cmake_minimum_required(VERSION 3.18)

project(GliderNav VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml QuickControls2 Quick Location Positioning Network Svg)

set(MACOSX_BUNDLE_ICON_FILE GliderNavV4.icns)

set(app_icon_macos "${CMAKE_CURRENT_SOURCE_DIR}/appIcons/GliderNavV4.icns")
set_source_files_properties(${app_icon_macos} PROPERTIES
    MACOSX_PACKAGE_LOCATION "Resources")

qt_add_executable(GliderNav
   MACOSX_BUNDLE main.cpp ${app_icon_macos}
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(GliderNav PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER com.vision-lines.glidernav
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist"
    XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS "${CMAKE_CURRENT_SOURCE_DIR}/GliderNav.entitlements"
    XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME AppIcon
    QT_IOS_LAUNCH_SCREEN "${CMAKE_CURRENT_SOURCE_DIR}/ios/LaunchScreen.storyboard" 

    WIN32_EXECUTABLE TRUE
)

target_link_libraries(GliderNav PUBLIC
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::QuickControls2

    Qt${QT_VERSION_MAJOR}::Location
    Qt${QT_VERSION_MAJOR}::Positioning
    Qt${QT_VERSION_MAJOR}::Network
    Qt${QT_VERSION_MAJOR}::Svg
)

set_source_files_properties(AppSettings.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

set_source_files_properties(MapSourceModel.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_resources(GliderNav "configuration"
    PREFIX "/"
    FILES
        qtquickcontrols2.conf
)

if(IOS)
    list(APPEND OBJC_SOURCES
        iostools.h
        iostools.mm
    )
endif()

qt_add_qml_module(GliderNav
    URI GliderNav
    VERSION 1.0
    QML_FILES
        main.qml
        MovingMap.qml
        TasksView.qml
        LogsView.qml
        AirMap.qml
        SettingsView.qml
        TaskEditView.qml
        AppSettings.qml
        AirportMenu.qml
        MapSourceModel.qml

        AptAsMenuSection.qml

    RESOURCES
        icons/aeroplane-1.svg
        icons/angle-double-down.svg
        icons/angle-double-right.svg
        icons/arrow-downward.svg
        icons/arrow-left-circle.svg
        icons/arrow-upward.svg
        icons/check-circle-1.svg
        icons/clipboard.svg
        icons/cloud-download.svg
        icons/eye.svg
        icons/gear-1.svg

        icons/glider.svg

        icons/layout-26.svg
        icons/location-arrow-right.svg
        icons/map-marker-1.svg
        icons/pencil-1.svg
        icons/play.svg
        icons/plus.svg
        icons/refresh-circle-1-clockwise.svg
        icons/route-1.svg
        icons/share-2.svg
        icons/stopwatch.svg
        icons/trash-3.svg
        icons/xmark-circle.svg

    SOURCES task.h task.cpp
    SOURCES taskslist.h taskslist.cpp
    SOURCES controller.h controller.cpp
    SOURCES flightlog.h flightlog.cpp
    SOURCES flightloglist.h flightloglist.cpp
    SOURCES flightlogmodel.h flightlogmodel.cpp
    SOURCES airport.h airport.cpp
    SOURCES airspace.h airspace.cpp
    SOURCES airportmodel.h airportmodel.cpp
    SOURCES airspacemodel.h airspacemodel.cpp
    SOURCES airportfiltermodel.h airportfiltermodel.cpp
    SOURCES roles.h
    SOURCES airspacefiltermodel.h airspacefiltermodel.cpp
    SOURCES sectorquickitem.h sectorquickitem.cpp

    NO_RESOURCE_TARGET_PATH

    SOURCES
        ${OBJC_SOURCES}
    QML_FILES AptAsDataDownloadView.qml
    QML_FILES AptAsOptionsView.qml
    QML_FILES TurnpointDialog.qml
)

set_property(GLOBAL PROPERTY XCODE_EMIT_EFFECTIVE_PLATFORM_NAME ON)

if(IOS)
    set(asset_catalog_path "ios/Assets.xcassets")
    target_sources(GliderNav PRIVATE "${asset_catalog_path}")
    set_source_files_properties(${asset_catalog_path} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
endif()

#include(GNUInstallDirs)
install(TARGETS GliderNav
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

qt_generate_deploy_qml_app_script(
    TARGET ${PROJECT_NAME}
    OUTPUT_SCRIPT deploy_script
    MACOS_BUNDLE_POST_BUILD
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
)
install(SCRIPT ${deploy_script})
