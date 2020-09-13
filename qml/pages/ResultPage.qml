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
    id: resultPage
    property var search_parameters
    property var search_interval

    function startSearch() {
        var settings_search_interval = Storage.getSetting("search_interval");
        search_interval = settings_search_interval === "Unknown" ? "15" : settings_search_interval;
        appWindow.itinerariesModel.clear()
        Reittiopas.get_route(search_parameters, appWindow.itinerariesModel,
                             appWindow.itinerariesJson, regions.getRegion());
    }

    function setCoverData() {
        appWindow.coverPage.resetIndex()
        appWindow.cover.state = "result"
    }

    Connections {
        target: appWindow.itinerariesModel
        // Update cover when performing the search for the first time
        onDoneChanged: {
            if (appWindow.itinerariesModel.done && (status == PageStatus.Activating || status == PageStatus.Active)) {
                setCoverData()
            }
        }
    }

    // Update cover when coming back to ResultPage from RoutePage
    onStatusChanged: {
        if (status == PageStatus.Activating && appWindow.itinerariesModel.done) {
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
                new_parameters.jstime.setMinutes(new_parameters.jstime.getMinutes() + parseInt(resultPage.search_interval))
                new_parameters.time = Qt.formatTime(new_parameters.jstime.getMinutes(), "hhmm")
                search_parameters = new_parameters

                startSearch()
            }

            Label {
                text: qsTr("Next (+%1 min)").arg(Math.floor(resultPage.search_interval))
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
        model: appWindow.itinerariesModel
        footer: footer
        delegate: ResultDelegate {}
        spacing: 10 * Theme.pixelRatio
        interactive: !busyIndicator.running
        header: Column {
            width: parent.width
            PageHeader {
                title: search_parameters ? search_parameters.timetype === "departure" ?
                           qsTr("Departure") + " " + Qt.formatDateTime(search_parameters.jstime,"dd.MM hh:mm") :
                           qsTr("Arrival") + " " + Qt.formatDateTime(search_parameters.jstime,"dd.MM hh:mm") : ""
            }

            Label {
                width: parent.width
                text: search_parameters ? search_parameters.from_name + " - " + search_parameters.to_name + " " : ""
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
                    new_parameters.jstime.setMinutes(new_parameters.jstime.getMinutes() - parseInt(resultPage.search_interval))
                    new_parameters.time = Qt.formatTime(new_parameters.jstime.getMinutes(), "hhmm")
                    search_parameters = new_parameters

                    startSearch()
                }

                Label {
                    text: qsTr("Previous (-%1 min)").arg(Math.floor(resultPage.search_interval))
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
            visible: (!busyIndicator.running && appWindow.itinerariesModel.count == 0)
            text: qsTr("No results")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Map")
                onClicked: { pageStack.push(Qt.resolvedUrl("ResultMapPage.qml")) }
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        running: !appWindow.itinerariesModel.done
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }
}
