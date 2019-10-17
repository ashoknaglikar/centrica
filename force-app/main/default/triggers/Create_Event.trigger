trigger Create_Event on Unavailability__c (after update) 

    {
      String UnavId = RecordTypeIdHelper.getRecordTypeId('Event', 'Unavailable');
          
        for(Unavailability__c u: Trigger.New)

        if(u.Unavailability_Reason__c == 'Survey Booking' && u.Generated_Unavailability__c == True)
        {
             List<Event> lst_old_Event = [Select Id,Whatid,OwnerId,StartDateTime,EndDateTime, RecordtypeId from Event where Whatid =:u.Opportunity__c and recordtypeId = :UnavId and OwnerId =:u.Employee_Salesforce_ID__c and StartDateTime=:u.Start_Date_Time__c and EndDateTime =:u.End_Date_Time__c ];
    
                               
                    if(lst_old_Event.size()==0)
                    
                    {
                        List<Event> lst_eve= new List<Event> ();

                        Event obj_eve= new Event();
                        
                        obj_eve.recordtypeId= UnavId;
                        
                        obj_eve.Whatid = u.Opportunity__c;

                        obj_eve.OwnerId= u.Employee_Salesforce_ID__c;

                        obj_eve.Type__c= 'Survey';

                        obj_eve.whoid = u.Quote_Contact_Name__c;

                        obj_eve.StartDateTime= u.Start_Date_Time__c;
                        
                        obj_eve.EndDateTime= u.End_Date_Time__c;

                        obj_eve.status__c = 'New';
                    
                        String Sub = u.Quote_Account_Name__c+':'+u.Quote_Contact_Phone_Number__c+':'+'['+u.Unavailability_Reason__c +':'+u.Duaration_for_Event__c+']';
                        
                        String Sub1;
                        if (Sub.length()>80)
                            {

                                Sub1=Sub.substring(0,79);

                            }
                            else
                            {
                                Sub1=Sub;
                            }
                        obj_eve.Subject = Sub1 ;
                        
                        obj_eve.Unavailability_Reason__c = 'Survey Booking';
                         obj_eve.Call_Notes__c = u.Unavailability_Notes__c;
                        
                        
                        System.debug('obj_eve: '+obj_eve);    

                        lst_eve.add(obj_eve);

                    try

                        {

                            if(lst_eve!= null)

                            insert lst_eve;
                            
                            System.debug('lst_eve: '+lst_eve);  

                        }

                        catch(Exception exp)

                        {

                            System.debug('Exception'+ exp);

                        } 
                        
                    }
                    
                
                    else

                    {

                        List<Event> lst_recheck_Event= new List <Event> ();

                        for(Integer i=0; i<lst_old_Event.size();i++)

                        {

                            Event event1= new Event(Id = lst_old_Event[i].Id);    

                            event1.recordtypeId= UnavId;
                        
                            event1.Whatid = u.Opportunity__c;

                            event1.OwnerId= u.Employee_Salesforce_ID__c;

                            event1.Type__c= 'Survey';

                            event1.whoid = u.Quote_Contact_Name__c;

                            event1.StartDateTime= u.Start_Date_Time__c;
                            
                            event1.EndDateTime= u.End_Date_Time__c;

                            event1.status__c = 'New';
    
                            String Sub = u.Quote_Account_Name__c+':'+u.Quote_Contact_Phone_Number__c+':'+'['+u.Unavailability_Reason__c +':'+u.Duaration_for_Event__c+']';
                        
                            String Sub1;
                            if (Sub.length()>80)
                                {

                                    Sub1=Sub.substring(0,79);

                                }
                                else
                                {
                                    Sub1=Sub;
                                }
                            event1.Subject = Sub1 ;
                            
                            event1.Unavailability_Reason__c = 'Survey Booking';
                            event1.Call_Notes__c = u.Unavailability_Notes__c;


                            System.debug('event1: '+event1);

                            lst_recheck_Event.add(event1); 

                            
                        } 
                        try

                        {

                            if(lst_recheck_Event!= null)
                             Update lst_recheck_Event;

                            System.debug('lst_recheck_Event: '+lst_recheck_Event);  

                        }

                        catch(Exception exp)

                        {

                            System.debug('Exception'+ exp);

                        } 


                    }
                                       }
    }