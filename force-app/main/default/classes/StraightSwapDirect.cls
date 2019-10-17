public class StraightSwapDirect {
    
    public CombiSwapQuestion__c ssObj {get;set;}
    
    //public boolean showPi {get;set;}
    
    String retUrl = ApexPages.currentPage().getParameters().get('retURL');
    
    String oppId = ApexPages.currentPage().getParameters().get('oppId');
    
    string ProdInterest = ApexPages.currentPage().getParameters().get('PID');
    boolean newInbound = ApexPages.currentPage().getParameters().get('new')=='true'?true:false;
    
    public Opportunity opp {get;set;}
    
    public string saveBtn{get;set;}
    
    //public integer count{get;set;}
       
    public boolean pid{get;set;}
    boolean saveCnf =false;
   
    public boolean ssd1{get;set;}
    public boolean ssd2{get;set;}    
    public boolean ssd3{get;set;}   
    public boolean ssd4{get;set;}   
    public boolean ssd5{get;set;}   
    public boolean ssd6{get;set;}   
    public boolean ssd7{get;set;}   
    public boolean ssd8{get;set;}   
    public boolean saveExitBtn {get;set;}
    boolean Landlord = false;
   
    utilities util = new utilities();
    
    
    public StraightSwapDirect(Apexpages.standardcontroller stdCtr)
    {
        opp = new Opportunity();
        ssObj =  (CombiSwapQuestion__c)stdCtr.getRecord();
        ssObj.Opportunity__c = oppId;
        
        pid = false;
        saveExitBtn = false;
        //if(ProdInterest == 'SS Direct'){
        //  ProdInterest = 'Straight swap direct';
        //}
        
        //if(ProdInterest!=null)
        ssObj.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('CombiSwapQuestion__c', 'Straight swap direct');
        
        
        system.debug('------>'+ssobj.RecordTypeId);
        opp = [Select id, AccountId, Account.Primary_Contact__c,Product_Interest__c,Contact_Type__c from Opportunity Where id = : oppId];
        
        saveBtn = 'Save & Exit';
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Customer might be eligible for Straight Swap Direct, please complete the following questionnaire to determine the eligibility');
        ApexPages.addMessage(myMsg);
        
        if(opp.Contact_Type__c == 'Tenant' || opp.Contact_Type__c == 'Landlord' || opp.Contact_Type__c == 'Agent'
                 || opp.Contact_Type__c == 'Multi-premise')
        {
         Landlord = true;
        }
           
    }
    
    public pageReference check(){
      //pageReference pageref;
      system.debug(LoggingLevel.INFO,'------>'+ssobj.SSD1__c+ssobj.SSD2__c+ssobj.SSD3__c+ssobj.SSD4__c+ssobj.SSD5__c+ssobj.SSD6__c+ssobj.SSD7__c+ssobj.SSD8__c);
      if(ssObj.SSD1__c == 'Yes')
      {
      ssd1 = true;
      saveExitBtn = false;
      }
      else if(ssObj.SSD1__c != null){
        util.setErrorMsg(true, 'Customer is not eligible for SS Direct. Please Save & Exit to book normal HSA Appointment.');
        saveExitBtn = true;
        return null;
      }
      
      if(ssObj.SSD2__c == 'Yes')
      {
          ssd2 = true;
          saveExitBtn = false;
      }
      else if(ssObj.SSD2__c != null){
        util.setErrorMsg(true, 'Customer is not eligible for SS Direct. Please Save & Exit to book normal HSA Appointment.');
        saveExitBtn = true;
        return null;
      }
      
      if(ssObj.SSD3__c == 'Yes')
      {
        ssd3 = true;
        saveExitBtn = false;
      }
      else if(ssObj.SSD3__c != null){
        util.setErrorMsg(true, 'Customer is not eligible for SS Direct. Please Save & Exit to book normal HSA Appointment.');
        saveExitBtn = true;
        return null;
      }
      
      if(ssObj.SSD4__c == 'Wall')
      {
      ssd4 = true;
      saveExitBtn = false;
      }
      else if(ssObj.SSD4__c != null){
        util.setErrorMsg(true, 'Customer is not eligible for SS Direct. Please Save & Exit to book normal HSA Appointment. ');
        saveExitBtn = true;
        return null;
      }
      
      if(ssObj.SSD5__c == 'Yes')
      {
          ssd5 = true;
          saveExitBtn = false;
      }
      else if(ssObj.SSD5__c != null){
        util.setErrorMsg(true, 'Customer is not eligible for SS Direct. Please Save & Exit to book normal HSA Appointment.');
        saveExitBtn = true;
        return null;
      }
      
      if(ssObj.SSD6__c == 'No')
      {
          ssd6 = true;
          saveExitBtn = false;
      }
      else if(ssObj.SSD6__c != null){
        util.setErrorMsg(true, 'Customer is not eligible for SS Direct. Please Save & Exit to book normal HSA Appointment.');
        saveExitBtn = true;
        return null;
      }
      
      if(ssObj.SSD7__c != 'Roof')
      {
          ssd7 = true;
          saveExitBtn = false;
      }
      else if(ssObj.SSD7__c != null){
        util.setErrorMsg(true, 'Customer is not eligible for SS Direct. Please Save & Exit to book normal HSA Appointment.');
        saveExitBtn = true;
        return null;
      }
      
      if(ssObj.SSD8__c == 'No')
      {
      ssd8 = true;
      saveExitBtn = false;
      }    
      else if(ssObj.SSD8__c != null){
        util.setErrorMsg(true, 'Customer is not eligible for SS Direct. Please Save & Exit to book normal HSA Appointment.');
        saveExitBtn = true;
        return null;
      }
      
      
      
      if(ssObj.SSD1__c!=null && ssObj.SSD2__c!=null && ssObj.SSD3__c!=null && ssObj.SSD4__c!=null && ssObj.SSD5__c!=null && ssObj.SSD6__c!=null && ssObj.SSD7__c!=null && ssObj.SSD8__c!=null){
         if(ssObj.SSD1__c=='Yes' && ssObj.SSD2__c=='Yes' && ssObj.SSD3__c=='Yes' && ssObj.SSD4__c=='Wall' && ssObj.SSD5__c=='Yes' && ssObj.SSD6__c=='No' && ssObj.SSD7__c!='Floor' && ssObj.SSD8__c=='No'){
             util.setErrorMsg(false, 'Customer is eligible for SS direct please reconfirm the Product of Interest.');
             pid=true;
             ssObj.SS_Direct_Eligiblity__c = 'Yes';
             saveExitBtn = true;
             upsert ssObj;
             return null;
         }else{
             util.setErrorMsg(true, 'Customer is not eligible for SS Direct. Please Save & Exit to book normal HSA Appointment.');
             pid=false;
             return null;
             saveExitBtn = true;
          }   
      }
      
      
        
      
          
     
         
      
      
      
      return null;
    }
    
    public pageReference saveExit()
    {
        pageReference returnUrl;
        try{
           boolean tenant = false, Landlord = false;
           system.debug('----------------> Inside of sec2');
           
          
           upsert ssObj;              
           
           
          
          return (exitBtn());  
          
        }catch (Exception e)
        {
            util.setErrorMsg(true, e.getMessage());
            return null;
        }
        
        
    }
    
    
    
    public pagereference confirm()
    {
        upsert ssObj;       
        opp.Product_Interest__c = 'Straight Swap - Direct';
        update Opp;
    
        return (exitBtn());
    
   }
   
   public pagereference exitBtn()
   {
      
       if(Landlord){
                return new pagereference ('/apex/captureLandlordDetails?edit=1&source=IC&chiLeadId='+opp.Id+'&accId='+opp.AccountId+'&new='+newInbound);
            }else 
            {
                return new pageReference('/apex/availability?var_OpptyId='+  
                                oppId+'&var_Source=ICL&view=null&var_date=null&var_contactId='
                                +opp.Account.Primary_Contact__c+'&gDeal=3'+'&new='+newInbound);
            }
                        
        
   }

}