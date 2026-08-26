 <!-----------------------------------------------------------------------------

FILE NAME:		deleteTableRows.cfm
DESCRIPTION:	Delete the rows when the window closes.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	25-Feb-2015	 Delete the rows
							 

------------------------------------------------------------------------------> 
 
<cfset UploadID = URL.Upload_ID />
 <br>
 <br>
 <strong>Clearing cache.... </strong>
<!--- <cfset useLakebaseFordelDataFromTable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_new_single_file_blk_ins")>
<cfif useLakebaseFordelDataFromTable>
	<cftry>
		<cfset application.oLakebase.deleteRows("bb_new_single_file_blk_ins", {
			"upload_id" = "eq.#UploadID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelDataFromTable = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelDataFromTable>
<cfquery name="delDataFromTable" datasource="#application.datasource#">
	DELETE FROM BB_New_Single_File_BLK_INS WHERE Upload_ID = #UploadID#
</cfquery>
</cfif> --->
<script>
window.close();
</script>
