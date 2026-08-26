<!---
	Copyright (c)2022 Blacksmith Applications, Inc.
	Filename:		AwayX\Common_files\Contract\Auto_Add_Distributors.cfm
	Created:		10/13/2022
	Developer:		Dinesh Rachala
	Description:	
--->
<cfset PAGETITLE = "Auto Add Distributors">
<cfinclude template="/settings/settings_title.cfm">
<cfparam  name="form.Update_distributors" default="1">
<cfparam  name="form.save" default="0">

	<cfquery name="getCurrentValue" datasource="#application.datasource#">
		SELECT AutoAdd_Distributor_ThirdPartyClaims
		FROM Contract_Main_Aux_Data
		WHERE Contract_Main_ID = #url.Contract_main_id#
	</cfquery>
<cfif form.save AND (getCurrentValue.AutoAdd_Distributor_ThirdPartyClaims NEQ form.Update_distributors)>
	<cfquery name="" datasource="#application.datasource#">
		UPDATE Contract_Main_Aux_Data
		SET AutoAdd_Distributor_ThirdPartyClaims = #form.Update_distributors#
		WHERE Contract_Main_ID = #url.Contract_main_id#

		INSERT INTO Program_AutoAdd_Distributor_History (Contract_Main_ID, Contract_Number, Previous_Value, New_Value, Updated_By)
		VALUES(#url.Contract_main_id#, '#url.Contract_number#', #getCurrentValue.AutoAdd_Distributor_ThirdPartyClaims#, #form.Update_distributors#, '#request.AccessStructure.User_ID#')
	</cfquery>

</cfif>
<br>
<form name="AutoAddDistributor" action="Auto_Add_Distributors.cfm?<cfoutput>Status=#url.Status#&Contract_main_id=#url.Contract_main_id#&Contract_number=#url.Contract_number#</cfoutput>" method="post" id="AutoAddDistributor">
	Update distributors on program based on 3rd party billbacks                     
	<select name="Update_distributors">
		<option value="1" <cfif getCurrentValue.AutoAdd_Distributor_ThirdPartyClaims>selected</cfif>>Yes</option>
		<option value="0" <cfif ! getCurrentValue.AutoAdd_Distributor_ThirdPartyClaims>selected</cfif>>No</option>
	</select>
	<input type="hidden" name="save" value="1">
	<a id="save" href="#" onclick="frmSubmit();"><cfoutput>#application.util.string.actionLinkFormat("Save")#</cfoutput></a>
</form>

<cfquery name="getHistory" datasource="#application.datasource#">
	SELECT revision_version, DistHistory.Contract_Number, 
	CASE WHEN DistHistory.Previous_Value = 0 THEN 'No' ELSE 'Yes' END AS Previous_Value, 
	CASE WHEN DistHistory.New_Value = 0 THEN 'No' ELSE 'Yes' END AS New_Value, 
	U.Name_First+' '+U.Name_Last AS UpdatedBy, DistHistory.Updated_Date
	FROM Program_AutoAdd_Distributor_History DistHistory 
	INNER JOIN contract_main CM
	ON CM.Contract_Main_ID = DistHistory.contract_main_ID
	INNER JOIN _Users U
	ON U.User_ID = DistHistory.Updated_By
	WHERE DistHistory.Contract_Number = '#url.Contract_number#'
	ORDER BY DistHistory.Updated_Date desc
</cfquery>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.datagrid TBODY TR.even { BACKGROUND-COLOR: #eeffee }
</style>

<p style="font-size:14px; font-weight:bold; font-family:Century Gothic,Verdana,Arial;">History</p>
<table class="datagrid" >
	<thead>
	<tr>
		<th>Program #</th>
		<th>Version</th>
		<th>Previous Value</th>
		<th>Current Value</th>
		<th>Updated By</th>
		<th>Updated Date</th>
	</tr>
</thead>
<cfif getHistory.recordcount>
	<cfoutput query="getHistory">
		<tr>
			<td>#Contract_Number#</td>
			<td>#revision_version#</td>
			<td>#Previous_Value#</td>
			<td>#New_Value#</td>
			<td>#UpdatedBy#</td>
			<td>#dateformat(Updated_Date, 'm/d/yyy')# #timeformat(Updated_Date, 'h:mm:ss TT')#</td>
		</tr>
	</cfoutput>
	<cfelse>
		<tr>
			<td colspan="6" align="center"> No Data</td>
		</tr>
	</cfif> 
</table>

<script type="text/javascript">
	function frmSubmit(){
		document.getElementById("AutoAddDistributor").submit();
	}
</script>