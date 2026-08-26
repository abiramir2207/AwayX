<!------Send_Route_Message.cfm----->

<CFPARAM NAME="FORM.SENDERSUBJECT" 		DEFAULT="">
<CFPARAM NAME="FORM.MESSAGE_BODY" 		DEFAULT="">
<CFPARAM NAME="FORM.DOCUMENT_TYPE" 				DEFAULT=0>
<CFPARAM NAME="FORM.DOCUMENT_ID" 			DEFAULT="">
<cfparam name="FORM.Internal_Recipient_Email_Address" 	default="">
<cfparam name="Form.Notify_Recipient" 	default=0>

<CFIF Len(Trim(FORM.Internal_Recipient_Email_Address)) GT 0>
<CFTRANSACTION ACTION = "BEGIN">
	<CFTRY>
		<CFQUERY NAME="Update_Route_Message" DATASOURCE="#application.datasource#">
			SET NOCOUNT ON
			INSERT INTO	Route_Message
			(Sender_ID, Subject, Message_Body, Message_Date, Document_Type_ID, Document_ID)
			VALUES
			('#request.AccessStructure.User_ID#', '#left(FORM.SenderSubject, 250)#', '#FORM.Message_Body#', GetDate(), #FORM.Document_Type#, '#FORM.Document_ID#')
			SELECT Route_Message_ID = @@IDENTITY
			SET NOCOUNT OFF
		</CFQUERY>
		
		<!------
		<CFMAIL TO			=	"#Form.External_Recipient_Email_Address#"
		        FROM		=	"#request.AccessStructure.User_Email#"
		        SUBJECT		=	"#Form.Sendersubject#"
				TYPE		=	"html">		
				#Form.Message_Body#
			<cfmailparam file = "#APPLICATIONPATH##FORM.HTML_FILE_PATH#">
		</CFMAIL>----->

		
		<CFSET sendmail_Email="">
		<CFLOOP INDEX = "this_Internal_User_ID"
		  LIST = "#FORM.Internal_Recipient_Email_Address#"
		  DELIMITERS = ";">

		  	<CFSET thisEmailID="null">
		  	<CFIF Form.Notify_Recipient>
			  	<CFQUERY NAME="getEmailID_Recipients" DATASOURCE="#application.datasource#">
					SELECT	User_Email
					FROM	_Users
					WHERE	_Users.User_ID = '#this_Internal_User_ID#'
				</CFQUERY>
				
				<CFIF getEmailID_Recipients.recordCount GT 0>
					<CFSET thisEmailID=getEmailID_Recipients.User_Email>
					<CFSET sendmail_Email=ListAppend(sendmail_Email, thisEmailID,";")>
					<CFSET thisEmailID="'#thisEmailID#'">
				</CFIF>
			</CFIF>
			
		 	 
		  	
			<CFQUERY NAME="Update_Recipients" DATASOURCE="#application.datasource#">
				INSERT	INTO	Route_Recipient
				(Route_Message_ID, Recipient_ID, Recipient_Email)
				VALUES
				(#Update_Route_Message.Route_Message_ID#, '#this_Internal_User_ID#', #PreserveSingleQuotes(thisEmailID)#)
			</CFQUERY>

		</CFLOOP> 
		
				<!------Update_Route_Message.Route_Message_ID----->
		<CFTRANSACTION ACTION = "COMMIT"/>
		<!------<CFTRANSACTION ACTION = "ROLLBACK"/>----->
		<CFCATCH>
    		<CFTRANSACTION ACTION = "ROLLBACK"/>
				<CFRETHROW>
				<CFABORT>
		</CFCATCH>
	</CFTRY>
</CFTRANSACTION>
	<CFSET Encrypt_Document_Type 	= "BillbackInbox">
	<CFSET Encrypt_Document_ID 		= "">
	<CFINCLUDE TEMPLATE="/Common_Files/Encrypted_url.cfm">
			
	<CFIF Len(sendmail_Email) GT 0>
<!--- 			<CFMAIL TO			=	"#sendmail_Email#"
		        FROM		=	"#request.AccessStructure.User_Email#"
		        SUBJECT		=	"Communication Center Email Notification"
				TYPE="HTML"
				> --->
			<cfoutput>
			<CF_EMAILWrapper 
				TO			=	"#sendmail_Email#"
		        FROM		=	"#request.AccessStructure.User_Email#"
		        SUBJECT		=	"Communication Center Email Notification"
				TYPE="HTML" 
				messagetype="1" 
				generatedby="3" 
				apparea="3" 
				userid="#request.AccessStructure.user_id#">
				
				<TABLE WIDTH="100%">
				<TR VALIGN="top">
				<TD>
				Subject: #FORM.SENDERSUBJECT#<BR>
				Message: #Form.Message_Body#<BR>
				Acknowledge to the above message from the Communication Center
				<CFIF Len(Encrypted_Url) GT 0>
					<BR><A HREF="#Encrypted_Url#">Click here to goto the Communication Center...</A>		
				</CFIF>
				</TD>
				</TR>
				</TABLE>
		<!--- </CFMAIL> --->
		</CF_EMAILWRAPPER>
		</cfoutput>			
	</CFIF>
		<BR>
		<TABLE HEIGHT="100%" ALIGN="center">
		<TR>
		<TD>
		<SPAN CLASS="Title2" ALIGN="CENTER">
		Message Sent !!!
		<BR>
		Please wait while we bring you back to the billback
		</SPAN>
		</TD>
		</TR>
		</TABLE>		
		

<CFELSE>
	<BR>
		<B CLASS="fc_red">
		Invalid Recipient
		</B>		
</CFIF>
<script language="JavaScript">
function seeya()
{
	window.location.href="<CFOUTPUT>#RedirectURL#</CFOUTPUT>";
}
setTimeout('seeya()',2000); 
</script>