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
import "../components"

Dialog {
    property alias model: view.model
    property alias model2: view2.model
    property bool departure: true
    property variant resultObject
    id: fav_recent_dialog
    canNavigateForward: false
    forwardNavigation: true
    anchors.fill: parent
    PageHeader { id: header ; title: departure ? qsTr("Departure") : qsTr("Destination") }
    SectionHeader {
            anchors.top: header.bottom
            id: favoritesheaderitem
            text: qsTr("Favorites")
    }

    //Spacing { id: favoritesHeaderBottomSpacer; height: 30; anchors.top: favoritesheaderitem.bottom }

    SilicaListView {
        width: parent.width
        id: view
        anchors.top: favoritesheaderitem.bottom
        anchors.bottom: recentsearchesheaderitem.top
        delegate: SuggestionDelegate {
            model: view.model
            onClicked: {
                fav_recent_dialog.resultObject = view.model.get(index)
                console.log(JSON.stringify(resultObject))
                fav_recent_dialog.canNavigateForward = true
                fav_recent_dialog.accept()
            }
        }
        VerticalScrollDecorator {}
    }

    //Spacing { id: headerTopSpacer; height: 50; anchors.bottom: recentsearchesheaderitem.top }

    SectionHeader {
            anchors.verticalCenter: parent.verticalCenter
            id: recentsearchesheaderitem
            text: qsTr("Recent searches")
    }


    //Spacing { id: recentItemsHeaderBottomSpacer; height: 30; anchors.top: recentsearchesheaderitem.bottom }

    SilicaListView {
        id: view2
        width: parent.width
        anchors.top: recentsearchesheaderitem.bottom
        anchors.bottom: parent.bottom
        delegate: SuggestionDelegate {
            model: view2.model
            onClicked: {
                fav_recent_dialog.resultObject = view2.model.get(index)
                console.log(JSON.stringify(resultObject))
                fav_recent_dialog.canNavigateForward = true
                fav_recent_dialog.accept()
            }
        }
        VerticalScrollDecorator {}
    }
}
