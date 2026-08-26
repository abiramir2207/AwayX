<cfparam name="form.Billback_ID" default="">
<cfparam name="form.Program_List" default="">
<cfparam name="form.Program_Notes" default="">



<CFSET is_unknown_program = 0>
<CFIF len(trim(Form.Unknown_Program_Number)) GT 0>
	<CFSET is_unknown_program = 1>
</CFIF>

<CFIF is_unknown_program EQ 0>
	<cfset useLakebaseForcheckforexistingprogram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForcheckforexistingprogram>
	<cftry>
		<cfset checkforexistingprogram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"deleted" = "eq.0",
				"program_id" = "eq.#form.Program_List#",
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckforexistingprogram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckforexistingprogram>
<cfquery name="checkforexistingprogram" datasource="#Application.Datasource#">
		SELECT Billback_ID
		FROM Billback_program
		WHERE
			Billback_ID = '#FORM.Billback_ID#'
			AND
			Deleted = 0
			AND
			Program_ID = '#form.Program_List#'
	</cfquery>
</cfif>
	<CFIF checkforexistingprogram.recordcount EQ 0>
		<cfset useLakebaseForinsertProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForinsertProgram>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_program", {
			"billback_id" = "#FORM.Billback_ID#",
			"program_id" = "#Program_List#",
			"bb_program_notes" = "#FORM.Program_Notes#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertProgram>
<cfquery name="insertProgram" datasource="#Application.Datasource#">
			INSERT INTO Billback_Program
			(Billback_ID,Program_ID,BB_Program_Notes)
			VALUES
			('#FORM.Billback_ID#','#Program_List#','#FORM.Program_Notes#')
		</cfquery>
</cfif>
	</CFIF>
<CFELSE>
	<cfquery name="insertProgram" datasource="#Application.Datasource#">
		INSERT INTO Billback_Program
		(Billback_ID,BB_Program_Number,BB_Program_Title,BB_Program_Notes)
		VALUES
		('#FORM.Billback_ID#', '#FORM.Unknown_Program_Number#','#FORM.Unknown_Program_Title#','#FORM.Unknown_Program_Notes#')
	</cfquery>	
</CFIF>

<CFLOCATION url="program_form.cfm?BBID=#FORM.Billback_ID#">
