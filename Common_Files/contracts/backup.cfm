<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<CFSET FORM.Program_ID = cryp.value>
<cfset thisProduct_Tier_Data_List ="">

<CFLOOP INDEX="theFieldName" LIST="#FORM.FIELDNAMES#">
	<CFIF left(theFieldName, 13) EQ "WEEKLY_VOLUME">

		<CFSET thisProduct_WeeklyVolume = evaluate(theFieldName)>
		<CFSET thisProduct_Product_ID = right(theFieldName, 36)>

		<CFQUERY NAME="getProdDataID" datasource="#application.datasource#">
			SELECT  dbo.Contract_Products.BSA_Foodservice_Items_Master_ID, 
			                      dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID,dbo.Program_Growth_Component_Product_Data.Contract_Products_ID
			FROM         dbo.Program_Growth_Component_Product_Data INNER JOIN
			                      dbo.Contract_Products ON 
			                      dbo.Program_Growth_Component_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID
			WHERE     (dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#FORM.Component_ID#') AND 
			                      (dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = '#replace(thisProduct_Product_ID, "_", "-", "ALL")#')
								  AND (dbo.Contract_Products.Deleted = 0)
		</CFQUERY>
		
		<cfset useLakebaseForupdateWeeklyVolume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_component_product_data")>
<cfif useLakebaseForupdateWeeklyVolume>
	<cftry>
		<cfset application.oLakebase.updateRows("program_growth_component_product_data",
			{
				"program_growth_component_product_data_id" = "eq.#getProdDataID.Program_Growth_Component_Product_Data_ID#"
			},
			{
				"weekly_volume" = "#thisProduct_WeeklyVolume#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateWeeklyVolume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateWeeklyVolume>
<CFQUERY NAME="updateWeeklyVolume" datasource="#application.datasource#">
			UPDATE Program_Growth_Component_Product_Data
			SET
				Weekly_Volume = '#thisProduct_WeeklyVolume#'
			WHERE Program_Growth_Component_Product_Data_ID = '#getProdDataID.Program_Growth_Component_Product_Data_ID#'
		</CFQUERY>
</cfif>

			<CFLOOP INDEX="Tier_ID" LIST="#FORM.Tier_List#" DELIMITERS=",">
				<!--- insert Product ID --->
				<cfset thisProduct_Tier_Data_List = listappend(thisProduct_Tier_Data_List, thisProduct_Product_ID, ",")>
				<!--- insert tier ID --->
				<cfset thisProduct_Tier_Data_List = listappend(thisProduct_Tier_Data_List, Tier_ID, ",")>
				<!--- insert tier rate --->
				<cfset thisProduct_Tier_Data_List = listappend(thisProduct_Tier_Data_List, evaluate("FORM.Tier_#Tier_ID#_Product_Rate_#thisProduct_Product_ID#"), ",")>
				<!--- insert tier UOM --->
				<cfset thisProduct_Tier_Data_List = listappend(thisProduct_Tier_Data_List, evaluate("FORM.Tier_#Tier_ID#_Product_Rate_#thisProduct_Product_ID#_UOM"), ",")>
				<!--- insert Program_Growth_Component_Product_Data ID --->
				<cfset thisProduct_Tier_Data_List = listappend(thisProduct_Tier_Data_List, evaluate("FORM.Tier_#thisProduct_Product_ID#_TheID"), ",")>

			</CFLOOP>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="LoopCount" FROM="1" TO="#listlen(thisProduct_Tier_Data_List)#" STEP="5">
	<!--- product id --->
		<CFSET ListPosition = LoopCount>
	<CFSET BSA_Foodservice_Items_Master_ID = replace(listgetat(thisProduct_Tier_Data_List,ListPosition,","), "_", "-","ALL")>
	<!--- tier id --->
		<CFSET ListPosition = LoopCount+1>
	<CFSET Program_Growth_Component_Tier_ID = replace(listgetat(thisProduct_Tier_Data_List,ListPosition,","), "_", "-","ALL")>
	<!--- tier rate --->
		<CFSET ListPosition = LoopCount+2>
	<CFSET Rate = listgetat(thisProduct_Tier_Data_List,ListPosition,",")>
	<!--- UOM --->
		<CFSET ListPosition = LoopCount+3>
	<CFSET Unit_Of_Measure_ID = listgetat(thisProduct_Tier_Data_List,ListPosition,",")>
	<!--- Product ID --->
		<CFSET ListPosition = LoopCount+4>
	<CFSET The_Program_Growth_Component_Product_Tier_Data_ID = listgetat(thisProduct_Tier_Data_List,ListPosition,",")>
	
	<CFQUERY NAME="checkForExistingTierInfo" datasource="#application.datasource#">
		SELECT     dbo.Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Tier_Data_ID, 
		                      dbo.Program_Growth_Component_Product_Data.Contract_Products_ID
		FROM         dbo.Program_Growth_Component_Product_Data INNER JOIN
		                      dbo.Program_Growth_Component_Product_Tier_Data ON 
		                      dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID = dbo.Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID
		                       INNER JOIN
		                      dbo.Contract_Products ON 
		                      dbo.Program_Growth_Component_Product_Data.Contract_Products_ID = dbo.Contract_Products.Contract_Products_ID
		WHERE     (dbo.Program_Growth_Component_Product_Data.Deleted = 0) AND (dbo.Program_Growth_Component_Product_Tier_Data.Deleted = 0) AND 
		           (dbo.Contract_Products.Deleted = 0) AND
					(dbo.Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID = '#Program_Growth_Component_Tier_ID#')
	</CFQUERY>

 	<CFIF checkForExistingTierInfo.recordcount EQ 0>
	<!--- insert --->
		<cfset useLakebaseForinsertTierProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_component_product_tier_data")>
<cfif useLakebaseForinsertTierProductData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_growth_component_product_tier_data", {
			"program_growth_component_product_data_id" = "#The_Program_Growth_Component_Product_Tier_Data_ID#",
			"program_growth_component_tier_id" = "#Program_Growth_Component_Tier_ID#",
			"rate" = "#Rate#",
			"unit_of_measure_id" = "#Unit_Of_Measure_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertTierProductData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertTierProductData>
<CFQUERY NAME="insertTierProductData" datasource="#application.datasource#">
			INSERT INTO Program_Growth_Component_Product_Tier_Data
			(Program_Growth_Component_Product_Data_ID,Program_Growth_Component_Tier_ID, Rate, Unit_Of_Measure_ID)
			VALUES
			('#The_Program_Growth_Component_Product_Tier_Data_ID#', '#Program_Growth_Component_Tier_ID#', '#Rate#','#Unit_Of_Measure_ID#')
		</CFQUERY>
</cfif>
	
	<CFELSE>
	<!--- update --->
		<cfset useLakebaseForupdateTierData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_component_product_tier_data")>
<cfif useLakebaseForupdateTierData>
	<cftry>
		<cfset application.oLakebase.updateRows("program_growth_component_product_tier_data",
			{
				"program_growth_component_product_tier_data_id" = "eq.#checkForExistingTierInfo.Program_Growth_Component_Product_Tier_Data_ID#"
			},
			{
				"rate" = "#Rate#",
				"unit_of_measure_id" = "#Unit_Of_Measure_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateTierData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateTierData>
<CFQUERY NAME="updateTierData" datasource="#application.datasource#">
			UPDATE Program_Growth_Component_Product_Tier_Data
			SET
				Rate 				= '#Rate#',
				Unit_Of_Measure_ID 	= '#Unit_Of_Measure_ID#'
			WHERE Program_Growth_Component_Product_Tier_Data_ID = '#checkForExistingTierInfo.Program_Growth_Component_Product_Tier_Data_ID#'
		</CFQUERY>
</cfif>
	</CFIF>

 </CFLOOP>

<CFLOCATION URL="Contract_Discount_Growth.cfm?CID=#cryp.string#">