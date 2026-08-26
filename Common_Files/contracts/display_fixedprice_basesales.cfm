<cfparam name="url.Program_ID" default="0">
<cfparam name="url.List_Of_Contract_Main_IDs" default="">
<cfinclude template="/script/cf/string_functions.cfm">
<cfif url.Program_ID NEQ "" and url.Program_ID NEQ 0>
<cfsilent>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset ViewProgramManager = CreateObject("component", "components.programs.Display_Program.viewprogramtemplateManager") />
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<!--- <cfset appSettings = genSettingsManager.get()> --->
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />
<cfset displayGroupTypeDesc = genSettingsManager.settings.getViewProgramProductGroupTypeDesc() />

<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT 	
			Contract_Main.*,
			Contract_Main_Aux_Data.Like_Product_Exist,
			Program_Control_Panel_Options.Date_Exclusions_ON
	FROM 	Contract_Main
	LEFT JOIN Contract_Main_Aux_Data
	ON		Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
	INNER JOIN	Program_Control_Panel_Options
	ON 		Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE 	Contract_Main.Contract_Main_ID = '#url.program_id#'
</CFQUERY>

			<cfif url.List_Of_Contract_Main_IDs neq "">
				<cfset getFixedPriceProducts  = ViewProgramManager.getFixedPriceProducts(url.List_Of_Contract_Main_IDs, displayGroupType,1,1,appSettings.getBidRequestUsePriceByDate(),
appSettings.getUseItemCustPrice())>
			<cfelse>
				<cfset getFixedPriceProducts  = ViewProgramManager.getFixedPriceProducts(url.Program_ID, displayGroupType,0,1,appSettings.getBidRequestUsePriceByDate(),appSettings.getUseItemCustPrice())>
			</cfif>
</cfsilent>
<cfif getFixedPriceProducts.recordcount GT 0>
				<cfif appSettings.getfixedcomponents_on()>
<!--- List_Of_Contract_Main_IDs will be always blank if GetSettings.Date_Exclusions_ON eq 0 --->
					<cfif List_Of_Contract_Main_IDs eq "">
						<cfset getcompNames  = ViewProgramManager.getcompNames(url.Program_ID,"0")>
					<cfelse>
						<cfset getcompNames  = ViewProgramManager.getcompNames(url.List_Of_Contract_Main_IDs,"1")>
					</cfif>
				</cfif>
<CFIF getFixedPriceProducts.recordcount GT 0>
<cfoutput>
<B><FONT SIZE="2" COLOR="Navy">Fixed Pricing - Base Sales at time of Approval</FONT></B>
<HR COLOR="Navy">
<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">	
					<!--- TABLE HEADERS --->
	<THEAD>
					<TR BGCOLOR="##FFCE84" VALIGN="bottom">
						<TD ID="header" WIDTH="75" valign="top"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>UPC/</cfif></cfif>ITEM</B></TD>
						<TD ID="header" WIDTH="250" valign="top"><B>DESCRIPTION</B><cfif displayGroupType>/ <B>#displayGroupTypeDesc#</B></cfif></TD>
						<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
							<TD ID="header" WIDTH="35" valign="top"><B>Similar Product</B></TD>
						</cfif>
						<!--- <cfif not summaryView> --->
							<cfif CSLGetContractInfo.Date_Exclusions_ON EQ 1>
								<TD ID="header" valign="top"><B>Date</B></TD>
							</cfif>
							<cfset CompList ="">
							<cfif appSettings.getfixedcomponents_on()>		
							<cfquery name="getdistinctcompnames" dbtype="query">
								select distinct Program_Fixed_Component_Name,
								Fixed_Component_Paid_to
								from getcompNames 
								order by Program_Fixed_Component_Name,Program_Fixed_Component_ID
							</cfquery>				
			
							<CFLOOP query="getcompNames">
								<cfif CSLGetContractInfo.Date_Exclusions_ON EQ 0 OR getcompNames.Contract_Main_ID eq CSLGetContractInfo.Contract_Main_ID>					
									<!--- Do not repeat the Component Entries (commented out the code) --->
									<cfif ListFindNoCase(CompList,getcompNames.Program_Fixed_Component_ID) eq 0>
										<cfset CompList = ListAppend(CompList,getcompNames.Program_Fixed_Component_ID)>
									</cfif>
								</cfif>
								</cfloop>
								<CFLOOP query="getdistinctcompnames">
								
							<TD ID="header" valign="top"><strong>Base<br>Sales</strong></TD>
							<TD ID="header" valign="top"><strong><cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>Discount<cfelse>Allow</cfif></strong></TD>
								<TD ID="header" valign="top"><B><cfoutput>#getdistinctcompnames.Program_Fixed_Component_Name#</cfoutput>
								<br>#templateManager.getPaymentPaidToTypeDesc(paidToID = getdistinctcompnames.Fixed_Component_Paid_to, paidToDesc="")#</B></TD>
							<TD ID="header" valign="top"><strong>Discount%</strong></TD>
								</CFLOOP>	

							<cfelse>
								<TD ID="header" WIDTH="130" ALIGN="RIGHT" valign="top"><B>Price</B></TD>
							</cfif>
						
					</TR>
					</THEAD>
					</cfoutput>
<cfif CSLGetContractInfo.Date_Exclusions_ON eq 0>
						<cfset List_Of_Contract_Main_IDs = CSLGetContractInfo.Contract_Main_ID>
					<cfelse>
						<cfset List_Of_Contract_Main_IDs = Replace(List_Of_Contract_Main_IDs,"'","","ALL")>
					</cfif>
					<cfset LoopCount = 0>
		<CFOUTPUT QUERY="getFixedPriceProducts" group="BSA_Foodservice_Items_Master_ID">
							<cfset LoopCount =LoopCount + 1>
							<cfoutput group="CONTRACT_MAIN_ID">
							<cfset ContractID = getFixedPriceProducts.CONTRACT_MAIN_ID>
							<!--- <cfloop list="#List_Of_Contract_Main_IDs#" index="ContractID"> ---> 
							<CFSET item_num= getFixedPriceProducts.BSA_Foodservice_Items_Master_ID>
							<CFSET Contract_ID= getFixedPriceProducts.CONTRACT_MAIN_ID>
							<CFSET IsExclusionRevision= getFixedPriceProducts.IsExclusionRevision>
							<TR  BGCOLOR="#IIf(LoopCount Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#getFixedPriceProducts.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
								<TD ID="">
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
										<cfif application.returned_customer_setting.upc_switch EQ 1>#getFixedPriceProducts.UPC#<br></cfif>
									</cfif>#getFixedPriceProducts.ITEM#
								</TD>
								<TD ID="">#getFixedPriceProducts.Description#
								<!--- <cfif displayGroupType and not summaryView> --->
								<cfif displayGroupType>
								<br>	#DisplayGroupName#
								</cfif></TD>

								<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
								<TD ID="">		
								<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(CSLGetContractInfo.Contract_Main_ID,item_num)>
									<cfif SimilarExistingProduct.Recordcount neq 0>Yes<cfelse>No</cfif>
								</TD>
								</cfif>
								<cfif appSettings.getfixedcomponents_on()>
								
								<cfset ContractDate = "">
								<cfset FixedPriceList = "">
								 <CFLOOP query="getcompNames">
								<cfif CSLGetContractInfo.Date_Exclusions_ON EQ 0>
									<cfset TotalFixedComponentIDList =  ViewProgramManager.getFixedComponentIDs(ContractID,item_num)>						
									<!--- Get the fixedproductprice for the Different contracts, by passing the ContractID too in the  getfixedproductprice function --->
									<cfset getfixedproductprice  = ViewProgramManager.getfixedproductprice(getFixedPriceProducts,getcompNames.Program_Fixed_Component_ID,item_num,ContractID)>

									<cfelse>
				
										<cfset TotalFixedComponentIDList =  ViewProgramManager.getFixedComponentIDs(ContractID,item_num)>

										<cfset getfixedproductprice  = ViewProgramManager.getfixedproductprice(getFixedPriceProducts,getcompNames.Program_Fixed_Component_ID,item_num,ContractID)>
						
													
																						
					<!--- Do not repeat the Date --->
										<cfif getfixedproductprice.Fixed_Price_Value NEQ "">																		
											<cfif getfixedproductprice.Contract_Start_Date&getfixedproductprice.Contract_End_Date neq ContractDate> 
												<cfset ContractDate = getfixedproductprice.Contract_Start_Date&getfixedproductprice.Contract_End_Date>
						
											<cfif getfixedproductprice.IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
											<TD>#DateFormat(getfixedproductprice.Contract_Start_Date,"MM/DD/YYYY")#<br/> #DateFormat(getfixedproductprice.Contract_End_Date,"MM/DD/YYYY")#</TD>
																		
											<cfelse>
										<TD ID="">

								<!--- If there are Date Exclusions --->	
								<cfif ListLen(List_Of_Contract_Main_IDs) GT 1>
								<!--- Show the Contract Start Date --->
								<cfif DECount EQ 0>
								#DateFormat(getDateExclusionprogramIDs.Contract_Start_Date, "MM/DD/YYYY")#<br /></cfif>
								<!--- Delete the ParentID from the list and loop through the date exclusion ID's (Loop through the years, Month and Days)--->
								<cfset Date_Exclusion_Contract_Main_IDs = ListDeleteAt(List_Of_Contract_Main_IDs,1)>
								<cfset DateExclusionDate = GenProgramManager.DateExclusionDates(Date_Exclusion_Contract_Main_IDs)>
								<cfloop query="DateExclusionDate">
									<cfloop from="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_Start_Date)#" to="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_End_Date)#" index="IndexYear">
										<cfloop from="1" to="12" index="IndexMonth">
											<cfloop from="1" to="31" index="IndexDay">		
												<cfset DayDate = "#IndexMonth#/#IndexDay#/#IndexYear#">
													<cfif IsDate(DayDate)>
														<!--- If the date in the loop matches the date exclusion start date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date) eq 0>
															<!--- If it's not the first row --->
															<cfif DateExclusionDate.currentrow neq 1>
																<!--- If there is a days difference in the previous date exclusion end date and current date exclusion start date --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date[DateExclusionDate.currentrow-1]) GT 0>
																#DateFormat(Before_Date_Exclusion_Contract_Start_Date, "MM/DD/YYYY")#<br /><br />
																</cfif>
															 <cfelse>

<cfif DECount EQ 0>															#DateFormat(DateAdd('d',-1,Contract_Start_Date),"MM/DD/YYYY")#<br /><br /></cfif>
															</cfif> 
														</cfif>
													<!--- If the date in the loop matches the date exclusion end date --->
														 <cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
														<!--- If it's not the last row --->
															<cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
														<!--- If there is a days difference in the current date exclusion end date and the following date exclusion start date, get that info --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																	#DateFormat(After_Date_Exclusion_Contract_End_Date, "MM/DD/YYYY")#<br />
																	#DateFormat(Before_Date_Exclusion_Contract_Start_Date[DateExclusionDate.currentrow+1], "MM/DD/YYYY")#<br /><br />			
																</cfif>
													
															<cfelse>
														
															<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
																<cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																#DateFormat(DateAdd('d',1,Contract_End_Date),"MM/DD/YYYY")#<br />
																#DateFormat(getDateExclusionprogramIDs.Contract_End_Date, "MM/DD/YYYY")#
																</cfif>
													</cfif>
													</cfif>
												</cfif>
											</cfloop>
										</cfloop>
									</cfloop>
								</cfloop>
								</cfif>
								</TD>
										</cfif>
										</cfif>
										</cfif>
									</cfif>
								</CFLOOP> 
								
			<cfset getcurrentcompNames  = ViewProgramManager.getcompNames(ContractID,"0")>
			<cfparam name="getcopmcount" default="0">
			 <cfloop query ="getcurrentcompNames">
			 <cfsilent>
			 <cfset getcurrentfixedproductprice  = ViewProgramManager.getfixedproductprice(getFixedPriceProducts,getcurrentcompNames.Program_Fixed_Component_ID,item_num,ContractID)>
			<cfif getcurrentfixedproductprice.recordcount EQ 0>
				<cfset currentfixedvalue = 0>
			<cfelse>
				<cfif getcurrentfixedproductprice.Fixed_Price_Value EQ "">
				<cfset currentfixedvalue = 0>
				<cfelse>
				<cfset currentfixedvalue = getcurrentfixedproductprice.Fixed_Price_Value>
				</cfif>
			</cfif>
			<cfsavecontent variable="fixeddisplayvalue">
			<cfif currentfixedvalue neq 0>
#trim(numberformat(currentfixedvalue, ViewProgramManager.getRateFormatMask()))#/#left(getcurrentfixedproductprice.Abbreviation, 2)# <cfif appSettings.getPgmDisplayBothRateUOM() AND (getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 1 OR getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 2)>
			<br>#trim(numberformat(ViewProgramManager.getRateInUOM(currentfixedvalue, getcurrentfixedproductprice.Unit_Of_Measure_ID, getcurrentfixedproductprice.Net_Weight), ViewProgramManager.getRateFormatMask()))#/#ViewProgramManager.getTheOtherUOMDesc(getcurrentfixedproductprice.Unit_Of_Measure_ID)#
			</cfif><cfelse><cfif appsettings.getdisplayzerosviewprogram()>0.0000/#left(getcurrentfixedproductprice.Abbreviation, 2)# <cfelse>&nbsp;</cfif></cfif></cfsavecontent>
			
			</cfsilent>
		<cfsilent>
	<cfset getfixedbaseprice  = ViewProgramManager.getfixedbaseprice(getFixedPriceProducts,getcurrentcompNames.Program_Fixed_Component_ID,item_num)>
<cfset allow = getfixedbaseprice.Approved_Base_Sales - getfixedbaseprice.Fixed_Price_Value>
<cfif getfixedbaseprice.Approved_Base_Sales NEQ 0>
<cfset discount_percent = ((getfixedbaseprice.Approved_Base_Sales - getfixedbaseprice.Fixed_Price_Value)/getfixedbaseprice.Approved_Base_Sales) * 100>
<cfelse>
<cfset discount_percent = 0>
</cfif>
							</cfsilent>
			<TD>
						#trim(numberformat(getfixedbaseprice.Approved_Base_Sales, ViewProgramManager.getRateFormatMask()))#
						</TD>
			<td>
			<cfif allow LT 0>
			<cfset allowneg = allow * -1>
			#Negativeformat(numberformat(allowneg, ViewProgramManager.getRateFormatMask()))#
			<cfelse>
			#trim(numberformat(allow, ViewProgramManager.getRateFormatMask()))#
			</cfif>
</td>
			<td>
			<cfif getcurrentfixedproductprice.IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
	#fixeddisplayvalue#
																		
											<cfelse>
			<!--- If there are Date Exclusions --->	
								<cfif ListLen(List_Of_Contract_Main_IDs) GT 1>
								<!--- Show the Contract Start Date --->
								<!--- Delete the ParentID from the list and loop through the date exclusion ID's (Loop through the years, Month and Days)--->
								<cfset Date_Exclusion_Contract_Main_IDs = ListDeleteAt(List_Of_Contract_Main_IDs,1)>
<cfset DateExclusionDate = GenProgramManager.DateExclusionDates(Date_Exclusion_Contract_Main_IDs)>
			<cfloop query="DateExclusionDate">
									<cfloop from="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_Start_Date)#" to="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_End_Date)#" index="IndexYear">
										<cfloop from="1" to="12" index="IndexMonth">
											<cfloop from="1" to="31" index="IndexDay">		
												<cfset DayDate = "#IndexMonth#/#IndexDay#/#IndexYear#">
													<cfif IsDate(DayDate)>
														<!--- If the date in the loop matches the date exclusion start date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date) eq 0>
															<!--- If it's not the first row --->
															<cfif DateExclusionDate.currentrow neq 1>
																<!--- If there is a days difference in the previous date exclusion end date and current date exclusion start date --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date[DateExclusionDate.currentrow-1]) GT 0>
																#fixeddisplayvalue#<br /><br /><br />
																</cfif>
															 <cfelse><cfif DECount EQ 0>#fixeddisplayvalue#<br /><br /><br /></cfif>
															</cfif> 
														</cfif>
													<!--- If the date in the loop matches the date exclusion end date --->
														 <cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
														<!--- If it's not the last row --->
															<cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
														<!--- If there is a days difference in the current date exclusion end date and the following date exclusion start date, get that info --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																	#fixeddisplayvalue#	<br /><br /><br />			
																</cfif>
													
															<cfelse>
														
															<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
																<cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																#fixeddisplayvalue#
																</cfif>
													</cfif>
													</cfif>
												</cfif>
											</cfloop>
										</cfloop>
									</cfloop>
								</cfloop></cfif>
			</cfif>
			
						<cfif getcurrentcompNames.recordcount LT getcopmcount>
			<cfset coldiff = getcopmcount - getcurrentcompNames.recordcount>
			<td colspan="#coldiff#">&nbsp;</td>
			</cfif>
			<cfset getcopmcount = getcurrentcompNames.recordcount>
			
			<TD>
					<CFIF discount_percent LT 0>
					<cfset discountperneg = discount_percent * -1>
					#NegativeFormat(numberformat(discountperneg,"____.__"))#%	
					<CFELSE>
					#numberformat(discount_percent,"____.__")#%
					</CFIF>
			</TD>
			
			</cfloop>
			<cfelse>
				<TD ALIGN="RIGHT" valign="top">#trim(numberformat(getFixedPriceProducts.Fixed_Price_Value, ViewProgramManager.getRateFormatMask()))# per #left(getFixedPriceProducts.Abbreviation, 2)#
	<br>			<cfif appSettings.getPgmDisplayBothRateUOM() AND (getFixedPriceProducts.Unit_Of_Measure_ID EQ 1 OR getFixedPriceProducts.Unit_Of_Measure_ID EQ 2)>
				#trim(numberformat(ViewProgramManager.getRateInUOM(getFixedPriceProducts.Fixed_Price_Value, getFixedPriceProducts.Unit_Of_Measure_ID, getFixedPriceProducts.Net_Weight), ViewProgramManager.getRateFormatMask()))# per #ViewProgramManager.getTheOtherUOMDesc(getFixedPriceProducts.Unit_Of_Measure_ID)#
				</cfif>
				</TD>				
			</cfif>
							</cfoutput>
							
					</cfoutput>
</cfif>
</TABLE>
</cfif>
<br><br>
<span style="align:center">
<CF_button
						button_name		=	""
						button_caption	=	"print"
						button_action	=	"javascript:printPage();"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Print Page"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>	</span>

								
			

<cfelse>
<strong>Invalid Contract Number. Please try again.</strong>
</cfif>

<script>
		function printPage()
		{
			window.print();
		}
	</script>