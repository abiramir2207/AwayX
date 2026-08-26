<!------ update_entry_status_save.cfm ----->
<cfset searchInputToken_1 = "TXT_REF_NUMBER_">
<cfset searchInputToken_2 = "CHK_UPDATE_STATUS_">

<cfset LenInputToken_1 = len(searchInputToken_1)>
<cfset LenInputToken_2 = len(searchInputToken_2)>

<cfscript>
function displayChange(sStr, iCount, color_code)
{
if(iCount GT 0)
{
	WriteOutput("<br>");
}
WriteOutput("<span class=sp_" & color_code & ">" & sStr & "</span>");
return (iCount  + 1);
}
</cfscript>
<cfset ColorBackground = "FFCE84">
<cfset EntryStatusDesc = ProgramPostApprovalStatusManager.getProgramPostApprovalStatusDesc(2) />
<cfset changeDate = DateFormat(Now(), "mm/dd/yyyy") />
<cfset changedUser = request.AccessStructure.Name_First & " " & request.AccessStructure.Name_Last />
<cfset changedByMessage = "<br>by #changedUser# on #changeDate#" />
<cfloop collection = #Form# item = "FieldNames">
	<cfset FieldName = FieldNames> 

	<cfset Current_Program_ID = 0>
	<cfset Program_Ref_Number = "" />
	<cfset Update_Status = 0 />
	<cfset Update_Proram_Ref_Number = 0 />
	
	<cfif left(FieldName, LenInputToken_1) IS searchInputToken_1>
		<cfset Current_Program_ID = ListLast(FieldName, "_")>
		<cfset Program_Ref_Number = Evaluate("Form.#FieldName#") />
		<cfset Update_Proram_Ref_Number = 1 />
		<cfset Update_Status = 1 />
	</cfif>
	
	<cfif left(FieldName, LenInputToken_2) IS searchInputToken_2>
		<cfset Current_Program_ID = ListLast(FieldName, "_")>
		<cfset Update_Status = 1 />
	</cfif>
	
	<cfif (Update_Proram_Ref_Number EQ 1 OR Update_Status EQ 1) AND IsNumeric(Current_Program_ID)>
		<cfquery name="qGetProgramIfo" datasource="#application.datasource#">
			SELECT	Contract_Reference_Number, Contract_Number
			FROM	Contract_Main
			WHERE	Contract_Main_ID = <cfqueryparam value="#Current_Program_ID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfquery name="qUpdateStatusAndReferenceNumber" datasource="#application.datasource#">
			UPDATE	Contract_Main
			SET		Program_Post_Approval_Status_ID = NULL
			<cfif Update_Proram_Ref_Number EQ 1>
					,Contract_Reference_Number = <cfqueryparam value="#Program_Ref_Number#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			WHERE	Contract_Main_ID = <cfqueryparam value="#Current_Program_ID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif Update_Status EQ 1>
			<cfset ProgramPostApprovalStatusManager.setCompleteProgramPostApprovalStatusHistory(
						programId = Current_Program_ID,
						postApprovalStatusId = 2,
						userId = request.AccessStructure.user_id) />
		</cfif>
		
		<!------ Update program History Info ----->
		<cfoutput>
		<cfsavecontent variable="historyInfo">
		<style>
		.sp_2
		{
			color:green;
		}
		</style>
		<TABLE cellpadding="3" align="center" cellspacing="0" width="80%" border="0" class="ChangeLog">
		<TR>
			<TD  class="heading" style="background-color:#ColorBackground#">WHAT</TD>
			<TD  class="heading" style="background-color:#ColorBackground#">FROM</TD>
			<TD  class="heading" style="background-color:#ColorBackground#">TO</TD>
			<TD  class="heading" style="background-color:#ColorBackground#">ACTION</TD>
		</TR>
	
		<!------ Show Program Title ----->
		<cfif Update_Proram_Ref_Number EQ 1>
		<TR valign="top">
			<TD width="40%"><B>#application.returned_customer_setting.reference_number_label#</B></TD>
			<TD width="20%">#qGetProgramIfo.Contract_Reference_Number#&nbsp;</TD>
			<TD width="20%">#Program_Ref_Number##changedByMessage#&nbsp;</TD>
			<TD width="20%">
			<cfset iCount = displayChange("Changed", 0, 2) />
			&nbsp;</TD>
		</TR>
		</cfif>
		<cfif Update_Status EQ 1>
		<TR valign="top">
			<TD width="40%"><B>#EntryStatusDesc#</B></TD>
			<TD width="20%">Not complete&nbsp;</TD>
			<TD width="20%">Complete#changedByMessage#&nbsp;</TD>
			<TD width="20%">
			<cfset iCount = displayChange("Changed", 0, 2) />
			&nbsp;</TD>
		</TR>
		</cfif>
		</TABLE>
		</cfsavecontent>
		</cfoutput>
		
		<cfquery name="qGetCurrentHistoryString" datasource="#application.datasource#">
			SELECT	Contract_Details
			FROM	Program_History
			WHERE	Deleted = 0
			AND		Contract_Main_ID = <cfqueryparam value="#Current_Program_ID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif qGetCurrentHistoryString.recordCount>
			<cfquery name="qUpdateHistoryString" datasource="#application.datasource#">
				UPDATE	Program_History
				SET		Contract_Details = '#qGetCurrentHistoryString.Contract_Details#<br>#historyInfo#'
				WHERE	Deleted = 0
				AND		Contract_Main_ID = <cfqueryparam value="#Current_Program_ID#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		<cfelse>
			<cfquery name="qInsertHistoryString" datasource="#application.datasource#">
				INSERT INTO Program_History(Contract_Main_ID,Contract_Number,Contract_Details)
				VALUES(<cfqueryparam value="#Current_Program_ID#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#qGetProgramIfo.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">,
					'#historyInfo#')
			</cfquery>
		</cfif>
	</cfif>
	
</cfloop>
<cflocation addtoken="No" url="#sCurrentPage#?complete=save" />