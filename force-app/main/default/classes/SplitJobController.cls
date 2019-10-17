public with sharing class SplitJobController {

    public Opportunity objOpp = new Opportunity();
    public List<Job_Element__c> jobElementList = new List<Job_Element__c>();
    private List<Job_ELement__c> toBedeletedJEList = new List<Job_ELement__c>();
    private Map<String,Map<String,Integer>> map1 = new Map<String,Map<String,Integer>>();
    private Map<String,Map<String,Integer>> map2 = new Map<String,Map<String,Integer>>();
    private Map<String,List<Quote_Product__c>> map3 = new Map<String,List<Quote_Product__c>>();
    private Map<String,Map<String,Decimal>> map4 = new Map<String,Map<String,Decimal>>();
    private Map<String,List<Job_Element__c>> map5 = new Map<String,List<Job_Element__c>>();
    private MAp<String,Job_Element__c> jeObjMAp = new Map<String,Job_Element__c>();
    public List<packDetails> pckDetList = new List<packDetails>();
    public String errorMsg = '';
    public String s_jobId = '';
    private String jeJobId = '';
    public Boolean bCheckPlatform{get; set;}
    // Skill Map change 
    public Map<String,calcHours> skillmap = new Map<String,calcHours>();
    List<String> basicSkillList = new List<String> {'Mechanical' ,'Building Work','Powerflush', 'Electrical' , 'ECO'};
    Set<String> basicSkillSet = new Set<String> ();
    public List<calcHours> hourList {get; set;}
    public double totalHours {get; set;}
    // Code fix by BGSAMSsupport for  PRB00007089 starts
    List<Job_Element__c> jeListSelected = new List<Job_Element__c>();
    // Code fix by BGSAMSsupport for  PRB00007089 ends
    // Cognizant - CHI Phase III CR-002 implementation... START 
    
    public AddNewSkill ObjNewSkill = new AddNewSkill();
    
    // Cognizant - CHI Phase III CR-002 implementation... END
    
    public Opportunity getobjOpp(){
        return this.objOpp;
    }
    public List<packDetails> getPckDetList(){
       if(pckDetList.size() > 0)
           return pckDetList;   
       else
           return null;
   }
    
    public String getErrorMsg(){
        return this.errorMsg;
    }
    public void setErrorMsg(String val){
        if(val != null && val != ''){
            errorMsg = val;
        }
    }
    
    public void sets_jobId(String val){     
        if(val != null && val != ''){
            s_jobId = val;
        }
        System.debug('s_job id =  '+s_jobId);
    }
    public String gets_jobId(){
        return this.s_jobId;
    }
    public void setJeJobId(String val){
        if(val != '' && val != null){
            this.jeJobId = val;
        }
        System.debug('# JOB ID FOR WHICH ELEMENTS WERE FETCHED ... #    '+jeJobId);
    }
    public String getJeJobId(){
        return this.jeJobId;
    }
    
    
    public SplitJobController(){
        
        bCheckPlatform = false;
        String oppId = System.currentpagereference().getparameters().get('oppId');
        this.objOpp = [Select Name, Platform__c,Amount_Settled__c,o.StageName, o.Payment_Reference_Number__c, o.Amount, o.Account.Primary_Contact_Last_Name__c, 
                       o.Account.Primary_Contact_First_Name__c, o.Account.Primary_Contact_Salutation__c, o.Account.BillingCountry, o.Account.BillingPostalCode, 
                       o.Account.BillingState, o.Account.BillingCity, o.Account.BillingStreet, o.Account.Name, o.AccountId, (Select id,Name, Customer_Name__c, 
                       Delivery_Date__c, Delivery_Notes__c, District__r.Name, Installation_Date__c, Installation_Special_Instructions__c, Installer_Notes__c, Quote__r.Name,
                       Status__c, Total_Job_Hours__c, Type__c, Job_Notes__c,Split_Job__c From Jobs__r where Status__c not in ('Installed','Cancelled','Suspended')) From Opportunity o where id =: oppId];
        System.debug('-inside default constructor of SplitJobController objOpp  -----'+objOpp);
        if(objOpp.Platform__c == 'Premier')
          bCheckPlatform = true;
               
    }
    public List<Job__c> getJobDetails(){  
        System.debug('-inside getJobDetails of SplitJobControllerobjOpp.Jobs__r -----'+objOpp.Jobs__r);    
        if((objOpp.Jobs__r).size() > 0){
            this.setErrorMsg('');
            return objOpp.Jobs__r; 
        }
        else{
            this.setErrorMsg('There is no valid job to split.');
            return null;
        }
    }
    
    public PageReference actnFetchElements(){
        
        
        System.debug('Calling Action fetch Elements ... : ' + s_jobId);
        
        if(s_jobId == null || s_jobId == ''){
            this.setErrorMsg('Please select a Job to fetch relevant packs from it.');
            return null;
        }
        
        
        Set<String> partnumSet = new Set<String>();
        List<Quote_product__c> quoteProdList = new List<Quote_product__c>();
       
        String QuoteId='';
        
        pckDetList.clear();
        map1.clear();
        map2.clear();
        map3.clear();
        map4.clear();
        map5.clear();
        jobElementList.clear();
        jeObjMAp.clear();
        if(!(pckDetList.isEmpty())){
            pckDetList.clear();
        }
        
        //PRB00029789 - added j.Line_Item_ID__c
        
        jobElementList = [Select j.UnitsFormula__c, j.Line_Item_ID__c, j.Unit_Price__c, j.Type__c, j.Supplier_Order_Number__c, j.Sub_Status__c, j.Status__c, j.Skill__c, j.Remove_Waste__c, j.Product__c, j.Product_ID__c, j.Premier_Updated__c, j.Planned__c, j.P5_IsItinerary__c, j.Is_Vanstock__c, j.Do_Not_Assign_Order__c, j.Description__c, j.Code__c,Job__c,Job__r.Quote__c,Units__c,order__c       
              From Job_Element__c j where job__c =:s_jobId and status__c not in ('Cancelled','Removed') order by Type__c asc];
        System.debug('Job element size : '+jobElementList.size());
        System.debug('Job element  : ' +jobElementList);
               
        if(jobElementList.size() > 0){
            this.setErrorMsg('');
            
            for(Job_Element__c je : jobElementList)
                jeObjMAp.put(je.id,je);
            
            
            totalHours=0;
            hourList = new List<calcHours>();
            skillmap = new Map<String,calcHours>();
            basicSkillSet.addAll(basicSkillList);
            for(Job_Element__c je: jobElementList){
                partnumSet.add(je.Product_ID__c);
                calcHours hour = new calcHours();
                hour.skill = je.Skill__c;
                //hour.hours = je.jE.Units__c;
                if(je.Skill__c!=null)
                skillmap.put(je.Skill__c , hour);
                
                if(QuoteId == '')
                    QuoteId = je.Job__r.Quote__c;
            }
            hourList = sortSkills(skillmap);
            
            List<Product_Work_code__c> workcodeList = [Select p.Hours__c,Product_Code__c From Product_Work_Code__c p where product_code__c in :partnumSet and start_date__c <= :System.today() and end_date__c>=:System.today() ];
            
            List<Product_Materials__c> productMaterials = [Select Quantity__c, Product_Code__c From Product_Materials__c where Product_Code__c in :partnumSet AND (Start_Date__c <= :date.today() AND End_Date__c >= :date.today()) AND (Active__c = True)];
            // ###################################################     ADDING TO MAP 1    ############################################
            System.debug('workcodeList  : ' +workcodeList);
            System.debug('productMaterials : ' +productMaterials);
            Map<String,Integer> workCode = new Map<String,Integer>();
            Map<String,Integer> materialCode = new Map<String,Integer>();
            Integer cnt =0;
            for(Product_Work_code__c work : workcodeList){              
                if(workCode.containsKey(work.Product_Code__c)){
                    cnt = workCode.get(work.Product_Code__c);
                    cnt++;
                    workCode.put(work.Product_Code__c,cnt);
                }else{                  
                    workCode.put(work.Product_Code__c,1);
                }
            }
            cnt =0;
            for(Product_Materials__c material : productMaterials){              
                if(materialCode.containsKey(material.Product_Code__c)){
                    cnt = materialCode.get(material.Product_Code__c);
                    cnt++;
                    materialCode.put(material.Product_Code__c,cnt);
                }else{                  
                    materialCode.put(material.Product_Code__c,1);
                }
            }
            for(String part : partnumSet){
                Map<String,Integer> tempMap = new Map<String,Integer>();
                if(workCode.containsKey(part)){
                    tempMap.put('Work',workCode.get(part));
                     System.debug('#  tempMap if' + tempMap);
                }else{
                    tempMap.put('Work',0);
                }
                if(materialCode.containsKey(part)){
                    tempMap.put('Material',materialCode.get(part));
                    System.debug('#  tempMap else' + tempMap);
                }else{
                    tempMap.put('Material',0);
                }
                map1.put(part,tempMap);
                System.debug('#  map1' + map1);
            }
            System.debug('#  CHECKPOST 1 : MAP 1' + map1);
            
            // ###################################################     ADDING TO MAP 2    ############################################            
            for(String part : partnumSet){
                Integer workItems =0;
                Integer matItems = 0;
                Decimal Hours = 0;
                Map<string,Decimal> WorkHours = new Map<string,Decimal>();
                Map<string,Decimal> MaterialHours = new Map<string,Decimal>();
                List<Job_Element__c> jeList = new List<Job_Element__c>();
                for(Job_Element__c je: jobElementList){
                    if(je.Type__c == 'Work' && (je.Product_ID__c == part)){                     
                        workItems++;
                        //Added By Ashok G--WP9346
                        jeList.add(je);
                        if(WorkHours .containskey(part)){
                        system.debug('Inside map4'+part);
                          if(je.Units__c==null){
                            WorkHours .put(part,WorkHours.get(part));
                          }else{
                            Decimal WHours = je.Units__c+WorkHours.get(part);
                            WorkHours.put(part,WHours);                            
                          }
                        }else{
                          if(je.Units__c==Null)
                          WorkHours.put(part,Hours);
                          else{
                          system.debug('First call'+part);
                          WorkHours.put(part,je.Units__c);
                          }
                        }
                        //END
                    }
                    if(je.Type__c == 'Material' && (je.Product_ID__c == part)){                     
                        matItems++;
                        //Added By Ashok G -- WP9346
                        if(MaterialHours.containskey(part)){
                        system.debug('SECOND CALL'+part);
                          if(je.Units__c==null){
                           MaterialHours.put(part,MaterialHours.get(part));
                          }else{
                             Decimal WHours = je.Units__c+MaterialHours.get(part);
                             MaterialHours.put(part,WHours);                            
                            
                          }
                        }else{
                          if(je.Units__c==Null)
                          MaterialHours.put(part,Hours);
                          else{
                          system.debug('FIRST MATERIAL CALL'+part);
                          MaterialHours.put(part,je.Units__c);
                          
                          }
                        }
                        //END
                    }
                }
                //Change By Ashok G
                Map<String,Decimal> tempMap = new Map<String,Decimal>();
                if(workHours.containsKey(part)){
                    tempMap.put('Work',workHours.get(part));
                     System.debug('#  tempMap if' + tempMap);
                }else{
                    tempMap.put('Work',0);
                }
                if(materialHours.containsKey(part)){
                    tempMap.put('Material',materialHours.get(part));
                    System.debug('#  tempMap else' + tempMap);
                }else{
                    tempMap.put('Material',0);
                }
                map4.put(part,tempMap);
                map5.put(part,jeList);
                //END
                if(matItems > 0 || workItems > 0){
                    Map<String,Integer> tempList = new Map<String,Integer>();
                    if(workItems > 0 && matItems > 0){                      
                        tempList.put('Work',workItems);
                        tempList.put('Material',matItems);
                        map2.put(part,tempList);
                       
                    }else if(workItems > 0 && matItems == 0){
                        tempList.put('Work',workItems);
                        tempList.put('Material',0);
                        map2.put(part,tempList);
                      
                    }else if(workItems == 0 && matItems > 0){
                        tempList.put('Work',0);
                        tempList.put('Material',matItems);
                        map2.put(part,tempList);
                    }
                }
            }
            System.debug('#  CHECKPOST 2 : MAP 2' + map2);
            System.debug('#  CHECKPOST 4 : MAP 4' + map4); 
            System.debug('#  CHECKPOST 4 : MAP 5' + map5); 
            // ###################################################     ADDING TO MAP 3    ############################################
            quoteProdList = [Select Name,id,q.Sales_Price__c, q.Quantity__c, q.Product_Description__c, q.Part_Number__c,q.ASP__r.Name, q.ASP__c From Quote_Product__c q where BigMachines_Quote__c=:QuoteId and Part_Number__c  in :partnumSet];
            for(String part : partnumSet){
                List<Quote_product__c> packs = new List<Quote_product__c>();
                for(Quote_Product__c qp : quoteProdList){
                    if(qp.Part_Number__c == part){
                        packs.add(qp);
                    }   
                }
                if(packs.size() > 0)
                    map3.put(part,packs);
            }
            System.debug('#  CHECKPOST 3 : MAP 3' + map3);
            // #################################################    END :     ADDING TO MAP 1/2/3    #################################
            for(String map1Key : map1.keySet()){
                Integer workItmCount = (map1.get(map1Key)).get('Work') ;
                Integer materialItmCount = (map1.get(map1Key)).get('Material') ;
                Integer workJeCount = (map2.get(map1Key)).get('Work');
                Integer materialJeCount = (map2.get(map1Key)).get('Material');
                Decimal WHours = (map4.get(map1key)).get('Work'); //Added By Ashok G
                Decimal MHours = (map4.get(map1key)).get('Material'); //Added By Ashok G
                List<Job_Element__c> JEWList = map5.get(map1key);
                List<Quote_Product__c> packList = map3.get(map1Key);    
                Integer workqty = 0;
                Integer materialqty = 0;
                for(Quote_Product__c pack : packList){
                    Integer qty = (pack.Quantity__c).intValue();
                    workqty =  (qty*workItmCount);
                    materialqty = (qty*materialItmCount); 
                    if(workQty > 0 && materialQty > 0){
                        if(workQty == workJeCount && workJeCount > 0 && materialJeCount > 0 && materialQty == materialJeCount){
                            packDetails pckDetObj = new packDetails(JEWList);
                            pckDetObj.packElement  = pack;
                            pckDetObj.Hours = WHours; //Added By Ashok G
                            pckDetList.add(pckDetObj);
                            workJeCount -=workQty;
                            materialJeCount -=materialQty;
                            break;
                        }else if(workQty < workJeCount || materialQty < materialJeCount){
                            packDetails pckDetObj = new packDetails(JEWList);
                            pckDetObj.packElement  = pack;
                            pckDetObj.Hours = WHours; //Added By Ashok G
                            pckDetList.add(pckDetObj);
                            workJeCount -=workQty;
                            materialJeCount -=materialQty;
                            //break;
                        }else if (workJeCount == 0){
                            if(materialQty == materialJeCount){
                                packDetails pckDetObj = new packDetails(JEWList);
                                pckDetObj.packElement  = pack;
                                pckDetObj.Hours = MHours; //Added By Ashok G
                                pckDetList.add(pckDetObj);
                                materialJeCount -=materialQty;
                                break;
                            }else if(materialQty < materialJeCount){
                                packDetails pckDetObj = new packDetails(JEWList);
                                pckDetObj.packElement  = pack;
                                pckDetObj.Hours = MHours; //Added By Ashok G
                                pckDetList.add(pckDetObj);
                                materialJeCount -=materialQty;
                            }
                        }else if (materialJeCount == 0 ){
                            if(workQty == workJeCount){
                                packDetails pckDetObj = new packDetails(JEWList);
                                pckDetObj.packElement  = pack;
                                pckDetObj.Hours = WHours; //Added By Ashok G
                                pckDetList.add(pckDetObj);
                                workJeCount -=workQty;
                                break;
                            }else if(workQty < workJeCount){
                                packDetails pckDetObj = new packDetails(JEWList);
                                pckDetObj.packElement  = pack;
                                pckDetObj.Hours = WHours; //Added By Ashok G
                                pckDetList.add(pckDetObj);
                                workJeCount -=workQty;
                            }
                        }
                    }else if(workQty > 0 && materialQty == 0){
                        if(workQty == workJeCount){
                            packDetails pckDetObj = new packDetails(JEWList);
                            pckDetObj.packElement  = pack;
                            pckDetObj.Hours = WHours; //Added By Ashok G
                            pckDetList.add(pckDetObj);
                            workJeCount -=workQty;
                            break;
                        }else if(workQty < workJeCount){                            
                            packDetails pckDetObj = new packDetails(JEWList);
                            pckDetObj.packElement  = pack;
                            pckDetObj.Hours = WHours; //Added By Ashok G
                            pckDetList.add(pckDetObj);
                            workJeCount -=workQty;
                            
                        }
                    }else if(workQty == 0 && materialQty > 0){
                        if( materialQty == materialJeCount){
                            packDetails pckDetObj = new packDetails(JEWList);
                            pckDetObj.packElement  = pack;
                            //pckDetObj.Hours = MHours; //Added By Ashok G
                            pckDetList.add(pckDetObj);
                            materialJeCount -=materialQty;
                            break;
                        }else if(materialQty < materialJeCount){                            
                            packDetails pckDetObj = new packDetails(JEWList);
                            pckDetObj.packElement  = pack;
                            //pckDetObj.Hours = MHours; //Added By Ashok G
                            pckDetList.add(pckDetObj);
                            materialJeCount -=materialQty;
                            //break;
                        }
                    }
                }
            }
            this.setJeJobId(s_jobId);    
        }else{
            this.setErrorMsg('No Relevant Job Elements Retrieved for this Job');
        }
        return null;
    }
    public Pagereference actnCloneJOb(){
        String postCodeSector = (objOpp.Account.BillingPostalCode).substring(0,(objOpp.Account.BillingPostalCode).length()-2);  
        Postcode_Sector__c postCodeSecObj = [Select Sub_Patch__r.District__c From Postcode_Sector__c where name =:postCodeSector and type__c = 'Installation'];
        BigMachines_Quote__c triggerQuote = [select id,deliveryNotes__c,bmStatusReason__c,App_Assigned_To__c,Installation_Special_Instructions__c,Opportunity__c from BigMachines_Quote__c where Opportunity__c =:objOpp.id and Is_Primary__c=true];                                                
        Job__c newQuoteJob = new Job__c(Quote__c=triggerQuote.Id,
                                        Delivery_Notes__c=triggerQuote.deliveryNotes__c,
                                        Installation_Special_Instructions__c = triggerQuote.Installation_Special_Instructions__c,
                                        District__c=postCodeSecObj.Sub_Patch__r.District__c,
                                        CHI_Lead__c=triggerQuote.Opportunity__c,
                                        Type__c = 'Central Heating Installation',
                                        Status__c = 'Pending',
                                        Quote_app_assigned_to__c = triggerQuote.App_Assigned_To__c);
                           
        boolean bmStatusReasonNotBlank = false;
        if(triggerQuote.bmStatusReason__c!=null){
            if(triggerQuote.bmStatusReason__c.length()>0)
                bmStatusReasonNotBlank = true;                          
        }
        if(bmStatusReasonNotBlank)
            newQuoteJob.Sub_Status__c=triggerQuote.bmStatusReason__c;
        else{
            newQuoteJob.Sub_Status__c='Awaiting Planning';
        }
       try{
           insert newQuoteJob;
       }catch(DMLException e){
           System.debug('exception '+e);
       }
       return null;
   }
    
    public Pagereference SplitJOB(){
        System.debug('##  MOVE FROM JOB : '+jeJobId+ '  @ TO JOB @  '+s_jobId);
        if(jeJobId == s_jobId){
            //this.setErrorMsg('Error : The source and destination jobs cannot be same.');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error : The source and destination jobs cannot be same.');
            ApexPages.addMessage(myMsg); 
            return null;
        }
        List<Quote_Product__c> qpList = new List<Quote_Product__c>();
        for(packDetails pck : pckDetList){
            if(pck.b_IsElementSelected != null && pck.b_IsElementSelected){
                qpList.add(pck.packElement);
            }
        }
        System.debug('-------qpList()----------' +qpList); 
        try{
            toBedeletedJEList = this.filterJobElements(qpList);               
            if(toBedeletedJEList.size() > 0){
                try{ 
                    String str2 =  this.createDeleteJObElemnts();
                    if(str2 == 'success'){
                        List<String> jobs = new List<String>{jeJobId,s_jobId};
                        Map<String,boolean> jMap = new Map<String,boolean>();
                        jMap.put(jeJobId,true);
                        jMap.put(s_jobId,false);
                        List<Job__c>  jobsLst = this.updateJob(qpList,jobs,jMap);
                        try{
                            update jobsLst ;
                            // Added on : 2nd July : UAT request : parent job when replanning would not return original instal date
                            //this.deleteDiaries(delJobid);
                           jobBookingManager.suspendJob(jeJobId);
                            
                        }catch(Exception e){
                            System.debug('exception  --'+e);
                        }
                    }
                }catch(Exception e){
                    System.debug('exception  --'+e.getMessage());
                }
            }
        }catch(Exception e){
            System.debug('exception  --'+e.getMessage());
        }
        return new pageReference('/apex/SplitJob?oppId='+objOpp.id+'&orgJobId='+jeJobId);
    }
    private List<Job_Element__c> filterJobELements(List<Quote_Product__c> quoteProdList){
        Map<String,Integer> PartqtyMap = new Map<String,Integer>();
           for(Quote_Product__c qProd1 : quoteProdList){
                
                 if(PartqtyMap.containsKey(qProd1.part_Number__c)){
                    Integer cnt=PartqtyMap.get(qProd1.part_Number__c);
                    cnt++;
                    PartqtyMap.put(qProd1.part_Number__c,cnt);
                        System.debug('PartqtyMap value'+PartqtyMap);
                 }
            else{
            PartqtyMap.put(qProd1.part_Number__c,1);
                System.debug('PartqtyMap value'+PartqtyMap);
            }
            System.debug('PartqtyMap value'+PartqtyMap);
            }
        for(Quote_Product__c qProd : quoteProdList){
            System.debug('quoteProdList  '+quoteProdList + 'size:' +quoteProdList.size());
            Integer workCnt = ((qProd.Quantity__c)*((map1.get(qProd.part_Number__c)).get('Work'))*(PartqtyMap.get(qProd.part_Number__c))).intValue();
            Integer materialCnt = ((qProd.Quantity__c)*((map1.get(qProd.part_Number__c)).get('Material'))*(PartqtyMap.get(qProd.part_Number__c))).intValue();
            Integer innerWorkCnt = map2.get(qProd.part_Number__c).get('Work');
            Integer innerMaterialCnt = map2.get(qProd.part_Number__c).get('Material');
            System.debug('wrkCnt = '+workCnt+' matCnt '+materialCnt+ ' innerWCnt '+innerWorkCnt+'  innerMatCnt '+innerMaterialCnt);
            // Code fix by BGSAMSsupport for  PRB00007625 starts  
            Boolean duplicate = false;
            Boolean duplicatemat = false;
            for(Job_Element__c je : jeObjMAp.values()){
                System.debug('Looping JE :  '+je);
                if((je.Type__c).equalsIgnoreCase('Work') && je.product_id__c == qProd.part_Number__c){
                    if(workCnt > 0 && workCnt <= innerWorkCnt){
                        for(Job_Element__c je1 : toBedeletedJEList)
                        {
                        if(je1.id == je.id)
                        {
                        duplicate = true;
                        System.debug('Duplicate  value' + duplicate);   
                        break;                  
                        }
                        }
                        if(duplicate)
                        {
                         continue;
                        }
                        System.debug('Looping JE reducing work count:  '+workCnt + ' :  '+innerWorkCnt);
                        toBedeletedJEList.add(je);
                        workCnt --;
                        System.debug('workCnt :  '+workCnt);
                    }                   
                }
                if((je.Type__c).equalsIgnoreCase('Material') && je.product_id__c == qProd.part_Number__c){
                    if(materialCnt > 0 && materialCnt <= innerMaterialCnt){
                        for(Job_Element__c jemat : toBedeletedJEList)
                        {
                        if(jemat.id == je.id)
                        {
                        duplicatemat = true;
                        System.debug('Duplicate  value' + duplicatemat);   
                        break;                  
                        }
                        }
                        if(duplicatemat)
                        {
                         continue;
                        }
                        // Code fix by BGSAMSsupport for  PRB00007625 ends   
                        System.debug('Looping JE reducing material count:  '+materialCnt + ' :  '+innerMaterialCnt);
                        toBedeletedJEList.add(je);
                        materialCnt --;
                        System.debug('materialCnt :  '+materialCnt);
                    }                   
                }
            }
            System.debug('@ List to be cloned & deleted : @'+toBedeletedJEList);
        }
        System.debug('@ List  toBedeletedJEList : @'+toBedeletedJEList);
        return toBedeletedJEList;
    }
    private String createDeleteJObElemnts(){
        List<Job_Element__c> tempJeList = new List<Job_Element__c>();
        Set<String> jeOrderIds = new Set<String>();
        Set<String> jeCodeIds = new Set<String>();
        
        for(Job_Element__c je : toBedeletedJEList){
            Job_Element__c tempJobElement = je.clone(false);
            tempJobElement.Status__c = 'Active';
            tempJobElement.Sub_Status__c = 'Awaiting Order';
            tempJobElement.Order__c =null;
            tempJeList.add(tempJobElement);
            jeOrderIds.add(je.Order__c);
            jeCodeIds.add(je.Code__c);
        }

        try{
            // Added for Order Management
            List<Order_Line_item__c> ordLines = [select id,P5_Sub_Status_c__c,p5_status_c__c from Order_line_item__c where 
                        P5_Purchase_Order__c in : jeOrderIds and code__c in : jeCodeIds];
            if(ordLines.size() > 0){
                for(Order_Line_Item__c oli : ordLines){
                    oli.p5_status_c__c = 'Cancelled';
                    oli.P5_Sub_Status_c__c = 'Element Splitted';
                }
                try{
                    update ordLines;
                }catch(Exception e){
                    System.debug('Exception e '+e.getMessage());
                }
            }
            delete toBedeletedJEList;
        }catch(Exception e){
            System.debug('Exception e '+e.getMessage());
            return 'Error : '+e.getMessage();
        }
        try{
            for(Job_Element__c je : tempJeList){
                je.Job__c = s_jobId;
            }
            System.debug('---- copied --- '+tempJeList.size() +'  :  '+tempJeList);
        
            insert tempJeList;
            // Code fix by BGSAMSsupport for  PRB00007089 starts
            jeListSelected = tempJeList.clone();
            System.debug('---- jeListSelected------' +jeListSelected);
            // Code fix by BGSAMSsupport for  PRB00007089 ends
            return 'success';
        }catch(Exception e){
            System.debug('Exception e '+e.getMessage());
            return 'Error : '+e.getMessage();
        }
    }
    private List<Job__c> updateJob(List<Quote_Product__c> qpList,List<String> jobL,Map<String,boolean> jobBMap){
        
        Integer posNeg=1;
        Map<String,String> pwMap =  new Map<String,String>();
        Map<String,Integer> qtyMap = new Map<String,Integer>();
                
        
       for(Quote_Product__c qp : qpList){               
            if(qtyMap.containsKey(qp.part_number__c)){
                Integer qty = qtyMap.get(qp.part_number__c);
                qty=qty+(qp.Quantity__c).intValue(); 
                qtyMap.put(qp.part_number__c,qty);
                
            }else{
                qtyMap.put(qp.part_number__c,(qp.Quantity__c).intValue());
            }
       }
       System.debug('##  qtyMap ## '+qtyMap);
       
       List<Product_Work_code__c> workcodeList = [Select p.Skill__c, p.Work_Code__c ,start_date__c,end_date__c,p.Product_Code__c, p.Hours__c From Product_Work_Code__c p where product_code__c in :qtyMap.keySet() and start_date__c <= :System.today() and end_date__c>=:System.today() ];
       
       // Cognizant - CHI Phase III CR-002 implementation... START
       System.debug('##  workcodeList ## '+workcodeList);
       List<Job__c> jobList = ObjNewSkill.fetchJobList(jobL); 
        
       //List<Job__c> jobList = [select dont_override_hours__c,Split_Job__c,Water_Heating_Fixing_Hours__c,Building_Work_Hours__c,Connect_Solar_Panel_Hours__c,Contractor_Installation_Hours__c,Electrical_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,LPG_Installation_Hours__c,Mechanical_Hours__c,Payment_Collection_Hours__c,Roof_Work_Hours__c,Specialist_Building_Hours__c,Unvented_Hot_Water_Hours__c,PowerFlush_Hours__c,Solar_Hours__c,id from job__c where id in :jobL];
        // Cognizant - CHI Phase III CR-002 implementation... END
        
       for(Product_Work_code__c pw :workcodeList ){
           // Code fix by BGSAMSsupport for  PRB00007089 starts
        for(Job_Element__c jeList : jeListSelected){
              System.debug('## jeList '+jeList);
              System.debug('## jeList.P5_IsItinerary__c  '+jeList.P5_IsItinerary__c );
          if(jeList.P5_IsItinerary__c == false && jeList.Product_ID__c==pw.Product_Code__c && jeList.Type__c=='work' && jeList.Code__c==pw.Work_Code__c){ 
         // Code fix by BGSAMSsupport for  PRB00007089 ends   
           if(pwMap.containsKey(pw.Product_Code__c)){
                String tempStr = pwMap.get(pw.Product_Code__c);
                tempStr = tempStr+'/'+pw.Skill__c+':'+pw.Hours__c;
                pwMap.put(pw.Product_Code__c ,tempStr);
                System.debug('##  pwMap ##if '+pwMap);
           }else{
                pwMap.put(pw.Product_Code__c ,pw.Skill__c+':'+pw.Hours__c);
                System.debug('##  pwMap ##else '+pwMap);
                }
           break;
            }
           }
       } 
       
       System.debug('##  pwMap ## '+pwMap); 
       
       // Cognizant - CHI Phase III CR-002 implementation... START 
       jobList = ObjNewSkill.setJobHours(jobList, pwMap, jobBMap, qtyMap);        
       
       // Cognizant - CHI Phase III CR-002 implementation... END
       
       return jobList;
   }
    public PageReference actnCancel(){
        Pagereference pg = new Pagereference('/'+System.currentpagereference().getparameters().get('orgJobId'));
        pg.setRedirect(true);   
        return pg;
   }
   
  public void calculateSelectedHours()
  {
   system.debug('------skillmap-------------'+skillmap);
    hourList = new List<calcHours>();
    for(packDetails pck : pckDetList)
    {
        if(pck.b_IsElementSelected)
        {
            //totalHours = 0;
            calcHours hour = new calcHours();
            for(Job_Element__c jE : pck.JE){
                if(skillmap.containsKey(jE.Skill__c))
                {
                    hour = skillmap.get(jE.Skill__c);
                    //totalHours = totalHours + hour.hours;
                    if(!hour.elementIds.contains(jE.id))
                    {
                        hour.elementIds.add(jE.id);
                        hour.skillStyle = 'color:#4842F5;';
                        hour.hours = hour.hours + jE.Units__c;
                        totalHours = totalHours + jE.Units__c;
                    }
                }
                skillmap.put(jE.Skill__c , hour);
             }
            
            
        }
        else
        {
            calcHours hour = new calcHours();
            for(Job_Element__c jE:pck.JE){
                if(skillmap.containsKey(jE.Skill__c))
                {
                    hour = skillmap.get(jE.Skill__c);
                    //totalHours = totalHours - hour.hours;
                    if(hour.elementIds.contains(jE.id))
                    {
                        hour.hours = hour.hours - jE.Units__c;
                        hour.skillStyle = '';
                        hour.elementIds.remove(jE.id);
                        totalHours = totalHours - jE.Units__c;
                    }
                }
                skillmap.put(jE.Skill__c , hour);
             }
            
        }
        system.debug('------skillmap-------------'+skillmap);
    }
    if(skillmap != null && skillmap.values() != null )
    {
        hourList = sortSkills(skillmap);
    }
   }
   
   list<calcHours> sortSkills(map<string,calcHours> skillMap)
   {
    List<string> skillset = new List<string>();
    skillset.addAll(skillMap.keySet());
    skillset.sort();
    system.debug('------skillset-------------'+skillset);
    List<calcHours> tmpHourList = new List<calcHours>();
    List<calcHours> basicHourList = new List<calcHours>();
    for(String tmpSkill : basicSkillList)
    {
        calcHours tmpHour = new calcHours();
        //tmpHour.skill = tmpSkill;
        tmpHour = skillMap.get(tmpSkill);
        basicHourList.add(tmpHour);
    }
    tmpHourList.addAll(basicHourList);
    for(String skill : skillset)
    {
        if(!basicSkillSet.contains(skill))
        tmpHourList.add(skillMap.get(skill));
    }
    return tmpHourList;
   }
   
    public class CalcHours
    {
        public string skill {get; set;}
        public double hours {get; set;}
        public set<Id> elementIds {get; set;}
        public string skillStyle {get; set;}
        public calcHours()
        {
            skill = '';
            hours = 0;
            elementIds = new set<Id>();
            skillStyle = '';
        }
      }
    
   public class packDetails{
        public Quote_Product__c packElement = new Quote_Product__c();
        public List<Job_Element__c> jE{get; private set;}
        public boolean b_IsElementSelected = false;
        public Decimal Hours;
       
        public Decimal getHours(){
          return Hours;
        }
        public void setB_IsElementSelected(boolean selected){
            this.B_IsElementSelected = selected;
        }
        public boolean getB_IsElementSelected(){
            return this.b_IsElementSelected;
        }
        public Quote_Product__c getpackElement(){
            return packElement ;
        }
        
        public packDetails(List<Job_Element__c> jE){
          this.jE = jE;
                
        } 
   }
    
   
}