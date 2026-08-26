<!----------------------------------------------------------------------------------
Name         :	planners_access_rights.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	Anand Rao
Description  : 	The file contains all Planner profile management logic.
---------------------------------------------------------------------------------->

<cfparam name="fromSettings_management" default=0>

<cfif fromSettings_management neq 1>
<SCRIPT LANGUAGE="JavaScript">
function disableCheck()
{
	return false;
}

function disableBillbackElement(chObj,bEnable)
{
	var styleText = "border: 2px solid Silver;";
	if(bEnable)
	{
		chObj.disabled = false;
		if(chObj.type == "text")
		{
			chObj.style.cssText = ""
		}
	}
	else
	{
		chObj.disabled = true;
		if(chObj.type == "checkbox")
		{
			chObj.checked = bEnable;
		}
		if(chObj.type == "text")
		{
			chObj.style.cssText = styleText;
		}
	}
}

</SCRIPT>
</cfif>
<cfparam name="saveToXl" default="no">
<cfparam name="fName" default="xl">


	<!--- write the header to XL --->
	<cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""><cf_toFile fname="#fName#" data="Planner Profile Settings" nl="yes"></cfif>
	<!---
		64386:	'Deduction Profile Settings' header still visible when setting is set to 'Hide'/Anand Rao/28-Nov-2016
		Make sure to add new setting in the below if condition also.
	--->
	<cfif  (fromSettings_management EQ 1 OR getSettingsManagerProfiles.Planner_Create NEQ 0
			OR getSettingsManagerProfiles.Planner_Create_View NEQ 0
			OR getSettingsManagerProfiles.Planner_Create_None NEQ 0
			OR getSettingsManagerProfiles.Planner_Reassign NEQ 0
			OR getSettingsManagerProfiles.Planner_Margin_View NEQ 0
			OR getSettingsManagerProfiles.Planner_Approval_Rights NEQ 0
			OR getSettingsManagerProfiles.Marketing_Events_Create NEQ 0
			OR getSettingsManagerProfiles.Marketing_Events_Create_View NEQ 0
			OR getSettingsManagerProfiles.Marketing_Events_Create_None NEQ 0
			OR getSettingsManagerProfiles.Planner_Product_Calendar NEQ 0
			OR getSettingsManagerProfiles.Planner_Strategic_Guidelines NEQ 0
			OR getSettingsManagerProfiles.NUC_Targets_Create NEQ 0
			OR getSettingsManagerProfiles.NUC_Targets_Create_View NEQ 0
			OR getSettingsManagerProfiles.NUC_Targets_Create_None NEQ 0
		  	OR getSettingsManagerProfiles.Planner_Catalog NEQ 0
			)>
		<tr><td id="subheader" class="locked" align="left"><cfoutput>#Application.PlannerLabel# Profile Settings</cfoutput></td></tr>
	</cfif>

	<cfoutput>
	<!---------------------->
	<!--- Planner Create --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "#Application.PlannerLabel# - Create">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD  align="right" nowrap>#_setting#</TD>
			<TD WIDTH="270" align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Create" value="1" id="Planner_Create_1" <cfif getSettingsManagerProfiles.Planner_Create EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Create" value="0" id="Planner_Create_0" <cfif getSettingsManagerProfiles.Planner_Create EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Create EQ 0> style="display:none"</cfif>>
			<TD WIDTH="275" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Create NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Planner_Create_Mass_2" NAME="Planner_Create" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','Planner_Create_Mass_2','2')" TITLE="Update all values for this row.">(+)</a></TD>

			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
					<INPUT NAME="Planner_Create_#counter#" TYPE="radio"  MASSUPDATEID="Planner_Create_Mass_2" ID="Planner_Create_#counter#" VALUE="2" onclick="checkview(#counter#);" <CFIF getProfiles.Planner_Create EQ 2>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Create NEQ 0>
					<CFIF evaluate("getProfiles.Planner_Create") EQ 2>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!----------------------->
	<!--- Planner - View  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "#Application.PlannerLabel# - View">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Create_View" value="1" id="Planner_Create_View_1" <cfif getSettingsManagerProfiles.Planner_Create_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Create_View" value="0" id="Planner_Create_View_0" <cfif getSettingsManagerProfiles.Planner_Create_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Create_View EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Create_View NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Planner_Create_Mass_1"  NAME="Planner_Create" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','Planner_Create_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="Planner_Create_#counter#" TYPE="radio"  MASSUPDATEID="Planner_Create_Mass_1" ID="Planner_Create_#counter#" VALUE="1" onclick="checkview(#counter#);" <CFIF getProfiles.Planner_Create EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Create_View NEQ 0>
					<CFIF evaluate("getProfiles.Planner_Create") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Create_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!----------------------->
	<!--- Planner - None  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "#Application.PlannerLabel# - None">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Create_None" value="1" id="Planner_Create_None_1" <cfif getSettingsManagerProfiles.Planner_Create_None EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Create_None" value="0" id="Planner_Create_None_0" <cfif getSettingsManagerProfiles.Planner_Create_None EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Create_None EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Create_None NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Planner_Create_Mass_0"  NAME="Planner_Create" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','Planner_Create_Mass_0','0')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="Planner_Create_#counter#" TYPE="radio"  MASSUPDATEID="Planner_Create_Mass_0" ID="Planner_Create_#counter#" VALUE="0" onclick="checkview(#counter#);" <CFIF getProfiles.Planner_Create EQ 0>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Create_None NEQ 0>
					<CFIF evaluate("getProfiles.Planner_Create") EQ 0>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Create_None NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------->
	<!--- Planner - Reassign  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "#Application.PlannerLabel# - Reassign">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Reassign" value="1" id="Planner_Reassign_1" <cfif getSettingsManagerProfiles.Planner_Reassign EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Reassign" value="0" id="Planner_Reassign_0" <cfif getSettingsManagerProfiles.Planner_Reassign EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Reassign EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Reassign NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"><INPUT TYPE="checkbox" NAME="Planner_Reassign" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Planner_Reassign_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="Planner_Reassign_#counter#" TYPE="checkbox"  MASSUPDATEID="Planner_Reassign_Mass_1" ID="Planner_Reassign_#counter#" VALUE="1" onclick="checkview(#counter#);" <CFIF getProfiles.Planner_Reassign EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Reassign NEQ 0>
					<CFIF evaluate("getProfiles.Planner_Create") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Reassign NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Planner_Margin_View ---->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "View Margins">

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Margin_View" value="1" id="Planner_Margin_View_1" <cfif getSettingsManagerProfiles.Planner_Margin_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Margin_View" value="0" id="Planner_Margin_View_0" <cfif getSettingsManagerProfiles.Planner_Margin_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Margin_View EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Margin_View NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Planner_Margin_View" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Planner_Margin_View','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<cfset Counter = getProfiles.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Margin_View NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Planner_Margin_View_#counter#" NAME="Planner_Margin_View_#counter#"  MASSUPDATEID="Planner_Margin_View" VALUE="1"<CFIF getProfiles.Planner_Margin_View EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Margin_View NEQ 0>
					<CFIF evaluate("getProfiles.Planner_Margin_View") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Margin_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Planner Approval Rights ---->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "Approval Rights">
 	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Approval_Rights" value="1" id="Planner_Approval_Rights_1" <cfif getSettingsManagerProfiles.Planner_Approval_Rights EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Approval_Rights" value="0" id="Planner_Approval_Rights_0" <cfif getSettingsManagerProfiles.Planner_Approval_Rights EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Approval_Rights EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Approval_Rights NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Planner_Approval_Rights" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Planner_Approval_Rights','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<cfset Counter = getProfiles.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Approval_Rights NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Planner_Approval_Rights_#counter#" NAME="Planner_Approval_Rights_#counter#"  MASSUPDATEID="Planner_Approval_Rights" VALUE="1"<CFIF getProfiles.Planner_Approval_Rights EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Approval_Rights NEQ 0>
					<CFIF evaluate("getProfiles.Planner_Approval_Rights") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Approval_Rights NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>

	<cfif appSettings.get_Setting('Planner_Targets_Enabled') NEQ "1">

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Planner Max Total Spend ---->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
 	<cfset _setting = "#Application.PlannerLabel# Max Total Spend">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Max_Total_Spend" value="1" id="Planner_Max_Total_Spend_1" <cfif getSettingsManagerProfiles.Planner_Max_Total_Spend EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Max_Total_Spend" value="0" id="Planner_Max_Total_Spend_0" <cfif getSettingsManagerProfiles.Planner_Max_Total_Spend EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Max_Total_Spend EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Max_Total_Spend NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="Planner_Max_Total_Spend" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Planner_Max_Total_Spend','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<cfset Counter = getProfiles.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Max_Total_Spend NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" ID="Planner_Max_Total_Spend_#counter#" NAME="Planner_Max_Total_Spend_#counter#"  MASSUPDATEID="Planner_Max_Total_Spend"  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY# SIZE="5" VALUE="#getProfiles.Planner_Max_Total_Spend#" onkeyup="clenseTextBuffer(this, '02134567890')"></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Max_Total_Spend NEQ 0>
					<cf_toFile fname="#fName#" data=",#getProfiles.Planner_Max_Total_Spend#">
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Max_Total_Spend NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>


	<cfelse>


	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Planner Target Approval $ ---->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "#Application.PlannerLabel# Target - Approval $">
 	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Target_Approval_Dollar" value="1" id="Planner_Target_Approval_Dollar_1" <cfif getSettingsManagerProfiles.Planner_Target_Approval_Dollar EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Target_Approval_Dollar" value="0" id="Planner_Target_Approval_Dollar_0" <cfif getSettingsManagerProfiles.Planner_Target_Approval_Dollar EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Target_Approval_Dollar EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Approval_Dollar NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="Planner_Target_Approval_Dollar" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Planner_Target_Approval_Dollar','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<cfset Counter = getProfiles.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Approval_Dollar NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" ID="Planner_Target_Approval_Dollar_#counter#" NAME="Planner_Target_Approval_Dollar_#counter#"  MASSUPDATEID="Planner_Target_Approval_Dollar"  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY# SIZE="5" VALUE="#getProfiles.Planner_Target_Approval_Dollar#" onkeyup="clenseTextBuffer(this, '02134567890')"></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Approval_Dollar NEQ 0>
					<cf_toFile fname="#fName#" data=",#getProfiles.Planner_Target_Approval_Dollar#">
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Approval_Dollar NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Planner Target Max Overspend $ ---->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "#Application.PlannerLabel# Target - Max Overspend $">
 	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Target_Max_Overspend" value="1" id="Planner_Target_Max_Overspend_1" <cfif getSettingsManagerProfiles.Planner_Target_Max_Overspend EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Target_Max_Overspend" value="0" id="Planner_Target_Max_Overspend_0" <cfif getSettingsManagerProfiles.Planner_Target_Max_Overspend EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Target_Max_Overspend EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Max_Overspend NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="Planner_Target_Max_Overspend" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Planner_Target_Max_Overspend','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<cfset Counter = getProfiles.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Max_Overspend NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" ID="Planner_Target_Max_Overspend_#counter#" NAME="Planner_Target_Max_Overspend_#counter#"  MASSUPDATEID="Planner_Target_Max_Overspend"  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY# SIZE="5" VALUE="#getProfiles.Planner_Target_Max_Overspend#" onkeyup="clenseTextBuffer(this, '02134567890')"></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Max_Overspend NEQ 0>
					<cf_toFile fname="#fName#" data=",#getProfiles.Planner_Target_Max_Overspend#">
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Max_Overspend NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Max Slotting Target Increase ---->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cfset _setting = "Max Slotting Target Increase">
 	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Target_Max_Slotting_Target_Increase" value="1" id="Planner_Target_Max_Slotting_Target_Increase_1" <cfif getSettingsManagerProfiles.Planner_Target_Max_Slotting_Target_Increase EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Target_Max_Slotting_Target_Increase" value="0" id="Planner_Target_Max_Slotting_Target_Increase_0" <cfif getSettingsManagerProfiles.Planner_Target_Max_Slotting_Target_Increase EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Target_Max_Slotting_Target_Increase EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Max_Slotting_Target_Increase NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="Planner_Target_Max_Slotting_Target_Increase" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Planner_Target_Max_Slotting_Target_Increase','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<cfset Counter = getProfiles.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Max_Slotting_Target_Increase NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" ID="Planner_Target_Max_Slotting_Target_Increase_#counter#" NAME="Planner_Target_Max_Slotting_Target_Increase_#counter#"  MASSUPDATEID="Planner_Target_Max_Slotting_Target_Increase"  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY# SIZE="5" VALUE="#getProfiles.Planner_Target_Max_Slotting_Target_Increase#" onkeyup="clenseTextBuffer(this, '02134567890')"></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Max_Slotting_Target_Increase NEQ 0>
					<cf_toFile fname="#fName#" data=",#getProfiles.Planner_Target_Max_Slotting_Target_Increase#">
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Target_Max_Slotting_Target_Increase NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	</cfif>


<!--- ngt --->
	<!--- <cfset render_setting_1("View Margin %", "View_Margin_Percent", 1, "View_Margin_Percent")>
	<cfset render_setting_1("View Target NUC", "View_Target_NUC", 1, "View_Target_NUC")>
	<cfset render_setting_1("View NUC", "View_NUC", 1, "View_NUC")>
	<cfset render_setting_1("View Target NUC Var", "View_Target_NUC_Var", 1, "View_Target_NUC_Var")> --->


	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Marketing/Consumer Events - Create --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "Consumer Events - Create">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD  align="right" nowrap>#_setting#</TD>
			<TD WIDTH="270" align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Marketing_Events_Create" value="1" id="Marketing_Events_Create_1" <cfif getSettingsManagerProfiles.Marketing_Events_Create EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Marketing_Events_Create" value="0" id="Marketing_Events_Create_0" <cfif getSettingsManagerProfiles.Marketing_Events_Create EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Marketing_Events_Create EQ 0> style="display:none"</cfif>>
			<TD WIDTH="275" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Marketing_Events_Create NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Marketing_Events_Create_Mass_2" NAME="Marketing_Events_Create" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','Marketing_Events_Create_Mass_2','2')" TITLE="Update all values for this row.">(+)</a></TD>


			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
					<INPUT NAME="Marketing_Events_Create_#counter#" TYPE="radio"  MASSUPDATEID="Marketing_Events_Create_Mass_2" ID="Marketing_Events_Create_#counter#" VALUE="2" onclick="checkview(#counter#);" <CFIF getProfiles.Marketing_Events_Create EQ 2>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Marketing_Events_Create NEQ 0>
					<CFIF evaluate("getProfiles.Marketing_Events_Create") EQ 2>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Marketing_Events_Create NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Marketing/Consumer Events - View  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "Consumer Events - View">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Marketing_Events_Create_View" value="1" id="Marketing_Events_Create_View_1" <cfif getSettingsManagerProfiles.Marketing_Events_Create_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Marketing_Events_Create_View" value="0" id="Marketing_Events_Create_View_0" <cfif getSettingsManagerProfiles.Marketing_Events_Create_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Marketing_Events_Create_View EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Marketing_Events_Create_View NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Marketing_Events_Create_Mass_1"  NAME="Marketing_Events_Create" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','Marketing_Events_Create_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="Marketing_Events_Create_#counter#" TYPE="radio"  MASSUPDATEID="Marketing_Events_Create_Mass_1" ID="Marketing_Events_Create_#counter#" VALUE="1" onclick="checkview(#counter#);" <CFIF getProfiles.Marketing_Events_Create EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Marketing_Events_Create_View NEQ 0>
					<CFIF evaluate("getProfiles.Marketing_Events_Create") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Marketing_Events_Create_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Marketing/Consumer Events - None  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "Consumer Events - None">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Marketing_Events_Create_None" value="1" id="Marketing_Events_Create_None_1" <cfif getSettingsManagerProfiles.Marketing_Events_Create_None EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Marketing_Events_Create_None" value="0" id="Marketing_Events_Create_None_0" <cfif getSettingsManagerProfiles.Marketing_Events_Create_None EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Marketing_Events_Create_None EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Marketing_Events_Create_None NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Marketing_Events_Create_Mass_0"  NAME="Marketing_Events_Create" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','Marketing_Events_Create_Mass_0','0')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="Marketing_Events_Create_#counter#" TYPE="radio"  MASSUPDATEID="Marketing_Events_Create_Mass_0" ID="Marketing_Events_Create_#counter#" VALUE="0" onclick="checkview(#counter#);" <CFIF getProfiles.Marketing_Events_Create EQ 0>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Marketing_Events_Create_None NEQ 0>
					<CFIF evaluate("getProfiles.Marketing_Events_Create") EQ 0>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Marketing_Events_Create_None NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Consumer Calendar ---->
 	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "Consumer Calendar">
 	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Product_Calendar" value="1" id="Planner_Product_Calendar_1" <cfif getSettingsManagerProfiles.Planner_Product_Calendar EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Product_Calendar" value="0" id="Planner_Product_Calendar_0" <cfif getSettingsManagerProfiles.Planner_Product_Calendar EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Product_Calendar EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Product_Calendar NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Planner_Product_Calendar" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Planner_Product_Calendar','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<cfset Counter = getProfiles.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Product_Calendar NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Planner_Product_Calendar_#counter#" NAME="Planner_Product_Calendar_#counter#"  MASSUPDATEID="Planner_Product_Calendar" VALUE="1"<CFIF getProfiles.Planner_Product_Calendar EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Product_Calendar NEQ 0>
					<CFIF evaluate("getSettingsManagerProfiles.Planner_Product_Calendar") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Product_Calendar NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Strategic Guidelines ---->
 	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "Strategic Guidelines">
 	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Strategic_Guidelines" value="1" id="Planner_Strategic_Guidelines_1" <cfif getSettingsManagerProfiles.Planner_Strategic_Guidelines EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Strategic_Guidelines" value="0" id="Planner_Strategic_Guidelines_0" <cfif getSettingsManagerProfiles.Planner_Strategic_Guidelines EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Strategic_Guidelines EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Strategic_Guidelines NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Planner_Strategic_Guidelines" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Planner_Strategic_Guidelines','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<cfset Counter = getProfiles.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Strategic_Guidelines NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Planner_Strategic_Guidelines_#counter#" NAME="Planner_Strategic_Guidelines_#counter#"  MASSUPDATEID="Planner_Strategic_Guidelines" VALUE="1"<CFIF getProfiles.Planner_Strategic_Guidelines EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Strategic_Guidelines NEQ 0>
					<CFIF evaluate("getSettingsManagerProfiles.Planner_Strategic_Guidelines") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Strategic_Guidelines NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- NUC Targets - Create --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "NUC Targets - Create">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD  align="right" nowrap>#_setting#</TD>
			<TD WIDTH="270" align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="NUC_Targets_Create" value="1" id="NUC_Targets_Create_1" <cfif getSettingsManagerProfiles.NUC_Targets_Create EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="NUC_Targets_Create" value="0" id="NUC_Targets_Create_0" <cfif getSettingsManagerProfiles.NUC_Targets_Create EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.NUC_Targets_Create EQ 0> style="display:none"</cfif>>
			<TD WIDTH="275" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.NUC_Targets_Create NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="NUC_Targets_Create_Mass_2" NAME="NUC_Targets_Create" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','NUC_Targets_Create_Mass_2','2')" TITLE="Update all values for this row.">(+)</a></TD>


			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
					<INPUT NAME="NUC_Targets_Create_#counter#" TYPE="radio"  MASSUPDATEID="NUC_Targets_Create_Mass_2" ID="NUC_Targets_Create_#counter#" VALUE="2" onclick="checkview(#counter#);" <CFIF getProfiles.NUC_Targets_Create EQ 2>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.NUC_Targets_Create NEQ 0>
					<CFIF evaluate("getProfiles.NUC_Targets_Create") EQ 2>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.NUC_Targets_Create NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- NUC Targets - View  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "NUC Targets - View">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="NUC_Targets_Create_View" value="1" id="NUC_Targets_Create_View_1" <cfif getSettingsManagerProfiles.NUC_Targets_Create_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="NUC_Targets_Create_View" value="0" id="NUC_Targets_Create_View_0" <cfif getSettingsManagerProfiles.NUC_Targets_Create_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.NUC_Targets_Create_View EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.NUC_Targets_Create_View NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="NUC_Targets_Create_Mass_1"  NAME="NUC_Targets_Create" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','NUC_Targets_Create_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="NUC_Targets_Create_#counter#" TYPE="radio"  MASSUPDATEID="NUC_Targets_Create_Mass_1" ID="NUC_Targets_Create_#counter#" VALUE="1" onclick="checkview(#counter#);" <CFIF getProfiles.NUC_Targets_Create EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.NUC_Targets_Create_View NEQ 0>
					<CFIF evaluate("getProfiles.NUC_Targets_Create") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.NUC_Targets_Create_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- NUC Targets - None  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "NUC Targets - None">
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="NUC_Targets_Create_None" value="1" id="NUC_Targets_Create_None_1" <cfif getSettingsManagerProfiles.NUC_Targets_Create_None EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="NUC_Targets_Create_None" value="0" id="NUC_Targets_Create_None_0" <cfif getSettingsManagerProfiles.NUC_Targets_Create_None EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.NUC_Targets_Create_None EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.NUC_Targets_Create_None NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="NUC_Targets_Create_Mass_0"  NAME="NUC_Targets_Create" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','NUC_Targets_Create_Mass_0','0')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="NUC_Targets_Create_#counter#" TYPE="radio"  MASSUPDATEID="NUC_Targets_Create_Mass_0" ID="NUC_Targets_Create_#counter#" VALUE="0" onclick="checkview(#counter#);" <CFIF getProfiles.NUC_Targets_Create EQ 0>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.NUC_Targets_Create_None NEQ 0>
					<CFIF evaluate("getProfiles.NUC_Targets_Create") EQ 0>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.NUC_Targets_Create_None NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Read only catalog access ---->
 	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset _setting = "Read only catalog access">
 	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#_setting#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Catalog" value="1" id="Planner_Catalog_1" <cfif getSettingsManagerProfiles.Planner_Catalog EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planner_Catalog" value="0" id="Planner_Catalog_0" <cfif getSettingsManagerProfiles.Planner_Catalog EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planner_Catalog EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#_setting#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Catalog NEQ 0><cf_toFile fname="#fName#" data="#_setting#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Planner_Catalog" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Planner_Catalog','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<cfset Counter = getProfiles.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Catalog NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Planner_Catalog_#counter#" NAME="Planner_Catalog_#counter#"  MASSUPDATEID="Planner_Catalog" VALUE="1"<CFIF getProfiles.Planner_Catalog EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Catalog NEQ 0>
					<CFIF evaluate("getSettingsManagerProfiles.Planner_Catalog") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planner_Catalog NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
</cfoutput>
