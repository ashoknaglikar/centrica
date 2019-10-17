/*
*
*  CLASS -  AspEnhanced
*  AUTHOR - 22 Oct 2013, Cognizant
*  PURPOSE - To Enhance the functionality of ASP
* 
*/

public class  AspEnhanced 
{
    public ASP__c asp{get;set;}
    public string BigMachineId;
    
    public string aspId{get;set;}
    integer orderqp =1;
    list<Quote_Product__c> listExistingPQ;
  
    Utilities util = new Utilities();
    
    public boolean sec1{get;set;} 
    public boolean sec2{get;set;}
    public boolean sec3{get;set;}
    public boolean sec4{get;set;}
    public boolean sec5 {get;set;}
    public boolean sec6 {get;set;}
  
    public boolean addTable{get;set;}
    public boolean udpTable{get;set;}
    
      
    public boolean chgBtn{get;set;}  
    public boolean canBtn{get;set;}
    public boolean updBtn{get;set;}
    public boolean udpBtn {get;set;}
    public boolean cnfBtn{get;set;}  
    public boolean valBtn {get;set;}
    public boolean subBtn {get;set;}
    public boolean addBtn {get;set;}
    public boolean creNew{get;set;}
    public boolean aspSec{get;set;}
    public boolean mateRem{get;set;}
    public boolean showReqItm{get;set;}
    public boolean showJob{get;set;}
    public boolean savBtn{get;set;}
    public boolean showField{get;set;}
    public boolean showMaterialInfo{get;set;}
    boolean editMode = false;
   
    public boolean conf {get;set;}
    
    public list <quoteproductClass> amendmeList {get;set;}
    public list <quoteproductClass> userDefinedList {get;set;}
    public list <quoteproductClass> FullList {get;set;}
    public list <quoteproductClass> showList{get;set;}
    public list <ASP__c> existingASP {get;set;}
    public decimal totalVal {get;set;}
    public list<ASP_Requested_Items__c> requestedItems{get;set;}
    public string reqPrdId{get;set;}
    
   
    public Job__c job{get;set;}
    public list<Job__c> jobList{get;set;}
    public BigMachines_Quote__c bmQuote {get;set;}
    
    public decimal discount {get;set;}
    
    map<string, Quote_Product__c> addMap;
    map<string, Quote_Product__c> removeMap;
    map<string, Quote_Product__c> existingMap;
    map<string, Quote_Product__c> oldRemoveMap;
    map<string, Quote_Product__c> showMap;
    map<id,ASP_Requested_Items__c> reqProdMap;
    quoteproductClass discountClass ;
    public Product2 disountProd = new Product2();
    string retUrl; 
    boolean aspView=false;
    string chiId ='';
    
    //added for asp hours
    public String ASPHours{get;set;}
    public boolean showAspHours{get;set;}
    public List<List<String>> ASPHoursList{get;set;}
    
    public string alertMessage{get;set;}
    
    // ASP Acknowledement Changes:
    public decimal customePaymentVar {get;set;}
    public decimal suggestedPayment {get;set;}
    decimal partRefunded=00;
    decimal partAdded=00;
    public AspEnhanced(ApexPages.StandardController controller)
    {
        try{
        totalVal=0.0;  
        customePaymentVar= suggestedPayment = 0.0; 
        mateRem = false;
        disountProd = [Select id,Name from Product2 where Name = 'D001']; 
        discount = 0.00;
        asp = new ASP__c(); 
        amendmeList = new list <quoteproductClass>();
        userDefinedList = new list <quoteproductClass>();
        FullList = new list <quoteproductClass>();
        showList = new list <quoteproductClass>();
        addMap = new map<string, Quote_Product__c>();
        removeMap = new map<string, Quote_Product__c>();
        showMap = new map<string, Quote_Product__c>();
        addTable = false;
        
        //code added for asp hours
        showAspHours = false;
        
        existingASP = new list<ASP__c>();
        existingMap = new  map<string, Quote_Product__c> ();
        oldRemoveMap  = new  map<string, Quote_Product__c> ();
        requestedItems = new list<ASP_Requested_Items__c>();
        reqProdMap = new map<id, ASP_Requested_Items__c>();
        retUrl = '';
        //canBtn =true;
        string aspId = system.currentPageReference().getParameters().get('id');
        retUrl = system.currentPageReference().getParameters().get('retURL');
        chiId = system.currentPageReference().getParameters().get('chiId');
        string editstring = system.currentPageReference().getParameters().get('edit');
        if(chiId!=null)
        {
            bmQuote = [Select id,Opportunity__c, Billed__c from BigMachines_Quote__c where opportunity__c = :chiId and is_Primary__c = true];
            BigMachineId = bmQuote.Id;
            retUrl = bmQuote.Id;
            
        }
        
        editMode = true;
        job = new Job__c();
        jobList = new list<Job__c>();
        if(aspId!=''&& aspId!=null)
        {
            populateASP(aspId);
            valBtn = false;
            subBtn = true;
            /*
            if(asp.Lock__c)
            {
                
                util.setErrorMsg(false, 'No futher Updates are allowed on this ASP.');
                subBtn = false;
                sec4=true;
                sec6=true;
                canBtn=true;
                return;
            }*/
            if(asp.Status__c == 'Submitted')
            {
                subBtn = false;
                editMode = false;
                canBtn = false;
                chgBtn =false;
                creNew =false;
            }
            
            aspView = true;
            aspSec = false;
        }
        
        system.debug('Returl--->'+retUrl);
        canBtn =true;
        if(retUrl != '' && retUrl!=null && editMode || editstring =='1')
        {
            
            editMode = true;
            //sec1 = true;
            if(retUrl=='' ||retUrl==null)
            retUrl = asp.Quote__c;
            
        }else 
        {
            editMode = false;
            sec4 = true;
            sec6 = true;
            valBtn = false;
            
            
        }
        
        if(editMode)
        {
            if(retUrl!=null)
            {
                if(retUrl.contains('/'))
                {
                    system.debug('I am here');
                    retUrl = retUrl.right(retUrl.length()-1).trim();
                    if(retUrl.length()>16)
                    {
                        retUrl = retUrl.substring(0,15);
                    }
                    id temp = retUrl;
                    asp.Quote__c= temp;
                    retUrl = asp.Quote__c;
                    BigMachineId= asp.Quote__c;        
                }
                else
                {
                    retUrl = retUrl.trim();
                    asp.Quote__c =retUrl; 
                    BigMachineId= asp.Quote__c;
                }
            }else if(asp!=null)
            {
                 BigMachineId= asp.Quote__c;
            }
        }
        if(BigMachineId!=null)
        {
            system.debug('Big Machines-->'+BigMachineId);
            bmQuote = new BigMachines_Quote__c();
            
            bmQuote = [Select id,Opportunity__c,Opportunity__r.Name, Billed__c , (select id,Name, ASP_Date__c,Status__c,Picklist__c,Charge_to_Customer__c,  Lock__c,
                      Description__c/*,Asp_Billing_Status__c*/ from ASPs__r order by CreatedDate Desc)from BigMachines_Quote__c where id = :BigMachineId];
            if( bmQuote.ASPs__r.size()>0 )
            {
                if(!aspView)
                {
                    aspSec =true;
                    creNew =true;
                    showField = true;
                    for(ASP__c asp: bmQuote.ASPs__r)    
                    {
                        if(asp.Status__c == 'Entered')
                        creNew =false;
                        
                        existingASP.add(asp);
                    }    
                }else if(editstring =='1')
                {
                 sec1 = true;
                 updBtn =true;
                 sec3 = false;   
                 if(asp.Status__c=='Entered')
                 {
                     sec2 =true;
                     sec3=true;
                     addBtn =true;
                     udpBtn = true;
                     cnfBtn = true;
                     //canBtn =true;
                     subBtn= false;
                    
                 }    
                }else
                {
                    if(showList.size()==0&& userDefinedList.size()==0)
                    {
                        subBtn = false;
                        canBtn =false;
                    }   
                    
                }    
                    
            }else
            {
                showField =true;
                aspSec =false;
                sec1 = true;
                valBtn =true;
                if(aspView && showList.size()==0&& userDefinedList.size()==0)
                {
                    subBtn = false;
                    canBtn =false;
                }   
            }  
            
            if(editstring=='1')
            {
                if(asp.Status__c == 'Entered')
                {
                    popReuestedItems();
                    if(requestedItems.size()>0)
                         showReqItm =true;
                }        
            }  
            
            try{
                job = [select id, Name , GDIndicator__c, Status__c,Sub_Status__c, Installation_Date__c, Customer_Preferred_Date__c, District__c, CHI_Lead__r.AccountId ,CHI_Lead__r.Account.Primary_Contact__c from Job__c where Quote__c = : BigMachineId and Is_Downtime_Job__c=false and Is_Remedial_Job__c =false and  Secondary_Job_Type_New__c=null limit 1];
            }catch(Exception e)
            {
                util.setErrorMsg(true, 'No Primary Job on this Quote.');
                sec1 =false;
                valBtn =false;
                return;
            }
            
            
          
            //listPQ = new list<Quote_Product__c>();
            
            listExistingPQ =  [select Id,Materials__c ,ASP__c, ASP_Reason__c ,  quotingReason__c, ASP_Impact__c,GrossSingle__c,Labour__c,Product__r.Information_Only__c, Name, Product__r.Description, Product__r.Name, Product_Description__c, User_Defined_Product__c, Product__c, Part_Number__c, Quantity__c, Unit_Price_Inc_VAT__c,ASP_Action__c,Gross_Total__c ,  Sales_Price__c, User_Defined_Description__c,Order__c,Product__r.Adding_Alert__c,Product__r.Removing_Alert__c,Customer_Charged_Refunded__c  from Quote_Product__c where BigMachines_Quote__c = :BigMachineId and Product__r.Information_Only__c != 'Yes' and ASP_Reason__c != 'Removed' And Name != 'D001' order by Name];
            
            for(Quote_Product__c q: listExistingPQ)
            {
                if(asp.Id ==null || q.Asp__c != asp.Id)
                {
                    quoteproductClass qpc= new quoteproductClass(q);
                    FullList.add(qpc);
                    existingMap.put(q.Name, q);
                }
            }
        
        }
        
    if(retUrl==null || retUrl=='')
    retUrl=bmQuote.Opportunity__c  ; 
    
    if(aspView)
    canBtn =false;
    
    if(editMode)
    canBtn =true;
    }catch (exception e)
    {
        seterror(e);
    }
      
    }
    
    private void populateASP(id aspId)
    {
        discount = 0.0;
        amendmeList = new list<quoteproductClass>();
        showList = new list<quoteproductClass>();
        userDefinedList = new list<quoteproductClass>();
        addMap = new map<string, Quote_Product__c>();
        removeMap = new map<string, Quote_Product__c>();
        showMap = new map<string, Quote_Product__c>();
        oldRemoveMap = new map<string, Quote_Product__c>();
        asp =[Select a.Status__c, a.Quote__c, a.Picklist__c, a.Name, a.Material_Return_Info__c, a.Id, a.Function__c,Lock__c,Request_For_ASP__c, 
                  a.Description__c, a.Definition__c, a.ASP_Type__c,Approved_By__c, a.ASP_Date__c, Charge_to_Customer__c ,ASP_Total__c, Material_Notes__c,
                  (select Id,Materials__c ,Labour__c,Sales_Price__c, Name, Product_Description__c, Product__c, Part_Number__c,
                  Quantity__c,ASP_Reason__c,ASP_Impact__c,GrossSingle__c,ASP_Action__c,Description__c ,Unit_Price_Inc_VAT__c,Unit_Merchant_Price_Exc_VAT__c,ASP__c,Gross_Total__c , User_Defined_Description__c,Order__c,
                  Supplier__c,Product__r.Adding_Alert__c,Product__r.Removing_Alert__c,Customer_Charged_Refunded__c   from Quote_Products__r order by Order__c),Quote_ASP_Unsubmitted_Total__c,Balancing_Cost_Change__c,Person_Approved_By__c,a.Asp_Billing_Status__c From ASP__c a where id = :aspId];
            
        if(asp.Quote_Products__r.size()>0)
        {
            for(Quote_Product__c qp : asp.Quote_Products__r)
            {
                if(qp.Name == 'UDPQP')
                continue;
                if(qp.ASP_Reason__c=='Added')
                {
                
                    amendmeList.add(new quoteproductClass(qp));
                    addMap.put(qp.Name,qp);
                    
                    if(qp.Name==disountProd.Name)
                    {
                        discountClass = new quoteproductClass(qp);
                        discount +=qp.ASP_Impact__c;
                    }
                    
                }
                else if(qp.ASP_Reason__c=='Removed')
                {
                    oldremoveMap.put(qp.Name,qp);
                    quoteproductClass qps = new quoteproductClass(qp);
                    qps.Quantity = qp.Quantity__c;
                    amendmeList.add(qps);
                }
                //showList.add(new quoteproductClass(qp));
            }   
            
            for(string qp:oldremoveMap.keyset())
            {
                
                if(addmap.containskey(qp))
                {
                    removeMap.put(qp,addmap.get(qp));
                    addmap.remove(qp);
                }   
            }
            for(Quote_Product__c qp : asp.Quote_Products__r)
            {
                if(qp.Name == 'UDPQP')
                {
                     userDefinedList.add(new quoteproductClass(qp));
                     udpTable =true;
                }
                else if(oldRemoveMap.containskey(qp.Name) && removeMap.containskey(qp.Name) )
                {
                    decimal showQuan = oldRemoveMap.get(qp.Name).Quantity__c - removeMap.get(qp.Name).Quantity__c;
                    decimal aspImp = oldRemoveMap.get(qp.Name).ASP_Impact__c + removeMap.get(qp.Name).ASP_Impact__c;
                    boolean lab, mat=false;
                    Quote_Product__c qpTem = oldRemoveMap.get(qp.Name);
                    if(qpTem.ASP_Action__c.contains('Parts and Hours'))
                    {
                        lab=true;
                        mat=true;
                    }else if(qpTem.ASP_Action__c.contains('Parts Only'))
                    {
                        lab=false;
                        mat=true;
                    }
                    else if(qpTem.ASP_Action__c.contains('Hours Only'))
                    {
                        lab=true;
                        mat=false;
                    }
                    
                    
                    quoteproductClass qpsNew = new quoteproductClass(new Quote_Product__c(Name=qp.Name, ASP_Reason__c='Removed',  Product__c =qp.Product__c, ASP_Action__c = 'Remove Parts and Hours',
                                                    Materials__c= mat, Labour__c = lab,Quantity__c =showQuan, ASP_Impact__c= aspImp));
                    qpsNew.descript = qp.Product_Description__c;
                    if(!showMap.containskey(qp.Name))
                    {                               
                        showList.add(qpsNew);
                        showMap.put(qp.Name, qp);
                    }
                        
                    
                } else
                {
                    showList.add(new quoteproductClass(qp));
                }   
            }     
        }
        
        BigMachineId =  asp.Quote__c;
        list<quoteproductClass> templist = new list<quoteproductClass>();
        
        if(asp.ASP_Total__c!=null)
        {
            totalVal = asp.ASP_Total__c;
            
        }else
        {
            templist.addall(amendmeList);
            templist.addall(userDefinedList);
            totalVal = calTotal(templist);
            system.debug('After CAl-->'+totalVal);
        }
        if(asp.Status__c == 'Submitted')
        {
            //canBtn= false;
            subBtn =false;
        }
        
        if(amendmeList.size()>0)
        addTable = true;
        
        if(userDefinedList.size()>0)
        udpTable =true;
        
    }
    
    public void popReuestedItems()
    {
        sec3=true;
        if(asp.Request_For_ASP__c!=null)
        {
            reqProdMap = new map<id,ASP_Requested_Items__c>([select Id,Product__c,Product__r.Name,Quantity__c,Product_Description__c,Action__c,Processed__c from ASP_Requested_Items__c where   ASP_Request__c = :asp.Request_For_ASP__c]);
            requestedItems = reqProdMap.values();
            
            if(requestedItems.size()>0)
            {
                showReqItm =true;
                for(ASP_Requested_Items__c asr: requestedItems)
                {
                    if(!asr.processed__c)
                    {
                        sec3=false;
                        break;
                    }
                }
                
            }
            
        }
    }
    
    public void confirm ()
    {
        try{
        if(asp.Charge_to_Customer__c == null)
        {
            util.setErrorMsg(true, 'Please Enter Charge to Customer.');
            return;
        }
        
                      
        
        if(asp!=null)
        asp.ASP_Hours__c = aspHours;
        update asp;
        ASP__c tempasp = queryASP(asp.Id);
        
        if(tempasp.Balancing_Cost_Change__c!=0)
        {
            addDiscount();
        }
        
        
        if(amendmeList.size()>0 || userDefinedList.size()>0)
        {
            list<Quote_Product__c> updatingList = new list<Quote_Product__c>();
            
            for(quoteproductClass qps: amendmeList)
            {
                system.debug('Product-- Name-->'+qps.qp.Product__c);
                if(qps.qp.Name != disountProd.Name )
                {
                    for(quoteproductClass sh: showList)
                    {
                        if(qps.qp.Name==sh.qp.Name)
                        {
                        qps.qp.Labour__c = sh.qp.Labour__c;
                        qps.qp.Materials__c = sh.qp.Materials__c;
                        break;
                        }
                    }
                    if(qps.qp.ASP_Reason__c == 'Added')
                    {
                        
                        qps.qp.ASP_Action__c = 'Add Parts and Hours';
                        if(!qps.qp.Materials__c && !qps.qp.Labour__c)
                        {
                            util.setErrorMsg(true, 'Invalid Action either Labour or Material Should be selected.');
                            return;
                        }else if(qps.qp.Materials__c && !qps.qp.Labour__c)
                            qps.qp.ASP_Action__c = 'Add Parts Only';
                        else if(!qps.qp.Materials__c && qps.qp.Labour__c)
                        {
                            qps.qp.ASP_Action__c = 'Add Hours Only';
                        }
                    }else if(qps.qp.ASP_Reason__c == 'Removed')
                    {
                        qps.qp.ASP_Action__c = 'Remove Parts and Hours';
                        if(qps.qp.Materials__c)
                        {
                            mateRem =true;
                        }
                        if(!qps.qp.Materials__c && !qps.qp.Labour__c)
                        {
                            util.setErrorMsg(true, 'Invalid Action either Labour or Material Should be selected.');
                            return;
                        }else if(qps.qp.Materials__c && !qps.qp.Labour__c)
                        
                            qps.qp.ASP_Action__c = 'Remove Parts Only';
                        else if(!qps.qp.Materials__c && qps.qp.Labour__c)
                        {
                            
                            qps.qp.ASP_Action__c = 'Remove Hours Only';
                        }
                    }
                    updatingList.add(qps.qp);
                }   
                
            }
            if(userDefinedList.size()>0)
            {
                for(quoteproductClass qps: userDefinedList)
                {
                    updatingList.add(qps.qp);
                }
            }
            
            if(updatingList.size()>0)
            upsert updatingList;
            
            populateASP(asp.Id) ;
            
            cnfBtn = false;
            chgBtn = true;
            if(amendmeList.size()>0)
            addTable =true;
            else
            addTable = false;
            
            if(userDefinedList.size()>0)
            udpTable =true;
            else
            udpTable = false;
            
            
            sec1 = false;
            sec2 = false;
            sec3 = false;
            sec4 = true;
            sec5 = true;
            sec6 = false;
            addBtn = false;
            udpBtn = false;
            subBtn =true;
            showReqItm =false;
            updBtn =false;
            valBtn = false;
        }else
        {
            util.setErrorMsg(true, 'Please add some items to see the summary.');
        }
        
        //code added for asp hours
        if(showList.size()>0){
            showAspHours = true;
            ASPHours ='';
            //ASPHoursList = new List<List<String>>();
            Map<Id,Quote_product__c> productToQpMap = new Map<Id,Quote_product__c>();
            Map<Id,Double> productToQuantityMap = new Map<Id,Double>();
            Set<id> PId = new Set<id>();
            System.debug('####showLIst###'+showList);
            for(quoteproductClass q:showList){
                PId.add(q.qp.Product__c);
                productToQpMap.put(q.qp.Product__c,q.qp);
                productToQuantityMap.put(q.qp.Product__c,q.qp.Quantity__c);
            }
            System.debug('#####productToQuantityMap#####'+productToQuantityMap);
            System.debug('#####PId#####'+PId);
            List<Product_Work_Code__c> workCodes = [SELECT id,Hours__c,Skill_Type__c,Product__c from Product_Work_Code__c where product__c IN :productToQpMap.keySet() and Start_Date__c<=:System.today() and End_Date__c>=:System.today()];
            System.debug('#####workCodes#####'+workCodes);
            
            if(workCodes.size()>0){
                Map<string,Double> skillHourMap = new Map<String,Double>();
                for(Product_Work_Code__c wc:workCodes){
                    System.debug('#########'+wc.Hours__c+productToQuantityMap.get(wc.product__c)+Double.valueOf(-(wc.Hours__c*productToQuantityMap.get(wc.product__c))));
                    if(skillHourMap.containsKey(wc.Skill_Type__c)){
                        if(productToQpMap.get(wc.Product__c).Asp_reason__c == 'Added')
                            skillHourMap.put(wc.Skill_Type__c,Double.valueOf(skillHourMap.get(wc.Skill_Type__c)+(wc.Hours__c*productToQuantityMap.get(wc.product__c))));
                        else
                            skillHourMap.put(wc.Skill_Type__c,Double.valueOf(skillHourMap.get(wc.Skill_Type__c)-(wc.Hours__c*productToQuantityMap.get(wc.product__c))));
                    }
                    else{
                        if(productToQpMap.get(wc.Product__c).Asp_reason__c == 'Added')
                            skillHourMap.put(wc.Skill_Type__c,Double.valueOf((wc.Hours__c*productToQuantityMap.get(wc.product__c)))); 
                        else
                            skillHourMap.put(wc.Skill_Type__c,Double.valueOf(-(wc.Hours__c*productToQuantityMap.get(wc.product__c))));
                    }
                }
                System.debug('#####skillHourMap#####'+skillHourMap);
                ASPHours = '';
                for(String s:skillHourMap.keySet()){
                    ASPHours = ASPHours + s + '='+skillHourMap.get(s)+';';
                }
                System.debug('#####ASPHours#####'+ASPHours );
                ASPHoursList = new List<List<String>>();                
                List<String> tempStr = ASPHours.split(';');
                for(String s: tempStr){
                    String[] str = s.split('=');
                    ASPHoursList.add(str);
                }
            }                
                
        }
        }
        catch(exception e)
        {
            seterror(e);
        }
    }
    
    
    public pagereference OnChangesClick()
    {
        if(retUrl==null)
        {
            return(new pagereference('/apex/Aspenhanced?retUrl='+bmQuote.Id));
        }
        populateASP(asp.Id) ;
        popReuestedItems();
        if(asp.Status__c!='Submitted')
        {
            //if(amendmeList.size()>0)
            {
                cnfBtn = true;
                chgBtn = false;
                addTable = true;
                sec1 = true;
                sec2 = true;
                sec3 = true;
                sec4 = false;
                sec5= false;
                sec6= false;
                subBtn = false;
                addBtn = true;
                udpBtn = true;
                if(requestedItems.size()>0)
                showReqItm =true;
                
                
            }
            
        }else if(asp.Status__c =='Submitted')
        {
            cnfBtn = false;
            chgBtn = false;
            addTable = false;
            sec1 = true;
            sec2 = false;
            sec3 = false;
            sec4 = false;
            sec5= false;
            sec6= true;
            subBtn = false;
            updBtn = true;
            showReqItm = false;
            
        }
        return null;
    }
    
    
    public void AddProductQuote()
    {
        Quote_Product__c qpNew = new Quote_Product__c(BigMachines_Quote__c=BigMachineId,Quantity__c =1, ASP__c = asp.Id, Materials__c = true, Labour__c = true, ASP_Reason__c = 'Added',ASP_Action__c = 'Add Parts and Hours' );
        
        quoteproductClass qpClass = new quoteproductClass(qpNew);
        //qpClass.updateQp = true;
        //amendmeList.add(qpClass);
        showList.add(qpClass);
        //listPQ.add(qpNew); 
        if(showList != null && showList.size()>0)
            addTable =true;
        else
            addTable =false;
        
    }
    
    public void AddRemoveQty()
    {       
       try{
        system.debug('********i am here**********');
        Boolean isexistingrow=false;
        boolean remove = false;
        boolean removeShow = false;
        integer i = 0;
        integer j =0;
        boolean show = false;
        boolean flag = false;
        string oldasp;
        string oldact;
        decimal oldaspimp;
        for(quoteproductClass q:FullList)
        {
            
            Quote_Product__c  qp = new Quote_Product__c();
            Quote_Product__c  Showqp = new Quote_Product__c();
            if(q.add)
                {
                system.debug('******In Add******');
                system.debug('******Add Map******'+addMap);
                system.debug('******Remove Map******'+removeMap);
                system.debug('******Old Map******'+oldremoveMap);
                if(removeMap.containskey(q.qp.Name))
                {
                    qp = removeMap.get(q.qp.Name);
                    if(qp.Quantity__c==1)
                    {
                        
                        delete qp;
                        removeMap.remove(q.qp.Name);
                        remove = true;
                        removeShow = true;
                        i = 0;
                        for(quoteproductClass s: amendmeList)
                        {
                            if(s.qp.Name==qp.Name)
                            break;
                            else
                            i++;
                        }
                        
                        j = 0;
                        for(quoteproductClass s: showList)
                        {
                            if(s.qp.Name==qp.Name)
                            break;
                            else
                            j++;
                        }
                        
                        
                    }else
                    {
                        
                        qp.Quantity__c+=1;
                        if(oldRemoveMap.containskey(qp.Name) && oldRemoveMap.get(qp.Name).Quantity__c<= qp.Quantity__c)
                        {
                            util.setErrorMsg(true, 'Action Not Allowed');
                            q.add = false;
                            qp.Quantity__c-=1;
                            return;
                            
                        }
                        //q.quantity-=1;
                        update qp;
                        qp = queryQuoteProcut(qp.Id);
                        removeMap.put(q.qp.Name,qp);
                    }
                    isexistingrow=true;
                }
                else if(!addMap.containskey(q.qp.Name))
                {
                    qp =  new Quote_Product__c(Name=q.qp.Name, ASP_Reason__c='Added', ASP__c = asp.id, Product__c =q.qp.Product__c, ASP_Action__c = 'Add Parts and Hours',
                                                Materials__c= true, Labour__c = true,Quantity__c =1, BigMachines_Quote__c = BigMachineId); 
                    qp.Order__c = orderqp; 
                    orderqp++;
                    insert qp;
                    system.debug('Suceessfull--->'+qp);
                }
                else 
                {
                    qp = addMap.get(q.qp.Name);
                    qp.Quantity__c+=1;
                    //q.quantity+=1;
                    update qp;
                    
                    isexistingrow=true;
                }
                
                q.add = false;
                if(!remove)
                {
                    addMap.put(qp.Name, qp);
                }   
                if(q.qp.Product__r.Adding_Alert__c!=Null){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,q.qp.Product__r.Adding_Alert__c);
                    ApexPages.addMessage(myMsg);
                }
            }else
            if(q.sub)
            {
                system.debug('******In Sub******');
                system.debug('******Add Map******'+addMap);
                system.debug('******Remove Map******'+removeMap);
                system.debug('******Old Map******'+oldremoveMap);
                
                if(addMap.containskey(q.qp.Name))
                {
                    qp = addMap.get(q.qp.Name);
                    if(qp.Quantity__c==1)
                    {
                        addMap.remove(q.qp.Name);
                        delete qp;
                        remove = true;
                        removeShow = true;
                        removemap.remove(q.qp.Name);
                        i=0;
                        for(quoteproductClass s: amendmeList)
                        {
                            if(s.qp.Name==qp.Name)
                            break;
                            else
                            i++;
                        }
                        
                        j=0;
                        for(quoteproductClass s: showList)
                        {
                            if(s.qp.Name==qp.Name)
                            break;
                            else
                            j++;
                        }
                    }else
                    {
                        qp.Quantity__c-=1;
                        //q.quantity-=1;
                        update qp;
                        addMap.put(q.qp.Name,qp);
                    }
                    isexistingrow = true;
                    
                    
                }
                else if(!removeMap.containskey(q.qp.Name))
                {
                    if(oldRemoveMap.containskey(q.qp.Name))
                    {
                        util.setErrorMsg(true, 'You can not remove more than exisiting quantity.');
                        q.sub=false;
                        return;
                    }
                    if(q.qp.ASP__c!=null)
                    {
                    oldasp = q.qp.ASP__c;
                    oldaspimp = q.qp.ASP_Impact__c;
                    oldact= q.qp.ASP_Action__c;
                    }
                    
                    system.debug('oldAsp--->'+oldasp);
                    qp = q.qp;
                    qp.ASP_Reason__c = 'Removed';
                    qp.ASP_Action__c = 'Remove Parts & Hours';
                    qp.ASP__c =  asp.id;
                    qp.Materials__c = true;
                    qp.Labour__c = true;
                    qp.Order__c = orderqp;
                    orderqp++;
                    update qp;
                    qp = queryQuoteProcut(qp.Id);
                    oldRemoveMap.put(qp.Name,qp); 
                    quoteproductClass qpclass = new quoteproductClass(qp);
                    qpclass.quantity = qp.Quantity__c;
                    if(oldasp!=null)
                    {
                        system.debug('In If----->'+oldasp);
                        qpclass.oldasp = oldasp;
                        qpclass.oldaspimp = oldaspimp;
                        qpclass.oldact = oldact;
                        
                    }
                    
                    amendmeList.add(qpclass);
                    system.debug('1st Amend list-->'+amendmeList);
                    if(qp.Quantity__c > 1)
                    {
                        decimal quan = qp.Quantity__c - 1;
                        decimal showQuan = qp.Quantity__c -quan;
                        qp =  new Quote_Product__c(Name=q.qp.Name, ASP_Reason__c='Added', ASP__c = asp.id, Product__c =q.qp.Product__c, ASP_Action__c = 'Add Parts and Hours',
                                                    Materials__c= true, Labour__c = true,Quantity__c =quan, BigMachines_Quote__c = BigMachineId); 
                        qp.Order__c = orderqp-1;
                        insert qp;
                        
                        Showqp =  new Quote_Product__c(Name=q.qp.Name, ASP_Reason__c='Removed',  Product__c =q.qp.Product__c, ASP_Action__c = 'Remove Parts and Hours',
                                                    Materials__c= true, Labour__c = true,Quantity__c =showQuan ); 
                                                
                        show =true;
                    }else
                    {
                        
                        Showqp =qp;
                        show =true;
                        flag = true;
                        //isexistingrow = true;
                    }
                    
                    
                }
                else
                {
                    qp = removeMap.get(q.qp.Name);
                    if(qp.ASP_Reason__c == 'Added')
                    {
                        if(qp.Quantity__c == 1)
                        {
                            delete qp;
                            remove = true;
                            
                            i =0;
                            for(quoteproductClass s: amendmeList)
                            {
                                if(s.qp.Name==qp.Name && s.qp.ASP_Reason__c=='Added')
                                break;
                                else
                                i++;
                            }
                            
                            j =0;
                            for(quoteproductClass s: showList)
                            {
                                if(s.qp.Name==qp.Name && s.qp.ASP_Reason__c=='Removed')
                                {
                                    s.qp= oldRemoveMap.get(s.qp.Name);
                                    break;
                                }
                                
                                j++;
                            }
                            removemap.remove(q.qp.Name);
                            
                        }else
                        {
                            qp.Quantity__c-=1;
                            //q.quantity-=1;
                            update qp;
                                        
                            qp = queryQuoteProcut(qp.Id);
                            removeMap.put(qp.name, qp);
                            for(quoteproductClass s: amendmeList)
                            {
                                if(s.qp.Name==qp.Name && s.qp.ASP_Reason__c=='Added')
                                    s.qp = qp;
                            }
                            for(quoteproductClass s: showList)
                            {
                                if(s.qp.Name==qp.Name && s.qp.ASP_Reason__c=='Removed')
                                {
                                    s.qp.ASP_Impact__c = oldRemoveMap.get(s.qp.Name).ASP_Impact__c + qp.ASP_Impact__c;
                                    s.qp.Quantity__c +=1;
                                }   
                            }
                                list<quoteproductClass> tempList = new list<quoteproductClass>();
                                tempList.addall(userDefinedList);
                                tempList.addall(amendmeList);
                                totalVal = calTotal(tempList);   
                                q.sub=false;  
                                return;         
                            //show = true;
                            
                        }
                    }else
                    {
                        util.setErrorMsg(true, 'Action Not Allowed');
                        return;
                    }
                }
                q.sub = false;
                if(!remove)
                {
                    qp =queryQuoteProcut(qp.Id);
        
                    removeMap.put(q.qp.Name, qp);
                }
                if(q.qp.Product__r.Removing_Alert__c!=Null){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,q.qp.Product__r.Removing_Alert__c);
                    ApexPages.addMessage(myMsg);
                }
            }
            if(qp.Id!=null && !remove)
            {
                //qp = queryQuoteProcut(qp.Id);
                if(isexistingrow)
                {  
                    
                    for(quoteproductClass qps:amendmeList)
                    {
                        if(qps.qp.Name== qp.Name && qps.qp.ASP_Reason__c == qp.ASP_Reason__c)
                        {
                            qps.qp = qp;
                            break;
                        }
                        
                    }
                    
                    for(quoteproductClass qps:showList)
                    {
                        if(qps.qp.Name== qp.Name )
                        {
                            qps.qp = qp;
                            break;
                        }
                        
                    }
                    
                    
                }else
                {
                    qp = queryQuoteProcut(qp.Id);
                    if(!flag)
                    {
                    quoteproductClass qpclass = new quoteproductClass(qp);
                    amendmeList.add(qpclass);
                    }
                    if(show)
                    {
                        quoteproductClass showClass = new quoteproductClass(Showqp);
                        if(Showqp.Id==null)
                        {
                        decimal aspImpact =0.0;
                        aspImpact = oldRemoveMap.get(Showqp.Name).ASP_Impact__c + qp.ASP_Impact__c;
                        Showqp.ASP_Impact__c = aspImpact;
                        showClass.quantity = oldRemoveMap.get(Showqp.Name).Quantity__c;
                        showClass.Descript =    qp.Product_Description__c;
                        }
                        showList.add(showClass);
                    }else
                    {
                        showlist.add(new quoteproductClass(qp));
                    }    
                        
                }
                break;
            }
            
            
            
       
        }
        
        asp =queryASP(asp.Id);
        
        if(remove)
        {
            amendmeList.remove(i);
            
        }   
        if(removeShow)
        {
            showList.remove(j);
        }
        
        
        
       // if(amendmeList != null && amendmeList.size()>0)
       if(showList != null && showList.size()>0)
           addTable =true;
        else
            addTable =false;
        
        list<quoteproductClass> tempList = new list<quoteproductClass>();
        tempList.addall(userDefinedList);
        tempList.addall(amendmeList);
        totalVal = calTotal(tempList);    
       }
       catch(Exception e)
       {
            seterror(e);   
            util.setErrorMsg(true, 'Action Not Allowed');
       }
        //return null;
    }
    
    private Quote_Product__c queryQuoteProcut(id qpId)
    {
        
        Quote_Product__c qp = new Quote_Product__c();
        qp=[select Id,Materials__c ,Labour__c,Sales_Price__c, Name, Product_Description__c, Product__c,GrossSingle__c,
          Part_Number__c, Quantity__c,ASP_Reason__c,ASP_Action__c,ASP_Impact__c,Description__c ,Unit_Price_Inc_VAT__c,Unit_Merchant_Price_Exc_VAT__c,Gross_Total__c 
            ,Supplier__c,ASP__c,User_Defined_Description__c,Order__c,Product__r.Adding_Alert__c,Product__r.Removing_Alert__c,Customer_Charged_Refunded__c   from Quote_Product__c where Id = :qpId];
        return qp;            
    }
    
    
    public void addRemoveAbove()
    {
        integer i =0;
        
        Quote_Product__c qpR= new Quote_Product__c();
        Quote_Product__c qpA= new Quote_Product__c();
        Quote_Product__c qp= new Quote_Product__c();
        boolean remove = false;
        list <quoteproductClass> templist = new list <quoteproductClass>();
        for(quoteproductClass q : showList)
        {
            if(q.add)
            {
                system.debug('selected-->'+q);
                if(addMap.containsKey(q.qp.Name))
                {
                    qpA = addMap.get(q.qp.Name);
                    qpA.Quantity__c+=1;
                    update qpA;
                    qpA = queryQuoteProcut(qpA.Id);
                    q.qp = qpA;
                    addmap.put(q.qp.Name, qpA);
                    for(quoteproductClass qpsClass: amendmeList)
                    {
                        if(qpsClass.qp.Id ==qpA.Id )
                        {
                            qpsClass.qp = qpA;
                            break;
                        }
                    }
                }   
                else if(removeMap.containskey(q.qp.Name))
                {
                    qpR = removeMap.get(q.qp.Name);
                    quote_product__c removed = oldRemoveMap.get(q.qp.Name);
                    system.debug('Added As Removed-->'+qpR);
                    if(q.qp.ASP_Reason__c == 'Removed')
                    {
                        
                        system.debug('Removed-->'+removed);
                        /*if(removed.Quantity__c ==  q.qp.quantity__c)
                        {
                            delete qpR;
                            integer j =0;
                            for(quoteproductClass qps: amendmeList)
                            {
                                if(qps.qp.Name== q.qp.Name &&  qps.qp.ASP_Reason__c == 'Added')
                                {
                                    break;
                                }
                                j++;
                            }
                            amendmeList.remove(j);
                            removemap.remove(q.qp.Name);
                        }else*/ if(removed.Quantity__c > q.qp.Quantity__c)
                        {
                            qpR.Quantity__c -=1;
                            if(qpR.Quantity__c==0)
                            {
                                delete qpR;
                                integer j =0;
                                for(quoteproductClass qps: amendmeList)
                                {
                                    if(qps.qp.Name== q.qp.Name &&  qps.qp.ASP_Reason__c == 'Added')
                                    {
                                        break;
                                    }
                                    j++;
                                }
                                amendmeList.remove(j);
                                removemap.remove(q.qp.Name);
                                q.qp.ASP_Impact__c = removed.ASP_Impact__c;
                            }else
                            {
                                update qpR;
                                system.debug('Removed--->'+qpr.Id);
                                qpR=queryQuoteProcut(qpr.Id); 
                                removemap.put(qpR.Name,qpR);
                                q.qp.ASP_Impact__c = removed.ASP_Impact__c + qpR.ASP_Impact__c;
                            }
                            
                            q.qp.Quantity__c+=1;
                        }
                    }
                }else
                {
                    util.setErrorMsg(true, 'You can not remove more than exisiting quantity.');
                    q.add=false;
                    return;
                }
                q.add=false;
                break;
            }
            else
            if(q.sub)
            {
                if(q.qp.Quantity__c <= 1)
                {
                    if(addMap.containskey(q.qp.Name))
                    {
                        qp = addMap.get(q.qp.Name);
                        addMap.remove(q.qp.Name);
                        delete qp;
                        templist.addall(amendmeList);
                        amendmelist = new list <quoteproductClass>();
                        for(quoteproductClass qps: templist)
                        {
                            if(q.qp.Name != qps.qp.Name )
                            {
                                amendmelist.add(qps);
                            }
                        }    
                         
                    }   
                    else if(removeMap.containskey(q.qp.Name))
                    {
                        system.debug('Remove Map---->'+removeMap);
                        
                        qp = removeMap.get(q.qp.Name);
                        removeMap.remove(q.qp.Name);
                        templist.addall(amendmeList);
                        amendmelist = new list <quoteproductClass>();
                        
                        for(quoteproductClass qps: templist)
                        {
                            if(q.qp.Name == qps.qp.Name )
                            {
                                if (qps.qp.ASP_Reason__c =='Removed' )
                                {
                                    Quote_Product__c qpnew = new Quote_Product__c(id = qps.qp.id);
                                    if(qps.oldasp!=null)
                                    {
                                        qpnew.ASP__c = qps.oldAsp;
                                        qpnew.ASP_Reason__c = 'Added';
                                        qpnew.ASP_Action__c = qps.oldact;
                                        qpnew.ASP_Impact__c = qps.oldaspimp;
                                        qpnew.ASP_Status__c = 'Committed - Added';
                                        qpnew.Sales_Price__c = qps.qp.Grosssingle__c;
                                    }else
                                    {
                                         qpnew.ASP__c=null;
                                         qpnew.ASP_Reason__c = '';
                                         qpnew.ASP_Action__c = '';
                                         qpnew.ASP_Removed__c = '';
                                         qpnew.ASP_Date__c =null;
                                         qpnew.ASP_Impact__c = null;
                                         qpnew.ASP_Status__c = '';
                                         qpnew.Sales_Price__c = qps.qp.Grosssingle__c;
                                    }
                                    update qpnew;
                                    
                                }else
                                {
                                    delete qps.qp;
                                    
                                }
                            }else
                            {
                                amendmeList.add(qps);
                                
                            }
                            
                        }
                    }else
                    {
                        templist.addall(amendmeList);
                        amendmelist = new list <quoteproductClass>();
                        
                        for(quoteproductClass qps: templist)
                        {
                            if (qps.qp.ASP_Reason__c =='Removed' )
                            {
                                Quote_Product__c qpnew = new Quote_Product__c(id = qps.qp.id);
                                if(qps.oldasp!=null)
                                {
                                    qpnew.ASP__c = qps.oldAsp;
                                    qpnew.ASP_Reason__c = 'Added';
                                    qpnew.ASP_Action__c = qps.oldact;
                                    qpnew.ASP_Impact__c = qps.oldaspimp;
                                    qpnew.ASP_Status__c = 'Commited - Added';
                                    qpnew.Sales_Price__c = qps.qp.Grosssingle__c;
                                    
                                }else
                                {
                                     qpnew.ASP__c=null;
                                     qpnew.ASP_Reason__c = '';
                                     qpnew.ASP_Action__c = '';
                                     qpnew.ASP_Removed__c = '';
                                     qpnew.ASP_Date__c =null;
                                     qpnew.ASP_Impact__c = null;
                                     qpnew.ASP_Status__c = '';
                                     qpnew.Sales_Price__c = qps.qp.Grosssingle__c;
                                }
                                update qpnew;
                            }    
                        }
                    }   
                    
                    templist = new list <quoteproductClass>();
                    templist.addall(showList);
                    showList = new list <quoteproductClass>();
                    for(quoteproductClass qps: templist)
                    {
                        if(q.qp.Name != qps.qp.Name )
                        {
                            showList.add(qps);
                        }
                        
                    } 
                    remove = true;
                    //delete qp;
                }else
                {
                    if(q.qp.ASP_Reason__c == 'Removed')
                    {
                        qp = oldRemoveMap.get(q.qp.Name);
                        system.debug('Original-->'+qp);
                        if(removeMap.containskey(q.qp.Name))
                        {
                            qpR = removeMap.get(q.qp.Name);
                            
                            //if(qp.Quantity__c ==q.quantity)
                            {
                                qpR.Quantity__c+=1;
                                update qpR;
                                qpR= queryQuoteProcut(qpR.Id);
                                removeMap.put(qpR.Name, qpR);
                            }
                            
                        }else
                        {
                            system.debug('Original-->'+q);
                            if(qp.Quantity__c ==q.qp.Quantity__c)
                            {
                                qpR = new Quote_Product__c (Name=q.qp.Name, ASP_Reason__c='Added', ASP__c = asp.id, Product__c =q.qp.Product__c, ASP_Action__c = 'Add Parts and Hours',
                                                    Materials__c= true, Labour__c = true,Quantity__c =1, BigMachines_Quote__c = BigMachineId);
                                insert qpR; 
                                qpR = queryQuoteProcut(qpR.Id);
                                removeMap.put(qpR.Name,qpR);
                                amendmeList.add(new quoteproductclass(qpR));                    
                            }
                            
                            
                        }
                        q.qp.Quantity__c-=1;
                        q.qp.ASP_Impact__c = qp.ASP_Impact__c + qpR.ASP_Impact__c;
                    }else
                    {    
                        if(addMap.containskey(q.qp.Name))
                        qpA = addMap.get(q.qp.Name);
                        qpA.Quantity__c-=1;
                        //qp.ASP_Impact__c-=qp.GrossSingle__c;
                        update qpA;
                        qpA= queryQuoteProcut(qpA.Id);
                        addMap.put(q.qp.Name, qpA);
                        q.qp=qpA;
                    }   
                    
                }
                q.sub=false;
                break;
                
            }
            i++;
        }
        /*if(remove)
        {
            showList.remove(i); 
            
        }*/
        
        asp =queryASP(asp.Id);
        tempList = new list<quoteproductClass>();
        tempList.addall(userDefinedList);
        tempList.addall(amendmeList);
        totalVal = calTotal(tempList);
        
    }
    
    
    
    public pagereference Submit()
    {
        list<string> aspCategory ;
        string aspTimeLine = '';
        decimal authorisationTotal = 00;
        queryjob(3);
        list<Case>  insertCaselist = new list<Case>();
        pagereference p ;
        if(jobList[0].Status__c == 'Installed')
        {
            aspTimeLine = 'Post Install';
        }else if(jobList[0].Status__c == 'Planned' && System.today() >= Job.Installation_Date__c )
        {
            aspTimeLine = 'WIP';
        }else if(jobList[0].Status__c == 'Pending' || jobList[0].Status__c == 'Suspended' || jobList[0].Status__c == 'Cancelled' || jobList[0].Status__c == 'Allocated' || (jobList[0].Status__c == 'Planned'  && Job.Installation_Date__c>= system.today()))
        {
            aspTimeLine = 'Pre Install';
        }
        
        try{ 
            list<ASP_Exception__c> insertList = new list<ASP_Exception__c>();
            if(system.label.aspExcpetion == 'on')
            {
            if(asp.Approved_By__c==null)
            {
                util.setErrorMsg(true, 'Please enter Approved By on this ASP.');
                return null;
            }
            /*
                Check Approver for the limit
            */
            string categoryExternalKey ='';
            
            if(asp.Asp_Type__c == 'N/A' || asp.Asp_Type__c == 'Downtime')
            {
                categoryExternalKey = (asp.Function__c!=null && asp.Function__c!=''? asp.Function__c :'')+(asp.Definition__c!=null && asp.Definition__c!=''? asp.Definition__c :'')+(asp.Picklist__c!=null&&asp.Picklist__c!=''? asp.Picklist__c:'');
            }else if(asp.ASP_Type__c != 'N/A')
            {
                categoryExternalKey = (asp.ASP_Type__c!=null && asp.ASP_Type__c!=''? asp.ASP_Type__c :'');
            }
            system.debug('categoryExternalKey-- >'+categoryExternalKey);
            
            ASP_Category__c[] categoryRecord = [Select id , Category__c, Consider_Discount__c, Consider_ASP_Total__c  from ASP_Category__c where ExtrenalKey__c = :categoryExternalKey ];
            system.debug('categoryRecord-- >'+categoryRecord);
            
            string whatsUsed;
            if(categoryRecord.size()>0)
            {
                aspCategory = new list<string> {categoryRecord[0].Category__c};
                asp.General_ASP_Exception_Category__c = categoryRecord[0].Category__c;
                if(categoryRecord[0].Consider_Discount__c)
                {
                    authorisationTotal = -(discount);
                    whatsUsed = 'Discount';
                }else if(categoryRecord[0].Consider_ASP_Total__c)
                {
                    authorisationTotal = totalVal;
                    whatsUsed = 'Total Value';
                }
                
                if(categoryRecord[0].Category__c == 'Compensation')
                {
                    system.debug('in case creation******'+job.CHI_Lead__c);
                    Case c = new Case (RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Case', 'Dissatisfaction'), Status= 'Closed', AccountId = job.CHI_Lead__r.AccountId, Job__c = job.Id , Opportunity__c =job.CHI_Lead__c, 
                    Subject = 'Auto- Closed Compensation ASP', Description = asp.Description__c, District__c  = job.district__c, Origin = 'Compensation ASP', Communication_status__c = 'Awaiting office', Case_Source__c  = 'Customer',
                    Priority = 'Low', Case_Manager__c = system.label.CompensationManager, Issued_To_Group__c = 'Office',TimeOpened__c = System.today(), TimeClosed__c = system.today(),
                    ContactId = job.CHI_Lead__r.Account.Primary_Contact__c,Task_Comments__c =asp.Description__c );
                    
                    //Fetching the assignment rules on case
                    AssignmentRule AR = new AssignmentRule();
                    AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                    
                    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                    
                    c.setOptions(dmlOpts);          
                    
                    insertCaselist.add(c);
                    
                    system.debug('List-- >'+insertCaselist);
                }
                
            }else
            {
                authorisationTotal = -(discount);
                aspCategory  = new list<string> {'Miscellaneous'};
                asp.General_ASP_Exception_Category__c = 'Miscellaneous';
            }
                    
            Employee__c currentUser = [Select Salesforce_User__r.ManagerId, Salesforce_User__r.ASP_Authorising_Rank__c, Salesforce_User__c From Employee__c where Id = :asp.Approved_By__c];
            
            System.debug('aspTimeLine-- >'+aspTimeLine);
           
            decimal roleId = currentUser.Salesforce_User__r.ASP_Authorising_Rank__c;
            System.debug('aspTimeLine-- >'+roleId);
            
             System.debug('aspTimeLine-- >'+aspCategory);
            
            List <ASP_Limits__c> aspLimit = [Select id, RoleName__c,  Upper_Limit__c, SLA__c ,ASP_Category__c from ASP_Limits__c Where RoleId__c =: roleId and ASP_Category__c in :aspCategory and ASP_TimeLine__c = :aspTimeLine];
            
            System.debug('aspLimit--- >'+aspLimit);
            System.debug('authorisationTotal--- >'+authorisationTotal);
           
            if(roleId == null ||roleId == 0 || aspLimit.size()==0)
            {
                 util.setErrorMsg(true, '"Approved By" is not eligible to approve this ASP.');
                 return null;
                
            }else
            {
                for(string categoryStr : aspCategory)
                {
                    for(ASP_Limits__c al: aspLimit)
                    {
                        if(al.Upper_Limit__c <  authorisationTotal && al.ASP_Category__c == categoryStr)
                        {
                            //needs Authorisation
                            insertList.add(new ASP_Exception__c(Assigned_To__c= currentUser.Salesforce_User__r.ManagerId, Status__c = 'In Progress', Allowed_Amount__c = al.Upper_Limit__c,  
                                                                Authorised_Amount__c =authorisationTotal, Cateogry__c = categoryStr, ASP__c = asp.Id, ASP_Applied_Time__c =  aspTimeLine, 
                                                                Exception_User__c = currentUser.Salesforce_User__c, Role_Name__c = al.RoleName__c, Whats_Used__c = whatsUsed, Due_Date__c = system.today().addDays(integer.valueof(al.SLA__c))));
                            
                            break;
                        }
                    }
                }
                
            }
        }
        
            asp.Customer_Payment_Variation__c = customePaymentVar;
            asp.Suggested_Customer_Payment__c = suggestedPayment;
            asp.ASP_Timeline__c = aspTimeLine; 
            asp.ASP_Total__c = totalVal;
            asp.ASP_Hours__c = aspHours;
            asp.Value_of_Packs_Returned_in_Part__c = partRefunded;
            asp.Value_of_Packs_Added_in_Part__c  = partAdded;
            update asp;
            
            
            
            string result =    QuoteProductDecompile.submitASP(asp.Id, BigMachineId); 
            
            if(result.startswith('Exception occurred:'))
            {
                util.setErrorMsg(true, result);
            }else
            {
                
                if(asp.ASP_Type__c !=null)
                {
                    if(asp.ASP_Type__c.contains('Remedial'))
                    queryjob(1);
                    else if(asp.ASP_Type__c.contains('Downtime'))
                    queryjob(2);
                    else if(asp.ASP_Type__c.contains('Recall'))
                    queryjob(4);
                    else
                    queryjob(3);
                    if(jobList.size()>0  && jobList[0].Status__c == 'Planned')
                    {
                        //regerenateOrders
                        p  = new pagereference ('/apex/PurchaseOrderAmendment?AutoRegeneration=1&id='+jobList[0].Id);
                    }
                }else
                {
                    queryjob(3);
                    if(jobList.size()>0  && jobList[0].Status__c == 'Planned')
                    {
                        //regerenateOrders
                       p =new pagereference ('/apex/PurchaseOrderAmendment?AutoRegeneration=1&id='+jobList[0].Id);
                    }
                }
                asp=queryASP(asp.Id);
                sec5=false;
                sec6=true;
                subBtn =false;
                chgBtn=false;
                showJob =true;
                PageReference pdfPage =page.aspPdf;
                //putting id of custom object in parm id so that I can read it to fetch records
                pdfPage.getParameters().put('id',asp.id);
                
                pdfPage.setRedirect(true);
                Blob pdfBlob = pdfPage.getcontentAsPdf(); //PRB00031256 - changed from getcontent() to getcontentAsPdf()
                    
                Attachment aspPdf = new Attachment(Body = pdfBlob,
                                                Name = asp.Name+'.pdf',
                                                ParentId = asp.Id,
                                                isPrivate = false,
                                                contenttype='.pdf'
                                                );
               
               insert aspPdf;                                 
               system.debug('In Attachment creation: '+aspPdf.Name);   
               
               if(insertList.size()>0)
               {
                result = 'Asp was sucessfully submitted and sent to manager for acknowledgement';
                util.setErrorMsg(false, result);
                insert insertList;
               }else
               {
               util.setErrorMsg(false, result);
               }
               
               if(insertCaselist.size()>0)
               {
                
                insert insertCaselist;
               }
                    
            }       
        }catch (Exception e)
        {
            seterror(e);
            
        }
        return p;
    }
    
    public void queryjob(integer i)
    {
        if(i==1)
        {
            jobList = [select id, Name , GDIndicator__c, Status__c, Sub_Status__c, Installation_Date__c, Customer_Preferred_Date__c from Job__c where Quote__c = : BigMachineId and Is_Downtime_Job__c=false and Is_Remedial_Job__c =true and Split_Job__c =false order by CreatedDate desc limit 1];
        }else if(i==2)
        {
            jobList = [select id, Name , GDIndicator__c, Status__c,Sub_Status__c, Installation_Date__c, Customer_Preferred_Date__c  from Job__c where Quote__c = : BigMachineId and Is_Downtime_Job__c=true and Is_Remedial_Job__c =false and Split_Job__c =false order by CreatedDate desc limit 1];
        }else if(i==3)
        {
            jobList = [select id, Name , GDIndicator__c, Status__c,Sub_Status__c, Installation_Date__c, Customer_Preferred_Date__c,Maximum_End_Date__c,CHI_Lead__c  from Job__c where id=:job.id limit 1];
        }else if(i==4)
        {
            jobList = [select id, Name , GDIndicator__c, Status__c,Sub_Status__c, Installation_Date__c, Customer_Preferred_Date__c  from Job__c where Secondary_Job_Type_New__c = :asp.ASP_Type__c order by CreatedDate desc limit 1];
        }
        
        
    }
    
    public void createASP()
    {
        
        try{
            
            if(asp.id==null  )
            {
                asp.Quote__c = BigMachineId;
                insert asp;
                
                cnfBtn = true;
                sec2 = true;
                sec3=true;
                //valBtn = false;
                addBtn =true;
                udpBtn =true;
                valBtn = true;
            }else
            {
                update asp;
            }
            
            showField = false;
            asp =queryASP(asp.Id);
            
            //code added to Stop removals on remedial ASP
            if(asp.Asp_type__c == 'Remedial' || asp.Asp_type__c == 'Downtime')
             sec3 = false;
            
            //return (new pagereference ('/apex/aspenhanced?aspId'+asp.Id+'&retURL='+BigMachineId));
            
        }catch (exception e)
        {
            valBtn = true;
            sec2 = false;
            sec3= false;
            seterror(e); 
            //return null;
        }       
    }
    
  
     public class quoteproductClass
    {
        public boolean add {get;set;}
        public boolean sub {get;set;}  
        public Quote_Product__c qp {get;set;}
        public string type_qp {get;set;} 
        public boolean remove {get;set;}
        public boolean shwremove {get;set;}
        public decimal quantity{get;set;}
        public boolean updateQp {get;set;}
        public string style {get;set;}
        public string descript {get;set;}
        string oldasp;
        decimal oldaspImp;
        string  oldact;
        public quoteproductClass (Quote_Product__c q)
        {
            qp = q;
            add = false;
            sub = false;
            remove = false;
            updateQp=false;
            if(q.ASP_Reason__c == 'Added' && (q.Name == 'D001' ||  q.Name == 'A001'))
                style = 'color:blue;';
            else if(q.ASP_Reason__c == 'Added' )    
                style = 'color:black;';
            else
                style = 'color:red;'    ;
            //quantity =q.Quantity__c;
            if(descript==null)
            descript = q.Product_Description__c;
            //oldasp= q.ASP__c;
            
        }
        
             
    } 
    
    public pagereference deleteASP()
    {
        if(retUrl==null)
        {
            return null;
        }
        Pagereference p ;
            
        if(asp.Status__c != 'Submitted' && showList.size()==0 && asp.Request_For_ASP__c==null)
        {
            /*list<Quote_Product__c> deleteList = new list<Quote_Product__c>();
            list<Quote_Product__c> updateList = new list<Quote_Product__c>();
            for(quoteproductClass qps:amendmeList)
            {
                if(qps.qp.ASP_Reason__c == 'Added')
                {
                    deleteList.add(qps.qp);
                }else
                {
                    
                    if(qps.oldasp!=null)
                    {
                        qps.qp.ASP__c = qps.oldAsp;
                        qps.qp.ASP_Reason__c = 'Added';
                        qps.qp.ASP_Action__c = qps.oldact;
                        qps.qp.ASP_Impact__c = qps.oldaspimp;
                    }
                    else
                    {
                        qps.qp.ASP_Reason__c = '';
                        qps.qp.ASP_Action__c = '';
                        qps.qp.ASP_Removed__c = '';
                        qps.qp.ASP_Date__c =null;
                        qps.qp.ASP_Impact__c = null;
                        qps.qp.ASP__c = null;
                    }
                    updateList.add(qps.qp);
                }
            }
            if(deleteList.size()>0)
            delete deleteList;
            
            if(updateList.size()>0)
            update updateList;
            */
            if(asp.id!=null)
            delete asp;
            
            
        
            system.debug('--->'+job.Id+' '+retUrl);
            if(job.Id!=null)
             p = new pagereference('/'+job.Id);
            else if(retUrl!=null)
             p = new pagereference('/'+retUrl);
             return p;
        }
        
        
        if(asp.Id!=null)
        p = new pagereference('/'+asp.Id);
        return (p);
    }
    
    
    
    public void RemovePQ()
    {   
        integer i =0;     
        integer j =0;
        integer k =0;
        string oldasp ;
        decimal oldaspimp;
        string oldact;
        for(quoteproductClass qps:FullList)
        {
            if(qps.remove)
            {
                if(qps.qp.Name == 'UDPQP')
                {
                    qps.qp.ASP_Reason__c = 'Removed';
                    qps.qp.Materials__c = true;
                    qps.qp.Labour__c = false;
                    qps.qp.ASP_Action__c = 'Remove Parts Only';
                    qps.qp.ASP__c =  asp.id;
                    update qps.qp;
                    qps.qp = queryQuoteProcut(qps.qp.Id);
                    userDefinedList.add(qps);
                    udpTable =true;
                    break;
                }else
                if(addMap.containskey(qps.qp.Name))
                {
                    i =0;
                    for(quoteproductClass ams:amendmeList)  
                    {
                        if(ams.qp.Name == qps.qp.Name)
                        {
                            delete ams.qp;
                            break;
                        }
                        i++;
                    }
                    j=0;
                    for(quoteproductClass ams:showList) 
                    {
                        if(ams.qp.Name == qps.qp.Name)
                        {
                            //delete ams.qp;
                            break;
                        }
                        j++;
                    }
                    amendmeList.remove(i);
                    showList.remove(j);
                    util.setErrorMsg(false, 'Added item was removed.');
                    addMap.remove(qps.qp.Name);
                }
                
                if(removeMap.containskey(qps.qp.Name))
                {
                    i =0;
                    for(quoteproductClass ams:amendmeList)  
                    {
                        if(ams.qp.ASP_Reason__c == 'Added' && ams.qp.Name == qps.qp.Name)
                        {
                            delete ams.qp;
                            break;
                        }
                        i++;
                    }
                    amendmeList.remove(i);
                    removeMap.remove(qps.qp.Name);
                    return;
                }
                if(!removeMap.containskey(qps.qp.Name) && !addMap.containskey(qps.qp.Name) )
                {
                    Quote_Product__c qp = qps.qp;
                    if(qp.ASP__c!=null)
                    {
                        oldasp = qp.ASP__c;
                        oldaspimp = qp.ASP_Impact__c;
                        oldact = qp.ASP_Action__c;
                    }
                    
                    qp.ASP_Reason__c = 'Removed';
                    qp.Materials__c = true;
                    qp.Labour__c = true;
                    qp.ASP_Action__c = 'Remove Parts & Hours';
                    qp.ASP__c =  asp.id;
                    qp.Order__c = orderqp;
                    orderqp++;
                    update qp;
                    qp = queryQuoteProcut(qp.Id);
                    quoteproductClass qpsClass = new quoteproductClass(qp);
                    qpsClass.quantity = qp.Quantity__c;
                    if(oldasp!=null)
                    {
                        qpsClass.oldasp=oldasp;
                        qpsClass.oldaspimp=oldaspimp;
                        qpsClass.oldact=oldact;
                        
                    }
                    amendmeList.add(qpsClass);
                    showList.add(qpsClass);
                    //removeMap.put(qps.qp.Name,qp);
                    oldRemoveMap.put(qps.qp.Name,qp);
                }
            if(qps.qp.Product__r.Removing_Alert__c!=Null){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,qps.qp.Product__r.Removing_Alert__c);
             ApexPages.addMessage(myMsg);
            }   
            qps.remove = false; 
            asp = queryASP(asp.Id);
            break;
            }
            k++;
        }
        if(k<FullList.size())
        FullList.remove(k);
        
        if(amendmeList.size()>0)
        addTable =true;
        list<quoteproductClass> tempList = new list<quoteproductClass>();
        tempList.addall(userDefinedList);
        tempList.addall(amendmeList);
        totalVal = calTotal(tempList);
       
    }
    
    public void RemovePQabove()
    {  
        list<Quote_Product__c> deleteList = new list<Quote_Product__c>();
        list<Quote_Product__c> updatelist = new list<Quote_Product__c>();
        string productName ;
        for(quoteproductClass qps : showList)
        {
            if(qps.remove)
            {
                productName = qps.qp.Name;
                break;
            }
            qps.remove = false;
        }
        //list<integer> index = new list<integer>();
        //integer i=0;
        system.debug('Amend -->'+amendmeList);
        for(quoteproductClass qps : amendmeList)
        {
            if(qps.qp.Name == productName)
            {
                if(qps.qp.ASP_Reason__c == 'Added')
                {
                    deleteList.add(qps.qp);
                }   
                else 
                {
                    system.debug('---->'+qps);
                    if(qps.oldasp!=null)
                    {
                        qps.qp.ASP__c = qps.oldasp;
                        qps.qp.ASP_Action__c = qps.oldact;
                        qps.qp.ASP_Impact__c = qps.oldaspImp;
                        qps.qp.ASP_Reason__c = 'Added'; 
                        qps.qp.ASP_Status__c = 'Commited - Added'; 
                        qps.qp.Sales_Price__c = qps.qp.Grosssingle__c;
                    }else
                    {
                        qps.qp.ASP__c = null;
                        qps.qp.ASP_Action__c = null;
                        qps.qp.ASP_Reason__c = null; 
                        qps.qp.ASP_Date__c =null;
                        qps.qp.ASP_Impact__c = null;
                        qps.qp.ASP_Status__c = ''; 
                        qps.qp.Sales_Price__c = qps.qp.Grosssingle__c;
                    }
                    qps.qp.ASP_Removed__c = '';
                    updatelist.add(qps.qp);
                    
                }
                //index.add(i);
                if(qps.qp.Name == disountProd.Name)
                discount = 0.0;
            }
            //i++;
            oldRemoveMap.remove(qps.qp.Name );
            removeMap.remove(qps.qp.Name );
            addMap.remove(qps.qp.Name );
        }
        system.debug('productName-->'+productName);
        list<quoteproductClass> temp = new list<quoteproductClass>();
        temp.addall(amendmeList);
        amendmeList = new list<quoteproductClass>();
        for(quoteproductClass qps : temp)
        {
            if(qps.qp.Name != productName)
            {
                amendmeList.add(qps);
                
            }
        }
        system.debug('amendmeList-->'+amendmeList);
        temp = new list<quoteproductClass>();
        temp.addall(showList);
        showList = new list<quoteproductClass>();
        for(quoteproductClass qps : temp)
        {
            if(qps.qp.Name != productName)
            {
                showList.add(qps);
                
            }
        }
        system.debug('showList-->'+showList);
        addMap.remove(productName);
        removeMap.remove(productName);
        
        list<quoteproductClass> tempList = new list<quoteproductClass>();
        temp = new list<quoteproductClass>();
        temp.addall(userDefinedList);
        temp.addall(amendmeList);
        totalVal = calTotal(temp);
        
        try{
            if(deleteList.size()>0)
            delete deleteList;
            IF(updatelist.SIZE()>0)
            update updatelist;
            asp = queryASP(asp.Id);
        }catch (exception e)
        {
            seterror(e);
        }
        
        
    }
    
    public void seterror(exception e)
    {
        system.debug('Exception-->'+e.getmessage());
        if(e.getmessage().Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
        {
            list<string> error = e.getmessage().split(',');
            
            //if(!error[1].contains('specified'))
            util.setErrorMsg(true, error[1]);
            
        }else
        {   
            util.setErrorMsg(true, e.getmessage());
        }  
    }
    
    public ASP__c queryASP(id aspId)
    {
        asp =[Select a.Status__c, a.Quote__c, a.Picklist__c, a.Name, a.Material_Return_Info__c, a.Id, a.Function__c,Lock__c, 
                  a.Description__c, a.Definition__c, a.ASP_Type__c, a.ASP_Date__c, Charge_to_Customer__c,Quote_ASP_Unsubmitted_Total__c,
                  Approved_By__c,ASP_Total__c,Material_Notes__c,Balancing_Cost_Change__c,Person_Approved_By__c,Request_For_ASP__c,Asp_Billing_Status__c,Quote__r.Opportunity__c From ASP__c a where id = :aspId];
                  
        return asp;       
    }
    
    public void updateQuoteProd()
    {
        try{
            list<Quote_Product__c >instingList = new list<Quote_Product__c >();
            list<Quote_Product__c >updatingList = new list<Quote_Product__c >();
            list<Quote_Product__c >deletelist = new list<Quote_Product__c >();
            
            for(quoteproductClass qps: showList)
            {
                system.debug('add-->'+qps.add);
                if(qps.qp.ASP_Reason__c != 'Removed')
                {
                    if(qps.qp.id==null)
                    {
                        qps.qp.Order__c = orderqp;
                        orderqp++;
                        instingList.add( qps.qp);
                                    //qps.updateQp =false;
                    //break;
                    }else
                    {
                        updatingList.add( qps.qp);
                    }
                }else
                {
                    integer remove =0;
                    boolean stop =false;
                    quoteproductClass rem;
                    for(quoteproductClass qpa: amendmeList)
                    {
                        if(qpa.qp.Name == qps.qp.Name)
                        {
                            if(qpa.qp.ASP_Reason__c == 'Removed')
                            {
                                rem = qpa;
                                break;
                            }
                        }
                        
                    }
                    for(quoteproductClass qpa: amendmeList)
                    {
                        if(qpa.qp.Name == rem.qp.Name)
                        {
                            //Quote_Product__c qp = oldRemoveMap.get(qpa.qp.Name);
                            system.debug('Quantity-->'+rem);
                            system.debug('Quantity-->'+qpa);
                            if(rem.Quantity< qpa.qp.Quantity__c)
                            {
                                util.setErrorMsg(true, 'You cant remove more than existing quantity.');
                                return;
                            }else if(rem.Quantity== qpa.qp.Quantity__c)
                            {
                                if(qpa.qp.ASP_Reason__c == 'Added')
                                {
                                    deletelist.add(qpa.qp);
                                    removemap.remove(qpa.qp.Name);
                                    stop = true;
                                }else
                                {
                                    
                                    qpa.qp.Labour__c = qps.qp.Labour__c;
                                    qpa.qp.Materials__c = qps.qp.Materials__c;
                                    qpa.qp.ASP_Action__c = 'Remove Parts and Hours';
                                    if(qpa.qp.Labour__c  && !qpa.qp.Materials__c)
                                    qpa.qp.ASP_Action__c = 'Remove Hours Only';
                                    if(!qpa.qp.Labour__c  && qpa.qp.Materials__c)
                                    qpa.qp.ASP_Action__c = 'Remove Parts Only';
                                    updatingList.add(qpa.qp);
                                }
                                
                            }
                            else
                            {
                                qpa.qp.Labour__c = qps.qp.Labour__c;
                                qpa.qp.Materials__c = qps.qp.Materials__c;
                                decimal quan = rem.Quantity - qps.qp.Quantity__c;
                                if(qpa.qp.ASP_Reason__c == 'Added')
                                {
                                    qpa.qp.ASP_Action__c = 'Added Parts and Hours';
                                    if(qpa.qp.Labour__c  && !qpa.qp.Materials__c)
                                    qpa.qp.ASP_Action__c = 'Added Hours Only';
                                    if(!qpa.qp.Labour__c  && qpa.qp.Materials__c)
                                    qpa.qp.ASP_Action__c = 'Added Parts Only';
                                    qpa.qp.Quantity__c = quan;
                                    updatingList.add(qpa.qp);
                                }else if(qpa.qp.ASP_Reason__c == 'Removed')
                                {
                                    qpa.qp.ASP_Action__c = 'Remove Parts and Hours';
                                    if(qpa.qp.Labour__c  && !qpa.qp.Materials__c)
                                    qpa.qp.ASP_Action__c = 'Remove Hours Only';
                                    if(!qpa.qp.Labour__c  && qpa.qp.Materials__c)
                                    qpa.qp.ASP_Action__c = 'Remove Parts Only';
                                    updatingList.add(qpa.qp);
                                }
                            }
                        }
                        if(!stop)
                        remove ++ ;
                    }
                    if(stop)
                    amendmeList.remove(remove);
                
                    
                }   
                //suggestedPayment =+qps.qp.ASP_Impact__c;
                
            }
            
            if(instingList.size()>0)
            insert instingList;
            
            if(updatingList.size()>0)
            {
                set<Id> newset = new set<Id>();
                list <Quote_Product__c> Templist = new  list<Quote_Product__c>();
                for(Quote_Product__c qp: updatingList)
                {
                    if(!newset.contains(qp.Id))
                    {
                        Templist.add(qp);
                        newset.add(qp.Id);
                    }
                }
                update Templist;
            }
            
            if(deletelist.size()>0)
                delete deletelist;
            /*for(quoteproductClass qps: amendmeList)
            {
                qps.qp = queryQuoteProcut(qps.qp.Id);
            }*/
            
            
            populateASP(asp.Id);    
            list<quoteproductClass> temp = new list<quoteproductClass>();
            temp.addall(userDefinedList);
            temp.addall(amendmeList);
            totalVal = calTotal(temp);
            
        }
        
        
        catch (Exception e) 
        {
            seterror(e);
        }
    }
    
    public void addDiscount()
    {
        try{
            
        discount =0.0;
        decimal chargeCustom =0.0;
        
        string cost_cust = ApexPages.currentPage().getParameters().get('cost_cust');
        system.debug('Discount--- >'+cost_cust);
        
        if(cost_cust!='' && cost_cust!=null)
        chargeCustom = decimal.valueof(cost_cust.trim().normalizeSpace());
        else
        chargeCustom = asp.Charge_to_Customer__c;
        
        if(addmap.containskey(disountProd.Name))
        {
            
            delete (addmap.get(disountProd.Name));
        }
        asp =queryASP(asp.Id);
        discount =    asp.Quote_ASP_Unsubmitted_Total__c- chargeCustom ;
        
        asp.Charge_to_Customer__c=chargeCustom;
        customePaymentVar =  (asp.Charge_to_Customer__c!=null ?asp.Charge_to_Customer__c:0.0 )-suggestedPayment;
        update asp;
        
        list<quoteproductClass> templist = new list<quoteproductClass>();
        if(discount!=0)
        {
            Quote_Product__c discountPrd = new Quote_Product__c(Name=disountProd.Name, ASP_Reason__c='Added',ASP_Status__c = 'Entered', ASP__c = asp.id, Product__c =disountProd.Id, ASP_Action__c = 'Discount',
                                                Quantity__c =1, BigMachines_Quote__c = BigMachineId, Cost_Change__c = discount); 
                                                
            discountPrd.Order__c = orderqp;
            orderqp++;
            upsert discountPrd;
            asp = queryASP(asp.Id);
            
            discountPrd = queryQuoteProcut(discountPrd.Id);
            if(addMap.containskey(discountPrd.Name))
            {
                discountClass.qp= discountPrd;
                for(quoteproductClass qps:showList)
                {
                    if(qps.qp.Name=='D001')
                    {
                        qps.qp = discountPrd;
                    }
                }
                
                for(quoteproductClass qps:amendmeList)
                {
                    if(qps.qp.Name=='D001')
                    {
                        qps.qp = discountPrd;
                    }
                }
                
            }else
            {
                discountClass =  new quoteproductClass(discountPrd);
                amendmeList.add(discountClass);
                showList.add(discountClass);
                addTable = true;
            }
            addMap.put(discountPrd.Name,discountPrd);
            cnfBtn = true;
        }else
        {
            addmap.remove(disountProd.Name);
            templist.addall(showlist);
            showlist = new list<quoteproductClass>();
            for(quoteproductClass sh:templist)
            {
                if(sh.qp.Name!=disountProd.Name)
                showList.add(sh);
            }
            templist = new list<quoteproductClass>();
            templist.addall(amendmeList);
            amendmeList = new list<quoteproductClass>();
            for(quoteproductClass am:templist)
            {
                if(am.qp.Name!=disountProd.Name)
                amendmeList.add(am);
            }
        }
        templist = new list<quoteproductClass>();
        templist.addall(amendmeList);
        templist.addall(userDefinedList);
        totalVal = calTotal(templist);
        for(quoteproductClass qps:showList)
        {
            if(qps.qp.ASP_Action__c.contains('Remove') && qps.qp.Materials__c)
            {
                showMaterialInfo = true;
                break;
            }
        }
        
        }catch(exception e)
        {
            if(valBtn)
            {
                util.setErrorMsg(true, 'Please validate before entering charge.');
                return;
            }
            seterror(e); 
        }
        
    }
    
    public void AddUDP()
    {
        
        Quote_Product__c qpNew = new Quote_Product__c(BigMachines_Quote__c=BigMachineId,Quantity__c =1, ASP__c = asp.Id, Materials__c = true, Labour__c = false, ASP_Reason__c = 'Added',ASP_Action__c = 'Add Parts Only',
                                Product__c = '01t2000000275fK' ,Name='UDPQP', User_Defined_Product__c = true,Supplier__c = 'a0920000006Q4RQ',User_Defined_VAT_Rate__c='General VAT');
        insert qpNew;
        quoteproductClass qpClass = new quoteproductClass(qpNew);
        qpClass.updateQp = true;
        userDefinedList.add(qpClass);
        
        //listPQ.add(qpNew); 
        if(userDefinedList != null && userDefinedList.size()>0)
            udpTable =true;
        else
            udpTable =false;
     
        
    }
    
    public void updateUDP()
    {
        try
        {
        list<Quote_Product__c> updUdpList = new list<Quote_Product__c>();
        
        for(quoteproductClass qps: userDefinedList)
        {
            updUdpList.add(qps.qp);
        }
        
         if(updUdpList.size()>0)
        update updUdpList;
        
        for(quoteproductClass qps: userDefinedList)
        {
            qps.qp = queryQuoteProcut(qps.qp.Id);
        }
        list<quoteproductClass> temp = new list<quoteproductClass>();
        temp.addall(userDefinedList);
        temp.addall(amendmeList);
        totalVal = calTotal(temp);
        
       
        
        }catch (Exception e)
        {
            seterror(e);
        }
    }
    
    public void RemoveUDPabove()
    {
          
        list<Quote_Product__c> deleteList = new list<Quote_Product__c>();
        
        string productName ;
        integer j=0;
        for(quoteproductClass qps : userDefinedList)
        {
            if(qps.remove)
            {
                productName = qps.qp.Name;
                deleteList.add(qps.qp);
                break;
                
            }
            j++;
        }
        userDefinedList.remove(j);
        if(userDefinedList.size()==0)
            udpTable =false;
        try{
            delete deleteList;
            
            asp = queryASP(asp.Id);
        }catch (exception e)
        {
            seterror(e); 
        }
        
    }
    
    private decimal calTotal(list<quoteproductClass> qpList)
    {
        decimal total = 0.00;
        decimal partRefTemp = 0.00;
        decimal partAddedTemp = 0.00;
        system.debug('Size-->'+qpList.size()+disountProd.Name);
        for(quoteproductClass qp : qpList)
        {
            system.debug('Each Item-->'+qp);
            if(qp.qp.ASP_Impact__c!=null && qp.qp.Name!=disountProd.Name)
            {
                total += qp.qp.ASP_Impact__c;
                system.debug('Total--->'+total);
            } 
            if(qp.qp.Customer_Charged_Refunded__c ==true && (qp.qp.Labour__c && !qp.qp.Materials__c) ||(!qp.qp.Labour__c && qp.qp.Materials__c) )  
            {
                if(qp.qp.ASP_Reason__c == 'Removed')
                    partRefTemp +=qp.qp.ASP_Impact__c;
                else
                    partAddedTemp +=qp.qp.ASP_Impact__c;
                
            }
            partRefunded = -(partRefTemp);
            partAdded = partAddedTemp;
            
        }
        
        return total;
    }
    
    public void createNew()
    {
        asp = new ASP__c ();
        amendmeList = new list<quoteproductClass>();
        userDefinedList = new list<quoteproductClass>();
        showList = new list<quoteproductClass>();
        addMap = new map<string, Quote_Product__c>();
        removeMap = new map<string, Quote_Product__c>();
        showMap = new map<string, Quote_Product__c>();
        oldRemoveMap = new map<string, Quote_Product__c>();
        sec1 = true;
        valBtn =true;   
        creNew =false;
        aspSec =false;
        sec2=false;
        sec3=false;
        sec4=false;
        sec5=false;
        sec6=false;
        canBtn =true;
        totalVal = 0.0;
        discount =0.0;
    }
    
    public void showSelectedASP()
    {
        if(aspId!=null)
        {
            populateASP(aspId);
            asp.Charge_to_Customer__c = null;
            sec1 = true;
            cnfBtn = true;
            addTable = true;
            sec2 = true;
            sec3=false;
            addBtn =true;
            udpBtn =true;
            aspSec =false;
            sec4=false;
            sec6=false;
            popReuestedItems();
            canBtn =true;
            valBtn = true;
            showField =false;
            system.debug('Finally--->'+totalVal);
        }
    }
    
    public void viewSelectedASP()
    {
        if(aspId!=null)
        {
            populateASP(aspId);
            sec4=true;
            
            addTable = true;
            sec6 = true;
            
        }
        
    }
    
    public void addSelProd()
    {
        if(reqPrdId!=null)
        {
            Quote_Product__c qpNew  = new Quote_Product__c();
            ASP_Requested_Items__c selProd = reqProdMap.get(reqPrdId);
            if(selProd.Product__r.Name =='D001' || selProd.Product__r.Name == 'UDPQP')
            {
                util.setErrorMsg(true, selProd.Product__r.Name+' Can not be processed this way');
                selProd.processed__c = true;
                update selProd;
                return;
            }
            if(selProd.Action__c == 'Add')
            {
                    selProd.Quantity__c = selProd.Quantity__c!=null?selProd.Quantity__c:1;
                    
                    qpNew = new Quote_Product__c(Product__c = selProd.Product__c, Quantity__c = selProd.Quantity__c, ASP__c = asp.Id,BigMachines_Quote__c=BigMachineId, ASP_Reason__c ='Added' , ASP_Action__c ='Add Parts and Hours', Labour__c = true, Materials__c = true );
                    insert qpNew;
                    qpNew = queryQuoteProcut(qpNew.Id);
                    amendmeList.add(new quoteproductClass(qpNew));
                    showList.add(new quoteproductClass(qpNew));
                    addmap.put(selProd.Product__r.Name,qpNew );
                    addTable = true;
                    
            }else if(selProd.Action__c == 'Remove')
            {
                if(existingMap.containskey(selProd.Product__r.Name))
                {
                    qpNew = existingMap.get(selProd.Product__r.Name);
                    qpNew.ASP__c = asp.Id;
                    //qpNew.BigMachines_Quote__c = BigMachineId;
                    qpNew.ASP_Reason__c = 'Removed';
                    qpNew.ASP_Action__c= 'Remove Parts and Hours';
                    qpNew.Materials__c = true;
                    qpNew.labour__c =true;
                    update qpNew;
                    qpNew = queryQuoteProcut(qpNew.Id);
                    amendmeList.add(new quoteproductClass(qpNew));
                    showList.add(new quoteproductClass(qpNew));
                    oldRemoveMap.put(selProd.Product__r.Name,qpNew );
                    addTable = true;
                }else
                {
                    util.setErrorMsg(true, 'This item doesnt exist on the Quote to remove.');
                    
                }
            }
            
            selProd.processed__c = true;
            update selProd;
            popReuestedItems();
            
        }
        
    }
    
    public void rejSelProd()
    {
        if(reqPrdId!=null)
        {
            ASP_Requested_Items__c selProd = reqProdMap.get(reqPrdId);
            selProd.processed__c = true;
            update selProd;
            popReuestedItems();
        }
        
        
    }
    
    public pagereference planJob()
    {
        update jobList;
        date custDate = jobList[0].Customer_Preferred_Date__c;
        if(custDate!=null)
        {
        String cust = custDate.format();
        pagereference page= new pagereference('/apex/JobSearchResults?jobId='+jobList[0].Id+'&custDate='+cust);
        return page;
        }else
        {
            util.setErrorMsg(true, 'Please select Customer Preffered Date.');
            return null;
        }
    }
    
    public void updateAsp()
    {
        try{
        update asp;
        sec1 = false;
        sec2 = false;
        sec3 = false;
        sec4 = true;
        sec5 = false;
        sec6 = true;
        addBtn = false;
        udpBtn = false;
        addTable = true;
        updBtn = false;
        chgBtn =true;
        }
        catch (Exception e)
        {
            seterror(e);
        }
        
        
    }
    
    public void calucalateCustomerPayementVariation()
    {
        decimal total = 0.00;
        //system.debug('Size-->'+qpList.size()+disountProd.Name);
        for(quoteproductClass qp : showList)
        {
            system.debug('Each Item-->'+qp);
            if(qp.qp.ASP_Impact__c!=null && qp.qp.Name!=disountProd.Name && qp.qp.Customer_Charged_Refunded__c == true)
            {
                total += qp.qp.ASP_Impact__c;
                
            }   
        }
        system.debug('Total--->'+total);
        suggestedPayment = total ;
        system.debug('suggestedPayment-->'+suggestedPayment);
        system.debug(asp.Charge_to_Customer__c);
        customePaymentVar = total== 0.00 ? 0.00 : (asp.Charge_to_Customer__c!=null ?asp.Charge_to_Customer__c-suggestedPayment:-suggestedPayment) ;
        system.debug('suggestedPayment-->'+suggestedPayment);
        system.debug('suggestedPayment-->'+customePaymentVar);
        
    }
    
    
    
}