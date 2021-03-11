public class newConstomerController {
    public Account account {get;set;}
    
    Map<string,CategoryMap__c> mcs = new Map<string,CategoryMap__c>();
    public Map<string,List<String>> rMap{get;set;}
    
    List<ContactInfo> coninfoList = new List<ContactInfo>();
    public String ContactAddress {get; set;} 
    public boolean showSecCon{get;set;}
    public string reason{get;set;}
    public string subreason{get;set;}
    //changes By Ashok G
    public list<category_Indicator__c> catInd{get;set;}
    public string catIndicator{get;set;}
    public string customerCateogryType {get;set;}
    public string acceptBttnClr{get;set;}
    public string optOutBttnClr{get;set;}
    public String gasCMsg{get;set;}
    public Boolean gcNoMatch{get;set;}
    public PicklistWrapper[] piclistValues {get;set;}
    Utilities util = new Utilities();
    public boolean cchMessage {get;set;}
    
   public newConstomerController ()
   {
       acceptBttnClr=optOutBttnClr='#b3e000';
       showSecCon = false;
       rMap = new Map<string,List<String>>();
       cchMessage = false;
       mcs = categoryMap__c.getAll();
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
   
         //Method to verify gas cousil number and to set pop up message alert
     public PageReference verifyGCNumber(){
    
       system.debug('**2');
      String gasOne= Apexpages.currentPage().getParameters().get('g1');
      String gasTwo= Apexpages.currentPage().getParameters().get('g2');
      String gasThre = Apexpages.currentPage().getParameters().get('g3');

     boolean gcNoMatch=false;
    
     string gcNo=gasOne+'-'+gasTwo+'-'+gasThre;
     List<Gas_Council__c> gasCounsilList  = [Select name,Message__c from Gas_Council__c where name=:gcNo];
     gasCMsg =null;
     if(gasOne!=null && gasTwo!=null && gasThre!=null)
     {
          system.debug('**3');
       if(gasCounsilList.size()>0){
         for(Gas_Council__c gmap: gasCounsilList ){
             if(gmap.Name==gcNo ){
             system.debug('**4');
             gasCMsg =gmap.Message__c ;
             gcNoMatch=true;
             
             }
         }
       }
     }
     system.debug('**gcNoMatch'+gcNoMatch); 
     system.debug('**gasCMsg'+gasCMsg);
     return null;
     }
     
     public void indicator(){
      system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=-=-=>'+reason+' '+subreason);
      system.debug(LoggingLevel.INFO,''+Opportunities[0].Does_the_customer_have_hot_water__c);
      //Opportunities[0].Latest_customer_category__c = 5;
     
      reason = (reason=='-- NONE --' || reason == '')?null:reason;
      subreason = (subreason=='-- NONE --' || subreason == '')?null:subreason;
      //Opportunities[0].Vulnerable_reason__c = reason;
      //Opportunities[0].Vulnerable_category__c = subreason;
      
      system.debug(LoggingLevel.INFO,'============>heat:'+ApexPages.currentPage().getParameters().get('Heat'));
      system.debug(LoggingLevel.INFO,'============>heat:'+ApexPages.currentPage().getParameters().get('HW'));
      system.debug(LoggingLevel.INFO,'============>heat:'+ApexPages.currentPage().getParameters().get('OH'));
      system.debug(LoggingLevel.INFO,'============>heat:'+ApexPages.currentPage().getParameters().get('vul'));
      //system.debug(LoggingLevel.INFO,'============>res:'+ApexPages.currentPage().getParameters().get('reason'));
      //system.debug(LoggingLevel.INFO,'============>subres:'+ApexPages.currentPage().getParameters().get('subreason'));
      string heat = ApexPages.currentPage().getParameters().get('Heat');
      string hotWater = ApexPages.currentPage().getParameters().get('HW');
      string oHeat = ApexPages.currentPage().getParameters().get('OH');
      if(oHeat!='Yes' && oHeat!='No')
      oHeat='';
      
      string vul = ApexPages.currentPage().getParameters().get('vul');
      system.debug(LoggingLevel.info,'all values:==='+heat+''+hotWater+' '+oHeat+' '+vul+' '+subReason+' '+Reason);
      
      catInd = [select id,name,Reason__c,Sub_Reason__c,Heating__c,Hot_Water__c,Other_Heat__c,Vunerable__c,Category__c,Category_Indicator__c from category_Indicator__c 
                where Customer_Category_Logic__c = :customerCateogryType and Heating__c = :heat and Hot_Water__c = :hotWater and Reason__c = :subreason and  Sub_Reason__c = :reason and Other_Heat__c = :oHeat];
     
      system.debug(logginglevel.info,'return values:----'+catInd);   
         if(catInd.size()>0)
         {
             Opportunities[0].Latest_customer_category__c = catInd[0].Category__c;
             catIndicator = catInd[0].Category_Indicator__c;
             Opportunities[0].Vulnerable_reason__c = reason;
             Opportunities[0].Vulnerable_category__c = subreason;
             
         }else{
            
            catIndicator = '<img src="/resource/1337590708000/Undefined" alt="Undefined" height="25" width="90" border="0"/>';
            Opportunities[0].Latest_customer_category__c = 99;
            
         }
         
         
    
      
      
    }
    
    
    /*public void indicator1(){
      system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=-=-=>'+reason+' '+subreason);
      system.debug(LoggingLevel.INFO,''+Opportunities[0].Does_the_customer_have_hot_water__c);
      //Opportunities[0].Latest_customer_category__c = 5;
     
      reason = (reason=='-- NONE --' || reason == '')?null:reason;
      subreason = (subreason=='-- NONE --' || subreason == '')?null:subreason;
      Opportunities[0].Vulnerable_reason__c = reason;
      Opportunities[0].Vulnerable_category__c = subreason;
    }*/
   
   public map<string,CategoryMap__c> getMcs(){
      return mcs;
    }
    
     public void setMcs(map<string,CategoryMap__c> mcsrec){
        
        mcs = mcsrec;
         
    }
    
    public List<ContactInfo> getConInfoList(){
        return coninfoList;
    }
    
    public void setConInfoList(List<ContactInfo> coninfoListRec){
        
        coninfoList = coninfoListRec;
         
    }
    
    public List<Opportunity> Opportunities{get; set;}   

    public void showSecCon()
    {
       showSecCon = ( showSecCon==true ? false:true);
    }
    
    public void checkCustomerMarketing()
    {
        if(Opportunities[0].Customer_Marketing_Consent__c == 'No')
	     Opportunities[0].Marketing_Preferences__c = '';
        
    }
   public  void AgreeAndAccept(){
        Opportunities[0].Customer_Marketing_Consent__c='Yes';
        populateNumbers();
        
        
        optOutBttnClr='#b3e000';
        boolean atleastone = false;
        String str='';
        for(PicklistWrapper p : piclistValues)
        {
            
            if(!atleastone && p.isselected  )
            {
                atleastone = true;
                
            }
             if((p.label == 'Mobile' && p.isSelected && coninfoList[0].contact.MobilePhone == null) || 
                (p.label == 'Email' && p.isSelected && coninfoList[0].contact.Email__c == null ) ||
                (p.label == 'Phone' && p.isSelected && coninfoList[0].contact.HomePhone == null ) ||
                (p.label == 'Text Message' && p.isSelected && coninfoList[0].contact.MobilePhone == null ) )
             {
                 cchMessage = true;
                 util.seterrormsg(true, 'Marketing preference can only be set where the corresponding contact exists.');
             }
        }
        if(!atleastone)
        {
            cchMessage= true;
            util.seterrormsg(true, 'Please select one marketing prefernce if customer is agreeing to optin.');
        }
       if(atleastone ){
           
            acceptBttnClr='red';
        
           
       }
    }
    
     public  void  OptOut(){
         populateNumbers();
         Opportunities[0].Customer_Marketing_Consent__c='No';
         for(PicklistWrapper p : piclistValues)
         {
             p.isSelected = false;
         }
          optOutBttnClr='red';
         acceptBttnClr='#b3e000';
    }
    
    
    public void populateNumbers()
    {
        if(coninfoList[0].contact.Phone!=null ){
            if(coninfoList[0].contact.Phone.startswith('07')){
                coninfoList[0].contact.MobilePhone = coninfoList[0].contact.Phone;
            }else{
                coninfoList[0].contact.HomePhone = coninfoList[0].contact.Phone;
            }
        }
    }

    
}