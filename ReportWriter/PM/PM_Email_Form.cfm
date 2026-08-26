<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Send Email</title>
</head>

<body>
<BR><BR>
<CFOUTPUT>
<CFIF isdefined("FORM.Email_Address")>
<DIV style="Width: 400px; Height: 450px;">

<FORM NAME="send_mail" ACTION="PM_Email_Form.cfm" METHOD="Post">
	
		
	</TABLE>
	<TABLE ALIGN="CENTER">
		<TR>
			<TD COLSPAN="100%" STYLE=" border-bottom:2px orange solid;font-size:14px;font-weight:bold;color:Navy;">Email Form</TD>
		</TR>
		<TR>
			<TD><br><br></TD>
			<TD><br><br></TD>
			<TD><br><br></TD>
			
		</TR>
		<TR>
			<TD VALIGN="Top" Align="right"><b>From:</b></TD>
			<TD ROWSPAN="4" STYLE="border-right:Solid 2px blue;">&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD><INPUT SIZE="50" TYPE="Text" NAME="SenderAddress" VALUE="#request.AccessStructure.user_email#" disabled></TD>
		</TR>
		<TR>
			<TD VALIGN="Top" Align="right"><b>To:</b></TD>	
			<TD>&nbsp;</TD>		
			<TD>
			 <CFSET ToAdd = #Replace(FORM.Email_Address,",",";","all")#>				
				<CFSET length = #listlen(ToAdd,";")#>	
				<CFIF length GT 1>
					<TEXTAREA NAME="ToAddress" COLS="92" ROWS="4">#ToAdd#</TEXTAREA>
					<FONT COLOR="Red"><B><I>To add more recipients, add the email addresses separating them with a semi- colon ( ;)</I></B></FONT>
				<CFELSE>
					<INPUT SIZE="50" NAME="ToAddress" VALUE="#ToAdd#">
				</CFIF>
		</TR>
		<TR>
			<TD VALIGN="Top" Align="right"><b>Subject:</b></TD>
			<TD>&nbsp;</TD>
			<TD><INPUT SIZE="90" NAME="Subject" VALUE="#FORM.Subject#"></TD>
		</TR>	
		<TR>
			<TD VALIGN="Top" Align="right"><b>Message:</b></TD>
			<TD>&nbsp;</TD>
			<TD><TEXTAREA NAME="Message" cols="92" rows="6"></TEXTAREA></TD>
		</TR>
		<TR>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
			<TD><br><br>
			<CF_button
				button_name		=	""
				button_caption	=	"send email"
				button_action	=	"javascript: document.send_mail.submit();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				></TD>
		</TR>
	</TABLE>
</FORM>

</DIV>
</CFIF>

<CFIF isdefined("FORM.Message")>
	<cfoutput>
		  <cf_EmailWrapper 	
			to = "#FORM.ToAddress#"
			from = "#request.AccessStructure.User_Email#"
			subject = "#FORM.Subject#"
			TYPE =	"html" 
			messagetype="1" 
			generatedby="3" 
			apparea="6" 
			userid="#request.AccessStructure.user_id#">
		  
		  <TABLE WIDTH="100%">
			<TR VALIGN="top">
			<TD>
				
				#FORM.Message#
	
			</TD>
			</TR>
			</TABLE>
		  
		  
	
		<!--- </cfmail>  --->
		</cf_EmailWrapper> 
	</cfoutput>
	<TABLE ALIGN="center">
		<TR>
			<TD><BR><BR><BR><BR>Mail has been sent.</TD>
		</TR>
	</TABLE>
	
	<SCRIPT LANGUAGE="JavaScript">
		setTimeout("closeWindow()", 2000);
		function closeWindow()
		{
			window.close();
		}
	</SCRIPT>
</CFIF>

</CFOUTPUT>

</body>
</html>
