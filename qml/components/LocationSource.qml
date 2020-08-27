import QtQuick 2.1
import Sailfish.Silica 1.0
import QtPositioning 5.3

Item {
    signal locationFound()
    signal noLocationSource()

    property alias timer: gpsTimer

    function positionValid(position) {
        if(position.latitudeValid && position.longitudeValid)
            return true
        else
            return false
    }

    function getCurrentCoord() {
        /* wait until position is accurate enough */
        if(positionSource.supportedPositioningMethods === PositionSource.NoPositioningMethods) {
            gpsTimer.stop()
            noLocationSource()
        } else if(positionValid(positionSource.position) && positionSource.position.horizontalAccuracy > 0 && positionSource.position.horizontalAccuracy < 100) {
            gpsTimer.stop()
            previousCoord.coordinate.latitude = positionSource.position.coordinate.latitude
            previousCoord.coordinate.longitude = positionSource.position.coordinate.longitude
            Reittiopas.get_reverse_geocode(
                previousCoord.coordinate.latitude.toString(),
                previousCoord.coordinate.longitude.toString(),
                currentLocationModel,
                Storage.getSetting('api')
            )
        } else {
            /* poll again in 200ms */
            gpsTimer.start()
        }
    }

    Location {
        id: previousCoord
        coordinate: QtPositioning.coordinate(0, 0)
    }

    Timer {
        id: gpsTimer
        onTriggered: getCurrentCoord()
        triggeredOnStart: true
        interval: 200
        repeat: true
    }

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: Qt.application.active
        onPositionChanged: {
            /* if we have moved >250 meters from the previous place, update current location */
            if(previousCoord.coordinate.latitude !== 0 && previousCoord.coordinate.longitude !== 0 &&
                    position.coordinate.distanceTo(previousCoord) > 250) {
                getCurrentCoord()
            }
        }
        onSourceErrorChanged: {
            console.log("sourceError", sourceError)
        }
    }

    ListModel {
        id: currentLocationModel
        property bool done: true

        onDoneChanged: {
            if (done) {
                /* There should be always just one result since query size=1 */
                if(currentLocationModel.count > 0) {
                    appWindow.locationParameters.gps = currentLocationModel.get(0)
                    locationFound()
                }
            }
        }
    }
}
