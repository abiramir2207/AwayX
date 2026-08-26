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

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">



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


<cfif len(trim(Form.Broker_Address)) GT 0>
<BR><BR>
<H4 STYLE="Color: Red;">
The following Email has been sent...<BR><BR>
</H4>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Build Email Body																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset ShowDetails=1>
<CFSAVECONTENT VARIABLE = "Body_Content">
	<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		10px;
			}
	</STYLE>
	
	<cfset Print = 1>

		<CFOUTPUT>
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
			<TD VALIGN="top"><B>Message:</B></TD>
			<TD>#Form.Message_Body#</TD>
		</TR>
		<TR>
			<TD VALIGN="top"><B>Subject:</B></TD>
			<TD>#Form.Sendersubject#</TD>
		</TR>
				<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">
		
		<!--- Build file name --->
		<CFSET filename_email	=	"#datetimestamp#_#gettickcount()#">
			<CFSET HTML_File_Path="\temp_files\search_screens\invoice\utilities\htmlfiles\#filename_email#.html">
			<CFIF NOT FileExists("#Application.Doc_Path##HTML_File_Path#")>
				<CFINCLUDE TEMPLATE="Summary_Save.cfm">
				<CFSET HTML_File_Path=HTML_File_Path>
			</cfif>
						
				<TR>
			<TD VALIGN="top"><B>Program</B></TD>
			<TD><CFINCLUDE TEMPLATE="#Application.Doc_Mapping##HTML_File_Path#"></TD>
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

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Repalcing Invoice file name with Invoice Number																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CF_Naming_Email_Attachments 
				Title="Invoice_#FORM.Invoice_Number#" 
				Relative_Src_File_Path="#HTML_File_Path#"  
				Relative_Dest_Dir_Path ="Temp_Files\Invoice" 
				Return_Variable_Name="Invoice_FN">
				
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send email..................																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFMAIL TO			=	"#Broker_Address#"
        FROM		=	"#request.AccessStructure.User_Email#"
        SUBJECT		=	"#Form.Sendersubject#"
		TYPE		=	"html"> --->
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
		<TR VALIGN="top">
		<TD>
		#Form.Message_Body#
		</TD>
		</TR>
		</TABLE>
		<!--- <cfmailparam file = "#Invoice_FN#"> --->
		<cf_EmailWrapperParam file = "#Invoice_FN#" store="yes">
<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
</cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfelse>

You did not enter an email address to which to send this page.
</cfif>


		<cfset ReturnPage = "/search_screens/invoice/invoice_detail.cfm?Invoice_Header_ID=#Invoice_Header_ID#">
	

<table width="100" align="Center">
<tr>
<td>
<CF_button
	button_name		=	""
	button_caption	=	"return to summary"
	button_action	=	"window.location.href='#ReturnPage#';"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to return to invoice details..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">
</td>
<Td>

		<CF_button
			button_name		=	""
			button_caption	=	"close"
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

