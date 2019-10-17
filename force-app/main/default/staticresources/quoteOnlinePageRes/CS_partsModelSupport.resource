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
        // [geographicalUpliftAmount for the part] = geographicUpliftFactor * listPrice, else itÕs 0.
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
    	var val;
        if (dataType === 'String') {
            var wrapper = CS.getAttributeWrapper(id);
            var attr;
            var prefix = "cscfga__";

            if (!wrapper) return;

            attr = wrapper.attr;

            if (!CS.getAttributeField(id, 'active')) {
                return '';
            }

            val = attr[prefix + 'Value__c'];

            val = (val === null || val === undefined) ? '' : String(val);
        } else {
            val = oldGetAttributeValue(id, dataType);
            val = (val === null || val === undefined) ? '' : val;
        }
        return val;
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



// Call the method in ipad context to make sure it is overridden
if(navigator.device) {
    overrideGetAttributeValue();
    //overrideDisableAttribute();
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
        if(!val || val=='--None--') {
            CS.setAttribute(def+':Radiator_Message_0', 'Please fill in all room details in order to calculate room heat loss. '+i);
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

    var tolerance=CS.getAttributeValue(def+':Tolerance_0');
    //console.log(tolerance);
    var lower=((grtot-(grtot/100*tolerance))).toFixed(2);
    var upper =((grtot+(grtot/100*tolerance))).toFixed(2);

    CS.setCalculation(def+':Heat_Loss_0', grtot.toFixed(2));
    CS.setCalculation(def+':PowerLower_0',lower);
    CS.setCalculation(def+':PowerUpper_0',upper);
    CS.setAttribute(def+':Radiator_Message_0', 'Select a radiator with heatloss between '+lower+'kw and '+upper+'kw');
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
    
    
    for (var i=0; i<arr.length; i++){
            CS.makeAttributeReadOnly(def+':'+arr[i]);
    }
    
}