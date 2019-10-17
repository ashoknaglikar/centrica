public class ContactEditViewComponentController {
	List<Contact> conList = new List<Contact>();
	List<ContactInfo> coninfoList = new List<ContactInfo>();
	public String ContactAddress {get; set;} 
	public List<Contact> getConList(){
        return conList;
    }
    
    public void setConList(List<Contact> conlst){
        if(conlst!=null){
            conList = conlst;
        }
    }
    
   /* 
   
    public class ContactInfo{
        public Contact contact{get; set;}
        public Boolean AddSlct{get; set;}
        public Boolean ConSlct{get; set;}
        public String AddStrt{get;set;}
        public String AddCty{get;set;}
        public String AddStat{get;set;}
        public String AddCntr{get;set;}
        public String AddZip{get;set;}
        public String ConAdd{get;set;}
     }  
    
    */
    
    public List<ContactInfo> getConInfoList(){
    	return coninfoList;
    }
    
    public void setConInfoList(List<ContactInfo> coninfoListRec){
    	//List<ContactInfo> coninfoList = new List<ContactInfo>();
    	coninfoList = coninfoListRec;
    	 /*System.debug('------------- going for if');
    	if(coninfoListRec.size()>0){
    		System.debug('------------- going in if goindg for FOR');
    		for(ContactInfo cInf:coninfoListRec){
    			ContactInfo newcontact = cInf;
    			Contact c = cInf.contact;
    			System.debug('------------- going in if goindg for cInf.contact = ' + c);
				if(c != null){
					String Address;
					if(Address == null && c.MailingStreet != null){
		            	Address = c.MailingStreet;
		            }
		            else if(Address != null && c.MailingStreet != null){
		            	Address = Address+','+c.MailingStreet;
		            }
		            if(Address == null && c.MailingCity != null){
		            	Address = c.MailingCity;
		            }
		            else if(Address != null && c.MailingCity != null){
		            	Address = Address+','+c.MailingCity;
		            }
		            if(Address == null && c.MailingState != null){
		            	Address = c.MailingState;
		            }
		            else if(Address != null && c.MailingState != null){
		            	Address = Address+','+c.MailingState;
		            }
		            if(Address == null && c.MailingCountry != null){
		            	Address = c.MailingCountry;
		            }
		            else if(Address != null && c.MailingCountry != null){
		            	Address = Address+','+c.MailingCountry;
		            }
		            if(Address == null && c.MailingPostalCode != null){
		            	Address = c.MailingPostalCode;
		            }
		            else if(Address != null && c.MailingPostalCode != null){
		            	Address = Address+','+c.MailingPostalCode;
		            }
		            newcontact.ConAdd = Address;
		            System.debug('------------- setting address = ' + Address);
		            coninfoList.add(newContact);
				}
    		}
    	}*/
    }
}