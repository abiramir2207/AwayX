<!---%%%%%%%%%%%%%%%%%%%%% SAVE FOR TESTING %%%%%%%%%%%%%%%%%%%%%--->
	<!--- <cfset list1 = #c#> --->
	<!--- <cfset list2 = #b#> --->
	<!---   <CF_List_Compare List1 = #list1# List2 = #list2#>    --->
	<!--- <cfoutput>#LC_Common#<br>#list1#<br>#list2#</cfoutput> --->
	<!--- <cfabort>  --->
<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->
  
	<cfset PAGE_TITLE = "Program Components View">	

			<cfquery name="getRebateComponentsHeader" datasource="#application.datasource#">
				SELECT Distinct Component_Number, hq_rebate_component_title, Program_Component_ID
				FROM hq_rebate
				INNER JOIN hq_rebate_components
				ON hq_rebate_components.hq_rebate_id = hq_rebate.hq_rebate_id
				WHERE hq_rebate_components.user_id = '#request.AccessStructure.User_ID#'
				AND hq_rebate_components.hq_rebate_id = #a#
			</cfquery>
						
			<cfquery name="getSelectedBrands" datasource="#application.datasource#" blockfactor="100">
					Select DISTINCT Brand
					FROM Contract_Products
					INNER JOIN  BSA_Foodservice_items_Master 
					ON Contract_Products.Product_UPC = BSA_Foodservice_items_Master.UPC
					WHERE (Contract_Products.HQ_Rebate_ID = #a# 
					AND Contract_Products.User_ID = '#request.AccessStructure.User_ID#')
					order by brand
				</cfquery>
				
				<CFQUERY NAME="GetProductsForThisProgram" datasource="#application.datasource#">
					SELECT 
						HQ_Temp_Products.HQ_Rebate_ID, 
						HQ_Temp_Products.Product_UPC,
						HQ_Rebate_Components.Program_Component_ID
					FROM HQ_Temp_Products, HQ_Rebate_Components
					WHERE HQ_Temp_Products.Program_Component_ID = 0
					AND (HQ_Temp_Products.HQ_Rebate_ID = #gcpvCryp.value#)
					AND	HQ_Temp_Products.User_ID = '#request.AccessStructure.User_ID#'
					UNION
					SELECT 
						Contract_Products.HQ_Rebate_ID, 
						Contract_Products.Product_UPC,
						HQ_Rebate_Components.Program_Component_ID
					FROM Contract_Products, HQ_Rebate_Components
					WHERE Contract_Products.Program_Component_ID = HQ_Rebate_Components.Program_Component_ID
					AND (Contract_Products.HQ_Rebate_ID = #gcpvCryp.value#)
					AND	Contract_Products.User_ID = '#request.AccessStructure.User_ID#'
				</CFQUERY>
			
				<CFQUERY NAME="GetAllHQRebateProducts" datasource="#application.datasource#">
					SELECT BSA_Foodservice_items_Master.*, 
					    Contract_Products.Product_UPC,
						HQ_Rebate_Components.Program_Component_ID
					FROM HQ_Rebate
					INNER JOIN HQ_Rebate_Components 
					ON HQ_Rebate_Components.HQ_Rebate_ID = HQ_Rebate.HQ_Rebate_ID
					INNER JOIN Contract_Products
					ON HQ_Rebate_Components.Program_Component_ID = Contract_Products.Program_Component_ID 
					INNER JOIN  BSA_Foodservice_items_Master 
					ON Contract_Products.Product_UPC = BSA_Foodservice_items_Master.UPC
					WHERE (HQ_Rebate.HQ_Rebate_ID = #a#)
					AND Contract_Products.User_ID = '#request.AccessStructure.User_ID#'
				</CFQUERY>
				
		<cfset CallingPageCode = "lw">	
			<cfloop query="getRebateComponentsHeader">
				<cfoutput>
					<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: 11pt; font-weight: bold; margin-left: 20px;">
						#hq_rebate_component_title#
					</font>
						<cfif #getRebateComponentsHeader.Program_Component_ID# neq ''>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<span style="position: absolute; left: 500px;"><input type="text"
					       name="Program_Component_ID"
					       id="Program_Component_ID" 
						   size="40"
					       value="#getRebateComponentsHeader.Program_Component_ID#">	
						   </span>
						 </cfif>	
				</cfoutput>
				
				<CFIF getSelectedBrands.recordcount GT 0>
					<cfset z = #getRebateComponentsHeader.Program_Component_ID#>
			
				<cfloop query="getSelectedBrands">							
					<cfset x = #getSelectedBrands.Brand#>
					
						<cfquery name="GetCurrentProducts" datasource="#application.datasource#">
							SELECT DISTINCT *
							FROM Contract_Products
							INNER JOIN  BSA_Foodservice_items_Master 
							ON Contract_Products.Product_UPC = BSA_Foodservice_items_Master.UPC
							WHERE (Contract_Products.HQ_Rebate_ID = #a#
							AND Contract_Products.User_ID = '#request.AccessStructure.User_ID#')
							AND BSA_Foodservice_items_Master.brand = '#Trim(x)#'
							AND Contract_Products.Program_Component_ID 
							IN (#QuotedValueList(GetAllHQRebateProducts.Program_Component_ID)#)
							AND Program_Component_ID = '#z#'
							order by brand
						</cfquery>
						
							<CF_List_Compare 
								List1 = #ValueList(GetProductsForThisProgram.Product_UPC, ",")# 
								List2 = #ValueList(GetCurrentProducts.Product_UPC, ",")#
							>		
						<span style="cursor: default;">
								<table cellpadding="0" cellspacing="0" style="margin-left: 30px;">
									<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td colspan="4"><B>Products</B></td></tr><tr><td align="left" width="25"><B>Sel</B></td><td align="left" width="25"><B>Incl</B></td><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td align="left"><B>UPC</B></td></cfif></cfif><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align="left"><B>Description</B></td></tr>							
						<CFLOOP QUERY="GetCurrentProducts">
							<cfoutput>
							<Cf_cryp string="#GetCurrentProducts.product_upc#" type="en" key="#request.key#">
							
									<tr style="height: 5px;">
										<td align="left">
											<cfif ListFindNoCase(#LC_Common#, '#GetCurrentProducts.product_UPC#', ",")>
												<img src="/Images/yes.gif" width="12" height="12" border="0">
											<cfelse>
												<img src="/Images/no.gif" width="12" height="12" border="0">
											</cfif>
										</td>
										<td width="25" align="left">
										<cfset product = REPLACE(product_UPC, "-", "__", "ALL")>
										<cfset Program = REPLACE(GetCurrentProducts.Program_Component_ID, "-", "__", "ALL")>
										<cfset Program = Trim(Program)>
											<input type="checkbox"
										       name="Incl_Prod_#c#_#product#_#Program#_#HQ_Rebate_ID#"
										       id="Incl_Prod_#c#_#product#_#Program#_#HQ_Rebate_ID#"
										       value="#GetCurrentProducts.product_UPC#">
											</td>
										<td align="left"><span style="cursor:pointer;"
	      									onClick="NewWindow('/profiles/products/product_profile.cfm?PID=#cryp.value#','name','400','450','Yes', 'No', 'No');return false;">
												#GetCurrentProducts.product_UPC#
										</span></td>
										<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
										<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td align="left"><span onClick="NewWindow('/profiles/products/product_profile.cfm?PID=#cryp.value#','name','400','450','Yes', 'No');return false;">
											#GetCurrentProducts.Description#
										</span></td></cfif></cfif>
										</span>
										</cfoutput>
									</CFLOOP>
								</cfloop>
							</tr>
							<tr><td colspan="8"><hr width="95%" size="1" color="FF0000"></td></tr>
						</table>
			</CFIF>

			<cfset y = #getRebateComponentsHeader.Component_Number#>
			
			<cfquery name="getRebateComponentsType" datasource="#application.datasource#">
				SELECT Distinct Component_Number, rebate_program_type, Program_Component_ID
				FROM hq_rebate
				INNER JOIN hq_rebate_components
				ON hq_rebate_components.hq_rebate_id = hq_rebate.hq_rebate_id
				WHERE hq_rebate_components.user_id = '#request.AccessStructure.User_ID#'
				AND hq_rebate_components.hq_rebate_id = #a#
				AND Component_Number = #y#
				<cfif IsDefined('z') AND z neq ''>AND Program_Component_ID = '#z#'</cfif>
			</cfquery>
			
			<cfloop query="getRebateComponentsType">
				<table border="0" cellspacing="0" cellpadding="0" width="95%" style="margin-left: 30px;">
			
				<cfoutput>
					
				<tr>
					<td colspan="100%">
						<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: 9pt; font-weight: bold;">
							#rebate_program_type#	<!--- <input type="text" size="5" style="left: 650px; position: absolute;" value="#HQ_Rebate_Component_ID#"> --->
						</font>
					</td>
				</tr>
				
				</cfoutput>
			
			<cfset x = #getRebateComponentsType.rebate_program_type#>
			<cfquery name="getRebateComponents" datasource="#application.datasource#">
				SELECT 
					hq_rebate.hq_rebate_id as hq_rebate_id, 
					hq_rebate_component_id,
					step_count, 
					Rate_Dollars, 
					Rebate_Rate_Type, 
					From_Date, 
					To_Date, 
					Volume_Target_From, 
					Volume_Target_To, 
					Rebate_Amount_Type, 
					Performance_Requirements, 
					Program_component_ID,
					hq_rebate_component_title,
					rebate_program_type,
					hq_rebate_component_title + '  --  ' + rebate_program_type AS header,
					component_number
				FROM hq_rebate
				INNER JOIN hq_rebate_components
				ON hq_rebate_components.hq_rebate_id = hq_rebate.hq_rebate_id
				WHERE hq_rebate_components.user_id = '#request.AccessStructure.User_ID#'
				AND hq_rebate_components.hq_rebate_id = #a#
				AND rebate_program_type = '#x#'
				AND Component_Number = #y#
				<cfif IsDefined('z') AND z neq ''>AND Program_Component_ID = '#z#'</cfif>
				order by component_number, hq_rebate_component_title, rebate_program_type
			</cfquery>		
			
					<cfoutput query="getRebateComponents">	
							<tr>
							<td width="100%">
							<cfif #getRebateComponents.step_count# neq ''><b>#step_count#</b></cfif>
								Discount #DollarFormat(getRebateComponents.Rate_Dollars)#<img src="/Images/CLEAR.GIF" alt="" width="1" height="1" border="0"> 
							<cfif #getRebateComponents.Rebate_Rate_Type# neq ''>
									/ #getRebateComponents.Rebate_Rate_Type#<img src="/Images/CLEAR.GIF" alt="" width="1" height="1" border="0">
							</cfif>
							<cfif #getRebateComponents.From_Date# neq ''>
								 	from #DateFormat(getRebateComponents.From_Date, 'm/d/yyyy')#<img src="/Images/CLEAR.GIF" alt="" width="1" height="1" border="0">
							</cfif>
							<cfif #getRebateComponents.To_Date# neq ''>
								 to #DateFormat(getRebateComponents.To_Date, 'm/d/yyyy')#<img src="/Images/CLEAR.GIF" alt="" width="1" height="1" border="0">
							</cfif>
							<cfif #getRebateComponents.Volume_Target_From# gt 0>
									for #NumberFormat(getRebateComponents.Volume_Target_From)# #getRebateComponents.Rebate_Amount_Type#<img src="/Images/CLEAR.GIF" alt="" width="1" height="1" border="0">
							</cfif>
							<cfif #getRebateComponents.Volume_Target_To# gt 0>
									to #getRebateComponents.Volume_Target_To# #getRebateComponents.Rebate_Amount_Type#.<img src="/Images/CLEAR.GIF" alt="" width="1" height="1" border="0">
							 </cfif>
							<cfif #Trim(getRebateComponents.Performance_Requirements)# neq ''>  
									<font style="font-style: italic;">
										<strong>Requirements:</strong> #getRebateComponents.Performance_Requirements#<img src="/Images/CLEAR.GIF" alt="" width="1" height="1" border="0">
									</font>
							</cfif>
							</td>
							<cfset Program = REPLACE(Program_Component_ID, "-", "__", "ALL")>
							<cfset Program = Trim(Program)>
							<cfset sea = REPLACE(c, "-", "__", "ALL")>
								<td align="right" nowrap>Rate - <input type="text" name="Comp_Rate_Discount_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#" id="Comp_Rate_Discount_#Program#" size="4">&nbsp;&nbsp;&nbsp;&nbsp;</td>
								<td align="right" nowrap>Diff - <input type="text" name="Comp_Rate_Delta_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#" id="Comp_Rate_Delta_#Program#" size="4"></td>
						
						</tr>
					</cfoutput>
				</table>
				<table><tr><td>&nbsp;</td></tr></table>
				</cfloop> 
			</cfloop>