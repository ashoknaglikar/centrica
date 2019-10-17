public without sharing class MetricBatch implements Database.Batchable<sObject>, Database.Stateful {

  private String query;
  private String objectType;
  private Map<String, Double> metrics;
  private List<Metric_Configuration__c> configurations;
  
  private static final String DELIM         = '}->';
  private static final String TYPE_PICKLIST = 'picklist';
  private static final String TYPE_ID       = 'id';
  private static final String TYPE_NUMBER   = 'number';
  private static final String STR_NULL      = 'null';
  public  static final String WORK_PRODUCT  = 'Work_Product__c';
  public  static final String RELEASE       = 'SS_Release__c';
  public  static final String ITERATION     = 'Iteration__c';
  
  public MetricBatch() {
    init(WORK_PRODUCT, '');
  }  
  
  public MetricBatch(String runType) {
    init(runType, '');
  }
  
  public MetricBatch(String runType, String queryTail) {
    init(runType, queryTail);
  }    

  public Database.QueryLocator start(Database.BatchableContext context) {
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext context, List<sObject> scope) {
    if(objectType == ITERATION) {
      List<sObject> toUpdate = new List<sObject>();
      
      for(sObject todo : scope) {
        saveInitialTaskEstimates(todo, toUpdate);
      }
      
      update toUpdate;
      String iterationQuery = query;
      if(iterationQuery.toLowerCase().contains(' where ')) {
        iterationQuery += ' AND Id in :scope';
      } else {
        iterationQuery += ' WHERE Id in :scope';
      }
      
      scope = Database.query(iterationQuery);      
    }
    
    for(sObject todo : scope) {
      for(Metric_Configuration__c config : configurations) {
        incrementMetric(todo, config);
      }
    }
  }
  
  private void saveInitialTaskEstimates(sObject todo, List<sObject> toUpdate) {
    if(Date.valueOf(todo.get('Start_Date__c')) == System.today()) {
      todo.put('Day_One_Estimate__c', Double.valueOf(todo.get('Task_Estimate__c')));
      toUpdate.add(todo);
    }
  }

  public void finish(Database.BatchableContext BC) {
    List<Daily_Project_Metric__c> reportables = new List<Daily_Project_Metric__c>();

    for(String key : metrics.keySet()) {
      reportables.add(calculateMetric(key, metrics.get(key)));
    }
    
    try {
      insert reportables;
    } catch(Exception ex) {
      System.assertEquals(ex.getMessage(), ex.getStackTraceString());
    }
    nextBatch();
  }

  private Daily_Project_Metric__c calculateMetric(String key, Double value) {
    List<String> keySplit   = key.split(DELIM);
    String metricCategory   = keySplit.get(1);
    String metricName       = keySplit.get(2);
    String aggregateBy      = keySplit.get(5);
    String aggregateByValue = keySplit.size() == 7 ? keySplit.get(6) : null;
    
    Daily_Project_Metric__c toCalculate = new Daily_Project_Metric__c(
      Date__c            = System.today(),
      Metric_Category__c = metricCategory,
      Metric_Name__c     = metricName,
      Value__c           = value      
    );
    
    if(String.isNotEmpty(aggregateBy)       && 
       aggregateBy != STR_NULL              && 
       aggregateBy.toLowerCase() != TYPE_ID &&
       String.isNotEmpty(aggregateByValue)  && 
       aggregateByValue != STR_NULL) {
         
      toCalculate.put(aggregateBy, aggregateByValue);
    } else if(aggregateBy == TYPE_ID) {
      if(objectType == ITERATION) {
        toCalculate.put('Iteration__c', aggregateByValue);
      } else if(objectType == RELEASE) {
        toCalculate.put('SS_Release__c', aggregateByValue);
      }
    }
    
    return toCalculate;
  }
  
  private void incrementMetric(sObject todo, Metric_Configuration__c config) {
    String type        = config.Field_Type__c.toLowerCase();
    String key         = generateKey(todo, config, type);
    Double incrementBy = 0;
    
    if(!metrics.containsKey(key)) {
      metrics.put(key, 0);
    }
    
    Double metric = metrics.get(key);
    if(type == TYPE_ID || (type == TYPE_PICKLIST && todo.get(config.Field_Name__c) == config.Metric_Name__c)) {
      incrementBy = 1;
    } else if(type == TYPE_NUMBER) {
      incrementBy = Double.valueOf(todo.get(config.Field_Name__c));
      if(incrementBy == null) {
        incrementBy = 0;
      }      
    }
    
    metrics.put(key, metric + incrementBy);
  }
  
  private String generateKey(sObject todo, Metric_Configuration__c config, String type) {
    return type
           + DELIM 
           + config.Metric_Category__c
           + DELIM
           + config.Metric_Name__c
           + DELIM
           + objectType
           + DELIM
           + config.Field_Name__c
           + DELIM
           + config.Aggregate_By__c
           + DELIM
           + (String.isEmpty(config.Aggregate_By__c) ? '' : todo.get(config.Aggregate_By__c));
  }
  
  private String getSelectClause() {
    Set<String> selectClause = new Set<String>{'Id'};
    
    if(objectType == ITERATION) {
      selectClause.add('Task_Estimate__c');
      selectClause.add('Start_Date__c');
    }
    
    for(Metric_Configuration__c config : configurations) {
      if(String.isNotEmpty(config.Aggregate_By__c)) {
        selectClause.add(config.Aggregate_By__c);
      }
      
      if(String.isNotEmpty(config.Field_Name__c)) {
        selectClause.add(config.Field_Name__c);
      }     
    }
    
    return String.join(new List<String>(selectClause), ', ');
  }
  
  private void nextBatch() {
    if(!Test.isRunningTest()) {
      if(objectType == WORK_PRODUCT) {
        Database.executeBatch(new MetricBatch(RELEASE));
      } else if(objectType == RELEASE) {
        Database.executeBatch(new MetricBatch(ITERATION, ' WHERE Current_Iteration__c = true'));
      }
    }    
  }
  
  private void init(String runType, String queryTail) {
    metrics        = new Map<String, Double>();
    objectType     = runType;
    configurations =
      [SELECT Aggregate_By__c, 
              Field_Name__c, 
              Field_Type__c, 
              Metric_Category__c, 
              Metric_Name__c
         FROM Metric_Configuration__c
        WHERE sObject__c = :objectType]; 
        
    query = 'SELECT ' + getSelectClause() + ' FROM ' + objectType + queryTail;    
  }

}