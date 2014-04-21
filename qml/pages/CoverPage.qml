/**********************************************************************
*
* This file is part of the Jopas, forked from Meegopas.
* More information:
*
*   https://github.com/rasjani/Jopas
*   https://github.com/junousia/Meegopas
*
* Author: Jani Mikkonen <jani.mikkonen@gmail.com>
* Original author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
* Other contributors:
*   Jonni Rainisto <jonni.rainisto@gmail.com>
*   Mohammed Samee <msameer@foolab.org>r
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../js/UIConstants.js" as UIConstants

CoverBackground {

    property string coverLine1: appWindow.coverLine1
    property string coverLine2: appWindow.coverLine2
    property string coverLine3: appWindow.coverLine3
    property string coverLine4: appWindow.coverLine4
    property string coverLine5: appWindow.coverLine5
    property string coverLine6: appWindow.coverLine6

    Label {
        id: label
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: UIConstants.DEFAULT_MARGIN / 2
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        text: coverLine1 + "\n" + coverLine2 + "\n" + coverLine3 + "\n" + coverLine4 + "\n" + coverLine5 + "\n" + coverLine6
        wrapMode: Text.WordWrap
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                console.log("coverLeftClicked")
                appWindow.activate()
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                console.log("coverRightClicked")
                appWindow.activate()
            }
        }
    }
}
