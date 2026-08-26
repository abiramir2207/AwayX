<!---
File: BB_Reason_Code_Selection.cfm
Created by: Deepa Kunnath
Created on: 09/16/2010
Label for creation: D24781 - BB reason codes
Lowest build available: 6.1

Varibaled expected:
Billback_ID
appSettings.Reason_Code_in_Billback_Display_Setting
reasonCodePerRow

Purpose: This file can be included in other files to enable users to select pick billback reason code 
Currently included in:
/billbacks/APPROVAL/payment.cfm
/GL_Code/Gl_Code_In_Billback/Payment_Request/VendorID_Selection.cfm
--->
<cfsilent>
<cfparam name="Form.DD_Reason_Code_ID" default="">
<CFQUERY NAME="Get_ReasonCode" DATASOURCE="#Application.Datasource#">
	SELECT 		DD_Reason_Code_ID, DD_Reason_Code_Description, DD_Reason_Code, Display_In, Is_BB_Default,
				CASE WHEN BB_Reason_Code_Selection.BB_Reason_Code_ID IS NULL THEN 0 ELSE 1 END as Is_Selected
	FROM 		DD_Reason_Code
	LEFT JOIN 	BB_Reason_Code_Selection
	ON			BB_Reason_Code_Selection.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR" />
	AND			BB_Reason_Code_Selection.BB_Reason_Code_ID = DD_Reason_Code.DD_Reason_Code_ID
	WHERE 		Deleted = 0 AND Display_In IN (2,3)
	ORDER BY	DD_Reason_Code_Description
</CFQUERY>

<cfset useLakebaseForGetReasonCodeSelected = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_reasoncode")>
<cfif useLakebaseForGetReasonCodeSelected>
	<cftry>
		<cfset GetReasonCodeSelected = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_reasoncode", {
				"is_selected" = "eq.1",
				"select" = "dd_reason_code_id"
			}), "dd_reason_code_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetReasonCodeSelected = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetReasonCodeSelected>
<CFQUERY NAME="GetReasonCodeSelected" dbtype="query">
	SELECT 		DD_Reason_Code_ID
	FROM 		Get_ReasonCode
	WHERE 		Is_Selected = 1	
</CFQUERY>
</cfif>
</cfsilent>

<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script language="javascript">
function isReasonCodeSelected()
{
	<cfif appSettings.getBBReasonCodeAllowMultiple() EQ 1>
	// checkbox
	if (document.all.DD_Reason_Code_ID)
	return Any_Object_Checked(document.all.DD_Reason_Code_ID);
	else
	return false;
	<cfelse>
	// select
	if (document.all.DD_Reason_Code_ID.value == 'INVALID')
	{
		return false;
	}
	else
	{
		return true;
	}
	</cfif>	
}
</script>
<cfoutput>
<span id="error_DD_Reason_Code_ID"></span><strong>Select the reason code for approving this billback:</strong><br />
<cfif appSettings.getBBReasonCodeAllowMultiple() EQ 1>
	<!--- select multiple reason code --->
	<cfset divheight = 21 />
	<div class="styleDivReasoncode">
	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
	<CFLOOP QUERY="Get_ReasonCode">
		<cfset sChecked = "" />
		<!--- If there is something already saved, show that as selected by default --->
		<cfif GetReasonCodeSelected.recordCount>
			<cfif Get_ReasonCode.Is_Selected EQ 1>
				<cfset sChecked = " checked " />
			</cfif>
		<!--- If user just selected some thing it will be in form variable --->
		<cfelseif Form.DD_Reason_Code_ID neq "">
			<cfif ListFind(Form.DD_Reason_Code_ID, Get_ReasonCode.DD_Reason_Code_ID)>
				<cfset sChecked = " checked " />
			</cfif>
		<!--- If none of the above, show the default one as selected --->
		<cfelseif Get_ReasonCode.Is_BB_Default EQ 1>
			<cfset sChecked = " checked " />
		</cfif>
		<td width="33.33%"><input type="checkbox" name="DD_Reason_Code_ID" value="#Get_ReasonCode.DD_Reason_Code_ID#" #sChecked#> #trim(Get_ReasonCode.DD_Reason_Code_Description)# (#trim(Get_ReasonCode.DD_Reason_Code)#)</td>
		<cfif currentRow mod reasonCodePerRow eq 0 and currentRow neq recordCount></tr><tr>
			<cfif divheight lt 100><cfset divheight = divheight + 21 /></cfif>
		</cfif>
	</cfloop>
	</tr>
	</table>
	</div>
	<style>
		.styleDivReasoncode
		{
			height:#divheight#px;
			overflow:auto;
		}
	</style>
<cfelse>
	<!--- select single reason code --->
	<SELECT NAME="DD_Reason_Code_ID">
		<OPTION VALUE="INVALID" SELECTED>** Select a Reason code</OPTION>
			<CFLOOP QUERY="Get_ReasonCode">
			<cfset sChecked = "" />
			<cfif GetReasonCodeSelected.recordCount>
				<cfif Get_ReasonCode.Is_Selected EQ 1>
					<cfset sChecked = " selected " />
				</cfif>
			<cfelseif Get_ReasonCode.Is_BB_Default EQ 1>
				<cfset sChecked = " selected " />
			</cfif>
			<OPTION VALUE="#Get_ReasonCode.DD_Reason_Code_ID#" #sChecked#>
				#trim(Get_ReasonCode.DD_Reason_Code_Description)# (#trim(Get_ReasonCode.DD_Reason_Code)#)
			</OPTION>
		</cfloop>
	</SELECT>
</cfif>
</cfoutput>

