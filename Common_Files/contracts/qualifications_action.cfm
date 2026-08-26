	<cfparam name="FORM.Doc_ID" default="">		
	<!--- Attach the documents to "program qualifications". --->	
	<cfif FORM.Doc_ID neq "">
		<CFLOOP LIST="#FORM.Doc_ID#" INDEX="doc">
			<cfset useLakebaseForinsert_selection = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForinsert_selection>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_attachments", {
			"doc_id" = "#doc#",
			"program_id" = "#Form.Program_Qualification_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsert_selection = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsert_selection>
<CFQUERY NAME = "insert_selection" DATASOURCE = "#Application.Datasource#">
				INSERT INTO Contract_Attachments(Doc_Id,Program_ID) VALUES ('#doc#',#Form.Program_Qualification_ID#)
			</CFQUERY>
</cfif>
		</CFLOOP>
	</cfif>