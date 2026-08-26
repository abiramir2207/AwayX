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
	SELECT distinct Top 25 CONTRACT_MAIN_ID, CONTRACT_NUMBER, New_Start_Date, New_End_Date, Responsible_User_ID 
	FROM  PriceChangeProgramList
	WHERE Killed = 0 AND Skip = 0 AND Completed = 0
	ORDER BY  CONTRACT_NUMBER, CONTRACT_MAIN_ID
</cfquery>

<!--- Setting Variables --->
<cfset Scheduled = 1>
<cfset NumberUpdated = 0> <!--- Just an indicator of number of programs renewed --->
<cfset form.IsAutoRevision = 1 />
<cfset programObj = CreateObject("component", "components.programs.program") />
<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
<cfset variables.BizCon = "This program has been systematically updated" />
<!--- /////////////////////////////////////////////////////////////////////////////////////////////////// --->

<cfloop query="Programs_Custom_Revision">
	<!---sets all the stuff that contract revision needs--->
	<cfset Program_ID_To_Replicate = Programs_Custom_Revision.CONTRACT_MAIN_ID />
	
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
		
		<cfset Original_Creating_User_Position_ID = qGetProgram.Original_Creating_User_Position_ID>
		<cfset User_Position_ID = qGetProgram.Creating_User_Position_ID>
		<cfset request.AccessStructure.Creating_User_Position_ID = qGetProgram.Creating_User_Position_ID>
		<cfset request.AccessStructure.User_ID = qGetProgram.Creator_ID>
		<cfset FORM.Notes = qGetProgram.Notes />
		
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
		
		<cfset volumeCS = (1 * 7.00) / variables.new_span />
		<cfset volumeLB = (1 * 7.00) / variables.new_span />
		
		<CFSET FORM.Approved_By_User_ID 		=  qGetProgram.Approved_By_User_ID /> <!--- Dev Note: KAL; D14181: Change the Approver to the Auto Price Change --->		
		
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
			<cfset form.Scheduled	= 1>
			<cfset NumberUpdated 	= NumberUpdated + 1>
			#NumberUpdated# - #FORM.Contract_Number# - #Renewed_Program_ID#<hr>
		</CFOUTPUT>
	
	<!--- Update the price for the products. --->
	<CFQUERY name="Update_Price_Change" datasource="#application.datasource#">
		Update	PROGRAM_FIXED_PRICE_PRODUCT_DATA 
		SET		Fixed_Price_Value = PPPC.New_Price
		FROM 	Contract_Main CM
				INNER JOIN CONTRACT_PRODUCTS CP ON CM.CONTRACT_MAIN_ID = CP.CONTRACT_MAIN_ID AND CP.DELETED = 0 and CP.Product_Type_ID = 1
				INNER JOIN PROGRAM_FIXED_PRICE_PRODUCT_DATA FX ON FX.PROGRAM_ID = CP.CONTRACT_MAIN_ID AND CP.CONTRACT_PRODUCTS_ID = FX.CONTRACT_PRODUCTS_ID  AND FX.DELETED = 0
				INNER JOIN Program_Product_Price_Changed PPPC ON PPPC.CONTRACT_MAIN_ID = CM.Revision_Of_Contract_Main_ID AND 
				PPPC.CONTRACT_NUMBER = CM.CONTRACT_NUMBER AND 
				PPPC.BSA_FOODSERVICE_ITEMS_MASTER_ID = CP.BSA_FOODSERVICE_ITEMS_MASTER_ID AND 
				PPPC.Change_Completed = 0 AND PPPC.PRODUCT_STATUS = 'U'
		WHERE 	CM.DELETED = 0 
		AND		CM.CONTRACT_MAIN_ID = <cfqueryparam value="#RENEWED_PROGRAM_ID#" cfsqltype="cf_sql_integer">
		AND		PPPC.CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">		
	</CFQUERY>

	<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
	<!--- ///////////////////////////////////////////////////////////////// ADD PRODUCTS ////////////////////////////////////////////////////////////////////////// --->
	<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
	<cfquery name="qGetDiscountDataToAdd" datasource="#application.datasource#">
		SELECT 	BSA_Foodservice_Items_Master_ID, New_Price, ISNULL(Rate_UOM, 'CS') AS Rate_UOM, Net_Weight
		FROM 	Program_Product_Price_Changed
		WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
		AND		Change_Completed = 0
		AND		PRODUCT_STATUS	= 'A'
	</cfquery>
	
	<!--- loop over the discount data to add --->
	<cfloop query="qGetDiscountDataToAdd">

		<cfif trim(qGetDiscountDataToAdd.Rate_UOM) eq "LB">
			<cfset tmpRateUOM = 2 />
		<cfelse>
			<cfset tmpRateUOM = 1 />
		</cfif>
		<cfquery name="qAddContractProducts" datasource="#application.datasource#">
		
			SET NOCOUNT ON
			INSERT INTO Contract_Products
				(BSA_Foodservice_Items_Master_ID, Contract_Main_ID, Product_Type_ID, Product_Group_Level_ID, Pricing_Level_ID, Discounted_Item, Include_In_Margin)
			VALUES
				('#qGetDiscountDataToAdd.BSA_Foodservice_Items_Master_ID#', #RENEWED_PROGRAM_ID#, 1, 0, 1, 1, 1)		
			SELECT Contract_Products_ID = @@IDENTITY
			SET NOCOUNT OFF
		
		</cfquery>
		
		<cfquery name="qGetProgramFixedCompID" datasource="#application.datasource#">
			SELECT 	DISTINCT Program_Fixed_Component_ID
			FROM 	Program_Fixed_Component
			WHERE 	Program_ID = <cfqueryparam value="#renewed_program_id#" cfsqltype="cf_sql_integer" />
			AND 	Deleted = 0
		</cfquery>
		
		<cfquery name="qAddFixedProductData" datasource="#application.datasource#">
			INSERT INTO Program_Fixed_Price_Product_Data
				(Program_ID, Contract_Products_ID, Fixed_Price_Value, Unit_Of_Measure_ID, Program_Fixed_Component_ID)
			VALUES
				('#renewed_program_id#', '#qAddContractProducts.Contract_Products_ID#', '#qGetDiscountDataToAdd.New_Price#', '#tmpRateUOM#', '#qGetProgramFixedCompID.Program_Fixed_Component_ID#')
		</cfquery>	

		<cfif qGetDiscountDataToAdd.Rate_UOM eq "CS">
			<cfset volumeLB = volumeCS * qGetDiscountDataToAdd.Net_Weight />
		<cfelse>
			<cfset volumeCS = volumeLB / qGetDiscountDataToAdd.Net_Weight />
		</cfif>
		<cfquery name="qInsertVol" datasource="#application.datasource#">
			INSERT INTO	Program_Product_Volume
				(BSA_Foodservice_Items_Master_ID, Program_ID, Volume_CS, Volume_LB)
			VALUES
				('#qGetDiscountDataToAdd.BSA_Foodservice_Items_Master_ID#', #RENEWED_PROGRAM_ID#,  <cfqueryparam value="#volumeCS#" cfsqltype="CF_SQL_FLOAT" />,  <cfqueryparam value="#volumeLB#" cfsqltype="CF_SQL_FLOAT" />)
		</cfquery>
			
	</cfloop>
	<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
	<!--- ///////////////////////////////////////////////////////////////// ADD PRODUCTS END/////////////////////////////////////////////////////////////////////// --->
	<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
	
	<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
	<!--- ///////////////////////////////////////////////////////////////// REMOVE PRODUCTS /////////////////////////////////////////////////////////////////////// --->
	<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
	<!--- get discount data to be removed --->
	<cfquery name="qGetDiscountDataToRemove" datasource="#application.datasource#">
		SELECT 	BSA_Foodservice_Items_Master_ID
		FROM 	Program_Product_Price_Changed
		WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
		AND		Change_Completed = 0
		AND		PRODUCT_STATUS	= 'D'
	</cfquery>
	
	<!--- loop over the discount data to add --->
	<cfloop query="qGetDiscountDataToRemove">

		<cfquery name="qRemoveContractProducts" datasource="#application.datasource#">
			UPDATE	Contract_Products
			SET		Deleted = 1
			WHERE	Contract_Main_ID = #RENEWED_PROGRAM_ID#
			AND		BSA_Foodservice_Items_Master_ID = '#qGetDiscountDataToRemove.BSA_Foodservice_Items_Master_ID#'
		</cfquery>
			
		<cfquery name="qGetProgramFixedCompIDRemove" datasource="#application.datasource#">
			SELECT 	DISTINCT Program_Fixed_Component_ID
			FROM 	Program_Fixed_Component
			WHERE 	Program_ID = <cfqueryparam value="#renewed_program_id#" cfsqltype="cf_sql_integer" />
			AND 	Deleted = 0
		</cfquery>
		
		<cfquery name="qRemoveFixedProductData" datasource="#application.datasource#">
			UPDATE 	Program_Fixed_Price_Product_Data
			SET		Program_Fixed_Price_Product_Data.Deleted = 1
			FROM	Program_Fixed_Price_Product_Data
					INNER JOIN Contract_Products ON
					Contract_Products.Contract_Main_ID = Program_Fixed_Price_Product_Data.Program_ID AND
					Contract_Products.Contract_Products_ID = Program_Fixed_Price_Product_Data.Contract_Products_ID AND 
					Contract_Products.BSA_Foodservice_Items_Master_ID = '#qGetDiscountDataToRemove.BSA_Foodservice_Items_Master_ID#' AND
					Contract_Products.Contract_Main_ID = '#RENEWED_PROGRAM_ID#' AND
					Contract_Products.Deleted = 1
			WHERE	Program_Fixed_Price_Product_Data.Program_ID = '#RENEWED_PROGRAM_ID#'
			AND		Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID = '#qGetProgramFixedCompIDRemove.Program_Fixed_Component_ID#'			
		</cfquery>	
	
		<cfquery name="qRemoveVol" datasource="#application.datasource#">
			DELETE FROM	Program_Product_Volume
			WHERE	Program_ID = '#RENEWED_PROGRAM_ID#'
			AND		BSA_Foodservice_Items_Master_ID = '#qGetDiscountDataToRemove.BSA_Foodservice_Items_Master_ID#'
		</cfquery>
		
	</cfloop>
	<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
	<!--- ///////////////////////////////////////////////////////////////// REMOVE PRODUCTS END /////////////////////////////////////////////////////////////////// --->
	<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
	
	<!---  Mark the Program as Completed when the price is updated. --->
	<CFQUERY name="Update_Changed_Flag" datasource="#application.datasource#">
		Update	Program_Product_Price_Changed 
		SET		Change_Completed = 1
		WHERE 	CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">		
	</CFQUERY>	
	
	<cfset programObj = CreateObject("component", "components.programs.program") />
	<cfset programObj.makeRFA(renewed_program_id, qGetProgram.Responsible_User_ID) />	
	<cfset Contract_Main_ID = renewed_program_id>
	
		
	<!--- Auto Approve the program --->
	<cfset program_id = Renewed_Program_ID>
	<CFINCLUDE TEMPLATE = "/Common_Files/Contracts/Contract_layered_approve_action_Auto.cfm">

	<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
	<CFQUERY NAME="InsertBizCon" DATASOURCE="#Application.Datasource#">
		INSERT INTO Contract_Evaluation_Notes (Contract_Number, Entered_By, Eval_Action, Notes, Created_Date, Contract_Notes_Type)
		VALUES	(	<cfqueryparam value="#FORM.CONTRACT_NUMBER#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="System" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="History Load" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#variables.BizCon#" cfsqltype="cf_sql_varchar">,
					GETDATE(),
					<cfqueryparam value="2" cfsqltype="cf_sql_integer">
				)				
	</CFQUERY>
	 
	<!--- Dev Note: Kal;  Update the temp table and set 1 if revision created succesfully --->
	<CFQUERY NAME="SetProcessed" DATASOURCE="#Application.Datasource#">
		UPDATE 	PriceChangeProgramList
		SET 	COMPLETED = 1,
				NEW_CONTRACT_MAIN_ID = <cfqueryparam value="#RENEWED_PROGRAM_ID#" cfsqltype="cf_sql_integer">,
				New_Start_Date = <cfqueryparam value="#New_Pgm_Start_Date#" cfsqltype="cf_sql_date">,
				New_End_Date =  <cfqueryparam value="#New_Pgm_End_Date#" cfsqltype="cf_sql_date">
		WHERE 	CONTRACT_NUMBER = <cfqueryparam value="#FORM.CONTRACT_NUMBER#" cfsqltype="cf_sql_varchar">
		AND 	CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
	</CFQUERY>

	<!--- Dev Note: Kal;  Update the end date on the previous program so it expires before the new programs starts --->
	<CFQUERY NAME="UpdatePreviousProgramEndDate" DATASOURCE="#Application.Datasource#">
		Update	Contract_Main
		Set		Contract_Main.Contract_End_Date = Mod_End_Date
		From	Contract_Main
		INNER JOIN PriceChangeProgramList On Contract_Main.Contract_Main_ID = PriceChangeProgramList.Contract_Main_ID 
		and		(DateDiff(d, Contract_Main.Contract_Start_Date, #CreateODBCDatetime(New_Pgm_Start_Date)#) > 0)
		and		Contract_Main.Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
	</CFQUERY>
		
	<!--- update contract_main --->
	<CFSTOREDPROC PROCEDURE="Update_Contract_Quantity" datasource="#application.datasource#">
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Contract_Main_ID"		VALUE="#RENEWED_PROGRAM_ID#">						
		<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Verify_Product_Volume"	VALUE="0">
	</CFSTOREDPROC>
		
</cfloop>

<!--- Dev Note: Kal;  Update the temp table with the new program's status and version --->
<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
	UPDATE 	PriceChangeProgramList
	SET		New_Version = Revision_Version, 
			New_Contract_Status_ID = Contract_Status_Type_IDX,
			New_Contract_Status = Contract_Status_Type_Desc
	FROM	PriceChangeProgramList, Contract_Main, Contract_Status_Types  
	WHERE	PriceChangeProgramList.New_Contract_Main_ID = Contract_Main.Contract_Main_ID
	AND		PriceChangeProgramList.Contract_Main_ID = Contract_Main.Revision_of_Contract_Main_ID
	AND		Contract_Status_Types.Contract_Status_Type_ID = Contract_Status_Type_IDX
</CFQUERY>
