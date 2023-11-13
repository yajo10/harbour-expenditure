import QtQuick 2.6
import Sailfish.Silica 1.0


Page {
    id: pageResults
    allowedOrientations: Orientation.All
    onVisibleChanged: {
        if (visible === true) { // entered page
            listModel_activeProjectResults.clear()
            listModel_activeProjectResultsSettlement.clear()
            generateExchangeRateListFromExpenses()
            addExchangeRates_listmodelActiveProjectExpenses()
        }
    }

    property real totalSpendingAmount_baseCurrency : 0
    property int counterShownExchangeRates : 0
    property string toShareString : ""

    ListModel {
        id: listModel_activeProjectResultsSettlement
    }
    SilicaFlickable{
        id: listView
        anchors.fill: parent
        contentHeight: resultsColumn.height // tell overall height

        PullDownMenu {
            MenuItem {
                text: qsTr("Share detailed")
                onClicked: {
                    createShareString("detailed")
                }
            }
            MenuItem {
                text: qsTr("Share compact")
                onClicked: {
                    createShareString("compact")
                }
            }
        }

        Column {
            id: resultsColumn
            x: Theme.paddingLarge
            width: parent.width - 2*x

            Column {
                width: parent.width
                topPadding: Theme.paddingLarge

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignRight
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    text: qsTr("Results")
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.highlightColor
                    text: activeProjectName + " [" + activeProjectCurrency + "]"
                }
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge + Theme.paddingSmall
            }
            Label {
                visible: listModel_exchangeRates.count > 1 // main exchange rate is also counted in
                width: parent.width
                bottomPadding: Theme.paddingMedium
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("EXCHANGE RATES")
            }
            Repeater {
                id: idRepeaterExchangeRates
                width: parent.width
                model: listModel_exchangeRates
                delegate: Column {
                    id: idColumnContent
                    visible: expense_currency !== activeProjectCurrency
                    width: parent.width

                    Row {
                        width: parent.width

                        Label {
                            width: parent.width / 3
                            height: parent.height
                            topPadding: Theme.paddingSmall
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.WordWrap
                            text: (exchangeRateMode === 1)
                                    ? (new Date(Number(date_time)).toLocaleString(Qt.locale(), "dd.MM.yy" + " - " + "hh:mm")) //"ddd dd.MM.yyyy - hh:mm"
                                    : (qsTr("constant"))
                        }
                        Label {
                            width: parent.width / 3
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.WordWrap
                            topPadding: Theme.paddingSmall
                            horizontalAlignment: Text.AlignRight
                            text: Number(1).toFixed(2) + " " + "<b>" +expense_currency + "</b>" + " = "
                        }
                        TextField {
                            id: idTextfieldExchangeRate
                            width: parent.width / 3
                            textRightMargin: idLabelProjectCurrency.width
                            textLeftMargin: 0
                            inputMethodHints: Qt.ImhFormattedNumbersOnly //use "Qt.ImhDigitsOnly" for INT
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignRight
                            text: Number(exchange_rate) //.toFixed(decimalPlacesCurrencyRate)
                            EnterKey.onClicked: {
                                focus = false
                            }
                            onFocusChanged: {
                                if (text.length < 1) {
                                    text = Number(exchange_rate) //.toFixed(decimalPlacesCurrencyRate)
                                } else {
                                    text = text.replace(",", ".")
                                    text = Number(text) //.toFixed(decimalPlacesCurrencyRate)
                                }
                                if (focus) {
                                    selectAll()
                                } else { // unfocus
                                    exchange_rate = Number(text)
                                    storeExchangeRate_DB(expense_currency, exchange_rate)
                                    addExchangeRates_listmodelActiveProjectExpenses()
                                }
                            }
                            Label {
                                id: idLabelProjectCurrency
                                anchors.left: parent.right
                                font.pixelSize: Theme.fontSizeSmall
                                //color: Theme.highlightColor
                                color: Theme.secondaryColor
                                text: "<b>" + base_currency + "</b>"
                            }
                        }
                    }
                }

            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Label {
                width: parent.width
                bottomPadding: Theme.paddingMedium
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("SPENDING OVERVIEW")
            }
            Row {
                visible: listModel_activeProjectResults.count > 0
                width: parent.width

                Label {
                    width: parent.width / 4
                    color: Theme.secondaryColor
                    font.italic: true
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("name")
                }
                Label {
                    width: parent.width / 4
                    color: Theme.secondaryColor
                    font.italic: true
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("payments")
                }
                Label {
                    width: parent.width / 4
                    color: Theme.secondaryColor
                    font.italic: true
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("benefits")
                }
                Label {
                    width: parent.width / 4
                    color: Theme.secondaryColor
                    font.italic: true
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("saldo")
                }
            }
            Repeater {
                id: idRepeaterExpensesOverview
                model: listModel_activeProjectResults
                delegate: Row {
                    width: parent.width

                    Label {
                        width: parent.width / 4
                        font.pixelSize: Theme.fontSizeSmall
                        text: beneficiary_name
                    }
                    Label {
                        width: parent.width / 4
                        font.pixelSize: Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignRight
                        text: expense_sum.toFixed(2)
                    }
                    Label {
                        width: parent.width / 4
                        font.pixelSize: Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignRight
                        text: beneficiary_sum.toFixed(2)
                    }
                    Label {
                        width: parent.width / 4
                        font.pixelSize: Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignRight
                        color: (( Number(expense_sum) -  Number(beneficiary_sum) ).toFixed(2) < 0) ? Theme.errorColor : "green"
                        text: ( Number(expense_sum) -  Number(beneficiary_sum) ).toFixed(2)
                    }
                }
            }
            Row {
                visible: listModel_activeProjectResults.count > 0
                width: parent.width
                topPadding: Theme.paddingMedium

                Label {
                    width: parent.width / 4 * 2
                    color: Theme.secondaryColor
                    font.bold: true
                    font.overline: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.fontSizeSmall
                    text: totalSpendingAmount_baseCurrency.toFixed(2)
                    //text: activeProjectCurrency + " " + totalSpendingAmount_baseCurrency.toFixed(2)
                }
                Item {
                    width: parent.width / 4
                    height: 1
                }
                Label {
                    width: parent.width / 4
                    color: Theme.secondaryColor
                    font.bold: true
                    font.overline: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.fontSizeSmall
                    text: activeProjectCurrency
                }
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge * 2.5
            }

            Label {
                width: parent.width
                bottomPadding: Theme.paddingMedium
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("SETTLEMENT SUGGESTION")
            }
            Repeater {
                id: idRepeaterSettlementSuggestions
                visible: model.count > 0
                model: listModel_activeProjectResultsSettlement
                delegate: Row {
                    width: parent.width

                    Label {
                        width: parent.width
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.WordWrap
                        text: (settling_sum.toFixed(2) >= 0) ?
                              ("<b>" + from_name + "</b> " + qsTr("owes") + " <b>" + to_name + "</b> " + qsTr("the sum of") + " <b>" + settling_sum.toFixed(2) + "</b> <i>" + activeProjectCurrency + "</i>.")
                            : ("<b>" + to_name + "</b> " + qsTr("owes") + " <b>" + from_name + "</b> " + qsTr("the sum of") + " <b>" + (-settling_sum).toFixed(2) + "</b> <i>" + activeProjectCurrency + "</i>.")

                    }
                }
            }
            Item {
                width: parent.width
                height: Theme.itemSizeSmall
            }
        }
    }


    function generateExchangeRateListFromExpenses() {
        listModel_exchangeRates.clear()

        for (var i = 0; i < listModel_activeProjectExpenses.count; i++) {
            if (exchangeRateMode === 0 ) { // collective currency
                // check if available and where occuring
                var currencyAlreadySet = false
                var addCurrencyIndex = 0
                for (var j = 0; j < listModel_exchangeRates.count; j++) {
                    if ( listModel_activeProjectExpenses.get(i).expense_currency === listModel_exchangeRates.get(j).expense_currency ) {
                        currencyAlreadySet = true
                        addCurrencyIndex = j
                    }
                }
                // if it has not been set yet, add to exchange rate list
                if (currencyAlreadySet === false) {
                    var tempStoredExchangeRateDB = Number(storageItem.getExchangeRate(listModel_activeProjectExpenses.get(i).expense_currency, 1))
                    listModel_exchangeRates.append({ expense_currency : listModel_activeProjectExpenses.get(i).expense_currency,
                                                    base_currency : activeProjectCurrency,
                                                    exchange_rate : tempStoredExchangeRateDB,
                                                    date_time : Number(0)
                                                   })
                }
            } else { // exchangeRateMode === 1 ... individual transactions
                var tempExpenseCurrency = listModel_activeProjectExpenses.get(i).expense_currency
                if (tempExpenseCurrency !== activeProjectCurrency) {
                    tempStoredExchangeRateDB = Number(storageItem.getExchangeRate(listModel_activeProjectExpenses.get(i).expense_currency, 1))
                    listModel_exchangeRates.append({ expense_currency : listModel_activeProjectExpenses.get(i).expense_currency,
                                                    base_currency : activeProjectCurrency,
                                                    exchange_rate : tempStoredExchangeRateDB,
                                                    date_time : Number(listModel_activeProjectExpenses.get(i).date_time)
                                                   })
                }
            }
        }
    }

    function storeExchangeRate_DB (exchange_rate_currency, exchange_rate_value) {
        var tempOccurences = Number(storageItem.countExchangeRateOccurances(exchange_rate_currency, 0))
        if (tempOccurences === 0) { // add new entry
            storageItem.setExchangeRate(exchange_rate_currency, exchange_rate_value)
        } else { // update existing entry
            storageItem.updateExchangeRate(exchange_rate_currency, exchange_rate_value)
        }
    }

    function addExchangeRates_listmodelActiveProjectExpenses() {
        for (var i = 0; i < listModel_activeProjectExpenses.count; i++) {
            var tempExpenseCurrency = listModel_activeProjectExpenses.get(i).expense_currency
            var tempExpenseDateTime = Number(listModel_activeProjectExpenses.get(i).date_time)

            if (tempExpenseCurrency === activeProjectCurrency) { // paid in project specific currency
                listModel_activeProjectExpenses.set(i, {"exchange_rate": Number(1)})
            } else { // if paid in different currency

                if ( exchangeRateMode === 0 ) { // ... collective currency
                    for (var k = 0; k < listModel_exchangeRates.count; k++) {
                        if (listModel_exchangeRates.get(k).expense_currency === tempExpenseCurrency) {
                            listModel_activeProjectExpenses.set(i, {"exchange_rate": Number(listModel_exchangeRates.get(k).exchange_rate)})
                            //console.log(Number(listModel_exchangeRates.get(k).exchange_rate))
                        }
                    }
                } else { // ... individual transactions
                    for (k = 0; k < listModel_exchangeRates.count; k++) {
                        if ((listModel_exchangeRates.get(k).expense_currency === tempExpenseCurrency) && (Number(listModel_exchangeRates.get(k).date_time) === tempExpenseDateTime)) {
                            listModel_activeProjectExpenses.set(i, {"exchange_rate": Number(listModel_exchangeRates.get(k).exchange_rate)})
                        }
                    }
                }
            }
        }
        calculateResults_members()
    }

    function calculateResults_members () {
        listModel_activeProjectResults.clear()
        listModel_activeProjectResultsSettlement.clear()
        totalSpendingAmount_baseCurrency = 0

        // sum up benefits per member
        for (var i = 0; i < listModel_activeProjectExpenses.count; i++) {
            var tempBeneficiariesArray = (listModel_activeProjectExpenses.get(i).expense_members).split(" ||| ")
            for (var j = 0; j < tempBeneficiariesArray.length; j++) {
                var tempExpense_inBaseCurrency_perBeneficiariy = ((Number(listModel_activeProjectExpenses.get(i).expense_sum) / tempBeneficiariesArray.length) * Number(listModel_activeProjectExpenses.get(i).exchange_rate))

                // cycle through results list, check if beneficiary is already available and where
                var tempBeneficiaryAvailable = false
                var tempBeneficiaryIndex = 0
                for (var k = 0; k < listModel_activeProjectResults.count; k++ ) {
                    if (listModel_activeProjectResults.get(k).beneficiary_name === tempBeneficiariesArray[j]) {
                        tempBeneficiaryAvailable = true
                        tempBeneficiaryIndex = k
                    }
                }
                // if not available, add him to results list (only on first occurance)
                if (tempBeneficiaryAvailable === false) {
                    //console.log("first entry for: " + tempBeneficiariesArray[j])
                    //console.log(tempExpense_inBaseCurrency_perBeneficiariy + " " + activeProjectCurrency)
                    listModel_activeProjectResults.append({ beneficiary_name : tempBeneficiariesArray[j],
                                                            beneficiary_sum : Number(tempExpense_inBaseCurrency_perBeneficiariy),
                                                            base_currency : activeProjectCurrency,
                                                            expense_sum : 0 // this info gets added later
                                                          })
                } else {  // otherwise add his share to the existing list
                    var tempBeneficiarySum = Number(listModel_activeProjectResults.get(tempBeneficiaryIndex).beneficiary_sum) + Number(tempExpense_inBaseCurrency_perBeneficiariy)
                    listModel_activeProjectResults.set(tempBeneficiaryIndex, { "beneficiary_sum": Number(tempBeneficiarySum) })
                    //console.log("latest benefitSum for " + tempBeneficiariesArray[j] + " is: " + tempBeneficiarySum)
                }
                //console.log(tempBeneficiariesArray[j])
                //console.log(tempExpense_inBaseCurrency_perBeneficiariy)
            }
        }

        // once listModel_activeProjectResults is created, go over expenses again and add payments
        for ( i = 0; i < listModel_activeProjectExpenses.count; i++) {
            var tempExpensePayer = listModel_activeProjectExpenses.get(i).expense_payer
            var tempExpense_inBaseCurrency =  Number(listModel_activeProjectExpenses.get(i).expense_sum) * Number(listModel_activeProjectExpenses.get(i).exchange_rate)
            totalSpendingAmount_baseCurrency += tempExpense_inBaseCurrency
            //console.log(tempExpensePayer)
            //console.log(tempExpense_inBaseCurrency)

            // check if payer is already in results list as benefitter
            var tempPayerAvailable = false
            var tempPayerIndex = 0
            for (var l = 0; l < listModel_activeProjectResults.count; l++ ) {
                if (listModel_activeProjectResults.get(l).beneficiary_name === tempExpensePayer) {
                    tempPayerAvailable = true
                    tempPayerIndex = l
                }
            }

            // if not available, add him to results list (only on first occurance)
            if (tempPayerAvailable === false) {
                //console.log("first entry for payer: " + tempExpensePayer + " = " + tempExpense_inBaseCurrency + " " + activeProjectCurrency)
                //console.log("seems he paid but never benefits from anything")
                listModel_activeProjectResults.append({ beneficiary_name : tempExpensePayer,
                                                        beneficiary_sum : 0,
                                                        base_currency : activeProjectCurrency,
                                                        expense_sum : Number(tempExpense_inBaseCurrency),
                                                      })
            } else {  // otherwise add his share to the existing list
                var tempPayerSum = Number(listModel_activeProjectResults.get(tempPayerIndex).expense_sum) + Number(tempExpense_inBaseCurrency)
                listModel_activeProjectResults.set(tempPayerIndex, { "expense_sum": Number(tempPayerSum) })
                //console.log("latest payerSum for " + tempExpensePayer + " is: " + tempPayerSum)
            }
        }

        // sort results list according
        listModel_activeProjectResults.quick_sort("desc") // payer with highest expense on top


        // apply a (n-1) algorithm  to settle expenses (how much each person ows to whom)
        var outstandingNamesArray = []
        var outstandingSumsArray = []
        var totalSum = 0
        // iter backwards to get smallest amounts first, since listModel_activeProjectResults starts with highest expenses
        for (var m = listModel_activeProjectResults.count-1; m >= 0; m--) {
            outstandingNamesArray.push(listModel_activeProjectResults.get(m).beneficiary_name)
            outstandingSumsArray.push( Number(listModel_activeProjectResults.get(m).expense_sum) - Number(listModel_activeProjectResults.get(m).beneficiary_sum) )
            totalSum += ( Number(listModel_activeProjectResults.get(m).expense_sum) - Number(listModel_activeProjectResults.get(m).beneficiary_sum) )
        }
        //console.log(outstandingNamesArray)
        //console.log(outstandingSumsArray)
        //console.log(totalSum)

        function splitPayments() {
          const mean = totalSum / outstandingNamesArray.length
          var sortedValuesPaid = []
          for (var n = 0; n < outstandingSumsArray.length; n++) {
              sortedValuesPaid.push(outstandingSumsArray[n] - mean)
          }
          var i = 0
          var j = outstandingNamesArray.length - 1
          var debt
          while (i < j) {
            debt = Math.min(-(sortedValuesPaid[i]), sortedValuesPaid[j])
            sortedValuesPaid[i] += debt
            sortedValuesPaid[j] -= debt
            listModel_activeProjectResultsSettlement.append({ from_name : outstandingNamesArray[i],
                                                                to_name : outstandingNamesArray[j],
                                                                settling_sum : Number(debt),
                                                              })
            //console.log(outstandingNamesArray[i] + " owes " + outstandingNamesArray[j] + " the sum of " + debt )
            if (sortedValuesPaid[i] === 0) { i++ }
            if (sortedValuesPaid[j] === 0) { j-- }
          }
        }
        splitPayments()
    }

    function createShareString (detailGrade) {

        // create a shareable string
        toShareString = "\n" + qsTr("Project:") + " " + activeProjectName
                + "\n" + qsTr("Total expenses") + " = "
                + totalSpendingAmount_baseCurrency.toFixed(2) + " " + activeProjectCurrency
                + "\n" + "\n"
        for (var i = 0; i < listModel_activeProjectResults.count; i++) {
            toShareString += listModel_activeProjectResults.get(i).beneficiary_name + ":"
                    + "\n" + qsTr("payed") + " " + listModel_activeProjectResults.get(i).expense_sum.toFixed(2) + " " + activeProjectCurrency
                    + "\n" + qsTr("received") + " " + listModel_activeProjectResults.get(i).beneficiary_sum.toFixed(2) + " " + activeProjectCurrency
                    + "\n" + qsTr("saldo") + " " + (Number(listModel_activeProjectResults.get(i).expense_sum) - Number(listModel_activeProjectResults.get(i).beneficiary_sum)).toFixed(2) + " " + activeProjectCurrency
                    + "\n" + "\n"
        }
        toShareString += qsTr("Settlement suggestion:")
                + "\n"
        for (i = 0; i < listModel_activeProjectResultsSettlement.count; i++) {
            if ( Number(listModel_activeProjectResultsSettlement.get(i).settling_sum).toFixed(2) >= 0 ) {
                toShareString += listModel_activeProjectResultsSettlement.get(i).from_name
                    + " " + qsTr("owes") + " "
                    + listModel_activeProjectResultsSettlement.get(i).to_name
                    + " " + qsTr("the sum of") + " " + Number(listModel_activeProjectResultsSettlement.get(i).settling_sum).toFixed(2) + " " + activeProjectCurrency
                    + "." + "\n"
            } else { // amount < 0
                toShareString += listModel_activeProjectResultsSettlement.get(i).to_name
                    + " " + qsTr("owes") + " "
                    + listModel_activeProjectResultsSettlement.get(i).from_name
                    + " " + qsTr("the sum of") + " " + (-1*Number(listModel_activeProjectResultsSettlement.get(i).settling_sum).toFixed(2)) + " " + activeProjectCurrency
                    + "." + "\n"
            }
        }
        //console.log(toShareString)


        // add details if necessary
        if (detailGrade === "detailed") {
            toShareString += "\n" + "\n" + "\n"
                    + qsTr("Detailed Spendings:")
                    + "\n" + "\n"
            for ( i = 0; i < listModel_activeProjectExpenses.count; i++) {
                if (sortOrderExpenses === 0) { // 0=descending, 1=ascending
                    var tmpEntryNumber = (listModel_activeProjectExpenses.count - i)
                } else {
                    tmpEntryNumber = (i+1)
                }
                toShareString += qsTr("Expense #") + tmpEntryNumber
                        + "\n" + qsTr("date:") + " " + new Date(Number(listModel_activeProjectExpenses.get(i).date_time)).toLocaleString(Qt.locale(), "ddd dd.MM.yyyy - hh:mm")
                        + "\n" + qsTr("payer:") + " " + listModel_activeProjectExpenses.get(i).expense_payer
                        + "\n" + qsTr("item:") + " " + listModel_activeProjectExpenses.get(i).expense_name
                        + "\n" + qsTr("price:") + " " + Number(listModel_activeProjectExpenses.get(i).expense_sum).toFixed(2) + " " + listModel_activeProjectExpenses.get(i).expense_currency
                        + "\n" + qsTr("beneficiaries:") + " " + listModel_activeProjectExpenses.get(i).expense_members.split(" ||| ").join(", ") // .replace(" ||| ", ", ")
                        + "\n" + qsTr("info:") + " " + listModel_activeProjectExpenses.get(i).expense_info
                        + "\n" + "\n"
            }
        }
        console.log(toShareString)

        // send this string
        Clipboard.text = toShareString
        shareActionText.mimeType = "text/plain" // "text/*" or "application/text"
        shareActionText.resources = [{
                                        "data": toShareString,
                                        "name": activeProjectName,
                                    } ]
        shareActionText.trigger()
    }

}
