<cfparam name="form.Billback_ID" default="">
<cfparam name="form.Program_List" default="">
<cfparam name="form.Program_Notes" default="">



<CFSET is_unknown_program = 0>
<CFIF len(trim(Form.Unknown_Program_Number)) GT 0>
	<CFSET is_unknown_program = 1>
</CFIF>

<CFIF is_unknown_program EQ 0>
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
	<CFIF checkforexistingprogram.recordcount EQ 0>
		<cfquery name="insertProgram" datasource="#Application.Datasource#">
			INSERT INTO Billback_Program
			(Billback_ID,Program_ID,BB_Program_Notes)
			VALUES
			('#FORM.Billback_ID#','#Program_List#','#FORM.Program_Notes#')
		</cfquery>
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
