

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="Delete_Data" datasource="#application.datasource#">
		DELETE FROM PM_priority  
		WHERE		PM_priority_ID			=	'#Form.PM_priority_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_priority.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
<CFIF trim(Form.PM_priority_Description) EQ "" OR trim(Form.PM_priority_Description) EQ 0>
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>

<CFIF Form.PM_priority_ID EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		PM_priority
						(PM_priority_Description,PM_Priority_Definition,PM_priority_Deleted,PM_Updated_UserId,PM_IsCritical)
		Values			('#Form.PM_priority_Description#','#Form.PM_priority_Definition#',#Form.PM_priority_Deleted#, '#request.AccessStructure.User_Id#', <CFIF isdefined("FORM.PM_IsCritical")>1<CFELSE>0</CFIF>)
	</CFQUERY>
	<CFLOCATION URL="create_priority.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		PM_priority
		SET 		PM_priority_Description 	=	'#Form.PM_priority_Description#',
					PM_Priority_Definition		=	'#Form.PM_priority_Definition#',
					PM_priority_Deleted		=	#Form.PM_priority_Deleted#,
					PM_Updated_UserId  		=   '#request.AccessStructure.User_Id#',
					PM_LastUpdated   		=   getdate(),
					PM_IsCritical			=	<CFIF isdefined("FORM.PM_IsCritical")>1<CFELSE>0</CFIF> 
		WHERE		PM_priority_ID			=	'#Form.PM_priority_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_priority.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

