<cfif isdefined("form.delete_recid")>
	<CFQUERY NAME="deleteRecords" datasource="#application.datasource#">
		DELETE
		FROM deduction_market_to_user
		WHERE deduction_market_to_user_ID IN(#form.delete_recid#)
	</CFQUERY>
</cfif>


<CFLOOP INDEX="fieldName" LIST="#FORM.FIELDNAMES#">
	<cfset localuser_id = evaluate(fieldname)>
	
	<cfif lcase(right(fieldName,4)) EQ "user">
		<cfset record_id 	= evaluate("#mid(fieldName, 1, len(fieldName)-5)#_recid")>
		<cfset marketarea	= evaluate("#mid(fieldName, 1, len(fieldName)-5)#_market")>
		<!--- not a new record --->
		<cfif record_id NEQ 0>
			<cfset useLakebaseForgetMarketRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_market_to_user")>
<cfif useLakebaseForgetMarketRecord>
	<cftry>
		<cfset getMarketRecord = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_market_to_user", {
				"deduction_market_to_user_id" = "eq.#record_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetMarketRecord = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetMarketRecord>
<cfquery name="getMarketRecord" datasource="#application.datasource#">
				SELECT *
				FROM deduction_market_to_user
				WHERE deduction_market_to_user_id = '#record_id#'
			</cfquery>
</cfif>
		
			<cfset useLakebaseForupdateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_market_to_user")>
<cfif useLakebaseForupdateInfo>
	<cftry>
		<cfset application.oLakebase.updateRows("deduction_market_to_user",
			{
				"deduction_market_to_user_id" = "eq.#record_id#"
			},
			{
				"user_id" = "#localuser_id#",
				"market_area_id" = "#marketarea#",
				"setting_last_updated" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateInfo>
<cfquery name="updateInfo" datasource="#application.datasource#">
				UPDATE deduction_market_to_user
				SET 
					User_ID = '#localuser_id#',
					Market_Area_ID = '#marketarea#',
					Setting_Last_Updated = getdate()
				WHERE deduction_market_to_user_id = '#record_id#'
			</cfquery>
</cfif>			
			
		<CFELSE>
				<cfset useLakebaseForsaveMarketAreaAssignments = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_market_to_user")>
<cfif useLakebaseForsaveMarketAreaAssignments>
	<cftry>
		<cfset application.oLakebase.insertRow("deduction_market_to_user", {
			"user_id" = "#localuser_id#",
			"market_area_id" = "#marketarea#",
			"company_main_id" = "#request.AccessStructure.Company_Main_ID#",
			"setting_last_updated" = "#now()#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveMarketAreaAssignments = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveMarketAreaAssignments>
<cfquery name="saveMarketAreaAssignments" datasource="#application.datasource#">
					INSERT INTO deduction_market_to_user
					(User_ID, Market_Area_ID, Company_Main_ID, Setting_Last_Updated)
					VALUES
					('#localuser_id#','#marketarea#','#request.AccessStructure.Company_Main_ID#', getdate())
				</cfquery>
</cfif>			
		</cfif>
	
	</cfif>
</cfloop>
					<!--- WHERE Market_Area = '#evaluate("#mid(fieldName, 1, len(fieldName)-5)#_market")#' --->

<cflocation url="deduction_market_to_user.cfm?ID=#createuuid()#">
