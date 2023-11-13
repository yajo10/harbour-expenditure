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
    property var activeProjectID
    property var hideBackColor : Theme.rgba(Theme.overlayBackgroundColor, 0.9)
    property int amountBeneficiaries : 0
    property string modeEdit : "new"
    property date currentDate
    property date currentTime
    property double editedTimeStamp // unixtime, can be edited, is NOT entry creation timestamp
    property double createdTimeStamp
    property bool dateTimeManuallyChanged : false


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


    Rectangle {
        anchors.fill: parent
        color: hideBackColor
        onColorChanged: opacity = 4

        Rectangle {
            id: idBackgroundRectExpenses
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
                        bottomPadding: Theme.paddingLarge * 2

                        Column {
                            id: idColumnAddDate
                            width: parent.width /3*2 - Theme.paddingLarge /2

                            Label {
                                width: parent.width
                                text: currentDate.toLocaleDateString(Qt.locale(), "dd. MMMM yyyy")
                                color: Theme.highlightColor

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        unFocusTextFields()
                                        var dialog = pageStack.push(datePickerComponent, {
                                            date: currentDate // preset picker to todays date
                                        } )
                                        dialog.accepted.connect( function () {
                                            currentDate = (dialog.date)
                                            editedTimeStamp = Number((combineDateAndTime(currentDate, currentTime)).getTime())
                                            dateTimeManuallyChanged = true
                                        } )
                                    }
                                }
                            }
                            Label {
                                width: parent.width
                                text: currentTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                                color: Theme.highlightColor

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        unFocusTextFields()
                                        var dialog = pageStack.push(timePickerComponent, {
                                            hour: currentTime.getHours(), // preset picker to current time
                                            minute: currentTime.getMinutes(),
                                            hourMode: 1
                                        } )
                                        dialog.accepted.connect( function () {
                                            currentTime = new Date ( dialog.time)
                                            editedTimeStamp = Number((combineDateAndTime(currentDate, currentTime)).getTime())
                                            dateTimeManuallyChanged = true
                                        } )
                                    }
                                }
                            }
                            /*
                            Label {
                                width: parent.width
                                font.pixelSize: Theme.fontSizeTiny
                                text: "create_" + createdTimeStamp
                            }
                            Label {
                                width: parent.width
                                font.pixelSize: Theme.fontSizeTiny
                                text: "edit_" + editedTimeStamp
                            }
                            */
                        }
                        Item {
                            width: Theme.paddingLarge
                            height: 1
                        }
                        Button {
                            id: idLabelHeaderAdd2
                            enabled: (idTextfieldItem.length > 0)  && (amountBeneficiaries > 0)
                            width: parent.width /3 - Theme.paddingLarge /2
                            height: idColumnAddDate.height
                            text: (modeEdit === "new") ? qsTr("Add") : qsTr("Save")
                            onClicked: {
                                addEditExpense()
                            }
                        }
                    }
                    TextField {
                        id: idTextfieldItem
                        width: page.width
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
                            text: qsTr("expense")
                        }
                    }
                    Row {
                        width: parent.width

                        TextField {
                            id: idTextfieldPrice
                            width: parent.width /3 + parent.width /6
                            textRightMargin: 0
                            inputMethodHints: Qt.ImhFormattedNumbersOnly //use "Qt.ImhDigitsOnly" for INT
                            text: Number("0").toFixed(2)
                            EnterKey.onClicked: {
                                focus = false
                            }
                            onFocusChanged: {
                                text = text.replace(",", ".")
                                text = Number(text).toFixed(2)
                                if (focus) {
                                    selectAll()
                                }
                            }

                            Label {
                                anchors.top: parent.bottom
                                anchors.topMargin: Theme.paddingSmall
                                font.pixelSize: Theme.fontSizeExtraSmall
                                color: Theme.secondaryColor
                                text: qsTr("price")
                            }
                        }
                        Item {
                            width: parent.width / 6
                            height: 1
                        }
                        TextField {
                            id: idTextfieldCurrency
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
                                text: qsTr("currency")
                            }
                        }
                    }
                    TextField {
                        id: idTextfieldInfo
                        width: page.width
                        //acceptableInput: text.length < 255
                        font.pixelSize: Theme.fontSizeMedium
                        EnterKey.onClicked: {
                            focus = false
                        }
                        Label {
                            anchors.top: parent.bottom
                            anchors.topMargin: Theme.paddingSmall
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                            text: qsTr("info")
                        }
                    }
                    Row {
                        x: Theme.paddingLarge
                        width: parent.width - 2*x
                        topPadding: Theme.paddingLarge * 2
                        bottomPadding: Theme.paddingMedium

                        Label {
                            width: parent.width / 2 - Theme.paddingLarge/2
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                            text: qsTr("payment by")
                        }
                        Item {
                            width: Theme.paddingLarge
                            height: 1
                        }
                        Label {
                            width: parent.width / 2 - Theme.paddingLarge/2
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.secondaryColor
                            text: qsTr("beneficiary")
                        }
                    }
                    Column {
                        x: Theme.paddingLarge
                        width: parent.width - 2*x

                        Repeater {
                            model: listModel_activeProjectMembers
                            delegate: Row {
                                id: idtestcolumn
                                width: parent.width

                                Label {
                                    id: idLabelPayerName
                                    width: parent.width / 3*2 - Theme.paddingLarge/2
                                    height: Theme.iconSizeSmallPlus
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.WordWrap
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: member_isPayer === "true"
                                    color: (member_isPayer === "true") ? Theme.primaryColor : Theme.highlightColor
                                    text: member_name

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            for (var i = 0; i < listModel_activeProjectMembers.count ; i++) {
                                                listModel_activeProjectMembers.setProperty(i, "member_isPayer", "false")
                                            }
                                            member_isPayer="true"
                                        }
                                    }
                                }
                                Item {
                                    width: Theme.paddingLarge
                                    height: 1
                                }
                                Item {
                                    width: parent.width / 3 - Theme.paddingLarge/2
                                    height: parent.height

                                    Icon {
                                        anchors.right: parent.right
                                        height: parent.height
                                        width: height
                                        color: (member_isPayer==="true") ? Theme.primaryColor : Theme.highlightColor
                                        source: (member_isBeneficiary==="true") ? "image://theme/icon-m-accept?" : ""

                                        Rectangle {
                                            z: -1
                                            anchors.centerIn: parent
                                            width: parent.width - Theme.paddingSmall
                                            height: width
                                            color: "transparent"
                                            border.width: (member_isPayer==="true") ? 2 : 1
                                            border.color: Theme.secondaryColor
                                            radius: width/4
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            anchors.leftMargin: -Theme.paddingLarge
                                            anchors.rightMargin: -Theme.paddingLarge
                                            onClicked: {
                                                (member_isBeneficiary==="true") ? (member_isBeneficiary="false") : (member_isBeneficiary="true")
                                                amountBeneficiaries = 0
                                                for (var i = 0; i < listModel_activeProjectMembers.count ; i++) {
                                                    if (listModel_activeProjectMembers.get(i).member_isBeneficiary === "true") {
                                                        amountBeneficiaries += 1
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
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
        anchors.topMargin: idBackgroundRectExpenses.anchors.topMargin / 2 - height/2
        source: "image://theme/icon-splus-cancel?"
        opacity: 1
    }



    function notify( color, upperMargin, modeEditNew, activeProjectID_unixtime, expense_ID_created ) {
        // color settings
        if (color && (typeof(color) != "undefined")) {
            idBackgroundRectExpenses.color = color
        }
        else {
            idBackgroundRectExpenses.color = Theme.rgba(Theme.highlightBackgroundColor, 0.9)
        }

        // position settings
        if (upperMargin && (typeof(upperMargin) != "undefined")) {
            idBackgroundRectExpenses.anchors.topMargin = upperMargin
        }
        else {
            idBackgroundRectExpenses.anchors.topMargin = 0
        }

        // project settings
        activeProjectID = activeProjectID_unixtime
        modeEdit = modeEditNew

        // reset time and date to current time and date
        if (modeEditNew === "new") {
            idTextfieldItem.text = ""
            idTextfieldPrice.text = "0"
            idTextfieldCurrency.text = recentlyUsedCurrency
            idTextfieldInfo.text = ""
            currentDate = new Date()
            currentTime = new Date()
            createdTimeStamp = Number(new Date().getTime())
            editedTimeStamp = Number(new Date().getTime())
        } else { // modeEditNew === "edit"
            //console.log("editing " + expense_ID_created)
            for (var i = 0; i < listModel_activeProjectExpenses.count ; i++) {
                if (Number(expense_ID_created) === Number(listModel_activeProjectExpenses.get(i).id_unixtime_created)) {
                    idTextfieldItem.text = listModel_activeProjectExpenses.get(i).expense_name
                    idTextfieldPrice.text = listModel_activeProjectExpenses.get(i).expense_sum
                    idTextfieldCurrency.text = listModel_activeProjectExpenses.get(i).expense_currency
                    idTextfieldInfo.text = listModel_activeProjectExpenses.get(i).expense_info
                    var olderDateTime = Number(listModel_activeProjectExpenses.get(i).date_time)
                    currentDate = new Date(olderDateTime)
                    currentTime = new Date (olderDateTime)
                    createdTimeStamp = Number(listModel_activeProjectExpenses.get(i).id_unixtime_created)
                    editedTimeStamp = Number(listModel_activeProjectExpenses.get(i).date_time)
                }
            }
        }

        // remember last beneficiaries and payer in "new" mode, load expense beneficiaries and payer in "edit" mode
        amountBeneficiaries = 0
        if (modeEditNew === "new") {

            // count beneficiaries
            for (i = 0; i < listModel_activeProjectMembers.count ; i++) {
                if (listModel_activeProjectMembers.get(i).member_isBeneficiary === "true") {
                    amountBeneficiaries += 1
                }
            }

            // use last used project specific beneficiaries and payers settings
            for (var j = 0; j < listModel_allProjects.count ; j++) {
                if ( Number(listModel_allProjects.get(j).project_id_timestamp) === Number(activeProjectID_unixtime) ) {
                    var activeProjectMembersArray = (listModel_allProjects.get(j).project_members).split(" ||| ")
                    var activeProjectRecentPayerArray = (listModel_allProjects.get(j).project_recent_payer_boolarray).split(" ||| ")
                    var activeProjectRecentBeneficiariesArray = (listModel_allProjects.get(j).project_recent_beneficiaries_boolarray).split(" ||| ")
                    for (var s = 0; s < activeProjectMembersArray.length ; s++) {
                        listModel_activeProjectMembers.set( s, {
                            "member_isBeneficiary" : activeProjectRecentBeneficiariesArray[s],
                            "member_isPayer" : activeProjectRecentPayerArray[s],
                        })
                    }
                }
            }
        } else { // "edit" mode

            // find item in expenses list for editing
            for (var k = 0; k < listModel_activeProjectExpenses.count ; k++) {
                if (Number(expense_ID_created) === Number(listModel_activeProjectExpenses.get(k).id_unixtime_created)) {
                    var editedBeneficiariesList = (listModel_activeProjectExpenses.get(k).expense_members).split(" ||| ")
                    var editPayersList =(listModel_activeProjectExpenses.get(k).expense_payer).split(" ||| ")

                    for (var l = 0; l < listModel_activeProjectMembers.count; l++) {
                        listModel_activeProjectMembers.setProperty(l, "member_isBeneficiary", "false")
                        listModel_activeProjectMembers.setProperty(l, "member_isPayer", "false")

                        // mark beneficiaries and get amount
                        for (var m = 0; m < editedBeneficiariesList.length; m++) {
                            if (listModel_activeProjectMembers.get(l).member_name === editedBeneficiariesList[m]) {
                                listModel_activeProjectMembers.setProperty(l, "member_isBeneficiary", "true")
                                amountBeneficiaries += 1
                            }
                        }
                        // mark payer
                        for (m = 0; m < editPayersList.length; m++) {
                            if (listModel_activeProjectMembers.get(l).member_name === editPayersList[m]) {
                                listModel_activeProjectMembers.setProperty(l, "member_isPayer", "true")
                            }
                        }
                    }
                }
            }
        }
        //console.log(amountBeneficiaries)

        // show banner overlay
        popup.opacity = 1.0

        // focus on expense text searchField
        if (modeEditNew === "new") {
            idTextfieldItem.forceActiveFocus()
        }
    }

    function hide() {
        unFocusTextFields()
        popup.opacity = 0.0 // make invisible

        // clear all fields
        idTextfieldItem.text = ""
        idTextfieldPrice.text = "0"
        idTextfieldCurrency.text = recentlyUsedCurrency
        idTextfieldInfo.text = ""
        //idButtonAddExpense.visible = true
    }

    function unFocusTextFields() {
        idTextfieldItem.focus = false
        idTextfieldPrice.focus = false
        idTextfieldCurrency.focus = false
        idTextfieldInfo.focus = false
    }

    function combineDateAndTime(date, time) {
        // warning: slice necessary to avoid singele digit outputs which can not be used in combined call
        var year = date.getFullYear();
        var month = ('0' + (date.getMonth() + 1)).slice(-2); // Jan is 0, dec is 11
        var day = ('0' + date.getDate()).slice(-2)
        //var month = date.getMonth() // only give one digit outputs <10, which causes errors later
        //var day = date.getDate(); // only gives one digit outputs <10, which causes errors later
        var dateString = year + '-' + month + '-' + day;
        var hours = ('0' + time.getHours()).slice(-2)
        var minutes = ('0' + time.getMinutes()).slice(-2)
        var timeString = hours + ':' + minutes + ':00';
        //var timeString = time.getHours() + ':' + time.getMinutes() + ':00';
        //console.log(dateString)
        //console.log(timeString)
        var combined = Date.fromLocaleString(Qt.locale(), dateString + ' ' + timeString, "yyyy-MM-dd hh:mm:ss")
        //console.log(combined)
        return combined;
    }

    function addEditExpense() {
        var project_name_table = activeProjectID.toString()
        var id_unixtime_created = createdTimeStamp // time of entry creation, does not change, serves as unique expense_ID
        var date_time = editedTimeStamp // new or edited time of expense
        var expense_name = idTextfieldItem.text
        var expense_sum = idTextfieldPrice.text
        var expense_currency = idTextfieldCurrency.text
        var expense_info = idTextfieldInfo.text
        var expense_members = ""
        var project_recent_payer_boolarray = ""
        var project_recent_beneficiaries_boolarray = ""
        for (var i = 0; i < listModel_activeProjectMembers.count ; i++) {
            project_recent_payer_boolarray +=  " ||| " + listModel_activeProjectMembers.get(i).member_isPayer
            project_recent_beneficiaries_boolarray +=  " ||| " + listModel_activeProjectMembers.get(i).member_isBeneficiary
            if (listModel_activeProjectMembers.get(i).member_isPayer === "true") {
                var expense_payer = listModel_activeProjectMembers.get(i).member_name

            }
            if (listModel_activeProjectMembers.get(i).member_isBeneficiary === "true") {
                expense_members += " ||| " + listModel_activeProjectMembers.get(i).member_name
            }
        }
        project_recent_payer_boolarray = project_recent_payer_boolarray.replace(" ||| ", "")
        project_recent_beneficiaries_boolarray = project_recent_beneficiaries_boolarray.replace(" ||| ", "")
        expense_members = expense_members.replace(" ||| ", "")
        //console.log("table_name= " + project_name_table)
        //console.log(id_unixtime_created + ", " + date_time + ", " + expense_name + ", " + expense_sum + ", " + expense_currency + ", " + expense_info + ", " + expense_payer + ", " + expense_members)

        // update listmodel expenses and store in DB
        if (modeEdit === "new") {
            listModel_activeProjectExpenses.append({
                id_unixtime_created : Number(id_unixtime_created).toFixed(0),
                date_time : Number(date_time).toFixed(0),
                expense_name : expense_name,
                expense_sum : Number(expense_sum).toFixed(2),
                expense_currency : expense_currency,
                expense_info : expense_info,
                expense_payer : expense_payer,
                expense_members : expense_members,
            })
            storageItem.setExpense(project_name_table, id_unixtime_created.toString(), date_time.toString(), expense_name, expense_sum, expense_currency, expense_info, expense_payer, expense_members)
        } else { //modeEdit === "edit"
           for (var j = 0; j < listModel_activeProjectExpenses.count ; j++) {
                if (id_unixtime_created === Number(listModel_activeProjectExpenses.get(j).id_unixtime_created)) {
                    listModel_activeProjectExpenses.set(j, {
                        id_unixtime_created : Number(id_unixtime_created).toFixed(0),
                        date_time : Number(date_time).toFixed(0),
                        expense_name : expense_name,
                        expense_sum : Number(expense_sum).toFixed(2),
                        expense_currency : expense_currency,
                        expense_info : expense_info,
                        expense_payer : expense_payer,
                        expense_members : expense_members,
                    })
                }
            }
            storageItem.updateExpense(project_name_table, id_unixtime_created.toString(), date_time.toString(), expense_name, expense_sum, expense_currency, expense_info, expense_payer, expense_members)
            // if dates got changed: also sort expenses list
            if (dateTimeManuallyChanged) {
                listModel_activeProjectExpenses.quick_sort()
                dateTimeManuallyChanged = false
            }
        }

        //remember recently used currency
        recentlyUsedCurrency = expense_currency
        storageItem.setSettings("recentlyUsedCurrency", recentlyUsedCurrency)

        // update allProject_Listmodel and DB for recent_beneficiaries and recent_payer in case of "new" entry
        if (modeEdit === "new") {
            for (var k = 0; k < listModel_allProjects.count ; k++) {
                if ( Number(listModel_allProjects.get(k).project_id_timestamp) === Number(activeProjectID_unixtime) ) {
                    listModel_allProjects.set(k, {
                          "project_recent_payer_boolarray" : project_recent_payer_boolarray ,
                          "project_recent_beneficiaries_boolarray" : project_recent_beneficiaries_boolarray,
                      })
                }
            }
            storageItem.updateField_Project(activeProjectID_unixtime, "project_recent_payer_boolarray", project_recent_payer_boolarray)
            storageItem.updateField_Project(activeProjectID_unixtime, "project_recent_beneficiaries_boolarray", project_recent_beneficiaries_boolarray)
        }

        // finally hide popup banner
        hide()
    }
}

