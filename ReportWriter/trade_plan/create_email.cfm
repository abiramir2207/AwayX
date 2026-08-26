<cfoutput>

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

	document.emailForm.submit();
}
</script>

<cfquery name="qGetTradePlanTitle" datasource="#application.datasource#">
	SELECT 	Trade_Plan_Title
	FROM 	trade_plan
	WHERE 	trade_plan_id = '#Trade_Plan_ID#'
</cfquery>

<form method="post" name="emailForm">
<INPUT TYPE="Hidden" NAME="TP_Title" VALUE=<CFOUTPUT>"#qGetTradePlanTitle.Trade_Plan_Title#"</CFOUTPUT>>
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
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="#application.returned_customer_setting.Trade_Label# #Application.PlannerLabel# Report #qGetTradePlanTitle.Trade_Plan_Title#"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5"></TEXTAREA></TD>
</TR>
</TABLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR VALIGN="top">
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Recipient_Email_Address" COLS="75" ROWS="5" STYLE="width:300px;"></TEXTAREA>
	</TD>
	<TD ALIGN="left">
	<CF_Email_Address_Lookup
			Destination_Form_Name="emailForm"
			Destination_Field_Name="Recipient_Email_Address"
			width="200"
			size="5"
			Alert="true">
	</TD>
</TR>
<TR>
	<TD></TD>
	<TD COLSPAN="2">
	<FONT COLOR="Red"><B><I>To add more recipients, add the email addresses separating them with a semi- colon ( ;)</I></B></FONT>
	</TD>
</TR>
</TABLE>

<BR><BR>
<CFSAVECONTENT VARIABLE="Trade_Plan_Content">

	<STYLE TYPE="text/css">
			td
			{
				font-family:	sans-serif;
				font-size:		10px;
			}
	</STYLE>

	<cfinclude template="trade_plan_calc.cfm" />

</CFSAVECONTENT>

<!--- Date/Time stamp construction to be used in the naming scheme of the file --->
<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">

<!--- Build file name --->
<CFSET filename_email = "#Trade_Plan_ID#_#datetimestamp#_#gettickcount()#">

<!--- <CFSET Trade_Plan_HTML_File_Path ="\ReportWriter\trade_plan\temp\#filename_email#.html"> --->
<CFSET Trade_Plan_HTML_File_Path ="\Temp_Files\TradePlanner\#filename_email#.html">

<INPUT NAME="HTML_File_Path" TYPE="hidden" VALUE="#Trade_Plan_HTML_File_Path#" />

<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_Path & Trade_Plan_HTML_File_Path />
<!--- end create usable directory information --->

<!--- Build complete path --->
<CFSET completepath = The_File_Location />

<!--- Save the file to the server --->
<cffile action="write" file="#completepath#" output="#Trade_Plan_Content#">

<CFINCLUDE TEMPLATE="#Application.Doc_Mapping##Trade_Plan_HTML_File_Path#">


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
				button_tip		=	"Print page"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"cancel"
				button_action	=	"window.location.href='index.cfm?action=display&Trade_Plan_ID=#Trade_Plan_ID#'"
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
</form>
</cfoutput>