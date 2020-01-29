@RestResource(urlMapping='/getBundles/*')
global with sharing class onlineBoilersBundleReturn {
    
    @httpget
    global static bundleResponseClass.BundleResponse getBundles()
    {
        RestRequest req = RestContext.request;
        
        Map<String, String> headers = req.headers;
        
        system.debug(headers);
        
        //Request Headers
        bundleRequestClass.BundleRequest bun = new bundleRequestClass.BundleRequest();
        bun = bundleRequestClass.parse(headers.get('RequestParameters'));
        
        //bun.Address = new bundleRequestClass.Address();
        
        // format postcode correctly
        string trimmed_code;
        string first_part;
        string second_part;
        string reformatted_code;
        string post_code_sector;
        trimmed_code    = bun.Address.Postcode.replace(' ', '');
        system.debug('trimmed_code = ' + trimmed_code);
        second_part     = trimmed_code.substring(trimmed_code.length()-3, trimmed_code.length());
        system.debug('second_part = ' + second_part);
        first_part      = trimmed_code.substring(0, trimmed_code.length()-second_part.length());
        system.debug('first_part = ' + first_part);
        reformatted_code = first_part + ' ' + second_part;
        system.debug('reformatted_code = ' + reformatted_code);
        string sector = reformatted_code.substring(0,reformatted_code.length()-2);
        system.debug('sector = ' + sector);
        Postcode_sector__c pc = [Select id, Country__c From Postcode_Sector__c where Name = :sector and Type__c = 'Sales'];
        
        string scotland = 'No';
        string plumekit = 'No';
        string isHomeCare = 'No';
        string hiveReq = 'No';
        
        
        if(pc.Country__c == 'Scotland')
        scotland = 'Yes';
        
        
        
        plumekit = bun.plumeKitReq ? 'Yes' :'No';
        
        isHomeCare = bun.isHomeCare ? 'Yes' :  'No';
        
        hiveReq = bun.hiveReq ? 'Yes': 'No';
        
        bundleResponseClass.BundleResponse response = new bundleResponseClass.BundleResponse();
        response.bundles = new list<bundleResponseClass.Bundle>();
        //bundleResponseClass.OptionalExtra ect = new bundleResponseClass.OptionalExtra();
        
        List<bundleResponseClass.OptionalExtra> optionalExtras = new list<bundleResponseClass.OptionalExtra> {/*ect*/};
        
        response.Address = bun.Address;
        response.activeLeadExists = 'No';
        
        // check exisitng Leads
        string billingStreet = response.Address.NameNumber + ' ' +response.Address.Street;
        string test_acc_name = reformatted_code.trim() + ' ' + (billingStreet.length()>29 ? billingStreet.substring(0,29): billingStreet);
        system.debug('Searching for Account with Account_Id__c of: ' + test_acc_name);
        
        List<Account> existing_accs = [SELECT  Id FROM Account WHERE Account_Id__c = :test_acc_name ]; // use this field as it is indexed
        
        if(existing_accs.size()>0)
        {   
           
            List<Opportunity> existing_leads = [SELECT Id, CloseDate, StageName, CHI_Lead_Id1__c,Product_Interest__c, AccountId ,LeadSource, (select id from Bigmachines_Quotes__r),(Select id, Status__c,Visit_Date__c from Appointments__r where Status__c = 'Appointed')
                                        FROM Opportunity
                                        WHERE AccountId = :existing_accs[0].id
                                        AND CloseDate >= :Date.Today() order by StageName limit 1];
   
            
            
            if (existing_leads.size() > 0 ) { 
                 
                for(Opportunity o : existing_leads)
                {
                    system.debug('--Oppo--'+o);
                    
                    if( o.Bigmachines_Quotes__r.size()>0)
                    {
                       response.activeLeadExists = 'Yes';
                       response.leadReference =  o.CHI_Lead_Id1__c;
                       break;
                    }
                    
                    if(o.StageName =='Appointed' || o.StageName =='Active')
                    {
                        for(Appointment__c a: o.Appointments__r)
                        {
                            system.debug('--Appointent--'+a);
                            if(a.Visit_Date__c>=system.today())
                            {
                                response.activeLeadExists = 'Yes';
                                response.leadReference = o.CHI_Lead_Id1__c;
                                break;
                            }
                        }
                    }
                    
                }
            }
        }
        
        for(Bundle__c b : [Select id, Name,Install_Price__c ,Reference_Code__c, Gross_Price__c, Total_Price__c, Total_Allowances__c, (Select id, Name, CS_Part__r.Name, CS_Part__r.Description__c, CS_Part__c, CS_Part__r.Part_Code__c, Price__c, Quantity__c from Bundle_Parts__r ), (Select id, Amount__c, Code__c,CS_Allowance__c, CS_Allowance__r.Name from Bundle_Allowances__r where Active__c = true) from Bundle__c 
                          where Scotland__c = :Scotland and Hive__c = :hiveReq and Plume_Kit__c = :plumekit and active__c = true])
        {
            decimal activeallowaceTotal = 0;
            bundleResponseClass.Bundle bundleObj = new bundleResponseClass.Bundle();
            bundleObj.optionalExtras = optionalExtras;                      
            
            bundleObj.installPrice = b.Install_Price__c;
            bundleObj.totalBundlePrice = b.Gross_Price__c;
            /*
            bundleObj.totalPriceAfterDiscount = b.Total_Price__c;
            bundleObj.totalAllowance = b.Total_Allowances__c;
            */
            bundleObj.id = b.Reference_Code__c;
                    
            for(Bundle_Part__c bp: b.Bundle_Parts__r)
            {
                //system.debug(bp.CS_Part__r.Name.ToUpperCase().Contains('HIVE') + ' '+bp.CS_Part__r.Name);
                if(bp.CS_Part__r.Part_Code__c.Startswith('CBLR'))
                {
                    bundleObj.boilerCode  = bp.CS_Part__r.Part_Code__c;
                    bundleObj.boilerName = bp.CS_Part__r.Description__c;
                    bundleObj.boilerPrice = bp.Price__c;
                    //break;
                }else if(bp.CS_Part__r.Name.ToUpperCase().Contains('HIVE'))
                {
                    bundleObj.hivePrice = bp.Price__c;
                }
            }
            bundleObj.installPrice = bundleObj.totalBundlePrice - bundleObj.hivePrice - bundleObj.hivePrice;
            bundleObj.allowances = new list<bundleResponseClass.Allowance>();
            for(Bundle_Allowance__c ba: b.Bundle_Allowances__r)
            {
                bundleResponseClass.Allowance allowance = new bundleResponseClass.Allowance();
                allowance.name = ba.CS_Allowance__r.Name;
                allowance.amount = ba.Amount__c;
                allowance.code = ba.Code__c;
                allowance.sfId = ba.CS_Allowance__c;
                bundleObj.allowances.add(allowance);  
                activeallowaceTotal+=ba.Amount__c;
            }
            
            // add extra discount for Homecare
            if(isHomeCare == 'Yes')
            {
                CS_Allowance__c aw = [Select id,Amount__c,  Allowance_Code__c,Quote_Description__c, Name  from CS_Allowance__c where onlineHCDiscount__c = true limit 1];
                if(aw!=null)
                {
                    bundleResponseClass.Allowance allowance = new bundleResponseClass.Allowance();
                    allowance.name = aw.Quote_Description__c;
                    allowance.amount = aw.Amount__c;
                    allowance.code = aw.Allowance_Code__c;
                    allowance.sfId = aw.Id;
                    bundleObj.allowances.add(allowance); 
                    //bundleObj.totalAllowance += aw.Amount__c;
                    //bundleObj.totalPriceAfterDiscount -= aw.Amount__c;
                    activeallowaceTotal+=aw.Amount__c;
                }
                
                
            }
            bundleObj.totalPriceAfterDiscount = b.Gross_Price__c - activeallowaceTotal ;
            bundleObj.totalAllowance = activeallowaceTotal;
            
            response.bundles.add(bundleObj);
            
            
        }
        
        return response;
        
    }
    
}