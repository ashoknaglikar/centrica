public with sharing class ShifttemplateExtension 
{

public Diary_Change__c deReq{get;set;}
public boolean week1{get;set;}
public boolean week2{get;set;}
public boolean week3{get;set;}
public boolean week4{get;set;}
public boolean recAvail{get;set;}            
private ApexPages.StandardController controller{get;set;}     
public boolean copy2  = false, copy3  = false, copy4 = false;
Utilities util = new Utilities();
//Wrapper class instance
public availabilityWrapper availabilityWrapIns { get; set; }
public List<SelectOption> availabilityTypes { get; set; }
public Shift_template__c shiftTemplate { get; set; }

//Suguna 
Public time StartTime{get;set;}
Public time EndTime{get;set;}
Public Integer slotDurationHour{get;set;}
Public Integer slotDurationMin{get;set;}
Public time LunchTime{get;set;}
Public Integer lunchDurationHour{get;set;}
Public Integer lunchDurationMin{get;set;}

Public boolean mondayCheck{get;set;}
Public boolean tuesdayCheck{get;set;}
Public boolean wednesdayCheck{get;set;}
Public boolean thursdayCheck{get;set;}
Public boolean fridayCheck{get;set;}
Public boolean saturdayCheck{get;set;}
Public boolean sundayCheck{get;set;}
Public boolean Check{get;set;}

public boolean week_1{get;set;}
public boolean week_2{get;set;}
public boolean week_3{get;set;}
public boolean week_4{get;set;}
//ends

public ShifttemplateExtension(ApexPages.StandardController controller)
{ 
    check=true;
    LunchTime = time.newInstance(12,00, 00, 00);
    lunchDurationMin = 30;
    recAvail=True;
    deReq = New Diary_Change__c();
    setAvailability();
    system.debug('entering in constructor');
    shiftTemplate = (Shift_template__c)controller.getrecord();
    
}


//Suguna - start
Public void clickGenerate()
{
    boolean errorflag= validatefields();
    if(!errorflag)
    {
        if(week_1)
        {
            if(mondayCheck)
            availabilityWrapIns.weekTemplateMondayList = generateAppList();
            else
            availabilityWrapIns.weekTemplateMondayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(tuesdayCheck)
            availabilityWrapIns.weekTemplateTuesdayList = generateAppList();
            else
            availabilityWrapIns.weekTemplateTuesdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(wednesdayCheck)
            availabilityWrapIns.weekTemplatewednesdayList = generateAppList();
            else
            availabilityWrapIns.weekTemplatewednesdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(thursdayCheck)
            availabilityWrapIns.weekTemplatethursdayList = generateAppList();
            else
            availabilityWrapIns.weekTemplatethursdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(fridayCheck)
            availabilityWrapIns.weekTemplateFridayList = generateAppList();
            else
            availabilityWrapIns.weekTemplateFridayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(saturdayCheck)
            availabilityWrapIns.weekTemplatesaturdayList = generateAppList();
            else
            availabilityWrapIns.weekTemplatesaturdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(sundayCheck)
            availabilityWrapIns.weekTemplatesundayList = generateAppList();
            else
            availabilityWrapIns.weekTemplatesundayList = new List<availabilityWrapper.weekTemplateWrapper>();
        }
        if(week_2)
        {  
            if(mondayCheck)
            availabilityWrapIns.week2TemplateMondayList = generateAppList();
            else
            availabilityWrapIns.week2TemplateMondayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(tuesdayCheck)
            availabilityWrapIns.week2TemplateTuesdayList = generateAppList();
            else
            availabilityWrapIns.week2TemplateTuesdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(wednesdayCheck)
            availabilityWrapIns.week2TemplatewednesdayList = generateAppList();
            else
            availabilityWrapIns.week2TemplatewednesdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(thursdayCheck)
            availabilityWrapIns.week2TemplatethursdayList = generateAppList();
            else
            availabilityWrapIns.week2TemplatethursdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(fridayCheck)
            availabilityWrapIns.week2TemplateFridayList = generateAppList();
            else
            availabilityWrapIns.week2TemplateFridayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(saturdayCheck)
            availabilityWrapIns.week2TemplatesaturdayList = generateAppList();
            else
            availabilityWrapIns.week2TemplatesaturdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(sundayCheck)
            availabilityWrapIns.week2TemplatesundayList = generateAppList();
            else
            availabilityWrapIns.week2TemplatesundayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
        }
         if(week_3)
        {  
            if(mondayCheck)
            availabilityWrapIns.week3TemplateMondayList = generateAppList();
            else
            availabilityWrapIns.week3TemplateMondayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(tuesdayCheck)
            availabilityWrapIns.week3TemplateTuesdayList = generateAppList();
            else
            availabilityWrapIns.week3TemplateTuesdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(wednesdayCheck)
            availabilityWrapIns.week3TemplatewednesdayList = generateAppList();
            else
            availabilityWrapIns.week3TemplatewednesdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(thursdayCheck)
            availabilityWrapIns.week3TemplatethursdayList = generateAppList();
            else
            availabilityWrapIns.week3TemplatethursdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(fridayCheck)
            availabilityWrapIns.week3TemplateFridayList = generateAppList();
            else
            availabilityWrapIns.week3TemplateFridayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(saturdayCheck)
            availabilityWrapIns.week3TemplatesaturdayList = generateAppList();
            else
            availabilityWrapIns.week3TemplatesaturdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(sundayCheck)
            availabilityWrapIns.week3TemplatesundayList = generateAppList();
            else
            availabilityWrapIns.week3TemplatesundayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
        }
         if(week_4)
        {  
            if(mondayCheck)
            availabilityWrapIns.week4TemplateMondayList = generateAppList();
            else
            availabilityWrapIns.week4TemplateMondayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(tuesdayCheck)
            availabilityWrapIns.week4TemplateTuesdayList = generateAppList();
            else
            availabilityWrapIns.week4TemplateTuesdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(wednesdayCheck)
            availabilityWrapIns.week4TemplatewednesdayList = generateAppList();
            else
            availabilityWrapIns.week4TemplatewednesdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(thursdayCheck)
            availabilityWrapIns.week4TemplatethursdayList = generateAppList();
            else
            availabilityWrapIns.week4TemplatethursdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(fridayCheck)
            availabilityWrapIns.week4TemplateFridayList = generateAppList();
            else
            availabilityWrapIns.week4TemplateFridayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(saturdayCheck)
            availabilityWrapIns.week4TemplatesaturdayList = generateAppList();
            else
            availabilityWrapIns.week4TemplatesaturdayList = new List<availabilityWrapper.weekTemplateWrapper>();
            
            if(sundayCheck)
            availabilityWrapIns.week4TemplatesundayList = generateAppList();
            else
            availabilityWrapIns.week4TemplatesundayList = new List<availabilityWrapper.weekTemplateWrapper>();
        }
    }
    
}

public List<availabilityWrapper.weekTemplateWrapper> generateAppList()
{
    List<availabilityWrapper.weekTemplateWrapper> tempList = new List<availabilityWrapper.weekTemplateWrapper>();
    time Stime = startTime;
    for(Integer i=0;sTime<endTime;i++)
    {
       time eTime = sTime.addHours(slotDurationHour).addMinutes(slotDurationMin);
       
       if(sTime==LunchTime) 
       {
           sTime = sTime.addHours(lunchDurationHour).addMinutes(lunchDurationMin);
           eTime = sTime.addHours(slotDurationHour).addMinutes(slotDurationMin);
       }
       else if(sTime<LunchTime && eTime>LunchTime)
       {
           sTime = LunchTime.addHours(lunchDurationHour).addMinutes(lunchDurationMin);
           eTime = sTime.addHours(slotDurationHour).addMinutes(slotDurationMin);
       }
       
       if(sTime>=startTime && eTime<=endTime)
       {
           availabilityWrapper.weekTemplateWrapper weektemp = new availabilityWrapper.weekTemplateWrapper();
           weektemp.startTime = sTime;
           weektemp.endTime = eTime;
           weektemp.type = 'Sales';
           weektemp.appointments = 1;
           tempList.add(weektemp);
       }
       stime= eTime;
    }
    return tempList;
}

public boolean validatefields()
{
    boolean errorFlag = false;
    if(StartTime==null || endTime==null)
    {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Start Time and End Time.'));
         errorFlag =true;
    }
    if((slotDurationHour==null||slotDurationHour==0) &&(slotDurationMin==null||slotDurationMin==0))
    {   
          
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Slot Duration'));
         errorFlag =true;
    }
    if(startTime>=endTime)
    {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start time should be less than the end time'));
         errorFlag =true;
    }
    return errorFlag;
}
//suguna - ends

public List<SelectOption> getAvailabilityType()
{
    
    List<SelectOption> options = new List<SelectOption>();
    
    Schema.DescribeFieldResult fieldResult = Week_template__c.Type__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry f : ple)
    {
        options.add(new SelectOption(f.getLabel(), f.getValue()));
    }       
    return options;
}

public void setAvailability(){
    availabilityWrapIns = New availabilityWrapper();
    availabilityTypes = getAvailabilityType();
    
    //Week 1 list
    availabilityWrapIns.weekTemplateMondayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.weekTemplateTuesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.weekTemplateWednesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.weekTemplateThursdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.weekTemplateFridayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.weekTemplateSaturdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.weekTemplateSundayList = New List<availabilityWrapper.weekTemplateWrapper>();
    //Week 2 list
    availabilityWrapIns.week2TemplateMondayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week2TemplateTuesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week2TemplateWednesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week2TemplateThursdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week2TemplateFridayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week2TemplateSaturdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week2TemplateSundayList = New List<availabilityWrapper.weekTemplateWrapper>();
    //Week 3 list
    availabilityWrapIns.week3TemplateMondayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week3TemplateTuesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week3TemplateWednesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week3TemplateThursdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week3TemplateFridayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week3TemplateSaturdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week3TemplateSundayList = New List<availabilityWrapper.weekTemplateWrapper>();
    //Week 4 list
    availabilityWrapIns.week4TemplateMondayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week4TemplateTuesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week4TemplateWednesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week4TemplateThursdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week4TemplateFridayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week4TemplateSaturdayList = New List<availabilityWrapper.weekTemplateWrapper>();
    availabilityWrapIns.week4TemplateSundayList = New List<availabilityWrapper.weekTemplateWrapper>();
    //Value set from custom label for displaying the number of rows
    //Integer rows = Integer.valueOf(Label.DairyChangesAppoinmentRow);
    Integer rows = 2;
    for(Integer i=0;i < rows;i++){
        //Week 1
        availabilityWrapIns.weekTemplateMondayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.weekTemplateTuesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.weekTemplateWednesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.weekTemplateThursdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.weekTemplateFridayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.weekTemplateSaturdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.weekTemplateSundayList.add(New availabilityWrapper.weekTemplateWrapper());
        //Week 2
        availabilityWrapIns.week2TemplateMondayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week2TemplateTuesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week2TemplateWednesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week2TemplateThursdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week2TemplateFridayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week2TemplateSaturdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week2TemplateSundayList.add(New availabilityWrapper.weekTemplateWrapper());
        //Week 3
        availabilityWrapIns.week3TemplateMondayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week3TemplateTuesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week3TemplateWednesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week3TemplateThursdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week3TemplateFridayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week3TemplateSaturdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week3TemplateSundayList.add(New availabilityWrapper.weekTemplateWrapper());
        //Week 4
        availabilityWrapIns.week4TemplateMondayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week4TemplateTuesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week4TemplateWednesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week4TemplateThursdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week4TemplateFridayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week4TemplateSaturdayList.add(New availabilityWrapper.weekTemplateWrapper());
        availabilityWrapIns.week4TemplateSundayList.add(New availabilityWrapper.weekTemplateWrapper());
    }
    
}

public void displayWeek1()
{
    week1 = true;
    System.debug('====week1==='+week1);
}

public void displayWeek2()
{
    if(shiftTemplate.Week_2__c)
        week2 = true;
    else
        week2=false;
    
}

public void displayWeek3()
{
    if(shiftTemplate.Week_3__c)
        week3 = true;
    else
        week3=false;
    
}

public void displayWeek4()
{
    if(shiftTemplate.Week_4__c)
        week4 = true;
    else
        week4=false;
    
}


public pagereference saveAvailability(){
    List<Week_template__c> createWeekTemplateList = New List<Week_template__c>();
    if(checkAllvalidation() ){
        
        Insert shiftTemplate;
        
        system.debug('@@ into save '+createWeekTemplateList);
        
        
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 1', 'Monday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateMondayList, 'Week 2', 'Monday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateMondayList, 'Week 3', 'Monday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week4TemplateMondayList, 'Week 4', 'Monday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 1', 'Tuesday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateTuesdayList, 'Week 2', 'Tuesday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateTuesdayList, 'Week 3', 'Tuesday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week4TemplateTuesdayList, 'Week 4', 'Tuesday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 1', 'Wednesday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateWednesdayList, 'Week 2', 'Wednesday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateWednesdayList, 'Week 3', 'Wednesday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week4TemplateWednesdayList, 'Week 4', 'Wednesday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 1', 'Thursday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateThursdayList, 'Week 2', 'Thursday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateThursdayList, 'Week 3', 'Thursday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week4TemplateThursdayList, 'Week 4', 'Thursday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 1', 'Friday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateFridayList, 'Week 2', 'Friday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateFridayList, 'Week 3', 'Friday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week4TemplateFridayList, 'Week 4', 'Friday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 1', 'Saturday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateSaturdayList, 'Week 2', 'Saturday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateSaturdayList, 'Week 3', 'Saturday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week4TemplateSaturdayList, 'Week 4', 'Saturday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 1', 'Sunday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateSundayList, 'Week 2', 'Sunday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateSundayList, 'Week 3', 'Sunday'));
        createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week4TemplateSundayList, 'Week 4', 'Sunday'));
        system.debug('@@ into save template '+createWeekTemplateList);
        createWeekTemplateList.addAll(populateWeekRecordsAvailable());
        
        
        if(createWeekTemplateList.size() > 0){
            try{
                Insert createWeekTemplateList;
                return new pagereference('/'+shiftTemplate.Id);                
                }
                catch(Exception e){
                    return null;
                }
        }
        
    }
    return null;
}

//Cloning the records for week 2, week 3 and week 4 based on the checkbox values
public List<Week_template__c> populateWeekRecordsAvailable(){
    System.debug('Inside clone functionality');
    System.debug('Copy 2 value-->' +copy2);
    System.debug('Copy 3 value-->' +copy3);
    System.debug('Copy 4 value-->' +copy4);
    System.debug('Week 2 value--->' +shiftTemplate.Week_2__c);
    System.debug('Week 3 value--->' +shiftTemplate.Week_3__c);
    System.debug('Week 4 value--->' +shiftTemplate.Week_4__c);
    
    List<Week_template__c> createWeekTemplateList = New List<Week_template__c>();
    if(shiftTemplate.Week_2__c && shiftTemplate.Week_3__c && shiftTemplate.Week_4__c)
    {
        if(!copy2 && copy3 && copy4)  
        {   
            //week3Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 3', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 3', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 3', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 3', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 3', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 3', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 3', 'Sunday'));
            
            //week4Details = week2Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateMondayList, 'Week 4', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateTuesdayList, 'Week 4', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateWednesdayList, 'Week 4', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateThursdayList, 'Week 4', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateFridayList, 'Week 4', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateSaturdayList, 'Week 4', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week2TemplateSundayList, 'Week 4', 'Sunday'));
        }
        
        else if(copy2 && !copy3 && copy4)
        {
            //week2Details = week1Details.clone(true); //populateRoleDetails(RoleVlaues1,week2Details); 
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 2', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 2', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 2', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 2', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 2', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 2', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 2', 'Sunday'));
            
            //week4Details = week3Details.clone(true);//populateRoleDetails(RoleVlaues3,week4Details);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateMondayList, 'Week 4', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateTuesdayList, 'Week 4', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateWednesdayList, 'Week 4', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateThursdayList, 'Week 4', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateFridayList, 'Week 4', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateSaturdayList, 'Week 4', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.week3TemplateSundayList, 'Week 4', 'Sunday'));       
        } 
        else if(copy2 && copy3 && !copy4)
        {
            //week2Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week2Details);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 2', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 2', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 2', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 2', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 2', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 2', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 2', 'Sunday')); 
            
            //week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 3', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 3', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 3', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 3', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 3', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 3', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 3', 'Sunday'));
            
        }  
        else if(!copy2 && !copy3 && copy4)
        {
            //week4Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week4Details);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 4', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 4', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 4', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 4', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 4', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 4', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 4', 'Sunday'));
            
        } else if(copy2 && !copy3 && !copy4)
        {
            //week2Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 2', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 2', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 2', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 2', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 2', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 2', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 2', 'Sunday'));
        }else if(!copy2 && copy3 && !copy4)
        {
            // week3Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week3Details);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 3', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 3', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 3', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 3', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 3', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 3', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 3', 'Sunday'));
        }else if(copy2 && copy3 && copy4)
        {
            //week2Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 2', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 2', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 2', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 2', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 2', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 2', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 2', 'Sunday'));
            
            //week3Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 3', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 3', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 3', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 3', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 3', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 3', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 3', 'Sunday'));
            
            //week4Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 4', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 4', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 4', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 4', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 4', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 4', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 4', 'Sunday'));                    }
    }
    
    
    else if(!shiftTemplate.Week_2__c && shiftTemplate.Week_3__c && shiftTemplate.Week_4__c)
    {
        if(!copy3 && copy4)
        {
            //week4Details = week1Details.clone(true);  
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 4', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 4', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 4', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 4', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 4', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 4', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 4', 'Sunday'));   
        }  
        else if(copy3 && !copy4)
        {
            //week3Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 3', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 3', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 3', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 3', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 3', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 3', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 3', 'Sunday'));  
            
        } else if (copy3 && copy4)
        {
            //week3Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 3', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 3', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 3', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 3', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 3', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 3', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 3', 'Sunday'));  
            
            //week4Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 4', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 4', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 4', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 4', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 4', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 4', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 4', 'Sunday'));  
        }               
    } 
    
    else if(shiftTemplate.Week_2__c && !shiftTemplate.Week_3__c && shiftTemplate.Week_4__c)
    {
        if(!copy2 && copy4)
        {
            //week4Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 4', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 4', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 4', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 4', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 4', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 4', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 4', 'Sunday'));  
        }
        else if(copy2 && !copy4)
        {
            //week2Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 2', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 2', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 2', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 2', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 2', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 2', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 2', 'Sunday'));  
        }else if(copy2 && copy4)
        {
            //week2Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 2', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 2', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 2', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 2', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 2', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 2', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 2', 'Sunday'));  
            //week4Details = week1Details.clone(true);
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 4', 'Monday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 4', 'Tuesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 4', 'Wednesday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 4', 'Thursday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 4', 'Friday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 4', 'Saturday'));
            createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 4', 'Sunday'));  
            
        }
    }           
        else if(shiftTemplate.Week_2__c && shiftTemplate.Week_3__c && !shiftTemplate.Week_4__c)
        {
            if(!copy2 && copy3)
            {
                //week3Details = week1Details.clone(true);
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 3', 'Monday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 3', 'Tuesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 3', 'Wednesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 3', 'Thursday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 3', 'Friday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 3', 'Saturday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 3', 'Sunday'));  
            }else if(copy2 && !copy3)
            {
                //week2Details = week1Details.clone(true);//populateRoleDetails(RoleVlaues1,week2Details);  
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 2', 'Monday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 2', 'Tuesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 2', 'Wednesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 2', 'Thursday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 2', 'Friday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 2', 'Saturday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 2', 'Sunday'));  
            }else if(copy2 && copy3)
            {
                //week2Details = week1Details.clone(true); 
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 2', 'Monday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 2', 'Tuesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 2', 'Wednesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 2', 'Thursday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 2', 'Friday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 2', 'Saturday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 2', 'Sunday'));   
                
                //week3Details = week1Details.clone(true);
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 3', 'Monday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 3', 'Tuesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 3', 'Wednesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 3', 'Thursday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 3', 'Friday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 3', 'Saturday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 3', 'Sunday'));  
            }
        }  
        else if(!shiftTemplate.Week_2__c && !shiftTemplate.Week_3__c && shiftTemplate.Week_4__c)
        {
            if(copy4)
            {             
                //week4Details = week1Details.clone(true);
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 4', 'Monday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 4', 'Tuesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 4', 'Wednesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 4', 'Thursday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 4', 'Friday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 4', 'Saturday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 4', 'Sunday'));  
            }
        }
        else if(shiftTemplate.Week_2__c && !shiftTemplate.Week_3__c && !shiftTemplate.Week_4__c)
        {
            if(copy2)
            {
                //week2Details = week1Details.clone(true);
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 2', 'Monday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 2', 'Tuesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 2', 'Wednesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 2', 'Thursday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 2', 'Friday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 2', 'Saturday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 2', 'Sunday'));  
            }            
        }
        else if(!shiftTemplate.Week_2__c && shiftTemplate.Week_3__c && !shiftTemplate.Week_4__c)
        {
            if(copy3)
            { 
                //week3Details = week1Details.clone(true);
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateMondayList, 'Week 3', 'Monday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateTuesdayList, 'Week 3', 'Tuesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateWednesdayList, 'Week 3', 'Wednesday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateThursdayList, 'Week 3', 'Thursday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateFridayList, 'Week 3', 'Friday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSaturdayList, 'Week 3', 'Saturday'));
                createWeekTemplateList.addAll(getWeekTemplateWrapper(availabilityWrapIns.weekTemplateSundayList, 'Week 3', 'Sunday'));  
                
            }                   
        } 
     
    return createWeekTemplateList;
}

public list<Week_template__c> getWeekTemplateWrapper(List<availabilityWrapper.weekTemplateWrapper> weekTemplateWrap, String weekName, String dayName){
    List<Week_template__c> createWeekTemplateList = New List<Week_template__c>();
    for(availabilityWrapper.weekTemplateWrapper wrap : weekTemplateWrap){
        if(validateWeekTemplate(wrap) && validateTime(wrap)){
            if(wrap.active)
            {
            Week_template__c weekTemplateIns = New Week_template__c();
            weekTemplateIns.Day_name__c = dayName;
            weekTemplateIns.Week_name__c = weekName;
            weekTemplateIns.Start_time__c = wrap.startTime;
            weekTemplateIns.End_time__c = wrap.endTime;
            weekTemplateIns.Type__c = wrap.type;
            weekTemplateIns.Number_of_Appointments__c = wrap.appointments;
            weekTemplateIns.Shift_template__c = shiftTemplate.Id;
            createWeekTemplateList.add(weekTemplateIns);}
        }
    }
    return createWeekTemplateList;
}

//Validation for start time and end time

    public boolean validateTime(availabilityWrapper.weekTemplateWrapper wrap){
        if(wrap.startTime < wrap.endTime){
        return true;    
        }
        return false;
    }

//Validation for each record - checks if all the values are entered correctly
public Boolean validateWeekTemplate(availabilityWrapper.weekTemplateWrapper wrap){
    if(wrap.startTime != null && wrap.endTime != null && wrap.type != null && wrap.appointments != null){
        System.debug('Inside the validate week template validation');
        if(wrap.startTime < wrap.endTime){
        return true;    
        }
        else{
        util.setErrorMsg(true,'Start time should be less than the end time' );
        return false;
        }
    }
    
    else
    {   // System.debug('Inside the else part of the validation');
       // util.setErrorMsg(true,'Please Enter all the field values' );
        return false;
    }
    
}

//Validates that we have entered week data on page and sets the boolean value for the variables for cloning functionality
private boolean checkAllvalidation()
{ 
    boolean finalResult = true;
    if(recAvail)
    {
        
        System.debug('Inside the validation');
        
        if(shiftTemplate.Week_1__c && checkisEmpty(availabilityWrapIns.weekTemplateMondayList) && checkisEmpty(availabilityWrapIns.weekTemplateTuesdayList) && checkisEmpty(availabilityWrapIns.weekTemplateWednesdayList) && checkisEmpty(availabilityWrapIns.weekTemplateThursdayList) && checkisEmpty(availabilityWrapIns.weekTemplateFridayList) && checkisEmpty(availabilityWrapIns.weekTemplateSaturdayList) && checkisEmpty(availabilityWrapIns.weekTemplateSundayList))   
        {   system.debug('shiftTemplate.Week_1__c--->' +shiftTemplate.Week_1__c);
            system.debug('checkisEmpty(availabilityWrapIns.weekTemplateMondayList)--->' + checkisEmpty(availabilityWrapIns.weekTemplateMondayList));
            system.debug('Please Enter Some Appointment');
            util.setErrorMsg(true,'Please Enter Some Appointment Details in Week 1 OR Do Not Check the Week 1 check box.' );
            finalResult =  false;
        } 
        
        if(shiftTemplate.Week_2__c  && checkisEmpty(availabilityWrapIns.week2TemplateMondayList) && checkisEmpty(availabilityWrapIns.week2TemplateTuesdayList) && checkisEmpty(availabilityWrapIns.week2TemplateWednesdayList) && checkisEmpty(availabilityWrapIns.week2TemplateThursdayList) && checkisEmpty(availabilityWrapIns.week2TemplateFridayList) && checkisEmpty(availabilityWrapIns.week2TemplateSaturdayList) && checkisEmpty(availabilityWrapIns.week2TemplateSundayList))
            
        {
            copy2 = true;
        }
        
        
        
        if(shiftTemplate.Week_3__c  && checkisEmpty(availabilityWrapIns.week3TemplateMondayList) && checkisEmpty(availabilityWrapIns.week3TemplateTuesdayList) && checkisEmpty(availabilityWrapIns.week3TemplateWednesdayList) && checkisEmpty(availabilityWrapIns.week3TemplateThursdayList) && checkisEmpty(availabilityWrapIns.week3TemplateFridayList) && checkisEmpty(availabilityWrapIns.week3TemplateSaturdayList) && checkisEmpty(availabilityWrapIns.week3TemplateSundayList))
            
        {
            copy3=true;
        }
        
        
        if(shiftTemplate.Week_4__c  && checkisEmpty(availabilityWrapIns.week4TemplateMondayList) && checkisEmpty(availabilityWrapIns.week4TemplateTuesdayList) && checkisEmpty(availabilityWrapIns.week4TemplateWednesdayList) && checkisEmpty(availabilityWrapIns.week4TemplateThursdayList) && checkisEmpty(availabilityWrapIns.week4TemplateFridayList) && checkisEmpty(availabilityWrapIns.week4TemplateSaturdayList) && checkisEmpty(availabilityWrapIns.week4TemplateSundayList))
            
        {
            copy4=true;
        }
    }
    system.debug('val'+finalResult);
    return finalResult;
    
}

public boolean checkisEmpty (list<availabilityWrapper.weekTemplateWrapper> TemplateList) {
    Boolean isEmpty = true;
    for(availabilityWrapper.weekTemplateWrapper WT:TemplateList) {
        if(WT.startTime != null && WT.endTime != null && WT.type != null && WT.type != '' && WT.appointments != null && WT.appointments > 0 ) 
        {
            isEmpty = false;
            break;
        }
    }
    system.debug(isEmpty);
    return isEmpty; 
} 

public pagereference doNothing(){
    
    displayWeek1();
    displayWeek2();
    displayWeek3();
    displayWeek4();
    if(shiftTemplate.Week_1__c)
    {
        week_1=true;
    }
    else
    {
       week_1=false;
        availabilityWrapIns.weekTemplateMondayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.weekTemplateTuesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.weekTemplateWednesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.weekTemplateThursdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.weekTemplateFridayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.weekTemplateSaturdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.weekTemplateSundayList = New List<availabilityWrapper.weekTemplateWrapper>();
    }
    
    if(shiftTemplate.Week_2__c)
    {
       week_2=true;
    }
    else
    {
       week_2=false;
        availabilityWrapIns.week2TemplateMondayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week2TemplateTuesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week2TemplateWednesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week2TemplateThursdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week2TemplateFridayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week2TemplateSaturdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week2TemplateSundayList = New List<availabilityWrapper.weekTemplateWrapper>();
    }
     if(shiftTemplate.Week_3__c)
     {
       week_3=true;
     }
    else
    {
       week_3=false;
       availabilityWrapIns.week3TemplateMondayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week3TemplateTuesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week3TemplateWednesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week3TemplateThursdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week3TemplateFridayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week3TemplateSaturdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week3TemplateSundayList = New List<availabilityWrapper.weekTemplateWrapper>();
    }
    if(shiftTemplate.Week_4__c)
    {
      week_4=true;
    }
    else
    {
        week_4=false;
        availabilityWrapIns.week4TemplateMondayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week4TemplateTuesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week4TemplateWednesdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week4TemplateThursdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week4TemplateFridayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week4TemplateSaturdayList = New List<availabilityWrapper.weekTemplateWrapper>();
        availabilityWrapIns.week4TemplateSundayList = New List<availabilityWrapper.weekTemplateWrapper>();
    }
    
    return null;
}

public void methodOne(){
    System.debug('Inside method one');
    //availabilityWrapIns = New availabilityWrapper();
    System.debug('Inside method one');
    String paramValue = Apexpages.currentPage().getParameters().get('myparam');
    Integer y = Integer.valueOf(paramValue);
    System.debug('Inside method one-->'+y);
    if(y == 1)
    availabilityWrapIns.weekTemplateMondayList.add(New availabilityWrapper.weekTemplateWrapper());
    if(y == 2)
        availabilityWrapIns.weekTemplateTuesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 3)
            availabilityWrapIns.weekTemplateWednesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 4)
            availabilityWrapIns.weekTemplateThursdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 5)
            availabilityWrapIns.weekTemplateFridayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 6)
            availabilityWrapIns.weekTemplateSaturdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 7)
            availabilityWrapIns.weekTemplateSundayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 8)
            availabilityWrapIns.week2TemplateMondayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 9)
            availabilityWrapIns.week2TemplateTuesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 10)
             availabilityWrapIns.week2TemplateWednesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 11)
            availabilityWrapIns.week2TemplateThursdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 12)
             availabilityWrapIns.week2TemplateFridayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 13)
            availabilityWrapIns.week2TemplateSaturdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 14)
             availabilityWrapIns.week2TemplateSundayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 15)
            availabilityWrapIns.week3TemplateMondayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 16)
            availabilityWrapIns.week3TemplateTuesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 17)
            availabilityWrapIns.week3TemplateWednesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 18)
            availabilityWrapIns.week3TemplateThursdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 19)
             availabilityWrapIns.week3TemplateFridayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 20)
            availabilityWrapIns.week3TemplateSaturdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 21)
            availabilityWrapIns.week3TemplateSundayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 22)
            availabilityWrapIns.week4TemplateMondayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 23)
             availabilityWrapIns.week4TemplateTuesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 24)
            availabilityWrapIns.week4TemplateWednesdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 25)
            availabilityWrapIns.week4TemplateThursdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 26)
             availabilityWrapIns.week4TemplateFridayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 27)
            availabilityWrapIns.week4TemplateSaturdayList.add(New availabilityWrapper.weekTemplateWrapper());
        if(y == 28)
            availabilityWrapIns.week4TemplateSundayList.add(New availabilityWrapper.weekTemplateWrapper());
     
    //return null;
}
}