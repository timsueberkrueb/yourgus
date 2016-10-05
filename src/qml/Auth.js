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

.import 'Secret.js' as Secret

var SERVER_IP = Secret.AUTH_SERVER_IP;

function requestUrl(url, success, error) {
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.status >= 200 && (doc.status < 300 || doc.status === 304 ))
                success(doc.responseText);
            else {
                error(doc.status)
            }
        }
    }
    doc.open("GET", url);
    doc.send();
}

function requestJson(url, success, error) {
    requestUrl(url, function(text) {
        try {
            success(JSON.parse(text));
        }
        catch(e){
            console.log(e)
        }
    }, error);
}


function authenticatePassword(username, password, success, failure, error) {
    var url = "https://%1/?uname=%2&upswd=%3".arg(SERVER_IP).arg(username).arg(password);
    requestJson(url, function(data){
        if (data["login"] === true || data["login"] === "true")
            success(data["hash"]);
        else
            failure();
    }, error);
}


function authenticateToken(token, success, failure, error) {
    var url = "https://%1/?hash=%2".arg(SERVER_IP).arg(token);
    requestJson(url, function(data){
        if (data["login"] === true || data["login"] === "true")
            success(data["hash"]);
        else
            failure();
    }, error);
}

function authenticate(username, password, hash, success, failure, error) {
    if (password) {
        authenticatePassword(username, password, success, failure, error);
    }
    else if (hash) {
        authenticateToken(hash, success, failure, error);
    }
    else {
        failure();
    }
}
