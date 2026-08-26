<cfif isDefined("url.Program_ID")>
<cf_cryp type="de" key="#request.key#" string="#url.Program_ID#">
<CFSET FORM.Program_ID = cryp.value>
</cfif>

<!--- lock checker --->
<CFSET LockChecker_CID  = FORM.Program_ID>
<CFINCLUDE TEMPLATE="LockChecker.cfm">

<!---Delete logic--->
<cfif isDefined("form.Delete")>
<cfparam name="ItemList" default="">

	<cfloop collection = #Form# item = "FieldNames">
		 <cfset FieldName = FieldNames> 

		<cfif left(FieldName, 8) IS "Product_">
			<cfset FieldName = right(FieldName, 36)>
			<cfset FieldName = replace(FieldName, "_", "-", "all")>
			<cfset FieldValue = Evaluate("Form.#FieldNames#")>
			
		<cfset useLakebaseForDeleteItem = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_product_data")>
<cfif useLakebaseForDeleteItem>
	<cftry>
		<cfset application.oLakebase.updateRows("program_lump_sum_product_data",
			{
				"program_lump_sum_product_data_id" = "eq.#FieldName#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteItem = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteItem>
<cfquery name="DeleteItem" datasource="#application.datasource#">
			UPDATE Program_Lump_Sum_Product_Data
			SET Deleted = 1
			WHERE Program_Lump_Sum_Product_Data_ID = '#FieldName#'
		</cfquery>
</cfif>
			
		</cfif>
		
	</cfloop>

</cfif>

<!---Show logic--->

<!---Query--->
<CFQUERY NAME="getLumpSumProducts" datasource="#application.datasource#">
	SELECT		Contract_Products.Contract_Products_ID, 
				Type_Code_Desc.Type_Code_Desc, 
				Brand.Brand_Name, 
				BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, 
				CASE
				WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
					''
				ELSE
					BSA_Foodservice_Items_Master.UPC
				END As UPC, 
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
					''
				ELSE
					BSA_Foodservice_Items_Master.Item
				END As Item,
				CASE 
				WHEN Contract_Products.Product_Group_Level_ID = 1 THEN
					'All ' + ISNULL(Business_Segment.Business_Unit_Desc, '') + ' Products'
				ELSE
					BSA_Foodservice_Items_Master.Description
				END As Description, 
				Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID,
				Program_Lump_Sum_Product_Data.Program_Lump_Sum_Product_Data_ID
	FROM    	Contract_Products 
				INNER JOIN BSA_Foodservice_Items_Master 
				ON Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID 
				LEFT JOIN Brand 
				ON BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID 
				LEFT JOIN Type_Code_Desc 
				ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID 
				INNER JOIN Program_Lump_Sum_Product_Data 
				ON Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID
				LEFT JOIN Business_Segment
				ON
				Business_Segment.Deleted = 0
				AND
				Business_Segment.Business_Segment_ID = Contract_Products.Product_Group_ID
	WHERE 		
				Program_Lump_Sum_Product_Data.Deleted = 0 
		AND 	Contract_Products.Deleted = 0 
		AND 	Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = '#Program_Lump_Sum_ID#'

</CFQUERY>
					
	<!---Query for component--->
	<CFQUERY NAME="getComponent" datasource="#application.datasource#">
	SELECT Program_Lump_Sums.*, Program_Lump_Sum_Name.Program_Lump_Sum_Name
	FROM Program_Lump_Sums
		INNER JOIN Program_Lump_Sum_Name
		ON Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
	WHERE Program_Lump_Sum_ID = '#Program_Lump_Sum_ID#'
	AND Program_Lump_Sums.DELETED = 0
	</CFQUERY>
	
	
	<CFQUERY NAME="getProgramInfo" datasource="#application.datasource#">
SELECT     dbo.Units_of_Measure.Unit_Of_Measure_Desc, dbo.Units_of_Measure.Abbreviation, dbo.Contract_Main.Contract_Quantity
FROM         dbo.Contract_Main INNER JOIN
                      dbo.Units_of_Measure ON dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
	WHERE dbo.Contract_Main.Contract_Main_ID = '#Program_ID#' 
</CFQUERY>
	
	<html>
	<head>
	<title>View <CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> Products</title>
	</head>
	<body>

	<!---Display--->
	<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
	</style>
	
	<!---Javascript--->
	<script>
	function selectAll(){
	
			document.all.checkall.checked = event.srcElement.checked;

			if(document.all.checkAllProducts.length != null) {
				for(var x=0; x<checkAllProducts.length;x++) {
					box = checkAllProducts[x].firstChild
					box.checked = document.all.checkall.checked
				}
			}
			else{
				if(document.all.checkAllProducts != null){
					box = checkAllProducts.firstChild
					box.checked = document.all.checkall.checked
				}
			}
		}
		
		function deleteItem() {
		if(confirm("Do you really want to delete these items?")){
			Delete.submit();
		}

	}
	function refreshParent()
	{
		if(window.opener)
		{
			window.opener.location.reload();
		}
		window.close();
	}
	</script>
	
	<!------<cfif len(trim(getComponent.Lump_Sum_Volume)) LT 1>
		<cfset Lump_Sum_Volume = 0>
	<cfelse>
		<cfset Lump_Sum_Volume = getComponent.Lump_Sum_Volume>
	</cfif>----->
	
	 <table cellpadding="2" cellspacing="2" border="0" bgcolor="" width="95%" style="border-bottom:solid #93BEE2 1px; border-top:solid #93BEE2 1px; border-right:solid #93BEE2 1px; border-left:solid #93BEE2 1px;" >
	 <cfoutput>
	 <tr>
	 <td>&nbsp; </td>
	 <td id="header"><strong>#getComponent.Program_Lump_Sum_Name#</strong></td>
	 <td id="header"><strong>#getComponent.Lump_Sum_Description#</strong></td>
	 <td id="header"><strong>#lsCurrencyFormat(getComponent.Lump_Sum_Amount)#</strong></td>
	 <!------<td id="header"><strong>#NumberFormat(Lump_Sum_Volume, "___,___,___.__")# #getProgramInfo.Unit_Of_Measure_Desc#</strong></td>----->
	 </tr>
	 </cfoutput>
	 </table>	
	 
<form action="LumpSum_Show_Products.cfm" method="Post" name="Delete">
 	 

	<table width="95%" cellpadding="0" cellspacing="0" border="0" style="maintable">
	<tr BGCOLOR="#FFCE84" VALIGN="bottom">
	<td id="header" style="border-bottom:solid #93BEE2 1px;">&nbsp; </td>
	<td id="header" style="border-bottom:solid #93BEE2 1px;"><input TYPE="checkbox" NAME="checkall" ONCLICK="selectAll();">	</td>
	<td id="header" style="border-bottom:solid #93BEE2 1px;" nowrap><strong><cfoutput>#application.returned_customer_setting.item_label#</cfoutput></strong></td>
<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>	<td id="header" style="border-bottom:solid #93BEE2 1px;" nowrap><strong><cfoutput>#application.returned_customer_setting.upc_label#</cfoutput></strong></td></cfif></cfif>
	<td id="header" style="border-bottom:solid #93BEE2 1px;"><strong>Description</strong></td>
	<td id="header" style="border-bottom:solid #93BEE2 1px;"><strong>Type Codes</strong></td>
	<td id="header" style="border-bottom:solid #93BEE2 1px;"><strong>Brand</strong></td>
	</tr>
	
	<cfoutput query="getLumpSumProducts">
	
	<cfset fieldname = replace(Program_Lump_Sum_Product_Data_ID, "-", "_", "ALL")>
	
	<tr  BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
	<td style="border-bottom:solid ##93BEE2 1px;">&nbsp; </td>
	<td style="border-bottom:solid ##93BEE2 1px;"><span ID="checkAllProducts"><input TYPE="Checkbox" NAME="Product_#fieldname#" ONCLICK="if(!this.checked) document.all.checkall.checked = false;"></span></td>	
	<td style="border-bottom:solid ##93BEE2 1px;">#Item#&nbsp;</td>
	<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td style="border-bottom:solid ##93BEE2 1px;">#UPC#&nbsp;</td></cfif></cfif>
	<td style="border-bottom:solid ##93BEE2 1px;">#Description#</td>
	<td style="border-bottom:solid ##93BEE2 1px;">#Type_Code_Desc#&nbsp;</td>
	<td style="border-bottom:solid ##93BEE2 1px;">#Brand_Name#&nbsp;</td>
	</tr>
	</cfoutput>
	
	</table>
	<input type="hidden" name="Delete" value="yes">
	<cfoutput>
	<input type="hidden" name="Program_ID" value="#Program_ID#">
	<input type="hidden" name="Program_Lump_Sum_ID" value="#Program_Lump_Sum_ID#">
	</cfoutput>
	</form>
	<span STYLE="color: red;"><strong>[</strong></span><A STYLE="cursor:pointer;" ONCLICK="deleteItem();"> <strong>delete selected products </strong></A><span STYLE="color: red;"><strong>]</strong></span> <span STYLE="color: red;"><strong>[</strong></span><A STYLE="cursor:pointer;" ONCLICK="refreshParent();"> <strong>close window</strong> </A><span STYLE="color: red;"><strong>]</strong></span>
	
	
	<!---Options--->
	
	</body>
	</html>