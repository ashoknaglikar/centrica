/*
 * CS_pricing
Change History:
16/03/15 IC amended coreBundleSummary
 
 Only one function in this file is not synchronous.
 */

var totalNetPrice = 0;
var totalMargin = 0; // -> configurator attribute
var VATperGroup = {};
var skillsPerGroup = {};
var grossPriceInclVAT = 0; // -> configurator attribute
var discountableGrossPriceInclVAT = 0; // -> configurator attribute
var marginContributingGrossPriceInclVAT = 0; // -> configurator attribute
var totalCost = 0; // -> configurator attribute

/**
 * An HTML select list.
 * @constructor
 */
var SelectList = function(id, values) {
    this.selectlist = '<select id="' + id + '" style="width: 250px;" data-selected-id="" onclick="onSelectListClick(id, this.value)" onchange="onSelectListChange(id, this.value)">';
    for (var i = 0; i < values.length; i++) {
        var displayValue = values[i].displayValue;
        var value = values[i].value;
        var quoteDescription = values[i].quoteDescription;
        this.selectlist += '<option value="' + value + '" quote-description="' + quoteDescription + '">' + displayValue + '</option>';
    }
    this.selectlist += '</select>';
};

/**
 * An HTML select list option.
 * @constructor
 */
var SelectListOption = function(displayValue, value, quoteDescription) {
    this.option = {
        displayValue: displayValue,
        value: value,
        quoteDescription: quoteDescription
    };
};

/**
 * An HTML input field.
 * @constructor
 */
var InputField = function(id) {
    this.input = '<input type="text" value="0" id="' + id + '" onkeydown="validateActualAmount(id.substring(id.length-1))"/>';
};

/**
 * An HTML button.
 * @constructor
 */
var Button = function(id, value, action) {
    this.button = '<button id="' + id + '" onclick="' + action + '" class="allowanceButton">' + value + '</button>';
};

/**
 * An HTML input field used for displaying showroom content.
 * @constructor
 */
var DSAButton = function(value, id) {
    id = "'" + id + "'"; 
    this.button = '<input type="button" class="dsa-button" value="' + value + '" onclick="toggleBtnCss(this).then(displayShowroomContentForId(' + id + '))" />';    
};

/**
 * An HTML table. Used for HSA, customer, skill and allowance tables.
 * @constructor
 */
var Table = function(id) {
    this.table = '<table id="' + id + '" class="detailList">';
};

Table.prototype.addHeader = function() {
    this.table += '<thead>';
    return this;
};

Table.prototype.addHeaderRow = function(firstColumn, secondColumn, thirdColumn, fourthColumn, fifthColumn, sixthColumn) {
    if (!firstColumn) { firstColumn = ''; }
    if (!secondColumn) { secondColumn = ''; }
    if (!thirdColumn) { thirdColumn = ''; }
    if (!fourthColumn) { fourthColumn = ''; }
    if (!fifthColumn) { fifthColumn = ''; }
    if (!sixthColumn) { sixthColumn = ''; }
    this.table += '<tr>' +
        '<th class="ps-th ps-text-align-left">' + firstColumn + '</th>' +
        '<th class="ps-th ps-text-align-center">' + secondColumn + '</th>' +
        '<th class="ps-th ps-text-align-right">' + thirdColumn + '</th>' +
        '<th class="ps-th ps-text-align-right">' + fourthColumn + '</th>' +
        '<th class="ps-th ps-text-align-right">' + fifthColumn + '</th>' +
        '<th class="ps-th ps-text-align-right">' + sixthColumn + '</th>' +
        '</tr>';
    return this;
};

Table.prototype.closeHeader = function() {
    this.table += '</thead>';
    return this;
};

Table.prototype.addBody = function() {
    this.table += '<tbody>';
    return this;
};

Table.prototype.addRow = function(firstColumn, secondColumn, thirdColumn, fourthColumn, fifthColumn, sixthColumn, customCSS) {
    if (!firstColumn) { firstColumn = ''; }
    if (!secondColumn) { secondColumn = ''; }
    if (!thirdColumn) { thirdColumn = ''; }
    if (!fourthColumn) { fourthColumn = ''; }
    if (!fifthColumn) { fifthColumn = ''; }
    if (!sixthColumn) { sixthColumn = ''; }
    if (!customCSS) { customCSS = ''; }
    this.table += '<tr>' +
        '<td class="ps-tr ps-text-align-left" style="' + customCSS + '">' + firstColumn + '</td>' +
        '<td class="ps-tr ps-text-align-center" style="' + customCSS + '">' + secondColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + thirdColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + fourthColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + fifthColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + sixthColumn + '</td>' +
        '</tr>';
    return this;
};

Table.prototype.addAccordionParent = function(parentId, firstColumn, secondColumn, thirdColumn, fourthColumn, fifthColumn, sixthColumn, customCSS) {
    if (!firstColumn) { firstColumn = ''; }
    if (!secondColumn) { secondColumn = ''; }
    if (!thirdColumn) { thirdColumn = ''; }
    if (!fourthColumn) { fourthColumn = ''; }
    if (!fifthColumn) { fifthColumn = ''; }
    if (!sixthColumn) { sixthColumn = ''; }
    if (!customCSS) { customCSS = ''; }
    this.table += '<tr id="' + parentId + '" class="accordion-parent" style="cursor: pointer;">' +
        '<td class="ps-tr ps-text-align-left" style="' + customCSS + '">' + '+' + '&nbsp;'+ firstColumn + '</td>' +
        '<td class="ps-tr ps-text-align-center" style="' + customCSS + '">' + secondColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + thirdColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + fourthColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + fifthColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + sixthColumn + '</td>' +
        '</tr>';
    return this;
};

Table.prototype.addAccordionChild = function(parentId, firstColumn, secondColumn, thirdColumn, fourthColumn, fifthColumn, sixthColumn, customCSS) {
    if (!firstColumn) { firstColumn = ''; }
    if (!secondColumn) { secondColumn = ''; }
    if (!thirdColumn) { thirdColumn = ''; }
    if (!fourthColumn) { fourthColumn = ''; }
    if (!fifthColumn) { fifthColumn = ''; }
    if (!sixthColumn) { sixthColumn = ''; }
    if (!customCSS) { customCSS = ''; }
    this.table += '<tr class="accordion-child-' + parentId + '" style="display: none;">' +
        '<td class="ps-tr ps-text-align-left" style="' + customCSS + '">' + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + firstColumn + '</td>' +
        '<td class="ps-tr ps-text-align-center" style="' + customCSS + '">' + secondColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + thirdColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + fourthColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + fifthColumn + '</td>' +
        '<td class="ps-tr ps-text-align-right" style="' + customCSS + '">' + sixthColumn + '</td>' +
        '</tr>';
    return this;
};

Table.prototype.closeBody = function() {
    this.table += '</tbody>';
    return this;
};

Table.prototype.closeTable = function() {
    this.table += '</table>';
    return this;
};

/**
 * Checks whether the value is a number.
 * @param {Number} n
 * @return {Boolean}
 */
function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

/**
 * Sorts the numbers ascending.
 * Usage: listOfElementsToBeSorted.sort(numberSort);
 * @return {Boolean}
 */
function numberSort(a, b) {
    return a - b;
}

/**
 * Checks whether the array contains a certain value.
 * @param {Array} a
 * @param (String) obj
 * @return {Boolean} Whether the array contains a value.
 */
function contains(a, obj) {
    var i = a.length;
    while (i--) {
        if (a[i] === obj) {
            return true;
        }
    }
    return false;
}

/**
 * Checks whether the pressed key corresponds to a "." or a number.
 * @param {Event} event
 * @return {Boolean} Whether the pressed key is a "." or a number.
 */
function isPressedNumberOrDot(event) {
    return (/\d/.test(String.fromCharCode(event.which))) || (/\./.test(String.fromCharCode(event.which)));
}

/**
 * Creates a select list object containing only one option ("-- None --").
 * @return {Array}
 */

function createEmptySelectList() {
    var emptyList = [];
    emptyList.push(new SelectListOption("-- None --", 'none', '').option);
    return emptyList;
}

/**
 * Returns the formatted price.
 * @param {String} amount
 * @param {Boolean} addMinus Flag whether the formatted price displays a minus sign.
 * @return {String} The formatted price.
 */
function formatPrice(amount, addMinus) {
    var returnedAmount;
    if (isNumber(amount)) {
        returnedAmount = parseFloat(amount);
        if (addMinus) {
            return '-&pound;' + returnedAmount.toFixed(2);
        } else {
            return '&pound;' + returnedAmount.toFixed(2);
        }
    } else {
        return amount;
    }
}

/**
 * Rounds the item price.
 * @param  {Number} amount 
 * @return {Number}       
 */
function roundPrice(amount) {
    if(isNumber(amount)) {
        return parseFloat(amount.toFixed(2));
    }
    return amount;
}

/**
 * Fires on allowances button click (buttons 1 - 7)
 * @param {String} id Id of the clicked button
 */
function onAllowanceButtonClick(id) {
    // toggle the css class to indicate the button was clicked
    jQuery("#" + id).toggleClass("allowancesClicked");

    if (id === "applyAll") {
        if (jQuery("#" + id).hasClass("allowancesClicked")) {
            jQuery(".allowanceButton").addClass("allowancesClicked");
        } else {
            jQuery(".allowanceButton").removeClass("allowancesClicked");
        }
    }

    for (var i = 1; i < 7; i++) {
        // if the button is clicked set the CS Is_Applied flag to TRUE
        if (jQuery("#allowance" + i).hasClass("allowancesClicked")) {
            CS.setAttributeField('Allowance' + i + '_0', 'Is_Applied', 'TRUE');
        } else {
            CS.setAttributeField('Allowance' + i + '_0', 'Is_Applied', 'FALSE');
        }
    }
    // save the button values and css so that the configurator doesn't overwrite them
    var customerButtons = (jQuery('span[data-cs-binding="Customer_Allowance_Buttons_0"] div')[0]).outerHTML;
    CS.setAttributeValue('Customer_Allowance_Buttons_0', customerButtons);

    // recalculate pricing screens to reflect the de/selected allowance
    calculatePricingScreenTotals();
    createCustomerTotalsTable();
    
    clearCustomerSignature(); //added 20 Jun
}

/** 
 * Fires on select list click.
 */
function onSelectListClick(selectListId, allowanceId) {
    function isEmptyOrWhitespace(str) {
        if(str === undefined) return false;
        return (str.length === 0 || !str.trim());
    }
    
    // get the index of the selected list change
    var idx = parseInt(selectListId.substring(selectListId.length - 1), 10);
    // check that it is only 
    if(('discount' + idx) == ('discount1')) {
        var alertMessage = 'Please enter the customer date of birth and recalculate prices before configurating the allowances.';
        var dateOfBirth = CS.getAttributeValue('Customer_Date_of_Birth_0'); 
        if(isEmptyOrWhitespace(dateOfBirth)) {
            if(navigator.device) {
                navigator.notification.alert( 
                    alertMessage, // message 
                    null, // callback 
                    'Alert', // title 
                    'Ok' // buttonName 
                ); 
            } else {
                alert(alertMessage);
            }
        }
    }
}

/**
 * Fires on select list value change. Updates the maximum amount span and actual amount input fields.
 * @param {String} selectListId Id of the select list which fired the event
 * @param {String} allowanceId Id of the selected allowance (value of the select list option)
 */
function onSelectListChange(selectListId, allowanceId) {
    // get the index of the selected list change
    var idx = parseInt(selectListId.substring(selectListId.length - 1), 10);

    // add the html "selected" attribute to prevent configurator issues
    var selectedOption = jQuery('#discount' + idx + ' :selected');
    jQuery('#discount' + idx).children().removeAttr('selected');
    jQuery('#discount' + idx).html(jQuery('#discount' + idx).html().split('select').join('')); // fix for IE9
    jQuery('#discount' + idx).attr('data-selected-id', selectedOption.val()); // fix for IE9
    jQuery('#discount' + idx + " option[value="+ selectedOption.val() +"]").attr('selected', true);
    
    var actualInputField = document.getElementById('discountAllowance' + idx);
    actualInputField.defaultValue = 0;
    jQuery('#discountAllowance' + idx).val('0');

    unbindAndSetHsaAllowances();

    // if the allowance Id exists, validate allowance, otherwise clear and set the max value to 0
    if (allowanceId !== '' && allowanceId != 'none') {
        validateAllowance(allowanceId, function() {

            //remove the value from current user input
            jQuery('#discountAllowance' + idx).val('0');

            setAllowanceMaxValue(selectListId);

            //validate current actual amount
            validateActualAmount(idx);

            // the validateActualAmount method has a timeout to ensure that 
            // the new value is picked up
            window.setTimeout(function() {
                unbindAndSetHsaAllowances();
            }, 20);

            populateNextSelectListsFrom(idx + 1);
        });
    } else {
        allowanceMax = 0;
        allowance = {
            Allowance_Code__c: '',
            Low_Campaign__c: '',
            Non_Cash__c: '',
            Cash_Equivalent_Amount__c: '',
            Amount_Type__c: ''
        };

        //remove the error message (if exists)
        jQuery('#allowanceError' + idx).text('');

        //remove the value from current user input
        jQuery('#discountAllowance' + idx).val('0');
        jQuery("#discountAllowance" + idx).prop('readonly', false);
        actualInputField.defaultValue = 0;

        jQuery("#validateAllowance" + idx).prop('disabled', false);
        jQuery("#validateAllowance" + idx).removeClass('allowancesClicked');

        setAllowanceMaxValue(selectListId);

        unbindAndSetHsaAllowances();

        populateNextSelectListsFrom(idx + 1);

        createHSATotalsWithAllowances();
    }
}

/**
 * Validates the amount present in the input field. Enables or disables the input fields based on the value.
 * Enables or disables button "Done" based on the validation result.
 * @param {Number} idx  number part of the id representing the actual amount input field.
 */
function validateActualAmount(idx) {
    setTimeout(function() {
        if ((idx > 0) && (idx < 7)) {
            var maxAmount = parseFloat(jQuery('#maxAllowance' + idx).text());
            var actualAmount = jQuery('#discountAllowance' + idx).val();
            var errorMessage = "Invalid value.";
            var actualInputField = document.getElementById('discountAllowance' + idx);
            var allowanceId = jQuery("#discount" + idx).val();
            var validateButton = jQuery("#validateAllowance" + idx);

            if (allowanceId && allowanceId.length > 0 && allowanceId != 'none') {
                if (actualAmount) {
                    actualInputField.defaultValue = actualAmount;
                    if ((!isNumber(actualAmount)) || (parseFloat(actualAmount) > maxAmount)) {
                        jQuery('#allowanceError' + idx).text(errorMessage);
                        validateButton.prop('disabled', true);
                        validateButton.addClass('allowancesClicked');
                    } else {
                        jQuery('#allowanceError' + idx).text('');
                        validateButton.prop('disabled', false);
                        validateButton.removeClass('allowancesClicked');
                    }
                } else {
                    jQuery('#allowanceError' + idx).text(errorMessage);
                    validateButton.prop('disabled', true);
                    validateButton.addClass('allowancesClicked');
                }

                var buttonDone = jQuery("#discountDone");
                buttonDone.prop('disabled', false);
                buttonDone.removeClass('allowancesClicked');
                for (var i = 1; i < 7; i++) {
                    if (jQuery('#allowanceError' + i).text().length > 0) {
                        buttonDone.prop('disabled', true);
                        buttonDone.addClass('allowancesClicked');
                    }
                }
            }
        }
    }, 5);
}

/**
 * Sets the maximum amount span with the calculated maximum value temporarily set in a global variable.
 * @param {String} selectListId     id of the select list with the selected allowance,
 * used to apply values to the maximum amount span and actual amount input fields.
 */
function setAllowanceMaxValue(selectListId) {
    var idx = selectListId.substring(selectListId.length - 1);
    // allowanceMax is a global variable declared in validateAllowances.js - it stores the current maximum amount
    jQuery("#maxAllowance" + idx).text(allowanceMax.toFixed(2));

    //set the allowance code value
    jQuery("#allowanceCode" + idx).text(allowance.Allowance_Code__c);

    //set the allowance flag isLowCampaign
    jQuery("#allowanceLowCampaign" + idx).text(allowance.Low_Campaign__c);

    //set the allowance flag isNonCash
    jQuery("#allowanceNonCash" + idx).text(allowance.Non_Cash__c);

    //set the Cash Equivalent Amount
    jQuery("#allowanceCashEquivalent" + idx).text(allowance.Cash_Equivalent_Amount__c);

    //if the allowance Amount type is fixed, set the input field to max value and disable it
    // allowance is a global variable declared in validateAllowances.js
    var allowanceInput = jQuery("#discountAllowance" + idx);
    var allowanceInputField = document.getElementById('discountAllowance' + idx);
    if (allowance.Amount_Type__c == 'Fixed') {
        if (allowanceMax === 0) {
            allowanceInput.val(allowanceMax);
            allowanceInputField.defaultValue = allowanceMax;
        } else {
            allowanceInput.val(allowanceMax.toFixed(2));
            allowanceInputField.defaultValue = allowanceMax.toFixed(2);
        }
        allowanceInput.prop('readonly', true);
    } else {
        allowanceInput.prop('readonly', false);
        allowanceInputField.defaultValue = 0;
    }

    CS.Log.warn('Allowance value set.');
    unbindAndSetHsaAllowances();
}

/**
 * Unbinds events and sets the value (to configurator attributes) of text fields
 * containing HSA allowance select lists, spans and input fields.
 */
function unbindAndSetHsaAllowances() {
    CS.Log.warn('Unbinding events from the allowance attribute and setting values.');
    
    // unbind the events on HSA allowances (and save the values to the HSA_Allowances_0 attribute) to prevent configurator overwriting the attribute
    var hsaAllowancesContainer = jQuery('span[data-cs-binding="HSA_Allowances_0"]');
  
    hsaAllowancesContainer.off("keypress").off("change");
   
    var hsaAllowancesTableObject = (jQuery('span[data-cs-binding="HSA_Allowances_0"] table')[0]);
    if (hsaAllowancesTableObject) {
        var hsaAllowancesTable = hsaAllowancesTableObject.outerHTML;
        if (hsaAllowancesTable) {
            CS.setAttributeValue('HSA_Allowances_0', hsaAllowancesTable);
        }
    }
    hsaAllowancesContainer.off("keypress").off("change");
}

/**
 * Populates the select lists after the select list specified by the parameter.
 * @param {Number} idx  number part of the id representing the select list.
 */
function populateNextSelectListsFrom(idx) {

    //clear all of the select lists after the changed one
    for (var i = idx; i < 7; i++) {
        var allowanceInput = jQuery('#discountAllowance' + i);
        allowanceInput.val('0');
        allowanceInput.prop('readonly', false); //enable the input field if it was disabled
        var allowanceInputField = document.getElementById('discountAllowance' + i);
        allowanceInputField.defaultValue = 0;

        var maxSpan = jQuery('#maxAllowance' + i);
        maxSpan.text('0.00');
        
        //set the allowance code value
        jQuery("#allowanceCode" + i).text('');

        //set the allowance flag isLowCampaign 
        jQuery("#allowanceLowCampaign" + i).text('');

        //set the allowance flag isNonCash
        jQuery("#allowanceNonCash" + i).text('');

        //set the Cash Equivalent Amount
        jQuery("#allowanceCashEquivalent" + i).text('');

        populateSelectList('discount' + i);
    }
}

/**
 * Populates the select list indicated by the id with array values.
 * @param {String} selectListId
 * @param {Array} allowanceList
 */
function populateSelectList(selectListId, allowanceList) {
    // allowanceList is optional, if not provided the list will be empty
    var selectListValues = createEmptySelectList();
    if (allowanceList) {
        for (var i = 0; i < allowanceList.length; i++) {
            var allowance = allowanceList[i];
            if ((allowance.Description__c) && (allowance.Id)) {
                var quoteDescription = '';
                if (allowance.Quote_Description__c) {
                    quoteDescription = allowance.Quote_Description__c;
                }
                selectListValues.push(new SelectListOption(allowance.Description__c, allowance.Id, quoteDescription).option);
            }
        }
    }

    // we change the select list in the configurator attribute instead of the ui(if the ui doesn't exist), because the configurator will overwrite the values
    var hsaTable;
    if (jQuery('span[data-cs-binding="HSA_Allowances_0"] table')[0]) {
        hsaTable = jQuery('span[data-cs-binding="HSA_Allowances_0"] table');
        hsaTable.find('#' + selectListId).parent().html(new SelectList(selectListId, selectListValues).selectlist);
        CS.setAttributeValue('HSA_Allowances_0', hsaTable[0].outerHTML);
    } else {
        hsaTable = jQuery(CS.getAttributeValue('HSA_Allowances_0'));
        hsaTable.find('#' + selectListId).parent().html(new SelectList(selectListId, selectListValues).selectlist);
        CS.setAttributeValue('HSA_Allowances_0', hsaTable[0].outerHTML);
    }
}

/**
 * Makes the specified input field readonly and calls a method to populate the next select list.
 * @param {Number} idx Number part of the id representing the select list.
 */
function lockAllowanceField(idx) {

    toggleBtnCss('validateAllowance' + idx).then(function(){
        unbindAndSetHsaAllowances();
    });

    idx = parseInt(idx, 10);

    var allowanceId = jQuery("#discount" + idx).val();

    var actualAmount = jQuery('#discountAllowance' + idx).val();
    var actualInputField = document.getElementById('discountAllowance' + idx);
    actualInputField.defaultValue = actualAmount;

    var allowanceInput = jQuery("#discountAllowance" + idx);
    allowanceInput.prop('readonly', true);

    populateNextSelectListsFrom(idx + 1);

    //recreate only the HSA pricing screens with allowances
    createHSATotalsWithAllowances();

    if (idx > 0 && idx < 6) {
        if (allowanceId && allowanceId !== 0 && allowanceId != 'none') {
            getApplicableAllowances("discount" + (idx + 1));
        }
    }
    unbindAndSetHsaAllowances();
}

/**
 * Fires on allowances "Done" button click. Sets the select list, maximum amount span, actual amount input field
 * values to configurator attributes. Enables application of the values to the customer pricing screen.
 */
function onAllowancesDoneClick() {

    toggleBtnCss('discountDone').then(function(){
        unbindAndSetHsaAllowances();
    });

    // needs to save actual allowance values to Configurator attributes
    var totalAllowances = 0;
    // iterate through all 6 allowance fields and get Ids
    for (var i = 1; i < 7; i++) {
        var id = jQuery('#discount' + i).val();
        var name = jQuery('#discount' + i + ' :selected').text();
        var description = jQuery('#discount' + i).find(':selected').attr('quote-description');
        var actualDiscount = parseFloat(jQuery('#discountAllowance' + i).val());
        var maxValue = parseFloat(jQuery('#maxAllowance' + i).text());
        var code = jQuery("#allowanceCode" + i).text();
        
        //set the Is_Applied attrobute field to false for of the allowances
        CS.setAttributeField('Allowance' + i + '_0', 'Is_Applied', 'FALSE');
        
        //check if an allowance is selected and a valid value exists in the input field
        if (isNumber(actualDiscount) && id !== '' && id != 'none') {
            CS.setAttributeValue('Allowance' + i + '_0', id);
            CS.setAttributeField('Allowance' + i + '_0', 'AllowanceName', name);
            CS.setAttributeField('Allowance' + i + '_0', 'AllowanceDescription', description);
            CS.setAttributeField('Allowance' + i + '_0', 'Code', code);
            CS.setAttributeField('Allowance' + i + '_0', 'MaxAmount', maxValue);

            if (maxValue > actualDiscount) {
                CS.setAttributeField('Allowance' + i + '_0', 'ActualAmount', actualDiscount);
            } else if (maxValue <= actualDiscount) {
                jQuery('#discountAllowance' + i).val(maxValue.toFixed(2));
                CS.setAttributeField('Allowance' + i + '_0', 'ActualAmount', maxValue);
            }
        } else {
            CS.setAttributeValue('Allowance' + i + '_0', '');
            CS.setAttributeField('Allowance' + i + '_0', 'AllowanceName', '');
            CS.setAttributeField('Allowance' + i + '_0', 'AllowanceDescription', description);
            CS.setAttributeField('Allowance' + i + '_0', 'Code', '');
            CS.setAttributeField('Allowance' + i + '_0', 'MaxAmount', 0);
            CS.setAttributeField('Allowance' + i + '_0', 'ActualAmount', 0);
        }
    }
    
    CS.Log.warn('*** Allowances have been saved and are ready to be applied.');
    
    clearCustomerSignature(); //added 20 Jun

    unbindAndSetHsaAllowances();

    createAllowancesButtons();
    calculatePricingScreenTotals();
    createPricingTables();
    createCustomerTotalsTable();
}

/**
 * Clears the allowance attributes and associated attribute fields.
 */
function clearAllAllowanceFields() {
    // clear all configurator fields and attributes
    for (var i = 1; i < 7; i++) {
        CS.setAttributeValue('Allowance' + i + '_0', '');
        CS.setAttributeField('Allowance' + i + '_0', 'AllowanceName', '');
        CS.setAttributeField('Allowance' + i + '_0', 'Is_Applied', 'FALSE');
        CS.setAttributeField('Allowance' + i + '_0', 'MaxAmount', 0);
        CS.setAttributeField('Allowance' + i + '_0', 'ActualAmount', 0);
    }
}

/**
 * A temporary method. Should be deleted in the future.
 * Prints the allowance values for index.
 */
function printAllowanceValuesForIndex(idx) {
    var allowanceId = jQuery("#discount" + idx).val(),
        allowanceName = jQuery('#discount' + idx + ' :selected').text(),
        allowanceCode = jQuery("#allowanceCode" + idx).text(),
        isLowCampaign = jQuery("#allowanceLowCampaign" + idx).text(),
        isNonCash = jQuery("#allowanceNonCash" + idx).text(),
        nonCashEquivalent = jQuery("#allowanceCashEquivalent" + idx).text(),
        allowanceMaxValue = parseFloat(jQuery('#maxAllowance' + idx).text()),
        allowanceActualValue = parseFloat(jQuery('#discountAllowance' + idx).val());

    CS.Log.warn('ID: "' + allowanceId +
        '" Name: "' + allowanceName +
        '" Code: "' + allowanceCode +
        '" isLowCampaign: "' + isLowCampaign +
        '" isNonCash: "' + isNonCash +
        '" nonCashEquivalent: "' + nonCashEquivalent +
        '" MaxValue: "' + allowanceMaxValue +
        '" ActualValue: "' + allowanceActualValue + '"');
}

/**
 * Adds the price and margin to global variables used to store totalNetPrice and totalMargin.
 * @param {Number} price
 * @param {Number} margin
 */
function addToTotalNetPrice(price) {
    if (isNumber(price)) {
        totalNetPrice += roundPrice(price);
    }
}

/**
 * Adds the price of Discountable Parts to a global variable used to store discountableGrossPriceInclVAT.
 * @param {Number} price
 */
function addToDiscountableGrossPriceInclVAT(price) {
    if (isNumber(price)) {
        discountableGrossPriceInclVAT += roundPrice(price);
    }
}

/**
 * Adds the price of Margin Contributing Parts to a global variable used to store marginContributingGrossPriceInclVAT.
 * @param {Number} price
 */
function addToMarginContributingGrossPriceInclVAT(price) {
    if (isNumber(price)) {
        marginContributingGrossPriceInclVAT += roundPrice(price);
    }

}

/**
 * Groups the vat amounts and sums their values.
 * @param {Object} item     a part or associatedPart object from partsModelJS
 */
function addToVATperGroup(item) {
    var vat = item.part.VAT_Code__c ? (item.part.VAT_Percentage__c ? item.part.VAT_Percentage__c : 0) : 0,
        amount = item.totalVatAmount ? item.totalVatAmount : 0,
        vatString = vat.toFixed(2);

    if (vat !== null) {
        if (isNumber(amount)) {
            if (isNaN(VATperGroup[vatString])) {
                VATperGroup[vatString] = roundPrice(amount);
            } else {
                VATperGroup[vatString] += roundPrice(amount);
            }
        }
    }
}

/**
 * Groups the skill hours and sums their values.
 * @param {Object} item     a part or associatedPart object from partsModelJS
 */
function addToSkillperGroup(item) {
    for (var i = 0; i < item.skillsList.length; i++) {
        var skill = item.skillsList[i],
            skillName = skill.name,
            skillCode = skill.skillCode,
            amount = skill.hours,
            quantity = parseInt(item.quantity, 10);

        if (isNumber(amount) && isNumber(quantity)) {
            if (!skillsPerGroup[skillName]) {
                skillsPerGroup[skillName] = [];
                skillsPerGroup[skillName].skillCode = skillCode;
                skillsPerGroup[skillName].amount = amount * quantity;
            } else {
                skillsPerGroup[skillName].amount += amount * quantity;
            }
        }
    }
}

/**
 * Sums the gross price.
 * @param {Number} amount
 */
function addToGrossPrice(amount) {
    if (isNumber(amount)) {
        grossPriceInclVAT += roundPrice(amount);
    }
}

/**
 * Sums the total Cost (includes S and M Cost).
 * @param {Number} amount
 */
function addToTotalCost(amount) {
    if (isNumber(amount)) {
        totalCost += roundPrice(amount);
    }
}

/**
 * Calculates the total margin based on th ebusiness provided formula.
 * Sets the calculated amount to the global variable totalMargin.
 */
function calculateTotalMargin() {
    CS.Log.warn('Calculating the total margin.');
    var marginContributingGrossTotal = parseFloat(CS.getAttributeValue('Margin_Contributing_Gross_Price_Incl_VAT_0'));
    var totalCost = parseFloat(CS.getAttributeValue('Total_Cost_0'));
    var fixedOverhead = parseFloat(CS.getAttributeValue('Fixed_Overhead_0'));
    var appliedAllowancesWithCashEquivalentAmount = getSumOfAllowancesWithCashEquivalentAmount();

    totalMargin = marginContributingGrossTotal - totalCost - appliedAllowancesWithCashEquivalentAmount - fixedOverhead;
}

/**
 * Updates the attribute running total price payable.
 * @param {Number} value Amount to be displayed.
 */
function updateRunningTotal(value) {
    CS.Log.warn('Updating the running total.');
    CS.setAttributeValue('Running_Total_Price_Payable_0', formatPrice(value));
}

/**
 * Called by loadPartsModelFromAttachment, to reset the value of 'Total_Allowance_Value_0' attribute, after
 * calculatePricingScreenTotals() has zeroed it (jQuery only works when user is on same page)
 */
function loadTotalAllowanceValue() {
    CS.Log.warn('Loading the total allowance values.');
    var totalAllowances = 0;
    
     // calculate totalAllowances by looping through all Allowance attributes that are Applied
    for (var j = 1; j < 7; j++) {
        if (CS.getAttributeValue('Allowance' + j + '_0') && CS.getAttributeValue('Allowance' + j + '_0') !== '' && 
            CS.getAttributeField('Allowance' + j + '_0', 'Is_Applied') && CS.getAttributeField('Allowance' + j + '_0', 'Is_Applied') == 'TRUE') {
            
            var maxAmount = CS.getAttributeFieldValue('Allowance' + j + '_0', 'MaxAmount');
            var actualAmount = parseFloat(CS.getAttributeFieldValue('Allowance' + j + '_0', 'ActualAmount'));
            if (actualAmount <= maxAmount) {
                totalAllowances += actualAmount;
            }
        }
    }

    CS.setAttributeValue('Total_Allowance_Value_0', roundPrice(totalAllowances));
}


/**
 * Calculated the totals used in pricing screens.
 * Iterates through the partsModelJS and sums the necessary values.
 * (totalNetPrice, totalMargin, VATperGroup, grossPriceInclVAT, skillsPerGroup)
 */
function calculatePricingScreenTotals() {
    CS.Log.warn('Calculating the pricing screen totals.');
    totalNetPrice = 0;
    totalMargin = 0;
    VATperGroup = {};
    grossPriceInclVAT = 0;

    discountableGrossPriceInclVAT = 0;
    marginContributingGrossPriceInclVAT = 0;
    totalCost = 0;

    skillsPerGroup = {};

    var totalAllowances = 0;

    for (var id in partsModelJS) {
        if (!partsModelJS.hasOwnProperty(id))
            continue;
        var item = partsModelJS[id];

        if ((item.isBundle && item.isLineItem) || (item.isPart && item.isLineItem)) {
            addToGrossPrice(item.aggregatedPriceInclVAT);
            addToTotalCost(item.aggregatedCost);

            var quantity = 1;
            var description = '';
            var aggregatedNetPrice = item.aggregatedNetPrice;

            if (item.isBundle) {
                description = item.parentBundle.Quote_Description__c ? item.parentBundle.Quote_Description__c : (item.parentBundle.Description__c ? item.parentBundle.Description__c : (item.parentBundle.Name ? item.parentBundle.Name : ''));
                quantity = item.attLastQuantity ? item.attLastQuantity : 1;
            } else {
                description = item.parentPart.part.Quote_Description__c ? item.parentPart.part.Quote_Description__c : (item.parentPart.part.Description__c ? item.parentPart.part.Description__c : (item.parentPart.part.Name ? item.parentPart.part.Name : ''));
                quantity = item.parentPart.quantity ? item.parentPart.quantity : 1;
            }

            if (item.isPart && !(item.isMultilookup)) {
                addToTotalNetPrice(aggregatedNetPrice);
                addToVATperGroup(item.parentPart);
                addToSkillperGroup(item.parentPart);

                if (item.parentPart.part.Discountable__c === true) {
                    addToDiscountableGrossPriceInclVAT(item.parentPart.totalPriceIncVAT);
                }
                if (item.parentPart.part.Contributing_to_Margin__c === true) {
                    addToMarginContributingGrossPriceInclVAT(item.parentPart.totalNetPrice);
                }

            } else if (item.isBundle) {
                addToTotalNetPrice(aggregatedNetPrice);
            } else if (item.isPart && item.isMultilookup) {
                addToTotalNetPrice(aggregatedNetPrice);
                addToVATperGroup(item.parentPart);
                addToSkillperGroup(item.parentPart);
            }

            for (var i = 0; i < item.associatedParts.length; i++) {
                var associatedPart = item.associatedParts[i];

                addToVATperGroup(associatedPart);
                addToSkillperGroup(associatedPart);

                if (associatedPart.part.Discountable__c === true) {
                    addToDiscountableGrossPriceInclVAT(associatedPart.totalPriceIncVAT);
                }
                if (associatedPart.part.Contributing_to_Margin__c === true) {
                    addToMarginContributingGrossPriceInclVAT(associatedPart.totalNetPrice);
                }
            }
        }
    }

    // calculate totalAllowances
    for (var j = 1; j < 7; j++) {
        if (CS.getAttributeValue('Allowance' + j + '_0') && CS.getAttributeValue('Allowance' + j + '_0') !== '' && CS.getAttributeFieldValue('Allowance' + j + '_0', 'Is_Applied')=='TRUE') {
            var maxAmount = CS.getAttributeFieldValue('Allowance' + j + '_0', 'MaxAmount');
            var actualAmount = parseFloat(CS.getAttributeFieldValue('Allowance' + j + '_0', 'ActualAmount'));
            if (actualAmount <= maxAmount) {
                totalAllowances += actualAmount;
            }
        }
    }

    CS.setAttributeValue('Total_Allowance_Value_0', roundPrice(totalAllowances));
    CS.setAttributeValue('Gross_Price_incl_VAT_0', roundPrice(grossPriceInclVAT));
    updateRunningTotal(grossPriceInclVAT);

    CS.setAttributeValue('Total_Net_Price_0', roundPrice(totalNetPrice));
    CS.setAttributeValue('Discountable_Gross_Price_Incl_VAT_0', roundPrice(discountableGrossPriceInclVAT));
    CS.setAttributeValue('Margin_Contributing_Gross_Price_Incl_VAT_0', roundPrice(marginContributingGrossPriceInclVAT));
    CS.setAttributeValue('Total_Cost_0', roundPrice(totalCost));

    calculateTotalMargin();
    CS.setAttributeValue('TotalMargin_0', roundPrice(totalMargin));
}

/**
 * Calculate total skill hours
 */
function calculateTotalSkillHours(excludeCodeList) {
    excludeCodeList = excludeCodeList || [];
    var totalSkillHours = 0;

    function getSkillHours(skillList) {
        var skillHoursCount = 0;

        for (var i = 0; i < skillList.length; i++) {
            var skillCode = skillList[i].skillCode;

            // if exclude code list contains observed skill code just ignore it
            if (_.contains(excludeCodeList, skillCode)) continue;

            skillHoursCount += skillList[i].hours;
        }
        return skillHoursCount;
    }

    for (var id in partsModelJS) {
        if (!partsModelJS.hasOwnProperty(id)) continue;
        
        var item = partsModelJS[id];
        if (!item.isLineItem) continue;

        if (item.isPart) {
            var skillList = item.parentPart.skillsList || [];
            if(skillList.length != 0) {
                totalSkillHours += getSkillHours(skillList) * item.parentPart.quantity;    
            }            
        }

        for (var j = 0; j < item.associatedParts.length; j++) {
            var associatedPartSkillsList = item.associatedParts[j].skillsList || [];
            if(associatedPartSkillsList.length != 0) {
                totalSkillHours += getSkillHours(associatedPartSkillsList) * item.associatedParts[j].quantity;
            }
        }
    }
    return totalSkillHours;
}


/**
 * Creates the HSA and Customer totals tables by calling their separate functions.
 */
function createPricingAndTotalsTables() {

    createPricingTables();

    createHSATotalsTable();
    createCustomerTotalsTable();
}


/*
 *  This is a method which uses the q.js framework so it has to be wrapped.
 */
//require(['node_modules/q/q'], function (Q) {
require(['bower_components/q/q'], function (Q) {    
    jQuery('body').on('click', '.accordion-parent', function() {
        var that = jQuery(this);
        toggleAccordionChildVisibility(that);
    });
    
    /**
     * Toggles the visibility of accordion children
     * @param  {Object} that A parent element whose children's visibility will be toggled.
     */
    function toggleAccordionChildVisibility(that) {
        var currentTime = Date.now();
        var lastClickTime = jQuery(that).data("lastClickTime");
        if (lastClickTime && (currentTime - lastClickTime < 200)) {
             return(false);   // ignore the click
        }
        jQuery(that).data("lastClickTime", currentTime);   // record time of last click
    
        var id = jQuery(that).attr("id");    
        var value = jQuery(that).find('td').first().text();
        var sign = value.substring(0,1);
        if(sign == '+') {
            sign = '-';
        } else {
            sign = '+';
        }
        jQuery(that).find('td').first().text(sign + value.substring(1));

        var visible = jQuery('.accordion-child-' + id).first().css('display');
        CS.Log.warn('toggled');
        if(visible == 'none') {
            jQuery('.accordion-child-' + id).fadeIn();    
        } else {
            jQuery('.accordion-child-' + id).fadeOut();  
        }  
    }
    
    /**
     *  Creates the Pricing tables for both the Customer and HSA pricing screens.
     */
    window.createPricingTables = function createPricingTables(){
        CS.Log.warn('Creating the pricing tables.');
        function addToSectionMap(sectionId, item, sectionMap) {
            //if it does not exist put it in the last section
            if(!sectionId) sectionId = 'last';
            if(!sectionMap[sectionId]) sectionMap[sectionId] = [];
            sectionMap[sectionId].push(item);
        }
        
        function getAllSections() {
        
            var allSections = [];
            if (navigator.device) {
                
                CS.Log.warn('***** Now calling SmartQuery for get Section List Info...');
                
                return CS.DB.smartQuery("SELECT {CS_Template_Section_Header__c:_soup} FROM {CS_Template_Section_Header__c} ")
                    .then(function(qr) {
                        return qr.getAll().then(function(results) {
                            var resultList = [];
                            for (var i = 0; i < results.length; i++) {
                                resultList.push(results[i][0]);
                            }
                            CS.Log.warn('The section headers are: ');
                            CS.Log.warn(resultList);
                            allSections = resultList;
                            
                            return Q.resolve(allSections);
                        });
                    }).fail(function(error) {
                        CS.Log.error('Could not fetch template section headers.');
                    });
        
            } else {
                var deferred = Q.defer();
        
                UISupport.getAllSections(
                    function(result, event) {
                        if (event.status) {
                            allSections = result;
                            deferred.resolve(allSections);
                        } else {
                            deferred.reject();
                        } 
                    }
                );
                return deferred.promise;
            }
        }
        
        // sort them by their template sections
        function sortItemsBySections(sectionPartMap, allSections) {
            
            CS.Log.warn('Sorting the items by template sections...');
            
            //sort the allSections
            allSections.sort(function(a, b) {
                return a.Sequence__c - b.Sequence__c;
            });
        
            // create a map of lvl1 and lvl2 sections
            var sectionsLvl1Lvl2Map = {}; // Map<Id, List<Id>> section1Id is the key, section2Ids are in a list
            _.each(allSections, function(val) {
                if(val.Level_1_Section__c) {
                    if(!sectionsLvl1Lvl2Map[val.Level_1_Section__c]) sectionsLvl1Lvl2Map[val.Level_1_Section__c] = [];
                    sectionsLvl1Lvl2Map[val.Level_1_Section__c].push(val.Id);
                } else {
                    if(!sectionsLvl1Lvl2Map[val.Id]) sectionsLvl1Lvl2Map[val.Id] = [];
                }
            });
            
            //sort the level 1 and level 2 sections
        
            // sort the items by their sections
            var itemArray = []; // an array containing all of the parts and bundles in the correct order ready to be displayed
            _.each(_.keys(sectionsLvl1Lvl2Map), function(section1Id) {
                // get the section1Id, take all of the parts
                _.each(_.keys(sectionPartMap), function(sectionPartId) {
                    if(section1Id == sectionPartId) {
                        var partList = sectionPartMap[section1Id];
                        itemArray.push.apply(itemArray, partList);
                    }
                });
    
                // get all of the section2ids, and add all of the parts
                _.each(sectionsLvl1Lvl2Map[section1Id], function(section2Id) {
                    _.each(_.keys(sectionPartMap), function(sectionPartId) {
                        if(section2Id == sectionPartId) {
                            var partList = sectionPartMap[section2Id];
                            itemArray.push.apply(itemArray, partList);
                        }
                    });
                });
            });
            
            // get all of the 'last' items, and add all of the parts
            _.each(_.keys(sectionPartMap), function(sectionPartId) {
                if('last' == sectionPartId) {
                    var partList = sectionPartMap[sectionPartId];
                    itemArray.push.apply(itemArray, partList);
                }
            });
        
            return itemArray;
        }
        
        // get all the items and parts - iterate through partsModelJS and add them to a list
        var customerSectionPartMap = []; // Map<sectionId, List<partsModel part or bundle>>
        var hsaSectionPartMap = []; // Map<sectionId, List<partsModel part or bundle>>
        var hsaBundlePartMap = {};
        
        CS.Log.warn('Populating the map containing sections and parts...');
        for(var id in partsModelJS) {
            if(!partsModelJS.hasOwnProperty(id)) continue;
            var item = partsModelJS[id];
        
            if ((item.isBundle && item.isLineItem) || (item.isPart && item.isLineItem)) {
        
                if (item.isPart && !(item.isMultilookup)) {
                    var visibleOnPresentationScreen = item.parentPart.part.Visible_on_Quote__c;
                    var showAssociatedParts = item.parentPart.part.Show_Parts__c;
                    if(showAssociatedParts) { // check whether or not the associated parts need to be shown
                        // add the part
                        if(visibleOnPresentationScreen) { // check whether or not the part needs to be visible on the presentation screen (the customer screen)
                            addToSectionMap(item.parentPart.part.CS_Template_Section_Header__c, item, customerSectionPartMap);
                        }
                        addToSectionMap(item.parentPart.part.CS_Template_Section_Header__c, item, hsaSectionPartMap);  

                        // add the associated parts
                        for (var i = 0; i < item.associatedParts.length; i++) {
                            var aPart = item.associatedParts[i];
                            var aPvisibleOnPresentationScreen = aPart.part.Visible_on_Quote__c;
                            if(aPvisibleOnPresentationScreen) { // check whether or not the part needs to be visible on the presentation screen (the customer screen)
                                addToSectionMap(item.parentPart.part.CS_Template_Section_Header__c, aPart, customerSectionPartMap);
                            }
                            addToSectionMap(item.parentPart.part.CS_Template_Section_Header__c, aPart, hsaSectionPartMap);  
                        }
                    } else {
                        if(visibleOnPresentationScreen) {
                            addToSectionMap(item.parentPart.part.CS_Template_Section_Header__c, item, customerSectionPartMap);
                        }
                        addToSectionMap(item.parentPart.part.CS_Template_Section_Header__c, item, hsaSectionPartMap);  
                    }
                } else if (item.isBundle) {
                    var showParts = item.parentBundle.Show_Parts__c;
                    if (showParts) {
                        // add all associated parts
                        for (var i = 0; i < item.associatedParts.length; i++) {
                            var associatedPart = item.associatedParts[i];
                            var aPvisibleOnPresentationScreen = associatedPart.part.Visible_on_Quote__c;
                            if(aPvisibleOnPresentationScreen) {
                                addToSectionMap(associatedPart.part.CS_Template_Section_Header__c, associatedPart, customerSectionPartMap);
                            }
                        }                
                    } else {
                        // add the bundle
                        addToSectionMap(item.parentBundle.CS_Template_Section_Header__c, item, customerSectionPartMap);
                    }

                    // for the hsa add the bundle, all of the associated parts should be visible when you click on the bundle
                    // put the asociated bundle parts in a map for easier retrieval
                    addToSectionMap(item.parentBundle.CS_Template_Section_Header__c, item, hsaSectionPartMap);
                    hsaBundlePartMap[item.parentBundle.Id] = [];
                    for (var i = 0; i < item.associatedParts.length; i++) {
                        var associatedPart = item.associatedParts[i];
                        hsaBundlePartMap[item.parentBundle.Id].push(associatedPart);
                    }   
                }
            }
        }
        
        getAllSections().then(function(resultSections) {
            return Q.all([sortItemsBySections(customerSectionPartMap, resultSections), sortItemsBySections(hsaSectionPartMap, resultSections)]);
        })
        .then(function(resultList) {
            var customerItemList = resultList[0],
                hsaItemList = resultList[1];

            // Create the pricing table
            CS.Log.warn('Creating the pricing tables...');

            // The customer pricing table
            var pricingTable = new Table('pricingTable');
            pricingTable.addHeader().addHeaderRow('Description', 'Quantity', 'Price Per Unit', 'Total Price').closeHeader();
            pricingTable.addBody();
            _.each(customerItemList, function(item) {
                var quantity = 1,
                    description = '',
                    price = 0,
                    contentVersionId = '';
    
                if (item.isBundle) {
                    description = item.parentBundle.Quote_Description__c ? item.parentBundle.Quote_Description__c : (item.parentBundle.Description__c ? item.parentBundle.Description__c : (item.parentBundle.Name ? item.parentBundle.Name : ''));
                    quantity = item.attLastQuantity ? item.attLastQuantity : 1;
                    contentVersionId = item.parentBundle.ContentVersionId__c;
                    price = item.aggregatedPriceInclVAT;
                } else if (item.isPart) {
                    description = item.parentPart.part.Quote_Description__c ? item.parentPart.part.Quote_Description__c : (item.parentPart.part.Description__c ? item.parentPart.part.Description__c : (item.parentPart.part.Name ? item.parentPart.part.Name : ''));
                    quantity = item.parentPart.quantity ? item.parentPart.quantity : 1;
                    contentVersionId = item.parentPart.part.ContentVersionId__c;
                    if(item.parentPart.part.Show_Parts__c) {
                        price = item.parentPart.priceVatIncl * quantity;
                    } else {
                        price = item.aggregatedPriceInclVAT;
                    }
                } else if(item.part) {
                    // it's an associated part 
                    description = item.part.Quote_Description__c ? item.part.Quote_Description__c : (item.part.Description__c ? item.part.Description__c : (item.part.Name ? item.part.Name : ''));
                    quantity = item.quantity ? item.quantity : 1;
                    contentVersionId = item.part.ContentVersionId__c;
                    price = item.priceVatIncl * quantity;
                }
                
                if(contentVersionId && navigator.device) {
                    pricingTable.addRow(new DSAButton('Showroom', contentVersionId).button + description, quantity, formatPrice(price / quantity), formatPrice(price));
                } else {
                    pricingTable.addRow(description, quantity, formatPrice(price / quantity), formatPrice(price));
                }
            });
            pricingTable.closeBody().closeTable();

            // The HSA pricing table
            var hsaPricingTable = new Table('hsaPricingTable');
            hsaPricingTable.addHeader().addHeaderRow('Description', 'Quantity', 'Price Per Unit', 'Total Price').closeHeader();
            hsaPricingTable.addBody();     
            _.each(hsaItemList, function(item) {
                var quantity = 1,
                    description = '',
                    price = 0,
                    contentVersionId = '';
    
                // if the item is bundle it needs to be an accordion
                if (item.isBundle) {
                    description = item.parentBundle.Quote_Description__c ? item.parentBundle.Quote_Description__c : (item.parentBundle.Description__c ? item.parentBundle.Description__c : (item.parentBundle.Name ? item.parentBundle.Name : ''));
                    quantity = item.attLastQuantity ? item.attLastQuantity : 1;
                    contentVersionId = item.parentBundle.ContentVersionId__c;
                    price = item.aggregatedPriceInclVAT;
                    var bundleId = item.parentBundle.Id;
                    var bundleChildren = hsaBundlePartMap[item.parentBundle.Id];

                    if(bundleChildren && bundleChildren.length > 0) {
                        hsaPricingTable.addAccordionParent(bundleId, description, quantity, formatPrice(price / quantity), formatPrice(price));
                        _.each(bundleChildren, function(item) {
                            description = item.part.Quote_Description__c ? item.part.Quote_Description__c : (item.part.Description__c ? item.part.Description__c : (item.part.Name ? item.part.Name : ''));
                            quantity = item.quantity ? item.quantity : 1;
                            contentVersionId = item.part.ContentVersionId__c;
                            price = item.priceVatIncl * quantity;
                            hsaPricingTable.addAccordionChild(bundleId, description, quantity, formatPrice(price / quantity), formatPrice(price));
                        });
                    } else {
                        hsaPricingTable.addRow(description, quantity, formatPrice(price / quantity), formatPrice(price));
                    }
                } else if (item.isPart) {
                    description = item.parentPart.part.Quote_Description__c ? item.parentPart.part.Quote_Description__c : (item.parentPart.part.Description__c ? item.parentPart.part.Description__c : (item.parentPart.part.Name ? item.parentPart.part.Name : ''));
                    quantity = item.parentPart.quantity ? item.parentPart.quantity : 1;
                    contentVersionId = item.parentPart.part.ContentVersionId__c;
                    if(item.parentPart.part.Show_Parts__c) {
                        price = item.parentPart.priceVatIncl * quantity; 
                    } else {
                        price = item.aggregatedPriceInclVAT;
                    }

                    hsaPricingTable.addRow(description, quantity, formatPrice(price / quantity), formatPrice(price));
                } else if(item.part) {
                    // it's an associated part 
                    description = item.part.Quote_Description__c ? item.part.Quote_Description__c : (item.part.Description__c ? item.part.Description__c : (item.part.Name ? item.part.Name : ''));
                    quantity = item.quantity ? item.quantity : 1;
                    contentVersionId = item.part.ContentVersionId__c;
                    price = item.priceVatIncl * quantity;

                    hsaPricingTable.addRow(description, quantity, formatPrice(price / quantity), formatPrice(price));
                }                
            });
            hsaPricingTable.closeBody().closeTable();           

            CS.setTextDisplay('HSA_Part_Summary_0', hsaPricingTable.table);
            CS.setTextDisplay('Customer_Part_Summary_0', pricingTable.table);
        });
    };
});

/**
 * Creates the Customer totals table for the customer pricing screen.
 */
function createCustomerTotalsTable() {
    CS.Log.warn('Creating the Customer Totals table.');
    var totalAllowances = parseFloat(CS.getAttributeValue('Total_Allowance_Value_0'));

    //Create the totals tables
    var sortedVatKeys = [];
    for (var vat in VATperGroup) {
        if (!VATperGroup.hasOwnProperty(vat))
            continue;
        sortedVatKeys.push(vat);
    }
    sortedVatKeys.sort(numberSort);

    // Create the totals Customer table
    var customerTotals = new Table('customerTotals');
    customerTotals.addHeader().closeHeader();
    customerTotals.addBody();
    customerTotals.addRow('Gross Price (Inc VAT):', '', '', '', '', formatPrice(grossPriceInclVAT), 'border-top:1px solid black;font-size:1.1em;');
    customerTotals.addRow('', '', '', '', '', '');

    // show the allowances if selected and applicable
    var showAllowances = false;
    var showTotalMinusOneCent = false;
    for (var j = 1; j < 7; j++) {
        if (CS.getAttributeValue('Allowance' + j + '_0') && CS.getAttributeValue('Allowance' + j + '_0') !== '' && CS.getAttributeFieldValue('Allowance' + j + '_0', 'Is_Applied')=='TRUE') {
            var allowanceName = CS.getAttributeFieldValue('Allowance' + j + '_0', 'AllowanceName');
            var maxAmount = CS.getAttributeFieldValue('Allowance' + j + '_0', 'MaxAmount');
            var actualAmount = parseFloat(CS.getAttributeFieldValue('Allowance' + j + '_0', 'ActualAmount'));

            // "Allowances with Amount 0.01 -> If the amount is 0.01, show amount of 0.00 on the customer pricing screen and in the basket summary quote."
            if (actualAmount === 0.01) {
                actualAmount = 0.00;
                showTotalMinusOneCent = true;
            }

            if (actualAmount <= maxAmount) {
                customerTotals.addRow(allowanceName + ':', '', '', '', '', formatPrice(actualAmount, true), 'font-weight: normal;');
            }
            showAllowances = true;
        }
    }
    if (showAllowances) {
        if (showTotalMinusOneCent) {
            customerTotals.addRow('Total Discounts (Inc VAT):', '', '', '', '', formatPrice(totalAllowances - 0.01), 'border-top:1px solid black;font-size:1.1em;');
            customerTotals.addRow('Total Price Payable (Inc VAT):', '', '', '', '', formatPrice(grossPriceInclVAT - totalAllowances + 0.01), 'font-size:1.1em;');
        } else {
            customerTotals.addRow('Total Discounts (Inc VAT):', '', '', '', '', formatPrice(totalAllowances), 'border-top:1px solid black;font-size:1.1em;');
            customerTotals.addRow('Total Price Payable (Inc VAT):', '', '', '', '', formatPrice(grossPriceInclVAT - totalAllowances), 'font-size:1.1em;');
        }
    }
    customerTotals.closeBody().closeTable();

    CS.setTextDisplay('Customer_Totals_0', customerTotals.table);
}

/**
 * Creates the HSA totals table for the HSA pricing screen.
 */
function createHSATotalsTable() {
    CS.Log.warn('Creating the HSA totals table.');
    var totalAllowances = parseFloat(CS.getAttributeValue('Total_Allowance_Value_0'));

    var sortedVatKeys = [];
    for (var vat in VATperGroup) {
        if (!VATperGroup.hasOwnProperty(vat))
            continue;
        sortedVatKeys.push(vat);
    }
    sortedVatKeys.sort(numberSort);

    // Create the totals HSA table
    var totalsHSA = new Table('totalsHSA');
    totalsHSA.addHeader().closeHeader();
    totalsHSA.addBody();
    totalsHSA.addRow('Gross Price (Inc VAT):', '', '', '', '', formatPrice(grossPriceInclVAT), 'border-top:1px solid black;font-size:1.1em;');
    updateRunningTotal(formatPrice(grossPriceInclVAT));

    // show the allowances if selected and applicable
    var showHsaAllowances = false;
    for (var j = 1; j < 7; j++) {
        if (CS.getAttributeValue('Allowance' + j + '_0') && CS.getAttributeValue('Allowance' + j + '_0') !== '' && CS.getAttributeFieldValue('Allowance' + j + '_0', 'Is_Applied')=='TRUE') {
            var maxAmount = CS.getAttributeFieldValue('Allowance' + j + '_0', 'MaxAmount'),
                actualAmount = parseFloat(CS.getAttributeFieldValue('Allowance' + j + '_0', 'ActualAmount')),
                allowanceName = CS.getAttributeFieldValue('Allowance' + j + '_0', 'AllowanceName');
            if (actualAmount <= maxAmount) {
                totalsHSA.addRow(allowanceName + ':', '', '', '', '', formatPrice(actualAmount, true), 'font-weight: normal;');
            }
            showHsaAllowances = true;
        }
    }
    if (showHsaAllowances) {
        totalsHSA.addRow('Total Discounts (Inc VAT):', '', '', '', '', formatPrice(totalAllowances), 'border-top:1px solid black;font-size:1.1em;');
        totalsHSA.addRow('Total Price Payable (Inc VAT):', '', '', '', '', formatPrice(grossPriceInclVAT - totalAllowances), 'font-size:1.1em;');
        updateRunningTotal(formatPrice(grossPriceInclVAT - totalAllowances));
    }

    totalsHSA.closeBody().closeTable();

    CS.setTextDisplay('HSA_Totals_0', totalsHSA.table);
}

/**
 * Creates the HSA totals table with validated allowances. Used only when "Validate allowance" button is clicked.
 */
function createHSATotalsWithAllowances() {
    CS.Log.warn('Creating the HSA totals table with allowances intact.');
    var totalTempAllowances = 0;

    var sortedVatKeys = [];
    for (var vat in VATperGroup) {
        if (!VATperGroup.hasOwnProperty(vat))
            continue;
        sortedVatKeys.push(vat);
    }
    sortedVatKeys.sort(numberSort);

    // Create the totals HSA table
    var totalsHSA = new Table('totalsHSA');
    totalsHSA.addHeader().closeHeader();
    totalsHSA.addBody();

    calculateTotalMargin();
    //totalsHSA.addRow('Total NET Price:', '', '', '', '', formatPrice(totalNetPrice));
    // Remove the VAT per group as per the request from business - commented out for now
    /*
    totalsHSA.addRow('VAT per Group:');
    for (var i = 0; i < sortedVatKeys.length; i++) {
        var key = sortedVatKeys[i];
        if (key === '0.00')
            continue;
        totalsHSA.addRow('', '', '', '', key + '%', formatPrice(VATperGroup[key]));
    }
    */

    totalsHSA.addRow('Gross Price (Inc VAT):', '', '', '', '', formatPrice(grossPriceInclVAT), 'border-top:1px solid black;font-size:1.1em;');
    updateRunningTotal(formatPrice(grossPriceInclVAT));
    totalsHSA.addRow();

    var showAllowances = false;
    for (var j = 1; j < 7; j++) {
        var actualAmount = parseFloat(jQuery('#discountAllowance' + j).val(), 10),
            allowanceInput = jQuery("#discountAllowance" + j),
            allowanceName = jQuery('#discount' + j + ' :selected').text(),
            allowanceId = jQuery('#discount' + j + ' :selected').val();

        var isLocked = allowanceInput.prop('readonly'),
            hasErrorMessage = jQuery("#allowanceError" + j).val() ? ((jQuery("#allowanceError" + j).val().length) > 0 ? true : false) : false;

        if (isLocked && !hasErrorMessage && allowanceId !== '' && allowanceId != 'none') {
            totalTempAllowances += actualAmount;
            totalsHSA.addRow(allowanceName + ':', '', '', '', '', formatPrice(actualAmount, true), 'font-weight: normal;');
            showAllowances = true;
        }
    }

    if (showAllowances) {
        totalsHSA.addRow('Total Discounts (Inc VAT):', '', '', '', '', formatPrice(totalTempAllowances), 'border-top:1px solid black;font-size:1.1em;');
        totalsHSA.addRow('Total Price Payable (Inc VAT):', '', '', '', '', formatPrice(grossPriceInclVAT - totalTempAllowances), 'font-size:1.1em;');
        updateRunningTotal(formatPrice(grossPriceInclVAT - totalTempAllowances));
    }

    totalsHSA.closeBody().closeTable();

    CS.setTextDisplay('HSA_Totals_0', totalsHSA.table);
}

/**
 * Creates the allowances buttons table (buttons 1 - 7)
 */
function createAllowancesButtons() {
    CS.Log.warn('Creating the allowance buttons.');
    var customerAvailableAllowances = '<div id="allowanceButtons">';
    customerAvailableAllowances += new Button('allowance1', '1', "onAllowanceButtonClick('allowance1')").button;
    customerAvailableAllowances += new Button('allowance2', '2', "onAllowanceButtonClick('allowance2')").button;
    customerAvailableAllowances += new Button('allowance3', '3', "onAllowanceButtonClick('allowance3')").button;
    customerAvailableAllowances += new Button('allowance4', '4', "onAllowanceButtonClick('allowance4')").button;
    customerAvailableAllowances += new Button('allowance5', '5', "onAllowanceButtonClick('allowance5')").button;
    customerAvailableAllowances += new Button('allowance6', '6', "onAllowanceButtonClick('allowance6')").button;
    customerAvailableAllowances += new Button('applyAll', '7', "onAllowanceButtonClick('applyAll')").button;
    customerAvailableAllowances += '</div>';

    CS.setTextDisplay('Customer_Allowance_Buttons_0', customerAvailableAllowances);
}

/**
 * Creates the skills table with aggregated skill amounts.
 */
function createSkillsTable() {
    CS.Log.warn('Creating Skills table.');
    var skillTable = new Table('skillTable');
    skillTable.addHeader();
    skillTable.addHeaderRow('Skill Name', 'Skill Code', 'Number of Hours');
    skillTable.closeHeader();
    skillTable.addBody();
    for (var key in skillsPerGroup) {
        if (!skillsPerGroup.hasOwnProperty(key))
            continue;
        var skillName = key;
        var skillCode = skillsPerGroup[key].skillCode;
        var amount = skillsPerGroup[key].amount;
        skillTable.addRow(skillName, skillCode, amount.toFixed(2));
    }
    skillTable.closeBody().closeTable();
    
    var coreBundleSummary = buildCoreBundleSummary();
    
    CS.setTextDisplay('Skill_Summary_0', skillTable.table + '<br/>' + coreBundleSummary);
}

function buildCoreBundleSummary(){
    //build the core bundle info
    var coreBundleSummary = '';
    if(CS.getAttributeValue('Boiler_0:System_Type_0' ) && CS.getAttributeValue('Boiler_0:Location_Type_0' )) {
        coreBundleSummary = '<h3>Core Bundle Summary</h3>';
        coreBundleSummary += '<p>' + CS.getAttributeValue('Boiler_0:System_Type_0' ) + '</p>';
        coreBundleSummary += '<p>' + CS.getAttributeValue('Boiler_0:Location_Type_0') + '</p>';    
        //IC 16/03/2015
        //if(partCodeExistsInPartsModelJS('P2969')){
        //    coreBundleSummary += '<p style="color:red">Pre electrical survey required</p>'; 
        //}
        coreBundleSummary += '<p>Boiler availability: '+ CS.getAttributeValue('Boiler_0:Boiler_Availability_0')+'</p>';
    }
    return coreBundleSummary;
}

/**
 * Creates the finance matrix table. 
 */
function createFinanceMatrixTable() {
    var sortedFinanceTerms = [],
        sortedFinanceRates = [];

    var productIndex = CS.Service.getProductIndex(),
        financeTermDefinitionId = CS.getAttributeWrapper('Finance_Term_0').definitionId,
        financeTermSelectOptions = productIndex.selectOptionsMapByAttribute[financeTermDefinitionId],
        financeRateDefinitionId = CS.getAttributeWrapper('Monthly_Interest_Rate_0').definitionId,
        financeRateSelectOptions = productIndex.selectOptionsMapByAttribute[financeRateDefinitionId];
    
    _.each(financeTermSelectOptions, function(val) {
        sortedFinanceTerms.push(val);
    });
    sortedFinanceTerms = _.sortBy(sortedFinanceTerms, 'cscfga__Sequence__c');
        
    _.each(financeRateSelectOptions, function(val) {
        sortedFinanceRates.push(val);
    });    
    sortedFinanceRates = _.sortBy(sortedFinanceRates, 'cscfga__Sequence__c');
    
    //Create table 
    var financeTable = new Table('financeTable');
    financeTable.addHeader().addHeaderRow('Loan Term (Years)', 'Loan Term (Months)', 'Minimum monthly repayment', 'Total amount repayable').closeHeader(); 
    financeTable.addBody(); 
    
    var balanceOutstanding = parseFloat(CS.getAttributeValue('Balance_Outstanding_0')), //variable 
        numOfMonths = parseInt(CS.getAttributeValue('Number_of_Months_0'), 10); //hardcoded 
    var annualInterestRate = 0.149;
    var monthlyInterestRate = parseFloat((Math.pow((1 + annualInterestRate), (1/12)) - 1).toFixed(7));

    var numOfFinanceItems = sortedFinanceTerms.length;
    for(var i=0; i<numOfFinanceItems; i++) {
        var financeTerm = parseInt(sortedFinanceTerms[i].cscfga__Value__c, 10);
            
        var value1 = parseFloat(balanceOutstanding * monthlyInterestRate);
        var value2 = Math.pow((1 + monthlyInterestRate), -1 * numOfMonths * financeTerm);
        var value3 = parseFloat(1 - value2);

        var monthlyPayment = parseFloat(value1 / value3);
        var totalAmountPayable = parseFloat(monthlyPayment * numOfMonths * financeTerm);

        financeTable.addRow(financeTerm, financeTerm * numOfMonths, formatPrice(monthlyPayment), '&pound;' + Math.round(totalAmountPayable));
    }
    
    financeTable.closeBody().closeTable(); 
    CS.setTextDisplay('Finance_Terms_Matrix_0', financeTable.table);
}

/**
 * Calls the exposed method for showing showroom content.
 * @param {String} id An id of the content to be displayed.
 */
function displayShowroomContentForId(id) {
    if(navigator.device){
        CS.Log.warn('Calling the method for displaying content...');
        CS.Log.warn('Id of the content to be displayed: ' + id);
        CS.Log.warn('the method to be called:');
        CS.Log.warn(CS.DSA.displayContentFromSFID);
        CS.DSA.displayContentFromSFID(id)
            .fail(function(e) { 
                navigator.notification.alert( 
                    'The selected content cannot be loaded.', // message 
                    null, // callback 
                    'Alert', // title 
                    'Ok' // buttonName 
                ); 
            });
    }
}

/**
 * A wrapper used to display a priced line Item or an applied Allowance on the Basket Summary Page on the iPad
 * @constructor
 */
function LineItemWrapper(aName, descr, qty, totalPrice, totalPriceWithVat) {
    this.ItemName = aName;
    this.ItemDescription = descr;
    this.ItemQuantity = qty;
    this.ItemTotalNetPrice = totalPrice;
    this.ItemTotalPriceInclVAT = totalPriceWithVat;
}

/**
 * Creates the line items of a Product Configuration for the Basket Summary Page on the iPad
 * @param {Array} allParts
 * @param {Object} config
 */
function createLineItems(allParts, config) {

    var lineItemList = [],
        allowanceItemList = [],
        totalPriceInclVAT = 0,
        totalDiscounts = 0;

    var allowanceAttributesForConfig = [],
        allowanceAttributes = ["Allowance1", "Allowance2", "Allowance3", "Allowance4", "Allowance5", "Allowance6"];

    for (var it in config) {
        var configEntry = config[it];
        if (configEntry.attr && allowanceAttributes.indexOf(configEntry.attr.Name) > -1) {
            allowanceAttributesForConfig.push(configEntry);
        }
    }

    // Build Line Items for Allowances
    for (var i = 0; i < allowanceAttributesForConfig.length; i++) {
        var currentAllowance = allowanceAttributesForConfig[i];
        var allowanceName = '';
        var allowanceActualValue = 0;

        //Only for Allowance Attributes that hold a value, and are applied
        if (currentAllowance.attributeFields && currentAllowance.attributeFields['Is_Applied'].cscfga__Value__c == 'TRUE' && currentAllowance.attr && currentAllowance.attr.cscfga__Value__c) {
            
            allowanceName = currentAllowance.attributeFields['AllowanceName'].cscfga__Value__c;
            allowanceActualValue = parseFloat(currentAllowance.attributeFields['ActualAmount'].cscfga__Value__c);

            totalDiscounts += allowanceActualValue;
            allowanceItemList.push(new LineItemWrapper(allowanceName, allowanceName, 1, allowanceActualValue, allowanceActualValue)); //DO NOT DISPLAY NET FOR ALLOWANCES
        }
    }

    // Build Line Items for priced Items
    for (var key in allParts) {
        var entry = allParts[key];
        var entryDescription = '';
        
        if (entry.isLineItem && entry.isPart && !entry.isMultilookup) {
            //construct item for Parent Part
            entryDescription = entry.parentPart.part.Quote_Description__c ? entry.parentPart.part.Quote_Description__c : (entry.parentPart.part.Description__c ? entry.parentPart.part.Description__c : (entry.parentPart.part.Name ? entry.parentPart.part.Name : ''));
            lineItemList.push(new LineItemWrapper(entry.parentPart.part.Name, entryDescription, entry.parentPart.quantity, roundPrice(entry.aggregatedNetPrice), roundPrice(entry.aggregatedPriceInclVAT)));
        } else if (entry.isLineItem && entry.isBundle) {
            // Change made to check the .parentBundle.Show_Parts__c flag, if the flag is true, show parts instead of bundles
            var showParts = entry.parentBundle.Show_Parts__c;
            if (showParts) {
                 for (var k = 0; k < entry.associatedParts.length; k++) {
                    var associatedPart = entry.associatedParts[k],
                        associatedPartDescription = associatedPart.part.Quote_Description__c ? associatedPart.part.Quote_Description__c : (associatedPart.part.Description__c ? associatedPart.part.Description__c : (associatedPart.part.Name ? associatedPart.part.Name : ''));
                    lineItemList.push(new LineItemWrapper(associatedPart.part.Name, associatedPartDescription, associatedPart.quantity, roundPrice(associatedPart.totalNetPrice), roundPrice(associatedPart.totalPriceIncVAT)));
                }
            } else {
                entryDescription = entry.parentBundle.Quote_Description__c ? entry.parentBundle.Quote_Description__c : (entry.parentBundle.Description__c ? entry.parentBundle.Description__c : (entry.parentBundle.Name ? entry.parentBundle.Name : ''));
                lineItemList.push(new LineItemWrapper(entry.parentBundle.Name, entryDescription, entry.attLastQuantity, roundPrice(entry.aggregatedNetPrice), roundPrice(entry.aggregatedPriceInclVAT)));
            }    

        } else if (entry.isLineItem && entry.isPart && entry.isMultilookup) {
            for (var j = 0; j < entry.associatedParts.length; j++) {
                var pi = entry.associatedParts[j],
                    piDescription = pi.part.Quote_Description__c ? pi.part.Quote_Description__c : (pi.part.Description__c ? pi.part.Description__c : (pi.part.Name ? pi.part.Name : ''));
                lineItemList.push(new LineItemWrapper(pi.part.Name, piDescription, pi.quantity, roundPrice(pi.totalNetPrice), roundPrice(pi.totalPriceIncVAT)));
            }
        }
    }
    
    var configLineItems = {
        allowanceLineItems: allowanceItemList,
        pricedLineItems: lineItemList
    };

    return configLineItems;
}

/**
 * This method binds the onchange method to the asbestos identified field in the straight swaps product.
 * It updates the account with asbestos details if the user confirms the popup query.
 */
jQuery(document).on('change', '#Asbestos_and_Stores\\:Asbestos_Identified_0', function() {
    setTimeout(function() {
        var asbestosFound = CS.getAttributeValue('Asbestos_Identified_0');
        if(asbestosFound == 'Yes') {
            // UPDATING THE ACCOUNT WILL ONLY BE DONE ON THE ONLINE
            // IT WILL NOT WORK ON THE IPAD
            // update the flag on the account that asbestos exists
            // this can only be done on the online, not on the iPad
            function disableQuoteFinish() {
                CS.markConfigurationInvalid('', 'Quotation cannot be processed where asbestos exists.');
                CS.makeAttributeReadOnly('Quote_Status_0');
                CS.setAttributeValue('Quote_Status_0', 'Quote Finalised - Not Accepted');
                jQuery('button[data-cs-group="Finish"]').hide();
            } 

            function showPopup() {
                var asbestosPopup = confirm("The Account will be updated with the new Asbestos information.\nPlease confirm the change.");
                if (asbestosPopup == true) {
                    disableQuoteFinish();
                    // call the remote action    
                    // on any result show a message on the screen
                    var accountId = CS.getAttributeValue('Appointment_Account_Id_0');
                    if(accountId && ((accountId.length == 15) || (accountId.length == 18))) {
                        UISupport.updateAsbestosDetails(
                            accountId,
                            function(result, event) {
                                if (event.status) {
                                    alert(result);
                                }
                                else {
                                    alert(result);
                                }
                        });
                    } else {
                        CS.Log.warn('Invalid account id.');
                    }
                } else {
                    // set the attribute value to false
                    CS.setAttributeValue('Asbestos_Identified_0', '--None--');   
                    CS.Rules.evaluateAllRules();
                }
            }

            if(navigator.device) {
                // iPad context
                disableQuoteFinish();
            } else {
                // show a confirmation popup first  
                showPopup();        
            }
        }
    }, 350); 
});