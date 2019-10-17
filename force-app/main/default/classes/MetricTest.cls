@isTest(SeeAllData=false)
private class MetricTest {

  private static testMethod void testWorkProductBatch() {
    Test.startTest();
    Project_Overview__c testProject     = TestUtil.createProject('tpP3849');
    Iteration__c testIteration = TestUtil.createIteration(
      'ti7438', testProject.Id, 
      'Active', System.today(), System.today().addDays(14));
      
    List<Schema.PicklistEntry> defectStates = 
      Work_Product__c.Defect_State__c.getDescribe().getPicklistValues();
    
    List<Metric_Configuration__c> metrics = new List<Metric_Configuration__c>();
    List<Work_Product__c> work = new List<Work_Product__c>();
    String label;
    Integer count = 0;
    RecordType defectType = TestUtil.getRecordType('Defect', MetricBatch.WORK_PRODUCT);
    
    for(Schema.PicklistEntry defectState : defectStates) {
      label = defectState.getLabel();
      metrics.add(new Metric_Configuration__c(
        Name               = 'UTM' + count,
        sObject__c         = MetricBatch.WORK_PRODUCT, 
        Field_Name__c      = 'Defect_State__c', 
        Field_Type__c      = 'Picklist', 
        Metric_Category__c = 'Defect State', 
        Metric_Name__c     = label));
        
      work.add(new Work_Product__c(
        RecordTypeId    = defectType.Id,
        Resolution__c   = 'testang',
        Name            = 'tp-' + label, 
        Project_Overview__c      = testProject.Id, 
        Defect_State__c = label,
        Iteration__c    = Math.mod(count++, 2) == 0 ? testIteration.Id : null));
    }
    
    metrics.add(new Metric_Configuration__c(
      Name               = 'UTM' + metrics.size(),
      sObject__c         = MetricBatch.WORK_PRODUCT, 
      Field_Name__c      = 'Id', 
      Field_Type__c      = 'Id', 
      Metric_Category__c = 'Iteration',
      Metric_Name__c     = 'Total Defects'));

    insert metrics;
    insert work;
    
    Database.executeBatch(new MetricBatch(MetricBatch.WORK_PRODUCT));
    Test.stopTest();
    
    List<Daily_Project_Metric__c> results = 
      [SELECT Metric_Category__c, Metric_Name__c, Value__c, Iteration__c 
         FROM Daily_Project_Metric__c];
         
    count = 0;
    for(Daily_Project_Metric__c metric : results) {
      if(metric.Metric_Name__c == 'Total Defects') {
        System.assertEquals(defectStates.size(), metric.Value__c);
        count++;
      } else {
        System.assertEquals(1, metric.Value__c);
        count++;
      }
    }
    
    System.assertEquals(defectStates.size() + 1, count);
  }
  
  private static testMethod void testWorkProductBatchAggregateBy() {
    Test.startTest();
    Project_Overview__c testProject     = TestUtil.createProject('tpP3849');
    Iteration__c testIteration = TestUtil.createIteration(
      'ti7438', testProject.Id, 
      'Active', System.today(), System.today().addDays(14));
      
    List<Schema.PicklistEntry> defectStates = 
      Work_Product__c.Defect_State__c.getDescribe().getPicklistValues();
    
    List<Metric_Configuration__c> metrics = new List<Metric_Configuration__c>();
    List<Work_Product__c> work = new List<Work_Product__c>();
    String label;
    Integer count = 0;
    Integer nullIterations = 0;
    Integer filledIterations = 0;    
    RecordType defectType = TestUtil.getRecordType('Defect', MetricBatch.WORK_PRODUCT);
    Id iterationId;
    
    for(Schema.PicklistEntry defectState : defectStates) {
      label = defectState.getLabel();
      metrics.add(new Metric_Configuration__c(
        Name               = 'UTM' + count,
        sObject__c         = MetricBatch.WORK_PRODUCT, 
        Field_Name__c      = 'Defect_State__c', 
        Field_Type__c      = 'Picklist', 
        Metric_Category__c = 'Defect State',
        Metric_Name__c     = label));
      
      if(Math.mod(count++, 2) == 0) {
        iterationId = testIteration.Id;
        filledIterations++;
      } else {
        iterationId = null;
        nullIterations++;
      }
      
      work.add(new Work_Product__c(
        RecordTypeId    = defectType.Id,
        Resolution__c   = 'testang',
        Name            = 'tp-' + label, 
        Project_Overview__c      = testProject.Id, 
        Defect_State__c = label,
        Iteration__c    = iterationId));
    }
    
    metrics.add(new Metric_Configuration__c(
      Name               = 'UTM' + metrics.size(),
      sObject__c         = MetricBatch.WORK_PRODUCT, 
      Field_Name__c      = 'Id', 
      Field_Type__c      = 'Id', 
      Metric_Category__c = 'Iteration',
      Aggregate_By__c    = 'Iteration__c',
      Metric_Name__c     = 'Total Defects'));

    insert metrics;
    insert work;
    
    Database.executeBatch(new MetricBatch(MetricBatch.WORK_PRODUCT));
    Test.stopTest();
    
    List<Daily_Project_Metric__c> results = 
      [SELECT Metric_Category__c, Metric_Name__c, Value__c, Iteration__c 
         FROM Daily_Project_Metric__c];
    
    count = 0;
    for(Daily_Project_Metric__c metric : results) {
      if(metric.Metric_Name__c == 'Total Defects' && metric.Iteration__c == null) {
        System.assertEquals(nullIterations, metric.Value__c);
        count++;
      } else if(metric.Metric_Name__c == 'Total Defects' && metric.Iteration__c != null) {
        System.assertEquals(filledIterations, metric.Value__c);
        count++;        
      } else {
        System.assertEquals(1, metric.Value__c);
        count++;
      }
    }
    
    System.assertEquals(defectStates.size() + 2, count);
  }  

  private static testMethod void testReleaseBatch() {
    Test.startTest();
    Project_Overview__c testProject1    = TestUtil.createProject('tpP3849');
    SS_Release__c testRelease1 = TestUtil.createRelease('tr4859', testProject1.Id, 10, 7);
    SS_Release__c testRelease2 = TestUtil.createRelease('tr4860', testProject1.Id, 10, 7);
    SS_Release__c testRelease3 = TestUtil.createRelease('tr4861', testProject1.Id, 10, 7);
    SS_Release__c testRelease4 = TestUtil.createRelease('tr4862', testProject1.Id, 10, 7);
    SS_Release__c testRelease5 = TestUtil.createRelease('tr4863', testProject1.Id, 10, 7);
    insert new List<Metric_Configuration__c>{
      new Metric_Configuration__c(
        Name               = 'UTM1',
        sObject__c         = MetricBatch.RELEASE, 
        Field_Name__c      = 'To_Do__c', 
        Field_Type__c      = 'Number', 
        Metric_Category__c = 'Release',
        Aggregate_By__c    = 'Id',
        Metric_Name__c     = 'Loaded Points'),
      new Metric_Configuration__c(
        Name               = 'UTM2',
        sObject__c         = MetricBatch.RELEASE, 
        Field_Name__c      = 'Accepted__c', 
        Field_Type__c      = 'Number', 
        Metric_Category__c = 'Release',
        Aggregate_By__c    = 'Id',
        Metric_Name__c     = 'Accepted Points')};
    Database.executeBatch(new MetricBatch(MetricBatch.RELEASE));
    Test.stopTest();
    
    List<Daily_Project_Metric__c> results = 
      [SELECT Metric_Category__c, Metric_Name__c, Value__c, Iteration__c 
         FROM Daily_Project_Metric__c];
    
    System.assertEquals(10, results.size());
    
    Integer counter = 0;
    for(Daily_Project_Metric__c result : results) {
      if(result.Metric_Name__c == 'Loaded Points') {
        System.assertEquals(10, result.Value__c);
        counter++;
      } else {
        System.assertEquals(7, result.Value__c);
        counter++;
      }
    }
    
    System.assertEquals(10, counter);
  }
  
  private static testMethod void testIterationBatch() {
    Test.startTest();
    Date startDate = System.today();
    Date endDate   = System.today().addDays(14);
    
    Project_Overview__c testProject1     = TestUtil.createProject('tpP3849');
    Iteration__c testIteration1 = TestUtil.createIteration(
      'ti7438', testProject1.Id, 
      'Active', startDate, endDate, 120, 10, 15);
    Project_Overview__c testProject2     = TestUtil.createProject('tpP3850');
    Iteration__c testIteration2 = TestUtil.createIteration(
      'ti7439', testProject2.Id, 
      'Active', startDate, endDate, 80, 20, 25);
      
    insert new List<Metric_Configuration__c>{
      new Metric_Configuration__c(
        Name               = 'UTM1',
        sObject__c         = MetricBatch.ITERATION, 
        Field_Name__c      = 'Ideal_Burn__c', 
        Field_Type__c      = 'Number', 
        Metric_Category__c = 'Iteration',
        Aggregate_By__c    = 'Id',
        Metric_Name__c     = 'Ideal Burn'),
      new Metric_Configuration__c(
        Name               = 'UTM2',
        sObject__c         = MetricBatch.ITERATION, 
        Field_Name__c      = 'Accepted__c', 
        Field_Type__c      = 'Number', 
        Metric_Category__c = 'Iteration',
        Aggregate_By__c    = 'Id',
        Metric_Name__c     = 'Accepted Points'),
      new Metric_Configuration__c(
        Name               = 'UTM3',
        sObject__c         = MetricBatch.ITERATION, 
        Field_Name__c      = 'To_Do__c', 
        Field_Type__c      = 'Number', 
        Metric_Category__c = 'Iteration',
        Aggregate_By__c    = 'Id',
        Metric_Name__c     = 'Loaded Points')};
    
    Database.executeBatch(new MetricBatch(MetricBatch.ITERATION, ' WHERE Project_Overview__c <> null'));
    Test.stopTest();
    
    List<Daily_Project_Metric__c> results = 
      [SELECT Metric_Category__c, Metric_Name__c, Value__c, Iteration__c 
         FROM Daily_Project_Metric__c];
    
    System.assertEquals(6, results.size());
    Integer count = 0;
    for(Daily_Project_Metric__c result : results) {
      if(result.Iteration__c == testIteration1.Id) {
        if(result.Metric_Name__c == 'Loaded Points') {
          System.assertEquals(10, result.Value__c);
          count++;
        } else if(result.Metric_Name__c == 'Accepted Points') {
          System.assertEquals(15, result.Value__c);
          count++;          
        } else if(result.Metric_Name__c == 'Ideal Burn') {
          System.assertNotEquals(0, result.Value__c);
          System.assertNotEquals(null, result.Value__c);
          count++;          
        }
      } else if(result.Iteration__c == testIteration2.Id) {
        if(result.Metric_Name__c == 'Loaded Points') {
          System.assertEquals(20, result.Value__c);
          count++;
        } else if(result.Metric_Name__c == 'Accepted Points') {
          System.assertEquals(25, result.Value__c);
          count++;          
        } else if(result.Metric_Name__c == 'Ideal Burn') {
          System.assertNotEquals(0, result.Value__c);
          System.assertNotEquals(null, result.Value__c);
          count++;          
        }        
      }
    }
    
    System.assertEquals(6, count);
  }

}