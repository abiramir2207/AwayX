<!------ 
Change_Approved_Void_Status.cfm
 ----->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<cfinclude template="billback_number_generator.cfm">
<CFSET Generated_BB_Code = generator_billback_number>

<cfset useLakebaseForGetVoidDetail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetVoidDetail>
	<cftry>
		<cfset GetVoidDetail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#URL.BBID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetVoidDetail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetVoidDetail>
<CFQUERY NAME="GetVoidDetail" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback WHERE Billback_ID = '#URL.BBID#'
</CFQUERY>
</cfif>

<cfset useLakebaseForgetThisUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetThisUserPosition>
	<cftry>
		<cfset getThisUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"user_position_type" = "eq.P",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetThisUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetThisUserPosition>
<CFQUERY NAME="getThisUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.User_ID#' AND User_Position_Type = 'P' AND  DELETED = 0
</CFQUERY>
</cfif>
<CFSET This_User_Position_ID = getThisUserPosition.User_Positions_ID>

<cfparam name="FORM.resubmitBillback" 	default="0">
<CFIF 	Isnumeric(FORM.resubmitBillback) AND FORM.resubmitBillback NEQ 0 
		AND GetVoidDetail.Billback_Status_ID EQ 8 AND GetVoidDetail.BB_Void_Multiplier LT 0>
	<cfset useLakebaseForNewBBCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForNewBBCode>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#URL.BBID#"
			},
			{
				"bb_code" = "#Generated_BB_Code#-00",
				"billback_status_id" = "3",
				"previous_bb_code" = "#GetVoidDetail.BB_Code#",
				"bb_payment_request_sent" = "0",
				"new_bb_created_date" = "#now()#",
				"void_reset_user_id" = "#request.AccessStructure.User_ID#",
				"viod_reset_user_position_id" = "#This_User_Position_ID#",
				"void_count" = "#GetVoidDetail.Void_Count# + 1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForNewBBCode = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForNewBBCode>
<CFQUERY NAME="NewBBCode" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback
		SET 	BB_Code 					= '#Generated_BB_Code#-00',
				Billback_Status_ID 			= 3,
				Previous_BB_Code 			= '#GetVoidDetail.BB_Code#',
				BB_Payment_Request_Sent		= 0,
				New_BB_Created_Date			= getdate(),
				Void_Reset_User_ID 			= '#request.AccessStructure.User_ID#',
				Viod_Reset_User_Position_ID = '#This_User_Position_ID#',
				Void_Count 					= #GetVoidDetail.Void_Count# + 1
				
		WHERE 	Billback_ID 				= '#URL.BBID#'
	</CFQUERY>
</cfif>
	
	<cfset useLakebaseForDeletePrevious = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_item_allocation_cal")>
<cfif useLakebaseForDeletePrevious>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_item_allocation_cal",
			{
				"billback_id" = "eq.#URL.BBID#",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeletePrevious = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeletePrevious>
<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Item_Allocation_Cal
		SET 	Deleted = 1
		WHERE 	Billback_ID = '#URL.BBID#' AND			
				Deleted = 0
	</CFQUERY>
</cfif>
	
	<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal
		SET 	Deleted = 1
		WHERE 	Billback_ID = '#URL.BBID#' AND				
				Deleted = 0
	</CFQUERY>
	
	
	<cfset useLakebaseForDeleteAllo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_allocation")>
<cfif useLakebaseForDeleteAllo>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_allocation",
			{
				"billback_id" = "eq.#URL.BBID#",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1",
				"allocation_saved" = "0",
				"payment_requested" = "0",
				"approved" = "0",
				"approved_date" = javaCast("null",""),
				"approved_by" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteAllo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteAllo>
<CFQUERY NAME="DeleteAllo" DATASOURCE="#Application.Datasource#">
		UPDATE 	Gl_Code_Allocation
		SET 	Deleted = 1,
				Allocation_Saved = 0,
				Payment_Requested = 0,
				Approved = 0,
				Approved_Date = NULL,
				Approved_By = NULL
				
		WHERE 	Billback_ID = '#URL.BBID#' AND				
				Deleted = 0
	</CFQUERY>
</cfif>
	
	<!------ 
	FORM.resubmitBillback (1=WIP status, 2=Approved Status)
	If FORM.resubmitBillback = 1, take them to bb_reset2.cfm and pass Billback_ID as argument
	If FORM.resubmitBillback = 2, we are done, take them back to home page, 
		here javascript is required to refresh the whole frame because the bb code has changed
	----->
	<cfif FORM.resubmitBillback EQ 1>
		<cflocation addtoken="No" url="/billbacks/common/bb_reset2.cfm?Billback_ID=#URL.BBID#&resetBillback=1&fromResubmit=1" />
	<cfelse>
		<CFOUTPUT>
		<SCRIPT language="JavaScript">
			function RefeshThis()
			{			
				window.parent.location.href = '/billbacks/capture/index.cfm?bbid=#URL.BBID#'
			}
			RefeshThis()
		</SCRIPT>
		</CFOUTPUT>
	</cfif>
<CFELSE>
	<SCRIPT language="JavaScript">
		function inValidAlert()
		{
			<cfif NOT Isnumeric(FORM.resubmitBillback) OR FORM.resubmitBillback EQ 0>
			
			<cfelse>
			alert("This is not a valid APPROVED - VOID Billback.")
			</cfif>
			<CFOUTPUT>
			window.location.href = "/billbacks/capture/Billback_Summary.CFM?bbid=#URL.BBID#";
			</CFOUTPUT>
		}
		inValidAlert()
	</SCRIPT>
</CFIF>


</body>
</html>
