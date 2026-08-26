<!---
Name: 			basic_information_action.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	N/A
Created By:		N/A
Description:	This file is the action page for billback basic information.
--->

<cfparam name="Form.BB_Volume" 								default="#form.claimCases#">
<cfparam name="Form.BB_Volume_UOM" 							default="1">
<cfparam name="Form.AddTax" 								default="0">
<cfparam name="Form.TotalTaxAmount" 						default="0">
<cfparam name="Form.Tax_Code_1" 							default="0">
<cfparam name="Form.Tax_Code_1_Domestic_Amount" 			default="0">
<cfparam name="Form.Tax_Code_1_Foreign_Amount" 				default="0">
<cfparam name="Form.Tax_Code_1_Domestic_Taxable_Amount" 	default="0">
<cfparam name="Form.Tax_Code_1_Foreign_Taxable_Amount" 		default="0">
<cfparam name="Form.Tax_Code_2" 							default="0">
<cfparam name="Form.Tax_Code_2_Domestic_Amount" 			default="0">
<cfparam name="Form.Tax_Code_2_Foreign_Amount" 				default="0">
<cfparam name="Form.Tax_Code_2_Domestic_Taxable_Amount" 	default="0">
<cfparam name="Form.Tax_Code_2_Foreign_Taxable_Amount" 		default="0">
<cfparam name="Form.Tax_Code_3" 							default="0">
<cfparam name="Form.Tax_Code_3_Domestic_Amount" 			default="0">
<cfparam name="Form.Tax_Code_3_Foreign_Amount" 				default="0">
<cfparam name="Form.Tax_Code_3_Domestic_Taxable_Amount" 	default="0">
<cfparam name="Form.Tax_Code_3_Foreign_Taxable_Amount" 		default="0">
<CFPARAM NAME="Form.ClaimMechanics"							default="0">
<CFPARAM NAME="Form.BB_Amount"								default="#form.claimAmount#">
<!--- D12149 Billbacks may now have negative values without this setting --->
<!--- <CFPARAM NAME="Form.Negative_Billback"						default="0"> --->
<cfparam name="Form.referenceNum"							default="" />
<CFPARAM NAME="Form.Vendor_Only_Billback" 					default="0">

<!--- <CFIF Form.Negative_Billback EQ 1>
 <CFSET FORM.BB_Closing_Method = 2>
</CFIF>
 --->
<CFIF len(trim(FORM.Billback_ID)) EQ 0>
	<CFSET QueryType = "insert">
</CFIF>

<CFIF len(trim(FORM.Billback_ID)) GT 0>
	<CFSET QueryType = "update">
</CFIF>
<!--- D22543 - Prevent updates while deviation Run all is in progress - Grid could cause this issue as it opens in popup --->
<CFIF QueryType EQ "update">
	<CFPARAM NAME="In_Progress_Check_BBID" default="">
	<CFPARAM NAME="PageName_InProgress" default="">
	<CFPARAM NAME="Progress_Type" default="0">

	<CFSET In_Progress_Check_BBID = FORM.Billback_ID>
	<CFSET PageName_InProgress = "Basic Info">
	<CFSET Progress_Type = 1>
	<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">
</CFIF>

<!---TSF: Label 9231 - This is to handle for the billback UOM--->
<!---the default UOM is CS so if they added LB and not CS we have to programmatically change it to LB--->
<cfif len(trim(FORM.claimPounds)) and not len(trim(FORM.claimCases))>
	<cfset Form.BB_Volume_UOM = 2 />
	<cfset Form.BB_Volume = FORM.claimPounds />
</cfif>

<!--- get user position id --->
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

<CFSWITCH expression="#QueryType#">
	<cfcase value="insert">
		<CFQUERY NAME="CheckDuplicate" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Billback WHERE BB_Code Like '#FORM.BB_CODE#-00'
		</CFQUERY>
		<CFIF CheckDuplicate.RecordCount GT 0>
			<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD><B><FONT COLOR="Red" SIZE="2">Billback with payable number <CFOUTPUT>"#FORM.BB_CODE#-00"</CFOUTPUT> already exist. Please, try again.</FONT></B></TD>
				</TR>
			</TABLE>
			<SCRIPT language="JavaScript">
			function relocate()
			{
				window.parent.location.href = "/manufacturers/home.cfm";
			}
			window.setTimeout('relocate()', 2000);
			</SCRIPT>
			<CFABORT>
		</CFIF>
		<cfquery name="insert_billback" datasource="#Application.Datasource#">
			INSERT INTO Billback
			(
				BB_AMOUNT,
				BB_Volume,
				BB_Volume_UOM,
				BB_CODE,
				BB_DATE,
				BB_Received_Date,
				Postmark_Date,
				BB_END_DATE,
				BB_CREATOR_ID,
				BB_CREATOR_User_Position_ID,
				BB_CREATOR_NOTES,
				BB_REFERENCE,
				BB_START_DATE,
				BB_TITLE,
				<CFIF IsDefined("FORM.BB_Closing_Method")>
				BB_Closing_Method,
				</CFIF>
				Original_BB_Code,
				TotalTaxAmount,
				CLAIM_CASES,
				CLAIM_POUNDS,
				<!--- D12149 Billbacks may now have negative values without this setting --->
				<!--- Negative_Billback, --->
				referenceNum,
				Vendor_Only_Billback
			)
			VALUES
			(
				'#FORM.BB_AMOUNT#',
				'#Form.BB_Volume#',
				'#Form.BB_Volume_UOM#',
				'#FORM.BB_CODE#-00',
				'#FORM.BB_DATE#',
				<CFIF FORM.BB_Received_Date NEQ "">
				'#FORM.BB_Received_Date#',
				<CFELSE>
				NULL,
				</CFIF>
				<CFIF FORM.Postmark_Date NEQ "">
				'#FORM.Postmark_Date#',
				<CFELSE>
				NULL,
				</CFIF>
				'#FORM.BB_END_DATE#',
				'#request.AccessStructure.USER_ID#',
				'#getThisUserPosition.User_Positions_ID#',
				'#FORM.BB_CREATOR_NOTES#',
				'#FORM.BB_REFERENCE#',
				'#FORM.BB_START_DATE#',
				'#FORM.BB_TITLE#',
				<CFIF IsDefined("FORM.BB_Closing_Method")>
					#FORM.BB_Closing_Method#,
				</CFIF>
				'#FORM.BB_CODE#',
				#Form.TotalTaxAmount#,
				#FORM.claimCases#,
				#FORM.claimPounds#,
				<!--- D12149 Billbacks may now have negative values without this setting --->
				<!--- #FORM.Negative_Billback#, --->
				'#form.referenceNum#',
				#Form.Vendor_Only_Billback#
			)
		</cfquery>

		<CFSET Billback_ID = insert_billback.billback_id>
 
		<!--- 
			44144: BB Analyst updating to Default analyst on Basic info/Anand Rao/30-Jul-14 
			Moved the below two lines of code to here, so that it will not update the analyst during
			the update.
		--->
		<cfset billbackAssignmentManager = CreateOBject("component", "components.billback.BillbackAssignmentManager") />
		<!--- 43146 save creator as analyst if possible otherwise use default analyst --->
		<cfset billbackAssignmentManager.saveBillbackAnalyst(billbackId = Billback_ID, creatorId = request.AccessStructure.user_id)>
		
		<CFIF len(trim(Billback_ID)) GT 0>
			<cfquery name="UnlockLockedBillbacks" datasource="#Application.Datasource#">
				UPDATE
					Billback_Allied
				SET
					BB_Is_Locked 			= 0,
					BB_Locked_By_User_ID 	= '#request.AccessStructure.User_ID#',
					BB_Lock_Date 			= #createodbcdatetime(Now())#
				WHERE
					BB_Is_Locked = 1
					AND
					BB_Locked_By_User_ID 	= '#request.AccessStructure.User_ID#'
					AND
					Billback_ID <>  '#Billback_ID#'
					AND BB_Locked_By_Match_Central = 0
			</cfquery>


			<cfquery name="ToggleLockStatus" datasource="#Application.Datasource#">
				UPDATE
					Billback_Allied
				SET
					BB_Is_Locked 			= 1,
					BB_Locked_By_User_ID 	= '#request.AccessStructure.User_ID#',
					BB_Lock_Date 			= #createodbcdatetime(Now())#
				WHERE
					Billback_ID = '#Billback_ID#'
			</cfquery>

		<cfif Form.AddTax eq 1>
			<cfset useLakebaseForAddBillbacksalesTax = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
			<cfif useLakebaseForAddBillbacksalesTax>
				<cftry>
					<!--- unlike SQL Server, the Lakebase dbo.bb_tax_info.deleted column has no DEFAULT,
					      so it must be set explicitly here to avoid leaving it NULL. --->
					<cfset application.oLakebase.insertRow("bb_tax_info", {
						"billback_id" = Billback_ID,
						"tax_code_1_id" = Form.TaxCode_1,
						"tax_allowance_code_1" = Form.TaxCode_1,
						"tax_code_1_domestic_amount" = Form.TaxAmount_1,
						"tax_code_1_foreign_amount" = Form.TaxAmount_1,
						"tax_code_1_domestic_taxable_amount" = Form.TaxableAmount_1,
						"tax_code_1_foreign_taxable_amount" = Form.TaxableAmount_1,
						"tax_code_2_id" = Form.TaxCode_2,
						"tax_allowance_code_2" = Form.TaxCode_2,
						"tax_code_2_domestic_amount" = Form.TaxAmount_2,
						"tax_code_2_foreign_amount" = Form.TaxAmount_2,
						"tax_code_2_domestic_taxable_amount" = Form.TaxableAmount_2,
						"tax_code_2_foreign_taxable_amount" = Form.TaxableAmount_2,
						"tax_code_3_id" = Form.TaxCode_3,
						"tax_allowance_code_3" = Form.TaxCode_3,
						"tax_code_3_domestic_amount" = Form.TaxAmount_3,
						"tax_code_3_foreign_amount" = Form.TaxAmount_3,
						"tax_code_3_domestic_taxable_amount" = Form.TaxableAmount_3,
						"tax_code_3_foreign_taxable_amount" = Form.TaxableAmount_3,
						"created_by" = request.AccessStructure.User_ID,
						"deleted" = false
					})>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForAddBillbacksalesTax = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForAddBillbacksalesTax>
				<cfquery name="AddBillbacksalesTax" datasource="#Application.Datasource#">
					INSERT INTO BB_Tax_Info(Billback_ID, Tax_Code_1_ID, Tax_Allowance_Code_1, Tax_Code_1_Domestic_Amount, Tax_Code_1_Foreign_Amount, Tax_Code_1_Domestic_Taxable_Amount, Tax_Code_1_Foreign_Taxable_Amount
					,Tax_Code_2_ID, Tax_Allowance_Code_2, Tax_Code_2_Domestic_Amount, Tax_Code_2_Foreign_Amount, Tax_Code_2_Domestic_Taxable_Amount, Tax_Code_2_Foreign_Taxable_Amount
					,Tax_Code_3_ID, Tax_Allowance_Code_3, Tax_Code_3_Domestic_Amount, Tax_Code_3_Foreign_Amount, Tax_Code_3_Domestic_Taxable_Amount, Tax_Code_3_Foreign_Taxable_Amount, Created_By)
					VALUES('#Billback_ID#','#Form.TaxCode_1#','#Form.TaxCode_1#' , #Form.TaxAmount_1#, #Form.TaxAmount_1#, #Form.TaxableAmount_1#, #Form.TaxableAmount_1#
					, '#Form.TaxCode_2#','#Form.TaxCode_2#', #Form.TaxAmount_2#, #Form.TaxAmount_2#, #Form.TaxableAmount_2#, #Form.TaxableAmount_2#
					, '#Form.TaxCode_3#','#Form.TaxCode_3#', #Form.TaxAmount_3#, #Form.TaxAmount_3#, #Form.TaxableAmount_3#, #Form.TaxableAmount_3#
					, '#request.AccessStructure.User_ID#')
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
	</cfcase>
	<CFCASE value="update">
		<cfset useLakebaseForGetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetStatus>
	<cftry>
		<cfset GetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "billback_status_id"
			}), "billback_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStatus>
<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
			SELECT Billback_Status_ID FROM Billback WHERE Billback_ID = '#FORM.Billback_ID#'
		</CFQUERY>
</cfif>
		<CFIF GetStatus.Billback_Status_ID GTE 3>
			<!--- 17302 - Redirect to Summary --->
			<CFSET Billback_Status_ID = GetStatus.Billback_Status_ID>
			<CFSET BB_ID_TO_Redirect = FORM.Billback_ID>
			<CFINCLUDE TEMPLATE = "BB_Summary_Redirect.cfm">
			<CFABORT>
		</CFIF>
		<CFSET AllowClosingMethodUpdate = 0>
		<CFIF GetStatus.Billback_Status_ID NEQ 4 AND GetStatus.Billback_Status_ID NEQ 5 AND GetStatus.Billback_Status_ID NEQ 7>
		<CFSET AllowClosingMethodUpdate = 1>
		</CFIF>
		<cfquery name="UpdateData" datasource="#Application.Datasource#">
			UPDATE Billback
				SET
				BB_AMOUNT					= '#FORM.BB_AMOUNT#',
				BB_Volume					= '#FORM.BB_Volume#',
				BB_Volume_UOM				= '#FORM.BB_Volume_UOM#',
				BB_CODE						= '#FORM.BB_CODE#',
				BB_DATE						= '#FORM.BB_DATE#',
				BB_Received_Date			= <CFIF FORM.BB_Received_Date NEQ "">
												'#FORM.BB_Received_Date#',
											  <CFELSE>
												NULL,
											  </CFIF>
				Postmark_Date				= <CFIF FORM.Postmark_Date NEQ "">
												'#FORM.Postmark_Date#',
											  <CFELSE>
												NULL,
											  </CFIF>
				BB_END_DATE					= '#FORM.BB_END_DATE#',
				BB_CREATOR_NOTES			= '#left(FORM.BB_CREATOR_NOTES,4000)#',
				BB_REFERENCE				= '#FORM.BB_REFERENCE#',
				BB_START_DATE				= '#FORM.BB_START_DATE#',
				BB_TITLE					= '#FORM.BB_TITLE#',
				<CFIF AllowClosingMethodUpdate EQ 1>
					<CFIF ISDefined("FORM.BB_Closing_Method")>
					BB_Closing_Method			= #FORM.BB_Closing_Method#,
					<CFELSE>
					BB_Closing_Method			= 1,
				</CFIF>
				</CFIF>
				ClaimMechanics				= '#form.ClaimMechanics#',
				TotalTaxAmount				= #form.TotalTaxAmount#,
				CLAIM_CASES					= '#trim(form.claimCases)#',
				CLAIM_POUNDS				= '#trim(form.claimPounds)#',
				<!--- D12149 Billbacks may now have negative values without this setting --->
				<!--- Negative_Billback			= '#FORM.Negative_Billback#', --->
				referenceNum                = '#form.referenceNum#',
				Vendor_Only_Billback		= '#Form.Vendor_Only_Billback#',
				Deviation_Ran_Date 			= NULL,
				Auto_Deviation_On 			= NULL,
				Deviation_Ran_By 			= NULL
			WHERE Billback_ID 				= '#FORM.Billback_ID#'
		</cfquery>
		<cfif Form.AddTax eq 1>
			<cfset useLakebaseForDelBillbacksalesTaxAmt = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
			<cfif useLakebaseForDelBillbacksalesTaxAmt>
				<cftry>
					<cfset application.oLakebase.updateRows("bb_tax_info",
						{ "billback_id" = "eq.#Billback_ID#", "deleted" = "eq.false" },
						{
							"tax_code_1_id" = Form.TaxCode_1,
							"tax_allowance_code_1" = Form.TaxCode_1,
							"tax_code_1_domestic_amount" = Form.TaxAmount_1,
							"tax_code_1_foreign_amount" = Form.TaxAmount_1,
							"tax_code_1_domestic_taxable_amount" = Form.TaxableAmount_1,
							"tax_code_1_foreign_taxable_amount" = Form.TaxableAmount_1,
							"tax_code_2_id" = Form.TaxCode_2,
							"tax_allowance_code_2" = Form.TaxCode_2,
							"tax_code_2_domestic_amount" = Form.TaxAmount_2,
							"tax_code_2_foreign_amount" = Form.TaxAmount_2,
							"tax_code_2_domestic_taxable_amount" = Form.TaxableAmount_2,
							"tax_code_2_foreign_taxable_amount" = Form.TaxableAmount_2,
							"tax_code_3_id" = Form.TaxCode_3,
							"tax_allowance_code_3" = Form.TaxCode_3,
							"tax_code_3_domestic_amount" = Form.TaxAmount_3,
							"tax_code_3_foreign_amount" = Form.TaxAmount_3,
							"tax_code_3_domestic_taxable_amount" = Form.TaxableAmount_3,
							"tax_code_3_foreign_taxable_amount" = Form.TaxableAmount_3,
							"last_updated_by" = request.AccessStructure.User_ID,
							"last_updated_on" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss")
						}
					)>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForDelBillbacksalesTaxAmt = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForDelBillbacksalesTaxAmt>
			    <cfquery name="delBillbacksalesTaxAmt" datasource="#Application.Datasource#">
			    UPDATE BB_Tax_Info
			    SET Tax_Code_1_ID = '#Form.TaxCode_1#'
				, Tax_Allowance_Code_1 = '#Form.TaxCode_1#'
				, Tax_Code_1_Domestic_Amount = #Form.TaxAmount_1#
				, Tax_Code_1_Foreign_Amount = #Form.TaxAmount_1#
				, Tax_Code_1_Domestic_Taxable_Amount = #Form.TaxableAmount_1#
				, Tax_Code_1_Foreign_Taxable_Amount = #Form.TaxableAmount_1#
				, Tax_Code_2_ID = '#Form.TaxCode_2#'
				, Tax_Allowance_Code_2 = '#Form.TaxCode_2#'
				, Tax_Code_2_Domestic_Amount = #Form.TaxAmount_2#
				, Tax_Code_2_Foreign_Amount = #Form.TaxAmount_2#
				, Tax_Code_2_Domestic_Taxable_Amount = #Form.TaxableAmount_2#
				, Tax_Code_2_Foreign_Taxable_Amount = #Form.TaxableAmount_2#
				, Tax_Code_3_ID = '#Form.TaxCode_3#'
				, Tax_Allowance_Code_3 = '#Form.TaxCode_3#'
				, Tax_Code_3_Domestic_Amount = #Form.TaxAmount_3#
				, Tax_Code_3_Foreign_Amount = #Form.TaxAmount_3#
				, Tax_Code_3_Domestic_Taxable_Amount = #Form.TaxableAmount_3#
				, Tax_Code_3_Foreign_Taxable_Amount = #Form.TaxableAmount_3#
				, Last_Updated_By = '#request.AccessStructure.User_ID#'
				, Last_Updated_On = GetDate()
					WHERE Billback_ID = '#Billback_ID#'
					AND Deleted = 0
			    </cfquery>
			</cfif>
		</cfif>
	</CFCASE>
</CFSWITCH>

<!--- 
	50616 - New Duplicate BB Logic/Anand Rao/17-Jun-2015
--->
<cfif isDefined("FORM.Billback_ID") and FORM.Billback_ID NEQ "">
	<cfset Billback_ID = FORM.Billback_ID />
</cfif>
 
<cfstoredproc procedure="BB_All_Dup_Group_Refresh" datasource="#application.datasource#">
 	<cfprocparam cfsqltype="CF_SQL_BIT" dbvarname="@@Full_Refresh" value="0" />
	<cfprocparam cfsqltype="CF_SQL_VARCHAR" dbvarname="@@Billback_ID" value="#Billback_ID#" />
</cfstoredProc>
	
<CFIF QueryType EQ "update">
	<CFPARAM NAME="In_Progress_Check_BBID" default="">
	<CFPARAM NAME="PageName_InProgress" default="">
	<CFPARAM NAME="Progress_Type" default="0">

	<CFSET In_Progress_Check_BBID = FORM.Billback_ID>
	<CFSET PageName_InProgress = "Basic Info">
	<CFSET Progress_Type = 2>
	<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">
</CFIF>

<!--- load info bar --->
<CFSET InfoBar_BBID = Billback_ID>
<cfinclude template="billback_load_infobar.cfm">

<CFSET thisbbid 			= Billback_ID>
<cfset Billback_IsLocked 	= 1>
<cfset AllowLockRelocate 	= 0>
<cfinclude template="billback_locker.cfm">


<!--- simulate button click --->
<cfset local_bbid = thisbbid>
<cfinclude template="bb_menu_stats.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">
<script>

<CFIF QueryType EQ "insert">
	callfireEvent(window.parent.document,window.parent.payee_tab,'Click')
<cfelse>
	callfireEvent(window.parent.document,window.parent.summary_tab,'Click')
</CFIF>
</script>

