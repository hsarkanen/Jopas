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
*   Mohammed Samee <msameer@foolab.org>r
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
import "js/storage.js" as Storage
import "js/favorites.js" as Favorites
import "components"

ApplicationWindow {
    id: appWindow
    cover: CoverBackground {
        CoverPlaceholder {
            text: "Jopas"
            // icon.source: "Jopas.png"
        }
    }


    InfoBanner {
        id: infoBanner
    }

    allowedOrientations: Orientation.All

    Component.onCompleted: {
        Storage.initialize()
        Favorites.initialize()

        var allowGps = Storage.getSetting("gps")
        var apiValue = Storage.getSetting("api")
        if (allowGps === "Unknown" || apiValue === "Unknown") {
            var dialog = pageStack.push(Qt.resolvedUrl("pages/StartupDialog.qml"))
            dialog.onAccepted.connect(function() {
                pageStack.replace(Qt.resolvedUrl("pages/MainPage.qml"))
            })
            dialog.onRejected.connect(function() {
                pageStack.replace(Qt.resolvedUrl("pages/MainPage.qml"))
            })
        }
        else {
            pageStack.push(Qt.resolvedUrl("pages/MainPage.qml"))
        }
    }

    signal followModeEnabled

    property alias banner : banner
    property variant scalingFactor : 1
    property bool positioningActive : (Qt.application.active && gpsEnabled)
    property bool followMode : false
    property bool mapVisible : false
    property string colorscheme : "default"
    property bool gpsEnabled : false

    onFollowModeChanged: {
        if(followMode)
            followModeEnabled()
    }

    Label {
        id: banner
    }
}
