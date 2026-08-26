<cfparam name="url.EZTemplate" default="0">
<!---Revision restrictions --->
<cfset GrowthChangeTarget = 1>

<!---For a revision, should show edit component information links or not? --->
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Growth_Change_Target eq 2>
	<cfset GrowthChangeTarget = 2>
</cfif>  

<br>
<table border="0" cellpadding="0" cellspacing="2">
<Tr>
	<!---Component page--->
	<cfif Component_Type IS 1 AND GrowthChangeTarget IS NOT 2>
		<td nowrap>
		<CF_smallLink 
		title = "component information" 
		url = "/common_files/contracts/Contract_Discount_Growth_Add_Component.cfm?Program_ID=#Program_ID#&Component_ID=#Component_ID#&CID=#CID#&Action=Edit&Component_Type=#Component_Type#&Growth_Component_Name_ID=#Growth_Component_Name_ID#&EZTemplate=#url.EZTemplate#"
		parameters = ""
		>&nbsp; &nbsp; 
		</td>
	
	<!---See if the program has a seperate volume tier--->
	<cfset useLakebaseForDoesItHaveSeperateVolume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
	<cfif useLakebaseForDoesItHaveSeperateVolume>
		<cftry>
			<cfset DoesItHaveSeperateVolume = application.oLakebase.toQuery(
				application.oLakebase.selectRows("program_growth_components", { "parent_id" = "eq.#Component_ID#", "select" = "program_growth_component_id" })
			)>
			<cfcatch type="any">
				<cfset useLakebaseForDoesItHaveSeperateVolume = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDoesItHaveSeperateVolume>
		<cfquery name="DoesItHaveSeperateVolume" datasource="#application.datasource#">
		SELECT Program_Growth_Component_ID FROM Program_Growth_Components WHERE Parent_ID = '#Component_ID#'
		</cfquery>
	</cfif>

	<cfif DoesItHaveSeperateVolume.Recordcount LT 1>
		<cfset SeperateVolumePool = 0>
	<cfelse>
		<cfset SeperateVolumePool = 1>
	</cfif>
		
	<!---Add volume pool page--->
	<cfif CGI.SCRIPT_NAME IS NOT "/Common_Files/contracts/Contract_Discount_Growth_Add_Volume_Items.cfm">
	<cfif SeperateVolumePool IS 1  AND GrowthChangeTarget IS NOT 2>
	<td nowrap>
	<CF_smallLink 
		title = "volume items" 
		url = "/common_files/contracts/Contract_Discount_Growth_Add_Volume_Items.cfm?CompID=#Component_ID#&Program_ID=#Program_ID#&CID=#CID#&Action=Edit&EZTemplate=#url.EZTemplate#"
		parameters = ""
		>	&nbsp; &nbsp;
		</td> 
	</cfif>	
	</cfif>
	
	</cfif>
	
	<!--- Now, we use normal growth components only. That is why I commented this. --->
	<!---Add target page--->
		<!---<cfif CGI.SCRIPT_NAME IS NOT "/Common_Files/contracts/Contract_Discount_Growth_Add_Target.cfm">
	<cfif Component_Type GT 1  AND GrowthChangeTarget IS NOT 2>
		<td nowrap>
		<CF_smallLink 
		title = "add target" 
		url = "/common_files/contracts/Contract_Discount_Growth_Add_Target.cfm?Program_ID=#Program_ID#&Component_ID=#Component_ID#&CID=#CID#&Component_Type=#Component_Type#&Rate_Type=#Rate_Type#&EZTemplate=#url.EZTemplate#"
		parameters = ""
		>&nbsp; &nbsp; 
		</td>
	</cfif>
	</cfif>
	--->
	<td nowrap>
	<CF_smallLink 
		title = "main growth page" 
		url = "/common_files/contracts/Contract_Discount_Growth.cfm?cid=#CID#&EZTemplate=#url.EZTemplate#"
		parameters = ""
		>&nbsp; &nbsp; 
	</td>
</TR>
</table>
<br>