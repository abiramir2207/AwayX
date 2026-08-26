<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Untitled</title>
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
</head>
<body>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET URL.PageTitle="Payables Auto Close">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/common_files/javascript.cfm">
<cfinclude template="/common_files/jQuery.cfm">
<!--- multiselect dependencies (start) --->
<cfmodule template="/customTags/include.cfm" file_to_include="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css, /styles/jQueryUI_18/jquery.multiselect.css, /Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js, /Script/javascript/jquery.multiselect.filter.js"/>
<!--- multiselect dependencies (end) --->

<cfif NOT isDefined("genSettingsManager") OR NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>
<cfset useLakebaseForGet_Data_Amount_Reason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_auto_close")>
<cfif useLakebaseForGet_Data_Amount_Reason>
	<cftry>
		<cfset Get_Data_Amount_Reason = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_auto_close", {})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Data_Amount_Reason = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data_Amount_Reason>
<CFQUERY NAME="Get_Data_Amount_Reason" DATASOURCE="#Application.Datasource#">
	SELECT *
	FROM DD_Auto_Close
</CFQUERY>
</cfif>

<cfset useLakebaseForGet_Data_Reason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForGet_Data_Reason>
	<cftry>
		<cfset Get_Data_Reason = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_reason_code", {
				"deleted" = "eq.0",
				"display_in" = "in.(1,3)"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Data_Reason = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data_Reason>
<CFQUERY NAME="Get_Data_Reason" DATASOURCE="#Application.Datasource#">
	SELECT *
	FROM DD_Reason_Code
	WHERE Deleted=0
	AND Display_In IN (1,3)
</CFQUERY>
</cfif>

<cfset useLakebaseForGet_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGet_Name>
	<cftry>
		<cfset Get_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"select" = "name_first,name_last",
				"user_id" = "eq.#Get_Data_Amount_Reason.Updated_By_User_ID#"
			}),
			"name_first,name_last"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Name>
<CFQUERY NAME="Get_Name" DATASOURCE="#Application.Datasource#">
	SELECT Name_First,Name_Last
	FROM _Users
	WHERE User_ID = '#Get_Data_Amount_Reason.Updated_By_User_ID#'
</CFQUERY>
</cfif>

<cfset useLakebaseForqGetAutoMatch = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_auto_match")>
<cfif useLakebaseForqGetAutoMatch>
	<cftry>
		<cfset qGetAutoMatch = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_auto_match", {
				"select" = "dd_auto_match_id,enabled,dollar_amount,dollar_amount_value,match_reference_number,match_distributor_bill_to,match_distributor_ship_to,auto_match_dd_reason_code_id,write_off_dd_reason_code_id,use_auto_match_dd_reason_code,use_write_off_dd_reason_code,deduction_status_after_auto_match,write_off_dollar_amount_value,auto_match_reconcile,reconcile_dollar_amount_value"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForqGetAutoMatch = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAutoMatch>
<CFQUERY NAME="qGetAutoMatch" DATASOURCE="#Application.Datasource#">
	SELECT	DD_Auto_Match_ID,Enabled,Dollar_Amount,Dollar_Amount_Value,Match_Reference_Number,Match_Distributor_Bill_To,
				Match_Distributor_Ship_To,Auto_Match_DD_Reason_Code_ID,	Write_Off_DD_Reason_Code_ID,Use_Auto_Match_DD_Reason_Code,
				Use_Write_Off_DD_Reason_Code,Deduction_Status_After_Auto_Match,Write_Off_Dollar_Amount_Value,Auto_Match_Reconcile <!--- 61842 --->
				,Reconcile_Dollar_Amount_Value <!---98653--->
	FROM	DD_Auto_Match
</CFQUERY>
</cfif>

<cfset useLakebaseForqGetBillbackStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_status")>
<cfif useLakebaseForqGetBillbackStatus>
	<cftry>
		<cfset qGetBillbackStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_status", {
				"select" = "billback_status_id,bb_status_description",
				"billback_status_id" = "in.(3,4,5)",
				"order" = "status_order_number.asc"
			}),
			"billback_status_id,bb_status_description"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForqGetBillbackStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBillbackStatus>
<CFQUERY NAME="qGetBillbackStatus" DATASOURCE="#Application.Datasource#">
	SELECT	Billback_Status_ID,BB_Status_Description
	FROM	Billback_Status
	WHERE 	Billback_Status_ID IN (3,4,5)
	ORDER BY Status_Order_Number
</CFQUERY>
</cfif>

<cfset useLakebaseForqGetDDStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_status")>
<cfif useLakebaseForqGetDDStatus>
	<cftry>
		<cfset qGetDDStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_status", {
				"select" = "dd_status_id,dd_status_description",
				"dd_status_id" = "in.(3,4)",
				"order" = "dd_status_order.asc"
			}),
			"dd_status_id,dd_status_description"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForqGetDDStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDDStatus>
<CFQUERY NAME="qGetDDStatus" DATASOURCE="#Application.Datasource#">
	SELECT	DD_Status_ID,DD_Status_Description
	FROM	DD_Status
	WHERE 	DD_Status_ID IN (3, 4)
	ORDER BY DD_Status_Order
</CFQUERY>
</cfif>
<!----D69678 :: Modify Auto Match logic to use Family and Reference only based on the Setting START--->
<cfset bbManager = createObject("component", "components.Billback.BillbackSettingsManager")>
<cfset qGetFamilyList = bbManager.GetFamilyNames()/>
<cfset qGetExistingFamily = bbManager.GetExistingFamilyNames(fromAutoMatch=1,fromAutoDeviation=0)/>
<cfset qGetExistingFamilyList = valuelist(qGetExistingFamily.family_id)>
<!----D69678 :: Modify Auto Match logic to use Family and Reference only based on the Setting END--->

<BR>
<CFIF Get_Data_Amount_Reason.recordcount GT 0 >
<!---
DEV Notes: Anand Rao/04-Nov-09
D21107: Removed the below line from the above if statement so that the updated by
header will show up in the Auto Close/match page even if only the Billback Auto Approve
record shows up.
--->
<!--- AND application.deductionLinksAvailable --->
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_Data_Amount_Reason.Updated_On, 'm/d/yyy')# #timeformat(Get_Data_Amount_Reason.Updated_On, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#Get_Name.Name_First# #Get_Name.Name_Last#</CFOUTPUT></B></FONT>
	</TD>
</TR>
  </TABLE>
<BR>
</CFIF>
<FORM NAME="Auto_Close_Form" ACTION="Auto_Close_Save.cfm" METHOD="Post">
<INPUT TYPE="Hidden" NAME="New_settings" VALUE=<CFIF Get_Data_Amount_Reason.recordcount GT 0>"0"<CFELSE>"1"</CFIF>>

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >

<!---<cfif application.deductionLinksAvailable> --->
<cfif application.appSettingsGet.getDeduction_Module()>
<tr><th colspan="2" align="left"><font color="navy">Deduction Auto Close</font></th></tr>
	<!--- Dev Note: KAL - D7911 Auto Close not allowed checkbox--->
	<TR>
		<TD><B>Do not allow Auto-Close:</B></TD>
		<TD width="500">&nbsp;&nbsp;<CFOUTPUT><INPUT onClick="javascript:EnableAutoCloseAmout(this)"  TYPE="Checkbox" NAME="AutoClose_not_allowed" VALUE="1"></CFOUTPUT></TD>
	</TR>
	<TR id="tr_AutoCloseAmount">
		<TD><BR><B>Close the deductions where the deduction amount is less than or equal to:</B></TD>
		<TD>&nbsp;&nbsp;<CFOUTPUT><INPUT TYPE="Text" NAME="Amount" VALUE="#Get_Data_Amount_Reason.Auto_Close_Amount#" SIZE="5"></CFOUTPUT></TD>
	</TR>
	<TR id="tr_AutoCloseReason">
		<TD><BR><B>Set the reason code for auto-closed deductions to:</B></TD>
		<TD><BR>&nbsp;
			<SELECT NAME="DD_Reason_Code_ID">
				<OPTION VALUE=""></OPTION>
				<CFOUTPUT QUERY="Get_Data_Reason">
				<OPTION VALUE="#DD_Reason_Code_ID#" <CFIF Get_Data_Amount_Reason.DD_Reason_Code_ID EQ DD_Reason_Code_ID>SELECTED</CFIF>>#DD_Reason_Code_Description#</OPTION>
				</CFOUTPUT>
			</SELECT>

		</TD>
	</TR>

	<tr>
		<td colspan="2" height="12px;"><hr width="100%" color="orange"></TD>
	</tr>
	<!---////////////////////////Deduction Auto Match///////////////////////--->
	<tr>
		<th colspan="2" align="left"><font color="navy">Deduction Auto Match</font></th>
	</tr>
	<TR>
		<TD>
			<B>Enable Deduction Auto Match:</B>
		</TD>
		<TD>
			&nbsp;&nbsp<INPUT TYPE="Checkbox" NAME="Enabled" VALUE="1" <cfif qGetAutoMatch.Enabled>checked</cfif> onClick="javascript:disableAutoMatch(this)" /><br>&nbsp;
		</TD>
	</TR>
	<TR>
		<TD>
			<B>Dollar Amount:</B>
			<br>&nbsp;
		</TD>
		<TD>
			&nbsp;&nbsp;<input name="Dollar_Amount" value="1" type="radio" id="ddAutoMatchElement" <cfif not qGetAutoMatch.Enabled>disabled</cfif> <cfif qGetAutoMatch.Dollar_Amount eq 1>checked</cfif>>Equal
			&nbsp;&nbsp;<input name="Dollar_Amount" value="2" type="radio" id="ddAutoMatchElement" <cfif not qGetAutoMatch.Enabled>disabled</cfif> <cfif qGetAutoMatch.Dollar_Amount eq 2>checked</cfif>>Less Than or Greater Than
			<cfoutput>
			<input name="Dollar_Amount_Value" type="text" size="5" value="#qGetAutoMatch.Dollar_Amount_Value#" <cfif not qGetAutoMatch.Enabled>disabled</cfif> id="ddAutoMatchElement" ONKEYUP="clenseText(this,'0123456789.')">
			</cfoutput>
			<br>&nbsp;
		</TD>
	</TR>
	<TR>
		<TD>
			<B>Match Reference Number:</B>
		</TD>
		<TD>
			&nbsp;&nbsp;<INPUT TYPE="Checkbox" NAME="Match_Reference_Number" VALUE="1" id="ddAutoMatchElement" <cfif not qGetAutoMatch.Enabled>disabled</cfif> <cfif qGetAutoMatch.Match_Reference_Number>checked</cfif> />
			<br>&nbsp;
		</TD>
	</TR>
	<TR>
		<TD>
			<B>Match on deduction customer:</B>
			<cf_SmallHelp width="600" dropdownCheck="0">
				<b>Match on deduction customer:</b>
				When this setting is ON, FORGE will match the deduction Ship To to the Payee Ship To from billbacks.
				If a deduction has only a Bill To, then, this setting alone will not consider those deductions.
				The second option below for matching by Bill To would also need to be enabled.
				If this setting is OFF, FORGE will not consider any customer dimension.
				<br><br>

				<b>1. Consider Ship To only:</b>
				When this setting is ON, deductions will consider only the Ship To.
				<br><br>

				<b>2. Consider Bill To when deduction has Bill To only:</b>
				When this setting is ON, FORGE will match the Ship To's associated to the Bill To in the deduction to the Payee Ship To from billbacks.
				If a deduction has both a Bill To and a Ship To, then, those deductions will consider only the Ship To unless the option below for matching ONLY by Bill To is enabled.
				If this setting is OFF, FORGE will consider only the Ship To dimension.
				When this is OFF, deductions that are Bill To only [and do not have a Ship To] will not be considered.
				<br><br>

				<b>3. Consider Bill To only:</b>
				When this setting is ON, FORGE will <u>always</u> match the Ship To's associated to the Bill To in the deduction to the Payee ShipTo from billbacks.
				If a deduction has both a Bill To and a Ship To, then, those deductions will consider only the Bill To.
				<font color="red">If you enable this option, please ensure that our client provides a BillTo with all deductions in the 1500 interface.</font>
				<br><br>
			</cf_SmallHelp>
		</TD>
		<TD>
			&nbsp;&nbsp;<INPUT TYPE="Checkbox" NAME="Match_Distributor_Ship_To" VALUE="1" id="ddAutoMatchElement" <cfif not qGetAutoMatch.Enabled>disabled</cfif> <cfif qGetAutoMatch.Match_Distributor_Ship_To>checked</cfif> onClick="javascript: disableAutoMatchDDCustomer(this);"><br>&nbsp;
		</TD>
	</TR>
	<TR>
		<TD>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B>Consider Ship To only:</B>
		</TD>
		<TD>
			&nbsp;&nbsp;<INPUT TYPE="radio" NAME="Match_Distributor_Bill_To" VALUE="0" <cfif not qGetAutoMatch.Match_Distributor_Ship_To>disabled</cfif> checked><br>&nbsp;
		</TD>
	</TR>
	<TR>
		<TD>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B>Consider Bill To when deduction has Bill To only:</B>
		</TD>
		<TD>
			&nbsp;&nbsp;<INPUT TYPE="radio" NAME="Match_Distributor_Bill_To" VALUE="1" <cfif not qGetAutoMatch.Match_Distributor_Ship_To>disabled</cfif> <cfif qGetAutoMatch.Match_Distributor_Bill_To EQ 1>checked</cfif>><br>&nbsp;
		</TD>
	</TR>
	<TR>
		<TD>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B>Consider Bill To only:</B>
		</TD>
		<TD>
			&nbsp;&nbsp;<INPUT TYPE="radio" NAME="Match_Distributor_Bill_To" VALUE="2" <cfif not qGetAutoMatch.Match_Distributor_Ship_To>disabled</cfif> <cfif qGetAutoMatch.Match_Distributor_Bill_To EQ 2>checked</cfif>><br>&nbsp;
		</TD>
	</TR>
	<!----D69678 :: Modify Auto Match logic to use Family and Reference only based on the Setting START--->
	<TR>
		<TD>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<B>Consider Family:</B>
			<cf_SmallHelp width="400" dropdownCheck="0">
				Auto Match by Family first.  If no match, then auto match on ship to / bill to.
			</cf_SmallHelp>
		</TD>
		<TD>
			<cfset display = "block">
				<cfif not qGetAutoMatch.Match_Distributor_Ship_To OR qGetAutoMatch.Match_Distributor_Bill_To NEQ 3>
					<cfset display = "none">
				</cfif>

			<span style="wiidth:100%;">
				<span style="float: left;width:10%;">&nbsp;
					<INPUT TYPE="radio" NAME="Match_Distributor_Bill_To" VALUE="3" id="FamilyBox" <cfif not qGetAutoMatch.Match_Distributor_Ship_To>disabled</cfif> <cfif qGetAutoMatch.Match_Distributor_Bill_To EQ 3>checked</cfif>><br>&nbsp;
				</span>
				<cfset display = "block">
				<cfif not qGetAutoMatch.Match_Distributor_Ship_To OR qGetAutoMatch.Match_Distributor_Bill_To NEQ 3>
					<cfset display = "none">
				</cfif>
				<span style="float:left;width:55%;display: <cfoutput>#display#</cfoutput>" id="Family_List">
					<select name="familyList" multiple="multiple" id="familyList">
					<cfoutput query="qGetFamilyList">
						<option value="#family_id#" <cfif listfind(qGetExistingFamilyList, family_id)>Selected</cfif>>#Family_Name#</option>
					</cfoutput>
					</select>
				</span>

				<cfoutput>
				<span style="float:right;width:30%;">
					<cfif qGetFamilyList.recordcount GTE 1000>
						<a href="javascript:(void);" onclick="javascript:selectAllOptions()">
							#application.util.string.actionLinkFormat2('Select All')#
						</a><br><br>
					</cfif>
					<cfif qGetExistingFamily.recordcount>
						<a href="javascript:(void);" onclick="javascript:window.open('Auto_Match_Deviations_Family_List.cfm?fromAutoMatch=1','AutoMatchFamily','toolbar=no,width=600,height=600,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false">
							#application.util.string.actionLinkFormat2('View Selected Families')#
						</a>
					</cfif>
				</span>
				</cfoutput>
			</span>
		<br>&nbsp;
		</TD>
	</TR>
	<!----D69678 :: Modify Auto Match logic to use Family and Reference only based on the Setting END--->
	<TR>
		<TD><BR><B>Deduction status if auto matched:</B></TD>
		<TD><BR>&nbsp;
			<SELECT NAME="Deduction_Status_After_Auto_Match" id="ddAutoMatchElement" <cfif not qGetAutoMatch.Enabled>disabled</cfif>>
				<CFOUTPUT QUERY="qGetDDStatus">
				<OPTION VALUE="#DD_Status_ID#" <CFIF qGetAutoMatch.Deduction_Status_After_Auto_Match EQ DD_Status_ID>SELECTED</CFIF>>#DD_Status_Description#</OPTION>
				</CFOUTPUT>
			</SELECT>
			<br>&nbsp;
		</TD>
	</TR>
	<TR>
		<TD>
			<B>Use below Auto Match Reason Code:</B>
		</TD>
		<TD>
			&nbsp;&nbsp;<INPUT TYPE="Checkbox" NAME="Use_Auto_Match_DD_Reason_Code" VALUE="1" id="ddAutoMatchElement" onClick="javascript: disableAutoMatchReasonCode(this);" <cfif not qGetAutoMatch.Enabled>disabled</cfif> <cfif qGetAutoMatch.Use_Auto_Match_DD_Reason_Code>checked</cfif>><br>&nbsp;
		</TD>
	</TR>
	<TR id="tr_AutoMatchReason" <cfif not qGetAutoMatch.Use_Auto_Match_DD_Reason_Code>disabled</cfif>>
		<TD><BR><B>Auto Match Reason Code:</B></TD>
		<TD><BR>&nbsp;
			<SELECT NAME="Auto_Match_DD_Reason_Code_ID">
				<OPTION VALUE="0"></OPTION>
				<CFOUTPUT QUERY="Get_Data_Reason">
				<OPTION VALUE="#DD_Reason_Code_ID#" <CFIF qGetAutoMatch.Auto_Match_DD_Reason_Code_ID EQ DD_Reason_Code_ID>SELECTED</CFIF>>#DD_Reason_Code_Description#</OPTION>
				</CFOUTPUT>
			</SELECT>
			<br>&nbsp;
		</TD>
	</TR>
	<cfif appsettings.getGL_Account_On()>
	<TR>
		<TD><BR><B>Auto Match <cfoutput>#Application.GLAccountLabel#</cfoutput> Code:</B><br>&nbsp;</TD><!---D42774 --->
		<TD>&nbsp;&nbsp;<CFOUTPUT QUERY="Get_Data_Reason"><CFIF qGetAutoMatch.Auto_Match_DD_Reason_Code_ID EQ DD_Reason_Code_ID>#GL_Account_Code#</cfif></cfoutput></TD>
	</TR>
	</cfif>
	<!--- 61842 Start --->
	<TR>
		<TD><BR><B>Auto match Reconcile:</B><br>&nbsp;</TD>
		<TD>	&nbsp;&nbsp;<INPUT TYPE="Checkbox" NAME="Auto_Match_Reconcile" VALUE="1" <cfif qGetAutoMatch.Auto_Match_Reconcile>checked</cfif>><br>&nbsp;</TD>
	</TR>
	<!--- 61842 End --->
<!--- 98653 Match Central auto reconcile error START --->
	<TR>
		<TD><B>Match Central Auto Reconcile Dollar Amount:</B><br>&nbsp;</TD>
		<TD>
			<cfoutput>
			<input name="Reconcile_Dollar_Amount_Value" type="text" size="5" value="#qGetAutoMatch.Reconcile_Dollar_Amount_Value#" <cfif not qGetAutoMatch.Enabled>disabled</cfif> ONKEYUP="clenseText(this,'0123456789.')">
			</cfoutput>
			<br>&nbsp;
		</TD>
	</TR>
<!--- 98653 Match Central auto reconcile error END --->
	<cfif appSettings.getDDAllowWriteOff()>
	<TR>
		<TD>
			<B>Write Off Dollar Amount:</B>
			<br>&nbsp;
		</TD>
		<TD>
			<cfoutput>
			<input name="Write_Off_Dollar_Amount_Value" type="text" size="5" value="#qGetAutoMatch.Write_Off_Dollar_Amount_Value#" <cfif not qGetAutoMatch.Enabled>disabled</cfif> id="ddAutoMatchElement" ONKEYUP="clenseText(this,'0123456789.')">
			</cfoutput>
			<br>&nbsp;
		</TD>
	</TR>
	</cfif>

	<TR>
		<TD>
			<B>Use below Write Off Reason Code:</B>
		</TD>
		<TD>
			&nbsp;&nbsp;<INPUT TYPE="Checkbox" NAME="Use_Write_Off_DD_Reason_Code" VALUE="1" id="ddAutoMatchElement" onClick="javascript: disableWriteOffReasonCode(this);" <cfif not qGetAutoMatch.Enabled>disabled</cfif> <cfif qGetAutoMatch.Use_Write_Off_DD_Reason_Code>checked</cfif>><br>&nbsp;
		</TD>
	</TR>
	<TR id="tr_WriteOffReason" <cfif not qGetAutoMatch.Use_Write_Off_DD_Reason_Code>disabled</cfif>>
		<TD><BR><B>Write Off Reason Code:</B></TD>
		<TD><BR>&nbsp;
			<SELECT NAME="Write_Off_DD_Reason_Code_ID">
				<OPTION VALUE="0"></OPTION>
				<CFOUTPUT QUERY="Get_Data_Reason">
				<OPTION VALUE="#DD_Reason_Code_ID#" <CFIF qGetAutoMatch.Write_Off_DD_Reason_Code_ID EQ DD_Reason_Code_ID>SELECTED</CFIF>>#DD_Reason_Code_Description#</OPTION>
				</CFOUTPUT>
			</SELECT>

		</TD>
	</TR>
	<cfif appsettings.getGL_Account_On()>
	<TR>
		<TD><BR><B>Write Off <cfoutput>#Application.GLAccountLabel#</cfoutput> Code:</B></TD><!---D42774 --->
		<TD>&nbsp;&nbsp;<cfoutput query="Get_Data_Reason"><cfif qGetAutoMatch.Write_Off_DD_Reason_Code_ID EQ DD_Reason_Code_ID>#GL_Account_Code#</cfif></cfoutput></TD>
	</TR>
	</cfif>
	<cfoutput>
	<input type="hidden" name="DD_Auto_Match_ID" value="#qGetAutoMatch.DD_Auto_Match_ID#" />
	</cfoutput>
	<tr><Td colspan="2" height="12px;"><hr width="100%" color="orange"></TD></tr>

	<TR>
		<TD COLSPAN="100%" ALIGN="Center">
			<BR><BR>
			<CF_button
				button_name		=	""
				button_caption	=	"save data"
				button_action	=	"Validate()"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
	</TR>
</cfif>
</TABLE>
</FORM>
<SCRIPT language="JavaScript">
function Validate(){
	var error = 0;
	if($('input[name=Match_Distributor_Bill_To]:checked').val() == 3){
		var options = $('#familyList > option:selected');
		if(options.length == 0){
			alert("Please Select A Family.");
			error = 1;
		}
	}
	if(error ==0)	{
		document.all.Auto_Close_Form.submit();
	}
}

function AutoApprove()
{
	document.location = 'auto_close_exceptions.cfm'
}
function FamilyRecords(val){
	if (val == 1){
		document.all.FamilyList.style.display = "block";
	}
	else {
		document.all.FamilyList.style.display = "none";
	}
}
<!---<cfif application.deductionLinksAvailable> --->
<cfif application.appSettingsGet.getDeduction_Module()>
function EnableAutoCloseAmout(thisObj)
	{
		// Dev Note: KAL - D7911 Auto Close not allowed checkbox
		// this function enables or disbales Auto Close Amount Text Box
		var formObj1	= 	document.all.Amount;
		var formObj2	= 	document.all.DD_Reason_Code_ID;
		if(thisObj.checked)
		{
			formObj1.value = '';
			formObj1.disabled = true;
			formObj2.value = '';
			formObj2.disabled = true;
			document.all.tr_AutoCloseAmount.disabled = true;
			document.all.tr_AutoCloseReason.disabled = true;
		}
		else
		{
			document.all.tr_AutoCloseAmount.disabled = false;
			document.all.tr_AutoCloseReason.disabled = false;
			formObj1.disabled = false;
			formObj2.disabled = false;
			formObj1.value = '<cfoutput>#Get_Data_Amount_Reason.Auto_Close_Amount#</cfoutput>';
			formObj2.value = '<cfoutput>#Get_Data_Amount_Reason.DD_Reason_Code_ID#</cfoutput>';
		}
	}
	<cfif Get_Data_Amount_Reason.Auto_Close_Amount EQ "">
			var thisObj = document.all.AutoClose_not_allowed;
			thisObj.checked = true;
			EnableAutoCloseAmout(thisObj);
	</cfif>
</cfif>

	function disableAutoMatch(enableObj)
	{
		var oAutoMatchControls=document.getElementsByTagName("input");

		enableDisable(enableObj.checked, oAutoMatchControls);

		oAutoMatchControls=document.getElementsByTagName("select");

		enableDisable(enableObj.checked, oAutoMatchControls);

		disableAutoMatchReasonCode(document.all.Use_Auto_Match_DD_Reason_Code);
		disableWriteOffReasonCode(document.all.Use_Write_Off_DD_Reason_Code);
		disableAutoMatchDDCustomer(document.all.Match_Distributor_Ship_To);

	}

	function enableDisable(bEnable, controlCollection)
	{
		for(i=0; i <= controlCollection.length; i++)
		{
			if(typeof(controlCollection[i]) == 'object' && controlCollection[i].id == 'ddAutoMatchElement')
			{
				if(bEnable)
					controlCollection[i].disabled = false;
				else
					controlCollection[i].disabled = true;
			}
		}
	}

	function disableAutoMatchReasonCode(enableObj)
	{
		if(enableObj.checked && !enableObj.disabled)
			document.all.tr_AutoMatchReason.disabled = false;
		else
			document.all.tr_AutoMatchReason.disabled = true;

	}

	function disableWriteOffReasonCode(enableObj)
	{
		if(enableObj.checked && !enableObj.disabled)
			document.all.tr_WriteOffReason.disabled = false;
		else
			document.all.tr_WriteOffReason.disabled = true;

	}

	function disableAutoMatchDDCustomer(enableObj)
	{
		var bDisable;
		var oRadioCollection = document.all.Match_Distributor_Bill_To;
		if(enableObj.checked && !enableObj.disabled)
			bDisable = false;
		else
			bDisable = true;


		for(i=0; i <= oRadioCollection.length; i++)
		{
			oRadioCollection[i].disabled = bDisable;
		}

	}
	// save all multie select dropdowns on the page into an array
	var dropdowns = ["#familyList"];
	//D69678 :: Modify Auto Match logic to use Family and Reference only based on the Setting

	// pass all dropdowns to multi_select() to filter out large dropdowns and apply multiselect()
	$(multi_select( dropdowns )).multiselect();

    $("INPUT[name=Match_Distributor_Bill_To]").click(function() {
    		if($(this).val() == 3){
    			$("#Family_List").show();
    		}else{
    			$("#Family_List").hide();
    		}
	});
     function selectAllOptions() {
        $('#familyList option').each(function () {
            $(this).attr('selected', true);
        });
    }
</script>
</body>
</html>
