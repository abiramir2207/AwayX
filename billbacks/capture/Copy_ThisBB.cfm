<!---
	Name: Copy_ThisBB        
	Copyright (c) 2006 Blacksmith Applications, Inc.
	Description:
		This page is responsible for copying billbacks. Is call from the basic information page. 
--->	
<cfparam name="URL.copyAssocOperator"	default="" />
<cfparam name="URL.copyAttachments"	default="0" />

<cfinclude template="billback_number_generator.cfm">
<CFSET NextBB_Code = generator_billback_number>

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
<CFQUERY NAME="getThisUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.User_ID#' AND User_Position_Type = 'P' AND  DELETED = 0
</CFQUERY>
</cfif>
<CFSET This_User_Position_ID = getThisUserPosition.User_Positions_ID>


<cfset useLakebaseForUpdateLock = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForUpdateLock>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_allied",
			{
				"billback_id" = "eq.#BBID#",
				"bb_locked_by_user_id" = "eq.#request.AccessStructure.User_ID#",
				"bb_locked_by_match_central" = "eq.0"
			},
			{
				"bb_is_locked" = "0",
				"bb_locked_by_user_id" = javaCast("null",""),
				"bb_lock_date" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateLock = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateLock>
<CFQUERY NAME="UpdateLock" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Allied 
	SET 	BB_Is_Locked = 0,
			BB_Locked_By_User_ID = NULL,
			BB_Lock_Date = NULL
	WHERE 	Billback_id = '#BBID#' AND 
			BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
		AND BB_Locked_By_Match_Central = 0
</CFQUERY>
</cfif>
 
 <!--- Dev Note: Clay 9710 - Add Expected Amount to BB Copy   --->
<CFQUERY NAME="InsertNewBB" DATASOURCE="#Application.Datasource#">
	INSERT INTO 
	Billback	(	BB_Title,									
					BB_Creator_Notes,					
					Comments,					
					Billback_Payee_Type_ID,
					BB_UP,
					BB_PNF,
					BB_CREATOR_ID,
					BB_CREATOR_User_Position_ID,					
					BB_Code,
					BB_Date,
					Billback_Status_ID,
					CopiedBB,
					Original_BB_Code,
					BB_Amount,
					Analyst_User_ID,
					BB_Closing_Method,
					Vendor_Only_Billback
							)
	
	SELECT 			BB_Title,
					BB_Creator_Notes,
					Comments,
					Billback_Payee_Type_ID,
					BB_UP,
					BB_PNF,
					'#request.AccessStructure.User_ID#',
					#getThisUserPosition.User_Positions_ID#,					
					'#NextBB_Code#-00',
					getdate(),
					1,
					'#BBID#',
					'#NextBB_Code#',
					BB_Amount,
					Analyst_User_ID,
					BB_Closing_Method,
					Vendor_Only_Billback
					
	FROM			Billback
	WHERE			Billback_ID = '#BBID#'	 
</CFQUERY>

<CFSET BillbackID = InsertNewBB.billback_id>

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Copy Payee Information --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

<!--- 
	50865: Billback copy function not transferring operator info to new billback/Anand Rao/15-Jun-2015
	If the existing BB has Associated Operator(s) and the Uploaded billback value is 2 or 3, then display a message box to the user.      
	Do you want to also copy over the Associated Operator information?   Yes / No      
	If user clicks YES, then we should carry forward the Associated Operator information.    
	If user clicks NO, then we should not carry forward the Associated Operator information.
--->

<cfif (isDefined("URL.copyAssocOperator") AND URL.copyAssocOperator EQ 1)>
	<cfquery name="InsertPayee" datasource="#Application.Datasource#">		
		INSERT INTO Billback_Assoc_Operator
			(Billback_ID, Operator_ID, Operator_Legacy_ID, Operator_Name, Created_date)
		SELECT	'#BillbackID#', Operator_ID, Operator_Legacy_ID, Operator_Name,getDate()
		FROM	Billback_Assoc_Operator
		WHERE	Billback_ID = '#BBID#'
		AND Deleted = 0
	</cfquery>
</cfif>

<cfset useLakebaseForGetPayeeType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForGetPayeeType>
	<cftry>
		<cfset GetPayeeType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#BBID#",
				"select" = "billback_payee_type_id"
			}), "billback_payee_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPayeeType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPayeeType>
<CFQUERY NAME="GetPayeeType" DATASOURCE="#Application.Datasource#">
	SELECT Billback_Payee_Type_ID FROM Billback WHERE Billback_ID = '#BBID#'
</CFQUERY>
</cfif>

<CFIF GetPayeeType.Billback_Payee_Type_ID EQ 1 OR GetPayeeType.Billback_Payee_Type_ID EQ 5>
	<cfset useLakebaseForCheckPayee = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor")>
<cfif useLakebaseForCheckPayee>
	<cftry>
		<cfset CheckPayee = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor", {
				"billback_id" = "eq.#BBID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckPayee = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckPayee>
<CFQUERY NAME="CheckPayee" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback_Distributor WHERE Billback_ID = '#BBID#' AND Deleted = 0
	</CFQUERY>
</cfif>
	<CFIF CheckPayee.RecordCount GT 0>
		
		
		<CFQUERY NAME="InsertPayee" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			Billback_Distributor	(	Distributor_ID,
										BB_Distributor_Ship_To,
										BB_Distributor_Name,
										BB_Distributor_Address1,
										BB_Distributor_Address2,
										BB_Distributor_City,
										BB_Distributor_State,
										BB_Distributor_Zipcode,
										BB_Distributor_Phone,
										BB_Distributor_Phone_Extn,
										BB_Distributor_Fax,
										BB_Distributor_Notes,
										Billback_ID,
										Uploaded_Vendor_ID
														)
										
			SELECT DISTINCT 			Distributor_ID,
										BB_Distributor_Ship_To,
										BB_Distributor_Name,
										BB_Distributor_Address1,
										BB_Distributor_Address2,
										BB_Distributor_City,
										BB_Distributor_State,
										BB_Distributor_Zipcode,
										BB_Distributor_Phone,
										BB_Distributor_Phone_Extn,
										BB_Distributor_Fax,
										BB_Distributor_Notes,
										'#BillbackID#',
										Uploaded_Vendor_ID		
											
			FROM 						Billback_Distributor
			
			WHERE						Billback_ID = '#BBID#' AND 
										Deleted = 0
		</CFQUERY>
	</CFIF>
<CFELSEIF GetPayeeType.Billback_Payee_Type_ID EQ 2 OR GetPayeeType.Billback_Payee_Type_ID EQ 6>
	<CFQUERY NAME="CheckPayee" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback_Operator WHERE Billback_ID = '#BBID#' AND Deleted = 0
	</CFQUERY>
	<CFIF CheckPayee.RecordCount GT 0>
		<!--- Dev Note: Clay 9710; Add Associated_Ship_to BB copy  --->	
		<CFQUERY NAME="InsertPayee" DATASOURCE="#Application.Datasource#">
			INSERT INTO	
			Billback_Operator	(	Operator_ID,
									BB_Operator_Name,
									BB_Operator_Address1,
									BB_Operator_Address2,
									BB_Operator_City,
									BB_Operator_State,
									BB_Operator_Zipcode,
									BB_Operator_Phone,
									BB_Operator_Phone_Extn,
									BB_Operator_Fax,
									BB_Operator_Notes,
									Associated_Ship_To,
									Billback_ID		)
			
			SELECT 					Operator_ID,
									BB_Operator_Name,
									BB_Operator_Address1,
									BB_Operator_Address2,
									BB_Operator_City,
									BB_Operator_State,
									BB_Operator_Zipcode,
									BB_Operator_Phone,
									BB_Operator_Phone_Extn,
									BB_Operator_Fax,
									BB_Operator_Notes,
									Associated_Ship_To,
									'#BillbackID#'		
											
			FROM 					Billback_Operator
			
			WHERE					Billback_ID = '#BBID#' AND 
									Deleted = 0
		</CFQUERY>
	</CFIF>
<CFELSEIF GetPayeeType.Billback_Payee_Type_ID EQ 3 OR GetPayeeType.Billback_Payee_Type_ID EQ 7>
	<CFQUERY NAME="CheckPayee" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback_Broker WHERE Billback_ID = '#BBID#' AND Deleted = 0
	</CFQUERY>
	<CFIF CheckPayee.RecordCount GT 0>
		<CFQUERY NAME="InsertPayee" DATASOURCE="#Application.Datasource#">
			INSERT INTO	
			Billback_Broker	(	Broker_ID,
								BB_Broker_Shared,
								BB_Broker_Name,
								BB_Broker_Address1,
								BB_Broker_Address2,
								BB_Broker_City,
								BB_Broker_State,
								BB_Broker_Zipcode,
								BB_Broker_Phone,
								BB_Broker_Phone_Extn,
								BB_Broker_Fax,
								BB_Broker_Notes,
								Associated_Ship_To,
								Billback_ID		)
			
			SELECT 				Broker_ID,
								BB_Broker_Shared,
								BB_Broker_Name,
								BB_Broker_Address1,
								BB_Broker_Address2,
								BB_Broker_City,
								BB_Broker_State,
								BB_Broker_Zipcode,
								BB_Broker_Phone,
								BB_Broker_Phone_Extn,
								BB_Broker_Fax,
								BB_Broker_Notes,
								Associated_Ship_To,
								'#BillbackID#'		
											
			FROM 				Billback_Broker
			
			WHERE				Billback_ID = '#BBID#' AND 
								Deleted = 0
		</CFQUERY>
	</CFIF>
<CFELSEIF GetPayeeType.Billback_Payee_Type_ID EQ 4>
	<CFQUERY NAME="CheckPayee" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback_Unidentified_Payee WHERE Billback_ID = '#BBID#' AND Deleted = 0
	</CFQUERY>
	<CFIF CheckPayee.RecordCount GT 0>
		<CFQUERY NAME="InsertPayee" DATASOURCE="#Application.Datasource#">
			INSERT INTO
			Billback_Unidentified_Payee	(	BB_UP_Name,
											BB_UP_Address1,
											BB_UP_Address2,
											BB_UP_City,
											BB_UP_State,
											BB_UP_Zipcode,
											BB_UP_Phone,
											BB_UP_Phone_Extn,
											BB_UP_Fax,
											BB_UP_Notes,
											Billback_ID			)
											
			SELECT 							BB_UP_Name,
											BB_UP_Address1,
											BB_UP_Address2,
											BB_UP_City,
											BB_UP_State,
											BB_UP_Zipcode,
											BB_UP_Phone,
											BB_UP_Phone_Extn,
											BB_UP_Fax,
											BB_UP_Notes,
											'#BillbackID#'
											
			FROM							Billback_Unidentified_Payee
			
			WHERE 							Billback_ID = '#BBID#' AND 
											Deleted = 0
			
		</CFQUERY>
	</CFIF>
</CFIF>

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Copy Billback_Distributor_List Information --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFQUERY NAME="DistList" DATASOURCE="#Application.Datasource#">
INSERT INTO 
Billback_Distributor_List (	BillBack_Id,
							Distributor_Id,
							Is_Group,
							Captured_From_Group
							)
SELECT 					'#BillbackID#',
						Distributor_ID,
						Is_Group,
						Captured_From_Group
								
FROM					Billback_Distributor_List					
						
WHERE 					Billback_ID = '#BBID#' AND 
						Deleted = 0
</CFQUERY>
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- End Copy Billback_Distributor_List Information --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->


<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Copy Program Information --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<cfset useLakebaseForCheckProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForCheckProgram>
	<cftry>
		<cfset CheckProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_id" = "eq.#BBID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckProgram>
<CFQUERY NAME="CheckProgram" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback_Program WHERE Billback_ID = '#BBID#' AND Deleted = 0
</CFQUERY>
</cfif>

<CFIF CheckProgram.RecordCount GT 0>
	
	
		<!--- In case it's an old program that doesn't have a discount list we need to construct it --->
	<cfif len(trim(CheckProgram.Discount_List)) IS 0>
		<cfloop query="CheckProgram">
		<cfquery name="GetDiscountsfromBillback" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT 	DISTINCT BB_Product_Type_ID 
			FROM 		Billback_Product_Detail
			INNER JOIN 	Billback_Product ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID AND 
						Billback_Product.Deleted = 0
			INNER JOIN 	Billback_Program ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID AND 
						Billback_Program.Program_ID = '#CheckProgram.Program_ID#'
			WHERE 		Billback_Product_Detail.Billback_ID = '#BBID#' AND 
						Billback_Product_Detail.Deleted = 0
			ORDER BY 	BB_Product_Type_ID
		</cfquery> 
				<!--- If there's something returned, set that as the discount list --->
				<!--- Dev Notes: 12777 Ana --->
				<cfset DiscountList = VALUELIST(GetDiscountsfromBillback.BB_Product_Type_ID, ',')>
		
		<cfif 	len(trim(DiscountList)) GT 0>
			<cfset useLakebaseForUpdateDiscountList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForUpdateDiscountList>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_program",
			{
				"program_id" = "eq.#CheckProgram.Program_ID#"
			},
			{
				"discount_list" = "#DiscountList#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateDiscountList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDiscountList>
<cfquery name="UpdateDiscountList" datasource="#application.datasource#">
			UPDATE Billback_Program
			SET Discount_List = '#DiscountList#'
			WHERE Billback_Program.Program_ID = '#CheckProgram.Program_ID#'
			</cfquery>
</cfif>
		</cfif>
				
		</cfloop>
	</cfif>
	
	<CFQUERY NAME="InsertProgram" DATASOURCE="#Application.Datasource#">
		INSERT INTO 
		Billback_Program	(	Program_ID,
								BB_Program_Number,
								BB_Program_Title,
								BB_Program_Notes,
								Billback_ID,
								Discount_List	)
								
		SELECT 					Program_ID,
								BB_Program_Number,
								BB_Program_Title,
								BB_Program_Notes,
								'#BillbackID#',
								Discount_List
								
		FROM					Billback_Program					
								
		WHERE 					Billback_ID = '#BBID#' AND 
								Deleted = 0
	</CFQUERY>		
</CFIF>

<CFQUERY NAME="SelectProg" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback_Program WHERE Billback_ID = '#BillbackID#' AND Deleted = 0
</CFQUERY>


<CFLOOP QUERY="SelectProg">

	<CFSET InsProgramID = SelectProg.Billback_Program_ID>
	<CFSET ProgramID = SelectProg.Program_ID>

	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<!--- Copy Product Information --->
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<CFQUERY NAME="CheckProduct" DATASOURCE="#Application.Datasource#">
		SELECT 	* 
		FROM 	Billback_Product 
		WHERE 	Billback_ID = '#BBID#' AND 
				Billback_Program_ID = (	SELECT 	Billback_Program_ID 
										FROM 	Billback_Program 
										WHERE 	Billback_ID = '#BBID#' AND 
												Program_ID = '#Program_ID#' AND 
												Deleted = 0	)	AND 
				Deleted = 0
	</CFQUERY>
	
	<CFIF CheckProduct.RecordCOunt GT 0>
		<CFQUERY NAME="InsertProd" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			Billback_Product	(	Product_ID,
									Billback_Program_ID,
									BB_Product_Category_ID,
									BB_Unknown_Product_Item_Number,
									BB_Unknown_Product_Description,
									BB_Unknown_Product_Notes,
									Product_Type_ID,
									Billback_ID,
									Distributor_Id,
									BB_Product_Quantity,
									BB_Product_UOM,
									Count_Flag,
									Actual_Count_Flag,
									Operator_ID
			)
									
			SELECT 					Product_ID,
									'#InsProgramID#',
									BB_Product_Category_ID,
									BB_Unknown_Product_Item_Number,
									BB_Unknown_Product_Description,
									BB_Unknown_Product_Notes,
									Product_Type_ID,
									'#BillbackID#',
									Distributor_Id,
									BB_Product_Quantity,
									BB_Product_UOM,
									Count_Flag,
									Actual_Count_Flag,
									Operator_ID	
									
			FROM 					Billback_Product
			
			WHERE 					Billback_ID = '#BBID#' AND 
									Billback_Program_ID = (	SELECT 	Billback_Program_ID 
															FROM 	Billback_Program 
															WHERE 	Billback_ID = '#BBID#' AND 
																	Program_ID = '#Program_ID#' AND 
																	Deleted = 0						) AND
									Deleted = 0
									
		</CFQUERY>

<!---76028 START--->
	<cfquery name="qChkBBIIL" datasource="#application.datasource#">	
		SELECT Count(*) AS RecCount FROM BB_Item_Invoice_Level WHERE Billback_ID = '#BBID#'
	</cfquery> 
		
	<cfif (qChkBBIIL.RecCount GTE 1 AND application.appSettingsGet.getViewOperatorinBillbackDeviation())>
		<CFQUERY NAME="InsertBBItemInvoice" DATASOURCE="#Application.Datasource#">
			INSERT INTO   BB_Item_Invoice_Level (      
			                     Billback_ID
			                     ,Program_ID
			                     ,Billback_Program_ID
			                     ,Billback_Product_ID
			                     ,Distributor_ID,Product_ID
			                     ,Discount_Type_ID
			                     ,Claimed_CS,Claimed_LB
			                     ,Invoice_Price_CS,Program_Price_CS
			                     ,Claimed_Rate_CS,Claimed_Amt
			                     ,Uploaded_Billback
			                     ,Item, Operator_ID
			                     )
			SELECT 
				newBP.Billback_ID, 
				'#ProgramID#' as Program_ID, 
				newBP.Billback_Program_ID, 
				newBP.Billback_Product_ID,
				BB_Item_Invoice_Level.Distributor_ID, BB_Item_Invoice_Level.Product_ID, 
				BB_Item_Invoice_Level.Discount_Type_ID,
				BB_Item_Invoice_Level.Claimed_CS, BB_Item_Invoice_Level.Claimed_LB,
				BB_Item_Invoice_Level.Invoice_Price_CS, BB_Item_Invoice_Level.Program_Price_CS,
				BB_Item_Invoice_Level.Claimed_Rate_CS, BB_Item_Invoice_Level.Claimed_Amt, 
				BB_Item_Invoice_Level.Uploaded_Billback,
				BB_Item_Invoice_Level.Item, BB_Item_Invoice_Level.Operator_ID
			FROM Billback_Program as originalBPG
			INNER JOIN BB_Item_Invoice_Level
			ON            BB_Item_Invoice_Level.Billback_Program_ID = originalBPG.Billback_Program_ID
			AND           BB_Item_Invoice_Level.Deleted = 0
			INNER JOIN Billback_Product originalBP
			ON            originalBP.Billback_ID = originalBPG.Billback_ID
			AND           originalBP.Billback_Program_ID = originalBPG.Billback_Program_ID
			AND           originalBP.Billback_Product_ID = BB_Item_Invoice_Level.Billback_Product_ID
			AND           originalBP.Deleted = 0
			INNER JOIN Billback_Product newBP
			ON            newBP.Billback_ID = '#BillbackID#'
			AND           newBP.Billback_Program_ID = '#InsProgramID#'
			AND           newBP.Product_ID = originalBP.Product_ID
			AND           newBP.Distributor_id = originalBP.Distributor_id
			AND           ISNULL(newBP.Operator_ID, 0) = ISNULL(originalBP.Operator_ID, 0)
			AND           newBP.Deleted = 0
			WHERE  originalBPG.Billback_ID = '#BBID#'
			AND           originalBPG.Program_ID = '#Program_ID#' 
			AND           originalBPG.Deleted = 0
		</CFQUERY>
	</cfif>
<!---76028 END--->		
		<CFQUERY NAME="CheckDetail" DATASOURCE="#Application.Datasource#">
			SELECT 	DISTINCT Billback_Product_Detail.Billback_Product_ID, Billback_Product.Product_ID, Billback_Product_Detail.Distributor_Id_Earned
			FROM 	Billback_Product_Detail 
				INNER JOIN Billback_Product
				ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
				AND BIllback_Product.Deleted = 0
				INNER JOIN Billback_Program
				ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
				AND Billback_Program.Deleted = 0
				AND Billback_Program.Program_ID = '#Program_ID#'
				AND Billback_Program.Billback_ID = '#BBID#'
			WHERE 	Billback_Product_Detail.Billback_ID = '#BBID#'														
			AND		Billback_Product_Detail.Deleted = 0
			AND		Billback_Product.Product_ID IS NOT NULL <!--- BJF: You cannot copy over unknown items --->
		</CFQUERY>
		<CFIF CheckDetail.RecordCount GT 0>
			
			<!--- Copy over discount list --->
			<cfquery name="GetDistinctProductsfromProgram" dbtype="query">
			SELECT DISTINCT Product_ID
			FROM CheckDetail
			</cfquery>
			
			<cfset ProgramIDforloop = Program_ID>
			<cfloop query="GetDistinctProductsfromProgram">
				
				<CFQUERY NAME="InsertDiscountList" DATASOURCE="#Application.Datasource#">
					INSERT INTO 
					BB_Product_Discount	(		Discount_List,
												Product_ID,
												Program_ID,
												Billback_ID			)
												
					SELECT 						Discount_List,
												'#GetDistinctProductsfromProgram.Product_ID#',
												'#ProgramIDforloop#',
												'#BillbackID#'
					FROM						BB_Product_Discount
					WHERE 						Billback_ID = '#BBID#' AND 
												Product_ID = '#GetDistinctProductsfromProgram.Product_ID#' 
				</CFQUERY>
			</cfloop>
			<!--- end discount list copy --->
			
			<CFLOOP QUERY="CheckDetail">
				<CFQUERY NAME="BBProductID" DATASOURCE="#Application.Datasource#">
					<!------ D10217: when it is an unknown product Product_ID = NULL (NULL = NULL) will always return false ----->
					DECLARE @Product_ID uniqueidentifier,
							@BB_Unknown_Product_Item_Number nvarchar(255),
							@BB_Unknown_Product_Description nvarchar(255),
							@BB_Unknown_Product_Notes nvarchar(255),
							@Product_Type_ID Int
						
					-- First get the information from the parent records
					SELECT 	@Product_ID = Product_ID ,
							@BB_Unknown_Product_Item_Number = BB_Unknown_Product_Item_Number,
							@BB_Unknown_Product_Description = BB_Unknown_Product_Description,
							@BB_Unknown_Product_Notes = BB_Unknown_Product_Notes,
							@Product_Type_ID = Product_Type_ID
					FROM 	Billback_Product
					WHERE	Billback_ID = '#BBID#' 
					AND	Billback_Product_ID = '#CheckDetail.Billback_Product_ID#'
					AND	Deleted = 0
					
					-- if product id is not null, do the regular way
					IF @Product_ID IS NOT NULL
					BEGIN
						SELECT 	* 
						FROM 	Billback_Product
						WHERE 	Billback_ID = '#BillbackID#'
						AND	Billback_Program_ID = '#InsProgramID#'
						AND	Deleted = 0 
						<cfif len(trim(CheckDetail.Distributor_Id_Earned)) GT 0>
						AND	Distributor_Id 	= '#CheckDetail.Distributor_Id_Earned#'
						</cfif>
						AND	Product_ID = @Product_ID
					END
					ELSE -- if product id is null, we have to match on item number, name etc., will be problem if there are 2 products with all same properties
					BEGIN
						SELECT 	* 
						FROM 	Billback_Product
						WHERE 	Billback_ID = '#BillbackID#'
						AND	Billback_Program_ID = '#InsProgramID#'
						AND	Deleted = 0 
						<cfif len(trim(CheckDetail.Distributor_Id_Earned)) GT 0>
						AND	Distributor_Id 	= '#CheckDetail.Distributor_Id_Earned#'
						</cfif>
						AND	@BB_Unknown_Product_Item_Number = BB_Unknown_Product_Item_Number
						AND	@BB_Unknown_Product_Description = BB_Unknown_Product_Description
						AND	@BB_Unknown_Product_Notes = BB_Unknown_Product_Notes
						AND	@Product_Type_ID = Product_Type_ID
					END
			</CFQUERY>
			
			<!------ D10217: Billback_Product_ID should never be NULL, if it is null, there will be hanging detail records with no Billback_Product_ID  ----->
			
				<CFQUERY NAME="InsertDetails" DATASOURCE="#Application.Datasource#">
					INSERT INTO 
					Billback_Product_Detail	(	Billback_Product_ID,
												BB_Product_Type_ID,
												Billback_ID,
												Distributor_ID_Earned,
												BB_Rate			)
												
					SELECT 						'#BBProductID.Billback_Product_ID#',
												BB_Product_Type_ID,
												'#BillbackID#',
												Distributor_ID_Earned,
												BB_Rate

												
					FROM						Billback_Product_Detail
					
					WHERE 						Billback_ID = '#BBID#' 
												AND Billback_Product_ID = '#CheckDetail.Billback_Product_ID#'
												AND Deleted = 0
				</CFQUERY>
												
			</CFLOOP>			
		</CFIF>
	</CFIF>
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

	
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<!--- Copy Lumpsum Information --->
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<cfset useLakebaseForCheckLump = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program_lumpsum_component")>
<cfif useLakebaseForCheckLump>
	<cftry>
		<cfset CheckLump = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program_lumpsum_component", {
				"billback_id" = "eq.#BBID#",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckLump = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckLump>
<CFQUERY NAME="CheckLump" DATASOURCE="#Application.Datasource#">
		SELECT Top 1 * FROM Billback_Program_Lumpsum_Component WHERE Billback_ID = '#BBID#' AND Deleted = 0
	</CFQUERY>
</cfif>
	
	<CFIF CheckLump.RecordCount GT 0>
		<CFQUERY NAME="InsertLump" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			Billback_Program_Lumpsum_Component	(	Billback_Program_ID,
													Component_Type_ID,
													Program_Lump_Sum_ID,
													Program_Growth_Component_Tier_ID,
													Name,
													Billback_ID	,
													Amount			)
													
			SELECT 									'#InsProgramID#',
													Component_Type_ID,
													Program_Lump_Sum_ID,
													Program_Growth_Component_Tier_ID,
													Name,
													'#BillbackID#',
													Amount
													
			FROM									Billback_Program_Lumpsum_Component
			INNER JOIN					Billback_Program
			ON									Billback_Program_Lumpsum_Component.Billback_Program_ID = Billback_Program.Billback_Program_ID
			WHERE 							Billback_Program_Lumpsum_Component.Billback_ID = '#BBID#' 
			AND									Billback_Program.Program_ID = '#ProgramID#'
			AND									Billback_Program_Lumpsum_Component.Deleted = 0
		</CFQUERY>
	</CFIF>	
		
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<!--- Copy Rebate Component Information --->
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<cfset useLakebaseForCheckRebate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program_rebate_component")>
<cfif useLakebaseForCheckRebate>
	<cftry>
		<cfset CheckRebate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program_rebate_component", {
				"billback_id" = "eq.#BBID#",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckRebate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckRebate>
<CFQUERY NAME="CheckRebate" DATASOURCE="#Application.Datasource#">
		SELECT Top 1 * FROM Billback_Program_Rebate_Component WHERE Billback_ID = '#BBID#' AND Deleted = 0
	</CFQUERY>
</cfif>
	
	<CFIF CheckRebate.RecordCount GT 0>
		<CFQUERY NAME="InsertRebate" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			Billback_Program_Rebate_Component	(	Billback_Program_ID,
													Program_Rebates_Component_Name,
													Program_Rebates_Component_Name_ID,
													Program_Rebates_Component_ID,
													Checked,
													Billback_ID
																	)
													
			SELECT 									'#ProgramID#',
													Program_Rebates_Component_Name,
													Program_Rebates_Component_Name_ID,
													Program_Rebates_Component_ID,
													Checked,
													'#BillbackID#'
													
			FROM									Billback_Program_Rebate_Component
				
			WHERE 									Billback_ID = '#BBID#'  
			AND									Billback_Program_ID = '#ProgramID#'
			AND										Deleted = 0
		</CFQUERY>
	</CFIF>	
		
	<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
</CFLOOP>

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Copy attachments --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFIF URL.copyAttachments EQ 1>
	<CFQUERY NAME="CheckAttachments" DATASOURCE="#Application.Datasource#">
		SELECT Top 1 * FROM Contract_Attachments WHERE Billback_ID = '#BBID#' AND Deleted = 0
	</CFQUERY>

	<CFIF CheckAttachments.RecordCount GT 0>	
		<CFQUERY NAME="InsertAttachments" DATASOURCE="#Application.Datasource#">
			INSERT INTO Contract_Attachments(Billback_ID,doc_ID)

			SELECT '#BillbackID#',Doc_ID
			FROM Contract_Attachments
			WHERE Billback_ID = '#BBID#'
			AND deleted = 0
		</CFQUERY>
	</CFIF>
</CFIF>

<CFQUERY NAME="UpdateLock" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback_Allied 
	SET 	BB_Is_Locked = 1,
			BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#',
			BB_Lock_Date = getdate()
	WHERE 	Billback_id = '#BillbackID#' 
</CFQUERY>

<!--- 
	50616 - New Duplicate BB Logic/Anand Rao/17-Jun-2015
--->
<cfstoredproc procedure="BB_All_Dup_Group_Refresh" datasource="#application.datasource#">
 	<cfprocparam cfsqltype="CF_SQL_BIT" dbvarname="@@Full_Refresh" value="0" />
	<cfprocparam cfsqltype="CF_SQL_VARCHAR" dbvarname="@@Billback_ID" value="#BillbackID#" />
</cfstoredProc>

<CFLOCATION URL="/billbacks/capture/INDEX.CFM?BBID=#BillbackID#&CopiedClaim=1" ADDTOKEN="No">