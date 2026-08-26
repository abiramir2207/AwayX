	<cfparam name="FORM.Doc_ID" default="">		
	<!--- Attach the documents to "program qualifications". --->	
	<cfif FORM.Doc_ID neq "">
		<CFLOOP LIST="#FORM.Doc_ID#" INDEX="doc">
			<CFQUERY NAME = "insert_selection" DATASOURCE = "#Application.Datasource#">
				INSERT INTO Contract_Attachments(Doc_Id,Program_ID) VALUES ('#doc#',#Form.Program_Qualification_ID#)
			</CFQUERY>
		</CFLOOP>
	</cfif>