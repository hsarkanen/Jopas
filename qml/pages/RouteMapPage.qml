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
import "../js/reittiopas.js" as Reittiopas
import "../js/UIConstants.js" as UIConstants
import "../components"

Page {
    backNavigation: false
    anchors.fill: parent

    MapElement {
        id: map

        anchors {
            top: parent.top
            left: parent.left
            bottom: tools.top
            right: parent.right
        }

        Component.onCompleted: {
            initialize()
            first_station()
        }
    }

    Row {
        id: tools

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        height: back.height

        IconButton {
            id: back
            icon.source: "image://theme/icon-m-back"
            onClicked: pageStack.pop()
        }

        IconButton {
            icon.source: "image://theme/icon-m-previous"
            onClicked: map.previous_station()
            enabled: !appWindow.followMode
        }

        IconButton {
            icon.source: "image://theme/icon-m-next"
            onClicked: map.next_station()
            enabled: !appWindow.followMode
        }

    }
}

