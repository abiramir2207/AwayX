<cfset appSettings = application.appSettingsGet>
<cfset billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init() />
<cfparam name="DoNotReplace" default="0">
<cfparam name="ProductsToSwitch" default="">
<cfparam name="lsBBItemInvoiceLevelID" default="">
<cfparam name="FORM.FlexAppName" default="">
<!--- D41335 :: Prod Event 4555--->
<cfparam name="NewFixed" default="">
<cfif isDefined("URL.FlexAppName")>
	<cfset structInsert(FORM,"FlexAppName",URL.FlexAppName,true) />
</cfif>
<!--- Sometimes there is more than one new program -- not sure how but this will stop it from throwing errors --->
<cfif listlen(NewProgram) GT 1>
	<Cfset NewProgram = listfirst(NewProgram)>
</cfif>
<!--- D51977 :: START Billback enhancements for operator level data --->
<!--- Parse the form data --->
<cfscript>
	a = ListToArray(ProductsToSwitch);
	l = '';
	l2 = '';
	//writeoutput('<br>');
	//	writeoutput(Arraylen(a));
	for (i=1;i LTE ArrayLen(a);i=i+1) {
	//	writeoutput('<br>');
	//	writeoutput(listfirst(a[i],"|"));
		l = listappend(l,listfirst(a[i],"|"));
		l2 = listappend(l2,listLast(a[i],"|"));
	}
	ProductsToSwitch = l;
	lsBBItemInvoiceLevelID = l2;
</cfscript>
<!--- D51977 :: END Billback enhancements for operator level data --->
   <!---  <br><cfdump var = '#l2#'/><br>  <cfdump var = '#l#'/>  <cfabort>  --->
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dom_common.js, /script/javascript/fixed_popup.js, /Script/javascript/dhtml.js">

<!---Queries regarding this page --->
<cfset useLakebaseForgetPayeeInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetPayeeInfo>
	<cftry>
		<cfset getPayeeInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "billback_payee_type_id"
			}), "billback_payee_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetPayeeInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetPayeeInfo>
<cfquery name="getPayeeInfo" datasource="#Application.Datasource#">
	SELECT 	Billback_Payee_Type_ID
	FROM 	Billback
	WHERE 	Billback_ID = '#Billback_ID#'
</cfquery>
</cfif>
<!--- D51977 :: START Billback enhancements for operator level data --->
<cfif application.appSettingsGet.getViewOperatorinBillbackDeviation()>
	<cfquery name="GetItemsfromProgramOnBillback" datasource="#application.datasource#">
	SELECT 	Billback_Product.Billback_Product_ID,
			CASE WHEN BSA_Foodservice_Items_Master.Item IS NULL THEN
			'NA'
			ELSE
			BSA_Foodservice_Items_Master.Item
			END AS Item,
			CASE WHEN BSA_Foodservice_Items_Master.Item IS NULL THEN
			Billback_Product.BB_Unknown_Product_Description
			ELSE
			BSA_Foodservice_Items_Master.Description
			END AS Description,
			Billback_Program.Discount_List,
			Billback_Program.Billback_Program_ID,
			bil.Claimed_Amt,
			bil.Claimed_CS,
			bil.Claimed_LB,
			bil.BB_Item_Invoice_Level_ID,
			ISNULL(Billback_Product.Operator_ID,bil.Operator_ID) AS Operator_ID,
			ISNULL(Billback_Product.Operator_Legacy_ID,bo.Legacy_ID) AS Operator_Legacy_ID, 
			ISNULL(Billback_Product.Operator_Name,bo.Operator_Name) AS Operator_Name
		FROM Billback_Product
		INNER JOIN Billback_Program
			ON Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
		AND Billback_Program.Program_ID = '#Program_ID#'
		AND Billback_Program.Deleted = 0
		LEFT JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
	--	INNER JOIN Billback_Product_Detail
	--		ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID -- NOT NEEDED...Causes DUPE ROWS
		INNER JOIN bb_item_invoice_level bil ON		
			bil.billback_id = Billback_Program.billback_id AND
			bil.deleted = 0 AND
			bil.Product_ID = Billback_Product.product_id AND
			bil.Distributor_ID = Billback_Product.Distributor_id AND
			bil.Program_ID = Billback_Program.Program_ID  AND
			Bil.Billback_Product_ID = Billback_Product.Billback_Product_ID
	LEFT JOIN bsa_operator bo ON
		bo.bsa_operator_id = bil.operator_id
	WHERE Billback_Product.Deleted = 0
	AND Billback_Product.Billback_ID = '#Billback_ID#'
	ORDER BY Operator_Name, Operator_ID, BSA_Foodservice_Items_Master.Item
	</cfquery>
	<!--- D51977 :: END Billback enhancements for operator level data --->
<cfelse>
	<cfquery name="GetItemsfromProgramOnBillback" datasource="#application.datasource#">
	SELECT 	DISTINCT Billback_Product.Billback_Product_ID,
			CASE WHEN BSA_Foodservice_Items_Master.Item IS NULL THEN
			'NA'
			ELSE
			BSA_Foodservice_Items_Master.Item
			END AS Item,
			CASE WHEN BSA_Foodservice_Items_Master.Item IS NULL THEN
			Billback_Product.BB_Unknown_Product_Description
			ELSE
			BSA_Foodservice_Items_Master.Description
			END AS Description,
			Billback_Program.Discount_List,
			Billback_Program.Billback_Program_ID,
			0 as Claimed_Amt,
			0 as Claimed_CS,
			0 AS Claimed_LB,
			0 as BB_Item_Invoice_Level_ID,
			Billback_Product.Operator_ID,
			Operator_Legacy_ID, Operator_Name
		FROM Billback_Product
		INNER JOIN Billback_Program
		ON Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID
		AND Billback_Program.Program_ID = '#Program_ID#'
		AND Billback_Program.Deleted = 0
		LEFT JOIN BSA_Foodservice_Items_Master
		ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
		INNER JOIN Billback_Product_Detail
		ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
	WHERE Billback_Product.Deleted = 0
	AND Billback_Product.Billback_ID = '#Billback_ID#'
	ORDER BY Billback_Product.Operator_ID, Billback_Product.Operator_Name, Item
	</cfquery>
</cfif>

<cfif isDefined("blnSubmit")>
<!---
	23405: BB Deviations / Anand Rao
	Change recommended by Deepa
 --->

        
    <!--- Find out if a different version of the new program is already on the billback  --->
    <cfquery name="qGetNewProgramCMIDFromBB" datasource="#application.datasource#">
    DECLARE @Contract_Number NVARCHAR(20)
    SELECT  @Contract_Number = Contract_Number
    FROM    Contract_Main
    WHERE   Contract_Main_ID = '#NewProgram#'
        
    SELECT Billback_Program.Program_ID
    FROM Billback_Program
    INNER JOIN Contract_Main
    ON  Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
    WHERE Billback_Program.Billback_ID = '#Billback_ID#'
    AND Billback_Program.Program_ID != '#NewProgram#'
    AND Contract_Main.Contract_Number = @Contract_Number
    AND Billback_Program.Deleted = 0
    </cfquery>
    
    <cfif qGetNewProgramCMIDFromBB.RecordCount>
        <cfset NewProgram = qGetNewProgramCMIDFromBB.Program_ID />
    </cfif>
    
	<cfset useLakebaseForgetID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForgetID>
	<cftry>
		<cfset getID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"program_id" = "neq.#NewProgram#",
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0",
				"select" = "billback_program_id,discount_list"
			}), "billback_program_id,discount_list"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetID>
<cfquery name="getID" datasource="#application.datasource#">
		SELECT 	Billback_Program_ID, Discount_List
		FROM 	Billback_Program
		WHERE 	Program_ID = '#Program_ID#'
		AND 	Billback_ID = '#Billback_ID#'
		AND 	Deleted = 0
		AND		Program_ID <> '#NewProgram#'
	</cfquery>
</cfif>

	<cfif getID.recordCount EQ 0 or listlen(ProductsToSwitch) EQ 0>
		<!---
		Do not proceed.
		If user some how manage to switch Program 1 to Program 2 twice, when the second time the page is executed,
		above query will not return any records.
		In that case we do not want to do any update.
		This issue can happen also when user tried to switch Program 1 with program 1 itself
		--->
		<BR><BR><BR><BR>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD><B><FONT COLOR="Red" SIZE="2">
					Cannot switch program. Possible reasons are,<br> <br>
					- You have selected the same program for source and destination.<br>
					- The source program you have selected is no longer present in the billback.<br>
					- You have to select products to switch.</FONT></B></TD>
			</TR>
		</TABLE>
		<cfabort>
	</cfif>

<!--- D22543 - Prevent updates while deviation Run all is in progress - Grid could cause this issue as it opens in popup --->
<CFPARAM NAME="In_Progress_Check_BBID" default="">
<CFPARAM NAME="PageName_InProgress" default="">
<CFPARAM NAME="Progress_Type" default="0">

<CFSET In_Progress_Check_BBID = FORM.Billback_ID>
<CFSET PageName_InProgress = "Swtich Programs">
<CFSET Progress_Type = 1>
<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">

<cfset useLakebaseForClearDev = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForClearDev>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Billback_ID#"
			},
			{
				"deviation_ran_date" = javaCast("null",""),
				"auto_deviation_on" = javaCast("null",""),
				"deviation_ran_by" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForClearDev = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForClearDev>
<cfquery name="ClearDev" datasource="#application.datasource#">
	UPDATE 	Billback 
	SET 	Deviation_Ran_Date = NULL,
			Auto_Deviation_On = NULL,
			Deviation_Ran_By = NULL
	WHERE	Billback_ID = '#Billback_ID#'
</cfquery>
</cfif>

<cftransaction>
<CFSET LoadBillbackID = Billback_ID>
 <!--- Lump sums --->
<cfif LSList IS NOT 0>
<cfloop list="#LSList#" index="LSID">
<cfset LSFieldname = "LS_" & LSID>
<cfset NewLSID = evaluate(LSFieldname)>

	<cfif Left(NewLSID,1) IS "L">
	<!---Regular lump sum --->
		<cfset NewLSLength = len(NewLSID)>
		<cfset NewLSID = Right(NewLSID, NewLSLength-1)>
		<cfset NewLSID = replace(NewLSID, "_", "-", "all")>
		<cfset SAFELSID = replace(LSID, "_", "-", "all")>

		<cfquery name="UpdateLumpSums" datasource="#application.datasource#">
		UPDATE Billback_Program_Lumpsum_Component
		SET Program_Lump_Sum_ID = '#NewLSID#',
			Component_Type_ID = 1,
			Program_Growth_Component_Tier_ID = null
		WHERE Billback_Program_Lumpsum_Component_ID = '#SAFELSID#'
		</cfquery>

	<cfelseif  Left(NewLSID,1) IS "G">
	<!---Growth lump sum --->
		<cfset NewLSLength = len(NewLSID)>
		<cfset NewLSID = Right(NewLSID, NewLSLength -1)>
		<cfset SafeGrowthLS = replace(NewLSID, "_", "-", "all")>
		<cfset DividerPosition = find("*", NewLSID)>
		<cfset GrowthLSID = left(SafeGrowthLS, DividerPosition-1)>
		<cfset GrowthTierID = right(SafeGrowthLS, DividerPosition-1)>
		<cfset SAFELSID = replace(LSID, "_", "-", "all")>

		<cfquery name="UpdateGrowthLumpSums" datasource="#application.datasource#">
		UPDATE Billback_Program_Lumpsum_Component
		SET Program_Lump_Sum_ID = '#GrowthLSID#',
			Component_Type_ID = 3,
			Program_Growth_Component_Tier_ID = '#GrowthTierID#'
		WHERE Billback_Program_Lumpsum_Component_ID = '#SAFELSID#'
		</cfquery>

	<cfelseif NewLSID IS 0>
	<!--- If not transferring --->
	<cfset DoNotReplace =1>
	</cfif>

<!---Lump sums to move --->
</cfloop>
</cfif>

<!--- Regular discounts --->
	<cfset OldProgramProducts = valuelist(GetItemsfromProgramOnBillback.Billback_Product_ID)>
	<!--- Skip all this if we aren't moving any products --->

	<cfset productsAlreadyMovedByProgramUpdate = 0 />
	<cfset Old_Billback_Program_ID = "" />
	<cfset New_Billback_Program_ID = "" />
        
	<!--- Compare the list to change with the list of all original --->
	<cfif listlen(ProductsToSwitch) GT 0>
 	<cfif listlen(OldProgramProducts) EQ listlen(ProductsToSwitch) AND DoNotReplace EQ 0>
	<!--- Switch them all --->
		<cfquery name="getID" datasource="#application.datasource#">
		SELECT Billback_Program_ID, Discount_List
		FROM Billback_Program
		WHERE Program_ID = '#Program_ID#'
		AND Billback_ID = '#Billback_ID#'
		AND Deleted = 0
		</cfquery>

		<cfset Old_Billback_Program_ID = getID.Billback_Program_ID />

		<!--- Find out if program is already on the billback and add to it if it is --->
		<cfquery name="ProgramAlreadyThere" datasource="#application.datasource#">
		SELECT Billback_Program_ID, Discount_List
		FROM Billback_Program
		WHERE Program_ID = '#NewProgram#'
		AND Billback_ID = '#Billback_ID#'
		AND Deleted = 0
		</cfquery>

		<!--- Update billback program --->
		<cfif ProgramAlreadyThere.Recordcount EQ 0>
			<cfquery name="UpdateBillbackProgram" datasource="#application.datasource#">
			UPDATE Billback_Program
			SET Program_ID = #NewProgram#
			WHERE Billback_Program_ID = '#getID.Billback_Program_ID#'
			AND Billback_ID = '#Billback_ID#'
			</cfquery>
			
			<!--- 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] - Anand Rao/20-Jun-2018 
				 In The above scenario, we are not deleting entrees for the Billback_program_ID and we are updating the program_ID, which may have a 
				 different BS_Var_2 value. So we are deleting it from the Billback_Distribution_Channel Table and the insert procedure at the bottm
				 will insert the correct value for that program into the Billback_Distribution_Channel table.
			--->
			<cfif (appSettings.get_Setting('BB_Display_Dist_Channel_Per_Program_Distributor'))>
				<cfquery name="UpdateBBDC" datasource="#application.datasource#">
					UPDATE 
							Billback_Distribution_Channel  
						SET 
							Deleted = 1,
							Deleted_By =  '#request.AccessStructure.User_ID#',
							Deleted_date = GetDate()
						WHERE  
							Billback_Program_ID = '#getID.Billback_Program_ID#'
							AND Billback_ID = '#Billback_ID#'
				</cfquery>
			</cfif>
			
			<cfquery name="UpdateBillbackInvoiceLevel" datasource="#application.datasource#">
			UPDATE BB_Item_Invoice_Level
			SET Program_ID = #NewProgram#
			WHERE Billback_Program_ID = '#getID.Billback_Program_ID#'
			AND Billback_ID = '#Billback_ID#'
			</cfquery>

			<!---
			All products are getting switched.

			When the Billback_Program is updated with new program id,
			product have automatically moved to new program and
			so we no longer need to update the Billback_product table

			Also ProductOnTargetProgram will return results as
			the program id is already updated with new program id
			--->
			<cfset productsAlreadyMovedByProgramUpdate = 1 />
			<cfset New_Billback_Program_ID = getID.Billback_Program_ID />
			<cfset Update_Desc = "Update BP.Program_ID" />

		<cfelse>

			<cfquery name="DeleteBillbackProgram" datasource="#application.datasource#">
			UPDATE Billback_Program
			SET Deleted = 1,
				Deleted_Date = GETDATE(),
				Deleted_By = 'Switch'
			WHERE Billback_Program_ID = '#getID.Billback_Program_ID#'
			AND Billback_ID = '#Billback_ID#'
			</cfquery>

			<cfquery name="replaceProgramID" datasource="#application.datasource#">
				UPDATE 	BB_Item_Invoice_Level
				SET 	Billback_Program_ID = '#ProgramAlreadyThere.Billback_Program_ID#',
						Program_ID = #NewProgram#
				WHERE 	Billback_Program_ID = '#getID.Billback_Program_ID#'
				AND 	Billback_ID = '#Billback_ID#'
			</cfquery>

			<!--- Overwrites previous GetID --->
			<cfset getID.Billback_Program_ID = ProgramAlreadyThere.Billback_Program_ID>
			<cfset getID.Discount_List = ProgramAlreadyThere.Discount_List>
			<cfset New_Billback_Program_ID = ProgramAlreadyThere.Billback_Program_ID />

		</cfif>


 		<!--- delete old rebate component (if applicable) and add new one --->
		<cfquery name="DeletedOldRebateComps" datasource="#application.datasource#">
		UPDATE Billback_Program_Rebate_Component
		SET Deleted = 1,
		Deleted_Date = getdate(),
		Deleted_By = 'Switch Programs'
		WHERE Billback_ID = '#Billback_ID#'
		AND Billback_Program_ID = '#Program_ID#'
		</cfquery>
		<!--- If you're only switching some you want to keep the existing components --->

	<cfelse>
	<!--- Update only some --->

		<cfquery name="getID" datasource="#application.datasource#">
		SELECT Billback_Program_ID, Discount_List
		FROM Billback_Program
		WHERE Program_ID = '#Program_ID#'
		AND Billback_ID = '#Billback_ID#'
		AND Deleted = 0
		</cfquery>

		<cfset Old_Billback_Program_ID = getID.Billback_Program_ID />

		<!--- Create entry in billback_program table --->
		<!--- The program might already be there ... in which case you should add to it --->
		<cfquery name="GetProgramIfAlreadyThere" datasource="#application.datasource#">
		SELECT Billback_ID, Program_ID
		FROM Billback_Program
		WHERE Billback_ID = '#Billback_ID#'
		AND Program_ID = '#NewProgram#'
		AND Deleted = 0
		</cfquery>

		<cfif GetProgramIfAlreadyThere.Recordcount LT 1>
			<cfquery name="InsertIntoBillbackProgram" datasource="#application.datasource#">
			INSERT INTO Billback_Program
			(
				Billback_ID,
				Program_ID
			)
			VALUES
			(
				'#Billback_ID#',
				'#NewProgram#'
			)
			</cfquery>
		</cfif>

		<cfquery name="getID" datasource="#application.datasource#">
			SELECT Billback_Program_ID, Discount_List
			FROM Billback_Program
			WHERE Billback_ID = '#Billback_ID#'
			AND Program_ID = '#NewProgram#'
			AND Deleted = 0
		</cfquery>

		<cfset New_Billback_Program_ID = getID.Billback_Program_ID />

		<!--- switch all or some --->
	</cfif>


		<!--- D29932: Update Discount Type --->
		<cfset NewComponent = "">

		<cfloop list="#DiscountsToMove#" index="DiscountsToMove">
			<cfset "NewDiscount#DiscountsToMove#" = DiscountsToMove />
			<!--- <cfoutput>#NewComponent# -- #DiscountsToMove#</cfoutput> --->
			<cfswitch expression="#DiscountsToMove#">
				<!--- Move from fixed --->
				<cfcase value="1">
					<!--- Pull from first query in case some have already been moved --->
					 <!--- <cfoutput> --->
					<cfif isNumeric(NewFixed)>
					<!--- if it's not a rebate, we can just set it to the new selection --->
						<cfset NewDiscountForFixed = NewFixed>
					<cfelse>
					<!--- If it's a rebate we need to handle for passing in the component_id --->
						<cfset DashPosition = find("_", NewFixed)>
						<CFSET CompLength = LEN(NewFixed) - DashPosition>
						<cfset NewDiscountForFixed = left(NewFixed, DashPosition -1)>
						 <!--- NewDiscountForFixed: #NewDiscountForFixed# --->
						<cfset NewComp1 = right(NewFixed, CompLength)>
						<!--- NewComp1: #NewComp1#<br>
						NewFixed: #NewFixed#<br>
						DashPosition: #DashPosition#<br> --->
						<cfif NOT listcontains(NewComponent, NewComp1)>
							<cfset NewComponent = listappend(NewComponent, NewComp1)>
						</cfif>
					</cfif>

					<cfset "NewDiscount#DiscountsToMove#" = NewDiscountForFixed />
				</cfcase>

				<!--- Move from rebate --->
				<cfcase value="2">
					<!--- <cfoutput> ---><cfif isNumeric(NewRebate)>
					<!--- if it's not a rebate, we can just set it to the new selection --->
						<cfset NewDiscountForRebate = NewRebate>
					<cfelse>
					<!--- If it's a rebate we need to handle for passing in the component_id --->
					<!--- Dash Position: #DashPosition#<br> --->
						<cfset DashPosition = find("_", NewRebate)>
						<!--- NewRebate: #NewRebate#<br> --->
						<CFSET CompLength = LEN(NewRebate) - DashPosition>
						<cfset NewDiscountForRebate = left(NewRebate, DashPosition -1)>
						<!--- NewDiscountForRebate: #NewDiscountForRebate#<br> --->
						<cfset NewComp2 = right(NewRebate, CompLength)>
						<!--- NewComp2: #NewComp2#<br> --->
						<cfif NOT listcontains(NewComponent, NewComp2)>
							<cfset NewComponent = listappend(NewComponent, NewComp2)>
							<!--- NewComponent: #NewComponent#<p></p> --->
						</cfif>
					</cfif>
					<!--- </cfoutput> --->
					<!--- Pull from first query in case some have already been moved --->
					<cfset "NewDiscount#DiscountsToMove#" = NewDiscountForRebate />
				</cfcase>

				<!--- Move from growth --->
				<cfcase value="4">
					<!--- Pull from first query in case some have already been moved --->

					<cfif isNumeric(NewGrowth)>
					<!--- if it's not a rebate, we can just set it to the new selection --->
						<cfset NewDiscountForGrowth = NewGrowth>
					<cfelse>
					<!--- If it's a rebate we need to handle for passing in the component_id --->
						<cfset DashPosition = find("_", NewGrowth)>
						<CFSET CompLength = LEN(NewGrowth) - DashPosition>
						<cfset NewDiscountForGrowth = left(NewGrowth, DashPosition -1)>
						<cfset NewComp4 = right(NewGrowth, CompLength)>
						<cfif NOT listcontains(NewComponent, NewComp4)>
							<cfset NewComponent = listappend(NewComponent, NewComp4)>
						</cfif>
					</cfif>
					<cfset "NewDiscount#DiscountsToMove#" = NewDiscountForGrowth />
				</cfcase>

				<!--- Move from formula --->
				<cfcase value="5">
					<!--- Pull from first query in case some have already been moved --->

					<cfif isNumeric(NewFormula)>
					<!--- if it's not a rebate, we can just set it to the new selection --->
						<cfset NewDiscountForFormula = NewFormula>
					<cfelse>
					<!--- If it's a rebate we need to handle for passing in the component_id --->
						<cfset DashPosition = find("_", NewFormula)>
						<CFSET CompLength = LEN(NewFormula) - DashPosition>
						<cfset NewDiscountForFormula = left(NewFormula, DashPosition -1)>
						<cfset NewComp5 = right(NewFormula, CompLength)>
						<cfif NOT listcontains(NewComponent, NewComp5)>
							<cfset NewComponent = listappend(NewComponent, NewComp5)>
						</cfif>
					</cfif>
					<cfset "NewDiscount#DiscountsToMove#" = NewDiscountForFormula />
				</cfcase>

				<!--- Move from bid request --->
				<cfcase value="11">
					<!--- Pull from first query in case some have already been moved --->
					<cfif isNumeric(NewBidRequest)>
					<!--- if it's not a rebate, we can just set it to the new selection --->
						<cfset NewDiscountForBidRequest = NewBidRequest>
					<cfelse>
					<!--- If it's a rebate we need to handle for passing in the component_id --->
						<cfset DashPosition = find("_", NewBidRequest)>
						<CFSET CompLength = LEN(NewBidRequest) - DashPosition>
						<cfset NewDiscountForBidRequest = left(NewBidRequest, DashPosition -1)>
						<cfset NewComp10 = right(NewBidRequest, CompLength)>
						<cfif NOT listcontains(NewComponent, NewComp10)>
							<cfset NewComponent = listappend(NewComponent, NewComp10)>
						</cfif>
					</cfif>
					<cfset "NewDiscount#DiscountsToMove#" = NewDiscountForBidRequest />
				</cfcase>

			</cfswitch>
		<!---Discount loop --->
		</cfloop>
		<cfset z = 1 />
		<cfset ProductsToSwitchActual = ''/>
		<!--- Update product on program --->
		<cfloop list="#ProductsToSwitch#" index="Billback_Product_ID">
			<!--- D51977 :: Billback enhancements for operator level data --->
			<!--- get the BB_Item_Invoice_Level_ID if available --->
			<cfscript>
				BB_Item_Invoice_Level_ID = 0;
				BB_Item_Invoice_Level_ID = ListGetAt(lsBBItemInvoiceLevelID,z);
				z = z+1;
			</cfscript>

			<cfset New_Billback_Product_ID = Billback_Product_ID />
			<cfset Update_Desc = "" />

			<cfquery name="IsProductOnProgram" datasource="#application.datasource#">
				SELECT Contract_Products_ID
				FROM Contract_Products
					INNER JOIN Billback_Product
					ON Billback_Product.Billback_Product_ID = '#Billback_Product_ID#'
					AND Billback_Product.Deleted = 0
				WHERE Contract_Main_ID = '#NewProgram#'
				AND Contract_Products.Deleted = 0
			</cfquery>

			<cfset Product_Type_ID = 2>
			<cfif IsProductOnProgram.Recordcount GT 0>
				<cfset Product_Type_ID = 1>
			</cfif>

			<cfquery name="GetProductInfo" datasource="#application.datasource#">
				SELECT Product_ID, Distributor_ID
				FROM Billback_Product
				WHERE Billback_Product_ID = '#Billback_Product_ID#'
			</cfquery>

			<!--- Is the product already on the target program? --->
			<cfif len(trim(GetProductInfo.Product_ID)) GT 0>
			<cfquery name="ProductOnTargetProgram" datasource="#application.datasource#">
				SELECT Billback_Product_ID, BB_Product_Quantity, BB_Product_UOM
				FROM Billback_Product
					INNER JOIN Billback_Program
					ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
					AND Billback_Program.Program_ID = '#NewProgram#'
				WHERE Product_ID = '#GetProductInfo.Product_ID#'
				AND Distributor_ID = '#GetProductInfo.Distributor_ID#'
				AND Billback_Product.Billback_ID = '#Billback_ID#'
				AND Billback_Product.Deleted = 0
			</cfquery>
			<cfelse>
				<cfset ProductOnTargetProgram = QueryNew("Billback_Product_ID, BB_Product_Quantity, BB_Product_UOM")>
				<cfset Product_Type_ID = 3>
			</cfif>

			<!--- If the product isn't already on the program, just switch over the product id to the new one --->


        <!--- <cfif ProductOnTargetProgram.Recordcount IS 0 OR (listlen(OldProgramProducts) EQ listlen(ProductsToSwitch))> --->
        <!---
            Dev Notes: 22129/Anand Rao: Removed the condition which was checking for the length as it was not working
            properly and would not sum the volume if both the oldprogramproducts and productsToSwitch had the same number
            of elements.
        ---->
        <!--- D51977 :: START Billback enhancements for operator level data --->
        <cfset bDeleteOld = 1/>
		<cfif BB_Item_Invoice_Level_ID GT 0>
			<cfquery name="checkDeleteOld" datasource="#application.datasource#">
				SELECT COUNT (bb_item_invoice_Level_Id) AS remainder from bb_item_invoice_level 
				where billback_product_Id = <cfqueryparam value="#Billback_Product_ID#"> 
				and bb_item_invoice_Level_Id NOT IN (#listqualify(lsBBItemInvoiceLevelID, "'")#)
			</cfquery>
			<cfif checkDeleteOld.remainder GT 0>
				<cfset bDeleteOld = 0/>
			</cfif>
		</cfif>
		<cfset oldBillbackProductId = Billback_Product_ID />
		<cfif ProductOnTargetProgram.Recordcount IS 0>
			<cfif bDeleteOld EQ 1 > <!--- OK to update since this is not a partial operator upd --->
				<!---<cfset ProductsToSwitchActual = ListAppend(ProductsToSwitchActual,Billback_Product_ID) />--->
				<cfquery name="UpdateProduct" datasource="#application.datasource#">
					UPDATE Billback_Product
					SET Product_Type_ID = #Product_Type_ID#,
					Billback_Program_ID = '#getID.Billback_Program_ID#'
					WHERE Billback_Product_ID = '#Billback_Product_ID#'
				</cfquery>
				<cfquery name="UpdateExistingProductProgramID" datasource="#application.datasource#">
					UPDATE 	BB_Item_Invoice_Level
					SET 	Billback_Program_ID = '#getID.Billback_Program_ID#',
							Program_ID = '#NewProgram#'
					WHERE 	Billback_ID = '#Billback_ID#'
					AND		Billback_Product_ID = '#Billback_Product_ID#'					
				</cfquery>
			<cfelse> <!--- we need to Insert since this is a partial --->
				<cfquery name="InsertBillbackProduct" datasource="#application.datasource#">
					Insert INTO Billback_Product
						(Billback_ID,
							Product_ID,
							Billback_Program_ID,
							BB_Product_Quantity,
							BB_Product_UOM,
							BB_Product_Category_ID,
							BB_Unknown_Product_Item_Number,
							BB_Unknown_Product_Description,
							BB_Unknown_Product_Notes,
							Product_Type_ID,
							Count_Flag,
							Product_Hierarchy_ID,
							Product_Hierarchy_Volume,
							Actual_Count_Flag,
							Distributor_id,
							Operator_ID,
							Operator_Legacy_ID,
							Operator_Name,
							Invalid_Product_Desc,
							Invalid_Product)
					SELECT 
						Billback_ID,
						Product_ID,
						'#getID.Billback_Program_ID#',
						(SELECT SUM(Claimed_CS) from BB_Item_Invoice_Level where Billback_Product_ID = '#Billback_Product_ID#'
									AND BB_Item_Invoice_Level_ID =  <cfqueryparam value="#BB_Item_Invoice_Level_ID#" cfsqltype="cf_sql_integer">) 
									AS BB_Product_Quantity,
						BB_Product_UOM,
						BB_Product_Category_ID,
						BB_Unknown_Product_Item_Number,
						BB_Unknown_Product_Description,
						BB_Unknown_Product_Notes,
						#Product_Type_ID#,
						Count_Flag,
						Product_Hierarchy_ID,
						Product_Hierarchy_Volume,
						Actual_Count_Flag,
						Distributor_id,
						Operator_ID,
						Operator_Legacy_ID,
						Operator_Name,
						Invalid_Product_Desc,
						Invalid_Product
					FROM Billback_Product
					WHERE 	Billback_Product_ID = '#Billback_Product_ID#'
					AND 	Deleted = 0
					
					SELECT SCOPE_IDENTITY() AS Billback_Product_ID
					
				</cfquery>
				<cfset Billback_Product_ID = InsertBillbackProduct.Billback_Product_ID />
				<cfquery name="UpdateExistingProductProgramID" datasource="#application.datasource#">
					UPDATE 	BB_Item_Invoice_Level
					SET 	Billback_Program_ID = '#getID.Billback_Program_ID#',
							Program_ID = '#NewProgram#',
							Billback_Product_ID = '#Billback_Product_ID#'
					WHERE 	Billback_ID = '#Billback_ID#'
					AND		Billback_Product_ID = '#oldBillbackProductId#'
					<cfif BB_Item_Invoice_Level_ID GT 0>
						AND BB_Item_Invoice_Level_ID =  <cfqueryparam value="#BB_Item_Invoice_Level_ID#" cfsqltype="cf_sql_integer">
					</cfif>
				</cfquery>
				<cfquery name="InsertBillbackProductDetail" datasource="#application.datasource#">
						Insert INTO Billback_Product_Detail
							(Billback_Product_ID,
							Billback_ID,
							BB_Product_Type_ID,
							BB_Rate,
							Product_Hierarchy_Rate,
							BB_Expected_Rate,
							Distributor_ID_Earned,
							Earned_From_Group,
							Customer_Group_ID,
							Sales_Dollars,
							Discount_Offered,
							Discount_UOM,
							Volume)
						SELECT 
							'#Billback_Product_ID#',
							Billback_ID,
							(CASE BB_Product_Type_ID
									<cfloop list="#DiscountsToMove#" index="DiscountsToMove">
									<cfif isDefined("NewDiscount#DiscountsToMove#")>
									WHEN #DiscountsToMove# THEN #Evaluate("NewDiscount#DiscountsToMove#")#
									</cfif>
									</cfloop>
									ELSE BB_Product_Type_ID
									END) AS BB_Product_Type_ID,
							(SELECT SUM(Claimed_Amt) from BB_Item_Invoice_Level where Billback_Product_ID = '#Billback_Product_ID#'
									AND BB_Item_Invoice_Level_ID =  <cfqueryparam value="#BB_Item_Invoice_Level_ID#" cfsqltype="cf_sql_integer">) 
									AS BB_Rate,
							Product_Hierarchy_Rate,
							BB_Expected_Rate,
							Distributor_ID_Earned,
							Earned_From_Group,
							Customer_Group_ID,
							Sales_Dollars,
							Discount_Offered,
							Discount_UOM,
							Volume
						FROM Billback_Product_Detail
						WHERE 	Billback_Product_ID = '#oldBillbackProductId#'
						AND 	Deleted = 0
					</cfquery>
					
					<cfquery name="UpdateProductOld" datasource="#application.datasource#">
							UPDATE Billback_Product
							SET BB_Product_Quantity = BB_Product_Quantity - (SELECT SUM(Claimed_CS) from BB_Item_Invoice_Level where Billback_Product_ID = '#Billback_Product_ID#'
											AND BB_Item_Invoice_Level_ID =  <cfqueryparam value="#BB_Item_Invoice_Level_ID#" cfsqltype="cf_sql_integer">) 
							WHERE Billback_Product_ID = '#oldBillbackProductId#'
					</cfquery>
					
					<cfquery name="UpdateProductDetailOld" datasource="#application.datasource#">
							UPDATE Billback_Product_detail
							SET BB_Rate = BB_Rate - (SELECT SUM(Claimed_Amt) from BB_Item_Invoice_Level where Billback_Product_ID = '#Billback_Product_ID#'
											AND BB_Item_Invoice_Level_ID =  <cfqueryparam value="#BB_Item_Invoice_Level_ID#" cfsqltype="cf_sql_integer">)
							WHERE Billback_Product_ID = '#oldBillbackProductId#'
					</cfquery>
			</cfif>
			<!--- D51977 :: END Billback enhancements for operator level data --->
			<cfset Update_Desc = "Update BP.BB_Program_ID" />

		<cfelse>

			<!---
			productsAlreadyMovedByProgramUpdate will be 1 above when
			all products are getting switched and products are moving to a program
			which was not in this billback

			As Billback_Program was updated with new program id above,
			product have automatically moved to new program and
			so we no longer need to update the Billback_product table

			Also ProductOnTargetProgram will return results as
			the program id is already updated with new program id
			--->
			<!--- if user double clicks there are chances that we try to switch product twice.
			When we try to switch it the second time, Billback_Product_ID will be equal to ProductOnTargetProgram.Billback_Product_ID
			In that can we don't need to do any thing.
			Otherwise below code will double the volume and set Billback_Product to deleted = 1 as both updates happens on same record
			--->
			<cfif productsAlreadyMovedByProgramUpdate eq 0
				AND Billback_Product_ID NEQ ProductOnTargetProgram.Billback_Product_ID>
				
				<!--- D51977 :: Billback enhancements for operator level data --->
				<!--- If the product is on the target program we need to sum volume, delete one of the versions and update billback_product_detail.billback_product_id for the one we deleted. --->
				<cfif BB_Item_Invoice_Level_ID GT 0><!--- we are moving volume basd on Operator --->
					<!--- Get data from billback_Product we're getting rid of --->
					<cfquery name="BillbackProductToBeRemoved" datasource="#application.datasource#">
						SELECT Billback_Product.Billback_Product_ID, BB_Product_Quantity, BB_Product_UOM,
						 ISNULL(Claimed_CS,Claimed_LB * i.net_weight ) AS Case_Quantity,
						 ISNULL(Claimed_LB,Claimed_CS/i.net_weight )   AS Pound_Quantity
						FROM Billback_Product
							INNER JOIN BSA_Foodservice_Items_Master i
							ON i.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
						INNER JOIN bb_item_invoice_level BIL ON
							BIL.Billback_Product_ID = Billback_Product.Billback_Product_ID
						WHERE Billback_Product.Billback_Product_ID = <cfqueryparam value="#Billback_Product_ID#"> AND
							   BIL.BB_Item_Invoice_Level_ID =  <cfqueryparam value="#BB_Item_Invoice_Level_ID#" cfsqltype="cf_sql_integer">
					</cfquery>
				<cfelse>
					<!--- Get data from billback_Product we're getting rid of --->
					<cfquery name="BillbackProductToBeRemoved" datasource="#application.datasource#">
						SELECT Billback_Product_ID, BB_Product_Quantity, BB_Product_UOM,
						CASE  WHEN Billback_Product.BB_Product_UOM = 1
						THEN	BB_Product_Quantity
						ELSE (cast(BB_Product_Quantity as float) * cast(BSA_Foodservice_Items_Master.Net_Weight as float))
						END AS Case_Quantity,
						CASE  WHEN Billback_Product.BB_Product_UOM = 1
						THEN	(cast(BB_Product_Quantity as float) / cast(BSA_Foodservice_Items_Master.Net_Weight as float))
						ELSE BB_Product_Quantity
						END AS Pound_Quantity
						FROM Billback_Product
							INNER JOIN BSA_Foodservice_Items_Master
							ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
						WHERE Billback_Product_ID = '#Billback_Product_ID#'
					</cfquery>
				</cfif>

				
				<!--- Detect zero volume --->
				<cfquery name="qZeroVolumeAdjust" datasource="#application.datasource#">
					SELECT	1 as Zero_Volume_Adjust,
							--CAST(1 AS DECIMAL(20, 4)) / CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT) as OnePoundInCases
							--CAST(1 AS DECIMAL(20, 4)) * CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT) as OneCaseInPounds,
							CASE Billback_Product.BB_Product_UOM
							WHEN 1 THEN 1 
							ELSE CAST(1 AS DECIMAL(20, 4)) / CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
							END as VolumeIncrementAdjustZeroCases,
							CASE Billback_Product.BB_Product_UOM
							WHEN 1 THEN CAST(1 AS DECIMAL(20, 4)) * CAST(BSA_Foodservice_Items_Master.Net_Weight AS FLOAT)
							ELSE 1
							END as VolumeIncrementAdjustZeroPounds
					FROM	Billback_Product
					INNER JOIN BSA_Foodservice_Items_Master
					ON		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Billback_Product.Product_ID
					WHERE 	Billback_Product_ID = '#ProductOnTargetProgram.Billback_Product_ID#'
					AND	(
							(Billback_Product.BB_Product_UOM = 1 AND ISNULL(cast(BB_Product_Quantity as float) + #BillbackProductToBeRemoved.Case_Quantity# ,0) = 0)
					OR		(Billback_Product.BB_Product_UOM = 2 AND ISNULL(cast(BB_Product_Quantity as float) + #BillbackProductToBeRemoved.Pound_Quantity# ,0) = 0)
					)               		
				</cfquery>
				
				<cfset VolumeIncrementAdjustZero = 0 />
				<cfset VolumeIncrementAdjustZeroCases = 0 />
				<cfset VolumeIncrementAdjustZeroPounds = 0 />
				<cfif qZeroVolumeAdjust.recordCount>
					<cfset VolumeIncrementAdjustZero = 1 />
					<cfset VolumeIncrementAdjustZeroCases = qZeroVolumeAdjust.VolumeIncrementAdjustZeroCases />
					<cfset VolumeIncrementAdjustZeroPounds = qZeroVolumeAdjust.VolumeIncrementAdjustZeroPounds />
				</cfif>
				
				<!--- Add volume to target billback_product --->
				<cfquery name="UpdateProduct" datasource="#application.datasource#">
					UPDATE Billback_Product
					SET Product_Type_ID = #Product_Type_ID#,
					Billback_Program_ID = '#getID.Billback_Program_ID#',
					BB_Product_Quantity =
					/* CASE WHEN Billback_Product.BB_Product_UOM = 1
					THEN cast(BB_Product_Quantity as float) + #BillbackProductToBeRemoved.Case_Quantity#
					ELSE cast(BB_Product_Quantity as float) + #BillbackProductToBeRemoved.Pound_Quantity#
					END */
					/***** D44775 - When the BB_Product_Quantity is 0 make it 1 *****/
					CASE WHEN Billback_Product.BB_Product_UOM = 1
					THEN cast(BB_Product_Quantity as float) + #BillbackProductToBeRemoved.Case_Quantity# + #VolumeIncrementAdjustZero#
					ELSE cast(BB_Product_Quantity as float) + #BillbackProductToBeRemoved.Pound_Quantity# + #VolumeIncrementAdjustZero#
					END
					
					/*
					CASE WHEN Billback_Product.BB_Product_UOM = 1
                    THEN CASE WHEN  ISNULL(cast(BB_Product_Quantity as float) + #BillbackProductToBeRemoved.Case_Quantity# ,0) = 0 THEN 1
                              ELSE  CAST(BB_Product_Quantity AS Float) + #BillbackProductToBeRemoved.Case_Quantity#
                         END
                    ELSE CASE WHEN  ISNULL(cast(BB_Product_Quantity as float) + #BillbackProductToBeRemoved.Pound_Quantity# ,0) = 0 THEN 1
                              ELSE  CAST(BB_Product_Quantity AS Float) + #BillbackProductToBeRemoved.Pound_Quantity#
                         END                                                           
               		END
					*/
					WHERE Billback_Product_ID = '#ProductOnTargetProgram.Billback_Product_ID#'
				</cfquery>

				<cfset New_Billback_Product_ID = ProductOnTargetProgram.Billback_Product_ID />

				<cfset selectedVolumeType = 0 />
				<cfquery name="getSelectedVolumeType" datasource="#application.datasource#">
					SELECT	Selected_Vol_Type
					FROM	BB_Item_Invoice_Level
					WHERE 	Billback_Product_ID = '#ProductOnTargetProgram.Billback_Product_ID#'
				</cfquery>
				<cfif getSelectedVolumeType.recordCount>
					<cfif getSelectedVolumeType.Selected_Vol_Type NEQ "">
						<cfset selectedVolumeType = getSelectedVolumeType.Selected_Vol_Type />
					</cfif>
				</cfif>
				<!--- 
					OneCaseInPounds = This is the case value equivalent to pound
					OnePoundInCases = This is the pound value equivalet to cases
				--->
				<cfquery name="UpdateBBItemInvoiceLevel" datasource="#application.datasource#">
					UPDATE	BB_Item_Invoice_Level
					SET 	Billback_Program_ID = '#getID.Billback_Program_ID#',
							Billback_Product_ID = '#ProductOnTargetProgram.Billback_Product_ID#',
							Program_ID			= '#NewProgram#',							
							Claimed_CS			= Claimed_CS + #VolumeIncrementAdjustZeroCases#,
							Claimed_LB			= Claimed_LB + #VolumeIncrementAdjustZeroPounds#
							<cfif selectedVolumeType EQ 1> <!--- Claimed --->
								,Selected_Vol_Type = 1,
								Selected_Vol_CS = Claimed_CS + #VolumeIncrementAdjustZeroCases#,
								Selected_Vol_LB = Claimed_LB + #VolumeIncrementAdjustZeroPounds#
							<cfelseif selectedVolumeType EQ 2> <!--- Expected --->
								,Selected_Vol_Type = 2,
								Selected_Vol_CS = Expected_CS,
								Selected_Vol_LB = Expected_LB
							</cfif>
							<!--- D29932: Update Discount Type --->
							, Discount_Type_ID = (	CASE Discount_Type_ID
													<cfloop list="#DiscountsToMove#" index="DiscountsToMove">
													<cfif isDefined("NewDiscount#DiscountsToMove#")>
													WHEN #DiscountsToMove# THEN #Evaluate("NewDiscount#DiscountsToMove#")#
													</cfif>
													</cfloop>
													ELSE Discount_Type_ID
													END)
					WHERE 	Billback_Product_ID = '#Billback_Product_ID#'
					<cfif BB_Item_Invoice_Level_ID GT 0>
						AND BB_Item_Invoice_Level_ID =  <cfqueryparam value="#BB_Item_Invoice_Level_ID#" cfsqltype="cf_sql_integer">
					</cfif>
				</cfquery>

				<!--- Update all billback_product_details, we sum up later on --->
				<cfif bDeleteOld EQ 1 > <!--- OK to update since this is not a partial operator upd --->
					<cfquery name="UpdateBillbackProductDetail" datasource="#application.datasource#">
						UPDATE 	Billback_Product_Detail
						SET 	Billback_Product_ID = '#ProductOnTargetProgram.Billback_Product_ID#',
								<!--- D29932: Update Discount Type --->
								BB_Product_Type_ID = (	CASE BB_Product_Type_ID
														<cfloop list="#DiscountsToMove#" index="DiscountsToMove">
														<cfif isDefined("NewDiscount#DiscountsToMove#")>
														WHEN #DiscountsToMove# THEN #Evaluate("NewDiscount#DiscountsToMove#")#
														</cfif>
														</cfloop>
														ELSE BB_Product_Type_ID
														END)
						WHERE 	Billback_Product_ID = '#Billback_Product_ID#'
						AND 	Deleted = 0
					</cfquery>
					<!--- D51977 :: START Billback enhancements for operator level data --->
				<cfelse> <!--- we need to Insert since this is a partial --->
                    <cfquery name="qDropTempTable" datasource="#application.datasource#">
                        IF OBJECT_ID('tempdb..##tmp_bpd_insert') IS NOT NULL
                        DROP TABLE ##tmp_bpd_insert
                    </cfquery>
					<cfquery name="UpdateBillbackProductDetail" datasource="#application.datasource#">
                        
                        SELECT Billback_Product_Detail_ID as Old_Billback_Product_Detail_ID,
							'#ProductOnTargetProgram.Billback_Product_ID#' as New_Billback_Product_ID,
							Billback_ID,
							(CASE BB_Product_Type_ID
									<cfloop list="#DiscountsToMove#" index="DiscountsToMove">
									<cfif isDefined("NewDiscount#DiscountsToMove#")>
									WHEN #DiscountsToMove# THEN #Evaluate("NewDiscount#DiscountsToMove#")#
									</cfif>
									</cfloop>
									ELSE BB_Product_Type_ID
									END) AS BB_Product_Type_ID,
							(SELECT SUM(Claimed_Amt) 
                            from    BB_Item_Invoice_Level 
                            where   Billback_Product_ID = '#ProductOnTargetProgram.Billback_Product_ID#'
                            <cfif BB_Item_Invoice_Level_ID GT 0>
                            AND BB_Item_Invoice_Level_ID =  <cfqueryparam value="#BB_Item_Invoice_Level_ID#" cfsqltype="cf_sql_integer">  
                            </cfif>
				            ) AS BB_Rate,
							Product_Hierarchy_Rate,
							BB_Expected_Rate,
							Distributor_ID_Earned,
							Earned_From_Group,
							Customer_Group_ID,
							Sales_Dollars,
							Discount_Offered,
							Discount_UOM,
							Volume
						INTO  ##tmp_bpd_insert
                        FROM Billback_Product_Detail
						WHERE 	Billback_Product_ID = '#Billback_Product_ID#'
						AND 	Deleted = 0
                        
                        
						Insert INTO Billback_Product_Detail
							(Billback_Product_ID,
							Billback_ID,
							BB_Product_Type_ID,
							BB_Rate,
							Product_Hierarchy_Rate,
							BB_Expected_Rate,
							Distributor_ID_Earned,
							Earned_From_Group,
							Customer_Group_ID,
							Sales_Dollars,
							Discount_Offered,
							Discount_UOM,
							Volume)
						SELECT 
							New_Billback_Product_ID,
							Billback_ID,
							BB_Product_Type_ID,
							BB_Rate,
							Product_Hierarchy_Rate,
							BB_Expected_Rate,
							Distributor_ID_Earned,
							Earned_From_Group,
							Customer_Group_ID,
							Sales_Dollars,
							Discount_Offered,
							Discount_UOM,
							Volume
						FROM ##tmp_bpd_insert
                                
                        UPDATE  d
                        SET     BB_Rate = d.BB_Rate - tmp.BB_Rate
                        FROM    Billback_Product_detail d
                        INNER JOIN ##tmp_bpd_insert tmp
                        ON  tmp.Old_Billback_Product_Detail_ID = d.Billback_Product_Detail_ID
					</cfquery>
                        
				</cfif>
				<!--- D51977 :: END Billback enhancements for operator level data --->
				<!--- Now deleted the old one --->
				<cfif bDeleteOld EQ 1 >
					<cfquery name="DeleteOldBillbackProduct" datasource="#application.datasource#">
						UPDATE 	Billback_Product
						SET 	Deleted = 1
						WHERE 	Billback_Product_ID = '#Billback_Product_ID#'
					</cfquery>
				</cfif>

				<cfset Update_Desc = "Consolidate BP" />

<!--- 			<cfquery name="DeleteOldBillbackProductDetail" datasource="#application.datasource#">
				UPDATE 	BB_Item_Invoice_Level
				SET 	Deleted = 1
					WHERE Billback_Product_ID = '#Billback_Product_ID#'
			</cfquery> --->

			<!---- Product is already on the program --->
			</cfif>
		</cfif>

			<cfquery name="AddtoLog" datasource="#application.datasource#">
				INSERT INTO BB_Switch_Program_Log
				(
					Billback_ID,
					Product_ID,
					Old_Program_ID,
					New_Program_ID,
					Old_Billback_Program_ID,
					New_Billback_Program_ID,
					Old_Billback_Product_ID,
					New_Billback_Product_ID,
					Update_Desc,
					Created_by
				)
				VALUES
				(
					<cfqueryparam value="#Billback_ID#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#GetProductInfo.Product_ID#" cfsqltype="cf_sql_varchar" null="#Len(GetProductInfo.Product_ID) eq 0#" />,
					<cfqueryparam value="#Program_ID#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="#NewProgram#" cfsqltype="cf_sql_integer" />,
					<cfqueryparam value="#Old_Billback_Program_ID#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#New_Billback_Program_ID#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#Billback_Product_ID#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#New_Billback_Product_ID#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#Update_Desc#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#request.accessstructure.user_id#" cfsqltype="CF_SQL_VARCHAR" />
				)
			</cfquery>
			<cfset ProductsToSwitchActual = ListAppend(ProductsToSwitchActual,Billback_Product_ID) />
		<!--- Product loop --->
		</cfloop>

		<!--- Update discount types xx
			--->
			<cfif len(trim(ProductsToSwitchActual)) GT 0 >
				<cfquery name="SelectProductDetails" datasource="#application.datasource#">
				SELECT * FROM Billback_Product_Detail
				WHERE Billback_Product_ID IN (#listqualify(ProductsToSwitchActual, "'")#)
				AND Deleted = 0
				</cfquery>
			<cfelse>
				<cfset SelectProductDetails = QueryNew('Billback_Product_Detail_ID,BB_Product_Type_ID')/>
			</cfif>

		<!--- D29932: Update Discount Type --->
		<cfloop list="#DiscountsToMove#" index="DiscountsToMove">

			<cfif isDefined("NewDiscount#DiscountsToMove#")>
				<cfset iNewDiscountType = Evaluate("NewDiscount#DiscountsToMove#") />

				<cfquery name="GetDiscountTypeProducts" dbtype="query">
					SELECT 	Billback_Product_Detail_ID
					FROM 	SelectProductDetails
					WHERE 	BB_Product_Type_ID = #DiscountsToMove#
				</cfquery>
				<cfset DiscountTypeProductsToUpdate = valuelist(GetDiscountTypeProducts.Billback_Product_Detail_ID)>

				<!--- Update with new discount type --->
				<cfif GetDiscountTypeProducts.Recordcount GT 0>
					<cfquery name="UpdateFixed" datasource="#application.datasource#">
						UPDATE Billback_Product_Detail
						SET BB_Product_Type_ID = #iNewDiscountType#
						WHERE Billback_Product_Detail_ID IN (#listqualify(DiscountTypeProductsToUpdate, "'")#)
					</cfquery>

					<cfquery name="UpdateFixedItemInvoiceLevel" datasource="#application.datasource#">
						UPDATE 	BB_Item_Invoice_Level
						SET 	Discount_Type_ID = #iNewDiscountType#
						WHERE 	Billback_Product_ID IN (#listqualify(ProductsToSwitch, "'")#) AND
								Discount_Type_ID = #DiscountsToMove# 
						<cfif application.appSettingsGet.getViewOperatorinBillbackDeviation()>
								AND
								bb_item_invoice_Level_Id IN (#listqualify(lsBBItemInvoiceLevelID, "'")#)
						</cfif>
					</cfquery>

				</cfif>
			</cfif>

		<!---Discount loop --->
		</cfloop>


		<cfif listlen(NewComponent) GT 0>

		<cfloop list="#NewComponent#" index="NewComponent">

		<cfquery name="CompAlreadyExists" datasource="#application.datasource#">
			SELECT Program_Rebates_Component_ID, Program_Rebates_Component_Name_ID
			FROM Billback_Program_Rebate_Component
			WHERE Billback_ID = '#Billback_ID#'
			AND Billback_Program_ID = '#NewProgram#'
			AND Program_Rebates_Component_Name_ID = '#NewComponent#'
			AND Deleted = 0
		</cfquery>

		<cfif CompAlreadyExists.Recordcount EQ 0>

		<!--- Information on the new program--->
		<cfset useLakebaseForGetContractNumbers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractNumbers>
	<cftry>
		<cfset GetContractNumbers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#NewProgram#",
				"select" = "contract_number,contract_title"
			}), "contract_number,contract_title"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractNumbers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractNumbers>
<cfquery name="GetContractNumbers" datasource="#application.datasource#">
			SELECT Contract_Number, Contract_Title
			FROM Contract_Main
			WHERE Contract_Main_ID = '#NewProgram#'
		</cfquery>
</cfif>
		
		<cfquery name="GetAllContractMains" datasource="#application.datasource#">
			SELECT 	Contract_Main_ID
			FROM Contract_Main
			WHERE Contract_Number LIKE '%#GetContractNumbers.Contract_Number#%'
			AND Approved = 1
		</cfquery>
		<cfset AllContractMains = valuelist(GetAllContractMains.Contract_Main_ID)>

		<cfquery name="GetCompInfo" datasource="#application.datasource#">
			SELECT TOP 1 Program_Rebates_Component.Program_Rebates_Component_ID,
				Program_Rebates_Component_Name.Program_Rebates_Component_Name
			FROM Program_Rebates_Component
				INNER JOIN Program_Rebates_Component_Name
				ON Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
			WHERE Program_Rebates_Component.Program_Rebates_Component_Name_ID = '#NewComponent#' AND
			Program_Rebates_Component.Program_ID IN (#AllContractMains#) 
			AND Program_Rebates_Component.Deleted = 0
			AND Program_Rebates_Component.Component_Paid_To = '#getPayeeInfo.Billback_Payee_Type_ID#'
			ORDER BY Program_Rebates_Component.Program_ID DESC
		</cfquery>

			<cfquery name="NewRebateComponent" datasource="#application.datasource#">
				INSERT INTO Billback_Program_Rebate_Component
				(
					Billback_ID,
					Billback_Program_ID,
					Program_Rebates_Component_ID,
					Program_Rebates_Component_Name,
					Program_Rebates_Component_Name_ID,
					Checked
				)
				VALUES
				(
					'#Billback_ID#',
					'#NewProgram#',
					'#GetCompInfo.Program_Rebates_Component_ID#',
					'#GetCompInfo.Program_Rebates_Component_Name#',
					#NewComponent#,
					'true'
				)
			</cfquery>
			<!--- the rebate comp you're adding isn't already there for the new program --->

		</cfif>
		<!--- components to add --->
		</cfloop>
		<!--- there are rebate components to add --->
		</cfif>
<!--- 
	
	NEED <cfif bDeleteOld EQ 1 >  LOGIC HERE    --->
		<cfif len(trim(ProductsToSwitchActual)) GT 0 >
			<!---Update discount list --->
			<cfquery name="GetDistinctDiscounts" datasource="#application.datasource#">
				SELECT DISTINCT BB_Product_Type_ID
				FROM Billback_Product_Detail
				WHERE Billback_Product_ID IN (#listqualify(ProductsToSwitchActual, "'")#)
				AND Deleted = 0
			</cfquery>
		<cfelse>
			<cfset GetDistinctDiscounts = QueryNew('BB_Product_Type_ID')/>
		</cfif>
		

		<cfset NewDiscountList = valuelist(GetDistinctDiscounts.BB_Product_Type_ID)>

		<cfif bDeleteOld EQ 0 >
			<cfset NewDiscountList = ListAppend(getID.Discount_List, NewDiscountList)>
		</cfif>
		

		<cfquery name="UpdateDiscountList" datasource="#application.datasource#">
			UPDATE Billback_Program
			SET Discount_List = '#NewDiscountList#'
			WHERE Billback_Program_ID = '#getID.Billback_Program_ID#'
			AND Deleted = 0
		</cfquery>

		<!--- START: 83849: Deviation Grid not processing correctly / Anand Rao / 25-Feb-2019 --->
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
			AND		Billback_ID = '#Billback_ID#'
			AND 	bp.Billback_Product_ID IN (#listqualify(ProductsToSwitchActual, "'")#)
			
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
		<!--- END: 83849: Deviation Grid not processing correctly / Anand Rao / 25-Feb-2019 --->

		<!--- Sums up duplicate entries --->
			 <!--- Discounts --->
				<!--- Get the problem records --->

				<cfquery name="GetRecordsToUpdate" datasource="#application.datasource#">
					SELECT Count(BB_Product_Type_ID),
					      Billback_Product.Billback_Product_ID,  BB_Product_Type_ID, SUM(cast(BB_Rate as float)) AS NewSum, Distributor_ID_Earned
					 FROM
					      Billback_Product_Detail
					 INNER JOIN
					      Billback_Product
					      ON Billback_Product.Billback_Product_ID = Billback_Product_Detail.Billback_Product_ID
					      AND Billback_Product.Deleted = 0
					WHERE Billback_Product.Billback_ID = '#Billback_ID#'
					      AND Billback_Product_Detail.Deleted = 0
					      AND Billback_Program_ID = '#getID.Billback_Program_ID#'
					 GROUP BY
					      Billback_Product.Billback_Product_ID, BB_Product_Type_ID, Distributor_ID_Earned
					 HAVING Count(BB_Product_Type_ID) > 1
				  </cfquery>

				   <cfloop query="GetRecordsToUpdate">

				   	<cfquery name="GetBillbackProduct" datasource="#application.datasource#">
					SELECT * FROM Billback_Product
					WHERE Billback_Product.Billback_ID = '#Billback_ID#'
			    	AND Deleted = 0
			   		AND Billback_Program_ID = '#getID.Billback_Program_ID#'
			   		AND Product_ID = '#GetRecordsToUpdate.Billback_Product_ID#'
					</cfquery>

				   <!--- Delete old record --->

				    <cfquery name="DeletetheDuplicates" datasource="#application.datasource#">
					   UPDATE Billback_Product_Detail
					   SET Deleted = 1
					   WHERE Billback_ID = '#Billback_ID#'
					   AND Billback_Product_ID = '#GetRecordsToUpdate.Billback_Product_ID#'
					   AND BB_Product_Type_ID = '#GetRecordsToUpdate.BB_Product_Type_ID#'
					   AND Deleted = 0
				   </cfquery>

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
							'#Billback_ID#',
							'#GetRecordsToUpdate.BB_Product_Type_ID#',
							'#GetRecordsToUpdate.NewSum#',
							'#GetRecordsToUpdate.Distributor_ID_Earned#'
						)
					</cfquery>

				   </cfloop>
 <!--- There are actually products on the list --->

 		<cfelse>
		<!--- Need a query for GetID --->



		<cfquery name="getID" datasource="#application.datasource#">
			SELECT Billback_Program_ID, Discount_List
			FROM Billback_Program
			WHERE Program_ID = '#NewProgram#'
			AND Billback_ID = '#Billback_ID#'
			AND Deleted = 0
			</cfquery>
		</cfif>

			<!--- end discounts --->
			<!--- BJF We need to add handling for if there is nothing at all on the program (no items and no lump sum)--->
			<!---There is no new program so we need to still switch the old one --->
			<Cfif getID.recordcount IS 0>

				<cfquery name="getExistingID" datasource="#application.datasource#">
				SELECT Billback_Program_ID
				FROM Billback_Program
				WHERE Program_ID = '#Program_ID#'
				AND Billback_ID = '#Billback_ID#'
				AND Deleted = 0
				</cfquery>

				<!--- Update billback program --->
				<cfquery name="UpdateBillbackProgram" datasource="#application.datasource#">
				UPDATE Billback_Program
				SET Program_ID = #NewProgram#
				WHERE Billback_Program_ID = '#getExistingID.Billback_Program_ID#'
				</cfquery>

				<!--- 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] - Anand Rao/20-Jun-2018 
				 In The above scenario, we are not deleting entrees for the Billback_program_ID and we are updating the program_ID, which may have a 
				 different BS_Var_2 value. So we are deleting it from the Billback_Distribution_Channel Table and the insert procedure at the bottm
				 will insert the correct value for that program into the Billback_Distribution_Channel table.
				--->
				<cfif (appSettings.get_Setting('BB_Display_Dist_Channel_Per_Program_Distributor'))>
					<cfquery name="UpdateBBDC" datasource="#application.datasource#">
						UPDATE 
								Billback_Distribution_Channel  
							SET 
								Deleted = 1,
								Deleted_By =  '#request.AccessStructure.User_ID#',
								Deleted_date = GetDate()
							WHERE  
								Billback_Program_ID = '#getExistingID.Billback_Program_ID#'
								AND Billback_ID = '#Billback_ID#'
					</cfquery>
				</cfif>
				<!--- Overwrites previous GetID --->
				<cfquery name="getID" datasource="#application.datasource#">
				SELECT Billback_Program_ID, Discount_List
				FROM Billback_Program
				WHERE Program_ID = '#NewProgram#'
				AND Billback_ID = '#Billback_ID#'
				AND Deleted = 0
				</cfquery>

		</cfif>

			<!--- Lump sums --->

			<cfquery name="GetAllLS" datasource="#application.datasource#">
			SELECT * FROM Billback_Program_Lumpsum_Component
			WHERE Billback_ID = '#Billback_ID#'
			</cfquery>

			<cfquery name="GetLSToUpdate" datasource="#application.datasource#">
				SELECT
			     Billback_Program_ID, Program_Lump_Sum_ID, Program_Growth_Component_Tier_ID, SUM(cast(Amount as float)) AS NewSum, Component_Type_ID
			 FROM
			      Billback_Program_Lumpsum_Component
			WHERE Billback_ID = '#Billback_ID#'
			      AND Billback_Program_Lumpsum_Component.Deleted = 0
			      AND Billback_Program_ID = '#getID.Billback_Program_ID#'
			 GROUP BY
			     Billback_Program_ID, Program_Lump_Sum_ID, Program_Growth_Component_Tier_ID, Component_Type_ID
			 <!--- HAVING Count(Program_Lump_Sum_ID) > 1 --->
				  </cfquery>

			<cfloop query="GetLSToUpdate">

				   <!--- Delete old record --->

				   <cfquery name="DeletetheDuplicates" datasource="#application.datasource#">
				   UPDATE Billback_Program_Lumpsum_Component
				   SET Deleted = 1
				   WHERE Billback_ID = '#Billback_ID#'
				   AND Billback_Program_ID = '#GetLSToUpdate.Billback_Program_ID#'
					AND Program_Lump_Sum_ID = '#GetLSToUpdate.Program_Lump_Sum_ID#'
					AND Component_Type_ID = '#GetLSToUpdate.Component_Type_ID#'
				   AND Deleted = 0
				   </cfquery>

				   	<!--- Insert new record --->
					<cfquery name="InsertNewSummedRecord" datasource="#application.datasource#">
					INSERT INTO Billback_Program_Lumpsum_Component
					(
						Billback_ID,
						Billback_Program_ID,
						Component_Type_ID,
						Program_Lump_Sum_ID,
						Amount
					)
					VALUES
					(
						'#Billback_ID#',
						'#GetLSToUpdate.Billback_Program_ID#',
						'#GetLSToUpdate.Component_Type_ID#',
						'#GetLSToUpdate.Program_Lump_Sum_ID#',
						#NewSum#
					)
					</cfquery>

				   </cfloop>
			<cfquery name="GetAllLSAgain" datasource="#application.datasource#">
			SELECT * FROM Billback_Program_Lumpsum_Component
			WHERE Billback_ID = '#Billback_ID#'
			</cfquery>

			<!--- end lump sums --->

		<!--- End summing up duplicate entries --->

			<!--- update the billback table with adjust data --->
			<cfquery name="qUpdateBillbacks" datasource="#application.datasource#">
				UPDATE	Billback
				SET		BB_Adjusted 		= <cfqueryparam value="1" cfsqltype="CF_SQL_BIT" />,
						BB_Adjusted_By		= <cfqueryparam value="#request.accessstructure.user_id#" cfsqltype="CF_SQL_VARCHAR" />,
						BB_Adjusted_Date	= getDate()
				WHERE 	Billback_ID 		=  <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR" />
			</cfquery>

			<!--- (START) MAKE SURE THE CORRECT "DISCOUNT LIST" IS ON THE BILLBACK --->

			<CFSET idxRebateOnBillback = ListFind(NewDiscountList,"2")>

			<!--- If rebate exists on billback. --->
			<CFIF idxRebateOnBillback neq 0>

			<!--- Check whether the products exist for the REBATE discount type in the "billback_product_detail" table for the new program. --->
			<cfquery name="qCountRebateProductsOnPrg" datasource="#application.datasource#">
			SELECT Count(Billback_Product_Detail.Billback_Product_ID) As Rebateproducts
			FROM Billback_Program
			INNER JOIN Billback_Product
			ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
			INNER JOIN Billback_Product_Detail
			ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
			WHERE Billback_Program.Billback_Program_ID = '#New_Billback_Program_ID#'
			AND Billback_Product.Deleted = 0
			AND Billback_Product_Detail.Deleted = 0
			AND Billback_Program.Deleted = 0
			AND Billback_Product_Detail.BB_Product_Type_ID = 2
			</cfquery>

			<!--- get billback rebate components for the new program. --->
			<cfquery name="getBBPrgRebateCompCount" datasource="#Application.Datasource#">
			SELECT count(Billback_Program_ID) As CompCount
			FROM Billback_Program_Rebate_Component
			WHERE Billback_Program_ID =  #NewProgram#
			AND Billback_id = '#Billback_ID#'
			AND Deleted = 0
			</cfquery>
				<!--- If neither REBATE comp exists for the new program nor the REBATE products exist in the "billback_product_detail" table.  --->
				<CFIF qCountRebateProductsOnPrg.Rebateproducts eq 0 AND getBBPrgRebateCompCount.CompCount eq 0>
					<!--- remove rebate from billback. --->
					<CFSET NewDiscountList = ListDeleteAt(NewDiscountList,idxRebateOnBillback)>

				</CFIF>
			</CFIF>

			<CFSET idxFixedPriceOnBillback = ListFind(NewDiscountList,"1")>

			<!--- If fixed price exists on billback.
			Note: We do not want Fixed Price to be removed from the billback if that is the only discount type left on the billback
			and so "Listlen(idxFixedPriceOnBillback) GT 1" is a safeguard.			
			 --->
			 <!--- 
			 	55702: Switch program issue inside program tab in a Billback/ Anand Rao / 11-Nov-2015
				idxFixedPriceOnBillback is not a list so, looks like it was wrongly placed and should have been 
				NewDiscountList. This correction was made and tested to make sure the page works correctly.
			 --->
			<CFIF Listlen(NewDiscountList) GT 1 AND idxFixedPriceOnBillback neq 0>

			<!--- Check whether the products exist for the FIXED PRICE discount type in the "billback_product_detail" table for the new program. --->
			<cfquery name="qCountFixedPriceProductsOnPrg" datasource="#application.datasource#">
			SELECT Count(Billback_Product_Detail.Billback_Product_ID) As FixedPriceproducts
			FROM Billback_Program
			INNER JOIN Billback_Product
			ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
			INNER JOIN Billback_Product_Detail
			ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
			WHERE Billback_Program.Billback_Program_ID = '#New_Billback_Program_ID#'
			AND Billback_Product.Deleted = 0
			AND Billback_Product_Detail.Deleted = 0
			AND Billback_Program.Deleted = 0
			AND Billback_Product_Detail.BB_Product_Type_ID = 1
			</cfquery>
				<!--- If FIXED PRICE products do not exist in the "billback_product_detail" table.  --->
				<CFIF qCountFixedPriceProductsOnPrg.FixedPriceproducts eq 0>
					<!--- remove fixed price from billback. --->
					<!--- 
			 			55702: Switch program issue inside program tab in a Billback/ Anand Rao / 11-Nov-2015
						Loop over the NewDiscountList using the below condition and remove the fixed discount type 
						from the Discount_List field, when there is no fixed component in the Billback. 
			 		--->
						<cfloop condition = "ListLen(NewDiscountList) GT 1 AND (ListFind(NewDiscountList,'1') NEQ 0)">
							<cfset idxToDelete = ListFind(NewDiscountList,"1") />
							<cfif idxToDelete  NEQ 0>
								<CFSET NewDiscountList = ListDeleteAt(NewDiscountList,idxToDelete)>
							</cfif>
						</cfloop>	
				</CFIF>
			</CFIF>
			
			<cfquery name="getDiscountList" datasource="#application.datasource#">
			SELECT Discount_List
			FROM Billback_Program
			WHERE Billback_Program_ID = '#New_Billback_Program_ID#'
			AND Billback_Program.Deleted = 0
			</cfquery>
			
			<!--- If the "Discount_List" on the billback_program table is different than the lastest "Discount_List". --->
			<cfif getDiscountList.Discount_List neq NewDiscountList>

				<cfquery name="UpdateDiscountList" datasource="#application.datasource#">
				UPDATE Billback_Program
				SET Discount_List = '#NewDiscountList#'
				WHERE Billback_Program_ID = '#New_Billback_Program_ID#'
				AND Deleted = 0
				</cfquery>

			</cfif>
			<!--- (END) MAKE SURE THE CORRECT "DISCOUNT LIST" IS ON THE BILLBACK --->
			
			
			<!--- 77469	Display Dist Channel at BB_Program Distributor Level   [ CF work ] /Anand/19-Jun-2018 --->
			<cfif (appSettings.get_Setting('BB_Display_Dist_Channel_Per_Program_Distributor'))>
				<cfquery name="qInsBB_DC" datasource="#Application.Datasource#">
					EXEC Billback_Distribution_Channel_Insert '#Billback_ID#'
				</cfquery>
			</cfif>

		</cftransaction>
<!---<cfabort>---> 
		<!--- D22543 - Prevent updates while deviation Run all is in progress - Grid could cause this issue as it opens in popup --->
		<CFPARAM NAME="In_Progress_Check_BBID" default="">
		<CFPARAM NAME="PageName_InProgress" default="">
		<CFPARAM NAME="Progress_Type" default="0">

		<CFSET In_Progress_Check_BBID = FORM.Billback_ID>
		<CFSET PageName_InProgress = "Swtich Programs">
		<CFSET Progress_Type = 2>
		<CFINCLUDE TEMPLATE = "BB_In_Progress_Check.cfm">

		<!--- Reload billback struct --->
		<cfinclude template="/billbacks/capture/load_billback_to_struct.cfm">
		<cfoutput>
		<script>
			function getFlexApp(appName)
			{
				if (navigator.appName.indexOf ("Microsoft") !=-1)
				{
					return opener.window[appName];
				}
				else
				{
					return opener.document[appName];
				 }
			}

			<cfif len(trim(form.FlexAppName))>
				function reloadBillbackEdit()
				{
					getFlexApp('#FORM.FlexAppName#').reloadBillbackEdit();
				}
				reloadBillbackEdit();
				window.close();
			<cfelse>
				callfireEvent(opener.parent.document,opener.parent.programs_tab,'Click');
				window.close();
			</cfif>
		</script>
		</cfoutput>
</cfif>

<html>
<head>
	<title>Switch Billback Program</title>
</head>
<body onload = "mytimer = setTimeout('fcsOnMe()', 25);">
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<style>
TABLE.productListTableStyle TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}

					.programInformationStyle_Top {
						border-top : 1 solid #ProgramDataBorderColor#;
						border-left : 1 solid #ProgramDataBorderColor#;
						border-right : 1 solid #ProgramDataBorderColor#;
						border-bottom : 0 solid red;
						background-color: WhiteSmoke;
					}

					.tableHeader {
						background-color : #ffce84;
					}

					.ProductTypeLabel {
						font-size: 12px;
						font-weight: bold;
						background-color: #ccffcc;
					}

					.LumpSumRow {
						border-bottom : 1 solid Navy;
					}

					.topMenu {
						border-top : 1 solid blue;
						border-bottom : 1 solid blue;
						border-left : 1 solid blue;
						border-right : 1 solid blue;
					}

					.redHeader
					{
						background-color: #8B0000;
					}


</style>
<cfoutput>
<div align="center">
<!--- Discounts --->

<!--- Discounts to check> --->


<cfset getPayeeID.Payee_ID = billbackProgramManager.getPayeeID(Billback_ID,getPayeeInfo.Billback_Payee_Type_ID) />
<cfif getPayeeInfo.Billback_Payee_Type_ID EQ 4 AND getPayeeID.Payee_ID NEQ "">
	<cfset getPayeeInfo.Billback_Payee_Type_ID = 1 />
</cfif>
<cfset Payee_Type_ID = getPayeeInfo.Billback_Payee_Type_ID>

<!--- Information on the new program--->
<cfquery name="GetContractNumbers" datasource="#application.datasource#">
SELECT Contract_Number, Contract_Title
FROM Contract_Main
WHERE Contract_Main_ID = '#NewProgram#'
</cfquery>

<cfquery name="GetAllContractMains" datasource="#application.datasource#">
SELECT 	Contract_Main_ID
FROM Contract_Main
WHERE Contract_Number LIKE '%#GetContractNumbers.Contract_Number#%'
AND Approved = 1
</cfquery>
<cfset AllContractMains = valuelist(GetAllContractMains.Contract_Main_ID)>

<cfset programDiscountTypes = "">

<cfquery name="GetDistinctDiscountTypes" datasource="#application.datasource#">
SELECT DISTINCT Product_Type_ID
FROM Contract_Products
WHERE Contract_Products.Contract_Main_ID IN (#AllContractMains#)
AND Contract_Products.Deleted = 0
</cfquery>

<!--- This only returns discount types where there is a component with that payee type --->
<cfset programDiscountTypes = "">
<cfloop query="GetDistinctDiscountTypes">
	<cfswitch expression="#Product_Type_ID#">
		<!--- Has fixed --->
		<cfcase value="1">
			<cfquery name="HasFixed" datasource="#application.datasource#">
			SELECT DISTINCT Program_Fixed_Component.Program_Fixed_Component_ID, Program_Fixed_Component_Name.Program_Fixed_Component_Name
				FROM Program_Fixed_Component
					INNER JOIN Program_Fixed_Component_Name
					ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
				WHERE Program_Fixed_Component.Program_ID IN (#AllContractMains#)
				AND Program_Fixed_Component.Deleted = 0
				AND (Program_Fixed_Component.Fixed_Component_Paid_To = #Payee_Type_ID#
					OR
						(Program_Fixed_Component.Fixed_Component_Paid_To = 4
							AND #Payee_Type_ID# != 3)
					)
			</cfquery>
			<cfif HasFixed.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "1")>
			</cfif>
		</cfcase>

		<!--- Has rebate --->
		<cfcase value="2">
			<cfquery name="Has_Rebate" datasource="#application.datasource#">
			SELECT DISTINCT
			Program_Rebates_Component_Name.Program_Rebates_Component_Name,
			Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
			FROM Program_Rebates_Component
				INNER JOIN Program_Rebates_Component_Name
				ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
			WHERE Program_Rebates_Component.Program_ID IN (#AllContractMains#)
			AND Program_Rebates_Component.Deleted = 0
			AND (Program_Rebates_Component.Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_Rebates_Component.Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			</cfquery>
			<cfif Has_Rebate.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "2")>
			</cfif>
		</cfcase>

		<!--- Has lumpsum --->
		<cfcase value="3">
			<cfquery name="Has_Lumpsums" datasource="#application.datasource#">
			SELECT DISTINCT Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID,
			Program_Lump_Sum_Name.Program_Lump_Sum_Name
			FROM Program_Lump_Sums
				INNER JOIN Program_Lump_Sum_Name
				ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE Program_Lump_Sums.Program_ID IN (#AllContractMains#)
			AND Program_Lump_Sums.Deleted = 0
			AND (Program_Lump_Sums.Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_Lump_Sums.Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			</cfquery>
			<Cfif Has_Lumpsums.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "3")>
			</CFIF>
		</cfcase>

		<!--- Has growth --->
		<cfcase value="4">
			<cfquery name="Has_Growth" datasource="#application.datasource#">
			SELECT Program_Growth_Components.Program_Growth_Component_ID,
			Program_Growth_Components_Name.Program_Growth_Components_Name,
			Program_Growth_Component_Tiers.Growth_Amount
			FROM Program_Growth_Components
				INNER JOIN Program_Growth_Components_Name
				ON Program_Growth_Components_Name.Program_Growth_Components_Name_ID = Program_Growth_Components.Program_Growth_Components_Name_ID
				INNER JOIN Program_Growth_Component_Tiers
				ON Program_Growth_Component_Tiers.Program_Growth_Component_ID = Program_Growth_Components.Program_Growth_Component_ID
				AND Program_Growth_Component_Tiers.Deleted = 0
			WHERE Program_Growth_Components.Program_ID IN (#AllContractMains#)
			AND Program_Growth_Components.Deleted = 0
			AND (Program_Growth_Components.Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_Growth_Components.Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			</cfquery>

			<Cfif Has_Growth.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "4")>
			</CFIF>
		</cfcase>

		<!--- Has formula --->
		<cfcase value="5">
			<Cfset programDiscountTypes = listappend(programDiscountTypes, "5")>
		</cfcase>

		<cfcase value="10">
			<cfquery name="Has_BidRequest" datasource="#application.datasource#">
			SELECT DISTINCT
			Program_BidRequest_Component_Name.Program_BidRequest_Component_Name,
			Program_BidRequest_Component_Name.Program_BidRequest_Component_Name_ID
			FROM Program_BidRequest_Component
				INNER JOIN Program_BidRequest_Component_Name
				ON Program_BidRequest_Component_Name.Program_BidRequest_Component_Name_ID = Program_BidRequest_Component.Program_BidRequest_Component_Name_ID
			WHERE Program_BidRequest_Component.Program_ID IN (#AllContractMains#)
			AND Program_BidRequest_Component.Deleted = 0
			AND (Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = #Payee_Type_ID#
				OR
					(Program_BidRequest_Component.Program_BidRequest_Component_Paid_To = 4
						AND #Payee_Type_ID# != 3)
				)
			</cfquery>

			<Cfif Has_BidRequest.Recordcount GT 0>
				<Cfset programDiscountTypes = listappend(programDiscountTypes, "11")>
			</CFIF>

		</cfcase>

	</cfswitch>
</cfloop>

<cfset NewDiscountList = programDiscountTypes>
<form name="Products" method="post" action="switch_program.cfm">

<cfif listcontains(NewDiscountList, 2)>
	<cfquery name="GetRebateComponents" datasource="#application.datasource#">
	SELECT DISTINCT Program_Rebates_Component_Name, Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
	FROM Program_Rebates_Component_Name
		INNER JOIN Program_Rebates_Component
		ON Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
		AND Program_Rebates_Component.Deleted = 0
		AND Program_Rebates_Component.Program_ID IN (#AllContractMains#)
		AND Program_Rebates_Component.Component_Paid_To = '#getPayeeInfo.Billback_Payee_Type_ID#'
		<!--- 32869 include only payment types where restrict from billback equals to no --->
		INNER JOIN Payment_Type ON Program_Rebates_Component.Claim_Mechanics = Payment_Type.Payment_Type_Id
                           AND Payment_Type.Restrict_From_BillBack = 0
                           AND Payment_Type.Deleted = 0
                           AND Payment_Type.Active = 1
	</cfquery>
</cfif>

<cfset useLakebaseForOldProgramInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForOldProgramInfo>
	<cftry>
		<cfset OldProgramInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Program_ID#",
				"select" = "contract_number,contract_title"
			}), "contract_number,contract_title"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForOldProgramInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForOldProgramInfo>
<cfquery name="OldProgramInfo" datasource="#application.datasource#">
SELECT Contract_Number, Contract_Title
FROM Contract_Main WHERE Contract_Main_ID = '#Program_ID#'
</cfquery>
</cfif>

<cf_cryp string="#Program_ID#" type="en" key="#request.key#">
<CFSET OldCID = cryp.value>

<cf_cryp string="#NewProgram#" type="en" key="#request.key#">
<CFSET NewCID = cryp.value>


<table width="95%" cellpadding="2" cellspacing="0" border="0">
<tr><td colspan="100%">
	<table border="0" width="100%">
	<tr>
		<td valign="top"><strong>Source program:</strong></td>
		<td ><A onClick="javaScript: NewWindow(this.href , 'Catalog_Program' , 750 , 550 , 'yes' , 'yes'); return false;" target="_blank" HREF="/scorecard/program_display.cfm?display_program=1&CID=#OldCID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #OldProgramInfo.Contract_Number#"><font color="660033"><b>#OldProgramInfo.Contract_Number#</b></font></a> #OldProgramInfo.Contract_Title#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Destination program:</strong> </td>
		<td><A onClick="javaScript: NewWindow(this.href , 'Catalog_Program' , 750 , 550 , 'yes' , 'yes'); return false;" target="_blank" HREF="/scorecard/program_display.cfm?display_program=1&CID=#NewCID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for program #GetContractNumbers.Contract_Number#"><font color="660033"><b>#GetContractNumbers.Contract_Number#</b></font></a> #GetContractNumbers.Contract_Title#</td>
	</tr>
	</table>
</td></tr>
<tr><th class="tableHeader" colspan="100%">Discount Assignment</th></tr>
<tr>
	<td width="50%">
	<strong>Discounts:</strong>
	<table>
		<cfif listcontains(GetItemsfromProgramOnBillback.Discount_List, 1)>

		<!--- fixed --->
		<tr>
			<td>Fixed Price discounts should be:</td>

			<td>
				<select name="NewFixed" onfocus="skipcycle=true" onblur="skipcycle=false">
					<cfif listcontains(NewDiscountList,1)><option value="1">Fixed Price</option></cfif>
					<cfif listcontains(NewDiscountList,2)>
						<cfloop query="GetRebateComponents">
							<option value="2_#Program_Rebates_Component_Name_ID#">#Application.RebateLabel# #Program_Rebates_Component_Name#</option>
						</cfloop>
					</cfif>
					<cfif listcontains(NewDiscountList,4)><option value="4">Growth</option></cfif>
					<cfif listcontains(NewDiscountList,5)><option value="5">Formula</option></cfif>
					<cfif listcontains(NewDiscountList,11)><option value="11">Bid Request/Proposal</option></cfif>
				</select>
			</td>
			</tr>
		</cfif>

		<cfif listcontains(GetItemsfromProgramOnBillback.Discount_List, 2)>
		<!--- rebate --->
		<tr>
		<td>Rebate discounts should be:</td>
			<td>
				<select name="NewRebate" onfocus="skipcycle=true" onblur="skipcycle=false">
					<cfif listcontains(NewDiscountList,1)><option value="1">Fixed Price</option></cfif>
					<cfif listcontains(NewDiscountList,2)>
						<cfloop query="GetRebateComponents">
							<option value="2_#Program_Rebates_Component_Name_ID#">#Application.RebateLabel# #Program_Rebates_Component_Name#</option>
						</cfloop>
					</cfif>
					<cfif listcontains(NewDiscountList,4)><option value="4">Growth</option></cfif>
					<cfif listcontains(NewDiscountList,5)><option value="5">Formula</option></cfif>
					<cfif listcontains(NewDiscountList,11)><option value="11">Bid Request/Proposal</option></cfif>
				</select>
			</td>
			</tr>
		</cfif>

		<cfif listcontains(GetItemsfromProgramOnBillback.Discount_List, 4)>
		<!--- growth --->
		<tr>
		<td>Growth discounts should be:</td>
			<td>
				<select name="NewGrowth" onfocus="skipcycle=true" onblur="skipcycle=false">
					<cfif listcontains(NewDiscountList,1)><option value="1">Fixed Price</option></cfif>
					<cfif listcontains(NewDiscountList,2)>
						<cfloop query="GetRebateComponents">
							<option value="2_#Program_Rebates_Component_Name_ID#">#Application.RebateLabel# #Program_Rebates_Component_Name#</option>
						</cfloop>
					</cfif>
					<cfif listcontains(NewDiscountList,4)><option value="4">Growth</option></cfif>
					<cfif listcontains(NewDiscountList,5)><option value="5">Formula</option></cfif>
					<cfif listcontains(NewDiscountList,11)><option value="11">Bid Request/Proposal</option></cfif>
				</select>
			</td>
			</tr>
			</cfif>

		<cfif listcontains(GetItemsfromProgramOnBillback.Discount_List, 5)>
		<!--- formula --->
		<tr>
		<td>Formula discounts should be:</td>
			<td>
				<select name="NewFormula" onfocus="skipcycle=true" onblur="skipcycle=false">
					<cfif listcontains(NewDiscountList,1)><option value="1">Fixed Price</option></cfif>
					<cfif listcontains(NewDiscountList,2)>
						<cfloop query="GetRebateComponents">
							<option value="2_#Program_Rebates_Component_Name_ID#">#Application.RebateLabel# #Program_Rebates_Component_Name#</option>
						</cfloop>
					</cfif>
					<cfif listcontains(NewDiscountList,4)><option value="4">Growth</option></cfif>
					<cfif listcontains(NewDiscountList,5)><option value="5">Formula</option></cfif>
					<cfif listcontains(NewDiscountList,11)><option value="11">Bid Request/Proposal</option></cfif>
				</select>
			</td>
		</tr>
		</cfif>

		<cfif listcontains(GetItemsfromProgramOnBillback.Discount_List, 11)>
		<!--- formula --->
		<tr>
		<td>Bid Request/Proposal should be:</td>
			<td>
				<select name="NewBidRequest" onfocus="skipcycle=true" onblur="skipcycle=false">
					<cfif listcontains(NewDiscountList,1)><option value="1">Fixed Price</option></cfif>
					<cfif listcontains(NewDiscountList,2)>
						<cfloop query="GetRebateComponents">
							<option value="2_#Program_Rebates_Component_Name_ID#">#Application.RebateLabel# #Program_Rebates_Component_Name#</option>
						</cfloop>
					</cfif>
					<cfif listcontains(NewDiscountList,4)><option value="4">Growth</option></cfif>
					<cfif listcontains(NewDiscountList,5)><option value="5">Formula</option></cfif>
					<cfif listcontains(NewDiscountList,11)><option value="11">Bid Request/Proposal</option></cfif>
				</select>
			</td>
			</tr>
		</cfif>
	</table>
	</td>
	<!--- Lump sum may not have product... check seperately --->
	<cfquery name="OldLumpsums" datasource="#application.datasource#">
	SELECT Billback_Program_Lumpsum_Component.*
	FROM Billback_Program_Lumpsum_Component
		INNER JOIN Billback_Program
		ON Billback_Program.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID
		AND Billback_Program.Program_ID = '#Program_ID#'
	WHERE Billback_Program.Billback_ID = '#Billback_ID#'
	AND Billback_Program_Lumpsum_Component.Deleted = 0
	</cfquery>


	<cfset LSList = "">
	<!--- <cfdump var="#OldLumpsums#"> --->
	<cfif listcontains(GetItemsfromProgramOnBillback.Discount_List, 3) OR listcontains(GetItemsfromProgramOnBillback.Discount_List, 4) OR OldLumpsums.Recordcount GT 0>

<cfset LumpSumSelection = QueryNew("LSID, LSDesc")>


	<cfquery name="NewLumpsums" datasource="#application.datasource#">
	SELECT DISTINCT Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID,
	Program_Lump_Sum_Name.Program_Lump_Sum_Name
	FROM Program_Lump_Sums
		INNER JOIN Program_Lump_Sum_Name
		ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
	WHERE Program_Lump_Sums.Program_ID IN (#AllContractMains#)
	AND Program_Lump_Sums.Deleted = 0
	AND (Program_Lump_Sums.Component_Paid_To = #Payee_Type_ID#
		OR
			(Program_Lump_Sums.Component_Paid_To = 4
				AND #Payee_Type_ID# != 3)
		)
	</cfquery>

	<cfif NewLumpsums.Recordcount GT 0>

	<cfloop query="NewLumpsums">

	<cfquery name="GetLSID" datasource="#application.datasource#">
		SELECT TOP 1 Program_Lump_Sum_ID
		FROM Program_Lump_Sums
		WHERE Program_Lump_Sum_Name_ID = '#NewLumpsums.Program_Lump_Sum_Name_ID#'
		AND Program_Lump_Sums.Program_ID  IN (#AllContractMains#)
		ORDER BY Program_ID DESC
		</cfquery>

	<cfset SafeLS = 	"L" & replace(GetLSID.Program_Lump_Sum_ID, "-", "_", "ALL") />
	<cfset LSName = Application.LumpsumLabel & " " & Program_Lump_Sum_Name>
	<cfset newRow  = QueryAddRow(LumpSumSelection)>
		<cfset temp = QuerySetCell(LumpSumSelection, "LSID", SafeLS)>
		<cfset temp = QuerySetCell(LumpSumSelection, "LSDesc", LSName)>
	</cfloop>

	</cfif>

<!--- Growth amount kickers for eligible comps --->
	<cfquery name="Has_Growth_Lumpsums" datasource="#application.datasource#">
	SELECT 	DISTINCT dbo.Program_Growth_Components_Name.Program_Growth_Components_Name_ID,
			dbo.Program_Growth_Components_Name.Program_Growth_Components_Name,
			dbo.Program_Growth_Component_Tiers.Tier_Number
	FROM  	dbo.Program_Growth_Components
			INNER JOIN	dbo.Program_Growth_Component_Tiers
			ON
			dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID
			INNER JOIN Program_Growth_Components_Name
		ON Program_Growth_Components_Name.Program_Growth_Components_Name_ID = Program_Growth_Components.Program_Growth_Components_Name_ID
	WHERE 	(dbo.Program_Growth_Component_Tiers.Deleted = 0)
			AND (dbo.Program_Growth_Components.Deleted = 0)
			AND (dbo.Program_Growth_Components.IsParent = 1)
			AND (dbo.Program_Growth_Components.Program_ID IN (#AllContractMains#))
			AND CAST(dbo.Program_Growth_Component_Tiers.Growth_Amount AS float(8)) <> 0
			AND len(CAST(dbo.Program_Growth_Component_Tiers.Growth_Amount AS float(8))) <> 0
			AND (Program_Growth_Components.Component_Paid_To = #Payee_Type_ID#
		OR
			(Program_Growth_Components.Component_Paid_To = 4
				AND #Payee_Type_ID# != 3)
		)
	ORDER BY dbo.Program_Growth_Components_Name.Program_Growth_Components_Name,
			dbo.Program_Growth_Component_Tiers.Tier_Number
	</cfquery>

	<cfif Has_Growth_Lumpsums.Recordcount GT 0>
	<cfloop query="Has_Growth_Lumpsums">
	<cfset SoloDiscount = "GrowthLump">
	<cfquery name="GetGrowthLSID" datasource="#application.datasource#">
		SELECT TOP 1 Program_Growth_Components.Program_Growth_Component_ID, Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
		FROM Program_Growth_Components
			INNER JOIN	dbo.Program_Growth_Component_Tiers
			ON
			dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID
		WHERE Program_Growth_Components_Name_ID = '#Has_Growth_Lumpsums.Program_Growth_Components_Name_ID#'
		AND Program_Growth_Components.Program_ID  IN (#AllContractMains#)
		ORDER BY Program_Growth_Components.Program_ID DESC
		</cfquery>

		<cfset SafeGrowthLS = 	replace(GetGrowthLSID.Program_Growth_Component_ID, "-", "_", "ALL") />
		<cfset SafeCompTier = replace(GetGrowthLSID.Program_Growth_Component_Tier_ID, "-", "_", "ALL") />
		<cfset GrowthTier = "G" & SafeGrowthLS & "*" & SafeCompTier>
		<cfset GrowthDesc = "Growth " & Program_Growth_Components_Name & " - Tier " & Tier_Number>
			<cfset newRow  = QueryAddRow(LumpSumSelection)>
				<cfset temp = QuerySetCell(LumpSumSelection, "LSID", GrowthTier)>
				<cfset temp = QuerySetCell(LumpSumSelection, "LSDesc", GrowthDesc)>

	</cfloop>
	</cfif>
<td align="left" valign="top">
	<table>
		<tr>
			<Td colspan="2"><strong>#Application.LumpsumLabel#s</strong></TD>
		</tr>
		<Cfloop query="OldLumpsums">

		<tr>
			<Td>
				<cfif OldLumpsums.Component_Type_ID IS 1>
			<cfquery name="OldLSName" datasource="#application.datasource#">
			SELECT 	Program_Lump_Sum_Name.Program_Lump_Sum_Name + '<br>' + ISNULL(Left(Lump_Sum_Description, 35), '') AS Lump_Sum_Name
			FROM 	Program_Lump_Sums
			INNER JOIN Program_Lump_Sum_Name
			ON 		Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE 	Program_Lump_Sum_ID = '#OldLumpsums.PROGRAM_LUMP_SUM_ID#'
			</cfquery>

		<cfelseif OldLumpsums.Component_Type_ID IS 3>
			<cfquery name="OldLSName" datasource="#application.datasource#">
			SELECT dbo.Program_Growth_Components.Component_Name + ' (Tier ' + dbo.Program_Growth_Component_Tiers.Tier_Number + ')'+ '<br>' + 'Growth Lump Sum' AS Lump_Sum_Name
			FROM  dbo.Program_Growth_Components INNER JOIN
			      dbo.Program_Growth_Component_Tiers ON
			      dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID
			WHERE (dbo.Program_Growth_Components.Program_Growth_Component_ID = '#OldLumpsums.PROGRAM_LUMP_SUM_ID#') AND (dbo.Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = '#OldLumpsums.Program_Growth_Component_Tier_ID#')
			</cfquery>
		<cfelse>
		<cfset OldLSName.Lump_Sum_Name = "Unknown Lump Sum">
		</cfif>
		#OldLSName.Lump_Sum_Name# =
			</td>


	<!--- <cfdump var="#LumpSumSelection#"> --->
	<td>
	<Cfif LumpSumSelection.Recordcount GT 0>
	<cfset OldLumpSum = replace(OldLumpsums.Billback_Program_Lumpsum_Component_ID, "-", "_", "all")>
	<cfset LSList = listappend(LSList, OldLumpSum)>
	<select name="LS_#OldLumpSum#" onfocus="skipcycle=true" onblur="skipcycle=false">
		<option value="0">Do not change
		<cfloop query="LumpSumSelection">
		<option value="#LSID#">#LSDesc#
		</cfloop>
	</select>
	<cfelse>
	NA <cfset LSList = 0>
	</CFIF>
	</td>
		</tr>
		</CFLOOP>


	</table>
	</td></cfif>
</tr>
</table>
<input type="hidden" name="LSList" value="#LSList#">
<input type="hidden" name="DiscountsToMove" value="#GetItemsfromProgramOnBillback.Discount_List#">

<!--- Products --->
<table width="95%" cellpadding="2" cellspacing="0" border="0" class="maintable">

<tr  class="tableHeader"><td><input type="checkbox" name="SelectAll" onclick="selectAll(this.checked)">&nbsp; </td>
<th class="tableHeader" colspan="3">Select Products to Switch</th></tr>

<tr>
	<td>&nbsp; </td>
	<td><strong>Item</strong></td>
	<td><strong>Description</strong></td>
	<td align="right">
	<CF_button
		button_name		=	"save1"
		button_caption	=	"save"
		button_action	=	"MakeChange()"
		button_type		=	"javascript_link"
		button_width	=	"200"
		button_color	=	"Navy"
		button_tip		=	"save"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
						</td>
</tr>
</cfoutput>

<cfif (appSettings.get_Setting('Restrict_One_Component_Per_Billback') EQ '1')>
	<cfset rowsChecked = 1 />
<cfelse>
	<cfset rowsChecked = 0 />
</cfif>

<cfoutput query="GetItemsfromProgramOnBillback" group="Operator_ID">

<cfquery name="GetOperatorName" datasource="#application.datasource#">
SELECT Operator_Name, BSA_Operator_ID, Legacy_ID,
Operator_Address + CHAR(13) + Operator_State+ CHAR(13) + Operator_Zip AS Operator_Address
FROM BSA_Operator
WHERE BSA_Operator_ID = '#Operator_ID#'
</cfquery>

	<cfif GetOperatorName.recordcount GT 0>
	<tr bgcolor="orange"><td><input type="checkbox" name="SelectAll" onclick="selectAllOperators(#GetOperatorName.BSA_Operator_ID#,this.checked)"></td><Td colspan="3">#GetOperatorName.Operator_Name# :: #GetOperatorName.Operator_Address# &nbsp;</tr>
	<cfelse>
	<!--- No operator --->
	<tr bgcolor="orange"><td><input type="checkbox" name="SelectAll" onclick="selectAll(this.checked)"></td><Td colspan="3">&nbsp;</tr>
	</cfif>
<cfoutput>

<cfset UnknownOperator = 0>
<Cfif len(trim(GetItemsfromProgramOnBillback.Operator_Legacy_ID)) GT 0>
	<cfset UnknownOperator = 1>
</CFIF>
<tr BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
<!--- D51977 :: START Billback enhancements for operator level data --->
<cfset sVal = GetItemsfromProgramOnBillback.Billback_Product_ID & '|' & GetItemsfromProgramOnBillback.BB_Item_Invoice_Level_ID />
<td><input type="checkbox" name="ProductsToSwitch" <cfif GetOperatorName.recordcount GT 0>id="#GetOperatorName.BSA_Operator_ID#"<cfelse>id="Items"</cfif> value="#sVal#"<cfif (rowsChecked EQ 1)>checked disabled title="The setting 'Restrict one component per billback' is ON, so all products needs to be switched"</cfif>>
<cfif (rowsChecked EQ 1)><input type="hidden" name="ProductsToSwitch" <cfif GetOperatorName.recordcount GT 0>id="#GetOperatorName.BSA_Operator_ID#"<cfelse>id="Items"</cfif> value="#sVal#"> </cfif>
</td>
<td>#GetItemsfromProgramOnBillback.Item#</td>
<td>#GetItemsfromProgramOnBillback.Description# <cfif UnknownOperator IS 1>(#GetItemsfromProgramOnBillback.Operator_Legacy_ID# - #GetItemsfromProgramOnBillback.Operator_Name#)</cfif></td>
<td>&nbsp; </td>
</tr><tr>
</cfoutput>
</cfoutput>
<cfoutput>
<!--- Hidden fields --->
<input type="hidden" name="Billback_ID" value="#Billback_ID#">
<input type="hidden" name="Program_ID" value="#Program_ID#">
<input type="hidden" name="NewProgram" value="#NewProgram#">
<input type="hidden" name="blnSubmit" value="1">
<input type="hidden" name="ParentFormname" value="#ParentFormname#">
<input type="hidden" name="FlexAppName" value="#FORM.FlexAppName#">
<!--- Hidden fields --->
</cfoutput>
</form>
<tr><td colspan="4" align="right" style="border-bottom: none;" style="NotMainTable">
<CF_button
							button_name		=	"save2"
							button_caption	=	"save"
							button_action	=	"MakeChange()"
							button_type		=	"javascript_link"
							button_width	=	"200"
							button_color	=	"Navy"
							button_tip		=	""
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
>
</td></tr>

</table>
<cfif (rowsChecked EQ 1)><div align="left"><font color="red">**The setting 'Restrict one component per billback' is ON, so all products needs to be switched and cannot be deselected by user.</font> </div></cfif>
</div>
</body>
</html>

<script>
function MakeChange()
{
	/* Sometimes, there will only be rebate on a particular program. User wants to switch to a program which only has fixed price.
	This warning will show up in that case.
	Note: Even if the user continues on the above warning, the billback program page has a hard-stop. The user needs to take care
	of this issue before proceeding.
	*/
	var bProceed = 0;
	var checkBoxs=document.getElementsByName("ProductsToSwitch");

    for(var i=0,l=checkBoxs.length;i<l;i++)
    {
        if(checkBoxs[i].checked)
        {
            bProceed = 1;
            break;
        }
    }
	if(bProceed == 0){
		alert('Please select product(s) to switch');
		return false;
	}

	<cfif listcontains(GetItemsfromProgramOnBillback.Discount_List, 2)>	
	if(window.Products.NewRebate.options[window.Products.NewRebate.selectedIndex].value == 1){
		if(!confirm('Are you sure you want to change rebate into fixed price?')){
			bProceed = 0;
		}
	}
	</cfif>

	
	if(bProceed == 1)
	{
		disableButton("save1_table", true, false);
		disableButton("save2_table", true, false);
		document.Products.submit();

		/* This code is to disable the "save" link on the billback program page */
		if (window.opener.disableButton)
		{
			window.opener.disableButton("save_table", true, false);
		}
	
}	}

function selectAllOperators(operatorID,checkedStatus)
{
	var allChecks = document.getElementsByTagName("input");

	if (allChecks.length)
	{	for (i = 0; i < allChecks.length; i++)
		{
			if(allChecks[i].id == operatorID) allChecks[i].checked = checkedStatus;
		}
	}
	else
	{
		if(allChecks.id == operatorID) allChecks.checked = checkedStatus;
	}

}

function selectAll(checkedStatus)
{
	var allChecks = document.getElementsByTagName("input");

	if (allChecks.length)
	{	for (i = 0; i < allChecks.length; i++)
		{
			allChecks[i].checked = checkedStatus;
		}
	}
	else
	{
		allChecks.checked = checkedStatus;
	}

}
</script>

