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


Item {
    id: webview
    property var internalView
    property url url
    property bool loaded: false

    function load(){
        internalView.url = url;
        loaded = true;
    }

    Rectangle {
        z: 5
        visible: internalView.loadProgress < 100
        anchors {
            top: parent.top
            left: parent.left
        }
        height: 3
        color: Style.palette.green
        width: parent.width * internalView.loadProgress/100

        Behavior on width {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }
    }

    Component.onCompleted: {
        var webviewComponent;
        webviewComponent = Qt.createComponent("webview/QtView.qml");
        if (webviewComponent.status === Component.Error) {
            webviewComponent = Qt.createComponent("webview/OxideView.qml");
        }
        internalView = webviewComponent.createObject(webview);
    }
}
