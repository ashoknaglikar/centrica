/*  BlackBoxOptions
    
    A class that holds options for a black box search. These are made up of 
    options (which are set on the Job) and parameters (which are taken from
    a Search Parameter object).
    
    Initially, search parameters will be the same for all searches; however
    the way this class has been coded should make future changes to allow
    for per-Job/per-Search parameters easier to implement

*/
public with sharing class BlackBoxOptions {

    public static final String PARAMETER_DEFAULT_IDENTIFIER = 'DEFAULT';
    
    // Search Options
    public boolean contractors = null;
    public boolean ownLabour = null;
    public Date customerPreferredDate = null;
    public boolean doubleHanded = null;
    
    public Date FinanceExpDate = null;
    

    // Search Parameters
    public double gapSizeTolerance = null;
    public double usableGapRemaining = null;
    public double doubleHandedThreshold = null;
    public Integer schedulingWindow = null;
    public double endOffset = null;
    public double hoursBetweenResources = null;
    
    // ordering Parameters
    public map<string, integer> resourceRankingMap = null;
    /* BlackBoxOptions()
        Default constructor. Sets up default values for options. */
    public BlackBoxOptions() {
        setupSearchParameters(PARAMETER_DEFAULT_IDENTIFIER, null);
        setDefaultOptions();
    }
    
    /* BlackBoxOptions(Job__c job)
        Constructor that takes a Job as a parameter, and sets the class 
        variables to the values found on the Job object. */
    public BlackBoxOptions(Job__c job) {
        setupSearchParameters(PARAMETER_DEFAULT_IDENTIFIER, job);
        // We can add a conditional to the above so that if there's a Search Parameter
        // related to the Job, we can pull in the parameter values from that object,
        // otherwise we can use the defaults 
        setOptions(job);
    }
    
    /* setOptions(Job__c job)
        Sets variables in this object to values found on the Job object. */
    private void setOptions(Job__c job) {
        if(!job.Contractors__c && !job.Own_Labour__c)
        {
            contractors = job.District__r.Consider_Contractors__c;
            ownLabour= job.District__r.Consider_Own_Labour__c;
            
        }else
        {
            contractors = job.Contractors__c;
            ownLabour = job.Own_Labour__c;
        }
        
        if(job.District__r.Own_Labour__c != null)
        resourceRankingMap.put('Own Labour',integer.valueof(job.District__r.Own_Labour__c));
        if(job.District__r.Contractor_Band1__c!= null)
        resourceRankingMap.put('Contractor Band 1',integer.valueof(job.District__r.Contractor_Band1__c ));
        if(job.District__r.Contractor_Band2__c != null)
        resourceRankingMap.put('Contractor Band 2',integer.valueof(job.District__r.Contractor_Band2__c ));
        if(job.District__r.Contractor_Band3__c != null)
        resourceRankingMap.put('Contractor Band 3',integer.valueof(job.District__r.Contractor_Band3__c ));
        if(job.District__r.Contractor__c != null)
        resourceRankingMap.put('Contractor',integer.valueof(job.District__r.Contractor__c ));
        
        /*if(job.Customer_Preferred_Date__c != null)
            customerPreferredDate = job.Customer_Preferred_Date__c;
        else
            customerPreferredDate = Date.today();*/
        if(cls_IsRun.isPlanner=='N'){
           //date check = system.today().addDays(integer.valueOf(system.label.HSA_minimum_planning_window));
           Date check = HSACustomerPrefDate(cls_IsRun.customerPreferredDate);
           
           customerPreferredDate = check; 
           //customerPreferredDate = cls_IsRun.customerPreferredDate;
        }
        else
        customerPreferredDate = cls_IsRun.customerPreferredDate; // added for Next 7 days employee search change 
        
        system.debug(LoggingLevel.INFO,'==-=-=->blk'+customerPreferredDate);   
        //Change BY Ashok G
        if(job.Finance_Expiry_Date__c != null)
        FinanceExpDate = job.Finance_Expiry_Date__c;
        
        
            
//rjd - -2010-01-12 - changing to or'ing the statements to force doublehanded if set
//as doublehanded on the job.
        if(job.Total_Job_Hours__c >= doubleHandedThreshold || job.Double_Handed_Job__c)
            doubleHanded = true;
        else
            doubleHanded = false;
            
        system.debug('resourceRankingMap---->'+resourceRankingMap);     
    }
    
    /* setDefaultOptions()
        Sets default values for the search options. */
    private void setDefaultOptions() {
        contractors = true;
        ownLabour = true;
        
        if(cls_IsRun.isPlanner=='N'){
        //customerPreferredDate = Date.today().addDays(integer.valueOf(system.label.No_ofDays));
          /* Date check = HSACustomerPrefDate(system.today());
           if(cls_IsRun.customerPreferredDate <= check)
           customerPreferredDate = HSACustomerPrefDate(cls_IsRun.customerPreferredDate);
           else*/
           //customerPreferredDate = cls_IsRun.customerPreferredDate; 
        }
        else
        customerPreferredDate = Date.today();
        
        doubleHanded = false;
    }

    /* setupSearchParameters(String parameterIdentifier)
        Sets search parameters by querying for the Search Parameter object with a 
        Type equal to the parameterIdentifier passed into the method. Currently,
        the only parameterIdentifier used is DEFAULT, though this can be adapted in
        the future */
    private void setupSearchParameters(String parameterIdentifier, Job__c job) {
        System.debug('Searching for parameterIdentifier: ' + parameterIdentifier);
        Search_Parameter__c parameters = [select s.ID, s.Gap_Size_Tolerance__c, s.Acceptable_Remaining_Gap__c, s.End_Date_Time_Offset__c,
                                         s.Double_Handed_Threshold__c, s.Scheduling_Window__c, s.Hours_Between_Multiple_Resources__c,
                                         s.Own_Labour__c, s.Contractor_Band_1__c , s.Contractor_Band_2__c , s.Contractor_Band_3__c ,s.Contractor__c          
                                         from Search_Parameter__c s
                                         where s.Type__c = :parameterIdentifier];
                                          
        
        // Defect XXX
        //gapSizeTolerance = parameters.Gap_Size_Tolerance__c;
        if(job != null && job.Override_Gap_Size_Tolerance__c != null && job.Override_Gap_Size_Tolerance__c > 0)
            gapSizeTolerance = job.Override_Gap_Size_Tolerance__c;
        else
            gapSizeTolerance = parameters.Gap_Size_Tolerance__c;
        
        usableGapRemaining = parameters.Acceptable_Remaining_Gap__c;
        doubleHandedThreshold = parameters.Double_Handed_Threshold__c;
        schedulingWindow = parameters.Scheduling_Window__c.intValue();
        endOffset = 100 - parameters.End_Date_Time_Offset__c;
        hoursBetweenResources = parameters.Hours_Between_Multiple_Resources__c; 
        
        
        resourceRankingMap = new  Map<String, integer>{'Own Labour'=>integer.valueOf(parameters.Own_Labour__c),
                                                            'Contractor Band 1' =>integer.valueOf(parameters.Contractor_Band_1__c), 
                                                            'Contractor Band 2' => integer.valueOf(parameters.Contractor_Band_2__c),
                                                            'Contractor Band 3' => integer.valueOf(parameters.Contractor_Band_3__c),
                                                            'Contractor' => integer.valueOf(parameters.Contractor__c)}; 
    }
    
    public Date HSACustomerPrefDate(Date cusPrefDate){
       //customerPreferredDate = cls_IsRun.customerPreferredDate;
       DateTimeHelper dt = new DateTimeHelper();
       Date dateToday = System.today();
       decimal diff  =decimal.valueof(dt.daysOff(dateToday, cusPrefDate)).abs();
       decimal diffActual = decimal.valueof(dateToday.daysBetween(cusPrefDate)).abs();
       diffActual -= diff;
       decimal diffWindow = 0;
       if(decimal.valueof(system.label.HSA_minimum_planning_window)>=diffActual) 
           diffWindow =decimal.valueof(system.label.HSA_minimum_planning_window) - diffActual;
        
       Time t = Time.newInstance(0,0,0,0);
       DateTime cDate1 = DateTime.newInstance(cusPrefDate,t);
      
       DateTime cDate2 = dt.addBussinessDays(cDate1,Integer.valueOf(diffWindow));
       Date PCDate = cDate2.Date();
       system.debug(LoggingLevel.INFO+'>CustomerPreferredDate'+customerPreferredDate);
       return PCDate;    
    }
}