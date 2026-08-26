<cfset LocationFrom = "Auto">

	<!---Get contract to send out the reminder for--->
	<cfquery name="GetContractsToRemindOn" datasource="#application.datasource#">
	SELECT 	Contract_Main.Contract_Main_ID 
	FROM 	Contract_Main 
			INNER JOIN Program_Control_Panel_Options
			ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE 	Contract_Main.Contract_Status_Type_IDX = 2
			AND Contract_Main.Deleted = 0
			AND DateDiff(d, Contract_Main.Broker_Approved_Date, getdate()) = Program_Control_Panel_Options.Days_For_Reminder
	</cfquery>
	
	<!---For each record returned--->
	<cfloop query="GetContractsToRemindOn">
		<cfset Contract_Main_ID = GetContractsToRemindOn.Contract_Main_ID>
		
		<!---Sending email using this include--->
		<cfinclude template="/ANYTHING_AUTOMATED/EMAIL/rfa_program_emailer.cfm">
	
	</cfloop>

<!--- <!---Do not execute code if number of days is 0--->
</cfif> --->
<!---This is now controlled by template--->