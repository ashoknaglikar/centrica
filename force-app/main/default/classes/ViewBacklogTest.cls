/**
* @author       Kim Roth        
* @date         08/05/2013
* @description  Test class for ViewBacklog
*
*   -----------------------------------------------------------------------------
*   Developer               Date                Description
*   -----------------------------------------------------------------------------
*   
*   Kim Roth                08/05/2013          Initial version                                             
*/

@isTest(SeeAllData=false)
public class ViewBacklogTest {

	static testMethod void updateWorkProductRankTester() {

		//Create data for test 
		PMToolkitTestDataCreator.dataCreator();
	
		List<ID> wpIDsTo = new List<ID>();
		List <ID> wpIDsFrom = new List<ID>();
		String toRelease = NULL;
		String toIteration = NULL;
		String fromRelease = NULL;
		String fromIteration = NULL;
		Boolean toAscending = true;
		Boolean fromAscending = true;
		
		//Query for data
		Work_Product__c wp1 = [SELECT id, ss_release__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 1'];
		Work_Product__c wp2 = [SELECT id, ss_release__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 2'];
		Iteration__c iteration1 = [SELECT id FROM Iteration__c WHERE name = 'Unit Test Iteration'];
		Iteration__c iteration2 = [SELECT id FROM Iteration__c WHERE name = 'Unit Test Iteration 2'];
		
		//Setting test data
		wpIDsTo.add(wp1.id);
		toRelease = wp1.ss_release__c;
		toIteration = iteration2.id;
		fromRelease = wp1.ss_release__c;
		fromIteration = wp1.iteration__c;
		
		ViewBacklog.updateWorkProductRank(wpIDsTo, toRelease, toIteration, toAscending, wpIDsFrom, fromRelease, fromIteration, fromAscending, null , null);
		
		test.startTest();
		//Test #1 - Adding 1 wp to an empty iteration
		wp1 = [SELECT id, ss_release__c, iteration__c, rank__c FROM Work_Product__c WHERE name = 'Test User Story 1'];
		//system.assertEquals(wp1.rank__c, 0);
		
		//Test #2 - Adding 2 wps to an empty iteration
		wpIDsTo.clear();
		wpIDsTo.add(wp2.id);
		wpIDsTo.add(wp1.id);
		
		ViewBacklog.updateWorkProductRank(wpIDsTo, toRelease, toIteration, toAscending, wpIDsFrom, fromRelease, fromIteration, fromAscending,  null , null);
		
		wp1 = [SELECT rank__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 1'];
		wp2 = [SELECT rank__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 2'];
		//system.assertEquals(wp1.rank__c, 1);
		//system.assertEquals(wp2.rank__c, 0);
		//system.assertEquals(wp1.iteration__c, toIteration);
		//system.assertEquals(wp2.iteration__c, toIteration);
		
		//Test #3 - Moving one wp back to the initial iteration
		wpIDsTo.clear();
		wpIDsTo.add(wp1.id);		
		wpIDsFrom.add(wp2.id);
		toIteration = iteration1.id;
		fromIteration = iteration2.id;
		
		ViewBacklog.updateWorkProductRank(wpIDsTo, toRelease, toIteration, toAscending, wpIDsFrom, fromRelease, fromIteration, fromAscending,  null , null);
		
		wp1 = [SELECT rank__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 1'];
		wp2 = [SELECT rank__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 2'];
		//system.assertEquals(wp1.rank__c, 0);
		//system.assertEquals(wp2.rank__c, 0);
		//system.assertEquals(wp1.iteration__c, toIteration);
		//system.assertEquals(wp2.iteration__c, fromIteration);

		test.stopTest();
	}
	
	static testMethod void selectProjectTester() {
		
		//Create data for test 
		PMToolkitTestDataCreator.dataCreator();
		Project_Overview__c selectedProject = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];	
		ViewBacklog vb = new ViewBacklog();
		
		//Setting current page
		PageReference projectBacklogPage = Page.ViewBacklog;
        projectBacklogPage.getParameters().put('project', selectedProject.id);  
        test.setCurrentPage(projectBacklogPage);
        
        pageReference returnedProjectBacklogPage = vb.selectProject();
		
	}

	static testMethod void getItemsTester() {

		PMToolkitTestDataCreator.dataCreator();
		Project_Overview__c selectedProject = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];	
		ViewBacklog vb = new ViewBacklog();
		List<SelectOption> myOptions = new List<SelectOption>();
		List<SelectOption> filterOptions = new List<SelectOption>();

		myOptions = vb.getItems();
		filterOptions = vb.filterByOptions;

		//system.assertEquals('Unit Test Project', myOptions[0].getLabel());

	}

	static testMethod void filterWorkProductsTester()
	{

		RecordType MyRT;

		MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Agile Project' AND SobjectType = 'Project_Overview__c']; 
        Project_Overview__c TestProject = new Project_Overview__c();
        TestProject.Name = 'Unit Test Project';
        TestProject.Project_Stage__c = 'Open';
        TestProject.RecordTypeId = MyRT.Id;
        system.debug('MANUAL INSERT: PROJECT');
        insert TestProject;

        //Creating test work product #3
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'User Story' AND SobjectType = 'Work_Product__c'];
        Work_Product__c Test_US3 = new Work_Product__c();
        Test_US3.Name = 'Test User Story 3';
        Test_US3.RecordTypeId = MyRT.Id;
        Test_US3.Project_Overview__c = TestProject.Id;
        Test_US3.rank__c = 2;
        insert Test_US3;
        
        //Creating test work product #4
        Work_Product__c Test_US4 = new Work_Product__c();
        Test_US4.Name = 'Test User Story 4';
        Test_US4.RecordTypeId = MyRT.Id;
        Test_US4.Project_Overview__c = TestProject.Id;
        Test_US4.rank__c = 3;
        system.debug('MANUAL INSERT: USER STORY 4');
        insert Test_US4;
      
        //Creating test defect
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Defect' AND SobjectType = 'Work_Product__c'];
        Work_Product__c Test_Defect1 = new Work_Product__c();
        Test_Defect1.Name = 'Test Defect 1';
        Test_Defect1.RecordTypeId = MyRT.Id;
        Test_Defect1.Project_Overview__c = TestProject.Id;
        Test_Defect1.Description__c = 'Terrible Defect.';
        Test_Defect1.Priority__c = '4 - Low';
        Test_Defect1.Severity__c = '4 - Cosmetic';
        Test_Defect1.Type__c = 'Bug';
        Test_Defect1.Defect_State__c = 'Open';
        Test_Defect1.Steps_to_Reproduce__c = 'Steps to reproduce.';
        system.debug('MANUAL INSERT: USER STORY 5 - Defect');
        insert Test_Defect1;

		Project_Overview__c selectedProject = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];
		PageReference projectBacklogPage = Page.ViewBacklog;
		//PageReference nextPage = Page.ViewBacklog;

		Work_Product__c wp1 = [SELECT id, ss_release__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 3'];
		Work_Product__c wp2 = [SELECT id, ss_release__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 4'];
		Work_Product__c defect1 = [SELECT id, ss_release__c, iteration__c FROM Work_Product__c WHERE name = 'Test Defect 1'];
		

		ViewBacklog vb = new ViewBacklog();
		

		//assert that all 3 items are in the backlog list before filtering.
		//system.assertEquals(3, vb.productBacklogList.size());

		//TESTING DEFECT FILTER
		vb.selectionFilter = 'Defects';
		projectBacklogPage = vb.filterWorkProducts();

		//assert that only the defect remains after filter
		//system.assertEquals(1, vb.productBacklogList.size());

		//assert the correct defect name to confirm
		//system.assertEquals('Test Defect 1', vb.productBacklogList[0].name);


		//TESTING User Story Filter
		vb.selectionFilter = 'User Stories';
		projectBacklogPage = vb.filterWorkProducts();

		//assert that only the User Stories remain after filter
		//system.assertEquals(2, vb.productBacklogList.size());

		//assert the correct UserStory names to confirm
		//system.assertEquals('Test User Story 3', vb.productBacklogList[0].name);
		//system.assertEquals('Test User Story 4', vb.productBacklogList[1].name);

		//TESTING ALL Filter
		vb.selectionFilter = 'ALL';
		projectBacklogPage = vb.filterWorkProducts();

		//assert that all 3 WPs are back in the list
		//system.assertEquals(3, vb.productBacklogList.size());

	}

		static testMethod void hidePastIterationsTester() {
		PMToolkitTestDataCreator.dataCreator();
		PageReference projectBacklogPage = Page.ViewBacklog;
		ViewBacklog vb = new ViewBacklog();
		
		Project_Overview__c selectedProject = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];	
		Work_Product__c wp1 = [SELECT id, ss_release__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 1'];
		Work_Product__c wp2 = [SELECT id, ss_release__c, iteration__c FROM Work_Product__c WHERE name = 'Test User Story 2'];
		Iteration__c iteration1 = [SELECT id, current_iteration__c FROM Iteration__c WHERE name = 'Unit Test Iteration'];
		Iteration__c iteration2 = [SELECT id, current_iteration__c FROM Iteration__c WHERE name = 'Unit Test Iteration 2'];

		Date yesterday = system.today().addDays(-1);
		Date tomorrow= system.today().addDays(1);

		system.debug('ISCURRENT' + iteration1.current_iteration__c);

		//Confirm both iterations in list before filtering
		//system.assertEquals(2, vb.iterationList.size());

		//Set check to true, call function
		vb.isHidePastIterations = true;
		projectBacklogPage = vb.hidePastIterations();

		//Confirm 1 item in the list after filtering
		//system.assertEquals(1, vb.iterationList.size());
		//Confirm iteration is set to active
		//system.assertEquals(true, vb.iterationList[0].current_iteration__c);

		//Set check to false, confirm both items in list.
		vb.isHidePastIterations = false;
		projectBacklogPage = vb.hidePastIterations();
		//system.assertEquals(2, vb.iterationList.size());


	}

	static testMethod void hidePastReleasesTester() {

		PMToolkitTestDataCreator.dataCreator();
		Project_Overview__c testProject = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];

		//Create 2nd release
        SS_Release__c TestRelease2 = new SS_Release__c();
        TestRelease2.Name = 'Unit Test Release 2';
        TestRelease2.State__c = 'Active';
        TestRelease2.Start_date__c = date.newInstance(2013,5,30);
        TestRelease2.Release_date__c = date.newInstance(2013,6,30);
        TestRelease2.Project_Overview__c = testProject.Id;
        insert TestRelease2;

        PageReference projectBacklogPage = Page.ViewBacklog;
		ViewBacklog vb = new ViewBacklog();

        SS_Release__c tr1 = [SELECT id, name FROM SS_Release__c WHERE name = 'Unit Test Release'];
        SS_Release__c tr2 = [SELECT id, name FROM SS_Release__c WHERE name = 'Unit Test Release 2'];

        //set check to false
        vb.isHidePastReleases = false;
        projectBacklogPage = vb.hidePastReleases();

        //confirm both releases are in the list
        system.assertEquals(2, vb.releaseList.size());

        //set check to true
        vb.isHidePastReleases = true;
        projectBacklogPage = vb.hidePastReleases();

        //confirm only current release is in the list
        //system.assertEquals(1, vb.releaseList.size());
        //system.assertEquals('Unit Test Release', vb.releaseList[0].name);

	}

	static testMethod void hideClosedProjectsTester() {

		PMToolkitTestDataCreator.dataCreator();

		PageReference projectBacklogPage = Page.ViewBacklog;
		ViewBacklog vb = new ViewBacklog();

		//confirm page URL
		//system.assertEquals('/apex/viewbacklog', projectBacklogPage.getUrl());

		projectBacklogPage = vb.hideClosedProjects();

		//Project exists in list, expecting NULL
		//system.assertEquals(null, projectBacklogPage);

	}

	static testMethod void redirectToStickyProjectTester()
	{
		PMToolkitTestDataCreator.dataCreator();
		Project_Overview__c testProject = [SELECT id FROM Project_Overview__c WHERE name = 'Unit Test Project'];

		PageReference projectBacklogPage = Page.ViewBacklog;
		ViewBacklog vb = new ViewBacklog();

		Profile SysAdProfileId = [SELECT id FROM Profile WHERE name = 'System Administrator'];
        User newUser = new User (username='testuser@pmtoolkit.com',
        	lastName='theLastName', profileId=SysAdProfileId.id,
        	email='testuser@pmtoolkit.com', alias='testUser',
        	timeZoneSidKey='America/Los_Angeles',
        	localeSidKey='en_CA', emailEncodingKey='UTF-8',
        	languageLocaleKey='en_US');
        	insert newUser;

        ProjectSelection__c proj = new ProjectSelection__c();
        proj.projectId__c = testProject.id;
        insert proj;

        system.debug('PBP: ' + projectBacklogPage);
        //confirm current url
        //system.assertEquals('/apex/viewbacklog', projectBacklogPage.getUrl());

        //confirm project is in selection list
        List<SelectOption> myOptions = new List<SelectOption>();
		myOptions = vb.getItems();
		//system.assertEquals('Unit Test Project', myOptions[0].getLabel());

		// call method, expected result is null if project is in list - which we confirmed already.
        projectBacklogPage = vb.redirectToStickyProject();
        //system.assertEquals(null, projectBacklogPage);


        //NOW - TRY WITH PROJECT ID NOT IN THE SELECTION

        //create fake project ID
        proj.projectId__c = 'b0Z4000000CC5AA';
        update proj;
        myOptions = vb.getItems();
        //confirm the only item in the list is still the original one
        //system.assertEquals('Unit Test Project', myOptions[0].getLabel());

        //call method again
        projectBacklogPage = vb.redirectToStickyProject();
        //confirm we were redirected to first project in the list
        //system.assertEquals('/apex/viewbacklog?project='+testProject.id, projectBacklogPage.getUrl());
	}


}