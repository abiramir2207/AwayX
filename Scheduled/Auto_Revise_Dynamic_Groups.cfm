<!---Auto_Revise_Dynamic_groups.cfm--->
<cfset Scheduled = 1>
<cfset form.IsAutoRevision = 1 />

<cfquery name="qGetDynamicContracts" datasource="#application.datasource#">
	SELECT 	DISTINCT Contract_Main.Contract_Main_ID
	FROM 	Contract_Main
			INNER JOIN Program_Control_Panel_Options ON
			Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			AND Program_Control_Panel_Options.Deleted = 0
			AND Program_Control_Panel_Options.Dynamic_Static_Groups = 1
			INNER JOIN Contract_Products ON
			Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
			AND Contract_Products.Deleted = 0
			INNER JOIN Contract_Distributors ON
			Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
			AND Contract_Distributors.Deleted = 0
	WHERE	Contract_Main.Deleted = 0
	AND		Contract_Main.Contract_Status_Type_IDX IN (5,6)
	AND		(Contract_Products.Is_Group = 1 AND Contract_Products.Product_Group_ID IN (SELECT DISTINCT CAST(Product_Group_ID AS NVARCHAR(50)) FROM Group_Members WHERE Updated_Bit = 1))
			OR
			(Contract_Distributors.Is_Group = 1 AND Contract_Distributors.Distributor_Group_ID IN (SELECT DISTINCT CAST(Customer_Group_ID AS NVARCHAR(50)) FROM Customer_Group_Members WHERE Updated_Bit = 1))
</cfquery>

<cfloop query="qGetDynamicContracts">
	<!---sets all the stuff that contract revision needs--->
	<cf_cryp type="en" string="#qGetDynamicContracts.Contract_Main_ID#"  key="#request.key#">
	<cfset Form.Program_ID = cryp.value>
	<cfset Form.ISREVISIONOFEXISTINGCONTRACT = 1>
	
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
			WHERE 	Contract_Main_ID = '#Program_ID_To_Replicate#'
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
	<!--- 	<CFSET FORM.start_date				= Program_Packet.Basic_Information.Contract_Start_Date> --->
		<CFSET FORM.start_date				= Now()>
		<CFSET FORM.end_date				= Program_Packet.Basic_Information.Contract_End_Date>
		<CFSET FORM.Adv_Spending_Amount		= "">
	
		<cfset Form.Responsible_User_Id_Position_Id = "#User_Position_ID#_#Program_Packet.Basic_Information.Responsible_User_Id#">
		<CFSET FORM.Contract_Reference_Number	= Program_Packet.Basic_Information.Contract_Reference_Number>
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
		
		<cfinclude template="/common_files/contracts/queries.cfm">
		
		<!---call this stored procedure to adjust for product volume that have come and gone--->
		<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">

			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Renewed_Program_ID#" null="no">

		</cfstoredproc>
		
		<!---call SP to adjust for the dynamic changes--->
		<cfstoredproc procedure="SP_ADJUST_DYNAMIC_PROGRAM" datasource="#application.datasource#">

			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#Renewed_Program_ID#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@OLD_CONTRACT_MAIN_ID" value = "#Program_ID_To_Replicate#" null="no">

		</cfstoredproc>
		
		</CFOUTPUT>
		
</cfloop>

<!---after the process runs set the updated bit to low--->
<cfquery name="qUpdateProductMembers" datasource="#application.datasource#">
	UPDATE	Group_Members
	SET		Updated_Bit = 0		
	WHERE	Updated_Bit = 1
</cfquery>

<cfquery name="qUpdateCustomerMembers" datasource="#application.datasource#">
	UPDATE	Customer_Group_Members
	SET		Updated_Bit = 0
	WHERE	Updated_Bit = 1
</cfquery>