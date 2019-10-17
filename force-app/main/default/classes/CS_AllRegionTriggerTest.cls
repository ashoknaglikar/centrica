@isTest
public with sharing class CS_AllRegionTriggerTest {

    static testMethod void testRegionUpdateIncludedListOnPart() {
        
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;

        insert vat20;
        
        List<Region__c> regionList = new List<Region__c>();
        List<CS_Part__c> partList = new List<CS_Part__c>();
             
        List<String> regionNames = new List<String>();
        regionNames.add('test region 0');
        regionNames.add('test region 1');
        regionNames.add('test region 2');

        partList.add(new CS_Part__c(Name = 'test part 0', Part_Code__c = '0', VAT_Code__c = vat20.Id));
        regionList.add(new Region__c(Name = regionNames[0], Code__c = '0', Type__c ='Sales'));

        partList.add(new CS_Part__c(Name = 'test part 1', Part_Code__c = '1', VAT_Code__c = vat20.Id));
        regionList.add(new Region__c(Name = regionNames[1], Code__c = '1', Type__c ='Sales'));

        partList.add(new CS_Part__c(Name = 'test part 2', Part_Code__c = '2', VAT_Code__c = vat20.Id));
        regionList.add(new Region__c(Name = regionNames[2], Code__c = '2', Type__c ='Sales'));

        
        insert partList;
        insert regionList;
        
        // Create a Part Availability for a CS Part
        CS_Part_Availability__c pav = new CS_Part_Availability__c(CS_Part__c = partList[0].Id, Region__c = regionList[0].Id);
        insert pav;
        
        List<Region__c> queriedRegions = [select Id, Name, Code__c from Region__c];
        
        
        Test.startTest();
        
        List<CS_Part__c> queriedParts = [select Id, Name, Included_In_Regions__c from CS_Part__c];
        
        for ( Integer i = 0; i < queriedParts.size(); i++) {

            System.debug(queriedParts[i].Included_In_Regions__c);
            
            if ( i == 0 ) {
                System.assert(queriedParts[i].Included_In_Regions__c == ',test region 0,');
            }
            else {
                String[] regions = queriedParts[i].Included_In_Regions__c.split(',');
                
                Set<String> regionSet = new Set<String>(regions);

                System.assert(true, regionSet.containsAll(regionNames));
            }
        }

        regionList[0].Type__c = 'Installation';
        update regionList[0];
        
        regionList[0].Type__c = 'Sales';
        update regionList[0];
        
        if(regionList[0] != null) delete regionList[0];
        
        Test.stopTest();
    }

    static testMethod void testRegionConvertedToSalesTypeIsIncludedInListOnPart() {
        
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;

        insert vat20;
        
        List<Region__c> regionList = new List<Region__c>();
        List<CS_Part__c> partList = new List<CS_Part__c>();

        List<String> regionNames = new List<String>();
        regionNames.add('test region 0');

        partList.add(new CS_Part__c(Name = 'test part 0', Part_Code__c = '0', VAT_Code__c = vat20.Id));
        regionList.add(new Region__c(Name = 'test region 0', Code__c = '0', Type__c ='Installation'));
        regionList.add(new Region__c(Name = 'test region 1', Code__c = '1', Type__c ='Installation'));

        
        insert partList;
        insert regionList;
        
        List<Region__c> queriedRegions = [select Id, Name, Code__c from Region__c];
        
        
        Test.startTest();
        
        List<CS_Part__c> queriedParts = [select Id, Name, Included_In_Regions__c from CS_Part__c];
        
        for ( Integer i = 0; i < queriedParts.size(); i++) {
                System.assert(queriedParts[i].Included_In_Regions__c == ',,');
        }
        
        regionList[0].Type__c = 'Sales';
        regionList[1].Type__c = 'Sales';
        update regionList[0];

        queriedParts = [select Id, Name, Included_In_Regions__c from CS_Part__c];

        for ( Integer i = 0; i < queriedParts.size(); i++) {

                String[] regions = queriedParts[i].Included_In_Regions__c.split(',');
                
                Set<String> regionSet = new Set<String>(regions);

                System.assert(true, regionSet.containsAll(regionNames));
        }
        
        Test.stopTest();
    }
}