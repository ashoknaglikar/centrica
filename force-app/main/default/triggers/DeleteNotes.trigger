trigger DeleteNotes on Note (before delete, before update) {

     Id currentProfileId = userinfo.getProfileId();
     
if(Trigger.isDelete){

//Here trigger.old is used to store value before deletion

for(Note NoteObj:trigger.old){ 

//where Note_function is the API name of custom label Note Function                                  
    if(!label.SystemAdminId.contains(currentProfileId))    
         NoteObj.Adderror('Cannot delete the note');  
} 
}
if(Trigger.isUpdate){
//Here trigger.new is used to store value after updation

for(Note NoteObj:trigger.new){       
                              
    if(!label.SystemAdminId.contains(currentProfileId))     
     NoteObj.Adderror('Cannot update the note');  
}
}
}