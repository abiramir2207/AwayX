<!---
Name: 			bb_menu_stats.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	N/A
Created By:		N/A
Description:	This file is responsible for gathering certain billback data.  
--->
<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>

<cfparam name="local_bbid" default="0">

<CFSET indexSettings.bb_status_id 					= 0>
<CFSET indexSettings.bb_is_locked					= 0>
<CFSET indexSettings.bb_UP							= 0>
<CFSET indexSettings.bb_PNF							= 0>
<CFSET indexSettings.bb_adjustment_created			= 0>
<CFSET indexSettings.bb_approved_amount				= 0>
<CFSET indexSettings.bb_complete_basic_info 		= "false">
<CFSET indexSettings.bb_complete_payee 				= "false">
<CFSET indexSettings.bb_complete_programs 			= "false">
<CFSET indexSettings.bb_complete_deviations 		= "false">
<CFSET indexSettings.bb_complete_wip        		= "false">
<CFSET indexSettings.bb_complete_payment 			= "false">
<CFSET indexSettings.bb_complete_document 			= "false">
<CFSET indexSettings.bb_complete_deduction 			= "false">
<CFSET indexSettings.bb_complete_split 				= "false">
<cfset indexSettings.locked_by_other_user 			= 0>
<cfset indexSettings.bb_is_split_parent 			= 0>
<cfset indexSettings.bb_complete_gl_code_alloc 		= 0>
<cfset indexSettings.bb_agreed_to 					= 0>
<cfset indexSettings.modifyagreerelatedlinks_enable = 1>
<cfset indexSettings.modify_agree_enable			= 0>
<cfset indexSettings.cra_or_above					= 0>
<cfset indexSettings.bb_in_ded_interface			= 0>
<cfset indexSettings.bb_in_pmt_interface			= 0>
<cfset indexSettings.RFArelatedlinks_enable = appSettings.get_Setting('Billback_Disable_Pages_RFA') ><!---77242--->

<!---  only use cache when it is a billback detail  --->
<cfset variables.cachedWithin = (cgi.script_name contains "billback_detail.cfm" ? CreateTimeSpan(0, 1, 0, 0) : CreateTimeSpan(0, 0, 0, 0))>

<cfif local_bbid NEQ 0 and len(trim(local_bbid)) NEQ 0>
	<cfquery name="getBBStats" datasource="#application.datasource#">
		SELECT     dbo.Billback.Billback_Status_ID, 
				   dbo.Billback.BB_UP, 
				   dbo.Billback.BB_PNF, 
				   dbo.Billback_Allied.BB_Is_Locked, 
				   dbo.Billback_Allied.BB_Locked_By_User_ID, 
				   dbo.Billback.Billback_ID, 
				   dbo.Billback.Billback_Payee_Type_ID, 
				   dbo.Billback.BB_Is_Child,
				   dbo.Billback.BB_UP, 
				   dbo.Billback.BB_PNF, 
				   dbo.Billback_Allied.BB_Is_Locked, 
				   dbo.Billback_Allied.BB_Locked_By_User_ID, 
				   dbo.Billback.Billback_ID, 
				   dbo.Billback.Billback_Payee_Type_ID, 
				   dbo.Billback.Uploaded_Billback,
				   cast(dbo.Billback.BB_Amount as Decimal(18,2)) as BB_Amount,
				   dbo.Billback.BB_Is_Child,
				   isnull(dbo.Billback.Scheduled_Auto_BB, 0) as Scheduled_Auto_BB,
				   dbo.Billback.Negative_billback,
				   dbo.Billback.BB_modify_agree, dbo.Billback.BB_Modify_Agree_User,
				   Billback.DD_Closure_Sent_On,
				   Billback.BB_Payment_Request_Sent,
				   Billback.Deviation_Ran_Date
		FROM         dbo.Billback INNER JOIN
		                      dbo.Billback_Allied ON dbo.Billback.Billback_ID = dbo.Billback_Allied.Billback_id
		WHERE     (dbo.Billback.Billback_ID = '#local_bbid#')	
	</cfquery>

	<CFSET indexSettings.bb_status_id 					= getBBStats.Billback_Status_ID>
	<CFSET indexSettings.bb_is_locked					= getBBStats.BB_Is_Locked>
	<CFSET indexSettings.bb_UP							= getBBStats.BB_UP>
	<CFSET indexSettings.bb_PNF							= getBBStats.BB_PNF>
	<CFSET indexSettings.bb_complete_basic_info 		= "true">

	<CFIF (getBBStats.BB_Locked_By_User_ID NEQ request.AccessStructure.user_id) AND indexSettings.bb_is_locked EQ 1>
		<cfset indexSettings.locked_by_other_user = 1>
	<cfelse>
		<cfset indexSettings.locked_by_other_user = 0>
	</CFIF>
	
	<cfif getBBStats.DD_Closure_Sent_On neq "">
		<cfset indexSettings.bb_in_ded_interface = 1>
	</cfif>
	<cfif getBBStats.BB_Payment_Request_Sent eq 1>
		<cfset indexSettings.bb_in_pmt_interface = 1>
	</cfif>
	
	<cfquery name="getBBApprovedStats" datasource="#application.datasource#">
		SELECT     Adjustment_Created, Approved_Amount
		FROM         dbo.BB_Approved
		WHERE     (Billback_ID = '#local_bbid#')
	</cfquery>

	<cfif getBBApprovedStats.recordcount GT 0>
		<CFSET indexSettings.bb_adjustment_created	= getBBApprovedStats.Adjustment_Created>
		<CFSET indexSettings.bb_approved_amount		= getBBApprovedStats.Approved_Amount>
	</cfif>

	<cfif len(trim(getBBStats.Billback_Payee_Type_ID)) GT 0 AND trim(getBBStats.Billback_Payee_Type_ID) NEQ 0>
		<CFSET indexSettings.bb_complete_payee 				= "true">
	</cfif>

	<cfset BB_Total_Amount = getBBStats.BB_Amount>
	<CFIF len(trim(BB_Total_Amount)) EQ 0>
		<cfset BB_Total_Amount = 0>
	</CFIF>
	
	<!---TSF: Label 9469 - Added call to getBillbackItemizedAmount() in BillbackManager--->
	<cfset variables.itemized_total = CreateObject("component", "components.billback.BillbackManager").getBillbackItemizedAmount(local_bbid) />
	
<!--- 	|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		If Scheduled_Auto_BB, then let then the itemized total does not need to equal the BB_total.	|||||||||||||||
		BB_Total is the calculated amount...Itemized total represents their overide total 			|||||||||||||||
		|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--->
	<cfif getBBStats.Scheduled_Auto_BB eq 1>
		<cfif (getBBStats.BB_Is_Child EQ 1 OR ((trim(itemized_total) NEQ "" AND trim(itemized_total) NEQ "0")))>
			<CFSET indexSettings.bb_complete_programs 			= "true">
		</cfif>
	<cfelse>
		<cfset bAllowZeroClaimed = 0 />
		<cfif getBBStats.Uploaded_Billback EQ 3> <!--- If 3rd party billback ---->
			<cfquery cachedWithin="#variables.cachedWithin#" dataSource="#application.datasource#" NAME="getUseGPO">
				SELECT	dbo.udf_UseGPO('#local_bbid#', #getBBStats.Uploaded_Billback#) as UseGPO
			</CFQUERY>
			<cfif Val(getUseGPO.UseGPO) EQ 1>
				<cfset bAllowZeroClaimed = 1 />
			</cfif>
		</cfif>
		<cfif (getBBStats.BB_Is_Child EQ 1 OR ((trim(itemized_total) EQ trim(BB_Total_Amount)) AND (trim(itemized_total) NEQ "" AND (bAllowZeroClaimed EQ 1 OR trim(itemized_total) NEQ "0"))))>
			<CFSET indexSettings.bb_complete_programs 			= "true">
		</cfif>
	</cfif>
	
	<cfif getBBStats.Billback_Status_ID GTE 3>
		<CFSET indexSettings.bb_complete_wip 		= "true">
	</cfif>
	
	<cfif getBBStats.Billback_Status_ID GTE 3>
		<CFSET indexSettings.bb_complete_deviations 		= "true">
	</cfif>
	<cfif getBBStats.Billback_Status_ID GTE 5>
		<CFSET indexSettings.bb_complete_payment 			= "true">
	</cfif>
	
	<CFQUERY NAME="Check_Document_Complete" DATASOURCE="#application.datasource#">
		SELECT	Count(*) AS Document_Count
		FROM	Contract_Attachments
		WHERE
				Contract_Attachments.Billback_ID = '#local_bbid#'
				AND 
				Contract_Attachments.Deleted = 0
	</CFQUERY>
	<CFIF Check_Document_Complete.RecordCount GT 0>
		<CFIF Check_Document_Complete.Document_Count GT 0>
			<CFSET indexSettings.bb_complete_document 			= "true">
		</CFIF>
	</CFIF>
	<!------ Get the stored deduction id ----->
	<cfset useLakebaseForgetAssociatedDeductionID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForgetAssociatedDeductionID>
	<cftry>
		<cfset getAssociatedDeductionID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"dd_closure_id" = "eq.#local_bbid#",
				"dd_closure_type" = "eq.1",
				"select" = "deduction_id"
			}), "deduction_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAssociatedDeductionID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAssociatedDeductionID>
<cfquery name="getAssociatedDeductionID" datasource="#application.datasource#">
		SELECT	Deductions.Deduction_ID
		FROM	Deductions
		WHERE	DD_Closure_ID = '#local_bbid#'
		AND		DD_Closure_Type = 1
	</cfquery>
</cfif>
	<CFIF getAssociatedDeductionID.RecordCount GT 0>
		<CFSET indexSettings.bb_complete_deduction 			= "true">		
	</CFIF>

	<cfset useLakebaseForIsSplitParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForIsSplitParent>
	<cftry>
		<cfset IsSplitParent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"bb_parent_id" = "eq.#local_bbid#",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsSplitParent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsSplitParent>
<CFQUERY NAME="IsSplitParent" DATASOURCE="#Application.Datasource#">
		SELECT 	Top 1 Billback_ID
		FROM 	Billback 
		WHERE 	BB_parent_ID = '#local_bbid#' 
		AND 	Deleted = 0
	</CFQUERY>
</cfif>

	<CFIF getBBStats.Billback_Status_ID GTE 3 AND (getBBStats.BB_Is_Child EQ 1 OR IsSplitParent.Recordcount GT 0)>
		<CFSET indexSettings.bb_complete_split = "true">
	</CFIF>

	<cfset indexSettings.bb_is_split_parent = IsSplitParent.recordCount />	
	<cfset useLakebaseForBB_Check_GL_Code_Alloc = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_allocation")>
<cfif useLakebaseForBB_Check_GL_Code_Alloc>
	<cftry>
		<cfset BB_Check_GL_Code_Alloc = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_allocation", {
				"billback_id" = "eq.#local_bbid#",
				"deleted" = "eq.0",
				"allocation_saved" = "eq.1",
				"limit" = "1",
				"select" = "billback_id"
			}), "billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBB_Check_GL_Code_Alloc = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBB_Check_GL_Code_Alloc>
<cfquery name="BB_Check_GL_Code_Alloc" datasource="#Application.Datasource#">
		SELECT 	Top 1 Billback_ID
		FROM 	Gl_Code_Allocation 
		WHERE 	Billback_ID = '#local_bbid#'
		AND 	GL_Code_Allocation.Deleted = 0 
		AND 	Allocation_Saved = 1	
	</cfquery>
</cfif>
	<cfset indexSettings.bb_complete_gl_code_alloc = BB_Check_GL_Code_Alloc.recordCount />
	
	<!--- check agreed info --->
	<cfquery name="getBB_AgreedInfo" datasource="#Application.Datasource#">
		SELECT 	count(*) as BB_AgreedCount
		FROM 	BB_Agreed_Info 
		WHERE 	Billback_ID = '#local_bbid#' 
		AND Deleted = 0	
	</cfquery>
	<cfif getBB_AgreedInfo.BB_AgreedCount GT 0><!--- billback has been agreed to --->
		<cfset indexSettings.bb_agreed_to = 1 />		
		<cfif appsettings.getBillbackModifyAgree() EQ 1 and indexSettings.bb_status_id eq 2>
			<!---
			Logic for basic info, payee, program link - start
			here are the different scenarios, now that we know that the billback has already been agreed to, and the app settings is on and teh billback is in rfa
			- billback is not in modify agree mode (no one has clicked modify agree yet) 
				modify agree related links (basic info, payee, program pages) - disabled
			- billback is in modify agree mode and i am the user who have it modifying
				modify agree related links (basic info, payee, program pages) - enabled
			- billback is in modify agree mode and i am not the user who have it modifying
				modify agree related links (basic info, payee, program pages) - disabled
			--->
			<cfset indexSettings.modifyagreerelatedlinks_enable = 0>
			<cfif getBBStats.BB_modify_agree EQ 1 AND getBBStats.BB_Modify_Agree_User eq request.AccessStructure.user_id>
				<cfset indexSettings.modifyagreerelatedlinks_enable = 1>
			</cfif>
			<!---- Logic for basic info, payee, program link - end --->
			
			<!---- Logic to find if the current user is above the cra position / authority sequence - start --->
			<cfset indexSettings.cra_or_above = 0>
			<cfquery name="getCRA" datasource="#Application.Datasource#">
				SELECT 	TOP 1 Service_Market_ID, Service_Region_ID, Service_Zone_ID, Authority_Sequence_Order
				FROM 	BillbackApprovablePositions 
				WHERE 	Billback_ID = '#local_bbid#' 
				ORDER BY Service_Market_ID DESC, Service_Region_ID DESC, Service_Zone_ID DESC, Authority_Sequence_Order DESC
			</cfquery>
			<cfquery name="qGetUserTopmostPosition" datasource="#application.datasource#">
				SELECT	TOP 1 Service_Zone_ID, Service_Region_ID, Service_Market_ID
				FROM	User_Position_Holders			
				INNER JOIN User_Positions
				ON 		User_Positions.User_Positions_ID	= User_Position_Holders.User_Positions_ID
				AND 	User_Positions.Deleted = 0
				WHERE	User_ID = '#request.AccessStructure.user_id#'
				AND	 	User_Position_Holders.Deleted = 0
				AND	 	User_Position_Holders.User_Positions_ID <> 0
				ORDER BY Service_Zone_ID, Service_Region_ID, Service_Market_ID
			</cfquery>
			<cfquery name="qGetUserAuthoritySequence" datasource="#application.datasource#">
				SELECT	Authority_Sequence.Authority_Sequence_Order
				FROM	_Users
				INNER JOIN Authority_Sequence
				ON		Authority_Sequence.Authority_Sequence_ID = _Users.Authority_Sequence_ID
				WHERE	_Users.User_ID = '#request.AccessStructure.user_id#'
			</cfquery>
			
			<cfif getCRA.Service_Market_ID NEQ ""><!--- cra is market level --->
				<cfif 		(qGetUserTopmostPosition.Service_Market_ID EQ "" OR qGetUserTopmostPosition.Service_Market_ID EQ getCRA.Service_Market_ID)
						AND (qGetUserTopmostPosition.Service_Region_ID EQ "" OR qGetUserTopmostPosition.Service_Region_ID EQ getCRA.Service_Region_ID)
						AND (qGetUserTopmostPosition.Service_Zone_ID EQ "" OR qGetUserTopmostPosition.Service_Zone_ID EQ getCRA.Service_Zone_ID)
						><!--- and i am same market level or above --->
						<cfset indexSettings.cra_or_above = 1>
				</cfif>
			<cfelseif getCRA.Service_Region_ID NEQ ""><!--- cra is region level --->
				<cfif 		(qGetUserTopmostPosition.Service_Market_ID EQ "")
						AND	(qGetUserTopmostPosition.Service_Region_ID EQ "" OR qGetUserTopmostPosition.Service_Region_ID EQ getCRA.Service_Region_ID)
						AND (qGetUserTopmostPosition.Service_Zone_ID EQ "" OR qGetUserTopmostPosition.Service_Zone_ID EQ getCRA.Service_Zone_ID)
						><!--- and i am same region level or above --->
						<cfset indexSettings.cra_or_above = 1>
				</cfif>
			<cfelseif getCRA.Service_Zone_ID NEQ ""><!--- cra is zone level --->
				<cfif 		(qGetUserTopmostPosition.Service_Market_ID EQ "")
						AND	(qGetUserTopmostPosition.Service_Region_ID EQ "")
						AND	(qGetUserTopmostPosition.Service_Zone_ID EQ "" OR qGetUserTopmostPosition.Service_Zone_ID EQ getCRA.Service_Zone_ID)
						><!--- and i am same zone level or above --->
						<cfset indexSettings.cra_or_above = 1>
				</cfif>
			<cfelse><!--- cra is hq --->
				<cfif 		(qGetUserTopmostPosition.Service_Zone_ID EQ "")
						><!--- and i am hq --->
					<cfif qGetUserAuthoritySequence.Authority_Sequence_Order lte getCRA.Authority_Sequence_Order><!--- and my authority sequence is above the cra authority sequnece (my auth seq order < cra auth seq order) --->
						<cfset indexSettings.cra_or_above = 1>
					</cfif>
				</cfif>
			</cfif>
			<!---- Logic to find if the current user is above the cra position / authority sequence - end --->
			
			<!---
			Logic for Modify Agree Link - start
			here are the different scenarios, now that we know that the billback has already been agreed to, and the app settings is on and teh billback is in rfa
			- billback is not in modify agree mode (no one has clicked modify agree yet) 
				modify agree link - enabled only if my position / authority sequnece is CRA or high
				D13118: Billbacks - Modify Agree: Lock down the modify agree link for everyone that is below the current CRA
			- billback is in modify agree mode
				modify agree link - disabled
			--->			
			
			<cfset indexSettings.modify_agree_enable = 0>
			<cfif getBBStats.BB_modify_agree EQ 0>
				<cfset indexSettings.modify_agree_enable = indexSettings.cra_or_above>
			</cfif>
			<!--- Logic for Modify Agree Link - end --->
			
		</cfif>
	</cfif>
	
	<!--- If deviation got reset, update the variable in the main page --->
	<cfif getBBStats.Deviation_Ran_Date EQ "">
		<cfset indexSettings.bb_force_deviation = 0 />
		<cfset indexSettings.bb_source_bbflexOrAgGridscorecard = 0 />
	</cfif>
</cfif>



<cfinclude template="/get_access_profile.cfm">


<CFSET indexSettings.current_user_create_bb			= Get_Profile_Settings.bb_create>
<CFSET indexSettings.current_user_id 				= request.AccessStructure.user_id>
<CFSET indexSettings.current_user_approve 			= Get_Profile_Settings.bb_approve>
<CFSET indexSettings.current_user_approve_critical 	= Get_Profile_Settings.bb_approve_critical>
<CFSET indexSettings.current_user_approve_amount 	= Get_Profile_Settings.bb_approve_amount>
<CFSET indexSettings.current_user_view_deviations 	= Get_Profile_Settings.BB_VIEW_DEVIATION>
<CFSET indexSettings.BB_Negative					= 0>
<cfif local_bbid NEQ 0 and len(trim(local_bbid)) NEQ 0>
	<CFIF getBBStats.Negative_billback EQ 1>
		<CFSET indexSettings.current_user_view_deviations = 0>
		<CFSET indexSettings.BB_Negative = 1>
	</CFIF>
</cfif>
<CFSET indexSettings.bb_id							= local_bbid>



<cfoutput>
<script>
	<cfloop index="x" list="#structkeylist(indexSettings)#">
		<cfset value = #trim(lcase(evaluate("indexSettings.#x#")))#>
		<CFIF (value EQ "false" OR value EQ "true") AND NOT isnumeric(value)>
			window.parent.#lcase(x)# = #value#;
		<cfelse>
			window.parent.#lcase(x)# = '#value#';
		</CFIF>		
	</CFLOOP>
		
	 var url = '<cfoutput>#cgi.script_name#</cfoutput>';
		if (url == '/Billbacks/common/bb_printer_friendly.cfm' || url == '/billbacks/common/bb_printer_friendly.cfm')
        {
          // do nothing
        }
		else {
		window.parent.buildMenu();
		}
</script>
</cfoutput>
