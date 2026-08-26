<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Email_Common_Form.cfm
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFSET PRINT_Expected_Attribute_List = "Include_File_path,Document_Title,Document_Number_Variable,Document_Title_Variable,Redirect_To_File_Path,FAX_EMAIL,pdf_folder">

<CFPARAM NAME="Attributes.Include_File_path" 	DEFAULT="">
<CFPARAM NAME="Attributes.Document_Title" 			DEFAULT="">
<CFPARAM NAME="Attributes.Document_Number_Variable" 	DEFAULT="">
<CFPARAM NAME="Attributes.Document_Title_Variable" 	DEFAULT="">
<CFPARAM NAME="Attributes.Redirect_To_File_Path" 	DEFAULT="">
<CFPARAM NAME="Attributes.FAX_EMAIL" 	DEFAULT="EMAIL">
<CFPARAM NAME="Attributes.Document_Title_File_Prefix" 	DEFAULT="">
<CFPARAM NAME="Attributes.contract_number" 	DEFAULT="">
<cfparam name="attributes.displayoutput" default="1">
<CFPARAM NAME="Attributes.Provide_Close_Link" default="">
<CFPARAM NAME="Attributes.Use_To_Email_Address_Instead_Of_Lookup" default="">
<!--- "To" Email and "CC" Email capability --->
<CFPARAM NAME="Attributes.BothTypes" default="0">
<CFPARAM NAME="Attributes.PDF_Footer" default="">
<CFPARAM NAME="Attributes.Language" default="">

<cfset CT_File_Path = Caller.Request.ApplicationPath>
<cfset CT_File_Mapping = "">
<cfif IsDefined("Caller.Application.Doc_Path")>
	<cfset CT_File_Path = Caller.Application.Doc_Path>
	<cfset CT_File_Mapping = Caller.Application.Doc_Mapping>
</cfif>

<CFSET RETURN_URL_KEYWORK = "RETURN_URL_">
<CFSET EMAIL_TEMP_FILE_FOLDER = "Temp_Files">

<CFIF Len(Trim(Attributes.Include_File_path)) LTE 0>
	<CFABORT>
</CFIF>
<CFSET EMAIL_SEND_AS_FORM_ELEMS = "">
<CFSET EMAIL_SEND_AS_URL_ELEMS = "">
<CFLOOP COLLECTION="#Attributes#" ITEM="FormItem">
	<CFSET "#FormItem#"="#Evaluate("Attributes.#FormItem#")#">
	<CFIF NOT ListFindNoCase(PRINT_Expected_Attribute_List, FormItem, ",")>
		<CFOUTPUT>
		<CFSAVECONTENT VARIABLE="EMAIL_SEND_AS_FORM_ELEMS">
		#EMAIL_SEND_AS_FORM_ELEMS#<INPUT TYPE="HIDDEN" NAME="#FormItem#" VALUE="#Evaluate("#FormItem#")#">
		</CFSAVECONTENT>
		</CFOUTPUT>
	</CFIF>
	<CFIF Left(FormItem, Len(RETURN_URL_KEYWORK)) EQ RETURN_URL_KEYWORK>
		<CFSET EMAIL_SEND_AS_URL_ELEMS = ListAppend(EMAIL_SEND_AS_URL_ELEMS, "#Right(FormItem, Evaluate("#Len(FormItem)# - #Len(RETURN_URL_KEYWORK)#"))#=#Evaluate("#FormItem#")#", "&")>
	</CFIF>
</CFLOOP>

<CFSAVECONTENT VARIABLE="EMAIL_FILE_CONTENT">
	<HTML>
	<HEAD>
	<TITLE></TITLE>
	<STYLE>
	<CFINCLUDE TEMPLATE="/Common_files/main_Style.css">
	</STYLE>
	</HEAD>
	<BODY>
	<cfif Attributes.contract_number NEQ "">
	<cfset url.contract_number = Attributes.contract_number>
	</cfif>
	<cfset request.language = attributes.language>
	<CFINCLUDE TEMPLATE="#Attributes.Include_File_path#">
	</BODY>
	</HTML>
</CFSAVECONTENT>
<!--- D37787 :Emails for Quote Letters not Sending
when program title have a special character like # coldufusion throws an event error as there is no mathching close tag.
Added code to replace # with empty string.
--->
<cfset Attributes.Document_Title_Variable = #replace(Attributes.Document_Title_Variable, "##", "", "ALL")#>

<CFSET EMAIL_SUBJECT="#Attributes.Document_Title#">
<CFIF Len(Trim(Attributes.Document_Number_Variable)) GT 0>
	<CFSET Document_Number = Evaluate("#Attributes.Document_Number_Variable#")>
	<CFSET EMAIL_SUBJECT="#EMAIL_SUBJECT# [#Document_Number#]">
<CFELSE>
	<CFSET Document_Number = Replace(CreateUUID(), "-", "_", "All")>
</CFIF>

<CFIF Len(Trim(Attributes.Document_Title_Variable)) GT 0>
	<CFSET EMAIL_SUBJECT="#EMAIL_SUBJECT# #Evaluate("#Attributes.Document_Title_Variable#")#">
</CFIF>

<CFSET EMAIL_FILE_CONTENT = REReplace(EMAIL_FILE_CONTENT, "<TITLE>.*?</TITLE>", "<TITLE>#EMAIL_SUBJECT#</TITLE>")>


<!--- Date/Time stamp construction to be used in the naming scheme of the file --->
<CFSET EMAIL_datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">
<CFSET EMAIL_filename_email	=	"#Document_Number#_#EMAIL_datetimestamp#_#gettickcount()#">
<CFSET EMAIL_HTML_File_Path="/#EMAIL_TEMP_FILE_FOLDER#/#EMAIL_filename_email#.htm">
<CFSET EMAIL_File_Path="\#EMAIL_TEMP_FILE_FOLDER#\#EMAIL_filename_email#.htm">
<CFSET EMAIL_The_File_Location = CT_File_Path & EMAIL_File_Path>
<CFSET EMAIL_completepath=EMAIL_The_File_Location>

<!--- Save the file to the server --->
<cffile action="write" file="#EMAIL_completepath#" output="#EMAIL_FILE_CONTENT#">


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<HTML>
<HEAD>
	<TITLE><cfoutput>#Attributes.Document_Title#</cfoutput></TITLE>

  <script type="text/javascript" src="/script/javascript/string_functions.min.js"></script>  <!--25704-->
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

  <cfif Attributes.Fax_Email neq "FAX">

  		//var recipients = combineEmails(document.all.Recipient_Email_Address.value, document.all.Recipient_Email_Address_2.value);   /*25704*/
		//ChromeFix
		 <cfif application.appSettingsGet.External_Contacts_Option eq 0>
			var recipients_2 = jQuery('input[name=Recipient_Email_Address_2]').val();
	    <cfelse>
		    var recipients_2 = jQuery('textarea[name=Recipient_Email_Address_2]').val();
		</cfif>
		 var recipients = combineEmails(jQuery("textarea[name=Recipient_Email_Address]").val(),recipients_2); //ChromeFix ::  Recipient_Email_Address_2 is undefined and we need to reference textarea via jQuery
			if ( recipients.length == 0 )
			{
				ErrorCount++;
				queueMessage("Please enter at least one email address", document.all.error_Recipient_Email_Address);
			}
			else
			{
				clearQueue(document.all.error_Recipient_Email_Address);
			  clearQueue(document.all.error_Recipient_Email_Address_2);  /*25704*/
			}
  </cfif>

		if(document.all.Form_Fax_Numbers)
		{
			if(document.all.Form_Fax_Numbers.value.length == 0)
			{
				ErrorCount++;
				queueMessage("You must enter at least one fax number", document.all.error_Fax_Numbers);
			}
			else
			{
				clearQueue(document.all.error_Form_Fax_Numbers);
			}
		}

				if(document.all.CC_Recipient_Email_Address)
				{
					var IsValidEmail = '';
					var separator = ";";
					var emails = document.all.CC_Recipient_Email_Address.value.split(separator);
					var EmailString = '';
							for(var i=0; i<emails.length; i++)
							{
								emails[i] = emails[i].replace(/(^[ \n\r]*)|([ \n\r]*$)/g, ""); //trim spaces
								IsValidEmail = /^[\w']+([\.-]?[\w']+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(emails[i])
								if(!IsValidEmail)
								{
									if(EmailString == '')
									{
										EmailString = EmailString + emails[i];
									}
									else
									{
										EmailString = EmailString + ',' + emails[i];
									}
								}
							}

								if(EmailString != '')
								{
										ErrorCount++;
										queueMessage("The following addresses were invalid - "  + EmailString, document.all.error_CC_Email_Address);
								}
								else
								{
										clearQueue(document.all.error_CC_Email_Address);
								}
						}

<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0)
	{
    if (typeof recipients != "undefined") {
    	// hide email recipient input
       //document.all.Recipient_Email_Address.style.visibility = 'hidden';
       // document.all.Recipient_Email_Address.value = recipients; //ChromeFix
		jQuery("textarea[name=Recipient_Email_Address]").hide().val(recipients);
    }
		Email.submit()

	}
	else
	{
		showMessageWindow()
	}
}

</script>
<CF_MessageWindow>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<STYLE>
	input[type=text],textarea
		{
			font-size:	12px;
			width:		500px;
		}
</STYLE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the email create page  																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET Accessstructure = Caller.Request.Accessstructure>
<BR>
<FORM ACTION="/Common_Files/Email_Common_Send.cfm" METHOD="post" NAME="Email" ID="MyForm">
<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset sSenderAddress = "" />
<cfif IsDefined("request.AccessStructure")>
	<cfset sSenderAddress = "#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" />
<cfelseif IsDefined("AccessStructure")>
	<cfset sSenderAddress = "#AccessStructure.Name_First# #AccessStructure.Name_Last# (#AccessStructure.User_Email#)" />
</cfif>
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#sSenderAddress#" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="#EMAIL_SUBJECT#"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5"></TEXTAREA></TD>
</TR>
</TABLE>
</CFOUTPUT>

<BR><BR>

<CFIF Attributes.FAX_EMAIL EQ "FAX">

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

<CFELSE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<CFIF Trim(Attributes.Use_To_Email_Address_Instead_Of_Lookup) EQ "">
<!---
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
--->
    <cf_emailRecipient
              intEmails_name  = "Recipient_Email_Address"
              company_codes   = ""                        >     <!---25704--->
<CFELSE>
  	<cfoutput>
	  <TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Recipient_Email_Address"></span></TD>
  	<TD><INPUT NAME="Recipient_Email_Address" value="#Attributes.Use_To_Email_Address_Instead_Of_Lookup#" readonly="">
  	</cfoutput>
  	</TD>
	</CFIF>
</TR>
<!--<CFIF Attributes.BothTypes eq 1>
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><span id="error_CC_Email_Address"></span><B>cc:&nbsp;&nbsp;</B></TD>
	<TD><INPUT NAME="CC_Recipient_Email_Address"></TD>
</TR>
</CFIF>
<CFIF Trim(Attributes.Use_To_Email_Address_Instead_Of_Lookup) EQ "" OR Attributes.BothTypes eq 1>
<TR>
	<TD></TD>
	<TD COLSPAN="2">
	<FONT COLOR="Red"><B><I>To add more recipients, add the email addresses separating them with a semi-colon ( ;)</I></B></FONT>
	</TD>
</TR>
</CFIF>
-->
</TABLE>


</CFIF>

<INPUT NAME="HTML_File_Path" TYPE="hidden" VALUE="<CFOUTPUT>#EMAIL_File_Path#</CFOUTPUT>">
<INPUT NAME="EMAIL_HTML_File_Path" TYPE="hidden" VALUE="<CFOUTPUT>#EMAIL_HTML_File_Path#</CFOUTPUT>">
<INPUT NAME="Document_Number" TYPE="hidden" VALUE="<CFOUTPUT>#Document_Number#</CFOUTPUT>">
<INPUT NAME="Redirect_To_File_Path" TYPE="hidden" VALUE="<CFOUTPUT>#Attributes.Redirect_To_File_Path#</CFOUTPUT>">
<INPUT NAME="Include_File_path" TYPE="hidden" VALUE="<CFOUTPUT>#Attributes.Include_File_path#</CFOUTPUT>">
<INPUT NAME="FAX_EMAIL" TYPE="hidden" VALUE="<CFOUTPUT>#Attributes.FAX_EMAIL#</CFOUTPUT>">
<INPUT NAME="Document_Title_File_Title" TYPE="Hidden" VALUE="<CFOUTPUT>#Attributes.Document_Title_File_Prefix##Evaluate("#Attributes.Document_Title_Variable#")#</CFOUTPUT>">

<!--- <input type="hidden" name="pdf_footer" value="<cfoutput>#attributes.pdf_footer#</cfoutput>"> --->
<CFOUTPUT>#EMAIL_SEND_AS_FORM_ELEMS#</CFOUTPUT>


<BR CLEAR="ALL">
<BR>



<TABLE ALIGN="center">
	<TR>
		<CFIF Len(Trim(Attributes.Redirect_To_File_Path)) GT 0>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"return to the document"
				button_action	=	"window.location.href='#Attributes.Redirect_To_File_Path#?#EMAIL_SEND_AS_URL_ELEMS#';"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to return to the document..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
		</CFIF>
		<CFIF Attributes.Provide_Close_Link EQ "1">
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"close window"
				button_action	=	"window.close();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to close this window ..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
		</CFIF>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"send #lcase(Attributes.FAX_EMAIL)# package"
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
 </BLOCKQUOTE>
</FORM>
<BR><BR>





<cfif attributes.displayoutput EQ 1>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2"><cfoutput>#Attributes.Document_Title#</cfoutput> Details</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFINCLUDE TEMPLATE="#CT_File_Mapping##EMAIL_HTML_File_Path#">
</cfif>


</BODY>
</HTML>




