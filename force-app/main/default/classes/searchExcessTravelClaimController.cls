public class searchExcessTravelClaimController{

public list<Excess_Travel_Claim__c> lstETC{get;set;}
public Job__c jb{get;set;}
public boolean show{get;set;}
public boolean selectAll{get;set;}
Utilities util;
public List<District__c> Districts {get;set;}    
public List<Region__c> Region {get;set;}
public string AreaName{get;set;}    
public String RegionName{get;set;}
public String Status{get;set;}
Public String area;    
public String regionID;
public list<ClaimWrap> lst_wrap{get;set;}
private integer counter = 0;
public integer pageSize{get;set;} 
public integer total_size{get;set;}
public boolean CAM{get;set;}

public List<SelectOption> getAreaItems(){            
    List<SelectOption> options = new List<SelectOption>();             
    options.add(new SelectOption('','---All---'));           
    if(Districts == null)            
    Districts = new list<District__c>();             
    for (Integer i = 0; i < Districts.size(); i++){                    
        // Districts = new list<District__c>();                                  
        options.add(new SelectOption(Districts[i].Name,Districts[i].Name));                
        system.debug('@@@@options'+options);            
    }
    
    return options;      
}                    

public List<SelectOption> getRegionItems(){            
    List<SelectOption> options = new List<SelectOption>();             
    options.add(new SelectOption('','---All---'));            
    if(Region == null)            
    Region = new list<Region__c>();             
    for (Integer i = 0; i < Region.size(); i++){                    
        // Districts = new list<District__c>();                                  
        options.add(new SelectOption(Region[i].Name,Region[i].Name));                
        system.debug('@@@@options'+options);
    }                                                           
    return options;      
}

public List<SelectOption> getStatusItems(){            
    List<SelectOption> options = new List<SelectOption>();             
               
    Schema.DescribeFieldResult fieldResult = Excess_Travel_Claim__c.Status__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
    for( Schema.PicklistEntry f : ple)
    {
       options.add(new SelectOption(f.getLabel(), f.getValue()));
    }      
    options.add(new SelectOption('','---All---')); 
    return options;    
}

public searchExcessTravelClaimController(){
    lstETC = new list<Excess_Travel_Claim__c>();           
    lst_wrap = new list<ClaimWrap>();
    show = false;
    selectAll = false;
    pageSize = 100;
    util  = new Utilities();              
    CAM = false;
    User loggedInUser = [Select id,name,ProfileId from User where id=:Userinfo.getUserId()];
    list<String> str = System.Label.ExcessTravelClaim_Profile.split(';');
    for(String s: str)
    if(loggedInUser.ProfileId == s)
    CAM = true;
    jb = new Job__c();            
    jb.Customer_Journey_First_Update__c = System.today().adddays(-30);            
    jb.BGNE_Install_Date__c = System.today();              
    Districts = [Select d.Name, d.Id From District__c d where d.Type__c = 'Installation' order by d.Name];                       
    Region = [Select reg.Name, reg.Id From Region__c reg where reg.Type__c = 'Installation' order by reg.Name];                       
}

 public class ClaimWrap{  
        public boolean isSelected{get;set;} 
        public Excess_Travel_Claim__c etc{get;set;}
        
        //wrapper class to bind checkbox and appointment object together
        public ClaimWrap(boolean isSelected,Excess_Travel_Claim__c etc)
        {
           this.isSelected = isSelected;
           this.etc = etc;             
        }
     }

public void onSelectAll(){
    if(selectAll==true)
    for(ClaimWrap c : lst_wrap){
        c.isSelected = true;
    }
    else
      for(ClaimWrap c : lst_wrap){
        c.isSelected = false;
      }   
}

public void searchClaims(){
    lstETC.clear();
    lst_wrap.clear();
    if(jb.Customer_Journey_First_Update__c!=null && jb.BGNE_Install_Date__c!=null){
        if(Status!=null && Status!=''){
            if(AreaName!=null && AreaName!=''){
                total_size = [SELECT count() FROM Excess_Travel_Claim__c 
                              where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c 
                              and Status__c=:Status];
                lstETC = [SELECT id,Name,District__c,Employee__c,Installation_date__c,Job__c,Region__c,Status__c,Approved_Date_Time__c
                          ,Completed_Date_Time__c,Submitted_Date_Time__c,Total_Time_for_30_and_60_Engineer__c,Total_Time_for_30_and_60_OfficeUser__c
                          ,Total_Time_for_60_Engineer__c,Total_Time_for_60_OfficeUser__c FROM Excess_Travel_Claim__c
                          where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c and 
                          Status__c=:Status and District__c=:AreaName order by Approved_Date_Time__c Limit :pageSize OFFSET :counter];
                          
                 if(lstETC.isEmpty())                        
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No claim found'));
                 else{
                     for(Excess_Travel_Claim__c e : lstETC){
                         lst_wrap.add(new ClaimWrap(false,e));
                     }
                 }
                 show = true;
            }
            else if(RegionName!= null && RegionName!= ''){
                total_size = [SELECT count() FROM Excess_Travel_Claim__c 
                              where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c 
                              and Status__c=:Status];
                lstETC = [SELECT id,Name,District__c,Employee__c,Installation_date__c,Job__c,Region__c,Status__c,Approved_Date_Time__c
                          ,Completed_Date_Time__c,Submitted_Date_Time__c,Total_Time_for_30_and_60_Engineer__c,Total_Time_for_30_and_60_OfficeUser__c
                          ,Total_Time_for_60_Engineer__c,Total_Time_for_60_OfficeUser__c FROM Excess_Travel_Claim__c
                          where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c and 
                          Status__c=:Status and Region__c=:RegionName order by Approved_Date_Time__c Limit :pageSize OFFSET :counter];
                          
                 if(lstETC.isEmpty())                        
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No claim found'));
                 else{
                     for(Excess_Travel_Claim__c e : lstETC){
                         lst_wrap.add(new ClaimWrap(false,e));
                     }
                 }
                 show = true;
            }
            else{
                total_size = [SELECT count() FROM Excess_Travel_Claim__c 
                              where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c 
                              and Status__c=:Status];
                lstETC = [SELECT id,Name,District__c,Employee__c,Installation_date__c,Job__c,Region__c,Status__c,Approved_Date_Time__c
                          ,Completed_Date_Time__c,Submitted_Date_Time__c,Total_Time_for_30_and_60_Engineer__c,Total_Time_for_30_and_60_OfficeUser__c
                          ,Total_Time_for_60_Engineer__c,Total_Time_for_60_OfficeUser__c FROM Excess_Travel_Claim__c
                          where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c and Status__c=:Status order by Approved_Date_Time__c Limit :pageSize OFFSET :counter];
                          
                 if(lstETC.isEmpty())                        
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No claim found'));
                 else{
                     for(Excess_Travel_Claim__c e : lstETC){
                         lst_wrap.add(new ClaimWrap(false,e));
                     }
                 }
                 show = true;
            }
        }
        
        else {
            if(AreaName!=null && AreaName!=''){
                System.debug('====InIf===');
                total_size = [SELECT count() FROM Excess_Travel_Claim__c 
                              where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c 
                              and District__c=:AreaName];
                lstETC = [SELECT id,Name,District__c,Employee__c,Installation_date__c,Job__c,Region__c,Status__c,Approved_Date_Time__c
                          ,Completed_Date_Time__c,Submitted_Date_Time__c,Total_Time_for_30_and_60_Engineer__c,Total_Time_for_30_and_60_OfficeUser__c
                          ,Total_Time_for_60_Engineer__c,Total_Time_for_60_OfficeUser__c FROM Excess_Travel_Claim__c
                          where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c and District__c=:AreaName order by Approved_Date_Time__c Limit :pageSize OFFSET :counter];
                          
                 System.debug('====InIf==='+lstETC+AreaName);
                 
                 if(lstETC.isEmpty())                        
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No claim found'));
                 
                 else{
                     for(Excess_Travel_Claim__c e : lstETC){
                         lst_wrap.add(new ClaimWrap(false,e));
                     }
                 }
                 show = true;   
            }
            
            else if(RegionName!= null && RegionName!= ''){
                total_size = [SELECT count() FROM Excess_Travel_Claim__c 
                              where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c 
                              and Region__c=:RegionName];
                lstETC = [SELECT id,Name,District__c,Employee__c,Installation_date__c,Job__c,Region__c,Status__c,Approved_Date_Time__c
                          ,Completed_Date_Time__c,Submitted_Date_Time__c,Total_Time_for_30_and_60_Engineer__c,Total_Time_for_30_and_60_OfficeUser__c
                          ,Total_Time_for_60_Engineer__c,Total_Time_for_60_OfficeUser__c FROM Excess_Travel_Claim__c
                          where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c and Region__c=:RegionName order by Approved_Date_Time__c Limit :pageSize OFFSET :counter];
                          
                 System.debug('====InIf==='+lstETC+RegionName);
                 if(lstETC.isEmpty())                        
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No claim found'));
                 else{
                     for(Excess_Travel_Claim__c e : lstETC){
                         lst_wrap.add(new ClaimWrap(false,e));
                     }
                 }
                 show = true;
            }
             
            else{
                total_size = [SELECT count() FROM Excess_Travel_Claim__c 
                              where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c];
                lstETC = [SELECT id,Name,District__c,Employee__c,Installation_date__c,Job__c,Region__c,Status__c,Approved_Date_Time__c
                          ,Completed_Date_Time__c,Submitted_Date_Time__c,Total_Time_for_30_and_60_Engineer__c,Total_Time_for_30_and_60_OfficeUser__c
                          ,Total_Time_for_60_Engineer__c,Total_Time_for_60_OfficeUser__c FROM Excess_Travel_Claim__c
                          where Approved_Date_Time__c>=:jb.Customer_Journey_First_Update__c and Approved_Date_Time__c<=:jb.BGNE_Install_Date__c order by Approved_Date_Time__c Limit :pageSize OFFSET :counter];
                          
                 if(lstETC.isEmpty())                        
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No claim found'));
                 else{
                     for(Excess_Travel_Claim__c e : lstETC){
                         lst_wrap.add(new ClaimWrap(false,e));
                     }
                 }
                 show = true;
             }
        }
    }
    else{
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Enter start and end date.');          
        ApexPages.addMessage(myMsg);  
    }
}

public void onComplete(){
    list<Excess_Travel_Claim__c> selectedClaims= new list<Excess_Travel_Claim__c>();
    if(selectAll)
      for(ClaimWrap e : lst_wrap)
      selectedClaims.add(e.etc);
    else
      for(ClaimWrap e : lst_wrap)
        if(e.isSelected==true)
          selectedClaims.add(e.etc);
          
    for(Excess_Travel_Claim__c e : selectedClaims)
        if(e.Status__c=='Approved')
          e.Status__c = 'Completed';
    try{
        update selectedClaims;
    }
    catch(Exception e){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());          
        ApexPages.addMessage(myMsg); 
    }
    lst_wrap.clear();
    searchClaims();
}

////////////////////////////////////////////
////////                          //////////
////////      Pagination          //////////
////////                          //////////
////////////////////////////////////////////

   public PageReference Previous() { //user clicked previous button
      counter -= pageSize;
      runQuery();
      return null;
   }
 
   public PageReference Next() { //user clicked next button
      counter += pageSize;
      runQuery();
      return null;
   }
 
   public Boolean getDisablePrevious() {
      //this will disable the previous and beginning buttons
      if (counter>0) return false; else return true;
   }
 
   public Boolean getDisableNext() { //this will disable the next and end buttons
      if (counter + pageSize < total_size) return false; else return true;
   }

   public Integer getPageNumber() {
      return counter/pageSize + 1;
   }
 
   public Integer getTotalPages() {
      if (math.mod(total_size, pageSize) > 0) {
         return total_size/pageSize + 1;
      } else {
         return (total_size/pageSize);
      }
   }
   
   private void runQuery()
   {
       lstETC.clear();
       lst_wrap.clear();
       searchClaims();
   }

}