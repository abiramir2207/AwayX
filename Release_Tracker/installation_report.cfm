<!---
***********************************************************************
Author: Milan Mushran
Filename: installation_report.cfm
Purpose: For viewing reports on patches installed.
Date Created: 10/04/2006
Modification: Added new new fields in the report - Version_Number,Comments
Modified By: Milan Mushran
Modified Date: 10/20/2006
Modification:
Modified By:
Modified Date:
***********************************************************************
--->
<STYLE TYPE="text/css">
		.filetypeheader{
			font-size: 11px;
			font-weight : bold;
			font-family:verdana;
			background: #FFFFCC;
		}
		.header
		{
			font-size: 11px;
			font-weight : bold;
			font-family:verdana;
			background: #FFCC99;
		}	
		TD.Underlined
		{
			border-bottom: 1px solid #7575FF;
		}
		TR.highlight TD.Underlined
		{
			background-color: #EAFFEA;
			border-bottom: 1px solid #7575FF;
			align: right;
		}
		TR.nothighlight TD.Underlined  
		{
			border-bottom: 1px solid #7575FF;
		}
</STYLE>
<SCRIPT language="JavaScript">
/* Click on the date to view the details for that date. */
/* This function accepts the number of records and two other parameters(which together form the uniqueID) */
function expandTable(objectID,ShowString,HideString) {
		var object = document.getElementById("TB_"+objectID);
		tempVar = eval("document.all.TB_"+objectID);
		if (object.style.display =='block')  {
			document.getElementById("picon_" + objectID).innerHTML = ShowString;
			object.style.display='none';
			for(var x=0; x<tempVar.length;x++){
			tempVar[x].style.display = 'none';
			}
		}
		else {
			document.getElementById("picon_" + objectID).innerHTML = HideString;
			object.style.display='block';
			for(var x=0; x<tempVar.length;x++){
			tempVar[x].style.display = 'block';
			}
		}
		return;
}

/* This function is used to view the "labels not yet deployed feature" */
function ClickToViewData(TotalRowsDetailed)
{
	var PunchListObject;

for (i=1; i<=TotalRowsDetailed; i++)
{
/* Get the row's ID */
PunchListObject = document.getElementById('PunchList_'+i)

	if(PunchListObject)
	{
		if(PunchListObject.style.display == 'none')
		{
			PunchListObject.style.display = '';
		}
		else
		{
			PunchListObject.style.display = 'none';
		}
	}
}
	return false;
}
</SCRIPT>

<cfparam name="PageTitle" default="">
<cfparam name="getInstallationDetails.File_Name" default="">
<cfparam name="getInstallationDetails.File_Path" default="">
<cfparam name="getInstallationDetails.Comments" default="">
<cfparam name="Application_Installation_Label_ID" default="0">
<cfparam name="AllOfLabels" default="0">

<!--- Displays the page title set in the URL --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<CFQUERY NAME="getInstallationDates" datasource="#application.datasource#">
		SELECT  DISTINCT Release_Version, Patch_Number,Installed_Date
		FROM Application_Installation
		WHERE INSTALLED_DATE IS NOT NULL
		ORDER BY Installed_Date DESC, Patch_Number Desc
</CFQUERY>

<cfset ReleaseVersionList = "">

<table border="0" cellpadding="4" cellspacing="0">
	<tr><td colspan="100%"> <font color = "maroon" SIZE="2"><u>DEPLOYMENT DATE (PATCH NUMBER)</u></font></td></tr>
	<cfoutput query = "getInstallationDates">
		<!---
		<CFSET ReleaseVersion = getInstallationDates.Release_Version>
		<cfif NOT ListContains(ReleaseVersionList,ReleaseVersion)>
		<tr>		
			<td colspan="100%"><b><u>DEPLOYMENT DATES (PATCH NUMBER) FOR RELEASE #ReleaseVersion#</b></u></td>
		<tr>
		</cfif>
		<cfset ReleaseVersionList = ListAppend(ReleaseVersionList,ReleaseVersion)>
		--->

	<CFQUERY NAME="getInstallationDetails" datasource="#application.datasource#">
		SELECT AI.Application_Installation_ID, AI.File_Path, LTRIM(RTRIM(AI.Release_Version)) As Release_Version, AI.Patch_Number, AI.CF_Installation, AI.Object_Type,
		AI.File_Name, AI.Installed_Date, AI.Name, AI.Label_Number, AIAD.Comments
		FROM Application_Installation AI LEFT OUTER JOIN Application_Installation_Aux_Data AIAD
		ON AI.Application_Installation_ID = AIAD.Application_Installation_ID
		WHERE AI.Installed_Date =  '#getInstallationDates.Installed_Date#'
		AND AI.Patch_Number = '#getInstallationDates.Patch_Number#'
		ORDER BY  AI.Object_Type, AI.File_Path,  AI.CF_Installation, AI.Installed_Date DESC
	</CFQUERY>
	<CFQUERY NAME="getInstallationLabels" datasource="#application.datasource#">
		SELECT Labels
		FROM Application_Installation_Label
		WHERE Inserted_Date =  '#getInstallationDates.Installed_Date#'
	</CFQUERY>
	<cfset AllOfLabels = ValueList(getInstallationLabels.Labels,",")>
	
	<cfif Len(AllOfLabels) GT 142>
		<cfset ModNumber = Len(trim(AllOfLabels)) \ 140>	
		<cfloop index = "LoopCount" from = "1" to = #ModNumber#>
			<cfset AllOfLabels = #Insert("<br>", trim(AllOfLabels),LoopCount*140+(LoopCount-1)*4 )#>
		</cfloop>
	</cfif>
	<!--- Click on this row to view the report of that date. --->	
	<tr>
		<cfset PatchNumber = Replace(getInstallationDates.Installed_Date, "-","" , "all")>
		<cfset PatchNumber = right( left(trim(PatchNumber),8), 6)>
		<cfset ShowLabelID = "LID#PatchNumber#">
		<td><a  href="javascript:expandTable('#ShowLabelID#','labels','hide labels');"><B># left(trim(getInstallationDates.Installed_Date),10)#</B></a>
		<B>(#Replace(getInstallationDates.Patch_Number, "000","")##PatchNumber#)</B></td>
		</td>
		<td>
			<b><font color="red">[</font></b>
			<a id="#ShowLabelID#" href="javascript:expandTable('#ShowLabelID#','labels','hide labels');">
				<b id="picon_#ShowLabelID#">labels</b>
			</a>
			<b><font color="red">]</font></b>
		</td>	
		<td>
			<b><font color="red">[</font></b><a href="installation_report_details.cfm?Installed_Date=#left(getInstallationDates.Installed_Date,10)#&Patch_Number=#getInstallationDates.Patch_Number#&PageTitle=SYSTEM ADMINISTRATION: Installation Report">more details</a>
			<!--- <a id="#PatchNumber#" href="javascript:expandTable('#PatchNumber#','show details','hide details');">
				<b id="picon_#PatchNumber#">show details</b>
			</a>--->	
			<b><font color="red">]</font></b>
		</td>		
	</tr>
	<tr>	
		<td colspan="3">
			<table id="TB_#ShowLabelID#" width="100%" style="display:none" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
				<tr><td class="header">Labels:</td></tr>
				<tr><td CLASS="Underlined">#AllOfLabels#</td></tr>
			</table>
		</td>
	</tr>
	<tr>	
		<td colspan="3">
			 <!---
			<table id="TB_#PatchNumber#" width="100%" style="display:none" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
			<tr>
				<td class="header">&nbsp;Date</td>
				<td class="header">&nbsp;Applied By</td>
				<td class="header">&nbsp;Patch</td>
				<td class="header">&nbsp;Label</td>
				<td class="header">&nbsp;File Name</td>
				<td class="header">&nbsp;File Path</td>
			</tr>
			
			<cfloop query="getInstallationDetails">
			<tr>
				<td CLASS="Underlined">&nbsp;#DateFormat(Installed_Date, "m/dd/yyyy")#</td>
				<td CLASS="Underlined">&nbsp;#Name#</td>
				<td CLASS="Underlined">&nbsp;#Patch_Number#</td>
				<td CLASS="Underlined">&nbsp;#Label_Number#</td>
				<td CLASS="Underlined">&nbsp;#getInstallationDetails.File_Name#</td>
				<td CLASS="Underlined" ALIGN="center">&nbsp;
				<CF_SmallHelp
				width="500"
				displayShifyX = "-400"
				
				imgPath="/images/doc.gif"
				imgWidth="11"
				imgHeight="13"
				dropdownCheck="0"
				>
				#getInstallationDetails.File_Path#
				</CF_SmallHelp>
				</td>			
			</tr>
			</cfloop>
			
			</table>--->	
		</td>
	</tr>
	</cfoutput>
</table>

	<!--- DO NOT REMOVE THE CODE BELOW. THE CODE IS REQUIRED. WE ONLY NEED TO REMOVE THE COMMENTS IN THE FUTURE (PERHAPS WITH SOME
				MINOR CHNAGES) FOR THIS FUNCTIONALITY TO WORK--->
<!---
	<CFQUERY NAME="getAllLabels" datasource="punchlist">
		SELECT Punch_ID As Label_Number
		FROM Punch INNER JOIN Punch_Status
		ON Punch.Punch_Status_ID = Punch_Status.Punch_Status_ID
		WHERE (Punch_Status.Punch_Status_Desc like 'Build to%'
		OR Punch.Punch_Status_ID IN (3,20,21))			-- (Closed - Complete, Integration and System testing)
		AND Punch.Punch_Owner_ID != 10							-- UnAssigned
		AND Punch_Status.Punch_Status_Deleted = 0 
		AND Punch.Punch_Release_ID = 
		(
			SELECT Punch_Release_ID
			FROM Punch_Release
			WHERE Punch_Release_Desc like '%#ReleaseVersion#%'
		)
	</CFQUERY>

<p></p>
<hr noshade>
	<table BORDER="0" CELLPADDING="2" CELLSPACING="0" ALIGN="CENTER" width="100%">
	<cfoutput>
		<tr  onmouseout="this.className='nothighlight'" onClick="return ClickToViewData('#getAllLabels.Recordcount#');">
				<td colspan="100%"><b><u>LABELS NOT YET DEPLOYED FOR RELEASE #ReleaseVersion#</u></b>
				<br /><br /> <a href="##"><b>LIST OF LABELS<b></a></td>
		</tr>
	</cfoutput>
		<cfoutput query="getAllLabels">
			<cfset Label_Number = getAllLabels.Label_Number>
				<cfset useLakebaseForgetMissingLabels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("application_installation")>
<cfif useLakebaseForgetMissingLabels>
	<cftry>
		<cfset getMissingLabels = application.oLakebase.toQuery(
			application.oLakebase.selectRows("application_installation", {
				"release_version" = "eq.#ReleaseVersion#",
				"label_number" = "not.is.null",
				"select" = "label_number as label_number"
			}), "label_number as label_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetMissingLabels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetMissingLabels>
<CFQUERY NAME="getMissingLabels" datasource="#application.datasource#">
					SELECT DISTINCT Label_Number AS Label_Number 
					FROM Application_Installation
					WHERE Release_Version = '#ReleaseVersion#'
					AND Label_Number = '#Label_Number#'
					AND Label_Number IS NOT NULL
				</CFQUERY>
</cfif>
					<cfif getMissingLabels.recordcount eq 0>
						<cfset useLakebaseForgetPunchTitle = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("punch")>
<cfif useLakebaseForgetPunchTitle>
	<cftry>
		<cfset getPunchTitle = application.oLakebase.toQuery(
			application.oLakebase.selectRows("punch", {
				"punch_id" = "eq.#Label_Number#",
				"select" = "punch_title"
			}), "punch_title"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPunchTitle = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPunchTitle>
<CFQUERY NAME="getPunchTitle" datasource="punchlist">
							SELECT Punch_Title
							FROM Punch
							WHERE Punch_ID = '#Label_Number#'
						</CFQUERY>
</cfif>
						<cfset Punch_Title = getPunchTitle.Punch_Title>
						<cfset UniqueObjectID = getAllLabels.currentrow>
						<tr id="PunchList_#UniqueObjectID#" style="display:none;">
								<td class="header" valign="top">#getAllLabels.Label_Number#</td>
								<td valign="top">#Punch_Title#</td>
						<tr>
					</cfif>
		</cfoutput>
	</table>
--->
