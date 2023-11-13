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
    onOpacityChanged: {
        //if needed
    }

    // UI variables
    property var hideBackColor : Theme.rgba(Theme.overlayBackgroundColor, 0.9)
    property int amountBeneficiaries : listModel_activeProjectMembersTEMP.count
    property string modeEdit : "new"
    property real editItemIndex : -1 // -1=new, otherwise gives index of list

    property int tempProjectListIndex
    property bool showTextfieldMemberName : false
    property string timeStamp : ((new Date).getTime()).toString() // creates unix timestamp

    property string backupFilePath : ""

    // suppress blend to main window on this overlay, e.g. for context menu ...
    // BUG: creates problems with _selectOrientation for context menus larger than 5 entries
    property alias __silica_applicationwindow_instance: fakeApplicationWindow
    Item {
        id: fakeApplicationWindow
        // suppresses warnings by context menu
        property var _dimScreen
        property var _undim
        function _undim() {}
        function _dimScreen() {}
    }
    Behavior on opacity {
        FadeAnimator {}
    }
    ListModel {
        id: listModel_activeProjectMembersTEMP
    }
    RemorsePopup {
        z: 10
        id: remorse_deleteProject
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

                    Row {
                        x: Theme.paddingLarge
                        width: parent.width - 2*x
                        topPadding: Theme.paddingLarge
                        bottomPadding: Theme.paddingLarge

                        Column {
                            id: idColumnAddProject
                            width: parent.width /3*2 - Theme.paddingLarge /2

                            Label {
                                width: parent.width
                                text: qsTr("Project")
                            }
                            Label {
                                width: parent.width
                                font.pixelSize: Theme.fontSizeTiny
                                text: (modeEdit === "new") ? (qsTr("create")) : (qsTr("edit"))
                            }
                        }
                        Item {
                            width: Theme.paddingLarge
                            height: 1
                        }
                        Button {
                            id: idLabelHeaderAdd2
                            enabled: (idTextfieldProjectname.length > 0)  && (amountBeneficiaries > 0)
                            width: parent.width /3 - Theme.paddingLarge /2
                            height: idColumnAddProject.height
                            text: (modeEdit === "new") ? qsTr("Add") : qsTr("Save")
                            onClicked: {
                                addProjectDB()
                            }
                        }
                    }
                    Row {
                        width: parent.width
                        topPadding: Theme.paddingLarge
                        bottomPadding: Theme.paddingLarge

                        TextField {
                            id: idTextfieldProjectname
                            width: parent.width /3 * 2 - Theme.paddingLarge
                            acceptableInput: text.length < 255
                            font.pixelSize: Theme.fontSizeMedium
                            EnterKey.onClicked: {
                                focus = false
                            }
                            Label {
                                anchors.top: parent.bottom
                                anchors.topMargin: Theme.paddingSmall
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                text: qsTr("name")
                            }
                        }
                        Item {
                            width: Theme.paddingLarge
                            height: 1
                        }
                        TextField {
                            id: idTextfieldCurrencyProject
                            width: parent.width /3
                            textLeftMargin: 0
                            horizontalAlignment: TextInput.AlignRight
                            acceptableInput: text.length > 0
                            EnterKey.enabled: text.length >= 0
                            EnterKey.onClicked: {
                                focus = false
                            }
                            onFocusChanged: {
                                if (text.length === 0) {
                                    text = recentlyUsedCurrency
                                }
                                if (focus) {
                                    selectAll()
                                }
                            }

                            Label {
                                anchors.right: parent.right
                                anchors.top: parent.bottom
                                anchors.topMargin: Theme.paddingSmall
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                text: qsTr("base currency")
                            }
                        }
                    }
                    Row {
                        x: Theme.paddingLarge
                        width: parent.width - 2*x
                        topPadding: Theme.paddingLarge

                        Label {
                            x: Theme.paddingLarge
                            width: parent.width/ 3*2 - Theme.paddingLarge / 2
                            height: idAddMemberButton.height
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Theme.fontSizeMedium
                            text: qsTr("Members")
                        }
                        Item {
                            width: Theme.paddingLarge
                            height: 1
                        }
                        Item {
                            id: idAddMemberButton
                            width: parent.width / 3 - Theme.paddingLarge/2
                            height: Theme.iconSizeMedium

                            Icon {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                height: parent.height
                                width: height
                                source: !showTextfieldMemberName ? "image://theme/icon-m-add?" : "image://theme/icon-m-clear?"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    showTextfieldMemberName ? showTextfieldMemberName=false : showTextfieldMemberName=true
                                    if (showTextfieldMemberName) {
                                        // clear field and set for new member
                                        editItemIndex = -1 // -1=add new member
                                        idTextfieldAddMember.text = ""
                                        idTextfieldAddMember.forceActiveFocus()
                                    } else {
                                        idTextfieldAddMember.text = ""
                                        idTextfieldAddMember.focus = false
                                    }
                                }
                            }
                        }
                    }
                    Column {
                        visible: !showTextfieldMemberName
                        width: parent.width

                        Repeater {
                            model: listModel_activeProjectMembersTEMP
                            delegate: ListItem {
                                contentHeight: Theme.itemSizeExtraSmall
                                menu: ContextMenu {
                                    MenuItem {
                                        text: qsTr("rename")
                                        onClicked: {
                                            showTextfieldMemberName ? showTextfieldMemberName=false : showTextfieldMemberName=true
                                            editItemIndex = index
                                            idTextfieldAddMember.text = member_name
                                            idTextfieldAddMember.forceActiveFocus()
                                        }
                                    }
                                    MenuItem {
                                        text: qsTr("remove")
                                        onClicked: {
                                            listModel_activeProjectMembersTEMP.remove(index)
                                        }
                                    }
                                }

                                Row {
                                    x: Theme.paddingLarge
                                    width: parent.width - 2*x
                                    height: parent.height

                                    Label {
                                        width: parent.width
                                        height: parent.height
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.highlightColor
                                        text: member_name
                                    }
                                }
                            }
                        }
                    }
                    Row {
                        width: parent.width
                        visible: showTextfieldMemberName
                        topPadding: Theme.paddingMedium

                        TextField {
                            id: idTextfieldAddMember
                            width: parent.width // 3*2 - Theme.paddingLarge
                            acceptableInput: text.length < 255
                            font.pixelSize: Theme.fontSizeSmall
                            onActiveFocusChanged: {
                                if (!focus) {
                                    showTextfieldMemberName = false
                                    idTextfieldAddMember.text = ""
                                }
                            }
                            EnterKey.onClicked: {
                                if (text.length > 0) {
                                    if (editItemIndex === -1) { // -1=add new member
                                        listModel_activeProjectMembersTEMP.append({ member_name : idTextfieldAddMember.text,
                                                                                    member_isBeneficiary : true,
                                                                                    member_isPayer : false,
                                                                                })
                                    } else { // "edit" existing member name by index in listmodel
                                        listModel_activeProjectMembersTEMP.setProperty(editItemIndex, "member_name", idTextfieldAddMember.text)
                                    }
                                }
                                focus = false
                                showTextfieldMemberName = false
                            }
                            Label {
                                anchors.top: parent.bottom
                                anchors.topMargin: Theme.paddingSmall
                                font.pixelSize: Theme.fontSizeExtraSmall
                                text: qsTr("name")
                            }
                        }
                    }
                    Item {
                        width: parent.width
                        height: Theme.itemSizeSmall
                    }
                    Row {
                        width: parent.width
                        visible: (modeEdit === "edit") && (listModel_allProjects.count > 0) // make sure there is always one project left once created
                        spacing: Theme.paddingLarge
                        leftPadding: Theme.paddingLarge

                        Button {
                            id: idLabelDeleteProject
                            width: parent.width /3 - parent.spacing * 1.5
                            height: idColumnAddProject.height
                            color: Theme.errorColor
                            text: (Number(activeProjectID_unixtime) != Number(timeStamp)) ? qsTr("Delete") : qsTr("Reset")
                            onClicked: {
                                if (Number(activeProjectID_unixtime) != Number(timeStamp)) { // if it is not the active project, delete it
                                    remorse_deleteProject.execute(qsTr("Delete this project?"), function() {
                                                                                deleteProject()
                                                                            })
                                } else { // if active project
                                    remorse_deleteProject.execute(qsTr("Clear all transactions?"), function() {
                                                                                clearProject()
                                                                            })
                                }
                            }
                        }
                        Button {
                            id: idLabelBackupProject
                            width: parent.width /3 - parent.spacing * 1.5
                            height: idColumnAddProject.height
                            text: qsTr("Backup")
                            onClicked: {
                                // hide() // ToDo: maybe close this popup?
                                pageStack.push(idFolderPickerPage)
                            }
                        }
                        Button {
                            id: idLabelRestoreProject
                            width: parent.width /3 - parent.spacing
                            height: idColumnAddProject.height
                            text: qsTr("Restore")
                            onClicked: {
                                // hide() // ToDo: maybe close this popup?
                                pageStack.push(idFilePickerPage)
                            }
                        }
                    }
                    Item {
                        width: parent.width
                        height: Theme.itemSizeSmall / 2
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


    function notify( color, upperMargin, modeEditNew, indexCurrentProject ) {
        // color settings
        if (color && (typeof(color) != "undefined")) {
            idBackgroundRectProject.color = color
        }
        else {
            idBackgroundRectProject.color = Theme.rgba(Theme.highlightBackgroundColor, 0.9)
        }

        // position settings
        if (upperMargin && (typeof(upperMargin) != "undefined")) {
            idBackgroundRectProject.anchors.topMargin = upperMargin
        }
        else {
            idBackgroundRectProject.anchors.topMargin = 0
        }

        // adjust input fields
        tempProjectListIndex = indexCurrentProject
        listModel_activeProjectMembersTEMP.clear()
        if (modeEditNew === "new") {
            modeEdit = "new"
            timeStamp = ((new Date).getTime()).toString()
            idTextfieldCurrencyProject.text = recentlyUsedCurrency
            idTextfieldProjectname.text = ""
            idTextfieldProjectname.forceActiveFocus()
        } else { // edit project mode
            modeEdit = "edit"
            var tempProjectMembersArray = []
            tempProjectMembersArray = (listModel_allProjects.get(idComboboxProject.currentIndex).project_members).split(" ||| ")
            for (var i = 0; i < tempProjectMembersArray.length ; i++) {
                listModel_activeProjectMembersTEMP.append({ member_name : tempProjectMembersArray[i],
                                                        })
            }
            timeStamp = (listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp).toString()
            idTextfieldProjectname.text = listModel_allProjects.get(idComboboxProject.currentIndex).project_name
            idTextfieldCurrencyProject.text = listModel_allProjects.get(idComboboxProject.currentIndex).project_base_currency
        }

        // all members are beneficiaries


        // show banner overlay
        popup.opacity = 1.0
    }

    function hide() {
        idTextfieldProjectname.focus = false
        idTextfieldCurrencyProject.focus = false

        // clear all fields
        idTextfieldProjectname.text = ""
        idTextfieldCurrencyProject.text = recentlyUsedCurrency

        // make invisible
        popup.opacity = 0.0
    }

    function addProjectDB () {
        var project_id_timestamp = timeStamp
        var project_name = idTextfieldProjectname.text
        var project_members = ""
        var project_recent_payer_boolarray = ""
        var project_recent_beneficiaries_boolarray = ""
        var project_base_currency = idTextfieldCurrencyProject.text

        for (var i = 0; i < listModel_activeProjectMembersTEMP.count ; i++) {
            project_members += " ||| " + listModel_activeProjectMembersTEMP.get(i).member_name
            project_recent_beneficiaries_boolarray += " ||| " + "true"
            // recent_payer can only be one person, initially this will be the first entry of the list
            if (i===0) {
                project_recent_payer_boolarray += " ||| " + "true"
            } else {
                project_recent_payer_boolarray += " ||| " + "false"
            }
        }
        // remove first  occurance of " ||| " to later be able to split that string
        project_members = project_members.replace(" ||| ", "")
        project_recent_payer_boolarray = project_recent_payer_boolarray.replace(" ||| ", "")
        project_recent_beneficiaries_boolarray = project_recent_beneficiaries_boolarray.replace(" ||| ", "")

        if (modeEdit === "new") {
            // store in DB and list for new project
            storageItem.setProject( project_id_timestamp, project_name, project_members, project_recent_payer_boolarray, project_recent_beneficiaries_boolarray, project_base_currency )
            listModel_allProjects.append({ project_id_timestamp : Number(project_id_timestamp),
                                         project_name : project_name,
                                         project_members : project_members,
                                         project_recent_payer_boolarray : project_recent_payer_boolarray,
                                         project_recent_beneficiaries_boolarray : project_recent_beneficiaries_boolarray,
                                         project_base_currency : project_base_currency,
                                     })

            // if this is the first project, auto set it as active project
            if (listModel_allProjects.count === 1) { // auto-sets as currently active project, if this project is very first one
                storageItem.setSettings("activeProjectID_unixtime", Number(project_id_timestamp) )
                activeProjectID_unixtime = Number(project_id_timestamp)
                loadActiveProjectInfos_FromDB( Number(project_id_timestamp) )
                //console.log("auto set as active project ID = " + activeProjectID_unixtime)
            }

        } else { // modeEdit === "edit
            // update DB and list for existing project
            storageItem.updateProject( project_id_timestamp, project_name, project_members, project_recent_payer_boolarray, project_recent_beneficiaries_boolarray, project_base_currency )
            for (var j = 0; j < listModel_allProjects.count ; j++) {
                if (listModel_allProjects.get(j).project_id_timestamp === Number(project_id_timestamp)) {
                    //console.log("updated entry at: id_" +  project_id_timestamp)
                    listModel_allProjects.set(j, { "project_name" : project_name,
                                                  "project_members" : project_members,
                                                  "project_recent_payer_boolarray" : project_recent_payer_boolarray,
                                                  "project_recent_beneficiaries_boolarray" : project_recent_beneficiaries_boolarray,
                                                  "project_base_currency" : project_base_currency
                                              })
                }
            }
        }
        updateEvenWhenCanceled = true
        hide()
    }

    function deleteProject() {
        updateEvenWhenCanceled = true
        storageItem.deleteProject(timeStamp)
        listModel_allProjects.remove(tempProjectListIndex)
        // set active project to reasonable one
        if (idComboboxProject.currentIndex != 0) {
            idComboboxProject.currentIndex = idComboboxProject.currentIndex -1
        }
        //console.log("auto set after deleting ID = " + Number(listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp))
        loadActiveProjectInfos_FromDB(Number(listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp)) // needed to make sure there is no expense or member list still active
        hide()
    }

    function clearProject() {
        updateEvenWhenCanceled = true
        listModel_activeProjectExpenses.clear()
        storageItem.removeFullTable( "table_" + activeProjectID_unixtime.toString() )
        loadActiveProjectInfos_FromDB(Number(listModel_allProjects.get(idComboboxProject.currentIndex).project_id_timestamp)) // needed to make sure there is no expense or member list still active
        hide()
    }

}

