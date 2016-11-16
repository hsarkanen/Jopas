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

// First, let's create a short helper function to get the database connection
function getDatabase() {
     return Sql.LocalStorage.openDatabaseSync("JollaOpas", "1.0", "StorageDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();

    db.transaction(
        function(tx) {
            // Create the settings table if it doesn't already exist
            // If the table exists, this is skipped
            // Type is just preparation for possibly different recentitem types in the future
            tx.executeSql('CREATE TABLE IF NOT EXISTS recentitems(coord TEXT UNIQUE, type TEXT NOT NULL, api TEXT NOT NULL, name TEXT NOT NULL);');
          });
}

function addRecentItem(name, coord) {
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        // If the place was already in recentitems remove it temporarily for increasing it's index to bring it first
        // on the list again
        var rs = tx.executeSql('SELECT coord,name FROM recentitems WHERE coord = ?', coord);
        if (rs.rows.length > 0) {
            rs = tx.executeSql('DELETE FROM recentitems WHERE coord = ?;', coord)
        }
        rs = tx.executeSql('INSERT INTO recentitems (coord,type,api,name) VALUES (?,?,?,?);', [coord,'normal',appWindow.currentApi,name]);
        if (rs.rowsAffected > 0) {
            res = "OK";
        } else {
            res = "Error";
        }
     });
  return res;
}

function deleteRecentItems() {
   var db = getDatabase();
   db.transaction(function(tx) {
        tx.executeSql('DROP TABLE recentitems');
        }
  );
  // The function returns always “OK”
  return "OK";
}

// This function is used to retrieve a setting from the database
function getRecentItems(model) {
   var db = getDatabase();
   var res="";
   db.transaction(function(tx) {
     var rs = tx.executeSql('SELECT coord,name FROM recentitems WHERE api = ?', appWindow.currentApi);
     if (rs.rows.length > 0) {
         // Return recentitems in reverse order
         for(var i = rs.rows.length - 1; i >= 0; --i) {
             var output = {}
             output.modelData = rs.rows.item(i).name;
             output.coord = rs.rows.item(i).coord;
             output.type = "recentitem"
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
