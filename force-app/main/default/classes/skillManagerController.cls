public with sharing class skillManagerController {
    // This page has been setup to aide the data team to add skill quicker to the installers via this one screen rather than
    // via the native screen.
    // Added by Philip Dennison - 
   
    public list<employee_Skills__c> skillList{get;set;}
    public list<skillClass> skillClassLst {get;set;}
    public string skillsAdd {get;set;}
    public string skillsPresent {get;set;}
    
    //Ashok variables
    public string errorMsg {get;set;}
    public boolean nonInstaller{get;set;}
    public boolean newSkillTb{get;set;}
    public boolean oldskillTb{get;set;}
    
    public id employeeid = ApexPages.currentPage().getParameters().get('empid');  // get id of employee in url
    
    // This method runs through each individual skills method and adds the skill where _chose = true.
     public PageReference addSkills() {
        list<employee_skills__c> newSkills = new list<employee_skills__c>();
        for(skillClass s : skillClassLst)
        {
            if(s.isSelect)
            {
             employee_skills__c e = new employee_skills__c(Skill_Name__c = s.skillName.trim(), Own_Jobs_Only__c = s.ownJobs, employee__c = employeeid );
            //insert NewMSkill;
            newSkills.add(e);   
            }
        }
        if(newSkills.size()>0)
        {
            insert newSkills;
            return (new PageReference('/'+employeeid));
        }else{
             errorMsg = 'Please Select atleast one Skill to add.';
             setErrorMsg();
             return null;
        }
   
    }
     public PageReference goBack() {
     return (new PageReference('/'+employeeid));
     }
     
    public skillManagerController() 
    {
        Id empId = ApexPages.currentPage().getParameters().get('empid');
        if(empId!=null)
        {
            skillsAdd ='Skills To Add';
            skillsPresent = 'Skills Present';
            Employee__c e = [Select id, Resource_Type__c from Employee__c where Id=: employeeid];
            if(e.Resource_Type__c != 'Installer')
            {
                errorMsg = 'Employee is not a Installer';
                nonInstaller= true;
                setErrorMsg();
                
            }
            Schema.DescribeFieldResult skillField = Employee_Skills__c.Skill_Name__c.getDescribe();
            //List <Schema.PicklistEntry>  
            List <Schema.PicklistEntry>  picklistskills = skillField.getPicklistValues();
            
            skillList = [SELECT id, name, Employee__c, Own_Jobs_Only__c, Skill_Name__c, createdByID, createdDate 
                     FROM employee_skills__c 
                     WHERE employee__c =:ApexPages.currentPage().getParameters().get('empid')
                     ORDER BY skill_Name__c];
                     
           Map<string,boolean> skillmap = new  Map<string,boolean>();
           if(skillList.size()>0) 
           {                    
               oldskillTb = true;
               for(employee_skills__c es:skillList)
               {
                    if(!skillmap.containskey(es.Skill_Name__c.trim()))
                    {
                        skillmap.put(es.Skill_Name__c.trim(),true);
                    }
               }
           }       
           newSkillTb = false;
           skillClassLst =new list<skillClass>();
           for(Schema.PicklistEntry s : picklistskills)
           {
                
                if(!skillmap.containskey(s.getLabel()))
                {
                        newSkillTb= true;
                        skillClass sc = new skillClass(s);
                        if(!(
                        s.getLabel().contains('Electrical')||
                        s.getLabel().contains('Specialist Building')||
                        s.getLabel().contains('Scaffolder')))
                        {
                            sc.ownJobs = true;  
                        }   
                        skillClassLst.add(sc);
                    
                } 
           }
           if(!newSkillTb)
           {
                errorMsg = 'All Skills are already present for this Employee.';
                setErrorMsg();  
           }
            
        }
    
     }
            
        public class skillClass{
            
            public boolean isSelect{get;set;}
            public boolean ownJobs{get;set;}
            public String skillName{get;set;}
            
            public skillClass(Schema.PicklistEntry p)
            {
                isSelect = false;
                ownJobs = false;
                skillName = p.getLabel();
            }
            
            
        }
        
        public void setErrorMsg()
        {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.error, errorMsg);
            ApexPages.addMessage(msg);
        }
}