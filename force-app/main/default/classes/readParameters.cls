public class readParameters{
  
  public job__c job{get;set;}
  public Opportunity opp;
  public string chiLeadNo{get;set;}
  public Map<String, Double> skillsAndHours = new Map<String, Double>(); 
  public AddNewSkill ObjNewSkill = new AddNewSkill();
  public boolean errorRender{get;set;}
  public String errorMsg {get;set;}
  public boolean Confirm{get;set;}
  public boolean exstng{get;set;}
  public string custDate{get;set;}
  boolean Edisable;
  string jobId='';
  string PreElectric;    
  
  public boolean lowIndicator{get;set;}
  
 /* public boolean getlowIndicator(){
    return lowIndicator;
  }*/
  
  public boolean getEdisable(){
    return Edisable;
  }
    
  public readParameters(){
         errorMsg = '';
         Confirm = FALSE;
         errorRender=FALSE;
         exstng = FALSE;
         Edisable = FALSE;
         lowIndicator = false;
         job = new Job__c();
         custDate = '';
         string completeList = ApexPages.currentPage().getParameters().get('lead');
         string jid = ApexPages.currentPage().getParameters().get('jobId');
         
         system.debug('completeList-->'+completeList+completeList.contains('/'));
         List<string> allParams = completeList.split('/');
         
         system.debug('All params -->'+allParams);
         map<string, string> paramMap = new Map<string, string>{'lead'=>'Test', 'M'=>'0.0', 'PF'=>'0.0', 'E'=>'0.0', 'B'=>'0.0', 'M'=>'0.0', 'RHC'=>'0.0',
                                                                'R'=>'0.0', 'ECO'=>'0.0', 'SB'=>'0.0', 'MSL'=>'0.0', 'CI'=>'0.0', 'FF'=>'0.0',
                                                                'LP'=>'0.0', 'PC'=>'0.0', 'MEG'=>'0.0', 'S'=>'0.0', 'UV'=>'0.0', 'WF'=>'0.0',
                                                                'EA'=>'0.0', 'A'=>'0.0', 'AF'=>'0.0', 'EG'=>'0.0', 'LC'=>'0.0', 'Bloc'=>'',
                                                                'InstType'=>'' , 'PreElec'=>'', 'HA' =>'NO'};
         for(string s: allParams)
         {
             if(s.contains('='))
             {
                 string[] temp = s.split('=');
                 paramMap.put(temp[0], temp[1]);
             }else
             
             paramMap.put('lead', s);
         }
         
         system.debug(LoggingLevel.INFO,'Final Map-->'+paramMap);
         
         
         chiLeadNo          =paramMap.get('lead'); 
         string MechHours   =paramMap.get('M'); 
         string PFHours     =paramMap.get('PF'); 
         string EleHours    =paramMap.get('E'); 
         string BuildHours  =paramMap.get('B'); 
         string RHHours     =paramMap.get('RHC'); 
         string RWHours     =paramMap.get('R'); 
         string ECO         =paramMap.get('ECO'); 
         string SBhours     =paramMap.get('SB'); 
         string CSPHours    =paramMap.get('MSL'); 
         string CIHours     =paramMap.get('CI'); 
         string FFHours     =paramMap.get('FF'); 
         string LPHours     =paramMap.get('LP'); 
         string PCHours     =paramMap.get('PC'); 
         string MEGHours    =paramMap.get('MEG'); 
         string ScafHours   =paramMap.get('S'); 
         string UVHours     =paramMap.get('UV'); 
         string WHHours     =paramMap.get('WF'); 
         string EAHours     =paramMap.get('EA'); 
         string AsbesHours  =paramMap.get('A'); 
         string AsbFixHours =paramMap.get('AF'); 
         string EEGHours    =paramMap.get('EG'); 
         string LCHours     =paramMap.get('LC'); 
         string BoilerLoc   =paramMap.get('Bloc');
         string InstType    =paramMap.get('InstType'); 
         PreElectric        =paramMap.get('PreElec'); 
         boolean heavyAppliance = paramMap.get('HA').toUpperCase() == 'YES';
         
           if(chiLeadNo!=null){
               system.debug(LoggingLevel.INFO,'chiLeadNo-->');
               try{
                 opp = [select id,name,CHI_Lead_Id__c,AccountId,Account.BillingPostalcode,
                            (select id,name,Quote__c,CHI_Lead__c,Customer_Preferred_Date__c ,Delivery_Date__c,Installation_Date__c,Mechanical_Hours__c,PowerFlush_Hours__c,Electrical_Hours__c,Building_Work_Hours__c,Remote_Heating__c ,Roof_Work_Hours__c,ECO_Hours__c ,Specialist_Building_Hours__c, Connect_Solar_Panel_Hours__c ,
                            Contractor_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,LPG_Installation_Hours__c,Payment_Collection_Hours__c,Ecogen_Mechanical_Hours__c,Start_Data_Time__c,Delivery_Slot__c, 
                            Scaffolder_Hours__c ,Unvented_Hot_Water_Hours__c ,Water_Heating_Fixing_Hours__c ,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Install_Postcode__c,
                            Ecogen_Electrical_Hours__c,Landlord_Check_Hours__c,Boiler_Location__c,Installation_Type__c,Status__c,Sub_Status__c,Balancing_Skill__c from Jobs__r) 
                            from opportunity where CHI_Lead_Id__c=:chileadNo LIMIT 1];
                   //opp = [select id,name,CHI_Lead_Id__c from opportunity where CHI_Lead_Id__c=:chileadNo LIMIT 1];
                   
                if(opp.Account.BillingPostalcode !=null ){
                   try{
                   string postcodeSector = opp.Account.BillingPostalcode.substring(0,opp.Account.BillingPostalCode.length()-2);
                   postcode_Sector__c p = [select id, Sub_Patch__r.District__r.Low_Utilisation__c from postcode_Sector__c where name = :postcodeSector and Type__c = 'Installation' ];
                   if(p.Sub_Patch__r.District__r.Low_Utilisation__c)
                   lowIndicator = true;
                   }
                   catch (exception e)
                   {
                      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getmessage());
                      ApexPages.addMessage(myMsg);
                   }
                  
                 }  
               }Catch(Exception e){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please check the Lead Number');
                    ApexPages.addMessage(myMsg);
                    //return null; 
               }
             }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Lead Number doesn\'t exist');
                ApexPages.addMessage(myMsg);
             }
             if(opp!=null && opp.Jobs__r.size()>0){
                   //exstng = TRUE;
                   try{
                       job = opp.jobs__r[0];
                       if(job.Status__c == 'Allocated'){
                        exstng = True;
                        custDate = job.customer_preferred_Date__c.format();
                       }else if(job.Status__c == 'Pending' && job.Quote__c == null){
                         custDate = job.customer_preferred_Date__c.format();
                         system.debug(LoggingLevel.INFO,'@@@@@@'+boilerLoc);
                         job.Mechanical_Hours__c = MechHours!=null?Double.valueOf(MechHours):0.00;
                         //system.debug(LoggingLevel.INFO,'@@@@@@1'+job.Mechanical_Hours__c);
                         job.PowerFlush_Hours__c = PFHours!=null?Double.valueOf(PFHours):0.00; 
                         job.Electrical_Hours__c = eleHours!=null?Double.valueOf(eleHours):0.00;
                         job.Building_Work_Hours__c = BuildHours!=null?Double.valueOf(BuildHours):0.00;
                         job.Remote_Heating__c = RHHours!=null?Double.valueOf(RHHours):0.00; 
                         job.Roof_Work_Hours__c = RWHours!=null?Double.valueOf(RWHours):0.00; 
                         job.ECO_Hours__c = ECO!=null?Double.valueOf(ECO):0.00; 
                         job.Specialist_Building_Hours__c = SBhours!=null?Double.valueOf(SBhours):0.00; 
                         job.Connect_Solar_Panel_Hours__c = CSPHours!=null?Double.valueOf(CSPHours):0.00;
                         job.Contractor_Installation_Hours__c = CIHours!=null?Double.valueOf(CIHours):0.00;
                         job.Fire_Wall_Heater_Fixing_Hours__c = FFHours!=null?Double.valueOf(FFHours):0.00;
                         job.LPG_Installation_Hours__c = LPHours!=null?Double.valueOf(LPHours):0.00; 
                         job.Payment_Collection_Hours__c = PCHours!=null?Double.valueOf(PCHours):0.00; 
                         job.Ecogen_Mechanical_Hours__c = MEGHours!=null?Double.valueOf(MEGHours):0.00;
                         job.Scaffolder_Hours__c = ScafHours!=null?Double.valueOf(ScafHours):0.00; 
                         job.Unvented_Hot_Water_Hours__c = UVHours!=null?Double.valueOf(UVHours):0.00; 
                         job.Water_Heating_Fixing_Hours__c = WHHours!=null?Double.valueOf(WHHours):0.00; 
                         job.Electrical_Work_ASP_Hours__c = EAHours!=null?Double.valueOf(EAHours):0.00;
                         job.Asbestos_Removal_Hours__c = AsbesHours!=null?Double.valueOf(AsbesHours):0.00;
                         job.Asbestos_Removal_Fixed_Rate_Hours__c = AsbFixHours!=null?Double.valueOf(AsbFixHours):0.00;
                         job.Ecogen_Electrical_Hours__c = EEGHours!=null?Double.valueOf(EEGHours):0.00; 
                         job.Landlord_Check_Hours__c = LCHours!=null?Double.valueOf(LCHours):0.00; 
                         job.Boiler_Location__c = BoilerLoc;
                         job.Installation_Type__c = InstType;
                         job.Heavy_Appliance__c = heavyAppliance;
                         BlackBoxOptions dt = new BlackBoxOptions();
                         job.Customer_Preferred_Date__c = dt.HSACustomerPrefDate(system.today());
                         custDate=string.valueof(job.Customer_Preferred_Date__c);
                         string[] slist = custDate.split('-');
                         custDate = slist[2]+'/'+slist[1]+'/'+slist[0];
                       }
                       skillsAndHours = ObjNewSkill.setSkillHoursInfo(job, skillsAndHours);
                       if(job.Scaffolder_Hours__c > 0) {
                       skillsAndHours.put('SCAFFOLDER', job.Scaffolder_Hours__c);
                       }
                       System.debug(LoggingLevel.INFO,'skillsAndHours: ' + skillsAndHours);
                       ObjNewSkill.validateJobSkillHoursHSA(skillsAndHours);
                     }catch(Exception e){
                       errorRender=TRUE;
                       errorMsg = e.getMessage();
                       Edisable = TRUE;
                     }
             }else{
                 try{
                 system.debug(LoggingLevel.INFO,'@@@@@@'+boilerLoc);
                 job.Mechanical_Hours__c = MechHours!=null?Double.valueOf(MechHours):0.00;
                 //system.debug(LoggingLevel.INFO,'@@@@@@1'+job.Mechanical_Hours__c);
                 job.PowerFlush_Hours__c = PFHours!=null?Double.valueOf(PFHours):0.00; 
                 job.Electrical_Hours__c = eleHours!=null?Double.valueOf(eleHours):0.00;
                 job.Building_Work_Hours__c = BuildHours!=null?Double.valueOf(BuildHours):0.00;
                 job.Remote_Heating__c = RHHours!=null?Double.valueOf(RHHours):0.00; 
                 job.Roof_Work_Hours__c = RWHours!=null?Double.valueOf(RWHours):0.00; 
                 job.ECO_Hours__c = ECO!=null?Double.valueOf(ECO):0.00; 
                 job.Specialist_Building_Hours__c = SBhours!=null?Double.valueOf(SBhours):0.00; 
                 job.Connect_Solar_Panel_Hours__c = CSPHours!=null?Double.valueOf(CSPHours):0.00;
                 job.Contractor_Installation_Hours__c = CIHours!=null?Double.valueOf(CIHours):0.00;
                 job.Fire_Wall_Heater_Fixing_Hours__c = FFHours!=null?Double.valueOf(FFHours):0.00;
                 job.LPG_Installation_Hours__c = LPHours!=null?Double.valueOf(LPHours):0.00; 
                 job.Payment_Collection_Hours__c = PCHours!=null?Double.valueOf(PCHours):0.00; 
                 job.Ecogen_Mechanical_Hours__c = MEGHours!=null?Double.valueOf(MEGHours):0.00;
                 job.Scaffolder_Hours__c = ScafHours!=null?Double.valueOf(ScafHours):0.00; 
                 job.Unvented_Hot_Water_Hours__c = UVHours!=null?Double.valueOf(UVHours):0.00; 
                 job.Water_Heating_Fixing_Hours__c = WHHours!=null?Double.valueOf(WHHours):0.00; 
                 job.Electrical_Work_ASP_Hours__c = EAHours!=null?Double.valueOf(EAHours):0.00;
                 job.Asbestos_Removal_Hours__c = AsbesHours!=null?Double.valueOf(AsbesHours):0.00;
                 job.Asbestos_Removal_Fixed_Rate_Hours__c = AsbFixHours!=null?Double.valueOf(AsbFixHours):0.00;
                 job.Ecogen_Electrical_Hours__c = EEGHours!=null?Double.valueOf(EEGHours):0.00; 
                 job.Landlord_Check_Hours__c = LCHours!=null?Double.valueOf(LCHours):0.00; 
                 job.Boiler_Location__c = BoilerLoc;
                 job.Installation_Type__c = InstType;
                 job.Heavy_Appliance__c = heavyAppliance;
                 job.Status__c = 'Pending';
                 job.Sub_Status__c = 'Install Date Required';
                 BlackBoxOptions dt = new BlackBoxOptions();
                 job.Customer_Preferred_Date__c = dt.HSACustomerPrefDate(system.today());
                 custDate=string.valueof(job.Customer_Preferred_Date__c);
                 string[] slist = custDate.split('-');
                 custDate = slist[2]+'/'+slist[1]+'/'+slist[0];
                 skillsAndHours = ObjNewSkill.setSkillHoursInfo(job, skillsAndHours);
                 if(job.Scaffolder_Hours__c > 0) {
                 skillsAndHours.put('SCAFFOLDER', job.Scaffolder_Hours__c);
                 }
                 System.debug(LoggingLevel.INFO,'skillsAndHours: ' + skillsAndHours);
                 ObjNewSkill.validateJobSkillHoursHSA(skillsAndHours);
             }catch(Exception e){
              errorRender=TRUE;
              errorMsg = e.getMessage();
              Edisable = TRUE;
              exstng = true;
            }
            
             
            }
            if(PreElectric.toUpperCase() ==  'YES' || job.Asbestos_Removal_Hours__c >0 )
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This Job is classified as complex, please contact the office to plan.');
                ApexPages.addMessage(myMsg);
               
                Edisable = TRUE;
            }
            
      
  }
  
  public pagereference CreateJob(){
      
      String cDate = ApexPages.currentPage().getParameters().get('cDate');
      system.debug(LoggingLevel.Info,'=====>'+cDate);
      if(cDate!=null && cDate!=''){
        job.Customer_Preferred_Date__c = Date.Parse(cDate);
        custDate = cDate;
      }else{
        cDate = system.today().format();
        custDate = cDate;
        job.Customer_Preferred_Date__c = Date.Parse(cDate);  
      }
      system.debug(LoggingLevel.INFO,'------->'+cDate);
      
      if(opp!=null)
      job.CHI_Lead__c = opp.id;
      
      /*if(job.Customer_Preferred_Date__c == null){
         custDate = system.today().format();
      }else{
         string cDate = string.valueof(job.Customer_Preferred_Date__c);
         custDate = cDate.substring(8,10)+'/'+cDate.substring(5,7)+'/'+cDate.substring(0,4);
      }
      system.debug(LoggingLevel.INFO,'------->'+custDate);*/
      
      try{
          system.debug(Logginglevel.INFO,'job--->'+job);
          /*Commented by Ashok G 
          skillsAndHours = ObjNewSkill.setSkillHoursInfo(job, skillsAndHours);
          if(job.Scaffolder_Hours__c > 0) {
          skillsAndHours.put('SCAFFOLDER', job.Scaffolder_Hours__c);
          }
          System.debug(LoggingLevel.INFO,'skillsAndHours: ' + skillsAndHours);
          ObjNewSkill.validateJobSkillHoursHSA(skillsAndHours);*/
         
          /*if(job.Scaffolder_Hours__c>0){
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Job with Scaffolder Hours is unable to Plan By HSA');
           ApexPages.addMessage(myMsg);
           return null;
          }*/
          if(PreElectric.toUpperCase() !=  'YES')
          Database.upsert(job);
          else
          {
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This Job is classified as complex, please contact the office to plan.');
                ApexPages.addMessage(myMsg);
                return null;  
          }
      }catch(System.DmlException e){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error:'+e.getDmlMessage(0)+e.getlinenumber());
        ApexPages.addMessage(myMsg);
        return null;  
      }catch(Exception e){
        errorRender=TRUE;
        errorMsg = e.getMessage()+e.getlinenumber();
        return null;
      }
      
      
      
      /*if(job.Mechanical_Hours__c>4){
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error:Total hours shouldnot exceed 4');
          ApexPages.addMessage(myMsg);
          return null;
      }*/
      
      system.debug(LoggingLevel.INFO,'jobid----->'+job.id);
      //pagereference pageref = new pagereference('/apex/SearchResultsHSA?jobid='+job.id+'&p=N');
      //pageref.setRedirect(true);
      //return pageref; 
      confirm = TRUE;
      pagereference pageref = new pagereference('/apex/SearchResultsHSA?jobid='+job.id+'&p=N'+'&custDate='+cDate);
      pageref.setRedirect(true);
      return pageref; 
      
  }
  
  public pagereference runSearch(){
      pagereference pageref = new pagereference('/apex/SearchResultsHSA?jobid='+job.id+'&p=N');
      pageref.setRedirect(true);
      return pageref; 
  
  }
  

}