global class sendSurveyDataSchedular implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        
      SendSurveyDataBatch objDialler = new SendSurveyDataBatch();
      Database.executeBatch(objDialler,100);
        
     }
}