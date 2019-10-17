global class updateQuoteAvgHours implements Database.Batchable<sObject> {

   
   public static void invokeBatch()
   {
       updateQuoteAvgHours sendApp = new updateQuoteAvgHours();
       ID batchprocessid = Database.executeBatch(sendApp);
   }
   
   global string QuoteRec;
   
   
   global Database.QueryLocator start(Database.BatchableContext BC){     
           
          Boolean Check = TRUE;  
          string startDate = system.label.StartDate;
          datetime CDate;
          datetime now;
          if(startDate != 'of')
          {
          CDate= date.valueof(system.label.StartDate.split(':')[0]);
          now = CDate.adddays(integer.valueof(system.label.StartDate.split(':')[1]));
          }else
          {
          CDate = system.today();
          now= system.now();
          }
          
          
          string QuoteRec= 'select id,name,Billed__c,Other_Skills_Avg_Cost__c,Avg_Mechanical_Cost__c,Avg_Electrical_Cost__c,Avg_Building_Cost__c,Avg_Roofwork_Cost__c,Avg_PowerFlush_Cost__c,Actual_Building_Work_Cost__c,Actual_Electrical_Cost__c,Actual_Labour_Cost__c,All_Other_skills_Actual_Cost__c,Actual_Material_Cost__c,Actual_Powerflush_Cost__c,Actual_Roof_Work_Cost__c,Acual_Mechanical_Cost__c,Average_Labour_Cost_Quote__c,Average_Material_Cost_Quote__c,Is_Calc_Avg_Lab_Mat_Cost_On_Quote__c,Opportunity__c,Product_Type_ID__c, Opportunity__r.Install_Postcode__c,(select id,name,BigMachines_Quote__c,Non_Commision_Pack__c,part_number__c,Quantity__c from Quote_Products__r) from BigMachines_Quote__c'+
                            ' where'+' createdDate'+'>='+':CDate'+' AND createdDate'+'<='+':now AND New_Finance_Calculation_Done__c = false'; 
          system.debug('----->'+QuoteRec);
          return Database.getQueryLocator(QuoteRec);
    }   

     
   global void execute(Database.BatchableContext BC, List<BigMachines_Quote__c> BGQuote){
    
      
      Map<Id,Map<String,Integer>> CallLabMet = new Map<Id,Map<String,Integer>>();
      Map<String, Integer> QuoteProductMap;
      
      Integer qty = 0;  
      set<string> productTypeList = new set<string> ();
      set<string> postCodeList = new set<string>();
      set<string> finalProductCodeList = new set<string>(); 
      
      for(BigMachines_Quote__c BGQ: BGQuote)
      {
          productTypeList.add(BGQ.Product_Type_Id__c);
          postCodeList.add(BGQ.Opportunity__r.Install_Postcode__c.substring(0,BGQ.Opportunity__r.Install_Postcode__c.length()-2));
            
         
          QuoteProductMap = new Map<String, Integer>();
          
          
           for(Quote_Product__c QP: BGQ.Quote_Products__r){
               
               finalProductCodeList.add(QP.part_number__c);
             
               if(QuoteProductMap.containsKey(QP.part_number__c)){
                      qty = QuoteProductMap.get(QP.part_number__c);
                      qty=qty+(QP.Quantity__c).intValue();
                      QuoteProductMap.put(QP.part_number__c,qty);
               }
               else{                
                  QuoteProductMap.put(QP.part_number__c,(QP.Quantity__c).intValue()); 
               } 
             
           }
              
           CallLabMet.put(BGQ.Id,QuoteProductMap); 
      }
      map<string, string> postcodDistMap = new map<string, string>();
      for(Postcode_sector__c p: [select id, Sub_Patch__r.District__c, Name from Postcode_Sector__c where name in :postCodeList and Type__c = 'Installation' ])
      {
          postcodDistMap.put(p.Name,p.Sub_patch__r.District__c);
      }
      
         if(CallLabMet.size()>0){
           calLabourCost(CallLabMet,  productTypeList,postcodDistMap, BGQuote, finalProductCodeList);
         } 
          
      
      
     
        
   }
  
  global void finish(Database.BatchableContext BC){
  
  }
  
  public static void calLabourCost(Map<Id,Map<String, Integer>> QuoteProductMap, set<string> productTypeList, map<string, string> postcodDistMap,  List<BigMachines_Quote__c> BGQuote, set<string> finalProductCodeList)
  { 
        system.debug('INSIDE CALL LABOUR COST');
        list<BigMachines_Quote__c> updatelist = new list<BigMachines_Quote__c>();
        
        List<string> District;
        List<String> Product_Type;
        String Skill;
        String hoursStr;
        String skillUpper;
        Map<String,Integer> Pcode = new Map<String,Integer>();
        
          
        Map<String, String> ProductWorkCodeMap = new Map<String, String>();             
        
        //Retrieve ProductWorkCode information for the Quote Products
        List<Product_Work_Code__c> ProductWorkCodes = [Select Work_Code__c, Skill_Type__c,Skill__c, Hours__c, Product_Code__c From Product_Work_Code__c 
        where Product_Code__c in :finalProductCodeList AND (Start_Date__c <= :date.today() AND End_Date__c >= :date.today()) AND (Active__c = True)];
        
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
        
         
        District = new List<Id>();
        Product_Type = new List<String>();
            
        District.addall(postcodDistMap.values());
        Product_Type.addall(productTypeList);
           
        system.debug('District Product Type:'+District+''+Product_Type);
          //Get the Map having info of rate of skills in a particular District
        map<string, map<string , Map<String, Double>>> SkillRatePerDistrictMapTemp = getSkillRatePerDistrict(District,Product_Type);
          
          /*  Material Calculation data retrival Starts*/
        List< Product_Materials__c > ProductMaterials  = [Select Quantity__c, Product_Code__c, Material_Code__c From Product_Materials__c 
        where Product_Code__c in :finalProductCodeList AND (Start_Date__c <= :date.today() AND End_Date__c >= :date.today()) AND (Active__c = True)] ;
        Set<string> Setproductcode = new Set<string>();
        Map<String, String> ProductMaterialMap = new Map<String, String>();        
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
        }
        
        Map<String, Double> NWACPerMaterialMap = new Map<String, Double>();
        if(Setproductcode.size()>0)
        {
            NWACPerMaterialMap = QuoteProductDecompileHelper.getNWACForMaterial(Setproductcode);
            
        }
          
          system.debug('=-=-=-='+SkillRatePerDistrictMapTemp);
          for(BigMachines_Quote__c b : BGQuote)
          {
              Double Product_Material_Cost = 0;
              Double Product_Labour_Cost = 0; 
              Double Product_Mechanical_Cost = 0;
              Double Product_Electrical_Cost = 0;
              Double Product_Building_Cost = 0;
              Double Product_Roofwork_Cost = 0;
              Double Product_Powerflush_Cost = 0;
        
              Map<String, Double> SkillRatePerDistrictMap = new  Map<String, Double>();
              if(SkillRatePerDistrictMapTemp.Containskey(postcodDistMap.get(b.Opportunity__r.Install_Postcode__c.substring(0,b.Opportunity__r.Install_Postcode__c.length()-2))))
              {
                  Map<String, Double> WithProductIdMap = new  Map<String, Double>();
                  Map<String, Double> WithOutProductIdMap = new  Map<String, Double>();
                  Map<string , Map<String, Double>> tempMap =  SkillRatePerDistrictMapTemp.get(postcodDistMap.get(b.Opportunity__r.Install_Postcode__c.substring(0,b.Opportunity__r.Install_Postcode__c.length()-2)));
                  if(tempMap.containskey(b.Product_Type_Id__c))
                  WithProductIdMap = tempMap.get(b.Product_Type_Id__c);
                  
                  WithOutProductIdMap =tempMap.get('null');
                  
                  for(string s : WithProductIdMap.keyset())
                  {
                      WithOutProductIdMap.put(s, WithProductIdMap.get(s));
                  }
                  
                  SkillRatePerDistrictMap = WithOutProductIdMap;
              }
              if(QuoteProductMap.containsKey(b.Id))
              for(string ProductCode: QuoteProductMap.get(b.id).keyset())
              {
                map<string, integer> tempMap = new map<string, integer>();
                tempmap = QuoteProductMap.get(b.Id);
                if(ProductWorkCodeMap.containskey(ProductCode))
                {
                    System.debug('Calculating Labour Cost For Product ' + ProductCode);
                    
                    String[] strList = (ProductWorkCodeMap.get(ProductCode)).split('/');
                    Integer qtyTotal = tempmap.get(ProductCode);
                    Double Avg_Labour_Cost ; 
                    Double Avg_Mechnaical_Cost ;
                    Double Avg_PowerFlush_Cost;
                    Double Avg_Electrical_Cost;
                    Double Avg_Building_Cost;
                    Double Avg_Roofwork_Cost;
                    
                    // Initialitializing for each product
                    Avg_Labour_Cost = 0; 
                    Avg_Mechnaical_Cost = 0;
                    Avg_PowerFlush_Cost = 0;
                    Avg_Electrical_Cost = 0;
                    Avg_Building_Cost = 0;
                    Avg_Roofwork_Cost = 0;                     
                    
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
                        system.debug('&&&&&&&&&&&&'+SkillRatePerDistrictMap.get(Skill));
                        if(Skill.contains('MECHANICAL')&& SkillRatePerDistrictMap.get(Skill) != NULL)   //CAL Actual Mechanical Hours                       
                          Avg_Mechnaical_Cost = Avg_Mechnaical_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill)); 
                        else if(Skill.contains ('WATER HEATER FIXING')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));       
                        else if(Skill.contains ('SPECIALIST BUILDING')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('SPECIALIST BUILDING WORK')&& SkillRatePerDistrictMap.get(Skill) != NULL) 
                         Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill)); 
                        else if(Skill.contains ('SCAFFOLDER')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost +(Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));     
                        else if(Skill.contains ('ROOF WORK')&& SkillRatePerDistrictMap.get(Skill) != NULL) //CAL Actual Roof WOrk Hours 
                         Avg_RoofWork_Cost = Avg_RoofWork_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('PAYMENT COLLECTION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('ELECTRICAL')&& SkillRatePerDistrictMap.get(Skill) != NULL) //CAL Actual Electric Hours 
                          Avg_Electrical_Cost = Avg_Electrical_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('LPG INSTALLATION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('FIREWALL HEATER FIXING')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                        Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('CONTRACTOR INSTALLATION')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill)); 
                        else if(Skill.contains ('CONNECT SOLAR PANELS')&& SkillRatePerDistrictMap.get(Skill) != NULL)
                          Avg_Labour_Cost = Avg_Labour_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('BUILDING WORK')&& SkillRatePerDistrictMap.get(Skill) != NULL) //CAL Actual Building Hours 
                          Avg_Building_Cost = Avg_Building_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
                        else if(Skill.contains ('POWERFLUSH')&& SkillRatePerDistrictMap.get(Skill) != NULL) //CAL Actual Power flush Hours 
                         Avg_PowerFlush_Cost = Avg_PowerFlush_Cost + (Double.valueOf(hoursStr) * SkillRatePerDistrictMap.get(Skill));
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
                        Product_Mechanical_Cost = Product_Mechanical_Cost + Avg_Mechnaical_Cost * qtyTotal;
                        Product_Electrical_Cost = Product_Electrical_Cost + Avg_Electrical_Cost * qtyTotal;
                        Product_Building_Cost = Product_Building_Cost + Avg_Building_Cost * qtyTotal;
                        Product_Roofwork_Cost = Product_Roofwork_Cost + Avg_Roofwork_Cost * qtyTotal;
                        Product_Powerflush_Cost = Product_Powerflush_Cost + Avg_PowerFlush_Cost * qtyTotal;
                        //ProductLabourCost = Product_Labour_Cost+':'+Product_Mechanical_Cost+':'+Product_Electrical_Cost+':'+Product_Building_Cost+':'+Product_Roofwork_Cost+':'+Product_Powerflush_Cost;  
                        System.debug(' Final Labour cost in calLabourCost'+ Product_Labour_Cost); 
                  }
                  
                  if(NWACPerMaterialMap.size()>0)
                  {   
                    if( ProductMaterialMap.containskey(ProductCode) )
                      {
                        String[] strList = (ProductMaterialMap.get(ProductCode)).split('/');
                        double qtyTotal = tempmap.get(ProductCode);
                        System.debug('Finding NWAC for '+ ProductCode + 'Having quantity ' + qtyTotal);
                        // Initialitializing for each product
                        double Avg_Material_Cost = 0;                    
                        Double MaterialNWAC = 0;
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
           
           
           BigMachines_Quote__c bm = new BigMachines_Quote__c();         
           bm.Other_Skills_Avg_Cost__c = Product_Labour_Cost;
           bm.Avg_Mechanical_Cost__c = Product_Mechanical_Cost;
           bm.Avg_Electrical_Cost__c = Product_Electrical_Cost;
           bm.Avg_Building_Cost__c = Product_Building_Cost;
           bm.Avg_Roofwork_Cost__c = Product_Roofwork_Cost;
           bm.Avg_PowerFlush_Cost__c = Product_Powerflush_Cost;
           bm.Average_Material_Cost_Quote__c = Product_Material_Cost;
           bm.Average_Labour_Cost_Quote__c = Product_Labour_Cost+Product_Mechanical_Cost+Product_Electrical_Cost+Product_Building_Cost+Product_Roofwork_Cost+Product_Powerflush_Cost;
           bm.New_Finance_Calculation_Done__c = true;
           bm.Id = b.Id;
           updatelist.add(bm);        
          }
          Lock.jobTriggerSwitch = true;
          cls_IsRun.generalTriggerSwitch = true;
          cls_IsRun.dontFireTriggers = true;
          if(updatelist.size()>0)
          update updatelist;
          System.debug('ProductWorkCodeMap.size() '+ ProductWorkCodeMap.size()  );  
          
      }             
        
            
    
            
       public static map<string, map<string , Map<String, Double>>>  getSkillRatePerDistrict(List<Id> District, List<string> Product_Type)
       {
            map<string, map<string , Map<String, Double>>> retrunMap = new map<string, map<string , Map<String, Double>>>();
            map<string , Map<String, Double>> ProductTypeMap = new map<string , Map<String, Double>>();
            
            System.debug('Entering getSkillRatePerDistrict For District :' + District);
            Map<String, Double> SkillRatePerDistrictNullMap = new Map<String, Double>();
            Map<String, Double> SkillRatePerDistrictProdMap = new Map<String, Double>();
            String SkillUpper; 
            Double Rate = 0.0;
            List<Avg_Skill_Rate__c> SkillRatePerDistrict =  [Select a.Skill__c, a.Rate__c ,Product_Type_ID__c, District__c From Avg_Skill_Rate__c a where a.District__c = :District and (Product_Type_ID__c = :Product_Type or Product_Type_ID__c = null)];
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
                    ProductTypeMap.put(SkillRate.Product_Type_ID__c, SkillRatePerDistrictProdMap);
                    retrunMap.put(SkillRate.District__c, ProductTypeMap);
                }
                else{                                
                    SkillRatePerDistrictNullMap.put(SkillUpper.toUpperCase().replaceAll('/', '_') , Rate);
                    ProductTypeMap.put('null', SkillRatePerDistrictNullMap);
                    retrunMap.put(SkillRate.District__c, ProductTypeMap);
                    
                    
                }
             }
             system.debug('retrunMap----->'+retrunMap); 
           
                  
        }
        return retrunMap;
    }     
            
      

  
}