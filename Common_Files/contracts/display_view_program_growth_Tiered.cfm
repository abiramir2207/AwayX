<!-----------------------------------------------------------------------------

FILE NAME:		display_view_program_growth_Tiered.cfm
DESCRIPTION:
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao		28-Jun-2018		Created
------------------------------------------------------------------------------>
<style>
	div.noData { color: red; font-weight: bold; text-align: center;	}
</style>

<CFIF GetSettings.Discount_Growth EQ 1>
	<cfset getComponents  = ViewProgramManager.getgrowthComponents(CSLGetContractInfo.Contract_Main_ID,appSettings.getGrowthExpansion1())>

	<!--- D45016 :: Restrict access at component level for all discount types START--->
	<cfset useLakebaseForGetAllGrowthComponentsAccess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_component_profile")>
	<cfif useLakebaseForGetAllGrowthComponentsAccess>
		<cftry>
			<cfset getAllGrowthComponentsAccess = application.oLakebase.toQuery(
				application.oLakebase.selectRows("program_growth_component_profile", { "deleted" = "eq.false", "profiles_id" = "eq.#request.AccessStructure.Profiles_ID#", "allow_user_to_view" = "eq.1" })
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForGetAllGrowthComponentsAccess = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetAllGrowthComponentsAccess>
	<cfquery name="getAllGrowthComponentsAccess" datasource="#application.datasource#">
			SELECT 	*
			FROM		Program_Growth_Component_Profile
			WHERE	Deleted = 0
			AND 		Profiles_ID = #request.AccessStructure.Profiles_ID#
			AND 		Allow_User_To_View = 1
	</cfquery>
	</cfif>
	<cfset restictList = valuelist(getAllGrowthComponentsAccess.Program_Growth_Component_Name_ID)>
<cfif listlen(restictList)>
	<cfquery name="getComponents" dbtype="query" >
	SELECT *
	FROM getComponents
	WHERE Program_Growth_Components_Name_Id  NOT IN (#restictList#)
	</cfquery>
</cfif>
	<!--- D45016 :: Restrict access at component level for all discount types END--->
	<cfset varSaveContentVal = "" />
	<cfif getComponents.recordcount GT 0>
	<cfoutput>
	<TR>
		<TD COLSPAN="100%">
			<BR>
			<B><FONT SIZE="2" COLOR="Navy"><cfoutput>#Application.GrowthLabel#</cfoutput></FONT></B><!--- 29856:labels for Fixed Price, Rebate, Lump Sum, Growth --->
			<HR COLOR="Navy">
			<TABLE WIDTH="100%" CELLPADDING="0" CELLSPACING="0" border="0">
			<CFIF getComponents.recordcount GT 0>
				<CFLOOP QUERY="getComponents">

				<!--- If the Payee is the "Distributor" in the "Billback_Closing_Method" settings in the settings panel --->

				<cfif getComponents.Payee_Selection eq 1>
					<cfset qryDistributor = objDistributor.getDistributor(getComponents.Vendor_Master_ID)>
				<cfelse>
					<cfset qryVendor = objVendor.getVendorInfo(getComponents.Vendor_Master_ID)>
				</cfif>
				<cfif Program_Growth_Comparison_Period_UOM_ID eq 2>
					<cfset Growth_Comparison_Period_UOM = "sales dollars">
				<cfelse>
					<cfset Growth_Comparison_Period_UOM = "volume">
				</cfif>
				<cfparam name="HasSeperateVolume" default="0">

				<cfif appSettings.getGrowthExpansion1()>
					<cfif Program_Growth_Component_Type_ID IS 1>
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

				<cfquery name="GetGrowthCompInformation" datasource="#application.datasource#">
					SELECT	Payment_Type.Payment_Type_Name, Payment_Type.Restrict_From_Billback, Payment_Type.Is_Auto_Pay,
							Min_Purchase_Requirement, Min_Purchase_Value
						<!--- D58135 ::  Additional Component info displaye inside program START--->
						,Program_Growth_Components_Name.ID_on_ViewProgramPage
						,Program_Growth_Components_Name.DeductionAccount_on_ViewProgramPage
						,Program_Growth_Components_Name.PaymentAccount_on_ViewProgramPage
						,Program_Growth_Components_Name.External_ID
						,Program_Growth_Components_Name.Deduction_Account
						,Program_Growth_Components_Name.Payment_Account
						<!--- D58135 ::  Additional Component info displaye inside program END--->
						,Program_Growth_Components_Name.Program_Growth_Components_Name
					FROM 	Program_Growth_Components
					LEFT JOIN Payment_Type
					ON 		Payment_Type.Payment_Type_ID = Program_Growth_Components.Claim_Mechanics
					INNER JOIN Program_Growth_Components_Name
					ON 	Program_Growth_Components_Name.Program_Growth_Components_Name_ID = Program_Growth_Components.Program_Growth_Components_Name_ID
					WHERE 	Program_Growth_Components.Program_Growth_Component_ID = '#CurrentComponent_ID#'
				</cfquery>

					<cfset getComponentProducts  = ViewProgramManager.getComponentProducts(CurrentComponent_ID, CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
					<TR>
						<TD COLSPAN="100%">
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
				<cfif DistinctRate.Recordcount IS 1 AND DistinctRate.Rate IS 0 AND appsettings.getdisplayzerosviewprogram() eq 0 >
								&nbsp;
				<!---Display items/groups--->
				<cfelse>


				<cfset colheaders =''>
		<cfset headersvalue =''>
			<CFIF getComponents.Rate_Type EQ 1>
				<cfset colheaders ='Retroactive Rate'>
				<cfset headersvalue ="All eligible #Growth_Comparison_Period_UOM# will be paid at the highest tier's rate attained.">
			<CFELSE>
				<cfset colheaders ='Bracket Rate'>
				<cfset headersvalue ="#Growth_Comparison_Period_UOM# comprising each tier will be paid at the rate for that tier.">
			</CFIF>
			<cfif appSettings.getGrowthExpansion1()>
				<cfset colheaders =ListAppend(colheaders,'Type')>
				<cfset headersvalue= ListAppend(headersvalue,'#getComponents.Description#')>
			</cfif>
			<!---D46874 :: New Growth Option (Growth Calculation) START --->
			<CFQUERY NAME="GetAllContractInfo" datasource="#application.datasource#">
				SELECT	Growth_Auto_Pay
				FROM	Program_Control_Panel_Options
				WHERE 	ProgramControl_Panel_Options_ID = #CSLGetContractInfo.ProgramType_ID#
			</CFQUERY>
			<cfif GetAllContractInfo.Growth_Auto_Pay>
			<cfset colheaders =ListAppend(colheaders,'Growth Calculation')>
				<cfif getComponents.Growth_Calculation EQ 1>
					<cfset headersvalue= ListAppend(headersvalue,'Entire Program')>
				<cfelseif getComponents.Growth_Calculation EQ 2>
					<cfset headersvalue= ListAppend(headersvalue,'Each Distributor')>
				<cfelseif getComponents.Growth_Calculation EQ 3>
					<cfset headersvalue= ListAppend(headersvalue,'Each Planning Group')>
				<cfelse>
					<cfset headersvalue= ListAppend(headersvalue,'N/A')>
				</cfif>
				</li>
			</cfif>
			<!---D46874 :: New Growth Option (Growth Calculation) END--->

			<cfset colheaders =ListAppend(colheaders,'Paid to')>
			<cfset headersvalue =ListAppend(headersvalue,'#templateManager.getPaymentPaidToTypeDesc(paidToID = getComponents.Component_Paid_To, paidToDesc="")#')>
			<!--- PAYEE --->
			<cfif GetGrowthCompInformation.Is_Auto_Pay eq 1>
				<cfset colheaders=ListAppend(colheaders,'Payee')>
				<cfif getComponents.Vendor_Master_ID neq "">
					<cfif getComponents.Payee_Selection eq 1>
						<cfset headersvalue =ListAppend(headersvalue,'#qryDistributor.Name# (#qryDistributor.Shr_Ship_To#)')>
					<cfelse>
						<cfset headersvalue =ListAppend(headersvalue,'#qryVendor.Vendor_Name# (#qryVendor.Vendor_ID#)')>
					</cfif>
				<cfelse>
					<cfif getComponents.Vendor_Selection eq 2>
						<cfset headersvalue =ListAppend(headersvalue,'Pays each individually')>
					<cfelseif getComponents.Vendor_Selection eq 3>
						<cfset headersvalue =ListAppend(headersvalue,'Pays each planning group')>
					</cfif>
				</cfif>
			</cfif>
			<!--- PAYMENT CYCLE --->
			<cfif appSettings.getPaymentCycleAtDiscountType()>
				<cfset FORM.PaymentCycle = PaymentCycleManager.getPaymentCycle(CSLGetContractInfo.Contract_Main_ID, 4, getComponents.Program_Growth_Component_ID) />
				 <cfset paymentCycleDesc = paymentCycleManager.getPaymentCycleDescription(FORM.PaymentCycle)>
				 <cfif len(paymentCycleDesc)>
					<cfset colheaders=ListAppend(colheaders,'Payment Cycle')>
					<cfset headersvalue =ListAppend(headersvalue, #paymentCycleDesc#)>
				</cfif>
			</cfif>
			<!--- GL ACCOUNT --->
			<cfif appSettings.getGL_Account_On() AND len(getComponents.GL_Account_Desc)>
				<cfset colheaders=ListAppend(colheaders,#Application.GLAccountLabel#)>
				<cfset headersvalue =ListAppend(headersvalue,'#getComponents.GL_Account_Desc# (#getComponents.GL_Account#)')>
			</cfif>
			<!--- PAYMENT TYPE --->
			<cfif appSettings.getClaims_at_Comp_Level()>
				<cfif len(GetGrowthCompInformation.Payment_Type_Name)>
					<cfset colheaders=ListAppend(colheaders,'Claim Mechanic')>
					<cfset headersvalue =ListAppend(headersvalue,'#GetGrowthCompInformation.Payment_Type_Name#')>
				</cfif>
			</cfif>
			<!--- BILLBACK ACCESS --->
			<cfif len(trim(GetGrowthCompInformation.Restrict_From_Billback)) GT 0>
				<cfset colheaders=ListAppend(colheaders,'Available for Billbacks')>
				<cfif GetGrowthCompInformation.Restrict_From_Billback IS 1>
					<cfset headersvalue =ListAppend(headersvalue,'NO')>
				<cfelse>
					<cfset headersvalue =ListAppend(headersvalue,'YES')>
				</cfif>
			</cfif>
			<!--- Minimum $ Purchase --->
			<cfif GetSettings.Growth_Min_Purchase EQ 1 AND GetGrowthCompInformation.Min_Purchase_Requirement EQ 1>
				<cfset colheaders=ListAppend(colheaders,'Minimum $ Purchase')>
				<cfset headersvalue =ListAppend(headersvalue,'#dollarformat(GetGrowthCompInformation.Min_Purchase_Value)#')>
			</cfif>
			<!--- EXTERNAL ID --->
			<cfset ID = LabelComp.getGeneralLabels('Growth External ID')>
			<cfif application.returned_customer_setting.external_id_on EQ 1 AND GetGrowthCompInformation.ID_on_ViewProgramPage>
				<cfif len(GetGrowthCompInformation.External_ID)>
				<cfset colheaders=ListAppend(colheaders,#ID.General_Labels_Label#)>
				<cfset headersvalue =ListAppend(headersvalue,#GetGrowthCompInformation.External_ID#)>
				</cfif>
			</cfif>
			<!--- DEDUCTION ACCOUNT --->
			<cfset DeductionAccount = LabelComp.getGeneralLabels('Deduction Account')>
			<cfif GetGrowthCompInformation.DeductionAccount_on_ViewProgramPage>
				<cfif len(GetGrowthCompInformation.Deduction_Account)>
					<cfset colheaders=ListAppend(colheaders,#DeductionAccount.General_Labels_Label#)>
					<cfset headersvalue =ListAppend(headersvalue,#GetGrowthCompInformation.Deduction_Account#)>
				</cfif>
			</cfif>
			<!--- PAYMENT ACCOUNT --->
			<cfset PaymentAccount = LabelComp.getGeneralLabels('Payment Account')>
			<cfif GetGrowthCompInformation.PaymentAccount_on_ViewProgramPage>
				<cfif len(GetGrowthCompInformation.Payment_Account)>
					<cfset colheaders=ListAppend(colheaders,#PaymentAccount.General_Labels_Label#)>
					<cfset headersvalue =ListAppend(headersvalue,#GetGrowthCompInformation.Payment_Account#)>
				</cfif>
			</cfif>

<cfsavecontent variable="TiersInfo">
 	<cfset getComponentTiers  = ViewProgramManager.getComponentTiers(CSLGetContractInfo.Contract_Main_ID,CurrentComponent_ID)>
 	<cfset tierFormat = "___,___,___,___,___,___,___," />
	<cfif getComponents.component_UOM EQ 3 AND appSettings.getGrowthDecimal4PercentTier() EQ 1>
		<cfset tierFormat = "___,___,___,___,___,___,___.___" />
	</cfif>
	<!----Only do this for normal ones--->
	<cfif appSettings.getGrowthExpansion1() IS 0>
		<TABLE WIDTH="50%" CELLPADDING="1" CELLSPACING="0" border="0">
			<tr><td colspan="100%" align="left">&nbsp;&nbsp;<b>Component Name: #GetGrowthCompInformation.Program_Growth_Components_Name#</b></td></tr>
			<TR VALIGN="bottom">
				<!--- <cfif appSettings.getBonusInGrowthSwitch()> ---> <!--- 43234 Growth Template Settings --->
				<cfif GetSettings.Bonus_Field eq 1>
					<TD><B>Tiers</B></TD>
				</cfif>
				<TD ID="header" WIDTH="100%" ><B>#ViewProgramManager.CapFirst(Growth_Comparison_Period_UOM)# Range (#getComponents.component_UOM_Desc#)</B></TD>
				<!--- <cfif appSettings.getBonusInGrowthSwitch()> ---> <!--- 43234 Growth Template Settings --->
				<cfif GetSettings.Bonus_Field eq 1>
					<TD ID="header" WIDTH="130" NOWRAP ALIGN="left"><B>#Application.BonusLabel#</B></TD>
				</cfif>
			</TR>
			<tr><td colspan="100%"><em>Achieve these #Growth_Comparison_Period_UOM# tiers and earn the rate shown</em></td></tr>
			<CFLOOP QUERY="getComponentTiers">
			<TR>
				<!--- <cfif appSettings.getBonusInGrowthSwitch()> ---> <!--- 43234 Growth Template Settings --->
				<cfif GetSettings.Bonus_Field eq 1>
				<TD style="font-size: 11px;color:navy;" align="left" nowrap><strong>Tier #Tier_Number#:</strong></TD>
				</cfif>
				<TD style="font-size: 10px;">#trim(numberformat(val(getComponentTiers.Range_Start), tierFormat))# <cfif trim(getComponentTiers.Range_End) EQ "*"> or More<cfelse>to #trim(numberformat(val(getComponentTiers.Range_End), tierFormat))#</cfif></TD>
				<!--- <cfif appSettings.getBonusInGrowthSwitch()> ---> <!--- 43234 Growth Template Settings --->
				<cfif GetSettings.Bonus_Field eq 1>
					<TD style="font-size: 10px;" ALIGN="left"><cfif not summaryView>$ #trim(numberformat(getComponentTiers.Growth_Amount, '___,___,___,___,___,___,___'))#<cfelse>&nbsp;</cfif></TD>
				</cfif>
			</TR>
			</CFLOOP>
		</TABLE>
	<cfelseif appSettings.getGrowthExpansion1()>
		<cfif getComponents.Program_Growth_Component_Type_ID IS 1>
 		<TABLE WIDTH="60%" CELLPADDING="1" CELLSPACING="0" border="0">
			<tr><td colspan="100%" align="left"><b>Component Name: #GetGrowthCompInformation.Program_Growth_Components_Name#</b></td></tr>
			<TR VALIGN="bottom">
			<!--- <cfif appSettings.getBonusInGrowthSwitch()> ---> <!--- 43234 Growth Template Settings --->
				<TD ID="header" align="left" style="font-size:10px;">&nbsp;&nbsp;<B>#ViewProgramManager.CapFirst(Growth_Comparison_Period_UOM,1)# Range (#getComponents.component_UOM_Desc#)</B></TD>
			<!--- <cfif appSettings.getBonusInGrowthSwitch()> ---> <!--- 43234 Growth Template Settings --->
			<cfif GetSettings.Bonus_Field eq 1>
				<TD ID="header" WIDTH="130" NOWRAP align="left" style="font-size:10px;"><B>#Application.BonusLabel#</B></TD>
			</cfif>
				<TD ID="header" WIDTH="130" NOWRAP align="left" style="font-size:10px;"><b>Rate</b></td>
			</TR>
			<!--- <TR>
				<TD COLSPAN="100%">	<em>Achieve these #Growth_Comparison_Period_UOM# tiers and earn the rate shown</em></TD>
			</TR> --->
			<cfset iLoopCount = 1 />
			<CFLOOP QUERY="getComponentTiers">
				<!--- TYSON will enter the same rate for all the groups or products belonging to the same TIER and so displaying rates above the actual group/products
					will actually work for TYSON.
				--->
				<cfquery name="GrowthRate" datasource="#application.datasource#">
					SELECT DISTINCT Rate, uom.abbreviation
					 FROM Program_Growth_Component_Product_Tier_Data pgc
					 		INNER JOIN Units_of_Measure uom ON uom.Unit_of_measure_ID = pgc.Unit_of_measure_ID
						WHERE Program_Growth_Component_Tier_ID = '#getComponentTiers.Program_Growth_Component_Tier_ID#'
							AND pgc.deleted = 0
				</cfquery>
			<TR>
			<!--- <cfif appSettings.getBonusInGrowthSwitch()> ---> <!--- 43234 Growth Template Settings --->
				<TD style="font-size: 10px;">
					<cfif GetSettings.Bonus_Field eq 1>
						&nbsp;&nbsp;<strong style="color:navy;">Tier #Tier_Number#:</strong>
					<cfelse>
						&nbsp;&nbsp;<strong style="color:navy;">Tier #iLoopCount#:</strong>
					</cfif>
					&nbsp;&nbsp;#trim(numberformat(val(getComponentTiers.Range_Start), tierFormat))#
					<cfif trim(getComponentTiers.Range_End) EQ "*">
						or More
					<cfelse>
						to #trim(numberformat(val(getComponentTiers.Range_End), tierFormat))#
					</cfif>
				</TD>
			<!--- <cfif appSettings.getBonusInGrowthSwitch()> ---> <!--- 43234 Growth Template Settings --->
			<cfif GetSettings.Bonus_Field eq 1>
				<TD style="font-size: 10px;" align="left">
					<cfif not summaryView>
						$ #trim(numberformat(getComponentTiers.Growth_Amount, '___,___,___,___,___,___,___'))#  / #GrowthRate.Abbreviation#
					<cfelse>
						&nbsp;
					</cfif>
				</TD>
			</cfif>
				<TD style="font-size: 10px;" align="left">
					<cfif not summaryView>
						$ #trim(numberformat(GrowthRate.Rate,'9.99999'))# / #GrowthRate.Abbreviation#
					<cfelse>
						&nbsp;
					</cfif>
				</TD>
			</TR>
			<cfset iLoopCount++ />
			</CFLOOP>
		</TABLE><br>
		<!---It's a stairway or X of Y--->
		<cfelse>
 		<!---Target information--->
		<cfset GetTargets  = ViewProgramManager.GetTargets(getComponents.Program_Growth_Component_ID)>
		<TABLE WIDTH="100%" CELLPADDING="1" CELLSPACING="0" border="0">
		<TR VALIGN="bottom">
			<TD ID="header" WIDTH="100%" STYLE="border-bottom:solid 93BEE2 1px;"><B>Targets</B></TD>
			<TD ID="header" WIDTH="130" NOWRAP STYLE="border-bottom:solid 93BEE2 1px;" ALIGN="RIGHT">&nbsp; </TD>
		</TR>
		<!--- <TR><TD COLSPAN="100%"><em>Achieve these volume targets and earn the rate shown on the rate items</em></TD></TR> --->
		<CFLOOP QUERY="getTargets">
		<TR>
			<TD style="font-size: 10px;" bgcolor="lightsteelblue">#GetTargets.Target_Order#) #GetTargets.Component_Name#</TD>
			<TD style="font-size: 10px;" ALIGN="RIGHT" bgcolor="lightsteelblue">#GetTargets.Range_End#  #GetTargets.Abbreviation#</TD>
			<cfif isnumeric(GetTargets.Growth_Amount)><TD style="font-size: 10px;" ALIGN="RIGHT" bgcolor="lightsteelblue"><cfif not summaryView>#dollarformat(GetTargets.Growth_Amount)#<cfelse>&nbsp;</cfif></TD></cfif>
		</TR>
		<!---Get items for this target--->
		<cfset TargetItems  = ViewProgramManager.TargetItems(GetTargets.Program_Growth_Component_ID)>
		<cfif TargetItems.Recordcount GT 0>
		<TR>
			<TD COLSPAN="100%">
			<TABLE CELLSPACING="0" CELLPADDING="0" WIDTH="100%">
			<CFLOOP QUERY="TargetItems">
				<TD CLASS="dataStyle" NOWRAP WIDTH="33%" VALIGN="top" BGCOLOR="F2F2F2" >
				<span>
					<FONT SIZE="1">#trim(TargetItems.Description)#<BR>#TargetItems.Item#</FONT>
				</span>
				</TD>
				<CFIF TargetItems.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
			</CFLOOP>
			</TABLE>
			</TD>
		</TR>
		</cfif>
		</CFLOOP>
		</TABLE>
		</cfif>
	</cfif>
</cfsavecontent>
	<cfloop from="1" to="#listlen(colheaders)#" index="headers">
		<cfif headers EQ 1>
			<!--- <td style="width:40%" rowspan="#listlen(colheaders)#"> ---><cfoutput>#TiersInfo#</cfoutput><!--- </td> --->
		</cfif>
	</cfloop>

<!---In case this is just rate, and not volume--->
<cfif HasSeperateVolume IS 1>
<strong>Rate Items:</strong>
</cfif>

<cfset ExistingPricingLevelList = "">
<cfset growthProdMod = 1 />
<cfset zeroEXRow = 1 />
<cfset EXInfoRow = 1 />

<TABLE WIDTH="100%" CELLPADDING="0" CELLSPACING="5" border="0" ALIGN="center" >
	<tr>
				<td width="50%" valign="top">
							<table class="Maintable" width="100%" cellpadding="3" cellspacing="0" border="0">
							<!--- TABLE HEADERS --->
							<TR BGCOLOR="##FFCE84" VALIGN="bottom">
								<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
									<cfif application.returned_customer_setting.upc_switch EQ 1>
										<TD ID="header" width="225px"><B>#REReplace(application.returned_customer_setting.upc_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B></TD>
									</cfif>
								</cfif>
								<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
								<TD ID="header" width="125px"><B>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B></TD>
								</cfif>
								<TD ID="header"><B>Description</B></TD>

								<cfif summaryView>
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
										<cfif application.returned_customer_setting.upc_switch EQ 1>
											<TD ID="header"><B>#REReplace(application.returned_customer_setting.upc_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B></TD>
										</cfif>
									</cfif>
									<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
									<TD ID="header"><B>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B></TD>
									</cfif>
									<TD ID="header"><B>Description</B></TD>
								</cfif>
								<cfif displayGroupType>
									<TD ID="header">&nbsp;</TD>
								</cfif>
								<cfif not summaryView>
									<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
									<TD ID="header"><B>Similar Product</B></TD>
									</cfif>
									<!--- <TD ID="header" WIDTH="130" STYLE="border-bottom:solid 93BEE2 1px;" ALIGN="left" nowrap colspan="2"><B>#GetGrowthCompInformation.Program_Growth_Components_Name#</B></TD> --->
								</cfif>
							</TR>

							<!--- TABLE DATA QUERY --->
							<!---TSF: Label D6588 --->

							<cfset BgCol_PricingLevel = 0 />
							<cfif summaryView><cfset productCount = 0 ><TR BGCOLOR="F2F2F2"></cfif>
							<CFLOOP QUERY="getComponentProducts">
								<CFSET CurrentProduct = getComponentProducts.Contract_Products_ID>
								<CFSET Current_Product_Pricing_Level_ID = getComponentProducts.Pricing_Level_ID>
								<!---TSF: Label D6588 --->
								<!---check the sum of the tiers. if they aren't > 0, then don't display the procuct--->
								<cfif 1 eq 1>
									<cfset getComponentProductTierData  = ViewProgramManager.getComponentProductTierData(CSLGetContractInfo.Contract_Main_ID,CurrentProduct)>
									<!--- DATA OUTPUT --->
									<cfparam name="BgCol_1" default="C6FFC6">
									<cfparam name="BgCol_2" default="FFFFFF">

									<CFSET ThisProductsID = getComponentProducts.BSA_Foodservice_Items_Master_ID>
									<cfset This_Product_Group_Level_ID = getComponentProducts.Product_Group_Level_ID>

									<!---onmouseover menuId--->
									<cfif getComponentProducts.Is_Group eq 1>
										<cfset request.menuId = 11 />
										<cfset request.theMOId = "#getComponentProducts.Product_Group_ID#&Group_Level_ID=#getComponentProducts.Product_Group_Level_ID#&programId=#CSLGetContractInfo.Contract_Main_ID#&producttype_id=4" />
									<cfelse>
										<cfset request.menuId = 6 />
										<cfset request.theMOId = ThisProductsID />
									</cfif>
									<cfif not summaryView>
									<cfset thisGroupLevelDesc = GroupDataManager.getProductGroupsData(This_Product_Group_Level_ID).Group_Level_Desc />
									<cfif trim(thisGroupLevelDesc) eq "">
										 <cfset thisGroupLevelDesc = "Product" />
									</cfif>
									<cfif (len(trim(getComponentProductTierData.Rate)) NEQ 0 AND getComponentProductTierData.Rate NEQ 0)>
										<!--- Dev Note (77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to "ExistingPricingLevelList".
										This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
										Note: we set "growthProdMod" back to 1, so that the color coding can restart for a new group.
										thisGroupLevelDesc i.e., "group_level_desc" is shown on a single row.
										--->
										<cfif ListFind(ExistingPricingLevelList,Current_Product_Pricing_Level_ID) eq 0>
											<cfset growthProdMod = 1 />
											<TR bgcolor="##92B792">
												<TD colspan="100%">#thisGroupLevelDesc#</TD>
											</TR>
											<cfset ExistingPricingLevelList = ListAppend(ExistingPricingLevelList,Current_Product_Pricing_Level_ID)>
										</cfif>

										<CFSET CurrentRowColor = IIf(growthProdMod Mod 2, DE(BgCol_1), DE(BgCol_2)) >

										<TR BGCOLOR="#CurrentRowColor#" VALIGN="top"<cfif getComponentProducts.Is_Group eq 1 or (This_Product_Group_Level_ID EQ 0 OR This_Product_Group_Level_ID EQ "")> ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"</cfif>>
											<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
												<cfif application.returned_customer_setting.upc_switch EQ 1>
													<TD STYLE="border-bottom: 0px;" >#getComponentProducts.UPC#</TD>
												</cfif>
											</cfif>
											<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
											<TD STYLE="border-bottom: 0px;width:125px" >#getComponentProducts.ITEM#</TD>
											</cfif>
											<TD STYLE="border-bottom: 0px;" >
												<cfif getComponentProducts.is_group EQ 1>
												<cfset getHierarchyLevelDetails = GroupDataManager.getHierarchyLevel(prodGroupId=getComponentProducts.product_group_id, addParentName=2) />
												<cfif getHierarchyLevelDetails.Group_Level_Desc NEQ "">
												#getHierarchyLevelDetails.Group_Level_Desc# <cfelse>#getComponentProducts.DESCRIPTION#
												</cfif>
												<cfelse>
												#getComponentProducts.DESCRIPTION#
												</cfif><cfif appsettings.getShowBrandOnViewProgram() EQ 1><br>#getComponentProducts.Brand_Name#</cfif>
												<!--- D36277	Add brand to program view END--->
											</TD>
											<cfset currentNetWeight = getComponentProducts.Net_Weight />
											<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
											<TD  STYLE="border-bottom: 0px;">
												<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(CSLGetContractInfo.Contract_Main_ID,ThisProductsID)>
												<cfif SimilarExistingProduct.Recordcount neq 0>Yes<cfelse>No</cfif>
											</TD>
											</cfif>
										</TR>
										<cfset growthProdMod = growthProdMod + 1 />
										<cfelse>
										<!--- <cfsavecontent variable="zeroExclusions"> --->
										<cfif EXInfoRow>
											<cfset EXInfoRow = 0>
										<tr>
											<td colspan="100">
												<strong><u>Exclusions</u></strong>	&nbsp;&nbsp;&nbsp; (There is a $0 pay out rate for below groups/products)<br>
											</td>
										</tr>
										</cfif>
										<cfset zeroEXRow = zeroEXRow + 1>
										<!--- Dev Note (77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to "ExistingPricingLevelList".
										This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
										Note: we set "zeroEXRow" back to 1, so that the color coding can restart for a new group.
										thisGroupLevelDesc i.e., "group_level_desc" is shown on a single row.
										--->
										<cfif ListFind(ExistingPricingLevelList,Current_Product_Pricing_Level_ID) eq 0>
											<cfset zeroEXRow = 1 />
											<TR bgcolor="##92B792">
												<TD colspan="100%">#thisGroupLevelDesc#</TD>
											</TR>
											<cfset ExistingPricingLevelList = ListAppend(ExistingPricingLevelList,Current_Product_Pricing_Level_ID)>
										</cfif>

										<cfset CurrentZeroEXRowColor = IIf(zeroEXRow Mod 2, DE(BgCol_1), DE(BgCol_2)) >

											<TR BGCOLOR="#CurrentZeroEXRowColor#" VALIGN="top"<cfif getComponentProducts.Is_Group eq 1 or (This_Product_Group_Level_ID EQ 0 OR This_Product_Group_Level_ID EQ "")> ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"</cfif>>
											<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
												<cfif application.returned_customer_setting.upc_switch EQ 1>
													<TD STYLE="border-bottom: 0px;" WIDTH="40">#getComponentProducts.UPC#</TD>
												</cfif>
											</cfif>
											<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
											<TD STYLE="border-bottom: 0px;" WIDTH="35">#getComponentProducts.ITEM#</TD>
											</cfif>
											<TD STYLE="border-bottom: 0px;" WIDTH="80">
												<cfif getComponentProducts.is_group EQ 1>
													<cfset getHierarchyLevelDetails = GroupDataManager.getHierarchyLevel(prodGroupId=getComponentProducts.product_group_id, addParentName=2) />
													<cfif getHierarchyLevelDetails.Group_Level_Desc NEQ "">
														#getHierarchyLevelDetails.Group_Level_Desc#
													<cfelse>
														#getComponentProducts.DESCRIPTION#
													</cfif>
												<cfelse>
													#getComponentProducts.DESCRIPTION#
												</cfif>
												<cfif appsettings.getShowBrandOnViewProgram() EQ 1><br>#getComponentProducts.Brand_Name#</cfif>
												<!--- D36277	Add brand to program view END--->
											</TD>
											<cfset currentNetWeight = getComponentProducts.Net_Weight />
											<cfif displayGroupType>
												<TD STYLE="border-bottom: 0px;" WIDTH="90">#DisplayGroupName#</TD>
											</cfif>
											<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
											<TD  STYLE="border-bottom: 0px;">
												<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(CSLGetContractInfo.Contract_Main_ID,ThisProductsID)>
												<cfif SimilarExistingProduct.Recordcount neq 0>Yes<cfelse>No</cfif>
											</TD>
											</cfif>

										</TR>
										<!--- </cfsavecontent>
											<cfset varSaveContentVal = varSaveContentVal & zeroExclusions /> --->
										</cfif>
									<cfelse>
										<cfif productCount Mod 2 EQ 0>
											</tr>
											<TR BGCOLOR="F2F2F2" VALIGN="top"<cfif getComponentProducts.Is_Group eq 1 or (This_Product_Group_Level_ID EQ 0 OR This_Product_Group_Level_ID EQ "")> ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"</cfif>>
										</cfif>
										<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
											<cfif application.returned_customer_setting.upc_switch EQ 1>
												<!--- <TD STYLE="border-bottom:solid 93BEE2 1px;" >#getComponentProducts.UPC#</TD> --->
												 <TD WIDTH="60">#getComponentProducts.UPC#</TD>
											</cfif>
										</cfif>
										<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
										<TD WIDTH="100">#getComponentProducts.ITEM#</TD>
										</cfif>
										<TD WIDTH="100">
											#getComponentProducts.DESCRIPTION#<br>#getComponentProducts.Brand_Name#
										</TD>
										<cfset productCount = productCount + 1 >
									</cfif>


								</cfif>
							</CFLOOP>
							</TR>
						</TABLE>
					</td>
			</tr>
		</table>

						</cfif>
						<CFELSE>
							<div class="noData">NO PRODUCTS SUPPLIED</div>
						</CFIF>
						</TD>
					</TR>




	<tr><td colspan="100%">&nbsp;</td></tr>
	
	<cfset colheaders=ListAppend(colheaders,#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#& ' Count')>
	<cfset headersvalue =ListAppend(headersvalue,#getComponentProducts.recordCount#)>

	<cfloop from="1" to="#listlen(colheaders)#" index="headers">
			<tr>
				<td style="width:60%">
					<li>#listgetat(colheaders,headers)# : #listgetat(headersvalue,headers)#</li>
				</td>
				<!--- <cfif headers EQ 1>
					<td style="width:40%" rowspan="#listlen(colheaders)#"><cfoutput>#TiersInfo#</cfoutput></td>
				</cfif> --->
			</tr>
	</cfloop>

				</CFLOOP>
			<CFELSE>
				<TR>
					<TD COLSPAN="100%" ALIGN="center"><B><FONT COLOR="Red">NONE SUPPLIED</FONT></B></TD>
				</TR>
			</CFIF>
			</TABLE>
		</TD>
	</TR>

	</cfoutput>
	<!------ Start Clause Code ----->
	<cfset getProgramClause = clauseProgramManager.getProgramClause(CSLGetContractInfo.Contract_Main_ID, 2, 4)>
	<cfif getProgramClause.recordCount>
	<cfoutput><TR>
		<TD COLSPAN="100%">
		<BR>
		<!------ Growth Clauses ----->
		<cfinclude template="/Clause_Library/clause_program_display.cfm">
		</TD>
	</TR></cfoutput>
	</cfif>
	<!------ End  Clause Code ----->
	</cfif>
	</CFIF>