<cfparam name="URL.CPID" 	default=0>
<cfparam name="url.Group_Id" default=0>
<cfparam name="Total_Cost" default="0">


<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET URL.CID = cryp.value>

<CFSET CID=URL.CID>
<CFSET Group_Id = #replace(url.Group_Id, "-", "_", "ALL")#>

<CFIF type EQ "C1">
	<CFSET PAGE_TITLE="Variable Cost Calculation">
<CFELSEIF  type EQ "C2">
	<CFSET PAGE_TITLE="Fixed Cost Calculation">
<CFELSEIF type EQ "CM" >
	<CFSET PAGE_TITLE="Contribution Margin Calculation">
<CFELSEIF type EQ "GP">
	<CFSET PAGE_TITLE="Gross Profit Calculation">
<CFELSEIF type EQ "A">
	<CFSET PAGE_TITLE="Allowance Calculation">
<CFELSEIF type EQ "N">
	<CFSET PAGE_TITLE="Net Sales Calculation">
<CFELSEIF type EQ "T">
	<CFSET PAGE_TITLE="Target Margin Calculation">
<cfelseif type EQ "AG">
	<CFSET PAGE_TITLE="Users Agreed">
<cfelse>
	<CFSET PAGE_TITLE="Cost Calculation">
</CFIF>
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<style>
		TABLE.Maintable td	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
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


<CFIF (URL.group_id EQ 0 OR URL.CID EQ 0) OR NOT isNumeric(URL.CID)>
	<BLOCKQUOTE>
	<BR><BR><BR><SPAN CLASS="TITLE2">Invalid Contract/Product information</SPAN>
	</BLOCKQUOTE>
	<CFABORT>
</CFIF>


<CFQUERY NAME="Program_Details" DATASOURCE="#Application.Datasource#">
	SELECT Contract_Number, Contract_Start_Date, Contract_End_Date,
	ProgramType_ID
	FROM Contract_Main WHERE Contract_Main_ID = <CFOUTPUT>#CID#</CFOUTPUT>
</CFQUERY>


<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT *
	FROM
		Program_Control_Panel_Options
	WHERE
		ProgramControl_Panel_Options_ID = '#trim(Program_Details.ProgramType_ID)#'
</cfquery>


<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
	SELECT distinct Product_Hierarchy_Name,Right(Product_Hierarchy,3) as Product_Hierarchy,
	ISNULL(AVG(BSA_Item_Costs.Total_Var_Mfg_Cost),0) as Var_Mfg_Cost,
	ISNULL(AVG(BSA_Item_Costs.Fixed_Mfg_OH),0) as Fixed_Mfg_OH,
	AVG(ISNULL(BSA_Item_Costs.Transfer_Freight,0)) as Transfer_Freight,
	AVG((ISNULL(CAST(WH_Handling as decimal(20,4)),0) * BSA_Foodservice_Items_Master.Net_Weight)) as WH_Handling,
	AVG((ISNULL(CAST(WH_Storage as decimal(20,4)),0) * BSA_Foodservice_Items_Master.Net_Weight)) as WH_Storage,
	AVG((ISNULL(CAST(IQA_Factor as decimal(20,4)),0) * BSA_Foodservice_Items_Master.Net_Weight)) as IQA_Factor,
	AVG((ISNULL(CAST(Other_Cost as decimal(20,4)),0) * BSA_Foodservice_Items_Master.Net_Weight)) as Other_Cost,
	AVG(ISNULL(CAST(BSA_Foodservice_Items_Master.Net_Weight as decimal(20,4)),0)) as Net_Weight,
	AVG(ISNULL(BSA_Item_Costs.Resin_Factor,0)) as Resin_Factor,
	AVG(ISNULL(contract_group_margin.Customer_Freight,0)) as Freight_Cost
	FROM contract_products
	INNER JOIN BSA_Foodservice_Items_Master
	ON contract_products.BSA_Foodservice_Items_Master_id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	INNER JOIN BSA_Item_Costs
	ON 	BSA_Item_Costs.product_id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id
	INNER JOIN Product_Hierarchy
	ON 	Product_Hierarchy.Product_Hierarchy_Id = BSA_Foodservice_Items_Master.Product_Hierarchy_Id
	and Product_Hierarchy.deleted = 0
	INNER JOIN contract_group_margin
	ON contract_group_margin.group_id  = BSA_Foodservice_Items_Master.Product_Hierarchy_Id
	INNER JOIN Type_Group_Desc
	ON 	Type_Group_Desc.Type_Group_Desc_Id = Product_Hierarchy.Type_Group_Desc_Id
	and contract_group_margin.contract_main_id = #CID#
	and contract_group_margin.deleted = 0
	WHERE 	contract_products.contract_main_id = #CID#
	and  contract_products.deleted = 0
	and 	BSA_Foodservice_Items_Master.Product_Hierarchy_Id = '#replace(group_id, "_", "-", "ALL")#'
	and 	BSA_Foodservice_Items_Master.Deleted = 0
	group by BSA_Foodservice_Items_Master.Product_Hierarchy_Id,Product_Hierarchy_Name,Product_Hierarchy
</CFQUERY>
<cfquery NAME="getMargins" datasource="#application.datasource#">
	SELECT
	ISNULL(CAST(Net_Sales_CS as float),0) as Net_Sales,
	ISNULL(CAST(Cost_CS as float),0) as Cost1,
	ISNULL(CAST(Cost2_CS as float),0) as Cost2,
	ISNULL(CAST(Contribution_Margin_CS as float),0) as Contribution_Margin,
	ISNULL(CAST(Operating_Income_CS as float),0) as Operating_Income,
	ISNULL(FPR_CS,0) as Fixed_Price_CS, ISNULL(RER_CS,0) as Rebate_Price_CS, ISNULL(GRR_CS,0) as Growth_Price_CS, ISNULL(KPR_CS,0) as Formula_Price_CS,
	ISNULL(OER_CS,0) as Offinvoice_Price_CS, ISNULL(LumpsumAmount_CS,0) as LumpsumAmount_CS,ISNULL(Base_Sales_CS,0) as Base_Sales_CS,
	ISNULL(Item_Allowance_CS,0) as ITEM_ALLOWANCE_CS ,ISNULL(TPA_CS,0) as TPA_CS ,ISNULL(Cash_Discount_CS,0) as Cash_Discount_CS ,ISNULL(Net_Sales_CS,0) as Net_Sales_CS,ISNULL(Cost_CS,0) as Cost_CS ,ISNULL(Diff_Fixed_Price_CS,0) as Diff_Fixed_Price_CS,
	ISNULL(Diff_Formula_Price_CS,0) as Diff_Formula_Price_CS,
	ISNULL(Product_Hierarchy.Target_Margin,0) as TargetMargin,
	<!--- 66894	Margin Target ENH Forge START --->
	<cfif getSettings.Generic_Type EQ 'Operator Direct or HQ Programs' OR getSettings.Generic_Type EQ 'Operator-Deviated Pricing'>
		ISNULL(Group_ID_Margin_Operator,0)
	<cfelse>
		ISNULL(Group_ID_Margin,0)
	</cfif>
	 AS Margin_Target_Variation
	<!--- 66894 --->
	,Product_Hierarchy.Product_Hierarchy_Name,Product_Hierarchy.Product_Hierarchy_Id
	FROM
	contract_group_margin
	INNER JOIN Product_Hierarchy
	ON Product_Hierarchy.Product_Hierarchy_id = contract_group_margin.group_Id
	and Product_Hierarchy.deleted = 0
	LEFT JOIN Group_Approval_Rights
	ON 	Group_Approval_Rights.Group_ID = Product_Hierarchy.Type_Group_Desc_ID
	and Group_Approval_Rights.User_Profile_ID = #request.AccessStructure.Profiles_ID#
	and Group_Approval_Rights.deleted = 0
	where contract_group_margin.group_id =  '#replace(group_id, "_", "-", "ALL")#'
	and contract_group_margin.contract_main_id = #CID#
	and contract_group_margin.deleted = 0
</cfquery>

<cfif type EQ "AG">
<CFQUERY NAME="GetUsersAgreed" datasource="#application.datasource#">
	SELECT distinct name_first,name_last,Program_Type_Code_Approval_Info.created_date,Product_Hierarchy_id,Product_Hierarchy.Product_Hierarchy_name,Right(Product_Hierarchy,3) as Product_Hierarchy
	FROM  Program_Type_Code_Approval_Info
	INNER JOIN Product_Hierarchy
	ON 	Product_Hierarchy.Product_Hierarchy_id = Program_Type_Code_Approval_Info.Type_Code_Desc_Id
	AND Product_Hierarchy.deleted = 0
	INNER JOIN _Users
	ON _Users.user_id = Program_Type_Code_Approval_Info.user_id
	and _users.deleted = 0
	where Program_Type_Code_Approval_Info.program_id = #CID#
	and  Program_Type_Code_Approval_Info.Type_Code_Desc_Id = '#replace(group_id, "_", "-", "ALL")#'
	AND isNULL(AGREE,0) = 1
	and Program_Type_Code_Approval_Info.deleted = 0
</cfquery>
</cfif>

<BR><BR>
<SPAN CLASS="TITLE2"><cfoutput>#PAGE_TITLE#</cfoutput></SPAN>
<HR COLOR="Orange">
<CFOUTPUT QUERY="Program_Details">
  <TABLE border="0" WIDTH="366">
    <tr>
      <td width="10" ALIGN="Left" STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">&nbsp;</td>
      <td width="346" ALIGN="Left" STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Program:</B>&nbsp;&nbsp;[#Contract_Number#]</td>
    </tr>
    <tr>
      <td STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left">&nbsp;</td>
      <td STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left"><B>Start
        Date:</B>&nbsp;&nbsp;#DateFormat(Contract_Start_Date,"mm/dd/yyyy")#</td>
    </tr>
    <tr>
      <td STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left">&nbsp;</td>
      <td STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left"><B>End
        Date:</B>&nbsp;&nbsp;#DateFormat(Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</td>
    </tr>
  </TABLE>
<HR COLOR="Orange">
</CFOUTPUT>
<cfoutput>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<tr>
		<td STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT FAMILY:</B></td>
		<td STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#TheQuery.Product_Hierarchy_Name# - #TheQuery.Product_Hierarchy#</B></td>
	</tr>
</TABLE>
</cfoutput>
<CFIF isdefined("TheQuery") and TheQuery.recordCount GT 0>
<cfoutput>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
<cfif type EQ "C1">
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Variable Manufacturing Cost</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset Var_Mfg_Cost = "#TheQuery.Var_Mfg_Cost#">
		$#trim(numberformat(evaluate(Var_Mfg_Cost),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Resin Factor</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset Resin_Factor = "#TheQuery.Resin_Factor#">
		$#trim(numberformat(evaluate(Resin_Factor),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Customer Freight</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset Freight_Cost = "#TheQuery.Freight_Cost#">
		$#trim(numberformat(evaluate(Freight_Cost),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Transfer Freight</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset Transfer_Freight = "#TheQuery.Transfer_Freight#">
		$#trim(numberformat(evaluate(Transfer_Freight),'_-___,___,___,___,___.____'))#
	</td>
</tr>
	<cfset Total_Cost = getMargins.Cost1>
<cfelseif type EQ "C2">
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Fixed Manufacturing Costs</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset Fixed_Mfg_OH = "#TheQuery.Fixed_Mfg_OH#">
		$#trim(numberformat(evaluate(Fixed_Mfg_OH),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Warehouse Handling</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset WH_Handling = "#TheQuery.WH_Handling#">
		$#trim(numberformat(evaluate(WH_Handling),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Warehouse Storage</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset WH_Storage = "#TheQuery.WH_Storage#">
		$#trim(numberformat(evaluate(WH_Storage),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Other Cost</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset othercost = TheQuery.Other_Cost + TheQuery.IQA_Factor>
		<cfset Other_Cost = "#othercost#">
			$#trim(numberformat(evaluate(Other_Cost),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<cfset Total_Cost = getMargins.Cost2>
<cfelseif type EQ "CM">
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Net Sales</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset Net_Sales = "#getMargins.Net_Sales#">
		$#trim(numberformat(evaluate(Net_Sales),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Variable Costs</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset Cost1 = "#getMargins.Cost1#">
		-$#trim(numberformat(evaluate(Cost1),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<cfset Total_Cost = getMargins.Contribution_Margin>
<cfelseif type EQ "GP">
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Contribution Margin</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset ContributionMargin = "#getMargins.Contribution_Margin#">
	<cfif getMargins.Contribution_Margin LT 0>
		<span STYLE="color: red;">
			<cfset ContributionMargin = evaluate(ContributionMargin) * (-1)>
			[$#trim(numberformat(evaluate(ContributionMargin),'_-___,___,___,___,___.____'))#]
		</span>
	<cfelse>
		$#trim(numberformat(evaluate(ContributionMargin),'_-___,___,___,___,___.____'))#
	</cfif>
	</td>
</tr>
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Fixed Costs</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset Cost2 = "#getMargins.Cost2#">
		-$#trim(numberformat(evaluate(Cost2),'_-___,___,___,___,___.____'))#
	</td>
</tr>
<cfset Total_Cost = getMargins.Operating_Income>
</CFIF>
</TABLE>
<cfif NOT type EQ "T" AND NOT type EQ "AG">
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Total:</B></td>
		<td STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">
		<cfset TotalCost = "#Total_Cost#">
		<cfif Total_Cost LT 0>
			<span STYLE="color: red;">
				<cfset TotalCost = evaluate(TotalCost) * (-1)>
				[$#trim(numberformat(evaluate(TotalCost),'_-___,___,___,___,___.____'))#]
			</span>
		<cfelse>
			$#trim(numberformat(evaluate(TotalCost),'_-___,___,___,___,___.____'))#
		</cfif>
		</td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	</tr>
</TABLE>
</cfif>
</cfoutput>
</cfif>

<cfif type EQ "N">
<cfoutput>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Base Sales</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;">
			<cfset Base_Sales = "#getMargins.Base_Sales_CS#">
			$#trim(numberformat(evaluate(Base_Sales),'_-___,___,___,___,___.____'))#
		</td>
	</tr>
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Cash Discount</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;">
			<cfset Cash_Discount = "#getMargins.Cash_Discount_CS#">
			$#trim(numberformat(evaluate(Cash_Discount),'_-___,___,___,___,___.____'))#
		</td>
	</tr>
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Allowances</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;">
			<cfset ItemAllowance = "#getMargins.Item_Allowance_CS#">
			<cfif ItemAllowance LT 0>
				<span STYLE="color: red;">
					<cfset Item_Allowance = evaluate(ItemAllowance) * (-1)>
					[$#trim(numberformat(evaluate(Item_Allowance),'_-___,___,___,___,___.____'))#]
				</span>
			<cfelse>
				$#trim(numberformat(evaluate(ItemAllowance),'_-___,___,___,___,___.____'))#
			</cfif>
		</td>
</tr>
<tr>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#application.returned_customer_setting.Trade_Label#</B></td>
	<td STYLE="border-bottom: 1px ##93BEE2 solid;">
		<cfset TPA = "#getMargins.TPA_CS#">
		$#trim(numberformat(evaluate(TPA),'_-___,___,___,___,___.____'))#
	</td>
</tr>
</TABLE>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Net Sales:</B></td>
		<td STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">
		<B>
		<cfset NetSales = "#getMargins.Net_Sales_CS#">
		<cfif NetSales LT 0>
			<span STYLE="color: red;">
				<cfset Net_Sales = evaluate(NetSales)>
				[$#trim(numberformat(Net_Sales,'_-___,___,___,___,___.____'))#]
			</span>
		<cfelse>
			$#trim(numberformat(evaluate(NetSales),'_-___,___,___,___,___.____'))#
		</cfif>
		</B>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
</TABLE>
</cfoutput>
<cfelseif type EQ "A">
<cfoutput>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
	<tr BGCOLOR="##FFCE84" VALIGN="bottom">
		<td NOWRAP><B>Discount Type</B></td>
		<td NOWRAP><B>Price</B></td>
	</tr>
	<CFIF GetSettings.Discount_Fixed_Prices EQ 1>
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Fixed</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;" align="right">
			<cfset diff_fixed_price = "#getMargins.Diff_Fixed_Price_CS#">
			$#trim(numberformat(evaluate(diff_fixed_price),'_-___,___,___,___,___.____'))#
		</td>
	<tr>
	</cfif>
	<CFIF GetSettings.Discount_Rebates EQ 1>
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#Application.RebateLabel#</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;" align="right">
			<CFSET Rebate_Price = "#getMargins.Rebate_Price_CS#">
			$#trim(numberformat(evaluate(Rebate_Price),'_-___,___,___,___,___.____'))#
		</td>
	</tr>
	</cfif>
	<CFIF GetSettings.Discount_Lump_Sums EQ 1>
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#Application.LumpsumLabel#</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;" align="right">
			<CFSET LumpsumAmount = "#getMargins.LumpsumAmount_CS#">
			$#trim(numberformat(evaluate(LumpsumAmount),'_-___,___,___,___,___.____'))#
		</td>
	</tr>
	</cfif>
	<CFIF GetSettings.Discount_Growth EQ 1>
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Growth</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;" align="right">
			<cfset Growth_Price = "#getMargins.Growth_Price_CS#">
			$#trim(numberformat(evaluate(Growth_Price),'_-___,___,___,___,___.____'))#
		</td>
	</tr>
	</cfif>
	<CFIF GetSettings.Discount_Formula_Pricing EQ 1>
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Formula</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2  solid;" align="right">
			<cfset Formula_Price ="#getMargins.Diff_Formula_Price_CS#">
			$#trim(numberformat(evaluate(Formula_Price),'_-___,___,___,___,___.____'))#
		</td>
	</tr>
	</cfif>
	<cfif GetSettings.Generic_Type IS "Distributor Off-Invoice">
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Off Invoice</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;" align="right">
			<cfset Offinvoice_Price = "#getMargins.Offinvoice_Price_CS#">
			$#trim(numberformat(evaluate(Offinvoice_Price),'_-___,___,___,___,___.____'))#
		</td>
	</tr>
	</cfif>
</TABLE>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Total Allowance:</B></td>
		<td STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">
		<cfset ItemAllowance = "#getMargins.Item_Allowance_CS#">
		<B>
		<cfif ItemAllowance LT 0>
			<span STYLE="color: red;">
				<cfset Item_Allowance = evaluate(ItemAllowance) * (-1)>
				[$#trim(numberformat(Item_Allowance,'_-___,___,___,___,___.____'))#]
			</span>
		<cfelse>
			$#trim(numberformat(evaluate(ItemAllowance),'_-___,___,___,___,___.____'))#
		</cfif>
		</B>
		</td>
	</tr>
	<tr>
	<td>&nbsp;</td>
	</tr>
</TABLE>
</cfoutput>
<cfelseif type EQ "AG">
<cfoutput query="GetUsersAgreed" group="Product_Hierarchy_Id">
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>User Name</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;">Date/Time</td>
	</tr>
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>#name_first# #name_last#</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;">#Dateformat(created_date,"mm/dd/yyyy")#</td>
	</tr>
</TABLE>
</cfoutput>
<cfelseif type EQ "T">
<cfoutput>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Margin Target</B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;" align="right">
		#trim(numberformat(Round(getMargins.TargetMargin),'_-___,___,___,___,___'))#%
		</td>
	</tr>
	<tr>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Margin Target Variation </B></td>
		<td STYLE="border-bottom: 1px ##93BEE2 solid;" align="right">
			<cfif trim(getMargins.Margin_Target_Variation) NEQ "*">
				#trim(numberformat(Round(getMargins.Margin_Target_Variation),'_-___,___,___,___,___'))#%
			<cfelse>
				*
			</cfif>
		</td>
	</tr>
</TABLE>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Margin%:</B></td>
		<td STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">
		<cfif trim(getMargins.Margin_Target_Variation) NEQ "*">
			<CFSET totalmargin = getMargins.TargetMargin - ((getMargins.TargetMargin * getMargins.Margin_Target_Variation)/100)>
		<cfelse>
			<CFSET totalmargin = getMargins.TargetMargin>
		</cfif>
			#trim(numberformat(totalmargin,'_-___,___,___,___,___.__'))#%
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
</TABLE>
</cfoutput>
</cfif>

<HR color="orange">
<div align="center"><B><font color="FF0000">[</font> <a onclick="javascript:window.close()" STYLE="cursor: pointer;">Close Window</a> <font color="FF0000">]</font></B></div>

</BODY>
</HTML>