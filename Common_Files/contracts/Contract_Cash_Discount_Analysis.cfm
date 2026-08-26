<CFSET PAGE_TITLE="Cash Discount Calculation">
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


<cfset appSettings = application.appSettingsGet />

<CFQUERY NAME="Product_Details" DATASOURCE="#Application.Datasource#">
	SELECT bsafim.UPC,bsafim.Description,bsafim.net_weight,Item_Deliverytype,
	cpm.Item_Allowance_CS,
	cpm.Base_Discount_CS
	FROM BSA_Foodservice_Items_Master bsafim
	LEFT JOIN Contract_Product_Margin cpm
	ON cpm.Product_ID = bsafim.BSA_Foodservice_Items_Master_ID
	WHERE cpm.Contract_Main_ID = '#CID#'
	AND BSA_Foodservice_Items_Master_ID =  '#replace(ItemId, "_", "-", "ALL")#'
</CFQUERY>

<CFQUERY NAME="Program_Details" DATASOURCE="#Application.Datasource#">
	SELECT 	cm.Contract_Number, cm.Contract_Start_Date, cm.Contract_End_Date,pcpo.generic_type,
			pcpo.Use_Fixed_Price_As_Base_Sales
	FROM 	Contract_Main cm
	INNER JOIN Program_Control_Panel_Options pcpo
	ON cm.ProgramType_id = pcpo.ProgramControl_Panel_Options_ID
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
	WHERE 	cd.Contract_Main_ID = '#CID#'
	AND 	cd.Deleted = 0
	ORDER BY bsafc.Shr_Ship_To
</CFQUERY>

<CFQUERY NAME="getDistributorTotalWeight" dbtype="query">
	SELECT 	SUM(Program_Weight) as Total_Program_Weight
	FROM 	getProgDistributors	
</CFQUERY>

<cfset totalDistributorWeight = getDistributorTotalWeight.Total_Program_Weight />

<cfset Program_Fixed_Price_CS = 0 />
<cfif Program_Details.Use_Fixed_Price_As_Base_Sales>
	<CFQUERY NAME="getProgramFixedPrice" datasource="#application.datasource#">
		SELECT 	AVG(
				CASE
				WHEN Unit_Of_Measure_ID = 1 THEN
						ISNULL(CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS FLOAT), 0)
				WHEN Unit_Of_Measure_ID = 2 THEN
						ISNULL(CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS FLOAT), 0) * #Product_Details.Net_Weight#
				ELSE
					0
				END) as Fixed_Price_Value
		FROM 	Contract_Products
		INNER JOIN Program_Fixed_Price_Product_Data
		ON		Program_Fixed_Price_Product_Data.Deleted = 0
		AND		Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
		AND 	ISNULL(CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS FLOAT), 0) != 0.00
		WHERE	Contract_Products.Contract_Main_ID = '#CID#'
		AND		Contract_Products.Deleted = 0
		AND		Contract_Products.Product_Type_ID = 1
		AND		Contract_Products.BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'		
	</CFQUERY>
	<cfif getProgramFixedPrice.recordCount>
		<cfset Program_Fixed_Price_CS = getProgramFixedPrice.Fixed_Price_Value />
	</cfif>
</cfif>

<BLOCKQUOTE>
<BR><BR>
<SPAN CLASS="TITLE2">Cash Discount Calculation</SPAN>
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
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#Product_Details.UPC# - </cfif></cfif>#Product_Details.Description#</B></TD>
	</TR>
</TABLE>
</CFOUTPUT>
<cfif appsettings.getlocalcostvariables() neq 1>
	<cfset cashDiscountLabel = appSettings.getMarginColHeader3() />
<cfelse>
	<cfset cashDiscountLabel = appSettings.getMarginColHeader4() />
</cfif>
<cfoutput>
<TABLE CLASS="Maintable" WIDTH="90%" CELLPADDING="3" CELLSPACING="0" ALIGN="center" border="0">
		<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<td>&nbsp;</td>
			<TD ID="header" NOWRAP WIDTH="75"><B><CFOUTPUT>#application.returned_customer_setting.shard_ship_to_label#</CFOUTPUT></B></TD>
			<TD ID="header"><B>Name</B></TD>
			<TD ID="header" ALIGN="LEFT"><B>#cashDiscountLabel# %</B></TD>
			<TD ID="header" ALIGN="LEFT"><B>#appsettings.getMarginColHeader2()#	</B></TD>
			<TD ID="header" ALIGN="CLEFT"><B>#cashDiscountLabel#</B></TD>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header" ALIGN="CLEFT"><B>Weight</B></TD>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header" NOWRAP ALIGN="LEFT"><B>Wtd<br />#cashDiscountLabel#</B></TD>
		</TR>
</cfoutput>
<cfset Sum_Cash_Discount_CS = 0 />
<CFOUTPUT QUERY="getProgDistributors">
	<cfset Customer_ID = BSA_Foodservice_Customers_ID>
	<!----
	-- D16849: Template-level control of base sales with fixed price programs
	-- The new template choice will display as ‘Use Fixed Price as Base Sales’
	-- If this switch is on, we will use the fixed price from the program as the base sales value if there is a fixed price in the program; otherwise, the current logic will continue forward
	---->
	<cfif Program_Details.Use_Fixed_Price_As_Base_Sales AND Program_Fixed_Price_CS GT 0>
		<cfset Base_Price = Program_Fixed_Price_CS />
	<cfelse>
		<!--- Get Base Price for a Customer/Product Combo --->
		<CFQUERY NAME="getBasePrice" datasource="#application.datasource#">
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
	
		<cfif getBasePrice.recordcount eq 0 or getBasePrice.CS_Price eq "">
			<!--- Get Base Price for a Product (If record not found in Gross Margin) --->
			<CFQUERY NAME="getBasePrice" datasource="#application.datasource#">
				SELECT CASE #Product_Details.Item_Deliverytype#
					WHEN 2 
						THEN
							ITEM_FOB_BASE_PRICE_CS
					ELSE
							ITEM_DEL_BASE_PRICE_CS
					END
					As CS_Price
				FROM 	Item_Margin_Targets imt
				WHERE 	imt.product_id = '#replace(ItemId, "_", "-", "ALL")#'
				AND 	imt.Deleted = 0
			</CFQUERY>
		</cfif>
		
		<cfset Base_Price = getBasePrice.CS_Price>
	
	</cfif>
	<!--- If after all that you still don't have a base price, set it to 0 --->
	<cfif len(trim(Base_Price)) IS 0>
		<cfset Base_Price = 0>
	</cfif>

	<cfset Cash_Discount_CS = Base_Price * Cash_Discount />

	<CFIF getProgDistributors.Shr_Ship_To NEQ "">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<td>&nbsp;</td>
			<TD>#getProgDistributors.Shr_Ship_To#</TD>
			<TD>#getProgDistributors.Name# (#getProgDistributors.City#, #getProgDistributors.State#)</TD>
			<TD ALIGN="LEFT">

			<CFSET data = trim(numberformat(Cash_Discount * 100,"___,___,___,___,___,___,___,___.___"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#UOM_Prepend##data##UOM_Append#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: black;""><B>#data# %</B></SPAN>"></CFIF>
			#data#
			</TD>
			
			<CFSET data = trim(numberformat(Base_Price,"___,___,___,___,___,___,___,___.___"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#/CS]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: black;""><B>#data# / CS</B></SPAN>"></CFIF>
			<TD ALIGN="LEFT">#data#</TD>
			
			<CFSET data = trim(numberformat(Cash_Discount_CS,"___,___,___,___,___,___,___,___.___"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: black;""><B>$#data# / CS</B></SPAN>"></CFIF>			
			<TD ALIGN="LEFT">#data#</TD>

			<TD ALIGN="LEFT">*</TD>
			<TD ALIGN="LEFT">#Program_Weight#%</TD>
			<TD ALIGN="LEFT">=</TD>
			<TD ALIGN="LEFT">

			<cfset Weighted_Cash_Discount_CS = (Cash_Discount_CS * Program_Weight) / totalDistributorWeight />
			<cfset Sum_Cash_Discount_CS = Sum_Cash_Discount_CS + Weighted_Cash_Discount_CS />

			<cfset data = trim(numberformat(Weighted_Cash_Discount_CS,"___,___,___,___,___,___,___,___.______"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: black;""><B>$#data#</B></SPAN>"></CFIF>
			#data#
			</TD>
		</TR>
		</CFIF>
	
</CFOUTPUT>

		<CFOUTPUT>
		<CFIF getProgDistributors.Shr_Ship_To NEQ "">
		<TR ALIGN="LEFT">
			<TD COLSPAN="9" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>#cashDiscountLabel# / CS (&##931; Wtd #cashDiscountLabel#) = </B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(Sum_Cash_Discount_CS,"___,___,___,___,___,___,___,___.___"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: NAVY;""><B>$#data#</B></SPAN>"></CFIF>
			<B>#data#</B>
			</TD>
		</TR>
			<cfset Sum_Cash_Discount_LB = Sum_Cash_Discount_CS / Product_Details.Net_Weight>

		<TR ALIGN="LEFT">
			<TD COLSPAN="9" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>#cashDiscountLabel# / LB = </B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(Sum_Cash_Discount_LB,"___,___,___,___,___,___,___,___.___"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: NAVY;""><B>$#data#</B></SPAN>"></CFIF>
			<B>#data#</B>
			</TD>
		</TR>
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