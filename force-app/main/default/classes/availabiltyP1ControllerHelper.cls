public without sharing class availabiltyP1ControllerHelper {
    
    public static AvailabilityP1Controller.availDataSet[] callOFSAPI(list<date> window, string postcodeSector, string bucketId, Opportunity opp, date activeDate)
    {
        system.debug('window -->'+window);
        system.debug('postcodeSector -->'+postcodeSector);
        system.debug('bucketId -->'+bucketId);
        system.debug('activeDate -->'+activeDate);
        system.debug('opp -->'+opp);
        activeDate = activeDate.toStartofweek();
    
        AvailabilityP1Controller.availDataSet[] finalDateSet  = new list<AvailabilityP1Controller.availDataSet>(); 
        
        Map<string, SalesAppointment__c> mcs = SalesAppointment__c.getAll();
        list<string> title = new list<string>{};
        title.addall(mcs.keyset());
        map<integer,SalesAppointment__c> sortcodeMap = new map<integer,SalesAppointment__c>();
        for(SalesAppointment__c ap : mcs.values())
        {
            sortcodeMap.put(integer.valueof(ap.Order__c), ap);
            
        }
        
        list<integer> sortedOrder = new list<integer> {};
        sortedOrder.addall(sortcodeMap.keyset());
        sortedOrder.sort();
        
        for(integer i : sortedOrder)
        {
            SalesAppointment__c ap = sortcodeMap.get(i);
            AvailabilityP1Controller.availDataSet show = new AvailabilityP1Controller.availDataSet();
            show.settimeTitle(ap.Name);
            show.settimeTitleStartHour(integer.valueof(ap.Start_Time__c.split(':')[0]));
            show.settimeTitleEndHour(integer.valueof(ap.End_Time__c.split(':')[0]));
            show.settimeTitleStartMinute(integer.valueof(ap.Start_Time__c.split(':')[1]));
            show.settimeTitleEndMinute(integer.valueof(ap.End_Time__c.split(':')[1]));
            finalDateSet.add(show);
        }
        
        Employee__c emp = [select id,name,Slots_To_Reserve__c,Customer_Category_To_Reseve__c, Release_Day__c, Release_Time__c from Employee__c where id=:bucketId];
        
        list<string> location = new list<string>{bucketId};
        try{
        toaCapacity.capacity_response_element response  = getCapacityRes.getCapacity(location, window, postcodeSector,opp.Account.BillingPostalCode,opp.Product_Interest__c);
        /*List<String> tmpSet = new List<String>();
        tmpSet.addAll(system.label.PriorityAppointmentHour.split(';',0));
        
        Integer hourValue;
        String isPrioritySwitchActive; 
        if(tmpSet != null && tmpSet.size() > 0)
        {
            hourValue = Integer.valueOf(tmpSet[0]);
            isPrioritySwitchActive = tmpSet[1].toLowerCase();
        }*/
        
        datetime nowTime = system.now();
        Integer currentHour = datetime.now().hour(); 
        
        TOA_Product_Interest__c tp = TOA_Product_Interest__c.getInstance(opp.Product_Interest__c);
        
        
        integer minAvailable = integer.valueof(response.activity_travel_time)+integer.valueof(tp.Duration__c);
        if(response!=null)
        {
            
            for(toaCapacity.capacity_element cap : response.capacity)
            {   
                    
                    
                System.debug('Capacity Element -->'+cap); 
                 for(integer cp=0; cp < 7; cp++){
                     
                    date pageDate = date.newInstance(activeDate.year(), activeDate.month(), activeDate.day()+cp);
                     
                 for(integer lp=0; lp<finalDateSet.size(); lp++){
                    
                    if(cap.work_skill != null /*&& cap.available >= minAvailable */ && finalDateSet[lp].timeTitle == cap.time_slot && pageDate == cap.date_x /*&& capacityCategory.contains(cap.work_skill)*/)
                    {
                        datetime slotStartTime = datetime.newInstance(cap.date_x.year(), cap.date_x.month(), cap.date_x.day(), integer.valueof(mcs.get(finalDateSet[lp].timeTitle).Start_Time__c.split(':')[0]), integer.valueof(mcs.get(finalDateSet[lp].timeTitle).Start_Time__c.split(':')[1]), 0);
                        integer noofdays = system.today().daysBetween(date.valueOf(slotStartTime));
                        
                        if(emp.Slots_To_Reserve__c !=null && emp.Customer_Category_To_Reseve__c != null && !emp.Customer_Category_To_Reseve__c.contains(string.valueof(opp.Latest_customer_category__c)) && emp.Slots_To_Reserve__c.contains(cap.time_slot))
                        {
                            integer numberOfDaysBefore = integer.valueof(emp.Release_Day__c);
                            integer timeElement = integer.valueof(emp.Release_Time__c);
                            time timeVar = Time.newInstance(timeElement, 0, 0, 0);
                            datetime releaseDateTime = datetime.newinstance(cap.date_x.adddays(-(numberOfDaysBefore)), timeVar);
                            if(releaseDateTime>system.now())
                            {
                            	continue;
                            }
                            
                        }
                        
                        if(nowTime < slotStartTime || cap.time_slot == 'AT')
                        {
                            
                            if(cap.work_skill == 'standard_cc'  )
                            {
                            	finalDateSet[lp].availableminutes[cp]=cap.available; 
                            }else if(cap.work_skill == 'Commercial')
                            
                             finalDateSet[lp].commercialMinutes[cp]=cap.available;
                            /*
                            if(  finalDateSet[lp].availableminutes[cp] >= minAvailable)
                            {
                            	finalDateSet[lp].daysAvailable[cp]=true;
                           
                            }else
                            {
                            	finalDateSet[lp].availableminutes[cp] = null;
                            	finalDateSet[lp].daysAvailable[cp]=false;
                            }*/
                            
                        }
                        
                    }
                 
                 }
                 }
                

             system.debug(finalDateSet);
            }
            
         for(AvailabilityP1Controller.availDataSet a : finalDateSet)
         {
         	if(system.label.SmallCommercialTurnOff == 'Yes' && opp.Product_Interest__c == 'Small Commercial' ){

         		for(integer i = 0;i<7;i++)
         		{
 			         system.debug('I am here in small commercial'+a.availableminutes[i]);
             		if(a.commercialMinutes[i]!=null )
             		{
             			if(a.availableminutes[i]!=null &&a.availableminutes[i] <0)
             			{
             				a.availableminutes[i]+=a.commercialMinutes[i];
             			}else
             			{
             				a.availableminutes[i]=a.commercialMinutes[i];
             			}
             		}else
             		{
             			a.availableminutes[i] = 0;
             		}
             		
             		if(a.availableminutes[i] >= minAvailable)
                    {
                    	a.daysAvailable[i]=true;
                   
                    }else
                    {
                    	a.availableminutes[i] = null;
                    	a.daysAvailable[i]=false;
                    }
         		}
         	}else{
         		system.debug('I am not in small commercial'+opp.Product_Interest__c);
         		for(integer i = 0;i<7;i++)
         		{
             		if(a.commercialMinutes[i]!=null )
             		{
             			if(a.availableminutes[i]!=null)
             			{
             				a.availableminutes[i]+=a.commercialMinutes[i];
             			}else
             			{
             				a.availableminutes[i]=a.commercialMinutes[i];
             			}
             		}
             		if(  a.availableminutes[i] >= minAvailable)
                    {
                    	a.daysAvailable[i]=true;
                   
                    }else
                    {
                    	a.availableminutes[i] = null;
                    	a.daysAvailable[i]=false;
                    }
         		}
         		
         	}
         	
         }
        }
        }catch (Exception e)
        {
            ApexPages.Message msg;
            msg = new ApexPages.Message(Apexpages.Severity.error, 'There are no available appoints for this week, please try another week.');
            system.debug(LoggingLevel.INFO,''+e.getmessage()+e.getlinenumber());
            ApexPages.addMessage(msg);
        }
        //system.debug('finalDateSet --- >'+finalDateSet);
        return finalDateSet;
    }

}