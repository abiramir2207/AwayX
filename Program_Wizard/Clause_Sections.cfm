
<cfsetting enablecfoutputonly="Yes">
<cfparam name="Attributes.Clause_Type" 	default="">
<cfparam name="Attributes.Display_Title" 	default="">
<cfparam name="Attributes.Discount_Type_ID" 	default="">
<cfparam name="Attributes.clauseId" 	default="0">
<cfparam name="Attributes.categoryId" 	default="0">

<cfinclude template="/Clause_Library/Clause_Functions.cfm">

<cfset variables.appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<cfset getTemplateClause = caller.getTemplateClause>
<cfset tableBorderColor = "##93BEE2">

<!--- Dev Note: Milan - 19623/25647. For the old clauses functionality of clauses, we use optional/required 
clauses (0,1). For new simple clauses, there is no difference between optional and required..I am just using the 
code for backward compatibility.
--->
<cfif appSettings.getSimpleClause() eq 1>
  <cfset requiredNameList = "Optional">
  <cfset requiredList = "0">
<cfelse>
  <cfset requiredNameList = "Optional,Required">
  <cfset requiredList = "1,0">
</cfif>

<cfset cellChecked = false>
<cfset catFieldName = buildFieldName("ClauseCategory", Attributes.categoryId, Attributes.Clause_Type, Attributes.Discount_Type_ID)>

<cfsavecontent variable="cellContent">
<cfloop list="#requiredList#" delimiters="," index="currRequired">
	<cfoutput>	
	<!---<td title="#Attributes.Display_Title# - #ListGetAt(requiredNameList, currRequired+1, ",")#" width="50%" align="center" style="border:none;">--->
	<td>
		<cfset fieldName = buildFieldName("Clause", "#currRequired#", Attributes.Clause_Type, Attributes.Discount_Type_ID)>
		<cfset otherPairFieldName = buildFieldName("Clause", (currRequired + 1) mod 2, Attributes.Clause_Type, Attributes.Discount_Type_ID)>
		<cfset FormFieldValue = Evaluate("form.#fieldName#")>
		<cfset isChecked = ListFindNoCase(FormFieldValue, Attributes.clauseId, ",") />
		<cfif NOT isChecked>
			<cfparam name="form.#catFieldName#" 	default="">
			<cfset prevCat = Evaluate("form.#catFieldName#") />
			<cfset isChecked = ListFindNoCase(FormFieldValue, prevCat, ",") />
		</cfif>
		<!--- Dev Note: Milan - 19623/25647. For the old clauses functionality of clauses, we use the checkbox for optional/required. 
		For new simple clauses, I just use the hidden variable for backward compatibility.
		--->
		<cfif appSettings.getSimpleClause() eq 1>
		  <input sPairName="#otherPairFieldName#" onPropertyChange="javaScript: onlyOneChecked(this);" type="hidden" name="#fieldName#" value="#Attributes.clauseId#">				
		<cfelse>
		  <input sPairName="#otherPairFieldName#" onPropertyChange="javaScript: onlyOneChecked(this);" type="Checkbox" name="#fieldName#" value="#Attributes.clauseId#"<cfif isChecked> checked <cfset cellChecked = true></cfif>>
		</cfif>
	</td>
	</cfoutput>
</cfloop>
</cfsavecontent>
<cfoutput>
<!---
<td id="discType#IIF(Attributes.Discount_Type_ID EQ "", DE('0'), Attributes.Discount_Type_ID)#" colspan="2" style="border-left:1px solid #tableBorderColor#;" align="center" onmouseover3="javaScript: highlightRowCol(this, '##CCFFCC', 0, '##AAEEAA');" onmouseout3="javaScript: highlightRowCol(this, '##FFFFFF', 0);">
<table cellpadding="0" cellspacing="0" width="100%" class="NotMaintable">
<tr>
#cellContent#
</tr>
</table>
<input type="Hidden" name="#catFieldName#" value="#Attributes.clauseId#">
</td>--->

#cellContent#
</cfoutput>
