public class TestUtil {  
  public static Project_Overview__c createProject(String name) {
    RecordType rt = [SELECT ID from RecordType where Name='Agile Project'];  
    
    Project_Overview__c testProject = new Project_Overview__c(Name = name, recordTypeId = rt.id);
    
    insert testProject;
    return testProject;
  }
  
  public static Work_Product__c createWorkProduct(String name, Id projectId) {
    Work_Product__c testWorkProduct = 
      new Work_Product__c(Name = name, Project_Overview__c = projectId);
      
    insert testWorkProduct;
    return testWorkProduct;
  }
  
  public static Iteration__c createIteration(
    String name, Id projectId, String state, Date startDate, Date endDate) {
    
    Iteration__c testIteration = new Iteration__c(
      Name          = name, 
      Project_Overview__c    = projectId, 
      State__c      = state, 
      Start_Date__c = startDate, 
      End_Date__c   = endDate);
    
    insert testIteration;
    return testIteration;
  }
  
  public static Iteration__c createIteration(
    String name, Id projectId, String state, Date startDate, Date endDate, Double taskEstimate, Double loaded, Double accepted) {
    
    Iteration__c testIteration = new Iteration__c(
      Name             = name, 
      Project_Overview__c       = projectId, 
      State__c         = state, 
      Start_Date__c    = startDate, 
      End_Date__c      = endDate,
      Task_Estimate__c = taskEstimate,
      Accepted__c      = accepted,
      To_Do__c         = loaded);
    
    insert testIteration;
    return testIteration;
  }  
  
  public static SS_Release__c createRelease(String name, Id projectId, Integer toDo, Integer accepted) {
    SS_Release__c testRelease = new SS_Release__c(
      Name = name, Project_Overview__c = projectId, To_Do__c = toDo, Accepted__c = accepted);
    insert testRelease;
    return testRelease;
  }
  
  public static RecordType getRecordType(String name, String type) {
    return [SELECT Id FROM RecordType WHERE Name = :name AND SobjectType = :type];
  }
}