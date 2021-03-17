global class jobTriggerHelper {
    
    static set<String> jobInstallationType = new set<string>();
    static set<String> jobBoilerLocation_1 = new set<string>();
    static set<String> jobBoilerLocation_2 = new set<string>();
    static set<String> job1HourBand = new set<string>();
    static set<String> job4HourBand = new set<string>();
    static set<Integer> jobLabourSet  = new set<Integer>();
    static set<decimal> jobHourAdjustment = new set<decimal>();
    static map<string, string> bolierLocationMap = new map<string, string>();
    
    webservice static string btnClickUpdateBlancingMecanical(id[] jobId)
    {
        list<Job__c> jobList =[Select id,Installation_Type__c, Boiler_Location__c,  Total_Hours__c,Balancing_Skill__c/*,  District__r.Premier_Ready__c , District__r.Before_Trial__c */ from Job__c where Id in: jobId];
        list<Job__c> finalList = new list<Job__c>();
        for(Job__c j: jobList)
        {
            if(j.Installation_Type__c == null || j.Boiler_Location__c == null)
            {
                return('Installation Type & Boiler location can not be blank.');
            }
            //if(j.District__r.Before_Trial__c== true)
            //{
                finalList.add(j);
            //}else{
                
               // continue;
            //}
        }
        if(finalList.size()>0){
            try{
                calculateBalancingMechanicalHours(finalList, true);
                
                update finalList;
                return('Sucessfully Calcluated.');
            }catch(exception e)
            {
                  return('Opps.. Some thing went wrong.'+e.getmessage() +'. At line number ' +e.getLinenumber());
            }
        }else{
             return('This job is not in Trial District');
        }
        
    }
    
    public static void calculateBalancingMechanicalHours(list<Job__c> JobList,  boolean recalSPhours)
    {
        calculateBalancingMechanicalHoursReturnJobs(JobList, recalSPhours);
    }
    
    public  static list<Job__c> calculateBalancingMechanicalHoursReturnJobs(list<Job__c> JobList,  boolean recalSPhours )
    {
        //Search_Parameter__c searchParam = [Select  Double_Handed_Threshold__c  from Search_Parameter__c Where Type__c  = 'DEFAULT'];
        //list<Job__c> returnList = new list<Job__c>();
        decimal x2MenBoundry = decimal.valueof(system.label.X2_Men_Boundry);
        
        for(string s: system.label.Boiler_Location_Map.split(';'))
        {
            string[] innerStrin = s.split('=>');
            bolierLocationMap.put(innerStrin[0],innerStrin[1]);
        }
        list<PHS_Data__c> halfDayLookUpData = [Select Calculation_Method__c, Premier_Hour_Equivalent__c, Lower_Boundry__c, Upper_Boundry__c from PHS_Data__c  
                                                  where Data_Type__c = 'Half Day Lookup'];
        for(Job__c j :JobList)
        {
            //jobHourAdjustment.put(j.Id, j);
            jobInstallationType.add( j.Installation_Type__c);                                        // add Installation type like A1, A2 etc
            //jobBoilerLocation_1
            jobBoilerLocation_1.add( j.Boiler_Location__c);                                            // add Boiler location like B1, B2 etc
            
            if(bolierLocationMap.containsKey(j.Boiler_Location__c))
            jobBoilerLocation_2.add(bolierLocationMap.get(j.Boiler_Location__c));
            else
            jobBoilerLocation_2.add(j.Boiler_Location__c);
            
            integer totalHoursInteger = integer.valueof(j.Total_Hours__c);                                   // remove any decimal if any from toal Hours
            string X1HrBand = string.valueof(totalHoursInteger) +'-'+ string.valueof(totalHoursInteger+1);   // if total hours is 10.5 then make 1hrBand is 10-11
            job1HourBand.add(X1HrBand);                                             
            
            integer X4hourQuoatient = totalHoursInteger/4;
            string X4hourband = string.valueof(X4hourQuoatient*4) +'-'+ string.valueof((X4hourQuoatient*4)+4);
            job4HourBand.add(X4hourband);
            
            // if total hours is greated then Double_Handed_Threshold__c then set it 2 else set it 1
            if(x2MenBoundry< j.Total_Hours__c)
            jobLabourSet.add(2);
            else
            jobLabourSet.add(1);
            
            system.debug('Type Map-->'+jobInstallationType);
            system.debug('Location Map-->'+jobBoilerLocation_1);
            system.debug('1 hour Map-->'+job1HourBand);
            system.debug('4 hour Map-->'+job4HourBand);
            system.debug('Labour Map-->'+jobLabourSet);
             
        }
        
        list<PHS_Data__c> dataUsed = [Select id, Adjustment__c, Boiler_Location__c, Hour_Banding__c, Data_Type__c, Include__c , Installation_Type__c, Number_Of_Men__c, S2S_Include__c , S2S_Adjustment__c 
                                      from PHS_Data__c where (Boiler_Location__c in : jobBoilerLocation_1 or Boiler_Location__c in : jobBoilerLocation_2 )and 
                                    Installation_Type__c in : jobInstallationType and (Hour_Banding__c in : job1HourBand OR Hour_Banding__c in : job4HourBand) and Number_Of_Men__c in : jobLabourSet order by Order__c ];
        
        system.debug('Simplification data-->'+dataUsed);
        
        for(Job__c j : JobList)
        {
            decimal initalAdjutment = 0;
            integer noMen = 1;
            if(x2MenBoundry< j.Total_Hours__c)
            noMen =2;
            
            for(PHS_Data__c p: dataUsed)
            {
                if(j.Boiler_Location__c == p.Boiler_Location__c && 
                   j.Installation_Type__c == p.Installation_Type__c &&
                   noMen == p.Number_Of_Men__c)
                  {
                      // First Try S2S Details
                      integer totalHoursInteger = integer.valueof(j.Total_Hours__c);                                   // remove any decimal if any from toal Hours
                      string X1HrBand = string.valueof(totalHoursInteger) +'-'+ string.valueof(totalHoursInteger+1);   // if total hours is 10.5 then make 1hrBand is 10-11
                      
                      integer X4hourQuoatient = totalHoursInteger/4;
                      string X4hourband = string.valueof(X4hourQuoatient*4) +'-'+ string.valueof((X4hourQuoatient*4)+4);
                      
                      if(p.Hour_Banding__c == X1HrBand && p.S2S_Include__c == 1){
                            initalAdjutment = p.S2S_Adjustment__c;
                            system.debug('---s2s---');
                            break;
                        }else if(p.Hour_Banding__c == X1HrBand && p.Include__c == 1 && initalAdjutment==0) { // Second try Overall Details
                            initalAdjutment = p.Adjustment__c;
                            system.debug('---Overall---');
                            break;
                           
                       }else if(p.Hour_Banding__c == X4hourband &&  p.Data_Type__c == 'Half Day' && p.S2S_Include__c== 1 && initalAdjutment==0 ){ // third try with Half Day details
                            initalAdjutment = p.S2S_Adjustment__c;
                            system.debug('---HalfDay---');
                            break;
                        
                        }
                  }      
            } 
        
            
            decimal revisedTime = j.Total_Hours__c + initalAdjutment;
            system.debug('revisedTime---->'+revisedTime);
            jobHourAdjustment.add(revisedTime);
            j.GPS_Hours__c = initalAdjutment;
            //j.Balancing_Skill__c = revisedTime;
        
        if(recalSPhours)
        {
            //Query Halfday look up data
            
            system.debug('half Day look up-->'+halfDayLookUpData);
            PHS_Data__c rightOne = new PHS_Data__c(); 
            for(PHS_Data__c p : halfDayLookUpData)
            {
                if(p.Lower_Boundry__c <= revisedTime && p.Upper_Boundry__c >= revisedTime)
                {
                    rightOne = p;
                    break;
                }  
                
                
            }
            if(rightOne.Calculation_Method__c == 'Half Day Booking') 
            {
                j.Balancing_Skill__c = rightOne.Premier_Hour_Equivalent__c-j.Total_Hours__c;
            }
            else{
                j.Balancing_Skill__c = revisedTime - J.Total_Hours__c;
            }
                j.Balancing_Skill__c = j.Balancing_Skill__c.setScale(2).doubleValue(); //PRB00028115
            
        }
    }    
    return JobList;                              
            
    }  

}