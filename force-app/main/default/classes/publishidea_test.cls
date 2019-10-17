@isTest

private class publishidea_test 
{

     static testmethod void testMethod1()
        {
                
                User user = TestClassHelper.createUser();
                insert user;
                    
                Idea ida = TestClassHelper.createidea(user.id);
                insert ida;
             
               publishidea pbklshidea = new publishidea(new ApexPages.StandardController(ida));
               pbklshidea.editidea() ;
               pbklshidea.saveidea() ;
               pbklshidea.cancelidea();
               
                
        } 
       
 }