public with sharing class copyConsumableOrder {
    Public Consumables_Requests__c conReq {get;set;}
    public list<conItemClass> conClassList {get;set;}
    public decimal total {get;set;}
    public string totalString {get;set;}
    public boolean needApp {get;set;}
    public boolean shpngBasket {get;set;}
    public boolean submitted {get;set;}
    Utilities util = new Utilities();
    public boolean isImportant{get;set;}
    public string orderName {get;set;}
    public boolean cnfDel {get;set;}
    public boolean preExist{get;set;}
    Id LoggedinUser;
    boolean copyOrder;
    public copyConsumableOrder()
    {
    	preExist= false;
    	LoggedinUser = userinfo.getuserId();
    	id conReqid = System.currentPageReference().getParameters().get('crId');
        shpngBasket = (System.currentPageReference().getParameters().get('Bas')=='t'?true:false);
        copyOrder = System.currentPageReference().getParameters().get('isCopy')=='true'?true:false;
    	if(copyOrder)
    	{
	    	try{
	    		conReq = [Select id, Name, Request_Total_Value__c,Item_Count__c from Consumables_Requests__c where IsShoppingBasket__c = true and Status__c = 'In Progress' and CreatedById = :LoggedinUser limit 1];
	    		if(conReq!=null)
	    		preExist = true;
	    		util.setErrorMsg(True, 'You cant copy order, as below order needs attention first.');
	    		
	    	}catch (Exception e)
	    	{
	    		preExist = false;
	    		
	    	}
    	}
    	if(!preExist)
    	{
            totalString ='0.00';
            
            conReq = [Select c.Status__c, c.Raised_By__c, c.District__c,Request_Total_Value__c,Employee_ID__c,Item_Count__c,Notes__c,
                      (Select Item_Requested__r.Sharepoint_URL__c, Item_Requested__r.ImageName__c,Capital_Item__c, Cost_Each__c, Item_Requested__c, Line_Total__c, Not_Ordered__c,  
                      Other_Desciption__c, Quantity__c, Short_Description__c, Product_Code__c,Notes__c,Item_Requested__r.Image_URL__c,
                      Item_Requested__r.Unit_Quantity__c,Item_Requested__r.Max_Quantity__c, Item_Requested__r.CHI_Lead__c,Job__c,CHILead__c   From Consumable_Items__r),Order_Name__c , 
                      Employee__r.District__r.Authorisation_Value__c,Employee__r.Employee_Number__c From Consumables_Requests__c c where id = :conReqid ];
           SYSTEM.DEBUG('--->'+conReq.Consumable_Items__r+conReq);
           conClassList  = new list<conItemClass>();
           /*
           map<string, string> codeImageURLMap = new map<string, string>();
           for(Consumable_Items__c con : conReq.Consumable_Items__r)
           {
               codeImageURLMap.put(con.Item_Requested__r.ImageName__c, null);
           }
           
           try{
               if(!test.isRunningTest()){
               for(items_SharepointVia360__x item : [select id, DisplayUrl,DownloadUrl__c, Name__c from items_SharepointVia360__x where name__c in :codeImageURLMap.keyset()])
               {
                    codeImageURLMap.put(item.Name__c, item.DownloadUrl__c);   
               }
                   
               }
           } catch (exception e)
           {
               
           }*/
           
           for(Consumable_Items__c con : conReq.Consumable_Items__r)
           {
               //string url = codeImageURLMap.containskey(con.Item_Requested__r.ImageName__c)?codeImageURLMap.get(con.Item_Requested__r.ImageName__c):'';
               conClassList.add(new conItemClass(con, null));
          
           
               total = conReq.Request_Total_Value__c;   
               if(total>conReq.Employee__r.District__r.Authorisation_Value__c) 
               needApp =true;
               totalString = total.toplainstring(); 
           }       
    	}            
    }
    
    public class conItemClass{
        public boolean isSelected {get;set;}
        public Consumable_Items__c conItem {get;set;}
        public integer Quantity {get;set;}
        public string colour {get;set;}
        public string url{get;set;}
        public conItemClass(Consumable_Items__c con, string url)
        {
           this.url = url;
            conItem = con;
            conItem.CHILead__c= new opportunity().id;
            Quantity = con.Quantity__c.intvalue();
            isSelected = false;
            colour = 'black';
            if(con.Quantity__c >con.Item_Requested__r.Max_Quantity__c)
            colour = 'red';
        }
    }
    
    public void recalculatePrice()
    {
       decimal temptotal =0;
	   for(conItemClass con : conClassList )
       {
           if(con.Quantity>con.conItem.Item_Requested__r.Max_Quantity__c)
           {
               con.colour = 'color:red;font-weight:bold';
               util.setErrorMsg(true, 'One or more items exceeds the maximum quantity.');
           }else
           {
           temptotal += (con.Quantity*con.conItem.Cost_Each__c);
           con.colour = 'color:black';
           }
       }
       total = temptotal;
       totalString = total.toplainstring();
       if(total>= conReq.Employee__r.District__r.Authorisation_Value__c)
       needApp =true;
       else
       needApp =false;
    }
    
    public void Submit()
    {
        try
        {
        if(conClassList.size()>0){
            for(conItemClass cItem: conClassList){
               
               if(cItem.conItem.Item_Requested__r.CHI_Lead__c==true &&  cItem.conItem.CHILead__c==null){
               util.setErrorMsg(false, 'CHI Lead number is mandatory');
               } 
                
            }
        }
        if(shpngBasket)
            {
            submitted = True;
            list<Consumable_Items__c> conItems = new list<Consumable_Items__c>();
            if(conClassList.size()>0)
            {
            conReq.Status__c = 'Submitted';
            update conReq;
            for(conItemClass c: conClassList)
            {
            conItems.add(new Consumable_Items__c(id=c.conItem.id,Quantity__c=c.Quantity, CHILead__c = c.conItem.CHILead__c));
            //conItems.add(c.conItem);
            if(c.conItem.Item_Requested__r.CHI_Lead__c==true &&  c.conItem.CHILead__c==null){
                submitted = False;
            }
            }
            update conItems;
            
           
            }
            else
            util.setErrorMsg(false, 'Order Cannot be empty.');
            
            }
        
        else if(copyOrder)
        {
        	if(conClassList.size()>0)
        	 {
                Consumables_Requests__c con_Ins = new Consumables_Requests__c(Status__c = 'In Progress', IsShoppingBasket__c = true,Employee__c = conReq.Employee__c ,Employee_ID__c=conReq.Employee_ID__c);
                system.debug('Before Creating---->');
                insert con_Ins;
                 system.debug('After Creating---->'+con_Ins);
                list <Consumable_Items__c> conItem_Ins = new list <Consumable_Items__c>();
                for(conItemClass c:conClassList)
                {
                        conItem_Ins.add(new Consumable_Items__c(Item_Requested__c=c.conItem.Item_Requested__c, Quantity__c=c.Quantity,Request__c=con_Ins.Id, CHILead__c = c.conItem.CHILead__c));
                }
                if(conItem_Ins.size()>0)
                insert conItem_Ins;
                con_Ins.Status__c = 'Submitted';
                system.debug('Before Updating---->'+conReq);
                update con_Ins;
                submitted = true; 
        	 }	
        }else
        {	
        	 if(conClassList.size()>0)
        	 {
                /*Consumables_Requests__c con_Ins = new Consumables_Requests__c(Status__c = 'In Progress', IsShoppingBasket__c = true,Employee__c = conReq.Employee__c ,Employee_ID__c=conReq.Employee_ID__c);
                system.debug('Before Creating---->');
                insert con_Ins;
                 system.debug('After Creating---->'+con_Ins);
                list <Consumable_Items__c> conItem_Ins = new list <Consumable_Items__c>();
                for(conItemClass c:conClassList)
                {
                        conItem_Ins.add(new Consumable_Items__c(Item_Requested__c=c.conItem.Item_Requested__c, Quantity__c=c.Quantity,Request__c=con_Ins.Id));
                }
                if(conItem_Ins.size()>0)
                insert conItem_Ins;*/
                
                conReq.Status__c = 'Submitted';
                system.debug('Before Updating---->'+conReq);
                update conReq;
                system.debug('After Updating---->'+conReq);
                //conReq = con_Ins;
                submitted = true; 
        	 }else  
        	 util.setErrorMsg(false, 'Order Cannot be empty.');
        }
        }catch (exception e)
        {
            
            if(e.getmessage().Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                list<string> error = e.getmessage().split(',');
                util.setErrorMsg(true, error[1]);
            }else
            util.setErrorMsg(true, e.getmessage());
            
        }
        
        
    }
    public pagereference Discard()
    {
        if(shpngBasket && conReq != null)
        {
                delete conReq;
        }
        PageReference pageRef = new PageReference('/apex/ConsumableSearch');
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    public void confirmDelete()
    {
        util.setErrorMsg(false, 'This will Delete Whole Order.');
        submitted = true;
        cnfDel = true;
    }
    public pagereference goToShpngBasket()
    {
        try
        {
        if(!shpngBasket)
        {
                Consumables_Requests__c con_Ins = new Consumables_Requests__c(Status__c = 'In Progress', IsShoppingBasket__c = true,Employee__c = conReq.Employee__c ,Employee_ID__c=conReq.Employee_ID__c);
                insert con_Ins;
                list <Consumable_Items__c> conItem_Ins = new list <Consumable_Items__c>();
                for(conItemClass c:conClassList)
                {
                        conItem_Ins.add(new Consumable_Items__c(Item_Requested__c=c.conItem.Item_Requested__c, Quantity__c=c.Quantity,Request__c=con_Ins.Id));
                }
                if(conItem_Ins.size()>0)
                insert conItem_Ins;
                
                
        }else
        {
        	if(conReq!=null)
        	update conReq;
        	if(conClassList.size()>0)
            {
            	list<Consumable_Items__c> conItems = new list<Consumable_Items__c>();
            	for(conItemClass c: conClassList)
            	{
            		conItems.add(new Consumable_Items__c(id=c.conItem.id,Quantity__c=c.Quantity));
            		
            	}
            	update conItems;
            }
        	
        }
        PageReference pageRef = new PageReference('/apex/ConsumableSearch');
        pageRef.setRedirect(true);
        return pageRef;
        }
        catch (exception e)
        {
            if(e.getmessage().Contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                list<string> error = e.getmessage().split(',');
                util.setErrorMsg(true, error[1]);
            }else
            util.setErrorMsg(true, e.getmessage());
            return null;
        }
    }
    
    public void RemoveItems()
    {
        list <Consumable_Items__c> conItem_Del = new list <Consumable_Items__c>();
        for(integer i =0; i<conClassList.size();i++)
        {
                if(conClassList[i].isSelected)
                {
                    conItem_Del.add(conClassList[i].conItem);
                    total -= (conClassList[i].conItem.Cost_Each__c *conClassList[i].Quantity);
                    if(total<conReq.Employee__r.District__r.Authorisation_Value__c) 
          		    needApp =false;
                    totalString = total.toplainstring();
                    conClassList.remove(i);
                }
                
        }
        if(shpngBasket && conItem_Del.size()>0)
        {
            delete conItem_Del;
        }
        if(conItem_Del.size()==0)
        {
            util.setErrorMsg(true, 'Please select some items to remove.');
        }
    }
    public void cancel()
    {
        submitted = false;
        cnfDel = false;
    }
    
    public pagereference homePage()
    {
    	return (new pagereference('/apex/ConsumableRequestListView'));
    }
    
    public pagereference continue_Btn()
    {
    	pagereference p = new pagereference('/apex/copyConsumableOrder?isCopy=false&crId='+conReq.id+'&bas=t');
    	p.setRedirect(true);
    	return (p);
    }
    
    public void CreateCopyOrder()
    {
    	if(!shpngBasket && conClassList.size()>0)
    	 {
            Consumables_Requests__c con_Ins = new Consumables_Requests__c(Status__c = 'In Progress', IsShoppingBasket__c = true,Employee__c = conReq.Employee__c ,Employee_ID__c=conReq.Employee__r.Employee_Number__c);
            system.debug('Before Creating---->');
            insert con_Ins;
            
            list <Consumable_Items__c> conItem_Ins = new list <Consumable_Items__c>();
            for(conItemClass c:conClassList)
            {
                    conItem_Ins.add(new Consumable_Items__c(Item_Requested__c=c.conItem.Item_Requested__c, Quantity__c=c.Quantity,Request__c=con_Ins.Id));
            }
            if(conItem_Ins.size()>0)
            insert conItem_Ins;
            
            conReq = [Select c.Status__c, c.Raised_By__c, c.District__c,Request_Total_Value__c,Employee_ID__c,Item_Count__c,Notes__c,
                      (Select Capital_Item__c, Cost_Each__c, Item_Requested__c, Line_Total__c, Not_Ordered__c,  
                      Other_Desciption__c, Quantity__c, Short_Description__c, Product_Code__c,Notes__c,Item_Requested__r.Image_URL__c,
                      Item_Requested__r.Unit_Quantity__c,Item_Requested__r.CHI_Lead__c , Job__c,CHILead__c  From Consumable_Items__r),Order_Name__c , 
                      Employee__r.District__r.Authorisation_Value__c,Employee__r.Employee_Number__c From Consumables_Requests__c c where id = :con_Ins.Id ];
         }
    }
    
}