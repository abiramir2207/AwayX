<cfoutput><!---Saves values entered in /billbacks/capture/program_components_discounts.cfm --->

<cfset useLakebaseForGetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetStatus>
	<cftry>
		<cfset GetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "billback_status_id"
			}), "billback_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStatus>
<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
	SELECT Billback_Status_ID FROM Billback WHERE Billback_ID = '#FORM.Billback_ID#'
</CFQUERY>
</cfif>
<CFIF GetStatus.Billback_Status_ID GTE 3> 
	<!--- 17302 - Redirect to Summary --->
	<CFSET Billback_Status_ID = GetStatus.Billback_Status_ID>
	<CFSET BB_ID_TO_Redirect = FORM.Billback_ID>
	<CFINCLUDE TEMPLATE = "BB_Summary_Redirect.cfm">
	<CFABORT>
</CFIF>

<!---  <cfdump var="#form#"> --->
<cfparam name="ParentFormName" default="">
<cfparam name="Form.ContractMainList" default="0">
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset DiscountList = "">

<!--- If it's not already there, add the program to billback_programs --->
<cfset useLakebaseForDoesBillbackProgramHaveValue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForDoesBillbackProgramHaveValue>
	<cftry>
		<cfset DoesBillbackProgramHaveValue = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#Billback_ID#",
				"program_id" = "eq.#Program_ID#",
				"deleted" = "eq.0",
				"select" = "billback_program_id,discount_list"
			}), "billback_program_id,discount_list"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDoesBillbackProgramHaveValue = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDoesBillbackProgramHaveValue>
<cfquery name="DoesBillbackProgramHaveValue" datasource="#application.datasource#">
Select Billback_Program_ID, Discount_List 
FROM Billback_Program
WHERE Billback_ID = '#Billback_ID#'
AND Program_ID = '#Program_ID#'
AND Deleted = 0
</cfquery>
</cfif>

<cfif DoesBillbackProgramHaveValue.Recordcount GT 0>
	<cfset Billback_Program_ID = DoesBillbackProgramHaveValue.Billback_Program_ID>
<cfelse>
<!--- Insert into Billback_Program --->
<cfset ShowProductsInGroupLevel = 0>
<cfquery name="getProgramInfo" datasource="#application.datasource#">
SELECT	dbo.Contract_Main.Contract_Number, 
	dbo.Contract_Main.Contract_Title, 
	dbo.Contract_Main.Contract_Start_Date, 
	dbo.Contract_Main.Contract_End_Date, 
	dbo.Contract_Main.Contract_Quantity, 
	dbo.Contract_Main.Contract_Main_ID, 
	dbo.Contract_Main.Contract_Status_Type_IDX,
	dbo.Program_Control_Panel_Options.Discount_Lump_Sums,dbo.Contract_Main.ProgramType_ID,
	(
		SELECT 	aaa.GroupLevelBB 
		FROM 	Program_Latest_Template_ID 
				INNER JOIN Program_Control_Panel_Options aaa ON 
				aaa.ProgramControl_Panel_Options_ID = Program_Latest_Template_ID.Latest 
		WHERE 	Program_Latest_Template_ID.ProgramControl_Panel_Options_ID=dbo.Contract_Main.ProgramType_ID
	)as GroupLevelBB
FROM  dbo.Contract_Main 
	INNER JOIN dbo.Program_Control_Panel_Options ON 
	dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
WHERE	(dbo.Contract_Main.Contract_Main_ID = #Program_ID#)				
</cfquery>

<cfif appSettings.getUseProductHierarchy() AND getProgramInfo.GroupLevelBB EQ 1>
	<CFSET ShowProductsInGroupLevel = 1>							
</cfif>

	<cfset useLakebaseForInsertIntoBillbackProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForInsertIntoBillbackProgram>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_program", {
			"billback_id" = "#Billback_ID#",
			"display_product_hierarchy" = "#ShowProductsInGroupLevel#",
			"program_id" = "#Program_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertIntoBillbackProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertIntoBillbackProgram>
<cfquery name="InsertIntoBillbackProgram" datasource="#application.datasource#">
	INSERT INTO Billback_Program
	(
		Billback_ID,
		Display_Product_Hierarchy,								
		Program_ID
	)
	VALUES
	(
		'#Billback_ID#',
		'#ShowProductsInGroupLevel#',
		'#Program_ID#'
	)
	</cfquery>
</cfif>
	
	<cfset useLakebaseForGetBillbackProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForGetBillbackProgramID>
	<cftry>
		<cfset GetBillbackProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#Billback_ID#",
				"program_id" = "eq.#Program_ID#",
				"deleted" = "eq.0",
				"select" = "billback_program_id"
			}), "billback_program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBillbackProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBillbackProgramID>
<cfquery name="GetBillbackProgramID" datasource="#application.datasource#">
	Select Billback_Program_ID 
	FROM Billback_Program
	WHERE Billback_ID = '#Billback_ID#'
	AND Program_ID = '#Program_ID#'
	AND Deleted = 0
	</cfquery>
</cfif>
	<cfset Billback_Program_ID = GetBillbackProgramID.Billback_Program_ID>
</cfif>

<!--- END insert program --->

<!--- Fixed Price --->
<cfif isDefined("form.IncludeFixedPrice") AND form.IncludeFixedPrice IS 1>
	<Cfset DiscountList = listappend(DiscountList, "1")>
</cfif>

<!--- Add rebate --->

<!---handle for claims at the component level--->
<cfif isDefined("form.Program_Rebates_Component_Name_ID")>
	
	<!---clear out any existing entries--->
	<cfquery name="DeletePriorRebateData" datasource="#application.datasource#">
		UPDATE	Billback_Program_Rebate_Component
		SET		Deleted = 1,
				Deleted_Date = GetDate(),
				Deleted_By = 'component pop up',
				Insert_Component_List = <cfqueryparam value="#Left(form.Program_Rebates_Component_Name_ID, 50)#" cfsqltype="cf_sql_varchar"> 
		WHERE	Billback_ID = '#Form.Billback_ID#'
		AND		Billback_Program_ID = '#Program_ID#'
	</cfquery>
	
	<!---Loop through selected rebate components--->
	<cfset ShowRebate = 0>
	<cfloop index="variables.rebIndx" list="#form.Program_Rebates_Component_Name_ID#">
		<cfset Current_Program_Rebates_Component_ID = variables.rebIndx />
		<cfquery name="ComponentName" datasource="#application.datasource#">
			SELECT TOP 1 Program_Rebates_Component.Program_ID,
					Program_Rebates_Component.Program_Rebates_Component_ID,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID,
					Program_Rebates_Component_Name.Program_Rebates_Component_Name
			FROM 	Program_Rebates_Component
			INNER JOIN Program_Rebates_Component_Name 
			ON		Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
			WHERE 	Program_Rebates_Component.Deleted = 0
			AND		Program_Rebates_Component.Program_Rebates_Component_Name_ID = '#Current_Program_Rebates_Component_ID#'
			AND 	(Program_Rebates_Component.Component_Paid_To = #Payee_Type_ID#
			OR
					(Program_Rebates_Component.Component_Paid_To = 4 
					AND #Payee_Type_ID# != 3)
			)
			AND 	Program_Rebates_Component.Program_ID IN (#Form.ContractMainList#)
			ORDER BY Program_Rebates_Component.Program_ID DESC
		</cfquery>
				
		<cfset CompName = ComponentName.Program_Rebates_Component_Name />
		<cfset ProgramCompId = ComponentName.Program_Rebates_Component_ID />
							
		<cfquery name="qInsertRebateData" datasource="#application.datasource#">
			INSERT INTO Billback_Program_Rebate_Component
			(
				Billback_ID, 
				Billback_Program_ID, 
				Program_Rebates_Component_Name, 
				Program_Rebates_Component_Name_ID, 
				Program_Rebates_Component_ID,
				Checked
			)
			VALUES
			(
				'#Form.Billback_ID#', 
				'#Program_ID#', 
				'#CompName#', 
				'#Current_Program_Rebates_Component_ID#',
				'#ProgramCompId#', 
				'true'
			)
		</cfquery>
		<cfset ShowRebate = 1>
		
	</cfloop><!---END Loop through selected rebate components--->
	
	<!--- Rebate --->
	<cfif ShowRebate IS 1>
		<Cfset DiscountList = listappend(DiscountList, "2")>
	</cfif>
	
</cfif><!---END handle for claims at the component level--->
<!--- End rebates<br> --->

<!--- Growth --->
	<cfif isDefined("form.IncludeGrowth") AND form.IncludeGrowth IS 1>
		<Cfset DiscountList = listappend(DiscountList, "4")>
	</cfif>

<!--- Formula --->
	<cfif isDefined("form.IncludeFormula") AND form.IncludeFormula IS 1>
		<Cfset DiscountList = listappend(DiscountList, "5")>
	</cfif>
	
<!--- TODO: Do again for Bid Request --->
<cfif appSettings.Claims_at_Comp_Level AND isDefined("form.Program_BidRequest_Component_ID")>

<!---clear out any existing entries--->
	<cfset useLakebaseForqInsertBidRequestData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program_bidrequest_component")>
<cfif useLakebaseForqInsertBidRequestData>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_program_bidrequest_component",
			{
				"billback_id" = "eq.#Form.Billback_ID#",
				"billback_program_id" = "eq.#Program_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertBidRequestData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertBidRequestData>
<cfquery name="qInsertBidRequestData" datasource="#application.datasource#">
		UPDATE	Billback_Program_BidRequest_Component
		SET		Deleted = 1
		WHERE	Billback_ID = '#Form.Billback_ID#'
		AND		Billback_Program_ID = '#Program_ID#'
	</cfquery>
</cfif>
	
	<!---Loop through selected bid request components--->
	<cfset ShowBidRequest = 0>
	<cfloop index="variables.rebIndx" list="#Program_BidRequest_Component_ID#">
								
		<cfquery name="ComponentName" datasource="#application.datasource#">
		SELECT 	Program_BidRequest_Component_Name.Program_BidRequest_Component_Name, 
				Payment_Paid_To_Types.Payment_Paid_To_Type_Name,
				Program_BidRequest_Component.Program_BidRequest_Component_Name_ID
	FROM 	Program_BidRequest_Component
			INNER JOIN Program_BidRequest_Component_Name ON
			Program_BidRequest_Component_Name.Program_BidRequest_Component_Name_ID = Program_BidRequest_Component.Program_BidRequest_Component_Name_ID
			LEFT JOIN Payment_Paid_To_Types ON 
			Payment_Paid_To_Types.Payment_Paid_To_Type_ID = Program_BidRequest_Component.Program_BidRequest_Component_Paid_To
	WHERE 	Program_BidRequest_Component.Deleted = 0
	AND 	Program_BidRequest_Component.Program_ID = #Program_ID#
	AND 	Program_BidRequest_Component.Program_BidRequest_Component_ID = #variables.rebIndx#
		</cfquery>
		
		<cfset BRCompName = ComponentName.Program_BidRequest_Component_Name>
							
		<cfquery name="qInsertBidRequestData" datasource="#application.datasource#">
			INSERT INTO Billback_Program_BidRequest_Component
			(
				Billback_ID, 
				Billback_Program_ID, 
				Program_BidRequest_Component_Name, 
				Program_BidRequest_Component_Name_ID, 
				Program_BidRequest_Component_ID,
				Checked
			)
			VALUES
			(
				'#Form.Billback_ID#', 
				'#Program_ID#', 
				'#BRCompName#', 
				'#variables.rebIndx#', 
				'#ComponentName.Program_BidRequest_Component_Name_ID#',
				'true'
			)
		</cfquery>
		<cfset ShowBidRequest = 1>
	</cfloop><!---END Loop through selected bidrequest components--->
	
	<!--- Bid Request ---> 
	<cfif ShowBidRequest IS 1>
		<Cfset DiscountList = listappend(DiscountList, "11")>
	</cfif>
	
</cfif>


<!--- Lump sums --->

<!--- Delete prior lump sums --->
<cfset useLakebaseForDeletePriorLS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program_lumpsum_component")>
<cfif useLakebaseForDeletePriorLS>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_program_lumpsum_component",
			{
				"billback_id" = "eq.#Billback_ID#",
				"billback_program_id" = "eq.#Billback_Program_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeletePriorLS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeletePriorLS>
<cfquery name="DeletePriorLS" datasource="#application.datasource#">
UPDATE Billback_Program_Lumpsum_Component
SET Deleted = 1
WHERE Billback_ID = '#Billback_ID#'
AND Billback_Program_ID = '#Billback_Program_ID#'
</cfquery>
</cfif>

<cfif isDefined("LSList")>
<cfloop list="#LSList#" index="SafeLSID">

<cfset PROGRAM_LUMP_SUM_ID = 	replace(SafeLSID, "_", "-", "ALL") />
<!--- Only insert if they actually saved a value --->
<cfif isNumeric(evaluate("LumpSum_#SafeLSID#")) and len(evaluate("LumpSum_#SafeLSID#")) GT 0>
	 <cfquery name="InsertLumpSum" datasource="#Application.Datasource#">
		INSERT INTO Billback_Program_Lumpsum_Component
		(Billback_ID, Billback_Program_ID,Component_Type_ID,Program_Lump_Sum_ID,Amount)
		VALUES
		('#Billback_ID#', '#Billback_Program_ID#',1,'#PROGRAM_LUMP_SUM_ID#',#evaluate("LumpSum_#SafeLSID#")#)
	</cfquery>
</cfif>
</cfloop>
</cfif>
<!--- End Lump sum<br> --->
	
<!--- Save growth lump sums--->
<!--- Prior lump sums deleted before regular lump sums --->
<cfif isDefined("GrowthLSList")>
<cfloop list="#GrowthLSList#" index="SafeLSID">
<cfset FieldLength = len(SafeLSID)>
<cfset TierIDDividerLocation = find("__", SafeLSID)>
<cfset GrowthComponentID = left(SafeLSID, (TierIDDividerLocation-1))>
<cfset GrowthTier  = right(SafeLSID, (FieldLength - (TierIDDividerLocation+1)))>
<cfset Component_Tier_ID = replace(GrowthTier, "_", "-", "ALL") />
<cfset Growth_LUMP_SUM_ID = 	replace(GrowthComponentID, "_", "-", "ALL") />

<cfif isNumeric(evaluate("GrowthLS_#GrowthComponentID#__#GrowthTier#")) and len(evaluate("GrowthLS_#GrowthComponentID#__#GrowthTier#")) GT 0>
	<cfquery name="InsertGrowthLumpSum" datasource="#Application.Datasource#">
	INSERT INTO Billback_Program_Lumpsum_Component
	(Billback_ID, Billback_Program_ID,Component_Type_ID,Program_Lump_Sum_ID,Amount,Program_Growth_Component_Tier_ID)
	VALUES
	('#Billback_ID#', '#Billback_Program_ID#',3,'#Growth_LUMP_SUM_ID#',#evaluate("GrowthLS_#GrowthComponentID#__#GrowthTier#")#, '#Component_Tier_ID#')
	</cfquery>  
</cfif>
</cfloop>	

</cfif>


<!--- Enter data for other discount types --->

<!--- If a discount type got deleted, delete entries for those products --->
<cfif listlen(DoesBillbackProgramHaveValue.Discount_List) GT 0>
<cfset DeleteProductFromTheseDiscounts = "">
<cfloop list="#DoesBillbackProgramHaveValue.Discount_List#" index="DiscountID">
	<Cfif NOT listcontains(DiscountList, DiscountID)>
		<cfset DeleteProductFromTheseDiscounts = listappend(DeleteProductFromTheseDiscounts, DiscountID)>
	</CFIF>
</cfloop>

<cfif listlen(DeleteProductFromTheseDiscounts) GT 0>
<cfquery name="UpdateAppropriateProducts" datasource="#application.datasource#">
UPDATE Billback_Product_Detail
SET Billback_Product_Detail.BB_Rate = 0
FROM Billback_Product_Detail
	INNER JOIN Billback_Product
	ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
	AND Billback_Program_ID = '#Billback_Program_ID#'
WHERE BB_Product_Type_ID IN (#DeleteProductFromTheseDiscounts#)
AND Billback_Product_Detail.Billback_ID = '#Billback_ID#'
AND Billback_Product.Billback_ID = '#Billback_ID#'
</cfquery>
</cfif>
</cfif>

	<cfset useLakebaseForAddDiscountList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForAddDiscountList>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_program",
			{
				"billback_program_id" = "eq.#Billback_Program_ID#"
			},
			{
				"discount_list" = "#DiscountList#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAddDiscountList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAddDiscountList>
<cfquery name="AddDiscountList" datasource="#application.datasource#">
	UPDATE Billback_Program
	SET Discount_List = '#DiscountList#'
	WHERE Billback_Program_ID = '#Billback_Program_ID#'
	</cfquery>
</cfif>
	
	
	<!--- Don't go to product page if only lump sum has been selected --->
	<cfif len(trim(DiscountList)) IS 0 AND len(trim(LocationURL)) LT 1>
		<script>
			opener.document.all.KnownProgramForm.submit()
			window.close()	
		</script>
	<cfabort>
	</cfif>
	
	<cfif len(trim(LocationURL)) GT 0 AND len(trim(DiscountList)) IS 0>
		<cfset LocationURL = "program_form.cfm?BBID=#Billback_ID#">
	</cfif>
	
	<cfif NOT isDefined("LocationURL") OR len(Trim(LocationURL)) LT 1>
		<cfset LocationURL="SelectProductsFromProgram.cfm?Formname=KnownProgramForm&PID="&#Program_ID#&"&BBID="&#Billback_ID#&"&payType="&#Payee_Type_ID#&"&DiscountList="&#DiscountList#>
	<cfelse>
	<!--- append discount list --->
		<cfset LocationURL = LocationUrl & DiscountList>
	</cfif>

	<cflocation url="#LocationURL#"> 

	</cfoutput>	

