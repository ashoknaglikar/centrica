@isTest
private class DevelopmentSurveyTaskFactoryTest {
	
	@isTest static void testCreateTask()
	{

		Id idFixture = 'a4Qg00000008TrvEAF';
		Date dueDateFixture = Date.today().addDays(1);
		Id surveyResponseIdFixture = 'a4Qg00000008TrvEAB';
		String subjectFixture = 'test subject text';
		String descriptionFixture = 'test description text';

		Task result = DevelopmentSurveyTaskFactory.createTask(idFixture
			, dueDateFixture
			, surveyResponseIdFixture
			, subjectFixture
			, descriptionFixture);


		System.assertEquals('Development Survey', result.Type, 'Task type not correct');
		System.assert(result.RecordTypeId != null);
        System.assertEquals(subjectFixture, result.Subject, 'subjects should be the same');
		System.assert(dueDateFixture.isSameDay(result.ActivityDate));
        System.assertEquals(descriptionFixture, result.Description, 'descriptions should be the same');
        System.assertEquals(IdFixture, result.OwnerId, 'Related Record is wrong');
        System.assertEquals(surveyResponseIdFixture+'', result.WhatId+'', 'Related Record is wrong');

	}
	
	@isTest static void testCreateReviewTask()
	{
		Id idFixture = 'a4Qg00000008TrvEAF';
		Date dueDateFixture = Date.today().addDays(1);
		Id surveyResponseIdFixture = 'a4Qg00000008TrvEAB';
		String subjectFixture = 'test subject text';
		String descriptionFixture = 'test description text';

		Task result = DevelopmentSurveyTaskFactory.createReviewTask(idFixture
			, dueDateFixture
			, surveyResponseIdFixture
			, subjectFixture
			, descriptionFixture);


		System.assertEquals('Development Survey Review', result.Type, 'Task type not correct');
		System.assert(result.RecordTypeId != null);
        System.assertEquals(subjectFixture, result.Subject, 'subjects should be the same');
		System.assert(dueDateFixture.isSameDay(result.ActivityDate));
        System.assertEquals(descriptionFixture, result.Description, 'descriptions should be the same');
        System.assertEquals(IdFixture, result.OwnerId, 'Related Record is wrong');
        System.assertEquals(surveyResponseIdFixture+'', result.WhatId+'', 'Related Record is wrong');
	}
	
}