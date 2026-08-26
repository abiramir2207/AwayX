<!---
	Name:          	volume_dont_count.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	03/12/2015
	Created By:    	Tim Ford
	Description:   	Page to select which components volume shoult not be counted in Billbacks
	Usage:
--->
<html>
<title>Ignore Volume Component Selection</title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
p { font-size:13px; color:green; font-weight:bold; }
</style>
<body>
<script>

function submitForm()
{
	document.selectdontcount.saveData.value = 1;
	document.selectdontcount.submit();
}
</script>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>

<cfparam name="url.programId" 	default="0" />
<cfparam name="form.programId"	default="#url.programId#" />
<cfparam name="form.saveData" 	default="0" />
<cfparam name="form.Program_Fixed_Component_ID" 	default="0" />
<cfparam name="form.Program_Rebates_Component_ID" 	default="0" />

<cfif form.saveData eq 1>
<cfoutput>

	<!--- First reset Dont_Count_Volume flags --->
	<cfquery name="qRestDontCount" datasource="#application.datasource#">
		UPDATE	Program_Fixed_Component
		SET		Dont_Count_Volume = 0
		WHERE	Program_ID = '#form.programId#'
		AND		Deleted = 0

		UPDATE	Program_Rebates_Component
		SET		Dont_Count_Volume = 0
		WHERE	Program_ID = '#form.programId#'
		AND		Deleted = 0
	</cfquery>

	<!--- Set Fixed Dont_Count_Volume if selected --->
	<cfif form.Program_Fixed_Component_ID neq 0>
		<cfloop index="fIdx" list="#form.Program_Fixed_Component_ID#">
			<cfset useLakebaseForqSetFixedDontCount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component")>
<cfif useLakebaseForqSetFixedDontCount>
	<cftry>
		<cfset application.oLakebase.updateRows("program_fixed_component",
			{
				"program_fixed_component_id" = "eq.#fIdx#"
			},
			{
				"dont_count_volume" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSetFixedDontCount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSetFixedDontCount>
<cfquery name="qSetFixedDontCount" datasource="#application.datasource#">
				UPDATE	Program_Fixed_Component
				SET		Dont_Count_Volume = 1
				WHERE	Program_Fixed_Component_ID = '#fIdx#'
			</cfquery>
</cfif>
		</cfloop>
	</cfif>

	<!--- Set Rebate Dont_Count_Volume if selected --->
	<cfif form.Program_Rebates_Component_ID neq 0>
		<cfloop index="rIdx" list="#form.Program_Rebates_Component_ID#">
			<cfset useLakebaseForqSetRebateDontCount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component")>
<cfif useLakebaseForqSetRebateDontCount>
	<cftry>
		<cfset application.oLakebase.updateRows("program_rebates_component",
			{
				"program_rebates_component_id" = "eq.#rIdx#"
			},
			{
				"dont_count_volume" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSetRebateDontCount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSetRebateDontCount>
<cfquery name="qSetRebateDontCount" datasource="#application.datasource#">
				UPDATE	Program_Rebates_Component
				SET		Dont_Count_Volume = 1
				WHERE	Program_Rebates_Component_ID = '#rIdx#'
			</cfquery>
</cfif>
		</cfloop>
	</cfif>

	<script>
		window.close();
	</script>

</cfoutput>
</cfif>

<cfquery name="qGetFixedComponentData" datasource="#application.datasource#">

	SELECT	(SELECT Discount_Type_Desc FROM Discount_Type WHERE Discount_Type_ID = 1) AS Discount_Type,
			pfcn.Program_Fixed_Component_Name AS Comp_Name,
			CASE WHEN pfc.Fixed_Component_Paid_to = 1 THEN 'Distributor' ELSE 'Operator' END AS Pays_To,
			pfc.Program_Fixed_Component_ID,
			1 as Discount_Type_ID,
			Dont_Count_Volume
	FROM	Program_Fixed_Component pfc
			INNER JOIN Program_Fixed_Component_Name pfcn ON pfcn.Program_Fixed_Component_Name_ID = pfc.Program_Fixed_Component_Name_ID
	WHERE	Program_ID = '#form.programId#' and pfc.Deleted = 0

	ORDER BY Pays_To

</cfquery>

<cfquery name="qGetRebateComponentData" datasource="#application.datasource#">

	SELECT	(select Discount_Type_Desc FROM Discount_Type WHERE Discount_Type_ID = 2) AS Discount_Type,
			prcn.Program_Rebates_Component_Name AS Comp_Name,
			CASE WHEN prc.Component_Paid_To = 1 THEN 'Distributor' ELSE 'Operator' END AS Pays_To,
			prc.Program_Rebates_Component_ID,
			2 as Discount_Type_ID,
			Dont_Count_Volume
	FROM	Program_Rebates_Component prc
			INNER JOIN Program_Rebates_Component_Name prcn on prcn.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID
	WHERE	prc.Program_ID = '#form.programId#' and prc.Deleted = 0

	ORDER BY Pays_To

</cfquery>

<cfquery name="qProgram" datasource="#application.datasource#">
	SELECT	Contract_Status_Type_IDX, Contract_Is_Locked
	FROM	Contract_Main
	WHERE	Contract_Main_ID = <cfqueryparam value="#form.programId#">
</cfquery>

<cfset view_only = ( qProgram.Contract_Status_Type_IDX neq 1 OR qProgram.Contract_Is_Locked EQ 0 )>

<form action="volume_dont_count.cfm" METHOD="post" NAME="selectdontcount">
<cfif view_only>
	<p>Program needs to be revised (in WIP status) to make changes.</p>
</cfif>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="50%" CLASS="datagrid" id="compList">
	<thead>
	<tr>
		<th>Discount Type</th>
		<th>Component Name</th>
		<th>Pays To</th>
		<th>Ignore Volume</th>
	</tr>
	</thead>
	<tbody>
		<cfoutput query="qGetFixedComponentData">
		<TR>
			<td>#Discount_Type#</td>
			<td>#Comp_Name#</td>
			<td>#Pays_To#</td>
			<td><input name="Program_Fixed_Component_ID" type="checkbox" <cfif view_only>disabled="disabled"</cfif> value="#Program_Fixed_Component_ID#" <cfif qGetFixedComponentData.Dont_Count_Volume>checked</cfif>></td>
		</TR>
		</cfoutput>
		<cfoutput query="qGetRebateComponentData">
		<TR>
			<td>#Discount_Type#</td>
			<td>#Comp_Name#</td>
			<td>#Pays_To#</td>
			<td><input name="Program_Rebates_Component_ID" type="checkbox" <cfif view_only>disabled="disabled"</cfif> value="#Program_Rebates_Component_ID#" <cfif qGetRebateComponentData.Dont_Count_Volume>checked</cfif>></td>
		</TR>
		</cfoutput>
	</tbody>
</table>
<cfoutput>
<input name="saveData"						type="hidden"	value="0" />
<input name="programId" 					type="hidden"	value="#form.programId#" />
<input name="lProgramFixedComponentIDs" 	type="hidden"	value="#ValueList(qGetFixedComponentData.Program_Fixed_Component_ID)#" />
<input name="lProgramRebatesComponentIDs" 	type="hidden"	value="#ValueList(qGetRebateComponentData.Program_Rebates_Component_ID)#" />
</form>
<br>
<table align="center" cellpadding="10">
	<tr>
		<cfif not view_only>
			<td>
				<a href="##" onclick="submitForm()">#application.util.string.actionLinkFormat2("save")#</a>
			</td>
		</cfif>
		<td>
			<a href="##" onclick="window.close()">#application.util.string.actionLinkFormat2("close")#</a>
		</td>
	</tr>
</table>
</cfoutput>
</body>
</html>