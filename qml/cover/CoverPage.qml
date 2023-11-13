import QtQuick 2.6
import Sailfish.Silica 1.0
import "../pages"

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
        source: "/usr/share/icons/hicolor/172x172/apps/harbour-expenditure.png"
        width: Theme.iconSizeLarge
        height: Theme.iconSizeLarge
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit
    }
    BannerAddExpense {
        id: bannerAddExpense
    }


    CoverActionList {
        id: coverAction

        CoverAction {
            onTriggered: {
                if(Number(storageItem.getSettings("activeProjectID_unixtime", 0)) !== 0) {
                    main.activate()
                    bannerAddExpense.notify( Theme.rgba(Theme.highlightDimmerColor, 1), Theme.itemSizeLarge, "new", activeProjectID_unixtime, 0 )
                }

            }

            iconSource: "image://theme/icon-cover-add"
        }
    }
}
