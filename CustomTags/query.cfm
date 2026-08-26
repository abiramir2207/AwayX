<cfif thisTag.ExecutionMode is 'end'>
	<cfquery name="insertQuery" datasource="#attributes.datasource#">
		INSERT INTO thadata
		(thadata)
		VALUES
		('#thisTag.generatedContent#')
		
	</cfquery>
	
	<cfstoredproc procedure="cf_query" datasource="#attributes.datasource#">
		<cfprocparam type="In" cfsqltype="CF_SQL_IDSTAMP" dbvarname="@@INPUTVAR_thadata_id" value="#insertQuery.thadata_ID#" null="No">
		<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" variable="tempCode" dbvarname="@@Execution_Result_Code" null="No">
		<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" variable="tempCodeDesc" dbvarname="@@Execution_Result_Code_DESC" null="No">
		<cfprocparam type="Out" cfsqltype="CF_SQL_VARCHAR" variable="tempthis" dbvarname="@@out" null="No">	
	</cfstoredproc>
	
	<cfoutput>
		#tempthis#
	</cfoutput>



	<!--- dont display query on main page --->
	<cfset thisTag.generatedContent="">
</cfif>
