public with sharing class RecordTypeIdHelper {
	static Map<String, Map<String, Id>> RecIds = new Map<String, Map<String, Id>>();
	
	//throws an exception if SobjectType or recTypeName is not valid
	public static Id getRecordTypeId(String SobjectType, String recTypeName)
	{
		Id result;
		//if the id'd have not been queried yet, store them in the map
		if (!RecIds.containsKey(SobjectType))
		{
			System.debug('Going to query database');
			String query = 'Select Id, Name From RecordType where SobjectType = \'' + SobjectType + '\'';
			List<RecordType> myRecordTypes = new List<RecordType>((List<RecordType>)Database.query(query));
			if(myRecordTypes.size() < 1) throw new getRecordTypeException(SobjectType + ' is not a valid object type or does not have any record types.');
			Map<String, Id> myMap = new Map<String, Id>();
			for(RecordType myRecordType : myRecordTypes)
			{
				myMap.put(myRecordType.name, myRecordType.id);
			}
			RecIds.put(SobjectType, myMap);
			System.debug(RecIds);
		}
		//now have the required values in the map, find the id if it exists
		if(RecIds.get(SobjectType).containsKey(recTypeName))
		{
			result = RecIds.get(SobjectType).get(recTypeName);
		}
		else
		{
			throw new getRecordTypeException(recTypeName + ' is not a valid record type name for ' + SobjectType + '.');
		}			
		return result;
	}
	public class getRecordTypeException extends Exception{} 
}