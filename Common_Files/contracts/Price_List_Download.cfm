<!---
	Copyright (c)2015 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\Common_Files\contracts\Price_List_Download.cfm
	Created:		1/6/2015
	Developer:	drachala
	Description:	use to download price list
--->
 <cfquery name="qDropTempTables" datasource="#Application.Datasource#">
 
 	IF OBJECT_ID('tempdb..##tmp_cp') IS NOT NULL
	DROP TABLE ##tmp_cp
	
	IF OBJECT_ID('tempdb..##tmp_price') IS NOT NULL
	DROP TABLE ##tmp_price	
	
	IF OBJECT_ID('tempdb..##weight_sum') IS NOT NULL
	DROP TABLE ##weight_sum	
	
	IF OBJECT_ID('tempdb..##price_final') IS NOT NULL
	DROP TABLE ##price_final
		
	IF OBJECT_ID('tempdb..##tmp_dist_prod') IS NOT NULL
	DROP TABLE ##tmp_dist_prod
	
 </cfquery>
 
 <cfquery name="qGetProgramsItemRates" datasource="#Application.Datasource#">
	DECLARE 	@Contract_Main_ID int,
						@DELIVERYTYPE varchar(2),
						@Program_Start datetime,
						@Use_Fixed_Price_Type BIT,
						@Price_List_By_Template BIT,
						@ItemMarginTarget_OR_GrossMargin_For_PriceList BIT,
						@Base_Sales_based_on_Prg_Start_Date bit,
						@Effective_Date_for_Price datetime,
						@Price_List_Header_ID uniqueidentifier,
						@Select_Effective_Date_for_Price bit,
						@Use_Fixed_Price_As_Base_Sales bit,
						@Market_Price BIT,
						@Price_List_ID varchar(20),
						@ProgramType_ID int,
						@TmpDateForPrice datetime,
						@WhileCounter int

	SELECT	@Contract_Main_ID = #url.Contract_Main_Id#,
					@DELIVERYTYPE = 'D' -- D or F
	
	SELECT	@Use_Fixed_Price_Type = Use_Fixed_Price_Type,
					@Price_List_By_Template = Price_List_By_Template,
					@ItemMarginTarget_OR_GrossMargin_For_PriceList = ItemMarginTarget_OR_GrossMargin_For_PriceList
	FROM		_Application_Settings
	
	SELECT	@ProgramType_ID = ProgramType_ID,
					@Effective_Date_for_Price = ISNULL(Price_Protection_Date, Effective_Date_for_Price),
					@Program_Start = Contract_Start_Date
	FROM		CONTRACT_MAIN 
	WHERE	CONTRACT_MAIN_ID = @Contract_Main_ID
	
	SELECT	@Price_List_ID = Price_List_ID
	FROM		Contract_Main_Aux_Data 
	WHERE	CONTRACT_MAIN_ID = @Contract_Main_ID
	
	SELECT 	@Price_List_Header_ID = CASE WHEN @Price_List_By_Template = 1 THEN Margin_Price_List_Header_ID ELSE NULL END,
					@Base_Sales_based_on_Prg_Start_Date = Base_Sales_based_on_Prg_Start_Date, 
					@Select_Effective_Date_for_Price = Select_Effective_Date_for_Price,
					@Use_Fixed_Price_As_Base_Sales = Use_Fixed_Price_As_Base_Sales,
					@Market_Price = Program_Control_Panel_Options.Market_Price
	FROM 		dbo.Program_Control_Panel_Options 
	WHERE 	ProgramControl_Panel_Options_ID = @ProgramType_ID

	IF OBJECT_ID('tempdb..##tmp_cp') IS NOT NULL
	DROP TABLE ##tmp_cp
		
	SELECT	DISTINCT cm.Contract_Main_ID, cm.Contract_Number,
					cp.BSA_Foodservice_Items_Master_ID, i.Item, i.Description, 
					CAST(0 as decimal(20, 2)) as Price_Program_Start,
					CAST(0 as decimal(20, 2)) as Price_Current
	INTO	##tmp_cp
	FROM	Contract_Main cm
	INNER JOIN Contract_Products cp
	ON			cp.Contract_Main_ID = cm.Contract_Main_ID
	AND		cp.Deleted = 0
	AND		cp.Is_Group = 0
	INNER JOIN BSA_Foodservice_Items_Master i
	ON		i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	WHERE	cm.Contract_Main_ID = @Contract_Main_ID

	------Logic to get price
	IF OBJECT_ID('tempdb..##tmp_price') IS NOT NULL
	DROP TABLE ##tmp_price	
	CREATE TABLE ##tmp_price(	
							Customer_ID Uniqueidentifier,
							Product_ID Uniqueidentifier,
							Price DECIMAL (20,4),
							distributor_weight DECIMAL (10, 4))
							
	IF OBJECT_ID('tempdb..##weight_sum') IS NOT NULL
	DROP TABLE ##weight_sum	
	CREATE TABLE ##weight_sum(
							product_id Uniqueidentifier, 
							distributor_weight_sum float)
	
	IF OBJECT_ID('tempdb..##price_final') IS NOT NULL
	DROP TABLE ##price_final	
	CREATE TABLE ##price_final(
		product_id Uniqueidentifier, 
		Price decimal(20, 4)	)
		
	IF OBJECT_ID('tempdb..##tmp_dist_prod') IS NOT NULL
	DROP TABLE ##tmp_dist_prod
	CREATE TABLE ##tmp_dist_prod(
								BSA_Foodservice_Customers_ID Uniqueidentifier, 
								Price_List_Header_ID Uniqueidentifier,
								Shr_Ship_To nvarchar(200),
								Distributor_Weight decimal(10, 4),
								BSA_Foodservice_Items_Master_ID Uniqueidentifier,
								Price DECIMAL (20,4))
----------------------------Logic to get price
---  When @WhileCounter = 1, we will get price based on program start
---  When @WhileCounter = 2, we will get price based on today
SET @WhileCounter = 1
	WHILE @WhileCounter <= 2
		BEGIN
			IF @WhileCounter = 1
				SET @TmpDateForPrice = @Program_Start
			ELSE
				SET @TmpDateForPrice = CAST(CONVERT(VARCHAR(10), GETDATE(), 101) AS DATETIME)
			IF (@Use_Fixed_Price_Type = 1 OR @Price_List_By_Template = 1)
				BEGIN
					INSERT INTO ##tmp_price (Customer_ID, Product_ID, Distributor_Weight, Price)
					SELECT	NULL as customer_id , price_list_detail.product_id,
							100 as Distributor_Weight,
							CASE @DELIVERYTYPE
							WHEN 'F' THEN CS_FOB_Price
								ELSE  CS_Bracket_1
							END
					FROM price_list_header
					INNER JOIN price_list_detail
					ON	price_list_detail.price_list_header_id = price_list_header.price_list_header_id
					AND	price_list_detail.Deleted = 0
					AND	@TmpDateForPrice between price_list_detail.Start_Date and price_list_detail.End_Date
					AND	price_list_detail.product_id IN (SELECT DISTINCT BSA_Foodservice_Items_Master_ID FROM ##tmp_cp)
					WHERE	(@Price_List_By_Template = 0 AND @Use_Fixed_Price_Type = 1 AND price_list_header.price_list_id = @Price_List_ID)-- use price list based on fixed price type
					OR		(@Price_List_By_Template = 1 AND price_list_header.price_list_header_id = @Price_List_Header_ID) -- use price list based on template
						
				END
		ELSE 
		BEGIN
		TRUNCATE TABLE ##tmp_dist_prod 
		INSERT INTO ##tmp_dist_prod (BSA_Foodservice_Customers_ID, Price_List_Header_ID, Shr_Ship_To, Distributor_Weight, BSA_Foodservice_Items_Master_ID)
		SELECT	contract_distributors.BSA_Foodservice_Customers_ID, 
				BSA_Foodservice_Customers.Price_List_Header_ID,
				BSA_Foodservice_Customers.Shr_Ship_To,
				CAST(contract_distributors.program_weight as decimal(10, 4)) as Distributor_Weight,
				##tmp_cp.BSA_Foodservice_Items_Master_ID
		FROM	contract_distributors
		inner join BSA_Foodservice_Customers 
		on		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = contract_distributors.BSA_Foodservice_Customers_ID
		inner join ##tmp_cp
		on		1 = 1
		where	contract_distributors.CONTRACT_MAIN_ID = @Contract_Main_ID
		AND		contract_distributors.Deleted = 0
		AND		BSA_Foodservice_Customers.Active_Code = 'A'
			
		-- get price from regular price list
		UPDATE	t
		SET		Price = 
					CASE @DELIVERYTYPE
					WHEN 'F' THEN CS_FOB_Price
					ELSE  CS_Bracket_1
					END
		FROM	##tmp_dist_prod t
		INNER JOIN Price_List_Detail
		ON		Price_List_Detail.Price_List_Header_ID = t.Price_List_Header_ID
		AND		Price_List_Detail.Product_ID = t.BSA_Foodservice_Items_Master_ID
		AND		Price_List_Detail.Deleted = 0
		AND		@TmpDateForPrice between price_list_detail.Start_Date and price_list_detail.End_Date
		
		-- get price from special price list
		UPDATE	t
		SET		Price = 
					CASE @DELIVERYTYPE
					WHEN 'F' THEN CS_FOB_Price
						ELSE  CS_Bracket_1
					END
		from	##tmp_dist_prod t
		INNER JOIN Price_List_Header_Special h
		ON		h.Ship_To = t.Shr_Ship_To
		INNER JOIN Price_List_Detail_Special d
		ON		d.Price_List_Header_Special_ID = h.Price_List_Header_Special_ID
		AND		d.Product_ID = t.BSA_Foodservice_Items_Master_ID
		AND		d.Deleted = 0
		AND		@TmpDateForPrice between d.Start_Date and d.End_Date
		
		-- get price from default price list
		UPDATE	t
		SET		Price = 
					CASE @DELIVERYTYPE
					WHEN 'F' THEN CS_FOB_Price
						ELSE  CS_Bracket_1
					END
		from	##tmp_dist_prod t
		INNER JOIN Price_List_Default d
		ON		d.Product_ID = t.BSA_Foodservice_Items_Master_ID
		AND		d.Deleted = 0
		AND		@TmpDateForPrice between d.Start_Date and d.End_Date
		WHERE	t.Price IS NULL
		
		
		INSERT INTO ##tmp_price (Customer_ID, Product_ID, Distributor_Weight, Price)
		SELECT	BSA_Foodservice_Customers_ID, BSA_Foodservice_Items_Master_ID, Distributor_Weight, Price
		FROM	##tmp_dist_prod

	END

	TRUNCATE TABLE ##weight_sum
	INSERT INTO ##weight_sum (product_id, distributor_weight_sum)
	SELECT 	product_id, isnull(sum(distributor_weight), 100) as distributor_weight_sum
	FROM	##tmp_price
	where	Price <> 0
	group by product_id

	TRUNCATE TABLE ##price_final
	INSERT INTO ##price_final (product_id, Price)
	select	gm.product_id, SUM(Price * distributor_weight / isnull(nullif(s.distributor_weight_sum, 0), 100)) as Price -- Use distributor_weight_sum = 100 if distributor_weight_sum is 0 or null
	from	##tmp_price gm
	left join ##weight_sum s
	on		s.product_id = gm.product_id
	group by gm.product_id


	IF @WhileCounter = 1
	BEGIN
		update	##tmp_cp
		set		Price_Program_Start = ##price_final.Price
		from	##tmp_cp
		inner join ##price_final
		on		##price_final.product_id = ##tmp_cp.BSA_Foodservice_Items_Master_ID
	END
	ELSE
	BEGIN
		update	##tmp_cp
		set		Price_Current = ##price_final.Price
		from	##tmp_cp
		inner join ##price_final
		on		##price_final.product_id = ##tmp_cp.BSA_Foodservice_Items_Master_ID
	END
	SET @WhileCounter = @WhileCounter + 1
END
--- ********************************** Logic to get price - end
select	Item, description, Price_Program_start, Price_current, (Price_current - Price_Program_start) AS variance
from	##tmp_cp
 </cfquery>
 
     <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init("user_report.xls") />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "Users") />
      <!--- Creates the default Font --->
	  <cfset f = workBook.createFont() />
      <cfset cs = workBook.createCellStyle() />
      <cfset cswrap = workBook.createCellStyle() />
      <cfif isDefined("f.BOLDWEIGHT_BOLD")> <cfset f.setBoldweight(f.BOLDWEIGHT_BOLD)> <cfelse> <cfset f.setBold(true)> </cfif>
      <cfset cs.setFont(f) />
      <cfset cswrap.setFont(f) />
      <cfset cswrap.setWrapText(true) />


  	  <!--- Create a row and the Header cell --->
      <cfset row1 = newSheet.createRow(0) />
      <cfset cell1 = row1.createCell(0) />

	  <cfset cell1.setCellValue("Item") />
      <cfset cell1.setCellStyle(cswrap) />

      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("Description") />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("Start Date List Price Per Case ") />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Today List Price Per Case ") />
      <cfset cell4.setCellStyle(cs) />

      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Variance") />
      <cfset cell5.setCellStyle(cs) />
               
     <cfoutput>
	 	 
      <cfloop query="qGetProgramsItemRates">
	   <cfset row2 = newSheet.createRow(#currentRow#) />

		<cfset row2.createCell(0).setCellValue(#Item#) />
		<cfset row2.createCell(1).setCellValue(#description#) />
		<cfset row2.createCell(2).setCellValue(#DollarFormat(Price_Program_start)#) />
		<cfset row2.createCell(3).setCellValue(#DollarFormat(Price_current)#) />
		<cfset row2.createCell(4).setCellValue(#DollarFormat(variance)#) />

	 </cfloop>
    </cfoutput>
    
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	 <cfheader name="Content-Disposition" value="attachment;filename=Program_#RemoveChars(url.Contract_Number,1,4)#_List_Price_Comparison.xls"  />
	 <cfcontent type="application/vnd.ms-excel" file="user_report.xls" deletefile="true"  />	 