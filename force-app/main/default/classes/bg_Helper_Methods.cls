/*
 * This class has generic helper methods
 * @Author Brightgen
 * Created 2013/11/12
 */
public with sharing class bg_Helper_Methods{
	public static String joinList(List<String> theList, String separator) {

		if (theList == null)   { return null; }
		if (separator == null) { separator = ''; }

		String joined = '';
		Boolean firstItem = true;
		for (String item : theList) {
			if(null != item) {
				if(firstItem){ firstItem = false; }
				else { joined += separator; }
				joined += item;
			}
		}
		return joined;
	}
	/*
	 * This method will return a set if Ids on the list of objects passed in
	 * @Param Records The list of records the side of Id's will be generated from
	 */
	public static Set<Id> getIdSet(List<sObject> Records) {
		Set<Id> recordIds = new Set<Id>();
		for(sObject record : records) {
			if(!recordIds.contains(record.Id)) {
				recordIds.add(record.Id);
			}
		}
		return recordIds;
	}
	
	/*
	 * This method will return a map of field values relating to an object
	 * @Param Records A list of sObjects used to retrive the Ids from
	 */
	public static Map<String, sObject> getIdObjectMap(List<sObject> Records) {
		Map<String, sObject> objectMap = new Map<String, sObject>();
		for(sObject Record : Records) {
			objectMap.put(Record.Id, Record);
		}
		return objectMap;
	}
	
	/*
	 * This method will return a set if the specified field name on the list of objects passed in
	 * @Param Records The list of records the side of Id's will be generated from
	 * @Param FieldName The field name used to retrieve the values for the set
	 * @Note This method doesn't catch any exceptions. The field not existing will need to be delt with.
	 */
	public static Set<object> getIdSet(List<sObject> Records, String FieldName) {
		Set<object> recordIds = new Set<object>();
		for(sObject record : records) {
			if(!recordIds.contains(record.get(FieldName))) {
				recordIds.add(record.get(FieldName));
			}
		}
		return recordIds;
	}
	/*
	 * This method will return the object name of a lookup in a record
	 * @Return string object name
	 * @Return null no object name could be found
	 */
	public static string getLookupFieldUpObjectType(List<sObject> Records, String FieldName) {
		/*
		 * Get field schema information
		 */
		Map<String, Schema.SObjectType> GlobalMap = Schema.getGlobalDescribe();
		if(Records.size() > 0) {
			sObject firstRecord = Records.get(0);
			Schema.DescribeSObjectResult obj = GlobalMap.get(string.valueOf(firstRecord.getSObjectType())).getDescribe();
			Schema.DescribeFieldResult FieldInformation;
			try {
				FieldInformation = obj.Fields.getMap().get(FieldName).getDescribe();
			} catch (NullPointerException e) {
				throw new bg_Custom_Exceptions.IncorrectFieldForObjectException('Field [' + FieldName + '] does not exist on object [' + string.valueOf(firstRecord.getSObjectType()) + ']');
			}
			
			/*
			 * Check that the object is an external Id, Id or lookup and through an exception if not
			 */
			if(!FieldInformation.isIdLookup() && !FieldInformation.isNamePointing() && FieldInformation.getRelationshipName() == null) {
				throw new bg_Custom_Exceptions.InvalidFieldException('The field specified needs to be an Id, External Id or a lookup to be used in the getFieldObjectMap method');
			}
			
			/*
			 * Get the name of the related object to the field
			 */
			return FieldInformation.getReferenceTo().size() == 0? string.valueOf(firstRecord.getSObjectType()) : string.valueOf(FieldInformation.getReferenceTo().get(0));
		}
		return null;
	}
	
	/*
	 * This method will return a map of field values relating to an object
	 * @Param Records A list of sObjects used to retrive the Ids from
	 * @Param FieldName The field name used to retrieve the keys for the map
	 * @Param FieldsNeeded The fields needed off the related object
	 * @TODO
	 * 		- Make the function work with external Ids
	 * @Note This method doesn't catch any exceptions. The field not existing will need to be delt with.
	 * @Exception InvalidFieldException
	 */
	public static Map<String, sObject> getFieldObjectMap(List<sObject> Records, String FieldName, String[] FieldsNeeded) {			
		/*
		 * Get the name of the related object to the field
		 */
		string relatedObject = getLookupFieldUpObjectType(Records, FieldName);
		
		Set<object> sObjectIds = getIdSet(records, FieldName);
		
		/*
		 * Implement building up the database query
		 */
		String fieldToSelect = String.Join(FieldsNeeded, ',');
		List<object> IdsList = new List<object>();
		IdsList.addAll(sObjectIds);
		String Ids = convertToQueryString(IdsList);
		
		/*
		 * Id is hard coded and will need to be changed to work with external Ids
		 */
		if(relatedObject != null) {
			String query = 'Select ' + fieldToSelect + ' From ' + relatedObject + ' Where Id In ' + Ids;
			return getIdObjectMap(Database.query(query));
		} else {
			return new Map<String, sObject>();
		}
	}
	
	public static String convertToQueryString(Set<object> setValues) {
		List<object> IdsList = new List<object>();
		IdsList.addAll(setValues);
		String Ids = '(\'' + String.Join(IdsList, '\',\'') + '\')';
		return Ids;
	}
	
	public static String convertToQueryString(List<object> ListValues) {
		String Ids = '(\'' + String.Join(ListValues, '\',\'') + '\')';
		return Ids;
	}
	
	/*
	 * This method will return a list of sObjects where a certain field of them has updated
     * @param List<sObject> A list of sObject to update
	 * @param List<sObject> A list of sObject before the triggers have changed them
	 * @Param String A field name to check if it has been changed
	 * @TODO Look at implementing a list of field names to compare against
	 */
	public static List<sObject> getAllRecordsThatHaveChanged(List<sObject> sObjectNew, List<sObject> sObjectOld, String[] FieldNames) {
		/*
		 * Generate new sObject Map
		 */
		Map<String, sObject> sObjectMap = getIdObjectMap(sObjectNew);
		
		/*
		 * Check if the sObject has changed and add them to a list
		 */
		List<sObject> sObjectList = new List<sObject>();
		for(sObject sObjectRecord : sObjectOld) {
			Boolean isChanged = false;
			for(String FieldName : FieldNames) {
				if(sObjectMap.get(sObjectRecord.Id).get(FieldName) != sObjectRecord.get(FieldName)) {
					isChanged = true;
				}
			}
			if(isChanged) {
				sObjectList.add(sObjectMap.get(sObjectRecord.Id));
			}
		}
		return sObjectList;
	}
	
	/*
	 * This method will return a list of sObjects where a certain field of them has not updated
     * @param List<sObject> A list of sObject to update
	 * @param List<sObject> A list of sObject before the triggers have changed them
	 * @Param String A field name to check if it has been changed
	 * @TODO Look at implementing a list of field names to compare against
	 */
	public static List<sObject> getAllRecordsThatHaveNotChanged(List<sObject> sObjectNew, List<sObject> sObjectOld, String[] FieldNames) {
		/*
		 * Remove all objects that have changed from the new sObject list
		 */
		Set<sObject> records = new Set<sObject>(sObjectNew);
		records.removeAll(getAllRecordsThatHaveChanged(sObjectNew, sObjectOld, FieldNames));
		
		/*
		 * Return a list of records that haven't changed
		 */
		return new List<sObject>(records);
	}
	
	/*
	 * This method will return you the Id of the record type specified
	 * @Param sObjectName The name of the object the record type belongs to
	 * @Param RecordTypeName The name of the record type
	 */
	public static Id getRecordTypeId(String sObjectName, String RecordTypeName) {
		return [Select R.Name, R.Id, R.SobjectType from RecordType R Where R.SobjectType = :sObjectName And R.DeveloperName = :RecordTypeName].Id;
	}
	
	/*
	 * This method will return a list of sObjects where a list of fields contain certain values
     * @param List<sObject> A list of sObject to update
	 * @Param String A field name to check if it has been changed
	 */
	public static List<sObject> getAllRecordsThatHaveValues(List<sObject> sObjectNew, Map<String, object[]> FieldValuesMap) {
		/*
		 * Check if each of the records contain certain values
		 */
		List<sObject> sObjectList = new List<sObject>();
		for(sObject sObjectRecord : sObjectNew) {
			Boolean isMatching = false;
			Integer matchingCount = 0;
			for(String key : FieldValuesMap.keySet()) {
				for(object fieldValue : FieldValuesMap.get(key)) {
					if(sObjectRecord.get(key) == fieldValue) {
						isMatching = true;
					}
				}
				if(isMatching == true) {
					matchingCount++;
				}
			}
			if(matchingCount == FieldValuesMap.keySet().Size()) {
				sObjectList.add(sObjectRecord);
			}
		}
		return sObjectList;
	}
	
	/*
	 * This method will return a list of sObjects where a list of fields contain certain values
     * @param List<sObject> A list of sObject to update
	 * @Param String A field name to check if it has been changed
	 */
	public static List<sObject> getAllRecordsThatDontHaveValues(List<sObject> sObjectNew, Map<String, object[]> FieldValuesMap) {
		/*
		 * Check if each of the records contain certain values
		 */
		Set<sObject> sObjectNewSet = new Set<sObject>(sObjectNew);
		Set<sObject> sObjectList = new Set<sObject>(getAllRecordsThatHaveValues(sObjectNew, FieldValuesMap));
		
		sObjectNewSet.removeAll(sObjectList);
		List<sObject> returnList = new List<sObject>(sObjectNewSet);
		return returnList;
	}
	
	/*
	 * This method will return a map of field values relating to an object
	 * @Param Records A list of sObjects used to retrive the Ids from
	 * @Param FieldsNeeded The fields needed off the related object
	 * @TODO
	 * 		- Make the function work with external Ids
	 * @Note This method doesn't catch any exceptions. The field not existing will need to be delt with.
	 * @Exception InvalidFieldException
	 */
	public static Map<String, sObject> getFieldChildObjectMap(List<sObject> Records, String ObjectName, String FieldName, String[] FieldsNeeded) {			
		return getFieldChildObjectMapAndFilter(Records, ObjectName, FieldName, FieldsNeeded, new Map<String, object[]>());
	}
	
	/*
	 * Filter a Map
	 */
	public static Map<string, sObject> FilterMap(Map<string, sObject> records, Map<String, object[]> filterValues) {		
		Map<string, sObject> returnMap = new Map<string, sObject>();
		for(sObject record : getAllRecordsThatHaveValues(records.Values(), filterValues)) {
			returnMap.put(record.Id, record);
		}
		return returnMap;
	}
	
	/*
	 * Genereate map and filter
	 */
	public static Map<String, sObject> getFieldChildObjectMapAndFilter(List<sObject> Records, String ObjectName, String FieldName, String[] FieldsNeeded, Map<String, object[]> filterValues) {
		/*
		 * Get the name of the related object to the field
		 */	
		Set<object> sObjectIds = getIdSet(records, 'Id');
		/*
		 * Implement building up the database query
		 */
		String fieldToSelect = String.Join(FieldsNeeded, ',');
		List<object> IdsList = new List<object>();
		IdsList.addAll(sObjectIds);
		String Ids = convertToQueryString(IdsList);
		
		/*
		 * Id is hard coded and will need to be changed to work with external Ids
		 */
		if(ObjectName != null && Ids != '(\'\')') {
			String query = 'Select ' + fieldToSelect + ' From ' + ObjectName + ' Where ' + FieldName + ' In ' + Ids;
			return getIdObjectMap(getAllRecordsThatHaveValues(Database.query(query), filterValues));
		} else {
			return new Map<String, sObject>();
		}
	}
	/*
	 * This method will insert the list of objects and return a list of Ids of the inserted records
	 */
	public static Set<Id> insertRecords(List<sObject> records) {
		Database.SaveResult[] srList = Database.insert(records, false);
		Set<Id> insertedIds = new Set<Id>();
		for (Database.SaveResult sr : srList) {
			if (sr.isSuccess()) {
				insertedIds.add(sr.getId());
			} else {
				for(Database.Error err : sr.getErrors()) {
		            System.debug('The following error has occurred.');                    
		            System.debug(err.getStatusCode() + ': ' + err.getMessage());
		            System.debug(getLookupFieldUpObjectType(records, 'Id') + ' fields that affected this error: ' + err.getFields());
		        }
			}
		}
		return insertedIds;
	}
	
	/*
	 * deDuplicate List
	 */
	public static List<sObject> deduplicateList(List<sObject> records) {
		Set<sobject> myset = new Set<sobject>();
		List<sobject> result = new List<sobject>();
		myset.addAll(records);
		result.addAll(myset);	
		return result;
	}
}