/**
 * Copyright Salesforce.com 2014
 * original author Daniel Harfleet - Salesforce Services
 * First written for use within the Development Surveys functionality of CHI Depot
 */
public with sharing class ErrorHandlerApexPage
	extends ErrorHandler
{

	private static Map<String, LoggingLevel> loggingLevelMappings;
	{
		loggingLevelMappings = new Map<String, LoggingLevel>();
		loggingLevelMappings.put(ErrorHandler.LEVEL_FATAL, LoggingLevel.ERROR);
		loggingLevelMappings.put(ErrorHandler.LEVEL_ERROR, LoggingLevel.ERROR);
		loggingLevelMappings.put(ErrorHandler.LEVEL_WARNING, LoggingLevel.WARN);
	}

	private static Map<String, ApexPages.severity> apexPageSeverityMappings;
	{
		apexPageSeverityMappings = new Map<String, ApexPages.severity>();
		apexPageSeverityMappings.put(ErrorHandler.LEVEL_FATAL, ApexPages.severity.ERROR);
		apexPageSeverityMappings.put(ErrorHandler.LEVEL_ERROR, ApexPages.severity.ERROR);
		apexPageSeverityMappings.put(ErrorHandler.LEVEL_WARNING, ApexPages.severity.WARNING);
	}

	public static String convertExceptionToString(Exception ex)
	{
		List<String> tokens = new List<String>();
        tokens.add(ex.getMessage());
        tokens.add(String.valueOf(ex.getLineNumber()));
        tokens.add(ex.getStackTraceString());
        
        String result = String.join(tokens, ':');
        return result;
	}

	override public void handleException(String level, String message, String messageDetail, Exception ex)
	{

		LoggingLevel logLevel = loggingLevelMappings.get(level);

		String logEntry = convertExceptionToString(ex);
		System.debug(logLevel, logEntry);

		ApexPages.severity severity = apexPageSeverityMappings.get(level);
		ApexPages.Message apexPageMessage = new ApexPages.Message(severity, message, messageDetail);
        ApexPages.addMessage(apexPageMessage);

	}


}