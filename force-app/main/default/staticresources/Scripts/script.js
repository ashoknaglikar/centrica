function showContactInfo(item, winid, cList)
{	
	for(var i=0; i<cList.length; i++) cList[i].style.display = "none";
	if(!item.checked)
	{
		document.getElementById(winid).style.display = '';
	}
}