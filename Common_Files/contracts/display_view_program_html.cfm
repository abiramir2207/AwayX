<cfsetting showDebugOutput=yes>

<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />
<cfset displayGroupTypeDesc = genSettingsManager.settings.getViewProgramProductGroupTypeDesc() />
<cfparam name="url.editMode" default="0" />
<cfparam name="url.forceCachedView" default="0" />
<cfparam name="url.doNotCacheThisView" default="0" /><!--- D12831: if the view is not complete (eg:catalog summary) we do not want to cache it ---->
<cfparam name="url.EZTemplate" default="0">
<!--- D10648: Make a change in preview link to always show the cached file if it exits.  That way if a cached file exists, the performance will be faster in displaying the page.  --->
<cfparam name="summaryView" default="false" />
<cfparam name="form.operatorList" default="" />
<cfparam name="bIsIndirectBid" default="0">
<cfparam name="URL.CatalogView" default="0">
<cfparam name="url.FromFlex" 	default="0">
<cfparam name="URL.FromVolumeApplicator" default="0" />
<cfparam name="variables.pgmThinDisplayIsAttachement" 	default="0">
<cfif NOT IsDefined("GenProgramManager")>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
</cfif>
<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>
<cfset GroupDataManager = CreateObject("component","components.products.Group.DataManager") />
<!------ Get pricing level descriptions ----->
<cfset qGetPricingLevel = GroupDataManager.getPricingLevel() />
<cfset arPricingLevel = ListToArray(ValueList(qGetPricingLevel.Pricing_Level_Desc, ","), ",") />

<cfif isdefined("AlreadyBeenHere")>
 	&nbsp; <!--- we are all set. if we include functions more than once....Kaboom --->
<cfelse>
	<cfinclude template="/script/cf/string_functions.cfm">
</cfif>
<cfset objVendor = CreateObject("component", "components.programs.vendor.vendor")>
<cfset objDistributor = CreateObject("component", "components.programs.distributors.distributor")>
<cfset objProgramFreight = CreateObject("component", "components.freight.ProgramFreight")>
<cfset objSearchProgram = CreateObject("component", "mvc.Models.Program.Search_Program")>
<cfset ProgramDistributorFreightCount = objProgramFreight.GetProgramDistributorFreightCount(CSLGetContractInfo.contract_main_id)>
<cfset ProgramFreightComponentType = GenProgramManager.GetProgramFreightComponentType(CSLGetContractInfo.contract_main_id)>
<cfset ProgramFreightOn = GenProgramManager.GetIsProgramFreightOn(CSLGetContractInfo.contract_main_id)>
<cfset budgetReportMgr = CreateObject("component","mvc.models.Reports.BudgetReport") /><!---D51049 --->
<!--- D58135 ::  Additional Component info displaye inside program START--->
<cfset LabelComp 			= Createobject("component", "components.settings.labels.labels").init() />
<!--- D58135 ::  Additional Component info displaye inside program END --->
<!--- Get the currency and set the variables --->
<cfset objCurrency = CreateObject("component", "components.programs.currency.ProgramCurrencyType")>
<cfset qCurrency = objCurrency.getProgramCurrencies(CSLGetContractInfo.Contract_Main_ID)>
<cfif qCurrency.RecordCount GT 0>
	<cfset CurrencyVar = #qCurrency.currency_name# & " (" & #qCurrency.currency_code# & ")">
<cfelse>
	<cfset CurrencyVar = "United States Dollars (USD)">
</cfif>

<!---initialize PaymentCycleManager--->
<cfset PaymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager") />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset getFieldSettings = templateManager.getProgramTemplate(CSLGetContractInfo.contract_main_id) />
<cfset bidRequestProdMan = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
<cfif appSettings.getBidRequestUsePriceByDate() EQ 1>
	<cfset bIsIndirectBid = bidRequestProdMan.checkIndirectBid(CSLGetContractInfo.contract_main_id) />
</cfif>
<cfset BidRequestProductStatusManager = CreateObject("component", "components.programs.bid_request.BidRequestProductStatusManager").init() />
<cfset BidRequestProductStatusManager.loadProgramProducts(CSLGetContractInfo.contract_main_id) />

<cfset TreatmentCodeManager = CreateObject("component","components.Operating_Group.TreatmentCodeManager").init() />
<cfset BasisCodeManager = CreateObject("component","components.Operating_Group.BasisCodeManager").init() />

<cfset Display_Basis_Treatment_Code = 0 />
<cfif GetSettings.Include_Treatment_Basis_Code>
	<cfset Display_Basis_Treatment_Code = 1 />
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset sProgramViewCacheFileName = "View_Program_#CSLGetContractInfo.Contract_Main_ID#.htm" />
<!---
  Dev Notes: 21058/Anand Rao/10-Nov-09 Refresing Prg. Qty after closing Volume screen
  Added an URL variable FromVolumeApplicator
 --->
<cfif (url.editMode eq 0 AND url.forceCachedView EQ 0) OR NOT fileexists("#Application.Doc_Path#\Temp_Files\Program\#sProgramViewCacheFileName#") OR url.FromFlex eq 1 OR (URL.FromVolumeApplicator EQ 1)>

<cfsavecontent variable="content">
<cfoutput>
  <style>
  	<cfinclude template="/common_files/main_style.css">
	TABLE.Maintable TD	{
		border-bottom:solid ##93BEE2 1px;
		font-size : 10px;
		}

	##header {
		font-size: 12px;
		}

	##cellLabel {
		font-family:Arial;
		font-size: 12px;
		font-weight: bold;
		vertical-align : top;
		}

	##dataStyle {
		font-size: 10px;
		}

	TD {
		font-family:Arial;
		}
	fieldset {
		border:0px solid;
		padding: 0px;
		}
	hr {
		color: navy;
		height: 1px;
		}
	pre	{
		margin-top: 0px;
		margin-bottom: 0px;
		font-family:Arial;
		font-size:13px;
		valign:center;
		}
</style>
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
  <!--- Open layer Options																				--->
  <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style type="text/css" media="print">
	thead {
		display: table-header-group;
		}
	tfoot {
		display: table-footer-group;
		}
	TABLE {
		background-image: none;
		}
	.TableSize {
		width: 650;
		}
	.TableSize2 {
		width: 315;
		}
</style>

<style type="text/css" media="screen">
	.TableSize {
		width: 775;
		}
	.TableSize2 {
		width: 375;
		}
</style>

<cfsilent>
<cfparam name="Sent_To_External_Client" default=0>
<cfparam name="group_processed" default=0>
<cfparam name="getpositionabove" default = 0>
<cfparam name="DECount" default="0">
<cfparam name="Contract_Id_List" default="">
<!--- List_Of_Contract_Main_IDs  will always be blank if  GetSettings.Date_Exclusions_ON EQ 0) --->
<cfset List_Of_Contract_Main_IDs = "">


<!--- If its a Date Exclusion Program, Append the date exclusion program ids to the Main Program ID --->
<cfif GetSettings.Date_Exclusions_ON EQ 1>

<!--- If "Contract_Status_legend.cfm" is not called (where the queries are already written), then call the queries from here --->
	<cfif NOT IsDefined("getParentContractInfo.RecordCount")>
		<cfset getParentContractInfo = GenProgramManager.ParentProgramInfo(CSLGetContractInfo.Contract_Main_ID)>
	</cfif>

	<cfif getParentContractInfo.RecordCount eq 0>
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSLGetContractInfo.Contract_Main_ID,0)>
			<cfset DECount = GenProgramManager.getStartDates(CSLGetContractInfo.Contract_Main_ID,CSLGetContractInfo.contract_start_date)>
		<cfelse>
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(getParentContractInfo.Contract_Main_ID,1)>
			<cfset DECount = GenProgramManager.getStartDates(getParentContractInfo.Contract_Main_ID,getParentContractInfo.contract_start_date)>
	</cfif>


			<cfif getParentContractInfo.RecordCount eq 0>
				<cfset List_Of_Contract_Main_IDs = QuotedvalueList(CSLGetContractInfo.Contract_Main_ID)>

				<cfif getDateExclusionprogramIDs.Revision_Program_ID neq "">
					<cfset List_Of_Contract_Main_IDs = List_Of_Contract_Main_IDs & ',' & QuotedvalueList(getDateExclusionprogramIDs.Revision_Program_ID)>
				</cfif>

			<cfelse>
				<cfset List_Of_Contract_Main_IDs = QuotedvalueList(getParentContractInfo.Contract_Main_ID)>

				<cfif getDateExclusionprogramIDs.Revision_Program_ID neq "">
					<cfset List_Of_Contract_Main_IDs = List_Of_Contract_Main_IDs & ',' & QuotedvalueList(getDateExclusionprogramIDs.Revision_Program_ID)>
				</cfif>

			</cfif>
		<cfset Contract_Id_List = List_Of_Contract_Main_IDs>
<cfelse>
		<cfset Contract_Id_List = CSLGetContractInfo.Contract_Main_ID>
</cfif>

<cfset discounttypes = CreateObject("component", "components.programs.program").getprogramDiscounttypes(Contract_Id_List) />
<cfset paymenttypeManager = CreateObject("component","components.programs.payment_type.paymenttype") />
<cfinclude template="/common_files/general_labels.cfm">
</cfsilent>

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" CLASS="TABLESIZE">
		<cfset titlecolwidth = 625>
	 	<cfset col1width = 150>
		<cfset col2width = 220>
		<cfset col1style = "padding: 2px;" >
		<cfset colmidstyle = "border-left: 1px solid ##cccccc; padding-left: 5px;"><!--- font-weight:bold; --->
<cfif url.eztemplate eq 0>
	<thead>
	<tr>
		<td colspan="2">
		<table>
		  <tr>
		    <td  nowrap="nowrap">
			<cfinclude template="#application.doc_mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">#application.returned_customer_setting.company_name#</div>
				<font size="+1" color="navy">
					<b>
						#getprogramstatus.getstatusdesc(cslgetcontractinfo.contract_status_type_idx)#: #cslgetcontractinfo.contract_number#
						<cfif cslgetcontractinfo.contract_status_type_idx gt 2>
							<cfif len(cslgetcontractinfo.revision_version) eq 4>
								#right("000#cslgetcontractinfo.revision_version#", 4)#
							<cfelseif len(cslgetcontractinfo.revision_version) eq 5>
								#right("000#cslgetcontractinfo.revision_version#", 5)#
							<cfelse>
								#right("000#cslgetcontractinfo.revision_version#", 3)#
							</cfif>
						</cfif>
					</b>
				</font>
				<cfif cslgetcontractinfo.Previous_Fiscal_Year_Volume eq 1>
					<font style="font-style: italic;">If this program is setup for Auto Pay, it will use prior year's volume for Auto Pay calculations.</font>
				</cfif>
		    </td>
		    <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
		    <td>
	  		<cfif #CSLGetContractInfo.Manual_Cancel# eq 1>
				<CFQUERY NAME="qGetUserCancelled" datasource="#application.datasource#">
					select name_first,name_last
					from _users
					where User_ID = '#CSLGetContractInfo.Cancelled_By#'
				</CFQUERY>
				<font color="red">Program cancelled by  #qGetUserCancelled.name_first# #qGetUserCancelled.name_last# on #DateFormat(CSLGetContractInfo.Cancelled_Date,"mm/dd/yyyy")#. The user cancelled the program using the option
				<cfif #CSLGetContractInfo.Cancel_And_End_Dated# eq 0>
					'Cancel as if it never existed'
				<cfelse>
					'Cancel as of today'
				</cfif>
				</font> <br>
	  		</cfif>
	  		<cfif Sent_To_External_Client EQ 1>
				<font size="3" color="red"><b>
					&nbsp;&nbsp;* This program is being sent to SAP *
				</b></font>
			</cfif>
			<cfif group_processed EQ 1>
				<font size="1" color="red"><b>
					&nbsp;&nbsp;* Group processing is done on a nightly basis. This program will be ready for approval tomorrow. *
				</b></font>
			</cfif>
			<!--- is trade eligible --->
			<cfif GetSettings.Include_Trade EQ 0>
				<font SIZE="2" COLOR="red"><I>
					<cfif len(trim(GetSettings.Trade_Blurb)) GT 0>
						#GetSettings.Trade_Blurb#
					<cfelse>
						* Volumes from this program are not eligible for any other trade or promotional allowances
					</cfif>
				</I></font>
			</cfif>
		    </td>
		  </tr>
		</table>
			<hr>
		</TD>
	</TR>
	</THEAD>
	<cfif  CSLGetContractInfo.Contract_Status_Type_IDX LT 3>
	<TR>
		<TD COLSPAN="2" align="left" valign="top">
			<font size="3" color="red"><b>* This program is not approved *</b></font>
		</TD>
	</TR>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	</cfif>
<!---
**************************************************************************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************HEADER INFO START*****************************************************************************************************************************************
**************************************************************************************************************************************************************************************************************************************************************************************
--->
<cfsetting showDebugOutput=yes>
<!---BID REQUEST  --->
<cfset bidReqObj = CreateObject("component", "components.programs.bid_request.BidRequestManager").getBidRequest(CSLGetContractInfo.Contract_Main_ID) />

<!--- VOLUME QUERIES START --->
	<!--- 39792 Bids - Exclude Lost From Volume Automation --->
	<cfset BidExcludeLostFromVolumeAuto = 0 />
	<cfif CSLGetContractInfo.BidRequestStatusOn eq 1 AND CSLGetContractInfo.ItemMarked_Lost_Program_Volume_Automation eq 0 AND trim(bidReqObj.getStatus()) NEQ 1>
		<cfset bidExcludeLostFromVolumeAuto = 1 />
	</cfif>

	<!--- Get the default Unit of time (uot) settings being used in the control panel-programs-settings--->
	<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
		SELECT	Volume_UOT_ID
		FROM		 _Users_Settings
		WHERE	User_ID		=		'#request.AccessStructure.Company_Main_ID#'
	</CFQUERY>

	<cfset program_Span = Datediff('d',CSLGetContractInfo.Contract_Start_Date, CSLGetContractInfo.Contract_End_Date) + 1>
	<!--- Dev Note: KAL; 8337 --->

	<cfset ProgVolQty 	= CreateObject("component", "components.programs.volume.ProgramVolume").getProgramQty(CSLGetContractInfo.Contract_Main_ID, program_Span, Get_Settings.Volume_UOT_ID,bidExcludeLostFromVolumeAuto) />
	<cfset Program_Qtg_Cases	= ProgVolQty.ProgramQtgCases>
	<cfset Program_Qtg_lbs		= ProgVolQty.ProgramQtglbs>
	<cfset Volume_UOT_Cases		= ProgVolQty.VolumeUOTCases>
	<cfset Volume_UOT_lbs		= ProgVolQty.VolumeUOTlbs>

	<!--- D37069 :: View Programs - Cases and Dollars for all effective versions START --->
	<cfset ProgTotalVolQty 	= CreateObject("component", "components.programs.volume.ProgramVolume").getTotalProgramQty(CSLGetContractInfo.Contract_Number,  Get_Settings.Volume_UOT_ID,bidExcludeLostFromVolumeAuto,CSLGetContractInfo.Contract_Main_ID) />
	<cfset Total_Program_Qtg_Cases	= ProgTotalVolQty.ProgramQtgCases>
	<cfset Total_Program_Qtg_lbs		= ProgTotalVolQty.ProgramQtglbs>
	<cfset Total_Volume_UOT_Cases		= ProgTotalVolQty.VolumeUOTCases>
	<cfset Total_Volume_UOT_lbs		= ProgTotalVolQty.VolumeUOTlbs>

	<!--- D37069 :: View Programs - Cases and Dollars for all effective versions END --->

	<!--- 27187 Add trade spend as a percentage of total base sales dollars --->
	<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval") />
	<cfset getProgramMargins = ApprovalProgramManager.getProgramMargins(CSLGetContractInfo.contract_main_id,1) />

	<!--- D37069 :: View Programs - Cases and Dollars for all effective versions START --->
	<cfset ProgTotalTradeSpend 	= CreateObject("component", "components.programs.volume.ProgramVolume").getTotalTradeSpend(CSLGetContractInfo.Contract_Number) />

	<cfif (getProgramMargins.Total_BaseSales_Dollar NEQ 0 AND getProgramMargins.recordcount NEQ 0)>
		<cfset TotalTradeSpendPercentage = round(ProgTotalTradeSpend.program_spend * 10000 /getProgramMargins.Total_BaseSales_Dollar) /100 >
	<cfelse>
		<cfset TotalTradeSpendPercentage =0/>
	</cfif>
<!--- D37069 :: View Programs - Cases and Dollars for all effective versions END --->

	<cfif (getProgramMargins.Total_BaseSales_Dollar NEQ 0 AND getProgramMargins.recordcount NEQ 0)>
		<cfif (isDefined("CSLGetContractInfo.program_spend") AND (CSLGetContractInfo.program_spend NEQ "" OR CSLGetContractInfo.program_spend NEQ 0))>
			<cfset TradeSpendPercentage = round(Val(CSLGetContractInfo.program_spend) * 10000 /getProgramMargins.Total_BaseSales_Dollar) /100 >
		<cfelse>
			<cfset TradeSpendPercentage =0/>
		</cfif>
	<cfelse>
		<cfset TradeSpendPercentage =0/>
	</cfif>
	<!--- D37069 :: View Programs - Cases and Dollars for all effective versions END --->

<!--- VOLUME QUERIES END --->

<!---
**************************************************************************************************************************************************************************************************************************************************************************************
*********************************************************************************************************DEFAULT HEADER INFO START  COLUMN A****************************************************************************************************************************
**************************************************************************************************************************************************************************************************************************************************************************************
--->

<!------------->
<!--- TITLE --->
<!------------->
<tr >
	<td colspan="2" cellpadding="2">
		<span style="display:inline-block; width:149px; font-weight:bold;">&nbsp;Title</span>
		<span style="display:inline-block; border-left:1px solid ##ccc; padding-left:2px; font-weight:bold;">&nbsp;#CSLGetContractInfo.Contract_Title#</span>
		<cfif GetSettings.Specify_Operators EQ 1>
			<cfset getOperators = ViewProgramManager.getOperators(CSLGetContractInfo.Contract_Main_ID)>
		</cfif>
	</td>
</tr>

<tr>
		<td >
						<TABLE border="0" cellpadding="0" cellspacing="0" class="tablesize2"><cfsilent>
								<!---D38043  :: Program revision dates - View Program --->
								<!--- DELIVERY PERIOD --->
								<cfquery name="ProgramDates" datasource="#application.datasource#">
										SELECT    MIN(effective_start_date) AS Min_effective_start_date,
										            	MAX(effective_end_Date) AS Max_effective_end_Date
										FROM  	Contract_Main
										WHERE    Contract_Number = '#CSLGetContractInfo.Contract_Number#'
										AND       	Approved = 1
										AND        Effective_Start_Date IS NOT NULL
								</cfquery>
								</cfsilent>
								<tr style="font-weight:bold;">
										<td width="#col1Width#" style="#col1Style#">#general_labels[ delivery_period ]#</td>
										<td width="#col2Width#" style="#colMidStyle#">
										<cfif len(ProgramDates.Min_effective_start_date) EQ 0>#dateformat(CSLGetContractInfo.Contract_Start_Date,'long')#<cfelse>#dateformat(ProgramDates.Min_effective_start_date,'long')#</cfif>
										to
										<cfif len(ProgramDates.Max_effective_end_Date) EQ 0>#dateformat(CSLGetContractInfo.Contract_End_Date,'long')#<cfelse>#dateformat(ProgramDates.Max_effective_end_Date,'long')#</cfif>
										</td>
								</tr>
								<!--- D38043  :: Program revision dates - View Program--->
								<cfif GetSettings.show_Contract_Dates eq 1>
								<tr style="font-weight:bold;">
									<td width="#col1Width#" style="#col1Style#">Contract Period</td>
									<td width="#col2Width#" style="#colMidStyle#">
										#dateformat(CSLGetContractInfo.contract_period_start_date,'long')#
											to
										#dateformat(CSLGetContractInfo.contract_period_end_date,'long')#
									</td>
								</tr>
								</cfif>
								<!--- BUSINESS SEGMENTS--->
								<cfif businessSegmentsOn eq 1>
									<tr>
											<td width="#col1Width#" style="#col1Style#">#appSettings.getbusiness_segment_label()#</td>
											<td width="#col2Width#" style="#colMidStyle#">#qGetThisBusSegment.Business_Unit_Desc#&nbsp;	</td>
									</tr>
								</cfif>
								<!--- PROGRAM TYPE --->
									<tr>
											<td width="#col1Width#" style="#col1Style#">Program Type</td>
											<td width="#col2Width#" style="#colMidStyle#">#CSLGetContractInfo.Created_Type#&nbsp;#CSLGetContractInfo.Template_Filter_Description#</td>
									</tr>
								<!--- BUDGETS --->
								<!---25715--->
								<cfset bProgramHasBudget = 0 />
								<cfif appSettings.getBudgetsFunctionalityOn()>
										<cfquery name="vars.qBudgets" datasource="#application.datasource#">
												SELECT b.Budget_Desc
												FROM Budget_Program_Selection bps
												INNER JOIN Budget b ON b.Budget_ID = bps.Budget_ID
												WHERE Program_ID = <cfqueryparam value="#CSLGetContractInfo.Contract_Main_ID#" cfsqltype="cf_sql_integer">
										</cfquery>
										<cfif vars.qBudgets.RecordCount>
											<cfset bProgramHasBudget = 1 />
										</cfif>
										<tr>
											<td width="#col1Width#" style="#col1Style#" >Budget</td>
										<!---25715 - budget728 id is used in other file, do not change it--->
											<td width="#col2Width#" style="#colMidStyle#" id="budget728">
										<cfloop query="vars.qBudgets">
												#vars.qBudgets.Budget_Desc#<br/>
										</cfloop>
											</td>
										</tr>
								</cfif>
						</TABLE>
		</td>
<!---
**************************************************************************************************************************************************************************************************************************************************************************************
*********************************************************************************************************DEFAULT HEADER INFO START  COLUMN B****************************************************************************************************************************
**************************************************************************************************************************************************************************************************************************************************************************************
--->
		<td  style="padding-left:5;">

						<TABLE border="0" cellpadding="0" cellspacing="0" class="tablesize2">
						<!--- D37069 :: View Programs - Cases and Dollars for all effective versions START --->
						<!--- TOTAL VOLUME --->
						<tr>
							<td width="#col1Width#" style="#col1Style#">#application.returned_customer_setting.Total_Volume_Label#</td>
							<td width="#col2Width#" style="#colMidStyle#">
					<cfif IsStruct(ProgTotalVolQty)>
						<cfif appSettings.getViewProgramVolumeUOM() EQ 1>
								#trim(numberformat(round(Total_Program_Qtg_Cases),'___,___,___,___,___,___'))# #Application.UOMCasePlural#
						<cfelseif appSettings.getViewProgramVolumeUOM() EQ 2>
								#trim(numberformat(round(Total_Program_Qtg_lbs),'___,___,___,___,___,___'))# #Application.UOMPoundPlural#
						<cfelse>
								#trim(numberformat(round(Total_Program_Qtg_Cases),'___,___,___,___,___,___'))# #Application.UOMCasePlural# / #trim(numberformat(round(Total_Program_Qtg_lbs),'___,___,___,___,___,___'))# #Application.UOMPoundPlural#
						</cfif>
					<cfelse>
								#trim(numberformat(round(CSLGetContractInfo.Contract_Quantity),'___,___,___,___,___,___'))# #getContractUOMLabel.Unit_Of_Measure_Desc#&nbsp;
					</cfif>
							</td>
						</tr>
					<!--- TOTAL ESTIMATED TRADE DOLLARS --->
					<cfif (appSettings.getApprovalLayeredOn() OR appSettings.getapprovalStandardOn()) AND CSLGetContractInfo.Approved AND appSettings.getViewProgramEstimatedAmount() EQ 1>
							<!--- Get payment $ from payment history --->
							<cfquery name="qPaymentHistory" datasource="#application.datasource#">
								select	sum(paid_amount) as paid_amount
								from	payment_history_details d 
								where	d.contract_number = '#CSLGetContractInfo.Contract_Number#'
							</cfquery>
							<tr>
								<td width="#col1Width#" style="#col1Style#">Total Estimated Trade $ / Payment $</td>
								<td width="#col2Width#" style="#colMidStyle#">#trim(Dollarformat(ProgTotalTradeSpend.program_spend))#&nbsp;/&nbsp;#trim(Dollarformat(qPaymentHistory.paid_amount))#&nbsp;</td>
							</tr>
					</cfif>
					<!--- D37069 :: View Programs - Cases and Dollars for all effective versions END --->
					<!--- D51049 :: View Program Update for Committed and Actual $ START --->
					<!--- TOTAL Committed $ and Actual $ --->
						<cfif appSettings.getBudgetsFunctionalityOn()>
							<cfset qbudgetReport = budgetReportMgr.getBudgetLabels()>
							<cfquery name="dollaramount" datasource="#application.datasource#">
								DECLARE @Committed_Dollar decimal(20, 4),
								            	@Actual_Dollar decimal(20, 4)

								SELECT @Committed_Dollar = SUM(pg.Committed_Dollar),
								           @Actual_Dollar = SUM(pg.Actual_Dollar)
								FROM  Budget_Position_Program pg
								WHERE pg.Contract_Number = '#CSLGetContractInfo.Contract_Number#'

								SELECT  @Committed_Dollar = ISNULL(@Committed_Dollar, 0) + ISNULL(SUM(pg.Committed_Dollar), 0),
								             @Actual_Dollar = ISNULL(@Actual_Dollar, 0) + ISNULL(SUM(pg.Actual_Dollar), 0)
								FROM  Budget_Distributor_Program pg
								WHERE pg.Contract_Number = '#CSLGetContractInfo.Contract_Number#'

								SELECT @Committed_Dollar as Committed_Dollar, @Actual_Dollar as Actual_Dollar
							</cfquery>
							<cfif bProgramHasBudget OR dollaramount.Committed_Dollar NEQ 0 OR dollaramount.Actual_Dollar NEQ 0>
							<tr>
								<td width="#col1Width#" style="#col1Style#">Total Budget #qbudgetReport.Committed_Dollar_Label# / #qbudgetReport.Approved_Payment_Dollar_Label#</td>
								<td width="#col2Width#" style="#colMidStyle#">#dollarformat(dollaramount.Committed_Dollar)#&nbsp;/&nbsp;#dollarformat(dollaramount.Actual_Dollar)#</td>
							</tr>
							</cfif>
						</cfif>
					<!--- D51049 :: View Program Update for Committed and Actual $ END --->
					<!--- PROGRAM CURRENCY --->
							<tr>
								<td width="#col1Width#" style="#col1Style#">Program Currency</td>
								<td width="#col2Width#" style="#colMidStyle#">#CurrencyVar#&nbsp;</td>
							</tr>

				<!--- RESPONSIBLE SALES PERSON --->
				<cfif application.returned_customer_setting.Responsible_Person EQ 1>
						<tr>
							<td width="#col1Width#" style="#col1Style#" >Responsible Sales Person</td>
							<td width="#col2Width#" style="#colMidStyle#">
						<cfsilent>
								<!---if summary view, show detail information of user such as email, phone no--->
								<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(CSLGetContractInfo.Responsible_User_ID) />
								<cfquery name="PositionDescforCreating" datasource="#application.datasource#">
										SELECT Position_Label
										FROM User_Positions
										WHERE User_Positions_ID = '#CSLGetContractInfo.Creating_User_Position_ID#'
								</cfquery>
								<!--- Changed this control to display RSP Company_Name instead of Work_Address_2 --->
								<cfset displaySPRAddress2 = "" />
								<cfif appSettings.getPgmViewDisplaySPRAddress2() AND Trim(qUser.Company_Name) NEQ "">
										<cfset displaySPRAddress2 = ", #Trim(qUser.Company_Name)#" />
								</cfif>
						</cfsilent>

						<cfif summaryView>
								<cfif quser.recordcount gt 0>
									<table cellpadding="2" cellspacing="0" border="0" bgcolor="f2f2f2">
										<tr>
											<td><b>Name:</b>   #quser.user_full_name#<cfif displayspraddress2 neq "">#displayspraddress2#</cfif> (#positiondescforcreating.position_label#) &nbsp;</td>
											<td width="1px">&nbsp;</td>
											<td><b>Phone:</b> #quser.user_work_phone# <cfif len(quser.work_phone_ext) gt 0> ext: #quser.work_phone_ext#</cfif></td>
										</tr>
										<tr>
											<td nowrap><b>Title:</b> &nbsp; #quser.title#</td>
											<td  width="1px">&nbsp;</td>
											<td><b>Email:</b>&nbsp;&nbsp; <a href="mailto:#quser.user_email#">#quser.user_email#</a></td>
										</tr>
									</table>&nbsp;
								<cfelse>
										<font size="2" color="red"><b>Vacant</b></font> (#positiondescforcreating.position_label#)
								</cfif>
						<cfelse>
								<cfif quser.recordcount>
										#quser.user_full_name#
								<cfelse>
										<font size="2" color="red"><b>Vacant</b></font>
								</cfif>
								<cfif displayspraddress2 neq "">
										#displayspraddress2#
								</cfif>
										(#positiondescforcreating.position_label#) &nbsp;
						</cfif>
								</td>
							</tr>
				</cfif>
				</TABLE>
		</td>
</tr>
<!--- NOTES --->
<tr style="padding-top:4px;padding-bottom:8px;">
		<td  colspan="2">&nbsp;Notes:
									<cfif appSettings.getDisplayNotesFieldOnProgram() EQ 1>
										<cfif len(trim(cslgetcontractinfo.notes))>
													#replace(replace(cslgetcontractinfo.notes, " ", " &nbsp;", "all"), "#chr(13)#", "<br>", "all")#
										<cfelse>
													(none)
										</cfif>
													&nbsp;
									</cfif>
		</td>
</tr>

<!---
**************************************************************************************************************************************************************************************************************************************************************************************
********************************************************************************************************HIDDEN HEADER INFO START COLUMN A*******************************************************************************************************************************
**************************************************************************************************************************************************************************************************************************************************************************************
--->
<tr>
	<td colspan="2">
		<BR><B><FONT SIZE="2" COLOR="Navy">More Header Information</FONT></B><a href="##" style="margin-left:5px;" id="toggleHeader"></a><HR COLOR="Navy">
	</td>
</tr>

<!---TSF: MODIFICATION Bid Request--->
<!---FILTER: if the template/program type is Bid Request, then get,set and display for Bid Request--->
<!---BID REQUEST  --move up as 39792 Bids - Exclude Lost From Volume Automation needs Program_Bid_Request.Bid_Request_status_ID
<cfset bidReqObj = CreateObject("component", "components.programs.bid_request.BidRequestManager").getBidRequest(CSLGetContractInfo.Contract_Main_ID) />  --->
<tr id="headerInfo">
		<td >
				<TABLE border="0" cellpadding="0" cellspacing="0" class="tablesize2">
							<!--- VERSION DATES --->
							<tr>
									<td width="#col1Width#" style="#col1Style#">Version Date</td>
									<td width="#col2Width#" style="#colMidStyle#">
									#dateformat(CSLGetContractInfo.Contract_Start_Date,'long')# to #dateformat(CSLGetContractInfo.Contract_End_Date,'long')#
									</td>
							</tr>
							<!--- APPROVAL DATE --->
							<cfif isDefined("CSLGETCONTRACTINFO.Approval_Date")>
								<cfif len(trim(CSLGETCONTRACTINFO.Approval_Date)) GT 0>
										<tr>
												<td width="#col1Width#" style="#col1Style#">Approved On</td>
												<td width="#col2Width#" style="#colMidStyle#">#dateformat(CSLGETCONTRACTINFO.Approval_Date, 'MM/DD/YYYY')#&nbsp;	</td>
										</tr>
								</cfif>
							</cfif>
							<!--- DATE TO CLAIM --->
							<cfif GetSettings.Billback_Date IS 1 AND GetSettings.Billback_Date_Span GT 1>
								<cfset PaymentRequestDue = dateadd("d", GetSettings.Billback_Date_Span, CSLGetContractInfo.Contract_End_Date)>
										<tr>
												<td width="#col1Width#" style="#col1Style#">Last Date to Claim</td>
												<td width="#col2Width#" style="#colMidStyle#">#dateformat(PaymentRequestDue, 'mmmm dd, yyyy')#&nbsp;&nbsp;( #GetSettings.Billback_Date_Span# days after expiration )&nbsp;	</td>
										</tr>
							</cfif>
							<!--- OPEN DATE --->
							<cfif GetSettings.Include_Open_Date IS 1>
										<tr>
												<td width="#col1width#" style="#col1style#">Open Date</td>
												<td width="#col2width#" style="#colmidstyle#">#dateformat(bidreqobj.getopendate(), "mm/dd/yyyy")#&nbsp;</td>
										</tr>
							</cfif>
							<!--- TIME OF OPEN DATE --->
							<cfif getsettings.include_time_of_open_date is 1>
									<tr>
											<td width="#col1width#" style="#col1style#">Time of Open Date</td>
											<td width="#col2width#" style="#colmidstyle#">#bidreqobj.getopentime()#&nbsp;</td>
									</tr>
							</cfif>
							<!--- DATE NEEDED --->
							<cfif GetSettings.Include_Date_Needed_by IS 1>
										<tr>
												<td width="#col1width#" style="#col1style#">Date Needed</td>
												<td width="#col2width#" style="#colmidstyle#">#dateformat(bidreqobj.getdateneeded(), "mm/dd/yyyy")#&nbsp;</td>
										</tr>
							</cfif>
							<!--- PROGRAM AWARD DATE --->
							<cfif getsettings.include_reply_date is 1>
									<tr>
											<td width="#col1width#" style="#col1style#">Program Award Date</td>
											<td width="#col2width#" style="#colmidstyle#">#dateformat(bidreqobj.getexpectedreplydate(), "mm/dd/yyyy")#&nbsp;</td>
									</tr>
							</cfif>
							<!--- EFFECTIVE DATE FOR PRICE --->
							<!--- Dev Notes:29632 - Effective Date for Price/Anand Rao/21-Dec-2011 --->
							<cfif (appSettings.PRICE_LIST_BY_TEMPLATE EQ 1 AND getFieldSettings.Base_Sales_based_on_Prg_Start_Date EQ 1 AND getFieldSettings.Select_Effective_Date_for_Price EQ 1)>
									<tr>
											<td width="#col1Width#" style="#col1Style#">Effective Date for Price</TD>
											<td width="#col2Width#" style="#colMidStyle#">
												<cfif CSLGetContractInfo.Effective_Date_for_Price EQ "">
														No Effective Date
												<cfelse>
														#DateFormat(CSLGetContractInfo.Effective_Date_for_Price, "mm/dd/yyyy")#&nbsp;
												</cfif>
											</td>
									</tr>
							<!--- PRICE PROTECTION DATE --->
									<!--- D32776:Effective Price Date Changed on all Bid Programs START --->
									<tr>
											<td width="#col1Width#" style="#col1Style#">Price Protection Date</TD>
											<td width="#col2Width#" style="#colMidStyle#">
												<cfif CSLGetContractInfo.Price_Protection_Date EQ "">
														No Price Protection Date
												<cfelse>
														#DateFormat(CSLGetContractInfo.Price_Protection_Date, "mm/dd/yyyy")#&nbsp;
												</cfif>
											</td>
									</tr>
									<!--- D32776:Effective Price Date Changed on all Bid Programs END --->
							</cfif>
							<!--- End 29632 --->
							<!---PERFORMANCE DATES--->
							<cfif getSettings.Retail_Performance_Dates EQ 1 AND IsDate(CSLGetContractInfo.Performance_Start_Date) AND IsDate(CSLGetContractInfo.Performance_End_Date)>
							<cfset PerformanceDatesLabel 	= labelComp.GetGeneralLabels('Performance Dates').General_Labels_Label />
										<tr >
												<td width="#col1Width#" style="#col1Style#"><b>#PerformanceDatesLabel#</b></td>
												<td width="#col2Width#" style="#colMidStyle#">
														#MonthAsString(datepart('m', CSLGetContractInfo.Performance_Start_Date))#&nbsp;#datepart('d', CSLGetContractInfo.Performance_Start_Date)#,&nbsp;#datepart('yyyy', CSLGetContractInfo.Performance_Start_Date)#
														to
														#MonthAsString(datepart('m', CSLGetContractInfo.Performance_End_Date))#&nbsp;#datepart('d', CSLGetContractInfo.Performance_End_Date)#,&nbsp;#datepart('yyyy', CSLGetContractInfo.Performance_End_Date)#
														&nbsp;
												</td>
									</tr>
							</cfif>
							<!--- PROPOSAL STATUS --->
							<cfif cslgetcontractinfo.bidrequeststatuson eq 1>
								<tr>
											<td width="#col1width#" style="#col1style#">Proposal Status</td>
											<!---filter: do if it's pending--->
											<td width="#col2width#" style="#colmidstyle#">#bidreqobj.getstatusdesc()#<cfif trim(bidreqobj.getstatusdesc()) eq "pending">...</cfif>&nbsp;</td>
									</tr>
							</cfif>
							<!--- COMPETITIVE INFORMATION --->
							<cfif trim(cslgetcontractinfo.generic_type) eq "direct pricing">
										<tr >
												<td width="#col1width#" style="#col1style#">Competitive Information</td>
												<td width="#col2width#" style="#colmidstyle#">
												<!---filter: if there aren't any notes then say so--->
													<cfif len(trim(cslgetcontractinfo.competitive_info_notes))>
														#replace(replace(cslgetcontractinfo.competitive_info_notes, " ", " &nbsp;", "all"), "#chr(13)#", "<br>", "all")#
													<cfelse>
														(none)
													</cfif>&nbsp;
												</td>
										</tr>
							</cfif>
							<!--- LINE ITEM --->
							<cfif cslgetcontractinfo.bidrequeststatuson eq 1>
									<tr>
											<td width="#col1width#" style="#col1style#">Line Item</td>
											<td width="#col2width#" style="#colmidstyle#">
												<cfif bidreqobj.getlineitem()>
													yes
												<cfelse>
													no
												</cfif>
											</td>
									</tr>
							</cfif>
							<!--- AWARDED --->
							<cfif getsettings.show_awarded_in_catalog is 1>
									<tr>
											<td width="#col1width#" style="#col1style#">Awarded</td>
											<td width="#col2width#" style="#colmidstyle#" >
											<cfif cslgetcontractinfo.is_awarded is 1>
												yes
											<cfelse>
												no
											</cfif>
											</td>
									</tr>
							</cfif>
							<!--- PAYMENT CYCLE --->
							<cfif NOT appSettings.getPaymentCycleAtDiscountType()>
								<cfset getPaymentCycles =  ViewProgramManager.getPaymentCycles(CSLGetContractInfo.PaymentCycle)>
										<tr>
												<td width="#col1Width#" style="#col1Style#">Payment Cycle</td>
												<td width="#col2Width#" style="#colMidStyle#">#getPaymentCycles.Payment_Cycle#&nbsp;</td>
										</tr>
							</cfif>
							<!---SEARCH SEQUENCE INFORMATION--->
							<cfif appSettings.getSearchSequenceOn() AND len(trim(CSLGetContractInfo.Search_Sequence_ID))>
									<cfset searchSequenceManager 			= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
									<cfset Search_Sequence_Name = searchSequenceManager.getSearchSequenceInfo(CSLGetContractInfo.Search_Sequence_ID) />
									<tr>
											<td width="#col1Width#" style="#col1Style#">Search Sequence</td>
											<td width="#col2Width#" style="#colMidStyle#">#Search_Sequence_Name.Search_Sequence_Legacy# #Search_Sequence_Name.Search_Sequence_Desc#</td>
									</tr>
							</cfif>
							<!--- SIMILAR PRODUCT EXIST --->
							<cfif appSettings.getPgmLikeProductCheckbox()>
								<cfif CSLGetContractInfo.Like_Product_Exist EQ 1>
									<tr>
											<td width="#col1Width#" style="#col1Style#">Similar Product Exist</td>
											<td width="#col2Width#" style="#colMidStyle#">
												<cfif CSLGetContractInfo.Like_Product_Exist EQ 1>
													yes
												<cfelse>
													no
												</cfif>&nbsp;
											</td>
									</tr>
								</cfif>
							</cfif>
							<!--- FREIGHT NOTES --->
							<cfif appSettings.getDisplayNotesFieldOnProgram() EQ 1 AND programfreighton eq 1 AND programdistributorfreightcount eq 1 AND programfreightcomponenttype neq 0>
										<tr>
												<td width="#col1width#" style="#col1style#">Freight Notes:</td>
												<td width="100%" style="#colmidstyle# font-weight:normal;">
													<cfif len(trim(cslgetcontractinfo.freight_notes))>
														#replace(replace(trim(cslgetcontractinfo.freight_notes), "  ", " &nbsp;", "all"), "#chr(13)#", "<br>", "all")#
													<cfelse>
													    (none)
													</cfif>
													&nbsp;
												</td>
										</tr>
							</cfif>
							<!---EQUIPMENT PLACEMENT--->
							<cfif getContract_Main_Aux_Data.Equipment_Placement IS 1>
									<tr>
											<td width="#col1width#" style="#col1style#">Equipment Placement</td>
											<td width="#col2width#" style="#colmidstyle#" >yes</td>
									</tr>
							</cfif>
							<!--- EQUIPMENT PLACEMENT NOTE --->
							<cfif getContract_Main_Aux_Data.Equipment_Placement IS 1>
									<tr >
											<td width="#col1Width#" style="#col1Style#">Equipment Placement Note</td>
											<td width="#col2Width#" style="#colMidStyle#" >
												<cfif getContract_Main_Aux_Data.Equipment_Placement_Note neq "">
													#getContract_Main_Aux_Data.Equipment_Placement_Note#
												<cfelse>
													(None)
												</cfif>
											</td>
									</tr>
							</cfif>
				</TABLE>
		</td>
<!---
**************************************************************************************************************************************************************************************************************************************************************************************
*********************************************************************************************************HIDDEN HEADER INFO START  COLUMN B *****************************************************************************************************************************
**************************************************************************************************************************************************************************************************************************************************************************************
--->
<td style="padding-left:8px;" >
				<TABLE border="0" cellpadding="0" cellspacing="0" class="tablesize2">
					<!--- PROGRAM VOLUME --->
							<tr>
									<td width="#col1Width#" style="#col1Style#">#application.returned_customer_setting.Program_Quantity_Label#</td>
									<td width="#col2Width#" style="#colMidStyle#">
					<!---	D36632--->
					<cfif IsStruct(ProgVolQty)>
							<cfif appSettings.getViewProgramVolumeUOM() EQ 1>
									#trim(numberformat(round(Program_Qtg_Cases),'___,___,___,___,___,___'))# #Application.UOMCasePlural#
							<cfelseif appSettings.getViewProgramVolumeUOM() EQ 2>
									#trim(numberformat(round(Program_Qtg_lbs),'___,___,___,___,___,___'))# #Application.UOMPoundPlural#
							<cfelse>
									#trim(numberformat(round(Program_Qtg_Cases),'___,___,___,___,___,___'))# #Application.UOMCasePlural# / #trim(numberformat(round(Program_Qtg_lbs),'___,___,___,___,___,___'))# #Application.UOMPoundPlural#
							</cfif>
					<cfelse>
							#trim(numberformat(round(CSLGetContractInfo.Contract_Quantity),'___,___,___,___,___,___'))# #getContractUOMLabel.Unit_Of_Measure_Desc#&nbsp;
					</cfif>
									</td>
							</tr>
					<!--- VERSION TRADE AMOUNT --->
					<cfif (appSettings.getApprovalLayeredOn() OR appSettings.getapprovalStandardOn()) AND CSLGetContractInfo.Contract_Status_Type_IDX GTE 2  AND appSettings.getViewProgramEstimatedAmount() EQ 1>
							<tr>
									<td width="#col1Width#" style="#col1Style#">Version Trade $:</td>
									<td width="#col2Width#" style="#colMidStyle#">#trim(Dollarformat(CSLGetContractInfo.program_spend))#&nbsp;/&nbsp;#trim(numberformat(TradeSpendPercentage,'_-___,___,___,___,___._'))#%</td>
							</tr>
					</cfif>
	 				<!---DISCOUNT IDENTIFIERS--->
					<cfif getGeneralSettings.Use_Discount_ID IS 1 AND len(trim(GetSettings.Discount_Identifier_ID)) GT 0>
							<cfset GetDiscountIdentifier =  ViewProgramManager.GetDiscountIdentifier(GetSettings.Discount_Identifier_ID)>
								<tr>
										<td width="#col1Width#" style="#col1Style#">Discount Identifier</td>
										<td width="#col2Width#" style="#colMidStyle#">(#GetDiscountIdentifier.Discount_Identifier_Number#)&nbsp;&nbsp;#GetDiscountIdentifier.Discount_Identifier_Desc#</td>
								</tr>
					</cfif>

					<!---Bracket Override--->
					<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "CPA">
						<cfset BracketOveride =  '' >
						<cfif len(CSLGetContractInfo.Override_Price_List_Id) GT 25>
							<cfquery name="qGetPriceListOverRide" datasource="#application.datasource#">
								SELECT Price_list_Id,
									Price_List_Header_Id
								FROM Price_List_Header H
								where Price_List_Header_Id = '#CSLGetContractInfo.Override_Price_List_Id#'
							</cfquery>
							<cfset BracketOveride =  qGetPriceListOverRide.Price_list_Id >
						</cfif>		
								<tr>
										<td width="#col1Width#" style="#col1Style#">Bracket Price Override</td>
										<td width="#col2Width#" style="#colMidStyle#">#BracketOveride#</td>
								</tr>
					</cfif>

					<!--- LINE OF BUSINESS --->
					<cfif appSettings.getSalesOrgOn()>
								<tr>
										<td width="#col1Width#" style="#col1Style#">#appSettings.getlob_label()#</td>
										<td width="#col2Width#" style="#colMidStyle#">#Line_Of_Business_Name#</td>
								</tr>
					</cfif>
					<!--- REFERENCE --->
					<tr>
							<td width="#col1Width#" style="#col1Style#">#application.returned_customer_setting.reference_number_label#</td>
							<td width="#col2Width#" style="#colMidStyle#">
					<cfif appsettings.getSend_to_SAP()>
							&nbsp;
					<cfelse>
							#CSLGetContractInfo.Contract_Reference_Number#&nbsp;
					</cfif>
							</td>
					</tr>
					<!--- REFERENCE 2 --->
					<tr>
							<td width="#col1Width#" style="#col1Style#">#application.returned_customer_setting.reference_number_2_label#</td>
							<td width="#col2Width#" style="#colMidStyle#">
					<cfif appsettings.getSend_to_SAP()>
							&nbsp;
					<cfelse>
							#CSLGetContractInfo.Contract_Reference_Number_2#&nbsp;
					</cfif>
							</td>
					</tr>
					<!----LEGACY ID--->
					<cfif appSettings.getView_Legacy_ID() EQ 1>
						<cfset labelComp = CreateObject("component", "components.settings.labels.labels").init() />
						<cfset legacyIDLabel = labelComp.GetGeneralLabels('Legacy ID').General_Labels_Label />
								<tr>
										<td width="#col1Width#" style="#col1Style#">#legacyIDLabel#</td>
										<td width="#col2width#" style="#colmidstyle#">#cslgetcontractinfo.legacy_deal_id#&nbsp;</td>
								</tr>
					</cfif>
					<!----BID ID--->
					<cfif application.returned_customer_setting.display_bid_id>
						<tr>
								<td width="#col1Width#" style="#col1Style#">Bid ID</td>
								<td width="#col2Width#" style="#colMidStyle#">#CSLGetContractInfo.BID_NUMBER#</td>
						</tr>
					</cfif>
					<!--- MANAGER --->
							<cfif appsettings.getShowManagerDetailsOnViewProgram() eq 1>
									<tr>
										<td width="#col1Width#" style="#col1Style#"  >Manager</td>
										<td width="#col2Width#" nowrap style="#colMidStyle#">
										<cfset getpositionabove = CreateObject("component", "components.geography.position").getFirstPositionAbove(CSLGetContractInfo.Creating_User_Position_ID) />
							</cfif>
							<cfif getpositionabove neq -1>
										<cfquery name="PositionDescforManager" datasource="#application.datasource#">
												SELECT Position_Label
												FROM User_Positions
												WHERE User_Positions_ID = '#getpositionabove#'
										</cfquery>
									<cfif PositionDescforManager.recordcount GT 0>
											<cfquery name="getManagerDetails" datasource="#application.datasource#">
													SELECT top 1 name_first, name_last, (work_phone_1 + '-' + work_phone_2 + '-' + work_phone_3) AS "Work_Phone",Work_Phone_Ext,user_email,title
													FROM user_position_holders
													INNER JOIN _users ON
													_users.user_id = user_position_holders.user_id
													AND _users.deleted = 0
													WHERE user_position_holders.user_positions_id = '#getpositionabove#'
													AND user_position_type = 'P'
													AND user_position_holders.deleted = 0
													AND _Users.User_Rights_ID != 9999
													AND _Users.User_Email NOT LIKE '%bigredflame%'
											</cfquery>
											<cfif getManagerDetails.recordcount GT 0>
													<table cellpadding="2" cellspacing="0" border="0" bgcolor="F2F2F2">
														<tr>
															<td nowrap><B>Name:</B>#getManagerDetails.name_first# #getManagerDetails.name_last#&nbsp;</td>
															<td width="1px">&nbsp;</td>
															<td><B>Phone:</B> #getManagerDetails.Work_Phone# <cfif Len(getManagerDetails.Work_Phone_Ext) GT 0> Ext: #getManagerDetails.Work_Phone_Ext#</cfif></td>
													</tr>
													<tr>
															<td nowrap><B>Position:</B> &nbsp; #PositionDescforManager.Position_Label#</td>
															<td  width="1px">&nbsp;</td>
															<td nowrap><B>Email:</B>&nbsp;&nbsp; <a href="mailto:#getManagerDetails.User_Email#">#getManagerDetails.User_Email#</a></td>
													</tr>
												</table>
										<cfelse>
												#PositionDescforManager.Position_Label#&nbsp;
										</cfif>
								</cfif>
						<cfelse>
								&nbsp;
						</cfif>
						</td>
					</tr>
					<!--- REQUIREMENTS --->
					<cfset GetPerfRequirements =  ViewProgramManager.GetPerfRequirements(CSL_Contract_Main_ID)>
					<cfif GetPerfRequirements.Recordcount GT 0>
								<tr>
										<td width="#col1width#" style="#col1style#">Requirements:<br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  </td>
										<td width="#col2width#" style="#colmidstyle#" >
											<cfloop query="getperfrequirements">
												#requirement_name#<br>
											</cfloop>
										</td>
								</tr>
					</cfif>
					<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND (GetDiscountIdentifier.Discount_Identifier_Number EQ "CPA" OR GetDiscountIdentifier.Discount_Identifier_Number EQ "GPO") >
							<cfquery name="getPayType" datasource="#application.datasource#">
								 select ClaimMechanics,PT.Payment_Type_Name
								 From Contract_Main CM
								 Inner Join Payment_Type pt on
									PT.Payment_Type_Id = CM.ClaimMechanics
								 where Contract_Main_Id = #CSL_Contract_Main_ID#
							</cfquery>
							<tr>
										<td width="#col1width#" style="#col1style#">Rebate Eligibility</td>
										<td width="#col2width#" style="#colmidstyle#" valign="top">
											#getPayType.Payment_Type_Name#
										</td>
								</tr>
					</cfif>

				<!--- START:: 116758: Performance Type for non-retail programs / Anand Rao / 25-Aug-2022 --->
					<cfif (CSLGetContractInfo.Planner_Perf_Type_ID NEQ 0)>
						<cfoutput>
							<cfquery name="getPlannerPerfType" datasource="#application.datasource#">
								SELECT * FROM Planner_Perf_Types WHERE Planner_Perf_Types_ID = #CSLGetContractInfo.Planner_Perf_Type_ID#
							</cfquery>
						</cfoutput>
						<tr>
							<td width="#col1width#" style="#col1style#">Performance Type</td>
							<td width="#col2width#" style="#colmidstyle#" valign="top">
								#getPlannerPerfType.Description#
							</td>
						</tr>
					</cfif>
				<!--- END:: 116758: Performance Type for non-retail programs / Anand Rao / 25-Aug-2022 --->
					
					<!---PULLBACKS--->
					<cfif appSettings.getPullbacksOn() EQ 1>
						<cfif CSLGetContractInfo.generic_type EQ "Distributor Trade/Shelter" and CSLGetContractInfo.Pullbacks_On EQ 1 AND appSettings.get_Setting('Recapture_By_Operator_For_Multiple_Lists') NEQ '1'>
								<tr>
										<td width="#col1width#" style="#col1style#"><cfoutput>#appsettings.getpullbacklabel()#</cfoutput> from this program</td>
										<td width="#col2width#" style="#colmidstyle#" >
											<cfif cslgetcontractinfo.pullback_from_this_program eq 1>
												yes
											<cfelse>
												no
											</cfif>
										</td>
								</tr>
						</cfif>
					</cfif>
					<!--- d8409: broker and trade question --->
					<!------BROKER TRADE QUESTIONS ----->
					<cfif appsettings.getbrokertradequeston() eq 1 and getsettings.broker_trade_question eq 1>
							<tr >
									<td width="#col1width#" style="#col1style#">is #lcase(application.returned_customer_setting.broker_label_singular)#'s commission affected by this #lcase(application.rebatelabel)#/billback?</td>
									<td width="#col2width#" style="#colmidstyle#" valign="bottom">#genprogrammanager.getaffectbrokercommission(cslgetcontractinfo.affect_broker_commission)#</td>
							</tr>
						<cfif cslgetcontractinfo.affect_broker_commission eq 1>
								<tr >
										<td width="#col1width#" style="#col1style#">the commission should be</td>
										<td width="#col2width#" style="#colmidstyle#" valign="bottom">#genprogrammanager.getaffectbrokercommissiontype(cslgetcontractinfo.affect_broker_commission_type)#</td>
								</tr>
						</cfif>
								<tr >
										<td width="#col1width#" style="#col1style#">is shelter affected?</td>
										<td width="#col2width#" style="#colmidstyle#" valign="bottom">#genprogrammanager.getaffectshelter(cslgetcontractinfo.affect_shelter)#</td>
								</tr>
						<cfif cslgetcontractinfo.affect_shelter eq 1>
								<tr >
										<td width="#col1width#" style="#col1style#">shelter affects</td>
										<td width="#col2width#" style="#colmidstyle#" valign="bottom">#genprogrammanager.getaffectsheltertypes(cslgetcontractinfo.affect_shelter_type)#</td>
								</tr>
						</cfif>
					</cfif>

					<!--- ALTERNATE PAYMENT RECIPIENT --->
					<!--- D37492 /D38189::Alternate Payment Recipient --->
					<cfif GetSettings.alternate_payment_recipient AND len(CSLGetContractInfo.Alternate_Payment_Recipient)>
							<cfquery name="operatorinfo" datasource="#application.datasource#">
									SELECT Operator_Name + '(' + isnull(Legacy_ID, BSA_Operator_ID) +')' AS Operator_info
									FROM BSA_Operator
									WHERE BSA_Operator_ID = #trim(CSLGetContractInfo.Alternate_Payment_Recipient)#
							</cfquery>
						<tr>
								<td width="#col1Width#" style="#col1Style#">Alternative Payment Recipient</td>
								<td width="#col2Width#" style="#colMidStyle#">#operatorinfo.operator_info#</td>
						</tr>
					</cfif>
					<!--- CURRENCY CONVERSION --->
					<!--- 34302 --->
					<cfif getFieldSettings.currency_conversion_factor eq "1">
							<tr>
								<td width="#col1Width#" style="#col1Style#">Currency Conversion Factor</td>
								<td width="#col2Width#" style="#colMidStyle#">#CSLGetContractInfo.currency_conversion_factor#&nbsp;</td>
							</tr>
					</cfif>
					<!--- D37492/D38189::Alternate Payment Recipient  --->
					<!------ PROGRAM LABEL ----->
					<cfif appSettings.getUse_Accounting_Program_Type() EQ 1 AND IsNumeric(CSLGetContractInfo.Accounting_Program_Type_ID)>
							<cfset AccountingProgramTypeManager = CreateObject("component","components.programs.Accounting_Program_Type.AccountingProgramTypeManager").init() />
							<cfset GetAPT = AccountingProgramTypeManager.getAccountingProgramTypes(CSLGetContractInfo.Accounting_Program_Type_ID) />
							<cfif GetAPT.Recordcount GT 0>
								<tr>
										<td width="#col1Width#" style="#col1Style#">Program Label</td>
										<td width="#col2Width#" style="#colMidStyle#">#GetAPT.APT_Name#
											<cfif len(trim(GetAPT.APT_Reference_Number)) GT 0>
												(#trim(GetAPT.APT_Reference_Number)#)
											</cfif>
										</td>
								</tr>
							</cfif>
					</cfif>
					<!------ OPERATING GROUP ----->
					<cfif appSettings.getOperatingGroupOn()>
						<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />

						<cfset programLevel1Level 				= operatingGroupManager.getProgramLevel1Level() />
						<cfset programLevel1LevelLabel 			= operatingGroupManager.getLabel(programLevel1Level) />
						<cfset programLevel1Desc 				= operatingGroupManager.getProgramOperatingGroupDesc(level=programLevel1Level, programId=CSLGetContractInfo.Contract_Main_ID) />

						<cfset programLevel2Level 				= operatingGroupManager.getProgramLevel2Level() />
						<cfset programLevel2LevelLabel 			= operatingGroupManager.getLabel(programLevel2Level) />
						<cfset programLevel2Desc 				= operatingGroupManager.getProgramOperatingGroupDesc(level=programLevel2Level, programId=CSLGetContractInfo.Contract_Main_ID) />
							<tr>
									<td width="#col1Width#" style="#col1Style#">#programLevel1LevelLabel#</td>
									<td width="#col2Width#" style="#colMidStyle#">#programLevel1Desc#</td>
							</tr>
							<tr>
									<td width="#col1Width#" style="#col1Style#">#programLevel2LevelLabel#</td>
									<td width="#col2Width#" style="#colMidStyle#">#programLevel2Desc#</td>
							</tr>
					</cfif>
					<!--- D38942 :: Program Blackout Period on Frontend START --->
						<cfif CSLGetContractInfo.Auto_Volume EQ 1 AND CSLGetContractInfo.Blackout_Periods EQ 2>
							<tr>
								<td width="#col1Width#" style="#col1Style#">Weeks after start date to ignore for volume automation:</td>
								<td width="#col2Width#" style="#colMidStyle#">#CSLGetContractInfo.WeeksAfter# Weeks</td>
							</tr>
							<tr>
								<td width="#col1Width#" style="#col1Style#">Weeks before end date to ignore for volume automation</td>
								<td width="#col2Width#" style="#colMidStyle#">#CSLGetContractInfo.WeeksBefore# Weeks</td>
							</tr>
						</cfif>
					<!--- D38942 :: Program Blackout Period on Frontend END --->
				</TABLE>
		</td>
</tr>
    <cfif GetSettings.Auto_Renew_Option GTE 1>
	<tr>
		<td colspan="2">
			<font style="#col1Style#"> Auto Renew </font>
			<font style="#colMidStyle#">
				<cfif CSLGetContractInfo.Auto_Renew EQ 1 >
					#objSearchProgram.getProgramAutoRenewInfo(Program_ID = CSLGetContractInfo.Contract_Main_ID)#
				<cfelse>
					Turned Off
				</cfif>
			</font>
		</td>
	</tr>
    </cfif>

</table>
</td>
</tr>

	<!---BJF: Add link to bid history popup --->

	<cfif CSLGetContractInfo.Generic_Type eq "Bid Request">
	<cfsilent>
	<cfparam name="form.Program_ID" default="" />
	<cfparam name="form.product_list" default="" />
	<cfparam name="form.operatorList" default="" />
	<cfparam name="form.init" default="0" />

	<!---initialize the OperatorManager--->
	<cfset OperatorManager = CreateObject("component", "components.programs.operators.OperatorManager") />
	<cfset operatorIds = OperatorManager.getProgramOperatorIds(cryp.value) />
	<cfset form.operatorList = operatorIds.getLOperatorIds() />


	<!---initialize the BidRequestProductManager--->
	<cfset bidRequest = bidRequestProdMan.getBidRequestProductsFromDb(cryp.value) />

	<!---set the bid request products list for form.product_list--->
	<cfset form.Product_List = bidRequest.getLBidRequestProductIds() />

	</cfsilent>

	<cfif ListLen(form.operatorList) gt 0 and ListLen(form.operatorList) lte 10>

	<FORM ACTION="" METHOD="post" NAME="dataForm" ID="dataForm">
		<input type="hidden" name="Program_ID" value="#CSLGetContractInfo.Contract_Main_ID#">
		<input type="hidden" name="operatorList" value="#form.operatorList#">
		<input type="hidden" name="Product_List" value="#form.Product_List#">
		<input type="hidden" name="init" value="0">
	</FORM>

		<tr>
			<td colspan="3">
				<p>&nbsp; </p>
				<B>
				<FONT COLOR="FF0000">[</font>
				<a href="javascript:NewWindow('bid_request/bid_request_history.cfm?Program_ID=#CSLGetContractInfo.Contract_Main_ID#','name','850','600','Yes', 'No')">
					 proposal history
				</a>
				<FONT COLOR="FF0000">]</font>
				</B>
			</td>
		</tr>
		</cfif>
	</cfif>
	</cfif>
	</cfoutput>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif url.EZTemplate EQ 0>
	<Cfif GetSettings.Payable_To IS 1>

	<CFIF getContract_Main_Aux_Data.Pay_To_Distributor NEQ 1>
	<cfif len(trim(getContract_Main_Aux_Data.Payable_Company)) GT 0 OR len(trim(getContract_Main_Aux_Data.Payable_Attention)) GT 0 OR len(trim(getContract_Main_Aux_Data.Payable_Address_1)) GT 0>

		<CFOUTPUT>
			<TR>
				<TD >
					<table BORDER="0" CELLPADDING="0" CELLSPACING="0" CLASS="TableSize2">
						<TR>
							<TD ID="cellLabel" nowrap width="110">
								<br>Payable To:
								<br>#repeatString("&nbsp; ",15)#
							</TD>
							<TD ID="dataStyle">
								<br>&nbsp;&nbsp;
								#getContract_Main_Aux_Data.Payable_Company#<br>
								&nbsp;&nbsp; Attention: #getContract_Main_Aux_Data.Payable_Attention#<br>
								&nbsp;&nbsp; #getContract_Main_Aux_Data.Payable_Address_1#<br>
								<cfif len(trim(getContract_Main_Aux_Data.Payable_Address_2)) GT 0>
									&nbsp;&nbsp; #getContract_Main_Aux_Data.Payable_Address_2#<br>
								</cfif>
								&nbsp;&nbsp; #getContract_Main_Aux_Data.Payable_City#, #getContract_Main_Aux_Data.Payable_State#
								&nbsp; &nbsp; #getContract_Main_Aux_Data.Payable_Zip#<Br><br>
								&nbsp;&nbsp;Comments: #getContract_Main_Aux_Data.Payable_Comments#
								<br><br>
							</TD>
						</TR>
					</table>
				</TD>
		</CFOUTPUT>

	</cfif>
	</CFIF>
	<cfelse>

	<Cfif GetSettings.Send_Payment_To IS 1>
		<tr>
	</cfif>

	</CFIF>

	<!----Send payment to--->

	<Cfif GetSettings.Send_Payment_To IS 1>
		<CFIF getContract_Main_Aux_Data.Send_To_Broker NEQ 1>
			<cfif len(trim(getContract_Main_Aux_Data.Send_Company)) GT 0 OR len(trim(getContract_Main_Aux_Data.Send_Attention)) GT 0 OR len(trim(getContract_Main_Aux_Data.Send_Address_1)) GT 0>
				<CFOUTPUT>
						<TD >
							<table BORDER="0" CELLPADDING="0" CELLSPACING="0" CLASS="TableSize2">
								<TR>
									<TD ID="cellLabel" nowrap width="110">
										<br>Send Payment To:
										<br>#repeatString("&nbsp; ",15)#
									</TD>
									<TD ID="dataStyle">
										<BR>&nbsp;&nbsp; #getContract_Main_Aux_Data.Send_Company#<br>
										&nbsp;&nbsp; Attention: #getContract_Main_Aux_Data.Send_Attention#<br>
										&nbsp;&nbsp; #getContract_Main_Aux_Data.Send_Address_1#<br>
										<cfif len(trim(getContract_Main_Aux_Data.Send_Address_2)) GT 0>
											&nbsp;&nbsp; #getContract_Main_Aux_Data.Send_Address_2#<br>
										</cfif>
										&nbsp;&nbsp; #getContract_Main_Aux_Data.Send_City#, #getContract_Main_Aux_Data.Send_State#
										&nbsp; &nbsp; #getContract_Main_Aux_Data.Send_Zip#
										<br><br>
									</TD>
								</TR>
							</table>
						</TD>
					</TR>
				</CFOUTPUT>
			</cfif>
		</CFIF>
	<cfelse>

	<Cfif GetSettings.Payable_To IS 1>
		</tr>
	</cfif>

	</CFIF>



<!--- BJF: Program level payee removed by label 14531 --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- operators																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---D27190 Added view/hide operators, reduced white space--->
<cfsetting enablecfoutputonly="true" >
	<cfif GetSettings.Specify_Operators EQ 1>
	<cfif getOperators.recordcount GT 0>
	<cfoutput><TR></cfoutput>
		<cfoutput><TD COLSPAN="2"></cfoutput>
		<cfoutput><BR><B><FONT SIZE="2" COLOR="Navy">Eligible <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput></font></B>
				<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "CPA">
						<a  href="####" id="oprPDF"
								name="oprPDF" title="Create an End User PDF"
								onClick="CreateCpaPDF();">
						<img src="/images/PDF_Icon.gif" align="middle" border="0" height="15" width="12"/></a>
				</cfif>
			<a href="##" id="toggleOperators" style="margin-left:5px;"></a><HR COLOR="Navy">
		</cfoutput>
			<cfsilent>
			<cfset LegacyIdOn = application.returned_customer_setting.operator_legacy_id_on>
			<cfif businessSegmentsOn eq 1 and isDefined("CSLGetContractInfo.BUSINESS_SEGMENT_ID")>
				<cfset OperatorBSFilter = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").get(CSLGetContractInfo.Business_Segment_Id) />
				<CFSET CSLGetContractInfo.BUSINESS_SEGMENT_ID = OperatorBSFilter.Operator_BS_Filter>
				<cfset LegacyIdOn =  OperatorBSFilter.LegacyIdOn>
			</cfif>
			</cfsilent>
			<cfoutput><TABLE id="eligibleOperators"  cellspacing="3" cellpadding="3" WIDTH="100%"></cfoutput>
				<CFIF getOperators.RECORDCOUNT GT 0>
					<CFLOOP QUERY="getOperators">
						<!--- D31561: Operator Groups Search START--->
						<cfif getOperators.IS_GROUP>
							<cfif  application.appSettingsGet.get_Setting('GPO_One_Page_Program_Creation') EQ 1>
								<cfset profile_id = "#getOperators.Operator_Group_ID_Int#&Is_Group=1&programId=#CSLGetContractInfo.Contract_Main_ID#">
							<cfelse>
								<cfset profile_id = "#getOperators.Operator_Group_ID#&Is_Group=1&programId=#CSLGetContractInfo.Contract_Main_ID#">
							</cfif>
							<cfset menuID = 13>
						<cfelse>
							<cfset profile_id = #getOperators.BSA_Operator_ID#>
							<cfset menuID = 5>
						</cfif>
						<!--- D31561: Operator Groups Search END--->
						<cfoutput><TD CLASS="dataStyle" WIDTH="33%" VALIGN="top" BGCOLOR="F2F2F2" <cfif NOT isDefined("URL.action_type")>STYLE="cursor: help;" ONMOUSEOVER="menuID=#menuID#;URLstring='';an_ID='#profile_id#';doNotRelocate=1;" ONMOUSEOUT="menuID=0;"</cfif>></cfoutput><!--- D31561: Operator Groups Search --->

						<cfoutput><span><FONT SIZE="1">#trim(getOperators.Operator_Name)#</cfoutput>
								<cfif ! appSettings.getShowBSAOperators() AND Legacy_ID NEQ "" AND (getOperators.IS_GROUP EQ 0 OR appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '0')>
									<cfoutput>(#trim(Legacy_ID)#)</cfoutput>
            					<cfelse>
            						<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '1' AND getOperators.IS_GROUP>
             							<cfoutput>(#trim(Operator_ID)#) [#Group_Level_Type# :: #Group_Level_Desc#]</cfoutput>
             						<cfelse>
             							<cfoutput>(#trim(Operator_ID)#)</cfoutput>
             						</cfif>
            					</cfif>
								<cfif trim(getOperators.Operator_Address) NEQ "">
							<cfoutput><br>#trim(getOperators.Operator_Address)#</cfoutput>
								</cfif>
								<CFIF OPERATOR_CITY NEQ "" AND OPERATOR_STATE NEQ "">
							<cfoutput><BR>#trim(getOperators.Operator_City)#, #getOperators.Operator_State# #getOperators.Operator_Zip#</cfoutput>
								</CFIF>
								<cfif len(trim(getOperators.Operator_Phone)) GT 0>
							<cfoutput><br>#trim(getOperators.Operator_Phone)#</cfoutput>
								</cfif>
						<cfoutput></font></span></TD></cfoutput>

						<CFIF getOperators.CURRENTROW MOD 3><CFELSE><cfoutput></TR><TR></cfoutput></CFIF>
					</CFLOOP>
				<CFELSE>
					<cfoutput><TD ALIGN="center"><B><FONT COLOR="Red">NONE SUPPLIED</font></B></TD></cfoutput>
				</CFIF>
			<cfoutput></TABLE></cfoutput>
		<cfoutput></TD></cfoutput>
	<cfoutput></TR></cfoutput>
	</cfif>
	</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Distributors/Vendors --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<!--- Dev Note: WR 78635 - When GetSettings.Allow_Vendor_Only EQ 1, we select vendors in the program. Note: We insert vendors into customer master table for client(s) who want "vendor" as a payee. --->
	<cfif GetSettings.Specify_Distributors EQ 1 OR GetSettings.Allow_Vendor_Only EQ 1>
		<cfset _Setting_Display_Distributor_ID = appSettings.get_Setting('Display_Distributor_ID') />
	<!---D56899 :: Added below IF condition so that we can pass an argument display both GROUP and INDIVIDUAL distributors  if template setting allow user to pick group and individual distributors. START--->
		<cfif CSLGetContractInfo.specify_distributor_groups AND CSLGetContractInfo.specify_individual_distributors>
			<cfset displayGroupANDIndividual = 1>
		<cfelse>
			<cfset displayGroupANDIndividual = 0>
		</cfif>
	<!---D56899 :: Added below IF condition so that we can pass an argument display both GROUP and INDIVIDUAL distributors  if template setting allow user to pick group and individual distributors. END--->
	<cfset DistGroupManager = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
	<cfset getDistributors = ViewProgramManager.getDistributors(CSLGetContractInfo.Contract_Main_ID, businessSegmentsOn, DistGroupManager.ProgramDistributorIsGroup(CSLGetContractInfo.Contract_Main_ID),displayGroupANDIndividual)>
	<cfset getDistributorExceptions = ViewProgramManager.getDistributorExceptions(CSLGetContractInfo.Contract_Main_ID)>

	<cfif getDistributors.recordcount GT 0>
	<cfoutput><TR></cfoutput>
		<cfoutput><TD COLSPAN="2"></cfoutput>
		<cfoutput><BR><B><FONT SIZE="2" COLOR="Navy">Eligible <cfif GetSettings.Allow_Vendor_Only EQ 1>#variables.VendorLabel#s<cfelse>#application.returned_customer_setting.distributor_label_plural#</cfif></font></B>&nbsp: Count = #getDistributors.recordcount# &nbsp; <a href="##" id="toggleDistributors" style="margin-left:5px;"></a>&nbsp;&nbsp;<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 and GetSettings.RFP_Process EQ 1>
			<cfscript>
			 		oRFP		= CreateObject("component", "mvc.Models.Program.RfpManager");
			        q = oRFP.getFreightDataQuery(CSLGetContractInfo.Contract_Main_ID);	
			</cfscript>
			<cfquery name="SetMatrix" dbtype = "query">
					Select * from q where fixed_component_type IN (8,9) 
			</cfquery>	<!--- --- AND won = 1  TODO:        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--->
			<cfif setMatrix.recordcount GT 0 && session.Get_Profile_Settings.RFP_Freight_FOB_Delivered_View_Create GT 0><a  href="####" id="rfpfreight" name="rfpfreight" title="Choose FOB or Delivered Pricing"onClick="CreateRFPFreight();">#application.util.string.linkFormat("FOB / Delivered")#</a></cfif>
		</cfif>
		<HR COLOR="Navy">
		<CFIF getDistributorExceptions.RECORDCOUNT GT 0><span id="distributorInclusionsHeading" style="font-size:11px;font-weight:bold;color:navy;">#application.returned_customer_setting.distributor_label_singular# Inclusions</span></cfif>
		</cfoutput>
			<cfoutput><TABLE id="eligibleDistributors" cellspacing="3" cellpadding="3" WIDTH="100%"></cfoutput>
				<CFIF getDistributors.RECORDCOUNT GT 0>
					<CFLOOP QUERY="getDistributors">

						<!---handle what gets passed to the distributor profile popup based on groups--->
						<cfif getDistributors.Is_Group eq 1>
							<cfset this.profileId = "#getDistributors.BSA_Foodservice_Customers_ID#&Distributor_Group_Level_ID=#getDistributors.Distributor_Group_Level_ID#&Is_Group=1&programId=#CSLGetContractInfo.Contract_Main_ID#" />
						<cfelse>
							<cfset this.profileId = getDistributors.BSA_Foodservice_Customers_ID />
						</cfif>

						<cfoutput><TD CLASS="dataStyle" WIDTH="33%" VALIGN="top" BGCOLOR="F2F2F2" <cfif NOT isDefined("URL.action_type")> STYLE="cursor: help;" ONMOUSEOVER="menuID=3;URLstring='';an_ID='#this.profileId#';doNotRelocate=1;" ONMOUSEOUT="menuID=0;" </cfif>></cfoutput>
							<cfoutput><span><FONT SIZE="1"></cfoutput>
								<!--- If fixed price freight is on --->
								<cfif (NOT variables.pgmThinDisplayIsAttachement) AND (ProgramFreightOn eq 1) AND (Get_Profile_Settings.Approve_Freight_Programs OR Get_Profile_Settings.Freight_View_Create NEQ 0) AND ProgramDistributorFreightCount eq 1 AND ProgramFreightComponentType neq 0>
								  <cfoutput><a href="##" onclick="NewWindow('/common_files/contracts/Contract_Fixed_Freight_details.cfm?ProgramID=#CSLGetContractInfo.Contract_Main_ID#&Distributor_ID=#URLEncodedFormat(getDistributors.BSA_Foodservice_Customers_ID)#','viewfreight','850','600','Yes', 'Yes');" style="color:000000"></cfoutput>
									<cfoutput>#trim(getDistributors.Name)#<cfif _Setting_Display_Distributor_ID eq '1' AND Len(Shr_Ship_To)>(#trim(Shr_Ship_To)#)<cfelseif (_Setting_Display_Distributor_ID eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND Len(Ship_To)>(#trim(Ship_To)#)</cfif></a></cfoutput>
								<CFELSEIF getsettings.Discount_Fixed_Prices_Freight EQ 1 >
									<cfoutput><a href="##" onclick="NewWindow('/common_files/contracts/Contract_Fixed_Customer_Rates.cfm?ProgramID=#CSLGetContractInfo.Contract_Main_ID#&Distributor_ID=#URLEncodedFormat(getDistributors.BSA_Foodservice_Customers_ID)#','viewfreight','850','600','Yes', 'Yes');" style="color:000000"></cfoutput>
									<cfoutput>#trim(getDistributors.Name)#<cfif _Setting_Display_Distributor_ID eq '1' AND Len(Shr_Ship_To)>(#trim(Shr_Ship_To)#)<cfelseif (_Setting_Display_Distributor_ID eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND Len(Ship_To)>(#trim(Ship_To)#)</cfif></a></cfoutput>
								<cfelse>
								  <cfoutput>#trim(getDistributors.Name)#<cfif _Setting_Display_Distributor_ID eq '1' AND Len(Shr_Ship_To)>(#trim(Shr_Ship_To)#)<cfelseif (_Setting_Display_Distributor_ID eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND Len(Ship_To)>(#trim(Ship_To)#)</cfif></cfoutput>
								</cfif>
								<cfif Distributor_Group_Level_ID EQ 1>
									<cfset distCount = DistGroupManager.getDistributorGroupDistributorCount(Distributor_Group_Level_ID, Distributor_Group_ID) />(#distCount# #application.returned_customer_setting.distributor_label_plural#)
								</cfif>
								<CFIF getDistributors.CITY NEQ "" AND getDistributors.STATE NEQ "">
									<cfoutput><BR>#trim(getDistributors.City)#, #getDistributors.State# #trim(getDistributors.zipcode)#</cfoutput>
								</CFIF>
								<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "CPA">
									<cfoutput>
										<a  href="####" id="custPDF"
												name="custPDF" title="Create a Distributor PDF"
												onClick="CreateCpaDistPDF('#getDistributors.BSA_Foodservice_Customers_ID#');">
										<img src="/images/PDF_Icon.gif" align="middle" border="0" height="15" width="12"/></a>
									</cfoutput>
								</cfif>
								<cfoutput></font></span></TD></cfoutput>
						<CFIF getDistributors.CURRENTROW MOD 3><CFELSE><cfoutput></TR><TR></cfoutput></CFIF>
					</CFLOOP>
				<CFELSE>
					<cfoutput><TD ALIGN="center"><B><FONT COLOR="Red">NONE SUPPLIED</font></B></TD></cfoutput>
				</CFIF>
			<cfoutput></TABLE></cfoutput>

			<!--- DISTRIBUTOR EXCEPTIONS --->
			<CFIF getDistributorExceptions.RECORDCOUNT GT 0>
			<cfoutput><BR>
			<span id="distributorExclusionsHeading" style="font-size:11px;font-weight:bold;color:navy;">#application.returned_customer_setting.distributor_label_singular# Exclusions</span>
			</cfoutput>

			<cfoutput><TABLE id="eligibleDistributorExceptions" cellspacing="3" cellpadding="3" WIDTH="100%"></cfoutput>

					<CFLOOP QUERY="getDistributorExceptions">
						<cfoutput><TD CLASS="dataStyle" WIDTH="33%"></cfoutput>
							<cfoutput><span><FONT SIZE="1"></cfoutput>
								<cfoutput>#trim(getDistributorExceptions.Name)#
									<cfif _Setting_Display_Distributor_ID eq '1' AND Len(getDistributorExceptions.Shr_Ship_To)>
										(#trim(getDistributorExceptions.Shr_Ship_To)#)
									<cfelseif (_Setting_Display_Distributor_ID eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND Len(getDistributorExceptions.Ship_To)>
										(#trim(getDistributorExceptions.Ship_To)#)
									</cfif>
								</cfoutput>
								<CFIF getDistributorExceptions.CITY NEQ "" AND getDistributorExceptions.STATE NEQ "">
									<cfoutput><BR>#trim(getDistributorExceptions.City)#, #getDistributorExceptions.State# #trim(getDistributorExceptions.zipcode)#</cfoutput>
								</CFIF>
								<cfoutput></font></span></TD></cfoutput>
						<CFIF getDistributorExceptions.CURRENTROW MOD 3><CFELSE><cfoutput></TR><TR></cfoutput></CFIF>
					</CFLOOP>
			<cfoutput></TABLE></cfoutput>
			</CFIF>
		<cfoutput></TD></cfoutput>
	<cfoutput></TR></cfoutput>
	</cfif>
	</CFIF>

	<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "CPA">
		<cfoutput><SCRIPT>
			function CreateCpaPDF()
			{
				NewWindow('/Common_Files/contracts/OPP/create_pdf_caller.cfm?Contract_Main_ID=#CSLGetContractInfo.Contract_Main_ID#&type=2','cpaOutput','800','600','Yes', 'Yes');
				return false;
			}
			function CreateCpaDistPDF(id)
			{
				NewWindow('/Common_Files/contracts/OPP/create_pdf_caller.cfm?Contract_Main_ID=#CSLGetContractInfo.Contract_Main_ID#&type=1&custId='+id,'cpaOutput','800','600','Yes', 'Yes');
				return false;
			}
		</SCRIPT></cfoutput>
	</cfif>
	<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 and GetSettings.RFP_Process EQ 1>
		<CF_CRYP type="en" string="#CSLGetContractInfo.Contract_Main_ID#" key="#request.key#">
		<cfoutput><SCRIPT>
			function CreateRFPFreight()
			{
				NewWindow('/Common_Files/contracts/OPP/RFP_Freight_Form.cfm?CID=#cryp.value#&x=1','cpaOutput','1400','800','Yes', 'Yes');
				return false;
			}
		</SCRIPT></cfoutput>
	</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Brokers																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


	<cfif GetSettings.Specify_Brokers EQ 1>

	<!--- Dev Note: Clay 9116: Remove Auto_Brokers from the display_view_program_html.cfm; new argument and sql criteria --->
	<cfset getMarketsMaster  = ViewProgramManager.getMarkets(CSLGetContractInfo.Contract_Main_ID,appsettings.getRemoveBrokerSelection())>
	<cfset request.getMarketsMaster = getMarketsMaster>
	<cfset getBrokerNames  = ViewProgramManager.getBrokerNames("request.getMarketsMaster")>

	<cfif getMarketsMaster.recordcount GT 0>
	<cfoutput><TR></cfoutput>
		<cfoutput><TD COLSPAN="2"></cfoutput>
				<cfoutput><BR></cfoutput>
				<cfoutput><B><FONT SIZE="2" COLOR="Navy">Eligible Brokers</FONT></B><a href="##" id="toggleBrokers" style="margin-left:5px;"></a><HR COLOR="Navy"></cfoutput>
						<cfoutput><TABLE id="eligibleBrokers" cellspacing="3" cellpadding="3" WIDTH="100%"></cfoutput>
							<CFLOOP QUERY="getBrokerNames">

								<!--- <cfset this.profileId = "#brokerList#&IS_Group=1" /> --->
								<cfoutput><TD CLASS="dataStyle" nowrap WIDTH="33%" VALIGN="top"	BGCOLOR="F2F2F2" <cfif NOT isDefined("URL.action_type")> STYLE="cursor: help;" ONMOUSEOVER="menuID=4;URLstring='';an_ID='#URLEncodedFormat(getBrokerNames.Broker_Name)#&Contract_Main_ID=#CSLGetContractInfo.Contract_Main_ID#&Is_Group=1';doNotRelocate=1;" ONMOUSEOUT="menuID=0;"</cfif>></cfoutput>
									<cfoutput><span><FONT SIZE="1">#trim(getBrokerNames.Broker_Name)#</span></cfoutput>
								<cfoutput></TD></cfoutput>
								<CFIF getBrokerNames.CURRENTROW MOD 3><CFELSE><cfoutput></TR><TR></cfoutput></CFIF>
							</CFLOOP>
						<cfoutput></TABLE></cfoutput>
					<cfoutput></font></cfoutput>
		<cfoutput></TD></cfoutput>
	<cfoutput></TR></cfoutput>
	</cfif>
	</CFIF>
<cfsetting enablecfoutputonly="false" >

</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- PAYEE DETAILS																					 --->
<!--- Although the query result may return more resultset we display only top one record for the
	  Payee Detail  																			 	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif variables.bHideFromLSAutoPay eq 1>
	<cfquery name="getPayeeDetails" datasource="#application.datasource#">
		SELECT 	Vendor_Name, Vendor_ID, Address_1, City, State, Zipcode
		FROM   	Program_Lump_Sums INNER JOIN Vendor_Master
		ON      Program_Lump_Sums.Vendor_Master_Id = Vendor_Master.Vendor_Master_Id
		WHERE 	Program_Lump_Sums.Program_ID = #CSLGetContractInfo.Contract_Main_ID#
		AND     Program_Lump_Sums.Deleted = 0
	</cfquery>

	<cfif getPayeeDetails.RecordCount GTE 1>
		<tr>
			<td colspan="2">
			<br><b><font size="2" color="Navy">Eligible Payee</font></b><hr color="Navy">
				<table cellspacing="3" cellpadding="3" width="100%">
					<tr>
						<td class="dataStyle" bgcolor="F2F2F2">
							<font size="1"><cfoutput>
								#Trim(getPayeeDetails.Vendor_Name)#
								<cfif getPayeeDetails.vendor_id NEQ "">
								(#getPayeeDetails.Vendor_ID#)</cfif>
								<cfif Trim(getpayeedetails.Address_1) NEQ "">
								<br>#getPayeeDetails.Address_1#
								</cfif>
								<cfif getPayeeDetails.city NEQ "" and getPayeeDetails.state NEQ "">
									<br>#getPayeeDetails.City#, #getPayeeDetails.State# #getPayeeDetails.zipcode#
								</cfif>
								</cfoutput>
							</font>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</cfif>
</cfif>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---TSF: Modification Bid Request--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Bid Request 																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif ListFind(discounttypes,"10",",")>

	<cfinclude template="display_view_program_bid_request.cfm">

</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Off-Invoice																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif ListFind(discounttypes,"8",",")>

	<cfinclude template="display_view_program_off-invoice.cfm">

</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "CPA">
		 <cfset request.noty_version = "3">
	<cf_include files=" /common_files/noty.cfm"> <!--- /common_files/tailwind-css.cfm, --->
	<cfset jQuery.version ="1.12.4">
	<cfset jQueryUI.widgets = "tooltip,datepicker">
	<cfset jQueryUI.widgets = "all">
	<cfset jQueryUI.version = "1.11">
    <cfset request.ag_grid_theme = "ba-ag-theme-balham">

    <cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
                                       "/common_Files/ag-Grid.cfm",
                                       "/styles/css-loader.css",
                                       "/styles/font-awesome.min.css"
                                        ] )#>
                                        <!--- "/common_files/contracts/GPO_One_Page/opp_grids.cfm" --->
    <script src="/script/javascript/jQueryUI_1_11/datepicker.js"></script>
	<cf_include files="/script/javascript/jQueryUI_1_11/jquery-ui.css">
 <style>
        <!--- override the ag-grid styles included above --->
		.ag-theme-balham {
			font-size: 11px;
		}
		.ag-header {
			font-size: 11px !important;
		}
		.ag-theme-balham .ag-cell {
			/* padding-left: 4px; */
			padding-right: 2px;
        }
        .ag-theme-balham .ag-header-cell-label {
			width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
		}
        .ag-theme-balham .ag-header-cell {
            padding-left: 6px;  /* get checkbox to line up */
        }
  		.ag-theme-balham .ag-row-selected {
    		border-bottom-color: #b5b5b5; /* don't hide lines when selected */
		}
		.ag-theme-balham .ag-selection-checkbox span {
		    left: 2px; /* center the checkbox */
    	}
    	.number-cell {
	        text-align: right;
	    }
    </style>
	<cfset variables.ContractMainId = CSLGetContractInfo.Contract_Main_Id >
	<cfset oppViewOnly = 1>
	<TABLE CLASS="Maintable" WIDTH="1000" CELLPADDING="3" CELLSPACING="0" border="0">
		<TR WIDTH="100%">
			<TD WIDTH="100%" colspan="100%">
			<div class="flex-1 bg-white mx-1 text-sm text-black" WIDTH="100%">
				<section name="section_CPA_Products" class="mr-1" WIDTH="100%">
					<CFINCLUDE template="/Common_Files/contracts/OPP/CPA_Products_Form.cfm" />
				</section>
			</div>
			</TD>
		</TR>
	</TABLE>
<cfelse>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- FIXED PRICING																					 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!---  NO LONGER USE display_view_program_fixed_pricing_with_freight.cfm VIA SETTING Discount_Fixed_Prices_Freight
		SHOW CUST RATES IN A POP-UP
		<cfif getsettings.Discount_Fixed_Prices_Freight neq 1> --->
		<cfif ListFind(discounttypes,"1",",")>

		<cfinclude template="display_view_program_fixed_pricing.cfm">

	</cfif>
<!--- </cfif> --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- FIXED PRICING	with Freight																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <cfif getsettings.Discount_Fixed_Prices_Freight EQ 1>
	<cfif ListFind(discounttypes,"1",",")>

		<cfinclude template="display_view_program_fixed_pricing_with_freight.cfm">

	</cfif>
</cfif> --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- REBATES																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif ListFind(discounttypes,"2",",")>

		<cfinclude template="display_view_program_rebates.cfm">

	</cfif>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</cfif>  <!---  IF GPO_One_Page_Program_Creation --->

		<cfinclude template="display_view_program_lump_sum.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- GROWTH																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif ListFind(discounttypes,"4",",")>
	<cfif (appSettings.get_Setting('Growth_Consolidated_View') EQ '1')>
		<cfinclude template="display_view_program_growth_Tiered.cfm">
	<cfelse>
		<cfinclude template="display_view_program_growth.cfm">
	</cfif>

</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Formula Pricing																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif ListFind(discounttypes,"5",",")>

		<cfinclude template="display_view_program_formula_pricing.cfm">

</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Bid Rules																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif ListFind(discounttypes,"9",",")>

		<cfinclude template="display_view_program_bid_rules.cfm">

</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Documents																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfif isdefined("request.AccessStructure.name_first")>
<CFINCLUDE TEMPLATE="/Common_Files/Documents/User_Positions_Under_this_User.cfm">

<CFSET Access_Position_List = GP_Position_List_From_My_Position_Down>
<CFOUTPUT>
<!---
	Dev Notes: D23320/Anand Rao/17-May-10
	  User profile setting to view private documents
--->
<cfset Att_display  = ViewProgramManager.Att_display(CSLGetContractInfo.Contract_Main_ID,Access_Position_List,request.AccessStructure.User_ID,Get_Profile_Settings.View_Private_Documents,request.AccessStructure.Profiles_ID)>

</CFOUTPUT>
<CFIF Att_display.recordcount GT 0 AND URL.CatalogView EQ 0>
	<cfinclude template="/Common_Files/Documents/Document_Include.cfm" />
	<!-----
	please don't remove the following comment,
	attachmentstart (and it only needs 2 dashs like html comment, it is purposely done)
	it is used in a regular expression
	to remove the attachment area from the email and fax.
	If any questions, please contact Deepa first before editing :)
	--------------->
	<!--attachmentstart-->
		<TR>
			<TD COLSPAN="2">
				<BR>
				<B><FONT SIZE="2" COLOR="Navy">Attached Documents</font></B><HR COLOR="Navy">
				<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
					<!--- TABLE HEADERS --->
					<TR BGCOLOR="#FFCE84" VALIGN="bottom">
						<TD ID="header"><FONT SIZE="1"><B>DATE<br>NAME</B></font></TD>
						<TD ID="header" ><FONT SIZE="1"><B>FILE</B></font></TD>
						<TD ID="header" ><FONT SIZE="1"><B>TITLE<br>DESCRIPTION</B></font></TD>
					</TR>
					<CFOUTPUT QUERY="Att_display">
						<!--- DATA OUTPUT --->
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
						<cfset User_Name  = ViewProgramManager.User_Name(Uploaded_By)>
							<CFSET SIZEinMB = #Doc_size#/1024>
							<TD ID="" WIDTH="16%">#DateFormat(Uploaded_Date,"mm/dd/yyyy")#<BR>#User_Name.Name_First# #User_Name.Name_Last#&nbsp;</TD>
							<TD nowrap ID="" TITLE="File Name: #Doc_File_Name#"><A href="javascript: confirmation('#ReReplace(ReReplace(Doc_Uni_Name,"##","&##35;","ALL"),"'","\'","ALL")#');" TITLE="Click here to view '#Doc_File_Name#'">
									<CFSET Display_Name=Left(Doc_File_Name,20)>
									<CFIF len(trim(Doc_File_Name)) GT 20>
										#LCASE(Display_Name)#...
									<CFELSEIF len(trim(Doc_File_Name)) EQ 0>
										&nbsp;
									<CFELSE>
										#LCASE(Display_Name)#
									</CFIF>
									</A><BR>#NumberFormat(SIZEinMB,"_.____")# KB&nbsp;</TD>

							<TD ID="" WIDTH="58%"><FONT color="red"><b>#Doc_Title#</b></font><br>Description: #Doc_Description#&nbsp;</TD>
						</TR>
					</CFOUTPUT>
				</TABLE>
			</TD>
		</TR>
	<!--attachmentend-->
	<!-----
	please don't remove the above comment,
	attachmentend (and it only needs 2 dashs like html comment, it is purposely done)
	it is used in a regular expression
	to remove the attachment area from the email and fax
	If any questions, please contact Deepa first before editing :)
	--------------->
	</CFIF>	</cfif>
	<!---TSF: Label D6588 --->
<!---
	<cfoutput>
		<TR>
			<TD COLSPAN="2">
				<cfsilent>
					<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
					<CFSET Program_Volume.Load_Basic_Information(CSLGetContractInfo.Contract_Main_ID, request.AccessStructure.Company_Main_ID)>
				</cfsilent>
				<cfif Program_Volume.isVolumeApplied() >
					<CFSET Program_Volume.View_Program_Product_List()>
				</cfif>
				<!-------------------- display volume information ---------------------->
			</TD>
		</TR>
	</cfoutput>
 --->
	<!------ Start Clause Code ----->
	<cfset getProgramClause = clauseProgramManager.getProgramClause(CSLGetContractInfo.Contract_Main_ID, 1)>
	<cfif getProgramClause.recordCount>
	<cfoutput><TR>
		<TD COLSPAN="2">
		<BR><BR><BR>
		<B><FONT SIZE="2" COLOR="Navy">General Terms</font></B><HR COLOR="Navy">
		<cfinclude template="/Clause_Library/clause_program_display.cfm">
		</TD>
	</TR></cfoutput>
	</cfif>
	<!------ End  Clause Code ----->
<!--- DAA: D14842
<cfif url.EZTemplate EQ 0>
	<cfif application.returned_customer_setting.confidentiality_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.confidentiality_switch EQ 1>
	<cfoutput>
	<TR>
		<TD COLSPAN="2">
			<br>
			<hr>
			<DIV STYLE="font-size: 12px;"><cfoutput>#application.returned_customer_setting.confidentiality_content#</cfoutput>
				<hr>
			</DIV>
		</TD>
	</TR>
	</cfoutput>
	</cfif></cfif>
</cfif>
--->
 <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</table>

<!---Signing area to signify customer acceptance--->
<cfif GetSettings.Customer_Acceptance IS 1>
<cfoutput>
	<table width="700" cellpadding="1" cellspacing="1" border="0" >
	<tr height="30">
	  <td width="12%" height="25" align="right" valign="bottom" nowrap>NAME</td>
	  <td STYLE="border-bottom:solid black 1px;">&nbsp;</td>
	  <td width="23%" align="right" valign="bottom" nowrap>NAME</td>
	  <td STYLE="border-bottom:solid black 1px;">&nbsp;</td>
	  </tr>
	<tr height="30">
	  <td nowrap valign="bottom" align="right">TITLE</td>
	  <td STYLE="border-bottom:solid black 1px;">&nbsp;</td>
	  <td nowrap valign="bottom" align="right">TITLE</td>
	  <td STYLE="border-bottom:solid black 1px;">&nbsp;</td>
	  </tr>
	<tr height="30">
		<td nowrap valign="bottom" align="right">SIGNATURE:</td><td width="33%" STYLE="border-bottom:solid black 1px;">&nbsp; </td>
		<td nowrap valign="bottom" align="right">&nbsp; &nbsp; &nbsp; SIGNATURE: </td><td width="32%" STYLE="border-bottom:solid black 1px;">&nbsp; </td>
	</tr>
	<tr height="30">
		<td nowrap valign="bottom" align="right">DATE: </td><td width="33%" STYLE="border-bottom:solid black 1px;">&nbsp; </td>
		<td nowrap valign="bottom" align="right">&nbsp; &nbsp; &nbsp; DATE: </td><td width="32%" STYLE="border-bottom:solid black 1px;">&nbsp; </td>
	</tr>
  </table>
</cfoutput>

</cfif>


<SCRIPT>
	function showRateCalculation(CID,CPID,PPID){
		//window.open()
		NewWindow('/Common_Files/Contracts/Formula_Price_Display.cfm?CID=' + CID + '&CPID=' + CPID + '&PPID=' + PPID,'tradeAnalysis','800','400','Yes', 'Yes')
	}


</SCRIPT>

</cfsavecontent>


<cfif url.doNotCacheThisView eq 0><!--- if the view is not complete (eg:catalog summary) we do not want to cache it ---->

	<cflock timeout="10" type="exclusive">
		<cffile action="write" file="#Application.Doc_Path#\Temp_Files\Program\#sProgramViewCacheFileName#" output="#content#">
	</cflock>

</cfif>

<cfif application.appsettingsget.label_sets>
	<!--- USE LABEL SET TO CHANGE WORDS IF THIS TEMPLATE HAS A DEFAULT LABEL SET SELECTED --->
	<!---
	<cfif GetSettings.Label_Set_Default NEQ "">
		<cfset labelComp = CreateObject("component", "components.settings.labels.labels").init() />
		<cfset labelset = labelComp.GetProgramLabels(GetSettings.Label_Set_Default,true) />
		<cfset content = labelComp.replaceWords(content,labelset) />
	</cfif>
	--->
</cfif>


<!--- ACTUAL OUTPUT DISPLAY TO THE CLIENT --->
<cfoutput>#content#</cfoutput>

<cfelse>

	<cfinclude template="#Application.Doc_Mapping#/Temp_Files/Program/#sProgramViewCacheFileName#" />

</cfif>
