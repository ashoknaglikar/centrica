/**
* @author       Kim Roth        
* @date         06/11/2013
* @description  This Class is the controller extension class for Visualforce Page "ViewBacklog".
*
*   -----------------------------------------------------------------------------
*   Developer               Date                Description
*   -----------------------------------------------------------------------------
*   
*   Kim Roth                06/11/2013          Initial version                                             
*/

global with sharing class ViewBacklog {

    public List<Work_Product__c> releaseBacklogList {get;set;}
    public List<Work_Product__c> iterationBacklogList {get;set;}
    public List<Work_Product__c> productBacklogList {get;set;}
    public List<Work_Product__c> bugList {get;set;}
     public List<Work_Product__c> lowPriority {get;set;}
    public List<Iteration__c> iterationList {get;set;}
    public List<SS_Release__c> releaseList {get;set;}
    public List<Project_Overview__c> projectList {get;set;}
    public Id selectedProjectId {get;set;}
    public boolean isHidePastIterations {get; set;}
    public boolean isHidePastReleases {get; set;}
    public boolean isHideClosedProjects {get; set;}
    public Map<String, planTabColorScheme__c> colorScheme {get;set;}
    
    private List<ss_release__c> completeReleaseList;
    private List<iteration__c> completeIterationList;
    private List<work_product__c> completeWPList;
    private List<work_product__c> completeBugList;
    private RecordType parentUserStoryRecordType;
    public Project_Overview__c currentProject{get;set;}
   
    public String selectionFilter {
        get {
            if (selectionFilter == null)
                selectionFilter ='All';
            return selectionFilter;
                
        }
        set;
    }
    public List<SelectOption> filterByOptions {
        get {
            SelectOption allOption = new SelectOption('All','All'); 
            SelectOption storyOption = new SelectOption('User Stories','User Stories');
            SelectOption defectOption = new SelectOption('Defects','Defects');                                   
            return new System.SelectOption[]{storyOption, defectOption, allOption};
        }
        private set;
    }
    private ProjectSelection__c projectSelection = new ProjectSelection__c();
    public string DefectRecordType {get;set;}
    public string userStoryRecordType {get;set;}
    public string lowPriorityRecordType{get;set;}
    
    
    
    /**
    * @author       Kim Roth
    * @date         06/11/2013
    * @description  Method that creates lists for iteration, product and release backlog
    * @param        <none> 
    * @return       <none>
    */  
    public ViewBacklog() { 
        isHidePastIterations = true;
        isHidePastReleases = true;
        isHideClosedProjects = true;
        
        if(ApexPages.currentpage().getParameters().get('isProjectCloseToggle')=='true')
        {
            isHideClosedProjects = true;
        }
        else if(isHideClosedProjects == null){isHideClosedProjects = false;}
        if(selectedProjectId == null || isHideClosedProjects){
            selectedProjectId = getItems()[0].getValue();
            
        }
         //get color scheme from custom settings
        colorScheme = planTabColorScheme__c.getAll();
        
         // Retrieve the user's last project selection from the custom setting
        ProjectSelection__c proj = ProjectSelection__c.getInstance(UserInfo.getUserId());
        if (proj.projectId__c != null) {
            selectedProjectId = proj.projectId__c;
        }     

          
        currentProject = [Select id, Name from Project_Overview__c where id = : selectedProjectId] ;
        //parentUserStoryRecordType = [SELECT id FROM RecordType WHERE name = 'Parent User Story' AND sobjectType = 'Work_Product__c'];   
        
        DefectRecordType = RecordTypeIdHelper.getRecordTypeId('Work_Product__c', 'Defect');
        userStoryRecordType = RecordTypeIdHelper.getRecordTypeId('Work_Product__c', 'User Story'); 
        lowPriorityRecordType = RecordTypeIdHelper.getRecordTypeId('Work_Product__c', 'Low Priority');   
      //  selectedProjectId = ApexPages.currentPage().getParameters().get('project');
        
        
        //query for iterations
        iterationList = completeIterationList = [select id, name, state__c, start_date__c, end_date__c, plan_estimate__c, planned_velocity__c, Current_Iteration__c from iteration__c where Project_Overview__c = :selectedProjectId order by start_date__c desc];
        
        //query for releases
        releaseList = completeReleaseList = [select id, name, start_date__c, release_date__c from ss_release__c where Project_Overview__c = :selectedProjectId order by start_date__c desc];        
        
        //query for release backlog
        releaseBacklogList = [select id, name, work_product_id__c, plan_estimate__c, iteration__c, state__c, blocked__c, iteration__r.Name, ss_release__r.Name, rank__c, recordtypeid, is_defect__c 
                              ,Platform_Acronym__c, StyleClass__c  from Work_Product__c 
                              where Project_Overview__c = :selectedProjectId AND ss_release__c <> NULL and iteration__c = NULL 
                              order by rank__c asc]; //release is not null
        
        //query for iteration backlog
        
        iterationBacklogList = [select id, name, work_product_id__c, plan_estimate__c, iteration__c, state__c, blocked__c, iteration__r.Name, ss_release__r.Name, rank__c, is_defect__c 
                                ,Platform_Acronym__c, StyleClass__c,RecordTypeId from work_Product__c 
                                where Project_Overview__c = :selectedProjectId AND iteration__c <> NULL 
                                order by rank__c asc]; // iteration is not null                             
        
        //query for product backlog
        productBacklogList = completeWPList = [select id, name, work_product_id__c, plan_estimate__c, iteration__c, state__c, blocked__c, iteration__r.Name, ss_release__r.Name, rank__c, is_defect__c, Record_Type_Name__c 
                              ,Platform_Acronym__c, StyleClass__c,RecordTypeId from work_Product__c 
                              where Project_Overview__c = :selectedProjectId AND iteration__c = NULL and ss_release__c = NULL and recordtypeid = :userStoryRecordType
                              order by rank__c asc];
                              
        bugList = completeBugList = [select id, name, work_product_id__c, plan_estimate__c, iteration__c, state__c, blocked__c, iteration__r.Name, ss_release__r.Name, rank__c, is_defect__c, Record_Type_Name__c 
                              ,Platform_Acronym__c, StyleClass__c,RecordTypeId from work_Product__c 
                              where Project_Overview__c = :selectedProjectId AND iteration__c = NULL and ss_release__c = NULL and recordtypeid = :DefectRecordType
                              order by rank__c asc];   
                            
        lowPriority = [select id, name, work_product_id__c, plan_estimate__c, iteration__c, state__c, blocked__c, iteration__r.Name, ss_release__r.Name, rank__c, is_defect__c, Record_Type_Name__c 
                              ,Platform_Acronym__c, StyleClass__c,RecordTypeId from work_Product__c 
                              where Project_Overview__c = :selectedProjectId AND iteration__c = NULL and ss_release__c = NULL and recordtypeid = :lowPriorityRecordType
                              order by rank__c asc];
    
        hidePastReleases();
        hidePastIterations();
        hideClosedProjects();
                              
    }

    @RemoteAction
    global static String updateWorkProductRank(List<Id> toIds,   String toRelease,   String toIteration,   Boolean toAscending, 
                                             List<Id> fromIds, String fromRelease, String fromIteration, Boolean fromAscending, string toRecordType, string fromRecordType) {
      
        List<Work_Product__c> workProducts = new List<Work_Product__c>();
      Integer count = 0;
        toRelease     = String.isEmpty(toRelease)     ? null : toRelease;
        toIteration   = String.isEmpty(toIteration)   ? null : toIteration;
        fromRelease   = String.isEmpty(fromRelease)   ? null : fromRelease;
        fromIteration = String.isEmpty(fromIteration) ? null : fromIteration;
        toRecordType = String.isEmpty(toRecordType) ? null : toRecordType;
        fromRecordType = String.isEmpty(fromRecordType) ? null : fromRecordType;
        
        for(Id wpId : toIds) {
            Work_Product__c wp = new Work_Product__c();
            wp.Id = wpId;
            wp.Rank__c = toAscending ? count : toIds.size() - count - 1;
            wp.Iteration__c = toIteration;

            if((toRelease <> NULL && toRelease != fromRelease) || (toRelease == NULL && toIteration == NULL))
              { wp.SS_Release__c = toRelease;}          
          count++;
          workProducts.add(wp);
          
          if(toRecordType!=fromRecordType)
          {
              wp.RecordTypeId = toRecordType;
          }
        }
      
      if(toRelease != fromRelease || toIteration != fromIteration) {
        count = 0;
        for(Id wpId : fromIds) {
                workProducts.add(new Work_Product__c(
                Id            = wpId,
                Rank__c       = fromAscending ? count : fromIds.size() - count - 1,
                Iteration__c  = fromIteration
                ));
            
            count++;
        }
      }

        try{update workProducts;} catch(DmlException e) { system.debug(e.getDmlMessage(0));
           return e.getDmlMessage(0);
        }

        return 'success';
      
    }
     
    /**
    * @author       Kim Roth
    * @date         06/25/2013
    * @description  Method to return select options for each project
    * @param        <none>
    * @return       options - List of select options
    */  
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<Project_Overview__c> projectList = new List<Project_Overview__c>();
        RecordType projectRT = new RecordType();
        
        projectRT = [select id FROM RecordType WHERE name = 'Agile Project' AND sObjectType = 'Project_Overview__c'];
        if(isHideClosedProjects)
        {
            projectList = [select id, name from Project_Overview__c where Project_Stage__c != 'Closed' AND recordTypeID =: projectRT.id ORDER BY name];
        }
        else
        {
            projectList = [select id, name from Project_Overview__c where recordTypeID =: projectRT.id ORDER BY name];
        }
        if(projectList.size() > 0) {
            for(Project_Overview__c project : projectList){
                options.add(new SelectOption(project.id, project.name));
            }
        } else {
            options.add(new SelectOption(projectRT.id, '--None--'));
        }
        return options;
    }
    
    
    
    /**
    * @author       Yael Perez
    * @date         09/23/2013
    * @description  Helper method to verify if a project which was retrieved from the custom setting exists as an option in the
    *               Project selectOption picklist.
    * @param        Project ID
    * @return       true if the project exists in the picklist
    */
    private boolean isStoredProjectExistInProjectPicklist(Id projId) {
        Project_Overview__c po;
        try {
            po = [select id, name from Project_Overview__c where id =: projId];
        } catch (Exception ex) {
            return false;
        }
        for (SelectOption option : getItems()) {
            if (option.getValue().equalsIgnoreCase(po.Id)) {
                return true;
            }
        }
        return false;
    }
    
    public PageReference selectProject() {
        // Store project ID in custom setting.
        projectSelection = ProjectSelection__c.getInstance(UserInfo.getUserId());
        projectSelection.projectId__c = selectedProjectId;
        try { upsert projectSelection; } catch (System.DmlException ex) {
            System.debug('Exception thrown while trying to upsert custom setting: ' + ex.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while loading the selected project, please contact your administrator.﻿');
            ApexPages.addMessage(myMsg);
        }
        
        // Send the user to the backlog page for the selected project
        PageReference projectBacklogPage = Page.ViewBacklog;
        projectBacklogPage.getParameters().put('project', selectedProjectId);        
        projectBacklogPage.setRedirect(true);
        // return null;
        return projectBacklogPage;
    }
    
    /**
    * @author       Yael Perez
    * @date         09/09/2013
    * @description  Action invoked when filtering the WP list on the plan page.
    * @param        <none>
    * @return       null
    */
    public PageReference filterWorkProducts() {
        List<Work_Product__c> filteredWPList = new List<Work_product__c>();

        if (selectionFilter == 'Defects') {
            for (Work_product__c wp : completeWPList) {
                if (wp.Record_Type_Name__c.equalsignorecase('Defect')) {
                    filteredWPList.add(wp);
                }                
            }     
            productBacklogList = filteredWPList;       
        } else if (selectionFilter == 'User Stories') {
            for (Work_product__c wp : completeWPList) {
                if (wp.Record_Type_Name__c.equalsignorecase('User Story')) {
                    filteredWPList.add(wp);
                }                
            }
            productBacklogList = filteredWPList;        
        } else if (selectionFilter == 'All') {
            productBacklogList = completeWPList;
        }
        return null;
    }
        
    /**
    * @author       Yael Perez
    * @date         09/09/2013
    * @description  Action invoked when hiding old iterations.
    * @param        <none>
    * @return       null
    */    
    public PageReference hidePastIterations() {
        List<Iteration__c> iterList = new List<Iteration__c>();
        if (isHidePastIterations) {
            for (iteration__c iteration : iterationList) {
                if (iteration.current_iteration__c) {
                    iterList.add(iteration);
                }
            }
        } else if (!isHidePastIterations) {
            iterList = completeIterationList;
        }
        iterationList = iterList;
        return null;
    }
 
    /**
    * @author       Yael Perez
    * @date         09/09/2013
    * @description  Action invoked when hiding past releases.
    * @param        <none>
    * @return       null
    */       
    public PageReference hidePastReleases() {
        List<ss_release__c> relList = new List<ss_release__c>();
        if (isHidePastReleases) {
            for (ss_release__c release : releaseList) {
                if (release.release_date__c >= Date.Today()) {
                    relList.add(release);
                }
            }
        } else if (!isHidePastReleases) {
              relList = completeReleaseList;        
        }
        releaseList = relList;
        return null;
    }

    public PageReference hideClosedProjects()
    {
        //was a hidden project selected when the hide option was toggled?
        if(!isStoredProjectExistInProjectPicklist(selectedProjectId)){
            return redirectToStickyProject();
        }
        return null;
    }
    
    /**
    * @author       Tarren Anderson
    * @date         10/01/2013
    * @description  Redirect if user doesn't have a custom setting, or the project ID no longer exists.
    * @param        <none>
    * @return       null
    */    

     public PageReference redirectToStickyProject() {
         ProjectSelection__c proj = ProjectSelection__c.getInstance(UserInfo.getUserId());
         //check if custom setting exists, or if the Project ID is not an option in the Project picklist
         if (proj.projectId__c == null || !isStoredProjectExistInProjectPicklist(proj.projectId__c)) 
        {
            //get id of first project in the picklist
            selectedProjectId = getItems()[0].getValue();
            //set the custom setting equal to the ID of the first project
            proj.projectId__c = selectedProjectId;
                //UPDATE CUSTOM SETTING FOR PROJECT SELECTION
                try { upsert proj; } catch (System.DmlException ex) {
                    System.debug('Exception thrown while trying to upsert custom setting: ' + ex.getMessage());
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while loading the selected project, please contact your administrator.﻿');
                    ApexPages.addMessage(myMsg);
                }
            //return the page reference    
            PageReference projectBacklogPage = Page.ViewBacklog;
            projectBacklogPage.getParameters().put('project', selectedProjectId); 
            if(isHideClosedProjects)
            {
                projectBacklogPage.getParameters().put('isProjectCloseToggle', 'true'); 
            }       
            projectBacklogPage.setRedirect(true);
            return projectBacklogPage;
        }
        return null;
     
    }


    /**
    * @author       Tarren Anderson
    * @date         10/06/2013
    * @description  Return map containing color scheme from custom settings.
    * @param        <none>
    * @return       Map
    */   
        public Map<String, planTabColorScheme__c> getMyColor()
    {
        return colorScheme;
        
    }
    
    
    
}