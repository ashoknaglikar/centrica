public class MerchantViewController {

// The purpose of the merchant view was in reply to CR-000483.
// A screen or view is SFDC was required to allow the merchant PTS a limited view of Salesforce customer and order details,
// without the ability to view data classed as sensitive i.e. Employee pay number.
// Further development may be required if more merchants are created or other user types require use.
// Created by Philip Dennison - 23/07/2011
    
// Updated - 02/05/2013 by Phil Dennison - Updated to bring in 'Latest_customer_category_indicator__c' for CR-000964

// Updated - 11/06/2015 by Ashok Gajapathi - search done based on SAP Number / JOB Number / Lead Number
public boolean showDetail{get;set;} 
public String PONumber{get;set;}
public list<Order__c> PODetails{get;set;}
public String OppID{get;set;}
public Contact ContactDetails{get;set;}
public List<Diary_entry__c> DiaryDetails{get;set;}
public string errorMsg{get;set;}
public boolean SelectingOrder{get;set;}
public boolean showtrue1{get;set;}
  

    public PageReference Search() {
        // Only allow details of purchase orders to be returned where the supplier is PTS as the screen is only
        // for PTS at this moment in time.
        PODetails = new list<Order__c>();
        set<string> groupNames = new set<string>();
        set<Id> supplierId = new set<Id>();
        // get all the public group assigned to the user
        for(GroupMember groupMember : [Select g.UserOrGroupId, g.Group.Name, g.GroupId From GroupMember g
                        where g.UserOrGroupId =: userinfo.GetUserId() ])
        {
            groupNames.add(groupMember.Group.Name);
        }
        // serach for the suppliers with same name as group name and add the supplier ids
        for(Supplier__c supp : [Select Id, Name from Supplier__c Where name in :groupNames ])
        {
            supplierId.add(supp.Id);
        }
        
        if(PONumber!=null && PONumber!='')
        {
        PONumber = PONumber.trim();
    	try{
        PODetails = [SELECT ID, Job__c, Supplier_Number__c, SAP_Number__c, Status__c, Name, Order_Date__c, 
                    Job_Delivery_Date__c,Delivery_Slot__c,Order_Note__c, order_value__c,Job__r.Delivery_Notes__c,
                    Job__r.Name , Job__r.status__c , Job__r.District__c , Job__r.Region__c,
                    Job__r.DHM_Name__c , Job__r.DHM_Phone__c , Job__r.CHI_Lead__c,Job__r.CHI_Lead__r.name,Job__r.CHI_Lead__r.CHI_Lead_Id__c,
                    Job__r.CHI_Lead__r.StageName ,Job__r.CHI_Lead__r.Account.BillingCity, 
                    Job__r.CHI_Lead__r.Account.BillingStreet,Job__r.CHI_Lead__r.Account.BillingState ,
                    Job__r.CHI_Lead__r.Account.BillingPostalCode , Job__r.Latest_customer_category_indicator__c,
                    (Select Code__c, Description__c, P5_Status_c__c, P5_Unit_Price_c__c, Qty__c, Quantity_Returned__c, Total_Amount__c, Units__c From Order_Line_Items__r)   
                    FROM Order__c WHERE Supplier__c in :supplierId AND (SAP_number__c =:PONumber OR Job__r.Name =:PONumber OR Job__r.CHI_Lead__r.CHI_Lead_Id__c =:PONumber)];
        system.debug('###PODetails'+ PODetails.size());
        }
        catch(exception e)  {
            errorMsg = 'This is not a valid SAP or you do not have permissions on this record';
            setErrorMsg();
            showDetail = false;
            return null;
                            }
        }                    
              
        if(PODetails != NULL & PODetails.size()==1)             
        {
        showDetail = true; 
        selectingOrder = false; 
        showtrue1 = true;                                    
        // Extract required opportunity information
        OppID = PODetails[0].Job__r.CHI_Lead__c;
        // Extract required Account information
        ContactDetails = [SELECT ID, Name,email__c,Mobilephone,HomePhone,OtherPhone, Phone 
                            FROM contact 
                            WHERE Primary_Contact__c = TRUE AND AccountID =:PODetails[0].Job__r.CHI_Lead__r.AccountId limit 1]; 
                          
        DiaryDetails = [SELECT Week__c, Start_Date__c, Sub_Type__c, Week__r.Employee__r.First_Name__c,
                        Week__r.Employee__r.Last_Name__c, Week__r.Employee__r.Phone_No__c,Week__r.Employee__r.Supplier__c  
                        FROM Diary_Entry__c WHERE Job__c =: PODetails[0].Job__c order by start_date__c ];
                        
        }
        else if(PODetails.size()>1){
          showDetail = true;
          SelectingOrder = true;
          showtrue1 = false;
        
        }
        
        return null;
        }
        
        public void setErrorMsg()
        {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.warning, errorMsg);
            ApexPages.addMessage(msg);
        }
}