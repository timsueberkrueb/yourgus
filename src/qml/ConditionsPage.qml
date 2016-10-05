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
import QtQuick.Layouts 1.1
import quey.ui 0.1

Page {
    id: conditionsPage
    title: "Nutzungsbedingungen"
    showHeader: Settings.conditionsAccepted

    signal accepted()
    signal rejected()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacing

        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
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
                    text: "Bedingungen"
                    font: Style.font.subheading
                }

                WrapLabel {
                    Layout.fillWidth: true
                    text: "<b>YourGUS ist eine inoffizielle Anwendung</b> für Schüler des <a href='http://www.gymnasium-unterrieden.de/'>Gymnasium Unterrieden Sindelfingen</a>. "+
                          "Diese App wird weder durch das Gymnasium Unterrieden, die Schulleitung oder die Stadt Sindelfingen "+
                          "unterstützt noch wird sie offiziell von genannten Einrichtungen bzw. Personengruppen zur Verfügung gestellt. "
                    onLinkActivated: Qt.openUrlExternally(link)
                    linkColor: Style.palette.green
                }

                WrapLabel {
                    Layout.fillWidth: true
                    text: "<b>Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV:</b><br/>" +
                          "Tim Süberkrüb. Im Rahmen dieser Anwendung veröffentlichte Meinungsäußerungen " +
                          "(in Form von Videos, Kommentaren, Blogposts und anderen Inhalten) spiegeln " +
                          "- wenn nicht anders gekennzeichnet - lediglich meine persönliche Meinung wieder. " +
                          "Die Inhalte werden mit angemessener Sorgfalt erstellt, jedoch übernehme ich ausdrücklich keine Gewähr für die Richtigkeit, Vollständigkeit "+
                          " und Aktualität der Inhalte."+
                          " Bei der Nutzung dieser Anwendung kommt kein Vertragsverhältnis zwischen dir, dem Nutzer, "+
                          "und mir zustande. "
                }

                WrapLabel {
                    Layout.fillWidth: true
                    text: "Auf die Aktualität, Richtigkeit und Vollständigkeit der Vertretungsplaninhalte habe ich keinen Einfluss und übernehme somit keine Gewähr. "+
                          "Das gilt ebenso für eingebettete Webseiten."
                }

                WrapLabel {
                    Layout.fillWidth: true
                    text: "<b>YourGus ist freie Software</b> und steht unter der <a href='http://www.gnu.org/licenses/gpl'>GNU General Public License</a> zur Verfügung."
                    onLinkActivated: Qt.openUrlExternally(link)
                    linkColor: Style.palette.green
                }

                WrapLabel {
                    Layout.fillWidth: true
                    text: copyright
                }

                WrapLabel {
                    Layout.fillWidth: true
                    text: 'This program is distributed in the hope that it will be useful,'+
                          ' but WITHOUT ANY WARRANTY; without even the implied warranty of'+
                          ' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the'+
                          ' GNU General Public License for more details.'
                }

            }
        }

        Row {
            Layout.fillWidth: true
            height: 64
            spacing: Style.spacing
            visible: !Settings.conditionsAccepted

            Button {
                text: "Ablehnen"
                onClicked: rejected()
            }

            Button {
                text: "Annehmen"
                onClicked: accepted()
            }
        }
    }
}
