public with sharing class GreenDealQuestionnaireCont {

    public Green_Deal_Questions__c greenDealQues{get;set;}  
    public string genericMsg {get;set;}
    public boolean editMode {get;set;}
    public Job__c Job {get;set;}
    public transient string greenDealTitle{get;set;} 
    

    public integer renderdInt {get;set;}
    public boolean landTenQuest {get;set;}
    public boolean disableBenefit1{get;set;}
    public boolean disableBenefit2{get;set;}
    public boolean disableBenefit3{get;set;}
    public boolean disableConstraint{get;set;}
    Utilities util = new Utilities();
	public string checkpicString {get;set;}
	public string IBPRAB{get;set;}
	public string WHBPATV{get;set;}
	public string WCFS{get;set;}
	public string WCFTOL{get;set;}
	public string CTCOSPC{get;set;}
	
	public boolean A{get;set;}
	public boolean B{get;set;}
	
	public string Any_Constraints {get;set;}
	public boolean disableP_Constaints {get;set;}
	
	public boolean nonGD {get;set;}
	public string elecSuppl {get;set;}
	
	public string epc {get;set;}
	public string impEPC {get;set;}
	public boolean Hideepc {get;set;}
	public string PHGDV {get;set;}
	public boolean disPHGDV{get;set;}
	
	public string AHGDAR {get;set;}
	public boolean disAHGDAR{get;set;}
	public boolean disPHAWGDP {get;set;}
	public string PHAWGDP{get;set;}
	public boolean disCGDAAAPOP {get;set;}
	public string CGDAAAPOP {get;set;}
	public boolean Others{get;set;}
	public string custName{get;set;}
	public string street{get;set;}
	public string postcode{get;set;}
	public string city{get;set;}
	public string county{get;set;}
	public string email{get;set;}
	public string phone{get;set;}
	public string mobile{get;set;}
	public string cType{get;set;}
	id chiLeadId;
	public boolean AWroute{get;set;}
	public boolean createNew {get;set;}
    public GreenDealQuestionnaireCont(ApexPages.StandardController controller)
    {
    	A=false; B = false;
        renderdInt = 15;
        greenDealQues = new Green_Deal_Questions__c();
        greenDealQues = (Green_Deal_Questions__c)controller.getRecord();
        genericMsg = '';
        editMode = false;
       
        landTenQuest = false;
        disableBenefit1 = false;
        disableBenefit2 = false;
        disableBenefit3 = false;
        disableConstraint = false;
        AWroute = false;
        id JobId = system.currentPageReference().getParameters().get('jobId');
        id  gdExisting = system.currentPageReference().getParameters().get('id');
        string retUrl = system.currentPageReference().getParameters().get('retURL');
       	string view = system.currentPageReference().getParameters().get('view');
       	
        if(retUrl !='' && retUrl!=null )
        {
        	system.debug('-->'+retUrl);
        	if(view == '1')
        	{
        		
        	}else
        	{
        		editMode = true;
        	}
        	if(retUrl.startsWith('a0n'))
        	{
        		JobId = retUrl;
        	}else
        	if(retUrl.contains('006'))
        	{
        		if(retUrl.contains('/'))
        		chiLeadId= retUrl.right(retUrl.length()-1).substring(0,15);
        		else
        		chiLeadId = retUrl;
        	}
        }
        Opportunity chiLead = new Opportunity();
       	
        
        
        
        if(gdExisting!=null)
        {
        greenDealQues = [Select specify_improvements__c, improvements_due_to_EPC__c, energy_efficient_measures__c, 
                        Yes__c, Years_Energy_Bill__c, WHBPATV__c, WCFTOL__c, WCFS__c,LastModifiedById, LastModifiedDate,
                         Secondary_Heating__c, SOEGDP__c, Property_Constaints__c, Property_Age__c, Primary_Heating__c,
                         PHGDV__c, PHAWGDP__c, Others__c, No__c, Name, Meter_Type__c, MPAN__c,
                         Job__c, IsDeleted, Id, IBPRAB__c, GD_Qualified__c, GDPIIEP__c, GDA_Discussion__c, 
                         GDARRN__c, Energy_Performance_Certificate__c, Electric_Supplier__c, CreatedDate, CreatedById, 
                         CTCOSPC__c, CGDAAAPOP__c, Building_Type__c, Any_Constraints__c, Acess_Restictions__c, AYHTP__c, 
                         AHGDAR__c,Benefit_2B_3__c, Benefit_2B_2__c, Benefit_2B_1__c, Benefit_2A_2__c, 
                         Benefit_2A_1__c, Benefit_1B_4__c, Benefit_1B_3__c, Benefit_1B_2__c, Benefit_1B_1__c,
                         Benefit_1A_3__c, Benefit_1A_2__c, Benefit_1A_1__c,CHI_Lead__c  From Green_Deal_Questions__c where id = :gdExisting];
        }
        
        if(greenDealQues.Job__c!=null) 
        {                
        JobId =  greenDealQues.Job__c;     
        } 
        else if(JobId!=null)
        {
        JobId =  JobId;    
        }  
        
        if(greenDealQues.CHI_Lead__c!=null)
        {
        	chiLeadId = greenDealQues.CHI_Lead__c;
        }
        
        if(chiLeadId!=null)
       	{
       		chiLead = [Select Account.Primary_Contact__r.Contact_Type__c, CHI_Lead_Id__c,Account.Primary_Contact__r.Email,Mobile_Phone__c, Install_Postcode__c, Install_Address_Street__c, Install_Address_County__c, Install_Address_City__c, Home_Phone__c, Customer_Name__c,(Select Id From GD_Pre_Qualification_Questions__r), (Select id from Jobs__r where Is_Remedial_Job__c = false and Split_Job__c = false and Is_DownTime_Job__c =false)  From Opportunity where id = :chiLeadId];
       		custName = chiLead.Customer_Name__c;
       		street = chiLead.Install_Address_Street__c;
       		postcode = chiLead.Install_Postcode__c;
       		city = chiLead.Install_Address_City__c;
       		county = chiLead.Install_Address_County__c;
       		email = chiLead.Account.Primary_Contact__r.Email;
       		phone = chiLead.Home_Phone__c;
       		mobile = chiLead.Mobile_Phone__c;
       		cType = chiLead.Account.Primary_Contact__r.Contact_Type__c;
       		greenDealTitle = 'Green Deal Questionnaire: '+chiLead.CHI_Lead_Id__c;
       		if(chiLead.Jobs__r.size()>0)
       		{
       			JobId = chiLead.Jobs__r[0].Id;
       		}
       	}
        
        system.debug('Job Id---->'+JobId);
        if(gdExisting==null && chiLead.GD_Pre_Qualification_Questions__r.size()>0)
        {
        	gdExisting = chiLead.GD_Pre_Qualification_Questions__r[0].Id;
        }else
        {
        	if(view == '1')
        	{
	        	util.setErrorMsg(true, 'No Prequalification Records');
	        	createNew = true;
        	}
        }
        
        
         Job = new Job__c ();
        if(JobId!=null)
        {
      
	        Job = [Select Name ,Type__c, Customer_Name__c,Job_Type__c, CHI_Lead__c,CHI_Lead_Number_Text__c,Best_Phone_Number__c,Home_Phone__c,Install_Street__c,Install_City__c,Installation_County__c, 
	              CHI_Lead__r.Account.Primary_Contact__r.Contact_Type__c,Customer_Email_Address__c, Install_Postcode__c, (Select Id From Green_Deal_Questions__r)  from Job__c where Id = :JobId];
	        
	   		custName = Job.Customer_Name__c;
	   		street = Job.Install_Street__c;
	   		postcode = Job.Install_Postcode__c;
	   		city = Job.Install_City__c;
	   		county = Job.Installation_County__c;
	   		email = Job.Customer_Email_Address__c;
	   		phone = Job.Home_Phone__c;
	   		mobile = Job.Best_Phone_Number__c;
	   		cType = Job.CHI_Lead__r.Account.Primary_Contact__r.Contact_Type__c;
	   		greenDealTitle = 'Green Deal Questionnaire: '+Job.CHI_Lead_Number_Text__c;
	   		
	   		if(Job.Green_Deal_Questions__r.size()>0)
	   		{
	   			greenDealQues.Id=Job.Green_Deal_Questions__r[0].Id;
	   		}
    	}
        
     
        
       system.debug('---->'+JobId+chiLeadId);
      
        
        if(editMode && greenDealQues!=null)
        {
			//improve();
            
            if(greenDealQues.improvements_due_to_EPC__c == 'No')
			{
				renderdInt = 4 ;
				
			}
           
           	 // epcfunction();
           
           if(greenDealQues.Energy_Performance_Certificate__c == 'No')
			{
				renderdInt = 3;
				Hideepc= true;
				disPHAWGDP = true;
			}	
			
			
           //showlandlordQues();
			if(greenDealQues.WHBPATV__c == null || (greenDealQues.WHBPATV__c.contains('Landlord') || greenDealQues.WHBPATV__c.contains('Tenant')) )
			{
				landTenQuest = false;
			}
			else
			{
				 landTenQuest = true;
			}
			
			if(greenDealQues.WHBPATV__c == null || greenDealQues.WHBPATV__c.contains('Other') )
			{
				Others = false;
			}
			else
			{
				 Others = true;
			}
           
           
            
    		  
			
			
			//disableBenefitSection1();
			if(greenDealQues.IBPRAB__c == 'No')
			{
				disableBenefit1 = true;
				disableBenefit2 = true;
			}else
			{
				disableBenefit1 = false;
				disableBenefit2 = false;
			}
           // disableBenefitSection2();
           if(greenDealQues.CTCOSPC__c == 'Yes')
			{
				disableBenefit2 = true;
			}else
			{
				disableBenefit2=false;
			}
            //disableBenefitSection3();
            //disableP_Con();
            if( greenDealQues.Any_Constraints__c == 'No')
				disableP_Constaints = true	;
			else
				disableP_Constaints = false;
			
			if(greenDealQues.Energy_Performance_Certificate__c=='No')
			{
				renderdInt = 3;
				Hideepc= true;
			}	
           // showGDString();
           for(string s: system.label.GD_Suppliers.split(','))
			{
				if(greenDealQues.Electric_Supplier__c == null || greenDealQues.Electric_Supplier__c.contains(s))
				{
					nonGD = false;
					
				}else
				{
					nonGD = true;
				}
			}
          
            //PHGDVFunc();
            if(greenDealQues.PHGDV__c == 'No')
			{
				disPHGDV = true;
				disAHGDAR = true;
				disPHAWGDP = true;
				renderdInt = 5;
			}
			
				
            //AHGDARFunc();
            if(greenDealQues.AHGDAR__c == 'No')
			{
				disAHGDAR = true;
				disPHAWGDP = true;
			}
				
			
            //PHAWGDPFunc();
            if(greenDealQues.PHAWGDP__c == 'No')
			{
				disPHAWGDP = true;
				
			}
				
            
            //CGDAAAPOPFunc();
	   		if(greenDealQues.CGDAAAPOP__c == 'Yes' )
			{
				disCGDAAAPOP = true;
			}
	            
        } 
        if(greenDealQues!=null)
        {
	     //checkconsent1();
	        if(greenDealQues.WCFS__c == 'No')
			{
				renderdInt = 2;
				util.setErrorMsg(true, 'Customer is not Eligible for Green Deal.');
			}
			
			//checkconsent2();
	        
	        if(greenDealQues.WCFTOL__c == 'No')
			{
				renderdInt = 2;
				util.setErrorMsg(true, 'Customer is not Eligible for Green Deal.');
			}
			
			 //checkPicCap();
	        if(greenDealQues.AYHTP__c== 'No')
			{
				renderdInt = 0;
				util.setErrorMsg(true, 'Customer is not Eligible for Green Deal.');
			}
			
	        if(Job.Job_Type__c!=null && Job.Job_Type__c!='Green Deal' && Job.Job_Type__c!='GDF')
	        {
	      	  util.setErrorMsg(true, 'Job is not Green Deal.');
	          renderdInt = 0;	      
	        }
          
        }   
	}

    public pagereference save()
    {
    	System.debug(Job.Id);

    	if(greenDealQues.Job__c==null && Job.Id!=null)
    	greenDealQues.Job__c = Job.Id;
    	Boolean benefit =false;
    	if(greenDealQues.Benefit_1A_1__c==null && greenDealQues.Benefit_1A_2__c ==null && greenDealQues.Benefit_1A_3__c == null
    	 && greenDealQues.Benefit_1B_1__c==null && greenDealQues.Benefit_1B_2__c==null && greenDealQues.Benefit_1B_3__c==null 
    	 && greenDealQues.Benefit_1B_4__c==null && greenDealQues.Benefit_2A_1__c==null && greenDealQues.Benefit_2B_1__c==null
    	 && greenDealQues.Benefit_2B_2__c==null && greenDealQues.Benefit_2B_3__c==null)
    	 {
    	 	benefit=true;
    	 }
    	if(renderdInt>2 && greenDealQues.IBPRAB__c == 'Yes' && greenDealQues.CTCOSPC__c == 'No' && benefit)
    	{
    		util.setErrorMsg(true, 'Please Pick atleast one Benefit.');
    		return null;
    	}
    	
    	if(renderdInt>2 && !greenDealQues.Yes__c && ! greenDealQues.No__c)
    	{
    		util.setErrorMsg(true, 'Please answer Yes or No to Objection question.');
    		return null;
    	}
    	
    	if(greenDealQues.CHI_Lead__c==null)
    	greenDealQues.CHI_Lead__c = chiLeadId!=null ? chileadId: Job.CHI_Lead__c;
    	
    	if(greenDealQues.Job__c==null)
    	greenDealQues.Job__c = Job!=null? Job.Id:''; 
    	
    	upsert(greenDealQues); 
    	return (new pagereference ('/'+greenDealQues.Id));
       
        
    }
    
    public pagereference edit()
    {
    	pagereference p = new pagereference('/apex/GreenDealQuestionnaire?id='+greenDealQues.Id+'&retURL=e');
    	p.setRedirect(true);
    	return (p);
    }
    
    public pagereference cancel()
    {
    	if(chiLeadId!=null)
    	{
    		 return (new pagereference ('/'+chiLeadId));
    	}else if(Job.Id!=null)
    	{
        	return (new pagereference ('/'+Job.Id));
    	}
    	return null;
    }
    
    //inner class to show multipicklist in form of checkbox & Value

    
     
    // Check customer aggrees to take photos if not then customer is not eligible.
	public void checkPicCap()
	{
		
		system.debug('********** in checkPicCap*****'+checkpicString+greenDealQues.AYHTP__c);
		if(checkpicString == 'No')
		{
			system.debug('Pic Cap--->'+checkpicString);
			renderdInt = 0;
			util.setErrorMsg(true, 'Customer is not Eligible for Green Deal.');
		}else
		{
			renderdInt = 15;
		}
		
	}
	
	// Display extra 2 question in case of landlord or Tenant
	public void showlandlordQues()
	{
		system.debug('showlandlordQues-->'+WHBPATV+ ' '+ greenDealQues.WHBPATV__c);
		
		if(WHBPATV != null && (WHBPATV.contains('Landlord') || WHBPATV.contains('Tenant') || WHBPATV == '') )
		{
			landTenQuest = false;
		}
		else
		{
			 landTenQuest = true;
		}
		
		if(WHBPATV != null && (WHBPATV.contains('Other')|| WHBPATV == '') )
		{
			Others = false;
		}
		else
		{
			 Others = true;
		}
		
	}
	
	public void checkconsent1()
	{
		if(WCFS == 'No')
		{
			renderdInt = 2;
			util.setErrorMsg(true, 'Customer is not Eligible for Green Deal.');
		}else
		{
			renderdInt=15;
		}
	}
	
	public void checkconsent2()
	{
		if(WCFTOL == 'No'  )
		{
			renderdInt = 2;
			util.setErrorMsg(true, 'Customer is not Eligible for Green Deal.');
		}else
		{
			renderdInt=15;
		}
	}
	
	public void disableBenefitSection1()
	{
		
		if(IBPRAB == 'No' )
		{
			disableBenefit1 = true;
			disableBenefit2 = true;
		}else
		{
			disableBenefit1 = false;
			disableBenefit2 = false;
			
		}
	}
	
	public void disableBenefitSection2()
	{
		if(CTCOSPC == 'Yes')
		{
			disableBenefit2 = true;
			AWroute = true;
		}else
		{
			disableBenefit2=false;
			AWroute=false;
			
		}
	}
	
	public void disableBenefitSection3()
	{

		system.debug('**In disableBenefitSection3'+A +B);
		if(A&&B)
		{
			disableBenefit3 = true;
			AWroute = true;
		}else
		{
			disableBenefit3 = false;
			AWroute = false;
		}
	}
	
	
	public void disableP_Con()
	{
		if(Any_Constraints == 'No')
			disableP_Constaints = true	;
		else
			disableP_Constaints = false;
	}
	
	public void showGDString()
	{
		
		for(string s: system.label.GD_Suppliers.split(','))
		{
			system.debug('--->'+ s+ ' '+ elecSuppl);
			if((elecSuppl !=null && elecSuppl.contains(s) ))
			{
				nonGD = false;
				break;
				
			}else
			{
				nonGD = true;
			}
		}
	}
	
	public void epcfunction()
	{
		if(epc=='No' )
		{
			renderdInt = 3;
			Hideepc= true;
			disPHAWGDP = true;
		}	
		else
		{
			renderdInt = 15;
			Hideepc = false;
			disPHAWGDP =false;
		}
	}
	
	public void improve()
	{
		if(impEPC == 'No')
		{
			renderdInt = 4 ;
		}else
		{
			renderdInt = 15;
		}
	}
	
	public void PHGDVFunc()
	{
		if(PHGDV == 'No' )
		{
			disPHGDV = true;
			disAHGDAR = true;
			disPHAWGDP = true;
			
		}
		else
		{
			disPHGDV = false;
			disAHGDAR = false;
			disPHAWGDP = false;
			
		}	
		
	}
	
	public void AHGDARFunc()
	{
		if( AHGDAR == 'No')
		{
			disAHGDAR = true;
			disPHAWGDP = true;
		}
		else
		{
			disAHGDAR = false;
			disPHAWGDP = false;
		}	
	}
	
	public void PHAWGDPFunc()
	{
		if( PHAWGDP == 'No' )
		{
			disPHAWGDP = true;
			
		}
		else
		{
			disPHAWGDP = false;
		}	
	}
	
	public void CGDAAAPOPFunc()
	{
		if(CGDAAAPOP == 'Yes' )
		{
			disCGDAAAPOP = true;
		}else
		{
			disCGDAAAPOP = false;
		}
	}
	
	public void awRoute()
	{
		if(A&&B)
		{
			
			AWroute = true;
		}else
		{
			AWroute = false;
		}
	}
	
	public pagereference newCreate()
	{
		Pagereference p = new Pagereference('/apex/GreenDealQuestionnaire?retURL=%2F'+chiLeadId);
		p.setredirect(true);
		return p;
	}
	
}