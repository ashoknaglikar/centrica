@isTest
private class CombiSwepCountTestClass {
    
    static testMethod void myUnitTest() 
    {
         CombiSwapQuestion__c c=new CombiSwapQuestion__c();
         CombiSwapCont csc =new CombiSwapCont();
         csc.getcombiSwap();
         csc.setcombiSwap(c);

       //csc.CombiSwapCont();
     }
 }