<!------ Clause_Template_Display.cfm ----->
<cfoutput>
<cfinclude template="/script/cf/string_functions.cfm">

<cfparam name="id" 	default="0">
<cfset tableBorderColor = "##93BEE2">
<cfif id>
	
	<!------ load the discount types ----->
	<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
	<cfset template = templateManager.get(url.id)>
	<cfset qGetAllDiscountTypes = templateManager.getAllDiscountTypes(url.id)>
	
	<!------ clause template ----->
	<cfset clauseTemplateManager = CreateObject("component", "components.clause_library.ClauseTemplateManager").init() />
	<!------ get all saved clause for this template ----->
	<cfset getTemplateClause = clauseTemplateManager.getTemplateClause(url.id)>
	<cfif getTemplateClause.recordCount GT 0>
		<cfquery name="qGetDistinctClause" dbtype="query">
			SELECT 	DISTINCT Clause_Library_ID, Clause_Category_Name
			FROM	getTemplateClause
			ORDER BY Clause_Category_Name
		</cfquery>
		<table cellpadding="2" cellspacing="0" border="0" class="MainTable" width="100%">	
			<cfset discCount = (qGetAllDiscountTypes.recordCount + 1) * 2>
			<colgroup>
				<col span="1" width="30%"></col>
				<col span="#discCount#" width="#Evaluate("70/#discCount#")#%"></col>
			<colgroup>
			<tr>
				<td colspan="100%" align="right" id="header">
				<B>R</B> - Required
				&nbsp;&nbsp;&nbsp;
				<B>O</B> - Optional
				</td>
			</tr>
			<tr bgcolor="C6FFC6" valign="bottom">
				<td align="center" rowspan="2" id="header"><B>Clause</B></td>
				<td align="center" colspan="2" id="header"><B>General</B></td>
				<cfloop query="qGetAllDiscountTypes">
				<td align="center" colspan="2" id="header"><B>#Discount_Type_Desc#</B></td>
				</cfloop>
			</tr>
			<tr bgcolor="C6FFC6" valign="bottom">
				<td id="header" style="border-left:1px solid #tableBorderColor#;" align="center" title="required"><B>R</B></td>
				<td id="header" title="optional" align="center"><B>O</B></td>
				<cfloop query="qGetAllDiscountTypes">
				<td id="header" style="border-left:1px solid #tableBorderColor#;" align="center" title="required"><B>R</B></td>
				<td id="header" title="optional" align="center"><B>O</B></td>
				</cfloop>
			</tr>
			<cfloop query="qGetDistinctClause">
				<cfset clauseId = Clause_Library_ID>
				<tr valign="top">
					<td title="#Clause_Category_Name#"><A HREF="/Clause_Library/index.cfm?id=#Clause_Library_ID#&command=dClause" onClick="NewWindow(this.href,'Clause_Display','625','450','Yes', 'Yes');return false;">#showRestrictedLength(Clause_Category_Name, 30)#</A></td>	
					<CF_Clause_Display_Sections
						Clause_Type = "1"
						clauseId = "#clauseId#"
						>
					<cfloop query="qGetAllDiscountTypes">
						<CF_Clause_Display_Sections
							Clause_Type = "2"
							Discount_Type_ID = "#Discount_Type_ID#"
							clauseId = "#clauseId#"
							>
					</cfloop>
				</tr>
			</cfloop>
		</table>		
	</cfif>
</cfif>
</cfoutput>