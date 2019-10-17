global class GetQuotaDataSchedule implements Schedulable{
  global void execute(SchedulableContext sc) {
       
        FetchQuotaDataReq.createOFSBatch();

    }

}