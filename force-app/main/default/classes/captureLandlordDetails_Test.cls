@isTest

private class captureLandlordDetails_Test{
    static list<Opportunity> chiLead = new list<Opportunity>();
    static Account acc;
    static Contact con;
    

    static void createData(){
    
         acc = TestClassHelper.createAccout();
         insert acc;
         con = TestClassHelper.createContact(acc);
         con.Contact_Type__c = 'Landlord';
         con.Primary_Contact__c = true;        
         insert con;
         chiLead.add(TestClassHelper.createCHILead(acc));
         chiLead[0].Bill_Title__c='';
         insert chiLead;
         System.debug('====debug===='+chiLead.size());
                    
    } 
    
    static testmethod void method1(){
        createData(); 
        Test.setCurrentPage(new Pagereference('/apex/captureLandlordDetails?edit='+1+'&accId='+acc.id+'&chiLeadId='+chiLead[0].id+'&source='+'IC'+'&billingAdd='+'No'));  
        captureLandlordDetails controller = new captureLandlordDetails();
        controller.invokeBillingAddressFunction(); 
        
        controller.opp.Bill_Title__c = '';        
        Test.setCurrentPage(new Pagereference('/apex/captureLandlordDetails?edit='+1+'&accId='+acc.id+'&chiLeadId='+chiLead[0].id+'&source='+'IC'+'&billingAdd='+'Yes')); 
        controller.invokeBillingAddressFunction();
        
        controller.LanlordContact.Live_Abroad__c = 'Yes';
        controller.invokeOverAddress();
        controller.LanlordContact.Live_Abroad__c = 'No';
        controller.invokeOverAddress();        
        
        controller.editBtn();
        controller.exitClick();
        
        controller.opp.Bill_Title__c = 'Company';        
        controller.removeFirstName(); 
         
        controller.opp.Bill_Title__c = 'First Name';        
        controller.removeFirstName();             
        
        controller.opp.Landlords_permission__c='No';
        controller.bookAppointmet(); 
         
        controller.opp.Landlords_permission__c='Yes';
        controller.bookAppointmet(); 
         
        Test.setCurrentPage(new Pagereference('/apex/captureLandlordDetails?edit='+1+'&accId='+acc.id+'&chiLeadId='+chiLead[0].id+'&source='+'SF'+'&billingAdd='+'Yes')); 
        controller.opp.Landlords_permission__c='Yes';
        controller.bookAppointmet(); 
         
        controller.LanlordContact.Email__C = null;
        controller.LanlordContact.MobilePhone = null; 
        controller.LanlordContact.HomePhone = null; 
        controller.LanlordContact.OtherPhone = null;
        controller.checkContact();
         
        controller.LanlordContact.Preferred_Contact_Method__c ='Email';
        controller.LanlordContact.MobilePhone = '8149862208';
        controller.checkContact();
        
        controller.opp.BillingAddress__c = 'No';
        controller.LanlordContact.Live_Abroad__c= 'No';
        controller.saveDetails();  
              
    }
    
    static testmethod void method2(){
        acc = TestClassHelper.createAccout();
        insert acc;
        con = TestClassHelper.createContact(acc);
        con.Primary_Contact__c = true;        
        insert con;
        chiLead.add(TestClassHelper.createCHILead(acc));
        chiLead[0].Bill_Title__c='';
        chiLead[0].BillingAddress__c = 'No';        
        insert chiLead;
        System.debug('====debug===='+chiLead.size());
        
        Test.setCurrentPage(new Pagereference('/apex/captureLandlordDetails?edit='+1+'&accId='+acc.id+'&chiLeadId='+chiLead[0].id+'&source='+'SF'+'&billingAdd='+'Yes'));  
        captureLandlordDetails controller = new captureLandlordDetails();
        controller.invokeBillingAddressFunction(); 
         
    }
    
    static testmethod void method3(){
        acc = TestClassHelper.createAccout();
        insert acc;
        con = TestClassHelper.createContact(acc);
        con.Primary_Contact__c = true;        
        con.Preferred_Contact_Method__c = 'Email' ;
        con.Email__C = 'priti@gmail.com';
        //con.Salutation__c = 'Ms';  
        insert con;
        chiLead.add(TestClassHelper.createCHILead(acc));
        chiLead[0].Bill_Title__c='';
        chiLead[0].BillingAddress__c = 'No'; 
        insert chiLead;
        System.debug('====debug===='+chiLead.size());
        
        Test.setCurrentPage(new Pagereference('/apex/captureLandlordDetails?edit='+1+'&accId='+acc.id+'&chiLeadId='+chiLead[0].id+'&source='+'IC'+'&billingAdd='+'Yes'));  
        captureLandlordDetails controller = new captureLandlordDetails();
        controller.invokeBillingAddressFunction(); 
        controller.bookAppointmet();  
        controller.checkContact(); 
               
        Test.setCurrentPage(new Pagereference('/apex/captureLandlordDetails?edit='+0+'&accId='+acc.id+'&chiLeadId='+chiLead[0].id+'&source='+'SF'+'&billingAdd='+'Yes')); 
        controller.bookAppointmet(); 
        Test.setCurrentPage(new Pagereference('/apex/captureLandlordDetails?edit='+0+'&accId='+acc.id+'&chiLeadId='+chiLead[0].id+'&source='+'IC'+'&billingAdd='+'Yes')); 
        controller.bookAppointmet();
        controller.exitClick(); 
        controller.checkContact();  
    }

}