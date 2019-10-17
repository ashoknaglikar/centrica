public class StraightSwapExtenstion {
    
    public CombiSwapQuestion__c ssObj {get;set;}
    
    public boolean sec2 {get;set;}
    
    public boolean sec1 {get;set;}
    
    public boolean sec3 {get;set;}
    
    public boolean sec4 {get;set;}
    
    public boolean sec5 {get;set;}
    
    public boolean showPi {get;set;}
    
    String retUrl = ApexPages.currentPage().getParameters().get('retURL');
    
    String oppId = ApexPages.currentPage().getParameters().get('oppId');
    
    string ProdInterest = ApexPages.currentPage().getParameters().get('PID');
    
    public Opportunity opp {get;set;}
    
    public string saveBtn{get;set;}
    
    public integer count{get;set;}
    
    boolean saveCnf =false;
   
        
    utilities util = new utilities();
    
    
    public StraightSwapExtenstion(Apexpages.standardcontroller stdCtr)
    {
        opp = new Opportunity();
        ssObj =  (CombiSwapQuestion__c)stdCtr.getRecord();
        ssObj.Opportunity__c = oppId;
        sec1 = FALSE;
        sec3 = FALSE;
        sec4 = false;
        sec5 = FALSE;
        count = 0;
        if(ProdInterest == 'Straight Swap'){
          ProdInterest = 'Telesales Combi';
        }
        
        if(ProdInterest!=null)
        ssObj.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('CombiSwapQuestion__c', ProdInterest);
        
        if(ProdInterest == 'Telesales Combi')
        sec1 = TRUE;
        else if(ProdInterest == 'Telesales Conventional')
        sec3 = TRUE;
        
        system.debug('------>'+ssobj.RecordTypeId);
        opp = [Select id, AccountId, Account.Primary_Contact__c,Product_Interest__c  from Opportunity Where id = : oppId];
        sec2 = false;
        saveBtn = 'Save & Exit';
    }
    
    public void lpgAction()
    {
        if(ssObj.S_S_Q1__c== 'Yes')
        {
            util.setErrorMsg(true, 'LPG Boilers are not eligible for Straight swaps. Please click save & continue to progress with CHB boiler lead and book a HSA visit. ' );
            sec2 = false;
            showPi = true;
            saveBtn = 'Save & Exit';
            opp.Product_Interest__c = 'Central Heating Boiler';
            
        }else
        {
            sec2 = true;
            showPi = false;
            saveBtn = 'Save & Book Appointment';
        }
    }
    
     public void TelesalesCOnAction()
    {
        if(ssObj.S_S_Q1__c== 'No' && (ssObj.S_S_TC1__c == 'Up to 18KW' || ssObj.S_S_TC1__c == 'Up to 24KW'))
        {
            sec4 = true;
            sec5 = false;
            showPi = false;
            saveBtn = 'Save & Book Appointment'; 
            
        }
        
        if( ssObj.S_S_Q1__c == 'Yes'){
          util.setErrorMsg(true, 'LPG Boilers are not eligible for Straight swaps. ' );
          showPi = false;
          sec5 = false;
          sec4=false;
               
        }
        
        if( ssObj.S_S_TC1__c == 'Greater than 24KW'){
          util.setErrorMsg(true, 'The output range selected is not eligible for Straight swaps.' );
          showPi = false;
          sec4=false;
               
        }
       
        if((ssObj.S_S_Q1__c== 'NO' && ssObj.S_S_TC1__c == 'Greater than 24KW') || (ssObj.S_S_Q1__c== 'Yes' && ssObj.S_S_TC1__c != 'Greater than 24KW') || (ssObj.S_S_Q1__c== 'Yes' && ssObj.S_S_TC1__c == 'Greater than 24KW')){
            util.setErrorMsg(true, 'Please click save & continue to progress with CHB boiler lead and book a HSA visit. ' );
            sec4 = false;
            sec5 = false;
            showPi = true;
            saveBtn = 'Save & Exit';
            opp.Product_Interest__c = 'Central Heating Boiler';
            
        }
    }
    
    public pageReference saveExit()
    {
        pageReference returnUrl;
        try{
          
           system.debug('----------------> Inside of sec2');
                if(!showPi && !saveCnf && sec2 && (ssObj.S_S_Q1__c == null || ssObj.S_S_Q2__c == null ||  ssObj.S_S_Q3__c == null || ssObj.S_S_Q4__c == null || ssObj.S_S_Q6__c == null ||
                 ssObj.S_S_Q7__c == null || ssObj.S_S_Q10__c == null || ssObj.S_S_Q9__c == null || ssObj.S_S_Q11__c == null || ssObj.S_S_Q12__c == null /* || ssObj.S_S_Q13__c == null */ ))
                 {
                    util.setErrorMsg(false, 'Some of the questions are blank. Are you sure you want to continue? If Yes please click Save again.');
                    sec5 = TRUE;
                    saveCnf = true;
                    return null;
                    
                 }
             
             
            
              system.debug('----------------> Inside of sec4');
                 if(!showPi && !saveCnf && sec4 && (ssObj.S_S_Q1__c == null || ssObj.S_S_Q2__c == null ||  ssObj.S_S_Q3__c == null || ssObj.S_S_TC3__c== null || ssObj.S_S_TC4__c== null || ssObj.S_S_TC5__c== null ||
                 ssObj.S_S_Q7__c == null || ssObj.S_S_Q8__c== null || ssObj.S_S_Q6__c== null || ssObj.S_S_Q4__c== null || ssObj.S_S_Q9__c== null || ssObj.S_S_TC6__c== null || ssObj.S_S_TC7__c== null || ssObj.S_S_TC8__c== null ||
                 ssObj.S_S_TC9__c== null || ssObj.S_S_TC10__c== null || ssObj.S_S_Q12__c== null || ssObj.S_S_TC11__c== null || ssObj.S_S_Q14__c== null))
                 {
                    util.setErrorMsg(false, 'Some of the questions are blank. Are you sure you want to continue? If Yes please click Save again.');
                    sec5 = TRUE;
                    saveCnf = true;
                    return null;
                    
                 }
           
            if(showPi)
            {
                if(opp.Product_Interest__c == 'Telesales Combi' || opp.Product_Interest__c == 'Telesales Conventional')
                {
                    util.setErrorMsg(false, 'Please change the Product Interest to any thing other than Straight Swap. As this Lead is not eligible for this offer anymore.');
                    return null;
                    
                }else
                {
                    update opp;
                    returnUrl =  new pagereference ('/apex/Wrapupscreenpage?chiLeadId='+opp.Id+'&accId='+opp.AccountId);
                }
            }else{
                returnUrl =  new pageReference('/apex/availability?var_OpptyId='+  
                        ssObj.Opportunity__c+'&var_Source=ICL&view=null&var_date=null&var_contactId='
                        +opp.Account.Primary_Contact__c+'&gDeal=3');
                    
            }        
            upsert ssObj;        
            return returnUrl;
        }catch (Exception e)
        {
            util.setErrorMsg(true, e.getMessage());
            return null;
        }
        
        
    }
    
    public pagereference exitBtn()
    {
        return ( new pagereference ('/apex/Wrapupscreenpage?chiLeadId='+opp.Id+'&accId='+opp.AccountId));
    }

}