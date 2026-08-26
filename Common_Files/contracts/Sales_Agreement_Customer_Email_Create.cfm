<CFSET PAGE_TITLE="Email Customer info">
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<cfset Action = "Email">
	<CFINCLUDE TEMPLATE="/common_files/contracts/sales_agreement_customer_email_fax_handler.cfm">
<cfparam name="sort" default="name_last">


<cfset appSettings = application.appSettingsGet />

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.min.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/script/javascript/string_validations.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<script>

var ErrorCount = 0;
function confirmCompletion(disableClickedButtonName)
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
	
	//var recipients = combineEmails(document.all.Broker_Address.value, document.all.Broker_Address_2.value);
	//ChromeFix
	<cfif application.appSettingsGet.External_Contacts_Option eq 0>
		var recipients_2 = jQuery('input[name=Broker_Address_2]').val();
    <cfelse>
	    var recipients_2 = jQuery('textarea[name=Broker_Address_2]').val();
	</cfif>
	var recipients = combineEmails(jQuery("textarea[name=Broker_Address]").val(),recipients_2); //ChromeFix
	if ( recipients.length == 0 )   /*25704*/
	{
		ErrorCount++;
		queueMessage("You must enter at least one email address", document.all.error_Broker_Address);
	}
	else
	{
		clearQueue(document.all.error_Broker_Address);
	}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
  	// hide email recipient input
  	// document.all.Broker_Address.style.visibility = 'hidden';
  	// combine int email recipients & ext email recipients
	//	document.all.Broker_Address.value = recipients; //ChromeFix
	jQuery("textarea[name=Broker_Address]").hide().val(recipients);
		Email.submit()
		disableButton(disableClickedButtonName, true, false);
	}
	else 
	{
		showMessageWindow()
	}	
}
</script>
<CF_MessageWindow>	
	
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE>

<STYLE>
	textarea
		{
			font-size:	12px;
			width:		500px;
		}
</STYLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decode all of the URL Variables and retrieve the necessary data to populate the email fields	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif isDefined("URL.passedForm")>
	<cfparam name="completepath_email" 	default="">
</cfif>

<!--- decode the key values--->
<cfif not isDefined("URL.Export_Customer_ID")>
	<!--- Decode the Program ID that comes from the URL.CID variable --->
	<cf_cryp	type = "de" string = "#URL.CID#" key = "#request.key#">
	<CFSET URL.Export_Customer_ID=cryp.value>
</cfif>

	<!--- Decode the path of the file to be sent --->
	<cf_cryp	type = "de" string = "#Encoded_completepath_email#" key = "#request.key#">
	<CFSET completepath_email=cryp.value>

<!--- Get the customer info --->
<cfset useLakebaseForGet_Customer_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_customer") AND application.oLakebase.isTableMigrated("export_customer_details")>
<cfif useLakebaseForGet_Customer_Details>
	<cftry>
		<cfset Get_Customer_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("export_customer", {
				"export_customer_id" = "eq.#URL.Export_Customer_ID#",
				"select" = "export_customer_base_number,export_customer_id,export_customer_name"
			}, "export_customer_id", "export_customer_details", "export_customer_id", "export_customer_status_type"), "export_customer_base_number,export_customer_id,export_customer_name,export_customer_status_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Customer_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Customer_Details>
<CFQUERY NAME="Get_Customer_Details" datasource="#application.datasource#">
	SELECT	a.Export_Customer_ID,a.Export_Customer_Base_Number,a.Export_Customer_Name,b.Export_Customer_Status_Type
	FROM		Export_Customer a INNER JOIN Export_Customer_Details b
	ON a.Export_Customer_ID = b.Export_Customer_ID
	WHERE		a.Export_Customer_ID	=	'#URL.Export_Customer_ID#'
</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<FORM ACTION="sales_agreement_customer_email_send.cfm" METHOD="post" NAME="Email" ID="Email">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="Customer #Get_Customer_Details.Export_Customer_ID#" STYLE="width:540px;"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD ><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5" STYLE="width:540px;"></TEXTAREA></TD>
</TR>
</TABLE>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

</CFOUTPUT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Broker_Address"></span>
	</TD>
	<TD>&nbsp;<br><TEXTAREA NAME="Broker_Address" COLS="75" ROWS="5" STYLE="WIDTH:300px;" ONKEYPRESS="javaSCript: return Valid_Key_On_Email_Object();"><CFOUTPUT><cfif appSettings.getIncludeUsersEmailAuto()>#request.AccessStructure.User_Email#</cfif></CFOUTPUT></TEXTAREA>
	</TD>
	<TD ALIGN="left">
				<TABLE cellpadding="0" cellspacing="0">
					<TR><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
						<TD nowrap><span title="Sort by Last Name">
							<CF_button
								button_name		=	""
								button_caption	=	"Last"
								button_action	=	"sortOptionslast(document.all.Email.E_User_Email_Address)"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	"Last"
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"></span>
						</TD>
						<TD><span title="Sort by Email">
							<CF_button
								button_name		=	""
								button_caption	=	"Email"
								button_action	=	"sortOptionsemail(document.all.Email.E_User_Email_Address)"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	"Email"
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold"></span>
						</TD>
					</TR>
					<TR>
						<TD id="EmLook" colspan="4">
							<CF_Email_Address_Lookup 
								Destination_Form_Name="Email"
								Destination_Field_Name="Broker_Address"
								width="350"
								size="5"
								Alert="true"
								sort ="#sort#"> 
						</TD>
					</TR>
				</TABLE>
	</TD>
</TR>
<TR>
	<TD></TD>
	<TD COLSPAN="2">
	<FONT COLOR="Red"><B><I>To add more recipients, add the email addresses separating them with a semi- colon ( ;)</I></B></FONT>
	</TD>
</TR>
</TABLE>
--->

<!--25704 - 2011-mar-15 added ext. contacts-->
<cfscript>
  intEmails_value = "";
  if ( appSettings.getIncludeUsersEmailAuto() ) {
    intEmails_value = request.AccessStructure.User_Email;
  }
</cfscript>

<cf_emailRecipient
          intEmails_name  = "Broker_Address"  
          intEmails_value = #intEmails_value#
          company_codes   = ""  >

<cfif Not isDefined("URL.passedForm")>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<HR COLOR="Orange">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFSET reversed_completepath_email = reverse(completepath_email)>
		<CFSET filename_enail=reverse(left(reversed_completepath_email, find("\", reversed_completepath_email)-1))>
		<INPUT NAME="Customer_Name" TYPE="hidden" VALUE="<CFOUTPUT>#filename_enail#</CFOUTPUT>">
</cfif>

<BR CLEAR="ALL">
<BR>

<!--- Encrypt the CID the file --->
<cf_cryp	type = "en" string = "#Get_Customer_Details.Export_Customer_ID#" key = "#request.key#">
<CFSET CID=cryp.value>

<TABLE>
	<TR>
		<TD>
			<CF_button
				button_name		=	"send"
				button_caption	=	"send email package"
				button_action	=	"confirmCompletion('send_table');"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to send..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"return to Customer view"
				button_action	=	"window.location.href='sales_agreement_customer_request.cfm?CID=#CID#';"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Click here to return to customer view..."
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold">
		</TD>
	</TR>
</TABLE>

<cfoutput>
<INPUT TYPE="Hidden" NAME="Customer_number" VALUE="#Get_Customer_Details.Export_Customer_ID#">
<INPUT TYPE="Hidden" NAME="Customer_Base_number" VALUE="#Get_Customer_Details.Export_Customer_Base_Number#">
<INPUT TYPE="hidden" NAME="Customer_CID" VALUE="#CID#">
</cfoutput>
</FORM>

</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>
