//# sourceURL=CS_partsModel.js
/*
version from test prior to condensate bundle change
--- CS_partsModel  ----
--- Change History ----
17/03/15 IC amended function checkBundleReplacementParts() to remove check for districts
checkbox is now only available to valid disticts in product definition
18/03/15 reverted function checkBundleReplacementParts() but extended district list
26/03/15  amended function checkBundleReplacementParts() to check by district project
13/04/2015 IC added P1993 to list of building packs to be removed list
17/07/2015 IC addded Checking auto by pass in core bundle;  

*/
//IMPORTANT GLOBAL VARIABLES
var partsModelJS = {};


var latestPartsModelJS = {};

var partCodesQtyIdsMap = new Map();

//PCBH3 AUTO
var existsPCBH3 = false;
var existAddedHive = false;
var additionalPackEntryRef = 'AutoAdded_AP_',
    additionalPackPartCodesList; 


var ipadDevice = 'iPad';
var laptopDevice = 'Laptop';
var device = (navigator.device ? ipadDevice : laptopDevice);

var CS_PartAssocRelationship_Requires = 'Requires';
var CS_PartAssocRelationship_Optional = 'Optional';
var CS_PricebookType_Standard = 'Standard';
var CS_PricebookType_LowCost = 'Low Cost';
var CS_PricebookType_SmallCommercial = 'SmallCommercial';

//Other global
var attsChangedList; //of type RemotingParamWrapper List
var regionCode;
var districtCode;
var pricebookType;
var boilerGroup;
var geographicUpliftFactor;
var calculationInProgress = 0;

// powercleanse and powerflush related
var powerCleansePartCode = 'P1989';
var powerFlushCategory = 'Powerflush';

// scottish parts - Boundary changes - 2016
var scottishCarbonMonoxideCode = 'P2871';
var scottishTradingName = 'Scottish Gas';

//Automatically added Electrical Packs need to have a key in the partsModelJS. This is also used during validation of partsModel, so entries with a key like this
//would be skipped for checking, to avoid returning message that a related produce has been removed.
var electricalPackEntryRef = 'AutoAdded_EP_';

//Automatically added Select List Packs need to have a key in the partsModelJS. This is also used during validation of partsModel, so entries with a key like this
//would be skipped for checking, to avoid returning message that a related produce has been removed.
var selectListPackEntryRef = 'AutoAdded_SLP_',
    selectListPackPartCodesList; // used while iterating through the CS.Service.config to get all of the part codes from select lists
var userInputPackEntryRef = 'AutoAdded_UIP_',
    userInputPackPartCodeListData;

var multiSelectWithQuantityList;

/**
 * A wrapper of all important properties of the Attribute that has changed since the last time the partsModelJS was built.
 * @constructor
 */
var CS_RemotingParamWrapper = function(atbRef, atbVal, atbPrice, attQuantity, attDesc, attIsLineItem, attIsPart, attIsBundle, attIsMultiLookup, attIsPlaceholder, attIsPriceOverriden, instLoc, instNotes) {
    this.attRef = atbRef;
    this.attValue = atbVal;
    this.attPrice = atbPrice;
    this.quantity = attQuantity;
    this.lineItemDescription = attDesc;
    this.isLineItem = attIsLineItem;
    this.isPart = attIsPart;
    this.isBundle = attIsBundle;
    this.isMultilookup = attIsMultiLookup;
    this.isPlaceholder = attIsPlaceholder;
    this.isPriceOverriden = attIsPriceOverriden;
    this.installationLocation = instLoc;
    this.installationNotes = instNotes;
};


require(['bower_components/q/q'], function (Q) {
    
    window.onFirstLoadOfProduct = function onFirstLoadOfProduct(){
        if(navigator.device){
            partsModelJS = {};
            
            CS.Service.config['Quote_Status_0'].attr.cscfga__Value__c='--None--';
            CS.Service.config['Quote_Status_0'].attr.cscfga__Display_Value__c='--None--';
            CS.setAttributeValue('Quote_Status_0', '--None--');

            CS.Service.config['Reason_0'].attr.cscfga__Value__c='--None--';
            CS.Service.config['Reason_0'].attr.cscfga__Display_Value__c='--None--';
            CS.setAttributeValue('Reason_0', '--None--');
            
            //path
            CS.setAttributeValue('Installation_Form_Path_0', '');
            CS.setAttributeValue('Pdf_Path_0', '');
            
            //signed
            CS.setAttributeValue('Pdf_Signed_0', 0);
            CS.setAttributeValue('Installation_Form_Signed_0', 0);
            
            
            // delete deposit payment data and make fields read/write 
            // this is to allow new payment data to be entered on
            // a cloned quote which had those fields set as read-only
            CS.setAttributeValue("Worldpay_Plugin_Sent_Data_0", "false");

        }
        
    }
    
     if(navigator.device){
        CS.Log.setLevel('WARN');
    }
    
    //dynamic lookup value
    window.getDynamicLookupValue = function getDynamicLookupValue(lookupQueryName, fieldName) {
        var d = Q.defer();
        fieldName = ('' + fieldName).toLowerCase();
        var definitionId = CS.Service.getCurrentProductId();
        var dynamicLookupQueryProxy = CS.getDynamicLookupValue('Lookup(' + lookupQueryName + ')', fieldName, definitionId);
        dynamicLookupQueryProxy.applyValue = function(data) {
            if (data) {
                CS.Log.debug('Resolving field name', data[fieldName]);
                d.resolve(data[fieldName]);
            } else {
                d.resolve();
            }
        };
        dynamicLookupQueryProxy.setError = function(e) {
            CS.Log.error('Error in dynamic lookup query:', e);
            d.reject(e);
        };
        return d.promise;
    }

    //new Scottish
    //dynamic lookup value
    window.checkIfScottishPostcode = function checkIfScottishPostcode() {
        var lookupQueryName = 'AppointmentQuery';
        var fieldName = 'Trading_Name__c'; 

        var d = Q.defer();
        fieldName = ('' + fieldName).toLowerCase();
        var definitionId = CS.Service.getCurrentProductId();
        var dynamicLookupQueryProxy = CS.getDynamicLookupValue('Lookup(' + lookupQueryName + ')', fieldName, definitionId);
        dynamicLookupQueryProxy.applyValue = function(data) {
            if (data) {
                CS.Log.debug('Resolving field name', data[fieldName]);
                d.resolve(data[fieldName]);
            } else {
                d.resolve();
            }
        };
        dynamicLookupQueryProxy.setError = function(e) {
            CS.Log.error('Error in dynamic lookup query:', e);
            d.reject(e);
        };
        return d.promise;
    }

    /**
     * Builds the partsModelJS
     * Called by the button to build the partsModelJS
     */
    window.buildParts = function buildParts() {

        
        //AUTO PCBH3
        existsPCBH3 = false;
        existAddedHive = false;

        clearCustomerSignature();
        
        toggleBtnCss('btn-buildparts');
        
        if (calculationInProgress == 1) {
            return;
        }
        calculationInProgress = 1;

        // AF added 4/8/14
        jQuery('#btn-quotepdf, #btn-quotepdf-preprinted').attr('disabled', 'disabled');
        
        CS.Log.warn('***** Starting progress indicator');
        CS.indicator.start();
        
        CS.setAttributeValue('Validate_0', 'Yes'); //This will trigger validation of the configuration, and messages will be displayed accordingly on the screen
    
        // Check if any price-affecting changes have occured. If so, rebuild parts Model and proceed to calculatingPrices. If not, rebuild parts Model only (we don't want to clear Allowances if there is no price change).
        var pricesAffected = validateAttributesChanged(true);
        CS.Log.warn('pricesAffected is: ' + pricesAffected);
        
        
        //EP added 24/06: Warning that allowances will need to be reconfigured, only if partsModel is not being built for the 1st time and there are price affecting changes 
        if (partsModelJS && Object.keys(partsModelJS).length > 0 && pricesAffected === true) {
            var cont = alert('Prices have changed. Please re-configure and apply allowances.');
            getDynamicLookupValue('OpportunityQuery','CreatedDate').then(function(result){
                
                 if(CS.isCsaContext){
                    var newDateVal = result.substring(0, result.indexOf('.'));
                    var dateVal = new Date(newDateVal);
                    console.log('Parsed val:', dateVal);
                    CS.setAttributeValue('CHI_Lead_Created_Date_0', dateVal);
                    CS.setAttributeValue('Opp_Created_Date_0', dateVal);

                }
                else{
                    CS.setAttributeValue('Opp_Created_Date_0', result);
                }
                
                //CS.setAttributeValue('Opp_Created_Date_0', result);
                clearAllAllowanceFields();
                createHSAAllowancesTable();
            });
            /* if (!cont) {
                return;
            } */
        }
        
        //Now clear partsModelJS as we are re-building it from scratch
        partsModelJS = {};
    
        attsChangedList = []; //RemotingParamWrapper List
        regionCode = CS.getAttributeValue('Geographic_Region_0');
        districtCode = CS.getAttributeValue('District_Code_0');
        pricebookType = CS.getAttributeValue('Pricebook_Type_0');
        boilerGroup = CS.getAttributeValue('Boiler_0:Boiler_Group_0') ? CS.getAttributeValue('Boiler_0:Boiler_Group_0') : '';
        geographicUpliftFactor = CS.getAttributeValue('Geographic_Uplift_Factor_0');
        
        selectListPackPartCodesList = []; // a list containing all of the parts codes retreived from select lists to be queried and automatically added
        var selectListCodesExist = false;
        
        userInputPackPartCodeListData = {};
        var userInputCodesExist = false;
        multiSelectWithQuantityList = {};
        
        // --------- Iterate through Configurator attributes and collect all where Is_Part__c is TRUE or Is_Bundle__c is TRUE --------------
        CS.Log.warn('Config properties found: ' + Object.keys(CS.Service.config).length);
    
        for (var attrRef in CS.Service.config) {

            //CS.Log.warn('=====BUILD PARTS ATTR REF  '+attrRef);
            var node = CS.Service.config[attrRef];
            if (!node.attr) continue;
    
            var isPart = node.definition.Is_Part__c ? node.definition.Is_Part__c : false;
            var isBundle = node.definition.Is_Bundle__c ? node.definition.Is_Bundle__c : false;
            var hasSelectListPartCode = ((node.definition.Has_Part_Code__c ? node.definition.Has_Part_Code__c : false) && (node.definition.cscfga__Type__c == 'Select List'));
            
            
            if(hasSelectListPartCode) {

                //CS.Log.warn('=====HAS SELECT LIST PART CODE  '+attrRef);
                /*
                try{
                    CS.Log.warn('=====HAS VALUE  '+node.attr.cscfga__Value__c);
                }
                catch(err){
                     CS.Log.warn('=====HAS NO VALUE ');
                }
                */
                // only add valid values and not 'No', 'Yes', 'N/A', 'N / A', '-- None --', '--None--', 'NA'
                if(node.attr.cscfga__Value__c && !_.contains(['No', 'Yes', 'N/A', 'N / A', '-- None --', '--None--', 'NA'], node.attr.cscfga__Value__c)) {
                    selectListPackPartCodesList.push(node.attr.cscfga__Value__c);
                    //CS.Log.warn('=====PUSHED INTO '+attrRef);
                    selectListCodesExist = true; 
                }
                continue;
            }

            // packs defined with attribute of type 'User Input' and value type 'Integer' are checked here
            // original attribute references will be ignore when buildding parts model - auto generated references with agregated quantity will be used insted

            var hasPartCode = node.definition.Has_Part_Code__c;
            //var isUserInput = node.definition.cscfga__Type__c == 'User Input' || node.definition.cscfga__Type__c == 'Numeric Keypad';
            
            if ( isPart && hasPartCode)
            {
                if(node.attr.cscfga__Value__c) {
                    
                    if (node.attr.cscfga__Value__c == 0 /*&& node.reference == "PSLT48_0"*/) { 
                        continue; 
                    } 
                    else {
                    
                        userInputPackPartCodeListData[node.reference] = {
                            'pack code' : node.attr.Name,
                            'quantity' : node.attr.cscfga__Value__c
                        };
                        if (node.attr.Name in userInputPackPartCodeListData) {
                            userInputPackPartCodeListData[node.attr.Name] = Number(userInputPackPartCodeListData[node.attr.Name]) + Number(node.attr.cscfga__Value__c);
                        } else {
                            userInputPackPartCodeListData[node.attr.Name] = Number(node.attr.cscfga__Value__c);
                        }
                        userInputCodesExist = true;
                    }
                }
                continue;
            }
            
            
            
            if (node.definition.cscfga__Type__c == 'MultiSelect Lookup With Quantity') {
                
                CS.Log.warn('>>>>>>>>> BuildParts: MultiSelect Lookup With Quantity >>>>>>>>>>>> START:');
            /*    
                if(node.attr.cscfga__Value__c) {

                    var partItems = node.attr.cscfga__Value__c.split("|");
                    var idItem, qtyItem, nameItem;

                    var availableRecords = CS.getMultiLookupRecords("Boiler_0:Flue_0:Flue_Parts_0").records;
                    
                    var idsArray = [];
                    var valsArray = []; 
                    for (item in availableRecords) {
                        idsArray.push(availableRecords[item].Part__c);
                        valsArray.push(availableRecords[item]);
                    }
                    availableRecords =  _.object(idsArray, valsArray);

                    for (i = 0; i < partItems.length; i++) {

                        idItem = partItems[i].split(",")[0];
                        qtyItem = partItems[i].split(",")[1];
                        nameItem = availableRecords[idItem]["Part_Code__c"];

                        //!!!!!!!!!!!!
                        // this is not enough as the quantity is expected as additional input something like:
                        // userInputPackPartCodeListData[node.attr.Name] = Number(node.attr.cscfga__Value__c);
                        // otherwise, an error will occure at calculateTotalSkillHours()
                        //!!!!!!!!!!!!
                        userInputPackPartCodeListData[nameItem] = {
                            'pack code' : nameItem,
                            'quantity' : Number(qtyItem)
                        };
                       
                        userInputCodesExist = true;
                    }
                }
            */

                // to store the value and check later if it has changed
                multiSelectWithQuantityList[node.reference] = node.attr.cscfga__Value__c;

                CS.Log.warn('>>>>>>>>> BuildParts: MultiSelect Lookup With Quantity >>>>>>>>>>>> END:');
            }
            else if (!isPart && !isBundle) continue;
    
            var isMultilookup = (node.definition.cscfga__Type__c == 'MultiSelect List' && node.definition.cscfga__Enable_Multiple_Selection__c == 'true');
            var newQuantity   = calcQuantityForAttribute(node); //if isRelatedProduct, check if attr with Name relatedProductName_Quantity exists, if so get value. Else: 1
    
            var nodeReference = node.reference;
            var newValue      = node.attr.cscfga__Value__c;
    
            var isPlaceholder    = node.definition.Is_Placeholder__c ? node.definition.Is_Placeholder__c : false;
            var isLineItem       = node.attr.cscfga__Is_Line_Item__c ? node.attr.cscfga__Is_Line_Item__c : false;
            var lineItemDescription = node.attr.cscfga__Line_Item_Description__c ? node.attr.cscfga__Line_Item_Description__c : '';
            var isPriceOverriden = node.definition.Is_Price_Overriden__c;
            var price            = isNumber(node.attr.cscfga__Price__c) ? node.attr.cscfga__Price__c : 0;
    
            var installationLocation = getInstallationLocation(node);
            var installationNotes    = getInstallationNotes(node);
    
            // fetch the new data for the changed Attribute - create a CS_RemotingParamWrapper
            if (newValue) {
                var remotingparam = new CS_RemotingParamWrapper(nodeReference, newValue, price, newQuantity,
                    lineItemDescription, isLineItem, isPart, isBundle, isMultilookup, isPlaceholder, isPriceOverriden, 
                    installationLocation, installationNotes);
                attsChangedList.push(remotingparam);
                CS.Log.warn('New attribute found to be added: ' + nodeReference + ' - ' + newValue);
            }
        }
    
        CS.Log.warn('attsChangedList: ' + attsChangedList.length);
    
        if ( (attsChangedList && attsChangedList.length > 0) || selectListCodesExist || userInputCodesExist ) {
            getPartModelInformation(pricesAffected).then(function(){
                CS.Log.warn('***** Stopping progress indicator');
                CS.indicator.stop();
                // AF added 4/8/14
                jQuery('#btn-quotepdf, #btn-quotepdf-preprinted').removeAttr('disabled');
                
                // MK added 17/6/15
                calculationInProgress = 0;
            });
        } else {
            CS.Log.warn(partsModelJS);
            changeActualPlaceholder();
            createPricingScreens().then(function(){
                CS.Log.warn('***** Stopping progress indicator');
                CS.indicator.stop(); 
                // AF added 4/8/14  
                jQuery('#btn-quotepdf, #btn-quotepdf-preprinted').removeAttr('disabled');
                
                // MK added 17/6/15
                calculationInProgress = 0;
            });
        }
    };
    
    window.displayEmptyDOBAlert = function displayEmptyDOBAlert(){
        if(CS.isCsaContext){
          if((CS.getAttributeValue('Customer_Date_of_Birth_0')===null) || (CS.getAttributeValue('Customer_Date_of_Birth_0')==='')){
              if(navigator.device){
                navigator.notification.alert('Please enter the customer date of birth and recalculate prices before configurating the allowances.', null,'Warning', 'Ok');
              }
              else{
                  alert('Please enter the customer date of birth and recalculate prices before configurating the allowances.');
              }
          }
        }
        else{
            CS.Log.warn('Keeping same alert on existing version');
        }
        
    };
    
    /**
     * Clears all Allowance related Attribute Fields, re-calculates Prices and applicable Allowances.
     */
    window.createPricingScreens = function createPricingScreens() {
        displayEmptyDOBAlert();
        //radiator price fix
        changeActualPlaceholder();
        
        CS.Log.warn('createPricingScreens called...');
        
        clearAllAllowanceFields(); //sync
    
        calculatePricingScreenTotals(); //sync
        createPricingAndTotalsTables(); //sync
        createSkillsTable(); //sync
    
        createAllowancesButtons();  //sync
        
        // ATTENTION!!! createHSAAllowancesTable was called before createAllowancesButtons, but because it is the only async function
        //try to have it in the end so that it can return the promise resolved after everything else is complete
        
        return createHSAAllowancesTable();  //getApplicableAllowances for 1st selectList - async
    };
    
    //radiator price fix
     window.changeActualPlaceholder = function changeActualPlaceholder(){
         
         for(var id in partsModelJS){
            if(id.indexOf('Placeholder_0')!=-1){
                if((partsModelJS[id].parentPart.part.Radiator_Category__c == 'M') || (partsModelJS[id].parentPart.part.Radiator_Category__c == 'L') || (partsModelJS[id].parentPart.part.Radiator_Category__c == 'XL') || (partsModelJS[id].parentPart.part.Radiator_Category__c == 'S')){
                    
                    var t1 = id.indexOf(':');
                    var t2 = id.indexOf('_');
                    var indexRad = id.substring(t2+1, t1);
                    console.log(partsModelJS[id].parentPart.part.Radiator_Category__c);
                    changePrice(indexRad);
                }
            }
        }
         
     }
    //radiator price fix
    window.changePrice = function changePrice(indexRad){
        var placeholderKey = 'Radiator_'+indexRad+':Placeholder_0';
        var actualRadKey = 'Radiator_'+indexRad+':Actual_Radiator_2_0';
        if(partsModelJS[placeholderKey]){
            var agPrice = partsModelJS[placeholderKey].aggregatedPriceInclVAT;
            var agCost  = partsModelJS[placeholderKey].aggregatedCost;
            var agNetPrice  = partsModelJS[placeholderKey].aggregatedNetPrice;

            var partTotalPriceInclVat = partsModelJS[placeholderKey].parentPart.totalPriceIncVAT;

            var pricePart = partsModelJS[placeholderKey].parentPart.price;
            var priceListPricePart = partsModelJS[placeholderKey].parentPart.listPrice;
            var priceVatInclPart = partsModelJS[placeholderKey].parentPart.priceVatIncl;
            var priceGeoUpliftAmount = partsModelJS[placeholderKey].parentPart.geographicUpliftAmount;

            if(partsModelJS[actualRadKey]){
                partsModelJS[actualRadKey].aggregatedPriceInclVAT = agPrice;
                partsModelJS[actualRadKey].aggregatedCost = agCost;
                partsModelJS[actualRadKey].aggregatedNetPrice = agNetPrice;
                partsModelJS[actualRadKey].parentPart.price = pricePart;
                partsModelJS[actualRadKey].parentPart.listPrice = priceListPricePart;
                partsModelJS[actualRadKey].parentPart.geographicUpliftAmount = priceGeoUpliftAmount;

                partsModelJS[actualRadKey].parentPart.totalPriceIncVAT = partTotalPriceInclVat;

                partsModelJS[actualRadKey].parentPart.priceVatIncl = priceVatInclPart;
                CS.Log.warn('+++++Changed part - new parent part price =='+partsModelJS[actualRadKey].parentPart.price);

                //Change 'Placeholder Price'
                var placeholderPriceRadKey = 'Radiator_'+indexRad+':Placeholder_Price_0';
                var placeholderRadKey = 'Radiator_'+indexRad+':Placeholder_Price_0';
                CS.setAttributeValue(placeholderPriceRadKey, pricePart);
                CS.Service.config[placeholderRadKey].attr.cscfga__Price__c = pricePart;
                CS.Service.config[placeholderPriceRadKey].attr.cscfga__Price__c = pricePart;
            }
                
        }
    }
    
    
    
    /**
     * Added 20 June: Ensure that if a price affecting change has taken place when HSA clicks on 'Calculate Prices', customer's signature will be cleared.
     * This will force HSA to acquire new signature before setting the Quote to Finalised Accepted, thus ensuring Allowances etc reflect what was agreed.
     */
    window.clearCustomerSignature = function clearCustomerSignature() {
        
        CS.Log.warn('Clearing Customer Signature: pdfSigned and pdfPath...');
        
        CS.setAttributeValue('Pdf_Signed_0', 0);
        CS.setAttributeValue('Pdf_Path_0', '');

        try{
            var financeExist = CS.Service.config['Finance_Illustration_Path_0'];

            if(financeExist){
            CS.setAttributeValue('Finance_Illustration_Path_0', ''); 
            }
        }
        catch(err){CS.Log.warn('Attributes do not exist');}
        try{

            var installNotesExist = CS.Service.config['Installation_Form_Signed_0'];
            var installPathExist = CS.Service.config['Installation_Form_Path_0'];
            if(installNotesExist){
                CS.setAttributeValue('Installation_Form_Signed_0', 'No');
                
                if(CS.isCsaContext){
                    CS.setAttributeValue('Installation_Form_Signed_0', 0);
                }
            }
            if(installPathExist){
                CS.setAttributeValue('Installation_Form_Path_0', ''); 
            }
            
        }
        catch(err){CS.Log.warn('Attributes do not exist');}
        
    };
    
    
    /**
     * Loads the Pricing Screens by resetting the Display value of these attributes to the Stored Value
     */
    function loadPricingScreens() {
        CS.setAttribute('HSA_Part_Summary_0', CS.getAttributeValue('HSA_Part_Summary_0'));
        CS.setAttribute('Customer_Part_Summary_0', CS.getAttributeValue('Customer_Part_Summary_0'));
        CS.setAttribute('HSA_Totals_0', CS.getAttributeValue('HSA_Totals_0'));
        CS.setAttribute('Customer_Totals_0', CS.getAttributeValue('Customer_Totals_0'));
        CS.setAttribute('HSA_Allowances_0', CS.getAttributeValue('HSA_Allowances_0'));
        CS.setAttribute('Customer_Allowance_Buttons_0', CS.getAttributeValue('Customer_Allowance_Buttons_0'));
        CS.setAttribute('Skill_Summary_0', CS.getAttributeValue('Skill_Summary_0'));
    };
    
    /**
     * Loads the partsModelJS from the Attachment when an existing Product Configuration is launched
     * @param {String} configId
     */
    window.loadPartsModelFromAttachment = function loadPartsModelFromAttachment(configId) {
    
        CS.Log.warn('***** configId is: ' + configId);
    
        var device = (navigator.device ? 'iPad' : 'Laptop');
    
        if (configId) {
    
            if (device == 'iPad') {
                CS.Log.warn('***** loadPartsModelFromAttachment for iPad called ...');
    
                return CS.DB.smartQuery("SELECT {Attachment:_soup} FROM {Attachment} WHERE {Attachment:RelatedSoup} = 'Configuration' AND {Attachment:name} = 'partsModel.txt' AND {Attachment:RelatedEntryId} = '" + configId + "'").then(function(qr) {
                    return qr.getAll().then(function(result) {
                        var json = '';
                        if (result && result.length > 0) {
                            json = JSON.parse(result[0][0].Data);
                        }
    
                        partsModelJS = json;
                        CS.Log.warn('Loaded partsModelJS from SmartStore ...');
                        CS.Log.warn(partsModelJS);
                        
                        //radiator price fix
                        changeActualPlaceholder();
                                
                        loadPricingScreens();
                        calculatePricingScreenTotals(); //need to init global variables that hold pricing totals
                        loadTotalAllowanceValue();
                                
                        return Q.resolve();
    
                    });
                })
                .fail(function(e) { CS.Log.error(e);});
            } else if (device == 'Laptop') {
                UISupport.getPartsModel(
                    configId,
                    function(result, event) {
                        if (event.status) {
                            setTimeout(function() {
                                partsModelJS = result;
                                CS.Log.warn('Loaded partsModelJS for online...');
                                CS.Log.warn(partsModelJS);
                                
                                //radiator price fix
                                changeActualPlaceholder();
                                
                                loadPricingScreens();
                                calculatePricingScreenTotals(); //need to init global variables that hold pricing totals
                                loadTotalAllowanceValue();
                            }, 1000);
                        }
                    }
                );
            }
        }
    };
    
    /**
     * Saves the partsModelJS.
     * @param {String} configId
     * @param {Function} callback
     */
    window.savePartsModel = function savePartsModel(configId, callback) {
    
        CS.Log.warn("savePartsModel called");
        CS.Log.warn("configId is: " + configId);
    
        var device = (navigator.device ? 'iPad' : 'Laptop');
    
        if (device == 'iPad') {
            CS.Log.warn('***** savePartsModel for iPad called ...');
            CS.Log.warn('***** configId is:' + configId);
    
            return CS.DB.smartQuery("SELECT {Attachment:_soup} FROM {Attachment} WHERE {Attachment:RelatedSoup} = 'Configuration' AND {Attachment:name} = 'partsModel.txt' AND {Attachment:RelatedEntryId} = " + configId).then(function(qr) {
                return qr.getAll().then(function(results) {
                    CS.Log.warn('**** Retrieved configuration: ' + results.length);
                    CS.Log.warn(results);
    
                    CS.Log.warn('partsModelJS contains:');
                    CS.Log.warn(partsModelJS);
                    CS.Log.warn('**** Assigning jsonPartsModel...');
                    
                    var jsonPartsModel = JSON.stringify(partsModelJS);
                    
                    var pm;
                    if (results.length === 0) {
                        pm = {
                            RelatedSoup: 'Configuration',
                            RelatedEntryId: configId,
                            Name: 'partsModel.txt',
                            Data: jsonPartsModel
                        };
                        CS.Log.warn('***** About to insert new partsModel attachment... ');
                    } else {
                        if(typeof results[0][0] == 'string') {
                            pm = JSON.parse(results[0][0]);    
                        } else {
                            pm = results[0][0];
                        }  
                        
                        pm['Data'] = jsonPartsModel;
                        CS.Log.warn('***** About to update partsModel attachment... ');
                    }
    
                    return CS.DB.upsert('Attachment', pm);
                });
            })
            .fail(function(e) { CS.Log.error(e);});
    
        } else if (device == 'Laptop') {
            CS.Log.warn('***** Now calling RemoteAction savePartsModel...');
    
            removeSfAttributesNodes();  //required
    
            UISupport.savePartsModel(
                configId,
                partsModelJS,
                function(result, event) {
                    if (event.status) {
                        CS.Log.warn('***** PartsModel saved successfully');
    
                        if (callback) {
                            callback(); //this will be the redirect for online
                        }
                    } else {
                        CS.Log.warn('***** Error saving Parts Model', event);
                        callback(event);
                    }
                },
                {timeout: 120000}
            );
        }
    };
    
    /**
     * When the partsModelJS is sent to the server for saving, deserialization of the json failes because of the
     * attribute nodes that SF generates for Sobjects included in the JSON structure (CS_Part__c & CS_Bundle__c).
     * These attributes are then removed.
     */
    function removeSfAttributesNodes() {
        
        for (var key in partsModelJS) {
            if (!partsModelJS.hasOwnProperty(key)) continue;
        
            var entry = partsModelJS[key],
                isPart = entry.isPart ? entry.isPart : false,
                isBundle = entry.isBundle ? entry.isBundle : false;
            
            if (isPart && entry.parentPart && entry.parentPart.part) {
                delete entry.parentPart.part.attributes;
            } else if (isBundle && entry.parentBundle && entry.parentBundle) {
                delete entry.parentBundle.attributes;
            }
            
            // iterate through all associated parts
            for (var i = 0; i < entry.associatedParts.length; i++) {
                var associatedPart = entry.associatedParts[i];
            
                if (associatedPart.part) {
                    delete associatedPart.part.attributes;
                }
            }
        }
    }
    
    
    /**
     * Returns the Installation Location (if applicable) of an Attribute (stored in an Attribute Field in Configurator if applicable).
     * @param {Object} node
     * @returns {String} the Installation Location.
     */
    function getInstallationLocation(node) {
        if (node.attributeFields) {
            if (node.attributeFields['Installation_Location']) {
                return (node.attributeFields['Installation_Location'].cscfga__Value__c ? node.attributeFields['Installation_Location'].cscfga__Value__c : '');
            }
        }
        return '';
    }
    
    /**
     * Returns the Installation Notes (if applicable) of an Attribute (stored in an Attribute Field in Configurator if applicable).
     * @param {Object} node
     * @returns {String} the Installation Notes.
     */
    function getInstallationNotes(node) {
        if (node.attributeFields) {
            if (node.attributeFields['Installation_Notes']) {
                return (node.attributeFields['Installation_Notes'].cscfga__Value__c ? node.attributeFields['Installation_Notes'].cscfga__Value__c : '');
            }
        }
        return '';
    }
    
    /**
     * Returns the Radiator Category (if applicable) of an Attribute (stored in an Attribute Field in Configurator if applicable).
     * @param {Object} node
     * @returns {String} the Radiator Category.
     */
    function getRadiatorCategory(node) {
        if (node.attributeFields) {
            if (node.attributeFields['Radiator_Category']) {
                return node.attributeFields['Radiator_Category'].cscfga__Value__c;
            }
        }
        return '';
    }
    
    /**
     * Returns the Quantity of an Attribute.
     * @param {Object} node
     * @returns {Decimal} the Quantity.
     */
    function calcQuantityForAttribute(node) {
        var attQuantity = 1;
    
        // Check if there is a Quantity attribute with the same name, otherwise return 1
        var productType = node.definition.cscfga__Type__c;
    
        // Boiler_0 -> Boiler_Quantity_0
        var suffix = node.reference.substr(node.reference.length - 1);
        var quantityAttRef = node.reference.substring(0, node.reference.length - 1) + 'Quantity_' + suffix;
    
        // Now check if an att with this reference exists
        if (CS.Service.config[quantityAttRef]) {
            attQuantity = parseFloat(CS.getAttributeValue(quantityAttRef)) ? parseFloat(CS.getAttributeValue(quantityAttRef)) : 1;
        }
        return attQuantity;
    }
    


    window.validateSelectListHasPartCodeAttributeChange = function validateSelectListHasPartCodeAttributeChange(){

          var count = getCurrentSelectListPartCodes();
          if(count==0){
            latestPartsModelJS={};
          }
          //if((count>0)&&partsModelJS && (Object.keys(partsModelJS).length>2)){
            //if(!_.isEmpty(partsModelJS)){
            if((count.length >0) && latestPartsModelJS && (Object.keys(latestPartsModelJS).length>0)){
            var currentSelectListValues = getCurrentSelectListPartCodes();
            return getPacksByCode(currentSelectListValues).then(function(params) {
                return haveSelectListPartsChanged(params)});
            }
        
    }
    

    function getPartIdsFromPartsModel(){
        var selectHasPartCodeFromPartsModel =[];
        var selIndex=0;
        var pRef=selectListPackEntryRef+selIndex;

        while(pRef in partsModelJS){
            var partsModelNode = partsModelJS[pRef];
            selectHasPartCodeFromPartsModel.push(partsModelNode.attLastValue);
            if(pRef in partsModelJS){
                selIndex++; 
                pRef= selectListPackEntryRef+selIndex;
            } else break;
        }

        return selectHasPartCodeFromPartsModel;
    }

    function haveSelectListPartsChanged (packIdList){
        
        var packIdsListCheck = [];

        //console.log(packIdList);

        for (i = 0; i < packIdList.length; i++) { 
            packIdsListCheck.push(packIdList[i].Id);
        }  
        var partsModelIds = getPartIdsFromPartsModel();
        var match = selectListsHasPartCodeMatch(packIdsListCheck, partsModelIds);


        if(!match){
            jQuery("button:contains('Finish')").hide(); 
            CS.markConfigurationInvalid("Please re-calculate prices");
        }

        return match;

    }

    function getCurrentSelectListPartCodes(){
        var selectHasPartCodeCodesListCheck = [];
        //get current select list has part code codes       
        for (var attrRef in CS.Service.config) {
            var node = CS.Service.config[attrRef];

             if (!node.attr) continue;

             if(node.definition.Has_Part_Code__c && (node.definition.cscfga__Type__c == 'Select List')){
                if(node.attr.cscfga__Value__c && !_.contains(['No', 'Yes', 'N/A', 'N / A', '-- None --', '--None--', 'NA'], node.attr.cscfga__Value__c)) {
                    selectHasPartCodeCodesListCheck.push(node.attr.cscfga__Value__c);
                }

             }
        }
        return selectHasPartCodeCodesListCheck;
    }

    function selectListsHasPartCodeMatch(sel1, sel2){
        var match = false;
        if(sel1.sort().join(',')=== sel2.sort().join(',')){
            match=true;
        }
        return match;
        
    }
    /**
     * Is called when user clicks on the Finish button, as well as when user clicks on 'Calculate Prices' button
     * On 'Finish', it checks whether any attribute has changed since the last time the partsModel was built, and if so it prevents the user from saving until they explicitly rebuild prices
     * On 'Calculate Prices', it only checks if any price-affecting changes have occured. If so, after rebuilding the partsModel the algorithm will recalulcate prices as well (and clear allowances)
     * @param {Boolean} checkForPriceAffectingOnly
     * @returns {Boolean} changed
     */
    window.validateAttributesChanged = function validateAttributesChanged(checkForPriceAffectingOnly) {
        var hasChanged = false;
    
        // --------- Iterate through Configurator attributes and check all where Is_Part__c is TRUE or Is_Bundle__c is TRUE --------------
        CS.Log.warn('***** validateAttributesChanged has been called');
        
        //Check if any attributes that affect Allowance Applicability have changed. If so, Allowances need to be cleared and re-calculated (added 13/06)
        if (CS.getAttributeValue('HEAT_Pricebook_Shadow_0') != CS.getAttributeValue('HEAT_Pricebook_0') ||
            CS.getAttributeValue('Voucher_Number_Shadow_0') != CS.getAttributeValue('Voucher_Number_0') ||
            CS.getAttributeValue('Customer_Date_of_Birth_Shadow_0') != CS.getAttributeValue('Customer_Date_of_Birth_0') ||
            CS.getAttributeValue('Employee_ID_Shadow_0') != CS.getAttributeValue('Employee_ID_0')
        ) {
                CS.Log.warn('******* An attribute affecting allowance applicability has changed (productType/VoucherNo/EmployeeId/Age) ');
                hasChanged = true;
                return hasChanged;
        }
        
    
        //Check if any Related Products have been removed
        if (relatedProductsDeleted(checkForPriceAffectingOnly) === true) {
            hasChanged = true;
            return hasChanged;
        }
    
        for (var attrRef in CS.Service.config) {
            var node = CS.Service.config[attrRef];
    

            //CS.Log.warn('***** CHECKING NODE===='+attrRef);

            if (!node.attr) continue;

            
            if (!node.definition.Is_Part__c && !node.definition.Is_Bundle__c && !node.definition.Recalculate_If_Changed__c) continue;
            
            
    
            //if checking for price affecting changes only and the node is an Actual Radiator of any Radiator Category other than Towel Warmer & Designer, then skip check
            var skipCheckForAtt = false;
            if (checkForPriceAffectingOnly && checkForPriceAffectingOnly === true && node.definition.Is_Price_Overriden__c === true && node.definition.Is_Placeholder__c === false && entryIsPriceAffectingActualRadiator(node) === false) {
                CS.Log.warn('******* Node is not price affecting and will be skipped for checking: ' + node.reference);
                skipCheckForAtt = true;
            }
    
            var attQuantity = calcQuantityForAttribute(node);
            var installationLocation = getInstallationLocation(node);
            var installationNotes = getInstallationNotes(node);

            // check if an entry for the attRef exists in the partsModelJS
            if (partsModelJS && node.reference in partsModelJS) {

                //CS.Log.warn('***** CHECKING NODE REFERENCE===='+node.reference);
    
                //check if the existing attribute is an actual Radiator (Is_Price_Overriden)
                if (skipCheckForAtt === true) {
    
                    //do nothing, (any) change is NOT price affecting
                    CS.Log.warn('******* Existing attribute is an Actual Radiators (not Designer/Towel Warmer) and is not price affecting: ' + node.reference);
                } else {
    
                    // Is _lastValue the same as current (lookup) value? (Checks for change in value)
                    if (node.attr.cscfga__Value__c == partsModelJS[attrRef].attLastValue) {
    
                        // ----- Check for all params of interest that could have changed on the attribute (Quantity, IsLineItem, Price, LineItemDescription, InstallationLocation, Installation Notes)  -----
    
                        // Is _lastQuantity the same as current? This is price affecting, prices would need recalculation
                        if (attQuantity != partsModelJS[attrRef].attLastQuantity) {
                            CS.Log.warn('***** Quantity changed for attribute: ' + node.reference);
                            hasChanged = true;
                            return hasChanged;
                        }
    
                        //The following changes are not price affecting, so skip if checking for price affecting changes only
                        if (checkForPriceAffectingOnly && checkForPriceAffectingOnly === true) {
                            //skip
                        } else {
                            //Installation Location
                            if (installationLocation != partsModelJS[attrRef].installationLocation) {
                                //CS.Log.warn('***** Installation Location changed for attribute: ' + node.reference);
                                hasChanged = true;
                                return hasChanged;
                            }
    
                            //Installation Notes
                            if (installationNotes != partsModelJS[attrRef].installationNotes) {
                                //CS.Log.warn('***** Installation Notes changed for attribute: ' + node.reference);
                                hasChanged = true;
                                return hasChanged;
                            }
    
                            // IsLineItem property the same as current? Note that only Placeholder Radiators can have their IsLineItem property changed and
                            //this only happens if an Actual Radiator has been configured. This change is not price affecting
                            if (node.attr.cscfga__Is_Line_Item__c != partsModelJS[attrRef].isLineItem) {
                                //CS.Log.warn('****** IsLineItem changed for attribute: ' + node.reference);
                                hasChanged = true;
                                return hasChanged;
                            }
    
                            //Is LineItem Description the same as current?
                            if (node.attr.cscfga__Line_Item_Description__c && (node.attr.cscfga__Line_Item_Description__c != partsModelJS[attrRef].attLastLineItemDescription)) {
                                //CS.Log.warn('****** IsLineItemDescription changed for attribute: ' + node.reference);
                                hasChanged = true;
                                return hasChanged;
                            }
                        }
    
                        /*
                        //IsPriceOverriden and PriceChanged?
                        if (node.definition.Is_Price_Overriden__c && partsModelJS[attrRef].parentPart && node.attr.cscfga__Price__c != partsModelJS[attrRef].parentPart.price) {
                            CS.Log.warn('****** Price changed for attribute: ' + node.reference);
                            hasChanged = true;
                            return hasChanged;
                        }
                        */
                    } else if (node.definition.Is_Part__c && node.definition.Has_Part_Code__c) {

                        if (userInputPackPartCodeListData == undefined) { continue; }

                        var value      = node.attr.cscfga__Value__c;
                        var savedValue = userInputPackPartCodeListData[node.reference].quantity;

                        if (value != savedValue) {
                            hasChanged = true;
                            return hasChanged;
                        } else {
                            CS.Log.warn('******* User Input pack quantitiy value has changed for : ' + node.reference + ' - ' + node.attr.cscfga__Value__c);
                        }
                    } else {
                        // If value is changed. This is price affecting, prices would need recalculation.
                        CS.Log.warn('******* Value has changed for attribute: ' + node.reference + ' - ' + node.attr.cscfga__Value__c);
                        hasChanged = true;
                        return hasChanged;
                    }
                }
            }
            else if (partsModelJS && userInputPackPartCodeListData && node.reference in userInputPackPartCodeListData) {
                
                // jump over user input defined pack references as they are handled by duplicate auto-generated references
                CS.Log.warn('******* jumping over user input pack reference: ' + node.reference);
                
                // PRD ISSUE FIX: 2018.07.16
                // DESCRIPTION: To fix issue in Production, that everytime the quantity in P1316_0 and P1315_0 is decreased, the allowances are not cleared, because priceChange is not detected
                //
                if (node.definition.Has_Part_Code__c == true && node.definition.cscfga__Type__c == 'Numeric Keypad') {

                    var newValue = node.attr.cscfga__Value__c;
                    var oldValue = userInputPackPartCodeListData[node.reference].quantity;

                    if (newValue != oldValue) {
                        hasChanged = true;
                        CS.Log.warn('******* User Input pack ' + node.reference + 'quantitiy value has changed from : ' + oldValue + ' to ' + newValue);
                        return hasChanged;
                    }
                }
                //
                // END OF PRD ISSUE FIX: 2018.07.16

            } else if (partsModelJS && multiSelectWithQuantityList && node.reference in multiSelectWithQuantityList) {
                    CS.Log.warn('******* check multiselect lookup with quantity: ' + node.reference);

                    var newValue = node.attr.cscfga__Value__c;
                    var oldValue = multiSelectWithQuantityList[node.reference];

                    if (newValue != oldValue) {
                        hasChanged = true;
                        CS.Log.warn('******* MultiSelectLookup ' + node.reference + ' value has changed from : ' + oldValue + ' to ' + newValue);
                        return hasChanged;
                    }

            } else {
                // else if partsModelJS is null or attRef does not exist in partsModelJS (This is an addition)
                
                // Does the att have a (non blank) value?
                if (node.attr.cscfga__Value__c) {
                    CS.Log.warn('******* New attribute has been added: ' + node.reference + ' - ' + node.attr.cscfga__Value__c);
    
                    //check if the new attribute is an actual Radiator (Is_Price_Overriden && Not Is Placeholder)
                    if (skipCheckForAtt === true) {
                        //do nothing, change is NOT price affecting
                        CS.Log.warn('******* This has price overriden');
                    } else {
                        hasChanged = true;
                        return hasChanged; //return straight away
                    }
                }
            }
        }
   
        // saveInstallationNotes removed from here 2019-01-29 as for new Quotes the basket doesn't exist at this point
       
        return hasChanged;
    };

    window.saveInstallationNotes = function saveInstallationNotes(currentBasketId, rootConfigId) {

        if(navigator.device==undefined){
            if(CS.Service.config["Installation_Form_Path_0"] != undefined){
                // 2019-01-24 create quote no matter quote accepted or not (but store it on diff places)
                //if((hasChanged == false)){ // && (CS.getAttributeValue("Quote_Status_0")=='Quote Finalised - Accepted') && (CS.getAttributeValue("Reason_0") != '--None--')){
                    var salesRegion = CS.getAttributeValue('Geographic_Region_0');
                    var quoteAccepted = false;
                    if ((CS.getAttributeValue("Quote_Status_0")=='Quote Finalised - Accepted') && (CS.getAttributeValue("Reason_0") != '--None--')) {
                        quoteAccepted = true;
                    }

                    if (salesRegion === 'Scotland'){
                        installationTemplateOnlineSave('SG', quoteAccepted, currentBasketId, rootConfigId);
                        CS.Log.warn('**Saving SG');
                    }
                    else{
                        installationTemplateOnlineSave('BG', quoteAccepted, currentBasketId, rootConfigId);
                        CS.Log.warn('**Saving BG');
                    }
                }

            //}    
            
        }

    };
    
    /**
     * Checks if any (attribute of Type) related Products have been deleted since the partsModel was last built
     * @param {Boolean} checkForPriceAffectingOnly
     * @returns {Boolean} changed
     */
    function relatedProductsDeleted(checkForPriceAffectingOnly) {
        // Iterate through each entry in the partsModelJS. Check if attRef is still in the Configuration Model. 
    
        var changed = false;
    
        for (var key in partsModelJS) {
            if (!partsModelJS.hasOwnProperty(key)) continue;
    
            var attRef = partsModelJS[key].attRef;
            if (!(attRef in CS.Service.config)) {
                var entry = partsModelJS[key];

                //if autoadded electrical pack, skip no corresponding Related Product would exist in the Configuration
                if (entry.attRef && entry.attRef.indexOf(electricalPackEntryRef) === 0) {continue;}

                if (entry.attRef && entry.attRef.indexOf(selectListPackEntryRef) === 0) {continue;}

                if (entry.attRef && entry.attRef.indexOf(userInputPackEntryRef) === 0) {continue;}

                if (entry.attRef && entry.attRef.indexOf(additionalPackEntryRef) === 0) {continue;}

                if (checkForPriceAffectingOnly && checkForPriceAffectingOnly === true && entry.isPriceOverriden === true && entry.isPlaceholder === false && entryIsPriceAffectingActualRadiator(entry) === false) {
                    //if the attribute removed is an actual Radiator (not price affecting), do nothing
                    CS.Log.warn('******* Actual Radiator has been removed - not price affecting');
                    
                } else {
                    changed = true;
                    CS.Log.warn('******* Related Product has been removed: ' + attRef);
                    return changed;
                }
            }
        }
    
        return changed;
    }
    
    /**
     * Checks if an entry in the partsModelJS or in CS.Service.config represents an Actual Radiator that is Price affecting as it is being configured without a placeholder on the UI
     * At the moment these are radiators with Radiator Cateogry 'Designer' or 'Towel Warmer'
     * @param {Object} entry: an entry in the partsModelJS
     * @returns {Boolean}
     */
    function entryIsPriceAffectingActualRadiator(entry) {
        //If input param is an entry in partsModelJS
        if (entry.parentPart && entry.parentPart.part && (entry.parentPart.part.Radiator_Category__c == 'Designer' || entry.parentPart.part.Radiator_Category__c == 'Towel Warmer')) {
            CS.Log.warn('******* PartsModel entry is a Designer/Towel Warmer Radiator');
            return true;
        }
        //Else if input param is a Configurator Attribute node
        else if (entry.attr && entry.attributeFields) {
            var radiatorCategory = getRadiatorCategory(entry);
            
            if (radiatorCategory == 'Designer' || radiatorCategory == 'Towel Warmer') {
                CS.Log.warn('******* Configurator Attribute is a Designer/Towel Warmer Radiator');
                return true;
            }
        }
        return false;
    }
    
    //{ #region Powerflush and powercleanse (part suppression)
    
    /**
     * Tests whether an item is a PowerFlush part.
     * @param  {Object}  item An object retreived from partsModelJS.
     * @return {Boolean}      Returns whether an item is a PowerFlush part.
     */
    function isPowerFlush(item){
        if(item.Subcategory__c === powerFlushCategory) return true;
        else return false;
    }
    
    /**
     * Tests whether and item is a PowerCleanse part.
     * @param  {Object}  item An object retreived from partsModelJS.
     * @return {Boolean}      Returns whether an item is a PowerCleanse part.
     */
    function isPowerCleanse(item){
        if(item.Part_Code__c === powerCleansePartCode) return true; 
        else return false;
    }

    
    /**
     * Removes any PowerCleanse parts from partsModelJS.
     * Updates the partsModelJS and recalculates the prices.
     */
    function removePowerCleanseParts() {
    
        // iterate through parts model
        for (var id in partsModelJS) {
            if (!partsModelJS.hasOwnProperty(id))
                continue;
            var item = partsModelJS[id];
            
            if (item.isPart && !(item.isMultilookup)) {
    
                // if an item is a powercleanse remove it
                if (isPowerCleanse(item.parentPart.part)) {
                    var rootId = id.substring(0, id.indexOf(':'));
                    CS.Log.warn('Removing part: ' + rootId);
    
                    // remove the item (Related Product) from configurator. Power Cleanse Parts are available to be selected via Pack C (Stores)
                    CS.Service.removeRelatedProduct(rootId);
    
                    // remove the part (entire node) from partsModelJS
                    delete partsModelJS[id];
                    
                    continue;
                }
            }
    
            if (item && item.associatedParts) {
                
                
                //iterate through associated parts of Part AND Bundle entries
                var updateItemPricesFlag = false;
                
                //Iterate in reverse order and delete using splice. Delete leaves the item undefined and does NOT update the length property
                for (var i = item.associatedParts.length - 1 ; i >= 0; i--) {
                    var associatedPart = item.associatedParts[i];

                    // if an item is a powercleanse remove it
                    if (isPowerCleanse(associatedPart.part)) {
                        CS.Log.warn('Removing associated part ');
                        //delete partsModelJS[id].associatedParts[i];
                        partsModelJS[id].associatedParts.splice(i, 1);
                        updateItemPricesFlag = true;
                    }
                }
                // also update the price of the node
                if (updateItemPricesFlag) {
                    //updateItemPrices(item);
                    item.aggregatedNetPrice = item.calculateAggregatedNetPriceForEntry(); //prototype functions of CS_PartModelEntry
                    item.aggregatedPriceInclVAT = item.calculateAggregatedPriceInclVatForEntry();
                    item.aggregatedCost = item.calculateAggregatedM_Cost() + item.calculateAggregatedS_Cost();
                }
            
            }
        }
    }
    
    //2017
    //remove powerclense associated part 
    function removeAssociatedPowercleansePartFullSys() {
        // iterate through parts model
        if(CS.getAttributeValue('Job_Type_Required_0')=='Full System'){
            for (var id in partsModelJS) {
                if (!partsModelJS.hasOwnProperty(id))
                    continue;
                var item = partsModelJS[id];
                if (item && item.associatedParts) {
                    //iterate through associated parts of Part AND Bundle entries
                    var updateItemPricesFlag = false;
                    
                    //Iterate in reverse order and delete using splice. Delete leaves the item undefined and does NOT update the length property
                    for (var i = item.associatedParts.length - 1 ; i >= 0; i--) {
                        var associatedPart = item.associatedParts[i];
    
                        // if an item is a powercleanse remove it
                        if (isPowerCleanse(associatedPart.part)) {
                            CS.Log.warn('Removing associated part ');
                            //delete partsModelJS[id].associatedParts[i];
                            partsModelJS[id].associatedParts.splice(i, 1);
                            updateItemPricesFlag = true;
                        }
                    }
                    // also update the price of the node
                    if (updateItemPricesFlag) {
                        //updateItemPrices(item);
                        item.aggregatedNetPrice = item.calculateAggregatedNetPriceForEntry(); //prototype functions of CS_PartModelEntry
                        item.aggregatedPriceInclVAT = item.calculateAggregatedPriceInclVatForEntry();
                        item.aggregatedCost = item.calculateAggregatedM_Cost() + item.calculateAggregatedS_Cost();
                    }
                }
            }
        }
        
    }
    
    
    //2016-Boundary changes
    function isScottishCarbonMonoxidePart(item){
        if(item.Part_Code__c === scottishCarbonMonoxideCode) return true; 
        else return false;
    }
    
    function removeScottishPartsIfNotInScotland(inScottland) {
    
   
        if(inScottland != scottishTradingName){
             CS.Log.warn('Not Scotland - removing SCotish Carbon Monoxide - trading Name =='+inScottland);
            // iterate through parts model
            for (var id in partsModelJS) {
                if (!partsModelJS.hasOwnProperty(id))
                    continue;
                var item = partsModelJS[id];
                
                if (item.isPart && !(item.isMultilookup)) {
        
                    // if an item is a powercleanse remove it
                    if (isScottishCarbonMonoxidePart(item.parentPart.part)) {
                        var rootId = id.substring(0, id.indexOf(':'));
                        CS.Log.warn('Removing part: ' + rootId);
        
                        // remove the item (Related Product) from configurator. Power Cleanse Parts are available to be selected via Pack C (Stores)
                        CS.Service.removeRelatedProduct(rootId);
        
                        // remove the part (entire node) from partsModelJS
                        delete partsModelJS[id];
                        
                        continue;
                    }
                }
        
                if (item && item.associatedParts) {
                    //iterate through associated parts of Part AND Bundle entries
                    var updateItemPricesFlag = false;
                    
                    //Iterate in reverse order and delete using splice. Delete leaves the item undefined and does NOT update the length property
                    for (var i = item.associatedParts.length - 1 ; i >= 0; i--) {
                        var associatedPart = item.associatedParts[i];
    
                        // if an item is a powercleanse remove it
                        if (isScottishCarbonMonoxidePart(associatedPart.part)) {
                            CS.Log.warn('Removing associated part ');
                            //delete partsModelJS[id].associatedParts[i];
                            partsModelJS[id].associatedParts.splice(i, 1);
                            updateItemPricesFlag = true;
                        }
                    }
                    // also update the price of the node
                    if (updateItemPricesFlag) {
                        //updateItemPrices(item);
                        item.aggregatedNetPrice = item.calculateAggregatedNetPriceForEntry(); //prototype functions of CS_PartModelEntry
                        item.aggregatedPriceInclVAT = item.calculateAggregatedPriceInclVatForEntry();
                        item.aggregatedCost = item.calculateAggregatedM_Cost() + item.calculateAggregatedS_Cost();
                    }
                }
            }
        }
        else{
            CS.Log.warn('In Scotland - Scotish Carbon Monoxide part can stay - trading Name =='+inScottland);
        }
    }
    
    /**
     * Checks whether Powerflush and Powercleanse items exist in a solution.
     * If they do, removes any powercleanse parts from partsModelJS.
     */
    function checkforPowerflushAndPowercleanse(){

        var powerFlushExists = false;
        var powerCleanseExists = false;
    
        // iterate through all parts
        for (var id in partsModelJS) {
            if (!partsModelJS.hasOwnProperty(id))
                continue;
            if(powerFlushExists && powerCleanseExists) break;
    
            var item = partsModelJS[id];
            if (item.isPart && !(item.isMultilookup)) {
                // check whether powerflush and powercleanse parts exist in partsModelJS
                if(!powerFlushExists) powerFlushExists = isPowerFlush(item.parentPart.part);
                if(!powerCleanseExists) powerCleanseExists = isPowerCleanse(item.parentPart.part);
            }
            
            //Check associatedParts for both Parts & Bundles
            if (item.associatedParts) {
                for (var i = 0; i < item.associatedParts.length; i++) {
                    var associatedPart = item.associatedParts[i];
    
                    if(!powerFlushExists) powerFlushExists = isPowerFlush(associatedPart.part);
                    if(!powerCleanseExists) powerCleanseExists = isPowerCleanse(associatedPart.part);               
                }
            }
        }
        
        CS.Log.warn('*** powerFlushExists: ' + powerFlushExists);
        CS.Log.warn('*** powerCleanseExists: ' + powerCleanseExists);
    
        // remove powercleanse if they exist
        // and update prices and related attributes
        if(powerFlushExists && powerCleanseExists){
            CS.Log.warn('Power Flush and Power Cleanse both found in the solution. Initiating suppression of Power Cleanse...');
            removePowerCleanseParts();
        } else {
            CS.Log.warn('No suppression required.');
        }
        
        return Q.resolve(); //NEW PROMISES, everything above is synchronous
    }
    
    //} #endregion Powerflush and powercleanse (part suppression)
    
    /**
     * Retrieves the parts by their part codes.
     * @param {Array} An array of part codes.
     * @return {Array} An array of retrieved parts.
     */ 
    window.getPacksByCode = function getPacksByCode(packCodesToRetrieve) {
        
        CS.Log.warn('getPacksByCode called..');
        
        var packsList = [];
        var device = (navigator.device) ? 'iPad' : 'Laptop';
        if (device === 'iPad') {
            return CS.DB.smartQuery("SELECT {CS_Part__c:_soup} FROM {CS_Part__c} WHERE {CS_Part__c:Part_Code__c} IN " + convertToListForSmartQuery(packCodesToRetrieve)).then(function(qr) {
                return qr.getAll().then(function(results) {
                    if (results && results.length > 0) {
                        CS.Log.warn('Packs retrieved in total: ' + results.length);
                        for (var i = 0; i < results.length; i++) {
                            packsList.push(results[i][0]);
                        }
                    } else {
                        CS.Log.warn('No Packs retrieved ..');
                    }
                    return Q.resolve(packsList);
                });
            });
    
        } else if (device === 'Laptop') {
            
            var deferred = Q.defer();
                    
            UISupport.getPartsByPartCode(
                packCodesToRetrieve,
                function(result, event) {
                    if (event.status) {
                        CS.Log.warn('Packs retrieved in total: ' + result.length);
                        packsList = result;
                                            
                        deferred.resolve(packsList);
                    }
                    else {
                         deferred.reject('Event failed');
                    }
            });
            
            return deferred.promise;
        } 
    };
    
    //{ #region Electrical Pack automatic addition
    
    /**
     * Checks the added parts in the solution and adds electrical packs if all of the conditions
     * are satisfied.
     */
    window.checkElectricalPacks = function checkElectricalPacks() {
        
        CS.Log.warn('***** checkElectricalPacks called..');
    
        var packCodesToRetrieve = ['P2958', 'P2970', 'P2959', 'P1422'];
    
        return getPacksByCode(packCodesToRetrieve)
        .then(function(params) {
            return addApplicableElectricalPacks(params); //ok
        });
        
        /**
         * Compares the solution items and attributes against the desired business logic.
         * Adds the electrical packs to the solution if they satisfy the business logic.
         * @param {Array} electricalPacksList An array of retreived packs, which may be added to the solution.
         */
        function addApplicableElectricalPacks(electricalPacksList) {
            
            /**
             * Returns first found part from a provided list, which matches the provided part code.
             * @param {String} code A part code to compare against.
             * @param {Array} partList A list of parts to compare against.
             * @return {Object} Returns a part from the provided part list if it exists.
             */
            function getPartByCode(code, partList) {
                for (var i = 0; i < partList.length; i++) {
                    if (partList[i].Part_Code__c === code) {
                        return partList[i];
                    }
                }
                return null;
            }
    
            /**
             * Adds a part Id to a list of all part ids to be added to the parts model.
             * Checks whether or not a part to be added already exists.
             * @param {String} partCode A part code of a part to be added. 
             * @param {Array} partList A list of parts against to check whether or not
             * a part to be added exists.
             */
            function addPartToPartsForAddition(partCode, partList) {
    
                var part = getPartByCode(partCode, partList);
    
                if (part && !existsInPartsModelJS(part)) {
                    partIdsToAdd.push(part.Id);
                    zovPartPrereqs++;
                }
            }
    
            /**
             * Checks various conditions used in the business logic which determines 
             * which parts are to be added to the partModelJS.
             * @param {String} partCode A part code of a part to be added.
             * @param {String} partType A part type of a part to be added.
             * @param {Boolean} isWireless A flag indicating whether or not a part is a wireless part.
             */
            function checkPartCodesTypesWireless(partCode, partType, isWireless) {
                if (partCode === 'P193' || partCode === 'P2976') fusedSpurExists = true;
                if (partCode === 'P125' || partCode === 'P1251') isFullyPumped = true;
                if (partType === 'PRG' && partCode != 'PXPRG') prgExists = true;
                if (partType === 'RST' && partCode != 'PXRST' && !isWireless) wiredExists = true;
                if (partCode === 'P140' || partCode === 'P141' || partCode === 'P1412') frostProtectionExists = true;
                if (partType === 'ZOV') zovExists = true;
            }
            
            CS.Log.warn('addApplicableElectricalPacks called..');
            
            var isPor = CS.getAttributeValue('Boiler_0:POR_0') === 'Yes'? true: false,
                fusedSpurExists = false,
                isFullyPumped = false,
                useExistingControls = CS.getAttributeValue('Boiler_0:Use_Existing_Controls_0') === 'Yes' ? true : false,
                prgExists = false,
                wiredExists = false,
                frostProtectionExists = false,
                isSameLocation = CS.getAttributeValue('Boiler_0:Controls_0:Location_0') === 'No' ? true : false,
                zovPartPrereqs = 0,
                zovExists = false;

            // Iterate the partsModelJS.
            for (var id in partsModelJS) {
                if (!partsModelJS.hasOwnProperty(id)) continue;
                var item = partsModelJS[id];
    
                if (item.isPart && item.parentPart.part) {
                    var partCode = item.parentPart.part.Part_Code__c,
                        partType = item.parentPart.part.Type__c,
                        isWireless = item.parentPart.part.Wireless__c;
      
                    checkPartCodesTypesWireless(partCode, partType, isWireless);
                }
                // Check associated parts as well.
                for (var i = 0; i < item.associatedParts.length; i++) {
                    var associatedPart = item.associatedParts[i];
    
                    partCode = associatedPart.part.Part_Code__c;
                    partType = associatedPart.part.Type__c;
                    isWireless = associatedPart.part.Wireless__c;
    
                    checkPartCodesTypesWireless(partCode, partType, isWireless);        
                }
            }
            
            // Test all the logic and get the list of parts to fetch.
            var partIdsToAdd = [];
             
            if (isPor || fusedSpurExists || isFullyPumped) {
                addPartToPartsForAddition('P2958', electricalPacksList);
            } else {
                if (useExistingControls) {
                    addPartToPartsForAddition('P2970', electricalPacksList);
                } else {
                    if (prgExists || wiredExists || frostProtectionExists) {
                        if (isSameLocation) {
                            addPartToPartsForAddition('P2970', electricalPacksList);
                        } else {
                            addPartToPartsForAddition('P2958', electricalPacksList); 
                        }
                    } else {
                        if (isFullyPumped) {
                            addPartToPartsForAddition('P2958', electricalPacksList);
                        } else {
                            addPartToPartsForAddition('P2970', electricalPacksList);
                        }
                    }
                }
            }
    
            if (zovPartPrereqs == 1 && zovExists) {
                addPartToPartsForAddition('P2959', electricalPacksList);
                addPartToPartsForAddition('P1422', electricalPacksList);
            }
            
            CS.Log.warn('*** Electrical Packs to be added to the partsModel: ' + partIdsToAdd.length);
            
            // Add the electrical packs to the parts Model
            if (partIdsToAdd.length > 0) {
                CS.Log.warn('Electrical Packs found to be added..');
                
                // This wraps up ALL variables that are required in the chain of promises, wrapped up in a single parameter.
                var partParams = {
                    parentPartIds: [], //holds parentIds
                    parentBundleIds: [], //holds parent Bundles
                    partIdsToQuery: [], //all Parts that need to be retrieved
                    parentToAssociatedPartsMap: {}, //Map<String, List<AssociatedPartWrapper>> - Key here is a BundleId or a PartId, values are the associated Parts
                    multilookupAttToAssociatedPartsMap: {},
                    allReferencedBundlesMap: {},
                    pricesAffected: true
                };
                            
                partParams.partIdsToQuery = _.uniq(partIdsToAdd);
                partParams.parentPartIds =_.uniq(partIdsToAdd);
                partParams.pricesAffected = true; // Clear allowances as we are adding new parts.
                
                return getPartAssociations(partParams)
                .then(function(params) {
                    return handlePartAssociationResponseCommon(params);
                })
                .then(function(params) {
                    return getAllReferencedPartInformation(params);
                })
                .then(function(params) {
                    return addElectricalPacksToPartsModel(params); 
                });
                 
            }
            else {
                CS.Log.warn('No Electrical Packs found to be added..');
                Q.resolve();
            }
        }
    };
    
    /**
     * Constructs parts to be added to the parts model. Creates part associations.
     * @param {Object} partParams An oject containing all of the retreived parts which are to be added to the solution.
     */
    function addElectricalPacksToPartsModel(partParams) {
        
        var allReferencedPartWrappersMap = partParams.allReferencedPartWrappersMap;
        
        CS.Log.warn('****** Referenced Parts retrieved: ' + Object.keys(allReferencedPartWrappersMap).length);
        
        var counter = 0;
        for (var pId in partParams.allReferencedPartWrappersMap) {
            var associatedParts = []; 
            
            // Check for associations
            if (partParams.parentToAssociatedPartsMap[pId]) {
                var childrenParts = partParams.parentToAssociatedPartsMap[pId];
                
                for (var i = 0; i <  childrenParts.length; i++) {
                    var apw = childrenParts[i];
                    
                    // Note: not all AssociatedParts may be retrieved if they don't match the filter criteria
                    if (allReferencedPartWrappersMap[apw.associatedPartId]) {
                        var retrievedPartWrapper = allReferencedPartWrappersMap[apw.associatedPartId]; //type CS_PartWrapper
                                                
                        if (retrievedPartWrapper.part.Included_In_Regions__c && _.contains(retrievedPartWrapper.part.Included_In_Regions__c.split(','), regionCode)) {
                            var assPartInfo = new CS_PartInformation(retrievedPartWrapper, null, districtCode, apw.quantity, geographicUpliftFactor);
                            associatedParts.push(assPartInfo);
                        }
                    }
                }
            } else {
                CS.Log.warn('********* No associated Parts found for: ' + pId);
            }
            
            // ---------------------------------------------------------------------------------------
            // ---------- Now create the entry (key of the Map will be the attRef) ------------------ 
            var entry = null; //type CS_PartModelEntry. Clear the entry
            
            //If parent is Part
            if (isInArray(pId, partParams.parentPartIds)) {
                
                //Configurator has already performed the eligibility checks otherwise this couldn't have been selected
                var parentPartWrapper = allReferencedPartWrappersMap[pId] ? allReferencedPartWrappersMap[pId] : null;  //type CS_PartWrapper
                
                if (!parentPartWrapper) {
                    CS.Log.warn('***** Electrical parentPart filtered out on the DB: ' + pId);
                }
                
                if (parentPartWrapper) {
                    CS.Log.warn('***** parentPart is: ' + parentPartWrapper.part.Name);
                    var attRef = electricalPackEntryRef + counter;
                    counter++;
                    
                    CS.Log.warn('Creating entry for electrical Pack with attRef: ' + attRef);
                    var attWrapper = new CS_RemotingParamWrapper(attRef, pId, 0, 1, '', true, true, false, false, false, false, '', '');
                    
                    entry = new CS_PartModelEntry(attWrapper, null, parentPartWrapper, associatedParts, pricebookType, districtCode, geographicUpliftFactor);
                } else {
                    CS.Log.warn('No parentPartWrapper found..');
                }
            }
            
            if (entry) {
                partsModelJS[attRef] = entry;
                CS.Log.warn('***** New entry added with attRef: ' + attRef);
            }
            else {
                CS.Log.warn('entry is null..');
            }
        }
        
        return Q.resolve();
    }
    
    //{ #endregion Electrical Pack automatic addition
    
    window.checkIfPartExists = function checkIfPartExists(item, itemList){
        return itemList.indexOf(item) > -1
    }


    //{ #region Select list packs 
       
    window.checkSelectListPacks = function checkSelectListPacks() {
        CS.Log.warn('***** checkSelectListPacks called...');
        //selectListPackPartCodesList = _.uniq(selectListPackPartCodesList);
        CS.Log.warn('Number of part codes: ' + selectListPackPartCodesList.length);
        CS.Log.warn('Part codes: ');
        CS.Log.warn(selectListPackPartCodesList);
        

        //PCBH3 AUTO ADD        
        if(checkIfPartExists('P2276', selectListPackPartCodesList) && (checkIfPartExists('PCBH1', selectListPackPartCodesList)||checkIfPartExists('PCBH2', selectListPackPartCodesList))){
         
            //CS.Log.warn("+++++++ P2276 and PCBH1 or PCBH2 EXIST +++++++");
            existsPCBH3 = true;
            existAddedHive = true;
            //selectListPackPartCodesList.push("PCBH3");
        }
        else if(checkIfPartExists('PCBH1', selectListPackPartCodesList)||checkIfPartExists('PCBH2', selectListPackPartCodesList) ||checkIfPartExists('PCBH4', selectListPackPartCodesList) ||checkIfPartExists('PCBH5', selectListPackPartCodesList) ) {

            existAddedHive = true;
            //CS.Log.warn("+++++++ !!!!!!!PCBH1 or PCBH2 EXIST +++++++");
            //CS.Log.warn("++++++ExistsPCBH3 =="+existsPCBH3);
        }
        else{
            existsPCBH3=false;
            existAddedHive = false;
            //CS.Log.warn("++++++doesn't exists");
        }

        // map to store select list attributes' quantities
        var partCodesQtyMap = new Map();

        _.each(selectListPackPartCodesList, function(slPartCode) {
          if (!partCodesQtyMap.has(slPartCode)) {
            partCodesQtyMap.set(slPartCode, 1);
          } else {
            partCodesQtyMap.set(
              slPartCode,
              partCodesQtyMap.get(slPartCode) + 1
            );
          }
        });

        
        return getPacksByCode(selectListPackPartCodesList).then(function(result) {
            for (i = 0; i < result.length; i++) {
                if (partCodesQtyMap.has(result[i].Part_Code__c)) {
                    partCodesQtyIdsMap.set(result[i].Id, partCodesQtyMap.get(result[i].Part_Code__c))
                }
            }
            return addApplicableSelectListParts(result);
        });
        
        function addApplicableSelectListParts(selectListParts) {
            CS.Log.warn('addApplicableSelectListParts called...');
            CS.Log.warn('Select List Packs to be added to the partsModel: ' + selectListParts.length);
            CS.Log.warn(selectListParts);
            
            if(selectListParts.length > 0) {
                //This wraps up ALL variables that are required in the chain of promises, wrapped up in a single parameter.
                var partParams = {
                    parentPartIds: [], //holds parentIds
                    parentBundleIds: [], //holds parent Bundles
                    partIdsToQuery: [], //all Parts that need to be retrieved
                    parentToAssociatedPartsMap: {}, //Map<String, List<AssociatedPartWrapper>> - Key here is a BundleId or a PartId, values are the associated Parts
                    multilookupAttToAssociatedPartsMap: {},
                    allReferencedBundlesMap: {},
                    pricesAffected: true
                };
                
               var partIdsToBeAdded = [];
                _.each(selectListParts, function(part) {
                    partIdsToBeAdded.push(part.Id);
                });         

                //partParams.partIdsToQuery = _.uniq(partIdsToBeAdded);
                //partParams.parentPartIds =_.uniq(partIdsToBeAdded);
                partParams.partIdsToQuery = partIdsToBeAdded;
                partParams.parentPartIds = partIdsToBeAdded;
                partParams.pricesAffected = true; //clear allowances as we are adding new parts...

                return getPartAssociations(partParams).then(function(params) {
                    return handlePartAssociationResponseCommon(params);  //ok
                }).then(function(params) {
                    return getAllReferencedPartInformation(params);  //ok
                }).then(function(params) {
                    return addSelectListPacksToPartsModel(params);  //NEW
                });                 
            } else {
                CS.Log.warn('No Select List Packs found to be added..');
                Q.resolve();
            }
        };

        function addSelectListPacksToPartsModel(partParams) {

            //CS.Log.warn("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!ADDING SELECT LIST PACKS");

            var allReferencedPartWrappersMap = partParams.allReferencedPartWrappersMap;

            CS.Log.warn('****** Referenced Parts retrieved: ' + Object.keys(allReferencedPartWrappersMap).length);

            var counter = 0;
            for (var pId in partParams.allReferencedPartWrappersMap) {              
                var associatedParts = []; 

                // Check for associations
                if (partParams.parentToAssociatedPartsMap[pId]) {               
                    var childrenParts = partParams.parentToAssociatedPartsMap[pId]; //list

                    for (var i = 0; i <  childrenParts.length; i++) {
                        var apw = childrenParts[i];

                        // Note: not all AssociatedParts may be retrieved if they don't match the filter criteria
                        if (allReferencedPartWrappersMap[apw.associatedPartId]) {
                            var retrievedPartWrapper = allReferencedPartWrappersMap[apw.associatedPartId]; //type CS_PartWrapper
                                        
                            if (retrievedPartWrapper.part.Included_In_Regions__c && _.contains(retrievedPartWrapper.part.Included_In_Regions__c.split(','), regionCode)) {
                                var assPartInfo = new CS_PartInformation(retrievedPartWrapper, null, districtCode, apw.quantity, geographicUpliftFactor);
                                associatedParts.push(assPartInfo);
                            }
                        }
                    }
                } else {
                    CS.Log.warn('********* No associated Parts found for: ' + pId);
                }

                // --------------------------------------------------------------------------------------
                // ---------- Now create the entry (key of the Map will be the attRef) ------------------ 

                var entry = null; //type CS_PartModelEntry. Clear the entry.
                // If parent is Part
                if (isInArray(pId, partParams.parentPartIds)) {                 
                    var parentPartWrapper = allReferencedPartWrappersMap[pId] ? allReferencedPartWrappersMap[pId] : null;  //type CS_PartWrapper

                    if(!parentPartWrapper) { //is null
                        CS.Log.warn('***** Select List parentPart filtered out on the DB: ' + pId);
                    }

                    CS.Log.warn('***** parentPart is: ' + parentPartWrapper.part.Name);

                    if (parentPartWrapper) {
                        var attRef = selectListPackEntryRef + counter;
                        counter++;

                        //set attribute quantity
                        var attQty = 1;
                        if (partCodesQtyIdsMap.has(pId)) {
                            attQty = partCodesQtyIdsMap.get(pId);
                        }

                        CS.Log.warn('Creating entry for Select List Pack with attRef: ' + attRef);
                        var attWrapper = new CS_RemotingParamWrapper(attRef, pId, 0, attQty, '', true, true, false, false, false, false, '', '');                        
                        entry = new CS_PartModelEntry(attWrapper, null, parentPartWrapper, associatedParts, pricebookType, districtCode, geographicUpliftFactor);
                    } else {
                        CS.Log.warn('No parentPartWrapper found..');
                    }
                }

                if (entry) {
                    partsModelJS[attRef] = entry;
                    //CS.Log.warn('***** New entry added with attRef: ' + attRef);
                    //CS.Log.warn('ADDED FOLLOWING ENTRY..'+entry);
                } else {
                    CS.Log.warn('entry is null..');
                }
            }           
            return Q.resolve();
        };
    };

    //} #endregion Select list packs



    //TEST ADDITIONAL

    window.checkAdditionalPacks = function checkAdditionalPacks() {
        CS.Log.warn('***** checkAdditionalListPacks called...');
        additionalPackPartCodesList = [];
        var boilerID= CS.getAttributeValue("Boiler_0:Part_Code_0","String");

        //PCBH3 AUTO ADD        
        //CS.Log.warn("++++++ExistsPCBH3 =="+existsPCBH3);
        if((existAddedHive==true) && (existsPCBH3 == true)){
            additionalPackPartCodesList.push("PCBH3");
        }
        
        //IC 31/08/2018
        var boilerArr=['CBLR1380','CBLR3453','CBLR3454','CBLR3455','CBLR3456','CBLR3457','CBLR3458','CBLR3461','CBLR3462'];

        if(isInArray(boilerID,boilerArr) && existAddedHive==true){
            additionalPackPartCodesList.push("PCBH3");
        }
        else{
            //CS.Log.warn("++++++doesn't exists");

            CS.Log.warn('No Additional List Packs found to be added..');
            Q.resolve();
        }
        
        return getPacksByCode(additionalPackPartCodesList).then(function(result) {
            return addApplicableAdditionalParts(result);
        });
        
        function addApplicableAdditionalParts(additionalListParts) {
            CS.Log.warn('additionalListParts called...');
            CS.Log.warn('Additional Packs to be added to the partsModel: ' + additionalListParts.length);
            CS.Log.warn(additionalListParts);
            
            if(additionalListParts.length > 0) {
                //This wraps up ALL variables that are required in the chain of promises, wrapped up in a single parameter.
                var partParams = {
                    parentPartIds: [], //holds parentIds
                    parentBundleIds: [], //holds parent Bundles
                    partIdsToQuery: [], //all Parts that need to be retrieved
                    parentToAssociatedPartsMap: {}, //Map<String, List<AssociatedPartWrapper>> - Key here is a BundleId or a PartId, values are the associated Parts
                    multilookupAttToAssociatedPartsMap: {},
                    allReferencedBundlesMap: {},
                    pricesAffected: true
                };
                
               var partIdsToBeAdded = [];
                _.each(additionalListParts, function(part) {
                    partIdsToBeAdded.push(part.Id);
                });         

                partParams.partIdsToQuery = _.uniq(partIdsToBeAdded);
                partParams.parentPartIds =_.uniq(partIdsToBeAdded);
                partParams.pricesAffected = true; //clear allowances as we are adding new parts...

                return getPartAssociations(partParams).then(function(params) {
                    return handlePartAssociationResponseCommon(params);  //ok
                }).then(function(params) {
                    return getAllReferencedPartInformation(params);  //ok
                }).then(function(params) {
                    return addAdditionalPacksToPartsModel(params);  //NEW
                });                 
            } else {
                CS.Log.warn('No Additional List Packs found to be added..');
                Q.resolve();
            }
        };

        function addAdditionalPacksToPartsModel(partParams) {

            var allReferencedPartWrappersMap = partParams.allReferencedPartWrappersMap;

            CS.Log.warn('****** Referenced Parts retrieved: ' + Object.keys(allReferencedPartWrappersMap).length);

            var counter = 0;
            for (var pId in partParams.allReferencedPartWrappersMap) {              
                var associatedParts = []; 

                // Check for associations
                if (partParams.parentToAssociatedPartsMap[pId]) {               
                    var childrenParts = partParams.parentToAssociatedPartsMap[pId]; //list

                    for (var i = 0; i <  childrenParts.length; i++) {
                        var apw = childrenParts[i];

                        // Note: not all AssociatedParts may be retrieved if they don't match the filter criteria
                        if (allReferencedPartWrappersMap[apw.associatedPartId]) {
                            var retrievedPartWrapper = allReferencedPartWrappersMap[apw.associatedPartId]; //type CS_PartWrapper
                                        
                            if (retrievedPartWrapper.part.Included_In_Regions__c && _.contains(retrievedPartWrapper.part.Included_In_Regions__c.split(','), regionCode)) {
                                var assPartInfo = new CS_PartInformation(retrievedPartWrapper, null, districtCode, apw.quantity, geographicUpliftFactor);
                                associatedParts.push(assPartInfo);
                            }
                        }
                    }
                } else {
                    CS.Log.warn('********* No associated Parts found for: ' + pId);
                }

                // --------------------------------------------------------------------------------------
                // ---------- Now create the entry (key of the Map will be the attRef) ------------------ 

                var entry = null; //type CS_PartModelEntry. Clear the entry.
                // If parent is Part
                if (isInArray(pId, partParams.parentPartIds)) {                 
                    var parentPartWrapper = allReferencedPartWrappersMap[pId] ? allReferencedPartWrappersMap[pId] : null;  //type CS_PartWrapper

                    if(!parentPartWrapper) { //is null
                        CS.Log.warn('***** Additional parentPart filtered out on the DB: ' + pId);
                    }

                    CS.Log.warn('***** parentPart is: ' + parentPartWrapper.part.Name);

                    if (parentPartWrapper) {
                        var attRef = additionalPackEntryRef + counter;
                        counter++;

                        CS.Log.warn('Creating entry for additional Pack with attRef: ' + attRef);
                        var attWrapper = new CS_RemotingParamWrapper(attRef, pId, 0, 1, '', true, true, false, false, false, false, '', '');                        
                        entry = new CS_PartModelEntry(attWrapper, null, parentPartWrapper, associatedParts, pricebookType, districtCode, geographicUpliftFactor);
                    } else {
                        CS.Log.warn('No parentPartWrapper found..');
                    }
                }

                if (entry) {
                    partsModelJS[attRef] = entry;
                    CS.Log.warn('***** New entry added with attRef: ' + attRef);
                } else {
                    CS.Log.warn('entry is null..');
                }
            }           
            return Q.resolve();
        };
    };


    //END TEST ADDITIONAL




    window.checkUserInputPacks = function checkUserInputPacks() {
        CS.Log.warn('***** checkUserInputPacks called...');
        userInputPackPartCodeList = _.pluck(userInputPackPartCodeListData, 'pack code');
        userInputPackPartCodeList = _.filter(userInputPackPartCodeList, function(element){ return element != undefined; });
        CS.Log.warn('Number of part codes: ' + userInputPackPartCodeList.length);
        CS.Log.warn('Part codes: ');
        CS.Log.warn(userInputPackPartCodeList);
        
        return getPacksByCode(userInputPackPartCodeList).then(function(result) {
            return addApplicableUserInputParts(result);
        });
        
        function addApplicableUserInputParts(userInputParts) {
            CS.Log.warn('addApplicableUserInputParts called...');
            CS.Log.warn('User Input Packs to be added to the partsModel: ' + userInputParts.length);
            CS.Log.warn(userInputParts);
            
            if(userInputParts.length > 0) {
                //This wraps up ALL variables that are required in the chain of promises, wrapped up in a single parameter.
                var partParams = {
                    parentPartIds: [], //holds parentIds
                    parentBundleIds: [], //holds parent Bundles
                    partIdsToQuery: [], //all Parts that need to be retrieved
                    parentToAssociatedPartsMap: {}, //Map<String, List<AssociatedPartWrapper>> - Key here is a BundleId or a PartId, values are the associated Parts
                    multilookupAttToAssociatedPartsMap: {},
                    allReferencedBundlesMap: {},
                    pricesAffected: true,
                    parentValues: [] // new - holds user input values
                };
                
               var partIdsToBeAdded = [];
                _.each(userInputParts, function(part) {
                    partIdsToBeAdded.push(part.Id);
                });         

                partParams.partIdsToQuery = partIdsToBeAdded;
                partParams.parentPartIds = partIdsToBeAdded;
                partParams.pricesAffected = true; //clear allowances as we are adding new parts...

                return getPartAssociations(partParams).then(function(params) {
                    return handlePartAssociationResponseCommon(params);
                }).then(function(params) {
                    return getAllReferencedPartInformation(params);
                }).then(function(params) {
                    return addUserInpuPacksToPartsModel(params);
                });                 
            } else {
                CS.Log.warn('No User Input Packs found to be added..');
                Q.resolve();
            }
        };

        function addUserInpuPacksToPartsModel(partParams) {

            var allReferencedPartWrappersMap = partParams.allReferencedPartWrappersMap;

            CS.Log.warn('****** Referenced Parts retrieved: ' + Object.keys(allReferencedPartWrappersMap).length);

            var counter = 0;
            for (var pId in partParams.allReferencedPartWrappersMap) {              
                var associatedParts = []; 

                // Check for associations
                if (partParams.parentToAssociatedPartsMap[pId]) {               
                    var childrenParts = partParams.parentToAssociatedPartsMap[pId]; //list

                    for (var i = 0; i <  childrenParts.length; i++) {
                        var apw = childrenParts[i];

                        // Note: not all AssociatedParts may be retrieved if they don't match the filter criteria
                        if (allReferencedPartWrappersMap[apw.associatedPartId]) {
                            var retrievedPartWrapper = allReferencedPartWrappersMap[apw.associatedPartId]; //type CS_PartWrapper
                                        
                            if (retrievedPartWrapper.part.Included_In_Regions__c && _.contains(retrievedPartWrapper.part.Included_In_Regions__c.split(','), regionCode)) {
                                var assPartInfo = new CS_PartInformation(retrievedPartWrapper, null, districtCode, apw.quantity, geographicUpliftFactor);
                                associatedParts.push(assPartInfo);
                            }
                        }
                    }
                } else {
                    CS.Log.warn('********* No associated Parts found for: ' + pId);
                }

                // --------------------------------------------------------------------------------------
                // ---------- Now create the entry (key of the Map will be the attRef) ------------------ 

                var entry = null; //type CS_PartModelEntry. Clear the entry.
                // If parent is Part
                if (isInArray(pId, partParams.parentPartIds)) {                 
                    var parentPartWrapper = allReferencedPartWrappersMap[pId] ? allReferencedPartWrappersMap[pId] : null;  //type CS_PartWrapper

                    if(!parentPartWrapper) { //is null
                        CS.Log.warn('***** User Input parentPart filtered out on the DB: ' + pId);
                    }

                    CS.Log.warn('***** parentPart is: ' + parentPartWrapper.part.Name);

                    CS.Log.warn(parentPartWrapper);
                    if (parentPartWrapper) {
                        CS.Log.warn('passed');
                        var attRef = userInputPackEntryRef + counter;
                        counter++;

                        CS.Log.warn('Creating entry for User Input Pack with attRef: ' + attRef + ' ' + pId);

                        var quantitiy = userInputPackPartCodeListData[parentPartWrapper.part.Part_Code__c];

                        var attWrapper = new CS_RemotingParamWrapper(attRef, pId, 0, quantitiy, '', true, true, false, false, false, false, '', '');
                        entry = new CS_PartModelEntry(attWrapper, null, parentPartWrapper, associatedParts, pricebookType, districtCode, geographicUpliftFactor);
                    } else {
                        CS.Log.warn('No parentPartWrapper found..');
                    }
                }

                if (entry) {
                    partsModelJS[attRef] = entry;
                    CS.Log.warn('***** New entry added with attRef: ' + attRef + ' ' + quantitiy);
                } else {
                    CS.Log.warn('entry is null...');
                }
            }           
            return Q.resolve();
        };
    };

    /**
     * Replaces an associated part in the bundle with another part.
     * @param  {[type]} bundleAttRef   Bundle to have its associated part replaced.
     * @param  {[type]} removePartCode Part code of the part to be replaced.
     * @param  {[type]} addPartCode    Part code of the part to be added instead.
     * @param  {[type]} quantity       Quantity of the part to be added.
     */
    window.replaceBundlePart = function replaceBundlePart(bundleAttRef, removePartCodes, addPartCodes, quantity) {
    
        /**
         * Replaces the associated parts from a provided bundle. 
         * @param  {Object} partParams Retrieved parts to be added to the bundle.
         * @param  {Object} bundle     A bundle which will have its associated parts replaced.
         */
        function replaceAssociatedParts(partParams, bundle) {
            var allReferencedPartWrappersMap = partParams.allReferencedPartWrappersMap;
            var associatedParts = []; 
    
            for (var pId in allReferencedPartWrappersMap) {
                var retrievedPartWrapper = allReferencedPartWrappersMap[pId]; //type CS_PartWrapper
    
                var assPartInfo = new CS_PartInformation(retrievedPartWrapper, null, districtCode, quantity, geographicUpliftFactor);
                associatedParts.push(assPartInfo);
            }    

            bundle.associatedParts = bundle.associatedParts.concat(associatedParts);
            return Q.resolve();
        }
    
        /**
         * Recalculates the bundle aggregated values (aggregatedCost, aggregatedNetPrice, aggregatedPriceInvlVAT)
         * @param  {Object} bundle A bundle which will have its totals recalculated.
         */
        function recalculateBundleTotals(bundle) {
            var aggregatedMap = {
                aggregatedCost: 0,
                aggregatedNetPrice: 0,
                aggregatedPriceInclVAT: 0
            };
            bundle.associatedParts.reduce(function(map, part) {
                map.aggregatedCost += part.totalSkillsCost + part.totalMaterialsCost;
                map.aggregatedNetPrice += part.totalNetPrice;
                map.aggregatedPriceInclVAT += part.totalPriceIncVAT;
                return aggregatedMap;
            }, aggregatedMap);
    
            bundle.aggregatedCost = aggregatedMap.aggregatedCost;
            bundle.aggregatedNetPrice = aggregatedMap.aggregatedNetPrice;
            bundle.aggregatedPriceInclVAT = aggregatedMap.aggregatedPriceInclVAT;
            return Q.resolve();
        }

        // check whether the parameters are specified, set the variable value to an empty array of not
        // change: M.K. April 1, 2015
        removePartCodes = removePartCodes || '';// removePartCodes = removePartCodes || [];
        addPartCodes = addPartCodes || '';// addPartCodes = addPartCodes || [];

        // if both arrays are empty, there is no need to make any changes
        // we need to return a promise since this is a part of chained promise
        if((removePartCodes.length == 0) && (addPartCodes.length == 0)) return Q.resolve();
    
        var bundle = _.findWhere(partsModelJS, {attRef: bundleAttRef}); // Retrieve the specified bundle from the partsModelJS
        var partsToBeRemoved = removePartCodes.split(',').concat(addPartCodes.split(','));
        
        var associatedParts = _.filter(bundle.associatedParts, function(it) { // Filter the associated parts
            return !_.contains(partsToBeRemoved, it.part.Part_Code__c);
        });
        
        bundle.associatedParts = associatedParts; // Replace the bundle associated parts
    
        // -- Get the part --
        return getPacksByCode(addPartCodes.split(',')).then(function(packs) {
            var partIds = _.pluck(packs, 'Id');
            CS.Log.warn('PartIds are:', partIds);
            var partParams = {
                parentPartIds: [], 
                parentBundleIds: [], 
                partIdsToQuery: [], //all Parts that need to be retrieved
                parentToAssociatedPartsMap: {}, 
                multilookupAttToAssociatedPartsMap: {},
                allReferencedBundlesMap: {},
                pricesAffected: true
            };
    
            partParams.parentPartIds = _.uniq(partIds);
            partParams.partIdsToQuery = _.uniq(partIds);
         
            return partParams;
        })
        .then(function(partParams) {
            return getAllReferencedPartInformation(partParams); // Get the part information
        })
        .then(function(partParams) {
            return replaceAssociatedParts(partParams, bundle); // Replace the associated part in the bundle
        })
        .then(function() {
            return recalculateBundleTotals(bundle); // Recalculate bundle totals
        })
        .fail(function(err) {
            CS.Log.warn(err);
        });
    }
    
    
    function checkBundleReplacementParts() {
        
        CS.Log.warn('Checking bundle replacement packs...');        
        return Q(1).then(function() {
            //get list of district projects
            //var projects = (CS.getAttributeValue('Boiler_0:Included_Projects_0') || '').split(","); 
            var projects = CS.getAttributeValue('Boiler_0:Included_Projects_0'); 
            var isFlueRelatedWorkRequired = CS.getAttributeValue('Boiler_0:Is_Flue_Related_Work_Required_0') == 'Yes' ? true : false;
            
            var bundleName = 'Boiler_0:Core_Bundle_ID_0';
            var partsToBeRemoved = 'P1992,P1949,P1993';

            if(projects && projects.indexOf("FBW") > 0){
                partsToBeAdded='P1945';
            }else{
                partsToBeAdded='P1949';
            }

            // if the checkbox is ticked swap the building work
            if(isFlueRelatedWorkRequired) {
                CS.Log.warn("****Swapped building work packs****");
                return replaceBundlePart(bundleName, partsToBeRemoved, partsToBeAdded, 1); 
            } else {
                return Q.resolve();
            }
        })// continue the chain here if there are more bundle to be checked against (remove the ';' if youre continuing the chain of promises)
        /*
        an example of the continued chain:
        
        .then(function() {
            var isSomeOtherCheckBoxTrue = ...
            if(isSomeOtherCheckBoxTrue) {
                return replaceBundlePart('Bundle_att_ref', 'partToBeRemoved', 'partToBeAdded', quantity);
            } else {
                return Q.resolve();
            }
        });
        
        */
        //IC added 17/12/14 (removed ';' from above)
        .then(function(){
            CS.Log.warn("Swap pipe in bundle");
            var pipePack = CS.getAttributeValue('Boiler_0:PipePackID_0');
            var bundleName = 'Boiler_0:Core_Bundle_ID_0';
            CS.Log.warn("bundleName: " + bundleName);
            var additionalPipe = CS.getAttributeValue('Boiler_0:AdditionalPipeQuantity_0', 'Integer');
            var existingQty = CS.getAttributeValue('Boiler_0:PipeInBundle_0', 'Integer');
            var newQty = 0;
            newQty = existingQty + additionalPipe;
            CS.Log.warn("newQty: " + newQty);
            if(additionalPipe != null && additionalPipe > 0) {
                CS.Log.warn('Replace the parts');
                return replaceBundlePart(bundleName, pipePack, pipePack, newQty);
            } else {
                return Q.resolve();
            }
        })
        //IC Added 22/06/2015
        .then(function(){
            CS.Log.warn("---Checking condensate bundle---");
            var term=CS.getAttributeValue("Boiler_0:Condensate_0:Termination_Point_0", "String");
            var length= CS.getAttributeValue("Boiler_0:Condensate_0:External_length_0", "String");
            
            //updated 13/05/2019
            var boilerArr=['CBLR1360','CBLR1361','CBLR1362','CBLR1363','CBLR1040','CBLR1041','CBLR1042','CBLR1043','CBLR1044','CBLR1045','CBLR1046','CBLR1047','CBLR1094','CBLR1095',
            'CBLR3500',	'CBLR3501',	'CBLR3502',	'CBLR3503',	'CBLR3504',	'CBLR3505',	'CBLR3506',	'CBLR3507',	'CBLR3508',	'CBLR3509',	'CBLR3514',	'CBLR3515',	'CBLR3516',	'CBLR3517',
            'CBLR3518',	'CBLR3519',	'CBLR3520',	'CBLR3521',	'CBLR3522',	'CBLR3523',	'CBLR3510',	'CBLR3511',	'CBLR3512',	'CBLR3513',	'CBLR3524',	'CBLR3525',	'CBLR3526',	'CBLR3527',	
            'CBLR3548',	'CBLR3549',	'CBLR3550',	'CBLR3551',	'CBLR3528',	'CBLR3529',	'CBLR3530',	'CBLR3531',	'CBLR3532',	'CBLR3533',	'CBLR3534',	'CBLR3535',	'CBLR3536',	'CBLR3537',	
            'CBLR3538',	'CBLR3539',	'CBLR3540',	'CBLR3541',	'CBLR3542',	'CBLR3543',	'CBLR3544',	'CBLR3545',	'CBLR3546',	'CBLR3547'
            ];
            var boilerID= CS.getAttributeValue("Boiler_0:Part_Code_0","String");
            
            if(term=="External" && length=="upto3" && isInArray(boilerID,boilerArr)){
                var bundleAttRef="Boiler_0:Condensate_0:Condensate_Solution_ID_0";
                var colour=CS.getAttributeValue("Boiler_0:Condensate_0:Pipework_Colour_0","String");
                //CS.Log.warn(colour);
                if(colour=="Black"){
                    var removePart='P2087';
                    var addPart='P1326';}
                else if(colour=="White"){
                    var removePart='P2085';
                    var addPart='P1313';
                }
                CS.Log.warn("replaceBundlePart("+bundleAttRef+","+removePart+","+addPart+")");
                return replaceBundlePart(bundleAttRef, removePart, addPart, 1);
                
            }
            else {
                return Q.resolve();
            }
        })
        .then(function(){
            CS.Log.warn("---Checking auto by pass in core bundle---");  
            //IC updated 31/08/2018
            var boilerArr=['CBLR1372','CBLR1373','CBLR1374','CBLR1375','CBLR1376','CBLR1377','CBLR3370','CBLR3371','CBLR3372',
                           'CBLR3375','CBLR3376','CBLR3377','CBLR1417','CBLR1418','CBLR1419','CBLR1420','CBLR1421','CBLR1422',
                           'CBLR3423','CBLR3424','CBLR3425','CBLR3426','CBLR3427','CBLR3428',
                           'CBLR3453','CBLR3454','CBLR3455','CBLR3456','CBLR3457','CBLR3458','CBLR3461','CBLR3462'];
                           
            var boilerID= CS.getAttributeValue("Boiler_0:Part_Code_0","String");
            
            if(isInArray(boilerID,boilerArr)){
                var bundleAttRef="Boiler_0:Core_Bundle_ID_0";
                var removePart='P321';
                var addPart='';
                CS.Log.warn("replaceBundlePart("+bundleAttRef+","+removePart+")");
                return replaceBundlePart(bundleAttRef, removePart,"",0);
                
            }
            else {
                return Q.resolve();
            }
        });
    }

    window.addComplexPriceToCoreBundle = function addComplexPriceToCoreBundle() {
        var bundleName = 'Boiler_0:Core_Bundle_ID_0';
        var bundleId = CS.getAttributeValue('Boiler_0:Core_Bundle_ID_0');
        if (bundleId == null) {
            CS.Log.warn('***** No bundleId to query.');
            return Q.resolve();
        }

        var skillCodesToExclude = ['E','EA'];
        var totalSkillHours = calculateTotalSkillHours(skillCodesToExclude);
        var device = (navigator.device ? 'iPad' : 'Laptop');

        if (device == 'iPad') {
            return CS.DB.smartQuery("SELECT {CS_Part__c:Part_Code__c} FROM {CS_Bundle__c}, {CS_Bundle_Complex_Price_Association__c}, {CS_Part__c} WHERE {CS_Bundle_Complex_Price_Association__c:CS_Bundle__c} = '" + bundleId + "' AND {CS_Bundle_Complex_Price_Association__c:Lower_Skill_Hours_Limit__c} <= " + totalSkillHours + " AND ({CS_Bundle_Complex_Price_Association__c:Upper_Skill_Hours_Limit__c} > " + totalSkillHours + " OR {CS_Bundle_Complex_Price_Association__c:Upper_Skill_Hours_Limit__c} IS NULL) AND {CS_Bundle__c:Id} = {CS_Bundle_Complex_Price_Association__c:CS_Bundle__c} AND {CS_Part__c:Id} = {CS_Bundle_Complex_Price_Association__c:CS_Part__c}")
                .then(function(qr) {
                    return qr.getAll().then(function(results) {             
                        var partsToBeAdded = (results[0] || []).join();
                        return replaceBundlePart(bundleName, '', partsToBeAdded, 1);
                    });
                });

        } else if (device == 'Laptop') {
            var deferred = Q.defer();
            CS.Log.warn('***** Now calling RemoteAction getBundleComplexPriceAssociations...');

            UISupport.getBundleComplexPriceAssociations(
                [bundleId], totalSkillHours,
                function(results, event) {
                    if (event.status) {
                        var partsToBeAdded = [];
                        var bcpaObject = results || {};
                        for (var key in bcpaObject) {
                            if (bcpaObject.hasOwnProperty(key)) {
                                var bcpa = bcpaObject[key];
                                var partCode = bcpa.CS_Part__r.Part_Code__c;

                                partsToBeAdded.push(partCode);
                            }
                        }
                        partsToBeAdded = partsToBeAdded.join();
                        return replaceBundlePart(bundleName, '', partsToBeAdded, 1).then(function() {
                            deferred.resolve();    
                        });
                    } else {
                        deferred.reject('Event failed');
                    }
                }
            );
            return deferred.promise;
        }
        throw 'Should not get here'; 

        return Q.resolve();
    }
   
    /**
     * Initiates the construction of the partsModelJS (a Map<String, CS_PartModelEntry>, where key is the attRef. This represents the entire model of price affecting parts)
     * @param {Boolean} pricesAffected
     */
    window.getPartModelInformation = function getPartModelInformation (pricesAffected) {
        
        var deferred = Q.defer();
        CS.indicator.start();
        CS.Log.warn('***** Promises: getPartModelInformation');
        
        //This wraps up ALL variables that are required in the chain of callbacks, wrapped up in a single parameter.
        var partParams = {
            parentPartIds: [], //holds parentIds
            parentBundleIds: [], //holds parent Bundles
            partIdsToQuery: [], //all Parts that need to be retrieved
            parentToAssociatedPartsMap: {}, //Map<String, List<AssociatedPartWrapper>> - Key here is a BundleId or a PartId, values are the associated Parts
            multilookupAttToAssociatedPartsMap: {},
            allReferencedBundlesMap: {},
            partAssociations: [],
            allReferencedPartWrappersMap: {},
            pricesAffected: pricesAffected
        };
        for (var i = 0; i < attsChangedList.length; i++) {
            var rpw = attsChangedList[i];
            
            if (rpw.isBundle === true) {
                partParams.parentBundleIds.push(rpw.attValue);
            }
            else if (rpw.isPart === true && rpw.isMultilookup === false) {
                partParams.parentPartIds.push(rpw.attValue);
            }
            else if (rpw.isMultilookup === true) {
                //split the string, add values to partIdsToQuery, populate the multilookupAttToAssociatedPartsMap
                var partIds = rpw.attValue.split(",");   //partIds are stored in a comma separated list here
                for (var j = 0; j < partIds.length; i++) {
                    var pId = partIds[j];
                    partParams.partIdsToQuery.push(pId);
                    
                    if (!partParams.multilookupAttToAssociatedPartsMap[rpw.attRef]) {
                        var assParts = [];
                        assParts.push(pId);
                        partParams.multilookupAttToAssociatedPartsMap[rpw.attRef] = assParts;
                    }
                    else {
                        var assParts = partParams.multilookupAttToAssociatedPartsMap[rpw.attRef];
                        assParts.push(pId);
                        partParams.multilookupAttToAssociatedPartsMap[rpw.attRef] = assParts;
                    }
                }
            }
        }
        
        partParams.partIdsToQuery = partParams.partIdsToQuery.concat(partParams.parentPartIds); //get all partIds together in the same array
        
        getBundlesWithAssociations(partParams) 
        .then(function(params) {
            return getPartAssociations(params); 
        })
        .then(function(params) {
            return handleBundleAssociationResponseCommon(params); 
        })
        .then(function(params) {
            return handleAllOptionalParts(params); 
        })
        .then(function(params) {
            return handlePartAssociationResponseCommon(params); 
        })
        .then(function(params) {
            return getAllReferencedPartInformation(params); 
        })
        .then(function(params) {
            return handleAllReferencedPartInformationCommon(params); 
        })
        .then(function() {
            return checkforPowerflushAndPowercleanse(); 
        })
        .then(function(){
            return removeAssociatedPowercleansePartFullSys(); 
        })
        .then(function(){
            return checkIfScottishPostcode(); 
        })
        .then(function(params){
            return removeScottishPartsIfNotInScotland(params);
        })
        .then(function(params) {
            return checkElectricalPacks(); 
        })
        .then(function(params) {
            return checkSelectListPacks();
        })
        .then(function(params) {
            return checkAdditionalPacks();
        })
        .then(function(params) {
            return checkUserInputPacks();
        })
        .then(function() {
            return checkBundleReplacementParts();
        })
        .then(function() {
            return addComplexPriceToCoreBundle();
        })
        .then(function() {
            CS.Log.warn('**** Promises: doPriceUpdates');
            //CS.Log.warn('**** pricesAffected: ' + pricesAffected);
            CS.Log.warn('**** partParams.pricesAffected: ' + partParams.pricesAffected);
            
            return doPriceUpdates(partParams.pricesAffected);  
        })
        .then(function() {
            updateAllowanceApplicabilityShadowAttributes();
            return Q.resolve();
        })
        .catch(function(e) { CS.Log.error(e);})
        .done(function(){
            deferred.resolve();
        });
        
        return deferred.promise;
    }
    
    /**
     * Handles the retrieval of Bundle Assocations by creating the required maps.
     * @param {Object} partParams
     */
    window.handleBundleAssociationResponseCommon = function handleBundleAssociationResponseCommon(partParams) {
        CS.indicator.start();
        //Loop through retrieved Bundles and their associations to build the parentToAssociatedPartsMap and push all associated PartIds to partIdsToQuery    
        for (var bundleId in partParams.allReferencedBundlesMap) {
            var bundle = partParams.allReferencedBundlesMap[bundleId];
            
            CS.Log.warn('***** Bundle: ' + bundle.Name + ' has ' + (bundle.CS_Bundle_Part_Associations__r ? bundle.CS_Bundle_Part_Associations__r.length : ' no') + ' Part Asssociations');
            
            if (bundle.CS_Bundle_Part_Associations__r) {
                for (var i = 0; i < bundle.CS_Bundle_Part_Associations__r.length; i++) {    
                   var bpa = bundle.CS_Bundle_Part_Associations__r[i]; //type CS_Bundle_Part_Association__c

                   if(bundle.Type__c == 'Flue'){
                       //For Flue Bundles, ONLY include associated Parts whose boiler group is the same as the one selected in the solution
                       CS.Log.warn('**** Flue found');
                       CS.Log.warn('**** associated Flue Part belongs to boiler group: ' + bpa.Part_Boiler_Group__c);
    
                       if(bpa.Part_Boiler_Group__c && _.contains(bpa.Part_Boiler_Group__c.split(','), boilerGroup)) { 
                           if (!partParams.parentToAssociatedPartsMap[bundleId]) {
                               var assParts = [];
                               assParts.push(new AssociatedPartWrapper(bpa.Part__c, bpa.Quantity__c));
                               partParams.parentToAssociatedPartsMap[bundleId] = assParts;
                           }
                           else {
                               var assParts = partParams.parentToAssociatedPartsMap[bundleId];
                               assParts.push(new AssociatedPartWrapper(bpa.Part__c, bpa.Quantity__c));
                               partParams.parentToAssociatedPartsMap[bundleId] = assParts;
                           }                   
                           partParams.partIdsToQuery.push(bpa.Part__c);
                           CS.Log.warn('***** Part Id pushed to partIdsToQuery for Bundle: ' + bundle.Name);
                       }
                   }
                   else if(bundle.Type__c == 'Multiselect') {
                        //For Flue Bundles, ONLY include associated Parts whose boiler group is the same as the one selected in the solution
                        CS.Log.warn('**** Multiselect Flue found');
                        CS.Log.warn('**** associated Multiselect Flue Part belongs to boiler group: ' + bpa.Part_Boiler_Group__c);

                        if(bpa.Part_Boiler_Group__c && _.contains(bpa.Part_Boiler_Group__c.split(','), boilerGroup)) { 
                               
                           var assParts = [];
                           var selectedFlueParts = CS.getAttributeValue("Boiler_0:Flue_0:Flue_Parts_0");

                            if (selectedFlueParts.length > 0) { 

                                var keyValuePairs = selectedFlueParts.split('|');
                                var retArr =_.reduce(keyValuePairs, function(acc, curr) {
                                    var key = curr.split(',')[0];
                                    acc[key] = parseInt(curr.split(',')[1], 10) || 1;
                                    return acc;
                                }, {});

                                for (itemPart in retArr) {
                                    assParts.push(new AssociatedPartWrapper(itemPart, retArr[itemPart]));
                                    partParams.partIdsToQuery.push(itemPart);
                                }
                                partParams.parentToAssociatedPartsMap[bundleId] = assParts;
                            }
                            CS.Log.warn('***** Part Id pushed to partIdsToQuery for Bundle: ' + bundle.Name);
                        }
                   }
                   else { //for all other Bundle Types
                        if (!partParams.parentToAssociatedPartsMap[bundleId]) {
                            var assParts = [];
                            assParts.push(new AssociatedPartWrapper(bpa.Part__c, bpa.Quantity__c));
                            partParams.parentToAssociatedPartsMap[bundleId] = assParts;
                        }
                        else {
                            var assParts = partParams.parentToAssociatedPartsMap[bundleId];
                            assParts.push(new AssociatedPartWrapper(bpa.Part__c, bpa.Quantity__c));
                            partParams.parentToAssociatedPartsMap[bundleId] = assParts;
                        }                   
                        partParams.partIdsToQuery.push(bpa.Part__c);
                        CS.Log.warn('***** Part Id pushed to partIdsToQuery for Bundle: ' + bundle.Name);
                   }
               }
            }
        }
        
        return Q.resolve(partParams);
     };

     window.handleAllOptionalParts = function handleAllOptionalParts(partParams) {

        CS.indicator.start();
        //Loop through retrieved Part Associations to populate the parentToAssociatedPartsMap and push all associated PartIds to partIdsToQuery
        for (var i = 0; i < partParams.partAssociations.length; i++) {
            var pa = partParams.partAssociations[i];
            if (pa.Relationship__c == 'Optional') {
                var selectedOptionalParts = "";

                if (CS.getAttributeValue("Boiler_0:Optional_Parts_0") != undefined) {
                    selectedOptionalParts = CS.getAttributeValue("Boiler_0:Optional_Parts_0");
                }

                if (selectedOptionalParts.length > 0 && selectedOptionalParts != "undefined") { 

                    var keyValuePairs = selectedOptionalParts.split('|');
                    var retArr =_.reduce(keyValuePairs, function(acc, curr) {
                        var key = curr.split(',')[0];
                        if (key != 'undefined') {
                            acc[key] = parseInt(curr.split(',')[1], 10) || 1;
                        }
                        return acc;
                    }, {});
                    for (itemPart in retArr) {
                        if (itemPart == pa.Part_2__c) {
                            if (!partParams.parentToAssociatedPartsMap[pa.Part_1__c]) {
                                var assParts = [];
                                assParts.push(new AssociatedPartWrapper(pa.Part_2__c, retArr[itemPart]));
                                partParams.parentToAssociatedPartsMap[pa.Part_1__c] = assParts;
                            }
                            else {
                                var assParts = partParams.parentToAssociatedPartsMap[pa.Part_1__c];
                                assParts.push(new AssociatedPartWrapper(pa.Part_2__c, retArr[itemPart]));
                                partParams.parentToAssociatedPartsMap[pa.Part_1__c] = assParts;
                            }
                            
                            partParams.partIdsToQuery.push(pa.Part_2__c);
                        }
                    }
                }
            }
        }
        return Q.resolve(partParams);
     };
        
    /**
     * Handles the retrieval of Part Assocations by creating the required maps.
     * @param {Array} partAssociations
     * @param {Object} partParams
     */
    window.handlePartAssociationResponseCommon = function handlePartAssociationResponseCommon(partParams) {
        CS.indicator.start();
        //Loop through retrieved Part Associations to populate the parentToAssociatedPartsMap and push all associated PartIds to partIdsToQuery
        for (var i = 0; i < partParams.partAssociations.length; i++) {
            var pa = partParams.partAssociations[i];
            if (pa.Relationship__c != 'Optional') {
                if (!partParams.parentToAssociatedPartsMap[pa.Part_1__c]) {
                    var assParts = [];
                    assParts.push(new AssociatedPartWrapper(pa.Part_2__c, pa.Quantity__c));
                    partParams.parentToAssociatedPartsMap[pa.Part_1__c] = assParts;
                }
                else {
                    var assParts = partParams.parentToAssociatedPartsMap[pa.Part_1__c];
                    assParts.push(new AssociatedPartWrapper(pa.Part_2__c, pa.Quantity__c));
                    partParams.parentToAssociatedPartsMap[pa.Part_1__c] = assParts;
                }
                
                partParams.partIdsToQuery.push(pa.Part_2__c);
            }
        }
            
        CS.Log.warn('***** multilookup attributes found: ' + Object.keys(partParams.multilookupAttToAssociatedPartsMap).length);
        CS.Log.warn('**** parentToAssociatedPartsMap entries found: ' + Object.keys(partParams.parentToAssociatedPartsMap).length);
        CS.Log.warn('****** PartIds to query: ' + partParams.partIdsToQuery.length);
        
        return Q.resolve(partParams); 
    }
    
    /**
     * Handles the retrieval of all information associated with the Parts in question
     * @param {Array} allReferencedPartWrappersMap
     * @param {Object} partParams
     */
    window.handleAllReferencedPartInformationCommon = function handleAllReferencedPartInformationCommon(partParams) {
        CS.indicator.start();
        var allReferencedPartWrappersMap = partParams.allReferencedPartWrappersMap;
    
        CS.Log.warn('****** Referenced Parts retrieved: ' + Object.keys(allReferencedPartWrappersMap).length);
        
        // -------------------- Now construct the Entry Model in a map structure for easier retrieval in JS. ----------------------
        // The Keys of the Map will be the attRefs
        // For each key, get its associations from parentToAssociatedPartsMap. Loop through each AssociatedPartWrapper and transform the Key With Associations
        //into a CS_PartModelEntry structure
        
        var partModelInfo = {}; //Map<String, CS_PartModelEntry> will be returned
    
        CS.Log.warn('****');
        CS.Log.warn('**** Building Map ...');
        
        for (var counter = 0; counter < attsChangedList.length; counter++) {
            attWrapper = attsChangedList[counter];
            
            CS.Log.warn('**** for attribute: ' + attWrapper.attRef);
                
            // ------- Create the List of associatedParts for each Key - Check Region applicability -------------
            var associatedParts = []; //List<CS_PartModelEntry.CS_PartInformation>
            
            //For Multi lookups, build associatedPart list given the info in multilookupAttToAssociatedPartsMap
            if (attWrapper.isMultilookup == true && partParams.multilookupAttToAssociatedPartsMap[attWrapper.attRef]) {
            
                CS.Log.warn('******** Multilookup found with associated parts: ' + partParams.multilookupAttToAssociatedPartsMap[attWrapper.attRef].length);
                
                var multilookupParts = partParams.multilookupAttToAssociatedPartsMap[attWrapper.attRef]; //list
                for (var i = 0; i <  multilookupParts.length; i++) {
                    var partId = multilookupParts[i];
                    
                    //Note: the multi lookup values should all be valid, as Configurator has filtered them
                    if (allReferencedPartWrappersMap[partId]) {
                        var retrievedPartWrapper = allReferencedPartWrappersMap[partId]; //type CS_PartWrapper
                                                
                        if (retrievedPartWrapper.part.Included_In_Regions__c && _.contains(retrievedPartWrapper.part.Included_In_Regions__c.split(','), regionCode)) {
                            var assPartInfo = new CS_PartInformation(retrievedPartWrapper, null, districtCode, 1, geographicUpliftFactor);                   // TO DO WAS CS_PartModelEntry.CS_PartInformation !!!
                            associatedParts.push(assPartInfo);      
                            
                            CS.Log.warn('*********** Assoc Part Added for ' + attWrapper.attRef + ' - ' + retrievedPartWrapper.part.Name);               
                        }
                        else {
                            CS.Log.warn('*********** Assoc Part Ignored for: ' + attWrapper.attRef + ' - '  + retrievedPartWrapper.part.Id + ' - ' + retrievedPartWrapper.part.Name);
                        }
                    }
                }
            }
            
            //For ParentParts & ParentBundles, build associatedPart list given the info in parentToAssociatedPartsMap
            //(attWrapper.isPart || attWrapper.isBundle) &&  : omitted as multilookup check goes first
            else if (partParams.parentToAssociatedPartsMap[attWrapper.attValue]) {
            
                //CS.Log.warn('*** ParentPart/Bundle found with associatedEntries: ' + parentToAssociatedPartsMap[attWrapper.attValue].length);
                
                var childrenParts = partParams.parentToAssociatedPartsMap[attWrapper.attValue]; //list
                for (var i = 0; i <  childrenParts.length; i++) {
                    var apw = childrenParts[i];
                    
                    //Note: not all AssociatedParts may be retrieved if they don't match the filter criteria
                    if (allReferencedPartWrappersMap[apw.associatedPartId]) {
                        var retrievedPartWrapper = allReferencedPartWrappersMap[apw.associatedPartId]; //type CS_PartWrapper
                           
                        CS.Log.warn('******* ' + attWrapper.attRef + ' - ' + retrievedPartWrapper.part.Included_In_Regions__c);
                                                
                        if (retrievedPartWrapper.part.Included_In_Regions__c && _.contains(retrievedPartWrapper.part.Included_In_Regions__c.split(','), regionCode)) {
                            var assPartInfo = new CS_PartInformation(retrievedPartWrapper, null, districtCode, apw.quantity, geographicUpliftFactor);                // TO DO WAS CS_PartModelEntry.CS_PartInformation !!!
                            associatedParts.push(assPartInfo);
                            
                            CS.Log.warn('******** Assoc Part Added for ' + attWrapper.attRef + ' - ' + retrievedPartWrapper.part.Name);
                        }
                        else {
                            CS.Log.warn('******** Assoc Part Ignored for: ' + attWrapper.attRef + ' - '  + retrievedPartWrapper.part.Id + ' - ' + retrievedPartWrapper.part.Name);
                        }
                    }
                }
            }        
            else {
                CS.Log.warn('********* No associated Parts found for: ' + attWrapper.attRef + ' - ' + attWrapper.attValue + ' ****');
            }
            
            // ---------------------------------------------------------------------------------------
            // ---------- Now create the entry (key of the Map will be the attRef) ------------------ 
            var entry = null; //type CS_PartModelEntry. Clear the entry
            
            //If parent is Part
            if (attWrapper.isPart == true && attWrapper.isMultilookup == false && isInArray(attWrapper.attValue, partParams.parentPartIds)) {
                
                //Configurator has already performed the eligibility checks otherwise this couldn't have been selected
                var parentPartWrapper = allReferencedPartWrappersMap[attWrapper.attValue] ? allReferencedPartWrappersMap[attWrapper.attValue] : null;  //type CS_PartWrapper
                
                if (!parentPartWrapper) { //is null
                    CS.Log.warn('***** problem with parentPart filtered out on the DB but not on Configurator: ' + attWrapper.attRef + ' with value ' + attWrapper.attValue);
                }
                
                //CS.Log.warn('***** parentPart is: ' + parentPartWrapper.part.Name);
                
                /// EXCEPTION HANDLING
                if (parentPartWrapper) {
                    entry = new CS_PartModelEntry(attWrapper, null, parentPartWrapper, associatedParts, pricebookType, districtCode, geographicUpliftFactor);
                
                    //AUTO PCBH3
                    //CS.Log.warn("+++MY4=="+parentPartWrapper.part.Part_Code__c);
                    if(parentPartWrapper.part.Part_Code__c=="P2276"){
                        existsPCBH3=true;
                        //CS.Log.warn("====FOUND P2276");
                    }
                }
            }
            //Else if parent is Bundle
            else if (attWrapper.isBundle == true  && isInArray(attWrapper.attValue, partParams.parentBundleIds)) {
                var parentBundle = partParams.allReferencedBundlesMap[attWrapper.attValue] ? partParams.allReferencedBundlesMap[attWrapper.attValue] : null; //type CS_Bundle__c
                
                if (parentBundle) { //will exist..
                    CS.Log.warn('****** parentBundle is: ' + parentBundle.Name);
                    delete parentBundle.CS_Bundle_Part_Associations__r; //remove this property! It is not needed
                    entry = new CS_PartModelEntry(attWrapper, parentBundle, null, associatedParts, pricebookType, districtCode, geographicUpliftFactor);
                }
                else {
                    CS.Log.warn('****** parentBundle is NOT retrieved as no Part association exist for the bundle');
                }
            }           
            else if (attWrapper.isMultilookup == true) {
                entry = new CS_PartModelEntry(attWrapper, null, null, associatedParts, pricebookType, districtCode, geographicUpliftFactor);
            }
            
            // If a Bundle has NO Associated Parts, then entry will be NULL here. Added this if statement (16 April)
            if (entry) {
                partModelInfo[attWrapper.attRef] = entry;
            }
            else {
                CS.Log.warn('**** Null entry found and was NOT added to the partsModel structure');
                CS.Log.warn('*** entry is ' + entry);
            }        
        }
    
        //Call here        
        partsModelJS = partModelInfo;

        //*SMFix
        latestPartsModelJS = partsModelJS;
        //endfix
        CS.Log.warn(partsModelJS);
        
        return Q.resolve(partParams);    
    };
    
    
    /**
     * Handles the retrieval of all information associated with the Parts in question
     * @param {Boolean} pricesAffected
     */
    window.doPriceUpdates = function doPriceUpdates(pricesAffected) {
        //Only if prices have been affected, proceed to recalculating prices (, allowances etc.)
        CS.indicator.start();
        CS.Log.warn('doPriceUpdates called...');
        CS.Log.warn('pricesAffected is: ' + pricesAffected);
        
        if (pricesAffected === true) {
            clearCustomerSignature(); //added 20 June. Allowances will be cleared so signature must be obtained again. This forces HSA to ensure all is configured as agreed (and re-configure allowances if needed)
            return createPricingScreens(); //this is async
        }
        else {
            //Still need to rebuild the Pricing blocks as LineItem Descriptions may have changed and need to be reflected
            //radiator price fix
            changeActualPlaceholder();
            
            calculatePricingScreenTotals();
            createPricingTables();
            createHSATotalsWithAllowances();
            createCustomerTotalsTable();
            createSkillsTable();
            
            CS.Log.warn('Completed createSkillsTable...');
            
            return Q.resolve();
        }
    }
    
    /**
     * Updates the shadow attributes to the latest values, for the next run.
     */
    window.updateAllowanceApplicabilityShadowAttributes = function updateAllowanceApplicabilityShadowAttributes() {
        CS.Log.warn('*** Updating Shadow attributes.. ');
        
        CS.setAttributeValue('HEAT_Pricebook_Shadow_0', CS.getAttributeValue('HEAT_Pricebook_0'));
        CS.setAttributeValue('Voucher_Number_Shadow_0', CS.getAttributeValue('Voucher_Number_0'));
        CS.setAttributeValue('Customer_Date_of_Birth_Shadow_0', CS.getAttributeValue('Customer_Date_of_Birth_0'));
        CS.setAttributeValue('Employee_ID_Shadow_0', CS.getAttributeValue('Employee_ID_0'));
    }
    
    /**
     * Creates and sets the next Quote's Reference. Called by Configurator Rule
     */
    window.setNextQuoteReference = function setNextQuoteReference() {
        var oppId = CS.getAttributeValue('CHI_Lead_Id_0'),
            oppNumber = CS.getAttributeValue('CHI_Lead_Number_0');
        
        if (!oppId || !oppNumber) {
            return;
        }
        CS.Log.warn('***** Opportunity Id is: ' + oppId);
           
        getQuoteCount(oppId).then(function (param) {
            var newRef = constructNextQuoteRef(param);
            
            CS.Log.warn('***** Quote Ref for this Quote is set to: ' + newRef);
            CS.setAttributeValue('Quote_Reference_0', newRef);
             
            return Q.resolve();
        })
        .fail(function(error) { CS.Log.error;});  
    };
 
    /**
     * Creates and sets the next Quote's Reference. Called by Configurator Rule
     * @param {String} oppId: the CHI Lead Id to retrieve and count existing Quotes for
     */
    window.getQuoteCount = function getQuoteCount(oppId) {
   
        var device = (navigator.device ? 'iPad' : 'Laptop');
        if (device == 'iPad') {
            return CS.DB.smartQuery("SELECT count(*) FROM {cscfga__Product_Basket__c} WHERE {cscfga__Product_Basket__c:cscfga__Opportunity__c} = '" + oppId + "'").then(function(qr) {
                return qr.getAll().then(function (results) {
                    var counter = results[0][0];
                    
                    CS.Log.warn('***** Quote Count retrieved: ' + counter);
                    return Q.resolve(counter);
                });
            });
        } else if (device == 'Laptop'){
            var deferred = Q.defer(); 
            CS.Log.warn('***** Now calling RemoteAction getQuoteCountOnOpportunity...');
          
            UISupport.getQuoteCountOnOpportunity(
                oppId,
                function (result, event) {
                    if (event.status) {
                        CS.Log.warn('***** Quote Count retrieved: ' + result);
                        deferred.resolve(result);
                    } else {
                        deferred.reject('Event failed');
                    }
                }
            );
            return deferred.promise;
        }
        throw 'Should not get here'; 
    };
 
    /**
     * Constructs the next Quote's Reference by concatenating 'C', the CHI Lead Number and a unique character
     * @param {Integer} quoteCount
     */
     window.constructNextQuoteRef = function constructNextQuoteRef(quoteCount) {
        CS.Log.warn('***** constructNextQuoteRef called...');
        
        var oppNumber = CS.getAttributeValue('CHI_Lead_Number_0'),
            finalChar = calcFinalChar(quoteCount),
            quoteRef = 'C' + oppNumber + finalChar;
        
        CS.Log.warn('***** quoteRef is: ' + quoteRef);
        return quoteRef;
    };
    
    /**
     * Calculates the final character of the quote reference.
     * @param {Integer} n Number of existing quotes.
     */
    window.calcFinalChar = function calcFinalChar(n){
        var lastCharArray = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".split('');
        
        if(n < lastCharArray.length) return lastCharArray[n];
        return calcFinalChar(Math.floor(n/lastCharArray.length)-1) + calcFinalChar(n % lastCharArray.length);
    };

    function StoresController() {};

    StoresController.prototype.getStorePackId = function(storeItemIndex) {
        var packId = '';

        var packReference = 'Stores_' + storeItemIndex + ':Pack_C_0';
        var packReferenceAlt = 'Stores_' + storeItemIndex + ':Packs_C_All_0';

        var packIdFirst = CS.getAttributeValue(packReference);
        var packIdAlt = CS.getAttributeValue(packReferenceAlt);

        if (packIdFirst != undefined && packIdFirst != '') {
            packId = packIdFirst;
        } else if (packIdAlt != undefined && packIdAlt != '') {
            packId = packIdAlt;
        }

        return packId;
    };

    StoresController.prototype.getStoreInstallationPackId = function(storeItemIndex) {
        var res = '';

        var packReference = 'Stores_' + storeItemIndex + ':Pack_C_Installation_Pack_0';
        var storeReference = 'Stores_' + storeItemIndex;

        var packWrapper = CS.getAttributeWrapper(storeReference);

        if (packWrapper == undefined) {
            return undefined;
        }

        packId = CS.getAttributeValue(packReference);

        if (packId != undefined && packId != '') {
            res = packId;
        }

        return res;
    };

    StoresController.prototype.storePackType = function(storeItemIndex) {
        var packRef = 'Stores_' + storeItemIndex + ':Pack_C_0';
        var id = CS.getAttributeValue(packRef);

        if (id != undefined && id != '') {
            return 'pack';
        }

        var packInstallRef = 'Stores_' + storeItemIndex + ':Pack_C_Installation_Pack_0';
        id = CS.getAttributeValue(packInstallRef);

        if (id != undefined && id != '') {
            return 'install pack';
        }

        var globalPack = 'Stores_' + storeItemIndex + ':Packs_C_All_0';
        id = CS.getAttributeValue(globalPack);

        if (id != undefined && id != '') {
            return 'global pack';
        }

        return '';
    };

    StoresController.prototype.getStoreGlobalPackId = function(storeItemIndex) {
        var packId = '';

        var packReferenceAlt = 'Stores_' + storeItemIndex + ':Packs_C_All_0';

        var packIdAlt = CS.getAttributeValue(packReferenceAlt);

        if (packIdAlt != undefined && packIdAlt != '') {
            packId = packIdAlt;
        }

        return packId;
    };


    StoresController.prototype.getStorePackWrapper = function(storeItemIndex, packType) {
        var packReference = 'Stores_' + storeItemIndex + ':Pack_C_0';

        if (packType == 'install pack' ) {
            packReference = 'Stores_' + storeItemIndex + ':Pack_C_Installation_Pack_0';
        } else if (packType == 'global pack') {
            packReference = 'Stores_' + storeItemIndex + ':Packs_C_All_0';
        }

        var packWrapper   = CS.getAttributeWrapper(packReference);

        return packWrapper;        
    };

    StoresController.prototype.getStoreGlobalPackWrapper = function(storeItemIndex) {
        var packReference = 'Stores_' + storeItemIndex + ':Packs_C_All_0';

        var packWrapper   = CS.getAttributeWrapper(packReference);

        return packWrapper;     
    };

    StoresController.prototype.getStoreInstallPackWrapper = function(storeItemIndex) {
        var packReference = 'Stores_' + storeItemIndex + ':Pack_C_Installation_Pack_0';

        var packWrapper   = CS.getAttributeWrapper(packReference);

        return packWrapper;     
    };

    var storesCtrl = new StoresController();

    window.lastRuleStores = function lastRuleStores() {

        for (var j = 0; j < CS.getAttributeWrapper('Stores_0').relatedProducts.length; j++)
        {


            var testAllSTORE = CS.getAttributeValue('Stores_' + j + ':Packs_C_All_0');
            if (testAllSTORE != undefined && testAllSTORE != '') {
                CS.setAttributeValue('Stores_' + j + ':Pack_C_0', testAllSTORE);
            }
            // check and process manadatory packs

            var storePackId = storesCtrl.getStorePackId(j);

            if (storePackId == '') {
                continue;
            }

            CS.Log.info('storePackId ' + storePackId);

            getRequiredInstallationPacks(storePackId)
            .then(function(records) {
                var type = typeof records;
                return processMandatoryAssociationsPack(records);
            })
            .catch(function(e) {
                CS.Log.error('error in getRequiredInstallationPacks');
                CS.Log.error(e);
            })
            .done();
        }

        for (var i = 0; i < CS.getAttributeWrapper('Stores_0').relatedProducts.length; i++) {

            var packType = storesCtrl.storePackType(i);

            // workaround for clearing pack name if alternative pack selection method is used

            var storePackIdAlt          = storesCtrl.getStoreGlobalPackId(i);
            var storeInstallPackId      = storesCtrl.getStoreInstallationPackId(i);

            if (packType == '') {
                continue;
            }

            var storePackWrapper        = storesCtrl.getStorePackWrapper(i, packType);
            var storeGlobalPackWrapper  = storesCtrl.getStoreGlobalPackWrapper(i);
            var storeInstallPackWrapper  = storesCtrl.getStoreInstallPackWrapper(i);

            if (storePackIdAlt != '' && storePackWrapper != undefined) {
                storePackWrapper.attr.cscfga__Display_Value__c = storeGlobalPackWrapper.attr.cscfga__Display_Value__c;
            }
            else if (storeInstallPackId != '' && storePackWrapper != undefined) {
                storePackWrapper.attr.cscfga__Display_Value__c = storeInstallPackWrapper.attr.cscfga__Display_Value__c;
            }

            // automatically set category and subcategory picklists if all packs lookup has been used to set the store pack

            var allStoresTest = CS.getAttributeValue('Stores_' + i + ':Packs_C_All_0');
            
            var subcat = CS.getAttributeValue('Stores_' + i + ':Packs_C_All_Subcategory_0');

            var cat = CS.getAttributeValue('Stores_' + i + ':Packs_C_All_Category_0');
            var catBackup = CS.getAttributeValue('Stores_' + i + ':Pack_C_Category_0');

            if (cat != undefined && cat != '' && allStoresTest != '' && allStoresTest != undefined) {
                CS.setAttributeValue('Stores_' + i + ':Pack_C_Category_0', cat);
                CS.setAttributeValue('Stores_' + i + ':Category_0', cat);
            }

            if (subcat != undefined && subcat != '' && allStoresTest != '' && allStoresTest != undefined) {
                CS.constrainList('Stores_' + i + ':Pack_C_Subcategory_0', [['--None--','--None--'],
                                                                           ['Additional Labour','Additional Labour'],
                                                                           ['Back Panel and Hearths','Back Panel and Hearths'],
                                                                           ['Bespoke Horizontal Flue','Bespoke Horizontal Flue'],
                                                                           ['Bespoke Vertical Flue','Bespoke Vertical Flue'],  
                                                                           ['Building Work','Building Work'], 
                                                                           ['Combisave','Combisave'],
                                                                           ['Customer Controls','Customer Controls'],
                                                                           ['Cylinders','Cylinders'],
                                                                           ['Cylinders (Thermal Store)','Cylinders (Thermal Store)'],
                                                                           ['Cylinders (Unvented)','Cylinders (Unvented)'],
                                                                           ['Designer Radiator Valves','Designer Radiator Valves'],
                                                                           ['Disconnections and Removals','Disconnections and Removals'],
                                                                           ['Electrical','Electrical'],
                                                                           ['Filter','Filter'],
                                                                           ['Fires','Fires'],
                                                                           ['Frost Protection','Frost Protection'],
                                                                           ['Hearths','Hearths'],
                                                                           ['Mantels','Mantels'],
                                                                           ['Miscellaneous','Miscellaneous'],
                                                                           ['Pipe Insulation','Pipe Insulation'],
                                                                           ['Pipe Trunking','Pipe Trunking'],
                                                                           ['Pipework','Pipework'],
                                                                           ['Powercleanse','Powercleanse'],
                                                                           ['Powerflush','Powerflush'],
                                                                           ['Pressure Vessels','Pressure Vessels'],
                                                                           ['Pump and Valves','Pump and Valves'],
                                                                           ['Radiator Valves','Radiator Valves'],
                                                                           ['Scale Reducers','Scale Reducers'],
                                                                           ['Showers (Electric)','Showers (Electric)'],
                                                                           ['Showers (Gravity/Mains)','Showers (Gravity/Mains)'],
                                                                           ['Showers (Power)','Showers (Power)'],
                                                                           ['Showers (Pump)','Showers (Pump)'],
                                                                           ['Standard Radiator Valves','Standard Radiator Valves'],
                                                                           ['Stand Off Brackets','Stand Off Brackets'],
                                                                           ['Tanks','Tanks'],
                                                                           ['Thermostatic Radiator Valves','Thermostatic Radiator Valves'],
                                                                           ['Warranties and Homecare','Warranties and Homecare'],
                                                                           ['Water Heater','Water Heater'],
                                                                           ['Water Softeners','Water Softeners']
                                                                           ]);

                CS.setAttributeValue('Stores_' + i + ':Pack_C_Subcategory_0', subcat);

                CS.setAttributeValue('Stores_' + i + ':Subcategory_0', subcat);
            }
            var storePackWrapperDel = storesCtrl.getStorePackWrapper(i, 'pack');
            var storesBackDel = CS.getAttributeValue('Stores_' + i + ':Pack_C_0')
            if(storesBackDel==''){
                storePackWrapperDel.attr.cscfga__Display_Value__c = '';
            }

            CS.setAttributeValue('Stores_' + i + ':Packs_C_All_Subcategory_0', '');
            CS.setAttributeValue('Stores_' + i + ':Packs_C_All_Category_0', '');
            CS.setAttributeValue('Stores_' + i + ':Packs_C_All_0', '');

        }
    };

    window.getStorePackItemQuantity = function(storeItemIndex) {
        var quantity = 0;

        var quantityReference = 'Stores_' + storeItemIndex + ':Pack_C_Quantity_0';

        var quantityValue = CS.getAttributeValue(quantityReference);

        if (quantityValue != undefined && quantityValue != '') {
            quantity = quantityValue;
        }

        return quantity;
    };

    window.getStorePackQuantity = function(storePackId) {
        var quantity = 0;

        var storeItemIndex = 0;

        while(true) {
            var packId = storesCtrl.getStorePackId(storeItemIndex);

            if (packId == '') {
                break;
            }

            if (packId == storePackId) {
                quantity += Number( getStorePackItemQuantity(storeItemIndex) );
            }

            storeItemIndex++;
        }

        return quantity;
    };

    window.getStoreInstallationPackQuantity = function(storePackId) {
        var quantity = 0;

        var storesCount = CS.getAttributeWrapper('Stores_0').relatedProducts.length;

        for (var i = 0; i < storesCount; i++) {
            if ( storesCtrl.storePackType(i) != 'install pack') {
                continue;
            }
            var packId = storesCtrl.getStoreInstallationPackId(i);

            if (packId == storePackId) {
                quantity += Number( getStorePackItemQuantity(storeItemIndex) );
            }
        }

        return quantity;
    };

    window.getRequiredInstallationPacks = function(packId) {
        CS.Log.info('***** getRequiredInstallationPacks called: ' + packId);

        var deferred = Q.defer();

        if (navigator.device) {
            // ipad

            var query = "SELECT {CS_Part_Association__c:_soup} FROM {CS_Part_Association__c} WHERE {CS_Part_Association__c:Part_1__c} = '" + packId + "'" + " AND {CS_Part_Association__c:Relationship__c} = 'Requires This Pack Or Other With Same Relationship Type'";

            CS.Log.info(query);

            CS.DB.smartQuery("SELECT {CS_Part_Association__c:_soup} FROM {CS_Part_Association__c} WHERE {CS_Part_Association__c:Part_1__c} = '" + packId + "'" + " AND {CS_Part_Association__c:Relationship__c} = 'Requires This Pack Or Other With Same Relationship Type'")
            .then(function(qr) {
                return qr.getAll().then(function (results) {
                    CS.Log.info('***** associated parts retrieved: ' + results);
                    return deferred.resolve(results);
                });
            })
            .fail(function(e) {
                CS.Log.error('error in CS.DB.smartQuery');
                CS.Log.error(e);
            });

            return deferred.promise;

        } else {
            // online
            var parentPartIds = [];
            parentPartIds.push(packId);

            UISupport.getPartsWithAssociationsOfType(
                parentPartIds, 'Requires This Pack Or Other With Same Relationship Type',
                function (result, event) {
                    if (event.status) {
                        CS.Log.info('mandatory associated parts retrieved: ' + result.length);
                        deferred.resolve(result);
                    }
                    else {
                        deferred.reject('part association query failed');
                    }
                }
            );

            return deferred.promise;
        }

        return deferred.promise;
    };
    
    window.processMandatoryAssociationsPack = function(packAssociations) {
        var deferred = Q.defer();

        var counter = packAssociations.length;
        
        //CS.Log.warn('***** Part Association count for pack ' + window.storePackId + ' with relationship type \'Requires This Pack Or Other With Same Relationship Type\': ' + counter);
        //CS.Log.warn(packId);
        
        if (counter == 0) {
            return deferred.resolve();
        }

        CS.Log.warn('packAssociations');
        CS.Log.warn(packAssociations);
        var flatResultsArray = _.flatten(packAssociations);
        CS.Log.warn('flatResultsArray');
        CS.Log.warn(flatResultsArray);

        var relatedPacks = _.pluck(flatResultsArray, 'Part_2_Name__c');

        var parentPackIds = _.pluck(flatResultsArray, 'Part_1__c');
        var parentPackId = _.uniq(parentPackIds)[0];
        CS.Log.warn('parentPackId');
        CS.Log.warn(parentPackId);

        var dependentPackCount = getStorePackQuantity(parentPackId);

        var dependeePackIds = _.pluck(flatResultsArray, 'Part_2__c');
        CS.Log.warn('dependeePackIds');
        CS.Log.warn(dependeePackIds);

        var dependeePackCount = 0;
        dependeePackIdsUniq = _.uniq(dependeePackIds);
        dependeePackIdsUniq.forEach(function(packId) {
            dependeePackCount += Number(getStoreInstallationPackQuantity(packId));
        });        

        CS.Log.warn('dependentPackCount');
        CS.Log.warn(dependentPackCount);

        CS.Log.warn('dependeePackCount');
        CS.Log.warn(dependeePackCount);

        if (dependeePackCount >= dependentPackCount) {
            return deferred.resolve();
        }
        
        var popUpMessageContent = 'Please select one of mandatory installation packs: ';

        relatedPacks.forEach(function(packName) { popUpMessageContent += packName + ', '; });

        CS.markConfigurationInvalid(popUpMessageContent.trim());

        return deferred.resolve();
    };
});

window.openPlanningScreenSF = function openPlanningScreenSF(){
    var skillsParameters = "";
    //var url = "https://eu3.salesforce.com/apex/ReadParametersfromURL?";
    
    for (var key in skillsPerGroup) {
        try{
            var obj = skillsPerGroup[key].skillCode;
            skillsParameters += skillsPerGroup[key].skillCode+'='+skillsPerGroup[key].amount.toFixed(2)+"/";
        }
        catch(err){}
    }
  
    var INST ='';
    try{
         INST = CS.Service.config["Boiler_0:System_Type_0"].attr.cscfga__Display_Value__c;
         if(INST.split(' ')[0]!=""){
            INST='InstType='+INST.split(' ')[0]+'/';
         }
         
    }
   catch(err){
      INST =''; 
   }
   
   var LOC ='';
    try{
         LOC = CS.Service.config["Boiler_0:Location_Type_0"].attr.cscfga__Display_Value__c;
         if(LOC.split(' ')[0]!=""){
         LOC = 'Bloc='+LOC.split(' ')[0]+'/';
        }
    }
   catch(err){
      LOC =''; 
   }
   
   var preElec='';
   
   var HA = partCodeExistsInPartsModelJS("P200") ? 'HA=yes/' : '';

   if(partCodeExistsInPartsModelJS("P2969")){
        preElec="PreElec=Yes/";
   }
    
    var CHIL = "lead="+CS.Service.config["CHI_Lead_Number_0"].attr.cscfga__Display_Value__c+'/';

    var url= "https://eu13.salesforce.com/apex/ReadParametersfromURL?"+CHIL+skillsParameters+LOC+INST+preElec+HA;
    //var url= "https://cs107.salesforce.com/apex/ReadParametersfromURL?"+CHIL+skillsParameters+LOC+INST+preElec+HA;
    console.log(url);
    if(navigator.device){
        cordova.exec(function(result) {console.log(result);}, function(e){console.log(e);}, 'DSANavigationPlugin', 'openURL', [url+',true,true']);
    }
    else{
        window.open(url, '_blank');
        CS.Log.warn('ONLINE VERSION');
    }
}

window.checkIfPlanningScreenRestricted = function checkIfPlanningScreenRestricted(){
        if(navigator.device){
            setTimeout(function(){
                     jQuery('#btn-open-planning').show();
                 }, 0);
            
        }
        else{
            jQuery('#btn-open-planning').hide();
        }
        
}

window.checkIfNewQuoteRestricted = function checkIfNewQuoteRestricted(){
    
    if(CS.Service.getCurrentScreenRef().indexOf("Planning")!=-1){
        
        //hide accept quote button
        setTimeout(function(){
                     jQuery('#btn-acceptquote').hide();
                 }, 0);
        
        if(navigator.device){
            setTimeout(function(){
            jQuery('#btn-acceptquote').before(jQuery('#new-quote-btn-test'));
            jQuery('#btn-customer-confirmation-form').before(jQuery('#btn-installation-form'));
            jQuery('#btn-quotepdf-preprinted').hide();
            jQuery('#btn-quotepdf').hide();
            jQuery('#btn-customer-confirmation-form').hide();
            jQuery('#btn-finance-illustration-pdf').hide();
            jQuery('#btn-acceptquote').hide();
             }, 0);
        }
    }
}

window.executeVulnerableCustomersRules = function executeVulnerableCustomersRules(){
    
    var currentVulnerableCustomer = CS.getAttributeValue('Vulnerable_Customer_0');
    var confirmedHSC = CS.getAttributeValue('Confirm_HSC_rating_0');
    
    if(((confirmedHSC=='Yes')||(confirmedHSC=='--None--'))&&(currentVulnerableCustomer=='Yes')){
        var currentReason = CS.getAttributeValue("Vulnerable_Reasons_0");
        if(currentReason == '--None--'){
            getDynamicLookupValue('OpportunityQuery', 'Vulnerable_reason__c').then(function(x) { CS.setAttributeValue("Vulnerable_Reasons_0", x);});
        }
    }

    if(currentVulnerableCustomer!='Yes'){
        CS.disableAttribute('Vulnerable_Reasons_0');
        //CS.setAttributeValue("Vulnerable_Reasons_0", '--None--');
    }
    
    
    executeVulnerableCustomerRules();
    
    // TS 14.06.2017 ---- Interest Free Credit, isEligibleForIFC() is defined in CS_quotePdf
    var ifcNeedsText = 'Eligible for Interest Free Credit';
    var needsValue = CS.getAttributeValue('Needs_0');
    if (isEligibleForIFC() && needsValue === "") {
        CS.setAttributeValue('Needs_0', ifcNeedsText);
    } else if (isEligibleForIFC() === false && needsValue.includes(ifcNeedsText)) {
        needsValue = needsValue.replace(ifcNeedsText, "");
        CS.setAttributeValue('Needs_0', needsValue);
    }
    
    // TS 15.08.2017 ---- Don't allow finishing the incomplete quote even if the status is "Not Accepted" (this must be here otherwise the product definition must be changed)
    if (navigator.device) { // make sure we're running on iPad
        
        var quoteStatus = CS.getAttributeValue('Quote_Status_0');
        
        if (CS.getAttributeValue('Boiler_0:Filling_Loop_Select_0') === 'Please select') { 
            CS.markConfigurationInvalid('','Please select filling loop on boiler'); 
        }
        
        if (quoteStatus == 'Quote Finalised - Not Accepted') {
            
            var havePdfQuote = CS.getAttributeValue('Pdf_Path_0');
            var haveInstallationNotes = CS.getAttributeValue('Installation_Form_Path_0');
            
            
            havePdfQuote = havePdfQuote != undefined ? havePdfQuote.length > 0 : false;
            haveInstallationNotes = haveInstallationNotes != undefined ? haveInstallationNotes.length > 0 : false;
            
            if (!havePdfQuote) {
                CS.markConfigurationInvalid('', 'Please tap the "Print Quote" button');
            }
            
            if (!haveInstallationNotes) {
                CS.markConfigurationInvalid('', 'Please tap the "Installation Notes" button');
            }
            var configStatus = CS.getConfigurationProperty('', 'status');
            console.log('***** configStatus: ' + configStatus)
            if (configStatus == 'Incomplete' || configStatus == 'Invalid') {
                jQuery("button:contains('Finish')").hide();
            }
          
        }
    }

    /*
    var inTrialRegion = true;
    
    //trial regions removed on 3-10-2016
    if(inTrialRegion == true){
        executeVulnerableCustomerRules();
    }
    */
}

window.selectedReasonInVulnerableReasons = function selectedReasonInVulnerableReasons(){
    var vulnerableReasonSelected = false;
    
    var selectedReason = CS.getAttributeValue("Vulnerable_Reasons_0");
    
    if((selectedReason == '75 and over') || 
    (selectedReason == 'Families with children under 5') || 
    (selectedReason == 'Cancer') || 
    (selectedReason == 'Heart condition') || 
    (selectedReason == 'Lung conditions') || 
    (selectedReason == 'Dementia') || 
    (selectedReason == "Alzheimer's") || 
    (selectedReason == 'Wheelchair user') || 
    (selectedReason == 'Confined to bed') || 
    (selectedReason == 'Arthritis') || 
    (selectedReason == 'Post op recovery') || 
    (selectedReason == 'Leukaemia')){
        vulnerableReasonSelected = true;
         CS.Log.warn("**** GEO VULNERABLE CUSTOMERS - SELECTED REASON");
    }
    
    if(vulnerableReasonSelected == true){
        CS.Log.warn("**** GEO VULNERABLE CUSTOMERS - RIGHT REASON HAS BEEN SELECTED");
    }
    
     if(vulnerableReasonSelected == false){
        CS.Log.warn("**** GEO VULNERABLE CUSTOMERS - RIGHT REASON HAS NOT !!!!! BEEN SELECTED");
    }
    
    return vulnerableReasonSelected;
}

window.executeVulnerableCustomerRules = function executeVulnerableCustomerRules(){
    var boilerWorking = CS.getAttributeValue("Boiler_Working_0");
    var hotWaterAvailable = CS.getAttributeValue("Hot_Water_Available_0");
    var otherFormOfHeating = CS.getAttributeValue("Other_Form_of_Heating_0");;
    var inVulnerableReasons = selectedReasonInVulnerableReasons();
    
    CS.Log.warn("**** GEO VULNERABLE CUSTOMERS - EXECUTING RULES");
    
    //CATEGORY 1
    //Boiler Working = true AND Hot Water Available = true
    if(((boilerWorking == "No") && (otherFormOfHeating == "No") && (hotWaterAvailable == "No") && (inVulnerableReasons == true)) 
    || ((boilerWorking == "No") && (otherFormOfHeating == "No") && (hotWaterAvailable == "Yes") && (inVulnerableReasons == true))) {
        CS.Service.config["Latest_Customer_Category_0"].attr.cscfga__Is_Read_Only__c = false;
        CS.setAttributeValue("Latest_Customer_Category_0", "1");
        CS.Service.config["Latest_Customer_Category_0"].attr.cscfga__Is_Read_Only__c = true;
        CS.Log.warn('**** GEO VULNERABLE CUSTOMERS -- SET TO 1');
    }
   
    //CATEGORY 2
    else if(((otherFormOfHeating == "No") && (boilerWorking == "No") && (hotWaterAvailable == "No") && (inVulnerableReasons == false)) 
    ||((otherFormOfHeating == "No") && (boilerWorking == "No") && (hotWaterAvailable == "Yes") && (inVulnerableReasons == false))
    ||((otherFormOfHeating == "No") && (boilerWorking == "Yes") && (hotWaterAvailable == "No") && (inVulnerableReasons == true))
    ||((otherFormOfHeating == "Yes") && (boilerWorking == "No") && (hotWaterAvailable == "No") && (inVulnerableReasons == true))
    ||((otherFormOfHeating == "Yes") && (boilerWorking == "No") && (hotWaterAvailable == "Yes") && (inVulnerableReasons == true))
    ||((otherFormOfHeating == "Yes") && (boilerWorking == "Yes") && (hotWaterAvailable == "No") && (inVulnerableReasons == true))) {
        CS.Service.config["Latest_Customer_Category_0"].attr.cscfga__Is_Read_Only__c = false;
        CS.setAttributeValue("Latest_Customer_Category_0", "2");
        CS.Service.config["Latest_Customer_Category_0"].attr.cscfga__Is_Read_Only__c = true;
        CS.Log.warn('**** GEO VULNERABLE CUSTOMERS -- SET TO 2');
    }
    
    //CATEGORY 3
    else if(((otherFormOfHeating == "No") && (boilerWorking == "Yes") && (hotWaterAvailable == "No") && (inVulnerableReasons == false))
    ||((otherFormOfHeating == "Yes") && (boilerWorking == "No") && (hotWaterAvailable == "No") && (inVulnerableReasons == false))
    ||((otherFormOfHeating == "Yes") && (boilerWorking == "No") && (hotWaterAvailable == "Yes") && (inVulnerableReasons == false))
    ||((otherFormOfHeating == "Yes") && (boilerWorking == "Yes") && (hotWaterAvailable == "No") && (inVulnerableReasons == false))) {
         CS.Service.config["Latest_Customer_Category_0"].attr.cscfga__Is_Read_Only__c = false;
        CS.setAttributeValue("Latest_Customer_Category_0", "3");
        CS.Service.config["Latest_Customer_Category_0"].attr.cscfga__Is_Read_Only__c = true;
        CS.Log.warn('**** GEO VULNERABLE CUSTOMERS -- SET TO 3');
    }
    
    //CATEGORY 4
    else if(((otherFormOfHeating == "No") && (boilerWorking == "Yes") && (hotWaterAvailable == "Yes") && (inVulnerableReasons == false))
    ||((otherFormOfHeating == "No") && (boilerWorking == "Yes") && (hotWaterAvailable == "Yes") && (inVulnerableReasons == true))
    ||((otherFormOfHeating == "Yes") && (boilerWorking == "Yes") && (hotWaterAvailable == "Yes") && (inVulnerableReasons == false))
    ||((otherFormOfHeating == "Yes") && (boilerWorking == "Yes") && (hotWaterAvailable == "Yes") && (inVulnerableReasons == true))) {
        CS.Service.config["Latest_Customer_Category_0"].attr.cscfga__Is_Read_Only__c = false;
        CS.setAttributeValue("Latest_Customer_Category_0", "4");
        CS.Service.config["Latest_Customer_Category_0"].attr.cscfga__Is_Read_Only__c = true;
        CS.Log.warn('**** GEO VULNERABLE CUSTOMERS -- SET TO 4');
    }
    
    else{
        CS.Log.warn('**** GEO VULNERABLE CUSTOMERS -- NO MATCHNG CONDITIONS');
    }
    
}



window.isInTrialRegionDeposit = function isInTrialRegionDeposit(){
    var inRegion = false;
    if((CS.getAttributeValue("Geographic_Region_0")=="North") || (CS.getAttributeValue("Geographic_Region_0") == "Scotland")|| (CS.getAttributeValue("Geographic_Region_0") == "Central")|| (CS.getAttributeValue("Geographic_Region_0") == "South West")){
        inRegion = true;
        CS.Log.warn('****   In trial region for actual deposit');
        
    }
    return inRegion;
}


window.geographicDepositValidation = function geographicDepositValidation(){
    // 2018-08-22 Minimum deposit set to %, NOT 0 (commented below code)
    triggerActualDepositValidation();

    /*
    //set minimum deposit to 0
        //CS.setAttributeValue('Minimum_Deposit_0',0);
        //CS.Log.warn('****    Minimum deposit set to 0');
        
         if(!enableDepositValidation()){
        //set minimum deposit to 0
        CS.setAttributeValue('Minimum_Deposit_0',0);
        CS.Log.warn('****    Minimum deposit set to 0');
        }
        else{
            //execute rule for minimum deposit being greated than actual deposit
            //sequence 98
            triggerActualDepositValidation();
        }
    */
    
    /*
    if(isInTrialRegionDeposit()){
        //set minimum deposit to 0
        CS.setAttributeValue('Minimum_Deposit_0',0);
        CS.Log.warn('****    Minimum deposit set to 0');
    }
    else{
        //execute rule for minimum deposit being greated than actual deposit
        //sequence 98
        triggerActualDepositValidation();
    }
    */
}

window.enableDepositValidation = function enableDepositValidation(){
    var enableDepositValidation = false;
    if (CS.Service.config[""].config.Name.indexOf('Straight Swaps')!=-1){
        enableDepositValidation = true;
    }
    return enableDepositValidation;
}

function triggerActualDepositValidation(){
    CS.Log.warn('****    Executing rule for actual deposit greater than minimum deposit validation- !!!');
    var actDep = parseFloat(CS.getAttributeValue('Actual_Deposit_0'));
    var minDep = parseFloat(CS.getAttributeValue('Minimum_Deposit_0'));
    //When {Heating Solution:Quote Status} is not 'Quote Finalised - Not Accepted' AND {Heating Solution:Actual Deposit} is less than '{Minimum Deposit}' AND {Heating Solution:Payment Method} is not 'Finance' -> Mark Configuration Invalid.
    if((CS.getAttributeValue('Quote_Status_0')!='Quote Finalised - Not Accepted') && (actDep < minDep) && (CS.getAttributeValue('Payment_Method_0')!='Finance')){
        CS.markConfigurationInvalid('To sell the quote the preferred deposit cannot be less than the minimum deposit, unless payment option is finance package.');
    }

}

window.setWorldpayButtonVisibility = function() {
    console.log("setWorldpayButtonVisibility()");
    //jQuery("#btn-worldpay-payment").hide();
    if (navigator.device) {
        jQuery('[data-cs-binding=' +'Worldpay_Payment_0]').hide();
    } else {
        jQuery('[data-cs-binding=' +'Worldpay_Payment_0]').parent().parent().hide(); 
    }

    var screenRef = CS.Service.getCurrentScreenRef().split(":")[1];


    if (navigator.device && screenRef === "Deposit_and_Payment") {
      var paymentType = CS.getAttributeValue("Payment_Type_0");
      var depositRecNum = CS.getAttributeValue("Deposit_Receipt_Number_0");
      var epdq = CS.getAttributeValue("EPDQ_reference_number_0");
      var applicablePaymTypes = ["Credit Card", "Debit Card"];
      var correctType = applicablePaymTypes.indexOf(paymentType) > -1;
      //var isButtonVisible = isAllowed  && correctType && depositRecNum.length == 11 && epdq.length === 0;
      var showButton = correctType && depositRecNum.length == 11 && epdq.length === 0;
      var depositNumberValid = CS.getAttributeField('Deposit_Receipt_Number_0', 'Valid');
      console.log("showButton="+showButton)
      if (showButton && depositNumberValid != 'False') {
        //jQuery("#btn-worldpay-payment").show();

        if (navigator.device) {
            jQuery('[data-cs-binding=' +'Worldpay_Payment_0]').show();
        } else {
            jQuery('[data-cs-binding=' +'Worldpay_Payment_0]').parent().parent().show(); 
        }
      }
    }

    /* doesn't work
    var btnElement = jQuery("#btn-worldpay-payment");
    var depositNumberValid = CS.getAttributeField('Deposit_Receipt_Number_0', 'Valid');

    if (btnElement && btnElement.length > 0) {
        if (depositNumberValid == 'False') {
            btnElement[0].style.opacity = ".2";
            document.getElementById('btn-worldpay-payment').disabled = true;
        } else {
            btnElement[0].style.opacity = "1";
            document.getElementById('btn-worldpay-payment').disabled = false;
        }
    }
    */

};

window.startWorldPayPayment = function() {
  var DSAWorldPayPlugin = function() {};

  var outParams = {
    "BGS_Payment_Reference_Num__c": CS.getAttributeValue("Deposit_Receipt_Number_0"),
    "Amount__c": "" + CS.getAttributeValue("Actual_Deposit_0"),
    "CustomerName": CS.getAttributeValue("Customer_Name_0"),
    "CustomerAddress": CS.getAttributeValue("Customer_Address_0"),
    "CHI_Lead_Number": CS.getAttributeValue("CHI_Lead_Number_0"),
    "PaymentType": CS.getAttributeValue("Payment_Type_0")
  };

  var errHandler = function(errstr) {
    alert(errstr);
  };

  var successHandler = function(res) {
    // TODO: Handle the plugin result
    var CORRECT_STATUS = "Approved Online";
    CS.setAttributeValue("EPDQ_reference_number_0", res.EPDQ_Authorisation__c);
    CS.setAttributeValue("Payment_Gateway_Reference_Number_0", res.Payment_Gateway_Reference_Number__c);
    CS.setAttributeValue("Payment_Gateway_0", res.Payment_Gateway__c);
    CS.setAttributeValue("Transaction_Status_0", res.Transaction_Status__c);

    if (res.Transaction_Successful__c) {
      // set "deposit details" inputs read only
      CS.setAttributeValue("Worldpay_Plugin_Sent_Data_0", "true");
    } 
    console.log("***Result from Worldpay plugin: " + JSON.stringify(res));
  };

  DSAWorldPayPlugin.prototype.worldPayPayment = function(success,error,params) {
      console.log("Calling worldPayPayment");
      console.log("Params:" + params);
      cordova.exec(function(result) { success(result); }, error, 
        "DSAWorldPayPlugin", "worldPayPayment", [params]);
  };
  
  // First save the quote (requires app version 1.0.93 and newer)
  CS.saveBasket();

  // instantiate the plugin object
  var wpplug = new DSAWorldPayPlugin();

  // call the plugin
  wpplug.worldPayPayment(successHandler, errHandler, JSON.stringify(outParams));
}



window.testIfS = function testIfS(){
    console.log('Synced');
}

// TS. 3.10.2017. -- invalidate quote if not complete, even for non-sold quote (Not Accepted)

window.invalidateForNonSold = function invalidateForNonSold() { 
  
  // Temporary workaround for required attribute validation
  // until proper validation is implemented

  /**
   * Returns an array of all required attributes in the solution which need to be populated.
   * @return {Array} An array of attributes.
   */
  function _getEmptyRequiredAttributes() {
    return _.filter(CS.Service.config, function(it) {
      if (it && it.attr && it.attr.cscfga__Is_Required__c && it.displayInfo) {
        return ((it.attr.cscfga__Is_Required__c === true) && (it.displayInfo != 'Related Product')) && 
        ((it.attr.cscfga__Value__c === '') || 
        (it.attr.cscfga__Value__c === null) || 
        (it.attr.cscfga__Value__c == '--None--'));
      }
    });
  }

  /**
   * Constructs a message with all of the required attributes.
   * Displays a message for the user to know which attributes need to be populated.
   * Marks the configuration invalid until all of the required attributes are populated.
   */
  function displayRequiredAttributeMessages() {
    var requiredAttributes = _getEmptyRequiredAttributes();
    var requiredAttributesMessages = '';
    _.each(requiredAttributes, function(it) {
      requiredAttributesMessages += '"' + it.attr.Name + '" value is required. ';
    });
    if (requiredAttributesMessages.length) {
      CS.markConfigurationInvalid('', requiredAttributesMessages);
    }
  }
  
  var configStatus = CS.getConfigurationProperty('', 'status');
  var quoteStatus = CS.getAttributeValue('Quote_Status_0');
  var pdfStatus = CS.getAttributeValue('Pdf_Signed_0');
  var paymentMethod = CS.getAttributeValue('Payment_Method_0');

  var installationNotesSigned = CS.getAttributeValue('Installation_Form_Signed_0');

  // Temporary workaround for required attribute validation
  // until proper validation is implemented
  if (quoteStatus == 'Quote Finalised - Not Accepted') {
    displayRequiredAttributeMessages();
  }
  if (CS.getAttributeDisplayValue('Boiler_0') != undefined) {
      if (quoteStatus == 'Quote Finalised - Not Accepted' ) {

          if (configStatus != 'Valid') {
              jQuery("button:contains('Finish')").hide();
              
              CS.displayInfo('Configuration cannot be finished with \'Quote Finalised - Not Accepted\' status while you have unresolved errors.');
          } 
      }
      
      if (quoteStatus == 'Quote Finalised - Not Accepted' || quoteStatus == 'Quote Finalised - Accepted') {
          
          if (CS.getAttributeValue('Boiler_0') !== undefined && CS.getAttributeDisplayValue('Boiler_0:Controls_0') === '' && !CS.getAttributeValue('Boiler_0:Use_Existing_Controls_0')) { 
              console.log('***** Invalidate config must select controls or use existing');
              jQuery("button:contains('Finish')").hide();
              CS.markConfigurationInvalid("Please select Boiler Controls");
          } 
      }

      if (CS.getAttributeValue('Boiler_0') !== undefined && CS.getAttributeDisplayValue('Boiler_0:Controls_0') != '' && CS.getAttributeValue('Boiler_0:Use_Existing_Controls_0')) { 
        jQuery("button:contains('Finish')").hide();
        CS.markConfigurationInvalid("");
      } 
  }
  
  
  
}

window.validateForNonSold = function validateForNonSold(){ 
    if((CS.Service.config["Boiler_0:P1315_0"]!=null)&&(CS.Service.config["Boiler_0:P1316_0"]!=null)){
        if(isNaN(parseFloat(CS.Service.config["Boiler_0:P1315_0"].attr.cscfga__Value__c))){
            CS.Service.config["Boiler_0:P1315_0"].attr.cscfga__Value__c='';
            CS.Service.config["Boiler_0:P1315_0"].attr.cscfga__Display_Value__c='';
            CS.Log.warn('Changed!');
        }
        else{
           CS.Log.warn('Not changed');
        }
       
        if(isNaN(parseFloat(CS.Service.config["Boiler_0:P1316_0"].attr.cscfga__Value__c))){
            CS.Service.config["Boiler_0:P1316_0"].attr.cscfga__Value__c='';
            CS.Service.config["Boiler_0:P1316_0"].attr.cscfga__Display_Value__c='';
            CS.Log.warn('Changed!');
        }
        else{
           CS.Log.warn('Not changed');
        }
    }
    
    // TS 4.10
    var useEx = CS.Service.config['Boiler_0:Use_Existing_Controls_0'];
    
    if (useEx != undefined && useEx.attr.cscfga__Is_Read_Only__c) {
        
        if (useEx.attr.cscfga__Value__c) {
            useEx.attr.cscfga__Value__c = false;
        } 
        
    }
    
    if((CS.getAttributeValue('Job_Type_Required_0')=='Full System')&&(CS.Service.config['Boiler_0:Powerflush_upgrade_0']!=null)){
        CS.setAttributeValue('Boiler_0:Powerflush_upgrade_0','P2015');
        CS.Service.config['Boiler_0:Powerflush_upgrade_0'].attr.cscfga__Is_Read_Only__c=true;
        CS.Service.config['Boiler_0:Powerflush_upgrade_0'].attr.cscfga__Is_Required__c = false;
    }
    
    // TS 3.10.2017 ensure that either controls or "use existing" is selected
    if (CS.Service.config.Boiler_0 != undefined) {
        if (CS.getAttributeDisplayValue('Boiler_0:Controls_0') === '' && !CS.getAttributeValue('Boiler_0:Use_Existing_Controls_0')) { 
              console.log('***** Invalidate config must select controls or use existing');
              jQuery("button:contains('Finish')").hide();
              if (CS.Service.config['Boiler_0:Controls_0'] != undefined) {
                CS.Service.config['Boiler_0:Controls_0'].attr.cscfga__Is_Required__c = true;
              }
        } 
    }
    
    if(CS.getAttributeValue('Quote_Status_0')=='Quote Finalised - Accepted'){
        /*
        if(CS.getAttributeValue('Deposit_Receipt_Number_0')==''){
            CS.Service.config['Deposit_Receipt_Number_0'].attr.cscfga__Is_Required__c = true;
        }
        
        if(CS.getAttributeValue('Payment_Method_0')=='--None--'){
            CS.Service.config['Payment_Method_0'].attr.cscfga__Is_Required__c = true;
        }
        
        if(CS.getAttributeValue('Payment_Type_0')=='--None--'){
            CS.Service.config['Payment_Type_0'].attr.cscfga__Is_Required__c = true;
        }
        */    
        CS.Service.config['Deposit_Receipt_Number_0'].attr.cscfga__Is_Required__c = true;
        CS.Service.config['Payment_Method_0'].attr.cscfga__Is_Required__c = true;
        CS.Service.config['Payment_Type_0'].attr.cscfga__Is_Required__c = true;
        CS.Service.config['Reason_for_Quotation_0'].attr.cscfga__Is_Required__c = true;
        CS.Service.config['Reason_for_system_selection_0'].attr.cscfga__Is_Required__c = true;
        
        if(CS.Service.config['Homecare_0']){
            CS.Service.config['Homecare_0'].attr.cscfga__Is_Required__c = true;
        }
        CS.Service.config['Assist_Flag_0'].attr.cscfga__Is_Required__c = true;
        CS.Service.config['Confirm_HSC_rating_0'].attr.cscfga__Is_Required__c = true;

        if(CS.getAttributeValue("Definition_Name_0")=="Small Commercial"){
             CS.Service.config['Customer_Identity_Check_0:Job_Role_0'].attr.cscfga__Is_Required__c = true;
        }
    }

    if(CS.getAttributeValue('Quote_Status_0')=='Quote Finalised - Not Accepted'){
        CS.Service.config['Payment_Type_0'].attr.cscfga__Is_Required__c = false;
        CS.Service.config['EPDQ_reference_number_0'].attr.cscfga__Is_Required__c = false;
        CS.Service.config['Electronic_Signature_0'].attr.cscfga__Is_Required__c = false;
        CS.Service.config['Payment_Option_0'].attr.cscfga__Is_Required__c = false;
        CS.Service.config['Application_Status_0'].attr.cscfga__Is_Required__c = false;
        CS.Service.config['Application_Number_0'].attr.cscfga__Is_Required__c = false;
        CS.Service.config['Application_Date_0'].attr.cscfga__Is_Required__c = false;
    }
    
    invalidateForNonSold();
}

window.setErrorCssStyle = function setErrorCssStyle() { };
    
window.setSuspectedMaterialUUID = function setSuspectedMaterialUUID() {
    var uuidAttrRef = CS.Service.getCurrentConfigRef() + ':UUID_0';
    var current_uuid = CS.getAttributeValue(uuidAttrRef); 
    // ensure to set UUID only once 
    if (current_uuid === '__NOT_SET__') { 
        var uuidv4 = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) { 
        var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8); 
        return v.toString(16); 
        }); 
        CS.setAttributeValue(uuidAttrRef, uuidv4); 
    }
}


window.hideActualRadiator = function hideActualRadiator(){
    if(CS.Service.config["Actual_Radiator_0"]){
        if(CS.Service.getCurrentScreenRef().indexOf("Radiators")!=-1){
           
            if(navigator.device){
                
                if(CS.Service.config['AR_available_0'] && CS.getAttributeValue('AR_available_0') == 'Yes'){
                    setTimeout(function(){ jQuery('[data-cs-binding="Radiator_0"]').hide(); }, 0);
                    setTimeout(function(){ jQuery('[data-cs-binding="Radiator_0"]').prev().hide(); }, 0);
                    CS.Log.warn('DISPLAYING RADIATOR - HIDING ACTUAL');
                }
                else if(CS.Service.config['AR_available_0'] && CS.getAttributeValue('AR_available_0') == 'No'){
                    setTimeout(function(){ jQuery('[data-cs-binding="Actual_Radiator_0"]').hide(); }, 0);
                    setTimeout(function(){ jQuery('[data-cs-binding="Actual_Radiator_0"]').prev().hide(); }, 0);
                    CS.Log.warn('DISPLAYING ACTUAL - HIDING RADIATOR');
                }
                
                else{
                    jQuery('[data-cs-binding="Actual_Radiator_0"]').hide();
                    jQuery('[data-cs-binding="Actual_Radiator_0"]').prev().hide();
                    
                    if(CS.Service.config["Radiator_0"].relatedProducts.length ==0){
                    CS.DB.smartQuery("SELECT {CS_Part__c:_soup} FROM {CS_Part__c} WHERE {CS_Part__c:Is_Placeholder_Formula__c} = 0 AND {CS_Part__c:Included_In_Regions__c} LIKE '%,North England,%' AND {CS_Part__c:Group__c} = 'RAD' AND {CS_Part__c:Model__c} LIKE '%Compact%' AND {CS_Part__c:Manufacturer__c} LIKE '%Caradon Stelrad%' AND {CS_Part__c:Output__c} <= '6' AND {CS_Part__c:Output__c} >= '0' AND {CS_Part__c:Exists_in_Pricebooks__c} LIKE '%Standard%' AND {CS_Part__c:Active_Formula__c} = 1 LIMIT 1", 10000).then(function(qr) {qr.getAll().then(function(x) { 
                                            if(x!=undefined){
                                               CS.Log.warn('All has been synced');
                                               jQuery('[data-cs-binding="Actual_Radiator_0"]').show();
                                               jQuery('[data-cs-binding="Actual_Radiator_0"]').prev().show();
                                               
                                               jQuery('[data-cs-binding="Radiator_0"]').hide();
                                               jQuery('[data-cs-binding="Radiator_0"]').prev().hide();

                                               CS.setAttributeValue('AR_available_0', 'Yes');
                                            }
                                            
                                        })});
                    }
                }
            }
            else{
                //online
                if((CS.Service.config["Actual_Radiator_0"])&&(CS.Service.getCurrentScreenRef().indexOf("Radiators")!=-1)){
                    if(CS.Service.config["Radiator_0"].relatedProducts.length ==0){
                        setTimeout(function(){ jQuery('[data-cs-binding="Radiator_0"]').hide(); }, 0);
                    }
                    else{
                        setTimeout(function(){ jQuery('[data-cs-binding="Actual_Radiator_0"]').hide(); }, 0);
                    }
                }
            }
            
        }
    }   
}