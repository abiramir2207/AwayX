<cfparam name="URL.CPID" 	default=0>
<cfparam name="url.ItemId" default=0>
<cfparam name="url.type" default="A">
<cfparam name="url.desc" default="">
<cfparam name="Total_Cost" default="0">
<cfparam name="url.margin_type" default="1">
<cfparam name="STAT_MULTIPLIER" default="1">
<cfparam name="MULTIPLIER" default="*">

<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET URL.CID = cryp.value>

<CFSET CID=URL.CID>
<CFSET ItemId = #replace(url.ItemId, "-", "_", "ALL")#>
<CFSET type = url.type>
<cfset desc = url.desc>

<CFIF type EQ "C1">
	<CFSET PAGE_TITLE="Variable Cost Calculation">
<CFELSEIF  type EQ "C2">
	<CFSET PAGE_TITLE="Fixed Cost Calculation">
<CFELSEIF type EQ "CM" >
	<CFSET PAGE_TITLE="Contribution Margin Calculation">
<CFELSEIF type EQ "GP">
	<CFSET PAGE_TITLE="Gross Profit Calculation">
</CFIF>
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">

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

<cfif url.margin_type EQ 3>
<CFQUERY NAME="GetNetValue" datasource="#application.datasource#">
SELECT ISNULL(CAST(NET_WEIGHT as decimal(20,4)),0) as NET_WEIGHT
FROM BSA_Foodservice_Items_Master
where BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'
</CFQUERY>
<cfif GetNetValue.NET_WEIGHT EQ 0>
<cfset Net = 1>
<cfelse>
<cfset Net = GetNetValue.NET_WEIGHT>
</cfif>
<cfset STAT_MULTIPLIER = Net>
<CFSET MULTIPLIER = "/">
<cfelseif url.margin_type EQ 4>
<CFQUERY NAME="GetVolume" datasource="#application.datasource#">
SELECT ISNULL(Product_Program_Volume_CS,0) as Volume_Equivalent
FROM contract_product_margin
where product_id = '#replace(ItemId, "_", "-", "ALL")#'
and deleted = 0
and contract_main_id = #CID#
</CFQUERY>
<CFSET STAT_MULTIPLIER = GetVolume.Volume_Equivalent>
<CFSET MULTIPLIER = "*">
<cfelse>
<CFSET STAT_MULTIPLIER = 1>
<CFSET MULTIPLIER = "*">
</cfif>


<CFIF (URL.ItemID EQ 0 OR URL.CID EQ 0) OR NOT isNumeric(URL.CID)>
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
SELECT item, description,
ISNULL(BSA_Item_Costs.Total_Var_Mfg_Cost,0) as Total_Var_Mfg_Cost,
ISNULL(BSA_Item_Costs.Fixed_Mfg_OH,0) as Fixed_Mfg_OH,
ISNULL(BSA_Item_Costs.Transfer_Freight,0) as Transfer_Freight,ISNULL(BSA_Item_Costs.Resin_Factor,0) as Resin_Factor ,(ISNULL(contract_product_margin.Customer_Freight,0) * (BSA_Foodservice_Items_Master.Net_Weight)) as Freight_Cost,
(ISNULL(CAST(WH_Handling as decimal(20,4)),0) * BSA_Foodservice_Items_Master.Net_Weight) as WH_Handling,
(ISNULL(CAST(WH_Storage as decimal(20,4)),0) * BSA_Foodservice_Items_Master.Net_Weight) as WH_Storage,
(ISNULL(CAST(IQA_Factor as decimal(20,4)),0) * BSA_Foodservice_Items_Master.Net_Weight) as IQA_Factor,
(ISNULL(CAST(Other_Cost as decimal(20,4)),0) * BSA_Foodservice_Items_Master.Net_Weight) as Other_Cost,
ISNULL(CAST(Net_Sales_CS as decimal(20,4)),0) as Net_Sales,
ISNULL(CAST(Cost_CS as decimal(20,4)),0) as Cost1,
ISNULL(CAST(Cost2_CS as decimal(20,4)),0) as Cost2,
ISNULL(CAST(Contribution_Margin_CS as float),0) as Contribution_Margin,
ISNULL(CAST(Operating_Income_CS as float),0) as Operating_Income,
Type_Group_Desc.Type_Group_Desc_ID,
ISNULL(BSA_Foodservice_Items_Master.Net_Weight,0) as Net_Weight
FROM BSA_Foodservice_Items_Master
INNER JOIN BSA_Item_Costs
ON BSA_Item_Costs.Product_id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
INNER JOIN Type_Group_Desc ON
Type_Group_Desc.Type_Group_Desc_ID = BSA_Foodservice_Items_Master.Type_Group_Desc_ID
and Type_Group_Desc.deleted = 0
INNER JOIN contract_product_margin
ON contract_product_margin.product_id  = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
and contract_product_margin.contract_main_id = #CID#
and contract_product_margin.deleted = 0
WHERE BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#' and 
BSA_Foodservice_Items_Master.Deleted = 0
</CFQUERY>
<!------<CFDUMP VAR="#getThisProductsDistCombos#">----->



<!------<CFOUTPUT>#FinalTPASum#</CFOUTPUT>----->

<BR><BR>
<SPAN CLASS="TITLE2"><cfoutput>#PAGE_TITLE#</cfoutput></SPAN>
<HR COLOR="Orange">
<CFOUTPUT QUERY="Program_Details">
  <TABLE border="0" WIDTH="366">
    <TR> 
      <TD width="10" ALIGN="Left" STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">&nbsp;</TD>
      <TD width="346" ALIGN="Left" STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Program:</B>&nbsp;&nbsp;[#Contract_Number#]</TD>
    </TR>
    <TR> 
      <TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left">&nbsp;</TD>
      <TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left"><B>Start 
        Date:</B>&nbsp;&nbsp;#DateFormat(Contract_Start_Date,"mm/dd/yyyy")#</TD>
    </TR>
    <TR> 
      <TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left">&nbsp;</TD>
      <TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Left"><B>End 
        Date:</B>&nbsp;&nbsp;#DateFormat(Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
    </TR>
  </TABLE>
<HR COLOR="Orange">
</CFOUTPUT>
<cfoutput>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B>#TheQuery.Item# - #TheQuery.Description#</B></TD>
	</TR>
</TABLE></cfoutput>
<CFIF isdefined("TheQuery") and TheQuery.recordCount GT 0>
<cfoutput>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" STYLE="border-bottom: 1px solid navy; border-top: 1px solid navy; border-right: 1px solid navy; border-left: 1px solid navy;">
<cfif type EQ "C1">
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Variable Manufacturing Cost</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset Total_Var_Mfg_Cost = "#TheQuery.Total_Var_Mfg_Cost##MULTIPLIER##STAT_MULTIPLIER#">
$#trim(numberformat(evaluate(Total_Var_Mfg_Cost),'_-___,___,___,___,___.____'))#</TD>
		</TR>

</TR>
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Resin Factor</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset Resin_Factor = "#TheQuery.Resin_Factor##MULTIPLIER##STAT_MULTIPLIER#">
$#trim(numberformat(evaluate(Resin_Factor),'_-___,___,___,___,___.____'))#</TD>
		</TR>

</TR>
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Customer Freight</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset Freight_Cost = "#TheQuery.Freight_Cost##MULTIPLIER##STAT_MULTIPLIER#">
$#trim(numberformat(evaluate(Freight_Cost),'_-___,___,___,___,___.____'))#</TD>
		</TR>

</TR>
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Transfer Freight</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset Transfer_Freight = "#TheQuery.Transfer_Freight##MULTIPLIER##STAT_MULTIPLIER#">
$#trim(numberformat(evaluate(Transfer_Freight),'_-___,___,___,___,___.____'))#</TD>
		</TR>

</TR>
<cfset Total_Cost = TheQuery.Cost1>
<cfelseif type EQ "C2">
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Fixed Manufacturing Costs</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset Fixed_Mfg_OH = "#TheQuery.Fixed_Mfg_OH##MULTIPLIER##STAT_MULTIPLIER#">
$#trim(numberformat(evaluate(Fixed_Mfg_OH),'_-___,___,___,___,___.____'))#</TD>
		</TR>
		
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Warehouse Handling</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset WH_Handling = "#TheQuery.WH_Handling##MULTIPLIER##STAT_MULTIPLIER#">
$#trim(numberformat(evaluate(WH_Handling),'_-___,___,___,___,___.____'))#</TD>
		</TR>
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Warehouse Storage</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset WH_Storage = "#TheQuery.WH_Storage##MULTIPLIER##STAT_MULTIPLIER#">
$#trim(numberformat(evaluate(WH_Storage),'_-___,___,___,___,___.____'))#</TD>
		</TR>
<TR>
			
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Other Cost</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset othercost = TheQuery.Other_Cost + TheQuery.IQA_Factor>
<cfset Other_Cost = "#othercost##MULTIPLIER##STAT_MULTIPLIER#">
$#trim(numberformat(evaluate(Other_Cost),'_-___,___,___,___,___.____'))#</TD>
		</TR>
	<cfset Total_Cost = TheQuery.Cost2>

<cfelseif type EQ "CM">
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Net Sales</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset Net_Sales = "#TheQuery.Net_Sales##MULTIPLIER##STAT_MULTIPLIER#">
$#trim(numberformat(evaluate(Net_Sales),'_-___,___,___,___,___.____'))#</TD>
</TR>
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Variable Costs</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset Cost1 = "#TheQuery.Cost1##MULTIPLIER##STAT_MULTIPLIER#">
-$#trim(numberformat(evaluate(Cost1),'_-___,___,___,___,___.____'))#</TD>
</TR>
<cfset Total_Cost = TheQuery.Contribution_Margin>
<cfelseif type EQ "GP">
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Contribution Margin</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset ContributionMargin = "#TheQuery.Contribution_Margin##MULTIPLIER##STAT_MULTIPLIER#">
<cfif TheQuery.Contribution_Margin LT 0>
		<span STYLE="color: red;">
			<cfset ContributionMargin = evaluate(ContributionMargin) * (-1)>
	[$#trim(numberformat(evaluate(ContributionMargin),'_-___,___,___,___,___.____'))#]
		</span>
		<cfelse>
		$#trim(numberformat(evaluate(ContributionMargin),'_-___,___,___,___,___.____'))#
		</cfif>
</TD>
</TR>
<TR>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;"><B>Fixed Costs</B></TD>
			<TD STYLE="border-bottom: 1px ##93BEE2 solid;">
<cfset Cost2 = "#TheQuery.Cost2##MULTIPLIER##STAT_MULTIPLIER#">
-$#trim(numberformat(evaluate(Cost2),'_-___,___,___,___,___.____'))#</TD>
</TR>
<cfset Total_Cost = TheQuery.Operating_Income>
</CFIF>
</TABLE>
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<TR>
	<TD>&nbsp;</TD>
	</TR>
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>Total:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">
		<cfset TotalCost = "#Total_Cost##MULTIPLIER##STAT_MULTIPLIER#">
		<cfif Total_Cost LT 0>
		<span STYLE="color: red;">
			<cfset TotalCost = evaluate(TotalCost) * (-1)>
			[$#trim(numberformat(evaluate(TotalCost),'_-___,___,___,___,___.____'))#]
		</span>
		<cfelse>
			$#trim(numberformat(evaluate(TotalCost),'_-___,___,___,___,___.____'))#
		</cfif>
		</B></TD>
	</TR>
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

