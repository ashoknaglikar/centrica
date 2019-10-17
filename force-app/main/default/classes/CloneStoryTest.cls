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
private class CloneStoryTest {

    private static Work_Product__c createData(){
        RecordType rt = [SELECT ID from RecordType where Name='User Story'];
        RecordType projectRt = [SELECT ID from RecordType where Name='Agile Project'];
        
        //Create data
        Project_Overview__c project = new Project_Overview__c();
        project.Name ='Project';
        project.recordTypeId = projectRt.id;
        insert project;
        
        Iteration__c iteration = new Iteration__c();
        iteration.Name = 'Interation';
        iteration.State__c = 'Active';
        iteration.Project_Overview__c = project.id;
        iteration.Start_Date__c = Date.newInstance(2013, 06, 01);
        iteration.Start_Date__c = Date.newInstance(2013, 06, 11);
        
        insert iteration;
        
        Work_Product__c wp = new Work_Product__c();
        wp.Name = 'Test Work Product';
        wp.Description__c = 'This is a description for a user story';
        wp.Acceptance_Critiera__c = 'Acceptance Criteria';
       // wp.Split_Reason__c = 'This is the split reason';
        wp.Iteration__c = iteration.Id;
        wp.Project_Overview__c = project.Id;
        wp.RecordTypeId = rt.Id;
        
        insert wp;
        
        return wp;
        
        
    }
    
    static testMethod void cancelTest(){
        Work_Product__c wp = createData();
                
        PageReference pageRef = Page.CloneStory;
       
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id', wp.Id);
        CloneStory cloneStory = new CloneStory();
        cloneStory.cancel();
        
    }
    static testMethod void saveTest() {
        
       Work_Product__c wp = createData();
        
        List<Work_Product_Task__c> tasks = new List<Work_Product_Task__c>();
        for(Integer i=0; i<=20; i++ ){
            Work_Product_Task__c task = new Work_Product_Task__c();
            task.Name = 'task ' + String.valueOf(i);
            task.Work_Product__c = wp.Id;
            task.Estimate__c = 5;
            task.To_Do__c = 5;
            task.State__c ='Defined';
            tasks.add(task);
        }       
        
        //Create a completed task
        Work_Product_Task__c task = new Work_Product_Task__c();
        task.Name = 'completed task';
        task.Work_Product__c = wp.Id;
        task.State__c ='Completed';
        tasks.add(task);
        
        insert tasks;
        
        PageReference pageRef = Page.CloneStory;
       
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id', wp.Id);
        CloneStory cloneStory = new CloneStory();
        cloneStory.taskList[0].checked = true;

        
        //US242
        for(CloneStory.CheckedTask checkedTask :cloneStory.taskList){
            system.assertNotEquals(checkedTask.task.State__c,'Completed');
        }  
        
        cloneStory.save();
        system.debug('WPID: ' + wp.Id);
        /*
        Work_Product__c splitWP = [SELECT Id, Name, Continued_From__c 
            from Work_Product__c where Continued_From__c =: wp.Id];
        
        //US
        system.assertEquals(splitWP.Continued_From__c, wp.Id);
        */
    }
}