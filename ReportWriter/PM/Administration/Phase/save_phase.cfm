
<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM PM_Phase  
		WHERE		PM_Phase_ID			=	'#Form.PM_Phase_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_Phase.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
<CFIF trim(Form.PM_Phase_Description) EQ "" OR trim(Form.PM_Phase_Description) EQ 0>
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>

<CFIF Form.PM_Phase_ID EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		PM_Phase
						(PM_Phase_Description,PM_Phase_Definition,PM_Phase_Deleted)
		Values			('#Form.PM_Phase_Description#','#Form.PM_Phase_Definition#',#Form.PM_Phase_Deleted#)
	</CFQUERY>
	<CFLOCATION URL="create_Phase.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		PM_Phase
		SET 		PM_Phase_Description 	=	'#Form.PM_Phase_Description#',
					PM_Phase_Definition		=	'#Form.PM_Phase_Definition#',
					PM_Phase_Deleted		=	#Form.PM_Phase_Deleted#
		WHERE		PM_Phase_ID			=	'#Form.PM_Phase_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_Phase.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

