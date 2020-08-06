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
            name: QT_TR_NOOP("Helsinki and the capital region (HRT)")
            identifier: "helsinki"
            apiName: "hsl"
            boundarycirclelat: 60.169
            boundarycirclelon: 24.940
        }
        ListElement {
            name: QT_TR_NOOP("Tampere region (Nysse)")
            identifier: "tampere"
            apiName: "finland"
            boundarycirclelat: 61.498
            boundarycirclelon: 23.759
        }
        ListElement {
            name: QT_TR_NOOP("Turku region (Föli)")
            identifier: "turku"
            apiName: "finland"
            boundarycirclelat: 60.451
            boundarycirclelon: 22.267
        }
        ListElement {
            name: QT_TR_NOOP("Hämeenlinna region")
            identifier: "hameenlinna"
            apiName: "waltti"
            boundarycirclelat: 60.997
            boundarycirclelon: 24.465
        }
        ListElement {
            name: QT_TR_NOOP("Iisalmi")
            identifier: "iisalmi"
            apiName: "waltti"
            boundarycirclelat: 63.557
            boundarycirclelon: 27.190
        }
        ListElement {
            name: QT_TR_NOOP("Joensuu region (JOJO)")
            identifier: "joensuu"
            apiName: "waltti"
            boundarycirclelat: 62.601
            boundarycirclelon: 29.762
        }
        ListElement {
            name: QT_TR_NOOP("Jyväskylä region (Linkki)")
            identifier: "jyvaskyla"
            apiName: "waltti"
            boundarycirclelat: 62.243
            boundarycirclelon: 25.747
        }
        ListElement {
            name: QT_TR_NOOP("Kajaani region")
            identifier: "kajaani"
            apiName: "waltti"
            boundarycirclelat: 64.227
            boundarycirclelon: 27.729
        }
        ListElement {
            name: QT_TR_NOOP("Kotka region")
            identifier: "kotka"
            apiName: "waltti"
            boundarycirclelat: 60.461
            boundarycirclelon: 26.939
        }
        ListElement {
            name: QT_TR_NOOP("Kouvola")
            identifier: "kouvola"
            apiName: "waltti"
            boundarycirclelat: 60.869
            boundarycirclelon: 26.700
        }
        ListElement {
            name: QT_TR_NOOP("Kuopio region (Vilkku)")
            identifier: "kuopio"
            apiName: "waltti"
            boundarycirclelat: 62.892
            boundarycirclelon: 27.678
        }
        ListElement {
            name: QT_TR_NOOP("Lahti region (LSL)")
            identifier: "lahti"
            apiName: "waltti"
            boundarycirclelat: 60.984
            boundarycirclelon: 25.656
        }
        ListElement {
            name: QT_TR_NOOP("Lappeenranta")
            identifier: "lappeenranta"
            apiName: "waltti"
            boundarycirclelat: 61.056
            boundarycirclelon: 28.185
        }
        ListElement {
            name: QT_TR_NOOP("Mikkeli")
            identifier: "mikkeli"
            apiName: "waltti"
            boundarycirclelat: 61.688
            boundarycirclelon: 27.274
        }
        ListElement {
            name: QT_TR_NOOP("Oulu region")
            identifier: "oulu"
            apiName: "waltti"
            boundarycirclelat: 65.012
            boundarycirclelon: 25.471
        }
        ListElement {
            name: QT_TR_NOOP("Rovaniemi (Linkkari)")
            identifier: "rovaniemi"
            apiName: "waltti"
            boundarycirclelat: 66.500
            boundarycirclelon: 25.714
        }
        ListElement {
            name: QT_TR_NOOP("Vaasa")
            identifier: "vaasa"
            apiName: "waltti"
            boundarycirclelat: 63.096
            boundarycirclelon: 21.616
        }
        ListElement {
            name: QT_TR_NOOP("Whole Finland")
            identifier: "finland"
            apiName: "finland"
        }

        function getRegion() {
            var apiName = Storage.getSetting('api');
            for (var i = 0; i < regions.count; i++) {
                var value = regions.get(i);
                if (apiName === value.identifier) {
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

        var query = readCLIArguments(Qt.application.arguments,":");
        var dest = "", from = "";

        if ("parameters" in query) {
            if ("to" in query.parameters)
                dest = query.parameters.to;
            if ("from" in query.parameters)
                from = query.parameters.from;
        }

        var apiValue = Storage.getSetting("api")
        if (apiValue === "Unknown") {
            mainPage = pageStack.push(Qt.resolvedUrl("pages/MainPage.qml"), {
                                          "startPoint": from, "destinationPoint": dest }, true)
            var dialog = pageStack.push(Qt.resolvedUrl("pages/StartupDialog.qml"), {}, true)
        }
        else {
            mainPage = pageStack.push(Qt.resolvedUrl("pages/MainPage.qml"), {
                                          "startPoint": from, "destinationPoint": dest })
        }
    }

    function readCLIArguments(argList, sepStr) {
        // checks argList[] for "-q" = "--query", "--address", "--to" and "--from"
        // uses an url parser for 'query', but not for 'address', 'to' nor 'from'
        var result = { scheme: "", action: "", comment: "", parameters: {} }
        var nrArg = argList.length, dStr = "", i = 0, decode = true

        if (sepStr === undefined)
            sepStr = ":"

        while(i < nrArg-1) {
            if (argList[i] === "-q" || argList[i] === "--query") {
                result = schemeComponents(argList[i+1], decode, sepStr)
<<<<<<< HEAD
=======

>>>>>>> c62d043ffd452fc5fbbc8c691585e479a4a27960
                i = nrArg
            } else if (argList[i] === "--address" || argList[i] === "--to") {
                result.parameters.to = argList[i+1]
                i = nrArg
            } else if (argList[i] === "--from") {
                result.parameters.from = argList[i+1]
                i = nrArg
            }
            i++
        }

        return result
    }

    function schemeComponents(url, decode, sepStr) {
        // modified from www.sitepoint.com/get-url-parameters-with-javascript/
        // url - string to be parsed
        // decode - is decodeURIComponent() used for the parameter values?
        // sepStr - separator between the scheme name and the query - ":" or "://" usually
        var result = {}, queryParams = {}, j=0, schemeStr = url;

        if (sepStr === undefined)
            sepStr = ":"
        if (decode === undefined)
            decode = true

        // if query string exists
        if (schemeStr) {
            j = schemeStr.indexOf(sepStr)
            result.scheme = schemeStr.substring(0,j)

            j += sepStr.length
            schemeStr = schemeStr.substring(j) // from j to end

            j = schemeStr.indexOf("?")
            result.action = schemeStr.substring(0, j)

            schemeStr = schemeStr.substring(j+1)

            j = schemeStr.indexOf("#")
            if (j >= 0) {
                result.comment = schemeStr.substring(j+1)
               schemeStr = schemeStr.substring(0, j)
            }

            // split our query string into its component parts
            var arr = schemeStr.split('&');

            for (var i = 0; i < arr.length; i++) {
                // separate the keys and the values
                var a = arr[i].split('=');

                // set parameter name and value (use 'true' if empty)
                var paramName = a[0];
                var paramValue = typeof (a[1]) === 'undefined' ? true : a[1];
                if (decode && typeof (paramValue) === typeof ("")) // if value is string
                    paramValue = decodeURIComponent(paramValue)

                // if the paramName ends with square brackets, e.g. colors[] or colors[2]
                if (paramName.match(/\[(\d+)?\]$/)) {

                    // create key if it doesn't exist
                    var key = paramName.replace(/\[(\d+)?\]/, '');
                    if (!queryParams[key]) queryParams[key] = [];

                    // if it's an indexed array e.g. colors[2]
                    if (paramName.match(/\[\d+\]$/)) {
                        // get the index value and add the entry at the appropriate position
                        var index = /\[(\d+)\]/.exec(paramName)[1];
                        queryParams[key][index] = paramValue;
                    } else {
                        // otherwise add the value to the end of the array
                        queryParams[key].push(paramValue);
                    }
                } else {
                    // we're dealing with a string
                    if (!queryParams[paramName]) {
                        // if it doesn't exist, create property
                        queryParams[paramName] = paramValue;
                    } else if (queryParams[paramName] && typeof queryParams[paramName] === 'string'){
                        // if property does exist and it's a string, convert it to an array
                        queryParams[paramName] = [queryParams[paramName]];
                        queryParams[paramName].push(paramValue);
                    } else {
                        // otherwise add the property
                        queryParams[paramName].push(paramValue);
                    }
                }
            }
        }
        result.parameters = queryParams
        return result;
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
