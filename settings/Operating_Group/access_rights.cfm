<!---
	Name: access_rights.cfm         
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		The file contains all Operatoring Group profile management logic.
	Usage:
		/settings/access_rights/access_rights_matrix.cfm
	Tip:
		See /settings/access_rights/access_rights_matrix.cfm for additional usage information.
--->
<!------
Query BB_Profiles_Settings to get the saved values
----->

<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
<cfset profileRestrictionLevel 			= operatingGroupManager.getProfileRestrictionLevel() />
<cfset profileRestrictionLevelLabel 	= operatingGroupManager.getLabel(profileRestrictionLevel) />


	<!--- Dev Note: drachala; D28010: Profile Setting modifications 
				  what For: Check weather user selected any profiles if so we are passing argument into getOperatingGroupProfileSettings query.	--->
<cfset qOperatingGroupProfileSettings 	= operatingGroupManager.getOperatingGroupProfileSettings(level = profileRestrictionLevel, profile_id = profile_id)>
     	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  ---> 
<cfparam name="saveToXl" default="no">
<cfparam name="fName" default="xl">

	<!--- write the header to XL --->
	<cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""><cf_toFile fname="#fName#" data="#profileRestrictionLevelLabel#" nl="yes"></cfif>	
	<tr><td id="subheader" class="locked" align="left">Operating Group Profile Settings</td></tr>
	<cfoutput query="qOperatingGroupProfileSettings" group="Operating_Group_ID">
	<TR>
		<TD WIDTH="195" id="locked" class="locked" nowrap>#Operating_Group_Desc#</TD> <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="#Operating_Group_Desc#"></cfif>
		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Operating_Group_Profile_#Operating_Group_ID#" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Operating_Group_Profile_#Operating_Group_ID#','1')" TITLE="Update all values for this row.">(+)</a></TD>
		<cfoutput>
		<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Operating_Group_Profile_#Profiles_ID#_#Operating_Group_ID#" NAME="Operating_Group_Profile_#Profiles_ID#_#Operating_Group_ID#"  MASSUPDATEID="Operating_Group_Profile_#Operating_Group_ID#" VALUE="1"<CFIF Val(Operating_Group_Profile_Map_ID) NEQ 0> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#Profiles_ID#"#frmREADONLY#></TD>
			<cfif saveToXl is "yes">
				<CFIF Val(qOperatingGroupProfileSettings.Operating_Group_Profile_Map_ID) NEQ 0>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
		</cfoutput>
		<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	</TR>
	</cfoutput>	
