<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<!--- <!DOCTYPE HTML> --->
<html>
<head>
	<title>Billback Summary</title>
<cfsilent>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset BillbackSummaryManager = CreateObject("component", "components.Billback.BillbackSummaryManager")>
<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
<cfset variables.VendorLabel = labelSettings.getBBLabels().vendor />

<CFPARAM NAME="URL.BBID"	DEFAULT="">
<cfparam name="url.SHOW_PRINT_VERSION" default="0">
<cfparam name="url.show_email_version" default="0">
<cfparam name="HasDefaultProgram" default="0">
<cfparam name="HasUnknownProduct" default="0">
<cfparam name="HasInvalidVolume" default="0">
<cfparam name="url.bb_lock_action" default="0">

<cfset LabelComp 		= Createobject("component", "components.settings.labels.labels").init() />
<cfset qGetBSVar2Label	= LabelComp.getGeneralLabels('BS_Var_2') />

<CFSET Billback_ID=URL.BBID>
<!--- Dev Note: Clay 11044 - BB Preview --->
<CFSET sBillbackViewCacheFileName = "View_Billback_" & REREPLACE(Billback_ID,'-','_','ALL') & ".htm" />

<CFQUERY NAME="CheckCopiedBB" DATASOURCE="#Application.Datasource#">
	SELECT Billback.*, _users.name_first + ' ' + _users.name_last as user_name
	FROM Billback
	left join _users on
	_users.user_id = Billback.BB_Modify_Agree_User
	WHERE Billback_ID = '#URL.BBID#'

</CFQUERY>

<!--- Ana 15906 - Auto Deviation Failed - 0 volume in the Billback Product ... --->
<CFIF CheckCopiedBB.Billback_Status_ID EQ 1>
	<CFQUERY NAME="CheckForZeroVolume" DATASOURCE="#Application.Datasource#">
		SELECT 	TOP 1 * FROM Billback_Product
		WHERE 	Billback_ID = '#URL.BBID#' AND
				CAST(BB_Product_Quantity AS Float) = 0 AND
				Deleted = 0
	</CFQUERY>
</CFIF>
<!--- Check to see if default program is on billback D11756--->
<Cfquery name="GetBillbackSettings" datasource="#application.datasource#">
SELECT Default_Program
FROM Billback_Settings
</CFQUERY>
<!--- 61486 : Default program only when $'s equal to $0.00 START--->
<cfset HasDefaultProgram = BillbackSummaryManager.DummyProgram(Billback_ID)>
<!---61486 : Default program only when $'s equal to $0.00 END--->

<!--- End check to see if default program is on billback D11756 --->

<cfquery name="InvalidProducts" datasource="#application.datasource#">
	SELECT 	DISTINCT
			CASE WHEN Billback_Product.Product_ID IS NULL THEN 1 ELSE 0 END as HasUnknownProduct,
			CASE WHEN CAST(Billback_Product.BB_Product_Quantity AS DECIMAL(18,2)) = 0 THEN 1 ELSE 0 END as HasInvalidVolume
	FROM 	Billback_Program
	INNER JOIN Billback_Product
	ON		Billback_Product.Billback_ID = Billback_Program.Billback_ID
	AND		Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
	AND		Billback_Product.Deleted = 0
	AND		(Billback_Product.Product_ID IS NULL OR CAST(Billback_Product.BB_Product_Quantity AS DECIMAL(18,2)) = 0)
	WHERE 	Billback_Program.Billback_ID = '#Billback_ID#'
	AND 	Billback_Program.Deleted = 0
</cfquery>
<cfif InvalidProducts.Recordcount GT 0 AND appSettings.getThirdPartyBBUpload() NEQ 3>
	<cfset HasUnknownProduct = InvalidProducts.HasUnknownProduct />
	<cfset HasInvalidVolume = InvalidProducts.HasInvalidVolume />
</cfif>
</cfsilent>

<CFIF CheckCopiedBB.CopiedBB NEQ "" AND CheckCopiedBB.BB_Start_Date EQ "">
	<CFLOCATION URL="basic_information_form.cfm?BBID=#URL.BBID#" ADDTOKEN="No">
<!---
<!--- BJF D10746 -- don't hold them hostage to item volume when they copy --->
<CFELSEIF CheckCopiedBB.CopiedBB NEQ "" AND CheckCopiedBB.VolumeRateSaved EQ 0>
	<CFLOCATION URL="/billbacks/capture/program_form.cfm?BBID=#URL.BBID#" ADDTOKEN="No"> --->
</CFIF>

<!--- MOVED FROM LINE 240 so taht the itemized total would be available for ...infobar.cfm below--->
<cfset local_bbid = Billback_ID>
<cfinclude template="bb_menu_stats.cfm">
<!--- MOVED FROM LINE 240 seems ok...need to test more--->

<CFSET InfoBar_BBID = Billback_ID>
<cfinclude template="billback_load_infobar.cfm">

<cfset useLakebaseForCheckSplit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForCheckSplit>
	<cftry>
		<cfset CheckSplit = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"bb_parent_id" = "eq.#URL.BBID#",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckSplit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckSplit>
<CFQUERY NAME="CheckSplit" DATASOURCE="#Application.Datasource#">
	SELECT Top 1 * FROM Billback WHERE BB_parent_ID = '#URL.BBID#' AND Deleted = 0
</CFQUERY>
</cfif>
<cfset Split_Parent = CheckSplit.recordCount />

<SCRIPT language="JavaScript">
function modify_agreeaproval()
{
	alert("Billback is being modified by <cfoutput>#CheckCopiedBB.user_name#</cfoutput>");
}
</SCRIPT>
	<cfinclude template="iframe_style.cfm">
</head>
<!---
<img src=/images/lock3.gif width=25 height=34 border=0 onmouseover=""this.src='/images/lock2.gif'"" onmouseout=""this.src='/images/lock3.gif'"" style=""cursor:pointer;""><BR>UNLOCKED
 --->
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="0">


<cfinclude template="/get_access_profile.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This section handles the Billback Approval								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Display The Appropriate Status --->
<CFSET StatusDisplay_CELLSPACING	= 4>
<CFSET StatusDisplay_CELLPADDING	= 0>
<CFSET StatusDisplay_FONTCOLOR		= "white">
<CFSET StatusDisplay_CELLBGCOLOR	= "green">

<CFSET Program_Is_A_Revision 			= 0>
<CFSET ISPROGRAMTEMPLATEAVAILABLE 		= 1>
<CFSEt DisAllowAccessBasedOnPosition 	= 0>
	<cfquery name="qGetBBsLockedByMe" datasource="#Application.Datasource#">
		SELECT BB_Is_Locked
		FROM Billback_Allied
		WHERE
			BB_Is_Locked			=	1
			AND
			BB_Locked_By_User_ID	= '#request.AccessStructure.User_ID#'
			<CFIF LEN(trim(Billback_ID)) GT 0 AND Billback_ID NEQ 0>
				AND
				Billback_ID <> '#Billback_ID#'
			</CFIF>
	</cfquery>
	<CFIF qGetBBsLockedByMe.recordcount GT 0>
		<cfquery name="UnLockOtherBillbacksLockedByMe" datasource="#Application.Datasource#">
			UPDATE	Billback_Allied
			SET
				BB_Is_Locked = 0
			WHERE
				BB_Is_Locked			=	1
				AND
				BB_Locked_By_User_ID	= '#request.AccessStructure.User_ID#'
				<CFIF LEN(trim(Billback_ID)) GT 0 AND Billback_ID NEQ 0>
					AND
					Billback_ID <> '#Billback_ID#'
				</CFIF>
			AND BB_Locked_By_Match_Central = 0
		</cfquery>
	</CFIF>

	<cfset useLakebaseForGetLockStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForGetLockStatus>
	<cftry>
		<cfset GetLockStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_allied", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "bb_is_locked,bb_locked_by_user_id"
			}), "bb_is_locked,bb_locked_by_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetLockStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetLockStatus>
<cfquery name="GetLockStatus" datasource="#Application.Datasource#">
		SELECT BB_Is_Locked,BB_Locked_By_User_ID
		FROM
			Billback_Allied
		WHERE
			Billback_ID = '#Billback_ID#'
	</cfquery>
</cfif>


	<CFIF GetLockStatus.BB_Is_Locked EQ 1>
		<CFSET DisAllowAccessBasedOnLockStatus 	= 0>
	<CFELSE>
		<CFSET DisAllowAccessBasedOnLockStatus 	= 1>
	</CFIF>

	<CFIF GetLockStatus.BB_Locked_By_User_ID NEQ request.AccessStructure.User_ID>
		<CFSET DisAllowAccessBasedOnLockStatus 	= 1>
	</CFIF>
<cfset APVL_Contract_Status = getBillbackInformation.Billback_Status_ID>

<cfscript>
	StatusDisplay_BGCOLOR		= "";
	StatusDisplay_CELLBGCOLOR	= "";
	StatusDisplay_DisplayText   = "";
</cfscript>


<!--- START: 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] - Anand Rao/28-Jun-2018 --->
<cfset DCsFailed = 0 />
<cfif  (appSettings.get_Setting('BB_Display_Dist_Channel_Per_Program_Distributor'))>
		<cfset useLakebaseForgetDCDistCount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distribution_channel")>
<cfif useLakebaseForgetDCDistCount>
	<cftry>
		<cfset getDCDistCount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distribution_channel", {
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0",
				"bs_var_2" = "eq."
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDCDistCount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDCDistCount>
<cfquery name="getDCDistCount" datasource="#application.datasource#">
			SELECT * from Billback_Distribution_Channel where Billback_ID = '#Billback_ID#' AND Deleted = 0 and BS_VAR_2 = ''
		</cfquery>
</cfif>
		<cfif (getDCDistCount.Recordcount NEQ 0)>
			<cfset DCsFailed = 1>
		</cfif>
</cfif>
<!--- END: 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] - Anand Rao/28-Jun-2018 --->

<!--- START: 108970	Vendor changes for Segment / Anand Rao / 09-Dec-2021 --->
<CFSET IncompleteMessage = "This billback needs to be corrected before moving it to Ready For Approval." />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<!--- <cfoutput>#businessSegManager.isEnabledForVendorType()#</cfoutput>
<cfabort> --->
<cfset BusinessSegmentMessageOn = 0 />
<cfset BusinessSegmentMessage = "" />
	<cfif businessSegManager.isEnabledForVendorType() NEQ 0>
		<cfset useLakebaseForLoadBillbackData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForLoadBillbackData>
	<cftry>
		<cfset LoadBillbackData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "bb_title,bb_date,bb_start_date,bb_end_date,bb_amount,bb_reference,bb_creator_id,bb_creator_notes,bb_code,bb_creator_user_position_id,billback_status_id,billback_payee_type_id,bb_up,bb_pnf,created_date,deleted,scheduled_auto_bb,bb_closing_method,vendor_only_billback"
			}), "bb_title,bb_date,bb_start_date,bb_end_date,bb_amount,bb_reference,bb_creator_id,bb_creator_notes,bb_code,bb_creator_user_position_id,billback_status_id,billback_payee_type_id,bb_up,bb_pnf,created_date,deleted,scheduled_auto_bb,bb_closing_method,vendor_only_billback"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLoadBillbackData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLoadBillbackData>
<cfquery name="LoadBillbackData" datasource="#Application.Datasource#">
			SELECT
				BB_Title,
				BB_Date,
				BB_Start_Date,
				BB_End_Date,
				BB_Amount,
				BB_Reference,
				BB_Creator_ID,
				BB_Creator_Notes,
				BB_Code,
				BB_Creator_User_Position_ID,
				Billback_Status_ID,
				Billback_Payee_Type_ID,
				BB_UP,
				BB_PNF,
				Created_Date,
				Deleted,
				Scheduled_Auto_BB,
				BB_Closing_Method,
				Vendor_Only_Billback
			FROM Billback
			WHERE Billback_ID = '#Billback_ID#'
		</cfquery>
</cfif>
		<!--- <cfset savedPayeeType = LoadBillbackData.Billback_Payee_Type_ID /> --->
		<cfset lsVendorBusinessSegmentID = ""/>
		<cfswitch expression="#LoadBillbackData.Billback_Payee_Type_ID#">
			<cfcase value="1">
				<cfquery name="getPayeeData" datasource="#Application.Datasource#">
					SELECT BFC.Business_Segment_ID, BS.Business_Unit_Desc, BD.*
					FROM Billback_Distributor BD
					INNER JOIN BSA_Foodservice_Customers BFC ON BFC.BSA_Foodservice_Customers_ID = BD.Distributor_ID
					INNER JOIN Business_Segment BS ON BS.Business_Segment_ID = BFC.Business_Segment_ID 
					WHERE BD.Billback_ID = '#Billback_ID#' AND BD.Deleted = 0
				</cfquery>
				<cfset VendorList = QuotedValueList(getPayeeData.Uploaded_Vendor_ID) />
				<cfset BusinessSegmentList = ValueList(getPayeeData.Business_Segment_ID) />
				<cfset lsDistBusinessUnitDesc = getPayeeData.Business_Unit_Desc />
				<cfquery name="qryCheckVendorBusSeg" datasource="#Application.Datasource#">
					SELECT BS.Business_Unit_Desc, VM.* FROM Vendor_Master VM
					INNER JOIN Business_Segment BS ON BS.Business_Segment_ID = VM.Business_Segment_ID
					WHERE VM.Vendor_ID IN (#PreserveSingleQuotes(VendorList)#)
					AND VM.Business_Segment_ID NOT IN (#BusinessSegmentList#)
				</cfquery>
				<cfset lsVendorBusinessSegmentID = ValueList(qryCheckVendorBusSeg.Business_Segment_ID) />
				<cfif (isDefined("qryCheckVendorBusSeg") AND qryCheckVendorBusSeg.RecordCount NEQ 0)>
					<cfset BusinessSegmentMessageOn = 1 />
					<cfset lsVendBusinessUnitDesc = qryCheckVendorBusSeg.Business_Unit_Desc />
					<cfset BusinessSegmentMessage = BusinessSegmentMessage & "\n" & application.returned_customer_setting.distributor_label_singular & " vs Vendor Mismatch" />
					<cfset BusinessSegmentMessage = BusinessSegmentMessage & "\n     " & application.returned_customer_setting.distributor_label_singular & " " & appSettings.getbusiness_segment_label() & "(s): " & lsDistBusinessUnitDesc  />
					<cfset BusinessSegmentMessage = BusinessSegmentMessage & "\n     " & "Vendor " & appSettings.getbusiness_segment_label() & "(s): " & lsVendBusinessUnitDesc  />
					<cfset IncompleteMessage = IncompleteMessage & BusinessSegmentMessage />
				</cfif>
			</cfcase> 
			<cfcase value="2"><!--- op --->
			 <!--- Code removed as it was not needed for this scenario check the CVS diff to see the difference --->		
			</cfcase>
		</cfswitch>
		
	</cfif> <!--- END: <cfif businessSegManager.isEnabledForVendorType() NEQ 0> --->
<!--- END: 108970	Vendor changes for Segment / Anand Rao / 09-Dec-2021 --->
<!--- <cfdump var="#IncompleteMessage#" /><cfabort> --->
<CFSWITCH EXPRESSION="#APVL_Contract_Status#">
	<CFCASE VALUE="1">

		<cfif (HasDefaultProgram IS 1 AND Get_Profile_Settings.Allow_RFA_With_Default_Program EQ 0) OR HasUnknownProduct IS 1 OR HasInvalidVolume IS 1>

			<CFSET StatusDisplay_DisplayText	= "INCOMPLETE">

		<CFSET StatusDisplay_BGCOLOR		= "orange">
		<CFSET StatusDisplay_CELLBGCOLOR	= "orange">

		<cfif HasDefaultProgram IS 1 AND Get_Profile_Settings.Allow_RFA_With_Default_Program EQ 0>
			<cfset useLakebaseForGetDefaultProgramInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetDefaultProgramInfo>
	<cftry>
		<cfset GetDefaultProgramInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#GetBillbackSettings.Default_Program#",
				"select" = "contract_number"
			}), "contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDefaultProgramInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDefaultProgramInfo>
<cfquery name="GetDefaultProgramInfo" datasource="#application.datasource#">
			SELECT Contract_Number FROM Contract_Main WHERE Contract_Main_ID = '#GetBillbackSettings.Default_Program#'
			</cfquery>
</cfif>
			<CFSET IncompleteMessage = IncompleteMessage & "\n\n" & "Billback has the default program (#GetDefaultProgramInfo.Contract_Number#) associated with it. Please transfer all records off of the default program to continue." />
		</cfif>
		<cfif HasUnknownProduct IS 1>
			<CFSET IncompleteMessage = IncompleteMessage & "\n\n" & "Billback has unknown produts(s)." />
		</cfif>
		<cfif HasInvalidVolume IS 1>
			<CFSET IncompleteMessage = IncompleteMessage & "\n\n" & "Billback has produts(s) with zero volume." />
		</cfif>
		<cfif DCsFailed IS 1>
			<CFSET IncompleteMessage = IncompleteMessage & "\n\n" & "Billback has some of the #qGetBSVar2Label.General_Labels_Label# empty" />
		</cfif>
		
			<SCRIPT>
			function confirmApproval(){
				<!--- alert("This billback has the default program (<cfoutput>#GetDefaultProgramInfo.Contract_Number#</cfoutput>) associated with it. Billbacks with the default program cannot be moved to Ready For Approval. Please transfer all records off of the default program to continue."); --->
				alert("<cfoutput>#IncompleteMessage#</cfoutput>");
				document.all.ApproveContractButton.checked = false;
			}
			</SCRIPT>
		<!--- Can't RFA if the default program is on the billback --->
		<cfelse>

		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Work In Progress">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Revision In Progress">
		</CFIF>

		<CFSET StatusDisplay_BGCOLOR		= "gray">
		<CFSET StatusDisplay_CELLBGCOLOR	= "gray">
		<!---61486 : Default program only when $'s equal to $0.00 START --->
		<CFIF HasDefaultProgram EQ 1>
			<CFSET StatusDisplay_DisplayText	= "INCOMPLETE">
			<CFSET StatusDisplay_BGCOLOR		= "orange">
			<CFSET StatusDisplay_CELLBGCOLOR	= "orange">
		</CFIF>
		<!---61486 : Default program only when $'s equal to $0.00 END --->
		<SCRIPT>
			function confirmApproval() {
				var payee = 0
				var program = 0
				var alertvar = ""
				var ZeroVolume = 0
				var DCFailed = 0
				var BusinessSegmentMessageOn = 0
				
				if (window.parent.bb_complete_payee == true){
					payee = 1	}
				if (window.parent.bb_complete_programs == true)	{
					program = 1		}
				<!--- Ana 15906 - Auto Deviation Failed - 0 volume in the Billback Product ... --->
				<CFIF CheckCopiedBB.Billback_Status_ID EQ 1 AND CheckForZeroVolume.RecordCount GT 0 AND appSettings.getBBProductAllowZeroVolume() EQ 0>
					ZeroVolume = 1
				</CFIF>
				<cfif DCsFailed IS 1>
					DCFailed = 1
				</cfif>
				<cfif BusinessSegmentMessageOn IS 1>
					BusinessSegmentMessageOn = 1
				</cfif>
				
				//if(window.parent.bb_complete_payee == true){
				if (payee == 1 && program == 1 && ZeroVolume == 0 && DCFailed == 0 && BusinessSegmentMessageOn == 0){
						document.all.ApproveContractButton.disabled = true;
						processingPopUpDisplay('div.customContainer'); //D51575
						NewWindow('/billbacks/common/BB_Business_Consideration.cfm?MODE=5&Formname=ApprovalForm&BBID='+document.ApprovalForm.Billback_ID.value,'BB_BusiConsi','800','600','Yes', 'Yes');
						//document.all.ApprovalForm.submit();
				}
				else{
					if (payee == 0)	{
						alertvar = "\n* Payee"	}
					if (program == 0)	{
						alertvar = alertvar + "\n The billback amount on the basic info page does not equal the amount on the programs page.  \nAmounts must match before proceeding." }
					if (ZeroVolume == 1)	{
						alertvar = alertvar + "\n Billback has one or more products with Zero volume. Volume can not be zero." }
					<cfif DCsFailed IS 1>
						alertvar = alertvar + "\n <cfoutput>#qGetBSVar2Label.General_Labels_Label# for #application.returned_customer_setting.distributor_label_plural#</cfoutput> must be selected before moving forward."
					</cfif>
					if (BusinessSegmentMessageOn == 1)
					{
						alertvar = alertvar + "\n <cfoutput>#BusinessSegmentMessage#</cfoutput>";
					}
						alert("Please complete the following items first:\n "+alertvar)
				}
			}

			
			/*function confirmApproval() {
				if(window.parent.bb_complete_payee == true){
						document.all.ApproveContractButton.disabled = true;
						NewWindow('/billbacks/common/BB_Business_Consideration.cfm?MODE=5&Formname=ApprovalForm&BBID='+document.ApprovalForm.Billback_ID.value,'BB_BusiConsi','800','600','Yes', 'Yes');
						//document.all.ApprovalForm.submit();

				}
				else{
					alert("Select a payee before flagging this billback as 'Ready For Approval'")
				}
			}*/
		</SCRIPT>
		</cfif>
		<!-- </FORM> -->
	</CFCASE>

	<CFCASE VALUE="2">
		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Ready For Approval">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Revision Ready For Approval">
		</CFIF>
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
		<!---77024 :: BB Assignment - by template START--->
		<cfif val(appSettings.get_Setting('BB_Assignment_By_Template')) EQ 1>
				<cfset canApproveProgramTemplate = BillbackSummaryManager.ProgramApprovalRights(Billback_ID, request.AccessStructure.user_id)>
		<cfelse>
				<cfset canApproveProgramTemplate = 1>
		</cfif>
		<!---77024 :: BB Assignment - by template END--->
		<SCRIPT>
			function disableApproveLink()// this function will get called from inside the business considerations pop up
			{
				var tdObj = document.all.TD_Approve_Link;
				if(tdObj){
					tdObj.onclick = new Function ("return false;");
					tdObj.onmouseover = new Function ("return false;");
					tdObj.onmouseout = new Function ("return false;");
					tdObj.bgColor = "cccccc";
					tdObj.style.backgroundColor = "cccccc";
					tdObj.style.cursor = "default";
				}
			}
			function BeginApprovalProcess() {  
				<!---77024 :: BB Assignment - by template --->
				var alertvar = "";
				<cfif canApproveProgramTemplate>
					<!--- cfif HasDefaultProgram AND CheckCopiedBB.bb_amount ---> //D61486
					<!---	alertvar = "Billback has the default program associated with it.\nPlease transfer all records off of the default program to continue";					<cfelse> --->
						processingPopUpDisplay('div.customContainer'); //D51575
						NewWindow('/billbacks/common/BB_Business_Consideration.cfm?MODE=2&EDIT=0&Formname=ApprovalForm&BBID='+document.ApprovalForm.Billback_ID.value,'BB_BusiConsi','800','600','Yes', 'Yes');
					<!--- /cfif --->
				<cfelse>
					alertvar = "You cannot approve this Billback due to program template access restrictions."
				</cfif>
				<cfif DCsFailed IS 1>
					alertvar = alertvar + "\n Billback has some of the <cfoutput>#qGetBSVar2Label.General_Labels_Label#</cfoutput> empty"
				</cfif>
				if (alertvar != "")
				{
					alert(alertvar);
				}
				
			}

			function BeginNegativeBillbackApprovalProcess() {
				var alertvar = "";
				<!---77024 :: BB Assignment - by template --->
				<cfif canApproveProgramTemplate>
					processingPopUpDisplay('div.customContainer'); //D51575
					NewWindow('/billbacks/common/BB_Business_Consideration.cfm?MODE=10&EDIT=0&BBID='+document.ApprovalForm.Billback_ID.value,'BB_BusiConsi','800','600','Yes', 'Yes');
				<cfelse>
					alertvar = "You cannot approve this Billback due to program template access restrictions."
				</cfif>
				<cfif DCsFailed IS 1>
					alertvar = alertvar + "\n Billback has some of the <cfoutput>#qGetBSVar2Label.General_Labels_Label#</cfoutput> empty"
				</cfif>
				if (alertvar != "")
				{
					alert(alertvar);
				}
			}

			function BeginAutoBBApprovalProcess()	{
				var alertvar = "";
				<!---77024 :: BB Assignment - by template --->
				<cfif canApproveProgramTemplate>
					processingPopUpDisplay('div.customContainer'); //D51575
					window.location.href ='/billbacks/approval/index.cfm?Auto_Billback_Approval=1&BBID='+document.ApprovalForm.Billback_ID.value;
				<cfelse>
					alertvar = "You cannot approve this Billback due to program template access restrictions."
				</cfif>
				<cfif DCsFailed IS 1>
					alertvar = alertvar + "\n Billback has some of the <cfoutput>#qGetBSVar2Label.General_Labels_Label#</cfoutput> empty"
				</cfif>
				if (alertvar != "")
				{
					alert(alertvar);
				}
			}

<!--- Dev Note:Milan;11363 - Is the function below being used now ? --->
			function confirmApproval() {
				if(confirm("Press OK To Flag This Billback as Paid")) {
					processingPopUpDisplay('div.customContainer'); //D51575
					document.all.ApprovalForm.submit();
				}
				else {
					document.all.ApproveContractButton.checked = false;
				}
			}
		</SCRIPT>
	</CFCASE>

	<CFCASE VALUE="3">
		<CFSET StatusDisplay_DisplayText	= "Approved">
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "green">
		<CFSET StatusDisplay_FONTCOLOR		= "white">
	</CFCASE>

	<CFCASE VALUE="4">
		<CFSET StatusDisplay_DisplayText	= "Payment Request">
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>

	<CFCASE VALUE="5">
		<CFSET StatusDisplay_DisplayText	= "Paid">
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>
	<CFCASE VALUE="6">
		<CFSET StatusDisplay_DisplayText	= "Pending Fund Update">
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>
	<CFCASE VALUE="7">
		<CFSET StatusDisplay_DisplayText	= "Pending Vendor ID">
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>
	<CFCASE VALUE="8">
		<CFSET StatusDisplay_DisplayText	= "Approved - VOID">
		<CFSET StatusDisplay_BGCOLOR = "Red">
	</CFCASE>
	<CFCASE VALUE="9">    <!--- 55551 --->
		<CFSET StatusDisplay_DisplayText	= "Rejected">
		<CFSET StatusDisplay_BGCOLOR = "Red">
	</CFCASE>

</CFSWITCH>

<CFSET IsAgreed = 0>
<CFIF Get_Profile_Settings.BB_RFA_Agreed EQ 1 AND APVL_Contract_Status EQ 2>
	<CFQUERY NAME="IsRFAAgreed" DATASOURCE="#application.datasource#">
		SELECT 		*
		FROM 		User_Position_Holders
		INNER JOIN 	_Users ON _Users.User_ID = User_Position_Holders.User_ID AND _Users.Deleted = 0
		INNER JOIN 	BB_Agreed_Info ON BB_Agreed_Info.User_position_ID = User_Position_Holders.User_Positions_ID AND BB_Agreed_Info.Authority_Sequence_ID = ISNULL(_Users.Authority_Sequence_ID,0) AND BB_Agreed_Info.Deleted = 0
AND BB_Agreed_Info.user_id = User_Position_Holders.User_ID
		WHERE 		User_Position_Holders.User_ID = '#request.AccessStructure.user_id#' AND User_Position_Holders.Deleted = 0 AND
					BB_Agreed_Info.Billback_ID = '#Billback_ID#'
	</CFQUERY>
	<CFIF IsRFAAgreed.RecordCount GT 0>
		<CFSET IsAgreed = 1>
		<!--- <CFSET StatusDisplay_DisplayText = "Agreed"> --->
	</CFIF>
</CFIF>


<CFOUTPUT>
	<TABLE
		BORDER="0"
		CELLSPACING="#StatusDisplay_CELLSPACING#"
		CELLPADDING="#StatusDisplay_CELLPADDING#"
		WIDTH="100%"
		BGCOLOR="#StatusDisplay_BGCOLOR#">
	<TR>
		<TD BGCOLOR="#StatusDisplay_CELLBGCOLOR#" WIDTH="100%"><FONT COLOR="#StatusDisplay_FONTCOLOR#" SIZE="3"><B>#StatusDisplay_DisplayText#</B></FONT></TD>
			<CFIF (APVL_Contract_Status EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0) AND (CheckCopiedBB.CopiedBB EQ "" OR CheckCopiedBB.VolumeRateSaved EQ 1) AND Get_Profile_Settings.BB_Create EQ 1>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP>
				&nbsp;&nbsp;&nbsp;
				<FONT COLOR="Black" SIZE="3"><B><!--- Click Here To Flag This Program As  --->Ready For Approval</B></FONT>
				<INPUT TYPE="checkbox" NAME="ApproveContractButton" TITLE="Click Here to Begin Approval Process" VALUE="" onClick="confirmApproval()">
				&nbsp;&nbsp;&nbsp;
			</CFIF>

			<!--- this user has full approval abilities --->
			<CFIF APVL_Contract_Status EQ 2 AND DisAllowAccessBasedOnLockStatus EQ 0 AND Get_Profile_Settings.BB_VIEW_DEVIATION EQ 1>
				<cfset disabledApproveLink = 0 />
				<cfset disabledApproveLinkLabel = "" />
				<cfset disabledApproveLinkTitle = "" />

				<!----- Disable the link and show "Agreed" when the billback is already agreed to and I am not same as or above the current CRA ----->
				<CFIF 			appsettings.getBillbackModifyAgree() EQ 1
						AND 	indexSettings.bb_agreed_to EQ 1
						AND 	indexSettings.cra_or_above EQ 0

					>
					<cfset disabledApproveLink = 1 />
					<cfset disabledApproveLinkLabel = "Agreed" />
					<cfset disabledApproveLinkTitle = "" />
				</CFIF>

				<cfif disabledApproveLink eq 0>
					<!----- Disable the link and when the billback is being modify agreed to by another user  ----->
					<cfif CheckCopiedBB.BB_Modify_Agree EQ 1 and CheckCopiedBB.BB_Modify_Agree_User NEQ request.AccessStructure.user_id>
						<cfset disabledApproveLink = 1 />
						<cfset disabledApproveLinkLabel = "Click Here to Begin Approval Process" />
						<cfset disabledApproveLinkTitle = "Billback is being modified by #CheckCopiedBB.user_name#" />
					</cfif>
				</cfif>

				<CFIF disabledApproveLink eq 1>
					<TD ID="TD_Approve_Link" ALIGN="right" BGCOLOR="Gray" STYLE="font-size: 15px; font-weight: bold; color:white" title="#disabledApproveLinkTitle#" NOWRAP >
					&nbsp;&nbsp;&nbsp;
					#disabledApproveLinkLabel#
					&nbsp;&nbsp;&nbsp;
					</TD>
				<CFELSE>
					<TD ID="TD_Approve_Link" ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: pointer;" <cfif CheckCopiedBB.Auto_Billback eq 1>ONCLICK="BeginAutoBBApprovalProcess();"<cfelse><cfif CheckCopiedBB.BB_Modify_Agree EQ 1 and CheckCopiedBB.BB_Modify_Agree_User NEQ request.AccessStructure.user_id>ONCLICK="modify_agreeaproval()"<cfelse><CFIF CheckCopiedBB.Negative_Billback EQ 1>ONCLICK="BeginNegativeBillbackApprovalProcess()"<CFELSE>ONCLICK="BeginApprovalProcess()"</CFIF></cfif></cfif>>
						&nbsp;&nbsp;&nbsp;
						<CFIF IsAgreed EQ 0>
						Click Here to Begin Approval Process
						<CFELSE>
						Agreed
						</CFIF>
						&nbsp;&nbsp;&nbsp;
					</TD>
				</CFIF>
			</CFIF>

			<CFIF APVL_Contract_Status EQ 8 AND DisAllowAccessBasedOnLockStatus EQ 0 AND appSettings.getBBDisplayResubmit()>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: pointer;">
					<A Href="bb_resubmit_1.cfm?BBID=#Billback_ID#">Click here to resubmit this billback</A>
				</TD>
			</CFIF>
	</TR>
	</TABLE>

	<cfif CheckCopiedBB.CopiedBB NEQ "" AND CheckCopiedBB.VolumeRateSaved EQ 0>
	<font color="red" size="+1">This billback has items without rates or extended amounts. You must add those to be able to request approval for this billback.</font>
	</cfif>

</CFOUTPUT>

<br>
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<div class="customContainer" style="display:none;"></div>
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->

<!--- </blockquote> --->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!---
	END STATUS
 --->
<!--- MOVED TO LINE 10..SEEMS OK....
<cfset local_bbid = Billback_ID>
<cfinclude template="bb_menu_stats.cfm"> --->

<!---TSF - Label 13068: If the billback is being unlocked then use the temp cache file if it exists. Otherwise run the code to build Billback Summary page--->
<cfif url.bb_lock_action and fileexists("#Application.Doc_Path#\Temp_Files\Billback\Summary_#sBillbackViewCacheFileName#")>

	<cfinclude template="#Application.Doc_Mapping#/Temp_Files/Billback/Summary_#sBillbackViewCacheFileName#" />

<cfelse>

<cfparam name="Show_Details" default="0">
<!--- 	<cfset url.show_edit_link = 1 /> --->
	<cfif Show_Details IS 1>
		<cfset ShowDetails = Show_Details>
	<cfelse>
		<cfset ShowDetails = 0>
	</cfif>

	<CFSAVECONTENT VARIABLE="Billback.Summary_Content">
		<CFINCLUDE TEMPLATE="Billback_Summary_Content.cfm">
	</CFSAVECONTENT>

	<cfsavecontent variable="variables.bbSummaryContent">

		<CFOUTPUT>#Replace(Billback.Summary_Content, "<cfif len(trim(Get_Billback_Info.Comments)) GT 0><TR style=""display:none;""><TD></TD></TR>", "<TR><TD nowrap ID=""cellLabel"">Comments:<BR><span style=""color:red;font-size:10px;"">only visible internally</span></TD><TD valign=""top"">#Get_Billback_Info.Comments#</TD></TR><cfelse> </cfif>")#</CFOUTPUT>

	</cfsavecontent>

	<cflock timeout="10" type="exclusive">
		<cffile action="write" nameconflict="OVERWRITE" file="#Application.Doc_Path#\Temp_Files\Billback\Summary_#sBillbackViewCacheFileName#" output="#variables.bbSummaryContent#">
	</cflock>

	<!---strip out the edit link for display--->
	<cfset variables.bbSummaryContent = REReplaceNoCase(variables.bbSummaryContent, "<removeforemail>[\s\S]*?</removeforemail*>", "", "ALL") />
	<cfset Billback.Summary_Content = REReplaceNoCase(Billback.Summary_Content, "<removeforemail>[\s\S]*?</removeforemail*>", "", "ALL") />

	<cfoutput>#variables.bbSummaryContent#</cfoutput>

	<cfif ShowDetails NEQ 0>
	<cflock timeout="10" type="exclusive">
		<cffile action="write" nameconflict="OVERWRITE" file="#Application.Doc_Path#\Temp_Files\Billback\#sBillbackViewCacheFileName#" output="<html>#Billback.Summary_Content#</html>">
	</cflock>
	</cfif>

</cfif>

	<CFSET Status_Value = getBillbackInformation.Billback_Status_ID>
	<cfswitch expression="#Status_Value#">
		<cfcase value="1"><!--- IS WIP NEXT RFA --->
			<CFSET Status_Value = 2>
		</cfcase>
	</CFSWITCH>

	<cfoutput>
		<form action="Billback_Approval_Action.cfm" method="post" name="ApprovalForm" id="ApprovalForm">
			<input type="Hidden" name="Billback_ID" value="#Billback_ID#">
			<input type="Hidden" name="Status_Value" value="#Status_Value#">
		</FORM>
	</cfoutput>

<!--- moved up to line 228...or so
<cfset local_bbid = Billback_ID>
<cfinclude template="bb_menu_stats.cfm"> --->
<script>
	if(window.parent.summary_tab)
	{
		window.parent.current_menu_item = "summary";
		window.parent.assignActiveTab();
		window.parent.buildMenu();
	}
</script>

<cfset bblock.bb_id 				= local_bbid>
<cfset bblock.user_id_bb_locker 	= request.AccessStructure.user_id>
<cfset bblock.relocate_ability 		= "0">
<cfinclude template="billback_locker.cfm">
<!---Added view/hide operators--->
<cfinclude template="/common_files/jQuery.cfm">
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<cfinclude template="/Common_Files/noty.cfm">
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->

<script type="text/javascript" src="/script/javascript/ajax_js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common_files/scripts/showhide.js"></script>

<script type="text/javascript">
	// BSD D11544
     var url = '<cfoutput>#lcase(cgi.script_name)#</cfoutput>';
   if (url == '/billbacks/capture/billback_summary.cfm' || url == '/billbacks/capture/billback_summary_content.cfm')
   {
       try { window.parent.dyniframesize(); } catch (err) { };
   }
  // override bsa common cookie prefix
	constant.cookie = 'bbs_';
	<!---these IDs are defined in \billbacks\capture\Billback_Summary_Content.cfm--->
	setupHideShow( 'toggleOperators', 'eligibleOperators' );
</script>
<script>
	<!--- 50922 adjust columns heading table width (top) to be the same as the programs/products content table width (bottom)
				:: this is due to the vertical scrolling bar added automatically by the browser on the bottom table --->
	<cfif not structKeyExists(request, "print_or_email")>
		jQuery('#programsproducts-top').css("width", jQuery('#programsproducts').css("width") );
	</cfif>
	<!--- remove manual reject option after billback becomes manual rejected --->
	<cfif getBillbackInformation.Billback_Status_ID eq '9'>
		$(top.frames["mywindowname"].document.getElementById('manual_reject_tab')).hide();
	</cfif>
</script>
</BODY>
</html>
