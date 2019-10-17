@isTest
private class DeleteNotes_Test {

public static testMethod void noteTestMethod(){

account acc = TestClassHelper.createAccout();
insert acc;

Profile p = [Select id from profile where name !='System Administrator' limit 1];
User user = new user(profileid= p.id,alias = 'standt', email='DeleteNotes@testorg.com',
emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', 
timezonesidkey='America/Los_Angeles', username='DeleteNotes@testorg.com');

insert User;


system.runas(User){
Note NoteObj = New Note(
Title='tittle',
Body='body',
Parentid =acc.id,

OwnerId = User.id


);

insert NoteObj ; 

NoteObj.Body ='asdh';
NoteObj.Title ='bcdh';
try
{
    Update NoteObj;
}
catch(exception ex){}

}
}


Public static testMethod void noteTestMethod1(){

account acc = TestClassHelper.createAccout();
insert acc;

Profile p = [Select id from profile where name !='System Administrator' limit 1];

User user = new user(profileid = p.id,alias = 'standt1', email='DeleteNotes1@testorg.com',
emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', 
timezonesidkey='America/Los_Angeles', username='DeleteNotes12@testorg.com');

insert User;

system.runas(User){

Note NoteObj = New Note(
Title='tittle',
Body='body',
Parentid =acc.id,
OwnerId = User.id
);

insert NoteObj ; 

NoteObj.Body ='asdh';
NoteObj.Title ='bcdh';

try{
Delete NoteObj;

}
catch(Exception ex)
{}
}

}
}