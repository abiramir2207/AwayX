<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save to database the settings from the prior screen											 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF Form.up_sv EQ 0>
	<CFQUERY NAME="Insert_Data" datasource="#application.datasource#">
		INSERT INTO _Users_Settings
			(
				Email_Message, 
				Email_Message_Date_Updated,
				user_id
			)
		VALUES
			(
				'#Email_Message#', 
				#Date_Updated#,
				'#request.AccessStructure.User_ID#'
			)
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="Update_Data" datasource="#application.datasource#">
		Update 	_Users_Settings
		Set		Email_Message				= 		'#Email_Message#',
				Email_Message_Date_Updated	=		 #Date_Updated#
		Where	user_id 					=		'#request.AccessStructure.User_ID#'
	</CFQUERY>
</CFIF>





<CFLOCATION URL="email_message_form.cfm?ID=#createuuid()#" ADDTOKEN="No">






