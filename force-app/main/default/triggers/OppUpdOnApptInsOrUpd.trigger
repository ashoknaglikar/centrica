trigger OppUpdOnApptInsOrUpd on Appointment__c (before insert, before update)
{
    
  
  // Make sure that we enter this trigger only once in one transaction.
  if(cls_IsRun.isAppInsertUpdate || cls_IsRun.appointmentSwitch){
        
        return;
        
    }
   
    // Updates Opportunities when associated appointments are either inserted
    // or the Appointments status has changed and is now Appointed or Cancelled
     
    Map<ID,Appointment__c> updatedAppts = new Map<ID,Appointment__c>{};
    list<Opportunity> SO_List_Opp = new list<Opportunity>();
    Opportunity[] oppsToBeUpdated = new list<Opportunity>(); 
    Map<ID,Appointment__c> salesmap= new Map<ID,Appointment__c>();
    Map<ID,Appointment__c> greendealmap= new Map<ID,Appointment__c>();
    List<ID> mapids = new List<ID>(); 
    Map<Id, Appointment__c> oppIdApptMap = new Map<Id, Appointment__c>();
    List<sObject> messages = new List<sObject>();
    // If newAppt Status is Happened, Premier has updated (can we assume this?)
    // therefore we don't want Appointment History on the Appointment created
    // This is already taken care of - it won't be added to updateAppts, the
    // associated opportunity won't be pulled out and therefore won't be updated.
    
    for (Appointment__c newAppt : Trigger.new)
    {
    
    	if(newAppt.OFS_ETA_Text__c != null)
    	newAppt.ETA__c = datetime.valueof(newAppt.OFS_ETA_Text__c.trim() );
    	
        system.debug('--------------------I am here---------------');
        if(trigger.isupdate)
        {
            system.debug('--------------------I am here---------------');
            if(system.label.OFS_Integration_User.contains(userinfo.getUserid()))
            {
                if(trigger.oldmap.get(newAppt.id).Assigned_To__c != newAppt.Assigned_To__c)
                {
                newAppt.Create_History__c = true;
                newAppt.Old_Assigned_To__c = trigger.oldmap.get(newappt.id).Assigned_To__c ;
                }
                
                if(trigger.oldmap.get(newAppt.id).Status__c != newAppt.Status__c && newAppt.Status__c== 'Cancelled')
                {
                    newAppt.Create_History__c = true;
                }
                
            }
            
            if( newAppt.PushToOFS__c == true && trigger.oldmap.get(newAppt.Id).PushToOFS__c == false)
            {
                    
                newAppt.TOA_Duration__c = '90';
                newAppt.OFS_Appointment__c = true;
            
            }
            system.debug('--------------------I am here---------------');
            Appointment__c oldApp = trigger.oldmap.get(newAppt.Id);
            system.debug('--------------------I am here---------------'+newAppt.ETA_After_Optimisation__c+'   '+newAppt.OFS_Appointment__c+' '+oldApp.ETA_After_Optimisation__c );
            
            if(newAppt.OFS_Appointment__c== true && newAppt.ETA_After_Optimisation_Text__c!= null && newAppt.ETA_After_Optimisation_Text__c != oldApp.ETA_After_Optimisation_Text__c)
            {
            	newAppt.ETA_After_Optimisation__c = Datetime.valueOf(newAppt.ETA_After_Optimisation_Text__c.trim());
            }
            
            if(newAppt.OFS_Appointment__c== true && newAppt.ETA_After_Optimisation__c!= null && newAppt.ETA_After_Optimisation__c != oldApp.ETA_After_Optimisation__c)
            {
                Datetime ETADate = newAppt.ETA_After_Optimisation__c;
                Decimal min = newAppt.ETA_After_Optimisation__c.minute();
                Integer hr = newAppt.ETA_After_Optimisation__c.hour();
                system.debug('======>'+hr+'--Min'+min);
                if(min>0){
                    Date cDate = ETADate.date();
                    Integer x = Integer.valueof((min+7.5)/15);
                    Integer Rmin = Math.mod((x*15),60);
                    System.debug('Rounded to nearest Quarter ' + min+'===> '+ Rmin);             
                    
                    Integer hr1 = Integer.valueof((min/105)+0.5);
                    system.debug('Inside'+hr1);
                    Integer RHr = Math.mod((hr1+hr),24);
                    System.debug('------>RHr'+RHr);
                    ETADate = Datetime.newInstance(cDate.year(),cDate.Month(),cDate.day(),RHr,Rmin,0);
                    System.debug('@@@@@@@@@@@'+ETADATE);
                }
                newAppt.Start__c = ETADate;
                newAppt.End__c = newAppt.Start__c.addHours(+2);
                
                IV_Vectors__c deail = IV_Vectors__c.getInstance('SLA Start Hours');
                newAppt.SLA_Start__c = newAppt.Start__c.addHours(integer.valueof(deail.Key__c));
                
                deail = IV_Vectors__c.getInstance('SLA Start Minutes');
                newAppt.SLA_Start__c = newAppt.Start__c.addMinutes(integer.valueof(deail.Key__c));
                
                deail = IV_Vectors__c.getInstance('SLA End Hours');
                integer slaHrsParam = integer.valueof(deail.Key__c);
                
                deail = IV_Vectors__c.getInstance('SLA End Minutes');
                integer slaminParam = integer.valueof(deail.Key__c);
                
                newAppt.SLA_End__c = newAppt.Start__c.addHours(slaHrsParam).addMinutes(slaminParam);
                newAppt.PushToOFS__c = true;
                if(IV_Vectors__c.getInstance('ETAWorkforce_Switch').Key__c == 'on')
                messages.add(new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c='A-'+newAppt.Id,
                                                                                     TOA2__appt_number__c=newAppt.Id
                                                                                ));
                        
            }
        }
          
        if(Trigger.isInsert || ((newappt.Status__c == 'Appointed' || newappt.Status__c == 'Cancelled' || newappt.Status__c == 'Happened')  && Trigger.oldMap.get(newAppt.Id).Status__c != newAppt.Status__c) || (Trigger.oldMap.get(newAppt.Id).Appointment_Attendee__c != newAppt.Appointment_Attendee__c)) 
        {
             //system.debug('SO Debug--->'+newAppt.Name);
            // We will need to get this Appointment's Opportunities
            if(newAppt.Type__c=='Sales' || newAppt.Type__c=='Survey' ||  newAppt.Type__c=='Priority' ||
            newAppt.Type__c=='Technical' || newAppt.Type__c=='Joint')
            updatedAppts.put(newAppt.Opportunity__c, newAppt);
            

        }
        else if(trigger.isUpdate && newAppt.Status__c == 'Appointed' && newAppt.Assigned_To__c  != trigger.oldmap.get(newAppt.Id).Assigned_To__c && newAppt.Employee_BM_User__c == 'Yes')
        {
            SO_List_Opp.add(new Opportunity(Id=newAppt.Opportunity__c, Commission_SO_HSA__c = newAppt.Assigned_To_Name__c, COMMISSION_SO_HSA_Payroll__c = newAppt.Assigned_To_Payroll__c,Commission_SO_ApptDate__c = newAppt.Visit_Date__c/*, Sales_Advisor__r = new People_Hirearchy__c(Pay_number__c = newAppt.Assigned_To_Payroll__c) */));
            
        }
        /*
        // if - check if Appt is updated to Appointed
 		if (newAppt.Type__c=='Sales' &&  (trigger.isinsert || Trigger.isupdate && Trigger.oldMap.get(newAppt.Id).Status__c != newAppt.Status__c) && (newAppt.Status__c=='Appointed' || newAppt.Status__c=='Cancelled'))
        {
            salesmap.put(newAppt.Opportunity__c, newAppt);
            system.debug('@@@@salesmap'+salesmap);
        }
        
        if(newAppt.Type__c=='Green Deal' && (trigger.isinsert || Trigger.isupdate && Trigger.oldMap.get(newAppt.Id).Status__c != newAppt.Status__c) && (newAppt.Status__c=='Appointed' || newAppt.Status__c=='Cancelled'))
        {
            greendealmap.put(newAppt.Opportunity__c, newAppt); 
            system.debug('@@@@greendealmap'+greendealmap); 
        }
        */
        if(newAppt.Status__c == 'Appointed' && newAppt.Type__c == 'Sales' && newAppt.Opportunity__c!=null)// && (newAppt.Landlords_Email__c == null||newAppt.Landlords_Name__c == null || newAppt.Tenants_Name__c == null || newAppt.Tenants_Email__c == null) && newAppt.Opportunity__c!=null)
        {
            oppIdApptMap.put(newAppt.Opportunity__c, newAppt);
        }
        
        system.debug('oppIdApptMap-->'+oppIdApptMap);
        
        
        /********* populate Appointment Time ******/
        
        
        

 }
    
    if(oppIdApptMap.keyset().size()>0)
    {
        Map<Id,Id> opAppId = new Map<Id,Id>();
        Map<id, Opportunity> oppMap = new Map<id, Opportunity>([Select id, Product_Interest__c, Account.Landlord_Account__c,Account.Sales_Subpatch__r.Appointment_Source__c,Account.Sales_Subpatch__r.Code__c, Account.Sales_Subpatch__r.OFS_Start_Date__c, AccountId,
        														/*(Select Sales_Appointment__c from Land_Lord_Records__r limit 1)*/ 
        														DSM__c, DSM_Email__c, DSM_Name__c, DSM_Phonenumber__c from Opportunity where Id in :oppIdApptMap.keyset()]);
        //Map<Landlord_Record__c,Appointment__c> AppLLId = new Map<Landlord_Record__c,Appointment__c>();
                
        
        
        if(!oppIdApptMap.values().isEmpty())
        for(Appointment__c app : oppIdApptMap.values()){
        	
        	
            opportunity opp = oppMap.get(app.Opportunity__c);
            
            app.DSM_Email__c = opp.DSM_Email__c;
    		app.DSM_Mobile__c = opp.DSM_Phonenumber__c;
			app.DSM_Name__c = opp.DSM_Name__c ;
            app.Subpatch_Code__c = opp.Account.Sales_SubPatch__r.Code__c!=null && opp.Account.Sales_SubPatch__r.Code__c!='' ? opp.Account.Sales_SubPatch__r.Code__c.substring(2,opp.Account.Sales_SubPatch__r.Code__c.length()):'';
             /*if(oppMap.get(app.Opportunity__c).Land_Lord_Records__r!=null && !oppMap.get(app.Opportunity__c).Land_Lord_Records__r.isEmpty()){
                 AppLLId.put(oppMap.get(app.Opportunity__c).Land_Lord_Records__r,app);
             }*/
             System.debug('====3'+oppMap.get(app.Opportunity__c).Account.Landlord_Account__c); 
             
             if(oppMap.get(app.Opportunity__c)!=null)
             app.if_Landlord_Account__c = oppMap.get(app.Opportunity__c).Account.Landlord_Account__c;  
             
             TOA_Product_Interest__c prd = TOA_Product_Interest__c.getInstance(opp.Product_Interest__c);
             system.debug('£££££££££££££'+prd);
             if(prd!= null && opp.Account.Sales_Subpatch__r.Appointment_Source__c == 'OFS' && opp.Account.Sales_Subpatch__r.OFS_Start_Date__c <= app.Start__c)     
             {
                system.debug('£££££££££££££'+opp.Account.Sales_Subpatch__r.Appointment_Source__c);
                system.debug('£££££££££££££'+opp.Account.Sales_Subpatch__r.OFS_Start_Date__c);
                
                app.OFS_Appointment__c = true;
                app.TOA_Duration__c = prd.Duration__c;
                string timeBand;
                if(app.Time_Band__c!=null)
                {
                    timeBand= app.Time_Band__c;
                }else
                {
                    app.adderror('Time Band is Required');
                    
                }
                
                SalesAppointment__c sp = SalesAppointment__c.getInstance(timeBand);
                if(trigger.isInsert)
                {
                    app.Start__c = Datetime.newInstance(app.Start__c.year(),app.Start__c.month(),app.Start__c.day(),integer.valueof(sp.Start_Time__c.split(':')[0]),integer.valueof(sp.Start_Time__c.split(':')[1]),0);
                    app.End__c = Datetime.newInstance(app.Start__c.year(),app.Start__c.month(),app.Start__c.day(),integer.valueof(sp.End_Time__c.split(':')[0]),integer.valueof(sp.End_Time__c.split(':')[1]),0);
                }
                if(!app.PushToOFS__c)
                {
                    if(app.OFS_Appointment__c && (trigger.isupdate && ((app.Start__c != trigger.oldmap.get(app.Id).Start__c )||( app.End__c != trigger.oldmap.get(app.Id).End__c))))
                    {
                        
                    }else if(trigger.isinsert)
                    {
                        app.SLA_Start__c = Datetime.newInstance(app.Start__c.year(),app.Start__c.month(),app.Start__c.day(),integer.valueof(sp.SLA_Start__c.split(':')[0]),integer.valueof(sp.SLA_Start__c.split(':')[1]),0);
                        app.SLA_End__c = Datetime.newInstance(app.Start__c.year(),app.Start__c.month(),app.Start__c.day(),integer.valueof(sp.SLA_End__c.split(':')[0]),integer.valueof(sp.SLA_End__c.split(':')[1]),0);
                    }    
                }
                
                if(app.Shorter_Time_Bands__c != null )
                {
                    list<string> band = app.Shorter_Time_Bands__c.split('-');
                    
                    app.SLA_Start__c = Datetime.newInstance(app.Start__c.year(),app.Start__c.month(),app.Start__c.day(),integer.valueof(band[0].split(':')[0]),integer.valueof(band[0].split(':')[1]),0);
                    app.SLA_End__c = Datetime.newInstance(app.Start__c.year(),app.Start__c.month(),app.Start__c.day(),integer.valueof(band[1].split(':')[0]),integer.valueof(band[1].split(':')[1]),0);
                } 
                
	             system.debug(' app.SLA_Start__c --->'+ app.SLA_Start__c);
	             system.debug(' app.SLA_Start__c --->'+ app.SLA_End__c);
	             if(app.SLA_Start__c!=null)
	             app.SLA_Start_Text__c = app.SLA_Start__c.format('YYYY-MM-dd kk:mm:ss');
	             
	             if(app.SLA_End__c!=null)
	             app.SLA_End_Text__c = app.SLA_End__c.format('YYYY-MM-dd kk:mm:ss');
                
             }else
             {
                app.OFS_Appointment__c = false;
             }
             
             
        }
         
        /*
        List<Landlord_record__c> ToBeUpdateLL = new List<Landlord_record__c>();        
        //for(Appointment__c app : oppIdApptMap.values())
        for(Landlord_Record__c l : AppLLId.keySet()) {
            l.Sales_Appointment__c = AppLLId.get(l).id;
            ToBeUpdateLL.add(l);           
        } 
        
        if(ToBeUpdateLL.size()>0 && !system.label.OFS_Integration_User.contains(userinfo.getUserid() ))
            update  ToBeUpdateLL;       
                
             
         
        for(Opportunity o: oppMap.values())
        {
            if(o.Account.Landlord_Account__c)
            {
                opAppId.put(o.AccountId,o.Id);
            } 
        }
          
        map<Id, List<Contact>> oppContact = new map<Id,list<Contact>>();
        
        list<string> contactTypes = new list<string>{'Landlord','Tenant','Multi-premise'};
        if(opAppId.keyset().size()>0)
        {
            for(Account a: [Select id, (Select id, Email,Preferred_Contact_Method__c,Salutation,FirstName,LastName,Contact_Type__c from Contacts where contact_type__c in: contactTypes) from Account where Id in:opAppId.keyset() ])
            {
                oppContact.put(opAppId.get(a.Id),a.Contacts );
            }
        }
        
        for(Appointment__c a: trigger.new)
        {
            if(oppContact.containskey(a.Opportunity__c))
            {
                for(Contact c: oppContact.get(a.Opportunity__c))
                {
                    if(c.Contact_Type__c == 'Tenant')
                    {
                        a.Tenants_Name__c = c.Salutation +' '+c.FirstName+' '+c.LastName;
                        a.Tenants_Email__c = c.Email;
                        a.Tenans_Prefferred_Con__c = c.Preferred_Contact_Method__c; 

                    }else if(c.Contact_Type__c == 'Landlord' || c.Contact_Type__c == 'Agent')
                    {
                        a.Landlords_Name__c = c.Salutation +' '+c.FirstName+' '+c.LastName;
                        a.Landlords_Email__c = c.Email;
                        a.Landlords_Prefferred_Con__c = c.Preferred_Contact_Method__c;

                    }else if(c.Contact_Type__c == 'Multi-premise' )
                    {
                        a.Landlords_Name__c = c.LastName;
                        a.Landlords_Email__c = c.Email;
                        a.Landlords_Prefferred_Con__c = c.Preferred_Contact_Method__c;

                    }
                    
                }
            }
        }*/
    }
    

     
     if(messages.size()>0)
     insert messages;
     /*
     mapids.addAll(salesmap.keySet());
     
     system.debug('mapids.addAll(salesmap.keySet()' + mapids);
     
     mapids.addAll(greendealmap.keySet());
     
     system.debug('mapids.addAll(greendealmap.keySet()' + mapids);
     */
  
/*
if (mapids.size()!=null && mapids.size()>0)
{

             
              List<Green_Deal_Reconsilliation__c> gdlist =[select id,CHI_UniqueId__c,Status__c,Opportunity__c,GDA_Name__c,GDA_Date__c,Vibrant__c,Sales_Appointment__c,Green_Deal_Appointment__c from Green_Deal_Reconsilliation__c where Opportunity__c in: mapids]; 
              
              system.debug('&&&&&&&gdlist'+gdlist);
              
                if ( gdlist.size()!= null && gdlist.size()>0)
                {
                            system.debug('&&&&&&&gdlist1'+gdlist);    
                                  
                           for(Green_Deal_Reconsilliation__c gd:gdlist)
                            {
                                     system.debug('&&&&&&&gdlist2'+gdlist);     
                                                                
                                      if(salesmap.containskey(gd.Opportunity__c))
                                      {
                                             
                                               if(salesmap.get(gd.Opportunity__c).Status__c == 'Appointed')
                                              {
                                                 
                                                  gd.Sales_Appointment__c=salesmap.get(gd.Opportunity__c).Id;
                                                  
                                              }
                                              else if(salesmap.get(gd.Opportunity__c).Status__c == 'Cancelled')
                                              {   
                                                  system.debug('salesmap.get(gd.Opportunity__c).Status__c'+salesmap.get(gd.Opportunity__c).Status__c );   
                                                  gd.Sales_Appointment__c=null;
                                                 
                                              }
                                             
                                      }
                                
                                      if(greendealmap.containskey(gd.Opportunity__c))
                                      {
                                           if(greendealmap.get(gd.Opportunity__c).Status__c == 'Appointed')
                                           {
                                              gd.Green_Deal_Appointment__c=greendealmap.get(gd.Opportunity__c).Id;                                           
                                              gd.GDA_Name__c= greendealmap.get(gd.Opportunity__c).Assigned_To_Name__c;
                                              gd.GDA_Date__c= greendealmap.get(gd.Opportunity__c).Visit_Date__c;
                                              gd.Vibrant__c='';
                                              
                                           }
                                       
                                      else if(greendealmap.get(gd.Opportunity__c).Status__c == 'Cancelled')
                                              { 
                                                 system.debug('greendealmap.get(gd.Opportunity__c).Status__c'+greendealmap.get(gd.Opportunity__c).Status__c );  
                                                  gd.Green_Deal_Appointment__c=null;
                                                  gd.GDA_Name__c= '';
                                                  gd.GDA_Date__c= null;
                                                  gd.Vibrant__c='';
                                              }
                          
                                        }
                          
                       }
                        
                  
                        system.debug('&&&&&&&update gdlist'+gdlist);   
            }
                    update gdlist;
                     
    }
*/ 

   if (!updatedAppts.isEmpty())
    {
    oppsToBeUpdated = [Select o.id,o.StageName,o.Number_of_Survey_Appointments__c, 
                                    o.Number_of_Sales_Appointments__c, o.First_Appointment_Date__c,
                                    o.Number_of_Appointed_Sales_Appointments__c,
                                    o.Number_of_Appointed_Survey_Appointments__c, 
                                    o.Number_of_Cancelled_Sales_Appointments__c,HistorySOHSA__c
                                    ,Commission_SO_HSA__c,Commission_SO_ApptDate__c, COMMISSION_SO_HSA_Payroll__c,HistorySOAppDate__c,
                                    o.Appointment_Attendee__c                                    
                                    from Opportunity o
                                    WHERE o.id IN :updatedAppts.keySet()]; 
    if(oppsToBeUpdated!=null){  
        if(oppsToBeUpdated.size()>0){                              
            for(Opportunity opp : oppsToBeUpdated){
                if(updatedAppts.containsKey(opp.id)){
                    if(updatedAppts.get(opp.id).Status__c == 'Appointed'){
                        opp.Unappointed_lead_reason__c = '';
                        opp.Prospect__c = false;
                        opp.Reason_Code__c = null;
                        opp.Override_Call_Back_Date__c = null;
                        opp.Call_Back_Date__c = null;
                        opp.Actual_Call_Back_Date__c = null;                      
                        Appointment__c relatedAppt = updatedAppts.get(opp.id);
                        system.debug('******'+opp.Commission_SO_HSA__c +'@@@'+relatedAppt.Assigned_To_Name__c);
                        
                        if(relatedAppt.Type__c == 'Sales' && opp.Commission_SO_HSA__c != relatedAppt.Assigned_To_Name__c && relatedAppt.Employee_BM_User__c == 'Yes')
                        {
                            opp.Commission_SO_HSA__c = relatedAppt.Assigned_To_Name__c;
                            opp.Commission_SO_ApptDate__c = relatedAppt.Visit_Date__c;
                            opp.COMMISSION_SO_HSA_Payroll__c = relatedAppt.Assigned_To_Payroll__c;
                            //opp.Sales_Advisor__r =  new People_Hirearchy__c(Pay_number__c = relatedAppt.Assigned_To_Payroll__c);
                        
                        }
                        opp.Appointment_Attendee__c = relatedAppt.Appointment_Attendee__c;                         
                    }
                }
            }
        } 
    } 
    System.debug('OppUpdOnApptInsOrUpd: size of oppsToBeUpdated is ' + oppsToBeUpdated.size());
    
    //Appointment__c updatedApp = null;
    
    if (!oppsToBeUpdated.isEmpty())
    {
        for(Opportunity opp : oppsToBeUpdated)
        {
            Appointment__c relatedAppt = updatedAppts.get(opp.id);
            system.debug('%%%%%%%Ashoks Debug----->'+relatedAppt);          
            if ((relatedAppt.Status__c=='Appointed' && System.Trigger.isInsert)
                    || (System.Trigger.isUpdate && Trigger.oldMap.get(relatedAppt.id).Status__c!='Appointed' && Trigger.oldMap.get(relatedAppt.id).Status__c!='Cancelled'))
            {
                opp.StageName='Appointed';
                // This field is updated to cover change for validating engineer CHI Leads.
                Opp.Customer_agreed_to_appointment__c = 'Yes';
                opp.Cancel_Todays_Appt_No_Other_Future_Appt__c=false;
                
                if (relatedAppt.Type__c=='Sales'|| relatedAppt.Type__c=='Priority')
                {   
                    if(opp.Number_of_Sales_Appointments__c==0 || opp.Number_of_Sales_Appointments__c== null)
                    {
                        // Check on this field - if it's populated, we don't want to overwrite
                        if(opp.First_Appointment_Date__c == null)
                            opp.First_Appointment_Date__c=Datetime.now();
                        opp.Number_of_Sales_Appointments__c=1;
                    }
                    else
                        opp.Number_of_Sales_Appointments__c += 1;
                    if(relatedAppt.Status__c == 'Appointed')                   
                      {    
                      //system.debug('8888888888888888888888outside the loop for add '+opp.Number_of_Appointed_Sales_Appointments__c );
                    if(opp.Number_of_Appointed_Sales_Appointments__c==0 || 
                                                    opp.Number_of_Appointed_Sales_Appointments__c== null) 
                                                    {
                                                    
                        opp.Number_of_Appointed_Sales_Appointments__c=1;
                        //system.debug('8888888888888888888888inside the loop for add - if'+opp.Number_of_Appointed_Sales_Appointments__c );
                        }    
                        
                    else
                    {
                        opp.Number_of_Appointed_Sales_Appointments__c+=1;
                        //system.debug('8888888888888888888888inside the loop for add - else'+opp.Number_of_Appointed_Sales_Appointments__c );
                        }
                     }
                                                
                    
                }
                /*
                else if(relatedAppt.Type__c=='Survey')
                {
                    if(opp.Number_of_Survey_Appointments__c==0 || opp.Number_of_Survey_Appointments__c==null)
                        opp.Number_of_Survey_Appointments__c=1;
                    else
                        opp.Number_of_Survey_Appointments__c+=1;
                    if(relatedAppt.Status__c == 'Appointed')                   
                    {    
                    if(opp.Number_of_Appointed_Survey_Appointments__c==0 || 
                                                    opp.Number_of_Appointed_Survey_Appointments__c== null)
                        opp.Number_of_Appointed_Survey_Appointments__c=1;   
                    else
                        opp.Number_of_Appointed_Survey_Appointments__c += 1;
                     }
                }*/
            }
            else if(System.Trigger.isUpdate && relatedAppt.Status__c=='Cancelled' 
                                    && Trigger.oldMap.get(relatedAppt.id).Status__c!='Cancelled')
            {
               
                if (relatedAppt.Type__c=='Sales')
                {       
                        if (opp.Number_of_Sales_Appointments__c > 0){ 
                            opp.Number_of_Sales_Appointments__c-=1;
                            
                                if(opp.Number_of_Cancelled_Sales_Appointments__c == null){
                                           opp.Number_of_Cancelled_Sales_Appointments__c = 0;}
                            opp.Number_of_Cancelled_Sales_Appointments__c+=1;
                        }
                        //system.debug('8888888888888888888888outside the loop'+opp.Number_of_Appointed_Sales_Appointments__c );
                        if (opp.Number_of_Appointed_Sales_Appointments__c > 0)
                        {
                             opp.Number_of_Appointed_Sales_Appointments__c-=1;
                             //system.debug('8888888888888888888888inside the loop'+opp.Number_of_Appointed_Sales_Appointments__c );
                             }
                        // Sales Opportunity change start: 25/10/2012
                     
                        if((opp.Commission_SO_HSA__c == relatedAppt.Assigned_To_Name__c) && (opp.Commission_SO_ApptDate__c == relatedAppt.Visit_Date__c) && (relatedAppt.Primary_Cancellation_Reason__c == 'Customer Request Direct' || relatedAppt.Primary_Cancellation_Reason__c =='Cancelled - Automatic Rearrange' 
                        || relatedAppt.Primary_Cancellation_Reason__c =='HA Availability' || relatedAppt.Primary_Cancellation_Reason__c == 'Re-scheduled Appointment') )
                        {
                            if(relatedAppt.Visit_Date__c>=system.today())
                            { 
                                //system.debug('@@@@opp.Commission_SO_ApptDate__c'+opp.Commission_SO_ApptDate__c);
                                //system.debug('@@@@system.today()'+system.today());
                            if(opp.HistorySOHSA__c == null && opp.HistorySOAppDate__c == null)
                            {
                                opp.Commission_SO_HSA__c = '';
                                opp.Commission_SO_ApptDate__c = null;
                                opp.COMMISSION_SO_HSA_Payroll__c = '';
                                opp.HistorySOHSA__c= '';
                                opp.HistorySOAppDate__c =null;
                            }
                            else
                            {
                                List<String> HSADetails =  opp.HistorySOHSA__c.split('-');
                                if(HSADetails!= null && HSADetails.size()>=2)
                                {
                                    opp.Commission_SO_HSA__c = HSADetails[0];
                                    opp.COMMISSION_SO_HSA_Payroll__c = HSADetails[1];
                                    opp.Commission_SO_ApptDate__c = opp.HistorySOAppDate__c;
                                    opp.HistorySOHSA__c= '';
                                    opp.HistorySOAppDate__c =null;
                                }
                            }
                            }
                        }
                        else if((opp.Commission_SO_HSA__c == relatedAppt.Assigned_To_Name__c) && (opp.Commission_SO_ApptDate__c == relatedAppt.Visit_Date__c) && (relatedAppt.Primary_Cancellation_Reason__c != 'Customer Request Direct' || relatedAppt.Primary_Cancellation_Reason__c !='Cancelled - Automatic Rearrange' 
                        || relatedAppt.Primary_Cancellation_Reason__c !='HA Availability' || relatedAppt.Primary_Cancellation_Reason__c != 'Re-scheduled Appointment'))
                        {
                            opp.HistorySOHSA__c = opp.Commission_SO_HSA__c + '-'+opp.COMMISSION_SO_HSA_Payroll__c;
                            opp.HistorySOAppDate__c = relatedAppt.Visit_Date__c;
                        }
                        
                        
                    // Sales Opportunity change end.
                }  
                /*
                else if(relatedAppt.Type__c=='Survey')
                {
                        if (opp.Number_of_Appointed_Survey_Appointments__c > 0)
                        opp.Number_of_Survey_Appointments__c-=1;
                        if (opp.Number_of_Appointed_Survey_Appointments__c > 0)
                        opp.Number_of_Appointed_Survey_Appointments__c-=1;
                }   
                            
                    if (opp.Number_of_Appointed_Survey_Appointments__c==0 &&
                                opp.Number_of_Appointed_Sales_Appointments__c==0)
                    {               
                        opp.StageName='Active';
                        
                        if(Datetime.valueOf(relatedAppt.Start__c).isSameDay(Datetime.now()))
                            opp.Cancel_Todays_Appt_No_Other_Future_Appt__c=true;
                    }
                */    
                //if no other active appts exist for the opp, set StageName to 'Active'
            }//else if - cancelled appt
            else if(System.Trigger.isUpdate && relatedAppt.Status__c=='Happened' 
                                    && Trigger.oldMap.get(relatedAppt.id).Status__c=='Appointed')
            {
                
                if (relatedAppt.Type__c=='Sales' && opp.Number_of_Sales_Appointments__c > 0) 
                      opp.Number_of_Appointed_Sales_Appointments__c=opp.Number_of_Appointed_Sales_Appointments__c-1;
                    
                else if(relatedAppt.Type__c=='Survey' && opp.Number_of_Appointed_Survey_Appointments__c > 0)
                    opp.Number_of_Appointed_Survey_Appointments__c=opp.Number_of_Appointed_Survey_Appointments__c-1;
                
            }//else if - happened appt
             
        }//for - iterate over opportunities to be updated
       
        
    }//if there are opportunites to be process  
    }
    if(SO_List_Opp.size()>0)
    oppsToBeUpdated.addall(SO_List_Opp);
    Lock.triggerUpdatingOpps = true;
    if (!oppsToBeUpdated.isEmpty())
    {
        set<ID> oppset = new set<ID>();
        list<Opportunity> finalList  = new list<Opportunity>();
        for(Opportunity o: oppsToBeUpdated)
        {
            if(!oppset.contains(o.Id))
            {
                finalList.add(o);
                oppset.add(o.Id);
            }
            
        }
       
        Database.update(finalList);
    }    
    Lock.triggerUpdatingOpps = false;
        if(trigger.isInsert)
        cls_IsRun.setIsAppInsertUpdate();

}