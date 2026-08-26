<!------ deductions_action.cfm ----->
<cfparam name="FORM.Deduction_ID" 	default="">
<cfparam name="FORM.BBID" 	default="">

<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />

<cfif FORM.Deduction_ID NEQ "" AND FORM.BBID NEQ "">

	<cfset Billback_ID = FORM.BBID />
	<cfset Deduction_ID = FORM.Deduction_ID />
		<cfinclude template="/deductions/save_billback_association.cfm" />
		<!--- Dev Note(79256) - Passing "ReasonCode" from here because in the "closeDeduction" function, it is a "required" argument.
		Actually, we do not want to update the reason code as we get the "reason code" from the client. So, we are 
		actually passing another argument called "DontUpdateReasonCode". When this is set to 1, we do not update the "ReasonCode"
		--->
		<cfset DeductionManager.closeDeduction(Deduction_ID=Deduction_ID,ReasonCode='',ClearedAmount=form.Cleared_Amount,DontUpdateReasonCode=1)>

</cfif>
<!--- Ana: D15168 - Dont let reset --->
<cfset local_bbid = FORM.BBID>
<cfinclude template="bb_menu_stats.cfm">
<script>
	window.parent.tabClick('summary');
</script>
<!--- <CFLOCATION URL="Billback_Summary.cfm?BBID=#FORM.BBID#" ADDTOKEN="NO"> --->