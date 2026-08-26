<CFSET PageTitle="#application.CompanyName#: VIEW FEEDBACK LOG">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js"/>
<script language="javascript">
	function deleteAll()
		{
			if(window.checkAllDel != null)
			{
				if(checkAllDel.length)
					{
						for(var x=0; x<checkAllDel.length;x++)
						{
							box = getFirstChild(checkAllDel[x])
							box.checked = document.all.deleteAllEmail.checked
						}
					}
				else
					{
						box = getFirstChild(window.checkAllDel)
						box.checked = document.all.deleteAllEmail.checked					
					}
			}
			
		}
</script>

<cfif isdefined("form.deleteEmail")>
	<cfset useLakebaseForQDelEmailLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("email_messages")>
	<cfif useLakebaseForQDelEmailLog>
		<cftry>
			<cfset application.oLakebase.updateRows("email_messages",
				{ "email_message_id" = "in.(#form.deleteEmail#)" },
				{ "deleted" = true }
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForQDelEmailLog = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForQDelEmailLog>
		<CFQUERY NAME="qDelEmailLog" datasource="#application.datasource#">
			Update email_messages
			set deleted = 1
			Where		email_message_id	in 	(#listQualify(form.deleteEmail,"'")#)
		</CFQUERY>
	</cfif>

</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the email log from the database														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_email_log" datasource="#application.datasource#">
Select 		email_messages.*,
			_users.user_id,
			_users.Name_First,
			_users.Name_Last
From		email_messages,
			_users
Where		email_messages.email_user_id	=	_users.user_id
			and email_messages.deleted = 0
Order by	email_date_sent	DESC
</CFQUERY>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>




<CFOUTPUT><H4 STYLE="color:gray;">There are #Get_email_log.Recordcount# email messages<cfif isdefined("form.deleteEmail")>&nbsp;&nbsp;(#ListLen(form.deleteEmail)# record<cfif ListLen(form.deleteEmail) gt 1>s</cfif> deleted)</cfif></H4></CFOUTPUT>
<form name="frmEmailLog" action="view_email_log.cfm" method="post">
<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="2" CELLSPACING="0" BORDER="0">
<TR BGCOLOR="#FFCE84">
	<TD ID="header" VALIGN="BOTTOM"><input type="checkbox" name="deleteAllEmail" onclick="deleteAll();" /><B>DEL</B></TD>
	<TD ID="header" VALIGN="BOTTOM"><B>From<BR>Name</B></TD>
	<TD ID="header" VALIGN="BOTTOM"><B>From<BR>Email Address</B></TD>
	<TD ID="header" VALIGN="BOTTOM"><B>Date</B></TD>
	<TD ID="header" VALIGN="BOTTOM"><B>Subject</B></TD>
	<TD ID="header" VALIGN="BOTTOM"><B>Message Body</B></TD>
</TR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Defines the number of rows to display per "page"										       --->
	<cf_Number_of_Rows maxrows="20">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFOUTPUT QUERY="Get_email_log"  startrow="#StartRow#" maxrows="#MaxRows#">
<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<TD NOWRAP VALIGN="top"><span ID="checkAllDel"><input type="checkbox" name="deleteEmail" value="#email_message_id#" /></span></TD>
	<TD NOWRAP VALIGN="top">#Name_First# #Name_Last#&nbsp;&nbsp;</TD>
	<TD NOWRAP VALIGN="top"><A HREF="mailto:#email_address_from#?subject=#URLEncodedFormat(email_subject)#&body=&lt;&lt;#URLEncodedFormat(email_message)#&gt;&gt;&cc=#request.AccessStructure.User_Email#" TITLE="Click to send a message to this person">#email_address_from#&nbsp;&nbsp;</A></TD>
	<TD NOWRAP VALIGN="top">#dateformat(email_date_sent, 'm/d/yyyy')# #timeformat(email_date_sent, 'h:mm:ss tt')#&nbsp;&nbsp;</TD>
	<TD VALIGN="top">#email_subject#&nbsp;&nbsp;</TD>
	<TD VALIGN="top">#email_message#&nbsp;&nbsp;</TD>
</TR>
</CFOUTPUT>

<TR>
	<TD  STYLE="Border:none;"><input type="submit" value="Delete" />&nbsp;&nbsp;</TD>
	<TD COLSPAN="4" STYLE="Border:none;">
		<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
		<cf_Next_Previous 
			maxpages		=	"10"
			query			=	"Get_email_log"										
			previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		>
		</DIV>
	</TD>
</TR>
</form>
</TABLE>


