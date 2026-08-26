<!-----------------------------------------------------------------------------

FILE NAME:		reprocess.cfm
DESCRIPTION:	Reprocess file
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	23-Apr-2013

------------------------------------------------------------------------------>
<cfsilent>
<cfset pagetitle = "PAYABLES RE-PROCESS">

<cfif structKeyExists(URL, 'display')>
  <cfset form.display = URL.display>
</cfif>
<cfparam name="form.command" 	default="PRGREPROCESS">
<cfparam name="form.display"	default="PROGRAM">
<cfif form.display EQ "program">
	<cfset selectedIndex = 0>
<cfelseif form.display EQ "operator">
	<cfset selectedIndex = 1>
</cfif>
</cfsilent>
<cfset busSegMgr.obj = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset busSegMgr.isEnabled = busSegMgr.obj.isEnabled()/>
<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
#actions { margin-bottom:10px; }
#actions a { margin:0 30px 0 0;}
.even { width:<cfif busSegMgr.isEnabled>33%<cfelse>50%</cfif>; }
.mid { text-align: center; }
div.save { margin-top:10px; }
datatable-scroll {
    overflow-x: auto;
    overflow-y: visible;
}
.modeText {
	position: relative;
	top:-10px;
	margin-left:6px;
}
.locked {
	font-size: 12px;
	font-weight: bold;
	color: red;
}
form {
	margin:11px 0; padding:0;
}
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">
<!--------------------------------------------------------------------------------------------------------------------->
<cfinclude template="\settings\Advanced_Budget\actionFormat.cfm">
<!--------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm"
							layoutID = "reProcess"
							helpLink = "true"
							selectedIndex = "#selectedIndex#" >

<script src="/Common_Files/Delete_Functions.js"></script>
<script src="/script/javascript/string_functions.js"></script>
<script language="JavaScript" src="/Script/javascript/dom_common.js"></script>
<link rel="stylesheet" type="text/css" href="/common_files/viewmodes.css">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset BBManager = createObject("component","mvc.Models.Billback.BillbackManager") />
</head>

<FORM ACTION="reprocess.cfm" METHOD="post" NAME="DataForm">
<!---<cfinclude template="/helpsystem/help_link.cfm">--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---<cfinclude template="/settings/settings_title.cfm">--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif isDefined("URL.lockUnlock")>
	<!--- 1 = lock; 0 = unlock --->
	<cfif URL.lockUnlock>
		<cfset temp = BBManager.lockReprocessPage(request.accessstructure.user_ID) />
	<cfelse>
		<cfset temp = BBManager.unlockReprocessPage() />
	</cfif>
</cfif>

<cfinclude template="lock_unlock.cfm" />

<!--- handle for reprocessing --->

<cfif form.display EQ "program">
	<cfinclude template="BBProgramReprocess.cfm" />
	<cfif isDefined("FORM.BB_ID")>	
		<cfquery name="ReprocessCount" datasource="#application.datasource#">
			DECLARE 
			@Total_Count INT = 0,
			@Total_Success INT = 0,
			@Total_Failed INT = 0
			
			SELECT @Total_Count = COUNT(*) FROM BB_Program_Reprocess_List
			SELECT @Total_Success = COUNT(*) FROM BB_Program_Reprocess_List WHERE Reprocess_Date IS NOT NULL
			SELECT @Total_Failed = COUNT(*) FROM BB_Program_Reprocess_List WHERE Reprocess_Date IS NULL
			
			SELECT @Total_Count AS Total_Count, @Total_Success AS Total_Success, @Total_Failed AS Total_Failed
		</cfquery>
		<cfoutput>
			<script language="javascript">
			alert('Re-process has completed.  Your results are:\n\n Record Count\n----------------\n#ReprocessCount.Total_Success#  Passed\n#ReprocessCount.Total_Failed#  Remains in re-process\n-------------------------------\n#ReprocessCount.Total_Count#   Total in the batch');
			</script>
		</cfoutput>
	</cfif>

<cfelseif form.display EQ "operator">
	 <cfinclude template="BBOperatorReprocess.cfm" />
</cfif>
<cfoutput>
	<input name="command" id="command" type="hidden" value="#form.command#" />
	<input name="display" id="display" type="hidden" value="#form.display#" />
</cfoutput>
</form>

</body>
</html>

<!--- <cfinclude template="\common_files\datatable\viewDataTable.cfm"> --->

<script language="javascript">
	function selectAll(thisObj)
	{
		var chObjs = document.all.BB_ID;
		var bCheck = thisObj.checked;
		var i;
		if(chObjs)
		{
			if(chObjs.length)
			{
				for(i=0;i<chObjs.length;i++)
				{
					chObjs[i].checked = bCheck;
				}
			}
			else
			{
				chObjs.checked = bCheck;
			}
		}
	}

	function fnReprocess()
	{
		var actionFrm = document.DataForm;
		var chObjs = document.all.BB_ID;
		actionFrm.command.value = 'PRGREPROCESS';
		var iShowAlert = 0;

		if (chObjs)
		{
			if(chObjs.length)
			{
				for(i=0;i<chObjs.length;i++)
				{
					if (chObjs[i].checked == true)
					{
						iShowAlert++;
					}
				}
				if (iShowAlert==0)
				{
					alert("Please check atleast one record to process!!");
				}
				else
				{
					document.getElementById('aReProcess').disabled=true;
					document.getElementById('aReProcess2').disabled=true;
					actionFrm.submit();
					return false;
				}
			}
		}
		else
		{
			actionFrm.submit();
			return false;
		}
	}


	function fnSavePG()
	{
		var actionFrm = document.DataForm;
		var chObjs = document.all.BB_ID;
		actionFrm.command.value = 'OPERSAVE';
		var iShowAlert = 0;

	if (chObjs)
		{
			if(chObjs.length)
			{
				for(i=0;i<chObjs.length;i++)
				{
					if (chObjs[i].checked == true)
					{
						iShowAlert++;
					}
				}
				if (iShowAlert==0)
				{
					alert("Please check atleast one record to process!!");
				}
				else
				{
					actionFrm.submit();
					return false;
				}
			}
		}
		else
		{
			actionFrm.submit();
			return false;
		}
	}


function submitDataForm(action)
{
	var actionFrm = document.DataForm;

	//if action is edit set the compId hidden value, then reset the action to the existing state
	 actionFrm.display.value = action;
  actionFrm.submit();
	return false;
}


</script>

</cfmodule>
