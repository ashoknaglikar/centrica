trigger bInsValidateShiftPatterns on Shift_Pattern__c (before insert,before update) {
	
	for(Shift_Pattern__c s: trigger.new)
	{
		try{
			Week__c w = new Week__c(Week_Commencing__c = system.today().tostartofweek());
			datetime monStrtAva;  
			if(s.Monday_Start_Time__c!= null) 
			monStrtAva = GenerateAvailability.getDiaryStartEndTime(w,s.Monday_Start_Time__c,0);
			datetime tueStrtAva;
			if(s.Tuesday_Start_Time__c!= null) 
			tueStrtAva = GenerateAvailability.getDiaryStartEndTime(w,s.Tuesday_Start_Time__c,0);
			datetime wedStrtAva;
			if(s.Wednesday_Start_Time__c!= null) 
			wedStrtAva = GenerateAvailability.getDiaryStartEndTime(w,s.Wednesday_Start_Time__c,0);
			datetime thuStrtAva;
			if(s.Thursday_Start_Time__c!= null) 
			thuStrtAva = GenerateAvailability.getDiaryStartEndTime(w,s.Thursday_Start_Time__c,0);
			datetime friStrtAva;
			if(s.Friday_Start_Time__c!= null) 
			friStrtAva = GenerateAvailability.getDiaryStartEndTime(w,s.Friday_Start_Time__c,0);
			datetime satStrtAva;
			if(s.Saturday_Start_Time__c!= null) 
			satStrtAva = GenerateAvailability.getDiaryStartEndTime(w,s.Saturday_Start_Time__c,0);
			datetime sunStrtAva;
			if(s.Sunday_Start_Time__c!= null) 
			sunStrtAva = GenerateAvailability.getDiaryStartEndTime(w,s.Sunday_Start_Time__c,0);
			
			datetime monEndAva;			
			if(s.monday_End_Time__c!= null) 
			monEndAva = GenerateAvailability.getDiaryStartEndTime(w,s.monday_End_Time__c,0);
			datetime tueEndAva;
			if(s.Tuesday_End_Time__c!= null) 
			tueEndAva = GenerateAvailability.getDiaryStartEndTime(w,s.Tuesday_End_Time__c,0);
			datetime wedEndAva;
			if(s.Wednesday_End_Time__c!= null) 
			wedEndAva = GenerateAvailability.getDiaryStartEndTime(w,s.Wednesday_End_Time__c,0);
			datetime thuEndAva;
			if(s.Thursday_End_Time__c!= null) 
			thuEndAva = GenerateAvailability.getDiaryStartEndTime(w,s.Thursday_End_Time__c,0);
			datetime friEndAva;
			if(s.Friday_End_Time__c!= null) 
			friEndAva = GenerateAvailability.getDiaryStartEndTime(w,s.Friday_End_Time__c,0);
			datetime satEndAva;
			if(s.Saturday_End_Time__c!= null) 
			satEndAva = GenerateAvailability.getDiaryStartEndTime(w,s.Saturday_End_Time__c,0);
			datetime sunEndAva;
			if(s.Sunday_End_Time__c!= null) 
			sunEndAva = GenerateAvailability.getDiaryStartEndTime(w,s.Sunday_End_Time__c,0);
			
			datetime monStrtUnav;  
			if(s.Mon_Unav_Start_Time__c!= null) 
			monStrtUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Mon_Unav_Start_Time__c,0);
			datetime tueStrtUnav;
			if(s.Tue_Unav_Start_Time__c!= null) 
			tueStrtUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Tue_Unav_Start_Time__c,0);
			datetime wedStrtUnav;
			if(s.Wed_Unav_Start_Time__c!= null) 
			wedStrtUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Wed_Unav_Start_Time__c,0);
			datetime thuStrtUnav;
			if(s.Thu_Unav_Start_Time__c!= null) 
			thuStrtUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Thu_Unav_Start_Time__c,0);
			datetime friStrtUnav;
			if(s.Fri_Unav_Start_Time__c!= null) 
			friStrtUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Fri_Unav_Start_Time__c,0);
			datetime satStrtUnav;
			if(s.Sat_Unav_Start_Time__c!= null) 
			satStrtUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Sat_Unav_Start_Time__c,0);
			datetime sunStrtUnav;
			if(s.Sun_Unav_Start_Time__c!= null) 
			sunStrtUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Sun_Unav_Start_Time__c,0);
			
			datetime monEndUnav;  
			if(s.Mon_Unav_End_Time__c!= null) 
			monEndUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Mon_Unav_End_Time__c,0);
			datetime tueEndUnav;
			if(s.Tue_Unav_End_Time__c!= null) 
			tueEndUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Tue_Unav_End_Time__c,0);
			datetime wedEndUnav;
			if(s.Wed_Unav_End_Time__c!= null) 
			wedEndUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Wed_Unav_End_Time__c,0);
			datetime thuEndUnav;
			if(s.Thu_Unav_End_Time__c!= null) 
			thuEndUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Thu_Unav_End_Time__c,0);
			datetime friEndUnav;
			if(s.Fri_Unav_End_Time__c!= null) 
			friEndUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Fri_Unav_End_Time__c,0);
			datetime satEndUnav;
			if(s.Sat_Unav_End_Time__c!= null) 
			satEndUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Sat_Unav_End_Time__c,0);
			datetime sunEndUnav;
			if(s.Sun_Unav_End_Time__c!= null) 
			sunEndUnav = GenerateAvailability.getDiaryStartEndTime(w,s.Sun_Unav_End_Time__c,0);
		
		
			if(monStrtUnav < monStrtAva || monStrtUnav > monEndAva || monEndUnav < monStrtAva || monEndUnav > monEndAva 
			   ||tueStrtUnav < tueStrtAva || tueStrtUnav > tueEndAva || tueEndUnav < tueStrtAva || tueEndUnav > tueEndAva
			   ||WedStrtUnav < WedStrtAva || WedStrtUnav > WedEndAva || WedEndUnav < WedStrtAva || WedEndUnav > WedEndAva
			   ||thuStrtUnav < thuStrtAva || thuStrtUnav > thuEndAva || thuEndUnav < thuStrtAva || thuEndUnav > thuEndAva
			   ||friStrtUnav < friStrtAva || friStrtUnav > friEndAva || friEndUnav < friStrtAva || friEndUnav > friEndAva
			   ||satStrtUnav < satStrtAva || satStrtUnav > satEndAva || satEndUnav < satStrtAva || satEndUnav > satEndAva
			   ||sunStrtUnav < sunStrtAva || sunStrtUnav > sunEndAva || sunEndUnav < sunStrtAva || sunEndUnav > sunEndAva
			   )
			   {
			   	if(system.label.Validation_Rule_Switch == 'yes')
			   	s.adderror('Some of the Unavailability Times are exceeding shiftpattern');
			   }
			if(((s.Mon_Unav_Start_Time__c!=null || s.Mon_Unav_End_Time__c!=null) &&(s.Monday_Start_Time__c==null || s.Monday_End_Time__c==null))
				||((s.Tue_Unav_Start_Time__c!=null || s.Tue_Unav_End_Time__c!=null) &&(s.Tuesday_Start_Time__c==null || s.Tuesday_End_Time__c==null))
				||((s.Wed_Unav_Start_Time__c!=null || s.Wed_Unav_End_Time__c!=null) &&(s.Wednesday_Start_Time__c==null || s.Wednesday_End_Time__c==null))
				||((s.Thu_Unav_Start_Time__c!=null || s.Thu_Unav_End_Time__c!=null) &&(s.Thursday_Start_Time__c==null || s.Thursday_End_Time__c==null))
				||((s.Fri_Unav_Start_Time__c!=null || s.Fri_Unav_End_Time__c!=null) &&(s.Friday_Start_Time__c==null || s.Friday_End_Time__c==null))
				||((s.Sat_Unav_Start_Time__c!=null || s.Sat_Unav_End_Time__c!=null) &&(s.Saturday_Start_Time__c==null || s.Saturday_End_Time__c==null))
				||((s.Sun_Unav_Start_Time__c!=null || s.Sun_Unav_End_Time__c!=null) &&(s.Sunday_Start_Time__c==null || s.Sunday_End_Time__c==null)))
			{
				if(system.label.Validation_Rule_Switch == 'yes')
				s.adderror('Unavailability can not exists without Availability');
			}
		}catch(Exception e)
		{
			if(system.label.Validation_Rule_Switch == 'yes')
			s.adderror('Shift Pattern is not valid');
		}   
	}
    		
	
}