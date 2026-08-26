 <cfsilent>
<cfset Validation_Reason = "0">
<cfset Critical_Deviation = "0">
<cfset Volume_Deviation = "0">
<cfset Rate_Deviation = "0">

	<!--- Customer authorized --->	
	<!--- If there's a hit, set this as the validation reason --->
	<cfif Deviation_Unauthorized_Payee EQ 1>
		<cfset Validation_Reason = 1>
		<cfset Critical_Deviation = 1>
	</cfif>
	
	
	<!--- Product authorized --->
	<cfif Validation_Reason EQ 0><!--- Only keep checking if a validation reason hasn't been found yet --->	
		<!--- If there's a hit, set this as the validation reason --->
		<cfif Deviation_Unauthorized_Product EQ 1>
			<cfset Validation_Reason = 2>
			<cfset Critical_Deviation = 1>
		</cfif>	
	</cfif>
	
	<!--- Claim dates --->
	<cfif Validation_Reason EQ 0><!--- Only keep checking if a validation reason hasn't been found yet --->	
		<!--- If there's a hit, set this as the validation reason --->
		<cfif Deviation_Program_Dates EQ 1>
			<cfset Validation_Reason = 3>
			<cfset Volume_Deviation = 1>
		</cfif>
	</cfif>
	
	<!--- Claim overlap --->
	<cfif Critical_Deviation EQ 0 AND Volume_Deviation EQ 0> <!--- Check if there is no critical deviation --->	
		<!--- If there's a hit, set this as the validation reason --->
		<cfif Deviation_Billback_Overlap eq 1>
			<cfset Validation_Reason = 4>
			<cfset Volume_Deviation = 1>
		</cfif>
	</cfif>
	
	<!--- Volume --->
	<cfif Critical_Deviation EQ 0 AND Volume_Deviation EQ 0> <!--- Check if there is no critical deviation --->
		<!--- Check on bb_item_invoice_level table values --->
		<cfif Claim_CS GT Approved_CS>
			<cfset Validation_Reason = 5>
			<cfset Volume_Deviation = 1>
		</cfif>
	</cfif>
	
	<!--- Rate --->
	<cfif Critical_Deviation EQ 0> <!--- Check if there is no critical deviation --->
		<!--- Check on bb_item_invoice_level table values --->
		<cfif Claim_Rate NEQ Approved_Rate>
			<!--- If there's a volume deviation, append the rate deviation. Otherwise, just show rate deviation --->
			<cfif Volume_Deviation NEQ 0>
				<cfif (listFindNoCase(Validation_Reason, "5") OR (Validation_Reason NEQ 0))>
				<cfset Validation_Reason = Validation_Reason & ",6">
				</cfif>
			<cfelse>
				<cfset Validation_Reason = 6>
			</cfif>
			
		</cfif>
	</cfif>
	
	<!--- Price --->
	<cfif Critical_Deviation EQ 0> <!--- Check if there is no critical deviation --->
		<!--- Check on bb_item_invoice_level table values --->
		<cfif Approved_Contract_Price GT Approved_Invoice_Price>
			<!--- If there's a volume deviation, append the price deviation. Otherwise, just show price deviation --->
			<cfif Volume_Deviation NEQ 0>
				<cfif (listFindNoCase(Validation_Reason, "5") OR (Validation_Reason NEQ 0))>
				<cfset Validation_Reason = Validation_Reason & ",7">
				</cfif>
			<cfelse>
				<cfset Validation_Reason = 7>
			</cfif>
		</cfif>
	</cfif>
	
</cfsilent>
<cfoutput>
	<Cfif Validation_Reason IS NOT 0>
		#Validation_Reason#
	<cfelse> <!--- Only show a null if no deviation --->
		 &nbsp;
	</CFIF>
</cfoutput>