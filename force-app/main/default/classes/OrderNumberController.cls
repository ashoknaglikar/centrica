/*
Type Name: OrderNumberController 
Author: Cognizant
Created Date: 21/05/2010
Reason:This controller is used to insert new SAP Number record in a given range of numbers by SAP
Change History:
*/

public class OrderNumberController
{
    public Long iStartNum{ get; set;}
    public Long iEndNum{ get; set;}
    public Integer iIncrementNumber{get;set;}
    static final Integer lmt = 2000;

    public OrderNumberController() 
    {
    // this is constructor
        iIncrementNumber=1;
    }
    
    Public PageReference OrderSearch()
    {
        /* This method checks for the existing record in the given range, 
            if it doesnt exists then creates the new record */
            if(iStartNum==null)
            {
                ApexPages.Message msg1 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter start number');        
                ApexPages.addMessage(msg1);
                
            }
            if(iEndNum==null)
            {
                ApexPages.Message msg2 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter end number');        
                ApexPages.addMessage(msg2);
            }
            if (iIncrementNumber==null){
                ApexPages.Message msg3 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter incremental value');        
                ApexPages.addMessage(msg3);
            
            } else if (iIncrementNumber<=0) {
                ApexPages.Message msg4 = new ApexPages.Message(ApexPages.Severity.ERROR, 'Incremental value should be greater than zero');        
                ApexPages.addMessage(msg4);
            }
            if(iStartNum<iEndNum)
            {   Long lnCount=[select count() from SAP_Number__c where SAP_Num_Ord__c>=:iStartNum and SAP_Num_Ord__c<=:iEndNum];
                  if (lnCount>0) 
                {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'SAP number already exists');        
                    ApexPages.addMessage(msg);
                }
                else
                {
                    GenerateSAPOrderNumber.reconcile(iStartNum,iEndNum,iIncrementNumber);
                }
            }
            else 
            {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Start Number should be smaller than End Number');        
                ApexPages.addMessage(msg);
            }
            return null;
     }        
    public PageReference cancel1()
    {
        PageReference pageRef1 = new PageReference('/home/home.jsp');
        return pageRef1;
    }
    Public  PageReference Clear1()
    {
        PageReference pageRef = new PageReference('/apex/SearchOrderNumber');
        return pageRef;
    }
}