<!---
***********************************************************************
Created By: Deepa Kunnath
File Path: /deductions/settings/deduction_external_settings.cfm
Created Date: 3/22/2005
Deleted Bit: 0 :)
Purpose: For controlling the deduction settings editable by users
***********************************************************************
--->

<CFSET PAGETITLE = "SYSTEM ADMINISTRATION: PAYABLES SETTINGS">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE></TITLE>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfoutput>

<!------ set defaults ----->
<cfparam name="form.state" 	default="0">
<cfparam name="url.command" 	default="Settings1">
<cfparam name="form.command" 	default="#url.command#">
<cfset thisPage = "deduction_external_settings.cfm?command=#form.command#">
<cfset formName = "frmDeductionExternalSettings">
<cfset appSettings = application.appSettingsGet>
<cfset deductionSettingsManager = CreateObject("component", "components.deduction.settings.DeductionSettingsManager").init() />
<cfset billbackSettingsManager = CreateObject("component", "components.billback.BillbackSettingsManager") />
<cfif form.state>
	<cfparam name="form.DDNewAddReminderAfterDays" 	default="0">


	<cfset deductionSettings = deductionSettingsManager.get(0)>
	<cfset deductionSettings.setDDNewAddReminderAfterDays(form.DDNewAddReminderAfterDays)>
	<cfset deductionSettings.setUpdatedBy(request.AccessStructure.User_ID)>
	<cfset deductionSettingsManager.save()>

	<cfparam name="form.Search_Expired_Program_Within" 	default="0">
	<cfset billbackSettingsManager.saveSearchExpiredProgramWithin(form.Search_Expired_Program_Within) />

	<cfparam name="form.Adjustment_Default" 	default="1">
	<cfparam name="form.Sort_Option_for_Scorecard" 	default="BBI">
	<cfparam name="form.Sort_by" 	default="DESC">

	<cfset billbackSettingsManager.saveAdjustmentDefault(form.Adjustment_Default) />
	<cfset billbackSettingsManager.saveAdjustmentDefault(form.Adjustment_Default) />
	<!--- 98106 - Auto Deviations to consider if bb is beyond program budget START --->
	<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn() >
	<cfset billbackSettingsManager.saveBB_Status_for_Budget_Actual(FORM.BB_Status_for_Budget_Actual) />
	</cfif>
	<!--- 98106 - Auto Deviations to consider if bb is beyond program budget END --->
	<cflocation addtoken="No" url="#thisPage#">

	<cfabort>
</cfif>


<script language="JavaScript">
	function submitForm(thisForm, sCommand)
	{
		thisForm.command.value = sCommand;
		thisForm.submit();
		return false;
	}
</script>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script language="JavaScript">
	function validateThisField(iType, oInput, sMsg)
	{
		var isValid = true;
		switch(iType)
		{
			case 1:
			{
				isValid = isInt(oInput.value);
				break;
			}
			case 2:
			{
				isValid = !isSpace(oInput.value);
				break;
			}
		}

		var errObj = eval("document.all.err_sp_" + oInput.name);
		if(isValid)
		{
			clearQueue(errObj);
		}
		else
		{
			queueMessage(sMsg, errObj);
		}
		return isValid;
	}
</script>

<form action="#thisPage#" method="post" name="#formName#" style="display:inline;">

<cfoutput>

<cfset deductionSettings = deductionSettingsManager.get(1, 1)>
<cfset Search_Expired_Program_Within = billbackSettingsManager.getSearchExpiredProgramWithin()>
<cfset AdjustmentDefault_Selected = billbackSettingsManager.getAdjustment_Default()>
<cfset Default_sort_columns = billbackSettingsManager.getDefaultSortOptions()>
<cfset Default_sort_option_for_Scorecard = Default_sort_columns.Default_sort_option_for_Scorecard />
<cfset Default_Sort_By 					= Default_sort_columns.Default_Sort_By />
<cfset BB_Status_for_Budget_Actual = billbackSettingsManager.getBB_Status_for_Budget_Actual()>	<!--- 98106 --->

<style>
	.deductionSettingsInput
	{
		text-align:right;
		width:50px;
	}
</style>

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_validations.js"></SCRIPT>
<script language="JavaScript">

function validateAndSubmit(thisForm)
{

	ErrorCount = 0
	<!---<cfif application.deductionLinksAvailable> --->
	<cfif application.appSettingsGet.getDeduction_Module()>
	if (!validateThisField(1, document.all.DDNewAddReminderAfterDays, "'Deduction new status reminder lag time' should be a valid number"))
	{
		ErrorCount++;
	}
	else
	{
		clearQueue(document.all.err_sp_DDNewAddReminderAfterDays);
	}
	</cfif>
	if(ErrorCount == 0) {

			submitForm(thisForm, "Settings1");

	}
	else {
		showMessageWindow()
	}

}

function fnResetDeleteDecider(iOption)
{
	NewWindow("ResetOrDelete.cfm?iAction=" + iOption + "","print","800","600","Yes", "No");
}

<!---function fnResendBillback()
{
	NewWindow("ResetOrDelete.cfm","print","800","600","Yes", "No");
}--->


function fnSwitchJobs(bSwitch,iJobType)
{
	NewWindow("toggleJobSwitch.cfm?iAction=" + bSwitch + "&iJobType=" + iJobType,"Job_Switch","500","400","Yes", "No");
}

</script>

<br>
<cfif Len(deductionSettings.getUpdatedBy()) GT 0>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD>
	<FONT SIZE="2"><B>The settings were last updated on #dateformat(deductionSettings.getUpdatedOn(), 'mm/dd/yyyy')# #timeformat(deductionSettings.getUpdatedOn(), 'hh:mm:ss TT')# by #deductionSettings.getUpdatedByUserName()#</B></FONT>	</TD>
</TD>
</TR>
</TABLE>
</cfif>
<br>
<table cellpadding="2" cellspacing="0" border="0" width="500">
	<!---<cfif application.deductionLinksAvailable> --->
	<cfif application.appSettingsGet.getDeduction_Module()>
	<tr>
		<td>Add reminder if deduction in 'new' status for:</td>
		<td><span id="err_sp_DDNewAddReminderAfterDays">&nbsp;&nbsp;</span></td>
		<td nowrap>&nbsp;<input maxlength="3"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="deductionSettingsInput" type="Text" name="DDNewAddReminderAfterDays" value="#deductionSettings.getDDNewAddReminderAfterDays()#"> calendar days</td>
	</tr>
	</cfif>
	<tr>
		<td>Within billbacks, when searching for programs display expired programs within N days of the program's end date:</td>
		<td><span id="err_sp_Search_Expired_Program_Within">&nbsp;&nbsp;</span></td>
		<td>&nbsp;<input maxlength="3"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="deductionSettingsInput" type="Text" name="Search_Expired_Program_Within" value="#Search_Expired_Program_Within#"> days</td>
	</tr>
	<tr>
		<td>Adjustment default status:</td>
		<td><span id="err_sp_adjustment_default_status">&nbsp;&nbsp;</span></td>
		<td>&nbsp;<SELECT name="Adjustment_Default">
					<OPTION value="1" <cfif AdjustmentDefault_Selected EQ 1>selected</cfif>>Apply</OPTION>
					<OPTION value="2" <cfif AdjustmentDefault_Selected EQ 2>selected</cfif>>Ignore</OPTION>
					<OPTION value="3" <cfif AdjustmentDefault_Selected EQ 3>selected</cfif>>Remove</OPTION> <!--- Hide--->
			</SELECT>
		</td>
	</tr>

	<!--- Anand Rao/22-DEc-2011/D29654 Settings for BB Reset/Delete, PRG Unlock/Reactivate --->
	<tr>
		<td>
			Reset billbacks:
						<!--- D32926: Settings Warning - Reset a Paid Billback START --->
													<CF_SmallHelp
															width="300"
															displayShifyX = "0"
															imgPath="/images/help_small.gif"
															imgWidth="14"
															imgHeight="13"
															dropdownCheck="0"
															>
														Selecting this option may not have the desired impact on interfaces with each client.  Some interfaces are too complex to handle with common code such as this option.
													</CF_SmallHelp>
						<!--- D32926: Settings Warning - Reset a Paid Billback END --->

		</td>
		<td>&nbsp;</td>
		<td>
		<CF_button
			button_name		=	""
			button_caption	=	"Reset Billbacks"
			button_action	=	"fnResetDeleteDecider('1');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
	</tr>
	<tr>
			<td>
				Delete billbacks:
						<!--- D32926: Settings Warning - Delete a Paid Billback START --->
													<CF_SmallHelp
															width="300"
															displayShifyX = "0"
															imgPath="/images/help_small.gif"
															imgWidth="14"
															imgHeight="13"
															dropdownCheck="0"
															>
															After selecting this option, the billbacks selected will no longer be available for users to interact with and the interfaces with the ERP will be out of synch until a similar action is taken in the ERP.
													</CF_SmallHelp>
						<!--- D32926: Settings Warning - Delete a Paid Billback END --->

			</td>
			<td>&nbsp;</td>
			<td>
			<CF_button
				button_name		=	""
				button_caption	=	"Delete billbacks"
				button_action	=	"fnResetDeleteDecider('2');"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Save"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
			</nowrap>
			</td>
	</tr>
	<!--- End D29654 --->
		<!--- D29824:New Settings.. --->
	<tr>
			<td>
				Resend Billback in Payment Interface:

					<!--- D32927: Settings Warning - Resend Billback in Payment Interface START --->
							<CF_SmallHelp
									width="300"
									displayShifyX = "0"
									imgPath="/images/help_small.gif"
									imgWidth="14"
									imgHeight="13"
									dropdownCheck="0"
									>
									Selecting this option will merely reset the flag in the billback table for certain interfaces to pick up.
									Due to custom interfaces that are more complex, not all FORGE customers will be able to leverage this feature
							</CF_SmallHelp>
					<!--- D32927: Settings Warning - Resend Billback in Payment Interface END --->

			</td>
			<td>&nbsp;</td>
			<td>
					<CF_smallLink
					title = "Search Billbacks"
					url = "resend_billback_interface.cfm"
					parameters = ""
					>
			</nowrap>
			</td>
	</tr>
	<!--- D29824:New Settings.. --->

	<!---Anand Rao/17-Nov-2011/29229 - Default sort order for billback scorecard --->
	<tr>
		<td>Default sort option for Scorecard:</td>
		<td><span id="err_sp_Default_sort_option_for_Scorecard">&nbsp;&nbsp;</span></td>
		<td>&nbsp;<SELECT name="Sort_Option_for_Scorecard">
					<OPTION value="BBI" <cfif Default_sort_option_for_Scorecard EQ "BBI">selected</cfif>>Payable ##</OPTION>
					<OPTION value="BBD" <cfif Default_sort_option_for_Scorecard EQ "BBD">selected</cfif>>Date</OPTION>
					<OPTION value="BBNUM" <cfif Default_sort_option_for_Scorecard EQ "BBNUM">selected</cfif>>Billback ##</OPTION>
					<OPTION value="BBT" <cfif Default_sort_option_for_Scorecard EQ "BBT">selected</cfif>>Title</OPTION>
					<OPTION value="BBSD" <cfif Default_sort_option_for_Scorecard EQ "BBSD">selected</cfif>>Start Date</OPTION>
					<OPTION value="BBED" <cfif Default_sort_option_for_Scorecard EQ "BBED">selected</cfif>>End Date</OPTION>
					<OPTION value="BBA" <cfif Default_sort_option_for_Scorecard EQ "BBA">selected</cfif>>$ Amount</OPTION>
				</SELECT>
		</td>
	</tr>
	<tr>
		<td>Ascending/Descending?</td>
		<td><span id="err_sp_Sort_by">&nbsp;&nbsp;</span></td>
		<td>&nbsp;<SELECT name="Sort_by">
					<OPTION value="ASC" <cfif Default_Sort_By EQ "ASC">selected</cfif>>Ascending</OPTION>
					<OPTION value="DESC" <cfif Default_Sort_By EQ "DESC">selected</cfif>>Descending</OPTION>
				</SELECT>
		</td>
	</tr>
	<!--- 98106 - Auto Deviations to consider if bb is beyond program budget START --->
	<cfif Application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn() >
	<tr>
		<td>Which billback status should impact the budget's actual dollars:</td>
		<td>&nbsp;&nbsp;</td>
		<td>
			<select name="BB_Status_for_Budget_Actual">
				<option value="3" <cfif BB_Status_for_Budget_Actual EQ 3>Selected</cfif>>Approved</option>
				<option value="5" <cfif BB_Status_for_Budget_Actual EQ 5>Selected</cfif>>Paid</option>
			</select>
		</td>
		</tr>
	</cfif>
	<!--- 98106 - Auto Deviations to consider if bb is beyond program budget END --->
	<!---
		START:: D46210: Create �Update CRA� link for Billbacks in settings> payables >payables settings/Anand Rao/13-Nov-2014
	--->
	<tr>
	<td>Update CRA:</td>
	<td>&nbsp; </td>
	<td nowrap colspan="3"><input type="button" value="Click here" onClick="NewWindow('Update_BB_CRA.cfm','Update_CRA','600','400','No', 'No'); return false;"></td>
</tr>
	<!---
		END: D46210
	--->

	<tr>
		<td></td><td></td>
		<td  align="center">
		<br>
		<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"validateAndSubmit(document.#formName#);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
	</tr>
</table>
</cfoutput>

	<input type="Hidden" name="state" value="1">
	<input type="Hidden" name="command" value="#form.command#">
</form>
<CF_MessageWindow />
</cfoutput>

<hr width="100%" color="orange">
<table cellpadding="2" cellspacing="0" border="0" width="500">
<tr>
	<td>
		<div align="left" width="500">
		<cfinclude template="/billbacks/capture/upload_billback/Default_Program.cfm" >
		<br />
		</div>
	</td>
</tr>
</table>

<hr width="100%" color="orange">
<div align="left" width="500">
<cfset variables.src = "payable_settings" />
<cfinclude template="/Settings/upload_billback_utility/upload_settings.cfm" />
</div>
<hr width="100%" color="orange">

<!---
      Dev Notes: D24193/Anand Rao/27-Jul-10
    	BB Flex Grid Select All Button & Approve Change
--->

<cfset oBillbackColorSettings = createObject("component", "components.billback.BillbackSettingsManager") />
	<cfset qGetBBDevColorSetting 	= oBillbackColorSettings.getBBDevColorSetting() />
  <cfset varExpBgColor        = qGetBBDevColorSetting.ExpBtnBgColor />
  <cfset varExpFontColor      = qGetBBDevColorSetting.ExpBtnFontColor />
  <cfset varClmBgColor        = qGetBBDevColorSetting.ClmBtnBgColor />
  <cfset varClmFontColor      = qGetBBDevColorSetting.ClmBtnFontColor />
  <cfset varEltBgColor        = qGetBBDevColorSetting.EltBtnBgColor />
  <cfset varEltFontColor      = qGetBBDevColorSetting.EltBtnFontColor />
  <cfset varSelBgColor        = qGetBBDevColorSetting.SelBtnBgColor />
  <cfset varSelFontColor      = qGetBBDevColorSetting.SelBtnFontColor />

<cfoutput>
  <cfif Len(trim(qGetBBDevColorSetting.BtnColor_Updated_By)) GT 0>
    <br />
    <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="2">
    	<tr>
    		<td>
    			<cfoutput>
    			<FONT SIZE="2"><B>The settings were last updated on #dateformat(qGetBBDevColorSetting.BtnColor_Updated_Date, 'mm/dd/yyyy')# #timeformat(qGetBBDevColorSetting.BtnColor_Updated_Date, 'hh:mm:ss TT')# by #qGetBBDevColorSetting.Updated_By#</B></FONT>
    			</cfoutput>
    		</td>
    	</tr>
    </table>
  </cfif>
 <br><font color="navy" size=2><b><span class="subheading">Billback Deviation Grid - Settings</span></b></font><br>
 (Click on the button to select a color)<br><br>

  <table border="0" cellspacing="1">
   	  <tr>
        <td style="font-weight:bold">
  			  Expected $:&nbsp;
  		  </td>
        <td>
      	 <input type="button" value="Expected $" style="background:###varExpBgColor#;width:85px;height:20px;color:###varExpFontColor#" onclick="javascript:window.open('/billbacks/settings/BB_Dev_Color_Setting.cfm','ColorPicker','toolbar=no,width=675,height=275,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false">
        </td>
    	</tr>
    	<tr>
        <td style="font-weight:bold">
  			  Expected LT $:&nbsp;
  		  </td>
        <td>
  	    <input type="button" value="Expected $ LT" style="background:###varEltBgColor#;width:85px;height:20px;color:###varEltFontColor#" onclick="javascript:window.open('/billbacks/settings/BB_Dev_Color_Setting.cfm','ColorPicker','toolbar=no,width=675,height=275,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false"><br>
  	    </td>
    	</tr>
    	<tr>
        <td style="font-weight:bold">
  			  Claimed $:&nbsp;
  		  </td>
        <td>
    	     <input type="button" value="Claimed $" style="background:###varClmBgColor#;width:85px;height:20px;color:###varClmFontColor#" onclick="javascript:window.open('/billbacks/settings/BB_Dev_Color_Setting.cfm','ColorPicker','toolbar=no,width=675,height=275,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false"><br>
  	    </td>
    	</tr>

    	<tr>
        <td style="font-weight:bold">
  			  Selected $:&nbsp;
  		  </td>
        <td>
      	  <input type="button" value="Selected $" style="background:###varSelBgColor#;width:85px;height:20px;color:###varSelFontColor#" onclick="javascript:window.open('/billbacks/settings/BB_Dev_Color_Setting.cfm','ColorPicker','toolbar=no,width=675,height=275,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false">
        </td>
    	</tr>
  </table>
</cfoutput>
<hr width="100%" color="orange">

<div align="left" width="500">
  <cfinclude template="Billback_Type_Label_Settings.cfm" />
</div>
<hr width="100%" color="orange">

<div align="left" width="500">
  <cfinclude template="3rdPartyUpload_SingleBBPerInv.cfm" />
</div>
<hr width="100%" color="orange">
	<cfset useLakebaseForshowJobSetting1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_settings")>
	<cfif useLakebaseForshowJobSetting1>
		<cftry>
			<cfset showJobSetting = application.oLakebase.toQuery(
				application.oLakebase.selectRows("customer_settings", {
					"select" = "show_bb_job_settings"
				}),
				"show_bb_job_settings"
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForshowJobSetting1 = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForshowJobSetting1>
	<cfquery name="showJobSetting" datasource="#application.datasource#">
 		SELECT Show_BB_Job_Settings FROM Customer_Settings
	</cfquery>
	</cfif>
	<cfif showJobSetting.Show_BB_Job_Settings EQ 1>

		<cfquery name="showJobSetting" datasource="#application.datasource#">
 			SELECT BS.Enable_Jobs_1_To_4,
				   usr1.Name_First + ' ' + usr1.Name_Last AS Updated_By_4,
				   BS.Enable_Jobs_1_To_4_Updated_Date,
				   BS.Enable_Job_5,
				   usr2.Name_First + ' ' + usr2.Name_Last AS Updated_By_5,
				   BS.Enable_Jobs_5_Updated_Date
			FROM Billback_Settings BS
				LEFT JOIN _Users usr1 ON usr1.User_ID = BS.Enable_Jobs_1_To_4_Updated_By
				LEFT JOIN _Users usr2 ON usr2.User_ID = BS.Enable_Jobs_5_Updated_By

		</cfquery>

		<br><font color="navy" size=2><b><span class="subheading">Month End Process:</span></b></font><br><br>

		<cfif Len(trim(showJobSetting.Updated_By_4)) GT 0>
	   	 	<br />
		    <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="2">
		    	<tr>
		    		<td>
		    			<cfoutput>
		    			<FONT SIZE="2"><B>The setting was last updated on #dateformat(showJobSetting.Enable_Jobs_1_To_4_Updated_Date, 'mm/dd/yyyy')# #timeformat(showJobSetting.Enable_Jobs_1_To_4_Updated_Date, 'hh:mm:ss TT')# by #showJobSetting.Updated_By_4#</B></FONT>
		    			</cfoutput>
		    		</td>
		    	</tr>
		    </table>
  		</cfif>

		<table border="0" cellspacing="1" cellpadding="2">
			<tr>
				<td style="font-weight:bold"  valign="top">
					JOBS 1 to 4:
				</td>
				<td style="font-weight:bold">
					AdvanceFoods_Prod_BB_III_Party_Claim_Upload (SQL23)&nbsp;&nbsp;&nbsp;&nbsp;<br>
					Advancefood_900_GL_Request (APF)<br>
					BA_AdvanceFoods_Auto_Deviation (APF) <br>
					BA_AdvanceFoods_Auto_Match (APF)<br>
					<br>
  		  		</td>
        		<td valign="top">
					<cfif (showJobSetting.Enable_Jobs_1_To_4 EQ 1)>
						<CF_button
							button_name		=	""
							button_caption	=	"Disable Jobs 1 through 4"
							button_action	=	"fnSwitchJobs('0','1');"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"Save"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
					<cfelse>
						<CF_button
							button_name		=	""
							button_caption	=	"Enable Jobs 1 through 4"
							button_action	=	"fnSwitchJobs('1','1');"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"Save"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
					</cfif>

				</td>
			</tr>
			<cfif Len(trim(showJobSetting.Updated_By_5)) GT 0>
			<tr>
				<td colspan="100%">
			   	 	<br />
				    <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="3" cellspacing="2">
				    	<tr>
				    		<td>
				    			<cfoutput>
				    			<FONT SIZE="2"><B>The setting was last updated on #dateformat(showJobSetting.Enable_Jobs_5_Updated_Date, 'mm/dd/yyyy')# #timeformat(showJobSetting.Enable_Jobs_5_Updated_Date, 'hh:mm:ss TT')# by #showJobSetting.Updated_By_5#</B></FONT>
				    			</cfoutput>
				    		</td>
				    	</tr>
				    </table>
				</td>
			</tr>
  		</cfif>
			<tr>
				<td style="font-weight:bold" valign="top">
					JOB 5:
				</td>
				<td style="font-weight:bold">
					AdvanceFoods_1510_Credit_Request
				</td>
				<td>
				<cfif (showJobSetting.Enable_Job_5 EQ 1)>
						<CF_button
							button_name		=	""
							button_caption	=	"Disable Job 5"
							button_action	=	"fnSwitchJobs('0','2');"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"Save"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
					<cfelse>
						<CF_button
							button_name		=	""
							button_caption	=	"Enable Job 5"
							button_action	=	"fnSwitchJobs('1','2');"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"Save"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>
					</cfif>
				</td>
			</tr>
		</table>
		<hr width="100%" color="orange">
	</cfif> <!--- <cfif showJobSetting.Show_BB_Job_Settings EQ 1> --->

</BODY>
</HTML>
