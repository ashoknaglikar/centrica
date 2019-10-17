public with sharing class EmployeeTriggerHelper {
    
    public static void processBeforeInsert(list<Employee__c> newList, Map<Id,Employee__c> newMap)
    {
        tieOldCallHistorytoEmp(newList, new Map<Id,Employee__c>{});
    }
    
    public static void processBeforeUpdate(list<Employee__c> newList, Map<Id,Employee__c> newMap, list<Employee__c> oldList, Map<Id,Employee__c> oldMap)
    {
        tieOldCallHistorytoEmp(newList, oldMap);
    }
    
    
    public static void tieOldCallHistorytoEmp(list<Employee__c> empList,  Map<Id,Employee__c> oldMap)
    { 
        Map<string,Employee__c> newPhoneEmpMap = new Map<string,Employee__c>();
        Map<string,Employee__c> newLanIdEmpMap = new Map<string,Employee__c>();
        Map<string,Employee__c> oldPhoneEmpMap = new Map<string,Employee__c>();
        Map<string,Employee__c> oldLanIdEmpMap = new Map<string,Employee__c>();
        
        for(Employee__c emp : empList)
        {
            if((emp.Phone_No__c != null && emp.Phone_No__c != '') && (trigger.isInsert || (trigger.isUpdate && oldmap.containskey(emp.Id) && (oldmap.get(emp.Id).Phone_No__c != emp.Phone_No__c))))
            {
                newPhoneEmpMap.put(emp.Phone_No__c, emp);
                
            } 
            if(trigger.isupdate && oldmap.get(emp.Id).Phone_No__c!=null && oldmap.get(emp.Id).Phone_No__c!= emp.Phone_No__c)
            {
                oldPhoneEmpMap.put(oldmap.get(emp.Id).Phone_No__c, oldmap.get(emp.Id));
            }
            
            if((emp.Short_Dial__c != null && emp.Short_Dial__c != '') && (trigger.isInsert || (trigger.isUpdate && oldmap.containskey(emp.Id) && (oldmap.get(emp.Id).Short_Dial__c != emp.Short_Dial__c))))
            {
                newPhoneEmpMap.put(emp.Short_Dial__c, emp);
            }
            if(trigger.isupdate && oldmap.get(emp.Id).Short_Dial__c!=null && oldmap.get(emp.Id).Short_Dial__c!= emp.Short_Dial__c)
            {
                oldPhoneEmpMap.put(oldmap.get(emp.Id).Short_Dial__c, oldmap.get(emp.Id));
            }
            
            if((emp.Contact_Phone_Number__c != null && emp.Contact_Phone_Number__c != '') && (trigger.isInsert || (trigger.isUpdate && oldmap.containskey(emp.Id) && (oldmap.get(emp.Id).Contact_Phone_Number__c != emp.Contact_Phone_Number__c))))
            {
                newPhoneEmpMap.put(emp.Contact_Phone_Number__c, emp);
            }
            if(trigger.isupdate && oldmap.get(emp.Id).Contact_Phone_Number__c!=null && oldmap.get(emp.Id).Contact_Phone_Number__c!= emp.Contact_Phone_Number__c)
            {
                oldPhoneEmpMap.put(oldmap.get(emp.Id).Contact_Phone_Number__c, oldmap.get(emp.Id));
            }
            
            if((emp.Lan_Id__c != null && emp.Lan_Id__c != '') && (trigger.isInsert || (trigger.isUpdate  && oldmap.containskey(emp.Id) && (oldmap.get(emp.Id).Lan_Id__c != emp.Lan_Id__c))))
            {
                newLanIdEmpMap.put(emp.Lan_Id__c, emp);
            }
            
            if(trigger.isupdate && oldmap.get(emp.Id).Lan_Id__c!=null && oldmap.get(emp.Id).Lan_Id__c!= emp.Lan_Id__c)
            {
                oldLanIdEmpMap.put(oldmap.get(emp.Id).Lan_Id__c, oldmap.get(emp.Id));
            }
            
            
        }
        
        set<Call_History__c> finalUpdatelist = new set<Call_History__c>();
        set<id> finalId = new set<ID>();
        //integer i= 1;
        if(newPhoneEmpMap.size()>0)
        {
            string str = '';
            for(string s: newPhoneEmpMap.keyset())
            {
                str+= s+' OR';
            }
            String searchString = str.removeEnd('OR');    
                 //if(i<=20)
                //{
                    list<Call_History__c> updatingList = (List<Call_History__c>)[FIND :searchString IN Phone FIELDS RETURNING Call_History__c (id, Phone_Num__c  )][0];
                    //list<Call_History__c> updatingList = [Select id, Phone_Num__c from Call_History__c  where Phone_Num__c in :newPhoneEmpMap.keyset() and Mobile_Employee__c = null ];
                    
                    for(Call_History__c c:  updatingList)
                    {
                        if(newPhoneEmpMap.containsKey(c.Phone_Num__c))
                        c.Mobile_Employee__c = newPhoneEmpMap.get(c.Phone_Num__c).Id;
                        if(!finalId.contains(c.id))
                        {
                            finalUpdatelist.add(c);
                            finalId.add(c.Id);
                        }
                    }
                    
                   // i++;
                //}
            //}
            
        }
        
        if(oldPhoneEmpMap.size()>0)
        {
            String str1 = '';
            //changed By Ashok G
            for(string s: oldPhoneEmpMap.keyset())
            {
              str1+= s+' OR';
            }
            
            set<id> empids = new set<id>();
            for(Employee__c emp: oldPhoneEmpMap.values()){
               empids.add(emp.id);
            }
            
            String searchString1 = str1.removeEnd('OR'); 
                 //if(i<=20)
                //{
                    list<Call_History__c> updatingList = (List<Call_History__c>)[FIND :searchString1 IN Phone FIELDS RETURNING Call_History__c (id, Phone_Num__c where Mobile_Employee__c = :empids)][0];
                    //list<Call_History__c> updatingList = (List<Call_History__c>)[FIND :searchString1 IN Phone FIELDS RETURNING Call_History__c (id, Phone_Num__c where Mobile_Employee__c = :oldPhoneEmpMap.get(s).id)][0];

                    //list<Call_History__c> updatingList = [Select id, Phone_Num__c from Call_History__c  where Phone_Num__c in :oldPhoneEmpMap.keyset() and Mobile_Employee__c NOT IN :oldPhoneEmpMap.keyset()];
                
                    for(Call_History__c c:  updatingList)
                    {
                        
                        c.Mobile_Employee__c = null;
                        if(!finalId.contains(c.id))
                        {
                            finalUpdatelist.add(c);
                            finalId.add(c.Id);
                        }
                    }
                    //i++;
                //}
            //}  
        }
        
        if(newLanIdEmpMap.size()>0)
        {
            string str = '';
            for(string s: newLanIdEmpMap.keyset())
            {
                str += s+' OR';
            }    
            String searchString = str.removeEnd('OR');
                //if(i<=20)
                //{
                    list<Call_History__c> updatingList = (List<Call_History__c>)[FIND :searchString IN ALL FIELDS RETURNING Call_History__c (id, Emp_LAN_Id__c )][0];
                    //list<Call_History__c> updatingList = [Select id, Emp_LAN_Id__c from Call_History__c  where Emp_LAN_Id__c in :newLanIdEmpMap.keyset() and Employee__c = null ];
            
                    for(Call_History__c c:  updatingList)
                    {
                        if(newLanIdEmpMap.containsKey(c.Emp_LAN_Id__c))
                        c.Employee__c = newLanIdEmpMap.get(c.Emp_LAN_Id__c).Id;
                        if(!finalId.contains(c.id))
                        {
                            finalUpdatelist.add(c);
                            finalId.add(c.Id);
                        }
                    }
                    //i++;
                    
                //}
            //}  
            
            
        }
        
        if(oldLanIdEmpMap.size()>0)
        {
            string str = '';
            for(string s: oldLanIdEmpMap.keyset())
            {
               str += s+' OR';
            }
            set<id> empids = new set<id>();
            for(Employee__c emp: oldLanIDEmpMap.values()){
               empids.add(emp.id);
            }
            String searchString = str.removeEnd('OR');
                //if(i<=20)
                //{
                    list<Call_History__c> updatingList = (List<Call_History__c>)[FIND :searchString IN ALL FIELDS RETURNING Call_History__c (id, Emp_LAN_Id__c where Employee__c = :empids)][0];

                    //list<Call_History__c> updatingList = (List<Call_History__c>)[FIND :s IN ALL FIELDS RETURNING Call_History__c (id, Emp_LAN_Id__c where Employee__c = :oldLanIdEmpMap.get(s).Id)][0];
                    
                    //list<Call_History__c> updatingList = [Select id, Emp_LAN_Id__c from Call_History__c  where Emp_LAN_Id__c in :oldLanIdEmpMap.keyset() and Employee__r.Lan_Id__c NOT IN :oldLanIdEmpMap.keyset() ];
            
                    for(Call_History__c c:  updatingList)
                    {
                        
                        c.Employee__c =null;
                        if(!finalId.contains(c.id))
                        {
                            finalUpdatelist.add(c);
                            finalId.add(c.Id);
                        }
                    }
                    //i++;
                    
               // }
            //}  
            
            
        }
        
        if(finalUpdatelist.size()>0)
        {
            list<Call_history__c> temp =  new list<Call_history__c>();
            temp.addall(finalUpdatelist);
            update  temp;
        }
    }

}