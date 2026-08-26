<!---%%%%%%%%%%%%%%%%%%%%% SAVE FOR TESTING %%%%%%%%%%%%%%%%%%%%%--->
	<!--- <cfset list1 = #c#> --->
	<!--- <cfset list2 = #b#> --->
	<!---   <CF_List_Compare List1 = #list1# List2 = #list2#>    --->
	<!--- <cfoutput>#LC_Common#<br>#list1#<br>#list2#</cfoutput> --->
	<!--- <cfabort>  --->
<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->

<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->
<!---   Need to add user/company_main constriction to data    --->
<!---%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--->
  
	<cfset PAGE_TITLE = "Program Components View">	
			<cf_cryp type="de" string="#URL.HQR_ID#" key="#request.key#">
			
			<cfquery name="getLambProducts" datasource="#application.datasource#">
				SELECT DISTINCT *
				FROM lamb_requirements, lamb_requirements_products
				WHERE lamb_requirements.HQ_Rebate_ID = #cryp.value#
				AND lamb_requirements.Program_Component_ID = lamb_requirements_products.Program_Component_ID
				AND lamb_requirements_products.Deleted = 0
				and lamb_requirements.Deleted = 0
			</cfquery>
			
			<cfset HQRC_ID = #ValueList(getLambProducts.HQ_Rebate_Component_ID)#>
			
			<cfif HQRC_ID neq ''>
				<cfquery name="getLambRequirements" datasource="#application.datasource#">
					SELECT DISTINCT *
					FROM lamb_requirements
					WHERE HQ_Rebate_ID = #cryp.value#
					AND HQ_Rebate_Component_ID IN (#HQRC_ID#)
					AND Deleted = 0
				</cfquery>
			</cfif>
			
			<!--- NB: a = #ExistingTradeProgramsForTheseDistributors.HQ_Rebate_ID# --->
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
					FROM HQ_Rebate_Component_Products
					INNER JOIN  BSA_Foodservice_items_Master 
					ON HQ_Rebate_Component_Products.Product_UPC = BSA_Foodservice_items_Master.UPC
					WHERE (HQ_Rebate_Component_Products.HQ_Rebate_ID = #a# 
					AND HQ_Rebate_Component_Products.User_ID = '#request.AccessStructure.User_ID#')
					
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
						HQ_Rebate_Component_Products.HQ_Rebate_ID, 
						HQ_Rebate_Component_Products.Product_UPC,
						HQ_Rebate_Components.Program_Component_ID
					FROM HQ_Rebate_Component_Products, HQ_Rebate_Components
					WHERE HQ_Rebate_Component_Products.Program_Component_ID = HQ_Rebate_Components.Program_Component_ID
					AND (HQ_Rebate_Component_Products.HQ_Rebate_ID = #gcpvCryp.value#)
					AND	HQ_Rebate_Component_Products.User_ID = '#request.AccessStructure.User_ID#'
				</CFQUERY>
			
				<CFQUERY NAME="GetAllHQRebateProducts" datasource="#application.datasource#">
					SELECT BSA_Foodservice_items_Master.*, 
					    HQ_Rebate_Component_Products.Product_UPC,
						HQ_Rebate_Components.Program_Component_ID
					FROM HQ_Rebate
					INNER JOIN HQ_Rebate_Components 
					ON HQ_Rebate_Components.HQ_Rebate_ID = HQ_Rebate.HQ_Rebate_ID
					INNER JOIN HQ_Rebate_Component_Products
					ON HQ_Rebate_Components.Program_Component_ID = HQ_Rebate_Component_Products.Program_Component_ID 
					INNER JOIN  BSA_Foodservice_items_Master 
					ON HQ_Rebate_Component_Products.Product_UPC = BSA_Foodservice_items_Master.UPC
					WHERE (HQ_Rebate.HQ_Rebate_ID = #a#)
					AND HQ_Rebate_Component_Products.User_ID = '#request.AccessStructure.User_ID#'
				</CFQUERY>
				
		<cfset CallingPageCode = "lw">	
			<cfloop query="getRebateComponentsHeader">
				<cfoutput>
					<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: 11pt; font-weight: bold; margin-left: 20px;">
						#hq_rebate_component_title#
					</font>
				</cfoutput>
				
				<CFIF getSelectedBrands.recordcount GT 0>
					<cfset z = #getRebateComponentsHeader.Program_Component_ID#>
			
				<cfloop query="getSelectedBrands">							
					<cfset x = #getSelectedBrands.Brand#>
					
						<cfquery name="GetCurrentProducts" datasource="#application.datasource#">
							SELECT DISTINCT 
								HQ_Rebate_Component_Products.HQ_Rebate_Component_Products_ID, 
								HQ_Rebate_Component_Products.Product_UPC,
								HQ_Rebate_Component_Products.Program_Component_ID, 
								HQ_Rebate_Component_Products.User_ID, 
								HQ_Rebate_Component_Products.HQ_Rebate_ID,
								BSA_Foodservice_items_Master.*
							FROM HQ_Rebate_Component_Products
							INNER JOIN  BSA_Foodservice_items_Master 
							ON HQ_Rebate_Component_Products.Product_UPC = BSA_Foodservice_items_Master.UPC
							WHERE (HQ_Rebate_Component_Products.HQ_Rebate_ID = #a#
							AND HQ_Rebate_Component_Products.User_ID = '#request.AccessStructure.User_ID#')
							AND BSA_Foodservice_items_Master.brand = '#Trim(x)#'
							AND HQ_Rebate_Component_Products.Program_Component_ID 
							IN (#QuotedValueList(GetAllHQRebateProducts.Program_Component_ID)#)
							AND Program_Component_ID = '#z#'
							order by BSA_Foodservice_items_Master.brand
						</cfquery>
						
							<CF_List_Compare 
								List1 = #ValueList(GetProductsForThisProgram.Product_UPC, ",")# 
								List2 = #ValueList(GetCurrentProducts.Product_UPC, ",")#
							>		
						<span style="cursor: default;">
								<table cellpadding="0" cellspacing="0" style="margin-left: 30px;" width="100%">
									<tr>
										<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
										<td colspan="4"><B>Products</B></td>
									</tr>
									<tr>
										<td align="left" width="25"><B>Sel</B></td>
										<td align="left" width="25"><B>Incl</B></td>
										<td>&nbsp;</td>
										<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td align="left"><B>UPC</B></td></cfif></cfif>
										<!--- <td>&nbsp;&nbsp;&nbsp;&nbsp;</td> --->
										<td align="left" width="100%">&nbsp;&nbsp;&nbsp;&nbsp;<B>Description</B></td>
									</tr>							
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
										<cfset product = #REPLACE(GetCurrentProducts.product_UPC, "-", "__", "ALL")#>
										<cfset Program = #REPLACE(Program_Component_ID, "-", "__", "ALL")#>
										<cfset Program = #Trim(Program)#>
										<cfset HQ_Rebate_ID = #GetCurrentProducts.HQ_Rebate_ID#>
										
										<!--- NB: c = #GetDistInfo.BSA_Foodservice_Customers_ID# -- Distributor_ID --->
											<cfif #ListContains(ValueList(getLambProducts.UPC), GetCurrentProducts.product_UPC, ",")# 
												   AND #ListContains(ValueList(getLambProducts.Assoc_Dist_ID), c, ",")#
												   AND #HQ_Rebate_ID# eq #a#>
												<input type="checkbox"
											       name="Incl_Prod_#c#_#product#_#HQ_Rebate_ID#_UPD"
											       id="Incl_Prod_#c#_#product#_#HQ_Rebate_ID#_UPD"
											       value="#GetCurrentProducts.product_UPC#"  
												   checked>
											<cfelse>
												<input type="checkbox"
											       name="Incl_Prod_#c#_#product#_#HQ_Rebate_ID#_INS"
											       id="Incl_Prod_#c#_#product#_#HQ_Rebate_ID#_INS"
											       value="#GetCurrentProducts.product_UPC#">
											</cfif>
											</td>
										<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><td align="left" NOWRAP><span style="cursor:pointer;"
	      									onClick="NewWindow('/profiles/products/product_profile.cfm?PID=#cryp.value#','name','400','450','Yes', 'No', 'No');return false;">
												#GetCurrentProducts.product_UPC#
										</span></td></cfif></cfif>
										<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
										<td align="left" NOWRAP><span onClick="NewWindow('/profiles/products/product_profile.cfm?PID=#cryp.value#','name','400','450','Yes', 'No');return false;">
											#GetCurrentProducts.Description#
										</span></td>
										</span>
										</cfoutput>
									</CFLOOP>
								</cfloop>
							</tr>
							<tr><td colspan="8"><hr width="95%" size="1" color="FF0000"></td></tr>
						</table>
			</CFIF>
<cfif #Program_Component_ID# is ''>
<cfelse>
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
					<td width="100%">
						<font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: 9pt; font-weight: bold;">
							#rebate_program_type#	<!--- <input type="text" size="5" style="left: 650px; position: absolute;" value="#HQ_Rebate_Component_ID#"> --->
						</font>
					</td>
					<td>&nbsp;</td>
					<td align="left"><img src="/Images/CLEAR.GIF" alt="" width="20" height="1" border="0"><strong>AMT</strong></td>
					<td align="left"><img src="/Images/CLEAR.GIF" alt="" width="5" height="1" border="0"><strong>ADJ</strong></td>
				</tr>
				
				</cfoutput>
			
			<cfset x = #getRebateComponentsType.rebate_program_type#>
			<cfquery name="getRebateComponents" datasource="#application.datasource#">
				SELECT DISTINCT
					hq_rebate.hq_rebate_id as hq_rebate_id, 
					hq_rebate.Distributor_IDs,
					hq_rebate_components.hq_rebate_component_id,
					step_count, 
					Rate_Dollars, 
					Rebate_Rate_Type, 
					From_Date, 
					To_Date, 
					Volume_Target_From, 
					Volume_Target_To, 
					Rebate_Amount_Type, 
					Performance_Requirements, 
					hq_rebate_components.Program_component_ID,
					hq_rebate_component_title,
					rebate_program_type,
					hq_rebate_component_title + '  --  ' + rebate_program_type AS header,
					Component_Number
				FROM hq_rebate
				INNER JOIN hq_rebate_components
				ON hq_rebate_components.hq_rebate_id = hq_rebate.hq_rebate_id
				WHERE hq_rebate_components.user_id = '#request.AccessStructure.User_ID#'
				AND hq_rebate_components.hq_rebate_id = #a#
				AND rebate_program_type = '#x#'
				AND Component_Number = #y#
				<cfif IsDefined('z') AND z neq ''>AND hq_rebate_components.Program_Component_ID = '#z#'</cfif>
				order by component_number, hq_rebate_component_title, rebate_program_type
			</cfquery>		
					<cfloop query="getRebateComponents">	
							<cfoutput>
						<tr>
							<td width="100%" colspan="2">
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
							<b>#hq_rebate_component_id#</b>
							</td>
							<cfset Program = REPLACE(Program_Component_ID, "-", "__", "ALL")>
							<cfset Program = Trim(Program)>
							<cfset sea = REPLACE(c, "-", "__", "ALL")>
							
							<!--- 
							<cfset temp1 = ValueList(getLambRequirements.Comp_Rate_Discount)>
							<cfset temp2 = ValueList(getLambRequirements.Comp_Rate_Delta)> 
							--->
							<cfif HQRC_ID neq ''>
								<!--- Declare the array --->
								<cfset myarray=arraynew(2)>
								<!--- Populate the array row by row --->
								<cfloop query="getLambRequirements">
								  <cfset myarray[currentrow][1]=Comp_Rate_Discount[currentrow]>
								  <cfset myarray[currentrow][2]=Comp_Rate_Delta[currentrow]>
								  <cfset myarray[currentrow][3]=HQ_Rebate_Component_ID[currentrow]>
								  <cfset myarray[currentrow][4]=Assoc_Dist_ID[currentrow]>
								</cfloop>
								<!--- array upper bound --->
								<cfset total_records = #getLambRequirements.recordcount#>
							 </cfif>
							 
							<td align="right" nowrap style=""><!--- <b>Amt</b> ---> <!--- <img src="/Images/CLEAR.GIF" alt="" width="15" height="1" border="0"> ---> 
								 <cfif #ListContains(ValueList(getLambProducts.hq_rebate_component_id), hq_rebate_component_id, ",")# 
									AND #ListContains(ValueList(getLambProducts.Assoc_Dist_ID), c, ",")#
									AND #HQ_Rebate_ID# eq #a#
									AND #HQRC_ID# neq ''>			
									<input type="text"
								       name="Comp_Rate_Discount_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_UPD_#step_count#"
								       id="Comp_Rate_Discount_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_UPD_#step_count#"
								       onchange="computeAdjDiff(document.all.Comp_Rate_Discount_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_UPD_#step_count#.value, #getRebateComponents.Rate_Dollars#, document.all.Comp_Rate_Delta_#SEA#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_UPD_#step_count#)" 
									   size="4" 
									   value="<cfloop index="Counter" from=1 to="#Total_Records#"><cfif #hq_rebate_component_id# eq myarray[counter][3] AND #c# eq myarray[counter][4]>#myarray[counter][1]#</cfif></cfloop>">
								
								<!--- <img src="/Images/CLEAR.GIF" alt="" width="10" height="1" border="0"> ---> 
								 <cfelse>
									<input type="text"
								       name="Comp_Rate_Discount_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_INS_#step_count#"
								       id="Comp_Rate_Discount_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_INS_#step_count#"
								       onchange="computeAdjDiff(document.all.Comp_Rate_Discount_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_UPD_#step_count#.value, #getRebateComponents.Rate_Dollars#, document.all.Comp_Rate_Delta_#SEA#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_UPD_#step_count#)" 
									   size="4"><img src="/Images/CLEAR.GIF" alt="" width="5" height="1" border="0"> 
								 </cfif>
							</td>
							
							<td align="right" nowrap><!--- <b>Adj</b>  ---><img src="/Images/CLEAR.GIF" alt="" width="0" height="1" border="0">
								<cfif #ListContains(ValueList(getLambProducts.hq_rebate_component_id), hq_rebate_component_id, ",")# 
									AND #ListContains(ValueList(getLambRequirements.Assoc_Dist_ID), c, ",")#
									AND #HQ_Rebate_ID# eq #a#
									AND #HQRC_ID# neq ''>
									<input type="text"
								       name="Comp_Rate_Delta_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_UPD_#step_count#"
								       id="Comp_Rate_Delta_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_UPD_#step_count#"
								       size="4" 
									   value="<cfloop index="Counter" from=1 to="#Total_Records#"><cfif #hq_rebate_component_id# eq myarray[counter][3] AND #c# eq myarray[counter][4]>#myarray[counter][2]#</cfif></cfloop>">
								 
								 <cfelse>
									<input type="text"
								       name="Comp_Rate_Delta_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_INS_#step_count#"
								       id="Comp_Rate_Delta_#sea#_#Program#_#hq_rebate_component_id#_#HQ_Rebate_ID#_INS_#step_count#"
								       size="4" 
									   value="">
								 </cfif>
							</td>
						</tr>
						</cfoutput>
					</cfloop>
				</table>
				<table><tr><td>&nbsp;</td></tr></table>
				</cfloop> 
			</cfif>
			</cfloop>
