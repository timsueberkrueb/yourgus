/*
 * This file is part of the YourGUS
 * Copyright (C) 2016 Tim Süberkrüb (https://github.com/tim-sueberkrueb)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#ifdef USE_DEFAULT_QT_WEBVIEW
#include <QtWebView>
#endif
#include <QQmlContext>
#include <QStandardPaths>
#include "settings.h"
#include "cache.h"
#include <QtGlobal>
#include <QDebug>
const QString VERSION = "0.1";
const QString COPYRIGHT = "Copyright (C) 2016 by Tim Süberkrüb";

#ifdef Q_OS_ANDROID
const QString APP_FOLDER_NAME = "";
const QString CONFIG_FILE_PATH = "";
const QString CACHE_FILE_PATH = "";
#else
const QString APP_FOLDER_NAME = "/yourgus.timsueberkrueb/";
const QString CONFIG_FILE_PATH = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + APP_FOLDER_NAME;
const QString CACHE_FILE_PATH = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + APP_FOLDER_NAME;
#endif
const QString DATA_PATH = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + APP_FOLDER_NAME;


int main(int argc, char *argv[])
{
    // Enable High-DPI support
    #ifdef ENABLE_HIGH_DPI_SCALING
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    #endif
    QGuiApplication app(argc, argv);

    #ifdef USE_DEFAULT_QT_WEBVIEW
    QtWebView::initialize();
    #endif

    QQmlApplicationEngine engine;

    engine.addImportPath(QStringLiteral("qrc:///"));

    Settings settings(CONFIG_FILE_PATH, DATA_PATH);
    Cache cache(CACHE_FILE_PATH);
    engine.rootContext()->setContextProperty("Settings", &settings);
    engine.rootContext()->setContextProperty("Cache", &cache);
    engine.rootContext()->setContextProperty("copyright", COPYRIGHT);
    engine.rootContext()->setContextProperty("version", VERSION);

    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));

    return app.exec();
}
