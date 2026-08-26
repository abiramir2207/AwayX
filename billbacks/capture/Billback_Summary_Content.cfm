<!---
Name: 			Billback_Summary_Content.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	N/A
Created By:		N/A
Description:	This file is responsible for displaying the summary of a billback.
--->

<!--- <title>Billback Summary</title> --->
<cfparam name="ShowDedLink" default="1">
<cfparam name="url.SHOW_PRINT_VERSION" default="0">
<cfparam name="url.show_email_version" default="0">
<cfparam name="cryp.value" default="">
<!--- <cfparam name="HasDefaultProgram" default="0"> --->
<cfparam name="url.show_edit_link" default="0">
<cfparam name="ShowDetails" default="1">
<cfparam name="url.deleted_billback" default="0"/><!---D40664 :: Settings page to show Deleted Billbacks --->
<cfset bDivestedNote = 0 />
<cfif not isDefined("Get_Profile_Settings")>
<cfinclude template="/get_access_profile.cfm" />
</cfif>
<!--- Get default program if printing --->
<!--- Check to see if default program is on billback D11756--->
<cfset useLakebaseForGetBillbackSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForGetBillbackSettings>
	<cftry>
		<cfset GetBillbackSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "default_program,use_dflt_prg"
			}), "default_program,use_dflt_prg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBillbackSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBillbackSettings>
<cfquery name="GetBillbackSettings" datasource="#application.datasource#">
	SELECT Default_Program,USE_DFLT_PRG FROM Billback_Settings
</cfquery>
</cfif>

<cfset BBProgramManager = CreateObject("component", "components.Billback.Programs.BillbackProgramsManager") />
<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
<cfset qGetBSVar2Label		= LabelComp.getGeneralLabels('BS_Var_2') />

<cfif NOT isDefined("HasDefaultProgram")>
	<cfif len(trim(GetBillbackSettings.Default_Program)) GT 0>
		<cfset useLakebaseForIsDefaultProgramOnBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForIsDefaultProgramOnBillback>
	<cftry>
		<cfset IsDefaultProgramOnBillback = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"program_id" = "eq.#GetBillbackSettings.Default_Program#",
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0",
				"select" = "billback_program_id"
			}), "billback_program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsDefaultProgramOnBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsDefaultProgramOnBillback>
<cfquery name="IsDefaultProgramOnBillback" datasource="#application.datasource#">
			SELECT Billback_Program_ID
			FROM Billback_Program
			WHERE Program_ID = '#GetBillbackSettings.Default_Program#'
			AND Billback_ID = '#Billback_ID#'
			AND Deleted = 0
		</cfquery>
</cfif>
		<cfif IsDefaultProgramOnBillback.Recordcount GT 0>
			<cfset HasDefaultProgram = 1>
		<cfelse>
			<cfset HasDefaultProgram = 0>
		</cfif>
	<cfelse>
		<cfset HasDefaultProgram = 0>
	</cfif>
</cfif>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<!--- pullback applied amount --->
<cfscript>
	PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager");
	GetPullbackInfo = PullbackManager.getPullbackAppliedInfo(Billback_ID);
	BillbackSettingsManager = CreateObject("component", "components.billback.BillbackSettingsManager");
	getSubtotalDisplaySettings = BillbackSettingsManager.getSubtotalDisplaySettings();

	// 33278 - added case, pound labels
	label.CFC = CreateObject("component","components.settings.labels.labels").init();
	label.query = label.CFC.getGeneralLabels( 'case plural' );
	label.case_plural = label.query.General_Labels_Label;
	label.query = label.CFC.getGeneralLabels( 'pound plural' );
	label.pound_plural = label.query.General_Labels_Label;
</cfscript>

<cfif NOT isDefined("variables.VendorLabel")>
	<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
	<cfset variables.VendorLabel = labelSettings.getBBLabels().vendor />
</cfif>

<cfif LEN(trim(Billback_ID)) EQ 0>
	<cflocation url="../search_screens/search_billbacks.cfm">
	<cfabort>
</cfif>

<cfparam name="Print_Version" default="0">

<!---------------------------------------------------
This Page generates the Content for Billback Summary
---------------------------------------------------->
<style>

	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}

	#header
		{
			font-size: 12px;
		}

	#cellLabel
		{
			<!--- font-family:Arial; --->
			font-size: 10px;
			font-weight: bold;
			vertical-align : top;
		}

	#dataStyle
		{
			font-size: 10px;
		}

	TD
		{
			font-family:Arial;
			font-size:10px;
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
	.ThreeBorders
	{
	border-left:solid ffe4b5 1px;
	border-right:solid ffe4b5 1px;
	border-bottom:solid ffe4b5 1px;
	font-size: 10px;
	font-family: arial;
	}
	.RegularText
	{
	font-size: 10px;
	font-family: arial;
	}

	.underLineRow td
	{
		border-bottom:1px solid #000000;
		border-top:none;
		border-left:none;
		border-right:none;
	}
</style>


<cfoutput>
	<cfinclude template="/Billbacks/Deviation/Deviation_Display_Style.cfm">
	<cfsilent>
		<cfset billbackMan = CreateObject("component", "components.billback.BillbackManager").init() />

<!--- If the setting allows for Sales tax Info --->
<cfset CheckTemplateSalesTax = BBProgramManager.getTemplateSalesTax(Billback_ID)>

<cfset bBillbackSalesTax = 0 />
<cfif (CheckTemplateSalesTax.RecordCount GTE 2)>
	<cfloop query = "CheckTemplateSalesTax">
		<cfif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
			<cfset bBillbackSalesTax = 1 />
		</cfif>
	</cfloop>
<cfelseif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
	<cfset bBillbackSalesTax = 1 />
</cfif>

		<!--- <cfif appSettings.getBillbacksSalesTax() eq 1> --->
		<cfif (bBillbackSalesTax EQ 1)>
			<cfset BillbackSalesTaxAmountInfo = billbackMan.getBillbacksSalesTaxAmount(Billback_ID)>
		</cfif>
     <!-----------------------------------------------------------------------------
      Dev Notes: D18281 - Solo - Add new closing method on billback entry
    	All the closing method dropdown and values now come from the DB based on
      the settings in the settings panel
    -Anand Rao/29-May-09
    ------------------------------------------------------------------------------>
		<!--- Get the Billback number --->
		<cfquery name="Get_Billback_Info" datasource="#application.datasource#">
			SELECT	  	isnull(Billback_Program.Program_ID,'') AS ProgramID,
						isNull(Billback.Claim_Cases, 0.00) as Claim_Cases,
						isNull(Billback.Claim_Pounds, 0.00) as Claim_Pounds,
						isNull(cast(Billback.BB_Amount as decimal(18,2)), 0.00) as BB_Amount,
						Uploaded_Billback,
						Billback.*,
						Billback_Allied.BB_Is_Locked,
						Billback_Allied.BB_Locked_By_User_ID,
						Billback_Status.BB_Status_Description,
						cast(Billback_Settings.Auto_Approve_Amount as decimal(18,2)) as Auto_Approve_Amount,
						Billback_Settings.Auto_Approve_On,
            Billback_Settings.Auto_Approve_BB_Types,
            Billback_Settings.Auto_Approved_BB_Status,
            Billback_Closing_Methods.Abbreviation,
            Billback_Closing_Methods.vchBillback_Closing_Method_Desc,
						DateDiff(d, Billback.Created_Date, getDate()) as Billback_Age,
						Billback_Settings.Auto_Appr_Consider_Created_Date,
						Billback_Settings.Auto_Appr_Age
			FROM		Billback
            LEFT JOIN Billback_Closing_Methods
              ON (Billback.BB_Closing_Method = Billback_Closing_Methods.iBillback_Closing_Method_ID)
  					LEFT JOIN Billback_Settings ON 1 = 1
						LEFT JOIN Billback_Allied ON
						Billback_Allied.Billback_ID = Billback.Billback_ID
						LEFT JOIN Billback_Program ON
						Billback_Program.billback_id = 	Billback.billback_id
						AND Billback_program.deleted = 0
						LEFT JOIN   Billback_Status ON
						Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
			WHERE
			<!---D40664 :: Settings page to show Deleted Billbacks --->
			<cfif url.deleted_billback EQ 0>
			Billback.Deleted = 0
			AND
			</cfif>
			<!---D40664 :: Settings page to show Deleted Billbacks --->
			Billback.Billback_ID = '#Billback_ID#'
		</cfquery>

		<!--- Dev Note(78635): Check whether it is a lump sum program paid to vendor --->
		<cfset variables.VendorOnlyBillback = Get_Billback_Info.Vendor_Only_Billback>

		<cfset Billback_Payable_Number=Get_Billback_Info.BB_Code>
		<cfset Billback_Billback_Title=Get_Billback_Info.BB_Title>
		<cfset Billback_ProgramID = Get_Billback_Info.ProgramID >
		<cfparam name="businessSegmentsOn" default="0">

		<cfscript>
			// these are constants
			uom.case  = 1;
			uom.pound = 2;
			uom.both  = 3;

			// retrieve "View Program / Billback Summary UOM" setting
			config.ViewProgramVolumeUOM = application.appSettingsGet.getViewProgramVolumeUOM();

			// set up local flags for showing pounds and showing cases
			show.pound = ( config.ViewProgramVolumeUOM eq uom.pound or config.ViewProgramVolumeUOM eq uom.both );
			show.case  = ( config.ViewProgramVolumeUOM eq uom.case  or config.ViewProgramVolumeUOM eq uom.both );
		</cfscript>
	</cfsilent>

	<table border="0" width="99%" align="center" bgcolor="ffffff" cellpadding="1" cellspacing="0">
		<caption style="text-align:left">
			<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">#application.returned_customer_setting.company_name#</div>
		</caption>
		<tr>
			<td colspan="100%" bgcolor="">
				<B><FONT SIZE="+1" COLOR="Navy">Payable Number: #Billback_Payable_Number#</FONT></B>&nbsp;&nbsp;&nbsp;
				<CFIF Get_Billback_Info.BB_Is_Child EQ 1><FONT COLOR="Red" SIZE="2">This information relates to the parent billback, not the split billback.</FONT></CFIF>
          <!-----------------------------------------------------------------------------
            Dev Notes: D19081
            Added another condition in the below if statement
            "AND (Auto_Approve_BB_Types EQ 2 OR Auto_Approve_BB_Types EQ 3)" where 2
            denotes the user has selected "Manually created billbacks only" in the
            Setting Payable Auto Close and 3 is he selected "Both".
            -Anand Rao/21-May-09
          ------------------------------------------------------------------------------>
				<cfset BillbackSummaryManager = CreateObject("component", "components.Billback.BillbackSummaryManager") />
				<cfset payeeTypeId = 0 />
				<cfif Get_Billback_Info.Billback_Payee_Type_ID neq "">
					<cfset payeeTypeId = Get_Billback_Info.Billback_Payee_Type_ID />
				</cfif>

				<cfif BillbackSummaryManager.getBillbackAutoApproval(
						billbackId = Billback_ID,
						billbackAmount = Get_Billback_Info.BB_Amount,
						billbackStatus = Get_Billback_Info.Billback_Status_ID,
						billbackPayeeTypeId = payeeTypeId,
						billbackAge = Get_Billback_Info.Billback_Age,
						billbackReference = Get_Billback_Info.BB_Reference)

						AND Get_Billback_Info.Billback_Status_ID LT 2>
					<BR>
					<font color="red" size="1">
						<B>** Claimed dollar amount of this payable is within auto approval limit. This payable will be auto approved on Request for Approval if vendor requirement is satisfied.</B>
					</font>
				</cfif>
				<HR COLOR="Navy">
			</td>
		</tr>
		<tr>
			<td colspan="100%">
			 	<table border="0" width="100%" bgcolor="ffffff" cellpadding="0" cellspacing="0">
			 		<tr>
			  			<td>
							<table border="0" width="240px" align="left" bgcolor="ffffff" cellpadding="1" cellspacing="2">
								<tr>
									<td id="cellLabel">Title:</td>
									<td id="dataStyle" width="100%">#Billback_Billback_Title#</td>
								</tr>
								<!--- handle business segments---->
								<cfsilent>
									<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
									<cfif businessSegManager.isEnabled() and Billback_ProgramID NEQ "" and Billback_ProgramID NEQ 0>
										<cfset businessSegmentsOn = 1 />
										<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(Billback_ProgramID) />
										<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
										<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
										<!---<cfset appSettings = genSettingsManager.get()>--->
										<cfif appSettings.getSalesOrgOn()>
											<cfset LOBManager = CreateObject("component", "components.programs.business_segment.LOBManager") />
											<cfset LOBIdForProgram = LOBManager.getLOBIdByProgram(Billback_ProgramID) />
											<cfif LOBIdForProgram NEQ "">
												<cfset qGetThisLOB = LOBManager.get(LOBIdForProgram) />
												<cfset Line_Of_Business_Name = qGetThisLOB.Line_Of_Business_Name>
											<cfelse>
												<cfset Line_Of_Business_Name = "No #appSettings.getlob_label()#">
											</cfif>
										</cfif>
									</cfif>
								</cfsilent>

								<!---display business segments if it's turned on--->
								<cfif businessSegmentsOn eq 1>
									<tr>
										<td ID="cellLabel">#appSettings.getbusiness_segment_label()#</td>
										<td ID="dataStyle" WIDTH="100%">
											#qGetThisBusSegment.Business_Unit_Desc#&nbsp;
										</td>
									</tr>
									<cfif appSettings.getSalesOrgOn()>
										<tr>
											<td ID="cellLabel">#appSettings.getlob_label()#</td>
											<td ID="dataStyle" WIDTH="100%">#Line_Of_Business_Name#&nbsp;</td>
										</tr>
									</cfif>
								</cfif>
								<tr>
									<td id="cellLabel">Billback Number:</td>
									<td width="100%" valign="bottom" ID="dataStyle">#Get_Billback_Info.BB_Reference#</td>
								</tr>
								<cfset billbackAssignmentManager = CreateOBject("component", "components.billback.BillbackAssignmentManager") />
								<tr>
									<td id="cellLabel"> Analyst:</td>
									<td id="dataStyle">#billbackAssignmentManager.getBillbackAnalystName(Billback_ID)#</td>
								</tr>
							</table>
						</td>
						<td>
							<table BORDER="0" WIDTH="240px" ALIGN="left" BGCOLOR="ffffff" CELLPADDING="1" CELLSPACING="2" STYLE="border-left:1px solid black;border-right:1px solid black;">
								<tr>
									<td id="cellLabel" NOWRAP>Billback Date:</td>
									<td id="dataStyle" WIDTH="100%">#DateFormat(Get_Billback_Info.BB_Date, 'MMMM DD, YYYY')#</td>
								</tr>

								<cfif Print_Version IS 1>
									<tr>
										<td id="cellLabel" NOWRAP>Billback Status:</td>
										<td id="dataStyle" WIDTH="100%">#Get_Billback_Info.BB_Status_Description#</td>
									</tr>
								</cfif>

								<!---Recieved date--->
								<cfif len(trim(Get_Billback_Info.BB_Received_Date)) GT 0>
									<tr>
										<td id="cellLabel" NOWRAP>Received Date:</td>
										<td ID="dataStyle" WIDTH="100%">#DateFormat(Get_Billback_Info.BB_Received_Date, 'MMMM DD, YYYY')#</td>
									</tr>
								</cfif>

								<cfif len(trim(Get_Billback_Info.Postmark_Date)) GT 0>
									<!---Postmark date--->
									<tr>
										<td ID="cellLabel" NOWRAP>Postmark Date:</td>
										<td ID="dataStyle" WIDTH="100%">#DateFormat(Get_Billback_Info.Postmark_Date, 'MMMM DD, YYYY')#</td>
									</tr>
								</cfif>

								<!---Reference Number--->
								<tr>
									<td ID="cellLabel" NOWRAP>Reference Number:</td>
									<td ID="dataStyle" WIDTH="100%">#Get_Billback_Info.referenceNum#</td>
								</tr>
							</table>
						</td>
						<td valign="top">
							<!---
								D39812: Validate EDI files for potential billback duplicate/Anand Rao/13-Feb-2014
								Added the below section for displaying EDI duplicate, if it is flagged as duplicate.
							--->
							<cfset useLakebaseForgetBBSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForgetBBSettings>
	<cftry>
		<cfset getBBSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "enable_bb_dup_check"
			}), "enable_bb_dup_check"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBBSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBBSettings>
<cfquery name="getBBSettings" datasource="#application.datasource#">
								SELECT 	Enable_BB_Dup_Check
	            				FROM 		Billback_Settings
        					</cfquery>
</cfif>
							<cfif Get_Billback_Info.BB_Upload_Dup_Group_ID EQ "">
								<cfset BBUploadDupGroupID = 0 />
							<cfelse>
								<cfset BBUploadDupGroupID = Get_Billback_Info.BB_Upload_Dup_Group_ID />
							</cfif>

							<cfif (getBBSettings.Enable_BB_Dup_Check EQ 1 AND BBUploadDupGroupID NEQ 0 )>
								<div align="right" style="border:0px solid ##ccc; width:260;" ><font color="red"><strong>[EDI Duplicate]</strong></font></div>
							</cfif>
							<!---
								D50616 - New Duplicate BB Logic/Anand Rao/06-Jun-2014
							--->
							<cfif isDefined("Get_Billback_Info.BB_All_Dup_Group_ID") AND Get_Billback_Info.BB_All_Dup_Group_ID NEQ "">
								<div align="right" style="border:0px solid ##ccc; width:260;" ><font color="red" size="4"><strong>Duplicate</strong></font></div>
							</cfif>

							<table width="240px" BORDER="0" BGCOLOR="ffffff" CELLPADDING="1" CELLSPACING="2">
								<tr>
									<td ID="cellLabel" NOWRAP>Period:</td>
									<td ID="dataStyle">
										<!--- D41181 : Prod Event 3928
											Event error happening in some scenarios when BB_Start_Date and BB_End_Date is empty
											--->
										<cfif len(Get_Billback_Info.BB_Start_Date)>
										#MonthAsString(datepart('m', Get_Billback_Info.BB_Start_Date))#&nbsp;#datepart('d', Get_Billback_Info.BB_Start_Date)#,&nbsp;#datepart('yyyy', Get_Billback_Info.BB_Start_Date)#
											<cfelse>
												N/A
										</cfif>
										to
										<cfif len(Get_Billback_Info.BB_End_Date)>
										#MonthAsString(datepart('m', Get_Billback_Info.BB_End_Date))#&nbsp;#datepart('d', Get_Billback_Info.BB_End_Date)#,&nbsp;#datepart('yyyy', Get_Billback_Info.BB_End_Date)#
											<cfelse>
												N/A
										</cfif>
										<!---D41181 : Prod Event 3928 : END --->
									</td>
								</tr>
								<cfsilent>
									<CFSET ShowEditLink = 0>
									<CFIF Billback_ID NEQ ""
										<!--- AND Get_Billback_Info.BB_Is_Locked EQ 1 --->
										<!---  AND Get_Billback_Info.BB_Locked_By_User_ID EQ request.AccessStructure.User_ID --->
										AND Get_Billback_Info.BB_Associated_To_DD NEQ 1
										AND Get_Billback_Info.Billback_Status_ID NEQ 4
										AND Get_Billback_Info.Billback_Status_ID NEQ 5
										AND Get_Billback_Info.Billback_Status_ID NEQ 7
										AND Get_Billback_Info.Negative_Billback EQ 0
										AND Get_Profile_Settings.BB_Approve >
										<CFSET url.show_edit_link = 1>
										<CFSET ShowEditLink = 1>
									</CFIF>
								</cfsilent>
								<cfif (appsettings.getOneProgramPerBillback() IS 1 OR appSettings.get_Setting('Restrict_One_Component_Per_Billback') EQ '1') AND appsettings.getClaimMech_Popup() IS 2 AND len(trim(Get_Billback_Info.ProgramID)) GT 0>
									<cfsilent>
										<cfparam name="PaymentMethodName" default="None selected">
										<cfif len(trim(Get_Billback_Info.ClaimMechanics)) IS NOT 0>
											<cfset useLakebaseForGetCMName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_type")>
<cfif useLakebaseForGetCMName>
	<cftry>
		<cfset GetCMName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_type", {
				"payment_type_id" = "eq.#Get_Billback_Info.ClaimMechanics#",
				"select" = "payment_type_name"
			}), "payment_type_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCMName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCMName>
<cfquery name="GetCMName" datasource="#application.datasource#">
												SELECT Payment_Type.Payment_Type_Name
												FROM Payment_Type
												WHERE Payment_Type_ID = '#Get_Billback_Info.ClaimMechanics#'
											</cfquery>
</cfif>
											<cfset PaymentMethodName = GetCMName.Payment_Type_Name>
										<cfelse>
											<cfquery name="GetCMName" datasource="#application.datasource#">
												SELECT Payment_Type.Payment_Type_Name, Payment_Type.Payment_Type_ID
												FROM Billback_Program
													INNER JOIN Contract_Main
													ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
													INNER JOIN Payment_Type
													ON Payment_Type.Payment_Type_ID = Contract_Main.ClaimMechanics
												WHERE Billback_Program.Billback_ID = '#Get_Billback_Info.Billback_ID#'
											</cfquery>

											<!---If all these conditions are true but no payment type has been set, we sneakily update the payment type here --->
											<cfif len(trim(GetCMName.Payment_Type_ID)) GT 0>
												<cfset useLakebaseForUpdatePaymentType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdatePaymentType>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Get_Billback_Info.Billback_ID#"
			},
			{
				"claimmechanics" = "#GetCMName.Payment_Type_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdatePaymentType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdatePaymentType>
<cfquery name="UpdatePaymentType" datasource="#application.datasource#">
													UPDATE Billback
													SET ClaimMechanics = #GetCMName.Payment_Type_ID#
													WHERE Billback_ID = '#Get_Billback_Info.Billback_ID#'
												</cfquery>
</cfif>
											</cfif>
											<cfset PaymentMethodName = GetCMName.Payment_Type_Name>
										</cfif>
									</cfsilent>
									<tr>
										<td ID="cellLabel">Payment Method:</td>
										<td ID="dataStyle">#PaymentMethodName#</td>
									</tr>
								</cfif>
								<tr>

									<td ID="cellLabel" nowrap>Closing Method:</td>
                  <!---
                    D18281: The value is coming from the main query itself based on a join so no need for the earlier
                            Checking and displaying the value - Anand Rao/29-May-09
                  --->
				  		<!---
							D32471:Program View Billbacks showing multiple times- Anand Rao/14-Jun-12
						--->
						<cfset childrenCMs = "" />
				  		<cfif (application.appSettingsGet.DISPLAY_ONLY_BILLBACK_PARENT)>
							<cfsilent>
								<cfquery name="GetChildBBCM" datasource="#application.datasource#">
									SELECT BB.BB_Code,
					 					BCM.Abbreviation,
							            BCM.vchBillback_Closing_Method_Desc
		            				FROM Payment_History_Details PHD
						            INNER JOIN Billback BB on BB.Billback_ID = PHD.Billback_ID
									LEFT JOIN Billback_Closing_Methods BCM
		              				ON (BB.BB_Closing_Method = BCM.iBillback_Closing_Method_ID)
		              				WHERE BB.BB_Parent_ID = '#Get_Billback_Info.Billback_ID#'
									  order by BCM.Abbreviation
								</cfquery>
								<cfloop query="GetChildBBCM">
									<cfset childrenCMs = childrenCMs & GetChildBBCM.vchBillback_Closing_Method_Desc & ";" />
								</cfloop>
							</cfsilent>
						</cfif>

									<td ID="dataStyle"><cfif ((application.appSettingsGet.DISPLAY_ONLY_BILLBACK_PARENT) AND childrenCMs NEQ "")>#childrenCMs#<cfelse>#Get_Billback_Info.vchBillback_Closing_Method_Desc#</cfif>
                  <!--- <CFIF Get_Billback_Info.BB_Closing_Method EQ 2>Deduction<CFELSEIF Get_Billback_Info.BB_Closing_Method EQ 3>Off Invoice<CFELSEIF Get_Billback_Info.BB_Closing_Method EQ 4>Adjustment<CFELSE>Payment</CFIF> --->
										<!------ DEV NOTE DRK D9471 - removeforemail is a dummy tag so that we can remove this edit link on email/fax/print etc., please don't remove ----->
										<removeforemail>
											<cfif Get_Billback_Info.DD_Closure_Sent_On eq "">
												<CFIF ShowEditLink EQ 1 or (url.show_edit_link and Get_Billback_Info.Billback_Status_ID LT 4)>
													&nbsp;&nbsp;<B>
													<FONT COLOR="Red" SIZE="2">[ </FONT>
													<A href="Closing_Method_Edit.cfm?Billback_ID=#Billback_ID#" onclick="NewWindow(this.href,'name','600','225','Yes', 'No');return false;" TITLE="">edit</A>
													<FONT COLOR="Red" SIZE="2"> ]</FONT></B>
												</CFIF>
											</cfif>
										</removeforemail>
									</td>
								</tr>
								<CFIF Get_Billback_Info.BB_Closing_Method EQ 2>
									<cfsilent>
										<CFQUERY NAME="GetAssociatedDD" DATASOURCE="#Application.Datasource#">
											SELECT * FROM DD_Closure_Detail
											INNER JOIN Deductions ON Deductions.Deduction_ID = DD_Closure_Detail.Deduction_ID AND
											DD_Closure_Detail.DD_Closure_ID = '#Billback_ID#' AND DD_Closure_Detail.Deleted = 0 AND
											Deductions.Deleted = 0
										</CFQUERY>
									</cfsilent>
									<CFIF GetAssociatedDD.RecordCount GT 0>
										<tr>
											<td ID="cellLabel">Associated Deduction:</td>
											<td ID="dataStyle">
												<!---Don't show this link from the deduction window --->
												<cfif ShowDedLink NEQ 0>
													<A href="/deductions/deduction.cfm?Deduction_ID=#GetAssociatedDD.Deduction_ID#" onclick="NewWindow(this.href,'name','800','600','Yes', 'Yes');return false;" TITLE="">#GetAssociatedDD.DD_DedID_SP_Number#</a>
												<cfelse>
													#GetAssociatedDD.DD_DedID_SP_Number#
												</cfif>
											</td>
										</tr>
								   	</CFIF>
								</CFIF>

							</table>
						</td>
					</tr>
				</table>

				<cfsilent>
					<!---TSF: Label 9231 --->
					<!---declare all variables here--->
					<cfset variables.getBillbackItemizedVolumeSum	= billbackMan.getBillbackItemizedVolumeSum(Billback_ID) />
					<cfset variables.getBillbackPaidVolumeSum		= billbackMan.getBillbackPaidVolumeSum(Billback_ID) />
					<cfset variables.billbackAmount 				= 0.00 />
					<!---check to see if we have an itemized total first--->
					<cfif not isDefined("variables.itemized_total")>
						<cfset variables.itemized_total = CreateObject("component", "components.billback.BillbackManager").getBillbackItemizedAmount(Billback_ID) />
					</cfif>
					<cfset variables.itemizedAmount 				= variables.itemized_total />
					<cfset variables.varianceAmount 				= 0.00 />
					<cfset variables.claimPounds 					= Get_Billback_Info.Claim_Pounds />
					<cfset variables.claimCases 					= Get_Billback_Info.Claim_Cases />
					<cfset variables.itemizedPounds					= variables.getBillbackItemizedVolumeSum.Volume_LB />
					<cfset variables.itemizedCases 					= variables.getBillbackItemizedVolumeSum.Volume_CS />
					<!---if value is negative then add it, otherwise subtract it--->
					<cfif variables.itemizedPounds lt 0>
						<cfset variables.variancePounds				= variables.claimPounds + variables.itemizedPounds />
					<cfelse>
						<cfset variables.variancePounds				= variables.claimPounds - variables.itemizedPounds />
					</cfif>
					<!---if value is negative then add it, otherwise subtract it--->
					<cfif variables.itemizedCases lt 0>
						<cfset variables.varianceCases				= variables.claimCases + variables.itemizedCases />
					<cfelse>
						<cfset variables.varianceCases				= variables.claimCases - variables.itemizedCases />
					</cfif>
					<cfset variables.statusItemizedAmount 			= billbackMan.getBillbackPaidAmount(Billback_ID) />
					<cfset variables.statusItemizedPounds			= variables.getBillbackPaidVolumeSum.TotalPaidLB />
					<cfset variables.statusItemizedCases 			= variables.getBillbackPaidVolumeSum.TotalPaidCS />
					<!---if value is negative then add it, otherwise subtract it--->
					<cfif variables.statusItemizedPounds lt 0>
						<cfset variables.statusVariancePounds		= variables.claimPounds + variables.statusItemizedPounds />
					<cfelse>
						<cfset variables.statusVariancePounds		= variables.claimPounds - variables.statusItemizedPounds />
					</cfif>
					<!---if value is negative then add it, otherwise subtract it--->
					<cfif variables.statusItemizedCases lt 0>
						<cfset variables.statusVarianceCases		= variables.claimCases + variables.statusItemizedCases />
					<cfelse>
						<cfset variables.statusVarianceCases		= variables.claimCases - variables.statusItemizedCases />
					</cfif>
				</cfsilent>
				<span id="cellLabel">&nbsp;Notes:</span> #Get_Billback_Info.BB_Creator_Notes#
			</td>
		</tr>
		<tr style="display:none;"><td></td></tr>
		<tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="100%">
				<table border="0" cellpadding="0" cellspacing="0" width="100%">
					<tr>
						<td>
						<table border="0" cellpadding="4" cellspacing="0" width="330" align="left">
							<tr class="underLineRow">
								<td colspan="100%"><span style="font-size:14px"><b>Customer Claim</b></span></td>
							</tr>
							<tr class="underLineRow">
								<td>&nbsp;</td>
								<td align="right"><b><u>Claim Summary</u></b></td>
								<td align="right"><b><u>Itemized Total</u></b></td>
								<td align="right"><b><u>Variance</u></b></td>
							</tr>
							<tr class="underLineRow">
								<td><b>$ Amount</b></td>
								<td align="right">
									<cfsilent>
										<cfset variables.billbackAmount = Get_Billback_Info.BB_Amount />
									</cfsilent>
									<cfset variables.billbackAmountmodified = variables.billbackAmount>

									<CFIF variables.billbackAmount lt 0>
										<cfset variables.billbackAmountmodified = variables.billbackAmount * -1 />
										<span style="color:##FF0000">$[ #numberFormat(variables.billbackAmountmodified, ',.__')# ]</span>
									<CFELSE>
										#dollarFormat(variables.billbackAmount)#
									</CFIF>
									<!--- <cfif appsettings.getBillbacksSalesTax() eq 1> --->
									<cfif (bBillbackSalesTax EQ 1)>
										<!--- If the setting allows for Sales tax Info --->
										 + #trim(dollarformat(val(Get_Billback_Info.TotalTaxAmount)))# (Sales Tax) = #trim(Dollarformat(val(variables.billbackAmount) + val(Get_Billback_Info.TotalTaxAmount)))#
									</cfif>
								</td>
								<td align="right">
									<!---if the value is negative then change the display format--->
									<cfif variables.itemizedAmount lt 0>
										<cfset variables.itemizedAmount = variables.itemizedAmount * -1 />
										<span style="color:##FF0000">$[ #numberFormat(variables.itemizedAmount, ',.__')# ]</span>
									<cfelse>
										#dollarFormat(variables.itemizedAmount)#
									</cfif>
								</td>
								<cfif variables.itemizedAmount lt 0>
									<cfset variables.varianceAmount = variables.billbackAmountmodified + variables.itemizedAmount />
								<cfelse>
									<cfset variables.varianceAmount = variables.billbackAmountmodified - variables.itemizedAmount />
								</cfif>
								<td align="right">
									<!---if the value is negative then change the display format--->
									<cfif variables.varianceAmount lt 0>
										<cfset variables.varianceAmount = variables.varianceAmount * -1 />
										<span style="color:##FF0000">$[ #numberFormat(variables.varianceAmount, ',.__')# ]</span>
									<cfelse>
										#dollarFormat(variables.varianceAmount)#
									</cfif>
								</td>
							</tr>
						<cfif show.pound>    <!--- 35547 --->
							<tr class="underLineRow">
								<td><b>#label.pound_plural#</b></td>
								<td align="right">
								<cfset variables.claimPoundsmodified = variables.claimPounds>
									<cfif variables.claimPounds lt 0>
										<cfset variables.claimPoundsmodified = variables.claimPounds * -1 />
										<span style="color:##FF0000">[ #numberFormat(variables.claimPoundsmodified, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.claimPounds, ',.__')#
									</cfif>
								</td>
								<td align="right">
								<cfset variables.itemizedPoundsmodified = variables.itemizedPounds>
									<cfif variables.itemizedPounds lt 0>
										<cfset variables.itemizedPoundsmodified = variables.itemizedPounds * -1 />
										<span style="color:##FF0000">[ #numberFormat(variables.itemizedPoundsModified, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.itemizedPounds, ',.__')#
									</cfif>
								</td>
								<td align="right">
									<cfset variables.variancePounds = variables.variancePounds * 100>
									<cfset variables.variancePounds = round(variables.variancePounds) />
									<cfset variables.variancePounds = variables.variancePounds / 100>

									<cfif variables.itemizedAmount lt 0>
									<cfset variables.variancePounds = variables.claimPoundsmodified + variables.itemizedPoundsmodified />
								<cfelse>
									<cfset variables.variancePounds = variables.claimPoundsmodified - variables.itemizedPoundsmodified />
								</cfif>

									<!---if the value is negative then change the display format--->
									<cfif variables.variancePounds lt 0>
										<cfset variables.variancePounds = variables.variancePounds * -1 />
										<span style="color:##FF0000">[ #numberFormat(variables.variancePounds, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.variancePounds, ',.__')#
									</cfif>
								</td>
							</tr>
						</cfif>
						<cfif show.case>    <!--- 35547 --->
							<tr class="underLineRow">
								<td><b>#label.case_plural#</b></td>
								<td align="right">
								<cfset variables.claimCasesmodified = variables.claimCases>
									<cfif variables.claimCases lt 0>
										<cfset variables.claimCasesmodified = variables.claimCases * -1 />
										<span style="color:##FF0000">[ #numberformat(variables.claimCasesmodified, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.claimCases, ',.__')#
									</cfif>
								</td>
								<td align="right">
								<cfset variables.itemizedCasesmodified = variables.itemizedCases>
									<cfif variables.itemizedCases lt 0>
										<cfset variables.itemizedCases = variables.itemizedCases * -1 />
										<span style="color:##FF0000">[ #numberformat(variables.itemizedCases, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.itemizedCases, ',.__')#
									</cfif>
								</td>
								<td align="right">
									<cfset variables.varianceCases = variables.varianceCases * 100>
									<cfset variables.varianceCases = round(variables.varianceCases) />
									<cfset variables.varianceCases = variables.varianceCases / 100>

									<cfif variables.itemizedCases lt 0>
									<cfset variables.varianceCases = variables.claimCases + variables.itemizedCasesmodified />
										<cfelse>
									<cfset variables.varianceCases = variables.claimCases - variables.itemizedCasesmodified />
									</cfif>

									<!---if the value is negative then change the display format--->
									<cfif variables.varianceCases lt 0>
										<cfset variables.varianceCases = variables.varianceCases * -1 />
										<span style="color:##FF0000">[ #numberformat(variables.varianceCases, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.varianceCases, ',.__')#
									</cfif>
								</td>
							</tr>
						</cfif>
						</table>
					</td><td>
						<table border="0" cellpadding="4" cellspacing="0" width="330" align="center">
							<!---/////////////STATUS///////////////--->
							<tr class="underLineRow">
								<td colspan="100%"><span style="font-size:14px"><b>Customer Claim vs. System</b></span></td>
							</tr>
							<tr class="underLineRow">
								<td>&nbsp;</td>
								<cfif Get_Billback_Info.Scheduled_Auto_BB>
									<td align="right"><b><u>Paid Amount</u></b></td>
								<cfelse>
									<td align="right"><b><u>System Total</u></b></td>
								</cfif>
								<td align="right"><b><u>Claim Summary</u></b></td>
								<td align="right"><b><u>Variance</u></b></td>
							</tr>
							<tr class="underLineRow">
								<td><b>$ Amount</b></td>
								<td align="right">
									<!---if the value is negative then change the display format--->
									<cfif variables.statusItemizedAmount lt 0>
										<cfset variables.tmpStatusItemizedAmount = variables.statusItemizedAmount * -1 />
										<span style="color:##FF0000">$[ #numberFormat(variables.tmpStatusItemizedAmount, ',.__')# ]</span>
									<cfelse>
										#dollarFormat(variables.statusItemizedAmount)#
									</cfif>
								</td>
								<td align="right">
									<!---if the value is negative then change the display format--->

									<cfif variables.billbackAmount lt 0>
										<cfset variables.billbackAmountmodified = variables.billbackAmount * -1 />
										<span style="color:##FF0000">$[ #numberFormat(variables.billbackAmountmodified, ',.__')# ]</span>
									<cfelse>
										#dollarFormat(variables.billbackAmount)#
									</cfif>
									<cfif (bBillbackSalesTax EQ 1)>
									<!--- <cfif appsettings.getBillbacksSalesTax() eq 1> --->
										<!--- If the setting allows for Sales tax Info --->
										 + #trim(dollarformat(val(Get_Billback_Info.TotalTaxAmount)))# (Sales Tax) = #trim(Dollarformat(val(variables.billbackAmount) + val(Get_Billback_Info.TotalTaxAmount)))#
									</cfif>
								</td>
								<!--- <cfif variables.statusItemizedAmount lt 0>
									<cfset variables.statusVarianceAmount = variables.billbackAmountmodified + variables.statusItemizedAmount />
								<cfelse> --->
									<cfset variables.statusVarianceAmount = variables.statusItemizedAmount - variables.billbackAmount />
								<!--- </cfif> --->
								<td align="right">
									<cfset variables.statusVarianceAmount = variables.statusVarianceAmount />
									<!---if the value is negative then change the display format--->
									<cfif variables.statusVarianceAmount lt 0>
										<cfset variables.statusVarianceAmount = variables.statusVarianceAmount * -1 />
										<span style="color:##FF0000">$[ #numberFormat(variables.statusVarianceAmount, ',.__')# ]</span>
									<cfelse>
										#dollarFormat(variables.statusVarianceAmount)#
									</cfif>
								</td>
							</tr>
						<cfif show.pound>    <!--- 35547 --->
							<tr class="underLineRow">
								<td><b>#label.pound_plural#</b></td>
								<td align="right">
									<cfif variables.statusItemizedPounds lt 0>
										<cfset variables.statusItemizedPounds = variables.statusItemizedPounds * -1 />
										<span style="color:##FF0000">[ #numberFormat(variables.statusItemizedPounds, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.statusItemizedPounds, ',.__')#
									</cfif>
								</td>
								<td align="right">
									<cfif variables.claimPounds lt 0>
										<span style="color:##FF0000">[ #numberFormat(variables.claimPounds, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.claimPounds, ',.__')#
									</cfif>
								</td>
								<td align="right">
									<cfset variables.statusVariancePounds = variables.statusVariancePounds * 100>
									<cfset variables.statusVariancePounds = round(variables.statusVariancePounds) />
									<cfset variables.statusVariancePounds = variables.statusVariancePounds / 100>

									<!---if the value is negative then change the display format--->
									<cfif variables.statusItemizedPounds lt 0>
										<cfset variables.statusVariancePounds = variables.claimPounds + variables.statusItemizedPounds />
									<cfelse>
										<cfset variables.statusVariancePounds = variables.claimPounds - variables.statusItemizedPounds />
									</cfif>
									<cfif variables.statusVariancePounds lt 0>
										<cfset variables.statusVariancePounds = variables.statusVariancePounds * -1 />
										<span style="color:##FF0000">[ #numberFormat(variables.statusVariancePounds, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.statusVariancePounds, ',.__')#
									</cfif>
								</td>
							</tr>
						</cfif>

						<cfif show.case>    <!--- 35547 --->
							<tr class="underLineRow">
								<td><b>#label.case_plural#</b></td>

								<td align="right">
									<!---if the value is negative then change the display format--->
									<cfif variables.statusItemizedCases lt 0>
										<cfset variables.statusItemizedCases = variables.statusItemizedCases * -1 />
										<span style="color:##FF0000">[ #numberformat(variables.statusItemizedCases, ',.__')# ]</span>
									<cfelse>
										#numberformat(variables.statusItemizedCases, ',.__')#
									</cfif>
								</td>
								<td align="right">
									<!---if the value is negative then change the display format--->
									<cfif variables.claimCases lt 0>
										<span style="color:##FF0000">[ #numberformat(variables.claimCases, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.claimCases, ',.__')#
									</cfif>
								</td>
								<td align="right">
									<cfset variables.statusVarianceCases = variables.statusVarianceCases * 100>
									<cfset variables.statusVarianceCases = round(variables.statusVarianceCases) />
									<cfset variables.statusVarianceCases = variables.statusVarianceCases / 100>

									<!---if the value is negative then change the display format--->
									<cfif variables.statusItemizedCases lt 0>
										<cfset variables.statusVarianceCases = variables.claimCases + variables.statusItemizedCases />
									<cfelse>
										<cfset variables.statusVarianceCases = variables.claimCases - variables.statusItemizedCases />
									</cfif>
									<cfif variables.statusVarianceCases lt 0>
										<cfset variables.statusVarianceCases = variables.statusVarianceCases * -1 />
										<span style="color:##FF0000">[ #numberFormat(variables.statusVarianceCases, ',.__')# ]</span>
									<cfelse>
										#numberFormat(variables.statusVarianceCases, ',.__')#
									</cfif>
								</td>
							</tr>
						</cfif>

						</table>
						</td>
					</tr>
					</table>
					</td>
				</tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
					<td>
						<table border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td id="cellLabel">&nbsp;</td>
								<td id="dataStyle">&nbsp;</td>
							</tr>
							<tr>
								<td id="cellLabel"></td>
								<td id="dataStyle">&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<cfsilent>
					<!---Only show for paid billbacks--->
					<!---LL: handle the status for 4 --->
					<cfquery name="GetApprovedInfo" datasource="#application.datasource#">
						SELECT 	BB_Approved.*,
								isnull(cast(BB_Approved.Expected_Amount as decimal(18,2)), 0) as BB_Expected_Amount,
								isnull(cast(BB_Approved.Approved_Amount as decimal(18,2)), 0) as BB_Approved_Amount,
								isnull(cast(BB_Approved.Paid_Amount as decimal(18,2)), 0) as BB_Paid_Amount,
								_Users.Name_First,
								_Users.Name_Last,
								BB_Approved.Check_Number,
								BB_Approved.Check_Date,
								BB_Approved.Check_Amount,
								BB_Check_Status_ID,
								BB_Approved.Vendor_master_ID,
								isnull(cast(BB_Settlement.withHold_amt as decimal(18,2)),0) as  withHold_amt,
								BB_ShortPay_Reason.SP_Reason_Description,
								BB_ShortPay_Reason.SP_Reason_Code,
								Billback.Payment_Notes AS PaymentNotes<!---D31841 --->
						FROM 	BB_Approved
						INNER JOIN Billback on Billback.Billback_id = BB_Approved.Billback_ID
						LEFT JOIN	BB_Settlement ON BB_Settlement.Billback_ID = BB_Approved.Billback_ID
						LEFT JOIN  	BB_ShortPay_Reason ON BB_ShortPay_Reason.BB_ShortPay_Reason_ID = BB_Settlement.BB_ShortPay_Reason_ID
								LEFT JOIN _users ON
								_Users.User_ID = BB_Approved.User_Approved
						WHERE 	BB_Approved.Billback_ID = <CFIF Get_Billback_Info.BB_Is_Child EQ 1>'#Get_Billback_Info.BB_parent_ID#'<CFELSE>'#Billback_ID#'</CFIF>
					</cfquery>
				</cfsilent>

				<cfif Get_Billback_Info.Billback_Status_ID IS 5 or Get_Billback_Info.Billback_Status_ID IS 4>

					<tr><td colspan="3">&nbsp; </td></tr>
					<tr>
						<td COLSPAN="100%" BGCOLOR=""><B><FONT SIZE="2" COLOR="Navy">Approval Information</FONT></B><CFIF Get_Billback_Info.BB_Is_Child EQ 1><FONT COLOR="Red" SIZE="2"> This information relates to the parent billback, not the split billback.</FONT></CFIF><HR COLOR="Navy">	</td>
					</tr>

					<cfif GetApprovedInfo.Recordcount IS 1>
						<cfif not Get_Billback_Info.Scheduled_Auto_BB><!--- don't show for sched Auto BB's --->
						  <tr>
						    <td colspan="3" NOWRAP ID="cellLabel">
						    	<table width="250" border="0" align="left" cellpadding="2" cellspacing="2">
						          <tr>
						            <td width="109" nowrap="nowrap" ID="cellLabel">Expected Amount:</td>
						            <td width="307" ID="dataStyle">#trim(Dollarformat(GetApprovedInfo.BB_Expected_Amount))#</td>
						          </tr>
						          <tr>
						            <td ID="cellLabel" NOWRAP>Approved Amount:</td>
						            <td ID="dataStyle"><cfoutput>#iif((GetApprovedInfo.Approved_Amount EQ 0), DE(trim(Dollarformat(GetApprovedInfo.BB_Paid_Amount))),DE(trim(Dollarformat(GetApprovedInfo.Approved_Amount))))#</cfoutput></td>
						          </tr>
						          <tr>
						            <td ID="cellLabel">Paid Amount:</td>
						            <td ID="dataStyle">#trim(Dollarformat(GetApprovedInfo.BB_Paid_Amount))#</td>
						          </tr>
						          <cfsilent>
									<cfquery name="AdjustmentsPaidbythisBB" datasource="#application.datasource#">
										SELECT 	BB_Adjustment.Adjustment_Amount, Billback.BB_Title, Billback.BB_Date, Billback.BB_Code
										FROM 	BB_Adjustment
										INNER JOIN Billback ON Billback.Billback_ID = BB_Adjustment.Billback_ID
										AND 	Billback.Deleted = 0
										WHERE 	BB_Adjustment.Adjustment_deducted_From_BB_ID = '#Billback_ID#'
										AND 	BB_Adjustment.Deleted = 0
									</cfquery>
								</cfsilent>
								<cfif AdjustmentsPaidbythisBB.Recordcount GT 0>
									<tr>
										<td ID="cellLabel" valign="top">Adjustments Paid:</td>
										<td ID="dataStyle">
										<cfloop query="AdjustmentsPaidbythisBB">
											<strong>#AdjustmentsPaidbythisBB.BB_Code#</strong> (#AdjustmentsPaidbythisBB.BB_Title#): #lscurrencyformat(AdjustmentsPaidbythisBB.Adjustment_Amount)#
										</cfloop>
										</td>
									</tr>
								</cfif>
								<tr>
									<td nowrap="nowrap" ID="cellLabel">Adjustment Created:</td>
									<td ID="dataStyle">#trim(Dollarformat(GetApprovedInfo.Adjustment_Created))#</td>
								</tr>
								<cfif GetApprovedInfo.withHold_amt neq 0>
									<tr>
										<td ID="cellLabel" NOWRAP>Withold Amount:</td>
										<td ID="dataStyle">#trim(Dollarformat(GetApprovedInfo.withHold_amt))#<img src="/images/fill.gif" width="10">#GetApprovedInfo.SP_Reason_Code#  ::  #GetApprovedInfo.SP_Reason_Description#</td>
									</tr>
								</cfif>
								<cfif IsNumeric(GetApprovedInfo.Pullback_applied_Amount) AND GetApprovedInfo.Pullback_applied_Amount neq 0>
									<tr>
										<td ID="cellLabel" NOWRAP>#Ucase(left(appsettings.getPullbackLabel(),1))##replace(appsettings.getPullbackLabel(),left(appsettings.getPullbackLabel(),1),"",1)# Paid:</td>
										<td ID="dataStyle">#trim(Dollarformat(GetApprovedInfo.Pullback_applied_Amount))#</td>
									</tr>
								</cfif>
					        </table>
							<cfif not Get_Billback_Info.Scheduled_Auto_BB><!--- don't show for sched Auto BB's --->
								<table width="250" border="0" align="left" cellpadding="2" cellspacing="2">
								 	<cfsilent>
										<cfquery name="VolumeSums" datasource="#application.datasource#">
											SELECT	SUM(Item_Volume_Paid_CS) AS TotalPaidCS,
													SUM(Item_Volume_Paid_LB) AS TotalPaidLB,
													SUM(Item_E_Volume_CS) AS TotalExpectedCS,
													SUM(Item_E_Volume_LB) AS TotalExpectedLB,
													SUM(Item_Volume_Approved_CS) AS TotalApprovedCS,
													SUM(Item_Volume_Approved_LB) AS TotalApprovedLB,
													SUM(Item_BB_Volume_CS) AS TotalBBItemizedCS,
													SUM(Item_BB_Volume_LB) AS TotalBBItemizedLB
											FROM 	BB_Item_Final
											WHERE 	BB_Item_Final.Deleted = 0
											AND 	BB_Item_Final.Billback_ID = '#Billback_ID#'
										</cfquery>
									</cfsilent>
									<tr>
										<td id="cellLabel">Expected Volume:</td>
										<td id="dataStyle">
											<cfif show.case>    <!--- 35547 --->
												#numberformat(VolumeSums.TotalExpectedCS, '___,___,___.__')# CS
											</cfif>
											<cfif config.ViewProgramVolumeUOM eq uom.both>    <!--- 35547 --->
												-
											</cfif>
											<cfif show.pound>    <!--- 35547 --->
												#numberformat(VolumeSums.TotalExpectedLB)# LBS</td>
											</cfif>
									</tr>
									<tr>
										<td id="cellLabel">Approved Volume:</td>
										<td id="dataStyle">
											<cfif show.case>    <!--- 35547 --->
											#numberformat(VolumeSums.TotalPaidCS, '___,___,___.__')# CS
											</cfif>
											<cfif config.ViewProgramVolumeUOM eq uom.both>    <!--- 35547 --->
											-
											</cfif>
											<cfif show.pound>    <!--- 35547 --->
											#numberformat(VolumeSums.TotalPaidLB)# LBS</td>
											</cfif>
									</tr>
									<tr>
										<td id="cellLabel">Paid Volume:</td>
										<td id="dataStyle">
											<cfif show.case>    <!--- 35547 --->
											#numberformat(VolumeSums.TotalPaidCS, '___,___,___.__')# CS
											</cfif>
											<cfif config.ViewProgramVolumeUOM eq uom.both>    <!--- 35547 --->
											 -
											</cfif>
											<cfif show.pound>    <!--- 35547 --->
											#numberformat(VolumeSums.TotalPaidLB)# LBS</td>
											</cfif>
									</tr>
							  	</table>
								<table width="250" border="0" align="left" cellpadding="2" cellspacing="2">
									<tr>
										<td ID="cellLabel">Approved By:</td>
										<td ID="dataStyle">#GetApprovedInfo.Name_First# #GetApprovedInfo.Name_Last#</td>
									</tr>
									<tr>
										<td ID="cellLabel" NOWRAP>Approved Date:</td>
										<td ID="dataStyle">#dateformat(GetApprovedInfo.Date_Approved, 'MM/DD/YYYY')#</td>
									</tr>
									<tr>
										<td ID="cellLabel" NOWRAP>Payment Notes:</td>
										<td ID="dataStyle">#GetApprovedInfo.PaymentNotes#</td>		<!---D31841 --->
									</tr>
								</table>
							</td></tr></cfif> <!--- cfif not Get_Billback_Info.Scheduled_Auto_BB --->


						</cfif> <!--- cfif not Get_Billback_Info.Scheduled_Auto_BB --->
					</cfif> <!--- cfif GetApprovedInfo.Recordcount IS 1 --->
				</cfif> <!--- cfif Get_Billback_Info.Billback_Status_ID IS 5 or Get_Billback_Info.Billback_Status_ID IS 4 --->
				<!---Only for paid billbacks--->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

				<CFIF GetApprovedInfo.RecordCount GT 0>
					<cfsilent>
						<CFQUERY NAME="GetCheckInfo" DATASOURCE="#Application.Datasource#">
							SELECT  	BB_Approved.BB_Check_Status_ID,
										BB_Approved.Check_Number,
										BB_Approved.Check_Date,
										BB_Approved.Check_Amount,
										BB_Approved.Document_Number_1,
										BB_Approved.Document_Number_2,
										BB_Check_Status.BB_Check_Status
							FROM 		BB_Approved
							INNER JOIN 	BB_Check_Status ON BB_Check_Status.BB_Check_Status_ID = BB_Approved.BB_Check_Status_ID
							WHERE 		Billback_ID = '#Billback_ID#'
						</CFQUERY>
					</cfsilent>
					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
					<!--- Check Info --->
					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
					<CFIF GetCheckInfo.RecordCount GT 0>
						<tr>
							<td COLSPAN="100%" BGCOLOR=""><BR><B><FONT SIZE="2" COLOR="Navy">Settlement Information</FONT></B><HR COLOR="Navy">	</td>
						</tr>
						<tr>
							<td colspan="3">
								<table width="430" border="0" cellspacing="0" cellpadding="0"><!--- start table --->
									<tr>
										<td ID="cellLabel">Status:</td>
										<td ID="dataStyle">#GetCheckInfo.BB_Check_Status#</td>
									</tr>
									<CFIF GetCheckInfo.BB_Check_Status_ID EQ 2 OR GetCheckInfo.BB_Check_Status_ID EQ 4>
										<tr>
											<td ID="cellLabel">Amount:</td>
											<td ID="dataStyle">#DOLLARFORMAT(GetCheckInfo.Check_Amount)#</td>
										</tr>
										<tr>
											<td ID="cellLabel">Date:</td>
											<td ID="dataStyle">#DATEFORMAT(GetCheckInfo.Check_Date,"mm/dd/yyyy")#</td>
										</tr>
										<tr valign="top">
											<td ID="cellLabel">Settlement ID:<sup style="color:red">*</sup></td>
											<td ID="dataStyle">#GetCheckInfo.Check_Number#</td>
										</tr>
										<cfif GetCheckInfo.Document_Number_1 NEQ "">
										<tr valign="top">
											<td ID="cellLabel">Document ID ##1:</td>
											<td ID="dataStyle">#GetCheckInfo.Document_Number_1#</td>
										</tr>
										</cfif>
										<cfif GetCheckInfo.Document_Number_2 NEQ "">
										<tr valign="top">
											<td ID="cellLabel">Document ID ##2:</td>
											<td ID="dataStyle">#GetCheckInfo.Document_Number_2#</td>
										</tr>
										</cfif>
										<tr>
											<td colspan="2" style="color:red">
												The Settlement ID represents either the check number, credit memo number or accounting document depending on configuration.
											</td>
										</tr>
									</CFIF>
								</table><!--- end table, D12941: the iframe was not getting resized when the html was malformed (no closing table tag) --->
							</td>
						</tr>
					</CFIF>
					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
				</CFIF>

				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<!--- Payee																							 --->
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				<cfsilent>
					<!---D40664 :: Settings page to show Deleted Billbacks --->
					<cfset thisPayeeObj = CreateObject("component", "components.Billback.BillbackSummaryManager").init(Billback_ID, url.deleted_billback) >
					<cfset getPayeeInfo = thisPayeeObj.getPayeeInfo() />
					<cfset getDistList = thisPayeeObj.getMultiDistList(Billback_ID) />
					<cfset AssoOperator = thisPayeeObj.getAssoOperator(Billback_ID)>
					<cfset AssociatedDistributor = thisPayeeObj.getAssociatedDistributor(Billback_ID)>
				</cfsilent>

				<tr>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td width="250" nowrap="true"><B><FONT SIZE="2" COLOR="Navy">#application.returned_customer_setting.Billback_Payee_Label#</FONT></B></td>
					<!---<CFIF HasDefaultProgram EQ 1 AND AssoOperator.RecordCount GT 0 AND (Get_Billback_Info.Uploaded_Billback EQ 2 OR Get_Billback_Info.Uploaded_Billback EQ 3)>  ---><!--- 43579 removed HasDefaultProgram EQ 1 condition--->
					<CFIF  AssoOperator.RecordCount GT 0>
					<!--- AND (Get_Billback_Info.Uploaded_Billback EQ 2 OR Get_Billback_Info.Uploaded_Billback EQ 3 OR Get_Billback_Info.Uploaded_Billback EQ 0) -- Removed this condition  50865: Billback copy function not transferring operator info to new billback--->
						<td width="250" nowrap="true"><B><FONT SIZE="2" COLOR="Navy">#application.returned_customer_setting.operator_label_singular#</FONT></B></td>
					</cfif>
					<cfif appsettings.getVendor_Selection_Pay_Req() or application.returned_customer_setting.Upload_GL_Code eq 1 OR appSettings.getBillback_Payment_Request_Without_Vendor_Selection()>
						<cfsilent>
							<CFQUERY NAME="GetVendor" DATASOURCE="#Application.Datasource#">
								SELECT Vendor_master_ID FROM BB_Approved WHERE Billback_ID = '#Billback_ID#'
							</CFQUERY>
							<CFIF GetVendor.Vendor_master_ID EQ "">
								<CFIF Get_Billback_Info.Billback_Payee_Type_ID EQ 1>
									<cfset useLakebaseForGetVendorNum = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor")>
<cfif useLakebaseForGetVendorNum>
	<cftry>
		<cfset GetVendorNum = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor", {
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0",
				"select" = "uploaded_vendor_id"
			}), "uploaded_vendor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetVendorNum = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetVendorNum>
<CFQUERY NAME="GetVendorNum" DATASOURCE="#Application.Datasource#">
										SELECT Uploaded_Vendor_ID FROM Billback_Distributor WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0
									</CFQUERY>
</cfif>
								<CFELSEIF Get_Billback_Info.Billback_Payee_Type_ID EQ 2>
									<CFQUERY NAME="GetVendorNum" DATASOURCE="#Application.Datasource#">
										SELECT Uploaded_Vendor_ID FROM Billback_Operator WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0
									</CFQUERY>
								<CFELSEIF Get_Billback_Info.Billback_Payee_Type_ID EQ 3>
									<CFQUERY NAME="GetVendorNum" DATASOURCE="#Application.Datasource#">
										SELECT Uploaded_Vendor_ID FROM Billback_Broker WHERE Billback_ID = '#Billback_ID#' AND Deleted = 0
									</CFQUERY>
								</CFIF>
							</CFIF>
						</cfsilent>
						<cfif GetVendor.Vendor_Master_ID NEQ "" OR
								(	(Get_Billback_Info.Billback_Payee_Type_ID EQ 1 OR Get_Billback_Info.Billback_Payee_Type_ID EQ 2 OR Get_Billback_Info.Billback_Payee_Type_ID EQ 3)
									 AND
									GetVendorNum.Uploaded_Vendor_ID NEQ ""
								)>
							<td><B><FONT SIZE="2" COLOR="Navy">#variables.VendorLabel#</FONT></B></td>
						</cfif>
					</cfif>
				</tr>
				<tr>
					<td colspan="100%"><HR COLOR="Navy"></td>
				</tr>
				<tr>
					<td width="250" nowrap="true" id="dataStyle">
						<CFIF getPayeeInfo.RECORDCOUNT GT 0>
							<cfif getPayeeInfo.Billback_Payee_Type_ID eq 1><!--- Distributor --->
							<a href="javascript:(void);" onclick="javascript:window.open('/profiles/Distributors/Distributor_profile.cfm?DID=#getPayeeInfo.BB_Payee_ID#','viewdist','toolbar=no,width=400,height=450,location=no,menubar=no,resizable=yes,scrollbars=yes');return false"><span style="color: black">#getPayeeInfo.Payee_Name#</span></a>
							<cfelseif getPayeeInfo.Billback_Payee_Type_ID eq 2><!--- Operator --->
							<a href="javascript:(void);" onclick="javascript:window.open('/profiles/Operators/Operator_profile.cfm?OID=#getPayeeInfo.BB_Payee_ID#','viewdist','toolbar=no,width=400,height=450,location=no,menubar=no,resizable=yes,scrollbars=yes');return false"><span style="color: black">#getPayeeInfo.Payee_Name#</span></a>
							<cfelse>#getPayeeInfo.Payee_Name#
							</cfif>
							 <cfif getPayeeInfo.Payee_ShipTo is not ''> &nbsp;(#getPayeeInfo.Payee_ShipTo#) </cfif>
							<CFIF Len(Trim(getPayeeInfo.City)) GT 0 AND Len(Trim(getPayeeInfo.State_Code)) GT 0>
								<BR>#getPayeeInfo.City#,#getPayeeInfo.State_Code#
							</CFIF>
						<CFELSE>
							<B><FONT COLOR="Red">NONE SUPPLIED</FONT></B>
						</CFIF>
					</td>

					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
					<!--- Operator Info --->
					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

					<!--- Dev Notes: Ana 11041 Uploaded Operators --->
					<cfset useLakebaseForDefaultBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForDefaultBB>
	<cftry>
		<cfset DefaultBB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "default_program,use_dflt_prg"
			}), "default_program,use_dflt_prg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDefaultBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDefaultBB>
<cfquery name="DefaultBB" datasource="#application.datasource#">
						SELECT Default_Program,USE_DFLT_PRG FROM Billback_Settings
					</cfquery>
</cfif>
 					<!--- <CFIF HasDefaultProgram EQ 1 AND AssoOperator.RecordCount GT 0 AND (Get_Billback_Info.Uploaded_Billback EQ 2 OR Get_Billback_Info.Uploaded_Billback EQ 3)> ---><!--- 43579 removed HasDefaultProgram EQ 1 condition--->
					<CFIF  AssoOperator.RecordCount GT 0>
					<!--- AND (Get_Billback_Info.Uploaded_Billback EQ 2 OR Get_Billback_Info.Uploaded_Billback EQ 3 OR Get_Billback_Info.Uploaded_Billback EQ 0) -- Removed this condition  50865: Billback copy function not transferring operator info to new billback --->
						<td width="250" nowrap="true" id="dataStyle">
							<CFIF AssoOperator.RecordCount EQ 1>
								#AssoOperator.Operator_name# (#AssoOperator.Legacy_ID#)
							<CFELSE>
								<CF_openLayer
									Border="Yes"
									BorderSize="1"
									BorderColor="orange"
									Image="/images/plus2.gif"
									ImageOpen="/images/minus2.gif"
									Title="Hide #application.returned_customer_setting.operator_label_plural#:"
									TitleClosed="Show #application.returned_customer_setting.operator_label_plural#:"
									TitleTooltip="Click to Show/Hide #application.returned_customer_setting.operator_label_plural#"
									TitleFont="font"
									TitleColor="Blue"
									TitleSize="9"
									IsClosed="Yes"
									Width="93%">
									<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
										<CFLOOP Query="AssoOperator">
											<tr>
												<td VALIGN="Top">#Operator_name# (#Legacy_ID#) </td>
											</tr>
										</CFLOOP>
									</TABLE>
								</CF_openLayer>
							</CFIF>
						</td>
					</CFIF>

					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
					<!--- Vendor Info --->
					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
					<CFIF appsettings.getVendor_Selection_Pay_Req() OR application.returned_customer_setting.Upload_GL_Code EQ 1 OR appSettings.getBillback_Payment_Request_Without_Vendor_Selection()>
							<cfsilent>
							<CFIF (isDefined("GetVendor.Vendor_master_ID") AND GetVendor.Vendor_master_ID EQ "")>
								<CFIF isDefined("GetVendorNum.Uploaded_Vendor_ID") AND GetVendorNum.Uploaded_Vendor_ID NEQ "" AND (Get_Billback_Info.Billback_Payee_Type_ID EQ 1 OR Get_Billback_Info.Billback_Payee_Type_ID EQ 2 OR Get_Billback_Info.Billback_Payee_Type_ID EQ 3)>
									<cfset useLakebaseForGetVendorInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
<cfif useLakebaseForGetVendorInfo>
	<cftry>
		<cfset GetVendorInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vendor_master", {
				"vendor_id" = "eq.#GetVendorNum.Uploaded_Vendor_ID#",
				"select" = "vendor_name,vendor_id,active_code,address_1,address_2,city,state,zipcode"
			}), "vendor_name,vendor_id,active_code,address_1,address_2,city,state,zipcode"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetVendorInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetVendorInfo>
<CFQUERY NAME="GetVendorInfo" DATASOURCE="#Application.Datasource#">
										SELECT 		Vendor_Name,
												Vendor_Master.Vendor_ID,
												Active_Code,
												Address_1,
												Address_2,
												City,
												State,
												Zipcode

									FROM		Vendor_Master
									WHERE 	Vendor_Master.Vendor_ID = '#GetVendorNum.Uploaded_Vendor_ID#'
									</CFQUERY>
</cfif>
								</CFIF>
							<CFELSEIF (isDefined("GetVendor.Vendor_master_ID") AND GetVendor.Vendor_master_ID NEQ "")>
								<CFQUERY NAME="GetVendorInfo" DATASOURCE="#Application.Datasource#">
									SELECT 		Vendor_Name,
												Vendor_Master.Vendor_ID,
												Active_Code,
												Address_1,
												Address_2,
												City,
												State,
												Zipcode

									FROM		Vendor_Master
									WHERE 		Vendor_Master_ID = '#GetVendor.Vendor_master_ID#'
								</CFQUERY>
							</CFIF>
							</cfsilent>
              <!---
              Dev Notes: Anand Rao/22062/18-Jan-09 Solo PRD - Event error Element VENDOR_ID is undefined in GETVENDORINFO
              Added the isDefined condition to check if the Variable existed before checking for a value
              --->
  					  <CFIF ((isDefined("GetVendorInfo.Vendor_ID")) AND (GetVendorInfo.Vendor_ID NEQ ""))>
							<td width="250" nowrap="true">
								<CFIF GetVendorInfo.RECORDCOUNT GT 0>
									<FONT SIZE="1">
										#GetVendorInfo.Vendor_Name# (#GetVendorInfo.Vendor_ID#)
										<BR>#GetVendorInfo.Address_1#<CFIF GetVendorInfo.Address_2 NEQ "">, #GetVendorInfo.Address_2#,</CFIF><BR>#GetVendorInfo.City#, #GetVendorInfo.State#, #GetVendorInfo.Zipcode#
									</FONT>
								<CFELSE>
									<B><FONT COLOR="Red">NONE SUPPLIED</FONT></B>
								</CFIF>
							</td>
						</CFIF>
					</CFIF>
					<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
				</tr>

              <!---
              	Dev Notes: Anand Rao/24-Jul-13/D38473: EDI -- 'USE DEFAULT PROGRAM IF OPERATOR AND/OR DISTRIBUTOR IS INVALID'
              --->
			<cfif HasDefaultProgram EQ 1 AND GetBillbackSettings.USE_DFLT_PRG EQ 1 AND Get_Billback_Info.Uploaded_Billback EQ 3 AND AssociatedDistributor.RecordCount GT 0 >
				<tr>
					<td colspan="100%" valign="top">
						<B><FONT SIZE="2" COLOR="Navy">#application.returned_customer_setting.distributor_label_singular#</FONT></B>
					</td>
				<tr>
				<tr>
					<td colspan="100%"><HR COLOR="Navy"></td>
				</tr>
				<tr>
					<td colspan="100%" nowrap="true" id="dataStyle" >
						<CFIF AssociatedDistributor.RecordCount EQ 1>
							<cfif AssociatedDistributor.Ship_Name NEQ "">
								#AssociatedDistributor.Ship_Name# (#AssociatedDistributor.Ship_To# )
							<cfelse>
								NONE
							</cfif>
						<CFELSE>
							<CF_openLayer
								Border="Yes"
								BorderSize="1"
								BorderColor="orange"
								Image="/images/plus2.gif"
								ImageOpen="/images/minus2.gif"
								Title="Hide #application.returned_customer_setting.distributor_label_plural#:"
								TitleClosed="Show #application.returned_customer_setting.distributor_label_plural#:"
								TitleTooltip="Click to Show/Hide #application.returned_customer_setting.distributor_label_plural#"
								TitleFont="font"
								TitleColor="Blue"
								TitleSize="9"
								IsClosed="Yes"
								Width="30%">
								<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
									<CFLOOP Query="AssociatedDistributor">
										 <cfif Ship_Name NEQ "">
											<tr>
												<td VALIGN="Top">#Ship_Name# (#Ship_To#) </td>
											</tr>
										</cfif>
									</CFLOOP>
								</TABLE>
							</CF_openLayer>
						</CFIF>
					</td>
				</tr>
			</cfif>
</cfoutput>

	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<!--- Distributor Info --->
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<!---from now on, use billback summary manager component --->
	<cfoutput>
		<tr>
			<td COLSPAN="100%">
				<BR>
				<B><FONT SIZE="2" COLOR="Navy">#application.returned_customer_setting.distributor_label_plural#</FONT></B><HR COLOR="Navy">
				<cfset HasDistributorInfo = 0>

				<!--- if this is a multi distributor BB, show the list else show single	 :: 	#thisPayeeObj.getPayeeType()# ::--->
				<!--- Dev Note(78635): For "vendor only billbacks", we do not need to show the "Distributor" section --->
				<cfif variables.VendorOnlyBillback eq 0>
					<cfif thisPayeeObj.getPayeeType() EQ 1 or thisPayeeObj.getPayeeType() EQ 5 or thisPayeeObj.getPayeeType() EQ 2 or thisPayeeObj.getPayeeType() EQ 3>

						<cfif getDistList.RECORDCOUNT GT 0>
							<cfset HasDistributorInfo = 1>
							<!---Format distributors like we do in programs--->
							<TABLE border="0"  cellspacing="3" cellpadding="3" WIDTH="100%">
								<CFLOOP QUERY="getDistList">
									<!---handle what gets passed to the distributor profile popup based on groups--->
									<td CLASS="dataStyle" WIDTH="33%" VALIGN="top" BGCOLOR="F2F2F2">
										<cfif getDistList.is_group eq 1>
											<a href="javascript:(void);" onclick="javascript:window.open('ShowGroupDistList.cfm?billback_id=#Billback_ID#','viewgrouplist','toolbar=no,width=1024,height=660,location=no,menubar=yes,resizable=yes,scrollbars=yes');return false"><span style="color: black">#getDistList.Name#</span></a>
										<cfelse>
											<a href="javascript:(void);" onclick="javascript:window.open('/profiles/Distributors/Distributor_profile.cfm?DID=#getDistList.BSA_Foodservice_Customers_ID#','viewdist','toolbar=no,width=400,height=450,location=no,menubar=no,resizable=yes,scrollbars=yes');return false"><span style="color: black">#getDistList.Name#</span></a>
												&nbsp;(#getDistList.Shr_Ship_To#)
										</cfif>

										<span>
											<FONT SIZE="1">
												<CFIF getDistList.CITY NEQ "" AND getDistList.STATE NEQ "">
													<BR>#getDistList.City#, #getDistList.State#
												</CFIF>
											</FONT>
										</span>
									</td>
									<CFIF getDistList.CURRENTROW MOD 3><CFELSE></tr><tr></CFIF>
								</CFLOOP>
							</TABLE>
							<!---End distributor display --->

						<cfelseif getPayeeInfo.RECORDCOUNT GT 0 and thisPayeeObj.getPayeeType() NEQ 2>
							<cfset HasDistributorInfo = 1>
							<FONT SIZE="1">
								#getPayeeInfo.Payee_Name# <cfif getPayeeInfo.Payee_ShipTo is not ''> &nbsp;(#getPayeeInfo.Payee_ShipTo#) </cfif>
								<CFIF Len(Trim(getPayeeInfo.City)) GT 0 AND Len(Trim(getPayeeInfo.State_Code)) GT 0>
									<BR>#getPayeeInfo.City#,#getPayeeInfo.State_Code#
								</CFIF>
							</FONT>
						</cfif> <!--- getDistList.RECORDCOUNT GT 0 --->
					</cfif>
				</cfif>

				<!---get associated distributor information for this operator---->
				<cfif variables.VendorOnlyBillback eq 0>
					<cfif (thisPayeeObj.getPayeeType() EQ 2 or thisPayeeObj.getPayeeType() EQ 4) AND HasDistributorInfo EQ 0>
						<cfif thisPayeeObj.getHasOperatorAsscoiateDistributor()>
						<cfset HasDistributorInfo = 1>
							<FONT SIZE="1">
								#getPayeeInfo.Associated_Dist_Name# <cfif getPayeeInfo.Associated_Payee_ShipTo is not ''> &nbsp;(#getPayeeInfo.Associated_Payee_ShipTo#) </cfif>
								<CFIF Len(Trim(getPayeeInfo.Associated_Dist_City)) GT 0 AND Len(Trim(getPayeeInfo.Associated_Dist_State)) GT 0>
									<BR>#getPayeeInfo.Associated_Dist_City#,#getPayeeInfo.Associated_Dist_State#
								</CFIF>
							</FONT>
						</cfif>
					</cfif>
				</cfif>
				<cfif HasDistributorInfo IS 0>
					<B><FONT COLOR="Red">NONE SUPPLIED</FONT></B>
				</cfif>
			</td>
		</tr>
	</cfoutput>


	<!--- OPERATOR Information --->
	<cfoutput>
		<tr>
			<td COLSPAN="100%">
				<BR>
				<cfset HasOperatorInfo = 0>

				<cfquery dataSource="#application.datasource#" NAME="getUseGPO">
					SELECT	dbo.udf_UseGPO('#Billback_ID#', #Get_Billback_Info.Uploaded_Billback#) as UseGPO
				</CFQUERY>
				<cfset bUseGPO = getUseGPO.UseGPO />
				<cfset displayBILOperators = 0 />
 				<cfif appSettings.getViewOperatorinBillbackDeviation() OR bUseGPO EQ 1>
					<cfset displayBILOperators = 1 />
					<cfquery name="getAllOperators" datasource="#application.datasource#">
						SELECT DISTINCT BBIIL.Operator_ID AS BSA_Operator_ID,
										BSAOP.Legacy_ID,
										BSAOP.Operator_Name
						FROM BB_Item_Invoice_Level BBIIL
							INNER JOIN BSA_OPERATOR BSAOP ON BSAOP.bsa_Operator_Id = BBIIL.Operator_ID
						WHERE 	BBIIL.Billback_ID = <cfqueryparam value = "#Billback_ID#" cfsqltype = 'cf_sql_varchar'>
						ORDER BY Operator_Name
					</cfquery>
				</cfif>

				<cfif ((!displayBILOperators) OR (displayBILOperators AND getAllOperators.RecordCount EQ 0))>
					<cfquery name="getAllOperators" datasource="#application.datasource#">
						<!---32752 - Modified to show operator group not the members in the group--->
						SELECT DISTINCT CASE CONTRACT_OPERATORS.Is_Group
						                  WHEN 1 THEN PG_OPERATOR_CATEGORY.pg_Operator_Category_Name
						                  ELSE BSA_OPERATOR.Operator_Name
						                END  AS Operator_Name
						                ,BSA_OPERATOR.Legacy_Id
						                ,CASE CONTRACT_OPERATORS.Is_Group
						                   WHEN 1 THEN PG_OPERATOR_CATEGORY.pg_Operator_Category_Code
						                   ELSE COALESCE( NULLIF( BSA_OPERATOR.Legacy_Id, '' ), Cast( BSA_OPERATOR.bsa_Operator_Id AS CHAR( 50 )) )
						                 END AS bsa_operator_id
						  FROM BILLBACK_PROGRAM
						       INNER JOIN CONTRACT_OPERATORS ON CONTRACT_OPERATORS.Contract_Main_Id = BILLBACK_PROGRAM.Program_Id
						                                        AND CONTRACT_OPERATORS.Deleted = 0
						                                        AND CONTRACT_OPERATORS.Captured_From_Group = 0
						       LEFT JOIN BSA_OPERATOR ON BSA_OPERATOR.bsa_Operator_Id = CONTRACT_OPERATORS.bsa_Operator_Id
						                                 AND CONTRACT_OPERATORS.Is_Group = 0
						       LEFT JOIN PG_OPERATOR_CATEGORY ON PG_OPERATOR_CATEGORY.pg_Operator_Category_Id = CONTRACT_OPERATORS.Operator_Group_Id
						                                         AND CONTRACT_OPERATORS.Is_Group = 1
						 WHERE BILLBACK_PROGRAM.Deleted = 0
						       AND BILLBACK_PROGRAM.BillBack_Id = <cfqueryparam value = "#Billback_ID#" cfsqltype = 'cf_sql_varchar'>
						 ORDER BY Operator_Name
					</cfquery>
				</cfif>

				<B><FONT SIZE="2" COLOR="Navy">#application.returned_customer_setting.operator_label_plural#</FONT></B>
				<cfif getAllOperators.recordcount>
					<a href="##" id="toggleOperators" style="margin-left:10px;"></a>
				</cfif>
				<HR COLOR="Navy">
				<CFIF getAllOperators.RECORDCOUNT GT 0>
					<cfset HasOperatorInfo = 1>
					<!---Format operators like we do in programs--->
					<TABLE id="eligibleOperators" border="0"  cellspacing="3" cellpadding="3" WIDTH="100%">
						<CFLOOP QUERY="getAllOperators">
						<!---handle what gets passed to the distributor profile popup based on groups--->
							<td CLASS="dataStyle" WIDTH="33%" VALIGN="top" BGCOLOR="F2F2F2">
								<span>
									<FONT SIZE="1">
										#trim(getAllOperators.Operator_Name)#
										<cfif application.returned_customer_setting.operator_legacy_id_on AND len(trim(getAllOperators.Legacy_ID)) GT 0>
											(#trim(getAllOperators.Legacy_ID)#)
										<cfelse>
											(#trim(getAllOperators.BSA_Operator_ID)#)
										</cfif>
									</FONT>
								</span>
							</td>
						<CFIF getAllOperators.CURRENTROW MOD 3><CFELSE></tr><tr></CFIF>
						</CFLOOP>
					</TABLE>
				</CFIF>

				<cfif getAllOperators.recordcount IS 0>
					<B><FONT COLOR="Red">NONE SUPPLIED</FONT></B>
				</cfif>
			</td>
		</tr>
	</cfoutput>

	<cfsilent>
	<CFIF Get_Billback_Info.BB_Is_Child EQ 1>
		<cfset useLakebaseForGetParentInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetParentInfo>
	<cftry>
		<cfset GetParentInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Get_Billback_Info.BB_Parent_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetParentInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetParentInfo>
<CFQUERY NAME="GetParentInfo" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Billback WHERE Billback_ID = '#Get_Billback_Info.BB_Parent_ID#'
		</CFQUERY>
</cfif>
		<cfset OriginalBBID = Billback_ID>
		<cfset Billback_ID = Get_Billback_Info.BB_parent_ID>
	</CFIF>
	</cfsilent>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Programs and Products																			 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<tr>
		<td COLSPAN="100%">
			<BR>
			<B>
				<FONT SIZE="2" COLOR="Navy">Programs and Products</FONT>
			</B>
				<CFIF Get_Billback_Info.BB_Is_Child EQ 1><FONT COLOR="Red" SIZE="2"> This information relates to the parent billback, not the split billback.</FONT></CFIF>
			<HR COLOR="Navy">
		</td>
	</tr>
</TABLE>

<cfif ShowDetails EQ 1>

	<cfsilent>
		<!--- Dev Note: 10748 Milan (New bb display doesn't show items w/claim adjustment)--->
		<cfset Include_Claim_Adjustment = 1>
		<cfset Get_Program_Lumpsum_Products = thisPayeeObj.Get_Program_Lumpsum_Products(Billback_ID) />
		<cfset Get_Program_Lumpsum = thisPayeeObj.Get_All_Program_Lumpsum(Billback_ID) />
		<cfset Get_Program_Products = thisPayeeObj.Get_Program_Products(Billback_ID,getDistList.Distributor_ID,getSubtotalDisplaySettings.Display_Product_Group_BB,getSubtotalDisplaySettings.Group_Claim_By_Product_Attribute,Include_Claim_Adjustment) />
		<cfset Get_Program_Growth = thisPayeeObj.Get_Program_Growth(Billback_ID) />
		<cfset Discount_Type_List="Fixed Price, #Application.RebateLabel#, #Application.LumpsumLabel#, Growth, Formula Price,6,7,8,9,Claim Adjustment,Bid Request">
	</cfsilent>

	<cfsilent>
		<cfset Total_Billback_Amount = 0>
		<cfset Total_Billback_Deviation = 0>
	</cfsilent>

	<!--- this table contains only the column heading --->
	<TABLE CELLPADDING="2" id="programsproducts-top" CELLSPACING="0" BORDER="0" WIDTH="98%" <cfif url.SHOW_PRINT_VERSION or url.show_email_version> align="center"</cfif>>
		<cfsavecontent variable="variables.prog_prod_header">
				<!--- 01 ---><td WIDTH="25%" nowrap>&nbsp;</td>
				<cfoutput>
			<cfif show.pound>    <!--- 35547 --->
				<!--- 02 ---><td width="8%" align="right"><b>#label.pound_plural#</b></td>
			</cfif>
			<cfif show.case>    <!--- 35547 --->
				<!--- 03 ---><td width="8%" align="right"><b>#label.case_plural#</b></td>
			</cfif>
				<!--- 04 ---><td width="9%" align="right"><b>Expected</b></td>
			<cfif show.pound>    <!--- 35547 --->
				<!--- 05 ---><td width="8%" align="right"><b>#label.pound_plural#</b></td>
			</cfif>
			<cfif show.case>    <!--- 35547 --->
				<!--- 06 ---><td width="8%" align="right"><b>#label.case_plural#</b></td>
			</cfif>
				<!--- 07 ---><td width="9%" align="right"><b>Claimed</b></td>
			<cfif show.pound>    <!--- 35547 --->
				<!--- 08 ---><td width="8%" align="right"><b>#label.pound_plural#</b></td>
			</cfif>
			<cfif show.case>    <!--- 35547 --->
				<!--- 09 ---><td width="8%" align="right"><b>#label.case_plural#</b></td>
			</cfif>
				</cfoutput>
				<!--- 10 ---><td width="9%" align="right"><b>Paid</b></td>
		</cfsavecontent>
		<cfoutput><tr bgcolor="ffce84">#application.util.string.compress( variables.prog_prod_header  )#</tr></cfoutput>
	</table>

	<div <cfif url.SHOW_PRINT_VERSION EQ 0 and url.show_email_version EQ 0> style="height:550px;overflow-y:auto;" <cfelse> <cfset request.print_or_email = 1> </cfif> >  <!--- 50922 apply fixed height to display mode (not printing, not emailing) --->
	<!--- this table contains only the table body without the columns heading --->
	<TABLE CELLPADDING="2" id="programsproducts" CELLSPACING="0" BORDER="0" WIDTH="98%" <cfif url.SHOW_PRINT_VERSION or url.show_email_version> align="center"</cfif>>
	<tbody>
		<cfsilent>
			<cfset useLakebaseForgetGroupDistintItemDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_program_products")>
<cfif useLakebaseForgetGroupDistintItemDetails>
	<cftry>
		<cfset getGroupDistintItemDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_program_products", {
				"select" = "item_bb_volume_cs,item_bb_volume_lb,item_expected_volume_cs,item_expected_volume_lb,item_approved_volume_cs,item_approved_volume_lb,group_id,billback_program_id,billback_product_id,dist_id,isproductonprogram,legacy_id"
			}), "item_bb_volume_cs,item_bb_volume_lb,item_expected_volume_cs,item_expected_volume_lb,item_approved_volume_cs,item_approved_volume_lb,group_id,billback_program_id,billback_product_id,dist_id,isproductonprogram,legacy_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGroupDistintItemDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGroupDistintItemDetails>
<cfquery name="getGroupDistintItemDetails" dbtype="query">
				select distinct Item_BB_Volume_CS, Item_BB_Volume_LB,
				Item_Expected_Volume_CS,Item_Expected_Volume_LB,
				Item_Approved_Volume_CS,Item_Approved_Volume_LB,group_id,billback_program_id,
				Billback_Product_ID,dist_id,IsProductOnProgram,Legacy_ID
				from Get_Program_Products
			</cfquery>
</cfif>
		</cfsilent>

		<CFIF Get_Program_Products.RecordCount GT 0>
			<cfsilent>
				<cfset total_BB_approved_volume_lb = 0>
				<cfset total_BB_approved_volume_cs = 0>
				<cfset total_BB_expected_volume_lb = 0>
				<cfset total_BB_expected_volume_cs = 0>
				<cfset total_BB_claimed_volume_lb = 0>
				<cfset total_BB_claimed_volume_cs = 0>
				<cfset Total_Expected_Amount = 0>
				<cfset Total_Claimed_Amount = 0>
				<cfset Total_Approved_Amount = 0>
				<cfset Total_Approved_Billback_Amount = 0>
				<!--- Distributor related variables --->
				<cfset Group_BB_approved_volume_lb = 0>
				<cfset Group_BB_approved_volume_cs = 0>
				<cfset Group_BB_expected_volume_lb = 0>
				<cfset Group_BB_expected_volume_cs = 0>
				<cfset Group_BB_claimed_volume_lb = 0>
				<cfset Group_BB_claimed_volume_cs = 0>
				<cfset Group_Expected_Amount = 0>
				<cfset Group_Claimed_Amount = 0>
				<cfset Group_Approved_Amount = 0>
			</cfsilent>

			<CFOUTPUT QUERY="Get_Program_Products" GROUP="Billback_Program_ID">
				<CF_CRYP type="en" string="#Get_Program_Products.Contract_Main_ID#" key="#request.key#">
				<cfset CID = cryp.value>

				<cfsilent>
					<cfset Total_Approved_Program_Amount = 0>
					<cfset Total_Expected_Program_Amount = 0>
					<cfset Total_Claimed_Program_Amount = 0>
					<cfset windowWidth = 815>
					<cfset windowHeight = 650>
				</cfsilent>

				<tr CLASS="programTD">
					<td COLSPAN="100%" style="font-size:9px">
						<!--- D48987 :: Program Revision History Link inside Billback  Page --->
						<font color="660033">[</font>
						<A onClick="javaScript: NewWindow(this.href , 'Program_View' , #windowWidth# , #windowHeight# , 'yes' , 'yes'); return false;" target="_blank" HREF="/CID_Wrapper.cfm?Program_ID=#Get_Program_Products.contract_main_id#&Page_Relocate=/scorecard/program_display.cfm"  STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #Get_Program_Products.Program_Number#"><b>#Get_Program_Products.Program_Number#</b><!--- </font> ---></A>
						<font color="660033">]&nbsp;
						#Get_Program_Products.Program_Title# -- #dateformat(Get_Program_Products.Start_Date, 'mm/dd/yyyy')# to #dateformat(Get_Program_Products.End_Date, 'mm/dd/yyyy')#</font>

						<!---Get SAP approval number (Pactiv only) D10829 --->
						<cfquery name="GetSAPApproval" datasource="#application.datasource#">
							SELECT DISTINCT Pactiv_Program_ID
							FROM program_webservices_error_detail
							INNER JOIN Billback_Program_Payment_Period
							ON Billback_Program_Payment_Period.BSA_Program_ID = program_webservices_error_detail.BSA_Program_ID
							And Billback_Program_Payment_Period.Billback_ID = '#Billback_ID#'
							WHERE Message_Type = 'S'
						</cfquery>
						<cfif GetSAPApproval.recordcount GT 0>
							<br>
							<strong>SAP Approval Number: #GetSAPApproval.Pactiv_Program_ID#</strong>
						</cfif>
						<!--- START: 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] - Anand Rao/19-Jun-2018 --->
						<cfset editDC = 0 />
						<cfif (Get_Profile_Settings.BB_Display_Dist_Channel_Per_Program_Distributor EQ '1' AND ShowEditLink EQ 1 AND Get_Billback_Info.BB_Payment_Request_Sent EQ 0)>
							<cfset editDC = 1 />
						</cfif>
						<cfif (isdefined("Get_Program_Products.BS_Var_2") AND appSettings.get_Setting('BB_Display_Dist_Channel_Per_Program_Distributor') EQ '1')>
						<div style="float: right;" align="right"><a href="##" onclick="openDC('#JSSTRINGFORMAT(Get_Billback_Info.Billback_ID)#','#JSSTRINGFORMAT(Get_Program_Products.Billback_Program_ID)#','#JSSTRINGFORMAT(Get_Program_Products.Program_ID)#','#editDC#')" title="View <cfif (editDC EQ 1)>/Edit</cfif> #qGetBSVar2Label.General_Labels_Label# "><strong>#qGetBSVar2Label.General_Labels_Label#</strong></a>&nbsp;&nbsp;</div>
						</cfif>
  						<!--- END: 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] - Anand Rao/19-Jun-2018 --->
					</td>
				</tr>

				<!---------- Start Products --------------->
				<cfoutput group="dist_id">
					<!--- Dev Note: Kal; 13585 - Resetting Distributor related variables and the sub-totals were being carried over to next section --->
					<cfset Group_BB_approved_volume_lb = 0>
					<cfset Group_BB_approved_volume_cs = 0>
					<cfset Group_BB_expected_volume_lb = 0>
					<cfset Group_BB_expected_volume_cs = 0>
					<cfset Group_BB_claimed_volume_lb = 0>
					<cfset Group_BB_claimed_volume_cs = 0>
					<cfset Group_Expected_Amount = 0>
					<cfset Group_Claimed_Amount = 0>
					<cfset Group_Approved_Amount = 0>

					<cfset ProductNotOnProgramCount = 0>
					<cfset UnKnowProductCount = 0>
					<cfset productcount = 0>
					<cfsilent>
						<cfquery name="getdistdetails" dbtype="query">
							select sum(Billback_rate) as claimed_amount,
							sum(Item_E_Volume * Expected_Rate) as expected_amount,
							sum(Item_Approved_Volume * Approved_rate) as approved_amount
							from Get_Program_Products where dist_id = '#Get_Program_Products.dist_id#'
							and billback_program_id = '#Get_Program_Products.billback_program_id#'
							AND IsProductOnProgram = #Get_Program_Products.IsProductOnProgram#
						</cfquery>

						<cfquery name="getdistvolumedetails" dbtype="query">
							select
							SUM(Item_BB_Volume_CS) as claimed_volume_cs,
							SUM(Item_BB_Volume_LB) as claimed_volume_lb,
							SUM(Item_Expected_Volume_CS) as expected_volume_cs,
							SUM(Item_Expected_Volume_LB) as expected_volume_lb,
							SUM(Item_Approved_Volume_CS) as approved_volume_cs,
							SUM(Item_Approved_Volume_LB) as approved_volume_lb
							from getgroupdistintitemdetails
							where
							<cfif len(Get_Program_Products.Group_Id) gt 0>
								group_id = '#Get_Program_Products.Group_Id#'
								 <cfelse>
							    (group_id is null or group_id = '')
							</cfif>
							and billback_program_id = '#Get_Program_Products.billback_program_id#'
							AND IsProductOnProgram = #Get_Program_Products.IsProductOnProgram#
						</cfquery>
					</cfsilent>
					<cfif getdistdetails.recordcount GT 0>
						<tr bgcolor="8B0000"><!--- bgcolor="EAFFEA" --->
							<!--- 01 ---><td nowrap valign="top" width="25%" style="font-size:9px; color:white;"><strong>#Get_Program_Products.ship_to# :: #Get_Program_Products.name#</strong></td>
							<cfif show.pound>
							<!--- 02 ---><td valign="top" width="8%" align="right" style="font-size:9px">&nbsp;</td>
							</cfif>
							<cfif show.case>
							<!--- 03 ---><td valign="top" width="8%" align="right" style="font-size:9px">&nbsp;</td>
							</cfif>
							<!--- 04 ---><td align="right" valign="top" width="9%"  style="font-size:9px">&nbsp;</td><!--- BB --->
							<cfif show.pound>
							<!--- 05 ---><td valign="top" align="right" width="8%"  style="font-size:9px">&nbsp;</td>
							</cfif>
							<cfif show.case>
							<!--- 06 ---><td valign="top" align="right" width="8%" style="font-size:9px">&nbsp;</td>
							</cfif>
							<!--- 07 ---><td align="right" valign="top" width="9%" style="font-size:9px">&nbsp;</td><!--- EX --->
							<cfif show.pound>
							<!--- 08 ---><td valign="top" align="right" width="8%" style="font-size:9px">&nbsp;</td>
							</cfif>
							<cfif show.case>
							<!--- 09 ---><td valign="top" align="right" width="8%" style="font-size:9px">&nbsp;</td>
							</cfif>
							<!--- 10 ---><td align="right" width="9%" valign="top" style="font-size:9px">&nbsp;</td><!--- Paid --->
						</tr>
					</cfif>
					<cfoutput group="Legacy_ID">
					<cfif appSettings.getViewOperatorinBillbackDeviation()>
						<cfif getdistdetails.recordcount GT 0>
							<cfif isDefined("Get_Program_Products.Legacy_ID") AND Get_Program_Products.Legacy_ID NEQ "">
								<tr bgcolor="8B0000"><!--- bgcolor="EAFFEA" --->
									<!--- 01 ---><td nowrap valign="top" width="25%" style="font-size:9px;color:white;border-top:thin solid;border-color:##99CCCC;"><strong>#Get_Program_Products.Legacy_ID# :: #Get_Program_Products.Operator_Name# :: #Get_Program_Products.Operator_Address#</strong></td><!--- D51977 :: Billback enhancements for operator level data --->
									<cfif show.pound>
									<!--- 02 ---><td valign="top" width="8%" align="right" style="font-size:9px;border-top:thin solid;border-color:##99CCCC;">&nbsp;</td>
									</cfif>
									<cfif show.case>
									<!--- 03 ---><td valign="top" width="8%" align="right" style="font-size:9px;border-top:thin solid;border-color:##99CCCC;">&nbsp;</td>
									</cfif>
									<!--- 04 ---><td align="right" valign="top" width="9%"  style="font-size:9px;border-top:thin solid;border-color:##99CCCC;">&nbsp;</td><!--- BB --->
									<cfif show.pound>
									<!--- 05 ---><td valign="top" align="right" width="8%"  style="font-size:9px;border-top:thin solid;border-color:##99CCCC;">&nbsp;</td>
									</cfif>
									<cfif show.case>
									<!--- 06 ---><td valign="top" align="right" width="8%" style="font-size:9px;border-top:thin solid;border-color:##99CCCC;">&nbsp;</td>
									</cfif>
									<!--- 07 ---><td align="right" valign="top" width="9%" style="font-size:9px;border-top:thin solid;border-color:##99CCCC;">&nbsp;</td><!--- EX --->
									<cfif show.pound>
									<!--- 08 ---><td valign="top" align="right" width="8%" style="font-size:9px;border-top:thin solid;border-color:##99CCCC;">&nbsp;</td>
									</cfif>
									<cfif show.case>
									<!--- 09 ---><td valign="top" align="right" width="8%" style="font-size:9px;border-top:thin solid;border-color:##99CCCC;">&nbsp;</td>
									</cfif>
									<!--- 10 ---><td align="right" width="9%" valign="top" style="font-size:9px;border-top:thin solid;border-color:##99CCCC;">&nbsp;</td><!--- Paid --->
								</tr>
							</cfif>
						</cfif>
					</cfif>


					<CFIF Billback_Product_ID NEQ "">
						<cfoutput group="Group_Id">
							<cfsilent>

								<cfset BB_group_Id = replace(Get_Program_Products.Group_Id, "-","_","ALL") & trim(Get_Program_Products.ship_to) & IsProductOnProgram>
								<cfset BB_group_Id = replace(BB_group_Id, "-","_","ALL")>
								<cfquery name="getgroupdetails" dbtype="query">
									select sum(Billback_rate) as claimed_amount,
									sum(Item_E_Volume * Expected_Rate) as expected_amount,
									sum(Item_Approved_Volume * Approved_rate) as approved_amount
									from Get_Program_Products
									where
										<cfif len(Get_Program_Products.Group_Id) gt 0>
											group_id = '#Get_Program_Products.Group_Id#'
											 <cfelse>
										    (group_id is null or group_id = '')
										</cfif>
									and billback_program_id = '#Get_Program_Products.billback_program_id#'
									<cfif Get_Program_Products.dist_id NEQ "">
										and dist_id = '#Get_Program_Products.dist_id#'
									</cfif>
									AND IsProductOnProgram = #Get_Program_Products.IsProductOnProgram#
								</cfquery>

								<cfquery name="getgroupvolumedetails" dbtype="query">
									select
									SUM(Item_BB_Volume_CS) as claimed_volume_cs,
									SUM(Item_BB_Volume_LB) as claimed_volume_lb,
									SUM(Item_Expected_Volume_CS) as expected_volume_cs,
									SUM(Item_Expected_Volume_LB) as expected_volume_lb,
									SUM(Item_Approved_Volume_CS) as approved_volume_cs,
									SUM(Item_Approved_Volume_LB) as approved_volume_lb
									from getgroupdistintitemdetails
									where 	<cfif len(Get_Program_Products.Group_Id) gt 0>
											group_id = '#Get_Program_Products.Group_Id#'
											 <cfelse>
										    (group_id is null or group_id = '')
										    </cfif>
									and billback_program_id = '#Get_Program_Products.billback_program_id#'
									<cfif Get_Program_Products.dist_id NEQ "">
										and dist_id = '#Get_Program_Products.dist_id#'
									</cfif>
									AND IsProductOnProgram = #Get_Program_Products.IsProductOnProgram#
								</cfquery>

								<cfset Group_BB_approved_volume_lb = Group_BB_approved_volume_lb + val(getgroupvolumedetails.approved_volume_lb)>
								<cfset Group_BB_approved_volume_cs = Group_BB_approved_volume_cs + val(getgroupvolumedetails.approved_volume_cs)>
								<cfset Group_BB_expected_volume_lb = Group_BB_expected_volume_lb + val(getgroupvolumedetails.expected_volume_lb)>
								<cfset Group_BB_expected_volume_cs = Group_BB_expected_volume_cs + val(getgroupvolumedetails.expected_volume_cs)>
								<cfset Group_BB_claimed_volume_lb = Group_BB_claimed_volume_lb + val(getgroupvolumedetails.claimed_volume_lb)>
								<cfset Group_BB_claimed_volume_cs = Group_BB_claimed_volume_cs + val(getgroupvolumedetails.claimed_volume_cs)>
								<cfset Group_Expected_Amount = Group_Expected_Amount + numberFormat(getgroupdetails.expected_amount,'.__')>
								<cfset Group_Claimed_Amount = Group_Claimed_Amount + numberFormat(getgroupdetails.claimed_amount,'.__')>
								<cfset Group_Approved_Amount = Group_Approved_Amount + numberFormat(getgroupdetails.approved_amount,'.__')>

							</cfsilent>

<!--- 							<cfif IsProductOnProgram EQ 0><cfset ProductNotOnProgramCount = ProductNotOnProgramCount + 1></cfif>

							<cfif ProductNotOnProgramCount EQ 1>
								<tr BGCOLOR="##cccccc"><td COLSPAN="100%" style="font-size:9px;"><u>Products Not On Program</u></td></tr>
							</cfif>

							<cfif IsProductOnProgram EQ 1><cfset UnKnowProductCount = 0></cfif>
							<cfif Product_Type_ID EQ 3><cfset UnKnowProductCount = UnKnowProductCount + 1></cfif>

							<cfif UnKnowProductCount EQ 1>
								<tr BGCOLOR="##cccccc"><td COLSPAN="100%" style="font-size:9px;"><u>Unknown Products</u></td></tr>
								<cfset productcount = productcount + 1>
							</cfif> --->

							<cfif getSubtotalDisplaySettings.Display_Product_Group_BB EQ 1>

								<tr>
									<td valign="top" width="25%" style="font-size:9px;<cfif Get_Program_Products.currentrow GT 1>border-top:thin Navy dashed;</cfif>">
										<a id="#Get_Program_Products.contract_main_id#_#BB_group_Id#_m1" href="javascript:expandMenu('#Get_Program_Products.contract_main_id#_#BB_group_Id#','#Get_Program_Products.contract_main_id#_#BB_group_Id#_m1');">
												<cfif url.SHOW_PRINT_VERSION EQ 0 and url.show_email_version EQ 0>
													<img src="/images/plus.gif" border="0" width=10 id="picon_#Get_Program_Products.contract_main_id#_#BB_group_Id#" height=10>
												<cfelse>
													<img src="/images/minus.gif" border="0" width=10 id="picon_#Get_Program_Products.contract_main_id#_#BB_group_Id#" height=10>
												</cfif>
												&nbsp;&nbsp;#Get_Program_Products.Group_Name_Id#
										</a>
									</td>

									<cfif getgroupdetails.recordcount GT 0>

										<cfif show.pound>
										<td valign="top" align="right" width="8%" style="font-size:9px;<cfif Get_Program_Products.currentrow GT 1>border-top:thin Navy dashed;</cfif>">#numberformat(getgroupvolumedetails.expected_volume_lb,"___,___,___,___.__")#</td>
										</cfif>
										<cfif show.case>
										<td valign="top" align="right" width="8%" style="font-size:<cfif Get_Program_Products.currentrow GT 1>9px;border-top:thin Navy dashed;</cfif>">#numberformat(getgroupvolumedetails.expected_volume_cs,"___,___,___,___.__")#</td>
										</cfif>
										<td align="right" valign="top" width="9%" style="font-size:<cfif Get_Program_Products.currentrow GT 1>9px;border-top:thin Navy dashed;</cfif>">
											#LSCurrencyFormat(getgroupdetails.expected_amount)#
											<cfsilent>
												<cfif getgroupvolumedetails.expected_volume_cs NEQ 0>
												<cfset G_E_Rate_CS = getgroupdetails.expected_amount/getgroupvolumedetails.expected_volume_cs>
												<cfelse>
												<cfset G_E_Rate_CS = 0>
												</cfif>
												<cfif getgroupvolumedetails.expected_volume_lb NEQ 0>
												<cfset G_E_Rate_lb = getgroupdetails.expected_amount/getgroupvolumedetails.expected_volume_lb>
												<cfelse>
												<cfset G_E_Rate_lb = 0>
												</cfif>
											</cfsilent><br>
											<!--- <cfif getgroupdetails.expected_amount lt 0>
												(#LSCurrencyFormat(G_E_Rate_cs)#) /#Application.UOMCaseAbrSingular#<br>
												(#LSCurrencyFormat(G_E_Rate_lb)#) /#Application.UOMPoundAbrSingular#
											<cfelse> --->

												<cfif show.case>
												#LSCurrencyFormat(G_E_Rate_cs)#/#Application.UOMCaseAbrSingular#<br>
												</cfif>
												<cfif show.pound>
												#LSCurrencyFormat(G_E_Rate_lb)#/#Application.UOMPoundAbrSingular#
												</cfif>
												<!--- START: 81534: Incorrect BB expected & claimed rate if UOM is CWT :: Anand Rao/02-Dec-2018 --->
												<cfif (isDefined("User_Entered_Quantity") AND isDefined("User_Picked_UOM") AND (User_Entered_Quantity NEQ "") AND (User_Picked_UOM NEQ "") AND (User_Picked_UOM EQ 6))>
													#LSCurrencyFormat(G_E_Rate_lb*100)#/#User_UOM_DESC#
												</cfif>
												<!--- END: 81534: Incorrect BB expected & claimed rate if UOM is CWT :: Anand Rao/02-Dec-2018 --->
											<!--- </cfif> --->
										</td><!--- EX --->

										<cfif show.pound>
										<td valign="top" width="8%" align="right" style="font-size:9px;<cfif Get_Program_Products.currentrow GT 1>border-top:thin Navy dashed;</cfif>">#numberformat(getgroupvolumedetails.claimed_volume_lb,"___,___,___,___.__")#</td>
										</cfif>
										<cfif show.case>
										<td valign="top" width="8%" align="right" style="font-size:9px;<cfif Get_Program_Products.currentrow GT 1>border-top:thin Navy dashed;</cfif>">#numberformat(getgroupvolumedetails.claimed_volume_cs,"___,___,___,___.__")#</td>
										</cfif>
										<td align="right" valign="top" width="9%" style="font-size:9px;<cfif Get_Program_Products.currentrow GT 1>border-top:thin Navy dashed;</cfif>">#LSCurrencyFormat(getgroupdetails.claimed_amount)#
											<cfsilent>
												<cfif getgroupvolumedetails.claimed_volume_cs NEQ 0>
													<cfset G_BB_Rate_CS = getgroupdetails.claimed_amount/getgroupvolumedetails.claimed_volume_cs>
												<cfelse>
													<cfset G_BB_Rate_CS = 0>
												</cfif>
												<cfif getgroupvolumedetails.claimed_volume_lb NEQ 0>
													<cfset G_BB_Rate_lb = getgroupdetails.claimed_amount/getgroupvolumedetails.claimed_volume_lb>
												<cfelse>
													<cfset G_BB_Rate_lb = 0>
												</cfif>
											</cfsilent>
											<br>
											<!--- <cfif getgroupdetails.claimed_amount lt 0>
												(#LSCurrencyFormat(G_BB_Rate_CS)#) /#Application.UOMCaseAbrSingular#<br>
												(#LSCurrencyFormat(G_BB_Rate_lb)#) /#Application.UOMPoundAbrSingular#
											<cfelse> --->
												#LSCurrencyFormat(G_BB_Rate_CS)#/#Application.UOMCaseAbrSingular#<br>
												#LSCurrencyFormat(G_BB_Rate_lb)#/#Application.UOMPoundAbrSingular#
												<!--- START: 81534: Incorrect BB expected & claimed rate if UOM is CWT :: Anand Rao/02-Dec-2018 --->
												<cfif (isDefined("User_Entered_Quantity") AND isDefined("User_Picked_UOM") AND (User_Entered_Quantity NEQ "") AND (User_Picked_UOM NEQ "") AND (User_Picked_UOM EQ 6))>
													<br>#User_Entered_Quantity#/#User_UOM_DESC#
												</cfif>
												<!--- END: 81534: Incorrect BB expected & claimed rate if UOM is CWT :: Anand Rao/02-Dec-2018 --->

											<!--- </cfif> --->
										</td><!--- BB --->

									<cfif show.pound>
										<td valign="top" align="right" width="8%" style="font-size:9px;<cfif Get_Program_Products.currentrow GT 1>border-top:thin Navy dashed;</cfif>">#numberformat(getgroupvolumedetails.approved_volume_lb,"___,___,___,___.__")#</td>
									</cfif>
									<cfif show.case>
										<td valign="top" align="right" width="8%" style="font-size:9px;<cfif Get_Program_Products.currentrow GT 1>border-top:thin Navy dashed;</cfif>">#numberformat(getgroupvolumedetails.approved_volume_cs,"___,___,___,___.__")#</td>
									</cfif>
										<td align="right" width="9%" valign="top" style="font-size:9px;<cfif Get_Program_Products.currentrow GT 1>border-top:thin Navy dashed;</cfif>">
											#LSCurrencyFormat(getgroupdetails.approved_amount)#
											<cfsilent>
												<cfif getgroupvolumedetails.approved_volume_cs NEQ 0>
													<cfset G_A_Rate_CS = getgroupdetails.approved_amount/getgroupvolumedetails.approved_volume_cs>
												<cfelse>
													<cfset G_A_Rate_CS = 0>
												</cfif>
												<cfif getgroupvolumedetails.approved_volume_lb NEQ 0>
													<cfset G_A_Rate_lb = getgroupdetails.approved_amount/getgroupvolumedetails.approved_volume_lb>
												<cfelse>
													<cfset G_A_Rate_lb = 0>
												</cfif>
											</cfsilent>
											<br>
											<!--- <cfif getgroupdetails.approved_amount lt 0>
												(#LSCurrencyFormat(G_A_Rate_cs)#) /#Application.UOMCaseAbrSingular#<br>
												(#LSCurrencyFormat(G_A_Rate_lb)#) /#Application.UOMPoundAbrSingular#
											<cfelse> --->
									<cfif show.case>
												#LSCurrencyFormat(G_A_Rate_cs)#/#Application.UOMCaseAbrSingular#<br>
									</cfif>
									<cfif show.pound>
												#LSCurrencyFormat(G_A_Rate_lb)#/#Application.UOMPoundAbrSingular#
									</cfif>
									<!--- START: 81534: Incorrect BB expected & claimed rate if UOM is CWT :: Anand Rao/02-Dec-2018 --->
									<cfif (isDefined("User_Entered_Quantity") AND isDefined("User_Picked_UOM") AND (User_Entered_Quantity NEQ "") AND (User_Picked_UOM NEQ "") AND (User_Picked_UOM EQ 6))>
												<br>#LSCurrencyFormat(G_A_Rate_lb*100)#/#User_UOM_DESC#
									</cfif>
									<!--- END: 81534: Incorrect BB expected & claimed rate if UOM is CWT :: Anand Rao/02-Dec-2018 --->

											<!--- </cfif> --->
										</td><!--- Paid --->
									<cfelse> <!--- getgroupdetails.recordcount GT 0 --->
										<td colspan="100%">&nbsp;</td>
									</cfif> <!--- getgroupdetails.recordcount GT 0 --->
								</tr>
							</cfif> <!--- getSubtotalDisplaySettings.Display_Product_Group_BB EQ 1 --->

							<cfset productcount = 0>
							<cfset Current_Product_Volume = Item_Approved_Volume>
							<!--- <cfset UnKnowProductCount = 0> --->
							<!--- <cfset ProductNotOnProgramCount = 0> --->
							<cfoutput group="Billback_Product_ID">
								<cfsilent>
									<cfset productcount = productcount + 1>
									<cfset P_Billback_Amount =0.000>
									<cfset P_Expected_Amount = 0.000>
									<cfset P_Approved_Amount = 0.000>
									<cfif BB_Product_Type_ID NEQ "">
										<cfoutput>
											<!--- If auto pay AND BB rate eq Expected rate AND it has 0 volume, set expected and approved rates equal to bb_rate.  0 volume on some credit records wont extend --->
											<cfif get_Billback_Info.Auto_Billback AND Get_Program_Products.Billback_rate EQ Get_Program_Products.Expected_Rate AND Get_Program_Products.Item_E_Volume EQ 0>
												<cfset P_Billback_Amount = P_Billback_Amount + Get_Program_Products.Billback_rate>
												<cfset P_Expected_Amount = P_Expected_Amount + Get_Program_Products.Billback_rate>
												<cfset P_Approved_Amount = P_Approved_Amount+  Get_Program_Products.Billback_rate>
											<CFELSE>
												<cfset P_Billback_Amount = P_Billback_Amount + Get_Program_Products.Billback_rate>
												<cfset P_Expected_Amount = P_Expected_Amount + Get_Program_Products.Item_E_Volume * Get_Program_Products.Expected_Rate>
												<cfset P_Approved_Amount = P_Approved_Amount+  Get_Program_Products.Item_Approved_Volume * Get_Program_Products.Approved_Rate>
											</CFIF>


											<cfset Total_Approved_Billback_Amount = Total_Approved_Billback_Amount + numberformat((Get_Program_Products.Item_Approved_Volume * Get_Program_Products.Approved_Rate), '.__')>
                      <!--- D22078:Anand Rao/21-Jan-10: Rounding fixing --->
											<!--- <cfset Total_Approved_Program_Amount = Total_Approved_Program_Amount + numberformat((Get_Program_Products.Item_Approved_Volume * Get_Program_Products.Approved_Rate), '.__')>
											<cfset Total_Expected_Program_Amount = Total_Expected_Program_Amount + numberformat((Get_Program_Products.Item_E_Volume * Get_Program_Products.Expected_Rate), '.__')> --->

											<!--- If auto pay and it has 0 volume, set expected and approved rates equal to bb_rate.  0 volume on some credit records wont extend --->
											<cfif get_Billback_Info.Auto_Billback AND Get_Program_Products.Billback_rate EQ Get_Program_Products.Expected_Rate AND Get_Program_Products.Item_E_Volume EQ 0>
												<cfset Total_Approved_Program_Amount = Total_Approved_Program_Amount + numberformat(Get_Program_Products.Billback_rate, '.__')>
												<cfset Total_Expected_Program_Amount = Total_Expected_Program_Amount + numberformat(Get_Program_Products.Billback_rate, '.__')>
												<cfset Total_Claimed_Program_Amount = Total_Claimed_Program_Amount + numberformat(Get_Program_Products.Billback_rate, '.__')>
											<CFELSE>
												<cfset Total_Approved_Program_Amount = Total_Approved_Program_Amount + numberformat(Get_Program_Products.Approved_Amount, '.__')>
												<cfset Total_Expected_Program_Amount = Total_Expected_Program_Amount + numberformat((Get_Program_Products.Expected_Amount), '.__')>
												<cfset Total_Claimed_Program_Amount = Total_Claimed_Program_Amount + numberformat(Get_Program_Products.Billback_rate, '.__')>
											</CFIF>

										</cfoutput>
									</cfif>
								</cfsilent>

              <!--- Commented this code above and moved it here for Label: D21094 --->
							<cfif IsProductOnProgram EQ 0 AND Product_Type_ID NEQ 3><cfset ProductNotOnProgramCount = ProductNotOnProgramCount + 1></cfif>

							<cfif ProductNotOnProgramCount EQ 1>
								<tr BGCOLOR="##cccccc"><td COLSPAN="100%" style="font-size:9px;"><u>Products Not On Program</u></td></tr>
							</cfif>

							<cfif IsProductOnProgram EQ 1><cfset UnKnowProductCount = 0></cfif>
							<cfif Product_Type_ID EQ 3><cfset UnKnowProductCount = UnKnowProductCount + 1></cfif>

							<cfif UnKnowProductCount EQ 1>
								<tr BGCOLOR="##cccccc"><td COLSPAN="100%" style="font-size:9px;"><u>Unknown Products</u></td></tr>
								<cfset productcount = productcount + 1>
							</cfif>
              <!--- End Label: D21094 --->

								<cfif Evaluate(productcount mod 2) eq 0>
									<cfset tmpBgColor = "FFFFFF" />
								<cfelse>
									<cfset tmpBgColor = "ccffcc" />
								</cfif>
								<cfif getSubtotalDisplaySettings.Display_Product_Group_BB EQ 0>
									<tr BGCOLOR="#tmpBgColor#">
								<cfelse>
									<tr
										<cfif url.SHOW_PRINT_VERSION EQ 0 and url.show_email_version EQ 0>style="display:none"<cfelse>style="display:table-row;"</cfif>
										id="TR_#Get_Program_Products.contract_main_id#_#BB_group_Id#" BGCOLOR="#tmpBgColor#">
								</cfif><!--- Items marked as BSA_Foodservice_Items_Master.Is_Divested = 1 have an asterisk and are red --->
											<td align="left" valign="top" style="font-size:9px;font-face:Ariel;" width="25%"><cfif Get_Program_Products.Is_Divested IS 1>
                      <cfset bDivestedNote = 1/><font color="red"></cfif>
											#Get_Program_Products.Item_Number#
												<cfif Get_Program_Products.Is_Divested IS 1>*</cfif>
												<br>#Left(Get_Program_Products.Description, 40)#
												<cfif Get_Program_Products.Is_Divested IS 1></font></cfif>
											</td>

										<cfif show.pound>
											<td valign="top" align="right" width="8%" style="font-size:9px" >#numberformat(Get_Program_Products.Item_Expected_Volume_LB,"___,___,___,___.__")#</td>
										</cfif>
											<td valign="top" align="right" width="8%" style="font-size:9px" >#numberformat(Get_Program_Products.Item_Expected_Volume_CS,"___,___,___,___.__")#</td>
										<cfif show.case>
											<td align="right" valign="top" width="9%" style="font-size:9px" >#DollarFormat(P_Expected_Amount)#</td>
										</cfif>
										<cfif show.pound>
											<td valign="top" align="right" width="8%" style="font-size:9px">#numberformat(Get_Program_Products.Item_BB_Volume_LB,"___,___,___,___.__")#</td>
										</cfif>
										<cfif show.case>
											<td valign="top" align="right" width="8%" style="font-size:9px" >#numberformat(Get_Program_Products.Item_BB_Volume_CS,"___,___,___,___.__")#</td>
										</cfif>
											<td align="right" valign="top" width="9%" style="font-size:9px" >#DollarFormat(P_Billback_Amount)#</td>
										<cfif show.pound>
											<td valign="top" align="right" width="8%" style="font-size:9px" >#numberformat(Get_Program_Products.Item_Approved_Volume_LB,"___,___,___,___.__")#</td>
										</cfif>
										<cfif show.case>
											<td valign="top" align="right" width="8%" style="font-size:9px" >#numberformat(Get_Program_Products.Item_Approved_Volume_CS,"___,___,___,___.__")#</td>
										</cfif>
											<td align="right" valign="top" width="9%" style="font-size:9px" >#DollarFormat(P_Approved_Amount)#</td>
									</tr>
							</cfoutput>  <!--- group="Billback_Product_ID" --->
						</cfoutput> <!--- group="Group_Id" --->
					</CFIF> <!--- CFIF Billback_Product_ID NEQ "" --->

					<!--- If there are multiple distributors, show the sub total for every distributor --->
					<cfif getDistList.recordcount gt 1>
							<tr>
								<td width="25%" style="font-size:9px"><b>Sub Total</b> </td>
						<cfif show.pound>
								<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(Group_BB_expected_volume_lb,"___,___,___,___.__")#</strong></td>
						</cfif>
						<cfif show.case>
								<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(Group_BB_expected_volume_cs,"___,___,___,___.__")#</strong></td>
						</cfif>
								<td align="right" width="9%" style="font-size:9px"><strong>#DollarFormat(Group_Expected_Amount)#</strong></td>
						<cfif show.pound>
								<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(Group_BB_claimed_volume_lb,"___,___,___,___.__")#</strong></td>
						</cfif>
						<cfif show.case>
								<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(Group_BB_claimed_volume_cs,"___,___,___,___.__")#</strong></td>
						</cfif>
								<td align="right" width="9%" style="font-size:9px"><strong>#DollarFormat(Group_Claimed_Amount)#</strong></td>
						<cfif show.pound>
								<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(Group_BB_approved_volume_lb,"___,___,___,___.__")#</strong></td>
						</cfif>
						<cfif show.case>
								<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(Group_BB_approved_volume_cs,"___,___,___,___.__")#</strong></td>
						</cfif>
								<td align="right" width="9%" style="font-size:9px"><strong>#DollarFormat(Group_Approved_Amount)#</strong></td>
							</tr>
					</cfif>
					</cfoutput> <!--- group="Legacy_ID" --->
				</cfoutput> <!--- group="dist_id" --->
				<!---------- End Products --------------->

				<cfsilent>
					<cfquery name="getBBprogramdetails" dbtype="query">
						select SUM(Item_BB_Volume_CS) as claimed_volume_cs,
						SUM(Item_BB_Volume_LB) as claimed_volume_lb,
						SUM(Item_Expected_Volume_CS) as expected_volume_cs,
						SUM(Item_Expected_Volume_LB) as expected_volume_lb,
						SUM(Item_Approved_Volume_CS) as approved_volume_cs,
						SUM(Item_Approved_Volume_LB) as approved_volume_lb
						from getgroupdistintitemdetails where billback_program_id = '#Get_Program_Products.billback_program_id#'
					</cfquery>

					<cfset total_BB_approved_volume_lb = total_BB_approved_volume_lb + getBBprogramdetails.approved_volume_lb>
					<cfset total_BB_approved_volume_cs = total_BB_approved_volume_cs + getBBprogramdetails.approved_volume_cs>
					<cfset total_BB_expected_volume_lb = total_BB_expected_volume_lb + getBBprogramdetails.expected_volume_lb>
					<cfset total_BB_expected_volume_cs = total_BB_expected_volume_cs + getBBprogramdetails.expected_volume_cs>
					<cfset total_BB_claimed_volume_lb = total_BB_claimed_volume_lb + getBBprogramdetails.claimed_volume_lb>
					<cfset total_BB_claimed_volume_cs = total_BB_claimed_volume_cs + getBBprogramdetails.claimed_volume_cs>
				</cfsilent>

				<!--- If there is a single distributor, show the sub total for distributor --->
				<cfif getDistList.recordcount lte 1>
					<tr bgcolor="FFFACD">
						<!------Total Approved  Amount----->
						<td width="25%" style="font-size:9px"><b>Sub Total</b> </td>
					<cfif show.pound>
						<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(getBBprogramdetails.expected_volume_lb,"___,___,___,___.__")#</strong></td>
					</cfif>
					<cfif show.case>
						<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(getBBprogramdetails.expected_volume_cs,"___,___,___,___.__")#</strong></td>
					</cfif>
						<td align="right" width="9%" style="font-size:9px"><strong>#DollarFormat(Total_Expected_Program_Amount)#</strong></td>
					<cfif show.pound>
						<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(getBBprogramdetails.claimed_volume_lb,"___,___,___,___.__")#</strong></td>
					</cfif>
					<cfif show.case>
						<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(getBBprogramdetails.claimed_volume_cs,"___,___,___,___.__")#</strong></td>
					</cfif>
						<td align="right" width="9%" style="font-size:9px"><strong>#DollarFormat(Total_Claimed_Program_Amount)#</strong></td>
					<cfif show.pound>
						<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(getBBprogramdetails.approved_volume_lb,"___,___,___,___.__")#</strong></td>
					</cfif>
					<cfif show.case>
						<td align="right" width="8%" style="font-size:9px"><strong>#numberformat(getBBprogramdetails.approved_volume_cs,"___,___,___,___.__")#</strong></td>
					</cfif>
						<td align="right" width="9%" style="font-size:9px"><strong>#DollarFormat(Total_Approved_Program_Amount)#</strong></td>
					</tr>
				</cfif>

				<!--- Dev Note: KAL; D14729: BB with lump sum shows no info on BB summary page --->
				<!------ Start Lumpsum ---------------->
				<cfsilent>
					<CFQUERY DBTYPE="query" NAME="This_Program_lumpsum">
						SELECT	*
						FROM	Get_Program_Lumpsum
						WHERE 	Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="cf_sql_idstamp">
					</CFQUERY>
					<CFQUERY DBTYPE="query" NAME="This_Billback_lumpsum">
						SELECT	*
						FROM	Get_Program_Lumpsum_Products
						WHERE 	Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="cf_sql_idstamp">
					</CFQUERY>
					<CFQUERY DBTYPE="query" NAME="This_Billback_lumpsum_Sum">
						SELECT	SUM(Amount) AS BB_Lumpsum_Claimed,
								SUM(Expected) AS BB_Lumpsum_Expected,
								SUM(Approved) AS BB_Lumpsum_Approved
						FROM	Get_Program_Lumpsum
						WHERE 	Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="cf_sql_idstamp">
					</CFQUERY>
				</cfsilent>


				<cfif This_Program_lumpsum.recordCount GT 0>

					<cfsilent>
						<cfset Total_Approved_Billback_Amount = Total_Approved_Billback_Amount + This_Billback_lumpsum_Sum.BB_Lumpsum_Approved>
						<cfset Total_Approved_Program_Amount = Total_Approved_Program_Amount + This_Billback_lumpsum_Sum.BB_Lumpsum_Approved>
						<cfset Total_Expected_Program_Amount = Total_Expected_Program_Amount + This_Billback_lumpsum_Sum.BB_Lumpsum_Expected>
						<cfset Total_Claimed_Program_Amount = Total_Claimed_Program_Amount + This_Billback_lumpsum_Sum.BB_Lumpsum_Claimed>

						<cfset lumpsum_display_text = "#Application.LumpsumLabel#" />
						<!--- Dev Note: KAL; D14729: BB Summary for LumpSum & Growth : Show component name only 1 component exists on the program. --->
						<cfif This_Program_lumpsum.recordCount eq 1>
							<cfset lumpsum_display_text = "#This_Billback_lumpsum.Component_Name#" />
						</cfif>
					</cfsilent>
					<tr style="font-size:9px">
						<td style="font-size:9px">#lumpsum_display_text#</td>
						<cfif show.pound>
							<td>&nbsp;</td>
						</cfif>
						<cfif show.case>
							<td>&nbsp;</td>
						</cfif>
						<td align="right" style="font-size:9px">#LSCurrencyFormat(This_Billback_lumpsum_Sum.BB_Lumpsum_Expected)#</td><!--- BB --->
						<cfif show.pound>
							<td>&nbsp;</td>
						</cfif>
						<cfif show.case>
							<td>&nbsp;</td>
						</cfif>
						<td align="right" style="font-size:9px">#LSCurrencyFormat(This_Billback_lumpsum_Sum.BB_Lumpsum_Claimed)#</td><!--- EX --->
						<cfif show.pound>
							<td>&nbsp;</td>
						</cfif>
						<cfif show.case>
							<td>&nbsp;</td>
						</cfif>
						<td align="right" style="font-size:9px">#LSCurrencyFormat(This_Billback_lumpsum_Sum.BB_Lumpsum_Approved)#</td><!--- Paid --->
					</tr>

				</cfif>
				<!------ End Lumpsum ---------------->

				<!---------- Start Growth Get_Program_Growth --------->
				<cfsilent>
					<CFQUERY DBTYPE="query" NAME="This_Program_Growth">
						SELECT	*
						FROM	Get_Program_Growth
						WHERE 	Billback_Program_ID = <cfqueryparam value="#Billback_Program_ID#" cfsqltype="cf_sql_idstamp">
					</CFQUERY>
				</cfsilent>
				<CFIF This_Program_Growth.recordCount GT 0>
					<tr CLASS="growthInTR">
						<td style="font-size:9px">Growth</td>
						<td colspan="1">&nbsp;</td>
						<td align="right" style="font-size:9px">#LSCurrencyFormat(This_Program_Growth.Expected_Amount)# </td><!--- BB --->
						<td colspan="1">&nbsp;</td>
						<td align="right" style="font-size:9px">#LSCurrencyFormat(This_Program_Growth.Total_Growth)#</td><!--- EX --->
						<td colspan="1">&nbsp;</td>
						<td align="right" style="font-size:9px">#LSCurrencyFormat(This_Program_Growth.BB_Approved_Amount)#</td><!--- Paid --->
					</tr>

					<cfsilent>
						<cfset Total_Approved_Billback_Amount = Total_Approved_Billback_Amount + This_Program_Growth.BB_Approved_Amount>
						<cfset Total_Approved_Program_Amount = Total_Approved_Program_Amount + This_Program_Growth.BB_Approved_Amount>
						<cfset Total_Expected_Program_Amount = Total_Expected_Program_Amount + This_Program_Growth.Expected_Amount>
						<cfset Total_Claimed_Program_Amount = Total_Claimed_Program_Amount + This_Program_Growth.Total_Growth>
					</cfsilent>
				</CFIF>

			<!--- Add to the TOTAL --->
			<cfset Total_Expected_Amount = Total_Expected_Amount + numberformat(Total_Expected_Program_Amount, '.__')>
			<cfset Total_Claimed_Amount = Total_Claimed_Amount + numberformat(Total_Claimed_Program_Amount, '.__')>
			<cfset Total_Approved_Amount = Total_Approved_Amount + numberformat(Total_Approved_Program_Amount, '.__')>

			</CFOUTPUT> <!--- CFOUTPUT QUERY="Get_Program_Products" GROUP="Billback_Program_ID" --->

			<cfoutput>
				<tr bgcolor="D2E1EE" style="height:20px;"><!--- BGCOLOR="FFFACD" --->
					<td width="25%" nowrap style="font-size:9px;font-weight:bold;color:Navy;"><b>TOTAL</b></td>

			<cfif show.pound>
					<td align="right" width="8%" style="font-size:9px;color:Navy;"><strong>#numberformat(total_BB_expected_volume_lb,"___,___,___,___.__")#</strong></td>
			</cfif>
			<cfif show.case>
					<td align="right" width="8%" style="font-size:9px;color:Navy;"><strong>#numberformat(total_BB_expected_volume_cs,"___,___,___,___.__")#</strong></td>
			</cfif>
					<td align="right" width="9%" style="font-size:9px;color:Navy;"><strong>#DollarFormat(Total_Expected_Amount)#</strong></td>
			<cfif show.pound>
					<td align="right" width="8%" style="font-size:9px;color:Navy;"><strong>#numberformat(total_BB_claimed_volume_lb,"___,___,___,___.__")#</strong></td>
			</cfif>
			<cfif show.case>
					<td align="right" width="8%" style="font-size:9px;color:Navy;"><strong>#numberformat(total_BB_claimed_volume_cs,"___,___,___,___.__")#</strong></td>
			</cfif>
					<td align="right" width="9%" style="font-size:9px;color:Navy;"><strong>#DollarFormat(Total_Claimed_Amount)#</strong></td>
			<cfif show.pound>
					<td align="right" width="8%" style="font-size:9px;color:Navy;"><strong>#numberformat(total_BB_approved_volume_lb,"___,___,___,___.__")#</strong></td>
			</cfif>
			<cfif show.case>
					<td align="right" width="8%" style="font-size:9px;color:Navy;"><strong>#numberformat(total_BB_approved_volume_cs,"___,___,___,___.__")#</strong></td>
			</cfif>
					<td align="right" width="9%" style="font-size:9px;color:Navy;"><strong>#DollarFormat(Total_Approved_Amount)#</strong></td>
				</tr>
			</cfoutput>
		<CFELSE> <!--- Get_Program_Products.RecordCount GT 0 --->
			<B><FONT COLOR="Red">NO PROGRAM SUPPLIED</FONT></B>
	  	</CFIF> <!--- Get_Program_Products.RecordCount GT 0 --->
	  </tbody>
	</TABLE>
  <cfif bDivestedNote EQ 1>&nbsp;&nbsp;&nbsp;<FONT COLOR="Red">* - indicates the item is divested</FONT></cfif>
	<cfset bbtype = CreateObject("component","components.Billback.BBAutoReportGet").init().getAutoPayType() />
	<cfset genericType = thisPayeeObj.getGenericType(Get_Billback_Info.programid) />
	<cfset bPullbackLite = 0 />
	<cfif GetPullbackInfo.BB_pullbacks_applied EQ 1 and bbtype EQ 2>
		<cfset qBBAutoLtPBData = CreateObject("component","components.Billback.BBAutoReportGet").init().GetAutoPayLitePBApplied(Billback_ID) />
		<cfset bPullbackLite = qBBAutoLtPBData.recordcount />
	</cfif>
	<cfif GetPullbackInfo.BB_pullbacks_applied EQ 1 and genericType NEQ 'Brokerage' AND bPullbackLite EQ 0>
		<br />	<!--- pullback applied amount --->
		<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="99%" ALIGN="center">
				<tr>
					<td colspan="100%"><br />
						<B><FONT SIZE="2" COLOR="Navy">
								<cfoutput>#Ucase(left(appsettings.getPullbackLabel(),1))##replace(appsettings.getPullbackLabel(),left(appsettings.getPullbackLabel(),1),"",1)#</cfoutput>
							</FONT></B>
						<HR COLOR="Navy">
					</td>
				</tr>
				<tr id="PB">
					<cfset url.BB_ID = Billback_Id />
					<cfset url.fromdeletepage = 1 />
					<cfset url.inline = 1 />
					<td align="right" width="100%"><cfinclude template="/billbacks/approval/viewappliedpullbacks.cfm" /><br /></td>
				</tr>
		</TABLE>
	<cfelseif application.appSettingsGet.getBrokerage_Functionality_On()> <!--- Display Brokerage Pullbacks --->
		<cfset qBrkPBData = CreateObject("component","components.Brk_Pullback.Brk_Pullback_Get").init().GetPBApplied(Billback_ID) />
		<cfif qBrkPBData.recordcount GT 0>
			<br />	<!--- pullback applied amount --->
			<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="99%" ALIGN="center">
					<tr>
						<TD colspan="100%"><BR>
						<B><FONT SIZE="2" COLOR="Navy">
							<cfoutput>#Ucase(left(appsettings.getPullbackLabel(),1))##replace(appsettings.getPullbackLabel(),left(appsettings.getPullbackLabel(),1),"",1)#</cfoutput>
						</FONT></B>
						<HR COLOR="Navy">
						</TD>
					</tr>
					<tr id="PB">
						<td align="LEFT" width="100%">
							<Table width="250" cellpadding="0" cellspacing="0">
								<TR bgcolor="ffce84" id="cellLabel" style="height:18px;">
									<TD width="150" style="border-bottom:solid #93BEE2 1px;">BillBack</TD>
									<TD  Align="Right" width="100" style="border-bottom:solid #93BEE2 1px;">Applied Dollars</TD>
								</TR><!--- <cfdump var="#qBrkPBData#"><cfabort> --->
								<cfset totBrkPullback = 0/>
								<cfoutput query="qBrkPBData">
									<cfif Evaluate(qBrkPBData.currentRow mod 2) eq 0>
										<cfset tmpBgColor = "FFFFFF" />
									<cfelse>
										<cfset tmpBgColor = "ccffcc" />
									</cfif>
									<TR bgcolor="#tmpBgColor#">
										<TD width="150"><a href="##" onclick="browse('#JSSTRINGFORMAT(qBrkPBData.billback_id)#')" title="#qBrkPBData.BB_Title#">#qBrkPBData.BB_Code#</a></TD>
										<TD Align="Right" width="100">#qBrkPBData.Applied_Dollars#</TD>
									</TR>
									<cfset totBrkPullback = totBrkPullback + qBrkPBData.Applied_Dollars />
								</cfoutput>
								<TR bgcolor="D2E1EE" style="height:18px;">
									<TD width="25%" nowrap style="font-size:9px;font-weight:bold;color:Navy;"><b>TOTAL</b> </TD>
									<TD Align="Right" width="100"><cfoutput>#totBrkPullback#</cfoutput></TD>
								</TR>
							</Table>
						</td>
					</tr>
			</TABLE>
		</cfif>
	<cfelseif bbtype EQ 2 AND GetPullbackInfo.BB_pullbacks_applied EQ 1> <!--- Display Ineligible volume (Auto PAy Lite) Pullbacks --->
		<cfif qBBAutoLtPBData.recordcount GT 0>
			<br />	<!--- pullback applied amount --->
			<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="99%" ALIGN="center">
					<tr>
						<TD colspan="100%"><BR>
						<B><FONT SIZE="2" COLOR="Navy">
							<cfoutput>#Ucase(left(appsettings.getPullbackLabel(),1))##replace(appsettings.getPullbackLabel(),left(appsettings.getPullbackLabel(),1),"",1)#</cfoutput>
						</FONT></B>
						<HR COLOR="Navy">
						</TD>
					</tr>
					<tr id="PB">
						<td align="LEFT" width="100%">
							<Table width="250" cellpadding="4" cellspacing="0">
								<TR bgcolor="ffce84" id="cellLabel" style="height:18px;">
									<TD width="150" style="border-bottom:solid #93BEE2 1px;">BillBack</TD>
									<TD  Align="Right" width="100" style="border-bottom:solid #93BEE2 1px;">Applied Dollars</TD>
								</TR><!--- <cfdump var="#qBBAutoLtPBData#"><cfabort> --->
								<cfset totBrkPullback = 0/>
								<cfoutput query="qBBAutoLtPBData">
									<cfif Evaluate(qBBAutoLtPBData.currentRow mod 2) eq 0>
										<cfset tmpBgColor = "FFFFFF" />
									<cfelse>
										<cfset tmpBgColor = "ccffcc" />
									</cfif>
									<TR bgcolor="#tmpBgColor#">
										<TD width="150"><a href="##" onclick="browse('#JSSTRINGFORMAT(qBBAutoLtPBData.billback_id)#')" title="#qBBAutoLtPBData.BB_Title#">#qBBAutoLtPBData.BB_Code#</a></TD>
										<TD Align="Right" width="100">#DollarFormat(qBBAutoLtPBData.Applied_Dollars)#</TD>
									</TR>
									<cfset totBrkPullback = totBrkPullback + qBBAutoLtPBData.Applied_Dollars />
								</cfoutput>
								<TR bgcolor="D2E1EE" style="height:18px;">
									<TD width="40%" nowrap style="font-size:9px;font-weight:bold;color:Navy;"><b>TOTAL</b> </TD>
									<TD Align="Right" width="100"><cfoutput>#DollarFormat(totBrkPullback)#</cfoutput></TD>
								</TR>
							</Table>
						</td>
					</tr>
			</TABLE>
		</cfif>
	</cfif>
	<!--- </tbody>
	</table> --->
<!--- ShowDetails IS 1 ---->
<cfelse>
	<div id="spp132" style="margin:5px 0 0 5px;"><a href="##"><cfoutput>#application.util.string.actionLinkFormat2( "show program and product details" )#</cfoutput></a></div>
<!--- ShowDetails IS 1 --->
</cfif>

<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="99%" ALIGN="center">
	<CFIF Get_Billback_Info.BB_Is_Child EQ 1>
		<cfset Billback_ID = OriginalBBID>
	</CFIF>

	<!--- Diplay Attached Documents --->
	<cfset bDocViewer = 0/>
	<CFIF not isdefined("Display_None_Attachments")>
		<cfif application.appSettingsGet.get_Setting('BB_Doc_Server_Folder') NEQ ''>
			<cfset bDocViewer = 1/> <!--- LOOK FOR FILES IN DOC SERVER --->
		</cfif>
		<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />

		<cfsilent>
			<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">
<!---
	Dev Notes: D23320/Anand Rao/17-May-10
	  User profile setting to view private documents
--->

			<!--- Tim Ford - Label 32482: Billback - display attached docs for all BB versions from Payment History --->
			<!--- Get the billback ids for all the billbacks based on BB Code --->
			<cfquery name="qGetBillbackIds" datasource="#application.datasource#">
				SELECT DISTINCT Billback_ID
					FROM Billback
				WHERE
				Billback_ID = '#URL.BBID#'
				OR
				BB_Parent_ID = '#URL.BBID#'
				AND Deleted = 0
			</cfquery>

			<CFQUERY NAME="get_attachments" DATASOURCE="#Application.Datasource#">
				/* SELECT 		*
				FROM 		Document_Details
				INNER JOIN 	Contract_Attachments ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
				WHERE 		Contract_Attachments.Billback_ID = '#URL.BBID#'
				AND 		(	(	Public_View = 1
									AND User_Position_ID IN (#preserveSingleQuotes(GP_Position_List_From_My_Position_Down)#)
								)
								OR Public_View = 0
							) */

     IF OBJECT_ID('tempdb..##TMP_BILLBACK_ATTACHMENTS') IS NOT NULL
  DROP TABLE ##TMP_BILLBACK_ATTACHMENTS
  SELECT	DISTINCT Document_Details.*
  INTO	##TMP_BILLBACK_ATTACHMENTS
  FROM    Document_Details
  INNER JOIN 	Contract_Attachments ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
  LEFT JOIN Profiles_Settings PS
  ON		PS.Profiles_ID = #Request.AccessStructure.Profiles_ID#   AND PS.View_Private_Documents = 1
  WHERE Document_Details.Deleted = 0
    AND (
          ( Public_View = 1
  		    AND User_Position_ID IN (#Preservesinglequotes(GP_Position_List_From_My_Position_Down)#)
  				)
         OR Public_View = 0
        )
        AND
      (Document_Details.Uploaded_By = '#Request.AccessStructure.User_ID#' OR  Public_View =0)
      AND
    Contract_Attachments.Billback_ID IN (#QuotedValueList(qGetBillbackIds.Billback_ID)#)

    INSERT INTO ##TMP_BILLBACK_ATTACHMENTS
    SELECT	Document_Details.*
    FROM    Document_Details
    INNER JOIN 	Contract_Attachments ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
    INNER JOIN Profiles_Settings PS
    ON		PS.Profiles_ID = #request.accessStructure.Profiles_ID#  AND PS.View_Private_Documents = 1
    WHERE
    Document_Details.Deleted = 0
    AND
    ((Public_View = 1
         AND User_Position_ID IN (#Preservesinglequotes(GP_Position_List_From_My_Position_Down)#)
         )OR Public_View = 0
        )
   AND
    Contract_Attachments.Billback_ID IN (#QuotedValueList(qGetBillbackIds.Billback_ID)#)

    SELECT DISTINCT * FROM ##TMP_BILLBACK_ATTACHMENTS

			</CFQUERY>
		</cfsilent>
		<tr>
			<td COLSPAN="100%">
				<BR>
					<B><FONT SIZE="2" COLOR="Navy">Attachments</FONT></B><HR COLOR="Navy">
					<CFIF get_attachments.RecordCount GT 0>
					<TABLE align="center" border="0" width="100%" CLASS="maintable" CELLSPACING="0">
							<tr bgcolor="ffce84">
								<td STYLE="font-size: 11px; font-weight: bold;">Date / Name</td>
								<td STYLE="font-size: 11px; font-weight: bold;">File</td>
								<td STYLE="font-size: 11px; font-weight: bold;">Title / Description</td>
								<td STYLE="font-size: 11px; font-weight: bold;">Type</td>
							</tr>
						<CFOUTPUT QUERY="get_attachments">
						<cfsilent>
							<cfset useLakebaseForUser_Name = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForUser_Name>
	<cftry>
		<cfset User_Name = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Uploaded_By#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUser_Name = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUser_Name>
<CFQUERY NAME="User_Name" DATASOURCE="#Application.Datasource#">
								SELECT Name_First, Name_Last FROM _USERS WHERE User_ID = '#Uploaded_By#'
							</CFQUERY>
</cfif>
						</cfsilent>
							<cfset variables.Uni_Name = Doc_Uni_Name/>
							<cfif trim(variables.Uni_Name) eq ''>
								<cfset variables.Uni_Name = Doc_File_Name/>
							</cfif>
							<tr valign="top" bgcolor="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
								<td WIDTH="16%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<br>#User_Name.Name_First# #User_Name.Name_Last#</td>
								<cfset SIZEinMB = #Doc_size#/1024>

								<td NOWRAP TITLE="File Name: #Doc_File_Name#">
									<cfif bDocViewer eq 1>
										<A href="javascript: confirmDocServerGet('#jsStringFormat(Doc_File_Name)#','#jsStringFormat(Doc_Uni_Name)#');" TITLE="Click here to view '#Doc_File_Name#'">
									<cfelse>
										<A href="javascript: confirmation('#jsStringFormat(variables.Uni_Name)#');" TITLE="Click here to view '#Doc_File_Name#'">
									</cfif>
									<cfset Display_Name=Left(Doc_File_Name,20)>
									<CFIF len(trim(Doc_File_Name)) GT 20>
										#LCASE(Display_Name)#...
									<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
										&nbsp;
									<CFELSE>
										#LCASE(Display_Name)#
									</CFIF>
									</A><br>#NumberFormat(SIZEinMB,"_.___")#&nbsp;KB</td>
								<td WIDTH="58%"><FONT COLOR="red">#Doc_Title#</FONT><BR>Description: #Doc_Description#</td>
								<td WIDTH="12%">#Doc_Type#</td>
							</tr>
						</CFOUTPUT>
					  </TABLE>
					<CFELSE>
						<B><FONT COLOR="Red">NO DOCUMENTS ATTACHED</FONT></B>
					</CFIF>
			</td>
		</tr>
	</CFIF>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--->


	<cfif application.returned_customer_setting.confidentiality_switch NEQ application.returned_customer_setting.customer_setting_error_string>
		<cfif application.returned_customer_setting.confidentiality_switch EQ 1>
		<tr>
			<td COLSPAN="100%">
				<br>
				<hr>
				<font size="-2"><cfoutput>#application.returned_customer_setting.confidentiality_content# </cfoutput></font>
				<hr>
			</td>
		</tr>
		</cfif>
	</cfif>

</TABLE>
</div>   <!--- style="height:550px"> --->

<!--- show detail form -- this assumes that only "billback_summary.cfm" will ever have ShowDetails = 0...
if any other page needs show details to be 0 you'll have to write logic that makes the action of the form dynamic--->
<form name="ShowDetails" action="/billbacks/capture/Billback_Summary.cfm?BBID=<cfoutput>#Billback_ID#</cfoutput>" method="post">
	<input type="hidden" name="Show_Details" value="1">
</form>
<!--- end show detail form---->

<cfinclude template="\common_files\jQuery.cfm">
<script src="/script/javascript/jquery.noty.packaged.min.js"></script>

<script language="javascript">
	var clicked_spp132 = 0;
	jQuery("#spp132").click(function(){
		/* prevent multiple clicks */
		if (clicked_spp132 == 0) {
			clicked_spp132 = 1;
			jQuery(this).html("&nbsp;");
			noty( { text: "Gathering program and product details, please wait..."
		        	,layout:'bottom'
		        	,type:'information'
		        	,killer:true
		        	,timeout:0	});
			ShowDetails.submit();
		}
	});

	function showDetails(){
		ShowDetails.submit();
	}

	function expandMenu(objectID, parentID) {
		var object = document.getElementById("TR_"+objectID);
		var parent = document.getElementById(parentID);
		tempVar = eval("document.all.TR_"+objectID);
		var myPIcon = document.getElementById("picon_" + objectID);

		if (parent == null){
			object.style.display='none';
			return;
		}

		if (object.style.display =='table-row')  {
			myPIcon.src="/images/plus.gif";
			object.style.display='none';
			for(var x=0; x<tempVar.length;x++){
			tempVar[x].style.display = 'none';
			}
		}
		else {
			myPIcon.src="/images/minus.gif";
			object.style.display='table-row';
			for(var x=0; x<tempVar.length;x++){
			tempVar[x].style.display = 'table-row';
			}
		}
		<cfif NOT cgi.SCRIPT_NAME contains "bb_preview.cfm">
		try { window.parent.dyniframesize(); } catch (err) { };
		</cfif>
		return;
	}

	function browse(id){
	  NewWindow('/billbacks/capture/bb_preview.cfm?BBID='+id,'BB_Preview2','800','600','Yes', 'Yes');
	 }

	function openDC(BBID, BBPRGID,PRGID,showEditLink){
//		NewWindow('/billbacks/capture/DistributionChannelSelection.cfm?PRGID='+Program_ID + '&BBPRGID=' + BBProgramID + '&DISTID=' + Dist_ID + '&BBID='+ BBID, 'DC', 400, 300, 'yes', 'yes');
		NewWindow('/billbacks/capture/DistributionChannelSelection.cfm?BBID='+ BBID + '&PRGID=' + PRGID + '&BBPRGID=' + BBPRGID + '&showEditLink=' + showEditLink, 'DC', 600, 300, 'yes', 'yes');
	}

	// BSD D11544
    var url = '<cfoutput>#lcase(cgi.script_name)#</cfoutput>';
	if (window.location.href.indexOf('bb_preview.cfm') == -1)
	{
		if (url == '/billbacks/capture/billback_summary.cfm')
		{
  			try { window.parent.dyniframesize(); } catch (err) { };
   		}
  	}

	// append a :: indicator for F5 cached relocading feature
	document.title = "Billback Summary ::";
</script>

<cf_include files="/script/javascript/F5_Reload.js">
