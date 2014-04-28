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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/UIConstants.js" as UIConstants
import "../js/storage.js" as Storage
import "../js/favorites.js" as Favorites

CoverBackground {

    property string coverLine1: appWindow.coverLine1
    property string coverLine2: appWindow.coverLine2
    property string coverLine3: appWindow.coverLine3
    property string coverLine4: appWindow.coverLine4
    property string coverLine5: appWindow.coverLine5
    property string coverLine6: appWindow.coverLine6

    Label {
        id: label
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: UIConstants.DEFAULT_MARGIN / 2
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: coverLine1 + "\n" + coverLine2 + "\n" + coverLine3 + "\n" + coverLine4 + "\n" + coverLine5 + "\n" + coverLine6
        wrapMode: Text.WordWrap
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-favorite"
            onTriggered: {
                startCoverSearch("straight")
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-shuffle"
            onTriggered: {
                startCoverSearch("reverse")
            }
        }
    }

    function startCoverSearch(direction) {
        pageStack.clear()
        appWindow.activate()
        var coverRoutesItem = []
        var res = Favorites.getFavoriteRoutes('cover', Storage.getSetting("api"), coverRoutesItem)
        if (res == "Unknown") {
            var page = pageStack.push(Qt.resolvedUrl("MainPage.qml"))
            page.displayPopupMessage( qsTr("Please save a route and add it to cover action by long-press.") )
        }
        else {
            var parameters = {}
            var walking_speed = Storage.getSetting("walking_speed")
            var optimize = Storage.getSetting("optimize")
            var change_margin = Storage.getSetting("change_margin")

            parameters.from_name = direction == "straight" ? coverRoutesItem.modelFromName : coverRoutesItem.modelToName
            parameters.from = direction == "straight" ? coverRoutesItem.modelFromCoord : coverRoutesItem.modelToCoord
            parameters.to_name = direction == "straight" ? coverRoutesItem.modelToName : coverRoutesItem.modelFromName
            parameters.to = direction == "straight" ? coverRoutesItem.modelToCoord : coverRoutesItem.modelFromCoord

            parameters.time = new Date()
            parameters.timetype = "departure"
            parameters.walk_speed = walking_speed == "Unknown"?"70":walking_speed
            parameters.optimize = optimize == "Unknown"?"default":optimize
            parameters.change_margin = change_margin == "Unknown"?"3":Math.floor(change_margin)
            parameters.transport_types = ["ferry"]
            if(Storage.getSetting("train_disabled") != "true")
                parameters.transport_types.push("train")
            if(Storage.getSetting("bus_disabled") != "true") {
                parameters.transport_types.push("bus")
                parameters.transport_types.push("uline")
                parameters.transport_types.push("service")
            }
            if(Storage.getSetting("metro_disabled") != "true")
                parameters.transport_types.push("metro")
            if(Storage.getSetting("tram_disabled") != "true")
                parameters.transport_types.push("tram")
            pageStack.push(Qt.resolvedUrl("MainPage.qml"), {}, PageStackAction.Immediate)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
        }
    }
}
