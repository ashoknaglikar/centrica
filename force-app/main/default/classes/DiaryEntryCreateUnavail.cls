//This apex class is controller for DiaryEntryCreateUnavail visualforce page which is used to render diary entry from diary view page
public class DiaryEntryCreateUnavail{
    public Id entryId{get;set;}
    public string area{get;set;}
    public Diary_Entry__c diaryEntry{get;set;}
  public   DiaryEntryCreateUnavail(ApexPages.StandardController controller){
        entryId= apexpages.currentpage().getparameters().get('entryId');
        area= apexpages.currentpage().getparameters().get('area');

        diaryEntry= new Diary_Entry__c();
            if(entryId!=null){
                 diaryEntry =[select id,Name,Diary_View_Link__c,Employee_Name__c,Start__c,Week__c,Sub_Type__c,Record_Type__c,End__c,Extra_Hours__c,Hours__c,Overbooked_Hours__c,Length__c,Gap_Count1__c from Diary_Entry__c where id =: entryId];
            }
        
    }
   //This method is used to create unavailability 
   
   
   public PageReference CreateUnavailability(){
       
       string  returnUrl= '/apex/Employee_Unavailable?id='+entryId+'&area='+area;
       if(area == 'null' )
       {
           returnUrl +='&sfdc.tabName='+label.PeopleViewTab;
       }
        PageReference pageRef = new PageReference(returnUrl);
        return pageRef ;
    }  
   
    //This method is used to return back to diary view     
     public PageReference DiaryView(){
   
        PageReference pageRef = new PageReference(diaryEntry.Diary_View_Link__c);
        return pageRef ;
    }     
 }