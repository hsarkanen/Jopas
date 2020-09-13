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
import "../js/reittiopas.js" as Reittiopas
import "../js/helper.js" as Helper
import "../components"

Page {
    property int route_index
    property string header
    property string duration
    property string walking
    property string start_time
    property string finish_time
    property string routeDetails: ""

    Component.onCompleted: {
        dumpLegs(route_index, routeModel)
    }

    function dumpLegs(index, model) {
        // save used route index for dumping stops
        appWindow.itinerariesIndex = index
        var countOfLegs = appWindow.itinerariesModel.get(route_index).legs.count
        for (var legindex = 0; legindex < countOfLegs; ++legindex) {
            var legdata = appWindow.itinerariesModel.get(route_index).legs.get(legindex)
            var station = {}
            station.type = "station"
            station.name = legdata.from.name ? legdata.from.name : ''
            station.time = legdata.from.time
            station.code = ""
            if (legindex !== 0) {
                station.shortCode = legdata.from.shortCode
            }
            station.length = legdata.distance
            station.duration = 0
            station.leg_number = ""
            var shortCodeText = typeof(station.shortCode) === "undefined" ? "" : "(" + station.shortCode + ")"
            routeDetails += (Qt.formatTime(station.time, "hh:mm") + " " + station.name + shortCodeText + "\n")
            if (legdata.type === "walk") {
                routeDetails += (qsTr("Walking") + ", " + Math.floor(legdata.length/100)/10 + " " + qsTr("km") + "\n")
            } else {
                routeDetails += qsTr(Helper.capitalize_string(legdata.type))
                routeDetails += (" " + legdata.code + ", " + legdata.duration + " " + qsTr("min") + "\n")
            }
            model.append(station)
            model.append(legdata)
        }
        var last_location = appWindow.itinerariesModel.get(route_index).legs.get(countOfLegs  - 1)
        var last_station = {"type" : "station",
                            "name" : last_location.to.name,
                            "time" : last_location.to.time,
                            "leg_number" : ""}

        model.append(last_station)
        appWindow.coverAlignment = Text.AlignLeft
        appWindow.coverHeader = start_time.slice(11,16) + " - " + finish_time.slice(11,16)
        appWindow.coverContents = routeDetails
        model.done = true
    }

    ListModel {
        id: routeModel
        property bool done: false
    }

    Component {
        id: delegate
        Loader {
            width: parent.width
            source: type == "station" ?  "../components/RouteStationDelegate.qml" : "../components/RouteDelegate.qml"
        }
    }

    SilicaListView {
        id: routeList
        anchors.fill: parent
        model: routeModel
        delegate: delegate
        interactive: !busyIndicator.visible

        VerticalScrollDecorator {}

        header: Column {
            width: parent.width
            PageHeader {
                title: qsTr("%1 minutes").arg(duration)
            }

            Label {
                width: parent.width
                text: qsTr("Walking %1 km").arg(walking)
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignRight
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingSmall
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                text: header
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignRight
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingSmall
                wrapMode: Text.WordWrap
            }
        }

        ViewPlaceholder {
            enabled: (!busyIndicator.visible && routeModel.count == 0)
            text: qsTr("No results")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Copy details to Clipboard")
                onClicked: {
                    Clipboard.text = routeDetails
                    appWindow.useNotification( qsTr("Route details copied to Clipboard") )
                }
            }
            MenuItem {
                text: qsTr("Map")
                onClicked: { pageStack.push(Qt.resolvedUrl("RouteMapPage.qml")) }
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(routeModel.done)
        running: true
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }
}
