<!--- 110308 RBL 17449 --->
<cfif GetSettings.Discount_Lump_Sums EQ 1>
	<cfoutput>
	<cfif List_Of_Contract_Main_IDs neq "">
		<cfset getLumpSums  = ViewProgramManager.getLumpSums(List_of_Contract_Main_IDs,1)>
	<cfelse>
		<cfset getLumpSums  = ViewProgramManager.getLumpSums(CSLGetContractInfo.Contract_Main_ID)>
	</cfif>
	<!--- DATA OUTPUT --->
	<!--- D45016 :: Restrict access at component level for all discount types START--->
	<cfset useLakebaseForCompvisibility = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lumpsum_component_profile")>
	<cfif useLakebaseForCompvisibility>
		<cftry>
			<cfset compvisibility = application.oLakebase.toQuery(
				application.oLakebase.selectRows("program_lumpsum_component_profile", { "profiles_id" = "eq.#request.AccessStructure.Profiles_ID#", "allow_user_to_view" = "eq.1", "deleted" = "eq.false" })
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForCompvisibility = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForCompvisibility>
	<cfquery name="compvisibility" datasource="#application.datasource#">
		SELECT *
		FROM Program_LumpSum_Component_Profile
		WHERE Profiles_ID = #request.AccessStructure.Profiles_ID#
		AND 	Allow_User_To_View = 1
		AND Deleted = 0
	</cfquery>
	</cfif>
	<cfset restrictlist = valuelist(compvisibility.Program_LumpSum_Component_Name_ID)>
	<!--- D45016 :: Restrict access at component level for all discount types END--->
	<cfif getLumpSums.recordcount GT 0>
		<tr>
		<td colspan="100%"><br></td>
		</tr>
		<tr>
			<td colspan="100%">
			<b><font size="2" color="navy">#application.lumpsumlabel#</font></b><hr color="navy">
			<cfif getlumpsums.recordcount gt 0>
				<cfset lumpsummanager = createobject("component", "components.programs.lump_sum_components.lumpsummanager") />
				<cfloop query="getlumpsums">
					<!--- D45016 :: restrict access at component level for all discount types start--->
					<cfif listfind(restrictlist, getlumpsums.program_lump_sum_name_id)>
						<cfset display="none">
					<cfelse>
						<cfset display="">
					</cfif>
					<!--- D45016 :: Restrict access at component level for all discount types END--->
					<table width="100%" border="0">
						<tr >
							<td style="font-weight:bold;font-size:14px;width:50%">
								#getLumpSums.Program_Lump_Sum_Name#
							</td>
							<td style="font-weight:bold;font-size:14px;width:50%" valign="top">
								<cfif not summaryView>
									$ #trim(numberformat(getLumpSums.Lump_Sum_Amount, '___,___,___,___,___,___.__'))#
									<!--- converter currency --->
									<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
										$ #trim(numberformat((getLumpSums.Lump_Sum_Amount * CSLGetContractInfo.currency_conversion_factor), '___,___,___,___,___,___.__'))# (CAD)
									</cfif>
								<cfelse>
									&nbsp;
								</cfif>
							</td>
						</tr>

						<tr>
							<td colspan="2" style="font-weight:normal;font-size:11px;padding-top:5px;">
								<cfif Len(getLumpSums.Lump_Sum_Description)><em>#getLumpSums.Lump_Sum_Description#</em><cfelse>&nbsp;</cfif>
							</td>
						</tr>
					<!--- Dev Note: WR 78635 - If "vendor" is a payee on the template, then hide "paid to".
					"Paid to" is actually vendor, but in the database, we save it as distributor. --->
					<cfif variables.bvendorOnlyProgram eq 0>
						<cfset colheaders ="Paid to">
						<cfset headersvalue =#templateManager.getPaymentPaidToTypeDesc(paidToID = getLumpSums.Component_Paid_To, paidToDesc="")#>
					<cfelse>
						<cfset colheaders ="">
						<cfset headersvalue ="">
					</cfif>
					<!--- GL ACCOUNT --->
					<cfif appSettings.getGL_Account_On() AND len(getLumpSums.GL_Account_Desc)>
						<cfset colheaders=ListAppend(colheaders,#Application.GLAccountLabel#)>
						<cfset headersvalue =ListAppend(headersvalue,'#getLumpSums.GL_Account_Desc# (#getLumpSums.GL_Account#)')>
					</cfif>
					<!--- DATES --->
					<cfif GetSettings.Date_Exclusions_ON EQ 1>
						<cfset colheaders=ListAppend(colheaders,'Dates')>
						<cfif getLumpSums.IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
							<cfset headersvalue =ListAppend(headersvalue, '#DateFormat(getLumpSums.Contract_Start_Date, "MM/DD/YYYY")# &ndash; #DateFormat(getLumpSums.Contract_End_Date, "MM/DD/YYYY")#')>
						<cfelse>
							<!--- If there are Date Exclusions --->
							<cfif ListLen(List_Of_Contract_Main_IDs) GT 1>
								<!--- Show the Contract Start Date --->
								<cfif DECount EQ 0>
									<cfset Datesvalue =ListAppend(headersvalue, '#DateFormat(getDateExclusionprogramIDs.Contract_Start_Date, "MM/DD/YYYY")#')>
								</cfif>
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
																<cfset headersvalue =ListAppend(headersvalue,'#DateFormat(Before_Date_Exclusion_Contract_Start_Date, "MM/DD/YYYY")#')>
															 </cfif>
														<cfelse>
															<cfif DECount EQ 0>
																<cfset headersvalue =ListAppend(headersvalue,'#DateFormat(DateAdd('d',-1,Contract_Start_Date),"MM/DD/YYYY")#')>
															</cfif>
														</cfif>
													</cfif>
													<!--- If the date in the loop matches the date exclusion end date --->
													<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
													<!--- If it's not the last row --->
														<cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
														<!--- If there is a days difference in the current date exclusion end date and the followinf date exclusion start date, get that info --->
															<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																<cfset headersvalue =ListAppend(headersvalue,'#DateFormat(After_Date_Exclusion_Contract_End_Date, "MM/DD/YYYY")# &ndash; #DateFormat(Before_Date_Exclusion_Contract_Start_Date[DateExclusionDate.currentrow+1], "MM/DD/YYYY")#')>
															</cfif>
														<cfelse>
														<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
															<cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																<cfset headersvalue =ListAppend(headersvalue,'#DateFormat(DateAdd('d',1,Contract_End_Date),"MM/DD/YYYY")# &ndash; #DateFormat(getDateExclusionprogramIDs.Contract_End_Date, "MM/DD/YYYY")#')>
															</cfif>
														</cfif>
													</cfif>
												</cfif>
											</cfloop>
										</cfloop>
									</cfloop>
								</cfloop>
							</cfif>
						</cfif>
					</cfif>
					<!--- PAYEE --->
					<cfset variables.Payee = "" />
					<cfif getLumpSums.Vendor_Master_ID NEQ "">
						<cfset useLakebaseForGetPayeeName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
						<cfif useLakebaseForGetPayeeName>
							<cftry>
								<cfset getPayeeName = application.oLakebase.toQuery(
									application.oLakebase.selectRows("vendor_master", { "select" = "vendor_name", "vendor_master_id" = "eq.#getLumpSums.Vendor_Master_Id#" }),
									"Vendor_Name"
								)>
								<cfcatch type="any">
									<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
									<cfset useLakebaseForGetPayeeName = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForGetPayeeName>
					<cfquery name="getPayeeName" datasource="#application.datasource#">
							SELECT Vendor_Name
							FROM 	Vendor_Master
							WHERE	Vendor_Master_Id = '#getLumpSums.Vendor_Master_Id#'
						</cfquery>
						</cfif>
						<cfif getPayeeName.RecordCount EQ 0><!--- If vendor not found, it could be a distributor --->
							<cfquery name="getPayeeName" datasource="#application.datasource#">
								SELECT 	Name as Vendor_Name
								FROM 	BSA_Foodservice_Customers
								WHERE	BSA_Foodservice_Customers_Id = '#getLumpSums.Vendor_Master_Id#'
							</cfquery>
						</cfif>
						<cfset variables.Payee = getPayeeName.Vendor_Name />
						<cfif len(variables.Payee)>
							<cfset colheaders=ListAppend(colheaders,'Payee')>
							<cfset headersvalue =ListAppend(headersvalue,#variables.Payee#)>
						</cfif>
					</cfif>
					<!--- PAYMENT CYCLE --->
					<cfif appSettings.getPaymentCycleAtDiscountType()>
						<cfset FORM.PaymentCycle = PaymentCycleManager.getPaymentCycle(CSLGetContractInfo.Contract_Main_ID, 3, Program_Lumps_Sum_Ext_Id) />
						 <cfset paymentCycleDesc = paymentCycleManager.getPaymentCycleDescription(FORM.PaymentCycle)>
						 <cfif len(paymentCycleDesc)>
							<cfset colheaders=ListAppend(colheaders,'Payment Cycle')>
							<cfset headersvalue =ListAppend(headersvalue, #paymentCycleDesc#)>
						</cfif>
					</cfif>
					<!--- PAYMENT TYPE --->
					<cfif appSettings.getClaims_at_Comp_Level() AND Claim_Mechanics NEQ 0>
						<cfif len(#paymenttypeManager.getDesc(Claim_Mechanics)#)>
							<cfset colheaders=ListAppend(colheaders,'Claim Mechanic')>
							<cfset headersvalue =ListAppend(headersvalue,'#paymenttypeManager.getDesc(Claim_Mechanics)#')>
						</cfif>
					</cfif>
					<!--- BILLBACK ACCESS --->
					 <cfquery name="GetLSCompInformation" datasource="#application.datasource#">
						SELECT 	Payment_Type.Payment_Type_Name, Payment_Type.Restrict_From_Billback, Payment_Type.Is_Auto_Pay
						FROM Program_Lump_Sums
						LEFT JOIN Payment_Type
						ON Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
						WHERE Program_Lump_Sums.Program_Lump_Sum_ID = '#getLumpSums.Program_Lump_Sum_ID#'
					</cfquery>
					<cfif len(trim(GetLSCompInformation.Restrict_From_Billback)) GT 0>
						<cfset colheaders=ListAppend(colheaders,'Available for Billbacks')>
						<cfif GetLSCompInformation.Restrict_From_Billback IS 1>
							<cfset headersvalue =ListAppend(headersvalue,'NO')>
						<cfelse>
							<cfset headersvalue =ListAppend(headersvalue,'YES')>
						</cfif>
					</cfif>
					<!--- EXTERNAL ID --->
					<cfset ID = LabelComp.getGeneralLabels('Lump Sum External ID')>
					<cfif application.returned_customer_setting.external_id_on AND getLumpSums.ID_on_ViewProgramPage>
						<cfif len(getLumpSums.External_ID)>
						<cfset colheaders=ListAppend(colheaders,#ID.General_Labels_Label#)>
						<cfset headersvalue =ListAppend(headersvalue,#getLumpSums.External_ID#)>
						</cfif>
					</cfif>
					<!--- DEDUCTION ACCOUNT --->
					<cfset DeductionAccount = LabelComp.getGeneralLabels('Deduction Account')>
					<cfif getLumpSums.DeductionAccount_on_ViewProgramPage>
						<cfif len(getLumpSums.Deduction_Account)>
							<cfset colheaders=ListAppend(colheaders,#DeductionAccount.General_Labels_Label#)>
							<cfset headersvalue =ListAppend(headersvalue,#getLumpSums.Deduction_Account#)>
						</cfif>
					</cfif>
					<!--- PAYMENT ACCOUNT --->
					<cfset PaymentAccount = LabelComp.getGeneralLabels('Payment Account')>
					<cfif getLumpSums.PaymentAccount_on_ViewProgramPage>
						<cfif len(getLumpSums.Payment_Account)>
							<cfset colheaders=ListAppend(colheaders,#PaymentAccount.General_Labels_Label#)>
							<cfset headersvalue =ListAppend(headersvalue,#getLumpSums.Payment_Account#)>
						</cfif>
					</cfif>

						<cfset LumpSumDataManager = CreateObject("component", "components.programs.lump_sum_components.DataManager").init() />
						<cfset getLumpSumProducts = LumpSumDataManager.getProgramLumpSumProducts(Program_Lump_Sum_ID, program_id) />
						<cfset colheaders=ListAppend(colheaders,#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#& ' Count')>
						<cfset headersvalue =ListAppend(headersvalue,#getLumpSumProducts.recordCount#)>

					<cfloop from="1" to="#listlen(colheaders)#" index="headers">
						<cfif headers MOD 2 EQ 1>
							<tr>
						</cfif>
								<td>
									<li>#listgetat(colheaders,headers)# : #listgetat(headersvalue,headers)#</li>
								</td>
						<cfif headers MOD 2 EQ 0>
							</tr>
						</cfif>
					</cfloop>
			<!------ Display details if application settings says so ----->
			<cfif appSettings.getPgmLumpsumDetailedDisplay() >
				<!------ Display distributor details ----->
				<cfif GetSettings.Discount_Lump_Sums_Distributor_Mandated EQ 1>
					<!------ get distributors ----->
					<cfset getdistributors  = lumpsummanager.getlumpsumdistributors(program_id, program_lump_sum_id, 1)>
					<cfif getdistributors.recordcount gt 0>
					<tr style="display:#display#">
						<td colspan="100%" align="right">
							<table cellspacing="2" cellpadding="2" width="100%">
								<tr>
									<td style="border-bottom:2px solid orange;" colspan="100%" id="header" align="left">
										<b>#application.returned_customer_setting.distributor_label_plural#</b>
									</td>
								</tr>
								<tr>
									<cfloop query="getdistributors">
									<!---handle what gets passed to the distributor profile popup based on groups--->
										<td style="border:none;" class="datastyle" width="33%" valign="top">
											<span>
												<font size="1">
													#ucase(trim(getdistributors.name))# <cfif len(shr_ship_to)>(#shr_ship_to#)</cfif>
												</font>
											</span>
										</td>
										<cfif getdistributors.currentrow mod 3>
											<cfelse>
											</tr>
											<tr>
										</cfif>
									</cfloop>
								</tr>
							</table>
						</td>
					</tr>
					</cfif>
				</cfif>
				<!------ Display product details ----->
				<cfif NOT variables.bHideFromLSAutoPay>
					<tr style="display:#display#">
						<td colspan="100%" align="right">
							<cfset displaylumpsuminfo = 0 />
							<!--- D36277 --->
							<cfset fromviewprogram = 1>
							<cfset url.lump_id = program_lump_sum_id />
							<table cellspacing="0" cellpadding="2" width="100%">
								<tr>
									<td style="border:none;">
										<cfset variables.bypassjs = 1 />
										<cfinclude template="lumpsum_products.cfm">
									</td>
								</tr>
							</table>
							<br>
						</td>
					</tr>
				</cfif>
			</cfif>
			</table>
			</CFLOOP>
			<!---NEW END --->
		<cfelse>
			<table width="100%" style="display:#display#">
				<tr>
					<td colspan="100%" align="center"><b><font color="red">NONE SUPPLIED</font></b></td>
				</tr>
			</table>
		</cfif>
		</td>
	</tr>
	<!------ Start Clause Code ----->
	<cfset getProgramClause = clauseProgramManager.getProgramClause(CSLGetContractInfo.Contract_Main_ID, 2, 3)>
	<cfif getProgramClause.recordCount>
		<tr style="display:#display#">
			<td colspan="100%">
			<br>
			<!------ lumpsum clauses ----->
			<cfinclude template="/clause_library/clause_program_display.cfm">
			</td>
		</tr>
	</cfif>
	<!------ End  Clause Code ----->
	</cfif>
	</cfoutput>
</cfif>
