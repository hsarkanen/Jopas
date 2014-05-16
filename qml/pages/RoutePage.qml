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
import "../components"

Page {
    property int route_index
    property string from_name
    property string to_name
    property string header
    property string duration
    property string walking
    property string start_time
    property string finish_time
    property string departure_string: qsTr("Departure") + ":"
    property string arrival_string: qsTr("Arrival") + ":"

    Component.onCompleted: {
        var route = Reittiopas.get_route_instance()
        route.dump_legs(route_index, routeModel)
        from_name = route.from_name
        to_name = route.to_name

        appWindow.coverLine1 = departure_string
        appWindow.coverLine2 = start_time.slice(11,16)
        appWindow.coverLine3 = from_name
        appWindow.coverLine4 = arrival_string
        appWindow.coverLine5 = finish_time.slice(11,16)
        appWindow.coverLine6 = to_name
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
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                text: header
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignRight
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
                    Clipboard.text = departure_string + " " + Qt.formatDateTime(start_time,"dd.MM hh:mm") + "\n" + from_name + "\n\n" + arrival_string + " " + Qt.formatDateTime(finish_time,"dd.MM hh:mm") + "\n" + to_name
                    displayPopupMessage( qsTr("Route details copied to Clipboard") )
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

    // Added InfoBanner here as a workaround to display it correctly above all other UI elements, fixing the z-order from the one in main.qml isn't trivial
    InfoBanner {
        id: infoBanner
        z: 1
    }
    function displayPopupMessage(message) {
        infoBanner.displayError(message)
    }
}
