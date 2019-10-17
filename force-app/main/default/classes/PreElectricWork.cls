public class PreElectricWork 
{
    List<String> lst_plannedStatus = new List<String>{'Planned','Installed'};
    List<String> lst_unplannedStatus = new List<String>{'Pending','Suspended'};
    List<String> lst_Preinstalledtype = new List<String>();//{'Pre-Electric && Earth Spike','Pre-Electric Only', 'Customer to Arrange Pre-Electric & Earth Spike' };
   
    List<String> lst_productids = new List<String>();
    
    public List<Job_Element__c> lst_JobElement {get;set;}
    public Boolean showplanned{get;set;}
    public Boolean showunplanned{get;set;}
    public Job__c jb {get;set;}
    Utilities util ;
    public String tableName {get;set;} 
    Public String area;
    public String regionID;
    public List<District__c> Districts {get;set;}
    public List<Region__c> Region {get;set;}
    public string AreaName{get;set;}
    public String RegionName{get;set;}
    public String WMISNumber{get;set;}
    public string statusvar{get;set;}
    date startDate, endDate;
    
    //public String MIDASNumber{get;set;}
    public List<wrapperClass> wrapList{get;set;}
    
    String baseQuery = 'Select Id,Name,Start_Date__c,Job__c,Job_Element_Number__c,Employee_Itn__c,Product_ID__c, Job__r.Name, Job__r.Address__c,Job__r.Status__c,Job__r.Sub_Status__c,Job__r.Pre_Install_Type__c, Job__r.District__c, Job__r.Pre_Installed_Status__c,Job__r.Installation_Date__c,'+
                       'Job__r.CHI_Lead__r.Latest_customer_category_indicator__c,Job__r.Next_Action_Date_From_Pre_Electric_Recor__c, Job__r.CreatedDate From Job_Element__c where Product_ID__c IN:lst_productids '+
                       ' and CreatedDate>=:startDate and CreatedDate<=:endDate';

	string criteriaQuery = ' ';

	string finalQuery = '';		
    
    
public class wrapperClass{
    public Job_Element__c je{get;set;}
    public Pre_Electrical_Work_Document__c pe{get;set;}
           
    public wrapperClass(Job_Element__c je,Pre_Electrical_Work_Document__c pe){
        this.je = je;
        this.pe = pe;
    }
}  

public List<SelectOption> allAvailableStatus{get;set;}


 public SelectOption[] allStatusSelected { 
 	get{
 		List<SelectOption> options = new List<SelectOption>(); 
 		options.add(new SelectOption('','---All---')); 
 		Schema.DescribeFieldResult fieldResult = Pre_Electrical_Work_Document__c.Status__c.getDescribe();
    	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    	
    	for( Schema.PicklistEntry f : ple)
	    {
	       options.add(new SelectOption(f.getLabel(), f.getValue()));
	      
	    } 
	    options.add(new SelectOption('Null','---Blank---'));      
	    
    	
	    return options;
 	}
 	set; 
 } 
   
public List<SelectOption> getAreaItems()
{
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('','---All---'));
    if(Districts == null)
    Districts = new list<District__c>(); 
    for (Integer i = 0; i < Districts.size(); i++)
    {     
        // Districts = new list<District__c>();                  
        options.add(new SelectOption(Districts[i].Id,Districts[i].Name));
         system.debug('@@@@options'+options);
    }                                               
    return options;
}
      
      
public List<SelectOption> getRegionItems()
{
    List<SelectOption> options = new List<SelectOption>(); 
    options.add(new SelectOption('','---All---'));
    if(Region == null)
    Region = new list<Region__c>(); 
    for (Integer i = 0; i < Region.size(); i++)
    {     
        // Districts = new list<District__c>();                  
        options.add(new SelectOption(Region[i].Name,Region [i].Name));
        system.debug('@@@@options'+options);
    }                                               
    return options;
}

public PreElectricWork()
{       
    lst_JobElement = new List<Job_Element__c>{};
     util  = new Utilities();  
    jb= new Job__c ();
    jb.Customer_Journey_First_Update__c=System.today();
    jb.BGNE_Install_Date__c= System.today()+7;  
    Districts = [Select d.Name, d.Id From District__c d where d.Type__c = 'Installation' order by d.Name]; 
    system.debug('@@@@Districts'+Districts);
    Region = [Select reg.Name, reg.Id From Region__c reg where reg.Type__c = 'Installation' order by reg.Name];
    lst_productids = System.Label.Pre_Electric_Work_Codes.split(',');
    System.debug('====Product===='+lst_productids);
    lst_Preinstalledtype.add('Customer to Arrange Pre-Electric & Earth Spike');
    lst_Preinstalledtype.add('Customer to Arrange Pre-Electric');	
	allAvailableStatus = new List<SelectOption>();
}
      


public void onClickSearch(){
    tableName = 'Searched Jobs';
    lst_JobElement =  new List<Job_Element__c>{};
        
    if(WMISNumber==null || WMISNumber==''){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Enter text in search box.');
        ApexPages.addMessage(myMsg);  
    }
    else{
        lst_JobElement =  new List<Job_Element__c>{};
        wrapList = new List<wrapperClass>();                       
        Set<id> Ids = new Set<id>();
        List<Pre_Electrical_Work_Document__c> pe = [Select id,Job__c,Sub_Status__c from Pre_Electrical_Work_Document__c  where WMIS_Reference_Number__c =:WMISNumber or WIMIS_Reference_Number_2__c =:WMISNumber];
        
        for(Pre_Electrical_Work_Document__c p : pe){
            Ids.add(p.Job__c);
        }
        lst_JobElement=[Select Id,Name,Start_Date__c,Job__c,Job_Element_Number__c,Employee_Itn__c,Product_ID__c, Job__r.Name, Job__r.Address__c,Job__r.Status__c,Job__r.Sub_Status__c,Job__r.Pre_Install_Type__c, Job__r.District__c, Job__r.Pre_Installed_Status__c,Job__r.Installation_Date__c,
                        Job__r.CHI_Lead__r.Latest_customer_category_indicator__c,Job__r.Next_Action_Date_From_Pre_Electric_Recor__c 
                        From Job_Element__c where Job__c IN :Ids and Product_ID__c IN:lst_productids];
                                
        if(!lst_JobElement.isEmpty() && !pe.isEmpty())
        wrapList.add(new wrapperClass(lst_JobElement.isEmpty()?null:lst_JobElement[0],pe.isEmpty()?null:pe[0]));
        System.debug('=====priti========'+wrapList);
        if(wrapList.isEmpty())
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No job is found'));
                                
        showplanned=true;         
    }   
}

public List<String> splitLabel(String str){
    List<String> result = str.split(';');
    return result;
}

public void showplannedjobs() 
{
	
    tableName = 'Planned Jobs';
    if(checkDates())
    return;  
        
	system.debug('lst_plannedStatus-->'+lst_plannedStatus+'---'+lst_Preinstalledtype+' '+splitLabel(System.Label.Trial_for_ESD)+' '+jb.Customer_Journey_First_Update__c+' '+jb.BGNE_Install_Date__c+' '+allStatusSelected);
    if(System.Label.Trial_for_ESD=='Off' && jb.Customer_Journey_First_Update__c!= null && jb.BGNE_Install_Date__c!= null )    
    {
        prepareSearchCritera(0);
    	
    	finalQuery = baseQuery + criteriaQuery;
    	system.debug('finalQuery-->'+finalQuery);
    	lst_JobElement =  new List<Job_Element__c>{};
    	
        lst_JobElement = database.query(finalQuery);
            
        populateInnerClass(lst_JobElement); 
    	
    	
    }
}

 
public void showunplannedjobs() 
{ 
    tableName = 'Unplanned Jobs';   
    if(checkDates())
    return;   
                  
    lst_JobElement =  new List<Job_Element__c>{};
   
   if(System.Label.Trial_for_ESD=='Off' && jb.Customer_Journey_First_Update__c!= null && jb.BGNE_Install_Date__c!= null)
    {             
	    
    	prepareSearchCritera(1);
    	
    	finalQuery = baseQuery + criteriaQuery;
    	
    	lst_JobElement =  new List<Job_Element__c>{};
    	
        lst_JobElement = database.query(finalQuery);
            
        populateInnerClass(lst_JobElement); 
    	                
	                            
	       
	    
	}

}
   
public boolean checkDates()
{
    if(jb.Customer_Journey_First_Update__c==null || jb.BGNE_Install_Date__c==null)
    {
        util.setErrorMsg(true, 'Start & End can not be blank.');
        return true;
    }
    if(jb.Customer_Journey_First_Update__c>jb.BGNE_Install_Date__c)
    {
        util.setErrorMsg(true, 'Start can not be greater then End.');
         return true;
    }
    if(jb.Customer_Journey_First_Update__c.daysbetween(jb.BGNE_Install_Date__c)>30)
    {
    	 util.setErrorMsg(true, 'Start & End date window can not be more than 30 days.');
          return true;
    }
    
    startDate = jb.Customer_Journey_First_Update__c;
	endDate = jb.BGNE_Install_Date__c;
	return false;
}


private String sortDirection = 'ASC';   
private String sortExp = 'name';   
public String sortExpression   {     
	get{        
		return sortExp;     
		}     
	set{       
		//if the column is clicked on then switch between Ascending and Descending modes       
		if (value == sortExp)         
			sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';       
		else         
		sortDirection = 'ASC';       
		sortExp = value;     
		}   
} 
	
public String getSortDirection() {    
	//if not column is selected     
	if (sortExpression == null || sortExpression == '')      
	return 'ASC';    else     return sortDirection; } 
	public void setSortDirection(String value) {     
		sortDirection = value; 
		}

public void ViewData() {       
	//build the full sort expression       
	string sortFullExp = sortExpression  + ' ' + sortDirection;             //query the database based on the sort expression
	//accounts = Database.query('Select id, Name, BillingCity, BillingCountry, Phone from Account order by ' + sortFullExp + ' limit 1000');
	system.debug('sortFullExp -->'+sortFullExp);    
	
	
	string finalQueryWithSorting =  finalQuery +' order by '+sortFullExp+' NULLS LAST'; 
	 
	lst_JobElement =  new List<Job_Element__c>{};
    	
    lst_JobElement = database.query(finalQueryWithSorting);
        
    populateInnerClass(lst_JobElement); 
	//return null;   
}		
		
	

public void populateInnerClass(list<Job_Element__c> jobElementList)
{
	Set<id> job = new Set<id>();
    wrapList = new List<wrapperClass>();
    for(Job_Element__c je : jobElementList){
         job.add(je.Job__c);
    }
    
            
    Map<Id, Job__c> jMap = new map<id, Job__c>([Select id,(Select id, Sub_status__c, Job__c FROM Pre_Electrical_Work_documents__r  order by createddate DESC Limit 1) FROM Job__c where id IN :job]);
           
    for(Job_Element__c je : jobElementList){
        //for(Job__c jb : j){
            if(jMap.containskey(je.Job__c))
              wrapList.add(new wrapperClass(je,jMap.get(je.Job__c).Pre_Electrical_Work_documents__r.isEmpty()?null:jMap.get(je.Job__c).Pre_Electrical_Work_documents__r[0]));
        //}
    }
            
    if(wrapList.isEmpty())
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No job is found'));
    
    showplanned=true;
}
	

public void prepareSearchCritera(integer i)
{
	// i= 0 - planned integer
	if(i== 0)
	{
		//criteriaQuery =  ' and Job__r.Installation_date__c>=:startDate and Job__r.Installation_Date__c<=:endDate and Job__r.Status__c IN: lst_plannedStatus ';
		criteriaQuery =  ' and Job__r.Status__c IN: lst_plannedStatus ';
	}else if(i==1) // i=1 for unplanned status
	{
		//criteriaQuery =  ' and CreatedDate>=:startDate and CreatedDate<=:endDate and Job__r.Status__c IN: lst_unplannedStatus ';
		criteriaQuery =  ' and Job__r.Status__c IN: lst_unplannedStatus ';
	}
		
	//lst_Preinstalledtype = DiallerPageCont.formatSelectOptionsToString(allStatusSelected);
	
	if(statusvar == 'Null' )
	{
		criteriaQuery +=' and Job__r.Pre_Installed_Status__c = null'; 
	}else
	if(statusvar !=null && statusvar != '')
	criteriaQuery +=' and Job__r.Pre_Installed_Status__c = :statusvar'; 
	
	
	if(AreaName!=null)
	criteriaQuery += ' and Job__r.District__c =:AreaName ';
	else if(RegionName!= null)
	criteriaQuery += ' and Job__r.Region__c =:RegionName ';
	
	system.debug('criteriaQuery--- >'+criteriaQuery);
	
	
}
	
			
   
   
}