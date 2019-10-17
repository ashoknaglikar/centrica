/* The main purpose of this class is to lock and unlock the multiple weeks ,contains employee in it
so that it shouldn't be book by another user */

global class WeekLockWebService{ 

webservice static String WeekLock(String weekId)
  
   { 
       List<Week__c> weeksToBeLocked = new List<Week__c>();
       List<Id> employeeWithinWeeks = new List<Id>();
       Week_Lock__c weekLock = new Week_Lock__c ();
       List<Employee_Week_Lock__c> ewl = new List<Employee_Week_Lock__c>();
       List<Id> groupwithinweeks = new List<Id>(); 
       
   
weekLock = [Select End_Date__c,Locking_User__c,Start_Date__c,Status__c,(Select Employee__c,Group__c from Employee_Week_Lock__r) from Week_Lock__c 
                   Where id= :weekId];
                        
            for(Employee_Week_Lock__c emp:weekLock.Employee_Week_Lock__r)
               {
                  if(emp.Group__c!= null)
                    { 
                      groupwithinweeks.add(emp.Group__c );
                          }
                          else
                          {
                             employeeWithinWeeks.add(emp.Employee__c);
                          }
                               emp.Status__c = 'Locked';
               }

  if(groupwithinweeks.size()>0)
              {         
                 list<Employee_Group__c> groupObj =  [Select Employee__c From Employee_Group__c
                                                                  where  Group__c in :groupwithinweeks];
                              
                              for(Employee_Group__c gp:groupObj)
                                  {
                                     employeeWithinWeeks.add(gp.Employee__c);
                 
                                  }
              } 
                     
 for(Week__c week:[Select Week_Commencing__c,Locking_User__c,Locking_User__r.Name,Employee__c,Employee__r.Name  from Week__c  where Employee__c in :employeeWithinWeeks and Week_Commencing__c>=:weekLock.Start_Date__c  and Week_Commencing__c<=:weekLock.End_Date__c ])
          
            {
               if(week.Locking_User__c!=null)
            {
                return('Error: This employee '+week.Employee__r.Name+' cannot be locked, as its locked by '+week.Locking_User__r.Name+'.');
            }
                week.Locking_User__c = weekLock.Locking_User__c;
                weeksToBeLocked.add(week);
       
            }
            
  try
      {
        update weeksToBeLocked;
        weekLock.Status__c = 'Locked';
        update weekLock;
        update weekLock.Employee_Week_Lock__r;
        return('Sucessfully Locked.');
        
      }
      
       catch (Exception e)
       {
         return('Exception Occured:'+e.getMessage());
       }
       
    }        
                     
  /*-----Locking of Employees and Group of Employees within weeks selected Ends here-----*/
         
        
 webservice static void WeekunLock(String weekId) 
            
    {
   
         List<Week__c> weeksToBeLocked = new List<Week__c>();
         List<Id> employeeWithinWeeks = new List<Id>();
         Week_Lock__c weekLock =new Week_Lock__c ();
         List<Id> groupwithinweeks = new List<Id>(); 
         List<Employee_Week_Lock__c> ewl = new List<Employee_Week_Lock__c>();
              
 weekLock = [Select End_Date__c,Locking_User__c,Start_Date__c,Status__c,(Select Employee__c,Group__c from Employee_Week_Lock__r) from Week_Lock__c 
                     Where id= :weekId];
                          
   for(Employee_Week_Lock__c emp:weekLock.Employee_Week_Lock__r)
   
         {      
             if(emp.Group__c!= null)
             
                         { 
                            groupwithinweeks.add(emp.Group__c );

                          }
              else
                      {
                        employeeWithinWeeks.add(emp.Employee__c);
                      }
                         emp.Status__c = 'Unlocked';
                            
               
         }

              if(groupwithinweeks.size()>0)
              
              { 
                   list<Employee_Group__c> groupObj =  [Select Employee__c From Employee_Group__c
                                                               where  Group__c in :groupwithinweeks];
                   
                    for(Employee_Group__c gp:groupObj)
                    
                    {
                      employeeWithinWeeks.add(gp.Employee__c);
                 
                    }

               }
               
  
 for(Week__c week:[Select Week_Commencing__c,Locking_User__c,Locking_User__r.Name,Employee__c,Employee__r.Name from Week__c where Employee__c in :employeeWithinWeeks and Week_Commencing__c>=:weekLock.Start_Date__c  and Week_Commencing__c<=:weekLock.End_Date__c ])
        
       {
                week.Locking_User__c = null;
                weeksToBeLocked.add(week);
         }
      
         
    try
       {
           update weeksToBeLocked;
           weekLock.Status__c ='Unlocked';
           update weekLock;
           update weekLock.Employee_Week_Lock__r;
         
       }
       
    catch (Exception e)
       {
         
       }
   } 
   
 /*-----UnLocking of Employees and Group of Employees within weeks selected Ends-----*/
   
   
   webservice static void EmployeeWeekunLock(String EmployeeWeekId) 
   
       {
           List<Week__c> weeksToBeLocked = new List<Week__c>();
           Employee_Week_Lock__c EmployeeweekLock = new Employee_Week_Lock__c ();
           List<Id> employeeWithinWeeks = new List<Id>();
           List<Id> groupwithinweeks = new List<Id>();
           
           EmployeeweekLock = [Select Id, Employee__c,Group__c,Status__c,Week_Lock__r.Start_Date__c,Week_Lock__r.End_Date__c,Week_Lock__c from Employee_Week_Lock__c 
                                     Where id= :EmployeeWeekId];
                       
         {      
             if(EmployeeweekLock.Group__c!= null)
             
               { 
                  groupwithinweeks.add(EmployeeweekLock.Group__c );

               }
                         
             else
                  
                  {
                     employeeWithinWeeks.add(EmployeeweekLock.Employee__c);
                  }
                     
                     EmployeeweekLock.Status__c = 'Unlocked';
               
          }
          
          if(groupwithinweeks.size()>0)
              
              { 
                   list<Employee_Group__c> groupObj =  [Select Employee__c From Employee_Group__c
                                                               where  Group__c in :groupwithinweeks];
                   
                    for(Employee_Group__c gp:groupObj)
                    
                    {
                      employeeWithinWeeks.add(gp.Employee__c);
                 
                    }

               }
                       
              
  for(Week__c week:[Select Week_Commencing__c,Locking_User__c,Employee__c from Week__c where Employee__c = :EmployeeweekLock.Employee__c and Week_Commencing__c>=:EmployeeweekLock.Week_Lock__r.Start_Date__c  and Week_Commencing__c<=:EmployeeweekLock.Week_Lock__r.End_Date__c ])
           
           {
              week.Locking_User__c = null;
               weeksToBeLocked.add(week);
               EmployeeweekLock.Status__c = 'Unlocked';
      
            }
     
     
   
   try   
        {
            update weeksToBeLocked;
            update EmployeeweekLock;
        
        }
   
  catch (Exception e)
       {
         
       }

   }
  
  }
 
   
 /*-----UnLocking of individual and Group of Employees within weeks selected Ends-----*/