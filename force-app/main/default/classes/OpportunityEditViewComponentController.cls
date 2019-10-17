public class OpportunityEditViewComponentController{
    
    public List<Opportunity> Opportunities{get; set;}   
    public String LeadCommentsOpp;  
    public String LeadCommentsEdit;
    public String comments='';
    public List<String> commentsArray;
   
    public string catIndicator{get;set;}
    public string customerCateogryType {get;set;}
    public list<category_Indicator__c> catInd{get;set;}    
    public String getLeadCommentsEdit(){
        return LeadCommentsEdit;
    }
    public void setLeadCommentsEdit(String s){
        System.debug('### before set lead commentsEdit: s='+s);
        this.LeadCommentsEdit=s;
        System.debug('### set lead commentsEdit: '+this.LeadCommentsEdit);
    }
    
    public String getLeadCommentsOpp(){
        System.debug('###*** lead comments: '+Opportunities[0].Lead_Comments__c);
        System.debug('### opportunity: '+Opportunities[0]);
        return Opportunities[0].Lead_Comments__c;
    }
    
    public List<String> getLeadCommentsOppArray(){
        commentsArray=new List<String>();
        try{
            if(opportunities != null)       
            {                       
                comments = Opportunities[0].Lead_Comments__c;
                System.debug('###**** Comments: '+comments);
                
                if(comments!=null && comments !='')
                {
                    commentsArray = comments.split('\\n');              
                }
                else
                {
                    commentsArray.add('');
                }               
                System.debug('###**** commentsArray: '+commentsArray);
                System.debug('###**** commentsArray size: '+commentsArray.size());              
            }   
        }catch(Exception e){
            System.debug('###**** exception occured: '+e);
            return null;
        }
        return commentsArray;
    }
    
    public String Referral_Employee {
        get
        {
            return Opportunities[0].Referral_Employee__c;
        }
    
        set
        {
            Opportunities[0].Referral_Employee__c = null;
            Opportunities[0].Referral_Employee__r = null;
            if(Opportunities!=null && Opportunities.size()!=0 )
            {
                if(value != '') Opportunities[0].Referral_Employee__c = value;
            }
        }
    }
      public void indicator(){
      system.debug('*inside ind');
      string heat = ApexPages.currentPage().getParameters().get('Heat');
      string hotWater = ApexPages.currentPage().getParameters().get('HW');
      string oHeat = ApexPages.currentPage().getParameters().get('OH');
       string reason;
      
      string subreason = ApexPages.currentPage().getParameters().get('subreason');
     List<Opportunity> listOpp=new List<Opportunity>();
      
      listOpp= [select id,name,Vulnerable_category__c,Customer_Category_Record_Modified_By__c,Customer_Category_Modified_Datetime__c,Latest_customer_category_indicator__c,
                  Is_the_customers_boiler_working__c, Does_the_customer_have_hot_water__c ,Customer_have_any_other_form_of_HEAT__c,Is_the_customer_vulnerable__c,customer_Category_Logic1__c, 
                   Vulnerable_reason__c,Latest_customer_category__c,Last_customer_cat_info_update_source__c,Stage_object_type__c ,Stage_object_id__c,pending_update_to_customer_category__c
                    from opportunity where id=:Opportunities[0].id ];
      customerCateogryType = (listOpp[0].customer_category_Logic1__c!=null)?listOpp[0].customer_category_Logic1__c:'0';
       //subreason = listOpp[0].Vulnerable_reason__c; 
       reason= listOpp[0].Vulnerable_category__c;
        system.debug('*customerCateogryType '+customerCateogryType );
      if(oHeat!='Yes' && oHeat!='No')
      oHeat='';
      
     // reason = (reason=='-- NONE --' || reason == '')?null:reason;
     // subreason = (subreason=='-- NONE --' || subreason == '')?null:subreason;
        system.debug('*reason '+reason );
        system.debug('*subreason '+subreason );
      string vul = ApexPages.currentPage().getParameters().get('vul');
      
      catInd = [select id,name,Reason__c,Sub_Reason__c,Heating__c,Hot_Water__c,Other_Heat__c,Vunerable__c,Category__c,Category_Indicator__c from category_Indicator__c 
                where Customer_Category_Logic__c = :customerCateogryType and Heating__c = :heat and Hot_Water__c = :hotWater and   Sub_Reason__c = :subreason and Other_Heat__c = :oHeat];
        system.debug('*catInd '+catInd );
     //Reason__c = :reason and
         if(catInd.size()>0)
         {
             Opportunities[0].Latest_customer_category__c = catInd[0].Category__c;
             catIndicator = catInd[0].Category_Indicator__c;
               system.debug('*catIndicator '+catIndicator );
              Opportunities[0].Vulnerable_reason__c = subreason;
              Opportunities[0].Vulnerable_category__c = reason;
             
         }else{
            
            catIndicator = '<img src="/resource/1337590708000/Undefined" alt="Undefined" height="25" width="90" border="0"/>';
             Opportunities[0].Latest_customer_category__c = 99;
            
         }
    }

}