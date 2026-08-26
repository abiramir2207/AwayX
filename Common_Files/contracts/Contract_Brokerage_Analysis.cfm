<CFSET PAGE_TITLE="Brokerage Calculation">
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
	SELECT 	cm.Contract_Number, cm.Contract_Start_Date, cm.Contract_End_Date,pcpo.generic_type
	FROM 	Contract_Main cm
	INNER JOIN Program_Control_Panel_Options pcpo
	ON cm.ProgramType_id = pcpo.ProgramControl_Panel_Options_ID
	WHERE cm.Contract_Main_ID = <cfqueryparam value="#CID#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

<CFQUERY NAME="getProgDistributors" datasource="#application.datasource#">
 SELECT cd.BSA_Foodservice_Customers_ID,
		bsafc.Name,bsafc.Shr_Ship_To,bsafc.City,bsafc.State, ISNULL(bsafc.Cash_Discount, 0) as Cash_Discount,
		Program_Weight
 FROM Contract_Distributors cd
 INNER JOIN BSA_Foodservice_Customers bsafc
 ON cd.BSA_Foodservice_Customers_ID = bsafc.BSA_Foodservice_Customers_ID
 WHERE cd.Contract_Main_ID = '#CID#'
 AND cd.Is_Group = 0
 AND cd.Deleted = 0
</CFQUERY>

<CFQUERY NAME="getDistributorWeight" datasource="#application.datasource#">
SELECT SUM(CAST(Program_Weight As Decimal(20,2))) as Total_Program_Weight
FROM Contract_Distributors
WHERE Contract_Main_ID =  '#CID#'
AND Is_Group = 0
AND Deleted = 0
</CFQUERY>

<!--- Status of Zero means "Net out of Base Sales" - Check "margin settings" page --->
<CFQUERY NAME="GetDiscountStatus" datasource="#application.datasource#">
	SELECT Column_Name
	FROM Brokerage_Margin_Calc_Settings BMC
	WHERE Status = 0
</CFQUERY>

<BLOCKQUOTE>
<BR><BR>
<SPAN CLASS="TITLE2">Brokerage Calculation</SPAN>
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

<cfset Include_Cash_Discount = 0>
<cfset Include_Allowance = 0>
<cfset Include_Trade_Adjustment = 0>
<cfset ShowColumns = 9>

<TABLE CLASS="Maintable" WIDTH="90%" CELLPADDING="3" CELLSPACING="0" ALIGN="center" border="0">
		<TR BGCOLOR="#FFCE84" VALIGN="bottom">
			<td>&nbsp;</td>
			<TD ID="header" WIDTH="140" NOWRAP><B>Name</B></TD>
			<TD ID="header" WIDTH="75" ALIGN="LEFT" NOWRAP><B>Source</B></TD>
			<TD ID="header" ALIGN="LEFT"><B>Brkr Comm</B></TD>
		<CFOUTPUT>
			<TD ID="header" ALIGN="LEFT"><B>#appsettings.getMarginColHeader3()#</B></TD>
			<cfloop query="GetDiscountStatus">
			<cfif lcase(Column_Name) eq 'cash_discount'>
				<cfset Include_Cash_Discount = 1>
				<cfset ShowColumns = ShowColumns + 1>
				<TD ID="header" ALIGN="LEFT"><B>
					<cfif appsettings.getlocalcostvariables() neq 1>
					#appSettings.getMarginColHeader3()#
					<cfelse>
					#appSettings.getMarginColHeader4()#
					</cfif>
				</B></TD>
			<cfelseif lcase(Column_Name) eq 'allowance'>
				<cfset Include_Allowance = 1>
				<cfset ShowColumns = ShowColumns + 1>
				<TD ID="header" ALIGN="LEFT"><B>#appSettings.getMarginColHeader5()#</B></TD>
			<cfelseif lcase(Column_Name) eq 'trade_adjustment'>
				<cfset Include_Trade_Adjustment = 1>
				<cfset ShowColumns = ShowColumns + 1>
				<TD ID="header" ALIGN="LEFT"><B>#appSettings.getMarginColHeader6()#</B></TD>	
			</cfif>
			</cfloop>
		</CFOUTPUT>
			<TD ID="header" ALIGN="LEFT"><B>Brkr Exp</B></TD>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header" ALIGN="LEFT"><B>Weight</B></TD>
			<TD ID="header">&nbsp;</TD>
			<TD ID="header" NOWRAP ALIGN="LEFT"><B>Wtd<br />Brkr Exp</B></TD>
		</TR>

<cfset Sum_Weighted_Rate = 0>
<CFOUTPUT QUERY="getProgDistributors">
<cfset Customer_ID = BSA_Foodservice_Customers_ID>
<!--- Get Brokerage Information for Customer/Prod combo --->
	<CFQUERY NAME="getBrokerageCustomer" datasource="#application.datasource#">
	SELECT bcpr.*
	,uom.Abbreviation
	FROM Brokerage_Customer_Product_Rate bcpr
	INNER JOIN BSA_Foodservice_Items_Master bsafim
	ON bcpr.Product_Id = bsafim.BSA_Foodservice_Items_Master_ID
	INNER JOIN Units_Of_Measure uom
	ON UOM.Unit_Of_Measure_id = bcpr.Rate_UOM
	WHERE bcpr.Customer_Id = '#Customer_ID#'
	AND CAST(bcpr.Product_Id As varchar(50)) =  '#replace(ItemId, "_", "-", "ALL")#'
	</CFQUERY>

<cfif appSettings.getOperatorTPAInDistributorPrograms() AND (Program_Details.generic_type eq 'Operator Direct or HQ Programs' OR 
Program_Details.generic_type eq 'Operator-Deviated Pricing')>
	<CFQUERY NAME="GetTPA" DATASOURCE="#Application.Datasource#">
	SELECT	SUM(CAST(CAST(pdt.Rate AS Float) AS Decimal(20,4))) AS Rate
	FROM	Program_Distributors_Trade pdt
	INNER JOIN Contract_Main cm
	ON pdt.Contract_Main_ID = cm.Contract_Main_ID
	INNER JOIN Program_Control_Panel_Options pcpo
	ON	pcpo.ProgramControl_Panel_Options_ID = cm.ProgramType_id
	AND	pcpo.Generic_Type NOT IN ('Operator Direct or HQ Programs', 'Operator-Deviated Pricing')
	WHERE pdt.BSA_Foodservice_Customers_ID = '#Customer_ID#'
	AND pdt.BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'
	AND	pdt.Deleted = 0
	</CFQUERY>
<cfelse>
	<CFQUERY NAME="GetTPA" DATASOURCE="#Application.Datasource#">
	SELECT	SUM(CAST(CAST(pdt.Rate AS Float) AS Decimal(20,4))) AS Rate
	FROM	Program_Distributors_Trade pdt
	INNER JOIN Contract_Main cm
	ON	cm.Contract_Main_ID = pdt.Contract_Main_ID
	AND	cm.Contract_Number <> '#Program_Details.Contract_Number#'
	WHERE pdt.BSA_Foodservice_Customers_ID = '#Customer_ID#'
	AND pdt.BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'
	AND	pdt.Deleted = 0
	</CFQUERY>
 </cfif>

<cfif getBrokerageCustomer.recordcount neq 0>
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
	FROM gross_Margin
	WHERE Customer_ID = '#Customer_ID#'
	AND product_id = '#replace(ItemId, "_", "-", "ALL")#'
	AND Deleted =0
	GROUP BY Customer_ID,product_id
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
	FROM Item_Margin_Targets imt
	WHERE imt.product_id = '#replace(ItemId, "_", "-", "ALL")#'
	AND imt.Deleted = 0
	</CFQUERY>
	</cfif>
<cfloop query="getBrokerageCustomer">
<cfset Rate = getBrokerageCustomer.Rate>
<cfset Base_Price = getBasePrice.CS_Price>
<!--- If after all that you still don't have a base price, set it to 0 --->
	<cfif len(trim(Base_Price)) IS 0>
		<cfset Base_Price = 0>
	</cfif>
	<CFIF getProgDistributors.Shr_Ship_To NEQ "">
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<td>&nbsp;</td>
			<TD>#getProgDistributors.Name# - #getProgDistributors.City#,#getProgDistributors.State#&nbsp;(#getProgDistributors.Shr_Ship_To#)</TD>
			<TD>#ListGetAt(getBrokerageCustomer.Source,1,"-")#-#ListGetAt(getBrokerageCustomer.Source,2,"-")#</TD>
			<TD ALIGN="LEFT">

			<cfif getBrokerageCustomer.Rate_UOM eq 1 OR getBrokerageCustomer.Rate_UOM eq 2>
			<CFSET UOM_Prepend = "$">
			<CFSET UOM_Append = "/#getBrokerageCustomer.Abbreviation#">
			<cfelse>
			<CFSET UOM_Prepend = "">
			<CFSET UOM_Append = getBrokerageCustomer.Abbreviation>
			</cfif>	
			
			<CFSET data = trim(numberformat(rate,"999,999,999,999,999,999,999,999.999"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#UOM_Prepend##data##UOM_Append#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>#UOM_Prepend##data##UOM_Append#</B></SPAN>"></CFIF>
			#data#
			</TD>
			
			<CFSET data = trim(numberformat(Base_Price,"999,999,999,999,999,999,999,999.999"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#/CS]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>#data#/CS</B></SPAN>"></CFIF>
			<TD ALIGN="LEFT">#data#</TD>

			<cfset Net_Price = Base_Price />
			<cfif Include_Cash_Discount eq 1>
				<cfif appsettings.getlocalcostvariables() eq 2>
					<cfset Use_Cash_Discount = val(Base_Price) * getProgDistributors.Cash_Discount />
				<cfelse>
					<cfset Use_Cash_Discount = Val(Product_Details.Base_Discount_CS) />
				</cfif>
				<cfset Net_Price = val(Base_Price) - Use_Cash_Discount />
				<CFSET data = trim(numberformat(Use_Cash_Discount,"999,999,999,999,999,999,999,999.999"))>
				<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#/CS]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>#data#/CS</B></SPAN>"></CFIF>
				<TD ALIGN="LEFT">#data#</TD>
			</cfif>
			<cfif Include_Allowance eq 1>
				<cfset Net_Price = val(Net_Price) - val(Product_Details.Item_Allowance_CS)>
				<CFSET data = trim(numberformat(val(Product_Details.Item_Allowance_CS),"999,999,999,999,999,999,999,999.999"))>
				<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#/CS]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>#data#/CS</B></SPAN>"></CFIF>
				<TD ALIGN="LEFT">#data#</TD>
			</cfif>
			<cfif Include_Trade_Adjustment eq 1>
				<cfset Net_Price = val(Net_Price) - (val(GetTPA.Rate) * Product_Details.Net_Weight)>
				<CFSET data = trim(numberformat(val(GetTPA.Rate) * Product_Details.Net_Weight,"999,999,999,999,999,999,999,999.999"))>
				<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[#data#/CS]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>#data#/CS</B></SPAN>"></CFIF>
				<TD ALIGN="LEFT">#data#</TD>
			</cfif>
			
			<cfif getBrokerageCustomer.Rate_UOM eq 1>
				<cfset BrokerageRate = Rate>
			<cfelseif getBrokerageCustomer.Rate_UOM eq 2>
				<cfset BrokerageRate = Rate * Product_Details.Net_Weight>
			<cfelseif getBrokerageCustomer.Rate_UOM eq 3>
				<cfset BrokerageRate = (Net_Price * Rate) / 100>
			</cfif>			
			
			<CFSET data = trim(numberformat(BrokerageRate,"999,999,999,999,999,999,999,999.999"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>			
			<TD ALIGN="LEFT">#data#</TD>

			<TD ALIGN="LEFT">*</TD>
			<TD ALIGN="LEFT">#getProgDistributors.Program_Weight#%</TD>
			<TD ALIGN="LEFT">=</TD>
			<TD ALIGN="LEFT">

			<cfset weighted_rate = (BrokerageRate * getProgDistributors.Program_Weight)/getDistributorWeight.Total_Program_Weight>
			<cfset Sum_Weighted_Rate = Sum_Weighted_Rate + weighted_rate>

			<cfset data = trim(numberformat(weighted_rate,"999,999,999,999,999,999,999,999.99999"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			#data#
			</TD>
		</TR>
		</CFIF>
		</CFLoop>
		</cfif>
		</CFOUTPUT>
		<CFOUTPUT>
		<CFIF getProgDistributors.Shr_Ship_To NEQ "">
		<TR ALIGN="LEFT">
			<TD COLSPAN="#ShowColumns#" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>Brkr Exp / CS (&##931; Wtd Brkr Exp) = </B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(Sum_Weighted_Rate,"999,999,999,999,999,999,999,999.999"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			<B>#data#</B>
			</TD>
		</TR>
			<cfset Sum_Weighted_Rate = Sum_Weighted_Rate / Product_Details.Net_Weight>

		<TR ALIGN="LEFT">
			<TD COLSPAN="#ShowColumns#" ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>Brkr Exp / LB </B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(Sum_Weighted_Rate,"999,999,999,999,999,999,999,999.999"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
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