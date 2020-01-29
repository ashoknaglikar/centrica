public class OnlineQuoteHelper {
    
    public static CS_QuoteOnlineTemplateController.AllQuoteData createQuotePDFData(BigMachines_Quote__c bQuote)
    {
        CS_QuoteOnlineTemplateController.AllQuoteData inputQuoteData = new CS_QuoteOnlineTemplateController.AllQuoteData();
        inputQuoteData.customerName  = bQuote.Opportunity__r.Account.Primary_Contact__r.Salutation+' '+bQuote.Opportunity__r.Account.Primary_Contact__r.Name;
        System.debug('inputQuoteData.customerName: ' + inputQuoteData.customerName);
        inputQuoteData.wwabGas1YearCareExists = false;
        inputQuoteData.installationAddress  = bQuote.Opportunity__r.Install_Address_Street__c;
        //2017
        inputQuoteData.billingPostcode  = bQuote.Opportunity__r.Account.Primary_Contact__r.MailingPostalCode;
        inputQuoteData.billingStreet = bQuote.Opportunity__r.Account.Primary_Contact__r.MailingStreet + ' '+ bQuote.Opportunity__r.Account.Primary_Contact__r.MailingCity;
        inputQuoteData.billingCounty  = bQuote.Opportunity__r.Account.Primary_Contact__r.MailingState;
        
        inputQuoteData.hsaName  = bQuote.App_Assigned_To__c;
        inputQuoteData.allowancesApplied = '£'+string.valueof(bQuote.appliedAllowancesTotal__c);
        inputQuoteData.deposit = string.valueof(bQuote.depositOnPricing__c);
        if(bQuote.depositOnPricing__c >0)
        inputQuoteData.depositPaidBy = 'Card';
        inputQuoteData.balance = '£'+string.valueof(bQuote.finalNetQuoteTotal__c - bQuote.depositOnPricing__c);
        inputQuoteData.balanceToBePaidBy = bQuote.POC_Payment_Method__c;
        
        inputQuoteData.quoteDate = bQuote.CreatedDate.date().format();
        inputQuoteData.quoteNumber = bQuote.Name;
        inputQuoteData.quoteRef = bQuote.Opportunity__r.CHI_Lead_Id__c;
        
        
        list<string> partCode = new list<string>();
        map<string, Quote_Product__c> quoteMap = new map<string, Quote_Product__c>();
    
        for(Quote_Product__c qp : bQuote.Quote_Products__r)
        {
            partCode.add(qp.Name);
            
            quoteMap.put(qp.Name, qp);
            /*if(!inputQuoteData.wwabGas1YearCareExists  && IV_Vectors__c.getInstance('wwabGas1YearCareProductName').key__c.contains(qp.name))
            inputQuoteData.wwabGas1YearCareExists = true;*/
            
        }
        
        
        // get all sections
        // sort all sections
        String sectionQuery = 'Select ' + CS_SObjectHelper.getFieldListForSOQL('CS_Template_Section_Header__c') + ' From CS_Template_Section_Header__c ORDER BY Sequence__c';
        
        List<CS_Template_Section_Header__c> allSections = ((List<CS_Template_Section_Header__c>)database.query(sectionQuery));
                      
        Map<Id, CS_Template_Section_Header__c> allSectionsMap = new Map<Id, CS_Template_Section_Header__c>(allSections);
        
        // create a map of level1 to level2 sections
        Map<Id, List<Id>> level1toLevel2Map = new Map<Id, List<Id>>();
        for(CS_Template_Section_Header__c section : allSections) {
            // check if a section is a level 2 section
            if(section.Level_1_Section__c != null) {
                if (level1toLevel2Map.get(section.Level_1_Section__c) == null) {
                    level1toLevel2Map.put(section.Level_1_Section__c, new List<Id>());
                }              
                level1toLevel2Map.get(section.Level_1_Section__c).add(section.Id);
                
            } else {
                if (level1toLevel2Map.get(section.Id) == null) level1toLevel2Map.put(section.Id, new List<Id>());
            }
        }
        
        
        map<string, CS_Part__c > codePartMap = new map<string, CS_Part__c>();
        for(CS_Part__c CSPart : [Select id, Part_Code__c, Quote_Description__c, Quote_Section__c, CS_Template_Section_Header__c,Section_Level__c, Section_Name__c
                                from CS_Part__c where Part_Code__c = : partCode])
        {
            codePartMap.put(CSPart.Part_Code__c, CSPart);
            
        }
        
        map<string, CS_Bundle__c> codeBundleMap = new map<string, CS_bundle__c>();
        //map<string, string> partcodeBundleMap = new map<string, string>();
        for(CS_Bundle__c CSBundle : [Select Id , Quote_Description__c, Product_Code__c ,Section_Level__c, CS_Template_Section_Header__c, (Select id, Part_Code__c from CS_Bundle_Part_Associations__r) from CS_Bundle__c 
                                    where Product_Code__c in : partCode])
        {
            codeBundleMap.put(CSBundle.Product_Code__c , CSBundle);
            /*
            for(CS_Bundle_Part_Association__c bpa:  CSBundle.CS_Bundle_Part_Associations__r)
            partcodeBundleMap.put(bpa.Part_code__c, CSBundle.Product_Code__c);
            */
            
        }
        
        
        decimal boilerPrice = 0.0;
        decimal level1PriceWithoutBoiler = 0.0;
        decimal level2PriceExtras = 0.0;
        integer charPerLine = 30;
        
        map<Id,  list<CS_Part__c>> templatePartMap = new map<Id,  list<CS_Part__c>>();
        map<Id,  list<CS_Bundle__c>> templateBundleMap = new map<Id,  list<CS_Bundle__c>>();
        
        map<id, CS_QuoteOnlineTemplateController.PDFQuoteDetailSection> level2Sections= new map<id, CS_QuoteOnlineTemplateController.PDFQuoteDetailSection>();
        map<id, CS_QuoteOnlineTemplateController.PDFQuoteDetailSection> level1Sections= new map<id, CS_QuoteOnlineTemplateController.PDFQuoteDetailSection>();
        decimal noSection = 0.0;           
        //CS_QuoteOnlineTemplateController.PDFQuoteDetailSection noPriceSection = new CS_QuoteOnlineTemplateController.PDFQuoteDetailSection();
        for(Quote_Product__c qp : bQuote.Quote_Products__r)
        {
            string quoteDes = '';
            if(qp.Name.StartsWith('CBLR'))
            boilerPrice += qp.Gross_Total__c;
            else
            {
                if(!codePartMap.containsKey(qp.Name))
                level1PriceWithoutBoiler +=qp.Gross_Total__c;
                
                if(codePartMap.containsKey(qp.Name))
                {
                    CS_Part__c cp = codePartMap.get(qp.Name);
                    
                    if(cp.Section_Level__c == 'Level 2')
                    {
                        CS_Template_Section_Header__c header = allSectionsMap.get(cp.CS_Template_Section_Header__c);
                        CS_Template_Section_Header__c parentHeader = allSectionsMap.get(header.Level_1_Section__c);
                        if(parentHeader.Name.touppercase().Contains('EXTRAS'))
                        level2PriceExtras +=qp.Gross_Total__c;
                        else
                        level1PriceWithoutBoiler +=qp.Gross_Total__c;
                        
                    }else 
                    level1PriceWithoutBoiler +=qp.Gross_Total__c;
                    
                }
            }
            string templateId ;
            
            if(codePartMap.containskey(qp.Name))
            {
                CS_Part__c innerPart = codePartMap.get(qp.Name);
                quoteDes = innerPart.Quote_Description__c;
                if(!templatePartMap.containskey(innerPart.CS_Template_Section_Header__c))
                templatePartMap.put(innerPart.CS_Template_Section_Header__c, new list<CS_Part__c>{innerPart});
                else
                templatePartMap.get(innerPart.CS_Template_Section_Header__c).add(innerPart);
                templateId = innerPart.CS_Template_Section_Header__c;
            }else
            
            if(codeBundleMap.containskey(qp.Name))
            {
                CS_Bundle__c innerBundle = codeBundleMap.get(qp.Name);
                quoteDes = innerBundle.Quote_Description__c;
                if(!templateBundleMap.containskey(innerBundle.CS_Template_Section_Header__c))
                templateBundleMap.put(innerBundle.CS_Template_Section_Header__c, new list<CS_Bundle__c>{innerBundle});
                else
                templateBundleMap.get(innerBundle.CS_Template_Section_Header__c).add(innerBundle);
                templateId = innerBundle.CS_Template_Section_Header__c;
            }else
            {
                noSection+=qp.Gross_Total__c;
            }
            
            if(templateId!=null && quoteDes!=null)
            {
                //quoteDes = quoteDes.replace('Your', '');
                CS_Template_Section_Header__c tempObj = allSectionsMap.get(templateId);
                
                string total = qp.Gross_Total__c>0 ? '£'+string.valueof(qp.Gross_Total__c):'';
                if(tempObj.Level_1_Section__c !=null)
                {
                    if(!level2Sections.containskey(tempObj.id))
                    {
                        CS_QuoteOnlineTemplateController.PDFQuoteDetailSection newSec  = new CS_QuoteOnlineTemplateController.PDFQuoteDetailSection('Level2' , tempObj.Name.replace('Your', ''));
                        newSec.items = new list<CS_QuoteOnlineTemplateController.PDFQuoteLineItem>{new CS_QuoteOnlineTemplateController.PDFQuoteLineItem (quoteDes,  qp.Quantity__c, total, qp.Id)};
                        level2Sections.put(tempObj.id, newSec);
                        newSec.line +=(2+(quoteDes.length()/charPerLine)+1);
                    }
                    else
                    {
                        CS_QuoteOnlineTemplateController.PDFQuoteDetailSection newSec  = level2Sections.get(tempObj.id);
                        newSec.items.add(new CS_QuoteOnlineTemplateController.PDFQuoteLineItem (quoteDes,  qp.Quantity__c, total, qp.Id));
                        newSec.line +=(quoteDes.length()/charPerLine)+1;
                    }
                }else
                {
                    if(!level1Sections.containskey(tempObj.id))
                    {
                        CS_QuoteOnlineTemplateController.PDFQuoteDetailSection newSec  = new CS_QuoteOnlineTemplateController.PDFQuoteDetailSection('Level1' , tempObj.Name.replace('Your', ''));
                        newSec.items = new list<CS_QuoteOnlineTemplateController.PDFQuoteLineItem>{new CS_QuoteOnlineTemplateController.PDFQuoteLineItem (quoteDes,  qp.Quantity__c, total, qp.Id)};
                        level1Sections.put(tempObj.id, newSec);
                        newSec.line +=2+(quoteDes.length()/charPerLine)+1;
                    }
                    else
                    {
                        CS_QuoteOnlineTemplateController.PDFQuoteDetailSection newSec  = level1Sections.get(tempObj.id);
                        newSec.items.add(new CS_QuoteOnlineTemplateController.PDFQuoteLineItem (quoteDes,  qp.Quantity__c, total, qp.Id));
                        newSec.line +=(quoteDes.length()/charPerLine)+1;
                    }
                }
            }else
            {
                 noSection+=qp.Gross_Total__c;
            }
                
                
        }
        inputQuoteData.innerPdfQuoteDetail = new list<list<CS_QuoteOnlineTemplateController.PDFQuoteDetailSection>>();
        
        if(boilerPrice <=0)
        inputQuoteData.wwabQuote = true;
        
        list<CS_QuoteOnlineTemplateController.PDFQuoteDetailSection> sectionByPage = 
                new list<CS_QuoteOnlineTemplateController.PDFQuoteDetailSection>();
        
        decimal linePerPage = 25;
        decimal totalline = 1;
        
        for(id i : level1toLevel2Map.keySet())
        {
            if(level1Sections.containsKey(i))
            {
                sectionByPage.add(level1Sections.get(i));
                totalline+=level1Sections.get(i).line;
            }
            
            for(id j : level1toLevel2Map.get(i))
            {
                
                if(level2Sections.containsKey(j))
                {
                    
                    CS_Template_Section_Header__c child =   allSectionsMap.get(j);
                    if(child.Name.contains('installation and associated work'))
                    {
                        for(CS_QuoteOnlineTemplateController.PDFQuoteLineItem item : level2Sections.get(j).items)
                        {
                            if(item.price == '' && item.Name.contains('We will replace your existing'))
                            {
                                item.price= '£'+string.valueof(noSection);  
                                break;
                            }
                        }
                    }
                    if(!level1Sections.containsKey(child.Level_1_Section__c))
                    {
                        CS_Template_Section_Header__c parent =  allSectionsMap.get(child.Level_1_Section__c);
                        CS_QuoteOnlineTemplateController.PDFQuoteDetailSection obj = new CS_QuoteOnlineTemplateController.PDFQuoteDetailSection('Level1' , parent.Name.replace('Your', ''));
                        sectionByPage.add(obj);
                        level1Sections.put(parent.Id,obj);
                        totalline++;
                    }
                    sectionByPage.add(level2Sections.get(j));
                    totalline+=level2Sections.get(j).line;
                }
            }
            
            if(totalline>linePerPage)
            {
                
                //fo(CS_QuoteOnlineTemplateController.PDFQuoteDetailSection : inputQuoteData)
                inputQuoteData.innerPdfQuoteDetail.add(new list<CS_QuoteOnlineTemplateController.PDFQuoteDetailSection>(sectionByPage));
                sectionByPage.clear();
                totalline = 1;
            }
            
        }
        if(sectionByPage.size()>0)
        {
            inputQuoteData.innerPdfQuoteDetail.add(new list<CS_QuoteOnlineTemplateController.PDFQuoteDetailSection>(sectionByPage));
        }
        if(inputQuoteData.innerPdfQuoteDetail.size()>0)
        {
            string boilerplus = bQuote.Boiler_Plus_Reasons__c == 'Included'?'Your Heating system is compliant with the Boiler Plus legislation as you have selected a compatible control which will help reduce your energy usage.':'Based on the information you have provided, your system already contains controls which meet the requirements for Boiler Plus, if our engineer identifies that this is not correct on the day of installation they will discuss the options you have. Please note new time and temperature controls will be chargeable.';
            integer size = inputQuoteData.innerPdfQuoteDetail.size();
            integer temp = inputQuoteData.innerPdfQuoteDetail[size-1].size();
            inputQuoteData.innerPdfQuoteDetail[size-1][temp-1].items.add(new CS_QuoteOnlineTemplateController.PDFQuoteLineItem (boilerplus, 1, null, null));
        }
       //inputQuoteData.innerPdfQuoteDetail = detailSectionMap.values()[0];
       //system.debug('***************'+detailSectionMap.values()[0]);
       //createEmail.CretaeSendTextEmail(new list<string>{'ashokkumar.nagaleekar@centrica.com'}, json.serialize(inputQuoteData.innerPdfQuoteDetail.size()) , 'Response');
       inputQuoteData.innerTopSummaryTable = new list< CS_QuoteOnlineTemplateController.SummaryTableType>();
       inputQuoteData.allowances = new list<CS_QuoteOnlineTemplateController.allowanceClass>();
       if(boilerPrice>0)
       inputQuoteData.innerTopSummaryTable.add(
            new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                 'Boiler', 
                                 'summary-section', 
                                  boilerPrice, 
                                 'section-price right')); 
      
      inputQuoteData.innerTopSummaryTable.add(
            new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                 'Installation Essentials', 
                                 'summary-section', 
                                  level1PriceWithoutBoiler, 
                                 'section-price right'));
      
      if(level2PriceExtras>0)                             
      inputQuoteData.innerTopSummaryTable.add(
            new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                 'Tailored Extras', 
                                 'summary-section', 
                                  level2PriceExtras, 
                                 'section-price right'));
                                 
                                 
       inputQuoteData.innerTopSummaryTable.add(
            new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                 'Total gross price (inc. VAT)', 
                                 'summary-section', 
                                  bQuote.finalPriceVisibleToCustomer__c, 
                                 'section-price right')); 
        list<id> allowancesAdded = new list<Id>();
        
        if (bQuote.CS_Allowance_1__c != null) {
            
            inputQuoteData.innerTopSummaryTable.add(
                    new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                         'Our offers for you', 
                                         'boldText slate', 
                                         '', 
                                         'section-price'));
            
            if(bQuote.allowance_desc_1__c != null && bQuote.appliedAmount1__c != null)
            {
                inputQuoteData.innerTopSummaryTable.add(
                                    new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                    bQuote.allowance_desc_1__c, 
                                    'allowance-label', 
                                    bQuote.appliedAmount1__c, 
                                    'allowance-value right'));
                                    
               inputQuoteData.allowances.add(new CS_QuoteOnlineTemplateController.allowanceClass(bQuote.allowance_desc_1__c, bQuote.appliedAmount1__c));
               allowancesAdded.add(bQuote.CS_Allowance_1__c);
            }
            if(bQuote.allowance_desc_2__c != null && bQuote.appliedAmount2__c != null)
            {
                inputQuoteData.innerTopSummaryTable.add(
                                    new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                    bQuote.allowance_desc_2__c, 
                                    'allowance-label', 
                                    bQuote.appliedAmount2__c, 
                                    'allowance-value right'));
                inputQuoteData.allowances.add(new CS_QuoteOnlineTemplateController.allowanceClass(bQuote.allowance_desc_2__c, bQuote.appliedAmount2__c));
                allowancesAdded.add(bQuote.CS_Allowance_2__c);
            }
            if(bQuote.allowance_desc_3__c != null && bQuote.appliedAmount3__c != null)
            {
                inputQuoteData.innerTopSummaryTable.add(
                                    new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                    bQuote.allowance_desc_3__c, 
                                    'allowance-label', 
                                    bQuote.appliedAmount3__c, 
                                    'allowance-value right'));
                inputQuoteData.allowances.add(new CS_QuoteOnlineTemplateController.allowanceClass(bQuote.allowance_desc_3__c, bQuote.appliedAmount3__c));
                allowancesAdded.add(bQuote.CS_Allowance_3__c);
            }
            if(bQuote.allowance_desc_4__c != null && bQuote.appliedAmount4__c != null)
            {
                inputQuoteData.innerTopSummaryTable.add(
                                    new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                    bQuote.allowance_desc_4__c, 
                                    'allowance-label', 
                                    bQuote.appliedAmount4__c, 
                                    'allowance-value right'));
                inputQuoteData.allowances.add(new CS_QuoteOnlineTemplateController.allowanceClass(bQuote.allowance_desc_4__c, bQuote.appliedAmount4__c));
                allowancesAdded.add(bQuote.CS_Allowance_4__c);
            }
            if(bQuote.allowance_desc_5__c != null && bQuote.appliedAmount5__c != null)
            {
                inputQuoteData.innerTopSummaryTable.add(
                                    new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                    bQuote.allowance_desc_5__c, 
                                    'allowance-label', 
                                    bQuote.appliedAmount5__c, 
                                    'allowance-value right'));
                inputQuoteData.allowances.add(new CS_QuoteOnlineTemplateController.allowanceClass(bQuote.allowance_desc_5__c, bQuote.appliedAmount5__c));
                allowancesAdded.add(bQuote.CS_Allowance_5__c);
            }
            if(bQuote.allowance_desc_6__c != null && bQuote.appliedAmount6__c != null)
            {
                inputQuoteData.innerTopSummaryTable.add(
                                    new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                    bQuote.allowance_desc_6__c, 
                                    'allowance-label', 
                                    bQuote.appliedAmount6__c, 
                                    'allowance-value right'));
                inputQuoteData.allowances.add(new CS_QuoteOnlineTemplateController.allowanceClass(bQuote.allowance_desc_6__c, bQuote.appliedAmount6__c));
                allowancesAdded.add(bQuote.CS_Allowance_6__c);
            }
            if(bQuote.allowance_desc_7__c != null && bQuote.appliedAmount7__c != null)
            {
                inputQuoteData.innerTopSummaryTable.add(
                                    new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                    bQuote.allowance_desc_7__c, 
                                    'allowance-label', 
                                    bQuote.appliedAmount7__c, 
                                    'allowance-value right'));
                inputQuoteData.allowances.add(new CS_QuoteOnlineTemplateController.allowanceClass(bQuote.allowance_desc_7__c, bQuote.appliedAmount7__c));
            }
            inputQuoteData.tAndCs = '';
            system.debug('Before t & c--->'+allowancesAdded);
            for(CS_Allowance__c c: [Select T_C_s__c from CS_Allowance__c where Id in : allowancesAdded ])
            {
                system.debug('I am in T7 Cs - -->'+c);
                if(c.T_C_s__c!=null)
                inputQuoteData.tAndCs += c.T_C_s__c ;
            }
            inputQuoteData.innerTopSummaryTable.add(
                    new CS_QuoteOnlineTemplateController.SummaryTableType('', 
                                         'Total discount', 
                                         'discount-total boldText', 
                                         bQuote.discountsTotalOnPricing__c, 
                                         'section-total boldText right'));
            
           inputQuoteData.allowances.add(new CS_QuoteOnlineTemplateController.allowanceClass('Total Discounts', bQuote.discountsTotalOnPricing__c)); 
        } 
        
        
     
        return inputQuoteData;   
    }

}