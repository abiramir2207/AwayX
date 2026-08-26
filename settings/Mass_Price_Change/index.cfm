<cfsilent>
<!---
       Name:          index.cfm
       Copyright:     Copyright (c) 2013 Blacksmith Applications, Inc.
       Created Date:  05/30/2013
       Created By:    Kal
       Label:		  34605
       Description:   Mass Price Change Utility
--->
</cfsilent>

<!--- Initiate the CFC --->
<cfset MPCManager = createObject("component","mvc.Models.Program.Upload.MassPriceChange") />

<!--- css includes --->
<link rel="stylesheet" type="text/css" href="/common_files/main_style.css">
<link rel="stylesheet" type="text/css" href="/common_files/viewmodes.css">
<link rel="stylesheet" type="text/css" href="/common_files/upload_styles.css">

<!--- JS / jQuery includes --->
<cfset jQueryUI.version ="1.10.3" />
<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
<cfinclude template="/common_files/jQuery.cfm">



<!--- get all variables/parameters into variable scope  --->
<!--- <cfparam name="variables.updateType" default="#MPCManager.getUpdateType(request.accessstructure.user_ID)#" /> --->
<cfset temp = structAppend(variables,form) />
<cfset temp = structAppend(variables,url) />

<!--- header file --->
<cfinclude template="header.cfm" />


<!--- Lock unlock actions --->
<cfif isDefined("variables.lockUnlock")>
	<!--- 1 = lock; 0 = unlock --->
	<cfif variables.lockUnlock>
		<cfset temp = MPCManager.lockPage(request.accessstructure.user_ID) />
	<cfelse>
		<cfset temp = MPCManager.unlockPage() />
	</cfif>
</cfif>
<!--- Lock unlock file --->
<cfinclude template="lock_unlock.cfm" />

<!--- to display any msgs --->
<div id="displayMsg" class="displayMsg"></div>
<div id="prgCountDisplay" class="displayMsg"></div>

<!--- upload file section --->
<cfinclude template="upload_file.cfm">


<cfoutput>
	<!--- Schedule the mass revise --->
	<!--- If uploaded data has valid records then allow to schedule the revise  --->
	<cfif (MPCManager.checkLock().IS_LOCKED EQ 1)
	 AND MPCManager.checkLock().User_ID EQ request.AccessStructure.User_ID
	 AND MPCManager.getDataExists()>
		<div id="scheduleMsg" class="buttonText" align="center">
			<cfif NOT MPCManager.checkScheduled() >
				<div id="executeMPdiv"> <span class="redBracket">[</span><a href="##" id="executeMPUpdate">execute mass update</a><span class="redBracket">]</span> </div>
				<div id="cancelMPdiv"> <span class="redBracket">[</span><a href="##" id="cancelMPUpdate">cancel mass update</a><span class="redBracket">]</span> </div>
			</cfif>
			<!--- link to update staus --->
			<div id="mpReportdiv"> <span class="redBracket">[</span><a href="##" id="updateStatus">refresh status</a><span class="redBracket">]</span> </div>
			<!--- <div id="mpReportdiv"> <span class="redBracket">[</span><a href="reportDownload.cfm" id="mpReportLink">download report</a><span class="redBracket">]</span> </div> --->
		</div>
	</cfif>
</cfoutput>


<!--- JavaScript/jQuery --->
<script type="text/javascript">
	$(document).ready(function(){
		chkLocked = function(){
			if('<cfoutput>#MPCManager.checkLock().IS_LOCKED#</cfoutput>' == 1
				&& '<cfoutput>#MPCManager.checkLock().User_ID#</cfoutput>' != '<cfoutput>#request.AccessStructure.User_ID#</cfoutput>')
			{
				// locked and not same user, hide everything
				displayMessage('Utility is currently locked. Unlock to edit/upload!');
				hideUpload();
			}
			else if('<cfoutput>#MPCManager.checkLock().IS_LOCKED#</cfoutput>' == 0){
				// not locked (with or without data) then ask the user to lock it.
				displayMessage('Please lock the utility to edit/upload a file!');
				hideUpload();
			}
		}

		// if valid data then hide the form
		chkData = function(){
			if(	'<cfoutput>#MPCManager.checkLock().IS_LOCKED#</cfoutput>' == 1
				&& '<cfoutput>#MPCManager.checkLock().User_ID#</cfoutput>' == '<cfoutput>#request.AccessStructure.User_ID#</cfoutput>'
				&& '<cfoutput>#MPCManager.checkScheduled()#</cfoutput>' == 0
				)
			{
				// if any validation errors then display
				if('<cfoutput>#MPCManager.getDataExists()#</cfoutput>' == 1){
					displayMessage('<cfoutput>#spreadSheetError#</cfoutput>');
					displayMessage('Data validated, please execute the update');
					hideUpload();
				}
			}
		}

		// if scheduled then display scheduled message
		chkSchedule = function(){
			if('<cfoutput>#MPCManager.checkScheduled()#</cfoutput>' == 1){
				displayMessage('An update is currently in process');
				showStatusDiv();
				hideUpload();
			}
		}

		$('#executeMPUpdate').click(function() {
			$('#xlErrors').hide();
			$('#displayMsg').html('executing mass price update...!');
			$.ajax({
				url: "/mvc/Models/Program/Upload/MassPriceChange.cfc"
				,type: "post"
				,data: {
					method: "executeMassUpdate",
					user_ID: '<cfoutput>#request.AccessStructure.User_ID#</cfoutput>'
				}
				,dataType: "json"
				,async: true
				,timeout: 60000
				,error: function(jqXHR, textStatus, errorThrown) {
					alert('An unexpected problem has occurred, please report this error!');
				}
				,success: function(data) {
					$('#displayMsg').html(data + ' programs to update! ');
					showStatusDiv();
					// TODO:
					// 	Display program counts
					// 	When count is zero for the locked use show download link
					// show refresh link display counts.
				}
			})
			return false;
		});


		$('#cancelMPUpdate').click(function() {
			$('#xlErrors').hide();
			$('#displayMsg').html('cancelling update...!');
			$.ajax({
				url: "/mvc/Models/Program/Upload/MassPriceChange.cfc"
				,type: "post"
				,data: {method: "cancelMassUpdate"}
				,dataType: "json"
				,async: true
				,timeout: 60000
				,error: function(jqXHR, textStatus, errorThrown) {
					alert('An unexpected problem has occurred, please report this error!');
				}
				,success: function(data) {
					$('#displayMsg').html('cancelled !');
					$('#displayMsg').css('display','none');
					$('#scheduleMsg').hide();
					$('#uploadFileForm').show();
				}
			})
			return false;
		});


		$(function() {$("#datepicker").datepicker();});
		$('#mpReportdiv').css('display','none');

		chkLocked();
		chkData();
		chkSchedule();

	}); //end document.ready

	displayMessage = function(msg){
		$('#displayMsg').append(msg);
		$('#displayMsg').append('<br/>');
	}

	hideUpload = function(){
		$('#uploadFileForm').hide();
	}

	popHelp = function(){
		NewWindowTopLeft('help.cfm', 'popHelp', 800, 400, 1, 0, 0, 0);
	}

	showStatusDiv = function(){
		$('#mpReportdiv').css('display','block');
		$('#executeMPdiv').css('display','none');
		$('#cancelMPdiv').css('display','none');
	}

	$('#updateStatus').click(function() {
		$.getJSON( '/mvc/Models/Program/Upload/MassPriceChange.cfc', {
			method:"getProgramCounts",
			returnFormat:"json"
		}) // $.getJSON
		.done(function(data){  // success: populate customers.
			$('#displayMsg').html(data.DATA[0][0] + ' : programs processed.<br> ' + data.DATA[0][1] + ' / '+ data.DATA[0][2] + ' : programs to update! <br>' );
			displayMessage('An update is currently in process');
		}) // $.getJSON done // success: populate customers.
		.fail(function() {
			$('#displayMsg').html('');
		}); // $.getJSON done // fail
	});

	emailReport = function(){
		$.ajax({
			"dataType": 'json',
			"type": "POST",
			 url: "emailReport.cfm?userEmail=<cfoutput>#request.AccessStructure.User_Email#</cfoutput>"
		})
	}

</script>
