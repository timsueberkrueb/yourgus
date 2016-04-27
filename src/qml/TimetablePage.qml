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
import "VP.js" as VP

Page {
    id: timetablePage

    property bool loaded: false
    property bool offline: false
    property var dates: []
    property var dateIndex: 0
    property var planData: ({})
    property var entries: []
    property int currentIndex: -1
    property bool filterForUser: optionFilterForUser.selectedIndex == 0
    onFilterForUserChanged: {
        dateSelected();
    }

    signal dateSelected()
    onDateSelected: {
        if (planData[dates[dateIndex]]) {
            entries = VP.getEntries(
                planData[dates[dateIndex]],
                filterForUser ? loginPage.username : false,
                loginPage.loginMode == loginPage.teacher ? loginPage.fullName : false
            );
            entriesChanged();
        }
    }

    title: "Stundenplan"

    menu: Menu {
        items: [
            MenuItem {
                text: "Mensa"
                iconName: "coffee"
                onTriggered: pageView.push(mensaPage);
            },
            MenuItem {
                text: "News"
                iconName: "bookmarks"
                onTriggered: pageView.push(newsPage);
            },
            MenuItem {
                text: "Anmeldung"
                iconName: "log-in"
                onTriggered: pageView.push(loginPage);
            },
            MenuItem {
                text: "Über"
                iconName: "information"
                onTriggered: pageView.push(aboutPage);
            }
        ]
    }

    actions: [
        Action {
            iconName: "refresh"
            onTriggered: {
                if (loggedIn)
                    retrieve()
                else {
                    pageView.push(loginPage);
                    loginPage.login();
                }
            }
        }
    ]

    function loadCache(){
        planData = Cache.content;
        dates = Object.keys(planData);
        dateSelected();
        loaded = true;
    }

    function retrieve() {
        showLoadingPage();
        VP.getDates(function(dates){        // Success
            offline = false;
            timetablePage.dates = dates;
            dateIndex = 0;
            datesChanged();
            var n = dates.length;
            var i = 0;
            VP.forEach(dates, function(date){
                VP.getData(date, function(data) {
                    planData[date] = data;
                    i++;
                    if (i==n) {
                        dateSelected();     // Finished
                        loaded = true;
                        hideLoadingPage();
                        // Save data in cache
                        Cache.content = planData;
                        Cache.save();
                    }
                });
            });
        }, function(){                      // Error
            loaded = true;
            offline = true;
            hideLoadingPage();
            loaded = false;
            console.log("Network error occured");
            Alert.show("Fehler", "Ein Netzwerkfehler ist aufgetreten. Stelle bitte sicher, dass du mit dem Internet verbunden bist.",
                new Alert.Button("Abbrechen"),
                new Alert.Button("Erneut versuchen", function(){
                    retrieve();
                })
            );
        });
    }

    function getDateString(ds) {
        var locale = Qt.locale()
        var d = Date.fromLocaleString(locale, ds, "dd.MM.yyyy");
        return d.toLocaleDateString(locale, "dddd, dd.MM.yyyy");
    }

    function getDateStringFromUnixTime(t) {
        var locale = Qt.locale();
        var date = new Date(t);
        return date.toLocaleDateString(locale, "dddd, dd.MM.yyyy");
    }

    function getAbsentString(a) {
        var s = "";
        for (var i=0; i<a.length; i++) {
            s += a[i] + (i < a.length-1 ? ",\n" : "");
        }
        return s || "-";
    }

    function getAbsentClassesString() {
        return getAbsentString(
            VP.getAbsentClasses(planData[dates[dateIndex]])
        );
    }

    function getAbsentCoursesString() {
        return getAbsentString(
            VP.getAbsentCourses(planData[dates[dateIndex]])
        );
    }

    function getAbsentTeachersString() {
        return getAbsentString(
            VP.getAbsentTeachers(planData[dates[dateIndex]])
        );
    }

    function getMissingRoomsString() {
        return getAbsentString(
            VP.getMissingRooms(planData[dates[dateIndex]])
        );
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.spacing
        spacing: Style.spacing

        Label {
            visible: offline
            text: "Kein Netz: Sie sind offline."
            color: Style.palette.red
        }

        RowLayout {
            Layout.fillWidth: true

            ListItem {
                Layout.fillWidth: true

                height: Units.dp(64)        // Fix for scaling issues on Ubuntu Touch (Qt 5.4)

                color: dateMouseArea.containsMouse ? (dateMouseArea.pressed ? Style.palette.regular : Style.hoverColor(Style.palette.regular)) : Style.palette.white

                Label {
                    anchors.centerIn: parent
                    text: dates.length > 0 ? getDateString(dates[dateIndex]) : ""
                    color: dateMouseArea.pressed ? Style.palette.white : Style.palette.regular
                }

                MouseArea {
                    id: dateMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        dialogDates.open();
                    }
                }

                Dialog {
                    id: dialogDates
                    title: "Datum wählen"

                    content: ListView {
                        id: listView
                        model: dates
                        height: childrenRect.height
                        width: dialogDates.minimumWidth
                        delegate: ListItem {
                            width: parent.width
                            color: dateIndex === index ? Style.palette.regular : Style.palette.white

                            onClicked: {
                                if (dateIndex != index) {
                                    dateIndex = index;
                                    dateSelected();
                                    dialogDates.close();
                                }
                            }

                            Label {
                                anchors.centerIn: parent
                                text: getDateString(dates[index]);
                                color: dateIndex === index ? Style.palette.white : Style.palette.regular
                            }
                        }
                    }
                }
            }

            IconButton {
                iconName: "gear"

                onClicked: {
                    dialogOptions.open();
                }

                Dialog {
                    id: dialogOptions

                    title: "Options"

                    content: ColumnLayout {
                        spacing: Style.spacing

                        Label {
                            text: "Anzeige"
                        }

                        RadioGroup {
                            id: optionFilterForUser
                            RadioButton {
                                selected: true
                                text: "Nur meine Änderungen"
                            }
                            RadioButton {
                                text: "Alle Änderungen"
                            }
                        }
                    }
                }
            }
        }

        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            contentHeight: contentColumn.childrenRect.height

            Column {
                id: contentColumn
                width: parent.width
                height: childrenRect.height
                spacing: Style.spacing

                RowLayout {
                    width: parent.width

                    WrapLabel {
                        visible: loginPage.loginMode == loginPage.student
                        Layout.fillWidth: true
                        text: "<b>Anmerkungen:</b> %1".arg(VP.getStudentNotes(planData[dates[dateIndex]]))
                    }

                    WrapLabel {
                        visible: loginPage.loginMode == loginPage.teacher
                        Layout.fillWidth: true
                        text: "<b>Anmerkungen:<b> %1".arg(VP.getTeacherNotes(planData[dates[dateIndex]]))
                    }

                    IconButton {
                        iconName: "information"
                        onClicked: dialogInfos.open()
                    }
                }

                ListView {
                    id: listViewContent
                    width: parent.width
                    height: contentHeight
                    model: entries
                    delegate: ListItem {
                        property int canceled: 0
                        property int roomChanged: 1
                        property int generic: 2
                        property int mode: {
                            if (modelData.substitutionTeacher == "entfällt")
                                return canceled;
                            else if (modelData.substitutionRoom != "-")
                                return roomChanged;
                            else
                                return generic;
                        }
                        property color modeColor: {
                            switch(mode) {
                                case canceled:
                                    return Style.palette.red
                                default:
                                    return Style.palette.regular
                            }
                        }

                        width: parent.width
                        height: Units.dp(76)        // Fix for scaling issues on Ubuntu Touch (Qt 5.4)
                        color: currentIndex == index ? Style.hoverColor(Style.palette.regular) : Style.palette.white

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Style.spacing
                            spacing: Style.spacing

                            Circle {
                                width: height
                                height: parent.height
                                color: modeColor

                                Label {
                                    anchors.centerIn: parent
                                    text: "%1".arg(modelData.lesson)
                                    color: Style.palette.white
                                }
                            }

                            ColumnLayout {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Label {
                                        text: "Statt %1:".arg(modelData.originalSubject)
                                    }

                                    Label {
                                        text: mode == canceled ? "entfällt" : modelData.substitutionSubject
                                    }

                                    Label {
                                        visible: modelData.substitutionRoom != "-"
                                        text: "in %1".arg(modelData.substitutionRoom)
                                    }
                                }

                                ElideLabel {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: "<i>%1</i>".arg(modelData.comments)
                                }
                            }

                            Label {
                                text: modelData.className
                            }
                        }

                        onClicked: {
                            dialogDetails.modelData = modelData;
                            currentIndex = index;
                            dialogDetails.open();
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }
                }

                ListItem {
                    height: visible ? Units.dp(76) : 0              // Fix for scaling issues on Ubuntu Touch (Qt 5.4)
                    width: parent.width
                    visible: listViewContent.model.length == 0

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Style.spacing
                        spacing: Style.spacing

                        Circle {
                            width: height
                            height: parent.height
                            color: Style.palette.green

                            Icon {
                                anchors.centerIn: parent
                                name: "checkmark-empty"
                                color: Style.palette.white
                            }
                        }

                        Label {
                            text: "Keine Änderungen"
                        }
                    }
                }
            }
        }

        Dialog {
            id: dialogDetails

            property var modelData: false

            title: "Details"

            content: Grid {
                columns: 2
                spacing: Style.spacing

                Label { text: "Klasse" }
                Label { text: dialogDetails.modelData ? dialogDetails.modelData.className : "" }
                Label { text: "Stunde" }
                Label { text: dialogDetails.modelData ? dialogDetails.modelData.lesson : "" }
                Label { text: "Lehrer" }
                Label { text: dialogDetails.modelData ? dialogDetails.modelData.originalTeacher : "" }
                Label { text: "Fach" }
                Label { text: dialogDetails.modelData ? dialogDetails.modelData.originalSubject : "" }
                Label { text: "Lehrer" }
                Label { text: dialogDetails.modelData ? dialogDetails.modelData.substitutionTeacher : "" }
                Label { text: "Fach" }
                Label { text: dialogDetails.modelData ? dialogDetails.modelData.substitutionSubject : "" }
                Label { text: "Raum" }
                Label { text: dialogDetails.modelData ? dialogDetails.modelData.substitutionRoom : "" }
                Label { text: "Hinweis" }
                WrapLabel {
                    availableWidth: dialogDetails.contentAvailableWidth - 128
                    text: dialogDetails.modelData ? dialogDetails.modelData.comments : ""
                }
            }

            onClosed: currentIndex = -1;
        }

        Dialog {
            id: dialogInfos

            title: "Informationen"

            content: Grid {
                columns: 2
                spacing: Style.spacing

                Label { text: "Zuletzt aktualisiert:" }
                Label { text: loaded ? getDateStringFromUnixTime(VP.getLastUpdated(planData[dates[dateIndex]])) : "" }
                Label { text: "Version:" }
                Label { text: loaded ? VP.getVersion(planData[dates[dateIndex]]) : "" }
                Label { text: "Fehlende Räume:" }
                Label { text: loaded ? getMissingRoomsString() : "" }
                Label { text: "Abwesende Klassen:" }
                Label { text: loaded ? getAbsentClassesString() : "" }
                Label { text: "Abwesende Kurse:" }
                Label { text: loaded ? getAbsentCoursesString() : "" }
                Label { text: "Abwesende Lehrer:" }
                Label { text: loaded ? getAbsentTeachersString() : "" }
            }
        }

    }

    onPushed: {
        loadCache();

        VP.requestUrl("http://google.com",      // Check connectivity
            function(){                         // Success
                if (!loggedIn) {
                    pageView.push(loginPage);
                    if (!app.loggedIn && Settings.authtoken && Settings.username)
                        loginPage.login();
                }

                if (visible && !loaded && loggedIn)
                    retrieve();
            },
            function(){                         // Failure
                offline = true;
            }
        )
    }
}
