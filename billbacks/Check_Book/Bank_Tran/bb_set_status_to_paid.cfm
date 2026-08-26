<!------
set status to paid
----->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<CFIF appSettings.getInterface_700_To_Client()>
	<cfquery name="Set_Status" datasource="#application.datasource#">
		UPDATE 	Billback 
		SET		Billback_Status_ID = 4,
				BB_Payment_Request_Approved = 1,
				BB_Payment_Request_Approved_Date = getdate(),
				BB_Payment_Request_Approved_BY = '#request.AccessStructure.User_ID#'
		WHERE	Billback.Billback_ID = '#Billback_ID#'
	</cfquery>
<CFELSE>
	<cfset application.returned_customer_setting.PayBy_awayX = 0 /><!--- D8914 Payby_awayX  Get rid of the switch  --->
	<CFIF application.returned_customer_setting.PayBy_awayX EQ 0 AND application.returned_customer_setting.Customer_Keyword EQ "conagra">
		<cfquery name="Set_Status" datasource="#application.datasource#">
			UPDATE	Billback
			SET		Billback_Status_ID = 5,
					Paid_Date = getdate()
			WHERE
				Billback.Billback_ID = '#Billback_ID#'
				/*AND
				Billback.Billback_Status_ID = 4*/
		</cfquery>
	<CFELSE>
		<cfquery name="Set_Status" datasource="#application.datasource#">
			UPDATE	Billback
			SET		Billback_Status_ID = 5,
					Paid_Date = getdate()
			WHERE
				Billback.Billback_ID = '#Billback_ID#'
				AND
				Billback.Billback_Status_ID = 3
		</cfquery>
	</CFIF> 
	
</CFIF>
