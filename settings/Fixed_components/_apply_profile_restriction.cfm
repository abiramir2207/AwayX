<cfoutput>
<table width="70%" border="0" cellpadding="1" cellspacing="0">
	<tr>
		<td>
			Component: <b>#qGetCompFixed.Program_Fixed_Component_Name#</b>
			<hr color="navy">
			Check which profiles you want to restrict <b>#qGetCompFixed.Program_Fixed_Component_Name#</b> from.
		</td>
	</tr>
</table>
<br>
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
<table width="70%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE" style="margin-top:5px;">
	<!---- HEAD ----->
	<tr ID="HEADER" BGCOLOR="##FFCE84">
		<td STYLE="font-size:11px;" width="30px">&nbsp;</td>
		<td STYLE="font-size:11px;" width="50%" nowrap><b>Profiles</b></td>
		<td STYLE="font-size:11px;" nowrap><b>Visibility</b></td>
	</tr>
	<cfloop query="qGetProfiles">
		<cfset lProfileIds = fixedCompProfit.get(form.compId, Profiles_ID)>
		<tr <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
			<td><INPUT NAME="Profiles_ID" TYPE="checkbox" value="#Profiles_ID#" <cfif lProfileIds.Profiles_ID EQ Profiles_ID>checked</cfif> /></td>
			<td STYLE="font-size:11px;" nowrap>#Profiles_Desc#</td>	
			<td STYLE="font-size:11px;" nowrap><input name="Visibility" type="checkbox" value="#Profiles_ID#" <cfif  (lProfileIds.Profiles_ID EQ Profiles_ID AND lProfileIds.Allow_User_To_View)>checked</cfif> /></td>	
		</tr>
		
	</cfloop>
</table>
<br>
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