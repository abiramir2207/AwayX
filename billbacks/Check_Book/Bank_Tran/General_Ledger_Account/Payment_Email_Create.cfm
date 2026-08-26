<script type="text/javascript" src="/script/javascript/string_functions.min.js"></script>  <!--25704-->
<script>
function confirmCompletion() {
	var ErrorCount = 0;
	 //ChromeFix
	// var recipients = combineEmails(document.Prepare_Email.Send_to.value, document.Prepare_Email.Send_to_2.value);
	  <cfif appSettings.External_Contacts_Option eq 0>
			var recipients_2 = jQuery('input[name=Send_to_2]').val();
     <cfelse>
	       var recipients_2 = jQuery('textarea[name=Send_to_2]').val();
	 </cfif>
	var recipients = combineEmails(jQuery("textarea[name=Send_To]").val(),recipients_2); //ChromeFix 
		if ( recipients.length == 0 )   /*25704*/
		{
			ErrorCount++;
			queueMessage("Please enter at least one email address", document.Prepare_Email.error_Send_to);
		}
		else
		{
			clearQueue(document.Prepare_Email.error_Send_to);
		}
		
	if(ErrorCount == 0) {
  	// hide email recipient input
  //	document.Prepare_Email.Send_to.style.visibility = 'hidden';
  	// combine int email recipients & ext email recipients
	//	document.Prepare_Email.Send_to.value = recipients; //ChromeFix
	jQuery("textarea[name=Send_to]").hide().val(recipients);
		Prepare_Email.submit()
	}
	else 
		showMessageWindow()
}
</script>
<CF_MessageWindow>	

<BR>



<FONT SIZE="3" COLOR="Navy"><B>Message Details:</B></FONT>
<HR COLOR="Orange">
<FORM NAME="Prepare_Email" ACTION="Payment_Email_Send.cfm" METHOD="POST">
<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Att_File_Name" VALUE="#File_Name#">
</CFOUTPUT>
<CFIF isdefined("URL.Email_All")>
<INPUT TYPE="hidden" NAME="Att_File_List" VALUE="1">
</CFIF>
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
	<TR>
		<TD ALIGN="right" WIDTH="150"><B>Date:&nbsp;&nbsp;</B></TD>
		<TD><INPUT TYPE="text" NAME="SenderDate" SIZE="30" VALUE="#dateformat(now(), 'mmmmm d, yyyy')#" STYLE="width: 250px;"></TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>From:&nbsp;&nbsp;</B></TD>
		<TD><INPUT TYPE="Text" NAME="Sender_Name" SIZE="30" VALUE="#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# (#request.AccessStructure.User_Email#)"STYLE="width: 250px;"> </TD>
	</TR>
	<TR>
		<TD ALIGN="right"><B>Subject:&nbsp;&nbsp;</B></TD>	
		<TD><INPUT TYPE="Text" NAME="SenderSubject" SIZE="30" VALUE="Payment Request <CFIF isdefined("Num_Payment_req")>(#Num_Payment_req#)</CFIF>"></TD>	
	</TR>
	<TR>
		<TD ALIGN="right" VALIGN="TOP"><B>Message Body:&nbsp;&nbsp;</B></TD>
		<TD><TEXTAREA NAME="Message_Body" COLS="75" ROWS="5" STYLE="width:540px;"></TEXTAREA></TD>
	</TR>
</TABLE>
</CFOUTPUT>
<BR><BR>
<FONT SIZE="3" COLOR="Navy"><B>Recipients' Email Addresses:</B></FONT>
<HR COLOR="Orange">


<!---<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" >
<TR>
	<TD ALIGN="right" WIDTH="150" VALIGN="TOP"><B>Recipients:&nbsp;&nbsp;</B><span id="error_Broker_Address"></span></TD>
	<TD><TEXTAREA NAME="Send_to" COLS="55" ROWS="5" ></TEXTAREA></TD>
	<TD ALIGN="left">
	<CF_Email_Address_Lookup 
			Destination_Form_Name="Prepare_Email"
			Destination_Field_Name="Send_to"
			width="200"
			size="5"
			Alert="true">
	</TD>
</TR>
<TR>
	<TD></TD>
	<TD COLSPAN="2">
	<FONT COLOR="Red"><B><I>Please make sure each email address is separated by a semi- colon ( ;)</I></B></FONT>
	</TD>
</TR>
</TABLE>
--->

<!--get the shared code for companyCodes() function-->
<cfinclude template="\billbacks\common\companycodes.cfm">   

<!--25704 - 2011-mar-15 added ext. contacts-->
<cf_emailRecipient
          intEmails_name  = "Send_to"  
          company_codes   = #CompanyCodes(GetBBDetails.Billback_ID)#  >

<TABLE ALIGN="Center">
	<TR>
		<TD>
			<CFOUTPUT>
				<CF_button
					button_name		=	""
					button_caption	=	"Send Email"
					button_action	=	"confirmCompletion()"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
			</CFOUTPUT>
		</TD>
	</TR>
</TABLE>
</FORM>
<CFIF not isdefined("URL.Email_All")>
<BR><BR>
<!--- <FONT SIZE="3" COLOR="Navy"><B>Payment Details:</B></FONT> --->

<CFOUTPUT>#Mail_Fax#</CFOUTPUT>
</CFIF>
