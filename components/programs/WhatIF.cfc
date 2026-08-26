<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\programs\WhatIF.cfc
	Date:      2014 October
	Author:    Chris Nguyen

	Purposes:  Houses all functions to support what if

	Remarks:

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="What IF" output="false">

	<cffunction name="unLockAll" access="public" output="true" hint="Unlock all locked records based on user ID">
		<cfargument name="user_id" type="string" required="true">

		<cfquery name="local.whatif" datasource="#application.datasource#">
			UPDATE WhatIF
			   SET Locked_By = ''
			 WHERE Locked_By = '#arguments.user_id#'
		</cfquery>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="updateLock" access="public" returntype="string" output="true" hint="">
		<cfargument name="whatIf_ID" type="numeric" required="true"/>
		<cfargument name="action" type="string" required="true"/>

		<!--- attempt to lock a record so editing can be done --->
		<cfif arguments.action eq 'edit'>
			<cfquery name="local.whatif" datasource="#application.datasource#">
				SELECT a.*
		              ,e.name_first + ' ' + e.name_last as Editor
				  FROM WHATIF a
				  		LEFT JOIN _USERS e ON a.locked_by = e.user_id
				 WHERE whatIf_ID = #arguments.whatIf_ID#
			</cfquery>

			<cfif local.whatif.locked_by eq "" or local.whatif.locked_by eq request.AccessStructure.User_ID>
				<cfquery name="local.whatif" datasource="#application.datasource#">
					UPDATE WhatIF
					   SET  Modified_Date = getDate()
					       ,Modified_By   = '#request.AccessStructure.User_ID#'
					       ,Locked_By     = '#request.AccessStructure.User_ID#'
					 WHERE whatIf_ID = #arguments.whatIf_ID#
				</cfquery>
			<cfelse>
				<!--- <cfreturn "Edit is currently not allowed, the selected record is locked by #local.whatif.Editor#."> --->
				<cfreturn "The selected what if p&l is currently being locked by <b>#local.whatif.Editor#</b>">
			</cfif>

		<!--- attempt to release a lock on a record --->
		<cfelseif arguments.action eq 'readonly' or arguments.action eq 'unlock'>
			<cfquery name="local.whatif" datasource="#application.datasource#">
				UPDATE WhatIF
				   SET Locked_By = ''
				 WHERE whatIf_ID = #arguments.whatIf_ID#
			</cfquery>
		</cfif>   <!---  arguments.action eq 'edit'> --->

		<!--- blank string = SUCCESS indicator --->
		<cfreturn "">
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getWhatIf" access="public" returntype="query" output="false" hint="">
		<cfargument name="search" type="string" required="false" default=""/>

		<cfquery name="local.result" datasource="#application.datasource#">
		  <!--- for performance reason get the LATEST 1,000 rows for an individual and 2,000 rows for a group --->
		  <!--- if more is needed we would have to switch to use ajax method --->
		  SELECT TOP <cfif arguments.search eq 'all'> 2000 <cfelse> 1000 </cfif>
		          a.*
		         ,Distributor_Name = b.Name
		         ,b.shr_ship_to
		         ,c.name_first + ' ' + c.name_last as Creator
		         ,d.name_first + ' ' + d.name_last as Modifier
		         ,e.name_first + ' ' + e.name_last as Editor
		    FROM WHATIF a
		    	 INNER JOIN BSA_Foodservice_Customers b ON a.shr_ship_to = b.shr_ship_to
		    	 INNER JOIN _USERS c ON a.created_by = c.user_id
		    	 LEFT JOIN _USERS d ON a.modified_by = d.user_id
		    	 LEFT JOIN _USERS e ON a.locked_by = e.user_id
		   WHERE a.Deleted = 0
		   		 <cfif arguments.search eq 'all'>
		   		    AND 1 = 1
		   		 <!--- search value is numeric find the row by ID --->
		   		 <cfelseif isNumeric( arguments.search )>
		   		 	AND a.whatIf_ID = #arguments.search#
		   		 <!--- default to search for all rows belong to logged in user --->
		   		 <cfelseif arguments.search eq ''>
		     		AND a.Created_By = '#request.AccessStructure.User_ID#'
		     	 <cfelse>
		     		AND a.Created_By = '#arguments.search#'
				 </cfif>
				 ORDER BY Created_Date DESC
		</cfquery>

		<cfreturn local.result>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getCreators" access="public" returntype="query" output="false" hint="">
		<cfargument name="search" type="string" required="false" default=""/>

		<cfquery name="local.result" datasource="#application.datasource#">
		  SELECT DISTINCT
		         c.name_first + ' ' + c.name_last as Full_Name
		        ,a.created_by
		    FROM WHATIF a
		    	 INNER JOIN _USERS c ON a.created_by = c.user_id
		   WHERE a.Deleted = 0
		   ORDER BY c.name_first + ' ' + c.name_last
		</cfquery>

		<cfreturn local.result>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getWhatIfProduct" access="public" returntype="query" output="false" hint="">
		<cfargument name="whatIf_ID" type="numeric" required="true"/>

		<cfquery name="local.result" datasource="#application.datasource#">
			DECLARE @margin_type INT
			       ,@uom_lbs INT = 3

			SELECT @margin_type = wi.margin_type
			  FROM WHATIF wi
			 WHERE wi.whatIf_ID = #arguments.whatIf_ID#

			SELECT wi.*
			       ,i.Item
			       ,i.Description
			       <!--- calculate various costs based on selected UOM --->
			       ,System_Raw_Material = CASE
			       							WHEN @margin_type = @uom_lbs THEN System_Raw_Material_CS / i.net_weight
			       							ELSE System_Raw_Material_CS
			       						  END
			       ,System_Packaging    = CASE
			       							WHEN @margin_type = @uom_lbs THEN System_Packaging_CS / i.net_weight
			       							ELSE System_Packaging_CS
			       						  END
			       ,System_DVL          = CASE
			       							WHEN @margin_type = @uom_lbs THEN System_DVL_CS / i.net_weight
			       							ELSE System_DVL_CS
			       						  END
			       ,System_Fixed_Cost   = CASE
			       							WHEN @margin_type = @uom_lbs THEN System_Fixed_Cost_CS / i.net_weight
			       							ELSE System_Fixed_Cost_CS
			       						  END
			       ,System_DNT          = CASE
			       							WHEN @margin_type = @uom_lbs THEN System_DNT_CS / i.net_weight
			       							ELSE System_DNT_CS
			       						  END
			       ,System_Equip_CEMA   = CASE
			       							WHEN @margin_type = @uom_lbs THEN System_Equip_CEMA_CS / i.net_weight
			       							ELSE System_Equip_CEMA_CS
			       						  END
			       ,System_Comp_Cost    = CASE
			       							WHEN @margin_type = @uom_lbs THEN System_Comp_Cost_CS / i.net_weight
			       							ELSE System_Comp_Cost_CS
			       						  END
			       ,System_Cost         = CASE
			       							WHEN @margin_type = @uom_lbs THEN System_Cost_CS / i.net_weight
			       							ELSE System_Cost_CS
			       						  END
			   	   ,IsNull( Group_Id_Approval, 0 )                AS Group_Id_Approval
			  FROM WhatIf_Product wi
			       	INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER i ON i.BSA_Foodservice_Items_Master_ID = wi.BSA_Foodservice_Items_Master_ID
					INNER JOIN Type_Code_desc ON Type_Code_desc.Type_Code_desc_Id = i.Type_Code_desc_Id
       				LEFT JOIN Group_Approval_Rights ON Group_Approval_Rights.Group_Id = Type_Code_desc.Type_Code_desc_Id
					                                          AND Group_Approval_Rights.User_Profile_Id = #request.Accessstructure.Profiles_ID#
					                                          AND Group_Approval_Rights.Deleted = 0
			 WHERE wi.Deleted = 0
					 AND WhatIf_Id = #arguments.whatIf_ID#
					 ORDER BY i.Item
		</cfquery>

		<cfreturn local.result>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="saveDistributor" access="public" output="true" hint="">

		<cfset useLakebaseForlocal_save = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("whatif")>
<cfif useLakebaseForlocal_save>
	<cftry>
		<cfset application.oLakebase.updateRows("whatif",
			{
				"whatif_id" = "eq.#form.id#"
			},
			{
				"modified_date" = "#now()#",
				"modified_by" = "#request.AccessStructure.User_ID#",
				"shr_ship_to" = "#form.distributor#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_save = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_save>
<cfquery name="local.save" datasource="#application.datasource#">
			UPDATE WhatIF
			   SET  Modified_Date = getDate()
			       ,Modified_By   = '#request.AccessStructure.User_ID#'
			       ,shr_ship_to   = '#form.distributor#'
			 WHERE WhatIf_Id = #form.id#
		</cfquery>
</cfif>

		<cfset resetWhatIf( form.id )>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="resetWhatIf" access="public" output="true" hint="">
		<cfargument name="whatIf_ID" type="numeric" required="true"/>

		<cfquery name="local.save" datasource="#application.datasource#">
			UPDATE WhatIF
			   SET  Modified_Date = getDate()
			       ,Margin_Type   = 1
			       ,Modified_By   = '#request.AccessStructure.User_ID#'
			 WHERE WhatIf_Id = #arguments.whatIf_ID#

			 SELECT shr_ship_to
			   FROM WhatIF
			  WHERE WhatIf_Id = #arguments.whatIf_ID#
		</cfquery>

		<cfset local.shr_ship_to    = local.save.shr_ship_to>
		<cfset local.whatIF_product = getWhatIfProduct(arguments.whatIf_ID)>

		<cfloop query="local.whatIF_product">
			<cfquery name="local.save" datasource="#application.datasource#" result="local.result">
				<cfset local.item = local.whatIF_product.BSA_Foodservice_Items_Master_ID>

				<!---  get/calculate system values for price, cost, tpa, ... --->
				<cfinclude template="\components\programs\whatIF_System.cfm">

				UPDATE WhatIF_Product
  				   SET Deleted = 0
						,System_Raw_Material_CS = @raw_material
						,System_Packaging_CS    = @packaging
						,System_DVL_CS          = @dvl
						,System_Fixed_Cost_CS   = @fixed_cost
						,System_DNT_CS          = @dnt
						,System_Equip_CEMA_CS   = @equip_cema
						,System_Comp_Cost_CS    = @component_cost

						,System_Cost_CS         = @cost
						,System_Opr_Income      = @opr_income
						,System_Opr_Margin      = @opr_margin
						,System_List_Price      = @list_price
						,System_Net_Sales       = @net_sales
						,System_Net_Weight      = @net_weight
						,System_trade           = @tpa
						,System_Cash_Disc       = @cash_discount

						,User_List_Price        = @list_price
						,User_Net_Sales         = @net_sales
						,User_trade             = @tpa
						,User_Raw_Material      = @raw_material
						,User_Packaging         = @packaging
						,User_DVL               = @dvl
						,User_Fixed_Cost        = @fixed_cost

						,User_DNT               = @dnt
						,User_Equip_CEMA        = @equip_cema
						,User_Comp_Cost         = @component_cost
						,User_Cost              = @cost
						,User_Opr_Income        = @opr_income
						,User_Opr_Margin        = @opr_margin

						,User_Trade_Other_Allowances = 0
						,User_Trade_Cash_Disc        = 0
						,User_Distributor_Trade      = 0

						,User_Cash_Disc              = 0
				 WHERE whatIf_ID = #arguments.whatIf_ID#
			       AND BSA_Foodservice_Items_Master_ID = '#local.item#'
			</cfquery>
		</cfloop>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="saveWhatIf" access="public" output="true" hint="">

		<!--- trim extra characters to fit db schema --->
		<cfset form.title       = left(form.title, 50)>
		<cfset form.description = left(form.description, 500)>

		<cftransaction>
			<cfquery name="local.save" datasource="#application.datasource#">
				<cfif form.whatIf_ID eq '0'>
					INSERT INTO WHATIF
						           ( Title
						             ,Description
						             ,shr_Ship_To
						             ,margin_type
						             ,Locked_by
						             ,Created_by )
						     VALUES
						           ( '#form.title#'
						             ,'#form.description#'
						             ,(SELECT TOP 1 shr_Ship_To FROM BSA_Foodservice_Customers WHERE name = 'Sysco Chicago')
						             ,1
						             ,'#request.AccessStructure.User_ID#'
						             ,'#request.AccessStructure.User_ID#' )
					SELECT Scope_Identity() AS whatIf_ID
				<cfelse>
					UPDATE WhatIF
					   SET Title          = '#form.title#'
					       ,Description   = '#form.description#'
					       ,Modified_Date = getDate()
					       ,Modified_By   = '#request.AccessStructure.User_ID#'
					       ,Locked_By     = '#request.AccessStructure.User_ID#'
					       <cfif structKeyExists(form, "whatif_notes")>
					       		,Notes = '#left(form.whatif_notes, 1000)#'
						   </cfif>
					 WHERE WhatIf_Id = #form.whatIf_ID#
				</cfif>   <!--- form.whatIf_ID eq '0'> --->
			</cfquery>

			<cfif form.whatIf_ID eq '0'>
				<cfset local.is_new   = true>
				<cfset form.whatIf_ID = local.save.whatIf_ID>
			<cfelse>
				<cfset local.is_new = false>
			</cfif>

			<!--- pull back selected shr_ship_to --->
			<cfquery name="local.find" datasource="#application.datasource#">
				SELECT shr_Ship_To
				  FROM WhatIF
				 WHERE whatIf_ID = #form.whatIf_ID#
			</cfquery>
			<cfset local.shr_ship_to = local.find.shr_ship_to>

			<!--- mark existing products that are no longer selected --->
			<cfif not local.is_new>
				<cfquery name="local.delete" datasource="#application.datasource#">
					UPDATE WhatIF_Product
					   SET Deleted = 1
					 WHERE whatIf_ID = #form.whatIf_ID#
					       AND NOT BSA_Foodservice_Items_Master_ID IN (<cfqueryparam list="true" value="#form.products#">)
				</cfquery>
			</cfif>

			<cfloop list="#form.products#" index="local.item">
				<!--- detect if product exists --->
				<cfquery name="local.find" datasource="#application.datasource#">
					SELECT 1
					  FROM WhatIF_Product
					 WHERE whatIf_ID = #form.whatIf_ID#
					       AND BSA_Foodservice_Items_Master_ID = '#local.item#'
				</cfquery>

				<cfif local.find.recordCount gt 0>
					<cfquery name="local.update" datasource="#application.datasource#">
						UPDATE WhatIF_Product
						   SET Deleted = 0
						 WHERE whatIf_ID = #form.whatIf_ID#
					       AND BSA_Foodservice_Items_Master_ID = '#local.item#'
					</cfquery>
				<cfelse>
					<cfquery name="local.insert" datasource="#application.datasource#">
						<!--- get system values --->
						<cfinclude template="\components\programs\whatIF_System.cfm">

						INSERT WhatIF_Product
										( whatIf_ID
										 ,BSA_Foodservice_Items_Master_ID
										 ,System_Volume
										 ,User_Volume
										 ,System_List_Price
										 ,System_Net_Sales
										 ,System_Net_Weight
										 ,System_trade
										 ,System_Raw_Material_CS
										 ,System_Packaging_CS
										 ,System_DVL_CS
										 ,System_Fixed_Cost_CS
										 ,System_DNT_CS
										 ,System_Equip_CEMA_CS
										 ,System_Comp_Cost_CS
										 ,System_Cost_CS
										 ,System_Opr_Income
										 ,System_Opr_Margin
										 ,System_Cash_Disc

										 ,User_List_Price
										 ,User_Net_Sales
										 ,User_trade
										 ,User_Raw_Material
										 ,User_Packaging
										 ,User_DVL
										 ,User_Fixed_Cost
										 ,User_DNT
										 ,User_Equip_CEMA
										 ,User_Comp_Cost
										 ,User_Cost
										 ,User_Opr_Income
										 ,User_Opr_Margin
										)
								VALUES  ( #form.whatIF_ID#
									     ,'#local.item#'
									     ,1
									     ,1
									     ,@list_price
									     ,@net_sales
									     ,@net_weight
									     ,@tpa
										 ,@raw_material
										 ,@packaging
										 ,@dvl
										 ,@fixed_cost
										 ,@dnt
										 ,@equip_cema
										 ,@component_cost
										 ,@cost
										 ,@opr_income
										 ,@opr_margin
										 ,@cash_discount

									     ,@list_price
									     ,@net_sales
									     ,@tpa
										 ,@raw_material
										 ,@packaging
										 ,@dvl
										 ,@fixed_cost
										 ,@dnt
										 ,@equip_cema
										 ,@component_cost
										 ,@cost
										 ,@opr_income
										 ,@opr_margin
									    )
					</cfquery>
				</cfif>
			</cfloop>
		</cftransaction>

		<cfreturn form.whatIf_ID>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="whatIFvalue" access="public" output="true" hint="">
	    <cfargument name="val" required="true">

	    <cfset local.factor = 1>

	    <!--- special handling for negative value with parentheses format --->
	    <cfif arguments.val contains "(">
			<cfset local.factor = -1>
			<!--- remove parentheses --->
			<cfset arguments.val = replace(arguments.val, "(", "", "all")>
			<cfset arguments.val = replace(arguments.val, ")", "", "all")>
		</cfif>

	    <cfreturn local.factor * val(replace(replace(arguments.val, "$", "", "all"), ",", "", "all"))>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="saveWhatIfProduct" access="public" output="true" hint="">

		<cftransaction>
    		<cfloop from="1" to="#form.product_count#" index="local.index">
    			<cfquery name="local.save" datasource="#application.datasource#">
    				UPDATE WhatIF
    				   SET Margin_Type    = #form.margin_type#
					       ,Modified_Date = getDate()
					       ,Modified_By   = '#request.AccessStructure.User_ID#'
					       <cfif structKeyExists(form, "whatif_notes")>
					       		,Notes = '#left(form.whatif_notes, 1000)#'
						   </cfif>
    				 WHERE whatIf_ID = #form.ID#

					<!--- when cash discount is on these inputs do not exist --->
					<cfparam name="form.user_trade_other_allowances_#local.index#"  default="0">
					<cfparam name="form.user_trade_cash_disc_#local.index#"         default="0">

					<!--- when cash discount is off these inputs do not exist --->
					<cfparam name="form.user_cash_disc_#local.index#"               default="0">
					<cfparam name="form.user_raw_material_#local.index#"            default="0">

    				UPDATE WhatIf_Product
    				   SET    User_Volume           = #whatIFvalue(form["user_volume_"       & local.index ])#,
                              User_comp_Cost        = #whatIFvalue(form["user_comp_cost_"    & local.index ])#,
                              User_Cost             = #whatIFvalue(form["user_cost_"         & local.index ])#,
                              User_CSA              = #whatIFvalue(form["user_csa_"          & local.index ])#,
                              User_Discount         = #whatIFvalue(form["user_disc_"         & local.index ])#,
                              User_Discount_Percent = #whatIFvalue(form["user_disc_percent_" & local.index ])#,
                              User_dnt              = #whatIFvalue(form["user_dnt_"          & local.index ])#,
                              User_dvl              = #whatIFvalue(form["user_dvl_"          & local.index ])#,
                              User_Equip_CEMA       = #whatIFvalue(form["user_equip_"        & local.index ])#,
                              User_Fixed_Cost       = #whatIFvalue(form["user_fixed_cost_"   & local.index ])#,
                              User_Fixed_Price      = #whatIFvalue(form["user_fixed_price_"  & local.index ])#,
                              User_Growth_Discount  = #whatIFvalue(form["user_growth_"       & local.index ])#,
                              User_List_Price       = #whatIFvalue(form["user_list_price_"   & local.index ])#,
                              User_LS_Discount      = #whatIFvalue(form["user_ls_"           & local.index ])#,
                              User_Net_Sales        = #whatIFvalue(form["user_net_sales_"    & local.index ])#,
                              User_opr_Income       = #whatIFvalue(form["user_opr_income_"   & local.index ])#,
                              User_opr_Margin       = #whatIFvalue(form["user_opr_margin_"   & local.index ])#,
                              User_Packaging        = #whatIFvalue(form["user_packaging_"    & local.index ])#,
                              User_Raw_Material     = #whatIFvalue(form["user_raw_material_" & local.index ])#,
                              User_Rebate_Discount  = #whatIFvalue(form["user_rebate_"       & local.index ])#,

							  User_Trade_Other_Allowances = #whatIFvalue(form["user_trade_other_allowances_"  & local.index ])#,
							  User_Trade_Cash_Disc        = #whatIFvalue(form["user_trade_cash_disc_"         & local.index ])#,
							  User_Distributor_Trade      = #whatIFvalue(form["user_distributor_trade_"       & local.index ])#,

							  User_Cash_Disc              = #whatIFvalue(form["user_cash_disc_"               & local.index ])#
    				 WHERE whatIf_ID = #form.ID#
    				   AND BSA_Foodservice_Items_Master_ID = '#form["prod_id_" & local.index]#'
    			</cfquery>
    		</cfloop>  <!--- from="1" to="#form.product_count#"> --->
		</cftransaction>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="zapWhatIf" access="public" output="true" hint="Flags what if as deleted">
		<cfargument name="whatIf_ID" type="numeric" required="true"/>

		<cfquery name="local.save" datasource="#application.datasource#">
			UPDATE WhatIF
			   SET Deleted        = 1
			       ,Modified_Date = getDate()
			       ,Modified_By   = '#request.AccessStructure.User_ID#'
			 WHERE WhatIf_Id = #arguments.whatIf_ID#
		</cfquery>

	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="deleteWhatIfProduct" access="public" output="true" hint="Deletes a what if product">
		<cfargument name="whatIf_ID" type="numeric" required="true"/>
		<cfargument name="BSA_Foodservice_Items_Master_ID" type="string" required="true"/>

		<cfquery name="local.save" datasource="#application.datasource#">
			UPDATE WhatIF
			   SET  Modified_Date = getDate()
			       ,Modified_By   = '#request.AccessStructure.User_ID#'
			 WHERE WhatIf_Id = #arguments.whatIf_ID#

			UPDATE WhatIf_Product
			   SET Deleted = 1,
    			   User_Volume           = NULL,
                   User_comp_Cost        = NULL,
                   User_Cost             = NULL,
                   User_CSA              = NULL,
                   User_Discount         = NULL,
                   User_Discount_Percent = NULL,
                   User_dnt              = NULL,
                   User_dvl              = NULL,
                   User_Equip_CEMA       = NULL,
                   User_Fixed_Cost       = NULL,
                   User_Fixed_Price      = NULL,
                   User_Growth_Discount  = NULL,
                   User_List_Price       = NULL,
                   User_LS_Discount      = NULL,
                   User_Net_Sales        = NULL,
                   User_opr_Income       = NULL,
                   User_opr_Margin       = NULL,
                   User_Packaging        = NULL,
                   User_Raw_Material     = NULL,
                   User_Rebate_Discount  = NULL,
                   User_Trade            = NULL,
				   User_Trade_Other_Allowances = NULL,
				   User_Trade_Cash_Disc        = NULL,
				   User_Distributor_Trade      = NULL,
				   User_Cash_Disc              = NULL
			 WHERE WhatIf_Id = #arguments.whatIf_ID#
    			   AND BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
		</cfquery>

	</cffunction>

</cfcomponent>