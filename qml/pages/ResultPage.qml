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
import "../js/storage.js" as Storage
import "../components"

Page {
    property variant search_parameters

    Component.onCompleted: startSearch()

    function startSearch() {
        routeModel.clear()
        Reittiopas.new_route_instance(search_parameters, routeModel, Storage.getSetting('api'))
    }

    function setCoverData() {
        var route = Reittiopas.get_route_instance()
        appWindow.coverLine1 = search_parameters.from_name
        appWindow.coverLine2 = route.last_result[0].start.toString().slice(16,21) + " - " + route.last_result[0].finish.toString().slice(16,21)
        appWindow.coverLine3 = route.last_result[1].start.toString().slice(16,21) + " - " + route.last_result[1].finish.toString().slice(16,21)
        appWindow.coverLine4 = route.last_result[2].start.toString().slice(16,21) + " - " + route.last_result[2].finish.toString().slice(16,21)
        appWindow.coverLine5 = route.last_result[3].start.toString().slice(16,21) + " - " + route.last_result[3].finish.toString().slice(16,21)
        appWindow.coverLine6 = route.last_result[4].start.toString().slice(16,21) + " - " + route.last_result[4].finish.toString().slice(16,21)
    }

    ListModel {
        id: routeModel
        property bool done : false
        // Update cover when performing the search for the first time
        onDoneChanged: {
            if (done) {
                setCoverData()
            }
        }
    }
    // Update cover when coming back to ResultPage from RoutePage
    onStatusChanged: {
        if (status == PageStatus.Activating && routeModel.done) {
            setCoverData()
        }
    }

    Component {
        id: footer

        ListItem {
            height: Theme.itemSizeExtraSmall
            visible: !busyIndicator.running

            onClicked: {
                /* workaround to modify qml array is to make a copy of it,
                   modify the copy and assign the copy back to the original */
                var new_parameters = search_parameters
                new_parameters.time.setMinutes(new_parameters.time.getMinutes() + 15)
                search_parameters = new_parameters

                startSearch()
            }

            Label {
                text: qsTr("Next")
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.secondaryColor
            }
        }
    }


    SilicaListView {
        id: list
        anchors.fill: parent
        model: routeModel
        footer: footer
        delegate: ResultDelegate {}
        spacing: 10
        interactive: !busyIndicator.running
        header: Column {
            width: parent.width
            PageHeader {
                title: search_parameters.timetype == "departure" ?
                           qsTr("Departure") + " " + Qt.formatDateTime(search_parameters.time,"dd.MM hh:mm") :
                           qsTr("Arrival") + " " + Qt.formatDateTime(search_parameters.time,"dd.MM hh:mm")
            }

            Label {
                width: parent.width
                text: search_parameters.from_name + " - " + search_parameters.to_name + " "
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.WordWrap
            }

            ListItem {
                height: Theme.itemSizeExtraSmall
                visible: !busyIndicator.running

                onClicked: {
                    /* workaround to modify qml array is to make a copy of it,
                       modify the copy and assign the copy back to the original */
                    var new_parameters = search_parameters
                    new_parameters.time.setMinutes(new_parameters.time.getMinutes() - 15)
                    search_parameters = new_parameters

                    startSearch()
                }

                Label {
                    text: qsTr("Previous")
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.secondaryColor
                }
            }
            Spacing{id: headerSpacing; height: 10}
        }

        ViewPlaceholder {
            anchors.centerIn: parent
            visible: (!busyIndicator.running && routeModel.count == 0)
            text: qsTr("No results")
        }
    }

    BusyIndicator {
        id: busyIndicator
        running: !routeModel.done
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }
}