
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


<cfquery name="clear_contract_renewal_packets" datasource="#application.datasource#">
	DELETE
	FROM Contract_Renewal_Packets
</cfquery>
<h1>stagnant contract replication wddx packets cleared</h1><BR>
<cfflush>


<cfquery name="clear_revision_queue" datasource="#application.datasource#">
	DELETE
	FROM Program_Formula_Pricing_Release_Programs
</cfquery>
<h1>program revision queue cleared</h1><BR>
<cfflush>


<cfquery name="clear_Wddx_Packet_To_File_Map" datasource="#application.datasource#">
	DELETE
	FROM Wddx_Packet_To_File_Map
</cfquery>
<h1>wddx packet to file mapping table cleared (used by billbacks)</h1><BR>
<cfflush>



<h1>APPLICATION INITIALIZATION COMPLETE - ARENT YOU PROUD</h1><BR>

<h1><a href="index.htm">CLICK HERE TO LOGIN</a></h1>


