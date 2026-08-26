<cfset appSettings = application.appSettingsGet />
<cfset baseSalesLabel = appSettings.getMarginColHeader2() />

<CFSET PAGE_TITLE="#baseSalesLabel# Calculation">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<style>
		TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
		#header {font-size: 12px;}
	</style>

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">


<!----------------- Add Spinner ------------------------>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<!----------------- Add Spinner ------------------------>

<cfparam name="url.type"  default="LB"> <!--- Not being used --->
<cfparam name="URL.CPID" 	default=0>
<cfparam name="URL.CID" 	default=0>
<cfparam name="url.ItemId" default=0>
<CFPARAM name="url.margin_type" default="1"> <!--- Not being used --->
<CFPARAM NAME="STAT_MULTIPLIER" default= "1">  <!--- Not being used --->

<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET URL.CID = cryp.value>


<CFIF ((URL.CPID EQ 0 OR URL.CID EQ 0) AND (URL.ItemID EQ 0 OR URL.CID EQ 0)) OR (URL.CPID NEQ 0 AND NOT isNumeric(URL.CPID) OR NOT isNumeric(URL.CID))>
	<BLOCKQUOTE>
	<BR><BR><BR><SPAN CLASS="TITLE2">Invalid Contract/Product information</SPAN>
	</BLOCKQUOTE>
	<CFABORT>
</CFIF>

<cfset type = url.type>
<CFSET CPID=URL.CPID>
<CFSET CID=URL.CID>
<CFSET ItemId = url.ItemId>
<CFSET productId = replace(ItemId, "_", "-", "ALL") />

<!--- Set the Deliver_Type as "Delivered" for items without a "delivery_type". 1 is "Delivered" --->
<CFQUERY NAME="Product_Details" DATASOURCE="#Application.Datasource#">
	SELECT bsafim.UPC,bsafim.Description,bsafim.net_weight,isnull(nullif(Item_Deliverytype,''),1) As Item_Deliverytype,
	cpm.Item_Allowance_CS
	, cpm.Base_Discount_CS
	, cpm.Price_Subtract_TPA_CS
	, cpm.Price_Subtract_TPA_LB
	FROM BSA_Foodservice_Items_Master bsafim
	LEFT JOIN Contract_Product_Margin cpm
	ON cpm.Product_ID = bsafim.BSA_Foodservice_Items_Master_ID
	WHERE cpm.Contract_Main_ID = '#CID#'
	AND BSA_Foodservice_Items_Master_ID =  '#replace(ItemId, "_", "-", "ALL")#'
</CFQUERY>

<CFQUERY NAME="Program_Details" DATASOURCE="#Application.Datasource#">
	SELECT 	cm.Contract_Number, cm.Contract_Start_Date, cm.Contract_End_Date,
			pcpo.generic_type,
			pcpo.Use_Fixed_Price_As_Base_Sales,
			pcpo.Market_Price,
			Contract_Main_Aux_Data.Price_List_ID,
			Contract_Main_Aux_Data.priceBracket_Update,
			pcpo.Margin_Price_List_Header_ID
	FROM 	Contract_Main cm
	INNER JOIN Program_Control_Panel_Options pcpo
	ON cm.ProgramType_id = pcpo.ProgramControl_Panel_Options_ID
	INNER JOIN Contract_Main_Aux_Data
	ON cm.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
	WHERE cm.Contract_Main_ID = <cfqueryparam value="#CID#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

<CFQUERY NAME="getProgDistributors" datasource="#application.datasource#">
	SELECT 	cd.BSA_Foodservice_Customers_ID,
			bsafc.Name, bsafc.Shr_Ship_To, bsafc.City, bsafc.State, bsafc.ZipCode,
			ISNULL(bsafc.Cash_Discount, 0) as Cash_Discount, 
			CAST(Program_Weight As Decimal(20,2)) as Program_Weight
	FROM 	Contract_Distributors cd
	INNER JOIN BSA_Foodservice_Customers bsafc
	ON 		cd.BSA_Foodservice_Customers_ID = bsafc.BSA_Foodservice_Customers_ID
	AND 	bsafc.Active_Code = 'A' ---D46276 
	AND 	Shr_Ship_To != 'GROUP'---D46276 
	WHERE 	cd.Contract_Main_ID = '#CID#'
	AND 	cd.Deleted = 0
	ORDER BY bsafc.Shr_Ship_To
</CFQUERY>

<CFQUERY NAME="getDistributorTotalWeight" dbtype="query">
	SELECT 	SUM(Program_Weight) as Total_Program_Weight
	FROM 	getProgDistributors	
</CFQUERY>

<cfif application.util.query.get_Setting("margin_display_style", 0) is "custom_t">
    <CFQUERY NAME="qDropTmpTables" datasource="#application.datasource#">
        IF OBJECT_ID('tempdb..##Tmpdisp_Gross_Margin') IS NOT NULL
        DROP TABLE ##Tmpdisp_Gross_Margin
        
        IF OBJECT_ID('tempdb..##TmpDisp_Contract_Distributors') IS NOT NULL
        DROP TABLE ##TmpDisp_Contract_Distributors
        
        IF OBJECT_ID('tempdb..##tmpdisp_oi_dist') IS NOT NULL
        DROP TABLE ##tmpdisp_oi_dist
        
        IF OBJECT_ID('tempdb..##tmpdisp_oi_price') IS NOT NULL
        DROP TABLE ##tmpdisp_oi_price
        
        IF OBJECT_ID('tempdb..##tmpdisp_need_price') IS NOT NULL
        DROP TABLE ##tmpdisp_need_price
    </CFQUERY>
    <CFQUERY NAME="qPopulateGrossmargin" datasource="#application.datasource#">
        DECLARE @Contract_Main_ID int = '#CID#',
                @Product_ID uniqueidentifier = '#replace(ItemId, "_", "-", "ALL")#',
                @Contract_Start_Date DATE = '#DateFormat(Program_Details.Contract_Start_Date,"mm/dd/yyyy")#',
                @Net_Weight decimal(20, 4) = #Product_Details.Net_Weight#

        IF OBJECT_ID('tempdb..##Tmpdisp_Gross_Margin') IS NOT NULL
        DROP TABLE ##Tmpdisp_Gross_Margin

        CREATE TABLE ##Tmpdisp_Gross_Margin
                (	Customer_ID Uniqueidentifier,
                    CS_FOB_Price DECIMAL (20,4),
                    CS_DEL_Price DECIMAL (20, 4)
                )

        IF OBJECT_ID('tempdb..##TmpDisp_Contract_Distributors') IS NOT NULL
        DROP TABLE ##TmpDisp_Contract_Distributors

        SELECT Contract_Distributors_ID, Contract_Main_ID, BFC.BSA_Foodservice_Customers_ID, CAST(contract_distributors.program_weight as decimal(10, 4)) as Program_Weight, BFC.Active_Code
        INTO ##TmpDisp_Contract_Distributors 
        FROM Contract_Distributors 
        INNER JOIN BSA_Foodservice_Customers BFC
        ON BFC.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
        WHERE Contract_Distributors.DELETED = 0 
        AND is_group = 0
        AND Active_Code = 'A'
        AND CONTRACT_MAIN_ID = @Contract_Main_ID
        

        /* A.1. Get all OI fixed price programs for distributors from this program and is for the program start date*/
        IF OBJECT_ID('tempdb..##tmpdisp_oi_dist') IS NOT NULL
        DROP TABLE ##tmpdisp_oi_dist

        select	cm.Contract_Main_ID, cm.Contract_Number, cm.Contract_Start_Date, cm.Contract_End_Date,
                cd.BSA_Foodservice_Customers_ID, CAST(c.program_weight as decimal(10, 4)) as Distributor_Weight,
                fc.Program_Fixed_Component_ID
        into	##tmpdisp_oi_dist
        from	Contract_Main cm
        inner join Program_Fixed_Component fc
        on		fc.Program_ID = cm.Contract_Main_ID
        and		fc.Deleted = 0
        inner join Payment_Type pt
        on		pt.Payment_Type_ID = fc.Claim_Mechanics
        inner join Contract_Distributors cd
        on		cd.Contract_Main_ID = cm.Contract_Main_ID
        and		cd.Deleted = 0
        inner join ##TmpDisp_Contract_Distributors c
        on		c.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
        where	cm.Deleted = 0
        and		cm.Approved = 1
        and		cm.Manual_Cancel = 0
        and		pt.Off_Invoice = 1
        and		@Contract_Start_Date between cm.Contract_Start_Date and cm.Contract_End_Date

        /* A.2. Get the OI prices from above OI programs */
        IF OBJECT_ID('tempdb..##tmpdisp_oi_price') IS NOT NULL
        DROP TABLE ##tmpdisp_oi_price

        select	cm.*,
                cp.BSA_Foodservice_Items_Master_ID,
                pd.Fixed_Price_Value, pd.Unit_Of_Measure_ID, 
                CAST(CASE pd.Unit_Of_Measure_ID WHEN 1 THEN pd.Fixed_Price_Value WHEN 2 THEN pd.Fixed_Price_Value * @Net_Weight END as decimal(20, 5)) as OI_Fixed_Price_CS,
                ROW_NUMBER() OVER(PARTITION BY cm.BSA_Foodservice_Customers_ID, cp.BSA_Foodservice_Items_Master_ID Order By cm.Contract_Start_Date Desc, 
                CAST(CASE pd.Unit_Of_Measure_ID WHEN 1 THEN pd.Fixed_Price_Value WHEN 2 THEN pd.Fixed_Price_Value * @Net_Weight END as decimal(20, 5))) as Row_ID
                /* We will only keep records with Row_ID = 1, Select min start date, min price */
        into	##tmpdisp_oi_price
        from	##tmpdisp_oi_dist cm
        inner join Contract_Products cp
        on		cp.Contract_Main_ID = cm.Contract_Main_ID
        and		cp.Deleted = 0
        and		cp.Product_Type_ID = 1
        inner join Program_Fixed_Price_Product_Data pd
        on		pd.Contract_Products_ID = cp.Contract_Products_ID
        and		pd.Program_Fixed_Component_ID = cm.Program_Fixed_Component_ID
        and		pd.Deleted = 0
        where	cp.BSA_Foodservice_Items_Master_ID = @Product_ID
        and     CAST(pd.Fixed_Price_Value AS FLOAT) != 0.00

        /* A.3. Insert prices into ##Tmpdisp_Gross_Margin */
        INSERT INTO ##Tmpdisp_Gross_Margin (Customer_ID, CS_FOB_Price, CS_DEL_Price)
        SELECT	BSA_Foodservice_Customers_ID, OI_Fixed_Price_CS, OI_Fixed_Price_CS
        FROM	##tmpdisp_oi_price
        WHERE	Row_ID = 1

        /* B. Get price from special/regular price list if price not found above */
        IF OBJECT_ID('tempdb..##tmpdisp_need_price') IS NOT NULL
        DROP TABLE ##tmpdisp_need_price

        SELECT	contract_distributors.bsa_foodservice_customers_id, 
                CAST(null as decimal(20, 4)) as CS_FOB_Price, 
                CAST(null as decimal(20, 4)) as CS_DEL_Price
        INTO	##tmpdisp_need_price
        FROM ##TmpDisp_Contract_Distributors	contract_distributors 
        WHERE contract_distributors.Active_Code = 'A'
        AND	NOT EXISTS (
            SELECT	1 
            FROM	##Tmpdisp_Gross_Margin gm 
            WHERE	gm.Customer_ID = contract_distributors.bsa_foodservice_customers_id
        )

        -- Get special price
        -- Get special price where program start date between price list start and end date
        -- If there are no results, use the future price with the Min Start Date
        IF OBJECT_ID('tempdb..##tmp_special_price') IS NOT NULL
        DROP TABLE ##tmp_special_price

        SELECT	Price_List_Header_Special.Customers_ID,
                price_list_detail_Special.product_id,
                price_list_detail_Special.CS_FOB_Price,
                price_list_detail_Special.CS_Bracket_1,
                ROW_NUMBER() Over (Partition By Price_List_Header_Special.Customers_ID, price_list_detail_Special.product_id Order By price_list_detail_Special.Start_Date) as Row_ID
        INTO	##tmp_special_price
        FROM Price_List_Header_Special
        INNER JOIN price_list_detail_Special
        ON	price_list_detail_Special.Price_List_Header_Special_ID = Price_List_Header_Special.Price_List_Header_Special_ID
        AND	price_list_detail_Special.Deleted = 0
        AND	price_list_detail_Special.End_Date >= @Contract_Start_Date
        WHERE	Price_List_Header_Special.Deleted = 0
        AND		price_list_detail_Special.product_id = @Product_ID
        AND		EXISTS (
            SELECT	1
            FROM	##tmpdisp_need_price p
            WHERE	p.bsa_foodservice_customers_id = Price_List_Header_Special.Customers_ID
        )

        UPDATE	np
        SET		CS_FOB_Price = sp.CS_FOB_Price,
                CS_DEL_Price = sp.CS_Bracket_1
        FROM	##tmpdisp_need_price np
        INNER JOIN ##tmp_special_price sp
        ON		sp.Customers_ID = np.BSA_Foodservice_Customers_ID
        WHERE	sp.Row_ID = 1

        -- Get regular price
        -- Get regular price where program start date between price list start and end date
        -- If there are no results, use the future price with the Min Start Date
        IF OBJECT_ID('tempdb..##tmp_regular_price') IS NOT NULL
        DROP TABLE ##tmp_regular_price

        SELECT	price_list_detail.product_id,
                price_list_detail.CS_FOB_Price,
                price_list_detail.CS_Bracket_1,
                ROW_NUMBER() Over (Partition By price_list_detail.product_id Order By price_list_detail.Start_Date) as Row_ID
        INTO	##tmp_regular_price
        FROM price_list_header
        INNER JOIN price_list_detail
        ON	price_list_detail.price_list_header_id = price_list_header.price_list_header_id
        AND	price_list_detail.Deleted = 0
        AND	price_list_detail.End_Date >= @Contract_Start_Date
        WHERE	price_list_header.Deleted = 0
        AND		price_list_detail.product_id = @Product_ID
        AND		EXISTS (
            SELECT	1
            FROM	##tmpdisp_need_price p
            WHERE	p.CS_FOB_Price IS NULL -- special price not found
        )

        UPDATE	p
        SET		CS_FOB_Price = rp.CS_FOB_Price,
                CS_DEL_Price = rp.CS_Bracket_1
        FROM ##tmpdisp_need_price p
        INNER JOIN ##tmp_regular_price rp
        ON		p.CS_FOB_Price IS NULL -- special price not found

        /* C. For product/customer that did not find a price, get OI fixed price from current program */
        IF EXISTS (SELECT 1 FROM ##tmpdisp_need_price WHERE CS_FOB_Price IS NULL)
        BEGIN
        
            DECLARE @Fixed_Price_Val decimal(20,5 )

            SELECT 	@Fixed_Price_Val = Min(CAST(CASE F.Unit_Of_Measure_ID WHEN 1 THEN F.Fixed_Price_Value WHEN 2 THEN F.Fixed_Price_Value * @Net_Weight END as decimal(20, 5)))
            FROM 	Contract_Products CP
            INNER JOIN Program_Fixed_Price_Product_Data F
            ON		F.Deleted = 0
            AND		F.Contract_Products_ID = CP.Contract_Products_ID
            INNER JOIN Program_Fixed_Component fc
            ON		fc.Program_Fixed_Component_ID = F.Program_Fixed_Component_ID
            INNER JOIN Payment_Type pt
            ON		pt.Payment_Type_ID = fc.Claim_Mechanics
            WHERE	CP.Contract_Main_ID = '#CID#'
            AND		CP.Deleted = 0
            AND		CP.Product_Type_ID = 1
            AND		CP.BSA_Foodservice_Items_Master_ID = @Product_ID
            AND     CAST(F.Fixed_Price_Value AS FLOAT) != 0.00
            AND		pt.Off_Invoice = 1

            IF @Fixed_Price_Val IS NOT NULL
            BEGIN
        
                UPDATE	p
                SET		CS_FOB_Price = @Fixed_Price_Val,
                        CS_DEL_Price = @Fixed_Price_Val
                FROM    ##tmpdisp_need_price p
                WHERE CS_FOB_Price IS NULL

            END

        END
        
        INSERT INTO ##Tmpdisp_Gross_Margin (Customer_ID, CS_FOB_Price, CS_DEL_Price)
        SELECT	BSA_Foodservice_Customers_ID, CS_FOB_Price, CS_DEL_Price
        FROM	##tmpdisp_need_price
        WHERE	CS_FOB_Price IS NOT NULL
        
        

    </CFQUERY>
</cfif> <!--- <cfif application.util.query.get_Setting("margin_display_style", 0) is "custom_t"> --->
    
<cfset totalDistributorWeight = getDistributorTotalWeight.Total_Program_Weight />
<cfset validProgramWeight = 0.00>
<cfset Weighted_Base_Price_CS = 0>
<cfset Sum_Base_Price_CS = 0 />
<cfset Total_Weighted_Base_Price_CS = 0 />

<cfset Program_Fixed_Price_CS = 0 />
<cfset Program_Bracket_Price_CS = 0 />
<cfset Program_Template_Price_CS = 0 />


<cfif appSettings.getPriceListByTemplate() EQ 1 AND Program_Details.Market_Price EQ 0>
	<cfset qTemplatePrice = CreateObject("component", "components.programs.ProgramManager").getItemCustPriceTemplatePS(
			product_id = productId,
			Contract_Main_ID = CID,
			priceHeaderListID = Program_Details.Margin_Price_List_Header_ID) />
	<cfif qTemplatePrice.recordCount>
		<cfset Program_Template_Price_CS = qTemplatePrice.FOB_CS_Price />
	</cfif> 

<cfelseif appSettings.getUseFixedPriceType()>
	<cfset qBracketPrice = CreateObject("component", "components.programs.bid_request.BidRequestProductManager").getItemCustPriceForFP(
			product_id = productId,
			Contract_Main_ID = CID,
			priceListID = Program_Details.Price_List_ID) />
	<cfif qBracketPrice.recordCount>
		<cfset Program_Bracket_Price_CS = qBracketPrice.FOB_CS_Price />
	</cfif> 
<cfelseif Program_Details.Use_Fixed_Price_As_Base_Sales OR Program_Details.Market_Price>
	<CFQUERY NAME="getProgramFixedPrice" datasource="#application.datasource#">
		SELECT 	AVG(
			<cfif Program_Details.Market_Price>
				CASE
				WHEN Unit_Of_Measure_ID = 1 THEN
						CAST(ISNULL(PFPPD.Market_Price_Rate,0) AS DECIMAL(10,4))
				WHEN Unit_Of_Measure_ID = 2 THEN
						CAST(ISNULL(PFPPD.Market_Price_Rate,0) AS DECIMAL(10,4)) * #Product_Details.Net_Weight#
				ELSE
					0
				END) 
			<cfelse>
				CASE
				WHEN Unit_Of_Measure_ID = 1 THEN
						CAST(ISNULL(PFPPD.Fixed_Price_Value,0) AS DECIMAL(10,4))
				WHEN Unit_Of_Measure_ID = 2 THEN
						CAST(ISNULL(PFPPD.Fixed_Price_Value,0) AS DECIMAL(10,4)) * #Product_Details.Net_Weight#
				ELSE
					0
				END) 
			</cfif>
				as Fixed_Price_Value
		FROM 	Contract_Products CP
		INNER JOIN Program_Fixed_Price_Product_Data PFPPD
		ON		PFPPD.Deleted = 0
		AND		PFPPD.Contract_Products_ID = CP.Contract_Products_ID
		<cfif Program_Details.Market_Price>
			AND 	ISNULL(CAST(PFPPD.Fixed_Price_Value AS FLOAT), 0) != 0.00
		<cfelse>
			AND 	CAST(ISNULL(PFPPD.Fixed_Price_Value,0) AS DECIMAL(10,4)) != 0.00
		</cfif>
		WHERE	CP.Contract_Main_ID = '#CID#'
		AND		CP.Deleted = 0
		AND		CP.Product_Type_ID = 1
		AND		CP.BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'		
	</CFQUERY>
	<cfif getProgramFixedPrice.recordCount>
		<cfset Program_Fixed_Price_CS = getProgramFixedPrice.Fixed_Price_Value />
	</cfif>
</cfif>

<!--- Get Base Price for a Product --->
	<CFQUERY NAME="getBasePrice" datasource="#application.datasource#">
		SELECT CASE #Product_Details.Item_Deliverytype#
			WHEN 2 
				THEN
					ITEM_FOB_BASE_PRICE
			ELSE
					ITEM_DEL_BASE_PRICE
			END
			As CS_Price
		FROM 	Item_Margin_Targets imt
		WHERE 	imt.product_id = '#replace(ItemId, "_", "-", "ALL")#'
		AND 	imt.Deleted = 0
	</CFQUERY>

<BLOCKQUOTE>
<BR><BR>
<SPAN CLASS="TITLE2"><CFOUTPUT>#baseSalesLabel#</CFOUTPUT> Calculation</SPAN>
<HR COLOR="Orange">
<CFOUTPUT QUERY="Program_Details">
<TABLE border="0" WIDTH="90%">
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Program:</B>&nbsp;&nbsp;[#Contract_Number#]</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Center"><B>Start Date:</B>&nbsp;&nbsp;#DateFormat(Contract_Start_Date,"mm/dd/yyyy")#</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Right"><B>End Date:</B>&nbsp;&nbsp;#DateFormat(Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
	</TR>
</TABLE>
<HR COLOR="Orange">
</CFOUTPUT>

<CFOUTPUT>
<TABLE BORDER="0">
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" width="100"><B>PRODUCT:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="left"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#Product_Details.UPC# - </cfif></cfif>#Product_Details.Description#</B></TD>
	</TR>
	<!--- Display the bracket --->
	<cfif appSettings.getUseFixedPriceType()>
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" width="100"><B>PRICE BRACKET:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="left"><B>
			<!--- Dev Note: drachala; D28453: When displaying price bracket do not display the price list id  START                
                What  I did: added ListLast to display numbers after "_"--->
			<!---#Program_Details.Price_List_ID#--->
				#ListLast(Program_Details.price_list_id, "_")#
			<!--- End Dev Note drachala D28453 When displaying price bracket do not display the price list id --->
			<cfif Program_Details.priceBracket_Update eq 1><sup class="overriddenShow">*</sup></cfif></B></TD>
	</TR>
	</cfif>
</TABLE>
</CFOUTPUT>

<cfoutput>
<TABLE CLASS="Maintable" WIDTH="90%" CELLPADDING="3" CELLSPACING="0" ALIGN="center" border="0">
		<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<td>&nbsp;</td>
			<TD ID="header" NOWRAP WIDTH="75"><B><CFOUTPUT>#application.returned_customer_setting.shard_ship_to_label#</CFOUTPUT></B></TD>
			<TD ID="header"><B>Name</B></TD>
			<TD colspan="7">&nbsp;</TD>
			<TD ID="header" ALIGN="LEFT"><B>#baseSalesLabel#</B></TD>
			<TD ID="header" ALIGN="CLEFT"><B>Weight</B></TD>
		</TR>
</cfoutput>

<CFOUTPUT QUERY="getProgDistributors">
	<cfset Customer_ID = BSA_Foodservice_Customers_ID>
	<!----
	-- D16849: Template-level control of base sales with fixed price programs
	-- The new template choice will display as Use Fixed Price as Base Sales
	-- If this switch is on, we will use the fixed price from the program as the base sales value if there is a fixed price in the program; otherwise, the current logic will continue forward
	#appSettings.getUseFixedPriceType()# :: #Program_Details.Market_Price# ::#appSettings.getPriceListByTemplate()# ----> 
	<cfif appSettings.getPriceListByTemplate() EQ 1 AND (Program_Details.Market_Price EQ 0)>
		<cfset Base_Price = Program_Template_Price_CS />
	<cfelseif appSettings.getUseFixedPriceType()>
		<cfset Base_Price = Program_Bracket_Price_CS />
	<cfelseif (Program_Details.Use_Fixed_Price_As_Base_Sales OR Program_Details.Market_Price) AND Program_Fixed_Price_CS GT 0>
		<cfset Base_Price = Program_Fixed_Price_CS />
	<cfelse>
        <cfif application.util.query.get_Setting("margin_display_style", 0) is "custom_t">
            <!--- Get Base Price for a Customer/Product Combo --->
            <CFQUERY NAME="getBasePriceFromgrossMargin" datasource="#application.datasource#">
                SELECT 
                    CASE #Product_Details.Item_Deliverytype#
                    WHEN 2 
                            -- Bcoz of duplicate records, we are using AVG
                        THEN
                            AVG(CS_FOB_Price) 
                    ELSE
                            AVG(CS_DEL_Price)
                    END
                    As CS_Price
                FROM 	##Tmpdisp_Gross_Margin
                WHERE 	Customer_ID = '#Customer_ID#'
            </CFQUERY>
        <cfelse>
            <!--- Get Base Price for a Customer/Product Combo --->
            <CFQUERY NAME="getBasePriceFromgrossMargin" datasource="#application.datasource#">
                SELECT 
                    CASE #Product_Details.Item_Deliverytype#
                    WHEN 2 
                            -- Bcoz of duplicate records, we are using AVG
                        THEN
                            AVG(CS_FOB_Price) 
                    ELSE
                            AVG(CS_DEL_Price)
                    END
                    As CS_Price
                FROM 	gross_Margin
                WHERE 	Customer_ID = '#Customer_ID#'
                AND 	product_id = '#replace(ItemId, "_", "-", "ALL")#'
                AND 	Deleted =0
            </CFQUERY>
        </cfif>
		<cfif getBasePriceFromgrossMargin.recordcount eq 0 or getBasePriceFromgrossMargin.CS_Price eq "">
				<!--- Get Base Price for a Product (If record not found in Gross Margin) --->
			<cfset Base_Price = getBasePrice.CS_Price>
		<cfelse>
			<cfset  Base_Price = getBasePriceFromgrossMargin.CS_Price>
		</cfif>

	</cfif>
	<!--- If after all that you still don't have a base price, set it to 0 --->
	<cfif len(trim(Base_Price)) IS 0>
		<cfset Base_Price = 0>
	</cfif>
	
	<!--- default --->
	<cfset Base_Price_LB = 0>
	<cfset prodUOM = "CS">
	
	<!--- Dev Note (74985) - For UOM of "LB". --->
	<cfif url.margin_type eq 3>
		<cfset Base_Price_LB = Base_Price / Product_Details.Net_Weight>
		<cfset prodUOM = "LB">
	</cfif>

	<CFIF getProgDistributors.Shr_Ship_To NEQ "">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<td>&nbsp;</td>
			<TD>#getProgDistributors.Shr_Ship_To#</TD>
			<TD>#getProgDistributors.Name# (#getProgDistributors.City#, #getProgDistributors.State#)</TD>
			<TD colspan="7">&nbsp;</TD>
			<!--- For UOM of "LB" --->
			<cfif url.margin_type eq 3>
			<CFSET data = trim(numberformat(Base_Price_LB,"___,___,___,___,___,___,___,___.___"))>
			<cfelse>
			<CFSET data = trim(numberformat(Base_Price,"___,___,___,___,___,___,___,___.___"))>
			</cfif>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#/#prodUOM#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: black;""><B>#data# / #prodUOM#</B></SPAN>"></CFIF>
			<TD ALIGN="LEFT">#data#</TD>
			<TD ALIGN="LEFT"><cfif Base_Price neq 0>#Program_Weight#%<cfelse>&nbsp;</cfif></TD>
			<!--- Dev Note: 19373 (Milan) - For eg: Weighted Base_Price for base_price of 27 with distributor weight of 20% will be (27 * .2) --->
			<cfset Weighted_Base_Price_CS = Base_Price * (Program_Weight / totalDistributorWeight) />
			<!--- Dev Note: 19373 (Milan) - Add the weighted_base_prices for all the base_prices that have a base_price. Base_prices of 0 
						will be ignored because anything multiplied by 0 will be 0.			
			--->
			<cfset Sum_Base_Price_CS = Sum_Base_Price_CS + Weighted_Base_Price_CS />
			<!--- Dev Note: 19373 (Milan) - Get the validProgramWeight - For eg: if we have 4 distributors, 2 with a weight of 20% and 40% each and the remaining
						2 with a weight of 15% each. We are only interested in the first two distributors as they have a valid base_price.
				--->
			<cfif Base_Price neq 0>
				<cfset validProgramWeight = validProgramWeight + Program_Weight>
			</cfif>
		</TR>
		</CFIF>
	
</CFOUTPUT>
	<!--- Dev Note: 19373 (Milan) - Here the Sum_Base_Price_CS will be divided by the validProgramWeight only and not weight of all distributors --->
	<cfif validProgramWeight neq 0>
		<cfset Total_Weighted_Base_Price_CS = Sum_Base_Price_CS / (validProgramWeight/totalDistributorWeight)>
	<cfelse>
		<cfset Total_Weighted_Base_Price_CS = 0 />
	</cfif>

		<CFOUTPUT>
		<CFIF getProgDistributors.Shr_Ship_To NEQ "">
		<!--- For UOM of "CS" --->
		<cfsavecontent variable="showCS">
		<TR ALIGN="LEFT">
			<TD COLSPAN="11" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>#baseSalesLabel# / CS <cfif url.margin_type neq 3>(&##931; Wtd #baseSalesLabel#)</cfif> = </B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(Total_Weighted_Base_Price_CS,"___,___,___,___,___,___,___,___.___"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: NAVY;""><B>$#data#</B></SPAN>"></CFIF>
			<B>#data#</B>
			</TD>
	</TR>
	<cfif  VAL(Product_Details.Price_Subtract_TPA_CS) NEQ 0>
	<TR ALIGN="LEFT">
		<TD COLSPAN="11" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
		<B>#appsettings.getMarginColHeader6()# / CS = </B>
		</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
		<cfset data1 = Product_Details.Price_Subtract_TPA_CS>
		<CFIF data1 LT 0><CFSET data1 = "<SPAN STYLE=""color: red;""><b>[$#data1#]</b></SPAN>"><CFELSE><CFSET data1 = "<SPAN STYLE=""color: NAVY;""><B>$#data1#</B></SPAN>"></CFIF>
		<B>#data1#</B>
		</TD>
	</TR>
	<TR ALIGN="LEFT">
		<TD COLSPAN="11" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">&nbsp;</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
		<cfset data = Total_Weighted_Base_Price_CS - Product_Details.Price_Subtract_TPA_CS>			
		<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: NAVY;""><B>$#data#</B></SPAN>"></CFIF>	
		<B>#baseSalesLabel# / CS = #data#</B>
		</TD>
	</TR>	
	</cfif>		
	
		</cfsavecontent>

		<cfset Sum_Base_Price_LB = Total_Weighted_Base_Price_CS / Product_Details.Net_Weight>
		<!--- For UOM of "LB" --->
		<cfsavecontent variable="showLB">
		<TR ALIGN="LEFT">
			<TD COLSPAN="11" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>#baseSalesLabel# / LB <cfif url.margin_type eq 3>(&##931; Wtd #baseSalesLabel#)</cfif> = </B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(Sum_Base_Price_LB,"___,___,___,___,___,___,___,___.___"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: NAVY;""><B>$#data#</B></SPAN>"></CFIF>
			<B>#data#</B>
			</TD>
		</TR>
	<cfif  VAL(Product_Details.Price_Subtract_TPA_LB) NEQ 0>
	<TR ALIGN="LEFT">
		<TD COLSPAN="11" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
		<B>#appsettings.getMarginColHeader6()# / LB = </B>
		</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
		<cfset data1 = Product_Details.Price_Subtract_TPA_LB>
		<CFIF data1 LT 0><CFSET data1 = "<SPAN STYLE=""color: red;""><b>[$#data1#]</b></SPAN>"><CFELSE><CFSET data1 = "<SPAN STYLE=""color: NAVY;""><B>$#data1#</B></SPAN>"></CFIF>
		<B>#data1#</B>
		</TD>
	</TR>
	<TR ALIGN="LEFT">
		<TD COLSPAN="11" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">&nbsp;</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
		<cfset data = Sum_Base_Price_LB - Product_Details.Price_Subtract_TPA_LB>		
		<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: NAVY;""><B>$#data#</B></SPAN>"></CFIF>	
		<B>#baseSalesLabel# / LB = #data#</B>
		</TD>
	</TR>	
	</cfif>				
		</cfsavecontent>

		<!--- For UOM of "LB", show "LB" first. --->
		<cfif url.margin_type eq 3>
			#showLB##showCS#
		<cfelse>
			#showCS##showLB#
		</cfif>
		</CFIF>
		</CFOUTPUT>		
		</TABLE>
		
	<center>
	<CF_button
		button_name		=	""
		button_caption	=	"close window"
		button_action	=	"window.close();"
		button_type		=	"javascript_link"
		button_width	=	"50"
		button_color	=	"Navy"
		button_tip		=	"execute"
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
	</center>
</BLOCKQUOTE>
</BODY>
</HTML>