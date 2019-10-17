public class TestUpdateCountryDifferentiator 
{
    static testMethod void updateCountryDifferentiator() 
    {
        String leadid = '';
        String newPostalCode = '';
        
       //Create Lead
        Lead lead = new Lead(Status='Open', FirstName='Centrica', LastName='Evian', PostalCode='BN1 1JH', Street='Flat 3, 26 Maybury Road', Company='Centrica');          
        Database.insert(lead);
        
        leadid = lead.Id;
        lead = [SELECT a.Scottish_Exec__c, a.Country_Differentiator__c, a.Sales_Subpatch__c FROM Lead a WHERE a.Id = :leadid];      
        Postcode_Sector__c subPacthBN1 = [Select p.Sub_Patch__r.Id, p.Sub_Patch__c, p.Name From Postcode_Sector__c p where name='BN1 1' and type__c = 'Sales' ];  
        System.assertEquals('England', lead.Country_Differentiator__c);
        //System.assertEquals(false, lead.Scottish_Exec__c);
        System.assertEquals(subPacthBN1.Sub_Patch__c , lead.Sales_Subpatch__c);
        
        leadid = lead.Id;
        newPostalCode = 'BN2 1JH';
        
        Lead[] newLead =  [SELECT a.PostalCode FROM Lead a WHERE a.Id = :leadid];      
        System.assertEquals(1, newLead.size());
        newLead[0].PostalCode = newPostalCode;
        Database.update(newLead);
        
        newLead =  [SELECT a.Scottish_Exec__c, a.Country_Differentiator__c, a.Sales_Subpatch__c FROM Lead a WHERE a.Id = :leadid];  
        Postcode_Sector__c subPacthBN2 = [Select p.Sub_Patch__r.Id, p.Sub_Patch__c, p.Name From Postcode_Sector__c p where name='BN2 1' and type__c = 'Sales' ];                              
        //System.assertEquals('Scotland', newLead[0].Country_Differentiator__c);
        //System.assertEquals(subPacthBN2.Sub_Patch__c, newLead[0].Sales_Subpatch__c);
        //System.assertEquals(true, newLead[0].Scottish_Exec__c);
        
        newPostalCode = '';
        newLead =  [SELECT a.PostalCode FROM Lead a WHERE a.Id = :leadid]; 
        System.assertEquals(1, newLead.size());     
        newLead[0].PostalCode = newPostalCode;
        Database.update(newLead);
        
        newLead =  [SELECT a.Scottish_Exec__c, a.Country_Differentiator__c, a.Sales_Subpatch__c FROM Lead a WHERE a.Id = :leadid];      
        System.assertEquals(null, newLead[0].Country_Differentiator__c);
        System.assertEquals(null, newLead[0].Sales_Subpatch__c);
        
        newPostalCode = 'BN11JH';
        newLead =  [SELECT a.PostalCode FROM Lead a WHERE a.Id = :leadid]; 
        System.assertEquals(1, newLead.size());     
        newLead[0].PostalCode = newPostalCode;
        Database.update(newLead);
        
        newLead =  [SELECT a.Scottish_Exec__c, a.Country_Differentiator__c, a.Sales_Subpatch__c FROM Lead a WHERE a.Id = :leadid]; 
        subPacthBN1 = [Select p.Sub_Patch__r.Id, p.Sub_Patch__c, p.Name From Postcode_Sector__c p where name='BN1 1' and type__c = 'Sales' ];       
        System.assertEquals('England', newLead[0].Country_Differentiator__c);
        System.assertEquals(subPacthBN1.Sub_Patch__c, newLead[0].Sales_Subpatch__c);
        //System.assertEquals(false, newLead[0].Scottish_Exec__c);
        
        newPostalCode = 'BN21 2JH';
        newLead =  [SELECT a.PostalCode FROM Lead a WHERE a.Id = :leadid];
        System.assertEquals(1, newLead.size());     
        newLead[0].PostalCode = newPostalCode;
        Database.update(newLead);
        
        newLead =  [SELECT a.Scottish_Exec__c, a.Country_Differentiator__c, a.Sales_Subpatch__c FROM Lead a WHERE a.Id = :leadid];
        subPacthBN2 = [Select p.Sub_Patch__r.Id, p.Sub_Patch__c, p.Name From Postcode_Sector__c p where name='BN2 1' and type__c = 'Sales' ];      
//        System.assertEquals('Scotland', newLead[0].Country_Differentiator__c);
  //      System.assertEquals(subPacthBN2.Sub_Patch__c, newLead[0].Sales_Subpatch__c);
        //System.assertEquals(true, newLead[0].Scottish_Exec__c);
        
        newPostalCode = 'E1 0AB';
        newLead =  [SELECT a.PostalCode FROM Lead a WHERE a.Id = :leadid];
    //    System.assertEquals(1, newLead.size());     
        newLead[0].PostalCode = newPostalCode;

        Database.update(newLead);
        
        newLead =  [SELECT a.Scottish_Exec__c, a.Country_Differentiator__c, a.Sales_Subpatch__c FROM Lead a WHERE a.Id = :leadid];      
        
                //Create Lead
        Lead lead1 = new Lead(Status='Open', FirstName='Centrica', LastName='Evian', PostalCode='BN21 2JH', Street='Flat 3, 26 Maybury Road', Company='Centrica');          
        Database.insert(lead1);        
        
        leadid = lead1.Id;
        lead1 = [SELECT a.Scottish_Exec__c, a.Country_Differentiator__c, a.Sales_Subpatch__c FROM Lead a WHERE a.Id = :leadid];      
        subPacthBN2 = [Select p.Sub_Patch__r.Id, p.Sub_Patch__c, p.Name From Postcode_Sector__c p where name='BN2 1' and type__c = 'Sales' ];
          
      //  System.assertEquals('Scotland', lead1.Country_Differentiator__c);
        //System.assertEquals(subPacthBN2.Sub_Patch__c, lead1.Sales_Subpatch__c);
        //System.assertEquals(true, lead1.Scottish_Exec__c);   
        
                //Create Lead
        Lead lead2 = new Lead(Status='Open', FirstName='Centrica', LastName='Evian', Street='Flat 3, 26 Maybury Road', Company='Centrica');          
        Database.insert(lead2);        
        
        leadid = lead2.Id;
        lead2 = [SELECT a.Scottish_Exec__c, a.Country_Differentiator__c, a.Sales_Subpatch__c FROM Lead a WHERE a.Id = :leadid];      
        
        //System.assertEquals(null, lead2.Country_Differentiator__c);
        //System.assertEquals(null, lead2.Sales_Subpatch__c);
        //System.assertEquals(false, lead2.Scottish_Exec__c);                    

    }
}