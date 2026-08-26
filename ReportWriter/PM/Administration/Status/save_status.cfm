

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM PM_Status  
		WHERE		PM_Status_ID			=	'#Form.PM_Status_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_status.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- Check for the presence of data --->
<CFIF trim(Form.PM_Status_Description) EQ "" OR trim(Form.PM_Status_Description) EQ 0>
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>

<CFIF Form.PM_Status_ID EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		PM_Status
						(PM_Status_Description,PM_Status_Definition,PM_Status_Deleted,PM_Updated_UserId)
		Values			('#Form.PM_Status_Description#','#Form.PM_Status_Definition#',#Form.PM_Status_Deleted#,'#request.AccessStructure.User_Id#')
	</CFQUERY>
	<CFLOCATION URL="create_status.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		PM_Status
		SET 		PM_Status_Description 	=	'#Form.PM_Status_Description#',
					PM_Status_Definition	=	'#Form.PM_Status_Definition#',
					PM_Status_Deleted		=	#Form.PM_Status_Deleted#,
					PM_Updated_UserId  		=   '#request.AccessStructure.User_Id#',
					PM_LastUpdated   		=   getdate()
		WHERE		PM_Status_ID			=	'#Form.PM_Status_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_status.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

