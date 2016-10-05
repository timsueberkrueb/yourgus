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

import QtQuick 2.4
import quey.ui 0.1

Page {
    id: loadingPage

    property bool cancelable: true

    property var colors: [
        Style.palette.red,
        Style.palette.yellow,
        Style.palette.green,
        Style.palette.blue,
        Style.palette.purple,
        Style.palette.orange
    ]

    property int colorIndex: 0

    property var loadingStrings: [
        "Lädt, bitte warten ...",
        "Wir bereiten alles vor ...",
        "Noch etwas Geduld ...",
        "Es dauert nicht mehr lange ...",
        "Einen Moment noch ...",
        "Lade Daten ..."
    ]

    property int loadingStringIndex: 0

    signal canceled()

    function shuffle(a) {
        var j, x, i;
        for (i = a.length; i; i -= 1) {
            j = Math.floor(Math.random() * i);
            x = a[i - 1];
            a[i - 1] = a[j];
            a[j] = x;
        }
    }

    function shuffleColors() { shuffle(colors) }
    function shuffleLoadingStrings() { shuffle(loadingStrings) }

    showHeader: false

    Rectangle {
        anchors.fill: parent
        color: colors[colorIndex]

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: Style.spacing

        ActivityIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: true
            color: Style.palette.white
        }

        Label {
            text: loadingStrings[loadingStringIndex]
            color: Style.palette.white
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            if (colorIndex === colors.length-1) {
                colorIndex = 0;
                if (loadingStringIndex === loadingStrings.length-1)
                    loadingStringIndex = 0;
                else
                    loadingStringIndex++;
            }
            else
                colorIndex++;
        }
    }

    onVisibleChanged: {
        if (visible) {
            shuffleColors();
            shuffleLoadingStrings();
        }
    }

    Label {
        anchors {
            bottom: parent.bottom
            bottomMargin: Style.spacing
            horizontalCenter: parent.horizontalCenter
        }
        visible: cancelable
        text: "<a href='#'>Abbrechen</a>"
        linkColor: Style.palette.white
        onLinkActivated: {
            pageView.pop(loadingPage);
            canceled();
        }
    }
}
