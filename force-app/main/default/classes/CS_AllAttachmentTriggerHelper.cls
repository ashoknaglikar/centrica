public class CS_AllAttachmentTriggerHelper {

public static void createBMQuoteAndQuoteProducts(Map<Id, Attachment> triggerMap) {
        try{

        // system.debug('********** getting a list of affected attachments');
        
        System.debug('MY USER ----------------------- USING AaJSON function');
        system.debug('triggerMap='+triggerMap);
        String pdfQuoteNameFilter = CS_Constants.PdfQuoteFileNamePrefix + '%';
        String pdfConfirmationFormNameFilter = CS_Constants.PdfCustomerConfirmationFormPrefix + '%';
        String installationNotes = CS_Constants.InstallationNotesPDF + '%';
        
        //only 4 types of Attachments we are interested in from incoming list (partsModel.txt and QuotePdf)
        List<Attachment> affectedAttachments = 
                [Select Id, ParentId, Name, Body, Parent.Type
                  From Attachment 
                  Where Id in :triggerMap.keySet() 
                    and (Parent.Type = 'cscfga__Product_Configuration__c' or Parent.Type = 'cscfga__Product_Basket__c')
                    and (Name = :CS_Constants.PartsModelFileName or
                         Name like :pdfQuoteNameFilter or
                         Name LIKE :pdfConfirmationFormNameFilter or
                         Name Like :installationNotes or 
                         Name = :CS_Constants.PdfFinanceIllustrationName)
                ];
        System.debug('affectedAttachments='+affectedAttachments);
        //check which attachment bodies can be deserialized and use those attachment bodies to generate BM Quote & Quote Products
        system.debug('********** checking which attachment can be deserialized -- MY USER ----------------------- USING AaJSON function');
        
        Map<Id, Attachment> quotePdfToBasketIdMap               = new Map<Id, Attachment>(); //EP NEW
        Map<Id, Attachment> quotePdfConfirmationfToBasketIdMap  = new Map<Id, Attachment>();
        Map<Id, Attachment> basketIdToFinanceIllustrationPdf    = new Map<Id, Attachment>();
        Map<Id, Attachment> tempinstallationNotesPDF = new Map<Id, Attachment>();
        Map<Id, Attachment> installationNotesPDF    = new Map<Id, Attachment>();
        Map<Id, Map<String, CS_PartModelEntry>> attachmentPartsModelMap = new Map<Id, Map<String, CS_PartModelEntry>>(); //Map of partsModel to its Product Configuration Id
        Set<Id> affectedPcIds = new Set<Id>();
        
        for(Attachment att : affectedAttachments){
            system.debug('Attachemnt Name-->'+att.Name);
            //Only attachments attached to Configurations with partsModelFileName that can be deserialised will generate BM Quote info
            if (att.Parent.Type == 'cscfga__Product_Configuration__c' && att.Name == CS_Constants.PartsModelFileName) {
                try{
                    Map<String, CS_PartModelEntry> mapPartsModel = new Map<String, CS_PartModelEntry>();
                    String partsModel = att.Body.toString();                
                    
                    mapPartsModel = (Map<String, CS_PartModelEntry>)JSON.deserialize(partsModel, Map<String, CS_PartModelEntry>.class);         
                    attachmentPartsModelMap.put(att.ParentId, mapPartsModel);
                    affectedPcIds.add(att.ParentId);    //only these Product Configuration Ids will be processed
                }
                catch(Exception ex){
                    system.debug(ex);
                }
            }
            
            //If attachment is pdfQuote
            else if (att.Parent.Type == 'cscfga__Product_Basket__c' && att.Name.startsWith(CS_Constants.PdfQuoteFileNamePrefix)) {
                quotePdfToBasketIdMap.put(att.ParentId, att); //put in a Map for later processing
            }
            else if (att.Parent.Type == 'cscfga__Product_Basket__c' && att.Name.startsWith(CS_Constants.PdfCustomerConfirmationFormPrefix)) {
                quotePdfConfirmationfToBasketIdMap.put(att.ParentId, att);
            }
            else if (att.Parent.Type == 'cscfga__Product_Basket__c' && att.Name == CS_Constants.PdfFinanceIllustrationName) {
                basketIdToFinanceIllustrationPdf.put(att.ParentId, att);
            }else if (att.Parent.Type == 'cscfga__Product_Basket__c' && att.Name.startsWith(CS_Constants.InstallationNotesPDF)) {
                tempinstallationNotesPDF.put(att.ParentId, att);
                installationNotesPDF.put(att.ParentId, att);
                System.debug('********** ADDED installation notes template =='+att.Name);
            }

        }
        System.debug('attachmentPartsModelMap='+attachmentPartsModelMap);
        System.debug('********** GOT INSTALLATION NOTES PDF '+tempinstallationNotesPDF);
        
        Map<Id, cscfga__Product_Configuration__c> affectedProductConfigurationsMap = new Map<Id, cscfga__Product_Configuration__c>(
                [Select c.cscfga__Unit_Price__c, c.cscfga__Total_Price__c, 
                     c.cscfga__Serial_Number__c, c.cscfga__Screen_Flow__c, c.cscfga__Root_Configuration__c, c.cscfga__Recurring_Charge__c, 
                     c.cscfga__Recurrence_Frequency__c, c.cscfga__Quantity__c, c.cscfga__Product_Family__c, c.cscfga__Product_Definition__c, c.cscfga__Product_Bundle__c, 
                     c.cscfga__Product_Basket__c, c.cscfga__Product_Definition__r.Name,
                     c.cscfga__Product_Basket__r.Appointment__r.Assigned_To_Name__c, 
                     c.cscfga__Product_Basket__r.Appointment__r.Name,
                     c.cscfga__Product_Basket__r.Appointment__r.Assigned_To__r.Name,
                     c.cscfga__Product_Basket__r.Appointment__r.Status__c, 
                     c.cscfga__Product_Basket__r.Appointment__r.Status_Reason__c,
                     c.cscfga__Parent_Configuration__c, c.cscfga__One_Off_Charge__c, 
                     c.cscfga__Key__c, c.cscfga__Entry_Date__c, c.cscfga__Description__c, 
                     c.cscfga__Contract_Term__c, c.cscfga__Contract_Term_Period__c, c.cscfga__Contract_Term_Period_Description__c, 
                     c.cscfga__Configuration_Status__c, c.cscfga__Configuration_Offer__c, c.cscfga__Billing_Frequency__c, c.cscfga__Attribute_Name__c, 
                     c.OwnerId, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate,
                     c.CreatedBy.Name, c.CreatedBy.Email, c.CreatedBy.MobilePhone, c.CreatedBy.Phone, c.CreatedBy.Title,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__c,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.AccountId,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Asbestos_Found__c,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Asbestos_Found_Date_New__c,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.healthSafety_Notes__c,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.Id,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.bm_fApplicationStatus__c,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.bm_fApplicationDate__c,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.bm_fAcceptanceNumber__c,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.bm_fFinancialProduct__c,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.bm_fAmountOfCredit__c,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingStreet,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingCity,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingState,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode,
                     c.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r.MailingCountry,
                     (Select Id, Name, cscfga__Value__c From cscfga__Attributes__r)
                 From cscfga__Product_Configuration__c c 
                 Where c.Id in :affectedPcIds
                     and c.cscfga__Configuration_Status__c != :CS_Constants.ProductConfiguration_ClonedStatus]); //Do not create BM Quote for 'Cloned' configs
             
        system.debug('********** Selecting Controls product configurations');
        System.debug('affectedProductConfigurationsMap='+affectedProductConfigurationsMap);
        // select a list of configurations which are named Controls. Query root as this is a few levels deep
        List<cscfga__Product_Configuration__c> controlsConfigurations = [select Id, Name, cscfga__Root_Configuration__c, cscfga__Parent_Configuration__c, 
                                                                            (select Id, Name, cscfga__Value__c, cscfga__Attribute_Definition__r.Name From cscfga__Attributes__r)
                                                                        from cscfga__Product_Configuration__c 
                                                                        where Name like 'Controls%' 
                                                                            and cscfga__Root_Configuration__c in :affectedProductConfigurationsMap.keySet()];
          system.debug('controlsConfigurations='+controlsConfigurations);                                                              
        // create a map of root config, Controls configurations                   
        Map<Id, cscfga__Product_Configuration__c> rootIdToControlsConfigMap = new Map<Id, cscfga__Product_Configuration__c>();
        for (cscfga__Product_Configuration__c control : controlsConfigurations){
            rootIdToControlsConfigMap.put(control.cscfga__Root_Configuration__c, control);
        }
                     
        // select a list of related configurations
        system.debug('********** Selecting related product configurations');
        List<cscfga__Product_Configuration__c> relatedConfigurations = [select Id, Name, cscfga__Parent_Configuration__c, cscfga__Product_Definition__r.Name,cscfga__Attribute_Name__c,
                                                                            (select Id, Name, cscfga__Value__c, cscfga__Attribute_Definition__r.Name From cscfga__Attributes__r)
                                                                        from cscfga__Product_Configuration__c 
                                                                        where cscfga__Parent_Configuration__c in :affectedProductConfigurationsMap.keySet()];
           system.debug('relatedConfigurations='+relatedConfigurations);                                                              
        Map<Id, List<cscfga__Product_Configuration__c>> parentToChildConfigsMap = new Map<Id, List<cscfga__Product_Configuration__c>>();
        Map<Id, Map<String, String>> childConfigToAttributesMap = new Map<Id, Map<String, String>>();
        for (cscfga__Product_Configuration__c child : relatedConfigurations) {
         
            //populate parentToChildConfigsMap
            if (!parentToChildConfigsMap.containsKey(child.cscfga__Parent_Configuration__c)) {
                parentToChildConfigsMap.put(child.cscfga__Parent_Configuration__c, new List<cscfga__Product_Configuration__c> {child});
            }
            else {
                parentToChildConfigsMap.get(child.cscfga__Parent_Configuration__c).add(child);
            }
             
            //populate childConfigToAttributesMap (required for mapping Placeholder Radiator to Actual CS Part
            for (cscfga__Attribute__c att : child.cscfga__Attributes__r) {
                if (!childConfigToAttributesMap.containsKey(child.Id)) {
                    childConfigToAttributesMap.put(child.Id, new Map<String, String> {att.cscfga__Attribute_Definition__r.Name => att.cscfga__Value__c});
                }
                else {
                    childConfigToAttributesMap.get(child.Id).put(att.cscfga__Attribute_Definition__r.Name, att.cscfga__Value__c);
                }
             
            }
        }
                
        // A separate soql query for Attribute Fields 
        //system.debug('********** Selecting attribute fields');
        Set<Id> attributeIds = new Set<Id>();
        Id OppId ;
        for(Id pcId : affectedProductConfigurationsMap.keySet()){
            cscfga__Product_Configuration__c pc = affectedProductConfigurationsMap.get(pcId);
            for(cscfga__Attribute__c attr : pc.cscfga__Attributes__r){
                attributeIds.add(attr.Id);
            }
            OppId = affectedProductConfigurationsMap.get(pcId).cscfga__Product_Basket__r.Appointment__r.Opportunity__c;
        } 
        
        boolean duplicate =false;
        if(OppId!=null)
        {
            list<BigMachines_Quote__c> existingItems = [select Id from BigMachines_Quote__c where Opportunity__c = :oppId and Consider_For_Installation_Planning__c = 'Y'];
            
            duplicate = existingItems.size()>0;
        }
              
        List<cscfga__Attribute_Field__c> attributeFields = [Select Id, Name, cscfga__Attribute__c, cscfga__Value__c 
                                                            From cscfga__Attribute_Field__c 
                                                            Where cscfga__Attribute__c in :attributeIds];
        
        // lists of BigMachines_Quote__c, Quote_Product__c, BGS_Payment__c to be inserted and Accounts, Contacts to be updated
        List<BigMachines_Quote__c> bmQuotes = new List<BigMachines_Quote__c>();
        List<Quote_Product__c> quoteProducts = new List<Quote_Product__c>();
        List<BGS_Payment__c> leadPayments = new List<BGS_Payment__c>();
        List<Account> accountsToBeUpdated = new List<Account>();
        List<Contact> contactsToBeUpdated = new List<Contact>();
        List<Suspect_Material__c>lstSuspectMaterial =new List<Suspect_Material__c>();
        List<cscfga__Product_Configuration__c> suspectedMaterialConfig=new List<cscfga__Product_Configuration__c>();
        List<cscfga__Product_Configuration__c> motQuestionAnswers= new list<cscfga__Product_Configuration__c>();
        list<Reportable_Attribute__c> insertReportableAttributeList = new list<Reportable_Attribute__c>();
        // get all the Allowances for populating lookup fields on bm quote
        String allowanceQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Allowance__c') + ' From CS_Allowance__c';
        List<CS_Allowance__c> allowancesList =  ((List<CS_Allowance__c>)database.query(allowanceQuery));  
        Map<Id, CS_Allowance__c> allowancesMap = new Map<Id, CS_Allowance__c>(allowancesList);

        // ------------------------------------------------------------ BigMachines_Quote__c creation -----------------------------------------------------------
        system.debug('********** starting BM Quote creation');
        
        //AaJSON
        Set<Id> pConfigsAllIds = (new Map<Id,cscfga__Product_Configuration__c>(affectedProductConfigurationsMap)).keySet();
        List<Id> pConfigsIdList = new List<Id>(pConfigsAllIds);

        //add controlsId
        if(controlsConfigurations!=null){
            for(cscfga__Product_Configuration__c pConfOther:controlsConfigurations){
                pConfigsIdList.add(pConfOther.Id);
            }
        }
        //--added
        if(relatedConfigurations!=null){
            for(cscfga__Product_Configuration__c pRelOther:relatedConfigurations){
                pConfigsIdList.add(pRelOther.Id);
            }
        }
        

        //end
        Map<String,Object> configsData = cscfga.API_1.getProductConfigurations(pConfigsIdList); 
        //AaJSON
        system.debug('-->'+configsData);
        // Iterate through created Product Configurations and create a BM Quote and related records
        for (Id pcId : affectedProductConfigurationsMap.keySet()){              

            cscfga__Product_Configuration__c pc = affectedProductConfigurationsMap.get(pcId);
            cscfga__Product_Configuration__c controlsConfig = rootIdToControlsConfigMap.get(pc.Id);
            //Smart Meter changes
            cscfga__Product_Configuration__c smartMeterConfig = getConfigurationByName('Smart Meter', parentToChildConfigsMap.get(pc.Id));
            //2017
            suspectedMaterialConfig = getAllConfigurationByName('Suspected Material', parentToChildConfigsMap.get(pc.Id));
            motQuestionAnswers      = getAllConfigurationByName('Home Efficiency', parentToChildConfigsMap.get(pc.Id));
            system.debug('suspectedmaterialConfig='+suspectedmaterialConfig);
            if(smartMeterConfig == null){
                smartMeterConfig = getConfigurationByName('Smart Meter 1', parentToChildConfigsMap.get(pc.Id));
            }
            
            BigMachines_Quote__c bmQuote = new BigMachines_Quote__c();
            
            Map<String, CS_PartModelEntry> mapPartsModel = attachmentPartsModelMap.containsKey(pc.Id) ? attachmentPartsModelMap.get(pc.Id) : new Map<String, CS_PartModelEntry>();   
            
            //create default installation notes for each product configuration (append the custom installation notes to the default ones)
            String defaultInstallationNotes = '';
            if(defaultInstallationNotes == ''){
                defaultInstallationNotes = getInstallationNotes(pc, parentToChildConfigsMap.get(pc.Id), rootIdToControlsConfigMap, mapPartsModel,configsData);
            }
            
            Map<String, Decimal> totalSkillHoursMap = new Map<String, Decimal>(); 
            totalSkillHoursMap = calculateTotalSkillHours(mapPartsModel); // get a map of skill codes, skill hours
            
            //AaJSON
            List<cscfga__Attribute__c> configAttributeList = (List<cscfga__Attribute__c>)configsData.get(pcId +'-attributes');
            //AaJSON
            
            Decimal grossTotalInclVAT = returnDecimal(getAttributeValue('Gross Price incl VAT', configAttributeList)),
                    totalAllowances   = returnDecimal(getAttributeValue('Total Allowance Value', configAttributeList)),
                    actualDeposit     = returnDecimal(getAttributeValue('Actual Deposit', configAttributeList));
             
            //AaJSON
            /*
            Id allowance1 = getAttributeId('Allowance1', configAttributeList),
               allowance2 = getAttributeId('Allowance2', configAttributeList),
               allowance3 = getAttributeId('Allowance3', configAttributeList),
               allowance4 = getAttributeId('Allowance4', configAttributeList),
               allowance5 = getAttributeId('Allowance5', configAttributeList),
               allowance6 = getAttributeId('Allowance6', configAttributeList);
            */
            Id allowance1 = getAttributeDefId('Allowance1', configAttributeList);
            System.debug('*****Allowance 1 attr id=='+allowance1);
            Id allowance2 = getAttributeDefId('Allowance2', configAttributeList);
            Id allowance3 = getAttributeDefId('Allowance3', configAttributeList);
            Id allowance4 = getAttributeDefId('Allowance4', configAttributeList);
            Id allowance5 = getAttributeDefId('Allowance5', configAttributeList);
            Id allowance6 = getAttributeDefId('Allowance6', configAttributeList);
            //id asbestosRisk  =    getAttributeDefId('Asbestos Risk Register', configAttributeList);
            String isAllowance1Applied = getAttributeFieldValueAaJSON('Is_Applied', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance1+'-attributeFields'));
            System.debug('*****Allwoance 1 =='+isAllowance1Applied);
            String isAllowance2Applied = getAttributeFieldValueAaJSON('Is_Applied', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance2+'-attributeFields'));
            String isAllowance3Applied = getAttributeFieldValueAaJSON('Is_Applied', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance3+'-attributeFields'));
            String isAllowance4Applied = getAttributeFieldValueAaJSON('Is_Applied', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance4+'-attributeFields'));
            String isAllowance5Applied = getAttributeFieldValueAaJSON('Is_Applied', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance5+'-attributeFields'));
            String isAllowance6Applied = getAttributeFieldValueAaJSON('Is_Applied', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance6+'-attributeFields'));
            // Refernce Number - Derive any voucherNumber present 
            String refernceNum1 = getAttributeFieldValueAaJSON('ReferenceNumber', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance1+'-attributeFields'));
            String refernceNum2 = getAttributeFieldValueAaJSON('ReferenceNumber', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance2+'-attributeFields'));
            String refernceNum3 = getAttributeFieldValueAaJSON('ReferenceNumber', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance3+'-attributeFields'));
            String refernceNum4 = getAttributeFieldValueAaJSON('ReferenceNumber', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance4+'-attributeFields'));
            String refernceNum5 = getAttributeFieldValueAaJSON('ReferenceNumber', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance5+'-attributeFields'));
            String refernceNum6 = getAttributeFieldValueAaJSON('ReferenceNumber', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance6+'-attributeFields'));
            
                   /*
                   isAllowance2Applied = getAttributeFieldValue(allowance2, 'Is_Applied', attributeFields),
                   isAllowance3Applied = getAttributeFieldValue(allowance3, 'Is_Applied', attributeFields),
                   isAllowance4Applied = getAttributeFieldValue(allowance4, 'Is_Applied', attributeFields),
                   isAllowance5Applied = getAttributeFieldValue(allowance5, 'Is_Applied', attributeFields),
                   isAllowance6Applied = getAttributeFieldValue(allowance6, 'Is_Applied', attributeFields);
                   */
            
            // Start of BigMachines_Quote__c creation
            
            bmQuote.Name                                    = getAttributeValue('Quote Reference', configAttributeList); 
            bmQuote.App_Assigned_To__c                      = pc.cscfga__Product_Basket__r.Appointment__r.Assigned_To__r.Name;
            bmQuote.Opportunity__c                          = pc.cscfga__Product_Basket__r.Appointment__r.Opportunity__c;
            
            bmQuote.CS_Quote__c                             = pc.cscfga__Product_Basket__c;
            bmquote.Asbestos_Risk_Register__c               = getAttributeValue('Asbestos Risk Register', configAttributeList);     
            String voucherNumber                            = getAttributeValue('Voucher Number', configAttributeList); //only 1 can be captured at the moment
            String employeeId                               = getAttributeValue('Employee ID', configAttributeList); //only 1 can be captured at the moment
            bmquote.Energy_Account_Ref__c                   = getAttributeValue('Energy Account Ref', configAttributeList);
            bmquote.Allowance_Email__c                      = getAttributeValue('Contact Email', configAttributeList); // added 26/11/18 by PD to capture email for account setup
            String allowance1_Id                            = getAttributeValue('Allowance1', configAttributeList);
            String allowance2_Id                            = getAttributeValue('Allowance2', configAttributeList);
            String allowance3_Id                            = getAttributeValue('Allowance3', configAttributeList);
            String allowance4_Id                            = getAttributeValue('Allowance4', configAttributeList);
            String allowance5_Id                            = getAttributeValue('Allowance5', configAttributeList);
            String allowance6_Id                            = getAttributeValue('Allowance6', configAttributeList);

            
            
            if (isAllowance1Applied == 'TRUE' && String.isNotEmpty(allowance1_Id)) {
                //bmQuote.appliedAllowance1__c                = getAttributeFieldValue(allowance1, 'Code', attributeFields);
                bmQuote.appliedAllowance1__c                = getAttributeFieldValueAaJSON('Code', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance1+'-attributeFields'));
                bmQuote.appliedAmount1__c                   = returnDecimal(getAttributeFieldValueAaJSON('ActualAmount', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance1+'-attributeFields')));
                //bmQuote.allowance_desc_1__c                 = getAttributeFieldValue(allowance1, 'AllowanceName', attributeFields);
                bmQuote.allowance_desc_1__c                 = getAttributeFieldValueAaJSON('AllowanceName', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance1+'-attributeFields'));
                
                bmQuote.CS_Allowance_1__c                   = allowance1_Id;
                
                System.debug('****VOUCHER NUMBER ='+voucherNumber);
                System.debug('****employeeId ='+employeeId);
                Boolean requiresVaucher = allowancesMap.get(allowance1_Id).Requires_Voucher_ID__c;
                System.debug('****requiresVaucher =='+requiresVaucher);

                bmQuote.allowance1VoucherNumber__c          = (allowancesMap.containsKey(allowance1_Id) && allowancesMap.get(allowance1_Id).Requires_Voucher_ID__c ? voucherNumber : refernceNum1);
                bmQuote.employeePayrollNumber1__c           = (allowancesMap.containsKey(allowance1_Id) && allowancesMap.get(allowance1_Id).Requires_Employee_ID__c ? employeeId : '');
            }            
            if (isAllowance2Applied == 'TRUE' && String.isNotEmpty(allowance2_Id)) {
                //bmQuote.appliedAllowance2__c                = getAttributeFieldValue(allowance2, 'Code', attributeFields);
                bmQuote.appliedAllowance2__c                = getAttributeFieldValueAaJSON('Code', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance2+'-attributeFields'));
                bmQuote.appliedAmount2__c                   = returnDecimal(getAttributeFieldValueAaJSON('ActualAmount', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance2+'-attributeFields')));//returnDecimal(getAttributeFieldValueAaJSON(allowance2, 'ActualAmount', attributeFields));
                //bmQuote.allowance_desc_2__c                 = getAttributeFieldValue(allowance2, 'AllowanceName', attributeFields);
                bmQuote.allowance_desc_2__c                 = getAttributeFieldValueAaJSON('AllowanceName', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance2+'-attributeFields'));
                
                bmQuote.CS_Allowance_2__c                   = allowance2_Id;
                //bmQuote.allowance2VoucherNumber__c          = refernceNum2;
                
                bmQuote.allowance2VoucherNumber__c          = (allowancesMap.containsKey(allowance2_Id) && allowancesMap.get(allowance2_Id).Requires_Voucher_ID__c ? voucherNumber : refernceNum2);
                bmQuote.employeePayrollNumber2__c           = (allowancesMap.containsKey(allowance2_Id) && allowancesMap.get(allowance2_Id).Requires_Employee_ID__c ? employeeId : '');
            } 
            if (isAllowance3Applied == 'TRUE' && String.isNotEmpty(allowance3_Id)) {
                //bmQuote.appliedAllowance3__c                = getAttributeFieldValue(allowance3, 'Code', attributeFields);
                bmQuote.appliedAllowance3__c                = getAttributeFieldValueAaJSON('Code', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance3+'-attributeFields'));
                
                bmQuote.appliedAmount3__c                   = returnDecimal(getAttributeFieldValueAaJSON('ActualAmount', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance3+'-attributeFields')));//returnDecimal(getAttributeFieldValue(allowance3, 'ActualAmount', attributeFields));
                //bmQuote.allowance_desc_3__c                 = getAttributeFieldValue(allowance3, 'AllowanceName', attributeFields);
                bmQuote.allowance_desc_3__c                 = getAttributeFieldValueAaJSON('AllowanceName', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance3+'-attributeFields'));
                
                bmQuote.CS_Allowance_3__c                   = allowance3_Id;
                //bmQuote.allowance3VoucherNumber__c          = refernceNum3;
                bmQuote.allowance3VoucherNumber__c          = (allowancesMap.containsKey(allowance3_Id) && allowancesMap.get(allowance3_Id).Requires_Voucher_ID__c ? voucherNumber : refernceNum3);
                bmQuote.employeePayrollNumber3__c           = (allowancesMap.containsKey(allowance3_Id) && allowancesMap.get(allowance3_Id).Requires_Employee_ID__c ? employeeId : '');
            } 
            if (isAllowance4Applied == 'TRUE' && String.isNotEmpty(allowance4_Id)) {
                //bmQuote.appliedAllowance4__c                = getAttributeFieldValue(allowance4, 'Code', attributeFields);
                bmQuote.appliedAllowance4__c                = getAttributeFieldValueAaJSON('Code', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance4+'-attributeFields'));
                bmQuote.appliedAmount4__c                   = returnDecimal(getAttributeFieldValueAaJSON('ActualAmount', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance4+'-attributeFields')));//returnDecimal(getAttributeFieldValue(allowance4, 'ActualAmount', attributeFields));
                //bmQuote.allowance_desc_4__c                 = getAttributeFieldValue(allowance4, 'AllowanceName', attributeFields);
                bmQuote.allowance_desc_4__c                 = getAttributeFieldValueAaJSON('AllowanceName', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance4+'-attributeFields'));               
                bmQuote.CS_Allowance_4__c                   = allowance4_Id;
                //bmQuote.allowance4VoucherNumber__c          = refernceNum4;
                bmQuote.allowance4VoucherNumber__c          = (allowancesMap.containsKey(allowance4_Id) && allowancesMap.get(allowance4_Id).Requires_Voucher_ID__c ? voucherNumber : refernceNum4);
                bmQuote.employeePayrollNumber4__c           = (allowancesMap.containsKey(allowance4_Id) && allowancesMap.get(allowance4_Id).Requires_Employee_ID__c ? employeeId : '');
            } 
            if (isAllowance5Applied == 'TRUE' && String.isNotEmpty(allowance5_Id)) {
                //bmQuote.appliedAllowance5__c                = getAttributeFieldValue(allowance5, 'Code', attributeFields);
                bmQuote.appliedAllowance5__c                = getAttributeFieldValueAaJSON('Code', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance5+'-attributeFields'));
                bmQuote.appliedAmount5__c                   = returnDecimal(getAttributeFieldValueAaJSON('ActualAmount', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance5+'-attributeFields')));//returnDecimal(getAttributeFieldValue(allowance5, 'ActualAmount', attributeFields));
                //bmQuote.allowance_desc_5__c                 = getAttributeFieldValue(allowance5, 'AllowanceName', attributeFields);
                bmQuote.allowance_desc_5__c                 = getAttributeFieldValueAaJSON('AllowanceName', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance5+'-attributeFields'));
                bmQuote.CS_Allowance_5__c                   = allowance5_Id;
                //bmQuote.allowance5VoucherNumber__c          = refernceNum5;
                bmQuote.allowance5VoucherNumber__c          = (allowancesMap.containsKey(allowance5_Id) && allowancesMap.get(allowance5_Id).Requires_Voucher_ID__c ? voucherNumber : refernceNum5);
                bmQuote.employeePayrollNumber5__c           = (allowancesMap.containsKey(allowance5_Id) && allowancesMap.get(allowance5_Id).Requires_Employee_ID__c ? employeeId : '');
            } 
            if (isAllowance6Applied == 'TRUE' && String.isNotEmpty(allowance6_Id)) {
                //bmQuote.appliedAllowance6__c                = getAttributeFieldValue(allowance6, 'Code', attributeFields);
                bmQuote.appliedAllowance6__c                = getAttributeFieldValueAaJSON('Code', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance6+'-attributeFields'));
                bmQuote.appliedAmount6__c                   = returnDecimal(getAttributeFieldValueAaJSON('ActualAmount', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance6+'-attributeFields')));//returnDecimal(getAttributeFieldValue(allowance6, 'ActualAmount', attributeFields));
                //bmQuote.allowance_desc_6__c                 = getAttributeFieldValue(allowance6, 'AllowanceName', attributeFields);
                bmQuote.allowance_desc_6__c                 = getAttributeFieldValueAaJSON('AllowanceName', (List<cscfga__Attribute_Field__c>)configsData.get(pcId +'-'+allowance6+'-attributeFields'));
                
                bmQuote.CS_Allowance_6__c                   = allowance6_Id;
                //bmQuote.allowance6VoucherNumber__c          = refernceNum6;
                bmQuote.allowance6VoucherNumber__c          = (allowancesMap.containsKey(allowance6_Id) && allowancesMap.get(allowance6_Id).Requires_Voucher_ID__c ? voucherNumber : refernceNum6);
                bmQuote.employeePayrollNumber6__c           = (allowancesMap.containsKey(allowance6_Id) && allowancesMap.get(allowance6_Id).Requires_Employee_ID__c ? employeeId : '');
            } 
            
            bmQuote.appliedAllowancesTotal__c               = totalAllowances; 
            bmQuote.balancePricing__c                       = grossTotalInclVAT - totalAllowances - actualDeposit; //-> Total Price incl VAT- Allowances - Deposit -> (grossPriceInclVAT - Allowances - Desposit(field still missing))
            bmQuote.bmStatusReason__c                       = duplicate ? 'Subsequent Sold Quote' : getAttributeValue('Reason', configAttributeList);
            
            if ((getAttributeValue('Quote Status',configAttributeList) == CS_Constants.QuoteStatus_FinalizedAccepted)){
                bmQuote.closeDate__c                        = system.today();//Date.valueOf(pc.CreatedDate); 
            }           
            
            bmQuote.createdDate_quote__c                    = returnDate(getAttributeValue('Quote Creation Date', configAttributeList));
            bmQuote.deliveryDate__c                         = returnDate(getAttributeValue('Delivery Date', configAttributeList));
            
            bmQuote.deliveryNotes__c                        = returnString(getAttributeValue('Delivery Notes', configAttributeList), 250);
            bmQuote.depositOnPricing__c                     = actualDeposit;
            bmQuote.discountsTotalOnPricing__c              = totalAllowances;
            
            bmQuote.geographicUpliftFactor__c               = returnDecimal(getAttributeValue('Geographic Uplift Factor', configAttributeList));
            bmQuote.grossPricingTotal__c                    = grossTotalInclVAT; //-> "grossPriceInclVAT before discount plus geographic uplift"
            bmQuote.Installation_Special_Instructions__c    = returnString(getAttributeValue('Special Notes for Installer', configAttributeList), 250);
            bmQuote.installationDate__c                     = returnDate(getAttributeValue('Installation Date',configAttributeList));
            
            bmQuote.net__c                                  = grossTotalInclVAT - totalAllowances; //-> (GrossPricingTotal - Discounts) (includes uplift, VAT)
            
            if (getAttributeValue('Customer Date of Birth', configAttributeList) != null) {
                bmQuote.OP_DOB__c  = returnDate(getAttributeValue('Customer Date of Birth',configAttributeList));
            }
            
            bmQuote.POC_Payment_Method__c                   = getAttributeValue('Payment Method', configAttributeList);
            bmQuote.POC_Payment_Option__c                   = getAttributeValue('Payment Option',configAttributeList);
            
            bmQuote.preparedBy_Quote__c                     = pc.CreatedBy.Name + '\n' + pc.cscfga__Product_Basket__r.Appointment__r.Name + '\n' + pc.cscfga__Configuration_Status__c;
            bmQuote.preparedByCell_quote__c                 = pc.CreatedBy.MobilePhone;
            bmQuote.preparedByEmail_quote__c                = pc.CreatedBy.Email;
            bmQuote.preparedByName_quote__c                 = pc.CreatedBy.Name;
            bmQuote.preparedByPhone_quote__c                = pc.CreatedBy.Phone;
            bmQuote.preparedByTitle_quote__c                = pc.CreatedBy.Title;
            bmQuote.Pricebook_Id__c                         = getAttributeValue('HEAT Pricebook', configAttributeList); 
            bmQuote.Product_Type_ID__c                      = getAttributeValue('HEAT Pricebook', configAttributeList);           
            bmQuote.Quote_Finish_Time__c                    = returnDateTime(getAttributeValue('Quote Finish Time', configAttributeList));     
            //bmQuote.Quote_Suffix__c
            //bmQuote.quoteNumber_quote__c
            //bmQuote.quoteType_quote__c
            //bmQuote.QuoteVersion__c
            //bmQuote.revisionNumber_quote__c
            
            bmQuote.sFDCApptStatus__c                       = pc.cscfga__Product_Basket__r.Appointment__r.Status__c;
            bmQuote.sFDCApptStatusReason__c                 = pc.cscfga__Product_Basket__r.Appointment__r.Status_Reason__c;     
            
            bmQuote.skillTotal_ecogenElectrical__c          = totalSkillHoursMap.containsKey('EG') ? totalSkillHoursMap.get('EG') : 0;
            bmQuote.skillTotal_ecogenMechanical__c          = totalSkillHoursMap.containsKey('MEG') ? totalSkillHoursMap.get('MEG') : 0;
            //bmQuote.skillTotalAsbestosRemoval__c          -> skill/code missing
            //bmQuote.skillTotalAsbestosRemovalFixedRate__c -> skill/code missing
            bmQuote.skillTotalBuildingWork__c               = totalSkillHoursMap.containsKey('B') ? totalSkillHoursMap.get('B') : 0;
            bmQuote.skillTotalConnectSolarPanels__c         = totalSkillHoursMap.containsKey('MSL') ? totalSkillHoursMap.get('MSL') : 0;
            //bmQuote.skillTotalContractorInstallation__c   -> skill/code missing            
            bmQuote.skillTotalElectrical__c                 = totalSkillHoursMap.containsKey('E') ? totalSkillHoursMap.get('E') : 0;    
            bmQuote.SkillTotalElectricalWorkASP__c          = totalSkillHoursMap.containsKey('EA') ? totalSkillHoursMap.get('EA') : 0;
            bmQuote.skillTotalFireWallHeaterFixing__c       = totalSkillHoursMap.containsKey('FF') ? totalSkillHoursMap.get('FF') : 0;
            bmQuote.skillTotalLPGInstallation__c            = totalSkillHoursMap.containsKey('LP') ? totalSkillHoursMap.get('LP') : 0;
            bmQuote.skillTotalMechanical__c                 = totalSkillHoursMap.containsKey('M') ? totalSkillHoursMap.get('M') : 0;
            bmQuote.skillTotalPaymentCollection__c          = totalSkillHoursMap.containsKey('PC') ? totalSkillHoursMap.get('PC') : 0;
            bmQuote.skillTotalPowerFlush__c                 = totalSkillHoursMap.containsKey('PF') ? totalSkillHoursMap.get('PF') : 0;
            bmQuote.skillTotalRoofWork__c                   = totalSkillHoursMap.containsKey('R') ? totalSkillHoursMap.get('R') : 0;
            bmQuote.skillTotalScaffolder__c                 = totalSkillHoursMap.containsKey('S') ? totalSkillHoursMap.get('S') : 0;
            //bmQuote.skillTotalSolar__c                    -> skill/code missing
            bmQuote.skillTotalSpecialistBuilding__c         = totalSkillHoursMap.containsKey('SB') ? totalSkillHoursMap.get('SB') : 0;
            bmQuote.skillTotalUnventedHotWater__c           = totalSkillHoursMap.containsKey('UV') ? totalSkillHoursMap.get('UV') : 0;
            bmQuote.skillTotalWaterHeatingFixing__c         = totalSkillHoursMap.containsKey('WF') ? totalSkillHoursMap.get('WF') : 0;
            bmQuote.Landlord_Check__c                        = totalSkillHoursMap.containsKey('LC') ? totalSkillHoursMap.get('LC') : 0;
            bmQuote.stage__c                                = duplicate ? 'Quote Finalised - Not Accepted' : getAttributeValue('Quote Status',configAttributeList);  
            /*/if(bmQuote.stage__c!='Quote Finalised - Accepted')
            {
                tempinstallationNotesPDF.clear();
            }*/
            System.debug('new Installation Notes -->'+installationNotesPDF);
            bmQuote.submittedDate_quote__c                  = Date.valueOf(pc.CreatedDate);
            
            String systemType = getAttributeValue('System Type Required', configAttributeList); 
            if(systemType == 'Combination') {
                bmQuote.systemType__c = '1';
            } else if (systemType == 'Conventional') {
                bmQuote.systemType__c = '2';
            } else {
                bmQuote.systemType__c = '';
            }
                        
            bmQuote.totalNetPrice_quote__c                  = grossTotalInclVAT - totalAllowances;  // -> GrossPricing Total (incl VAT & uplift) - DiscountingTotal
            bmQuote.Signature_Date__c                       = getAttributeValue('Quote Creation Date', configAttributeList);      
            
            bmQuote.Customer_have_any_other_form_of_heat__c = returnValueInsteadOfNone(getAttributeValue('Other Form of Heating',configAttributeList), 'Not applicable');
            bmQuote.Does_the_customer_have_hot_water__c     = getAttributeValue('Hot Water Available',configAttributeList);
            
            // deleted! bmQuote.existing_efficiency_rating__c           = getAttributeValue('Existing Efficiency Rating', pc.cscfga__Attributes__r);
            // deleted! bmQuote.existing_gas_council_number__c          = getAttributeValue('Existing Gas Council Number', pc.cscfga__Attributes__r);
            bmQuote.Finance_Esigned__c                      = returnValueInsteadOfNone(getAttributeValue('Electronic Signature', configAttributeList), '');
            
            //Changed 13/06/2014: was ((bmQuote.Finance_Esigned__c != null) && (bmQuote.Finance_Esigned__c != '')) ? true : false;
            bmQuote.Is_Electronically_Signed__c             = (getAttributeValue('Quote Status', configAttributeList) == CS_Constants.QuoteStatus_FinalizedAccepted && 
                                                                getAttributeValue('Pdf Signed',configAttributeList) == '1') ? true : false;
            
            bmQuote.Is_the_customer_s_boiler_working__c     = getAttributeValue('Boiler Working', configAttributeList);            
            bmQuote.Is_the_customer_vulnerable__c           = returnValueInsteadOfNone(getAttributeValue('Vulnerable Customer', configAttributeList), 'Not applicable');
            
            String existingSystemType                       = getAttributeValue('Existing System', configAttributeList);
            String systemTypeRequired                       = getAttributeValue('System Type Required', configAttributeList);
            String jobTypeRequired                          = getAttributeValue('Job Type Required', configAttributeList);
            bmQuote.SM_Installation_Date__c                 = returnDate(getAttributeValue('Smart Meter Install Date', configAttributeList));
            bmQuote.SM_Installation_Time__c                 = getAttributeValue('Smart Meter Install Slot', configAttributeList);
            string SSjobtype                                = getAttributeValue('Select Job Type', configAttributeList);
            if(SSjobtype=='')
            SSjobtype                                       = getAttributeValue('Definition Name', configAttributeList);
            List<String> jobTypeList                        = jobTypeListFromCombination(existingSystemType, systemTypeRequired, jobTypeRequired, SSjobtype);
            bmQuote.Job_Type__c                             = jobTypeList[0];
            bmQuote.Job_Type_Description__c                 = jobTypeList[1];
            
            bmQuote.Latest_customer_category__c             = returnDecimal(getAttributeValue('Latest Customer Category', configAttributeList));
            bmQuote.Remote_Heating__c                       = totalSkillHoursMap.containsKey('RHC') ? totalSkillHoursMap.get('RHC') : 0;
            
            bmQuote.RHCStatus__c                            = 'FALSE'; // set to false because we check in the quote product loops RHC_Status will be either TRUE or FALSE if P2285 or PSLT1 or PSLT2 has been sold 
            bmQuote.Customer_Homecare_Contact__c            = 'No'; //EP added 23/06
              
              
            if(controlsConfig != null){
                
                 //AaJSON
                List<cscfga__Attribute__c> configAttributeListControls = (List<cscfga__Attribute__c>)configsData.get(controlsConfig.Id +'-attributes');
                //AaJSON
                bmQuote.RHCMobile__c                        = getAttributeValue('Customer Phone Number 2', configAttributeListControls); // note: we get theese from controls related configuration
                
                try {
                    bmQuote.RHCUsername__c                  = getAttributeValue('Customer Email Address 2', configAttributeListControls); // note: we get theese from controls related configuration
                } catch (Exception e){
                    system.debug('Invalid email address. ' + e.getMessage());
                }
            }
            if(pc.cscfga__Product_Definition__r.Name == 'Straight Swaps') {
                try {
                     // TS 11.07.2017: Fix for RHC Username not showing in BigMachines Quotes on product definitions with AaJSON enabled 
                     bmQuote.RHCUsername__c                  = getAttributeValue('HIVE email', configAttributeList); 
                     bmQuote.RHCStatus__c = 'TRUE'; // TS 11.09.2017: Fix for RHC status not being set to 'TRUE'
                } catch (Exception e){
                    system.debug('Invalid email address. ' + e.getMessage());
                }
            }
            
            bmQuote.skillTotalECO__c                        = totalSkillHoursMap.containsKey('ECO') ? totalSkillHoursMap.get('ECO') : 0;
            
            // SM Read Times - Updated 10/09/14 PD. 
            //AaJSON update
            //if(smartMeterConfig != null && smartMeterConfig.cscfga__Attributes__r.size()>0)
            if(smartMeterConfig != null)
            {
                
                //AaJSON
                List<cscfga__Attribute__c> configAttributeListSM = (List<cscfga__Attribute__c>)configsData.get(smartMeterConfig.Id +'-attributes');
                
                if(configAttributeListSM !=null && configAttributeListSM.size()>0){
                    //AaJSON
                    bmQuote.SM_Read_Times__c                        = getAttributeValue('Smart meter read time', configAttributeListSM);
                    bmQuote.SM_Microgen__c                          = getAttributeValue('Micro Generation', configAttributeListSM);
                    bmQuote.SM_Vulnerability__c                     = getAttributeValue('Vulnerability', configAttributeListSM);
                    bmQuote.SM_Access_To_Meter__c                   = getAttributeValue('Access', configAttributeListSM);
                    bmQuote.Interested_In_SM__c                     = getAttributeValue('Smart Meter Required', configAttributeListSM); 
                }
            }
            
            
             
            
            bmQuote.Vulnerable_reason__c                    = returnValueInsteadOfNone(getAttributeValue('Vulnerable Reasons', configAttributeList), 'NA');
            
            bmQuote.BigMachines_Transaction_Id__c           = CS_GuidGenerator.NewGUID().substring(6); // use to link master detail with quote products
            
            // ********** new fields linked from bugfixes **********
            bmQuote.finalPriceVisibleToCustomer__c          = grossTotalInclVAT;
            bmQuote.finalNetQuoteTotal__c                   = grossTotalInclVAT - totalAllowances;
            bmQuote.Scaffold_Notes__c                       = getAttributeValue('Scaffold Notes', configAttributeList);
            bmQuote.Customer_Assist__c                      = getAttributeValue('Assist Flag', configAttributeList);
            bmQuote.Office_Notes__c                         = getAttributeValue('Office Notes', configAttributeList);
            bmQuote.Boiler_Plus_Reasons__c                  = getAttributeValue('Boiler Plus Reason', configAttributeList);
            // --------------------------------- Account update -------------------------------
            Account a = pc.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account;
            if(a!=null){
                String asbestosIdentified = getAttributeValue('Asbestos Identified', configAttributeList);
                a.Asbestos_Found__c = asbestosIdentified;
                if(asbestosIdentified == 'Yes'){
                    a.Asbestos_Found_Date_New__c = Date.valueOf(pc.CreatedDate);    
                    
                    //Construct H&S Notes
                    String healthAndSafetyNotes = 'Asbestos has been identified at this property on ' + a.Asbestos_Found_Date_New__c + '\n';
                    
                    if(parentToChildConfigsMap != null) {
                        if (parentToChildConfigsMap.containsKey(pc.Id)) {
                            for (cscfga__Product_Configuration__c childConfig : parentToChildConfigsMap.get(pc.Id)) {
                                
                                if (childConfig.cscfga__Product_Definition__r.Name == 'Asbestos') { 
                                    system.debug('Asbestos related configuration found');
                                    
                                    //AaJSON
                                    List<cscfga__Attribute__c> configAttributeListAsb = (List<cscfga__Attribute__c>)configsData.get(childConfig.Id +'-attributes');
               
                                    // find Asbestos Location field
                                    healthAndSafetyNotes = healthAndSafetyNotes + 'Location: ' + getAttributeValue('Asbestos Location', configAttributeListAsb) + '\n';
                                    healthAndSafetyNotes = healthAndSafetyNotes + 'The following packs were ordered: \n';
                                    healthAndSafetyNotes = healthAndSafetyNotes + getAttributeValue('Asbestos Removal Pack Description', configAttributeListAsb) + '; \n';
                                }
                            }
                        }
                    }
                    
                    a.healthSafety_Notes__c = healthAndSafetyNotes;
                    system.debug('Health and Safety notes set to: ' + healthAndSafetyNotes);
                }
                
                
                accountsToBeUpdated.add(a);
            }
            
            Boolean toUpdateContact = false;
            
            // ---------- Contact update ----------
            Contact c = pc.cscfga__Product_Basket__r.Appointment__r.Opportunity__r.Account.Primary_Contact__r;
            //update contact fields only if the payment method is finance
            if(!duplicate && bmQuote.POC_Payment_Method__c == 'Finance' && bmQuote.stage__c == 'Quote Finalised - Accepted'){
                if(c!=null){
                    c.bm_fApplicationStatus__c              = getAttributeValue('Application Status', configAttributeList);
                    c.bm_fApplicationDate__c                = returnDate(getAttributeValue('Application Date', configAttributeList));
                    c.bm_fAcceptanceNumber__c               = getAttributeValue('Application Number', configAttributeList);
                    c.bm_fFinancialProduct__c               = getAttributeValue('Payment Option', configAttributeList);
                    c.bm_fAmountOfCredit__c                 = returnDecimal(getAttributeValue('Balance Outstanding', configAttributeList));
                    toUpdateContact = true;
                    //contactsToBeUpdated.add(c);
                }
            }

            // update contact if there are any changes to the address fields
            if(!duplicate && c!=null) {
                //fix for the duplicate contact issue. 
                //Boolean toUpdateContact = false;
                String billingStreet                        = getAttributeValue('Billing Street', configAttributeList) != null ? getAttributeValue('Billing Street',configAttributeList) : '';
                String billingCity                          = getAttributeValue('Billing City', configAttributeList) != null ? getAttributeValue('Billing City',configAttributeList) : '';
                String billingCounty                        = getAttributeValue('Billing County', configAttributeList) != null ? getAttributeValue('Billing County', configAttributeList) : '';
                String billingPostcode                      = getAttributeValue('Billing Postcode', configAttributeList) != null ? getAttributeValue('Billing Postcode', configAttributeList) : '';
                String billingCountry                       = getAttributeValue('Billing Country', configAttributeList) != null ? getAttributeValue('Billing Country', configAttributeList) : '';

                if((c.MailingStreet != billingStreet) && (billingStreet != '')) {
                    c.MailingStreet = billingStreet;
                    toUpdateContact = true;
                }
                if((c.MailingCity != billingCity) && (billingCity != '')) {
                    c.MailingCity = billingCity;
                    toUpdateContact = true;
                }
                if((c.MailingState != billingCounty) && (billingCounty != '')) {
                    c.MailingState = billingCounty;
                    toUpdateContact = true;
                }
                if((c.MailingPostalCode != billingPostcode) && (billingPostcode != '')) {
                    c.MailingPostalCode = billingPostcode;
                    toUpdateContact = true;
                }
                if((c.MailingCountry != billingCountry) && (billingCountry != '')) {
                    c.MailingCountry = billingCountry;
                    toUpdateContact = true;
                }
                
            }
            if(toUpdateContact) {
                contactsToBeUpdated.add(c); 
            }
            
            // ------------------------------------------------------------ BGS_Payment__c creation -----------------------------------------------------------
            // if the Status of the Basket is 'Finalized - Accepted' then create a BGS_Payment__c
            // EP 16/06 removed AND clause for:  and an 'Actual Deposit' has been entered (and >0)
            if(!duplicate && getAttributeValue('Quote Status', configAttributeList) == CS_Constants.QuoteStatus_FinalizedAccepted){
                BGS_Payment__c leadPayment = new BGS_Payment__c();
                String paymentGateway = getAttributeValue('Payment Gateway', configAttributeList);
                String paymentGatewayReferenceNumber = getAttributeValue('Payment Gateway Reference Number', configAttributeList);
                String transactionStatus = getAttributeValue('Transaction Status', configAttributeList);
                
                leadPayment.Opportunity__c                      = pc.cscfga__Product_Basket__r.Appointment__r.Opportunity__c;
                leadPayment.Amount__c                           = returnDecimal(getAttributeValue('Actual Deposit', configAttributeList));
                leadPayment.Payment_Method__c                   = getAttributeValue('Payment Type', configAttributeList);
                leadPayment.depositOnPricing__c                 = returnDecimal(getAttributeValue('Actual Deposit', configAttributeList));
                leadPayment.BGS_Payment_Reference_Num__c        = getAttributeValue('Deposit Receipt Number', configAttributeList);
                leadPayment.EPDQ_Authorisation__c               = getAttributeValue('EPDQ reference number', configAttributeList);
                if (paymentGateway != null && paymentGateway.length() > 0) {
                    leadPayment.Payment_Gateway__c              = paymentGateway;
                }
                if (paymentGatewayReferenceNumber != null && paymentGatewayReferenceNumber.length() > 0) {
                    leadPayment.Payment_Gateway_Reference_Number__c = paymentGatewayReferenceNumber;
                }
                if (transactionStatus != null && transactionStatus.length() > 0) {
                    leadPayment.Transaction_Status__c = transactionStatus;
                }

                leadPayment.Transaction_Successful__c           = true;
                leadPayment.Payment_Type__c                     = 'Deposit';

                leadPayments.add(leadPayment);                
            } 
            
             
            // ------------------------------------------------------------- Quote_Product__c creation --------------------------------------------------------
            // take the de-serialized attachment related to that BM quote/product configuration and populate quote products 
            list<String> partCodeList = new list<String>();
            Integer numberOfParts = 0;
            for(String key : mapPartsModel.keySet()){
                CS_PartModelEntry item = mapPartsModel.get(key);
                
                if (!item.isLineItem) {
                    continue;
                }
                
                if(item.isPart && !item.isMultilookup && item.parentPart != null){
                    numberOfParts++;
                    
                    // if the product configuration contains any of the parts with the following codes, set the RHCStatus__c to true
                    if(System.label.RHC_Product_Names.contains(item.parentPart.part.Part_Code__c)){
                        bmQuote.RHCStatus__c = 'TRUE';
                    }
                    
                    //EP added 23/06
                    if((item.parentPart.part.Part_Code__c == 'P12006')){
                        bmQuote.Customer_Homecare_Contact__c = 'Yes';
                    }
                    
                    if(item.parentPart.part.Part_Code__c!=null)
                    {
                        partCodeList.add(item.parentPart.part.Part_Code__c);
                    }
                    
                    Quote_Product__c partQuoteProduct = new Quote_Product__c();
                    partQuoteProduct.Product__c = item.parentPart.part.Product__c;

                    if (item.isPlaceholder) {
                        String valueToMatch = item.attLastValue,
                               valueOfActual,
                               placeholderAttName = 'Placeholder',
                               actualAttName = 'Radiator';
                        
                        if (parentToChildConfigsMap.containsKey(pc.Id)) {
                            for (cscfga__Product_Configuration__c relatedPc : parentToChildConfigsMap.get(pc.Id)) {
                                for (cscfga__Attribute__c att : relatedPc.cscfga__Attributes__r) {
                                    if (att.cscfga__Attribute_Definition__r.Name == placeholderAttName && att.cscfga__Value__c == valueToMatch) {
                                        //locate 'Radiator' attribute of the same related Product and get its value
                                        valueOfActual = childConfigToAttributesMap.get(relatedPc.Id).get(actualAttName);
                                    }
                                }
                            }
                        }
                        partQuoteProduct.CS_Actual_Part__c = valueOfActual;
                    }
                                      
                    //for placeholder parts their price should be 0         
                    partQuoteProduct.BigMachines_Quote__r                   = new BigMachines_Quote__c(BigMachines_Transaction_Id__c = bmQuote.BigMachines_Transaction_Id__c );         
                    partQuoteProduct.Sales_Price__c                         = item.isPlaceholder ? 0 : item.parentPart.totalPriceIncVAT; //price * quantity
                    partQuoteProduct.Quantity__c                            = item.parentPart.quantity;
                    partQuoteProduct.geographicUplift__c                    = item.parentPart.geographicUpliftAmount;
                    partQuoteProduct.vATAAfterDiscount__c                   = item.parentPart.vatAmount;
                    partQuoteProduct.quotingReason__c                       = 'First Quote';
                    partQuoteProduct.price_list_price_each__c               = item.isPlaceholder ? 0 : item.parentPart.listPrice;
                    partQuoteProduct.GrossSingle__c                         = item.isPlaceholder ? 0 : item.parentPart.priceVatIncl;
                    partQuoteProduct.Part_Number__c                         = item.parentPart.part.Part_Code__c; 
                    partQuoteProduct.Component_Type__c                      = item.parentPart.part.Type__c;
                    partQuoteProduct.Product_Code__c                        = item.parentPart.part.Part_Code__c; //
                    partQuoteProduct.BGC_Number__c                          = item.parentPart.part.BGC_Number__c; 
                    partQuoteProduct.upliftable__c                          = item.parentPart.part.Upliftable__c ? 'Y' : 'N';
                    partQuoteProduct.Component_Group_Type__c                = item.parentPart.part.Type__c;
                    partQuoteProduct.Quote_Description__c                   = returnString(item.parentPart.part.Quote_Description__c, 255);
                    partQuoteProduct.EAN__c                                 = item.parentPart.part.EAN__c;
                    partQuoteProduct.Model_Description__c                   = item.parentPart.part.Model__c;
                    partQuoteProduct.installationLocation__c                = item.installationLocation;
                    partQuoteProduct.installationNotes__c                   = defaultInstallationNotes + item.installationNotes;
                    // if the percentage is 20%, set the FirstVATCode__c to 1, if the percentage is 5% set the FirstVATCode__c to 4
                    Integer vat = Integer.valueOf(item.parentPart.part.VAT_Percentage__c);
                    if(vat != null){
                        if(vat == 20){
                            partQuoteProduct.FirstVATCode__c = 1;
                        } else if(vat == 5){
                            partQuoteProduct.FirstVATCode__c = 4;
                        }
                    }
                    partQuoteProduct.VATABeforeDiscount__c                  = item.parentPart.vatAmount; // -> same as VATAfterDiscount
                    partQuoteProduct.Level_1_Print_Description__c           = item.parentPart.part.Quote_Section__c;
                    partQuoteProduct.Manufacturer__c                        = item.parentPart.part.Manufacturer__c;
                    
                    quoteProducts.add(partQuoteProduct);
                }
                else if(item.isBundle){
                    numberOfParts++;
                    Quote_Product__c bundleQuoteProduct = new Quote_Product__c();
                    
                    // for bundles price should be 0    
                    // if anything is part specific leave it blank for the bundle
                    bundleQuoteProduct.BigMachines_Quote__r = new BigMachines_Quote__c(BigMachines_Transaction_Id__c = bmQuote.BigMachines_Transaction_Id__c );
                    bundleQuoteProduct.Product__c                             = item.parentBundle.Product__c;
                    bundleQuoteProduct.Sales_Price__c                         = 0;
                    bundleQuoteProduct.Quantity__c                            = item.attLastQuantity;
                    //bundleQuoteProduct.geographicUplift__c                  -> no uplift on bundles?
                    //bundleQuoteProduct.vATAAfterDiscount__c                 -> 0
                    bundleQuoteProduct.quotingReason__c                       = 'First Quote';
                    bundleQuoteProduct.price_list_price_each__c               = 0;       
                    //bundleQuoteProduct.Part_Number__c
                    bundleQuoteProduct.Component_Type__c                      = item.parentBundle.Type__c;
                    bundleQuoteProduct.Product_Code__c                        = item.parentBundle.Product_Code__c;
                    //bundleQuoteProduct.BGC_Number__c                        -> N/A
                    //bundleQuoteProduct.upliftable__c                        -> no uplift on bundles?
                    bundleQuoteProduct.Component_Group_Type__c                = item.parentBundle.Type__c;
                    bundleQuoteProduct.Quote_Description__c                   =  returnString(item.parentBundle.Quote_Description__c, 255);
                    //bundleQuoteProduct.EAN__c                               -> N/A
                    //bundleQuoteProduct.Model_Description__c                 -> N/A
                    bundleQuoteProduct.installationLocation__c                = item.installationLocation;
                    bundleQuoteProduct.installationNotes__c                   = defaultInstallationNotes + item.installationNotes;
                    //bundleQuoteProduct.FirstVATCode__c                      -> N/A
                    bundleQuoteProduct.VATABeforeDiscount__c                  = 0;
                    //bundleQuoteProduct.Level_1_Print_Description__c         -> N/A
                    //bundleQuoteProduct.Manufacturer__c                      -> N/A
                    
                    quoteProducts.add(bundleQuoteProduct);
                }   
                
                numberOfParts += item.associatedParts.size();
                
                //Now loop through associated Parts
                for(integer i=0; i<item.associatedParts.size(); i++){
                    CS_PartModelEntry.CS_PartInformation associatedPart = item.associatedParts[i];System.debug('###: ' + associatedPart.part.Part_Code__c);
                    
                    if((associatedPart.part.Part_Code__c == 'P2285') || (associatedPart.part.Part_Code__c == 'PSLT1') || (associatedPart.part.Part_Code__c == 'PSLT2')){
                        bmQuote.RHCStatus__c = 'TRUE';
                    }
                    
                    //EP added 23/06
                    if((associatedPart.part.Part_Code__c == 'P12006')){
                        bmQuote.Customer_Homecare_Contact__c = 'Yes';
                    }
                    
                    Quote_Product__c assPartQuoteproduct = new Quote_Product__c();
                    
                    assPartQuoteproduct.CS_Bundle__c                          = (item.isBundle ? item.parentBundle.Id : null); //link Bundle associated Parts with their CS Bundle
                    assPartQuoteproduct.Product__c                            = associatedPart.part.Product__c;
                    assPartQuoteproduct.BigMachines_Quote__r                  = new BigMachines_Quote__c(BigMachines_Transaction_Id__c = bmQuote.BigMachines_Transaction_Id__c );            
                    assPartQuoteproduct.Sales_Price__c                        = associatedPart.totalPriceIncVAT;
                    assPartQuoteproduct.Quantity__c                           = associatedPart.quantity;
                    assPartQuoteproduct.geographicUplift__c                   = associatedPart.geographicUpliftAmount;
                    assPartQuoteproduct.vATAAfterDiscount__c                  = associatedPart.vatAmount;
                    assPartQuoteproduct.quotingReason__c                      = 'First Quote';
                    assPartQuoteproduct.price_list_price_each__c              = associatedPart.listPrice;    
                    assPartQuoteproduct.GrossSingle__c                        = associatedPart.priceVatIncl;
                    assPartQuoteproduct.Part_Number__c                        = associatedPart.part.Part_Code__c;
                    assPartQuoteproduct.Component_Type__c                     = associatedPart.part.Type__c;
                    assPartQuoteproduct.Product_Code__c                       = associatedPart.part.Part_Code__c;
                    assPartQuoteproduct.BGC_Number__c                         = associatedPart.part.BGC_Number__c;
                    assPartQuoteproduct.upliftable__c                         = associatedPart.part.Upliftable__c ? 'Y' : 'N';
                    assPartQuoteproduct.Component_Group_Type__c               = associatedPart.part.Type__c;
                    assPartQuoteproduct.Quote_Description__c                  = returnString(associatedPart.part.Quote_Description__c, 255);
                    assPartQuoteproduct.EAN__c                                = associatedPart.part.EAN__c;
                    assPartQuoteproduct.Model_Description__c                  = associatedPart.part.Model__c;
                    assPartQuoteproduct.installationLocation__c               = item.installationLocation; // installation location of the parent part? the associated parts do not have it
                    assPartQuoteproduct.installationNotes__c                  = defaultInstallationNotes + item.installationNotes;
                    // -> '1' for 20%, '4' for 5%
                    Integer vat = Integer.valueOf(associatedPart.part.VAT_Percentage__c);
                    if(vat != null){
                        if(vat == 20){
                            assPartQuoteproduct.FirstVATCode__c = 1;
                        } else if(vat == 5){
                            assPartQuoteproduct.FirstVATCode__c = 4;
                        }
                    }                   
                    
                    assPartQuoteproduct.VATABeforeDiscount__c                 = associatedPart.vatAmount;
                    assPartQuoteproduct.Level_1_Print_Description__c          = associatedPart.part.Quote_Section__c;
                    assPartQuoteproduct.Manufacturer__c                       = associatedPart.part.Manufacturer__c;
                    
                    quoteProducts.add(assPartQuoteproduct);
                }       
            } 
            
            if(partCodeList.size()>0)
            {
                Map<string, Product_Order__c> materialCodeMap = new Map<string, Product_Order__c>();
                for(Product_Order__c p: [Select BGC_Number__c, Product_code__c from  Product_Order__c where  Product_Code__c in : partCodeList and BGC_Number__c!= null])
                {
                    materialCodeMap.put(p.Product_code__c,p);
                }
                
                for(Quote_product__c q: quoteProducts ) 
                {
                    if(materialCodeMap.containskey(q.Part_Number__c))
                    {
                        q.BGC_Number__c =  materialCodeMap.get(q.Part_Number__c).BGC_Number__c.replaceall('-','');
                    }
                    
                }
            }
               
            
            bmQuote.Active_QP_Lines__c  = numberOfParts; //number of parts and associated parts//-> Total No of Parts added to the job (automatically as well) - all Placeholder items as well & Bundles
            
            bmQuotes.add(bmQuote);        
        }      
        
        
        if (bmQuotes.size() > 0) { insert bmQuotes; }
            
         if(suspectedMaterialConfig != null)
            {
                List<cscfga__Attribute__c> configAttributeListSM =new List<cscfga__Attribute__c>();
                For(cscfga__Product_Configuration__c  c :suspectedMaterialConfig)
                {
                   Suspect_Material__c suspectMaterial = new Suspect_Material__c();
                    configAttributeListSM= (List<cscfga__Attribute__c>)configsData.get(c.Id +'-attributes');
                    suspectMaterial.BigMachines_Quote__r =new BigMachines_Quote__c(BigMachines_Transaction_Id__c = bmQuotes[0].BigMachines_Transaction_Id__c );
                    suspectMaterial.Asbestos_Removal_Pack__c=getAttributeValue('Asbestos Removal Pack',configAttributeListSM);
                    suspectMaterial.Action_type__c=getAttributeValue('Action type',configAttributeListSM);
                    suspectMaterial.Asbestos_Removal_Pack_Quantity__c= (getAttributeValue('Asbestos Removal Pack Quantity',configAttributeListSM) == null ? null : Integer.valueOf(getAttributeValue('Asbestos Removal Pack Quantity',configAttributeListSM)));
                    suspectMaterial.Room__c=getAttributeValue('Room',configAttributeListSM);
                    suspectMaterial.Sample_Date__c= (string.isBlank(getAttributeValue('Sample Date',configAttributeListSM)) ? null : date.parse(getAttributeValue('Sample Date',configAttributeListSM)));
                    suspectMaterial.Sample_Disturbed__c=getAttributeValue('Disturbed',configAttributeListSM);
                    suspectMaterial.Sample_Location__c=getAttributeValue('Sample Location',configAttributeListSM);
                    suspectMaterial.Sample_Required__c=getAttributeDisplayValue('SampleReq',configAttributeListSM);
                    suspectMaterial.Type__c=getAttributeValue('Type',configAttributeListSM);
                    lstSuspectMaterial.add(suspectMaterial);
                   }
               
            }
            if(lstSuspectMaterial.size()>0){
                insert lstSuspectMaterial;
            }
            //system.debug('motQuestionAnswers-->'+motQuestionAnswers);
            if(motQuestionAnswers.size()>0){
                insertReportableAttributeList.addall(CSAllAttachementTriggerSecondHelper.createHomeEffeciencyReportableAttributes('Home Efficiency',motQuestionAnswers,configsData , bmQuotes[0].Id));
            }
            //system.debug('lstSuspectMaterial='+lstSuspectMaterial); 
            
            
        if (quoteProducts.size() > 0) { insert quoteProducts; }
        if (leadPayments.size() > 0) { if(leadPayments[0].Payment_Gateway_Reference_Number__c!=null)
                                      upsert leadPayments Payment_Gateway_Reference_Number__c; 
                                      else
                                      insert leadPayments; 
                                      System.debug('***WORLDPAY: => ' + leadPayments);
                                    }
        
        if (accountsToBeUpdated.size() > 0) { update accountsToBeUpdated; }
        if (contactsToBeUpdated.size() > 0) { update contactsToBeUpdated;  }
        if (insertReportableAttributeList.size()>0) {insert insertReportableAttributeList; }
        //EP NEW
        createBMQuoteAttachments(bmQuotes, quotePdfToBasketIdMap, quotePdfConfirmationfToBasketIdMap, basketIdToFinanceIllustrationPdf, tempinstallationNotesPDF);
        }catch(Exception e)
        
        {
            System.LoggingLevel level = LoggingLevel.ERROR;
            system.debug(level, e);
            system.debug(level, e.getMessage() +' '+e.getLineNumber());
            list<id> parentId = new list<id>();
            for(Attachment a: triggerMap.values())
            {
                parentId.add(a.ParentId);
            }
            list<Id> oppList = new list<Id>(); 
            for(cscfga__Product_Configuration__c c: [Select cscfga__Product_Basket__r.cscfga__Opportunity__c from cscfga__Product_Configuration__c where Id in:parentId])
            {
                if(c.cscfga__Product_Basket__r.cscfga__Opportunity__c!=null)
                oppList.add(c.cscfga__Product_Basket__r.cscfga__Opportunity__c);
            }
            system.debug('before error-- >'+parentId);
            system.debug('before error-- >'+oppList);
            if(oppList.size()>0)
            {
            Opportunity  opp = [Select id, CHI_Lead_Id1__c from Opportunity where id in :oppList];
            //CreateEmail.CretaeSendTextEmail(system.label.supportNewQuote.split(','),e.getmessage()+' Occured in New QuotTool at line NO: '+e.getLineNumber()+' for Lead :'+opp.CHI_Lead_Id1__c, 'Exception in Online CS_AllAttachmentTriggerHelper. For Lead ID:'+opp.Id+' for HSA :'+userinfo.getName() );
            }
        }
        
    }  
    
    /**
     * Takes as arguments a list of newly created BM Quotes and a Map<BasketId, Attachment> of newly inserted Quote pdf attachments against their Basket
     * Inserts pdf Quote attachments against (new or existing) BM Quote records
     */
    private static void createBMQuoteAttachments(   List<BigMachines_Quote__c> bmQuotes,
                                                    Map<Id, Attachment> quotePdfToBasketIdMap,
                                                    Map<Id, Attachment> quotePdfConfirmationfToBasketIdMap,
                                                    Map<Id, Attachment> basketIdToFinanceIllustrationPdf,
                                                    Map<Id, Attachment> tempinstallationNotesPDF)
    {
        system.debug('****** Creating Pdf ...bmQuotes ');
        Map<Id, Attachment> processedQuotePdfToBasketIdMap = new Map<Id, Attachment>(); //will hold quotePdfs already processed
        Map<Id, Attachment> processedInstallationNotesToBasketIdMap = new Map<Id, Attachment>(); //will hold quoteConfirmationPdfs already processed
        Map<Id, Attachment> processedQuotePdfConfirmationToBasketIdMap = new Map<Id, Attachment>(); //will hold quoteConfirmationPdfs already processed
        
        //Loop through newly created BM Quote records and check if a quotePdf Attachment is in the newly created list of 
        //attachments for every bm Quote's Basket. If so process
        //This is the scenario where the 2 attachments arrive together into SF
        

        
        List<Attachment> bmQuoteAttachments = new List<Attachment>(); //to insert
        List<Id> basketIdsMissingQuotePdf = new List<Id>(); //in the context of this trigger
        List<Id> basketIdsMissingQuoteConfirmationPdf = new List<Id>();
        List<Id> basketIdsMissingFinanceIllustrationPdf = new List<Id>();
        List<Id> basketIdsMissingInstallNotesPdf = new List<Id>();
        Map<Id, BigMachines_Quote__c> basketToBmQuoteWithoutPdfMap = new Map<Id, BigMachines_Quote__c>(); //key is the BasketId
        Map<Id, BigMachines_Quote__c> basketToBmQuoteWithoutConfirmationPdfMap = new Map<Id, BigMachines_Quote__c>();
        Map<Id, BigMachines_Quote__c> basketToBmQuoteWithoutFinanceIllustrationPdfMap = new Map<Id, BigMachines_Quote__c>();
        Map<Id, BigMachines_Quote__c> basketToBmQuoteWithoutInstallNotedsPdfMap = new Map<Id, BigMachines_Quote__c>();

        System.debug('****** Quote PDF attachment not found ... ');
        boolean quotePDFadded = false;
        for (BigMachines_Quote__c bmQuote : bmQuotes) {
            if(bmQuote.Id != null) {
                if (quotePdfToBasketIdMap.containsKey(bmQuote.CS_Quote__c)) {
                    //The 2 attachments arrived together
                    Attachment pdfAttachmentForBasket = quotePdfToBasketIdMap.get(bmQuote.CS_Quote__c); 
                    
                    // Add map entry to processedMap to avoid processing again in the end
                    processedQuotePdfToBasketIdMap.put(bmQuote.CS_Quote__c, pdfAttachmentForBasket);   
                    
                    Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, pdfAttachmentForBasket, 'quote', false);
                    bmQuoteAttachments.add(clonedAttachment);
                    quotePDFadded = true;
                }
                else {
                    System.debug('****** Quote PDF attachment not found ... ');
                    //The pdfQuote has not arrived together with the partsModel Attachment. Check if it is already in the database (if it arrived to SF first)
                    basketIdsMissingQuotePdf.add(bmQuote.CS_Quote__c);
                    basketToBmQuoteWithoutPdfMap.put(bmQuote.CS_Quote__c, bmQuote); //to enable us retrieve the bmQuote of the basket
                }
                
                if (quotePdfConfirmationfToBasketIdMap.containsKey(bmQuote.CS_Quote__c)) {
                    Attachment pdfAttachmentForBasket = quotePdfConfirmationfToBasketIdMap.get(bmQuote.CS_Quote__c);
                    
                    processedQuotePdfConfirmationToBasketIdMap.put(bmQuote.CS_Quote__c, pdfAttachmentForBasket);
                    
                    Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, pdfAttachmentForBasket, 'customer_confirmation',false);
                    bmQuoteAttachments.add(clonedAttachment);
                }
                else {
                    System.debug('****** PDF Confirmation attachment not found ... ');
                    basketIdsMissingQuoteConfirmationPdf.add(bmQuote.CS_Quote__c);
                    basketToBmQuoteWithoutConfirmationPdfMap.put(bmQuote.CS_Quote__c, bmQuote);
                }

                if (basketIdToFinanceIllustrationPdf.containsKey(bmQuote.CS_Quote__c)) {

                    Attachment pdfAttachmentForBasket = basketIdToFinanceIllustrationPdf.get(bmQuote.CS_Quote__c);

                    System.debug(pdfAttachmentForBasket);

                    Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, pdfAttachmentForBasket, 'Finance Illustration', false);
                    bmQuoteAttachments.add(clonedAttachment);
                } else {
                    System.debug('****** Finance Illustration attachment not found ... ');
                    basketIdsMissingFinanceIllustrationPdf.add(bmQuote.CS_Quote__c);
                    basketToBmQuoteWithoutFinanceIllustrationPdfMap.put(bmQuote.CS_Quote__c, bmQuote);
                }
                
                if (tempinstallationNotesPDF.containsKey(bmQuote.CS_Quote__c)) {
                    system.debug('*****inside Installation Notes****');

                    Attachment pdfAttachmentForBasket = tempinstallationNotesPDF.get(bmQuote.CS_Quote__c);
                    //installation notes
                    processedInstallationNotesToBasketIdMap.put(bmQuote.CS_Quote__c, pdfAttachmentForBasket);
                    System.debug(pdfAttachmentForBasket);

                    //check status
                    Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, pdfAttachmentForBasket, ' - Installation notes', true);
                    
                    //removed
                    /*
                    if(bmQuote.stage__c =='Quote Finalised - Accepted'){
                        clonedAttachment.ParentId = bmQuote.Opportunity__c;
                    }
                    */
                    bmQuoteAttachments.add(clonedAttachment);
                    
                } else
                {
                    System.debug('****** INSTALLATION NOTES attachment not found ... ');
                    basketIdsMissingInstallNotesPdf.add(bmQuote.CS_Quote__c);
                    basketToBmQuoteWithoutInstallNotedsPdfMap.put(bmQuote.CS_Quote__c, bmQuote);
                }
            }
        }
        
        if (basketIdsMissingQuotePdf.size() > 0) {
            String pdfQuoteNameFilter = CS_Constants.PdfQuoteFileNamePrefix + '%';
        
            // Check if pdfAttachments already exist in SF for these baskets. If so, clone the attachment to BM Quote
            List<Attachment> existingPdfQuotes = [Select Id, ParentId, Name, Body, Parent.Type
                                                  From Attachment 
                                                  Where ParentId in :basketIdsMissingQuotePdf
                                                    and Name like :pdfQuoteNameFilter
                                                ];
                                                
            for (Attachment existingPdf : existingPdfQuotes) {
                //Create an Attachment for the newly created BmQuote of its Basket
                
                if (basketToBmQuoteWithoutPdfMap.containsKey(existingPdf.ParentId)) {
                    BigMachines_Quote__c bmQuote = basketToBmQuoteWithoutPdfMap.get(existingPdf.ParentId);
                    if(bmQuote.Id != null) {
                        Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, existingPdf, 'quote', false);
                        bmQuoteAttachments.add(clonedAttachment);
                        quotePDFadded = true;
                    }
                }
            }
        }
        
        if (basketIdsMissingQuoteConfirmationPdf.size() > 0) {
            String pdfConfirmationFormNameFilter = CS_Constants.PdfCustomerConfirmationFormPrefix + '%';
            
            List<Attachment> existingPdfQuotes = [Select Id, ParentId, Name, Body, Parent.Type
                                                  From Attachment 
                                                  Where ParentId in :basketIdsMissingQuoteConfirmationPdf
                                                    and Name like :pdfConfirmationFormNameFilter
                                                ];
                                                
            for (Attachment existingPdf : existingPdfQuotes) {
                //Create an Attachment for the newly created BmQuote of its Basket
                
                if (basketToBmQuoteWithoutConfirmationPdfMap.containsKey(existingPdf.ParentId)) {
                    BigMachines_Quote__c bmQuote = basketToBmQuoteWithoutConfirmationPdfMap.get(existingPdf.ParentId);
                    if(bmQuote.Id != null) {
                        Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, existingPdf, 'customer_confirmation',false);
                        bmQuoteAttachments.add(clonedAttachment);
                    }
                }
            }
        }

        if (basketIdsMissingFinanceIllustrationPdf.size() > 0) {
            String pdfNameFilter = 'Finance Illustration%';
        
            // Check if pdfAttachments already exist in SF for these baskets. If so, clone the attachment to BM Quote
            List<Attachment> existingPdfAttachments = [Select Id, ParentId, Name, Body, Parent.Type
                                                  From Attachment 
                                                  Where ParentId in :basketIdsMissingFinanceIllustrationPdf
                                                    and Name like :pdfNameFilter
                                                ];
                                                
            for (Attachment existingPdf : existingPdfAttachments) {
                //Create an Attachment for the newly created BmQuote of its Basket
                
                if (basketToBmQuoteWithoutFinanceIllustrationPdfMap.containsKey(existingPdf.ParentId)) {
                    BigMachines_Quote__c bmQuote = basketToBmQuoteWithoutFinanceIllustrationPdfMap.get(existingPdf.ParentId);
                    if(bmQuote.Id != null) {
                        Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, existingPdf, 'Finance Illustration',false);
                        bmQuoteAttachments.add(clonedAttachment);
                    }
                }
            }
        }
        
         if (basketIdsMissingInstallNotesPdf.size() > 0) {
            System.debug('*AN ----Something with Inst notes');
            String pdfNameFilter = 'Installation notes%';
        
            // Check if pdfAttachments already exist in SF for these baskets. If so, clone the attachment to BM Quote
            List<Attachment> existingPdfAttachments = [Select Id, ParentId, Name, Body, Parent.Type
                                                  From Attachment 
                                                  Where ParentId in :basketIdsMissingInstallNotesPdf
                                                    and Name like :pdfNameFilter
                                                ];
                                                
            for (Attachment existingPdf : existingPdfAttachments) {
                //Create an Attachment for the newly created BmQuote of its Basket
                
                if (basketToBmQuoteWithoutInstallNotedsPdfMap.containsKey(existingPdf.ParentId)) {
                    BigMachines_Quote__c bmQuote = basketToBmQuoteWithoutInstallNotedsPdfMap.get(existingPdf.ParentId);
                    if(bmQuote.Id != null) {
                        Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, existingPdf, 'Installation notes', true);
                        clonedAttachment.Name = bmQuote.Name +' - Installation notes.pdf';
                        /*
                        if(bmQuote.Stage__c == 'Quote Finalised - Accepted'){
                            clonedAttachment.ParentId = bmQuote.Opportunity__c;
                        }
                        */
                        bmQuoteAttachments.add(clonedAttachment);
                    }
                }
            }
        }
        
        
            
        
        //Pdf Quote Attachments that arrive into SF after the partsModel will fall under the 'unprocessed' pdf attachments category, see below.
        
        //Now loop though quotePdfs that are NOT processed and check if the bmQuote record for the Basket has already been created.
        //Scenario where partsModel attachment has arrived first and BM Quote has already been created
        List<Id> unprocessedPdfBasketIds = new List<Id>();
        for (Id basketId : quotePdfToBasketIdMap.keySet()) {
            if (!processedQuotePdfToBasketIdMap.containsKey(basketId)) {
                unprocessedPdfBasketIds.add(basketId);
            }
        }
        for (Id basketId : quotePdfConfirmationfToBasketIdMap.keySet()) {
            if (!processedQuotePdfConfirmationToBasketIdMap.containsKey(basketId)) {
                unprocessedPdfBasketIds.add(basketId);
            }
        }

        //Installation notes
        for (Id basketId : tempinstallationNotesPDF.keySet()) {
            if (!processedInstallationNotesToBasketIdMap.containsKey(basketId)) {
                unprocessedPdfBasketIds.add(basketId);
            }
        }

        System.debug('###/// ' + unprocessedPdfBasketIds.size() + ' ' + unprocessedPdfBasketIds);
        if (unprocessedPdfBasketIds.size() > 0) {
            List<BigMachines_Quote__c> existingBmQuotes = [select Id,Name, BigMachines_Transaction_Id__c, CS_Quote__c, Opportunity__c,Stage__c 
                                                            from BigMachines_Quote__c
                                                            where CS_Quote__c in :unprocessedPdfBasketIds];
            System.debug('****** unprocessedPdfBasketIds' + unprocessedPdfBasketIds);
            System.debug('****** existingBmQuotes' + existingBmQuotes);
            for (BigMachines_Quote__c bmQuote : existingBmQuotes) {
                //these are the BM Quotes for which we will now create the quotePdf Attachment
                if(bmQuote.Id != null) {
                    if (quotePdfToBasketIdMap.containsKey(bmQuote.CS_Quote__c)) {
                        Attachment pdfAttachmentForBasket = quotePdfToBasketIdMap.get(bmQuote.CS_Quote__c); 
                           
                        // Add map entry to processedMap to avoid processing again in the end
                        processedQuotePdfToBasketIdMap.put(bmQuote.CS_Quote__c, pdfAttachmentForBasket);   
                        
                        Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, pdfAttachmentForBasket, 'quote', false);
                        bmQuoteAttachments.add(clonedAttachment);
                        quotePDFadded = true;
                    }
                    if (quotePdfConfirmationfToBasketIdMap.containsKey(bmQuote.CS_Quote__c)) {
                        Attachment pdfAttachmentForBasket = quotePdfConfirmationfToBasketIdMap.get(bmQuote.CS_Quote__c);
                        
                        processedQuotePdfConfirmationToBasketIdMap.put(bmQuote.CS_Quote__c, pdfAttachmentForBasket);
                        
                        Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, pdfAttachmentForBasket, 'customer_confirmation', false);
                        bmQuoteAttachments.add(clonedAttachment);
                        //quotePDFadded = true;
                    }

                    if (tempinstallationNotesPDF.containsKey(bmQuote.CS_Quote__c)) {
                        Attachment pdfAttachmentForBasket = tempinstallationNotesPDF.get(bmQuote.CS_Quote__c);
                        //installation notes
                        processedInstallationNotesToBasketIdMap.put(bmQuote.CS_Quote__c, pdfAttachmentForBasket);
                        
                        Attachment clonedAttachment = createPdfAttachmentForBmQuote(bmQuote, pdfAttachmentForBasket, 'installation_notes', true);
                        
                        System.debug('*****created cloned attt ==oppId =='+bmQuote.Opportunity__c);
                        System.debug('*****stage is =='+bmQuote.Stage__c);
                        
                        if(bmQuote.Stage__c == 'Quote Finalised - Accepted'){
                            clonedAttachment.ParentId = bmQuote.Opportunity__c;

                            System.debug('*****attach to opp is =='+bmQuote.Opportunity__c);
                        }
                        
                        bmQuoteAttachments.add(clonedAttachment);
                    }

                }
            }
            
        }
        
        //Finally insert all the bmQuoteAttachments
        
        system.debug('Auto attach quote pdf -->'+quotePDFadded+' '+bmQuotes);
        insert bmQuoteAttachments;
        if(!quotePDFadded && system.label.Generate_Quote_PDF_Future=='on' && (bmQuotes[0].Job_Type__c == '15' ||bmQuotes[0].Job_Type__c == '17'))
        {
            customerPortalAcceptCloneQuote.addAttachment(bmQuotes[0].id,bmQuotes[0].BigMachines_Transaction_Id__c);
        }
       
    }
    
    
    /**
     * Takes as argumentsa BM Quote record to create the attachment for and the original attachment
     * Returns the cloned Attachment re-parented
     */
    private static Attachment createPdfAttachmentForBmQuote(BigMachines_Quote__c bmQuote, Attachment pdfAttachment, String nameSuffix, Boolean checkStatus) {
        System.debug('***** bmQuote ' + bmQuote);
        System.debug('***** pdfAttachment ' + pdfAttachment);
        
        Attachment clonedAttachment = pdfAttachment.clone(false);
        //clonedAttachment.OwnerId = UserInfo.getUserId();
        clonedAttachment.Name = bmQuote.BigMachines_Transaction_Id__c + '_' + nameSuffix + '.pdf'; //required, as this triggers extra processes
        
        System.debug('Inside create --- stage'+bmQuote.stage__c);
        System.debug('Inside create --- opportunity'+bmQuote.Opportunity__c);

        //if(nameSuffux.toLowerCase().indexOf('installation')!=1){
        if(checkStatus==true){  
            clonedAttachment.Name = bmQuote.Name + ' - Installation notes.pdf';
            System.debug('Inside create --- INSTALLATION');
            //if(bmQuote.stage__c == 'Quote Finalised - Not Accepted'){
                clonedAttachment.ParentId = bmQuote.Id;

            //}
            if(bmQuote.stage__c == 'Quote Finalised - Accepted'){
                
                clonedAttachment.ParentId = bmQuote.Opportunity__c;
                
            }
        }
        else{
            clonedAttachment.ParentId = bmQuote.Id;
        }
        
        
        return clonedAttachment;
    }
    
    /**
     * Returns a concatenated string of installation notes required on every quote product. 
     * @param {cscfga__Product_Configuration__c} pc     A root product configuration.
     * @param {List<cscfga__Product_Configuration__c>}  childConfigurations     A list of related configurations to the root configuration.
     * @param {Map<Id, cscfga__Product_Configuration__c>}  rootIdToControlsConfigMap  A map of root configurations and child configurations (Controls).
     * @param {Map<String, CS_PartModelEntry>} partsModel    A deserialized map of parts and bundles from the created product configurations. 
     */
    private static String getInstallationNotes(cscfga__Product_Configuration__c pc, List<cscfga__Product_Configuration__c> childConfigurations, 
        Map<Id, cscfga__Product_Configuration__c> rootIdToControlsConfigMap, Map<String, CS_PartModelEntry> partsModel, Map<String, Object> configsData){
        
        List<cscfga__Attribute__c> attributeList = pc.cscfga__Attributes__r;
    
         //AaJSON
        List<cscfga__Attribute__c> configAttributeListInst = (List<cscfga__Attribute__c>)configsData.get(pc.Id +'-attributes');
                
        
        String installationNotes = '', 
               boilerNameAndLocation = '', 
               flueNotes = '', 
               condensateRouteNotes = '', 
               availableHeight = '', 
               availableWidth = '', 
               availableDepth = '', 
               controlLocation = '', 
               programmer = '',
               newline = '\n';
        
        String propertyType             = getAttributeValue('Property Section', configAttributeListInst) != null ? getAttributeValue('Property Section', configAttributeListInst) : '',
               numberOfBedrooms         = getAttributeValue('Number of Bedrooms', configAttributeListInst) != null ? getAttributeValue('Number of Bedrooms', configAttributeListInst) : '',
               existingSystemType       = getAttributeValue('Existing System', configAttributeListInst) != null ? getAttributeValue('Existing System', configAttributeListInst) : '',
               totalPropertyHeatloss    = getAttributeValue('Total Heat Loss Adjusted', configAttributeListInst) != null ? getAttributeValue('Total Heat Loss Adjusted', configAttributeListInst) : '';
        
        cscfga__Product_Configuration__c boilerConfiguration = getConfigurationByName('Boiler', childConfigurations);
        //2017
        if(boilerConfiguration == null){
            boilerConfiguration = getConfigurationByName('Boiler 1', childConfigurations);
        }
        cscfga__Product_Configuration__c controlsConfig = rootIdToControlsConfigMap.get(pc.Id);
        system.debug('******** control config: ' + controlsConfig);
        
        // A check is added here whether or not it is a straight swap 
        // boiler name and location are then populated
        String straightSwapBoilerLocation = getAttributeValue('Boiler Installation Location', configAttributeListInst) != null ? getAttributeValue('Boiler Installation Location', configAttributeListInst) : '';
        if(pc.cscfga__Product_Definition__r.Name == 'Straight Swaps') {
            boilerNameAndLocation = partsModel.get('Boiler_Id_0').parentPart.part.Name + ' in ' + straightSwapBoilerLocation;
        } else if(pc.cscfga__Product_Definition__r.Name == 'Online Boilers') {
            String boilerName = getAttributeValue('Select Boiler', configAttributeListInst) != null ? getAttributeValue('Select Boiler', configAttributeListInst) : '';
            String boilerInstallationLocation = getAttributeValue('Boiler Installation Location', configAttributeListInst) != null ? getAttributeValue('Boiler Installation Location', configAttributeListInst) : '';
            boilerNameAndLocation = boilerName + ' in ' + boilerInstallationLocation;
        } else if(partsModel.get('Boiler_0:Boiler_0') != null){
            boilerNameAndLocation       = partsModel.get('Boiler_0:Boiler_0').parentPart.part.Name + ' in ' + partsModel.get('Boiler_0:Boiler_0').installationLocation;
            flueNotes                   = partsModel.get('Boiler_0:Boiler_0').installationNotes;
            condensateRouteNotes        = partsModel.get('Boiler_0:Boiler_0').installationNotes;
        }
        
        if(boilerConfiguration != null){
             //AaJSON
            List<cscfga__Attribute__c> configAttributeListInstBoiler = (List<cscfga__Attribute__c>)configsData.get(boilerConfiguration.Id +'-attributes');
         
            availableHeight             = getAttributeValue('Height', configAttributeListInstBoiler) != '' ? getAttributeValue('Height', configAttributeListInstBoiler) : '0';
            availableWidth              = getAttributeValue('Width', configAttributeListInstBoiler) != '' ? getAttributeValue('Width',configAttributeListInstBoiler) : '0';
            availableDepth              = getAttributeValue('Depth', configAttributeListInstBoiler) != '' ? getAttributeValue('Depth', configAttributeListInstBoiler) : '0';
            if(controlsConfig != null){
                 //AaJSON
                List<cscfga__Attribute__c> configAttributeListInstControls = (List<cscfga__Attribute__c>)configsData.get(controlsConfig.Id +'-attributes');
         
                controlLocation             = getAttributeValue('Location', configAttributeListInstControls);
                programmer                  = partsModel.get('Boiler_0:Controls_0:Programmer_Id_0') !=null ? partsModel.get('Boiler_0:Controls_0:Programmer_Id_0').parentPart.part.Name : '';
            }
        }
    
        String socketAndSeeResult       = getAttributeValue('Socket and See reading', attributeList);
        
        installationNotes += 'PROPERTY TYPE: '              + propertyType                  + newline +
                             'No of BEDS: '                 + numberOfBedrooms              + newline +
                             'EXISTING SYSTEM TYPE: '       + existingSystemType            + newline + 
                             'FIT '                         + boilerNameAndLocation         + newline +
                             'Total property heatloss = '   + totalPropertyHeatloss + 'kW'  + newline +
                             'Available height = '          + availableHeight + 'mm' +      + newline +
                             'Available width = '           + availableWidth  + 'mm' +      + newline +
                             'Available depth = '           + availableDepth  + 'mm' +      + newline +
                             'FLUE NOTES: '                                                 + newline +
                             flueNotes                                                      + newline +
                             'CONDENSATE ROUTE NOTES: '                                     + newline +
                             condensateRouteNotes                                           + newline +
                             'CONTROLS NOTES: '                                             + newline +
                             'Location: '                   + controlLocation               + newline +
                             'Programmer = '                + programmer +                  + newline +
                             'GAS SUPPLY ROUTE: '                                           + newline +
                                                                                            + newline +    
                             'BUILDING WORK: '                                              + newline +
                                                                                            + newline +
                             'ELECTRICAL: '                                                 + newline +
                             'Socket and see result: '      + socketAndSeeResult +          + newline +
                                                                                            + newline +
                             'DISRUPTION: '                                                 + newline +
                             'CUSTOMER TO DO: '                                             + newline +
                             'ADDITIONAL NOTES: '                                           + newline;
        
        return installationNotes;
    }
    
    /**
     * Returns an Id from and attribute specified by name.
     * @param {String} attributeName    An attribute name.
     * @param {List<cscfga__Attribute__c>} attributeList    A list of attributes.
     * @returns {Id}
     */
    private static Id getAttributeId(String attributeName, List<cscfga__Attribute__c> attributeList){
        try{
            for(cscfga__Attribute__c attr : attributeList){
                if(attr.Name == attributename) return attr.Id;
            }   
        } catch (Exception ex){
            return null;        
        }
        return null;  
    }
    
    /**
     * Returns an attribute value from an attribute specified by name.
     * @param {String} attributeName    An attribute name.
     * @param {List<cscfga__Attribute__c>} attributeList    A list of attributes.
     * @returns {String}
     */ 
    private static String getAttributeValue(String attributeName, List<cscfga__Attribute__c> attributeList){
        for(cscfga__Attribute__c attr : attributeList){
            if(attr.Name == attributename) return attr.cscfga__Value__c;
        }   
        return '';
    }
    
    /**
     * Returns an attribute Display Value  from an attribute specified by name.
     * @param {String} attributeName    An attribute name.
     * @param {List<cscfga__Attribute__c>} attributeList    A list of attributes.
     * @returns {String}
     */ 
    private static String getAttributeDisplayValue(String attributeName, List<cscfga__Attribute__c> attributeList){
        for(cscfga__Attribute__c attr : attributeList){
            if(attr.Name == attributename) return attr.cscfga__Display_Value__c;
        }   
        return '';
    }
    
    //AaJSON
     private static String getAttributeDefId(String attributeName, List<cscfga__Attribute__c> attributeList){
        for(cscfga__Attribute__c attr : attributeList){
            if(attr.Name == attributename) return attr.cscfga__Attribute_Definition__c;
        }   
        return '';
    }
    
    
    /**
     * Returns an attribute field value from and attribute specified by Id, and the attribute field name.
     * @param {Id} attributeId  A selected attribute id.
     * @param {String} attributeFieldName   An attribute field name.
     * @param {List<cscfga__Attribute_Field__c>} attributeFields    A list of attribute fields.
     * @returns {String}
     */
    private static String getAttributeFieldValue(Id attributeId, String attributeFieldName, List<cscfga__Attribute_Field__c> attributeFields){
        for(cscfga__Attribute_Field__c attributeField : attributeFields){
            if((attributeField.cscfga__Attribute__c == attributeId) && (attributeField.Name == attributeFieldName)){
                return attributeField.cscfga__Value__c;
            }
        }
        return '';
    }
    
     private static String getAttributeFieldValueAaJSON(String attributeFieldName, List<cscfga__Attribute_Field__c> attributeFields){
        try{
        for(cscfga__Attribute_Field__c attributeField : attributeFields){
            if(attributeField.Name == attributeFieldName){
                return attributeField.cscfga__Value__c;
            }
            
        }
        return '';
        }
        catch(Exception ex){
           System.debug('Exception in getAttributeFieldValueAaJSON: ' + ex);
           return ''; 
        }
        
    }
    
    /**
     * Returns a cscfga__Product_Configuration__c from a list of supplied product configurations, with a specific name.
     * @param {String} configurationName    A configuration name.
     * @param {List<cscfga__Product_Configuration__c>} productConfigurations    A list of product configurations.
     * @returns {cscfga__Product_Configuration__c}
     */ 
    private static cscfga__Product_Configuration__c getConfigurationByName(String configurationName, List<cscfga__Product_Configuration__c> productConfigurations){
        if(productConfigurations != null){
            for(cscfga__Product_Configuration__c pc : productConfigurations){
                if(pc.Name == configurationName){
                    return pc;
                }
            }
        }
        return null;
    }
    private static list<cscfga__Product_Configuration__c> getAllConfigurationByName(String configurationName, List<cscfga__Product_Configuration__c> productConfigurations){
        list<cscfga__Product_Configuration__c> pcList = new list<cscfga__Product_Configuration__c>();
        if(productConfigurations != null){
            for(cscfga__Product_Configuration__c pc : productConfigurations){
                if(pc.Name.contains(configurationName)){
                    pcList.add(pc);
                }
            }
        }
        return pcList;
    } 
    /**
     * Returns a map of skill codes and total skill hours per skill code.
     * @param {Map<String, CS_PartModelEntry>} mapPartsModel    A map of parts present in the product configuration.
     * @returns {Map<String, Decimal>}
     */ 
    private static Map<String, Decimal> calculateTotalSkillHours(Map<String, CS_PartModelEntry> mapPartsModel){
        Map<String, Decimal> skillMap = new Map<String, Decimal>();
        for(String key : mapPartsModel.keySet()){
            CS_PartModelEntry item = mapPartsModel.get(key);  
            
            if(item.isPart && !item.isMultilookup && item.parentPart != null){
                for(Integer i = 0; i<item.parentPart.skillsList.size(); i++){
                    String skillCode = item.parentPart.skillsList[i].skillCode;
                    Decimal quantity = item.parentPart.quantity != null ? item.parentPart.quantity : 1;
                    Decimal skillHours = item.parentPart.skillsList[i].hours * quantity;
                    if(skillMap.containsKey(skillCode)){
                        skillHours += skillMap.get(skillCode);                    
                    }
                    skillMap.put(skillCode, skillHours);               
                } 
            }
            
            for(integer i=0; i<item.associatedParts.size(); i++){
               for(Integer j = 0; j<item.associatedParts[i].skillsList.size(); j++){
                    String skillCodeA = item.associatedParts[i].skillsList[j].skillCode;
                    Decimal quantityA = item.associatedParts[i].quantity != null ? item.associatedParts[i].quantity : 1;
                    Decimal skillHoursA = item.associatedParts[i].skillsList[j].hours * quantityA;
                    if(skillMap.containsKey(skillCodeA)){
                        skillHoursA += skillMap.get(skillCodeA);                    
                    }
                    skillMap.put(skillCodeA, skillHoursA);               
                } 
            }      
                      
        }
        return skillMap;
    }
    
    /**
     * Tries to parse a Decimal value from a provided String value.
     * Returns 0.00 if the parsing was unsuccessful.
     * @param {String} value    A string representation of a decimal value.
     * @returns {Decimal}
     */ 
    private static Decimal returnDecimal(String value){
        try {
            return Decimal.valueOf(value);
        } catch (Exception ex){
            return 0.00;
        }   
    }  
    
    /**
     * Tries to parse a date from string. Returns a parsed date or a null value if the parsing was unsuccessful.
     * @param {String} d    A string representation of a date value.
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
    
    private static DateTime returnDateTime(String d){
        if (d == null) {
            return null;
        }
    
        try {
          DateTime parsedDate = DateTime.parse(d); 
          return parsedDate; 
        }
        catch (TypeException e) {
          try {
                DateTime parsedDate = DateTime.valueOf(d); 
                return parsedDate;
            }
            catch (TypeException ex) {
              return null;
            }        
        }
        return null;    
    }

     public static Date returnDate(){
        
        return null;    
    }



    /**
     * Returns a boolean value true or false from the supplied String value.
     * @param {String} value    A string value of true or false.
     * @returns {Boolean}
     */ 
    public static Boolean returnBoolean(String value){
        if(value != null){
            if(value.toUpperCase() == 'TRUE'){
                return true;
            } else {
                return false;
            }   
        } else {
            return false;
        }
    }
    
    /**
     * Returns a return value if a supplied string contains '--None--'
     * @param {String} value    A supplied value.
     * @param {String} returnValue  A value to be returned if applicable.
     * @returns {String}
     */
    private static String returnValueInsteadOfNone(String value, String returnValue){
        if((value!=null) && (value.contains('--None--'))){
            return returnValue;
        } else {
            return value;
        }
    }
    
    private static String returnString(String value, Integer charCount) {
        if (String.isNotEmpty(value)) {
            return (value.length() > charCount ? value.substring(0, charCount-1) : value);
        }
        
        return '';
    }
    
    /** 
     * Returns a job type list from the combination of existing and required system types as well as a required job type.
     * @param {String} existingSystemType  An existing system type.
     * @param {String} systemTypeRequired  A required system type.
     * @param {String} jobTypeRequired  A required job type.
     * @param {String} jobTypeRequired  A required Product Defination Name .
     */
     
    private static List<String> jobTypeListFromCombination(String existingSystemType, String systemTypeRequired, String jobTypeRequired, String productDef){
        
        
        String existingSystemTypeCombination    = 'Combination';
        String existingSystemTypeConventional   = 'Conventional';
        String existingSystemTypeWarmAir        = 'Warm Air';
        String existingSystemTypeNoHeating      = 'No Heating';
        
        String systemTypeRequiredCombination    = 'Combination';
        String systemTypeRequiredConventional   = 'Conventional';
      
        
        String jobTypeRequiredFull              = 'Full System';
        String jobTypeRequiredReplacement       = 'Boiler Replacement';
        String jobTypeStraightSwap              = 'Straight Swap';
        String jobTypeOnlineBoiler              = 'Online Boilers';
        system.debug('---->'+productDef);
        if(productDef!=null &&  productDef.contains(jobTypeOnlineBoiler))
            return new List<String>{'16', jobTypeOnlineBoiler};
        if(productDef!=null &&  productDef.contains(jobTypeStraightSwap) || productDef.contains('Combination')){
            return new List<String>{'15', jobTypeStraightSwap};
        } else if(productDef!=null &&  productDef.contains('Conventional'))
        {
            return new List<String>{'17', 'Telesales Conv'};
        }
        
        else if((existingSystemType == existingSystemTypeCombination) && (systemTypeRequired == systemTypeRequiredCombination) && (jobTypeRequired == jobTypeRequiredReplacement)){
            if(productDef!=null &&  productDef.contains('Small Commercial'))
            return new List<String>{'18', 'Small Commercial Combi to combi replacement'};
            else
            return new List<String>{'2', 'Combi to combi replacement'};
        } else if((existingSystemType == existingSystemTypeConventional) && (systemTypeRequired == systemTypeRequiredCombination) && (jobTypeRequired == jobTypeRequiredReplacement)){
            if(productDef!=null &&  productDef.contains('Small Commercial'))
            return new List<String>{'19', 'Small Commercial Conv to combi replacement'};
            else
            return new List<String>{'3', 'Conventional to combi replacement'};
        } else if((existingSystemType == existingSystemTypeConventional) && (systemTypeRequired == systemTypeRequiredConventional) && (jobTypeRequired == jobTypeRequiredReplacement)){
            if(productDef!=null &&  productDef.contains('Small Commercial'))
            return new List<String>{'20', 'Small Commercial Conv to conv replacement'};
            else
            return new List<String>{'4', 'Conventional to conventional replacement'};
        } else if((existingSystemType == existingSystemTypeNoHeating) && (systemTypeRequired == systemTypeRequiredCombination) && (jobTypeRequired == jobTypeRequiredFull)){
            if(productDef!=null &&  productDef.contains('Small Commercial'))
            return new List<String>{'21', 'Small Commercial New combi system'};
            else
            return new List<String>{'6', 'New combi system'};
        } else if((existingSystemType == existingSystemTypeNoHeating) && (systemTypeRequired == systemTypeRequiredConventional) && (jobTypeRequired == jobTypeRequiredFull)){
            if(productDef!=null &&  productDef.contains('Small Commercial'))
            return new List<String>{'22', 'Small Commercial New conv system'};
            else
            return new List<String>{'7', 'New conv system'};
        } else if((existingSystemType == existingSystemTypeCombination) && (systemTypeRequired == systemTypeRequiredCombination) && (jobTypeRequired == jobTypeRequiredFull)){
            if(productDef!=null &&  productDef.contains('Small Commercial'))
            return new List<String>{'23', 'Small Commercial Replacement combi full system'};
            else
            return new List<String>{'8', 'Replacement combi full system'};
        } else if((existingSystemType == existingSystemTypeConventional) && (systemTypeRequired == systemTypeRequiredConventional) && (jobTypeRequired == jobTypeRequiredFull)){
            if(productDef!=null &&  productDef.contains('Small Commercial'))
            return new List<String>{'24', 'Small Commercial Replacement conv full system'};
            else
            return new List<String>{'9', 'Replacement conventional full system'};
        } else {
            return new List<String>{'1', 'Job Type not selected'};
        }
    }
    
}