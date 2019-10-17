public class SurveyJobDiary {
    public class SurveyJobDiaryDetails{
        public String str_SurveyJobTitle{get;set;}
        public String str_JobNumber{get;set;}
        public String str_JobId{get;set;}

        private Unavailability__c obj_Survey=new Unavailability__c();
        public Unavailability__c getObj_Survey(){
            return obj_Survey;
        }
        public void setObj_Survey(Unavailability__c value){
            obj_Survey=value;
        }
        
    }
    private Boolean isFirst=false;
    public Boolean bln_Error{get;set;}
    public List<SurveyJobDiaryDetails> lst_SurveyJobDetail{get;set;}
    public Job_Diary__c obj_Job1 {get;set;}
    public Job_Diary__c obj_Job2 {get;set;}
    private Integer int_Count=1;
    public String str_jobPipelineTimeline{get;set;}
    public Id id_Installer {get;set;}
    public String str_StartDate{get;set;}
    public String str_EndDate{get;set;}
    public String str_InstallerName{get;set;}
    private List<Unavailability__c> lst_Unavailability=new List<Unavailability__c>{};
    public String str_Message{get;set;}
    
    public List<Unavailability__c> getLst_Unavailability(){
        return lst_Unavailability;
    }
    public void setLst_Unavailabilty(List<Unavailability__c> value){
        lst_Unavailability=value;
    }
    public SurveyJobDiary(){
        Date startDate=date.today();
        obj_Job1=new Job_Diary__c();
        obj_Job2=new Job_Diary__c();
        obj_Job1.Job_Notification_Date__c=startDate;
        System.debug('Start Date:' + obj_Job1.Job_Notification_Date__c);
        obj_Job2.Job_Notification_Date__c=startDate.addDays(6);
        System.debug('End Date:' + obj_Job2.Job_Notification_Date__c);
        populateData();
        
    }
    private void populateData(){
        
        bln_Error=false;
        String str_EmpId='';
        lst_SurveyJobDetail=new List<SurveyJobDiaryDetails>{};
        str_jobPipelineTimeline='Period :' + obj_Job1.Job_Notification_Date__c.format() + ' - ' + obj_Job2.Job_Notification_Date__c.format();
        System.debug('Start Of Installer Population');        
        if (obj_Job1.JobInstaller__c==null) {
            id_Installer=UserInfo.getUserid();
            System.debug('Installer :' + id_Installer);
        } else {
            id_Installer=obj_Job1.JobInstaller__c;
            System.debug('Installer :' + id_Installer);            
        }
        str_InstallerName=[select Name from User where id=:id_Installer].Name;
        str_InstallerName='Survey Diary for ' + str_InstallerName;
        try {
            str_EmpId=[Select Id From Employee__c where Salesforce_User__c =:id_Installer limit 1].Id;
            System.debug('$$$$$$$$ Employee Id: ' + str_EmpId);
        }catch(Exception ex){
            System.debug(ex.getMessage());
            str_Message='User doesnot have link to employee record.';
            bln_Error=true;
        }
        if (str_EmpId!='') {
            lst_Unavailability=[Select Unavailability_Reason__c, Unavailability_Notes__c, 
                                Start_Date_Time__c, Generated_Unavailability__c,Opportunity__c,Opportunity__r.Name,Quote_number__c, 
                                End_Date_Time__c,StartDate__c ,Opportunity__r.Account.Address__c,
                                Opportunity__r.Account.Primary_Contact__c,DayOfWeek__c,Duaration_for_Event__c,LastModifiedById
                                From Unavailability__c where Unavailability_Reason__c=:'Survey Booking' 
                                and Employee__c=:str_EmpId and 
                                StartDate__c>=:obj_Job1.Job_Notification_Date__c and 
                                StartDate__c<=:obj_Job2.Job_Notification_Date__c and
                                Remove_Unavailability__c =: False and 
                                Generated_Unavailability__c =:True
                                Order by StartDate__c ASC];
            Integer int_TotalCount=lst_Unavailability.size();
            lst_SurveyJobDetail=new List<SurveyJobDiaryDetails>{};
            SurveyJobDiaryDetails obj_SurveyDetail=new SurveyJobDiaryDetails();
            int_Count=1;
            Map<String,Job__c> mp_JobNo=new Map<String,Job__c>{};
            Set<String> set_JobNo=new Set<String>{};
            for(Unavailability__c obj_Unavailalibilty:lst_Unavailability){
                set_JobNo.add(obj_Unavailalibilty.Opportunity__c);
            }
            
            List<Job__c> lst_Job =[select id, Name,CHI_Lead__c from Job__c where CHI_Lead__c In:set_JobNo];
            for (Job__c obj_job:lst_Job){
                mp_JobNo.put(obj_job.CHI_Lead__c,obj_job);
            }
            for(Unavailability__c obj_Unavailalibilty:lst_Unavailability){
                obj_SurveyDetail=new SurveyJobDiaryDetails();
                obj_SurveyDetail.str_SurveyJobTitle='Survey ' + int_Count + ' of ' + int_TotalCount + ' > ' + obj_Unavailalibilty.Opportunity__r.Name + ' ; Survey Day: ' + obj_Unavailalibilty.DayOfWeek__c; 
                int_Count++;
                if (mp_JobNo==null) {
                    
                } else if (mp_JobNo.size()>0 ) {
                    try {
                        obj_SurveyDetail.str_JobId=mp_JobNo.get(obj_Unavailalibilty.Opportunity__c).id;
                        obj_SurveyDetail.str_JobNumber=mp_JobNo.get(obj_Unavailalibilty.Opportunity__c).Name;
                    } catch(Exception ex){
                        //do nothing
                    }
                }
                obj_SurveyDetail.obj_Survey=obj_Unavailalibilty;
                lst_SurveyJobDetail.add(obj_SurveyDetail);
            }
        }
        if (lst_SurveyJobDetail==null) {
            lst_SurveyJobDetail=null;
            if (bln_Error==false) {
                str_Message='No record to display';
            }
        } else if (lst_SurveyJobDetail.size()==0) {
            lst_SurveyJobDetail=null;
            if (bln_Error==false) {
                str_Message='No record to display';
            }
        }
       
    }
    
   
    public PageReference surveyJobRerun() {
        populateData();    
        return null;    
    } 
    
    //Test Method for this Class
    Public static Testmethod void SurveyJobDiary_Test(){
        try {   
            SurveyJobDiary s = new SurveyJobDiary();
            SurveyJobDiary.SurveyJobDiaryDetails IO = new SurveyJobDiary.SurveyJobDiaryDetails();
            String D = IO.str_SurveyJobTitle;
            Unavailability__c sdf = new Unavailability__c();
            sdf = IO.getObj_Survey();
            IO.setObj_Survey(sdf);
            
        } catch(Exception ex){
            //do nothing
        }
    }
    
}