public class TopcallOrderGenerationPDF{
    /*
    Author                 : Cognizant
    Functionality         : This is a helper class is for the creation of the Order Dispatch pdf file and attach to the attachment objects in the Order object.
    The class acts as a controller class for the pdf generation.
    The class takes in Order Number as an argument.
    Create Date          : 26 May 2010
    Change History    :
    Modified Date     :
    */     
    
    public class FileGenarationDetails{
        public String sPageType {get;set;}
        public String sPageName {get;set;}
    }
    public List<order__c> orderLst=new List<order__c>{};
    public List<Attachment> attachmentList{get;set;}
    //Test COnstructur
    private String sJobId='';

    public PageReference GeneratePDF(){
        GeneratePDFandAttach(orderLst);
        String sURL='/'+ sJobId;
        PageReference pdfPg=new PageReference(sURL);
        pdfPg.setRedirect(true);
        return pdfPg;
    }
    
    //Default Constructor for the class
    public TopcallOrderGenerationPDF(){
        
        sJobId=System.currentPageReference().getParameters().get('jid');
        orderLst=[select order__c.Type__c,Id, Supplier__r.Name,Supplier__r.Supplier_Num__c,Status__c,Delivery_Date_Changed__c,Topcall_Fax_Status__c from order__c where Job__c=:sJobId And Status__c Not In('Cancelled','Rejected','Inactive')];    
        
    }  
    public void GeneratePDFandAttach(List<order__c> orderList){
        System.debug('$$$$$$$$$$$$$$$$$$$$$$ : ' + orderList);
       List<FileGenarationDetails>  fileDetailsList;
       attachmentList=new List<Attachment>{};
       Attachment attachment=new Attachment();
       List<order__c> privateOrderLst=new List<order__c>{};
       for (order__c objOrder:orderList) {
            if (objOrder.Type__c=='Work'){
              //CCHP116:          Installer Order
              fileDetailsList=new List<FileGenarationDetails>{};
              fileDetailsList.add(addToList('IO','CCHP116InstallerOrder'));
              /*
              fileDetailsList.add(addToList('NCHODC','NCHODeliveryChecklist'));
              fileDetailsList.add(addToList('MDC','MerchantDeliveryChecklist'));
              fileDetailsList.add(addToList('ADC','AmendedDeliveryChecklist'));
              fileDetailsList.add(addToList('IS','Installer_Specification'));
              */
              createAttachment(objOrder.Id,fileDetailsList,'Installer Order');   
              try {    
                  //CCHP120:          Resource Order
                  Order__c orderObj = [Select Supplier__r.Supplier_Num__c,Supplier__r.partner__c From order__c Where Id=:objOrder.Id];
                  String sSupplierNum=orderObj.Supplier__r.Supplier_Num__c ;
                  if(orderObj.Supplier__r.partner__c == 'Y' || orderObj.Supplier__r.partner__c == 'y'){
                      List<Diary_Entry__c> DiaryEntryList=new List<Diary_Entry__c>{};
                      DiaryEntryList=[Select Week__r.Employee__r.Employee_Number__c
                                            From Diary_Entry__c where Job__c=:sJobId 
                                            And Record_Type__c='Job Booking' And Week__r.Employee__r.Supplier__r.Supplier_Num__c=:sSupplierNum];
                      Set<String> sEmployeeNumberSet=new Set<String>{};
                      for (Diary_Entry__c objDiaryEntry:DiaryEntryList){
                        sEmployeeNumberSet.add(objDiaryEntry.Week__r.Employee__r.Employee_Number__c);   
                      }
                      for (String sEmployeeNumber:sEmployeeNumberSet){
                        String sURL='/apex/Resource_Order?id=' + objOrder.Id + '&resourceId=' + sEmployeeNumber;
                        PageReference pdfPg=new PageReference(sURL);
                        pdfPg.setRedirect(true);
                        
                        Blob blbObject=pdfPg.getContent();
                        
                        attachment=new Attachment();
                        attachment.ParentId=objOrder.Id;
                        attachment.Body=blbObject;
                        String sFileName='Resource Order - ' + sEmployeeNumber + '.pdf';
                        attachment.Name=sFileName;
                        attachment.ContentType='application/pdf';
                        attachmentList.add(attachment);      
                      }
                     }  
                      if ((sSupplierNum!='0030') && (sSupplierNum!='3163') && (sSupplierNum!='2017')){
                        fileDetailsList=new List<FileGenarationDetails>{};
                        fileDetailsList.add(addToList('CO','CCNP116ContractorOrder'));
                        createAttachment(objOrder.Id,fileDetailsList,'Contractor Order');
                      }
                 
              } catch(Exception ex){
                  //do nothing
              }
              /*    
              fileDetailsList=new List<FileGenarationDetails>{};
              fileDetailsList.add(addToList('IO','InstallerOrder'));
              createAttachment(objOrder.Id,fileDetailsList,'Resource Order');
              */
              
              //CCHP123:          Engineer's Specification     
              fileDetailsList=new List<FileGenarationDetails>{};
              fileDetailsList.add(addToList('IS','Installer_Specification'));
              createAttachment(objOrder.Id,fileDetailsList,'Installers Specification');
              
              
              
            }else if (objOrder.Type__c=='Material') {
                if ((objOrder.Status__c=='Active'||objOrder.Status__c=='Amended') && objOrder.Delivery_Date_Changed__c == true){
                List<Attachment> attachmentLst=[Select ParentId, Id From Attachment Where ParentId =:objOrder.Id];
                    if (attachmentLst!=null) {
                        delete attachmentLst;
                    }
                    fileDetailsList=new List<FileGenarationDetails>{};
                    fileDetailsList.add(addToList('CCHP190_NE','CCHP190_NE'));
                    objOrder.Topcall_Fax_Status__c='Awaiting Integration';
                    privateOrderLst.add(objOrder);
                    createAttachment(objOrder.Id,fileDetailsList,'Re-Plan Notice');
                } else {
                    List<Attachment> attachmentLst=[Select ParentId, Id From Attachment Where ParentId =:objOrder.Id];
                    if (attachmentLst!=null) {
                        delete attachmentLst;
                    }
                  //CCHP121:          Delivery Checklist
                  fileDetailsList=new List<FileGenarationDetails>{};
                  
                  fileDetailsList.add(addToList('NCHODC','CCHP121_Delivery_Checklist'));
                  /*
                  fileDetailsList.add(addToList('MDC','MerchantDeliveryChecklist'));
                  fileDetailsList.add(addToList('ADC','AmendedDeliveryChecklist'));
                  */
                  createAttachment(objOrder.Id,fileDetailsList,'Delivery Checklist');
                } 
            }       
              
        
       }
       try {
           Database.Insert(attachmentList, false);
           if (privateOrderLst.size()>0){
                Database.update(privateOrderLst, false);    
           }
       } catch(Exception ex) {
           System.debug('@Exception :' + ex.getMessage());
       }
    }
    private FileGenarationDetails addToList(String sPageType, String sPageName){
        FileGenarationDetails objFileGenarationDetails=new FileGenarationDetails();
        objFileGenarationDetails.sPageType=sPageType;
        objFileGenarationDetails.sPageName=sPageName;   
        
        return  objFileGenarationDetails;
    }
    public void createAttachment(String sOrderNo,List<FileGenarationDetails> fileDetailsList,String sPdfName){
        try {  
            Integer iCount=1;
            Attachment attachment=new Attachment();
            System.debug('##############' + fileDetailsList);
            String sFileName='';
            for (FileGenarationDetails objFileDetails:fileDetailsList) {      
                String sURL='/apex/'+ objFileDetails.sPageName +'?id=' + sOrderNo + '&pageType=' + objFileDetails.sPageType;
                PageReference pdfPg=new PageReference(sURL);
                pdfPg.setRedirect(true);
                
                Blob blbObject=pdfPg.getContent();
                
                attachment=new Attachment();
                attachment.ParentId=sOrderNo;
                attachment.Body=blbObject;
                sFileName=sPdfName + iCount + '.pdf';
                attachment.Name=sFileName;
                attachment.ContentType='application/pdf';
                attachmentList.add(attachment);
                
                iCount++;
            }     
        } catch (Exception ex) {
            System.debug('@Exception :' + ex.getMessage());    
        }
    }
}