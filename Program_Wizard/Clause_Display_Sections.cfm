<!------ Clause_Display_Sections.cfm ----->



<cfsetting enablecfoutputonly="Yes">
<cfparam name="Attributes.Clause_Type" 	default="">
<cfparam name="Attributes.Discount_Type_ID" 	default="">
<cfparam name="Attributes.clauseId" 	default="0">


<cfinclude template="/Clause_Library/Clause_Functions.cfm">

<cfset getTemplateClause = caller.getTemplateClause>

<cfset tableBorderColor = "##93BEE2">
<cfset requiredList = "1,0">
<cfoutput>
<td colspan="2" style="border-left:1px solid #tableBorderColor#;" align="center">
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
</cfoutput>
<cfloop list="#requiredList#" delimiters="," index="currRequired">
	<cfquery name="qGetThisDiscTypeClause" dbtype="query">
		SELECT	*
		FROM	getTemplateClause
		WHERE
				Clause_Type = #Attributes.Clause_Type#
				AND
				isRequired = #currRequired#
				<cfif Attributes.Discount_Type_ID NEQ "">
				AND
				Discount_Type_ID = #Attributes.Discount_Type_ID#
				</cfif>
				AND
				Clause_Library_ID = #Attributes.clauseId#
	</cfquery>
	<cfoutput>	
	<!------ <td<cfif currRequired> style="border-left:1px solid ##FFCE84;"</cfif> align="center" style="background-color:expression(trColor(this));">	 ----->	
	<td width="50%" align="center" style="border:none;">
		<cfset fieldName = buildFieldName("Clause", "#currRequired#", Attributes.Clause_Type, Attributes.Discount_Type_ID)>
		<cfset otherPairFieldName = buildFieldName("Clause", (currRequired + 1) mod 2, Attributes.Clause_Type, Attributes.Discount_Type_ID)>
		<cfif qGetThisDiscTypeClause.recordCount GT 0><img src="/Images/yes_small.gif"><cfelse><img src="?images/fill.gif" height="1" width="1"></cfif>
	</td>
	<!------ </td> ----->
	</cfoutput>
</cfloop>
<cfoutput>
</tr>
</table>
</td>
</cfoutput>






<!------ 
<cfsetting enablecfoutputonly="Yes">
<cfparam name="Attributes.Clause_Type" 	default="">
<cfparam name="Attributes.Discount_Type_ID" 	default="">
<cfparam name="Attributes.Display_Title" 	default="">
<cfparam name="Attributes.colCount" 	default="">

<cfset qClauses = caller.getTemplateClause>
<cfset requiredNameList = "Optional,Required">
<cfset requiredList = "1,0">
<cfinclude template="/script/cf/string_functions.cfm">

<cfquery name="thisClauseTypesClauses" dbtype="query">
	SELECT	*
	FROM	qClauses
	WHERE
			Clause_Type = #Attributes.Clause_Type#
			<CFIF Attributes.Discount_Type_ID NEQ "">
			AND
			Discount_Type_ID = #Attributes.Discount_Type_ID#
			</CFIF>
	ORDER BY isRequired DESC, Clause_Library_Title ASC
</cfquery>
<cfset colCount = Attributes.colCount>
<cfset cnt = 0>
<cfif thisClauseTypesClauses.recordCount GT 0>
	<cfoutput>
	<tr valign="top">
		<td style="border-bottom:solid ##93BEE2 1px;">&nbsp; &nbsp; <B>#Attributes.Display_Title#</B></td>
		<cfloop query="thisClauseTypesClauses">
			<cfset cnt = currentRow>
			<td style="border-bottom:solid ##93BEE2 1px;" title="#ListGetAt(requiredNameList, (isRequired + 1), ",")# clause" bgcolor="#IIF(isRequired, DE('FFF8DC'), DE('FFFFFF'))#"><cfif isRequired><img alt="Required clause" src="/Images/exclamation_1.gif"><cfelse>&nbsp;</cfif>&nbsp;<A HREF="/Common_Files/contracts/Clause_Library/index.cfm?id=#Clause_Library_ID#&command=dClause" onClick="NewWindow(this.href,'name','625','450','Yes', 'Yes');return false;"><FONT FACE="Arial, Helvetica, sans-serif" COLOR="##000099">#showRestrictedLength(Clause_Library_Title, 300)#</FONT></A></td>			
			<cfif not (cnt mod colCount) and currentRow LT recordCount>
			</tr>
			<tr>
			<td></td>
			</cfif>
		</cfloop>
		<cfset cnt = Evaluate(cnt mod colCount)>
		<cfif cnt>
		<cfloop index="i" from="#cnt#" to="#Evaluate(colCount - 1)#">
			<td style="border-bottom:solid ##93BEE2 1px;">&nbsp;</td>
		</cfloop>
		</cfif>
	</tr>
	</cfoutput>
</cfif>
 ----->