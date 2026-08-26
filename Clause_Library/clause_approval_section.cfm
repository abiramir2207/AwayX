<cfsetting enablecfoutputonly="Yes">
<!------ clause_approval_section.cfm ----->
<cfparam name="Attributes.clauseType" 	default="">
<cfparam name="Attributes.discountTypeId" 	default="0">
<cfparam name="Attributes.clauseId" 	default="">
<cfinclude template="/Clause_Library/Clause_Functions.cfm">

<cfset fieldName = buildFieldName("Removed_Clause", "0", Attributes.clauseType, Attributes.discountTypeId)>
<cfset qGetClauseRequireApproval = caller.qGetClauseRequireApproval>
<cfquery name="qGetDiscTypeRquired" dbtype="query">
	SELECT	isRequired
	FROM	qGetClauseRequireApproval
	WHERE
			Clause_Library_ID = #Attributes.clauseId#
			AND Clause_Type = #Attributes.clauseType#
			<cfif Attributes.discountTypeId>
			AND Discount_Type_ID = #Attributes.discountTypeId#
			</cfif>
			AND isRequired = 1
</cfquery>
<cfset isRequired = false>
<cfif qGetDiscTypeRquired.recordCount>
	<cfset isRequired = true>
</cfif>
<cfoutput>
<td align="center"<cfif isRequired> onmouseover="javaScript: highlightRowCol(this, '##CCFFCC', 1, '##AAEEAA');" onmouseout="javaScript: highlightRowCol(this, '##FFFFFF', 1);"</cfif>>
<cfif isRequired>
<input type="checkbox" value="#Attributes.clauseId#" name="#fieldName#">
<cfelse>NA
</cfif>
</td>
</cfoutput>
