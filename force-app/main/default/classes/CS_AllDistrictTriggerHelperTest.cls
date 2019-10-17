@isTest
private class CS_AllDistrictTriggerHelperTest {
	
	static void prepareData() {
		// create a district

		District__c d = new District__c(
			Code__c = 'D123',
			Name = 'TestDistrict'
			);
		insert d;

		// create a subpatch

		Sub_Patch__c subpatch = new Sub_Patch__c(
			Code__c = 'SP123',
			Name = 'TestSubpatch',
			District__c = d.id
			);
		insert subpatch;


		// create a postcode sector

		Postcode_Sector__c ps = new Postcode_Sector__c(
			Code__c = 'PS123',
			Name = 'TestPostcodeSector',
			Sub_Patch__c = subpatch.id
			);
		insert ps;

		// create multiple projects
		
		List<CS_Project__c> projectList = new List<CS_Project__c>();
		CS_Project__c p1 = new CS_Project__c(
			Name = 'Project1',
			Project_Code__c = 'PRO'
		);

		CS_Project__c p2 = new CS_Project__c(
			Name = 'Project2',
			Project_Code__c = 'TWO'
		);

		projectList.add(p1);
		projectList.add(p2);
		insert projectList;

		// create junction objects between projects and districts
		List<CS_Project_Availability__c> paList = new List<CS_Project_Availability__c>();
		CS_Project_Availability__c pa1 = new CS_Project_Availability__c(
			District__c = d.id,
			CS_Project__c = projectList[0].id	
		);

		CS_Project_Availability__c pa2 = new CS_Project_Availability__c(
			District__c = d.id,
			CS_Project__c = projectList[1].id
		);
		paList.add(pa1);
		paList.add(pa2);
		insert paList;
	}

	static testMethod void updateIncludedProjectsBeforeDistrictUpdateTest() {
		prepareData();

		District__c district = [
			SELECT Name
			, Code__c
			, Included_Projects__c
			FROM District__c
			WHERE Code__c = 'D123'
			LIMIT 1];

		district.Code__c = 'D987';

		update district;

		District__c updatedDistrict = [
			SELECT Name
			, Code__c
			, Included_Projects__c
			FROM District__c
			WHERE Code__c = 'D987'
			LIMIT 1];

		System.assertEquals('\'PRO\',\'TWO\'', updatedDistrict.Included_Projects__c);                
	}

	static testMethod void updateIncludedProjectsAfterProjectAvailabilityUpdateOrInsertTest() {
		prepareData();

		District__c district = [
			SELECT Name
			, Code__c
			, Included_Projects__c
			FROM District__c
			WHERE Code__c = 'D123'
			LIMIT 1];

		CS_Project__c p1 = [
			SELECT Name
			, Project_Code__c
			FROM CS_Project__c 
			WHERE Project_Code__c = 'PRO'
			LIMIT 1];

		CS_Project_Availability__c pa = [
			SELECT District__c
			, CS_Project__c
			FROM CS_Project_Availability__c 
			WHERE CS_Project__c = :p1.id
			LIMIT 1];

		update pa;

		System.assertEquals('\'PRO\',\'TWO\'', district.Included_Projects__c);                
	}

	static testMethod void updateIncludedProjectsAfterProjectAvailabilityDeleteTest() {
		prepareData();

		District__c district = [
			SELECT Name
			, Code__c
			, Included_Projects__c
			FROM District__c
			WHERE Code__c = 'D123'
			LIMIT 1];

		CS_Project__c p1 = [
			SELECT Name
			, Project_Code__c
			FROM CS_Project__c 
			WHERE Project_Code__c = 'PRO'
			LIMIT 1];

		CS_Project_Availability__c pa = [
			SELECT District__c
			, CS_Project__c
			FROM CS_Project_Availability__c 
			WHERE CS_Project__c = :p1.id
			LIMIT 1];

		delete pa;

		District__c updatedDistrict = [
			SELECT Name
			, Code__c
			, Included_Projects__c
			FROM District__c
			WHERE Code__c = 'D123'
			LIMIT 1];

		System.assertEquals('\'TWO\'', updatedDistrict.Included_Projects__c);      
	}

	static testMethod void updateIncludedProjectsAfterProjectUpdateOrDeleteTest() {
		prepareData();

		CS_Project__c p1 = [
			SELECT Name
			, Project_Code__c
			FROM CS_Project__c 
			WHERE Project_Code__c = 'PRO'
			LIMIT 1];
		delete p1;

		District__c district = [
			SELECT Name
			, Code__c
			, Included_Projects__c
			FROM District__c
			WHERE Code__c = 'D123'
			LIMIT 1];

		System.assertEquals('\'TWO\'', district.Included_Projects__c);      
	}
}