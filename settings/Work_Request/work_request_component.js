// JavaScript Document

///////////////////////////////////   Submit //////////////////////////////////////////	
function submitDataForm(action,compId)
{
	var actionFrm = document.DataForm;
		
	//if action is edit set the compId hidden value, then reset the action to the existing state
	if (action == "edit")
	{
		actionFrm.compId.value = compId;
		actionFrm.returnTo.value = actionFrm.display.value;
	}
	if (action == "add")
	{
		if(actionFrm.compExternalID)
		{
			actionFrm.compExternalID.value = "";
		}
		if(actionFrm.compName)
		{
			actionFrm.compName.value = "";
		}		
	}
		
	actionFrm.display.value = action;
	actionFrm.submit();
	return false;
}

///////////////////////////////////   Add Component //////////////////////////////////////////		
function addComp()
{
	var ErrorCount = 0;
	var actionFrm = document.DataForm;
		
	//do validation
	if (trim(actionFrm.Work_Title.value) == "")
	{
		ErrorCount++;
		queueMessage("Please provide the 'Issue Title' of the request", document.all.error_title);
		
	}
	else
	{
		clearQueue(document.all.error_title);
	}

	var matchURL = actionFrm.URLEnvironment.value.search(/.com/i);
	if(matchURL == -1)
	{ 
		ErrorCount++;
		queueMessage("Please provide the valid 'URL Of The Environment'. Ex:  acme.com", document.all.err_URLEnvironment);
	}
	
	else
	{
		clearQueue(document.all.err_URLEnvironment);
	}

	if (trim(actionFrm.ProgBBDDIDs.value) == "")
	{
		ErrorCount++;
		queueMessage("Please provide the 'Prog ID, BB ID,  DD ID and Interface Name'", document.all.err_ProgBBDDIDs);
		
	}
	else
	{
		clearQueue(document.all.err_ProgBBDDIDs);
	}

	if (trim(actionFrm.UserInfo.value) == "")
	{
		ErrorCount++;
		queueMessage("Please provide the 'User Name, Password, Position, Profile'", document.all.err_UserInfo);
		
	}
	else
	{
		clearQueue(document.all.err_UserInfo);
	}

	if (trim(actionFrm.CurrentBehavior.value) == "")
	{
		ErrorCount++;
		queueMessage("Please provide the current behavior", document.all.err_CurrentBehavior);
		
	}
	else
	{
		clearQueue(document.all.err_CurrentBehavior);
	}

	if (trim(actionFrm.ExpectedBehavior.value) == "")
	{
		ErrorCount++;
		queueMessage("Please provide the expected behavior", document.all.err_ExpectedBehavior);
		
	}
	else
	{
		clearQueue(document.all.err_ExpectedBehavior);
	}
	
	if (trim(actionFrm.Client_Priority.value) == "0")
	{
		ErrorCount++;
		queueMessage("Please select priority", document.all.err_Client_Priority);
		
	}
	else
	{
		clearQueue(document.all.err_Client_Priority);
	}

	if (trim(actionFrm.App_Area.value) == "0")
	{
		ErrorCount++;
		queueMessage("Please select the affected application area", document.all.err_App_Area);
		
	}
	else
	{
		clearQueue(document.all.err_App_Area);
	}

	if (trim(actionFrm.Request_Type.value) == "0")
	{
		ErrorCount++;
		queueMessage("Please select request type", document.all.err_Request_Type);
		
	}
	else
	{
		clearQueue(document.all.err_Request_Type);
	}

	if(ErrorCount == 0) {
	//set hidden form fields and submit
	actionFrm.command.value = 'addComp';
	actionFrm.display.value = 'active';
	actionFrm.submit();
	disableButton('save_wr_table', true, false);
	return false;	
	}		
	else {
				showMessageWindow();
		return false;
	}	
}

///////////////////////////////////   Delete Component //////////////////////////////////////////		
function deleteComp(compId)
{
	var actionFrm = document.DataForm;

	if(confirm("Do you really want to delete the selected work request?"))
	{
		actionFrm.compId.value = compId;
		actionFrm.display.value = 'active'
		actionFrm.command.value = 'delete';
		actionFrm.submit();
		return false;
	}
		
	return false;
}

///////////////////////////////////   Search //////////////////////////////////////////

function doSearchNow()
{
	document.DataForm.display.value = 'searchResults';
	document.DataForm.submit();
	return false;
}

///////////////////////////////////   Document Screen //////////////////////////////////////////
function documentWindow(compId)
{
	var windowLocation = "work_request_documents.cfm?Work_Request_ID=" + compId;

	NewWindow(windowLocation, "WorkReqDocuments", 800, 600, "yes", "yes")
	
	return false;
}

///////////////////////////////////   Document Screen //////////////////////////////////////////
function documentWindowAdd(compId)
{
	var windowLocation = "work_request_documents.cfm?MatchAttch=" + compId;

	NewWindow(windowLocation, "WorkReqDocumentsAdd", 800, 600, "yes", "yes")
	
	return false;
}
///////////////////////////////////   Show/hide details //////////////////////////////////////////
function showDetails(Punch_ID)
{

	var documentLocation1 = eval("document.all.releaseDetails" + Punch_ID + "1")
	var documentLocation2 = eval("document.all.releaseDetails" + Punch_ID + "2")
	var documentLocation3 = eval("document.all.releaseDetails" + Punch_ID + "3")
	var documentLocation4 = eval("document.all.releaseDetails" + Punch_ID + "4")
	var documentLocation5 = eval("document.all.releaseDetails" + Punch_ID + "5")
	var documentLocation6 = eval("document.all.releaseDetails" + Punch_ID + "6")
	var showLink = eval("document.all.ShowLink_" + Punch_ID)
	
	documentLocation1.style.display = "";
	documentLocation2.style.display = "";
	documentLocation3.style.display = "";
	documentLocation4.style.display = "";
	documentLocation5.style.display = "";
	documentLocation6.style.display = "";
	showLink.style.display = "none";
	return false;
}

///////////////////////////////////   Edit notes //////////////////////////////////////////
function NotesPopup(workRequestID,SearchData)
{
		var windowLocation = "work_request_notes_edit.cfm?Work_Request_ID=" + workRequestID+"&Search_Data="+SearchData;

		NewWindow(windowLocation, "WorkReqNotes", 800, 600, "yes", "yes")
	
		return false;
}

///////////////////////////////////  Export to XL  //////////////////////////////////////////
function ExportToXL()
{
	
	var Request_Desc = document.DataForm.Request_Desc.value;
	var Request_Type= document.DataForm.Request_Type.value;
	var App_Area= document.DataForm.App_Area.value;
	var Client_Priority= document.DataForm.Client_Priority.value;
	var Item_Status= document.DataForm.Item_Status.value;
	var Built_To = document.DataForm.Built_To.value;
	var Created_Since_Date= document.DataForm.Created_Since_Date.value;
	if (Built_To.length  == 0)
	{
		Built_To = 0;
	}

	var windowLocation = "work_request_XL_export.cfm?Request_Desc="+Request_Desc+"&Request_Type="+Request_Type+"&App_Area="+App_Area+"&Client_Priority="+Client_Priority+"&Item_Status="+Item_Status+"&Built_To="+Built_To+"&Created_Since_Date="+Created_Since_Date;
	NewWindow(windowLocation, "ExportToXL", 800, 600, "yes", "yes")
	return false;
}

///////////////////////////////////  expandTable //////////////////////////////////////////
function expandTable(objectID) {
		var object = document.getElementById("TB_"+objectID);
		tempVar = eval("document.all.TB_"+objectID);
		var myPIcon = document.getElementById("picon_" + objectID);
		if (object.style.display =='block')  {
			document.getElementById("picon_" + objectID).innerHTML = "show details";
			object.style.display='none';
			for(var x=0; x<tempVar.length;x++){
			tempVar[x].style.display = 'none';
			}
		}
		else {
			document.getElementById("picon_" + objectID).innerHTML = "hide details";
			object.style.display='block';
			for(var x=0; x<tempVar.length;x++){
			tempVar[x].style.display = 'block';
			}
		}
		return;
}