	<!--- D28783: Release 7 EZ Button Max Rate
	- On RFA of an ez button program if template allows auto approval and if user have approval rights auto approve the products based on below rules.
	- On program approval, auto-approve logic need to be adjusted to account for each product. DONE DEEPA 10/18/2011
		When template is set as max rate, products that are within the template max rate can be auto approved
		When template is set as absolute rate, products that are included in the template product list can be auto approved
		Template max rate / product list should come from the latest version of the template.
		Products that did not get approved need to go through regular approval process and need to be approved from margin page
		Program can get auto approved if all products are auto-approved
	--->
	<cfset GetSettings = programManager.getProgramTemplateInfo(Contract_Main_ID) />
	
	<cfset Latest_EZ_Contract_ID = GetSettings.EZ_Contract_Id />
	<cfif getsettings.EZButton_On EQ 1 and URL.EZTemplate EQ 0><!--- AND GetSettings.Discount_Rebate_Max_Rate_On  EQ 0---->
		<!--- D45263 :: Create table to store max rates by template/profile --->
		<CFQUERY NAME="qProductsBeyondMaxRate" datasource="#application.datasource#">
			select	distinct BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description
			from	DBO.UDF_EZ_GET_PROGRAM_PRODUCTS (#Contract_Main_ID#, 'NOT_WITHIN_EZ_RATE', #request.AccessStructure.Profiles_ID#) as prod
			inner join BSA_Foodservice_Items_Master
			on	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = prod.BSA_Foodservice_Items_Master_ID
		</CFQUERY>
		
		<cfset lProductsBeyondMaxRateList = ValueList(qProductsBeyondMaxRate.BSA_Foodservice_Items_Master_ID) /> 
		
		<CFQUERY NAME="qGroupsWithNoMembers" datasource="#application.datasource#">
			<!--- Get groups that do not have members --->
			select	BSA_Foodservice_Items_Master_ID
			from	contract_products
			where	contract_main_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#Contract_Main_ID#" />
			and		Deleted = 0
			and		Is_Group = 1
			and		not exists
			(
				select	mem.contract_products_id
				from	contract_products mem
				where	mem.Contract_Main_ID = contract_products.Contract_Main_ID
				and		mem.Product_Group_ID = contract_products.BSA_Foodservice_Items_Master_ID
				and		mem.Product_Type_ID = contract_products.Product_Type_ID
				and		mem.Deleted = 0
				and		mem.Captured_From_Group = 1
			)
		</CFQUERY>
		
	<!--- Dev Note: drachala; D29041: Issues with EZ button  START    
    Added/Changed: Added "Your profile cannot approve beyond the max template rate." to list at front instead of adding to each and every alert message--->
	<cfif qProductsBeyondMaxRate.Recordcount or qGroupsWithNoMembers.Recordcount>
	<cfset strMessage = "Your profile cannot approve beyond the max template rate." & "\n" />
	</cfif>
	<!--- End Dev Note: drachala; D29054:  --->
		
	<cfif qGroupsWithNoMembers.Recordcount>
		<cfset MaxRateError = 1 />
		<cfset strMessage = strMessage & "Product group(s) on program does not have any members and therefore cannot be compared to the template EZ rate." & "\n" />
	</cfif>
	
		<!---   Your profile cannot approve beyond the max template rate. --->

		<cfloop query="qProductsBeyondMaxRate">
			<cfset MaxRateError = 1 />
			<!--- D32754: Rework 32620 
			Replace "&nbsp;" with empty space.
			--->
			<cfset strMessage = strMessage & currentRow & ")   " & item & " #description#" & " rates are beyond the max template rate." & "\n" />
		</cfloop>

	</cfif>

