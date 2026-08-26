

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<CFQUERY NAME="Delete_Data" datasource="#application.datasource#">
		DELETE FROM Template_Notes  
		WHERE		Template_Note_ID			=	'#Form.Template_Note_ID#'
	</CFQUERY>
	<CFLOCATION URL="List_And_Create.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
<CFIF trim(Form.Template_Note_Desc) EQ "" OR trim(Form.Template_Note_Desc) EQ 0>
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>

<CFIF Form.Template_Note_ID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSave_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_notes")>
<cfif useLakebaseForSave_Data>
	<cftry>
		<cfset application.oLakebase.insertRow("template_notes", {
			"template_note_desc" = "#Form.Template_Note_Desc#",
			"created_by" = "#request.AccessStructure.User_Id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForSave_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSave_Data>
<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		INSERT INTO		Template_Notes
						(Template_Note_Desc,Created_By)
		Values			('#Form.Template_Note_Desc#','#request.AccessStructure.User_Id#')
	</CFQUERY>
</cfif>	
<CFELSE>
<!--- Update the record --->
	<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
		UPDATE 		Template_Notes
		SET 		Template_Note_Desc 	=	'#Form.Template_Note_Desc#',
					Updated_By  		=   '#request.AccessStructure.User_Id#',
					Updated_Date   		=   getdate()
		WHERE		Template_Note_ID			=	'#Form.Template_Note_ID#'
	</CFQUERY>	
</CFIF>
<CFLOCATION URL="List_And_Create.cfm" ADDTOKEN="No">
<CFABORT>
