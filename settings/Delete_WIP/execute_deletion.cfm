<cfparam name="form.PurgeDate"		default="">
<cfparam name="form.Purge_Programs" default="">
<cfparam name="form.Purge_Billbacks" default="">
<cfparam name="form.PurgeProgramCount" default=0>
<cfparam name="form.PurgeBillbackCount" default=0>

<!--- Do the actual processing --->

	<!--- Insert into log --->
	<cfset useLakebaseForInsertIntoDeletedLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("log_deleted_records")>
<cfif useLakebaseForInsertIntoDeletedLog>
	<cftry>
		<cfset application.oLakebase.insertRow("log_deleted_records", {
			"user_id" = "#request.accessstructure.User_ID#",
			"number_of_billbacks" = "#form.PurgeBillbackCount#",
			"number_of_programs" = "#form.PurgeProgramCount#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertIntoDeletedLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertIntoDeletedLog>
<cfquery name="InsertIntoDeletedLog" datasource="#application.datasource#">
	INSERT INTO Log_Deleted_Records
	(
		User_ID,
		Number_Of_Billbacks,
		Number_Of_Programs
	)
	VALUES
	(
		'#request.accessstructure.User_ID#',
		'#form.PurgeBillbackCount#',
		'#form.PurgeProgramCount#'
	)
	</cfquery>
</cfif>

	<!--- Let's purge those programs --->
	<cfif form.Purge_Programs IS 1>
		<!--- NOTE:
		If you change the conditions in this query, you will need to change it on "excel_program_list.cfm" and "confirm_deletion.cfm" also. 
		--->
		<!--- First get the list of Contract Mains to purge --->
		<cfquery name="GetPurgedPrograms" datasource="#application.datasource#">
		SELECT DISTINCT Contract_Main_ID
		FROM Contract_Main
		WHERE Contract_Main.Contract_Created_Date <= #PurgeDate#
		AND Contract_Main.Contract_Status_Type_IDX = 1
		AND contract_Number NOT LIKE '%TMP_PRG%'
		</cfquery>
		
		<cfloop query="GetPurgedPrograms">
			<!--- actual delete is done in a stored proc --->
			<cfstoredproc procedure="Delete_One_Program" datasource="#application.datasource#">
				<cfprocparam type="In" cfsqltype="CF_SQL_INTEGER" variable="Contract_Main_ID" dbvarname="@@Contract_Main_ID" value="#GetPurgedPrograms.Contract_Main_ID#" null="No">
			</cfstoredproc>
		</cfloop>
	
	</cfif>

		<!--- Let's purge those billbacks --->
	<cfif form.Purge_Billbacks IS 1>
		<!--- NOTE:
		If you change the conditions in this query, you will need to change it on "excel_billback_list.cfm" and "confirm_deletion.cfm" also. 
		--->		
		<!--- First get the list of Contract Mains to purge --->
		<cfquery name="GetPurgedBillbacks" datasource="#application.datasource#">
		SELECT DISTINCT Billback_ID
		FROM Billback
		WHERE Billback.Created_Date <= #PurgeDate#
		AND Billback.Billback_Status_ID = 1
		</cfquery>
		
		<cfloop query="GetPurgedBillbacks">
			<!--- actual delete is done in a stored proc --->
			<cfstoredproc procedure="Delete_One_Billback" datasource="#application.datasource#">
				<cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" variable="Billback_ID" dbvarname="@@Billback_ID" value="#GetPurgedBillbacks.Billback_ID#" null="No">
			</cfstoredproc>
		</cfloop>
		
	</cfif>

<!--- End processing and display results. --->


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Delete WIP</TITLE>
	
	
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET pagetitle = "SYSTEM ADMINISTRATION: Delete WIP Billbacks and Programs">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!---Help Files--->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<p></p>

<table>
<tr>
	<td width="250"><strong>WIP records before this date were deleted:</strong></td>
	<td width="250"><cfoutput>#dateformat(PurgeDate, 'mm/dd/yyyy')#</cfoutput></td>
</tr>

	<tr>
		<td ><strong>Number of Programs that were purged:</strong></td>
		<td><cfoutput>#form.PurgeProgramCount#</cfoutput></td>
	</tr>

	<tr>
		<td ><strong>Number of Billbacks that were purged:</strong></td>
		<td><cfoutput>#form.PurgeBillbackCount#</cfoutput></td>
	</tr>
	

</table> 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>