<!---
       Name:          Auto_Revise_Program_Custom.cfm 
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  07/15/2006
       Created By:    kvangapalli
       Label:		  12522, 10201
       Description:   This file is used to auto renew bunch of programs selected in the query. 
						Add two columns (CHANGE_COMPLETED, NEW_CONTRACT_MAIN_ID) to the table holding the program_ID's. These columns are used to filter selection. 
						Certain values like Start_Date, End_Date are set below. So whereever a 'Dev Note' appears below, set the appropriate values.
--->

<!---********* For SIMPLOT -- Don't schedule or run this job before 9:00pm EST. *********--->
<!---*** Removed the Stored Proc as we would be running the SP manually and scheduling the Mass Price to run in batches of 25. ***--->

<cfquery name="Programs_Custom_Revision" datasource="#application.datasource#">
	SELECT Top 25 CONTRACT_MAIN_ID, CONTRACT_NUMBER, New_Start_Date, New_End_Date, Responsible_User_ID 
	FROM  PriceChangeProgramList
	WHERE Killed = 0 AND Skip = 0 AND Copied = 0 AND Skip_Copy = 0 
	ORDER BY  CONTRACT_NUMBER, CONTRACT_MAIN_ID
</cfquery>

<!--- Setting Variables --->
<cfset Scheduled = 1>
<cfset NumberUpdated = 0> <!--- Just an indicator of number of programs renewed --->
<cfset Form.IsAutoCopy = 1 />
<cfset Form.ForceFreightOnAutoCopy = 0 />
<cfset programObj = CreateObject("component", "components.programs.program") />
<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
<cfset variables.BizCon = "This program has been systematically created due to a price increase effective - " & DateFormat(Programs_Custom_Revision.New_Start_Date, "mm/dd/yyyy") />
<!--- /////////////////////////////////////////////////////////////////////////////////////////////////// --->

<cfloop query="Programs_Custom_Revision">
	<!---sets all the stuff that contract revision needs--->
	<cfset Program_ID_To_Replicate = Programs_Custom_Revision.CONTRACT_MAIN_ID />
	<cfset programNumberToUseForAdd = Programs_Custom_Revision.CONTRACT_NUMBER />
	
	<cfset New_Pgm_Start_Date 	= Programs_Custom_Revision.New_Start_Date	/>	
	<cfset New_Pgm_End_Date 	= Programs_Custom_Revision.New_End_Date	/>

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
	
		
	<cfquery name="qGetProgram" datasource="#application.datasource#">
		SELECT 	Original_Creating_User_Position_ID, 
				Creating_User_Position_ID, 
				Creator_ID,
				Responsible_User_ID,
				Contract_Number,
				Notes,
				Contract_Start_Date,
				Contract_End_Date,
				Contract_Quantity,
				Notes
		FROM 	Contract_Main
		WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
	</cfquery>
		
	<cfset Original_Creating_User_Position_ID = qGetProgram.Original_Creating_User_Position_ID>
	<cfset User_Position_ID = qGetProgram.Creating_User_Position_ID>
	<cfset request.AccessStructure.Creating_User_Position_ID = qGetProgram.Creating_User_Position_ID>
	<cfset request.AccessStructure.User_ID = qGetProgram.Creator_ID>
	<cfset FORM.Notes = qGetProgram.Notes />
		
		
	<CFSTOREDPROC PROCEDURE="USP_Copy_Program" datasource="#application.datasource#">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Program_ID_To_Replicate"		VALUE="#Program_ID_To_Replicate#">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR "	DBVARNAME="@New_Contract_Number"			VALUE="">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@IsRevisionOfExistingContract"	VALUE="0">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ISROLLOVER"						VALUE="0">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@ForceFreightOnAutoCopy"			VALUE="0">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@User_Position_ID"				VALUE="0" null="true">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Responsible_User_ID"			VALUE="" null="true">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR"	DBVARNAME="@Current_User_ID"				VALUE="#request.AccessStructure.User_ID#">
		<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Contract_Main_ID"				VARIABLE="Renewed_Program_ID">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_Mass_Copy"					VALUE="0">
		<CFPROCPARAM TYPE="Out"	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Is_Group_Deal"					VARIABLE="Is_Group_Deal">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@From_EZ_Template"				VALUE="0">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@Is_AutoRenew"					VALUE="0">
	</CFSTOREDPROC>
	
	<!--- get the program span --->
	<cfquery name="qGetProgramSpan" datasource="#application.datasource#">
		SELECT	DATEDIFF(d, Contract_Start_Date, Contract_End_Date) + 1 AS Program_Span
		FROM 	Contract_Main
		WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#" />
	</cfquery>
	
	<cfset nProgramSpan = qGetProgramSpan.Program_Span />
	
	<!--- get the item, rate, uom and discount data to add --->
	<cfset useLakebaseForqGetDiscountDataToAdd = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("simplot_items_add")>
<cfif useLakebaseForqGetDiscountDataToAdd>
	<cftry>
		<cfset qGetDiscountDataToAdd = application.oLakebase.toQuery(
			application.oLakebase.selectRows("simplot_items_add", {
				"program_id" = "eq.#programNumberToUseForAdd#",
				"order" = "component_type.asc",
				"select" = "item,uom,unit_of_measure_id,rate,component_type,component_name_id"
			}), "item,uom,unit_of_measure_id,rate,component_type,component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDiscountDataToAdd = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDiscountDataToAdd>
<cfquery name="qGetDiscountDataToAdd" datasource="#application.datasource#">
		SELECT	Item, UOM, Unit_Of_Measure_ID, Rate, Component_Type, Component_Name_ID
		FROM	Simplot_Items_Add 
		WHERE	Program_ID = '#programNumberToUseForAdd#'
		ORDER BY Component_Type
	</cfquery>
</cfif>
	
	<cfloop query="qGetDiscountDataToAdd">
	
		<cfquery name="qGetItemMasterID" datasource="#application.datasource#">
			SELECT	BSA_Foodservice_Items_Master_ID
			FROM	BSA_Foodservice_Items_Master 
			WHERE	Item = '#trim(qGetDiscountDataToAdd.Item)#'
			AND		Deleted = 0
			AND		Active_Code = 'A' 
		</cfquery>
		
		<cfquery name="qAddContractProducts" datasource="#application.datasource#">
		
			SET NOCOUNT ON
			INSERT INTO Contract_Products
				(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID, Product_Group_Level_ID, Pricing_Level_ID, Discounted_Item, Include_In_Margin, Include_In_Volume)
			VALUES
				('#qGetItemMasterID.BSA_Foodservice_Items_Master_ID#', '#Renewed_Program_ID#', '#qGetDiscountDataToAdd.Component_Type#', 9, 1, 1, 1, 1)
								
			SELECT Contract_Products_ID = @@IDENTITY
			SET NOCOUNT OFF
		
		</cfquery>
		
		<!--- if its fixed then add fixed data --->
		<cfif qGetDiscountDataToAdd.Component_Type eq 1>
		
			<cfquery name="qGetProgramFixedCompID" datasource="#application.datasource#">
				SELECT 	DISTINCT Program_Fixed_Component_ID
				FROM 	Program_Fixed_Component
				WHERE 	Program_ID = <cfqueryparam value="#Renewed_Program_ID#" cfsqltype="cf_sql_integer" />
				AND 	Deleted = 0
			</cfquery>
			
			<cfset useLakebaseForqAddFixedProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_price_product_data")>
<cfif useLakebaseForqAddFixedProductData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_fixed_price_product_data", {
			"program_id" = "#renewed_program_id#",
			"contract_products_id" = "#qAddContractProducts.Contract_Products_ID#",
			"fixed_price_value" = "#qGetDiscountDataToAdd.Rate#",
			"unit_of_measure_id" = "#qGetDiscountDataToAdd.Unit_Of_Measure_ID#",
			"program_fixed_component_id" = "#qGetProgramFixedCompID.Program_Fixed_Component_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddFixedProductData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddFixedProductData>
<cfquery name="qAddFixedProductData" datasource="#application.datasource#">
				INSERT INTO Program_Fixed_Price_Product_Data
					(Program_ID, Contract_Products_ID, Fixed_Price_Value, Unit_Of_Measure_ID, Program_Fixed_Component_ID)
				VALUES
					('#renewed_program_id#', '#qAddContractProducts.Contract_Products_ID#', '#qGetDiscountDataToAdd.Rate#', '#qGetDiscountDataToAdd.Unit_Of_Measure_ID#', '#qGetProgramFixedCompID.Program_Fixed_Component_ID#')
			</cfquery>
</cfif>
		
		<!--- if its fixed then add fixed data --->
		<cfelseif qGetDiscountDataToAdd.Component_Type eq 2>	
		
			<cfquery name="qGetProgramThisRebateCompID" datasource="#application.datasource#">
				SELECT	Program_Rebates_Component_ID
				FROM 	Program_Rebates_Component 
				WHERE 	Program_ID = <cfqueryparam value="#Renewed_Program_ID#" cfsqltype="cf_sql_integer" />
				AND		Program_Rebates_Component_Name_ID = '#qGetDiscountDataToAdd.Component_Name_ID#' 
				AND 	Deleted = 0
			</cfquery>
			
			<cfset useLakebaseForqAddRebateProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_product_data")>
<cfif useLakebaseForqAddRebateProductData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_rebates_product_data", {
			"program_id" = "#renewed_program_id#",
			"contract_products_id" = "#qAddContractProducts.Contract_Products_ID#",
			"rebate_value" = "#qGetDiscountDataToAdd.Rate#",
			"unit_of_measure_id" = "#qGetDiscountDataToAdd.Unit_Of_Measure_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqAddRebateProductData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAddRebateProductData>
<cfquery name="qAddRebateProductData" datasource="#application.datasource#">
				INSERT INTO Program_Rebates_Product_Data
					(Program_ID, Contract_Products_ID, Rebate_Value, Unit_Of_Measure_ID)
				VALUES
					('#renewed_program_id#', '#qAddContractProducts.Contract_Products_ID#', '#qGetDiscountDataToAdd.Rate#', '#qGetDiscountDataToAdd.Unit_Of_Measure_ID#')
			</cfquery>
</cfif>
			
			<cfquery name="qAddRebateCompData" datasource="#application.datasource#">
				INSERT INTO	Program_Rebates_Component_Data
					(Program_Rebates_Component_ID, Program_Rebates_Product_Data_ID, Rate, Unit_Of_Measure_Id)
				VALUES
				(
					<cfqueryparam value="#qGetProgramThisRebateCompID.Program_Rebates_Component_ID#" cfsqltype="cf_sql_integer" />, 
					<cfqueryparam value="#qAddRebateProductData.Program_Rebates_Product_Data_ID#" cfsqltype="cf_sql_integer" />, 
					<cfqueryparam value="#qGetDiscountDataToAdd.Rate#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#qGetDiscountDataToAdd.Unit_Of_Measure_ID#" cfsqltype="cf_sql_integer" />
				)
			</cfquery>
			
		</cfif>
		
		<!--- check volume --->
		<cfset useLakebaseForqCheckVolume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_volume")>
<cfif useLakebaseForqCheckVolume>
	<cftry>
		<cfset qCheckVolume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_product_volume", {
				"bsa_foodservice_items_master_id" = "eq.#qGetItemMasterID.BSA_Foodservice_Items_Master_ID#",
				"program_id" = "eq.#renewed_program_id#",
				"deleted" = "eq.0",
				"select" = "program_product_volume_id"
			}), "program_product_volume_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckVolume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckVolume>
<cfquery name="qCheckVolume" datasource="#application.datasource#">
			SELECT	Program_Product_Volume_ID
			FROM	Program_Product_Volume
			WHERE	BSA_Foodservice_Items_Master_ID = '#qGetItemMasterID.BSA_Foodservice_Items_Master_ID#'
			AND		Program_ID = #renewed_program_id#
			AND		Deleted = 0
		</cfquery>
</cfif>
		
		<cfif not qCheckVolume.RecordCount>
		
			<cfset nWeeklyCs = (1 * 7.00) / nProgramSpan />
			<cfset nWeeklyCs = TRIM(nWeeklyCs) />
			<cfif NOT isNumeric(nWeeklyCs)>
				<cfset nWeeklyCs = 1 />
			</cfif>
		
			<cfset useLakebaseForqInsertVol = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_volume")>
<cfif useLakebaseForqInsertVol>
	<cftry>
		<cfset application.oLakebase.insertRow("program_product_volume", {
			"bsa_foodservice_items_master_id" = "#qGetItemMasterID.BSA_Foodservice_Items_Master_ID#",
			"program_id" = "#renewed_program_id#",
			"volume_cs" = "#nWeeklyCs#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertVol = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertVol>
<cfquery name="qInsertVol" datasource="#application.datasource#">
				INSERT INTO	Program_Product_Volume
					(BSA_Foodservice_Items_Master_ID, Program_ID, Volume_CS)
				VALUES
					('#qGetItemMasterID.BSA_Foodservice_Items_Master_ID#', #renewed_program_id#,  '#nWeeklyCs#' )
			</cfquery>
</cfif>
			
			<cfquery name="qUpdateVolumeLB" datasource="#application.datasource#">
				UPDATE	Program_Product_Volume
				SET		Volume_LB = Program_Product_Volume.Volume_CS * BSA_Foodservice_Items_Master.Net_Weight
				FROM	Program_Product_Volume
						INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID AND
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#qGetItemMasterID.BSA_Foodservice_Items_Master_ID#'
				WHERE	Program_Product_Volume.Program_ID = #renewed_program_id#
				AND		Program_Product_Volume.Deleted = 0
				AND		Program_Product_Volume.Is_Group = 0
			</cfquery>
		</cfif>
					
	</cfloop>
	
	<!---Adjust for multiple components if there is more than one rebate component--->
	<cfquery name="qCheckForMultipleRebateComps" datasource="#application.datasource#">
		SELECT	Program_Rebates_Component_ID
		FROM 	Program_Rebates_Component 
		WHERE 	Program_ID = <cfqueryparam value="#Renewed_Program_ID#" cfsqltype="cf_sql_integer" />
		AND 	Deleted = 0
	</cfquery>
	
	<cfif qCheckForMultipleRebateComps.RecordCount gt 1>
		<!--- adjust Program_Rebates_Component_Data table for any missed component/product combinations --->
		<cfquery name="qAdjustCompProd" datasource="#application.datasource#">
			INSERT INTO Program_Rebates_Component_Data 
				(Program_Rebates_Component_ID, Program_Rebates_Product_Data_ID, Rate, Unit_Of_Measure_ID, Is_Group)
			SELECT	Program_Rebates_Component.Program_Rebates_Component_ID, Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID, 0 as Rate, 1 as Unit_Of_Measure_ID, Program_Rebates_Product_Data.Is_Group
			FROM	Program_Rebates_Product_Data
					INNER JOIN Program_Rebates_Component ON
					Program_Rebates_Product_Data.Program_ID = Program_Rebates_Component.Program_ID
					LEFT JOIN Program_Rebates_Component_Data  ON
					Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID AND
					Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
			WHERE 	Program_Rebates_Component.Program_ID = <cfqueryparam value="#Renewed_Program_ID#" cfsqltype="cf_sql_integer" />
			AND		Program_Rebates_Component_Data.Program_Rebates_Component_ID IS NULL
			AND		Program_Rebates_Product_Data.Deleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
			AND		Program_Rebates_Component.Deleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
		</cfquery>
	</cfif>
	
	<!--- Dev Note: KAL; Setting the values for the intermediate revision version here --->
	<CFSET FORM.start_date				= New_Pgm_Start_Date>
	<CFSET FORM.end_date				= New_Pgm_End_Date>

	<!--- Dev Note: KAL; D15524: Prorate the volume for the remainder of the program span --->
	<CFSET variables.previous_start_date	= qGetProgram.Contract_Start_Date>
	<CFSET variables.previous_end_date		= qGetProgram.Contract_End_Date>	
	<CFSET variables.previous_span			= DateDiff("d", variables.previous_start_date, variables.previous_end_date) + 1>
	<CFSET variables.new_span				= DateDiff("d", New_Pgm_Start_Date, New_Pgm_End_Date) + 1>
	<CFSET variables.new_pgm_quantity		= Round((variables.new_span/variables.previous_span) * qGetProgram.Contract_Quantity) />
	<CFSET FORM.Quantity					= variables.new_pgm_quantity>	 
	

	<CFSET FORM.Approved_By_User_ID 		=  "00000000-0000-0000-0000000000000001"> <!--- Dev Note: KAL; D14181: Change the Approver to the Auto Price Change --->		

	<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
	<cfset FORM.Notes = FORM.Notes & " - (Price Change Applied - " & DateFormat(Programs_Custom_Revision.New_Start_Date, "mm/dd/yyyy") &")" />

	<cfquery name="qUpdateDatesAndVolume" datasource="#application.datasource#">
		UPDATE	Contract_Main
		SET		Contract_Quantity = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Quantity#">,
				Contract_Start_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.Start_Date#">,
				Contract_End_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.End_Date#">,
				Notes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Form.Notes#">
		WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
	</cfquery>
	
	<cfquery name="qGetNewProgram" datasource="#application.datasource#">
		SELECT 	Contract_Number, ProgramType_ID
		FROM 	Contract_Main 
		WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
	</cfquery>
	
	<cfset form.Contract_Number = qGetNewProgram.Contract_Number />
	
	<CFOUTPUT>
		<cfset form.Scheduled 					= 1>
		<cfset NumberUpdated = NumberUpdated + 1>
		#NumberUpdated# - #FORM.Contract_Number# - #Renewed_Program_ID#<hr>
	</CFOUTPUT>
							
	
	<!--- Make RFA --->
	<cfset programObj = CreateObject("component", "components.programs.program") />
	<cfset programObj.makeRFA(renewed_program_id, qGetProgram.Responsible_User_ID) />	
	<cfset Contract_Main_ID = renewed_program_id>

	<!--- For Simplot/5.0 Only: Call the freight populate routine --->
	<cfstoredproc datasource="#application.datasource#" procedure="Populate_Program_Distributor_Freight_Mass_Price_Process" >
		<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#RENEWED_PROGRAM_ID#" />
	</cfstoredproc>	
	 	
	<!--- Auto Approve the program --->
	<cfset program_id = Renewed_Program_ID>
	<CFINCLUDE TEMPLATE = "/Common_Files/Contracts/Contract_layered_approve_action_Auto.cfm">

	<!--- Dev Note: KAL; D16959: JRS - Margin page previous version summary displaying zero's --->
	<cfstoredproc datasource="#application.datasource#" procedure="GET_PROFIT_MARGIN_LAYERED" >
		<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#RENEWED_PROGRAM_ID#" />
	</cfstoredproc>

	<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
	<CFQUERY NAME="InsertBizCon" DATASOURCE="#Application.Datasource#">
		INSERT INTO Contract_Evaluation_Notes (Contract_Number, Entered_By, Eval_Action, Notes, Created_Date, Contract_Notes_Type)
		VALUES	(	<cfqueryparam value="#FORM.CONTRACT_NUMBER#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="System" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="Pricing Update" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#variables.BizCon#" cfsqltype="cf_sql_varchar">,
					GETDATE(),
					<cfqueryparam value="2" cfsqltype="cf_sql_integer">
				)				
	</CFQUERY>
	 
	<!--- Dev Note: Kal;  Update the temp table and set 1 if revision created succesfully --->
	<CFQUERY NAME="SetProcessed" DATASOURCE="#Application.Datasource#">
		UPDATE 	PriceChangeProgramList
		SET 	COPIED = 1, COMPLETED = 1,
				Copied_Program_ID = <cfqueryparam value="#RENEWED_PROGRAM_ID#" cfsqltype="cf_sql_integer">,
				Copied_Program_Number = <cfqueryparam value="#FORM.CONTRACT_NUMBER#" cfsqltype="cf_sql_varchar">,
				New_Start_Date = <cfqueryparam value="#New_Pgm_Start_Date#" cfsqltype="cf_sql_date">,
				New_End_Date =  <cfqueryparam value="#New_Pgm_End_Date#" cfsqltype="cf_sql_date">
		WHERE 	CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
	</CFQUERY>
	
	<!--- Dev Note: KAL; D16694: JRS - Changes to Price Increase : This below update is no longer needed. 
	<!--- Dev Note: Kal;  Update the end date on the previous program so it expires before the new programs starts --->
	<CFQUERY NAME="UpdatePreviousProgramEndDate" DATASOURCE="#Application.Datasource#">
		Update	Contract_Main
		Set		Contract_Main.Contract_End_Date = Mod_End_Date
		From	Contract_Main
		INNER JOIN PriceChangeProgramList On Contract_Main.Contract_Main_ID = PriceChangeProgramList.Contract_Main_ID 
		and		(DateDiff(d, Contract_Main.Contract_Start_Date, New_Pgm_Start_Date) > 0)
		and		Contract_Main.Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
	</CFQUERY>
	--->
</cfloop>

<!--- Dev Note: Kal;  Update the temp table with the new program's status and version --->
<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
	UPDATE 	PriceChangeProgramList
	SET		Copied_Contract_Status_ID = Contract_Status_Type_IDX,
			Copied_Contract_Status = Contract_Status_Type_Desc
	FROM	PriceChangeProgramList, Contract_Main, Contract_Status_Types  
	WHERE	PriceChangeProgramList.Copied_Program_ID = Contract_Main.Contract_Main_ID
	AND		Contract_Status_Types.Contract_Status_Type_ID = Contract_Status_Type_IDX
</CFQUERY>

<!---
<!--- Dev Note: KAL; D15633 Auto Generate Letters on Completion of Revision --->
<!--- Dev Note: KAL; D15780: Letters page displays operator and distributor sections overlapped --->
<cfquery name="qRevisions_Letters" datasource="#application.datasource#">
	Select	Top 25 CM.Contract_Main_ID, CM.Contract_Start_Date, PCPO.Operator_Letters_Required, PCPO.Distributor_Letters_Required
	From  PriceChangeProgramList
	Inner Join Contract_Main CM On CM.Contract_Main_ID = Copied_Program_ID
	Inner Join Program_Control_Panel_Options PCPO On PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
	Where Killed = 0 and Skip = 0 and Completed = 1 and Copied = 1 and CM.Deleted = 0 
		  and (PCPO.Operator_Letters_Required = 1 or PCPO.Distributor_Letters_Required = 1)
	Order By New_Contract_Main_ID
</cfquery>

<cfloop query="qRevisions_Letters">
	
	<!--- Dev Note: KAL; D15780: Letters page displays operator and distributor sections overlapped --->
	<cfset variables.templateLetterType = 0 />
	
	<cfif Operator_Letters_Required eq 1 and Distributor_Letters_Required eq 0>
		<cfset variables.templateLetterType = 1 />			
	<cfelseif Operator_Letters_Required eq 0 and Distributor_Letters_Required eq 1>
		<cfset variables.templateLetterType = 2 />
	<cfelseif Operator_Letters_Required eq 1 and Distributor_Letters_Required eq 1>
		<cfset variables.templateLetterType = 3 />
	</cfif>
	
	<cfmodule
          template="/common_files/contracts/letters/auto_generate_gateway.cfm"
          bAddCustomerProductNumbers="0"
          bAuto="1"
          bFormSubmitted="0"
          bLetterDisplayFreight="1"
          claimRateDate = "#DateFormat(Contract_Start_Date, 'mm/dd/yyyy')#"
          bIncludeVolumePage="0"
          bInsertWatermark="0"
          bListLast="0"
          contract_main_id="#trim(qRevisions_Letters.Contract_Main_ID)#"
          customerFreightUom="CS"
          distributor_letter_type="1"
          dis_letter_settings="2"
          letter_type="#variables.templateLetterType#"
          notification_type="2"
          operator_letter_type="1"
          opr_letter_settings="2"
          user_id = "00000000-0000-0000-0000000000000001"
          timeout_seconds="3600" /> <!--- averages 2 min per letter without the freight page... 1000 ltrs could be 33 hrs --->

	<!--- Dev Note: Kal;  Update the temp table and set Completed = 2 if letters were created --->
	<cfquery name="qSetLettersProcessed" datasource="#Application.Datasource#">
		UPDATE 	PriceChangeProgramList 
		SET 	COMPLETED = 2
		WHERE 	COMPLETED = 1
		AND 	Copied_Program_ID = <cfqueryparam value="#qRevisions_Letters.Contract_Main_ID#" cfsqltype="cf_sql_integer">
	</cfquery>

</cfloop>
--->