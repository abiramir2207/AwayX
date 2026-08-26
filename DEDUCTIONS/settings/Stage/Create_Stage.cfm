<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<CFSET URL.PageTitle="Deductions: #UCase(stDeductionLabels["Action"])# LIST MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
<cfif useLakebaseForGet_Data>
	<cftry>
		<cfset Get_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_stage", {
				"order" = "dd_stage_description.asc"
			}),
			"dd_stage_id,dd_stage_description,deleted,is_default,is_auto_reminded,auto_default_days"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Data>
<CFQUERY NAME="Get_Data" datasource="#application.datasource#">
	Select		*
	From		DD_Stage
	Order by	DD_Stage_Description
</CFQUERY>
</cfif>
<!--- 70923 :: Create new feature for deduction workflow --->
<cfset Get_Existing_Analyst_Profile = createObject("component", "components.Deduction.DeductionManager").getExistingAnalystProfile()/>

<TABLE "actionTable" BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
<TR>
	<TD VALIGN="top">

		<SPAN CLASS="title2">Stored Records</SPAN>
		<HR COLOR="Blue" SIZE="1">

		<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable" id="stageTable">
			<TR>
				<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
				<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
				<Td>&nbsp; </TD>
				<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Auto Reminder Days</B></SPAN></TD>
			</TR>
			<CFOUTPUT QUERY="Get_Data">
			<TR>
				<TD NOWRAP><A HREF="create_Stage.cfm?RID=#DD_Stage_ID#">#DD_Stage_Description#</A></TD>
				<TD NOWRAP>
						<CFIF Deleted EQ 0>
						<IMG SRC="/images/yes_small.gif" TITLE="active record...">
						<CFELSE>
						<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
						</CFIF>
				</TD>
				<td>
					<cfif Is_Default IS 1>
					default
					<cfelse>
					&nbsp;
					</cfif>
				</td>
				<td align="right">
					<cfif Is_Auto_Reminded><IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"></cfif>#Auto_Default_Days#
				</td>
			</TR>
			</CFOUTPUT>
		</TABLE>

		<BR>

		<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
		<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record

	</TD>
	<TD VALIGN="top">

		<SPAN CLASS="title2">Edit Record</SPAN>
		<HR COLOR="Blue" SIZE="1">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for the ID of the item passed --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFPARAM NAME="URL.RID" DEFAULT="0">
<CFPARAM NAME="Get_Item.DD_Stage_Description" DEFAULT="">
<CFPARAM NAME="Get_Item.DD_Stage_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">
<CFPARAM NAME="Get_Item.Is_Default" DEFAULT="0">


<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		DD_Stage
	Where		DD_Stage_ID	like	'#URL.RID#'
</CFQUERY>

<SCRIPT language="JavaScript">
function alert_and_delete()
{
 	var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
	if (confirmdelete == true)
	{
		document.all.DeleteRecord.value=1;
		document.MyForm.submit();
	}
}

function Validate()
{
	if (document.all.DD_Stage_Description.value == "")
	{
		alert("Please enter some description.");
		document.all.DD_Stage_Description.focus();
		return;
	}
	<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
	if(document.all.Action_Analyst_Profile.value =='' ){
		alert("Please select an analyst profile.");
		document.all.Action_Analyst.focus();
		return;
	}
	</cfif>
	if (document.all.Actual_Default.value == 1 && (document.all.Deleted[1].checked || document.all.Is_Default.checked == false))
	{
		var formObj = document.MyForm;
		formObj.action = "DeleteDefault.cfm";
		NewWindow("", 'delDef', '500', '200', 'Yes', 'No', true);
		formObj.target = "delDef";
		document.MyForm.submit();
		return
	}
	else
	{
		document.MyForm.submit();
	}
}
</SCRIPT>

<!--- 70923 :: Create new feature for deduction workflow START--->
<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
<!--- multiselect dependencies (start) --->
<cfmodule template="/customTags/include.cfm" file_to_include="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css, /styles/jQueryUI_18/jquery.multiselect.css" />
<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js, /Script/javascript/jquery.multiselect.filter.js"/>
<!--- multiselect dependencies (end) --->

<cfif Get_Item.recordcount EQ 0>
	<cfset DDStageID = 0>
<cfelse>
	<cfset DDStageID = Get_Item.DD_Stage_ID>
</cfif>
<cfset Get_Action_Analyst_Profile = createObject("component", "components.Deduction.DeductionManager").getActionAnalystProfile(DDStageID)/>
</cfif>
<!--- 70923 :: Create new feature for deduction workflow END--->

		<FORM ACTION="save_Stage.cfm" METHOD="post" NAME="MyForm" id="MyForm">
		<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="Actual_Default" VALUE="#Get_Item.Is_Default#">
		</CFOUTPUT>
		<TABLE CELLSPACING="5" CELLPADDING="0">
			<TR>
				<TD VALIGN="top" ALIGN="right"><B>Description</B></TD>
				<TD VALIGN="top">
					<CFOUTPUT>
						<INPUT SIZE="55" NAME="DD_Stage_Description" VALUE="#Get_Item.DD_Stage_Description#" MAXLENGTH="20">
						<INPUT TYPE="hidden" NAME="DD_Stage_ID" VALUE="#Get_Item.DD_Stage_ID#">
					</CFOUTPUT>
				</TD>
			</TR>
			<TR>
				<TD VALIGN="top" ALIGN="right"><B>Auto Reminder Days</B></TD>
				<TD VALIGN="top">
					<CFOUTPUT>
						<INPUT SIZE="55" NAME="DD_Stage_Auto_Reminder_Days" VALUE="#Get_Item.Auto_Default_Days#" MAXLENGTH="20">
					</CFOUTPUT>
				</TD>
			</TR>
			<!--- 70923 :: Create new feature for deduction workflow START --->
			<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
			<TR>
				<TD VALIGN="top" ALIGN="right"><B>Select Analyst</B></TD>
				<TD VALIGN="top">
					<SELECT NAME="Action_Analyst_Profile" id="ActionAnalyst" multiple="multiple">
					<CFOUTPUT query="Get_Existing_Analyst_Profile">
						<OPTION VALUE="#Profiles_ID#" <cfif ListFindNoCase(ValueList(Get_Action_Analyst_Profile.Profiles_ID), Profiles_ID)>SELECTED</cfif>>#Profiles_Desc#</OPTION>
					</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			</cfif>
			<!--- 70923 :: Create new feature for deduction workflow END --->
			<TR>
				<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
				<TD VALIGN="top">
				<!--- Is this record deleted? --->
				<CFIF Get_Item.Deleted EQ 0 OR Get_Item.Deleted EQ "">
					<CFSET active=" CHECKED">
					<CFSET inactive="">
				<CFELSE>
					<CFSET active="">
					<CFSET inactive=" CHECKED">
				</CFIF>

				<CFOUTPUT>
				<INPUT TYPE="radio" VALUE="0" NAME="Deleted"#active#>Active
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
				<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#>Inactive

				</CFOUTPUT>

				</TD>
			</TR>
			<tr>
			<td valign="top" align="right"><strong>Default</strong></td>
			<td valign="top">

				<INPUT TYPE="CheckBox" VALUE="1" NAME="Is_Default" <CFIF Get_Item.Is_Default EQ 1>CHECKED</CFIF>>Yes
			</td>
			</tr>
			<tr>
				<td valign="top" align="right">
					<b>Auto Reminder</b>
				</td>
				<td><INPUT TYPE="CheckBox" VALUE="1" NAME="autoReminder" <CFIF Get_Item.Is_Auto_Reminded EQ 1>CHECKED</CFIF> onClick=""></td>
			</tr>

			<TR>
				<TD VALIGN="top" ALIGN="right"></TD>
				<TD VALIGN="top">
					<A HREF="javascript: Validate()"><cfoutput>#application.util.string.actionLinkFormat2('save data')#</cfoutput></A>
				<INPUT TYPE="hidden" NAME="DeleteRecord" VALUE="0">
				<CFIF Get_Item.Deleted EQ 1>
					<A HREF="javascript: alert_and_delete();"><cfoutput>#application.util.string.actionLinkFormat2('delete data')#</cfoutput></A>
				</CFIF>
				</TD>
			</TR>
		</TABLE>
		</FORM>
	</TD>
</TR>
</TABLE>
<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
<script>
	$("#ActionAnalyst").multiselect().multiselectfilter();
</script>
</cfif>
<A HREF="create_Stage.cfm"><cfoutput>#application.util.string.actionLinkFormat2('create new entry')#</cfoutput></A>