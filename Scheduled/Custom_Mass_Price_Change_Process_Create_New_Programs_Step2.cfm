<!---
       Name:          Custom_Mass_Price_Change_Process_Create_New_Programs_Step2.cfm
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  02/02/2010
       Created By:    Tim Ford
       Description:   This file is used to auto renew bunch of programs selected in the query. 
--->

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
			
			
			<cfset Original_Creating_User_Position_ID 					= qGetProgram.Original_Creating_User_Position_ID>
			<cfset User_Position_ID 									= qGetProgram.Creating_User_Position_ID>
			<cfset request.AccessStructure.Creating_User_Position_ID 	= qGetProgram.Creating_User_Position_ID>
			<cfset request.AccessStructure.User_ID 						= qGetProgram.Creator_ID>
			<CFSET FORM.Notes											= trim(qGetProgram.Notes)>
				
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
		
		
			<!--- Dev Note: KAL; Setting the values for the intermediate revision version here --->
			<CFSET FORM.start_date				= New_Pgm_Start_Date>
			<CFSET FORM.end_date				= New_Pgm_End_Date>
		
			<!--- Dev Note: KAL; D15524: Prorate the volume for the remainder of the program span --->
			<CFSET variables.previous_start_date	= qGetProgram.Contract_Start_Date>
			<CFSET variables.previous_end_date		= qGetProgram.Contract_End_Date>	
			<CFSET variables.previous_span			= DateDiff("d", variables.previous_start_date, variables.previous_end_date) + 1>
			<CFSET variables.new_span				= DateDiff("d", New_Pgm_Start_Date, New_Pgm_End_Date) + 1>
			<CFSET variables.new_pgm_quantity		= Round((variables.new_span/variables.previous_span)*qGetProgram.Contract_Quantity) />
			<CFSET FORM.Quantity					= variables.new_pgm_quantity>	 
				
			<CFSET FORM.Approved_By_User_ID 		=  "00000000-0000-0000-0000000000000001"> <!--- Dev Note: KAL; D14181: Change the Approver to the Auto Price Change --->		
			
			<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
			<cfset FORM.Notes = FORM.Notes & " - (Price Change Applied - " & DateFormat(Programs_Custom_Revision.New_Start_Date, "mm/dd/yyyy") &")" />
		
			<cfquery name="qUpdateDatesAndVolume" datasource="#application.datasource#">
				UPDATE	Contract_Main
				SET		Contract_Quantity = '#FORM.Quantity#', <!---<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.Quantity#">,--->
						Contract_Start_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.Start_Date#">,
						Contract_End_Date = <cfqueryparam cfsqltype="cf_sql_date" value="#Form.End_Date#">
				WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
			</cfquery>
			
			<cfquery name="qGetNewProgramData" datasource="#application.datasource#">
				SELECT	Contract_Number
				FROM	Contract_Main
				WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Renewed_Program_ID#">
			
			</cfquery>
			
			<CFSET FORM.Contract_Number = qGetNewProgramData.Contract_Number>
			
			<CFOUTPUT>
				<cfset form.Scheduled 					= 1>
				<cfset NumberUpdated = NumberUpdated + 1>
				
			</CFOUTPUT>
							
			<!--- Update the price for the products. --->
			<CFQUERY name="Update_Price_Change" datasource="#application.datasource#">
				Update	PROGRAM_FIXED_PRICE_PRODUCT_DATA 
				SET		Fixed_Price_Value = PPPC.New_Price
				FROM 	Contract_Main CM
				INNER JOIN CONTRACT_PRODUCTS CP ON CM.CONTRACT_MAIN_ID = CP.CONTRACT_MAIN_ID AND CP.DELETED = 0 and CP.Product_Type_ID = 1
				INNER JOIN PROGRAM_FIXED_PRICE_PRODUCT_DATA FX ON FX.PROGRAM_ID = CP.CONTRACT_MAIN_ID AND CP.CONTRACT_PRODUCTS_ID = FX.CONTRACT_PRODUCTS_ID  AND FX.DELETED = 0
				INNER JOIN Program_Product_Price_Changed PPPC ON PPPC.CONTRACT_MAIN_ID = CM.Renewal_Of_Contract_Main_ID 
					AND PPPC.BSA_FOODSERVICE_ITEMS_MASTER_ID = CP.BSA_FOODSERVICE_ITEMS_MASTER_ID
					AND PPPC.Change_Completed = 0
				WHERE 	CM.DELETED = 0 
				AND	CM.CONTRACT_MAIN_ID = <cfqueryparam value="#RENEWED_PROGRAM_ID#" cfsqltype="cf_sql_integer">
				AND	PPPC.CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">		
			</CFQUERY>
		
			<!---  Mark the Program as Completed when the price is updated. --->
			<CFQUERY name="Update_Changed_Flag" datasource="#application.datasource#">
				Update	Program_Product_Price_Changed 
				SET		Change_Completed = 1
				WHERE 	CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">		
			</CFQUERY>	
			
			<!--- Make RFA --->
			<cfset programObj = CreateObject("component", "components.programs.program") />
			<cfset programObj.makeRFA(renewed_program_id, qGetProgram.Responsible_User_ID) />	
			<cfset Contract_Main_ID = renewed_program_id>
		
			<!--- For Simplot/5.0 Only: Call the freight populate routine --->
			<cfstoredproc datasource="#application.datasource#" procedure="Populate_Program_Distributor_Freight_Mass_Price_Process" >
				<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#RENEWED_PROGRAM_ID#" />
			</cfstoredproc>	
			 
			<!--- For Simplot/5.0 Only: Call the freight populate routine --->
			<!--- Update the Freight for the programs. --->
			<CFQUERY name="Update_Freight_Change" datasource="#application.datasource#">
				Update	Program_Distributor_Freight 
				SET		IBF_Rate = New_IBF_Rate
				FROM 	Contract_Main CM
				INNER JOIN Program_Distributor_Price_Changed PDPC ON PDPC.CONTRACT_MAIN_ID = CM.Renewal_Of_Contract_Main_ID AND PDPC.Change_Completed = 0
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
			
				
			<!--- Auto Approve the program --->
			<cfset program_id = Renewed_Program_ID>
			<CFINCLUDE TEMPLATE = "/Common_Files/Contracts/Contract_layered_approve_action_Auto.cfm">

			<CFSTOREDPROC PROCEDURE="Update_Contract_Quantity" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Contract_Main_ID"		VALUE="#RENEWED_PROGRAM_ID#">						
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Verify_Product_Volume"	VALUE="1">
			</CFSTOREDPROC>
			
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
			 
			 <!---initialize the BidRequestManager--->
			<cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />
		
			<!---apply status for bid request--->
			<cfset bidRequestManager.applyStatus(RENEWED_PROGRAM_ID, 2) />
			
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