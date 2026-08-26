<!---
	Name: deduction_access_rights.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		The file contains all deduction profile management logic.
	Usage:
		/settings/access_rights/access_rights_matrix.cfm
	Tip:
		See /settings/access_rights/access_rights_matrix.cfm for additional usage information.
IMPORTANT NOTE:
If you added a new setting to this file, please insert this new setting to Settings_List.sql accordingly.
--->

<!------
Query BB_Profiles_Settings to get the saved values
----->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />

<!--- Dev Note: drachala; D28010: Profile Setting modifications
			  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->

<cfif NOT isDefined("Deduction_User_Profile")> 
	<cfset Deduction_User_Profile = CreateObject("component", "components.settings.profiles.profile").getAllProfiles(profile_id=profile_id,UserSettingPanel=UserSetting.Settings_Panel)>
</cfif>
	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->

<!--- Dev Note: KAL; D7821 --->
<cfset DD_Status_Profile_Settings =  CreateObject("component", "components.settings.profiles.profile").getDD_Status_Settings(profile_id=profile_id,UserSettingPanel=UserSetting.Settings_Panel)>

<cfset useLakebaseForgetDD_Status_list = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_status")>
<cfif useLakebaseForgetDD_Status_list>
<cftry>
<cfset excludedStatusIDs = []>
<cfif application.returned_customer_setting.DD_Show_Rebill NEQ 1>
<cfset arrayAppend(excludedStatusIDs, 7)>
</cfif>
<cfif appSettings.getDDAllowNegativeAmountCredits() NEQ 1>
<cfset arrayAppend(excludedStatusIDs, 8)>
<cfset arrayAppend(excludedStatusIDs, 9)>
</cfif>
<cfif appSettings.getDD_Show_Delete() NEQ 1>
<cfset arrayAppend(excludedStatusIDs, 6)>
</cfif>
<cfset ddsParams = { "order" = "dd_status_order.asc" }>
<cfif arrayLen(excludedStatusIDs)>
<cfset ddsParams["dd_status_id"] = "not.in.(#arrayToList(excludedStatusIDs)#)">
</cfif>
<cfset getDD_Status_list = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_status", ddsParams)
)>
<cfcatch type="any">
<cfset useLakebaseForgetDD_Status_list = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForgetDD_Status_list><cfquery name="getDD_Status_list" datasource="#application.datasource#">
	Select DD_Status_ID, DD_Status_Description,Setting_Display_Value FROM DD_Status
	WHERE
	<CFIF application.returned_customer_setting.DD_Show_Rebill NEQ 1>
	DD_Status_ID <> 7 AND
	</CFIF>
	<CFIF appSettings.getDDAllowNegativeAmountCredits() NEQ 1>
	DD_Status_ID NOT IN (8,9) AND
	</CFIF>
	<cfif appSettings.getDD_Show_Delete() NEQ 1>
	DD_Status_ID <> 6 AND
	</cfif>
	1 = 1
ORDER BY DD_Status_Order
</cfquery>
</cfif>

<!--- End Note: KAL; D7821 --->

<SCRIPT LANGUAGE="JavaScript">


function disableDeductionElement(chObj,bEnable)
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

function DDAmountCheck(thisObj)
{
	var thisForm = thisObj.form;
	var cellOffset = -2;

	var itemIndex = thisObj.name.split("_");
	itemIndex = itemIndex[itemIndex.length-1];

	if(eval("thisForm.DD_Approve_" + itemIndex + ".checked") )
	{
		disableDeductionElement(eval("thisForm.DD_Approve_Amount_" + itemIndex), true);
	}
	else
	{
		disableDeductionElement(eval("thisForm.DD_Approve_Amount_" + itemIndex), false);
	}

}
</SCRIPT>

<cfparam name="fromSettings_management" default=0>
<cfparam name="saveToXl" default="no">
<cfparam name="fName" default="xl">

	<!--- write the header to XL --->
	<cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""><cf_toFile fname="#fName#" data="Deductions" nl="yes"></cfif>
	<!---
		64386:	'Deduction Profile Settings' header still visible when setting is set to 'Hide'/Anand Rao/28-Nov-2016
		Make sure to add new setting in the below if condition also.
	--->
	<cfif (	fromSettings_management EQ 1
			OR getSettingsManagerProfiles.DD_ACCESS_LEVEL NEQ 0
			OR getSettingsManagerProfiles.DD_ACCESS_LEVEL_View NEQ 0
			OR getSettingsManagerProfiles.DD_ACCESS_LEVEL_None NEQ 0
			OR getSettingsManagerProfiles.DD_Approve NEQ 0
			OR ((application.returned_customer_setting.DD_Show_Rebill EQ 1 OR appSettings.getIntegrated_Rebill() EQ 1) AND getSettingsManagerProfiles.DD_Approve_Rebill EQ 1)
			OR getSettingsManagerProfiles.DD_Approve_Amount NEQ 0
			OR (application.returned_customer_setting.DD_Show_Rebill EQ 1 AND getSettingsManagerProfiles.DD_Open_Rebill_Transfer EQ 1)
			OR getSettingsManagerProfiles.DD_Reassign_Access NEQ 0
			OR (appSettings.getDD_Show_Reject() EQ 1 AND getSettingsManagerProfiles.DD_Reject EQ 1)
			OR (appSettings.getDD_Show_Delete() EQ 1 AND getSettingsManagerProfiles.DD_Delete EQ 1)
			OR getSettingsManagerProfiles.DD_Internal_Notes NEQ 0
			OR getSettingsManagerProfiles.DD_Split NEQ 0
			OR (appSettings.getDD_Show_Edit_Customer_Num() EQ 1 AND getSettingsManagerProfiles.DD_Edit_Cust_RefNo EQ 1)
			OR getSettingsManagerProfiles.DD_RFA_Agreed NEQ 0
			OR getSettingsManagerProfiles.DD_Disable_Inv_Link NEQ 0
			OR getDD_Status_list.Setting_Display_Value NEQ 0
			OR getSettingsManagerProfiles.DD_Search_By_Analyst NEQ 0
			OR getSettingsManagerProfiles.DD_Match_Central NEQ 0
			OR getSettingsManagerProfiles.DD_New_From_Open NEQ 0
			OR getSettingsManagerProfiles.DD_Reopen NEQ 0
			OR getSettingsManagerProfiles.DD_Match_Central_Write_Off_Amount NEQ 0
			OR getSettingsManagerProfiles.DD_Non_Trade_Tolerance NEQ 0
 		 )>
		<tr><td id="subheader" class="locked" align="left">Deduction Profile Settings</td></tr>
	</cfif>
	<cfoutput>
		<!--- Start view only and none code access level code --->
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right"  nowrap>View & Edit</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_ACCESS_LEVEL" value="1" id="DD_ACCESS_LEVEL_1" id="DD_ACCESS_LEVEL_1" <cfif getSettingsManagerProfiles.DD_ACCESS_LEVEL EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_ACCESS_LEVEL" value="0" id="DD_ACCESS_LEVEL_0" id="DD_ACCESS_LEVEL_0" <cfif getSettingsManagerProfiles.DD_ACCESS_LEVEL EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_ACCESS_LEVEL EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>View & Edit</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ACCESS_LEVEL NEQ 0><cf_toFile fname="#fName#" data="View & Edit"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="DD_ACCESS_LEVEL_Mass_2" NAME="DD_ACCESS_LEVEL" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','DD_ACCESS_LEVEL_Mass_2','2')" TITLE="Update all values for this row.">(+)</a></TD>
			<cfloop query="Deduction_User_Profile"><cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="DD_ACCESS_LEVEL_#Counter#" MASSUPDATEID="DD_ACCESS_LEVEL_Mass_2" VALUE="2"<CFIF evaluate("Deduction_User_Profile.DD_ACCESS_LEVEL") EQ 2> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ACCESS_LEVEL NEQ 0>
					<CFIF evaluate("Deduction_User_Profile.DD_ACCESS_LEVEL") EQ 2>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ACCESS_LEVEL NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>View</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_ACCESS_LEVEL_View" value="1" id="DD_ACCESS_LEVEL_View_1" id="DD_ACCESS_LEVEL_View_1" <cfif getSettingsManagerProfiles.DD_ACCESS_LEVEL_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_ACCESS_LEVEL_View" value="0" id="DD_ACCESS_LEVEL_View_0" id="DD_ACCESS_LEVEL_View_0" <cfif getSettingsManagerProfiles.DD_ACCESS_LEVEL_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_ACCESS_LEVEL_View EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>View</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ACCESS_LEVEL_View NEQ 0><cf_toFile fname="#fName#" data="View"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="DD_ACCESS_LEVEL_Mass_1" NAME="DD_ACCESS_LEVEL" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','DD_ACCESS_LEVEL_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<cfloop query="Deduction_User_Profile"><cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="DD_ACCESS_LEVEL_#Counter#" MASSUPDATEID="DD_ACCESS_LEVEL_Mass_1" VALUE="1"<CFIF evaluate("Deduction_User_Profile.DD_ACCESS_LEVEL") EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ACCESS_LEVEL_View NEQ 0>
					<CFIF evaluate("Deduction_User_Profile.DD_ACCESS_LEVEL") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ACCESS_LEVEL_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>None</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_ACCESS_LEVEL_None" value="1" id="DD_ACCESS_LEVEL_None_1" id="DD_ACCESS_LEVEL_None_1" <cfif getSettingsManagerProfiles.DD_ACCESS_LEVEL_None EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_ACCESS_LEVEL_None" value="0" id="DD_ACCESS_LEVEL_None_0" id="DD_ACCESS_LEVEL_None_0" <cfif getSettingsManagerProfiles.DD_ACCESS_LEVEL_None EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_ACCESS_LEVEL_None EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>None</TD><cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ACCESS_LEVEL_None NEQ 0><cf_toFile fname="#fName#" data="None"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="DD_ACCESS_LEVEL_Mass_0" NAME="DD_ACCESS_LEVEL" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','DD_ACCESS_LEVEL_Mass_0','0')" TITLE="Update all values for this row.">(+)</a></TD>
			<cfloop query="Deduction_User_Profile"><cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="DD_ACCESS_LEVEL_#Counter#"  MASSUPDATEID="DD_ACCESS_LEVEL_Mass_0" VALUE="0"<CFIF evaluate("Deduction_User_Profile.DD_ACCESS_LEVEL") EQ 0> CHECKED</CFIF> <!--- onpropertychange="changeDisableOtherCheckBoxes(this, this.form.DD_ACCESS_LEVEL_#i#, 1);"--->  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ACCESS_LEVEL_None NEQ 0>
					<CFIF evaluate("Deduction_User_Profile.DD_ACCESS_LEVEL") EQ 0>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ACCESS_LEVEL_None NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
		<!--- End View Only and None Code Access Level Code --->
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Approve</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Approve" value="1" id="DD_Approve_1" id="DD_Approve_1" <cfif getSettingsManagerProfiles.DD_Approve EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Approve" value="0" id="DD_Approve_0" id="DD_Approve_0" <cfif getSettingsManagerProfiles.DD_Approve EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Approve EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Approve</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Approve NEQ 0><cf_toFile fname="#fName#" data="Approve"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Approve" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Approve','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="DD_Approve_#counter#" NAME="DD_Approve_#counter#"  MASSUPDATEID="DD_Approve" VALUE="1"<CFIF Deduction_User_Profile.DD_Approve EQ 1> CHECKED</CFIF> onClick="javaScript:DDAmountCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Approve NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Approve") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Approve NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
	    <CFIF (application.returned_customer_setting.DD_Show_Rebill EQ 1 OR appSettings.getIntegrated_Rebill() EQ 1)>
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Allow Rebill</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Approve_Rebill" value="1" id="DD_Approve_Rebill_1" <cfif getSettingsManagerProfiles.DD_Approve_Rebill EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Approve_Rebill" value="0" id="DD_Approve_Rebill_0" <cfif getSettingsManagerProfiles.DD_Approve_Rebill EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Approve_Rebill EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Allow Rebill</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Approve_Rebill NEQ 0><cf_toFile fname="#fName#" data="Allow Rebill"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Approve_Rebill" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Approve_Rebill','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="DD_Approve_Rebill_#counter#"  MASSUPDATEID="DD_Approve_Rebill" VALUE="1"<CFIF Deduction_User_Profile.DD_Approve_Rebill EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Approve_Rebill NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Approve_Rebill") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Approve_Rebill NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
	    </CFIF>
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Approve Amount</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Approve_Amount" value="1" id="DD_Approve_Amount_1" <cfif getSettingsManagerProfiles.DD_Approve_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Approve_Amount" value="0" id="DD_Approve_Amount_0" <cfif getSettingsManagerProfiles.DD_Approve_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.DD_Approve_Amount EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Approve Amount</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Approve_Amount NEQ 0><cf_toFile fname="#fName#" data="Approve Amount"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="DD_Approve_Amount" ID="DD_Approve_Amount" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','DD_Approve_Amount','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID> <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data=""></cfif>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="DD_Approve_Amount_#counter#" SIZE="5"  MASSUPDATEID="DD_Approve_Amount" VALUE="#Deduction_User_Profile.DD_Approve_Amount#" onkeyup="clenseTextBuffer(this, '02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Approve_Amount NEQ 0>
				<cf_toFile fname="#fName#" data= ",#Deduction_User_Profile.DD_Approve_Amount#">
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Approve_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
	    <CFIF application.returned_customer_setting.DD_Show_Rebill EQ 1>
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Rebill <=> Open</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Open_Rebill_Transfer" value="1" id="DD_Open_Rebill_Transfer_1" <cfif getSettingsManagerProfiles.DD_Open_Rebill_Transfer EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Open_Rebill_Transfer" value="0" id="DD_Open_Rebill_Transfer_0" <cfif getSettingsManagerProfiles.DD_Open_Rebill_Transfer EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Open_Rebill_Transfer EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Rebill <=> Open</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Open_Rebill_Transfer NEQ 0><cf_toFile fname="#fName#" data="Rebill <=> Open"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Open_Rebill_Transfer" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Open_Rebill_Transfer','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="DD_Open_Rebill_Transfer_#counter#"  MASSUPDATEID="DD_Open_Rebill_Transfer" VALUE="1"<CFIF Deduction_User_Profile.DD_Open_Rebill_Transfer EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Open_Rebill_Transfer NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Open_Rebill_Transfer") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Open_Rebill_Transfer NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
	    </CFIF>
	    <cfif appSettings.getDD_Show_reassign()>
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Reassign Deductions</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Reassign_Access" value="1" id="DD_Reassign_Access_1" <cfif getSettingsManagerProfiles.DD_Reassign_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Reassign_Access" value="0" id="DD_Reassign_Access_0" <cfif getSettingsManagerProfiles.DD_Reassign_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Reassign_Access EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Reassign Deductions</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Reassign_Access NEQ 0><cf_toFile fname="#fName#" data="Reassign Deductions"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Reassign_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Reassign_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Reassign_Access NEQ 0><cf_toFile fname="#fName#" data=""></cfif>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="DD_Reassign_Access_#counter#" NAME="DD_Reassign_Access_#counter#"  MASSUPDATEID="DD_Reassign_Access" VALUE="1"<CFIF Deduction_User_Profile.DD_Reassign_Access EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Reassign_Access NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Reassign_Access") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Reassign_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
	    </cfif>
		<!--- Dev Note: KAL; D8047 --->
	    <cfif appSettings.getDD_Show_Reject()>
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Reject Deductions</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Reject" value="1" id="DD_Reject_1" <cfif getSettingsManagerProfiles.DD_Reject EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Reject" value="0" id="DD_Reject_0" <cfif getSettingsManagerProfiles.DD_Reject EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Reject EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Reject Deductions</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Reject NEQ 0><cf_toFile fname="#fName#" data="Reject Deductions"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Reject" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Reject','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="DD_Reject_#counter#" NAME="DD_Reject_#counter#"  MASSUPDATEID="DD_Reject" VALUE="1"<CFIF Deduction_User_Profile.DD_Reject EQ 1> CHECKED</CFIF>  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Reject NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Reject") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
		<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Reject NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
	    </cfif>
		<!--- End Note: KAL; D8047 --->
	    <cfif appSettings.getDD_Show_Delete()>
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Delete/Undelete Deductions</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Delete" value="1" id="DD_Delete_1" <cfif getSettingsManagerProfiles.DD_Delete EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Delete" value="0" id="DD_Delete_0" <cfif getSettingsManagerProfiles.DD_Delete EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Delete EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Delete/Undelete Deductions</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Delete NEQ 0><cf_toFile fname="#fName#" data="Delete/Undelete Deductions"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Delete" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Delete','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="DD_Delete_#counter#" NAME="DD_Delete_#counter#"  MASSUPDATEID="DD_Delete" VALUE="1"<CFIF Deduction_User_Profile.DD_Delete EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Delete NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Delete") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Delete NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
	    </cfif>
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Internal #stDeductionLabels["Action"]# Notes</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Internal_Notes" value="1" id="DD_Internal_Notes_1" <cfif getSettingsManagerProfiles.DD_Internal_Notes EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Internal_Notes" value="0" id="DD_Internal_Notes_0" <cfif getSettingsManagerProfiles.DD_Internal_Notes EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Internal_Notes EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Internal #stDeductionLabels["Action"]# Notes</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Internal_Notes NEQ 0><cf_toFile fname="#fName#" data="Internal #stDeductionLabels["Action"]# Notes"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Internal_Notes" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Internal_Notes','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="DD_Internal_Notes_#counter#" NAME="DD_Internal_Notes_#counter#"  MASSUPDATEID="DD_Internal_Notes" VALUE="1"<CFIF Deduction_User_Profile.DD_Internal_Notes EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Internal_Notes NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Internal_Notes") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
		<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Internal_Notes NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Split Deductions</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Split" value="1" id="DD_Split_1" <cfif getSettingsManagerProfiles.DD_Split EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Split" value="0" id="DD_Split_0" <cfif getSettingsManagerProfiles.DD_Split EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Split EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Split Deductions</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Split NEQ 0><cf_toFile fname="#fName#" data="Split Deductions"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Split" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Split','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="DD_Split_#counter#" NAME="DD_Split_#counter#"  MASSUPDATEID="DD_Split" VALUE="1"<CFIF Deduction_User_Profile.DD_Split EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Split NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Split") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Split NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
	    <cfif appSettings.getDD_Show_Edit_Customer_Num()>
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Edit #stDeductionLabels["Customer Reference"]#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Edit_Cust_RefNo" value="1" id="DD_Edit_Cust_RefNo_1" <cfif getSettingsManagerProfiles.DD_Edit_Cust_RefNo EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Edit_Cust_RefNo" value="0" id="DD_Edit_Cust_RefNo_0" <cfif getSettingsManagerProfiles.DD_Edit_Cust_RefNo EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Edit_Cust_RefNo EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Edit #stDeductionLabels["Customer Reference"]#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Edit_Cust_RefNo NEQ 0><cf_toFile fname="#fName#" data="Edit #stDeductionLabels["Customer Reference"]#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Edit_Cust_RefNo" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Edit_Cust_RefNo','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="DD_Edit_Cust_RefNo_#counter#" NAME="DD_Edit_Cust_RefNo_#counter#"  MASSUPDATEID="DD_Edit_Cust_RefNo" VALUE="1"<CFIF Deduction_User_Profile.DD_Edit_Cust_RefNo EQ 1> CHECKED</CFIF>  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Edit_Cust_RefNo NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Edit_Cust_RefNo") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Edit_Cust_RefNo NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
	    </cfif>
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>RFA scorecard - Agreed / Display all</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_RFA_Agreed" value="1" id="DD_RFA_Agreed_1" <cfif getSettingsManagerProfiles.DD_RFA_Agreed EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_RFA_Agreed" value="0" id="DD_RFA_Agreed_0" <cfif getSettingsManagerProfiles.DD_RFA_Agreed EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_RFA_Agreed EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>RFA scorecard - Agreed</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_RFA_Agreed NEQ 0><cf_toFile fname="#fName#" data="RFA scorecard - Agreed"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="DD_RFA_Agreed_Mass_1" NAME="DD_RFA_Agreed" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','DD_RFA_Agreed_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<CFSET counter=Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#"><INPUT TYPE="Radio" NAME="DD_RFA_Agreed_#counter#" MASSUPDATEID="DD_RFA_Agreed_Mass_1" VALUE="1" <CFIF Deduction_User_Profile.DD_RFA_Agreed EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>			<!--- <CFIF Billback_User_Profile.BB_Approve_Critical EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);" --->
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_RFA_Agreed NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_RFA_Agreed") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_RFA_Agreed NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    <TR <cfif getSettingsManagerProfiles.DD_RFA_Agreed EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>RFA scorecard - Display all</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_RFA_Agreed NEQ 0><cf_toFile fname="#fName#" data="RFA scorecard - Display all"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="DD_RFA_Agreed_Mass_0" NAME="DD_RFA_Agreed" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','DD_RFA_Agreed_Mass_0','0')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<CFSET counter=Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#"><INPUT TYPE="Radio" NAME="DD_RFA_Agreed_#counter#" MASSUPDATEID="DD_RFA_Agreed_Mass_0" VALUE="0" <CFIF Deduction_User_Profile.DD_RFA_Agreed EQ 0>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>	<!--- <CFIF Billback_User_Profile.BB_Approve_Critical EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);" --->
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_RFA_Agreed NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_RFA_Agreed") EQ 0>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_RFA_Agreed NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
	    <cfif appSettings.getDD_Show_Invoices()>
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Disable Invoice Link</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Disable_Inv_Link" value="1" id="DD_Disable_Inv_Link_1" <cfif getSettingsManagerProfiles.DD_Disable_Inv_Link EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Disable_Inv_Link" value="0" id="DD_Disable_Inv_Link_0" <cfif getSettingsManagerProfiles.DD_Disable_Inv_Link EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
	    	<TR <cfif getSettingsManagerProfiles.DD_Disable_Inv_Link EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Disable Invoice Link</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Disable_Inv_Link NEQ 0><cf_toFile fname="#fName#" data="Disable Invoice Link"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="DD_Disable_Inv_Link" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DD_Disable_Inv_Link','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="DD_Disable_Inv_Link_#counter#" NAME="DD_Disable_Inv_Link_#counter#" MASSUPDATEID="DD_Disable_Inv_Link" VALUE="1"<CFIF Deduction_User_Profile.DD_Disable_Inv_Link EQ 1> CHECKED</CFIF>  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Disable_Inv_Link NEQ 0>
				<CFIF evaluate("Deduction_User_Profile.DD_Disable_Inv_Link") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Disable_Inv_Link NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
	    </cfif>
		<!--- Dev Note: KAL; D7821 --->
	    <cfloop query="getDD_Status_list">
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Hide #DD_Status_Description#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Status_#DD_Status_ID#" value="1" id="DD_Status_#DD_Status_ID#_1" <cfif getDD_Status_list.Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Status_#DD_Status_ID#" value="0" id="DD_Status_#DD_Status_ID#_0" <cfif getDD_Status_list.Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getDD_Status_list.Setting_Display_Value EQ 0> style="display:none"</cfif>>

			<cfset Description = DD_Status_Description />
			<cfset Status_number = DD_Status_ID />



				<!--- Dev Note: drachala; D28010: Profile Setting modifications
				What For: Check weather user selected any profiles if so Added a contdition in WHERE.
				--->

			<cfquery name="DD_Status_Settings_From_Qry" dbtype="query">
				Select *
				from DD_Status_Profile_Settings
				where DD_Status_Profile_Settings.DD_Status_ID = #Status_number#
				<cfif isdefined("profile_id") and len(profile_id)>
				AND Profiles_ID IN( <cfqueryparam value="#profile_id#" cfsqltype="CF_SQL_INTEGER" list="yes"	/>	)
				</cfif>
			</cfquery>



			<TD WIDTH="195" id="locked" class="locked" nowrap>Hide #Description#</TD> <cfif saveToXl is "yes" and getDD_Status_list.Setting_Display_Value NEQ 0><cf_toFile fname="#fName#" data="Hide #Description#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Hide_#Status_number#" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Hide_#Status_number#','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<cfloop query="DD_Status_Settings_From_Qry">
				<cfset Counter = DD_Status_Settings_From_Qry.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap title="Hide #Description#"><INPUT TYPE="checkbox" ID="Hide_#Status_number#_#counter#" NAME="Hide_#Status_number#_#counter#"  MASSUPDATEID="Hide_#Status_number#" VALUE="1" <CFIF DD_Status_Settings_From_Qry.IS_Checked EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getDD_Status_list.Setting_Display_Value NEQ 0>
					<CFIF evaluate("DD_Status_Settings_From_Qry.IS_Checked") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</cfloop>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getDD_Status_list.Setting_Display_Value NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
	    </cfloop>
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Search DD by Analyst</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Search_By_Analyst" value="1" id="DD_Search_By_Analyst_1" <cfif getSettingsManagerProfiles.DD_Search_By_Analyst EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Search_By_Analyst" value="0" id="DD_Search_By_Analyst_0" <cfif getSettingsManagerProfiles.DD_Search_By_Analyst EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Search_By_Analyst EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Search DD by Analyst</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Search_By_Analyst NEQ 0><cf_toFile fname="#fName#" data="Search DD by Analyst"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
				<INPUT TYPE="checkbox" NAME="DD_Search_By_Analyst" VALUE="1">
				<a href="##"
					OnClick="javascript:massUpdate('checkbox','DD_Search_By_Analyst','1')"
					TITLE="Update all values for this row.">(+)</a>
			</TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap title="Search DD by Analyst">
					<INPUT TYPE="checkbox"
							ID="DD_Search_By_Analyst_#counter#"
							NAME="DD_Search_By_Analyst_#counter#"
							MASSUPDATEID="DD_Search_By_Analyst"
							VALUE="1"
								<CFIF Deduction_User_Profile.DD_Search_By_Analyst EQ 1>
									CHECKED
								</CFIF>
							MASSCONTROLID="massUpdateColumn_#counter#"
							#frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Search_By_Analyst NEQ 0>
					<CFIF Deduction_User_Profile.DD_Search_By_Analyst EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Search_By_Analyst NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
		<!--- End Note: KAL; D7821 End --->
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Match Central</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Match_Central" value="1" id="DD_Match_Central_1" <cfif getSettingsManagerProfiles.DD_Match_Central EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Match_Central" value="0" id="DD_Match_Central_0" <cfif getSettingsManagerProfiles.DD_Match_Central EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Match_Central EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Match Central</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Match_Central NEQ 0><cf_toFile fname="#fName#" data="Match Central"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
				<INPUT TYPE="checkbox" NAME="DD_Match_Central" VALUE="1">
				<a href="##"
					OnClick="javascript:massUpdate('checkbox','DD_Match_Central','1')"
					TITLE="Update all values for this row.">(+)</a>
			</TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap title="DD Match Central">
					<INPUT TYPE="checkbox"
							ID="DD_Match_Central_#counter#"
							NAME="DD_Match_Central_#counter#"
							MASSUPDATEID="DD_Match_Central"
							VALUE="1"
								<CFIF Deduction_User_Profile.DD_Match_Central EQ 1>
									CHECKED
								</CFIF>
							MASSCONTROLID="massUpdateColumn_#counter#"
							#frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Match_Central NEQ 0>
					<CFIF Deduction_User_Profile.DD_Match_Central EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Match_Central NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
		<!---  START: D43923: Ability to set deduction status to "New" from "Open" -- Profile control/Anand Rao/14-Jul-2014 --->
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Status To "New" From "Open"</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_New_From_Open" value="1" id="DD_New_From_Open_1" <cfif getSettingsManagerProfiles.DD_New_From_Open EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_New_From_Open" value="0" id="DD_New_From_Open_0" <cfif getSettingsManagerProfiles.DD_New_From_Open EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_New_From_Open EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Status To "New" From "Open"</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_New_From_Open NEQ 0><cf_toFile fname="#fName#" data="Change status to New from Open"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
				<INPUT TYPE="checkbox" NAME="DD_New_From_Open" VALUE="1">
				<a href="##"
					OnClick="javascript:massUpdate('checkbox','DD_New_From_Open','1')"
					TITLE="Update all values for this row.">(+)</a>
			</TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap title="DD Match Central">
					<INPUT TYPE="checkbox"
							ID="DD_New_From_Open_#counter#"
							NAME="DD_New_From_Open_#counter#"
							MASSUPDATEID="DD_New_From_Open"
							VALUE="1"
								<CFIF Deduction_User_Profile.DD_New_From_Open EQ 1>
									CHECKED
								</CFIF>
							MASSCONTROLID="massUpdateColumn_#counter#"
							#frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_New_From_Open NEQ 0>
					<CFIF Deduction_User_Profile.DD_New_From_Open EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_New_From_Open NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
<!---  END: D43923: Ability to set deduction status to "New" from "Open" -- Profile control/Aannd Rao/14-Jul-2014 --->
	<!---  START: D111888: Make ability to 'Reopen' Deductions a profile setting /Anand Rao/01-Dec-2021 --->
	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Reopen</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_ReOpen" value="1" id="DD_ReOpen_1" <cfif getSettingsManagerProfiles.DD_ReOpen EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_ReOpen" value="0" id="DD_ReOpen_0" <cfif getSettingsManagerProfiles.DD_ReOpen EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_ReOpen EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Reopen</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ReOpen NEQ 0><cf_toFile fname="#fName#" data="Change status to New from Open"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
				<INPUT TYPE="checkbox" NAME="DD_ReOpen" VALUE="1">
				<a href="##"
					OnClick="javascript:massUpdate('checkbox','DD_ReOpen','1')"
					TITLE="Update all values for this row.">(+)</a>
			</TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap title="DD Match Central">
					<INPUT TYPE="checkbox"
							ID="DD_ReOpen_#counter#"
							NAME="DD_ReOpen_#counter#"
							MASSUPDATEID="DD_ReOpen"
							VALUE="1"
								<CFIF Deduction_User_Profile.DD_ReOpen EQ 1>
									CHECKED
								</CFIF>
							MASSCONTROLID="massUpdateColumn_#counter#"
							#frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ReOpen NEQ 0>
					<CFIF Deduction_User_Profile.DD_ReOpen EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_ReOpen NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
	<!---  END: D111888: Make ability to 'Reopen' Deductions a profile setting/Aannd Rao/01-Dec-2021 --->

	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Match Central Write Off Amount</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Match_Central_Write_Off_Amount" value="1" id="DD_Match_Central_Write_Off_Amount_1" <cfif getSettingsManagerProfiles.DD_Match_Central_Write_Off_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Match_Central_Write_Off_Amount" value="0" id="DD_Match_Central_Write_Off_Amount_0" <cfif getSettingsManagerProfiles.DD_Match_Central_Write_Off_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Match_Central_Write_Off_Amount EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Match Central Write Off Amount</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Match_Central_Write_Off_Amount NEQ 0><cf_toFile fname="#fName#" data="Match Central Write Off Amount"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
				<INPUT TYPE="text"
						NAME="DD_Match_Central_Write_Off_Amount"
						ID="DD_Match_Central_Write_Off_Amount"
						SIZE="5"
						VALUE=""
						onkeyup="clenseTextBuffer(this, '02134567890')">
				<a href="##"
					OnClick="javascript:massUpdate('textbox','DD_Match_Central_Write_Off_Amount','1')"
					TITLE="Update all values for this row.">(+)</a>
			</TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap title="Search DD by Analyst">
					<INPUT TYPE="text"
							NAME="DD_Match_Central_Write_Off_Amount_#counter#"
							SIZE="5"
							MASSUPDATEID="DD_Match_Central_Write_Off_Amount"
							VALUE="#Deduction_User_Profile.DD_Match_Central_Write_Off_Amount#"
							onkeyup="clenseTextBuffer(this, '02134567890')"
							MASSCONTROLID="massUpdateColumn_#counter#"
							#frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Match_Central_Write_Off_Amount NEQ 0>
					<CFIF Deduction_User_Profile.DD_Match_Central_Write_Off_Amount EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Match_Central_Write_Off_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>

<!--- Dev Note: drachala; D29481: Non trade deductions  START
Added/Changed: Added This new Setting to Deductions--->

	    <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Non Trade Tolerance </TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Non_Trade_Tolerance" value="1" id="DD_Non_Trade_Tolerance_1" <cfif getSettingsManagerProfiles.DD_Non_Trade_Tolerance EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="DD_Non_Trade_Tolerance" value="0" id="DD_Non_Trade_Tolerance_0" <cfif getSettingsManagerProfiles.DD_Non_Trade_Tolerance EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	    <cfelse>
		<TR <cfif getSettingsManagerProfiles.DD_Non_Trade_Tolerance EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Non Trade Tolerance</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Non_Trade_Tolerance NEQ 0><cf_toFile fname="#fName#" data="Non Trade Tolerance"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
				<INPUT TYPE="text"
						NAME="DD_Non_Trade_Tolerance"
						ID="DD_Non_Trade_Tolerance"
						SIZE="5"
						VALUE=""
						onkeyup="clenseTextBuffer(this, '02134567890')">
				<a href="##"
					OnClick="javascript:massUpdate('textbox','DD_Non_Trade_Tolerance','1')"
					TITLE="Update all values for this row.">(+)</a>
			</TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap title="Search DD by Analyst">
					<INPUT TYPE="text"
							NAME="DD_Non_Trade_Tolerance_#counter#"
							SIZE="5"
							MASSUPDATEID="DD_Non_Trade_Tolerance"
							VALUE="#Deduction_User_Profile.DD_Non_Trade_Tolerance#"
							onkeyup="clenseTextBuffer(this, '02134567890')"
							MASSCONTROLID="massUpdateColumn_#counter#"
							#frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Non_Trade_Tolerance NEQ 0>
					<CFIF Deduction_User_Profile.DD_Non_Trade_Tolerance EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DD_Non_Trade_Tolerance NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	    </cfif>
	    <!--- End Dev Note: drachala; D29481: Non trade deductions  --->
<!--- 
<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Search Customer Invoice </TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Search_Customer_Invoice" value="1" id="Search_Customer_Invoice_1" <cfif getSettingsManagerProfiles.Search_Customer_Invoice EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Search_Customer_Invoice" value="0" id="Search_Customer_Invoice_0" <cfif getSettingsManagerProfiles.Search_Customer_Invoice EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
<cfelse>
		<TR <cfif getSettingsManagerProfiles.Search_Customer_Invoice EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Search Customer Invoice</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Customer_Invoice NEQ 0><cf_toFile fname="#fName#" data="Search Customer Invoice"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
				<INPUT TYPE="checkbox" NAME="Search_Customer_Invoice" VALUE="1">
				<a href="##" OnClick="javascript:massUpdate('checkbox','Search_Customer_Invoice','1')" TITLE="Update all values for this row.">(+)</a>
			</TD>
			<CFLOOP QUERY="Deduction_User_Profile">
			<cfset Counter = Deduction_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap title="Search Customer Invoice">
					<INPUT TYPE="checkbox" NAME="Search_Customer_Invoice_#counter#" ID="Search_Customer_Invoice_#counter#" SIZE="5"  MASSUPDATEID="Search_Customer_Invoice" VALUE="1" onkeyup="clenseTextBuffer(this, '02134567890')" 	MASSCONTROLID="massUpdateColumn_#counter#"
							<cfif Deduction_User_Profile.Search_Customer_Invoice EQ 1>CHECKED</cfif> #frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Customer_Invoice NEQ 0>
					<CFIF Deduction_User_Profile.Search_Customer_Invoice EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Customer_Invoice NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
</cfif> --->

</cfoutput>