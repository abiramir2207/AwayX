<cfset useLakebaseFordeletePriorDistributorCalendar = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_fiscal_year")>
<cfif useLakebaseFordeletePriorDistributorCalendar>
	<cftry>
		<cfset application.oLakebase.updateRows("distributor_fiscal_year",
			{
				"company_main_id" = "eq.#request.AccessStructure.Company_Main_ID#",
				"distributor_id" = "eq.#Form.Distributor_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeletePriorDistributorCalendar = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletePriorDistributorCalendar>
<CFQUERY NAME="deletePriorDistributorCalendar" datasource="#application.datasource#">
	UPDATE Distributor_Fiscal_year
	SET Deleted = 1
	WHERE Company_main_ID = '#request.AccessStructure.Company_Main_ID#'
	AND Distributor_ID = '#Form.Distributor_ID#'
</CFQUERY>
</cfif>

<CFLOOP INDEX="LoopCount" FROM="1" TO="#FORM.NUMBER_OF_PERIODS#" STEP="1">
	<CFQUERY NAME="saveFiscalYear" datasource="#application.datasource#">
		INSERT INTO Distributor_Fiscal_year
		(Company_Main_ID, Distributor_ID, Start_Date, End_Date, Period_Length, Last_Updated, Last_Updated_By_User_ID)
		VALUEs
		( '#request.AccessStructure.Company_Main_ID#','#Form.Distributor_ID#', #createodbcdatetime(evaluate("FORM.Period_#LoopCount#_Starting_Date"))#, #createodbcdatetime(evaluate("FORM.Period_#LoopCount#_Ending_Date"))#, #evaluate("FORM.Period_#LoopCount#_Length")#, #createodbcdatetime(now())#, '#request.AccessStructure.User_ID#')
	</CFQUERY>
</CFLOOP>



<cflocation URL="distributor_fiscal_year_settings.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Save Settings</TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save fiscal year settings																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

Saved!!!


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



