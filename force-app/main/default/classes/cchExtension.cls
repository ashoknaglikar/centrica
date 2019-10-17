public class cchExtension {
        
        public Opportunity chilead {get;set;}
        
        public boolean  showMessage {get;set;}
        public string acceptBttnClr{get;set;}
        public string optOutBttnClr{get;set;}
        public PicklistWrapper[] piclistValues {get;set;}
        public boolean cchMessage {get;set;}
        ApexPages.StandardController standCont ;
        Utilities util = new Utilities();
        public List<PicklistWrapper> picklistValues{get;set;}
        public string contactid {get;set;}
        
        public cchExtension(ApexPages.StandardController controller)
        {
            showMessage = false;
            standCont = controller;
            
            standCont.addFields(new list<string>{'Customer_Marketing_Consent__c', 'Marketing_Preferences__c'});
            cchMessage=False;
            chilead = (Opportunity)controller.getRecord();
            List<PicklistWrapper> picVal = getPicklistValues();
            picklistValues = picVal;
            contactid = [select id, Account.Primary_Contact__c from Opportunity where id =:chilead.Id ].Account.Primary_Contact__c;
            if(chilead.Customer_Marketing_Consent__c=='Yes')
            {
                acceptBttnClr='red';
                optOutBttnClr='#b3e000';
            }
            else
            {
                acceptBttnClr='#b3e000';
                optOutBttnClr='red';  
                
            }
        }
        public List<PicklistWrapper> getPicklistValues() {
            List<PicklistWrapper> picklistValues=new List<PicklistWrapper>();
            
            picklistValues = new List<PicklistWrapper>();    
            Schema.DescribeFieldResult fieldResult = Opportunity.Marketing_Preferences__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : ple)
            {
                boolean  checkbox =false;
                if(chilead.Marketing_Preferences__c!=null && chilead.Marketing_Preferences__c.contains(f.getValue()))
                    checkbox = true;
                picklistValues.add(new PicklistWrapper(f.getLabel(),f.getValue(), checkbox));
            }       
            
            return picklistValues;
        }
        
        public void  updatePreference()
        {
            showMessage = true;
            if(chilead.Customer_Marketing_Consent__c == 'yes' && chilead.Marketing_Preferences__c != ''){
                AgreeAndAccept();
                cchMessage = true;
                
            }
            else {
                OptOut();
                cchMessage = true;
            }
            standCont.save(); 
            util.seterrormsg(False, 'Sucessfully Updated! Please inform customers that downstream systems will take x hours for these changes to take effect.');
            
        }
        
        public void checkCustomerMarketing()
        {
            if(chilead.Customer_Marketing_Consent__c == 'No')
                chilead.Marketing_Preferences__c = '';
        }
        
        public  void AgreeAndAccept(){
            String str='';
            Boolean atLeastOneSelected=false;
            For(PicklistWrapper wrapper:picklistValues){
                if(wrapper.isSelected==True){
                    str += wrapper.value + ';';
                }
            }
            if(!string.isBlank(str)){
                chilead.Customer_Marketing_Consent__c='Yes';
                chilead.Marketing_Preferences__c=str;
                acceptBttnClr='red';
                optOutBttnClr='#b3e000';
                cchMessage = true;
                util.seterrormsg(False, 'Thanks, you can update your preferences or opt out online or email  generalenquiry@britishgas.co.uk at anytime.For more details on how we use your data, please read our privacy policy online.');
                
            }
            
            
            else
            {
                cchMessage = true;
                acceptBttnClr='#b3e000';
                optOutBttnClr='red';
                util.seterrormsg(True, 'Please select atleast one marketing prefernce if customer is agreeing to optin.');
                
            }
            
            if(chilead.Customer_Marketing_Consent__c!=''){
                update  chilead ;
            }
        }
        
        public  void  OptOut(){
            chilead.Customer_Marketing_Consent__c='No';
            chilead.Marketing_Preferences__c = '';
            update  chilead ;
            optOutBttnClr='red';
            acceptBttnClr='#b3e000';
            cchMessage = true;
            util.seterrormsg(False, 'Is it that you don’t want to hear from us at all?  You can choose to be contacted by any of the following options – mail, mobile, landline, email or text. Do any of these sound ok?');
        } 
        
        
    }