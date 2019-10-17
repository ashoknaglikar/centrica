/*
 * Represents an entry in the entire Parts Model.
 * Associated Parts are grouped under the (Parent) Part or Bundle that brought them into the solution automatically.
 * Where the Configurator attribute is of Type MultiLookup, then both parentPart & parentBundle will be null, and every Id in the
 *      multilookup's value will represent an associated Part. We assume that these Parts:
 *      - will NEVER have associated parts,  
 *      - their Quantity will ALWAYS be 1,
 *      - their Price cannot be overriden
 * In certain cases, the Price of a Part will NOT be the PartPrice retrieved from the database, but will be overriden in Configurator (below the line Radiators)
 * In this case, the IsPriceOverriden flag will be true, so the Price of the Part will be taken from the Configurator Attribute rather than the database record (PartPrice)
 * The CS_PartModelEntry constructs itself given the params passed in the constructor
 */

global class CS_PartModelEntry {
    
    public String attRef {get; set;} //this will be the key of the map as well
    
    public String attLastValue {get; set;} // a PartId, a BundleId, or csv if multilookup Part
    public Decimal attLastQuantity {get; set;} //the same as the parentPart.quantity or 1 if Bundle or multilookup
    
    public String attLastLineItemDescription {get; set;}
    
    public CS_PartInformation parentPart {get; set;} //only makes sense if is Part and not a Multilookup. Otherwise leave null
    public List<CS_PartInformation> associatedParts {get;  set;}
    public CS_Bundle__c parentBundle {get; set;}  //null if parent IsPart, or att is multilookup
    
    public Boolean isLineItem {get; set;}
    public Boolean isPart {get; set;}
    public Boolean isBundle {get; set;}
    public Boolean isMultilookup {get; set;}
    public Boolean isPlaceholder {get; set;}
    public Boolean isPriceOverriden {get; set;}
    
    public String pricebookType;
    public String districtCode;
    public Decimal geographicUpliftFactor {get; set;}
    
    public String installationLocation {get; set;}
    public String installationNotes {get; set;}
    
    //Some Aggregated totals at this level for easier solution-level roll ups
    public Decimal aggregatedNetPrice {get;  set;}
    public Decimal aggregatedPriceInclVAT {get;  set;}
    public Decimal aggregatedCost {get;  set;}
    
    //EP NEW
    
    public CS_PartModelEntry (CS_RemotingParamWrapper attInfo, CS_Bundle__c topBundle, CS_PartWrapper topPartWrapper, 
        List<CS_PartModelEntry.CS_PartInformation> assocParts, String aPricebookType, String district, Decimal geographicUpliftFactor) {
    
        /*
         * Generic bit, used by Part and Bundle specifc constructors
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
        
        if (topPartWrapper != null) {
            this.parentPart = new CS_PartInformation(topPartWrapper, attInfo, district, null, geographicUpliftFactor);
        }
        else if (topBundle != null) {
            this.parentBundle = topBundle;
        }

        this.geographicUpliftFactor = geographicUpliftFactor;
        
        // calculate Entry Level Totals; These are called when the constructor is called by tests, aiming to replicate the JS funtionality
        this.aggregatedNetPrice = this.calculateAggregatedNetPriceForEntry();
        this.aggregatedPriceInclVAT = this.calculateAggregatedPriceInclVatForEntry();
        this.aggregatedCost = this.calculateAggregatedM_Cost() + this.calculateAggregatedS_Cost();
    }
    
    //END EP NEW
    
    
    //public CS_PartModelEntry() {}
    
    /*
     * Generic constructor, used by Part and Bundle speicifc constructors
     */
    /*
    public CS_PartModelEntry(CS_RemotingParamWrapper attInfo, List<CS_PartInformation> assocParts, String aPricebookType, String district) {
        this.isLineItem = attInfo.IsLineItem;
        this.isPart = attInfo.isPart;
        this.isBundle = attInfo.IsBundle;
        this.isMultilookup = attInfo.isMultilookup;
        this.isPlaceholder = attInfo.isPlaceholder;
        this.isPriceOverriden = attInfo.isPriceOverriden;
        
        this.attRef = attInfo.attRef;
        this.attLastValue = attInfo.attValue;
        this.attLastLineItemDescription = attInfo.lineItemDescription;
        
        if (attInfo.isBundle || attInfo.isMultilookup) {
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
        
        calculateEntryLevelTotals();
    }
    */
    
    /*
    //For Parts: The Parent Part could have a quantity other than 1
    public CS_PartModelEntry(CS_RemotingParamWrapper attInfo, CS_Part__c topPart, List<CS_PartInformation> assocParts, String aPricebookType, String pcSector) {
        this(attInfo, assocParts, aPricebookType, pcSector);
        this.parentPart = new CS_PartInformation(topPart, attInfo, pcSector);

        //Leave parentBundle null
        
        calculateEntryLevelTotals();
    }
    */
    
    /*
    //For Bundles
    public CS_PartModelEntry (CS_RemotingParamWrapper attInfo, CS_Bundle__c topBundle, List<CS_PartInformation> assocParts, String aPricebookType, String pcSector) { 
        this(attInfo, assocParts, aPricebookType, pcSector);
        this.parentBundle = topBundle;
        
        //Leave parentPart null!!!
        
        calculateEntryLevelTotals();
    }
    */
    
     void calculateEntryLevelTotals() {
        this.aggregatedNetPrice = calculateAggregatedNetPriceForEntry();
        this.aggregatedPriceInclVAT = calculateAggregatedPriceInclVatForEntry();
        this.aggregatedCost = calculateAggregatedM_Cost() + calculateAggregatedS_Cost();
    }
    
    /*
     * Calculates the total Price for the ParentPart as well as associated Parts, considering quantities as well
     */ 
     Decimal calculateAggregatedNetPriceForEntry() {
        Decimal total = 0;                
        Decimal totalAssociationsPricePerParentUnit = 0;   
             
        for ( CS_PartInformation pi : this.associatedParts) {
            totalAssociationsPricePerParentUnit += pi.totalNetPrice;
        }    
        
        if (this.parentPart != null) {
            total += this.parentPart.totalNetPrice;
            total += totalAssociationsPricePerParentUnit * this.parentPart.quantity;
        } else {
            total += totalAssociationsPricePerParentUnit;
        }
                
        return total;
    }
    
     Decimal calculateAggregatedPriceInclVatForEntry() {
        Decimal total = 0;
        Decimal totalAssociationsPricePerParentUnit = 0;  
        
        for ( CS_PartInformation pi : this.associatedParts) {
            totalAssociationsPricePerParentUnit += pi.totalPriceIncVAT;
        }
        
        if (this.parentPart != null) {
            total += this.parentPart.totalPriceIncVAT;
            total += totalAssociationsPricePerParentUnit * this.parentPart.quantity;
        } else {
            total += totalAssociationsPricePerParentUnit;
        }      
        
        return total;
    }
    
    /*
     * Calculates the total Material Cost for the ParentPart as well as associated Parts, considering quantities as well
     */ 
     Decimal calculateAggregatedM_Cost() {
        Decimal total = 0;
        Decimal totalAssociationsMCostPerParentUnit = 0;
        
        for ( CS_PartInformation pi : this.associatedParts) {
            if (pi.part.Contributing_to_Margin__c) {
                totalAssociationsMCostPerParentUnit += pi.totalMaterialsCost;            
            }
        }   
            
        if (this.parentPart != null) {
            if (this.parentPart.part.Contributing_to_Margin__c) {
                total += this.parentPart.totalMaterialsCost;
            }
            total += totalAssociationsMCostPerParentUnit * this.parentPart.quantity;
        } else {
            total += totalAssociationsMCostPerParentUnit; //for Bundles and multilookups Quantity is always 1
        }
               
        return total;
    }
    
    /*
     * Calculates the total Skill Cost for the ParentPart as well as associated Parts, considering quantities as well.
     * Considers pricebook
     */ 
     Decimal calculateAggregatedS_Cost() {
            
        Decimal total = 0;
        Decimal totalAssociationsSCostPerParentUnit = 0;
        
        for ( CS_PartInformation pi : this.associatedParts) {
            if (pi.part.Contributing_to_Margin__c) {
                totalAssociationsSCostPerParentUnit += pi.totalSkillsCost;            
            }
        }   
            
        if (this.parentPart != null) {
            if (this.parentPart.part.Contributing_to_Margin__c) {
                total += this.parentPart.totalSkillsCost;
            }
            total += totalAssociationsSCostPerParentUnit * this.parentPart.quantity;
        } else {
            total += totalAssociationsSCostPerParentUnit; //for Bundles and multilookups Quantity is always 1
        }
               
        return total;
    }
    
    
    public class CS_PartInformation {
        
        public CS_Part__c part {get; set;}
        
        public Decimal quantity {get; set;}
        //public Boolean minQuantity {get; set;} //for Flue multilookup - might be out of scope
        //public Boolean maxQuantity {get; set;} //for Flue multilookup - might be out of scope
               
        public List<CS_MaterialWrapper> materialsList {get; set;}
        public List<CS_SkillWrapper> skillsList {get; set;}
        
        //partPrice cannot be used anymore as in certain scenarios the Price__c needs to be overriden.
        //This means that all formula fields on Part_Price__c that use Price__c would be out of date.
        //public CS_Part_Price__c partPrice {get; set;} // DO NOT USE
        
        //Explicitly declare properties for Part_Price fields that are of interest.
        public Decimal price {get; set;} //Part_Price.Price__c or custom if IsPriceOverriden
        public Decimal listPrice {get; set;}
        public Decimal totalSkillsCostForUnit {get; set;} //set from CS_Part_Price (as could be Standard or Low)
        public Decimal totalMaterialsCostForUnit {get; set;} //set from CS_Part_Price
        
        // All the below properties were calculated values rerturned in the getter, but unless explictly set in the constructor they won't be available in the object returned to the client..
        public Decimal totalMaterialsCost {get; set;}
        public Decimal marginPreAllowances {get; set;}
        public Decimal priceVatIncl {get; set;}
        public Decimal vatAmount {get; set;}
        
        public Decimal geographicUpliftAmount {get; set;}
        
        // this is the total Price for all quantities
        public Decimal totalVatAmount {get; set;}
        public Decimal totalNetPrice {get; set;}
        public Decimal totalPriceIncVAT {get; set;}
        public Decimal totalSkillsCost {get; set;}

       
        /*
         * Constructor
         */
        public CS_PartInformation (CS_PartWrapper aPartWrapper, CS_RemotingParamWrapper attWrapper, String district, Decimal qty, Decimal geographicUpliftFactor) {
    
            Boolean isUpliftable = true;

            this.part = aPartWrapper.part;
            this.quantity = (qty != null ? qty : attWrapper.quantity);
            
            //Common bit
            //Part Price: Look for an exact District Code match. If no match exists, assign the 1st Price found. If no Price found, leave Null
            //Assumption is a maximum of 2 PartPrice records may be retrieved (national level & for specific district - otherwise it's a user data error
            CS_Part_Price__c partPrice = ((aPartWrapper.partPrices != null && aPartWrapper.partPrices.size() > 0) ? aPartWrapper.partPrices[0] : null );

            for (CS_Part_Price__c pp : aPartWrapper.partPrices) {
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
            this.price = (partPrice != null ? partPrice.Price__c : 0); //this may be overriden further down
            this.listPrice = this.price;
            
            this.totalSkillsCostForUnit = (partPrice != null ? partPrice.Total_S_Cost__c : 0);
            this.totalMaterialsCostForUnit = (partPrice!= null ? partPrice.Total_M_Cost__c : 0);

            //Populate Material List
            this.materialsList = new List<CS_MaterialWrapper>();
            for (CS_Part_Material__c pm : aPartWrapper.partMaterials) {
                this.materialsList.add(new CS_MaterialWrapper(pm));
            }
            
            //Populate Skills List
            this.skillsList = new List<CS_SkillWrapper>();
            for (CS_Part_Skill__c ps : aPartWrapper.partSkills) {
               this.skillsList.add(new CS_SkillWrapper(ps));
            }
            
            //Only the parent Part can have its Price overriden
            if (attWrapper != null && attWrapper.isPriceOverriden == true && this.part != null) {
                this.part.Description__c = attWrapper.lineItemDescription;
                this.price = attWrapper.attPrice;
                this.listPrice = this.price;
            }
            
            //override the part price if the part is upliftable
            if(isUpliftable){
                // calculate the geographical uplift amount and update the price
                this.geographicUpliftAmount = (geographicUpliftFactor/100) * this.price;
                //2016 pricing=round to 2 decimals
                this.price += this.geographicUpliftAmount;
                
               // this.price = this.price.SetScale(2);
            } else {
                this.geographicUpliftAmount = 0;
            }

            
            this.calculateFormulas(); //this must be done at the VERY END!!!
        }
        
        
        void calculateFormulas() {
            
            //TODO: MC make a change here, update the calculation of part price vat incl for geographical uplift

            this.totalMaterialsCost = ((totalMaterialsCostForUnit != null && quantity != null) ? (quantity * totalMaterialsCostForUnit) : 0);
            this.totalSkillsCost = ((totalSkillsCostForUnit != null && quantity != null) ? (quantity * totalSkillsCostForUnit) : 0);
            
            this.totalNetPrice = ((price != null && quantity != null) ? (quantity * price) : 0);
            
            Decimal totalPrice = ((quantity != null && this.price != null) ? (this.price * quantity) : 0); 
            this.marginPreAllowances = totalPrice - this.totalMaterialsCost - this.totalSkillsCost;
            
            this.priceVatIncl = (this.price != null ? this.price : 0);
            if (this.part != null && this.part.VAT_Percentage__c != null) {
                this.priceVatIncl += this.price * (this.part.VAT_Percentage__c /100);
                
                //2016 pricing round to 2 decimals
             //   this.priceVatIncl = this.priceVatIncl.SetScale(2);
            }
            
            this.vatAmount = ((this.price != null && this.part != null && this.part.VAT_Percentage__c != null) ? (this.price * this.part.VAT_Percentage__c/100) : 0); 
            
            this.totalVatAmount = ((vatAmount != null && quantity != null) ? (vatAmount * quantity) : 0);
            this.totalPriceIncVAT = ((priceVatIncl != null && quantity != null) ? (quantity * priceVatIncl) : 0);   
            
        }
        
        
        /*
         * For testing purposes!!! TEST
         */
        public CS_PartInformation() {}

        /* 
         * This constructor should be used when creating the parentPart. Only the parentPart can have its Price overriden
         * Do not use this for creating associated Parts.
         */
         /*
        public CS_PartInformation(CS_Part__c aPart, CS_RemotingParamWrapper attWrapper, String district) {
            this(aPart, attWrapper.quantity, district);
            
            if (attWrapper.isPriceOverriden && this.part != null) {
                this.part.Description__c = attWrapper.lineItemDescription;
                this.price = attWrapper.attPrice;
                
                //Part_Price__c properties will not be valid in this context (except for Cost-related information)
            }
            
            this.calculateFormulas();
        }
        */

        /*
         //This constructor is used to create Associated Parts. OverridingPrice is not allowed here.
         public CS_PartInformation(CS_Part__c aPart, Decimal qty, String district) {
            this.part = aPart;
            this.quantity = qty;
            //InstallationLocation?
            
            //Part Price: Look for an exact District Code match. If no exists, assign the 1st Price found. If no Price found, leave Null
            //Assumption is a maximum of 2 PartPrice records may be retrieved - otherwise it's a user data error
           
           
            system.debug('****part Prices: ' + aPart.CS_Part_Prices__r);
            CS_Part_Price__c partPrice = ((aPart.CS_Part_Prices__r != null && aPart.CS_Part_Prices__r.size() > 0) ? aPart.CS_Part_Prices__r[0] : null );
            for (CS_Part_Price__c pp : aPart.CS_Part_Prices__r) {
                if (pp.District_Code__c == district) {
                    partPrice = pp;
                }
            }
            
            
            system.debug('*** Part Price record found for Part ' + aPart.Name + ' (' + aPart.Id + '): ' + partPrice);
             
             //Populate fields that override the Part_Price__c defaults
             this.price = (partPrice != null ? partPrice.Price__c : 0); //this may be overriden
             this.totalSkillsCostForUnit = (partPrice != null ? partPrice.Total_S_Cost__c : 0);
             this.totalMaterialsCostForUnit = (partPrice != null ? partPrice.Total_M_Cost__c : 0);
            
            //Populate Material List
            this.materialsList = new List<CS_MaterialWrapper>();
            for (CS_Part_Material__c pm : aPart.CS_Part_Materials__r) {
                this.materialsList.add(new CS_MaterialWrapper(pm));
            }
            
            //Populate Skills List
            this.skillsList = new List<CS_SkillWrapper> ();
            for (CS_Part_Skill__c ps : aPart.CS_Part_Skills__r) {
                this.skillsList.add(new CS_SkillWrapper(ps));
            } 
            
            this.calculateFormulas();
            
        }
        */
    }
    
    public class CS_MaterialWrapper {
        public String name {get; set;}
        public String description {get; set;}
        public Decimal unitCost {get; set;}
        public Decimal quantity {get; set;}
        public Decimal totalCost {get;  set;}
        
        public CS_MaterialWrapper(CS_Part_Material__c pm) {
            this.name = pm.Material_Name__c;
            this.description = pm.Material_Description__c;
            this.unitCost = pm.Material_Cost_Per_Unit__c;
            this.quantity = pm.Quantity__c;
            
            this.totalCost = ((unitCost != null && quantity != null) ? unitCost * quantity : 0);
        }
    }
    
    public class CS_SkillWrapper {
        public String name {get; set;}
        public String skillCode {get; set;}
        public Decimal costPerHrStandard {get; set;}
        public Decimal costPerHrLowCost {get; set;}
        public Decimal hours {get; set;}
        
        public Decimal totalStandardCost {get;  set;}
        public Decimal totalLowCost {get;  set;}
        
        public CS_SkillWrapper(CS_Part_Skill__c ps) {
            this.name = ps.Skill_Name__c;
            this.skillCode = ps.Skill_Code__c;
            this.costPerHrStandard = ps.Skill_Cost_Per_Hour_Standard__c;
            this.costPerHrLowCost = ps.Skill_Cost_Per_Hour_Low_Cost__c;
            this.hours = ps.No_of_Hours__c;
            
            this.totalStandardCost = ((costPerHrStandard != null && hours != null) ? costPerHrStandard * hours : 0);
            this.totalLowCost = ((costPerHrLowCost != null && hours != null) ? costPerHrLowCost * hours : 0); 
            
        }
    }

}