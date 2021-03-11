@RestResource(urlMapping='/CustomerPortalFinanceApplication/*')
    global class CustomerPortalFinanceRestHelper {
        
        /* 
        This method is used for creation of finance application and checking if finance application already exist. It will
        send applicationId,application status and status as a reponse.
       */
        
        @HttpPost
        global static responseWrapper financeApplicationCreation(String oppId, String applicationDetails) {
            
            
            //String incomingJSON =JSON.serialize(new CustomerPortalFinance());//CustomerPortalHelper.decryptionOfData(financeApplication);//decryption of incoming Finance application
            
            // decryption of finance application Json
            string jsonAfterDecryption = CustomerPortalHelper.decryptionOfData(applicationDetails);
            // decryption of Opportunity ID
            String opportunityId = CustomerPortalHelper.getOpportunityId(oppId);
            
            Finance_Application__c customerPortal =new Finance_Application__c();
            // to store the response of incoming request
            responseWrapper responseJSON = new responseWrapper();
            // store the customer adddress from incoming json
            List< Map<String, Object>> customerAddress= new List<Map<String, Object>>();
            // store the employer Address from incoming json
            Map<String, Object> employerAddress = new Map<String, Object>(); 
            
            // get list of existing invalid finance applications without any statuse for deleteion
            list<Finance_Application__c> invalidApplications = new list<Finance_Application__c>();
            
            try{ 
                // check if finance application already exist
                List<Finance_Application__c> financeApp=[select id,Application_Status__c from Finance_Application__c where CHI_Lead__c =:opportunityId /*and Application_Status__c != NULL AND Finance_Product__r.Lender__c = 'Barclays'*/ ];
                
                for(Finance_Application__c fp: financeApp)
                {
                    if(fp.Application_Status__c == null || fp.Application_Status__c == '')
                    {
                        invalidApplications.add(fp);
                    }// checking for any valid applications.
                    else 
                    /* Code commeneted as lot of valid finance applications were being deleted 
                    if(CustomerPortalFinanceRestHelper.statusHelper(fp)!=null)*/
                    {
                        responseJSON.errorMessage.add('Finance application already exists.');
                        responseJSON.status = 'Error';
                        return responseJSON;
                    }/*else
                    {
                        invalidApplications.add(fp);
                    }*/
                    
                }
                
                
                
                //{
                if(!String.isBlank(jsonAfterDecryption)){
                    
                    
                    // deserialization of incoming json in class type
                    CustomerPortalFinance result=   (CustomerPortalFinance) JSON.deserialize(jsonAfterDecryption, CustomerPortalFinance.class);
                    system.debug('='+result);
                    //assigning the incoming finanace application in Finance_Application__c object 
                    customerPortal.Deposit__c = result.depositAmount;
                    customerPortal.Cash_Price__c = result.financeAmount;
                    customerPortal.Title__c=result.title ;   
                    customerPortal.First_Name__c= result.firstName ;
                    customerPortal.Middle_Name__c=result.middleName ;
                    customerPortal.Last_Name__c=result.lastName ;
                    customerPortal.Date_Of_Birth__c=date.parse(result.dateOfBirth);
                    customerPortal.Home_Phone__c=result.homePhone ;
                    customerPortal.Work_Phone__c=result.workPhone ;
                    customerPortal.Mobile__c=result.mobile ;
                    customerPortal.Email__c=result.email ;
                    customerPortal.Confirm_Email__c=result.email ;
                    customerPortal.Marital_Status__c=result.maritalStatus ;
                    customerPortal.Gender__c=result.gender ;
                    customerPortal.Nationality__c=result.nationality ;
                    customerPortal.Number_Of_Dependents__c=result.numberOfDependents ;
                    customerPortal.Employment_Status__c=result.employmentStatus ;
                    customerPortal.Cash_Price__c=result.financeAmount ;
                    customerPortal.Deposit__c=result.depositAmount ;
                    customerPortal.Job_Description__c=result.jobDescription ;
                    customerPortal.Gross_Annual_Income__c=result.grossAnnualSalary ;
                    customerPortal.Bank_Account_Name__c = result.nameOnBankAccount;
                    customerPortal.Time_At_Bank__c=result.timeAtBank ;
                    customerPortal.Bank_Account_Number__c=result.bankAccountNumber ;
                    customerPortal.Sort_Code__c=result.sortCode ;
                    customerPortal.Security_Question__c=result.securityQuestion ;
                    customerPortal.Security_Answer__c=result.securityAnswer ;
                    customerPortal.Number_Of_Credit_Cards__c = result.noOfCreditCards;
                    customerPortal.Monthly_Repayments__c = result.monthlyRepayments;
                    customerPortal.Request_Recieved__c = jsonAfterDecryption;
                    customerPortal.Portal_Quote__c = result.quoteId;
                    customerPortal.Income_Band__c = string.valueof(result.grossAnnualSalary);
                    customerPortal.Job_Total__c =  customerPortal.Deposit__c+ customerPortal.Cash_Price__c;
                    customerPortal.Rent__c = result.houserent;
                    customerPortal.Mortgage__c = result.mortgage;
                    customerPortal.Finance_Options__c = result.financeOptions;
                    customerPortal.Signature_Proof_of_Id__c = 'Not Sighted';
                    customerPortal.Sign_Proof_Details__c = 'N/A';
                    customerPortal.Adress_Proof_ID__c = 'Not Required';
                    customerPortal.Address_Proof_Details__c = 'N/A';
                    
                    If(result.customerAddress.size()>0){
                        customerPortal.Street1__c = result.customerAddress[0].street.replaceAll('[^a-zA-Z0-9]', ' ');
                        customerPortal.Post_Code1__c=result.customerAddress[0].postCode;
                        customerPortal.City1__c=removeSpeicalCharacters(result.customerAddress[0].city);
                        customerPortal.State1__c=removeSpeicalCharacters(result.customerAddress[0].state);
                        customerPortal.Country1__c=result.customerAddress[0].country;
                        customerPortal.Building_Number1__c=result.customerAddress[0].buildingHouseNumber;
                        customerPortal.Building_Name1__c=result.customerAddress[0].buildingHouseName;
                        customerPortal.Occupancy_Status1__c=result.customerAddress[0].occupancyStatus==null?'Not Asked':result.customerAddress[0].occupancyStatus;
                        customerPortal.Date_From1__c=result.customerAddress[0].dateFrom;
                        customerPortal.Year1__c=result.customerAddress[0].timeatAddressYear;
                        customerPortal.Month1__c=result.customerAddress[0].timeatAddressMonth ;
                    }
                    If(result.customerAddress.size()>1){
                        customerPortal.Street2__c = result.customerAddress[1].street.replaceAll('[^a-zA-Z0-9]', ' ');
                        customerPortal.Post_Code2__c=result.customerAddress[1].postCode;
                        customerPortal.City2__c=removeSpeicalCharacters(result.customerAddress[1].city);
                        customerPortal.State2__c=removeSpeicalCharacters(result.customerAddress[1].state);
                        customerPortal.Country2__c=result.customerAddress[1].country;
                        customerPortal.Building_Number2__c=result.customerAddress[1].buildingHouseNumber;
                        customerPortal.Building_Name2__c=result.customerAddress[1].buildingHouseName;
                        customerPortal.Occupancy_Status2__c=result.customerAddress[1].occupancyStatus==null?'Not Asked':result.customerAddress[1].occupancyStatus;
                        customerPortal.Date_From2__c=result.customerAddress[1].dateFrom;
                        customerPortal.Year2__c=result.customerAddress[1].timeatAddressYear;
                        customerPortal.Month2__c=result.customerAddress[1].timeatAddressMonth ; 
                    }
                    If(result.customerAddress.size()>2){
                        customerPortal.Street3__c = result.customerAddress[2].street.replaceAll('[^a-zA-Z0-9]', ' ');
                        customerPortal.Post_Code3__c=result.customerAddress[2].postCode;
                        customerPortal.City3__c=removeSpeicalCharacters(result.customerAddress[2].city);
                        customerPortal.State3__c=removeSpeicalCharacters(result.customerAddress[2].state);
                        customerPortal.Country3__c=result.customerAddress[2].country;
                        customerPortal.Building_Number3__c=result.customerAddress[2].buildingHouseNumber;
                        customerPortal.Building_Name3__c=result.customerAddress[2].buildingHouseName;
                        customerPortal.Occupancy_Status3__c=result.customerAddress[2].occupancyStatus==null?'Not Asked':result.customerAddress[2].occupancyStatus;
                        customerPortal.Date_From3__c=result.customerAddress[2].dateFrom;
                        customerPortal.Year3__c=result.customerAddress[2].timeatAddressYear;
                        customerPortal.Month3__c=result.customerAddress[2].timeatAddressMonth ;
                    }
                    if(result.EmployerAddress!=null)
                    {
                        customerPortal.Street_E__c =result.EmployerAddress.street;
                        customerPortal.Post_Code_E__c=result.EmployerAddress.postCode;
                        customerPortal.City_E__c=removeSpeicalCharacters(result.EmployerAddress.city);
                        customerPortal.State_E__c=removeSpeicalCharacters(result.EmployerAddress.state);
                        customerPortal.Country_E__c=result.EmployerAddress.country;
                        customerPortal.Building_Name_E__c=result.EmployerAddress.buildingHouseName ;
                        customerPortal.Employer_Name__c=result.EmployerAddress.employerName;
                        customerPortal.Employer_Phone__c=result.EmployerAddress.employerPhone;
                        customerPortal.YearE__c=result.EmployerAddress.timeatEmployerYear;
                        customerPortal.MonthE__c=result.EmployerAddress.timeatEmployerMonth;
                    }
                    
                    customerPortal.Income_Variation__c = result.incomeVariation;
                    customerPortal.Income_Variation_Value__c = result.incomeVariationValue;
                    customerPortal.Monthly_Expense__c = result.monthlyExpense;
                    customerPortal.Expense_Variation__c = result.expenseVariation;
                    customerPortal.Expense_Variation_Value__c = result.expenseVariationValue;
                   
                    //search for the finance product 
                    Finance_Product__c fp = [Select id, Payment_Options__c , Name, Interest_Rate__c From Finance_Product__c /*where Code__c = :result.typeOfFinance*/ limit 1];
                    // if finance product doesn't exist
                    if(fp == null )
                    {
                        responseJSON.errorMessage.add('No Finance Products Founds');
                        responseJSON.status = 'Error';
                        return responseJSON;
                        
                    }
                    // if finance product  exist,Populate the finance product and payment options
                    customerPortal.Finance_Product__c = fp.Id;
                    customerPortal.Payment_Options__c = fp.Payment_Options__c;
                    
                }     
                
                
                // populate the opportunity
                customerPortal.CHI_Lead__c = opportunityId;
                
                // populate the external Lead refernce number
                //customerPortal.Lead_Ext_Ref_No__c = CustomerPortalHelper.getExternalReference(opportunityId);
                
                // All Constants
                
                customerPortal.Type_of_Finance__c='e-Finance';
                
                customerPortal.Adress_Proof_ID__c = 'Home Delivery';
                
                customerPortal.Employment_Category__c = 'Not Asked';
                
                customerPortal.Alias__c = 'No';
                
                // insertion of finance application
                
                insert customerPortal ;
                
                // delete invalid applications
                if(invalidApplications.size()>0)
                delete invalidApplications;
                    
                // populating the response value for incoming request
                
                responseJSON.applicationID =customerPortal.id;
                responseJSON.applicationStatus = 'Sucessfully Appliation Created';
                responseJSON.status = 'Success';
                    
                    
                    
               // }
                /*else{
                    responseJSON.errorMessage.add('Finance Application Already exists.');
                    responseJSON.status = 'Error';
                }*/
            }
            Catch(Exception e){
                responseJSON.errorMessage.add(e.getMessage());
                responseJSON.status = 'Error';
            }
            return responseJSON;
        }
        
        
        /*
    
    This method is used to get the latest status update of the finance application using api and returns the Application Status
    Application Id back to Portal.
    */
        
        @HttpGet
        global static responseWrapper ApplicationStatus() {
            // getting finacece application Id from URL
            RestRequest req = RestContext.request;
            String financeApplicationId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            
            responseWrapper resObj = new responseWrapper();
            resObj.applicationID = financeApplicationId;
            
            
            resObj.status = 'Success';
            
            barclaysIntegrationHelper  barcalysHelper = new barclaysIntegrationHelper();
            // retrieving  the existing finance application
            List<Finance_Application__c> financeApplication = barcalysHelper.getFinanceApplication(new list<string>{financeApplicationId});
            
            if(financeApplication[0].Valid_New_Application__c)
            {
                Finance_Application__c tempApplication =  barclaysPhase3Helper.updateFinanceStatus(financeApplication[0]);
                
                if(tempApplication!=null)
                financeApplication[0] = tempApplication;
                
                resObj.signingLink = financeApplication[0].Finance_Link__c;
                resObj.lenderName = financeApplication[0].Lender_text__c;
                
                if(financeApplication[0].Application_Status__c == 'Declined')
                {
                    
                    resObj.declinedBy = new list<string>();
                    
                    if(financeApplication[0].Sent_To_2nd_lender__c!=null && financeApplication[0].Lender_text__c!='Barclays')
                    resObj.declinedBy.add('Barclays') ;
                    resObj.declinedBy.add(financeApplication[0].Lender_text__c);
                    
                }
                
            }else
            {
                try{
                    
                    if(financeApplication.size()>0)
                    {
                        system.debug('financeApplication[0]='+financeApplication[0]);
                        //getting tje latest status of the finance application from Barclays
                        wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element barcalysResponse = FinanceApplicationDetail.enquiryHelper(financeApplication[0]);
                        
                        system.debug('barcalysResponse='+barcalysResponse);
                        //errors while fetching the latest status of finance application
                        if(label.testsite == '1' && barcalysResponse!=null && barcalysResponse.Errors!= null && barcalysResponse.Errors.ErrorsWO.size()>0)
                        {
                            financeApplication[0].Error_Details__c +=System.Now(); 
                            resObj.status = 'Error';
                            financeApplication[0].Error_Details__c = string.valueof(System.Now()); 
                            for(wwwBarclaysPartnerfinanceCom.ErrorsWO err:barcalysResponse.Errors.ErrorsWO){
                                resObj.errorMessage.add(err.ErrorDescription);
                                
                                financeApplication[0].Error_Details__c +='  Next One: '+err.ErrorDescription;
                            }
                        }
                        else
                        {
                            // aasigning the latest status of application  to existing finance application.
                            
                            /*financeApplication[0].Application_Status__c = barcalysResponse.Application.ApplicationStatus;
                            financeApplication[0].status__c = barcalysResponse.Status;
                            financeApplication[0].Agreement_Number__c = barcalysResponse.Application.AgreementNumber;
                            */
                            resObj.declinedBy = new list<string>();
                            if(barcalysResponse.Application.ApplicationStatus == 'Declined')
                            resObj.declinedBy.add(financeApplication[0].Finance_Lender__c);
                            else
                            resObj.declinedBy = null;
                        }
                        
                    }
                }
                catch (Exception e) {
                    resObj.status = 'Error';
                    resObj.errorMessage.add(e.getMessage()+' ' +e.getLineNumber());
                    
                }
                
                resObj.signingLink = financeApplication[0].Document_Link__c;
                resObj.lenderName = financeApplication[0].Finance_Lender__c;
            }
            
           
            
            system.debug('Application_Status__c=='+financeApplication[0].Application_Status__c);
                        
            
            resObj.applicationID = financeApplication[0].Id;
            
            resObj.applicationStatus  = CustomerPortalFinanceRestHelper.statusHelper(financeApplication[0]);
            
             // updating the finance application
                   
            update financeApplication[0];
            
            // sending the response
            
            system.debug('Return Response for Get --> '+json.serialize(resObj));
            return resObj;
        }
        
        
        /*
    Wrapper class for response.
    */
        
        global class responseWrapper {
            
            global String status {get;set;} 
            global String applicationID {get;set;} 
            global String applicationStatus{get;set;}
            global string quoteId;
            global string financeAmount;
            global string lenderName;
            global string signingLink; 
            global list<String> errorMessage{get;set;}
            global list<string> declinedBy;
            
            global responseWrapper() {
                
                this.errorMessage= new list<String>();
                //this.lenderName  = 'Barcalays';
                //this.signingLink = 'www.google.com';
            }
            
            global list<errorClass> errorClassList;
        }
        
        global class errorClass{
            global string errorCode;
            global string errorMessage;
            
        }
        
        public static  string statusHelper(Finance_Application__c financeApplication)
        {
            string allAcceptedValues = IV_Vectors__c.getInstance('Finance_Accepted_Statuses').Key__c;
            string allRefferredValues = IV_Vectors__c.getInstance('Finance_Reffered_Statuses').Key__c;
            string allDeclinedValues = IV_Vectors__c.getInstance('Finance_Declined_Statuses').Key__c;
            string allParkedValues = IV_Vectors__c.getInstance('Finance_Parked_Status').Key__c;
            string returnString;
            // checking the application status and assigning the status value to reponse
            if(allParkedValues.contains(financeApplication.Application_Status__c))
            returnString = 'Parked';
            if(allAcceptedValues.contains(financeApplication.Application_Status__c))
               returnString = 'Accepted'; 
            else if(allDeclinedValues.contains(financeApplication.Application_Status__c))
                returnString = 'Declined';
            else if(allRefferredValues.contains(financeApplication.Application_Status__c))
                returnString = 'Referred';
                
                return returnString;
        }
        
        public static string removeSpeicalCharacters (string myString)
        {
            if(myString!=null)
            myString = myString.replaceAll('[^a-zA-Z0-9]', ' ');
            
            return myString;
         
        }
        
        public static responseWrapper extractBarcalysError (Finance_Application__c fApplication, responseWrapper resObj)
        {
            Portal_Errors__c genericError = Portal_Errors__c.getInstance('Generic Error');
            list<Portal_Errors__c> possibleErrors = Portal_Errors__c.getAll().values();
            if(fApplication.Error_Details__c!= null)
            {
                  for(errorListClass.ErrorClass err : errorListClass.parse(fApplication.Error_Details__c).Errors)
                  {
                      resObj.errorMessage.add(err.ErrorMessage);
                      CustomerPortalFinanceRestHelper.errorClass erroObj = new CustomerPortalFinanceRestHelper.errorClass();
                      erroObj.errorCode = genericError.Portal_Error_Code__c;
                      erroObj.errorMessage = genericError.Description__c;
                      
                    for(Portal_Errors__c p: possibleErrors)
                    {
                    
                        system.debug(p);
                        if( err!=null && err.ErrorCode != null && p.Barclays_Error_Code__c.contains(','+string.valueof(err.ErrorCode)+','))/*err.ErrorCode == 100 && p.Description__c.contains('/:'+p.Name)) || */
                        {
                            erroObj = new CustomerPortalFinanceRestHelper.errorClass();
                            
                            erroObj.errorCode = p.Portal_Error_Code__c;
                            erroObj.errorMessage = p.Description__c;
                            resObj.errorClassList.add(erroObj);
                            //break;
                        }
                    
                    
                    }
                      
                      resObj.status = 'Error';
                  }
                 
            }
            
            return resObj;
        }
        
        
    }