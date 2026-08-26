<HTML>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" RIGHTMARGIN="0" BOTTOMMARGIN="0"style="margin:0; border: 0px; background-color:transparent" allowTransparency="true">
<HEAD>
	<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
</HEAD>
<cfif NOT isDefined("billbackSettingsManager")>
	<cfset billbackSettingsManager = CreateObject("component", "components.billback.BillbackSettingsManager") />
</cfif>
<cfset Default_sort_columns = billbackSettingsManager.getDefaultSortOptions()>
<cfset Default_sort_option_for_Scorecard = Default_sort_columns.Default_sort_option_for_Scorecard />
<cfset Default_Sort_By 					= Default_sort_columns.Default_Sort_By />

<cfparam name="form_submitted" 						default="0">
<cfparam name="transactiontype" 					default="release">
<cfparam name="url.startrow" 						default="1">
<cfparam name="url.frompage" 						default="1">
<cfparam name="form.startrow" 						default="#url.startrow#">
<cfparam name="form.frompage" 						default="#url.frompage#">
<cfparam name="form.sortby" 						default="#Default_sort_option_for_Scorecard#">
<cfparam name="form.sortorder" 						default="#Default_Sort_By#">
<cfparam name="url.sortby" 						default="#form.sortby#">
<cfparam name="url.sortorder" 						default="#form.sortorder#">
<cfparam name="form.masspaybillbacklist" 				default="">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!----- D43149 ::  Billback Payment Request Tab Format----->
<cfinclude template="/actionFormat.cfm">
<cfset businessSegmentsMgr = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentSettings = businessSegmentsMgr.getEnabled() />
<cfset businessSegmentsOn = businessSegmentSettings.Display_Segment_In_Billbacks>
<!----- D43149 ::  Billback Payment Request Tab Format----->

<cfinclude template="/billbacks/scorecard/billback_status_tool_tip.cfm" />
<cfoutput>#billbackStatusToolTip#</cfoutput>
<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("popupInit();")
function initTheTooltip()
{
	popUp(-1)
}

</SCRIPT>
<cfset count = 0>

<!--- Dev Note: Milan (20463) - I copied the code from sc_payment_request.cfm. Now other clients also want to switch
between hold/release payment request.Earlier, we only had a checkbox, which when clicked used to approve (release)
payment request, but a user could not switch back to hold. It was a one- time action only.
--->
<cfoutput>
<cfif Form_Submitted EQ 1 >

		<cfif (TransactionType EQ "Release" OR TransactionType EQ "Hold")>
			<!--- "BBToBeReleasedList" is populated, when the user sets billbacks to released,
			by selecting the billbacks using checkbox.
			Note: When a user clicks on "release" link to "release" billbacks, "TransactionType=Release" is passed
			in the url, but while using the checkbox feature, I do not need to use "TransactionType" because the
			default "TransactionType" is "release".
			--->
			<cfif IsDefined("BBToBeReleasedList")>
				<cfif BBToBeReleasedList neq "">
					<cfset EligibleBBList = Replace(BBToBeReleasedList,'"','','ALL')>
				<cfelse>
			<!--- "billback_id" is populated, when the user sets billbacks to released,
			by clicking on the "release" link.
			--->
					<cfset EligibleBBList = billback_id>
				</cfif>
			<cfelse>
			<!--- "billback_id" is populated when the user sets billbacks to released,
			by clicking on the "release" link.
			--->
				<cfset EligibleBBList = billback_id>
			</cfif>
		</cfif>

		<CFQUERY name="UpDateBillback" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback
				SET 	BB_Payment_Request_Approved = <cfif TransactionType EQ "Release" OR TransactionType EQ "ReleaseAll">1<cfelse>0</cfif>,
						BB_Payment_Request_Approved_Date = <cfif TransactionType EQ "Release" OR TransactionType EQ "ReleaseAll">getdate()<cfelse>NULL</cfif>,
						BB_Payment_Request_Approved_By = <cfif TransactionType EQ "Release" OR TransactionType EQ "ReleaseAll">'#Request.AccessStructure.User_ID#'<cfelse>NULL</cfif>
				WHERE	Billback_ID IN (#listqualify(EligibleBBList, "'")#)
		</CFQUERY>

		<cfif TransactionType EQ "Release" OR TransactionType EQ "ReleaseAll">

			<CFLOOP index = "BBID_ForPrinting" list = "#EligibleBBList#">
				<script>
					NewWindow('/billbacks/common/bb_printer_friendly.cfm?BBID=#BBID_ForPrinting#','name','1000','600','Yes', 'No');
				</script>
			</CFLOOP>

		</cfif>

		<cfif TransactionType EQ "Release" OR TransactionType EQ "Hold">
			<CFLOCATION URL="SC_Payment_Request_VendorOnly.cfm?StartRow=#form.StartRow#">
		<cfelse>
			<CFLOCATION URL="SC_Payment_Request_VendorOnly.cfm" ADDTOKEN="No">
		</cfif>

	</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Select billback that are ready to be signed for payment --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</cfoutput>

<cfset startrow = form.startrow>
<cfset frompage = form.frompage>

<cf_Number_of_Rows maxrows=100>

<cfif Form_Submitted NEQ 1>
	<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
		 <divstyle="width:95%;height:5px;">&nbsp;</div>
		 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
		 <divstyle="width:95%;height:5px;">&nbsp;</div>
	</SPAN>

	<CFFLUSH>

	<SCRIPT>
		document.all.PleaseWaitMessage.style.display='none';
	</SCRIPT>

	<!---How the data is sorted--->
	<cfset sql_Sort_By="Billback.BB_title">
	<CFSWITCH expression="#URL.SORTBY#">
		<!---Payable number--->
		<CFCASE value="BBI">
			<cfset sql_Sort_By="Billback.BB_Code">
		</CFCASE>
		<!---Billback number--->
		<CFCASE value="BBNUM">
			<cfset sql_Sort_By="Billback.BB_Reference">
		</CFCASE>
		<!---Billback title--->
		<CFCASE value="BBT">
			<cfset sql_Sort_By="Billback.BB_title">
		</CFCASE>
		<!---Billback title--->
		<CFCASE value="Pay">
			<cfset sql_Sort_By="Customer_Name">
		</CFCASE>
		<!---Billback Date--->
		<CFCASE value="BBD">
			<cfset sql_Sort_By="dbo.Billback.BB_Date">
		</CFCASE>
		<!--- Amount--->
		<CFCASE value="PR_A">
			<cfset sql_Sort_By="Tot_Amount">
		</CFCASE>
		<!--- Amount--->
		<CFCASE value="PR_STATUS">
			<cfset sql_Sort_By="Signed">
		</CFCASE>
		<!--- Start Date --->
		<CFCASE value="BBSD">
			<cfset sql_Sort_By="Billback.BB_Start_Date">
		</CFCASE>
		<CFCASE value="BBED">
			<cfset sql_Sort_By="Billback.BB_End_Date">
		</CFCASE>
		<CFCASE value="BBAMT">
			<cfset sql_Sort_By="Billback.BB_Amount">
		</CFCASE>
		<CFCASE value="BBREFN">
            <cfset sql_Sort_By="Billback.referenceNum">
		</CFCASE>
		<CFCASE value="Analyst">
            <cfset sql_Sort_By="BBanalyst.Name_first">
        </CFCASE>
		<CFCASE value="Segment">
            <cfset sql_Sort_By="business_unit_desc">
		</CFCASE>
	</CFSWITCH>

	<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">

	<cfif URL.SORTORDER EQ "DESC">
		<cfset sql_Sort_By="#sql_Sort_By# DESC">
	<cfelse>
		<cfset sql_Sort_By="#sql_Sort_By# ASC">
	</cfif>

	<!--- setting to check whether the Sales Tax info is required --->
		<cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnVariable="ShowSalesTax">

	<CFQUERY name="Get_Data" DATASOURCE="#Application.Datasource#">
		#PreserveSingleQuotes(AllowBillbackIDs)#

		<cfif UserIsAnalyst AND AnalystList NEQ "">
		#PreserveSingleQuotes(AllowAnalystIds)#
		</cfif>

		<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

		DECLARE @Profile_Forbidden_Template table
		(
			Template_ID   int          NOT NULL,
			Forbid_Access_Type int          NOT NULL
		)
		INSERT INTO @Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
		select 	distinct template_id, Forbid_Access_Type
		from 	Profile_Forbidden_Template
		where 	Deleted = 0
				AND Forbid_Type = #forbidType#
				AND profile_id = #Get_Profile_Settings.Profiles_ID#

		SELECT 		DISTINCT
					Billback.Billback_ID,
					Billback.BB_Code,
					Billback.BB_Date,
					Billback.BB_Start_Date,
					Billback.BB_End_Date,
					Billback.BB_Amount,
					Billback.BB_Reference,
					CASE
						WHEN Billback.Billback_Payee_Type_ID=1 THEN
						ISNULL(BSA_Foodservice_Customers.Name,VM.Vendor_Name)

						WHEN Billback.Billback_Payee_Type_ID=2 THEN
						BSA_Operator.Operator_Name

						WHEN Billback.Billback_Payee_Type_ID=3 THEN
						BSA_Foodservice_Brokers.Broker_Name

						WHEN Billback.Billback_Payee_Type_ID=4 THEN
						Billback_Unidentified_Payee.BB_UP_Name

						WHEN Billback.Billback_Payee_Type_ID=5 THEN
						Billback_Distributor.BB_Distributor_Name

						WHEN Billback.Billback_Payee_Type_ID=6 THEN
						Billback_Operator.BB_Operator_Name

						WHEN Billback.Billback_Payee_Type_ID=7 THEN
						Billback_Broker.BB_Broker_Name

					END AS Customer_Name,
					BB_title,
					Billback.BB_Amount Claimed_Amt,
					Paid_Amount Tot_Amount,
					ISNULL(ROUND(Billback.TotalTaxAmount,2),0) TotalTaxAmount,
					Round(BB_Approved.Paid_Amount,2)+ISNULL(ROUND(Billback.TotalTaxAmount,2),0) AmountToPay,
					1 AS Payment_Type,
					'' AS Check_Issued,
					BB_Payment_Request_Prepared_Date Prepared_Date,
					aaa.Name_First Prepared_By_First_Name,
					aaa.Name_Last Prepared_By_Last_Name,
					BB_Payment_Request_Approved Signed,
					BB_Payment_Request_Approved_Date Signed_Date,
					_Users.Name_First Signed_By_First_Name,
					_Users.Name_Last Signed_By_Last_Name,
					Billback.Billback_Status_ID,
					Billback.BB_Payment_Request_Sent,
					Billback.BB_Payment_Request_Sent_On,
					Billback.BB_Received_Ack_Type,
					Billback.BB_Received_Ack_Date,
					BB_Approved.Voucher_Number,
					<!--- Dev Note: 43559. We needed "Payment_Request_Approved" to be ON for
					clients who do not use "GL Code allocation".
					--->
					<cfif application.returned_customer_setting.Show_BB_Payment_GLCode>
					ISNULL(Gl_Code_Allocation.Approved, 0) as Payment_Request_Approved,
					<cfelse>
					1 As Payment_Request_Approved,
					</cfif>
					Billback.referenceNum,
					BBanalyst.Name_first as BBanalyst_Name_first,
					BBanalyst.Name_last as BBanalyst_Name_last,

            <cfif businessSegmentsOn>
                isnull((select top 1 business_unit_desc from business_segment where Business_Segment_ID in ( select top 1 Business_Segment_ID from contract_main where contract_main_id in (select top 1 program_id from billback_program where billback_program.billback_id = billback.billback_id))),'Unassigned')
            <cfelse>
                ''
            </cfif> as business_unit_desc
		,Billback_Closing_Methods.vchBillback_Closing_Method_Desc
		,Billback_Closing_Methods.Abbreviation
		,Billback.Deviated

		FROM 		Billback
		LEFT JOIN	Billback_Allied
		ON (Billback_Allied.Billback_ID = Billback.Billback_ID)
		LEFT JOIN 	( Billback_Broker LEFT JOIN BSA_Foodservice_Brokers ON (Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID)) ON ((Billback_Broker.Billback_ID = Billback.Billback_ID) AND ((Billback.Billback_Payee_Type_ID = 3) OR (Billback.Billback_Payee_Type_ID = 7)) AND (Billback_Broker.Deleted = 0))
		LEFT JOIN 	( Billback_Distributor LEFT JOIN BSA_Foodservice_Customers ON (Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)) ON ((Billback_Distributor.Billback_ID = Billback.Billback_ID) AND ((Billback.Billback_Payee_Type_ID = 1) OR	(Billback.Billback_Payee_Type_ID = 5)) AND (Billback_Distributor.Deleted = 0))
		LEFT JOIN 	( Billback_Operator LEFT JOIN BSA_Operator ON (Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)) ON ((Billback_Operator.Billback_ID = Billback.Billback_ID) AND ((Billback.Billback_Payee_Type_ID = 2) OR (Billback.Billback_Payee_Type_ID = 6)) AND (Billback_Operator.Deleted = 0))
		LEFT JOIN 	Billback_Unidentified_Payee ON ((Billback_Unidentified_Payee.Billback_ID = Billback.Billback_ID) AND (Billback.Billback_Payee_Type_ID = 4) AND (Billback_Unidentified_Payee.Deleted = 0))
		LEFT JOIN Vendor_Master VM
		ON 	VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
		LEFT JOIN	BB_Approved
		ON BB_Approved.Billback_ID = Billback.Billback_ID
		LEFT JOIN 	Gl_Code_Allocation
		ON Gl_Code_Allocation.Billback_ID = Billback.Billback_ID
		AND Gl_Code_Allocation.Deleted = 0
		LEFT JOIN	_Users
		ON _Users.User_ID = Billback.BB_Payment_Request_Approved_By
		AND _Users.Deleted = 0
		LEFT JOIN 	_Users aaa
		ON aaa.User_ID = Billback.BB_Payment_Request_Prepared_By
		AND aaa.deleted = 0

		LEFT JOIN _users BBanalyst
        ON BBanalyst.User_ID = Billback.Analyst_User_ID

 		LEFT JOIN Billback_Closing_Methods
        ON  Billback.BB_Closing_Method = Billback_Closing_Methods.iBillback_Closing_Method_ID

		WHERE	Billback_Status_ID = 4
		AND 	Billback.Deleted = 0
		<!---TSF: Label 9639 - Removed Billback.BB_Payment_Request_Prepared = 1 so counts will match the counts on the home page--->
		AND 	(
				Billback.BB_Creator_ID = '#request.AccessStructure.User_ID#'
				<cfif UserIsAnalyst EQ 0>
					OR Billback.BB_Creator_User_Position_ID IN (#PreserveSingleQuotes(UserPositionList)#)
					<cfif listlen(BillbackIDs) GT 0>
					OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
					</cfif>
				<cfelse><!------ If billback analyst do not look at the position tree, use the analyst logic alone ----->
					<cfif AnalystList NEQ "">
					OR	Billback.Analyst_User_ID IN (#PreserveSingleQuotes(AnalystList)#)
					OR	Billback.BB_Creator_ID IN (#PreserveSingleQuotes(AnalystList)#)
					</cfif>
				</cfif>
			)
			AND NOT EXISTS
		(
			SELECT Billback_ID
			FROM Billback_Program
			INNER JOIN Contract_Main
			ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
			WHERE Billback_Program.Billback_ID = Billback.Billback_ID
			AND Billback_Program.Deleted = 0
			AND Contract_Main.ProgramType_ID
			<cfif forbidType EQ 0>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
			in
			<!--- (Forbid_Access_Type = 1 means 'Access') --->
			(select Template_ID from @Profile_Forbidden_Template WHERE Forbid_Access_Type = 1)
		)
		<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
				<!--- If the below profile settings is on, then the user should only be allowed to see programs
			that have him/her as an RSP OR where the program creator's RSP has the user number same as
			this user's User number
		--->
		AND NOT EXISTS
		(
			<cfset programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
			<cfset qUserNumber = "" />
			<cfif appSettings.getUserNumberRestrict()>
				<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(programScorecardRestrictCreatedByUserId) />
				<cfset qUserNumber = qUser.User_Number />
			</cfif>
			SELECT Billback_ID
			FROM Billback_Program
			INNER JOIN Contract_Main
			ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
			LEFT JOIN _Users responsibleSalesPerson
			ON 	responsibleSalesPerson.User_ID = Contract_Main.Responsible_User_ID
			AND	responsibleSalesPerson.Deleted = 0
			WHERE Billback_Program.Billback_ID = Billback.Billback_ID
			AND Billback_Program.Deleted = 0
			AND(
			Isnull(rtrim(ltrim(Contract_Main.Responsible_User_ID)),'') != '#programScorecardRestrictCreatedByUserId#'
				<cfif Len(qUserNumber) GT 0>
			AND Isnull(rtrim(ltrim(responsibleSalesPerson.User_Number)),'') != '#qUserNumber#'
				</cfif>
			)
		)
		</cfif>
		ORDER BY 	#sql_Sort_By#
	</CFQUERY>

	<cfset ListofBBInHoldStatus = "">

	<!---- When the user selects "check all" option for "release selected billbacks" feature, we need to select all the billbacks
	which have a checkbox available for "release", even though the billbacks are in different pages and so all records with
	a checkbox on page,1,2,3 etc should be selected. "AllMassReleaseBillbackList" below stores all the billbacks which could
	be released by the user."BBToBeReleasedList" below stores all the billbacks which are selected by the user to be released.
	--->
	<cfif appSettings.getBBPaymentRequestHoldRelease() eq 1>
			<cfloop query="Get_data">
				<cfinclude template = "Permit_Approval.cfm">
				<cfif Get_Data.Payment_Request_Approved eq 1 AND Get_Data.Signed EQ 0 AND Permit_Approval EQ 1>
					<cfset ListofBBInHoldStatus = ListAppend(ListofBBInHoldStatus,Get_data.billback_id)>
				</cfif>
			</cfloop>
	</cfif>

	<CFINCLUDE TEMPLATE="/Billbacks/scorecard/billback_Table_Measures.cfm">


	<form name="Status_Change" action="/GL_Code/GL_Code_In_Billback/Payment_Request/SC_Payment_Request_VendorOnly.cfm" method="POST" style="DISPLAY:INLINE;">
	<input type="Hidden" name="Form_Submitted" value="0">
	<input type="hidden" name="BBToBeReleasedList" id="BBToBeReleasedList">
	<CFOUTPUT>
	<input type="hidden" name="AllMassReleaseBillbackList" id="AllMassReleaseBillbackList" value="#ListofBBInHoldStatus#">
	<table BORDER="0" width="#table_width#" CELLSPACING="0" CELLPADDING="2" CLASS="Maintable">
	</CFOUTPUT>
	<cfset Pay_Multi_Billbacks_IDs = "" />
	<CFOUTPUT QUERY="Get_data" startrow="#StartRow#" maxrows="#MaxRows#">
		<cfset BillbackReplaced = Replace(get_Data.Billback_ID,"-","_","all")/>

		<TR BGCOLOR="#IIf(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<!---D43444	 :: Billback scorecard alignment changes for payment request --->
			<!---Status --->
			<TD nowrap  WIDTH="62" valign="middle">
			&nbsp;#getBBStatusImageString(Get_Data.Billback_Status_ID)#
			</TD>
			<!--- Type/Dev --->
			<TD nowrap  WIDTH="62" valign="top">
				<span title="#vchBillback_Closing_Method_Desc#">
					#Abbreviation#
				</span>
				<br>
				<CFIF Deviated EQ 1>
					<CFIF application.returned_customer_setting.Customer_Keyword EQ "Mccain">
					<cfset  deviation_heading  = "VAR" />
					<cfset 	deviation_desc  = "Claim Variance" />
					<CFELSE>
					<cfset  deviation_heading  =  "DEV" />
					<cfset 	deviation_desc  = "Deviation" />
					</CFIF>
					<span title="#deviation_desc#">
						#deviation_heading#
					</span>
				</CFIF>
			</TD>
			<!---D43444	 :: Billback scorecard alignment changes for payment request --->
			<!--- Billback Number/Preview --->
			<td nowrap width="#Evaluate(PR_Number_Width - 10)#">

				<cfif payment_type eq 1>
					<cfset BBurl = "/Billbacks/capture/index.cfm?BBID=#Billback_ID#"/>
				<cfelse>
					<cfset BBurl = "/Billbacks/Multi_BB_Payment/Distributor_And_BB_Form.cfm?BBID=#Billback_ID#&Pay_Multi_Billbacks_ID=#Pay_Multi_Billbacks_ID#&Payment_Data_Export_1_ID=#Payment_Data_Export_1_ID#"/>
				</cfif>

				<a target="_parent" href="#BBurl#" title="view billback #BB_Code#">
					#ActionText(BB_Code)#<br>
				</a>

				<CFQUERY name="Check_Lock" DATASOURCE="#Application.Datasource#">
						SELECT 		BB_Is_Locked,Name_First, Name_Last
						FROM 			Billback_Allied
						INNER JOIN	_Users
						ON _Users.User_ID = Billback_Allied.BB_Locked_By_User_ID
						AND _Users.Deleted=0
						WHERE Billback_ID = '#Billback_ID#'
				</CFQUERY>
				<a href="/billbacks/capture/bb_preview.cfm?BBID=#Billback_ID#"style="color:RGB(0,0,0)" id="previewlink" target="preview_window">preview</a><br />
				<a href="javascript:void(0)" onClick="javascript:openDetails('#Billback_ID#')" style="color:RGB(0,0,0)" id="detailslink">details</a>

			<cfif Check_Lock.BB_Is_Locked EQ 1>
				<img src="/images/lock.gif" title="This billback is currently being viewed by #Check_Lock.Name_First# #Check_Lock.Name_Last#" height="16" width="12">
			<cfelse>
				<img src="/images/fill.gif" width="12" border="0">
			</cfif>

			<cfif Billback_Status_ID EQ 4 AND BB_Payment_Request_Sent EQ 1>
				<cfset BB_Payment_Request_Sent_Date = "#DateFormat(BB_Payment_Request_Sent_On, "mm/dd/yyyy")# #TimeFormat(BB_Payment_Request_Sent_On, "hh:mm:ss tt")#" />
				<cfset BB_Received_Ack_Date_Str = "#DateFormat(BB_Received_Ack_Date, "mm/dd/yyyy")# #TimeFormat(BB_Received_Ack_Date, "hh:mm:ss tt")#" />
				<cfif BB_Received_Ack_Type EQ 0>
					<img src="/images/arrow1.gif" width="10" height="10" title="This billback is being sent to ERP #chr(13)##chr(10)#Send Date: #BB_Payment_Request_Sent_Date#">
				<cfelseif BB_Received_Ack_Type EQ 1>
					<img src="/images/arrow2.gif" width="10" height="10" title="This billback has been successfully loaded in ERP #chr(13)##chr(10)#Send Date: #BB_Payment_Request_Sent_Date# #chr(13)##chr(10)#Acknowledge Date: #BB_Received_Ack_Date_Str# #chr(13)##chr(10)#Voucher Number: #Voucher_Number#">
				<cfelseif BB_Received_Ack_Type EQ 2>
					<img src="/images/arrow1_red.gif" width="10" height="10" title="This billback failed to get loaded in ERP #chr(13)##chr(10)#Send Date: #BB_Payment_Request_Sent_Date# #chr(13)##chr(10)#Acknowledge Date: #BB_Received_Ack_Date_Str#">
				<cfelse>
					<img src="/images/fill.gif" width="12" border="0">
				</cfif>
			<cfelse>
				<img src="/images/fill.gif" width="12" border="0">
			</cfif>
			</td>

			<!--- Billback/Date/Reference Number --->
			<td nowrap width="#Evaluate(PR_BBD_Width + PR_BB_Width + 10)#" title="Billback Number: #BB_Reference#">
					#dateformat(BB_Date, 'mm/dd/yyyy')#<BR>
					<cfset display_title=Left(BB_Reference, PR_Ref_Num_Len)>
					<cfif LEN(display_title) LT Len(BB_Reference)>
						<cfset display_title="#display_title#...">
					</cfif>
					<cfif len(trim(display_title)) EQ 0>
						<cfset display_title=" ">
					</cfif>
			 		#HTMLEditFormat(display_title)#<br>
					#referenceNum#
			</td>
			<!---Payee/Title --->
			<td nowrap width="#Evaluate(PR_Title_Width + PR_Payee_Width - 5)#" title="Payee: #Customer_Name##chr(13)# title: #HTMLEditFormat(BB_title)#">
					<cfset display_title=Left(Customer_Name, PR_Payee_Len)>
					<cfif LEN(display_title) LT Len(Customer_Name)>
						<cfset display_title="#display_title#...">
					</cfif>
					<cfif len(trim(display_title)) EQ 0>
						<cfset display_title=" ">
					</cfif>
			 		#HTMLEditFormat(display_title)#<BR>

					<cfset display_title=Left(BB_title,PR_title_Len)>
					<cfif LEN(display_title) LT Len(BB_title)>
						<cfset display_title="#display_title#...">
					</cfif>
					<cfif len(trim(display_title)) EQ 0>
						<cfset display_title=" ">
					</cfif>
			 		#HTMLEditFormat(display_title)#
			</td>

			<!--- Status --->
	<!--- Look for hold/release app setting --->
	<cfif appSettings.getBBPaymentRequestHoldRelease() eq 1>
			<td width="#Evaluate(PR_Status_Width - 15)#">
				<cfinclude template = "Permit_Approval.cfm">
					<!--- Dev Note: Milan (20463) - I copied the code from sc_payment_request.cfm. Now other clients also want to switch
					between hold/release payment request.Earlier, we only had a checkbox, which when clicked used to approve (release)
					payment request, but a user could not switch back to hold. It was a one- time action only.
					--->
				<cfif Payment_Request_Approved EQ 0>
						<!--- D13342: If the payement request is not yet approved do not give hold/release options, user will need to go inside the billback, lock it and approve the payment request --->
						&nbsp;
				<cfelse>
						<!--- which status is this payment request in --->
						<cfif Signed EQ 0>
								<cfif Permit_Approval EQ 1>
									<span title="Select billback for 'release'">
										<input type="checkbox" class="chkHold" value="#Billback_ID#" id="chkHold_#BillbackReplaced#" />
									</span>
										<font size="1"style="font-weight:bold">
											HOLD
										</font>
										<br>
										<a href="SC_Payment_Request_VendorOnly.cfm?Billback_ID=#Billback_ID#&TransactionType=Release&Form_Submitted=1&StartRow=#Startrow#">
										release
										</a>
								<cfelse>
										<font size="1"style="font-weight:bold">
											HOLD
										</font>
								</cfif>
						<cfelseif Signed EQ 1 AND Check_Issued NEQ 1>
								<cfif Permit_Approval EQ 1>
										<a href="SC_Payment_Request_VendorOnly.cfm?Billback_ID=#Billback_ID#&TransactionType=Hold&Form_Submitted=1&StartRow=#Startrow#">
										hold
										</a><br>
										<font size="1"style="font-weight:bold">
											RELEASE
										</font>
								<cfelse>
										<font size="1"style="font-weight:bold">
											RELEASE
										</font>
								</cfif>
						<cfelseif Signed EQ 1 AND Check_issued EQ 1>
								RELEASED
						</cfif>
				</cfif>
			</td>
	</cfif>
			<!--- Start Date/ End Date --->
			<td width="#Evaluate(PR_Prepared_By -20)#">
					#DateFormat(BB_Start_Date, "mm/dd/yyyy")#&nbsp;	<BR>
					#DateFormat(BB_End_Date, "mm/dd/yyyy")#&nbsp;
			</td>
			<!--- Amount --->
			<td width="#Evaluate(PR_Amount_Width + 20)#">
					#DOLLARFORMAT(BB_Amount)#<BR>
					#DOLLARFORMAT(Tot_Amount)#
			</td>
			<!--- Segment/Analyst --->
			<td width="#PR_Approved_By#">&nbsp;
				<cfif len(BBanalyst_Name_First) or len(BBanalyst_Name_Last)>
						#BBanalyst_Name_First# #BBanalyst_Name_Last#
				<cfelse>
						No Analyst
				</cfif>
			<cfif businessSegmentsOn>
				<cfset maxBusinessSegmentLen = 10 >
				<br>&nbsp;<cfif len(business_unit_desc) GT maxBusinessSegmentLen>#left(business_unit_desc,maxBusinessSegmentLen)#...<cfelse>#business_unit_desc#</cfif>
			</cfif>


			</td>
			<!--- ................................................................................................................... --->
			<!--- IF BBManualSetPaidStatus QUICK  appSettings.Mass_Pay_Billback   ................................................... --->
			<!--- D32285 : Manually Set BB Status to Paid 			................................................................. --->
			<!--- ................................................................................................................... --->
			<cfif NOT isDefined("Get_Profile_Settings.Mass_Billback_Pay")>
				<cfset useLakebaseForGet_Profile_Settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_profiles_settings")>
<cfif useLakebaseForGet_Profile_Settings>
	<cftry>
		<cfset Get_Profile_Settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_profiles_settings", {
				"profiles_id" = "eq.#request.AccessStructure.Profiles_ID#",
				"select" = "mass_billback_pay,bb_approve"
			}), "mass_billback_pay,bb_approve"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Profile_Settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Profile_Settings>
<cfquery name="Get_Profile_Settings" datasource="#application.datasource#">
					SELECT Mass_Billback_Pay, BB_Approve
					FROM BB_Profiles_Settings
					WHERE Profiles_ID = 	'#request.AccessStructure.Profiles_ID#'
				</cfquery>
</cfif>
			</cfif>

			<cfif appSettings.Mass_Pay_Billback IS 1>
				<cfset Status_to_Show = 4>
			</cfif>
			<cfif appSettings.Mass_Pay_Billback IS 2>
				<cfset Status_to_Show = 2>
			</cfif>

		<cfif Get_Profile_Settings.Mass_Billback_Pay IS 1 AND appSettings.Mass_Pay_Billback IS NOT 0 AND Get_Profile_Settings.BB_Approve IS 1 AND Billback_Status_ID IS Status_to_Show>
		<!---Let's see if the billback has a program which has mass pay turned on -- all programs on billback must be created with a template that has mass payment --->
				<cfset ShowMassPay = 0>
				<cfquery name="GetTemplateSettingsForBillbackPrograms" datasource="#application.datasource#">
						SELECT Distinct Program_Control_Panel_Options.Mass_Billback_Pay
						FROM					Program_Control_Panel_Options
						INNER JOIN 		Contract_Main
						ON 						Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
						INNER JOIN 		Billback_Program
						ON 						Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
						AND 					Billback_Program.Deleted = 0
						AND 					Billback_Program.Billback_ID = '#Billback_ID#'
				</cfquery>

				<cfif GetTemplateSettingsForBillbackPrograms.Recordcount IS 1>
					<cfif GetTemplateSettingsForBillbackPrograms.Mass_Billback_Pay IS 1>
						<cfset ShowMassPay = 1>
					</cfif>
				</cfif>
				<!--- Mass Pay Check box --->
				<cfif ShowMassPay IS 1>
					<td width="15">
						<span title="Update Billback to Paid Status">
							<input type="checkbox" class="chkPaid" value="#Billback_ID#" id="chkPaid_#BillbackReplaced#" <cfif listfind(form.massPayBillbackList,Billback_ID) GT 0>CHECKED</cfif>/>
						</span>&nbsp;&nbsp;&nbsp;
					</td>
				<cfelseif Get_Profile_Settings.Mass_Billback_Pay IS 1 AND appSettings.Mass_Pay_Billback IS NOT 0 AND Get_Profile_Settings.BB_Approve>
					<td width="15">&nbsp;&nbsp;</td>
				</cfif>
		<cfelse>
				<td width="15">&nbsp; </td>
		</cfif>

			<!--- ................................................................................................................... --->
			<!--- IF BBManualSetPaidStatus QUICK  appSettings.Mass_Pay_Billback  .................................................... --->
			<!--- D32285 : Manually Set BB Status to Paid 			................................................................. --->
			<!--- ................................................................................................................... --->
		</tr>
		</CFOUTPUT>
</table>
	<cfoutput>
	<input type="hidden" name="Pay_Multi_Billbacks_IDs" value="#Pay_Multi_Billbacks_IDs#">
	</cfoutput>
	</form>
	<CFOUTPUT>
	<form action="SC_Payment_Request_VendorOnly.cfm" method="post" name="MyForm" ID="MyForm" style="DISPLAY:INLINE;">
		<input type="Hidden" name="startrow" value="#startrow#">
		<input type="Hidden" name="frompage" value="#frompage#">
		<input type="Hidden" name="SORTBY" value="#SORTBY#">
		<input type="Hidden" name="SORTORDER" value="#SORTORDER#">
		<input type="Hidden" name="massPayBillbackList" id="massPayBillbackList" value="#form.massPayBillbackList#">
	</form>

		<table width="98%" CELLSPACING="0" CELLPADDING="0">
		<tr>
			<td>
			<CF_Next_Previous_For_Forms
			formname="MyForm"
			query="Get_data"
			maxpages="30"
			previous		=	"<img src=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			next			=	"<img src=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			previousseries	=	"<img src=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			nextseries		=	"<img src=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			firstseries		=	"<img src=""/images/first_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			lastseries		=	"<img src=""/images/last_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			addparams="">
			</td>
			<cfset SECTION_RECORDCOUNT = Get_data.RecordCount>
			<td ALIGN="RIGHT">
				<FONT COLOR="Red" SIZE="2"><B>There <cfif SECTION_RECORDCOUNT EQ 1>Is<cfelse>Are</cfif>&nbsp;#SECTION_RECORDCOUNT# <cfif SECTION_RECORDCOUNT EQ 1>Billback<cfelse>Billbacks</cfif> In This Status</B></FONT>
			</td>
		</tr>
	</table>
	</CFOUTPUT>
<cfelse>

</cfif>
<cfinclude template="/common_files/jQuery.cfm">
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script type="text/javascript" src="/Script/javascript/variable.debugger.js"></script>
<SCRIPT language="JavaScript">
	function Confirm_Payment()
	{
		document.all.Form_Submitted.value = 1
		document.Status_Change.submit()
	}

	function manageChkAllPaid(){
		var arrItems = [];
		var arrItemsChecked = [];
		//get list of items on current page
		arrItems = $('.chkPaid').map(function() {
				return $(this).val();
		}).get();
		//get list of CHECKED items on current page
		arrItemsChecked = $('.chkPaid:checked').map(function() {
				return $(this).val();
		}).get();

		var bool = (arrItems.length == arrItemsChecked.length && arrItemsChecked.length > 0);

		//$(this).parent().find('#chkAllPaid').attr(':checked', 'checked' );
		$('#chkAllPaid',window.parent.document).attr('checked', bool );
		var x = window.parent.document.all.chkAllPaid.checked;
		//$.debug(x);
		//alert($('#chkAllPaid',window.parent));
	}
	//--- D32285 : Manually Set BB Status to Paid 			................................................................. ---
	$(document).ready(function() {

		//alert(window.parent.massPayBillbackList);

		//select checkboxes in master list
		var arrMassPayBillbackList =  window.parent.massPayBillbackList;
		$('.chkPaid').each(function(){
			$(this).attr('checked', ($.inArray($(this).val(), arrMassPayBillbackList) > -1) )
		});
		//check header row check box if necessary
		manageChkAllPaid();
		$('.chkPaid').click(function() {
			var arrBBtoPay = window.parent.massPayBillbackList;//document.all.MyForm.massPayBillbackList.value;
	    	var chkBox = $(this);
			var uid = chkBox.val();
			//if checked and not in list -> add
		    if (chkBox.is(':checked')){
		        // the checkbox was checked add to list
				arrBBtoPay[arrBBtoPay.length++] = uid;
		    } else{
		        // the checkbox was unchecked remove from list
				arrBBtoPay = jQuery.grep(arrBBtoPay, function(value) {
					return value != uid;
				} );
		    }
			document.all.MyForm.massPayBillbackList.value = arrBBtoPay.join();
			window.parent.massPayBillbackList = arrBBtoPay;
			manageChkAllPaid();
		});
	});

	//--- 44310: Mass Release billbacks in Payment Request status
	/*
	Note - This code is a copy of the above code which is meant for "Mass Pay".
	This code makes sure that when a user goes from page to page, the list of
	selected billbacks is retained.
	*/
	$(document).ready(function() {
		//select checkboxes in master list
		var arrMassReleaseBillbackList =  window.parent.massReleaseBillbackList;
		$('.chkHold').each(function(){
			$(this).attr('checked', ($.inArray($(this).val(), arrMassReleaseBillbackList) > -1) )
		});
		$('.chkHold').click(function() {
			var arrBBtoRelease = window.parent.massReleaseBillbackList;
	    	var chkBox = $(this);
			var uid = chkBox.val();
			//if checked and not in list -> add
		    if (chkBox.is(':checked')){
		        // the checkbox was checked add to list
				arrBBtoRelease[arrBBtoRelease.length++] = uid;
		    } else{
		        // the checkbox was unchecked remove from list
				arrBBtoRelease = jQuery.grep(arrBBtoRelease, function(value) {
					return value != uid;
				} );
		    }
			document.all.Status_Change.BBToBeReleasedList.value = arrBBtoRelease.join();
			window.parent.massReleaseBillbackList = arrBBtoRelease;
		});

	});

	/* When the user selects "check all" option for "release selected billbacks" feature, we need to select all the billbacks
	which have a checkbox available for "release", even though the billbacks are in different pages and so all records with
	a checkbox on page,1,2,3 etc should be selected.
	"massReleaseBillbackList" is populated on the parent page whoch also stores the list of billbacks.
	*/
	function CheckAllReleased(chkBoxStatus)
	{
		var arrItemsRelease = [];

		if(chkBoxStatus.checked == true)
		{
			if(confirm("Please be aware that all the billlbacks which are currently in 'Hold' status have been selected. This list includes billbacks in all the pages and not just the current page."
			+ " Are you sure you want to include all the billbacks?"))
			{
				if(document.getElementById('AllMassReleaseBillbackList').value != '')
				{
					document.all.Status_Change.BBToBeReleasedList.value = document.getElementById('AllMassReleaseBillbackList').value;
					window.parent.massReleaseBillbackList =  document.getElementById('AllMassReleaseBillbackList').value.split(",");

					/* Once the user uses the selection to select or unselect all billbacks, refresh page so that the checkboxes can be checked or unchecked. */
					location.reload();
		}
				}
			}
		else
		{
			document.all.Status_Change.BBToBeReleasedList.value = arrItemsRelease;
			window.parent.massReleaseBillbackList =  arrItemsRelease;

			/* Once the user uses the selection to select or unselect all billbacks, refresh page so that the checkboxes can be checked or unchecked. */
			location.reload();
		}
	}

	/* We have a link called "release selected billbacks". This link should be visible only when the user views the "payment request" status on the scorecard. */
	if(window.parent.idReleaseBB)
	{
		<cfif IsDefined("URL.SECTION_TO_OPEN")>
			/* "payment request" status. */
			<cfif URL.SECTION_TO_OPEN eq 4>
				window.parent.idReleaseBB.style.display = '';
			<cfelse>
				window.parent.idReleaseBB.style.display = 'none';
			</cfif>
		<cfelse>
				window.parent.idReleaseBB.style.display = '';
		</cfif>
	}

	function openDetails(BBID){
		NewWindow('/billbacks/scorecard/billback_details.cfm?BBID='+BBID, 'billback_details', 800, 600, 'yes', 'yes');
	}
</SCRIPT>
</BODY>
</HTML>