<!---  Dinesh Rachala
May 13 2011
LABEL 25701--->

<!--- NOTE: EARLIER, THIS PAGE WAS BEING CALLED FROM BID_INFO.CFM TOO. BUT NOW IT IS NOT.
SOME OF THE LEGACY CODE ON THIS PAGE WHICH MAY BE POINTING TO THIS FILE BEING CALLED FROM
BID_INDO.CFM DOES STILL EXIST.
NOW, BID_INFO.CFM CALLS BID_INFO_SAVE.CFM.
--->

<cfif NOT isdefined("form.source") OR (#len(form.source)# LTE 0) OR #form.source# EQ 'novalue'>
<cfset source = 0>
<cfelse>
<cfset source = #trim(form.source)#>
</cfif>

<cfif NOT isdefined("form.sourcetype") OR (#len(form.sourcetype)# LTE 0) OR #form.sourcetype# EQ 'novalue'>
<cfset sourcetype = 0>
<cfelse>
<cfset sourcetype = #trim(form.sourcetype)#>
</cfif>

<cfif NOT isdefined("form.sourcedate") OR (#len(form.sourcedate)# LTE 0)>
<cfset sourcedate = #DateFormat(Now(), 'mm/dd/yyyy')#>
<cfelse>
<cfset sourcedate = #trim(form.sourcedate)#>
</cfif>


<cfparam name="url.type" default="">
<cfparam name="form.page_number" default="1">

<cfoutput> 
<!--- This Query UPDATE PROGRAM BID REQUEST START --->

<cfquery name="update_program_bid_request" datasource="#application.datasource#">
UPDATE Program_Bid_request
SET Program_Bid_Source_ID = #source#, 
Program_Bid_Source_Type_ID = #sourcetype#, 
Program_Bid_Source_Date = '#sourcedate#'
WHERE program_id = <cfqueryparam value= "#trim(form.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<!--- THIS Query UPDATE PROGRAM BID REQUEST END --->

<cf_cryp type="en" key="#request.key#" string="#form.contract_main_id#">
<!--- This Component Returns all ProductID(BSA Program Id) as Query later on we use this Query to do QueryOFQuery START --->
<cfinvoke component="components.programs.bid_request.CompetitiveDataManager" method="getProgramCompetitiveProductData" returnVariable="items_info">
<cfinvokeargument name="programID" value="#trim(FORM.Contract_Main_ID)#">
</cfinvoke>

<!--- This Component Returns all ProductID(BSA Program Id) as Query later on we use this Query to do QueryOFQuery END --->
<cfset items = Arraynew(1)>

<cfset unique_item_group = ''>

<!--- This IF Determines if we are applying MASS APPLY or by ITEM  START--->
   <!--- 
   ######################################################################################################################################################################################################################## 
   ######################################################################################################################################################################################################################## 
   ####################################################################################MASS APPLY STARTS FROM HERE#########################################################################################################
   ######################################################################################################################################################################################################################## 
   ########################################################################################################################################################################################################################  
   ---> 


<cfif #trim(url.type)# EQ 'massapply'>


<cfparam name="form.mass_apply_package_type" default="0">
<cfparam name="form.mass_apply_category_type" default="0">
<cfparam name="form.mass_apply_shared" default="0">
<cfparam name="form.mass_apply_incremetal" default="0">
<cfparam name="form.mass_apply_specd" default="0">
<cfparam name="form.mass_apply_delivery_type" default="0">
<cfparam name="form.mass_apply_uom" default="0">
<cfparam name="form.mass_apply_rate" default="0">
<cfparam name="form.mass_apply_company" default="0">

                                
	                               <cfif isdefined("form.mass_apply_group") AND #form.mass_apply_group# NEQ 0>
								   	   
								   	   <cfset unique_item_group = listappend(unique_item_group, #trim(form.mass_apply_group)#)>
 											<!--- This Query gets Unique Product_Id using Product group they selected in MASS APPLY Section START --->	
											<!--- if -1 is not present then user selected individual groups,  
												  else if -1 is present in the form.mass_apply_group, then it means user selected "All products" option in the muliple select,
												  so go to the else and pick all the products. 
											--->
											<cfif listFind(form.mass_apply_group,"-1") EQ 0>
												<cfquery name="items_details" dbtype="query"> 
												SELECT BSA_FOODSERVICE_ITEMS_MASTER_ID FROM items_info WHERE PRODUCT_GROUP_ID IN (<cfqueryparam value= "#trim(form.mass_apply_group)#" cfsqltype="CF_SQL_CHAR" list="yes" >)
												</cfquery>
											<cfelse>
												<cfquery name="items_details" dbtype="query"> 
												SELECT BSA_FOODSERVICE_ITEMS_MASTER_ID FROM items_info
												</cfquery>
											</cfif>												
											<!--- This Query gets Unique Product_Id using Product group they selected in MASS APPLY Section END --->
													<cfloop query="items_details">
													<cfset Arrayappend(items, #items_details.BSA_FOODSERVICE_ITEMS_MASTER_ID#)>
													</cfloop>
									<cfelseif isdefined("form.checkbox_value") AND #len(form.checkbox_value)# GT 0>

									    <cfloop from="1" to="#listlen(form.checkbox_value)#" index="check_box">
											<!--- This Query gets Unique Product_Id using Product group they selected in MASS APPLY Section START --->	
											<cfquery name="items_details" dbtype="query"> 
											SELECT BSA_FOODSERVICE_ITEMS_MASTER_ID FROM items_info WHERE item = <cfqueryparam value='#trim(listGetAt(form.checkbox_value, check_box))#' cfsqltype="CF_SQL_VARCHAR" >
											</cfquery>
											<!--- This Query gets Unique Product_Id using Product group they selected in MASS APPLY Section END --->
												<cfset Arrayappend(items, #items_details.BSA_FOODSERVICE_ITEMS_MASTER_ID#)>
									    </cfloop>
									<cfelseif isdefined("form.MASS_APPLY_ALL") AND #form.MASS_APPLY_ALL# EQ "massapply_all">
									        <!--- This Query gets Unique Product_Id for ALL items when a check box is checked to MASS APPLY ALL START --->	
											<cfquery name="items_details" dbtype="query"> 
											SELECT BSA_FOODSERVICE_ITEMS_MASTER_ID FROM items_info
											</cfquery>
											<!--- This Query gets Unique Product_Id for ALL items when a check box is checked to MASS APPLY ALL  END --->
													<cfloop query="items_details">
													<cfset Arrayappend(items, #items_details.BSA_FOODSERVICE_ITEMS_MASTER_ID#)>
													</cfloop>
									</cfif> 
							
										
<!--- This if statement determine who WON the Product  WON = 0 if competator won, WON = 1 if Client WOM   START --->
											 
<cfif #form.mass_apply_won_lost# EQ 2>
<cfset won = 0>
<cfelseif #form.mass_apply_won_lost# EQ 1>
<cfset won = 1>
<cfelse>
<cfset won="NULL" />
</cfif>							
 <!--- This if statement determine who WON the Product  WON = 0 if competator won, WON = 1 if Client WOM   END --->
                       <!--- <cfif (#form.mass_apply_won_lost# EQ 1 AND #form.mass_apply_shared# EQ 1) OR (#form.mass_apply_won_lost# EQ 2)> --->
					   <cfif (#form.mass_apply_won_lost# EQ 1) OR (#form.mass_apply_won_lost# EQ 2)>
							<cfset till = #MAX(listlen(form.mass_apply_company), listlen(form.mass_apply_rate))#>
							<cfset till = #MAX(till, listlen(form.mass_apply_uom))#>
							<cfset till = #MAX(till, listlen(form.mass_apply_delivery_type))#>
							
						 <cfloop from="1"  to="#arraylen(items)#" index="item_id">


						<!--- Checks if there are records in Program  Competitive Data START --->
						<cfquery name="check_PCD" datasource="#application.datasource#">
						SELECT * FROM Program_Competitive_Data WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER" > AND Product_Id = <cfqueryparam value='#trim(items[item_id])#' cfsqltype="CF_SQL_VARCHAR" >
						</cfquery>
						<!--- Checks if there are records in Program  Competitive Data END --->
						
									<!--- DELETE if there are records in Program  Competitive Data START --->
									<cfif #check_PCD.recordcount# GT 0>
											<cfquery name="Delete_PCD" datasource="#application.datasource#">
											DELETE FROM Program_Competitive_Data WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER" > AND Product_Id = <cfqueryparam value='#trim(items[item_id])#' cfsqltype="CF_SQL_VARCHAR" >
											</cfquery>
									</cfif>
									<!--- DELETE if there are records in Program  Competitive Data START --->
						</cfloop> 								

						<!--- this loop through clone of form fields --->
						<cfloop from="1" to="#till#" index="company">

						
						<!--- This Loop AND Query will Update ProgramCompetitiveData Table  START --->
								<cfloop from="1"  to="#arraylen(items)#" index="item_id">
								            	<cfquery name="Insert_program_Competitive_Data" datasource="#application.datasource#">
												INSERT INTO Program_Competitive_Data(
												Program_ID, 
												Product_ID, 
												Program_Bid_Won_By_ID, 
												Won_Price, 
												Won_Uom, 
												Won_Delivery_Type
												)
												Values(
												#trim(FORM.Contract_Main_ID)#, 
												'#trim(items[item_id])#', 
												<cfif (#listlen(form.mass_apply_company)# GT 0) AND (#listlen(form.mass_apply_company)# GTE #company#)>
												
												#trim(listGetAt(form.mass_apply_company, company))#,
												
												<cfelse>
												0,
												</cfif> 
														<cfif (#listlen(form.mass_apply_rate)# GT 0) AND (#listlen(form.mass_apply_rate)# GTE #company#)>
														
														#trim(listGetAt(form.mass_apply_rate, company))#,
														
														<cfelse>
														0,
														</cfif>
												<cfif (#listlen(form.mass_apply_uom)# GT 0) AND (#listlen(form.mass_apply_uom)# GTE #company#)>
												
												#trim(listGetAt(form.mass_apply_uom, company))#,
												
												<cfelse>
												0,
												</cfif>
														<cfif (#listlen(form.mass_apply_delivery_type)# GT 0) AND (#listlen(form.mass_apply_delivery_type)# GTE #company#)>
														
														#trim(listGetAt(form.mass_apply_delivery_type, company))#
														
														<cfelse>
														0
														</cfif>
												
												)
												</cfquery>
						
								</cfloop>
						
						
						
						</cfloop>
						<!--- This Loop AND Query will Update ProgramCompetitiveData Table  END --->

				</cfif>							
									
										
										<!--- This Loop is done to INSERT Records into Program_Product_bid_info START --->
										<cfloop from="1"  to="#arraylen(items)#" index="item_id">
										
														<!--- Checks if there are records in Program_product_bid_info START --->
														<cfquery name="check_PPBI" datasource="#application.datasource#">
														SELECT * FROM Program_product_bid_info WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER" > AND Product_Id = <cfqueryparam value='#trim(items[item_id])#' cfsqltype="CF_SQL_VARCHAR" > and deleted = 0
														</cfquery>
														<!--- Checks if there are records in Program_product_bid_info END --->
														
														<cfquery name="qGetLineNumber" datasource="#application.datasource#">
														SELECT Line_number FROM Program_product_bid_info WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER" > AND Product_Id = <cfqueryparam value='#trim(items[item_id])#' cfsqltype="CF_SQL_VARCHAR" > and deleted = 0
														</cfquery>
														<cfif qGetLineNumber.RecordCount NEQ 0 and qGetLineNumber.Line_number NEQ "">
															<cfset line_number = qGetLineNumber.Line_number />
														<cfelse>
															<cfset line_number = "NULL" />
														</cfif>
	
														
														
														<!--- DELETE if there are records in Program_product_bid_info START --->
														<cfif #check_PPBI.recordcount# GT 0>
																	<cfquery name="Delete_PPBI" datasource="#application.datasource#">
																	INSERT INTO [History_Program_Product_Bid_Info]
																		([Program_Product_Bid_Info_ID]
																		 ,[Program_ID]
																		 ,[Product_ID]
																		 ,[Won]
																		 ,[Won_By]
																		 ,[Won_Price]
																		 ,[Won_Uom]
																		 ,[Deleted]
																		 ,[Created_Date]
																		 ,[Won_Delivery_Type]
																		 ,[Program_Bid_Won_By_ID]
																		 ,[Program_Bid_Category_ID]
																		 ,[Program_Bid_Package_ID]
																		 ,[Shared]
																		 ,[Incremental]
																		 ,[Line_Number]
																		 ,[Specd]
																		 ,[Updated_Date]
																		 ,[Updated_By])
																	SELECT 	[Program_Product_Bid_Info_ID]
																		 ,[Program_ID]
																		 ,[Product_ID]
																		 ,[Won]
																		 ,[Won_By]
																		 ,[Won_Price]
																		 ,[Won_Uom]
																		 ,[Deleted]
																	 	,[Created_Date]
																		 ,[Won_Delivery_Type]
																		 ,[Program_Bid_Won_By_ID]
																		 ,[Program_Bid_Category_ID]
																		 ,[Program_Bid_Package_ID]
																		 ,[Shared]
																		 ,[Incremental]
																		 ,[Line_Number]
																		 ,[Specd]
																		 ,[Updated_Date]
																		 ,[Updated_By]
																	FROM Program_Product_Bid_Info
																	WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER" > AND Product_Id = <cfqueryparam value='#trim(items[item_id])#' cfsqltype="CF_SQL_VARCHAR" > and deleted = 0

																	UPDATE Program_product_bid_info SET deleted = 1 WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER" > AND Product_Id = <cfqueryparam value='#trim(items[item_id])#' cfsqltype="CF_SQL_VARCHAR" > and deleted = 0
																	</cfquery>
														</cfif>
														<!--- DELETE if there are records in Program_product_bid_info START --->
                       
						
						
										      <cfquery name="items_won_details" dbtype="query"> 
											  SELECT DELIVERY_TYPE, RATE, UNIT_OF_MEASURE_ID FROM items_info WHERE BSA_FOODSERVICE_ITEMS_MASTER_ID = <cfqueryparam value='#trim(items[item_id])#' cfsqltype="CF_SQL_VARCHAR" >  
											  </cfquery>
											  											  
											 <cfquery name="insert_program_product_bid_info" datasource="#application.datasource#"> 
												INSERT INTO Program_product_bid_info(
												Program_ID, 
												Product_ID,
												Won, 
												Program_Bid_Category_ID, 
												Program_Bid_Package_ID, 
												Shared, 
												Line_Number,
												Incremental,
												Specd
												<cfif #form.mass_apply_won_lost# EQ 1>,
														Won_By,
														Won_Price,
														Won_Uom,
														Won_Delivery_type
												</cfif>
												,Updated_Date
												,Updated_By
												)
												Values(
												#trim(FORM.Contract_Main_ID)#, 
												'#trim(items[item_id])#', 
												#won#, 
												#form.mass_apply_category_type#, 
												#form.mass_apply_package_type#, 
												#form.mass_apply_shared#, 
												<cfif line_number eq "null">null<cfelse>'#line_number#'</cfif>,
												#form.mass_apply_incremetal#,
												#form.mass_apply_specd#
												<cfif #form.mass_apply_won_lost# EQ 1>,
														'#trim(application.returned_customer_setting.Company_Name)#',
														#trim(items_won_details.RATE)#,
														<cfif items_won_details.DELIVERY_TYPE EQ "FOB">
													   1,
														 <cfelseif items_won_details.DELIVERY_TYPE EQ "DELIVERED">
													   2,
														 </cfif>
														#trim(items_won_details.UNIT_OF_MEASURE_ID)#
												</cfif>
												,getdate()
												,'#request.accessstructure.User_ID#'
												)
												</cfquery>

										</cfloop>
										<!--- This Loop is done to INSERT Records into Program_Product_bid_info END --->

<!--- 
######################################################################################################################################################################################################################## 
######################################################################################################################################################################################################################## 
################################################################################NOT MASS APPLY STARTS FROM HERE#########################################################################################################
######################################################################################################################################################################################################################## 
########################################################################################################################################################################################################################  
---> 
<cfelse>

	<cfset complete_info = 0>
	<cfloop query="items_info" startrow="#trim(form.start_row)#" endrow="#trim(form.end_row)#">
		<cfset inputNamePrefix = "#trim(item)#_#Replace(items_info.BSA_Foodservice_Items_Master_ID,'-','_','ALL')#" />	
		
		<!--- Insert into List when Group exist START --->
		<cfif len(Product_Group_ID) GT 0 AND listfind(unique_item_group, product_group_id) EQ 0>
			<cfset unique_item_group = listappend(unique_item_group, product_group_id)>
		</cfif>
<!--- Insert into List when Group exist END --->
	
		<cfif (structKeyExists(form,"#inputNamePrefix#_company") AND #form["#inputNamePrefix#_company"]# EQ 0) AND (structKeyExists(form,"#inputNamePrefix#_rate") AND #form["#inputNamePrefix#_rate"]# EQ 0) AND 
		(structKeyExists(form,"#inputNamePrefix#_cases") AND #form["#inputNamePrefix#_cases"]# EQ 0) AND (structKeyExists(form,"#inputNamePrefix#_delivery_type") AND #form["#inputNamePrefix#_delivery_type"]# EQ 0 )
		AND (structKeyExists(form,"#inputNamePrefix#_WON_LOST") AND #form["#inputNamePrefix#_WON_LOST"]# EQ 0)
		AND (structKeyExists(form,"#inputNamePrefix#_Specd") AND #form["#inputNamePrefix#_Specd"]# EQ 0)
		AND (structKeyExists(form,"#inputNamePrefix#_shared") AND #form["#inputNamePrefix#_shared"]# EQ 0)
		AND (structKeyExists(form,"#inputNamePrefix#_Incremental") AND #form["#inputNamePrefix#_Incremental"]# EQ 0)>



		<cfset complete_info = 0>
		
		<cfelse>
			
			<cfset complete_info = 1>
		
		<cfif structKeyExists(form,"#inputNamePrefix#_won_lost") AND (#form["#inputNamePrefix#_won_lost"]# EQ 1)>
		<!--- won the ITEM --->
		<cfset won = 1>
		<cfelseif structKeyExists(form,"#inputNamePrefix#_won_lost") AND (#form["#inputNamePrefix#_won_lost"]# EQ 2)>
		<!--- LOST the ITEM --->
		<cfset won = 0>
		<cfelse>
		<cfset won = 2>
		</cfif>

		<!--- Checks if there are records in Program_product_bid_info START --->
		<cfquery name="check_PPBI" datasource="#application.datasource#">
			SELECT * 
			FROM Program_product_bid_info 
			WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER" > 
			AND Product_Id = <cfqueryparam value='#trim(items_info.BSA_FOODSERVICE_ITEMS_MASTER_ID)#' cfsqltype="CF_SQL_VARCHAR" >  
			AND deleted = 0
		</cfquery>
		<!--- Checks if there are records in Program_product_bid_info END --->
		
		<!--- DELETE if there are records in Program_product_bid_info START --->
		<cfif #check_PPBI.recordcount# GT 0>
			<cfquery name="Delete_PPBI" datasource="#application.datasource#">
				INSERT INTO [History_Program_Product_Bid_Info]
					([Program_Product_Bid_Info_ID]
					,[Program_ID]
					,[Product_ID]
					,[Won]
					,[Won_By]
					,[Won_Price]
					,[Won_Uom]
					,[Deleted]
					,[Created_Date]
					,[Won_Delivery_Type]
					,[Program_Bid_Won_By_ID]
					,[Program_Bid_Category_ID]
					,[Program_Bid_Package_ID]
					,[Shared]
					,[Incremental]
					,[Line_Number]
					,[Specd]
					,[Updated_Date]
					,[Updated_By])
				SELECT [Program_Product_Bid_Info_ID]
					,[Program_ID]
					,[Product_ID]
					,[Won]
					,[Won_By]
					,[Won_Price]
					,[Won_Uom]
					,[Deleted]
					,[Created_Date]
					,[Won_Delivery_Type]
					,[Program_Bid_Won_By_ID]
					,[Program_Bid_Category_ID]
					,[Program_Bid_Package_ID]
					,[Shared]
					,[Incremental]
					,[Line_Number]
					,[Specd]
					,[Updated_Date]
					,[Updated_By]
				FROM Program_Product_Bid_Info
				WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER" > 
				AND Product_Id = <cfqueryparam value='#trim(items_info.BSA_FOODSERVICE_ITEMS_MASTER_ID)#' cfsqltype="CF_SQL_VARCHAR" > 
				AND deleted = 0

				UPDATE Program_product_bid_info 
				SET deleted = 1 
				WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER" > 
				AND Product_Id = <cfqueryparam value='#trim(items_info.BSA_FOODSERVICE_ITEMS_MASTER_ID)#' cfsqltype="CF_SQL_VARCHAR" > 
				AND deleted = 0
			</cfquery>
		</cfif>
<!--- DELETE if there are records in Program_product_bid_info START --->
		
	<cfquery name="update_program_bid_request" datasource="#application.datasource#"> 
			INSERT INTO Program_Product_Bid_Info(
			Program_ID, 
			Product_ID, 
			Won, 
			<cfif structKeyExists(form,"#inputNamePrefix#_category_type") AND trim(form["#inputNamePrefix#_category_type"]) NEQ "">
			Program_Bid_Category_ID,
			</cfif>
			<cfif structKeyExists(form,"#inputNamePrefix#_package_type")  AND trim(form["#inputNamePrefix#_package_type"]) NEQ ""> 
			Program_Bid_Package_ID, 
			</cfif>
			Shared, 
			Incremental,
			Specd
			<cfif #structKeyExists(form,"#inputNamePrefix#_won_lost")# AND (#form["#inputNamePrefix#_won_lost"]# EQ 1)>
				<cfif #structKeyExists(form,"#inputNamePrefix#_client_won")#>
						,Won_By
				 </cfif>
				 <cfif #structKeyExists(form,"#inputNamePrefix#_client_won_rate")#>
						,Won_Price
				 </cfif>
				 <cfif #structKeyExists(form,"#inputNamePrefix#_client_won_uom")#>														 
						,Won_Uom
				 </cfif>
				 <cfif #structKeyExists(form,"#inputNamePrefix#_client_won_delivery_type")#>
						,Won_Delivery_type
				 </cfif>
			</cfif>
			<cfif  (#structKeyExists(form,"#inputNamePrefix#_line_number")# and form["#inputNamePrefix#_line_number"] NEQ "")>
				,Line_Number
			</cfif>
			,Updated_Date
			,Updated_By
			)
           Values(
			#trim(FORM.Contract_Main_ID)#, 
		   '#trim(items_info.BSA_FOODSERVICE_ITEMS_MASTER_ID)#', 
			#won#, 
			<cfif structKeyExists(form,"#inputNamePrefix#_category_type") AND trim(form["#inputNamePrefix#_category_type"]) NEQ "">
			#trim(form["#inputNamePrefix#_category_type"])#,
			</cfif>
			<cfif structKeyExists(form,"#inputNamePrefix#_package_type") AND trim(form["#inputNamePrefix#_package_type"]) NEQ "">
			#trim(form["#inputNamePrefix#_package_type"])#,
			</cfif>
			<cfif structKeyExists(form,"#inputNamePrefix#_shared")>
				#form["#inputNamePrefix#_shared"]#,
				<cfelse>
				0,
			</cfif>
			<cfif structKeyExists(form,"#inputNamePrefix#_Incremental")>
				#form["#inputNamePrefix#_Incremental"]#
			<cfelse>
				0
			</cfif>
			<cfif structKeyExists(form,"#inputNamePrefix#_Specd")>
				,#form["#inputNamePrefix#_Specd"]#
			<cfelse>
				,0
			</cfif>
			<cfif #structKeyExists(form,"#inputNamePrefix#_won_lost")# AND (#form["#inputNamePrefix#_won_lost"]# EQ 1)>
				<cfif #structKeyExists(form,"#inputNamePrefix#_client_won")#>
						,'#form["#inputNamePrefix#_client_won"]#'
				 </cfif>
				 <cfif #structKeyExists(form,"#inputNamePrefix#_client_won_rate")#>
						,#form["#inputNamePrefix#_client_won_rate"]#
				 </cfif>
				 <cfif #structKeyExists(form,"#inputNamePrefix#_client_won_uom")#>
						,#form["#inputNamePrefix#_client_won_uom"]#
				 </cfif>
				 <cfif #structKeyExists(form,"#inputNamePrefix#_client_won_delivery_type")#>
						,#form["#inputNamePrefix#_client_won_delivery_type"]#
				 </cfif>
			</cfif>
			<cfif  (#structKeyExists(form,"#inputNamePrefix#_line_number")# and form["#inputNamePrefix#_line_number"] NEQ "")>
				,'#form["#inputNamePrefix#_line_number"]#'
			</cfif>		
			,getdate()
			,'#request.accessstructure.User_ID#'
			)
	   </cfquery>  
			
<cfif (#structKeyExists(form,"#inputNamePrefix#_cases")#) AND (#structKeyExists(form,"#inputNamePrefix#_rate")#)>
<cfset till = #MAX(listlen(form["#inputNamePrefix#_company"]), listlen(form["#inputNamePrefix#_rate"]))#>
<cfelse>
<cfset till = 0>
</cfif>

<cfif #structKeyExists(form,"#inputNamePrefix#_cases")#>
<cfset till = #MAX(till, listlen(form["#inputNamePrefix#_cases"]))#>
</cfif>

<cfif #structKeyExists(form,"#inputNamePrefix#_delivery_type")#>
<cfset till = #MAX(till, listlen(form["#inputNamePrefix#_delivery_type"]))#>
</cfif>


<cfif #structKeyExists(form,"#inputNamePrefix#_cases")# AND listlen(form["#inputNamePrefix#_cases"]) LT till>
	<cfset diff = till - #listlen(form["#inputNamePrefix#_cases"])#>
	<cfloop from="1" to="#diff#" index="miss">
	<cfset form["#inputNamePrefix#_cases"] = #ListAppend(form["#inputNamePrefix#_cases"], "0")#>
	</cfloop> 
</cfif>

<cfif #structKeyExists(form,"#inputNamePrefix#_company")# AND listlen(form["#inputNamePrefix#_company"]) LT till>
	<cfset diff = till - #listlen(form["#inputNamePrefix#_company"])#>
	<cfloop from="1" to="#diff#" index="miss">
	<cfset form["#inputNamePrefix#_company"] = #ListAppend(form["#inputNamePrefix#_company"], "0")#>
	</cfloop> 
</cfif>

<cfif #structKeyExists(form,"#inputNamePrefix#_rate")# AND listlen(form["#inputNamePrefix#_rate"]) LT till>
	<cfset diff = till - #listlen(form["#inputNamePrefix#_rate"])#>
	<cfloop from="1" to="#diff#" index="miss">
	<cfset form["#inputNamePrefix#_rate"] = #ListAppend(form["#inputNamePrefix#_rate"], "0")#>
	</cfloop> 
</cfif>

<cfif #structKeyExists(form,"#inputNamePrefix#_delivery_type")# AND listlen(form["#inputNamePrefix#_delivery_type"]) LT till>
	<cfset diff = till - #listlen(form["#inputNamePrefix#_delivery_type"])#>
	<cfloop from="1" to="#diff#" index="miss">
	<cfset form["#inputNamePrefix#_delivery_type"] = #ListAppend(form["#inputNamePrefix#_delivery_type"], "0")#>
	</cfloop> 
</cfif>

                       <!--- Checks if there are records in Program  Competitive Data START --->
						<cfquery name="check_PCD" datasource="#application.datasource#">
						SELECT * FROM Program_Competitive_Data WHERE program_id = #trim(FORM.Contract_Main_ID)#  AND product_ID = <cfqueryparam value='#trim(items_info.BSA_FOODSERVICE_ITEMS_MASTER_ID)#' cfsqltype="CF_SQL_VARCHAR" > 
						</cfquery>
						<!--- Checks if there are records in Program  Competitive Data END --->
						
						<!--- DELETE if there are records in Program  Competitive Data START --->
						<cfif #check_PCD.recordcount# GT 0>
						<cfquery name="Delete_PCD" datasource="#application.datasource#">
						DELETE FROM Program_Competitive_Data WHERE program_id = #trim(FORM.Contract_Main_ID)# AND product_ID = <cfqueryparam value='#trim(items_info.BSA_FOODSERVICE_ITEMS_MASTER_ID)#' cfsqltype="CF_SQL_VARCHAR" >
						</cfquery>
						</cfif>
						<!--- DELETE if there are records in Program  Competitive Data START --->



					<cfloop from="1" to="#till#" index="A">


<!---<cfset lost_check = 0>	
<cfif (#form["#inputNamePrefix#_won_lost"]# EQ 1) AND (#structKeyExists(form,"#inputNamePrefix#_shared")# EQ 'NO')>
	<cfset lost_check = 1>	
</cfif>		

<cfif NOT lost_check>	
D34685
REGULAR Apply should save the additional won by even if the Shared button is set to No
--->
	
		<cfif (#listGetAt(form["#inputNamePrefix#_company"], A)# EQ 0)  AND (#listGetAt(form["#inputNamePrefix#_rate"], A)# EQ 0) 
		      AND (#listGetAt(form["#inputNamePrefix#_cases"], A)# EQ 0) AND (#listGetAt(form["#inputNamePrefix#_delivery_type"], A)# EQ 0)>
		<!---<cfoutput>#trim(items_info.item)#---#structKeyExists(form,"#inputNamePrefix#_delivery_type")#</cfoutput>--->
		<cfelse>
								
								
					
											<cfquery name="Insert_program_Competitive_Data" datasource="#application.datasource#">
											INSERT INTO Program_Competitive_Data(
											Program_ID, 
											Product_ID,
											Program_Bid_Won_By_ID,
											Won_Price,
											Won_Uom,
											Won_Delivery_Type
											)
											Values(
											#trim(FORM.Contract_Main_ID)#, 
										   '#trim(items_info.BSA_FOODSERVICE_ITEMS_MASTER_ID)#',
		                                    #trim(listGetAt(form["#inputNamePrefix#_company"], A))#,
		                                    '#NumericValue(trim(listGetAt(form["#inputNamePrefix#_rate"], A)))#',
		                                    #trim(listGetAt(form["#inputNamePrefix#_cases"], A))#,
											#trim(listGetAt(form["#inputNamePrefix#_delivery_type"], A))#
											)
											</cfquery> 
		</cfif> 									

<!---</cfif>--->
					</cfloop>

	</cfif>	

</cfloop>
	
	
</cfif> 
<!--- This IF Determines if we are applying MASS APPLY or by ITEM  END --->
</cfoutput> 

<cfquery name="pull_won_lost" datasource="#application.datasource#">
		SELECT DISTINCT Program_Product_Bid_Info.won
		FROM Contract_Products
		LEFT JOIN Program_Product_Bid_Info 
		ON	Program_Product_Bid_Info.Program_ID = Contract_Products.Contract_Main_ID
		AND	Program_Product_Bid_Info.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
		AND	Program_Product_Bid_Info.Deleted = 0
		where Contract_Products.Contract_Main_ID = <cfqueryparam value= "#trim(form.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER"> 
		AND Contract_Products.Deleted = 0
		AND	Contract_Products.Is_Group = 0
</cfquery>

<cfset status = 1/>
<cfif #pull_won_lost.recordcount# GT 1>
<cfset status = 3>
<cfelseif (#pull_won_lost.recordcount#) EQ 1 AND (#pull_won_lost.won# EQ 1)>
<cfset status = 2>
<cfelseif (#pull_won_lost.recordcount#) EQ 1 AND (#pull_won_lost.won# EQ 0)>
<cfset status = 4>
<cfelseif (#pull_won_lost.recordcount#) EQ 1 AND (#pull_won_lost.won# EQ "")>
<cfset status = 1>
</cfif>




<cfquery name="ApplyStatus" datasource="#application.datasource#">
			UPDATE	Program_Bid_Request
			SET 	Bid_Request_Status_ID = <cfqueryparam value= "#trim(status)#" cfsqltype="CF_SQL_INTEGER">, 
			     	Status_Changed_Date = getdate(),
					Status_Changed_By = '#request.accessstructure.User_ID#'
			WHERE	Deleted = 0
			AND		Program_ID = <cfqueryparam value= "#trim(form.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER">
</cfquery>

<!--- SET BID STATUS FOR GROUP RECORDS --->
<cfif (unique_item_group NEQ "") >
	
		<cfquery name="update_won_lost_group_level" datasource="#application.datasource#">
if object_id('tempdb..##tmp_group_won_lost') is not null
drop table ##tmp_group_won_lost
                  
SELECT		Contract_Products.contract_main_id,
			Contract_Products.Product_Group_ID,
			nullif(Program_Product_Bid_Info.won, 2) as won <!--- 2 is pending and NULL(no entry in Program_Product_Bid_Info) is also pending --->
into  ##tmp_group_won_lost
FROM        Contract_Products 
INNER JOIN Contract_Products MemeberCP ON
            MemeberCP.Contract_Main_ID = Contract_Products.Contract_Main_ID
AND         MemeberCP.Product_Group_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
AND         MemeberCP.Captured_From_Group = 1
AND         MemeberCP.Deleted = 0
LEFT JOIN Program_Product_Bid_Info ON 
            Contract_Products.contract_main_id = Program_Product_Bid_Info.Program_ID AND MemeberCP.BSA_Foodservice_Items_Master_id = Program_Product_Bid_Info.Product_ID
            AND Program_Product_Bid_Info.Deleted = 0
WHERE       Contract_Products.contract_main_id = <cfqueryparam value= '#trim(form.Contract_Main_ID)#' cfsqltype="CF_SQL_INTEGER">
AND         Contract_Products.Deleted = 0
AND         Contract_Products.Is_Group = 1
<cfif (unique_item_group NEQ "-1")>
AND         Contract_Products.Product_Group_ID IN (<cfqueryparam value='#trim(unique_item_group)#' cfsqltype="CF_SQL_VARCHAR" list="yes">)
</cfif>

-- any product pending = group status is pending
-- all products won = group status is won
-- all products lost = group status is lost
-- products won and lost combination = group status is split


if object_id('tempdb..##tmp_group_won_lost_status') is not null
drop table ##tmp_group_won_lost_status

select      contract_main_id, Product_Group_ID, 
            sum(case when won is null then 1 else 0 end) as pending,
            sum(won) as won,
            sum(case won when 1 then 0 else 1 end) as lost,
            count(*) as total_count
into ##tmp_group_won_lost_status
from  ##tmp_group_won_lost
Group by contract_main_id, Product_Group_ID

INSERT INTO [History_Program_Product_Bid_Info]
           ([Program_Product_Bid_Info_ID]
           ,[Program_ID]
           ,[Product_ID]
           ,[Won]
           ,[Won_By]
           ,[Won_Price]
           ,[Won_Uom]
           ,[Deleted]
           ,[Created_Date]
           ,[Won_Delivery_Type]
           ,[Program_Bid_Won_By_ID]
           ,[Program_Bid_Category_ID]
           ,[Program_Bid_Package_ID]
           ,[Shared]
           ,[Incremental]
           ,[Line_Number]
           ,[Specd]
           ,[Updated_Date]
           ,[Updated_By])
SELECT [Program_Product_Bid_Info_ID]
           ,[Program_ID]
           ,[Product_ID]
           ,[Won]
           ,[Won_By]
           ,[Won_Price]
           ,[Won_Uom]
           ,[Deleted]
           ,[Created_Date]
           ,[Won_Delivery_Type]
           ,[Program_Bid_Won_By_ID]
           ,[Program_Bid_Category_ID]
           ,[Program_Bid_Package_ID]
           ,[Shared]
           ,[Incremental]
           ,[Line_Number]
           ,[Specd]
           ,[Updated_Date]
           ,[Updated_By]
FROM Program_Product_Bid_Info
WHERE Program_ID = <cfqueryparam value= '#trim(form.Contract_Main_ID)#' cfsqltype="CF_SQL_INTEGER">
AND product_ID  IN (SELECT Product_Group_ID FROM ##tmp_group_won_lost_status)

UPDATE Program_Product_Bid_Info
SET Deleted = 1
WHERE Program_ID = <cfqueryparam value= '#trim(form.Contract_Main_ID)#' cfsqltype="CF_SQL_INTEGER">
AND product_ID  IN (SELECT Product_Group_ID FROM ##tmp_group_won_lost_status)

insert into Program_Product_Bid_Info (Program_ID, Product_ID, Won, Updated_Date, Updated_By)
select      contract_main_id, Product_Group_ID,
            case 
            when pending != 0 then NULL -- atleast one product is pending
            when won = total_count then 1 -- all products are flagged as won
            when lost = total_count then 0 -- all products are flagged as lost
            else 2 -- split
            end as bid_status
            ,getdate()
            ,'#request.accessstructure.User_ID#'
from  ##tmp_group_won_lost_status 

		</cfquery>
</cfif>
<cfset update = 0>
<cfif #trim(url.type)# EQ 'massapply'>
	<cfset page_number = 1>	
<cfelseif complete_info>
	<cfset page_number = #form.page_number# + 1>
<cfelse>
	<cfset page_number = #form.page_number#>
	<cfset update = 1>
</cfif>

	<cflocation url="competitive_data.cfm?CID=#cryp.value#&page_number=#trim(page_number)#&update=#update#">

<cffunction name="NumericValue" output="false" hint="I return the numeric value of a string.">
  <cfargument name="numericString" required="true" hint="I am the numeric string.">
  <cfset arguments.numericString = Replace(arguments.numericString, '$', '', 'all')>
  <cfset arguments.numericString = Replace(arguments.numericString, ',', '', 'all')>

  <cfif Len(Trim( arguments.numericString )) eq 0>
    <cfreturn 0>
  <cfelseif IsNumeric( arguments.numericString )>
    <cfreturn arguments.numericString>
  <cfelse>
    <cfreturn 0>
  </cfif>
</cffunction>