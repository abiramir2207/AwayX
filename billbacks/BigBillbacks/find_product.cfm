<cfparam name="form.ExistingProductList" default="">
<cfparam name="form.Product_List" default="">
<cfparam name="ProductName" default="">
<cfparam name="stError" default="">

<cfif len(trim(form.Product_List)) GT 0>
	<cfquery name="GetProdName" datasource="#application.datasource#">
		SELECT Description, Item, UPC
		FROM BSA_Foodservice_Items_Master
		WHERE BSA_Foodservice_Items_Master_ID IN (form.Product_List)
	</cfquery>
	
	<cfset ProductName = GetProdName.Description + " " + GetProdName.Item + " " + GetProdName.UPC>
</cfif>

<cfoutput><SCRIPT LANGUAGE="JavaScript" SRC="bigbillback.js"></SCRIPT></cfoutput>

<cfoutput>
<form name="ProductAlias" method="post" action="add_product_alias.cfm">


<INPUT NAME="ExistingProductList" TYPE="hidden"  value="#form.ExistingProductList#">
<INPUT NAME="Product_List" TYPE="hidden"  value="#form.Product_List#">
<input name="Big_Billback_ID" type="hidden" value="#Big_Billback_ID#">

<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width: 375;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">find your product</LEGEND>
		
		<!---Get data --->
		<cfset useLakebaseForGetBBBData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("big_billback")>
<cfif useLakebaseForGetBBBData>
	<cftry>
		<cfset GetBBBData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("big_billback", {
				"big_billback_id" = "eq.#Big_Billback_ID#",
				"select" = "product"
			}), "product"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBBBData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBBBData>
<cfquery name="GetBBBData" datasource="#application.datasource#">
		SELECT Product FROM Big_Billback WHERE Big_Billback_ID = #Big_Billback_ID#
		</cfquery>
</cfif>
	
		
		<table width="350" cellpadding="0" cellspacing="2" border="0">
		<cfif stError IS 1>
				<tr>
			<td><font color="red">An entry already exists for this alias. If you have already entered this alias but are still seeing highlighted options on your screen, try revalidating.</font></td>
		</tr>
		</cfif>
		<tr>
			<td><input type="text" name="Product_Alias" size="35" value="#replace(GetBBBData.Product, """", "&quot;")#"></td>
		</tr>
		<tr>
			<Td>#ProductName# </TD>
		</tr><tr>
			<td><CF_smallLink 
				title = "search for product" 
				url = "##"
				parameters = "onClick=""showProductSearchWindow();"""
				> 
				</td>
		</td>
		</tr>
		</table>
</FIELDSET>
</form>
</cfoutput>