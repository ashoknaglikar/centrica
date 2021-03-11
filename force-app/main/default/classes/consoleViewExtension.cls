// Harry Dhanoa(Westbrook) 1st June 2015
// This class is the controller of the VF page ConsoleView
// It gets all the fields related to the CHI Lead(Opportunity)
// and passes it to the page ConsoleView.
// The CHI Lead Id is a mandatory parameter in the URL 
// ie. https://<sf instance>/apex/ConsoleView?id=<CHI Lead Id>

public class consoleViewExtension {
    Public Opportunity opp{get;set;}
    public String progressBarStatusPicName{get;set;}
    public String latestCustCategoryImgURL{get;set;}
    public List<Note> notes{get;set;}
    public List<Case> cases{get;set;}   
    public Appointment__c salesApp{get;set;}
    public Job__c[] jobsWithDiaryEntry{get;set;}
    public List<String> installers{get;set;}
    public List<String> electricians{get;set;}
    public String daysToIntallation{get;set;}    
    public BigMachines_Quote__c[] bMQWithQuoteProduct{get;set;}
    public String knowledgeSearchString{get;set;} 
    //public List<Opportunity> recentlyViewedList{get;set;} 
    //public List<RecentlyViewed> recentlyViewedList{get;set;} 
    public List<String> numbersBoxList{get;set;}
    public Map<String,Decimal> numbersBoxMap{get;set;}       
    public OpportunityContactRole[] ocrList{get;set;} 
    public list<Contact> contactList{get;set;}
    public String iframeId{get;set;}
    public String NPSScore{get;set;}
    public String homeCare{get;set;} 
    public Boolean hasError{get;set;} 
    public string stageName{get;set;}
    public string colour {get;set;}
    public string QuoteStage{get;set;}
    public string boiler {get;set;}
    public boolean iframe{get;set;}
    public string npsColour{get;set;}
    public Payment_Collection__c paymentCollect{get;set;}
    public boolean otherContacts{get;set;}
    public string jobId {get;set;}               
    public consoleViewExtension(ApexPages.StandardController stdController) {
        iframe = false;
        QuoteStage = 'Quote Issued' ;
        stageName = 'Start';
        Id oppId = ApexPages.currentPage().getParameters().get('id');
        
        //recordId = ApexPages.currentPage().getParameters().get('view');
        if( oppId == null || oppId.getSObjectType().getDescribe().getName() != 'Opportunity') {
            //hasError = true;
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The URL should have the correct Opportunity Id populated. '));
            try{
            oppId = [Select id FROM RecentlyViewed WHERE Type = 'Opportunity' Limit 1].Id;
         
            }Catch (exception e)
            {
                oppId = [Select id from Opportunity limit 1].Id;
            }
            
        }  
        
        try {
            hasError = false;
            notes = new List<Note>();              
            cases = new List<Case>();
            latestCustCategoryImgURL = '';
            Integer callCount=0;
            Integer installAppCount=0;
            Integer salesAppCount=0;
            Integer notesCharacterLimitation = 170;
            Integer caseCommentCharacterLimitation = 150; 
            Integer installerNotesCharacterLimitation = 80;                     
            contactList = new List<Contact>();
            otherContacts = false;
            this.opp = [SELECT  Name, Date_time_appointment_booked__c,Account.Primary_Contact__c, Account.Primary_Contact__r.Salutation,CHI_Lead_Id__c , 
                                Latest_customer_category_indicator__c, Account.Primary_Contact__r.Name, Account.BillingPostalCode, Account.BillingStreet, Account.BillingState,
                                Account.BillingCity,
                                Account.Primary_Contact_Pref_Contact_Method__c,  Number_of_Sales_Appointments__c,
                                Account.Primary_Contact__r.MailingStreet, Account.Primary_Contact__r.MailingCity, 
                                Account.Primary_Contact__r.MailingState, Account.Primary_Contact__r.MailingCountry, 
                                Account.Primary_Contact__r.MailingPostalCode, discountsTotalOnPricing__c,
                                Account.Primary_Contact__r.HomePhone, Account.Primary_Contact__r.MobilePhone, 
                                Account.Primary_Contact__r.Email, Discounted_Amount__c, Sum_of_Deposits__c , Account.Primary_Contact__r.Email__C,
                                Original_Quote_Value__c, Amount, Balance_Outstanding__c, 
                                (SELECT Status__c, Type__c, Assigned_To__r.Name, Start__c, End__c, Appoint_Id_Calc_Installation__c,Broken_Appointment_Details__c 
                                 FROM Appointments__r 
                                 ORDER BY LastModifiedDate DESC),
                                (SELECT stage__c,bmStatusReason__c,finalNetQuoteTotal__c 
                                 FROM BigMachines_Quotes__r ),
                                (SELECT Payment_Type__c 
                                 FROM Payments__r 
                                 WHERE Payment_Type__c = 'Balance Payment'),
                                (SELECT Contact.Primary_Contact__c,Contact.Name,Contact.Contact_Type__c 
                                 FROM OpportunityContactRoles 
                                 ORDER BY Contact.Primary_Contact__c desc 
                                 LIMIT 3),
                                (SELECT Step1_Score__c 
                                 FROM NPS__r 
                                 ORDER BY LastModifiedDate DESC 
                                 LIMIT 1 ),
                                (SELECT Body, CreatedDate FROM Notes ORDER BY LastModifiedDate Desc),
                                (SELECT Name FROM Calls__r),
                                (SELECT Description, Status 
                                 FROM Cases__r 
                                 ORDER BY LastModifiedDate Desc
                                 LIMIT 3),
                                (SELECT Status__c,Mechanical_Installer__c,Installation_Date__c, Install_Street__c,
                                        Install_City__c, Installation_County__c, Install_Postcode__c 
                                 FROM Jobs__r 
                                 //WHERE Status__c = 'Installed' 
                                 ORDER BY Installation_Date__c DESC
                                 LIMIT 1)
    
                       FROM Opportunity 
                       WHERE Id = :oppId ];
    
            contactList = [Select id, Name,Contact_Type__c  from Contact Where AccountId = :opp.AccountId and Primary_Contact__c = false]  ; 
            otherContacts = contactList.size()>0;
            iframeId = opp.Id;//+'?isdtp=vw';
            
            // Loop through the CHI Lead Record to extract 8 stages.
            // Defaulting the stage to home visit booked
            progressBarStatusPicName = '0.png';
            // Stage 1 : Home Visit Booked  
            Boolean homeVisitBooked = false;                
            homeVisitBooked = opp.Date_time_appointment_booked__c!=null? true:false;
            system.debug('homeVisitBooked >>' + homeVisitBooked); 
            //stageNameOnOffMap.put('Home Visit Booked',homeVisitBooked);
            if(homeVisitBooked)
            {
                progressBarStatusPicName = '1.png';  
                stageName = 'salesAppointment';
            }
            
            // Stage 2 : Home Visit Complete                    
            Boolean homeVisitComplete = false;
            for(Appointment__c app : opp.Appointments__r) 
                if(app.Status__c=='Happened') {homeVisitComplete=true; break;}
            system.debug('homeVisitComplete >>' + homeVisitComplete);   
            //stageNameOnOffMap.put('Home Visit Complete',homeVisitComplete);
            if(homeVisitComplete)
            {
                progressBarStatusPicName = '2.png';
                stageName = 'salesAppointment';
            }
                    
            // Stage 3 : Quote Issued               
            Boolean quoteIssued = false;
            for(BigMachines_Quote__c bmq : opp.BigMachines_Quotes__r) 
                if(bmq.stage__c=='Quote Finalised - Not Accepted'){quoteIssued=true;break; }
            system.debug('quoteIssued >>' + quoteIssued);   
            //stageNameOnOffMap.put('Quote Issued',quoteIssued);
            if(quoteIssued)
            {
                progressBarStatusPicName = '3.png';
                QuoteStage = 'Quote Issued';
                stageName = 'quoteAccepted';
            }
                
                    
            // Stage 4 : Quote Accepted                 
            Boolean quoteAccepted = false;
            for(BigMachines_Quote__c bmq : opp.BigMachines_Quotes__r) 
                if(bmq.stage__c=='Quote Finalised - Accepted'){quoteAccepted=true;break; }
            system.debug('quoteAccepted >>' + quoteAccepted);   
            //stageNameOnOffMap.put('Quote Accepted',quoteAccepted);
            if(quoteAccepted)
            {
                progressBarStatusPicName = '4.png';
                stageName = 'quoteAccepted';
                QuoteStage = 'Quote Accepted';
            }
    
            // Stage 5 : Install Arranged                   
            Boolean installArranged = false;
            /*for(BigMachines_Quote__c bmq : opp.BigMachines_Quotes__r) 
                if(bmq.bmStatusReason__c=='Install date given'){installArranged=true;break; }*/
            for(Job__c job : opp.Jobs__r) 
                if(job.Status__c=='Planned'){installArranged=true;break; }    
            system.debug('installArranged >>' + installArranged);   
            //stageNameOnOffMap.put('Install Arranged',installArranged);
            if(installArranged)
            {
                progressBarStatusPicName = '5.png';
                stageName = 'installation';
            }
                    
            // Stage 6 : Install Completed                  
            Boolean installCompleted = false;
            for(Job__c job : opp.Jobs__r) 
                if(job.Status__c=='Installed'){installCompleted=true;break; }
            system.debug('installCompleted >>' + installCompleted); 
            //stageNameOnOffMap.put('Install Completed',installCompleted);
            if(installCompleted)
            {
                progressBarStatusPicName = '6.png';
                stageName = 'paymentCollection';
            }
                                    
            // Stage 7 : Final Payment                  
            Boolean finalPayment = false;
            for(BGS_Payment__c pay : opp.Payments__r) 
                if(pay.Payment_Type__c=='Balance Payment'){finalPayment=true;break; }
            system.debug('finalPayment >>' + finalPayment); 
            //stageNameOnOffMap.put('Final Payment',finalPayment);
            if(finalPayment)
            {
                progressBarStatusPicName = '7.png';
                stageName = 'paymentCollection';
            }
                        
            
            for(NPS__c npc: opp.NPS__r)
            {
                NPSScore=String.valueOf(npc.Step1_Score__c);     
                
                if(npc.Step1_Score__c>=8)
                npsColour = 'Green';
                else if(npc.Step1_Score__c<=8 && npc.Step1_Score__c>=5)
                npsColour = 'yellow';
                else
                npsColour = 'red';
                
                stageName = 'nps';   
                break;      
            }
           
    
            
            //progressBarStatusPicName = '2.png';
            // Trimming the Body of the Notes based Character Limitation set by notesCharacterLimitation
            for(Note n: opp.Notes) {
                if(n.Body != null) {
                    Integer noteSize = n.Body.length()<notesCharacterLimitation? n.Body.length() : notesCharacterLimitation; 
                    n.Body = n.Body.substring(0,noteSize);
                }
                notes.add(n);
            }            
            // Trimming the Comment of the Cases based Character Limitation set by caseCommentCharacterLimitation
            colour = 'Green';
            for(Case c: opp.Cases__r) {
                /*if(c.Description != null) {
                    Integer commentSize = c.Description.length()<caseCommentCharacterLimitation? c.Description.length() : caseCommentCharacterLimitation; 
                    c.Description = c.Description.substring(0,commentSize);
                    
                }*/
                if(c.Status != 'Closed')
                {
                    colour = 'Red';
                    break;
                }
                else
                colour = 'Yellow';
                cases.add(c);
            }
                                                      
            callCount = opp.Calls__r == null? 0:opp.Calls__r.size();  
            
            installAppCount = 0;
            for(Job__c j: [Select (Select Id From Planning_Histories__r) From Job__c where CHI_Lead__c = :opp.Id])
                installAppCount += j.Planning_Histories__r.size();
            
            salesAppCount = opp.Appointments__r == null? 0:opp.Calls__r.size();  
            
            /*numbersBoxList=new List<String>{'Number of Calls', 
                                            'Number of Install App.', 
                                            'Number of Sales App.'};
            numbersBoxMap = new Map<String,Decimal>{'Number of Calls'=>callCount, 
                                                    'Number of Install App.'=>installAppCount , 
                                                    'Number of Sales App.'=>salesAppCount};        */                             
            
            jobsWithDiaryEntry =[SELECT ID, Name, Delivery_Slot__c, Delivery_Date__c,Installation_Date__c, 
                                        Scaffolding_Required__c, DHM_Name__c, DHM_Phone__c,Start_Data_Time__c,
                                        (SELECT Employee_Name__c,Sub_Type__c  
                                          FROM Diary_Entries__r 
                                          WHERE Sub_Type__c='Mechanical' or  Sub_Type__c='Electrical') 
                                  FROM    Job__c j 
                                  WHERE   Is_Remedial_Job__c = false and  
                                          Is_Downtime_Job__c = false and 
                                          CHI_Lead__c = :opp.Id LIMIT 1];
             installers = new List<String>();
             electricians = new List<String>();
             daysToIntallation = 'N/A';
             if(!jobsWithDiaryEntry.isEmpty()) {
                 if(jobsWithDiaryEntry[0].Installation_Date__c!=null)
                 {
                     jobId = jobsWithDiaryEntry[0].Name;
                     daysToIntallation = String.valueOf(date.today().daysBetween(jobsWithDiaryEntry[0].Installation_Date__c)); // PRB00029327
                 }
                 //daysToIntallation = date.today().daysBetween(jobsWithDiaryEntry[0].Installation_Date__c) < 0? 
                   //                      'Happened' : 
                     //                    String.ValueOf(date.today().daysBetween(jobsWithDiaryEntry[0].Installation_Date__c));
                 for(Diary_Entry__c dE : jobsWithDiaryEntry[0].Diary_Entries__r) {
                     if(dE.Sub_Type__c == 'Mechanical')
                         installers.add(dE.Employee_Name__c);
                     else if(dE.Sub_Type__c == 'Electrical')
                         electricians.add(dE.Employee_Name__c);
                 }
                try{
                 paymentCollect = [Select id, Payment_Collection_Status__c from Payment_Collection__c where Job__c =: jobsWithDiaryEntry[0].Id];
                }catch(Exception e){}
                 
             } else {
                Job__c naJob = new Job__c(InstallerName__c ='n/a'); 
                Diary_Entry__c naDE = new Diary_Entry__c(Job__c=naJob.Id);
                jobsWithDiaryEntry.add(naJob);
             
             }
           
           
           
           
             
            for(Appointment__c app : opp.Appointments__r) {
               if(app.Status__c=='Happened' || app.Status__c=='Appointed') {
                   salesApp=app; 
                   //Broken_Appointment_Details__c is updated with the format hh:mm - hh:mm
                   if(salesApp.Start__c != null && salesApp.End__c!= null) {
                       String startTime = salesApp.Start__c.minute()<10?(String.valueOf(salesApp.Start__c.minute())+'0'):String.valueOf(salesApp.Start__c.minute());
                       startTime = salesApp.Start__c.hour()+':'+startTime;
                       String endTime = salesApp.End__c.minute()<10?(String.valueOf(salesApp.End__c.minute())+'0'):String.valueOf(salesApp.End__c.minute());
                       endTime = salesApp.End__c.hour()+':'+endTime;
                       salesApp.Broken_Appointment_Details__c = startTime +' - '+endTime;
                    }
                   break;
                }
            }
            
           list<BigMachines_Quote__c> bMQWithQuoteProductTemp = [SELECT stage__c,bmStatusReason__c, Job_Type_Description__c, POC_Payment_Method__c ,
                                        Installation_Special_Instructions__c,finalNetQuoteTotal__c , Is_Primary__c,
                                        (SELECT Name, Product_Description__c, installationNotes__c,Product__r.Guarantee__c
                                         FROM Quote_Products__r
                                         WHERE (Name LIKE 'CBLR%' or Product__r.Guarantee__c = true ) and
                                               ASP_Status__c != 'Committed - Removed' 
                                         ORDER BY LastModifiedDate DESC
                                         )
                                 FROM BigMachines_Quote__c 
                                 WHERE Opportunity__c = :opp.Id 
                                 /* and Is_Primary__c = true */
                                 ORDER BY CreatedDate DESC
                                 LIMIT 1];
            homeCare = 'No Home care pack present';                     
            bMQWithQuoteProduct = new list<BigMachines_Quote__c>();
            if(!bMQWithQuoteProductTemp.isEmpty()){
                
                for(BigMachines_Quote__c bmq :  bMQWithQuoteProductTemp)
                {
                // Trimming the Installer Notes by installerNotesCharacterLimitation
                for(Quote_Product__c c: bmq.Quote_Products__r) {
                    if(c.installationNotes__c != null) {
                        Integer commentSize = c.installationNotes__c.length()<installerNotesCharacterLimitation? c.installationNotes__c.length() : installerNotesCharacterLimitation; 
                        c.installationNotes__c = c.installationNotes__c.substring(0,commentSize);
                        
                    }   
                    if(c.Name.StartsWith('CBLR'))
                    boiler = c.Product_Description__c;
                    if(c.Product__r.Guarantee__c)
                    homeCare = c.Product_Description__c;
                }  
                if(bmq.Is_Primary__c)
                {
                    bMQWithQuoteProduct.clear();
                    bMQWithQuoteProduct.add(bmq);
                    break;
                }
                bMQWithQuoteProduct.clear();
                bMQWithQuoteProduct.add(bmq);
                
                }                           
            } else {
                BigMachines_Quote__c naBMQ = new BigMachines_Quote__c(stage__c='Not Available',bmStatusReason__c='Not Available',Job_Type_Description__c='Not Available',POC_Payment_Method__c='Not Available'); 
                Quote_Product__c naQP = new Quote_Product__c(Name='Not Available', installationNotes__c='Not Available',BigMachines_Quote__c=naBMQ.Id);
                bMQWithQuoteProduct.add(naBMQ);    
            }
            
            /*
            for(BigMachines_Quote__c bmq: [  SELECT (SELECT Product_Description__c
                                                     FROM Quote_Products__r
                                                     WHERE Product__r.Guarantee__c = true and
                                                           ASP_Status__c != 'Committed - Removed' 
                                                     ORDER BY LastModifiedDate DESC
                                                     LIMIT 1 )
                                             FROM BigMachines_Quote__c 
                                             WHERE Opportunity__c = :opp.Id and
                                                   Is_Primary__c = true 
                                             ORDER BY LastModifiedDate DESC
                                             LIMIT 1]) {
                for(Quote_Product__c qp : bmq.Quote_Products__r) {
                    homeCare = qp.Product_Description__c;    
                }
            }*/
            // Get recently viewed data from DB
            integer limitOpp = 7-(contactList.size()>0?contactList.size()+3:0);
            limitOpp = limitOpp<1?1:limitOpp;
            /*recentlyViewedList = [SELECT Id, Name
                                    FROM RecentlyViewed 
                                    WHERE Type = 'Opportunity'
                                    ORDER BY LastViewedDate DESC 
                                    LIMIT :limitOpp];  */   
                                    
            /*recentlyViewedList = [SELECT Id, Name, CHI_Lead_Id__c, Account.Primary_Contact__r.Name
                                    FROM Opportunity 
                                    WHERE SystemModStamp != NULL 
                                    ORDER BY SystemModStamp DESC
                                    LIMIT 10];      */                                
            
            //Create dummy OCR and add it to List if the count is less than 3
            Integer ocrSize = !opp.OpportunityContactRoles.isEmpty()? opp.OpportunityContactRoles.size():0;
            ocrList = new List<OpportunityContactRole>(opp.OpportunityContactRoles);
            for (Integer i = ocrSize; i < 3; i++) {                              
                ocrList.add(new OpportunityContactRole(OpportunityId=opp.Id));
            }
            
           
            
        } catch (Exception e) {
            hasError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }                                                                                                              
        
    }
            
    //This method navigates the user to the Account related to the CHI Lead
    public Pagereference openAccount() {
        //return new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.AccountId);
        return new Pagereference('/'+opp.AccountId);
    }
    
    //This method navigates the user to the standard CHI Lead page
    public Pagereference openLead() {
        return new Pagereference('/'+opp.Id);
    }

    //This method navigates the user to open a new case
    public Pagereference openNewCase() {
        return new Pagereference('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=%2Fapex%2FNewConsoleview&save_new_url=%2F500%2Fe%3FretURL%3D%252F001w000001MzzJA%26def_account_id%3D'+opp.AccountId+'%26def_account_id%3D'+opp.AccountId+'%26def_contact_id%3D'+opp.Account.Primary_Contact__c+'%26CF00N20000001Xgcp%3D'+opp.name+'%26CF00N200000024cqj%3D'+jobId);
    }
    
    //This method captures the search string and redirects the user to custom VF page
    //This functionality is not deployed in this release. 
    public Pagereference knowledgeSearch() {
        //PageReference ArticleList = Page.ArticleList;
        //ArticleList.setRedirect(true);
        //ArticleList.getParameters().put('searchstring', knowledgeSearchString); 
        //return ArticleList;
        return null;
    }  

    //This is a dummy method called by apex:actionFunction
    public pagereference updateIframeId(){
        /*system.debug('I am Here --------'+iframeId);
        pagereference p = new pagereference('/apex/NewConsoleView?id='+iframeId+'&view='+iframeId);
        return(p);*/
         
        //iframeId = recordId;
        if(iframeId!=null & iframeId.contains('/'))
        {
            iframe = true;
        }else
        iframe = false;
        return null;
    }
    
    public pagereference globalsearch()
    {
        pagereference p ;
        if(knowledgeSearchString!=null)
        {
            knowledgeSearchString= knowledgeSearchString.replaceall(' ', '+');
            p = new pagereference('/_ui/search/ui/UnifiedSearchResults?&str='+knowledgeSearchString);
            
        }else
        {
            return null;
        }
        return p;
    }  
    
    public pagereference openNewTask()
    {
        pagereference p = new pagereference('/setup/ui/recordtypeselect.jsp?ent=Task&retURL=%2F'+this.opp.Id+'&save_new_url=%2F00T%2Fe%3Fwho_id%3D'+userinfo.getuserID()+'%26what_id%3D'+this.opp.ID+'%26retURL%3D%252F'+this.opp.Id);
        
        return p;
        
    }
    
    public Pagereference openNewNote() {
        return new Pagereference('/002/e?parent_id='+string.valueof(opp.Id).substring(0,15)+'&retURL=/apex/NewConsoleView');
    }
    
}