<cfoutput>
<cfparam name="url.command" default="" />
<cfparam name="url.programList" default="" />
<cfparam name="url.sortBy" default="" />

<script>

	function confirmCompletion()
	{
	
		if(document.all.SenderAddress.value.length == 0)	
		{ 
		
			alert("You must enter your email address");
			return;
		}
			
		if(document.all.SenderSubject.value.length == 0)
		{			
			alert("You must enter a subject");
			return;
		}
			
		if(document.all.Recipient_Email_Address.value.length == 0)
		{
			alert("You must enter at least one email address");
			return;
		}
	
		document.emailFaxForm.submit();
	}
</script>

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	<br><br><br>
 	<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 	<br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>

<form action="email_fax_send.cfm" method="post" name="emailFaxForm">
	
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="Proposal Program Report"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5"></TEXTAREA></TD>
</TR>
</TABLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">
<!---handle for email/fax--->
<cfif url.command eq "email">
	Recipients Email Addresses
<cfelse>
	Recipients Fax Numbers
</cfif>

</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
	<TR VALIGN="top">
		<TD ALIGN="right" WIDTH="150" VALIGN="TOP">
			<B>Recipients:&nbsp;&nbsp;</B>
		</TD>
		<TD>
			<TEXTAREA NAME="Recipient_Email_Address" COLS="75" ROWS="5" STYLE="width:300px;"></TEXTAREA><br>
			<!---handle for fax--->
			<cfif url.command eq "fax">
				<FONT COLOR="Red">
					<B>
						<I>
							YOU MUST PRECEED THE AREA CODE WITH A "1"<BR>
							To add more recipients, add the fax numbers separating them with a semi- colon ( ;)<BR>
							Please make sure that there are no spaces, dashes in the FAX number.
						</I>
					</B>
				</FONT>
			</cfif>
		</TD>
		<!---handle for email--->
		<cfif url.command eq "email">
			<TD ALIGN="left">
				<CF_Email_Address_Lookup 
					Destination_Form_Name="emailFaxForm"
					Destination_Field_Name="Recipient_Email_Address"
					width="200"
					size="5"
					Alert="true"
				>
			</TD>
		</cfif>
	</TR>
	<!---handle for fax--->
	<cfif url.command eq "email">
	<TR>
		<TD></TD>
		<TD COLSPAN="2">
		<FONT COLOR="Red"><B><I>To add more recipients, add the email addresses separating them with a semi- colon ( ;)</I></B></FONT>
		</TD>
	</TR>
	</cfif>
</TABLE>

<BR><BR>
<CFSAVECONTENT VARIABLE="Bid_Request_Content">
	
	<STYLE TYPE="text/css">
			BODY, TD, BLOCKQUOTE, .normal
			{
				font-family : Arial;
				font-size : 8pt;
				color : Black;
			}
			TABLE.Maintable TD 
			{
				border-bottom:solid ##93BEE2 1px; font-size : 10px;
			}
			##header 
			{
				font-size: 12px;
			}
			Table.Maintable TD.tableheaders
			{
				font-size:12px;
				font-weight:bold;
				border-bottom:none; 
			}
			td
			{
				font-family:	sans-serif;
				font-size:		10px;
			}
	</STYLE>
	
	<cfinclude template="index.cfm" />
	
</CFSAVECONTENT>

<!--- Date/Time stamp construction to be used in the naming scheme of the file --->
<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">

<!--- Build file name --->
<CFSET filename_email = "#CreateUUID()#_#datetimestamp#_#gettickcount()#">

<CFSET File_Path ="\Temp_Files\Report\#filename_email#.html">

<INPUT NAME="HTML_File_Path" TYPE="hidden" VALUE="#File_Path#" />

<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_Path & File_Path />
<!--- end create usable directory information --->	

<!--- Build complete path --->
<CFSET completepath = The_File_Location />

<!--- Save the file to the server --->
<cffile action="write" file="#completepath#" output="#Bid_Request_Content#">

<CFINCLUDE TEMPLATE="#Application.Doc_Mapping##File_Path#">

<table>
	<tr>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"send"
				button_action	=	"confirmCompletion();"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Print Page"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>				
		</TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"cancel"
				button_action	=	"window.location.href='index.cfm?programList=#URL.PROGRAMLIST#&sortBy=#URL.SORTBY#'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Cancel email"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>				
		</TD>
	</tr>
</table>
<input type="hidden" name="command" value="#url.command#" />
<input type="hidden" name="redirectTo" value="programList=#url.programList#&sortBy=#url.sortBy#" />
</form>
</cfoutput>