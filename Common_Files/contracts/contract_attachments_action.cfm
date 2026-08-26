<cfparam name ="Form.FlexAppName" default="">
<cfparam name ="Form.EvaluationNotes" default="">
<cfparam name ="Form.Current_Selection_List" default="">

	<!--- This is the code which gets executed when the user attaches document to a program from inside a program. --->
	<cfif Form.FlexAppName eq "">
		<cfset useLakebaseForUpdateDel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
		<cfif useLakebaseForUpdateDel>
			<cftry>
				<cfset application.oLakebase.updateRows("contract_attachments",
					{ "program_id" = "eq.#FORM.Contract_Main_ID#" },
					{ "deleted" = true }
				)>
				<cfcatch type="any">
					<cfset useLakebaseForUpdateDel = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateDel>
			<cfset useLakebaseForupdate_del = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForupdate_del>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_attachments",
			{
				"program_id" = "eq.#FORM.Contract_Main_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdate_del = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdate_del>
<CFQUERY NAME="update_del" DATASOURCE="#Application.Datasource#">
				UPDATE Contract_Attachments SET deleted = 1 WHERE program_ID = '#FORM.Contract_Main_ID#'
			</CFQUERY>
</cfif>
		</cfif>

		<CFLOOP LIST="#Current_Selection_List#" INDEX="loop">
		<!--- add code to retain notes that were deleted in the statement above --->
		<cfparam name ="form.#replace(loop, "-", "_", "ALL")#" default="">
		<cfif not ListFindNoCase(form.Current_Selection_List, loop)>
			<cfset thisNote = "#Form.EvaluationNotes#" />
		<cfelse>
			<cfset thisNote = Evaluate("form.#replace(loop, "-", "_", "ALL")#") />
		</cfif>
		<CFOUTPUT>
			<cfset useLakebaseForInsertSelection = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
			<cfif useLakebaseForInsertSelection>
				<cftry>
					<cfset application.oLakebase.insertRow("contract_attachments", { "doc_id" = loop, "program_id" = FORM.Contract_Main_ID, "notes" = thisNote, "deleted" = false })>
					<cfcatch type="any">
						<cfset useLakebaseForInsertSelection = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForInsertSelection>
				<CFQUERY NAME = "insert_selection" DATASOURCE = "#Application.Datasource#">
					INSERT INTO Contract_Attachments(Doc_Id,Program_ID, Notes) VALUES ('#loop#',#FORM.Contract_Main_ID#, '#thisNote#')
				</CFQUERY>
			</cfif>
		</CFOUTPUT>
		</CFLOOP>
		<CFIF IsDefined("FORM.DeleteDocList")>
			<CFLOOP LIST="#FORM.DeleteDocList#" INDEX="LoopDelete">
				<CFQUERY NAME="" DATASOURCE="#Application.Datasource#">
					UPDATE Contract_Attachments SET deleted = 1 WHERE program_ID = '#FORM.Contract_Main_ID#' AND Doc_Id = '#LoopDelete#'
				</CFQUERY>
			</CFLOOP>
		</CFIF>

	<!--- This is the code which gets executed when the user attaches document from the flex program search tool.. --->
	<cfelse>	
		<!--- Save the Attached Documents --->
		<CFIF isdefined("FORM.Doc_ID")>
			<!--- Loop over the documents --->
			<CFLOOP INDEX="item" LIST="#Form.Doc_ID#" DELIMITERS=",">
					<!--- If the request is to add for multiple programs, then loop through the billbacks. --->
					<CFLOOP INDEX="prg_id" LIST="#form.ProgramList#" DELIMITERS=",">
						<cfset useLakebaseForSaveAttachments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
						<cfif useLakebaseForSaveAttachments>
							<cftry>
								<cfset application.oLakebase.insertRow("contract_attachments", { "program_id" = prg_id, "doc_id" = item, "deleted" = false })>
								<cfcatch type="any">
									<cfset useLakebaseForSaveAttachments = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForSaveAttachments>
							<CFQUERY NAME="Save_Attachments" datasource="#application.datasource#">
								INSERT	INTO Contract_Attachments
								(
									Program_ID,
									Doc_ID
								)
								VALUES
								(
									'#prg_id#',
									'#item#'
								)
							</CFQUERY>
						</cfif>
					</CFLOOP>
			</CFLOOP>
		</CFIF>
	</cfif>