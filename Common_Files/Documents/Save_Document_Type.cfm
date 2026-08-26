

<!--- Delete record --->
<CFIF FORM.DeleteRecord EQ 1>
	<cfset useLakebaseForDeleteData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_type")>
	<cfif useLakebaseForDeleteData>
		<cftry>
			<cfset application.oLakebase.deleteRows("document_type", { "doc_type_id" = "eq.#Form.Doc_Type_ID#" })>
			<cfcatch type="any">
				<cfset useLakebaseForDeleteData = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDeleteData>
		<CFQUERY NAME="delete_Data" datasource="#application.datasource#">
			DELETE FROM Document_type
			WHERE		Doc_Type_ID	=	'#Form.Doc_Type_ID#'
		</CFQUERY>
	</cfif>
	<CFLOCATION URL="create_Document_Type.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Item save data logic --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Check for the presence of data --->
<CFIF trim(Form.Doc_Type) EQ "" OR trim(Form.Doc_Type) EQ 0>
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 0000);</SCRIPT> 
	<CFABORT>
</CFIF>
<CFIF Form.Doc_Type_ID EQ "">
<!--- Insert the record --->
	<cfset useLakebaseForSaveDataInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_type")>
	<cfif useLakebaseForSaveDataInsert>
		<cftry>
			<cfset application.oLakebase.insertRow("document_type", {
				"doc_type" = Form.Doc_Type,
				"deleted" = (Form.deleted EQ 1)
			})>
			<cfcatch type="any">
				<cfset useLakebaseForSaveDataInsert = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSaveDataInsert>
		<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
			INSERT INTO		Document_type
							(Doc_Type,Deleted)
			Values			('#Form.Doc_Type#','#Form.deleted#')
		</CFQUERY>
	</cfif>
	<CFLOCATION URL="create_Document_Type.cfm" ADDTOKEN="No">
	<CFABORT>
<CFELSE>
<!--- Update the record --->
	<cfset useLakebaseForSaveDataUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("document_type")>
	<cfif useLakebaseForSaveDataUpdate>
		<cftry>
			<cfset application.oLakebase.updateRows("document_type",
				{ "doc_type_id" = "eq.#Form.Doc_Type_ID#" },
				{ "doc_type" = Form.Doc_Type, "deleted" = (Form.Deleted EQ 1) }
			)>
			<cfcatch type="any">
				<cfset useLakebaseForSaveDataUpdate = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSaveDataUpdate>
		<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
			UPDATE 		Document_Type
			SET 		Doc_Type	=	'#Form.Doc_Type#',
						Deleted		=	#Form.Deleted#
			WHERE		Doc_Type_ID	=	'#Form.Doc_Type_ID#'
		</CFQUERY>
	</cfif>
	<CFLOCATION URL="create_Document_Type.cfm" ADDTOKEN="No">
	<CFABORT>
</CFIF>
