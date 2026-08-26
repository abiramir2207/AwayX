<!---
billback_select_vendor.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#
Billback_ID=#Billback_ID#
Deduction_ID=#Deduction_ID#
---->

<cfif isDefined("NextAction") AND NextAction EQ "VendorSaved">
	<cfset useLakebaseForunlockBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
	<cfif useLakebaseForunlockBB>
		<cftry>
			<cfset application.oLakebase.updateRows("billback_allied",
				{ "billback_id" = "eq.#Billback_ID#" },
				{
					"bb_is_locked" = 0,
					"bb_locked_by_user_id" = javaCast("null", ""),
					"bb_lock_date" = javaCast("null", "")
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForunlockBB = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForunlockBB>
	<cfquery name="unlockBB" datasource="#application.datasource#">
		UPDATE 	Billback_Allied
		SET 	BB_Is_Locked = 0,
				BB_Locked_By_User_ID = NULL,
				BB_Lock_Date = NULL
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="cf_sql_varchar">
	</cfquery>
	</cfif>
	<cflocation addtoken="no" url="/deductions/inc_deduction_details.cfm?Deduction_ID=#Deduction_ID#" />	
</cfif>

<!---- Check if the billback is locked by someone else 
If yes, show a message and provide a link to go back to the deduction apge
If not, lock the billback and take the user to the vendor selection page
---->
<cfset useLakebaseForGetBillbackInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForGetBillbackInfo>
	<cftry>
		<cfset GetBillbackInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_allied", {
				"select" = "bb_is_locked,bb_locked_by_user_id,bb_lock_date",
				"billback_id" = "eq.#Billback_ID#"
			}),
			"bb_is_locked,bb_locked_by_user_id,bb_lock_date"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetBillbackInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBillbackInfo>
<cfquery name="GetBillbackInfo" datasource="#application.datasource#">
	SELECT 	BB_Is_Locked, BB_Locked_By_User_ID, BB_Lock_Date
	FROM 	Billback_Allied
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="cf_sql_varchar">	
</cfquery>
</cfif>
<cfif GetBillbackInfo.BB_Is_Locked EQ 1 AND GetBillbackInfo.BB_Locked_By_User_ID NEQ request.AccessStructure.User_ID>
	<br><br>
	<center>
	Billback is locked by some one else, please try again later
	<CF_smallLink 
		title = "go back" 
		url = "/deductions/inc_deduction_details.cfm?Deduction_ID=#Deduction_ID#"							
	>
	</center>
<cfelse>
	<!--- lock the billback if it is not already locked --->
	<cfif GetBillbackInfo.BB_Is_Locked EQ 0>
		<cfset useLakebaseForlockBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
		<cfif useLakebaseForlockBB>
			<cftry>
				<cfset application.oLakebase.updateRows("billback_allied",
					{ "billback_id" = "eq.#Billback_ID#" },
					{
						"bb_is_locked" = 1,
						"bb_locked_by_user_id" = request.AccessStructure.user_id,
						"bb_lock_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss")
					}
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForlockBB = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForlockBB>
		<cfquery name="lockBB" datasource="#application.datasource#">
			UPDATE 	Billback_Allied
			SET 	BB_Is_Locked = 1,
					BB_Locked_By_User_ID = '#request.AccessStructure.user_id#',
					BB_Lock_Date = GetDate()
			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
		</cfif>
	</cfif>
	<cflocation addtoken="no" url="/GL_code/GL_Code_In_Billback/Payment_Request/VendorID_Selection.cfm?Billback_ID=#Billback_ID#&Deduction_ID=#Deduction_ID#" />	
</cfif>