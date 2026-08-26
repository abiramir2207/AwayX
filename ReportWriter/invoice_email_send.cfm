<!---<cfdump var = #session#>--->
<CFSET PAGE_TITLE="Email Invoice">
<CFSET GROUP="contracts">
<cfset ShowDetails = 1>
<CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
	<HEAD>
		<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
		<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	</HEAD>

	<BODY id="email_send_body" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
	
		<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		 <br><br><br>
		 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		 <br><br><br>
		</SPAN>
		<CFFLUSH>
		<SCRIPT LANGUAGE="JavaScript">
			document.all.PleaseWaitMessage.style.display='none';
		</SCRIPT>
		<cfif len(trim(Form.Broker_Address)) GT 0>
		<BR><BR>
		<H4 STYLE="Color: Red;">
		The following Email has been sent...<BR><BR>
		</H4>
		
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Build Email Body																				 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<cfset ShowDetails=1>
			<STYLE TYPE="text/css">
					td
					{
						font-family:	sans-serif;
						font-size:		10px;
					}
			</STYLE>
			
			<cfset Print = 1>
		
				<CFOUTPUT>
					<FORM ACTION="" METHOD="post" NAME="EmailSendForm" ID="EmailSendForm">
						<TABLE CELLPADDING="1" CELLSPACING="5" BORDER="0" width="100%">
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
							<TD VALIGN="top"><B>To:</B></TD>
							<TD>#Form.Broker_Address#</TD>
						</TR>
						<TR>
							<TD VALIGN="top"><B>Subject:</B></TD>
							<TD>#Form.Sendersubject#</TD>
						</TR>
						<TR>
							<TD VALIGN="top"><B>Message:</B></TD>
							<TD>#Form.Message_Body#</TD>
						</TR>
							<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">
							<!--- Build file name --->
							<CFSET filename_email	=	"#datetimestamp#_#gettickcount()#">
							<CFSET HTML_File_Path="\search_screens\invoice\utilities\htmlfiles\#filename_email#.html">
							<CFIF NOT FileExists("#APPLICATIONPATH##HTML_File_Path#")>
								<CFINCLUDE TEMPLATE="invoice_Summary_Save.cfm">
								<CFSET HTML_File_Path=HTML_File_Path>
							</cfif>		
						<TR>
							<TD><!------ <CFINCLUDE TEMPLATE="#HTML_File_Path#"> -----></TD>
						</TR>
						<TR>
							<TD VALIGN="top"></TD>
							<TD></TD>
						</TR>
						</TABLE>
							<!--- hidden variables --->
						<cfoutput>
							<cfloop collection=#FORM# item="myItem">
								<cfoutput>
									<INPUT TYPE="Hidden" NAME="#trim(myItem)#" VALUE="#Evaluate('FORM.' & trim(myItem))#">
								</cfoutput>
							</cfloop>
						</cfoutput>
						<INPUT TYPE="Hidden" NAME="Broker_Address" ID="Broker_Address" VALUE="#Broker_Address#">
					</FORM>
					#Summary_Content#	 
					<BR>
				</CFOUTPUT>
				<cfflush>
		
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Repalcing Invoice file name with Invoice Number																 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!---
		<CF_Naming_Email_Attachments 
						Title="Invoice Volumn Confirmatin Email" 
						Relative_Src_File_Path="#HTML_File_Path#"  
						Relative_Dest_Dir_Path ="Temp_Files\Invoice" 
						Return_Variable_Name="Invoice_FN"> --->
						
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		
		
		
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Send email..................																	 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		
			<cfoutput>
				<CF_EMAILWRAPPER 
					TO			=	"#Broker_Address#"
			        FROM		=	"#request.AccessStructure.User_Email#"
			        SUBJECT		=	"#Form.Sendersubject#"
					TYPE		=	"html" 
					messagetype="1" 
					generatedby="3" 
					apparea="8" 
					userid="#request.AccessStructure.user_id#"> 
					
					<TABLE WIDTH="100%">
						<TR VALIGN="top"><TD>#Form.Message_Body#</TD></TR>
						<TR></TR>
						<TR><TD>#Summary_Content#</TD></TR>
					</TABLE>
					<!--- <cfmailparam file = "#Invoice_FN#"> --->
					<!--- <cf_EmailWrapperParam file = "#Invoice_FN#" store="yes"> --->
					<!--- </CFMAIL> --->
				</CF_EMAILWRAPPER>
			</cfoutput>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		
		<cfelse>
		
		You did not enter an email address to which to send this page.
		</cfif>
		
		
		<table width="100" align="Center">
			<tr>
				<TD>
						<CF_button
							button_name		=	""
							button_caption	=	"Close"
							button_action	=	"window.close();"
							button_type		=	"javascript_link"
							button_width	=	"150"
							button_color	=	"Navy"
							button_tip		=	"Close this window"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>	
				</TD>
			</tr>
		</table>
		<CFINCLUDE TEMPLATE="/includes/footer.cfm">
	</BODY>
</HTML>

<cfflush>

<cfsilent>
<cfset mail_flag = 1 >
<CFINCLUDE TEMPLATE="reportInvoiceAction.cfm">
</cfsilent>
 
<SCRIPT LANGUAGE="JavaScript">
	function RunReport(thisForm)
		{	
			var allClear = false;
			if (confirm("This report runs for a long period of time, do you want to continue to generate the report?"))
			{
				thisForm.action = "reportInvoiceAction.cfm?mail_flag=1";
				thisForm.submit();
				allClear = true;
			}
			return allClear;
		}
</SCRIPT>

