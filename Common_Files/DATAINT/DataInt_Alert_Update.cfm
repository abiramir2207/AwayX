<cfparam name="message" default="">

<cfif isdefined("Intra_id")>

<cfloop list="#form.intra_Id#" index="intra">
	<cfset useLakebaseForQGetEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
	<cfif useLakebaseForQGetEmail>
		<cftry>
			<cfset qGetEmail = application.oLakebase.toQuery(
				application.oLakebase.selectRows("data_integration_contacts", {
					"intra_id" = "eq.#intra#",
					"or" = "(email.eq.#form.upd_email#,email.eq.#form.email#)",
					"select" = "email,active"
				})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForQGetEmail = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForQGetEmail>
		<cfquery name="qGetEmail" datasource="#application.datasource#">
						Select email, Active
						From Data_Integration_Contacts
						Where intra_Id = #intra#
							and (email = '#form.upd_email#' or email = '#form.email#')
		</cfquery>
	</cfif>
	<!--- Delete record --->
	<CFIF FORM.DeleteRecord EQ 1>
		<cfif qGetEmail.recordcount gt 0>
			<cfset useLakebaseForDeletealertData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
			<cfif useLakebaseForDeletealertData>
				<cftry>
					<cfset application.oLakebase.deleteRows("data_integration_contacts",
						{ "intra_id" = "eq.#intra#", "email" = "eq.#form.email#" }
					)>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForDeletealertData = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForDeletealertData>
				<cfset useLakebaseFordeletealert_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
<cfif useLakebaseFordeletealert_Data>
	<cftry>
		<cfset application.oLakebase.deleteRows("data_integration_contacts", {
			"intra_id" = "eq.#intra#",
			"email" = "eq.#form.email#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordeletealert_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletealert_Data>
<CFQUERY NAME="deletealert_Data" datasource="#application.datasource#">
					DELETE From Data_Integration_Contacts
					Where intra_Id = #intra#
					and email = '#form.email#'
				</CFQUERY>
</cfif>
			</cfif>
			<cfset message = message&"Record deleted: "&intra&" "&form.email&"<br>">
		<cfelse>
			<cfset message = message&"No record to Delete: "&intra&"<br>">
		</cfif>
	<CFELSE>
	
		
			
		
		<cfif qGetEmail.recordcount gt 0><!--- update --->
				<cfset useLakebaseForSaveDataUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
				<cfif useLakebaseForSaveDataUpdate>
					<cftry>
						<cfset application.oLakebase.updateRows("data_integration_contacts",
							{ "or" = "(email.eq.#form.upd_email#,email.eq.#form.email#)", "intra_id" = "eq.#intra#" },
							{ "email" = form.email, "active" = (form.active EQ "1") }
						)>
						<cfcatch type="any">
							<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
							<cfset useLakebaseForSaveDataUpdate = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForSaveDataUpdate>
					<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
					  update Data_Integration_Contacts
					    set email = '#form.email#',
						active = #form.active#
						where (email = '#form.upd_email#' or email = '#form.email#')
						and intra_Id = #intra#
					</cfquery>
				</cfif>
				<cfset message =message&"Record Updated: "&intra&" "&form.email&"<br>">
		<cfelse><!--- insert --->
				<cfset useLakebaseForSaveDataInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("data_integration_contacts")>
				<cfif useLakebaseForSaveDataInsert>
					<cftry>
						<cfset application.oLakebase.insertRow("data_integration_contacts", {
							"email" = form.email,
							"intra_id" = intra,
							"active" = (form.active EQ "1")
						})>
						<cfcatch type="any">
							<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
							<cfset useLakebaseForSaveDataInsert = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForSaveDataInsert>
					<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
						insert into Data_Integration_Contacts
						(email, intra_id, active)
						values
						('#form.email#','#intra#', #form.active#)
					</cfquery>
				</cfif>
				<cfset message = message&"Record Inserted: "&intra&" "&form.email&"<br>">
		</cfif>
	</CFIF>
</cfloop>

		<CFLOCATION URL="dataInt_Alert.cfm?message=#message#&em=#form.email#" ADDTOKEN="No">
		<CFABORT>
<cfelse><!--- No id --->
	<CFLOCATION URL="dataInt_Alert.cfm" ADDTOKEN="No">
</cfif>
