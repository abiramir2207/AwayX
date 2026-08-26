<cfparam name="form.Days_Back"		default=0>
<cfparam name="form.Purge_Programs" default=0>
<cfparam name="form.Purge_Billbacks" default=0>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Delete WIP</TITLE>
	
	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
	
	<SCRIPT>
	function goToDelete()
	{
		if(confirm("If you continue, these records will be permanently and irretrievably deleted. Are you sure?"))
			{
				document.all.DeleteRecords.submit();
				return false;
			}	
		return false;
	}
	</SCRIPT>
	
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

<!--- They entered invalid options --->

<cfif (NOT form.Days_Back OR form.Days_Back IS 0) OR (NOT form.Purge_Programs AND NOT form.Purge_Billbacks)>
You have not entered a valid selection. You must enter a valid integer as the number of days back and choose to purge from either billbacks or programs.
</cfif>

<cfset DaysBack = Days_Back * -1>

<!--- Calculate how old this would be based on date --->
<cfset PurgeDate = dateadd("d",DaysBack,now())>

<table>
<tr>
	<td width="250"><strong>Delete records created before:</strong></td>
	<td width="250"><cfoutput>#dateformat(PurgeDate, 'mm/dd/yyyy')#</cfoutput></td>
</tr>
<!--- Get the count of programs that would be deleted --->
<cfset Purged_Programs = 0>
<cfif form.Purge_Programs>
	<!--- NOTE:
		If you change the conditions in this query, you will need to change it on "excel_program_list.cfm" and "execute_deletion.cfm" also.  
	--->
	<cfquery name="GetPurgedPrograms" datasource="#application.datasource#">
	SELECT COUNT(Contract_Main_ID) AS PurgeProgramCount
	FROM Contract_Main
	WHERE Contract_Main.Contract_Created_Date <= #PurgeDate#
	AND Contract_Main.Contract_Status_Type_IDX = 1
	AND contract_Number NOT LIKE '%TMP_PRG%'
	</cfquery>
	<tr>
		<td ><strong>Number of Programs to be purged:</strong></td>
		<td><cfoutput>#GetPurgedPrograms.PurgeProgramCount#</cfoutput></td>
	</tr>
	<cfset Purged_Programs = GetPurgedPrograms.PurgeProgramCount>
</cfif>

<!--- Get the count of billbacks that would be deleted --->
<cfset Purged_Billbacks = 0>
<cfif form.Purge_Billbacks>
	<!--- NOTE:
		If you change the conditions in this query, you will need to change it on "excel_billback_list.cfm" and "execute_deletion.cfm" also.
	--->
	<cfquery name="GetPurgedBillbacks" datasource="#application.datasource#">
	SELECT count(Billback_ID) AS PurgeBillbackCount
	FROM Billback
	WHERE Billback.Created_Date <= #PurgeDate#
	AND Billback.Billback_Status_ID = 1
	</cfquery>


	<tr>
		<td ><strong>Number of Billbacks to be purged:</strong></td>
		<td><cfoutput>#GetPurgedBillbacks.PurgeBillbackCount#</cfoutput></td>
	</tr>
	<cfset Purged_Billbacks = GetPurgedBillbacks.PurgeBillbackCount>
</cfif>
<tr>
	<td><CF_smallLink 
					title = "change dates" 
					url = "index.cfm"
					parameters = ""
				>
				</td>
	<td><CF_smallLink 
					title = "delete these records" 
					url = "##"
					parameters = "onClick=""javascript: return goToDelete();"""
				>	</td>
</tr>

<tr>
<cfoutput>
	<td>
	<cfif form.Purge_Programs>
	<CF_smallLink 
					title = "Export programs to Excel" 
					url = "excel_program_list.cfm?purgeDate=#PurgeDate#"
					parameters = ""
				>
				
	<cfelse>
	&nbsp;
	</cfif>
	</td>
	<td>
	<cfif form.Purge_Billbacks>
	<CF_smallLink 
					title = "Export billbacks to Excel" 
					url = "excel_billback_list.cfm?purgeDate=#PurgeDate#"
					parameters = ""
				>
	<cfelse>
	&nbsp;
	</cfif>
	</td>
</cfoutput>
</tr>
</table>
<!--- Hidden form to pass same information to the next page --->
<form name="DeleteRecords" action="execute_deletion.cfm" method="post">
	<cfoutput>
	<input type="hidden" name="PurgeDate" value="#PurgeDate#">
	<input type="hidden" name="Purge_Programs" value="#form.Purge_Programs#">
	<input type="hidden" name="Purge_Billbacks" value="#form.Purge_Billbacks#">
	<input type="hidden" name="PurgeProgramCount" value="#Purged_Programs#">
	<input type="hidden" name="PurgeBillbackCount" value="#Purged_Billbacks#">
	</cfoutput>
</form>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>