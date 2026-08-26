<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfset stDeductionLabels = createObject("component", "components.settings.Labels.Labels").init().GetDeductionLabelsStruct() />
<CFSET URL.PageTitle="Deductions: #UCase(stDeductionLabels["Classification"])# LIST MANAGEMENT">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the data for this item  --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
<cfif useLakebaseForGet_Data>
	<cftry>
		<cfset Get_Data = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_classification", {
				"order" = "dd_classification_desc.asc"
			}),
			"dd_classification_id,dd_classification_desc,deleted,is_default,is_matchcentral_default"
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
	From		DD_Classification
	Order by	DD_Classification_Desc
</CFQUERY>
</cfif>
<!--- 70923 :: Create new feature for deduction workflow --->
<cfset Get_Existing_Analyst_Profile = createObject("component", "components.Deduction.DeductionManager").getExistingAnalystProfile()/>

<TABLE "actionTable" BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
<TR>
<TD VALIGN="top">
	<SPAN CLASS="title2">Stored Records</SPAN>
	<HR COLOR="Blue" SIZE="1">
	<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="275" CLASS="Maintable" id="stageTable">
	<TR>
		<TD NOWRAP width="125px" valign="bottom"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
		<TD NOWRAP width="50px" valign="bottom" align="center"><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
		<TD NOWRAP width="50px" valign="bottom" align="center"><SPAN STYLE="font-size: 12px;"><B>System <br />Default</B></SPAN></TD>
		<TD NOWRAP width="50px" valign="bottom" align="center"><SPAN STYLE="font-size: 12px;"><B>Match <br />Central <br />Default</B></SPAN></TD>
	</TR>
	<CFOUTPUT QUERY="Get_Data">
	<TR>
		<TD NOWRAP><A HREF="create_Classifications.cfm?RID=#DD_Classification_ID#">#DD_Classification_Desc#</A></TD>
		<TD NOWRAP align="center">
			<CFIF Deleted EQ 0>
				<IMG SRC="/images/yes_small.gif" TITLE="active record...">
			<CFELSE>
				<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
			</CFIF>
		</TD>
		<TD align="center">
			<cfif Is_Default IS 1>
				<IMG SRC="/images/checkmark.gif" TITLE="Is System Default">
			<cfelse>
				&nbsp;
			</cfif>
		</TD>
		<TD align="center">
			<cfif Is_MatchCentral_Default IS 1>
				<IMG SRC="/images/checkmark.gif" TITLE="Is Match Central Default - (Only for billback/deduction closing.)">
			<cfelse>
				&nbsp;
			</cfif>
		</TD>
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
<CFPARAM NAME="Get_Item.DD_Classification_Description" DEFAULT="">
<CFPARAM NAME="Get_Item.DD_Classification_ID" DEFAULT="">
<CFPARAM NAME="Get_Item.Deleted" DEFAULT="0">
<CFPARAM NAME="Get_Item.Is_Default" DEFAULT="0">

<CFQUERY NAME="Get_Item" datasource="#application.datasource#">
	Select		*
	From		DD_Classification
	Where		DD_Classification_ID	like '#URL.RID#'
</CFQUERY>
<SCRIPT language="JavaScript">
	function alert_and_delete(){
		var confirmdelete = confirm("Click OK to permanently delete this data. You won't be able to undo this change...");
		if (confirmdelete == true){
			document.all.DeleteRecord.value=1;
			document.MyForm.submit();
		}
	}
	function Validate(){
		if (document.all.DD_Classification_Desc.value == ""){
			alert("Please enter some description.");
			document.all.DD_Classification_Desc.focus();
			return;
		}
		<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
		if(document.all.Classification_Analyst_Profile.value =='' ){
			alert("Please select an analyst profle.");
			document.all.Classification_Analyst_Profile.focus();
			return;
		}
		</cfif>
		if (document.all.Actual_Default.value == 1 && (document.all.Deleted[1].checked || document.all.Is_Default.checked == false)){
			var formObj = document.MyForm;
			formObj.action = "DeleteDefault.cfm";
			NewWindow("", 'delDef', '500', '200', 'Yes', 'No', true);
			formObj.target = "delDef";
			document.MyForm.submit();
			return
		}else{
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
		<cfset DDClassificationID = 0>
	<cfelse>
		<cfset DDClassificationID = Get_Item.DD_Classification_ID>
	</cfif>
	<cfset Get_Classification_Analyst_Profile = createObject("component", "components.Deduction.DeductionManager").getClassificationAnalystProfile(DDClassificationID)/>
</cfif>
<!--- 70923 :: Create new feature for deduction workflow END--->
<CFOUTPUT>
<FORM ACTION="save_Classifications.cfm" METHOD="post" NAME="MyForm">
	<INPUT TYPE="Hidden" NAME="Actual_Default" VALUE="#Get_Item.Is_Default#">
	<TABLE CELLSPACING="5" CELLPADDING="0">
	<TR>
		<TD VALIGN="top" ALIGN="right"><B>Description</B></TD>
		<TD VALIGN="top">
			<INPUT SIZE="55" NAME="DD_Classification_Desc" VALUE="#Get_Item.DD_Classification_Desc#" MAXLENGTH="50">
			<INPUT TYPE="hidden" NAME="DD_Classification_ID" VALUE="#Get_Item.DD_Classification_ID#">
		</TD>
	</TR>
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
			<INPUT TYPE="radio" VALUE="0" NAME="Deleted"#active#>Active	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
			<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#>Inactive
		</TD>
	</TR>
	<!--- 70923 :: Create new feature for deduction workflow START --->
	<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
		<TR>
			<TD VALIGN="top" ALIGN="right"><B>Select Analyst</B></TD>
			<TD VALIGN="top">
				<SELECT NAME="Classification_Analyst_Profile" id="ClassificationAnalyst" multiple="multiple">
				<cfloop query="Get_Existing_Analyst_Profile">
				<OPTION VALUE="#Profiles_ID#" <cfif ListFindNoCase(ValueList(Get_Classification_Analyst_Profile.Profiles_ID), Profiles_ID)>SELECTED</cfif>>#Profiles_Desc#</OPTION>
				</cfloop>
				</SELECT>
			</TD>
		</TR>	
		<!--- 70923 :: Create new feature for deduction workflow END --->
		<cfif appsettings.getGL_Account_On()>
		<TR>
			<TD VALIGN="top" ALIGN="right"><B><cfoutput>#Application.GLAccountLabel#</cfoutput> Code</B></TD>
			<TD VALIGN="top"  colspan="3">
			<input size="30" style="position: absolute;" name="gl_account_code" id="gl_account_code"  value="<cfoutput>#Get_Item.GL_Account_Code#</cfoutput>" autocomplete="off" />
			</TD>
		</TR>
	</cfif>
	</cfif>			
	<TR>
		<TD valign="top" align="right"><strong>Default</strong></TD>
		<TD valign="top">
			<INPUT TYPE="CheckBox" VALUE="1" NAME="Is_Default" <CFIF Get_Item.Is_Default EQ 1>CHECKED</CFIF>>Yes
		</TD>
	</TR>
	<TR>
		<TD valign="top" align="right"><strong>Match Central Default</strong></TD>
		<TD valign="top">
			<INPUT TYPE="CheckBox" VALUE="1" NAME="Is_MatchCentral_Default" <CFIF Get_Item.Is_MatchCentral_Default EQ 1>CHECKED</CFIF>>Yes <em>(Only for billback/deduction closing.)</em>
		</TD>
	</TR>
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
</CFOUTPUT>
</TD>
</TR>
</TABLE>
<A HREF="Create_Classifications.cfm"><cfoutput>#application.util.string.actionLinkFormat2('create new entry')#</cfoutput></A>
<style>
	.ui-corner-all, .ui-corner-bottom, .ui-corner-right, .ui-corner-br {
		border-bottom-right-radius: 4px;
	}
	.ui-corner-all, .ui-corner-bottom, .ui-corner-left, .ui-corner-bl {
		border-bottom-left-radius: 4px;
	}
	.ui-corner-all, .ui-corner-top, .ui-corner-right, .ui-corner-tr {
		border-top-right-radius: 4px;
	}
	.ui-corner-all, .ui-corner-top, .ui-corner-left, .ui-corner-tl {
		border-top-left-radius: 4px;
	}
	.ui-widget-content {
		border: 1px solid #aaa;
		background: #fff;
		color: #222;
	}
	.ui-widget {
		font-family: Verdana,Arial,sans-serif;
		font-size: 1.1em;
	}
	.ui-menu {
		list-style: none;
		padding: 0;
		margin: 0;
		display: block;
		outline: none;
	}
	.ui-autocomplete {
		position: absolute;
		top: 0px;
		left: 0px;
		cursor: default;
		width: auto;
		padding:5px;
	}
	.ui-front {
		z-index: 100;
	}
</style>
	<script>
		<cfif appSettings.get_Setting('Custom_Deduction_workflow') eq '1'>
		$("#ClassificationAnalyst").multiselect().multiselectfilter();
		</cfif>
		$(document).ready(function(){

        $('#gl_account_code').autocomplete({
				minLength: 1,
				source: function(request, response) {
                $.ajax({
                    url: "/components/Deduction/settings/gl_search_ajax.cfc?method=gl_search&fromClassification=1&returnformat=json",
                    dataType: "json",
                    data: {
			                      q: request.term,
			                      maxRows: 10
			                    },
                    success: function(data) {
                      response(data.slice(0, 10));
                    }
                })
            } ,
			 select: function(event, ui) { 
                $('#gl_account_code').val(ui.item.id);
            }
        });
		 });
	</script>
