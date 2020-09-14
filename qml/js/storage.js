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

//storage.js
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
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
          });
}

// This function is used to write a setting into the database
function setSetting(setting, value) {
   var db = getDatabase();
   var res = "";
   db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
              //console.log(rs.rowsAffected)
              if (rs.rowsAffected > 0) {
                res = "OK";
              } else {
                res = "Error";
              }
        }
  );
  // The function returns “OK” if it was successful, or “Error” if it wasn't
  return res;
}
// This function is used to retrieve a setting from the database
function getSetting(setting) {
   var db = getDatabase();
   var res="";
   db.transaction(function(tx) {
     var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
     if (rs.rows.length > 0) {
          res = rs.rows.item(0).value;
     } else {
         res = "Unknown";
     }
  })
  // The function returns “Unknown” if the setting was not found in the database
  // For more advanced projects, this should probably be handled through error codes
  return res
}

function checkSchema(db, tableName) {
  var r
  var query = ""
  db.transaction(
    function (tx) {
      var tableInfo = tx.executeSql('PRAGMA table_info(' + tableName + ');');
      var tableSchema = getSchema(tableName)
      if (tableInfo.rows.length === 0) {
        query += "CREATE TABLE IF NOT EXISTS " + tableSchema.name + "("
        for (var i in tableSchema.columns) {
          query += i + " "
            + tableSchema.columns[i].type + " "
            + tableSchema.columns[i].unique + " "
            + tableSchema.columns[i].null + " "
            + tableSchema.columns[i].defaultValue
          console.log(tableSchema.columns.indexOf(tableSchema.columns[i]), tableSchema.columns.length - 1, tableSchema.columns.indexOf(tableSchema.columns[i]) - 1 === tableSchema.columns.length)
          query += tableSchema.columns.indexOf(tableSchema.columns[i]) === tableSchema.columns.length - 1 ? "" : ", "
        }
        query += ");"
        tx.executeSql(query);
        tableInfo = tx.executeSql('PRAGMA table_info(' + tableSchema.name + ');');
        r = tableInfo.rows.length === 0 ? false : true;
      } else if (tableInfo.rows.length === tableSchema.columns.length) {
        r = true; //TODO: check column attributes
      } else {
        for (var i in tableSchema.columns) {
          if (!attributeExists(tableInfo.rows, i)) {
            var oldLength = tableInfo.rows.length
            query = "ALTER TABLE " + tableSchema.name + " ADD " + i + " "
              + tableSchema.columns[i].type + " "
              + tableSchema.columns[i].unique + " "
              + tableSchema.columns[i].null + " "
              + tableSchema.columns[i].defaultValue
            query += ";"
            tx.executeSql(query);
            tableInfo = tx.executeSql('PRAGMA table_info(' + tableSchema.name + ');');
            console.log("AlterTable result:", tableInfo.rows.length !== oldLength)
            r = true
          }
        }
      }
    });
  return r
}


function attributeExists(rows, value) {
  var exists = false
  for (var index = 0; index < rows.length; index++) {
    exists = rows.item(index).name === value
    if (exists) break
  }
  return exists
}

function getSchema(tableName) {
  switch (tableName) {
    case "favorites":
      return favoritesTable()
    case "favoriteRoutes":
      return favoriteRoutesTable()
    case "recentitems":
      var schema = JSON.parse(JSON.stringify(favoritesTable()))
      schema.name = "recentitems"
      return schema
    default:
      return null
  }
}

function favoritesTable() {
  var favoritesTable = {}
  favoritesTable.name = "favorites"
  favoritesTable.columns = {
        "coord": { type: "TEXT", unique: "UNIQUE", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "type": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "api": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "name": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "housenumber": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "street": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "distance": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "id": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "gid": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "layer": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "source": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "source_id": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "postalcode": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "postalcode_gid": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "confidence": { type: "INTEGER", unique: "", null: "NOT NULL", defaultValue: "DEFAULT(0)" },
        "accuracy": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "country": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "country_gid": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "country_a": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "region": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "region_gid": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "localadmin": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "localadmin_gid": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "locality": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "locality_gid": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "neighbourhood": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "neighbourhood_gid": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" },
        "label": { type: "TEXT", unique: "", null: "NOT NULL", defaultValue: "DEFAULT('')" }
    }
    return favoritesTable
}

function favoriteRoutesTable() {
    var favoriteRoutesTable = {}
    favoriteRoutesTable.name = "favoriteRoutes"
    favoriteRoutesTable.columns = {
        "routeIndex": { type: "INTEGER", unique: "PRIMARY KEY AUTOINCREMENT",null: "", defaultValue: "" },
        "type": { type: "TEXT", unique: "",null: "NOT NULL", defaultValue: "" },
        "api": { type: "TEXT", unique: "",null: "NOT NULL", defaultValue: "" },
        "fromCoord": { type: "TEXT", unique: "",null: "NOT NULL", defaultValue: "" },
        "fromName": { type: "TEXT", unique: "",null: "NOT NULL", defaultValue: "" },
        "toCoord": { type: "TEXT", unique: "",null: "NOT NULL", defaultValue: "" },
        "toName": { type: "TEXT", unique: "",null: "NOT NULL", defaultValue: "" }
    }
  return favoriteRoutesTable
}
