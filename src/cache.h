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
#ifndef CACHE_H
#define CACHE_H

#include <QObject>
#include <QVariant>

class Cache : public QObject
{
    Q_OBJECT
    Q_PROPERTY (QVariant content READ content WRITE setContent NOTIFY contentChanged)
public:
    explicit Cache(QString cacheFilePath, QObject *parent = 0);

    Q_INVOKABLE bool load();
    Q_INVOKABLE bool save();

    QVariant content() const { return m_content; }
    void setContent(QVariant val) { m_content = val; emit contentChanged(val); }

private:
    QString getDefaultCacheContent();
    QString getCacheContent();

    QString m_cacheFilePath;
    QString m_cacheFilename;
    QVariant m_content;

signals:
    void contentChanged(QVariant newValue);

public slots:
};

#endif // CACHE_H
