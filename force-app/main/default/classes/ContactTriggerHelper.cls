public with sharing class ContactTriggerHelper {
    
    public static void methodAfterInsert(list<Contact> newList, map<Id,Contact> newMap)
    {
        map<string, contact> contactMap = new map<String, contact>();
    
        for(Contact c:newList)
        {
            if(c.MobilePhone!= null && c.MobilePhone!= '')
            {
                contactMap.put(c.MobilePhone,c);
            }
            if(c.Homephone!= null && c.Homephone!= '')
            {
                contactMap.put(c.Homephone,c);
            }
            if(c.OtherPhone!= null && c.OtherPhone!= '')
            {
                contactMap.put(c.OtherPhone,c);
            }
        }
        if(contactMap.size()>0)
        processCallhistory(contactMap, null);
    }
    
    public static void methodAfterUpdate(list<Contact> newList, map<Id,Contact> newMap, list<Contact> oldList, map<id, Contact> oldMap)
    {
        map<string, contact> contactMap = new map<String, contact>();
        map<string, contact> oldContactMap = new map<String, contact>();
        for(Contact c:newList)
        {
            if( c.MobilePhone!= oldMap.get(c.Id).MobilePhone)
            {
                if(c.MobilePhone!= null && c.MobilePhone!= '')
                contactMap.put(c.MobilePhone,c);
                if(oldMap.get(c.Id).MobilePhone!= null && oldMap.get(c.Id).MobilePhone!= '')
                oldContactMap.put(oldMap.get(c.Id).MobilePhone,c);
            }
            if(c.Homephone!= oldMap.get(c.Id).Homephone)
            {
                if(c.Homephone!= null && c.Homephone!= '')
                contactMap.put(c.Homephone,c);
                if(oldMap.get(c.Id).Homephone!= null && oldMap.get(c.Id).Homephone!= '')
                oldContactMap.put(oldMap.get(c.Id).Homephone,c);
            }
            if(c.OtherPhone!= oldMap.get(c.Id).OtherPhone )
            {
                if(c.OtherPhone!= null && c.OtherPhone!= '' )
                contactMap.put(c.OtherPhone,c);
                if(oldMap.get(c.Id).OtherPhone!= null && oldMap.get(c.Id).OtherPhone!= '')
                oldContactMap.put(oldMap.get(c.Id).OtherPhone,c);
            }
        }
        if(contactMap.size()>0)
        processCallhistory(contactMap, oldContactMap);
    }
    
    public Static void processCallhistory (map<string, contact> contactMap, map<string, contact> oldContactMap)
    {
        
        List<Call_History__c> updateHistory = new List<Call_History__c>();
        set<id> finalid = new set<id>();
        string str='';
        for(string s: contactMap.keyset())
        {
           str+= s+' OR'; 
        }
        String searchString = str.removeEnd('OR');
         
          
                updateHistory = (List<Call_History__c>)[FIND :searchString IN Phone FIELDS RETURNING Call_History__c (id, Phone_Num__c,Contact__c,Mobile_Employee__c)][0];
            
                for(Call_History__c c: updateHistory)
                {
                    if(c.Contact__c == null && c.Mobile_Employee__c == null)
                    c.Contact__c = contactMap.containskey(c.Phone_Num__c)? contactMap.get(c.Phone_Num__c).Id:null;
                    
                }
              
        
        if(oldContactMap!=null && oldContactMap.size()>0)
        {
            string str1='';
            for(string s: oldContactMap.keyset())
            {
                str1+= s+' OR';  
            }
            String searchString1 = str1.removeEnd('OR');
                
                    List<Call_History__c> TEMPupdateHistory = (List<Call_History__c>)[FIND :searchString1 IN Phone FIELDS RETURNING Call_History__c (id )][0];
                
                    for(Call_History__c c: TEMPupdateHistory)
                    {
                        c.Contact__c = null;
                        if(!finalId.contains(c.id))
                        {
                            updateHistory.add(c);
                            finalId.add(c.Id);
                        }
                        //updateHistory.add(c);
                    } 
                  
            
        }
        
        if(updateHistory.size()>0)
        update UpdateHistory;
       
    }

}