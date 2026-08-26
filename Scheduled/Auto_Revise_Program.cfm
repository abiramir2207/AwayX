
<!--- <cfset New_Pgm_Start_Date = Effective_Date /><!---  should eb chnaged to use group date ---> --->

	<!---sets all the stuff that contract_renewal_action needs--->
	<cf_cryp type="en" string="#Needs_Revision.Program_ID#"  key="#request.key#">
	<cfset Form.Program_ID = cryp.value>
	<cfset Form.IsRevisionOfExistingContract = 1>
	
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
		SELECT 	Top 1 Company_Main_ID
		FROM 	Company_Main
	</cfquery>
</cfif>

	<cfset request.AccessStructure.Company_Main_ID = GetCompany.Company_Main_ID>
	
	<cfinclude template="/common_files/contracts/contract_renewal_action.cfm">
	
		<cfset useLakebaseForqProgramInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqProgramInfo>
	<cftry>
		<cfset qProgramInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Program_ID_To_Replicate#",
				"select" = "original_creating_user_position_id,creating_user_position_id,creator_id,programtype_id"
			}), "original_creating_user_position_id,creating_user_position_id,creator_id,programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqProgramInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqProgramInfo>
<cfquery name="qProgramInfo" datasource="#application.datasource#">
			SELECT 	Original_Creating_User_Position_ID, Creating_User_Position_ID, Creator_ID, ProgramType_ID
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = '#Program_ID_To_Replicate#'
		</cfquery>
</cfif>
		
		<!--- LOAD SETTINGS --->
		<cfset useLakebaseForgetFieldSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetFieldSettings>
	<cftry>
		<cfset getFieldSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#qProgramInfo.ProgramType_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetFieldSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetFieldSettings>
<cfquery name="getFieldSettings" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_Control_Panel_Options
			WHERE 	ProgramControl_Panel_Options_ID = '#qProgramInfo.ProgramType_ID#'
		</cfquery>
</cfif>
		
		<cfset useLakebaseForAutoRenew = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_auto_renew")>
<cfif useLakebaseForAutoRenew>
	<cftry>
		<cfset AutoRenew = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_auto_renew", {
				"program_id" = "eq.#Program_ID_To_Replicate#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAutoRenew = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAutoRenew>
<cfquery name="AutoRenew" datasource="#application.datasource#">
			SELECT 	* 
			FROM 	Program_Auto_Renew 
			WHERE 	Program_ID = '#Program_ID_To_Replicate#'
		</cfquery>
</cfif>
		
		<!------ Bid Request ----->
		<cfif getFieldSettings.Generic_Type eq "Bid Request">
			<!---get bid request--->
			<cfset bidReqObj = CreateObject("component", "components.programs.bid_request.BidRequestManager").getBidRequest(Program_ID_To_Replicate) />
			<cfset form.Open_Date = "" />
			<cfset form.Date_Needed = "" />
			<cfset form.Expected_Reply_Date = "" />
			<cfset form.Line_Item = bidReqObj.getLineItem() />
		</cfif>
		
		<cfset Original_Creating_User_Position_ID = qProgramInfo.Original_Creating_User_Position_ID>
		<cfset User_Position_ID = qProgramInfo.Creating_User_Position_ID>
		<cfset request.AccessStructure.Creating_User_Position_ID = qProgramInfo.Creating_User_Position_ID>
		<cfset request.AccessStructure.User_ID = qProgramInfo.Creator_ID>
		
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


		<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
			<CFSET FORM.Contract_Number 		= Program_Packet.Basic_Information.Contract_Number>
			<CFSET FORM.start_date				= Program_Packet.Basic_Information.Contract_Start_Date>
			<CFSET FORM.end_date				= Program_Packet.Basic_Information.Contract_End_Date>
			<CFSET FORM.Adv_Spending_Amount		= "">
			<CFSET FORM.Contract_Reference_Number	= Program_Packet.Basic_Information.Contract_Reference_Number>
		<CFELSE>
			<cfinclude template="/common_files/contracts/contract_number_generator.cfm">

			<CFSET FORM.Contract_Number 		= generator_contract_number>
			<CFSET FORM.start_date				= "">
			<CFSET FORM.end_date				= "">
			<CFSET FORM.Adv_Spending_Amount		= "">
			<CFSET FORM.Contract_Reference_Number	= "">
		</CFIF>

	
		<cfset Form.Responsible_User_Id_Position_Id = "#User_Position_ID#_#Program_Packet.Basic_Information.Responsible_User_Id#">		
		<CFSET FORM.Contract_Title				= Program_Packet.Basic_Information.Contract_Title>
		<CFSET FORM.Quantity					= Program_Packet.Basic_Information.Contract_Quantity>
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
		<CFOUTPUT>
		
		<cfset form.Start_Date 					= New_Pgm_Start_Date>
		<cfset form.End_Date 					= Program_Packet.Basic_Information.Contract_End_Date>
		<cfif AutoRenew.RecordCount>
			<cfset Form.Is_AutoRenew 				= Program_Packet.Basic_Information.Is_AutoRenew>
			<cfset form.Auto_Renew 					= 1>
			<cfset form.Renewal_Lead_Time 			= AutoRenew.Renewal_Lead_Time>
			<cfset form.AR_Renewal_Type 			= AutoRenew.AR_Renewal_Type>
		</cfif>
		<cfset form.Contract_Quantity_UOM_IDX 	= Contract_Quantity_UOM_IDX>
		<cfset form.Document_ID 				= "contract_create_1_form">
		<cfset form.Query_Type 					= "INSERT">
		<cfset form.CONTRACT_RENEWAL_PACKETS_ID = savePacket.Contract_Renewal_Packets_ID>
		<cfset form.Scheduled 					= 1>
		<cfset FORM.Document_ID 				= "contract_create_1_form">		
		<cfset FORM.ISRollOver 					= 0>
		#FORM.Contract_Number#<hr>
		<cfinclude template="/common_files/contracts/queries.cfm">
		</CFOUTPUT>
		
	<!------ Change the status to RFA ----->
	<cfset programObj.makeRFA(renewed_program_id, Program_Packet.Basic_Information.Responsible_User_ID) />	
	<cfset Contract_Main_ID = renewed_program_id>
	
	
	<cfset NumberUpdated = NumberUpdated + 1>
		

