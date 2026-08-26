<!---
Author: Ben Densmore
masseditstatus.cfm:

Created Date: Mar 21, 2007

Loops through checked Programs and
updates the proposal status. Inserts
User, Action and notes into Business
Considerations.
--->


<!---initialize the BidRequestManager--->
<cfparam name="FromFlex" default="0" />
<cfparam name="FromAGGrid" default="0" />
<cfset variables.bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />
<cfset variables.user = request.AccessStructure.Name_First & " " & request.AccessStructure.Name_Last />
<cfset variables.action = "Mass Edit Status" />
<cfset variables.notes = "Updated Proposal Status" />
<cfset program = CreateObject("component", "components.programs.program") />
<cfset anyFailures = 0 />
<cfset showMsg = "" />

<cfoutput>
<cfloop list="#form.massEditStatusList#" index="i" delimiters=",">
	<cfset programId = Find('_',i) />

	<cfset currentProgramId = Left(i,programId - 1) />
	<cfset statusId = Right(i,1) />

	<!------ lock the program ----->
	<cfset lockReturnValue = program.setLockStatus(currentProgramId, 1, request.AccessStructure.User_ID) />
	<cfif lockReturnValue EQ 1>

	   	<!---apply status for bid request--->
	   	<cfset variables.bidRequestManager.applyStatus(currentProgramId, statusId) />

		<!--- Get Contract ID --->
		<cfquery name="GetContractNumber" datasource="#application.datasource#">
			select contract_number,Is_A_Revision
			from contract_main
			where contract_main_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#Left(i,programId - 1)#">
		</cfquery>


		<!--- Add Business Considerations --->
		<cfquery name="postEvaluationNotes" datasource="#application.datasource#">
			insert into contract_evaluation_notes
			(Entered_By, Eval_Action, Notes, Contract_Number, Contract_Notes_Type)
			VALUES(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.user#" />,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.action#" />,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#REReplaceNoCase(trim(variables.notes),'\r','<br>','ALL')#" />,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#GetContractNumber.Contract_Number#" />,
			<cfqueryparam cfsqltype="cf_sql_integer" value="2" />
			)
		</cfquery>

		<!------ unlock program ----->
		<cfset program.setLockStatus(currentProgramId, 0)>

	<cfelseif lockReturnValue EQ 2>

		<cfset showMsg = "#showMsg#<br>Program not found" />
		<cfset anyFailures = 1 />

	<cfelseif lockReturnValue EQ 3>

		<cfset qProgram = program.getProgramInfo(currentProgramId) />
		<cfset programDesc = "[#qProgram.Contract_Number#] #qProgram.Contract_Title#" />
		<cfset showMsg = "#showMsg#<br>Program #programDesc# is locked by someone else and cannot be modified" />
		<cfset anyFailures = 1 />

	</cfif>

 </cfloop>
<script>

function goBackToScorecard()
{
	if (window.parent.showSearchResult)
	{
		window.parent.showSearchResult(false, 1);
	}
	else
	{
		parent.frames[1].location.href = 'scorecard1.cfm?SECTION_TO_OPEN=10&AGREE_ID=0';
	}
}
<cfif anyFailures EQ 0 AND FromFlex EQ 0 AND FromAGGrid EQ 0>
	goBackToScorecard();
</cfif>
</script>

<cfif anyFailures>

	<div align="center" style="font-weight:bold;font-size:14px;color:red">#showMsg#</div>

<cfif FromFlex EQ 0 AND FromAGGrid EQ 0>
	<br><br>
	<div align="center">
	<CF_smallLink
		title = "go back to program search/scorecard"
		url = "##"
		parameters = "onClick=""JavaScript: goBackToScorecard();return false;"""
	>
	</div>
</cfif>
</cfif>

<br />

<cfif FromFlex EQ 1>
<script>
	window.opener.location.href = '/flex/search/ProgramSearchFx.cfm?Reload=1';
	window.close();
</script>
</cfif>

<cfif FromAGGrid EQ 1>
<script>
	window.opener.location.href = '/programs/program_search.cfm?refresh_data=1';
	window.close();
</script>
</cfif>

 <!--- cflocation url="scorecard1.cfm?SECTION_TO_OPEN=10&title=Scorecard" addtoken="no" / --->
</cfoutput>