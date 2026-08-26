<!---
Display radio buttons for "paid to" inside programs. These radio buttons are only
used while adding a component, except for "growth", where it is used for addding as well
as editing a component.
--->
<style>
	.topborder{
		border-top: dotted 1px orange;
	}
</style>

<cfif isDefined("Form") AND  isStruct(Form)>
	<CFSET URL = fORM />
</cfif>

<cfset appSettings = application.appSettingsGet />
<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager") />
<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />
<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = URL.ProgramType_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = url.ContractMainID)>

<!--- Handle for planner paid to labels--->
<cfset qLabels                  = createObject("component", "components.settings.Labels.Labels").init() />
<cfset qGetPlannerDistributorLabels  = qLabels.GetPlannerLabels('Distributor') />
<cfset qGetPlannerOperatorLabels  = qLabels.GetPlannerLabels('Operator') />

<cfparam name="url.Is_a_Revision" default="0" />
<cfparam name="url.Growth_Auto_Pay" default="0" />
<cfparam name="url.GrowthSelectedCompPaidTo" default="0" />

<!--- Check to see if we can select Paid To: Distributor, Operator or both based on Template Generic Type.
Note:"url.Growth_Auto_Pay" argument gets used only for "growth" discount type.
Since the default is "0" on this file and "GetPaymentPaidToTypes" function, using "url.Growth_Auto_Pay"
here for all discount tyoes is O.K.
--->
<cfscript>
	GetPaymentPaidToTypes = templateManager.GetPaymentPaidToTypes(URL.ProgramType_ID, URL.Discount_Type_ID,URL.Component_Name_ID,url.Growth_Auto_Pay);
</cfscript>

<cfif URL.Discount_Type_ID eq 1>
	<cfset radioButtonName = "Fixed_Component_Paid_To">
<cfelse>
	<cfset radioButtonName = "Component_Paid_To">
</cfif>

<cfoutput>
<cfquery name="qPlannerProgram" datasource="#application.datasource#">
	SELECT 1
	FROM Contract_Main
	WHERE Contract_Main_ID = <cfqueryparam value="#url.ContractMainID#">
	AND Planner_ID > 0
</cfquery>

<cfloop query="GetPaymentPaidToTypes">

		<input name="#radioButtonName#" type="Radio" value="<cfoutput>#Payment_Paid_To_ID#</cfoutput>"
		<!---Note: For growth, the action of adding a component and editing a component uses the same file ("contract_Discount_Growth_Add_Component.cfm).
		That is the reason why the code for the saved "Paid_To" has to exist along with the default "paid to" - For "growth" only.
		Other discount types use a different file for editing.
		--->
		<cfif (GrowthSelectedCompPaidTo eq 0 AND GetPaymentPaidToTypes.Default_Paid_To_CF_Pages eq Payment_Paid_To_ID) OR GrowthSelectedCompPaidTo eq Payment_Paid_To_ID>checked</cfif>
		<cfif URL.Discount_Type_ID eq 4 and url.Is_a_Revision eq 1 AND RevisionSettings.Pay_To_Component eq 2>disabled</cfif>>
		<!--- Handle for planner paid to labels--->
		<cfif qPlannerProgram.recordCount>
			<cfif GetPaymentPaidToTypes.Payment_Paid_To_ID eq 1>
				#qGetPlannerDistributorLabels.Planner_Labels_Singular#
			<cfelse>
				#qGetPlannerOperatorLabels.Planner_Labels_Singular#
			</cfif>
		<cfelse>
			<cfoutput>#templateManager.getPaymentPaidToTypeDesc(paidToTypeIdentifier = Payment_Paid_To_Type_Identifier, paidToDesc=Payment_Paid_To_Type_Name)#</cfoutput>
		</cfif>

</cfloop>

</cfoutput>