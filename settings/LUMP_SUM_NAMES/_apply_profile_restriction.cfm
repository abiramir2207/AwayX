<cfoutput>
	<TABLE width="70%" border="0" cellpadding="1" cellspacing="0"  style="margin-bottom:5px;">
		<tr>
			<td>
				Component: <b>#qGetCompRebate.Program_Lump_Sum_Name#</b>
				<hr color="navy">
				Check which profiles you want to restrict <b>#qGetCompRebate.Program_Lump_Sum_Name#</b> from.
			</td>
		</tr>
	</TABLE>

	<CF_smallLink 
		title = "save" 
		url = ""
		parameters = "onClick=""javascript: return applyProfiles('#form.compId#');"""
	>
	<CF_smallLink 
		title = "cancel" 
		url = ""
		parameters = "onClick=""javascript: return submitDataForm('active');"""
	>
	
	<table width="70%" border="0" cellpadding="1" cellspacing="0" class="maintable" style="margin-top:5px;margin-bottom:5px;">
		<!---- HEAD ----->
		<tr ID="HEADER" BGCOLOR="##FFCE84">
			<td STYLE="font-size:11px;" width="30px">&nbsp;</td>
			<td STYLE="font-size:11px;" nowrap width="50%"><b>Profiles</b></td>
			<td STYLE="font-size:11px;" nowrap><b>Visibility</b></td>
		</tr>
		<cfloop query="qGetProfiles">	
			<cfset lProfileIds = lumsumCompProfit.get(form.compId, Profiles_ID)>
			<tr <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
				<td><input name="Profiles_ID" type="checkbox" value="#Profiles_ID#" <cfif lProfileIds.Profiles_ID EQ Profiles_ID>checked</cfif> /></td>
				<td STYLE="font-size:11px;" nowrap>#Profiles_Desc#</td>	
				<td><input name="Visibility" type="checkbox" value="#Profiles_ID#" <cfif  (lProfileIds.Profiles_ID EQ Profiles_ID AND lProfileIds.Allow_User_To_View)>checked</cfif> /></td>
			</tr>
		</cfloop>
	</table>

	<CF_smallLink 
		title = "save" 
		url = ""
		parameters = "onClick=""javascript: return applyProfiles('#form.compId#');"""
	>
	<CF_smallLink 
		title = "cancel" 
		url = ""
		parameters = "onClick=""javascript: return submitDataForm('active');"""
	>
</cfoutput>