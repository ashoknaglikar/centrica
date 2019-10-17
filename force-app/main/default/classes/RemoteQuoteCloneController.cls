public with sharing class  RemoteQuoteCloneController {
    
    private ID opportunityId;
    Public Opportunity opp{get;set;}
    public List<SelectOption> productList{get;set;}
    public String selectedProduct{get;set;}
    
    Map<string,CategoryMap__c> mcs = new Map<string,CategoryMap__c>();
    public Map<string,List<String>> rMap{get;set;}
    public string reason{get;set;}
    public string subreason{get;set;}
    public string catIndicator{get;set;}
    public list<category_Indicator__c> catInd{get;set;}
    string customerCateogryType;
    
    public string getcustomerCateogryType(){
       return customerCateogryType;
    }
    
 public RemoteQuoteCloneController (ApexPages.StandardController controller) {
     
        opportunityId = ApexPages.currentPage().getParameters().get('id');
        this.opp = (Opportunity)controller.getRecord();
        opp = [select id,name,Product_Interest__c,ta_notes__c,Vulnerable_category__c,Customer_Category_Record_Modified_By__c,Customer_Category_Modified_Datetime__c,Latest_customer_category_indicator__c,
                  Is_the_customers_boiler_working__c, Does_the_customer_have_hot_water__c ,Customer_have_any_other_form_of_HEAT__c,Is_the_customer_vulnerable__c,customer_Category_Logic1__c, 
                   Vulnerable_reason__c,Latest_customer_category__c,Last_customer_cat_info_update_source__c,Stage_object_type__c ,Stage_object_id__c,pending_update_to_customer_category__c,account.Primary_Contact__c
                    from opportunity where id=:opp.id];
       
        productList= new List<SelectOption>();
        productList.add(new SelectOption('','--None--'));
        productList.add(new SelectOption('Central Heating Boiler','Central Heating Boiler'));
        productList.add(new SelectOption('Small Commercial','Small Commercial'));
        /*productList.add(new SelectOption('Guided Sale','Guided Sale'));
        productList.add(new SelectOption('Straight Swap','Straight Swap'));
        productList.add(new SelectOption('Oil Boiler','Oil Boiler'));*/
        
        customerCateogryType = (opp.customer_category_Logic1__c!=null)?opp.customer_category_Logic1__c:'0';
        rMap = new Map<string,List<String>>();
        mcs = categoryMap__c.getAll();
       
        subreason = opp.Vulnerable_reason__c; 
        reason= opp.Vulnerable_category__c;
       
        for(categoryMap__c cmap: mcs.values()){
          if(rMap.containskey(cmap.reason__c)){
            rMap.get(cmap.reason__c).add(cmap.subReason__c); 
         }else{
           list<string> res = new list<string>();
           res.add(cmap.subReason__c);
           rMap.put(cmap.reason__c,res);
         }
       }
    }
  
  public PageReference bookAppointment() {
     
      if(selectedProduct==null ||selectedProduct=='')
      {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Product Interest:You must enter a value')); 
        return null;
      }
      
      /*Opportunity cloneLead = new Opportunity();
      Opportunity existingLead = database.query(makeQueryWithAllFields('Opportunity', 'Where id =\''+opportunityId+'\''));
      
      cloneLead = existingLead.clone(true);
      cloneLead.StageName = 'Active';
      cloneLead.Stage_Reason__c = null;
      cloneLead.id = null;
       
      
       populateCustCategoryDetails();
       cloneLead.Is_the_customers_boiler_working__c=opp.Is_the_customers_boiler_working__c;
       cloneLead.Does_the_customer_have_hot_water__c=opp.Does_the_customer_have_hot_water__c;
       cloneLead.Customer_have_any_other_form_of_HEAT__c=opp.Customer_have_any_other_form_of_HEAT__c;
       cloneLead.Is_the_customer_vulnerable__c=opp.Is_the_customer_vulnerable__c;
       cloneLead.Vulnerable_reason__c=opp.Vulnerable_reason__c;
       cloneLead.Latest_customer_category__c=opp.Latest_customer_category__c;
       
       cloneLead.Customer_Category_Record_Modified_By__c=Userinfo.getUserId();
       cloneLead.Customer_Category_Modified_Datetime__c=DateTime.now();
       cloneLead.Stage_object_type__c = 'CHI Lead';
       cloneLead.Last_customer_cat_info_update_source__c = 'SGC';
       cloneLead.Stage_object_id__c = null;
       
       cloneLead.Product_Interest__c =selectedProduct;
       cloneLead.ta_notes__c =opp.ta_notes__c;
       /*cloneLead.CHI_lead_Id__c =existingLead.CHI_lead_id__c+1;
       List<String> nameList= existingLead.name.split('-');
       cloneLead.name =cloneLead.CHI_lead_Id__c+'-'+nameList[1];
       
       existingLead.StageName = 'Closed Lost';
       existingLead.Stage_Reason_CHICR__c = 'Moved to HSA Journey';
       update existingLead;*/
       
      
       try{
             
            opp.Product_Interest__c =selectedProduct;
            populateCustCategoryDetails();
            update opp;
            system.debug('customer ca '+opp);
            /*insert cloneLead;*/
            return new PageReference('/apex/availability?existingLead=true&gDeal=0&new=true&var_cancelledapp=null&var_contactId='+opp.account.Primary_Contact__c+'&var_date=null&var_OpptyId='+opp.id+'&var_Source=SF&view=null');
            
       }
       catch(Exception ex)
       {  
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getmessage()));
          return null;
       }
    }
    
    
    public void populateCustCategoryDetails(){
            opp.Customer_Category_Record_Modified_By__c = Userinfo.getUserId();
            opp.Customer_Category_Modified_Datetime__c = DateTime.now();
            opp.Last_customer_cat_info_update_source__c = 'SGC';
            opp.Stage_object_type__c = 'CHI Lead';
            opp.Stage_object_id__c = opp.id;
            if(opp.Id != null)
            opp.pending_update_to_customer_category__c = true;
   }
   
   public void indicator(){
      string heat = ApexPages.currentPage().getParameters().get('Heat');
      string hotWater = ApexPages.currentPage().getParameters().get('HW');
      string oHeat = ApexPages.currentPage().getParameters().get('OH');
      if(oHeat!='Yes' && oHeat!='No')
      oHeat='';
      
      reason = (reason=='-- NONE --' || reason == '')?null:reason;
      subreason = (subreason=='-- NONE --' || subreason == '')?null:subreason;
      
      string vul = ApexPages.currentPage().getParameters().get('vul');
      system.debug(LoggingLevel.info,'all values:==='+heat+''+hotWater+' '+oHeat+' '+vul+' '+subReason+' '+Reason);
      
      catInd = [select id,name,Reason__c,Sub_Reason__c,Heating__c,Hot_Water__c,Other_Heat__c,Vunerable__c,Category__c,Category_Indicator__c from category_Indicator__c 
                where Customer_Category_Logic__c = :customerCateogryType and Heating__c = :heat and Hot_Water__c = :hotWater and Reason__c = :subreason and  Sub_Reason__c = :reason and Other_Heat__c = :oHeat];
     
      system.debug(logginglevel.info,'return values:----'+catInd);   
         if(catInd.size()>0)
         {
             
             opp.Latest_customer_category__c = catInd[0].Category__c;
             catIndicator = catInd[0].Category_Indicator__c;
             opp.Vulnerable_reason__c = reason;
             opp.Vulnerable_category__c = subreason;
             system.debug('customer ca if '+opp.Latest_customer_category__c);
             
         }else{
            
            catIndicator = '<img src="/resource/1337590708000/Undefined" alt="Undefined" height="25" width="90" border="0"/>';
            opp.Latest_customer_category__c = 99;
             system.debug('customer ca else '+opp.Latest_customer_category__c);
           
         }
    }
    
    /*public static string makeQueryWithAllFields(string objectName, string whereCriteria){
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){
                Schema.DescribeFieldResult fd = ft.getDescribe(); 
                    selectFields.add(fd.getName()); 
            }
        }
        
        String selects = '';
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}         
            
        }
        
        string finalQuery  = 'Select '+selects+' from '+objectName +' '+whereCriteria;
        return finalQuery;
    }*/

}