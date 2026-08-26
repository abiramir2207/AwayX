<cfsetting showDebugOutput="No">
<!DOCTYPE HTML>
<html>
<head>
</head>
<body>
<cfscript>
	request.focusHiLightOff = true;
	appSettings             = application.oApplicationAppSettingsManager.getApplicationAppSettings();
	param name              ="URL.useCache" default="#appSettings.getProgramScorecardCache()#";	
</cfscript>
<cfinclude template="/get_access_profile.cfm">
<style>
	tr {
		height: 20px;
	}
	table.normal-home td {
		font-size:13px;
		padding:0 5px;
	}
	table.normal-home td.count {
		font-weight: bold;
		color: red;
	}
	TD.UNDERLINED
		{
		border-bottom: 1px dotted #7575FF;
		}
	TR.highlight TD.UNDERLINED
		{
		background-color: #E5E5E5;
		border-bottom: 1px dotted #7575FF;
		cursor:pointer;
		}
	TR.nothighlight TD.UNDERLINED  
		{
		border-bottom: 1px dotted #7575FF;
		}

	BODY{
		margin-top: 5px;
		margin-left: 10px;
		margin-right: 10px;
		}
	.subtle
		{
		color:#7c7c7c;
		font-size:11px;
		margin-bottom: 3px;
		}
	.scorecardFooter
		{
		position: absolute;
		text-align: center;
		left: 0;
		right: 0;
		margin: auto;
		bottom: 6px;
		}
</STYLE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header Goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- This file contains the data for the search arguments to be passed to a function that returns the program scorecard summary.
This file is being included in at least one more place - "mvc/models/programs/search_program.cfc".
--->
<cfinclude template="CF_Search_Struct.cfm">

<cfset scorecardTime = Now() />
<cfset All_Status_Programs_Count =  CreateObject("component", "components.programs.ProgramManager").getProgramScorecardSummary(stSearch, URL.useCache)>


<TABLE class="normal-home" border="0" CELLPADDING="0" CELLSPACING="0" height="96%" width="100%" valign="top">
<!--- <cfif Get_Profile_Settings.RFA_Agreed EQ 0> --->
<!--- </cfif> --->
<CFOUTPUT QUERY="All_Status_Programs_Count" group="Contract_Status_Type_Desc">
	<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'" 
		<cfif appSettings.getFlexProgramSearch() eq 1>
			ONCLICK="showSC(#Contract_Status_Type_ID#, #Program_Agree_Status_ID#);"
		<cfelseif appSettings.getFlexProgramSearch() eq 2 OR appSettings.getFlexProgramSearch() eq 3>
			ONCLICK="showSCFx('#Contract_Status_Type_Desc#');"
		<cfelseif appSettings.getFlexProgramSearch() eq 4 OR appSettings.getFlexProgramSearch() eq 5>
			ONCLICK="showSCAGGrid(#Contract_Status_Type_ID#, '#Contract_Status_Type_Desc#');"
		<cfelse>
			ONCLICK="showSC(#Contract_Status_Type_ID#, #Program_Agree_Status_ID#);"
		</cfif>
		<cfif All_Status_Programs_Count.currentrow eq 1>style="padding-top:2px;"</cfif>>

		<TD WIDTH="160" CLASS="UNDERLINED">
			<CFIF ABS(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>#Contract_Status_Type_Desc#<CFELSE><FONT SIZE="2">#Contract_Status_Type_Desc#</FONT></CFIF>
		</TD>
		<cfset count = 0>
		<cfoutput>
			<cfset count = count + #Status_Count#>
		</cfoutput>
		<TD CLASS="UNDERLINED count" align="right">#numberFormat(Count, ",9")#</TD>
	</TR>
</CFOUTPUT>
</TABLE>

<cfoutput>
<div class="scorecardFooter">
	<div class="subtle">
		Last refreshed #DateFormat(Now(), "d mmm yyyy")# <cfif URL.useCache neq 1>#TimeFormat(scorecardTime, "h:mm tt")#</cfif>
	</div>
	<!--- Two buttons at bottom --->
	<cfif abs(Get_Profile_Settings.Cont_Prog_View_Create_Program) eq 1>
		<cfif(appSettings.getFlexProgramSearch() eq 1 OR appSettings.getFlexProgramSearch() eq 2 OR appSettings.getFlexProgramSearch() eq 3)>
				<cfset on_click = "return showSCFx('Expired');">
		<cfelseif(appSettings.getFlexProgramSearch() eq 4 OR appSettings.getFlexProgramSearch() eq 5)>
				<cfset on_click = "return showSCAGGrid(7,'Expired');">
		<cfelse>
				<cfset on_click = "return showSC(7);">
		</cfif>
			<a href="##" onclick="#on_click#" style="font-style:normal;margin-right:30px;">#application.util.string.linkFormat("view expired")#</a>
			<a href="##" onclick="return refreshView();" style="font-style:normal;">#application.util.string.linkFormat("refresh view")#</a>
	<cfelse>
		<b>Expired</b>
	</cfif>
</div>
</cfoutput>

<cf_include files="/styles/css-loader.css">
<cfinclude template="/Common_Files/jQuery.cfm">
<div class="customContainer" style="display:none;"></div>

<script>
	function refreshView() {
			window.location.href = "index.cfm?useCache=0";
			return false;
		}

	function showSCAGGrid(statusID,statusDesc) {
			/* These "statusID" are being used for the new (AG Grid) program search. */
			if(statusDesc == "Agreed"){
				statusID = 101;
			}
			else if(statusDesc == "Pending Approval"){
				statusID = 102;
			}
			else if(statusDesc == "Under Review"){
				statusID = 103;
			}
			else if(statusDesc == "Approved"){
				statusID = 104;
			}
			else if(statusDesc == "Pending ERP Research"){
				statusID = 105;
			}
			else if(statusDesc == "Pending ERP Entry"){
				statusID = 106;
			}
			else{
				statusID = statusID;
			}

			show_loader( "LOADING... PLEASE WAIT...");
			finalURL = "/programs/program_search.cfm?scorecard_status="+statusID
			window.parent.location.href=finalURL;
			return false;
		}	
	function showSCFx(ContractStatusTypeDesc) {
			finalURL = "/flex/search/ProgramSearchFx.cfm?status="+ContractStatusTypeDesc
			//finalURL = "/flexdev/Programsearch/bin-debug/ProgramSearchFx.cfm?status="+ContractStatusTypeDesc
			window.parent.location.href=finalURL;
			return false;
		}
 	function showSC(Section, agreementStatsId) {
			if(!agreementStatsId)
			{
				agreementStatsId = "0";
			}
			showExpired = false;
			
			if(Section == 7) {
				showExpired = true;
			}
			var guid1 = "<cfoutput>#createuuid()#</cfoutput>";
			finalURL = "/scorecard/scorecard1.cfm?a=" + guid1 + "&SECTION_TO_OPEN=" + Section + "&AGREE_ID=" + agreementStatsId + "&SHEXP=" + showExpired
			window.parent.location.href=finalURL;
			return false;
		}
	
</script>
</body>
</html>