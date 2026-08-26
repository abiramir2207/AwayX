<!-----------------------------------------------------------------------------

FILE NAME:		Program_Freight_Surcharge_Expiry_Notification.cfm
DESCRIPTION:	Sends the Freight surcharge expiry notification
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	02-Aug-2013		Send the Freight surcharge expiry notification to 
										RSPs of the program.

------------------------------------------------------------------------------> 



<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>

<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

<cfstoredproc procedure="Fuel_Surcharge_Expire_Notify" datasource="#application.datasource#">
 	<cfprocresult name="qryFuelSurchargeExpiryNotification">    
</cfstoredproc>


<cfif isDefined("qryFuelSurchargeExpiryNotification.RecordCount") AND qryFuelSurchargeExpiryNotification.RecordCount GTE 1>
	<cfloop query="qryFuelSurchargeExpiryNotification">
		<cf_EmailWrapper
			to="#Recipient#"
			from="#Contact_Admin_Email_Address#"
			subject="#Subject#"
			type="HTML"
			messagetype="1"
			generatedby="1"
			apparea="1">
			<cfoutput>#Body#</cfoutput>
		</cf_EmailWrapper>
	</cfloop>
</cfif>
		