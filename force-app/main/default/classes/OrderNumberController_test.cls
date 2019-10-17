@isTest
private class OrderNumberController_test{
 
 
    static testMethod void OrdNumCntrlr_TestMethod()
        {
             Long iStartNum=7777;
              Long iEndNum=77777; 
              Integer iIncrementNumber=33;               
            OrderNumberController OrdrNumCon = new OrderNumberController();        
            OrdrNumCon.iStartNum=null;            
            OrdrNumCon.OrderSearch();
            
            OrdrNumCon.iEndNum=null;
            OrdrNumCon.OrderSearch();
                       
            OrdrNumCon.iIncrementNumber=NULL;
            OrdrNumCon.OrderSearch();
            
            
            OrdrNumCon.iIncrementNumber=0;
            OrdrNumCon.OrderSearch();
            
                      
            OrdrNumCon.iStartNum=77;
            OrdrNumCon.iEndNum=777;
            OrdrNumCon.OrderSearch();
            
            OrdrNumCon.iStartNum=7777;
            OrdrNumCon.iEndNum=77;
            OrdrNumCon.OrderSearch();
            
            OrdrNumCon.Clear1();
            OrdrNumCon.cancel1();


            
                                                             
                    
        }
        
 }