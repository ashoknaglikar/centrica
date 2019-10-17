/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
public abstract class ErrorHandler
{
	public static String LEVEL_FATAL = 'fatal';
	public static String LEVEL_ERROR = 'error';
	public static String LEVEL_WARNING = 'warning';



	public abstract void handleException(String level, String message, String messageDetail, Exception ex);

}