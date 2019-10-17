public class Cont_UnavailabilityEntriesPage {
Work_Cycle__c wc;
//PRB00013737 - Unable to Create Group Work Cycles -- added this (employeeids) object
public set<Id> employeeids = new set<Id>();
public  List<Entries_To_Plan__c> UnAvailEntries = new List<Entries_To_Plan__c>();
public List<Id> UnAvailIds = new List<Id> ();
public Boolean IsData {get; set;}

public static String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');

public Cont_UnavailabilityEntriesPage()
{
// code fix starts - for Unable to create group work cycles - PRB00013737
    wc =[Select Employee__c, Group__c, Shift_Pattern__r.Pool_Shift_Pattern__c, Start_Date__c, Number_of_Weeks__c   from Work_Cycle__c where id=:ApexPages.currentPage().getParameters().get('s')];
    
    if(wc.Group__c != null)
    {
        for (Employee_Group__c e : [select Employee__c,Employee__r.Pool_Diary__c  from Employee_Group__c where Group__c = :wc.Group__c])
        {
            employeeids.add(e.Employee__c);
        }
    }
    else
    {
        employeeids.add(wc.Employee__c);
    }
   // code fix ends - for Unable to create group work cycles - PRB00013737
    Integer numOfWeeks = (wc.Number_of_Weeks__c).intValue();
    Datetime workCycleEndDate = wc.Start_Date__c.addDays((numOfWeeks * 7));
  // code fix starts - for Unable to create group work cycles - PRB00013737
   UnAvailEntries = [Select e.Name,e.Start__c, e.End__c, e.Employee_Name__c,e.Sub_Type__c,e.Diary_ID__c,e.Unavailability__c,e.Unavailability_ID__c From Entries_To_Plan__c e
                               where e.Record_Type__c ='Unavailability' and e.Employee__c IN :employeeids
                               and Start__c >= :wc.Start_Date__c and  End__c < :workCycleEndDate order by Start__c];
// code fix ends - for Unable to create group work cycles - PRB00013737 

    if(UnAvailEntries.size() == 0)
    {
        IsData = false;
    }
    else
    {
        IsData = true;
    }

}


public List<Entries_To_Plan__c> getEntries() {
  
        for(Entries_To_Plan__c entries : UnAvailEntries)
        { 
            UnAvailIds.add(entries.Diary_ID__c);            
        }
                               
        return UnAvailEntries;

}


public void  RemoveUnavilabilities()
{
    
  Diary_Entry__c[] unavDiary = [select Id, RecordTypeId ,d.Type__c, d.Start__c, 
                                 d.End__c, d.Employee_ID_18__c, d.Employee_Salesforce1_ID__c from Diary_Entry__c d
                                where Id in : UnAvailIds];
    List<Unavailability__c> UpadatingEntries = new List<Unavailability__c>();                                  
    List<Unavailability__c> unAvail = new   List<Unavailability__c>();  
    unAvail = RegenrateAvailabilty.retriveunavailability(unavDiary);                                  
                                
        for(Unavailability__c un : unAvail){
                
            un.Remove_Unavailability__c = true;
            UpadatingEntries.add(un);               
        }
        if(UpadatingEntries.size()>0){
        try {
            update UpadatingEntries;
            }
            
        catch(DMLexception e){
        
                system.debug('----EXCEPTION ----'+e);
          }
        }
        if(unavDiary.size()>0){
        try {
            delete unavDiary;
            }
            
        catch(DMLexception e){
        
                system.debug('----EXCEPTION ----'+e);
        
           }
        }
    
}


public pagereference deleterecords(){
  try{
  delete UnAvailEntries;
  } 
  catch (Exception e){
    
   }
   
  return null;
  } 
}