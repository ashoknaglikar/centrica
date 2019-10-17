/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class aINS_aUPD_updateOpptyUpdate_test {

    static testMethod void myUnitTest() {
       
       Opportunity opp =                 ([Select o.ta_notes__c, o.quoteIncrementer__c, o.discountsTotalOnPricing__c, o.Wrap_Up_Call_Type__c, o.With_Customer__c, 
                                         o.Visit_Type__c, o.Validation_Question_2__c, o.Validation_Question_1__c, o.Validated_Date__c, o.Urgency__c, o.Upgrade_Type__c,
                                         o.Unsafe_Appliance_Reason__c, o.Unbilled_Reason__c, o.UCRN__c, o.Type, o.Test_Workflow__c, o.SystemModstamp, o.Surveyor_Ppwrk_Recd_By__c,
                                         o.Surveyor_Ppwk_Recd_Date__c, o.Sum_of_Payments__c, o.Status__c, o.Stage_Reason__c, o.Stage_Modified_Date__c, o.StageName, o.Siebel_Created_Date__c, 
                                         o.Service_Required__c, o.Sent_To_Premier__c, o.Sent_Confirmation_Text_To_Referral_Eng__c, o.Scottish_Exec__c, o.Scottish_Exec_Export_Date__c, o.Sales_Ppwrk_Rcd_Dt_del__c, 
                                         o.Sales_Ppwrk_Rcd_By__c, o.Sales_Paperwork_Count__c, o.Sales_Document_Status__c, o.Sales_Appointment_Date_an_Time__c, o.SC_Work_Phone__c, 
                                         o.SC_Type__c, o.SC_Mobile_Phone__c, o.SC_Last_Name__c, o.SC_Home_Phone__c, o.SC_First_Name__c, o.SC_Address_Post_Code__c, o.SC_Address2__c, 
                                         o.SC_Address1__c, o.Replacement_Type__c, o.Referral_Engineer_First_Name__c, o.Referral_Employee__c, o.Referral_Employee_Source__c, o.Referral_Employee_Num__c, 
                                         o.Referral_Employee_Name__c, o.Referral_Employee_Location__c, o.ReferralEmployeeTextEmailAddress__c, o.Reference_Number__c, o.RecordTypeId, 
                                         o.Quote_Payment_Method__c, o.Property_Owner__c, o.Property_Occupied__c, o.Property_Characteristics__c, o.Product_Interest__c, o.Probability, o.Primary_Contact_Email__c, 
                                         o.Pricebook2Id, o.Premier_Group_Code__c, o.Premier_Employee_Num__c, o.Preferred_appointment_time__c, o.Preferred_appointment_day__c, o.Preferred_appointment_date__c, 
                                         o.Preferred_Visit_Date_Time__c, o.Preferred_Date__c, o.Preferred_Call_Time__c, o.Payment_Settlement_Status__c, o.Payment_Reference_Number__c, o.Payment_Method__c, 
                                         o.Page_Moy_Extract_Date__c, o.PREM_SOURCE_FORMULA__c, o.PMM_Engineer_Export_Date__c, o.PCN_Status__c, o.OwnerId, o.Override_Billing_checks__c, o.Original_Quote_Value__c, o.Opportunity_Age__c, 
                                         o.Old_SFID__c, o.Number_of_Survey_Appointments__c, o.Number_of_Successful_Deposit_Payments__c, o.Number_of_Sales_Appointments__c, o.Number_of_Installations__c, o.Number_of_Cancelled_Sales_Appointments__c, 
                                         o.Number_of_Appointed_Survey_Appointments__c, o.Number_of_Appointed_Sales_Appointments__c, o.Number_of_Accepted_Quotes__c, o.Number_Of_Radiators__c, o.Num_of_Quotes__c, o.Non_Op__c, o.NextStep, 
                                         o.Name, o.NIFCO_Export_Date__c, o.Move_boiler_position__c, o.Mobile_Phone__c, o.Media_Code__c, o.Marketing_Consent__c, o.Legacy_Modified_Date__c, o.Lead_Comments__c, o.LeadSource, o.LastModifiedDate, 
                                         o.LastModifiedById, o.LastActivityDate, o.IsWon, o.IsDeleted, o.IsClosed, o.Interface_Failure_Reason__c, o.Interface_Failure_Date__c, o.Install_Postcode__c, o.Install_Address_Street__c, o.Install_Address_County__c, 
                                         o.Install_Address_City__c, o.In_Premier__c, o.Id, o.House_Number__c, o.House_Name__c, o.Homecare__c, o.Home_improvement__c, o.Home_Phone__c, o.HomeImprovementCheckbox__c, o.HasOpportunityLineItem, o.Gas_Central_Heating_Supplier__c, 
                                         o.Gas_Central_Heating_Exists__c, o.Fulfilment_Type__c, o.Fulfilment_Flag__c, o.Fulfilment_Date__c, o.Fulfilment_Batch__c, o.ForecastCategoryName, o.ForecastCategory, o.Flat_Number__c, o.FiscalYear, o.FiscalQuarter, o.Fiscal, 
                                         o.First_Appointment_Date__c, o.Firefly_Script_Complete__c, o.Firefly_Id__c, o.Finance_Amount__c, o.Finance_Acceptance_Number__c, o.Fan_warmed_air__c, o.Estimated_Opportunity_Clearance_Date__c, o.Enquiry_Type__c, o.Enquiry_Received_By__c, 
                                         o.Enquiry_Reason__c, o.Enquiry_Num__c, o.Engineer_Comments__c, o.Employee_Referral_Points__c, o.Do_Not_Use__c, o.Discounted_Amount__c, o.Description, o.Deposit_Amount__c, o.Days_Since_Created__c, o.Customer_agreed_to_appointment__c, 
                                         o.Customer_Reason__c, o.Customer_Name__c, o.Customer_Give_Preferred_Date__c, o.Current_Boiler__c, o.Current_Boiler_Model__c, o.Current_Boiler_Manufacturer__c, o.Current_Boiler_Characteristics__c, o.CreatedDate, o.CreatedById, 
                                         o.Country_Differentiator__c, o.Contact_Number__c, o.Compensation_Amount__c, o.Comments__c, o.CloseDate, o.Change_boiler_type__c, o.Capped_Off__c, o.Cancel_Todays_Appt_No_Other_Future_Appt__c, o.CampaignId, o.COST_FORMULA__c, 
                                         o.CHI_Lead_Id__c, o.CHI_Lead_Id2__c, o.CHI_Lead_Id1__c, o.CHIRP__c, o.Boiler_Working__c, o.Boiler_Age__c, o.Billing_withheld_on__c, 
                                         o.Billed__c, o.Billed_Status__c, o.Best_Day_for_Callback__c, o.Balance_Payment_Method__c, o.Balance_Outstanding__c, o.Asbestos_Found__c, o.Amount_Settled__c, o.Amount, o.Alternative_Number__c, o.Address_Line2__c, o.Address_Line1__c, o.Account_Postcode_Sector__c, o.AccountId, o.Accept_Quote_Amt__c, 
                                         o.ASP_Removal__c, o.ASP_Discount__c, o.ASP_Addition__c From Opportunity o where Owner.Name = 'Automated Tasks' limit 1]);
       Compensation__c comp = new Compensation__c(); 
       comp.Related_CHI_Lead__c=opp.Id;
       comp.Value_Compensated__c=200;
       //comp.Name='TestName';
       insert comp;
       
       opp.Compensation_Amount__c=null;
       update opp;
       opp.Compensation_Amount__c=200;
       update opp;
       
       
       
    }
}