<cfset WebservicesManager = CreateObject("component","components.programs.Approval.Webservices_Manager") />

<cfset getProgramheader = WebservicesManager.getProgramheader(url.Program_ID,url.user_id)>

<cfset getDiscountTypeRates = WebservicesManager.getProgramRates(url.Program_ID,getwebservicedetails.program_discount_type_id,getProgramheader.template_code,getwebservicedetails.component_name_id)>

<cfset useLakebaseForgetprogramdetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_period_dates")>
<cfif useLakebaseForgetprogramdetails>
	<cftry>
		<cfset getprogramdetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_period_dates", {
				"bsa_program_id" = "eq.#getwebservicedetails.bsa_program_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetprogramdetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetprogramdetails>
<CFQUERY NAME="getprogramdetails" datasource="#application.datasource#">
 	select * from Program_period_dates
	where bsa_program_id = '#getwebservicedetails.bsa_program_id#'
 </CFQUERY>
</cfif>

<cfif getDiscountTypeRates.recordcount GT 0>
<cfset Discount_Type_ID = getwebservicedetails.program_discount_type_id>
			<cfif Discount_Type_ID EQ 3>
				<!---<cfset template_code = "LUMP">--->
				<cfset template_code = trim(getProgramheader.template_code)>
				<cfset UOM = "B">
			<cfelse>
				<cfset template_code = #trim(getProgramheader.template_code)#>
				<cfset UOM = #trim(getProgramheader.unit_of_measure)#>
			</cfif>
				
<cfoutput query="getDiscountTypeRates" group="Component_Name_ID">
<cfset tempxml = "<SOAP-ENV:Envelope xmlns:SOAP-ENV=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:SOAP-ENC=""http://schemas.xmlsoap.org/soap/encoding/""  xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""  xmlns:xsd=""http://www.w3.org/2001/XMLSchema""  xmlns:m0=""http://localhost/PTV_CONTRACTMTG/process/sapSubmitRebate""><SOAP-ENV:Body><m:sapSubmitRebate xmlns:m=""http://b2b.pactiv.com/BS/Rebate/PTV_CONTRACTMTG.process"" SOAP-ENV:encodingStyle=""http://schemas.xmlsoap.org/soap/encoding/"">" >
<cfset tempxml = tempxml & "<RebateHeader>">
<cfset tempxml = tempxml & "<RebateID>#getwebservicedetails.bsa_program_id#</RebateID>">
<cfset tempxml = tempxml & "<SAPRebateID></SAPRebateID>">
<cfset tempxml = tempxml & "<UpdateStatus></UpdateStatus>">
<cfset tempxml = tempxml & "<RebateDescription>#XMLFormat(getProgramheader.contract_title)#</RebateDescription>">
<cfset tempxml = tempxml & "<SalesOrganization>#getProgramheader.Line_Of_Business#</SalesOrganization>">
<cfset tempxml = tempxml & "<DistributionChannel>#getProgramheader.Business_Unit_Id#</DistributionChannel>">
<cfset tempxml = tempxml & "<TemplateCode>#template_code#</TemplateCode>">
<cfset tempxml = tempxml & "<PaymentFrequency>#getDiscountTypeRates.Payment_Cycle#</PaymentFrequency>">
<cfset tempxml = tempxml & "<Recipient>#getProgramheader.Shr_Ship_To#</Recipient>">
<cfset tempxml = tempxml & "<ValidFrom>#getprogramdetails.period_start_date#</ValidFrom>">
<cfset tempxml = tempxml & "<ValidTo>#getprogramdetails.period_end_date#</ValidTo>">
<cfset tempxml = tempxml & "<PaymentMethod>#getProgramheader.Payment_Type_Legacy_Id#</PaymentMethod>">
 <cfset tempxml = tempxml & "<ProgramManager>#getProgramheader.responsible_user#</ProgramManager>"> 
<cfset tempxml = tempxml & "<AccountSpecialist></AccountSpecialist>">
<cfset tempxml = tempxml & "<SalesRepresentative></SalesRepresentative>">
 <cfset tempxml = tempxml & "<ApprovedBy>#getProgramheader.approved_user#</ApprovedBy>"> 
<cfset tempxml = tempxml & "<ApprovedDate>#dateformat(getProgramheader.approval_date,"yyyymmdd")#</ApprovedDate>">
 <cfset tempxml = tempxml & "<CreatedByUser>#getProgramheader.creator_user#</CreatedByUser>"> 
<cfset tempxml = tempxml & "<CreatedDate>#dateformat(getProgramheader.Contract_Created_Date,"yyyymmdd")#</CreatedDate>">
<cfset tempxml = tempxml & "<LastChangedByUser></LastChangedByUser>">
<cfset tempxml = tempxml & "<LastChangeDate>#dateformat(now(),"yyyymmdd")#</LastChangeDate>">
<cfset tempxml = tempxml & "</RebateHeader>">

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
	<cfset tempxml = tempxml & "<BuyingGroup>#Buying_Group_Name#</BuyingGroup>">
	<cfif getDiscountTypeRates.Shr_Ship_To NEQ "Group">
			<cfset tempxml = tempxml & "<Customer>#getDiscountTypeRates.Shr_Ship_To#</Customer>">
	<cfelse>
		<cfset tempxml = tempxml & "<Customer></Customer>">
	</cfif>
</cfif>
<cfset tempxml = tempxml & "<ProductFamily>#getDiscountTypeRates.Product_group#</ProductFamily>">
<cfset tempxml = tempxml & "<CalculationType>#UOM#</CalculationType>">

<cfif Discount_Type_ID EQ 3>
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

<cfset lump_amount = currentlump>

<cfset tempxml = tempxml & "<Rate>#lump_amount#</Rate>">
<cfelse>
<cfset tempxml = tempxml & "<Rate>#getDiscountTypeRates.rate#</Rate>">
</cfif>


<cfset tempxml = tempxml & "<MaterialForSettlement>ADMIN_#getDiscountTypeRates.Product_group#</MaterialForSettlement>">
<cfset tempxml = tempxml & "<RebateConditionRecord></RebateConditionRecord>">
<cfset tempxml = tempxml & "<DeletionIndicator></DeletionIndicator>">
 <cfset tempxml = tempxml & "</m0:item#i#>">
 <cfset i=i+1>
</cfoutput>

<cfset tempxml = tempxml & "</RebateDetail>">
<cfset tempxml = tempxml & "</m:sapSubmitRebate></SOAP-ENV:Body></SOAP-ENV:Envelope>">

</cfoutput>

<cfset xmlDoc = XmlParse(tempxml)>
</cfif>



