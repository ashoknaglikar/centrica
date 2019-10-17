/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
@isTest
private class ErrorHandlerApexPageTest
{
	public static String LEVEL_ERROR = ErrorHandler.LEVEL_ERROR;
	
	@isTest static void testHandleException()
	{
		ErrorHandler errorHandler = new ErrorHandlerApexPage();

		String levelFixture = LEVEL_ERROR;
		String messageFixture = 'message';
		String messageDetailFixture = 'messageDetail';
		Exception exceptionFixture = new TestException(messageFixture);

		Test.startTest();
		errorHandler.handleException(levelFixture, 
									messageFixture, 
									messageDetailFixture, 
									exceptionFixture);
		Test.stopTest();

		System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
	}
	
	
	@isTest static void testConvertExceptionToString()
	{
		String messageFixture = 'message';
		Exception exceptionFixture = new TestException(messageFixture);

		String output = ErrorHandlerApexPage.convertExceptionToString(exceptionFixture);

		System.assert(output.startsWith(messageFixture));
	}
	

	public class TestException extends Exception{}
}