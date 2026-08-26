<CFSET PAGE_TITLE="Fax Invoice">
<cfset Print = 1>
<CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>


<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT LANGUAGE="JavaScript">
function hide_PleaseWaitMessage()
{
 document.all.PleaseWaitMessage.style.display='none';
}
document.body.onload=new Function ("hide_PleaseWaitMessage();");
</SCRIPT>


<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">


<BR><BR>

<cfif len(Form.Fax_Numbers) GT 0>
<H4 STYLE="Color: Red;">
The following fax has been sent...<BR><BR>
</H4>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSAVECONTENT VARIABLE = "Body_Content">
	<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		10px;
			}
	</STYLE>
	
	

		<CFOUTPUT>
		<TABLE CELLPADDING="1" CELLSPACING="5" BORDER="0">
		<TR>
			<TD VALIGN="top"><B>Date:</B></TD>
			<TD ROWSPAN="100%" BGCOLOR="Orange"></TD>
			<TD>#Form.SenderDate#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>From:</B></TD>
			<TD>#Form.Senderaddress#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Message:</B></TD>
			<TD>#Form.Message_Body#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Subject:</B></TD>
			<TD>#Form.Sendersubject#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Rebill</B></TD>
			<TD>


			<CFINCLUDE TEMPLATE="#Application.Doc_Mapping##HTML_File_Path#">
			
			</TD>
		</TR>
		<TR>
			<TD VALIGN="top"></TD>
			<TD></TD>
		</TR>
		</TABLE>
		</CFOUTPUT>
</CFSAVECONTENT> 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT>#Body_Content#</CFOUTPUT>	

<!--- ---------------------------------------------------------------------------------------- --->
<!--- Cover Sheet --->
<!--- ---------------------------------------------------------------------------------------- --->
<CFOUTPUT>
<CFSAVECONTENT VARIABLE = "Cover_sheet"> 
<TABLE CELLPADDING="5" CELLSPACING="15" BORDER="0"  width="95%">
 <TR>
  <TD NOWRAP ALIGN="Right" COLSPAN="4">
  <b>
  <font face="Arial" size="5">#application.returned_customer_setting.Company_Name#</font></b>  
  </TD>
 </TR>
 <TR>
  <TD COLSPAN="4" style="border-bottom-style: solid; border-bottom-width: 4" valign="top"></TD>
 </TR>
 <TR>
  <TD STYLE="FONT:72px;" COLSPAN="4" valign="top"><font face="Arial"><b>
        <br>
        F a x<br>
&nbsp;</b></font></TD>
 </TR>
 <TR>
  <TD width="75" rowspan="6" valign="top">&nbsp;</TD> 
  <TD ROWSPAN="6" valign="top">&nbsp;</TD>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Date:</font></B></TD>
  <TD WIDTH="100%" STYLE="FONT:16px;" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#FORM.SenderDate# </span></font></TD>  
 </TR>
 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">From:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#FORM.Senderaddress#</span></font></TD>
 </TR>
 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Subject:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#FORM.Sendersubject#</span></font></TD>
 </TR>
 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;"><B><font size="5" face="Arial">Message:</font></B></TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top">
        <font face="Arial">
        <span style="font-size: 13pt">#Form.Message_Body#</span></font></TD>  
 </TR>

 <TR>
  <TD VALIGN="top" STYLE="FONT:16px;">&nbsp;</TD>
  <TD STYLE="FONT:16px;" width="100%" valign="top"><br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>

&nbsp;</TD>  
 </TR>
</TABLE> 
<CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm">
 </CFSAVECONTENT>
 <CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">
 <CFSET filename_email	=	"#datetimestamp#_#gettickcount()#">
 
<CFSET CS_HTML_File_Path="\data_files\created\deductions\communications\rebill\CS_#filename_email#.html">


<CFFILE action = "write"
		file="#Application.Doc_Path##CS_HTML_FILE_Path#"
		output="#Cover_sheet#">    
 </CFOUTPUT>


<!--- ###################################################################################### --->

<CFSET Fax_Numbers_List="">
<CFLOOP INDEX="Item" LIST="#Form.Fax_Numbers#" DELIMITERS=";">
	<CFSET Fax_Numbers_List=item&"~FR="&AccessStructure.Name_First&"_"&AccessStructure.Name_Last&"@Faxmail.com"&";"&Fax_Numbers_List>
</CFLOOP>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send fax..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->

<CF_EMAILWRAPPER TO="#Fax_Numbers_List#"
        FROM="chainlink@awayx.com" 
		SUBJECT="#Form.SenderSubject#"
		messageType="2"
		generatedby="3" 
		apparea="13" 
		userid="#request.AccessStructure.user_id#"
		app_area_identifier="#Deduction_ID#">

		
		<cf_EmailWrapperParam file = "#FileLocation#" store="yes"> 
	 	<!---
		<CF_EMAILWRAPPERPARAM FILE = "#Application.Doc_Path##HTML_File_Path#" store="yes" /> --->

</CF_EMAILWRAPPER>   


<cfelse>
You did not include a fax number to send this information to.

</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		
<cfset useLakebaseForUpdateDeduction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateDeduction>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{
				"dd_date_closed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
				"dd_closed_by" = request.AccessStructure.User_ID,
				"dd_resolution_code" = ReasonCode,
				"dd_status" = 4,
				"dd_closure_method" = 2
			}
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUpdateDeduction = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDeduction>
	<cfquery name="UpdateDeduction" datasource="#application.datasource#">
	UPDATE Deductions
	SET DD_Date_Closed = getdate(),
		DD_Closed_By = '#request.AccessStructure.User_ID#',
		DD_Resolution_Code = '#ReasonCode#',
		DD_Status = 4,
		DD_Closure_Method = 2
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
</cfif>

<!---Close any reminders associated with this--->
<cfset useLakebaseForCloseReminders = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reminders")>
<cfif useLakebaseForCloseReminders>
	<cftry>
		<cfset application.oLakebase.updateRows("dd_reminders",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{ "dd_reminder_status" = 1 }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCloseReminders = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCloseReminders>
	<cfquery name="CloseReminders" datasource="#application.datasource#">
	UPDATE DD_Reminders
	SET DD_Reminder_Status = 1
	WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
</cfif>

 <table align="Center"><tr>
 <td>
<CF_button
	button_name		=	""
	button_caption	=	"return to deduction home"
	button_action	=	"window.parent.location.href='/deductions/deduction.cfm?Deduction_ID=<cfoutput>#Deduction_ID#</cfoutput>';"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Return to deduction home..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
</td>

 </td>
	</tr></table>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>

