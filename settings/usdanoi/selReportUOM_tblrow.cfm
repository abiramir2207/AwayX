<script>
	function verificationReportUOMHandler(oSelect) {
		oOption = oSelect.options[oSelect.selectedIndex];
		if(oOption.id) {
			if(oOption.id == "verification-report")	{
				document.all.selReportUOM.selectedIndex = 0;
				document.all.selReportBBDetail.selectedIndex = 1;
			}
		}
	}
	function ShowHistory()
	{
	var contractid = document.all.showhistory.options[document.all.showhistory.selectedIndex].value;
	NewWindow('/common_files/contracts/view_contract_history.cfm?ProgramId='+contractid,'ContractHistory','800','600','Yes', 'No');
	}
</script>
<cfparam name="IAgreeOperator" default="0">

<cfquery name="getCurrentSettings" datasource="#application.datasource#">
	SELECT USDANOI_I_Agree_Enabled
	FROM general_Settings
</cfquery>

<cfoutput>
<cfif isDefined("AllOperators")>
	<cfset AllOpCount =  listlen(AllOperators)>
<cfelse>
	<cfset AllOpCount =  0>
</cfif>

<tr id="dropdown_row">
<td colspan="100%" align="left" bgcolor="##FFFFFF">
<table width="100%" align"left" cellspacing="3" cellpadding="3">
<tr>
<cfif getCurrentSettings.USDANOI_I_Agree_Enabled EQ 1 AND (url.operator IS NOT 0 OR url.operatorid IS NOT 0 OR AllOpCount IS 1)>

<cfif AllOpCount IS 1>
	<cfset IAgreeOperator = AllOperators>
</cfif>
<cfif url.operator IS NOT 0 AND url.operatorid IS 0>
	<cfset IAgreeOperator = url.operator>
</cfif>
<cfif url.operatorid IS NOT 0>
	<cfset IAgreeOperator = url.operatorid>
</cfif>
		
		<!--- <td valign="top" align="left" style="cursor: help;" title="I&nbsp;<cfif getLatestAgreement.user_agrees EQ 1>AGREE<cfelse>DO NOT AGREE</cfif>:&nbsp;&nbsp;#HTMLEditFormat(getLatestAgreement.notes)#">
			<input type="checkbox" name="I_Agree_ChkBx" value="1" style="cursor: default;" onClick="showAgreementForm()"> <span style="font-size: 12px; font-weight: bold;">Click here to respond to this report<cfif getLatestAgreement.recordcount NEQ 0><br>Last Responded to on #DateFormat(getLatestAgreement.DateTimeStamp, 'm/d/yyyy')# <!--- - #TimeFormat(getLatestAgreement.DateTimeStamp, 'hh:mm:ss')# --->by #getLatestAgreement.Name_First# #getLatestAgreement.Name_Last#</cfif></span>
		</td> --->
		</cfif>
</tr>
	<tr>
	<cfquery name="getdistinctoperatorprograms" dbtype="query">
	select max(program_id) as program_id, operator_name
	from TheQuery 
	group by operator_name
	</cfquery>
	<td><span style="font-size: 11px; font-weight: bold;">Operators:</span><br><select name="showhistory">
	<cfif getdistinctoperatorprograms.Recordcount GT 0>
	<cfloop query="getdistinctoperatorprograms">
	<option value="#program_id#">#operator_name#</option>
	</cfloop>
	</cfif>
	</td>
	<td align="left"><br><CF_button
						button_name		=	""
						button_caption	=	"Show History"
						button_action	=	"javascript:ShowHistory();"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Print"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
	></td>
		<td align="right">
			<table cellspacing="3" cellpadding="3">
				<tr>
					<td align="right" nowrap>
					<cfif TheQuery.Recordcount GT 0>
						<span style="font-size: 11px; font-weight: bold;">Report Type:</span><br>
						<select name="selReportType" onchange="changeReportUOM()">
						<option value="operator" <cfif lcase(url.ReportType) EQ "operator"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#</option>
						<option value="item" <cfif lcase(url.ReportType) EQ "item"> SELECTED</cfif>>Item</option>
						<option value="operator-item" <cfif lcase(url.ReportType) EQ "operator-item"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#-Item</option>
						<option value="operator-month-item" <cfif lcase(url.ReportType) EQ "operator-month-item"> SELECTED</cfif>>#application.returned_customer_setting.operator_label_singular#-Month-Item</option>
						<option value="summary" <cfif lcase(url.ReportType) EQ "summary"> SELECTED</cfif>>Summary</option>
						<option id="verification-report" value="verification" <cfif lcase(url.ReportType) EQ "verification"> SELECTED</cfif>>Verification Report</option>
						<option id="Available_item_report" value="Available_item_report" <cfif lcase(url.ReportType) EQ "Available_item_report"> SELECTED</cfif>>Available Items</option>
			<option id="export_to_excel" value="export_to_excel" <cfif lcase(url.ReportType) EQ "export_to_excel"> SELECTED</cfif>>Export To Excel</option>
						</select>		
						</cfif>&nbsp; 					
					</td>
					
					<td align="right" nowrap>
						<span style="font-size: 11px; font-weight: bold;">Report Unit Of Measure:</span><br>
						<select name="selReportUOM" onchange="changeReportUOM()">
						<option value="rm" <cfif url.ReportUOM EQ "rm"> SELECTED</cfif>>Raw Materials</option>
						<!--- <option value="1" <cfif url.ReportUOM EQ "1"> SELECTED</cfif>>Cases</option> --->
						<option value="2" <cfif url.ReportUOM EQ "2"> SELECTED</cfif>>Net Pounds</option>
						
						</select>
					</td>
					
					<td align="right" nowrap>
					<cfif TheQuery.Recordcount GT 0>
						<span style="font-size: 11px; font-weight: bold;">Show #application.returned_customer_setting.distributor_label_singular# Delivery Detail:</span><br>
						<select name="selReportBBDetail" onchange="changeReportUOM()">
						<option value="0" <cfif url.ReportBBDetail EQ "0"> SELECTED</cfif>>No</option>
						<option value="1" <cfif url.ReportBBDetail EQ "1"> SELECTED</cfif>>Yes</option>
						</select></cfif>
						<input type="Button" onclick="document.all.frmChangeReportUOM.submit()" value="run report">
					</td>
					
				</tr>
			</table>
		</td>
	</tr>
</table>
</td>
</tr>
</cfoutput>