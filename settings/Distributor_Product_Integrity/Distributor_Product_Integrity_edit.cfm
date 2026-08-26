<cfif isDefined("stError")>
	<cfset showCompTypeName = "Component name" />
	<cfif form.rebate_type EQ 2>
		<cfset showCompTypeName = "PP Increase Rebate Component" />
	</cfif>
	<script>
	<cfoutput>		
	<cfif stError.bNameExists EQ 2>
		alert("This rule already exists with a different ID.");		
	<cfelseif stError.bNameExists EQ 3>
		alert("Another rule exists with the same name.");
	</cfif>
	</cfoutput>
	</script>
</cfif>

<cfparam name="form.Distributor_List" default="">
<cfparam name="form.Product_List" default="">

<cfquery name="GetExistingComponent" datasource="#application.datasource#">
SELECT * from Distributor_Product_Integrity_Rule
WHERE Distributor_Product_Integrity_Rule_ID = '#compID#'
</cfquery>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Product Integrity Rules</LEGEND>
	<cfoutput>
	<table width="90%" border="0">
		<colgroup>
		<col width="30%"></col>
		
		</colgroup>
		<TR>
			<TD ALIGN="right"><B>Rule Name:</B></TD>
			<TD colspan><INPUT NAME="Rule_Name" TYPE="text" VALUE="#GetExistingComponent.Rule_Name#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
	
		<TR>
			<TD ALIGN="right"><B>Error Message:</B></TD>
			<TD colspan><INPUT NAME="Error_Msg" TYPE="text" size="30" MAXLENGTH="500" value="#GetExistingComponent.Error_Msg#"></TD>
		</TR>	
		
		<TR>
			<TD ALIGN="right"><B>Restrictive:</B></TD>
			<TD ><INPUT NAME="Inclusive_Restriction" TYPE="radio" value="0" <cfif GetExistingComponent.Inclusive_Restriction IS 0>checked</cfif>>No 
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT NAME="Inclusive_Restriction" TYPE="radio" value="1" <cfif GetExistingComponent.Inclusive_Restriction IS 1>checked</cfif>>Yes</TD>
		</TR>	
		
		<TR>
			<TD ALIGN="right" valign="top"><B>Products:</B></TD>
			<TD >

			<cfif len(trim(form.Product_List)) GT 0>
				<cfquery name="GetRuleProducts" datasource="#application.datasource#">
				SELECT Description, Item, BSA_Foodservice_Items_Master_ID
				FROM BSA_Foodservice_Items_Master
				WHERE BSA_Foodservice_Items_Master_ID IN (#listqualify(form.Product_List,"'")#)
				</cfquery>
			<cfelse>
				<cfquery name="GetRuleProducts" datasource="#application.datasource#">
				SELECT Description, Item, BSA_Foodservice_Items_Master_ID
				FROM BSA_Foodservice_Items_Master
					INNER JOIN Distributor_Product_Integrity_Products
					ON Distributor_Product_Integrity_Products.Product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
					AND Distributor_Product_Integrity_Products.Deleted = 0
					AND Distributor_Product_Integrity_Products.Distributor_Product_Integrity_Rule_ID = '#compID#'
				</cfquery>			
			</cfif>
			
				<cfset ProductList = valuelist(GetRuleProducts.BSA_Foodservice_Items_Master_ID)>
				
				<table width="100%" BGCOLOR="EAFFEA" >
					<tr>
						<cfloop query="GetRuleProducts">
						<td CLASS="dataStyle" WIDTH="33%" VALIGN="top">
							#left(GetRuleProducts.Description, 50)#<cfif len(GetRuleProducts.Description)GT 50>...</cfif>
							(#GetRuleProducts.Item#)
						</td>
						<CFIF GetRuleProducts.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
						</cfloop>
				</table>
				
				<input type="hidden" name="Product_List" value="#ProductList#">
				<CF_smallLink 
					title = "Modify Product Selection" 
					url = "##"
					parameters = "onClick=""javascript: return showProductSearchWindow();"""
				>
			</TD>
		</TR>

		<TR>
			<TD ALIGN="right" valign="top"><B>#application.returned_customer_setting.distributor_label_singular#:</B></TD>
			<TD>
				
				
				<cfif len(trim(form.Distributor_List)) GT 0>
					<cfquery name="GetRuleDistributors" datasource="#application.datasource#">
					SELECT Name, Ship_To, BSA_Foodservice_Customers_ID
					FROM BSA_Foodservice_Customers
					WHERE BSA_Foodservice_Customers_ID IN  (#listqualify(form.Distributor_List,"'")#) 
					</cfquery>
				<cfelse>	
					<cfquery name="GetRuleDistributors" datasource="#application.datasource#">
					SELECT Name, Ship_To, BSA_Foodservice_Customers_ID
					FROM BSA_Foodservice_Customers
						INNER JOIN Distributor_Product_Integrity_Distributors
						ON Distributor_Product_Integrity_Distributors.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
						AND Distributor_Product_Integrity_Distributors.Deleted = 0
						AND Distributor_Product_Integrity_Distributors.Distributor_Product_Integrity_Rule_ID = '#compID#'
					</cfquery>
				</cfif>
				
				<cfset DistributorList = valuelist(GetRuleDistributors.BSA_Foodservice_Customers_ID)>
				
				<table width="100%" BGCOLOR="EAFFEA" >
					<tr>
						<cfloop query="GetRuleDistributors">
						<td CLASS="dataStyle" WIDTH="33%" VALIGN="top">
							#left(GetRuleDistributors.Name, 50)#<cfif len(GetRuleDistributors.Name)GT 50>...</cfif>
							(#GetRuleDistributors.Ship_to#)
						</td>
						<CFIF GetRuleDistributors.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
						</cfloop>
				</table>
				
				<input type="hidden" name="Distributor_List" value="#DistributorList#">
					<CF_smallLink 
					title = "Modify #application.returned_customer_setting.distributor_label_singular# Selection" 
					url = "##"
					parameters = "onClick=""javascript: return showDistributorSearchWindow();"""
				>
			</TD>
		</TR>
		
		
		<input type="hidden" name="ExistingDistributorList" value="#DistributorList#">
		<input type="hidden" name="ExistingProductList" value="#ProductList#">
		<input type="hidden" name="Distributor_Product_Integrity_Rule_ID" value="#compID#">
		<input type="hidden" name="compID" value="#compID#">
		</cfoutput>	
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return updateComp();"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</table>
	</FIELDSET>