<!---
<cfdump var="#Form#">
<CFABORT>
--->

<CFPARAM NAME="Form.DeleteRecord" Default="0">
<CFPARAM NAME="FORM.DESCRIPTION" Default="X">

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="Delete_Data" datasource="#application.datasource#">
		DELETE FROM report_access_levels
		WHERE		level_code		=	'#Form.Level_Code#'
	</CFQUERY>
	<CFLOCATION URL="maintain_report_access_levels_form.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
<CFIF FORM.DESCRIPTION EQ "X">
	<!--- <SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> --->
	<CFABORT>
</CFIF>


<CFIF Form.Level_Code EQ "">
<!--- Insert the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		report_access_levels
						(Description,Status,Updated_UserID,LastUpdated)
		Values			('#Form.Description#','#Form.Status#','#request.AccessStructure.User_ID#',getdate())
	</CFQUERY>
	<CFLOCATION URL="maintain_report_access_levels_form.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		report_access_levels
		SET 		description = '#form.description#',
					status		=	'#Form.Status#',
					Updated_UserID 	=	'#request.AccessStructure.User_ID#',
					LastUpdated = getDate()
		WHERE		level_code			=	'#Form.Level_Code#'
	</CFQUERY>
	<CFLOCATION URL="maintain_report_access_levels_form.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

