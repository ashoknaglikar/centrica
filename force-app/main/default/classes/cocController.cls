public with sharing class cocController {
    
    public Commissioning_Report__c jcd{get;set;}
    
    public string dateofHand1 {get;set;}
    public string dateofHand2 {get;set;}
    public boolean error {get;set;}
    public string errorMsg {get;set;} 
    Utilities util = new Utilities();
    public boolean bglogo{get;set;}
    public list <Attachment> signList{get;set;}
    public boolean pdf{get;set;}    
    public id cocId{get;set;}
    public string installStreet {get; set;}
    public cocController()
    {
        id jcdId = ApexPages.currentPage().getParameters().get('jcdId');
        pdf = false;
        pdf = ApexPages.currentPage().getParameters().get('p')=='1'?true:false;
        error =false;
        errorMsg ='';
        bglogo=true;
        try{
        if(jcdId!=null)
        {
               
            
            signList = new list <Attachment>();
            signList = [Select id from Attachment where ParentId =:jcdId and (Name='cust_Sign' or Name='inst_Sign') order by Name];
           
            dateofHand1 = system.today().format();            
            dateofHand2 = system.today().format();  
                
            jcd= new Commissioning_Report__c();
            
            jcd= [Select c.micro_CHP__c, c.TT_C_D__c, c.TRV_s__c, c.Solar_thermal__c, 
                                c.Room_thermostats__c, c.Programmers__c, c.Pipes__c, c.Job_Number__c, 
                                c.Installer_For_Job_Completion__c, c.Gas_Fired__c, c.Ducting_COC__c, 
                                c.Date_of_handover_Ins__c, c.Date_of_handover_Cus__c, c.Cylinder__c, 
                                c.Customer_s_name_COC__c, c.Customer_Name_Formula__c,Notes_Coc__c,Installer_s_name2_COC__c,
                                Installers_Name1_Coc__c,Job_Number__r.Install_City__c, c.Job_Number__r.Install_Postcode__c, 
                                c.Job_Number__r.Install_Street__c,CHI_Lead_Number__c,GD_Claims_of_conformity__c,Job_Number__r.Job_Type__c,
                                Job_Number__r.Region__c,COC_Required__c,Job_Number__r.District__r.COC_Ready__c,Cylinder_Thermostat__c
                                From Commissioning_Report__c c where id =:jcdId];
            if(jcd.Installer_For_Job_Completion__c!=null)
            {
                string[] names = jcd.Installer_For_Job_Completion__c.split(',');
                    jcd.Installers_Name1_Coc__c =names[0];
                if(names.size()>1 && names[0].trim()!=names[1].trim())
                    jcd.Installer_s_name2_COC__c = names[1];
            }
            // Fix for PRB00016995 starts
            if(jcd.Customer_s_name_COC__c==null)
            {
                jcd.Customer_s_name_COC__c = jcd.Customer_Name_Formula__c;
            }  
            // Fix for PRB00016995 ends         
            installStreet  = jcd.Job_Number__r.Install_Street__c.replaceall('\n', ', ' ).replaceall('\t', '  ').replaceall('\r', ' ');
            System.debug('job type---->'+jcd.Job_Number__r.Job_Type__c);
            if(jcd.COC_Required__c == 'No')
            {
                    util.setErrorMsg(true, 'This form is not required as job is not Green Deal Finance or Affordable Warmth. Please close');
                    error = true;
                    
            }  
            if(!jcd.Job_Number__r.District__r.COC_Ready__c)
            {
                 util.setErrorMsg(true, 'This form is not valid for you.');
                error = true;
            }
            if(jcd.Job_Number__r.Region__c == 'Scotland')
            bglogo =false;
        }
        }catch (exception e)
        {
            pdf= false;
        } 
       
    }
    
    public pagereference saverecord()
    {
        system.debug('----1'+jcd.Job_Number__c);
        if(jcd.COC_Required__c == 'No')
        {
                util.setErrorMsg(true, 'This form is not required as job is not Green Deal Finance or Affordable Warmth. Please close');
                system.debug('----2');
                return null;
        }
        if(jcd.GD_Claims_of_conformity__c==null)
        {
                util.setErrorMsg(true, 'Please enter status.');
                system.debug('----3');
                return null;
        }
        if(jcd.GD_Claims_of_conformity__c =='Completed- Electronically')
        {
        String enInstValue = Apexpages.currentPage().getParameters().get('encInst');
        String enCustValue = Apexpages.currentPage().getParameters().get('encCust');
        String dateinst = Apexpages.currentPage().getParameters().get('date1');
        String datecust = Apexpages.currentPage().getParameters().get('date2');
        string [] temp;
        if(dateinst!=null && dateinst.contains('/'))
        {
        temp = dateinst.split('/') ;
        dateofHand1 =temp[2]+'-'+temp[1]+'-'+temp[0];
        }else if(dateinst!=null && dateinst.contains('-'))
        {
            dateofHand1= dateinst;
        }else
        {
            util.setErrorMsg(true, 'Please enter both Handover dates');
            return null;
        }
        
        
        if(datecust!=null && datecust.contains('/'))
        {
        temp = datecust.split('/') ;
        dateofHand2 =temp[2]+'-'+temp[1]+'-'+temp[0];
        }else if(datecust!=null && datecust.contains('-'))
        {
            dateofHand2 =datecust;
        }
        else
        {
            util.setErrorMsg(true, 'Please enter both Handover dates');
            return null;
        }
        system.debug(enInstValue+enInstValue);
        if(enInstValue!=null && enCustValue!=null)
        {
                system.debug('----4');
                if(!enInstValue.contains('+') )
                {
                        util.setErrorMsg(true, 'Please make sure that Installer has signed');
                        system.debug('----5');
                        return null;
                        
                        
                }
                if(!enCustValue.contains('+'))
                {
                        util.setErrorMsg(true, 'Please make sure that Customer has signed');
                        system.debug('----6');
                        return null;
                       
                }
        }
        try{
        system.debug('Installer sign-->'+dateofHand1);
        system.debug('Installer sign-->'+dateofHand2);
        jcd.Date_of_handover_Ins__c = date.valueof(dateofHand1) ;
        jcd.Date_of_handover_Cus__c = date.valueof(dateofHand2) ;
        update jcd;
       
        string cSign = enCustValue.split(',').get(1);
        string iSign = enInstValue.split(',').get(1);
        
        //system.debug('/apex/cocForm1?pdf=1&jcdId='+jcd.Id+'&i='+iSign+'&c='+custSign);
        
        system.debug('----7');
        Attachment cAttachment = new Attachment(Body = EncodingUtil.base64Decode(cSign),
                                                Name = 'cust_Sign',
                                                ParentId = jcd.Id,
                                                isPrivate = false,
                                                ContentType = 'image/jpg',
                                                Description = 'Customers Signature');
        Attachment iAttachment = new Attachment(Body = EncodingUtil.base64Decode(iSign),
                                                Name = 'inst_Sign',
                                                ParentId = jcd.Id,
                                                isPrivate = false,
                                                ContentType = 'image/jpg',
                                                Description = 'Installer Signature');
        signList.add(cAttachment);
        signList.add(iAttachment);
        

        insert signList;
        
        
        pagereference p = new pagereference('/apex/cocForm1?p=1&jcdId='+jcd.Id);
        p.setredirect(true);
        return p;
        
        }catch(Exception E)
        {
                system.debug('Error  while saving JCD:'+e.getmessage());
                util.setErrorMsg(true, 'Something went wrong please contact administrator');//+e.getmessage()+dateinst);
        }
        }else
        {
             update jcd;
             return (new pagereference('/'+jcd.Id));
        }
        
      return null;
        
    }
    
    public pagereference cancel()
    {
        return new pagereference('/'+jcd.Id);
    }
    
    public void methodtest()
    {
        if(pdf)
        {
        try{
        PageReference pdfPage =page.cocFormPdf;
            //putting id of custom object in parm id so that I can read it to fetch records
        pdfPage.getParameters().put('jcdId',jcd.id);
        
        pdfPage.setRedirect(true);
        Blob pdfBlob = pdfPage.getContent();
            
        Attachment cocPdf = new Attachment(Body = pdfBlob,
                                            Name = 'Claims Of Conformity.pdf',
                                            ParentId = jcd.Id,
                                            isPrivate = false,
                                            contenttype='.pdf'
                                            );
                                                                                
            try{                                                                        
                    insert cocPdf;
                    if(signList.size()>0)
                    delete signList;
                    pdf =true;
                    cocId = cocPdf.id;
                    util.setErrorMsg(false, 'Sucessfully Saved!');
            }
            catch (exception e)
            {
                    system.debug('Error  while saving JCD:'+e.getmessage());
                    util.setErrorMsg(true, 'Something went wrong please contact system admin!');
            }
        
        }   
        catch(Exception e)
        {
            system.debug('Error  while saving JCD:'+e.getmessage());
            util.setErrorMsg(false, 'Click back button');
            
            return;
        }
        
        }
        
        
       
        
        
    }
  

}