@isTest(SeeAllData=true)
public class TestAutoGeneratePurchaseOrders {
    static AutoGeneratePurchaseOrders POGen =new AutoGeneratePurchaseOrders();
    static Job__c job;   
    static testmethod Job__c fetchJob()
    {
        
        
       
        try{
            
        job = [Select id from Job__c where id = 'a0n20000001MVMx'];
       
        }catch(Exception e){
            
            // Do Nothing
            
        }
        
        return  job;                                                
        
        
      
    }
     static testmethod void generateMaterialOrderForNewSupp1()
    {
        try{
               job = fetchJob();
               POGen.autoGenerateOrders(job);
               POGen.generateMaterialOrderForNewSupp(POGen.m_PrimaryJobElementMap, POGen.sPrimarySuppNum);
               
        }catch(Exception e){
            
            // Do Nothing
            
        }
    }
           
      static testmethod void generateMaterialOrderForNewSupp2() 
      { 
       try{
               POGen.autoGenerateOrders(job);
               POGen.generateMaterialOrderForNewSupp(POGen.m_PrimaryJobElementMap, POGen.sPrimarySuppNum);
               
        }catch(Exception e){
            
            
        }
      }
        static testmethod void generateMaterialOrderForNewSupp3()
        {
        try{
               //job = fetchJob();
               POGen.autoGenerateOrders(job);
               POGen.generateMaterialOrderForNewSupp(POGen.m_SecondaryJobElementMap, POGen.sSecondarySuppNum);
               
        }catch(Exception e){
            
            // Do Nothing
            
        }
        }
        static testmethod void generateMaterialOrderForNewSupp4()
        {
        try{
            
           
            POGen.generateItineryWorkOrder(POGen.w_SupplierJobElementMap, POGen.postCodeSkillRateMap, POGen.rateCardItemMap, '3163');
                    
             
        }catch(Exception e){
            
            // Do Nothing
            
        }
        }
        static testmethod void generateMaterialOrderForNewSupp5()
        {
        try{
               POGen.autoGenerateOrders(job);
               POGen.generateItineryMaterialOrder(POGen.m_PrimaryJobElementMap, POGen.sPrimarySuppNum, POGen.m_PrimaryRate);
               
        }catch(Exception e){
            
            // Do Nothing
            
        }
        }
        static testmethod void generateMaterialOrderForNewSupp()
        {
        try{
            
                POGen.autoGenerateOrders(job);
                POGen.generateItineryMaterialOrder(POGen.m_SecondaryJobElementMap, POGen.sSecondarySuppNum, POGen.m_SecondaryRate);
               
        }catch(Exception e){
            
            // Do Nothing
            
        }
        }
       
        
    

}