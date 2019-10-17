// Controller class for NPS VF pages
// Author : Cognizant 
public without sharing class NPSScoreCardController {
  
  String chiLeadID = System.currentPageReference().getParameters().get('var_OpptyId');
 
  public npsInformation npsInfo{get;set;}
  
  public NPSScoreCardController() {
    
    if(npsInfo == null){
        
        npsInfo = new npsInformation();
        
    }
    
    if(chiLeadID == null){
        
       chiLeadID = System.currentPageReference().getParameters().get('var_OpptyId');
       
    }
    
    if(npsInfo.opp == null && chiLeadID != null){
        npsInfo.opp = [Select id, CHI_Lead_Id__c, (Select id, CHI_Lead_Number__c from NPS__r limit 1) from Opportunity where id = :chiLeadID];
        
        if(npsInfo.opp.NPS__r.size()>0){
            
            npsInfo.nps = npsInfo.opp.NPS__r[0];
            npsInfo.countOfNPS = 1;
            npsInfo.renderSurvey = false;
            
        }else{
            
            npsInfo.nps = new NPS__c();
            npsInfo.countOfNPS = 0;
            npsInfo.renderSurvey = true;
            npsInfo.nps.Opportunity__c = npsInfo.opp.Id;
            npsInfo.chiLeadNumber = npsInfo.opp.CHI_Lead_Id__c;
            
        }
        
        npsInfo.optionsQ1 = new List<SelectOption>();
        npsInfo.optionsQ2 = new List<SelectOption>();
        npsInfo.optionsQ3 = new List<SelectOption>();
        npsInfo.optionsQ4 = new List<SelectOption>();
        npsInfo.optionsQ5 = new List<SelectOption>();
        npsInfo.optionsQ6 = new List<SelectOption>();
        npsInfo.optionsQ7 = new List<SelectOption>();
        addValuesSelectOptions(npsInfo.optionsQ1);
        addValuesSelectOptions(npsInfo.optionsQ2);
        npsInfo.optionsQ3.add(new SelectOption('Yes','Yes'));
        npsInfo.optionsQ3.add(new SelectOption('No','No'));
        npsInfo.optionsQ6.add(new SelectOption('Yes','Yes'));
        npsInfo.optionsQ6.add(new SelectOption('No','No'));
        addValuesSelectOptions(npsInfo.optionsQ4);
        addValuesSelectOptions(npsInfo.optionsQ5);
        addValuesSelectOptions(npsInfo.optionsQ7);
        
    }
    
  }
  
  // Add values in the select options
  
  private void addValuesSelectOptions(List<SelectOption> selectOption){
    
        selectOption.add(new SelectOption('0','0'));
        selectOption.add(new SelectOption('1','1')); 
        selectOption.add(new SelectOption('2','2')); 
        selectOption.add(new SelectOption('3','3')); 
        selectOption.add(new SelectOption('4','4')); 
        selectOption.add(new SelectOption('5','5')); 
        selectOption.add(new SelectOption('6','6')); 
        selectOption.add(new SelectOption('7','7')); 
        selectOption.add(new SelectOption('8','8'));  
        selectOption.add(new SelectOption('9','9')); 
        selectOption.add(new SelectOption('10','10')); 
        
  }
  
  // Submit NPS Form
  
  public PageReference submitNPSForm(){
        
        Pagereference pg;
        
        if(npsInfo.showMessage == null){
            
            npsInfo.showMessage = 0;
            
        }
        
        if(npsInfo.errorMessage == null){
            
            npsInfo.errorMessage = '';
            
        }
        
        try{
        
            if(npsInfo.scoreQ1 != null){
                
                npsInfo.nps.Step1_Score__c = Decimal.valueOf(npsInfo.scoreQ1);
                
            }else if(npsInfo.showMessage != 1){
                
                npsInfo.errorMessage = 'You have not answered question number 1, ';
                
                if(npsInfo.nps.Step1_Comments__c.trim().length() <= 1){
                
                    npsInfo.errorMessage = 'You have not answered question number 1 (and reason for the score), ';
                
                }
                
            }
            
            if(npsInfo.showMessage != 1 && npsInfo.nps.Step1_Comments__c.trim().length() <= 1 && npsInfo.scoreQ1 != null){
                
                npsInfo.errorMessage = 'Please input the reason for score given for first question. ';
                
            }
            
            if(npsInfo.scoreQ2 != null){
                
                npsInfo.nps.Step2_score__c = Decimal.valueOf(npsInfo.scoreQ2);
            
            }else if(npsInfo.showMessage != 1){
                
                if(!npsInfo.errorMessage.contains('You have not answered')){
                    
                    if(npsInfo.errorMessage.contains('Please input the reason for score given for first question')){
                        
                        npsInfo.errorMessage = npsInfo.errorMessage + 'You have not answered question number 2, ';
                            
                    }else{
                        
                        npsInfo.errorMessage = 'You have not answered question number 2, ';
                        
                    }
                    
                }else{
                    
                    npsInfo.errorMessage = npsInfo.errorMessage + '2, ';
                    
                }
                
            }
            
            if(npsInfo.scoreQ3 != null){
                
                npsInfo.nps.Q3_Score__c = npsInfo.scoreQ3;
            
            }else if(npsInfo.showMessage != 1){
                    
                if(!npsInfo.errorMessage.contains('You have not answered')){
                        
                    if(npsInfo.errorMessage.contains('Please input the reason for score given for first question')){
                        
                        npsInfo.errorMessage = npsInfo.errorMessage + 'You have not answered question number 3, ';
                            
                    }else{
                        
                        npsInfo.errorMessage = 'You have not answered question number 3, ';
                        
                    }
                    
                }else{
                    
                    npsInfo.errorMessage = npsInfo.errorMessage + '3, ';
                    
                }
                
            }
            
            if(npsInfo.scoreQ4 != null){
            
                npsInfo.nps.Q4_Score__c = npsInfo.scoreQ4;
                
            }else if(npsInfo.showMessage != 1){
                
                if(!npsInfo.errorMessage.contains('You have not answered')){
                    
                    if(npsInfo.errorMessage.contains('Please input the reason for score given for first question')){
                        
                        npsInfo.errorMessage = npsInfo.errorMessage + 'You have not answered question number 4, ';
                            
                    }else{
                        
                        npsInfo.errorMessage = 'You have not answered question number 4, ';
                        
                    }
                    
                }else{
                    
                    npsInfo.errorMessage = npsInfo.errorMessage + '4, ';
                    
                }
                
            }
            
            if(npsInfo.scoreQ5 != null){
                
                npsInfo.nps.Q5_Score__c = npsInfo.scoreQ5;
            
            }else if(npsInfo.showMessage != 1){
                        
                if(!npsInfo.errorMessage.contains('You have not answered')){
                        
                    if(npsInfo.errorMessage.contains('Please input the reason for score given for first question')){
                        
                        npsInfo.errorMessage = npsInfo.errorMessage + 'You have not answered question number 5, ';
                            
                    }else{
                        
                        npsInfo.errorMessage = 'You have not answered question number 5, ';
                        
                    }
                
                }else{
                    
                    npsInfo.errorMessage = npsInfo.errorMessage + '5, ';
                    
                }
                
            }
            
            if(npsInfo.scoreQ6 != null){
                
             npsInfo.nps.Q6_Score__c = npsInfo.scoreQ6;
            
            }else if(npsInfo.showMessage != 1){
                
            if(!npsInfo.errorMessage.contains('You have not answered')){
                    
                if(npsInfo.errorMessage.contains('Please input the reason for score given for first question')){
                        
                        npsInfo.errorMessage = npsInfo.errorMessage + 'You have not answered question number 6, ';
                            
                }else{
                        
                        npsInfo.errorMessage = 'You have not answered question number 6, ';
                        
                }
                
              }else{
                
                npsInfo.errorMessage = npsInfo.errorMessage + '6, ';
                
              }
            
            }
            
            if(npsInfo.scoreQ7 != null){
                
                npsInfo.nps.Q7_Score__c = npsInfo.scoreQ7;
            
            }else if(npsInfo.showMessage != 1){
                    
                if(!npsInfo.errorMessage.contains('You have not answered')){
                        
                    if(npsInfo.errorMessage.contains('Please input the reason for score given for first question')){
                        
                        npsInfo.errorMessage = npsInfo.errorMessage + 'You have not answered question number 7, ';
                            
                    }else{
                        
                        npsInfo.errorMessage = 'You have not answered question number 7, ';
                        
                    }
                
                }else{
                    
                    npsInfo.errorMessage = npsInfo.errorMessage + '7, ';
                    
                }
                
            }
            
            if(npsInfo.nps.Q8_Score__c!= null && npsInfo.nps.Q8_Score__c.trim().length() >= 1){
                
                // Do Nothing
                
            }else if(npsInfo.showMessage != 1){
                
                if(!npsInfo.errorMessage.contains('You have not answered')){
                    
                    if(npsInfo.errorMessage.contains('Please input the reason for score given for first question')){
                        
                        npsInfo.errorMessage = npsInfo.errorMessage + 'You have not answered question number 8, ';
                            
                    }else{
                        
                        npsInfo.errorMessage = 'You have not answered question number 8, ';
                        
                    }
                
                }else{
                    
                    npsInfo.errorMessage = npsInfo.errorMessage + '8, ';
                    
                }
                
            }
            
            if(npsInfo.errorMessage.trim().length() >= 10 && npsInfo.showMessage != 1){
                
                npsInfo.showMessage = 1;
                npsInfo.errorMessage = npsInfo.errorMessage + 'this is just for your attention, you can go ahead with submitting this survey without answering these questions.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,npsInfo.errorMessage));
                return null;
                
            }
            
            npsInfo.nps.Do_Not_Fire_Validations__c = true;
            npsInfo.nps.Is_Online_NPS_Form__c = true;
            Database.upsert(npsInfo.nps);
            pg = new Pagereference('/apex/NPSThankYouPage');
            pg.setRedirect(true);
            return pg;
        
        }catch(Exception excp){
            
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
            String[] toAddresses1 = new String[] {'pmk.hardy@gmail.com'};                                 
            mail1.setToAddresses(toAddresses1);
            mail1.setSubject('Exception ocurred in submitting NPS form for CHI Lead : '+npsInfo.opp.CHI_Lead_Id__c);
            mail1.setPlainTextBody('Exception ocurred in submitting NPS form for CHI Lead : '+npsInfo.opp.CHI_Lead_Id__c);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });  
            pg = new Pagereference('/apex/NPSErrorPage');
            pg.setRedirect(true);
            return pg;
            
        }
        
       return null; 
        
  }
  
  // Define properties of the NPS related data in this class
    
    public class npsInformation {
          
        public NPS__c nps{get;set;}
        public Opportunity opp{get;set;}
        public Integer countOfNPS;
        public boolean renderSurvey{get;set;}
        public boolean shownValidation{get;set;}
        public String errorMessage{get;set;}
        public Integer showMessage{get;set;}
        public String chiLeadNumber{get;set;}
        public List<SelectOption> optionsQ1{get;set;}
        public List<SelectOption> optionsQ2{get;set;}
        public List<SelectOption> optionsQ3{get;set;}
        public List<SelectOption> optionsQ4{get;set;}
        public List<SelectOption> optionsQ5{get;set;}
        public List<SelectOption> optionsQ6{get;set;}
        public List<SelectOption> optionsQ7{get;set;}
        public String scoreQ1{get;set;}
        public String scoreQ2{get;set;}
        public String scoreQ3{get;set;}
        public String scoreQ4{get;set;}
        public String scoreQ5{get;set;}
        public String scoreQ6{get;set;}
        public String scoreQ7{get;set;}
        
    }
    
}