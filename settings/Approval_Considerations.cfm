<!-----------------------------------------------------------------------------

FILE NAME:		Approval_Considerations.cfm
DESCRIPTION:	Apporoval Considerations creation screen
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	16-Jul-2014


------------------------------------------------------------------------------>
<link rel="stylesheet" type="text/css" href="/common_files/jquery.maxlength.css">

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfparam name="blnSubmit" default="0">
<CFPARAM NAME="URL.RID" DEFAULT="-1">


<cfset objApprovalConsiderations 	= CreateObject("component","mvc.Models.Program.ApprovalConsiderationsManager") />
<!--- <cfset application.oController.getObject(path="mvc.Models.Program.ApprovalConsiderationsManager",name="ApprovalConsiderationsManager",bReload= 0) /> --->

<!--- ************************* SAVE *************************--->
<cfif blnSubmit IS 1>

	<!--- <cfdump var="#form#" abort="true"> --->

	<cfset approvalConsiderationsID = 0 />
	<cfif form.Approval_Considerations_ID neq "">
		<cfset approvalConsiderationsID = form.Approval_Considerations_ID />
	</cfif>

	<cfparam name="form.template_select" default="">

	<cfset objApprovalConsiderations.addEditApprovalConsiderations(
			approvalConsiderationsID = approvalConsiderationsID,
			approvalConsiderationsName = FORM.Approval_Considerations_Name,
			approvalConsiderationsText = FORM.Approval_Considerations_Text,
			deleted = Form.Deleted,
			userID = request.AccessStructure.User_ID,
			template_select = form.template_select,
			Display_On_WhatIF_Generic = (structKeyExists(form,"Display_On_WhatIF_Generic") ? 1 : 0) )/>

	<cflocation addtoken="false" url="Approval_Considerations.cfm" />
</cfif>


<!--- ************************* GET DATA *************************--->
<cfset qGetCurrentApprovalConsiderations = objApprovalConsiderations.getApprovalConsiderations(approvalConsiderationsID=URL.RID, IncludeDeleted=1) />
<cfset qGetApprovalConsiderations = objApprovalConsiderations.getApprovalConsiderations(IncludeDeleted=1) />


<CFSET URL.PageTitle="Approval Considerations">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- ************************* DISPALY LAST UPDATED BY INFO *************************--->
<CFIF URL.RID LTE 0>
	<CFQUERY NAME="GetLastUpdatedDetails" datasource="#application.datasource#">
		Select		TOP 1 Updated_By, Updated_Date
		From		Approval_Considerations
		Order by	Updated_Date Desc
	</CFQUERY>
	<CFSET Last_Updated_By = GetLastUpdatedDetails.Updated_By />
	<CFSET Last_Updated_Date = GetLastUpdatedDetails.Updated_Date />
<CFELSE>
	<CFSET Last_Updated_By = qGetCurrentApprovalConsiderations.Updated_By />
	<CFSET Last_Updated_Date = qGetCurrentApprovalConsiderations.Updated_Date />
</CFIF>

<CFIF Last_Updated_By NEQ "">
	<CFQUERY NAME="getUserName" datasource="#application.datasource#">
		SELECT 	_Users.Name_First + ' ' + _Users.Name_Last AS User_FullName
		FROM 	_Users
		WHERE 	User_ID = '#Last_Updated_By#'
	</CFQUERY>
</CFIF>
<CFIF Last_Updated_By NEQ "">
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<tr><td>
	<FONT SIZE="2"><B>This <cfif url.RID GT 0>record <cfelse> setting</cfif> was last updated on <CFOUTPUT>#dateformat(Last_Updated_Date, 'm/d/yyy')# #timeformat(Last_Updated_Date, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#getUserName.User_FullName#</CFOUTPUT></B></FONT>
	</td></tr></table>
</CFIF>


<!--- ************************* DISPLAY THE CONTENTS *************************--->
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="100%">
	<col width="20%">
	<col width="80%">
	<TR>
		<!--- ************************* DISPLAY EXISTING RECORDS *************************--->
		<TD VALIGN="top">
			<SPAN CLASS="title2">Existing Approval Considerations</SPAN>
			<HR COLOR="Blue" SIZE="1">

			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200px" CLASS="Maintable">
				<TR>
					<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Name</B></SPAN></TD>
					<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
				</TR>
				<CFOUTPUT QUERY="qGetApprovalConsiderations">
				<TR>
					<TD NOWRAP><A HREF="Approval_Considerations.cfm?RID=#Approval_Considerations_ID#">#Approval_Considerations_Name#</A></TD>
					<TD NOWRAP>
						<CFIF Deleted EQ 0>
							<IMG SRC="/images/yes_small.gif" TITLE="active record...">
						<CFELSE>
							<IMG SRC="/images/no_small.gif" TITLE="inactive record...">
						</CFIF>
					</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
			<BR>
			<IMG SRC="/images/yes_small.gif" BORDER="0" ALT="" ALIGN="middle"> - active record<BR>
			<IMG SRC="/images/no_small.gif" BORDER="0" ALT="" ALIGN="middle"> - inactive record
		</TD>
		<!--- ************************* ADD/EDIT RECORD FORM *************************--->
		<TD VALIGN="top">
			<SPAN CLASS="title2">Edit Record</SPAN>
			<HR COLOR="Blue" SIZE="1">

			<SCRIPT language="JavaScript">
				function SubmitForm()
				{
					var isError = 0;
					var re = /\s/g;
					var strMsg = new Array();

					var strValue;

					strValue = document.MyForm.Approval_Considerations_Name.value.replace(re, "");
					if (strValue.length == 0)
					{
						strMsg[strMsg.length] = "Please enter a name.";
						isError = 1;
					}

					strValue = document.MyForm.Approval_Considerations_Text.value.replace(re, "");
					if (strValue.length == 0)
					{
						strMsg[strMsg.length] = "Please enter a text.";
						isError = 1;
					}

					if (isError == 0)
					{
						disableButton("save_table", true, false);
						MyForm.submit();
					}
					else
					{
						alert(strMsg.join("\n"));
					}
					return false;
				}

			</SCRIPT>
			<FORM ACTION="Approval_Considerations.cfm" METHOD="post" NAME="MyForm">
			<TABLE CELLSPACING="5" CELLPADDING="5" border="0" width="100%">
				<col width="10%">
				<col width="80%">
				<cfoutput>
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Name</B></TD>
					<TD VALIGN="top">
						<INPUT SIZE="62" NAME="Approval_Considerations_Name" VALUE="#qGetCurrentApprovalConsiderations.Approval_Considerations_Name#" MAXLENGTH="70">
					</TD>
				</TR>
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Text</B></TD>
					<TD VALIGN="top">
						<!--- <INPUT SIZE="62" NAME="Approval_Considerations_Text" VALUE="#qGetCurrentApprovalConsiderations.Approval_Considerations_Text#" MAXLENGTH="70"> --->
						<textarea cols="64" rows="10" id="ta813" name="Approval_Considerations_Text">#qGetCurrentApprovalConsiderations.Approval_Considerations_Text#</textarea>
						<INPUT TYPE="hidden" NAME="Approval_Considerations_ID" VALUE="#qGetCurrentApprovalConsiderations.Approval_Considerations_ID#">
					</TD>
				</TR>
				</cfoutput>
				<TR>
					<TD VALIGN="bottom" ALIGN="right"><B>Availability</B></TD>
					<TD VALIGN="bottom">
						<!--- Is this record deleted? --->
						<CFIF qGetCurrentApprovalConsiderations.Deleted EQ 0 OR qGetCurrentApprovalConsiderations.Deleted EQ "">
							<CFSET active=" CHECKED">
							<CFSET inactive="">
						<CFELSE>
							<CFSET active="">
							<CFSET inactive=" CHECKED">
						</CFIF>
						<CFOUTPUT>
						<INPUT TYPE="radio" VALUE="0" NAME="Deleted"#active#>Active&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<INPUT TYPE="radio" VALUE="1" NAME="Deleted"#inactive#>Inactive
						</CFOUTPUT>
					</TD>
				</TR>
				<TR>
					<TD VALIGN="bottom" ALIGN="right"><B>Also Display In</B></TD>
					<TD VALIGN="bottom">
						<CFOUTPUT>
						<INPUT TYPE="checkbox" <cfif qGetCurrentApprovalConsiderations.Display_On_WhatIF_Generic eq "1">checked=checked</cfif> NAME="Display_On_WhatIF_Generic"> What If P&L From Home Page
						</CFOUTPUT>
					</TD>
				</TR>

				<TR>
					<TD colspan="2">
						<cfscript>
							component_select_templates_component_id     = -1;
							component_select_templates_discount_type_id = "1,2,3,4,8,10";               // include all discount types
							variables.Approval_Considerations_ID        = val(qGetCurrentApprovalConsiderations.Approval_Considerations_ID);
						</cfscript>
						<cfinclude template="/program_wizard/component_select_templates.cfm" />
					</TD>
				</TR>

				<TR>
					<TD VALIGN="" ALIGN="right"></TD>
					<TD VALIGN="bottom">
						<br><br><br>
						<CF_button
							button_name	=	"save"
							button_caption	=	"save data"
							button_action	=	"return SubmitForm();"
							button_type	=	"javascript_link"
							button_width	=	"75"
							button_color	=	"Navy"
							button_tip	=	""
							font_color	=	"White"
							font_size		=	"12"
							font_weight	=	"bold"
						>
					</TD>
				</TR>
			</TABLE>
			<input type="hidden" name="blnSubmit" value="1">
			</FORM>
		</TD>
	</TR>
</TABLE>

<B>
<FONT COLOR="#ff0000" SIZE="2"><B>[</B></FONT>
	<A HREF="Approval_Considerations.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>

<cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.plugin.min.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.maxlength.min.js"></script>

<script>
$('#ta813').maxlength( { max: 200 } );
</script>