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
<!--- **** Set the path to the file with the products. Use the shared path if available. **** --->
<cfset Product_File_Path =  "" />
<cfset Freight_File_Path =  "" />
<cfset Product_File_Path =  "\\dbstage03\Client_Data\Simplot\MassPriceChange\PriceChange.csv" />
<cfset Freight_File_Path =  "\\dbstage03\Client_Data\Simplot\MassPriceChange\FreightChange.csv" />
<cfif NOT FileExists(#Product_File_Path#)> <cfset Product_File_Path =  "" /> </cfif>
<cfif NOT FileExists(#Freight_File_Path#)> <cfset Freight_File_Path =  "" /> </cfif>
		
<cfstoredproc datasource="#application.datasource#" procedure="Mass_Price_Change_Upload_SP">
	<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#Product_File_Path#" variable="@@Product_file" />
	<cfprocparam type="in" cfsqltype="cf_sql_varchar" value="#Freight_File_Path#" variable="@@Freight_file" />
</cfstoredproc>


<cfquery name="Programs_Custom_Revision" datasource="#application.datasource#">
	SELECT CONTRACT_MAIN_ID AS PROGRAM_ID, CONTRACT_NUMBER, New_Start_Date, New_End_Date, Responsible_User_ID 
	FROM  PriceChangeProgramList
--	WHERE Killed = 0 AND Skip = 0 AND Completed = 0
	WHERE ISNULL(Completed,0) = 0
	ORDER BY  CONTRACT_NUMBER, CONTRACT_MAIN_ID
</cfquery>

<!--- Setting Variables --->
<cfset Scheduled = 1>
<cfset NumberUpdated = 0> <!--- Just an indicator of number of programs renewed --->
<cfset form.IsAutoRevision = 1 />
<cfset programObj = CreateObject("component", "components.programs.program") />
<!--- /////////////////////////////////////////////////////////////////////////////////////////////////// --->

<cfloop query="Programs_Custom_Revision">
	<!---sets all the stuff that contract revision needs--->
	<cf_cryp type="en" string="#Programs_Custom_Revision.PROGRAM_ID#"  key="#request.key#">
	<cfset Form.Program_ID = cryp.value>
	<cfset Form.ISREVISIONOFEXISTINGCONTRACT = 1>
	
	<cfset New_Pgm_Start_Date 	= Programs_Custom_Revision.New_Start_Date	/>	
	<cfset New_Pgm_End_Date 	= Programs_Custom_Revision.New_End_Date	/>

	<cfquery name="Getcompany" datasource="#application.datasource#">
		SELECT Top 1 Company_Main_ID
		FROM Company_Main
	</cfquery>

	<cfset request.AccessStructure.Company_Main_ID = GetCompany.Company_Main_ID>
	
	<cfinclude template="/common_files/contracts/contract_revise_action.cfm">
		
		<cfquery name="GetOriginalUser" datasource="#application.datasource#">
			SELECT 	Original_Creating_User_Position_ID, 
					Creating_User_Position_ID, 
					Creator_ID
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfset Original_Creating_User_Position_ID = GetOriginalUser.Original_Creating_User_Position_ID>
		<cfset User_Position_ID = GetOriginalUser.Creating_User_Position_ID>
		<cfset request.AccessStructure.Creating_User_Position_ID = GetOriginalUser.Creating_User_Position_ID>
		<cfset request.AccessStructure.User_ID = GetOriginalUser.Creator_ID>
		
		<CFQUERY NAME="getPacket" datasource="#application.datasource#" MAXROWS="1">
			SELECT XML_File_Location
			FROM Contract_Renewal_Packets
			WHERE Contract_Renewal_Packets_ID = '#savePacket.Contract_Renewal_Packets_ID#'
		</CFQUERY>
	
		<CFFILE ACTION="READ" FILE="#getPacket.XML_File_Location#" VARIABLE="Packet_Data">
		<CFWDDX ACTION="WDDX2CFML" INPUT="#Packet_Data#" OUTPUT="Program_Packet">

		<CFSET FORM.Contract_Number 		= Program_Packet.Basic_Information.Contract_Number>
		<!--- Dev Note: KAL; Setting the values for the intermediate revision version here --->
		<CFSET FORM.start_date				= New_Pgm_Start_Date>
		<CFSET FORM.end_date				= New_Pgm_End_Date>
		<!--- <CFSET FORM.Quantity			= New_Pgm_Quantity> --->
		<CFSET FORM.Adv_Spending_Amount		= "">
	
		<CFSET Form.Responsible_User_Id_Position_Id = "#User_Position_ID#_#Program_Packet.Basic_Information.Responsible_User_Id#">
		<!--- <CFSET FORM.Approved_By_User_ID 		= "00000000-0000-0000-0000000000000001"> <!--- Dev Note: KAL; D14181: Change the Approver to the Auto Price Change --->
		<CFSET FORM.Approved_By_User_ID 		= Program_Packet.Basic_Information.Approved_By_User_ID> --->		
		<CFSET FORM.Contract_Reference_Number	= Program_Packet.Basic_Information.Contract_Reference_Number>
		<CFSET FORM.Quantity					= Program_Packet.Basic_Information.Contract_Quantity>
		<CFSET FORM.Contract_Title				= Program_Packet.Basic_Information.Contract_Title>
		<CFSET FORM.Contract_Quantity_UOM_IDX	= Program_Packet.Basic_Information.Contract_Quantity_uom_IDX>
		<CFSET FORM.Fixed_Rebate_Amount			= Program_Packet.Basic_Information.Fixed_Rebate_Amount>
		<CFSET FORM.Discount_Type_ID			= Program_Packet.Basic_Information.Discount_Type_ID>
	
		<CFSET FORM.Dist_Brand_Eligibility		= Program_Packet.Basic_Information.Dist_Brand_Eligibility>
		<CFSET FORM.button_caption				= "save changes">
		<CFSET FORM.Notes						= trim(Program_Packet.Basic_Information.Notes)>
		<CFSET FORM.Comments					= trim(Program_Packet.Basic_Information.Comments)>
		<CFSET FORM.RenewNeutral				= Program_Packet.Basic_Information.RenewNeutral>
		<CFSET FORM.ProgramType					= Program_Packet.Basic_Information.ProgramType_ID>
		<CFSET FORM.ProgramType_ID				= Program_Packet.Basic_Information.ProgramType_ID>
		
		<cfif FORM.ProgramType_ID EQ 0>
			<h1>THIS CONTRACT DOES NOT HAVE ALL THE APPROPIATE INFORMATION TO BE OF ANY USE</h1>
			<cfabort>
		</cfif>
		
		<CFSET FORM.Created_Type				= Program_Packet.Basic_Information.Created_Type>
		<!--- Claim Performance Requirements DATA--->
		<CFSET FORM.chkClaimPerfReq_1			= Program_Packet.Basic_Information.chkClaimPerfReq_1>
		<CFSET FORM.chkClaimPerfReq_2			= Program_Packet.Basic_Information.chkClaimPerfReq_2>
		<CFSET FORM.chkClaimPerfReq_3			= Program_Packet.Basic_Information.chkClaimPerfReq_3>
		<CFSET FORM.chkClaimPerfReq_4			= Program_Packet.Basic_Information.chkClaimPerfReq_4>
		<CFSET FORM.chkClaimPerfReq_5			= Program_Packet.Basic_Information.chkClaimPerfReq_5>
		<CFSET FORM.chkClaimPerfReq_6			= Program_Packet.Basic_Information.chkClaimPerfReq_6>
		<CFSET FORM.chkClaimPerfReq_7			= Program_Packet.Basic_Information.chkClaimPerfReq_7>
		<CFSET FORM.chkClaimPerfReq_8			= Program_Packet.Basic_Information.chkClaimPerfReq_8>
		<CFSET FORM.chkClaimPerfReq_9			= Program_Packet.Basic_Information.chkClaimPerfReq_9>
		<!--- Communication Settings --->	
		<CFSET FORM.CommRecip_1					= Program_Packet.Basic_Information.CommRecip_1>
		<CFSET FORM.CommRecip_2					= Program_Packet.Basic_Information.CommRecip_2>
		<CFSET FORM.CommRecip_3					= Program_Packet.Basic_Information.CommRecip_3>
		<CFSET FORM.CommRecip_4					= Program_Packet.Basic_Information.CommRecip_4>

		<!--- Payment Cycle --->
		<CFSET FORM.PaymentCycle				= Program_Packet.Basic_Information.PaymentCycle>
		<!--- Controllable --->
		<CFSET FORM.Controllable_Volume			= Program_Packet.Basic_Information.Controllable_Volume>
		<!--- Growth Inclusion --->
		<CFSET FORM.Growth_Inclusion			= Program_Packet.Basic_Information.Growth_Inclusion>
		<!--- Claim Mechanics --->
		<cfset Form.ClaimMechOption				= Program_Packet.Basic_Information.ClaimMechanics>
		<CFSET FORM.BldUpInvoice				= Program_Packet.Basic_Information.BldUpInvoice>
		<!--- Advanced Spending --->
		<cfset FORM.Adv_Spend_Amount			= Program_Packet.Basic_Information.Adv_Spending_Amount>
		<!--- Global GL Assignment --->
		<CFSET FORM.Global_GL_Assign_Choice		= Program_Packet.Basic_Information.GL_Assignment>
		<CFSET FORM.On_Release_Contract_Status_Type_IDX = Program_Packet.Basic_Information.On_Release_Contract_Status_Type_IDX>

		<cfset FORM.Business_Segment_ID			= Program_Packet.Basic_Information.Business_Segment_ID>
		<cfset FORM.LOB_ID						= Program_Packet.Basic_Information.Line_Of_Business_ID>
		
		<cfset FORM.Rebate_Recipient_Customer_ID= Program_Packet.Basic_Information.Rebate_Recipient_Customer_ID>
		<cfif FORM.Rebate_Recipient_Customer_ID EQ "NULL">
			<cfset FORM.Rebate_Recipient_Customer_ID = "" />
		</cfif>
		<cfif FORM.Notes EQ "NULL">
			<cfset FORM.Notes = "" />
		</cfif>
		
		<CFOUTPUT>
			<cfset form.Contract_Quantity_UOM_IDX 	= Contract_Quantity_UOM_IDX>
			<cfset form.Document_ID 				= "contract_create_1_form">
			<cfset form.Query_Type 					= "INSERT">
			<cfset form.CONTRACT_RENEWAL_PACKETS_ID = savePacket.Contract_Renewal_Packets_ID>
			<cfset form.Scheduled 					= 1>
			<!--- Insert info into contract_main table --->
			<cfinclude template="/common_files/contracts/queries.cfm">

			<cfset NumberUpdated = NumberUpdated + 1>
				#NumberUpdated# - #FORM.Contract_Number# - #Renewed_Program_ID#<hr>
		</CFOUTPUT>
						
	<!--- Update the price for the products. --->
	<CFQUERY name="Update_Price_Change" datasource="#application.datasource#">
		Update	Program_Rebates_Component_Data 
		SET		RATE = PPPC.New_Price
		FROM 	Contract_Main CM
		INNER JOIN CONTRACT_PRODUCTS CP ON CM.CONTRACT_MAIN_ID = CP.CONTRACT_MAIN_ID AND CP.DELETED = 0 and CP.Product_Type_ID = 2
		INNER JOIN Program_Rebates_Product_Data PRD ON CP.CONTRACT_PRODUCTS_ID = PRD.CONTRACT_PRODUCTS_ID  AND PRD.DELETED = 0
		INNER JOIN Program_Rebates_Component_Data PRCD ON PRD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID  AND PRCD.DELETED = 0
		-- INNER JOIN PROGRAM_FIXED_PRICE_PRODUCT_DATA FX ON FX.PROGRAM_ID = CP.CONTRACT_MAIN_ID AND CP.CONTRACT_PRODUCTS_ID = FX.CONTRACT_PRODUCTS_ID  AND FX.DELETED = 0
		INNER JOIN Program_Product_Price_Changed PPPC ON PPPC.CONTRACT_MAIN_ID = CM.Revision_Of_Contract_Main_ID 
			AND PPPC.CONTRACT_NUMBER = CM.CONTRACT_NUMBER 
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
	
	<cfset programObj = CreateObject("component", "components.programs.program") />
	<cfset programObj.makeRFA(renewed_program_id, Program_Packet.Basic_Information.Responsible_User_ID) />	
	<cfset Contract_Main_ID = renewed_program_id>
	
	<!--- For Simplot/5.0 Only: Call the freight populate routine --->
	<cfstoredproc datasource="#application.datasource#" procedure="Populate_Program_Distributor_Freight" >
		<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#RENEWED_PROGRAM_ID#" variable="@Program_ID" />
		<cfprocparam type="in" cfsqltype="cf_sql_bit" value="1" variable="@Recalc_All" />
	</cfstoredproc>
	
	<!--- For Simplot/5.0 Only: Call the freight populate routine --->
	<!--- Update the Freight for the programs. 
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
	--->
	
	<!--- For Simplot/5.0 Only: Call the freight populate routine --->
	<!---  Mark the Program as Completed when the Freight is updated. 
	<CFQUERY name="Update_Changed_Flag" datasource="#application.datasource#">
		Update	Program_Distributor_Price_Changed
		SET		Change_Completed = 1
		WHERE 	CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">		
	</CFQUERY>
	--->
		
	<!--- Auto Approve the program --->
	<cfset program_id = Renewed_Program_ID>
	<CFINCLUDE TEMPLATE = "/Common_Files/Contracts/Contract_layered_approve_action_Auto.cfm">
	 
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

		
</cfloop>

<!--- Dev Note: Kal;  Update the temp table with the new program's status and version --->
<CFQUERY NAME="UpdateStatus" DATASOURCE="#Application.Datasource#">
	UPDATE 	PriceChangeProgramList
	SET	New_Version = Revision_Version, 
		New_Contract_Status_ID = Contract_Status_Type_IDX,
		New_Contract_Status = Contract_Status_Type_Desc
	FROM	PriceChangeProgramList, Contract_Main, Contract_Status_Types  
	WHERE	PriceChangeProgramList.New_Contract_Main_ID = Contract_Main.Contract_Main_ID
	AND	PriceChangeProgramList.Contract_Main_ID = Contract_Main.Revision_of_Contract_Main_ID
	AND	Contract_Status_Types.Contract_Status_Type_ID = Contract_Status_Type_IDX
</CFQUERY>


