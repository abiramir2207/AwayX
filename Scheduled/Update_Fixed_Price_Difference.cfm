<!------ Update_Fixed_Price_Difference.cfm ----->
 
<cfquery name="qCheckTableExist" datasource="#application.datasource#">
	SELECT	*
	FROM	INFORMATION_SCHEMA.ROUTINES
	WHERE	ROUTINE_NAME = 'refresh_price_change'
</cfquery>
<cfif qCheckTableExist.recordCount>

	<cfquery name="Call_Refresh_price_change" datasource="#application.datasource#">
		EXEC refresh_price_change
	</cfquery>
		
	<!------ Send report ----->
	<cfinclude template="Program_Pricing_Change.cfm">
	
</cfif>