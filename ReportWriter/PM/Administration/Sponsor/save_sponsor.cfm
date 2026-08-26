
<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
		DELETE FROM PM_Sponsor  
		WHERE		PM_Sponsor_ID			=	'#Form.PM_Sponsor_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_Sponsor.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
<CFIF trim(Form.PM_Sponsor_Name_Last) EQ "" OR trim(Form.PM_Sponsor_Name_Last) EQ 0 OR trim(Form.PM_Sponsor_Name_First) EQ "" OR trim(Form.PM_Sponsor_Name_First) EQ 0 >
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>

<CFIF Form.PM_Sponsor_ID EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		PM_Sponsor
						(
							PM_Sponsor_Name_Last,
							PM_Sponsor_Name_First,
							PM_Sponsor_Email,
							PM_Sponsor_Phone,
							PM_Sponsor_Title,
							PM_Sponsor_Deleted,
							PM_Updated_UserId
						)
		Values			(
							'#Form.PM_Sponsor_Name_Last#',
							'#Form.PM_Sponsor_Name_First#',
							'#Form.PM_Sponsor_Email#',
							'#Form.PM_Sponsor_Phone#',
							'#Form.PM_Sponsor_Title#',
							 #Form.PM_Sponsor_Deleted#,
							'#request.AccessStructure.User_Id#'
						)
	</CFQUERY>
	<CFLOCATION URL="create_Sponsor.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		PM_Sponsor
		SET 		PM_Sponsor_Name_Last 	=	'#Form.PM_Sponsor_Name_Last#',
					PM_Sponsor_Name_First 	=	'#Form.PM_Sponsor_Name_First#',
					PM_Sponsor_Email 		=	'#Form.PM_Sponsor_Email#',
					PM_Sponsor_Phone	 	=	'#Form.PM_Sponsor_Phone#',
					PM_Sponsor_Title	 	=	'#Form.PM_Sponsor_Title#',
					PM_Sponsor_Deleted	 	=	 #Form.PM_Sponsor_Deleted#,
					PM_Updated_UserId  		=   '#request.AccessStructure.User_Id#',
					PM_LastUpdated   		=   getdate()

		WHERE		PM_Sponsor_ID			=	'#Form.PM_Sponsor_ID#'
	</CFQUERY>
	<CFLOCATION URL="create_Sponsor.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

