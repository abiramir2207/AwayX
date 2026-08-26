<CFSET PAGE_TITLE="Fax Customer Info">
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<cfset Action = "Fax">
	<CFINCLUDE TEMPLATE="/common_files/contracts/sales_agreement_customer_email_fax_handler.cfm">
<CFSET Fax_number = "">
<CFSET Fax_List = "">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
		<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
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
		if(document.all.Fax_Number.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must enter at least one fax number", document.all.error_Fax_Number);
		}
		else
		{
			clearQueue(document.all.error_Fax_Number);
		}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
		Fax.submit()
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
<BLOCKQUOTE>


<!--- 
<BR><BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here	--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=9>
<CFINCLUDE TEMPLATE="/help_files/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
--->

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

<!--- Decode the Program ID that comes from the URL.TID variable --->
<cfif not isDefined("URL.Export_Customer_ID")>
	<cf_cryp	type = "de" string = "#URL.CID#" key = "#request.key#">
	<CFSET URL.Export_Customer_ID=cryp.value>
</cfif>

	<!--- Decode the path of the file to be sent --->
	<cf_cryp	type = "de" string = "#Encoded_completepath_email#" key = "#request.key#">
	<CFSET completepath_email = cryp.value>

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

<CFSET Fax_Number = Fax_List>

<FORM ACTION="sales_agreement_customer_fax_send.cfm" METHOD="post" NAME="Fax">

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
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30"VALUE="Customer #Get_Customer_Details.Export_Customer_ID#" STYLE="width:540px;"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5" STYLE="width:540px;"></TEXTAREA><BR>
</TD>
</TR>
</TABLE>
<INPUT TYPE="Hidden" NAME="Customer_number" VALUE="#Get_Customer_Details.Export_Customer_ID#">
<INPUT TYPE="Hidden" NAME="Customer_Base_number" VALUE="#Get_Customer_Details.Export_Customer_Base_Number#">
<INPUT TYPE="hidden" NAME="Customer_CID" VALUE="#CID#">
</CFOUTPUT>

<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Fax Numbers</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Fax_Number"></span></TD>
	<TD>
		<TEXTAREA NAME="Fax_Number" COLS="75" ROWS="5" onKeyUp="clenseText(this, '0123456789;')" STYLE="width:540px;"><CFOUTPUT>#Fax_Number#</CFOUTPUT></TEXTAREA><BR>
		<FONT COLOR="Red"><B><I>
ALL FAX NUMBERS MUST BY PRECEDED BY THE APPROPRIATE COUNTRY CODE - FOR UNITED STATES YOU MUST PRECEDE THE AREA CODE WITH A "1"<BR>
To add more recipients, add the fax numbers separating them with a semi- colon ( ;)<BR>
			Please make sure that there are no spaces, dashes in the FAX number.
		</I></B></FONT>
	</TD>
</TR>
</TABLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFSET reversed_completepath_email=reverse(completepath_email)>
	<CFSET filename_enail=reverse(left(reversed_completepath_email, find("\", reversed_completepath_email)-1))>
	<INPUT NAME="Customer_Name" TYPE="hidden" VALUE="<CFOUTPUT>#filename_enail#</CFOUTPUT>">

<br clear="all">

<CF_button
	button_name		=	"send"
	button_caption	=	"send fax"
	button_action	=	"javascript:confirmCompletion('send_table');"
	button_type		=	"javascript_link"
	button_width	=	"150"
	button_color	=	"Navy"
	button_tip		=	"Click here to send a fax..."
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold">

</FORM>
</BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>