//# sourceURL=CS_partsModelSupport.js

/**
 * Implement the trim functionality in browsers where there is no support.
 */
if(typeof String.prototype.trim !== 'function') {
    String.prototype.trim = function() {
        return this.replace(/^\s+|\s+$/g, ''); 
    };
}
 
/**
 * Returns a comma separated list the items of an input array, enclosed in () for use in Smart Query IN clauses
 * @param {Array} ids
 * @returns {String} the formatted List of Ids
 */
function convertToListForSmartQuery(ids) {
        //returns a string of this format:  'a0B11000000AaVZ', 'a0B11000000AaVZ'
    if (ids && ids.length > 0) {
        var listString = "('')";
        if (ids.length > 0) {
            listString = "('" + ids[0] + "'";
            for (var i = 1; i < ids.length; i++) {
                listString += ",'" + ids[i]+ "'";
            }
            listString += ")";
        }
        return listString ;
    } else {
        return '(null)';
    }
}

/**
 * Returns true/false depending on wheter a value has been found in an array
 * @param {String} value
 * @param {Array} array
 * @returns {Boolean} found or not
 */
function isInArray(value, array) {
  return array.indexOf(value) > -1;
}

/**
 * Checks whether a part with the same part code exists in the partsModelJS.
 * @param {Object} part A part which will be checked whether it exists in the partsModelJS
 * @return {Boolean} Returns whether or not a part exists in partsModelJS
 */
function existsInPartsModelJS(part) {
    for (var id in partsModelJS) {
        if (!partsModelJS.hasOwnProperty(id)) continue;
        var item = partsModelJS[id];
        
        if(item.isPart){
            var partCode = item.parentPart.part.Part_Code__c;
            if (partCode == part.Part_Code__c) return true;
        }
        
        // check associatedParts as well
        for(var j=0; j<item.associatedParts.length; j++){
            var associatedPartCode = item.associatedParts[j].part.Part_Code__c;
            if (associatedPartCode == part.Part_Code__c) return true;
        }
    }
    return false;
}

/**
 * Checks whether a part with the specified part code exists in the partsModelJS.
 * @param {String} pc A part code which will be checked whether it exists in the partsModelJS
 * @return {Boolean} Returns whether or not a part exists in partsModelJS
 */
function partCodeExistsInPartsModelJS(pc) {
    for (var id in partsModelJS) {
        if (!partsModelJS.hasOwnProperty(id)) continue;
        var item = partsModelJS[id];
        
        if(item.isPart){
            var partCode = item.parentPart.part.Part_Code__c;
            if (partCode == pc) return true;
        }
        
        // check associatedParts as well
        for(var j=0; j<item.associatedParts.length; j++){
            var associatedPartCode = item.associatedParts[j].part.Part_Code__c;
            if (associatedPartCode == pc) return true;
        }
    }
    return false;
}

/**
 * Returns the 18 character id from a supplied 15 character one.
 * @param {String} id A Salesforce id
 * @return {String} A generated 18 character id
 */
function generate18CharId(id){
    // This method will take a 15 character ID and return its 18 character ID
     if (id === null){ 
          return null;
     }
     if (id.length != 15) {
          return id;
     }
     var suffix = '';
     var flags;
     for (var i = 0; i < 3; i++) {
          flags = 0;
          for (var j = 0; j < 5; j++) {
               var c = id.substring(i * 5 + j,i * 5 + j + 1);
               //Only add to flags if c is an uppercase letter:
               if (c.toUpperCase() == c && c >= 'A' && c <= 'Z') {
                    flags = flags + (1 << j);
               }
          }
          if (flags <= 25) {
               suffix = suffix + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.substring(flags,flags+1);
          }else{
               suffix = suffix + '012345'.substring(flags-26,flags-25);
          }
     }
     return id + suffix;
}

/**
 * A wrapper of all important properties of an Associated Part (its Id and Quantity)
 * @constructor
 */
var AssociatedPartWrapper = function (partId, qty) {
    this.associatedPartId = partId;
    this.quantity = qty;
};

/*
 * This class is used to provide a flat structure of the CS_Part__c and its associated Part_Prices__r, Part_Materials__r and Part_Skills__r
 * IMPORTANT: Needs to be kept in sync with the CS_PartWrapper Apex class (in terms of Property names & constructor parameters)
 * @param {Object} thePart
 * @param {Array} thePartPrices
 * @param {Array} thePartMaterials
 * @param {Array} thePartSkills
 * @constructor
 */ 
var CS_PartWrapper = function (thePart, thePartPrices, thePartMaterials, thePartSkills) {
    this.part = thePart;                     //type CS_Part__c
    this.partPrices = thePartPrices;         //type CS_Part_Price__c
    this.partMaterials = thePartMaterials;   //type CS_Part_Material__c
    this.partSkills = thePartSkills;         //type CS_Part_Skill__c
};

/*
 * This class represents a price affecting Attribute (Part or Bundle) including its associated Parts, Materials, Skills and Price information
 * IMPORTANT: Needs to be kept in sync with the CS_PartModelEntry Apex class (in terms of Property names & constructor parameters)
 * @param {Object} attInfo: of type CS_RemotingParamWrapper
 * @param {Object} topBundle: of type CS_Bundle__c
 * @param {Object} topPartWrapper: of type CS_PartWrapper
 * @param {Array} assocParts: of type CS_PartInformation
 * @param {String} aPricebookType
 * @param {String} district
 * @constructor
 * Rules: Either topBundle OR topPart can be passed into the constructor
 */
function CS_PartModelEntry (attInfo, topBundle, topPartWrapper, assocParts, aPricebookType, district, geographicUpliftFactor) {
    
    /*
     * Generic bit, used by Part and Bundle speicifc constructors
     */
    this.isLineItem = attInfo.isLineItem;
    this.isPart = attInfo.isPart;
    this.isBundle = attInfo.isBundle;
    this.isMultilookup = attInfo.isMultilookup;
    this.isPlaceholder = attInfo.isPlaceholder;
    this.isPriceOverriden = attInfo.isPriceOverriden;
    
    this.attRef = attInfo.attRef;
    this.attLastValue = attInfo.attValue;
    this.attLastLineItemDescription = attInfo.lineItemDescription;
    
    if (attInfo.isBundle == true || attInfo.isMultilookup == true) {
        this.attLastQuantity = 1;
    }
    else {
        //Non multilookup Part
        this.attLastQuantity = attInfo.quantity;   
    }
    
    this.pricebookType = aPricebookType;
    this.districtCode = district;
    this.installationLocation = attInfo.installationLocation;
    this.installationNotes = attInfo.installationNotes;
    
    this.associatedParts = assocParts;
    
    if (topPartWrapper) {
        this.parentPart = new CS_PartInformation(topPartWrapper, attInfo, district, null, geographicUpliftFactor);
    }
    else if (topBundle) {
        this.parentBundle = topBundle;
    }

    this.geographicUpliftFactor = geographicUpliftFactor;
    
    // calculate Entry Level Totals;
    this.aggregatedNetPrice = this.calculateAggregatedNetPriceForEntry();
    this.aggregatedPriceInclVAT = this.calculateAggregatedPriceInclVatForEntry();
    this.aggregatedCost = this.calculateAggregatedM_Cost() + this.calculateAggregatedS_Cost();

}

/*
* Calculates the total NET Price for the Entry (of ParentPart if applicable as well as associated Parts, considering quantities as well)
* Is a member of CS_PartModelEntry
* @returns {Decimal} Total Net Price for the Entry
*/ 
CS_PartModelEntry.prototype.calculateAggregatedNetPriceForEntry = function() {
    var total = 0;                
    var totalAssociationsPricePerParentUnit = 0;   
         
    for (var i = 0; i < this.associatedParts.length; i++) {
        var pi = this.associatedParts[i];
        totalAssociationsPricePerParentUnit += pi.totalNetPrice;
    }    
    
    if (this.parentPart) {
        total += this.parentPart.totalNetPrice;
        total += totalAssociationsPricePerParentUnit * this.parentPart.quantity;
    } else {
        total += totalAssociationsPricePerParentUnit;
    }
    
    //CS.Log.warn('***** aggregatedNetPrice:' + total);
    return total;
};

/*
* Calculates the total Price Inclusive of VAT for the Entry (of ParentPart if applicable as well as associated Parts, considering quantities as well)
* Is a member of CS_PartModelEntry
* @returns {Decimal} Total Price VAT Inclusive for the Entry
*/  
CS_PartModelEntry.prototype.calculateAggregatedPriceInclVatForEntry = function() {
    var total = 0;
    var totalAssociationsPricePerParentUnit = 0;  
    
    for (var i = 0; i < this.associatedParts.length; i++) {
        var pi = this.associatedParts[i];
        totalAssociationsPricePerParentUnit += pi.totalPriceIncVAT;
    }
    
    if (this.parentPart) {
        total += this.parentPart.totalPriceIncVAT;
        total += totalAssociationsPricePerParentUnit * this.parentPart.quantity;
    } else {
        total += totalAssociationsPricePerParentUnit;
    }      
    
    //CS.Log.warn('***** aggregatedPriceIncVAT:' + total);
    return total;
};
    
/*
 * Calculates the total Material Cost for the entry (of ParentPart if applicable as well as associated Parts, considering quantities as well)
 * Is a member of CS_PartModelEntry
 * @returns {Decimal} Total Material Cost for the Entry
 */ 
CS_PartModelEntry.prototype.calculateAggregatedM_Cost = function() {
    var total = 0;
    var totalAssociationsMCostPerParentUnit = 0;
    
    for (var i = 0; i < this.associatedParts.length; i++) {
        var pi = this.associatedParts[i];
        if (pi.part.Contributing_to_Margin__c == true) {
            totalAssociationsMCostPerParentUnit += pi.totalMaterialsCost;            
        }
    }   
        
    if (this.parentPart) {
        if (this.parentPart.part.Contributing_to_Margin__c == true) {
            total += this.parentPart.totalMaterialsCost;
        }
        total += totalAssociationsMCostPerParentUnit * this.parentPart.quantity;
    } else {
        total += totalAssociationsMCostPerParentUnit; //for Bundles and multilookups Quantity is always 1
    }
    
    //CS.Log.warn('***** aggregatedMCost:' + total);
    
    return total;
};
    
/*
 * Calculates the total Skill Cost for the entry (of ParentPart if applicable as well as associated Parts, considering quantities as well)
 * Considers pricebook
 * Is a member of CS_PartModelEntry
 * @returns {Decimal} Total Skills Cost for the Entry
 */ 
CS_PartModelEntry.prototype.calculateAggregatedS_Cost = function() {
            
    var total = 0;
    var totalAssociationsSCostPerParentUnit = 0;
    
    for (var i = 0; i < this.associatedParts.length; i++) {
        var pi = this.associatedParts[i];
        if (pi.part.Contributing_to_Margin__c == true) {
            totalAssociationsSCostPerParentUnit += pi.totalSkillsCost;            
        }
    }   
        
    if (this.parentPart) {
        if (this.parentPart.part.Contributing_to_Margin__c == true) {
            total += this.parentPart.totalSkillsCost;
        }
        total += totalAssociationsSCostPerParentUnit * this.parentPart.quantity;
    } else {
        total += totalAssociationsSCostPerParentUnit; //for Bundles and multilookups Quantity is always 1
    }
    
    //CS.Log.warn('***** aggregatedSCost:' + total);
    return total;
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 * This class represents and wraps a CS_Part including its associated Materials, Skills and Price information
 * IMPORTANT: Needs to be kept in sync with the CS_PartModelEntry.CS_PartInformation Apex class (in terms of Property names & constructor parameters)
 * Rule: When creating associated Parts or multilookups, the attWrapper should be left null!
 * Rule: When creating a parentPart, then just pass attWrapper.quantity as the quantity input param, or leave null
 * Just exposing quantity as it greatly differs according to what is being constructed. For example:
 * --> Multilookups always have Quantity 1
 * --> Quantity of associatedParts of parentParts or ParentBundles varies (stored in junction object)
 * @param {Object} aPartWrapper: of type CS_PartWrapper
 * @param {Object} attWrapper: of type CS_RemotingParamWrapper
 * @param {String} district
 * @param {Decimal} qty
 * @constructor
 */
function CS_PartInformation (aPartWrapper, attWrapper, district, qty, geographicUpliftFactor) {
    
    var isUpliftable = true;

    this.part = aPartWrapper.part;
    this.quantity = (qty ? qty : attWrapper.quantity);
    
    //Common bit
    //Part Price: Look for an exact District Code match. If no match exists, assign the 1st Price found. If no Price found, leave Null
    //Assumption is a maximum of 2 PartPrice records may be retrieved (national level & for specific district - otherwise it's a user data error
    //CS.Log.warn('****part Prices: ' + aPartWrapper.partPrices.length);                                     
    var partPrice = ((aPartWrapper.partPrices && aPartWrapper.partPrices.length > 0) ? aPartWrapper.partPrices[0] : null );
    
    for (var i = 0; i < aPartWrapper.partPrices.length; i++) {
        var pp = aPartWrapper.partPrices[i];
        if (pp.District_Code__c == district) {
            partPrice = pp;

            // if a district price exists the price is not upliftable
            isUpliftable = false;
        }
    }

     // if the part is not upliftable the price for that part is not upliftable
    if(!this.part.Upliftable__c){
        isUpliftable = false;
    }
         
    //Populate fields that override the Part_Price__c defaults
    this.price = (partPrice ? partPrice.Price__c : 0); //this may be overriden further down
    this.listPrice = this.price;

    this.totalSkillsCostForUnit = (partPrice ? partPrice.Total_S_Cost__c : 0);
    this.totalMaterialsCostForUnit = (partPrice ? partPrice.Total_M_Cost__c : 0);
    
    //Populate Material List
    this.materialsList = []; //type List<CS_MaterialWrapper>()
    if (aPartWrapper.partMaterials) {
      for (var i = 0; i < aPartWrapper.partMaterials.length; i++) {
          this.materialsList.push(new CS_MaterialWrapper(aPartWrapper.partMaterials[i]));
      }
    }
    
    //Populate Skills List
    this.skillsList = []; //type List<CS_SkillWrapper> ();
    if (aPartWrapper.partSkills) {
      for (var i = 0; i < aPartWrapper.partSkills.length; i++) {
          this.skillsList.push(new CS_SkillWrapper(aPartWrapper.partSkills[i]));
      }
    }
    
    //Only the parent Part can have its Price overriden
    if (attWrapper && attWrapper.isPriceOverriden == true && this.part) {
        this.part.Description__c = attWrapper.lineItemDescription;
        this.price = attWrapper.attPrice;
        this.listPrice = this.price;
    }
    
    //override the part price if the part is upliftable
    if(isUpliftable){
        // calculate the geographical uplift amount
        // [geographicalUpliftAmount for the part] = geographicUpliftFactor * listPrice, else itÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬ ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬ ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢s 0.
        
        //2016-calculation
        this.price = parseFloat(this.price);
        //end
        
        this.geographicUpliftAmount = (geographicUpliftFactor/100) * this.price;
        this.price += this.geographicUpliftAmount;
        
        //2016 pricing calculation
        this.price =this.price.toFixed(2);
        //end
        
    } else {
        this.geographicUpliftAmount = 0;
    }
                
    this.calculateFormulas(); //this must be done at the VERY END!!!
}

/*
 * Calculates the totals for the CS_PartInformation instance.
 * Is a member of CS_PartInformation
 */ 
CS_PartInformation.prototype.calculateFormulas = function() {

    //2016
    this.price = parseFloat(this.price);
    //end2016

    this.totalMaterialsCost = ((this.totalMaterialsCostForUnit && this.quantity) ? (this.quantity * this.totalMaterialsCostForUnit) : 0);
    this.totalSkillsCost = ((this.totalSkillsCostForUnit && this.quantity) ? (this.quantity * this.totalSkillsCostForUnit) : 0);
    
    this.totalNetPrice = ((this.price && this.quantity) ? (this.quantity * this.price) : 0);

    this.marginPreAllowances = this.totalNetPrice - this.totalMaterialsCost - this.totalSkillsCost;
    
    this.priceVatIncl = (this.price ? this.price : 0);
    if (this.part && this.part.VAT_Percentage__c ) {
        this.priceVatIncl += this.price * (this.part.VAT_Percentage__c /100);
        
        //2016 pricing calculation
        this.priceVatIncl = this.priceVatIncl.toFixed(2);
    }
    
    //CS.Log.warn('***** VAT info: ' + this.part.VAT_Percentage__c);
    this.vatAmount = ((this.price && this.part && this.part.VAT_Percentage__c) ? (this.price * this.part.VAT_Percentage__c/100) : 0); 
    
    this.totalVatAmount = ((this.vatAmount && this.quantity) ? (this.vatAmount * this.quantity) : 0);
    this.totalPriceIncVAT = ((this.priceVatIncl && this.quantity) ? (this.quantity * this.priceVatIncl) : 0);   
};

/*
 * This class wraps up a CS_Part_Material__c record
 * IMPORTANT: Needs to be kept in sync with the CS_PartModelEntry.CS_MaterialWrapper Apex class (in terms of Property names & constructor parameters)
 * @param {Object} pm: of type CS_Part_Material__c
 * @constructor
 */
function CS_MaterialWrapper(pm) {
    
    this.name = pm.Material_Name__c;
    this.description = pm.Material_Description__c;
    this.unitCost = pm.Material_Cost_Per_Unit__c;
    this.quantity = pm.Quantity__c;
    
    this.totalCost = ((this.unitCost != null && this.quantity != null) ? this.unitCost * this.quantity : 0);
}

/*
 * This class wraps up a CS_Part_Skill__c record
 * IMPORTANT: Needs to be kept in sync with the CS_PartModelEntry.CS_SkillWrapper Apex class (in terms of Property names & constructor parameters)
 * @param {Object} pm: of type CS_Part_Skill__c
 * @constructor
 */
function CS_SkillWrapper(ps) {
    this.name = ps.Skill_Name__c;
    this.skillCode = ps.Skill_Code__c;
    this.costPerHrStandard = ps.Skill_Cost_Per_Hour_Standard__c;
    this.costPerHrLowCost = ps.Skill_Cost_Per_Hour_Low_Cost__c;
    this.hours = ps.No_of_Hours__c;
    
    this.totalStandardCost = ((this.costPerHrStandard != null && this.hours != null) ? this.costPerHrStandard * this.hours : 0);
    this.totalLowCost = ((this.costPerHrLowCost != null && this.hours != null) ? this.costPerHrLowCost * this.hours : 0);
}

/**
 * Override the default getAttributeValue method, casting to String was missing
 */
function overrideGetAttributeValue() {
    var oldGetAttributeValue = CS.getAttributeValue;
    CS.getAttributeValue = function getAttributeValue(id, dataType) {
        if (dataType === 'String') {
            var wrapper = CS.getAttributeWrapper(id),
                attr,
                val,
                prefix = "cscfga__";

            if (!wrapper) return;

            attr = wrapper.attr;

            if (!CS.getAttributeField(id, 'active')) {
                return '';
            }

            val = attr[prefix + 'Value__c'];

            val = ((val === null) || (val == undefined)) ? '' : String(val);
            return val;
        } else {
            return oldGetAttributeValue(id, dataType);
        }
    };
};

/**
 * Override default disableAttribute method only in DepotSQT due existing application issue 
 */
function overrideDisableAttribute() {
    CS.disableAttribute = function disableAttribute(id) {
        if(CS.Service.config[id].displayInfo =='Select List'){
            CS.setAttributeValue(id,'--None--');
            CS.makeAttributeReadOnly(id);
        }
        else{
            CS.makeAttributeReadOnly(id);
            CS.setAttributeValue(id,'');
        }
    };
};

function overrideDisableAttributeForNewCSA(){
    CS.disableAttribute = function disableAttribute(id) {
    	var attrWrapper = CS.getAttributeWrapper(id);
    	if (attrWrapper && attrWrapper.displayInfo == "Select List") {
    		CS.binding.update(id, {active: false, lineItem: false, value: '--None--'});
    	} else {
    		CS.binding.update(id, {active: false, lineItem: false});
    	}
    }
}

// Call the method in ipad context to make sure it is overridden
if(navigator.device) {
    overrideGetAttributeValue();
    //overrideDisableAttribute();
    if(CS.isCsaContext==undefined){
        overrideDisableAttribute();
    }
    else{
        overrideDisableAttributeForNewCSA();
    }
}

//Towel warmer fix
window.checkIfTowelWarmerCategory = function checkIfTowelWarmerCategory(actRef){
    var towelWarmerCategories = ['Alara','Empire','Oval','Classic'];
    var isTowelWarmer = false;
    for (var i=0; i<towelWarmerCategories.length; i++){
        var val=towelWarmerCategories[i];
        if(CS.getAttributeValue(actRef+':Model_Range_0') == val){
            isTowelWarmer = true;
        }
    }
    return isTowelWarmer;
}

window.overrideHeatLossForNewInstallationTowerWarmer = function overrideHeatLossForNewInstallationTowerWarmer(actRef){
    //if new installation
    if((CS.Service.config[actRef+":Fitting_Pack_0"].attr.cscfga__Value__c == 'New installation') && checkIfTowelWarmerCategory(actRef)){
        //override heatloss if calculated
        if(CS.getAttributeValue(actRef+':Heat_Loss_0') != ''){
            CS.setCalculation(actRef+':PowerLower_0',0);
            CS.setCalculation(actRef+':PowerUpper_0',6);
        }
        
    }
}
//end

window.checkIfUINeedsToBeBlanked = function checkIfUINeedsToBeBlanked(reference,uiValue){
    var emptyTheValue = false;
    
    for(var itm in CS.Service.config[reference].selectOptions){
        if((CS.Service.config[reference].selectOptions[itm].cscfga__Value__c!='Other') && uiValue.substring(0, CS.Service.config[reference].selectOptions[itm].cscfga__Value__c.length)==CS.Service.config[reference].selectOptions[itm].cscfga__Value__c){
            emptyTheValue = true;
        }
    }
    return emptyTheValue;
}

window.setRequiredCSSForHeatLossFields = function setRequiredCSSForHeatLossFields(thisRef){
    
    if(navigator.device){
        
    
    var attrCSS=['Room_Height_0','Room_Length_0','External_Wall_Length_0', 'Window_Area_0', 'Room_Width_0','Room_Below_0','Room_Above_0','External_Wall_Type_0','Type_of_Windows_0']; 
    var attrToChangeCSS =[];
    var size=attrCSS.length;
    for(var i=0; i<size; i++){ 
        //Actual_Radiator_0:Attribute_Name_0
        var wholeReference = thisRef+':'+attrCSS[i];
        var required = CS.Service.config[wholeReference].attr.cscfga__Is_Required__c;
        var valueEmpty = false;
        if((CS.Service.config[wholeReference].attr.cscfga__Value__c==null) || (CS.Service.config[wholeReference].attr.cscfga__Value__c=='None') || (CS.Service.config[wholeReference].attr.cscfga__Value__c=='--None--')|| (CS.Service.config[wholeReference].attr.cscfga__Value__c=='')){
            valueEmpty = true;
        }
        if(required && valueEmpty){
            CS.Log.warn('Setting the value for '+wholeReference);
            attrToChangeCSS.push(wholeReference);
            //setTimeout(function(){jQuery('[data-cs-label="'+wholeReference+'"]').parent().addClass('attributeError');}, 0);
        }
    }  
    
    if(attrToChangeCSS.length >0){
        setTimeout(function(){
            CS.Log.warn('****In function');
            var sizeAttr=attrToChangeCSS.length;
            for(var j=0; j<sizeAttr; j++){
                jQuery('[data-cs-label="'+attrToChangeCSS[j]+'"]').parent().addClass('attributeError');
            }
        }, 0);
    }
    }
    else{
        CS.Log.warn('Not changing online');
    }
}


window.setUIFields = function setUIFields(){
    var thisDef=CS.Service.getCurrentConfigRef();
    if(thisDef!=''){

        //fix-set Valves_Required_0
        if(CS.getAttributeValue(thisDef+':Valves_Required_0') =='Yes'){
            CS.setAttributeValue(thisDef+':Valves_Required_0', 'true'); 
        }
        
        if((CS.getAttributeValue(thisDef+':Valves_Required_0') =='No') || (CS.getAttributeValue(thisDef+':Valves_Required_0') =='false')||(CS.getAttributeValue(thisDef+':Valves_Required_0') =='')){
            if(CS.getAttributeValue(thisDef+':Radiator_0') !=''){
                CS.Log.warn('RESETING RADIATOR VALVE');
                CS.setAttributeValue(thisDef+':Radiator_Valve_0','');
            }
        }
        //end fix
        var heatLossRequired = CS.getAttributeValue(thisDef+':Heatloss_Required_0');
        if(heatLossRequired == 'No'){
            CS.setAttributeValue(thisDef+':Radiator_Message_0', 'Please choose a suitable radiator, selecting manufacturer and model first.');
        }
        else{
            setRequiredCSSForHeatLossFields(thisDef);
        }
        var locationList = CS.getAttributeValue(thisDef+':Location_List_0'); 
        var locationUI = CS.getAttributeValue(thisDef+':Location_Within_Room_0');
        var reasonUI = CS.getAttributeValue(thisDef+':Heatloss_Reason_0');
        var reasonList = CS.getAttributeValue(thisDef+':Reason_List_0');
        
        if(reasonList!='Other' && reasonList!='--None--'){
            if((reasonUI=='')||(reasonUI.substring(0, reasonList.length)!=reasonList)){
                CS.setAttributeValue(thisDef+':Heatloss_Reason_0', reasonList);
            }
        }
        
        
        if(locationList!='--None--' && locationList!='Other'){
            if((locationUI=='')||(locationUI.substring(0, locationList.length)!=locationList)){
                CS.setAttributeValue(thisDef+':Location_Within_Room_0', locationList);
            }
        }
        
        else if(locationList=='Other'){
            var blankRef = thisDef+':Location_List_0';
            if(checkIfUINeedsToBeBlanked(blankRef, locationUI)){
                CS.Log.warn('RESETING location within room');
                CS.setAttributeValue(thisDef+':Location_Within_Room_0', '');
            }
            else{
                CS.Log.warn('NOT RESETING');
            }
        }
        
        /*
        if(locationList!='--None--'){
            if((locationUI=='')||(locationUI.substring(0, locationList.length)!=locationList)){
                if(locationList == 'Other'){
                    CS.setAttributeValue(thisDef+':Location_Within_Room_0', locationList+': ');
                }
                else{
                    CS.setAttributeValue(thisDef+':Location_Within_Room_0', locationList);
                }
            }
        }
        */
        
    }
    
    
}

window.setActualRadValuesFromPrevious = function setActualRadValuesFromPrevious(){
    var thisDef=CS.Service.getCurrentConfigRef();
    
    if(thisDef!=''){
        CS.Log.warn("****This definition: "+thisDef); 
        //SET DEFAULTS 
        var regions = CS.getAttributeValue('Geographic_Region_Shadow_0'); 
        var jobType = CS.getAttributeValue('Job_Type_Required_0'); 
        var pricebook= CS.getAttributeValue('Pricebook_Type_0'); 
    
        CS.setAttributeValue(thisDef+':Geographic_Region_Shadow_0',regions); 
        CS.setAttributeValue(thisDef+':Pricebook_Type_0',pricebook); 
        CS.setAttributeValue(thisDef+':Job_Type_Required_0',jobType); 
    
        var nRads=CS.Service.config.Actual_Radiator_0.relatedProducts.length; 
        CS.Log.warn("****Num="+nRads); 
        var run = CS.getAttributeValue(thisDef+":Perform_Calc_0"); 
        CS.Log.warn("Has set defaults run :"+run); 
        //has a radiator been added? 
        var thisRad=CS.getAttributeValue(thisDef+":Radiator_0"); 
    
    
        //only set defaults if a rad has NOT been added? or set a check value so only defaults once 
        if(nRads>1 && (run=="No" || run=="")){ 
        CS.Log.warn('Setting radiator defaults...'); 
        var radID = thisDef.split("_"); 
        var idx = radID[radID.length-1]-1; 
        var prevRad='Actual_Radiator_'+idx; 
        CS.Log.warn("Prev rad: "+prevRad); 
    
        var attributesToDefault=['Room_Height_0','Room_Below_0','Room_Above_0','External_Wall_Type_0','Type_of_Windows_0','Manufacturer_0','Model_Range_0', 'Radiator_Valve_0','Valves_Required_0']; 
        l=attributesToDefault.length; 
        //console.log('Default atttributes from previously selected radiator') 
        for(var i=0; i<l; i++){ 
        var source = prevRad+':'+attributesToDefault[i]; 
        var target = thisDef+':'+attributesToDefault[i]; 
        //console.log('Source: '+source+' Target: '+target); 
        var val=CS.getAttributeValue(source); 
        //console.log("CS.setAttributeValue('"+target+"','"+val+"')");
        if(thisDef!='Actual_Radiator_0'){
        CS.setAttributeValue(target, val);
        } 
        } 
        CS.setAttributeValue(thisDef+":Perform_Calc_0", true); 
        } 
    
        if(!thisRad){ 
            CS.Log.warn("No rad added calculate heatloss..."); 
            actualRadHeatloss(thisDef); 
        }
    }
}

function actualRadHeatloss(def){
    CS.Log.info("ActualRadiatorHeatloss("+def+")");
    var airchange = 1;
    var exttemp = CS.getAttributeFieldValue('External_Temperature_0', 'price');//from parent definition
    
    //user input dimension variables
    var rwidth = CS.getAttributeValue(def+':Room_Width_0');
    var rlength = CS.getAttributeValue(def+':Room_Length_0');
    var rheight = CS.getAttributeValue(def+':Room_Height_0');
    var lengthOfOutsideWalls = CS.getAttributeValue(def+':External_Wall_Length_0');
    var windarea = CS.getAttributeValue(def+':Window_Area_0');

    //user select fabric U values could be 0.00 but not 0
    var windtype = CS.getAttributeFieldValue(def+':Type_of_Windows_0', 'price');
    var walltype = CS.getAttributeFieldValue(def+':External_Wall_Type_0', 'price');
    var aboveroom = CS.getAttributeFieldValue(def+':Room_Above_0', 'price');
    var belowroom = CS.getAttributeFieldValue(def+':Room_Below_0', 'price');

    // these are just the string names - shouldnt be needed
    var windtypeSelectList = CS.getAttributeValue(def+':Type_of_Windows_0');
    var walltypeSelectList = CS.getAttributeValue(def+':External_Wall_Type_0');
    var aboveroomSelectList = CS.getAttributeValue(def+':Room_Above_0');
    var belowroomSelectList = CS.getAttributeValue(def+':Room_Below_0');console.log('Room below'+belowroom)
    var roomtypeSelectList = CS.getAttributeValue(def+':Room_Type_0');
    var roomtype = CS.getAttributeFieldValue(def+':Room_Type_0', 'price');

    //set temperature differential
    var tdiff = parseFloat(roomtype)- exttemp;

    var required=[roomtypeSelectList,rwidth,rlength,rheight,lengthOfOutsideWalls, windarea, windtypeSelectList,walltypeSelectList,aboveroomSelectList,belowroomSelectList];
    for (var i=0; i<required.length; i++){
        var val=required[i];
        //console.log(checkVal);
        if(!val || val=='--None--'|| val=='None') {
            CS.setAttribute(def+':Radiator_Message_0', 'Please fill in all room details in order to calculate room heat loss. ');
            return false;
        }
    }

    //all values filled in, perform calc
    var floorarea = rwidth * rlength;
    var volume = floorarea * rheight;
    var extwallarea = lengthOfOutsideWalls * rheight - windarea;

    //Heatloss of a section = uValue * area * temperature difference
    var windloss = parseFloat(windtype) * windarea * tdiff;
    var extwallloss = parseFloat(walltype) * extwallarea * tdiff;
    var ceilingloss = parseFloat(aboveroom) * floorarea * tdiff;
    var floorloss = parseFloat(belowroom) * floorarea * tdiff;

    switch (roomtype) { 
        case 23: airchange=2; break;
        case 22: airchange=1.5; break; 
        case 19: airchange=1; break;
        case 18: airchange=1.5; break; 
    }

    var ventloss = volume * airchange * tdiff * 0.33;

    var grtot = windloss + extwallloss + ceilingloss + floorloss + ventloss;
    // Put here general safety margin ;
    grtot = grtot * 1.15;
    grtot = grtot / 1000; //get kW

    //var tolerance=CS.getAttributeValue(def+':Tolerance_0');
    var tolerance=20;
    
    //console.log(tolerance);
    var lower=((grtot-(grtot/100*tolerance))).toFixed(2);
    //var upper =((grtot+(grtot/100*tolerance))).toFixed(2);//MF July 2018
    var upper = 6;

    CS.setCalculation(def+':Heat_Loss_0', grtot.toFixed(2));
    CS.setCalculation(def+':PowerLower_0',lower);
    CS.setCalculation(def+':PowerUpper_0',upper);
    //CS.setAttribute(def+':Radiator_Message_0', 'Select a radiator with heatloss between '+lower+'kw and '+upper+'kw');//MF July 2018
    CS.setAttribute(def+':Radiator_Message_0', 'Select a radiator based on heatloss required and customer preference as appropriate');

    overrideHeatLossForNewInstallationTowerWarmer(def);
}

function resetHeatlossAttributes(def){
    //called on reset button
    CS.Log.info("resetHeatlossAttributes("+def+")");
    var reset=['Type_of_Windows_0','External_Wall_Type_0','Room_Above_0','Room_Below_0','Room_Type_0'];
    for (var i=0; i<reset.length; i++){
            CS.setAttributeValue(def+':'+reset[i], 'None');
    }
}

function makeHeatlossAttributesReadOnly(def){
   //set if heatloss required=='No' or radiator has been selected
   
   if(def !=''){
       CS.Log.info("makeHeatlossAttributesReadOnly("+def+")");
    var arr=['Room_Height_0',
    'Room_Width_0',
    'Room_Length_0',
    'Window_Area_0',
    'External_Wall_Length_0',
    'Type_of_Windows_0',
    'Room_Above_0',
    'Room_Below_0',
    'Type_of_Windows_0',
    'External_Wall_Type_0'];
    
    var referenceHR = def+':'+'Heatloss_Required_0';
    var referenceRad = def+':'+'Radiator_0';
    var referenceRT = def+':'+'Room_Type_0';
    //||(CS.getAttributeValue(referenceRT)=='None')||(CS.getAttributeValue(referenceRad)==''))
    if(CS.Service.config[referenceHR]&&CS.Service.config[referenceRad]&&CS.Service.config[referenceRT]&&((CS.getAttributeValue(referenceHR)=='No')||(CS.getAttributeValue(referenceRT)=='None')||(CS.getAttributeValue(referenceRad)!=''))){
        for (var i=0; i<arr.length; i++){
            var reference = def+':'+arr[i];
            //CS.Service.config[reference].attr.cscfga__Is_Read_Only__c=true;
            //CS.makeAttributeReadOnly(reference);
            CS.Service.config[reference].attr.cscfga__Is_Read_Only__c=true;
            CS.Service.config[reference].attr.cscfga__Is_Required__c=false;
        }
    }
   }
}

window.validateBoilerPlusControls= function validateBoilerPlusControls(){
    CS.Log.warn("validateBoilerPlusControls()");
    var reason = CS.getAttributeValue("Boiler_Plus_Reason_0","String");
    var country = CS.getAttributeValue("Country_0","String");//England,Scotland,Wales
    //check if the new fields exist, this is for WIP

    //CS.Log.warn("Current reason: "+reason);
    //CS.Log.warn("Country:"+country);

    if(reason==null || country==null){
        console.log("No country or reason set!");
        return false;
    }

    var screenRef = CS.Service.getCurrentScreenRef();
    //eg "Heating_Solution:Prepare_Proposal"

    var system;

    if(!screenRef.includes("Prepare_Proposal")){
        CS.Log.warn("Not the proposal screen!")
        return false;
    }

    if(screenRef.includes("Heating_Solution")){
        console.log("Heating_Solution")
        system = CS.getAttributeValue("System_Type_Required_0", "String");
    }

    if(screenRef.includes("Straight_Swaps")){
        console.log("Straight_Swaps")
        system = CS.getAttributeDisplayValue("Select_Job_Type_0", "String");
    }
    //console.log("system: "+system)
    var start = new Date("2018-04-06"); //yyyy-mm-dd
    var now = new Date();

    //use underscore to check if partsModel has been compiled
    if(_.isEmpty(partsModelJS)){
        //CS.Log.warn("partsModelJS is empty!")
        CS.makeAttributeReadOnly("Boiler_Plus_Reason_0");
        CS.setAttributeValue("Boiler_Plus_Text_0","Calculate prices first");
        return false;
    }
    if(country!="England" || system!="Combination"){
        //CS.Log.warn("Not in England or not a combi!");
        CS.setAttributeValue("Boiler_Plus_Reason_0","Not applicable");
        CS.makeAttributeReadOnly("Boiler_Plus_Reason_0");
        CS.setAttributeValue("Boiler_Plus_Text_0","Boiler Plus Policy not applicable");
        return false;
    }
    
    if(now < start){
        //CS.Log.warn("Before start date");
        CS.setAttributeValue("Boiler_Plus_Reason_0","Not applicable");
        CS.makeAttributeReadOnly("Boiler_Plus_Reason_0");
        CS.setAttributeValue("Boiler_Plus_Text_0","Boiler Plus Policy not applicable until 06/04/2018");
        return false;
    }
    else{
        //CS.Log.warn("Parts Model exists and job is a combi in England, check if boiler plus parts added");


        // PD Updated 12/06/19
        var arr=["PSLT3","PSLT5","PSLT6","PSLT7","P2290","P2291","P2292","P2293","P2295","P1471","PSLT49","PSLT50","PSLT61","PSLT62","PSLT63"];
        
        //IC Updated 23/10/2018
        for(var i=0; i<arr.length; i++){
            var pCode=arr[i];
            //console.log("checking for "+pCode)
            if(partCodeExistsInPartsModelJS(pCode)){
                //CS.Log.warn("A boiler plus part has been added, set value as Included and make read only");
                CS.setAttributeValue("Boiler_Plus_Text_0","Boiler Plus Part has been included");
                CS.setAttributeValue("Boiler_Plus_Reason_0","Included");
                CS.makeAttributeReadOnly("Boiler_Plus_Reason_0");
            return false;
            }
        }
    }


    //validation requirements have not been satisfied, HSA must select option from reason list
    //console.log("HSA must select a reason code!")

    //console.log("constrain list")
    CS.constrainList("Boiler_Plus_Reason_0",[
        ["--Select--","--Select--"],
        ["Customer already has a compatible product","Existing Product"]
    ]);
    //this forces update
    //console.log("Update text display");
    var str= "As per the Boiler Plus policy a suitable measure should be included. " +"Please include a suitable part from controls or select reason for not adding a compliant part";

    CS.setAttributeValue("Boiler_Plus_Text_0",str);

    // 2018-08-20 removed as the same rule is implemented on the product level
    /*
    if(reason=="--Select--"){
        CS.markConfigurationInvalid("Please select a valid reason code for boiler plusÃƒÂ¢Ã¢â€šÂ¬Ã‚Â);
        return false;
    }
    */
}

window.additionalHiveAdded = function additionalHiveAdded(){
    console.log("additionalHiveAdded()");
    //first, hide any hive products if not in trial
    hideHiveProducts();
    //checks if any additional hive pack shave been added and adds a single Hive skill pack if any have been added
    var hiveAdded=false;
    var hiveDefinitions=["Hive_Products_0","Boiler_0:Controls_0:Hive_Products_0"];
    

    for (var key in hiveDefinitions){
        console.log(key)
        // skip loop if the property is from prototype
        if (!hiveDefinitions.hasOwnProperty(key)) continue;

        if(hiveAdded==false){
            var def = hiveDefinitions[key];
            console.log("Checking def: "+def);
            var wrapper=CS.getAttributeWrapper(def);
            if(wrapper){
                
                var l = wrapper.relatedProducts.length;
                //console.log(l);
                //console.log(def+" has "+l+" related products");
                if(l && l!=0){hiveAdded= true;}
            }
        }
    }
    if(hiveAdded==true){CS.setAttributeValue("PSLT48_0",1)}
    else{CS.setAttributeValue("PSLT48_0",'')}
}

window.addDeliveryLocation = function addDeliveryLocation(){
    console.log("addDeliveryLocation()")

    //var status = CS.getAttributeValue('Quote_Status_0');

    //only run if on ipad and accepted and loc attribute exists
    if(CS.getAttributeValue('Delivery_Location_0')){
        var loc = CS.getAttributeValue('Delivery_Location_0');
        var notes = CS.getAttributeValue('Additional_Delivery_Notes_0');

        if(loc !="--None--"){
            // var msg = "Recommended delivery location: "+loc+", please confirm with customer";
            // CS.setAttributeValue("Delivery_Notes_0", msg+"\n"+notes);
            var msg = loc+" : ";
            CS.setAttributeValue("Delivery_Notes_0", msg+notes);
        }else{
            CS.setAttributeValue("Delivery_Notes_0",notes);
        }
    }
}

window.hideHiveProducts = function hideHiveProducts(){
    var str = CS.getAttributeValue("Included_Projects_0");
    var arr = str.split(',');
    if(_.contains(arr, 'NHT')){
        CS.Log.warn("District is NOT in HIVE trial, hide Hive Products");
        setTimeout(function(){ jQuery('[data-cs-binding="Hive_Products_0"]').hide(); }, 0);
        setTimeout(function(){ jQuery('[data-cs-binding="Boiler_0:Controls_0:Hive_Products_0"]').hide(); }, 0);
        if(navigator.device){
            //on ipad hide the labels for the related products
             setTimeout(function(){ jQuery('[data-cs-binding="Hive_Products_0"]').prev().hide(); }, 0);
             setTimeout(function(){ jQuery('[data-cs-binding="Boiler_0:Controls_0:Hive_Products_0"]').prev().hide(); }, 0);
        }
        return true;
    }
    return false;
}


window.validateVoucherNumber = function validateVoucherNumber(){
    console.log("validateVoucherNumber()")
    var reference = CS.getAttributeValue('Energy_Account_Ref_0');
    var email = CS.getAttributeValue("Contact_Email_0");
    var table = document.getElementById("allowancesHSA"); 

    CS.Service.config['Energy_Account_Ref_0'].attr.cscfga__Is_Required__c=false;
    CS.Service.config['Contact_Email_0'].attr.cscfga__Is_Required__c=false;
   

    if(table){//table only exists on calculate prices
        for (var i = 1; i <= 6; i++) {
            var select = document.getElementById("discount"+i);
            var allowanceName = select.options[select.selectedIndex].text;
            var allowanceCode = select.options[select.selectedIndex].getAttribute('allowance-code');
            var requiresBillingRef = select.options[select.selectedIndex].getAttribute('requires-billing');
            var requiresEmail = select.options[select.selectedIndex].getAttribute('requires-email');
            
            if(requiresBillingRef=='true' && reference ==''){
                console.log(allowanceCode+" requires billing ref");
                    CS.Service.config['Energy_Account_Ref_0'].attr.cscfga__Is_Required__c=true;
                    setTimeout(function(){jQuery('[data-cs-label="Energy_Account_Ref_0"]').parent().addClass('attributeError');}, 0);
                    //jQuery('[data-cs-label="Energy_Account_Ref_0"]').parent().addClass('attributeError');
                    return false;
            }
            
            else if(requiresEmail=='true' && email ==''){
                console.log(allowanceCode+" requires email");
                CS.Service.config['Contact_Email_0'].attr.cscfga__Is_Required__c=true;
                setTimeout(function(){jQuery('[data-cs-label="Contact_Email_0"]').parent().addClass('attributeError');}, 0);
                setDefaultEmail();
                return false;
            }
        }
    }else{
        //console.log("checking allowance attributes...")
        for (var i = 1; i <= 6; i++) {
            //var allowanceCode = CS.getAttributeFieldValue('Allowance'+i+'_0', 'Code');
            var requiresBillingRef = CS.getAttributeFieldValue('Allowance'+i+'_0', 'requiresBillingRef');
            var requiresEmail = CS.getAttributeFieldValue('Allowance'+i+'_0', 'requiresEmail');

            if(requiresBillingRef=='TRUE' && reference == ''){
                CS.Service.config['Energy_Account_Ref_0'].attr.cscfga__Is_Required__c=true;
                return false;
            }
            else if(requiresEmail=='TRUE' && email == ''){
                //console.log(allowanceCode+" requires email");
                CS.Service.config['Contact_Email_0'].attr.cscfga__Is_Required__c=true;
                setDefaultEmail();
                return false;
            }
        }
    }

    function setDefaultEmail(){
        var emailEntered = CS.getAttributeValue("Contact_Email_0");
        if(emailEntered==''){
            var emailFromContact = CS.getAttributeValue("Email_0");
            var hiveEmail = CS.getAttributeValue("Boiler_0:Controls_0:Customer_Email_Address_2_0");
            if(hiveEmail){CS.setAttributeValue('Contact_Email_0',hiveEmail);}
            else if(emailFromContact){CS.setAttributeValue('Contact_Email_0',emailFromContact);}
        }
    }
}


window.addStandOffBracket = function addStandOffBracket(id){
    console.log("addStandOffBracket()");
    var shown = CS.getAttributeFieldValue('Boiler_0:Part_Code_0', 'standoffprompt');
    console.log("shown:"+shown);
    var currentScreen = CS.Service.getCurrentConfigRef()
    console.log(currentScreen);
    var isBoiler = currentScreen == "Boiler_0" ? true : false;
    console.log("isBoiler:"+isBoiler);
    if(isBoiler && shown != 'yes'){
        var r = confirm ("Do you want to add a standoff bracket?");
        console.log(r);
        CS.setAttributeField('Boiler_0:Part_Code_0', 'standoffprompt', 'yes');
        console.log("standoffprompt set to: "+CS.getAttributeFieldValue('Boiler_0:Part_Code_0', 'standoffprompt'));

        if(r==true){
            var brackets = {'CBLR1368':'P7821'};
            var id = CS.getAttributeValue("Boiler_0:Part_Code_0");
            var part = brackets[id];
            //need the function to add part to parts Model
            alert("add the stand off bracket "+part);
        }
    }
}

