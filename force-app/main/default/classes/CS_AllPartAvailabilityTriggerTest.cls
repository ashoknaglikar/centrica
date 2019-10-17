@isTest
public with sharing class CS_AllPartAvailabilityTriggerTest {

    static testMethod void insertPartAvailabilityTest(){
    
        Test.startTest();
        
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;
        insert vat20;
        
        List<CS_Part__c> partList = new List<CS_Part__c>();
        List<Region__c> regionList = new List<Region__c>(); 
                
        for(Integer i=0; i< 100; i++){
            partList.add(new CS_Part__c(Name = 'Test part 0009', Part_Code__c = string.valueOf(i), VAT_Code__c = vat20.Id));                
        }
        
        regionList.add(new Region__c(Name = 'Test region northeast', Code__c = '001', Type__c = 'Sales'));        
        regionList.add(new Region__c(Name = 'Test region southeast', Code__c = '002', Type__c = 'Sales'));
        
        insert partList;
        insert regionList;
        
        List<CS_Part__c> queriedPartsList = [select Id, Name, Included_In_Regions__c from CS_Part__c where Id in :partList];
        List<Region__c> queriedRegionsList = [select Id, Name from Region__c where Name = 'Test region northeast'];
        
        List<CS_Part_Availability__c> partAvailabilities = new List<CS_Part_Availability__c>();             
        for(Integer i=0; i< queriedPartsList.size(); i++){
            partAvailabilities.add(new CS_Part_Availability__c(CS_Part__c = queriedPartsList[i].Id, Region__c = queriedRegionsList[0].Id ));
        }
        
        insert partAvailabilities;
            
        List<CS_Part__c> queriedUpdatedPartsList = [select Id, Name, Included_In_Regions__c from CS_Part__c];
        for(Integer i=0; i< queriedUpdatedPartsList.size(); i++){
            System.debug(queriedUpdatedPartsList[i].Included_In_Regions__c );
            System.assertNotEquals(queriedUpdatedPartsList[i].Included_In_Regions__c, 'Test region southeast');
        }
        
        Test.stopTest();
    }
    
    static testMethod void includedInRegionsOnPartAvailabilityDeleteTest(){
        
        Test.startTest();
        
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;
        insert vat20;
        
        List<CS_Part__c> partList = new List<CS_Part__c>();
        List<Region__c> regionList = new List<Region__c>(); 
                
        for(Integer i=0; i< 100; i++){
            partList.add(new CS_Part__c(Name = 'Test part 0009', Part_Code__c = string.valueOf(i), VAT_Code__c= vat20.Id));                
        }
        
        regionList.add(new Region__c(Name = 'Test region northeast', Code__c = '001' ,Type__c = 'Sales'));        
        regionList.add(new Region__c(Name = 'Test region southeast', Code__c = '002', Type__c = 'Sales'));
        
        insert partList;
        insert regionList;
        
        List<CS_Part__c> queriedPartsList = [select Id, Name, Included_In_Regions__c from CS_Part__c where Id in :partList];
        List<Region__c> queriedRegionsList = 
            [select Id, Name from Region__c where Name = 'Test region northeast' or Name = 'Test region southeast'];
        
        List<CS_Part_Availability__c> partAvailabilities = new List<CS_Part_Availability__c>();             
        for(Integer i=0; i< queriedPartsList.size(); i++){
            partAvailabilities.add(new CS_Part_Availability__c(CS_Part__c = queriedPartsList[i].Id, Region__c = queriedRegionsList[0].Id ));
            partAvailabilities.add(new CS_Part_Availability__c(CS_Part__c = queriedPartsList[i].Id, Region__c = queriedRegionsList[1].Id ));
        }
        
        insert partAvailabilities;
        
        List<CS_Part_Availability__c> queriedPAs = [select Id from CS_Part_Availability__c];
        
        delete queriedPAs;
        
        List<CS_Part__c> finalPartList = [select Id, Name, Included_In_Regions__c from CS_Part__c where Id in :partList ];
        for(CS_Part__c p : finalPartList){
            System.assertEquals(p.Included_In_Regions__c, ',Test region northeast,Test region southeast,');
        }
        
        Test.stopTest();
    }
    
}