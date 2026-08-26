	<cfsilent>

	<cfset useLakebaseForqGetToleranceSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_tolerance_settings")>
<cfif useLakebaseForqGetToleranceSettings>
	<cftry>
		<cfset qGetToleranceSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_tolerance_settings", {
				"select" = "billback_tolerance_settings_id,cannot_exceed_percent,cannot_exceed_dollar,billback_status_id_below,billback_status_id_exceed,auto_deviation_inc_manual_bb,maximum_dollar_amount_checked,maximum_dollar_amount,billback_status_for_max_dollar_amt,last_updated_date,last_updated_by,auto_deviation_family_level,billback_ls_auto_process_amt,autoprocess_check_bb_beyond_budget"
			}), "billback_tolerance_settings_id,cannot_exceed_percent,cannot_exceed_dollar,billback_status_id_below,billback_status_id_exceed,auto_deviation_inc_manual_bb,maximum_dollar_amount_checked,maximum_dollar_amount,billback_status_for_max_dollar_amt,last_updated_date,last_updated_by,auto_deviation_family_level,billback_ls_auto_process_amt,autoprocess_check_bb_beyond_budget"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetToleranceSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetToleranceSettings>
<CFQUERY NAME="qGetToleranceSettings" DATASOURCE="#Application.Datasource#">
		SELECT	Billback_Tolerance_Settings_ID,
				Cannot_Exceed_Percent,
				Cannot_Exceed_Dollar,
				Billback_Status_ID_Below,
				Billback_Status_ID_Exceed,
				Auto_Deviation_Inc_Manual_BB,
				Maximum_Dollar_Amount_Checked,
				Maximum_Dollar_Amount,
				Billback_Status_For_Max_Dollar_Amt,
				Last_Updated_Date,
				Last_Updated_By,
				Auto_Deviation_Family_Level,
				Billback_LS_Auto_Process_Amt,
				AutoProcess_Check_BB_Beyond_Budget
		FROM	Billback_Tolerance_Settings
	</CFQUERY>
</cfif>

	<CFQUERY NAME="qGetBillbackStatus" DATASOURCE="#Application.Datasource#">
		SELECT	Billback_Status_ID,
				BB_Status_Description
		FROM	Billback_Status
		WHERE 	Billback_Status_ID NOT IN (1,5,6,7,8)
		ORDER BY Status_Order_Number
	</CFQUERY>

	<cfquery NAME="qGetClosingMethods" datasource="#application.datasource#">
		SELECT	*
		FROM  	Billback_Closing_Methods
		WHERE	bEnabled = 1
		ORDER BY vchBillback_Closing_Method_Desc
	</cfquery>

	<cfset useLakebaseForqGetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqGetUserName>
	<cftry>
		<cfset qGetUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#qGetToleranceSettings.Last_Updated_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetUserName>
<CFQUERY NAME="qGetUserName" DATASOURCE="#Application.Datasource#">
		SELECT	Name_First,Name_Last
		FROM 	_Users
		WHERE 	User_ID = '#qGetToleranceSettings.Last_Updated_By#'
	</CFQUERY>
</cfif>

<!----D74179 :: Auto Deviations at Family level START--->
	<cfset bbManager = createObject("component", "components.Billback.BillbackSettingsManager")>
	<cfset qGetFamilyList = bbManager.GetFamilyNames()/>
	<cfset qGetExistingFamily = bbManager.GetExistingFamilyNames(fromAutoMatch=0,fromAutoDeviation=1)/>
	<cfset qGetExistingFamilyList = valuelist(qGetExistingFamily.family_id)>
<!----D74179 :: Auto Deviations at Family level END--->

</cfsilent>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
</head>
<cfinclude template="/common_files/jQuery.cfm">
<!--- multiselect dependencies (start) --->
<cfmodule template="/customTags/include.cfm" file_to_include="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css, /styles/jQueryUI_18/jquery.multiselect.css, /Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js, /Script/javascript/jquery.multiselect.filter.js"/>
<!--- multiselect dependencies (end) --->

<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" Onload="ShowHideLayer('Max_Dollar_Amount'); ShowHideLayer('Billback_Status_for_Max_Dollar Amt')">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET URL.PageTitle="Interface Payables">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfoutput>
<BR>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
		<TD>
			<FONT SIZE="2"><B>This setting was last updated on #dateformat(qGetToleranceSettings.Last_Updated_Date, 'mm/dd/yyyy')# by #qGetUserName.Name_First# #qGetUserName.Name_Last#</B></FONT>
		</TD>
	</TR>
</TABLE>
<BR>

<FORM name="interface_payables" ACTION="interface_payables_save.cfm" METHOD="Post">

<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="2" width="1250">
	<tr>
		<th colspan="2" align="left">
			<font color="navy">Billback Tolerance Settings</font>
		</th>
	</tr>
	<TR>
		<TD style="width:300px;"><B>Deviation Cannot Exceed %:</B></TD>
		<TD><input type="text" name="Cannot_Exceed_Percent" value="#qGetToleranceSettings.Cannot_Exceed_Percent#" size="5" ONKEYUP="clenseText(this,'0123456789.')" /></TD>
	</TR>
	<TR>
		<TD><B>Deviation Cannot Exceed $:</B></TD>
		<TD><input type="text" name="Cannot_Exceed_Dollar" value="#qGetToleranceSettings.Cannot_Exceed_Dollar#" size="5" ONKEYUP="clenseText(this,'0123456789.')" /></TD>
	</TR>
	<tr>
		<td colspan="100%">
			<table cellpadding="1" cellspacing="1" border="0">
				<tr>
					<td>&nbsp;</td>
					<cfloop list="#ValueList(qGetClosingMethods.vchBillback_Closing_Method_Desc)#" index="indx">
						<td>
							<b>#indx#</b>
						</td>
					</cfloop>
				</tr>

				<TR>
					<TD><B>Billback Status if Below Deviation:</B></TD>
					<cfloop query="qGetClosingMethods">
						<TD>
							<select name="#iBillback_Closing_Method_ID#_Auto_Dev_BB_Status_Below">
								<cfloop query="qGetBillbackStatus">
									<option value="#Billback_Status_ID#" <cfif qGetClosingMethods.Auto_Dev_BB_Status_Below eq Billback_Status_ID>selected</cfif>>#BB_Status_Description#</option>
								</cfloop>
							</select>
						</TD>
					</cfloop>
				</TR>
				<TR>
					<TD><B>Billback Status if Exceeds Deviation:</B></TD>
					<cfloop query="qGetClosingMethods">
						<TD>
							<select name="#iBillback_Closing_Method_ID#_Auto_Dev_BB_Status_Exceed">
								<cfloop query="qGetBillbackStatus">
									<option value="#Billback_Status_ID#" <cfif qGetClosingMethods.Auto_Dev_BB_Status_Exceed eq Billback_Status_ID>selected</cfif>>#BB_Status_Description#</option>
								</cfloop>
							</select>
						</TD>
					</cfloop>
				</TR>

			</table>
		</td>
	</tr>
	<TR>
		<TD><B>Include Max Dollar Amt:</B></TD>
		<TD>
			<CFSET Maximum_Dollar_Amount_Checked = "">
			<CFIF qGetToleranceSettings.Maximum_Dollar_Amount_Checked EQ 1>
				<CFSET Maximum_Dollar_Amount_Checked = "Checked">
			</CFIF>
			<INPUT TYPE="CheckBox" NAME="Maximum_Dollar_Amount_Checked" ID="Maximum_Dollar_Amount_Checked" VALUE="1" Onclick="ShowHideLayer('Max_Dollar_Amount'); ShowHideLayer('Billback_Status_for_Max_Dollar Amt')" #Maximum_Dollar_Amount_Checked#>
		</TD>
	</TR>
	<TR id="Max_Dollar_Amount" style="display:none;">
		<TD><B>Claim dollars cannot equal or exceed $:</B></TD>
		<TD><input type="text" name="Maximum_Dollar_Amount" value="#qGetToleranceSettings.Maximum_Dollar_Amount#" size="5" ONKEYUP="clenseText(this,'0123456789')" /></TD>
	</TR>
	<!--- Dev Note: 18185 (Milan). Currently, we can set the billback to only RFA for billbacks
				>= maximum dollar amount. If you add any more statuses here, make a corresponding change in
				stored procedure - "BB_Auto_Deviation".
	--->
	<TR id="Billback_Status_for_Max_Dollar Amt" style="display:none;">
		<TD><B>If Claim Equals or Exceeds maximum, set status to:</B></TD>
		<TD>
			<select name="Billback_Status_For_Max_Dollar_Amt">
				<cfloop query="qGetBillbackStatus">
					<cfif Billback_Status_ID eq 2>
						<option value="#Billback_Status_ID#" <cfif qGetToleranceSettings.Billback_Status_For_Max_Dollar_Amt eq Billback_Status_ID>selected</cfif>>#BB_Status_Description#</option>
					</cfif>
				</cfloop>
			</select>
		</TD>
	</TR>
	<TR>
		<TD><B>Include manually entered billbacks in auto processing:</B></TD>
		<TD>
			<CFSET Inc_Manual = "">
			<CFIF qGetToleranceSettings.Auto_Deviation_Inc_Manual_BB EQ 1>
				<CFSET Inc_Manual = "Checked">
			</CFIF>
			<INPUT TYPE="CheckBox" NAME="Auto_Deviation_Inc_Manual_BB" VALUE="1" #Inc_Manual#>
		</TD>
	</TR>
<!--- 97865 - LS BB Controls START --->
<TR>
	<TD style="width:300px;"><B>Include lump sum billbacks in auto processing if lump sum claimed amount does not exceed:</B></TD>
	<TD><input type="text" name="Billback_LS_Auto_Process_Amt" value="#qGetToleranceSettings.Billback_LS_Auto_Process_Amt#" size="5" ONKEYUP="clenseText(this,'0123456789.')" /></TD>
</TR>
<!--- 97865 - LS BB Controls END --->
<!--- 74179 :: Auto Deviations at Family level START --->
	<TR>
		<TD><B>Auto Deviations at Family Level:</B></TD>
		<TD>
			<CFSET Inc_Manual = "">
			<cfset display = 'none'>
			<CFIF qGetToleranceSettings.Auto_Deviation_Family_Level EQ 1>
				<CFSET Inc_Manual = "Checked">
				<cfset display = 'block'>
			</CFIF>

			<span style="width: 100%">
				<span style="float: left;width:5%;">
					<INPUT TYPE="CheckBox" NAME="Auto_Deviation_Family_Level" VALUE="1" #Inc_Manual# id="FamilyCheckBox">
				</span>
				<span style="display:#display#;float:left;width:35%;" id="Family_List">
					<select name="familyList" multiple="multiple" id="familyList" style="width: 300px;">
						<cfloop query="qGetFamilyList">
						<option value="#family_id#" <cfif listfind(qGetExistingFamilyList, family_id)>Selected</cfif>>#Family_Name#</option>
						</cfloop>
					</select>
				</span>
				<cfif qGetExistingFamily.recordcount>
				<span style="float:right;width:58%;">
					<cfoutput>
					<a href="javascript:(void);" onclick="javascript:window.open('/deductions/settings/Auto_Match_Deviations_Family_List.cfm?fromAutoDeviation=1','AutoDeviationFamily','toolbar=no,width=600,height=600,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false">
						#application.util.string.actionLinkFormat2('View Selected Families')#
					</a>
				</cfoutput>
				</span>
				</cfif>
			</span>
		</TD>
	</TR>
<!--- 74179 :: Auto Deviations at Family level END --->

<!--- 98106 - Auto Deviations to consider if bb is beyond program budget START --->
<TR>
	<TD style="width:300px;"><B>When budgets functionality is on, auto processing to consider if billback is beyond program budget:</B></TD>
	<TD><input type="checkbox" name="AutoProcess_Check_BB_Beyond_Budget" value="1" <cfif qGetToleranceSettings.AutoProcess_Check_BB_Beyond_Budget>Checked</cfif>/></TD>
</TR>
<!--- 98106 - Auto Deviations to consider if bb is beyond program budget END --->

	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><BR><BR>
			<CF_button
				button_name		=	""
				button_caption	=	"save"
				button_action	=	"Validate();"
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
</TABLE>
<input type="hidden" name="Billback_Tolerance_Settings_ID" value="#qGetToleranceSettings.Billback_Tolerance_Settings_ID#" />
<input type="hidden" name="Billback_Closing_Method_ID_List" value="#ValueList(qGetClosingMethods.iBillback_Closing_Method_ID)#" />

</FORM>
</cfoutput>
<script language="javascript">
    $("#familyList").multiselect().multiselectfilter();
    $('#FamilyCheckBox').click(function() {
    		$("#Family_List").toggle(this.checked);
	});

	function ShowHideLayer(layerName)
	{
		if(document.all.Maximum_Dollar_Amount_Checked.checked == 1)
		{
			document.getElementById(layerName).style.display='block';
		}
		else
		{
			document.getElementById(layerName).style.display='none'
		}
	}

	function Validate(){
		var error = 0;
		if(document.all.Auto_Deviation_Family_Level.checked == 1){
			var options = $('#familyList > option:selected');
			if(options.length == 0){
				alert("Please Select A Family.");
				error = 1;
			}
		}
		if (document.all.Maximum_Dollar_Amount_Checked.checked == 1){
			if (document.all.Maximum_Dollar_Amount.value == "")	{
				alert("Please Enter A Max Dollar Amount.");
				document.all.Maximum_Dollar_Amount.focus();
				error = 1;
			}
		}
		if(error ==0)	{
			document.all.interface_payables.submit();
		}
	}
</script>
</body>
</html>
