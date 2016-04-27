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
import QtQuick.Layouts 1.1
import quey.ui 0.1

Page {
    title: "Über"

    Flickable {
        anchors.fill: parent
        anchors.margins: Style.spacing
        contentHeight: columnLayout.childrenRect.height
        clip: true

        ColumnLayout {
            id: columnLayout
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            spacing: Style.spacing

            Label {
                text: "YourGUS v%1".arg(version)
                font: Style.font.subheading
            }

            WrapLabel {
                Layout.fillWidth: true
                text: "YourGUS ist ein Schulplaner für das Gymnasium Unterrieden Sindelfingen.<br/>"+
                      "\nDiese App benutzt <a href='http://qt.io'>Qt 5</a> und <a href='http://quey-project.github.io'>Quey UI</a>.<br/><br/>"+
                      copyright
                onLinkActivated: Qt.openUrlExternally(link)
                linkColor: Style.palette.green
            }

            WrapLabel {
                Layout.fillWidth: true
                text: "YourGus ist open-source und steht unter der GPL-License. Der Quellcode ist öffentlich auf GitHub verfügbar."
            }

            Label {
                text: "<a href='#'>Nutzungsbedingungen</a>"
                onLinkActivated: pageView.push(conditionsPage);
                linkColor: Style.palette.green
            }

            Row {
                spacing: Style.spacing

                Button {
                    text: "GitHub"
                    color: Style.palette.blue
                    onClicked: Qt.openUrlExternally("http://github.com/tim-sueberkrueb/yourgus")
                }

                Button {
                    text: "Kontakt"
                    color: Style.palette.purple
                    onClicked: Qt.openUrlExternally("http://tim-sueberkrueb.github.io")
                }
            }
        }
    }
}
