<cfparam name="error" default="false">
<cfparam name="nomessagereceived" default="false">
<cfparam name="Error_Program_Id" default="">
<cfparam name="novaliditems" default="false">
<cfparam name="dateerrors" default="false">
<cfparam name="url.is_autorenew" default="0">
<cfparam name="lumpsumgroups" default="">
<cfparam name="errorData" default="">

<!------ Get application settings ----->
<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>

<cfprocessingdirective suppresswhitespace="YES">
<cfparam name="url.program_id" default="">  
<cfif url.program_id NEQ "">
<cf_cryp type="en" string ="#url.program_id#" key="#key#">
<cfset program_id = url.program_id>
<cfset FORM.ApproveContract = cryp.value>
<CFSET generateReleaseProgramID = cryp.value>
<cfset user_id = url.user_id>
<cfset WebservicesManager = CreateObject("component","components.programs.Approval.Webservices_Manager") />

<cfset getProgramheader = WebservicesManager.getProgramheader(Program_ID,user_id)>

<cfset getProgramDiscountTypes = WebservicesManager.getProgramDiscountTypes(Program_ID)>

 <!--- <cftry> --->
 
<cfloop query="getProgramDiscountTypes">
				<cfset getExcludedProgramRates = WebservicesManager.getProgramRates(Program_ID,getProgramDiscountTypes.Product_Type_ID,getProgramheader.template_code)>
				<cfset discount_type = Trim(getProgramDiscountTypes.Discount_Type)>
				<cfset Discount_Type_ID = getProgramDiscountTypes.Product_Type_ID>
		<cfif getExcludedProgramRates.recordcount GT 0>
					<cfif Discount_Type_ID EQ 3>
						<!---<cfset template_code = "LUMP">--->
						<cfset template_code = trim(getProgramheader.Lump_Spending_Code)>
						<cfset UOM = "B">
						<cfset getlumpprodvolume = WebservicesManager.getlumpprodsvolume(Program_ID)>				
							<cfif getlumpprodvolume.recordcount GT 0>
							<cfset lumpsumgroups = Valuelist(getlumpprodvolume.Product_Group_ID)>
								<CFQUERY NAME="getlumpvolsum" DBTYPE="query">
									select sum(volume_cs) as lumpvolumesum
									from getlumpprodvolume
								</CFQUERY>
							</cfif>
					<cfelse>
						<cfset template_code = #trim(getProgramheader.template_code)#>
						<cfset UOM = #trim(getProgramheader.unit_of_measure)#>
					</cfif>
						<cfset componentcount = 1>
		
						
		<!--- Got rates <HR>
		
		<cfflush> --->
		
		<!---  <CFQUERY NAME="getDiscountTypeRates" dbtype="query">
			select distinct pricing_level_id, Product_Group, rate, Component_Name_ID,Shr_Ship_To,
			Buying_Group,Payment_Cycle,Payment_Cycle_Id
			from getExcludedProgramRates
			where pricing_level_id = select max(pricing_level_id) from getExcludedProgramRates pr1
			where pr1.Product_Group = getExcludedProgramRates.Product_Group
			and pr1.Component_Name_ID = getExcludedProgramRates.Component_Name_ID
		</CFQUERY>  --->
		
		<CFQUERY NAME="getZeroProductgroups" dbtype="query">
			select distinct Product_Group
			from getExcludedProgramRates
			where rate = 0
		</CFQUERY> 
		
		<cfset zeroproductgrouplist = Valuelist(getZeroProductgroups.Product_Group)>
		
		<cfif Discount_Type_ID EQ 3> 
			<CFQUERY NAME="getDiscountTypeRates" dbtype="query">
				select *
				from getExcludedProgramRates
				<cfif getlumpprodvolume.recordcount GT 0>
				<cfif listlen(lumpsumgroups) GT 0>
				where PRODUCT_GROUP IN (#QuotedValueList(getlumpprodvolume.Product_Group_ID)#)
				</cfif>
				</cfif>
				order by Component_Name_ID,Product_Group,Payment_Cycle,Payment_Cycle_Id
			</CFQUERY> 
		<cfelse>
			<cfoutput>
			<CFQUERY NAME="getDiscountTypeRates" dbtype="query">
				select distinct Product_Group,Component_Name_ID,Shr_Ship_To,
				Buying_Group,Payment_Cycle,Payment_Cycle_Id,
				External_Id
				from getExcludedProgramRates
				<cfif ListLen(zeroproductgrouplist) NEQ 0>
				where Product_Group NOT IN (#QuotedValueList(getZeroProductgroups.Product_Group)#)
				</cfif>
				order by Component_Name_ID,Product_Group,Shr_Ship_To,Buying_Group,Payment_Cycle,Payment_Cycle_Id
			</CFQUERY> 
			</cfoutput>		
		</cfif>
		
		<cfset externalId = '' />
		<cfoutput query="getDiscountTypeRates" group="Component_Name_ID">
			<cfif error EQ "false" and nomessagereceived EQ "false">
				<cfset Payment_Cycle_Num = getDiscountTypeRates.Payment_Cycle_Id>
				 <cfset rUnits = CreateObject("component","components.programs.Approval.program_dates").getProgramPeriods(getProgramheader.contract_start_date,getProgramheader.contract_end_date,'',Payment_Cycle_Num, template_code,Discount_Type_ID) />
				 <cfif  getDiscountTypeRates.External_Id eq '$/CA'>
					<cfset externalId = 'DOLL' />
				 <cfelse>
				 	<cfset externalId = getDiscountTypeRates.External_Id />
				 </cfif>
				
				 <!--- got payment cycles<hr> <cfflush> --->
				<cfparam name="mws" default="0">
				<cfif arraylen(rUnits) GT 0>

					<cfif mws eq 0>
					  <cfset useLakebaseFordeleteprogramperiods = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_period_dates")>
<cfif useLakebaseFordeleteprogramperiods>
	<cftry>
		<cfset application.oLakebase.deleteRows("program_period_dates", {
			"contract_number" = "eq.#getProgramheader.contract_number#",
			"program_discount_type_id" = "eq.#Discount_Type_ID#",
			"component_name_id" = "eq.#getDiscountTypeRates.Component_Name_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteprogramperiods = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteprogramperiods>
<CFQUERY NAME="deleteprogramperiods" datasource="#application.datasource#">
						DELETE FROM
						program_period_dates
						where
						contract_number = #getProgramheader.contract_number#
						and Program_Discount_Type_ID = #Discount_Type_ID#
						and Component_Name_ID = #getDiscountTypeRates.Component_Name_ID#
					  </CFQUERY>
</cfif>
					 </cfif>

					<cfloop index="i" from="1" to="#Arraylen(rUnits)#">
					<cfif i LT 10>
					<cfset paymentcounter = "00#i#">
					<cfelse>
					<cfset paymentcounter = "0#i#">
					</cfif>
					<cfset RebateID = 
					#Replace(getProgramheader.contract_number,"-","")#&"."&#discount_type#&#componentcount#&"."&#paymentcounter#> 
					
					<cfif mws eq 0>
					   <CFQUERY NAME="insertprogramperiods" datasource="#application.datasource#">
						insert into program_period_dates
						(Program_Id,BSA_Program_Id,Program_Payment_Period,contract_number,Program_Discount_Type_ID,Component_Name_ID,Period_Start_Date,Period_End_Date)
						values(#getProgramheader.contract_main_id#,'#RebateID#', #paymentcounter#, #getProgramheader.contract_number#,#Discount_Type_ID#, #getDiscountTypeRates.Component_Name_ID#,#Trim(rUnits[i].PERIODSTARTDATE)#,#Trim(rUnits[i].PERIODENDDATE)#)
					   </CFQUERY>
					</cfif>

					</cfloop>
					<!--- 
					inserted program periods
					<cfflush> --->
					
					<cfset tempxml = "<SOAP-ENV:Envelope xmlns:SOAP-ENV=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:SOAP-ENC=""http://schemas.xmlsoap.org/soap/encoding/""  xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""  xmlns:xsd=""http://www.w3.org/2001/XMLSchema""  xmlns:m0=""http://localhost/PTV_CONTRACTMTG/process/sapSubmitRebate""><SOAP-ENV:Body><m:sapSubmitRebate xmlns:m=""http://b2b.pactiv.com/BS/Rebate/PTV_CONTRACTMTG.process"" SOAP-ENV:encodingStyle=""http://schemas.xmlsoap.org/soap/encoding/"">" >
					<cfset tempxml = tempxml & "<RebateHeader>">
					<cfset tempxml = tempxml & "<RebateID></RebateID>">
					<cfset tempxml = tempxml & "<SAPRebateID></SAPRebateID>">
					<cfset tempxml = tempxml & "<UpdateStatus></UpdateStatus>">
					<cfset tempxml = tempxml & "<RebateDescription>#XMLFormat(getProgramheader.contract_title)#</RebateDescription>">
					<cfset tempxml = tempxml & "<SalesOrganization>#getProgramheader.Line_Of_Business#</SalesOrganization>">
					<cfset tempxml = tempxml & "<DistributionChannel>#getProgramheader.Business_Unit_Id#</DistributionChannel>">
					<cfset tempxml = tempxml & "<TemplateCode>#lcase(template_code)#</TemplateCode>">
					<cfset tempxml = tempxml & "<CalculationBasis>#externalId#</CalculationBasis>">
					<cfset tempxml = tempxml & "<PaymentFrequency>#getDiscountTypeRates.Payment_Cycle#</PaymentFrequency>">
					<cfset tempxml = tempxml & "<Recipient>#getProgramheader.Shr_Ship_To#</Recipient>">
					<cfset tempxml = tempxml & "<ValidFrom></ValidFrom>">
					<cfset tempxml = tempxml & "<ValidTo></ValidTo>">
					<cfset tempxml = tempxml & "<PaymentMethod>#getProgramheader.Payment_Type_Legacy_Id#</PaymentMethod>">
					 <cfset tempxml = tempxml & "<ProgramManager>#getProgramheader.responsible_user#</ProgramManager>"> 
					<cfset tempxml = tempxml & "<AccountSpecialist></AccountSpecialist>">
					<cfset tempxml = tempxml & "<SalesRepresentative></SalesRepresentative>">
					<cfif url.is_autorenew EQ 0>
						<cfset tempxml = tempxml & "<ApprovedBy>#getProgramheader.approved_user#</ApprovedBy>"> 
						<cfset tempxml = tempxml & "<ApprovedDate>#dateformat(now(),"yyyymmdd")#</ApprovedDate>">
					<cfelse>
						<cfset tempxml = tempxml & "<ApprovedBy></ApprovedBy>"> 
						<cfset tempxml = tempxml & "<ApprovedDate></ApprovedDate>">
					</cfif>
					 <cfset tempxml = tempxml & "<CreatedByUser>#getProgramheader.creator_user#</CreatedByUser>"> 
					<cfset tempxml = tempxml & "<CreatedDate>#dateformat(getProgramheader.Contract_Created_Date,"yyyymmdd")#</CreatedDate>">
					<cfset tempxml = tempxml & "<LastChangedByUser></LastChangedByUser>">
					<cfset tempxml = tempxml & "<LastChangeDate>#dateformat(now(),"yyyymmdd")#</LastChangeDate>">
					<cfset tempxml = tempxml & "</RebateHeader>">
					
					<!--- <hr>
					created header <cfflush> --->
					<cfset i=0>
					<cfset product_family = "">
					<cfset useLakebaseForitemcount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getdiscounttyperates")>
<cfif useLakebaseForitemcount>
	<cftry>
		<cfset itemcount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getdiscounttyperates", {
				"component_name_id" = "eq.#getDiscountTypeRates.Component_Name_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForitemcount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForitemcount>
<CFQUERY NAME="itemcount" DBTYPE="query">
						select distinct * from getDiscountTypeRates
						where Component_Name_ID = #getDiscountTypeRates.Component_Name_ID#
					</CFQUERY>
</cfif>
					
					<cfset totaldetailcount  = itemcount.recordcount>
					
					<cfset tempxml = tempxml & "<RebateDetail xsi:type=""SOAP-ENC:Array"" SOAP-ENC:arrayType=""m0:__RebateDetail[#totaldetailcount#]"">">
					<cfset totallumpsumamount = 0>
					<cfoutput>
					<cfset tempxml = tempxml & "<m0:item#i# xsi:type=""m#i#:__RebateDetail"">">
					<cfset tempxml = tempxml & "<RebateID></RebateID>">
					<cfset tempxml = tempxml & "<SAPRebateID></SAPRebateID>">
					<cfif Discount_Type_ID EQ 3 and getProgramheader.template_code NEQ "LUMP">
						<cfset tempxml = tempxml & "<BuyingGroup></BuyingGroup>">
						<cfset tempxml = tempxml & "<Customer>#getProgramheader.Shr_Ship_To#</Customer>">
					<cfelse>
						<cfif getDiscountTypeRates.Buying_Group NEQ "None">
							<cfset Buying_Group_Name = getDiscountTypeRates.Buying_Group>
						<cfelse>
							<cfset Buying_Group_Name = "">
						</cfif>
						<cfif getProgramheader.template_code EQ 'BGRP'>
							<cfset tempxml = tempxml & "<BuyingGroup>#Buying_Group_Name#</BuyingGroup>">
						<cfelse>
							<cfset tempxml = tempxml & "<BuyingGroup></BuyingGroup>">
						</cfif>
						<cfif getDiscountTypeRates.Shr_Ship_To NEQ "Group">
								<cfset tempxml = tempxml & "<Customer>#getDiscountTypeRates.Shr_Ship_To#</Customer>">
						<cfelse>
							<cfset tempxml = tempxml & "<Customer></Customer>">
						</cfif>
					</cfif>
					<cfset tempxml = tempxml & "<ProductFamily>#getDiscountTypeRates.Product_group#</ProductFamily>">
					<cfset tempxml = tempxml & "<CalculationType>#UOM#</CalculationType>">
					
					
					<cfif Discount_Type_ID EQ 3>
					<cfif getlumpprodvolume.recordcount GT 0>
					<cfset product_family = getDiscountTypeRates.Product_group>
						<cfset useLakebaseForgetfamilylumpvol = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getlumpprodvolume")>
<cfif useLakebaseForgetfamilylumpvol>
	<cftry>
		<cfset getfamilylumpvol = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getlumpprodvolume", {
				"product_group_id" = "eq.#product_family#",
				"select" = "volume_cs as family_volume"
			}), "volume_cs as family_volume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetfamilylumpvol = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetfamilylumpvol>
<CFQUERY NAME="getfamilylumpvol" DBTYPE="query">
							select  volume_cs as family_volume
							from getlumpprodvolume
							where product_group_id = '#product_family#'
						</CFQUERY>
</cfif>
						<cfif getfamilylumpvol.recordcount EQ 0>
							<cfset familyvol = 0>
						<cfelse>
							<cfif getfamilylumpvol.family_volume EQ "">
								<cfset familyvol = 0>
							<cfelse>
								<cfset familyvol = getfamilylumpvol.family_volume>
							</cfif>
						</cfif>
						
					<cfset currentlump = (familyvol * getDiscountTypeRates.rate) / getlumpvolsum.lumpvolumesum>
					<!--- <cfset totallumpsumamount = totallumpsumamount + currentlump>
					<cfif i EQ (totaldetailcount-1)>
						<cfif totallumpsumamount LT getDiscountTypeRates.rate>
							<cfset currentlump = currentlump + (getDiscountTypeRates.rate - totallumpsumamount)>
						<cfelseif totallumpsumamount GT getDiscountTypeRates.rate>
							<cfset currentlump = currentlump - (totallumpsumamount - getDiscountTypeRates.rate)>
						</cfif>
					</cfif> --->
					<cfelse>
						 <cfset useLakebaseForfamilycount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getdiscounttyperates")>
<cfif useLakebaseForfamilycount>
	<cftry>
		<cfset familycount = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getdiscounttyperates", {
				"component_name_id" = "eq.#getDiscountTypeRates.Component_Name_ID#",
				"select" = "product_group"
			}), "product_group"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForfamilycount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForfamilycount>
<CFQUERY NAME="familycount" DBTYPE="query">
							select distinct Product_group from getDiscountTypeRates
							where Component_Name_ID = #getDiscountTypeRates.Component_Name_ID#
						</CFQUERY>
</cfif>
						<cfset currentlump = Numberformat(getDiscountTypeRates.rate/familycount.recordcount,"_________.__")>
					
						<cfif getDiscountTypeRates.Product_group NEQ product_family>
							<cfset totallumpsumamount = totallumpsumamount + currentlump>
							<cfset product_family = getDiscountTypeRates.Product_group>
						</cfif>
						<cfif i EQ (totaldetailcount-1)>
							<cfif totallumpsumamount LT getDiscountTypeRates.rate>
								<cfset currentlump = currentlump + (getDiscountTypeRates.rate - totallumpsumamount)>
							<cfelseif totallumpsumamount GT getDiscountTypeRates.rate>
								<cfset currentlump = currentlump - (totallumpsumamount - getDiscountTypeRates.rate)>
							</cfif>
						</cfif>
					</cfif>
					<cfset currentlump = Numberformat(currentlump,"_________.__")>
					<cfset tempxml = tempxml & "<Rate>#currentlump#</Rate>">
					<cfelse>
						<CFQUERY NAME="getmaxpricinglevel" DBTYPE="query">
							select max(pricing_level_id) as pricing_level from getExcludedProgramRates
							where Component_Name_ID = #getDiscountTypeRates.Component_Name_ID#
							and product_group = '#getDiscountTypeRates.product_group#'
						</CFQUERY>
						<cfset useLakebaseForgetgrouprate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getexcludedprogramrates")>
<cfif useLakebaseForgetgrouprate>
	<cftry>
		<cfset getgrouprate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getexcludedprogramrates", {
				"component_name_id" = "eq.#getDiscountTypeRates.Component_Name_ID#",
				"product_group" = "eq.#getDiscountTypeRates.product_group#",
				"pricing_level_id" = "eq.#getmaxpricinglevel.pricing_level#",
				"select" = "rate"
			}), "rate"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetgrouprate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetgrouprate>
<CFQUERY NAME="getgrouprate" DBTYPE="query">
							select rate from getExcludedProgramRates
							where Component_Name_ID = #getDiscountTypeRates.Component_Name_ID#
							and product_group = '#getDiscountTypeRates.product_group#'
							and pricing_level_id = #getmaxpricinglevel.pricing_level#
						</CFQUERY>
</cfif>
						<cfset tempxml = tempxml & "<Rate>#getgrouprate.rate#</Rate>">
					</cfif>

							<!---<CFQUERY NAME="gettestCount" datasource="#application.datasource#">
							insert into test_Webservice_Milan(test_desc)
							values('test')
							</CFQUERY>
							--->
					
					<cfset tempxml = tempxml & "<MaterialForSettlement>ADMIN_#getDiscountTypeRates.Product_group#</MaterialForSettlement>">
					<cfset tempxml = tempxml & "<RebateConditionRecord></RebateConditionRecord>">
					<cfset tempxml = tempxml & "<DeletionIndicator></DeletionIndicator>">
					<cfset tempxml = tempxml & "</m0:item#i#>">
					 <cfset i=i+1>
					</cfoutput>
					
					<cfset tempxml = tempxml & "</RebateDetail>">
					<cfset tempxml = tempxml & "</m:sapSubmitRebate></SOAP-ENV:Body></SOAP-ENV:Envelope>">
					
					<cfset xmlDocument = XmlParse(tempxml)>
					
					<cfset detaillen  = ArrayLen(xmlDocument.Envelope.body.sapSubmitRebate.RebateDetail.XmlChildren) - 1>
					
					<cfset stime = 0.07 * detaillen>
					<cfset ltime = 0.07 * detaillen>
					<cfif stime LT 20>
						<cfset stime = 20>
					<cfelse>
						<cfset stime = stime>
					</cfif>
					
					<cfif ltime LT 20>
						<cfset ltime = 20>
					<cfelse>
						<cfset ltime = ltime>
					</cfif>
					
					<!--- <hr>
					created xml <cfflush> --->
					
					<!---<cfdump var="#rUnits#">--->
					<cfloop index="i" from="1" to="#Arraylen(rUnits)#">
						<!--- #rUnits[i].PERIODSTARTDATE#
						#rUnits[i].PERIODENDDATE# --->
						<cfif i LT 10>
						<cfset RebateID = 
						#Replace(getProgramheader.contract_number,"-","")#&"."&#discount_type#&#componentcount#&".00#i#"> 
						<cfelse>
						<cfset RebateID = 
						#Replace(getProgramheader.contract_number,"-","")#&"."&#discount_type#&#componentcount#&".0#i#"> 
						</cfif> 
						
						<CFQUERY NAME="getprogramsettlementdetails" datasource="#application.datasource#">
						select * from
						Program_WebServices_Detail
						where BSA_Program_Id = '#RebateID#'
						and deleted = 0
						and (program_status = 'D' OR program_status = 'B' OR program_status = 'C')
						
						</CFQUERY>
						 
						<cfif getprogramsettlementdetails.recordcount EQ 0> 
							<cfset start_date = #Dateformat(Trim(rUnits[i].PERIODSTARTDATE),"yyyymmdd")#>
							<cfset end_date = #Dateformat(Trim(rUnits[i].PERIODENDDATE),"yyyymmdd")#>
							
							<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.RebateID.XmlText = RebateID>
							<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.ValidFrom.XmlText = start_date>
							<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.ValidTo.XmlText = end_date>
							
							<!--- <hr>
							made chnages to xml doc <cfflush> --->
							
							<CFQUERY NAME="getprogramerrordetails" datasource="#application.datasource#">
								select * from
								Program_Webservices_Error_Detail
								where BSA_Program_Id = '#RebateID#'
								and deleted = 0
								and Message_Type like '%S%'
							</CFQUERY>
							
							<cfset SAPRebateID = "">
							<cfset UpdateStatus = "">
							<cfif getprogramerrordetails.recordcount EQ 0>
								<cfset UpdateStatus = "I">
								<cfset SAPRebateID = "">
							<cfelse>
								<cfset UpdateStatus = "U">
								<cfset SAPRebateID = #getprogramerrordetails.Pactiv_Program_Id#>
							</cfif>
							 
							<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.UpdateStatus.XmlText = UpdateStatus>
							<cfset xmlDocument.Envelope.body.sapSubmitRebate.RebateHeader.SAPRebateID.XmlText = SAPRebateID>
							
							<cfif i GT 1>
								<cfif Trim(rUnits[i].PERIODSTARTDATE) GT now()>
									<cfbreak>
								</cfif>
							</cfif>
							
							<cfset xmlProgramDoc = ToString(xmlDocument)>

							<cfset useLakebaseForgetprogramdetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_detail")>
<cfif useLakebaseForgetprogramdetails>
	<cftry>
		<cfset getprogramdetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_webservices_detail", {
				"bsa_program_id" = "eq.#RebateID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetprogramdetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetprogramdetails>
<CFQUERY NAME="getprogramdetails" datasource="#application.datasource#">
								select * from
								Program_WebServices_Detail
								where BSA_Program_Id = '#RebateID#'
								and deleted = 0
							</CFQUERY>
</cfif>
							
							<cfset Schedule_Sent = url.is_autorenew />
							<cfif getprogramdetails.recordcount GT 0>
								<CFQUERY NAME="updateprogramwebservicesdetails" datasource="#application.datasource#">
									update Program_WebServices_Detail
									SET 
									BSA_XML_Structure = '#xmlProgramDoc#',
									Approved_User_Id = '#user_id#',
									Approved_Date = #now()#,
									program_id = #Program_ID#,
									Component_Name_ID = #getDiscountTypeRates.Component_Name_ID#,
									Program_Discount_Type_ID = #Discount_Type_ID#,
									Schedule_Sent = #Schedule_Sent#
									where
									BSA_Program_Id = '#RebateID#'
									and deleted = 0
								</CFQUERY>
							<cfelse>
								 <cfset useLakebaseForinsertprogramwebservicesdetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_detail")>
<cfif useLakebaseForinsertprogramwebservicesdetails>
	<cftry>
		<cfset application.oLakebase.insertRow("program_webservices_detail", {
			"program_id" = "#getProgramheader.contract_main_id#",
			"bsa_program_id" = "#RebateID#",
			"program_discount_type_id" = "#Discount_Type_ID#",
			"component_name_id" = "#getDiscountTypeRates.Component_Name_ID#",
			"bsa_xml_structure" = "#xmlProgramDoc#",
			"approved_user_id" = "#user_id#",
			"approved_date" = "#now()#",
			"schedule_sent" = "#Schedule_Sent#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertprogramwebservicesdetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertprogramwebservicesdetails>
<CFQUERY NAME="insertprogramwebservicesdetails" datasource="#application.datasource#">
									insert into Program_WebServices_Detail
									(Program_Id,BSA_Program_Id,Program_Discount_Type_ID,Component_Name_ID,BSA_XML_Structure,Approved_User_Id,Approved_Date,Schedule_Sent)
									values(#getProgramheader.contract_main_id#,'#RebateID#',#Discount_Type_ID#, #getDiscountTypeRates.Component_Name_ID#,'#xmlProgramDoc#','#user_id#',#now()#,#Schedule_Sent#)
								</CFQUERY>
</cfif>
							</cfif>
							<!--- <hr>
							inserted into the DB <cfflush> --->
							<!---  xmlhttp = createObject("COM", "Msxml2.XMLHTTP.3.0"); --->
							<div align="center"><font size="2" color="red">
							Sent Rebate #RebateID# to SAP
							</font></div>
							<br>
						<!---	SEND:<p><cfdump var = "#xmlProgramDoc#"/> --->
							
							 <cfhttp method="post" 
 								url = "#appSettings.getExternalWebserviceURL()#"
								charset = "UTF-8">
	
								<cfhttpparam
									type="xml"
									value="#trim(xmlProgramDoc)#"/>
 
								</cfhttp>
					<cfset myxml = 	CFHTTP.Filecontent/>

					<!--- <cfdump var = "#xmlProgramDoc#"/>
					<cfdump var = "#appSettings.getExternalWebserviceURL()#"/> <cfabort>
					<cfdump var = "#xmlProgramDoc#"/> --->
				

					<cfif isdefined("myxml") and myxml NEQ "">
								<cfset xmldoc = XmlParse(myxml)>
								<cfif StructKeyExists(xmldoc.Envelope.body,"sapSubmitRebateResponse")>
									<cfset component= xmldoc.Envelope.body.sapSubmitRebateResponse.RebateResult[1].item>
									
									<cfset size = ArrayLen(component)>
									<cfif isXmlDoc(xmldoc)>
										<cfset i = 1>
										<cfloop condition = "i LESS THAN OR EQUAL TO #size#">
											<cfset useLakebaseForinsertwebserviceserrordetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_error_detail")>
<cfif useLakebaseForinsertwebserviceserrordetails>
	<cftry>
		<cfset application.oLakebase.insertRow("program_webservices_error_detail", {
			"bsa_program_id" = "#component[i].BlackSmithRebateNumber.XmlText#",
			"pactiv_program_id" = "#component[i].PactivRebateNumber.XmlText#",
			"message_text" = "#component[i].MessageText.XmlText#",
			"message_type" = "#component[i].MessageType.XmlText#",
			"message_for" = "#component[i].MessageFor.XmlText#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertwebserviceserrordetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertwebserviceserrordetails>
<CFQUERY NAME="insertwebserviceserrordetails" datasource="#application.datasource#">
											insert into Program_Webservices_Error_Detail
											(BSA_Program_Id,Pactiv_Program_Id,Message_Text,Message_Type,Message_For)
											values('#component[i].BlackSmithRebateNumber.XmlText#','#component[i].PactivRebateNumber.XmlText#','#component[i].MessageText.XmlText#','#component[i].MessageType.XmlText#','#component[i].MessageFor.XmlText#')
											</CFQUERY>
</cfif>
											<cfif component[i].MessageType.XmlText EQ "E">
<cfsavecontent variable="errorDataTmp">
	Error in Approval Send to SAP:<br>
	#component[i].BlackSmithRebateNumber.XmlText#<br>
	#component[i].PactivRebateNumber.XmlText#
	#component[i].MessageText.XmlText#<br>
	#component[i].MessageType.XmlText#<br>
	#component[i].MessageFor.XmlText#<br>
	http://pactiv.awayx.com/scheduled/runsapprograms.cfm?cmid=#program_id# 
</cfsavecontent>
<cfset errorData = errorData & errorDataTmp />
												<div align="center"><font size="2" color="red">
													#component[i].BlackSmithRebateNumber.XmlText# - #component[i].PactivRebateNumber.XmlText#-#component[i].MessageText.XmlText#-<cfif Trim(component[i].MessageFor.XmlText) EQ "P">Message for Pactiv<cfelse>Message for Blacksmith</cfif>
												</font></div>
													<!--- If it is settled, flag it as settles and continue...Mimics manual process --->
													<CFIF component[i].MessageText.XmlText CONTAINS 'was already settled. Only display is possible'>
															<!--- Update record --->
															<cfset useLakebaseForupdateSettledRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_detail")>
<cfif useLakebaseForupdateSettledRecord>
	<cftry>
		<cfset application.oLakebase.updateRows("program_webservices_detail",
			{
				"bsa_program_id" = "eq.#component[i].BlackSmithRebateNumber.XmlText#"
			},
			{
				"program_status" = "D"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateSettledRecord = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateSettledRecord>
<CFQUERY NAME="updateSettledRecord" datasource="#application.datasource#">
																UPDATE Program_WebServices_Detail 
																SET program_status ='D'
																WHERE BSA_Program_Id ='#component[i].BlackSmithRebateNumber.XmlText#'
															</CFQUERY>
</cfif>
													<CFELSE>
															<cfset useLakebaseForselectSettledRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_webservices_detail")>
<cfif useLakebaseForselectSettledRecord>
	<cftry>
		<cfset selectSettledRecord = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_webservices_detail", {
				"bsa_program_id" = "eq.#component[i].BlackSmithRebateNumber.XmlText#",
				"program_status" = "eq.D",
				"select" = "program_status"
			}), "program_status"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForselectSettledRecord = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForselectSettledRecord>
<CFQUERY NAME="selectSettledRecord" datasource="#application.datasource#">
																SELECT Program_Status FROM Program_WebServices_Detail 
																WHERE 	BSA_Program_Id ='#component[i].BlackSmithRebateNumber.XmlText#' 
																		AND program_status ='D'
															</CFQUERY>
</cfif>
														<CFIF trim(selectSettledRecord.Program_Status) EQ 'D'>
															<!--- If it is already settled, ignore further error messages --->
														<CFELSE>
															
															<cfset error = "true">
															<cfset Error_Program_Id = component[i].BlackSmithRebateNumber.XmlText>
														</CFIF>
													</CFIF>
											<cfelse>
												<div align="center"><font size="2" color="red">
												Received #component[i].BlackSmithRebateNumber.XmlText# - #component[i].PactivRebateNumber.XmlText#-#component[i].MessageText.XmlText#
												</font>
												<HR>
											</cfif>
											<cfset i = i + 1>
										</cfloop>
									</cfif>
								<cfelse>
									<cfset nomessagereceived = "true">
								</cfif>
							<cfelse>
								<cfset nomessagereceived = "true">
							</cfif> 
							<cfif error EQ "true" OR nomessagereceived EQ "true">
								<cfbreak>
							</cfif> 
						</cfif>
					</cfloop>
				<cfelse>
					<cfset dateerrors ="true">
					<cfset error = "true">
				</cfif>
			</cfif> 
			<cfset componentcount = componentcount + 1>
		</cfoutput>
		
		<cfif error EQ "true" OR nomessagereceived EQ "true">
			<cfbreak>
		</cfif>
	
	<cfelse>
		<cfset novaliditems = "true">
	</cfif>

</cfloop>
<cfif errorData NEQ ''>
	<cfmail to = "msaunders@bigredflame.com;dkost@bigredflame.com" from = "msaunders@bigredflame.com" subject = "SAP Error :: Pactiv :: Approval" type="HTML">
	#errorData#
</cfmail>
</cfif>
<cfif nomessagereceived EQ "true">
	<br><div align="center"><font size="2" color="red"><B>No Response from SAP</B></font></div>
	  	<cfset useLakebaseForApproveContract = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForApproveContract>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#program_id#"
			},
			{
				"sent_to_external_client" = "0",
				"error_from_external_client" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForApproveContract = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForApproveContract>
<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #program_id#
		</CFQUERY>
</cfif>
</cfif>
<cfif dateerrors EQ "true">
	<br><div align="center"><font size="2" color="red"><B>Please check the dates and payment cycles selected.</B></font></div>
	<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #program_id#
		</CFQUERY>
</cfif>

<!---<cfoutput>#error# :: #nomessagereceived# :: #novaliditems#</cfoutput>--->
	
<cfif (error EQ "false") AND nomessagereceived EQ "false" and novaliditems EQ "false">
	<cfset getProgramsSent = WebservicesManager.getProgramsSent(Program_ID)>
	<cfdump var="#getProgramsSent#" />
	<cfif getProgramsSent.recordcount EQ 0>
	
		<cfset new_revision_version = 1 />
		<!---- check if program is a revision ---->
		<cfset useLakebaseForProgram_Detail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForProgram_Detail>
	<cftry>
		<cfset Program_Detail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#program_id#",
				"select" = "contract_number,is_a_revision"
			}), "contract_number,is_a_revision"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForProgram_Detail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForProgram_Detail>
<CFQUERY NAME="Program_Detail" datasource="#application.datasource#">
			SELECT	contract_number, Is_A_Revision
			FROM	Contract_Main
			WHERE 	Contract_Main_Id = #program_id#
		</CFQUERY>
</cfif>
		
		<cfif Program_Detail.Is_A_Revision EQ 1>
			<!--- now get the maximum version of all the approved programs of this contract number and then update the current approved program with max(revision_number) + 1 --->
			<CFQUERY NAME="GetRevisionVersion" datasource="#application.datasource#">
				select max(revision_version) as revisionversion
				from contract_main
				where contract_number like '%#Program_Detail.contract_number#%'
				and contract_main.Approved = 1
				and contract_main_id != #program_id#
			</CFQUERY>
			<cfset new_revision_version = GetRevisionVersion.revisionversion + 1 />
		</cfif>
		
		<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Approval_Date = getdate(), 
			<cfif url.is_autorenew EQ 0>
			Approved = 1,
			<cfif Program_Detail.Is_A_Revision EQ 1>
			revision_version = '#new_revision_version#', 
			</cfif> 
			</cfif>			
			Sent_To_External_Client = 0,
			Error_From_External_Client = 0,
			Approved_By_User_ID = '#User_ID#',
			Is_Manual_Revision = Is_A_Revision
			WHERE Contract_Main_Id = #program_id#
		</CFQUERY>
		<cfset contract_main_id = program_id>
		
		<!---if payment cycle is handled at the discount level then lock payment cycles --->
		<cfif appSettings.getPaymentCycleAtDiscountType()>
			<cfset CreateObject("component", "components.programs.PaymentCycleManager").lockPaymentCycles(contract_main_id) />
		</cfif>
		<cfset getThisProgramsStatus = WebservicesManager.getThisProgramsStatus(Program_ID)>
	<cfset request.AccessStructure.user_id = user_id>
		<cfsilent>
<cfif not isdefined("request.AccessStructure.Company_Main_ID")>
				<cfset useLakebaseForGetcompany = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGetcompany>
	<cftry>
		<cfset Getcompany = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"limit" = "1",
				"select" = "company_main_id"
			}), "company_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetcompany = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetcompany>
<cfquery name="Getcompany" datasource="#application.datasource#">
					SELECT Top 1 Company_Main_ID
					FROM Company_Main
				</cfquery>
</cfif>
<cfset request.AccessStructure.Company_Main_ID = GetCompany.Company_Main_ID>
			</cfif>
			<cfif url.is_autorenew EQ 0>
				<cfinclude template="/common_files/contracts/generate_approve_email.cfm">
			</cfif>
		 </cfsilent>
	</cfif>
<cfelseif error EQ 'true'>
		<div align="center"><font size="2" color="red">The program is not approved.</font> </div>
	<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
		UPDATE Contract_Main
		Set Sent_To_External_Client = 0,
		Error_From_External_Client = 1
		WHERE Contract_Main_Id = #program_id#
	</CFQUERY>
	<cfabort>
<cfelse>
		<div align="center"><font size="2" color="red">The program is not approved.</font> </div>
	<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
		UPDATE Contract_Main
		Set Sent_To_External_Client = 0,
		Error_From_External_Client = 1
		WHERE Contract_Main_Id = #program_id#
	</CFQUERY>
	<cfabort>
</cfif>
<cfif novaliditems EQ "true">
	
	<div align="center"><font size="2" color="red">Please check the Unit of measures for this template code - <cfoutput>#getProgramheader.template_code#</cfoutput>.<br>The program is not approved.</font> </div>
<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #program_id#
</CFQUERY>
<cfabort>
</cfif>

  <!--- <cfcatch type="application">
   <CFOUTPUT> <div align="center"><font size="2" color="red"><B>
   #cfcatch.message# - #cfcatch.detail# Could not connect to SAP, Please try again.</B></font></div>
	<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #program_id#
		</CFQUERY>
</cfoutput>
<cfabort>
   </cfcatch>
   
   <cfcatch type="Any">
      <CFOUTPUT> <div align="center"><font size="2" color="red"><B>
	 #cfcatch.message# - #cfcatch.detail# Could not connect to SAP, Please try again.</B></font></div></cfoutput>
	<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1 
			WHERE Contract_Main_Id = #program_id#
		</CFQUERY>
<cfabort>
   </cfcatch>
    <CFCATCH TYPE="xml">
                <CFOUTPUT><div align="center"> <font size="2" color="red"><B>Xml error: #cfcatch.message#<br>#cfcatch.detail#</B></font></div></CFOUTPUT>
	<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #program_id#
		</CFQUERY>
<cfabort>
     </CFCATCH>
	 
	</cftry>  --->
	
<cfelse>
Invalid Program Number
<CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
			UPDATE Contract_Main
			Set Sent_To_External_Client = 0,
			Error_From_External_Client = 1
			WHERE Contract_Main_Id = #program_id#
</CFQUERY>
</cfif>


</cfprocessingdirective>
