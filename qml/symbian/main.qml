/*
 * This file is part of the Meegopas, more information at www.gitorious.org/meegopas
 *
 * Author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * See full license at http://www.gnu.org/licenses/gpl-3.0.html
 */

import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "UIConstants.js" as UIConstants

PageStackWindow {
    id: appWindow
    initialPage: MainPage {}
    showStatusBar: appWindow.inPortrait

    property alias banner : banner
    property variant scaling_factor : 0.75
    property bool positioning_active : true
    property bool follow_mode : false
    property bool map_visible : false
    property string colorscheme : "default"

    Item {
        id: theme
        property bool inverted : true
    }

    Label {
        id: title
        text: "Meegopas"
        visible: appWindow.inPortrait
    }

    InfoBanner {
        id: banner
        property bool success : false
        iconSource: success ? "qrc:/images/banner_green.png":"qrc:/images/banner_red.png"
        function show() {
            banner.open()
        }
    }

    ToolBarLayout {
        id: commonTools
        visible: false
        ToolButton { iconSource: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
        ToolButton { iconSource: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        MenuLayout {
            MenuItem { text: qsTr("Settings"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
            MenuItem { text: qsTr("Manage favorites"); onClicked: pageStack.push(Qt.resolvedUrl("FavoritesPage.qml")) }
            MenuItem { text: qsTr("Exception info"); onClicked: pageStack.push(Qt.resolvedUrl("ExceptionsPage.qml")) }
            MenuItem { text: qsTr("About"); onClicked: about.open() }
        }
    }

    AboutDialog { id: about }
}
