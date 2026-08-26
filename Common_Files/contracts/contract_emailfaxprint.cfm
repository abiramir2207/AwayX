<cfparam name="url.program_list" default="">
<cfparam name="url.action_type" default="">
<cfparam name="url.contract_number" default="">
<cfparam name="programlist" default="">
<cfparam name="FAX_EMAIL_TEXT" default="">
<CFSET EMAIL_TEMP_FILE_FOLDER = "\Temp_Files\EmailFaxPrint">


<cfset useLakebaseForgetcontracttitle = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetcontracttitle>
	<cftry>
		<cfset getcontracttitle = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_number" = "eq.#url.contract_number#",
				"limit" = "1",
				"select" = "contract_title"
			}), "contract_title"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetcontracttitle = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetcontracttitle>
<cfquery name="getcontracttitle" datasource="#application.datasource#">
select top 1 contract_title
from contract_main
where contract_number = '#url.contract_number#'
</cfquery>
</cfif>


<CFSET EMAIL_datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">


<CFSET EMAIL_filename_email	=	"#Replace(url.contract_number,"000-",'')#_#EMAIL_datetimestamp#_#gettickcount()#">
<CFSET EMAIL_HTML_File_Path="#EMAIL_TEMP_FILE_FOLDER#\#EMAIL_filename_email#.htm">
<CFSET EMAIL_The_File_Location = "#Application.Doc_Path##EMAIL_HTML_File_Path#">

<!--- Save the file to the server --->
<cffile action="write" file="#EMAIL_The_File_Location#" output="">
<cfinclude template="/common_files/jQuery.cfm">
<cfif url.action_type EQ "P">
<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm">


<cfelseif url.action_type EQ "E" OR url.action_type EQ "F">
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<FORM ACTION="/Common_Files/Email_Common_Send.cfm" METHOD="post" NAME="Email" ID="MyForm">
<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE=""></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5"></TEXTAREA></TD>
</TR>
</TABLE>
</CFOUTPUT>
<cfif url.action_type EQ "E">
<cfset FAX_EMAIL_TEXT = "Email">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Recipient_Email_Address"></span></TD>
	<TD><TEXTAREA NAME="Recipient_Email_Address" COLS="75" ROWS="5" STYLE="WIDTH:300px;"></TEXTAREA>
	</TD>
	<TD ALIGN="left">
	<CF_Email_Address_Lookup
			Destination_Form_Name="Email"
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
</cfif>


<BR><BR>
<cfif url.action_type EQ "F">
<cfset FAX_EMAIL_TEXT = "Fax">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Fax Numbers</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Fax_Numbers"></span></TD>
	<TD>
		<TEXTAREA NAME="Form_Fax_Numbers" COLS="75" ROWS="5" onKeyUp="clenseText(this, '0123456789;')"></TEXTAREA><BR>
		<FONT COLOR="Red"><B><I>
YOU MUST PRECEED THE AREA CODE WITH A "1"<BR>
To add more recipients, add the fax numbers separating them with a semi- colon ( ;)<BR>
			Please make sure that there are no spaces, dashes in the FAX number.
		</I></B></FONT>
	</TD>
</TR>
</TABLE>
</cfif>

<TABLE align="center">
<TR>
<TD colspan="100%">
<CF_button
				button_name		=	""
				button_caption	=	"send #lcase(FAX_EMAIL_TEXT)# package"
				button_action	=	"confirmCompletion();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to send..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
</TD>
</TR>
</TABLE>

<INPUT NAME="HTML_File_Path" TYPE="hidden" VALUE="<CFOUTPUT>#EMAIL_HTML_File_Path#</CFOUTPUT>">
<INPUT NAME="Document_Number" TYPE="hidden" VALUE="<CFOUTPUT>#url.contract_number#</CFOUTPUT>">
<INPUT NAME="Redirect_To_File_Path" TYPE="hidden" VALUE="">
<INPUT NAME="Include_File_path" TYPE="hidden" VALUE="<CFOUTPUT>#EMAIL_The_File_Location#</CFOUTPUT>">
<INPUT NAME="FAX_EMAIL" TYPE="hidden" VALUE="<CFOUTPUT>#FAX_EMAIL_TEXT#</CFOUTPUT>">
<INPUT NAME="Document_Title_File_Title" TYPE="Hidden" VALUE="<cfoutput>#getcontracttitle.contract_title#</cfoutput>">

</form>
</cfif>


<cfset isfirst = 1>
<cfloop index = "programid"
  list = "#url.program_list#"
  delimiters = ",">
<cf_cryp type="en" string ="#programid#" key="#request.key#">
<CFSET URL.CID = cryp.value>
<cfset url.display_program =  1>
<cfset displayclosewindow = 0>
<!--- 69227 Cannot print program history versions
WE WERE ONLY EXECUTING COMMON QUERIES ONCE WHICH CAUSING SAME PROGRAM TO REPEATED  MULTIPLE TIME
ADDED BELOW VARIABLE WHICH WILL CAUSE COMMON QUERIES TO EXECUTE EVERY TIME IN LOOP
	---->
<cfset commonqueries_Called = 0>
<cfif isfirst NEQ 1>
<div class="BreakHere"></div>
</cfif>
<cfsavecontent variable = "programlist">
		<CFINCLUDE TEMPLATE="/scorecard/program_display.cfm">
<cfoutput>#programlist#</cfoutput>
</cfsavecontent>
<cfset isfirst = 0>
</cfloop>

<cffile action = "write" file="#EMAIL_The_File_Location#" output="#programlist#">

<cfoutput>#programlist#</cfoutput>

<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<script>

var ErrorCount = 0;
function confirmCompletion()
{

	var ErrorCount = 0;

		if(document.all.SenderAddress.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter your email address", document.all.error_SenderAddress);
		}
		else
		{
			clearQueue(document.all.error_SenderAddress);
		}


		 if(document.all.SenderSubject.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter a subject", document.all.error_SenderSubject);
		}
		else
		{
			clearQueue(document.all.error_SenderSubject);
		}

		if(document.all.Recipient_Email_Address)
		{
			var emailStr = jQuery("textarea[name=Recipient_Email_Address]").val();
			//if(document.all.Recipient_Email_Address.value.length == 0) CHROMEFIX
			if(emailStr.length == 0)
			{
				ErrorCount++;
				queueMessage("You must enter at least one email address", document.all.error_Recipient_Email_Address);
			}
			else
			{
				clearQueue(document.all.error_Recipient_Email_Address);
			}
		}

		if(document.all.Form_Fax_Numbers)
		{
			var faxStr = jQuery("textarea[name=Form_Fax_Numbers]").val();
			//if(document.all.Form_Fax_Numbers.value.length == 0) CHROMEFIX
			if(faxStr.length == 0)
			{
				ErrorCount++;
				queueMessage("You must enter at least one fax number", document.all.error_Fax_Numbers);
			}
			else
			{
				clearQueue(document.all.error_Form_Fax_Numbers);
			}
		}

<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0)
	{
		Email.submit()

	}
	else
	{
		showMessageWindow()
	}
}
</script>
<CF_MessageWindow>