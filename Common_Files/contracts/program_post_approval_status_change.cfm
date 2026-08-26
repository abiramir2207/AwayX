<!------ program_post_approval_status_change.cfm ----->
<cfparam name="form.post_approval_status_erp_research_to_hidden" 	default="">
<cfparam name="form.Business_considerations" 	default="">
<cfparam name="form.EncrypContractId" 	default="">

<cfif form.EncrypContractId NEQ "">
	<!------ decrypt ----->
	<cf_cryp type="de" key="#request.key#" string="#FORM.EncrypContractId#">
	<cfset Program_ID = cryp.value />
	
	<cfset programObj = CreateObject("component", "components.programs.program") />
	<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
	
	<cfif IsNumeric(form.post_approval_status_erp_research_from_hidden) AND IsNumeric(form.post_approval_status_erp_research_to_hidden)>
		<!------ save comments ----->
		<cfset programObj.saveInternalComments(
					programId = Program_ID,
					internalComments = BUSINESS_CONSIDERATIONS) />
		<!------  set post approval status ----->
		<cfset ProgramPostApprovalStatusManager.changeProgramPostApprovalStatus(
					programId = Program_ID,
					fromStatusId = form.post_approval_status_erp_research_from_hidden,
					toStatusId = form.post_approval_status_erp_research_to_hidden,
					userId = request.AccessStructure.user_id) />
		<!--- Send Email to Entry Team on Research Complete --->
		<cfif form.post_approval_status_erp_research_to_hidden EQ 2>
			<cfset Contract_Main_ID = cryp.value>
			<cfinclude template="/anything_automated/email/pending_research_complete_emailer.cfm">
		</cfif>
	
	</cfif>	
	
</cfif>

<cflocation addtoken="No" url="contract_edit_menu.cfm?CID=#FORM.EncrypContractId#" />