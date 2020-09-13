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

import QtQuick 2.1
import Sailfish.Silica 1.0
import "../../js/favorites.js" as Favorites
import "../components"
import "../../components"

Dialog {
    id: add_dialog
    property alias name: editTextField.text
    property bool edit: false
    property var favoritesModel
    property var favoriteObject
    property bool paramsValid: false

    canAccept: paramsValid || edit

    onAccepted: {
        if(paramsValid) {
            favoriteObject.name = editTextField.text
            if(("OK" == Favorites.addFavorite(favoriteObject))) {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
            }
        } else if (edit){
            if("OK" == Favorites.updateFavorite(editTextField.text, favoriteObject.coord, favoritesModel)) {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
            }
        }
    }

    function validateFavorite() {
        paramsValid = true
    }
    DialogHeader {
        id: header
        acceptText: edit ? qsTr("Edit favorite place") : qsTr("Add favorite place")
        anchors.top: parent.top
    }

    ComboBox {
        id: favoritePlace
        enabled: !edit
        anchors.top: header.bottom
        width: parent.width
        label: "Location"
        description: "Select your favorite place"
        value: add_dialog.favoriteObject.name || "Choose location"
        menu: ContextMenu {
            ListItem {
                MenuItem {
                    text: "Search"
                }
                onClicked: function() {
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/SearchAddress.qml"))
                    dialog.accepted.connect(function() {
                        add_dialog.favoriteObject = JSON.parse(JSON.stringify(dialog.selectObject))
                        favoritePlace.value = add_dialog.favoriteObject.name
                        editTextField.text = add_dialog.favoriteObject.name
                        validateFavorite()
                    })
                }
                onPressAndHold: {
                    favoritePlace.value = "Using GPS"
                    fromGPS.timer.running = true
                }
            }
            ListItem {
                MenuItem {
                    text: "Map"
                }
                onClicked: function() {
                    var coord
                    var name
                    if(add_dialog.favoriteObject) {
                        coord = add_dialog.favoriteObject.coord
                        name = add_dialog.favoriteObject.name
                    }
                    var dialog = pageStack.push(
                        Qt.resolvedUrl("../dialogs/Map.qml"),
                        {
                            inputCoord: coord || '',
                            resultName: name || ''
                        }
                    )
                    dialog.accepted.connect(function() {
                        add_dialog.favoriteObject = JSON.parse(JSON.stringify(dialog.resultObject))
                        favoritePlace.value = add_dialog.favoriteObject.name
                        editTextField.text = add_dialog.favoriteObject.name
                        validateFavorite()
                    })
                }
                onPressAndHold: {
                    favoritePlace.value = "Using GPS"
                    fromGPS.timer.running = true
                }
            }
            ListItem {
                MenuItem {
                    text: "Favorite"
                }
                onClicked: function() {
                    favoritesModel.clear()
                    Favorites.getFavorites(favoritesModel)
                    favoritesModel.insert(0, {name: qsTr("Current location"),coord:"0,0"})
                    recentItemsModel.clear()
                    RecentItems.getRecentItems(recentItemsModel)
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/FavoriteRecentItemSelection.qml"),
                        {
                            model: favoritesModel,
                            model2: recentItemsModel,
                        }
                    )
                    dialog.accepted.connect(function() {
                        add_dialog.favoriteObject = JSON.parse(JSON.stringify(dialog.resultObject))
                        favoritePlace.value = add_dialog.favoriteObject.name
                        editTextField.text = add_dialog.favoriteObject.name
                        validateFavorite()
                    })
                }
                onPressAndHold: {
                    if(add_dialog.favoriteObject.name && add_dialog.favoriteObject.coord) {
                        if(("OK" === Favorites.addFavorite(add_dialog.favoriteObject))) {
                            favoritesModel.clear()
                            Favorites.getFavorites(favoritesModel)
                            appWindow.useNotification( qsTr("Location added to favorite places") )
                        } else {
                            appWindow.useNotification(qsTr("Location already in the favorite places"))
                        }
                    } else {
                        console.log(add_dialog.favoriteObject.name, add_dialog.favoriteObject.coord)
                        appWindow.useNotification(qsTr("No location to put into favorites"))
                    }
                }
            }
        }
        onPressAndHold: function(){
            favoritePlace.value = "Using GPS"
            fromGPS.timer.running = true
        }
        LocationSource {
            id: fromGPS
            onLocationFound: function() {
                add_dialog.favoriteObject = appWindow.locationParameters.gps
                favoritePlace.value = add_dialog.favoriteObject.name
                editTextField.text = add_dialog.favoriteObject.name
                validateFavorite()
            }
            onNoLocationSource: function(){
                appWindow.useNotification( qsTr("Location service unavailable") )
                favoritePlace.value = add_dialog.favoriteObject.name || "Choose location"
            }
        }
    }

    TextField {
        id: editTextField
        anchors.top: favoritePlace.bottom
        width: parent.width
        text: {
            if(favoriteObject) {
                return favoriteObject.name
            }
            return qsTr("Name")
        }
        label: qsTr("Enter name for the favorite place")
        placeholderText: qsTr("Enter name for the favorite place")
        focusOutBehavior: FocusBehavior.ClearPageFocus
        onFocusChanged: if (focus) cursorPosition = text.length

        Item {
            parent: editTextField
            anchors.fill: parent

            IconButton {
                id: clearButton
                anchors {
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                width: icon.width
                height: parent.height
                icon.source: (editTextField.text.length > 0 ? "image://theme/icon-m-clear" : "")

                enabled: editTextField.enabled

                opacity: icon.status === Image.Ready ? 1 : 0
                Behavior on opacity {
                    FadeAnimation {}
                }

                onClicked: editTextField.text = ""
            }
        }

        Keys.onReturnPressed: {
            editTextField.focus = false
            parent.focus = true
        }
    }
}
