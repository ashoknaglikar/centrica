@isTest
public class DeleteProductConfigurationsTest{
    public static testmethod void testDeleteBatch(){
        
        setup();
        
        Test.startTest();
        
        List<cscfga__Product_Configuration__c> pcs = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name LIKE 'TEST-%'];
        System.assertEquals(2, pcs.size());
        List<cscfga__Product_Basket__c> pbs = [SELECT Id FROM cscfga__Product_Basket__c WHERE Name LIKE 'TEST-%'];
        System.assertEquals(2, pbs.size());
        List<cscfga__Attribute__c> atts = [SELECT Id FROM cscfga__Attribute__c WHERE Name LIKE 'TEST-%'];
        System.assertEquals(4, atts.size());
        
        String query = 'SELECT Id, cscfga__Product_Basket__r.CS_Quote_Status__c, CreatedDate FROM cscfga__Product_Configuration__c WHERE (Name LIKE \'TEST-%\') AND (cscfga__Product_Basket__r.CS_Quote_Status__c = \'Quote Finalised - Not Accepted\' AND CreatedDate <= :endDate AND CreatedDate >= :startDate) LIMIT 200';
        DeleteProductConfigurations dpc = new DeleteProductConfigurations(query);
        Database.executeBatch(dpc);
        Test.stopTest();
        
        List<cscfga__Product_Configuration__c> pcs1 = [SELECT Id, Name FROM cscfga__Product_Configuration__c WHERE Name LIKE 'TEST-%'];
        //System.assertEquals(1, pcs1.size());
        //System.assertEquals('TEST-ProdConfQFA', pcs1[0].Name);
        
        List<cscfga__Attribute__c> atts1 = [SELECT Id, cscfga__Product_Configuration__c FROM cscfga__Attribute__c WHERE Name LIKE 'TEST-%'];
        //System.assertEquals(2, atts1.size());
        /*for(cscfga__Attribute__c att : atts1){
            System.assertEquals(pcs1[0].Id, att.cscfga__Product_Configuration__c);
        }*/
        
        List<cscfga__Product_Basket__c> pbs1 = [SELECT Id FROM cscfga__Product_Basket__c WHERE Name LIKE 'TEST-%'];
        //System.assertEquals(2, pbs1.size());

    }
    
    public static void setup(){
    
        Delete_Product_Configurations_Setting__c startDate = new Delete_Product_Configurations_Setting__c();
        startDate.Name = 'Start Date';
        startDate.Value__c = '2015-01-01';
        insert startDate;
        
        Delete_Product_Configurations_Setting__c endDate = new Delete_Product_Configurations_Setting__c();
        endDate.Name = 'End Date';
        endDate.Value__c = '2015-12-31';
        insert endDate;
        
        
        Delete_Product_Configurations_Setting__c data = new Delete_Product_Configurations_Setting__c();
        data.Name = 'Data';
        data.Value__c = 'Al1';
        insert data;
        
        Delete_Product_Configurations_Setting__c emailTo = new Delete_Product_Configurations_Setting__c();
        emailTo.Name = 'Email Recipient';
        emailTo.Value__c = 'tomislav.brisevac@cloudsense.com';
        insert emailTo;
        
        List<cscfga__Product_Basket__c> pbs = new List<cscfga__Product_Basket__c>();
        List<cscfga__Product_Configuration__c> pcs = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> atts = new List<cscfga__Attribute__c>();
        
        cscfga__Product_Basket__c pb1 = new cscfga__Product_Basket__c(Name='TEST-ProdBasketQFNA', CS_Quote_Status__c = 'Quote Finalised - Not Accepted');
        pbs.add(pb1);
        cscfga__Product_Basket__c pb2 = new cscfga__Product_Basket__c(Name='TEST-ProdBasketQFA', CS_Quote_Status__c = 'Quote Finalised - Accepted');
        pbs.add(pb2);

        
        insert pbs;
        
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Name='TEST-ProdConfQFNA', cscfga__Product_Basket__c = pb1.Id);
        pcs.add(pc1);
        cscfga__Product_Configuration__c pc2 = new cscfga__Product_Configuration__c(Name='TEST-ProdConfQFA', cscfga__Product_Basket__c = pb2.Id);
        pcs.add(pc2);
        
        insert pcs;
        
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(Name='TEST-AttQFNA1', cscfga__Product_Configuration__c = pc1.Id);
        atts.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(Name='TEST-AttQFNA2', cscfga__Product_Configuration__c = pc1.Id);
        atts.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(Name='TEST-AttQFA1', cscfga__Product_Configuration__c = pc2.Id);
        atts.add(att3);
        cscfga__Attribute__c att4 = new cscfga__Attribute__c(Name='TEST-AttQFA2', cscfga__Product_Configuration__c = pc2.Id);
        atts.add(att4);
        
        insert atts;
    }
    
    public static testmethod void testDeleteBatchHigh(){
    
        Delete_Product_Configurations_Setting__c startDate = new Delete_Product_Configurations_Setting__c();
        startDate.Name = 'Start Date';
        startDate.Value__c = '2015-01-01';
        insert startDate;
        
        Delete_Product_Configurations_Setting__c endDate = new Delete_Product_Configurations_Setting__c();
        endDate.Name = 'End Date';
        endDate.Value__c = '2015-12-31';
        insert endDate;
        
        Delete_Product_Configurations_Setting__c data = new Delete_Product_Configurations_Setting__c();
        data.Name = 'Data';
        data.Value__c = 'Al1';
        insert data;
        
        List<cscfga__Product_Configuration__c> pcsA = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> attsA = new List<cscfga__Attribute__c>();
        List<cscfga__Attribute_Field__c> attFields = new List<cscfga__Attribute_Field__c>();
        
        cscfga__Product_Basket__c pb = new cscfga__Product_Basket__c(Name='TEST-ProdBasket', CS_Quote_Status__c = 'Quote Finalised - Not Accepted');
        insert pb;
        
        for(Integer i=0; i<200; i++){
            cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(Name='TEST-ProdConfQFNA' + i, cscfga__Product_Basket__c = pb.Id);
            pcsA.add(pc);
        }
        insert pcsA;
        
        for(Integer i=0; i<200; i++){
            for(Integer j=0; j<20; j++){
                cscfga__Attribute__c att = new cscfga__Attribute__c(Name='TEST-AttQFNA' + j, cscfga__Product_Configuration__c = pcsA[i].Id);
                attsA.add(att);
            }
        }
        insert attsA;
        
        for(Integer i=0; i<4000; i++){
                cscfga__Attribute_Field__c att = new cscfga__Attribute_Field__c(Name='TEST-AttField' + i, cscfga__Attribute__c = attsA[i].Id);
                attFields.add(att);
        }
        insert attFields;
        
        Test.startTest();
        
        List<cscfga__Product_Configuration__c> pcs = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name LIKE 'TEST-%'];
        System.assertEquals(200, pcs.size());
        List<cscfga__Product_Basket__c> pbs = [SELECT Id FROM cscfga__Product_Basket__c WHERE Name LIKE 'TEST-%'];
        System.assertEquals(1, pbs.size());
        List<cscfga__Attribute__c> atts = [SELECT Id FROM cscfga__Attribute__c WHERE Name LIKE 'TEST-%'];
        System.assertEquals(4000, atts.size());
        List<cscfga__Attribute_Field__c> attFs = [SELECT Id FROM cscfga__Attribute_Field__c WHERE Name LIKE 'TEST-%'];
        System.assertEquals(4000, attFs.size());
        
        String query = 'SELECT Id, cscfga__Product_Basket__r.CS_Quote_Status__c, CreatedDate FROM cscfga__Product_Configuration__c WHERE (Name LIKE \'TEST-%\') AND (cscfga__Product_Basket__r.CS_Quote_Status__c = \'Quote Finalised - Not Accepted\' AND CreatedDate <= :endDate AND CreatedDate >= :startDate)';
        DeleteProductConfigurations dpc = new DeleteProductConfigurations(query);
        Database.executeBatch(dpc);
        Test.stopTest();
        
        List<cscfga__Product_Configuration__c> pcs1 = [SELECT Id, Name FROM cscfga__Product_Configuration__c WHERE Name LIKE 'TEST-%'];
        //System.assertEquals(0, pcs1.size());
        
        List<cscfga__Attribute__c> atts1 = [SELECT Id, cscfga__Product_Configuration__c FROM cscfga__Attribute__c WHERE Name LIKE 'TEST-%'];
        //System.assertEquals(0, atts1.size());
        
        List<cscfga__Attribute_Field__c> attFa = [SELECT Id FROM cscfga__Attribute_Field__c WHERE Name LIKE 'TEST-%'];
        //System.assertEquals(0, attFa.size());
        
        List<cscfga__Product_Basket__c> pbs1 = [SELECT Id FROM cscfga__Product_Basket__c WHERE Name LIKE 'TEST-%'];
       // System.assertEquals(1, pbs1.size());

    }

}