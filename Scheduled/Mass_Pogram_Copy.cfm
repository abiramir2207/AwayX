<!---
       Name:          Mass_Pogram_Copy.cfm 
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  12/04/2009
       Created By:    Tim Ford
       Label:		  21443
       Description:   This file is used to auto copy bunch of programs selected in the query. 
						Add two columns (CHANGE_COMPLETED, NEW_CONTRACT_MAIN_ID) to the table holding the program_ID's. These columns are used to filter selection. 
						Certain values like Start_Date, End_Date are set below. So whereever a 'Dev Note' appears below, set the appropriate values.
--->


<!---*** Removed the Stored Proc as we would be running the SP manually and scheduling the Mass Price to run in batches of 25. ***--->

<cfquery name="Programs_Custom_Revision" datasource="#application.datasource#">
	SELECT Top 25 CONTRACT_MAIN_ID AS PROGRAM_ID, CONTRACT_NUMBER, New_Start_Date, New_End_Date, Responsible_User_ID 
	FROM  PriceChangeProgramList
	WHERE Copied = 0
	ORDER BY  CONTRACT_NUMBER, CONTRACT_MAIN_ID
</cfquery>

<!--- Setting Variables --->
<cfset Scheduled = 1>
<cfset NumberUpdated = 0> <!--- Just an indicator of number of programs renewed --->
<cfset Form.IsAutoCopy = 1 />
<cfset Form.ForceFreightOnAutoCopy = 0 />
<cfset programObj = CreateObject("component", "components.programs.program") />
<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
<!--- <cfset variables.BizCon = "This program has been systematically created due to a price increase effective - " & DateFormat(Programs_Custom_Revision.New_Start_Date, "mm/dd/yyyy") /> --->
<cfset variables.BizCon = "This program was automatically rolled over from 2010." />
<!--- /////////////////////////////////////////////////////////////////////////////////////////////////// --->

<cfloop query="Programs_Custom_Revision">
	<!---sets all the stuff that contract revision needs--->
	<cf_cryp type="en" string="#Programs_Custom_Revision.PROGRAM_ID#"  key="#request.key#">
	<cfset currentRenewingParentProgramID = Programs_Custom_Revision.Program_ID />
	<cfset Form.Program_ID = cryp.value>
	<cfset Form.IsRevisionOfExistingContract = 0>
	
	<cfset New_Pgm_Start_Date 	= Programs_Custom_Revision.New_Start_Date	/>	
	<cfset New_Pgm_End_Date 	= Programs_Custom_Revision.New_End_Date	/>

	<cfquery name="Getcompany" datasource="#application.datasource#">
		SELECT Top 1 Company_Main_ID
		FROM Company_Main
	</cfquery>

	<cfset request.AccessStructure.Company_Main_ID = GetCompany.Company_Main_ID>
	
	<cfinclude template="/common_files/contracts/contract_renewal_action.cfm">
		
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

		<cfinclude template="/common_files/contracts/contract_number_generator.cfm">
		<CFSET FORM.Contract_Number 		= generator_contract_number />
		<!--- Dev Note: KAL; Setting the values for the intermediate revision version here --->
		<CFSET FORM.start_date				= New_Pgm_Start_Date>
		<CFSET FORM.end_date				= New_Pgm_End_Date>

		<!--- Dev Note: KAL; D15524: Prorate the volume for the remainder of the program span --->
		<CFSET variables.previous_start_date	= Program_Packet.Basic_Information.Contract_Start_Date>
		<CFSET variables.previous_end_date		= Program_Packet.Basic_Information.Contract_End_Date>	
		<CFSET variables.previous_span			= DateDiff("d", variables.previous_start_date, variables.previous_end_date) + 1>
		<CFSET variables.new_span				= DateDiff("d", New_Pgm_Start_Date, New_Pgm_End_Date) + 1>
		<CFSET variables.new_pgm_quantity		= Round((variables.new_span/variables.previous_span)*Program_Packet.Basic_Information.Contract_Quantity) />
		
		<CFSET FORM.Quantity					= variables.new_pgm_quantity>	 
		<CFSET FORM.Adv_Spending_Amount			= "">
		<!--- Dev Note: KAL; D15524: JRS - Issues with PRGs after Price Increase - Programs have currency as CAD --->
		<CFSET Form.Currency					= Program_Packet.Basic_Information.CURRENCY>
		<!--- Dev Note: KAL; D15656: Add Legacy ID to Mass Price Change --->
		<CFSET Form.Legacy_ID					= "">
	
		<CFSET Form.Responsible_User_Id_Position_Id = "#User_Position_ID#_#Program_Packet.Basic_Information.Responsible_User_Id#">
		<CFSET FORM.Approved_By_User_ID 		=  Program_Packet.Basic_Information.Responsible_User_Id />
		<CFSET FORM.Contract_Reference_Number	= Program_Packet.Basic_Information.Contract_Reference_Number>
		<CFSET FORM.Operating_Group_1			= Program_Packet.Basic_Information.Operating_Group_Level_1_ID />
		<CFSET FORM.Operating_Group_2			= Program_Packet.Basic_Information.Operating_Group_Level_2_ID />
		<CFSET FORM.Contract_Title				= Program_Packet.Basic_Information.Contract_Title>
		<CFSET FORM.Contract_Quantity_UOM_IDX	= Program_Packet.Basic_Information.Contract_Quantity_uom_IDX>
		<CFSET FORM.Fixed_Rebate_Amount			= Program_Packet.Basic_Information.Fixed_Rebate_Amount>
		<CFSET FORM.Discount_Type_ID			= Program_Packet.Basic_Information.Discount_Type_ID>
		<CFSET FORM.Search_Sequence_ID			= Program_Packet.Basic_Information.Search_Sequence_ID>
	
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
		 
		<CFIF FORM.Performance_Start_Date EQ "NULL" OR FORM.Performance_End_Date EQ "NULL" >
			<CFSET FORM.Performance_Start_Date		= "" />
			<CFSET FORM.Performance_End_Date		= "" />				
		</CFIF>	
				 
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
		<!--- Dev Note: Kal;D15656  Add Legacy ID, Business Considerations, Date on Notes to Mass Price Change --->
		<cfset FORM.Notes = FORM.Notes />

		
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
	
	<!--- Make RFA --->
	<cfset programObj = CreateObject("component", "components.programs.program") />
	<cfset programObj.makeRFA(renewed_program_id, Program_Packet.Basic_Information.Responsible_User_ID) />	
	<cfset Contract_Main_ID = renewed_program_id>
	
		
	<!--- Auto Approve the program --->
	<cfset program_id = Renewed_Program_ID>
	<!---
	<CFINCLUDE TEMPLATE = "/Common_Files/Contracts/Contract_layered_approve_action_Auto.cfm">

	<!--- Dev Note: KAL; D16959: JRS - Margin page previous version summary displaying zero's --->
	<cfstoredproc datasource="#application.datasource#" procedure="GET_PROFIT_MARGIN_LAYERED" >
		<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#RENEWED_PROGRAM_ID#" />
	</cfstoredproc>
	--->
	
	
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


