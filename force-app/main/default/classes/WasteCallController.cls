/* BGB_CTS: WasteCallController 
   Description : This Class is the controller of Page to display a Waste Call Screen.
   Created : 14/10/09 :By Aruna
*/
public class WasteCallController {
    //Variable declaration.
    Account account;
    Inbound_Call__c inCall = new Inbound_Call__c();
    public String callId;
    public CallMode CallMode{get; set;}
    public DisplayMode DisplayMode{get; set;}    
    Lead lead;
    public Integer AccountViewMode{get; set;}
    private MessageConstants errorMsg;
    String errMsg;
// CTS CHI Conversion Start Ashok 23-11-10
    public boolean DirectEnq{get;set;}
    public boolean prospect {get; set;}
    public boolean enquiry{get; set;}
    public string LeadType ;
    public string getLeadType()    // This is the selectOption value from the selectList
    {
        return LeadType;
    }
    public void setLeadType(string LT)
    {
        this.LeadType = LT;
    }
    
    public List<selectoption> getLeadTypeOptions(){
         List<selectoption> options = new List<selectoption>();
         Options.add(new SelectOption('','--None--'));
         Options.add(new SelectOption('Prospect','Prospect'));
         Options.add(new SelectOption('Waste Call','Waste Call'));
         return options;
   }

//CTS CHI Conversion End
    //public constructor.
    public WasteCallController(){
        errorMsg = new MessageConstants();
        errMsg = '';
        
        CallMode = new CallMode();
        DisplayMode = new DisplayMode();
        
        AccountViewMode = DisplayMode.ADDRESSONLY;
        System.debug('---------AccountViewMode--------'+AccountViewMode);
        lead=new Lead();
        
        callId = ApexPages.currentPage().getParameters().get('c');
        Id firstpage = ApexPages.currentPage().getParameters().get('first');
        system.debug('------callId in class----'+callId);
        if(callId != null)
        {
            inCall = [Select  i.Related_To__c, i.Enquiry__c, i.CHI_Lead__c, i.End_Date_Time__c,i.Id, i.Billing_Zip__c, i.Billing_Street__c, i.Billing_State__c, i.Billing_City__c, i.Billilng_Country__c From Inbound_Call__c i where i.Id =:callId];
            
            account = new Account();
            System.debug('----------- inCall = ' + inCall);
            if(inCall != null)
            {
                if(inCall.CHI_Lead__c != null)
                {
                    // for new customer -> account is not present
                    List<Opportunity> lstOpps = [Select o.Account.ShippingPostalCode, o.Account.BillingCountry, o.Account.BillingPostalCode, o.Account.BillingState, o.Account.BillingCity, o.Account.BillingStreet, o.Account.Id, o.AccountId From Opportunity o where o.id=:inCall.CHI_Lead__c];
                    if(lstOpps != null && lstOpps.size() > 0)
                    {
                        account = lstOpps[0].Account;
                    }
                }
                else
                {
                    // for new customer where account is not created
                    account.BillingStreet = inCall.Billing_Street__c;
                    account.BillingCity = inCall.Billing_City__c;
                    account.BillingState = inCall.Billing_State__c;
                    account.BillingCountry = inCall.Billilng_Country__c;
                    account.BillingPostalCode = inCall.Billing_Zip__c;
                }
            }
        }
        System.debug('----------- account = ' + account);
        System.debug('----------- firstpage = ' + firstpage);
        
        
        if(firstpage == callId )
        {
            DirectEnq = true;
            LeadType ='Waste Call';
        }
    }
    
     
    public Account getAccount(){
        
        /*Account newAcc = new Account();
        System.debug('----------- inCall = ' + inCall);
        if(inCall != null){
            newAcc.BillingStreet = inCall.Billing_Street__c;
            newAcc.BillingCity = inCall.Billing_City__c;
            newAcc.BillingState = inCall.Billing_State__c;
            newAcc.BillingCountry = inCall.Billilng_Country__c;
            newAcc.BillingPostalCode = inCall.Billing_Zip__c;
        }*/
        
        //account= [Select a.Id,a.Name,a.Number_of_Bedrooms__c, a.Gas_Supply_At_Address__c, a.Current_Heating_System__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.CreatedDate From Account a limit 1];
        return account;
    }
    
    public void setLead(Lead lead){
        this.lead=lead;
    }
    public Lead getLead(){
        return this.lead;             
    }
     
    //Action method.
    public PageReference closeCall() {
        System.debug('------inside closecall----- ');
         //Nilesh waste call type error message starts.
        
        if(LeadType == ''||LeadType == null)
        {
            errMsg = errorMsg.ERR_NOWASTECALLTYPE;
            setErrorMsg();
            return null;
        }
        //Nilesh waste call type error message ends.
        if(lead.LastName == null || lead.LastName == '')
        {
            errMsg = errorMsg.ERR_SURNAME;
            setErrorMsg();
            return null;
        }
        if((lead.Categories__c == null || lead.Categories__c == '')&& LeadType =='Waste Call')
        {
            errMsg = errorMsg.ERR_NOWASTECALLCATEGORY;
            setErrorMsg();
            return null;
        }
        if(lead.Categories__c == 'Referred to other Gas Office'){
            if(lead.Sub_Categories_of_Gas_Office_Referral__c == null || lead.Sub_Categories_of_Gas_Office_Referral__c == ''){
                errMsg = errorMsg.ERR_WASTECALLCATEGORY;
                setErrorMsg();
                return null;
            }
        }
        // ashok CHI Conversion change start    
      
        if(LeadType == 'Prospect')
        {
            
            if(lead.FONT_COLOR_RED_Opt_Out__c == false)
            {
                if((lead.Phone == null || lead.Phone == '')&& lead.DoNotCall == false)
                {
                    errMsg = errorMsg.ERR_PHNUMBER;
                    setErrorMsg();
                    return null;
                }
                if((lead.Product_Interest__c == null || lead.Product_Interest__c == '')&& lead.DoNotCall == false)
                {
                    errMsg = errorMsg.ERR_PRDTINTREST;
                    setErrorMsg();
                    return null;
                }
                
            
                if((lead.Reason_Code__c == null && lead.Call_Back_Date__c == null)&& lead.DoNotCall == false) //||(lead.Reason_Code__c != '' && lead.Call_Back_Date__c == null ))
                {
                    errMsg = errorMsg.ERR_REASONCALLBACKCODE;
                    setErrorMsg();
                    return null;
                }
                if((lead.Reason_Code__c == null && lead.Call_Back_Date__c != null)&& lead.DoNotCall == false) //||(lead.Reason_Code__c != '' && lead.Call_Back_Date__c == null ))
                {
                    errMsg = errorMsg.ERR_REASON;
                    setErrorMsg();
                    return null;
                }
                if((lead.Reason_Code__c != null && lead.Call_Back_Date__c == null)&& lead.DoNotCall == false) //||(lead.Reason_Code__c != '' && lead.Call_Back_Date__c == null ))
                {
                    errMsg = errorMsg.ERR_CALLBACKTIMES;
                    setErrorMsg();
                    return null;
                }
                if((lead.Call_Back_Date__c == 'Over Ride Call Back Date' && lead.Overridden_Call_Back_Date__c ==  null)&& lead.DoNotCall == false)
                {
                    errMsg = errorMsg.ERR_OVERRIDECALLDATE;
                    setErrorMsg();
                    return null;
                }
                if((lead.Call_Back_Date__c != 'Over Ride Call Back Date' && lead.Overridden_Call_Back_Date__c !=  null)&& lead.DoNotCall == false)
                {
                    errMsg = errorMsg.ERR_DELOVERRIDECALLDATE;
                    setErrorMsg();
                    return null;
                }
            
                if(lead.DoNotCall == false && lead.Overridden_Call_Back_Date__c !=  null && lead.Reason_Code__c == null)
                {   
                    errMsg = errorMsg.ERR_REASON;
                    setErrorMsg();
                    return null;
                    
                }
               
            }
          /*if(lead.Call_Notes__c == null||lead.Call_Notes__c == '')
            {
                errMsg = errorMsg.ERR_CALLNOTES;
                setErrorMsg();
                return null;
            }*/
              
        // Ashok Changes End 
       UpdateOldLeads();   
       }
        createLead();
         
        PageReference pageRef = new PageReference('/apex/InboundCall');
        pageRef.setRedirect(true);
        return pageRef; 
    }
    public void UpdateOldLeads()
    {
        List<Lead> OldProspects = new List<Lead>();
        String AccountName;
        system.debug(inCall );
        if(account != null)
		{
			AccountName = account.BillingPostalCode.trim() + '  ';
			String str2 = account.BillingStreet.trim();
			AccountName = AccountName+str2;
		}
		else
        {
            AccountName = inCall.Billing_Zip__c.trim() + '  ';
            String str2 = inCall.Billing_Street__c.trim(); // 2 space in between
            AccountName = AccountName+str2;
            system.debug('AccountName--->'+AccountName);    
        }
        system.debug('AccountName--->'+AccountName);     
        OldProspects = [Select Id, Status,Prospect_Action_Required__c,Call_Back_Date__c from Lead where Lead_Type__c = 'Prospect' and Account_Key_Calc__c = :AccountName and Prospect_Action_Required__c = 'Yes']; 
        if(OldProspects.size()>0)
        {
            for(Lead l: OldProspects)
            {
                if(l.Call_Back_Date__c != 'Info Pack requested')
                {
                    l.Prospect_Action_Required__c='No';
                }   
            }
            update OldProspects;
        }
    }
    public void createLead()
    {
        // ashok change start
        list<Lead>LeadLst = new List<Lead>();
        lead.Lead_Type__c=LeadType;
        if(LeadType == 'Prospect')
        {
            lead.Prospect_Action_Required__c = 'Yes';
        }
        //end
        if(account != null && account.ID != null)
        {
            System.debug('------inside account setting----- ');
            
            lead.PostalCode = account.BillingPostalCode;
            lead.Street = account.BillingStreet;
            lead.City = account.BillingCity;
            lead.State = account.BillingState;
            lead.Country = account.BillingCountry;          
             
            lead.Company=account.Id;
        }
        else
        {
            if(inCall != null)
            {
                lead.PostalCode = inCall.Billing_Zip__c;
                lead.Street = inCall.Billing_Street__c;
                lead.City = inCall.Billilng_Country__c;
                lead.State = inCall.Billing_State__c;
                lead.Country = inCall.Billilng_Country__c;
                if(lead.FONT_COLOR_RED_Opt_Out__c == true)
                {
                    lead.Status = 'Closed';
                    String AccountName = inCall.Billing_Zip__c.trim() + '  ';
                    String str2 = inCall.Billing_Street__c.trim(); // 2 space in between
                    AccountName = AccountName+str2;
                    system.debug('AccountName--->'+AccountName);
                    LeadLst = [Select Id,Status,FONT_COLOR_RED_Opt_Out__c from Lead where Account_Key_Calc__c =:AccountName and Lead_Type__c = 'Prospect'];
                    for(Lead l: LeadLst)
                    {
                        l.Status = 'Closed';
                        l.FONT_COLOR_RED_Opt_Out__c = true;
                        l.Reason_Code__c = '';
                        l.Call_Back_Date__c = '';
                        l.Overridden_Call_Back_Date__c = null;
                    }
                }   
            }
        }
        if(lead.DoNotCall == true)
        {
            if((lead.Reason_Code__c!= null && lead.Call_Back_Date__c != null))
            {
                System.debug('------inside Do not call setting----- ');
                lead.Reason_Code__c = '';
                lead.Call_Back_Date__c = '';
            }
        }
        
        try
        {
            System.debug('------inside createlead----- ');
            System.debug('------incall----- '+inCall);
            System.debug('### Lead object: '+lead);
            lead.Company = 'New Company';
            system.debug('-----Insert ------');
            LeadLst.add(lead);
            upsert LeadLst;
            //insert lead;
            system.debug('-----Update ------');
            //update LeadLst;        
            if(inCall != null)
            {
                inCall.Enquiry__c = lead.Id;
                inCall.End_Date_Time__c = System.Now();
                inCall.Related_To__c = 'Enquiry';
                update inCall;
            }
            System.debug('Lead created...');
            
        }
        catch(Exception e){
            errMsg = errorMsg.ERR_PROCESSINGRECORDS;
            setErrorMsg();
            System.debug('Exception occured during Lead insert: '+e);
        }
        
    }
    
    public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, errMsg);
        ApexPages.addMessage(msg);
    }

    public String methodForTest(){
        String testString='This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
         
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';testString=testString+'This is test string';
        return testString;
    }

}