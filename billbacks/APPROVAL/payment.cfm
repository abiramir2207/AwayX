
<!---
  Dev Notes: Main label 19441 - Sub Label:20957 - Anand Rao [29-Oct-09]
  If the User came from the Flex BB Grid page and the BBFlexSource is
  "FlexBB" or "AgGridBB",which means the user came from the Billback Main page.
  If the BBFlexSource is BBFlexScoreCard or BBAgGridScoreCard, then the user
  came from the scorecard page, so load the Billback page in the same popup window
  with the left menu and top menu bars.
--->
<cfset variables.varFlexSource = "" />
<cfif IsDefined("url.BBID")>
	<CFSET Billback_ID=URL.BBID>
<cfelseif IsDefined("Form.BBID")>
	<CFSET Billback_ID= Form.BBID>
<cfelseif isDefined("Form.Billback_ID")>
	<cfset Billback_ID = Form.Billback_ID>
<cfelseif IsDefined("Url.Billback_ID")>
	<cfset Billback_ID = Url.Billback_ID>
<cfelse>
	The billback is not defined
	<cfabort>
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfset BillbackSummaryManager = CreateObject("component", "components.Billback.BillbackSummaryManager")>
<cfset HasDefaultProgram = BillbackSummaryManager.DummyProgram(Billback_ID)>
<cfinclude template="/get_access_profile.cfm">
	
<cfset bReasonCodeSelection = 0 />
<!--- D25219: SOW - Enable mass paying of payables START--->
<cfparam name="AgreeOrApprove" default="" >
<cfparam name="From_Quick_Pay" default="0">
<cfparam NAME="FORM.claimAmount" DEFAULT="0">
<cfparam NAME="UserCanApproveCriticalBB" DEFAULT="1"> <!--- 69542 --->

<!--- D25219: SOW - Enable mass paying of payables END--->
<cfset useLakebaseForGetUploadedBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetUploadedBB>
	<cftry>
		<cfset GetUploadedBB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "bb_title,bb_reference,bb_code,billback_status_id,uploaded_billback"
			}), "bb_title,bb_reference,bb_code,billback_status_id,uploaded_billback"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUploadedBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUploadedBB>
<cfquery name="GetUploadedBB" datasource="#application.datasource#">
	SELECT BB_Title,BB_Reference,BB_Code,Billback_Status_ID,Uploaded_Billback
	FROM Billback
	WHERE Billback_ID = '#Billback_ID#'
</cfquery>
</cfif>

<cfquery name="getProgramType" datasource="#application.datasource#">
	SELECT DISTINCT PCPO.Generic_Type, PCPO.Release_Settlement, CM.Released
	FROM 	Contract_Main CM
	INNER JOIN Billback_Program
	ON CM.Contract_Main_ID = Billback_Program.Program_ID
	INNER JOIN 		Program_Control_Panel_Options PCPO
	ON				PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
	WHERE Billback_Program.Billback_ID = '#Billback_ID#'
	AND Billback_Program.Deleted = 0
	AND PCPO.Generic_Type = 'Operator-Deviated Pricing'
</cfquery>

<cfif appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
	<cfset BBSource =  "AgGridBB">
	<cfset BBScorecard =  "BBAgGridScoreCard">
<cfelse>
	<cfset BBSource =  "flexBB">
	<cfset BBScorecard =  "BBFlexScoreCard">
</cfif>

<cfif
(
(isDefined("SESSION.BBFlexSource") AND SESSION.BBFlexSource EQ BBSource)
OR
(isDefined("SESSION.BBAgGridSource") AND SESSION.BBAgGridSource EQ BBSource)
)
AND From_Quick_Pay EQ 0><!--- D25219: SOW - Enable mass paying of payables ---> <!--- AND (GetUploadedBB.Uploaded_Billback NEQ 0)--->
  <cfset variables.varFlexSource = BBSource />
  <script>
	if(window.opener.parent.deviations_tab) {
	    // set the menu item of the parent window to have "Deviation" as selected
	    window.opener.parent.deviations_tab.className="activeMenuItem"
	    window.opener.parent.current_menu_item = "deviations";
	    window.opener.parent.buildMenu();
	  	window.opener.location.href = "/Billbacks/Approval/payment.cfm?BBID=<CFOUTPUT>#Billback_ID#&source=#BBSource#</CFOUTPUT>";
	    // Close the window after refreshing the main window location with the above url.
	  	window.close();
	}
	else {
	<!---
	Sometimes it is possible for this work flow:
	user open deviation grid from scorecard -> clicks approve button in deviation grid -> we open the billback and take user to payment page ->
	user uses the left hand side links (basic info, payee, etc.) and make changes to the billback ->
	clicks deviation and opens the deviation grid (opener gets overwritten as opener has the same name as the deviation grid - "BBDeviation") ->
	clicks approve button in deviation grid

	In this scenario currently we were getting a javascript error as the opener is not available with left handside links.
	Solution: Just relocate to index.cfm with source=#BBScorecard#
	 --->
		window.location.href = "/billbacks/capture/index.cfm?BBID=<CFOUTPUT>#Billback_ID#&source=#BBScorecard#</CFOUTPUT>";
	}
  </script>
	<cfif isDefined("SESSION.BBFlexSource")>
		<cfset StructDelete(SESSION,  "BBFlexSource" )>
	</cfif>
	<cfif isDefined("SESSION.BBAgGridSource")>
		<cfset StructDelete(SESSION,  "BBAgGridSource" )>
	</cfif>
	<cfabort>
<cfelseif
(
(isDefined("SESSION.BBFlexSource") AND SESSION.BBFlexSource EQ BBScorecard)
OR
(isDefined("SESSION.BBAgGridSource") AND SESSION.BBAgGridSource EQ BBScorecard)
)
AND From_Quick_Pay EQ 0><!--- D25219: SOW - Enable mass paying of payables --->
<!--- <cfelseif ((isDefined("SESSION.BBFlexSource") AND SESSION.BBFlexSource EQ BBScorecard) OR
          (isDefined("URL.SOURCE") AND URL.SOURCE EQ BBScorecard))> --->

  <!---
    The APPLICATION variable BBFlexSource is no more needed, so we delete it from the
    APPLICATION structure and load this popup page with the Main billback and
    taking the user to the Deviation page.
    --->
  <cfset variables.varFlexSource = BBScorecard />
  <!--- Below delete is not need for the new deviation search as we do not store BBScorecard in application or session scope. --->
	<cfif isDefined("SESSION.BBFlexSource")>
		<cfset StructDelete(SESSION,  "BBFlexSource" )>
	</cfif>
	<cfif isDefined("SESSION.BBAgGridSource")>
		<cfset StructDelete(SESSION,  "BBAgGridSource" )>
	</cfif>
  <cflocation url="/billbacks/capture/index.cfm?BBID=#Billback_ID#&source=#BBScorecard#"  addtoken="no"/>
	<cfabort>
</cfif>

<style>

	.ErrorMessage TD
	{
		color: red;
		font-weight: bold;
		border:none;
	}
	.ErrorMessage
	{
		color: red;
		font-weight: bold;
		border:none;
	}
</style>

<cfheader name="Cache-Control" value="no-store">

<cfset ShowSplit = appSettings.getSplitBillbacks() />
<cfset AutoConcileMatchCentralBB = appSettings.getAuto_Reconcile_Match_Central_BB() />
<!--- If they do fund allocation they can't split until after they allocate --->
<cfif ((application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1) OR AutoConcileMatchCentralBB EQ 1) >
	<cfset ShowSplit = 0>
</cfif>

<cfif IsDefined("url.BBID")>
	<CFSET Billback_ID=URL.BBID>
<cfelseif IsDefined("Form.BBID")>
	<CFSET Billback_ID= Form.BBID>
<cfelseif isDefined("Form.Billback_ID")>
	<cfset Billback_ID = Form.Billback_ID>
<cfelseif IsDefined("Url.Billback_ID")>
	<cfset Billback_ID = Url.Billback_ID>
<cfelse>
	The billback is not defined
	<cfabort>
</cfif>
<cfsilent>
	<cfset BillbackDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
	<cfset BillbackDeviationManager.updateLumpSumAllocation(Billback_ID, "None") /><!------ Set it to zero first ----->
	<cfset BBProgramManager = CreateObject("component", "components.Billback.Programs.BillbackProgramsManager") />

	<cfquery name="GetBillbackInfo" datasource="#application.datasource#">
		SELECT 	Billback.*, ISNULL(bcm.Closing_Method_Type, Billback.BB_Closing_Method) as Closing_Method_Type
		FROM Billback
		LEFT JOIN Billback_Closing_Methods bcm ON bcm.iBillback_Closing_Method_ID = Billback.BB_Closing_Method
		WHERE Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfset Closing_Method_Type = GetBillbackInfo.Closing_Method_Type />

	<cfif isDefined("form.ApprovedTotal")>
		<cfset form.ApprovedTotal = form.ApprovedTotal>
	<cfelse>
		<cfset form.ApprovedTotal = 0>
	</cfif>

	<cfquery name="GetPayeeInfo" datasource="#application.datasource#">
		SELECT Billback_Payee_Type_ID, Billback_Status_ID, BB_Amount, TotalTaxAmount, Scheduled_Auto_BB
		FROM Billback
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
</cfsilent>
<cfset Scheduled_Auto_BB = GetPayeeInfo.Scheduled_Auto_BB>
<cfquery name="SelBBApproved" datasource="#application.datasource#">
	SELECT Approval_Type, Approval_Updated_By, Approval_Updated_Date
	FROM BB_Approved
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<cfif ((GetPayeeInfo.Billback_Status_ID NEQ 2) AND (SelBBApproved.Approval_Type NEQ 3)) AND (From_Quick_Pay EQ 0)><!--- D25219: SOW - Enable mass paying of payables --->
	<font color="red" size="+2"><div align="Center"><strong>You can approve a billback only when it has a status of "Request for Approval".</strong></div></font>
	<cfabort>
</cfif>

<cfsilent>
<CFSET Approved_Payment_Type = 0>
<cfset claimAmount = GetBillbackInfo.BB_Amount />
<cfif IsDefined("Form.ProcessDetails")>
	<CFSET Approved_Payment_Type = 3>
	<cfquery name="Delete_Growth_User_Selection" datasource="#application.datasource#">
		UPDATE 	BB_Growth_Program_User_Selection
		SET 	Deleted = 1
		WHERE 	Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfquery name="Delete_Lump_Sum_User_Selection" datasource="#application.datasource#">
		UPDATE 	BB_Lump_Sums_User_Selection
		SET 	Deleted = 1
		WHERE 	Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<!---Reset lump sum--->
	<cfquery name="WhatIsLS" datasource="#application.datasource#">
	UPDATE BB_Lump_Sums
	SET LS_Approved_Amount = 0
	WHERE Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

<!---Process code from previous page--->
<CFOUTPUT>

<cfparam name="ItemList" default="">

	<cfloop collection = #Form# item = "FieldNames">
		 <cfset FieldName = FieldNames>

		<cfif left(FieldName, 3) IS "BB_">
			<cfset FieldName = right(FieldName, 36)>
			<cfset FieldName = replace(FieldName, "_", "-", "all")>
			<cfset FieldValue = Evaluate("Form.#FieldNames#")>

			<CFIF FieldValue IS "Item_MU_Volume">
				<CFQUERY NAME="GetNetWeight" DATASOURCE="#Application.Datasource#">
					SELECT 		ISNULL(BSA_Foodservice_Items_Master.Net_Weight, 1) Net_Weight, Billback_Product.BB_Product_UOM,
								BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
					FROM 		BB_Item_Final
					INNER JOIN 	Billback_Product ON Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID
					LEFT JOIN 	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
					WHERE 		BB_Item_Final_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				<CFSET SelectedUOM = GetNetWeight.BB_Product_UOM><!--- EVALUATE("FORM.MU_UOM_#FieldNames#") --->
				<CFIF SelectedUOM EQ 1>
					<CFSET CaseVolume = EVALUATE("FORM.MU_#FieldNames#")>
					<CFSET LBVolume = val(CaseVolume) * GetNetWeight.Net_Weight>
				<CFELSEIF SelectedUOM EQ 2>
					<CFSET LBVolume = EVALUATE("FORM.MU_#FieldNames#")>
					<CFSET CaseVolume = val(LBVolume) / GetNetWeight.Net_Weight>
				</CFIF>
			</CFIF>

		<cfquery name="UpdateItem" datasource="#application.datasource#">
			UPDATE BB_Item_Final
			<cfif FieldValue IS "Item_BB_Volume">
				SET Item_Volume_Approved_CS = Item_BB_Volume_CS,
					Item_Volume_Approved_LB = Item_BB_Volume_LB
			<cfelseif FieldValue IS "Item_E_Volume">
				SET Item_Volume_Approved_CS = Item_E_Volume_CS,
					Item_Volume_Approved_LB = Item_E_Volume_LB
			<cfelseif FieldValue IS "Item_MU_Volume">
				SET Item_Volume_Approved_CS = <cfqueryparam value="#val(CaseVolume)#" cfsqltype="CF_SQL_FLOAT">,
					Item_Volume_Approved_LB = <cfqueryparam value="#val(LBVolume)#" cfsqltype="CF_SQL_FLOAT">,
					Item_MU_Volume_CS		= <cfqueryparam value="#val(CaseVolume)#" cfsqltype="CF_SQL_FLOAT">,
					Item_MU_Volume_LB		= <cfqueryparam value="#val(LBVolume)#" cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				Set Item_Volume_Approved_LB = 0,
					Item_Volume_Approved_CS = 0
			</cfif>
			WHERE BB_Item_Final_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

			<cfset ItemList = listappend(ItemList, FieldName, ",")>

		<cfelseif left(FieldName, 3) IS "PR_">

			<cfset FieldName = right(FieldName, 36)>
			<cfset FieldName = replace(FieldName, "_", "-", "all")>
			<cfset FieldValue = Evaluate("Form.#FieldNames#")>

			<CFIF FieldValue IS "Manual_Rate">
				<CFQUERY NAME="GetNetWeight" DATASOURCE="#Application.Datasource#">
					SELECT 		ISNULL(BSA_Foodservice_Items_Master.Net_Weight, 1) Net_Weight, Billback_Product.BB_Product_UOM,
								BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
					FROM 		BB_Item_Final_Detail
					INNER JOIN 	BB_Item_Final ON BB_Item_Final.BB_Item_Final_ID = BB_Item_Final_Detail.BB_Item_Final_ID
					INNER JOIN 	Billback_Product ON Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID
					LEFT JOIN 	BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
					WHERE 		BB_Item_Final_Detail_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				<CFSET SelectedUOM = GetNetWeight.BB_Product_UOM><!--- EVALUATE("FORM.MU_UOM_#FieldNames#") --->
				<CFIF SelectedUOM EQ 1>
					<CFSET CaseRate = EVALUATE("FORM.MU_#FieldNames#")>
					<CFSET LBRate = val(CaseRate) / GetNetWeight.Net_Weight>
				<CFELSEIF SelectedUOM EQ 2>
					<CFSET LBRate = EVALUATE("FORM.MU_#FieldNames#")>
					<CFSET CaseRate = val(LBRate) * GetNetWeight.Net_Weight>
				</CFIF>
			</CFIF>

		<cfquery name="UpdateItemDetail" datasource="#application.datasource#">
			UPDATE BB_Item_Final_Detail
			<cfif FieldValue IS "Expected_Rate">
				SET Approved_Rate_CS = Expected_Rate_CS,
					Approved_Rate_LB = Expected_Rate_LB
			<cfelseif FieldValue IS "Billback_Rate">
				SET Approved_Rate_CS = Billback_Rate_CS,
					Approved_Rate_LB = Billback_Rate_LB
			<cfelseif FieldValue IS "Manual_Rate">
				SET Approved_Rate_CS = <cfqueryparam value="#val(CaseRate)#" cfsqltype="CF_SQL_FLOAT">,
					Approved_Rate_LB = <cfqueryparam value="#val(LBRate)#" cfsqltype="CF_SQL_FLOAT">,
					Manual_Rate_CS	 = <cfqueryparam value="#val(CaseRate)#" cfsqltype="CF_SQL_FLOAT">,
					Manual_Rate_LB	 = <cfqueryparam value="#val(LBRate)#" cfsqltype="CF_SQL_FLOAT">
			<cfelse>
				Set Approved_Rate_CS = 0,
					Approved_Rate_LB = 0
			</cfif>
			WHERE BB_Item_Final_Detail_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfelseif left(FieldName, 3) IS "GR_">

			<cfset FieldName = right(FieldName, 36)>
			<cfset FieldName = replace(FieldName, "_", "-", "all")>
			<cfset FieldValue = Evaluate("Form.#FieldNames#")>

		<cfif FieldValue IS "Billback_Growth">

			<cfquery name="UpdateGrowth" datasource="#application.datasource#">
				UPDATE 	BB_Growth_Program
				SET 	Approved_Amount = BB_Growth_Amount
				WHERE 	Billback_Program_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

		<cfelseif FieldValue IS "Expected_Growth">

			<cfquery name="UpdateGrowth" datasource="#application.datasource#">
				UPDATE 	BB_Growth_Program
				SET 	Approved_Amount = Expected_Amount
				WHERE 	Billback_Program_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

		<cfelseif FieldValue IS "Manual_Growth">

			<cfquery name="UpdateGrowth" datasource="#application.datasource#">
				UPDATE 	BB_Growth_Program
				SET 	Approved_Amount = #EVALUATE("FORM.MU_#FieldNames#")#,
						Manual_Growth_Amount = #EVALUATE("FORM.MU_#FieldNames#")#
				WHERE 	Billback_Program_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

		<cfelse>
			<cfquery name="UpdateGrowth" datasource="#application.datasource#">
				UPDATE 	BB_Growth_Program
				SET 	Approved_Amount = 0
				WHERE 	Billback_Program_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

		</cfif>

		<!---Lump Sum--->
		<cfelseif left(FieldName, 4) IS "TLS_">

			<cfset FieldName = right(FieldName, 36)>
			<cfset FieldName = replace(FieldName, "_", "-", "all")>
			<cfset FieldValue = Evaluate("Form.#FieldNames#")>

			<cfif FieldValue IS "BB">

				<cfquery name="UpdateLumpSum" datasource="#application.datasource#">
				UPDATE BB_Lump_Sums
				SET LS_Approved_Amount = LS_Billback_Amount
				WHERE Billback_Program_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>

				<cfset BillbackDeviationManager.updateLumpSumAllocation(Billback_ID, "BB") />

			<cfelseif FieldValue IS "E">

				<cfquery name="UpdateLumpSum" datasource="#application.datasource#">
				UPDATE BB_Lump_Sums
				SET LS_Approved_Amount = LS_Expected_Amount
				WHERE Billback_Program_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>

				<cfset BillbackDeviationManager.updateLumpSumAllocation(Billback_ID, "E") />

			<cfelseif FieldValue IS "None">

			<cfelseif FieldValue IS "M">

			<cfelse>

				<cfquery name="UpdateLumpSum" datasource="#application.datasource#">
				UPDATE BB_Lump_Sums
				SET LS_Approved_Amount = 0
				WHERE Billback_Program_ID = <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfif>

		<cfelseif (left(FieldName, 3) IS "LS_") OR (left(FieldName, 6) IS "MU_LS_")>

			<cfset FieldName = right(FieldName, 36)>
			<cfset FieldName = replace(FieldName, "_", "-", "all")>
			<cfset FieldValue = Evaluate("Form.#FieldNames#")>

			<cfquery name="GetLSID" datasource="#application.datasource#">
			SELECT Billback_Program_ID
			FROM Billback_Program_Lumpsum_Component
			WHERE Billback_Program_Lumpsum_Component_ID =  <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfset Billback_Program_ID = GetLSID.Billback_Program_ID>

			<cfquery name="WhatIsLS" datasource="#application.datasource#">
			SELECT LS_Approved_Amount
			FROM BB_Lump_Sums
			WHERE Billback_Program_ID = '#Billback_Program_ID#'
			AND Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfif len(trim(WhatIsLS.LS_Approved_Amount)) IS 0>
				<cfset LS_Approved_Amount = 0>
			<cfelse>
				<cfset LS_Approved_Amount = WhatISLS.LS_Approved_Amount>
			</cfif>

			<cfset NewLS = LS_Approved_Amount + FieldValue>

			<cfquery name="IncrementLumpSum" datasource="#application.datasource#">
			UPDATE BB_Lump_Sums
			SET LS_Approved_Amount = <cfqueryparam value="#NewLS#" cfsqltype="CF_SQL_FLOAT">
				<CFIF left(FieldNames, 6) IS "MU_LS_">
				,LS_Manual_Amount = <cfqueryparam value="#NewLS#" cfsqltype="CF_SQL_FLOAT">
				</CFIF>
			WHERE Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<CFIF left(FieldNames, 6) IS "MU_LS_">
				<CFQUERY NAME="UpdateMAmt" DATASOURCE="#Application.Datasource#">
					UPDATE 	Billback_Program_Lumpsum_Component
					SET 	Manual_Lumpsum_Amount <CFIF LEN(FieldValue) GT 0>= <cfqueryparam value="#FieldValue#" cfsqltype="CF_SQL_FLOAT"><CFELSE> IS NULL</CFIF>
					WHERE	Billback_Program_Lumpsum_Component_ID =  <cfqueryparam value="#FieldName#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
			</CFIF>

			<cfset BillbackDeviationManager.updateLumpSumAllocation(Billback_ID, "", FieldName, FieldValue) />

			<cfquery name="VerifyLS" datasource="#application.datasource#">
			SELECT LS_Approved_Amount
			FROM BB_Lump_Sums
			WHERE Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
			AND Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

		</cfif>

	</cfloop>

	<cfquery name="Insert_Growth_User_Selection" datasource="#application.datasource#">
		INSERT INTO BB_Growth_Program_User_Selection (Billback_ID, Billback_Program_ID, Approved_Amount, Manual_Growth_Amount, Created_By)
		SELECT	Billback_ID, Billback_Program_ID, Approved_Amount, Manual_Growth_Amount, '#Request.AccessStructure.User_ID#'
		FROM	BB_Growth_Program
		WHERE	Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfquery name="Insert_Lump_Sum_User_Selection" datasource="#application.datasource#">
		INSERT INTO BB_Lump_Sums_User_Selection (Billback_ID, Billback_Program_ID, LS_Approved_Amount, LS_Manual_Amount, Created_By)
		SELECT	Billback_ID, Billback_Program_ID, LS_Approved_Amount, LS_Manual_Amount, '#Request.AccessStructure.User_ID#'
		FROM	BB_Lump_Sums
		WHERE	Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

<!---Gets total Selected Amount from Database--->

<cfquery name="GetApprovedTotal" datasource="#application.datasource#">
	SELECT
			SUM(
			CASE
			WHEN Billback_Product.BB_Product_UOM = 1 THEN
				CAST(IsNull(BB_Item_Final.Item_Volume_Approved_CS, 0) * IsNull(Approved_Rate_CS, 0) As decimal(18,2))
			ELSE
				CAST(IsNull(BB_Item_Final.Item_Volume_Approved_LB, 0) * IsNull(Approved_Rate_LB, 0) As decimal(18,2))
			END
			)
			As ApprovedTotal
	FROM 	BB_Item_Final
			INNER JOIN Billback_Product
			ON
			Billback_Product.Deleted = 0
			AND
			Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID
			INNER JOIN BB_Item_Final_Detail
			ON BB_Item_Final.BB_Item_Final_id = BB_Item_Final_Detail.BB_Item_Final_id
	WHERE 	BB_Item_Final.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND BB_Item_Final.Deleted = 0
			AND BB_Item_Final_Detail.Deleted = 0
			AND BB_Item_Final_Detail.BB_Product_Type != 3
			AND BB_Item_Final_Detail.BB_Product_Type !=4
</cfquery>

<cfset ApprovedTotal = GetApprovedTotal.ApprovedTotal>

<!---Add Growth Amounts--->

  <cfquery name="GrowthApprovedTotal" datasource="#application.datasource#">
    SELECT ROUND(ISNULL(SUM(Approved_Amount), 0), 2) as ApprovedGrowth
    FROM BB_Growth_Program
    WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
  </cfquery>
  <cfset ApprovedTotal = ApprovedTotal + GrowthApprovedTotal.ApprovedGrowth>
  <!---Add Lump Sum Amounts--->
  <cfquery name="LSApprovedTotal" datasource="#application.datasource#">
    SELECT ROUND(ISNULL(SUM(LS_Approved_Amount), 0), 2) AS ApprovedLS
    FROM BB_Lump_Sums
    WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
  </cfquery>

	<cfset ApprovedTotal = ApprovedTotal + LSApprovedTotal.ApprovedLS>
	
	<cfset Approve_Amount = Get_Profile_Settings.BB_Approve_Amount>
	<cfset E_Amount_Total = Round(E_Amount_Total * 100) / 100><!------ round to 2 decimal places ----->
	<cfset ApprovedTotal = Round(ApprovedTotal * 100) / 100><!------ round to 2 decimal places ----->
	<cfset B_Approval_Difference = (ApprovedTotal - E_Amount_Total)>
  <cfset Rate_Paid_Type="A">
	<cfset Payment_Amount="#ApprovedTotal#">
	<cfset Billback_Amount_Total="#Billback_Amount_Total#">
	<cfset ApprovedTotal="#ApprovedTotal#">
</CFOUTPUT>
</body>
</html>

<cfelse>
  <!----------------------------------------------------------------------------
    START:
    D19441: BBquick view to deviations and aproval pages // Anand Rao 09/15/09
    Code for assigning form variables used below
  ----------------------------------------------------------------------------->

	<cfif (isDefined("URL.source")
	AND
	(
	((URL.source EQ "flexBB" OR URL.source EQ "BBFlexScoreCard") AND appSettings.get_Setting('BB_Deviation_Format') is 'Flex')
	OR
	((URL.source EQ "AgGridBB" OR URL.source EQ "BBAgGridScoreCard") AND appSettings.get_Setting('BB_Deviation_Format') contains 'CF')
	))>
    <cfoutput>
    <cfset variables.varFlexSource = "#URL.source#" />
    </cfoutput>
     <cfquery name="GetFormInfo" datasource="#application.datasource#">
      SELECT Billback_Payee_Type_ID, Billback_Status_ID, BB_Amount, TotalTaxAmount, Scheduled_Auto_BB, BB_Amount
      FROM Billback
      WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>
<!---     <cfquery name="GetFormInfoSelectedAmt" datasource="#application.datasource#">
      SELECT SUM(ISNULL(Final_Payment,0)) AS Final_Selected_Amount FROM BB_Item_Invoice_Level WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery> --->
 <cfquery name="GetFormInfoSelectedAmt" datasource="#application.datasource#">
      SELECT SUM(CAST(ISNULL(Final_Payment,0) As decimal(18,2))) AS Final_Selected_Amount,
       SUM(	CASE
			WHEN UOM = 1 THEN
				CAST(Allocated_Expected_CS * Expected_Rate_CS As decimal(18,2))
			ELSE
				CAST(Allocated_Expected_LB * Expected_Rate_LB  As decimal(18,2))
		END
    )    Expected_Amt
     FROM BB_Item_Invoice_Level WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
    </cfquery>

    <cfset ExpectedTotal = 0>
   <!---  <cfquery name="GrowthTotal" datasource="#application.datasource#">
      SELECT 	Round(ISNull(Sum(Expected_Amount), 0), 2) AS Expected_Amount
      FROM 	Billback_Program
      	INNER JOIN BB_Growth_Program
      	ON
      	(
      		(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
      		AND
      		(BB_Growth_Program.Deleted = 0)
      	)
      WHERE Billback_Program.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
      AND Billback_Program.Deleted = 0
      AND Exists
      ( 	SELECT Billback_Program.Billback_Program_ID
      	FROM Billback_Program
      	WHERE (BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
      	AND	(BB_Growth_Program.Deleted = 0)
      )
    </cfquery>

    <cfif GrowthTotal.Recordcount GT 0>
      <cfset ExpectedTotal = ExpectedTotal + GrowthTotal.Expected_Amount>
    </cfif>
    <cfquery name="GetLSTotals" datasource="#application.datasource#">
    SELECT 	Round(ISNull(Sum(LS_Expected_Amount), 0), 2) AS LS_Expected_Amount
    FROM BB_Lump_Sums
    WHERE BB_Lump_Sums.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
    AND BB_Lump_Sums.Deleted = 0
    AND Exists
    (
    	SELECT  Billback_Program_Lumpsum_Component.Billback_Program_Lumpsum_Component_ID
    	FROM	Billback_Program_Lumpsum_Component
    	WHERE
    	Billback_Program_Lumpsum_Component.Billback_Program_ID = BB_Lump_Sums.Billback_Program_ID
    	AND
    	Billback_Program_Lumpsum_Component.Deleted = 0
    	AND
    	(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
    	AND
    	(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
    	AND
    	(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
    	AND
    	(CAST(Billback_Program_Lumpsum_Component.Amount AS Float) > 0)
    )
    </cfquery> --->

    <!--- <cfset ExpectedTotal              = ExpectedTotal + GetLSTotals.LS_Expected_Amount> --->
    <!--- <cfset FORM.E_Amount_Total        =  ExpectedTotal /> --->
    <cfset FORM.E_Amount_Total        =  GetFormInfoSelectedAmt.Expected_Amt>
    <cfset FORM.RATE_PAID_TYPE        = "A" />
    <cfset FORM.Payment_Amount        = GetFormInfoSelectedAmt.Final_Selected_Amount />
    <cfset FORM.Billback_Amount_Total = GetFormInfo.BB_Amount />
    <cfset FORM.Scheduled_Auto_BB     = GetFormInfo.Scheduled_Auto_BB>
    <cfset FORM.Billback_ID           = URL.BBID />

  </cfif>
  <!----------------------------------------------------------------------------
    END:
    D19441: BBquick view to deviations and aproval pages // Anand Rao 09/15/09
  ----------------------------------------------------------------------------->

	<CFIF Form.Rate_Paid_Type EQ "BB">
		<CFSET Approved_Payment_Type = 1>
		<cfset BillbackDeviationManager.updateLumpSumAllocation(Billback_ID, "BB") />

		<!------ make sure the approved fields are populated so that it can be used below to calculate the amount getting approved per program ------->
		<cfquery name="UpdateItem" datasource="#application.datasource#">
			UPDATE 	BB_Item_Final
			SET 	Item_Volume_Approved_CS = Item_BB_Volume_CS,
					Item_Volume_Approved_LB = Item_BB_Volume_LB
			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfquery name="UpdateItemDetail" datasource="#application.datasource#">
			UPDATE BB_Item_Final_Detail
			SET 	Approved_Rate_CS = Billback_Rate_CS,
					Approved_Rate_LB = Billback_Rate_LB
			FROM	BB_Item_Final
			INNER JOIN BB_Item_Final_Detail
			ON		BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID
			WHERE 	BB_Item_Final.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfquery name="UpdateLumpSum" datasource="#application.datasource#">
			UPDATE BB_Lump_Sums
			SET LS_Approved_Amount = LS_Billback_Amount
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	<CFELSEIF Form.Rate_Paid_Type EQ "E">
		<CFSET Approved_Payment_Type = 2>
		<cfset BillbackDeviationManager.updateLumpSumAllocation(Billback_ID, "E") />

		<!------ make sure the approved fields are populated so that it can be used below to calculate the amount getting approved per program ------->
		<cfquery name="UpdateItem" datasource="#application.datasource#">
			UPDATE 	BB_Item_Final
			SET 	Item_Volume_Approved_CS = Item_E_Volume_CS,
					Item_Volume_Approved_LB = Item_E_Volume_LB
			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfquery name="UpdateItemDetail" datasource="#application.datasource#">
			UPDATE BB_Item_Final_Detail
			SET 	Approved_Rate_CS = Expected_Rate_CS,
					Approved_Rate_LB = Expected_Rate_LB
			FROM	BB_Item_Final
			INNER JOIN BB_Item_Final_Detail
			ON		BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID
			WHERE 	BB_Item_Final.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>

		<cfquery name="UpdateLumpSum" datasource="#application.datasource#">
			UPDATE BB_Lump_Sums
			SET LS_Approved_Amount = LS_Expected_Amount
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	</CFIF>
	<cfoutput>
	<cfset Rate_Paid_Type = Form.Rate_Paid_Type>
	<cfset Payment_Amount = Form.Payment_Amount>
	<cfset E_Amount_Total = Form.E_Amount_Total>
	<cfset Billback_Amount_Total = Form.Billback_Amount_Total>
	<cfset ApprovedTotal = Form.ApprovedTotal>
	<cfset Billback_ID = Form.Billback_ID>
	<cfset Scheduled_Auto_BB = Form.Scheduled_Auto_BB>
	</cfoutput>
</cfif>


<!---Calculates Exclusion to be created--->

<cfquery name="Exclusion" datasource="#application.datasource#">

  SELECT	SUM(<cfif Rate_Paid_Type IS "BB">Item_BB_Volume_LB<cfelseif Rate_Paid_Type IS "E">Item_E_Volume_LB<cfelseif Rate_Paid_Type IS "A">Item_Volume_Approved_LB<cfelse>0</cfif> *  IsNull(Program_Distributors_Trade_Rate.Rate, 0)) AS Total_Dollar_Amount
  FROM	Billback
  	INNER JOIN	Billback_Distributor
  	ON
  	(
  		(Billback_Distributor.Billback_ID = Billback.Billback_ID)
  		AND
  		(Billback.Billback_Payee_Type_ID = 1)
  		AND
  		(Billback_Distributor.Deleted = 0)
  	)
  	INNER JOIN	Billback_Program
  	ON
  	(
  		(Billback_Program.Billback_ID = Billback.Billback_ID)
  		AND
  		(Billback_Program.Deleted = 0)
  	)
  	INNER JOIN	Contract_Main
  	ON
  	(
  		(Contract_Main.Contract_Number = (SELECT CM.Contract_Number FROM Contract_Main CM WHERE CM.Contract_Main_ID = Billback_Program.Program_ID))
  		AND
  		(Contract_Main.Contract_Status_Type_IDX IN (4,5,6))
  	)
  	INNER JOIN	Program_Control_Panel_Options
  	ON
  	(
  		(Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID)
  		AND
  		(Program_Control_Panel_Options.Generic_Type IN ('Operator-Deviated Pricing', 'Bid Request'))
  		AND
  		(Program_Control_Panel_Options.Include_Trade = 0)
  	)
  	INNER JOIN	Billback_Product
  	ON
  	(
  		(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
  		AND
  		(Billback_Product.Deleted = 0)
  	)
  	INNER JOIN	BSA_Foodservice_Items_Master
  	ON
  	(
  		(BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID)
  		AND
  		(BSA_Foodservice_Items_Master.Deleted = 0)
  	)
  	INNER JOIN	BB_Item_Final
  	ON
  	(
  		(BB_Item_Final.Billback_ID = Billback.Billback_ID)
  		AND
  		(BB_Item_Final.Billback_Program_ID = Billback_Program.Billback_Program_ID)
  		AND
  		(BB_Item_Final.Billback_Product_ID = Billback_Product.Billback_Product_ID)
  	)
  	LEFT JOIN	Program_Distributors_Trade_Rate
  	ON
  	(
  		(Program_Distributors_Trade_Rate.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID)
  		AND
  		(Program_Distributors_Trade_Rate.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID)
  		AND
  		(Program_Distributors_Trade_Rate.Deleted = 0)
  	)
  WHERE
  	Billback.Deleted = 0
  	AND
  	Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<cfif Exclusion.Recordcount GT 0>
	<cfset ExclusionCreated = Exclusion.Total_Dollar_Amount>
<cfelse>
	<cfset ExclusionCreated = 0>
</cfif>
</cfsilent>
<html>
<head>
	<title>Billback Approval</title>
	<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
	<cfinclude template="/billbacks/capture/iframe_style.cfm">
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}

	#header
		{
			font-size: 12px;
		}

	#cellLabel
		{
			<!--- font-family:Arial; --->
			font-size: 11px;
			font-weight: bold;
			vertical-align : top;
		}

	#dataStyle
		{
			font-size: 11px;
		}

	TD
		{
			font-family:Arial;
		}
	HR
		{
			color: Navy;
		}

	.LeftRightBorder
	{
		border-left:solid #93BEE2 1px;
		border-right:solid #93BEE2 1px;
		border-top:solid #93BEE2 1px;
		font-size : 10px;
	}
	TABLE.LeftRightBorder TD
	{
		border-bottom:solid #93BEE2 1px; font-size : 10px;
	}
</style>

<SCRIPT LANGUAGE="JavaScript">
function getParentObject(thisObj, tagName)
{
 if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
 {
  return thisObj;
 }
 else if(thisObj.tagName.toLowerCase() == "body")
 {
  return null;
 }
 else
 {
  return getParentObject(thisObj.parentElement, tagName);
 }
}

function showThisLinkPopup(thisObj,NoResize)
{
 var aObj = getParentObject(thisObj, "a");
 var resize = "Yes";
 if(NoResize)
 {
  resize = "No";
 }
 if(aObj)
 {
  NewWindow(aObj.href, "Details",800, 500, "yes", resize);
 }
 return false;
}

</SCRIPT>

</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
	<p></p>

<!---If expected amount is negative set it to 0--->
<cfif E_Amount_Total LT 0>
	<cfset E_Amount_Total = 0>
</cfif>
<cfset sQueryString = ""/>
<cfset sQueryStringAppender = "" />

<cfif (isDefined("URL.source")
AND
(
((URL.source EQ "flexBB") AND appSettings.get_Setting('BB_Deviation_Format') is 'Flex')
OR
((URL.source EQ "AgGridBB") AND appSettings.get_Setting('BB_Deviation_Format') contains 'CF')
))>
	<cfif appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
		<cfset sQueryString = "?source=AgGridBB" />
		<cfset sQueryStringAppender = "&source=AgGridBB" />
	<cfelse>
		<cfset sQueryString = "?source=flexBB" />
		<cfset sQueryStringAppender = "&source=flexBB" />
	</cfif>
</cfif>

<form action="payment_confirmation.cfm#sQueryString#" method="post" name="MakePayment">  <!--- ONSUBMIT="javaScript: return checkApprovedAmount(this);" --->
<CFOUTPUT>
<INPUT TYPE="Hidden" NAME="BBSource" VALUE="#variables.varFlexSource#" />
<!---  varFlexSource:<cfdump var="#variables.varFlexSource#" />
<Cfabort>  --->

<INPUT TYPE="Hidden" NAME="claimAmount" VALUE="#claimAmount#" />
<INPUT TYPE="Hidden" NAME="Approved_Amount_Type" VALUE="#Approved_Payment_Type#"></CFOUTPUT>
<cfoutput>
<TABLE WIDTH="100%" border="0" CELLSPACING="0" CELLPADDING="2" STYLE="border-left:solid ffe4b5 1px; border-right:solid ffe4b5 1px; border-bottom:solid ffe4b5 1px;">
<tr bgcolor="ffe4b5">
	<td width="150" nowrap><strong>Selected Amount:</strong></td>
	<td width="20">:</td>
	<td align="right"><strong>#LSCurrencyFormat(Payment_Amount)#</strong></td>
	<td width="60%">&nbsp; </td>
</tr>
<cfif E_Amount_Total LT Payment_Amount and Not Scheduled_Auto_BB>
<tr bgcolor="ffe4b5">
	<td width="150" nowrap><strong>Expected Amount:</strong></td>
	<td width="20">:</td>
	<td align="right"><strong>#LSCurrencyFormat(E_Amount_Total)#</strong></td>
	<td width="60%">&nbsp; </td>
</tr>
</cfif>

<cfset Adjustment_Created = Payment_Amount - E_Amount_Total>
<cfif Adjustment_Created GT 0>
	<tr bgcolor="ffe4b5">
		<td><strong>Adjustment Created by This Billback:</strong></td>
		<td>:</td>
		<td align="right"><strong>#LSCurrencyFormat(Adjustment_Created)#</strong></td>
<input type="hidden" name="Adjustment_Created" value="#Adjustment_Created#">
		<td width="60%">&nbsp; </td>
	</tr>
<cfelse>
<input type="hidden" name="Adjustment_Created" value="0">
</cfif>
<cfif ExclusionCreated GT 0>
	<tr bgcolor="ffe4b5" style="border-bottom: solid navy 2px;">
		<td style="border-bottom: solid navy 2px;"><strong>Exclusion Created by This Billback:</strong></td>
		<td style="border-bottom: solid navy 2px;">:</td>
		<td style="border-bottom: solid navy 2px;" align="right"><A HREF="/billbacks/approval/bb_exclusion_details.cfm?Billback_ID=#Billback_ID#&Rate_Paid_Type=#Rate_Paid_Type#" onClick="javaScript: return showThisLinkPopup(this,0);"><strong>#LSCurrencyFormat(ExclusionCreated)#</strong></A></td>
<input type="hidden" name="ExclusionCreated" value="#ExclusionCreated#">
		<td style="border-bottom: solid navy 2px;" width="60%">&nbsp; </td>
	</tr>
<cfelse>
<input type="hidden" name="ExclusionCreated" value="0">
</cfif>
</cfoutput>

<!--- You only need to do the payee information and the adjustment information if the app setting for display is on --->
<cfif appsettings.getHide_Billback_Adjustments() EQ 0>
<cfset Unknown_Payee = 0>

<!---Get Payee Info--->
<cfif GetPayeeInfo.Billback_Payee_Type_ID IS 1>

	<cfquery name="GetBasicID" datasource="#application.datasource#">
	SELECT Distributor_ID FROM Billback_Distributor
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfif len(GetBasicID.Distributor_ID) LT 0 >
		<cfset Unknown_Payee = 1>
	<cfelse>

	<cfquery name="GetAdjustmentsForPayee" datasource="#application.datasource#">
	SELECT 	BB_Adjustment.BB_Adjustment_ID, BB_Adjustment.Billback_ID, BB_Adjustment.Payee_ID, BB_Adjustment.Billback_Payee_Type_ID, BB_Adjustment.Adjustment_Amount
			--, BB_Adjustment.Adjustment_Source
			, 1 As Adjustment_Source
	FROM BB_Adjustment
	WHERE 	BB_Adjustment.Hidden = 0
	AND		BB_Adjustment.Deleted = 0
	AND		BB_Adjustment.Applied = 0
	AND		BB_Adjustment.Payee_ID = <cfqueryparam value="#GetBasicID.Distributor_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		BB_Adjustment.Billback_Payee_Type_ID = 1
	</cfquery>
	</cfif>

</cfif>

<cfif GetPayeeInfo.Billback_Payee_Type_ID IS 2>
	<cfquery name="GetBasicID" datasource="#application.datasource#">
	SELECT Operator_ID FROM Billback_Operator
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfif len(GetBasicID.Operator_ID) LT 0 >
		<cfset Unknown_Payee = 1>
	<cfelse>

	<cfquery name="GetAdjustmentsForPayee" datasource="#application.datasource#">
	SELECT 	BB_Adjustment.BB_Adjustment_ID, BB_Adjustment.Billback_ID, BB_Adjustment.Payee_ID, BB_Adjustment.Billback_Payee_Type_ID, BB_Adjustment.Adjustment_Amount
			--, BB_Adjustment.Adjustment_Source
			, 1 As Adjustment_Source
	FROM BB_Adjustment
	WHERE 	BB_Adjustment.Hidden = 0
	AND		BB_Adjustment.Deleted = 0
	AND		BB_Adjustment.Applied = 0
	AND		BB_Adjustment.Payee_ID = <cfqueryparam value="#GetBasicID.Operator_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		BB_Adjustment.Billback_Payee_Type_ID = 2
	</cfquery>
	</cfif>
</cfif>

<cfif GetPayeeInfo.Billback_Payee_Type_ID IS 3>
	<cfquery name="GetBasicID" datasource="#application.datasource#">
	SELECT Broker_ID FROM Billback_Broker
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<cfif len(GetBasicID.Broker_ID) LT 0 >
		<cfset Unknown_Payee = 1>
	<cfelse>

	<cfquery name="GetAdjustmentsForPayee" datasource="#application.datasource#">
	SELECT 	BB_Adjustment.BB_Adjustment_ID, BB_Adjustment.Billback_ID, BB_Adjustment.Payee_ID, BB_Adjustment.Billback_Payee_Type_ID, BB_Adjustment.Adjustment_Amount
			--, BB_Adjustment.Adjustment_Source
			, 1 As Adjustment_Source
	FROM BB_Adjustment
	WHERE 	BB_Adjustment.Hidden = 0
	AND		BB_Adjustment.Deleted = 0
	AND		BB_Adjustment.Applied = 0
	AND		BB_Adjustment.Payee_ID = <cfqueryparam value="#GetBasicID.Broker_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND		BB_Adjustment.Billback_Payee_Type_ID = 1
	</cfquery>
	</cfif>
	<!---Get Broker--->
</cfif>


<!---Is a know payee type (not an unknown)--->
<cfif (GetPayeeInfo.Billback_Payee_Type_ID IS 1 OR GetPayeeInfo.Billback_Payee_Type_ID IS 2 OR GetPayeeInfo.Billback_Payee_Type_ID IS 3)>
 <cfoutput>
 <cfif GetAdjustmentsForPayee.Recordcount GT 0>
 	<tr>
		<td colspan="4">&nbsp;<br></td>
	</tr>
	<tr bgcolor="##D0CB6C">
		<td colspan="4">&nbsp;<br><strong>Adjustments:</strong></td>
	</tr>

	<tr>
		<td colspan="4">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<cfif Unknown_Payee IS 0>
		<cfloop query="GetAdjustmentsForPayee">

		<cfif GetAdjustmentsForPayee.Adjustment_Source IS 2>
			<cfquery name="DeductionData" datasource="#application.datasource#">
			SELECT * From Deductions WHERE Deduction_ID = <cfqueryparam value="#GetAdjustmentsForPayee.Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfset AdjustmentDetails.BB_Title = "Adjustment created from deduction">
			<cfset AdjustmentDetails.BB_Date = DeductionData.DD_Date_Closed>
			<cfset AdjustmentDetails.BB_Reference = "Deduction">
			<cfset AdjustmentDetails.BB_Code = DeductionData.DD_DedID>
		<cfelse>
			<cfquery name="AdjustmentDetails" datasource="#application.datasource#">
			SELECT Billback.BB_Title, Billback.BB_Date, Billback.BB_Reference, Billback.BB_Code
			FROM Billback
			WHERE Billback_ID = <cfqueryparam value="#GetAdjustmentsForPayee.Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>

		<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> >
		<td style="border-bottom:solid ##93BEE2 1px;">&nbsp; &nbsp; </td>
		<Td style="border-bottom:solid ##93BEE2 1px;"><strong>#AdjustmentDetails.BB_Code#</strong> #AdjustmentDetails.BB_Title# (#AdjustmentDetails.BB_Reference#) - #DateFormat(AdjustmentDetails.BB_Date, 'MMMM DD, YYYY')#</TD>
	<td style="border-bottom:solid ##93BEE2 1px;" align="right"><strong>#LSCurrencyFormat(GetAdjustmentsForPayee.Adjustment_Amount)#</strong>&nbsp; &nbsp; </td>
<td align="right" style="border-bottom:solid ##93BEE2 1px;">Ignore</td>
	<td align="left" style="border-bottom:solid ##93BEE2 1px;">
	<input type="Radio" subtractAmount="1" onClick="javaScript:adjust_Payment_Amount(this);" name="AD_#Replace(GetAdjustmentsForPayee.BB_Adjustment_ID, "-","_", "all")#" value="None" checked> </td>
	<td align="right" style="border-bottom:solid ##93BEE2 1px;">Apply</td>
	<td align="left" style="border-bottom:solid ##93BEE2 1px;">
	<input type="Radio" subtractAmount="0" onClick="javaScript:adjust_Payment_Amount(this);" name="AD_#Replace(GetAdjustmentsForPayee.BB_Adjustment_ID, "-","_", "all")#" value="#GetAdjustmentsForPayee.Adjustment_Amount#"></td>
	<td align="right" style="border-bottom:solid ##93BEE2 1px;">Remove</td>
	<td align="left" style="border-bottom:solid ##93BEE2 1px;">
	<input type="Radio" subtractAmount="0" onClick="javaScript:adjust_Payment_Amount(this);" name="AD_#Replace(GetAdjustmentsForPayee.BB_Adjustment_ID, "-","_", "all")#" value="Hide"> </td>
		</tr>
		</cfloop>
		</table>
		<cfelse>
		The payee is not associated with the application
		</cfif>
		</td>
		</tr>


	</cfif>
</cfoutput>


  <CFQUERY NAME="Should_Show_Exclusion" DATASOURCE="#application.datasource#">
  	SELECT	COUNT(*) AS Trade_Program_Count
  	FROM	Billback
  			INNER JOIN Billback_Program
  			ON
  			Billback.Billback_ID = Billback_Program.Billback_ID
  			AND
  			Billback_Program.Deleted = 0
  			INNER JOIN Contract_Main
  			ON
  			Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
  			INNER JOIN	Program_Control_Panel_Options
  			ON
  			Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
  			AND
  			Program_Control_Panel_Options.Generic_Type = 'Distributor Trade/Shelter'
  	WHERE
  			Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
  </CFQUERY>

	<!---Is a distributor--->
	<!---Billback_Payee_Type_ID = 1 Is a distributor--->
	<cfif GetPayeeInfo.Billback_Payee_Type_ID IS 1 AND Should_Show_Exclusion.Trade_Program_Count GT 0>

		<tr>
		<td colspan="4">&nbsp;<br></td>
		</tr>
		<tr bgcolor="#D0CB6C">
		<td colspan="4">&nbsp;<br><strong>Exclusions:</strong></td>
		</tr>
		<tr>
		<td colspan="4" style="border-bottom: solid navy 2px;">
		<table width="100%" cellpadding="0" cellspacing="0" border="0">
		<cfif Unknown_Payee IS 0>

<!----------- Exclusions are to be taken away from trade payments ---------->
<cfquery name="SelectProgramID" datasource="#application.datasource#">
	SELECT DISTINCT Contract_Main.Contract_Number, Program_Control_Panel_Options.Generic_Type
	FROM 			BB_Program_Exclusion
	INNER JOIN 		Contract_Main
	ON 				Contract_Main.Contract_Main_ID = BB_Program_Exclusion.Program_ID
	INNER JOIN 		Program_Control_Panel_Options
	ON				Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE 			BB_Program_Exclusion.Distributor_ID = <cfqueryparam value="#GetBasicID.Distributor_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND 			BB_Program_Exclusion.Deleted = 0
	AND 			BB_Program_Exclusion.Hidden = 0
	Order By 		Program_Control_Panel_Options.Generic_Type
</cfquery>

<CFSET Current_Generic_Type = "" />
<table width="100%" cellpadding="2" cellspacing="0" border="0">
<cfloop query="SelectProgramID">

	<CFIF Current_Generic_Type NEQ Generic_Type>
	<CFSET Current_Generic_Type = Generic_Type />
	<tr>
	<td colspan="100%" style="border-bottom:1px solid navy;"><strong><cfoutput>#Current_Generic_Type# programs</cfoutput></strong></td>
	</tr>
	</CFIF>

	<cfquery name="GetMainExclusion" datasource="#application.datasource#">
		SELECT		Contract_Main.Contract_Title, Contract_Main.Contract_Number, Billback.BB_Title, Billback.BB_Code, Billback.BB_Reference,  BB_Program_Exclusion.BB_Program_Exclusion_ID,
					(
					SELECT 		SUM(ISNUll(Dollar_Amount, 0 ))
					FROM 		BB_Product_Exclusion
					INNER JOIN 	BB_Program_Exclusion Exclusion
					ON 		Exclusion.Program_ID =
												(
												SELECT CM.Contract_Main_ID
												FROM Contract_Main CM
												WHERE CM.Contract_Main_ID = Exclusion.Program_ID
												AND CM.Contract_Number = Contract_Main.Contract_Number
												)
					AND 	Exclusion.Deleted = 0
					AND 	Exclusion.Hidden = 0
					AND 	Exclusion.BB_Program_exclusion_ID = BB_Product_Exclusion.BB_Program_Exclusion_ID
					WHERE 	BB_Product_Exclusion.Deleted = 0
					GROUP BY Exclusion.Deleted
					) AS TotalDollarPerProgram

		FROM 		BB_Program_Exclusion

		INNER JOIN 	Contract_Main
		ON 			Contract_Main.Contract_Number = <cfqueryparam value="#SelectProgramID.Contract_Number#" cfsqltype="CF_SQL_VARCHAR">

		INNER JOIN 	Billback
		ON 			Billback.Billback_ID = BB_Program_Exclusion.Billback_ID

		WHERE 		BB_Program_Exclusion.Distributor_ID = '#GetBasicID.Distributor_ID#'
		AND 		BB_Program_Exclusion.Program_ID = Contract_Main.Contract_Main_ID
		AND 		BB_Program_Exclusion.Hidden = 0
		AND 		BB_Program_Exclusion.Applied = 0
	</cfquery>

	<cfoutput query="GetMainExclusion" group="Contract_Title">
	<tr>

	<td colspan="3"><strong>#Contract_Number#</strong> #Contract_Title#</td>
	<td align="right"><strong>#LSCurrencyFormat(TotalDollarPerProgram)#</strong> &nbsp; </td>
	<td align="right">Ignore</td>
	<td align="left"><input type="radio" onClick="javaScript: applyToNextLevel(this, 0);" name="PR_#Replace(GetMainExclusion.Contract_Number, "-","_", "all")#" value="None" checked></td>
	<td align="right">Apply</td>
	<td align="left"><input type="radio" onClick="javaScript: applyToNextLevel(this, 1);" name="PR_#Replace(GetMainExclusion.Contract_Number, "-","_", "all")#" value="#TotalDollarPerProgram#"></td>
	<td align="right">Remove</td>
	<td align="left"><input type="radio" onClick="javaScript: applyToNextLevel(this, 1);" name="PR_#Replace(GetMainExclusion.Contract_Number, "-","_", "all")#" value="HIDE"></td>
	</tr>

		<cfoutput>

		<cfquery name="GetDollarAmount" datasource="#application.datasource#">
		SELECT Sum(IsNull(BB_Product_Exclusion.Dollar_Amount, 0)) AS TotalDollars
		FROM BB_Product_Exclusion
		WHERE BB_Product_Exclusion.BB_Program_Exclusion_ID = <cfqueryparam value="#GetMainExclusion.BB_Program_Exclusion_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<tr bgcolor="DDDDDD" id="TR_PR_#Replace(GetMainExclusion.Contract_Number, "-","_", "all")#">
			<td>&nbsp; &nbsp; &nbsp; </td>
			<td><strong>#BB_Code#</strong> #BB_Title# (#BB_Reference#)</td> <td>
			<A HREF="/billbacks/approval/product_details.cfm?BB_Program_Exclusion_ID=#GetMainExclusion.BB_Program_Exclusion_ID#" onClick="javaScript: return showThisLinkPopup(this,0);">Details</A>
			</td>
			<td align="right"> <strong>#LSCurrencyFormat(GetDollarAmount.TotalDollars)#</strong>&nbsp; </td>
			<td align="right">Ignore</td>
			<td align="left"><input type="radio" subtractAmount="1" onClick="javaScript:adjust_Payment_Amount(this);" name="EX_#Replace(GetMainExclusion.BB_Program_Exclusion_ID, "-","_", "all")#" value="None" checked></td>
			<td align="right">Apply</td>
			<td align="left"><input type="radio" subtractAmount="0" onClick="javaScript:adjust_Payment_Amount(this);" name="EX_#Replace(GetMainExclusion.BB_Program_Exclusion_ID, "-","_", "all")#" value="#GetDollarAmount.TotalDollars#"></td>
			<td align="right">Remove</td>
			<td align="left"><input type="radio" subtractAmount="0" onClick="javaScript:adjust_Payment_Amount(this);" name="EX_#Replace(GetMainExclusion.BB_Program_Exclusion_ID, "-","_", "all")#" value="HIDE"></td>
		</tr>
		</cfoutput>

	</cfoutput>


	</cfloop>
</table>
		<cfelse>
		The payee is not associated with the application
		</cfif>
		</td>
	</tr>
</cfif>

<!---Is a known Payee type--->
</cfif>

<!--- Show adjustments and exclusions  -- Hide_Billback_Adjustments --->
</cfif>



<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Claim Adjustment --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFIF Approved_Payment_Type NEQ 1>
	<CFQUERY NAME="GetTotClaim" DATASOURCE="#Application.Datasource#">
		SELECT 	SUM(CAST(BB_Rate AS float)) ClaimAd_Tot
		FROM 	Billback_Product_Detail
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
				BB_Product_Type_ID = 10 AND
				(Billback_Product_Detail.BB_Rate IS NOT NULL)AND
				(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)AND
				Deleted = 0
	</CFQUERY>
	<CFIF GetTotClaim.ClaimAd_Tot NEQ 0>

		<CFQUERY NAME="GetProgramDetails" DATASOURCE="#Application.Datasource#">
			SELECT 		Contract_number,
						Contract_Title,
						SUM(CAST(BB_Rate AS float)) AS Tot_bb_Rate

			FROM 		Billback_Product_Detail

			INNER JOIN 	Billback_Product
				ON 	Billback_Product.Billback_ID =<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
					Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID AND
					Billback_Product.Deleted = 0
			INNER JOIN 	Billback_Program ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID AND
						Billback_Program.Deleted = 0
			INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID

			WHERE 		Billback_Product_Detail.Billback_ID =<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
						Billback_Product_Detail.BB_Product_Type_ID = 10 AND
						Billback_Product_Detail.BB_Rate IS NOT NULL AND
						(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1) AND
						Billback_Product_Detail.Deleted = 0

			GROUP BY 	Program_ID,Contract_number,Contract_Title
		</CFQUERY>
		<cfquery name="GetApprovalInfo" datasource="#application.datasource#">
			SELECT BB_Approved.Paid_Amount
			FROM BB_Approved
			WHERE BB_Approved.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<tr>
		<td colspan="4">&nbsp; <br><strong>Claim Adjustment:</strong><br><HR COLOR="Orange"></td>

		<cfloop query="GetProgramDetails">
		<cfoutput>
		<tr <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<td style="border-bottom:solid ##93BEE2 1px;">&nbsp;&nbsp;&nbsp;&nbsp;<strong>#Contract_Number# </strong>#Contract_Title# </td>
		<td style="border-bottom:solid ##93BEE2 1px;">&nbsp;</td>
		<Td style="border-bottom:solid ##93BEE2 1px;" align="right"><font color="Red"><strong>#DollarFormat(Tot_bb_Rate)#</strong></font></TD>
		<td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td>
		</tr>
		</cfoutput>
		</cfloop>
		<td><td colspan="4">&nbsp; </td></td>
	</CFIF>
</CFIF>

	<!--- pullback applied amount --->
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
<cfset GetPullbackInfo = PullbackManager.getPullbackAppliedInfo(Billback_ID) />
<cfif GetPullbackInfo.BB_pullbacks_applied EQ 1>
	<tr>
	<td><strong><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Amount</strong></td>
	<td> <strong></strong> </td>
	<Td align="right"><font color="Red"><strong><cfoutput>#DollarFormat(GetPullbackInfo.Pullback_applied_Amount)#</cfoutput></strong></font></TD>
	<td>&nbsp; </td>
	</tr>
</cfif>
</TABLE>
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- End Claim Adjustment --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- D57265 :: Billback processed against OI Template
Added an argumets to modifiy query if its coming from Payments page.
--->
<cfset CheckTemplateApprovalRights = BBProgramManager.getTemplateApprovalRights(Billback_ID,1)>

<CFQUERY NAME="GetFA_AppSetting" DATASOURCE="#Application.Datasource#">
SELECT ForbidAllowProfilesInTemplates
FROM _Application_Settings
</CFQUERY>

<CFSET TemplateApprovalRight = 0>

	<CFIF GetFA_AppSetting.ForbidAllowProfilesInTemplates EQ 1 AND CheckTemplateApprovalRights.RecordCount EQ 0>
		<CFSET TemplateApprovalRight = 1>
	<CFELSEIF GetFA_AppSetting.ForbidAllowProfilesInTemplates EQ 0 AND CheckTemplateApprovalRights.RecordCount GT 0>
			<!--- D57265 :: Billback processed against OI Template
			Added a query of a query to find out if any record has Forbid_Access_Type = "0" IF query returns records we will prevent user approving the Billback. --->
		<cfset useLakebaseForcheckForbidAccess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("checktemplateapprovalrights")>
<cfif useLakebaseForcheckForbidAccess>
	<cftry>
		<cfset checkForbidAccess = application.oLakebase.toQuery(
			application.oLakebase.selectRows("checktemplateapprovalrights", {
				"forbid_access_type" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckForbidAccess = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckForbidAccess>
<cfquery name="checkForbidAccess" dbtype="query" >
			SELECT *
			FROM CheckTemplateApprovalRights
			WHERE Forbid_Access_Type = 0
		</cfquery>
</cfif>
		<cfif checkForbidAccess.RecordCount EQ 0.>
			<CFSET TemplateApprovalRight = 1>
		</cfif>
		<!--- 97865 - LS BB Controls START --->
		<cfif TemplateApprovalRight>
			<cfset CheckTemplateBBLSApprovalRights = BBProgramManager.getTemplateBBLSApprovalRights(Billback_ID,1)>

			<cfquery name="checkForbidAccess" dbtype="query" >
				SELECT *
				FROM CheckTemplateBBLSApprovalRights
				WHERE Forbid_Access_Type = 0
			</cfquery>

			<cfif checkForbidAccess.RecordCount>
				<CFSET TemplateApprovalRight = 0>
			</cfif>
		</cfif>
		<!--- 97865 - LS BB Controls END --->
	</CFIF>
			
<cfif Get_Profile_Settings.BB_Approve EQ 0>
	<CFSET TemplateApprovalRight = 0>
</cfif>

<!---- 117446 :: Billback - sales tax code START---> 
<cfif appSettings.getBillbacksSalesTax() EQ 2>
	<CFQUERY NAME="Get_Tax_Types" datasource="#application.datasource#">
		SELECT BB_Tax_Main_ID,Tax_Allowance_Code, Description, CAST(ISNULL(BB_Tax_Info.Tax_Code_1_ID, 0) AS INT) AS Tax_Type
		FROM BB_Tax_Main
		LEFT JOIN BB_Tax_Info
		ON BB_Tax_Info.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		WHERE BB_Tax_Main.Deleted = 0
		Order by	Description
	</CFQUERY>
	<tr>
		<td colspan="3" align="left">
			<span id="error_Tax_Type"></span><strong>Tax Type:</strong>
			<select name="Billbacks_Sales_Tax">
				<option value="0">Select a Tax Type</option>
				<cfoutput  query="Get_Tax_Types">
					<option value="#BB_Tax_Main_ID#" <cfif Tax_Type EQ BB_Tax_Main_ID>SELECTED</cfif>>#Description# ( #Tax_Allowance_Code# )</option>
				</cfoutput>
			</select>
		</td>
		<td>&nbsp; </td>
		</tr>

		<cfset BBProgramManager = CreateObject("component", "components.Billback.Programs.BillbackProgramsManager") />
		<cfset CheckTemplateSalesTax = BBProgramManager.getTemplateSalesTax(Billback_ID)>
		
		<cfset bBillbackSalesTax = 0 />
		<cfset newSalesTaxType = 1>
		<cfif (CheckTemplateSalesTax.RecordCount GTE 2)>
			<cfloop query = "CheckTemplateSalesTax">
				<cfif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
					<cfset bBillbackSalesTax = 1 />
				</cfif>
			</cfloop>
		<cfelseif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
			<cfset bBillbackSalesTax = 1 />
		</cfif>
<cfelse>
	<cfset newSalesTaxType = 0>
	<cfinclude template = "BB_Sales_Tax.cfm" />
</cfif>
<!---- 117446 :: Billback - sales tax code END--->

<CFOUTPUT>
<blockquote><br>
<CFIF Approved_Payment_Type NEQ 1 AND GetTotClaim.ClaimAd_Tot NEQ 0 AND GetTotClaim.ClaimAd_Tot NEQ "" AND ISNUMERIC(GetTotClaim.ClaimAd_Tot)>
	<CFSET Payment_Amount = Payment_Amount + GetTotClaim.ClaimAd_Tot>
</CFIF>
<cfif GetPullbackInfo.BB_pullbacks_applied EQ 1>
	<CFSET variables.Payment_Amount = variables.Payment_Amount  - GetPullbackInfo.Pullback_applied_Amount>
	<cfset form.Payment_Amount = variables.Payment_Amount/>
</cfif>
<!--- <cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnVariable="ShowSalesTax"> --->
<strong>Total Amount to Pay: $<SPAN id="Total_Payment_Amount">#NumberFormat(val(Payment_Amount), "-_.__")#</SPAN>
<!--- If the setting allows for Sales tax Info --->
<cfif  newSalesTaxType EQ 0 AND bBillbackSalesTax EQ 1>
 + Sales Tax $<SPAN id="Total_Tax_Amount">#NumberFormat(val(GetPayeeInfo.TotalTaxAmount), "-_.__")#</SPAN>
= $ <SPAN id="Total_Payment_Amount_Taxes_Included">#NumberFormat(val(Payment_Amount) + val(GetPayeeInfo.TotalTaxAmount), "-_.__")#</SPAN>
</cfif>
</strong>

<input type="hidden" name="Payment_Amount" value="#Payment_Amount#">
<input type="hidden" name="E_Amount_Total" value="#E_Amount_Total#">
<input type="hidden" name="Billback_Amount_Total" value="#Billback_Amount_Total#">
<input type="hidden" name="ApprovedTotal" value="#ApprovedTotal#">
<input type="hidden" name="Billback_ID" value="#Billback_ID#">
<input type="hidden" name="Payee_Type" value="#GetPayeeInfo.Billback_Payee_Type_ID#">
<input type="hidden" name="Rate_Paid_Type" value="#Rate_Paid_Type#">
<INPUT TYPE="Hidden" NAME="INP_Total_Payment_Amount" VALUE="#variables.Payment_Amount#">
<p></p>

<CFQUERY NAME="BBNotes" DATASOURCE="#Application.Datasource#">
	SELECT BB_Creator_Notes, Payment_Notes FROM Billback WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<!--- **START DEV NOTE: DAA; D16974: --->
<cfif TemplateApprovalRight EQ 1>
	<strong>Payment Notes:</strong> <CFIF BBNotes.BB_Creator_Notes NEQ ""><B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: CopyThisNotes(); return false;">Copy Notes from Basic Info</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></CFIF><Br>
	<!--- D31502:On BBK approval page cursor in Payment Notes field not left justified		START --->
	<!--- D31841: Payment notes not saving when user agrees to program... ADDED PAYMENT_NOTES VARIBALE TO DISPLAY PAYMENT NOTES --->
	<textarea name="Payment_Notes" rows="2" cols="50" style="text-align:left;">#BBNotes.Payment_Notes#</textarea><br /><br />
	<!--- D31502:On BBK approval page cursor in Payment Notes field not left justified		END --->
	<!--- DEV NOTE: DAA; D16974 --->
	<cfif (
			(appsettings.ReasonCodeinBillbackDED AND GetBillbackInfo.BB_Closing_Method EQ 2)
			OR
			(appsettings.getShowReasonCodeOnBBApprovalScreen() AND GetBillbackInfo.BB_Closing_Method NEQ 2)
			)
			AND (appSettings.Reason_Code_in_Billback_Display_Setting EQ 1 OR (appSettings.Reason_Code_in_Billback_Display_Setting EQ 2 AND Payment_Amount LT GetPayeeInfo.BB_Amount))>
		<cfset reasonCodePerRow = 3 />
		<cfinclude template="BB_Reason_Code_Selection.cfm" />
		<cfset bReasonCodeSelection = 1 />
	</cfif>
</cfif>
<!--- **END DEV NOTE: DAA; D16974: --->

</blockquote>

</td></tr>

<CFSET Approve_Tot_Amount = Get_Profile_Settings.BB_Tot_Approve_Amount>
<CFSET Approve_Devi_Amount = Get_Profile_Settings.BB_Approve_Amount>
<CFSET Approve_Credit_Memo_Amount = Get_Profile_Settings.Credit_Memo_Amount>
<CFSET Approve_Pay_Req_Approval_Amount = Get_Profile_Settings.BB_Pay_Req_Approval_Amount>

<!------ Any case check whether there is any lump sum more than the template cap, if so stop the user, no agree / approve ----->
<CFSET Is_Lumpsum_In_Template_Range = 1>
<cfset qGetAllProgramLumpsumTotalsVSTemplateMax = BillbackDeviationManager.getAllProgramLumpsumTotalsVSTemplateMax(Billback_ID, Rate_Paid_Type) />
<cfquery name="qCheckLumpSumTemplateCapExceed" dbtype="query">
	SELECT	*
	FROM	qGetAllProgramLumpsumTotalsVSTemplateMax
	WHERE	LumpSumCap > 0
	AND		Discount_Lump_Sums_Distributor_Mandated = 1
	AND		(LS_Amount + currentAllocation - ProgramAvailBalance) > LumpSumCap
</cfquery>

<cfif qCheckLumpSumTemplateCapExceed.recordCount>
	<cfset Is_Lumpsum_In_Template_Range = 0 />
</cfif>

<CFSET Is_Total_In_Range = 0>
<CFSET Is_Devi_In_Range = 0>
<CFSET Show_Agree = 0>
<CFSET Is_BB_Within_Budget = 1>

<CFSET Devi_Amount = Payment_Amount - E_Amount_Total>

<!--- If the closing method is "Payment" --->
<CFIF Closing_Method_Type eq 1>
	<!--- If the below app setting is ON, user can approve bb based on "total approval amount" profile. --->
	<cfif appSettings.getApproveBBBasedOnProfileTotalApprovalAmount() eq 1>
	<!--- Compare the total approval Amount (profile) with the payment amount.--->
		<CFIF Approve_Tot_Amount NEQ "*">
			<CFIF Payment_Amount LTE Approve_Tot_Amount>
				<CFSET Is_Total_In_Range = 1>
			</CFIF>
		<CFELSE>
				<CFSET Is_Total_In_Range = 1>
		</CFIF>
	<!--- If the above app setting is OFF, user can approve bb based on payment request Amount" profile. --->
	<cfelse>
	<!--- Compare the payment request Amount (profile) with the payment amount.--->
		<CFIF Approve_Pay_Req_Approval_Amount NEQ "*">
			<CFIF Payment_Amount LTE Approve_Pay_Req_Approval_Amount>
				<CFSET Is_Total_In_Range = 1>
			</CFIF>
		<CFELSE>
				<CFSET Is_Total_In_Range = 1>
		</CFIF>
	</cfif>
		<!--- If the above app setting is OFF, "payment request Amount" is now the approval limit. --->
		<cfif appSettings.getApproveBBBasedOnProfileTotalApprovalAmount() eq 0>
			<cfset Approve_Tot_Amount = Approve_Pay_Req_Approval_Amount>
		</cfif>
<!--- If the closing method is not "Payment" --->
<CFELSE>
<!--- If ThirdPartyBBUpload app setting is 3 (Combo) and there is at least one program with 'Operator-Deviated Pricing' generic type
			OR 	ThirdPartyBBUpload app setting is not 3 (Combo). Compare the total approval Amount (profile) with the payment amount.
--->
	<CFIF (appSettings.getThirdPartyBBUpload() EQ 3 AND getProgramType.recordcount neq 0) OR appSettings.getThirdPartyBBUpload() NEQ 3>
		<CFIF Approve_Tot_Amount NEQ "*">
			<CFIF Payment_Amount LTE Approve_Tot_Amount>
				<CFSET Is_Total_In_Range = 1>
			</CFIF>
		<CFELSE>
				<CFSET Is_Total_In_Range = 1>
		</CFIF>
	<CFELSE>
			<!--- If ThirdPartyBBUpload app setting is 3 and there are no programs with 'Operator-Deviated Pricing' generic type--->
			<CFIF appSettings.getThirdPartyBBUpload() EQ 3 AND getProgramType.recordcount eq 0>
					<CFIF Approve_Credit_Memo_Amount NEQ "*">
						<CFIF Payment_Amount LTE Approve_Credit_Memo_Amount>
							<CFSET Is_Total_In_Range = 1>
						</CFIF>
					<CFELSE>
						<CFSET Is_Total_In_Range = 1>
					</CFIF>
			<!--- Now "Credit_Memo_Amount" is your approval limit --->
			<cfset Approve_Tot_Amount = Approve_Credit_Memo_Amount>
			</CFIF>
	</CFIF>
</CFIF>

<CFIF Approve_Devi_Amount NEQ "*">
	<CFIF Devi_Amount LTE Approve_Devi_Amount>
		<CFSET Is_Devi_In_Range = 1>
	</CFIF>
<CFELSE>
		<CFSET Is_Devi_In_Range = 1>
</CFIF>

<!--- If "Approve Billback Beyond Budget" = OFF, Check if billback will be over budget balance  after approval --->
<CFIF appSettings.getBudgetsFunctionalityOn()>
    <CFSET Is_BB_Within_Budget = 0 />
    <CFIF Get_Profile_Settings.Approve_BB_Beyond_Budget EQ 1>
        <CFSET Is_BB_Within_Budget = 1 />
    <CFELSE>
        <CFSET Is_BB_Within_Budget = CreateObject("component", "mvc.Models.AdvancedBudget.BudgetManager").isBillbackDollarWithinBudget(Billback_ID) />
    </CFIF>
</CFIF>

<CFIF Is_Lumpsum_In_Template_Range NEQ 1 OR Is_Total_In_Range NEQ 1 OR Is_Devi_In_Range NEQ 1 OR Is_BB_Within_Budget NEQ 1>
    <CFSET Show_Agree = 1 />
</CFIF>
<!--- 69542	'Approve Critical' Billback Settings Update START--->
<CFQUERY NAME="CheckBBProgram" dataSource="#application.datasource#" >
	SELECT 	Billback.BB_UP, Billback.BB_PNF, Billback_Status_ID, PCPO.Release_Settlement, CM.Released
	FROM	Billback
	INNER JOIN Billback_Program BP
	ON BP.Billback_ID = Billback.Billback_ID
	INNER JOIN Contract_Main CM
	ON CM.Contract_Main_ID = BP.Program_ID
	INNER JOIN Program_Control_Panel_Options PCPO
	ON PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
	WHERE	Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND Billback.Deleted = 0
</CFQUERY>

<cfif CheckBBProgram.BB_UP EQ 1 OR CheckBBProgram.BB_PNF EQ 1 OR(appSettings.getReleaseSettlement() AND Get_Profile_Settings.BB_Approve_Critical EQ 0 AND CheckBBProgram.Release_Settlement AND CheckBBProgram.Released)>
	<cfset Show_Agree = 1>
	<cfset UserCanApproveCriticalBB = 0>
</cfif>
<!--- 69542	'Approve Critical' Billback Settings Update END --->

<CFSET IsAgreed = 0>
<CFIF Show_Agree EQ 1>
	<CFQUERY NAME="IsRFAAgreed" DATASOURCE="#application.datasource#">
		SELECT 		*
		FROM 		User_Position_Holders
		INNER JOIN 	_Users ON _Users.User_ID = User_Position_Holders.User_ID AND _Users.Deleted = 0
		INNER JOIN 	BB_Agreed_Info ON BB_Agreed_Info.User_position_ID = User_Position_Holders.User_Positions_ID AND BB_Agreed_Info.Authority_Sequence_ID = ISNULL(_Users.Authority_Sequence_ID,0) AND BB_Agreed_Info.Deleted = 0
AND BB_Agreed_Info.user_id = User_Position_Holders.User_ID
		WHERE 		User_Position_Holders.User_ID = <cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="CF_SQL_VARCHAR">
					AND User_Position_Holders.Deleted = 0
					AND BB_Agreed_Info.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	<CFIF IsRFAAgreed.RecordCount GT 0>
		<CFSET IsAgreed = 1>
	</CFIF>
</CFIF>

<!--- D25219: SOW - Enable mass paying of payables START --->
<CFIF Is_BB_Within_Budget NEQ 1>

<!--- 98106 :: Auto Deviations to consider if bb is beyond program budget START--->
<cfset useLakebaseForqGetToleranceSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_tolerance_settings")>
<cfif useLakebaseForqGetToleranceSettings>
	<cftry>
		<cfset qGetToleranceSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_tolerance_settings", {
				"select" = "autoprocess_check_bb_beyond_budget"
			}), "autoprocess_check_bb_beyond_budget"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetToleranceSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetToleranceSettings>
<CFQUERY NAME="qGetToleranceSettings" DATASOURCE="#Application.Datasource#">
	SELECT AutoProcess_Check_BB_Beyond_Budget
	FROM	Billback_Tolerance_Settings
</CFQUERY>
</cfif>
<cfif qGetToleranceSettings.AutoProcess_Check_BB_Beyond_Budget>
	<CFQUERY NAME="qUpdateBBConsiderations" DATASOURCE="#Application.Datasource#">
		UPDATE Billback
		SET BB_In_RFA_Due_To_Budget = 1
		WHERE Billback_ID = '#Billback_ID#'

		INSERT INTO BB_Business_Consideration(Billback_ID,Action,Notes,Created_By)
		Values('#Billback_ID#','RFA','Billback cannot be approved as approval amount exceeds the budget balance.','#request.AccessStructure.user_id#')
	</CFQUERY>
</cfif>
<!--- 98106 :: Auto Deviations to consider if bb is beyond program budget END--->

	<cfset BBTotalNotInRangeAgreeReason = "The billback approval amount exceeds the budget balance">
</CFIF>
<CFIF Is_Total_In_Range NEQ 1>
	<cfset BBTotalNotInRangeAgreeReason = "The billback approval amount exceeds the approval level">
</CFIF>
<CFIF Is_Devi_In_Range NEQ 1>
	<cfset BBDeviationNotInRangeAgreeReason = "The billback deviation amount exceeds the approval level">
</CFIF>
<!--- D25219: SOW - Enable mass paying of payables END --->
<CFIF Show_Agree EQ 1>
	<CFIF IsAgreed EQ 1>
		<cfif From_Quick_Pay EQ 0><!--- D25219: SOW - Enable mass paying of payables --->
		<CFQUERY NAME="GetAgreedUsers" DATASOURCE="#Application.Datasource#">
			SELECT 		distinct Created_Date, Agreed_Amount,Name_First,Name_Last
			FROM 		BB_Agreed_Info
			INNER JOIN 	_Users ON _Users.User_ID = BB_Agreed_Info.User_ID
			WHERE 		Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND BB_Agreed_Info.Deleted = 0
			ORDER BY 	BB_Agreed_Info.Created_Date DESC
		</CFQUERY>
		<TR>
		<TD COLSPAN="100%">
			<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0">
				<TR>
					<TD COLSPAN="100%"><B>Users who agreed with this billback:</B></TD>
				</TR>
				<CFLOOP QUERY="GetAgreedUsers">
				<TR>
					<TD>#Name_First# #Name_Last#</TD>
					<TD>#LSCurrencyFormat(Agreed_Amount)#</TD>
					<TD>#DATEFORMAT(Created_Date,"mm/dd/yyyy")#</TD>
				</TR>
				</CFLOOP>

			</TABLE><BR><BR>
		</TD>
	</TR>
	</TABLE>

	<CFABORT>
	<!--- D25219: SOW - Enable mass paying of payables START --->
	<cfelse>
		</TABLE>
	</cfif>
	<!--- D25219: SOW - Enable mass paying of payables END --->
	<CFELSE>
<!--- D25219: SOW - Enable mass paying of payables --->
	<TR>
		<TD COLSPAN="100%">
		<cfif From_Quick_Pay EQ 0>
			<INPUT TYPE="Hidden" NAME="AgreeThisBB" VALUE="1">
		</cfif>
			<TABLE BORDER="1" CELLPADDING="3" CELLSPACING="0" CLASS="ErrorMessage" ALIGN="Center">

		<cfif From_Quick_Pay EQ 0 AND UserCanApproveCriticalBB>
				<TR>
					<TD COLSPAN="100%">You cannot approve this amount for this billback because it exceeds your approval level.
                    <CFIF Is_BB_Within_Budget NEQ 1>
                    <BR>You cannot approve this amount for this billback because it exceeds budget balance.
                    </CFIF>
                    </TD>
				</TR>
				<CFIF Is_Total_In_Range NEQ 1>
				<cfset BBTotalNotInRangeAgreeReason = "The billback approval amount exceeds the approval level">
				<INPUT TYPE="Hidden" NAME="BBTotalNotInRangeAgreeReason" VALUE="#BBTotalNotInRangeAgreeReason#">
				<INPUT TYPE="Hidden" NAME="Profile_Approval_Amt" VALUE="#Approve_Tot_Amount#">
				<TR>
					<TD>This Billback Approval Amount</TD>
					<TD>#LSCurrencyFormat(Payment_Amount)#</TD>
				</TR>
				<TR>
					<TD>Amount you Have Permission to Approve</TD>
					<TD>
						<cfif LSIsCurrency(Approve_Tot_Amount)>
							#LSCurrencyFormat(Approve_Tot_Amount)#
						<cfelse>
							#Approve_Tot_Amount#
						</cfif>
					</TD>
				</TR>
				</CFIF>
				<CFIF Is_Devi_In_Range NEQ 1>
				<cfset BBDeviationNotInRangeAgreeReason = "The billback deviation amount exceeds the approval level">
				<INPUT TYPE="Hidden" NAME="BBDeviationNotInRangeAgreeReason" VALUE="#BBDeviationNotInRangeAgreeReason#">
				<INPUT TYPE="Hidden" NAME="ThisBB_Deviation_Amt" VALUE="#Devi_Amount#">
				<INPUT TYPE="Hidden" NAME="Profile_Devi_amt" VALUE="#Approve_Devi_Amount#">
				<TR>
					<TD>This Billback Deviation Amount</TD>
					<TD>#LSCurrencyFormat(Devi_Amount)#</TD>
				</TR>
				<TR>
					<TD>Deviation Amount you Have Permission to Approve</TD>
					<TD>
						<cfif LSIsCurrency(Approve_Devi_Amount)>
							#LSCurrencyFormat(Approve_Devi_Amount)#
						<cfelse>
							#Approve_Devi_Amount#
						</cfif>
					</TD>
				</TR>
				</CFIF>
<cfelse>
	<tr>
		<td>

			<Cfif CheckBBProgram.BB_PNF IS 1 AND CheckBBProgram.BB_UP IS 1>
			 	<cfset BBTotalNotInRangeAgreeReason = "This billback does not have a known payee and has unknown program(s)">
			</CFIF>

			<cfif CheckBBProgram.BB_PNF IS 0 AND CheckBBProgram.BB_UP IS 1>
					<cfset BBTotalNotInRangeAgreeReason = "This billback does not have a known payee">
			</cfif>

			<cfif CheckBBProgram.BB_PNF IS 1 AND CheckBBProgram.BB_UP IS 0>
					<cfset BBTotalNotInRangeAgreeReason = "This billback has unknown program(s)">
			</cfif>

			<cfif appSettings.getReleaseSettlement() AND Get_Profile_Settings.BB_Approve_Critical EQ 0 AND CheckBBProgram.Release_Settlement AND CheckBBProgram.Released>
					<cfset BBTotalNotInRangeAgreeReason = "You cannot approve critical billbacks">
			</cfif>

			<INPUT TYPE="Hidden" NAME="BBTotalNotInRangeAgreeReason" VALUE="#BBTotalNotInRangeAgreeReason#">
			#BBTotalNotInRangeAgreeReason#
		</td>
	</tr>
</cfif>
			</TABLE><BR><BR>

		</TD>
	</TR>
	<!--- D25219: SOW - Enable mass paying of payables --->
	</CFIF>
</CFIF>

<!------ Can approve/agree, but lump sum cap stops the user from going forward ----->
<cfif Is_Lumpsum_In_Template_Range EQ 0 AND TemplateApprovalRight EQ 1>
	<table  cellpadding="2" cellspacing="0" style="color:red;" width="90%" align="center">
	<caption style="font-weight:bold;border-bottom:1px solid black;">Program template #LCase(Application.LumpsumLabel)# cap restriction</caption>
	<colgroup>
	<col span="1"></col>
	<col span="10" align="right"></col>
	</colgroup>
	<tr>
		<td><B>Program</B></td>
		<td><B>Template Cap</B></td>
		<td><B>Already Allocated/Paid</B></td>
		<td><B>Program Available Balance</B></td>
		<td><B>Available Amount</B></td>
		<td><B>Current Claim</B></td>
	</tr>
	<cfloop query="qCheckLumpSumTemplateCapExceed">
	<tr>
		<td>[#Contract_Number#] #Contract_Title#</td>
		<td style="color:red;">#DollarFormat(LumpSumCap)#</td>
		<td style="color:red;">#DollarFormat(currentAllocation)#</td>
		<td style="color:red;">#DollarFormat(ProgramAvailBalance)#</td>
		<td style="color:red;">#DollarFormat(LumpSumCap - currentAllocation + ProgramAvailBalance)#</td>
		<td style="color:red;">#DollarFormat(LS_Amount)#</td>
	</tr>
	</cfloop>
	</table>
	<br><br>
</cfif>

<!----- budget selection ----->
<cfset budgetSelectionOn = false />
<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBudgetsFunctionalityOn()>
<cfif Show_Agree EQ 0>
	<!---- if user gets approve link ---->
	<cfset budgetSelectionOn = true />
	<tr>
	<td>
		<cfinclude template="budget_billback_select_include.cfm">

	</td>
	</tr>
</cfif>
</cfif>

<TR>
	<TD COLSPAN="100%">

		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">

		<CFIF TemplateApprovalRight EQ 1>
		<td valign="top" width="150" align="left">
		<!--- Redirection logic --->
		<cfinclude template="Get_Payment_Next_Page.cfm" />



			<cfif Scheduled_Auto_BB>
				<cfset DifferentAmountAction = "/billbacks/capture/program_form.cfm?BBID=#Billback_ID#">
			<cfelse>
				<cfset DifferentAmountAction = "/billbacks/approval/index.cfm?BBID=#Billback_ID#">
			</cfif>

      <!---
            19441 If the page was called from the Flex BB Deviation page then set this link to go back
            to the Flex too page.
            21230:  Added the if conditions so that the link will work differently if the user came
            from scorecard and from Normal process. - Anand Rao (Friday the 13th of Nov ;))
      --->
	<cfif (isDefined("URL.source")
		AND
		(
		((URL.source EQ "flexBB" OR URL.source EQ "BBFlexScoreCard") AND appSettings.get_Setting('BB_Deviation_Format') is 'Flex')
		OR
		((URL.source EQ "AgGridBB" OR URL.source EQ "BBAgGridScoreCard") AND appSettings.get_Setting('BB_Deviation_Format') contains 'CF')
		))>
	  	<cfif appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
			<cfset DifferentAmountAction = "/billbacks/deviation/deviation_main.cfm?bbid=#Billback_ID#&source=#URL.source#&caller=#URL.source#">
		<cfelse>
			<cfset DifferentAmountAction = "/flex/Billback/BillbackDevAppFX.cfm?bbid=#Billback_ID#&userID=#request.AccessStructure.User_ID#&source=#URL.source#&caller=#URL.source#">
		</cfif>
  				<cfif (URL.source EQ BBScorecard)>
			            <CF_button
			      			    button_name		=	"Select Different Payment Amounts"
			          			button_caption	=	"Select Different Payment Amounts"
			      		    	button_action	=	"top.location.href = '#DifferentAmountAction#'"
			          			button_type		=	"javascript_link"
			          			button_width	=	"50"
			          			button_color	=	"Navy"
			          			button_tip		=	"Select Different Payment Amounts"
			          			font_color		=	"White"
			          			font_size		=	"12"
			          			font_weight		=	"bold">
				<cfelse>
		              <CF_button
		      			    button_name		=	"Select Different Payment Amounts"
		          			button_caption	=	"Select Different Payment Amounts"
		      		    	button_action	=	"window.open('#DifferentAmountAction#','BBDeviation','location=1,status=1,scrollbars=1,resizable=1,width=1300,height=800');return false;"
		          			button_type		=	"javascript_link"
		          			button_width	=	"50"
		          			button_color	=	"Navy"
		          			button_tip		=	"Select Different Payment Amounts"
		          			font_color		=	"White"
		          			font_size		=	"12"
		          			font_weight		=	"bold">
				</cfif>
	<cfelse>
				<CF_button
			    button_name		=	"Select Different Payment Amounts"
    			button_caption	=	"Select Different Payment Amounts"
		    	button_action	=	"window.location = '#DifferentAmountAction#'"
    			button_type		=	"javascript_link"
    			button_width	=	"50"
    			button_color	=	"Navy"
    			button_tip		=	"Select Different Payment Amounts"
    			font_color		=	"White"
    			font_size		=	"12"
    			font_weight		=	"bold">
	</cfif>

				</td>


		<cfif appSettings.getPullbacksOn()>
		<TD  valign="top" width="150" align="center">
			<!------ Display the Apply Pullback Link ----->
		 <cfif Get_Profile_Settings.BB_Apply_Pullback>
			<cfsilent>
				<cfquery name="checkifpullbackfromthisprg" datasource="#application.datasource#">
					select distinct Pullback_From_This_Program from
					billback
					inner join billback_program on
					billback_program.billback_id = billback.billback_id
					inner join contract_main on
					contract_main.contract_main_id = billback_program.program_id
					where billback.billback_id = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			</cfsilent>
			 <cfif checkifpullbackfromthisprg.Pullback_From_This_Program eq 1>
				<CF_button
				button_name		=	"Apply <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
				button_caption	=	"Apply <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
				button_action	=	"submitapplypullbackform();"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Apply <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>	<br>
				<script>
					function submitapplypullbackform()
					{
						NewWindow('/billbacks/approval/applypullbacks.cfm?BB_ID=<cfoutput>#Billback_Id#</cfoutput>','pullbackdetails','870','620','Yes', 'No');
					}
				</script>
			 </cfif>
		</cfif>
		<!------ Display the Un-Apply Pullback Link ----->
		<cfif GetPullbackInfo.BB_pullbacks_applied EQ 1>
			<CF_button
			button_name		=	"View Applied <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
			button_caption	=	"View Applied <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
			button_action	=	"submitunapplypullbackform();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"View Applied <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
			<script>
				function submitunapplypullbackform()
				{
					NewWindow('/billbacks/approval/viewappliedpullbacks.cfm?BB_ID=<cfoutput>#Billback_Id#</cfoutput>','pullbackdetails','870','620','Yes', 'No');
				}
			</script>
		</cfif>
	</TD>
	</cfif>

		<td valign="top" width="150" align="left">

			<cfif Show_Agree EQ 0>

			<cfif NOT GetBillbackInfo.scheduled_Auto_BB AND NOT GetBillbackInfo.Auto_Billback>
  				<cfif appSettings.getPullbacksOn() AND GetPullbackInfo.BB_pullbacks_applied EQ 1 AND GetBillbackInfo.BB_Is_Child NEQ 1>
					<cfset SplitAction ="/billbacks/approval/UnApplyPullBackForSplitting.cfm?Parent=#Billback_ID#">
				<cfelse>
					<cfset SplitAction = "Split_BB.cfm?Billback_ID=#Billback_ID#">
				</cfif>

				<cfif ShowSplit NEQ 0>
					<CF_button
					button_name		=	"Approve_Split"
					button_caption	=	"Approve and Split"
					button_action	=	"ApproveAndSplit('#SplitAction#', 'Approve_Split_table')"
					button_type		=	"javascript_link"
					button_width	=	"50"
					button_color	=	"Navy"
					button_tip		=	"Split this billback amount"
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
					>
					&nbsp; &nbsp;
					<Br>
					<!--- Show split --->
				</cfif>
			<!--- Not scheduled --->
			</cfif>

			<!---What page to go to next --->
			<cfinclude template="Get_Payment_Next_Page.cfm" />
			<!--- End next page --->

			<!--- Permission to do payment request --->
			<CFIF Show_Agree EQ 0>
				<!--- D25219: SOW - Enable mass paying of payables START--->
				<cfset AgreeOrApprove = "Approve">
				<!--- D25219: SOW - Enable mass paying of payables END--->
				<CFIF Closing_Method_Type EQ 1 OR (application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1)>
			<!--- 	For closing methods: 1 = payment, 2 = deduction. There currently no special handling for the other methods.
					You can find a complete list in the mapping table Billback_Closing_Methods
			 --->
							<!--- closing method PAYMENT --->
							<CF_button
							button_name		=	"Approve_Pay"
							button_caption	=	"Approve and Pay"
							button_action	=	"checkApprovedAmount('#ActionPage#')"
							button_type		=	"javascript_link"
							button_width	=	"50"
							button_color	=	"Navy"
							button_tip		=	"Approve and pay this billback"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
							>
							<br>
				<CFELSE>
			<!--- closing method DEDUCTION and any other besides "Payment" --->
							<CFSET ApprovalPage = "home">
							<CF_button
							button_name		=	"Approve"
							button_caption	=	"Approve"
							button_action	=	"checkApprovedAmount('#ApprovalPage#')"
							button_type		=	"javascript_link"
							button_width	=	"50"
							button_color	=	"Navy"
							button_tip		=	"Approve this billback"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
							>
							<p></p>
				</CFIF>
				<FONT SIZE="1" COLOR="Blue">
					<CFIF GetBillbackInfo.BB_Closing_Method EQ 2>
						Given the closing method selected, you must associate this transaction to a deduction.
					</CFIF>
				</FONT>
			</CFIF>
			</td>
		</tr>

		<cfelse>
				<!--- D25219: SOW - Enable mass paying of payables START--->
					<cfset AgreeOrApprove = "Agree">
				<!--- D25219: SOW - Enable mass paying of payables END--->

			<!--- no need to pass billback_id as part of (/billbacks/approval/payment_display.cfm) as the next page is any way appending the billback id to the url. so if we pass it here, the valeu will look some thing like 7dc4e3d9-a69a-4ed9-b786-aca7301ab77f?Billback_ID=7dc4e3d9-a69a-4ed9-b786-aca7301ab77f --->
			<CF_button
				button_name		=	"Agree"
				button_caption	=	"Agree"
				button_action	=	"checkApprovedAmount('/billbacks/approval/payment_display.cfm')"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Agree"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
				</td></tr>
		</cfif>
		<!--- Can you do first approval? --->
		<CFELSE>
			<TR>
				<TD><B><FONT COLOR="Red" SIZE="2">
					<cfif Get_Profile_Settings.BB_Approve EQ 0>
					You do not have approval rights.
					<cfelse>
					You do not have approval rights for this program template.
					</cfif>
					</FONT></B></TD>
			</TR>
		</CFIF>
		</TABLE>
	</TD>
</TR>

</CFOUTPUT>

<tr><td colspan="4">&nbsp; </td></tr>

</TABLE>
<input type="hidden" name="LocationAfterSaving" value="">
</form>

<cf_MessageWindow />
<script src="/billbacks/common/common_js_functions.js"></script>
<script language="JavaScript">
	function CopyThisNotes()
	{
		var BINotes = "<CFOUTPUT>#JSSTringFormat(BBNotes.BB_Creator_Notes)#</CFOUTPUT>";
		//document.all.Payment_Notes.value = BINotes; CHROMEFIX 57214
		jQuery("textarea[name=Payment_Notes]").val(BINotes);
	}

	function applyToNextLevel(thisObj, hideAndApply)
	{
		var objName = thisObj.name;
		var tabObj = getParentObject(thisObj, "table");
		var chObjCol = document.all[thisObj.name];
		var i, trLen, chLen, chIndex;
		chLen = chObjCol.length;
		chIndex = 0;
		for(i=0;i<chLen;i++)
		{
			if(chObjCol[i].checked)
			{
				chIndex = i;
			}
		}

		var trObjs;
		eval("trObjs = tabObj.all.TR_" + objName + ";");

		if(trObjs.length)
		{
			trLen = trObjs.length;
			for(i=0;i<trLen;i++)
			{
				disableTr(trObjs[i], !hideAndApply, chIndex);
			}
		}
		else
		{
			disableTr(trObjs, !hideAndApply, chIndex);
		}

	}

	function disableTr(trObj, bEnable, checkIndex)
	{
		var chObjs = trObj.getElementsByTagName("INPUT");
		var i, j, chLen1, chLen2;
		chLen1 = chObjs.length;
		for(i=0;i<chLen1;i++)
		{
			if(chObjs[i].type == "radio")
			{
				document.all[chObjs[i].name][checkIndex].click();
			}
		}
	}

	function reset_First_Level(thisObj, index)
	{
		var trObj = getParentObject(thisObj, "tr");
		if(trObj.id)
		{
			var trName = trObj.id;
			trName = trName.substr(3);
			var chObjs = document.all[trName];
			var i, chLen, selIndex;
			if(chObjs.length)
			{
				chLen = chObjs.length;
				selIndex = 0;
				for(i=0;i<chLen;i++)
				{
					if(chObjs[i].checked)
					{
						selIndex = i;
						break;
					}
				}
				if(selIndex != index)
				{
					chObjs[0].checked = true;
				}
			}
		}
	}

	function adjust_Payment_Amount(thisObj)
	{
		var i,chLen;
		var chObjCol = document.all[thisObj.name];
		var DeltaAmount = 0;
		var thisAmount = 0;
		var subtractAmount = 0;
		var checkedAmountObj, subtractAmountObj;
		chLen = chObjCol.length;
		var selIndex = 0;

		for(i=0;i<chLen;i++)
		{
			if(chObjCol[i].checked)
			{
				checkedAmountObj = chObjCol[i];
				thisAmount = checkedAmountObj.value;
				thisAmount = parseFloat(thisAmount);
				thisAmount = isNaN(thisAmount)?0:thisAmount;
				reset_First_Level(chObjCol[i], i);

			}
			if(chObjCol[i].subtractAmount == 1)
			{
				subtractAmountObj = chObjCol[i];
				subtractAmount = subtractAmountObj.value;
				subtractAmount = parseFloat(subtractAmount);
				subtractAmount = isNaN(subtractAmount)?0:subtractAmount;
			}
		}

		if(subtractAmountObj)
		{
			subtractAmountObj.subtractAmount = 0;
		}
		if(checkedAmountObj)
		{
			checkedAmountObj.subtractAmount = 1;
		}
		if(checkedAmountObj)
		{
			DeltaAmount = (thisAmount - subtractAmount);
			//var existing_Amount = parseFloat(document.all.Total_Payment_Amount.innerText);
			var existing_Amount = parseFloat(document.all.INP_Total_Payment_Amount.value);
			existing_Amount = existing_Amount - DeltaAmount;
			document.all.INP_Total_Payment_Amount.value = existing_Amount;
			existing_Amount = formatToDeciamalPlaces(existing_Amount, 2);
			document.all.Total_Payment_Amount.innerText = existing_Amount;
			event.cancelBubble = true;
		}

	}

	function disablePageLinks() // gets called from business considerations pop-up
	{
		disableApproveLink();
	}

	function disableApproveLink() // gets called from business considerations pop-up
	{
		// disable these link, if some of these does not exist disableButton does handle for it.
		disableButton("Approve_Pay_table", true, false);
		disableButton('Approve_Split_table', true, false);
		disableButton("Approve_table", true, false);
		disableButton("Agree_table", true, false);
	}

	function checkApprovedAmount(RedirectionURL)
	{
		//*** START DEV NOTE: DAA; D16974: Validation for reason code selection, make sure one is selected
		var ErrorCount = 0;
		var bbTaxErrorCount = 0;
		<cfif appsettings.ReasonCodeinBillbackDED><!---  AND GetBillbackInfo.BB_Closing_Method EQ 2 --->


			<cfif bReasonCodeSelection>
			if (!isReasonCodeSelected()){
				queueMessage("Please select a reason code.", document.all.error_DD_Reason_Code_ID);
				ErrorCount++;
			} else {
				clearQueue(document.all.err_Business_Segment_ID);
			}
			</cfif>
			
			<cfif (HasDefaultProgram AND Payment_Amount NEQ 0)>
				queueMessage("Billback has the default program associated with it and the approval amount cannot be greater than $0.\nPlease pick $0 to approve.", document.all.error_DD_Reason_Code_ID);
				ErrorCount++;
			</cfif>
// 117446 :: Billback - sales tax code START 
			<cfif appSettings.getBillbacksSalesTax() EQ 2>
				if (document.all.Billbacks_Sales_Tax.value == "0"){
					queueMessage("Please select a tax type.", document.all.error_Tax_Type);
					ErrorCount++;
				}
			</cfif>
// 117446 :: Billback - sales tax code END 
			if (ErrorCount != 0){
				showMessageWindow();
				return false;
			}
		</cfif>
		//*** END DEV NOTE: DAA; D16974

		var bOK = false;
		var allValid = true;
		var bTaxValid = true;

		<cfif newSalesTaxType EQ 0 AND bBillbackSalesTax eq 1>
			bTaxValid = CheckForErrors();
		</cfif>

		<cfif budgetSelectionOn>
			<!---- if user gets approve link ---->
			allValid = validateBudgetSelection();
		</cfif>

		if(!allValid){
			showMessageWindow();
			return false;
		}
		if (!bTaxValid){
			return false;
		}

		var Approving_Amount = document.all.INP_Total_Payment_Amount.value;
		Approving_Amount = parseFloat(Approving_Amount);
		document.all.LocationAfterSaving.value = RedirectionURL;
		//disable the approve link
		disableApproveLink(); 	{
			<CFIF Show_Agree EQ 1>
			NewWindow('/billbacks/common/BB_Business_Consideration.cfm?MODE=1&Formname=MakePayment&BBID=<cfoutput>#Billback_ID##sQueryStringAppender#</cfoutput>','BB_BusiConsi','800','600','Yes', 'Yes');
			<CFELSE>
			NewWindow('/billbacks/common/BB_Business_Consideration.cfm?MODE=2&Formname=MakePayment&BBID=<cfoutput>#Billback_ID##sQueryStringAppender#</cfoutput>','BB_BusiConsi','800','600','Yes', 'Yes');
			</CFIF>

			bOK = true;
		}
		bOK = false;
		return bOK;
	}

	function ApproveAndSplit(url, linkName)
	{
		//disable the approve link(s)
		var bTaxValid = true;
		<cfif newSalesTaxType EQ 0 AND bBillbackSalesTax eq 1>
			bTaxValid = CheckForErrors();
		</cfif>
		if(!bTaxValid)
		{
			//showMessageWindow();
			return false;
		}
		disableApproveLink();
		document.all.LocationAfterSaving.value = url;
		document.all.MakePayment.submit();
	}

	// BSD D11544
	<!--- Dev Note: drachala; D28320: User is unable to scroll through Billback  START
    What  I did: Comment if statement so that window can expand dynamically --->
   <!---<cfif NOT isDefined("URL.source")>  --->
  <!--- <cfif NOT isDefined("APPLICATION.BBFlexSource") AND (APPLICATION.BBFlexSource EQ "BBFlexScoreCard")> --->
    try { window.parent.dyniframesize(); } catch (err) { };
  <!---</cfif>--->
</script>