<CFQUERY NAME="getParentProgram" datasource="#application.datasource#">
			SELECT Renewal_Of_Contract_Main_ID
			FROM Contract_main
			WHERE Contract_main_ID = '#Program_ID#'
</CFQUERY>


<CFIF getParentProgram.recordcount GT 0>
	<CFIF getParentProgram.Renewal_Of_Contract_Main_ID NEQ "">
	<cfset RollOverProgramManager = CreateObject("component","components.programs.RollOverProgramApproval.RollOverProgramManager") />

<cfset qGetContractInfo = RollOverProgramManager.GetContractInfo(getParentProgram.Renewal_Of_Contract_Main_ID)>

<CFIF qGetContractInfo.recordcount GT 0>

<CFSET programtype_id = qGetContractInfo.ProgramType_ID>
	<cfset qGetContractTemplateInfo = RollOverProgramManager.GetTemplateSettings(programtype_id)>

<CFSET HasFixedPrice = qGetContractTemplateInfo.Discount_Fixed_Prices>
<CFSET HasRebatePrice = qGetContractTemplateInfo.Discount_Rebates>
<CFSET HasLumpsum = qGetContractTemplateInfo.Discount_Lump_Sums>
<cfset rollover_allowed = 1>

	
<!--- Lumpsum check --->
	
<CFIF HasLumpsum>
	<cfset qParentLumpSum = RollOverProgramManager.GetLumpSumAmount(getParentProgram.Renewal_Of_Contract_Main_ID)>
<cfset qCurrentLumpSum = RollOverProgramManager.GetLumpSumAmount(Program_ID)>
<CFIF qParentLumpSum.TotalLumpsumAmount LT qCurrentLumpSum.TotalLumpsumAmount>
	<CFSET rollover_allowed = 0>
</CFIF>
</CFIF> 

<!---End Lumpsum check --->

<!--- Fixed Price check --->
<CFIF HasFixedPrice and NOT HasRebatePrice>
<cfset qFixedPrices = RollOverProgramManager.GetFixedAmount(getParentProgram.Renewal_Of_Contract_Main_ID,Program_ID)>

<CFLOOP query="qFixedPrices">
	<CFIF qFixedPrices.CurrentProgramFixedPrice LT qFixedPrices.ParentProgramFixedPrice>
		<CFSET rollover_allowed = 0> 
	</CFIF>
	<CFIF rollover_allowed EQ 0>
		<CFBREAK>
	</CFIF>
</CFLOOP>
</CFIF>


<!---End Fixed Price check --->

<!--- Rebate Price check --->
<CFIF NOT HasFixedPrice and HasRebatePrice>
	<cfset qRebatePrices = RollOverProgramManager.GetRebateAmount(getParentProgram.Renewal_Of_Contract_Main_ID,Program_ID)>

	<CFLOOP query="qRebatePrices">
		<CFIF qRebatePrices.CurrentProgramRebatePrice GT qRebatePrices.ParentProgramRebatePrice>
			<CFSET rollover_allowed = 0> 
		</CFIF>
		<CFIF rollover_allowed EQ 0>
			<CFBREAK>
		</CFIF>
	</CFLOOP>
</CFIF>


<CFIF HasFixedPrice and HasRebatePrice>
<cfset qRebatePrices = RollOverProgramManager.GetRebateAmount(getParentProgram.Renewal_Of_Contract_Main_ID,Program_ID)>
<cfset qFixedPrices = RollOverProgramManager.GetFixedAmount(getParentProgram.Renewal_Of_Contract_Main_ID,Program_ID)>

<CFSET qFixedPriceProducts = ValueList(qFixedPrices.BSA_Foodservice_Items_Master_Id,",")>
<CFSET qRebatePriceProducts = ValueList(qRebatePrices.BSA_Foodservice_Items_Master_Id,",")>

	<CFLOOP query="qFixedPrices">
		<cfquery name="GetRebatePrice" dbtype="query">
		SELECT CurrentProgramRebatePrice,ParentProgramRebatePrice
		FROM 
		qRebatePrices
		WHERE 
		BSA_Foodservice_Items_Master_Id = '#qFixedPrices.BSA_Foodservice_Items_Master_Id#'
</cfquery>

<CFIF GetRebatePrice.recordcount GT 0>
<CFSET currentprogramnetprice = qFixedPrices.CurrentProgramFixedPrice - GetRebatePrice.CurrentProgramRebatePrice>
<CFSET parentprogramnetprice = qFixedPrices.parentProgramFixedPrice - GetRebatePrice.parentProgramRebatePrice>
	<CFIF parentprogramnetprice GT currentprogramnetprice>
		<CFSET rollover_allowed = 0>
	</CFIF>
</CFIF>
	<CFIF rollover_allowed EQ 0>
		<CFBREAK>
	</CFIF>
	</CFLOOP>
	
<cfquery name="GetRebatesNotinFixed" dbtype="query">
		SELECT *
		FROM 
		qRebatePrices
		WHERE 
		BSA_Foodservice_Items_Master_Id NOT IN('#qFixedPriceProducts#')
</cfquery>

<CFIF GetRebatesNotinFixed.recordcount GT 0>
		<CFLOOP query="GetRebatesNotinFixed">
		<CFIF GetRebatesNotinFixed.CurrentProgramRebatePrice GT GetRebatesNotinFixed.ParentProgramRebatePrice>
			<CFSET rollover_allowed = 0> 
		</CFIF>
		<CFIF rollover_allowed EQ 0>
			<CFBREAK>
		</CFIF>
	</CFLOOP>

</CFIF>

<cfquery name="GetFixedNotinRebate" dbtype="query">
		SELECT *
		FROM 
		qFixedPrices
		WHERE 
		BSA_Foodservice_Items_Master_Id NOT IN('#qRebatePriceProducts#')
</cfquery>

<CFIF GetFixedNotinRebate.recordcount GT 0>
		<CFLOOP query="GetFixedNotinRebate">
		<CFIF GetFixedNotinRebate.CurrentProgramFixedPrice LT GetFixedNotinRebate.ParentProgramFixedPrice>
			<CFSET rollover_allowed = 0> 
		</CFIF>
		<CFIF rollover_allowed EQ 0>
			<CFBREAK>
		</CFIF>
	</CFLOOP>

</CFIF>


</CFIF>
<!---End Rebate Price check --->
		</CFIF>
	</CFIF>
</CFIF>
<!--- <CFIF isDefined("qFixedPrices")>
<cfdump var="#qFixedPrices#">
</CFIF>
<CFIF isDefined("qRebatePrices")>
<cfdump var="#qRebatePrices#">
</CFIF> --->

