import QtQuick 2.6
import Sailfish.Silica 1.0


MouseArea {
    id: popup
    z: 10
    width: parent.width
    height: parent.height
    visible: opacity > 0
    opacity: 0.0
    onClicked: {
        hide()
    }

    // UI variables
    property var hideBackColor : Theme.rgba(Theme.overlayBackgroundColor, 0.9)
    property string headlineInfoText : ""
    property string detailedInfoText : ""
    property string otherInfoText : ""
    property string filePath_Action : ""

    Behavior on opacity {
        FadeAnimator {}
    }

    Rectangle {
        anchors.fill: parent
        color: hideBackColor
        onColorChanged: opacity = 4

        Rectangle {
            id: idBackgroundRectProject
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: parent.width
            height: parent.height - anchors.topMargin - Theme.paddingLarge
            radius: Theme.paddingLarge

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: addExpenseColumn.height
                clip: true

                Column {
                    id: addExpenseColumn
                    width: parent.width
                    topPadding: Theme.paddingLarge
                    bottomPadding: Theme.paddingLarge

                    Label {
                        x: Theme.paddingLarge
                        width: parent.width - 2*x
                        wrapMode: Text.WordWrap
                        text: headlineInfoText
                        bottomPadding: Theme.paddingLarge
                    }
                    Label {
                        x: Theme.paddingLarge
                        width: parent.width - 2*x
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeTiny
                        text: detailedInfoText
                        bottomPadding: Theme.paddingLarge
                    }
                    Row {
                        x: Theme.paddingLarge
                        width: parent.width - 2*x
                        topPadding: Theme.paddingLarge
                        bottomPadding: Theme.paddingLarge

                        Button {
                            id: idButton1
                            width: parent.width /2 - Theme.paddingLarge /2
                            onClicked: {
                                restoreProjectExpenses(filePath_Action, "replace")
                                //backNavigationBlocked_deletedAddedProject = true
                                hide()
                            }
                        }
                        Item {
                            width: Theme.paddingLarge
                            height: 1
                        }
                        Button {
                            id: idButton2
                            width: parent.width /2 - Theme.paddingLarge /2
                            height: idButton1.height
                            onClicked: {
                                restoreProjectExpenses(filePath_Action, "merge")
                                //backNavigationBlocked_deletedAddedProject = true
                                hide()
                            }
                        }
                    }

                    Label {
                        x: Theme.paddingLarge
                        width: parent.width - 2*x
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.secondaryColor
                        text: otherInfoText
                        topPadding: Theme.paddingLarge
                        bottomPadding: Theme.paddingLarge
                    }

                }
            }
        }
    }
    Icon {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: idBackgroundRectProject.anchors.topMargin / 2 - height/2
        source: "image://theme/icon-splus-cancel?"
        opacity: 1
    }


    function notify( color, upperMargin, headText, bodyText, otherText, choiceText_1, choiceText_2, filePath ) {
        // color settings
        if (color && (typeof(color) != "undefined")) {
            idBackgroundRectProject.color = color
        } else {
            idBackgroundRectProject.color = Theme.rgba(Theme.highlightBackgroundColor, 0.9)
        }

        // position settings
        if (upperMargin && (typeof(upperMargin) != "undefined")) {
            idBackgroundRectProject.anchors.topMargin = upperMargin
        } else {
            idBackgroundRectProject.anchors.topMargin = 0
        }

        // set texts
        headlineInfoText = headText
        detailedInfoText = bodyText
        otherInfoText = otherText
        idButton1.text = choiceText_1
        idButton2.text = choiceText_2
        filePath_Action = filePath

        // show banner overlay
        popup.opacity = 1.0
    }

    function hide() {
        popup.opacity = 0.0
    }

}

