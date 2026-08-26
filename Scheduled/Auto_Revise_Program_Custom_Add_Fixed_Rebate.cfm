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
	SELECT TOP 25 CONTRACT_MAIN_ID, CONTRACT_NUMBER, New_Start_Date, New_End_Date 
	FROM  PriceChangeProgramList_Add_Fixed_Rebate
	WHERE Killed = 0 AND Skip = 0 AND Completed = 0
	ORDER BY  CONTRACT_NUMBER, CONTRACT_MAIN_ID
</cfquery>

<!--- Setting Variables --->
<cfset Scheduled = 1>
<cfset NumberUpdated = 0> <!--- Just an indicator of number of programs renewed --->
<cfset form.IsAutoRevision = 1 />
<cfset programObj = CreateObject("component", "components.programs.program") />
<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
<cfset variables.BizCon = "Mass update to include new items - systematically adding to programs" />
<!--- /////////////////////////////////////////////////////////////////////////////////////////////////// --->

<cfloop query="Programs_Custom_Revision">	
	 
	 <!---sets all the stuff that contract revision needs--->
	<cfset Program_ID_To_Replicate = trim(Programs_Custom_Revision.CONTRACT_MAIN_ID) />
	
	<cfset New_Pgm_Start_Date 	= Programs_Custom_Revision.New_Start_Date	/>	
	<cfset New_Pgm_End_Date 	= Programs_Custom_Revision.New_End_Date	/>

	<cfquery name="Getcompany" datasource="#application.datasource#">
		SELECT Top 1 Company_Main_ID
		FROM 	Company_Main
		WHERE	Deleted = 0
	</cfquery>

	<cfset request.AccessStructure.Company_Main_ID = GetCompany.Company_Main_ID>
		
		<cfquery name="qGetProgram" datasource="#application.datasource#">
			SELECT 	Original_Creating_User_Position_ID, 
					Creating_User_Position_ID, 
					Creator_ID,
					Responsible_User_ID,
					Contract_Start_Date, Contract_End_Date,
					Contract_Quantity,
					Contract_Number,
					Notes,
					Approved_By_User_ID
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfquery name="qGetProfileId" datasource="#application.datasource#">
			SELECT Profiles_ID from _Users where USER_ID = '#qGetProgram.Approved_By_User_ID#'
		</cfquery>
		<cfset Original_Creating_User_Position_ID = qGetProgram.Original_Creating_User_Position_ID>
		<cfset User_Position_ID = qGetProgram.Creating_User_Position_ID>
		<cfset request.AccessStructure.Creating_User_Position_ID = qGetProgram.Creating_User_Position_ID>
		<cfset request.AccessStructure.User_ID = qGetProgram.Creator_ID>
		<cfset request.AccessStructure.Profiles_ID = qGetProfileId.Profiles_ID>
		
		<CFSET FORM.Contract_Number 		= qGetProgram.Contract_Number>
		<!--- Dev Note: KAL; Setting the values for the intermediate revision version here --->
		<CFSET FORM.start_date				= New_Pgm_Start_Date>
		<CFSET FORM.end_date				= New_Pgm_End_Date>

		<!--- Dev Note: KAL; D15524: Prorate the volume for the remainder of the program span --->
		<CFSET variables.previous_start_date	= qGetProgram.Contract_Start_Date>
		<CFSET variables.previous_end_date		= qGetProgram.Contract_End_Date>	
		<CFSET variables.previous_span			= DateDiff("d", variables.previous_start_date, variables.previous_end_date) + 1>
		<CFSET variables.new_span				= DateDiff("d", New_Pgm_Start_Date, New_Pgm_End_Date) + 1>
		<CFSET variables.new_pgm_quantity		= int((variables.new_span/variables.previous_span) * qGetProgram.Contract_Quantity) />
		<CFSET FORM.Quantity					= variables.new_pgm_quantity>	 
		
		<CFSET FORM.Approved_By_User_ID 		=  "00000000-0000-0000-0000000000000001"> <!--- Dev Note: KAL; D14181: Change the Approver to the Auto Price Change --->		
		
		<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
		<cfset FORM.Notes = "Mass update to include new items - systematically adding to programs" />
		
		<CFSTOREDPROC PROCEDURE="USP_Copy_Program" datasource="#application.datasource#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Program_ID_To_Replicate"		VALUE="#Program_ID_To_Replicate#">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_VARCHAR "	DBVARNAME="@New_Contract_Number"			VALUE="">
			<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_BIT"		DBVARNAME="@IsRevisionOfExistingContract"	VALUE="1">
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
		
		<cfquery name="qUpdateDatesAndVolume" datasource="#application.datasource#">
			UPDATE	Contract_Main
			SET		Contract_Quantity = <cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Quantity#">,
					Contract_Start_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.Start_Date#">,
					Contract_End_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.End_Date#">,
					Notes = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.Notes#">
			WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
		</cfquery>
		
		<cfquery name="qGetNewProgram" datasource="#application.datasource#">
			SELECT 	Contract_Number, ProgramType_ID
			FROM 	Contract_Main 
			WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
		</cfquery>
		
		<CFOUTPUT>
			<cfset form.Scheduled 					= 1>

			<cfset NumberUpdated = NumberUpdated + 1>
				#NumberUpdated# - #FORM.Contract_Number# - #Renewed_Program_ID#<hr>
		</CFOUTPUT>
					
		<!--- get discount data to be added --->
		<cfquery name="qGetDiscountDataToAdd" datasource="#application.datasource#">
			SELECT 	Item, BSA_Foodservice_Items_Master_ID, Item_Add, BSA_Foodservice_Items_Master_ID_Add, Product_Type_ID, Added_Item_Exists, Rate, UOM, Component_ID
			FROM 	Program_Product_Price_Changed_Add_Fixed_Rebate_Data
			WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
			AND		Change_Completed = 0
		</cfquery>
		
		<!--- loop over the discount data to add --->
		<cfloop query="qGetDiscountDataToAdd">

			
			<!--- if the product already exists then we have to update the rate for the given discount type id --->
			<cfif qGetDiscountDataToAdd.Added_Item_Exists neq 1>
			
				<cfquery name="qAddContractProducts" datasource="#application.datasource#">
				
					SET NOCOUNT ON
					INSERT INTO Contract_Products
						(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID, Product_Group_Level_ID, Pricing_Level_ID, Discounted_Item, Include_In_Margin, Product_Group_ID,Captured_From_Group,Exclude_From_Margin,Copied_From_Contract_Product_ID,Group_Contract_Product_ID)
					SELECT DISTINCT
							'#qGetDiscountDataToAdd.BSA_Foodservice_Items_Master_ID_Add#',
							Contract_Main_ID,
							Product_Type_ID,
							Product_Group_Level_ID,
							Pricing_Level_ID,
							Discounted_Item,
							Include_In_Margin,
							Product_Group_ID,
							Captured_From_Group,
							Exclude_From_Margin,
							Copied_From_Contract_Product_ID,
							Group_Contract_Product_ID
					FROM	Contract_Products
					WHERE	Contract_Main_ID = <cfqueryparam value="#renewed_program_id#" cfsqltype="cf_sql_integer" />
					AND		BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#qGetDiscountDataToAdd.BSA_Foodservice_Items_Master_ID#" cfsqltype="cf_sql_varchar" />
					AND		Product_Type_ID = <cfqueryparam value="#qGetDiscountDataToAdd.Product_Type_ID#" cfsqltype="cf_sql_integer" />
					AND		Deleted = 0
										
					SELECT Contract_Products_ID = @@IDENTITY
					SET NOCOUNT OFF
				
				</cfquery>
				
				<!--- if its fixed then add fixed data --->
				<cfif qGetDiscountDataToAdd.Product_Type_ID eq 1>
				
					<cfquery name="qGetProgramFixedCompID" datasource="#application.datasource#">
						SELECT 	DISTINCT Program_Fixed_Component_ID
						FROM 	Program_Fixed_Component
						WHERE 	Program_ID = <cfqueryparam value="#renewed_program_id#" cfsqltype="cf_sql_integer" />
						AND 	Deleted = 0
					</cfquery>
					
					<cfset useLakebaseForqAddFixedProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_price_product_data")>
<cfif useLakebaseForqAddFixedProductData>
	<cftry>
		<cfset application.oLakebase.insertRow("program_fixed_price_product_data", {
			"program_id" = "#renewed_program_id#",
			"contract_products_id" = "#qAddContractProducts.Contract_Products_ID#",
			"fixed_price_value" = "#qGetDiscountDataToAdd.Rate#",
			"unit_of_measure_id" = "#qGetDiscountDataToAdd.UOM#",
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
							('#renewed_program_id#', '#qAddContractProducts.Contract_Products_ID#', '#qGetDiscountDataToAdd.Rate#', '#qGetDiscountDataToAdd.UOM#', '#qGetProgramFixedCompID.Program_Fixed_Component_ID#')
					</cfquery>
</cfif>
				
				<!--- if its fixed then add fixed data --->
				<cfelseif qGetDiscountDataToAdd.Product_Type_ID eq 2>	
				
					<cfquery name="qGetProgramRebateCompID" datasource="#application.datasource#">
						SELECT 	DISTINCT Program_Rebates_Component_ID
						FROM 	Program_Rebates_Component
						WHERE 	Program_ID = <cfqueryparam value="#renewed_program_id#" cfsqltype="cf_sql_integer" />
						AND 	Deleted = 0
					</cfquery>
					
					<cfquery name="qAddRebateProductData" datasource="#application.datasource#">
						INSERT INTO Program_Rebates_Product_Data
							(Program_ID, Contract_Products_ID)
						VALUES
							('#renewed_program_id#', '#qAddContractProducts.Contract_Products_ID#')
					</cfquery>
					
					<cfquery name="qAddRebateCompData" datasource="#application.datasource#">
						INSERT INTO	Program_Rebates_Component_Data
							(Program_Rebates_Component_ID, Program_Rebates_Product_Data_ID, Rate, Unit_Of_Measure_Id)
						VALUES
						(
							<cfqueryparam value="#qGetProgramRebateCompID.Program_Rebates_Component_ID#" cfsqltype="cf_sql_integer" />, 
							<cfqueryparam value="#qAddRebateProductData.Program_Rebates_Product_Data_ID#" cfsqltype="cf_sql_integer" />, 
							<cfqueryparam value="#qGetDiscountDataToAdd.Rate#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#qGetDiscountDataToAdd.UOM#" cfsqltype="cf_sql_integer" />
						)
					</cfquery>
					
				</cfif>
				
			</cfif>
		
			<!---  Mark the Program as Completed when the price is updated. --->
			<CFQUERY name="Update_Changed_Flag" datasource="#application.datasource#">
				UPDATE	Program_Product_Price_Changed_Add_Fixed_Rebate_Data 
				SET		Change_Completed = 1
				WHERE 	CONTRACT_MAIN_ID	= 	<cfqueryparam value="#trim(Program_ID_To_Replicate)#" cfsqltype="cf_sql_integer">	
				AND		Product_Type_ID		= 	<cfqueryparam value="#trim(qGetDiscountDataToAdd.Product_Type_ID)#" cfsqltype="cf_sql_integer">
				AND		Item				=	<cfqueryparam value="#trim(qGetDiscountDataToAdd.Item)#" cfsqltype="cf_sql_varchar">
			</CFQUERY>	
			
		</cfloop>

	
	<cfset programObj = CreateObject("component", "components.programs.program") />
	<cfset programObj.makeRFA(renewed_program_id, qGetProgram.Responsible_User_ID) />	
	<cfset Contract_Main_ID = renewed_program_id>
	<!---
	<!--- For Simplot/5.0 Only: Call the freight populate routine --->
	<cfstoredproc datasource="#application.datasource#" procedure="Populate_Program_Distributor_Freight" >
		<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#RENEWED_PROGRAM_ID#" variable="@Program_ID" />
		<cfprocparam type="in" cfsqltype="cf_sql_bit" value="1" variable="@Recalc_All" />
	</cfstoredproc>
	--->
	<!---
	<!--- For Simplot/5.0 Only: Call the freight populate routine --->
	<!--- Update the Freight for the programs. --->
	<CFQUERY name="Update_Freight_Change" datasource="#application.datasource#">
		Update	Program_Distributor_Freight 
		SET		IBF_Rate = New_IBF_Rate,
    			OBF_Rate = New_OBF_Rate
		FROM 	Contract_Main CM
		INNER JOIN Program_Distributor_Price_Changed PDPC ON PDPC.CONTRACT_MAIN_ID = CM.Revision_Of_Contract_Main_ID AND PDPC.Change_Completed = 0
		INNER JOIN Program_Distributor_Freight DF ON DF.PROGRAM_ID = CM.CONTRACT_MAIN_ID AND PDPC.BSA_Foodservice_Customers_ID = DF.Distributor_ID
			AND DF.DELETED = 0
		WHERE 	CM.DELETED = 0 
		AND	CM.CONTRACT_MAIN_ID = <cfqueryparam value="#RENEWED_PROGRAM_ID#" cfsqltype="cf_sql_integer">
		AND	PDPC.CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">		
	</CFQUERY>	
	
	<!--- For Simplot/5.0 Only: Call the freight populate routine --->
	<!---  Mark the Program as Completed when the Freight is updated. --->
	<CFQUERY name="Update_Changed_Flag" datasource="#application.datasource#">
		Update	Program_Distributor_Price_Changed
		SET		Change_Completed = 1
		WHERE 	CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">		
	</CFQUERY>
	--->
		
	<!--- Auto Approve the program --->
	<cfset program_id = Renewed_Program_ID>
	<CFINCLUDE TEMPLATE = "/Common_Files/Contracts/Contract_layered_approve_action_Auto.cfm">

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
		UPDATE 	PriceChangeProgramList_Add_Fixed_Rebate
		SET 	COMPLETED = 1,
				NEW_CONTRACT_MAIN_ID = <cfqueryparam value="#RENEWED_PROGRAM_ID#" cfsqltype="cf_sql_integer">,
				New_Start_Date = <cfqueryparam value="#New_Pgm_Start_Date#" cfsqltype="cf_sql_date">,
				New_End_Date =  <cfqueryparam value="#New_Pgm_End_Date#" cfsqltype="cf_sql_date">
		WHERE 	CONTRACT_NUMBER = <cfqueryparam value="#trim(Programs_Custom_Revision.CONTRACT_NUMBER)#" cfsqltype="cf_sql_varchar">
		AND 	CONTRACT_MAIN_ID = <cfqueryparam value="#trim(Programs_Custom_Revision.CONTRACT_MAIN_ID)#" cfsqltype="cf_sql_integer">
	</CFQUERY>

	<!---
	<!--- Dev Note: Kal;  Update the end date on the previous program so it expires before the new programs starts --->
	<CFQUERY NAME="UpdatePreviousProgramEndDate" DATASOURCE="#Application.Datasource#">
		Update	Contract_Main
		Set		Contract_Main.Contract_End_Date = Mod_End_Date
		From	Contract_Main
		INNER JOIN PriceChangeProgramList On Contract_Main.Contract_Main_ID = PriceChangeProgramList.Contract_Main_ID 
		and		(DateDiff(d, Contract_Main.Contract_Start_Date, <cfqueryparam value="#New_Pgm_Start_Date#" cfsqltype="cf_sql_date">) > 0)
		and		Contract_Main.Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
	</CFQUERY>
	--->
	

</cfloop>

<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
		UPDATE 	PriceChangeProgramList_Add_Fixed_Rebate
		SET		New_Version = Revision_Version, 
				New_Contract_Status_ID = Contract_Status_Type_IDX,
				New_Contract_Status = Contract_Status_Types.Contract_Status_Type_Desc
		FROM	PriceChangeProgramList_Add_Fixed_Rebate, Contract_Main, Contract_Status_Types  
		WHERE	PriceChangeProgramList_Add_Fixed_Rebate.New_Contract_Main_ID = Contract_Main.Contract_Main_ID
		AND		PriceChangeProgramList_Add_Fixed_Rebate.Contract_Main_ID = Contract_Main.Revision_of_Contract_Main_ID
		AND		Contract_Status_Types.Contract_Status_Type_ID = Contract_Status_Type_IDX
</CFQUERY>

