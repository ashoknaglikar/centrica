public class CustomerPortalHelper {
    public static string  getOpportunityId(String Sf_id ){

        Schema.DescribeSObjectResult r = Opportunity.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        if(Sf_id!=null)
        {
          if( Sf_id.length()>18)
          { 
              System.debug('SF_ID-->'+Sf_id);
              IV_Vectors__c  keyRecord = IV_Vectors__c.getinstance('Customer Portal');
              Blob key = Blob.valueOf(keyRecord.Key__c) ;//Blob.valueOf('380db410e8b11fa9');
              blob encrypted2 = EncodingUtil.convertFromHex(Sf_id);
              Blob decrypted = Crypto.decryptWithManagedIV('AES128', key, encrypted2);
              String OppId = decrypted.toString(); 
              system.debug('opp id ='+oppid);
              return oppid;
          }
          else  if(Sf_id.startswith(keyPrefix)){
              return Sf_id ;
          }
        }else
        {
            return null;
        }
        
        return '';
        
    }

    
  /*  Public Static string encryptionOfData(String dataToBeEncrypted ){
      
        IV_Vectors__c  keyRecord = IV_Vectors__c.getinstance('Customer Portal Finance Key');
        IV_Vectors__c  vectorRecord = IV_Vectors__c.getinstance('Customer Portal Finance Vector');

        Blob keyBlob = EncodingUtil.base64Decode(keyRecord.Key__c); 
        blob vectorBlob = EncodingUtil.base64Decode(vectorRecord.Key__c);

        blob dataToBeEncryptedAsBlob = EncodingUtil.base64Decode(dataToBeEncrypted);    
       
        blob  encryptedDataBolb = Crypto.encrypt('AES256', keyBlob, vectorBlob, dataToBeEncryptedAsBlob);
        
        string encryptedData = dataToBeEncryptedAsBlob.tostring();
        system.debug('<<encryptedData>>'+encryptedData);
    
        return encryptedData;
        
    }*/
    
    Public Static String decryptionOfData(string dataToBeDecryptedAsString){
        IV_Vectors__c  keyRecord = IV_Vectors__c.getinstance('Customer Portal Finance Key');
        IV_Vectors__c  vectorRecord = IV_Vectors__c.getinstance('Customer Portal Finance Vector');

        Blob keyBlob = EncodingUtil.base64Decode(keyRecord.Key__c); 
        blob vectorBlob = EncodingUtil.base64Decode(vectorRecord.Key__c);

        blob dataToBeDecryptedAsBlob = EncodingUtil.base64Decode(dataToBeDecryptedAsString);    
       
        Blob decrypted = Crypto.decrypt('AES256', keyBlob,vectorBlob, dataToBeDecryptedAsBlob);

        String decryptedData = decrypted.toString();
        system.debug('<<decryptedData>>'+decryptedData);
    
        return decryptedData;
        
    }
     public static String getExternalReference(String oppId){
        
         List<Opportunity> oppObj = [SELECT Id, Install_Postcode__c,ExternalRef__c,Install_Address_Street__c, Install_Address_City__c, Install_Address_County__c, Bill_City__c, Bill_Country__c, Bill_FirstName__c, Bill_LastName__c, 
                                     Bill_Post_Code__c, Bill_State__c, Bill_Street__c, Bill_Title__c, Accountid, Account.Primary_Contact__c,Account.Primary_Contact__r.Salutation,  Account.Primary_Contact__r.FirstName, Account.Primary_Contact__r.LastName,
                                     CHI_Lead_Id__c FROM Opportunity where Id = : oppId];
         String ExtRef='' ;
         if(oppObj.size()>0)
         {
             if(oppObj[0].ExternalRef__c!=null){
                 string[] Ext = oppObj[0].ExternalRef__c.split('-');
                 ExtRef = Ext[0]+'-'+string.valueof(Integer.valueof(Ext[1])+1);
             }
             else
             {
                 ExtRef = oppObj[0].CHI_Lead_Id__c+'-'+'1';
             }
             oppObj[0].ExternalRef__c = ExtRef;
             update oppObj[0];
             
         }
         return ExtRef;
    }
    public list<Finance_Application__c> returnFinanceApplications(id oppId)
    {
        return new list<Finance_Application__c>  ( [SELECT f.payment_Options__c, f.YearE__c, f.YearB__c, f.Year3__c, f.Year2__c, f.Year1__c, f.X2nd_Lender_Name__c, 
                                       f.X2nd_Lended_Soft_Search__c, f.Work_Phone__c, f.Type_of_Finance__c, f.Type_Employee__c, f.Trigger_Document_Email__c, f.Title__c, 
                                       f.Time_at_Employer__c, f.Time_at_Address3__c, f.Time_at_Address2__c, f.Time_at_Address1__c, f.Time_At_Bank__c, f.SystemModstamp, 
                                       f.Street_E__c, f.Street3__c, f.Street2__c, f.Street1__c, f.Status__c, f.State_E__c, f.State3__c, f.State2__c, f.State1__c, f.Sort_Code__c, 
                                       f.Signature_Proof_of_Id__c, f.Sign_Proof_Details__c, f.Selling_Type__c, f.Security_Question__c, f.Security_Answer__c, f.Repayment_Method__c, 
                                       f.Referral_Reason__c, f.Reference_Number__c, f.Post_Code_E__c, f.Post_Code3__c, f.Post_Code2__c, f.Post_Code1__c, f.Partner_Income__c, 
                                       f.Partner_Employment_Status__c, f.Occupancy_Status3__c, f.Occupancy_Status2__c, f.Occupancy_Status1__c, f.Number_Of_Dependents__c, 
                                       f.Number_Of_Credit_Cards__c, f.Nationality__c, f.Name, f.Monthly_Repayments__c, f.MonthE__c, f.MonthB__c, f.Month3__c, f.Month2__c, f.Month1__c, 
                                       f.Mobile__c, f.Middle_Name__c, f.Marital_Status__c, f.Lender_Code__c, f.Lead_Ext_Ref_No__c, f.Last_Name__c, f.LastModifiedDate, f.LastModifiedById, 
                                       f.LastActivityDate, f.Job_Total__c, f.Job_Description__c, f.IsDeleted, f.Input_Spurce__c, f.Id, f.Home_Phone__c, f.HSA__c, f.HSA_Email__c, 
                                       f.Gross_Income__c, f.Gross_Annual_additional_benefit__c, f.Gross_Annual_State_Pension__c, f.Gross_Annual_Private_Pension__c, 
                                       f.Gross_Annual_Other_Pension__c, f.Gross_Annual_Income__c, f.Gross_Annual_Disability_Allowance__c, f.Gender__c, f.First_Name__c, f.Finance_Product__c, 
                                       f.Finance_Lender__c, f.Employment_Status__c, f.Employment_Category__c, f.Employer_Phone__c, f.Employer_Name__c, f.Employee_From__c, f.Email__c, 
                                       f.Document_Link__c, f.Document_Link_Fr__c, f.Deposit__c, f.Delete_Date_Time__c, f.Delete_Data__c, f.Date_Opened__c, f.Date_Of_Birth__c, 
                                       f.Date_From3__c, f.Date_From2__c, f.Date_From1__c, f.CreatedDate, f.CreatedById, f.Country_E__c, f.Country3__c, f.Country2__c, f.Country1__c, 
                                       f.Confirm_Email__c, f.City_E__c, f.City3__c, f.City2__c, f.City1__c, f.Cash_Price__c, f.CPhone_Number__c, f.CHI_Lead__c, f.Building_Number3__c, 
                                       f.Building_Number2__c, f.Building_Number1__c, f.Building_Name_E__c, f.Building_Name3__c, f.Building_Name2__c, f.Building_Name1__c, 
                                       f.Barcalys_Link_Application_Expiry__c, f.Bank_Account_Number__c, f.Bank_Account_Name__c, f.Application_Status__c, f.Application_ID__c, 
                                       f.Applicant_Other_Income__c, f.Applicant_Net_Monthly_income__c, f.Alias__c, f.Alias_Title__c, f.Alias_Middle_Name__c, f.Alias_Last_Name__c, 
                                       f.Alias_First_Name__c, f.Agreement_Number__c, f.Adress_Proof_ID__c, f.Address_Proof_Details__c, f.Add3_Date__c, f.Add2_Date__c, f.Add1_Date__c,
                                       HSA__r.Barclays_Outlet__c,Finance_Product__r.Name,CHI_Lead__r.ExternalRef__c, CHI_Lead__r.CHI_Lead_Id__c, CHI_Lead__r.Product_Interest__c, 
                                       Finance_Product__r.Not_Available_For__c, Finance_Product__r.Parent_Product__r.Name , Interest_Rate__c, Total_Amount_Repayable__c,F.Finance_Product__r.eFinance_outlet_Code__c 
                                       FROM Finance_Application__c f
                                       where CHI_Lead__c = :oppId ]);

       
    }

    public static Finance_Application__c getFinanceApplicationByStatus(list<Finance_Application__c> faList , string status )
    {
        string allAcceptedValues = IV_Vectors__c.getInstance('Finance_Accepted_Statuses').Key__c;
        string allRefferredValues = IV_Vectors__c.getInstance('Finance_Reffered_Statuses').Key__c;
        string allDeclinedValues = IV_Vectors__c.getInstance('Finance_Declined_Statuses').Key__c;
        string allParkedValues = IV_Vectors__c.getInstance('Finance_Parked_Status').Key__c;
        string allOtherValues = IV_Vectors__c.getInstance('Finance_Other_Statuses').Key__c;
        Finance_Application__c localApp; 

        Finance_Application__c  accepted = new Finance_Application__c();
        Finance_Application__c  decilned = new Finance_Application__c();
        Finance_Application__c  other = new Finance_Application__c();
        for(Finance_Application__c f: faList)
        {
            localApp =  new Finance_Application__c();
            
            if(f.Application_Status__c!=null && !allOtherValues.contains(','+f.Application_Status__c+','))
            {
                localApp =f;
                if(status == 'Parked' && allParkedValues.contains(','+f.Application_Status__c+','))
                {
                    return localApp;
                }else if(status == 'Accepted' && allAcceptedValues.contains(','+f.Application_Status__c+','))
                {
                    return localApp;
                }else if(status == 'Referred' && allRefferredValues.contains(','+f.Application_Status__c+','))
                {
                    // run the update status 
                    return localApp;
                }else if(status == 'Declined' && allDeclinedValues.contains(','+f.Application_Status__c+','))
                {
                    return localApp;
                }
            }
            
        }

        return null;

    }
    


    public static Finance_Application__c applicationStatusUpdate(Finance_Application__c fa)
    {
        barclaysIntegrationHelper  barcalysHelper = new barclaysIntegrationHelper();
        List<Finance_Application__c> financeApplication = barcalysHelper.getFinanceApplication(new list<string>{fa.Id});
        if(fa.Valid_New_Application__c)
        {
            financeApplication[0] = barclaysPhase3Helper.updateFinanceStatus(financeApplication[0]);
            
        }else
        {
        
        
            if(financeApplication.size()>0)
            {
                system.debug('financeApplication[0]='+financeApplication[0]);
                //getting tje latest status of the finance application from Barclays
                wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element barcalysResponse = FinanceApplicationDetail.enquiryHelper(financeApplication[0]);
                
                system.debug('barcalysResponse='+barcalysResponse);
                //errors while fetching the latest status of finance application
                if(label.TestSite == '1' &&  barcalysResponse!=null && barcalysResponse.Errors!= null && barcalysResponse.Errors.ErrorsWO.size()>0)
                {
                    // don nothing
                }
                else
                {
                    // aasigning the latest status of application  to existing finance application.
                    financeApplication[0].Application_Status__c = barcalysResponse.Application.ApplicationStatus;
                    financeApplication[0].status__c = barcalysResponse.Status;
                    financeApplication[0].Agreement_Number__c = barcalysResponse.Application.AgreementNumber;
                   
                }
            }
                
           // updating the finance application
            
        }
        update financeApplication[0];
        return financeApplication[0];
    }
    
    public static String getdeliverySlot(string installTime)
    {
          String deliverySlot;
          String[] s= installTime.split(':');
          integer hour =Integer.valueOf(s[0].trim()); 
          integer minute= Integer.valueOf(s[1].trim());
          integer second= 0;
          integer millisecond = 0;
          time d = time.newInstance(hour, minute, second, millisecond);
          time endtime = time.newInstance(12, 0, 0, 0);
          if(d>=endtime) 
           deliverySlot =  System.Label.CPP_DeliverySlot_PM;
          else
           deliverySlot =  System.Label.CPP_DeliverySlot;
           
           system.debug(deliverySlot);
          return deliverySlot;
    }
    
    public class financeProduct
    {
        public decimal rate;
        public string productCode;
        public decimal numberOfMonths;
        public decimal repaymentDue;
        public Finance_Product__c fProd;
        public decimal orderNum;
        public string financeOption;
        public financeProduct(Finance_Product__c fProd)
        {
            this.fProd= fProd;
            this.rate = fProd.Interest_Rate__c;
            this.productCode = fProd.Code__c;
            this.repaymentDue= fProd.Deferral_Period__c;
            this.numberOfMonths = fProd.Tenure_in_Months__c;
            this.orderNum = fProd.Order__c;
            this.financeOption = fProd.Finance_Options__c;
        }
        
    }
    
    public static list <Finance_Product__c> getEligibleFinanceProducts (date quoteCreatedDate, date leadCreatedDate  )
    {
        return new list<Finance_Product__c> ([Select id,Interest_Rate__c, Deferral_Period__c,Tenure_in_Months__c,Code__c,Order__c,Finance_options__c from Finance_Product__c where Start_Date__c <= :quoteCreatedDate and Final_Date__c >= : quoteCreatedDate and End_Date__c >= : leadCreatedDate and Selectable__c = true order by Tenure_in_Months__c]);
    }

    
}