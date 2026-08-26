<!------ update_entry_status_search_result_display.cfm ----->
<cfoutput>
<input type="Hidden" name="Program_Number_List" value="#Form.Program_Number_List#" />
<cfinclude template="/scorecard/program_status_tool_tip.cfm" />
<cfoutput>#programStatusToolTip#</cfoutput>
<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js">
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("popupInit();")
function initTheTooltip(ToolTipText)
{
	popUp(-1)
}
</SCRIPT>
<cfset qGetTemplateProgramPostApprovalStatus = ProgramPostApprovalStatusManager.getTemplateProgramPostApprovalStatus
			(templateId = 0,
			programPostApprovalStatusId = 1,
			bSelected = 1,
			ignoreTemplateId = 1) />

<cfset showSubmit = 0 />
<table class="MainTable" cellspacing="0" cellpadding="2" align="center">
	<tr BGCOLOR="FFCE84">
	<td id="header" width="50"><b>Status</b></td>
	<td id="header" width="100"><b>Search Token</b></td>
	<td id="header" width="100"><b>Program ##</b></td>
	<td id="header" width="100"><b>Program Type</b></td>
	<td id="header" width="400"><b>Title</b></td>
	<td id="header" width="200"><b>Update</b></td>
	</tr>
	<cfloop query="qDoSearch">	
	<tr <cfif Update_Type EQ 0>bgcolor="##dddddd"</cfif>>	
	<td><cfif IsNumeric(Contract_Status_Type_IDX)>#getProgramStatusImageString(Contract_Status_Type_IDX)#</cfif>&nbsp;</td>
	<td>#Search_Token#&nbsp;</td>
	<td>#Contract_Number#&nbsp;</td>
	<td>#Created_Type#&nbsp;</td>
	<cfif Update_Type EQ 0>
	<td style="color:red;font-weight:bold;">#Message#&nbsp;</td>
	<cfelse>	
	<td>#Contract_Title#&nbsp;</td>
	</cfif>
	<td>
	<cfif Update_Type NEQ 0>
	<cfset showSubmit = 1 />
	<cfset useLakebaseForqGetTemplatePostApprovalStatusType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgettemplateprogrampostapprovalstatus")>
<cfif useLakebaseForqGetTemplatePostApprovalStatusType>
	<cftry>
		<cfset qGetTemplatePostApprovalStatusType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgettemplateprogrampostapprovalstatus", {
				"template_id" = "eq.#ProgramType_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetTemplatePostApprovalStatusType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetTemplatePostApprovalStatusType>
<cfquery name="qGetTemplatePostApprovalStatusType" dbtype="query">
	SELECT	*
	FROM	qGetTemplateProgramPostApprovalStatus
	WHERE	Template_ID = #ProgramType_ID#
	</cfquery>
</cfif>
	<cfif qGetTemplatePostApprovalStatusType.recordCount><input type="Text" name="TXT_REF_NUMBER_#Program_ID#" value="#Contract_Reference_Number#" maxlength="200"><cfelse><input type="Checkbox" name="CHK_UPDATE_STATUS_#Program_ID#"></cfif>
	</cfif>&nbsp;
	</td>
	</tr>
	</cfloop>
	<tr>
	<td id="header" style="border:none" colspan="100%" align="center">
	&nbsp;<br>
		<cfif showSubmit EQ 1>
		<CF_smallLink 
			title = "submit" 
			url = "##"
			parameters = "onClick=""javascript: return submitForm('save');"""
		>
		</cfif>
		<CF_smallLink 
			title = "search again" 
			url = "##"
			parameters = "onClick=""javascript: return submitForm('search-form');"""
		>
	</td>
	</tr>
</table>
</cfoutput>