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
#include "settings.h"
#include <QDebug>
#include <QFile>
#include <QByteArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDir>
#include <QFileInfo>

Settings::Settings(QString configFilePath, QString dataPath, QObject *parent) : QObject(parent){
    m_configFilePath = configFilePath;
    m_configFilename = configFilePath+"yourgus.json";
    m_dataPath = dataPath;

    if (!QDir(m_configFilePath).exists())
        QDir().mkdir(m_configFilePath);

    if (!QDir(m_dataPath).exists())
        QDir().mkdir(m_dataPath);

    QFileInfo checkFile(m_configFilename);
    if (!checkFile.exists() || !checkFile.isFile()) {
        qDebug() << "Config file does not exist. Creating default file at " << m_configFilePath;
        QFile file( m_configFilename );
        if ( file.open(QIODevice::ReadWrite) )
        {
            QTextStream stream( &file );
            stream << getDefaultConfigContent() << endl;
        }
    }
}

bool Settings::load()
{
    QFile configFile(m_configFilename);

    if (!configFile.open(QIODevice::ReadOnly)) {
        qWarning("Could not open config file.");
        return false;
    }

    QByteArray jsonByteData = configFile.readAll();
    QJsonDocument configDoc (QJsonDocument::fromJson(jsonByteData));

    auto json = configDoc.object();
    QJsonObject jsonData = json["data"].toObject();

    setUsername(jsonData["username"].toString());
    setFullname(jsonData["fullname"].toString());
    setAuthtoken(jsonData["authtoken"].toString());
    setConditionsAccepted(jsonData["conditions_accepted"].toBool());

    return true;
}

bool Settings::save()
{
    QFile file( m_configFilename );
    if ( !file.open(QIODevice::ReadWrite) ) {
        qWarning("Could not open config file.");
        return false;
    }
    QTextStream stream( &file );
    stream << getConfigContent() << endl;
    return true;
}

QString Settings::getDefaultConfigContent(){
    QJsonObject data {
        {"username", ""},
        {"fullname", ""},
        {"authtoken", ""},
        {"conditions_accepted", false}
    };
    QJsonObject meta {
        {"schema", "0.1"}
    };
    QJsonObject json {
        {"meta", meta},
        {"data", data}
    };
    QJsonDocument doc(json);
    return doc.toJson();
}

QString Settings::getConfigContent()
{
    QJsonObject data {
        {"username", m_username},
        {"fullname", m_fullname},
        {"authtoken", m_authtoken},
        {"conditions_accepted", m_conditions_accepted}
    };
    QJsonObject meta {
        {"schema", "0.1"}
    };
    QJsonObject json {
        {"meta", meta},
        {"data", data}
    };
    QJsonDocument doc(json);
    return doc.toJson();
}
