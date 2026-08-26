
<cfset letUserProceed = 1>
<cfset messageArray = ArrayNew(1)>
<cfparam name="agreetype" default  = "0">

<cfset forbidType = application.oApplicationAppSettingsManager.getApplicationAppSettings().getForbidAllowProfilesInTemplates() />

<!--- check to see if equipment exsits --->
<cfif appSettings.getEquipment_Placement() IS 1>
	<!---The program includes equipment placement--->
	<cfif getProgramInfo.Equipment_Placement IS 1>
		<cfif Get_Profile_Settings.Approve_Equipment_Placement IS NOT 1>
			<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "You cannot approve programs which have equipment/dispenser placements.")>
		</cfif>
	</cfif>
</cfif>

<!--- check to see if the profile has approval rights at the template level --->
<cfparam name="approvaltype" default="1">			
<cfif forbidType EQ 0>
	<cfset approvaltype = 0>
</cfif>

<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset getapprovalTypes = templateManager.getProfileForbidTemplate(getProgramInfo.ProgramType_ID, forbidType, 2, Get_Profile_Settings.Profiles_id) />

<cfset getagreeTypes = templateManager.getProfileForbidTemplate(getProgramInfo.ProgramType_ID, forbidType, 5, Get_Profile_Settings.Profiles_id) />

<cfif getapprovalTypes.recordcount GT 0>
	<cfif forbidType EQ 0>
		<cfif getagreeTypes.recordcount GT 0>
			<cfset approvaltype = 0>
			<cfset agreetype = 1>
		<cfelse>
			<cfset approvaltype = 1>
		</cfif>
	<cfelse>
		<cfset approvaltype = 0>
	</cfif> 
<cfelse>
	<!------ template - profile agree only is same for forbid and allow ----->
	<cfif getagreeTypes.recordcount GT 0>
		<cfset approvaltype = 0>
		<cfset agreetype = 1>
	</cfif>
</cfif>
<cfif approvaltype eq 0><!------ do not have approve rights ----->
	<cfset letUserProceed = 0>
	<cfset ArrayAppend(messageArray, "You do not have approval rights for this program.")>
</cfif>

<!--- check to see if user have profile approval rights --->
<cfif Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 0>
	<cfset letUserProceed = 0>
	<cfset ArrayAppend(messageArray, "You do not have approval rights.")>
	<cfset approvaltype = 0>
	<cfset agreetype = 0>
</cfif>



<cfset budgetDisplayString = "" />
<cfset programAgreeOnlyForBudgetDollar = 0 />
<cfif appSettings.getBudgetsFunctionalityOn()>
	<cfsavecontent variable="budgetDisplayString">
	<cfinclude template="advanced_budget_program_selection.cfm">
	</cfsavecontent>
	<cfif programAgreeOnlyForBudgetDollar>
		<cfset letUserProceed = 0 />
		<cfloop list="#sProgramBudgetMessage#" index="sMsg">
			<cfset ArrayAppend(messageArray, sMsg)>
		</cfloop>			
	</cfif>
</cfif>

<!--- check to see if the profile has approval rights at the template level --->
<cfinclude template="common_program_level_check.cfm">
<cfinclude template="common_lumpsum_approval_check.cfm">