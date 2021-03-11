public with sharing class Phase3TestHelper {
    
    @istest
    public static Postcode_Sector__c createTestGeography() {
        Region__c testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
        testRegion.Geography_Code__c='34';
        Database.insert(testRegion);
        
        District__c testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
        Database.insert(testDistrict);
        
        Sub_Patch__c testSubPatch = new Sub_Patch__c(Name='Test SubPatch', Code__c = 'SP99', 
                                                    Type__c='Installation', District__c = testDistrict.ID);
        Database.insert(testSubPatch);
        
        Postcode_Sector__c testPostcodeSector = new Postcode_Sector__c(Name = 'XX99 9', Description__c = 'Test Postcode Sector', 
                                                                        Water_Hardness__c = 99, Type__c = 'Installation', 
                                                                        Sub_Patch__c = testSubPatch.ID);
        Database.insert(testPostcodeSector);
        
        testPostcodeSector = [select p.Water_Hardness__c, p.Type__c, p.SystemModstamp, p.Sub_Patch__c, p.Name, p.LastModifiedDate, 
                                p.LastModifiedById, p.IsDeleted, p.Id, p.Description__c, p.CreatedDate, p.CreatedById, p.Code__c
                                From Postcode_Sector__c p where p.Id = :testPostcodeSector.Id];
        
        return testPostcodeSector;
    }

    @istest
    public static District__c createTestGeographyDistrict() {
        try {
            District__c testDistrict = [Select d.Type__c, d.SystemModstamp, d.Region__c, d.OwnerId, d.Name, d.LastModifiedDate, d.LastModifiedById, 
                        d.IsDeleted, d.Id, d.Geography_Uplift_Percentage__c, d.CreatedDate, d.CreatedById, d.Code__c 
                        From District__c d where Name='Test District' AND Code__c = 'TD99' AND Type__c='Installation'];
            return testDistrict;
        } catch(Exception ex){
            // Ignore
        }
        Region__c testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
        testRegion.Geography_Code__c='34';
        Database.insert(testRegion);
        
        District__c testDistrict = new District__c(Name='Test District', Code__c = 'TD99', Type__c='Installation', Region__c = testRegion.ID);
        Database.insert(testDistrict);
        
        Sub_Patch__c testSubPatch = new Sub_Patch__c(Name='Test SubPatch', Code__c = 'SP99', 
                                                    Type__c='Installation', District__c = testDistrict.ID);
        Database.insert(testSubPatch);
        
        Postcode_Sector__c testPostcodeSector = new Postcode_Sector__c(Name = 'XX99 9', Description__c = 'Test Postcode Sector', 
                                                                        Water_Hardness__c = 99, Type__c = 'Installation', 
                                                                        Sub_Patch__c = testSubPatch.ID);
        Database.insert(testPostcodeSector);
        
        testDistrict = [Select d.Type__c, d.SystemModstamp, d.Region__c, d.OwnerId, d.Name, d.LastModifiedDate, d.LastModifiedById, 
                        d.IsDeleted, d.Id, d.Geography_Uplift_Percentage__c, d.CreatedDate, d.CreatedById, d.Code__c 
                        From District__c d where d.Id = :testDistrict.Id];
        
        return testDistrict;
    }

    @isTest
    public static Search_Parameter__c createSearchParameters() {
        Search_Parameter__c sp = null;
        try {
            sp = [Select ID from Search_Parameter__c where Type__c = 'DEFAULT'];
        } catch(Exception ex) {
            sp = new Search_Parameter__c(Type__c='DEFAULT', Scheduling_Window__c = 5, Gap_Size_Tolerance__c = 0, 
                                         Acceptable_Remaining_Gap__c = 7, Double_Handed_Threshold__c = 16, 
                                         End_Date_Time_Offset__c = 10);
            Database.insert(sp);
            sp = [Select ID from Search_Parameter__c where Type__c = 'DEFAULT'];
        }
        
        return sp;
    }
    
    @isTest
    public static Supplier__c createSupplier() {
        Supplier__c supp = new Supplier__c(Name='TestSBB Supplier', Supplier_Num__c = '875411', Type__c = 'Resource', 
                                            Resource_Type__c='Own Labour');
        Database.insert(supp);
        supp = [Select s.Type__c, s.SystemModstamp, s.Supplier_Num__c, s.Street__c, s.State__c, s.Start_Date__c, 
                s.Resource_Type__c, s.Postcode__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, 
                s.IsDeleted, s.Id, s.GasSafe_Business_ID__c, s.End_Date__c, s.Description__c, s.CreatedDate, s.CreatedById, 
                s.Country__c, s.City__c
                From Supplier__c s where s.Id = :supp.ID];
        return supp;
    }
    
    @isTest
    public static Supplier__c createContractorSupplier() {
        Supplier__c supp = new Supplier__c(Name='TestSBB Contractor Supplier', Supplier_Num__c = '875412', Type__c = 'Resource', 
                                            Resource_Type__c='Contractor');
        Database.insert(supp);
        supp = [Select s.Type__c, s.SystemModstamp, s.Supplier_Num__c, s.Street__c, s.State__c, s.Start_Date__c, 
                s.Resource_Type__c, s.Postcode__c, s.OwnerId, s.Name, s.LastModifiedDate, s.LastModifiedById, 
                s.IsDeleted, s.Id, s.GasSafe_Business_ID__c, s.End_Date__c, s.Description__c, s.CreatedDate, s.CreatedById, 
                s.Country__c, s.City__c
                From Supplier__c s where s.Id = :supp.ID];
        return supp;
    }
    
    @isTest
    public static Employee__c createEmployee() {
        District__c district = createTestGeographyDistrict();
        Supplier__c supp = createSupplier();
        Employee__c emp = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = district.Id, Net_Promoter_Score__c = 10);
        Database.insert(emp);
        emp = [Select e.Works_Anywhere_in_District__c, e.Works_Anywhere_in_Area__c, e.Supplier__c, e.Resource_Type__c, e.Resource_Id__c, 
                e.Region__c, e.Pool_Diary__c, e.Phone_Number_3G__c, e.Own_Labour__c, e.Never_Works_With__c, e.Net_Promoter_Score__c, e.Name, 
                e.Manager__c, e.Last_Name__c, e.Inactive__c, e.Id, e.Group__c,e.First_Name__c, e.End_Date__c, e.Employee_Record_ID__c, 
                e.Employee_Number__c, e.Emp_type__c, e.Email__c, e.District__c, e.District_ID__c, e.Contractor_Band__c, 
                e.Always_Works_With__c, e.Always_Works_Alone__c, e.District__r.Region__c , e.Supplier__r.Name, e.salesforce_user__c,e.District__r.Name,Postcode__c,latitude__latitude__s,latitude__longitude__s,
                (select Employee__c, Employee__r.Always_Works_With__c,Employee__r.Always_Works_with_Electrician__c, Type__c from Employee_Postcodes__r ) , Skip_Rule__c, e.Always_Works_with_Electrician__c 
                From Employee__c e where e.Id = :emp.ID];
        return emp;
    }

    @isTest
    public static Employee__c createPoolEmployee() {
        District__c district = createTestGeographyDistrict();
        Supplier__c supp = createSupplier();
        Employee__c emp = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = true,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = district.Id, Net_Promoter_Score__c = 10, Postcode__c='ab1 cd1');
        Database.insert(emp);
        emp = [Select e.Works_Anywhere_in_District__c, e.Works_Anywhere_in_Area__c, e.Supplier__c, e.Resource_Type__c, e.Resource_Id__c, 
                e.Region__c, e.Pool_Diary__c, e.Phone_Number_3G__c, e.Own_Labour__c, e.Never_Works_With__c, e.Net_Promoter_Score__c, e.Name, 
                e.Manager__c, e.Last_Name__c, e.Inactive__c, e.Id, e.Group__c,e.First_Name__c, e.End_Date__c, e.Employee_Record_ID__c, 
                e.Employee_Number__c, e.Emp_type__c, e.Email__c, e.District__c, e.District_ID__c, e.Contractor_Band__c, 
                e.Always_Works_With__c, e.Always_Works_Alone__c, e.District__r.Region__c , e.Supplier__r.Name, e.District__r.Name,e.Always_Works_With_Electrician__c,latitude__latitude__s,latitude__longitude__s,
                (select Employee__c, Employee__r.Always_Works_With__c,employee__r.Always_Works_With_Electrician__c, Type__c from Employee_Postcodes__r ), Postcode__c, Skip_Rule__c
                From Employee__c e where e.Id = :emp.ID];
        return emp;
    }

    @isTest
    public static Employee__c createContractorEmployee() {
        District__c district = createTestGeographyDistrict();
        Supplier__c supp = createContractorSupplier();
        Employee__c emp = new Employee__c(Name = 'testSBB2', First_Name__c = 'SBB2', Last_Name__c = 'Test2', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002992', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,
                                            District__c = district.Id, Net_Promoter_Score__c = 10, Contractor_Band__c='Band 1', Postcode__c = 'ab1 cd1');
        Database.insert(emp);
        emp = [Select e.Works_Anywhere_in_District__c, e.Works_Anywhere_in_Area__c, e.Supplier__c, e.Resource_Type__c, e.Resource_Id__c, 
                e.Region__c, e.Pool_Diary__c, e.Phone_Number_3G__c, e.Own_Labour__c, e.Never_Works_With__c, e.Net_Promoter_Score__c, e.Name, 
                e.Manager__c, e.Last_Name__c, e.Inactive__c, e.Id, e.Group__c,e.First_Name__c, e.End_Date__c, e.Employee_Record_ID__c, 
                e.Employee_Number__c, e.Emp_type__c, e.Email__c, e.District__c, e.District_ID__c, e.Contractor_Band__c, 
                e.Always_Works_With__c, e.Always_Works_Alone__c, e.District__r.Region__c , e.Supplier__r.Name, e.District__r.Name,Postcode__c,e.Always_Works_With_Electrician__c,latitude__latitude__s,latitude__longitude__s,
                (select Employee__c, Employee__r.Always_Works_With__c, employee__r.Always_Works_With_Electrician__c,Type__c from Employee_Postcodes__r ), Skip_Rule__c
                From Employee__c e where e.Id = :emp.ID];
        return emp;
    }
    
    @isTest
    public static Employee__c createEmployeeAnywhereDistrict() {
        District__c district = null;
        try {
            district = [select ID from District__c where Name='Test District' AND Code__c = 'TD99' AND Type__c='Installation'];
        } catch(Exception ex) {
            district = createTestGeographyDistrict();   
        }
        
        if(SearchBlackBox.jobInfo != null)
            SearchBlackBox.jobInfo.jobDistrict = district.Id;
            
        Supplier__c supp = createSupplier();
        Employee__c emp = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = true, Works_Anywhere_In_Area__c = false, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null,Always_Works_With_Electrician__c=null,
                                            District__c = district.Id, Net_Promoter_Score__c = 10);
        Database.insert(emp);
        return emp;
    }
    
    
    @isTest
    public static Employee__c createEmployeeAnywhereArea() {
        District__c district = null;
        try {
            district = [select ID from District__c where Name='Test District' AND Code__c = 'TD99' AND Type__c='Installation'];
        } catch(Exception ex) {
            district = createTestGeographyDistrict();   
        }
        Region__c region = null;
        try {
            region = [select ID from Region__c where Name='Test Region' AND Code__c = 'TR99' AND Type__c='Installation'];
        } catch(Exception ex) {
            // do nothing
        }
        
        if(SearchBlackBox.jobInfo != null)
            SearchBlackBox.jobInfo.jobArea = region.Id;
        
        Supplier__c supp = createSupplier();
        Employee__c emp = new Employee__c(Name = 'testSBB1', First_Name__c = 'SBB1', Last_Name__c = 'Test1', Supplier__c = supp.ID,
                                            Employee_Number__c = '0002991', Resource_Type__c= 'Installer', Inactive__c = false,
                                            Works_Anywhere_In_District__c = false, Works_Anywhere_In_Area__c = true, Pool_Diary__c = false,
                                            Always_Works_Alone__c = false, Always_Works_With__c = null, Never_Works_With__c = null, Always_Works_With_Electrician__c=null,
                                            District__c = district.Id, Net_Promoter_Score__c = 10);
        Database.insert(emp);
        return emp;
    }
    
    @isTest
    public static Account createAccount() {
        Account acc = new Account(Name = 'Test SBB', BillingStreet='18 Roundacre', 
                                        BillingPostalCode='TN9 1NB', BillingCity='London', //XX99 9TS
                                        BillingCountry='UK', BillingState='London');
        Database.insert(acc);
        acc = [Select a.Website, a.Water_Hardness__c, a.Update_Account__c, a.Type, a.SystemModstamp, a.Siebel_URN__c, 
                a.Siebel_Created_Date__c, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, 
                a.ShippingCity, a.Sales_Subpatch__c, a.Sales_Region__c, a.Sales_District__c, a.Primary_Contact__c, 
                a.Primary_Contact_Salutation__c, a.Primary_Contact_Pref_Contact_Method__c, a.Primary_Contact_Last_Name__c, 
                a.Primary_Contact_First_Name__c, a.Phone, a.ParentId, a.OwnerId, a.NumberOfEmployees, a.Notes__c, a.Name, 
                a.MasterRecordId, a.Last_Sales_Appointment_added__c, a.Last_Information_Only_added__c, a.LastModifiedDate, 
                a.LastModifiedById, a.LastActivityDate, a.IsDeleted, a.Info_Only_CHI_Lead_count__c, a.Industry, a.Id, a.Fax, 
                a.Extended_Account_Key_Calc__c, a.Description, a.CreatedDate, a.CreatedById, a.Country_Differentiator__c, 
                a.CHI_Lead_Count__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, 
                a.AnnualRevenue, a.Address_Circumstance__c, a.Account_Key_Calc__c, a.Account_Id__c 
                From Account a where a.Id = :acc.Id];
        return acc;
    }
    
    @isTest
    public static Account createAccount1() {
        Account acc = new Account(Name = 'Test SBB', BillingStreet='18 Roundacre', 
                                        BillingPostalCode='SL2 1LS', BillingCity='London', //XX99 9TS
                                        BillingCountry='UK', BillingState='London');
        Database.insert(acc);
        acc = [Select a.Website, a.Water_Hardness__c, a.Update_Account__c, a.Type, a.SystemModstamp, a.Siebel_URN__c, 
                a.Siebel_Created_Date__c, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, 
                a.ShippingCity, a.Sales_Subpatch__c, a.Sales_Region__c, a.Sales_District__c, a.Primary_Contact__c, 
                a.Primary_Contact_Salutation__c, a.Primary_Contact_Pref_Contact_Method__c, a.Primary_Contact_Last_Name__c, 
                a.Primary_Contact_First_Name__c, a.Phone, a.ParentId, a.OwnerId, a.NumberOfEmployees, a.Notes__c, a.Name, 
                a.MasterRecordId, a.Last_Sales_Appointment_added__c, a.Last_Information_Only_added__c, a.LastModifiedDate, 
                a.LastModifiedById, a.LastActivityDate, a.IsDeleted, a.Info_Only_CHI_Lead_count__c, a.Industry, a.Id, a.Fax, 
                a.Extended_Account_Key_Calc__c, a.Description, a.CreatedDate, a.CreatedById, a.Country_Differentiator__c, 
                a.CHI_Lead_Count__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, 
                a.AnnualRevenue, a.Address_Circumstance__c, a.Account_Key_Calc__c, a.Account_Id__c 
                From Account a where a.Id = :acc.Id];
        return acc;
    }
    
    @isTest
    public static Campaign createCampaign() {
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp);
        camp = [Select c.Type, c.SystemModstamp, c.Status, c.StartDate, c.Source__c, c.Siebel_Campaign_Id__c, c.ParentId, c.OwnerId, 
                c.NumberSent, c.NumberOfWonOpportunities, c.NumberOfResponses, c.NumberOfOpportunities, c.NumberOfLeads, 
                c.NumberOfConvertedLeads, c.NumberOfContacts, c.Name, c.Media_Cost_Code__c, c.Marketing_Campaign_Code__c, 
                c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.IsActive, c.Id, c.Group_Code__c, 
                c.ExpectedRevenue, c.ExpectedResponse, c.EndDate, c.Description, c.CreatedDate, c.CreatedById, c.BudgetedCost, 
                c.AmountWonOpportunities, c.AmountAllOpportunities, c.ActualCost 
                From Campaign c Where c.Id = :camp.Id];
        return camp;
    }
    
    @isTest
    public static Opportunity createOpportunity() {
        Account acc = createAccount();
        Campaign camp = createCampaign();
        Opportunity opp = new Opportunity (LeadSource = 'MA', name = 'TestSBB() opp', AccountId = acc.Id,
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Active',
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);
        
        Database.insert(opp);
        opp = [Select o.ta_notes__c, o.quoteIncrementer__c, o.Wrap_Up_Call_Type__c, o.With_Customer__c, o.Visit_Type__c, 
        o.Validation_Question_2__c, o.Validation_Question_1__c, o.Validated_Date__c, o.Urgency__c, o.Upgrade_Type__c, 
        o.Unsafe_Appliance_Reason__c, o.UCRN__c, o.Type, o.SystemModstamp, o.Surveyor_Ppwrk_Recd_By__c, o.Surveyor_Ppwk_Recd_Date__c, 
        o.Stage_Reason__c, o.Stage_Modified_Date__c, o.StageName, o.Siebel_Created_Date__c, o.Service_Required__c, o.Scottish_Exec__c, 
        o.Scottish_Exec_Export_Date__c, o.Sales_Ppwrk_Rcd_Dt_del__c, o.Sales_Ppwrk_Rcd_By__c, o.SC_Work_Phone__c, o.SC_Type__c, 
        o.SC_Mobile_Phone__c, o.SC_Last_Name__c, o.SC_Home_Phone__c, o.SC_First_Name__c, o.SC_Address_Post_Code__c, o.SC_Address2__c, 
        o.SC_Address1__c, o.Replacement_Type__c, o.Referral_Employee__c, o.Referral_Employee_Source__c, o.Referral_Employee_Num__c, 
        o.Referral_Employee_Name__c, o.Referral_Employee_Location__c, o.Reference_Number__c, o.RecordTypeId, o.Property_Owner__c, 
        o.Property_Occupied__c, o.Property_Characteristics__c, o.Product_Interest__c, o.Probability, o.Pricebook2Id, o.Premier_Group_Code__c, 
        o.Premier_Employee_Num__c, o.Preferred_appointment_time__c, o.Preferred_appointment_day__c, o.Preferred_appointment_date__c, 
        o.Preferred_Visit_Date_Time__c, o.Preferred_Date__c, o.Preferred_Call_Time__c, o.Page_Moy_Extract_Date__c, o.PREM_SOURCE_FORMULA__c, 
        o.PMM_Engineer_Export_Date__c, o.OwnerId, o.Number_of_Survey_Appointments__c, o.Number_of_Successful_Deposit_Payments__c, 
        o.Number_of_Sales_Appointments__c, o.Number_of_Installations__c, o.Number_of_Appointed_Survey_Appointments__c, 
        o.Number_of_Appointed_Sales_Appointments__c, o.Number_of_Accepted_Quotes__c, o.Number_Of_Radiators__c, o.Num_of_Quotes__c, 
        o.NextStep, o.Name, o.NIFCO_Export_Date__c, o.Move_boiler_position__c, o.Media_Code__c, o.Marketing_Consent__c, 
        o.Legacy_Modified_Date__c, o.Lead_Comments__c, o.LeadSource, o.LastModifiedDate, o.LastModifiedById, o.LastActivityDate, o.IsWon, 
        o.IsDeleted, o.IsClosed, o.Install_Postcode__c, o.Install_Address_Street__c, o.Install_Address_County__c, o.Install_Address_City__c, 
        o.Id, o.House_Number__c, o.House_Name__c, o.Homecare__c, o.Home_improvement__c, o.HasOpportunityLineItem, 
        o.Gas_Central_Heating_Supplier__c, o.Gas_Central_Heating_Exists__c, o.Fulfilment_Type__c, o.Fulfilment_Flag__c, 
        o.Fulfilment_Date__c, o.Fulfilment_Batch__c, o.ForecastCategoryName, o.ForecastCategory, o.Flat_Number__c, /*o.FiscalYear,*/ 
        o.FiscalQuarter, o.Fiscal, o.First_Appointment_Date__c, o.Firefly_Script_Complete__c, o.Firefly_Id__c, o.Fan_warmed_air__c, 
        o.Enquiry_Type__c, o.Enquiry_Received_By__c, o.Enquiry_Reason__c, o.Enquiry_Num__c, o.Engineer_Comments__c, 
        o.Employee_Referral_Points__c, o.Do_Not_Use__c, o.Description, o.Deposit_Amount__c, o.Customer_Reason__c, 
        o.Customer_Give_Preferred_Date__c, o.Current_Boiler__c, o.Current_Boiler_Model__c, o.Current_Boiler_Manufacturer__c, 
        o.Current_Boiler_Characteristics__c, o.CreatedDate, o.CreatedById, o.Country_Differentiator__c, o.Contact_Number__c, o.Comments__c, 
        o.CloseDate, o.Change_boiler_type__c, o.Capped_Off__c, o.Cancel_Todays_Appt_No_Other_Future_Appt__c, o.CampaignId, o.COST_FORMULA__c, 
        o.CHI_Lead_Id__c, o.CHI_Lead_Id2__c, o.CHI_Lead_Id1__c, o.CHIRP__c, o.Boiler_Working__c, o.Boiler_Age__c, o.Best_Day_for_Callback__c, 
        o.Asbestos_Found__c, o.Amount, o.Alternative_Number__c, o.Address_Line2__c, o.Address_Line1__c, o.Account_Postcode_Sector__c, 
        o.AccountId, o.Accept_Quote_Amt__c , o.Latest_customer_category__c From Opportunity o Where o.Id = :opp.Id];
        return opp;
    }
    
    @isTest
    public static Opportunity createOpportunity1() {
        Account acc = createAccount1();
        Campaign camp = createCampaign();
        Opportunity opp = new Opportunity (LeadSource = 'MA', name = 'TestSBB() opp', AccountId = acc.Id,
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Active',
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);
        
        Database.insert(opp);
        opp = [Select o.ta_notes__c, o.quoteIncrementer__c, o.Wrap_Up_Call_Type__c, o.With_Customer__c, o.Visit_Type__c, 
        o.Validation_Question_2__c, o.Validation_Question_1__c, o.Validated_Date__c, o.Urgency__c, o.Upgrade_Type__c, 
        o.Unsafe_Appliance_Reason__c, o.UCRN__c, o.Type, o.SystemModstamp, o.Surveyor_Ppwrk_Recd_By__c, o.Surveyor_Ppwk_Recd_Date__c, 
        o.Stage_Reason__c, o.Stage_Modified_Date__c, o.StageName, o.Siebel_Created_Date__c, o.Service_Required__c, o.Scottish_Exec__c, 
        o.Scottish_Exec_Export_Date__c, o.Sales_Ppwrk_Rcd_Dt_del__c, o.Sales_Ppwrk_Rcd_By__c, o.SC_Work_Phone__c, o.SC_Type__c, 
        o.SC_Mobile_Phone__c, o.SC_Last_Name__c, o.SC_Home_Phone__c, o.SC_First_Name__c, o.SC_Address_Post_Code__c, o.SC_Address2__c, 
        o.SC_Address1__c, o.Replacement_Type__c, o.Referral_Employee__c, o.Referral_Employee_Source__c, o.Referral_Employee_Num__c, 
        o.Referral_Employee_Name__c, o.Referral_Employee_Location__c, o.Reference_Number__c, o.RecordTypeId, o.Property_Owner__c, 
        o.Property_Occupied__c, o.Property_Characteristics__c, o.Product_Interest__c, o.Probability, o.Pricebook2Id, o.Premier_Group_Code__c, 
        o.Premier_Employee_Num__c, o.Preferred_appointment_time__c, o.Preferred_appointment_day__c, o.Preferred_appointment_date__c, 
        o.Preferred_Visit_Date_Time__c, o.Preferred_Date__c, o.Preferred_Call_Time__c, o.Page_Moy_Extract_Date__c, o.PREM_SOURCE_FORMULA__c, 
        o.PMM_Engineer_Export_Date__c, o.OwnerId, o.Number_of_Survey_Appointments__c, o.Number_of_Successful_Deposit_Payments__c, 
        o.Number_of_Sales_Appointments__c, o.Number_of_Installations__c, o.Number_of_Appointed_Survey_Appointments__c, 
        o.Number_of_Appointed_Sales_Appointments__c, o.Number_of_Accepted_Quotes__c, o.Number_Of_Radiators__c, o.Num_of_Quotes__c, 
        o.NextStep, o.Name, o.NIFCO_Export_Date__c, o.Move_boiler_position__c, o.Media_Code__c, o.Marketing_Consent__c, 
        o.Legacy_Modified_Date__c, o.Lead_Comments__c, o.LeadSource, o.LastModifiedDate, o.LastModifiedById, o.LastActivityDate, o.IsWon, 
        o.IsDeleted, o.IsClosed, o.Install_Postcode__c, o.Install_Address_Street__c, o.Install_Address_County__c, o.Install_Address_City__c, 
        o.Id, o.House_Number__c, o.House_Name__c, o.Homecare__c, o.Home_improvement__c, o.HasOpportunityLineItem, 
        o.Gas_Central_Heating_Supplier__c, o.Gas_Central_Heating_Exists__c, o.Fulfilment_Type__c, o.Fulfilment_Flag__c, 
        o.Fulfilment_Date__c, o.Fulfilment_Batch__c, o.ForecastCategoryName, o.ForecastCategory, o.Flat_Number__c, /*o.FiscalYear,*/ 
        o.FiscalQuarter, o.Fiscal, o.First_Appointment_Date__c, o.Firefly_Script_Complete__c, o.Firefly_Id__c, o.Fan_warmed_air__c, 
        o.Enquiry_Type__c, o.Enquiry_Received_By__c, o.Enquiry_Reason__c, o.Enquiry_Num__c, o.Engineer_Comments__c, 
        o.Employee_Referral_Points__c, o.Do_Not_Use__c, o.Description, o.Deposit_Amount__c, o.Customer_Reason__c, 
        o.Customer_Give_Preferred_Date__c, o.Current_Boiler__c, o.Current_Boiler_Model__c, o.Current_Boiler_Manufacturer__c, 
        o.Current_Boiler_Characteristics__c, o.CreatedDate, o.CreatedById, o.Country_Differentiator__c, o.Contact_Number__c, o.Comments__c, 
        o.CloseDate, o.Change_boiler_type__c, o.Capped_Off__c, o.Cancel_Todays_Appt_No_Other_Future_Appt__c, o.CampaignId, o.COST_FORMULA__c, 
        o.CHI_Lead_Id__c, o.CHI_Lead_Id2__c, o.CHI_Lead_Id1__c, o.CHIRP__c, o.Boiler_Working__c, o.Boiler_Age__c, o.Best_Day_for_Callback__c, 
        o.Asbestos_Found__c, o.Amount, o.Alternative_Number__c, o.Address_Line2__c, o.Address_Line1__c, o.Account_Postcode_Sector__c, 
        o.AccountId, o.Accept_Quote_Amt__c , o.Latest_customer_category__c From Opportunity o Where o.Id = :opp.Id];
        return opp;
    }
    
    @isTest
    public static Job__c createJob1() {
        Opportunity opp = createOpportunity();
        opp.Latest_customer_category__c = 1;
        update opp;
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Customer_Preferred_Date__c = null,
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = false);
        Database.insert(job);
        job = [Select j.Water_Heating_Fixing_Hours__c,  
                j.Unvented_Hot_Water_Hours__c, j.Type__c, j.Total_Job_Hours__c, j.SystemModstamp, j.Sub_Status__c, j.Status__c, 
                j.Specialist_Building_Hours__c, j.Solar_Hours__c, j.Scaffolding_Required__c, 
                j.Scaffolding_Job_Elements__c, j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, 
                j.Resourcing_Status__c, j.Quote__c, j.PowerFlush_Hours__c, j.Pending_Reason__c, 
                j.Payment_Collection_Hours__c, j.OwnerId, j.Own_Labour__c, j.Named_Employee__c, j.Name, 
                j.Merchant_Status__c, j.Mechanical_Hours__c, j.Linked_Job__c, j.LastModifiedDate, j.LastModifiedById, 
                j.LastActivityDate, j.LPG_Installation_Hours__c, j.IsDeleted, j.Installer_Notes__c, 
                j.Installation_Special_Instructions__c, j.Installation_Address__c, j.Id,  
                j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Work_ASP_Hours__c,  
                j.Electrical_Hours__c, j.Double_Handed_Job__c, j.District__c, j.Delivery_Slot__c, j.Delivery_Notes__c, j.Delivery_Date__c, 
                j.Customer_Preferred_Date__c, j.CreatedDate, j.CreatedById, j.Contractors__c,  
                j.Contractor_Installation_Hours_del__c, j.Contractor_Installation_Hours__c,  
                j.Connect_Solar_Panel_Hours__c, j.CRD_Code__c, j.CHI_Lead__c, j.Building_Work_Hours__c, 
                j.Bring_Forward_Job__c, j.Asbestos_Removal_Required__c, j.Asbestos_Removal_Hours__c, j.Asbestos_Removal_Fixed_Rate_Hours__c, 
                j.Asbestos_Job_Elements__c, j.CHI_Lead__r.Install_Postcode__c, j.Named_Employee__r.Always_Works_With__c,
                j.Override_Gap_Size_Tolerance__c, j.Too_Many_Script_Statements__c,District__r.Contractor__c,  District__r.Contractor_Band1__c, 
                District__r.Contractor_Band2__c, District__r.Contractor_Band3__c, District__r.Own_Labour__c,
                District__r.Consider_Contractors__c, District__r.Consider_Own_Labour__c, Finance_Expiry_Date__c, S_P_hours__c
                From Job__c j Where j.Id = :job.Id];
        return job;
    }
    
    @isTest
    public static Job__c createJob2() {
        Opportunity opp = createOpportunity();
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Customer_Preferred_Date__c = Date.today(),
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
        Database.insert(job);
        job = [Select j.Water_Heating_Fixing_Hours__c,  
                j.Unvented_Hot_Water_Hours__c, j.Type__c, j.Total_Job_Hours__c, j.SystemModstamp, j.Sub_Status__c, j.Status__c, 
                j.Specialist_Building_Hours__c, j.Solar_Hours__c, j.Scaffolding_Required__c, 
                j.Scaffolding_Job_Elements__c, j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, 
                j.Resourcing_Status__c, j.Quote__c, j.PowerFlush_Hours__c, j.Pending_Reason__c, 
                j.Payment_Collection_Hours__c, j.OwnerId, j.Own_Labour__c, j.Named_Employee__c, j.Name, 
                j.Merchant_Status__c, j.Mechanical_Hours__c, j.Linked_Job__c, j.LastModifiedDate, j.LastModifiedById, 
                j.LastActivityDate, j.LPG_Installation_Hours__c, j.IsDeleted, j.Installer_Notes__c, 
                j.Installation_Special_Instructions__c, j.Installation_Address__c, j.Id,  
                j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Work_ASP_Hours__c,  
                j.Electrical_Hours__c, j.Double_Handed_Job__c, j.District__c, j.Delivery_Slot__c, j.Delivery_Notes__c, j.Delivery_Date__c, 
                j.Customer_Preferred_Date__c, j.CreatedDate, j.CreatedById, j.Contractors__c,  
                j.Contractor_Installation_Hours_del__c, j.Contractor_Installation_Hours__c,  
                j.Connect_Solar_Panel_Hours__c, j.CRD_Code__c, j.CHI_Lead__c, j.Building_Work_Hours__c, 
                j.Bring_Forward_Job__c, j.Asbestos_Removal_Required__c, j.Asbestos_Removal_Hours__c, j.Asbestos_Removal_Fixed_Rate_Hours__c, 
                j.Asbestos_Job_Elements__c, j.CHI_Lead__r.Install_Postcode__c, j.Named_Employee__r.Always_Works_With__c,
                j.Override_Gap_Size_Tolerance__c, j.Too_Many_Script_Statements__c,District__r.Contractor__c,  District__r.Contractor_Band1__c, 
                District__r.Contractor_Band2__c, District__r.Contractor_Band3__c, District__r.Own_Labour__c,
                District__r.Consider_Contractors__c, District__r.Consider_Own_Labour__c,Finance_Expiry_Date__c,  S_P_hours__c
                From Job__c j Where j.Id = :job.Id];
        return job;
    }
    
    @isTest
    public static Job__c createJob3() {
        Opportunity opp = createOpportunity();
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=20, PowerFlush_Hours__c = 4, Customer_Preferred_Date__c = Date.today(),
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
        Database.insert(job);
        job = [Select j.Water_Heating_Fixing_Hours__c,  
                j.Unvented_Hot_Water_Hours__c, j.Type__c, j.Total_Job_Hours__c, j.SystemModstamp, j.Sub_Status__c, j.Status__c, 
                j.Specialist_Building_Hours__c, j.Solar_Hours__c, j.Scaffolding_Required__c, 
                j.Scaffolding_Job_Elements__c, j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, 
                j.Resourcing_Status__c, j.Quote__c, j.PowerFlush_Hours__c, j.Pending_Reason__c, 
                j.Payment_Collection_Hours__c, j.OwnerId, j.Own_Labour__c, j.Named_Employee__c, j.Name, 
                j.Merchant_Status__c, j.Mechanical_Hours__c, j.Linked_Job__c, j.LastModifiedDate, j.LastModifiedById, 
                j.LastActivityDate, j.LPG_Installation_Hours__c, j.IsDeleted, j.Installer_Notes__c, 
                j.Installation_Special_Instructions__c, j.Installation_Address__c, j.Id,  
                j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Work_ASP_Hours__c,  
                j.Electrical_Hours__c, j.Double_Handed_Job__c, j.District__c, j.Delivery_Slot__c, j.Delivery_Notes__c, j.Delivery_Date__c, 
                j.Customer_Preferred_Date__c, j.CreatedDate, j.CreatedById, j.Contractors__c,  
                j.Contractor_Installation_Hours_del__c, j.Contractor_Installation_Hours__c,  
                j.Connect_Solar_Panel_Hours__c, j.CRD_Code__c, j.CHI_Lead__c, j.Building_Work_Hours__c, 
                j.Bring_Forward_Job__c, j.Asbestos_Removal_Required__c, j.Asbestos_Removal_Hours__c, j.Asbestos_Removal_Fixed_Rate_Hours__c, 
                j.Asbestos_Job_Elements__c, j.CHI_Lead__r.Install_Postcode__c, j.Named_Employee__r.Always_Works_With__c,
                j.Override_Gap_Size_Tolerance__c, j.Too_Many_Script_Statements__c,District__r.Contractor__c,  District__r.Contractor_Band1__c, 
                District__r.Contractor_Band2__c, District__r.Contractor_Band3__c, District__r.Own_Labour__c,
                District__r.Consider_Contractors__c, District__r.Consider_Own_Labour__c,Finance_Expiry_Date__c,  S_P_hours__c
                From Job__c j Where j.Id = :job.Id];
        return job;
    }
    
    @isTest
    public static Job__c createJob4() {
        Opportunity opp = createOpportunity();
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=1, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =1, 
                                Customer_Preferred_Date__c = Date.today(),
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
        Database.insert(job);
        job = [Select j.Water_Heating_Fixing_Hours__c,  
                j.Unvented_Hot_Water_Hours__c, j.Type__c, j.Total_Job_Hours__c, j.SystemModstamp, j.Sub_Status__c, j.Status__c, 
                j.Specialist_Building_Hours__c, j.Solar_Hours__c, j.Scaffolding_Required__c, 
                j.Scaffolding_Job_Elements__c, j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, 
                j.Resourcing_Status__c, j.Quote__c, j.PowerFlush_Hours__c, j.Pending_Reason__c, 
                j.Payment_Collection_Hours__c, j.OwnerId, j.Own_Labour__c, j.Named_Employee__c, j.Name, 
                j.Merchant_Status__c, j.Mechanical_Hours__c, j.Linked_Job__c, j.LastModifiedDate, j.LastModifiedById, 
                j.LastActivityDate, j.LPG_Installation_Hours__c, j.IsDeleted, j.Installer_Notes__c, 
                j.Installation_Special_Instructions__c, j.Installation_Address__c, j.Id,  
                j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Work_ASP_Hours__c,  
                j.Electrical_Hours__c, j.Double_Handed_Job__c, j.District__c, j.Delivery_Slot__c, j.Delivery_Notes__c, j.Delivery_Date__c, 
                j.Customer_Preferred_Date__c, j.CreatedDate, j.CreatedById, j.Contractors__c,  
                j.Contractor_Installation_Hours_del__c, j.Contractor_Installation_Hours__c,  
                j.Connect_Solar_Panel_Hours__c, j.CRD_Code__c, j.CHI_Lead__c, j.Building_Work_Hours__c, 
                j.Bring_Forward_Job__c, j.Asbestos_Removal_Required__c, j.Asbestos_Removal_Hours__c, j.Asbestos_Removal_Fixed_Rate_Hours__c, 
                j.Asbestos_Job_Elements__c, j.CHI_Lead__r.Install_Postcode__c, j.Named_Employee__r.Always_Works_With__c ,
                j.Override_Gap_Size_Tolerance__c, j.Too_Many_Script_Statements__c,District__r.Contractor__c,  District__r.Contractor_Band1__c, 
                District__r.Contractor_Band2__c, District__r.Contractor_Band3__c, District__r.Own_Labour__c,
                District__r.Consider_Contractors__c, District__r.Consider_Own_Labour__c,Finance_Expiry_Date__c,  S_P_hours__c
                From Job__c j Where j.Id = :job.Id];
        return job;
    }
    @isTest
    public static Job__c createJob5() {
        Opportunity opp = createOpportunity1();
        opp.Latest_customer_category__c = 1;
        update opp;
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Customer_Preferred_Date__c = null,
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = false);
        Database.insert(job);
        job = [Select j.Water_Heating_Fixing_Hours__c,  
                j.Unvented_Hot_Water_Hours__c, j.Type__c, j.Total_Job_Hours__c, j.SystemModstamp, j.Sub_Status__c, j.Status__c, 
                j.Specialist_Building_Hours__c, j.Solar_Hours__c, j.Scaffolding_Required__c, 
                j.Scaffolding_Job_Elements__c, j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, 
                j.Resourcing_Status__c, j.Quote__c, j.PowerFlush_Hours__c, j.Pending_Reason__c, 
                j.Payment_Collection_Hours__c, j.OwnerId, j.Own_Labour__c, j.Named_Employee__c, j.Name, 
                j.Merchant_Status__c, j.Mechanical_Hours__c, j.Linked_Job__c, j.LastModifiedDate, j.LastModifiedById, 
                j.LastActivityDate, j.LPG_Installation_Hours__c, j.IsDeleted, j.Installer_Notes__c, 
                j.Installation_Special_Instructions__c, j.Installation_Address__c, j.Id,  
                j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Work_ASP_Hours__c,  
                j.Electrical_Hours__c, j.Double_Handed_Job__c, j.District__c, j.Delivery_Slot__c, j.Delivery_Notes__c, j.Delivery_Date__c, 
                j.Customer_Preferred_Date__c, j.CreatedDate, j.CreatedById, j.Contractors__c,  
                j.Contractor_Installation_Hours_del__c, j.Contractor_Installation_Hours__c,  
                j.Connect_Solar_Panel_Hours__c, j.CRD_Code__c, j.CHI_Lead__c, j.Building_Work_Hours__c, 
                j.Bring_Forward_Job__c, j.Asbestos_Removal_Required__c, j.Asbestos_Removal_Hours__c, j.Asbestos_Removal_Fixed_Rate_Hours__c, 
                j.Asbestos_Job_Elements__c, j.CHI_Lead__r.Install_Postcode__c, j.Named_Employee__r.Always_Works_With__c,
                j.Override_Gap_Size_Tolerance__c, j.Too_Many_Script_Statements__c,District__r.Contractor__c,  District__r.Contractor_Band1__c, 
                District__r.Contractor_Band2__c, District__r.Contractor_Band3__c, District__r.Own_Labour__c,
                District__r.Consider_Contractors__c, District__r.Consider_Own_Labour__c,Finance_Expiry_Date__c,  S_P_hours__c
                From Job__c j Where j.Id = :job.Id];
        return job;
    }
    
    @isTest
    public static Employee__c createEmployeeAndPostcodeSectors() {
        Postcode_Sector__c pcs = createTestGeography();
        Employee__c emp = createEmployee();
        Employee_Postcode_Sectors__c epcs = new Employee_Postcode_Sectors__c(Employee__c = emp.Id, Postcode_Sector__c = pcs.ID,
                                            Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(7));
        Database.insert(epcs);
        
        emp = [Select e.X3G_phone_Number__c, e.Works_Anywhere_in_District__c, e.Works_Anywhere_in_Area__c, e.UsesBM__c, 
                e.User_code__c, e.Use_of_home_broadband__c, e.Textmail__c, e.TSA_Code__c, e.SystemModstamp, e.Supplier__c, 
                e.Supplier_Branch_Num__c, e.Street__c, e.State__c, e.Start_Date__c, e.Spare_Serial_Number__c, e.Spare_SIM_Number__c, 
                e.Spare_Laptop__c, e.Spare_Asset_Number__c, e.Source__c, e.Salesforce_User__c, e.SIM_Number__c, e.Retailer_No__c, 
                e.Resource_Type__c, e.Resource_Id__c, e.Region__c, e.RSA_token_Serial_Number__c, e.Printer__c, e.Primary_Role__c, 
                e.Primary_Laptop__c, e.Postcode__c, e.Pool_Diary__c, e.Phone_Number_3G__c, e.Phone_No__c, e.Personal_Broadband__c, 
                e.Pay_Number__c, e.PSTN_BG_Connectivity__c, e.OwnerId, e.Own_Labour__c, e.Never_Works_With__c, e.Net_Promoter_Score__c, 
                e.Name, e.Manager__c, e.Last_Name__c, e.LastModifiedDate, e.LastModifiedById, e.Laptop__c, e.LAN_ID__c, e.IsDeleted, 
                e.Inactive__c, e.If_Other_make_of_laptop__c, e.Id, e.Group__c, e.GasSafe_Licence_Number__c, e.Fujitsu_Serial_Number__c, 
                e.First_Name__c, e.Fax_No__c, e.End_Date__c, e.Employee_Record_ID__c, e.Employee_Number__c, e.Emp_type__c, e.Email__c, 
                e.District__c, e.District_ID__c, e.Default_Pricebook_ID__c, e.CreatedDate, e.CreatedById, e.Country__c, e.Contractor_Band__c, 
                e.City__c, e.Centrica_Asset_Tag__c, e.Always_Works_With__c, e.Always_Works_Alone__c, e.ADSL_BG_Connectivity__c,
                e.Supplier__r.Name, e.District__r.Name, e.District__r.Region__c,Skip_rule__c, e.Always_Works_With_Electrician__c,latitude__latitude__s,latitude__longitude__s,
                    (select Employee__c, Employee__r.Always_Works_With__c, employee__r.Always_Works_With_Electrician__c,Type__c from Employee_Postcodes__r ) 
                From Employee__c e where e.Id = :emp.ID]; 

        return emp;
    }
    
    @isTest
    public static Employee__c createEmployeeCoversDistrict() {
        Employee__c emp = createEmployeeAnywhereDistrict();
        
        emp = [Select e.X3G_phone_Number__c, e.Works_Anywhere_in_District__c, e.Works_Anywhere_in_Area__c, e.UsesBM__c, 
                e.User_code__c, e.Use_of_home_broadband__c, e.Textmail__c, e.TSA_Code__c, e.SystemModstamp, e.Supplier__c, 
                e.Supplier_Branch_Num__c, e.Street__c, e.State__c, e.Start_Date__c, e.Spare_Serial_Number__c, e.Spare_SIM_Number__c, 
                e.Spare_Laptop__c, e.Spare_Asset_Number__c, e.Source__c, e.Salesforce_User__c, e.SIM_Number__c, e.Retailer_No__c, 
                e.Resource_Type__c, e.Resource_Id__c, e.Region__c, e.RSA_token_Serial_Number__c, e.Printer__c, e.Primary_Role__c, 
                e.Primary_Laptop__c, e.Postcode__c, e.Pool_Diary__c, e.Phone_Number_3G__c, e.Phone_No__c, e.Personal_Broadband__c, 
                e.Pay_Number__c, e.PSTN_BG_Connectivity__c, e.OwnerId, e.Own_Labour__c, e.Never_Works_With__c, e.Net_Promoter_Score__c, 
                e.Name, e.Manager__c, e.Last_Name__c, e.LastModifiedDate, e.LastModifiedById, e.Laptop__c, e.LAN_ID__c, e.IsDeleted, 
                e.Inactive__c, e.If_Other_make_of_laptop__c, e.Id, e.Group__c, e.GasSafe_Licence_Number__c, e.Fujitsu_Serial_Number__c, 
                e.First_Name__c, e.Fax_No__c, e.End_Date__c, e.Employee_Record_ID__c, e.Employee_Number__c, e.Emp_type__c, e.Email__c, 
                e.District__c, e.District_ID__c, e.Default_Pricebook_ID__c, e.CreatedDate, e.CreatedById, e.Country__c, e.Contractor_Band__c, 
                e.City__c, e.Centrica_Asset_Tag__c, e.Always_Works_With__c, e.Always_Works_Alone__c, e.ADSL_BG_Connectivity__c,
                e.Supplier__r.Name, e.District__r.Name, e.District__r.Region__c, Skip_rule__c,e.Always_Works_With_Electrician__c,latitude__latitude__s,latitude__longitude__s,
                    (select Employee__c, Employee__r.Always_Works_With__c,employee__r.Always_Works_With_Electrician__c, Type__c from Employee_Postcodes__r )
                From Employee__c e where e.Id = :emp.ID];

        return emp;
    }
    
    @isTest
    public static Employee__c createEmployeeCoversArea() {
        Employee__c emp = createEmployeeAnywhereArea();
        
        emp = [Select e.X3G_phone_Number__c, e.Works_Anywhere_in_District__c, e.Works_Anywhere_in_Area__c, e.UsesBM__c, 
                e.User_code__c, e.Use_of_home_broadband__c, e.Textmail__c, e.TSA_Code__c, e.SystemModstamp, e.Supplier__c, 
                e.Supplier_Branch_Num__c, e.Street__c, e.State__c, e.Start_Date__c, e.Spare_Serial_Number__c, e.Spare_SIM_Number__c, 
                e.Spare_Laptop__c, e.Spare_Asset_Number__c, e.Source__c, e.Salesforce_User__c, e.SIM_Number__c, e.Retailer_No__c, 
                e.Resource_Type__c, e.Resource_Id__c, e.Region__c, e.RSA_token_Serial_Number__c, e.Printer__c, e.Primary_Role__c, 
                e.Primary_Laptop__c, e.Postcode__c, e.Pool_Diary__c, e.Phone_Number_3G__c, e.Phone_No__c, e.Personal_Broadband__c, 
                e.Pay_Number__c, e.PSTN_BG_Connectivity__c, e.OwnerId, e.Own_Labour__c, e.Never_Works_With__c, e.Net_Promoter_Score__c, 
                e.Name, e.Manager__c, e.Last_Name__c, e.LastModifiedDate, e.LastModifiedById, e.Laptop__c, e.LAN_ID__c, e.IsDeleted, 
                e.Inactive__c, e.If_Other_make_of_laptop__c, e.Id, e.Group__c, e.GasSafe_Licence_Number__c, e.Fujitsu_Serial_Number__c, 
                e.First_Name__c, e.Fax_No__c, e.End_Date__c, e.Employee_Record_ID__c, e.Employee_Number__c, e.Emp_type__c, e.Email__c, 
                e.District__c, e.District_ID__c, e.Default_Pricebook_ID__c, e.CreatedDate, e.CreatedById, e.Country__c, e.Contractor_Band__c, 
                e.City__c, e.Centrica_Asset_Tag__c, e.Always_Works_With__c, e.Always_Works_Alone__c, e.ADSL_BG_Connectivity__c,
                e.Supplier__r.Name, e.District__r.Name, e.District__r.Region__c, Skip_rule__c,e.Always_Works_With_Electrician__c,latitude__latitude__s,latitude__longitude__s,
                    (select Employee__c, Employee__r.Always_Works_With__c,employee__r.Always_Works_With_Electrician__c, Type__c from Employee_Postcodes__r )
                From Employee__c e where e.Id = :emp.ID];

        return emp;
    }
}