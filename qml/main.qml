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
import "js/storage.js" as Storage
import "js/favorites.js" as Favorites
import "components"

ApplicationWindow {
    id: appWindow

    cover: Qt.resolvedUrl("pages/CoverPage.qml")

    ListModel {
        id: regions

        ListElement {
            text: QT_TR_NOOP("Finland")
            apiName: "finland"
        }
        ListElement {
            text: QT_TR_NOOP("Helsinki")
            apiName: "hsl"
            boundarycirclelat: 60.169
            boundarycirclelon: 24.940
        }
        ListElement {
            text: QT_TR_NOOP("Tampere")
            apiName: "finland"
            boundarycirclelat: 61.498
            boundarycirclelon: 23.759
        }
        ListElement {
            text: QT_TR_NOOP("Turku")
            apiName: "finland"
            boundarycirclelat: 60.451
            boundarycirclelon: 22.267
        }
        ListElement {
            text: QT_TR_NOOP("Hämeenlinna")
            apiName: "waltti"
            boundarycirclelat: 60.997
            boundarycirclelon: 24.465
        }
        ListElement {
            text: QT_TR_NOOP("Joensuu")
            apiName: "waltti"
            boundarycirclelat: 62.601
            boundarycirclelon: 29.762
        }
        ListElement {
            text: QT_TR_NOOP("Jyväskylä")
            apiName: "waltti"
            boundarycirclelat: 62.243
            boundarycirclelon: 25.747
        }
        ListElement {
            text: QT_TR_NOOP("Kajaani")
            apiName: "waltti"
            boundarycirclelat: 64.227
            boundarycirclelon: 27.729
        }
        ListElement {
            text: QT_TR_NOOP("Kotka")
            apiName: "waltti"
            boundarycirclelat: 60.461
            boundarycirclelon: 26.939
        }
        ListElement {
            text: QT_TR_NOOP("Kouvola")
            apiName: "waltti"
            boundarycirclelat: 60.869
            boundarycirclelon: 26.700
        }
        ListElement {
            text: QT_TR_NOOP("Kuopio")
            apiName: "waltti"
            boundarycirclelat: 62.892
            boundarycirclelon: 27.678
        }
        ListElement {
            text: QT_TR_NOOP("Lahti")
            apiName: "waltti"
            boundarycirclelat: 60.984
            boundarycirclelon: 25.656
        }
        ListElement {
            text: QT_TR_NOOP("Lappeenranta")
            apiName: "waltti"
            boundarycirclelat: 61.056
            boundarycirclelon: 28.185
        }
        ListElement {
            text: QT_TR_NOOP("Mikkeli")
            apiName: "waltti"
            boundarycirclelat: 61.688
            boundarycirclelon: 27.274
        }
        ListElement {
            text: QT_TR_NOOP("Oulu")
            apiName: "waltti"
            boundarycirclelat: 65.012
            boundarycirclelon: 25.471
        }
        ListElement {
            text: QT_TR_NOOP("Rovaniemi")
            apiName: "waltti"
            boundarycirclelat: 66.500
            boundarycirclelon: 25.714
        }
        ListElement {
            text: QT_TR_NOOP("Salo")
            apiName: "waltti"
            boundarycirclelat: 60.385
            boundarycirclelon: 23.129
        }
        ListElement {
            text: QT_TR_NOOP("Vaasa")
            apiName: "waltti"
            boundarycirclelat: 63.096
            boundarycirclelon: 21.616
        }

        function getRegion() {
            var apiName = Storage.getSetting('api');
            for (var i = 0; i < regions.count; i++) {
                var value = regions.get(i);
                if (apiName === value.text.toLowerCase()) {
                    return value;
                }
            }
        }
    }

    InfoBanner {
        id: infoBanner
    }

    allowedOrientations: Orientation.All

    Component.onCompleted: {
        Storage.initialize()
        Favorites.initialize()

        var apiValue = Storage.getSetting("api")
        if (apiValue === "Unknown") {
            var dialog = pageStack.push(Qt.resolvedUrl("pages/StartupDialog.qml"))
            dialog.onAccepted.connect(function() {
                mainPage = pageStack.replace(Qt.resolvedUrl("pages/MainPage.qml"))
            })
            dialog.onRejected.connect(function() {
                mainPage = pageStack.replace(Qt.resolvedUrl("pages/MainPage.qml"))
            })
        }
        else {
            mainPage = pageStack.push(Qt.resolvedUrl("pages/MainPage.qml"))
        }
    }

    signal followModeEnabled

    property alias banner : banner
    property int scalingFactor : 1
    property bool followMode : false
    property bool mapVisible : false
    property string colorscheme : "default"

    // Pages sets the cover data to these properties and cover is instantiated every time based on these
    property string coverHeader: ''
    property string coverContents: ''
    property int coverAlignment: Text.AlignHCenter
    property string currentApi: ''
    property var mainPage
    property ListModel itinerariesModel: itinerariesModel
    property string itinerariesJson: ""
    property int itinerariesIndex: -1
    property string fromName: ""
    property string toName: ""

    onFollowModeChanged: {
        if(followMode)
            followModeEnabled()
    }

    Label {
        id: banner
    }

    ListModel {
        id: itinerariesModel
        property bool done: false
    }
}
