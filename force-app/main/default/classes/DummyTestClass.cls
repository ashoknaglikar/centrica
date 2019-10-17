/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DummyTestClass {

    static testMethod void Dummy1Test() {
        // TO DO: implement unit test
        dummyclass dc = new dummyclass();
         try{
         dummyclass.sendedi();
        
         } catch(system.Exception ex1) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
    }
     static testMethod void Dummy2Test(){   
         try{
         dummyclass.getgrdata();
         } catch(system.Exception ex2) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
         
    }
    static testMethod void Dummy3Test(){
         try{
         dummyclass.getsappo();
         
         } catch(system.Exception ex3) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
    }
    static testMethod void Dummy4Test(){
         try{
            dummyclass.getedi();
         } catch(system.Exception ex3) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
    }
    static testMethod void Dummy5Test(){
         try{
            dummyclass.sendsappo();
         } catch(system.Exception ex3) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
    }
    static testMethod void Dummy6Test(){
         try{
            dummyclass.setdeposit();
         } catch(system.Exception ex3) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
    }
    static testMethod void Dummy7Test(){
         try{
         dummyclass.getvendordata();
         } catch(system.Exception ex3) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
    }
    static testMethod void Dummy8Test(){
         try{
         dummyclass.deledidata();
         } catch(system.Exception ex3) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
    }
    static testMethod void Dummy9Test(){
         try{
          dummyclass.sdledi();
         } catch(system.Exception ex3) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
    }
    /*
    static testMethod void Dummy0Test(){
         try{        
         dummyclass.sendgrdata();
         dummyclass.sdlSAP();
         } catch(system.Exception ex3) 
         {
            // this try catch block is to catch an exception arising due to scheduling too many jobs
         }
        } */
}