<!------ payment_cycle_selection.cfm ----->
<!------
when calling from basic info page
<cf_payment_cycle_selection
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Program_ID = "0"
			Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
			isRevision = "#ISREVISIONOFEXISTINGCONTRACT#" -- this tells if its a revison
			>

when calling from discount type page
<cf_payment_cycle_selection
			Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
			Program_ID = "#FORM.Contract_Main_ID#"
			Selected_Payment_Cycle_ID = "#FORM.PaymentCycle#"
			>
 ----->
<cfsilent>
	<cfparam name="Attributes.Template_ID" 					default="0">
	<cfparam name="Attributes.Program_ID" 					default="0">
	<cfparam name="Attributes.Component_ID" 				default="0">
	<cfparam name="Attributes.discount_Type_ID" 			default="0">
	<cfparam name="Attributes.Selected_Payment_Cycle_ID" 	default="">
	<cfparam name="Attributes.Action" 						default="selection">
	<cfparam name="Attributes.isRevision"					default="0" type="boolean">
	<cfparam name="Attributes.NoneEntry"					default="1" type="boolean">
	<cfparam name="Attributes.Growth_Auto_Pay"					default="0" type="boolean">	<!--- D35731 Growth Auto Pay --->
	<cfparam name="Attributes.Disable_Payment_Cycle" 		default="0" type="boolean"> <!--- Dev Note: Kal; 12047 --->

	<cfset paymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager").init() />

	<cfif Attributes.Selected_Payment_Cycle_ID EQ "" AND Attributes.Program_ID NEQ 0 AND Attributes.discount_Type_ID NEQ 0 AND Attributes.Component_ID NEQ 0>
		<cfset Attributes.Selected_Payment_Cycle_ID = paymentCycleManager.getPaymentCycle(Attributes.Program_ID, Attributes.discount_Type_ID, Attributes.Component_ID)>
	</cfif>

</cfsilent>
<cfif Attributes.Action EQ "display">
	<cfset paymentCycleDesc = paymentCycleManager.getPaymentCycleDescription(Attributes.Selected_Payment_Cycle_ID)>
	<cfoutput>#paymentCycleDesc#</cfoutput>
<cfelse>
	<!--- D35731 Growth Auto Pay --->
	<cfset qGetPaymentCycles = paymentCycleManager.getPaymentCycles(Attributes.Template_ID, Attributes.Growth_Auto_Pay) />
	<cfif Attributes.Selected_Payment_Cycle_ID EQ "">
		<cfset Attributes.Selected_Payment_Cycle_ID = qGetPaymentCycles.PayCycleDefaultOption>
	</cfif>

	<!--- Dev Note: Kal; 12047 : Issue is when programID is not passed and we are trying to disable payment cycle if its a revision.
		  In that case the isRevision is passed.--->
	<cfset qTemplateRevisionSettings = CreateObject("component", "components.programs.Display_Program.revision_settings").getRevisionSettings(templateId = Attributes.Template_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = Attributes.Program_ID) />

	<!---guard against string values being passed--->
	<cfif isNumeric(Attributes.Program_ID) AND Attributes.Program_ID neq 0>
		<cfset Attributes.isRevision = CreateObject("component", "components.programs.Program").isARevision(Attributes.Program_ID) />
	</cfif>

	<!--- Dev Note: Kal; 12047 : Disable Payment Frequency on Revise based on template revision setting --->
	<cfif Attributes.isRevision AND qTemplateRevisionSettings.Payment_Frequency_Changes eq 2 >
		<cfset Attributes.Disable_Payment_Cycle = true />
	</cfif>

	<span id="Err_Sp_PaymentCycle"></span>
	<select name="PaymentCycle"
			id="PaymentCycle"
			onchange="document.all.PaymentCycle.value = this.value;"
			<cfif Attributes.Disable_Payment_Cycle>disabled</cfif>
			>
		<cfif Attributes.NoneEntry eq 1><option value="0" SELECTED>Choose One</option></cfif>
		<cfoutput query="qGetPaymentCycles">
			<option value="#Payment_Cycle_ID#" <cfif Payment_Cycle_ID eq Attributes.Selected_Payment_Cycle_ID>selected</cfif>>#Payment_Cycle#</option>
		</cfoutput>
	</select>

	<cfif Attributes.Disable_Payment_Cycle><cfoutput><input type="hidden" name="PaymentCycle" value="#Attributes.Selected_Payment_Cycle_ID#" /></cfoutput></cfif>

</cfif>