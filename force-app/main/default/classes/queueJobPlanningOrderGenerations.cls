public class queueJobPlanningOrderGenerations implements Queueable {
    
    private Job__c job;
    private string optionIDSelected;
    private id chiLead;
    private list<Diary_Entry__c> travelDiaryEntries;
    
    public queueJobPlanningOrderGenerations(id chiLead, string optionIDSelected, job__c job , list<Diary_Entry__c> travelDiaryEntries) {
      
        this.optionIDSelected = optionIDSelected;
        this.job              = job;
        this.chiLead          = chiLead;
        this.travelDiaryEntries = travelDiaryEntries;
    }

    public void execute(QueueableContext context) 
    {

       try{
    
       // this creates Diary Entries    
       JobBookingManager.planOrReplanJob(optionIDSelected);
       //This generates order
       AutoGeneratePurchaseOrders autoGen = new AutoGeneratePurchaseOrders();
       autoGen.autoGenerateOrders(job);
       
       //Job sharing 
       JobSharingCls.createJobSharing(new list<string> {job.Id});
       
       //create planing historyies
       createJobPlanningHistory(job);
       
       if(travelDiaryEntries.size()>0)
       insert travelDiaryEntries;
       
       
       }
       catch (exception e)
       {
           CreateEmail.CretaeSendTextEmail(new list<string>{'ashokkumar.nagaleekar@centrica.com'},'CHI lead: ' + chiLead +'\n Job Entries:' +JSON.serialize(job) +'\n Exception message :'+e.getMessage()+ ' at linenumber :'+e.getLineNumber(), 'Error in Job Booking Future Method' );
            
       }

}

public static void createJobPlanningHistory(Job__c job)
{
    Job_Planning_History__c JPH= new Job_Planning_History__c();
    JPH.Planned_By__c=UserInfo.getUserId();
    JPH.Job__c=job.id;
    JPH.Original_Installation_Date__c=null;
    JPH.New_Installation_Date__c=job.Installation_Date__c;
    JPH.Type__c='First Plan';
    JPH.RecordTypeId =System.label.Replan_First;
    insert JPH;
    
}
    
}