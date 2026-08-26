<!----
	Filename:	AwayX\Deductions\settings\Update_BB_CRA.cfm
	Created:	11/13/2014
 	Developer:	Anand Rao
	Description:
		USE TO UPDATE BB CRA
	Usage:
		settings / payables / payable settings
---->
<cfset useLakebaseForupdateBBcra = application.oLakebase.isEnabled() AND application.oLakebase.isProcMigrated("Populate_Billback_Approvable_Positions")>
<cfif useLakebaseForupdateBBcra>
	<cftry>
		<cfset application.oLakebase.callProcedure("Populate_Billback_Approvable_Positions", {})>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForupdateBBcra = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateBBcra>
<cfquery name="updateBBcra" datasource="#application.datasource#" >
	EXEC Populate_Billback_Approvable_Positions NULL
</cfquery>
</cfif>
<div style="color:green;font-size:12px;" align="center"><b>Done. This window will close automatically in 2 seconds.<b/></div>
<script>
 	setTimeout("closewindow()",2000);
	function closewindow(){
		self.close();
	}
</script> 