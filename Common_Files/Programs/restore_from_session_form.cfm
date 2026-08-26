<cfset useLakebaseForGetExistingWDDXPacketLocations = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("session_variable_storage")>
<cfif useLakebaseForGetExistingWDDXPacketLocations>
	<cftry>
		<cfset getExistingWDDXPacketLocations = application.oLakebase.toQuery(
			application.oLakebase.selectRows("session_variable_storage", { "user_id" = "eq.#request.AccessStructure.User_ID#", "order" = "timestamp_of_save.desc" })
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetExistingWDDXPacketLocations = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetExistingWDDXPacketLocations>
	<cfquery name="getExistingWDDXPacketLocations" datasource="#application.datasource#">
		SELECT *
		FROM Session_Variable_Storage
		WHERE User_Id = '#request.AccessStructure.User_ID#'
		ORDER BY Timestamp_Of_Save DESC
	</cfquery>
</cfif>
<script>
	confirmSelection=function(){
		if(confirm("IS THIS OK?")){
			document.theForm.submit()
		}
	}
</script>
<form action="restore_from_session_action.cfm" method="post" name="theForm" id="theForm">
<TABLE>
	<TR>
		<TD>&nbsp;</TD>
		<TD>&nbsp;</TD>
	</TR>
	<CFIF getExistingWDDXPacketLocations.RecordCount GT 0>
		<cfoutput query="getExistingWDDXPacketLocations">
			<TR>
				<TD><input name="RecordToRestore" id="RecordToRestore" type="radio" value="#getExistingWDDXPacketLocations.Session_Variable_Storage_ID#" onclick="confirmSelection()"></TD>
				<TD>#getExistingWDDXPacketLocations.Timestamp_Of_save#</TD>
			</TR>			
		</cfoutput>
	<CFELSE>
	NO PACKETS
	</CFIF>
</TABLE>
</form>
