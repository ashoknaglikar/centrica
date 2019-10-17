/** @constant
 *  @type {string}
 *  @default
 */
var allowanceRequiredType = 'Required';

/** @constant
 *  @type {string}
 *  @default
 */
var allowanceCalculationType = 'Calculation';

/** @constant
 *  @type {string}
 *  @default
 */
var allowanceNotAllowedType = 'Not Allowed';

var allowance; //represents the given CS_Allowance__c record
var allowanceMax;
var allowancePartAvailabilities = []; //array holding part dependencies of the allowance   Part/Allowance/Type/Amount/Quantity
var allowanceCategoryAvailabilities = []; //array holding part Type dependencies of the allowance   Category/Allowance/Type/Amount/Quantity


//require(['node_modules/q/q'], function (Q) {
require(['bower_components/q/q'], function (Q) {    
    /**
     * Toggles the button css background property to show the button click effect.
     * @param  {String} item Id of the button OR the button object itself.
     */
    window.toggleBtnCss = function toggleBtnCss(item){
        var deferred = Q.defer();
        
        if(typeof item === 'string') {
            item = jQuery('#' + item);
        } else {
            item = jQuery(item);
        }
        
        if(navigator.device){
            item.css('background', '-webkit-gradient(linear, left bottom, left top, from(#fff), to(#ccc))');
            window.setTimeout(function(){
                item.css('background', '-webkit-gradient(linear, left top, left bottom, from(#fff), to(#ccc))');
                deferred.resolve();
            }, 300);   
        }
        return deferred.promise;
    }

    /** 
     * Returns the age of a user in years. 
     * @param {Date} birthDate
     * @returns {Number}
     */
    function getAge(birthDate) {
        var today = new Date();
        var age = today.getFullYear() - birthDate.getFullYear();
        var m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age--;
        }
        return age;
    }
            
    /**
     *  Creates HSA allowances table containing the select lists, maximum value spans, input fields.
     */
    window.createHSAAllowancesTable = function createHSAAllowancesTable() {
    
        CS.Log.warn('createHSAAllowancesTable called...');
        var discount = createEmptySelectList();
    
        var allowancesHSA = new Table('allowancesHSA');
        allowancesHSA.addHeader().addHeaderRow('#', 'Select Allowance', 'Max Amount', 'Actual Amount', '', '').closeHeader();
        allowancesHSA.addBody();
    
        for (var i = 1; i <= 6; i++) {
    
            allowancesHSA.addRow(i + '.',
                new SelectList('discount' + i, discount).selectlist,
                '<span id="allowanceCode' + i + '" style="display: none;"></span>' + '<span id="allowanceLowCampaign' + i + '" style="display: none;"></span>' + '<span id="allowanceNonCash' + i + '" style="display: none;"></span>' + '<span id="allowanceCashEquivalent' + i + '" style="display: none;"></span>' + '<span id="maxAllowance' + i + '">0.00</span>',
                new InputField('discountAllowance' + i).input,
                new Button('validateAllowance' + i, 'Validate', "lockAllowanceField(" + i + ")").button,
                '<div class="ps-error" id="allowanceError' + i + '"></div>');
        }
        allowancesHSA.addRow('', '', '', new Button('discountDone', 'Allowances Configured', "onAllowancesDoneClick()").button);
        allowancesHSA.closeBody().closeTable();
        CS.setTextDisplay('HSA_Allowances_0', allowancesHSA.table);
    
        // every time the table is recreated, get the available allowances for the first select list (dropdown)
        return getApplicableAllowances('discount1');
    };
    
    /**
     * Gets the applicable allowances for a select list specified by the id.
     * Uses an internal function tickWorkers to ensure the select list
     * gets populated only after the method response.
     * @param {String} selectListId
     */
    
    window.getApplicableAllowances = function getApplicableAllowances(selectListId) {
        CS.Log.warn('getApplicableAllowances called');
        CS.Log.warn('selectListId: ' + selectListId);
    
        return calculateElligibleAllowancesForNextStep().then(function (results) {
            CS.Log.warn('*** calculateElligibleAllowancesForNextStep finished..');
            var allowanceList = results;
                        
            CS.Log.warn('selectListId: ' + selectListId);
            CS.Log.warn('allowanceList: ' + allowanceList);
                
            populateSelectList(selectListId, allowanceList);
                
            return Q.resolve();
        });
    };
    
    /**
     * Gets the allowance, allowancePartAvailabilities and allowanceCategoryAvailabilities based on the allowanceId.
     * Uses the internal tickWorkers method for synchronization of multiple asynchronous server method calls.
     * Calls the calculateAllowanceMaxValue when all methods have gotten a response from the server.
     * @param {String} allowanceId - id of the allowance which will be used for server queries
     * @param {Function} callback - a callback function passed further to calculateAllowanceMaxValue method.
     */
    window.validateAllowance = function validateAllowance(allowanceId, callback) {
    
        var workers = 0;
    
        function fetchAllowance(allowanceId, callback) {
            var device = (navigator.device ? 'iPad' : 'Laptop');
            if (device == ipadDevice) {
                CS.DB.smartQuery("SELECT {CS_Allowance__c:_soup} FROM {CS_Allowance__c} WHERE {CS_Allowance__c:Id} = '" + allowanceId + "'").then(function (qr) {
                    qr.getAll().then(function (results) {
                        allowance = results[0][0];
                        CS.Log.warn('Got allowance: ' + allowance);
                        tickWorkers(function () {
                            calculateAllowanceMaxValue(callback);
                        });
                    });
                })
                .fail(function(e) { CS.Log.error(e);});
    
            } else if (device == laptopDevice) {
                UISupport.getAllowance(
                    allowanceId,
                    function (result, event) {
                    if (event.status) {
                        CS.Log.warn('Got allowance: ' + result);
                        allowance = result;
                        tickWorkers(function () {
                            calculateAllowanceMaxValue(callback);
                        });
                    }
                });
            }
        }
    
        function fetchAllowancePartAvailabilities(allowanceId, callback) {
            var device = (navigator.device ? 'iPad' : 'Laptop');
            if (device == ipadDevice) {
                CS.DB.smartQuery("SELECT {CS_Allowance_Part_Availability__c:_soup} FROM {CS_Allowance_Part_Availability__c} WHERE {CS_Allowance_Part_Availability__c:CS_Allowance__c} = '" + allowanceId + "'").then(function (qr) {
                    qr.getAll().then(function (results) {
                        allowancePartAvailabilities = [];
                        for (var i = 0; i < results.length; i++) {
                            allowancePartAvailabilities.push(results[i][0]);
                        }
                        CS.Log.warn('Got allowancePartAvailabilities: ' + allowancePartAvailabilities);
                        tickWorkers(function () {
                            calculateAllowanceMaxValue(callback);
                        });
                    });
                })
                .fail(function(e) { CS.Log.error(e);});
    
            } else if (device == laptopDevice) {
                UISupport.getAllowancePartAvailabilities(
                    allowanceId, //of all Types
                    function (result, event) {
                        if (event.status) {
                            CS.Log.warn('Got allowancePartAvailabilities: ' + result);
                            allowancePartAvailabilities = result;
                            tickWorkers(function () {
                                calculateAllowanceMaxValue(callback);
                            });
                        }
                    }
                );
            }
        }
    
        function fetchAllowanceCategoryAvailabilities(allowanceId, callback) {
            var device = (navigator.device ? 'iPad' : 'Laptop');
            if (device == ipadDevice) {
                CS.DB.smartQuery("SELECT {CS_Allowance_Category_Availability__c:_soup} FROM {CS_Allowance_Category_Availability__c} WHERE {CS_Allowance_Category_Availability__c:CS_Allowance__c} = '" + allowanceId + "'").then(function (qr) {
                    qr.getAll().then(function (results) {
                        allowanceCategoryAvailabilities = [];
                        for (var i = 0; i < results.length; i++) {
                            allowanceCategoryAvailabilities.push(results[i][0]);
                        }
                        CS.Log.warn('Got allowanceCategoryAvailabilities: ' + allowanceCategoryAvailabilities);
                        tickWorkers(function () {
                            calculateAllowanceMaxValue(callback);
                        });
                    });
                })
                .fail(function(e) { CS.Log.error(e);});
    
            } else if (device == laptopDevice) {
                UISupport.getAllowanceCategoryAvailabilities(
                    allowanceId, // of all Types
                    function (result, event) {
                        if (event.status) {
                            CS.Log.warn('Got allowanceCategoryAvailabilities: ' + result);
                            allowanceCategoryAvailabilities = result;
                            tickWorkers(function () {
                                calculateAllowanceMaxValue(callback);
                            });
                        }
                    }
                );
            }
        }
    
        function tickWorkers(doneCallback) {
            workers--;
            if (workers === 0) {
                if (doneCallback) {
                    doneCallback();
                }
            }
        }
    
        fetchAllowance(allowanceId, callback);
        workers++;
        
        fetchAllowancePartAvailabilities(allowanceId, callback);
        workers++;
        
        fetchAllowanceCategoryAvailabilities(allowanceId, callback);
        workers++;
    };
    
    /**
     * Calculates the allowance max value. Also populates the allowance code hidden span, isLowCampaign, isNonCash, nonCashEquivalentAmount.
     * Sets the maxValus to a temporary global variable allowanceMax.
     * Executes the callback method after the calculation.
     * @param {Function} callback
     */
    function calculateAllowanceMaxValue(callback) {
    
        var maxAmount = 0; //will hold the allowance value that will be calculated
    
        // check whether the allowance is margin based
        // margin based allowances should not have Part nor Category associations of the type 'Calculation'
        var isMarginBased = allowance.Margin_Based__c;
        if (isMarginBased) {
    
            var marginContributingGrossTotal = parseFloat(CS.getAttributeValue('Margin_Contributing_Gross_Price_Incl_VAT_0'));
            var totalCost = parseFloat(CS.getAttributeValue('Total_Cost_0'));
            var fixedOverhead = parseFloat(CS.getAttributeValue('Fixed_Overhead_0'));
            var appliedAllowancesWithCashEquivalentAmount = getSumOfAllowancesWithCashEquivalentAmount();
            var isAnyAllowanceLowCampaign = hasAnyAllowanceLowCampaign();

            maxAmount = marginContributingGrossTotal - totalCost - appliedAllowancesWithCashEquivalentAmount - fixedOverhead;
    
            if (isAnyAllowanceLowCampaign) {
                var VBLow = parseFloat(CS.getAttributeValue('VBLow_0'));
                var VBLowFloor = parseFloat(CS.getAttributeValue('VBLowFloor_0'));
                maxAmount = maxAmount * (VBLow / 100);
                
                maxAmount = maxAmount < VBLowFloor ? VBLowFloor : maxAmount;
            } else {
                var VBHigh = parseFloat(CS.getAttributeValue('VBHigh_0'));
                var VBHighFloor = parseFloat(CS.getAttributeValue('VBHighFloor_0'));
                maxAmount = maxAmount * (VBHigh / 100);
                
                maxAmount = maxAmount < VBHighFloor ? VBHighFloor : maxAmount;
            }
    
            var allowanceVAT = parseFloat(CS.getAttributeValue('Allowance_VAT_0'));
    
            maxAmount = maxAmount * ((allowanceVAT / 100) + 1);
    
        } else {
            // Else the allowance is not margin based 
            
            var grossAmountVATIncl = CS.getAttributeValue('Gross_Price_incl_VAT_0');
            var allowancesSum = getSumOfAlreadyConfiguredAllowances(); // sum up already configured allowance Actual Amounts
            
            var calculationPartAvailabilities = getAllowancePartAvailabilityRecords(allowancePartAvailabilities, allowanceCalculationType);
            var calculationCategoryAvailabilities = getAllowanceCategoryAvailabilityRecords(allowanceCategoryAvailabilities, allowanceCalculationType);
            
            //Check if there are no Part or Category Rules, then the Allowance is a direct deduction to overall price (minus already configured Allowances)
            // This is also the case if Allowance Type = 'Amount'
            if (allowance.Allowance_Type__c == 'Amount') {
                maxAmount = maxAmount + allowance.Amount__c;
                CS.Log.warn('Allowance Amount: ' + allowance.Amount__c + ' added to maxAmount.');
            } 

            // "When the Allowance is a Percentage and is applied to the entire solution (i.e. there are no Calculation rules), then consider ONLY the Discountable Parts, not the Overall Gross"
            else if (allowance.Allowance_Type__c == 'Percent' && (!calculationPartAvailabilities || calculationPartAvailabilities.length === 0) && (!calculationCategoryAvailabilities || calculationCategoryAvailabilities.length === 0)){
                var discountableGrossPriceInclVAT = CS.getAttributeValue('Discountable_Gross_Price_Incl_VAT_0');
                maxAmount += (discountableGrossPriceInclVAT - allowancesSum) * (allowance.Amount__c / 100);
                CS.Log.warn('Max amount increased to: ' + maxAmount);
            } 
            // Else
            // Loop through PartRules & CategoryRules of type 'Calculation'.
            // If there is no Quantity, then calculate directly as Allowance applied to 'all that apply'.
            // If a rule WITH Quantity is found, then calculate the number of groups (meaning how many times the allowance can be applied) - considering the quantities of Rules of type 'Required'.
            // Get all rules (PartRules & PartTypeRules) of Type 'Required' that have a Quantity != null
            // Check occurrence of Parts that match the rules and calculate the number groups
            
            // Then, get the parts that match the rule from the partsModel, sort by Price asc - Note their Quantities!
            // discount the first X (where X = groups)
            else {

                var numberOfGroups = calculateGroups(allowancePartAvailabilities, allowanceCategoryAvailabilities); //gives us how many times an Allowance will be applied (for Calculation Rules that have a Quantity)
                CS.Log.warn('Groups found: ' + numberOfGroups);
    
                //Loop through Allowance Part Availabilities of type calculation.
                for (var i = 0; i < calculationPartAvailabilities.length; i++) {
                    var calcPartAvailability = calculationPartAvailabilities[i];
                    
                    CS.Log.warn('Looping through AllowancePartAvailabilities...');
                    
                    //Similar to current Rule: "Data value % of sum all qualifying parts added". Get all matching parts from partsModelJS, with their prices
                    var qualifyingParts = getMatchingPartsById(calcPartAvailability.CS_Part__c);

                    CS.Log.warn('Part availability quantity: ' + calcPartAvailability.Quantity__c);
                    if (!calcPartAvailability.Quantity__c) { // if Quantity is null apply discount to ALL matching parts in the partsModel
                        for (var j = 0; j < qualifyingParts.length; j++) {
                            var part = qualifyingParts[j];
    
                            //Note that item will always be included as this check is done to qualify the allowance before selection
                            maxAmount = maxAmount + (part.totalPriceIncVAT * (allowance.Amount__c / 100)); //we assume it's always percentage, totalPriceIncVAT considers quantities
                            CS.Log.warn('Max amount increased to: ' + maxAmount);
                        }
                        CS.Log.warn('Empty Quantity found. Applied Allowance to all qualifying parts.');
    
                    } else {
                        //We have already calculated groups. Sort the qualifying items by price ascending.
                        //If Quantity is specified, then it is a bundled offer in which case we need to check groups of items.
                        //For example: Buy 2, get 3rd free (we need to search how many times this group of 2 appears in the solution).
    
                        var partPricesArray = [];
                        for (var k = 0; k < qualifyingParts.length; k++) {
                            var part = qualifyingParts[k];
    
                            for (var m = 0; m < part.quantity; m++) { // If a Part has quantity other than 1, it needs to be added as many times as applicable.
                                partPricesArray.push(part.price);
                            }
                        }
                        partPricesArray.sort(function(a, b){return a-b});
    
                        var partMultiplier = calcPartAvailability.Quantity__c * numberOfGroups;
                        CS.Log.warn('Multiplier for ' + calcPartAvailability + ' is ' + partMultiplier);
    
                        partMultiplierCounter = 0;
                        for (var n = 0; n < partPricesArray.length; n++) {
                            var price = partPricesArray[n];
    
                            if (partMultiplierCounter < partMultiplier) {
                                maxAmount = maxAmount + (price * (allowance.Amount__c / 100));
                                CS.Log.warn('Max amount increased to: ' + maxAmount);
                                partMultiplierCounter++;
                            }
                        }
                    }
                }
    
                // Loop through Allowance Category Availabilities of type calculation.
                for (var p = 0; p < calculationCategoryAvailabilities.length; p++) {
                    CS.Log.warn('Looping through AllowanceCategoryAvailabilities...');
                    var calcCategoryAvailability = calculationCategoryAvailabilities[p];
    
                    // Get all matching parts from partsModelJS, get their prices
                    var qualifyingPartsByCategory = getMatchingPartsByDiscountCategory(calcCategoryAvailability.CS_Discount_Category_Name__c);
                    CS.Log.warn('qualifyingPartsByCategory: ' + qualifyingPartsByCategory);
    
                    CS.Log.warn('Category availability quantity: ' + calcCategoryAvailability.Quantity__c);
                    if (!calcCategoryAvailability.Quantity__c) { //Quantity is null => apply discount to ALL matching parts in the partsModel

                        CS.Log.warn('quantity is null or 0 ..');
                        for (var q = 0; q < qualifyingPartsByCategory.length; q++) {
                            var part = qualifyingPartsByCategory[q];
    
                            CS.Log.warn('part: ' + part.part.Name);
                            
                            //Note that item will always be included as this check is done to qualify the allowance before selection
                            maxAmount = maxAmount + (part.totalPriceIncVAT * (allowance.Amount__c / 100)); //we assume it's always percentage, tbc
                            CS.Log.warn('Max amount increased to: ' + maxAmount);
                        }
    
                        CS.Log.warn('Empty Quantity found. Applied Allowance to all qualifying parts.');
                    } else {

                        // We have already calculated groups. Sort the qualifying items by price ascending. 
                        var partPricesArray = [];
                        for (var r = 0; r < qualifyingPartsByCategory.length; r++) {
                            var part = qualifyingPartsByCategory[r];
    
                            for (var s = 0; s < part.quantity; s++) { // If a Part has quantity other than 1, it needs to be added as many times as applicable.
                                partPricesArray.push(part.price);
                            }
                        }
                        partPricesArray.sort(function(a, b){return a-b}); //perform numeric sort in ascending order

                        CS.Log.warn('partPricesArray: ');
                        CS.Log.warn(partPricesArray);
    
                        var categoryMultiplier = calcCategoryAvailability.Quantity__c * numberOfGroups;
                        CS.Log.warn('Multiplier for ' + calcCategoryAvailability + ' is ' + categoryMultiplier);
    
                        categoryMultiplierCounter = 0;
                        for (var t = 0; t < partPricesArray.length; t++) {
                            var price = partPricesArray[t];
    
                            if (categoryMultiplierCounter < categoryMultiplier) {
                                maxAmount = maxAmount + (price * (allowance.Amount__c / 100));
                                CS.Log.warn('Max amount increased to: ' + maxAmount);
                                categoryMultiplierCounter++;
                            }
                        }
                    }
                }
            }
        }
    
        // A global variable is used to set the maximum amount, and it is set using the callback.
        allowanceMax = maxAmount;
        CS.Log.warn('Max Amount is: ' + allowanceMax);
        callback();
    }
    
    // --------------------------------------------
    // from allowanceSupportingFunctions.js
    // --------------------------------------------
    
    /**
     * Get the sum total of already configured allowances.
     * @returns {Number} totalAllowances
     */
    function getSumOfAlreadyConfiguredAllowances() {
        // should we get the values from the configurator fields?
        //loop through the 6 rows and sum up the Actual Amounts of already configured allowances.
        var totalAllowances = 0;
        for (var i = 1; i < 7; i++) {
            var selectListValue = jQuery("#discount" + i).val();
            var actualValue = isNumber(jQuery("#discountAllowance" + i).val()) ? parseFloat(jQuery("#discountAllowance" + i).val()) : 0.00;
    
            if (selectListValue !== '' && selectListValue != 'none') {
                if (isNumber(actualValue)) {
                    totalAllowances += parseFloat(actualValue);
                }
            }
        }
        return totalAllowances;
    }
    /**
     * Get the sum total of already configured allowances including the cash equivalent for non cash allowances.
     * @returns {Number} totalAllowances
     */ 
    window.getSumOfAllowancesWithCashEquivalentAmount = function getSumOfAllowancesWithCashEquivalentAmount(){
        var totalAllowances = 0;
    
        var allowancesTable;
        if (jQuery('span[data-cs-binding="HSA_Allowances_0"] table')[0]) {
            allowancesTable = jQuery('span[data-cs-binding="HSA_Allowances_0"] table');
        } else {
            allowancesTable = jQuery(CS.getAttributeValue('HSA_Allowances_0'));
        }

        for (var i = 1; i < 7; i++) {
            var selectListValue = allowancesTable.find("#discount" + i).val();
            var actualValue = 0.00;
            
            var isNonCash = allowancesTable.find("#allowanceNonCash" + i).text();       
            if(isNonCash == 'true'){
                actualValue = isNumber(allowancesTable.find("#allowanceCashEquivalent" + i).text()) ? parseFloat(allowancesTable.find("#allowanceCashEquivalent" + i).text()) : 0.00;
            } else {
                actualValue = isNumber(allowancesTable.find("#discountAllowance" + i).val()) ? parseFloat(allowancesTable.find("#discountAllowance" + i).val()) : 0.00;
            }
    
            if (selectListValue !== '' && selectListValue != 'none') {
                if (isNumber(actualValue)) {
                    totalAllowances += parseFloat(actualValue);
                }
            }
        }
        return totalAllowances;
    };
    
    /**
     * Returns whether a low campaign flag exists for any applied allowance.
     * @returns {Boolean} exists
     */
    function hasAnyAllowanceLowCampaign(){
        for(var i=1; i<=6; i++){
            var allowanceLowCampaign = jQuery("#allowanceLowCampaign" + i).text();
            if(allowanceLowCampaign === 'true'){
                return true;
            }
        }
        return false;
    }
    
    /**
     * Return Allowance Part Availability records of the given Type.
     * @param {Array} allowancePartAvailabilities
     * @param {String} recordType
     * @returns {Array} rules - an array of Allowance Part Availability records
     */
    function getAllowancePartAvailabilityRecords(allowancePartAvailabilities, recordType) {
        var rules = [];
        
        for (var i = 0; i < allowancePartAvailabilities.length; i++) {
            var av = allowancePartAvailabilities[i];
            if (av.Type__c == recordType) {
                rules.push(av);
            }
        }
        CS.Log.warn('Part Availability Records of Type ' + recordType + ': ' + rules.length);
        return rules;
    }
    
    /**
     * Return Allowance Part Type Availability records of the given Type.
     * @param {Array} allowanceCategoryAvailabilities
     * @param {String} recordType
     * @returns {Array} rules - an array of Allowance Category Availability records
     */
    function getAllowanceCategoryAvailabilityRecords(allowanceCategoryAvailabilities, recordType) {
        var rules = [];
        
        for (var i = 0; i < allowanceCategoryAvailabilities.length; i++) {
            var av = allowanceCategoryAvailabilities[i];
            if (av.Type__c == recordType) {
                rules.push(av);
            }
        }
        CS.Log.warn('Category Availability Records of Type ' + recordType + ': ' + rules.length);
        return rules;
    }
    
    /**
     * Get all rules (PartRules & CategoryRules) of Type 'Required' that have a Quantity != null
     * Check occurrence of Parts that match the rules and calculate the number of groups.
     * @param {Array} allowancePartAvailabilities
     * @param {Array} allowanceCategoryAvailabilities
     * @returns {Number} groups - number of groups
     */
    function calculateGroups(allowancePartAvailabilities, allowanceCategoryAvailabilities) {
        var groups = 1; //default to 1, because Allowance Applicability check ensured there is at least 1 group of all Required items
        
        requiredPartRecords = getAllowancePartAvailabilityRecords(allowancePartAvailabilities, allowanceRequiredType);
        requiredCategoryRecords = getAllowanceCategoryAvailabilityRecords(allowanceCategoryAvailabilities, allowanceRequiredType);
        
        //check how many times each of the required parts AND part Types exists in the partsModel
        for (var i = 0; i < requiredPartRecords.length; i++) {
            var rp = requiredPartRecords[i];
            
            //see how many groups of each required item exist in the partsModel by dividing occurence/quantity
            //the final number of groups is the lowest number
            //Eg: for every 2 radiators and 3 valves, get 2 valves free
            // Say actuals are: 4 radiators & 9 valves => this should give us (2 and 3 =>) 2 groups, so get 2 * 2 valves free (max)
            if (rp.Quantity__c !== null) {
                var partOccurence = getPartOccurenceInPartsModel(rp.Part__c); //return an int
                var partGroups = Math.floor(partOccurence / rp.Quantity__c);
                
                if (partGroups < groups) {
                    groups = partGroups;
                }
            }
        }
    
        //for (rpt : requiredCategoryRecords) {
        for (var j = 0; j < requiredCategoryRecords.length; j++) {
            var rpt = requiredCategoryRecords[j];
            //see how many groups of parts of each required type exist in the partsModel by dividing occurence/quantity
            //the final number of groups is the lowest number
            //Eg: for every 2 radiators and 3 valves, get 2 valves free
            // Say actuals are: 4 radiators & 9 valves => this should give us 2 groups, so get 2 * 2 valves free (max)
            if (rpt.Quantity__c !== null) {
                var partTypeOccurence = getDiscountCategoryOccurenceInPartsModel(rpt.CS_Discount_Category_Name__c); //return an int
                var partTypeGroups = Math.floor(partTypeOccurence / rpt.Quantity__c);
                
                if (partTypeGroups < groups) {
                    groups = partTypeGroups;
                }
            }
        }
        return groups;
    }
    
    /**
     * Loops through the partsModel and returns all Parts with the given Id.
     * Returns the CS_PartInformation nodes (we need Quantity info & totalPriceIncVAT )
     * @param {String} partId
     * @returns {Array} parts - array of parts with the given id
     */
    function getMatchingPartsById(partId) {
    
        var parts = [];
        
        for (var id in partsModelJS) {
            if (!partsModelJS.hasOwnProperty(id))
                continue;
            var entry = partsModelJS[id];
            
            //Check parentPart only if isPart and is not multi-lookup
            if (entry.isPart && !entry.isMultilookup) {
                if (entry.parentPart && entry.parentPart.part && entry.parentPart.part.Id == partId) {
                    parts.push(entry.parentPart);
                }
            }
            
            //Check all associatedParts in any case
            var associatedParts = entry.associatedParts;
            for (var i = 0; i < associatedParts.length; i++) {
                var assPart = associatedParts[i];
            
                if (assPart.part && assPart.part.Id == partId) {
                    parts.push(assPart);
                }
            }
        }
        
        CS.Log.warn('Matching Parts to ' + partId + ' found: ' + parts.length);
        
        return parts;
    }
    
    /**
     * Loops through the partsModel and return all Parts with the given Category.
     * Returns the CS_PartInformation nodes (we need Quantity info & totalPriceIncVAT )
     * @param {String} category
     * @returns {Array} parts - array of parts in a given category
     */
    function getMatchingPartsByDiscountCategory(category) {
        var parts = [];
        
        for (var id in partsModelJS) {
            if (!partsModelJS.hasOwnProperty(id))
                continue;
            var entry = partsModelJS[id];
            
            //Check parentPart only if isPart and is not multilookup
            if (entry.isPart && !entry.isMultilookup) {
                if (entry.parentPart && entry.parentPart.part.Discount_Categories__c) {
                    var categories = entry.parentPart.part.Discount_Categories__c.split(',');
                    if(contains(categories, category)){
                        parts.push(entry.parentPart);   
                    }
                }
            }
            
            var associatedParts = entry.associatedParts;
            for (var i = 0; i < associatedParts.length; i++) {
                var assPart = associatedParts[i];
            
                if (assPart.part && assPart.part.Discount_Categories__c) {
                    var assCategories = assPart.part.Discount_Categories__c.split(',');
                    if(contains(assCategories, category)){
                        parts.push(assPart);
                    }
                }
            }
        
        }
        
        CS.Log.warn('Matching Parts to category ' + category + ' found: ' + parts.length);
        
        return parts;
    }
    
    /**
     * Parses the partsModelJS and counts how many times the specific partId exists (considers quantity!)
     * @param {String} partId
     * @returns {Number} times
     */
    function getPartOccurenceInPartsModel(partId) {
        var times = 0;
        
        for (var id in partsModelJS) {
            if (!partsModelJS.hasOwnProperty(id))
                continue;
            var entry = partsModelJS[id];
            
            //Check parentPart only if isPart and is not multilookup
            if (entry.isPart && !entry.isMultilookup) {
                if (entry.parentPart && entry.parentPart.part.Id == partId) {
                    times += isNumber(entry.parentPart.quantity) ? parseInt(entry.parentPart.quantity, 10) : 0; //same as entry.attLastQuantity
                }
            }
            
            var associatedParts = entry.associatedParts;
            for (var i = 0; i < associatedParts.length; i++) {
                var assPart = associatedParts[i];
            
                if (assPart.part.Id == partId) {
                    times += isNumber(assPart.quantity * entry.attLastQuantity) ? parseInt(assPart.quantity * entry.attLastQuantity, 10) : 0;
                }
            }
        }
        
        CS.Log.warn('Part occurence of Part ' + partId + ' is: ' + times);
        
        return times;
    }
    
    /**
     * Parses the partsModelJS and counts how many times Parts of this Type exist (considers quantity!)
     * @param {String} category
     * @returns {Number} times
     */
    function getDiscountCategoryOccurenceInPartsModel(category) {
        var times = 0;
        
        for (var id in partsModelJS) {
            if (!partsModelJS.hasOwnProperty(id))
                continue;
            var entry = partsModelJS[id];
            
            //Check parentPart only if isPart and is not multilookup
            if (entry.isPart && !entry.isMultilookup) {
                if (entry.parentPart && entry.parentPart.part.Discount_Categories__c && entry.parentPart.part.Discount_Categories__c.indexOf(category) != -1) {
                    times += isNumber(entry.parentPart.quantity) ? parseInt(entry.parentPart.quantity, 10) : 0; //same as entry.attLastQuantity
                }
            }
            
            var associatedParts = entry.associatedParts;
            for (var i = 0; i < associatedParts.length; i++) {
                var assPart = associatedParts[i];
                
                if (assPart.part.Discount_Categories__c && assPart.part.Discount_Categories__c.indexOf(category) != -1) {
                    times += isNumber(assPart.quantity * entry.attLastQuantity) ? parseInt(assPart.quantity * entry.attLastQuantity, 10) : 0;
                }
            }
        }
        
        CS.Log.warn('Part occurence of category ' + category + ' is: ' + times);
        
        return times;
    }
    
    /**
     * Filters the allowances which can be shown in the next select list, calls filterAllowances to further filter the received allowances from server.
     * Uses multiple internal methods for server or SmartStore queries.
     * Uses the internal tickWorkers method for synchronization of multiple asynchronous server method calls.
     * Receives and passes a callback function to method filterAllowances
     * @param {Function} callback
     */
    window.calculateElligibleAllowancesForNextStep = function calculateElligibleAllowancesForNextStep() {
        
        CS.Log.warn('calculateElligibleAllowancesForNextStep called');

        var productType = CS.getAttributeValue('HEAT_Pricebook_0');
    
        //compare to Threshold - deduct all the previous actuals, get all other actuals and deduct from gross price
        var grossPrice = isNumber(CS.getAttributeValue('Gross_Price_incl_VAT_0')) ? parseFloat(CS.getAttributeValue('Gross_Price_incl_VAT_0')) : 0.00;
        for (var i = 1; i < 7; i++) {
            var id = jQuery('#discount' + i).val();
            var actualAmount = isNumber(jQuery('#discountAllowance' + i).val()) ? parseFloat(jQuery('#discountAllowance' + i).val()) : 0.00;
            
            if (id && id !== '' && id != 'none') {
                grossPrice = grossPrice - actualAmount;
            }
        }
        
        var customerAge = CS.getAttributeValue('Customer_Date_of_Birth_0');
        
        if (customerAge && customerAge !== '' && customerAge !== null) {
            customerAge = new Date(moment(customerAge, ["DD/MM/YYYY", "YYYY-MM-DD"]));
            customerAge = getAge(customerAge);
        } else {
            customerAge = -1;
        }
        
        var leadCreationDate;
        if(navigator.device) {
            leadCreationDate = moment(CS.getAttributeValue('Opp_Created_Date_0')).format('YYYY-MM-DD');
        } else {
            leadCreationDate = CS.getAttributeValue('CHI_Lead_Created_Date_0');
        }
        
        var voucherNo = CS.getAttributeValue('Voucher_Number_0');
        
        var employeeId = CS.getAttributeValue('Employee_ID_0'); //employee id and voucher Id need to be populated but not validated
        
        var workers = 0;
        var params = {
            productType:productType,
            grossPrice:grossPrice,
            customerAge:customerAge,
            leadCreationDate:leadCreationDate,
            voucherNo:voucherNo,
            employeeId:employeeId
        };
        
        return Q.all([getApplicableFilteredAllowances(params), getAssignedToEmployeeGroupsAndId()]).then(function(params){
            return filterAllowances(params);
        })
        .fail(function(e) { CS.Log.error(e);});
                    
     };
      
    window.getApplicableFilteredAllowances = function getApplicableFilteredAllowances(params) {
    
        CS.Log.warn('getApplicableFilteredAllowances called..');
    
        var productType = params.productType,
            grossPrice = params.grossPrice,
            customerAge = params.customerAge,
            leadCreationDate = params.leadCreationDate.toString().split('/').join('-'),
            voucherNo = params.voucherNo,
            employeeId = params.employeeId;

        CS.Log.warn('Product type: ' + productType + ', gross price: ' + grossPrice + ', customer age: ' + customerAge + ', lead creation date: ' + leadCreationDate + ', voucher No: ' + voucherNo + ', employee ID: ' + employeeId);
                    
        var myDevice = (navigator.device ? 'iPad' : 'Laptop');
    
        if (myDevice == 'iPad') {
    
            CS.Log.warn('***** Now calling SmartQuery for Allowances...');

            var allowance, partAvail, ctgAvail, allAvail, groupAvail, parentAll;
            var allowanceMap = {};

            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            var yyyy = today.getFullYear();

            if (dd < 10) {
                dd = '0' + dd;
            }
            if (mm < 10) {
                mm = '0' + mm;
            }
            today = yyyy + '-' + mm + '-' + dd;

            var dynamicFilters = '';
            if (!voucherNo || (voucherNo === '')) {
                dynamicFilters += ' AND {CS_Allowance__c:Requires_Voucher_ID_Formula__c} = 0';
            }

            if (!employeeId || (employeeId === '')) {
                dynamicFilters += ' AND {CS_Allowance__c:Requires_Employee_ID_Formula__c} = 0';
            }

            var returnedAllowanceIds = [];
            
            return CS.DB.smartQuery("SELECT {CS_Allowance__c:_soup} FROM {CS_Allowance__c} WHERE ({CS_Allowance__c:Minimum_Threshold__c} <= " + grossPrice + " OR {CS_Allowance__c:Minimum_Threshold__c} IS NULL)" +
                    " AND ({CS_Allowance__c:Start_Date__c} IS NULL OR {CS_Allowance__c:Start_Date__c} <= '" + today + "')" +
                    " AND ({CS_Allowance__c:End_Date__c} IS NULL OR {CS_Allowance__c:End_Date__c} >= '" + today + "')" +
                    " AND ({CS_Allowance__c:Expiry_Date__c} IS NULL OR {CS_Allowance__c:Expiry_Date__c} >= '" + leadCreationDate + "')" +
                    " AND ({CS_Allowance__c:Minimum_Age__c} IS NULL OR {CS_Allowance__c:Minimum_Age__c} <= " + customerAge + ")" +
                    " AND {CS_Allowance__c:Valid_Product_Types__c} LIKE '%" + productType + "%'" + dynamicFilters)
            .then(function (qr) {
                return qr.getAll().then(function (results) {
                    CS.Log.warn('***** Allowances retrieved in total: ' + results.length);

                    for (var i = 0; i < results.length; i++) {
                        var allc = results[i][0];
                        returnedAllowanceIds.push(allc.Id);

                        var allowanceWithAssoc = allc;

                        //Init the relationships in the same form as returned from SOQL
                        allowanceWithAssoc.CS_Allowance_Part_Availabilities__r = [];
                        allowanceWithAssoc.CS_Allowance_Category_Availabilities__r = [];
                        allowanceWithAssoc.CS_Allowance_Availabilities__r = [];
                        allowanceWithAssoc.CS_Allowance_Empl_Group_Availabilities__r = [];
                        allowanceWithAssoc.CS_Parent_Allowances__r = [];

                        allowanceMap[allowanceWithAssoc.Id] = allowanceWithAssoc;
                    }
                    
                    var allowanceParams = {
                        returnedAllowanceIds: returnedAllowanceIds,
                        allowanceMap: allowanceMap
                    };

                    return Q.resolve(allowanceParams);
                });
            })
            .then(function (allowanceParams) {
                //CS.Log.warn(allowanceParams);
                return getAllowancePartAvailabilitiesSmSt(allowanceParams);
            })
            .then(function(allowanceParams) {
                //CS.Log.warn(allowanceParams);
                return getAllowanceCategoryAvailabilitiesSmSt(allowanceParams); //was    returnedAllowanceIds, allowanceMap 
            })
            .then(function(allowanceParams) {
                //CS.Log.warn(allowanceParams);
                return getAllowanceAvailabilitiesSmSt(allowanceParams); //was    returnedAllowanceIds, allowanceMap 
            })
            .then(function(allowanceParams) {
                //CS.Log.warn(allowanceParams);
                return getAllowanceEmployeeGroupsSmSt(allowanceParams); //was    returnedAllowanceIds, allowanceMap 
            })
            .then(function(allowanceParams) {
                //CS.Log.warn(allowanceParams);
                return getAllowanceCompatibilitiesSmSt(allowanceParams); //was    returnedAllowanceIds, allowanceMap    
            })
            .fail(function(e) { CS.Log.error(e);});
    
    
        } else if (myDevice == 'Laptop') {
            
            var deferred = Q.defer();
            
            CS.Log.warn('**** Now calling UISupport.getApplicableAllowances..');
            
            UISupport.getApplicableAllowances(
                productType,
                grossPrice,
                customerAge,
                leadCreationDate,
                voucherNo,
                employeeId,
                function (result, event) {
                if (event.status) {
                    CS.Log.warn('***** Allowances retrieved in total: ' + result.length);
                    var filteredAllowances = result;
                        
                    deferred.resolve(filteredAllowances); // NEW PROMISES
                }
                else {
                    deferred.reject('Event failed');
                }
            });
            
            return deferred.promise; 
        }
    };
    
    window.getAllowancePartAvailabilitiesSmSt = function getAllowancePartAvailabilitiesSmSt(allowanceParams) {
        CS.Log.warn('***** Now calling SmartQuery for CS_Allowance_Part_Availability__c...');
        
        return CS.DB.smartQuery("SELECT {CS_Allowance_Part_Availability__c:_soup} FROM {CS_Allowance_Part_Availability__c} WHERE {CS_Allowance_Part_Availability__c:CS_Allowance__c} IN " + convertToListForSmartQuery(allowanceParams.returnedAllowanceIds))
            .then(function (qr) {
                return qr.getAll().then(function (results) {
                    CS.Log.warn('***** Part Availabilities retrieved in total: ' + results.length);
                    for (var i = 0; i < results.length; i++) {
                        var pav = results[i][0];
                        var allowanceWithAssoc = allowanceParams.allowanceMap[pav.CS_Allowance__c];
                
                        //Init the relationships in the same form as returned from SOQL
                        allowanceWithAssoc.CS_Allowance_Part_Availabilities__r.push(pav);
                        allowanceParams.allowanceMap[pav.CS_Allowance__c] = allowanceWithAssoc;
                    }
    
                    return Q.resolve(allowanceParams); // NEW PROMISES
                });
            })
            .fail(function(e) { CS.Log.error(e);});
    };
    
    window.getAllowanceCategoryAvailabilitiesSmSt = function getAllowanceCategoryAvailabilitiesSmSt(allowanceParams) { //was returnedAllowanceIds, allowanceMap
        CS.Log.warn('***** Now calling SmartQuery for CS_Allowance_Category_Availability__c...');
        
        return CS.DB.smartQuery("SELECT {CS_Allowance_Category_Availability__c:_soup} FROM {CS_Allowance_Category_Availability__c} WHERE {CS_Allowance_Category_Availability__c:CS_Allowance__c} IN " + convertToListForSmartQuery(allowanceParams.returnedAllowanceIds))
            .then(function (qr) {
                return qr.getAll().then(function (results) {
                    CS.Log.warn('***** Category Availabilities retrieved in total: ' + results.length);
                    for (var i = 0; i < results.length; i++) {
                        var cav = results[i][0];
                        var allowanceWithAssoc = allowanceParams.allowanceMap[cav.CS_Allowance__c];

                        //Init the relationships in the same form as returned from SOQL
                        allowanceWithAssoc.CS_Allowance_Category_Availabilities__r.push(cav);
                        allowanceParams.allowanceMap[cav.CS_Allowance__c] = allowanceWithAssoc;
                    }
                    return Q.resolve(allowanceParams);
                });
            })
            .fail(function(e) { CS.Log.error(e);});
    }
    
    window.getAllowanceAvailabilitiesSmSt = function getAllowanceAvailabilitiesSmSt(allowanceParams) { //was returnedAllowanceIds, allowanceMap
        CS.Log.warn('***** Now calling SmartQuery for CS_Allowance_Availability__c...');
        
        return CS.DB.smartQuery("SELECT {CS_Allowance_Availability__c:_soup} FROM {CS_Allowance_Availability__c} WHERE {CS_Allowance_Availability__c:CS_Allowance__c} IN " + convertToListForSmartQuery(allowanceParams.returnedAllowanceIds))
        .then(function (qr) {
            return qr.getAll().then(function (results) {
                CS.Log.warn('***** Allowance Availabilities retrieved in total: ' + results.length);
                for (var i = 0; i < results.length; i++) {
                    var avail = results[i][0];
                    var allowanceWithAssoc = allowanceParams.allowanceMap[avail.CS_Allowance__c];

                    //Init the relationships in the same form as returned from SOQL
                    allowanceWithAssoc.CS_Allowance_Availabilities__r.push(avail);
                    allowanceParams.allowanceMap[avail.CS_Allowance__c] = allowanceWithAssoc;
                }

                return Q.resolve(allowanceParams);
            });
        })
        .fail(function(e) { CS.Log.error(e);});
    };
    
    window.getAllowanceEmployeeGroupsSmSt = function getAllowanceEmployeeGroupsSmSt(allowanceParams) { //was returnedAllowanceIds, allowanceMap
        CS.Log.warn('***** Now calling SmartQuery for CS_Allowance_Employee_Group__c...');
        
        return CS.DB.smartQuery("SELECT {CS_Allowance_Employee_Group__c:_soup} FROM {CS_Allowance_Employee_Group__c} WHERE {CS_Allowance_Employee_Group__c:CS_Allowance__c} IN " + convertToListForSmartQuery(allowanceParams.returnedAllowanceIds))
        .then(function (qr) {
            return qr.getAll().then(function (results) {
                CS.Log.warn('***** Employee Groups retrieved in total: ' + results.length);
                for (var i = 0; i < results.length; i++) {
                    var emgrp = results[i][0];
                    var allowanceWithAssoc = allowanceParams.allowanceMap[emgrp.CS_Allowance__c];

                    //Init the relationships in the same form as returned from SOQL
                    allowanceWithAssoc.CS_Allowance_Empl_Group_Availabilities__r.push(emgrp);
                    allowanceParams.allowanceMap[emgrp.CS_Allowance__c] = allowanceWithAssoc;
                }

                return Q.resolve(allowanceParams);
            });
        })
        .fail(function(e) { CS.Log.error(e);});
    };
    
    window.getAllowanceCompatibilitiesSmSt = function getAllowanceCompatibilitiesSmSt(allowanceParams) { //was returnedAllowanceIds, allowanceMap
        CS.Log.warn('***** Now calling SmartQuery for CS_Allowance_Compatibility__c...');
        
        return CS.DB.smartQuery("SELECT {CS_Allowance_Compatibility__c:_soup} FROM {CS_Allowance_Compatibility__c} WHERE {CS_Allowance_Compatibility__c:Child_Allowance__c} IN " + convertToListForSmartQuery(allowanceParams.returnedAllowanceIds))
        .then(function (qr) {
            return qr.getAll().then(function (results) {

                CS.Log.warn('***** Allowance Parents retrieved in total: ' + results.length);
                for (var i = 0; i < results.length; i++) {
                    var comp = results[i][0];
                    var allowanceWithAssoc = allowanceParams.allowanceMap[comp.Child_Allowance__c];

                    //Init the relationships in the same form as returned from SOQL
                    allowanceWithAssoc.CS_Parent_Allowances__r.push(comp);
                    allowanceParams.allowanceMap[comp.Child_Allowance__c] = allowanceWithAssoc;
                }

                var filteredAllowances = [];
                for (var key in allowanceParams.allowanceMap) {
                    filteredAllowances.push(allowanceParams.allowanceMap[key]);
                }
                
                return Q.resolve(filteredAllowances);
            });
        })
        .fail(function(e) { CS.Log.error(e);});
    };
            
    window.getAssignedToEmployeeGroupsAndId = function getAssignedToEmployeeGroupsAndId() {
        CS.Log.warn('*** getAssignedToEmployeeGroupsAndId called...');
        
        var myDevice = (navigator.device ? 'iPad' : 'Laptop');
        if (myDevice == 'iPad') {
            var userId = generate18CharId(CS.SFDC.userId);
            CS.Log.warn('Assigned to employee ID: ' + userId);
        
            CS.Log.warn('***** Now calling SmartQuery for employees...');
            
            return CS.DB.smartQuery("SELECT {Employee__c:_soup} from {Employee__c} WHERE {Employee__c:Salesforce_User__c} = '" + userId + "'").then(function(qr) { 
                return qr.getAll().then(function(results) {
                    var assignedToEmployee = results[0][0];
                    CS.Log.warn("Assigned to employee: ");
                    CS.Log.warn(assignedToEmployee);
                    
                    if(assignedToEmployee && assignedToEmployee.Id && assignedToEmployee.Id.length == 18 ) {
                        CS.setAttributeValue('Assigned_To_Employee_0', assignedToEmployee.Id);
                    }
                    
                    return Q.resolve(assignedToEmployee);
                });
            }).then(function(assignedToEmployee) {
                CS.Log.warn('***** Now calling SmartQuery for employee groups...');

                return CS.DB.smartQuery("SELECT {Employee_Group__c:_soup} FROM {Employee_Group__c} WHERE {Employee_Group__c:Employee__c} = '" + assignedToEmployee.Id + "'").then(function (qr) {
                    return qr.getAll().then(function (results) {
                        var assignedEmployeeGroups = [];
                        for (var i = 0; i < results.length; i++) {
                            var emgrp = results[i][0];
                            assignedEmployeeGroups.push(emgrp.Group_Name__c);
                        }
                            
                        CS.Log.warn('Got assignedToEmployee groups: ' + assignedEmployeeGroups.length);
                            
                        return Q.resolve(assignedEmployeeGroups);
                    });
                });
            }).fail(function(e) { 
                CS.Log.error(e);
                return Q.resolve([]);
            });

        } else if (myDevice == 'Laptop') {
            
            var deferred = Q.defer();

            UISupport.getAssignedToEmployeeGroupsAndId(
                function (result, event) {
                    if (event.status) {
                        var assignedToEmployee = result['employeeId'][0];
                        var assignedEmployeeGroups = result['employeeGroups'];
                        
                        CS.Log.warn('Got assignedToEmployee groups: ' + assignedEmployeeGroups.length);
                        
                        if(assignedToEmployee && assignedToEmployee.length == 18 ) {
                            CS.setAttributeValue('Assigned_To_Employee_0', assignedToEmployee);
                        }
                        deferred.resolve(assignedEmployeeGroups);
                    } else {
                        deferred.resolve([]);
                    }
                });

            return deferred.promise; 
        }
    };
    
    /**
     * Filters allowances based on business logic, most of the code was put here to reduce the complexity of the server queries.
     * Executes the callback method after filtering the allowances.
     * @param {Array} filteredAllowances
     * @param {Array} assignedEmployeeGroups
     * @param {Function} callback
     */
    function filterAllowances(params) {
        
        CS.Log.warn('Started additional filtering allowances...');
        
        CS.Log.warn('params[0]: ' );
        CS.Log.warn(params[0]);
        CS.Log.warn('params[1]: ');
        CS.Log.warn(params[1]);
                   
        var filteredAllowances = params[0];
        var assignedEmployeeGroups = params[1];
        
        CS.Log.warn('filteredAllowances: ' + filteredAllowances.length);
       
        //Child of Parent
        //get Ids from all of the previously selected allowances
        var previouslySelectedAllowancesIds = [];
        for (var s = 1; s < 7; s++) {
            var selectListValue = jQuery("#discount" + s).val();
            if (selectListValue && selectListValue !== '' && selectListValue != 'none') {
                previouslySelectedAllowancesIds.push(selectListValue);
            }
        }
        CS.Log.warn('Filtering by Child/Parent');
        //get all the filtered allowances
        var filteredAllowancesByChildParent = [];
        //if there are previously selected allowances we need to filter the new ones, otherwise it is the first selected allowance
        if (previouslySelectedAllowancesIds && previouslySelectedAllowancesIds.length > 0) {
            for (var i = 0; i < filteredAllowances.length; i++) {
                var allowance = filteredAllowances[i];
    
                //if an allowance has parent allowances we need to check whether the allowance has all of the required parent allowances
                if (allowance.CS_Parent_Allowances__r) {
                    var parentAllowancesCounter = previouslySelectedAllowancesIds.length;
    
                    for (var j = 0; j < allowance.CS_Parent_Allowances__r.length; j++) {
                        var parentAllowance = allowance.CS_Parent_Allowances__r[j].Parent_Allowance__c;
    
                        if (contains(previouslySelectedAllowancesIds, parentAllowance)) {
                            parentAllowancesCounter--;
                        }
                    }
    
                    if (parentAllowancesCounter <= 0) {
                        filteredAllowancesByChildParent.push(allowance);
                    }
                }
            }
        } else {
            filteredAllowancesByChildParent = filteredAllowances;
        }
        
        // Media code availability
        // filter the allowances by media code applicability
        var mediaCode = CS.getAttributeValue('Media_Code_0').toString();
        CS.Log.warn('Filtering by media code');
        var filteredAllowancesByMediaCode = [];
        for (var i = 0; i < filteredAllowancesByChildParent.length; i++) {
            var allowance = filteredAllowancesByChildParent[i];
            
            // allowance with no media codes will always be available
            if (!allowance.Media_Codes__c || allowance.Media_Codes__c.length === 0){
                filteredAllowancesByMediaCode.push(allowance);
            } else {
                // if the allowance has media codes, we need to verify that the media codes contain the entered mediaCode
                var mediaCodesArray = allowance.Media_Codes__c.split(',');
                if(contains(mediaCodesArray, mediaCode)){
                    filteredAllowancesByMediaCode.push(allowance);
                }
            }
        }
    
        // District availability
        // filter the allowances by district applicability
        var district = CS.getAttributeValue('District_Code_0');
    
        var filteredAllowancesByDistrict = [];
        for (var i = 0; i < filteredAllowancesByMediaCode.length; i++) {
            var allowance = filteredAllowancesByMediaCode[i];
            // "Allowance with no related districts will be available on a national level."
            if (!allowance.CS_Allowance_Availabilities__r || allowance.CS_Allowance_Availabilities__r.length === 0) {
                filteredAllowancesByDistrict.push(allowance);
            } else {
                // "If an allowance has any relationships to districts, it is only valid if it is related with the district from the quote installation address context."
                for (var j = 0; j < allowance.CS_Allowance_Availabilities__r.length; j++) {
                    var av = allowance.CS_Allowance_Availabilities__r[j];
                    if (av.District_Code__c == district) {
                        filteredAllowancesByDistrict.push(allowance);
                        break;
                    }
                }
            }
        }
        
        CS.Log.warn('filteredAllowancesByDistrict: ' + filteredAllowancesByDistrict.length);
    
        // assignedToEmployee groups
        //further filter the allowances by assignedToEmployee groups
        var filteredAllowancesByEmployee = [];
        for (var k = 0; k < filteredAllowancesByDistrict.length; k++) {
            var allowance = filteredAllowancesByDistrict[k];
            // "Allowance with no related employee groups will be available for all users."
            if (!allowance.CS_Allowance_Empl_Group_Availabilities__r || allowance.CS_Allowance_Empl_Group_Availabilities__r.length === 0) {
                filteredAllowancesByEmployee.push(allowance);
            } else {
                // "If an allowance has any relationships to employee groups, it is only valid for users assigned to respective employee group."
                for (var m = 0; m < allowance.CS_Allowance_Empl_Group_Availabilities__r.length; m++) {
                var aegrp = allowance.CS_Allowance_Empl_Group_Availabilities__r[m];
                    if (contains(assignedEmployeeGroups, aegrp.Group_Name__c)) {
                        filteredAllowancesByEmployee.push(allowance);
                        break;
                    }
                }
            }
        }

        CS.Log.warn('filteredAllowancesByEmployee: ' + filteredAllowancesByEmployee.length);
    
        //Filter based on Required & Calculation Rules
        var filteredAllowancesByPartAvailability = [];
    
        //Part Quantities need to be grouped by Part (we may have 2 Radiators in a 'Required' Type and another one in a 'Calculation' Type)
        // so we should be checking existence of 3 Radiators.
        // just group items that are Calculation or Required!!!
        //The same applies to Category Quantities
        
        for (var i = 0; i < filteredAllowancesByEmployee.length; i++) {
            var allowance = filteredAllowancesByEmployee[i];
            var flagCanBeAdded = true;
    
            if (allowance.CS_Allowance_Part_Availabilities__r) {
                var requiredPartQuantities = {};
                for (var j = 0; j < allowance.CS_Allowance_Part_Availabilities__r.length; j++) {
                    var pvl = allowance.CS_Allowance_Part_Availabilities__r[j];
    
                    // "If allowance has relationship of type ?Not Allowed? to any part, it will be valid only if none of the parts ?Not Allowed? for allowance are present on the solution."
                    if (pvl.Type__c == allowanceNotAllowedType) {
                        // If there are no parts in the parts model then include the allowance
                        if (getPartOccurenceInPartsModel(pvl.CS_Part__c) !== 0) {
                            flagCanBeAdded = false;
                        }
                    } else if (pvl.Type__c == allowanceRequiredType || pvl.Type__c == allowanceCalculationType) {
                        // "If allowance has relationship of type ?Required? to any part, it will be valid only if all the parts ?Required? for allowance have been included on the solution."
                        
                        //Group Parts and aggregate Quantity
                        //create a map with the key of partId and value is the number of parts
                        // blank quantity is set to 0 when constructed map - then if 0 is encountered change to 1
                        //put in a custom array: eg array[partId] = quantity (and increase this quantity accordingly in next iterations if applicable)
                        
                        var partId = pvl.CS_Part__c;
                        
                        if (isNaN(requiredPartQuantities[partId])) {
                            requiredPartQuantities[partId] = pvl.Quantity__c ? pvl.Quantity__c : 0;
                        } else {
                            requiredPartQuantities[discountName] += pvl.Quantity__c ? pvl.Quantity__c : 0;
                        }
                    }
                }
    
                var requiredPartQuantityCounter = 0;
                for (var partId in requiredPartQuantities) {
                    if (!requiredPartQuantities.hasOwnProperty(partId))
                        continue;
                    requiredPartQuantityCounter++;
                    var requiredPartQuantity = requiredPartQuantities[partId];
                    if (requiredPartQuantity === 0)
                        requiredPartQuantity = 1;
    
                    if (getPartOccurenceInPartsModel(partId) >= requiredPartQuantity) {
                        requiredPartQuantityCounter--;
                    }
                }
                if (requiredPartQuantityCounter !== 0) {
                    flagCanBeAdded = false;
                }
    
            } 
            if(flagCanBeAdded){
                filteredAllowancesByPartAvailability.push(allowance);
            }
        }
        
        CS.Log.warn('filteredAllowancesByPartAvailability: ' + filteredAllowancesByPartAvailability.length);
    
        var filteredAllowancesByCategoryAvailability = [];
    
        for (var i = 0; i < filteredAllowancesByPartAvailability.length; i++) {
            var allowance = filteredAllowancesByPartAvailability[i];
            var flagCanBeAdded2 = true;
    
            if (allowance.CS_Allowance_Category_Availabilities__r) {
                var requiredPartQuantities = {};
    
                for (var k = 0; k < allowance.CS_Allowance_Category_Availabilities__r.length; k++) {
                    var pvl = allowance.CS_Allowance_Category_Availabilities__r[k];
    
                    if (pvl.Type__c == allowanceNotAllowedType) {
                        // If there are no parts in the parts model then include the allowance
                        if (getDiscountCategoryOccurenceInPartsModel(pvl.CS_Discount_Category_Name__c) !== 0) {
                            flagCanBeAdded2 = false;
                        }
                    } else if (pvl.Type__c == allowanceRequiredType || pvl.Type__c == allowanceCalculationType) {
                        //Group Categories and aggregate Quantity
                        //put in a custom array
                        //Then (outside for loop), loop through this custom array and check the existence of grouped Quantities
                        //Note: where Quantity is null, then create an entry in the custom array for the Category if one doesn't exist already. If one does exist, do NOT increase the Quantity
    
                        var discountName = pvl.CS_Discount_Category_Name__c;
    
                        if (isNaN(requiredPartQuantities[discountName])) {
                            requiredPartQuantities[discountName] = pvl.Quantity__c ? pvl.Quantity__c : 0;
                        } else {
                            requiredPartQuantities[discountName] += pvl.Quantity__c ? pvl.Quantity__c : 0;
                        }
                    }
                }
    
                var requiredPartQuantityCounter = 0;
                for (var discountName in requiredPartQuantities) {
                    if (!requiredPartQuantities.hasOwnProperty(discountName))
                        continue;
                    requiredPartQuantityCounter++;
                    var requiredPartQuantity = requiredPartQuantities[discountName];
                    if (requiredPartQuantity === 0)
                        requiredPartQuantity = 1;
    
                    if (getDiscountCategoryOccurenceInPartsModel(discountName) >= requiredPartQuantity) {
                        requiredPartQuantityCounter--;
                    }
                }
                if (requiredPartQuantityCounter !== 0) {
                    flagCanBeAdded2 = false;
                }
            } 
            
            if(flagCanBeAdded2) {
                filteredAllowancesByCategoryAvailability.push(allowance);
            }
        }
        
        CS.Log.warn('Final Allowances for next select list: ' + filteredAllowancesByCategoryAvailability.length);
        //CS.Log.warn(filteredAllowancesByCategoryAvailability);
            
        CS.Log.warn('about to resolve filteredAllowancesByCategoryAvailability');
        return Q.resolve(filteredAllowancesByCategoryAvailability);
    }
})
