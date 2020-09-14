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
import "../js/reittiopas.js" as Reittiopas
import "../js/storage.js" as Storage
import "../js/favorites.js" as Favorites
import "../components"
import "./components"

Dialog {
    id: mainPage
    forwardNavigation: true
    canNavigateForward: paramsValid
    canAccept: paramsValid
    acceptDestination: Qt.resolvedUrl("ResultPage.qml")

    /* ReittiOpas query params */
    property bool paramsValid
    property variant searchParameters

    onAcceptPendingChanged: {
        if(status >= PageStatus.Active) {
            mainPage.acceptDestinationInstance.search_parameters = searchParameters
            mainPage.acceptDestinationInstance.startSearch()
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            appWindow.cover.state = "initial"
        }
    }

    function refreshFavoriteRoutes() {
            favoriteRoutesModel.clear()
            Favorites.getFavoriteRoutes("normal", appWindow.currentApi, favoriteRoutesModel)
    }

    function updateValues() {
        planner.updateValues(appWindow.locationParameters.from.name, appWindow.locationParameters.to.name)
    }

    function setTimeNow(){
        planner.timeButton.setTimeNow()
    }

    Component.onCompleted: {
        setTimeNow()
        appWindow.currentApi = Storage.getSetting("api")
        refreshFavoriteRoutes()
    }

    states: [
        State {
            name: "normal"
        },
        State {
            name: "waiting_route"
        }
    ]

    state: "normal"

    function setSearchParameters(parameters) {
        try {
            appWindow.setSearchParameters(parameters)
        } catch (err) {
            console.log("setSearchParameters", err)
        }
        if(!!parameters.from_name || !!parameters.from || !!parameters.to_name || !!parameters.to) {
            searchParameters = parameters
            paramsValid = true
            return
        }
        paramsValid = false
    }

    Rectangle {
        id: waiting
        color: "black"
        z: 250
        opacity: mainPage.state == "normal" ? 0.0 : 0.7

        Behavior on opacity {
            PropertyAnimation { duration: 200 }
        }

        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            enabled: mainPage.state != "normal"
            onClicked: mainPage.state = "normal"
        }
    }

    BusyIndicator {
        id: busyIndicator
        z: 260
        running: mainPage.state != "normal"
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }
    ExpandingBottomDrawer {
        id: drawer
        anchors.fill: parent
        startPoint: 0
        SilicaFlickable {
            id: form
            anchors.fill: parent
            contentHeight: parent.height
            PullDownMenu {
                enabled: !drawer.open
                MenuItem { text: qsTr("Settings"); onClicked: { pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
                MenuItem { text: qsTr("Exception info"); visible: appWindow.currentApi === "helsinki"; onClicked: pageStack.push(Qt.resolvedUrl("ExceptionsPage.qml")) }
                MenuItem { text: qsTr("Manage favorite places"); onClicked: pageStack.push(Qt.resolvedUrl("FavoritesPage.qml")) }
                MenuItem {
                    enabled: paramsValid
                    text: qsTr("Add as favorite route");
                    onClicked: {
                        var res = Favorites.addFavoriteRoute(
                            "normal",
                            appWindow.currentApi,
                            appWindow.locationParameters.from.coord ? appWindow.locationParameters.from.coord : appWindow.locationParameters.gps.coord,
                            appWindow.locationParameters.from.name ? appWindow.locationParameters.from.name : appWindow.locationParameters.gps.name,
                            appWindow.locationParameters.to.coord,
                            appWindow.locationParameters.to.name,
                            favoriteRoutesModel
                        )
                        if (res === "OK") {
                            appWindow.useNotification( qsTr("Favorite route added") )
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Get Return Route");
                    onClicked: {
                        var fromObj = JSON.parse(JSON.stringify(appWindow.locationParameters.from))
                        var toObj = JSON.parse(JSON.stringify(appWindow.locationParameters.to))
                        appWindow.locationParameters.from = toObj
                        appWindow.locationParameters.to = fromObj
                        planner.updateValues(appWindow.locationParameters.from.name || "Choose Location", appWindow.locationParameters.to.name || "Choose Location")
                        setSearchParameters({})
                    }
                }
                onActiveChanged: {
                    if (active) {
                        drawer.startPoint = 0
                    } else {
                        drawer.startPoint = Screen.height - headeritem.y - headeritem.height
                    }
                }
            }
            MouseArea {
                enabled: drawer.open
                anchors.fill: parent
                onClicked: drawer.open = false
            }
            PageHeader { id: header ; title: qsTr("Search")}
            RoutePlanner {
                id: planner
                enabled: !drawer.open
                onParamsChanged: setSearchParameters(params)
            }
            SectionHeader {
                id: headeritem
                text: qsTr("Favorite routes")
                anchors.top: planner.bottom
                onYChanged: {
                    var start = Screen.height - headeritem.y - headeritem.height
                    if(start < Screen.height/2) drawer.startPoint = Screen.height - headeritem.y - headeritem.height
                }
            }
        }
        background: SilicaListView {
            id: favoriteRouteList
            anchors.fill: parent
            width: parent.width
            model: favoriteRoutesModel
            delegate: favoriteRouteManageDelegate
            property Item contextMenu

            ViewPlaceholder {
                enabled: favoriteRouteList.count == 0
                verticalOffset: - drawer.startPoint * 0.5
                text: qsTr("No saved favorite routes")
            }
            Label {
                text: qsTr("Press to expand")
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryHighlightColor
                visible: !drawer.open && favoriteRouteList.count > 0
            }
            MouseArea {
                enabled: !drawer.open
                anchors.fill: favoriteRouteList
                onClicked: drawer.open = favoriteRouteList.count == 0 ? false : true
            }
            VerticalScrollDecorator {}
            Component {
                id: contextMenuComponent

                ContextMenu {
                    id: menu
                    property Item currentItem
                    MenuItem {
                        text: qsTr("Get Return Route")
                        onClicked: menu.currentItem.search(true)
                    }

                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: menu.currentItem.remove()
                    }
                }
            }

            Component {
                id: favoriteRouteManageDelegate

                BackgroundItem {
                    id: rootItem
                    width: ListView.view.width
                    height: menuOpen ? Theme.itemSizeSmall + favoriteRouteList.contextMenu.height : Theme.itemSizeSmall

                    property bool menuOpen: favoriteRouteList.contextMenu != null && favoriteRouteList.contextMenu.parent === rootItem

                    function addToCover() {
                        Favorites.addFavoriteRoute('cover', appWindow.currentApi, modelFromCoord, modelFromName, modelToCoord, modelToName)
                        appWindow.useNotification( qsTr("Favorite route added to cover action.") )
                    }

                    function remove() {
                        remorse.execute(rootItem, qsTr("Deleting"), function() {
                            Favorites.deleteFavoriteRoute(modelRouteIndex, appWindow.currentApi, favoriteRoutesModel)
                        })
                    }

                    function search(reverse) {
                        appWindow.locationParameters.from.name = reverse ? modelToName : modelFromName
                        appWindow.locationParameters.from.coord = reverse ? modelToCoord : modelFromCoord
                        appWindow.locationParameters.to.name = reverse ? modelFromName : modelToName
                        appWindow.locationParameters.to.coord = reverse ? modelFromCoord : modelToCoord
                        planner.updateValues(appWindow.locationParameters.from.name, appWindow.locationParameters.to.name)
                        setSearchParameters({})
                        pageStack.navigateForward()
                    }

                    onClicked: search()

                    onPressAndHold: {
                        if (!favoriteRouteList.contextMenu) {
                            favoriteRouteList.contextMenu = contextMenuComponent.createObject(favoriteRouteList)
                        }

                        favoriteRouteList.contextMenu.currentItem = rootItem
                        favoriteRouteList.contextMenu.open(rootItem)
                    }

                    Label {
                        id: label
                        height: Theme.itemSizeSmall
                        text: modelFromName + " - " + modelToName + " "
                        width: parent.width
                        color: drawer.open ? Theme.primaryColor : Theme.secondaryColor
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                    RemorseItem { id: remorse }
                }
            }
        }
    }
}
