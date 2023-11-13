import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    /*
    Label {
        id: label
        anchors.centerIn: parent
        text: qsTr("Expenditure")
    }
    */
    Image {
        id: name
        anchors.centerIn: parent
        source: "harbour-expenditure.png"
        width: Theme.iconSizeLarge
        height: Theme.iconSizeLarge
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit
    }
    /*
    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-pause"
        }
    }
    */
}
