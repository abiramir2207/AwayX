<!---get price list--->
<!---if it uses the standard price list then run a straight query--->
<CFIF NOT application.returned_customer_setting.standard_pricelist>

	<cfquery name="qGetPrice" datasource="#application.datasource#">
	
		SELECT 	CS_FOB_Price = AVG(CONVERT(FLOAT,CS_FOB_Price)), 
				LB_FOB_Price = AVG(CONVERT(FLOAT,LB_FOB_Price)) 
		FROM 	Price_List
		WHERE 	BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
		
	</cfquery>
	
	<cfset casePrice = qGetPrice.CS_FOB_Price />

<cfelse>

	<!---Call the get_fob_proce stored proc to get the special price--->
	<cfstoredproc procedure="GET_FOB_PRICE" datasource="#application.datasource#">
	   
		<!--- cfprocparam tags --->
	   <cfprocparam type = "In" CFSQLType ="CF_SQL_CHAR" dbVarName = "@@SHIP_TO" value="#qGetDist.ship_to#" null="no">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_ID" value="#BSA_Foodservice_Items_Master_ID#" null="no">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRICE_ID" value="#qGetDist.price_list_header_id#" null="no">
		<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="casePrice" dbVarName = "@@CS_PRICE" null="no">
		<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="poundPrice" dbVarName = "@@LB_PRICE" null="no">
	
	</cfstoredproc>

</cfif>


