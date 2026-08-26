
<!--- build tree --->
<cfinclude template="/settings/Access_Rights/approval_tree/Approver_Tree_Build.cfm">
<h1>access tree rendered (/settings/Access_Rights/approval_tree/Approver_Tree_Build.cfm)</h1><BR>
<cfflush>

<!--- clear all temp files --->
<cfinclude template="/Common_Files/Contracts/Delete_Temp_Files/Delete_Temp_Files.cfm">
<h1>temp files removed (/Common_Files/Contracts/Delete_Temp_Files/Delete_Temp_Files.cfm)</h1><BR>
<cfflush>

<!--- build settings file --->
<cfinclude template="/settings/CUSTOMER_SETTINGS/Memory_Data/Render_Files.cfm">
<h1>settings file rendered (/settings/CUSTOMER_SETTINGS/Memory_Data/Render_Files.cfm)</h1><BR>
<cfflush>


<cfset useLakebaseForclear_contract_renewal_packets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_renewal_packets")>
<cfif useLakebaseForclear_contract_renewal_packets>
	<cftry>
		<cfset application.oLakebase.deleteRows("contract_renewal_packets", {})>
		<cfcatch type="any">
			<cfset useLakebaseForclear_contract_renewal_packets = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForclear_contract_renewal_packets>
<cfquery name="clear_contract_renewal_packets" datasource="#application.datasource#">
	DELETE
	FROM Contract_Renewal_Packets
</cfquery>
</cfif>
<h1>stagnant contract replication wddx packets cleared</h1><BR>
<cfflush>


<cfset useLakebaseForclear_revision_queue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_release_programs")>
<cfif useLakebaseForclear_revision_queue>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_formula_pricing_release_programs", {})>
		<cfcatch type="any">
			<cfset useLakebaseForclear_revision_queue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForclear_revision_queue>
<cfquery name="clear_revision_queue" datasource="#application.datasource#">
	DELETE
	FROM Program_Formula_Pricing_Release_Programs
</cfquery>
</cfif>
<h1>program revision queue cleared</h1><BR>
<cfflush>


<cfset useLakebaseForclear_Wddx_Packet_To_File_Map = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("wddx_packet_to_file_map")>
<cfif useLakebaseForclear_Wddx_Packet_To_File_Map>
	<cftry>
		<cfset application.oLakebase.deleteRows("wddx_packet_to_file_map", {})>
		<cfcatch type="any">
			<cfset useLakebaseForclear_Wddx_Packet_To_File_Map = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForclear_Wddx_Packet_To_File_Map>
<cfquery name="clear_Wddx_Packet_To_File_Map" datasource="#application.datasource#">
	DELETE
	FROM Wddx_Packet_To_File_Map
</cfquery>
</cfif>
<h1>wddx packet to file mapping table cleared (used by billbacks)</h1><BR>
<cfflush>



<h1>APPLICATION INITIALIZATION COMPLETE - ARENT YOU PROUD</h1><BR>

<h1><a href="index.htm">CLICK HERE TO LOGIN</a></h1>


