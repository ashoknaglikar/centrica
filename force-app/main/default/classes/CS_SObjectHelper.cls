/**
 *  A helper class for SObject functionalities.
 */
public with sharing class CS_SObjectHelper {

    /**
     *  A cache for fields of objects.
     */
    static map<string, Schema.SObjectField[]> cachedObjectsFields =  new map<string, Schema.SObjectField[]>();
    
    /**
     *  Converts a list of ids to a string containing a quoted comma separated list wrapped in parentheses 
     *  for use with the IN-clause in dynamic SOQL.
     */
    public static string convertIdListToSoqlInListString(Id[] ids) {
        if (ids != null && ids.size() > 0) {
            String listString = '(\'\')';
            if (ids.size() > 0) {
                listString = '(\''+ids[0]+'\'';
                for (Integer i = 1; i < ids.size(); i++) {
                    listString += ',\'' + ids[i]+'\'';
                }
                listString += ')';
            }
            return listString ;
        } else {
            return '(null)';
        }
    }
    
    public static string convertStringListToSoqlInListString(String[] values) {
        if (values != null && values.size() > 0) {
            String listString = '(\'\')';
            if (values.size() > 0) {
                listString = '(\''+values[0]+'\'';
                for (Integer i = 1; i < values.size(); i++) {
                    listString += ',\'' + values[i]+'\'';
                }  
                listString += ')';
            }
            return listString ;
        } else {
            return '(null)';
        }
    }
    
    /**
     *  Returns a comma separated list of fields of the SObject with the given name, which can be used
     *  in SOQL queries.
     */ 
    public static String getFieldListForSOQL(string objectName) {
        return getFieldListForSOQL(objectName, null, null);
    }
    
    /**
     *  Returns a comma separated list of fields of the SObject with the given name, which can be used
     *  in SOQL queries. Fields defined in ignoreFields will be ignored. The given prefix is added to all fields.
     */ 
    public static String getFieldListForSOQL(string objectName, string prefix, set<string> ignoreFields) {
        
        Schema.SObjectField[] objFields = getObjectFields(objectName);
        
        String result = '';
        for (Schema.SObjectField f : objFields) {
            string fName = f.getDescribe().Name;
            if (ignoreFields == null || !ignoreFields.contains(fName)) {
                result += (prefix != null ? prefix : '') + fName + ',';
            }
        }
        
        // Remove last comma
        if (result.length() > 0) {
            result = result.substring(0, result.length() - 1);
        }
        
        return result;
    }
    
    
    
    /**
     *  Create a copy of the given original-object, and put it in the copy-object, by copying all the field values,
     *  except the ones listed in exceptFields. 
     */
    public static void copyObject(sobject original, sobject copy, set<string> exceptFields) {
        if (original != null) {
            Schema.SObjectField[] objFields = getObjectFields(original.getSObjectType().getDescribe().Name);
           
            for (Schema.SObjectField f : objFields) {
                if (f.getDescribe().isUpdateable() && (exceptFields == null || !exceptFields.contains(f.getDescribe().Name))) {
                    copy.put(f.getDescribe().LocalName, original.get(f.getDescribe().Name));
                }
            }
        }
        
        system.debug('******* ' + copy);
    }
    
    /**
     *  Returns list of fields of the object with the given name.
     */
    public static Schema.SObjectField[] getObjectFields(string objectName) {
        if (cachedObjectsFields.containsKey(objectName)) {
            return cachedObjectsFields.get(objectName);
        } else {
            SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType == null) {
                return null;
            }
            
            Schema.SObjectField[] objFields = objType.getDescribe().fields.getMap().values();
            cachedObjectsFields.put(objectName, objFields);
            return objFields;
        }
    }

    /**
     * Sorts a list based on the selected field and provided order.
     *
     * @param sObjectList   a list of sObject which needs to be sorted
     * @param sortField     the field to sort the list on
     * @param order         the order of sorting ('asc' or 'desc')
     */
    public static void sortList(List<sObject> sObjectList, String sortField, String order) {

        List<sObject> resultList = new List<sObject>();

        //Create a map to be used for sorting
        Map<Object, List<sObject>> objectMap = new Map<Object, List<sObject>>();

        for (sObject obj : sObjectList) {
            if (objectMap.get(obj.get(sortField)) == null) {
                objectMap.put(obj.get(sortField), new List<sObject>());
            }
            objectMap.get(obj.get(sortField)).add(obj);
        }

        //Sort the keys of the newly created map
        List<Object> keys = new List<Object>(objectMap.keySet());
        keys.sort();

        for (Object key : keys) {
            resultList.addAll(objectMap.get(key));
        }

        //Apply the sorted values to the source list
        sObjectList.clear();
        if (order.toLowerCase() == 'asc') {
            for (sObject obj : resultList) {
                sObjectList.add(obj);
            }
        } else if (order.toLowerCase() == 'desc') {
            for (Integer i = resultList.size() - 1; i >= 0; i--) {
                sObjectList.add(resultList[i]);
            }
        }
    }

}