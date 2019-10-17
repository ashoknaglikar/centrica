/*
Type Name: bINS_bUPD_MatchPublicGroupName
Author: Cognizant
Created Date: 09/07/2010
Reason: Agency change:This trigger prevents the user from entering agency 
        into the system for which public group does not exist into the system.
Change History:
*/

trigger bINS_bUPD_MatchPublicGroupName on Agency__c (before insert,before update) {

    List<Group> groupList = new List<Group>();
    List<String> groupNameList = new List<String>();
    Integer iFlag;
    //SELECTING ALL THE PUBLIC GROUPS FROM EXISTING SYSTEM.   
    for(Group g : [Select g.Type, g.Name, g.Id, g.Email From Group g where g.type = 'Regular'])
    {
        groupNameList.add(g.name);
    }  
    
    for(integer i = 0; i < Trigger.new.size(); i++ )
    {
        iFlag = 0;
        for(integer j = 0; j < groupNameList.size(); j++ ){
            if(Trigger.new[i].name == groupNameList[j]){
                iFlag = 1;
                break;
            }
        }
        if(iFlag != 1){
            Trigger.new[i].addError('Public group does does not exist with this agency name,\n Please give another agency name');
        }
    }
}