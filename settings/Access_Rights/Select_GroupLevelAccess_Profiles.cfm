<!------ Select_GroupLevelAccess_Profiles.cfm ----->

<script language="JavaScript">
	function selectAll(bCheck)
	{
		event.returnValue = false;
		var ObjProfiles = eval("document.all.Profile_Id");
		var i, profileLen;
		if(ObjProfiles)
		{
			profileLen = ObjProfiles.length;
			if(profileLen)
			{
				for(i=0;i<profileLen;i++)
				{
					if(!ObjProfiles[i].disabled)
					{
						ObjProfiles[i].checked = bCheck;
					}
				}
			}
			else
			{
				if(!ObjProfiles.disabled)
				{
					ObjProfiles.checked = bCheck;
				}
			}
		}
	}
</script>

<!------ Show profiles list ----->
<cfset qprofiles = CreateObject("component","components.settings.profiles.profile").getdistinctProfiles() />
<cfset maxCols = 4 />
<cfset tdWidth = 100/maxCols />
<CFSCRIPT>
Border="Yes";
BorderSize=1;  
BorderColor="orange";
Image="/images/plus3.gif";
ImageOpen="/images/minus3.gif";
TitleColor="Blue"; 
TitleFont="Arial";
TitleSize=9;
IsClosed="Yes";
</CFSCRIPT>

<CF_OPENLAYER
	BORDER="#Border#"							BORDERSIZE="#BorderSize#"  
	BORDERCOLOR="#BorderColor#"					IMAGE="#Image#"
	IMAGEOPEN="#ImageOpen#"						TITLE="Select Profiles"  
	TITLECLOSED="Select Profiles"				TITLETOOLTIP="Click here to toggle view"  
	TITLECOLOR="#TitleColor#"					TITLEFONT="#TitleFont#"
	TITLESIZE="#TitleSize#"						ISCLOSED="#IsClosed#">	

<table cellpadding="2" cellspacing="0" width="700" border="0" align="left">	
<cfif qprofiles.recordcount GT 0>
<tr bgcolor="FFCE8" style="height:20px">
	<td colspan="100%" nowrap style="border-bottom:1px solid ##93BEE2;">
	<CF_smallLink 
		title = "select all" 
		url = "##"
		parameters = "onClick=""javascript: return selectAll(true);"""
	>
	<CF_smallLink 
		title = "deselect all" 
		url = "##"
		parameters = "onClick=""javascript: return selectAll(false);"""
	>	
	</td>
	</tr>
		<tr><td colspan="100%"><b>*The above settings will be applied to all the selected profiles.</b></td></tr>
		<tr>
		<cfset colsCount = 0 />
		<cfoutput query="qprofiles">
		<td width="#tdWidth#%" style="border-bottom:1px solid ##93BEE2;"><input type="checkbox" name="Profile_Id" value="#Profiles_Id#" <cfif Profiles_Id is url.profileId>disabled</cfif>>#Profiles_Desc#</td>
		<cfset colsCount = colsCount + 1 />
		<cfif colsCount GTE maxCols>
			</tr><tr>
			<cfset colsCount = 0 />
		</cfif>
		</cfoutput>
		</tr>
	<cfelse>
		<tr>
		<td>No profiles found</td>
		</tr>
	</cfif>
</table>
</CF_OPENLAYER>