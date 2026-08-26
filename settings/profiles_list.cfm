<!---
	Copyright (c)2012 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\settings\profiles.cfm
	Created:		11/30/2012
	Developer:		drachala
--->

<cfparam name="url.sort" default="ASC">
<cfparam name="url.InputText"default="">

<cfif find("null",url.InputText)>
		<cfset InputText = replace(url.InputText, "null", "","ALL")> 
		<cfset url.InputText = replace(InputText, ",", "","ALL")> 
</cfif>

<cfquery name="getProfiles" datasource="#application.datasource#">
	select Profiles_short_desc,Profiles_Desc, Profiles_ID
	from Profiles
	where Deleted = 0 
	<cfif isdefined("url.InputText") AND url.InputText NEQ "">
	and (Profiles_short_desc like '%#url.InputText#%'  OR Profiles_Desc like  '%#url.InputText#%')
	</cfif>
	Order by Profiles_Desc #url.sort#
</cfquery>
<!---<cfdump var="#getProfiles#"><cfabort>--->

<cfoutput>
<table border="0" style="background-color: ##FFCE80;">
		<tr style="width:620px;">
				<td><B>Profiles</B>
						<cfif url.sort EQ 'desc'>
							<a href="#ajaxLink('#cgi.script_name#?sort=ASC')#"><img src="/images/asc.png" border="0"></a>
						<cfelseif url.sort EQ 'asc'>
							<a href="#ajaxLink('#cgi.script_name#?sort=DESC')#"><img src="/images/desc.png" border="0"></a>
						</cfif>					
				</td>
				<td align="right">
						<!---
						<span style="color: red;">[</span>&nbsp;&nbsp;<a href = "javascript:checkAll(document.profiles.selected_profiles);" style="font-weight : bold;font-size: 12px;">select all</a>&nbsp;&nbsp;	<span style="color: red;">]</span>
						<span style="color: red;">[</span>&nbsp;&nbsp;	<a href = "javascript:uncheckAll(document.profiles.selected_profiles);" style="font-weight : bold;font-size: 12px;">unselect all</a>&nbsp;&nbsp;<span style="color: red;">]</span>
						--->
						<span style="color: red;">[</span>&nbsp;&nbsp;<a href = "javascript:checkAll(jQuery('input[name=selected_profiles]'));" style="font-weight : bold;font-size: 12px;">select all</a>&nbsp;&nbsp;	<span style="color: red;">]</span>
						<span style="color: red;">[</span>&nbsp;&nbsp;	<a href = "javascript:uncheckAll(jQuery('input[name=selected_profiles]'));" style="font-weight : bold;font-size: 12px;">unselect all</a>&nbsp;&nbsp;<span style="color: red;">]</s
				></td>
		</tr>
</table>


<form name="profile" action="" id="profiles">
	<table border="0" width="100%">
				<tr>
						<input type="hidden" value="" name="selected_profiles">
					<cfloop query="getProfiles">
							<td>
								<input type="checkbox" value="<cfoutput>#profiles_ID#</cfoutput>" name="selected_profiles">
								<span style="width:50px">#Profiles_short_desc#</span>
								[&nbsp;#Profiles_Desc#&nbsp;]
							</td>
							<cfif getProfiles.currentRow MOD 2 EQ 0></tr></cfif>
					</cfloop>
				<tr>
							<td colspan="4" style="text-align: center;">
									<span style="color: red;">[</span>
											&nbsp;
											<!---<a href = "javascript: profiles_id(document.getElementById('profiles').selected_profiles);" style="font-weight : bold;font-size: 12px;">View Selected Profiles</a> CHROMEFIX--->
											<a href = "javascript: profiles_id(jQuery('input[name=selected_profiles]'));" style="font-weight : bold;font-size: 12px;">View Selected Profiles</a>
											&nbsp;
									<span style="color: red;">]</span>
							</td>
				</tr>
	</table>
</form>
</cfoutput>	