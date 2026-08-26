<!---
       Name:          Auto_Revise_Program_Custom_Customer_Substitution.cfm
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  04/13/2011
       Created By:    Tim Ford
       Label:		  26539
       Description:   This file is used to auto revise a list of programs and substitute a distributors based on ship to's defined by the client
--->


<cfquery name="Programs_Custom_Revision" datasource="#application.datasource#">
	SELECT 	Top 100 CONTRACT_MAIN_ID AS PROGRAM_ID, CONTRACT_NUMBER, New_Start_Date, New_End_Date, Responsible_User_ID 
	FROM  	Program_Customer_Substitution
	WHERE	Completed = 0
	ORDER BY CONTRACT_NUMBER, CONTRACT_MAIN_ID
</cfquery>

<!--- Setting Variables --->
<cfset Scheduled = 1>
<cfset NumberUpdated = 0> <!--- Just an indicator of number of programs renewed --->
<cfset form.IsAutoRevision = 1 />
<cfset programObj = CreateObject("component", "components.programs.program") />
<cfset variables.BizCon = "USFS Boston locations have been replaced with USFS Connecticut locations - systematically updating programs" />
<!--- /////////////////////////////////////////////////////////////////////////////////////////////////// --->

<cfloop query="Programs_Custom_Revision">
	<!---sets all the stuff that contract revision needs--->
	<cf_cryp type="en" string="#Programs_Custom_Revision.PROGRAM_ID#"  key="#request.key#">
	<cfset Form.Program_ID = cryp.value>
	<cfset Form.ISREVISIONOFEXISTINGCONTRACT = 1>
	
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
		
		<cfset useLakebaseForgetPacket = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_renewal_packets")>
<cfif useLakebaseForgetPacket>
	<cftry>
		<cfset getPacket = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_renewal_packets", {
				"contract_renewal_packets_id" = "eq.#savePacket.Contract_Renewal_Packets_ID#",
				"select" = "xml_file_location"
			}), "xml_file_location"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPacket = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPacket>
<CFQUERY NAME="getPacket" datasource="#application.datasource#" MAXROWS="1">
			SELECT XML_File_Location
			FROM Contract_Renewal_Packets
			WHERE Contract_Renewal_Packets_ID = '#savePacket.Contract_Renewal_Packets_ID#'
		</CFQUERY>
</cfif>
	
		<CFFILE ACTION="READ" FILE="#getPacket.XML_File_Location#" VARIABLE="Packet_Data">
		<CFWDDX ACTION="WDDX2CFML" INPUT="#Packet_Data#" OUTPUT="Program_Packet">

		<CFSET FORM.Contract_Number 		= Program_Packet.Basic_Information.Contract_Number>
		<!--- Dev Note: KAL; Setting the values for the intermediate revision version here --->
		<CFSET FORM.start_date				= New_Pgm_Start_Date>
		<CFSET FORM.end_date				= New_Pgm_End_Date>

		<!--- Dev Note: KAL; D15524: Prorate the volume for the remainder of the program span --->
		<CFSET variables.previous_start_date	= Program_Packet.Basic_Information.Contract_Start_Date>
		<CFSET variables.previous_end_date		= Program_Packet.Basic_Information.Contract_End_Date>	
		<CFSET variables.previous_span			= DateDiff("d", variables.previous_start_date, variables.previous_end_date) + 1>
		<CFSET variables.new_span				= DateDiff("d", New_Pgm_Start_Date, New_Pgm_End_Date) + 1>
		<CFSET variables.new_pgm_quantity		= int((variables.new_span/variables.previous_span)*Program_Packet.Basic_Information.Contract_Quantity) />
		
		<CFSET FORM.Quantity					= variables.new_pgm_quantity>	 
		<CFSET FORM.Adv_Spending_Amount			= "">

		<CFSET Form.Currency					= Program_Packet.Basic_Information.CURRENCY>
		<!--- Dev Note: KAL; D15656: Add Legacy ID to Mass Price Change --->
		<CFSET Form.Legacy_ID					= Program_Packet.Basic_Information.LEGACY_DEAL_ID>
	
		<CFSET Form.Responsible_User_Id_Position_Id = "#User_Position_ID#_#Program_Packet.Basic_Information.Responsible_User_Id#">
		<CFSET FORM.Approved_By_User_ID 		=  Program_Packet.Basic_Information.Approved_By_User_ID>	
		<CFSET FORM.Contract_Reference_Number	= Program_Packet.Basic_Information.Contract_Reference_Number>
	
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
		<!--- Dev Note: KAL; D16507: Auto Revision not copying over performance dates --->
		<CFSET FORM.Performance_Start_Date		= Program_Packet.Basic_Information.Performance_Start_Date>
		<CFSET FORM.Performance_End_Date		= Program_Packet.Basic_Information.Performance_End_Date>
		 
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

		<cfset FORM.Notes = FORM.Notes & "USFS Boston locations have been replaced with USFS Connecticut locations - systematically updating programs" />
		
		<cfif FORM.Legacy_ID EQ "NULL">
			<cfset FORM.Legacy_ID = "" />
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
			
		</CFOUTPUT>
						
	<!--- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		Customer Substitution: If the program contains a distributor that needs to be substituted, then delete both distibutors that need to be removed and added,
		then insert just distibutors that need to be added.
		
		For label D26539: The scenario is as follows:
		If ship to's 08896105 or 08896111 exist then delete ship to's 08896105, 08896111, 30938100 and 30938105 from Contract_Distributors then 
		insert ship to's 30938100 and 30938105 into Contract_Distributors.
		
		If ship to 08896502 exist then delete ship to's 08896502 and 30938500 from Contract_Distributors then 
		insert ship to 30938500 into Contract_Distributors.
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
	<cfquery name="qCheckCustomers1" datasource="#application.datasource#">
		SELECT	Contract_Distributors.* 
		FROM	Contract_Distributors
				INNER JOIN BSA_Foodservice_Customers ON
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
		WHERE	Contract_Main_ID = '#Program_ID_To_Replicate#'
		AND		Contract_Distributors.Deleted = 0
		AND		BSA_Foodservice_Customers.Ship_To IN ('08896105', '08896111')
	</cfquery>
	
	<cfif qCheckCustomers1.RecordCount>
		<cfquery name="qUpdateInsertCustomers1" datasource="#application.datasource#">
			UPDATE	Contract_Distributors
			SET		Contract_Distributors.Deleted = 1
			FROM	Contract_Distributors
					INNER JOIN BSA_Foodservice_Customers ON
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
			WHERE	Contract_Main_ID = '#renewed_program_id#'
			AND		BSA_Foodservice_Customers.Ship_To IN ('08896105', '08896111', '30938100', '30938105')
			
			INSERT INTO Contract_Distributors
				(BSA_Foodservice_Customers_ID, Contract_Main_ID)
			SELECT	DISTINCT BSA_Foodservice_Customers_ID, '#renewed_program_id#'
			FROM	BSA_Foodservice_Customers
			WHERE	Ship_To IN ('30938100', '30938105')
		</cfquery>
	</cfif>
	
	<cfquery name="qCheckCustomers2" datasource="#application.datasource#">
		SELECT	Contract_Distributors.* 
		FROM	Contract_Distributors
				INNER JOIN BSA_Foodservice_Customers ON
				BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
		WHERE	Contract_Main_ID = '#Program_ID_To_Replicate#'
		AND		Contract_Distributors.Deleted = 0
		AND		BSA_Foodservice_Customers.Ship_To = '08896502'
	</cfquery>
	
	<cfif qCheckCustomers2.RecordCount>
		<cfquery name="qUpdateInsertCustomers2" datasource="#application.datasource#">
			UPDATE	Contract_Distributors
			SET		Contract_Distributors.Deleted = 1
			FROM	Contract_Distributors
					INNER JOIN BSA_Foodservice_Customers ON
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
			WHERE	Contract_Main_ID = '#renewed_program_id#'
			AND		BSA_Foodservice_Customers.Ship_To IN ('08896502', '30938500')
			
			INSERT INTO Contract_Distributors
				(BSA_Foodservice_Customers_ID, Contract_Main_ID)
			SELECT	DISTINCT BSA_Foodservice_Customers_ID, '#renewed_program_id#'
			FROM	BSA_Foodservice_Customers
			WHERE	Ship_To = '30938500'
		</cfquery>
	</cfif>
	
	<cfquery name="qAdjustProgramWeight" datasource="#application.datasource#">
		DECLARE
		@Program_Weight		FLOAT,
		@Distributor_Count	INT

		SELECT	@Distributor_Count = COUNT(*)
		FROM	Contract_Distributors
		WHERE	Contract_Main_ID =  '#renewed_program_id#'
		AND		Deleted = 0
		
		SET @Program_Weight = 100.00 / @Distributor_Count
		
		UPDATE	Contract_Distributors
		SET		Program_Weight = @Program_Weight
		WHERE	Contract_Main_ID = '#renewed_program_id#'
		AND		Deleted = 0
	</cfquery>
	
	<cfset programObj = CreateObject("component", "components.programs.program") />
	<cfset programObj.makeRFA(renewed_program_id, Program_Packet.Basic_Information.Responsible_User_ID) />	
	<cfset Contract_Main_ID = renewed_program_id>
	
	<!--- For Simplot/5.0 Only: Call the freight populate routine --->
	<cfstoredproc datasource="#application.datasource#" procedure="Populate_Program_Distributor_Freight" >
		<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#RENEWED_PROGRAM_ID#" variable="@Program_ID" />
		<cfprocparam type="in" cfsqltype="cf_sql_bit" value="1" variable="@Recalc_All" />
	</cfstoredproc>

		
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
		UPDATE 	Program_Customer_Substitution
		SET 	Completed = 1,
				New_Contract_Main_ID = <cfqueryparam value="#RENEWED_PROGRAM_ID#" cfsqltype="cf_sql_integer">
		WHERE 	CONTRACT_NUMBER = <cfqueryparam value="#FORM.CONTRACT_NUMBER#" cfsqltype="cf_sql_varchar">
		AND 	CONTRACT_MAIN_ID = <cfqueryparam value="#Program_ID_To_Replicate#" cfsqltype="cf_sql_integer">
	</CFQUERY>
		
</cfloop>

