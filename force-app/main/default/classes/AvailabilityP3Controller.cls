public class AvailabilityP3Controller {

    // IntegratedScript changes
    String bookedDate = System.currentPageReference().getParameters().get('var_date');
    String bookedPeriod = System.currentPageReference().getParameters().get('var_period');
    String bookedApp = System.currentPageReference().getParameters().get('var_bookedAppId');
    String cancelledApp = System.currentPageReference().getParameters().get('var_cancelledAppId');
    String result = System.currentPageReference().getParameters().get('var_result');
    String CHIleadId = System.currentPageReference().getParameters().get('var_OpptyId');
    String source = System.currentPageReference().getParameters().get('var_Source');
    String ffParameters = Utilities.buildParameterString(System.currentPageReference(), null);
    String callID = System.currentPageReference().getParameters().get('var_CallId'); 
    // end IntegratedScript changes
    
    public AvailabilityP3Controller(ApexPages.StandardController  std)
    {
        
    }
    public String getdate() {      
        string datestring = '';
        try {
            datestring = String.Valueof(date.valueOf(bookedDate).day()+'-'+date.valueOf(bookedDate).month()+'-'+date.valueOf(bookedDate).year());
        } catch (Exception exc) {
            datestring = 'N/A';
        }   
        return datestring;
    }
    
    public String getperiod() {       
        return bookedPeriod;
    }
        
    public String getbookedAppId() {       
        return bookedApp;
    }
   
    public String getcancelledApp() {       
        return cancelledApp;
    }
    
    public boolean getshowCancelled1() {
        if(result=='4')
            return true;
        else
            return false;
    }
    
    public boolean getshowCancelled2() {
        if(result=='3' || result=='5')
            return true;
        else
            return false;
    }

    // CR MC014
    public boolean getshowCancelled3() {
        if(result == '7' || result == '8' || result == '9')
            return true;
        else
            return false;
    }    
    
    public boolean getshowCancelled4() {
        if(result == '7')
            return true;
        else
            return false;
    }
    // End CR MC014
    
    public boolean getshowSuccess(){
        // CR MC014 - added additional checks to this if statement
        if(result!='1' && result!='6' && result!='7' && result!='8' && result!='9')
            return true;
        // End CR MC014
        else
            return false;
    }
    
    // IntegratedScript changes
    public boolean getshowButton(){     
        if(source=='SF')
            return true;
        else
            return false;
    }
    // end IntegratedScript changes
    
    public boolean getshowButton2(){
        if(source=='FF' || source == 'IC')
            return true;
        else
            return false;
    }
    
    public boolean getshowFailure1(){       
        if(result=='1' || result=='6')
            return true;
        else
            return false;
    }
    
    public boolean getshowFailure2(){       
        if(result=='1' && cancelledApp=='null')
            return true;
        else
            return false;
    }
    
    public boolean getshowFailure3(){       
        if(result=='1' && cancelledApp!='null')
            return true;
        else
            return false;
    }
    
     public boolean getshowFailure4(){      
        if(result=='6')
            return true;
        else
            return false;
    }
    
    // CR MC014
    public boolean getshowFailure5() {
        if(result=='8' || result=='9')
            return true;
        else
            return false; 
    }
    // End CR MC014
        
  public PageReference onClickReturnCHILead() { 
        PageReference pageRef = new PageReference(''); 
        pageRef = new PageReference('/' + CHIleadId);
        pageRef.setRedirect(true);      
        return pageRef;
  }

    // IntegratedScript changes
    public PageReference onClickReturnFF() { 
        
        PageReference pageRef = new PageReference(''); 
        //pageRef = new PageReference('https://bgschi.sparkstudiosaas.com/webredirect'+ffParameters+'&FIREFLY_NAVIGATION=NEXT');
            //changes made to dispaly finish button for new Call script application
            if(source=='FF')
        {
            pageRef = new PageReference('https://bgschi.sparkstudiosaas.com/webredirect'+ffParameters+'&FIREFLY_NAVIGATION=NEXT');
        }
        else
        {
            pageRef = new PageReference('/apex/WorkflowPage?'+ 'a=1&c='+callID);
        }
        pageRef.setRedirect(true);      
        return pageRef;
    }
    
    public boolean getIsSF() {
        if(source == 'SF')
            return true;
        else
            return false;
    }
    // end IntegratedScript changes
}