<cfif isDefined("stError")>
	
	<script>
	<cfoutput>		
	<cfif stError.bNameExists EQ 1>
		alert("This alias already exists. You cannot create two entries with the same alias.");		
	</cfif>
	</cfoutput>
	</script>
</cfif>
<cfoutput>

	<CF_MessageWindow>


<cfparam name="form.Product_Alias" 				default="">
<cfparam name="form.ExistingProductList" 		default="">
<cfparam name="form.Product_List" 				default="">
<cfparam name="form.Alias_ID" 					default="">

<cfif len(trim(compId)) GT 0>
	<!--- Edit option --->
	<cfset compAlias = CreateObject("component","components.settings.AliasManagement.Alias")>
	<cfset GetAlias = compAlias.searchAlias("","","","",2,compId)>

	<cfif GetAlias.Recordcount GT 0 AND len(trim(form.Product_Alias)) LT 1 AND len(trim(form.ExistingProductList)) LT 1 AND len(trim(form.Product_List)) LT 1>
		<cfset form.Product_Alias = GetAlias.Alias_String>
		<cfset form.ExistingProductList = GetAlias.Alias_Item_ID>
		<cfset form.Product_List = GetAlias.Alias_Item_ID>
	</cfif>
	
</cfif>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Product Alias Information</LEGEND>
	<table width="90%" border="0">
		<colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup>
		
	
	<!--- Product Alias  --->
	
				<TR>
					<TD ALIGN="right"><B>Product Alias Text:</B><br>(What people call the product)</TD>
					<TD><span id="error_ProductAlias1"></span><span id="error_ProductAlias2"></span><span id="error_ProductAlias3"></span><INPUT NAME="Product_Alias" TYPE="text" VALUE="#form.Product_Alias#" SIZE="30" MAXLENGTH="50"></TD>
				</TR>
					<TR>
					
					<cfif len(trim(form.Product_List)) GT 0>
				<tr>	
				<td align="right"><strong>Selected product:</strong></td>
				
				<cfset useLakebaseForGetProductInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetProductInfo>
	<cftry>
		<cfset GetProductInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#form.Product_List#",
				"select" = "description,item,upc"
			}), "description,item,upc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetProductInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProductInfo>
<cfquery name="GetProductInfo" datasource="#application.datasource#">
				select description, item, upc 
				FROM bsa_foodservice_items_master
				WHERE bsa_foodservice_items_master_ID = '#form.Product_List#'
				</cfquery>
</cfif>
				
				<td>#trim(GetProductInfo.description)# (#GetProductInfo.item#/#GetProductInfo.UPC#)</td>
					
				</tr>
				</cfif>
				<Td align="right">
				<cfif len(trim(form.Product_List)) GT 0>
				<strong>Search for a different product</strong>:
				<cfelse><B>Search for product:</B>
				</cfif></TD>
				<Td><CF_smallLink 
	title = "search for product" 
	url = "##"
	parameters = "onClick=""showProductSearchWindow();return false;"""
>
	<INPUT NAME="ExistingProductList" TYPE="hidden"  value="#form.ExistingProductList#">
	<INPUT NAME="Product_List" TYPE="hidden"  value="#form.Product_List#">

	</TD></tr>
		<tr><td>&nbsp; </td><Td align="Center">
			<p>&nbsp; </p>
	
		<cfif len(trim(compId)) GT 0>
			<CF_smallLink 
				title = "save product alias changes" 
				url = "##"
				parameters = "onClick=""confirmProductCompletion('edit');return false;"""
			>
			<cfelse>
			<CF_smallLink 
				title = "save product alias" 
				url = "##"
				parameters = "onClick=""confirmProductCompletion('add');return false;"""
			>
			</cfif>

</TD></tr>

		<!--- /Product Alias  --->
		
	</table>
</FIELDSET>
</cfoutput>