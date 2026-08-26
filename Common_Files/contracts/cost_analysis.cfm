<CF_Loading>
<cfflush>

<cfparam name="URL.CID" default="">
<cfif len(URL.CID) EQ 0><cfabort></cfif>
<cf_cryp type="de" string="#URL.CID#" key="#request.key#">
<cfquery name="getContractProducts" datasource="#application.datasource#">
SELECT	dbo.BSA_Foodservice_Items_Master.Item, 
		dbo.Contract_Products.Contract_Main_ID, 
		dbo.Contract_Products.Discount_Value,
		dbo.Contract_Products.Product_UPC, 
		dbo.BSA_Foodservice_Items_Master.Description
FROM	dbo.Contract_Products
		INNER JOIN
			dbo.BSA_Foodservice_Items_Master
			ON
			dbo.Contract_Products.Product_UPC = dbo.BSA_Foodservice_Items_Master.UPC
WHERE	dbo.Contract_Products.Contract_Main_ID = '#cryp.value#'
</cfquery>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Cost Analysis</title>
</head>

<BODY ONBLUR="self.focus();" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>

<!--- 
<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" ALIGN="center">
<TR>
	<TD BGCOLOR="Yellow" ALIGN="center"><FONT COLOR="blue" SIZE="3"><B>Cost Analysis</B></FONT></TD>
</TR>
</TABLE>

 --->
<br>


<CENTER>
<FIELDSET STYLE="padding:0px; width: 95%; border: 1px solid Silver;">
<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">cost analysis</LEGEND>
<br>
<table width="420" border="0" cellspacing="0" cellpadding="10" align="center" class="Maintable">
	<TR BGCOLOR="FFCE84">
		<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD id="header"><b>SKU</b></TD></cfif></cfif>
		<TD id="header"><b>Description</b></TD>
		<TD id="header"><b>Contract<br>$/Lb</b></TD>
		<TD id="header"><b>Formula<br>$/Lb</b></TD>
		<TD id="header"><b>%</b></TD>
	</TR>
<cfoutput>
<cfloop query="getContractProducts">
	<cfset cost_product_item_number  = getContractProducts.Item>
	<cfinclude template="cost.cfm"> 
	<cfif len(trim(cost_ActualCommodityCost)) NEQ 0>
		<cfset delta = (getContractProducts.Discount_Value-cost_ActualCommodityCost)/cost_ActualCommodityCost>
		<cfset delta = (round(delta*1000)/1000)*100>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD>#getContractProducts.Product_UPC#</TD></cfif></cfif>
			<TD>#getContractProducts.Description#</TD>
			<TD>$#trim(numberformat(getContractProducts.Discount_Value,'_________.___'))#</TD>
			<TD>$#trim(numberformat(cost_ActualCommodityCost,'_________.___'))#</TD>
			<TD NOWRAP>
				<CFIF delta LT 0>
					<IMG SRC="/images/negative.gif" BORDER="0" ALT="">&nbsp;<FONT SIZE="3" COLOR="Red"><B>#evaluate(delta*(-1))#%</B></FONT>
				<CFELSE>
					<IMG SRC="/images/positive.gif" BORDER="0" ALT="">&nbsp;<FONT SIZE="3" COLOR="Green"><B>#delta#%</B></FONT>
				</CFIF>
			</TD>
		</TR>	
	<cfelse>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD colspan="100%" align="center">NO DATA FOR: #getContractProducts.Description# (#getContractProducts.Product_UPC#)</TD>
		</TR>	 
	</cfif>
</CFLOOP>
</cfoutput>
</table>

</FIELDSET>
</CENTER>


</body>
</html>
