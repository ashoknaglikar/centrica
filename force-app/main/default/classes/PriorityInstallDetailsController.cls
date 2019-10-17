/*
Controller class for inline visualforce showing
customer category information on CHI Lead
*/
public with sharing class PriorityInstallDetailsController {
    public boolean isEdit {get; set;}               // variable decide whether the mode is editable or not
    public Opportunity opp {get; set;}              // instance of Opportunity object 
    
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
    

    public PriorityInstallDetailsController(ApexPages.StandardController controller) {
    isEdit = true;
    this.opp = (Opportunity)controller.getRecord();
    opp = [select id,name,Vulnerable_category__c,Customer_Category_Record_Modified_By__c,Customer_Category_Modified_Datetime__c,Latest_customer_category_indicator__c,
                  Is_the_customers_boiler_working__c, Does_the_customer_have_hot_water__c ,Customer_have_any_other_form_of_HEAT__c,Is_the_customer_vulnerable__c,customer_Category_Logic1__c, 
                   Vulnerable_reason__c,Latest_customer_category__c,Last_customer_cat_info_update_source__c,Stage_object_type__c ,Stage_object_id__c,pending_update_to_customer_category__c
                    from opportunity where id=:opp.id];
         
     customerCateogryType = (opp.customer_category_Logic1__c!=null)?opp.customer_category_Logic1__c:'0';
     system.debug('-=-=-=-=-=-=-=-=-'+customerCateogryType);
     rMap = new Map<string,List<String>>();
     mcs = categoryMap__c.getAll();
       
       subreason = opp.Vulnerable_reason__c; 
       reason= opp.Vulnerable_category__c;
       
       system.debug('////////////'+mcs);
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
    
    /*
    Method called when user click "Edit" button.
    It also enable editable screen.
    */
    public void editDetails()
    {
        isEdit = false;
        
    }
    
    /*
    Method save the updates to Opportunity on clicking of "Save" button.
    It also enable read only mode once updations saved to database.
    */
    public void saveDetails()
    {
        isEdit = true;
        populateCustCategoryDetails();
        update opp;
        

    }
    
    /*
    Method redirect user to Opportunity record
    when user slick "Cancel" button.
    */
    public void cancelDetails()
    {
        isEdit = true;
    }
    
    /*
    Method populates customer category details based on
    response to questions from user 
    */
    private void populateCustCategoryDetails(){
     
            opp.Customer_Category_Record_Modified_By__c = Userinfo.getUserId();
            opp.Customer_Category_Modified_Datetime__c = DateTime.now();
            

            /*if (opp.Is_the_customers_boiler_working__c == 'Yes' && opp.Does_the_customer_have_hot_water__c == 'Yes'){
                         opp.Customer_have_any_other_form_of_HEAT__c = 'Not applicable';
                         opp.Is_the_customer_vulnerable__c = 'Not applicable';
            }
            if(opp.Is_the_customers_boiler_working__c == 'Yes' && opp.Does_the_customer_have_hot_water__c == 'No'){
                         opp.Customer_have_any_other_form_of_HEAT__c = 'Not applicable';
            }
            if(opp.Is_the_customer_vulnerable__c != 'Yes'){
                         opp.Vulnerable_reason__c = '';
            }*/
              

             opp.Last_customer_cat_info_update_source__c = 'SGC';
             opp.Stage_object_type__c = 'CHI Lead';
             opp.Stage_object_id__c = opp.id;
             if(opp.Id != null)
             opp.pending_update_to_customer_category__c = true;
               

             /* if(opp.Is_the_customers_boiler_working__c == 'Yes' && opp.Does_the_customer_have_hot_water__c == 'Yes'){
                       opp.Latest_customer_category__c = 4;
              }else if(opp.Is_the_customers_boiler_working__c == 'Yes' && opp.Does_the_customer_have_hot_water__c == 'No' && opp.Is_the_customer_vulnerable__c == 'Yes'){
                       opp.Latest_customer_category__c = 2;
              }else if(opp.Is_the_customers_boiler_working__c == 'Yes' && opp.Does_the_customer_have_hot_water__c == 'No' && opp.Is_the_customer_vulnerable__c == 'No'){
                       opp.Latest_customer_category__c = 3;
              }else if(opp.Is_the_customers_boiler_working__c == 'No' && opp.Does_the_customer_have_hot_water__c == 'Yes' && 
                       opp.Customer_have_any_other_form_of_HEAT__c == 'Yes' && opp.Is_the_customer_vulnerable__c == 'Yes'){
                       opp.Latest_customer_category__c = 2;
              }else if(opp.Is_the_customers_boiler_working__c == 'No' && opp.Does_the_customer_have_hot_water__c == 'Yes' && 
                       opp.Customer_have_any_other_form_of_HEAT__c == 'Yes' && opp.Is_the_customer_vulnerable__c == 'No'){
                       opp.Latest_customer_category__c = 3;
              }else if(opp.Is_the_customers_boiler_working__c == 'No' && opp.Does_the_customer_have_hot_water__c == 'Yes' && 
                       opp.Customer_have_any_other_form_of_HEAT__c == 'No' && opp.Is_the_customer_vulnerable__c == 'Yes'){
                       opp.Latest_customer_category__c = 1;
              }else if(opp.Is_the_customers_boiler_working__c == 'No' && opp.Does_the_customer_have_hot_water__c == 'Yes' && 
                       opp.Customer_have_any_other_form_of_HEAT__c == 'No' && opp.Is_the_customer_vulnerable__c == 'No'){
                       opp.Latest_customer_category__c = 2;
              }else if(opp.Is_the_customers_boiler_working__c == 'No' && opp.Does_the_customer_have_hot_water__c == 'No' && 
                       opp.Customer_have_any_other_form_of_HEAT__c == 'Yes' && opp.Is_the_customer_vulnerable__c == 'Yes'){
                       opp.Latest_customer_category__c = 2;
              }else if(opp.Is_the_customers_boiler_working__c == 'No' && opp.Does_the_customer_have_hot_water__c == 'No' && 
                       opp.Customer_have_any_other_form_of_HEAT__c == 'Yes' && opp.Is_the_customer_vulnerable__c == 'No'){
                       opp.Latest_customer_category__c = 3;
              }else if(opp.Is_the_customers_boiler_working__c == 'No' && opp.Does_the_customer_have_hot_water__c == 'No' && 
                       opp.Customer_have_any_other_form_of_HEAT__c == 'No' && opp.Is_the_customer_vulnerable__c == 'Yes'){
                       opp.Latest_customer_category__c = 1;
              }else if(opp.Is_the_customers_boiler_working__c == 'No' && opp.Does_the_customer_have_hot_water__c == 'No' && 
                       opp.Customer_have_any_other_form_of_HEAT__c == 'No' && opp.Is_the_customer_vulnerable__c == 'No'){
                       opp.Latest_customer_category__c = 2;
              }else{
                       opp.Latest_customer_category__c = 99;
              }*/
              
              

              

   }
   
     public void indicator(){
      system.debug(loggingLevel.INFO,'Indicator called:-----');
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
             
         }else{
            
            catIndicator = '<img src="/resource/1337590708000/Undefined" alt="Undefined" height="25" width="90" border="0"/>';
            opp.Latest_customer_category__c = 99;
            
         }
    }
   
}