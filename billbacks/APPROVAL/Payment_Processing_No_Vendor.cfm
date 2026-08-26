<!-----------------------------------------------------------------------------

FILE NAME:		Payment_Processing_No_Vendor.cfm
DESCRIPTION:		???
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	12-Jun-2013	Added Code to handle for payment when the 
			setting getBillback_Payment_Request_Without_Vendor_Selection()

------------------------------------------------------------------------------> 
	<cfquery name="GetBillbackInfo" datasource="#application.datasource#">
		SELECT 	*
		FROM Billback
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
 
 	<cfif GetBillbackInfo.Billback_Payee_Type_ID NEQ "">
		<cfquery name="selBillbackVendor" datasource="#Application.Datasource#">
			SELECT vm.Vendor_Master_ID
			FROM Vendor_Master vm
	 		<cfif GetBillbackInfo.Billback_Payee_Type_ID EQ 1>		
				INNER JOIN Billback_Distributor BD ON BD.Uploaded_Vendor_ID = vm.Vendor_ID
				INNER JOIN Billback BB ON BB.Billback_ID = BD.Billback_ID
			<cfelseif GetBillbackInfo.Billback_Payee_Type_ID  EQ 2>
				INNER JOIN Billback_Operator BO ON BO.Uploaded_Vendor_ID = vm.Vendor_ID
				INNER JOIN Billback BB ON BB.Billback_ID = BO.Billback_ID
			</cfif>
			WHERE BB.Billback_ID = '#Billback_ID#'
		</cfquery>
 		
		<cfif isDefined("selBillbackVendor") AND selBillbackVendor.RecordCount GTE 1 AND selBillbackVendor.Vendor_Master_ID NEQ "">
			<cfset useLakebaseForUpdBBApproved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_approved")>
<cfif useLakebaseForUpdBBApproved>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_approved",
			{
				"billback_id" = "eq.#Billback_ID#"
			},
			{
				"vendor_master_id" = "#selBillbackVendor.Vendor_Master_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdBBApproved = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdBBApproved>
<cfquery name="UpdBBApproved" datasource="#Application.Datasource#">
				UPDATE 	BB_Approved	 
				SET Vendor_Master_ID = '#selBillbackVendor.Vendor_Master_ID#'
				WHERE Billback_ID = '#Billback_ID#'	
			</cfquery>
</cfif>
		</cfif>
	</cfif>

	<cfset useLakebaseForUpdBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdBillback>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Billback_ID#"
			},
			{
				"billback_status_id" = "4",
				"bb_payment_request_approved" = "1",
				"bb_payment_request_approved_date" = "#now()#",
				"bb_payment_request_approved_by" = "#request.AccessStructure.User_ID#",
				"bb_payment_request_prepared" = "1",
				"bb_payment_request_prepared_by" = "#request.AccessStructure.User_ID#",
				"bb_payment_request_prepared_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdBillback>
<cfquery name="UpdBillback" datasource="#Application.Datasource#">
		UPDATE Billback
		SET         Billback_Status_ID = 4,
					BB_Payment_Request_Approved = 1,
		            BB_Payment_Request_Approved_Date = getdate(),
		            BB_Payment_Request_Approved_By = '#request.AccessStructure.User_ID#',
					BB_Payment_Request_Prepared = 1,
					BB_Payment_Request_Prepared_By =  '#request.AccessStructure.User_ID#',
					BB_Payment_Request_Prepared_Date = getdate()
		WHERE Billback_ID = '#Billback_ID#'
	</cfquery>
</cfif>
	
	<cflocation addtoken="no" url="/billbacks/capture/Billback_Summary.cfm?BBID=#Billback_ID#">