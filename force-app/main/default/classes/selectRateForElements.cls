/*
*   AUTHOR       :  COGNIZANT
*   DATE CREATED :  15 JUNE
*   DESCRIPTION  :  THIS CLASS IS RESPONSIBLE FOR QUERYING MULTIPLE OBJECTS TO POPULATING ELEMENT RATES PER SUPPLIER BASIS
*/
public class selectRateForElements{
    
    // VARIABLE TO ACCESS SKILL TYPE VS RATE CARD SKILL MATCH
    
    private Map<String,List<Job_Element__c>> vanStockElementMap=new Map<String,List<Job_Element__c>>{};
    public Map<String,List<Job_Element__c>> getVanStockElementMap(){
        return vanStockElementMap;
    }
    public void setVanStockElementMap(Map<String,List<Job_Element__c>> value){
        vanStockElementMap=value;
    }
    
    private Map<String,List<Job_Element__c>> notVanStockElementMap=new Map<String,List<Job_Element__c>>{};
    public Map<String,List<Job_Element__c>> getNotVanStockElementMap(){
        return notVanStockElementMap;
    }
    public void setNotVanStockElementMap(Map<String,List<Job_Element__c>> value){
        notVanStockElementMap=value;
    }
    
    //Non Orderable Element
    private Map<String,List<Job_Element__c>> nonOrderableElementMap=new Map<String,List<Job_Element__c>>{};
    public Map<String,List<Job_Element__c>> getNonOrderableElementMap(){
        return nonOrderableElementMap;
    }
    public void setNonOrderableElementMap(Map<String,List<Job_Element__c>> value){
        nonOrderableElementMap=value;
    }
    
    private Map<String,List<Job_Element__c>> orderableElementMap=new Map<String,List<Job_Element__c>>{};
    public Map<String,List<Job_Element__c>> getOrderableElementMap(){
        return orderableElementMap;
    }
    public void setOrderableElementMap(Map<String,List<Job_Element__c>> value){
        orderableElementMap=value;
    }
    
    
    
    public Map<String,Map<String,Post_Code_Skill_Rate__c>> postCodeSkillRateMap{get;set;}
    public Map<String,Map<String,Rate_Card_Items__c>> rateCardItemMap{get;set;}
              
    public Map<String,String> findBranchNum(List<String> supplierNumLst, String sRegion, String sPostCode){
        Map<String,String> branchMap=new Map<String,String>{};
        for (Supplier_Region_Supplier_Branch__c objBranch1: [Select BranchNum__c,Region__c,Supplier_Branch__r.Supplier_Num__c 
                                                                From Supplier_Region_Supplier_Branch__c Where 
                                                                Supplier_Branch__r.Supplier_Num__c In: supplierNumLst
                                                                And Region__c=:sRegion]) {
            branchMap.put(objBranch1.Supplier_Branch__r.Supplier_Num__c,objBranch1.BranchNum__c);                
               System.debug('maggi21'+ branchMap) ;
              System.debug('maggi23'+ objBranch1) ;
        }
        
        for (Post_Code_Supplier_Branch__c objBranch2: [Select Branch_Num__c,Postcode_Sector__c,Supplier_Branch__r.Supplier_Num__c 
                                                                From Post_Code_Supplier_Branch__c 
                                                                Where Supplier_Branch__r.Supplier_Num__c In: supplierNumLst
                                                                And Postcode_Sector__c=:sPostCode]){
            branchMap.put(objBranch2.Supplier_Branch__r.Supplier_Num__c,objBranch2.Branch_Num__c); 
             System.debug('maggi22'+ branchMap);   
              System.debug('maggi24'+ objBranch2);            
        }    System.debug('maggi26'+branchMap );
        return branchMap;
        
    }
    
   
   
        
    public void fetchWorkSupplierRate(Set<String> suppNumSet,Map<String,Map<String,List<Job_Element__c>>> w_JobElementMap,
                                                                        String postCodeSec,String Region, string District){
                                                                            
        postCodeSkillRateMap=new Map<String,Map<String,Post_Code_Skill_Rate__c>>{};
        Map<String,Post_Code_Skill_Rate__c> postCodeSkillMap;
        rateCardItemMap=new Map<String,Map<String,Rate_Card_Items__c>>{};
        //Map<String,Map<String,List<Double>>> SupplierRateCardWorkMap=new Map<String,Map<String,List<Double>>>{};
        List<String> sRateCardLst=new List<String>{};
        
        Map<String,List<String>> rateCardMap=new Map<String,List<String>>{};
        //code fix done by BGSAMS Support for too many soql - starts
        List<Post_Code_Rate_Card__c> regionandpostcodelist =[Select Postcode_Sector__c, Region__c, Rate_Card__c,NationalRate__c,District__c, Post_Code_Rate_Card_Ext_Id__c, Id,Rate_Card__r.Supplier_Num__c ,
                                                    (Select Skill__c, Cost__c, Preference__c From Post_Code_Skill_Rates__r) 
                                                    From Post_Code_Rate_Card__c 
                                                    Where ((Region__c=:Region OR NationalRate__c = true) OR Postcode_Sector__c=:postCodeSec OR District__c = :District )
                                                    And Rate_Card__r.Supplier_Num__c In:suppNumSet];                                                   
                               
        List<Post_Code_Skill_Rate__c> rateCardSkillLst=new List<Post_Code_Skill_Rate__c>{};
        for (Post_Code_Rate_Card__c objRegionCard:regionandpostcodelist){
        if ((objRegionCard.Region__c==Region)|| objRegionCard.NationalRate__c == true)
        {
             //code fix done by BGSAMS Support for too many soql - ends  
            //rateCardSkillLst=new List<Post_Code_Skill_Rate__c>{};
            for (Post_Code_Skill_Rate__c objPostCodeSkillRate:objRegionCard.Post_Code_Skill_Rates__r) {
                postCodeSkillMap=new Map<String,Post_Code_Skill_Rate__c>{};
               
                if (!postCodeSkillRateMap.containsKey(objRegionCard.Rate_Card__r.Supplier_Num__c)){
                    
                    postCodeSkillMap.put(objPostCodeSkillRate.Skill__c,objPostCodeSkillRate);
                    postCodeSkillRateMap.put(objRegionCard.Rate_Card__r.Supplier_Num__c,postCodeSkillMap);      
                }else{
                        /*
                            Change: National Contractor Rates Change. If we dont have any rates defined at region or district level then we go 
                            for National rates. I.E Post_Code_Rate_Card__c where NationalRate__c = True.
                              
                        */
                        postCodeSkillMap=postCodeSkillRateMap.get(objRegionCard.Rate_Card__r.Supplier_Num__c);
                        if(!postCodeSkillMap.containskey(objPostCodeSkillRate.Skill__c))
                        {
                            postCodeSkillMap.put(objPostCodeSkillRate.Skill__c,objPostCodeSkillRate);
                        }   
                        else if(postCodeSkillMap.containskey(objPostCodeSkillRate.Skill__c) && objRegionCard.NationalRate__c ==false)
                        {
                            postCodeSkillMap.remove(objPostCodeSkillRate.Skill__c);
                            postCodeSkillMap.put(objPostCodeSkillRate.Skill__c,objPostCodeSkillRate);
                        }
                        
                        postCodeSkillRateMap.put(objRegionCard.Rate_Card__r.Supplier_Num__c,postCodeSkillMap);
                    
                }
            }
            //code fix done by BGSAMS Support for Rate card issue - starts
            List<String> lstRateCard=new List<String>{};
            lstRateCard.add(objRegionCard.Rate_Card__c);
            rateCardMap.put(objRegionCard.Rate_Card__r.Supplier_Num__c,lstRateCard);
            
           /* List<String> lstRateCard=new List<String>{};
            if (rateCardMap.containsKey(objRegionCard.Rate_Card__r.Supplier_Num__c)) {
                lstRateCard=rateCardMap.get(objRegionCard.Rate_Card__r.Supplier_Num__c);
                lstRateCard.add(objRegionCard.Rate_Card__c);
                rateCardMap.put(objRegionCard.Rate_Card__r.Supplier_Num__c,lstRateCard);
            } else {
                lstRateCard.add(objRegionCard.Rate_Card__c);
                rateCardMap.put(objRegionCard.Rate_Card__r.Supplier_Num__c,lstRateCard);
            }*/
            
            //code fix done by BGSAMS Support for Rate card issue - ends
        }
        }
       
       for (Post_Code_Rate_Card__c objPostCodeCard:regionandpostcodelist){
            if (objPostCodeCard.District__c==District){
                 //code fix done by BGSAMS Support for too many soql - ends  
            //rateCardSkillLst=new List<Post_Code_Skill_Rate__c>{};
            for (Post_Code_Skill_Rate__c objPostCodeSkillRate1:objPostCodeCard.Post_Code_Skill_Rates__r) {
                postCodeSkillMap=new Map<String,Post_Code_Skill_Rate__c>{};
                if (!postCodeSkillRateMap.containsKey(objPostCodeCard.Rate_Card__r.Supplier_Num__c)){
                    postCodeSkillMap.put(objPostCodeSkillRate1.Skill__c,objPostCodeSkillRate1);
                    postCodeSkillRateMap.put(objPostCodeCard.Rate_Card__r.Supplier_Num__c,postCodeSkillMap);        
                }else{
                    postCodeSkillMap=postCodeSkillRateMap.get(objPostCodeCard.Rate_Card__r.Supplier_Num__c);
                    postCodeSkillMap.put(objPostCodeSkillRate1.Skill__c,objPostCodeSkillRate1);
                    postCodeSkillRateMap.put(objPostCodeCard.Rate_Card__r.Supplier_Num__c,postCodeSkillMap);
                }
            }
            //code fix done by BGSAMS Support for Rate card issue - starts
            List<String> lstRateCard=new List<String>{};
            lstRateCard.add(objPostCodeCard.Rate_Card__c);
            rateCardMap.put(objPostCodeCard.Rate_Card__r.Supplier_Num__c,lstRateCard);
            //code fix done by BGSAMS Support for Rate card issue - ends
        }
       }        
           //code fix done by BGSAMS Support for too many soql - starts     
        //List<Post_Code_Skill_Rate__c> rateCardSkillLst=new List<Post_Code_Skill_Rate__c>{};
        for (Post_Code_Rate_Card__c objPostCodeCard:regionandpostcodelist){
            if (objPostCodeCard.Postcode_Sector__c==postCodeSec){
                 //code fix done by BGSAMS Support for too many soql - ends  
            //rateCardSkillLst=new List<Post_Code_Skill_Rate__c>{};
            for (Post_Code_Skill_Rate__c objPostCodeSkillRate1:objPostCodeCard.Post_Code_Skill_Rates__r) {
                postCodeSkillMap=new Map<String,Post_Code_Skill_Rate__c>{};
                if (!postCodeSkillRateMap.containsKey(objPostCodeCard.Rate_Card__r.Supplier_Num__c)){
                    postCodeSkillMap.put(objPostCodeSkillRate1.Skill__c,objPostCodeSkillRate1);
                    postCodeSkillRateMap.put(objPostCodeCard.Rate_Card__r.Supplier_Num__c,postCodeSkillMap);        
                }else{
                    postCodeSkillMap=postCodeSkillRateMap.get(objPostCodeCard.Rate_Card__r.Supplier_Num__c);
                    postCodeSkillMap.put(objPostCodeSkillRate1.Skill__c,objPostCodeSkillRate1);
                    postCodeSkillRateMap.put(objPostCodeCard.Rate_Card__r.Supplier_Num__c,postCodeSkillMap);
                }
            }
            //code fix done by BGSAMS Support for Rate card issue - starts
            List<String> lstRateCard=new List<String>{};
            lstRateCard.add(objPostCodeCard.Rate_Card__c);
            rateCardMap.put(objPostCodeCard.Rate_Card__r.Supplier_Num__c,lstRateCard);
            
            
            /*List<String> lstRateCard=new List<String>{};
            if (rateCardMap.containsKey(objPostCodeCard.Rate_Card__r.Supplier_Num__c)) {
                lstRateCard=rateCardMap.get(objPostCodeCard.Rate_Card__r.Supplier_Num__c);
                lstRateCard.add(objPostCodeCard.Rate_Card__c);
                rateCardMap.put(objPostCodeCard.Rate_Card__r.Supplier_Num__c,lstRateCard);
            } else {
                lstRateCard.add(objPostCodeCard.Rate_Card__c);
                rateCardMap.put(objPostCodeCard.Rate_Card__r.Supplier_Num__c,lstRateCard);
            }*/
            //code fix done by BGSAMS Support for Rate card issue - ends
        }       
        }
        
        for (String sSupNum:suppNumSet){
            if (rateCardMap.containskey(sSupNum)){
                sRateCardLst.addAll(rateCardMap.get(sSupNum));
            }
        }
        //sRateCardLst=rateCardMap.values();
        System.debug('£££££££££££££££££:' + sRateCardLst);
        
        List<Rate_Card__c> rateCardLst=[Select Supplier_Num__c, Rate_Card_Type__c, P5_Supplier__c, Id, 
                                            (Select Cost__c, Work_Order__r.Work_Code__c,Work_Order__c, Status__c From Rate_Card_Items__r Where Status__c='Active') 
                                            From Rate_Card__c Where Id In:sRateCardLst And Rate_Card_Type__c>0 order by Supplier_Num__c];
        
        Map<String,Rate_Card_Items__c> RateCardItemInnerMap=new Map<String,Rate_Card_Items__c>{};
          
        for (Rate_Card__c objRateCard:rateCardLst){
            for (Rate_Card_Items__c objRateCardItem:objRateCard.Rate_Card_Items__r){
                RateCardItemInnerMap=new Map<String,Rate_Card_Items__c>{};
                if (!rateCardItemMap.containsKey(objRateCard.Supplier_Num__c)){
                    RateCardItemInnerMap.put(objRateCardItem.Work_Order__r.Work_Code__c,objRateCardItem);
                    rateCardItemMap.put(objRateCard.Supplier_Num__c,RateCardItemInnerMap);  
                } else {
                    RateCardItemInnerMap=rateCardItemMap.get(objRateCard.Supplier_Num__c);  
                    RateCardItemInnerMap.put(objRateCardItem.Work_Order__r.Work_Code__c,objRateCardItem);
                    rateCardItemMap.put(objRateCard.Supplier_Num__c,RateCardItemInnerMap);
                }   
            }
        }
        System.debug('%%%%%%%%%% :' + rateCardItemMap);
    }
        
    public Map<String,Map<String,Rate_Card_Items__c>> fetchMaterialSupplierRate(Set<String> suppNumSet,
                                                                                Map<String,List<Job_Element__c>> m_JobElementMap,
                                                                                String postCodeSec,String Region,String sDistrict){

        

        Set<String> itemCodeSet1=m_JobElementMap.keySet();
        Map<String,Rate_Card_Items__c> RateCardItemMap=new Map<String,Rate_Card_Items__c>{};
        Map<String,Map<String,Rate_Card_Items__c>> SupplierRateCardItemMap= new Map<String,Map<String,Rate_Card_Items__c>>{};
        Map<String,List<String>> customCodeMap=new Map<String,List<String>>{};
        List<String> sCodeLst=new List<String>{};
        Map<String,Map<String,String>> SupplierMaterialCustomCodeMap=new Map<String,Map<String,String>>{}; 
        Map<String,String> MaterialCustomCode=new Map<String,String>{};
        //code fix done by BGSAMS Support for too many soql - starts
        List <Supplier_Custom_Material_Code__c>tempvar = [Select Supplier__c, Region__c, District__c, Custom_Material_Code__c,
                                                                Supplier_Num__c,Material_Code__c 
                                                                From Supplier_Custom_Material_Code__c Where Supplier_Num__c In:suppNumSet
                                                                 AND ((Region__c = null AND District__c= null) OR Region__c=:Region OR District__c=:sDistrict) Order By Supplier_Num__c];
                
        for (Supplier_Custom_Material_Code__c objSuppMatCode:tempvar) {
            if (objSuppMatCode.Region__c == null && objSuppMatCode.District__c == null){
        //code fix done by BGSAMS Support for too many soql - ends
            sCodeLst=new List<String>{};
            if (customCodeMap.containsKey(objSuppMatCode.Material_Code__c)){
                sCodeLst=customCodeMap.get(objSuppMatCode.Material_Code__c);
                sCodeLst.add(objSuppMatCode.Custom_Material_Code__c);
            }else{
                sCodeLst.add(objSuppMatCode.Custom_Material_Code__c);
            }                                                   
            customCodeMap.put(objSuppMatCode.Material_Code__c,sCodeLst);
            
            MaterialCustomCode=new Map<String,String>{};    
            if (!SupplierMaterialCustomCodeMap.containsKey(objSuppMatCode.Supplier_Num__c)){
                MaterialCustomCode.put(objSuppMatCode.Custom_Material_Code__c,objSuppMatCode.Material_Code__c);
                SupplierMaterialCustomCodeMap.put(objSuppMatCode.Supplier_Num__c,MaterialCustomCode);   
            }else {
                MaterialCustomCode=SupplierMaterialCustomCodeMap.get(objSuppMatCode.Supplier_Num__c);
                MaterialCustomCode.put(objSuppMatCode.Custom_Material_Code__c,objSuppMatCode.Material_Code__c);
                SupplierMaterialCustomCodeMap.put(objSuppMatCode.Supplier_Num__c,MaterialCustomCode);   
           
            } 
            }
        }
        //code fix done by BGSAMS Support for too many soql - starts
        for (Supplier_Custom_Material_Code__c objSuppMatCode:tempvar) {
            if (objSuppMatCode.Region__c == Region){
        //code fix done by BGSAMS Support for too many soql - ends
            sCodeLst=new List<String>{};
            if (customCodeMap.containsKey(objSuppMatCode.Material_Code__c)){
                sCodeLst=customCodeMap.get(objSuppMatCode.Material_Code__c);
                sCodeLst.add(objSuppMatCode.Custom_Material_Code__c);
            }else{
                sCodeLst.add(objSuppMatCode.Custom_Material_Code__c);
            }                                                   
            customCodeMap.put(objSuppMatCode.Material_Code__c,sCodeLst);
            
            MaterialCustomCode=new Map<String,String>{};    
            if (!SupplierMaterialCustomCodeMap.containsKey(objSuppMatCode.Supplier_Num__c)){
                MaterialCustomCode.put(objSuppMatCode.Custom_Material_Code__c,objSuppMatCode.Material_Code__c);
                SupplierMaterialCustomCodeMap.put(objSuppMatCode.Supplier_Num__c,MaterialCustomCode);   
            }else {
                MaterialCustomCode=SupplierMaterialCustomCodeMap.get(objSuppMatCode.Supplier_Num__c);
                MaterialCustomCode.put(objSuppMatCode.Custom_Material_Code__c,objSuppMatCode.Material_Code__c);
                SupplierMaterialCustomCodeMap.put(objSuppMatCode.Supplier_Num__c,MaterialCustomCode);   
            }
            }
        }
        
        
        //code fix done by BGSAMS Support for too many soql - starts
        for (Supplier_Custom_Material_Code__c objSuppMatCode: tempvar) {
            if (objSuppMatCode.District__c==sDistrict){
        //code fix done by BGSAMS Support for too many soql - ends
            sCodeLst=new List<String>{};
            if (customCodeMap.containsKey(objSuppMatCode.Material_Code__c)){
                sCodeLst=customCodeMap.get(objSuppMatCode.Material_Code__c);
                sCodeLst.add(objSuppMatCode.Custom_Material_Code__c);
            }else{
                sCodeLst.add(objSuppMatCode.Custom_Material_Code__c);
            }                                                   
            customCodeMap.put(objSuppMatCode.Material_Code__c,sCodeLst);
            
            MaterialCustomCode=new Map<String,String>{};    
            if (!SupplierMaterialCustomCodeMap.containsKey(objSuppMatCode.Supplier_Num__c)){
                MaterialCustomCode.put(objSuppMatCode.Custom_Material_Code__c,objSuppMatCode.Material_Code__c);
                SupplierMaterialCustomCodeMap.put(objSuppMatCode.Supplier_Num__c,MaterialCustomCode);   
            }else {
                MaterialCustomCode=SupplierMaterialCustomCodeMap.get(objSuppMatCode.Supplier_Num__c);
                MaterialCustomCode.put(objSuppMatCode.Custom_Material_Code__c,objSuppMatCode.Material_Code__c);
                SupplierMaterialCustomCodeMap.put(objSuppMatCode.Supplier_Num__c,MaterialCustomCode);   
           
            } 
            }
        } 
        Set<String> itemCodeSet=new Set<String>{};
        for (String sTemp:itemCodeSet1){
            if (!customCodeMap.containsKey(sTemp)){
                itemCodeSet.add(sTemp); 
            }else {
                itemCodeSet.addAll(customCodeMap.get(sTemp));
            }
        }
        
        
        for (Rate_Card__c objRateCard:[Select Supplier_Num__c,P5_Supplier__c,Rate_Card_Type__c,
                                        (Select Material__c,Material__r.Product_Code__c,Material__r.Rebate__c,Cost__c,Status__c
                                        From Rate_Card_Items__r Where Status__c='Active' and Material__r.Product_Code__c In:itemCodeSet) 
                                        From Rate_Card__c Where Supplier_Num__c In:suppNumSet And Rate_Card_Type__c=0 order by Supplier_Num__c]){
            
            for (Rate_Card_Items__c objRateCardItem:objRateCard.Rate_Card_Items__r){
                MaterialCustomCode=new Map<String,String>{};
                RateCardItemMap=new Map<String,Rate_Card_Items__c>{};
                if (!SupplierRateCardItemMap.containsKey(objRateCard.Supplier_Num__c)){
                    if (!SupplierMaterialCustomCodeMap.containsKey(objRateCard.Supplier_Num__c)){
                        RateCardItemMap.put(objRateCardItem.Material__r.Product_Code__c,objRateCardItem);   
                    } else {
                        MaterialCustomCode=SupplierMaterialCustomCodeMap.get(objRateCard.Supplier_Num__c);
                        if (!MaterialCustomCode.containsKey(objRateCardItem.Material__r.Product_Code__c)){
                            RateCardItemMap.put(objRateCardItem.Material__r.Product_Code__c,objRateCardItem);
                        } else {
                            RateCardItemMap.put(MaterialCustomCode.get(objRateCardItem.Material__r.Product_Code__c),objRateCardItem);
                        }   
                    }   
                    //RateCardItemMap.put(objRateCardItem.Material__r.Product_Code__c,objRateCardItem);
                } else {
                    if (!SupplierMaterialCustomCodeMap.containsKey(objRateCard.Supplier_Num__c)){
                        RateCardItemMap=SupplierRateCardItemMap.get(objRateCard.Supplier_Num__c);
                        RateCardItemMap.put(objRateCardItem.Material__r.Product_Code__c,objRateCardItem);
                    } else {
                        MaterialCustomCode=SupplierMaterialCustomCodeMap.get(objRateCard.Supplier_Num__c);
                        if (!MaterialCustomCode.containsKey(objRateCardItem.Material__r.Product_Code__c)){
                            RateCardItemMap=SupplierRateCardItemMap.get(objRateCard.Supplier_Num__c);
                            RateCardItemMap.put(objRateCardItem.Material__r.Product_Code__c,objRateCardItem);
                        } else {
                            RateCardItemMap=SupplierRateCardItemMap.get(objRateCard.Supplier_Num__c);
                            RateCardItemMap.put(MaterialCustomCode.get(objRateCardItem.Material__r.Product_Code__c),objRateCardItem);
                        }   
                    }
                    //RateCardItemMap=SupplierRateCardItemMap.get(objRateCard.Supplier_Num__c);
                    //RateCardItemMap.put(objRateCardItem.Material__r.Product_Code__c,objRateCardItem);
                }
                SupplierRateCardItemMap.put(objRateCard.Supplier_Num__c,RateCardItemMap);
            }
        }
        
        return SupplierRateCardItemMap; 
    }
    
    /* Below method is commented as this no more used in the system. this method is replaced with the new method below.
        'segregateVanstockElementsByRegion' please read the comments below for better understaning. */
      
     public void segregateVanstockElements(Map<String,List<Job_Element__c>> m_JobElementMap, Boolean blVanstock){
        if (blVanstock){
            List<Product_Order__c> productOrderLst=[Select Van_Stock__c,Product_Code__c from Product_Order__c 
                                                    where Product_Code__c In:m_JobElementMap.keySet() And Van_Stock__c=true];
            for (Product_Order__c objProductOrder: productOrderLst){
                if(m_JobElementMap.containsKey(objProductOrder.Product_Code__c)){
                    vanStockElementMap.put(objProductOrder.Product_Code__c,m_JobElementMap.get(objProductOrder.Product_Code__c));
                    m_JobElementMap.remove(objProductOrder.Product_Code__c);        
                }
            }
        }
        notVanStockElementMap=m_JobElementMap;
    }
    
    /* vanstock change begin. 18/05/11
        This method works same as above but it sees the vanstock value on product order, supplier to segregate according to region.
    */  
    
    public void segregateVanstockElementsByRegion(Map<String,List<Job_Element__c>> m_JobElementMap, Decimal maxVanStockValue){
        if (maxVanStockValue > 0)
        {
            List<Product_Order__c> productOrderLst=[Select Van_Stock__c,Product_Code__c,Van_Stock_Value__c from Product_Order__c 
                                                    where Product_Code__c In:m_JobElementMap.keySet() And Van_Stock_Value__c >= 1 And Van_Stock_Value__c <= :maxVanStockValue and Van_Stock_Value__c != 0 and Van_Stock_Value__c != null];
            for (Product_Order__c objProductOrder: productOrderLst){
                if(m_JobElementMap.containsKey(objProductOrder.Product_Code__c)){
                    vanStockElementMap.put(objProductOrder.Product_Code__c,m_JobElementMap.get(objProductOrder.Product_Code__c));
                    m_JobElementMap.remove(objProductOrder.Product_Code__c);        
                }
            }
        }    
        notVanStockElementMap=m_JobElementMap;
    }
    /*
        This method segregates the non Orderable Component in the Job Element
    */
    public void segregateNonOrderableComponent(Map<String,List<Job_Element__c>> m_JobElementMap){
        List<Product_Order__c> productOrderLst=[Select ORDER_FLAG__c,Product_Code__c from Product_Order__c 
                                                    where Product_Code__c In:m_JobElementMap.keySet() And ORDER_FLAG__c='N'];
        for (Product_Order__c objProductOrder: productOrderLst){
            if(m_JobElementMap.containsKey(objProductOrder.Product_Code__c)){
                nonOrderableElementMap.put(objProductOrder.Product_Code__c,m_JobElementMap.get(objProductOrder.Product_Code__c));
                m_JobElementMap.remove(objProductOrder.Product_Code__c);        
            }
        }    
        orderableElementMap=m_JobElementMap;
    }
     
       /* 
       This method was added as a part of Vanstock Change.
       This method will select the max Vanstock value from list of suppliers from the Supplier Region Vanstock value
       and return only the value. 
       */
   public decimal fetchMaxVanstockvalue(set<string> suppIdSet, string regionId){
        system.debug('Supp numbers--->'+suppIdSet);
        system.debug('Region Id--->'+regionId);
        
        list<Supplier_Region_Van_Stock_Value__c> suppRegVanstockLst = new list<Supplier_Region_Van_Stock_Value__c>();
        decimal maxVanstockVal = 1;
        if(suppIdSet.size()>0 && regionId!= null)
        {
            suppRegVanstockLst = [Select Van_Stock_Value__c from Supplier_Region_Van_Stock_Value__c where Region__c =:regionId and Supplier_Number_Lookup__c in :suppIdSet];
            system.debug('list of suppRegVanstockLst--->'+suppRegVanstockLst);
            for(Supplier_Region_Van_Stock_Value__c s : suppRegVanstockLst)
            {
                if(s.Van_Stock_Value__c != null && s.Van_Stock_Value__c > maxVanstockVal)
                {
                    maxVanstockVal = s.Van_Stock_Value__c;
                }
            }
            
        }
        return maxVanstockVal;
    }
}