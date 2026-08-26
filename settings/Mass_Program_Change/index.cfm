<cfsilent>
<!---
	Name         : index.cfm
	Copyright    : Copyright (c) 2010 Blacksmith Applications , Inc.
	Created Date : 12/01/2010
	Created By   : Kal
	Label        : 25195
	Description  : Mass Program Change Upload Utility
--->
</cfsilent>

<!--- Initiate the CFC --->
<cfset MPCUManager = createObject("component","mvc.Models.Program.Upload.MassProgramChange") />

<!--- css includes --->
<link rel="stylesheet" type="text/css" href="/common_files/main_style.css">
<link rel="stylesheet" type="text/css" href="/common_files/viewmodes.css">
<link rel="stylesheet" type="text/css" href="/common_files/upload_styles.css">

<!--- JS / jQuery includes --->
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery-1.2.1-min.js"></script>


<!--- get all variables/parameters into variable scope  --->
<cfparam name="variables.updateType" default="#MPCUManager.getUpdateType(request.accessstructure.user_ID)#" />
<cfset temp = structAppend(variables,form) />
<cfset temp = structAppend(variables,url) />

<!--- header file --->
<cfinclude template="header.cfm" />

<!--- TODO: Remove this line 
<cfdump var="#variables.updateType#" label="variables" />
<cfdump var="#form#" label="form" />
<cfdump var="#url#" label="url" />
--->

<!--- Lock unlock actions --->
<cfif isDefined("variables.lockUnlock")>
	<!--- 1 = lock; 0 = unlock --->
	<cfif variables.lockUnlock> 
		<cfset temp = MPCUManager.lockPage(request.accessstructure.user_ID) />
	<cfelse>
		<cfset temp = MPCUManager.unlockPage() />
	</cfif>
</cfif>
<!--- Lock unlock file --->
<cfinclude template="lock_unlock.cfm" />

<!--- to display any msgs --->
<div id="displayMsg" class="displayMsg"></div> 

<!--- upload file section --->
<cfinclude template="upload_file.cfm">

<!--- Show Grid to edit the errors --->
<cfinclude template="displayGrid.cfm" />

<!--- <cfdump var="#variables#"> --->
<cfoutput>
	
	<!--- Schedule the mass revise --->
	<cfif isDefined("variables.scheduleTypeOption")>
		<cfif (variables.scheduleTypeOption eq "execute") AND (MPCUManager.checkSchedule() EQ 0) AND len(variables.updateType)  >
			<cfset temp = MPCUManager.executeMassUpdate(request.accessstructure.user_ID, variables.updateType) />
		<cfelseif (variables.scheduleTypeOption eq "cancel")>
			<cfset temp = MPCUManager.cancelMassUpdate() />
		</cfif>
	</cfif>
 
	<!--- If uploaded data has no error records to show then allow to schedule the revise  --->
	<cfif (MPCUManager.checkLock().IS_LOCKED EQ 1)
	 AND MPCUManager.checkLock().User_ID EQ request.AccessStructure.User_ID
	 AND MPCUManager.getDataExists()
	 AND NOT(MPCUManager.getErrors())>
		<div id="scheduleMsg" class="buttonText" align="center">
			<form name="massScheduleForm" id="massScheduleForm">
				<cfif NOT MPCUManager.checkSchedule() >
					<span class="redBracket">[</span><a href="##" onclick="javascipt:verifyScheduleForm('execute');">execute mass update</a><span class="redBracket">]</span> 
					<span class="redBracket">[</span><a href="##" onclick="javascipt:verifyScheduleForm('cancel');">cancel mass update</a><span class="redBracket">]</span>
				</cfif>
				<input type="hidden" name="scheduleTypeOption" value="0">
				<!--- link to force display of grid & upload sections --->
				<span class="redBracket">[</span><a href="##" id="dataLink" onclick="javascript:displayUploadGrid(this);">show/hide upload form</a><span class="redBracket">]</span>
			</form>
		</div>
	</cfif> 
</cfoutput>



<!--- JavaScript/jQuery --->
<script type="text/javascript">
	$(document).ready(function(){
		chkLocked = function(){
			if('<cfoutput>#MPCUManager.checkLock().IS_LOCKED#</cfoutput>' == 1 
				&& '<cfoutput>#MPCUManager.checkLock().User_ID#</cfoutput>' != '<cfoutput>#request.AccessStructure.User_ID#</cfoutput>')
			{
				// locked and not same user, hide everything
				displayMessage('Utility is currently locked. Unlock to edit/upload!');
				hideUpload();
				hideGrid();
			}
			else if('<cfoutput>#MPCUManager.checkLock().IS_LOCKED#</cfoutput>' == 0){
				// not locked (with or without data) then ask the user to lock it.
				displayMessage('Please lock the utility to edit/upload a file!');
				hideUpload();
				hideGrid();
			}		
		}
		
		// if no data hide the grid
		chkData = function(){
			if('<cfoutput>#MPCUManager.checkLock().IS_LOCKED#</cfoutput>' == 1
				&& '<cfoutput>#MPCUManager.checkLock().User_ID#</cfoutput>' == '<cfoutput>#request.AccessStructure.User_ID#</cfoutput>'
				&& '<cfoutput>#MPCUManager.getDataExists()#</cfoutput>' == 0)
			{
				
				<cfif !bValidSpreadSheet>
					displayMessage('Invalid SpreadSheet. <cfoutput>#spreadSheetError#</cfoutput>');
				<cfelse>
				displayMessage('No data to display, upload a file!');
				</cfif>
				hideGrid();
			}
		}

		// if data exists and no errors, hide the grid & upload
		chkErrors = function(){
			if('<cfoutput>#MPCUManager.checkLock().IS_LOCKED#</cfoutput>' == 1
				&& '<cfoutput>#MPCUManager.checkLock().User_ID#</cfoutput>' == '<cfoutput>#request.AccessStructure.User_ID#</cfoutput>'
				&& '<cfoutput>#MPCUManager.getDataExists()#</cfoutput>' == 1 
				&& '<cfoutput>#MPCUManager.getErrors()#</cfoutput>' == 0
				&& '<cfoutput>#MPCUManager.checkSchedule()#</cfoutput>' == 0)
			{
				displayMessage('No errors to display!');
				hideUpload();
				hideGrid();
			}
		}

		// if scheduled then display scheduled message
		chkSchedule = function(){
			if('<cfoutput>#MPCUManager.checkSchedule()#</cfoutput>' == 1){
				displayMessage('An update is currently in process');
				hideUpload();
				hideGrid();
			}
		}

		chkLocked();
		chkData();
		chkErrors();
		chkSchedule();
	});
	
	displayMessage = function(msg){
		$('#displayMsg').append(msg);	
		$('#displayMsg').append('<br/>');
	
	} 
	
	hideUpload = function(){
		$('#uploadFileForm').hide();	
	} 
	
	hideGrid = function(){
		$('#displayGridForm').hide();	
	} 
	
	displayUploadGrid = function(linkText){
		$('#uploadFileForm').toggle(100);
		// $('#displayGridForm').toggle(500);
	}
	
	popHelp = function(){
		//NewWindowTopLeft(mypage, myname, w, h, scroll, resize, returnWindow, menubar)
		NewWindowTopLeft('upload_instructions.cfm', 'popHelp', 480, 760, 1, 0, 0, 0);
	}
	
	function verifyScheduleForm(scheduleOption)
	{
		if(scheduleOption == 'cancel' || scheduleOption == 'execute' ){
			document.massScheduleForm.scheduleTypeOption.value = scheduleOption;
			document.massScheduleForm.submit();
		}
		return false;
	}
	
</script>
