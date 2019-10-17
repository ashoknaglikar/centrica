@isTest
private class CS_AllMaterialTriggerTest {

    static testMethod void testMaterialCostUpdate(){    
        
        Test.startTest();
        
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;
        insert vat20;
        
        List<CS_Material__c> materialList = new List<CS_Material__c>();
        List<CS_Part__c> partList = new List<CS_Part__c>();
        
        for (Integer i=0; i< 100; i++){
            materialList.add(new CS_Material__c(Name = 'Test material 005', Cost_Per_Unit__c = 10));
            partList.add(new CS_Part__c(Name = 'Test part 006', Part_Code__c = string.valueOf(i), VAT_Code__c = vat20.Id));
        }
        
        insert materialList;
        insert partlist;
                
        List<CS_Material__c> queriedMaterialList = [select Id, Name, Cost_Per_Unit__c from CS_Material__c where Id in :materialList];
        List<CS_Part__c> queriedPartList = [select Id, Name from CS_Part__c where Id in :partlist];
        
        List<CS_Part_Material__c> partMaterials = new List<CS_Part_Material__c>();
        
        for(Integer i=0; i<queriedMaterialList.size(); i++){
            Id materialId = queriedMaterialList[i].Id;
            Id partId = queriedPartList[i].Id;
            partMaterials.add(new CS_Part_Material__c(Material__c = materialId, Part__c = partId, Quantity__c = 1));
        }
        
        insert partMaterials;
        
        for (Integer i=0; i< queriedMaterialList.size(); i++){
            queriedMaterialList[i].Cost_Per_Unit__c += 1;
        }
        
        update queriedMaterialList;
        
        List<CS_Part__c> queriedUpdatedPartList = [select Id, Name, Total_M_Cost__c from CS_Part__c where Name = 'Test part 006'];
        for (Integer i=0; i< queriedUpdatedPartList.size(); i++){
            System.debug(queriedUpdatedPartList[i].Total_M_Cost__c);
            System.assertEquals(queriedUpdatedPartList[i].Total_M_Cost__c, 11);                     
        }
        
        Test.stopTest();
    }
    
    static testMethod void testUpdatePartTotalMCostAfterPMDeletion(){   
    
        Test.startTest();
        
        // create and inset a VAT code
        CS_VAT_Code__c vat20 = new CS_VAT_Code__c();
        vat20.Percentage__c = 20;
        insert vat20;
        
        // create and insert materials and parts
        List<CS_Material__c> materialList = new List<CS_Material__c>();
        List<CS_Part__c> partList = new List<CS_Part__c>();
        
        partList.add(new CS_Part__c(Name = 'Test part 006', Part_Code__c = string.valueOf(6483), VAT_Code__c = vat20.Id));
    
        for (Integer j=0; j< 10; j++){
            materialList.add(new CS_Material__c(Name = 'Test material 005', Cost_Per_Unit__c = 10));
        }
        
        insert materialList;
        insert partlist;
        
        List<CS_Material__c> queriedMaterialList = [select Id, Name, Cost_Per_Unit__c from CS_Material__c where Id in :materialList];
        List<CS_Part__c> queriedPartList = [select Id, Name from CS_Part__c where Id in :partlist];
        
        // associate part with materials
        List<CS_Part_Material__c> partMaterials = new List<CS_Part_Material__c>();
        
        for(Integer i=0; i<queriedMaterialList.size(); i++){
            Id materialId = queriedMaterialList[i].Id;
            Id partId = queriedPartList[0].Id;
            partMaterials.add(new CS_Part_Material__c(Material__c = materialId, Part__c = partId, Quantity__c = 1));
        }
        
        insert partMaterials;
        
        // delete half (5) of the materials
        List<CS_Part_Material__c> partMaterialsForDelete = [SELECT Id FROM CS_Part_Material__c WHERE Part__c = :queriedPartList[0].Id LIMIT 5];
        delete partMaterialsForDelete;
        
        //assert that part total material cost has halved
        
        List<CS_Part__c> queriedPartListAfterDeletion = [select Id, Name, Total_M_Cost__c from CS_Part__c where Id in :partList];
        CS_Part__c queriedPart = queriedPartListAfterDeletion[0];
        
        System.assertEquals(queriedPart.Total_M_Cost__c, 50);                     

        Test.stopTest();
    }
}