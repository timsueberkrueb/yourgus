/*
 * This file is part of YourGUS
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

#include "cache.h"
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QJSValue>

Cache::Cache(QString cacheFilePath, QObject *parent) : QObject(parent){
    m_cacheFilePath = cacheFilePath;
    m_cacheFilename = cacheFilePath + "yourgus-cache.json";

    if (!QDir(m_cacheFilePath).exists())
        QDir().mkdir(m_cacheFilePath);

    QFileInfo checkFile(m_cacheFilename);
    if (!checkFile.exists() || !checkFile.isFile()) {
        qDebug() << "Cache file does not exist. Creating default file at " << m_cacheFilePath;
        QFile file( m_cacheFilename );
        if ( file.open(QIODevice::ReadWrite) )
        {
            QTextStream stream( &file );
            stream << getDefaultCacheContent() << endl;
        }
    }

}

bool Cache::load()
{
    QFile cacheFile(m_cacheFilename);

    if (!cacheFile.open(QIODevice::ReadOnly)) {
        qWarning("Could not open cache file.");
        return false;
    }

    QByteArray jsonByteData = cacheFile.readAll();
    QJsonDocument doc (QJsonDocument::fromJson(jsonByteData));

    auto json = doc.object();
    QJsonObject jsonData = json["data"].toObject();
    QJsonDocument contentDoc(jsonData);
    setContent(contentDoc.toVariant());

    return true;
}

bool Cache::save()
{
    QFile file( m_cacheFilename );
    if ( !file.open(QIODevice::ReadWrite) ) {
        qWarning("Could not open cache file.");
        return false;
    }
    QTextStream stream( &file );
    stream << getCacheContent() << endl;
    return true;
}

QString Cache::getDefaultCacheContent() {
    QJsonObject data {};
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

QString Cache::getCacheContent(){
    QJsonDocument contentDoc (QJsonDocument::fromVariant(content().value<QJSValue>().toVariant()));
    QJsonObject data = contentDoc.object();
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
