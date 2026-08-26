<!---
credit_types.cfm
--->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfparam name="blnSubmit" default="0">
<CFPARAM NAME="URL.RID" DEFAULT="-1">


<cfset application.oController.getObject(path="mvc.Models.Program.CreditTypeManager",name="CreditTypeManager",bReload= 0) />

<!--- ************************* SAVE *************************--->
<cfif blnSubmit IS 1>
	
	
	<cfset creditTypeID = 0 />
	<cfif form.Credit_Type_ID neq "">
		<cfset creditTypeID = form.Credit_Type_ID />
	</cfif>
	
	<cfset application.oCreditTypeManager.addEditCreditType(
			creditTypeID = creditTypeID,
			creditType = form.Credit_Type,
			creditTypeDesc = form.Credit_Type_Description,
			deleted = Form.Deleted,
			userID = request.AccessStructure.User_ID) />
	
	
	<cflocation addtoken="false" url="credit_types.cfm" />	
</cfif>


<!--- ************************* GET DATA *************************--->
<cfset qGetCurrentCreditType = application.oCreditTypeManager.getCreditTypes(creditTypeID=URL.RID, IncludeDeleted=1) />
<cfset qGetCreditTypes = application.oCreditTypeManager.getCreditTypes(IncludeDeleted=1) />


<CFSET URL.PageTitle="Credit Types">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<!--- ************************* DISPALY LAST UPDATED BY INFO *************************--->
<CFIF URL.RID LTE 0>		
	<CFQUERY NAME="GetLastUpdatedDetails" datasource="#application.datasource#">
		Select		TOP 1 Updated_By, Updated_Date
		From		Credit_Type
		Order by	Updated_Date Desc
	</CFQUERY>
	<CFSET Last_Updated_By = GetLastUpdatedDetails.Updated_By />
	<CFSET Last_Updated_Date = GetLastUpdatedDetails.Updated_Date />
<CFELSE>
	<CFSET Last_Updated_By = qGetCurrentCreditType.Updated_By />
	<CFSET Last_Updated_Date = qGetCurrentCreditType.Updated_Date />
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
<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="750">
	<TR>
		<!--- ************************* DISPLAY EXISTING RECORDS *************************--->
		<TD VALIGN="top">
			<SPAN CLASS="title2">Existing Credit Types</SPAN>
			<HR COLOR="Blue" SIZE="1">
			
			<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="2" WIDTH="200" CLASS="Maintable">
				<TR>
					<TD NOWRAP WIDTH="100%"><SPAN STYLE="font-size: 12px;"><B>Description</B></SPAN></TD>
					<TD NOWRAP><SPAN STYLE="font-size: 12px;"><B>Status</B></SPAN></TD>
				</TR>
				<CFOUTPUT QUERY="qGetCreditTypes">
				<TR>
					<TD NOWRAP><A HREF="credit_types.cfm?RID=#Credit_Type_ID#">#Credit_Type_Description#</A></TD>
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
					
					strValue = document.MyForm.Credit_Type.value.replace(re, "");					
					if (strValue.length == 0)
					{
						strMsg[strMsg.length] = "Please enter a code.";						
						isError = 1;
					}
					
					strValue = document.MyForm.Credit_Type_Description.value.replace(re, "");					
					if (strValue.length == 0)
					{
						strMsg[strMsg.length] = "Please enter a description.";						
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
			<FORM ACTION="credit_types.cfm" METHOD="post" NAME="MyForm">
			<TABLE CELLSPACING="5" CELLPADDING="0">
				<cfoutput>
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Code</B></TD>
					<TD VALIGN="top">
						<INPUT SIZE="62" NAME="Credit_Type" VALUE="#qGetCurrentCreditType.Credit_Type#" MAXLENGTH="70">
					</TD>
				</TR>
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Description</B></TD>
					<TD VALIGN="top">
						<INPUT SIZE="62" NAME="Credit_Type_Description" VALUE="#qGetCurrentCreditType.Credit_Type_Description#" MAXLENGTH="70">
						<INPUT TYPE="hidden" NAME="Credit_Type_ID" VALUE="#qGetCurrentCreditType.Credit_Type_ID#">
					</TD>
				</TR>
				</cfoutput>
				<TR>
					<TD VALIGN="top" ALIGN="right"><B>Availability</B></TD>
					<TD VALIGN="top">
						<!--- Is this record deleted? --->
						<CFIF qGetCurrentCreditType.Deleted EQ 0 OR qGetCurrentCreditType.Deleted EQ "">
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
					<TD VALIGN="top" ALIGN="right"></TD>
					<TD VALIGN="top">
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
	<A HREF="credit_types.cfm"><B>create new entry</B></A>
<FONT COLOR="#ff0000" SIZE="2"><B>]</B></FONT>
</B>

