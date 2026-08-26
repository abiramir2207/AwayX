<cfsetting enablecfoutputonly="Yes">
<!------ Clause_Formvals.cfm ----->
<cfparam name="Attributes.Clause_Type" 	default="">
<cfparam name="Attributes.Discount_Type_ID" 	default="">
<cfparam name="Attributes.setDefault" 	default="0">

<cfif NOT Attributes.setDefault>
	<cfset getTemplateClause = caller.getTemplateClause>
</cfif>

<cfinclude template="/Clause_Library/Clause_Functions.cfm">

<cfset variables.appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<cfif appSettings.getSimpleClause() eq 1>
  <cfset requiredList = "0">
<cfelse>
  <cfset requiredList = "1,0">
</cfif>

<cfloop list="#requiredList#" delimiters="," index="currRequired">	
	<cfset fieldName = buildFieldName("Clause", "#currRequired#", Attributes.Clause_Type, Attributes.Discount_Type_ID)>
	<cfif Attributes.setDefault>
		<cfparam name="caller.form.#fieldName#" 	default="">
	<cfelse>
		<cfif NOT caller.form.state>
			<cfquery name="qGetThisDiscTypeClause" dbtype="query">
				SELECT	Clause_Library_ID
				FROM	getTemplateClause
				WHERE
						Clause_Type = #Attributes.Clause_Type#
						AND
						isRequired = #currRequired#
						<cfif Attributes.Discount_Type_ID NEQ "">
						AND
						Discount_Type_ID = #Attributes.Discount_Type_ID#
						</cfif>
			</cfquery>
			<cfset currList = ValueList(qGetThisDiscTypeClause.Clause_Library_ID)>
			<cfset "caller.form.#fieldName#" = currList>
		</cfif>
		<cfset currList = Evaluate("caller.form.#fieldName#")>
		<cfset caller.selectedClauseIds = ListAppend(caller.selectedClauseIds, currList, ",")>
	</cfif>
</cfloop>