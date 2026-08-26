


<!--- 
	Update the record with....
 --->
<!--- <cfset useLakebaseForcheck_exist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ledger_table")>
<cfif useLakebaseForcheck_exist>
	<cftry>
		<cfset check_exist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ledger_table", {
				"ledger_id" = "eq.#URL.RID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheck_exist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheck_exist>
<CFQUERY name = "check_exist" datasource = "#application.datasource#">
	select * from ledger_table where ledger_Id = #URL.RID#
</CFQUERY>
</cfif>
 --->

<cfif isdefined("form.check_number")>
<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
	Update	Ledger_Table
	Set		Check_Number			=	<CFIF LEN(TRIM(Check_Number)) EQ 0>NULL<CFELSE>#Check_Number#</CFIF>
	Where	Ledger_ID				=	#URL.RID#
</CFQUERY> 
</cfif>

<cfif isdefined("form.check_issue_date")>
<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
	Update	Ledger_Table
	Set		Check_issue_date			=	<CFIF LEN(TRIM(Check_issue_Date)) EQ 0>NULL<CFELSE>'#Check_Issue_Date#'</CFIF>
	Where	Ledger_ID				=	#URL.RID#
</CFQUERY> 
</cfif>
<cfif isdefined("form.check_clearance_date")>
<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
	Update	Ledger_Table
	Set		Check_clearance_date	=	<CFIF LEN(TRIM(Check_Clearance_Date)) EQ 0>NULL<CFELSE>'#Check_Clearance_Date#'</CFIF>
	Where	Ledger_ID				=	#URL.RID#
</CFQUERY> 
</cfif>

<!---  
<CFIF "#check_exist.check_number#" EQ "" or "#check_exist.check_Issue_Date#" EQ "" or "#check_exist.check_Clearance_Date#" EQ "">
<CFQUERY NAME="Save_Data" DATASOURCE="#application.datasource#">
	Update	Ledger_Table
	Set		<CFIF "#check_exist.check_number#" EQ "">Check_Number			=	'#Check_Number#'</CFIF>
			<CFIF "#check_exist.check_Issue_Date#" EQ "">Check_Issue_Date		=	<CFIF LEN(TRIM(Check_issue_Date)) EQ 0>NULL<CFELSE>'#Check_Issue_Date#'</CFIF></CFIF>
			<CFIF "#check_exist.check_Clearance_Date#" EQ "" and "#check_exist.check_issue_date#" NEQ "">Check_Clearance_Date	=	<CFIF LEN(TRIM(Check_Clearance_Date)) EQ 0>NULL<CFELSE>'#Check_Clearance_Date#'</CFIF></CFIF>			
	Where	Ledger_ID				=	#URL.RID#
</CFQUERY> 
</CFIF>






</CFOUTPUT>
 ---><CFLOCATION URL="index.cfm" ADDTOKEN="No">  



UPDATE Person
SET Address = 'Stien 12', City = 'Stavanger'
WHERE LastName = 'Rasmussen' --->