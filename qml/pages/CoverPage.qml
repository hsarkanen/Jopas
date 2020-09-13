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
import "../js/storage.js" as Storage
import "../js/favorites.js" as Favorites
import "../js/helper.js" as Helper
import "./components"

CoverBackground {
    id: appCover
    states: [
        State {
            name: "initial"
            PropertyChanges {target: favoritesView; visible: true; enabled: true }
            PropertyChanges {target: searchView; visible: false; enabled: false }
            PropertyChanges {target: itinerariesView; visible: false; enabled: false }
            PropertyChanges {target: routeView; visible: false; enabled: false }
            PropertyChanges {target: routeIndicator; visible: false; enabled: false }
            PropertyChanges {target: coverHeader; enabled: true; text: "Favorites" }
        },
        State {
            name: "search"
            PropertyChanges {target: favoritesView; visible: false; enabled: false }
            PropertyChanges {target: searchView; visible: true; enabled: true }
            PropertyChanges {target: itinerariesView; visible: false; enabled: false }
            PropertyChanges {target: routeView; visible: false; enabled: false }
            PropertyChanges {target: routeIndicator; visible: false; enabled: false }
            PropertyChanges {target: coverHeader; enabled: true; text: qsTr("To") }
        },
        State {
            name: "result"
            PropertyChanges {target: favoritesView; visible: false; enabled: false }
            PropertyChanges {target: searchView; visible: false; enabled: false }
            PropertyChanges {target: itinerariesView; visible: true; enabled: true }
            PropertyChanges {target: routeView; visible: false; enabled: false }
            PropertyChanges {target: routeIndicator; visible: false; enabled: false }
            PropertyChanges {target: coverHeader; visible: false; enabled: false }
        },
        State {
            name: "route"
            PropertyChanges {target: favoritesView; visible: false; enabled: false }
            PropertyChanges {target: searchView; visible: false; enabled: false }
            PropertyChanges {target: itinerariesView; visible: false; enabled: false }
            PropertyChanges {target: routeView; visible: true; enabled: true }
            PropertyChanges {target: routeIndicator; visible: true; enabled: true }
            PropertyChanges {target: coverHeader; visible: false; enabled: false }
        }
    ]

    Label {
        id: coverHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Theme.paddingSmall
        anchors.horizontalCenter: parent.horizontalCenter
        maximumLineCount: 2
        horizontalAlignment: Text.AlignHCenter
        color: Theme.highlightColor
        wrapMode: Text.Wrap
    }

    SilicaListView {
        id: favoritesView
        anchors.top: coverHeader.bottom
        anchors.bottom: coverActionArea.top
        clip: true
        model: favoriteRoutesModel
        width: parent.width
        interactive: false

        delegate: CoverFavoritesDelegate {}
    }

    SilicaListView {
        visible: false
        enabled: false
        anchors.top: coverHeader.bottom
        anchors.bottom: coverActionArea.top
        id: searchView
        model: ListModel {}
        width: parent.width
        interactive: false

        delegate: CoverSearchDelegate {}
    }

    SilicaListView {
        id: itinerariesView
        anchors.top: parent.top
        anchors.bottom: coverActionArea.top
        visible: false
        enabled: false
        model: itinerariesModel
        width: parent.width
        interactive: false

        delegate: CoverResultDelegate {}
        ViewPlaceholder {
            anchors.centerIn: parent
            visible: (!busyIndicator.running && itinerariesModel.count == 0)
            text: qsTr("No results")
        }
        BusyIndicator {
            id: busyIndicator
            running: !itinerariesModel.done
            size: BusyIndicatorSize.Medium
            anchors.centerIn: parent
        }
    }

    Row {
        id: routeIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
        enabled: false
        Rectangle {
            color: Theme.secondaryColor
            border.color: Theme.primaryColor
            border.width: 1
            opacity:0.2

            radius: 5
            smooth: true

            height: indicatorRepeater.height
            width: indicatorRepeater.width

            anchors {
                verticalCenter: routeIndicator.verticalCenter
            }
        }
        Repeater {
            id:indicatorRepeater
            model: routeModel
            anchors.horizontalCenter: parent.horizontalCenter
            delegate: Rectangle {
                anchors {
                    verticalCenter: routeIndicator.verticalCenter
                }
                height: routeIcon.height
                width: routeIcon.width
                color: "transparent"
                Rectangle {
                    color: Theme.secondaryColor
                    border.color: Theme.primaryColor
                    border.width: 1
                    opacity:(routeView.currentIndex == index ? 1 : 0.2)

                    radius: 5
                    smooth: true

                    height: routeIcon.height
                    width: routeIcon.width

                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
                Image {
                    id: routeIcon
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    height: routeView.count > 5 ? (appCover.width-2*Theme.paddingSmall)/routeView.count : (appCover.width-2*Theme.paddingSmall)/5
                    source: type !== "logo" ? "qrc:/images/" + type + ".png" : "qrc:logo"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    SilicaListView {
        id: routeView
        model: routeModel
        width: parent.width
        visible: false
        enabled: false
        interactive: false
        orientation: Qt.Horizontal
        anchors.left: parent.left
        anchors.top: routeIndicator.bottom
        anchors.bottom: coverAction.top

        delegate: CoverRouteDelegate {}
    }

    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: "image://theme/icon-cover-transfers"
            onTriggered: {
                switch(state) {
                case "initial":
                    favoritesView.currentIndex >= favoritesView.count - 1 ? favoritesView.currentIndex = 0 : favoritesView.incrementCurrentIndex()
                    break
                case "search":
                    searchView.currentIndex >= searchView.count - 1 ? searchView.currentIndex = 0 : searchView.incrementCurrentIndex()
                    break
                case "result":
                    itinerariesView.currentIndex >= itinerariesView.count - 1 ? itinerariesView.currentIndex = -1 : itinerariesView.incrementCurrentIndex()
                    break
                case "route":
                    routeView.currentIndex >= routeView.count - 1 ? routeView.currentIndex = 0 : routeView.incrementCurrentIndex()
                    break
                }

            }
        }

        CoverAction {
            iconSource: {
                switch(state) {
                case "initial":
                    return "image://theme/icon-cover-next"
                case "search":
                    if (searchView.currentIndex === searchView.count - 1) return "image://theme/icon-cover-previous"
                    return "image://theme/icon-cover-next"
                case "route":
                    return "image://theme/icon-cover-previous"
                case "result":
                    if (itinerariesView.currentIndex === -1) return "image://theme/icon-cover-previous"
                    return "image://theme/icon-cover-next"
                default:
                    return "image://theme/icon-cover-next"
                }
            }
            onTriggered: {
                switch(state) {
                case "route":
                    pageStack.pop()
                    break
                case "result":
                    if (itinerariesView.currentIndex === -1) pageStack.navigateBack()
                    else {
                        var route = itinerariesModel.get(itinerariesView.currentIndex)
                        pageStack.push(Qt.resolvedUrl("../pages/RoutePage.qml"), { route_index: itinerariesView.currentIndex,
                           header: locationParameters.from.name + " - " + locationParameters.to.name,
                           duration: route.duration,
                           walking: Math.floor(route.walk/100)/10,
                           start_time: route.start,
                           finish_time: route.finish
                       })
                    }
                    break
                case "initial":
                    searchView.model.clear()
                    var from = favoriteRoutesModel.get(favoritesView.currentIndex).modelFromName
                    var to = favoriteRoutesModel.get(favoritesView.currentIndex).modelToName
                    searchView.model.append({label: to, value: false})
                    searchView.model.append({label: from, value: true})
                    searchView.model.append({label: qsTr("Cancel")})
                    state = "search"
                    break
                case "search":
                    if (searchView.currentIndex === searchView.count - 1) state = "initial"
                    else {
                        var favorite = favoriteRoutesModel.get(favoritesView.currentIndex)
                        var reverse = searchView.model.get(searchView.currentIndex).value
                        appWindow.locationParameters.from.name = reverse ? favorite.modelToName : favorite.modelFromName
                        appWindow.locationParameters.from.coord = reverse ? favorite.modelToCoord : favorite.modelFromCoord
                        appWindow.locationParameters.to.name = reverse ? favorite.modelFromName : favorite.modelToName
                        appWindow.locationParameters.to.coord = reverse ? favorite.modelFromCoord : favorite.modelToCoord
                        mainPage.setTimeNow()
                        mainPage.setSearchParameters({})
                        mainPage.updateValues(appWindow.locationParameters.from.name, appWindow.locationParameters.to.name)
                        pageStack.navigateForward()
                        state = "result"
                    }
                    break
                }
            }
        }
    }

    function resetIndex(){
        favoritesView.currentIndex = 0
        searchView.currentIndex = 0
        itinerariesView.currentIndex = 0
        routeView.currentIndex = 0
    }
}
