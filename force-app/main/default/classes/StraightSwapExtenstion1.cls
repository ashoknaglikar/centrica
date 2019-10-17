public class StraightSwapExtenstion1 {
    
    public CombiSwapQuestion__c combi{get;set;}
   
    public boolean sec2 {get;set;}
    public boolean sec1 {get;set;}
    public opportunity opp{get;set;}
    public boolean showPi {get;set;}
    
    public boolean combi_bln{get;set;}
    public list<selectoption> questiomaireItems {get;set;}
    public string prdSelected{get;set;}
    
    
    private MessageConstants errorMsg;
    String errMsg;    
    utilities util = new utilities();
    
    
    public StraightSwapExtenstion1()
    {
        questiomaireItems = new list<selectoption>();
        questiomaireItems.add(new selectoption('---None---', ''));
        questiomaireItems.add(new selectoption('Combi', 'Combi'));
        questiomaireItems.add(new selectoption('Conv', 'Conv'));
        errMsg='';
        errorMsg = new MessageConstants();
        opp = new opportunity();
        sec1 = TRUE;
        sec2 = false;
        showPi = false;
        opp.Product_Interest__c='Central Heating Boiler';
        system.debug('-------------------'+questiomaireItems);
        //saveBtn = 'Save & Exit';
    }
    
    public void toggleQuestion()
    {
        if(prdSelected == 'Combi')
        {
            combi_bln = true;
            combi.Type__c = 'Combi';
        }else
        {
            combi_bln = false;
            combi.Type__c = 'Conv';
        }
    }
    
    
    public void lpgAction()
    {   
        system.debug('++++++++++++++++++++');
       
        if(combi.S_S_Q1__c== 'Yes')
        {   
           system.debug('+++++I am in Yes');
            util.setErrorMsg(true, 'LPG Boilers are not eligible for Straight swaps. Please click save & continue to progress with CHB boiler lead and book a HSA visit. ' );
            sec2 = false;
            showPi = true;
            opp.Product_Interest__c = 'Central Heating Boiler';
            
        }else
        {
            system.debug('+++++I am Not in Yes'+combi.S_S_Q1__c);
            sec2 = true;
            showPi = false;
           
        }
    }
    
  
   
}