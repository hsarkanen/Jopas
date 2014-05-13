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
import "../js/UIConstants.js" as UIConstants
import "../js/reittiopas.js" as Reittiopas
import "../js/favorites.js" as Favorites
import "../js/theme.js" as Theme
import "../components"

Dialog {
    id: add_dialog
    property alias name : editTextField.text
    property string coord : ""

    title: Column {
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            text: qsTr("Enter name for the favorite")
            font.pixelSize: UIConstants.FONT_XLARGE
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Qt.AlignCenter
            elide: Text.ElideNone
            font.bold: true
            font.family: UIConstants.FONT_FAMILY
            color: Theme.theme[appWindow.colorscheme].COLOR_FOREGROUND
        }
        Spacing { }
    }

    content: Item {
        width: parent.width
        height: edit_column.height + UIConstants.DEFAULT_MARGIN * 2
        Column {
            id: edit_column
            width: parent.width
            spacing: UIConstants.DEFAULT_MARGIN
            TextField {
                id: editTextField
                width: parent.width
                text: add_dialog.name

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
    }
    buttons: Column {
        spacing: UIConstants.DEFAULT_MARGIN
        anchors.horizontalCenter: parent.horizontalCenter
        width: button_save.width
        Button {
            id: button_save
            text: qsTr("Add")
            font.pixelSize: UIConstants.FONT_DEFAULT  * appWindow.scalingFactor
            width: UIConstants.BUTTON_WIDTH
            height: UIConstants.BUTTON_HEIGHT
            onClicked: {
                if(add_dialog.name != '') {
                    if(("OK" == Favorites.addFavorite(add_dialog.name, coord))) {
                        favoritesModel.clear()
                        Favorites.getFavorites(favoritesModel)
                        add_dialog.name = ''

                        infoBanner.displayError(qsTr("Location added to favorites"))
                    } else {
                        infoBanner.displayError(qsTr("Location already in the favorites"))
                    }
                }
                else {
                    infoBanner.displayError(qsTr("Name cannot be empty"))
                }
                add_dialog.close()
            }
        }
        Button {
            id: button_cancel
            text: qsTr("Cancel")
            font.pixelSize: UIConstants.FONT_DEFAULT  * appWindow.scalingFactor
            width: UIConstants.BUTTON_WIDTH
            height: UIConstants.BUTTON_HEIGHT
            onClicked: add_dialog.close()
        }
    }
}
