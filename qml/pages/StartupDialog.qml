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
import "../js/storage.js" as Storage
import "../components"

Dialog {
    SilicaFlickable {
        anchors.fill: parent
        Column {
            anchors.fill: parent

            DialogHeader {
                acceptText: defaultAcceptText
            }

            ComboBox {
                id: region
                label: qsTr("Choose region")
                menu: ContextMenu {
                    Repeater {
                        model: regions

                        delegate: MenuItem {
                            text: qsTranslate("main", model.name)
                            property string value: model.identifier
                        }
                    }
                }
            }
        }
    }
    onAccepted: {
        Storage.setSetting('api', region.currentItem.value === "Unknown" ? "helsinki" :
                                                                          region.currentItem.value);
        appWindow.currentApi = Storage.getSetting("api");
        Storage.setSetting("bus_disabled", "false");
        Storage.setSetting("ferry_disabled", "false");
        Storage.setSetting("tram_disabled", "false");
        Storage.setSetting("metro_disabled", "false");
        Storage.setSetting("train_disabled", "false");
        Storage.setSetting("change_margin", "3");
        Storage.setSetting("change_reluctance", "10");
        Storage.setSetting("walk_reluctance", "2");
        Storage.setSetting('walking_speed', "70");
        Storage.setSetting("search_interval", "15");
        Storage.setSetting("default_zoom_level", "5");
        Storage.setSetting("search_button_disabled", "false");
    }
}
