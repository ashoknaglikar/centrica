@isTest
private class TestEmployeeDeleteTrigger {
    
    static testMethod void testEmpDeleteTrigger () {
        
        Profile p = [select id from profile where name = 'Dummy Profile'];
        
        Integer empCount = 0;

        User dummyUser = new User(LastName = 'Sitel', Alias = 'admsit', 
                                  Email = 'sitel@admin.com', Username='sitel@admin.com',
                                  ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                  Migration_ID__c = 'sitel@admin.com',
                                  TimeZoneSidKey = 'Europe/London', 
                                  LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
                            
       Employee__c emp = new Employee__c(Name = 'test',First_Name__c = 'emp', Last_Name__c='delete', Employee_Number__c = '200000a');
   
       Database.insert(emp);
       
       System.runAs(dummyUser){
        
            try{
                
                Database.delete(emp);
                
            }catch(Exception excp){
                
                System.debug('Delete should fail.');
                
            }
        
            empCount = [Select COUNT() from Employee__c where Id =:emp.Id];
            
            System.assertEquals(empCount, 1);
        
       }
                                                                                     
      Database.delete(emp);
        
      empCount = [Select COUNT() from Employee__c where Id =:emp.Id];
            
      System.assertEquals(empCount, 0);                             
        
    }

}