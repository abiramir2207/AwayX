	<cfparam name="form.ProgramPacketSupplied" default="0">
	<cfparam name="SUPPLIEDPROGRAMPACKET" default="0">
	
<cfif form.ProgramPacketSupplied EQ 0>
	<CFQUERY NAME="getPacket" datasource="#application.datasource#" MAXROWS="1">
		SELECT *
		FROM Contract_Renewal_Packets
		WHERE Contract_Renewal_Packets_ID = '#FORM.CONTRACT_RENEWAL_PACKETS_ID#'
	</CFQUERY>	
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

	<CFFILE ACTION="READ" FILE="#getPacket.XML_File_Location#" VARIABLE="Packet_Data">
	<CFWDDX ACTION="WDDX2CFML" INPUT="#Packet_Data#" OUTPUT="Program_Packet">
<cfelse>
	<CFSET Program_Packet = Duplicate(SUPPLIEDPROGRAMPACKET)>
</cfif>	

				<!--- SAVE Basic information Data From BI Page --->
				<CFQUERY NAME="getThisUserPosition" datasource="#application.datasource#">
					SELECT User_Positions_ID
					FROM User_Position_Holders
					WHERE User_ID = '#Program_Packet.Basic_Information.Creator_ID#'
					AND User_Position_Type = 'P' AND DELETED = 0
				</CFQUERY>
				<CFSET This_User_Position_ID = getThisUserPosition.User_Positions_ID>
				<CFIF ucase(Program_Packet.Basic_Information.Contract_Reference_Number) EQ "NULL">
					<CFSET Program_Packet.Basic_Information.Contract_Reference_Number = "">
				</CFIF>
				<CFQUERY NAME="insert" datasource="#application.datasource#">
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
						Dist_Brand_Eligibility,
						Deleted,
						contract_status_type_IDX,
						fixed_rebate_amount,
						Creator_ID,
						Editor_ID,
						--Owner_Company_ID,
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
						Parent_Revised_Contract_Main_ID,
						Revision_of_Contract_Main_ID,
						Approved,
						Approval_Date,
						Approved_By_User_ID,
						Broker_Approved,
						Broker_Approved_Date,
						Broker_User_ID,
						Is_A_revision,
						IsExclusionRevision,
						Is_Manual_Revision,
						On_Release_Contract_Status_Type_IDX,
						Contract_Is_Locked,
						Contract_Locked_By_User_ID,
						Contract_Lock_Date,
						Responsible_User_ID,
						Formula_Price_Rebate_Type,
						Business_Segment_ID,
						Owner_Company_ID,
						Currency,
						Pullback_From_This_Program
						<!--- removed D13333
						<!--- Dev Note: CPM Budgets --->
						<cfif appSettings.getBudgetsOn() 
							  AND appSettings.getSelectBudgetsOn() EQ 1 
							  AND appSettings.getBudgetRelationshipToPrograms() EQ 1>
						,Budget_Reference_ID
						</cfif>
						--->
					)
					VALUES
					(
						'#Program_Packet.Basic_Information.Contract_Number#',
						'#Program_Packet.Basic_Information.Contract_Reference_Number#',
						'#Program_Packet.Basic_Information.Contract_Title#',
						'#Dateformat(Program_Packet.Basic_Information.CONTRACT_START_DATE,'m/d/yyy')#',
						'#Dateformat(Program_Packet.Basic_Information.CONTRACT_END_DATE,'m/d/yyy')#',
						'#Program_Packet.Basic_Information.CONTRACT_QUANTITY#',
						'#Program_Packet.Basic_Information.Contract_Quantity_UOM_IDX#' ,
						'#Program_Packet.Basic_Information.Dist_Brand_Eligibility#',
						0,
						'#Program_Packet.Basic_Information.ON_RELEASE_CONTRACT_STATUS_TYPE_IDX#',
						'#Program_Packet.Basic_Information.fixed_rebate_amount#',
						'#Program_Packet.Basic_Information.Creator_ID#',
						'#Program_Packet.Basic_Information.Editor_ID#',
						'#Program_Packet.Basic_Information.Notes#',
						#Program_Packet.Basic_Information.PaymentCycle#,
						'#Program_Packet.Basic_Information.Created_Type#',
						'#Program_Packet.Basic_Information.ProgramType_ID#',
						'#Program_Packet.Basic_Information.chkClaimPerfReq_1#',
						'#Program_Packet.Basic_Information.chkClaimPerfReq_2#',
						'#Program_Packet.Basic_Information.chkClaimPerfReq_3#',
						'#Program_Packet.Basic_Information.chkClaimPerfReq_4#',
						'#Program_Packet.Basic_Information.chkClaimPerfReq_5#',
						'#Program_Packet.Basic_Information.chkClaimPerfReq_6#',
						'#Program_Packet.Basic_Information.chkClaimPerfReq_7#',
						'#Program_Packet.Basic_Information.chkClaimPerfReq_8#',
						'#Program_Packet.Basic_Information.chkClaimPerfReq_9#',
						#Program_Packet.Basic_Information.CommRecip_1#,
						#Program_Packet.Basic_Information.CommRecip_2#,
						#Program_Packet.Basic_Information.CommRecip_3#,
						#Program_Packet.Basic_Information.CommRecip_4#,
						#Program_Packet.Basic_Information.Auto_Renew#,
						#Program_Packet.Basic_Information.Auto_Renewal_Fixed_Variable_Margin#,
						#Program_Packet.Basic_Information.CLAIMMECHANICS#,
						#Program_Packet.Basic_Information.BLDUPINVOICE#,
						#Program_Packet.Basic_Information.CONTROLLABLE_VOLUME#,
						#Program_Packet.Basic_Information.GROWTH_INCLUSION#,
						#Program_Packet.Basic_Information.GL_Assignment#,
						#Program_Packet.Basic_Information.Contract_Daily_Volume#,
						'#Program_Packet.Basic_Information.Adv_Spending_Amount#',
						'#Program_Packet.Basic_Information.Creating_User_Position_ID#',
						'#Program_Packet.Basic_Information.Pay_Brokerage#',
						#Program_Packet.Basic_Information.Parent_Revised_Contract_Main_ID#,
						#Program_Packet.Basic_Information.Revision_of_Contract_Main_ID#,
						#Program_Packet.Basic_Information.Approved#,
						<CFIF ucase(Program_Packet.Basic_Information.Approval_Date) EQ "NULL">
						NULL
						<CFELSE>
						#CreateODBCDateTime(Program_Packet.Basic_Information.Approval_Date)#
						</CFIF>,
						<CFIF ucase(Program_Packet.Basic_Information.Approved_By_User_ID) EQ "NULL">
						NULL
						<CFELSE>
						'#Program_Packet.Basic_Information.Approved_By_User_ID#'
						</CFIF>,
						'#Program_Packet.Basic_Information.Broker_Approved#',
						<CFIF ucase(Program_Packet.Basic_Information.Broker_Approved_Date) EQ "NULL">
						NULL
						<CFELSE>
						#CreateODBCDateTime(Program_Packet.Basic_Information.Broker_Approved_Date)#
						</CFIF>,
						'#Program_Packet.Basic_Information.Broker_User_ID#',
						'#Program_Packet.Basic_Information.Is_A_Revision#',
						'#Program_Packet.Basic_Information.IsExclusionRevision#',
						'#Program_Packet.Basic_Information.Is_Manual_Revision#',
						'#Program_Packet.Basic_Information.On_Release_Contract_Status_Type_IDX#',
						'1',
						'#Program_Packet.Basic_Information.Creator_ID#',
						GetDate(),
						'#Program_Packet.Basic_Information.Responsible_User_ID#',
						'#Program_Packet.Basic_Information.Formula_Price_Rebate_Type#',
						'#Program_Packet.Basic_Information.Business_Segment_ID#',
						'#Program_Packet.Basic_Information.Owner_Company_ID#',
						'#Program_Packet.Basic_Information.Currency#',
						'#Program_Packet.Basic_Information.Pullback_From_This_Program#'
						<!--- Dev Note: CPM Budgets --->
						<!---<cfif appSettings.getBudgetsOn() 
							  AND appSettings.getSelectBudgetsOn() EQ 1 
							  AND appSettings.getBudgetRelationshipToPrograms() EQ 1>
						,'#Program_Packet.Basic_Information.Budget_Reference_ID#'
						</cfif>--->
					)
					SELECT MAX(Contract_Main_ID) AS Contract_Main_ID FROM Contract_Main 
					SET NOCOUNT OFF
				</CFQUERY>
				
				<CFSET Renewed_Program_ID = insert.Contract_Main_ID>
				
				
<cfquery name="getTemplateSettings" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#Program_Packet.Basic_Information.ProgramType_ID#'
</cfquery>
				
					<!--- save accounting specialist --->
<cfif application.returned_customer_setting.Accounting_Specialist eq 1>
				<CFSET ListOfColumsToIgnore="Program_Accounting_Specialist_id,program_id,DELETED,created_date">
				<CFSET ThisStructureLevel = Program_Packet.Program_Accounting_Specialist>
				
				<CFIF ThisStructureLevel.recordcount GT 0>
					<cfset accounting_specialist_user_id = ThisStructureLevel.user_id>

						<!--- save data query --->
						<CFQUERY NAME="SaveProgramAccountingSpecialist" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(user_id,program_id)
							VALUES
							(#accounting_specialist_user_id#,#Renewed_Program_ID#)
						</CFQUERY>
					
				</CFIF>
				
	</cfif>
				<!--- END save --->		
				<!--- save operators --->
				<cfif getTemplateSettings.Specify_Operators EQ 1>
				<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,CONTRACT_OPERATORS_ID,DELETED,CREATED_DATE">
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
						<CFQUERY NAME="saveOperator" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Contract_Main_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				</cfif>
				<!--- END save --->				

 				<!--- save brokers --->
				<cfif getTemplateSettings.Specify_Brokers EQ 1>
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
						<CFQUERY NAME="saveBroker" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Contract_Main_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				</cfif>
				<!--- END save --->		 

 				<!--- save DISTRIBUTORS --->
				<cfif getTemplateSettings.Specify_Distributors EQ 1>
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
						<CFQUERY NAME="saveDISTRIBUTORS" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Contract_Main_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				</cfif>
				<!--- END save --->
				
				<!------<CFIF FORM.ISREVISIONOFEXISTINGCONTRACT EQ 1>----->
				<!--- save Attachments --->
				<CFSET ListOfColumsToIgnore="CREATED_DATE,PROGRAM_ID,ATTACHMENT_ID,DELETED">
				<CFSET ThisStructureLevel = Program_Packet.Attachments>
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
						<CFQUERY NAME="saveDISTRIBUTORS" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->
				<!------</CFIF>----->

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
						<CFQUERY NAME="saveProduct" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Contract_Main_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
						
						<!--- map old contract product_id to new one --->
						<CFSET Contract_Products_ID_Mapping[ArrayLen(Contract_Products_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
						<CFSET Contract_Products_ID_Mapping[ArrayLen(Contract_Products_ID_Mapping)][2] = saveProduct.Contract_Products_ID>
						<!--- end map old contract product_id to new one --->
					</CFLOOP>	
				</CFIF>
				<!--- END save --->
				
 				<!--- save Fixed Price Products --->
	<cfif getTemplateSettings.Discount_Fixed_Prices EQ 1>
				<CFIF  appSettings.getfixedcomponents_on()>
				<!--- intialize component mapping array --->
				<CFSET Program_Fixed_Component_ID_Mapping = ArrayNew(2)>
				<!--- end intialize component mapping array --->			

 				<!--- save fixed components --->
				<CFSET ListOfColumsToIgnore="PROGRAM_ID,DELETED,PROGRAM_FIXED_COMPONENT_ID,CREATED_DATE">
				<CFSET ThisStructureLevel = Program_Packet.Fixed_Price_Components>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
<cfoutput>#listfind(ListOfColumsToIgnore,temp_Column_Name)# - #temp_Column_Name# <br></cfoutput>
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<cfif NOT Len(Trim(DataItemForTheList))>
									<cfset DataItemForTheList = "NULL" />
								</cfif>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
			
						<!--- save data query --->
						<CFQUERY NAME="saveFixedComponents" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							<!----(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)---->
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
SELECT Program_Fixed_Component_ID = @@IDENTITY
						</CFQUERY>

						<!--- map old lump sum component id to new one --->
						<CFSET Program_Fixed_Component_ID_Mapping[ArrayLen(Program_Fixed_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_FIXED_COMPONENT_ID_#LoopCount#")>
						<CFSET Program_Fixed_Component_ID_Mapping[ArrayLen(Program_Fixed_Component_ID_Mapping)][2] = saveFixedComponents.Program_Fixed_Component_ID>
						<!--- end map old lump sum component id to new one --->
					</CFLOOP>	
				</CFIF>
				<!--- END save --->
				
			<!--- save fixed component Products --->
				<CFSET ListOfColumsToIgnore="PROGRAM_ID,CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_FIXED_PRICE_PRODUCT_DATA_ID,PROGRAM_FIXED_COMPONENT_ID">
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
						<!--- Find Mapped Contract_Product_ID --->
						<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
						<CFSET Mapped_product_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
							<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- Find Mapped Component --->
						<CFSET Old_Program_Fixed_Component_ID = evaluate("ThisStructureLevel.PROGRAM_FIXED_COMPONENT_ID_#LoopCount#")>
						<CFSET Mapped_Program_Fixed_Component_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Program_Fixed_Component_ID_Mapping)#" STEP="1">
							<CFIF Old_Program_Fixed_Component_ID EQ Program_Fixed_Component_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_Program_Fixed_Component_ID = Program_Fixed_Component_ID_Mapping[ArrayPositionCount][2]>
								<CFBREAK>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- save data query --->
						<CFQUERY NAME="saveFixedProducts" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							<!---(Contract_Products_ID,PROGRAM_LUMP_SUM_ID)--->
							(#FieldList#,Program_id, Contract_Products_ID,PROGRAM_FIXED_COMPONENT_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#, #Mapped_product_ID#,'#Mapped_Program_Fixed_Component_ID#')
							<!---(#Mapped_product_ID#,'#Mapped_Lump_Sum_ID#')--->
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->						
<CFELSE>

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
						<CFQUERY NAME="saveFixedPriceProducts" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,Contract_Products_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#, #Mapped_product_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save ---> 
</CFIF>
</cfif>
				<!--- END save --->
				
				
				<!--- Save BidRequest --->
				
				<cfif getTemplateSettings.Discount_Bidrequest EQ 1>
				<CFIF  appSettings.getBidRequestComponentsOn()>
				<!--- intialize component mapping array --->
				<CFSET Program_BidRequest_Component_ID_Mapping = ArrayNew(2)>
				<!--- end intialize component mapping array --->			

 				<!--- save fixed components --->
				<CFSET ListOfColumsToIgnore="PROGRAM_ID,DELETED,PROGRAM_BIDREQUEST_COMPONENT_ID,CREATED_DATE">
				<CFSET ThisStructureLevel = Program_Packet.BidRequest_Components>
				<CFIF ThisStructureLevel.recordcount GT 0>
					<CFLOOP INDEX="LoopCount" FROM="1" TO="#ThisStructureLevel.recordcount#" STEP="1">
						<CFSET FieldList = "">
						<CFSET DataValueList = "">
						
						<CFLOOP INDEX="temp_Column_Name" LIST="#ThisStructureLevel.ColumnList#">
<cfoutput>#listfind(ListOfColumsToIgnore,temp_Column_Name)# - #temp_Column_Name# <br></cfoutput>
							<CFIF listfind(ListOfColumsToIgnore,temp_Column_Name) EQ 0>
								<CFSET FieldList = listappend(FieldList,temp_Column_Name)>
								<CFSET DataItemForTheList = evaluate("ThisStructureLevel.#temp_Column_Name#_#LoopCount#")>
								<CFSET stringToEscape = DataItemForTheList>
								<CFSET stringToEscape = Replace(stringToEscape,chr(39),"&##39","ALL")> <!--- apostrophe --->
								<CFSET stringToEscape = Replace(stringToEscape,chr(44),"&##44","ALL")> <!--- comma --->
								<CFSET DataItemForTheList = stringToEscape>
								<cfif NOT Len(Trim(DataItemForTheList))>
									<cfset DataItemForTheList = "NULL" />
								</cfif>
								<CFSET DataValueList = listappend(DataValueList,DataItemForTheList)>
							</CFIF>
						</CFLOOP>
						
			
						<!--- save data query --->
						<CFQUERY NAME="saveBidRequestComponents" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							<!----(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)---->
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
SELECT Program_BidRequest_Component_ID = @@IDENTITY
						</CFQUERY>

						<!--- map old lump sum component id to new one --->
						<CFSET Program_BidRequest_Component_ID_Mapping[ArrayLen(Program_BidRequest_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_BidRequest_COMPONENT_ID_#LoopCount#")>
						<CFSET Program_BidRequest_Component_ID_Mapping[ArrayLen(Program_BidRequest_Component_ID_Mapping)][2] = saveBidRequestComponents.Program_BidRequest_Component_ID>
						<!--- end map old lump sum component id to new one --->
					</CFLOOP>	
				</CFIF>
				<!--- END save --->
				
			<!--- save fixed component Products --->
				<CFSET ListOfColumsToIgnore="PROGRAM_ID,CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_BID_REQUEST_PRODUCT_ID,PROGRAM_BIDREQUEST_COMPONENT_ID">
				<CFSET ThisStructureLevel = Program_Packet.Products.BidRequest_PRODUCTS>
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
						<!--- Find Mapped Contract_Product_ID --->
						<CFSET Old_Contract_Product_ID = evaluate("ThisStructureLevel.Contract_Products_ID_#LoopCount#")>
						<CFSET Mapped_product_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Contract_Products_ID_Mapping)#" STEP="1">
							<CFIF Old_Contract_Product_ID EQ Contract_Products_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_product_ID = Contract_Products_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- Find Mapped Component --->
						<CFSET Old_Program_BidRequest_Component_ID = evaluate("ThisStructureLevel.PROGRAM_BidRequest_COMPONENT_ID_#LoopCount#")>
						<CFSET Mapped_Program_BidRequest_Component_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Program_BidRequest_Component_ID_Mapping)#" STEP="1">
							<CFIF Old_Program_BidRequest_Component_ID EQ Program_BidRequest_Component_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_Program_BidRequest_Component_ID = Program_BidRequest_Component_ID_Mapping[ArrayPositionCount][2]>
								<CFBREAK>
							</CFIF>
						</CFLOOP>
						<!--- END Mapped Contract_Product_ID --->

						<!--- save data query --->
						<CFQUERY NAME="saveBidRequestProducts" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							<!---(Contract_Products_ID,PROGRAM_LUMP_SUM_ID)--->
							(#FieldList#,Program_id, Contract_Products_ID,PROGRAM_BidRequest_COMPONENT_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#, #Mapped_product_ID#,'#Mapped_Program_BidRequest_Component_ID#')
							<!---(#Mapped_product_ID#,'#Mapped_Lump_Sum_ID#')--->
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->						
<CFELSE>

 				<!--- save Bid Request Products --->
				<CFSET ListOfColumsToIgnore="CONTRACT_MAIN_ID,DELETED,CONTRACT_PRODUCTS_ID,PROGRAM_BID_REQUEST_PRODUCT_ID,PROGRAM_ID,CREATED_DATE">
				<CFSET ThisStructureLevel = Program_Packet.Products.BidRequest_PRODUCTS>
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
						<CFQUERY NAME="saveBidRequestPriceProducts" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,Contract_Products_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#, #Mapped_product_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save ---> 
</CFIF>
</cfif>

					<!--- save Off Invoice Products --->
<cfif getTemplateSettings.Generic_Type IS "Distributor Off-Invoice">
				<CFSET ListOfColumsToIgnore="PROGRAM_ID,CREATED_DATE,DELETED_BY,CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_OFFINVOICE_PRODUCT_DATA_ID">
				<CFSET ThisStructureLevel = Program_Packet.Products.OffInvoice_Products>
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
						<CFQUERY NAME="saveOffInvoiceProducts" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,Contract_Products_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#, #Mapped_product_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
</cfif>
				<!--- END save --->	
				
				
 				<!--- save Rebate Products --->
<CFIF getTemplateSettings.Discount_Rebates EQ 1>
 				<cfscript>
				
					//create instance of rebate
					//rebate = createObject("component","components.programs.rebates.Rebate");
					if(isdefined("Program_Packet.Products.Rebate_Products.Rebate_Array")) {
						rebateData = Program_Packet.Products.Rebate_Products.Rebate_Array;
						if (ArrayLen(rebateData.aProd))
						{
							rebateData.programId = Renewed_Program_ID;
							rebate.commit(rebateData);
						}
					}
				</cfscript>
 				<CFSET ListOfColumsToIgnore="PROGRAM_ID,CONTRACT_PRODUCTS_ID,DELETED,PROGRAM_REBATES_PRODUCT_DATA_ID,CREATED_DATE">
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
						<CFQUERY NAME="saveREBATEPriceProducts" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,Contract_Products_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#, #Mapped_product_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				</cfif>
				<!--- END save --->								

				<!--- intialize component mapping array --->
<CFIF getTemplateSettings.Discount_Lump_Sums EQ 1>
				<CFSET Lump_Sum_Component_ID_Mapping = ArrayNew(2)>
				<!--- end intialize component mapping array --->			

 				<!--- save lump sums --->
				<CFSET ListOfColumsToIgnore="PROGRAM_ID,DELETED,PROGRAM_LUMP_SUM_ID,PROGRAM_LUMPS_SUM_EXT_ID">
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
						<CFQUERY NAME="saveLumpSumComponents" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							<!---(#replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL")#,#Renewed_Program_ID#)--->
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
						<CFQUERY NAME="saveLumpSumProducts" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(Contract_Products_ID,PROGRAM_LUMP_SUM_ID)
							VALUES
							(#Mapped_product_ID#,'#Mapped_Lump_Sum_ID#')
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
</cfif>
				<!--- END save --->						
						 				
				<!--- save Growth Component --->
<CFIF getTemplateSettings.Discount_Growth EQ 1>
				<CFSET Growth_Component_ID_Mapping = ArrayNew(2)>
				<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_GROWTH_COMPONENT_ID,PROGRAM_ID,GROWTH_COMPONENT_NAME_ID">
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
						<CFQUERY NAME="saveGrowthComponent" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
				
						<!--- map old lump sum component id to new one --->
						<CFSET Growth_Component_ID_Mapping[ArrayLen(Growth_Component_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_ID_#LoopCount#")>
						<CFSET Growth_Component_ID_Mapping[ArrayLen(Growth_Component_ID_Mapping)][2] = saveGrowthComponent.A_ID>
						<!--- end map old lump sum component id to new one --->		
						
						<!---Update parent id--->
						<!---Makes sure we have the values--->
					
						<CFSET Old_Growth_Component_ID = evaluate("ThisStructureLevel.PROGRAM_GROWTH_COMPONENT_ID_#LoopCount#")>
						<CFSET Mapped_Growth_Component_ID = "">
						<CFLOOP INDEX="ArrayPositionCount" FROM="1" TO="#ArrayLen(Growth_Component_ID_Mapping)#" STEP="1">
							<CFIF Old_Growth_Component_ID EQ Growth_Component_ID_Mapping[ArrayPositionCount][1]>
								<CFSET Mapped_Growth_Component_ID = Growth_Component_ID_Mapping[ArrayPositionCount][2]>
							</CFIF>
						</CFLOOP>
						
						<!---Query to do the update--->
						<cfquery name="UpdateGrowthWithParentID" datasource="#application.datasource#">
						UPDATE Program_Growth_Components
						SET Parent_ID = '#Mapped_Growth_Component_ID#'
						WHERE Parent_ID = '#Old_Growth_Component_ID#'
						AND Program_ID = '#Renewed_Program_ID#'
						</cfquery>

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
						<CFQUERY NAME="saveGrowthComponentTiers" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,PROGRAM_GROWTH_COMPONENT_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#, '#Mapped_Growth_Component_ID#')
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
						<CFQUERY NAME="saveGrowthComponentProducts" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,CONTRACT_PRODUCTS_ID,PROGRAM_GROWTH_COMPONENT_ID)
							VALUES
							<!------(#DataValueList#,'#Mapped_product_ID#','#Mapped_Growth_Component_ID#')----->
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,'#Mapped_product_ID#','#Mapped_Growth_Component_ID#')							
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
						<CFQUERY NAME="saveproduct_tier_data" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID,PROGRAM_GROWTH_COMPONENT_TIER_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,'#Mapped_PROGRAM_GROWTH_COMPONENT_PRODUCT_DATA_ID#','#Mapped_Growth_Component_Tier_ID_Mapping#')
						</CFQUERY>
					</CFLOOP>
				</CFIF>
</cfif>
				<!--- END save --->
				
				<!--- save pricing formula periods --->
<CFIF getTemplateSettings.Discount_Formula_Pricing EQ 1>
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
						<CFQUERY NAME="savePricingPeriods" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
				<!--- END save --->

				<!--- intialize formula pricing rule ID mapping array --->
				<CFSET Program_Formula_Pricing_Rule_ID_Mapping = ArrayNew(2)>
				
				
				<!--- save pricing formula rules --->
				<CFSET ListOfColumsToIgnore="DELETED,PROGRAM_FORMULA_PRICING_RULE_MAPPED_ID,PROGRAM_ID">
				<CFSET ThisStructureLevel = Program_Packet.FORMULA_PRICING.PROGRAMRULES>
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
						<CFQUERY NAME="savePricingRules" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#)
						</CFQUERY>

						<!--- map old rule id to new one --->
						<CFSET Program_Formula_Pricing_Rule_ID_Mapping[ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)+1][1] = evaluate("ThisStructureLevel.Program_Formula_Pricing_Rule_Mapped_ID_#LoopCount#")>
						<CFSET Program_Formula_Pricing_Rule_ID_Mapping[ArrayLen(Program_Formula_Pricing_Rule_ID_Mapping)][2] = savePricingRules.Program_Formula_Pricing_Rule_Mapped_ID>
						<!--- end map old rule id to new one --->	

						
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
						<CFQUERY NAME="saveFormulaPricingProducts" datasource="#application.datasource#">
							INSERT INTO #ThisStructureLevel.Master_Table#
							(#FieldList#,Program_ID,Contract_Product_ID,PROGRAM_FORMULA_PRICING_RULE_ID)
							VALUES
							(#replace(replace(listqualify(DataValueList, "'", ","), '"', "'", "ALL"), "'NULL'", "NULL", "ALL")#,#Renewed_Program_ID#,#Mapped_product_ID#,'#Mapped_PROGRAM_FORMULA_PRICING_RULE_ID#')
						</CFQUERY>
					</CFLOOP>	
				</CFIF>
		
				<!----- Generate Formula Prices ---------->
				<CFSET generateReleaseProgramID = Renewed_Program_ID>
				<CFSET generateRelease_GeneratePrices = 1>
				<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">
</cfif>
				<!--- END save --->
				
				<!--- this update forces UPDATE Stored Procs To Run Which = GOOD --->
				<CFQUERY NAME="ForceTriggersToExecute" datasource="#application.datasource#">
					UPDATE Contract_Main
					SET Deleted = '#Program_Packet.Basic_Information.DELETED#'
					WHERE Contract_Main_ID = '#Renewed_Program_ID#'
				</CFQUERY>
		