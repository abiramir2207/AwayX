<!---
	Name: access_rights.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		The file contains all Billback profile management logic.
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

<cfif (appSettings.BB_DEVIATIONS_OVERRIDE_PRICE EQ 0)>
	<cfset appSetBBApproveExpRateLessTol = appSettings.BB_APPROVE_EXPECTED_RATE_LESS_TOLERANCE>
<cfelse>
	<cfset appSetBBApproveExpRateLessTol = 0 />
</cfif>

<cfparam name="fromSettings_management" default=0>

	<!--- Dev Note: drachala; D28010: Profile Setting modifications
				  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->

<cfset Billback_User_Profile = CreateObject("component", "components.settings.profiles.profile").getAllProfiles(profile_id=profile_id,UserSettingPanel=UserSetting.Settings_Panel)>
<cfset objSettingsService = CreateObject("component", "mvc.Models.SettingsService") />
<cfset Deduction_User_Profile = CreateObject("component", "components.settings.profiles.profile").getAllProfiles(profile_id=profile_id,UserSettingPanel=UserSetting.Settings_Panel)>

<!--- get BB Settings Info --->
<cfset qBillbackSettings = objSettingsService.getBillbackSettings()>

	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->


<cfset bShowAutoApproveAnalysis = 0>
<!--- If Auto approve is based on "bb closing method" --->
<cfif appSettings.getBBAutoApproveLogic() EQ 1>
	<!--- If billback settings allows to "auto approve" --->
	<cfif qBillbackSettings.Auto_Approve_CM_OFF eq 0>
		<cfset bShowAutoApproveAnalysis = 1>
	</cfif>
<cfelse>
	<!--- If billback settings allows to "auto approve".
	Note: Below column ("Auto_Approve_On") is a different table column than what is used above ("Auto_Approve_CM_OFF").
	--->
	<cfif qBillbackSettings.Auto_Approve_On EQ 1>
		<cfset bShowAutoApproveAnalysis = 1>
	</cfif>
</cfif>

<!--- 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] - Anand Rao/12-Jun-2018 --->
<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
<cfset qGetBSVar2Label		= LabelComp.getGeneralLabels('BS_Var_2') />

<cfif fromSettings_management neq 1>
<SCRIPT LANGUAGE="JavaScript">

function billbackCheckOnLoad(thisForm)
{
	<cfoutput>
	<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
		billbackCheck(thisForm.BB_Approve_#i#);
		billbackAmountCheck(thisForm.BB_Approve_#i#);
	</cfloop>
	</cfoutput>
}


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

function billbackCheck(thisObj)
{
	var thisForm = thisObj.form;
	var itemIndex = thisObj.name.split("_");
	itemIndex = itemIndex[itemIndex.length-1];

	if(eval("thisForm.BB_View_Deviation_" + itemIndex + ".checked"))
	{
		disableBillbackElement(eval("thisForm.BB_Approve_" + itemIndex), true);
		disableBillbackElement(eval("thisForm.BB_Approve_Critical_" + itemIndex), true);
	}
	else
	{
		disableBillbackElement(eval("thisForm.BB_Approve_" + itemIndex), false);
		disableBillbackElement(eval("thisForm.BB_Approve_Amount_" + itemIndex), false);
		disableBillbackElement(eval("thisForm.BB_Approve_Critical_" + itemIndex), false);
		disableBillbackElement(eval("thisForm.BB_Tot_Approve_Amount_" + itemIndex), false);
	}
}

function billbackAmountCheck(thisObj)
{
	var thisForm = thisObj.form;
	var itemIndex = thisObj.name.split("_");
	itemIndex = itemIndex[itemIndex.length-1];

	if(eval("thisForm.BB_Approve_" + itemIndex + ".checked") || eval("thisForm.BB_Approve_Critical_" + itemIndex + ".checked"))
	{
		disableBillbackElement(eval("thisForm.BB_Approve_Amount_" + itemIndex), true);
		disableBillbackElement(eval("thisForm.BB_Tot_Approve_Amount_" + itemIndex), true);
	}
	else
	{
		disableBillbackElement(eval("thisForm.BB_Approve_Amount_" + itemIndex), false);
		disableBillbackElement(eval("thisForm.BB_Tot_Approve_Amount_" + itemIndex), false);
	}

	/*
		D28359:BB Dev - user can only approve expected
		if the Approve button is checked enable the elements
	*/
	if(eval("thisForm.BB_Approve_" + itemIndex + ".checked"))
	{
		disableBillbackElement(eval("thisForm.BB_DevGrid_Expected_" + itemIndex), true);
		disableBillbackElement(eval("thisForm.BB_DevGrid_Claimed_" + itemIndex), true);
		disableBillbackElement(eval("thisForm.BB_DevGrid_Selected_" + itemIndex), true);
		<cfif (appSetBBApproveExpRateLessTol)>
			disableBillbackElement(eval("thisForm.BB_DevGrid_ELT_" + itemIndex), true);
		</cfif>
	}
	else
	{
		disableBillbackElement(eval("thisForm.BB_DevGrid_Expected_" + itemIndex), false);
		disableBillbackElement(eval("thisForm.BB_DevGrid_Claimed_" + itemIndex), false);
		disableBillbackElement(eval("thisForm.BB_DevGrid_Selected_" + itemIndex), false);
		<cfif (appSetBBApproveExpRateLessTol)>
			disableBillbackElement(eval("thisForm.BB_DevGrid_ELT_" + itemIndex), false);
		</cfif>

	}


	/*
	if(eval("thisForm.BB_Approve_Critical_" + itemIndex + ".checked"))
	{
		disableBillbackElement(eval("thisForm.BB_Approve_Critical_Amount_" + itemIndex), true);
	}
	else
	{
		disableBillbackElement(eval("thisForm.BB_Approve_Critical_Amount_" + itemIndex), false);
	}
	*/
}
</SCRIPT>
</cfif>
<cfparam name="saveToXl" default="no">
<cfparam name="fName" default="xl">



	<!--- write the header to XL --->
	<cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""><cf_toFile fname="#fName#" data="Billbacks" nl="yes"></cfif>
	<!---
		64386:	'Deduction Profile Settings' header still visible when setting is set to 'Hide'/Anand Rao/28-Nov-2016
		Make sure to add new setting in the below if condition also.
	--->
	<cfif ( fromSettings_management EQ 1
			OR getSettingsManagerProfiles.BB_Create NEQ 0
			OR getSettingsManagerProfiles.BB_Create_View NEQ 0
			OR getSettingsManagerProfiles.BB_Create_None NEQ 0
			OR getSettingsManagerProfiles.BB_View_Deviation NEQ 0
			OR getSettingsManagerProfiles.BB_Approve NEQ 0
			OR (getSettingsManagerProfiles.BB_Mass_Approve EQ 1) OR (getSettingsManagerProfiles.BB_Approve EQ 1)
			OR getSettingsManagerProfiles.BB_Approve_Amount NEQ 0
			OR getSettingsManagerProfiles.BB_Tot_Approve_Amount NEQ 0
			OR getSettingsManagerProfiles.BB_Pay_Req_Approval_Amount NEQ 0
			OR getSettingsManagerProfiles.Credit_Memo_Amount NEQ 0
			OR getSettingsManagerProfiles.BB_Approve_Critical NEQ 0
			OR getSettingsManagerProfiles.Approve_Last_Date_To_Claim NEQ 0
			OR getSettingsManagerProfiles.BB_closing_methods_view NEQ 0
			OR getSettingsManagerProfiles.BB_Delete NEQ 0
			OR (getSettingsManagerProfiles.BB_Mass_Delete EQ 1) OR (getSettingsManagerProfiles.BB_Delete EQ 1)
			OR (appSettings.getPullbacksOn() EQ 1 AND getSettingsManagerProfiles.BB_Apply_Pullback EQ 1)
			OR getSettingsManagerProfiles.BB_Apply_Pullback_Amount NEQ 0
			OR getSettingsManagerProfiles.BB_UnApply_Pullback NEQ 0
			OR (appSettings.getBudgetsFunctionalityOn() EQ 1 AND getSettingsManagerProfiles.Approve_BB_Beyond_Budget EQ 1)
			OR getSettingsManagerProfiles.BB_Reverse NEQ 0
			OR getSettingsManagerProfiles.Manual_Reject_Billback NEQ 0
			OR (appSettings.get_Setting('Manual_Void_Credit_Request') eq '1' AND getSettingsManagerProfiles.Void_Credit_Request EQ 1)
			OR getSettingsManagerProfiles.Autopay_Reverse NEQ 0
			OR getSettingsManagerProfiles.BB_Adjust NEQ 0
			OR getSettingsManagerProfiles.BB_Apply_Rebate_Rates NEQ 0
			OR (appsettings.Mass_Pay_Billback IS NOT 0 AND getSettingsManagerProfiles.Mass_Billback_Pay EQ 1)
			OR (appSettings.getBBAllowVendorMasterSearch() AND getSettingsManagerProfiles.BB_Allow_Vendor_Master_Search EQ 1)
			OR (appSettings.getdisableBBAddProgram() AND  getSettingsManagerProfiles.BB_Add_Program EQ 1)
			OR getSettingsManagerProfiles.BB_Add_Payee_Any_Position NEQ 0
			OR getSettingsManagerProfiles.BB_volume_override NEQ 0
			OR getSettingsManagerProfiles.BB_rate_override NEQ 0
			OR getSettingsManagerProfiles.BB_Search_By_Analyst NEQ 0
			OR getSettingsManagerProfiles.BB_Dev_Grid_Manual_Rate_Override_Check NEQ 0
			OR getSettingsManagerProfiles.View_BB_CRA_Analysis_Report NEQ 0
			OR getSettingsManagerProfiles.Change_BB_Start_End_Date1 NEQ 0
			OR getSettingsManagerProfiles.BB_Reassign NEQ 0
			OR (appSettings.get_Setting('Vendor_Batching') EQ '1' AND getSettingsManagerProfiles.Vendor_Hold_Research NEQ 0)
			OR getSettingsManagerProfiles.Display_BB_EDI_Download NEQ 0
			OR getSettingsManagerProfiles.Display_BB_User_Download NEQ 0
			OR getSettingsManagerProfiles.Display_BB_III_Party_Download NEQ 0
			OR (bShowAutoApproveAnalysis EQ 1 AND getSettingsManagerProfiles.Auto_Approve_Analysis EQ 1)
			OR (bShowAutoApproveAnalysis EQ 1 AND getSettingsManagerProfiles.Allow_RFA_With_Default_Program EQ 1)
			)>
		<tr><td id="subheader" class="locked" align="left">Billback Profile Settings</td></tr>
	</cfif>
	<cfoutput>
		<!---View and Create Billback--->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD  align="right" nowrap>View & Create</TD>
			<TD WIDTH="270" align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Create" value="1" id="BB_Create_1" <cfif getSettingsManagerProfiles.BB_Create EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Create" value="0" id="BB_Create_0" <cfif getSettingsManagerProfiles.BB_Create EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Create EQ 0> style="display:none"</cfif>>
			<TD WIDTH="275" id="locked" class="locked" nowrap>View & Create</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create NEQ 0><cf_toFile fname="#fName#" data="View & Create"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="BB_Create_Mass_1" NAME="BB_Create" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','BB_Create_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>


           <CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
				<INPUT NAME="BB_Create_#counter#" TYPE="radio"  MASSUPDATEID="BB_Create_Mass_1" ID="BB_Create_#counter#" VALUE="1" onclick="checkview(#counter#);" <CFIF Billback_User_Profile.BB_Create EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#>
			</TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Create") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

		<!---View Billback--->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>View Only</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Create_View" value="1" id="BB_Create_View_1" <cfif getSettingsManagerProfiles.BB_Create_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Create_View" value="0" id="BB_Create_View_0" <cfif getSettingsManagerProfiles.BB_Create_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Create_View EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>View Only</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create_View NEQ 0><cf_toFile fname="#fName#" data="View Only"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="BB_Create_Mass_2"  NAME="BB_Create" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','BB_Create_Mass_2','2')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="BB_Create_#counter#" TYPE="radio"  MASSUPDATEID="BB_Create_Mass_2" ID="BB_Create_#counter#" VALUE="2" onclick="checkview(#counter#);" <CFIF Billback_User_Profile.BB_Create EQ 2>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create_View NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Create") EQ 2>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
		<!---None--->

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>None</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Create_None" value="1" id="BB_Create_None_1" <cfif getSettingsManagerProfiles.BB_Create_None EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Create_None" value="0" id="BB_Create_None_0" <cfif getSettingsManagerProfiles.BB_Create_None EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Create_None EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>None</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create_None NEQ 0><cf_toFile fname="#fName#" data="None"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="BB_Create_Mass_0"  NAME="BB_Create" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','BB_Create_Mass_0','0')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="BB_Create_#counter#" TYPE="radio"  MASSUPDATEID="BB_Create_Mass_0" ID="BB_Create_#counter#" VALUE="0" onclick="checkview(#counter#);" <CFIF Billback_User_Profile.BB_Create EQ 0>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create_None NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Create") EQ 0>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Create_None NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>View Deviation</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_View_Deviation" value="1" id="BB_View_Deviation_1" <cfif getSettingsManagerProfiles.BB_View_Deviation EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_View_Deviation" value="0" id="BB_View_Deviation_0" <cfif getSettingsManagerProfiles.BB_View_Deviation EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_View_Deviation EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>View Deviation</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_View_Deviation NEQ 0><cf_toFile fname="#fName#" data="View Deviation"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_View_Deviation" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_View_Deviation','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_View_Deviation_#counter#"  MASSUPDATEID="BB_View_Deviation" NAME="BB_View_Deviation_#counter#" VALUE="1"<CFIF Billback_User_Profile.BB_View_Deviation EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_View_Deviation NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_View_Deviation") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_View_Deviation NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Approve</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Approve" value="1" id="BB_Approve_1" <cfif getSettingsManagerProfiles.BB_Approve EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Approve" value="0" id="BB_Approve_0" <cfif getSettingsManagerProfiles.BB_Approve EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Approve EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Approve<img src="/images/help_small.gif"
			Title="If the checkbox 'Sel'  is  selected, within the billback the user will have options to pay expected, claimed or manually entered values"/></TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Approve NEQ 0><cf_toFile fname="#fName#" data="Approve"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Approve" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Approve','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
				<INPUT TYPE="checkbox" NAME="BB_Approve_#counter#"  MASSUPDATEID="BB_Approve" VALUE="1"<CFIF Billback_User_Profile.BB_Approve EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);enable_disable(#counter#);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#><br><br>

				<table border="0" cellpadding="0" cellspacing = "0" width="80%">
					<tr>
						<td align="right" style="border:0px;">
							<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="checkbox" NAME="BB_DevGrid_Expected_#counter#" MASSUPDATEID="BB_DevGrid_Expected" VALUE="1"<CFIF Billback_User_Profile.BB_DevGrid_Expected EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);enable_disable(#counter#);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY# <CFIF Billback_User_Profile.BB_Approve NEQ 1>disabled</CFIF>>
						</td>
						<td style="border:0px;" title="Display Expected button in Dev Grid">
							&nbsp;Exp
						</td>
					</tr>
					<!---
						D28359 - Deviation Grid - don't consider volume, only can approve Expected $
						check to see if the bb_deviation_override_price appsetting is not ON, then use the bb_approve_expected_rate_less_tolerance is it is ON
					--->

					<cfif (appSetBBApproveExpRateLessTol)>
						<tr>
							<td align="right" style="border:0px;">
								<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="checkbox" NAME="BB_DevGrid_ELT_#counter#"  MASSUPDATEID="BB_DevGrid_ELT" VALUE="1"<CFIF Billback_User_Profile.BB_DevGrid_ELT EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);enable_disable(#counter#);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY# <CFIF Billback_User_Profile.BB_Approve NEQ 1>disabled</CFIF>></nobr>
							</td>
							<td style="border:0px;" title="Display Expected Less Tolerance button in Dev Grid">
								&nbsp;ELT
							</td>
						</tr>
					<cfelse>
							<input type="hidden" name="BB_DevGrid_ELT_#counter#" value="0" />
					</cfif>
					<tr>
						<td align="right" style="border:0px;">
							<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="checkbox" NAME="BB_DevGrid_Claimed_#counter#"  MASSUPDATEID="BB_DevGrid_Claimed" VALUE="1"<CFIF Billback_User_Profile.BB_DevGrid_Claimed EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);enable_disable(#counter#);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#  <CFIF Billback_User_Profile.BB_Approve NEQ 1> disabled</CFIF>>
						</td>
						<td style="border:0px;" title="Display Claimed button in Dev Grid">
							&nbsp;Clm
						</td>
					</tr>
					<tr>
						<td align="right" style="border:0px;">
							<nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT TYPE="checkbox" NAME="BB_DevGrid_Selected_#counter#"  MASSUPDATEID="BB_DevGrid_Selected" VALUE="1"<CFIF Billback_User_Profile.BB_DevGrid_Selected EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);enable_disable(#counter#);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#  <CFIF Billback_User_Profile.BB_Approve NEQ 1> disabled</CFIF>></nobr>
						</td>
						<td style="border:0px;" title="Display Selected button in Dev Grid">
							&nbsp;Sel
						</td>
					</tr>
				</table>
			</TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Approve NEQ 0>
				<cfif evaluate("Billback_User_Profile.BB_Approve") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>

			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Approve NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>


		</TR>


		<!--- This code writes the data into the excel file one at a time--->
		<!--- BB_DevGrid_Expected Field written to the Excel file--->
		<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_Expected NEQ 0><cf_toFile fname="#fName#" data="Expected"></cfif>
		<CFLOOP QUERY="Billback_User_Profile">
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_Expected NEQ 0>
				<cfif evaluate("Billback_User_Profile.BB_DevGrid_Expected") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
		</cfloop>
		<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_Expected NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		<!--- BB_DevGrid_ELT Field written to the Excel file--->
		<cfif (appSetBBApproveExpRateLessTol)>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_ELT NEQ 0><cf_toFile fname="#fName#" data="ELT"></cfif>
				<CFLOOP QUERY="Billback_User_Profile">
					<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_ELT NEQ 0>
						<cfif evaluate("Billback_User_Profile.BB_DevGrid_ELT") EQ 1>
							<cf_toFile fname="#fName#" data=",yes">
						<cfelse>
							<cf_toFile fname="#fName#" data=",no">
						</cfif>
					</cfif>
				</cfloop>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_ELT NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</cfif>
		<!--- BB_DevGrid_Claimed Field written to the Excel file--->
		<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_Claimed NEQ 0><cf_toFile fname="#fName#" data="Claimed"></cfif>
		<CFLOOP QUERY="Billback_User_Profile">
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_Claimed NEQ 0>
				<cfif evaluate("Billback_User_Profile.BB_DevGrid_Claimed") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
		</cfloop>
		<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_Claimed NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		<!--- BB_DevGrid_Selected Field written to the Excel file--->
		<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_Selected NEQ 0><cf_toFile fname="#fName#" data="Selected"></cfif>
		<CFLOOP QUERY="Billback_User_Profile">
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_Selected NEQ 0>
				<cfif evaluate("Billback_User_Profile.BB_DevGrid_Selected") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
		</cfloop>
		<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_DevGrid_Selected NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>





	</cfif>


	<!--- Dev Note: Drachala; D27781: 7.0 new bb profile settings --->
   <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Mass Approve Billback</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Mass_Approve" value="1" id="BB_Mass_Approve_1" <cfif getSettingsManagerProfiles.BB_Mass_Approve EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Mass_Approve" value="0" id="BB_Mass_Approve_0" <cfif getSettingsManagerProfiles.BB_Mass_Approve EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif (getSettingsManagerProfiles.BB_Mass_Approve EQ 0) OR (getSettingsManagerProfiles.BB_Approve EQ 0)> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Mass Approve Billback</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Mass_Approve NEQ 0><cf_toFile fname="#fName#" data="Mass Approve Billback"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >

			<INPUT TYPE="checkbox" NAME="BB_Mass_Approve" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Mass_Approve','1');" TITLE="Update all values for this row.">(+)</a></TD>


			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>

			<INPUT TYPE="checkbox" ID="BB_Mass_Approve_#counter#"  MASSUPDATEID="BB_Mass_Approve" NAME="BB_Mass_Approve_#counter#" VALUE="1"<CFIF Billback_User_Profile.BB_Mass_Approve EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#
			<CFIF Billback_User_Profile.BB_Approve EQ 1><cfelse>disabled</cfif>>

			</TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Mass_Approve NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Mass_Approve") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>

				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Mass_Approve NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
		<!--- Dev Note: Drachala; D27781: 7.0 new bb profile settings --->

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Approve Deviation Amount</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Approve_Amount" value="1" id="BB_Approve_Amount_1" <cfif getSettingsManagerProfiles.BB_Approve_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Approve_Amount" value="0" id="BB_Approve_Amount_0" <cfif getSettingsManagerProfiles.BB_Approve_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.BB_Approve_Amount EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Approve Deviation Amount</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Approve_Amount NEQ 0><cf_toFile fname="#fName#" data="Approve Deviation Amount"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="BB_Approve_Amount" ID="BB_Approve_Amount" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '*02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','BB_Approve_Amount','some text')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="BB_Approve_Amount_#counter#" SIZE="5"  MASSUPDATEID="BB_Approve_Amount" VALUE="#Billback_User_Profile.BB_Approve_Amount#" onkeyup="clenseTextBuffer(this, '*02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Approve_Amount NEQ 0>
				<cf_toFile fname="#fName#" data= ",#Billback_User_Profile.BB_Approve_Amount#">
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Approve_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Approve Total Amount</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Tot_Approve_Amount" value="1" id="BB_Tot_Approve_Amount_1" <cfif getSettingsManagerProfiles.BB_Tot_Approve_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Tot_Approve_Amount" value="0" id="BB_Tot_Approve_Amount_0" <cfif getSettingsManagerProfiles.BB_Tot_Approve_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.BB_Tot_Approve_Amount EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Approve Total Amount</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Tot_Approve_Amount NEQ 0><cf_toFile fname="#fName#" data="Approve Total Amount"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="BB_Tot_Approve_Amount" ID="BB_Tot_Approve_Amount" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '*02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','BB_Tot_Approve_Amount','some text')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="BB_Tot_Approve_Amount_#counter#" SIZE="5"  MASSUPDATEID="BB_Tot_Approve_Amount" VALUE="#Billback_User_Profile.BB_Tot_Approve_Amount#" onkeyup="clenseTextBuffer(this, '*02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Tot_Approve_Amount NEQ 0>
				<cf_toFile fname="#fName#" data= ",#Billback_User_Profile.BB_Tot_Approve_Amount#">
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Tot_Approve_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Pay.Req. Approval Amount</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Pay_Req_Approval_Amount" value="1" id="BB_Pay_Req_Approval_Amount_1" <cfif getSettingsManagerProfiles.BB_Pay_Req_Approval_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Pay_Req_Approval_Amount" value="0" id="BB_Pay_Req_Approval_Amount_0" <cfif getSettingsManagerProfiles.BB_Pay_Req_Approval_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.BB_Pay_Req_Approval_Amount EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Pay.Req. Approval Amount</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Pay_Req_Approval_Amount NEQ 0><cf_toFile fname="#fName#" data="Pay.Req. Approval Amount"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="BB_Pay_Req_Approval_Amount" ID="BB_Pay_Req_Approval_Amount" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '*02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','BB_Pay_Req_Approval_Amount','some text')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="BB_Pay_Req_Approval_Amount_#counter#"  MASSUPDATEID="BB_Pay_Req_Approval_Amount" SIZE="5" VALUE="#Billback_User_Profile.BB_Pay_Req_Approval_Amount#" onkeyup="clenseTextBuffer(this, '*02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Pay_Req_Approval_Amount NEQ 0>
				<cf_toFile fname="#fName#" data= ",#Billback_User_Profile.BB_Pay_Req_Approval_Amount#">
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Pay_Req_Approval_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Credit Memo Amount</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Credit_Memo_Amount" value="1" id="Credit_Memo_Amount_1" <cfif getSettingsManagerProfiles.Credit_Memo_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Credit_Memo_Amount" value="0" id="Credit_Memo_Amount_0" <cfif getSettingsManagerProfiles.Credit_Memo_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Credit_Memo_Amount EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Credit Memo Amount</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Credit_Memo_Amount NEQ 0><cf_toFile fname="#fName#" data="Credit Memo Amount"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="Credit_Memo_Amount" ID="Credit_Memo_Amount" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '*02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Credit_Memo_Amount','some text')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="Credit_Memo_Amount_#counter#"  MASSUPDATEID="Credit_Memo_Amount" SIZE="5" VALUE="#Billback_User_Profile.Credit_Memo_Amount#" onkeyup="clenseTextBuffer(this, '*02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Credit_Memo_Amount NEQ 0>
				<cf_toFile fname="#fName#" data= ",#Billback_User_Profile.Credit_Memo_Amount#">
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Credit_Memo_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Approve Critical</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Approve_Critical" value="1" id="BB_Approve_Critical_1" <cfif getSettingsManagerProfiles.BB_Approve_Critical EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Approve_Critical" value="0" id="BB_Approve_Critical_0" <cfif getSettingsManagerProfiles.BB_Approve_Critical EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Approve_Critical EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Approve Critical</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Approve_Critical NEQ 0><cf_toFile fname="#fName#" data="Approve Critical"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Approve_Critical" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Approve_Critical','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#"><INPUT TYPE="checkbox" NAME="BB_Approve_Critical_#counter#"  MASSUPDATEID="BB_Approve_Critical" VALUE="1"<CFIF Billback_User_Profile.BB_Approve_Critical EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Approve_Critical NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Approve_Critical") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Approve_Critical NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<!---last date to claim rights--->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Approve Last Date To Claim</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Approve_Last_Date_To_Claim" value="1" id="Approve_Last_Date_To_Claim_1" <cfif getSettingsManagerProfiles.Approve_Last_Date_To_Claim EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Approve_Last_Date_To_Claim" value="0" id="Approve_Last_Date_To_Claim_0" <cfif getSettingsManagerProfiles.Approve_Last_Date_To_Claim EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Approve_Last_Date_To_Claim EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Approve Last Date To Claim</TD>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Last_Date_To_Claim" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Last_Date_To_Claim','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Last_Date_To_Claim NEQ 0><cf_toFile fname="#fName#" data="Approve Last Date To Claim"></cfif>
			<CFLOOP QUERY="Billback_User_Profile">
				<CFSET counter=Billback_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#">
					<INPUT TYPE="checkbox" NAME="Approve_Last_Date_To_Claim_#counter#"  MASSUPDATEID="Approve_Last_Date_To_Claim" VALUE="1"<CFIF Billback_User_Profile.Approve_Last_Date_To_Claim EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Last_Date_To_Claim NEQ 0>
					<CFIF evaluate("Billback_User_Profile.Approve_Last_Date_To_Claim") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Last_Date_To_Claim NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

<!--- Dev Note: Drachala; D27781 : new bb profile settings --->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD  align="right" nowrap>Billback Closing Methods List</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_closing_methods_view" value="1" id="BB_closing_methods_view_1" <cfif getSettingsManagerProfiles.BB_closing_methods_view EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_closing_methods_view" value="0" id="BB_closing_methods_view_0" <cfif getSettingsManagerProfiles.BB_closing_methods_view EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
			<TR <cfif getSettingsManagerProfiles.BB_closing_methods_view EQ 0> style="display:none"</cfif>>

			<TD style="background-color: whitesmoke;border-right: 1px solid silver;position: relative;border-top:0px;border-bottom: 0px" nowrap>&nbsp;</TD>
				<TD style="border-top:0px;border-bottom: 0px">&nbsp;</TD>
			</TR>
			<TR <cfif getSettingsManagerProfiles.BB_closing_methods_view EQ 0> style="display:none"</cfif>>
				<TD WIDTH="195" id="locked" class="locked" nowrap>Billback Closing Methods List</TD><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_closing_methods_view NEQ 0><cf_toFile fname="#fName#" data="Bill Back Closing Methods"></cfif>
				<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >&nbsp;</TD>
				<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
				<cfset bApprovePullback = Evaluate("Get_#i#_Settings.Approve_Pullback") />
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#">

	<cfquery name="view_check" dbtype="query">
		SELECT * FROM Billback_User_Profile WHERE PROFILES_ID = #trim(i)#
	</cfquery>
				<CFIF view_check.BB_Create EQ 0 OR #frmREADONLY# EQ "DISABLED">
					<span ID="BB_closing_methods_view_#i#" style="color:999999;"><B>VIEW</B></span>
                <CFELSE>
				<span ID="BB_closing_methods_view_#i#" value="#i#" style="color:000000;display:block;"><a href="bb_closing_methods.cfm?profileId=#i#" onclick="javaScript:allowBlur();NewWindow(this.href , 'Bill_Back_Closing_Methods' , 750 , 650 , 'yes' , 'yes'); return false;" target="_blank"><b>VIEW</b></a></span>
				</CFIF>



				<span ID="BBD_closing_methods_view_#i#" value="#i#" style="color:000000;display:none;"><a href="bb_closing_methods.cfm?profileId=#i#" onclick="javaScript:allowBlur();NewWindow(this.href , 'Bill_Back_Closing_Methods' , 750 , 650 , 'yes' , 'yes'); return false;" target="_blank"><b>VIEW</b></a></span>
				<span ID="BBDR_closing_methods_view_#i#" style="color:999999; display:none"><B>VIEW</B></span>
				</span>

				</TD>
				</CFLOOP>
				<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_closing_methods_view NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
			</TR>
	</cfif>






<!--- Dev Note: Drachala; D27781 : new bb profile settings--->

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Delete Billback</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Delete" value="1" id="BB_Delete_1" <cfif getSettingsManagerProfiles.BB_Delete EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Delete" value="0" id="BB_Delete_0" <cfif getSettingsManagerProfiles.BB_Delete EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Delete EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Delete Billback</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Delete NEQ 0><cf_toFile fname="#fName#" data="Delete Billback"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Delete" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Delete','1');" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><!--- javaScript:billbackCheck(this); --->
				<INPUT TYPE="checkbox" ID="BB_Delete_#counter#"  MASSUPDATEID="BB_Delete" NAME="BB_Delete_#counter#" VALUE="1"<CFIF Billback_User_Profile.BB_Delete EQ 1> CHECKED</CFIF> onClick="enable_disable(#counter#);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#>
			</TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Delete NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Delete") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>

				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Delete NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

 <!--- START: 79028: BB Deviation Grid - default to only display items with deviation amt greater than $0  -Anand Rao/ 06-Sep-2018 --->
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>View Deviated Items Only On Load</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="View_Deviated_Items_Only_OnLoad" value="1" id="Manual_Reject_1" <cfif getSettingsManagerProfiles.View_Deviated_Items_Only_OnLoad EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="View_Deviated_Items_Only_OnLoad" value="0" id="View_Deviated_Items_Only_OnLoad_0" <cfif getSettingsManagerProfiles.View_Deviated_Items_Only_OnLoad EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.View_Deviated_Items_Only_OnLoad EQ 0> style="display:none"</cfif>>
			<td width="195" id="locked" class="locked" nowrap>View Deviated Items Only On Load</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Deviated_Items_Only_OnLoad NEQ 0><cf_toFile fname="#fName#" data="Reverse Billback"></cfif>
			<td width="#massUpdate_TD_Width#" class="massUpdate" ><input type="checkbox" name="View_Deviated_Items_Only_OnLoad" value="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Deviated_Items_Only_OnLoad','1')" title="Update all values for this row.">(+)</a></td>
			<cfloop query="Billback_User_Profile">
				<cfset counter=Billback_User_Profile.Profiles_ID>
				<td align="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="View_Deviated_Items_Only_OnLoad_#counter#"  MASSUPDATEID="View_Deviated_Items_Only_OnLoad" NAME="View_Deviated_Items_Only_OnLoad_#counter#" VALUE="1"<CFIF Billback_User_Profile.View_Deviated_Items_Only_OnLoad EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Deviated_Items_Only_OnLoad NEQ 0>
					<cfif Billback_User_Profile.View_Deviated_Items_Only_OnLoad EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</cfloop>
			<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Deviated_Items_Only_OnLoad NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
 <!--- END: 79028: BB Deviation Grid - default to only display items with deviation amt greater than $0  -Anand Rao/ 06-Sep-2018 --->


	<!--- Dev Note: Drachala; D27781: 7.0 new bb profile settings --->
		   <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Mass Delete Billback</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Mass_Delete" value="1" id="BB_Mass_Delete_1" <cfif getSettingsManagerProfiles.BB_Mass_Delete EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Mass_Delete" value="0" id="BB_Mass_Delete_0" <cfif getSettingsManagerProfiles.BB_Mass_Delete EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif (getSettingsManagerProfiles.BB_Mass_Delete EQ 0) OR (getSettingsManagerProfiles.BB_Delete EQ 0)> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Mass Delete Billback</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Mass_Delete NEQ 0><cf_toFile fname="#fName#" data="Mass Delete Billback"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >

    <INPUT TYPE="checkbox" NAME="BB_Mass_Delete" VALUE="1">
	<a href="##" OnClick="javascript:massUpdate('checkbox','BB_Mass_Delete','1');" TITLE="Update all values for this row.">(+)</a>
	</TD>

			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>

	<INPUT TYPE="checkbox" ID="BB_Mass_Delete_#counter#"  MASSUPDATEID="BB_Mass_Delete" NAME="BB_Mass_Delete_#counter#" VALUE="1"<CFIF Billback_User_Profile.BB_Mass_Delete EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#
	<CFIF Billback_User_Profile.BB_Delete EQ 1> <cfelse>disabled</cfif>>
	</TD>

			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Mass_Approve NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Mass_Delete") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>

					<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Mass_Delete NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<!--- Dev Note: Drachala; D27781:  7.0 new bb profile settings--->

	<cfif appSettings.getPullbacksOn()> <!--- Dev Note: DRK 9326 --->
	  <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Apply #appSettings.getPullbackLabel()#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Apply_Pullback" value="1" id="BB_Apply_Pullback_1" <cfif getSettingsManagerProfiles.BB_Apply_Pullback EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Apply_Pullback" value="0" id="BB_Apply_Pullback_0" <cfif getSettingsManagerProfiles.BB_Apply_Pullback EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	  <cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Apply_Pullback EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Apply #appSettings.getPullbackLabel()#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Apply_Pullback NEQ 0><cf_toFile fname="#fName#" data="Apply #appSettings.getPullbackLabel()#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Apply_Pullback" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Apply_Pullback','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Apply_Pullback_#counter#"  MASSUPDATEID="BB_Apply_Pullback" NAME="BB_Apply_Pullback_#counter#" VALUE="1"<CFIF Billback_User_Profile.BB_Apply_Pullback EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Apply_Pullback NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Apply_Pullback") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>

				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Apply_Pullback NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	  </cfif>

	  <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Apply #appSettings.getPullbackLabel()# Amount</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Apply_Pullback_Amount" value="1" id="BB_Apply_Pullback_Amount_1" <cfif getSettingsManagerProfiles.BB_Apply_Pullback_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Apply_Pullback_Amount" value="0" id="BB_Apply_Pullback_Amount_0" <cfif getSettingsManagerProfiles.BB_Apply_Pullback_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	  <cfelse>
		<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.BB_Apply_Pullback_Amount EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Apply #appSettings.getPullbackLabel()# Amount</TD><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Apply_Pullback_Amount NEQ 0><cf_toFile fname="#fName#" data="Apply #appSettings.getPullbackLabel()# Amount"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="BB_Apply_Pullback_Amount" ID="BB_Apply_Pullback_Amount" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '*02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','BB_Apply_Pullback_Amount','some text')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="BB_Apply_Pullback_Amount_#counter#" SIZE="5"  MASSUPDATEID="BB_Apply_Pullback_Amount" VALUE="#Billback_User_Profile.BB_Apply_Pullback_Amount#" onkeyup="clenseTextBuffer(this, '*02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Apply_Pullback_Amount NEQ 0>
				<cf_toFile fname="#fName#" data= ",#Billback_User_Profile.BB_Apply_Pullback_Amount#">
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Apply_Pullback_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	  </cfif>
	  <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Un-apply #appSettings.getPullbackLabel()#</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_UnApply_Pullback" value="1" id="BB_UnApply_Pullback_1" <cfif getSettingsManagerProfiles.BB_UnApply_Pullback EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_UnApply_Pullback" value="0" id="BB_UnApply_Pullback_0" <cfif getSettingsManagerProfiles.BB_UnApply_Pullback EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	  <cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_UnApply_Pullback EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Un-apply #appSettings.getPullbackLabel()#</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_UnApply_Pullback NEQ 0><cf_toFile fname="#fName#" data="Un-apply #appSettings.getPullbackLabel()#"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_UnApply_Pullback" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_UnApply_Pullback','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_UnApply_Pullback_#counter#"  MASSUPDATEID="BB_UnApply_Pullback" NAME="BB_UnApply_Pullback_#counter#" VALUE="1"<CFIF Billback_User_Profile.BB_UnApply_Pullback EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_UnApply_Pullback NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_UnApply_Pullback") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>

				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_UnApply_Pullback NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	  </cfif>
 	</cfif>
		<!--- If budget is on --->
	<cfif appSettings.getBudgetsFunctionalityOn()>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Approve Billback Beyond Budget</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Approve_BB_Beyond_Budget" value="1" id="Approve_BB_Beyond_Budget_1" <cfif getSettingsManagerProfiles.Approve_BB_Beyond_Budget EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Approve_BB_Beyond_Budget" value="0" id="Approve_BB_Beyond_Budget_0" <cfif getSettingsManagerProfiles.Approve_BB_Beyond_Budget EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Approve_BB_Beyond_Budget EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Approve Billback Beyond Budget</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_BB_Beyond_Budget NEQ 0><cf_toFile fname="#fName#" data="Approve Billback Beyond Budget"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_BB_Beyond_Budget" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_BB_Beyond_Budget','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#"><INPUT TYPE="checkbox" NAME="Approve_BB_Beyond_Budget_#counter#"  MASSUPDATEID="Approve_BB_Beyond_Budget" VALUE="1"<CFIF Billback_User_Profile.Approve_BB_Beyond_Budget EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_BB_Beyond_Budget NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Approve_BB_Beyond_Budget") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_BB_Beyond_Budget NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>RFA scorecard - Agreed / Display all</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_RFA_Agreed" value="1" id="BB_RFA_Agreed_1" <cfif getSettingsManagerProfiles.BB_RFA_Agreed EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_RFA_Agreed" value="0" id="BB_RFA_Agreed_0" <cfif getSettingsManagerProfiles.BB_RFA_Agreed EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_RFA_Agreed EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>RFA scorecard - Agreed</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_RFA_Agreed NEQ 0><cf_toFile fname="#fName#" data="RFA scorecard - Agreed"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT ID="BB_RFA_Agreed_Mass_1" TYPE="radio" NAME="BB_RFA_Agreed" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','BB_RFA_Agreed_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#"><INPUT TYPE="Radio" NAME="BB_RFA_Agreed_#counter#"  MASSUPDATEID="BB_RFA_Agreed_Mass_1" VALUE="1" <CFIF Billback_User_Profile.BB_RFA_Agreed EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>			<!--- <CFIF Billback_User_Profile.BB_Approve_Critical EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);" --->
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_RFA_Agreed NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_RFA_Agreed") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_RFA_Agreed NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		<TR <cfif getSettingsManagerProfiles.BB_RFA_Agreed EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>RFA scorecard - Display all</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_RFA_Agreed NEQ 0><cf_toFile fname="#fName#" data="RFA scorecard - Display all"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="BB_RFA_Agreed_Mass_0" NAME="BB_RFA_Agreed" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','BB_RFA_Agreed_Mass_0','0')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#"><INPUT TYPE="Radio" NAME="BB_RFA_Agreed_#counter#"  MASSUPDATEID="BB_RFA_Agreed_Mass_0" VALUE="0" <CFIF Billback_User_Profile.BB_RFA_Agreed EQ 0>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>	<!--- <CFIF Billback_User_Profile.BB_Approve_Critical EQ 1> CHECKED</CFIF> onClick="javaScript:billbackAmountCheck(this);" --->
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_RFA_Agreed NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_RFA_Agreed") EQ 0>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_RFA_Agreed NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Manual Void</TD>     <!--- 30916 --->
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Reverse" value="1" id="BB_Reverse_1" <cfif getSettingsManagerProfiles.BB_Reverse EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Reverse" value="0" id="BB_Reverse_0" <cfif getSettingsManagerProfiles.BB_Reverse EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Reverse EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Manual Void</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Reverse NEQ 0><cf_toFile fname="#fName#" data="Reverse Billback"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Reverse" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Reverse','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Reverse_#counter#"  MASSUPDATEID="BB_Reverse" NAME="BB_Reverse_#counter#" VALUE="1"<CFIF Billback_User_Profile.BB_Reverse EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Reverse NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Reverse") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Reverse NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<!--- 55551 --->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Manual Reject</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Manual_Reject_Billback" value="1" id="Manual_Reject_1" <cfif getSettingsManagerProfiles.Manual_Reject_Billback EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Manual_Reject_Billback" value="0" id="Manual_Reject_Billback_0" <cfif getSettingsManagerProfiles.Manual_Reject_Billback EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Manual_Reject_Billback EQ 0> style="display:none"</cfif>>
			<td width="195" id="locked" class="locked" nowrap>Manual Reject</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Manual_Reject_Billback NEQ 0><cf_toFile fname="#fName#" data="Reverse Billback"></cfif>
			<td width="#massUpdate_TD_Width#" class="massUpdate" ><input type="checkbox" name="Manual_Reject_Billback" value="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Manual_Reject_Billback','1')" title="Update all values for this row.">(+)</a></td>
			<cfloop query="Billback_User_Profile">
				<cfset counter=Billback_User_Profile.Profiles_ID>
				<td align="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Manual_Reject_Billback_#counter#"  MASSUPDATEID="Manual_Reject_Billback" NAME="Manual_Reject_Billback_#counter#" VALUE="1"<CFIF Billback_User_Profile.Manual_Reject_Billback EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Manual_Reject_Billback NEQ 0>
					<cfif Billback_User_Profile.Manual_Reject_Billback EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</cfloop>
			<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Manual_Reject_Billback NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--- 48779 --->
	<cfif appSettings.get_Setting('Manual_Void_Credit_Request') eq '1'>
		<cfif fromSettings_management eq 1>
			<TR>
				<TD align="right" nowrap>Manual Void Credit Requests</TD>     <!--- 48779 --->
				<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
					<input type="radio" name="Void_Credit_Request" value="1" id="Void_Credit_Request_1" <cfif getSettingsManagerProfiles.Void_Credit_Request EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" name="Void_Credit_Request" value="0" id="Void_Credit_Request_0" <cfif getSettingsManagerProfiles.Void_Credit_Request EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</TD>
			</TR
		<cfelse>
			<TR <cfif getSettingsManagerProfiles.Void_Credit_Request EQ 0> style="display:none"</cfif>>
				<TD WIDTH="195" id="locked" class="locked" nowrap>Manual Void Credit Requests</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Void_Credit_Request NEQ 0><cf_toFile fname="#fName#" data="Manual Void Credit Requests"></cfif>
				<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Void_Credit_Request" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Void_Credit_Request','1')" TITLE="Update all values for this row.">(+)</a></TD>
				<CFLOOP QUERY="Billback_User_Profile">
				<CFSET counter=Billback_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Void_Credit_Request_#counter#"  MASSUPDATEID="Void_Credit_Request" NAME="Void_Credit_Request_#counter#" VALUE="1"<CFIF Billback_User_Profile.Void_Credit_Request EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Void_Credit_Request NEQ 0>
					<CFIF evaluate("Billback_User_Profile.Void_Credit_Request") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
				</CFLOOP>
					<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Void_Credit_Request NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
			</TR>
		</cfif>
	</cfif>

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Auto pay reverse</TD>     <!--- 30916 --->
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Autopay_Reverse" value="1" id="Autopay_Reverse_1" <cfif getSettingsManagerProfiles.Autopay_Reverse EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Autopay_Reverse" value="0" id="Autopay_Reverse_0" <cfif getSettingsManagerProfiles.Autopay_Reverse EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Autopay_Reverse EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Auto pay reverse</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Autopay_Reverse NEQ 0><cf_toFile fname="#fName#" data="Reverse Billback"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Autopay_Reverse" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Autopay_Reverse','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Autopay_Reverse_#counter#"  MASSUPDATEID="Autopay_Reverse" NAME="Autopay_Reverse_#counter#" VALUE="1"<CFIF Billback_User_Profile.Autopay_Reverse EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Autopay_Reverse NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Autopay_Reverse") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Autopay_Reverse NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--- Dev Note: Drachala; D27781: 7.0 new bb profile settings --->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Adjust Billback</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Adjust" value="1" id="BB_Adjust_1" <cfif getSettingsManagerProfiles.BB_Adjust EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Adjust" value="0" id="BB_Adjust_0" <cfif getSettingsManagerProfiles.BB_Adjust EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Adjust EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Adjust Billback</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Adjust NEQ 0><cf_toFile fname="#fName#" data="Adjust Billback"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Adjust" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Adjust','1');" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID><!--- onClick="javaScript:billbackCheck(this);" --->
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Adjust_#counter#"  MASSUPDATEID="BB_Adjust" NAME="BB_Adjust_#counter#" VALUE="1"<CFIF Billback_User_Profile.BB_Adjust EQ 1> CHECKED</CFIF>  MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Adjust NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Adjust") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>

				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Adjust NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--- Dev Note: Drachala; D27781: 7.0 new bb profile settings --->

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Apply Rebate Rates</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Apply_Rebate_Rates" value="1" id="BB_Apply_Rebate_Rates_1" <cfif getSettingsManagerProfiles.BB_Apply_Rebate_Rates EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Apply_Rebate_Rates" value="0" id="BB_Apply_Rebate_Rates_0" <cfif getSettingsManagerProfiles.BB_Apply_Rebate_Rates EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Apply_Rebate_Rates EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Apply Rebate Rates</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Apply_Rebate_Rates NEQ 0><cf_toFile fname="#fName#" data="Apply Rebate Rates"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Apply_Rebate_Rates" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Apply_Rebate_Rates','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Apply_Rebate_Rates_#counter#"  MASSUPDATEID="BB_Apply_Rebate_Rates" NAME="BB_Apply_Rebate_Rates_#counter#" VALUE="1"<CFIF Billback_User_Profile.BB_Apply_Rebate_Rates EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Apply_Rebate_Rates NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Apply_Rebate_Rates") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Apply_Rebate_Rates NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
		<!---Allows user to mass pay billbacks if template also allows it --->
	<Cfif appsettings.Mass_Pay_Billback IS NOT 0>
	  <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Mass Pay Billbacks</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Mass_Billback_Pay" value="1" id="Mass_Billback_Pay_1" <cfif getSettingsManagerProfiles.Mass_Billback_Pay EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Mass_Billback_Pay" value="0" id="Mass_Billback_Pay_0" <cfif getSettingsManagerProfiles.Mass_Billback_Pay EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	  <cfelse>
		<TR <cfif getSettingsManagerProfiles.Mass_Billback_Pay EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Mass Pay Billbacks</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Mass_Billback_Pay NEQ 0><cf_toFile fname="#fName#" data="Mass Pay Billbacks"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Mass_Billback_Pay" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Mass_Billback_Pay','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Mass_Billback_Pay_#counter#"  NAME="Mass_Billback_Pay_#counter#" MASSUPDATEID="Mass_Billback_Pay" VALUE="1"<CFIF Billback_User_Profile.Mass_Billback_Pay EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Mass_Billback_Pay NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Mass_Billback_Pay") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Mass_Billback_Pay NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	  </cfif>
	</cfif>
			<!---end mass pay billbacks --->
	<CFIF appSettings.getBBAllowVendorMasterSearch()>
	  <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Allow Vendor Master Search</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Allow_Vendor_Master_Search" value="1" id="BB_Allow_Vendor_Master_Search_1" <cfif getSettingsManagerProfiles.BB_Allow_Vendor_Master_Search EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Allow_Vendor_Master_Search" value="0" id="BB_Allow_Vendor_Master_Search_0" <cfif getSettingsManagerProfiles.BB_Allow_Vendor_Master_Search EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	  <cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Allow_Vendor_Master_Search EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Allow Vendor Master Search</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Allow_Vendor_Master_Search NEQ 0><cf_toFile fname="#fName#" data="Allow Vendor Master Search"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Allow_Vendor_Master_Search" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Allow_Vendor_Master_Search','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Allow_Vendor_Master_Search_#counter#" NAME="BB_Allow_Vendor_Master_Search_#counter#" MASSUPDATEID="BB_Allow_Vendor_Master_Search" VALUE="1"<CFIF Billback_User_Profile.BB_Allow_Vendor_Master_Search EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Allow_Vendor_Master_Search NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Allow_Vendor_Master_Search") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Allow_Vendor_Master_Search NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	  </cfif>
	</CFIF>

		<!--- only if anyone is ever allowed to add programs where payee is not on program --->
	<cfif appSettings.getdisableBBAddProgram()>
	  <cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Add program without payee</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Add_Program" value="1" id="BB_Add_Program_1" <cfif getSettingsManagerProfiles.BB_Add_Program EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Add_Program" value="0" id="BB_Add_Program_0" <cfif getSettingsManagerProfiles.BB_Add_Program EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	  <cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Add_Program EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Add program without payee</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Add_Program NEQ 0><cf_toFile fname="#fName#" data="Add program without payee"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Add_Program" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Add_Program','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Add_Program_#counter#" NAME="BB_Add_Program_#counter#" MASSUPDATEID="BB_Add_Program" VALUE="1"<CFIF Billback_User_Profile.BB_Add_Program EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Add_Program NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Add_Program") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Add_Program NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	  </cfif>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Add Payee/Program from any position</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Add_Payee_Any_Position" value="1" id="BB_Add_Payee_Any_Position_1" <cfif getSettingsManagerProfiles.BB_Add_Payee_Any_Position EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Add_Payee_Any_Position" value="0" id="BB_Add_Payee_Any_Position_0" <cfif getSettingsManagerProfiles.BB_Add_Payee_Any_Position EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Add_Payee_Any_Position EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Add Payee/Program from any position</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Add_Payee_Any_Position NEQ 0><cf_toFile fname="#fName#" data="Add Payee/Program from any position"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Add_Payee_Any_Position" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Add_Payee_Any_Position','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Add_Payee_Any_Position_#counter#" NAME="BB_Add_Payee_Any_Position_#counter#" MASSUPDATEID="BB_Add_Payee_Any_Position" VALUE="1"<CFIF Billback_User_Profile.BB_Add_Payee_Any_Position EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Add_Payee_Any_Position NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Add_Payee_Any_Position") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Add_Payee_Any_Position NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Volume Override</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_volume_override" value="1" id="BB_volume_override_1" <cfif getSettingsManagerProfiles.BB_volume_override EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_volume_override" value="0" id="BB_volume_override_0" <cfif getSettingsManagerProfiles.BB_volume_override EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_volume_override EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Volume Override</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_volume_override NEQ 0><cf_toFile fname="#fName#" data="Volume Override"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_volume_override" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_volume_override','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_volume_override_#counter#" NAME="BB_volume_override_#counter#" MASSUPDATEID="BB_volume_override" VALUE="1"<CFIF Billback_User_Profile.BB_volume_override EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_volume_override NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_volume_override") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_volume_override NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Rate Override</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_rate_override" value="1" id="BB_rate_override_1" <cfif getSettingsManagerProfiles.BB_rate_override EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_rate_override" value="0" id="BB_rate_override_0" <cfif getSettingsManagerProfiles.BB_rate_override EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_rate_override EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Rate Override</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_rate_override NEQ 0><cf_toFile fname="#fName#" data="Rate Override"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_rate_override" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_rate_override','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_rate_override_#counter#" NAME="BB_rate_override_#counter#" MASSUPDATEID="BB_rate_override" VALUE="1"<CFIF Billback_User_Profile.BB_rate_override EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_rate_override NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_rate_override") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_rate_override NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>

		<!--- START: 81080: BB Deviation Grid - Show "Count" column --->
		<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>View Count column in deviation grid</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="View_Count_Column_In_Deviation_Grid" value="1" id="View_Count_Column_In_Deviation_Grid_1" <cfif getSettingsManagerProfiles.View_Count_Column_In_Deviation_Grid EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="View_Count_Column_In_Deviation_Grid" value="0" id="View_Count_Column_In_Deviation_Grid_0" <cfif getSettingsManagerProfiles.View_Count_Column_In_Deviation_Grid EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
		<cfelse>
		<TR <cfif getSettingsManagerProfiles.View_Count_Column_In_Deviation_Grid EQ 0> style="display:none"</cfif>>
			<td width="195" id="locked" class="locked" nowrap>View Count column in deviation grid</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Count_Column_In_Deviation_Grid NEQ 0><cf_toFile fname="#fName#" data="View Count column in deviation grid"></cfif>
			<td width="#massUpdate_TD_Width#" class="massUpdate" ><input type="checkbox" name="View_Count_Column_In_Deviation_Grid" value="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Count_Column_In_Deviation_Grid','1')" title="Update all values for this row.">(+)</a></td>
			<cfloop query="Billback_User_Profile">
				<cfset counter=Billback_User_Profile.Profiles_ID>
				<td align="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="View_Count_Column_In_Deviation_Grid_#counter#"  MASSUPDATEID="View_Count_Column_In_Deviation_Grid" NAME="View_Count_Column_In_Deviation_Grid_#counter#" VALUE="1"<CFIF Billback_User_Profile.View_Count_Column_In_Deviation_Grid EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Count_Column_In_Deviation_Grid NEQ 0>
					<cfif Billback_User_Profile.View_Count_Column_In_Deviation_Grid EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</cfloop>
			<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Count_Column_In_Deviation_Grid NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
		</cfif>
		<!--- END: 81080: BB Deviation Grid - Show "Count" column --->

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Search BB by Analyst</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Search_By_Analyst" value="1" id="BB_Search_By_Analyst_1" <cfif getSettingsManagerProfiles.BB_Search_By_Analyst EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Search_By_Analyst" value="0" id="BB_Search_By_Analyst_0" <cfif getSettingsManagerProfiles.BB_Search_By_Analyst EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Search_By_Analyst EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Search BB by Analyst</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Search_By_Analyst NEQ 0><cf_toFile fname="#fName#" data="Search BB by Analyst"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Search_By_Analyst" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Search_By_Analyst','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Search_By_Analyst_#counter#" NAME="BB_Search_By_Analyst_#counter#" MASSUPDATEID="BB_Search_By_Analyst" VALUE="1"<CFIF Billback_User_Profile.BB_Search_By_Analyst EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Search_By_Analyst NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Search_By_Analyst") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Search_By_Analyst NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
<!---
	Dev Notes: 23156/Anand Rao/26-Apr-10
	User profile to control manual rate override on bb deviation grid
--->
  	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Manual rate override &gt; claimed rate</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Dev_Grid_Manual_Rate_Override_Check" value="1" id="BB_Dev_Grid_Manual_Rate_Override_Check_1" <cfif getSettingsManagerProfiles.BB_Dev_Grid_Manual_Rate_Override_Check EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Dev_Grid_Manual_Rate_Override_Check" value="0" id="BB_Dev_Grid_Manual_Rate_Override_Check_0" <cfif getSettingsManagerProfiles.BB_Dev_Grid_Manual_Rate_Override_Check EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Dev_Grid_Manual_Rate_Override_Check EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Manual rate override &gt; claimed rate</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Dev_Grid_Manual_Rate_Override_Check NEQ 0><cf_toFile fname="#fName#" data="Manual rate override > claimed rate"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Dev_Grid_Manual_Rate_Override_Check" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Dev_Grid_Manual_Rate_Override_Check','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Dev_Grid_Manual_Rate_Override_Check_#counter#" NAME="BB_Dev_Grid_Manual_Rate_Override_Check_#counter#" MASSUPDATEID="BB_Dev_Grid_Manual_Rate_Override_Check" VALUE="1"<CFIF Billback_User_Profile.BB_Dev_Grid_Manual_Rate_Override_Check EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Dev_Grid_Manual_Rate_Override_Check NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Dev_Grid_Manual_Rate_Override_Check") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Dev_Grid_Manual_Rate_Override_Check NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

<!---
	Dev Notes: D28386: BB CRA Analysis Report/Anand Rao/15-Mar-12
	User profile to control manual rate override on bb deviation grid
--->

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>View BB CRA Analysis Rpt</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="View_BB_CRA_Analysis_Report" value="1" id="View_BB_CRA_Analysis_Report_1" <cfif getSettingsManagerProfiles.View_BB_CRA_Analysis_Report EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="View_BB_CRA_Analysis_Report" value="0" id="View_BB_CRA_Analysis_Report_0" <cfif getSettingsManagerProfiles.View_BB_CRA_Analysis_Report EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.View_BB_CRA_Analysis_Report EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>View BB CRA Analysis Rpt</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_BB_CRA_Analysis_Report NEQ 0><cf_toFile fname="#fName#" data="View BB CRA Analysis Report"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_BB_CRA_Analysis_Report" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_BB_CRA_Analysis_Report','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="View_BB_CRA_Analysis_Report_#counter#" NAME="View_BB_CRA_Analysis_Report_#counter#" MASSUPDATEID="View_BB_CRA_Analysis_Report" VALUE="1"<CFIF Billback_User_Profile.View_BB_CRA_Analysis_Report EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.View_BB_CRA_Analysis_Report NEQ 0>
				<CFIF evaluate("Billback_User_Profile.View_BB_CRA_Analysis_Report") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.View_BB_CRA_Analysis_Report NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--- Tim Ford - Label 34451: Add profile setting to restrict which users can change BB perf dates --->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Change BB start/end dates</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Change_BB_Start_End_Date1" value="1" id="Change_BB_Start_End_Date1_1" <cfif getSettingsManagerProfiles.Change_BB_Start_End_Date1 EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Change_BB_Start_End_Date1" value="0" id="Change_BB_Start_End_Date1_0" <cfif getSettingsManagerProfiles.Change_BB_Start_End_Date1 EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Change_BB_Start_End_Date1 EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Change BB start/end dates</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Change_BB_Start_End_Date1 NEQ 0><cf_toFile fname="#fName#" data="Change BB start/end dates"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Change_BB_Start_End_Date" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Change_BB_Start_End_Date','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Change_BB_Start_End_Date_#counter#" NAME="Change_BB_Start_End_Date_#counter#" MASSUPDATEID="Change_BB_Start_End_Date" VALUE="1"<CFIF Billback_User_Profile.Change_BB_Start_End_Date EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Change_BB_Start_End_Date1 NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Change_BB_Start_End_Date") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Change_BB_Start_End_Date1 NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--- Tim Ford - Label 43275: Add profile setting for BB Reassign --->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Reassign Billbacks</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Reassign" value="1" id="BB_Reassign_1" <cfif getSettingsManagerProfiles.BB_Reassign EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="BB_Reassign" value="0" id="BB_Reassign_0" <cfif getSettingsManagerProfiles.BB_Reassign EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.BB_Reassign EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>BB Reassign</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Reassign NEQ 0><cf_toFile fname="#fName#" data="BB Reassign"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="BB_Reassign" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Reassign','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="BB_Reassign_#counter#" NAME="BB_Reassign_#counter#" MASSUPDATEID="BB_Reassign" VALUE="1"<CFIF Billback_User_Profile.BB_Reassign EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Reassign NEQ 0>
				<CFIF evaluate("Billback_User_Profile.BB_Reassign") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Reassign NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<cfif appSettings.get_Setting('Vendor_Batching') eq '1'>
	<cfset billbackLabels = createObject("component", "mvc.Models.SettingsService").getBBLabels() />
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>#billBackLabels["Vendor"]# Batching</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Vendor_Hold_Research" value="1" id="Vendor_Hold_Research_1" <cfif getSettingsManagerProfiles.Vendor_Hold_Research EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Vendor_Hold_Research" value="0" id="Vendor_Hold_Research_0" <cfif getSettingsManagerProfiles.Vendor_Hold_Research EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Vendor_Hold_Research EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>#billBackLabels["Vendor"]# Batching</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Vendor_Hold_Research NEQ 0><cf_toFile fname="#fName#" data="BB Reassign"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Vendor_Hold_Research" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Vendor_Hold_Research','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Vendor_Hold_Research_#counter#" NAME="Vendor_Hold_Research_#counter#" MASSUPDATEID="Vendor_Hold_Research" VALUE="1"<CFIF Billback_User_Profile.Vendor_Hold_Research EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Vendor_Hold_Research NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Vendor_Hold_Research") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Vendor_Hold_Research NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
	</cfif>

	<!---  D51148:Viewing uploaded files inside Billback/Anand Rao/26-Jun-2015--->

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Display 'Download raw data' link for EDI Billbacks</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Display_BB_EDI_Download" value="1" id="Display_BB_EDI_Download_1" <cfif getSettingsManagerProfiles.Display_BB_EDI_Download EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Display_BB_EDI_Download" value="0" id="Display_BB_EDI_Download_0" <cfif getSettingsManagerProfiles.Display_BB_EDI_Download EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Display_BB_EDI_Download EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Display 'Download raw data' link for EDI Billbacks</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Display_BB_EDI_Download NEQ 0><cf_toFile fname="#fName#" data="Display 'Download raw data' link for EDI Billbacks"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Display_BB_EDI_Download" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Display_BB_EDI_Download','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Display_BB_EDI_Download_#counter#" NAME="Display_BB_EDI_Download_#counter#" MASSUPDATEID="Display_BB_EDI_Download" VALUE="1"<CFIF Billback_User_Profile.Display_BB_EDI_Download EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Display_BB_EDI_Download NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Display_BB_EDI_Download") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Display_BB_EDI_Download NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Display 'Download raw data' link for User Uploaded Billbacks</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Display_BB_User_Download" value="1" id="Display_BB_User_Download_1" <cfif getSettingsManagerProfiles.Display_BB_User_Download EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Display_BB_User_Download" value="0" id="Display_BB_User_Download_0" <cfif getSettingsManagerProfiles.Display_BB_User_Download EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Display_BB_User_Download EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Display 'Download raw data' link for User Uploaded Billbacks</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Display_BB_User_Download NEQ 0><cf_toFile fname="#fName#" data="Display �Download raw data� link for User Uploaded Billbacks"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Display_BB_User_Download" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Display_BB_User_Download','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Display_BB_User_Download_#counter#" NAME="Display_BB_User_Download_#counter#" MASSUPDATEID="Display_BB_User_Download" VALUE="1"<CFIF Billback_User_Profile.Display_BB_User_Download EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Display_BB_User_Download NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Display_BB_User_Download") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Display_BB_User_Download NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Display 'Download raw data' link for 3rd Party Billbacks</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Display_BB_III_Party_Download" value="1" id="Display_BB_III_Party_Download_1" <cfif getSettingsManagerProfiles.Display_BB_III_Party_Download EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Display_BB_III_Party_Download" value="0" id="Display_BB_III_Party_Download_0" <cfif getSettingsManagerProfiles.Display_BB_III_Party_Download EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Display_BB_III_Party_Download EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Display 'Download raw data' link for 3rd Party Billbacks</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Display_BB_III_Party_Download NEQ 0><cf_toFile fname="#fName#" data="Display �Download raw data� link for 3rd Party Billbacks"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Display_BB_III_Party_Download" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Display_BB_III_Party_Download','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Display_BB_III_Party_Download_#counter#" NAME="Display_BB_III_Party_Download_#counter#" MASSUPDATEID="Display_BB_III_Party_Download" VALUE="1"<CFIF Billback_User_Profile.Display_BB_III_Party_Download EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Display_BB_III_Party_Download NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Display_BB_III_Party_Download") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Display_BB_III_Party_Download NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>


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
</cfif>

<cfif bShowAutoApproveAnalysis EQ 1>
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Auto Approve Analysis</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Auto_Approve_Analysis" value="1" id="Auto_Approve_Analysis_1" <cfif getSettingsManagerProfiles.Auto_Approve_Analysis EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Auto_Approve_Analysis" value="0" id="Auto_Approve_Analysis_0" <cfif getSettingsManagerProfiles.Auto_Approve_Analysis EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Auto_Approve_Analysis EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Auto Approve Analysis</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Auto_Approve_Analysis NEQ 0><cf_toFile fname="#fName#" data="Auto Approve Analysis"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Auto_Approve_Analysis" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Auto_Approve_Analysis','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Auto_Approve_Analysis_#counter#" NAME="Auto_Approve_Analysis_#counter#" MASSUPDATEID="Auto_Approve_Analysis" VALUE="1"<CFIF Billback_User_Profile.Auto_Approve_Analysis EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Auto_Approve_Analysis NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Auto_Approve_Analysis") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Auto_Approve_Analysis NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
</cfif>
<!--- 61486 : Default program only when $'s equal to $0.00... START --->

	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Allow RFA on billbacks with default program</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Allow_RFA_With_Default_Program" value="1" id="Allow_RFA_With_Default_Program_1" <cfif getSettingsManagerProfiles.Allow_RFA_With_Default_Program EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Allow_RFA_With_Default_Program" value="0" id="Allow_RFA_With_Default_Program_0" <cfif getSettingsManagerProfiles.Allow_RFA_With_Default_Program EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Allow_RFA_With_Default_Program EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Allow RFA on billbacks with default program</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Allow_RFA_With_Default_Program NEQ 0><cf_toFile fname="#fName#" data="Allow RFA With Default Program"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Allow_RFA_With_Default_Program" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Allow_RFA_With_Default_Program','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
			<CFSET counter=Billback_User_Profile.Profiles_ID>
			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" ID="Allow_RFA_With_Default_Program_#counter#" NAME="Allow_RFA_With_Default_Program_#counter#" MASSUPDATEID="Allow_RFA_With_Default_Program" VALUE="1"<CFIF Billback_User_Profile.Allow_RFA_With_Default_Program EQ 1> CHECKED</CFIF> onClick="javaScript:billbackCheck(this);" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Allow_RFA_With_Default_Program NEQ 0>
				<CFIF evaluate("Billback_User_Profile.Allow_RFA_With_Default_Program") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				<cfelse>
					<cf_toFile fname="#fName#" data=",no">
				</cfif>
			</cfif>
			</CFLOOP>
				<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Allow_RFA_With_Default_Program NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

<!--- 61486 : Default program only when $'s equal to $0.00... END--->

<!--- START: 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ]   --->
   <cfif application.appSettingsGet.get_Setting('BB_Display_Dist_Channel_Per_Program_Distributor') eq '1'>
  	  <cfif fromSettings_management eq 1>
      	<cfset SettingsTemplateFormUserProfile(NameField="BB_Display_Dist_Channel_Per_Program_Distributor", NameFieldDesc="FORGE Analytics Single Sign On")>
	  <cfelse>
	  	<TR <cfif  getSettingsManagerProfiles.BB_Display_Dist_Channel_Per_Program_Distributor EQ 0> style="display:none" </cfif>>
	    		<TD WIDTH="195" id="locked" class="locked" nowrap>Update #qGetBSVar2Label.General_Labels_Label#</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Display_Dist_Channel_Per_Program_Distributor NEQ 0><cf_toFile fname="#fName#" data="Update #qGetBSVar2Label.General_Labels_Label#"></cfif>
	    		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="BB_Display_Dist_Channel_Per_Program_Distributor" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','BB_Display_Dist_Channel_Per_Program_Distributor','1')" TITLE="Update all values for this row.">(+)</a></TD>
	    		<cfloop query="Billback_User_Profile">
				<CFSET i=Billback_User_Profile.Profiles_ID>
	      			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="BB_Display_Dist_Channel_Per_Program_Distributor_#i#"  MASSUPDATEID="BB_Display_Dist_Channel_Per_Program_Distributor" <CFIF evaluate("Billback_User_Profile.BB_Display_Dist_Channel_Per_Program_Distributor") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
	    			<cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Display_Dist_Channel_Per_Program_Distributor NEQ 0>
	      				<CFIF evaluate("Billback_User_Profile.BB_Display_Dist_Channel_Per_Program_Distributor") EQ 1>
	        					<cf_toFile fname="#fName#" data=",yes">
	      				<cfelse>
	        					<cf_toFile fname="#fName#" data=",no">
	      				</cfif>
	    			</cfif>
	    		</CFLOOP>
	  		<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.BB_Display_Dist_Channel_Per_Program_Distributor NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	  	</TR>
	  </cfif>
  </cfif>

 <!--- END: 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ]   --->

 <!--- START: 76536: BB Oper Location Level - dup check  -Anand Rao/ 09-Aug-2018 --->
  <cfif application.appSettingsGet.get_Setting('BB_Oper_Location_Level_Dup_Checker') eq '1'>
	 <cfif fromSettings_management eq 1>
			<TR>
				<TD align="right" nowrap>BB Operator Location Level Duplicate Approval Amount</TD>
				<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
					<input type="radio" name="Max_BB_Oper_Location_Level_Dup_Approval_Amount" value="1" id="Max_BB_Oper_Location_Level_Dup_Approval_Amount_1" <cfif getSettingsManagerProfiles.Max_BB_Oper_Location_Level_Dup_Approval_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" name="Max_BB_Oper_Location_Level_Dup_Approval_Amount" value="0" id="Max_BB_Oper_Location_Level_Dup_Approval_Amount_0" <cfif getSettingsManagerProfiles.Max_BB_Oper_Location_Level_Dup_Approval_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</TD>
			</TR>
		<cfelse>
			<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Max_BB_Oper_Location_Level_Dup_Approval_Amount EQ 0> style="display:none"</cfif>>
				<TD WIDTH="195" id="locked" class="locked" nowrap>BB Operator Location Level Duplicate Approval Amount</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_BB_Oper_Location_Level_Dup_Approval_Amount NEQ 0><cf_toFile fname="#fName#" data="Max BB Oper Location Level Dup Approval Amount"></cfif>
				<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="Max_BB_Oper_Location_Level_Dup_Approval_Amount" ID="Max_BB_Oper_Location_Level_Dup_Approval_Amount" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '*02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Max_BB_Oper_Location_Level_Dup_Approval_Amount','some text')" TITLE="Update all values for this row.">(+)</a></TD>
				<CFLOOP QUERY="Billback_User_Profile">
				<CFSET counter=Billback_User_Profile.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="Max_BB_Oper_Location_Level_Dup_Approval_Amount_#counter#" SIZE="5"  MASSUPDATEID="BB_Approve_Amount" VALUE="#Billback_User_Profile.Max_BB_Oper_Location_Level_Dup_Approval_Amount#" onkeyup="clenseTextBuffer(this, '*02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_BB_Oper_Location_Level_Dup_Approval_Amount NEQ 0>
					<cf_toFile fname="#fName#" data= ",#Billback_User_Profile.Max_BB_Oper_Location_Level_Dup_Approval_Amount#">
				</cfif>
				</CFLOOP>
				<td width="100%">&nbsp;</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_BB_Oper_Location_Level_Dup_Approval_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
			</TR>
		</cfif>
	</cfif>
<!--- END: 76536: BB Oper Location Level - dup check   --->
<!--- Settlements --->
<cfif fromSettings_management eq 1>
	<TR>
		<TD align="right" nowrap>Settlements</TD>
		<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Settlements" value="1" id="Settlements_1" <cfif getSettingsManagerProfiles.Settlements EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Settlements" value="0" id="Settlements_0" <cfif getSettingsManagerProfiles.Settlements EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</TD>
	</TR>
<cfelse>
	<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Settlements EQ 0> style="display:none"</cfif>>
		<TD WIDTH="195" id="locked" class="locked" nowrap>Settlements</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Settlements NEQ 0><cf_toFile fname="#fName#" data="Settlements"></cfif>
		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Settlements" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Settlements','1')" TITLE="Update all values for this row.">(+)</a></TD>
		<CFLOOP QUERY="Billback_User_Profile">
		<CFSET counter=Billback_User_Profile.Profiles_ID>
		<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Settlements_#counter#"  MASSUPDATEID="Settlements" <CFIF evaluate("Billback_User_Profile.Settlements") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
	    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Settlements NEQ 0>
			<cf_toFile fname="#fName#" data= ",#Billback_User_Profile.Settlements#">
		</cfif>
		</CFLOOP>
		<td width="100%">&nbsp;</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Settlements NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	</TR>
</cfif>
<!--- 108221 Quick Pay modifications START--->
<cfif fromSettings_management eq 1>
	<TR>
		<TD align="right" nowrap>Advance Quick Pay</TD>
		<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
			<input type="radio" name="AQP_Available" value="1" id="AQP_Available_1" <cfif getSettingsManagerProfiles.AQP_Available EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="AQP_Available" value="0" id="AQP_Available_0" <cfif getSettingsManagerProfiles.AQP_Available EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</TD>
	</TR>
<cfelse>
	<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.AQP_Available EQ 0> style="display:none"</cfif>>
		<TD WIDTH="195" id="locked" class="locked" nowrap>Advance Quick Pay</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.AQP_Available NEQ 0><cf_toFile fname="#fName#" data="AQP_Available"></cfif>
		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="AQP_Available" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','AQP_Available','1')" TITLE="Update all values for this row.">(+)</a></TD>
		<CFLOOP QUERY="Billback_User_Profile">
		<CFSET counter=Billback_User_Profile.Profiles_ID>
		<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="AQP_Available_#counter#"  MASSUPDATEID="AQP_Available" <CFIF evaluate("Billback_User_Profile.AQP_Available") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
	    <cfif saveToXl is "yes" and getSettingsManagerProfiles.AQP_Available NEQ 0>
			<cf_toFile fname="#fName#" data= ",#Billback_User_Profile.AQP_Available#">
		</cfif>
		</CFLOOP>
		<td width="100%">&nbsp;</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.AQP_Available NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	</TR>
</cfif>
	<!--- 108221 Quick Pay modifications END--->
<!---97929 :: Quick Pay START--->
<cfif fromSettings_management eq 1>
	<TR>
		<TD align="right" nowrap>Advance QP Max Overspend</TD>
		<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
			<input type="radio" name="AQP_Max_Overspend" value="1" id="AQP_Max_Overspend_1" <cfif getSettingsManagerProfiles.AQP_Max_Overspend EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="AQP_Max_Overspend" value="0" id="AQP_Max_Overspend_0" <cfif getSettingsManagerProfiles.AQP_Max_Overspend EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		</TD>
	</TR>
<cfelse>
	<TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.AQP_Max_Overspend EQ 0> style="display:none"</cfif>>
		<TD WIDTH="195" id="locked" class="locked" nowrap>Advance QP Max Overspend</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.AQP_Max_Overspend NEQ 0><cf_toFile fname="#fName#" data="AQP_Max_Overspend"></cfif>
		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" NAME="AQP_Max_Overspend" ID="AQP_Max_Overspend" SIZE="5" VALUE="" onkeyup="clenseTextBuffer(this, '*02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','AQP_Max_Overspend','some text')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="Billback_User_Profile">
		<CFSET counter=Billback_User_Profile.Profiles_ID>
		<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="AQP_Max_Overspend_#counter#" SIZE="5" MASSUPDATEID="AQP_Max_Overspend" VALUE="#Billback_User_Profile.AQP_Max_Overspend#" onkeyup="clenseTextBuffer(this, '*02134567890')" MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
		<cfif saveToXl is "yes" and getSettingsManagerProfiles.AQP_Max_Overspend NEQ 0>
			<cf_toFile fname="#fName#" data= ",#Billback_User_Profile.AQP_Max_Overspend#">
		</cfif>
		</CFLOOP>
		<td width="100%">&nbsp;</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.AQP_Max_Overspend NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	</TR>
</cfif>
	<!---97929 :: Quick Pay END--->
</cfoutput>
