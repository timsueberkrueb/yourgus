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

.import "Secret.js" as Secret

var SERVER_IP = 'dominik-stiller.de';
var SERVER_PORT = '12566';
var APP_ID = 'sueberkrueb';
var APP_TOKEN = Secret.APP_TOKEN;

var ACTION_DATES = 0;
var ACTION_DATA = 1;
var ACTION_LATESTVERSION = 2;
var ACTION_APIVERSION = 3;

var actionUrlSegments = [
    "dates",
    "data",
    "latestversion",
    "apiversion"
]

function requestUrl(url, success, error) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.status >= 200 && (doc.status < 300 || doc.status === 304 ))
                success(doc.responseText);
            else
                error(doc.status)
        }
    }
    doc.open("GET", url);
    doc.send();
}

function requestJson(url, success, error) {
    requestUrl(url, function(text) {
        success(JSON.parse(text));
    }, error);
}

function getUrl(action, date) {
    var segment = '';
    segment += actionUrlSegments[action];
    switch (action) {
        case ACTION_DATA:
            segment += "/%1".arg(date);
            break;
        case ACTION_LATESTVERSION:
            segment += "/%1".arg(date);
            break;
    }
    return "http://%1:%2/%3?appid=%4&accesstoken=%5".arg(SERVER_IP).arg(SERVER_PORT).arg(segment).arg(APP_ID).arg(APP_TOKEN);
}

function forEach(a, f) {
    for (var i=0; i<a.length; i++) {
        f(a[i]);
    }
}

function matchForm(f, form) {
    var formName = form.slice(0, form.length-1)
    var formSect = form[form.length-1]
    if (formName == "11")                   // course level 11
        return formName == f;
    else if (formName == "12")              // course level 12
        return formName == f || f == "Abi";
    else
        return f.toLowerCase() == form || (f.toLowerCase().indexOf(formName) == 0 && f.toLowerCase().indexOf(formSect) > 0)
}

function getDates(success, error) {
    requestJson(getUrl(ACTION_DATES), function(res) {
        success(res["data"]["dates"]);
    }, error);
}

function getData(date, success, error) {
    requestJson(getUrl(ACTION_DATA, date), function(res) {
        success(res["data"]);
    }, error);
}

function getVersion(data) {
    return data["metadata"]["version"];
}

function getLastUpdated(data) {
    return data["metadata"]["lastUpdated"];
}

function getStudentNotes(data) {
    var notes = data["metadata"]["studentNotes"];
    return notes.replace(new RegExp("\t", "g"), "<br/>").replace(new RegExp("LFLF", "g"), "<br/>");
}

function getTeacherNotes(data) {
    var notes = data["metadata"]["teacherNotes"];
    return notes.replace(new RegExp("\t", "g"), "<br/>").replace(new RegExp("LFLF", "g"), "<br/>");
}

function getAbsentClasses(data) {
    return data["metadata"]["absentClasses"];
}

function getAbsentCourses(data) {
    return data["metadata"]["absentCourses"];
}

function getAbsentTeachers(data) {
    return data["metadata"]["absentTeachers"];
}

function getMissingRooms(data) {
    return data["metadata"]["missingRooms"]
}

function getEntries(data, username, teacherName) {
    var entries = data["entries"];
    var e = [];
    if (username) {
        for (var i=0; i<entries.length; i++) {
            var item = entries[i];
            if (!teacherName) {
                if (matchForm(item.className, username))
                    e.push(item);
            }
            else {
                if (item.originalTeacher == teacherName || item.substitutionTeacher == teacherName)
                    e.push(item);
            }
        }
        return e;
    }
    else
        return entries;
}
