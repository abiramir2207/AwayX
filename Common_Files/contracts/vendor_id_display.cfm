<cfparam name="Caller" default="">
	<cfif len(trim(Vendor_ID)) and Vendor_ID NEQ 0>
		<!--- If the Payee is the "Distributor" in the "Billback_Closing_Method" settings in the settings panel --->
		<cfif Payee_Selection eq 1>
			<cfif len(Vendor_ID) eq 36 > <!--- guid --->
				<cfquery name="GetVendorName" datasource="#application.datasource#">
					SELECT Name As Vendor_Name,BSA_Foodservice_Customers_ID As Vendor_Master_ID ,Shr_Ship_To  
					FROM BSA_Foodservice_Customers
				 -- WHERE Shr_Ship_To = '#Vendor_ID#'
				 	 WHERE BSA_Foodservice_Customers_ID = '#Vendor_ID#'
				</cfquery>
			<cfelse>
				<cfquery name="GetVendorName" datasource="#application.datasource#">
					SELECT Name As Vendor_Name,BSA_Foodservice_Customers_ID As Vendor_Master_ID ,Shr_Ship_To  
					FROM BSA_Foodservice_Customers
				 	 WHERE Shr_Ship_To = '#Vendor_ID#'
				</cfquery>
			</cfif>
			<cfset Vendor_ID = GetVendorName.Shr_Ship_To />
		<cfelse>			
				<cfquery name="GetVendorName" datasource="#application.datasource#">
				SELECT Vendor_Name, Vendor_Master_ID 
				FROM Vendor_Master
				WHERE Vendor_ID = '#Vendor_ID#'
			 </cfquery>
			</cfif>
	<Cfif GetVendorName.recordcount> 
		<cfoutput>#GetVendorName.Vendor_Name# (#Vendor_ID#)
		    <script>
			<cfswitch expression="#Caller#">
				<cfcase value="Fixed">
					document.FixedComponents.Vendor_Master_ID.value = '#GetVendorName.Vendor_Master_ID#'
				</cfcase>
				<cfcase value="FixedEdit">
					document.editcomponentform.Vendor_Master_ID.value = '#GetVendorName.Vendor_Master_ID#'
					document.editcomponentform.AllowSave.value = 1;
				</cfcase>
				<cfcase value="Growth">
					document.newComponentForm.Vendor_Master_ID.value = '#GetVendorName.Vendor_Master_ID#'
					document.newComponentForm.AllowSave.value = 1;
				</cfcase>
			<!--- DEV NOTE: DAA; D14922 This function was added by ben to pass the vendor id variable to the calling page, but does not work, had to remove. --->
				//var displayCallbackHandler = function() {	
					<cfcase value="Rebate">
						document.dataForm.Vendor_Master_ID.value = '#GetVendorName.Vendor_Master_ID#'
					</cfcase>
					<cfcase value="RebateEdit">
						document.editcomponentform.Vendor_Master_ID.value = '#GetVendorName.Vendor_Master_ID#'
						document.editcomponentform.AllowSave.value = 1;
					</cfcase>
					<cfcase value="LumpSum">
						document.NewLumpSum.Vendor_Master_ID.value = '#GetVendorName.Vendor_Master_ID#'
						//document.NewLumpSum.Vendor_ID.value = '#GetVendorName.Vendor_Master_ID#'
					</cfcase>
				//}
			</cfswitch>
			</script>
		</cfoutput>
	</Cfif>
<!--- <cfset AjaxOnLoad("submitForm")> --->
</cfif>