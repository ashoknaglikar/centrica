/*
     * This class is used to pass the required values from JS Remoting to the getPartModelInformation().
     * Every instance represents at attribute that had its value changed since the last time the Parts Model was built.
     */
    global class CS_RemotingParamWrapper {
        
        public String attRef {get; set;}    //attribute Id (not Salesforce Id!)
        public String attValue {get;set; } //This can be a PartId, a BundleId or a comma separated list of PartIds (when attribute is a multilookup)
        public Decimal attPrice {get;set; } //relevant if isPriceOverriden = true
        public Boolean isLineItem {get; set;} //set by Configurator
        public Decimal quantity {get; set;} //for multilookups, this will be assumed to always be 1
        
        public String lineItemDescription {get; set;}
        public Boolean isPart {get; set;} //can be multilookup!
        public Boolean isBundle {get; set;} //cannot be multilookup
        public Boolean isMultilookup {get; set;} //cannot be bundle
        public Boolean isPlaceholder {get; set;} 
        public Boolean isPriceOverriden {get; set;} //get Price from Attribute Price field, rather than from PartPrice
        
        public String installationLocation {get; set;}
        public String installationNotes {get; set;}
        
        //add any additional info that needs to be passed from Configurator to the Parts Model...eg DescriptionForCustomer etc...
        
        public CS_RemotingParamWrapper(String atbRef, String atbVal, Decimal atbPrice, Decimal attQuantity, String attDesc,Boolean attIsLineItem, Boolean attIsPart, Boolean attIsBundle, 
                                        Boolean attIsMultiLookup, Boolean attIsPlaceholder, Boolean attIsPriceOverriden, String installLocation, String installationNotes) {
            this.attRef = atbRef;
            this.attValue = atbVal;
            this.attPrice = atbPrice;
            this.quantity = attQuantity;
            this.lineItemDescription = attDesc;
            this.isLineItem = attIsLineItem;
            this.isPart = attIsPart;
            this.isBundle = attIsBundle;
            this.isMultilookup = attIsMultilookup;
            this.isPlaceholder = attIsPlaceholder;
            this.isPriceOverriden = attIsPriceOverriden;
            this.installationLocation = installLocation;
            this.installationNotes = installationNotes;
        }
     
    }