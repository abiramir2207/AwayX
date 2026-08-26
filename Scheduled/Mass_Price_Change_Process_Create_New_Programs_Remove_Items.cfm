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
<cfset variables.BizCon = "This program has been systematically created to remove items effective - " & DateFormat(Programs_Custom_Revision.New_Start_Date, "mm/dd/yyyy") />
<!--- /////////////////////////////////////////////////////////////////////////////////////////////////// --->

<cfloop query="Programs_Custom_Revision">
	<!---sets all the stuff that contract revision needs--->
	<cfset Program_ID_To_Replicate = Programs_Custom_Revision.CONTRACT_MAIN_ID />
	<cfset programNumberToUseForDelete = Programs_Custom_Revision.CONTRACT_NUMBER />
	
	<cfset New_Pgm_Start_Date 	= Programs_Custom_Revision.New_Start_Date	/>	
	<cfset New_Pgm_End_Date 	= Programs_Custom_Revision.New_End_Date	/>

	<cfquery name="Getcompany" datasource="#application.datasource#">
		SELECT Top 1 Company_Main_ID
		FROM Company_Main
	</cfquery>

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
	
	<cfquery name="qRemoveItems" datasource="#application.datasource#">
		
		IF OBJECT_ID('tempdb..##tmp1') IS NOT NULL
		DROP TABLE ##tmp1
		
		IF OBJECT_ID('tempdb..##tmp2') IS NOT NULL
		DROP TABLE ##tmp2
		
		SELECT	Contract_Products.Contract_Main_ID,
				Contract_products.BSA_Foodservice_Items_Master_ID,
				Contract_products.Contract_Products_ID,
				Contract_Products.Product_Type_ID
		INTO	##tmp1
		FROM	Contract_Main
				INNER JOIN Contract_Products ON
				Contract_Products.Contract_Main_ID  = Contract_Main.Contract_Main_ID
				INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_foodservice_Items_Master_ID = Contract_Products.BSA_foodservice_Items_Master_ID
				INNER JOIN Simplot_Items_Remove ON Simplot_Items_Remove.Item = BSA_Foodservice_Items_Master.Item
		WHERE	Contract_Main.Contract_Main_ID = '#Renewed_Program_ID#'
		AND		Contract_Products.Deleted = 0
		AND		Contract_Products.Product_Type_ID IN (1,2)
		AND		Simplot_Items_Remove.Program_ID = '#programNumberToUseForDelete#'
		
		
		--CONTRACT_PRODUCTS
		UPDATE	Contract_products 
		SET		Deleted = 1
		FROM	Contract_products
				INNER  JOIN ##tmp1 ON ##tmp1.Contract_products_ID = Contract_products.Contract_products_ID
		
		--VOLUME
		UPDATE	Program_Product_Volume 
		SET		Deleted = 1
		FROM	Program_Product_Volume
				INNER JOIN ##tmp1 ON ##tmp1.Contract_Main_ID = Program_Product_Volume.Program_ID AND
				##tmp1.BSA_foodservice_Items_master_ID = Program_Product_Volume.BSA_foodservice_Items_master_ID AND
				Program_Product_Volume.Deleted = 0
		
		
		--FIXED PRICE
		UPDATE	Program_Fixed_Price_Product_Data  
		SET		Deleted = 1
		FROM	##tmp1
				INNER JOIN Program_Fixed_Price_Product_Data ON
				##tmp1.Contract_products_ID = Program_Fixed_Price_Product_Data.Contract_products_ID AND
				##tmp1.Contract_Main_ID = Program_Fixed_Price_Product_Data.Program_ID AND
				Program_Fixed_Price_Product_Data.Deleted = 0
		WHERE	##tmp1.Product_type_ID  = 1
		
		
		--REBATE
		SELECT  DISTINCT
				Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID,
				Program_Rebates_Product_Data.Program_ID,
				Program_Rebates_Product_Data.Contract_Products_ID,
				Program_Rebates_Component_Data.Program_Rebates_Component_Data_ID,
				##tmp1.Product_Type_ID,
				Program_Rebates_Component.Program_Rebates_Component_ID
		INTO	##tmp2
		FROM	##tmp1
				INNER JOIN Program_Rebates_Component ON
				Program_Rebates_Component.Program_ID = ##tmp1.Contract_main_ID
				INNER JOIN Program_Rebates_Product_Data ON
				##tmp1.Contract_products_ID = Program_Rebates_Product_Data.Contract_products_ID AND
				##tmp1.Contract_Main_ID = Program_Rebates_Product_Data.Program_ID AND
				Program_Rebates_Product_Data.Deleted = 0
				INNER JOIN Program_Rebates_Component_Data ON
				Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID AND
				program_Rebates_Component_Data.Program_Rebates_Product_Data_ID =Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID AND 
				program_Rebates_Component_Data.Deleted =0
		WHERE	##tmp1.Product_Type_ID = 2
		
		
		UPDATE	Program_Rebates_Product_Data
		SET		Deleted = 1
		FROM	##tmp2
				INNER JOIN Program_Rebates_Product_Data ON
				##tmp2.Contract_products_ID = Program_Rebates_Product_Data.Contract_products_ID AND
				##tmp2.Program_ID = Program_Rebates_Product_Data.Program_ID AND
				Program_Rebates_Product_Data.Deleted = 0
		WHERE	##tmp2.Product_type_ID = 2
		
		
		UPDATE	Program_Rebates_Component_Data 
		SET		Deleted = 1
		FROM	##tmp2
				INNER JOIN Program_Rebates_Component_Data ON
				##tmp2.Program_Rebates_Component_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Component_Data_ID AND
				##tmp2.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID AND
				Program_Rebates_Component_Data.Deleted = 0
		WHERE	##tmp2.Product_type_ID = 2

	</cfquery>
	
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
	<cfset FORM.Notes = FORM.Notes & " - (Items Removed - " & DateFormat(Programs_Custom_Revision.New_Start_Date, "mm/dd/yyyy") &")" />

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