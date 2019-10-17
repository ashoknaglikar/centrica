public without sharing class CS_ProductBasketPdfController {
    
    public String assignedToHsa {get; set;}
    
    public List<String> installationAddress {get;set;}
    public List<String> billingAddress {get;set;}
    public PaymentData paymentData {get;set;}
    public QuoteDetails quoteDetails {get;set;}
    
    public String reasonForQuotation {get; set;}
    public List<Section> quoteItems {get; set;}
    
    public Id basketId {get; set;}
    
    public String pageContent {get;set;}
    
    private static final String RADIATOR = 'Radiator_';
    private static final String ACTUAL = 'Actual_Radiator_';
    private static final String PLACEHOLDER = 'Placeholder_';
    private static final String FITTINGBUNDLE = 'Fitting_Bundle_';
    private static final Map<String, String> fittingBundleNameMap = new Map<String, String> 
                                                    {'New location in same room' => 'new fix',
                                                     'Same place, different size' => 'replacement',
                                                     'Same place, same size' => 'replacement' };
    
    public PageReference displayPDF(){
        System.debug('pageContent: ' + pageContent);
        Attachment att;
        
        List<Attachment> attList = [Select Id, Name, Body, ParentId from Attachment where ParentId = :basketId and Name = 'PDF_TEMP_ATTACHMENT.txt'];
        if(attList.size() > 0) {
            att = attList[0];
        } else {
            att = new Attachment();
            att.ParentId = basketId;
        }
        att.Body = Blob.valueOf(pageContent);
        att.Name = 'PDF_TEMP_ATTACHMENT.txt';
        upsert att;
       
        PageReference pr = new PageReference('/apex/CS_Pdf');
        pr.getParameters().put('id', basketId);
        pr.setRedirect(true);
        return pr;
    }
    
    public CS_ProductBasketPdfController(ApexPages.StandardController c) {
        basketId = c.getRecord().Id;
        if(basketId != null) {
            
            cscfga__Product_Basket__c basket = [select Id, Name, Appointment__c, Appointment__r.Opportunity__c, 
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.Name,
                                                Appointment__r.Opportunity__r.Install_Address_Street__c,
                                                Appointment__r.Opportunity__r.Install_Postcode__c,
                                                Appointment__r.Opportunity__r.SC_Home_Phone__c,
                                                Appointment__r.Opportunity__r.SC_Mobile_Phone__c,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingStreet,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c,
                                                Appointment__r.Opportunity__r.Account.Primary_Contact__r.MobilePhone,
                                                Appointment__r.Assigned_To_Name__c,
                                                Appointment__r.CHI_Lead_No__c
                                                
                                                from cscfga__Product_Basket__c 
                                                where Id = :basketId];
            
            Id appointmentId = basket.Appointment__c;
            Id opportunityId = basket.Appointment__r.Opportunity__c;
            
            Map<Id, cscfga__Product_Configuration__c> configs = new Map<Id, cscfga__Product_Configuration__c> ([select Id, Name, cscfga__Product_Basket__r.cscfga__Basket_Status__c, cscfga__Product_Definition__c, cscfga__Configuration_Status__c
                                                                                                                from cscfga__Product_Configuration__c 
                                                                                                                where cscfga__Product_Basket__c = :basketId
                                                                                                                and cscfga__Parent_Configuration__c = null]);
                                                
            //get all attributes and attribute fields
            List<cscfga__Attribute__c> allAttributes = [select  cscfga__Annualised_Price__c, cscfga__Attribute_Definition__c, cscfga__Billing_Price__c, cscfga__Cascade_value__c, cscfga__Discount_Amount__c, cscfga__Discount_Type__c, 
                                                                cscfga__Display_Value__c, cscfga__Hidden__c, cscfga__Is_Line_Item__c, cscfga__Is_rate_line_item__c, cscfga__Is_Read_Only__c, cscfga__Is_Required__c, cscfga__is_active__c, 
                                                                cscfga__Key__c, cscfga__Line_Item_Description__c, cscfga__Line_Item_Sequence__c, cscfga__List_Price__c, Name, cscfga__Attribute_Definition__r.Name, cscfga__Price__c, 
                                                                cscfga__Product_Configuration__c, Id,  cscfga__Recurring__c, cscfga__Value__c,
                                                                (select     cscfga__Attribute__c, 
                                                                            Name, 
                                                                            Id, 
                                                                            cscfga__Value__c
                                                                from cscfga__Attribute_Fields__r)
                                                        from cscfga__Attribute__c 
                                                        where cscfga__Product_Configuration__r.cscfga__Product_Basket__c = : basketId];
            
            Map<Id, Map<String, cscfga__Attribute__c>> configAttributesMap = new Map<Id, Map<String, cscfga__Attribute__c>>(); //in case more than 1 configs are supported per basket in the future
            for (cscfga__Attribute__c att : allAttributes) {
                if (!configAttributesMap.containsKey(att.cscfga__Product_Configuration__c)) {
                    configAttributesMap.put(att.cscfga__Product_Configuration__c, new Map<String, cscfga__Attribute__c> {att.Name => att});
                }
                else {
                    configAttributesMap.get(att.cscfga__Product_Configuration__c).put(att.Name, att);
                }
            }
            
            List<Attachment> attachmentList = [SELECT Id, Name, Body, ParentId FROM Attachment where ParentId in :configs.keySet()];
            Map<Id, Attachment> configAttachmentMap = new Map<Id, Attachment>();
            for (Attachment doc : attachmentList) {
                configAttachmentMap.put(doc.ParentId, doc);
            }
            
            // installation address
            String Name = String.isNotEmpty(basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.Name) ? basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.Name: '';
            String Street = String.isNotEmpty(basket.Appointment__r.Opportunity__r.Install_Address_Street__c) ? basket.Appointment__r.Opportunity__r.Install_Address_Street__c: '';
            String PostalCode = String.isNotEmpty(basket.Appointment__r.Opportunity__r.Install_Postcode__c) ? basket.Appointment__r.Opportunity__r.Install_Postcode__c : '';
            String Telephone = String.isNotEmpty(basket.Appointment__r.Opportunity__r.SC_Home_Phone__c) ? basket.Appointment__r.Opportunity__r.SC_Home_Phone__c : '';
            String Mobile = String.isNotEmpty(basket.Appointment__r.Opportunity__r.SC_Mobile_Phone__c) ? basket.Appointment__r.Opportunity__r.SC_Mobile_Phone__c : '';
            Address installationAddressObject = new Address(Name, Street, PostalCode, Telephone, Mobile);
            installationAddress = installationAddressObject.toList();
            
            // billing address
            String BaName = String.isNotEmpty(basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.Name) ? basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.Name : '';
            String BaStreet = String.isNotEmpty(basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingStreet) ? basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingStreet : '';
            String BaPostalCode = String.isNotEmpty(basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode) ? basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode : '';
            String BaTelephone = String.isNotEmpty(basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c) ? basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.Best_Phone__c : '';
            String BaMobile = String.isNotEmpty(basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MobilePhone) ? basket.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MobilePhone : '';
            Address billingAddressObject = new Address(BaName, BaStreet, BaPostalCode, BaTelephone, BaMobile);
            billingAddress = billingAddressObject.toList();
            
            for (Id configId : configs.keySet()) {
                Map<String, cscfga__Attribute__c> attributeMap = configAttributesMap.get(configId);
                
                // assigned to hsa
                String hsaId = attributeMap.get('Assigned To Employee') != null ? attributeMap.get('Assigned To Employee').cscfga__Value__c : '';
                if(String.isNotEmpty(hsaId)) {
                    Employee__c hsa = [Select Id, First_Name__c, Last_Name__c, Phone_No__c from Employee__c where Id =:hsaId limit 1];
                    String hsaName = hsa.First_Name__c + ' ' + hsa.Last_Name__c;
                    assignedToHsa = 'To discuss or accept your quotation please contact ' + hsaName + ' on ' + hsa.Phone_No__c + ' or alternatively call us on '+Label.Phone_Inbound_IVR;
                } else {
                    assignedToHsa = '';
                }
                
                reasonForQuotation = attributeMap.get('Reason for Quotation') != null ? attributeMap.get('Reason for Quotation').cscfga__Value__c : '';
                
                // payment info
                String TotalPricePayable = attributeMap.get('Total Price Payable') != null ? attributeMap.get('Total Price Payable').cscfga__Value__c : '';
                String Deposit = attributeMap.get('Actual Deposit') != null ? attributeMap.get('Actual Deposit').cscfga__Value__c : '';
                String DepositReference = attributeMap.get('Deposit Receipt Number') != null ? attributeMap.get('Deposit Receipt Number').cscfga__Value__c : '';
                String DepositPaidBy = attributeMap.get('Payment Type') != null ? attributeMap.get('Payment Type').cscfga__Value__c : ''; 
                
                String Balance = String.valueOf(returnDecimal(attributeMap.get('Total Price Payable') != null ? attributeMap.get('Total Price Payable').cscfga__Value__c : '') - returnDecimal(attributeMap.get('Actual Deposit') != null ? attributeMap.get('Actual Deposit').cscfga__Value__c : ''));
                
                String BalancePaidBy = attributeMap.get('Payment Option') != null ? attributeMap.get('Payment Option').cscfga__Value__c : '';
                paymentData = new PaymentData(TotalPricePayable, Deposit, DepositReference, DepositPaidBy, Balance, BalancePaidBy);
                
                // quote details
                String QuoteDate = attributeMap.get('Quote Creation Date') != null ? attributeMap.get('Quote Creation Date').cscfga__Value__c : '';
                String QuoteNumber = attributeMap.get('Quote Reference') != null ? attributeMap.get('Quote Reference').cscfga__Value__c : '';
                String TransactionId = basket.Appointment__r.CHI_Lead_No__c;
                quoteDetails = new QuoteDetails(QuoteDate, QuoteNumber, TransactionId);
                
                // build the list of items to be displayed similar to the offline quote
                quoteItems = buildQuote(configAttachmentMap.get(configId), attributeMap);

                break;
            }
        }
    }
    
    /**
     * A class representing client addresses.
     */
    public class Address {
        public String Name {get; set;}
        public String Street {get; set;}
        public String PostalCode {get; set;}
        public String Telephone {get; set;}
        public String Mobile {get; set;}
        
        public Address(String n, String s, String pc, String t, String m) {
            this.Name = n;
            this.Street = s;
            this.PostalCode = pc;
            this.Telephone = t;
            this.Mobile = m;
        }
        
        public List<String> toList() {
            return new List<String> {Name, Street, PostalCode, Telephone, Mobile};
        }
        
        public override String toString() {
            
            List<String> addressList = new List<String> {Name, Street, PostalCode, Telephone, Mobile };
            
            Integer j = 0;
            while (j < addressList.size())
            {
                if(String.isEmpty(addressList.get(j))) {
                    addressList.remove(j);
                } else {
                    j++;
                }
            }
            return String.join(addressList, '\n');
        }
    }
    
    /**
     * A class representing client payment data to be shown on the quote.
     */
    public class PaymentData {
        public String TotalPayable {get; set;}
        public String Deposit {get; set;}
        public String DepositReference {get; set;}
        public String DepositPaidBy {get; set;}
        public String Balance {get; set;}
        public String BalanceToBePaidBy {get; set;}
        
        public PaymentData(String tp, String d, String dr, String dpb, String b, String btbpb) {
            this.TotalPayable = formatPrice(tp);
            this.Deposit = formatPrice(d);
            this.DepositReference = dr;
            this.DepositPaidBy = dpb;
            this.Balance = formatPrice(b);
            this.BalanceToBePaidBy = btbpb;
        }
        
        public List<String> toList() {
            return new List<String> {TotalPayable, Deposit, DepositReference, DepositPaidBy, Balance, BalanceToBePaidBy};
        }
    }
    
    /**
     * A class representing quote details to be shown on the quote. 
     */
    public class QuoteDetails {
        public String QuoteDate {get; set;}
        public String QuoteNumber {get; set;}
        public String TransactionId {get; set;}
        
        public QuoteDetails(String qd, String qn, String tid) {
            this.QuoteDate = toFullMonth(qd);
            this.QuoteNumber = qn;
            this.TransactionId = tid;
        }
        
        private String toFullMonth(String s) {
            Map<Integer, String> monthNames = new Map<Integer, String>{
                1 => 'January',
                2 => 'February', 
                3 => 'March',
                4 => 'April',
                5 => 'May',
                6 => 'June',
                7 => 'July',
                8 => 'August',
                9 => 'September',
                10 => 'October',
                11 => 'November',
                12 => 'December'
            };
            
            try {
                Date d = returnDate(s);
                String returnedDate = monthNames.get(d.month()) + ' ' + d.day() + ', ' + d.year();
                return returnedDate;
            } catch (Exception e) {
                
            }
            return s;
        }
    }
    
    /**
     * A class representing a section on the pdf quote.
     */
    public class Section {
        public String id {get; set;}
        public String Name {get; set;}
        public Decimal Sequence {get; set;}
        public Decimal Totals {get; set;}
        public List<LineItem> lineItems {get; set;}
        public List<Section> sections {get; set;}
        
        public Section(String id, String name, Decimal sequence) {
            this.Id = id;
            this.Name = name;
            this.Sequence = sequence;
            this.lineItems = new List<LineItem>();
            this.sections = new List<Section>();
        }
        
        public Section(String name, Decimal totals) {
            this.Name = name;
            this.Totals = totals;
            this.lineItems = new List<LineItem>();
            this.sections = new List<Section>();
        }
        
        public void addLineItem(LineItem l) {
            this.lineItems.add(l);
        }
        
        public void addSection(Section s) {
            this.sections.add(s);
        }
    }
    
    /**
     * A class representing line items under particular sections on the pdf quote.
     */
    public class LineItem {
        public String Description {get; set;}
        public Decimal Quantity {get; set;}
        public Decimal Price {get; set;}
        public Decimal Total {get; set;}
        
        public LineItem(String d, Decimal q, Decimal price, Decimal t) {
            this.Description = removeSpecialCharacters(d);
            this.Quantity = q;
            this.Price = price.setScale(2, RoundingMode.HALF_UP);
            this.Total = t.setScale(2, RoundingMode.HALF_UP);
        }
    }
    
    /**
     * Tries to return a date from a provided string.
     * Returns null if the parsing was unsuccessful.
     * @param {String} d   A string representation of a date.
     * @returns {Date}
     */
    private static Date returnDate(String d){
        if (d == null) {
            return null;
        }
        try {
          Date parsedDate = Date.parse(d); 
          return parsedDate; 
        }
        catch (TypeException e) {
          try {
                Date parsedDate = Date.valueOf(d); 
                return parsedDate;
            }
            catch (TypeException ex) {
              return null;
            }        
        }
        return null;    
    }
    
    /**
     * Formatts the price to 2 decimal values.
     * @param{String} p   A string representation of a price.
     * @return{Decimal} Returns a price in a decimal format rounded to 2 decimal places.
     */
    public static String formatPrice(String p) {
        try {
            Decimal priceDecimal = Decimal.valueOf(p); 
            priceDecimal = priceDecimal.setScale(2, RoundingMode.HALF_UP);
            return String.valueOf(priceDecimal);
        } catch (Exception ex) {
            
        }
        return p;
    }

    /**
     * Replaces any special characters present in the provided string.
     * @param{String} s
     * @return{String} Returns a string without special characters.
     */
    public static String removeSpecialCharacters(String s) {
        if(s != null && s.length() != 0) {
            return s.replaceAll('&amp;', '&');
        } else {
            return s;
        }
    }
    
    /**
     * Builds the model to be passed to the visual force page. Contains all of the items 
     * to be shown on the pdf quote.
     * @param {Attachment} att   An attachment containing the partsModel.
     * @param {Map<String, cscfga__Attribute__c>} Map of attributes, used for allowances values.
     * @returns {List<Section>} Returns a list of section objects which are displayed on the visualforce page.
     */
    private static List<Section> buildQuote(Attachment att, Map<String, cscfga__Attribute__c> attributeMap) {
        //initialize maps for radiators and bundles
        Map<String, CS_PartModelEntry> radiatorMap = new Map<String, CS_PartModelEntry>();
        Map<String, CS_PartModelEntry> fittingBundleMap = new Map<String, CS_PartModelEntry>();
        
        
        // get all sections
        // sort all sections
        String sectionQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Template_Section_Header__c') + ' From CS_Template_Section_Header__c ORDER BY Sequence__c ASC NULLS LAST';
        List<CS_Template_Section_Header__c> allSections = ((List<CS_Template_Section_Header__c>)database.query(sectionQuery));
        Map<Id, CS_Template_Section_Header__c> allSectionsMap = new Map<Id, CS_Template_Section_Header__c>(allSections);
        
        // create a map of level1 to level2 sections
        Map<Id, List<Id>> level1toLevel2Map = new Map<Id, List<Id>>();
        for(CS_Template_Section_Header__c section : allSections) {
            // check if a section is a level 2 section
            if(section.Level_1_Section__c != null) {
                if(level1toLevel2Map.get(section.Level_1_Section__c) == null) level1toLevel2Map.put(section.Level_1_Section__c, new List<Id>());
                level1toLevel2Map.get(section.Level_1_Section__c).add(section.Id);
            } else {
                if(level1toLevel2Map.get(section.Id) == null) level1toLevel2Map.put(section.Id, new List<Id>());
            }
        }
        
        // create a map of sections with their parts
        Map<Id, List<LineItem>> sectionIdToPartsModelMap = new Map<Id, List<LineItem>>();
        if (att != null) {
            Map<String, CS_PartModelEntry> partsModel = (Map<String, CS_PartModelEntry>)JSON.deserialize(att.Body.toString(), Map<String, CS_PartModelEntry>.class); 
            
            for(String key : partsModel.keySet()) {
                CS_PartModelEntry item = partsModel.get(key);
                
                if ((item.isBundle && item.isLineItem) || (item.isPart && item.isLineItem)) {
                
                    // add a check for radiators
                    if(isRadiatorAttribute(item.attRef)) {
                        addRadiatorOrFittingBundle(item, radiatorMap, fittingBundleMap);
                    } else {
                        if (item.isPart && !(item.isMultilookup)) {
                            // add the part
                            String description = String.isNotEmpty(item.parentPart.part.Quote_Description__c) ? item.parentPart.part.Quote_Description__c : (String.isNotEmpty(item.parentPart.part.Description__c) ? item.parentPart.part.Description__c : (String.isNotEmpty(item.parentPart.part.Name) ? item.parentPart.part.Name : ''));
                            Boolean showAssociatedParts = item.parentPart.part.Show_Parts__c;
                            if(showAssociatedParts == true) {
                                // add the parent part
                                LineItem li = new LineItem(description, item.parentPart.quantity, item.parentPart.totalNetPrice, item.parentPart.totalPriceIncVAT);
                            
                                if(item.parentPart.part.CS_Template_Section_Header__c != null) {
                                    if(sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c) == null) sectionIdToPartsModelMap.put(item.parentPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                                    sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c).add(li);   
                                }
                                // add the associated parts
                                for (CS_PartModelEntry.CS_PartInformation  associatedPart : item.associatedParts) {
                                    String aPdescription = String.isNotEmpty(associatedPart.part.Quote_Description__c) ? associatedPart.part.Quote_Description__c : (String.isNotEmpty(associatedPart.part.Description__c) ? associatedPart.part.Description__c : (String.isNotEmpty(associatedPart.part.Name) ? associatedPart.part.Name : ''));
                                    LineItem aPli = new LineItem(aPdescription, associatedPart.quantity, associatedPart.totalNetPrice, associatedPart.totalPriceIncVAT);
                            
                                    if(item.parentPart.part.CS_Template_Section_Header__c != null) {
                                        if(sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c) == null) sectionIdToPartsModelMap.put(item.parentPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                                        sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c).add(aPli);     
                                    }
                                } 
                            } else {
                                LineItem li = new LineItem(description, item.parentPart.quantity, item.aggregatedNetPrice, item.aggregatedPriceInclVAT);
                            
                                if(item.parentPart.part.CS_Template_Section_Header__c != null) {
                                    if(sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c) == null) sectionIdToPartsModelMap.put(item.parentPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                                    sectionIdToPartsModelMap.get(item.parentPart.part.CS_Template_Section_Header__c).add(li);   
                                }
                            }
                        } else if (item.isBundle) {
                            Boolean showParts = item.parentBundle.Show_Parts__c;
                            if (showParts == true) {
                                // add all associated parts
                                for (CS_PartModelEntry.CS_PartInformation  associatedPart : item.associatedParts) {
                                    String description = String.isNotEmpty(associatedPart.part.Quote_Description__c) ? associatedPart.part.Quote_Description__c : (String.isNotEmpty(associatedPart.part.Description__c) ? associatedPart.part.Description__c : (String.isNotEmpty(associatedPart.part.Name) ? associatedPart.part.Name : ''));
                                    LineItem li = new LineItem(description, associatedPart.quantity, associatedPart.totalNetPrice, associatedPart.totalPriceIncVAT);
                            
                                    if(associatedPart.part.CS_Template_Section_Header__c != null) {
                                        if(sectionIdToPartsModelMap.get(associatedPart.part.CS_Template_Section_Header__c) == null) sectionIdToPartsModelMap.put(associatedPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                                        sectionIdToPartsModelMap.get(associatedPart.part.CS_Template_Section_Header__c).add(li);    
                                    }
                                }                
                            } else {
                                // add the bundle
                                String description = String.isNotEmpty(item.parentBundle.Quote_Description__c) ? item.parentBundle.Quote_Description__c : (String.isNotEmpty(item.parentBundle.Description__c) ? item.parentBundle.Description__c : (String.isNotEmpty(item.parentBundle.Name) ? item.parentBundle.Name : ''));
                                LineItem li = new LineItem(description, item.attLastQuantity, item.aggregatedNetPrice, item.aggregatedPriceInclVAT);
                                
                                if(item.parentBundle.CS_Template_Section_Header__c != null) {
                                    if(sectionIdToPartsModelMap.get(item.parentBundle.CS_Template_Section_Header__c) == null) sectionIdToPartsModelMap.put(item.parentBundle.CS_Template_Section_Header__c, new List<LineItem>());
                                    sectionIdToPartsModelMap.get(item.parentBundle.CS_Template_Section_Header__c).add(li);  
                                }
                            }
                        }
                    }
                }
            }
            
            addRadiatorsToSectionList(radiatorMap, fittingBundleMap, sectionIdToPartsModelMap);
        }   
        
        List<Section> quoteItems = new List<Section>();
        
        // if the quote is a low cost quote an additional section needs to be added
        Boolean isLowCostSection = attributeMap.get('Pricebook Type') != null ? (attributeMap.get('Pricebook Type').cscfga__Value__c == CS_Constants.CS_PricebookType_LowCost ? true : false) : false;
        if(isLowCostSection) {
            Section lowCostSection = new Section('noId', 'Quotation details', 0);
            lowCostSection.addLineItem(new LineItem('The price quoted is a special offer and cannot be used in conjunction with any other British Gas boiler offer.', 0, 0, 0));
            quoteItems.add(lowCostSection);
        }
        
        // iterate through all of the sorted sections
        // create a list of section objects with their partsModel
        for(CS_Template_Section_Header__c sortedSection : allSections) {
            if(sortedSection.Level_1_Section__c == null) {
                Section sectionObject = new Section(sortedSection.Id, sortedSection.Name, sortedSection.Sequence__c);
                sectionObject.lineItems = sectionIdToPartsModelMap.get(sortedSection.Id);
                // if a level1 section has level 2 sections we need to iterate through those as well
                for(CS_Template_Section_Header__c sortedLevel2Section : allSections) {
                    if(sortedLevel2Section.Level_1_Section__c == sortedSection.Id) {
                        Section sectionLevel2Object = new Section(sortedLevel2Section.Id, sortedLevel2Section.Name, sortedLevel2Section.Sequence__c);
                        sectionLevel2Object.lineItems = sectionIdToPartsModelMap.get(sortedLevel2Section.Id);
                        sectionObject.addSection(sectionLevel2Object);
                    }    
                }
                quoteItems.add(sectionObject);
            }
        }
        
        // remove all empty sections
        Integer i = 0;
        while (i < quoteItems.size()) {
            if(quoteItems.get(i).sections.size() != 0) {
                Integer j = 0;
                while (j < quoteItems.get(i).sections.size()) {
                    if(quoteItems.get(i).sections.get(j).lineItems == null && quoteItems.get(i).sections.get(j).sections.size() == 0) {
                        quoteItems.get(i).sections.remove(j);
                    } else {
                        j++;
                    }
                }
            }
            
            if(quoteItems.get(i).lineItems == null && quoteItems.get(i).sections.size() == 0) {
                quoteItems.remove(i);
            } else {
                i++;
            }
        }
        
        // add the pricing
        // Pricing:
        Section pricing = new Section('', 'Pricing:', 996);
        Decimal grossPrice = returnDecimal(attributeMap.get('Gross Price incl VAT') != null ? attributeMap.get('Gross Price incl VAT').cscfga__Value__c : '0.00');
        pricing.addLineItem(new LineItem('Total Gross Price (inc. VAT)', 0, 0, grossPrice));
        
        //add the allowances
        List<String> allowanceAttributes = new List<String> {'Allowance1' , 'Allowance2', 'Allowance3', 'Allowance4', 'Allowance5', 'Allowance6'};
        
        Section discounts = new Section('', 'Discounts:', 997);
        for(String attr : allowanceAttributes) {
            cscfga__Attribute__c allowance = attributeMap.get(attr);
            if (allowance != null && allowance.cscfga__Value__c != null && allowance.cscfga__Value__c != '') {
                String isApplied = 'FALSE';
                String allowanceName = '';
                Decimal allowanceActualValue = 0;
                
                for (cscfga__Attribute_Field__c af : allowance.cscfga__Attribute_Fields__r) {
                    if (af.Name == 'AllowanceName') {
                        allowanceName = af.cscfga__Value__c;
                    }
                    else if (af.Name == 'ActualAmount') {
                        allowanceActualValue = Decimal.valueOf(af.cscfga__Value__c);
                    } 
                    else if (af.Name == 'Is_Applied'){
                        isApplied = af.cscfga__Value__c;
                    }
                }
                
                if(isApplied == 'TRUE'){
                    LineItem al = new LineItem(allowanceName, 0, 0, allowanceActualValue); //DO NOT DISPLAY NET FOR ALLOWANCES
                    discounts.addLineItem(al);
                }         
            }
        }
        
        pricing.addSection(discounts);
        
        // add the total discrounts
        Decimal totalAllowances = returnDecimal(attributeMap.get('Total Allowance Value') != null ? attributeMap.get('Total Allowance Value').cscfga__Value__c : '0.00');
        Section totalDiscounts = new Section('Total Discounts:', totalAllowances); 
        pricing.addSection(totalDiscounts);
        
        // add the total net price 
        // Total Net Price (incl. VAT)
        Decimal totalPricePayable = returnDecimal(attributeMap.get('Total Price Payable') != null ? attributeMap.get('Total Price Payable').cscfga__Value__c : '0.00');
        Section totalNetPrice = new Section('Total Net Price (inc. VAT):', totalPricePayable);
        pricing.addSection(totalNetPrice);
        
        quoteItems.add(pricing);
        
        return quoteItems;
    }
    
    /**
     * Checks whether an attribute reference starts with Radiator_ and contains
     * Placeholder_ or Actual_Radiator_ or Fitting_Bundle_
     * @param {String} attRef  An attribute reference which will be checked.
     * @returns {Boolean} Whether or not an attribute is a radiator attribute.
     */
    private static Boolean isRadiatorAttribute(String attRef) {
        if(attRef.startsWith(RADIATOR)) {
            if(attRef.contains(PLACEHOLDER) || attRef.contains(ACTUAL) || attRef.contains(FITTINGBUNDLE)) {
                return true;    
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
        
    /**
     * Adds the radiator or fitting bundle to their respective maps.
     * @param {CS_PartModelEntry} item   An partmodelentry.
     * @param {Map<String, CS_PartModelEntry>} radiatorMap  
     * @param {Map<String, CS_PartModelEntry>} fittingBundleMap
     */
    private static void addRadiatorOrFittingBundle(CS_PartModelEntry item, Map<String, CS_PartModelEntry> radiatorMap, Map<String, CS_PartModelEntry> fittingBundleMap) {
        // get reference for map
        String attRef = item.attRef;
        Integer len = RADIATOR.length() + 1;
        String index = attRef.substring(0, len);
        
        // add placeholders and actuals to radiator map
        // add fitting bundles to fitting bundle map
        if(attRef.contains(PLACEHOLDER) || attRef.contains(ACTUAL)) {
            radiatorMap.put(index, item);
        } else if(attRef.contains(FITTINGBUNDLE)) {
            fittingBundleMap.put(index, item);
        }
    }
    
    /**
     * Adds the constructed line items to the partsModel map to be displayed on the visualforce page.
     * It iterates through all of the radiators and fitting bundles and constructs line items out of them.
     * @param {Map<String, CS_PartModelEntry>} radiatorMap  A map of all radiator parts.
     * @param {Map<String, CS_PartModelEntry>} fittingBundleMap  A map of all the fitting bundles.
     * @param {Map<Id, List<LineItem>>} sectionIdToPartsModelMap  A map of sections and parts.
     */
    private static void addRadiatorsToSectionList(Map<String, CS_PartModelEntry> radiatorMap, Map<String, CS_PartModelEntry> fittingBundleMap, Map<Id, List<LineItem>> sectionIdToPartsModelMap) {
        // iterate radiator map
        for(String key : radiatorMap.keySet()) {
            CS_PartModelEntry rad = radiatorMap.get(key);
            CS_PartModelEntry fitBundle = fittingBundleMap.get(key);
    
            // construct radiator and add to section list
            if(rad != null) {
                String description = String.isNotEmpty(rad.parentPart.part.Quote_Description__c) ? rad.parentPart.part.Quote_Description__c : (String.isNotEmpty(rad.parentPart.part.Description__c) ? rad.parentPart.part.Description__c : (String.isNotEmpty(rad.parentPart.part.Name) ? rad.parentPart.part.Name : ''));
                Decimal aggregatedPriceInclVAT = rad.aggregatedPriceInclVAT;
                Decimal aggregatedNetPrice = rad.aggregatedNetPrice;
                
                if(fitBundle != null) {
                    // construct a description with fitting bundle
                    String fittingBundleName = fittingBundleNameMap.get(fitBundle.parentBundle.Fitting_Pack__c);
                    description += ' (' + fittingBundleName + ') x1';
                    // add the fitting price to the radiator price
                    Decimal fittingBundlePriceInclVAT = fitBundle.aggregatedPriceInclVAT;
                    Decimal fittingBundNetPrice = fitBundle.aggregatedNetPrice;
                    aggregatedPriceInclVAT += fittingBundlePriceInclVAT;
                    aggregatedNetPrice += fittingBundNetPrice;
                }

                // add the radiator along with the fitting bundle
                
                LineItem li = new LineItem(description, rad.parentPart.quantity, aggregatedNetPrice, aggregatedPriceInclVAT);
                
                if(rad.parentPart.part.CS_Template_Section_Header__c != null) {
                    if(sectionIdToPartsModelMap.get(rad.parentPart.part.CS_Template_Section_Header__c) == null) sectionIdToPartsModelMap.put(rad.parentPart.part.CS_Template_Section_Header__c, new List<LineItem>());
                    sectionIdToPartsModelMap.get(rad.parentPart.part.CS_Template_Section_Header__c).add(li);    
                }
            }
        }
    }
    
    /**
     * Tries to parse a Decimal value from a provided String value.
     * Returns 0.00 if the parsing was unsuccessful.
     * @param {String} value    A string representation of a decimal value.
     * @returns {Decimal}
     */ 
    private static Decimal returnDecimal(String value){
        try {
            return Decimal.valueOf(value).setScale(2, RoundingMode.HALF_UP); 
        } catch (Exception ex){
            return 0.00;
        }   
    }  
}