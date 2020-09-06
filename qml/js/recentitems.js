/**********************************************************************
*
* This file is part of the JollaOpas, forked from Jopas originally
* forked from Meegopas.
* More information:
*
*   https://github.com/hsarkanen/JollaOpas
*   https://github.com/rasjani/Jopas
*   https://github.com/junousia/Meegopas
*
* Author: Heikki Sarkanen <heikki.sarkanen@gmail.com>
* Original author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
* Other contributors:
*   Jani Mikkonen <jani.mikkonen@gmail.com>
*   Jonni Rainisto <jonni.rainisto@gmail.com>
*   Mohammed Sameer <msameer@foolab.org>
*   Clovis Scotti <scotti@ieee.org>
*   Benoit HERVIER <khertan@khertan.net>
*
* All assets contained within this project are copyrighted by their
* respectful authors.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* See full license at http://www.gnu.org/licenses/gpl-3.0.html
*
**********************************************************************/

// Adapted from:http://www.developer.nokia.com/Community/Wiki/How-to_create_a_persistent_settings_database_in_Qt_Quick_%28QML%29

.import QtQuick.LocalStorage 2.0 as Sql
.import "storage.js" as Storage

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = Storage.getDatabase();
    var status = Storage.checkSchema(db, "recentitems")
    console.log("favorites init success: ", status)
}

function addRecentItem(object) {
    var db = Storage.getDatabase();
    var res = "";
    db.transaction(function (tx) {
        // If the place was already in recentitems remove it temporarily for increasing it's index to bring it first
        // on the list again
        var rs = tx.executeSql('SELECT coord,name FROM recentitems WHERE coord = ?', coord);
        if (rs.rows.length > 0) {
            rs = tx.executeSql('DELETE FROM recentitems WHERE coord = ?;', coord)
        }
        else {
            var query = 'INSERT INTO recentitems ('
            var queryValues = ' VALUES ('
            var values = []
            for (var key in object) {
                // console.log(key, object[key])
                if (object[key]) {
                    query += key + ','
                    queryValues += '?,'
                    values.push(object[key])
                }
            }
            query += 'type,api)'
            queryValues += '?,?);'
            values.push('normal')
            values.push(appWindow.currentApi)
            rs = tx.executeSql(query + queryValues, values);
            if (rs.rowsAffected > 0) {
                res = "OK";
            } else {
                res = "Error";
            }
        }
    });
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

function deleteRecentItems() {
    var db = Storage.getDatabase();
    db.transaction(function(tx) {
        tx.executeSql('DROP TABLE recentitems');
        }
    );
    // The function returns always “OK”
    return "OK";
}

// This function is used to retrieve a setting from the database
function getRecentItems(model) {
    var db = Storage.getDatabase();
    var res="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM recentitems WHERE api = ?', appWindow.currentApi);
        if (rs.rows.length > 0) {
            for (var i = 0; i < rs.rows.length; i++) {
                var output = JSON.parse(JSON.stringify(rs.rows.item(i)))
                model.append(output)
            }
        } else {
            res = "Unknown";
        }
    })
    // The function returns “Unknown” if the setting was not found in the database
    // For more advanced projects, this should probably be handled through error codes
    return res
}
