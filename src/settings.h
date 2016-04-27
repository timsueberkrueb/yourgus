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
#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>


class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY (QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY (QString fullname READ fullname WRITE setFullname NOTIFY fullnameChanged)
    Q_PROPERTY (QString authtoken READ authtoken WRITE setAuthtoken NOTIFY authTokenChanged)
    Q_PROPERTY (bool conditionsAccepted READ conditionsAccepted WRITE setConditionsAccepted NOTIFY conditionsAcceptedChanged)

public:
    explicit Settings(QString configFilePath, QString dataPath, QObject *parent = 0);

    Q_INVOKABLE bool load();
    Q_INVOKABLE bool save();

    QString username() const { return m_username; }
    void setUsername(QString val) { m_username = val; emit usernameChanged(val); }

    QString fullname() const { return m_fullname; }
    void setFullname(QString val) { m_fullname = val; emit fullnameChanged(val); }

    QString authtoken() const { return m_authtoken; }
    void setAuthtoken(QString val) { m_authtoken = val; emit authTokenChanged(val); }

    bool conditionsAccepted() const { return m_conditions_accepted; }
    void setConditionsAccepted(bool val) { m_conditions_accepted = val; emit conditionsAcceptedChanged(val); }

private:
    QString m_configFilePath;
    QString m_configFilename;
    QString m_dataPath;
    QString m_username;
    QString m_fullname;
    QString m_authtoken;
    bool m_conditions_accepted;

    QString getDefaultConfigContent();
    QString getConfigContent();

signals:
    void usernameChanged(QString newValue);
    void fullnameChanged(QString newValue);
    void authTokenChanged(QString newValue);
    void conditionsAcceptedChanged(bool newValue);

};

#endif // SETTINGS_H
