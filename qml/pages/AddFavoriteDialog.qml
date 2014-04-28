/**********************************************************************
*
* This file is part of the Jopas, forked from Meegopas.
* More information:
*
*   https://github.com/rasjani/Jopas
*   https://github.com/junousia/Meegopas
*
* Author: Jani Mikkonen <jani.mikkonen@gmail.com>
* Original author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
* Other contributors:
*   Jonni Rainisto <jonni.rainisto@gmail.com>
*   Mohammed Sameer <msameer@foolab.org>
*   Clovis Scotti <scotti@ieee.org>
*   Benoit HERVIER <khertan@khertan.net>
*   Heikki Sarkanen <heikki.sarkanen@gmail.com>
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
import "../js/favorites.js" as Favorites
import "../components"

Dialog {
    id: add_dialog
    property string coord: ''
    property alias name: editTextField.text
    property variant favoritesModel

    canAccept: add_dialog.coord != '' && name.text != ''

    onAccepted: {
        if(add_dialog.name != '') {
            if(("OK" == Favorites.addFavorite(add_dialog.name, coord))) {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
            }
        }
    }

    Column {
        anchors.fill: parent

        DialogHeader {
            acceptText: qsTr("Add favorite")
        }

        LocationEntry {
            id: entry
            anchors.bottomMargin: Theme.paddingSizeSmall
            font.pixelSize: Theme.fontSizeMedium
            label.anchors.horizontalCenter: entry.horizontalCenter
            type: qsTr("Search for location")
            disable_favorites: true
            onLocationDone: {
                add_dialog.name = name
                add_dialog.coord = coord
            }
        }

        Spacing {}

        Label {
            text: qsTr("Enter name for the favorite")
            font.pixelSize: Theme.fontSizeMedium
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Qt.AlignCenter
            font.bold: true
            color: Theme.primaryColor
        }

        Spacing {}

        TextField {
            id: editTextField
            width: parent.width

            Image {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/images/clear.png"
                visible: (editTextField.activeFocus)

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        editTextField.text = ''
                    }
                }
            }

            Keys.onReturnPressed: {
                editTextField.focus = false
                parent.focus = true
            }
        }
    }

    // Added InfoBanner here as a workaround to display it correctly above all other UI elements, fixing the z-order from the one in main.qml isn't trivial
    InfoBanner {
        id: infoBanner
        z: 1
    }

    function displayPopupMessage(message) {
        infoBanner.displayError(message)
    }
}
