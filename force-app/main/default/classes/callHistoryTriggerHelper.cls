/*
Author: Ashok 
Date: 18/06/2015
Description: This is a helper class fot the trrigger. This class pulls the contact , employee related to the calling number & associates with appropriate 
Contact or empolyee records. 

*/

public with sharing class callHistoryTriggerHelper {
    
    Public static Map<Id, Id> AccOppMap = new Map<Id, Id>();
    public static void processBeforeInsert(list<Call_History__c> callHistoryList, map<id, Call_History__c> oldMap)
    {
        set<string> phoneNumberList = new set<string>();
        list<string> emplanList = new list<string>();
        map<string , list<Call_History__c>> empLanCallHistoryMap = new map<string , list<Call_History__c>>();
        map<string, list<Call_History__c>> phoneCallHistoryMap = new map<string, list<Call_History__c>>();
        
            
        for(Call_History__c c: callHistoryList)
        {
            
            if(c.Type__c != 'Portal')
            {
            if(c.Phone_Num__c!=null && c.Phone_Num__c != '' && (c.Recalculate__c == true || trigger.isInsert || (trigger.isUpdate && oldMap.get(c.Id).Phone_Num__c != c.Phone_Num__c)))
            {
                
                string phn = c.Phone_Num__c;
                if(c.Phone_Num__c.startsWith('9') )
                {
                    phn = c.Phone_Num__c.substring(1,c.Phone_Num__c.length());
                }
                if(c.Phone_Num__c.startsWith('+44') &&  c.Phone_Num__c.length()>10)
                {
                     phn = '0'+c.Phone_Num__c.substring(3,c.Phone_Num__c.length());
                }else if(c.Phone_Num__c.startsWith('+44') )
                {
                     phn = c.Phone_Num__c.substring(3,c.Phone_Num__c.length());
                }
                if(c.phone_Num__c.length() == 10){ //if phone Num is of 10 digit add '0'
                     phn = '0'+c.Phone_Num__c;
                }
                if(c.Phone_Num__c.startsWith('0') && c.Phone_Num__c.length() == 7){ //condition For ShortDial && CISCO Integration no(Max length: 6 with out '0')
                     phn = c.Phone_Num__c.substring(1,c.Phone_Num__c.length());
                }
                if(c.Phone_Num__c.startsWith('0') && c.Phone_Num__c.length() == 6){ //condition For Ext Number(Max length: 5 with out '0')
                     phn = c.Phone_Num__c.substring(1,c.Phone_Num__c.length());
                }
                
                
                c.Phone_Num__c = phn;
                phoneNumberList.add(phn);
                if(phoneCallHistoryMap.containskey(phn))
                phoneCallHistoryMap.get(phn).add(c);
                else
                phoneCallHistoryMap.put(phn, new list<Call_History__c>{c});
            }
            if(c.Emp_LAN_Id__c!=null && c.Emp_LAN_Id__c!= '' && (c.Recalculate__c == true || trigger.isInsert || (trigger.isUpdate && oldMap.get(c.Id).Emp_LAN_Id__c != c.Emp_LAN_Id__c)))
            {
                c.Emp_LAN_Id__c = c.Emp_LAN_Id__c.tolowerCase();
                emplanList.add(c.Emp_LAN_Id__c);
                if(empLanCallHistoryMap.containskey(c.Emp_LAN_Id__c))
                empLanCallHistoryMap.get(c.Emp_LAN_Id__c).add(c);
                else
                empLanCallHistoryMap.put(c.Emp_LAN_Id__c, new list<Call_History__c>{c});
            }
            }
        }
        system.debug(LoggingLevel.INFO,'phoneCallHistoryMap-->'+phoneCallHistoryMap.keyset());
        system.debug(LoggingLevel.INFO,'phoneCallHistoryMap-->'+empLanCallHistoryMap.keyset());
        integer i = 0;
        Map<string, Employee__c> empLanIdMap = new Map<string, Employee__c>();
        if(empLanCallHistoryMap.size()>0)
        {
            string str1='';
            for(string s: empLanCallHistoryMap.keyset())
            {   
                str1+= s+' OR';
            }
            String EmpLanIdSearch = str1.removeEnd('OR');
            for(Employee__c emp : (List<Employee__c>)[FIND :EmpLanIdSearch IN All FIELDS RETURNING Employee__C( id, Lan_Id__c where inactive__c=false) ][0])
            {
                    empLanIdMap.put(emp.Lan_Id__c.toLowerCase() , emp);
            }
            
        }
        Map<String, Employee__c> phoneEmployeeMap = new Map<String, Employee__c>();
        Map<string, Contact> contactPhoneMap = new Map<string, Contact>();
        Map<String, String> matFieldMap = new Map<String, String>();
        Map<Id,String> OppStageMap;
        //Map<Id, Id> AccOppMap = new Map<Id, Id>();
        date lastyear = system.today().adddays(-365); 
        
        if(phoneCallHistoryMap.size()>0)
        {
            set<id> accids = new set<id>();
            string str='';
            for(string s: phoneCallHistoryMap.keyset())
            {   
                str+= s+' OR';
            }
            String searchString = str.removeEnd('OR');
                   
                //if(i<=20)
                //{
                list<List<sobject>> sOBjectList = [FIND :searchString IN All FIELDS RETURNING Contact (id,AccountID,MobilePhone, HomePhone, OtherPhone ORDER BY CreatedDate Desc), Employee__C ( id,Phone_No__c,Short_Dial__c,Short_Dial_text__c,ManPower_Telephony_PIN__c,Cisco_UC_Integration_No_CUCI__c,Extension_Number__c where inactive__c=false)];
                                
                if(sOBjectList.size()>0)
                {
                    List<Contact> conSearchList = (List<Contact>)sOBjectList[0]; 
                    for(Contact c : conSearchList)
                    {
                        string phone;
                        string matchingField;
                        if(c.MobilePhone!=null && c.MobilePhone!= '' && phoneCallHistoryMap.containskey(c.MobilePhone)){
                        phone = c.MobilePhone;
                        matchingField = 'Contact - MobilePhone';
                        }
                        else if(c.HomePhone!=null && c.HomePhone!= '' && phoneCallHistoryMap.containskey(c.HomePhone)){
                        phone = c.HomePhone;
                        matchingField = 'Contact - HomePhone';
                        }
                        else if(c.OtherPhone!=null && c.OtherPhone!= '' && phoneCallHistoryMap.containskey(c.OtherPhone)){
                        phone = c.OtherPhone;
                        matchingField = 'Contact - OtherPhone';
                        }
                        
                        if(!contactPhoneMap.containskey(phone)){
                        contactPhoneMap.put(phone, c);
                        matFieldMap.put(phone, matchingField);
                        }
                        accids.add(c.Accountid);
                    }
                }
               
                if(sOBjectList.size()>1)
                {
                    List<Employee__c> employeeList = (List<Employee__c>)sOBjectList[1];
                   
                    
                    for(Employee__c e: employeeList)
                    {
                        phoneEmployeeMap.put(e.Phone_No__c , e);
                        phoneEmployeeMap.put(e.Short_Dial__c , e);
                        phoneEmployeeMap.put(e.ManPower_Telephony_PIN__c , e); 
                        phoneEmployeeMap.put(string.valueof(e.Extension_Number__c),e);
                        phoneEmployeeMap.put(e.Cisco_UC_Integration_No_CUCI__c,e);
                        matFieldMap.put(e.Phone_No__c, 'Employee - Phone');
                        matFieldMap.put(e.Short_Dial__c , 'Employee - Short Dial');
                        matFieldMap.put(e.ManPower_Telephony_PIN__c , 'Employee - Telephone PIN');
                        matFieldMap.put(string.valueof(e.Extension_Number__c), 'Employee - Ext Number');
                        matFieldMap.put(e.Cisco_UC_Integration_No_CUCI__c, 'Employee - CUCI Number');
                    }
                }
                
                if(accids.size()>0){
                  list<opportunity> oppList = [select id,name,StageName,accountid,(select id,name,status__c,Visit_Date__c from Appointments__r where Status__c!= 'Cancelled' order by Start__c Desc),(select id,name,Stage__c, Is_Primary__c, CreatedDate from BigMachines_Quotes__r order by Is_Primary__c , CreatedDate Desc),(select id,name,Is_Downtime_Job__c ,Is_Remedial_Job__c,Status__c from jobs__r Where Is_Remedial_Job__c = false and Is_Downtime_Job__c = false order by Createddate Desc) from opportunity where Accountid=:Accids order by CreatedDate Desc];
                  /*list<account> acc = [select id,name,(select id,name,StageName from Opportunities order by CreatedDate desc Limit 1) from Account where id=:accids];
                  for(account a: acc){
                    if(a.Opportunities!= null){
                      AccOppMap.put(a.id,a.Opportunities[0].id);
                    }
                  }*/
                   
                   OppStageMap = ProcessStageId(oppList); // Map Opportunity and Portal Stage
                }
                
               // i++;
               // }
                
           // }
            
           
        }
         system.debug('------------>'+contactPhoneMap); 
        for(Call_History__c c: callHistoryList)
        {
        	if(c.Type__c != 'Portal')
        	{
            system.debug('In For LOOP'+c);
            
            if(c.Emp_LAN_Id__c!=null && empLanIdMap.containskey(c.Emp_LAN_Id__c))
            {
                system.debug('In 1st If'+c);
                c.Employee__c = empLanIdMap.get(c.Emp_LAN_Id__c).Id;
            }
            
            if(c.Phone_Num__c!=null )
            {
                system.debug('In 2nd If'+c);
                if(contactPhoneMap.containsKey(c.Phone_Num__c)){
                c.Contact__c = contactPhoneMap.get(c.Phone_Num__c).id;
                c.Mobile_Employee__c = null;
                c.Matching_Field__c = matFieldMap.get(c.Phone_Num__c);
                c.Chi_lead__c = AccOppMap.get(contactPhoneMap.get(c.Phone_Num__c).Accountid);
                
                if(trigger.isInsert && !c.Recalculate__c)
                c.Portal_Stage__c = (OppStageMap!=null)?OppStageMap.get(AccOppMap.get(contactPhoneMap.get(c.Phone_Num__c).Accountid)):null;
                
                system.debug('In 2.1nd If'+c);
                }
                else if(phoneEmployeeMap.containskey(c.Phone_Num__c)){
                c.Mobile_Employee__c = phoneEmployeeMap.get(c.Phone_Num__c).Id;
                c.Contact__c = null;
                c.Matching_Field__c = matFieldMap.get(c.Phone_Num__c);
                c.chi_lead__c = null;
                c.Portal_Stage__c = null;
                system.debug('In 2.2nd If'+c);
                }else
                {
                    c.Contact__c = null;
                    c.Mobile_Employee__c = null;
                    c.Matching_Field__c = null;
                    c.Chi_Lead__c = null;
                    system.debug('In 2.23nd If'+c);
                }
            }else
            {
                c.Mobile_Employee__c = null;
                c.Contact__c = null;
                c.Matching_Field__c = null;
                c.Chi_Lead__c = null;
                system.debug('In3rd If'+c);
            }
            
            
        } 
        AccOppMap.clear();
        //List<List<SObject>> searchList = [FIND (phoneCallHistoryMap.keyset()) IN ALL FIELDS RETURNING  Contact, Employee__c()];
        }
    }
    
    Private static map<id,string> ProcessStageId(List<opportunity> oppList){
       
       map<Id,string> OppStageMap = new map<Id,String>();
       if(oppList.size() >0){
         //list<opportunity> oppList = [select id,name,StageName,(select id,name,status__c,Visit_Date__c from Appointments__r where Status__c!= 'Cancelled' order by Start__c ASC),(select id,name,Stage__c, Is_Primary__c, CreatedDate from BigMachines_Quotes__r order by Is_Primary__c , CreatedDate asc),(select id,name,Is_Downtime_Job__c ,Is_Remedial_Job__c,Status__c from jobs__r Where Is_Remedial_Job__c = false and Is_Downtime_Job__c = false) from opportunity where id=:oppIds];
         for(opportunity o: oppList){
           string stageId;
           if(!AccOppMap.containskey(o.Accountid))
           AccOppMap.put(o.AccountId,o.id);
           
           if(o.StageName!= 'Closed Lost' && o.StageName!= 'Expired'){
             stageId = '10.0';
             OppStageMap.put(o.id,stageId);
           }
           //Jobs
           if(o.Jobs__r.size()>0){
             for(Job__c j: o.Jobs__r){
                 if(j.Status__c == 'Pending'){
                     StageId= '40.1';
                     OppStageMap.put(o.id,stageId);
                 }else if(j.Status__c == 'Planned' || j.Status__c == 'Allocated'){
                     StageId= '40.2';
                     OppStageMap.put(o.id,stageId);
                 }else if(j.Status__c == 'Installed'){
                     StageId= '50.0';
                     OppStageMap.put(o.id,stageId);
                 }else if(j.Status__c == 'Suspended'){
                     StageId = '40.5';
                     OppStageMap.put(o.id,stageId);
                 }
             }
           }
           //Quotes
           else if(o.BigMachines_Quotes__r.size()>0)
           {
              for(Bigmachines_Quote__c b: o.BigMachines_Quotes__r){
                     StageId= '30.2';
                     OppStageMap.put(o.id,stageId);   
                     if(!b.Is_Primary__c)
                     { 
                       StageId= '30.1';
                       OppStageMap.put(o.id,stageId);
                       break;
                     }
               }
           }
           //Appointments
           else if(o.Appointments__r.size()>0){
              for(Appointment__c a : o.Appointments__r){
                  if(a.Status__c == 'Appointed' && a.Visit_Date__c>= system.today()){
                            // Future Appointed leads.
                            StageId= '20.0';
                            OppStageMap.put(o.id,stageId);
                            break;         
                  }else {
                     StageId= '20.1';
                     OppStageMap.put(o.id,stageId);
                  }
               }
           }
           
       }
    }
    return OppStageMap;  
  }

}