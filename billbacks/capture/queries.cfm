<CFPARAM name="FORM.Document_ID" default="">
<CFPARAM name="FORM.ClaimMechanics" default="0">
<CFPARAM name="FORM.BldUpInvoice" default="0">

<cfparam name="FORM.Dev_Fob" default="0">


<CFPARAM name="FORM.FIXED_REBATE_AMOUNT" default="0">
<CFPARAM name="FORM.Adv_Spend_Amount" default="">
<CFSET FORM.Adv_Spend_Amount = replace(FORM.Adv_Spend_Amount, ",", "", 'ALL')>

<!--- Claim Performance Requirments --->
<CFPARAM name="FORM.chkClaimPerfReq_1" 				default="0">
<CFPARAM name="FORM.chkClaimPerfReq_2" 				default="0">
<CFPARAM name="FORM.chkClaimPerfReq_3" 				default="0">
<CFPARAM name="FORM.chkClaimPerfReq_4" 				default="0">
<CFPARAM name="FORM.chkClaimPerfReq_5" 				default="0">
<CFPARAM name="FORM.chkClaimPerfReq_6" 				default="0">
<CFPARAM name="FORM.chkClaimPerfReq_7" 				default="0">
<CFPARAM name="FORM.chkClaimPerfReq_8" 				default="0">
<CFPARAM name="FORM.chkClaimPerfReq_9" 				default="0">

<!--- Communication Settings --->	
<CFPARAM name="FORM.CommRecip_1" 					default="0">
<CFPARAM name="FORM.CommRecip_2" 					default="0">
<CFPARAM name="FORM.CommRecip_3" 					default="0">
<CFPARAM name="FORM.CommRecip_4" 					default="0">	

<!--- Auto Renew Settings --->
<CFPARAM name="FORM.Auto_Renew" 						default="0">	
<CFPARAM name="FORM.Auto_Renewal_Fixed_Variable_Margin" default="0">
<!--- Claim Mechanics --->
<CFPARAM name="FORM.ClaimMechOption" 				default="0">	
<CFPARAM name="FORM.ClaimMechOptionsBUI" 			default="0">
<!--- Controllable Volume --->
<CFPARAM name="FORM.Controllable_Flag" 				default="0">
<!--- Growth Inclusion --->
<CFPARAM name="FORM.Growth_Inclusion_Flag" 			default="0">

<CFPARAM NAME="FORM.GL_Assignment_ID" DEFAULT="0">

<CFPARAM NAME="FORM.CONTRACT_RENEWAL_PACKETS_ID" DEFAULT="0">

<CFSET FORM.Quantity = replace(FORM.Quantity, ",", "", 'ALL')>


<cfset DayCount = datediff('d', start_date, end_date)>
<cfif DayCount EQ 0><cfset DayCount = 1></cfif>
<CFSET DailyContractQuantity = FORM.Quantity/DayCount>

<CFIF FORM.CONTRACT_RENEWAL_PACKETS_ID NEQ 0>
	<CFSET FORM.Document_ID = "">
</CFIF>

<CFSWITCH expression="#FORM.Document_ID#">
	<!---  --->
	<CFCASE value="contract_create_1_form">
		<CFSWITCH expression="#FORM.Query_Type#">

			<CFCASE value="INSERT">
				<cfset useLakebaseForgetThisUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetThisUserPosition>
	<cftry>
		<cfset getThisUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"user_position_type" = "eq.P",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetThisUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetThisUserPosition>
<CFQUERY NAME="getThisUserPosition" DATASOURCE="AwayX">
					SELECT User_Positions_ID
					FROM User_Position_Holders
					WHERE User_ID = '#request.AccessStructure.User_ID#' AND User_Position_Type = 'P' AND DELETED = 0
				</CFQUERY>
</cfif>
				<CFSET This_User_Position_ID = getThisUserPosition.User_Positions_ID>
		
				<CFQUERY NAME="insert" DATASOURCE="awayx">
					SET NOCOUNT ON
					INSERT INTO Contract_Main
					(
						Contract_Number,
						Contract_Reference_Number,
						Contract_Title,
						Contract_Start_Date,
						Contract_End_Date,
						Contract_Quantity,
						Contract_Quantity_UOM_IDX,
						<!--- Discount_Type_ID, ---><!---  may not need to be here anymore --->
						Dist_Brand_Eligibility,
						Deleted,
						contract_status_type_IDX,
						fixed_rebate_amount,
						Creator_ID,
						Editor_ID,
						Owner_Company_ID,
						Notes,
						PaymentCycle,
						ProgramType,
						ProgramType_ID,
						chkClaimPerfReq_1,
						chkClaimPerfReq_2,
						chkClaimPerfReq_3,
						chkClaimPerfReq_4,
						chkClaimPerfReq_5,
						chkClaimPerfReq_6,
						chkClaimPerfReq_7,
						chkClaimPerfReq_8,
						chkClaimPerfReq_9,
						CommRecip_1,
						CommRecip_2,
						CommRecip_3,
						CommRecip_4,
						Auto_Renew,
						Auto_Renewal_Fixed_Variable_Margin,
						ClaimMechanics,
						BldUpInvoice,
						Controllable_Volume,
						Growth_Inclusion,
						GL_Assignment,
						Contract_Daily_Volume,
						Adv_Spending_Amount,
						Creating_User_Position_ID,
						Contract_Is_Locked,
						Contract_Locked_By_User_ID				
					)
					VALUES
					(
						'#FORM.Contract_Number#',
						'#FORM.Contract_Reference_Number#',
						'#FORM.Contract_Title#',
						'#dateformat(FORM.start_date, 'm/d/yyyy')#',
						'#dateformat(FORM.end_date, 'm/d/yyyy')#',
						'#FORM.Quantity#',
						'#FORM.Contract_Quantity_UOM_IDX#' ,
						<!---<CFIF FORM.FRA_GNFP EQ 1>1<CFELSEIF FORM.FRA_GNFP EQ 5>5<CFELSE>'#FORM.DEV_FOB#'</CFIF>, --->
						'#FORM.Dist_Brand_Eligibility#',
						0,
						1,
						'#FORM.fixed_rebate_amount#',
						'#request.AccessStructure.User_ID#',
						'#request.AccessStructure.User_ID#',
						'#request.AccessStructure.Company_Main_ID#',
						'#FORM.Notes#',
						#FORM.PaymentCycle#,
						'#FORM.Created_Type#',
						'#Form.ProgramType_ID#',
						'#FORM.chkClaimPerfReq_1#',
						'#FORM.chkClaimPerfReq_2#',
						'#FORM.chkClaimPerfReq_3#',
						'#FORM.chkClaimPerfReq_4#',
						'#FORM.chkClaimPerfReq_5#',
						'#FORM.chkClaimPerfReq_6#',
						'#FORM.chkClaimPerfReq_7#',
						'#FORM.chkClaimPerfReq_8#',
						'#FORM.chkClaimPerfReq_9#',
						#FORM.CommRecip_1#,
						#FORM.CommRecip_2#,
						#FORM.CommRecip_3#,
						#FORM.CommRecip_4#,
						#FORM.Auto_Renew#,
						#FORM.Auto_Renewal_Fixed_Variable_Margin#,
						#FORM.ClaimMechOption#,
						#FORM.ClaimMechOptionsBUI#,
						#FORM.Controllable_Flag#,
						#FORM.Growth_Inclusion_Flag#,
						#FORM.GL_Assignment_ID#,
						'#DailyContractQuantity#',
						'#FORM.Adv_Spend_Amount#',
						'#This_User_Position_ID#',
						1,
						'#request.AccessStructure.User_ID#'
					)
					SELECT MAX(Contract_Main_ID) AS Contract_Main_ID FROM Contract_Main 
					--SELECT Contract_Main_ID = @@IDENTITY
					SET NOCOUNT OFF
				</CFQUERY>
				
				<!--- save comments --->
				<cfset useLakebaseForrecordCheck = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main_aux_data")>
<cfif useLakebaseForrecordCheck>
	<cftry>
		<cfset recordCheck = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main_aux_data", {
				"contract_main_id" = "eq.#insert.Contract_Main_ID#",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForrecordCheck = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForrecordCheck>
<cfquery name="recordCheck" datasource="#Application.Datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Main_Aux_Data
					WHERE Contract_Main_ID = '#insert.Contract_Main_ID#'
				</cfquery>
</cfif>
				<CFIF recordCheck.recordcount EQ 0>
					<cfquery name="insertRecord" datasource="#Application.Datasource#">
						INSERT INTO Contract_Main_Aux_Data
						(Contract_Main_ID)
						VALUES
						('#insert.Contract_Main_ID#')
					</cfquery>
				</CFIF>
				<cfquery name="saveAuxData" datasource="#Application.Datasource#">
					UPDATE Contract_Main_Aux_Data
					SET Comments = '#Form.Comments#'
					WHERE Contract_Main_ID = '#insert.Contract_Main_ID#'
				</cfquery>
				<!--- END comments --->
				
				<CF_CRYP type="en" string="#insert.Contract_Main_ID#" key="#request.key#">

				<CFSET redirector_Program_ID = Form.ProgramType_ID>
				<CFSET redirector_FromPage_ID = 1>
				<cfinclude template="internal_redirector_based_on_settings.cfm">

				<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&CID=#cryp.value#">
			</CFCASE>

			<CFCASE value="update">
				
				<CF_CRYP type="de" string="#FORM.CID#" key="#request.key#">
				
				<!--- lock checker --->
				<CFSET LockChecker_CID  = cryp.value>
				<CFINCLUDE TEMPLATE="LockChecker.cfm">
				<!--- lock checker --->

				
				<cfquery name="UPDATETHETABLE" datasource="awayx">
					UPDATE contract_main
					SET 
							Contract_Reference_Number	=	'#FORM.Contract_Reference_Number#',
							Contract_Title			 	=	'#FORM.Contract_Title#',
							Contract_Start_Date			=	'#FORM.start_date#',
							Contract_End_Date			=	'#FORM.end_date#',
							Contract_Quantity			=	'#FORM.quantity#',
							Contract_Daily_Volume		=	'#DailyContractQuantity#',
							Contract_Quantity_UOM_IDX	=	'#FORM.Contract_Quantity_UOM_IDX#',
							Fixed_Rebate_Amount			=	'#FORM.Fixed_Rebate_Amount#',
<!---						Discount_Type_ID			=	<CFIF FORM.FRA_GNFP EQ 1>1<CFELSEIF FORM.FRA_GNFP EQ 5>5<CFELSE>#FORM.DEV_FOB#</CFIF>, --->
							Dist_Brand_Eligibility		=	'#Form.Dist_Brand_Eligibility#',
							Notes						=	'#Form.Notes#',
							Editor_ID 					=	'#request.AccessStructure.User_ID#',
							PaymentCycle				= 	#FORM.PaymentCycle#,
							ProgramType					= 	'#FORM.Created_Type#',
							ProgramType_ID				=	'#FORM.ProgramType_ID#',
							chkClaimPerfReq_1			=	'#FORM.chkClaimPerfReq_1#',
							chkClaimPerfReq_2			=	'#FORM.chkClaimPerfReq_2#',
							chkClaimPerfReq_3			=	'#FORM.chkClaimPerfReq_3#',
							chkClaimPerfReq_4			=	'#FORM.chkClaimPerfReq_4#',
							chkClaimPerfReq_5			=	'#FORM.chkClaimPerfReq_5#',
							chkClaimPerfReq_6			=	'#FORM.chkClaimPerfReq_6#',
							chkClaimPerfReq_7			=	'#FORM.chkClaimPerfReq_7#',
							chkClaimPerfReq_8			=	'#FORM.chkClaimPerfReq_8#',
							chkClaimPerfReq_9			=	'#FORM.chkClaimPerfReq_9#',
							CommRecip_1					=	'#FORM.CommRecip_1#',
							CommRecip_2					=	'#FORM.CommRecip_2#',
							CommRecip_3					=	'#FORM.CommRecip_3#',
							CommRecip_4					=	'#FORM.CommRecip_4#',
							Auto_Renew					=	'#FORM.Auto_Renew#',
							Auto_Renewal_Fixed_Variable_Margin	=	#FORM.Auto_Renewal_Fixed_Variable_Margin#,
							ClaimMechanics				=	'#FORM.ClaimMechOption#',
							BldUpInvoice				=	'#FORM.ClaimMechOptionsBUI#',
							Controllable_Volume			=	'#FORM.Controllable_Flag#',
							Growth_Inclusion			=	'#FORM.Growth_Inclusion_Flag#',
							GL_Assignment				=	#FORM.GL_Assignment_ID#,
							Adv_Spending_Amount			=	'#FORM.Adv_Spend_Amount#'
					WHERE
							Contract_Main_ID			=	'#cryp.value#'
				</cfquery>

				<!--- save comments --->
				<cfquery name="recordCheck" datasource="#Application.Datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Main_Aux_Data
					WHERE Contract_Main_ID = '#cryp.value#'
				</cfquery>
				<CFIF recordCheck.recordcount EQ 0>
					<cfquery name="insertRecord" datasource="#Application.Datasource#">
						INSERT INTO Contract_Main_Aux_Data
						(Contract_Main_ID)
						VALUES
						('#cryp.value#')
					</cfquery>
				</CFIF>
				<cfquery name="saveAuxData" datasource="#Application.Datasource#">
					UPDATE Contract_Main_Aux_Data
					SET Comments = '#Form.Comments#'
					WHERE Contract_Main_ID = '#cryp.value#'
				</cfquery>
				<!--- END comments --->
					
					<CFLOCATION url="redirect.cfm?destination=contract_edit_menu.cfm&CID=#FORM.CID#">
			</CFCASE>
		</CFSWITCH>
	</CFCASE>

	
	<!---  --->
	<CFCASE value="SELECT_PRODUCTS">
		<CFSWITCH expression="#FORM.Query_Type#">
			<CFCASE value="INSERT">
				<CFQUERY NAME="insert" DATASOURCE="awayx">
					SET NOCOUNT ON
					INSERT INTO Contract_Main
					(
						Contract_Number,
						Contract_Reference_Number,
						Contract_Title,
						Contract_Start_Date,
						Contract_End_Date,
						Contract_Quantity,
						Contract_Quantity_UOM_IDX,
						Discount_Type_ID,
						Dist_Brand_Eligibility,
						Deleted,
						contract_status_type_IDX,
						fixed_rebate_amount,
						Author_ID,
						Owner_Company_ID
					)
					VALUES
					(
						'#FORM.Contract_Number#',
						'#FORM.Contract_Reference_Number#',
						'#FORM.Contract_Title#',
						'#FORM.start_date#',
						'#FORM.end_date#',
						'#FORM.Quantity#',
						'#FORM.Contract_Quantity_UOM_IDX#',
						<CFIF FORM.FRA_GNFP EQ 1>1<CFELSE>'#FORM.DEV_FOB#'</CFIF>,
						'#FORM.Dist_Brand_Eligibility#',
						0,
						1,
						'#FORM.fixed_rebate_amount#',
						'#request.AccessStructure.User_ID#',
						'#request.AccessStructure.Company_Main_ID#'
					)
					SELECT Contract_Main_ID = @@IDENTITY
					SET NOCOUNT OFF
				</CFQUERY>
				
				<CFSET redirector_Program_ID = Form.ProgramType_ID>
				<CFSET redirector_FromPage_ID = 5>
				<cfinclude template="internal_redirector_based_on_settings.cfm">

				<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&ID=#insert.Contract_Main_ID#">
				
				<!--- <CFLOCATION url="redirect.cfm?destination=select_Products.cfm&ID=#insert.Contract_Main_ID#"> --->

			</CFCASE>

			<CFCASE value="update">
				<cfquery name="UPDATE" datasource="awayx">
					UPDATE Contract_Main
					SET 
							Contract_Reference_Number	=	'#FORM.Contract_Reference_Number#',
							Contract_Title			 	=	'#FORM.Contract_Title#',
							Contract_Start_Date			=	'#FORM.start_date#',
							Contract_End_Date			=	'#FORM.end_date#',
							Contract_Quantity			=	'#FORM.quantity#',
							Contract_Quantity_UOM_IDX	=	'#FORM.Contract_Quantity_UOM_IDX#',
							Fixed_Rebate_Amount			=	'#FORM.Fixed_Rebate_Amount#',
							Discount_Type_ID			=	'<CFIF FORM.FRA_GNFP EQ 1>1<CFELSE>#FORM.DEV_FOB#</CFIF>',
							Dist_Brand_Eligibility		=	'#Form.Dist_Brand_Eligibility#'
					WHERE
							Contract_Main_ID			=	'#FORM.Contract_Main_ID#'
				</cfquery>
				
				<CFSET redirector_Program_ID = Form.ProgramType_ID>
				<CFSET redirector_FromPage_ID = 5>
				<cfinclude template="internal_redirector_based_on_settings.cfm">

				<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&ID=#insert.Contract_Main_ID#">
				<!--- <CFLOCATION url="redirect.cfm?destination=select_Products.cfm&ID=#FORM.Contract_Main_ID#"> --->

			</CFCASE>
		</CFSWITCH>
	</CFCASE>
<CFDEFAULTCASE>
	
</CFDEFAULTCASE>
</CFSWITCH>

<!--- Process data from the packet --->
<CFIF FORM.CONTRACT_RENEWAL_PACKETS_ID NEQ 0>
	<cfset useLakebaseForgetPacket = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_renewal_packets")>
<cfif useLakebaseForgetPacket>
	<cftry>
		<cfset getPacket = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_renewal_packets", {
				"contract_renewal_packets_id" = "eq.#FORM.CONTRACT_RENEWAL_PACKETS_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPacket = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPacket>
<CFQUERY NAME="getPacket" DATASOURCE="AwayX" MAXROWS="1">
		SELECT *
		FROM Contract_Renewal_Packets
		WHERE Contract_Renewal_Packets_ID = '#FORM.CONTRACT_RENEWAL_PACKETS_ID#'
	</CFQUERY>
</cfif>	
	
	<CFFILE ACTION="READ" FILE="#getPacket.XML_File_Location#" VARIABLE="Packet_Data">
	<CFWDDX ACTION="WDDX2CFML" INPUT="#Packet_Data#" OUTPUT="Program_Packet">

	<!--- <CFWDDX ACTION="WDDX2CFML" INPUT="#getPacket.Packet_Data#" OUTPUT="Program_Packet"> --->

				<!--- SAVE Basic information Data From BI Page --->
				<CFQUERY NAME="getThisUserPosition" DATASOURCE="AwayX">
					SELECT User_Positions_ID
					FROM User_Position_Holders
					WHERE User_ID = '#request.AccessStructure.User_ID#' AND User_Position_Type = 'P' AND DELETED = 0
				</CFQUERY>
				<CFSET This_User_Position_ID = getThisUserPosition.User_Positions_ID>
				<CFSET FORM.Renewal_Of_Contract_Main_ID = Program_Packet.Basic_Information.CONTRACT_MAIN_ID>
				
				
				<!---  contract is a revision so do some required work --->
				<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>
					<CFSET FORM.Contract_Title = FORM.Contract_Title>
					
					<CFif  trim(Program_Packet.Basic_Information.Parent_Revised_Contract_Main_ID) EQ "NULL">
						<CFSET FORM.Parent_Revised_Contract_Main_ID = Program_Packet.Basic_Information.Contract_Main_ID>
					<CFELSE>
						<CFSET FORM.Parent_Revised_Contract_Main_ID = Program_Packet.Basic_Information.Parent_Revised_Contract_Main_ID>						
					</CFIF>
					
					<CFSET FORM.Revision_of_Contract_Main_ID = Program_Packet.Basic_Information.Contract_Main_ID>
				
				<CFELSE>
					<CFSET FORM.Contract_Title = FORM.Contract_Title>
				</CFIF>
				
				<CFQUERY NAME="insert" DATASOURCE="awayx">
					SET NOCOUNT ON
					INSERT INTO Contract_Main
					(
						Contract_Number,
						Contract_Reference_Number,
						Contract_Title,
						Contract_Start_Date,
						Contract_End_Date,
						Contract_Quantity,
						Contract_Quantity_UOM_IDX,
						<!--- Discount_Type_ID, ---><!---  may not need to be here anymore --->
						Dist_Brand_Eligibility,
						Deleted,
						contract_status_type_IDX,
						fixed_rebate_amount,
						Creator_ID,
						Editor_ID,
						Owner_Company_ID,
						Notes,
						PaymentCycle,
						ProgramType,
						ProgramType_ID,
						chkClaimPerfReq_1,
						chkClaimPerfReq_2,
						chkClaimPerfReq_3,
						chkClaimPerfReq_4,
						chkClaimPerfReq_5,
						chkClaimPerfReq_6,
						chkClaimPerfReq_7,
						chkClaimPerfReq_8,
						chkClaimPerfReq_9,
						CommRecip_1,
						CommRecip_2,
						CommRecip_3,
						CommRecip_4,
						Auto_Renew,
						Auto_Renewal_Fixed_Variable_Margin,
						ClaimMechanics,
						BldUpInvoice,
						Controllable_Volume,
						Growth_Inclusion,
						GL_Assignment,
						Contract_Daily_Volume,
						Adv_Spending_Amount,
						Creating_User_Position_ID,
						Pay_Brokerage,
						On_Release_Contract_Status_Type_IDX,
						<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 0>
						Renewal_Of_Contract_Main_ID
						<CFELSE>
						Parent_Revised_Contract_Main_ID,
						Revision_of_Contract_Main_ID,
						Is_A_Revision
						</CFIF>
						
					)
					VALUES
					(
						'#FORM.Contract_Number#',
						'#FORM.Contract_Reference_Number#',
						'#FORM.Contract_Title#',
						'#dateformat(FORM.start_date, 'm/d/yyyy')#',
						'#dateformat(FORM.end_date, 'm/d/yyyy')#',
						'#FORM.Quantity#',
						'#FORM.Contract_Quantity_UOM_IDX#' ,
						<!---<CFIF FORM.FRA_GNFP EQ 1>1<CFELSEIF FORM.FRA_GNFP EQ 5>5<CFELSE>'#FORM.DEV_FOB#'</CFIF>, --->
						'#FORM.Dist_Brand_Eligibility#',
						0,
						1,
						'#FORM.fixed_rebate_amount#',
						'#request.AccessStructure.User_ID#',
						'#request.AccessStructure.User_ID#',
						'#request.AccessStructure.Company_Main_ID#',
						'#FORM.Notes#',
						#FORM.PaymentCycle#,
						'#FORM.Created_Type#',
						'#Form.ProgramType_ID#',
						'#FORM.chkClaimPerfReq_1#',
						'#FORM.chkClaimPerfReq_2#',
						'#FORM.chkClaimPerfReq_3#',
						'#FORM.chkClaimPerfReq_4#',
						'#FORM.chkClaimPerfReq_5#',
						'#FORM.chkClaimPerfReq_6#',
						'#FORM.chkClaimPerfReq_7#',
						'#FORM.chkClaimPerfReq_8#',
						'#FORM.chkClaimPerfReq_9#',
						#FORM.CommRecip_1#,
						#FORM.CommRecip_2#,
						#FORM.CommRecip_3#,
						#FORM.CommRecip_4#,
						#FORM.Auto_Renew#,
						#FORM.Auto_Renewal_Fixed_Variable_Margin#,
						#FORM.ClaimMechOption#,
						#FORM.ClaimMechOptionsBUI#,
						#FORM.Controllable_Flag#,
						#FORM.Growth_Inclusion_Flag#,
						#FORM.GL_Assignment_ID#,
						'#DailyContractQuantity#',
						'#FORM.Adv_Spend_Amount#',
						'#This_User_Position_ID#',
						'#Program_Packet.Basic_Information.Pay_Brokerage#',
						#FORM.On_Release_Contract_Status_Type_IDX#,
						<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 0>
						'#FORM.Renewal_Of_Contract_Main_ID#'
						<CFELSE>
						'#FORM.Parent_Revised_Contract_Main_ID#',
						'#FORM.Revision_of_Contract_Main_ID#',
						#FORM.ISREVISIONOFEXISTINGCONTRACT#
						</CFIF>
					
					)
					SELECT MAX(Contract_Main_ID) AS Contract_Main_ID FROM Contract_Main 
					--SELECT Contract_Main_ID = @@IDENTITY
					SET NOCOUNT OFF
				</CFQUERY>

				<!--- save comments --->
				<cfquery name="recordCheck" datasource="#Application.Datasource#">
					SELECT Contract_Main_ID
					FROM Contract_Main_Aux_Data
					WHERE Contract_Main_ID = '#insert.Contract_Main_ID#'
				</cfquery>
				<CFIF recordCheck.recordcount EQ 0>
					<cfquery name="insertRecord" datasource="#Application.Datasource#">
						INSERT INTO Contract_Main_Aux_Data
						(Contract_Main_ID)
						VALUES
						('#insert.Contract_Main_ID#')
					</cfquery>
				</CFIF>
				<cfquery name="saveAuxData" datasource="#Application.Datasource#">
					UPDATE Contract_Main_Aux_Data
					SET Comments = '#Form.Comments#'
					WHERE Contract_Main_ID = '#insert.Contract_Main_ID#'
				</cfquery>
				<!--- END comments --->
				
				<CFSET Renewed_Program_ID = insert.Contract_Main_ID>
				
				<!--- save operators --->
				<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,CONTRACT_OPERATORS_ID,DELETED">
				<CFSET ThisStructureLevel = Program_Packet.Operators>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>

								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
																
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>

						<!--- save data query --->
						<CFQUERY NAME="saveOperator" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Contract_Main_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->				

 				<!--- save brokers --->
				<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,CONTRACT_BROKERS_ID,DELETED">
				<CFSET ThisStructureLevel = Program_Packet.Brokers>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>

						<!--- save data query --->
						<CFQUERY NAME="saveBroker" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Contract_Main_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->		 

 				<!--- save DISTRIBUTORS --->
				<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,CONTRACT_DISTRIBUTORS_ID,DELETED">
				<CFSET ThisStructureLevel = Program_Packet.Distributors>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>

						<!--- save data query --->
						<CFQUERY NAME="saveDISTRIBUTORS" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Contract_Main_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->

 				<!--- initialize product id mapping array --->
				<CFSET Contract_Products_ID_Mapping = ArrayNew(2)>
				<CFSET Contract_Products_ID_TO_Lump_Sum_Component_ID_Mapping = ArrayNew(2)>
				<!--- END initialize product id mapping array --->
				
				<!--- Save products --->
				<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,CONTRACT_PRODUCTS_ID,DELETED,CREATOR_ID,DATE_CREATED,DISCOUNT_VALUE,EDITOR_ID,PRICING_RULE,PRODUCT_UPC">
				<CFSET ThisStructureLevel = Program_Packet.Products>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
						<!--- save data query --->
						<CFQUERY NAME="saveProduct" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Contract_Main_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
						
						<!--- map old contract product_id to new one --->
						<CFSET Contract_Products_ID_Mapping[ArrayLen(Contract_Products_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
						<CFSET Contract_Products_ID_Mapping[ArrayLen(Contract_Products_ID_Mapping)][2] = saveProduct.Contract_Products_ID>
						<!--- end map old contract product_id to new one --->
					</CFLOOP>	
				</CFIF>
				<!--- END save --->
				
 				<!--- save Fixed Price Products --->
				<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,DELETED,CONTRACT_PRODUCTS_ID,PROGRAM_FIXED_PRICE_PRODUCT_DATA_ID,PROGRAM_ID">
				<CFSET ThisStructureLevel = Program_Packet.Products.FIXED_PRICE_PRODUCTS>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
						<!--- Find Mapped Contract_Product_ID --->
						<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
						<CFSET Mapped_product_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
							<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- save data query --->
						<CFQUERY NAME="saveFixedPriceProducts" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,Contract_Products_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#, #Mapped_product_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->

 				<!--- save Rebate Products --->
				<CFSET ListOfColumsToIgnore="PROGRAM_ID,CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_REBATES_PRODUCT_DATA_ID">
				<CFSET ThisStructureLevel = Program_Packet.Products.REBATE_PRODUCTS>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
						<!--- Find Mapped Contract_Product_ID --->
						<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
						<CFSET Mapped_product_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
							<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- save data query --->
						<CFQUERY NAME="saveREBATEPriceProducts" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,Contract_Products_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#, #Mapped_product_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->								

				<!--- intialize component mapping array --->
				<CFSET Lump_Sum_Component_ID_Mapping = ArrayNew(2)>
				<!--- end intialize component mapping array --->			

 				<!--- save lump sums --->
				<CFSET ListOfColumsToIgnore="PROGRAM_ID,DELETED,PROGRAM_LUMP_SUM_ID">
				<CFSET ThisStructureLevel = Program_Packet.LUMP_SUM_COMPONENTS>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						<!--- save data query --->
						<CFQUERY NAME="saveLumpSumComponents" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							--(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>

						<!--- map old lump sum component id to new one --->
						<CFSET Lump_Sum_Component_ID_Mapping[ArrayLen(Lump_Sum_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_LUMP_SUM_ID_#LoopCount#")>
						<CFSET Lump_Sum_Component_ID_Mapping[ArrayLen(Lump_Sum_Component_ID_Mapping)][2] = saveLumpSumComponents.Program_Lump_Sum_ID>
						<!--- end map old lump sum component id to new one --->
					</CFLOOP>	
				</CFIF>
				<!--- END save --->

 				<!--- save lump products Products --->
				<CFSET ListOfColumsToIgnore="CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_LUMP_SUM_PRODUCT_DATA_ID,PROGRAM_LUMP_SUM_ID">
				<CFSET ThisStructureLevel = Program_Packet.LUMP_SUM_COMPONENTS.PRODUCTS>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
						<!--- Find Mapped Contract_Product_ID --->
						<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
						<CFSET Mapped_product_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
							<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
								<CFBREAK>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- Find Mapped Component --->
						<CFSET Old_Lump_Sum_ID = evaluate("ThisStructureLevel.PROGRAM_LUMP_SUM_ID_#LoopCount#")>
						<CFSET Mapped_Lump_Sum_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Lump_Sum_Component_ID_Mapping)#" STEP="1">
							<CFIF Old_Lump_Sum_ID EQ Lump_Sum_Component_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_Lump_Sum_ID = Lump_Sum_Component_ID_Mapping[ArrayPositionCount][2]>
								<CFBREAK>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- save data query --->
						<CFQUERY NAME="saveLumpSumProducts" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(Contract_Products_ID,PROGRAM_LUMP_SUM_ID)
							VALUES
							(#Mapped_product_ID#,'#Mapped_Lump_Sum_ID#')
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->						
				
				<!--- intialize Growth component mapping array --->
				<CFSET Growth_Component_ID_Mapping = ArrayNew(2)>
				<!--- end intialize Growth component mapping array --->	
				 				
				<!--- save Growth Component --->
				<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_GROWTH_COMPONENT_ID,PROGRAM_ID">
				<CFSET ThisStructureLevel = Program_Packet.GROWTH_COMPONENTS>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>

						<!--- save data query --->
						<CFQUERY NAME="saveGrowthComponent" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
						
						<!--- map old lump sum component id to new one --->
						<CFSET Growth_Component_ID_Mapping[ArrayLen(Growth_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_ID_#LoopCount#")>
						<CFSET Growth_Component_ID_Mapping[ArrayLen(Growth_Component_ID_Mapping)][2] = saveGrowthComponent.A_ID>
						<!--- end map old lump sum component id to new one --->						
					</CFLOOP>	
				</CFIF>
				<!--- END save --->
				
				<!--- intialize Growth component Tier mapping array --->
				<CFSET Growth_Component_Tier_ID_Mapping = ArrayNew(2)>
				<!--- end intialize Growth component Tier mapping array --->	
				
 				<!--- save Growth Component Tiers --->
				<CFSET ListOfColumsToIgnore="PROGRAM_GROWTH_COMPONENT_ID,PROGRAM_GROWTH_COMPONENT_TIER_ID,PROGRAM_ID,DELETED">
				<CFSET ThisStructureLevel = Program_Packet.GROWTH_COMPONENTS.TIERS>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
						<!--- Find Growth Component ID --->
						<CFSET Old_Growth_Component_ID = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_ID_#LoopCount#")>
						<CFSET Mapped_Growth_Component_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Growth_Component_ID_Mapping)#" STEP="1">
							<CFIF Old_Growth_Component_ID EQ Growth_Component_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_Growth_Component_ID = Growth_Component_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- save data query --->
						<CFQUERY NAME="saveGrowthComponentTiers" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,PROGRAM_GROWTH_COMPONENT_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#, '#Mapped_Growth_Component_ID#')
						</CFQUERY>
						<!--- map old lump sum component Tier id to new one --->
						<CFSET Growth_Component_Tier_ID_Mapping[ArrayLen(Growth_Component_Tier_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_TIER_ID_#LoopCount#")>
						<CFSET Growth_Component_Tier_ID_Mapping[ArrayLen(Growth_Component_Tier_ID_Mapping)][2] = saveGrowthComponentTiers.INS_Program_Growth_Component_Tier_ID>
						<!--- end map old lump sum component Tier id to new one --->	
					</CFLOOP>	
				</CFIF>
				<!--- END save --->

				<!--- init PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID mapping array ---> 				
				<CFSET PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping = ArrayNew(2)>
				<!--- end init PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID mapping array ---> 				
				
				<!--- save Growth Component Tier Products --->
				<CFSET ListOfColumsToIgnore="CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_GROWTH_COMPONENT_ID,PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID">
				<CFSET ThisStructureLevel = Program_Packet.GROWTH_COMPONENTS.TIERS.TIER_PRODUCTS>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
						<!--- Find Mapped Contract_Product_ID --->
						<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
						<CFSET Mapped_product_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
							<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
								<CFBREAK>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- Find Growth Component ID --->
						<CFSET Old_Growth_Component_ID = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_ID_#LoopCount#")>
						<CFSET Mapped_Growth_Component_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Growth_Component_ID_Mapping)#" STEP="1">
							<CFIF Old_Growth_Component_ID EQ Growth_Component_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_Growth_Component_ID = Growth_Component_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						<!--- END Growth Component ID --->

						<!--- save data query --->
						<CFQUERY NAME="saveGrowthComponentProducts" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,CONTRACT_PRODUCTS_ID,PROGRAM_GROWTH_COMPONENT_ID)
							VALUES
							(#DataValueList#,'#Mapped_product_ID#','#Mapped_Growth_Component_ID#')
						</CFQUERY>
						<!--- save product mapping --->
						<CFSET PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping[ArrayLen(PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_#LoopCount#")>
						<CFSET PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping[ArrayLen(PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping)][2] = saveGrowthComponentProducts.Program_Growth_Component_Product_Data_ID>
						<!--- end save product mapping --->
					</CFLOOP>	
				</CFIF>
				<!--- END save --->		

 				<!--- save product_tier rates data --->
				<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID,PROGRAM_GROWTH_COMPONENT_PRODUCT_TIER_DATA_ID,PROGRAM_GROWTH_COMPONENT_TIER_ID">
				<CFSET ThisStructureLevel = Program_Packet.GROWTH_COMPONENTS.TIERS.TIER_PRODUCTS.PRODUCT_TIER_DATA>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
						<!--- FIND PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID --->
						<CFSET OLD_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_#LoopCount#")>
						<CFSET Mapped_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping)#" STEP="1">
							<CFIF OLD_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID EQ PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID = PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						<!--- FIND PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID --->

						<!--- FIND PROGRAM_GROWTH_COMPONENT_PRODUCT_TIER_DATA_ID --->
						<CFSET OLD_Growth_Component_Tier_ID_Mapping  = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_TIER_ID_#LoopCount#")>
						<CFSET Mapped_Growth_Component_Tier_ID_Mapping = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Growth_Component_Tier_ID_Mapping)#" STEP="1">
							<CFIF OLD_Growth_Component_Tier_ID_Mapping EQ Growth_Component_Tier_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_Growth_Component_Tier_ID_Mapping = Growth_Component_Tier_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						<!--- FIND PROGRAM_GROWTH_COMPONENT_PRODUCT_TIER_DATA_ID --->						

						<!--- save data query --->
						<CFQUERY NAME="saveproduct_tier_data" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID,PROGRAM_GROWTH_COMPONENT_TIER_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,'#Mapped_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID#','#Mapped_Growth_Component_Tier_ID_Mapping#')
						</CFQUERY>
					</CFLOOP>
				</CFIF>
				<!--- END save --->
				
				<!--- save pricing formula periods --->
				<CFSET ListOfColumsToIgnore="PROGRAM_FORMULA_PRICING_PERIOD_ID,PROGRAM_ID">
				<CFSET ThisStructureLevel = Program_Packet.FORMULA_PRICING.PERIODS>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>

						<!--- save data query --->
						<CFQUERY NAME="savePricingPeriods" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->

				<!--- intialize formula pricing rule ID mapping array --->
				<CFSET Program_Formula_Pricing_Rule_ID_Mapping = ArrayNew(2)>
				<!--- end intialize formula pricing rule ID mapping array --->	
				
				<!--- save pricing formula rules --->
				<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_FORMULA_PRICING_RULE_ID,PROGRAM_ID">
				<CFSET ThisStructureLevel = Program_Packet.FORMULA_PRICING.RULES>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>

						<!--- save data query --->
						<CFQUERY NAME="savePricingRules" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>

						<!--- map old rule id to new one --->
						<CFSET Program_Formula_Pricing_Rule_ID_Mapping[ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.Program_Formula_Pricing_Rule_ID_#LoopCount#")>
						<CFSET Program_Formula_Pricing_Rule_ID_Mapping[ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)][2] = savePricingRules.Program_Formula_Pricing_Rule_ID>
						<!--- end map old rule id to new one --->	

						
					</CFLOOP>	
				</CFIF>
				<!--- END save --->			

				<!--- save pricing formula rules --->
				<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_FORMULA_PRICING_RULE_ID,PROGRAM_FORMULA_PRICING_RULE_COMM_DATA_ID,PROGRAM_ID">
				<CFSET ThisStructureLevel = Program_Packet.FORMULA_PRICING.COMMODITY_DATA>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
						<!--- FIND Rule ID --->
						<CFSET OLD_PROGRAM_FORMULA_PRICING_RULE_ID = evaluate("ThisStructureLevel.PROGRAM_FORMULA_PRICING_RULE_ID_#LoopCount#")>
						<CFSET Mapped_PROGRAM_FORMULA_PRICING_RULE_ID = "">
						
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)#" STEP="1">
							<CFIF OLD_PROGRAM_FORMULA_PRICING_RULE_ID EQ Program_Formula_Pricing_Rule_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_PROGRAM_FORMULA_PRICING_RULE_ID = Program_Formula_Pricing_Rule_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						
 						<!--- save data query --->
						<CFQUERY NAME="savePricingRuleCommData" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,PROGRAM_FORMULA_PRICING_RULE_ID,Program_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,'#Mapped_PROGRAM_FORMULA_PRICING_RULE_ID#',#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->	
				
				<!--- save pricing formula OVERAGE --->
				<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_FORMULA_PRICING_RULE_ID,PROGRAM_FORMULA_PRICING_RULE_OVERAGE_ID,PROGRAM_ID">
				<CFSET ThisStructureLevel = Program_Packet.FORMULA_PRICING.OVERAGE>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
						<!--- FIND Rule ID --->
						<CFSET OLD_PROGRAM_FORMULA_PRICING_RULE_ID = evaluate("ThisStructureLevel.PROGRAM_FORMULA_PRICING_RULE_ID_#LoopCount#")>
						<CFSET Mapped_PROGRAM_FORMULA_PRICING_RULE_ID = "">
						
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)#" STEP="1">
							<CFIF OLD_PROGRAM_FORMULA_PRICING_RULE_ID EQ Program_Formula_Pricing_Rule_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_PROGRAM_FORMULA_PRICING_RULE_ID = Program_Formula_Pricing_Rule_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						
 						<!--- save data query --->
						<CFQUERY NAME="savePricingRuleOverage" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,PROGRAM_FORMULA_PRICING_RULE_ID,Program_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,'#Mapped_PROGRAM_FORMULA_PRICING_RULE_ID#',#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->
				
 				<!--- save Formula Pricing Products --->
				<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_ID,CONTRACT_PRODUCT_ID,PROGRAM_FORMULA_PRICING_RULE_ID,PROGRAM_FORMULA_PRICING_RULE_PRODUCT_ID">
				<CFSET ThisStructureLevel = Program_Packet.FORMULA_PRICING.PRODUCTS>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
					
						<!--- FIND Rule ID --->
						<CFSET OLD_PROGRAM_FORMULA_PRICING_RULE_ID = evaluate("ThisStructureLevel.PROGRAM_FORMULA_PRICING_RULE_ID_#LoopCount#")>
						<CFSET Mapped_PROGRAM_FORMULA_PRICING_RULE_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)#" STEP="1">
							<CFIF OLD_PROGRAM_FORMULA_PRICING_RULE_ID EQ Program_Formula_Pricing_Rule_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_PROGRAM_FORMULA_PRICING_RULE_ID = Program_Formula_Pricing_Rule_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>						

						<!--- Find Mapped Contract_Product_ID --->
						<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Product_ID_#LoopCount#")>
						<CFSET Mapped_product_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
							<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- save data query --->
						<CFQUERY NAME="saveFormulaPricingProducts" DATASOURCE="AwayX">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,Contract_Product_ID,PROGRAM_FORMULA_PRICING_RULE_ID)
							VALUES
							(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#,#Mapped_product_ID#,'#Mapped_PROGRAM_FORMULA_PRICING_RULE_ID#')
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->		
				<CF_Cryp type="en" key="#request.key#" string = "#Renewed_Program_ID#">
				<CFLOCATION URL="contract_edit_menu.cfm?CID=#cryp.value#">
</CFIF>



