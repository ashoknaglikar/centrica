public without sharing class captureMeasures {
    
  
     public Green_Deal_Measures__c gdm {get;set;}
     public boolean accptddate{get;set;}
     public boolean planappstatus{get;set;}
     public boolean solidwall{get;set;}
     
    //public ApexPages.StandardController sc;
 
    
     string retURL;
     string gdr;
     string gdmId;
     string CHI_LeadID;
  
    public captureMeasures(ApexPages.StandardController controller)
    {
         //this.sc=controller;
         system.debug('******controller');
         
         accptddate=false;
         planappstatus=false;
         solidwall=false;
         
         
        gdm = new Green_Deal_Measures__c();
        gdm = (Green_Deal_Measures__c)controller.getRecord();
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        Schema.DescribeSObjectResult r = Green_Deal_Measures__c.sObjectType.getDescribe();
        string key = r.getkeyprefix();
        retURL = retURL.contains('/')? retURL.substring(1,retURL.length()) :retURL;
        
        if(retURL.substring(0,3) == key)
        {
            gdmId = retURL;
            
            system.debug('gdmId'+gdmId);
        }
        else
        {
            gdr = retURL;
        }
       
        if(gdmId!=null)
        { 
            system.debug('gdmId'+gdmId);
            
            gdm = [Select g.Scaffolding_Required__c, g.Recommended_measure__c, g.Name, g.Measure_Gross_Value__c, g.Installation_date__c, g.Id,
                    g.Green_Deal_Record__c,Green_Deal_Record__r.Opportunity__c, g.Extra_Gross_Value__c, g.Customer_Taken_Up_measure__c,
                    COCRecieved__c,Accepted_Dates__c,Planning_Application__c,C_10x__c,SWI_Survery__c,
                    install_spec__c,insulation_end__c,Planning_application_status__c,quote_uploaded__c,solid_wall_insulation__c,
                    solid_wall__c,EWISUR_has__c From Green_Deal_Measures__c g where id  =:gdmId];
           
            system.debug('gdmId'+gdmId);
             
           CHI_LeadID = gdm.Green_Deal_Record__r.Opportunity__c;
        }
        if(gdr!=null)
        {
            gdm.Green_Deal_Record__c = gdr;
            
            CHI_LeadID = [Select Opportunity__c  from Green_Deal_Reconsilliation__c where id = :gdr].Opportunity__c;
            
        }
        if(gdm.Recommended_measure__c == 'Solid Wall Insulation')
        {
	        solidwall = true;
	        
	        if(gdm.Planning_application_status__c !='Approved')
	        planappstatus = true;
        }
        
        gdm.solid_wall_insulation__c = null;
    }
   
    
   /*public pagereference saveRecord()
 {
    
     return(new pagereference('/'+gdmId));
     //system.debug('gdmId' + gdmId);
    
    
 }*/
 
 
    public pagereference cancel()
 {   
   //system.debug('gdmId');
   
    return(new pagereference('/'+retURL));
 }
 
 public pagereference SaveRecord()
 {
    upsert gdm;
    return (new pagereference('/'+gdm.Id));
 }

    
    public void fecthIntall()
    {
        String temp = Apexpages.currentPage().getParameters().get('recMeas');
        system.debug('temp '+temp );
        if(temp == 'Condensing Boilers')
        {
            try{
            Job__c j = [select id, Installation_Date__c,Scaffolding_Required__c from Job__c where CHI_Lead__c = : CHI_LeadID and Split_Job__c = false and Is_Downtime_Job__c = false and Is_Remedial_Job__c = false];
            gdm.Installation_date__c = j.Installation_Date__c;
            gdm.Scaffolding_Required__c = j.Scaffolding_Required__c;
            }catch (Exception e)
            {
                
            }
        }
        else
        {
            gdm.Installation_date__c= null;
            gdm.Scaffolding_Required__c = null;
        }
        
        
        if(temp == 'Solid wall insulation')
        { system.debug('temp '+temp );
          solidwall=true;
        }
         
        else
        {
          solidwall=false;
        }
    }
    
    public void accptddte(){
      String incdate= Apexpages.currentPage().getParameters().get('incdate');
      system.debug('incdate'+incdate);
      system.debug('incdate---->'+incdate);
      if(incdate!=null && incdate!='' )
      {
      accptddate= true;
      }
      else{
      
          accptddate= false;
      }
    }
     
      public void installdate(){
      String status= Apexpages.currentPage().getParameters().get('status');
      system.debug('status'+status);
      system.debug('status---->'+status);
      if(status=='Approved' )
      {
          planappstatus= false;
       	accptddate=true;
      }
      else
      {
      	gdm.Installation_date__c=null;
        accptddate=false;
        planappstatus= true;
      
       
      }
     
    } 
    
   

}