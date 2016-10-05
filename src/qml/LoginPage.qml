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
import "Auth.js" as Auth


Page {
    id: loginPage
    // enum-like loginMode
    property int student: 0
    property int teacher: 1

    property int loginMode: student
    property string loginString: loginMode == 0 ? "Schüler" : "Lehrer"
    property string alternativeLoginString: loginMode == 1 ? "Schüler" : "Lehrer"

    property string username: Settings.username
    property string fullName: Settings.fullname

    title: "Anmeldung %1".arg(loginString)

    signal loggedIn()
    signal loggedOut()

    function login(){
        showLoadingPage();

        Settings.username = username = usernameField.text;
        Settings.fullname = fullName = fullNameField.text;
        Settings.save();

        Auth.authenticate(username, passwordField.text, Settings.authtoken,
        function(auth_key){
            // Success
            console.log("Authentication succeeded.")
            if (auth_key) {
                Settings.authtoken = auth_key;
                Settings.save();
            }
            hideLoadingPage();
            pageView.pop(loginPage);
            loggedIn();
        },
        function(){
            console.log("Authentication failed.")
            hideLoadingPage();
            Alert.show(
                "Anmeldung fehlgeschlagen",
                "Bitte überprüfe dein Password und deinen Benutzernamen. Verwende die Anmeldedaten, die du auch auf der Homepage verwendest.",
                new Alert.Button("Okay")
            );
        },
        function(){
            console.log("An network error while authenticating.")
            hideLoadingPage();
            Alert.show(
                "Fehler",
                "Ein Netzwerkfehler ist aufgetreten. Stelle bitte sicher, dass du mit dem Internet verbunden bist und deine Anmeldedaten korrekt sind.",
                new Alert.Button("Okay")
            );
        });
    }

    function logout(){
        loggedOut();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacing

        Column {
            visible: app.loggedIn
            spacing: Style.spacing
            Layout.fillHeight: true

            Label {
                text: "Du bist als %1 (%2) angemeldet.".arg(loginString).arg(username)
                color: Style.palette.green
            }

            Button {
                text: "Abmelden"
                onClicked: logout();
            }
        }

        Grid {
            visible: !app.loggedIn
            columns: 2
            spacing: Style.spacing
            Layout.fillHeight: true

            Label {
                text: loginMode == student ? "Klasse" : "Benutzername"
            }

            TextField {
                id: usernameField
                text: username
            }

            Label {
                text: "Voller Name"
            }

            TextField {
                id: fullNameField
                placeholderText: loginMode == student ? "Optional" : 'z.B. "Herr Pfeiffer"'
                text: fullName
            }

            Label {
                text: "Password"
            }

            TextField {
                id: passwordField
                echoMode: TextInput.Password
            }

            Item { width: 1; height: 1 }    // Placeholder

            Label {
                text: "<a href='#'>Ich bin ein %2</a>".arg(alternativeLoginString)
                linkColor: Style.palette.green
                onLinkActivated: {
                    loginMode = loginMode == 0 ? 1 : 0;
                }
            }

            Button {
                text: "Abbrechen"
                onClicked: {
                    pageView.pop(loginPage);
                }
            }

            Button {
                text: "Anmelden"
                onClicked: {
                    if (usernameField.text && passwordField.text)
                        login();
                    else
                        Alert.show(
                            "Warnung",
                            "Du musst sowohl Password als auch Benutzernamen angeben. Verwende die Anmeldedaten, die du auch auf der Homepage verwendest.",
                            new Alert.Button("Okay")
                        );
                }
            }
        }
    }
}
