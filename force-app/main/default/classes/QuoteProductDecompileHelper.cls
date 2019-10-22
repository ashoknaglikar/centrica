/*
Type Name: QuoteProductDecompileHelper 
Author: Cognizant
Created Date: 01/09/2010
Reason: This class is created to support QuoteProductDecompile class.
        As QuoteProductDecompile class is reached maximum character limit, 
        some code of the class is shifted to this class.
Change History:
25/11/2010 - Added changes to implement CHI 2010 Commission Scheme that requires Projected Commissionable Margin(PCM)
             For the Quote OR ASP
*/
public class QuoteProductDecompileHelper{

    //Check if any JBH's exist that are not set to 'Integrated'
    public static list<Job_Element__c> returnJobElements(ASP__c asp, List<ID> quoteProductsRemovedIDs, list<Job_Element__c> jobElementsToRemove,  List<ID> qpRemoveParts,List<ID> qpRemoveHours,List<ID> qpRemovePartsAndHours, map<string, Quote_Product__c> quanMap){
       //PRB00025860 fix added a condition in the below query to restrict job elements with 'Removed' substatus
        jobElementsToRemove = [Select Units__c, UnitsFormula__c, Unit_Price__c, Type__c, Supplier__c, Supplier_Order_Number__c, Sub_Status__c, Status__c, Start_Date__c, Skill__c, Product__c, Product_ID__c, Premier_Updated__c, Planned__c, P5_IsItinerary__c, Order__c, New_Supplier__c, New_Supplier_Number__c, Name, Merchant_Order_Number__c, Line_Item_ID__c, Job__c, IsDeleted, Id, Do_Not_Assign_Order__c, Description__c,  Current_Supplier__c, Current_Supplier_Number__c, Completion_Date__c, Code__c from Job_Element__c where Line_Item_ID__c in:quoteProductsRemovedIDs and Sub_Status__c != 'Removed']; 
        //PRB00025860 fix ends
        System.debug('jobElementsToRemove is: '+jobElementsToRemove);
        System.debug('quanMap--->'+quanMap);
        map<string, decimal> removeCheckMap = new map<string, decimal>();
        map<string, list<Job_Element__c>> qpJobEleMap= new  map<string, list<Job_Element__c>>();
         //+++ Coding starts -- as a part of PRB00011438 by BGSAMS Support on 17-04-2013
        
        set<string> uniqueList = new set<string>();
        list<order__c> updOrderList = new list<order__c>();
        
        if(qpRemoveHours.isEmpty() && qpRemovePartsAndHours.isEmpty())
        {
            for(integer i =0; i<jobElementsToRemove.size();i++){
                Job_Element__c jobElementToRemove= jobElementsToRemove[i];
                if(jobElementToRemove.Type__c != 'Material')
                {
                    jobElementsToRemove.remove(i);
                    System.debug('jobElementToRemove  '+jobElementToRemove);
                }
            }
            
        }
        
        for(Job_Element__c je: jobElementsToRemove)
        {
            list<Job_Element__c> tempList= new list<Job_Element__c>();
            if(qpJobEleMap.containskey(je.Line_Item_ID__c))
            {
                tempList.addall(qpJobEleMap.get(je.Line_Item_ID__c));
                
            }
            tempList.add(je);
            qpJobEleMap.put(je.Line_Item_ID__c,tempList);
            
        }
        //--- Coding ends -- as a part of PRB00011438 by BGSAMS Support on 17-04-2013
        
        
        //DEFECT FIX: ASP REMOVAL: START: 19/08/2010.
        if(!jobElementsToRemove.isEmpty()){   
            //for(Job_Element__c jobElementToRemove:jobElementsToRemove){
                System.debug('Â£Â£Â£ ASP REMOVAL step5: jobElementsToRemove: '+jobElementsToRemove);
                System.debug('Â£Â£Â£ ASP REMOVAL step5: jobElementsToRemove: '+qpJobEleMap);
                for(String quoteProductId : qpRemoveParts){
                    if(qpJobEleMap.containskey(quoteProductId))
                    {
                    for(Job_Element__c jobElementToRemove:qpJobEleMap.get(quoteProductId))
                    {
                        decimal quan =0;
                        if(jobElementToRemove.Type__c == 'Material'){
                            if(quanMap.containskey(jobElementToRemove.Product_ID__c))
                            {
                                Quote_Product__c tempQ = quanMap.get(jobElementToRemove.Product_ID__c);
                                if(removeCheckMap.containskey(jobElementToRemove.Product_ID__c+jobElementToRemove.Code__c))
                                {
                                    quan = removeCheckMap.get(jobElementToRemove.Product_ID__c+jobElementToRemove.Code__c);
                                    if(quan>=tempQ.Quantity__c)
                                    {
                                        jobElementToRemove.Line_Item_ID__c = tempQ.Id;
                                        if(jobElementToRemove.Order__c!=null)
                                        {
                                            jobElementToRemove.Sub_Status__c='Awaiting Order';
                                        }else
                                        {
                                            jobElementToRemove.Sub_Status__c='Removed';
                                        }
                                        continue;
                                    }
                                }
                                quan+=1;
                                removeCheckMap.put(jobElementToRemove.Product_ID__c+jobElementToRemove.Code__c,quan );
                                
                            }
                            
                            jobElementToRemove.Status__c = 'Removed'; 
                                                   
                            if (jobElementToRemove.Order__c!=null){
                                jobElementToRemove.Sub_Status__c='Awaiting Order';
                                uniqueList.add(jobElementToRemove.Order__c);
                                    
                            } else {
                                jobElementToRemove.Sub_Status__c='Removed';
                            }  
                            
                            system.debug('updated job element status in qpRemoveParts');// added by BGSAMS support as a part of PRB00005800
                           // break;
                        }
                    }
                    }
                }
                
                for(String quoteProductId : qpRemoveHours){
                    if(qpJobEleMap.containskey(quoteProductId))
                    for(Job_Element__c jobElementToRemove:qpJobEleMap.get(quoteProductId))
                    {
                        decimal quan =0;
                        //if(jobElementToRemove.Line_Item_ID__c.equals(quoteProductId) && jobElementToRemove.Type__c == 'Work')
                        if(jobElementToRemove.Type__c == 'Work')
                        {
                            if(quanMap.containskey(jobElementToRemove.Product_ID__c))
                            {
                                Quote_Product__c tempQ = quanMap.get(jobElementToRemove.Product_ID__c);
                                if(removeCheckMap.containskey(jobElementToRemove.Product_ID__c+jobElementToRemove.Code__c))
                                {
                                    quan = removeCheckMap.get(jobElementToRemove.Product_ID__c+jobElementToRemove.Code__c);
                                    if(quan>=tempQ.Quantity__c)
                                    {
                                        jobElementToRemove.Line_Item_ID__c = tempQ.Id;
                                        if(jobElementToRemove.Order__c!=null)
                                        {
                                            jobElementToRemove.Sub_Status__c='Awaiting Order';
                                        }else
                                        {
                                            jobElementToRemove.Sub_Status__c='Removed';
                                        }
                                        continue;
                                    }
                                }
                                quan+=1;
                                removeCheckMap.put(jobElementToRemove.Product_ID__c+jobElementToRemove.Code__c,quan );
                                
                            }
                            jobElementToRemove.Status__c = 'Removed';
                            if (jobElementToRemove.Order__c!=null){
                                jobElementToRemove.Sub_Status__c='Awaiting Order';
                            } else {
                                jobElementToRemove.Sub_Status__c='Removed';
                            }
                            system.debug('updated job element status in qpRemoveHours');// added by BGSAMS support as a part of PRB00005800
                            //break;
                        }
                    }
                }

                for(String quoteProductId : qpRemovePartsAndHours){
                    if(qpJobEleMap.containskey(quoteProductId))
                    for(Job_Element__c jobElementToRemove:qpJobEleMap.get(quoteProductId))
                    {
                        decimal quan =0;
                        if(quanMap.containskey(jobElementToRemove.Product_ID__c))
                        {
                            Quote_Product__c tempQ = quanMap.get(jobElementToRemove.Product_ID__c);
                            if(removeCheckMap.containskey(jobElementToRemove.Product_ID__c+jobElementToRemove.Code__c))
                            {
                                system.debug('Quan--->'+quan);
                                quan = removeCheckMap.get(jobElementToRemove.Product_ID__c+jobElementToRemove.Code__c);
                                if(quan>=tempQ.Quantity__c)
                                {
                                    jobElementToRemove.Line_Item_ID__c = tempQ.Id;
                                    if(jobElementToRemove.Order__c!=null)
                                    {
                                        jobElementToRemove.Sub_Status__c='Awaiting Order';
                                    }else
                                    {
                                        jobElementToRemove.Sub_Status__c='Removed';
                                    }
                                   
                                    continue;
                                }
                            }
                            quan+=1;
                            removeCheckMap.put(jobElementToRemove.Product_ID__c+jobElementToRemove.Code__c,quan );
                           
                            system.debug('removeCheckMap--->'+removeCheckMap);
                            
                        }
                        if(jobElementToRemove.Type__c == 'Material' || jobElementToRemove.Type__c == 'Work'){
                            jobElementToRemove.Status__c = 'Removed';
                            if (jobElementToRemove.Order__c!=null){
                                jobElementToRemove.Sub_Status__c='Awaiting Order';
                                if(jobElementToRemove.Type__c == 'Material')
                                {
                                     uniqueList.add(jobElementToRemove.Order__c);   
                                }    
                            } else {
                                jobElementToRemove.Sub_Status__c='Removed';
                            }  
                            system.debug('updated job element status in qpRemovePartsAndHours ');// added by BGSAMS support as a part of PRB00005800                      
                            //break;
                        }
                    }
                }
            //}           
        }
            
        System.debug('Â£Â£Â£ ASP REMOVAL step6: jobElementsToRemove: '+jobElementsToRemove);
        try{
        System.debug('inside try block'); // added by BGSAMS support as a part of PRB00005800 
        if(jobElementsToRemove != null && jobElementsToRemove.size() > 0){
            update jobElementsToRemove; 
        } 
        
        for(string orderId: uniqueList)
        {
            updOrderList.add(new order__c(id= orderId, DelNotes_ASP__c = asp.Material_Notes__c, Mat_Ret_Info__c = asp.Material_Return_Info__c));
        } 
         
         if(updOrderList.size()>0)
         {
            update updOrderList;
         } 
        }
         catch(Exception e) {
         // added by BGSAMS support as a part of PRB00005800
         Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();   
         String[] toAddresses1 = system.label.Exception_emails_for_batches.split(',');
         mail1.setToAddresses(toAddresses1);
         mail1.setSubject('Exception while updating job element');
          mail1.setPlainTextBody('Exception while updating job element error received in QuoteProductDecompileHelper class: ' + e.getMessage()+' Error in line number : '+e.getLineNumber());
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
          System.debug('Exception while updating job element'+e.getMessage()+' Error in line number : '+e.getLineNumber());
                    
                    }
        //DEFECT FIX: ASP REMOVAL: END: 19/08/2010. 
        
        return jobElementsToRemove;
    }

        // CHI 2010 Commission Scheme Changes - Starts
        
        // Fix - Calculation of correct values of avg labour cost and avg material cost for ASP submission.
                 
        public  static Double[] calculatePCM(BigMachines_Quote__c TriggerQuote, Quote_Product__c[] TriggerQuoteProducts, Integer source)
        {                       
            Map<String, Integer> QuoteProductMap = new Map<String, Integer>();
           
            // Fix - Calculation of correct values of avg labour cost and avg material cost for ASP submission.
            Map<String, Integer> QuoteProductAvgLabourMapForASP = new Map<String, Integer>();
            Map<String, Integer> QuoteProductAvgMaterialMapForASP = new Map<String, Integer>();
            Integer quoteProductQTYForASP = 0;
            
            Double Avg_Labour_Cost =0.0 ;     
            Double Avg_Material_Cost =0.0 ;
            Double X2011_Commission_Sales_value = 0.0;
            Double Projected_Commissionable_Margin = 0.0; 
            Integer qty = 0;                
            String Productcode;
            Double templabour;
            Double tempmaterial;
            String concatenatedString; 
            String Test;         
            ID quoteID;
            
            /* Commission Change 
               Date: 07/04/2014
                           
            */
            
            Double CSV =0.0; // Commissioable Sales Value
            Double SOV =0.0; // Sales Order Value
            
            System.debug('Inside calculatePCM');           
         
            System.debug('Quote Passed'+ TriggerQuote);               
            system.debug('TriggerQuote.Line_Items_Decompiled__c: '+TriggerQuote.Line_Items_Decompiled__c);
            system.debug('TriggerQuote.quote_reconciled__c: '+TriggerQuote.quote_reconciled__c);
            system.debug('TriggerQuote.Consider_for_Installation_Planning__c: '+TriggerQuote.Consider_for_Installation_Planning__c +'TriggerQuote.stage__c: '+TriggerQuote.stage__c+'TriggerQuote.Is_Primary__c :'+TriggerQuote.Is_Primary__c );
            
            map<string , double> allowanceMap = new Map <String, Double>();
            double commissioableAllownce_tot =0.0;
            if(Source== 0)
            {
            if(TriggerQuote.appliedAmount1__c!=0)
            {
                allowanceMap.put(TriggerQuote.CS_Allowance_1__c, TriggerQuote.appliedAmount1__c);
                //allowanceMap.put('a4Q1100000005uB', TriggerQuote.appliedAmount1__c);
                
            }
            if(TriggerQuote.appliedAmount2__c!=0)
            {
                allowanceMap.put(TriggerQuote.CS_Allowance_2__c, TriggerQuote.appliedAmount2__c);
                //allowanceMap.put('a4Q1100000005uJEAQ', TriggerQuote.appliedAmount2__c);
            }
            if(TriggerQuote.appliedAmount3__c!=0)
            {
                allowanceMap.put(TriggerQuote.CS_Allowance_3__c, TriggerQuote.appliedAmount3__c);
                //allowanceMap.put('a4Q1100000005ti', TriggerQuote.appliedAmount3__c);
                
            }
            if(TriggerQuote.appliedAmount4__c!=0)
            {
                allowanceMap.put(TriggerQuote.CS_Allowance_4__c, TriggerQuote.appliedAmount4__c);
                
            }
            if(TriggerQuote.appliedAmount5__c!=0)
            {
                allowanceMap.put(TriggerQuote.CS_Allowance_5__c, TriggerQuote.appliedAmount5__c);
                
            }
            if(TriggerQuote.appliedAmount6__c!=0)
            {
                allowanceMap.put(TriggerQuote.CS_Allowance_6__c, TriggerQuote.appliedAmount6__c);
                
            }
            
        
            system.debug('Allowance Map-->'+allowanceMap);
            
            
            for(CS_Allowance__c a : [Select Id,Non_Cash__c , Cash_Equivalent_Amount__c , Commissionable__c,Allowance_Percentage__c  from CS_Allowance__c where Id in : allowanceMap.keyset()])
            {
                
                if(a.Non_Cash__c)
                commissioableAllownce_tot += a.Cash_Equivalent_Amount__c;
                else if(!a.Commissionable__c)
                {
                    if(a.Allowance_Percentage__c!=null)
                    {
                        system.debug('---Allownace--'+a.Id);
                        system.debug('---Allownace--'+a.Allowance_Percentage__c);
                        system.debug('---Allownace--'+commissioableAllownce_tot);
                        commissioableAllownce_tot +=allowanceMap.get(a.Id)*a.Allowance_Percentage__c/1.2;
                    }
                    else
                    
                    commissioableAllownce_tot +=allowanceMap.get(a.Id)/1.2;
                } 
            }
            system.debug('commissioableAllownce_tot-->'+commissioableAllownce_tot);
            
            }
    
            // Validate if the Quote should be taken for calculating PCM
            if( TriggerQuote.Line_Items_Decompiled__c == true && TriggerQuote.Consider_for_Installation_Planning__c == 'Y' && TriggerQuote.quote_reconciled__c == true && TriggerQuote.stage__c == 'Quote Finalised - Accepted')
                {
                    System.debug('Quote Validated to proceed');
                    quoteID = TriggerQuote.Id;
                                        
                if(!TriggerQuoteProducts.isEmpty())  
                   { 
                    system.debug('TriggerQuoteProducts.size() Passed is: '+ TriggerQuoteProducts.size());
                    
                  if(source == 0){
                        
                    for(Quote_Product__c QuoteProduct : TriggerQuoteProducts)                    
                    {
                        
                        System.debug('Non_Commision_Pack__c' + QuoteProduct.Non_Commision_Pack__c);
                        if(QuoteProduct.Non_Commision_Pack__c == 'N')
                           { 
                            // Put information of all the related QuoteProducts into the Map                      
                            if(QuoteProductMap.containsKey(QuoteProduct.part_number__c)){
                                qty = QuoteProductMap.get(QuoteProduct.part_number__c);
                                qty=qty+(QuoteProduct.Quantity__c).intValue();
                                QuoteProductMap.put(QuoteProduct.part_number__c,qty);
                            }
                            else{                
                                QuoteProductMap.put(QuoteProduct.part_number__c,(QuoteProduct.Quantity__c).intValue()); 
                            } 
                                                                                                       
                           }  
                              
                           CSV += QuoteProduct.Commission_Value__c;
                           SOV += QuoteProduct.Sales_Order_Value__c;  
                           system.debug('CSV--->'+CSV+'  '+SOV);              
                     }
                     
                  }else if(source == 1){
                    
                   for(Quote_Product__c QuoteProduct : TriggerQuoteProducts)                    
                    
                      {
                         System.debug('Non_Commision_Pack__c' + QuoteProduct.Non_Commision_Pack__c);
                         
                         // Do not consider non commisionable pack if these are removed as part of ASP process
                         
                         if(QuoteProduct.Non_Commision_Pack__c == 'Y' && QuoteProduct.ASP_Reason__c.equalsIgnoreCase('Removed')){
                            
                             continue;
                            
                         }
                         
                        
                        // Put information of all the related QuoteProducts into the Map 
                            
                            quoteProductQTYForASP = (QuoteProduct.Quantity__c).intValue();
                            
                            if(QuoteProduct.ASP_Reason__c.equalsIgnoreCase('Added')){
                                
                                quoteProductQTYForASP = quoteProductQTYForASP;
                                
                            }else if(QuoteProduct.ASP_Reason__c.equalsIgnoreCase('Removed')){
                                
                                quoteProductQTYForASP = 0 - quoteProductQTYForASP;
                                
                            }   
                            
                            if(QuoteProduct.ASP_Action__c.contains('Parts')){                  
                              if(QuoteProductAvgMaterialMapForASP.containsKey(QuoteProduct.part_number__c)){
                                  qty = QuoteProductAvgMaterialMapForASP.get(QuoteProduct.part_number__c);
                                  qty=qty+quoteProductQTYForASP;
                                  QuoteProductAvgMaterialMapForASP.put(QuoteProduct.part_number__c,qty);
                              }
                              else{                
                                  QuoteProductAvgMaterialMapForASP.put(QuoteProduct.part_number__c,quoteProductQTYForASP); 
                              } 
                            }  
                            
                            if(QuoteProduct.ASP_Action__c.contains('Hours')){                  
                              if(QuoteProductAvgLabourMapForASP.containsKey(QuoteProduct.part_number__c)){
                                  qty = QuoteProductAvgLabourMapForASP.get(QuoteProduct.part_number__c);
                                  qty=qty+quoteProductQTYForASP;
                                  QuoteProductAvgLabourMapForASP.put(QuoteProduct.part_number__c,qty);
                              }
                              else{                
                                  QuoteProductAvgLabourMapForASP.put(QuoteProduct.part_number__c,quoteProductQTYForASP); 
                              } 
                            }  
                                            
                     }
                    
                  }
                    
               }
                    
                    System.debug('QuoteProductMap '+ QuoteProductMap.size());                   
                    
                    if(!QuoteProductMap.isEmpty() && source == 0)
                    {
                        CSV -= commissioableAllownce_tot;
                        SOV -= commissioableAllownce_tot;
                        // Get the Labour Cost for all the products in the Quote
                        Avg_Labour_Cost = calLabourCost(QuoteProductMap,quoteID );
                        // Get the Material Cost for all the products in the Quote
                        Avg_Material_Cost = calMaterialCost(QuoteProductMap);
                    }
                    
                    if(!QuoteProductAvgMaterialMapForASP.isEmpty() && source ==1){
                         // Get the Material Cost for all the products in the Quote
                        Avg_Material_Cost = calMaterialCost(QuoteProductAvgMaterialMapForASP);
                    }
                    
                    if(!QuoteProductAvgLabourMapForASP.isEmpty() && source ==1){
                         // Get the Labour Cost for all the products in the Quote
                        Avg_Labour_Cost = calLabourCost(QuoteProductAvgLabourMapForASP,quoteID );
                    }
                                                    
                }       
                
                if(userinfo.getuserId () == system.label.BM_UserId)
                 X2011_Commission_Sales_value = TriggerQuote.X2011_Commission_Sales_value__c;
                else 
                
                 X2011_Commission_Sales_value = CSV - TriggerQuote.Non_Commissionable_sales_value__c;
                /*
                    PCM Adjustments done
                */
                
                Projected_Commissionable_Margin = X2011_Commission_Sales_value -(Avg_Labour_Cost + Avg_Material_Cost); 
                if(source==0)
                {
                    Double pcmAdjustment = double.valueof(system.label.PCM_Adjustment);
                    Projected_Commissionable_Margin+=pcmAdjustment;
                }                          
                
                Double[] ReturnValues = new Double[]{Projected_Commissionable_Margin, Avg_Labour_Cost, Avg_Material_Cost, CSV, SOV};
                System.debug('Return Values from calculatePCM() '+ ReturnValues);
                
                return ReturnValues;            
                 
        }                                           
                    
            public static Double calLabourCost(Map<String, Integer> QuoteProductMap, ID quoteID )
            { 
                Double Avg_Labour_Cost ; 
                Double Product_Labour_Cost = 0; 
                String District;
                String Skill;
                String hoursStr;
                String skillUpper;
                
                System.debug('Entering calLabourCost For quoteID' + quoteID);
                Job__c[] associatedJob = new Job__c[]{};              
                Map<String, String> ProductWorkCodeMap = new Map<String, String>();             
                
                //Retrieve ProductWorkCode information for the Quote Products
                List<Product_Work_Code__c> ProductWorkCodes = [Select Work_Code__c, Skill_Type__c,Skill__c, Hours__c, Product_Code__c From Product_Work_Code__c 
                where Product_Code__c in :QuoteProductMap.keySet()AND (Start_Date__c <= :date.today() AND End_Date__c >= :date.today()) AND (Active__c = True)];
                
                System.debug('ProductWorkCodes Size  '+ ProductWorkCodes.size());
                
                if(!ProductWorkCodes.isEmpty())
                  {
                    for(Product_Work_Code__c ProductWorkCode : ProductWorkCodes )
                     {  
                                        
                         if(ProductWorkCodeMap.containsKey(ProductWorkCode.Product_Code__c))
                         {
                            //Make the Skill in uppercase
                            if(ProductWorkCode.Skill_Type__c !=null){
                            skillUpper  = ProductWorkCode.Skill_Type__c;   
                            skillUpper = skillUpper.replaceAll('/', '_'); 
                            }                                                 
                            
                            String tempStr = ProductWorkCodeMap.get(ProductWorkCode.Product_Code__c);
                            if(ProductWorkCode.Hours__c != null && skillUpper !=null ){
                            tempStr = tempStr+'/'+skillUpper.toUpperCase() +':'+ProductWorkCode.Hours__c;
                            }else if((ProductWorkCode.Hours__c == null || ProductWorkCode.Hours__c == 0) && skillUpper !=null ){
                            tempStr = tempStr+'/'+skillUpper.toUpperCase() +':'+'0.0';
                            }
                            ProductWorkCodeMap.put(ProductWorkCode.Product_Code__c ,tempStr);
                         }
                         else{
                               if(ProductWorkCode.Skill_Type__c !=null){ 
                                  skillUpper  = ProductWorkCode.Skill_Type__c;
                                  skillUpper = skillUpper.replaceAll('/', '_'); 
                               }
                                                        
                               if(ProductWorkCode.Hours__c != null && skillUpper !=null ){
                                   ProductWorkCodeMap.put(ProductWorkCode.Product_Code__c ,skillUpper.toUpperCase() +':'+ProductWorkCode.Hours__c);
                              }else if((ProductWorkCode.Hours__c == null || ProductWorkCode.Hours__c == 0) && skillUpper !=null ){
                                   ProductWorkCodeMap.put(ProductWorkCode.Product_Code__c ,skillUpper.toUpperCase() +':'+ '0.0');
                              }      
                           }                 
                     }                              
                  }                   
                  //Get the District for the Quote
                  AddNewSkill ObjNewSkill = new AddNewSkill(); 
                  associatedJob = ObjNewSkill.fetchJobByQuote(quoteID,true);    
                  
                  if(!associatedJob.isEmpty())
                  District  = associatedJob[0].District__c;
                  string Product_Type = associatedJob[0].Quote__r.Product_Type_ID__c;
                  //Get the Map having info of rate of skills in a particular District
                  Map<String, Double> SkillRatePerDistrictMap = getSkillRatePerDistrict(District,Product_Type);
                  
                  System.debug('ProductWorkCodeMap.size() '+ ProductWorkCodeMap.size()  );  
                  if(ProductWorkCodeMap.size()>0){
                  for( String ProductCode : ProductWorkCodeMap.keySet() )
                  {
                    System.debug('Calculating Labour Cost For Product ' + ProductCode);
                    
                    String[] strList = (ProductWorkCodeMap.get(ProductCode)).split('/');
                    Integer qtyTotal = QuoteProductMap.get(ProductCode);
                    // Initialitializing for each product
                    Avg_Labour_Cost = 0;                      
                    
                    System.debug('Product quantity ' + qtyTotal + 'StrList '+ strList.size());
                    
                    for(String str : strList)
                    {    
                       String[] tempStr = str.split(':');
                       
                       if (tempStr.size() > 1){
                           Skill = tempStr[0];
                           hoursStr = tempStr[1]; 
                          }                                              
                       
                       if(hoursStr != NULL)
                       {                       
                        Skill = Skill.toUpperCase();                      
                       
                        System.debug('Skill '+ Skill + 'Hours ' + hoursStr );       
                        
                        if(Skill.contains('MECHANICAL')&& SkillRatePerDistrictMap.get(Skill) != NULL)                          
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill)); 
                        else if(Skill.contains ('WATER HEATER FIXING')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));       
                        else if(Skill.contains ('SPECIALIST BUILDING')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('SPECIALIST BUILDING WORK')&& SkillRatePerDistrictMap.get(Skill) != NULL) 
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill)); 
                        else if(Skill.contains ('SCAFFOLDER')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost +(Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));     
                        else if(Skill.contains ('ROOF WORK')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('PAYMENT COLLECTION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ELECTRICAL')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('LPG INSTALLATION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('FIREWALL HEATER FIXING')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                        Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('CONTRACTOR INSTALLATION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill)); 
                        else if(Skill.contains ('CONNECT SOLAR PANELS')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('BUILDING WORK')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('POWERFLUSH')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ELECTRICAL WORK ASP')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ASBESTOS REMOVAL')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ASBESTOS REMOVAL FIXED RATE')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('SOLAR')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('PRE-ELECTRICAL SURVEY')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ECOGEN MECHANICAL')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ECOGEN ELECTRICAL')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));                         
                         else if(Skill.contains ('UNVENTED HOT WATER')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('UNVENTED_HOT_WATER')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('FIRE_WALL HEATER FIXING')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('CONTRACTOR_INSTALLATION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill)); 
                        else if(Skill.contains ('CONNECT_SOLAR_PANELS')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('SPECIALIST_BUILDING_WORK')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ROOF_WORK')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ELECTRICAL_WORK_ASP')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ASBESTOS_REMOVAL')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ASBESTOS_REMOVAL-FIXED_RATE')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ASBESTOS REMOVAL-FIXED RATE')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('LPG_INSTALLATION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('PAYMENT_COLLECTION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('WATER_HEATER_FIXING')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                         else if(Skill.contains ('INSULATION (LOFT)')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('QUALITY INSPECTION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('CAVITY WALL INSULATION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));     
                        else if(Skill.contains ('POWERFLUSH')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('DOUBLE HANDED WORK')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('INSTALL SOLAR PANELS')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                                            
                        System.debug('Average Labour cost in calLabourCost'+ Avg_Labour_Cost);  
                       }                
                    }                   
                        Product_Labour_Cost = Product_Labour_Cost + Avg_Labour_Cost * qtyTotal; 
                        System.debug(' Final Labour cost in calLabourCost'+ Product_Labour_Cost);               
                  }
                  }             
                return Product_Labour_Cost;
            
            }               
            
            public static Double calMaterialCost(Map<String, Integer> QuoteProductMap)
            {
                Map<String, String> ProductMaterialMap = new Map<String, String>();
                Double Product_Material_Cost = 0;
                Double Avg_Material_Cost;
                Double MaterialNWAC = 0;  
                Integer qtyTotal = 0;  
                
                //Retrieve Product Material information for the Quote Products
                List< Product_Materials__c > ProductMaterials  = [Select Quantity__c, Product_Code__c, Material_Code__c From Product_Materials__c 
                where Product_Code__c in :QuoteProductMap.keySet() AND (Start_Date__c <= :date.today() AND End_Date__c >= :date.today()) AND (Active__c = True)] ;
                Set<string> Setproductcode = new Set<string>();
                
                if(!productMaterials.isEmpty())
                  {
                    for(Product_Materials__c ProductMaterial : ProductMaterials )
                     {  
                        if(ProductMaterialMap.containsKey(ProductMaterial.Product_Code__c))
                         {
                            String tempStr = ProductMaterialMap.get(ProductMaterial.Product_Code__c);
                            tempStr = tempStr+'/'+ProductMaterial.Material_Code__c+':'+ ProductMaterial.Quantity__c;                         
                            ProductMaterialMap.put(ProductMaterial.Product_Code__c ,tempStr);
                         }
                         else{
                            ProductMaterialMap.put(ProductMaterial.Product_Code__c ,ProductMaterial.Material_Code__c +':'+ProductMaterial.Quantity__c);
                         }
                         Setproductcode.add(ProductMaterial.Material_Code__c);                      
                       }                   
                    //Get the Map having info of NWAC of Materials
                    //Modified by AMit Kumar
                    /*****************************************************
                    *********************************************************start**************************************/
                    Map<String, Double> NWACPerMaterialMap = getNWACForMaterial(Setproductcode);
                    if(NWACPerMaterialMap.size()>0){   
                    for( String ProductCode : ProductMaterialMap.keySet() )
                      {
                        String[] strList = (ProductMaterialMap.get(ProductCode)).split('/');
                        qtyTotal = QuoteProductMap.get(ProductCode);
                        System.debug('Finding NWAC for '+ ProductCode + 'Having quantity ' + qtyTotal);
                        // Initialitializing for each product
                        Avg_Material_Cost = 0;                    
                    
                        for(String str : strList)
                        {    
                            String[] tempStr = str.split(':');
                            String MaterialCode = tempStr[0];
                            String MaterialQty  = tempStr[1];
                            System.debug(' For Material '+ MaterialCode + ' having Quantity '+ MaterialQty);               

                            MaterialNWAC = 0;
                            MaterialCode = MaterialCode.toUpperCase();                          
                            
                            MaterialNWAC = NWACPerMaterialMap.get(MaterialCode);                    
                            
                            if(MaterialNWAC != 0 && MaterialNWAC != NULL && MaterialQty != NULL)
                            //if(MaterialNWAC != 0 || MaterialNWAC != NULL )                          
                            Avg_Material_Cost = Avg_Material_Cost + (Double.valueOf(MaterialQty)* MaterialNWAC );
                            System.debug('MaterialNWAC '+ MaterialNWAC + ' For Material '+ MaterialCode + ' having Quantity '+ MaterialQty);               
                        } 
                        
                        Product_Material_Cost = Product_Material_Cost + Avg_Material_Cost * qtyTotal;                                                           
                      }  
                    }                       
                  }             
                
                return  Product_Material_Cost ;             
               }        
                    
        public static Map<String, Double> getSkillRatePerDistrict(String District, string Product_Type)
                {
                    System.debug('Entering getSkillRatePerDistrict For District :' + District);
                    Map<String, Double> SkillRatePerDistrictNullMap = new Map<String, Double>();
                    Map<String, Double> SkillRatePerDistrictProdMap = new Map<String, Double>();
                    String SkillUpper; 
                    Double Rate = 0.0;
                    List<Avg_Skill_Rate__c> SkillRatePerDistrict =  [Select a.Skill__c, a.Rate__c ,Product_Type_ID__c From Avg_Skill_Rate__c a where a.District__c = :District and (Product_Type_ID__c = :Product_Type or Product_Type_ID__c = null)];
                    if(SkillRatePerDistrict.size()>0){
                    for(Avg_Skill_Rate__c SkillRate : SkillRatePerDistrict )
                     {      
                        SkillUpper  = SkillRate.Skill__c;
                        
                        Rate = SkillRate.Rate__c;
                        if(Rate == NULL)
                          Rate = 0.0;                    
                        if(SkillRate.Product_Type_ID__c!= null)
                        {
                            SkillRatePerDistrictProdMap.put(SkillUpper.toUpperCase().replaceAll('/', '_') , Rate);
                            
                        }
                        else{                                
                            SkillRatePerDistrictNullMap.put(SkillUpper.toUpperCase().replaceAll('/', '_') , Rate);
                            
                        }
                     }
                     system.debug('Product Map-->'+SkillRatePerDistrictProdMap);
                     system.debug('Non Product Map-->'+SkillRatePerDistrictNullMap);
                    if(SkillRatePerDistrictProdMap.size()==0)
                    {
                        return SkillRatePerDistrictNullMap;
                    }else{
                            for(string s: SkillRatePerDistrictNullMap.keyset())
                            {
                                if(!SkillRatePerDistrictProdMap.containskey(s))
                                {
                                    SkillRatePerDistrictProdMap.put(s,SkillRatePerDistrictNullMap.get(s));
                                }
                                
                            }
                            return SkillRatePerDistrictProdMap;
                    }        
                    //system.debug('SkillRatePerDistrictMap.keyset is: '+ SkillRatePerDistrictMap.keyset());
                       
                    }                
                    return SkillRatePerDistrictNullMap;
                  
                }   
                    
        
        public static Map<String, Double>  getNWACForMaterial( set<string> Setproductcode)
                {
                    Map<String, Double> NWACForMaterialsMap = new Map<String, Double>();
                    String MaterialCodeUpper;   
                    List<Product_Order__c> NWACForMaterials =   [Select a.Product_Code__c, a.NWAC__c From  Product_Order__c a where Product_Code__c in:Setproductcode];
                    if(NWACForMaterials.size()>0){
                    for(Product_Order__c NWACForMaterial : NWACForMaterials )
                     {      
                        
                        MaterialCodeUpper = NWACForMaterial.Product_Code__c;                                        
                                                        
                        NWACForMaterialsMap.put(MaterialCodeUpper.toUpperCase(), NWACForMaterial.NWAC__c);                  
                     }      
                    }
                    system.debug('NWACForMaterialsMap.keyset is: '+ NWACForMaterialsMap.keyset());
                    return NWACForMaterialsMap;
                   
                }
                // CHI 2010 Commission Scheme Changes - ENDS
}