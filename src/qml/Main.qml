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
import QtQuick 2.4
import quey.ui 0.1


ApplicationWindow {
    id: app

    property bool loading: false
    property bool loggedIn: false

    function showLoadingPage() { pageView.push(loadingPage); return loadingPage; }
    function hideLoadingPage() { pageView.pop(loadingPage); return loadingPage; }

    visible: false

    width: 480
    height: 640

    PageStack {
        id: pageView
        anchors.fill: parent

        TimetablePage {
            id: timetablePage
            fixed: true
        }

        WebViewPage {
            id: mensaPage
            title: "Mensa"
            url: "https://gus.sams-on.de"
        }

        WebViewPage {
            id: newsPage
            title: "News"
            url: "http://www.gymnasium-unterrieden.de/"
        }

        LoginPage {
            id: loginPage

            onLoggedIn: {
                app.loggedIn = true;
                timetablePage.retrieve();
            }

            onLoggedOut: {
                app.loggedIn = false;
            }
        }

        ConditionsPage {
            id: conditionsPage
            onAccepted: {
                Settings.conditionsAccepted = true;
                Settings.save();
                pageView.pop(conditionsPage);
                pageView.push(timetablePage);
            }
            onRejected: {
                Qt.quit();
            }
        }

        AboutPage { id: aboutPage }

        LoadingPage { id: loadingPage }
    }

    Component.onCompleted: {
        // Fix for small font size on Ubuntu Touch (Qt 5.4)
        Style.font.regular.pixelSize = Units.dp(18)
        Style.font.subheading.pixelSize = Units.dp(20)
        Style.font.heading.pixelSize = Units.dp(22)

        visible = true;
        Settings.load();
        Cache.load();

        if (!Settings.conditionsAccepted)
            pageView.push(conditionsPage);
        else
            pageView.push(timetablePage);
    }
}
