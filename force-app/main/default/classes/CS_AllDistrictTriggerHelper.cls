public class CS_AllDistrictTriggerHelper {
	
	private static String separator = ',';
	//
	// Update Districts after district Update
	//
	public static void updateIncludedProjectsBeforeDistrictUpdate(Map<Id, District__c> triggerMap) {

		Map<Id, Set<String>> districtIdToProjectCodesMap = getDistrictToProjectCodesMap(triggerMap, new Set<String>());

		for(District__c district : triggerMap.values()) {
			if(districtIdToProjectCodesMap.containsKey(district.Id)) {
				String projectsCSV = String.join(new List<String>(districtIdToProjectCodesMap.get(district.Id)), separator);
				projectsCSV = '\'' + projectsCSV.replace(',', '\',\'') + '\''; 
				district.Included_Projects__c = projectsCSV; 
			} else {
				district.Included_Projects__c = '';
			}
		}
	}

	//
	// Update Districts after Product Availability Update, Insert, Delete, Undelete
	//
	public static void updateIncludedProjectsAfterProjectAvailabilityUpdateOrInsert(Map<Id, CS_Project_Availability__c> triggerMap) {
		updateDistrictsFromProjectAvailabilityMap(triggerMap);
	}

	public static void updateIncludedProjectsAfterProjectAvailabilityDelete(Map<Id, CS_Project_Availability__c> triggerMap) {
		updateDistrictsFromProjectAvailabilityMap(triggerMap);
	}

	public static void updateIncludedProjectsAfterProjectAvailabilityUnDelete(Map<Id, CS_Project_Availability__c> triggerMap) {
		updateDistrictsFromProjectAvailabilityMap(triggerMap);
	}

	//
	// Update Districts after Product Update, Delete
	//
	public static void updateIncludedProjectsAfterProjectUpdateOrDelete(Map<Id, CS_Project__c> triggerMap, Boolean isDelete){

		Map<Id, CS_Project_Availability__c> projectAvailabilitiesMap = new Map<Id, CS_Project_Availability__c>(
			[ SELECT Id
			, CS_Project__c 
			, District__c 
			, CS_Project__r.Project_Code__c
			FROM CS_Project_Availability__c 
			WHERE CS_Project__c in :triggerMap.keySet()]);

		if(isDelete) {
			// Since all of the methods rely on district to be updated
			// we have to stop the triggers here because after deleting 
			// the CS_Project we have no reference to the District.
			// Before deleting the CS_Project we have a reference to the District
			// but if we just update the district it will still have this 
			// project code in the list of included projects.
			// That is why the triggers are turned of for before delete trigger
			// and the District object is updated. 
			UISupport.setTriggersOff(UserInfo.getUserId());
			try {
				
				Set<Id> includedDistricts = new Set<Id>();
				for(CS_Project_Availability__c pa : projectAvailabilitiesMap.values()) {
					includedDistricts.add(pa.District__c);
				}
				Map<id, District__c> districtsToUpdateMap = new Map<Id, District__c>(
					[ SELECT Id
					, Included_Projects__c 
					FROM District__c
					WHERE Id in :includedDistricts]);

				Set<String> projectCodesToExclude = new Set<String>();
				for(CS_Project__c project : triggerMap.values()) {
					projectCodesToExclude.add(project.Project_Code__c);
				}

				Map<Id, Set<String>> districtIdToProjectCodesMap = getDistrictToProjectCodesMap(districtsToUpdateMap, projectCodesToExclude);

				for(District__c district : districtsToUpdateMap.values()) {
					if(districtIdToProjectCodesMap.containsKey(district.Id)) {
						String projectsCSV = String.join(new List<String>(districtIdToProjectCodesMap.get(district.Id)), separator);
						projectsCSV = '\'' + projectsCSV.replace(',', '\',\'') + '\'';
						district.Included_Projects__c = projectsCSV;
					}
				}

				update districtsToUpdateMap.values();
			} catch (Exception e) {

			} finally {
				UISupport.setTriggersOn(UserInfo.getUserId());
			}
		} else {
			updateDistrictsFromProjectAvailabilityMap(projectAvailabilitiesMap);	
		}
	}

	//
	// Touch (modify last modified date) on related Postcode sector
	//
	public static void updateRelatedPostcodeSector(Map<Id, District__c> triggerMap) {
		// select all subpatches
		Map<Id, Sub_Patch__c> relatedSubPatchesMap = new Map<Id, Sub_Patch__c>(
			[ SELECT Id
			, District__c 
			FROM Sub_Patch__c 
			WHERE District__c in :triggerMap.keySet()]);

		// select all postcode sectors of Sales type
		List<Postcode_Sector__c> relatedPostcodeSectors = 
			[ SELECT Id
			, Type__c
			, Sub_Patch__c
			FROM Postcode_Sector__c 
			WHERE Type__c = 'Sales' AND Sub_Patch__c in: relatedSubPatchesMap.keySet()];

		update relatedPostcodeSectors;
	}

	//
	// Helper methods
	//
	private static Map<Id, Set<String>> getDistrictToProjectCodesMap(Map<Id, District__c> triggerMap, Set<String> projectCodesToExclude) {

		// fetch a list of all Projects availabilities for provided districts
		List<CS_Project_Availability__c> projectAvailabilitiesList = [SELECT Id, CS_Project__c, District__c, 
																	CS_Project__r.Project_Code__c
																	FROM CS_Project_Availability__c 
																	WHERE District__c in :triggerMap.keySet()];

		Map<Id, Set<String>> districtIdToProjectCodesMap = new Map<Id, Set<String>>();
		for(CS_Project_Availability__c pa : projectAvailabilitiesList) {

			if(projectCodesToExclude.contains(pa.CS_Project__r.Project_Code__c)) continue;

			if(districtIdToProjectCodesMap.containsKey(pa.District__c)) {
				districtIdToProjectCodesMap.get(pa.District__c).add(pa.CS_Project__r.Project_Code__c);
			} else {
				districtIdToProjectCodesMap.put(pa.District__c, new Set<String> { pa.CS_Project__r.Project_Code__c });
			}
		}

		return districtIdToProjectCodesMap;
	}

	private static void updateDistrictsFromProjectAvailabilityMap(Map<Id, CS_Project_Availability__c> triggerMap) {
		Set<Id> includedDistricts = new Set<Id>();
		for(CS_Project_Availability__c pa : triggerMap.values()) {
			includedDistricts.add(pa.District__c);
		}

		List<District__c> districtList = [SELECT Id, Included_Projects__c 
											FROM District__c
											WHERE Id in :includedDistricts];

		if (!districtList.isEmpty()) {
			for (District__c district : districtList) {
				if (district.Included_Projects__c != null && district.Included_Projects__c != '' && !district.Included_Projects__c.contains('\'')) {
					district.Included_Projects__c = '\'' + district.Included_Projects__c.replace(',', '\',\'') + '\'';
				}
			}
		}

		update districtList;
	}
}