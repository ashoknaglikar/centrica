public with sharing class captureLandlordDetails {
    
    Landlord_Record__c landObj = new Landlord_Record__c();
    
    id AccountId = system.currentPageReference().getParameters().get('accId');
    id chiLeadId = system.currentPageReference().getParameters().get('chiLeadId');
    
    public Contact LanlordContact{get;set;} 
    
    public Contact billingContact{get;set;}
    
    public boolean editMode{get;set;}  
    
    public boolean showBilling{get;set;}
    
    public boolean showOverSeaAdd {get;set;}
    
    public boolean removeFirstNameBool{get;set;}
    public string source = system.currentPageReference().getParameters().get('source');
    
    public Opportunity opp {get;set;} 
    //public boolean showCaptureNewBill {get;set;}
    
    //public boolean showCaptureNewOver{get;set;}
    
    //change by Ashok G starts
    public string existingLead{get;set;}
    public boolean newInbound{get;set;}
    
    //End
    
    string message ='';
    
    Utilities util = new Utilities();
    
    boolean mutliPremise = false;
    
    public captureLandlordDetails()
    {
        LanlordContact = new Contact();
        billingContact = new Contact();
        existingLead = System.currentPageReference().getParameters().get('existingLead'); //to know lead exists or not
        newInbound = System.currentPageReference().getParameters().get('new')=='true'?true:false;
        system.debug('######existingLead'+existingLead+ newInbound);
        opp = new Opportunity(id = chiLeadId);
        opp = [Select id , Landlords_permission__c,Bill_Street__c,Bill_City__c,Bill_State__c,Bill_Post_Code__c,Bill_Country__c ,Live_Abroad__c,Bill_Title__c , 
               Bill_FirstName__c, Bill_LastName__c,BillingAddress__c,Customer_Name__c,  Install_Address_Street__c,Install_Address_City__c,
               Install_Address_County__c,  Install_Postcode__c, Multi_Premise__c from Opportunity where id = :chiLeadId];
    
        boolean landlord = false, prim = false;
        if(null!=AccountId)
        {
        List<Contact> contactList = [select id, Contact_Type__c, Salutation, FirstName, LastName, MobilePhone, Preferred_Contact_Method__c, 
                                    email, OtherPhone, HomePhone,MailingStreet, MailingState,MailingCity , MailingCountry, MailingPostalCode,
                                    Primary_Contact__c,Live_Abroad__c,Email__c,Multi_Premise__c from Contact  where AccountId = : AccountId order by CreatedDate desc];
        
        
        removeFirstNameBool=false;
        
        for(Contact c: contactList)
        {
            if((c.Contact_Type__c == 'Landlord'|| c.Contact_Type__c == 'Agent' || c.Contact_Type__c == 'Multi-premise') && !landlord)
            {
                landlord = true;
                LanlordContact = c;
                if(c.Contact_Type__c == 'Multi-premise')
                mutliPremise = true;
            }else if(c.Primary_Contact__c && !prim)
            {
                prim = true;
                billingContact = c;
                if(opp.Bill_Title__c=='')
                {
                    opp.Bill_Title__c = billingContact.Salutation;
                    opp.Bill_FirstName__c = billingContact.FirstName;
                    opp.Bill_LastName__c = billingContact.LastName;
                    opp.Bill_Street__c = billingContact.MailingStreet;
                    opp.Bill_City__c= billingContact.MailingCity;
                    opp.Bill_State__c= billingContact.MailingState;
                    opp.Bill_Post_Code__c= billingContact.MailingPostalCode;
                    opp.Bill_Country__c    = billingContact.MailingCountry;
                }
            }
            
            if(prim && landlord)        
            {
                break;
            }           
        }
        
        }
        editMode = system.currentPageReference().getParameters().get('edit')=='1'?true:false;   
        
        if(!landlord)
        util.setErrorMsg(false, 'please capture Landlord/Agent/Multi-Premise contacts for this Lead.');    
        
        
        if(editMode && opp.BillingAddress__c == 'No')
        showBilling = true;
                                    
    }
    
    public void invokeBillingAddressFunction()
    {
        string billingAdd = Apexpages.currentPage().getParameters().get('billingAdd');
        system.debug('LanlordContact-->'+billingAdd);
        if(billingAdd == 'No')
        {
            showBilling = true;
            opp.Bill_Title__c = LanlordContact.Salutation;
            
            if(LanlordContact.Salutation != 'Company' )
            opp.Bill_FirstName__c = LanlordContact.FirstName;
            
            opp.Bill_LastName__c = LanlordContact.LastName;
            opp.Bill_Street__c = LanlordContact.MailingStreet;
            opp.Bill_City__c = LanlordContact.MailingCity;
            opp.Bill_State__c = LanlordContact.MailingState;
            opp.Bill_Post_Code__c = LanlordContact.MailingPostalCode;
            opp.Bill_Country__c = 'United Kingdom';
            
        
            
        }else if(billingAdd == 'Yes')
        {
            showBilling = false;
            if(billingContact.Salutation!=null)
            {
            opp.Bill_Title__c = billingContact.Salutation;
            opp.Bill_FirstName__c = billingContact.FirstName;
            opp.Bill_LastName__c = billingContact.LastName;
            opp.Bill_Street__c = billingContact.MailingStreet;
            opp.Bill_City__c = billingContact.MailingCity;
            opp.Bill_State__c = billingContact.MailingState;
            opp.Bill_Post_Code__c = billingContact.MailingPostalCode;
            opp.Bill_Country__c = 'United Kingdom';
            }
        }
        
        //system.debug('showCaptureNewBill-->'+showCaptureNewBill);
    }
    
    public void invokeOverAddress()
    {
        system.debug('--->'+LanlordContact.Live_Abroad__c);
        if(opp.Live_Abroad__c == 'Yes')
        {
            showOverSeaAdd = true;
        }else
        {
            showOverSeaAdd= false;
            
        }  
        
    }
    
    public pagereference editBtn()
    {
        
        pagereference p  = new pagereference ('/apex/captureLandlordDetails?edit=1&chiLeadId='+chiLeadId+'&accId='+AccountId);
        p.setredirect(true);
        return p;
    }
    
    public pagereference saveDetails()
    {
        
        
        try{
            
            if(!mutliPremise)
            opp.Multi_Premise__c = null;
            else
            LanlordContact.Multi_Premise__c = opp.Multi_Premise__c;
            if(LanlordContact.Id==null)
            {
                if(checkContact())
                {
                    system.debug('#####5');
                    return null;
                }
                
                LanlordContact.AccountId = AccountId;
                
                insert LanlordContact;
            }else
            {
                if(checkContact())
                {
                    system.debug('#####5');
                    return null;
                }
                
                if(opp.BillingAddress__c == 'No' && LanlordContact.Live_Abroad__c!= 'Yes')
                {
                    LanlordContact.MailingStreet = opp.Bill_Street__c;
                    LanlordContact.MailingCity =opp.Bill_City__c;
                    LanlordContact.MailingPostalCode =opp.Bill_Post_Code__c;
                    LanlordContact.MailingState =opp.Bill_State__c;
                    LanlordContact.MailingCountry = 'United Kingdom';
                }
                update LanlordContact;
            }
            
            /*if(billingContact.id!=null)
            {
                //billingContact.BillingAddress__c = LanlordContact.BillingAddress__c;
                update billingContact;
            } */
            
            update opp;
            
            editMode = false;
            util.setErrorMsg(false, 'Sucesfully Saved');
        }catch(Exception e)
        {
            editMode  = true;   
            util.setErrorMsg(true, 'Something went wrong'+e.getmessage());
        }
            
        
        return (exitClick());
        
    }
    
    public boolean checkContact()
    {
        /*system.debug('############');
        system.debug(LanlordContact.Email__C);
        system.debug(LanlordContact.MobilePhone);
        system.debug(LanlordContact.HomePhone);
        system.debug(LanlordContact.OtherPhone);*/
        
        if(LanlordContact.Contact_Type__c  ==  'Multi-premise')
        mutliPremise = true;
        
        if(LanlordContact.Email__C == null && (LanlordContact.MobilePhone == null || LanlordContact.MobilePhone.trim() == '') && 
        (LanlordContact.HomePhone == null || LanlordContact.HomePhone.trim() == '')  && 
        (LanlordContact.OtherPhone == null || LanlordContact.OtherPhone.trim() == ''))
        {
            util.setErrorMsg(true, 'Please capture atleast one mode of contact.');
            system.debug('1');
            return true;
        }
            
        if(LanlordContact.Preferred_Contact_Method__c =='Email' && (LanlordContact.Email__C== null || LanlordContact.Email__C.trim()== ''))
        {
            util.setErrorMsg(true, 'Please enter Email address.');
            system.debug('2');
            return true;
        }else
        if(LanlordContact.Preferred_Contact_Method__c !='Email' && (LanlordContact.MobilePhone == null ||LanlordContact.MobilePhone.trim() == '') && (LanlordContact.HomePhone == null || LanlordContact.HomePhone.trim() == '') && (LanlordContact.OtherPhone == null||LanlordContact.OtherPhone.trim() == '' ))
        {
            util.setErrorMsg(true, 'Please enter one phone number.');
            system.debug('3');
            return true;
        }
        
        if(opp.BillingAddress__c=='No' && (opp.Bill_Street__c ==null || opp.Bill_Post_Code__c == null || opp.Bill_City__c == null))
        {
            util.setErrorMsg(true, 'Please capture Billing Address details.');
            system.debug('4');
            return true;
        }
        
        if(mutliPremise && opp.Multi_Premise__c == null)
        {
             util.setErrorMsg(true, 'Please capture Multi Premise name details.');
             return true;
        }   
       
        return false;
    }
    
    public pagereference exitClick()
    {
        if(source == 'IC' && !newInbound)
        {
            return new pagereference ('/apex/Wrapupscreenpage?chiLeadId='+chiLeadId+'&accId='+AccountId+'&existingLead='+existingLead);
        }else if(newInbound && source == 'IC'){
            return new pagereference ('/apex/new_Wrapupscreenpage?chiLeadId='+chiLeadId+'&accId='+AccountId+'&existingLead='+existingLead+'&new='+newInbound);
        }else
        {
            return new pagereference ('/'+chiLeadId);
            
        }
    }
    
    public pagereference bookAppointmet()
    {
        string gdeal = (opp.Product_Interest__c == 'Staright Swap' || opp.Product_Interest__c == 'Telesales Conv' || opp.Product_Interest__c == 'Staright Swap - Direct') ? '3': '0';
        
        if(opp.Landlords_permission__c!='Yes')
        {
            util.setErrorMsg(true, 'Landlord has not granted the permission.');
            return null;
        }
        saveDetails();
        
        if(editMode)
        return null;
        
        PageReference pageRef ;
        if(source == 'IC')
        {
        pageRef = new PageReference 
                ('/apex/availability?var_OpptyId='+  
                chiLeadId+'&var_Source=ICL&view=null&var_date=null&var_contactId='
                +billingContact.ID+'&var_cancelledapp=null' + 
                '&gDeal='+gdeal+'&new='+newInbound);
        }else
        {
            pageRef = new PageReference 
                ('/apex/availability?var_OpptyId='+  
                chiLeadId+'&var_Source=SF&view=null&var_date=null&var_contactId='
                +billingContact.ID+'&var_cancelledapp=null' + 
                '&gDeal='+gdeal+'&new='+newInbound);
        }        
                
        return pageRef;
    }
    
    public void removeFirstName(){
        if(opp.Bill_Title__c=='Company')
         removeFirstNameBool = true;
        else
         removeFirstNameBool = false;
  
    }
    

}