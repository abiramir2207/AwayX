<cfif NOT(isDefined("GetSettings"))>

  <cfquery name="GetSettings" datasource="#application.datasource#">
  	SELECT Program_Control_Panel_Options.*
  	FROM 
  		Program_Control_Panel_Options
      INNER JOIN Contract_Main
			ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
  	WHERE 
  		Contract_Main.Contract_Main_ID = '#trim(Contract_Main_ID)#'
  </cfquery>
</cfif>
	<cfset DiscountFound=0 />
  <cfset TotalDiscounts = 0 />
  <cfset bAllowAddComp = 1 />
 
<CFIF (GetSettings.Allow_Only_One_Discount EQ 1)>	
	<!---This include queries each discount type to see if one has been added to the program--->
<!--- 	<cfset Contract_Main_ID = Contract_Main_ID> --->
	
	<cfinclude template="discount_queries.cfm">
	<!---This include has the following queries:
		FixedPricesStatus
		FormulaStatus
		RebateStatus
		GrowthStatus
		LumpStatus
		getBidRequestProducts
		Off_Invoice
	--->
 

	
	<!---Fixed--->
	<CFIF ((GetSettings.Discount_Fixed_Prices EQ 1) AND (sDiscountType NEQ "FIXED"))>
  	<cfif FixedPricesStatus.Recordcount GT 0>
  		<cfset DiscountFound = 1 />
      <cfset TotalDiscounts = TotalDiscounts + 1 />
  	</cfif>
	</cfif>
  
	<!---Formula--->
	<CFIF ((GetSettings.Discount_Formula_Pricing EQ 1) AND (sDiscountType NEQ "FORMULA_PRICING"))>
	<cfif FormulaStatus.Recordcount GT 0>
		<cfset DiscountFound = 1 />
    <cfset TotalDiscounts = TotalDiscounts + 1 />    
	</cfif>
	</cfif>
	
	<!---Rebate--->
	<CFIF ((GetSettings.Discount_Rebates EQ 1) AND (sDiscountType NEQ "REBATE"))>
	<cfif RebateStatus.Recordcount GT 0>
		<cfset DiscountFound = 1 />
    <cfset TotalDiscounts = TotalDiscounts + 1 />    
	</cfif>
	</cfif>
	<!---Growth--->
	<CFIF ((GetSettings.Discount_Growth EQ 1) AND (sDiscountType NEQ "GROWTH"))>
	<cfif GrowthStatus.Recordcount GT 0>
		<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />    
	</cfif>
	</cfif>
	
	<!---Lump Sum--->
	<CFIF ((GetSettings.Discount_Lump_Sums EQ 1) AND (sDiscountType NEQ "LUMPSUM"))>
	<cfif LumpStatus.Recordcount GT 0>
		<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />    
	</cfif>
	</cfif>
	<!---Bid request--->
	<cfif ((GetSettings.Generic_Type IS "Bid Request" AND GetSettings.Discount_BidRequest EQ 1) AND (sDiscountType NEQ "BIDREQUEST"))>
		<cfif BidStatus.recordcount GT 0>
			<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />      
		</cfif>
	</cfif>
	
	<!---Off Invoice--->
	<cfif ((GetSettings.Generic_Type IS "Distributor Off-Invoice") AND (sDiscountType NEQ "DISTOFFINVOICE"))>
		<cfif Off_Invoice.Recordcount GT 0>
			<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />      
		</cfif>
	</cfif>

	<!---Bid rules--->
	<!---Bid rules logic not in palce--->
	
<!--- 	<cfif DiscountFound IS 0>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "You should have at least one discount offered to approve this program")>
	</cfif> --->
  
	<cfif (GetSettings.Allow_Only_One_Discount EQ 1)>
    <cfif (TotalDiscounts GTE 1)>
      <cfset letUserProceed = 0 />
      <cfset bAllowAddComp = 0 />
<!---       <cfset ArrayAppend(messageArray, "This program can only have one discount type.  Please remove a discount type.")> --->
    </cfif>
  </cfif>
  
  
<!---Require discount--->
</CFIF>
 