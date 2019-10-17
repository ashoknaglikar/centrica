@isTest
public class ProductDefinitionTemplateAttTriggerTest {
   
    static testMethod void testAttachmentNameChangeProductDefinition(){
        
        final String CS_compiledFileNameCSA = 'DefaultScreenFlow-csac__RenderOfflineAppUI';
        final String CS_compiledFileNameOrg = 'DefaultScreenFlow-RenderOfflineAppUICustom';
   
        Test.startTest();
        
        //create a Product definition        
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name = 'Heating Hot Water Solution Test';
        prodDef.cscfga__Description__c = 'Heating Hot Water Solution Test Description';
        insert prodDef;
        
        // Create compiledCSAAttachment attachment against Product Definition
        Attachment compiledCSAAttachment = new Attachment();
        compiledCSAAttachment.ParentID = prodDef.Id;
        compiledCSAAttachment.Body = Blob.valueOf('compiling for csa');
        compiledCSAAttachment.Name = CS_compiledFileNameOrg; 
        
        // Add two more attachments to Product Definition that should be deleted by the trigger               
        Attachment attachToDelete1 = new Attachment();
        attachToDelete1.ParentID = prodDef.Id;
        attachToDelete1.Body = Blob.valueOf('test1');
        attachToDelete1.Name = CS_compiledFileNameOrg; 
        
        Attachment attachToDelete2 = new Attachment();
        attachToDelete2.ParentID = prodDef.Id;
        attachToDelete2.Body = Blob.valueOf('test2');
        attachToDelete2.Name = CS_compiledFileNameOrg; 

        
        List<Attachment> attachments = new List<Attachment>();
        attachments.add(compiledCSAAttachment);
        attachments.add(attachToDelete1);
        attachments.add(attachToDelete2);
        
        insert attachments;
        Test.stopTest();
        
        List<Attachment> attListCSA = [SELECT   Id, ParentId 
                                       FROM     Attachment 
                                       WHERE    Parent.Type = 'cscfga__Product_Definition__c' 
                                            AND Name = :CS_compiledFileNameCSA];
        System.assertEquals(1, attListCSA.size());
        
        List<Attachment> attList = [SELECT      Id, ParentId 
                                    FROM        Attachment 
                                    WHERE       Parent.Type = 'cscfga__Product_Definition__c' 
                                            AND Parent.Id =: prodDef.Id 
                                            AND Name = :CS_compiledFileNameOrg];
                                            
        System.assertEquals(0, attList.size());
        
        
    }
    
  
}