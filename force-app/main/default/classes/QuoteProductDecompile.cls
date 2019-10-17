//make global as some methods are called via API (via custom button on an ASP page)
global without sharing class QuoteProductDecompile {
    ///
    //Class called by the QuoteProductDecompileTrigger which acts to decompile quote line items into Job element records
    ///
    //Check if quote products should be decompiled. All trigger line items must relate to the same quote, and the quote cannot already have been decompiled
    public static void decompileQuoteProducts(List<Quote_Product__c> TriggerQuoteProducts, List<ID> TriggerQuoteProductIDs){
        //Check that all quote products in the batch are related to the same quote.     
        boolean sameQuote = checkAssociatedQuoteIsTheSame(TriggerQuoteProducts, TriggerQuoteProducts[0].BigMachines_Quote__c);
         System.debug('sameQuote: '+sameQuote);      
        if(sameQuote){
            //Check Quote hasnt already been decompiled. To do this retrieve the Quote information.                      
            BigMachines_Quote__c triggerQuote = retrieveQuoteAssociatedToLineItems(TriggerQuoteProducts[0].BigMachines_Quote__c);   
             System.debug('----triggerQuote.Line_Items_Decompiled__c-----  '+triggerQuote.Line_Items_Decompiled__c);  
             System.debug('----triggerQuote.quote_reconciled__c-----  '+triggerQuote.quote_reconciled__c);                                    
            if(triggerQuote.Line_Items_Decompiled__c==false && triggerQuote.quote_reconciled__c==true){ 
                //call future method to do the decompile into Job elements
                System.debug('calling decompileQuoteProductsFuture');
                decompileQuoteProductsFuture(TriggerQuoteProductIDs);
                               
            }
        }    
    }
    
    //Future method used as more than 100 DML statements may occur (SFDC Govenor Limit) as trigger 'propogateModifications.trigger' also makes DML statements
    @future (callout=false)
    public static void decompileQuoteProductsFuture(List<ID> TriggerQuoteProductIDs){  
        System.debug('inside decompileQuoteProductsFuture');
        //declare exception variable for reporting 
        string decompileResult = 'Quote Decompiled Successfully';
        
        //retrieve the quote products that were inserted in the trigger
        Quote_Product__c[] TriggerQuoteProducts = retrieveQuoteLineItems(TriggerQuoteProductIDs);
        Job__c[] associatedJob = new List<Job__c>();
        boolean isSmartMeterRequired = false;
        
        try{                                          
            //Obtain the Job ID relating to the quote for which quote products have been added. Only one Job__c record should be linked to each Quote__c record. Every Accepted quote will have a job record (Job Reconciliation done in BigMachinesQuoteInsertJobReconciliation.cls)               
             associatedJob =retrieveJob(TriggerQuoteProducts[0].BigMachines_Quote__c,true); 
             System.debug('----------'+associatedJob);   
             string coreBundle;
             boolean coreBundleBln = false ;
             boolean misMatch = false;
            //Ensure an associatedJob record exists for this quote.
            if(associatedJob.size()==1){                
                //retrieve quote information          
                BigMachines_Quote__c triggerQuote = retrieveQuoteAssociatedToLineItems(associatedJob[0].Quote__c);                        
                                              
                system.debug('AssociatedJobID is: '+associatedJob[0].Id);   
                
                for(Quote_Product__c qp : TriggerQuoteProducts){
                    system.debug('Component_Type__c-->'+qp.Component_Type__c);
                    if(qp.Product__r.ProductCode == 'SM01'){
                        isSmartMeterRequired = true;
                    }
                    if(qp.Component_Type__c == 'Core Bundle')
                    {
                        coreBundle = qp.Product_Description__c;
                        coreBundleBln = true;
                    }
                }
                system.debug('Boolean Value -->'+coreBundleBln+ ' '+isSmartMeterRequired);
                boolean updateJob = false;
                boolean corebndlmismatch = false;
                if(coreBundleBln)
                {
                    
                    string[] budleInfo = (coreBundle != null && coreBundle != '') ? coreBundle.split(' ') : new List<string>();
                    system.debug('budleInfo-- >'+budleInfo);
                    if(associatedJob[0].District__r.Premier_ready__c  == true && budleInfo!= null & budleInfo.size() >= 2)
                     {
                          if(associatedJob[0].Installation_Type__c!=null && associatedJob[0].Boiler_Location__c !=null)
                          {
                              if(associatedJob[0].Installation_Type__c != budleInfo[0] || associatedJob[0].Boiler_Location__c != budleInfo[1] )
                              {
                              //PRB00027840 fix to compare job status as Allocated before changing the status and setting corebndlmismatch flag
                              If(associatedJob[0].Status__c == 'Allocated')
                              {
                                      associatedJob[0].Status__c = 'Allocated';
                                      associatedJob[0].Sub_Status__c = 'Quote Received Not Balanced'; //PRB00028012
                                  }
                                  associatedJob[0].Installation_Type__c = budleInfo[0] ;
                                  associatedJob[0].Boiler_Location__c = budleInfo[1]; 
                                  corebndlmismatch = true;
                                  
                              }
                              
                          }else{
                             associatedJob[0].Installation_Type__c = budleInfo[0];
                             associatedJob[0].Boiler_Location__c = budleInfo[1];
                             Lock.calBalancingSkill = true; 
                             
                          }
                         updateJob = true;
                     }
                     coreBundleBln = false;
                     
                }
                
                if(isSmartMeterRequired){
                    associatedJob[0].Smart_Meter_Required_Flag__c = 'Yes';
                    associatedJob[0].Reason_for_acknowledgement__c = 'New Job';
                    associatedJob[0].Smart_meter_installation_status__c = 'Pending';
                    associatedJob[0].Smart_meter_installation_sub_status__c = 'Unacknowledged';
                    triggerQuote.Smart_Meter_Required_Flag__c = 'Yes';
                    updateJob = true;
                    isSmartMeterRequired = false;
                }   
                
                if(updateJob)
                {
                     Database.update(associatedJob[0]);
                     //jobTriggerHelper.calculateBalancingMechanicalHours(associatedJob);
                }
                             
                //Collect all the part numbers associated to each quote product being added and create a delimited string of the line items ID and the quantity associated with it
                Map<String, String> PartNumbersMap = tallyPartNumbers(TriggerQuoteProducts);                                
                
                //Select Product_Work_Code__c data used to create Job Element records later
                List<Product_Work_Code__c> ProductWorkCodes = retrieveProductWorkCodes(PartNumbersMap); 
                system.debug('ProductWorkCodes.size() is: '+ProductWorkCodes.size());
                
                //Select Product_Materials__c data used to create Job Element records later
                List<Product_Materials__c> productMaterials = retrieveProductMaterials(PartNumbersMap); 
                system.debug('productMaterials.size() is: '+productMaterials.size());
                
                //IF job status is 'Allocated' then populate any 'WORK' job elements (not the materials elements) with the supplier name and supplier code.
                //To obtain this info look at the jobs related diary entries and find the supplier related to the employee related to the week that is linked to the diary entry found for the job which has the same 'skill' as the work element in question                    
                system.debug('associatedJob[0].Status__c is: '+associatedJob[0].Status__c);
                Map<String,Diary_Entry__c> diaryEntriesForEachSkillType = new Map<String,Diary_Entry__c>();
                Map<ID,Employee__c> employeeSupplierInfo = new Map<ID,Employee__c>();                    
                if(associatedJob[0].Status__c=='Allocated')
                    populateDiaryEntryAndSupplierMaps(diaryEntriesForEachSkillType,employeeSupplierInfo,associatedJob);
                
                system.debug('diaryEntriesForEachSkillType contains: '+diaryEntriesForEachSkillType);
                system.debug('employeeSupplierInfo contains: '+employeeSupplierInfo);
                
                //Construct a Job Element for each Product Work Code found in the reference data
                List<Job_Element__c> workJobElementsToInsert = createProductWorkCodeJobElements(ProductWorkCodes,associatedJob,diaryEntriesForEachSkillType, employeeSupplierInfo, PartNumbersMap);
                system.debug('workJobElementsToInsert.size() after all ProductWorkCodes added is: '+workJobElementsToInsert.size());
                
                //Construct a Job Element for each Product_Materials__c found in the reference data
                List<Job_Element__c> materialsJobElementsToInsert = createProductMaterialsJobElements(productMaterials, associatedJob, PartNumbersMap);
                system.debug('materialsJobElementsToInsert.size() after all productMaterials added is: '+materialsJobElementsToInsert.size());                                                   
                
                //combine all job elements into one list and insert them
                List<Job_Element__c> allJobElementsToInsert = new List<Job_Element__c>(); 
                allJobElementsToInsert.addAll(workJobElementsToInsert);
                allJobElementsToInsert.addAll(materialsJobElementsToInsert);   
                
                //setting the job elemnt status = changed 
                /*for(integer i =0; i < allJobElementsToInsert.size(); i++)
                {
                    allJobElementsToInsert[i].Status__c = 'Changed';
                }  */                                                                                                     
                insert(allJobElementsToInsert);           
                System.debug('-------------------         '    +allJobElementsToInsert);
                //If Job is 'Allocated' then check skill hours match with the Quote and update the status/sub-status to either booked, or Pending Mismatch.  
                system.debug('associatedJob[0].Status__c is: '+associatedJob[0].Status__c);                               
                if(associatedJob[0].Status__c=='Allocated'){          
                    boolean hoursMatch = checkIfSkillHoursMatchOnJobAndQuote(triggerQuote,associatedJob[0]);
                    system.debug('hoursMatch is: '+hoursMatch);
                    //PRB00027840 to update the job only if the corebndlmismatch flag is false
                    //if(corebndlmismatch == false){
                    if(corebndlmismatch)
                    {
                        hoursMatch = false;
                    }
                    updateJob(hoursMatch, associatedJob[0],triggerQuote); 
                   // }                                             
                    //Create a Job Booking history record of type 'Job Planned = true'if skill hours are found to be matching                               
                    if(hoursMatch)
                        createBookingHistory(associatedJob[0],true,true);
                }                
                triggerQuote.Line_Items_Decompiled__c=true;
                triggerQuote.isSystem__c = true;
                update triggerQuote;
                
                
            }
            else{                    
                decompileResult = 'Decomposition Failed: Quote for which line items are being created does not have a related Job record. Therefore job elements cannot be created for these line items.';
                System.debug('Quote for which line items are being created does not have a related Job record. Therefore job elements cannot be created for these line items.');
            }                                   
        }   
        catch(Exception e){
            if(e.getMessage().length()<200)
            decompileResult = 'Decomposition Failed: An exception occured - '+ e.getMessage(); 
            else
            decompileResult = 'Decomposition Failed: An exception occured - '+ e.getMessage().subString(0,200); 
            System.debug('An exception occured: '+e);
        }
        finally{
           
            BigMachines_Quote__c quote = retrieveQuoteAssociatedToLineItems(TriggerQuoteProducts[0].BigMachines_Quote__c);
            /*[select Is_Calc_Avg_Lab_Mat_Cost_On_Quote__c,quote_decompile_result__c,isSystem__c,
             Consider_for_Installation_Planning__c,Line_Items_Decompiled__c,quote_reconciled__c,stage__c,Is_Primary__c,
                X2011_Commission_Sales_value__c,Average_Labour_Cost_Quote__c,Average_Material_Cost_Quote__c, ECO_AW_GD__c,Opportunity__c,
                allowance_desc_1__c,allowance_desc_2__c, allowance_desc_3__c, allowance_desc_4__c, allowance_desc_5__c, allowance_desc_6__c,
                appliedAmount1__c, appliedAmount2__c, appliedAmount3__c, appliedAmount4__c,appliedAmount5__c, appliedAmount6__c,Non_Commissionable_sales_value__c
                from BigMachines_Quote__c where Id=:TriggerQuoteProducts[0].BigMachines_Quote__c];*/
            quote.quote_decompile_result__c=decompileResult;
            quote.isSystem__c =true;
            //update quote;
            
             System.debug('Calling calculatePCM');
                // CHI 2011 Commission Scheme Changes  - Starts          
                //Fetch the Quote again as fields are changed by  decompileQuoteProductsFuture while decompiling.  
                Double Projected_Commissionable_Margin = 0;                     
                //BigMachines_Quote__c TriggerQuoteupdated = retrieveQuoteAssociatedToLineItems(TriggerQuoteProducts[0].BigMachines_Quote__c);
                
                // Calculate the PCM for the Quote
                
                // Fix - Avg Labour and Avg Material cost becoming zero on quote. 
                
                
                if(quote.Is_Calc_Avg_Lab_Mat_Cost_On_Quote__c){
                    
                    update quote;
                    
                }else{
                     
                    Double[] PCMValues = QuoteProductDecompileHelper.calculatePCM(quote, TriggerQuoteProducts,0);                
                    
                    System.debug('Projected_Commissionable_Margin__c ' + PCMValues[0] + ' Average_Labour_Cost_Quote__c ' +PCMValues[1]+ ' Average_Material_Cost_Quote__c '  + PCMValues[2] );
                    
                    //if(PCMValues[1] > 0.00 && PCMValues[2] > 0.00){
                    
                         quote.Projected_Commissionable_Margin__c = PCMValues[0];
                         quote.Average_Labour_Cost_Quote__c       = PCMValues[1];
                         quote.Average_Material_Cost_Quote__c     = PCMValues[2];
                         quote.New_CSV__c = PCMValues[3];
                         quote.New_SOV__c = PCMValues[4];
                         //if(userinfo.getUserId() != system.label.BM_UserId)
                         {
                            quote.Commissionable_Sales_Value__c = PCMValues[3];
                            quote.salesOrderValue__c = PCMValues[4];
                         }
                         quote.Is_Calc_Avg_Lab_Mat_Cost_On_Quote__c = true;
                         update quote;
                         System.debug('Done calculatePCM');
                    
                     // }
                    
                }   
                
                try{
                
                // Auto-generate purchase orders as part of planning process if no order is yet generated on this job.
                  
                  AutoGeneratePurchaseOrders autoGen = new AutoGeneratePurchaseOrders();
                  
                  String autoGenerateOrders = System.Label.Auto_Generate_Purchase_Orders;
                  
                  // Fix - delete any orders which are being created without any job elements associated with them. 
                   
                  List<Order__c> orderList = new List<Order__c>();
                  
                
                  
                  if(associatedJob != null ){ 
                                                                                      
                    if(associatedJob.size()>0 && autoGenerateOrders.equalsIgnoreCase('TRUE')){
                        orderList = [Select Id from Order__c where Job__c=:associatedJob[0].Id]; 
                        if(associatedJob[0].Status__c == 'Planned' &&
                              associatedJob[0].Sub_Status__c == 'Installation Date Set' &&
                                associatedJob[0].Is_Remedial_Job__c != true &&
                                  associatedJob[0].Is_Downtime_Job__c != true &&
                                    orderList.size() == 0){ 
                                                                                         
                                      autoGen.autoGenerateOrders(associatedJob[0]);
                                      System.debug('Done auto-generate purchase orders');
                                      
                        }
                        
                     }
                     
                  }
              
              } catch(Exception e){

                    System.debug('An exception occured in auto-generation of purchase orders: '+e.getMessage());  
                                
              }
              try{
                if(quote.ECO_AW_GD__c=='GDF' || quote.ECO_AW_GD__c== 'Green Deal')
                {
                    GreenDealReconcillation.greendealreco(quote.Opportunity__c);
                }
              }
              catch (exception e)
              {
                
              }
            
        }             
        
    }  
         
       
    
    //Construct the required work job element records and return in an array
    public static List<Job_Element__c> createProductWorkCodeJobElements(List<Product_Work_Code__c> ProductWorkCodes, Job__c[] associatedJob, Map<String,Diary_Entry__c> diaryEntriesForEachSkillType, Map<ID,Employee__c> employeeSupplierInfo, Map<String, String> PartNumbersMap){
     
        //Create a job element for each Product_Work_Code__c added
        List<Job_Element__c> JobElementsToInsert = new List<Job_Element__c>();
        for(integer x=0;x<ProductWorkCodes.Size();x++){  
            String supplierName = '';
            String supplierNumber = '';                       
            Product_Work_Code__c ProductWorkCode = ProductWorkCodes[x]; 
            System.debug('------------'+associatedJob[0]);
            //If job is 'Allocated' then populate the correct Supplier Name and Supplier Number on each Work Job Element created.
            if(associatedJob[0].Status__c=='Allocated'){                          
                system.debug('ProductWorkCode.Skill__c.toLowerCase() is: '+ProductWorkCode.Skill__c.toLowerCase());
                system.debug('diaryEntriesForEachSkillType.keyset is: '+diaryEntriesForEachSkillType.keyset());
                //retrieve diary entry from map based on a matching skill
                if(diaryEntriesForEachSkillType.containsKey(ProductWorkCode.Skill__c.toLowerCase())){                              
                    Diary_Entry__c diaryEntryOfSameSkillType = diaryEntriesForEachSkillType.get(ProductWorkCode.Skill__c.toLowerCase());
                    //get supplier info of employee linked to the diary entry
                    if(employeeSupplierInfo.containsKey(diaryEntryOfSameSkillType.Week__r.Employee__c)){                                                              
                        Employee__c employeeOfDiaryEntry = employeeSupplierInfo.get(diaryEntryOfSameSkillType.Week__r.Employee__c);                      
                        supplierName = employeeOfDiaryEntry.Supplier__r.Name;
                        supplierNumber = employeeOfDiaryEntry.Supplier__r.Supplier_Num__c;
                    }
                }
            }                                       
            //Create multiple job elements if more than 1 identical line items were added.
            String quoteProductConcatenatedString = PartNumbersMap.get(ProductWorkCode.Product_Code__c);                
            //Split the concatenated string. This will contain multiple data if more than one of the same line item was added to a quote (ie same line item added multiple times, not just one line item with a quantity greater than 1)
            String[] quoteProductInfoSplit = quoteProductConcatenatedString.split(':');
            for(integer p=0;p<quoteProductInfoSplit.size()/2;p++){
                for(integer z=0;z<double.valueOf(quoteProductInfoSplit[p+p]).intValue();z++){                                                                                                                                   
                    Job_Element__c newProductWorkCodeJobElement = createJobElement(ProductWorkCode.Work_Code__c, 'Work', 'Active', ProductWorkCode.Work_Code_Description__c, associatedJob[0], ProductWorkCode.Product_Code__c, ProductWorkCode.Hours__c,ProductWorkCode.Skill__c,quoteProductInfoSplit[2*p+1],supplierName,supplierNumber);                                                                                                                            
                    JobElementsToInsert.add(newProductWorkCodeJobElement);
                }
            }
        }
        return JobElementsToInsert;
    }    
        
    //Construct the required materials job element records and return in an array
    public static List<Job_Element__c> createProductMaterialsJobElements(List<Product_Materials__c> productMaterials, Job__c[] associatedJob, Map<String, String> PartNumbersMap){
              
        List<Job_Element__c> JobElementsToInsert = new List<Job_Element__c>();
        System.debug('----------------- product materials found: ' + productMaterials+productMaterials.size());
//        System.debug('----------------- TriggerQuoteProducts =: ' + TriggerQuoteProducts+TriggerQuoteProducts.size());
        System.debug('----------------- PartNumbersMap =: ' +PartNumbersMap+PartNumbersMap.size());

        for(integer y=0;y<productMaterials.Size();y++){                     
            Product_Materials__c productMaterial = productMaterials[y];
            System.debug('----------------- Current product material: ' + productMaterial);   
                             
            //Create multiple seperate job elements if more than 1 identical line items were added to a quote 
            String quoteProductConcatenatedString = PartNumbersMap.get(productMaterial.Product_Code__c);   
            String[] quoteProductInfoSplit = quoteProductConcatenatedString.split(':');
            system.debug('quoteProductInfoSplit is :'+quoteProductInfoSplit);
            for(integer p=0;p<quoteProductInfoSplit.size()/2;p++){
                
                // brm - 13-01-2010 - work out quantity of product material
                Integer materialQuantity = double.valueOf(quoteProductInfoSplit[p+p]).intValue();
                
                // brm - 13-01-2010 - If the product code starts with C (i.e. is a Component)
                if (productMaterial.Material_Code__c.startsWith('C'))
                {
                    // brm - 13-01-2010 - create one job element only
                    System.debug('----------------- creating job element: ' + productMaterial.Material_Code__c + ', quantity: ' + materialQuantity);
                   // System.debug('----------------- QP TO GO: ' + TriggerQuoteProducts[p]);
                    Job_Element__c newproductMaterialJobElement = createJobElement(productMaterial.Material_Code__c, 'Material', 'Active', productMaterial.Material_Description__c,AssociatedJob[0],productMaterial.Product_Code__c, materialQuantity, '',quoteProductInfoSplit[2*p+1],'','');                                                                                
                    JobElementsToInsert.add(newproductMaterialJobElement); 
                }
                else
                {
                    // Note: This loop creates multiple job elements depending on what is typed in quantity
                    // i.e. quantity=3, creates 3 job elements
                    
                    // brm - 13-01-2010 - Changed to use materialQuantity variable
                    // double.valueOf(quoteProductInfoSplit[p+p]).intValue()
                    for(integer z=0;z<materialQuantity;z++){                                                                                                                                                                                                       
                            System.debug('----------------- creating job element: ' + productMaterial.Material_Code__c);
                            Job_Element__c newproductMaterialJobElement = createJobElement(productMaterial.Material_Code__c, 'Material', 'Active', productMaterial.Material_Description__c,AssociatedJob[0],productMaterial.Product_Code__c, productMaterial.Quantity__c, '',quoteProductInfoSplit[2*p+1],'','');                                                                                
                            JobElementsToInsert.add(newproductMaterialJobElement);                                                              
                    }
                }
            }
        } 
        return JobElementsToInsert;
    }
    
    //Retrieve the quote linked to the trigger line items inserted       
    public static BigMachines_Quote__c retrieveQuoteAssociatedToLineItems(ID quoteID){     

        // Cognizant - CHI Phase III CR-002 implementation... START
         
        AddNewSkill ObjNewSkill = new AddNewSkill(); 
        BigMachines_Quote__c triggerQuote = ObjNewSkill.fetchQuoteByQuote(quoteID);
        //BigMachines_Quote__c triggerQuote = [Select b.finalPriceVisibleToCustomer__c, b.quote_reconciled__c, b.Line_Items_Decompiled__c, b.skillTotalWaterHeatingFixing__c, b.skillTotalUnventedHotWater__c, b.skillTotalSpecialistBuilding__c, b.skillTotalSolar__c, b.skillTotalScaffolder__c, b.skillTotalRoofWork__c, b.skillTotalPowerFlush__c, b.skillTotalPaymentCollection__c, b.skillTotalMechanical__c, b.skillTotalLPGInstallation__c, b.skillTotalFireWallHeaterFixing__c, b.skillTotalElectrical__c, b.skillTotalContractorInstallation__c, b.skillTotalConnectSolarPanels__c, b.skillTotalBuildingWork__c, b.skillTotalAsbestosRemoval__c,isSystem__c, b.skillTotalAsbestosRemovalFixedRate__c, b.SkillTotalElectricalWorkASP__c, b.ASP_after_Billed__c,b.stage__c,b.Charge_to_Cutomer_after_Billed__c From BigMachines_Quote__c b where Id=:quoteID];
        
        // Cognizant - CHI Phase III CR-002 implementation... END
        
        return triggerQuote;                                                                 
    }              
    
    //Retrieve quote line records   
    //rjd - 22-12-2009 - only retrieving quote line items where the status isn't Refund or Removed.
    public static Quote_Product__c[] retrieveQuoteLineItems(ID[] TriggerQuoteProductIDs){     

        Quote_Product__c[] TriggerQuoteProducts = [Select id,Total_Price__c,Non_Commision_Pack__c
,Exclude_Decomposition__c,BigMachines_Quote__c, Quantity__c, Part_Number__c,Product__r.ProductCode, Product__r.Description,Commission_Value__c,
Sales_Order_Value__c,Component_Type__c, Product_Description__c  From Quote_Product__c 
                    where Id in:TriggerQuoteProductIDs and quotingReasonOn2ndVisit__c != 'Removed' and quotingReasonOn2ndVisit__c != 'Refund'];
        return TriggerQuoteProducts;                                                                 
    }  
    
    //Retrieve Job record linked to quote   
    public static Job__c[] retrieveJob(ID quoteID,boolean stat){     
        Job__c[] associatedJob = new Job__c[]{};
        // Cognizant - CHI Phase III CR-002 implementation... START
         
        AddNewSkill ObjNewSkill = new AddNewSkill();
        associatedJob = ObjNewSkill.fetchJobByQuote(quoteID,stat);
        
        /*if(stat == true)
            associatedJob = [Select Installation_Date__c,Quote__r.bmStatusReason__c,Job_Locked__c, Interface_Outstanding_Count__c, Id, Status__c,CHI_Lead__c,District__c,Quote__c,Type__c,Installer_Notes__c,Installation_Special_Instructions__c,Double_Handed_Job__c,Delivery_Notes__c,CRD_Code__c,Contractors__c,Contractor_Installation_Status__c,Bring_Forward_Job__c,Sub_Status__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Delivery_Date__c,Solar_Hours__c,Is_Remedial_Job__c,Is_Downtime_Job__c,Pre_Electrical_Hours__c From Job__c where Quote__c =:quoteID and Status__c in ('Pending','Planned','Allocated','Installed','Installed - Awaiting Payment')and Is_Remedial_Job__c != true and Is_Downtime_Job__c != true limit 1];
        else
            associatedJob = [Select Installation_Date__c,Quote__r.bmStatusReason__c,Job_Locked__c, Interface_Outstanding_Count__c, Id, Status__c,CHI_Lead__c,District__c,Quote__c,Type__c,Installer_Notes__c,Installation_Special_Instructions__c,Double_Handed_Job__c,Delivery_Notes__c,CRD_Code__c,Contractors__c,Contractor_Installation_Status__c,Bring_Forward_Job__c,Sub_Status__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Delivery_Date__c,Solar_Hours__c,Is_Remedial_Job__c,Is_Downtime_Job__c,Pre_Electrical_Hours__c From Job__c where Quote__c =:quoteID and Is_Remedial_Job__c != true and Is_Downtime_Job__c != true limit 1];
        */
        // Cognizant - CHI Phase III CR-002 implementation... END
        
        return associatedJob;                                                               
    }
           
    //Retrieve Product_Work_Code__c data associated with inserted quote line packs   
    public static List<Product_Work_Code__c> retrieveProductWorkCodes(Map<String, String> PartNumbersMap){     

        List<Product_Work_Code__c> ProductWorkCodes = [Select Work_Code__c, Work_Code_Description__c, Start_Date__c, Skill__c, Skill_Type__c, Product_Code__c, Name, Id, Hours__c, End_Date__c, Active__c From Product_Work_Code__c where Product_Code__c in :PartNumbersMap.keySet() AND (Start_Date__c <= :date.today() AND End_Date__c >= :date.today()) AND (Active__c = True)];       
        return ProductWorkCodes;                                                                 
    }     

    //Retrieve Product_Materials__c data associated with inserted quote line packs   
    public static List<Product_Materials__c> retrieveProductMaterials(Map<String, String> PartNumbersMap){     
        system.debug('PartNumbersMap retrieveProductMaterials is: '+PartNumbersMap);
        List<Product_Materials__c> productMaterials = [Select Start_Date__c, Quantity__c, Product_Code__c, Name, Material_Description__c, Material_Code__c, Id, End_Date__c From Product_Materials__c where Product_Code__c in :PartNumbersMap.keySet() AND (Start_Date__c <= :date.today() AND End_Date__c >= :date.today()) AND (Active__c = True)];
        system.debug('productMaterials is: '+productMaterials);
        return productMaterials;                                                                 
    }    
    
    //Load data into two maps holding info on diary entries related to the Job and employee and supplier information. These maps are referenced in code later.
    public static void populateDiaryEntryAndSupplierMaps(Map<String,Diary_Entry__c> diaryEntriesForEachSkillType, Map<ID,Employee__c> employeeSupplierInfo, Job__c[] associatedJob){     
                    
        list<ID> diaryEmpIDs = new list<ID>();
        //get associated diary entries for the job record
        Diary_Entry__c[] diaryEntries = [select Id, Week__r.Employee__c, Sub_Type__c from Diary_Entry__c where Job__c=:associatedJob[0].ID];                                                                                     
        //Create a map of skill type vs diary entry and create a list of all employees linked to diary entries
        for(Integer x=0;x<diaryEntries.size();x++){
            if(!diaryEntriesForEachSkillType.containsKey(diaryEntries[x].Sub_Type__c.toLowerCase())){
                diaryEntriesForEachSkillType.put(diaryEntries[x].Sub_Type__c.toLowerCase(),diaryEntries[x]);
                diaryEmpIDs.add(diaryEntries[x].Week__r.Employee__c);
            }
        }  
        System.debug('diaryEmpIDs : '+ diaryEmpIDs);
        //find supplier name and number linked to the employees performing the work                                     
        Map<ID,Employee__c> employeeSupplierInfoSOQLToMap = new Map<ID,Employee__c>([Select Supplier__r.Supplier_Num__c, Supplier__r.Name From Employee__c where ID in:diaryEmpIDs]);
        employeeSupplierInfo.putAll(employeeSupplierInfoSOQLToMap);                       
    }
    
    //Construct a job element record
    public static Job_Element__c createJobElement(String materialCode, String elementType, String status, String description, Job__c job, String productCode, Double hours, String skill, String lineItemSFDCId, String currentSupplier, String currentSupplierNumber){
//        System.debug('@ HERERERERERERE  @'+QuoteProduct);
        Job_Element__c newJobElement = new Job_Element__c ( Code__c = materialCode,                                                             
                                                            Type__c = elementType,
                                                            Status__c = status,                                                             
                                                            Description__c = description,
                                                            Job__c = job.ID,
                                                            Product_ID__c = productCode,
                                                            Units__c =hours,
                                                            Skill__c = skill,
                                                            Line_Item_ID__c = lineItemSFDCId,
                                                            Current_Supplier__c = currentSupplier, 
                                                            Current_Supplier_Number__c = currentSupplierNumber
                                                            );
        if(description.contains('Scaffolding') || description.contains('Asbestos'))
            newJobElement.P5_IsItinerary__c = true;
        System.debug('######creating Work job elemnt ###   '+newJobElement);
        return newJobElement;
    }
    
    
    //Check all quote products in the batch are related to the same quote.
    public static boolean checkAssociatedQuoteIsTheSame(Quote_Product__c[] TriggerQuoteProducts, ID quoteID){
                
        boolean sameQuote = true;       
        for (Integer i=0;i<TriggerQuoteProducts.size();i++) {
            system.debug('TriggerQuoteProducts[i].BigMachines_Quote__c is: '+TriggerQuoteProducts[i].BigMachines_Quote__c);         
            if (TriggerQuoteProducts[i].BigMachines_Quote__c != quoteId) {
                sameQuote = false;
            }
        }
        system.debug('sameQuote is: '+sameQuote);
        return sameQuote;
    }
    
    
    //Collect in a Map all the Part Numbers of the quote line items being added and for each create a delimited string containing the quote line ID and quantity associated for each instance that a product line item has been included on a quote 
    //Note - This string is later split and used to created the correct number of job elements correctly associated to the right BigMachines line item ID. Using this string method reduces the number of script statements required to do this logic 
    //(as appososed to itterating over a collection whilst already itterating through a collection) 
    public static Map<String, String> tallyPartNumbers(Quote_Product__c[] TriggerQuoteProducts){
                
            Map<String, String> PartNumbersMap = new Map<String, String>();
            String concatenatedString;     
            for(Quote_Product__c QuoteProduct:TriggerQuoteProducts){                                                    
                if(!PartNumbersMap.containsKey(QuoteProduct.Part_Number__c))
                    concatenatedString = String.valueOf(QuoteProduct.Quantity__c.intValue())+':'+QuoteProduct.ID;                    
                else{                   
                    String currentValue = PartNumbersMap.get(QuoteProduct.Part_Number__c);  
                    concatenatedString = currentValue+':'+String.valueOf(QuoteProduct.Quantity__c.intValue())+':'+QuoteProduct.ID;                                       
                }       
                PartNumbersMap.put(QuoteProduct.Part_Number__c,concatenatedString);
            }
            system.debug('PartNumbersMap is: '+PartNumbersMap);
            return PartNumbersMap;  
    }    
    
    //Check if an allocated job's skill hours match those skill hours recorded on the BigMachines_Quote__c
    public static boolean checkIfSkillHoursMatchOnJobAndQuote(BigMachines_Quote__c triggerQuote, Job__c Job){
        
        // Cognizant - CHI Phase III CR-002 implementation... START 
        
        AddNewSkill ObjNewSkill = new AddNewSkill();            
        boolean skillHoursMatch = ObjNewSkill.matchSkillHours(triggerQuote,Job);
        
        /*boolean skillHoursMatch=false;        
        if( ((Job.Water_Heating_Fixing_Hours__c == triggerQuote.skillTotalWaterHeatingFixing__c) || ((Job.Water_Heating_Fixing_Hours__c == null || Job.Water_Heating_Fixing_Hours__c == 0.00) && (triggerQuote.skillTotalWaterHeatingFixing__c == null || triggerQuote.skillTotalWaterHeatingFixing__c==0.00))) &&
            ((Job.Unvented_Hot_Water_Hours__c == triggerQuote.skillTotalUnventedHotWater__c) || ((Job.Unvented_Hot_Water_Hours__c == null || Job.Unvented_Hot_Water_Hours__c ==0.00) && (triggerQuote.skillTotalUnventedHotWater__c==null || triggerQuote.skillTotalUnventedHotWater__c==0.00))) &&
            ((Job.Specialist_Building_Hours__c == triggerQuote.skillTotalSpecialistBuilding__c) || ((Job.Specialist_Building_Hours__c == null || Job.Specialist_Building_Hours__c == 0.00) && (triggerQuote.skillTotalSpecialistBuilding__c==null || triggerQuote.skillTotalSpecialistBuilding__c==0.00))) &&
            ((Job.Scaffolder_Hours__c == triggerQuote.skillTotalScaffolder__c) || ((Job.Scaffolder_Hours__c == null || Job.Scaffolder_Hours__c == 0.00) && (triggerQuote.skillTotalScaffolder__c == null || triggerQuote.skillTotalScaffolder__c == 0.00))) &&
            ((Job.Roof_Work_Hours__c == triggerQuote.skillTotalRoofWork__c) || ((Job.Roof_Work_Hours__c == null || Job.Roof_Work_Hours__c==0.00) && (triggerQuote.skillTotalRoofWork__c ==null || triggerQuote.skillTotalRoofWork__c == 0.00))) &&
            ((Job.Payment_Collection_Hours__c == triggerQuote.skillTotalPaymentCollection__c) || ((Job.Payment_Collection_Hours__c == null || Job.Payment_Collection_Hours__c ==0.00) && (triggerQuote.skillTotalPaymentCollection__c == null || triggerQuote.skillTotalPaymentCollection__c == 0.00))) && 
            ((Job.Mechanical_Hours__c == triggerQuote.skillTotalMechanical__c) || ((Job.Mechanical_Hours__c == null || Job.Mechanical_Hours__c ==0.00) && (triggerQuote.skillTotalMechanical__c == null || triggerQuote.skillTotalMechanical__c==0.00))) &&
            ((Job.LPG_Installation_Hours__c == triggerQuote.skillTotalLPGInstallation__c) || ((Job.LPG_Installation_Hours__c == null || Job.LPG_Installation_Hours__c == 0.00) && (triggerQuote.skillTotalLPGInstallation__c==null || triggerQuote.skillTotalLPGInstallation__c==0.00))) &&
            ((Job.Fire_Wall_Heater_Fixing_Hours__c == triggerQuote.skillTotalFireWallHeaterFixing__c) || ((Job.Fire_Wall_Heater_Fixing_Hours__c == null || Job.Fire_Wall_Heater_Fixing_Hours__c == 0.00) && (triggerQuote.skillTotalFireWallHeaterFixing__c == null || triggerQuote.skillTotalFireWallHeaterFixing__c == 0.00))) &&
            ((Job.Electrical_Hours__c == triggerQuote.skillTotalElectrical__c) || ((Job.Electrical_Hours__c == 0.00 || Job.Electrical_Hours__c == null) && (triggerQuote.skillTotalElectrical__c == null || triggerQuote.skillTotalElectrical__c == 0.00))) &&
            ((Job.Contractor_Installation_Hours__c == triggerQuote.skillTotalContractorInstallation__c) || ((Job.Contractor_Installation_Hours__c == null || Job.Contractor_Installation_Hours__c == 0.00) && (triggerQuote.skillTotalContractorInstallation__c == null || triggerQuote.skillTotalContractorInstallation__c == 0.00))) &&
            ((Job.Connect_Solar_Panel_Hours__c ==triggerQuote.skillTotalConnectSolarPanels__c) || ((Job.Connect_Solar_Panel_Hours__c == null || Job.Connect_Solar_Panel_Hours__c ==0.00) && (triggerQuote.skillTotalConnectSolarPanels__c==null || triggerQuote.skillTotalConnectSolarPanels__c==0.00))) &&
            ((Job.Building_Work_Hours__c == triggerQuote.skillTotalBuildingWork__c) || ((Job.Building_Work_Hours__c == null || Job.Building_Work_Hours__c == 0.00) && (triggerQuote.skillTotalBuildingWork__c == null || triggerQuote.skillTotalBuildingWork__c==0.00))) &&
            ((Job.PowerFlush_Hours__c ==triggerQuote.skillTotalPowerFlush__c) || ((Job.PowerFlush_Hours__c ==null || Job.PowerFlush_Hours__c ==0.00) && (triggerQuote.skillTotalPowerFlush__c == null || triggerQuote.skillTotalPowerFlush__c == 0.00))) &&
            ((Job.Electrical_Work_ASP_Hours__c==triggerQuote.SkillTotalElectricalWorkASP__c) || ((Job.Electrical_Work_ASP_Hours__c==null || Job.Electrical_Work_ASP_Hours__c== 0.00) && (triggerQuote.SkillTotalElectricalWorkASP__c == null || triggerQuote.SkillTotalElectricalWorkASP__c == 0.00))) &&
            ((Job.Asbestos_Removal_Hours__c == triggerQuote.skillTotalAsbestosRemoval__c) || ((Job.Asbestos_Removal_Hours__c == null || Job.Asbestos_Removal_Hours__c == 0.00) && (triggerQuote.skillTotalAsbestosRemoval__c==null || triggerQuote.skillTotalAsbestosRemoval__c==0.00))) &&
            ((Job.Asbestos_Removal_Fixed_Rate_Hours__c ==triggerQuote.skillTotalAsbestosRemovalFixedRate__c) || ((Job.Asbestos_Removal_Fixed_Rate_Hours__c == null || Job.Asbestos_Removal_Fixed_Rate_Hours__c == 0.00) && (triggerQuote.skillTotalAsbestosRemovalFixedRate__c==null || triggerQuote.skillTotalAsbestosRemovalFixedRate__c==0.00))) &&
            ((Job.Solar_Hours__c == triggerQuote.skillTotalSolar__c) || ((Job.Solar_Hours__c == null || Job.Solar_Hours__c == 0.00) && (triggerQuote.skillTotalSolar__c == null || triggerQuote.skillTotalSolar__c == 0.00)))){
                                    
                skillHoursMatch=true;
            } */            
        // Cognizant - CHI Phase III CR-002 implementation... END
                    
        return skillHoursMatch;
    }
    
    //Update a Jobs status and sub status based on whether skill hours match on the job and quote.
    //Copy hours from quote to Job if they do not match. User tracks change via field history tracking on the hours fields
    public static void updateJob(boolean skillHoursMatchOnJobAndQuote, Job__c associatedJob, BigMachines_Quote__c triggerQuote){
        system.debug('Related quote bmStatusReason:'+associatedJob.Quote__r.bmStatusReason__c);
        if(skillHoursMatchOnJobAndQuote==true){
            associatedJob.Status__c='Planned';
            associatedJob.Sub_Status__c='Installation Date Set'; 
            associatedJob.GM_Status__c = 'In Progress';     
        }
        else{           
            associatedJob.Sub_Status__c='Quote Received Not Balanced';
            BigMachinesQuoteInsertJobReconciliation hourscopy = new BigMachinesQuoteInsertJobReconciliation();
            associatedJob = hourscopy.setJobHoursFromQuote(associatedJob,triggerQuote);
            update associatedJob;
            associatedJob = [Select id,Installation_Type__c, Boiler_Location__c,  Total_Hours__c,Balancing_Skill__c, District__r.Premier_Ready__c , District__r.Before_Trial__c from Job__c where Id = :associatedJob.Id];
            if(associatedJob.Installation_Type__c!=null
            && associatedJob.Boiler_Location__c!=null)
            jobTriggerHelper.calculateBalancingMechanicalHours(new list<Job__c> {associatedJob});
            
        }
        update associatedJob;
           
    }
    
    //create a job booking history record for merchant ordering interface to pick up
    public static void createBookingHistory(Job__c associatedJob, boolean workAffected, boolean materialsAffected){       
        system.debug('associatedJob.Id is: '+associatedJob.Id);
        Job_Booking_History__c bookingHistory = new Job_Booking_History__c(Work_Affected__c=workAffected, Materials_Affected__c=materialsAffected, Job__c=associatedJob.Id);       
        insert bookingHistory;        
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                                                                                                                  //
    //  ASP Related Classes - below are classes used as part of line item decomposition when an ASP is submitted.       //
    //                                                                                                                  //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////          
        
    //Called by the custom button 'Submit ASP' on the ASP page
    webservice static String submitASP(ID ASPId, ID ASPQuote){
        
        try{
            map<string,Quote_Product__c> addMap = new map<string,Quote_Product__c>();
            map<string,Quote_Product__c> remMap = new map<string, Quote_Product__c>();
            
            //Retrieve the ASP, and its associated Job and Quote
            ASP__c asp = [Select Function__c,Quote__c,quote__r.Id,quote__r.Opportunity__c,quote__r.Opportunity__r.Account.BillingPostalCode,Status__c,quote__r.Opportunity__r.StageName,Named_Employee__c, Charge_to_Customer__c,ASP_Type__c, Balancing_Cost_Change__c,ASP_Installation_Date__c, Projected_Commissionable_Margin__c, Average_Material_Cost_ASP__c, Average_Labour_Cost_ASP__c  , Definition__c,Material_Return_Info__c,Material_Notes__c from ASP__c where ID=:ASPId];
            Integer countSalesASP = [Select count() from ASP__c where Status__c = 'Submitted' and Quote__r.Id = :asp.quote__r.Id];
            Job__c[] associatedJobArray = new Job__c[]{};
            // Added this method for CHI CR-000462
            Quote_Product__c[] quoteProductsRelatingToASP;
            System.debug('@quote__r.Opportunity__r.StageName = @'+asp.quote__r.Opportunity__r.StageName);
            if(asp.quote__r.Opportunity__r.StageName == 'Closed Lost' && asp.ASP_Type__c !='Downtime' && asp.ASP_Type__c!=null &&  !asp.ASP_Type__c.Contains('Remedial'))
                throw new WebserviceException('The related CHI Lead is closed lost. Only Downtime ASPs and Remedial ASPs can be applied to the quote.');
            
            if(asp.ASP_Type__c =='Downtime' || (asp.ASP_Type__c!= null && asp.ASP_Type__c.contains('Remedial')))
                 associatedJobArray= retrieveJob(ASPQuote,false);// special case:  2nd arg should always be true in all other cases
            else
                associatedJobArray = retrieveJob(ASPQuote,true);
            //Job__c associatedJob = associatedJobArray[0]; // Commented : Cognizant :  29 June
            Job__c associatedJob = new Job__c();
            List<Job__c> newJobList=new List<Job__c>{};
            Job__c newJob = new Job__c();
             
            //if(associatedJobArray.isEmpty())
            if((!(asp.ASP_Type__c =='Downtime')) && associatedJobArray.isEmpty()) // added cognizant : 29 June
                throw new WebserviceException('There is no job against this ASP.');
            
               
            // Added : Cognizant : 29-June
            boolean entered =false;
            /*
            if(asp.ASP_Type__c!= null && asp.ASP_Type__c.contains('Remedial')){
                for(Job__c job : associatedJobArray){
                    if(job.Installation_Date__c == asp.ASP_Installation_Date__c){
                        entered  = true;
                        associatedJob = job;
                    }
                }
            }*/

            if(!entered){
                if(associatedJobArray.size() > 0)
                    associatedJob = associatedJobArray[0];
            }
             // Finish Part 1 : Cognizant : 29 June
             system.debug(entered+asp.ASP_Type__c+associatedJob.Job_Locked__c);
            if((!entered /*&& asp.ASP_Type__c== null*/) || (entered && associatedJob.Job_Locked__c =='N') || (!entered && asp.ASP_Type__c!= null && asp.ASP_Type__c.contains('Remedial')) || (asp.ASP_Type__c =='Downtime')){
            //retrieve all quote products relating to ASPs
                // brm - 12-01-2010 - Make charge to customer field mandatory
                if (asp.Charge_To_Customer__c == null)
                    throw new WebserviceException('Failure: Charge to Customer field is mandatory.');
                
                //rjd - 2010-01-29 - Stop submission if Balancing Cost Change is not 0 
                if (asp.Balancing_Cost_Change__c != 0)
                    throw new WebserviceException('Failure: You must enter a discount line for the value in the Balancing Discount field before the ASP can be submitted.');
                BigMachines_Quote__c quote = retrieveQuoteAssociatedToLineItems(ASPQuote);                          
                // Cognizant - CHI Phase III CR-005 implementation... START
                // Fix - PCM Calculation on ASP

                // ASP History Change - Starts
                
                List<Quote_Product__c> deleteQuoteProductList = [Select Id From Quote_Product__c where Mark_For_Deletion__c = true and ASP__c=:ASPId];
                
                cls_IsRun.setDontFireTriggers();
                
                Database.delete(deleteQuoteProductList);
                
                cls_IsRun.dontFireTriggers = false;

                quoteProductsRelatingToASP = [Select Product__c, Id, Total_Price__c, Total_Price_Ex_VAT__c, Name, GrossSingle__c, ASP_Impact__c, ASP_Status__c, Non_Commision_Pack__c, Supplier__c, Exclude_Decomposition__c,Quantity__c, Part_Number__c, ASP_Reason__c, ASP_Action__c, User_Defined_Product__c, Product_Description__c, Supplier__r.Name, Supplier__r.Supplier_Num__c, Unit_Merchant_Price_Exc_VAT__c, User_Defined_Description__c From Quote_Product__c where ASP__c=:ASPId];
                system.debug('quoteProductsRelatingToASP'+ quoteProductsRelatingToASP);// added by BGSAMS support as a part of PRB00005800
                
                if(quoteProductsRelatingToASP.size()<=0){
                    
                    Database.delete(asp);
                    
                    return 'This ASP is no longer required so deleting it and redirecting to quote.';
                    
                }
                
                // ASP History Change - Ends
                                
                List<ID> productIDList = new List<ID>();
                
                for(Quote_Product__c qp : quoteProductsRelatingToASP){
                    
                    if(qp.ASP_Action__c=='Add Hours Only' || qp.ASP_Action__c=='Add Parts and Hours' || qp.ASP_Action__c=='Remove Parts and Hours' || qp.ASP_Action__c=='Remove Hours Only'){    
                    
                        productIDList.add(qp.Product__c);
                        system.debug('productIDList'+ productIDList);// added by BGSAMS support as a part of PRB00005800
                    
                    }
                    
                    if(qp.ASP_Reason__c=='Removed')
                    {
                        remMap.put(qp.Name,qp);
                    }else
                    {
                        addMap.put(qp.Name,qp);
                    }
                }
                
                system.debug('Add Map--->'+addMap);
                system.debug('Add Map--->'+remMap);
                map<string,Quote_Product__c> quanMap = new map<string,Quote_Product__c>();
                for(string s: addMap.keyset())
                {
                    Quote_Product__c addQ= addMap.get(s);
                    Quote_Product__c remQ = new Quote_Product__c();
                    if(remMap.containskey(s))
                    {
                        remQ = remMap.get(s);
                        if( ((addQ.ASP_Action__c == 'Add Parts Only' &&  remQ.ASP_Action__c == 'Remove Parts Only') ||
                        (addQ.ASP_Action__c == 'Add Parts and Hours' &&  remQ.ASP_Action__c == 'Remove Parts and Hours')||
                        (addQ.ASP_Action__c == 'Add Hours Only' &&  remQ.ASP_Action__c == 'Remove Hours Only')))
                        {
                            remQ=remMap.get(s);
                            decimal quan = remQ.Quantity__c - addQ.Quantity__c;
                            if(quan>0)
                            quanMap.put(s,new Quote_Product__c(Quantity__c = quan, id = addQ.Id));
                        }
                    }
                    
                }  
                system.debug('quanMap--->'+quanMap);
                
                Integer countOfWorkCodes = [Select count() from Product_Work_Code__c where Product__c in :productIDList AND (Start_Date__c <= :date.today() AND End_Date__c >= :date.today()) AND (Active__c = True)];
                
                //Quote_Product__c[] quoteProductsRelatingToASP = [Select ASP_Status__c, Supplier__c, Exclude_Decomposition__c,Quantity__c, Part_Number__c, ASP_Reason__c, ASP_Action__c From Quote_Product__c where ASP__c=:ASPId];
                // Cognizant - CHI Phase III CR-005 implementation... END
                // CHI 2010 Commission Scheme Changes  - Start                 
                Double Projected_Commissionable_Margin_ASP = 0;                     
                   
                // Calculate the PCM for the Quote                
                //Projected_Commissionable_Margin_ASP   = QuoteProductDecompileHelper.calculatePCM(quote, quoteProductsRelatingToASP);
                Double[] PCMValues = QuoteProductDecompileHelper.calculatePCM(quote, quoteProductsRelatingToASP,1);
                System.debug('Projected_Commissionable_Margin For ASP '+ PCMValues[0] + 'Average_Labour_Rate_ASP For ASP '+ PCMValues[1] + 'Average_Material_Cost_ASP For ASP '+ PCMValues[2]  );                
                //asp.Projected_Commissionable_Margin__c = Projected_Commissionable_Margin_ASP;
                asp.Projected_Commissionable_Margin__c = PCMValues[0];
                asp.Average_Labour_Cost_ASP__c         = PCMValues[1];
                asp.Average_Material_Cost_ASP__c       = PCMValues[2];
                asp.Commissionable_Sales_Value__c = 0.0;
                asp.Non_Commission_Sales_Value__c = 0.0;
                //asp.ASP_Incent_Value__c = 0.0;
                asp.Commissionable_Sales_Value_Incl_VAT__c = 0.0;
                asp.Non_commission_Sales_Value_Incl_VAT__c = 0.0;
                asp.ASP_Commission_Sales_value_Incl_VAT__c = 0.0;
                //asp.ASP_Incent_Value__c = 0.0;
                
                for(Quote_Product__c quoteProduct : quoteProductsRelatingToASP){
                    if(quoteProduct.ASP_Action__c == 'Discount'){
                        continue;
                    }else if(quoteProduct.Total_Price_Ex_VAT__c != null){
                        if(quoteProduct.Total_Price_Ex_VAT__c <= 0.0){
                            continue;
                        }
                    }else if(quoteProduct.Total_Price_Ex_VAT__c == null){
                            continue;
                    }
                    if(quoteProduct.ASP_Reason__c == 'Added'){
                        if(quoteProduct.Non_Commision_Pack__c == 'N'){
                            asp.Commissionable_Sales_Value__c = asp.Commissionable_Sales_Value__c + quoteProduct.Total_Price_Ex_VAT__c; 
                            asp.Commissionable_Sales_Value_Incl_VAT__c = asp.Commissionable_Sales_Value_Incl_VAT__c + quoteProduct.Total_Price__c;
                        }else if(quoteProduct.Non_Commision_Pack__c == 'Y'){
                            asp.Non_Commission_Sales_Value__c = asp.Non_Commission_Sales_Value__c + quoteProduct.Total_Price_Ex_VAT__c;
                            asp.Non_commission_Sales_Value_Incl_VAT__c = asp.Non_commission_Sales_Value_Incl_VAT__c + quoteProduct.Total_Price__c;  
                        }
                    }else if(quoteProduct.ASP_Reason__c == 'Removed'){
                        if(quoteProduct.Non_Commision_Pack__c == 'N'){
                            asp.Commissionable_Sales_Value__c = asp.Commissionable_Sales_Value__c - quoteProduct.Total_Price_Ex_VAT__c;
                            asp.Commissionable_Sales_Value_Incl_VAT__c = asp.Commissionable_Sales_Value_Incl_VAT__c - quoteProduct.Total_Price__c; 
                        }
                    }
                }
                
                if(quoteProductsRelatingToASP.size() == 1 && quoteProductsRelatingToASP[0].ASP_Action__c == 'Discount'){
                         asp.Projected_Commissionable_Margin__c = 0;
                         asp.Average_Labour_Cost_ASP__c         = 0;
                         asp.Average_Material_Cost_ASP__c       = 0;
                         asp.ASP_Commission_Sales_value_Incl_VAT__c = 0;
               }else{
                         asp.ASP_Commission_Sales_value__c = (asp.Commissionable_Sales_Value__c + asp.Non_Commission_Sales_Value__c);
                         asp.ASP_Commission_Sales_value_Incl_VAT__c = (asp.Commissionable_Sales_Value_Incl_VAT__c + asp.Non_commission_Sales_Value_Incl_VAT__c);
                         asp.Projected_Commissionable_Margin__c = (asp.Commissionable_Sales_Value__c + asp.Non_Commission_Sales_Value__c) - (asp.Average_Labour_Cost_ASP__c+asp.Average_Material_Cost_ASP__c);
                }
                 
                 // ++ Added for ASP Discount CR-00081 start
                 if((asp.Definition__c == 'Sales Discount' || asp.Definition__c == 'Missing Discount') && asp.Function__c == 'Sales')
                 {
                    //asp.ASP_Incent_Value__c = (asp.Charge_to_Customer__c/1.2);
                    if(countSalesASP <= 0)
                    {
                        //asp.ASP_Incent_Value__c = asp.ASP_Incent_Value__c - Double.valueOf(System.Label.ASP_Penalty_Value);
                        asp.Penalty_ASP__c = true;
                    }
                 }
                 else
                 {
                    //asp.ASP_Incent_Value__c = ((asp.Charge_to_Customer__c * 2.5 - asp.ASP_Commission_Sales_value_Incl_VAT__c * 1.5)/1.2);
                    if(asp.Function__c == 'Sales' && asp.ASP_Commission_Sales_value_Incl_VAT__c != asp.Charge_to_Customer__c && countSalesASP<=0)
                    {
                        //asp.ASP_Incent_Value__c = asp.ASP_Incent_Value__c - Double.valueOf(System.Label.ASP_Penalty_Value);
                        asp.Penalty_ASP__c = true;
                    }
                 }
                 
                 // -- Added for ASP Discount CR-00081 end
                 
                 // ++ Commented code for ASP Discount CR-00081 start              
                 //asp.ASP_Incent_Value__c = (asp.Charge_to_Customer__c * 2.5 - asp.ASP_Commission_Sales_value_Incl_VAT__c * 1.5)/1.2;
                 // -- Commented code for ASP Discount CR-00081 end
                 
                 //System.debug('ASP_Incent_Value__c : '+asp.ASP_Incent_Value__c);
                 System.debug('First condition : '+String.valueOf(asp.Function__c == 'Sales'));
                 System.debug('Second condition is : '+String.valueOf(asp.ASP_Commission_Sales_value_Incl_VAT__c != asp.Charge_to_Customer__c));
                 System.debug('Third condition is : '+String.valueOf(countSalesASP<=0));
                 
                 // ++ Commented code for ASP Discount CR-00081 start
                 /*if(asp.Function__c == 'Sales' && asp.ASP_Commission_Sales_value_Incl_VAT__c != asp.Charge_to_Customer__c && countSalesASP<=0){
                    asp.ASP_Incent_Value__c = asp.ASP_Incent_Value__c - Double.valueOf(System.Label.ASP_Penalty_Value);
                    asp.Penalty_ASP__c = true;
                 }*/
                 // -- Commented code for ASP Discount CR-00081 end             
                                    
                 // CHI 2010 Commission Scheme Changes - End
                
                boolean blnCheckInstalled =false;
                boolean blnCheckDate = false;
                boolean blncheckdowntime = false;
               if(asp.ASP_Type__c!= null && (asp.ASP_Type__c.contains('Remedial') ||asp.ASP_Type__c == 'Recall')){
                  if(!entered){
                            System.debug('#####creating new job ...for remedial ');
                            blnCheckDate =true;
                            newJob.CHI_Lead__c =associatedJob.CHI_Lead__c;
                            newJob.District__c =associatedJob.District__c;
                            newJob.Installation_Date__c =asp.ASP_Installation_Date__c;
                            newJob.Quote__c =associatedJob.Quote__c;
                            newJob.Status__c ='Pending';
                            newJob.Secondary_Job_Type_New__c = asp.ASP_Type__c;
                            newJob.Sub_Status__c ='ASP Added';                            
                            newJob.Type__c =associatedJob.Type__c;
                            newJob.Installer_Notes__c =associatedJob.Installer_Notes__c;
                            newJob.Installation_Special_Instructions__c =associatedJob.Installation_Special_Instructions__c;
                            newJob.Double_Handed_Job__c =associatedJob.Double_Handed_Job__c;
                            newJob.Delivery_Notes__c =associatedJob.Delivery_Notes__c;
                            newJob.CRD_Code__c =associatedJob.CRD_Code__c;
                            newJob.Contractors__c =associatedJob.Contractors__c;
                            newJob.Contractor_Installation_Status__c=associatedJob.Contractor_Installation_Status__c;
                            newJob.Bring_Forward_Job__c=associatedJob.Bring_Forward_Job__c;
                            
                            if(asp.ASP_Type__c != 'Recall')
                            newJob.Is_Remedial_Job__c = true;
                            
                            if(asp.Named_Employee__c != null)
                                newJob.Named_Employee__c = asp.Named_Employee__c;
                            newJobList.add(newjob);
                            insert(newJobList);
                            associatedJob = newJob;
                            
                            
                            
                    }                    
                    system.debug('newJobList: '+newJobList);
                    system.debug('newJob Id: '+newJob.Id);
                }else
                if(asp.ASP_Type__c =='Downtime'){
                        blncheckdowntime =true;
                        String postCodeSector = asp.quote__r.Opportunity__r.Account.BillingPostalCode.substring(0,asp.quote__r.opportunity__r.Account.BillingPostalCode.length()-2);                                                      
                        newJob.District__c= new BigMachinesQuoteInsertJobReconciliation().getDistrict(postCodeSector);
                        newJob.CHI_Lead__c = asp.quote__r.Opportunity__c;
                        newJob.Secondary_Job_Type_New__c = asp.ASP_Type__c;
                        newJob.Quote__c =asp.Quote__c;
                        newJob.Status__c ='Pending';
                        newJob.Sub_Status__c ='ASP Added';
                        newJob.Type__c = 'Central Heating Instalations';
                        newJob.Is_Downtime_Job__c = true;
                        if(asp.Named_Employee__c != null)
                            newJob.Named_Employee__c = asp.Named_Employee__c;
                        newJobList.add(newjob);
                        insert(newJobList);
                        quote.isSystem__c=true;
                        associatedJob = newJob;
                } 
                
                //Ensure line items exist for the ASP.
                if(!quoteProductsRelatingToASP.isEmpty()){                                  
                                 
                    list<Quote_Product__c> quoteProductsRemoved = new list<Quote_Product__c>();
                    list<ID> quoteProductsRemovedIDs = new list<ID>();
                    list<Quote_Product__c> quoteProductsAdded = new list<Quote_Product__c>();
                    list<boolean> flags = new list<boolean>{false,false};
                    // Cognizant - CHI Phase III CR-005 implementation... START
                    list<Quote_Product__c> materialsAddedForUDP = new list<Quote_Product__c>();
                    // Cognizant - CHI Phase III CR-005 implementation... END
                    Map<ID,ID> supplierIDs = new Map<ID,ID>();                                  
                    Map<String,String> materialsAdded = new Map<String,String>();
                    Map<String,String> workAdded = new Map<String,String>();  
                    
                    //DEFECT FIX: ASP REMOVAL: CR-000210: START: 19/08/2010
                    List<ID> qpRemoveParts = new List<ID>();                    
                    List<ID> qpRemoveHours = new List<ID>();                
                    List<ID> qpRemovePartsAndHours = new List<ID>();            
                    //DEFECT FIX: CR-000210: END: 19/08/2010
                    
                    // Cognizant - CHI Phase III CR-005 implementation... START
                    // Added one parameter to this method for user defined asp                              
                    populateLineItemArrays(quoteProductsRelatingToASP, quoteProductsRemoved, quoteProductsRemovedIDs, quoteProductsAdded, materialsAddedForUDP, flags, supplierIDs, materialsAdded, workAdded,quanMap);
                    // Cognizant - CHI Phase III CR-005 implementation... END
                    
                    //DEFECT FIX:ASP REMOVAL: CR-000210: START: 19/08/2010 
                    for(integer x=0;x<quoteProductsRelatingToASP.size();x++){
                        System.debug('ASP REMOVAL step1: quoteProductsRelatingToASP[x].ASP_Reason__c: '+quoteProductsRelatingToASP[x].ASP_Reason__c);
                        if(quoteProductsRelatingToASP[x].ASP_Reason__c=='Removed' && quoteProductsRelatingToASP[x].ASP_Action__c!='Remove Extra Hours Only'){
                                          
                            if(quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Parts Only'){
                                qpRemoveParts.add(quoteProductsRelatingToASP[x].Id);    
                                     
                            } system.debug('qpRemoveParts'+ qpRemoveParts);// added by BGSAMS support as a part of PRB00005800
                            if(quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Hours Only'){
                                qpRemoveHours.add(quoteProductsRelatingToASP[x].Id);
                                
                            } system.debug('qpRemoveHours'+ qpRemoveHours);// added by BGSAMS support as a part of PRB00005800
                            if(quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Parts and Hours'){
                                qpRemovePartsAndHours.add(quoteProductsRelatingToASP[x].Id);
                                
                            }  system.debug('qpRemovePartsAndHours'+ qpRemovePartsAndHours);// added by BGSAMS support as a part of PRB00005800                         
                        }
                       
                    } 
                                                        
                    //DEFECT FIX: CR-000210: END: 19/08/2010
                    ///
                    //Decompose any line items that have been added to the ASP into new Job Elements
                    ///
                    List<Job_Element__c> workJobElementsToInsert = new List<Job_Element__c>();
                    List<Job_Element__c> workJobElementsToInsertnewJob = new List<Job_Element__c>();
                    List<Job_Element__c> materialsJobElementsToInsert = new List<Job_Element__c>();  
                    List<Job_Element__c> materialsJobElementsToInsertnewJob = new List<Job_Element__c>();
                    if(!quoteProductsAdded.isEmpty()){
                        //Retrieve Supplier Details of added line items relating to materials (parts)
                        Map<ID, Supplier__c> supplierMap = new Map<ID, Supplier__c>([Select Supplier_Num__c, Name from Supplier__c where Id in:supplierIDs.values()]);
                                        
                        //Collect all the part numbers associated to each quote product being added into a MAp and create a delimited string of the line items ID, ASP Reason type, and the quantity associated with it                     
                        Map<String, String> PartNumbersMap = tallyPartNumbersForASPs(quoteProductsAdded);
                        system.debug('materialsAdded cj is: '+materialsAdded);
                        //Retrieve all the reference data relating to any line item product added that requires decomposition into Job Elements
                        List<Product_Materials__c> productMaterials = retrieveProductMaterials(materialsAdded);
                        
                        List<Product_Work_Code__c> ProductWorkCodes = retrieveProductWorkCodes(workAdded);
                        
                        //Construct a Job Element for each Product Work Code found in the reference data
                       if((blnCheckInstalled == true && blnCheckDate == true)||(blncheckdowntime == true)){

                           workJobElementsToInsertnewJob = createProductWorkCodeJobElementsForASPs(ProductWorkCodes,newJob,PartNumbersMap);
                           
                        system.debug('workJobElementsToInsert.size() after all ProductWorkCodes added is: '+workJobElementsToInsertnewJob.size());
                       } else{
                        workJobElementsToInsert = createProductWorkCodeJobElementsForASPs(ProductWorkCodes,associatedJob,PartNumbersMap);
                        system.debug('workJobElementsToInsert.size() after all ProductWorkCodes added is: '+workJobElementsToInsert.size());
                       }
                         
                       if((blnCheckInstalled == true && blnCheckDate == true)||(blncheckdowntime == true)){

                           materialsJobElementsToInsertnewJob = createProductMaterialsJobElementsForASPs(productMaterials, newJob, PartNumbersMap, supplierMap, supplierIDs);
                           
                        system.debug('materialsJobElementsToInsert.size() after all productMaterials added is: '+materialsJobElementsToInsertnewJob.size());
                       }else{

                        //Construct a Job Element for each Product_Materials__c found in the reference data
                        materialsJobElementsToInsert = createProductMaterialsJobElementsForASPs(productMaterials, associatedJob, PartNumbersMap, supplierMap, supplierIDs);
                        system.debug('materialsJobElementsToInsert.size() after all productMaterials added is: '+materialsJobElementsToInsert.size()); 
                       }
                        //combine all job elements into one list and insert them
                        List<Job_Element__c> allJobElementsToInsert = new List<Job_Element__c>(); 
                        List<Job_Element__c> allJobElementsToInsertnewJob = new List<Job_Element__c>();
                        allJobElementsToInsert.addAll(workJobElementsToInsert);
                        allJobElementsToInsert.addAll(materialsJobElementsToInsert); 
                        allJobElementsToInsertnewJob.addAll(workJobElementsToInsertnewJob);
                        allJobElementsToInsertnewJob.addAll(materialsJobElementsToInsertnewJob);
                        //setting the status of Job elements to added if ASP added.   
                        if((blnCheckInstalled == true && blnCheckDate == true)||(blncheckdowntime == true)){
                        //setting the status of Job elements to added if ASP added.   
                         for(integer i=0; i < allJobElementsToInsertnewJob.size(); i++)
                         {
                            //PRODUCTION DEFECT FIX:TRANSFER WORK: START: 06-10-2010
                            //While creating job elements through ASP,put them in status :'ACTIVE' PREVIOUS: 'NEW'.
                            allJobElementsToInsertnewJob[i].Status__c = 'Active';
                            //PRODUCTION DEFECT FIX:TRANSFER WORK: END: 06-10-2010
                            
                         }
                                                                                                                         
                        insert(allJobElementsToInsertnewJob);
                        
                        } else{
                         for(integer i=0; i < allJobElementsToInsert.size(); i++)
                         {
                             //PRODUCTION DEFECT FIX:TRANSFER WORK: START: 06-10-2010
                            //While creating job elements through ASP,put them in status :'ACTIVE' PREVIOUS: 'NEW'.
                            allJobElementsToInsert[i].Status__c = 'Active';    
                            //PRODUCTION DEFECT FIX:TRANSFER WORK: END: 06-10-2010                     
                         }
                        System.debug('@Sumiting ASPS before :  @'+allJobElementsToInsert.size());    
                        insert(allJobElementsToInsert);
                        System.debug('@Sumiting after ASPS  :  @'+allJobElementsToInsert);  
                        }
                        
                    }
                    
                    // Cognizant - CHI Phase III CR-005 implementation... START
                    // Below block creates and inserts the job elements for user defined products.
                    if(!materialsAddedForUDP.isEmpty())
                    {
                        List<Job_Element__c> JobElementsToInsertForUDP = new List<Job_Element__c>();
                        for(integer x=0;x<materialsAddedForUDP.size();x++)    
                        {
                            Job_Element__c newproductMaterialJobElement = new Job_Element__c ( Code__c = '',                                                             
                                                                                            Type__c = 'Material',
                                                                                            Status__c = 'Active',                                                             
                                                                                            Description__c = materialsAddedForUDP[x].User_Defined_Description__c,
                                                                                            Job__c = AssociatedJob.ID,
                                                                                            Product_ID__c = materialsAddedForUDP[x].Part_Number__c,
                                                                                            Units__c =materialsAddedForUDP[x].Quantity__c,
                                                                                            Skill__c = '',
                                                                                            Line_Item_ID__c = materialsAddedForUDP[x].Id,
                                                                                            Current_Supplier__c = materialsAddedForUDP[x].Supplier__r.Name, 
                                                                                            Current_Supplier_Number__c =  materialsAddedForUDP[x].Supplier__r.Supplier_Num__c,
                                                                                            Merchant_Price__c = materialsAddedForUDP[x].Unit_Merchant_Price_Exc_VAT__c,
                                                                                            User_Defined_Product__c = true);
                            
                            if(materialsAddedForUDP[x].Product_Description__c.contains('Scaffolding') || materialsAddedForUDP[x].Product_Description__c.contains('Asbestos'))
                                newproductMaterialJobElement.P5_IsItinerary__c = true;
                            System.debug('######creating Work job elemnt ###   '+newproductMaterialJobElement);
                            
                            JobElementsToInsertForUDP.add(newproductMaterialJobElement);

                        }
                        System.debug('@Sumiting before UDPASPS  :  @'+JobElementsToInsertForUDP);   
                        insert(JobElementsToInsertForUDP);
                        
                        // Below code updates Code field of JE with Name field of JE for user defined JE only.                    
                        set<Id>jeIds = new set<Id>();
                        for(Job_Element__c je:JobElementsToInsertForUDP)
                        {
                            jeIds.add(je.Id);
                        }
                        list<Job_Element__c> updatingElements = [select Name,code__c from Job_Element__c where Id in :jeIds];
                        for(Job_Element__c je : updatingElements)
                        {
                            je.Code__c = 'MAT' + je.Name.substring(je.Name.indexof('-')+1,je.Name.length());
                        }                        
                        update updatingElements;
                    }
                    // Cognizant - CHI Phase III CR-005 implementation... END
                    
                    system.debug('Work and/or material Job Elements created for Added Line Items');
                    
                    ///
                    //For all line items of the ASP that have been made 'Removed' set all the associated Job Elements to be 'Returned'
                    ///
                    System.debug('#quoteProductsRemovedIDs = ##'+quoteProductsRemovedIDs);
                    list<Job_Element__c> jobElementsToRemove = new list<Job_Element__c>();
                    if(!quoteProductsRemovedIDs.isEmpty()){                                        
                        //DEFECT FIX: CR-000210: START: 19/08/2010
                        // added by BGSAMS support as a part of PRB00005800 starts
                        system.debug('ASPQuote '+ASPQuote);
                        system.debug('quoteProductsRemovedIDs '+quoteProductsRemovedIDs);
                        system.debug('jobElementsToRemove '+jobElementsToRemove);
                        system.debug('qpRemoveParts '+qpRemoveParts);
                        system.debug('qpRemoveHours '+qpRemoveHours);
                        system.debug('qpRemovePartsAndHours '+qpRemovePartsAndHours);
                        // added by BGSAMS support as a part of PRB00005800 ends
                        jobElementsToRemove = QuoteProductDecompileHelper.returnJobElements(asp,quoteProductsRemovedIDs, jobElementsToRemove, qpRemoveParts, qpRemoveHours, qpRemovePartsAndHours,quanMap);
                        
                        //DEFECT FIX: CR-000210: END: 19/08/2010
                    }
                    system.debug('Job elements set to Returned for Removed Line Items: jobElementsToRemove: '+jobElementsToRemove);
                    
                    for(integer x=0;x<quoteProductsRelatingToASP.size();x++){
                        System.debug('quoteProductsRelatingToASP[x].ASP_Reason__c : '+quoteProductsRelatingToASP[x].ASP_Reason__c);
                        if(quoteProductsRelatingToASP[x].ASP_Reason__c == 'Removed') 
                            quoteProductsRelatingToASP[x].ASP_Status__c='Committed - Removed';
                        else
                            quoteProductsRelatingToASP[x].ASP_Status__c='Committed - Added';
                    }
                    System.Debug('quoteProductsRelatingToASP: ' + quoteProductsRelatingToASP);
                    update quoteProductsRelatingToASP;
                    system.debug('Quote Line Items set to Committed');
                                                                                                    
                    ///
                    //Update the Job and Quote skill hours fields to reflect any hours added or removed by the ASP
                    ///
                    system.debug('jobElementsToRemove.size() :'+jobElementsToRemove.size());
                    boolean[] hoursAffected=new boolean[]{false};
                    //set the hours on job and quote. update call for each is made later on in code. 
                    if((blnCheckInstalled == true && blnCheckDate == true)||(blncheckdowntime == true)){
                    
                    System.debug('........QP'+workJobElementsToInsert);
                    setNewSkillHoursOnJobAndQuote(newJob, quote, workJobElementsToInsertnewJob,jobElementsToRemove,hoursAffected);
                    }
                    else{
                    setNewSkillHoursOnJobAndQuote(associatedJob, quote, workJobElementsToInsert, jobElementsToRemove,hoursAffected);                    
                    }system.debug('skill hours set but not committed');
                                    
                    ///
                    //Update job status and sub status if required (if line items added/removed affect hours)
                    ///         
                    system.debug('flags[1]: '+flags[1]);
                    if((blnCheckInstalled == true && blnCheckDate == true)){
                        associatedJob.Installed_Job__c=False;  //Added for Phase 5
                        associatedJob.Trigger_Update_Work_Hours__c = System.Now();
                        newJob.Is_Remedial_Job__c = true;
                        update newJob;
                        
                    }  
                    if((blncheckdowntime == true)){
                        associatedJob.Installed_Job__c=False;  //Added for Phase 5
                        associatedJob.Trigger_Update_Work_Hours__c = System.Now();
                        update newJob;
                        
                    } 
                    
                    System.debug('Aruna: flags[0]: '+flags[0]+' flags[1]: '+flags[1]);
                     //ASP DEFECT FIX:PRODUCTION ISSUE: START: 22/09/2010. 
                     //Just added one condirion is below if: "flags[0]==true"                     
                    if(countOfWorkCodes>0)
                    {
                    //ASP DEFECT FIX:PRODUCTION ISSUE: END: 22/09/2010. 
                        if (blnCheckDate ==false && blncheckdowntime == false )
                        {
                            associatedJob.Status__c='Pending';
                            associatedJob.Sub_Status__c='ASP Added'; 
                            associatedJob.Installed_Job__c=False;     //Added for Phase 5
                        }
                    }
                     //ASP DEFECT FIX:PRODUCTION ISSUE: END: 22/09/2010.
                    
                    //ASP DEFECT FIX:PRODUCTION ISSUE: START: 22/09/2010. 
                    //Just added one condirion is below if: "flags[0]==true" 
                    //commit changes to job (status's and skill hours changes)                  
                    if(flags[0]==true || flags[1]==true || hoursAffected[0]==true)
                    {
                        // brm - 08-01-2010 - Gets around the validation rules when changing hours
                       associatedJob.Installed_Job__c=False;  //Added for Phase 5
                       if(flags[1]==true || hoursAffected[0]==true){
                            associatedJob.Trigger_Update_Work_Hours__c = System.Now();
                       }    
                        update associatedJob;
                    } 
                    //ASP DEFECT FIX:PRODUCTION ISSUE: END: 22/09/2010.                                      
                    system.debug('Job status and/or Hours updated');

                    if (quote.Billed__c ==true)
                    {
                        quote.ASP_after_Billed__c = true;
                        quote.Charge_to_Cutomer_after_Billed__c = asp.Charge_to_Customer__c;
                    }
                    
                    update quote;
                    system.debug('Quote finalPriceVisibleToCustomer set');
                    
                    //ASP DEFECT FIX:PRODUCTION ISSUE: START: 22/09/2010.
                    ///
                    //Create Job Booking Histories if required
                    /// 
                    /*
                    if(flags[1]==true){
                    system.debug('associatedJob is:'+associatedJob);               
                    if (blnCheckDate ==false && blncheckdowntime == false ){
                    if(flags[0]==true)
                        createBookingHistory(associatedJob,false,true);  
                    }     
                    }*/                    
                    
                    if (blnCheckDate ==false && blncheckdowntime == false ){
                        if(flags[0]==true || flags[1]==true){
                            createBookingHistory(associatedJob,flags[1],flags[0]);  
                        } 
                    }
                    //ASP DEFECT FIX:PRODUCTION ISSUE: END: 22/09/2010.
                    system.debug('Job Booking History created');                    

                    ///
                    //Update ASP Status to submitted
                    ///                                 
                    asp.Status__c='Submitted';
                    update(asp);   
                    // Added this method for CHI CR-000462
                    createASPHistory(asp,quoteProductsRelatingToASP);                  
                    system.debug('ASP status updated');
                    
                     // Invoke the logic for calculating net customer price excluding VAT.
                    
                    List<BigMachines_Quote__c> bmQuoteListToConsider = new List<BigMachines_Quote__c>();
                    
                    CalculateQuoteNetValue c = new CalculateQuoteNetValue();
                    
                    BigMachines_Quote__c quoteToConsider = [select id, name, createdDate_quote__c,IsSystem__c, 
                          Number_of_paperworks_recieved__c,
                          Opportunity__r.Platform__c,
                          Opportunity__r.CHI_Lead_Id__c,Opportunity__c, 
                          Opportunity__r.Account.Primary_Contact__r.Salutation,
                          Opportunity__r.Account.Primary_Contact__r.FirstName,
                          Opportunity__r.Account.Primary_Contact__r.LastName,
                          Opportunity__r.Account.BillingStreet,
                          Opportunity__r.Account.BillingCity,
                          Opportunity__r.Account.BillingState,
                          Opportunity__r.Account.BillingPostalCode,
                          Opportunity__r.Account.Primary_Contact__r.MailingCity,
                          Opportunity__r.Account.Primary_Contact__r.MailingState,
                          Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ,
                          Opportunity__r.Account.Primary_Contact__r.MailingStreet,
                          Opportunity__r.Payment_Reference_Number__c,
                          Opportunity__r.Override_Billing_checks__c,
                          Opportunity__r.discountsTotalOnPricing__c,
                          Opportunity__r.Manual_Bill__c,VAT_1_Total_Amount_For_Net_Price_Calc__c,VAT_4_Total_Amount_For_Net_Price_Calc__c,Net_Price_Charged_To_Customer__c,
                          Opportunity__r.Bill_to_Office__c,
                          Opportunity__r.StageName,Opportunity__r.Bill_Period__c,Opportunity__r.Installation_Date_Billing__c,
                          VAT_17_5_Total_Amount__c, POC_Payment_Method__c,ASP_Discounts__c,
                          VAT_5_Total_Amount__c,discountsTotalOnPricing__c,App_Assigned_Payroll__c,
                          Pricebook_Id__c, App_Assigned_To__c,POC_Payment_Option__c, 
                          priceMatchDifference__c,ISpec_Difference__c,Billed__c,newPriceMatchDifference__c,closeDate__c,
                          newTotalNetPrice_quote__c,
           (Select ID from Paperwork_Recieved_Details__r where Sales_Paperwork_Validated_Date__c != null),
           (Select Employee_ID__c, Employee__r.Emp_type__c From Diary_Entries__r where Employee__r.Group__c = 'INST'),                                                                      
           (Select Product_Code__c, VAT_Code__c, User_Defined_VAT_Code__c,FirstVATCode__c, Gross_Total__c, Merchant_Price__c,Total_Price__c, BigMachines_Quote__c From Quote_Products__r),
           (Select Id, Delivery_Date__c,Installation_Date__c,Status__c, Region_Code__c,Is_Downtime_Job__c,Is_Remedial_Job__c,createddate From Jobs__r where Is_Downtime_Job__c = false and Is_Remedial_Job__c = false)
            from  BigMachines_Quote__c where ID = :ASPQuote];
             
                  bmQuoteListToConsider.add(quoteToConsider);

                  c.calculateQuoteNetValueForCustomer(bmQuoteListToConsider);
                    
                    //Return success message to the user
                    return 'Success: The ASP was submitted successfully.';
                }  
                //Return error message to the user          
                else                        
                    return 'Failure: The ASP has no associated line items to submit. No action was performed.';                                                                     
            }
            //Return error message to the user                                                      
            else             
                return 'Failure: The ASP cannot be submitted as the related job is locked.';                
        }
        catch(exception e){
            System.debug('error in decomposition:-' +e);
            return 'Exception occurred: '+e.getmessage();
        }
    }       

   // Added this method for CHI CR-000462
    
    public static void createASPHistory(ASP__c asp, List<Quote_Product__c> quoteProductsRelatingToASP){
        
        ASP_History__c aspHistory = new ASP_History__c();
        List<Quote_Product_History__c> quoteProductHistoryList = new List<Quote_Product_History__c>(); 
        Quote_Product_History__c quoteProductHistory;
        
        aspHistory.Parent_ASP__c = asp.ID;
        aspHistory.Orignal_ASP_Value__c = asp.Charge_to_Customer__c;
        aspHistory.ASP_Commission_Sales_value__c = asp.ASP_Commission_Sales_value__c;
        aspHistory.Projected_Commissionable_Margin__c = asp.Projected_Commissionable_Margin__c;
        aspHistory.Average_Labour_Cost_ASP__c = asp.Average_Labour_Cost_ASP__c;
        aspHistory.Average_Material_Cost_ASP__c = asp.Average_Material_Cost_ASP__c;
        aspHistory.Commissionable_Sales_Value__c = asp.Commissionable_Sales_Value__c;
        aspHistory.Non_Commission_Sales_Value__c = asp.Non_Commission_Sales_Value__c;
        Database.Insert(aspHistory);
        
        if(quoteProductsRelatingToASP.size()>0){
            
            for(Quote_Product__c qp : quoteProductsRelatingToASP){
            
                 quoteProductHistory = new Quote_Product_History__c();
                 quoteProductHistory.name = qp.Name;
                 quoteProductHistory.ASP_History__c = aspHistory.ID;
                 quoteProductHistory.ASP_Impact__c = qp.ASP_Impact__c;
                 quoteProductHistory.Add_Remove__c = qp.ASP_Reason__c;
                 quoteProductHistory.ASP_Action__c = qp.ASP_Action__c;
                 quoteProductHistory.GrossSingle__c = qp.GrossSingle__c;
                 quoteProductHistory.Quantity__c = qp.Quantity__c;
                 quoteProductHistoryList.add(quoteProductHistory);
            
            } 
            
            Database.Insert(quoteProductHistoryList);
            
        }
        
        return;
        
    }
        
    //Populate Maps and Lists to split out the ASPs Line Items into those that are added, and those that are removed, and also split into those which affect Work and those which affect Materials
    public static void populateLineItemArrays(Quote_Product__c[] quoteProductsRelatingToASP, list<Quote_Product__c> quoteProductsRemoved, list<ID> quoteProductsRemovedIDs, list<Quote_Product__c> quoteProductsAdded, list<Quote_Product__c> materialsAddedForUDP, List<boolean> flags, Map<ID,ID> supplierIDs, Map<String,String> materialsAdded, Map<String,String> workAdded, map<string, Quote_Product__c> quanMap){     
        system.debug('quoteProductsRelatingToASP.size() is: '+quoteProductsRelatingToASP.size());
        for(integer x=0;x<quoteProductsRelatingToASP.size();x++)    {
            // Cognizant - CHI Phase III CR-005 implementation... START
            // Just added a check for User_Defined_Product__c in below if condition
            // PRB00025860 fix starts - removed the condition '!quanmap.containskey(quoteProductsRelatingToASP[x].Name)'
            if(quoteProductsRelatingToASP[x].User_Defined_Product__c==false && quoteProductsRelatingToASP[x].ASP_Reason__c=='Added' && (quoteProductsRelatingToASP[x].ASP_Action__c=='Add Parts Only' || quoteProductsRelatingToASP[x].ASP_Action__c=='Add Parts and Hours' || quoteProductsRelatingToASP[x].ASP_Action__c=='Add Parts and Extra Hours' || quoteProductsRelatingToASP[x].ASP_Action__c=='Add Hours Only')){             
            // Cognizant - CHI Phase III CR-005 implementation... END
            // PRB00025860 fix ends
            System.debug('+++Entered if condition+++');
                quoteProductsAdded.add(quoteProductsRelatingToASP[x]); 
                //If line items involves adding materials (parts) collect supplier ID also. Used to get supplier name and number later                              
                if(quoteProductsRelatingToASP[x].ASP_Action__c=='Add Parts Only' || quoteProductsRelatingToASP[x].ASP_Action__c=='Add Parts and Hours' || quoteProductsRelatingToASP[x].ASP_Action__c=='Add Parts and Extra Hours'){                        
                    materialsAdded.put(quoteProductsRelatingToASP[x].Part_Number__c,quoteProductsRelatingToASP[x].Part_Number__c);                                      
                    //If supplier field populate by the user store its details in a map. Used later to stamp supplier of materials (parts)
                    if(quoteProductsRelatingToASP[x].Supplier__c!=null)
                        supplierIDs.put(quoteProductsRelatingToASP[x].ID,quoteProductsRelatingToASP[x].Supplier__c);
                    //material changes will occur so set flag to create a Job booking history of materials affected
                    flags[0]=true;                  
                }
                //create a list of all line items added that will require work decomposition
                if(quoteProductsRelatingToASP[x].ASP_Action__c=='Add Hours Only' || quoteProductsRelatingToASP[x].ASP_Action__c=='Add Parts and Hours')
                    workAdded.put(quoteProductsRelatingToASP[x].Part_Number__c,quoteProductsRelatingToASP[x].Part_Number__c);
            }
            else if(quoteProductsRelatingToASP[x].ASP_Reason__c=='Removed' && quoteProductsRelatingToASP[x].ASP_Action__c!='Remove Extra Hours Only'){
                quoteProductsRemoved.add(quoteProductsRelatingToASP[x]);
                quoteProductsRemovedIDs.add(quoteProductsRelatingToASP[x].Id);                      
                //check if material changes will occur and if so set flag to create a Job booking history of materials affected 
                // Cognizant - CHI Phase III CR-005 implementation... START
                // Just added a check for User_Defined_Product__c in below if condition
                //if(quoteProductsRelatingToASP[x].User_Defined_Product__c==false && (quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Parts Only' || quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Parts and Hours' || quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Parts and Extra Hours'))
                if(quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Parts Only' || quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Parts and Hours' || quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Parts and Extra Hours')    
                // Cognizant - CHI Phase III CR-005 implementation... END    
                    flags[0]=true;                                      
            }
            // Cognizant - CHI Phase III CR-005 implementation... START
             
            if(quoteProductsRelatingToASP[x].User_Defined_Product__c==true && quoteProductsRelatingToASP[x].ASP_Reason__c=='Added' && quoteProductsRelatingToASP[x].ASP_Action__c=='Add Parts Only')
            {
                materialsAddedForUDP.add(quoteProductsRelatingToASP[x]);
                flags[0]=true;
            }
            // Cognizant - CHI Phase III CR-005 implementation... END
            
            //If hours have been added or removed change the status and substatus of the job
                    
            if(quoteProductsRelatingToASP[x].ASP_Action__c=='Add Hours Only' || quoteProductsRelatingToASP[x].ASP_Action__c=='Add Parts and Hours' || quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Parts and Hours' || quoteProductsRelatingToASP[x].ASP_Action__c=='Remove Hours Only')    
                flags[1]=true; 
            
        }
        
        system.debug('quoteProductsRemoved is: '+quoteProductsRemoved);
        system.debug('quoteProductsRemovedIDs is: '+quoteProductsRemovedIDs);
        system.debug('quoteProductsAdded is: '+quoteProductsAdded);
        system.debug('flags is: '+flags);
        system.debug('supplierIDs is: '+supplierIDs); 
        system.debug('materialsAdded: '+materialsAdded);
        system.debug('workAdded: '+workAdded);      
    }
                
    
    //Collect in a Map all the Part Numbers of the quote line items being added for an ASP and for each create a delimited string containing the quote line ID, quantity, and ASP Reason associated for each instance that a product line item has been included on a quote 
    //Note - This string is later split and used to created the correct number of job elements correctly associated to the right BigMachines line item ID. Using this string method reduces the number of script statements required to do this logic 
    //(as appososed to itterating over a collection whilst already itterating through a collection) 
    public static Map<String, String> tallyPartNumbersForASPs(Quote_Product__c[] TriggerQuoteProducts){
                
            Map<String, String> PartNumbersMap = new Map<String, String>();
            String ASPReason;
            String concatenatedString;     
            for(Quote_Product__c QuoteProduct:TriggerQuoteProducts){  
                //Determine whether line item requires Parts/Hours adding and if so add it to PartNumbersMap
                ASPReason = '';    
                if(QuoteProduct.ASP_Action__c=='Add Parts Only' || QuoteProduct.ASP_Action__c=='Add Parts and Extra Hours')
                    ASPReason='M'; 
                else if(QuoteProduct.ASP_Action__c=='Add Parts and Hours')
                    ASPReason='MW';    
                else if(QuoteProduct.ASP_Action__c=='Add Hours Only')
                    ASPReason='W';  
                    
                system.debug('ASPReason is: '+ASPReason);     
                if(ASPReason!=''){
                    // brm - 12-01-2010 - Force part numbers to be all upper case                                    
                    if(!PartNumbersMap.containsKey(QuoteProduct.Part_Number__c.toUpperCase()))
                        concatenatedString = ASPReason+':'+String.valueOf(QuoteProduct.Quantity__c.intValue())+':'+QuoteProduct.ID;                                             
                    else{  
                        // brm - 12-01-2010 - Force part numbers to be all upper case
                        String currentValue = PartNumbersMap.get(QuoteProduct.Part_Number__c.toUpperCase());  
                        // brm - 21-01-2010 - Split products by a tube if there is more than 1
                        concatenatedString = currentValue+'|'+ASPReason+':'+String.valueOf(QuoteProduct.Quantity__c.intValue())+':'+QuoteProduct.ID;                                        
                    }
                    // brm - 12-01-2010 - Force part numbers to be all upper case
                    PartNumbersMap.put(QuoteProduct.Part_Number__c.toUpperCase(),concatenatedString); 
                }                              
            }
            system.debug('PartNumbersMap is: '+PartNumbersMap);
            return PartNumbersMap;  
    }                                    
   
    //Construct the required work job element records and return in an array
    public static List<Job_Element__c> createProductWorkCodeJobElementsForASPs(List<Product_Work_Code__c> ProductWorkCodes, Job__c associatedJob, Map<String, String> PartNumbersMap){
     
        //Create a job element for each Product_Work_Code__c needed adding
        List<Job_Element__c> JobElementsToInsert = new List<Job_Element__c>();
        System.debug('PartNumbersMap: '+PartNumbersMap);
        for(integer x=0;x<ProductWorkCodes.Size();x++){          
            Product_Work_Code__c ProductWorkCode = ProductWorkCodes[x];        
            System.debug('Looking for: '+ProductWorkCode.Product_Code__c);
            System.debug('Found: '+PartNumbersMap.get(ProductWorkCode.Product_Code__c));                               
            //Create multiple job elements if more than 1 identical line items were added.
            String quoteProductConcatenatedString = PartNumbersMap.get(ProductWorkCode.Product_Code__c);                
            //Split the concatenated string. This will contain multiple data if more than one of the same line item was added to a quote (ie same line item added multiple times (possibly with differing quantities), not just one line item with a quantity greater than 1)
            
            // brm - 21-01-2010 - split by duplicate products
            String[] quoteProduct = quoteProductConcatenatedString.split('\\|');
            
            //String[] quoteProductInfoSplit = quoteProductConcatenatedString.split(':');
            for(integer p=0;p<quoteProduct.size();p++){
                // brm - 21-01-2010 - Split each product into parts of product info
                String[] quoteProductInfoSplit = quoteProduct[p].split(':');
                
                //Only add work if line item asp action required it adding
                if(quoteProductInfoSplit[0]=='W'||quoteProductInfoSplit[0]=='MW')
                for(integer z=0;z<double.valueOf(quoteProductInfoSplit[1]).intValue();z++){                                                                                                                                   
                    Job_Element__c newProductWorkCodeJobElement = createJobElement(ProductWorkCode.Work_Code__c, 'Work', 'Active', ProductWorkCode.Work_Code_Description__c, associatedJob, ProductWorkCode.Product_Code__c, ProductWorkCode.Hours__c,ProductWorkCode.Skill__c,quoteProductInfoSplit[2],'','');                                                                                                                            
                    JobElementsToInsert.add(newProductWorkCodeJobElement);
                }
            }
        }
        return JobElementsToInsert;
    } 
    
    
    //Construct the required materials job element records and return in an array
    public static List<Job_Element__c> createProductMaterialsJobElementsForASPs(List<Product_Materials__c> productMaterials, Job__c associatedJob, Map<String, String> PartNumbersMap, Map<ID, Supplier__c> supplierMap, Map<ID, ID> supplierIDs){
              
        List<Job_Element__c> JobElementsToInsert = new List<Job_Element__c>();                                                           
        for(integer y=0;y<productMaterials.Size();y++){                     
            Product_Materials__c productMaterial = productMaterials[y];                 
            //Create multiple seperate job elements if more than 1 identical line items were added to a quote 
            // brm - 21-01-2010 - Format of string is M:Quantity:Id| (tube is only used to seperate duplicate product codes)
            String quoteProductConcatenatedString = PartNumbersMap.get(productMaterial.Product_Code__c); 
            
            // brm - 21-01-2010 - split by duplicate products
            String[] quoteProduct = quoteProductConcatenatedString.split('\\|');
            system.debug('quoteProduct is herererere:'+quoteProduct);
            
            // brm - 21-01-2010 - Changed from p<quoteProductInfoSplit.size()/2 to use quoteProduct list
            for(integer p=0;p<quoteProduct.size();p++){
                
                // brm - 21-01-2010 - Split each product into parts of product info
                String[] quoteProductInfoSplit = quoteProduct[p].split(':');
                system.debug('quoteProductInfoSplit is :'+quoteProductInfoSplit);
                
                //Only add materials if line item asp action required it adding
                // brm - 21-01-2010 - Get the first part of product info (type of quote product asp action)
                if(quoteProductInfoSplit[0]=='M'||quoteProductInfoSplit[0]=='MW')  
                // brm - 21-01-2010 - Get the quantity of product info
                for(integer z=0;z<double.valueOf(quoteProductInfoSplit[1]).intValue();z++){ 
                    String supplierNumber='';
                    String supplierName='';
                    // brm - 21-01-2010 - Get the id of product info
                    ID lineItemID =quoteProductInfoSplit[2]; 
                        //check if line item has a supplier/merchant entered. If it did it will be in the map below                     
                    if(supplierIDs.containsKey(lineItemID)){
                        // brm - 21-01-2010 - Get the id of product info                        
                        supplierName = supplierMap.get(supplierIDs.get(quoteProductInfoSplit[2])).Name;    
                        supplierNumber = supplierMap.get(supplierIDs.get(quoteProductInfoSplit[2])).Supplier_Num__c;                            
                    }                                                                                                                                                                                                  
                    Job_Element__c newproductMaterialJobElement = createJobElement(productMaterial.Material_Code__c, 'Material', 'Active', productMaterial.Material_Description__c,AssociatedJob,productMaterial.Product_Code__c, productMaterial.Quantity__c, '',quoteProductInfoSplit[2],supplierName,supplierNumber);                                                                                
                    JobElementsToInsert.add(newproductMaterialJobElement);                                                              
                }
            }
        } 
        return JobElementsToInsert;
    }
   
        
    //Construct the required materials job element records and return in an array
    //Construct the required materials job element records and return in an array
    public static void setNewSkillHoursOnJobAndQuote(Job__c associatedJob, BigMachines_Quote__c triggerQuote, List<Job_Element__c> workJobElementsToInsert, List<Job_Element__c> jobElementsToRemove, boolean[] hoursAffected){
    
        // Cognizant - CHI Phase III CR-002 implementation... START 
        // Code fix for the PRB00007089 - by BGSAMSSupport starts  
  List<Job_Element__c> workJobElementsToInsert_noniti=new List<Job_Element__c>(); 
   List<Job_Element__c> jobElementsToRemove_noniti = new List<Job_Element__c>();
   system.debug('workJobElementsToInsert in setNewSkillHoursOnJobAndQuote '+workJobElementsToInsert);
   system.debug('jobElementsToRemove in setNewSkillHoursOnJobAndQuote'+jobElementsToRemove);
    for(Job_Element__c je:workJobElementsToInsert){ 
        String JeDesc = je.Description__c.toUpperCase();
        String JeSkill = je.Skill__c.toUpperCase();
        String JeType = je.Type__c.toUpperCase();
        system.debug('JeDesc is'+JeDesc);
        system.debug('JeSkill is'+JeSkill);
        system.debug('JeType is'+JeType);   
            
                if(!(((JeDesc.contains('SCAFFOLDING'))||(JeDesc.contains('PREMIUM INSTALLATION'))||(JeDesc.contains('WEEKEND INSTALLATION'))||
        (JeDesc.contains('ASBESTOS'))||(JeDesc.contains('WASTE COLLECTION'))||(JeDesc.contains('PRE-INSTALLATION ELECTRICAL SURVEY'))||
        (JeDesc.contains('INSTALL SOLAR PANELS'))||(JeSkill.contains('CORE CUTTING (SCOTLAND)'))||(JeSkill.contains('CARPENTRY'))||(JeSkill.contains('BESPOKE INSTALLATION WORK'))||
        (JeSkill.contains('PROFESSIONAL CLEANING')))&&(JeType.contains('WORK'))))

        {
            workJobElementsToInsert_noniti.add(je);
        }
    }
     for(Job_Element__c je1:jobElementsToRemove){ 
        
           system.debug('jobElementsToRemove in setNewSkillHoursOnJobAndQuote'+jobElementsToRemove);
           
            system.debug('jobElementsToRemove in setNewSkillHoursOnJobAndQuote'+je1);
            
        if(!(je1.P5_IsItinerary__c))
        {
            jobElementsToRemove_noniti.add(je1);
        }
    }
        AddNewSkill ObjNewSkill = new AddNewSkill(); 
          system.debug('workJobElementsToInsert_noniti'+workJobElementsToInsert_noniti);
          system.debug('jobElementsToRemove_noniti'+jobElementsToRemove_noniti);
        
       ObjNewSkill.setNewSkillHours(associatedJob, triggerQuote, workJobElementsToInsert_noniti, jobElementsToRemove_noniti, hoursAffected); 
       // Code fix for the PRB00007089 - by BGSAMSSupport ends  
        
                    
     // Cognizant - CHI Phase III CR-002 implementation... END                            
    }
    public class WebserviceException extends Exception{}
}