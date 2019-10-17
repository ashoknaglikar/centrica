trigger UpdateCountryDifferentiator on Lead (after update) 
{
    if(Trigger.new[0].PostalCode != Trigger.old[0].PostalCode)
    {
        System.debug('Post code has been updated');
        String strPostcode = '';
        String strFirstPart = '';
        String strSecondPart = '';
        String strCountry = '';
        String strCode = '';
        ID patchId;
        strPostcode = Trigger.new[0].PostalCode ;
        
        if(strPostcode != null)
        {
            strPostcode = strPostcode.trim();
        }
        else
        {
            strPostcode = '';
        }        
        
        if ((strPostcode.length()!= 0))
        {         
            strPostcode = strPostcode.replace(' ', '');
            
            //If postcode length is 5 char
            if((strPostcode.length() == 5))
            {
                strPostcode = strPostcode.substring(0, 3);
                strFirstPart = strPostcode.substring(0, 2);
                strSecondPart = strPostcode.subString(2,3);
            }
                 
            //If postcode length is 6 char
            if((strPostcode.length() == 6))
            {
                strPostcode = strPostcode.substring(0, 4);
                strFirstPart = strPostcode.substring(0, 3);
                strSecondPart = strPostcode.subString(3,4);
            }
    
            //If postcode length is 7 char
            if((strPostcode.length() == 7))
            {
                strPostcode = strPostcode.substring(0, 5);
                strFirstPart = strPostcode.substring(0, 4);
                strSecondPart = strPostcode.subString(4,5);
            }
            
            System.debug('First Value of strPostcode = ' + strPostcode );            
            strPostcode = strFirstPart + ' ' + strSecondPart ;            
            System.debug('Second Value of strPostcode = ' + strPostcode );
                        
            Postcode_Sector__c[] postcodesec = [Select p.Sub_Patch__c, p.Sub_Patch__r.Id, p.Sub_Patch__r.Country_Differentiator__c, p.Sub_Patch__r.Code__c 
            from Postcode_Sector__c p where name =: strPostcode and Type__c='Sales'];
             
             if(!postcodesec.isEmpty())
             {
                 for(Postcode_Sector__c postcodesector: postcodesec) 
                 {                 
                     System.debug('Value of Country = ' + postcodesector.Sub_Patch__r.Country_Differentiator__c);
                     strCountry = postcodesector.Sub_Patch__r.Country_Differentiator__c;
                     strCode = postcodesector.Sub_Patch__r.Code__c ;
                     patchId = postcodesector.Sub_Patch__r.Id;
                     
                     Lead lead = [Select Scottish_Exec__c, Country_Differentiator__c, Sales_Subpatch__c from lead a 
                     where a.Id=:Trigger.new[0].Id];
                     
                     lead.Country_Differentiator__c = strCountry;
                     lead.Sales_Subpatch__c = patchId;
                     
                     /*Scottish Exec flag is set by workflow*/
                     /*
                     if(strCountry != null)
                     {
                         if(strCountry.equalsIgnoreCase('Scotland'))
                         {
                             lead.Scottish_Exec__c = true;
                         }
                         else
                         {
                             lead.Scottish_Exec__c = false;
                         }
                     }
                     */
                     
                     update lead;                              
                 }
             }
        }
        else
        {
            //Set the Country Differentiator to empty
            //Set the Sales Subpatch to empty    
            strCountry = '';
            strCode = '';            
                        
            Lead lead = [Select Scottish_Exec__c, Country_Differentiator__c, Sales_Subpatch__c from lead a 
            where a.Id=:Trigger.new[0].Id];
                     
            lead.Country_Differentiator__c = strCountry;
            lead.Sales_Subpatch__c = patchId;
            lead.Scottish_Exec__c = false;
            update lead;                           
        }   
    }
}