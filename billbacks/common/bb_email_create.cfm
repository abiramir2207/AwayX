<cfinclude template="/common_files/jQuery.cfm">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Billback</TITLE>
	
  <script type="text/javascript" src="/script/javascript/string_functions.min.js"></script>  <!--25704-->
	<script>

<cfparam name="sort" default="name_last"><!--- name_last --->
<cfset appSettings = application.appSettingsGet />
	
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

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
		<cfif application.appSettingsGet.External_Contacts_Option eq 0>
			var recipients_2 = jQuery('input[name=Recipient_Email_Address_2]').val();
	    <cfelse>
		    var recipients_2 = jQuery('textarea[name=Recipient_Email_Address_2]').val();
		</cfif>
			var recipients = combineEmails(jQuery("textarea[name=Recipient_Email_Address]").val(),recipients_2); //ChromeFix ::  Recipient_Email_Address_2 is undefined and we need to reference textarea via jQuery
		////jQuery( "input[name=Recipient_Email_Address_2]").val()  document.all.Recipient_Email_Address_2.value  document.all.Recipient_Email_Address.value
		if ( recipients.length == 0 )   /*25704*/
		{
			ErrorCount++;
			queueMessage("Please enter at least one email address", document.all.error_Recipient_Email_Address);
		}
		else
		{
			clearQueue(document.all.error_Recipient_Email_Address);
		}
		
/// SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX
	if(ErrorCount == 0) 
	{
    if (typeof recipients != "undefined") {
    	// hide email recipient input
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
	textarea
		{
			font-size:	12px;
			width:		500px;
		}
</STYLE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the email create page  																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFPARAM NAME="URL.BBID"								DEFAULT="">
<CFSET Billback_ID=URL.BBID>
<CFSET Display_None_Attachments = 1>
<CFINCLUDE TEMPLATE="Billback_Summary_Save.cfm">

  
<CFPARAM NAME="Billback_Billback_Title" 	DEFAULT="#application.returned_customer_setting.Trade_Label# Checkbook">

<BR>
<FORM ACTION="bb_email_send.cfm" METHOD="post" NAME="Email" ID="MyForm">
<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Message Details:</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
	<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 2	50px;"></TD>
	<!--- <TD ROWSPAN="100%"><IMG SRC="/images/email.gif"></TD> --->
</TR>
<TR>
	<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B><span id="error_SenderAddress"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderAddress" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)" STYLE="width: 250px;"></TD>
</TR>
<TR>
	<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B><span id="error_SenderSubject"></span></TD>
	<TD><INPUT TYPE="text" NAME="SenderSubject" SIZE="30" VALUE="Billback #Billback_Payable_Number# - #Billback_Billback_Title#" STYLE="width:500px"></TD>
</TR>
<TR>
	<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
	<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5"></TEXTAREA></TD>
</TR>
</TABLE>
</CFOUTPUT>
<BR><BR>


<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>
<CFQUERY NAME="mail_Documents" DATASOURCE = "#Application.Datasource#">
	SELECT 		contract_Attachments.doc_id,
				Doc_Uni_Name,
				doc_title,
				Doc_Description,
				Uploaded_Date,
				Uploaded_By,
				Doc_Type,
				Doc_File_Name,
				Doc_Size 

	FROM 		contract_Attachments
	LEFT JOIN 	Document_Details ON contract_Attachments.Doc_ID = Document_Details.Doc_ID 
	WHERE 		contract_Attachments.Billback_ID = '#URL.BBID#' 
	AND			contract_Attachments.deleted=0
				AND (	(	Public_View = 1
							AND User_Position_ID IN (#preserveSingleQuotes(Access_Position_List)#)
						) 						
							OR Public_View = 0	
					)
</CFQUERY>
<CFIF mail_Documents.recordcount GT 0>

<SPAN CLASS="title2">Attachments</SPAN>
<HR COLOR="Orange">


<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="80%">	
	<TR >
		<TD>&nbsp;</TD>
		<TD BGCOLOR="#ffce84">&nbsp;</TD>
		<TD ID="headed" STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Date / Name</TD>
		<TD ID="header" STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">File</TD>
		<TD STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Title / Description</TD>
		<TD STYLE="font-size: 11px; font-weight: bold;" BGCOLOR="#ffce84">Type</TD>
	</TR>
		<CFOUTPUT QUERY="Mail_Documents">
		<cfset useLakebaseForget_userName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForget_userName>
	<cftry>
		<cfset get_userName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Uploaded_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_userName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_userName>
<CFQUERY NAME="get_userName" DATASOURCE="#Application.Datasource#">
			SELECT 		Name_First,
						Name_Last
			FROM		_users
			WHERE 		User_ID = '#Uploaded_By#'
		</CFQUERY>
</cfif>
		<TR>		
		<TD WIDTH="100">&nbsp;</TD>		
		 <TD ALIGN="right" VALIGN="TOP" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"><INPUT TYPE="Checkbox" NAME="Doc_ID" VALUE="#Doc_ID#" >&nbsp;&nbsp;</TD> 
		 <TD WIDTH="125"  VALIGN="TOP" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">#dateFormat(Uploaded_Date,"mm/dd/yyyy")#<BR>#get_userName.Name_First# #get_userName.Name_Last#</TD>
		<CFSET SIZEinKB = #Doc_Size#/1024>
		<TD VALIGN="TOP" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"><A href="javascript: confirmation('#Doc_Uni_Name#');" TITLE="Click here to view '#Doc_File_Name#'">
		<CFSET Display_Name=Left(Doc_File_Name,10)>
			<CFIF len(trim(Doc_File_Name)) GT 10>
				#LCASE(Display_Name)#...
			<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
				&nbsp;
			<CFELSE>
				#LCASE(Display_Name)#	
			</CFIF>		</A>&nbsp;&nbsp;<br>#numberFormat(SIZEinKB,"_.___")# KB</TD>
		<TD VALIGN="TOP" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"><FONT COLOR="red">#Doc_Title#</FONT>&nbsp;&nbsp;<br>Description: #Doc_Description#</TD>
		<TD NOWRAP VALIGN="TOP" WIDTH="12%" BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">#Doc_Type#</TD>
		</TR>
	</CFOUTPUT>		
	</TABLE>	
<BR><BR>

</CFIF>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Recipients' Email Addresses</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--25704 - 2011-mar-15 added ext. contacts-->
<cfscript>
  intEmails_value = Billback_Recipient_Email_Address;
  if ( appSettings.getIncludeUsersEmailAuto() ) {
    if ( Len(intEmails_value) ) {
      intEmails_value =  intEmails_value & ";";
    }
    intEmails_value =  intEmails_value & request.AccessStructure.User_Email;
  }
</cfscript>

<!--get the shared code for companyCodes() function-->
<cfinclude template="\billbacks\common\companycodes.cfm">   
  
<cf_emailRecipient
          intEmails_name  = "Recipient_Email_Address"  
          intEmails_value = #intEmails_value#
          company_codes   = #CompanyCodes(Billback_ID)#  >

<!---
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR VALIGN="top">
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Recipient_Email_Address"></span></TD>
	<TD>&nbsp;<br><TEXTAREA NAME="Recipient_Email_Address" COLS="5" ROWS="15" STYLE="width:300px;"><CFOUTPUT><cfif appSettings.getIncludeUsersEmailAuto()>#request.AccessStructure.User_Email#<cfif len(Billback_Recipient_Email_Address) GT 0>;</cfif></cfif>#Billback_Recipient_Email_Address#</CFOUTPUT></TEXTAREA>
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
						Destination_Field_Name="Recipient_Email_Address"
						width="300"
						size="15"
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
<CFOUTPUT>
	<INPUT NAME="HTML_File_Path" TYPE="hidden" VALUE="#Billback_HTML_File_Path#">
	<INPUT NAME="Billback_ID" TYPE="hidden" VALUE="#Billback_ID#">
	<INPUT NAME="Payable_No" TYPE="hidden" VALUE="#Billback_Payable_Number#">
	<INPUT NAME="BB_Title" TYPE="hidden" VALUE="#Billback_Billback_Title#">
</CFOUTPUT>
<CFIF isdefined("URL.SHOW_FAX_EMAIL_VERSION")> 
	<CFIF URL.SHOW_FAX_EMAIL_VERSION EQ 1>
		<INPUT TYPE="Hidden" NAME="Deviation" VALUE="1"> 
	</CFIF>
</CFIF>
<BR CLEAR="ALL">
<BR>

<TABLE ALIGN="center">
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"send email package"
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

<!--- removed with 22661
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SPAN CLASS="title2">Billback Details</SPAN>
<HR COLOR="Orange">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<CFINCLUDE TEMPLATE="#Application.Doc_Mapping##Billback_HTML_File_Path#">
	<script>
	// Calls function to make iFrame same height as Browser Window
	// Needs to load the included template first before it can determine the size
	try { window.parent.dyniframesize(); } catch (err) { };
	</script>
--->

	<script>
	// Calls function to make iFrame same height as Browser Window
	// Needs to load the included template first before it can determine the size
	try { window.parent.dyniframesize(); } catch (err) { };
	</script>

</BODY>
</HTML>

 