<cfset useLakebaseForGetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetStatus>
	<cftry>
		<cfset GetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"select" = "billback_status_id,uploaded_billback"
			}), "billback_status_id,uploaded_billback"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStatus>
<CFQUERY NAME="GetStatus" DATASOURCE="#Application.Datasource#">
	SELECT Billback_Status_ID, Uploaded_Billback FROM Billback WHERE Billback_ID = '#FORM.Billback_ID#'
</CFQUERY>
</cfif>
<CFIF GetStatus.Billback_Status_ID GTE 3> 
	<!--- 17302 - Redirect to Summary --->
	<CFSET Billback_Status_ID = GetStatus.Billback_Status_ID>
	<CFSET BB_ID_TO_Redirect = FORM.Billback_ID>
	<CFINCLUDE TEMPLATE = "BB_Summary_Redirect.cfm">
	<CFABORT>
</CFIF>

<!--- D22543 - Prevent updates while deviation Run all is in progress - Grid could cause this issue as it opens in popup --->

<CFPARAM NAME="In_Progress_Check_BBID" default="">
<CFPARAM NAME="PageName_InProgress" default="">
<CFPARAM NAME="Progress_Type" default="0">

<CFSET In_Progress_Check_BBID = FORM.Billback_ID>
<CFSET PageName_InProgress = "Payee">
<CFSET Progress_Type = 1>	
<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">



<cfinclude template="/Script/cf/ListCompare.cfm">
<cfset appSettings = application.appSettingsGet />
<cfparam name="form.selected_bb_payee_type" 			default="0">
<cfparam name="form.selected_bb_payee_type_is_unknown" 	default="0">
<CFPARAM NAME="form.vendor_ID" DEFAULT="">
<cfparam name="form.multiDistList"					default = "">
<cfparam name="alertList"				default = "">
<cfparam name="form.modifyagreeacttion" default="0">
<cfparam name="form.saveOverwriteOption" default="">
<cfparam name="insertList" default="">

<!--- Ana: D15494 Get Payee Type --->
<cfquery name="GetPayeeType" datasource="#application.datasource#">
	SELECT  	Billback_Payee_Type_ID, Billback_Distributor.Distributor_ID 
	FROM 		Billback	
	LEFT JOIN 	Billback_Distributor ON Billback_Distributor.Billback_ID = Billback.Billback_ID AND
				Billback_Distributor.Deleted = 0
	WHERE 		Billback.Billback_ID = '#form.billback_id#'
</cfquery>

<!--- save the payee type in the bb table --->
<cfset useLakebaseForsavePayeeType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForsavePayeeType>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#form.billback_id#"
			},
			{
				"billback_payee_type_id" = "#form.selected_bb_payee_type#",
				"deviation_ran_date" = javaCast("null",""),
				"auto_deviation_on" = javaCast("null",""),
				"deviation_ran_by" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForsavePayeeType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsavePayeeType>
<cfquery name="savePayeeType" datasource="#application.datasource#">
	UPDATE Billback
	SET Billback_Payee_Type_ID = '#form.selected_bb_payee_type#',
		<!--- Ana: D15311 -- Set the Deviation Ran Details --->
		Deviation_Ran_Date = NULL,
		Auto_Deviation_On = NULL,
		Deviation_Ran_By = NULL 
	WHERE Billback_ID = '#form.billback_id#'
</cfquery>
</cfif>

<cfset billbackAssignmentManager = CreateOBject("component", "components.billback.BillbackAssignmentManager") />
<cfset billbackSummaryManager = CreateOBject("component", "components.billback.billbackSummaryManager") />
<cfset setAnalyst = 0 />

<CFSWITCH expression="#form.selected_bb_payee_type#">
	<CFCASE value="1"><!--- DISTRIBUTOR --->
		<CFSWITCH expression="#form.selected_bb_payee_type_is_unknown#">
			<CFCASE value="0"><!--- known (in the DB) --->				
				<cfset useLakebaseFordeletepriordata = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor")>
<cfif useLakebaseFordeletepriordata>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_distributor",
			{
				"billback_id" = "eq.#form.billback_ID#",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeletepriordata = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletepriordata>
<cfquery name="deletepriordata" datasource="#Application.Datasource#">
					UPDATE billback_distributor
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</cfquery>
</cfif>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Operator
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Broker
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Unidentified_Payee
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFIF TRIM(form.distributor_ID) NEQ ''>  <!--- There needs to be an ID to INSERT --->
					<cfquery name="insert" datasource="#application.datasource#">
						INSERT INTO billback_distributor
						(
							billback_ID,
							distributor_id,
							<CFIF IsDefined("FORM.Vendor_ID")>
							Uploaded_Vendor_ID,
							</CFIF>
							bb_distributor_notes
						)
						VALUES
						(
							'#form.billback_ID#',
							'#form.distributor_ID#',
							<CFIF IsDefined("FORM.Vendor_ID")>
							'#form.Vendor_ID#',
							</CFIF>
							'#form.Distributor_Notes#'						
						)
					</cfquery>
				</CFIF>
				<!---############    Multi distributors on a BB get populated here--->
				<!--- Clean up the distributorList --->
				<cfset prodList = billbackSummaryManager.getBBProdDistIdList(FORM.Billback_ID)>
				<cfset currentList = billbackSummaryManager.getBBCurrDistIdList(FORM.Billback_ID)>
				
				<!--- D29495: Billback_Detail missing ship_to number --->
				<cfif form.saveOverwriteOption eq "DistributorPayeeRetainExisting">
					<!--- If distributor list is empty add product distributor list so that products will not get wiped out --->
					<cfif form.multiDistList eq "">
						<cfset form.multiDistList = prodList />
					</cfif>
					<cfset insertList = form.multiDistList />
				<cfelse>
					<cfset insertList = "" />
				</cfif>

				<cfset deleteList = ListCompare(currentList, insertList)>
				<cfset tmpInsertList = listappend(insertList,form.distributor_ID)>
				<cfset alertList  = ListCompare(prodList, tmpInsertList)> <!--- Add the payee to the insertlist when calculating the alertlist --->
				<cfset okdeleteList = ListCompare(deleteList, alertList)>	<!--- Not used right now.  we delete the products automatically --->
				<cfset okinsertList = ListCompare(insertList, currentList)>
				
				 <!--- <cfoutput>#insertList#<br />prodList - #prodList#  ::  currentList - #currentList#<br />
						 del - #deleteList#  ::  alert - #alertList#  ::  okdel - #okdeleteList#  ::  okins - #okinsertList#</cfoutput><cfabort>  --->
				<cfif trim(deleteList) neq ""> <!---####    We used to check to see if we can delete...now we delete the distributor and at the botom of this page
													####    DELETE all of the products for this distributor ::  billbackSummaryManager.removeDistributorProducts #######--->
					<cfquery name="DeldistList" datasource="#application.datasource#">
						Delete from Billback_Distributor_List
						where Billback_ID = '#FORM.Billback_ID#'
						and distributor_id in (#Listqualify(deleteList,"'",",")#)
					</cfquery>
				</cfif>
				<CFLOOP List="#okinsertList#" index="DistId">
					<cfquery name="qInsertList" datasource="#application.datasource#">
						INSERT INTO 
							Billback_Distributor_List 	
								(		Billback_ID,
										Distributor_ID)			
							Values
								(	'#form.billback_ID#',
									'#DistId#'
									)
												
									<!---Update Billback_Distributor
										Set Is_BB_Calc = 0
										Where Billback_ID = '#form.billback_ID#'--->
					</cfquery>
				</CFLOOP>
						<!--- 		<cfquery name="DeldistList" datasource="#application.datasource#">
									Delete from Billback_Distributor_List
										where Billback_ID = '#FORM.Billback_ID#'
								</cfquery>
				<CFLOOP List="#form.multiDistList#" index="DistId">
									<cfquery name="insertList" datasource="#application.datasource#">
													INSERT INTO 
														Billback_Distributor_List 	
															(		Billback_ID,
																	Distributor_ID)			
														Values
															(	'#form.billback_ID#',
																'#DistId#'
																)
																
													<!---Update Billback_Distributor
														Set Is_BB_Calc = 0
														Where Billback_ID = '#form.billback_ID#'--->
									</cfquery>
				</CFLOOP> --->
				<!---############    Multi distributors on a BB get populated END END--->
				<cfset billbackAssignmentManager.saveBillbackAnalyst(billbackId = form.billback_ID, distributorId = form.distributor_ID, operatorId = "") />
				<cfset setAnalyst = 1 />
				<cfset BBType_ID = 1> 
			</CFCASE>

			<CFCASE value="1"><!--- unknown --->
				<cfquery name="deletepriordata" datasource="#Application.Datasource#">
					UPDATE billback_distributor
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</cfquery>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Operator
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Broker
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Unidentified_Payee
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>

				<cfquery name="insert" datasource="#application.datasource#">
					INSERT INTO billback_distributor
					(
						billback_ID,
						bb_distributor_name,
						bb_distributor_address1,
						bb_distributor_address2,
						bb_distributor_city,
						bb_distributor_state,
						bb_distributor_zipcode,
						bb_distributor_country_code,
						bb_distributor_notes
					)
					VALUES
					(
						'#form.billback_ID#',
						'#form.Unknown_Distributor_Name#',
						'#form.Unknown_Distributor_Address_1#',
						'#form.Unknown_Distributor_Address_2#',
						'#form.Unknown_Distributor_City#',
						'#form.Unknown_Distributor_State#',
						'#form.Unknown_Distributor_Zip#',
						'#form.Unknown_Distributor_Country_Code#',
						'#form.Unknown_Distributor_Notes#'
					)
				</cfquery>
				<cfset BBType_ID = 5> 
			</CFCASE>

			<cfdefaultcase>
			
			</cfdefaultcase>
		</CFSWITCH>
		
	<!---
    	Dev Notes: Anand Rao/24-Jul-13/D38473: EDI -- 'USE DEFAULT PROGRAM IF OPERATOR AND/OR DISTRIBUTOR IS INVALID'
	--->	
		<cfset useLakebaseForGetBillbackSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForGetBillbackSettings>
	<cftry>
		<cfset GetBillbackSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "default_program,use_dflt_prg"
			}), "default_program,use_dflt_prg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBillbackSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBillbackSettings>
<cfquery name="GetBillbackSettings" datasource="#application.datasource#">
			SELECT Default_Program,USE_DFLT_PRG FROM Billback_Settings
		</cfquery>
</cfif>		
		<cfif len(trim(GetBillbackSettings.Default_Program)) GT 0>
			<cfset useLakebaseForIsDefaultProgramOnBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForIsDefaultProgramOnBillback>
	<cftry>
		<cfset IsDefaultProgramOnBillback = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"program_id" = "eq.#GetBillbackSettings.Default_Program#",
				"billback_id" = "eq.#form.billback_ID#",
				"deleted" = "eq.0",
				"select" = "billback_program_id"
			}), "billback_program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsDefaultProgramOnBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsDefaultProgramOnBillback>
<cfquery name="IsDefaultProgramOnBillback" datasource="#application.datasource#">
				SELECT Billback_Program_ID
				FROM Billback_Program
				WHERE Program_ID = '#GetBillbackSettings.Default_Program#'
				AND Billback_ID = '#form.billback_ID#'
				AND Deleted = 0
			</cfquery>
</cfif>
			<cfif IsDefaultProgramOnBillback.Recordcount GT 0>
				<cfset HasDefaultProgram = 1>
			<cfelse>
				<cfset HasDefaultProgram = 0>
			</cfif>
		<cfelse>
			<cfset HasDefaultProgram = 0>
		</cfif>
		<!--- Update the below tables if the bb has the default program, and the tables have dummy distributor guids. --->
		<cfif HasDefaultProgram EQ 1 AND GetBillbackSettings.USE_DFLT_PRG EQ 1 AND GetStatus.Uploaded_Billback EQ 3>
			<cfset useLakebaseForupdBillbackProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product")>
<cfif useLakebaseForupdBillbackProduct>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_product",
			{
				"billback_id" = "eq.#form.billback_ID#",
				"distributor_id" = "eq.00000000-0000-0000-0000-000000000000",
				"deleted" = "eq.0"
			},
			{
				"distributor_id" = "#form.distributor_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBillbackProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBillbackProduct>
<cfquery name="updBillbackProduct" datasource="#Application.Datasource#">
				UPDATE Billback_Product
				SET Distributor_ID = '#form.distributor_ID#'
				WHERE Billback_ID = '#form.billback_ID#' AND Distributor_ID = '00000000-0000-0000-0000-000000000000' AND Deleted = 0
			</cfquery>
</cfif>
			<cfset useLakebaseForupdBillbackProductDetail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product_detail")>
<cfif useLakebaseForupdBillbackProductDetail>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_product_detail",
			{
				"billback_id" = "eq.#form.billback_ID#",
				"distributor_id_earned" = "eq.00000000-0000-0000-0000-000000000000",
				"deleted" = "eq.0"
			},
			{
				"distributor_id_earned" = "#form.distributor_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBillbackProductDetail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBillbackProductDetail>
<cfquery name="updBillbackProductDetail" datasource="#Application.Datasource#">
				UPDATE Billback_Product_Detail
				SET Distributor_ID_Earned = '#form.distributor_ID#'
				WHERE Billback_ID = '#form.billback_ID#' AND Distributor_ID_Earned = '00000000-0000-0000-0000-000000000000' AND Deleted = 0
			</cfquery>
</cfif>	
			<cfset useLakebaseForupdBBItemInvoiceLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_item_invoice_level")>
<cfif useLakebaseForupdBBItemInvoiceLevel>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_item_invoice_level",
			{
				"billback_id" = "eq.#form.billback_ID#",
				"distributor_id" = "eq.00000000-0000-0000-0000-000000000000",
				"deleted" = "eq.0"
			},
			{
				"distributor_id" = "#form.distributor_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBBItemInvoiceLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBBItemInvoiceLevel>
<cfquery name="updBBItemInvoiceLevel" datasource="#Application.Datasource#">
				UPDATE BB_Item_Invoice_Level
				SET Distributor_ID = '#form.distributor_ID#'
				WHERE Billback_ID = '#form.billback_ID#' AND Distributor_ID = '00000000-0000-0000-0000-000000000000' AND Deleted = 0
			</cfquery>
</cfif>	
		</cfif>
	</CFCASE>

	<CFCASE value="2"><!--- OPERATOR --->
		<CFSWITCH expression="#form.selected_bb_payee_type_is_unknown#">
			<CFCASE value="0"><!--- known (in the DB) --->
				
			
				<cfquery name="deletepriordata" datasource="#Application.Datasource#">
					UPDATE billback_distributor
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</cfquery>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Operator
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Broker
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Unidentified_Payee
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
  	  	<!--- 
	  	  	Added the checking and assiged as it was not working for the single
    			distributor option.  -Anand Rao 02/25/09 Label No:D18228
		    --->	
        <cfif appSettings.getMultiDistributorBB()>
			<cfset FORM.Associated_Ship_To = FORM.multiDistList />
		</cfif>		
				<cfquery name="insert" datasource="#application.datasource#">
					INSERT INTO billback_operator
					(
						billback_ID,
						operator_id,
						<CFIF IsDefined("FORM.Associated_Ship_To") AND FORM.Associated_Ship_To NEQ "">
						Associated_Ship_To,
						</CFIF>
						<CFIF IsDefined("FORM.Vendor_ID")>
						Uploaded_Vendor_ID,
						</CFIF>						
						bb_operator_notes						
					)
					VALUES
					(
						'#form.billback_ID#',
						'#form.operator_ID#',
						<CFIF IsDefined("FORM.Associated_Ship_To") AND FORM.Associated_Ship_To NEQ "">
						'#ListFirst(FORM.Associated_Ship_To)#',
						</CFIF>
						<CFIF IsDefined("FORM.Vendor_ID")>
						'#form.Vendor_ID#',
						</CFIF>
						'#form.Operator_Notes#'
						
					)
				</cfquery>
				<!---############    Multi distributors on a BB get populated here--->
				<!--- Clean up the distributorList --->
				<cfset prodList = billbackSummaryManager.getBBProdDistIdList(FORM.Billback_ID)>
				<cfset currentList = billbackSummaryManager.getBBCurrDistIdList(FORM.Billback_ID)>
				<cfset insertList = form.multiDistList>
				
				<cfset deleteList = ListCompare(currentList, insertList)>
				<cfset alertList  = ListCompare(prodList, insertList)>
				<cfset okdeleteList = ListCompare(deleteList, alertList)>  <!--- Not used right now.  we delete the products automatically --->
				<cfset okinsertList = ListCompare(insertList, currentList)>
				
				<!---<cfoutput>prodList - #prodList#  ::  currentList - #currentList#<br />
						 del - #deleteList#  ::  alert - #alertList#  ::  okdel - #okdeleteList#  ::  okins - #okinsertList#</cfoutput><cfabort>--->
				<cfif trim(deleteList) neq "">
								<cfquery name="DeldistList" datasource="#application.datasource#">
									Delete from Billback_Distributor_List
										where Billback_ID = '#FORM.Billback_ID#'
											and distributor_id in (#Listqualify(deleteList,"'",",")#)
								</cfquery>
				</cfif>
				<CFLOOP List="#okinsertList#" index="DistId">
									<cfquery name="qInsertList" datasource="#application.datasource#">
													INSERT INTO 
														Billback_Distributor_List 	
															(		Billback_ID,
																	Distributor_ID)			
														Values
															(	'#form.billback_ID#',
																'#DistId#'
																)
																
													<!---Update Billback_Distributor
														Set Is_BB_Calc = 0
														Where Billback_ID = '#form.billback_ID#'--->
									</cfquery>
				</CFLOOP>
				<cfif appSettings.getBB_Payee_Operator_Ship_To_Req() AND NOT appSettings.getMultiDistributorBB()>				
				<!--- Ana: Commenting this for D17352 <cfif isDefined("insertList") and ListLen(insertList) neq 0> --->
				 <cfquery name="DeldistList" datasource="#application.datasource#">
				   Delete from Billback_Distributor_List
				   where Billback_ID = '#FORM.Billback_ID#'			
				</cfquery>
				<!--- 
					Added the checking and assiged as it was not working for the single
					distributor option.  -Anand Rao 02/25/09 Label No:D18228
				--->        
        <cfif isDefined("FORM.Associated_Ship_To") AND FORM.Associated_Ship_To EQ "">
        <cfset FORM.Associated_Ship_To = FORM.multiDistList />
        </cfif>
        
				<cfquery name="insertDistList" datasource="#application.datasource#">
				  INSERT INTO
				  Billback_Distributor_List
				  (	Billback_ID,
					Distributor_ID)
				  Values
				  ('#form.billback_ID#',
				   '#form.Associated_Ship_To#'
				  )
				</cfquery>
               <!--- </cfif> --->
			 </cfif>
				<!---############    Multi distributors on a BB get populated END END--->
					<cfset billbackAssignmentManager.saveBillbackAnalyst(billbackId = form.billback_ID, distributorID = "", operatorID = form.operator_ID) />
					<cfset setAnalyst = 1 />
				<cfset BBType_ID = 2>
			</CFCASE>

			<CFCASE value="1"><!--- unknown --->
				<cfquery name="deletepriordata" datasource="#Application.Datasource#">
					UPDATE billback_distributor
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</cfquery>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Operator
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Broker
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Unidentified_Payee
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				
				<cfquery name="insert" datasource="#application.datasource#">
					INSERT INTO billback_operator
					(
						billback_ID,
						bb_operator_name,
						bb_operator_address1,
						bb_operator_address2,
						bb_operator_city,
						bb_operator_state,
						bb_operator_zipcode,
						bb_operator_country_code,
						bb_operator_notes
					)
					VALUES
					(
						'#form.billback_ID#',
						'#form.Unknown_operator_Name#',
						'#form.Unknown_operator_Address_1#',
						'#form.Unknown_operator_Address_2#',
						'#form.Unknown_operator_City#',
						'#form.Unknown_operator_State#',
						'#form.Unknown_operator_Zip#',
						'#form.Unknown_operator_Country_Code#',
						'#form.Unknown_operator_Notes#'
					)
				</cfquery>			
				<cfset BBType_ID = 6>
			</CFCASE>

			<cfdefaultcase>
			
			</cfdefaultcase>
		</CFSWITCH>
	</CFCASE>

	<CFCASE value="3"><!--- BROKER --->
		<CFSWITCH expression="#form.selected_bb_payee_type_is_unknown#">
			<CFCASE value="0"><!--- known (in the DB) --->
				<cfquery name="deletepriordata" datasource="#Application.Datasource#">
					UPDATE billback_distributor
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</cfquery>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Operator
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Broker
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Unidentified_Payee
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>

				<cfif appSettings.getMultiDistributorBB()>
					<cfset FORM.Associated_Ship_To = FORM.multiDistList />
				</cfif>

				<cfquery name="insert" datasource="#application.datasource#">
					INSERT INTO billback_broker
					(
						billback_ID,
						broker_id,
						<CFIF IsDefined("FORM.Associated_Ship_To") AND FORM.Associated_Ship_To NEQ "">
						Associated_Ship_To,
						</CFIF>
						<CFIF IsDefined("FORM.Vendor_ID")>
						Uploaded_Vendor_ID,
						</CFIF>
						bb_broker_notes
					)
					VALUES
					(
						'#form.billback_ID#',
						'#form.broker_ID#',
						<CFIF IsDefined("FORM.Associated_Ship_To") AND FORM.Associated_Ship_To NEQ "">
						'#FORM.Associated_Ship_To#',
						</CFIF>
						<CFIF IsDefined("FORM.Vendor_ID")>
						'#form.Vendor_ID#',
						</CFIF>
						'#form.broker_Notes#'
					)
				</cfquery>
				<!---############    Multi distributors on a BB get populated here--->
				<!--- Clean up the distributorList --->
				<cfset prodList = billbackSummaryManager.getBBProdDistIdList(FORM.Billback_ID)>
				<cfset currentList = billbackSummaryManager.getBBCurrDistIdList(FORM.Billback_ID)>
				<cfset insertList = form.multiDistList>
				
				<cfset deleteList = ListCompare(currentList, insertList)>
				<cfset alertList  = ListCompare(prodList, insertList)>
				<cfset okdeleteList = ListCompare(deleteList, alertList)>  <!--- Not used right now.  we delete the products automatically --->
				<cfset okinsertList = ListCompare(insertList, currentList)>
				
				<!---<cfoutput>prodList - #prodList#  ::  currentList - #currentList#<br />
						 del - #deleteList#  ::  alert - #alertList#  ::  okdel - #okdeleteList#  ::  okins - #okinsertList#</cfoutput><cfabort>--->
				<cfif trim(deleteList) neq "">
					<cfquery name="DeldistList" datasource="#application.datasource#">
						Delete from Billback_Distributor_List
							where Billback_ID = '#FORM.Billback_ID#'
								and distributor_id in (#Listqualify(deleteList,"'",",")#)
					</cfquery>
				</cfif>
				<CFLOOP List="#okinsertList#" index="DistId">
					<cfquery name="qInsertList" datasource="#application.datasource#">
					INSERT INTO 
						Billback_Distributor_List 	
							(		Billback_ID,
									Distributor_ID)			
						Values
							(	'#form.billback_ID#',
								'#DistId#'
							)
					</cfquery>
				</CFLOOP>
				<cfif appSettings.getBBPayeeBrokerShipToReq() AND NOT appSettings.getMultiDistributorBB()>				
				<!--- Ana: Commenting this for D17352 <cfif isDefined("insertList") and ListLen(insertList) neq 0> --->
				 <cfquery name="DeldistList" datasource="#application.datasource#">
				   Delete from Billback_Distributor_List
				   where Billback_ID = '#FORM.Billback_ID#'			
				</cfquery>
				<!--- 
					Added the checking and assiged as it was not working for the single
					distributor option.  -Anand Rao 02/25/09 Label No:D18228
				--->        
				<cfif isDefined("FORM.Associated_Ship_To") AND FORM.Associated_Ship_To EQ "">
				<cfset FORM.Associated_Ship_To = FORM.multiDistList />
				</cfif>
				
				<cfquery name="insertDistList" datasource="#application.datasource#">
				  INSERT INTO
				  Billback_Distributor_List
				  (	Billback_ID,
					Distributor_ID)
				  Values
				  ('#form.billback_ID#',
				   '#form.Associated_Ship_To#'
				  )
				</cfquery>
               <!--- </cfif> --->
			 </cfif>
				<cfset BBType_ID = 3>		
			</CFCASE>

			<CFCASE value="1"><!--- unknown --->
				<cfquery name="deletepriordata" datasource="#Application.Datasource#">
					UPDATE billback_distributor
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</cfquery>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Operator
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Broker
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
					UPDATE Billback_Unidentified_Payee
					SET Deleted = 1
					WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
				</CFQUERY>

				<cfquery name="insert" datasource="#application.datasource#">
					INSERT INTO billback_broker
					(
						billback_ID,
						bb_broker_name,
						bb_broker_address1,
						bb_broker_address2,
						bb_broker_city,
						bb_broker_state,
						bb_broker_zipcode,
						bb_broker_country_code,
						bb_broker_notes
					)
					VALUES
					(
						'#form.billback_ID#',
						'#form.Unknown_broker_Name#',
						'#form.Unknown_broker_Address_1#',
						'#form.Unknown_broker_Address_2#',
						'#form.Unknown_broker_City#',
						'#form.Unknown_broker_State#',
						'#form.Unknown_broker_Zip#',
						'#form.Unknown_broker_Country_code#',
						'#form.Unknown_broker_Notes#'
					)
				</cfquery>
				<cfset BBType_ID = 7>			
			</CFCASE>

			<cfdefaultcase>
			
			</cfdefaultcase>
		</CFSWITCH>
	</CFCASE>

	<CFCASE value="4"><!--- Other --->
			<cfquery name="deletepriordata" datasource="#Application.Datasource#">
				UPDATE billback_distributor
				SET Deleted = 1
				WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
			</cfquery>
			<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
				UPDATE Billback_Operator
				SET Deleted = 1
				WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
			</CFQUERY>
			<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
				UPDATE Billback_Broker
				SET Deleted = 1
				WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
			</CFQUERY>
			<CFQUERY NAME="deletepriordata" DATASOURCE="#Application.Datasource#">
				UPDATE Billback_Unidentified_Payee
				SET Deleted = 1
				WHERE Billback_ID = '#form.billback_ID#' AND Deleted = 0
			</CFQUERY>
			<!--- Clean up the distributorList --->
								<cfquery name="DeldistList" datasource="#application.datasource#">
									Delete from Billback_Distributor_List
										where Billback_ID = '#FORM.Billback_ID#'
								</cfquery>	
			<cfquery name="insert" datasource="#application.datasource#">
				INSERT INTO Billback_Unidentified_Payee
				(
					billback_ID,
					bb_up_name,
					bb_up_address1,
					bb_up_address2,
					bb_up_city,
					bb_up_state,
					bb_up_zipcode,
					bb_up_country_code,
					bb_up_notes
					<CFIF IsDefined("FORM.Associated_Ship_To") AND FORM.Associated_Ship_To NEQ "">
					,Associated_Ship_To
					</CFIF>
				)
				VALUES
				(
					'#FORM.billback_ID#',
					'#FORM.Other_Name#',
					'#FORM.Other_Address_1#',
					'#FORM.Other_Address_2#',
					'#FORM.Other_City#',
					'#FORM.Other_State#',
					'#FORM.Other_Zip#',
					'#FORM.Other_country_code#',
					'#FORM.Other_Notes#'
					<CFIF IsDefined("FORM.Associated_Ship_To") AND FORM.Associated_Ship_To NEQ "">
					,'#FORM.Associated_Ship_To#'
					</CFIF>
				)
			</cfquery>
			<CFIF IsDefined("FORM.Associated_Ship_To") AND FORM.Associated_Ship_To NEQ "">
				<cfset billbackAssignmentManager.saveBillbackAnalyst(billbackId = form.billback_ID, distributorId = FORM.Associated_Ship_To) />
				<cfset setAnalyst = 1 />
			</CFIF>
			<CFSET BBType_ID = 4>
	</CFCASE>
	
	<cfdefaultcase>
		<cfset BBType_ID = 0>	
	</cfdefaultcase>
</CFSWITCH>

<cfif setAnalyst EQ 0><!------ clear if there is previous anlyst saved already ----->
	<cfset billbackAssignmentManager.saveBillbackAnalyst(billbackId = form.billback_ID, distributorId = "") />
</cfif>

<!--- update billback --->
<CFIF BBType_ID NEQ 0>
	<cfquery name="savepayeetype" datasource="#Application.Datasource#">
		UPDATE Billback
		SET Billback_Payee_Type_ID = '#BBType_ID#'
		WHERE Billback_ID = '#FORM.Billback_ID#'
	</cfquery>
</CFIF>

<cfset useLakebaseForunidentifiedpayee = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForunidentifiedpayee>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#FORM.Billback_ID#"
			},
			{
				"bb_up" = "#form.selected_bb_payee_type_is_unknown#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForunidentifiedpayee = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForunidentifiedpayee>
<cfquery name="unidentifiedpayee" datasource="#Application.Datasource#">
	UPDATE Billback
	SET BB_UP = '#form.selected_bb_payee_type_is_unknown#'
	WHERE Billback_ID = '#FORM.Billback_ID#'
</cfquery>
</cfif>

<!--- 
	50616 - New Duplicate BB Logic/Anand Rao/17-Jun-2015
--->
<cfstoredproc procedure="BB_All_Dup_Group_Refresh" datasource="#application.datasource#">
 	<cfprocparam cfsqltype="CF_SQL_BIT" dbvarname="@@Full_Refresh" value="0" />
	<cfprocparam cfsqltype="CF_SQL_VARCHAR" dbvarname="@@Billback_ID" value="#FORM.Billback_ID#" />
</cfstoredProc>

<cfif isDefined("RedirectTo")>
  <cfif len(trim(RedirectTo)) GT 0>
   	<!--- 
  				Dev Notes: D24400/Anand Rao/16-Aug-10
  				Error Message: Payee update is in progress
          Added the below code to reset the flag BB_Upd_InProgress to 0 in the case of 
          the Big Billbacks.
  	--->
      <CFPARAM NAME="In_Progress_Check_BBID" default="">
      <CFPARAM NAME="PageName_InProgress" default="">
      <CFPARAM NAME="Progress_Type" default="0">
      
      <CFSET In_Progress_Check_BBID = FORM.Billback_ID>
      <CFSET PageName_InProgress = "Payee">
      <CFSET Progress_Type = 2>	
      <CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">
  	<cflocation url="#RedirectTo#?BBID=#FORM.Billback_ID#">
  </cfif>
</cfif>

<!--- simulate button click --->
<cfset local_bbid = FORM.Billback_ID>
<cfinclude template="bb_menu_stats.cfm">
<!--- Ana - 15494 - Billback payee changes do not delete prog if the new payee is part of the program --->
<!--- D30517: Item not appearing on Billback 'programs' page after importing it 
ADDED: one more condition to IF statement "form.saveOverwriteOption neq "DistributorPayeeRetainExisting"" to prevent updating when user select option B
 --->
<!--- D30718: Transferring Programs to new Key Accounts
Option A is not working as below Update is happening
We do not want below update if teh new distributor already have entries in Billback_product.Distributor_ID as it could result in duplicate key
User can chose the new Option C to do replace. 
 --->
<!--- 
<CFIF form.selected_bb_payee_type EQ 1 AND GetPayeeType.Billback_Payee_Type_ID EQ form.selected_bb_payee_type AND form.saveOverwriteOption neq "DistributorPayeeRetainExisting">

	<cfset useLakebaseForSaved_Program = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForSaved_Program>
	<cftry>
		<cfset Saved_Program = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#form.billback_ID#",
				"deleted" = "eq.0",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSaved_Program = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSaved_Program>
<CFQUERY NAME="Saved_Program" datasource="#application.datasource#">
		SELECT 	Program_ID 
		FROM 	Billback_Program 
		WHERE 	Billback_ID= '#form.billback_ID#' AND
				Deleted = 0
	</CFQUERY>
</cfif>
	
	<CFIF Saved_Program.RecordCount GT 0>
		
		<CFSET SavedProgramList = VALUELIST(Saved_Program.Program_ID)>
		
		<CFIF form.selected_bb_payee_type EQ 1>
		<CFQUERY NAME="NewPayee_In_Program" datasource="#application.datasource#">
			SELECT 	Contract_main_ID
			FROM 	Contract_Distributors 
			WHERE 	Contract_main_ID IN (#SavedProgramList#) AND
					BSA_FoodService_Customers_ID = '#form.distributor_ID#' AND
					Deleted = 0
		</CFQUERY>
		</CFIF>
		<CFIF form.selected_bb_payee_type EQ 1 AND GetPayeeType.Distributor_ID NEQ form.distributor_ID AND
				Saved_Program.RecordCount EQ NewPayee_In_Program.RecordCount>
			<cfset useLakebaseForqRemoveDistributorProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product")>
<cfif useLakebaseForqRemoveDistributorProducts>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_product",
			{
				"billback_id" = "eq.#form.billback_ID#",
				"distributor_id" = "eq.#GetPayeeType.Distributor_ID#"
			},
			{
				"distributor_id" = "#form.distributor_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqRemoveDistributorProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqRemoveDistributorProducts>
<CFQUERY NAME="qRemoveDistributorProducts" datasource="#application.datasource#">
				UPDATE 	Billback_Product 
				SET 	Distributor_id = '#form.distributor_ID#'
				WHERE 	Billback_ID= '#form.billback_ID#' AND
						Distributor_id = '#GetPayeeType.Distributor_ID#'
			</CFQUERY>
</cfif>
			<cfset useLakebaseForqRemoveDistributorProductDetail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product_detail")>
<cfif useLakebaseForqRemoveDistributorProductDetail>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_product_detail",
			{
				"billback_id" = "eq.#form.billback_ID#",
				"distributor_id_earned" = "eq.#GetPayeeType.Distributor_ID#"
			},
			{
				"distributor_id_earned" = "#form.distributor_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqRemoveDistributorProductDetail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqRemoveDistributorProductDetail>
<CFQUERY NAME="qRemoveDistributorProductDetail" datasource="#application.datasource#">
				UPDATE 	Billback_Product_detail 
				SET 	Distributor_id_Earned = '#form.distributor_ID#'
				WHERE 	Billback_ID= '#form.billback_ID#' AND
						Distributor_id_Earned = '#GetPayeeType.Distributor_ID#'
			</CFQUERY>
</cfif>

			<cfset useLakebaseForqUpdateDistributorID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_item_invoice_level")>
<cfif useLakebaseForqUpdateDistributorID>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_item_invoice_level",
			{
				"billback_id" = "eq.#form.billback_ID#",
				"distributor_id" = "eq.#GetPayeeType.Distributor_ID#"
			},
			{
				"distributor_id" = "#form.distributor_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateDistributorID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateDistributorID>
<CFQUERY NAME="qUpdateDistributorID" datasource="#application.datasource#">
				UPDATE 	BB_Item_Invoice_Level 
				SET 	Distributor_id = '#form.distributor_ID#'
				WHERE 	Billback_ID= '#form.billback_ID#'   AND
						Distributor_id = '#GetPayeeType.Distributor_ID#'
			</CFQUERY>
</cfif>
			<!--- Dev Note- Milan; 17165 - Do this only when there are products ("alertlist" is a list of distributors) 
						added to the billback. 
			--->
			<CFIF ListLen(alertList) GT 0>
				<CFSET DeletePosition = LISTFIND(alertList,GetPayeeType.Distributor_ID,",")>
				<cfset alertList = LISTDeleteAT(alertList,DeletePosition,",")>		
			</CFIF>
		</CFIF>
	</CFIF>
</CFIF>
 --->
<!--- END Ana - 15494 - Billback payee changes do not delete prog if the new payee is part of the program --->


<!--- D30517: Item not appearing on Billback 'programs' page after importing it START --->
<CFIF form.selected_bb_payee_type EQ 1 AND GetPayeeType.Billback_Payee_Type_ID EQ form.selected_bb_payee_type AND form.saveOverwriteOption eq "DistributorPayeeReplaceExisting">

	
			<CFQUERY NAME="qRemoveDistributorProducts" datasource="#application.datasource#">
				UPDATE 	Billback_Product 
				SET 	Distributor_id = '#form.distributor_ID#'
				WHERE 	Billback_ID= '#form.billback_ID#' 
				<!---AND Distributor_id = '#GetPayeeType.Distributor_ID#'--->
			</CFQUERY>
			<CFQUERY NAME="qRemoveDistributorProductDetail" datasource="#application.datasource#">
				UPDATE 	Billback_Product_detail 
				SET 	Distributor_id_Earned = '#form.distributor_ID#'
				WHERE 	Billback_ID= '#form.billback_ID#' 
				<!---AND		Distributor_id_Earned = '#GetPayeeType.Distributor_ID#'--->
			</CFQUERY>

			<CFQUERY NAME="qUpdateDistributorID" datasource="#application.datasource#">
				UPDATE BB_Item_Invoice_Level 
				SET 	Distributor_id = '#form.distributor_ID#'
				WHERE 	Billback_ID= '#form.billback_ID#'  
			</CFQUERY>
			
			<cfset alertList = "">
		
		
		<!--- 
			START:104331 - Billback did not consolidate with associated shipto on change/Anand Rao/18-Mar-2021 
			CONSOLIDATION CODE 
		--->
		<cfset ProductsToSwitchActual = ''/>		
		<cfquery name="UpdateConsolidationList" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..##bb_consolidate') IS NOT NULL
			DROP TABLE ##bb_consolidate
				
			SELECT	Row = ROW_NUMBER() OVER (PARTITION BY bp.Billback_Program_ID, bp.Distributor_id, bp.Product_ID ORDER BY bp.Created_Date) 
					, cnt = COUNT(*) OVER (PARTITION BY Billback_ID	, Product_ID, Billback_Program_ID, Distributor_ID)  
					, bp.Billback_ID
			        , bp.Billback_Product_ID
			        , bp.Billback_Program_ID
					, bp.Distributor_id
					, bp.Product_ID
					, bp.BB_Product_Quantity
					, bp.BB_Product_UOM
					, Consolidated_Qty = CAST(0 AS DECIMAL(18, 2))
			INTO	##bb_consolidate
			FROM	Billback_Product bp
			WHERE	bp.Deleted = 0
			AND		Billback_ID = '#FORM.Billback_ID#'
		/*  	AND 	bp.Billback_Product_ID IN (#listqualify(ProductsToSwitchActual, "'")#) */
			AND 	bp.Billback_Product_ID IN (SELECT Billback_Product_ID FROM Billback_Product WHERE Billback_ID = '#FORM.Billback_ID#' AND Deleted = 0)
			/* Process only the records that have atleast one record in the Billback_product */
			IF (SELECT COUNT(*) FROM ##bb_consolidate where cnt>1 ) >0
			BEGIN 
					-- consolidate Billback_Product 
					IF OBJECT_ID ('tempdb..##tmp_BP_Concolidate') IS NOT NULL
					DROP TABLE ##tmp_BP_Concolidate	
					SELECT	bp.Billback_ID
						  , bp.Billback_Program_ID
						  , bp.Distributor_id
						  , bp.Product_ID
						  , Consolidated_Qty = SUM(CAST(CASE bbc_survivor.BB_Product_UOM 
															WHEN 1 THEN CAST(bp.BB_Product_Quantity AS DECIMAL(18, 2))
															WHEN 2 THEN CASE WHEN CAST(i.Net_Weight AS DECIMAL(18, 2)) =0 THEN  CAST(bp.BB_Product_Quantity AS DECIMAL(18, 2))
																			 ELSE  CAST(bp.BB_Product_Quantity AS DECIMAL(18, 2))/CAST(i.Net_Weight AS DECIMAL(18, 2))
																		END
															ELSE 0
														END AS DECIMAL(18, 2)))		
						 , bbc_survivor.BB_Product_UOM 					
					INTO ##tmp_BP_Concolidate						
					FROM ##bb_consolidate bp
					JOIN ##bb_consolidate bbc_survivor
						ON  bbc_survivor.Billback_ID = bp.Billback_ID
						AND	bbc_survivor.Billback_Program_ID = bp.Billback_Program_ID
						AND bbc_survivor.Distributor_id = bp.Distributor_id
						AND bbc_survivor.Product_ID = bp.Product_ID
						AND bbc_survivor.Row = 1
					LEFT JOIN BSA_Foodservice_Items_Master i
						ON i.BSA_Foodservice_Items_Master_ID = bp.Product_ID
					WHERE bp.cnt>1
					GROUP BY bp.Billback_ID
						  , bp.Billback_Program_ID
						  , bp.Distributor_id
						  , bp.Product_ID
						  , bbc_survivor.BB_Product_UOM 
						  
					UPDATE bp 
					SET BB_Product_Quantity = CASE WHEN bc.Consolidated_Qty = 0.0 THEN 1
												   ELSE bc.Consolidated_Qty
											  END
					/*  SELECT bc.Consolidated_Qty, bp.* */
					FROM Billback_product bp
					JOIN ##tmp_BP_Concolidate bc
						ON  bc.Billback_ID = bp.Billback_ID
						AND	bc.Billback_Program_ID = bp.Billback_Program_ID
						AND bc.Distributor_id = bp.Distributor_id
						AND bc.Product_ID = bp.Product_ID
					WHERE bp.Billback_Product_ID IN (SELECT Billback_Product_ID FROM ##bb_consolidate WHERE Row = 1)
				
					/* Delete (logical) Billback_Product rows which were consolidated */
					UPDATE bp 
					SET Deleted = 1 	/* SELECT bp.Deleted, bp.*  */
					FROM Billback_product bp
					JOIN ##bb_consolidate bbc_delete
						ON bbc_delete.Billback_Product_ID = bp.Billback_Product_ID
						AND bbc_delete.Row > 1
			
					/*  update Billback_Product_Detail rows to reflect Billback_Product consolidation */
					UPDATE bpd 
					SET	Billback_Product_ID = bbc_survivor.Billback_Product_ID
					-- SELECT bpd.Billback_Product_ID, bbc_survivor.Billback_Product_ID, bbc.Row
					FROM Billback_product_Detail bpd
					JOIN ##bb_consolidate bbc
						ON bbc.Billback_Product_ID = bpd.Billback_Product_ID
						AND bbc.Row > 1
					JOIN ##bb_consolidate bbc_survivor
						ON bbc_survivor.Billback_Program_ID = bbc.Billback_Program_ID
						AND bbc_survivor.Distributor_id = bbc.Distributor_id
						AND bbc_survivor.Product_ID = bbc.Product_ID
						AND bbc_survivor.Row = 1
					WHERE bpd.Deleted = 0
					AND		 bbc.cnt>1
			
					/*  update BB_Item_Invoice_Level rows to reflect Billback_Product consolidation */
                    UPDATE bil 
                    SET    Billback_Product_ID = bbc_survivor.Billback_Product_ID
	                    /* SELECT bil.Billback_Product_ID, bbc_survivor.Billback_Product_ID, bbc.Row */
                    	FROM BB_Item_Invoice_Level bil
                    JOIN ##bb_consolidate bbc
                        ON bbc.Billback_Product_ID = bil.Billback_Product_ID
                        AND bbc.Row > 1
                    JOIN ##bb_consolidate bbc_survivor
                        ON bbc_survivor.Billback_Program_ID = bbc.Billback_Program_ID
                        AND bbc_survivor.Distributor_id = bbc.Distributor_id
	                    AND bbc_survivor.Product_ID = bbc.Product_ID
	                    AND bbc_survivor.Row = 1
                    WHERE bil.Deleted = 0
					AND 	bbc.cnt > 1
			
					/*  consolidate Billback_Product_Detail BB_rate */
					IF OBJECT_ID('tempdb..##tmp_BPD_Concolidate') IS NOT NULL
					DROP TABLE ##tmp_BPD_Concolidate
				
					SELECT bpd.Billback_ID
						, bpd.Billback_Product_ID
						, bpd.BB_Product_Type_ID
						, bpd.Distributor_ID_Earned
						, Consolidated_Amt = SUM(bpd.BB_Rate)
						, Survivor_ID = MIN(CAST(bpd.Billback_Product_Detail_ID AS VARCHAR(50)))
					INTO ##tmp_BPD_Concolidate
					FROM Billback_product_Detail bpd
					JOIN ##bb_consolidate bbc
						ON bbc.Billback_Product_ID = bpd.Billback_Product_ID
					WHERE	bpd.Deleted = 0
					and		bbc.cnt>1
					GROUP BY  bpd.Billback_ID,bpd.Billback_Product_ID, bpd.BB_Product_Type_ID, bpd.Distributor_ID_Earned
			
				
					UPDATE bbd SET BB_Rate = bbdc.Consolidated_Amt
					/*  SELECT bbd.Billback_Product_ID, bbd.BB_Product_Type_ID, bbd.Distributor_ID_Earned, bbd.BB_Rate, bbdc.Consolidated_Amt */
					FROM Billback_product_Detail bbd
					JOIN ##tmp_BPD_Concolidate bbdc
						ON bbdc.Survivor_ID = bbd.Billback_Product_Detail_ID
					WHERE bbd.Deleted = 0
				
					/* Delete (logical) Billback_Product_Detail rows which were consolidated */
					UPDATE bpd
					SET Deleted = 1 /* SELECT bpd.Deleted, bpd.* */
					FROM Billback_product_Detail bpd
					JOIN ##tmp_BPD_Concolidate bbc_delete
						ON bbc_delete.Billback_Product_ID = bpd.Billback_Product_ID
						AND bbc_delete.BB_Product_Type_ID = bpd.BB_Product_Type_ID
						AND bbc_delete.Distributor_ID_Earned = bpd.Distributor_ID_Earned
						AND bbc_delete.Survivor_ID != bpd.Billback_Product_Detail_ID
				
			END 
		</cfquery>	
		<cfquery name="GetRecordsToUpdate" datasource="#application.datasource#">
			SELECT Count(BB_Product_Type_ID),
			      Billback_Product.Billback_Product_ID,  BB_Product_Type_ID, SUM(cast(BB_Rate as float)) AS NewSum, Distributor_ID_Earned
			 FROM
			      Billback_Product_Detail
			 INNER JOIN
			      Billback_Product
			      ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
			      AND Billback_Product.Deleted = 0
			WHERE Billback_Product.Billback_ID = '#FORM.Billback_ID#'
			      AND Billback_Product_Detail.Deleted = 0
			 GROUP BY
			      Billback_Product.Billback_Product_ID, BB_Product_Type_ID, Distributor_ID_Earned
			 HAVING Count(BB_Product_Type_ID) > 1
		  </cfquery>

		   <cfloop query="GetRecordsToUpdate">

		   	<cfset useLakebaseForGetBillbackProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product")>
<cfif useLakebaseForGetBillbackProduct>
	<cftry>
		<cfset GetBillbackProduct = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_product", {
				"billback_id" = "eq.#FORM.Billback_ID#",
				"deleted" = "eq.0",
				"product_id" = "eq.#GetRecordsToUpdate.Billback_Product_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBillbackProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBillbackProduct>
<cfquery name="GetBillbackProduct" datasource="#application.datasource#">
			SELECT * FROM Billback_Product
			WHERE Billback_Product.Billback_ID = '#FORM.Billback_ID#'
	    	AND Deleted = 0
	   		AND Product_ID = '#GetRecordsToUpdate.Billback_Product_ID#'
			</cfquery>
</cfif>

		   <!--- Delete old record --->

		    <cfset useLakebaseForDeletetheDuplicates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product_detail")>
<cfif useLakebaseForDeletetheDuplicates>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_product_detail",
			{
				"billback_id" = "eq.#FORM.Billback_ID#",
				"billback_product_id" = "eq.#GetRecordsToUpdate.Billback_Product_ID#",
				"bb_product_type_id" = "eq.#GetRecordsToUpdate.BB_Product_Type_ID#",
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeletetheDuplicates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeletetheDuplicates>
<cfquery name="DeletetheDuplicates" datasource="#application.datasource#">
			   UPDATE Billback_Product_Detail
			   SET Deleted = 1
			   WHERE Billback_ID = '#FORM.Billback_ID#'
			   AND Billback_Product_ID = '#GetRecordsToUpdate.Billback_Product_ID#'
			   AND BB_Product_Type_ID = '#GetRecordsToUpdate.BB_Product_Type_ID#'
			   AND Deleted = 0
		   </cfquery>
</cfif>

		   	<!--- Insert new record --->
			<cfquery name="InsertNewSummedRecord" datasource="#application.datasource#">
				INSERT INTO Billback_Product_Detail
				(
					Billback_Product_ID,
					Billback_ID,
					BB_Product_Type_ID,
					BB_Rate,
					Distributor_ID_Earned
				)
				VALUES
				(
					'#GetRecordsToUpdate.Billback_Product_ID#',
					'#FORM.Billback_ID#',
					'#GetRecordsToUpdate.BB_Product_Type_ID#',
					'#GetRecordsToUpdate.NewSum#',
					'#GetRecordsToUpdate.Distributor_ID_Earned#'
				)
			</cfquery>
		   </cfloop>		
		<!--- 
			END:104331 - Billback did not consolidate with associated shipto on change/Anand Rao/18-Mar-2021 
			CONSOLIDATION CODE 
		--->
</CFIF>

<!--- D30517: Item not appearing on Billback 'programs' page after importing it END --->							
				
<!--- 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] /Anand/19-Jun-2018 --->
<cfif (appSettings.get_Setting('BB_Display_Dist_Channel_Per_Program_Distributor'))>
	<cfquery name="qInsBB_DC" datasource="#Application.Datasource#">
		EXEC Billback_Distribution_Channel_Insert '#FORM.Billback_ID#'
	</cfquery>
</cfif>
						
							
<cfparam name="alertName" default="">
<cfparam name="message" default="">
<cfif trim(alertList) neq "" and trim(alertList) neq "00000000-0000-0000-0000-000000000000"><!---send alert that a distributor could not be deleted--->
	<cfset qalert = billbackSummaryManager.getdistributorInfo(alertList)>
	<cfset temp = billbackSummaryManager.removeDistributorProducts(alertList,FORM.Billback_ID)>
	<cfloop query="qalert">
		<cfset alertName = alertname & trim(qalert.name) & " (" & qalert.ship_To & ")\n">
	</cfloop>
	<cfif qalert.recordcount gt 1>
		<cfset message = "Were Removed.  This action also Removed the products associated with these distributor.">
	<cfelse>
		<cfset message = "Was Removed.  This action also Removed the products associated with this distributor.">
	</cfif>
</cfif>

<!--- D22543 - Prevent updates while deviation Run all is in progress - Grid could cause this issue as it opens in popup --->

<CFPARAM NAME="In_Progress_Check_BBID" default="">
<CFPARAM NAME="PageName_InProgress" default="">
<CFPARAM NAME="Progress_Type" default="0">

<CFSET In_Progress_Check_BBID = FORM.Billback_ID>
<CFSET PageName_InProgress = "Payee">
<CFSET Progress_Type = 2>	
<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">

<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js">
<script>
	<cfif trim(alertList) neq "" and trim(alertList) neq "00000000-0000-0000-0000-000000000000">
		<cfoutput>alert("#alertName# #message#");</cfoutput>
	</cfif>
	<cfif form.modifyagreeacttion EQ 0>
	callfireEvent(window.parent.document,window.parent.programs_tab,'Click');
	<cfelse>
	callfireEvent(window.parent.document,window.parent.programs_tab,'Click');
	</cfif>
</script>