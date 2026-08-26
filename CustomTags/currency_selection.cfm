<!---
Created by Daniel Arsenault using claim_mechanic_selection.cfm as template
November 13, 2007
--->

<!------ currency_selection.cfm ----->
<!------

<cf_currency_selection
	Default_Currency_Selection = "#CSLGetContractInfo.Currency#"
	Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
	Edit_Selection = "#FORM.Currency#"
	Is_Revision = #CSLGetContractInfo.Is_Revision#
	>
 ----->
<cfsilent>
<cfparam name="Attributes.Default_Currency_Selection"				default="0">
<cfparam name="Attributes.Template_ID"								default="0">
<cfparam name="Attributes.Edit_Selection"							default="0">
<cfparam name="Attributes.Is_Revision"								default="0">
<cfparam name="Attributes.disabled"									default="0">
<!--- 
  Dev Notes: 21305/Anand Rao/17-Nov-09
  Added the condition checking for null value as it was slipping through and 
  assigning Null to the Pre_selected value as null had a len of 4 
--->
<Cfif Attributes.Edit_Selection IS 0 OR len(trim(Attributes.Edit_Selection)) IS 0 OR Attributes.Edit_Selection EQ "NULL">
	<cfset Pre_Selected = Attributes.Default_Currency_Selection>
<cfelse>
	<cfset Pre_Selected = Attributes.Edit_Selection>
</CFIF>

<cfquery name="GetDefaultCurrency" datasource="#application.datasource#">
	SELECT a.CurrencyDefaultOption, b.Currency_Name, b.Currency_Code
	FROM Program_Control_Panel_Options a, Currency b
	WHERE a.CurrencyDefaultOption = b.Currency_ID
		AND ProgramControl_Panel_Options_ID = '#Attributes.Template_ID#'
</cfquery>

<cfquery name="GetCurrenciesforTemplate" datasource="#application.datasource#">
	SELECT Currency.Currency_Name, Currency.Currency_Code, Currency.Currency_ID
	FROM Currency_Mapping
	INNER JOIN Currency
		ON Currency.Currency_ID = Currency_Mapping.Currency_ID
	WHERE Currency_Mapping.Deleted = 0
	AND Currency_Mapping.Template_ID = '#Attributes.Template_ID#'
	ORDER BY Currency.Currency_Name
</cfquery>
</cfsilent>

<cfif GetCurrenciesforTemplate.recordcount GT 0>
	<span id="Err_Sp_Currency"></span>
	<select name="Currency" id="Currency" <cfif Attributes.disabled EQ 1>disabled</cfif>>
		<cfif Pre_Selected EQ 0 OR Pre_Selected NEQ "">
			<option value="0" SELECTED>Choose One</option>
		</cfif>
		<cfoutput query="GetCurrenciesforTemplate">
			<option value="#Currency_ID#" <cfif Currency_ID eq Pre_Selected>selected</cfif>> #Currency_Name# (#Currency_Code#)</option>
		</cfoutput>
	</select>
	<cfif Attributes.disabled EQ 1>
		<cfoutput><input name="Currency" type="hidden" value="#Pre_Selected#"></cfoutput>
	</cfif>
<cfelse>
	<cfoutput>
		#GetDefaultCurrency.Currency_Name# (#GetDefaultCurrency.Currency_Code#)
		<input name="Currency" type="hidden" value="#GetDefaultCurrency.CurrencyDefaultOption#">
	</cfoutput>
</cfif>