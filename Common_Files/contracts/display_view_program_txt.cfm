<cfsilent>
	<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />
	<cfset displayGroupTypeDesc = genSettingsManager.settings.getViewProgramProductGroupTypeDesc() />

	<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
	<CFSET Program_Volume.Load_Basic_Information(CSLGetContractInfo.Contract_Main_ID, request.AccessStructure.Company_Main_ID)>			
<CFSET Program_Volume.Get_Product_List(0, 1)>
<cfif NOT Program_Volume.defaultUOT.getMultiplier()>
	<cfset Program_Volume.defaultUOT.setMultiplier(Program_Volume.Contract_Span) />
</cfif></cfsilent>
<cfoutput>#application.returned_customer_setting.company_name##NewLine#</cfoutput>
<cfoutput>#getprogramstatus.getStatusDesc(CSLGetContractInfo.Contract_Status_Type_IDX)#: Blacksmith Program ID - #CSLGetContractInfo.Contract_Number##NewLine##NewLine#</cfoutput>
		<!--- is trade eligible --->
		<cfif GetSettings.Include_Trade EQ 0>
		<cfif len(trim(GetSettings.Trade_Blurb)) GT 0><cfoutput>#GetSettings.Trade_Blurb##NewLine##NewLine#</cfoutput><cfelse><cfoutput>* Volumes from this program are not eligible for any other trade or promotional allowances#NewLine##NewLine#</cfoutput></cfif>
		</cfif>
<cfoutput>Title: #CSLGetContractInfo.Contract_Title##NewLine#
</cfoutput>
<cfoutput>Period: #MonthAsString(datepart('m', CSLGetContractInfo.Contract_Start_Date))# #datepart('d', CSLGetContractInfo.Contract_Start_Date)#, #datepart('yyyy', CSLGetContractInfo.Contract_Start_Date)# to #MonthAsString(datepart('m', CSLGetContractInfo.Contract_End_Date))# #datepart('d', CSLGetContractInfo.Contract_End_Date)#, #datepart('yyyy', CSLGetContractInfo.Contract_End_Date)# #NewLine##NewLine#</cfoutput>
<cfif GetSettings.Specify_Operators EQ 1>
		<cfset getOperators = ViewProgramManager.getOperators(CSLGetContractInfo.Contract_Main_ID)>
			<CFIF getOperators.RecordCount EQ 1>
				<cfoutput>-#application.returned_customer_setting.operator_label_singular#: #getOperators.Operator_Name##NewLine#</cfoutput>
			<CFELSEIF getOperators.RecordCount GT 1>
				<cfoutput>- Multiple #application.returned_customer_setting.operator_label_plural#</cfoutput>
			</CFIF>			<cfoutput>#NewLine##NewLine#</cfoutput>
		</cfif>
<!---display business segments if it's turned on--->
	<cfif businessSegmentsOn eq 1>
	<cfoutput>#appSettings.getbusiness_segment_label()#: #qGetThisBusSegment.Business_Unit_Desc# #NewLine##NewLine#</cfoutput>
	</cfif>
	<cfif appSettings.getSalesOrgOn()>
	<cfoutput>#appSettings.getlob_label()#: #Line_Of_Business_Name##NewLine##NewLine#</cfoutput>
	</cfif>
	<cfoutput>Program Type: #CSLGetContractInfo.Created_Type##NewLine##NewLine#</cfoutput>
		<!---Only display if there are discount identifiers--->
	<cfif getGeneralSettings.Use_Discount_ID IS 1 AND len(trim(GetSettings.Discount_Identifier_ID)) GT 0>
	<cfset GetDiscountIdentifier =  ViewProgramManager.GetDiscountIdentifier(GetSettings.Discount_Identifier_ID)>
	<cfoutput>Discount Identifier:(#GetDiscountIdentifier.Discount_Identifier_Number#)&nbsp;&nbsp;#GetDiscountIdentifier.Discount_Identifier_Desc##NewLine##NewLine#</cfoutput>
	</cfif>
	
	<cfoutput>#application.returned_customer_setting.reference_number_label#: #CSLGetContractInfo.Contract_Reference_Number##NewLine##NewLine#</cfoutput>

<!----Display legacy id if it's on--->
 <!--- Dev Note: Milan 9360 --->
<cfif appSettings.getView_Legacy_ID() EQ 1>
	<cfset labelComp = CreateObject("component", "components.settings.labels.labels").init() />
	<cfset legacyIDLabel 	= labelComp.GetGeneralLabels('Legacy ID').General_Labels_Label />
	<cfoutput>#legacyIDLabel#:#CSLGetContractInfo.LEGACY_DEAL_ID##NewLine##NewLine#</cfoutput>
</cfif>

<!----Display bid id if it's on--->
	<cfif application.returned_customer_setting.display_bid_id>
	<cfoutput>Bid ID: #CSLGetContractInfo.BID_NUMBER##NewLine##NewLine#</cfoutput>
	</cfif>
<!--- Payment Cycles Look Up --->
<cfif NOT appSettings.getPaymentCycleAtDiscountType()>
<cfset getPaymentCycles =  ViewProgramManager.getPaymentCycles(CSLGetContractInfo.PaymentCycle)>	
<cfoutput>Payment Cycle: #getPaymentCycles.Payment_Cycle##NewLine##NewLine#</cfoutput>
</cfif>

<cfoutput><!--- Program Qty --->#application.returned_customer_setting.Program_Quantity_Label# : #trim(numberformat(CSLGetContractInfo.Contract_Quantity,'___,___,___,___,___,___'))# #getContractUOMLabel.Unit_Of_Measure_Desc##NewLine##NewLine#</cfoutput>

		<!---Get payment type--->
	<cfquery name="PaymentTypeforProgram" datasource="#application.datasource#">
	SELECT Payment_Type.Payment_Type_Name
	FROM Payment_Type
	WHERE Payment_Type.Payment_Type_ID = '#CSLGetContractInfo.ClaimMechanics#'
	</cfquery>
	<cfoutput><cfif PaymentTypeforProgram.Recordcount IS 1>#trim(PaymentTypeforProgram.Payment_Type_Name)#</cfif>
	#NewLine#</cfoutput>
	
	<cfif GetSettings.Billback_Date IS 1 AND GetSettings.Billback_Date_Span GT 1>
	<cfset PaymentRequestDue = dateadd("d", GetSettings.Billback_Date_Span, CSLGetContractInfo.Contract_End_Date)>
	<cfoutput>Last Date to Claim: #dateformat(PaymentRequestDue, 'mmmm dd, yyyyy')# ( #GetSettings.Billback_Date_Span# days after expiration )#NewLine##NewLine#</cfoutput>
	</cfif>
	
	<!---Equipment Placement--->
	<cfif getContract_Main_Aux_Data.Equipment_Placement IS 1>
	<cfoutput>Equipment Placement: Yes#NewLine##NewLine#
	Equipment Placement Note:
	<cfif CSLGetContractInfo.Equipment_Placement_Note neq "">#CSLGetContractInfo.Equipment_Placement_Note#</cfif>#NewLine##NewLine#
	</cfoutput>
	</cfif> 
	
	<cfoutput>Owner Position: </cfoutput>
		<cfset qPosition = CreateObject("component", "components.geography.position").getPosition(CSLGetContractInfo.Creating_User_Position_ID) />
		<cfif qPosition.recordCount><cfoutput>#qPosition.Position_Label#</cfoutput></cfif>
		<cfoutput>#NewLine##NewLine#</cfoutput>
		
	<cfif application.returned_customer_setting.Responsible_Person EQ 1>
	<cfoutput>Responsible Sales Person: </cfoutput>
		<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(CSLGetContractInfo.Responsible_User_ID) />
		<cfif qUser.recordCount><cfoutput>#qUser.User_Full_Name#</cfoutput></cfif>
		<cfoutput>#NewLine##NewLine#</cfoutput>
	</cfif>
	
	<cfif isDefined("CSLGETCONTRACTINFO.Approval_Date")>
	<cfif len(trim(CSLGETCONTRACTINFO.Approval_Date)) GT 0>
	<cfoutput>Approved On:
	#dateformat(CSLGETCONTRACTINFO.Approval_Date, 'MM/DD/YYYY')# #NewLine##NewLine#</cfoutput>
	</cfif>
	</cfif>
	
	<cfif isDefined("CSLGETCONTRACTINFO.Approved_By_User_ID")>
	<cfif len(trim(CSLGETCONTRACTINFO.Approved_By_User_ID)) GT 0>
	<cfquery name="ApprovedUser" datasource="#application.datasource#">
			SELECT Name_First, Name_Last
			FROM _Users
			WHERE User_ID = '#CSLGetContractInfo.Approved_By_User_ID#'
	</cfquery>
	<cfoutput>Approved By: #ApprovedUser.Name_First# #ApprovedUser.Name_Last# #NewLine##NewLine###</cfoutput>
	</cfif>
	</cfif>
	
	
	<!---TSF: MODIFICATION Bid Request--->
	<!---FILTER: if the template/program type is Bid Request, then get,set and display for Bid Request--->
	<!---************************************ BID REQUEST ************************************************--->
	 <cfif CSLGetContractInfo.Generic_Type eq "Bid Request"> 
		<!---get bid request--->
		<cfset bidReqObj = CreateObject("component", "components.programs.bid_request.BidRequestManager").getBidRequest(CSLGetContractInfo.Contract_Main_ID) />
		<cfoutput>Open Date: #DateFormat(bidReqObj.getOpenDate(),"mm/dd/yyyy")##NewLine#</cfoutput>
		
		<cfoutput>Date Needed: #DateFormat(bidReqObj.getDateNeeded(),"mm/dd/yyyy")##NewLine#</cfoutput>

			<cfoutput>Expected Reply Dat: #DateFormat(bidReqObj.getExpectedReplyDate(),"mm/dd/yyyy")##NewLine#</cfoutput>
		
		<cfoutput>Line Item: </cfoutput><cfif bidReqObj.getLineItem()><cfoutput>Yes</cfoutput><cfelse><cfoutput>No</cfoutput></cfif><cfoutput>#NewLine#</cfoutput>

<cfoutput>Bid Request Status: #bidReqObj.getStatusDesc()#<cfif trim(bidReqObj.getStatusDesc()) eq "Pending">...</cfif>#NewLine#</cfoutput>
</cfif>
		<!---FILTER: If there aren't any notes then say so--->
		<cfoutput>Notes:</cfoutput>
		<cfif Len(trim(CSLGetContractInfo.Notes))><cfoutput>#CSLGetContractInfo.Notes#</cfoutput><cfelse><cfoutput>(None)</cfoutput></cfif><cfoutput>#NewLine#</cfoutput>
		
	<cfset GetPerfRequirements =  ViewProgramManager.GetPerfRequirements(CSL_Contract_Main_ID)>
	<cfif GetPerfRequirements.Recordcount GT 0>
<cfoutput>Performance Requirements: </cfoutput>
			<cfloop query="GetPerfRequirements">
			<cfoutput>#Requirement_Name#</cfoutput>
			</cfloop>
	<cfoutput>#NewLine##NewLine#</cfoutput>
	</cfif>
	
	<Cfif GetSettings.Payable_To IS 1>
	<CFIF getContract_Main_Aux_Data.Pay_To_Distributor NEQ 1>
	<cfif len(trim(getContract_Main_Aux_Data.Payable_Company)) GT 0 OR len(trim(getContract_Main_Aux_Data.Payable_Attention)) GT 0 OR len(trim(getContract_Main_Aux_Data.Payable_Address_1)) GT 0>
	<cfoutput>Payable To:#getContract_Main_Aux_Data.Payable_Company##NewLine#Attention:  #getContract_Main_Aux_Data.Payable_Attention##NewLine# #getContract_Main_Aux_Data.Payable_Address_1#
			<cfif len(trim(getContract_Main_Aux_Data.Payable_Address_2)) GT 0> #getContract_Main_Aux_Data.Payable_Address_2#</cfif>#NewLine#
		  #getContract_Main_Aux_Data.Payable_City#, #getContract_Main_Aux_Data.Payable_State#  #getContract_Main_Aux_Data.Payable_Zip#
			#NewLine#Comments: #getContract_Main_Aux_Data.Payable_Comments##NewLine##NewLine#</cfoutput>
	</cfif>
	</CFIF>
	</CFIF>
	
	<!----Send payment to--->
		
	<Cfif GetSettings.Send_Payment_To IS 1>
		
	<CFIF getContract_Main_Aux_Data.Send_To_Broker NEQ 1>
	<cfif len(trim(getContract_Main_Aux_Data.Send_Company)) GT 0 OR len(trim(getContract_Main_Aux_Data.Send_Attention)) GT 0 OR len(trim(getContract_Main_Aux_Data.Send_Address_1)) GT 0>
	
	<cfoutput>Payable To: #getContract_Main_Aux_Data.Send_Company##NewLine#
	Attention:  #getContract_Main_Aux_Data.Send_Attention##NewLine#
	#getContract_Main_Aux_Data.Send_Address_1#<cfif len(trim(getContract_Main_Aux_Data.Send_Address_2)) GT 0> #getContract_Main_Aux_Data.Send_Address_2#</cfif>
		  #NewLine##getContract_Main_Aux_Data.Send_City#, #getContract_Main_Aux_Data.Send_State#  #getContract_Main_Aux_Data.Send_Zip##NewLine#</cfoutput>
	</cfif>
	</CFIF>
	</CFIF>
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- operators																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
	
	<cfif GetSettings.Specify_Operators EQ 1>
	<cfif getOperators.recordcount GT 0>
	<cfoutput>#NewLine#Eligible #application.returned_customer_setting.operator_label_plural#: #NewLine#</cfoutput>
			<CFIF getOperators.RECORDCOUNT GT 0>
					<CFLOOP QUERY="getOperators">
						<cfoutput>#ucase(trim(getOperators.Operator_Name))#<cfif getOperators.Operator_ID NEQ "">(#trim(getOperators.Operator_ID)#)</cfif> </cfoutput>
											<cfif trim(getOperators.Operator_Address) NEQ ""><cfoutput>#ucase(getOperators.Operator_Address)#</cfoutput></cfif>
											<CFIF OPERATOR_CITY NEQ "" AND OPERATOR_STATE NEQ "">
												<cfoutput>#ucase(getOperators.Operator_City)#, #ucase(getOperators.Operator_State)# #getOperators.Operator_Zip#</cfoutput>
											</CFIF>
								<cfoutput>#NewLine#</cfoutput>
								</CFLOOP>
							<CFELSE>
								<cfoutput>NONE SUPPLIED#NewLine#</cfoutput>
							</CFIF>
	</cfif>
	</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Distributors --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<cfif GetSettings.Specify_Distributors EQ 1>
	<cfset getDistributors  = ViewProgramManager.getDistributors(CSLGetContractInfo.Contract_Main_ID,businessSegmentsOn,GetSettings.Specify_Distributor_Groups)>
	
	<cfif getDistributors.recordcount GT 0>
	<cfoutput>#NewLine#Eligible #application.returned_customer_setting.distributor_label_plural#: #NewLine#</cfoutput>
							<CFIF getDistributors.RECORDCOUNT GT 0>
								<CFLOOP QUERY="getDistributors">
								
									<!---handle what gets passed to the distributor profile popup based on groups--->
									<cfif getDistributors.Is_Group eq 1>
										<cfset this.profileId = "#getDistributors.BSA_Foodservice_Customers_ID#&Distributor_Group_Level_ID=#getDistributors.Distributor_Group_Level_ID#&Is_Group=1" />
									<cfelse>
										<cfset this.profileId = getDistributors.BSA_Foodservice_Customers_ID />
									</cfif>
											<cfoutput>#ucase(trim(getDistributors.Name))#</cfoutput> <cfif Len(Shr_Ship_To)> <cfoutput>(#Shr_Ship_To#) </cfoutput></cfif>
											<cfif Distributor_Group_Level_ID EQ 1>
												<cfset distCount = CreateObject("component", "components.programs.distributors.DistributorGroupManager").getDistributorGroupDistributorCount(Distributor_Group_Level_ID, Distributor_Group_ID) /><cfoutput>(#distCount# #application.returned_customer_setting.distributor_label_plural#) </cfoutput>
											</cfif>
											<CFIF getDistributors.CITY NEQ "" AND getDistributors.STATE NEQ "">									<cfoutput>#ucase(TRIM(getDistributors.City))#, #ucase(TrIm(getDistributors.State))#</cfoutput>
											</CFIF>
									<cfoutput>#NewLine#</cfoutput>
								</CFLOOP>
							<CFELSE>
								<cfoutput>NONE SUPPLIED#NewLine#</cfoutput>
							</CFIF>
	</cfif>
	</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Brokers																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif GetSettings.Specify_Brokers EQ 1>
	

	<cfset getMarkets  = ViewProgramManager.getMarkets(CSLGetContractInfo.Contract_Main_ID)>
	<cfif getMarkets.recordcount GT 0>
	<cfoutput>#NewLine#Eligible Brokers: #NewLine#</cfoutput>
							<CFIF getMarkets.RECORDCOUNT GT 0>
								<CFLOOP QUERY="getMarkets">
									<cfoutput>#ucase(trim(getMarkets.Broker_Name))# #ucase(getMarkets.Market_Name)#</cfoutput>
									<cfoutput>#NewLine#</cfoutput>		
								</CFLOOP>
							<CFELSE>
								<cfoutput>NONE SUPPLIED#NewLine#</cfoutput>
							</CFIF>
						
	</cfif>
	</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!---TSF: Modification Bid Request--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Bid Request 																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


	<CFIF GetSettings.Generic_Type IS "Bid Request"> --->
		
		<!---get bid request data--->
		<cfset bidReqProdsFromDB = CreateObject("component", "components.programs.bid_request.BidRequestProductManager").getBidRequestProductsFromDb(CSLGetContractInfo.Contract_Main_ID) />
		<cfset bidReqProds = bidReqProdsFromDB.getBidRequestProducts() />
			<!---display bid requests only if they exist--->
			<cfif ArrayLen(bidReqProds)>
			<cfoutput>#NewLine#Bid Request#NewLine#</cfoutput>
			<cfif appSettings.getPaymentCycleAtDiscountType()>
			<cfoutput>Payment Cycle:</cfoutput>
			<cf_payment_cycle_selection
				Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
				Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
				discount_Type_ID = "5"
				Selected_Payment_Cycle_ID = ""
				Action = "display"
				><cfoutput>#NewLine#</cfoutput>
			</cfif>
			<cfoutput>#claimHandle.TextAlignLeft(11,"UPC")#</cfoutput> <cfoutput>#claimHandle.TextAlignLeft(11,"ITEM")#</cfoutput>
<cfoutput>#claimHandle.TextAlignLeft(17,"DESCRIPTION")#</cfoutput>
<cfif displayGroupType>
<cfoutput>#claimHandle.TextAlignLeft(14,trim(displayGroupTypeDesc))#</cfoutput></cfif>
<cfoutput>#claimHandle.TextAlignLeft(4,"UOM")#</cfoutput>
 <cfoutput>#claimHandle.TextAlignLeft(14,"DefaultPr.")#</cfoutput>		
<cfoutput>#claimHandle.TextAlignLeft(12,"Allow.")#</cfoutput>		
<cfoutput>#claimHandle.TextAlignLeft(12,"Net")#</cfoutput>		
<cfoutput>#claimHandle.TextAlignLeft(8,"Won/Lost")#</cfoutput><cfset volumeapplicator ="#Program_Volume.defaultUOT.getDesc()# Vol."> <cfoutput>#claimHandle.TextAlignLeft(20,trim(volumeapplicator))#</cfoutput>
<cfoutput>#NEWLINE#</cfoutput>
<CFOUTPUT>#RepeatString("-",106)##NEWLINE#</CFOUTPUT>
				</cfif>			
						<cfloop index="i" from="1" to="#ArrayLen(bidReqProds)#">
						<CFSET Total_Product_Volume = Program_Volume.GetProductVolume(bidReqProds[i].getItemMasterId())><cfset item_volume="#numberformat(round(Total_Product_Volume), '___,___,__,__')# lb/#Program_Volume.defaultUOT.getNounDesc()#">	<cfoutput>#claimHandle.TextAlignLeft(11,Trim(bidReqProds[i].getUpc()))#</cfoutput>
							<cfoutput>#claimHandle.TextAlignLeft(11,Trim(bidReqProds[i].getItem()))#</cfoutput>
<cfif Len(Trim(bidReqProds[i].getDesc())) LT 15>
<cfset Desc = Trim(bidReqProds[i].getDesc())>
<cfelse>
<cfset Desc = Left(Trim(bidReqProds[i].getDesc()),14)>
</cfif>			
<cfoutput>#claimHandle.TextAlignLeft(17,Trim(Desc))#</cfoutput>
<cfif displayGroupType>
<cfset sDisplayGroupName = "">
<cfif displayGroupType EQ 3><!------ Q Brand ----->
<cfset sDisplayGroupName = bidReqProds[i].getQBrand()>
<cfelseif displayGroupType EQ 1><!------ Type Code ----->
<cfset sDisplayGroupName = bidReqProds[i].getTypeCode()>
</cfif>
<cfset sDisplayGroupName = Left(Trim(sDisplayGroupName),12)>
<cfoutput>#claimHandle.TextAlignLeft(14,sDisplayGroupName)#</cfoutput>
</cfif>		
<cfset BidUOm = request.app_general_functions.getUomDesc(bidReqProds[i].getUom(),0)>
<cfoutput>#claimHandle.TextAlignLeft(4,Trim(BidUOm))#</cfoutput>	
<cfset Defprice = NumberFormat(bidReqProds[i].getDefaultPrice() , ViewProgramManager.getRateFormatMask())>
<cfoutput>#claimHandle.TextAlignLeft(14,Trim(Defprice))#</cfoutput>		
<cfoutput>#claimHandle.TextAlignLeft(12,Trim(NumberFormat(bidReqProds[i].getAllowance() , ViewProgramManager.getRateFormatMask())))#</cfoutput>
<cfoutput>#claimHandle.TextAlignLeft(12,Trim(NumberFormat(bidReqProds[i].getNet() , ViewProgramManager.getRateFormatMask())))#</cfoutput>
<cfif trim(bidReqObj.getStatus()) eq 1>
<cfoutput>#claimHandle.TextAlignLeft(8,"Pending")#</cfoutput>
<cfelse>
<cfif bidReqProds[i].getWon()>
<cfoutput>#claimHandle.TextAlignLeft(8,"won")#</cfoutput>
<cfelse>
<cfoutput>#claimHandle.TextAlignLeft(8,"lost")#</cfoutput>
</cfif>
</cfif>
<cfoutput>#claimHandle.TextAlignLeft(20,item_volume)#</cfoutput>
<cfoutput>#NewLine#</cfoutput>
</cfloop>
		</cfif>
		
		
		<!--- <cfoutput>#claimHandle.TextAlignLeft(8,request.app_general_functions.getUomDesc(bidReqProds[i].getUom(),0))#</cfoutput>
<cfoutput>#claimHandle.TextAlignLeft(15,NumberFormat(bidReqProds[i].getDefaultPrice() , "$_.__"))#</cfoutput>
<cfoutput>#claimHandle.TextAlignLeft(15,NumberFormat(bidReqProds[i].getAllowance() , "$_.__"))#</cfoutput>
<cfoutput>#claimHandle.TextAlignLeft(15,NumberFormat(bidReqProds[i].getNet() , "$_.__"))#</cfoutput>
<cfif trim(bidReqObj.getStatus()) eq 1>
<cfoutput>#claimHandle.TextAlignLeft(12,"Pending...")#</cfoutput>
<cfelse>
<cfif bidReqProds[i].getWon()>
<cfoutput>#claimHandle.TextAlignLeft(12,"won")#</cfoutput>
<cfelse>
<cfoutput>#claimHandle.TextAlignLeft(12,"lost")#</cfoutput>
</cfif>
</cfif> --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Off-Invoice																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFIF GetSettings.Generic_Type IS "Distributor Off-Invoice">
	<cfset getOffInvoicePositive  = ViewProgramManager.getOffInvoicePositive(CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
<cfset getOffInvoiceNegative  = ViewProgramManager.getOffInvoiceNegative(CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
	

	<cfif getOffInvoicePositive.recordcount GT 0 OR getOffInvoiceNegative.recordcount GT 0>
	<cfoutput>Off Invoice (Price Increase): #NewLine#</cfoutput>

						<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfoutput>#claimHandle.TextAlignLeft(12,"UPC")#</cfoutput></cfif></cfif>
<cfoutput>#claimHandle.TextAlignLeft(12,"ITEM")#</cfoutput>
<cfoutput>#claimHandle.TextAlignLeft(18,"DESCRIPTION")#</cfoutput>
<cfif displayGroupType>
<cfoutput>#claimHandle.TextAlignLeft(15,trim(displayGroupTypeDesc))#</cfoutput></cfif>
<!------ TODO ----->
<cfoutput>ADJUSTMENT</cfoutput>
<cfset volumeapplicator ="#Program_Volume.defaultUOT.getDesc()# Vol.">
<cfoutput>#claimHandle.TextAlignLeft(20,trim(volumeapplicator))#</cfoutput>	
<CFOUTPUT>#NewLine##RepeatString("-",100)##NewLine#</CFOUTPUT>	
					<!--- begin DATA OUTPUT --->
					<CFLOOP QUERY="getOffInvoicePositive">
							<CFSET Total_Product_Volume = Program_Volume.GetProductVolume(getOffInvoicePositive.BSA_Foodservice_Items_Master_ID)><cfset item_volume="#numberformat(round(Total_Product_Volume), '___,___,__,__')# lb/#Program_Volume.defaultUOT.getNounDesc()#"><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfoutput>#claimHandle.TextAlignLeft(12,UPC)#</cfoutput></cfif></cfif>
<cfoutput>#claimHandle.TextAlignLeft(12,ITEM)#</cfoutput>
<cfif Len(Trim(Description)) LT 15>
<cfset Desc = Trim(Description)>
<cfelse>
<cfset Desc = Left(Trim(Description),15)>
</cfif>
<cfoutput>#claimHandle.TextAlignLeft(18,TRIM(Desc))#</cfoutput>
<cfif displayGroupType>
<cfset sDisplayGroupName = Left(Trim(DisplayGroupName),12)>
<cfoutput>#claimHandle.TextAlignLeft(15,TRIM(sDisplayGroupName))#</cfoutput>
</cfif>			
<cfif plus_minus IS 1><cfoutput>+</cfoutput><cfelse><cfoutput>-</cfoutput></cfif>   
<cfif UOM IS 1><cfoutput>#NumberFormat(Discount_Amount, ViewProgramManager.getRateFormatMask(0))# per case</cfoutput><cfelseif UOM IS 2><cfoutput>#NumberFormat(Discount_Amount, ViewProgramManager.getRateFormatMask(0))# per pound</cfoutput><cfelse><cfoutput>#NumberFormat(Discount_Amount, '___.____')#%</cfoutput></cfif><cfoutput>#claimHandle.TextAlignLeft(20,item_volume)#</cfoutput>
<cfoutput>#NewLine#</cfoutput>
					</CFLOOP>		
<cfoutput>					
#NewLine#Off Invoice (Price Decrease):#NewLine#</cfoutput>
<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfoutput>#claimHandle.TextAlignLeft(12,"UPC")#</cfoutput></cfif></cfif>
<cfoutput>#claimHandle.TextAlignLeft(12,"ITEM")#</cfoutput>
<cfoutput>#claimHandle.TextAlignLeft(18,"DESCRIPTION")#</cfoutput>
<cfif displayGroupType>
<cfoutput>#claimHandle.TextAlignLeft(15,trim(displayGroupTypeDesc))#</cfoutput></cfif>
<cfoutput>ADJUSTMENT</cfoutput><cfset volumeapplicator ="#Program_Volume.defaultUOT.getDesc()# Vol."> <cfoutput>#claimHandle.TextAlignLeft(20,trim(volumeapplicator))#</cfoutput>	
<CFOUTPUT>#NewLine##RepeatString("-",100)##NewLine#</CFOUTPUT>	
					<!--- begin DATA OUTPUT --->
<CFLOOP QUERY="getOffInvoiceNegative">
		<CFSET Total_Product_Volume = Program_Volume.GetProductVolume(getOffInvoiceNegative.BSA_Foodservice_Items_Master_ID)><cfset item_volume="#numberformat(round(Total_Product_Volume), '___,___,__,__')# lb/#Program_Volume.defaultUOT.getNounDesc()#"><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfoutput>#claimHandle.TextAlignLeft(12,UPC)#</cfoutput></cfif></cfif>
<cfoutput>#claimHandle.TextAlignLeft(12,ITEM)#</cfoutput>
<cfif Len(Trim(Description)) LT 15>
<cfset Desc = Trim(Description)>
<cfelse>
<cfset Desc = Left(Trim(Description),15)>
</cfif>
<cfoutput>#claimHandle.TextAlignLeft(18,TRIM(Desc))#</cfoutput>
<cfif displayGroupType>
<cfset sDisplayGroupName = Left(Trim(DisplayGroupName),12)>
<cfoutput>#claimHandle.TextAlignLeft(15,TRIM(sDisplayGroupName))#</cfoutput>
</cfif>			
<cfif plus_minus IS 1><cfoutput>+</cfoutput><cfelse><cfoutput>-</cfoutput></cfif>   
<cfif UOM IS 1><cfoutput>#NumberFormat(Discount_Amount, ViewProgramManager.getRateFormatMask(0))# per case</cfoutput><cfelseif UOM IS 2><cfoutput>#NumberFormat(Discount_Amount, ViewProgramManager.getRateFormatMask(0))# per pound</cfoutput><cfelse><cfoutput>#NumberFormat(Discount_Amount, '___.____')#%</cfoutput></cfif><cfoutput>#claimHandle.TextAlignLeft(20,item_volume)#</cfoutput>
<cfoutput>#NewLine#</cfoutput>				
</CFLOOP>					
						
</cfif>
	</CFIF>
	
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- FIXED PRICING																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


	<CFIF GetSettings.Discount_Fixed_Prices EQ 1>
	<cfset getFixedPriceProducts  = ViewProgramManager.getFixedPriceProducts(CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
	<cfif getFixedPriceProducts.recordcount GT 0>
	<cfif appSettings.getfixedcomponents_on()><cfset getcompNames  = ViewProgramManager.getcompNames(CSLGetContractInfo.Contract_Main_ID)></cfif>
	<cfoutput>#NewLine#Fixed Pricing: #NewLine#</cfoutput>

				<CFIF getFixedPriceProducts.recordcount GT 0>
				<cfoutput>*The Prices Below Are </cfoutput><CFIF CSLGetContractInfo.Fixed_Price_Rebate_Type EQ 1><cfoutput>Net Delivered</cfoutput><CFELSE><cfoutput>FOB</cfoutput></CFIF><cfif trim(CSLGetContractInfo.Generic_Type) EQ "Operator-Deviated Pricing"> <cfoutput> for the Distributor and do not include their mark-up</cfoutput></cfif>
<cfoutput>#NewLine#</cfoutput>
<cfif appSettings.getPaymentCycleAtDiscountType()>
<cfoutput>Payment Cycle:</cfoutput>
<cf_payment_cycle_selection
	Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
	Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
	discount_Type_ID = "1"
	Selected_Payment_Cycle_ID = ""
	Action = "display"
	>
</cfif>
<cfoutput>#NewLine#</cfoutput>
						<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfoutput>#claimHandle.TextAlignLeft(12,"UPC")#</cfoutput></cfif></cfif>
<cfoutput>#claimHandle.TextAlignLeft(12,"ITEM")#</cfoutput><cfoutput>#claimHandle.TextAlignLeft(16,"DESCRIPTION")#</cfoutput>
<cfif displayGroupType>
<cfoutput>#claimHandle.TextAlignLeft(15,trim(displayGroupTypeDesc))#</cfoutput></cfif>
						<cfif appSettings.getfixedcomponents_on()>
						<CFLOOP query="getcompNames">
						<cfif getcompNames.Fixed_Component_Paid_to EQ 1>
							<cfset paidto = "(Dis.)">
						<cfelse>
							<cfset paidto = "(Opr.)">
						</cfif>
						<cfset comp_name = LEFT(TRIM(getcompNames.Program_Fixed_Component_Name),10)>
					<cfset compname = #comp_name#&#paidto#>	<cfoutput>#claimHandle.TextAlignLeft(20,trim(compname))#</cfoutput>		</CFLOOP><cfelse><cfoutput>#claimHandle.TextAlignLeft(20,trim("Price"))#</cfoutput></cfif><cfset volumeapplicator ="#Program_Volume.defaultUOT.getDesc()# Vol."> <cfoutput>#claimHandle.TextAlignLeft(20,trim(volumeapplicator))#</cfoutput>
		<CFOUTPUT>#NewLine##RepeatString("-",100)##NewLine#</CFOUTPUT>	
				<!--- begin DATA OUTPUT --->

<CFOUTPUT QUERY="getFixedPriceProducts" group="BSA_Foodservice_Items_Master_ID"><cfsilent><CFSET Total_Product_Volume = Program_Volume.GetProductVolume(getFixedPriceProducts.BSA_Foodservice_Items_Master_ID)><cfset item_volume="#numberformat(round(Total_Product_Volume), '___,___,__,__')# #getContractUOMLabel.Unit_Of_Measure_Desc#/#Program_Volume.defaultUOT.getNounDesc()#"><CFSET item_num= getFixedPriceProducts.BSA_Foodservice_Items_Master_ID></cfsilent><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#claimHandle.TextAlignLeft(12,TRIM(getFixedPriceProducts.UPC))#</cfif></cfif>#claimHandle.TextAlignLeft(12,TRIM(getFixedPriceProducts.ITEM))#<cfset Desc = Left(LTrim(getFixedPriceProducts.Description),14)>#claimHandle.TextAlignLeft(16,Desc,1)#<cfif displayGroupType><cfset sDisplayGroupName = Left(Trim(DisplayGroupName),12)>#claimHandle.TextAlignLeft(15,sDisplayGroupName)#</cfif><cfif appSettings.getfixedcomponents_on()><CFLOOP query="getcompNames"><cfsilent><cfset getfixedproductprice=ViewProgramManager.getfixedproductprice(getFixedPriceProducts,getcompNames.Program_Fixed_Component_ID,item_num)><cfset price="#trim(numberformat(getfixedproductprice.Fixed_Price_Value, ViewProgramManager.getRateFormatMask()))#/#left(TRIM(getfixedproductprice.Abbreviation),2)#"></cfsilent><cfif getfixedproductprice.Fixed_Price_Value neq "" and getfixedproductprice.Fixed_Price_Value neq 0>#claimHandle.TextAlignLeft(20,price)#<cfelse>#claimHandle.TextAlignLeft(20,'')#</cfif></CFLOOP><cfelse><cfsilent><cfset price="#trim(numberformat(Fixed_Price_Value, ViewProgramManager.getRateFormatMask()))#/#left(TRIM(Abbreviation), 2)#"></cfsilent>#claimHandle.TextAlignLeft(20,price)#</cfif>#claimHandle.TextAlignLeft(20,item_volume)##NewLine#</CFOUTPUT><CFELSE><cfoutput>NO PRODUCTS SUPPLIED#NewLine#</cfoutput></CFIF>
					<!--- end DATA OUTPUT --->
			
	<!------ End  Clause Code ----->
	</cfif>
	</CFIF>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- REBATES																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


	<CFIF GetSettings.Discount_Rebates EQ 1>
	
		<cfscript>
			rebate =  createObject("component","components.programs.rebates.Rebate");
			comp =  createObject("component","components.programs.rebates.RebateComponent");
			rebateData = rebate.loadFromDB(programID=CSLGetContractInfo.Contract_Main_ID, displayGroupType=displayGroupType);
		</cfscript>
		
		<CFSET upc_width=80>
		<CFSET desc_width=100>
		<CFSET volume_width=60>
		<CFSET component_width=95>

		<cfif ArrayLen(rebateData.aProd)>
	
			<cfoutput>#NewLine##Application.RebateLabel#s: #NewLine#</cfoutput>
<cfif appSettings.getPaymentCycleAtDiscountType()>
<cfoutput>Payment Cycle:</cfoutput>
<cf_payment_cycle_selection
	Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
	Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
	discount_Type_ID = "1"
	Selected_Payment_Cycle_ID = ""
	Action = "display"
	>
</cfif>
<cfoutput>#NewLine#</cfoutput>
								<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
									<cfif application.returned_customer_setting.upc_switch EQ 1>	<cfoutput>#claimHandle.TextAlignLeft(11,"UPC")#</cfoutput>
									</cfif>
								</cfif>	<cfoutput>#claimHandle.TextAlignLeft(11,"ITEM")#</cfoutput>						
<cfoutput>#claimHandle.TextAlignLeft(17,"DESCRIPTION")#</cfoutput>		
<cfif displayGroupType><cfoutput>#claimHandle.TextAlignLeft(14,trim(displayGroupTypeDesc))#</cfoutput>
</cfif>							
<cfloop index="i" from="1" to="#ArrayLen(rebateData.aComp)#">
					<!---get the component name--->
					<cfscript>
										qCompName = comp.getComp(rebateData.aComp[i].compNameId);
									</cfscript>
									<cfoutput>#claimHandle.TextAlignLeft(20,LEFT(trim(qCompName.Program_Rebates_Component_Name),16))#</cfoutput>
								</cfloop><cfset volumeapplicator ="#Program_Volume.defaultUOT.getDesc()# Vol."> <cfoutput>#claimHandle.TextAlignLeft(20,trim(volumeapplicator))#</cfoutput>
				<CFOUTPUT>#NewLine##RepeatString("-",100)##NewLine#</CFOUTPUT>		
							<!--- begin DATA OUTPUT --->
							<cfloop index="i" from="1" to="#ArrayLen(rebateData.aProd)#">
							<CFSET Total_Product_Volume = Program_Volume.GetProductVolume(rebateData.aProd[i].MASTERITEMID)><cfset item_volume="#numberformat(round(Total_Product_Volume), '___,___,__,__')# #getContractUOMLabel.Unit_Of_Measure_Desc#/#Program_Volume.defaultUOT.getNounDesc()#">	
								<!---onmouseover menuId--->
								<cfif rebateData.aProd[i].isGroup eq 1>
									<cfset request.menuId = 11 />
									<cfset request.theMOId = "#rebateData.aProd[i].productGroupID#&Group_Level_ID=#rebateData.aProd[i].productGroupLevel#&programId=#CSLGetContractInfo.Contract_Main_ID#" />
								<cfelse>
									<cfset request.menuId = 6 />
									<cfset request.theMOId = rebateData.aProd[i].masterItemId />
								</cfif>
								<!--- DATA OUTPUT --->
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
										<cfif application.returned_customer_setting.upc_switch EQ 1>
									<cfoutput>#claimHandle.TextAlignLeft(11,TRIM(rebateData.aProd[i].UPC))#</cfoutput>		</cfif>
</cfif>
	<cfoutput>#claimHandle.TextAlignLeft(11,TRIM(rebateData.aProd[i].ITEM))#</cfoutput>								
	<cfif Len(Trim(rebateData.aProd[i].Description)) LT 15>
<cfset Desc = Trim(rebateData.aProd[i].Description)>
<cfelse>
<cfset Desc = Left(Trim(rebateData.aProd[i].Description),15)>
</cfif>
<cfoutput>#claimHandle.TextAlignLeft(17,TRIM(Desc))#</cfoutput>
									<!--- <cfif rebateData.aProd[i].productGroupLevel NEQ 0 AND rebateData.aProd[i].productGroupLevel NEQ "">
									(#ProductGroupManager.getProductGroupProductCount(rebateData.aProd[i].productGroupLevel, rebateData.aProd[i].productGroupID)# products)
									</cfif> --->
									<cfif displayGroupType>
									
<cfset sDisplayGroupName = Left(Trim(rebateData.aProd[i].displayGroupName),12)>
<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(sDisplayGroupName))#</cfoutput></cfif>
									
									<cfloop index="n" from="1" to="#ArrayLen(rebateData.aComp)#">
										<td>
										<!---get uom label--->
										<cfscript>
											uom = createObject("component","components.programs.rebates.uom");
											thisUom = uom.getUomAbbr(rebateData.aCompVal[i][n].uomId);
										</cfscript>
										<cfif rebateData.aCompVal[i][n].uomId eq 3>
										<cfset price = "#numberformat(rebateData.aCompVal[i][n].rate, ViewProgramManager.getRateFormatMask())##thisUom#">
<cfoutput>#claimHandle.TextAlignLeft(20,price)#</cfoutput>
										<cfelse>
	<cfset price = 									"#numberformat(rebateData.aCompVal[i][n].rate, ViewProgramManager.getRateFormatMask())# per #thisUom#">
<cfoutput>#claimHandle.TextAlignLeft(20,price)#</cfoutput>	
										</cfif>
									</cfloop>
					<cfoutput>#claimHandle.TextAlignLeft(20,item_volume)#</cfoutput>
								
								<cfoutput>#NewLine#</cfoutput>
							</cfloop>										
					<!--- END DATA OUTPUT --->
				
			<!------ End  Clause Code ----->
		</cfif>	
	</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- GROWTH																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFIF GetSettings.Discount_Growth EQ 1>
	<cfset getComponents  = ViewProgramManager.getgrowthComponents(CSLGetContractInfo.Contract_Main_ID,appSettings.getGrowthExpansion1())>
	<cfif getComponents.recordcount GT 0>
	<cfoutput>#NewLine#Growth Rates#NewLine#</cfoutput>
	<cfif appSettings.getPaymentCycleAtDiscountType()>
	<cfoutput>Payment Cycle:</cfoutput>
	<cf_payment_cycle_selection
		Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
		Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
		discount_Type_ID = "1"
		Selected_Payment_Cycle_ID = ""
		Action = "display"
		>
	</cfif>
			<CFIF getComponents.recordcount GT 0>
				<CFLOOP QUERY="getComponents">
				<cfparam name="HasSeperateVolume" default="0">
					
					<cfif appSettings.getGrowthExpansion1()>			
						<cfif getComponents.Program_Growth_Component_Type_ID IS 1>
							<!---Does it have a seperate volume pool?--->
							<cfset GetVolumePool  = ViewProgramManager.GetVolumePool(getComponents.Program_Growth_Component_ID)>
							
							<Cfif GetVolumePool.Recordcount GT 0>
							<Cfset HasSeperateVolume = 1>
							</CFIF>
						<cfelse>
							<Cfset HasSeperateVolume = 1>	
						</cfif>
					</cfif>
				
					<CFSET CurrentComponent_ID = getComponents.Program_Growth_Component_ID>
<cfoutput><cfoutput>#NewLine#</cfoutput>#getComponents.Component_Name#-(#getComponents.Component_Description#)(<CFIF getComponents.Rate_Type EQ 1> Retroactive Rate<CFELSE> Bracket Rate</CFIF>)<cfif appSettings.getGrowthExpansion1()>#NewLine#Type: #getComponents.Description##NewLine#</cfif></cfoutput>
					
					<cfset getComponentTiers  = ViewProgramManager.getComponentTiers(CSLGetContractInfo.Contract_Main_ID,CurrentComponent_ID)>
					<!----Only do this for normal ones--->
					<cfif appSettings.getGrowthExpansion1()>			
					<cfif getComponents.Program_Growth_Component_Type_ID IS 1>
					
<cfset volume_range = "Volume Range (#Trim(getComponents.component_UOM_Desc)#)">
<CFOUTPUT>#claimHandle.TextAlignLeft(40,trim(volume_range))#</cfoutput> <CFOUTPUT>#claimHandle.TextAlignLeft(30,Trim(Application.LumpsumLabel))##NewLine#</CFOUTPUT><CFOUTPUT>#RepeatString("-",60)##NewLine#</CFOUTPUT>		
						<CFLOOP QUERY="getComponentTiers">
						<cfset volume = "#trim(numberformat(val(getComponentTiers.Range_Start), '___,___,___,___,___,___,___,'))#"> <cfif trim(getComponentTiers.Range_End) EQ "*"> 
<cfset volume = volume & " or More">
<cfelse><cfset volume = volume & " to "> <cfset volume = volume & #trim(numberformat(val(getComponentTiers.Range_End), '___,___,___,___,___,___,___,'))#></cfif>
<cfoutput>#claimHandle.TextAlignLeft(40,Trim(volume))#</cfoutput>
<cfset amount = "$#trim(numberformat(getComponentTiers.Growth_Amount, '___,___,___,___,___,___,___'))#">
<cfoutput>#claimHandle.TextAlignLeft(30,amount)#</cfoutput>
<cfoutput>#NewLine#</cfoutput>
						</CFLOOP>	
						<cfoutput>#NewLine#</cfoutput>	
						<!---It's a stairway or X of Y--->
						<cfelse>	
						<!---Target information--->
						<cfset GetTargets  = ViewProgramManager.GetTargets(getComponents.Program_Growth_Component_ID)>
					
						<cfoutput>Targets:#NewLine#</cfoutput>
	<CFLOOP QUERY="getTargets">
<cfoutput>#GetTargets.Target_Order#) #GetTargets.Component_Name# #GetTargets.Range_End#  #GetTargets.Abbreviation##NewLine#</cfoutput>
						
						<!---Get items for this target--->
						<cfset TargetItems  = ViewProgramManager.TargetItems(GetTargets.Program_Growth_Component_ID)>
						<cfif TargetItems.Recordcount GT 0>
		<CFLOOP QUERY="TargetItems">
			<cfoutput>#trim(TargetItems.Description)##TargetItems.Item##newLine#</cfoutput>
				<CFIF TargetItems.CURRENTROW MOD 3><CFELSE></CFIF>
			</CFLOOP>
	</cfif>
</CFLOOP>
</cfif>
</cfif>
<cfset getComponentProducts  = ViewProgramManager.getComponentProducts(CurrentComponent_ID, CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
<CFIF getComponentProducts.recordcount GT 0>
<!---Checks to see if the only rate is 0 -- do not display products where all rates = 0--->	
				<cfquery name="DistinctRate" datasource="#application.datasource#">
				SELECT Distinct Program_Growth_Component_Product_Tier_Data.Rate 
					FROM Program_Growth_Component_Product_Tier_Data
					INNER JOIN Program_Growth_Component_Product_Data
					ON Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID = Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID
					AND Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#CurrentComponent_ID#'
					AND Program_Growth_Component_Product_Data.Deleted = 0
				WHERE Program_Growth_Component_Product_Tier_Data.Deleted = 0
				</cfquery>
							
				<!---Don't display if there's only one rate and that rate is 0--->
				<cfif DistinctRate.Recordcount IS 1 AND DistinctRate.Rate IS 0>
								&nbsp; 
				<!---Display items/groups--->
				<cfelse>

							<!---In case this is just rate, and not volume--->
							<cfif HasSeperateVolume IS 1>
							<cfoutput>#newLine#Rate Items:#newLine#</cfoutput>
							</cfif>
								<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
								<cfoutput>#claimHandle.TextAlignLeft(12,"UPC")#</cfoutput></cfif></cfif>
								<cfoutput>#claimHandle.TextAlignLeft(12,"ITEM")#</cfoutput>
<cfoutput>#claimHandle.TextAlignLeft(18,"DESCRIPTION")#</cfoutput>
<cfif displayGroupType>
<cfoutput>#claimHandle.TextAlignLeft(15,trim(displayGroupTypeDesc))#</cfoutput></cfif>
<cfoutput>RATES</cfoutput><cfset volumeapplicator ="#Program_Volume.defaultUOT.getDesc()# Vol."> <cfoutput>#claimHandle.TextAlignLeft(20,trim(volumeapplicator))#</cfoutput>
<CFOUTPUT>#NewLine##RepeatString("-",90)##NewLine#</CFOUTPUT>			
									
							<!--- TABLE DATA QUERY --->
							<CFLOOP QUERY="getComponentProducts">
							<CFSET Total_Product_Volume = Program_Volume.GetProductVolume(getComponentProducts.BSA_Foodservice_Items_Master_ID)><cfset item_volume="#numberformat(round(Total_Product_Volume), '___,___,__,__')# #getContractUOMLabel.Unit_Of_Measure_Desc#/#Program_Volume.defaultUOT.getNounDesc()#">
								<CFSET CurrentProduct = getComponentProducts.Contract_Products_ID>
							
								<cfset getComponentProductTierData  = ViewProgramManager.getComponentProductTierData(CSLGetContractInfo.Contract_Main_ID,CurrentProduct)>
								<!--- DATA OUTPUT --->
								<CFSET CurrentRowColor = IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))>
								<CFSET ThisProductsID = getComponentProducts.BSA_Foodservice_Items_Master_ID>
								<cfset This_Product_Group_Level_ID = getComponentProducts.Product_Group_Level_ID>
								
								<!---onmouseover menuId--->
								<cfif getComponentProducts.Is_Group eq 1>
									<cfset request.menuId = 11 />
									<cfset request.theMOId = "#getComponentProducts.Product_Group_ID#&Group_Level_ID=#getComponentProducts.Product_Group_Level_ID#&Program_ID=#CSLGetContractInfo.Contract_Main_ID#" />
								<cfelse>
									<cfset request.menuId = 6 />
									<cfset request.theMOId = ThisProductsID />
								</cfif>
								<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>
<cfoutput>#claimHandle.TextAlignLeft(12,getComponentProducts.UPC)#</cfoutput>
								</cfif></cfif>
<cfoutput>#claimHandle.TextAlignLeft(12,getComponentProducts.ITEM)#</cfoutput>
<cfif Len(Trim(getComponentProducts.Description)) LT 15>
<cfset Desc = Trim(getComponentProducts.Description)>
<cfelse>
<cfset Desc = Left(Trim(getComponentProducts.Description),15)>
</cfif>				
	<cfoutput>#claimHandle.TextAlignLeft(18,TRIM(Desc))#</cfoutput>
								<!--- <cfif Product_Group_Level_ID NEQ 0 AND Product_Group_Level_ID NEQ "">
								(#ProductGroupManager.getProductGroupProductCount(Product_Group_Level_ID, Product_Group_ID)# products)
								</cfif> --->
								
<cfif displayGroupType>
<cfset sDisplayGroupName = Left(Trim(getComponentProducts.DisplayGroupName),12)>
<cfoutput>#claimHandle.TextAlignLeft(15,TRIM(sDisplayGroupName))#</cfoutput>
</cfif>      
<cfoutput>Tier 1:</cfoutput>
<cfif len(trim(getComponentProductTierData.Rate)) EQ 0><cfoutput>Pending...</cfoutput>
<CFELSE>
<CFIF trim(getComponentProductTierData.Abbreviation) EQ "%">
									<cfoutput>#trim(numberformat(getComponentProductTierData.Rate, ViewProgramManager.getRateFormatMask(0)))# #left(getComponentProductTierData.Abbreviation,2)#</cfoutput>
									<CFELSE>
									<cfoutput>#trim(numberformat(getComponentProductTierData.Rate, ViewProgramManager.getRateFormatMask()))# per  #left(getComponentProductTierData.Abbreviation,2)#</cfoutput>
<cfoutput>#claimHandle.TextAlignLeft(20,item_volume)##NewLine#</cfoutput>
									</CFIF>
								</cfif>
							<CFIF getComponentProductTierData.recordcount GT 1>
								<CFLOOP QUERY="getComponentProductTierData" STARTROW="2">
<cfset space = "">
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
						<cfif application.returned_customer_setting.upc_switch EQ 1>
			<cfoutput>#claimHandle.TextAlignLeft(12,space)#</cfoutput>
		</cfif></cfif>
		<cfoutput>#claimHandle.TextAlignLeft(12,space)#</cfoutput>
		<cfoutput>#claimHandle.TextAlignLeft(18,space)#</cfoutput>
		<cfif appSettings.getUseProductGroup2()>
		<cfoutput>#claimHandle.TextAlignLeft(15,space)#</cfoutput>
		</cfif>
		<cfoutput>Tier #Tier_Number#:</cfoutput>
	<cfif len(trim(getComponentProductTierData.Rate)) EQ 0>
			<cfoutput>Pending...</cfoutput>
	<CFELSE>
	<cfif trim(getComponentProductTierData.Abbreviation) EQ "%">
										<cfoutput>#trim(numberformat(getComponentProductTierData.Rate, ViewProgramManager.getRateFormatMask(0)))# #trim(left(getComponentProductTierData.Abbreviation,2))#</cfoutput>
	<CFELSE>
										<cfoutput>#trim(numberformat(getComponentProductTierData.Rate, ViewProgramManager.getRateFormatMask()))# per  #trim(left(getComponentProductTierData.Abbreviation,2))#</cfoutput>
	</CFIF>
									</cfif>
			<cfoutput>#NewLine#</cfoutput>
								</CFLOOP>
							</CFIF>						
							</CFLOOP>
						<!---Don't display if there's only one rate and that rate is 0--->
						</cfif>		
						<CFELSE>
							<cfoutput>NO PRODUCTS SUPPLIED#NewLine#</cfoutput>
						</CFIF>	
				</CFLOOP>				
			<CFELSE>
				<cfoutput>NONE SUPPLIED#NewLine#</cfoutput>
			</CFIF>	

	<!------ End  Clause Code ----->
	</cfif>
	</CFIF>
	
	
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- LUMP SUM																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFIF GetSettings.Discount_Lump_Sums EQ 1>
	<cfset getLumpSums  = ViewProgramManager.getLumpSums(CSLGetContractInfo.Contract_Main_ID)>
								<!--- DATA OUTPUT --->
	<cfif getLumpSums.recordcount GT 0>	
	<CFOUTPUT>#NewLine##NewLine##Application.LumpsumLabel# Incentives#NewLine#</CFOUTPUT>
	<CFIF getLumpSums.recordcount GT 0>
	<cfif appSettings.getPaymentCycleAtDiscountType()>
	<cfoutput>Payment Cycle:</cfoutput>
	<cf_payment_cycle_selection
		Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
		Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
		discount_Type_ID = "3"
		Selected_Payment_Cycle_ID = ""
		Action = "display"
		><cfoutput>#NewLine#</cfoutput>
	</cfif>
				<cfoutput>#claimHandle.TextAlignLeft(40,"#Application.LumpsumLabel# Name")#</cfoutput>
				<cfoutput>#claimHandle.TextAlignLeft(30,"AMOUNT")#</cfoutput>	
				<cfoutput>#NewLine#</cfoutput>
					<CFLOOP QUERY="getLumpSums">
					<cfoutput>#claimHandle.TextAlignLeft(40,Trim(getLumpSums.Program_Lump_Sum_Name))#</cfoutput>
<cfset lumpamount = "$ #trim(numberformat(getLumpSums.Lump_Sum_Amount, '___,___,___,___,___,___.__'))#">
<cfoutput>#claimHandle.TextAlignLeft(30,trim(lumpamount))##NewLine#</cfoutput>
					</CFLOOP>
					<CFELSE>
						<cfoutput>NONE SUPPLIED#NewLine#</cfoutput>
					</CFIF>
	</cfif>
	</CFIF>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Formula Pricing																						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<CFIF GetSettings.Discount_Formula_Pricing EQ 1>
	<cfset getRules  = ViewProgramManager.getRules(CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
	<cfif getRules.recordcount GT 0>
		<CFSET getInfoForProgramID 	= CSLGetContractInfo.Contract_Main_ID>
		<CFSET getInfoForPeriod 	= "any">
		<CFINCLUDE TEMPLATE="program_pricing_period_information.cfm"> 
	<CFOUTPUT>#NewLine##NewLine#Formula Pricing#NewLine#</CFOUTPUT>
				<CFIF periods.Requested_Period_Info.ValidData EQ 1>
<cfoutput>Prices For Period: #DateFormat(periods.Requested_Period_Info.Start_Date,'m/d/yyyy')# - #DateFormat(periods.Requested_Period_Info.End_Date,'m/d/yyyy')##NewLine#Release Date:#DateFormat(periods.Requested_Period_Info.Release_Date,'m/d/yyyy')##NewLine#</cfoutput>
					<CFSET PPID=periods.Requested_Period_Info.Program_Formula_Pricing_Period_ID>
				<CFELSE>
					<cfoutput>NO DATE SUPPLIED#NewLine#</cfoutput>
					<CFSET PPID="">
				</CFIF>						
					
		<cfoutput>*The Prices Below Are </cfoutput><CFIF CSLGetContractInfo.Formula_Price_Rebate_Type EQ 1><cfoutput>Net Delivered</cfoutput><CFELSE><cfoutput>FOB</cfoutput></CFIF><cfif trim(CSLGetContractInfo.Generic_Type) EQ "Operator-Deviated Pricing"> <cfoutput>for the #application.returned_customer_setting.distributor_label_singular# and do not include their mark-up</cfoutput></cfif>
		<cfif appSettings.getPaymentCycleAtDiscountType()>
	<cfoutput><br>Payment Cycle:</cfoutput>
	<cf_payment_cycle_selection
		Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
		Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
		discount_Type_ID = "5"
		Selected_Payment_Cycle_ID = ""
		Action = "display"
		><cfoutput>#NewLine#</cfoutput>
	</cfif>
			<cfoutput>#NewLine##NewLine#</cfoutput>
			<CFIF getRules.recordcount GT 0>				
<CFOUTPUT QUERY="getRules" GROUP="Program_Formula_Pricing_Rule_Mapped_ID"><CFIF Formula_Pricing_Rule_ID EQ "">Rule is Inactive<CFELSE>#Trim(Rule_Name)#</CFIF>#newLine#<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfsilent>	</cfsilent>#claimHandle.TextAlignLeft(12,"UPC")#</cfif></cfif>#claimHandle.TextAlignLeft(12,"ITEM")##claimHandle.TextAlignLeft(18,"DESCRIPTION")#<cfif displayGroupType>#claimHandle.TextAlignLeft(15,trim(displayGroupTypeDesc))#</cfif>#claimHandle.TextAlignLeft(15,"ADJUSTMENT")#<cfset volumeapplicator="#Program_Volume.defaultUOT.getDesc()# Vol.">#claimHandle.TextAlignLeft(20,trim(volumeapplicator))##NewLine##RepeatString("-",90)##NewLine#<CFSET ProductCount = 0><CFOUTPUT><CFSET CurrentRowColor = IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))><Cfset ThisProductsID = BSA_Foodservice_Items_Master_ID><CFSET Total_Product_Volume = Program_Volume.GetProductVolume(ThisProductsID)><cfset item_volume="#numberformat(round(Total_Product_Volume), '___,___,__,__')# #getContractUOMLabel.Unit_Of_Measure_Desc#/#Program_Volume.defaultUOT.getNounDesc()#"><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#claimHandle.TextAlignLeft(12,Trim(UPC))#</cfif></cfif>#claimHandle.TextAlignLeft(12,Trim(ITEM))#<cfsilent><cfif Len(Trim(Description)) LT 15><cfset Desc = Trim(Description)><cfelse><cfset Desc = Left(Trim(Description),14)></cfif></cfsilent>#claimHandle.TextAlignLeft(18,Desc)#<cfif displayGroupType><cfsilent><cfset sDisplayGroupName = Left(Trim(DisplayGroupName),12)></cfsilent>#claimHandle.TextAlignLeft(15,sDisplayGroupName)#</cfif><cfset adjustment = "#trim(NumberFormat(Price, ViewProgramManager.getRateFormatMask()))# per Lb">#claimHandle.TextAlignLeft(15,adjustment)##claimHandle.TextAlignLeft(20,item_volume)##NewLine#</CFOUTPUT>#NewLine#</CFOUTPUT>
			</CFIF>
	</CFIF>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Bid Rules																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	
	<cfset BidProducts  = ViewProgramManager.BidProducts(CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
 	<CFIF BidProducts.Recordcount GT 0>
	
		<cfset GetValidProductsWithVolume  = ViewProgramManager.GetValidProductsWithVolume(CSLGetContractInfo.Contract_Main_ID)>
	
		<cfset listGetValidProductsWithVolume = valuelist(GetValidProductsWithVolume.BSA_Foodservice_Items_Master_ID)>
		<cfoutput>#NewLine##NewLine#Bid Pricing#NewLine#</cfoutput>
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfoutput>#claimHandle.TextAlignLeft(11,"UPC")#</cfoutput></cfif></cfif>	<cfoutput>#claimHandle.TextAlignLeft(11,"ITEM")#</cfoutput>						
<cfoutput>#claimHandle.TextAlignLeft(17,"DESCRIPTION")#</cfoutput>		
<cfif displayGroupType>	<cfoutput>#claimHandle.TextAlignLeft(15,trim(displayGroupTypeDesc))#</cfoutput>
</cfif>							<cfoutput>#claimHandle.TextAlignLeft(12,"Rate/Pound")#</cfoutput>	
<cfoutput>#claimHandle.TextAlignLeft(12,"Rate/Case")#</cfoutput>				
						
			<cfloop QUERY="BidProducts">
				<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><cfoutput>#claimHandle.TextAlignLeft(11,Trim(BidProducts.UPC))#</cfoutput></cfif></cfif>
<cfoutput>#claimHandle.TextAlignLeft(11,Trim(BidProducts.Item))#</cfoutput>
<cfif Len(Trim(BidProducts.Description)) LT 15>
<cfset Desc = Trim(BidProducts.Description)>
<cfelse>
<cfset Desc = Left(Trim(BidProducts.Description),15)>
</cfif>
<cfoutput>#claimHandle.TextAlignLeft(17,TRIM(Desc))#</cfoutput>
				<cfif displayGroupType>
				<cfset sDisplayGroupName = Left(Trim(DisplayGroupName),12)>				
<cfoutput>#claimHandle.TextAlignLeft(14,TRIM(sDisplayGroupName))#</cfoutput></cfif>
				<CFIF listfindnocase(listGetValidProductsWithVolume, BidProducts.BSA_Foodservice_Items_Master_ID) EQ 0>
					You must first assign a volume to this product
				<cfelse>
					<cfset price = "#trim(numberformat(BidProducts.Rate_LB, ViewProgramManager.getRateFormatMask()))# #trim(numberformat(BidProducts.Rate_CS, ViewProgramManager.getRateFormatMask()))#">
						<cfoutput>#claimHandle.TextAlignLeft(24,TRIM(price))#</cfoutput>
</CFIF>#newLine#
	</cfloop>
	</CFIF>
	
	
<!--- <CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
			<CFSET Program_Volume.Load_Basic_Information(CSLGetContractInfo.Contract_Main_ID, request.AccessStructure.Company_Main_ID)>
<CFSET Program_Volume.View_Program_Product_List_Txt()>
		<cfif application.returned_customer_setting.confidentiality_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.confidentiality_switch EQ 1>
	<cfoutput>#NewLine##NewLine##NewLine##NewLine##application.returned_customer_setting.confidentiality_content##newLine#</cfoutput>
	</cfif></cfif>
	<cfoutput></cfoutput> --->
