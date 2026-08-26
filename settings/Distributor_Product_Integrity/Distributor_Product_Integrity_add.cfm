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

<cfparam name="form.Distributor_Product_Integrity_Rule_ID" 	default="">
<cfparam name="form.Rule_Name" 								default="">
<cfparam name="form.Error_Msg" 								default="">
<cfparam name="form.Inclusive_Restriction" 					default="0">
<cfparam name="form.Distributor_List"						default="">
<cfparam name="form.Product_List"							default="">

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Product Integrity Rules</LEGEND>
	<table width="90%" border="0">
		<colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup>
		<cfoutput>
		
		<TR>
			<TD ALIGN="right"><B>Rule Name:</B></TD>
			<TD colspan><INPUT NAME="Rule_Name" TYPE="text" VALUE="#form.Rule_Name#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
	
		<TR>
			<TD ALIGN="right"><B>Error Message:</B></TD>
			<TD colspan><INPUT NAME="Error_Msg" TYPE="text" size="30" MAXLENGTH="500" value="#form.Error_Msg#"></TD>
		</TR>	
		
		<TR>
			<TD ALIGN="right"><B>Restrictive:</B></TD>
			<TD ><INPUT NAME="Inclusive_Restriction" TYPE="radio" value="0" <cfif form.Inclusive_Restriction IS 0>checked</cfif>>No 
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT NAME="Inclusive_Restriction" TYPE="radio" value="1" <cfif form.Inclusive_Restriction IS 1>checked</cfif>>Yes</TD>
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
				</cfif>
				<input type="hidden" name="Product_List" value="#form.Product_List#">
				<CF_smallLink 
					title = "Add Products" 
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
			</cfif>
			
				<input type="hidden" name="Distributor_List" value="#form.Distributor_List#">
					<CF_smallLink 
					title = "Add #application.returned_customer_setting.distributor_label_singular#" 
					url = "##"
					parameters = "onClick=""javascript: return showDistributorSearchWindow();"""
				>
			</TD>
		</TR>
		
		</cfoutput>	
		<input type="hidden" name="ExistingProductList" value="">
		<input type="hidden" name="Distributor_Product_Integrity_Rule_ID" value="#form.Distributor_Product_Integrity_Rule_ID#">
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return addComp();"
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