
<CFQUERY NAME="INSERT" datasource="#application.datasource#">
	INSERT INTO Purge_Log_Settings
		(User_ID,Phase_1_Period,Phase_1_Message,Phase_1_Email_Address,
		Phase_2_Period,Phase_2_Message,Phase_2_Email_Address)
	VALUES
		('#request.AccessStructure.User_ID#',
		'#D1#',
		 <cfif len(trim(FORM.Email_Message1)) EQ 0 >
		'Check the Phase I Log' ,
		<CFELSE>
		 '#Email_Message1#',
		 </cfif>
		'#Email_Address1#',
		'#D2#',
		<cfif len(trim(FORM.Email_Message1)) EQ 0 >
		'Check the Phase II Log' ,
		<CFELSE>
		 '#Email_Message2#',
		 </cfif>
		'#Email_Address2#')
</CFQUERY>		

<CFLOCATION URL="Purge_Settings1.cfm?ID=#createuuid()#" ADDTOKEN="No">

