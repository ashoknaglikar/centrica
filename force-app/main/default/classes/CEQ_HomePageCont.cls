@istest
public class CEQ_HomePageCont{
    /*
    public integer Count{get;set;}
    public Job__c job{get;set;}
    public list<PieWedgeData> ceqHeaderClass{get;set;}
  
    public list<PieWedgeData> caseNormClass {get;set;}
    public list<PieWedgeData> ASPNormalClass {get;set;}
    public list<PieWedgeData> FodNormalClass {get;set;}
    public list<PieWedgeData> NPSClass {get;set;}
    public list<wrapperClass> ceqInstClass {get;set;}
    public list<wrapperClass> ceqSaleClass {get;set;}
    public list<wrapperClass> ceqOtherClass {get;set;}
    public boolean fodTable {get;set;}
    public boolean caseTable {get;set;}
    public boolean aspTable {get;set;}
    public boolean fodChart {get;set;}
    public boolean caseChart{get;set;}
    public boolean aspChart{get;set;}
    date startDate;
    date endDate;
    public decimal avgNps{get;set;}
    public boolean saleChart{get;set;}
    public boolean custChart {get;set;}
    public boolean instChart{get;set;}
    
    
    public string region{get;set;}
    public string district{get;set;}
    
    public transient list<Failed_Install__c> failedList{get;set;}
    public transient list<Case> CaseList{get;set;}
    public transient list<ASP__c> aspList{get;set;}
    
    Utilities util = new Utilities();
    
    public list<selectoption> getRegionList()
    {
        list<selectoption> selectList = new list<selectoption>();
        selectList.add(new selectoption('','---All---'));
        for(Region__c re: [select id, Name from Region__c where Type__c ='Installation'])
        {
            selectList.add(new selectoption(re.Name,re.Name));
        }
        
        return  selectList; 
    }   
    
    public list<selectoption> getdistrictList()
    {
        list<selectoption> selectList = new list<selectoption>();
        selectList.add(new selectoption('','---All---'));
        for(District__c re: [select id, Name from District__c where Type__c ='Installation'])
        {
            selectList.add(new selectoption(re.Name,re.Name));
        }
        
        return  selectList; 
    }   
    
    List<string> ceqAnswers = new list<string>{'Yes','No', 'Customer Unavailable'};
    	
    
    string ceqItemQuery1 = 'Select Count(Id) cont,Report_Text__c,  GROUPING(Report_Text__c) rprt, AnswerPick__c, GROUPING(AnswerPick__c)  ans, Section__c from CEQ_Item__c ';
    string ceqItemQuery2 = ' and AnswerPick__c in: ceqAnswers group by ROLLUP(Report_Text__c,AnswerPick__c, Section__c) order by Report_Text__c  limit 50000';
    
    string caseQuery1 = 'Select count(Id) cont, Classification__c from Case where RecordTypeId= \'012200000009mdm\' and isClosed = false';
    string caseQuery2 = ' Group by Classification__c limit 50000 ';
    
    string ASPQuery1 = 'Select count(Id) cont, Function__c from ASP__c where Status__c= \'Submitted\'';
    string ASPQuery2= ' Group by Function__c limit 49999';
    
    string failedQuery1 = 'Select count(Id) cont, Cause__c from Failed_Install__c';
    string failedQuery2 =' Group by Cause__c limit 50000';
    
    string CEQCOunt = 'select  Count() from CEQ_Header__c limit 50000';
    
    String CreateDateQuery = ' where CreatedDate>=:startDate and CreatedDate<=:endDate';
    String CreateDateQueryWithout = ' and CreatedDate>=:startDate and CreatedDate<=:endDate';
    
    public CEQ_HomePageCont ()
    {
    	if(system.label.Validation_Rule_Switch =='yes')
    	startDate = system.today().adddays(-30);
        else
        startDate = system.today().adddays(-1);
        endDate   = system.today();
        
        job = new Job__c();
        job.Customer_Journey_First_Update__c = startDate;
        job.BGNE_Install_Date__c = endDate;
        
        //ceqHeader = 'a4Gg00000008bMFEAY' ;
        ceqHeaderClass = new  list<PieWedgeData> ();
        caseNormClass = new  list<PieWedgeData> ();
        ASPNormalClass = new  list<PieWedgeData> ();
        FodNormalClass = new  list<PieWedgeData> ();
        NPSClass = new list<PieWedgeData> ();
        ceqInstClass = new list<wrapperClass>();
        ceqSaleClass = new list<wrapperClass>();
        ceqOtherClass = new list<wrapperClass>();
        
        //list<aggregateresult> aggreResult= [select Count(Id) cont,Report_Text__c,  GROUPING(Report_Text__c) rprt, AnswerPick__c, GROUPING(AnswerPick__c)  ans, Section__c from CEQ_Item__c group by ROLLUP(Report_Text__c,AnswerPick__c, Section__c)  order by Report_Text__c, AnswerPick__c];
        list<aggregateresult> aggreResult= database.query(ceqItemQuery1+CreateDateQuery+ceqItemQuery2);
        innerclassForCeq(aggreResult) ; 
         
        system.debug('My New Class-->'+ceqInstClass); 
         
        /*list<aggregateresult> Caseresult = [Select count(Id), GROUPING(Sales_Region__c) rgn, GROUPING(Classification__c) classi from Case where RecordTypeId= '012200000009mdm' and isClosed = false Group by CUBE(Sales_Region__c,Classification__c )
                                            Order by GROUPING(Sales_Region__c) , GROUPING(Classification__c), Sales_Region__c, Classification__c];
        
        //list<aggregateresult> caseNormalResult = [Select count(Id) cont, Classification__c from Case where RecordTypeId= '012200000009mdm' and isClosed = false Group by Classification__c];
        list<aggregateresult> caseNormalResult = database.query(caseQuery1+CreateDateQueryWithout+caseQuery2);
        for(aggregateresult ag: caseNormalResult)
        {
            caseNormClass.add(new PieWedgeData(string.valueof(ag.get('Classification__c')), integer.valueof(ag.get('cont'))));
        } 
        
        //list<aggregateresult> ASPNormalResult = [Select count(Id) cont, Function__c from ASP__c where Status__c= 'Submitted' and CreatedDate> =:startDate and CreatedDate <= :endDate Group by Function__c ];
        list<aggregateresult> ASPNormalResult = database.query(ASPQuery1+CreateDateQueryWithout+ASPQuery2);
        for(aggregateresult ag: ASPNormalResult)
        {
            ASPNormalClass.add(new PieWedgeData(string.valueof(ag.get('Function__c')), integer.valueof(ag.get('cont'))));
        } 
        
        
        //list<aggregateresult> FODNormalResult = [Select count(Id) cont, Cause__c from Failed_Install__c where CreatedDate> =:startDate and CreatedDate <= :endDate Group by Cause__c ];
        list<aggregateresult> FODNormalResult =database.query(failedQuery1+CreateDateQuery+failedQuery2);
        for(aggregateresult ag: FODNormalResult)
        {
            FodNormalClass.add(new PieWedgeData(string.valueof(ag.get('Cause__c')), integer.valueof(ag.get('cont'))));
        } 
        //startDate = system.today().adddays(-100);
        /*
        list<aggregateresult> NPSResult = [Select count(STEP1_Score__c) cont from NPS__c ];
        for(aggregateresult ag: NPSResult )
        {
            //NPSClass.add(new PieWedgeData(string.valueof(ag.get('Opportunity__r.Sales_Region__c')), integer.valueof(ag.get('cont'))));
               avgNps = integer.valueof(ag.get('cont'));
        }
       // avgNps = [Select avg(STEP1_Score__c)  from NPS__c where CreatedDate> =:startDate and CreatedDate <= :endDate];
           
    }    
    // Wrapper class
    public class PieWedgeData {

        public String name { get; set; }
        public Integer data { get; set; }

        public PieWedgeData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }
    
    
    public void refreshData()
    {
        if(!checkDates())
        {
	       
	        
	        ceqHeaderClass = new  list<PieWedgeData> ();
	        caseNormClass = new  list<PieWedgeData> ();
	        ASPNormalClass = new  list<PieWedgeData> ();
	        FodNormalClass = new  list<PieWedgeData> ();
	        NPSClass = new list<PieWedgeData> ();
	        ceqInstClass = new list<wrapperClass>();
	        ceqSaleClass = new list<wrapperClass>();
	        ceqOtherClass = new list<wrapperClass>();
	        startDate =  job.Customer_Journey_First_Update__c ;
	        endDate   =  job.BGNE_Install_Date__c;
	        
	        if(job.Customer_Journey_First_Update__c!=null && job.BGNE_Install_Date__c!=null)
	        {
	         String CreateDateQuery = ' and CreatedDate>=:startDate and CreatedDate<=:endDate';
	         string CreateDateQueryWith = ' Where CreatedDate>=:startDate and CreatedDate<=:endDate';
	         string ceqFinalQuery;
	         string caseFinalQuery;
	         string ASPFinalResult;
	         string FODFinalQuery;
	         
	         if(district!=null && district!='')
	         {
	         	 string DistrictQuery = ' and CEQ_Header__r.Job__r.District__r.Name =:district';
	             ceqFinalQuery=ceqItemQuery1+CreateDateQueryWith+DistrictQuery+ceqItemQuery2;
	             system.debug('CEQ --->'+ceqFinalQuery);
	             
	             DistrictQuery = ' And Account.Sales_District__c =:district';
	             caseFinalQuery = caseQuery1+CreateDateQuery+DistrictQuery+caseQuery2;
	             
	             system.debug('caseFinalQuery --->'+caseFinalQuery );
	             
	             DistrictQuery = ' And Quote__r.Opportunity__r.DistrictName_Sales__c =:district';
	             ASPFinalResult = ASPQuery1 +CreateDateQuery+DistrictQuery + ASPQuery2;
	             
	             system.debug('ASPFinalResult --->'+ASPFinalResult );
	              
	             DistrictQuery = ' and Job__r.District__r.Name =:district';
	             FODFinalQuery= failedQuery1+CreateDateQueryWith+DistrictQuery + failedQuery2;
	         	
	         }
	         
	         else if(region!='' && region!=null)
	         {
	             string RegionQuery = ' and CEQ_Header__r.Job__r.Region__c =:region';
	             ceqFinalQuery=ceqItemQuery1+CreateDateQueryWith+RegionQuery+ceqItemQuery2;
	             system.debug('CEQ --->'+ceqFinalQuery);
	             
	             RegionQuery = ' And Sales_Region__c =:region';
	             caseFinalQuery = caseQuery1+CreateDateQuery+RegionQuery+caseQuery2;
	             
	             system.debug('caseFinalQuery --->'+caseFinalQuery );
	             
	             RegionQuery = ' And Quote__r.Opportunity__r.Sales_Region__c =:region';
	             ASPFinalResult = ASPQuery1 +CreateDateQuery+RegionQuery + ASPQuery2;
	             
	             system.debug('ASPFinalResult --->'+ASPFinalResult );
	              
	             RegionQuery = ' and Job__r.Region__c =:region';
	             FODFinalQuery= failedQuery1+CreateDateQueryWith+RegionQuery + failedQuery2;
	             
	              system.debug('ASPFinalResult --->'+FODFinalQuery);
	        } else
	        {
	            
	             ceqFinalQuery=ceqItemQuery1+CreateDateQueryWith+ceqItemQuery2;
	             
	             caseFinalQuery = caseQuery1+CreateDateQuery+caseQuery2;
	             
	             ASPFinalResult = ASPQuery1 +CreateDateQuery+ ASPQuery2;
	             
	             FODFinalQuery= failedQuery1+CreateDateQueryWith+failedQuery2;
	        }
	          
	        list<aggregateresult> aggreResult= database.query(ceqFinalQuery);
	        innerclassForCeq(aggreResult);   
	        
	        list<aggregateresult> caseNormalResult = database.query(caseFinalQuery );
	        for(aggregateresult ag: caseNormalResult)
	        {
	            caseNormClass.add(new PieWedgeData(string.valueof(ag.get('Classification__c')), integer.valueof(ag.get('cont'))));
	        } 
	        
	        list<aggregateresult> ASPNormalResult = database.query(ASPFinalResult );
	        for(aggregateresult ag: ASPNormalResult)
	        {
	            ASPNormalClass.add(new PieWedgeData(string.valueof(ag.get('Function__c')), integer.valueof(ag.get('cont'))));
	        } 
	        
	        list<aggregateresult> FODNormalResult = database.query(FODFinalQuery);
	        for(aggregateresult ag: FODNormalResult)
	        {
	            FodNormalClass.add(new PieWedgeData(string.valueof(ag.get('Cause__c')), integer.valueof(ag.get('cont'))));
	        } 
	        }
        }
        
    }  
    
    public boolean checkDates()
    {
        utilities util = new utilities();
        if(job.Customer_Journey_First_Update__c==null || job.BGNE_Install_Date__c==null)
        {
            util.setErrorMsg(true, 'Start & End can not be blank.');
            return true;
        }
        if(job.Customer_Journey_First_Update__c>job.BGNE_Install_Date__c)
        {
            util.setErrorMsg(true, 'Start can not be greater then End.');
            return true;
        }else if(job.BGNE_Install_Date__c.daysbetween(job.Customer_Journey_First_Update__c)>200)
        {
        	util.setErrorMsg(true, 'Please reduce the window between Start & End Date');
            return true;
        }
        return false;
    }  
    
    public void fetchFOD()
    {
    	try{
    	 string fodQuery1 = 'Select Job__c, Cause__c, Date_Failed__c,	District__c,Installer__c,Name, Reason__c  from Failed_Install__c where CreatedDate>=:startDate and CreatedDate<=:endDate';
    	 string fodQuery2 = ' order by Installer__c, Cause__c, Reason__c limit 9999';
    	 string regionCri = ' and Job__r.Region__c =:region';
    	 string DistrictCri = ' and Job__r.District__r.Name =:district'; 	
         startDate =  job.Customer_Journey_First_Update__c ;
         endDate   =  job.BGNE_Install_Date__c;
        
         String finalFodQuery;	
         if(district!='' && district!=null)
         {
         finalFodQuery = fodQuery1+DistrictCri+fodQuery2;
         }
         else if(region!='' && region!=null)
         {
         finalFodQuery = fodQuery1+regionCri+fodQuery2;
         }else
         {
         //failedList = [Select Job__c, Cause__c, Date_Failed__c,	District__c,Installer__c,Name, Reason__c  from Failed_Install__c where CreatedDate>=:startDate and CreatedDate<=:endDate order by Installer__c, Cause__c, Reason__c];
         finalFodQuery = fodQuery1+ fodQuery2;
         }
         failedList = database.query(finalFodQuery);
         if(failedList.size()>0)
         {
         	resetBoolean();
         	fodChart = true;
         	fodTable =true;
         }
    	}catch(Exception e)
    	{
    		failedList.clear();
    		util.setErrorMsg(true, 'Large amount of data is being fetched.Please Reduce the number of days or use Geograhy parameters.');
    	}
        
    }   
    
    public void fetchCases()
    {
    	try{
    	 string caseQuery1 = 'Select  CaseNumber,Classification__c,AccountId, Sales_Region__c, Account.Sales_District__c,Status from Case where RecordTypeId= \'012200000009mdm\' and isClosed = false and CreatedDate>=:startDate and CreatedDate<=:endDate';
    	 string caseQuery2 = ' order by Classification__c, Sales_Region__c limit 9999';
    	 string regionCri = ' and Sales_Region__c =:region';
    	 string DistrictCri = ' And Account.Sales_District__c =:district'; 	
         startDate =  job.Customer_Journey_First_Update__c ;
         endDate   =  job.BGNE_Install_Date__c;
        
         String finalcaseQuery;	
         
         if(district!='' && district!=null)
         {
         finalcaseQuery = caseQuery1+DistrictCri+caseQuery2;
         }
         else if(region!='' && region!=null)
         {
         finalcaseQuery = caseQuery1+regionCri+caseQuery2;
         }else
         {
         //failedList = [Select Job__c, Cause__c, Date_Failed__c,	District__c,Installer__c,Name, Reason__c  from Failed_Install__c where CreatedDate>=:startDate and CreatedDate<=:endDate order by Installer__c, Cause__c, Reason__c];
         finalcaseQuery = caseQuery1+ caseQuery2;
         }
         CaseList = database.query(finalcaseQuery);
         if(CaseList.size()>0)
         {
         	resetBoolean();
         	caseChart=true;
         	caseTable =true;
         }
    	}catch(exception e)
    	{
    		util.setErrorMsg(true, 'Large amount of data is being fetched.Please Reduce the number of days or use Geograhy parameters.');
    	}
        
    }
    
    
    public void fetchASPs()
    {
    	try{
    	 string aspQuery1 = 'Select Name, Function__c,Definition__c,Picklist__c,Charge_to_Customer__c,App_Assigned_To__c  from ASP__c where Status__c= \'Submitted\' and CreatedDate>=:startDate and CreatedDate<=:endDate';
    	 string aspQuery2 = ' order by Function__c,  Definition__c,Picklist__c';
    	 string regionCri = ' And Quote__r.Opportunity__r.Sales_Region__c =:region';
    	 string DistrictCri = ' And Quote__r.Opportunity__r.DistrictName_Sales__c =:district'; 	
         startDate =  job.Customer_Journey_First_Update__c ;
         endDate   =  job.BGNE_Install_Date__c;
        
         String finalaspQuery;	
         
         if(district!='' && district!=null)
         {
         finalaspQuery = aspQuery1+DistrictCri+aspQuery2;
         }
         else if(region!='' && region!=null)
         {
         finalaspQuery = aspQuery1+regionCri+aspQuery2;
         }else
         {
         //failedList = [Select Job__c, Cause__c, Date_Failed__c,	District__c,Installer__c,Name, Reason__c  from Failed_Install__c where CreatedDate>=:startDate and CreatedDate<=:endDate order by Installer__c, Cause__c, Reason__c];
	        util.setErrorMsg(true, 'Large amount of data is being fetched.Please Reduce the number of days or use Geograhy parameters.');
	        return;
         }
         aspList = database.query(finalaspQuery);
         if(aspList.size()>0)
         {
         	resetBoolean();
         	aspChart= true;
         	aspTable =true;
         }
    	}catch(Exception e)
    	{
    		aspList.clear();
    		util.setErrorMsg(true, 'Large amount of data is being fetched.Please Reduce the number of days or use Geograhy parameters.');
    	}
        
    }
    
    
   public class wrapperClass
   {
   		public string value1 {get;set;}
   		public integer countVal{get;set;}
   		public integer countVal2{get;set;}
   		public integer countVal3 {get;set;}
   		
   		
   		public wrapperClass(string value1 , integer countVal2,integer countVal)
   		{
   			this.value1 = value1;
   			this.countVal2 = countVal2;
   			//value3 = value3;
   			this.countVal = countVal;
   		}
   		
   		
   	
   }
   
   private void resetBoolean()
   {
   	fodTable = false;
   	caseTable = false;
   	aspTable = false;
   	fodChart = false;
   	caseChart = false;
   	aspChart = false;
   	saleChart = false;
   	custChart = false;
   	instChart = false;
   }  
   
   private void innerclassForCeq(list<aggregateresult> aggreResult)
   {
   		Map<string, wrapperClass> wrapperMap = new Map<string, wrapperClass>();
        Map<string, wrapperClass> wrapperMapSal = new Map<string, wrapperClass>();
        Map<string, wrapperClass> wrapperMapOther = new Map<string, wrapperClass>();
        
   		for(aggregateresult ag: aggreResult)
        {
        	
        	
        	if(integer.valueof(ag.get('rprt'))==0 && integer.valueof(ag.get('ans'))==0)
        	{
        		if(string.valueof(ag.get('Section__c'))== 'Installation')
	        	{
		        		system.debug('aggreResult-->'+ag);
		        		string question = string.valueof(ag.get('Report_Text__c')).substring(0,1);
		        		if(!wrapperMap.containskey(question))
		        		{
		        			wrapperClass innerClassVar = new wrapperClass(question,  integer.valueof(ag.get('cont')), 0);
		        			ceqInstClass.add(innerClassVar);
		    				wrapperMap.put(question, innerClassVar);
		        		}else
		        		{
		        			wrapperMap.get(question).countVal=  integer.valueof(ag.get('cont'));
		        		}
		        		//else if (ag.get('AnswerPick__c') == 'No')
		        		system.debug('My New Class in Loop-->'+ceqInstClass); 
		         	
	        	}else if(string.valueof(ag.get('Section__c'))== 'Sales')
	        	{
	        		system.debug('aggreResult-->'+ag);
	        		string question = string.valueof(ag.get('Report_Text__c')).substring(0,1);
	        		if(!wrapperMapSal.containskey(question))
	        		{
	        			wrapperClass innerClassVar = new wrapperClass(question,  integer.valueof(ag.get('cont')), 0);
	        			ceqSaleClass.add(innerClassVar);
	    				wrapperMapSal.put(question, innerClassVar);
	        		}else
	        		{
	        			wrapperMapSal.get(question).countVal=  integer.valueof(ag.get('cont'));
	        		}
	        		//else if (ag.get('AnswerPick__c') == 'No')
	        		system.debug('My New Class in Loop-->'+ceqInstClass); 
	        		
	        	}else if(string.valueof(ag.get('Section__c'))== 'Customer')
	        	{
	        		system.debug('aggreResult-->'+ag);
	        		string question = string.valueof(ag.get('Report_Text__c')).substring(0,1);
	        		if(!wrapperMapOther.containskey(question))
	        		{
	        			
	        			wrapperClass innerClassVar = new wrapperClass(question,  0, 0);
	        			innerClassVar.countVal3= integer.valueof(ag.get('cont'));
	        			ceqOtherClass.add(innerClassVar);
	    				wrapperMapOther.put(question, innerClassVar);
	    				
	        		}else
	        		{
	        			if(string.valueof(ag.get('AnswerPick__c'))=='Yes')
	        			wrapperMapOther.get(question).countVal=  integer.valueof(ag.get('cont'));
	        			else if(string.valueof(ag.get('AnswerPick__c'))=='No')
	        			wrapperMapOther.get(question).countVal2=  integer.valueof(ag.get('cont'));
	        		}
	        		//else if (ag.get('AnswerPick__c') == 'No')
	        		system.debug('My New Class in Loop-->'+ceqInstClass); 
	        		
	        	}	
        	}
        }	
   }
   
   public void showFailedJobs_Large()
   {
   	    resetBoolean();
   		fodChart = true;
   }
   
   public void showCases_Large()
   {
   	    resetBoolean();
   		caseChart = true;
   }
   
   public void showASPS_Large()
   {
   	    resetBoolean();
   		aspChart = true;
   }
   public void showSales_Large()
   {
   	    resetBoolean();
   		saleChart = true;
   }
   public void showInstallation_Large()
   {
   	    resetBoolean();
   		instChart = true;
   }
   
   public void showCustomer_Large()
   {
   	    resetBoolean();
   		custChart = true;
   }     
   */
}