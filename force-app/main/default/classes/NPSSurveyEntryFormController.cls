/**
Type Name: NPSSurveyEntryFormController
Author: Cognizant
Created Date: 22/04/2010
Reason: To submit the First NPS and Second NPS survey through Email.
Both the NPS surveys are handled through the same class.
Change History:
*/

public class NPSSurveyEntryFormController 
{
	//Variable declaration section.
    public String ObjectID{get; set;}
    public Integer iHit;
    public String Comments{get; set;}
    public Boolean SurveyPosted{get; set;}
    public NPS__c Entry{get; set;}
    public String Err{get; set;}
    public Boolean IsErr{get; set;}
    public Boolean DisplayNoDataError{get; set;}
    public Boolean DisplayLinkAccessError{get; set;}
    public Boolean DisplayNPSExistsError{get; set;}
    public Boolean DisplayNoNPSExistsError{get; set;}
    public Boolean IsLoadError {get; set;}
    public String primaryContact = ''; //to display the contact details in the form
    public Opportunity opp{get; set;}
    public String PageBody{get; set;}
    public String PageComment{get; set;}
    public String PageSignature{get; set;}
    public String ErrComments{get; set;}
    public Boolean IsErrComments{get; set;}
     
    // To identify whether page is being dislpayed for england or scotland 
    public Boolean IsEnglish {get; set;} 
    
    public String ContactSalutation = '';
    public String ContactFirstName = '';
    public String ContactLastName = '';


    public String Hit
    {
        get
        {
            return iHit.format();
        } 
        set
        {
            try
            {
                iHit  = Integer.valueof(value);
            }
            catch(Exception ex)
            {
                System.debug('error in setter');
                iHit = -1;
                //on submit case of record type dectractor
            }
        }
    } 
    
    //Default constructor.   
    public NPSSurveyEntryFormController()
    {
        System.debug('## STEP 1 : inside NPSSurveyEntryFormController constructor');        
        SurveyPosted = false;
        IsErr = false;
        
                
        //retrieve the CHI Lead/NPS id passed to page
        ObjectID = System.currentPageReference().getParameters().get('s');
        
        //retrieve step count passed to page
        String stepCount = System.currentPageReference().getParameters().get('h');
        
        System.debug('## STEP 2 : ObjectID: '+ObjectID);    
        System.debug('## STEP 3 : stepCount: '+stepCount);    
        //set default value of control elements
        DisplayNoDataError = false;
        DisplayLinkAccessError = false;
        IsLoadError = false;
        IsEnglish = false; 
        iHit = -1;
        
        //Data validation
        if((stepCount == null || ObjectID == null) || (stepCount.trim()== '' || ObjectID.trim() == ''))
        {
            //display error message as some data is missing in querystring
            DisplayNoDataError = true;
            IsLoadError = true;
            return;
        }
        
        if(stepCount != '1' && stepCount != '2')
        {
            DisplayNoDataError = true;
            IsLoadError = true;
            return;
        }
                
        System.debug('## STEP 4 :--------------- surveyID = ' + ObjectID);
        
        /**
        If page is opened for first nps card
        This means that ObjectID should contain CHI Lead ID
        */
        
        System.debug('## STEP 5 :--------------- stepCount = ' + stepCount);
        if(stepCount == '1')
        {
            //fetching opportunity details
            List<Opportunity> lstOpps = [select id, name,
            Account.Primary_Contact_Email__c, Account.BillingCountry,
            Account.Primary_Contact_Last_Name__c, Account.Primary_Contact_First_Name__c,
            Account.Primary_Contact_Salutation__c,CHI_Lead_Id__c from opportunity
            where id =:ObjectID];
            
            System.debug('## STEP 6 :--------------- lstOpps = ' + lstOpps);
            if(lstOpps != null && lstOpps.size() > 0) 
            {  
                opp = lstOpps[0]; 
                ContactSalutation = opp.Account.Primary_Contact_Salutation__c;             
                ContactFirstName = opp.Account.Primary_Contact_First_Name__c;
                ContactLastName = opp.Account.Primary_Contact_Last_Name__c;
            }
            
            System.debug('## STEP 7 :--------------- opp = ' + opp);    
            //check if opp is null or not
            If (opp != null) 
            {
                //set if customer's country is England or not (to display appropriate logo)
                SetIsEnglish(opp.Account.BillingCountry);
                
                List<NPS__c> lstNPS = [select id, Step1_Score__c, Step2_Score__c, Step1_Comments__c, Step2_Comments__c, Status__c, Created_by_InstallationForce__c from NPS__c where CHI_Lead_Name__c =: opp.CHI_Lead_Id__c limit 1];
                        
                if(lstNPS != null && lstNPS.size() > 0)
                {
                     //display error message as nps is already posted for first nps form
                     DisplayNPSExistsError = true;
                     IsLoadError = true;
                     return;
                }
                else
                {
                     NPS__c newNPS = new NPS__c();
                     newNPS.Status__c = 'Step 1'; 
                     newNPS.Contact_Email__c = opp.Account.Primary_Contact_Email__c;
                     newNPS.CHI_Lead_Name__c = opp.CHI_Lead_Id__c; //updated
                     newNPS.Opportunity__c = opp.Id;
                     newNPS.Account__c = opp.AccountId;
                     newNPS.First_NPS_Email_Sent__c = true; 
                     newNPS.Created_by_InstallationForce__c = true;
                     //set acccount id for nps
                     Entry = newNPS;
                     System.debug('## STEP 8 :--------------- NPSStatus= ' + Entry.Status__c );
                }
            }
            else
            {
                DisplayNoDataError = true;
                IsLoadError = true;
                return;
            }
        }
        else
        {
            /**
            The page is opened for second nps card
            So ObjectId should contain NPS Id
            */
            List<NPS__c> lstNPS = [select id, Step1_Score__c,
            Account__r.BillingCountry, Step2_Score__c,
            Step1_Comments__c, Step2_Comments__c, Status__c,
            Created_by_InstallationForce__c,Account__r.Primary_Contact_Last_Name__c,
            Account__r.Primary_Contact_First_Name__c,
            Account__r.Primary_Contact_Salutation__c, 
            DontUpdateNpsManually__c from NPS__c where id =: ObjectID];
            
            System.debug('## STEP 9 : this is the list of NPS'+lstNPS+'the object id is'+ObjectID);
            
            if(lstNPS != null && lstNPS.size() > 0)
            {
               System.debug(Entry);
               Entry = lstNPS[0];
               
               ContactSalutation = Entry.Account__r.Primary_Contact_Salutation__c;             
               ContactFirstName = Entry.Account__r.Primary_Contact_First_Name__c;
               ContactLastName = Entry.Account__r.Primary_Contact_Last_Name__c;               
                              
               //set if customer's country is England or not (to display appropriate logo)
               SetIsEnglish(Entry.Account__r.BillingCountry);

               //Checks the status with the PageReference URL
               System.debug('## STEP 10 : Entry.Status__c: '+Entry.Status__c);
               System.debug('## STEP 11 : stepCount: '+stepCount);
               
               if((Entry.Status__c == 'Step 1' && stepCount == '1') || 
               (Entry.Status__c == 'Step 2' && stepCount == '2'))
               {
                    DisplayLinkAccessError = false;
               }
               else
               {
                    DisplayLinkAccessError = true;
                    IsLoadError = true;
                    return;          
               }
               
               if (Entry.Status__c == 'Step 1')
               {
                    DisplayNPSExistsError = true;
                    IsLoadError = true;
                    return;
               }
               else
               {
                    DisplayNPSExistsError = false;
               }
            }
            else
            {
                /**
                Display error message as this is second nps card and
                no nps record exists ->  fail condition.
                */  
                DisplayNoNPSExistsError = true;
                IsLoadError = true;
                return;
            }
        }
    }
    
    /**
    This method will be called when user submits the first NPS survey and
    Second NPS survey through the link from email.
    Also,NPS record is inserted /updated in this method.   
    */
    public PageReference PostSurvey()
    {
    	ErrComments = '';
    	IsErrComments = false;
    	
        if( Comments != null && Comments.length() > 32000 )
        {
        	ErrComments = 'Please enter comments opto 32000 characters only.';       
            IsErrComments = true;
            //Comments = null;
        }
        
        if(iHit < 0)
        {
        	if(ErrComments != '') ErrComments += '\n';
            ErrComments += 'Please select a value on scale.';       
            IsErrComments = true;
        }
        
        if(IsErrComments)
        {
        	//if data is invalid return null to display error message
        	return null;
        }
        
        //Updates the Status of the NPS and saves the data entered by the user 
        try
        {
            
            if(Entry.Status__c == 'Step 1')
            {
                Entry.Step1_Score__c = iHit;
                Entry.Step1_Comments__c = Comments;
                Entry.Status__c = 'Step 2';
                insert Entry;
            }
            else
            {
                Entry.Step2_Score__c = iHit;
                Entry.Step2_Comments__c = Comments;                
                Entry.Status__c = 'Step 3';
                /** 
                Following line added on 06/05/2010.
                Description: The field 'DontUpdateNpsManually__c' is added to manipulate validation rule
                so that if First NPS is sent through Email,Second NPS should not be edited manually 
                or through dataloader.
                */
                Entry.DontUpdateNpsManually__c = true;
                
                update Entry;
            }    
            Entry = null;  
            
            SurveyPosted = true;  
            
            PageReference pageRef= new PageReference('/apex/NPSThanksPage');
            pageRef.setRedirect(true);
            return pageRef;
        }        
        catch(Exception ex)
        {
            System.debug('err : ' + ex);
            return null;
        }
    }
    
    private void SetIsEnglish(String country)
    {
     String stepCount = System.currentPageReference().getParameters().get('h');
		PageComment = 'test data';
       if(stepCount == '1')
       {
            if( country != 'United Kingdom')
            {
                IsEnglish = false;
                PageBody = System.Label.NPS_Email_Form1_Scottish_Gas.replace('\n','<br>');  
                PageComment = System.Label.NPS_Email_Comment_Form_Scottish_Gas;  
                PageSignature = System.Label.NPS_Scotland_Managing_Director;        
            }
            else
            {
                IsEnglish = true;
                PageBody = System.Label.NPS_Email_Form1_British_Gas.replace('\n','<br>');
                PageComment = System.Label.NPS_Email_Comment_Form_British_Gas;
                PageSignature = System.Label.NPS_Britain_Managing_Director;
            }
        }
        else
        {
            if( country != 'United Kingdom')
            {
                IsEnglish = false;
                PageBody = System.Label.NPS_Email_Form2_Scottish_Gas.replace('\n','<br>');  
                PageComment = System.Label.NPS_Email_Comment_Form_Scottish_Gas;  
                PageSignature = System.Label.NPS_Scotland_Managing_Director;             
            }
            else
            {
                IsEnglish = true;
                PageBody = System.Label.NPS_Email_Form2_British_Gas.replace('\n','<br>');
                PageComment = System.Label.NPS_Email_Comment_Form_British_Gas;
                PageSignature = System.Label.NPS_Britain_Managing_Director;
            }

        }
       
        }
            
    
  //To display the contact details in the form
   public String getPrimaryContactDetails()
   {
        String salutation = '';
        String firstName = '';
        String lastName = '';        
                       
        if(ContactSalutation != null)
        {
            salutation = ContactSalutation ;
        }
        if(ContactFirstName != null)
        {
            firstName = ContactFirstName ;
        }
        if(ContactLastName != null)
        {
            lastName = ContactLastName ;
        }            
                primaryContact = salutation + ' ' + firstName + ' ' + lastName;
        
        return primaryContact;        
    }
    
}