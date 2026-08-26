<cfoutput>
<cfset clauseCategoryManager = CreateObject("component", "components.clause_library.ClauseCategoryManager").init() />
<cfset qGetCat = clauseCategoryManager.getAll() />

<br><br>
<table cellpadding="2" cellspacing="0" class="MainTable" width="80%">
	<tr bgcolor="FFCE84">
		<td id="header">&nbsp;</td>
		<td id="header"><B>Clause Category</B></td>
		<td id="header" align="center"><B>Revision require approval</B></td>
		<td id="header" align="center"><B>Default Clause</B></td>
		<td id="header" align="center"><B>Delete Category</B></td>
	</tr>
	<cfloop query="qGetCat">
		<tr>
			<td>&nbsp;</td>
			<td>
				<a href="#thisPage#?command=ceClauseCategory&id=#Clause_Category_ID#">#Clause_Category_Name#</a>
			</td>
			<td align="center">
				<cfif Require_Approval><img src="/Images/yes_small.gif">
				<cfelse><img src="/Images/no_small.gif">
				</cfif>
			</td>
			<td align="center">
				<cfif Default_Clause_Library_ID NEQ "">
					<CF_smallLink 
							title = "view" 
							url = "/Clause_Library/index.cfm?id=#Default_Clause_Library_ID#&command=dClause"
							parameters = "onClick=""JavaScript: NewWindow(this.href,'Clause_Display','625','450','Yes', ',',',','Yes');return false;"""
						>
				<cfelse>
					None
				</cfif>
			</td>
			<td align="center">
				<CF_smallLink 
					title = "delete" 
					url = "/Clause_Library/index.cfm?id=#Clause_Category_ID#&command=delCategory"
					parameters = "onClick=""JavaScript: return alertDelete();"""
				>
			
			</td>
		</tr>	
	</cfloop>
</table>
</cfoutput>