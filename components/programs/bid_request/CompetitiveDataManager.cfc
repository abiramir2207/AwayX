<!---
FILENAME:   CompetitiveDataManager.cfc
CREATED:  	04/27/2011 - Tim Ford
--->

<cfcomponent displayname="CompetitiveDataManager" hint="Handles backend DB access for Competitive Data">

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getSources" output="false" returntype="query" hint="Returns a query of sources">
		<cfquery name="local.sources" datasource="#application.datasource#">
			SELECT Program_Bid_Source_Id
			       ,Program_Bid_Source_Code
			       ,Program_Bid_Source_Description
			  FROM PROGRAM_BID_SOURCE
			 WHERE Deleted = 0
			       AND Active = 1
			 ORDER BY Program_Bid_Source_Description
		</cfquery>
		<cfreturn local.sources>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getSourceTypes" output="false" returntype="query" hint="Returns a query of source types">
		<cfquery name="local.sourceTypes" datasource="#application.datasource#">
			SELECT Program_Bid_Source_Type_Id
			       ,Program_Bid_Source_Type_Code
			       ,Program_Bid_Source_Type_Description
			  FROM PROGRAM_BID_SOURCE_TYPE
			 WHERE Deleted = 0
			       AND Active = 1
			 ORDER BY Program_Bid_Source_Type_Description
		</cfquery>
		<cfreturn local.sourceTypes>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getPackages" output="false" returntype="query" hint="Returns a query of packages">
		<cfquery name="local.packages" datasource="#application.datasource#">
			SELECT Program_Bid_Package_Id
			       ,Program_Bid_Package_Code
			       ,Program_Bid_Package_Description
			  FROM PROGRAM_BID_PACKAGE
			 WHERE Deleted = 0
			       AND Active = 1
			 ORDER BY Program_Bid_Package_Description
		</cfquery>
		<cfreturn local.packages>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getCategories" output="false" returntype="query" hint="Returns a query of categories">
		<cfquery name="local.categories" datasource="#application.datasource#">
			SELECT Program_Bid_Category_Id
			       ,Program_Bid_Category_Code
			       ,Program_Bid_Category_Description
			  FROM PROGRAM_BID_CATEGORY
			 WHERE Deleted = 0
			       AND Active = 1
			 ORDER BY Program_Bid_Category_Description
		</cfquery>
		<cfreturn local.categories>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getCompetitors" output="false" returntype="query" hint="Returns a query of competitors">
		<cfquery name="local.competitors" datasource="#application.datasource#">
			 SELECT Program_Bid_Won_By_Id
			        ,Program_Bid_Won_By_Description
			    FROM PROGRAM_BID_WON_BY
			   WHERE Deleted = 0
			         AND Active = 1
			   ORDER BY Program_Bid_Won_By_Description
   	</cfquery>
		<cfreturn local.competitors>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getCompetitiveData" output="false" returntype="query" hint="Returns a query of competitive data">
		<cfargument name="contract_main_id" required="true" type="numeric">

		<cfquery name="local.competitiveData" datasource="#application.datasource#">
		  SELECT	Program_Competitive_Data.Product_Id,
		          	Program_Competitive_Data.Won_Price,
		          	Program_Competitive_Data.Won_Uom,
		          	Program_Competitive_Data.Won_Delivery_Type,
		          	Program_Bid_Won_By.Program_Bid_Won_By_ID,
		          	Program_Bid_Won_By.Program_Bid_Won_By_Code,
		          	Program_Bid_Won_By.Program_Bid_Won_By_Description,
					Program_Competitive_Data.Won,
					Program_Competitive_Data.Shared,
					Program_Competitive_Data.Incremental,
					Program_Competitive_Data.Specd,
					Program_Bid_Won_By.Is_Client
		    FROM 	Program_Competitive_Data
		    LEFT 	JOIN Program_Bid_Won_By ON
		          	Program_Bid_Won_By.Program_Bid_Won_By_ID = Program_Competitive_Data.Program_Bid_Won_By_ID
		   WHERE 	program_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.contract_main_id#">
   	</cfquery>

		<cfreturn local.competitiveData>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProductBidInfo" output="false" returntype="query" hint="Returns a query of product bid infos">
		<cfargument name="contract_main_id" required="true" type="numeric">

		<cfquery name="local.productBidInfo" datasource="#application.datasource#">
			SELECT	Program_Product_Bid_Info.*, Program_Bid_Won_By.Is_Client, Program_Bid_Won_By.Program_Bid_Won_By_Description
			FROM 	Program_Product_Bid_Info
					LEFT JOIN Program_Bid_Won_By ON
					Program_Bid_Won_By.Program_Bid_Won_By_ID = Program_Product_Bid_Info.Program_Bid_Won_By_ID
			WHERE 	program_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.contract_main_id#">
			AND 	Program_Product_Bid_Info.Deleted = 0

   	</cfquery>

		<cfreturn local.productBidInfo>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProductBidRequest" output="false" returntype="query" hint="Returns product bid request information">
		<cfargument name="contract_main_id" required="true" type="numeric">

		<cfreturn getProgramCompetitiveData( arguments.contract_main_id )>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getTemplateSettings" output="false" returntype="query" hint="Function returns tempate settings">
    <cfargument name="programID" required="true" type="numeric">

		<cfquery name="local.templateSettings" datasource="#application.datasource#">
			SELECT pcpo.Won_By
				       ,pcpo.Won_Rate
				       ,pcpo.Won_uom
				       ,pcpo.Delivery_Type
				       ,pcpo.Category
				       ,pcpo.Package
				       ,pcpo.Shared
				       ,pcpo.Incremental
				       ,pcpo.specd
				       ,pcpo.Source
				       ,pcpo.Source_Type
				       ,pcpo.Date_Source_Received
				       ,pcpo.DownLoad_comp_Data_History
				       ,pcpo.Display_Reminder_comp_Data_Page
				       ,pcpo.Opportunity_Volume
			  FROM CONTRACT_MAIN cm
			  INNER JOIN PROGRAM_CONTROL_PANEL_OPTIONS pcpo ON cm.ProgramType_Id = pcpo.ProgramControl_Panel_Options_Id
			 WHERE cm.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#trim(arguments.ProgramId)#">
		</cfquery>

		<cfreturn local.templateSettings />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProgramCompetitiveData" output="false" returntype="query" hint="function to return program competitive data">
		<cfargument name="programID" required="true" type="numeric">

		<cfquery name="local.programBidRequest" datasource="#application.datasource#">
			SELECT	Program_Bid_Source.Program_Bid_Source_ID,
							Program_Bid_Source.Program_Bid_Source_Code,
							Program_Bid_Source.Program_Bid_Source_Description,
							Program_Bid_Source_Type.Program_Bid_Source_Type_ID,
							Program_Bid_Source_Type.Program_Bid_Source_Type_Code,
							Program_Bid_Source_Type.Program_Bid_Source_Type_Description,
							Program_Bid_Request.Program_Bid_Source_Date
			FROM	Program_Bid_Request
					LEFT JOIN Program_Bid_Source ON Program_Bid_Source.Program_Bid_Source_ID = Program_Bid_Request.Program_Bid_Source_ID
					LEFT JOIN Program_Bid_Source_Type ON Program_Bid_Source_Type.Program_Bid_Source_Type_ID = Program_Bid_Request.Program_Bid_Source_Type_ID
			WHERE	Program_Bid_Request.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#">
			  AND	Program_Bid_Request.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
		</cfquery>

		<cfreturn local.programBidRequest/>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProducts" output="false" returntype="query" hint="Returns all products in a program">
		<cfargument name="programID" required="true" type="numeric">

		<cfquery name="local.allProducts" datasource="#application.datasource#">
			SELECT Distinct BSA_FOODSERVICE_ITEMS_MASTER.Item
						,BSA_FOODSERVICE_ITEMS_MASTER.Description
						,BSA_FOODSERVICE_ITEMS_MASTER.bsa_FoodService_Items_Master_Id
						,CASE WHEN(Contract_Products.Product_Group_ID = '' OR Contract_Products.Product_Group_ID is NULL)
						THEN
							tc.Type_Code_desc
						ELSE
							All_Product_Group_Types.Group_Desc
						END AS group_desc
						,Contract_Products.Product_Group_ID
			FROM CONTRACT_PRODUCTS
			INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER
			ON BSA_FOODSERVICE_ITEMS_MASTER.bsa_FoodService_Items_Master_Id = CONTRACT_PRODUCTS.bsa_FoodService_Items_Master_Id
			LEFT JOIN TYPE_CODE_DESC tc
			ON tc.Type_Code_desc_Id = BSA_FOODSERVICE_ITEMS_MASTER.Type_Code_desc_Id
			LEFT JOIN All_Product_Group_Types
			ON CAST(All_Product_Group_Types.Group_GUID AS varchar(50)) = contract_products.Product_Group_ID
			WHERE CONTRACT_PRODUCTS.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#">
			AND CONTRACT_PRODUCTS.Deleted = 0
			AND CONTRACT_PRODUCTS.Is_Group = 0
		</cfquery>

		<cfreturn local.allProducts/>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="saveAllData" output="true" hint="Saves all competitive data: top level, level 2 (won, competitor, rate, uom, delivery, pkg, shared, etc..), level 3 (competitor, rate, uom)">
		<!-------------------------------------------------------------------------->
		<!--- save top level columns when at least one of the top columns exists --->
		<!-------------------------------------------------------------------------->
		<cfif structKeyExists(form, "source")
		   or structKeyExists(form, "source_type")
		   or structKeyExists(form, "date_source_received")>
	    	<cfquery name="local.query" datasource="#application.datasource#" result="local.result">
	      		UPDATE 	PROGRAM_BID_REQUEST
	         	SET 	Program_Bid_Source_ID      = <cfif not structKeyExists(form, "source")> Program_Bid_Source_ID <cfelseif form.source eq "" > NULL <cfelse> #form.source# </cfif>,
						Program_Bid_Source_Type_ID = <cfif not structKeyExists(form, "source_type")> Program_Bid_Source_Type_ID <cfelseif form.source_type eq ""> NULL <cfelse> #form.source_type# </cfif>,
						Program_Bid_Source_Date    = <cfif not structKeyExists(form, "date_source_received")> Program_Bid_Source_Date <cfelseif form.date_source_received eq ""> NULL <cfelse> '#form.date_source_received#' </cfif>
	       		WHERE 	Program_ID = #trim(FORM.Contract_Main_ID)#
	    	</cfquery>

			<cfif local.result.recordCount eq 0>
				<cfquery name="local.query" datasource="#application.datasource#">
					INSERT PROGRAM_BID_REQUEST
				  	(
						Program_ID,
						Program_Bid_Source_ID,
						Program_Bid_Source_Type_ID,
						Program_Bid_Source_Date
					)
					VALUES
					(
						#trim(FORM.Contract_Main_ID)#,
						<cfif not structKeyExists(form, "source")> NULL <cfelseif form.source eq "" > NULL <cfelse> #form.source# </cfif>,
						<cfif not structKeyExists(form, "source_type")> NULL <cfelseif form.source_type eq ""> NULL <cfelse> #form.source_type# </cfif>,
						<cfif not structKeyExists(form, "date_source_received")> NULL <cfelseif form.date_source_received eq ""> NULL <cfelse> '#form.date_source_received#' </cfif>
					)
				</cfquery>
			</cfif>
		</cfif>  <!--- structKeyExists(form, "source") or structKeyExists(form, "source_type") or structKeyExists(form, "date_source_received")> --->
		<!----------------------------------------------------------------------------------------->
		<!--- save 2nd level rows (won, rate, uom, delivery, pkg, shared, incr, spec, category) --->
		<!----------------------------------------------------------------------------------------->

		<!--- clear out existing rows for 3rd level entries --->
		<cfquery name="local.query" datasource="#application.datasource#">
			DELETE FROM Program_Competitive_Data WHERE program_id = #trim(FORM.Contract_Main_ID)#
		</cfquery>

		<cfloop from="1" to="#form.l2.item.recordCount#" index="local.counter">
			<cfscript>
				local.item            = {};
				// ATTENTION: establish the element prefix (defined in competitive_data.cfm around line 309) to get to other elements
				local.namePrefix      = "l2.item" & local.counter;
			</cfscript>

			<cfif structKeyExists(form, local.namePrefix & '.id')>
				<cfscript>
					local.item.productID  = form[ local.namePrefix & '.id'   ];
					local.item.competitor = form[ local.namePrefix & '.comp' ];

					// won was converted from a checkbox into a dropdown on 2014 may 28
					local.item.won        = form[ local.namePrefix & '.won'  ];
					local.item.rate       = form[ local.namePrefix & '.rate' ];
					local.item.uom        = form[ local.namePrefix & '.uom'  ];

					// optional columns based on program template settings
					local.item.delivery    = (structKeyExists(form, local.namePrefix & ".deli") ? form[ local.namePrefix & '.deli' ]  : '');
					local.item.shared      = (structKeyExists(form, local.namePrefix & ".shar") ? form[ local.namePrefix & '.shar'  ] : '');
					local.item.incremental = (structKeyExists(form, local.namePrefix & ".incr") ? form[ local.namePrefix & '.incr'  ] : '');
					local.item.specd       = (structKeyExists(form, local.namePrefix & ".spec") ? form[ local.namePrefix & '.spec'  ] : '');
					local.item.package     = (structKeyExists(form, local.namePrefix & ".pack") ? form[ local.namePrefix & '.pack' ]  : '');
					local.item.category    = (structKeyExists(form, local.namePrefix & ".cat")  ? form[ local.namePrefix & '.cat' ]   : '');
				</cfscript>

				<cfquery name="local.query" datasource="#application.datasource#">
					INSERT INTO HISTORY_PROGRAM_PRODUCT_BID_INFO
								([Program_Product_Bid_Info_Id]
								 ,[Program_Id]
								 ,[Product_Id]
								 ,[Won]
								 ,[Won_By]
								 ,[Won_Price]
								 ,[Won_uom]
								 ,[Deleted]
								 ,[Created_Date]
								 ,[Won_Delivery_Type]
								 ,[Program_Bid_Won_By_Id]
								 ,[Program_Bid_Category_Id]
								 ,[Program_Bid_Package_Id]
								 ,[Shared]
								 ,[Incremental]
								 ,[Line_Number]
								 ,[specd]
								 ,[Updated_Date]
								 ,[Updated_By]
								 ,[Updated_By_Billback_ID])
					SELECT [Program_Product_Bid_Info_Id]
						   ,[Program_Id]
						   ,[Product_Id]
						   ,[Won]
						   ,[Won_By]
						   ,[Won_Price]
						   ,[Won_uom]
						   ,[Deleted]
						   ,[Created_Date]
						   ,[Won_Delivery_Type]
						   ,[Program_Bid_Won_By_Id]
						   ,[Program_Bid_Category_Id]
						   ,[Program_Bid_Package_Id]
						   ,[Shared]
						   ,[Incremental]
						   ,[Line_Number]
						   ,[specd]
						   ,[Updated_Date]
						   ,[Updated_By]
						   ,[Updated_By_Billback_ID]
					FROM 	PROGRAM_PRODUCT_BID_INFO
			   		WHERE 	Program_ID = #trim(FORM.Contract_Main_ID)#
				 	AND 	Product_ID = '#local.item.productID#'

					UPDATE	PROGRAM_PRODUCT_BID_INFO
					SET 	Deleted = 1
					WHERE 	Program_ID = #trim(FORM.Contract_Main_ID)#
					AND 	Product_ID = '#local.item.productID#'

					INSERT PROGRAM_PRODUCT_BID_INFO
						  ( Program_ID
						   ,Product_ID
						   ,Won
						<!--- Tim Ford - Label 44526: All Bid data will pertain to the client so we will be storing it in the Program_Product_Bid_Info table
						and Competitor data will get stored in the Program_Competitive_Data table
						<cfif form[ local.namePrefix & '.comp' ] EQ #trim(application.returned_customer_setting.company_name)#>
						--->
						   ,Won_Price
						   ,Program_Bid_Won_By_Id
						   ,Won_UOM
						   ,Won_Delivery_Type
						   ,Won_By
						   ,Program_Bid_Package_ID
						   ,Shared
						   ,Incremental
						   ,Specd
						   ,Program_Bid_Category_ID
						  )
					VALUES ( #trim(FORM.Contract_Main_ID)#
							   ,'#local.item.productID#'
							   ,<cfif local.item.won eq 'won'> 1 <cfelseif local.item.won eq 'lost'> 0 <cfelse> NULL </cfif>
							   	<!--- Tim Ford - Label 44526: All Bid data will pertain to the client so we will be storing it in the Program_Product_Bid_Info table
								and Competitor data will get stored in the Program_Competitive_Data table
								<cfif  form[ local.namePrefix & '.comp' ] EQ #trim(application.returned_customer_setting.company_name)#>
								--->
							   ,#val(local.item.rate)#
							   ,#val(local.item.competitor)#
							   ,#val(local.item.uom)#
							   ,#val(local.item.delivery)#
							   ,'#this.getClientBidDesc()#'
							   ,#val(local.item.package)#
							   ,<cfif local.item.shared eq "on"> 1 <cfelse> 0 </cfif>
							   ,<cfif local.item.incremental eq "on"> 1 <cfelse> 0 </cfif>
							   ,<cfif local.item.specd eq "on"> 1 <cfelse> 0 </cfif>
							   ,#val(local.item.category)#
							 )
				</cfquery>

			<!--- Tim Ford - Label 44526: All Bid data will pertain to the client so we will be storing it in the Program_Product_Bid_Info table
						and Competitor data will get stored in the Program_Competitive_Data table
			<cfif local.item.competitor NEQ "" AND form[ local.namePrefix & '.comp' ] NEQ #trim(application.returned_customer_setting.company_name)#>
				<cfquery name="local.query" datasource="#application.datasource#">
					INSERT PROGRAM_COMPETITIVE_DATA(
						 Program_ID
						,Product_ID
						,Program_Bid_Won_By_ID
						,Won_Price
						,Won_Uom
						,Won_Delivery_Type
					)
					VALUES (
						  #trim(FORM.Contract_Main_ID)#
						,'#local.item.productID#'
						,#val(local.item.competitor)#
						,#val(local.item.rate)#
						,#val(local.item.uom)#
						,#val(local.item.delivery)#
					)
				</cfquery>
			</cfif>
			--->
			</cfif>   <!--- structKeyExists(form, local.namePrefix & '.id')> --->

		</cfloop>  <!--- from="1" to="#form.L2.item.recordCount#" index="local.counter"> --->
		<!--- end of save 2nd level rows (won, rate, uom, delivery, pkg, shared, incr, spec, category) --->

		<!--------------------------------------------------->
		<!--- save 3rd level rows (competitor, rate, uom, Shared, Incremental, Specd) --->
		<!--------------------------------------------------->

		<cfloop from="1" to="#form.l3.item.recordCount#" index="local.counter">
				<cfscript>
					local.item            = {};
					// ATTENTION: establish the element prefix (defined in competitive_data.cfm around line 388) to get to other elements
					local.namePrefix      = "l3.item" & local.counter;
				</cfscript>

				<cfif structKeyExists(form, local.namePrefix & '.id')>
					<cfscript>
						local.item.productID  = form[ local.namePrefix & '.id'   ];
						local.item.competitor = form[ local.namePrefix & '.comp' ];
						local.item.rate       = form[ local.namePrefix & '.rate' ];
						local.item.uom        = form[ local.namePrefix & '.uom'  ];
						local.item.won        = (structKeyExists(form, local.namePrefix & ".won") ? form[ local.namePrefix & '.won' ]  : '');
						local.item.deli        = (structKeyExists(form, local.namePrefix & ".deli") ? form[ local.namePrefix & '.deli' ]  : '');
						local.item.incr        = (structKeyExists(form, local.namePrefix & ".incr") ? form[ local.namePrefix & '.incr' ]  : '');
						local.item.spec        = (structKeyExists(form, local.namePrefix & ".spec") ? form[ local.namePrefix & '.spec' ]  : '');
						local.item.shar        = (structKeyExists(form, local.namePrefix & ".shar") ? form[ local.namePrefix & '.shar' ]  : '');
					</cfscript>

	    		<cfquery name="local.query" datasource="#application.datasource#">
	    			INSERT PROGRAM_COMPETITIVE_DATA
					(
						Program_ID,
						Product_ID,
						Program_Bid_Won_By_ID,
						Won_Price,
						Won_Uom,
						Won_Delivery_Type,
						Won,
						Incremental,
						Specd,
						Shared
					)
	    			VALUES
					(
						#trim(FORM.Contract_Main_ID)#,
						'#local.item.productID#',
						#val(local.item.competitor)#,
						#val(local.item.rate)#,
						#val(local.item.uom)#,
						#val(local.item.deli)#,
						<cfif local.item.won eq 'won'> 1 <cfelseif local.item.won eq 'lost'> 0 <cfelse> 2 </cfif>,
						<cfif local.item.incr eq "on"> 1 <cfelse> 0 </cfif>,
						<cfif local.item.spec eq "on"> 1 <cfelse> 0 </cfif>,
						<cfif local.item.shar eq "on"> 1 <cfelse> 0 </cfif>
	    			)
	    		</cfquery>

				</cfif>
		</cfloop>   <!--- from="1" to="#form.l3.item.recordCount#" index="local.counter"> --->
		<!--- end of save 3rd level rows (competitor, rate, uom) --->

		<cfquery name="update_won_lost_group_level" datasource="#application.datasource#">
			if object_id('tempdb..##tmp_group_won_lost') is not null
			drop table ##tmp_group_won_lost

			SELECT	Contract_Products.contract_main_id,
					Contract_Products.Product_Group_ID,
					nullif(Program_Product_Bid_Info.won, 2) as won,
					<!--- 2 is pending and NULL(no entry in Program_Product_Bid_Info) is also pending --->
					Program_Product_Bid_Info.Program_Bid_Won_By_ID
			into  	##tmp_group_won_lost
			FROM	Contract_Products
					INNER JOIN Contract_Products MemeberCP ON
					MemeberCP.Contract_Main_ID = Contract_Products.Contract_Main_ID
					AND MemeberCP.Product_Group_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					AND MemeberCP.Captured_From_Group = 1
					AND MemeberCP.Deleted = 0
					LEFT JOIN Program_Product_Bid_Info ON
					Contract_Products.contract_main_id = Program_Product_Bid_Info.Program_ID AND MemeberCP.BSA_Foodservice_Items_Master_id = Program_Product_Bid_Info.Product_ID
					AND Program_Product_Bid_Info.Deleted = 0
			WHERE	Contract_Products.contract_main_id = <cfqueryparam value= '#trim(form.Contract_Main_ID)#' cfsqltype="CF_SQL_INTEGER">
			AND		Contract_Products.Deleted = 0
			AND		Contract_Products.Is_Group = 1

			-- any product pending = group status is pending
			-- all products won = group status is won
			-- all products lost = group status is lost
			-- products won and lost combination = group status is split

			if object_id('tempdb..##tmp_group_won_lost_status') is not null
			drop table ##tmp_group_won_lost_status

			select	contract_main_id, Product_Group_ID,
					sum(case when won is null then 1 else 0 end) as pending,
					sum(won) as won,
					sum(case won when 1 then 0 else 1 end) as lost,
					max(Program_Bid_Won_By_ID) as Program_Bid_Won_By_ID,
					count(*) as total_count
			into 	##tmp_group_won_lost_status
			from	##tmp_group_won_lost
			Group by contract_main_id, Product_Group_ID

			INSERT INTO [History_Program_Product_Bid_Info]
			(
					[Program_Product_Bid_Info_ID],
					[Program_ID],
					[Product_ID],
					[Won],
					[Won_By],
					[Won_Price],
					[Won_Uom],
					[Deleted],
					[Created_Date],
					[Won_Delivery_Type],
					[Program_Bid_Won_By_ID],
					[Program_Bid_Category_ID],
					[Program_Bid_Package_ID],
					[Shared],
					[Incremental],
					[Line_Number],
					[Specd],
					[Updated_Date],
					[Updated_By],
					[Updated_By_Billback_ID]
			)
			SELECT	[Program_Product_Bid_Info_ID],
					[Program_ID],
					[Product_ID],
					[Won],
					[Won_By],
					[Won_Price],
					[Won_Uom],
					[Deleted],
					[Created_Date],
					[Won_Delivery_Type],
					[Program_Bid_Won_By_ID],
					[Program_Bid_Category_ID],
					[Program_Bid_Package_ID],
					[Shared],
					[Incremental],
					[Line_Number],
					[Specd],
					[Updated_Date],
					[Updated_By],
					[Updated_By_Billback_ID]
			FROM 	Program_Product_Bid_Info
			WHERE 	Program_ID = <cfqueryparam value= '#trim(form.Contract_Main_ID)#' cfsqltype="CF_SQL_INTEGER">
			AND 	Product_ID  IN (SELECT Product_Group_ID FROM ##tmp_group_won_lost_status)

			UPDATE	Program_Product_Bid_Info
			SET 	Deleted = 1
			WHERE 	Program_ID = <cfqueryparam value= '#trim(form.Contract_Main_ID)#' cfsqltype="CF_SQL_INTEGER">
			AND 	Product_ID  IN (SELECT Product_Group_ID FROM ##tmp_group_won_lost_status)

			insert into Program_Product_Bid_Info
			(
				Program_ID, Product_ID, Won, Updated_Date, Updated_By, Program_Bid_Won_By_ID
			)
			select 	contract_main_id, Product_Group_ID,
					case
						when pending != 0 then NULL -- atleast one product is pending
						when won = total_count then 1 -- all products are flagged as won
						when lost = total_count then 0 -- all products are flagged as lost
						else 2 -- split
					end as bid_status,
					getdate(),
					'#request.accessstructure.User_ID#',
					Program_Bid_Won_By_ID
			from  	##tmp_group_won_lost_status
		</cfquery>

		<cfset setBidProposalStatus (#trim(FORM.Contract_Main_ID)#)/>

	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProgramCompetitiveProductData" output="false" returntype="query" hint="function to return program competitive product data">

		<cfargument name="programID" required="true" type="numeric">
		<cfargument name="source" required="false" type="string" default="">
		<cfargument name="searchCriteria" required="false" type="string" default="">
		<cfargument name="sortColumnNumber" required="false" type="string" default="">
		<cfargument name="sortColumnOrder" required="false" type="string" default="">
		<cfargument name="startRow" required="false" type="numeric" default="-1">
		<cfargument name="endRow" required="false" type="numeric" default="-1">
		<cfargument name="itemList" required="false" type="string" default="">

		<cfscript>
			//set local variables
			var nProgramId	= "";
			var qGetData	= "";
			var qRetData	= "";

			//assign local variables
			nProgramId 			= arguments.programID;
		</cfscript>

		<cfquery name="local.allProducts" datasource="#application.datasource#">
			SET NOCOUNT ON

			if object_id('tempdb..##tmp_program_bid_product_info') is not null
			drop table ##tmp_program_bid_product_info

			if object_id('tempdb..##tmp_final_program_bid_product_info') is not null
			drop table ##tmp_final_program_bid_product_info

			if object_id('tempdb..##tmp_program_bid_product_group_info') is not null
			drop table ##tmp_program_bid_product_group_info

			if object_id('tempdb..##tmp_won_rate_data') is not null
			drop table ##tmp_won_rate_data

			DECLARE  @totalCount int,
				 @totalDisplayCount int

			SELECT	BFIM.BSA_Foodservice_Items_Master_ID,
					BFIM.Item,
					AVG(CAST(PFPPD.Fixed_Price_Value AS FLOAT)) AS Rate,
					PFPPD.Unit_Of_Measure_ID,
					UOM.Abbreviation_Singular,
					CP.Product_Type_ID AS Discount_Type_ID,
					CASE WHEN FCN.Fixed_Component_Type = 1 THEN 'Delivered' ELSE 'FOB' END AS Delivery_Type
			INTO  	##tmp_won_rate_data
			FROM	Program_Fixed_Price_Product_Data PFPPD
					INNER JOIN Units_Of_Measure UOM ON
					UOM.Unit_Of_Measure_ID = PFPPD.Unit_Of_Measure_ID
					INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID AND
					PFC.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
					INNER JOIN Program_Fixed_Component_Name FCN ON
					FCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
					INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = PFPPD.Contract_Products_ID AND
					CP.Contract_Main_ID = PFPPD.Program_ID AND
					CP.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0"> AND
					CP.Product_Type_ID = <cfqueryparam cfsqltype="CF_SQL_NUMERIC" value="1">
					INNER JOIN BSA_Foodservice_Items_Master BFIM ON
					BFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			WHERE	PFPPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nProgramId#">
			<!--- itemlist only --->
			<cfif itemList neq "">
			AND BFIM.BSA_Foodservice_Items_Master_ID IN (#listqualify(arguments.itemList, "'", ",")#)
			</cfif>
			AND		PFPPD.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			GROUP BY BFIM.BSA_Foodservice_Items_Master_ID, BFIM.Item, PFPPD.Unit_Of_Measure_ID, UOM.Abbreviation_Singular, CP.Product_Type_ID, FCN.Fixed_Component_Type

			INSERT INTO ##tmp_won_rate_data
			SELECT	BFIM.BSA_Foodservice_Items_Master_ID,
					BFIM.Item,
					SUM(CAST(PRCD.Rate AS FLOAT)) AS Rate,
					PRCD.Unit_Of_Measure_ID,
					UOM.Abbreviation_Singular,
					CP.Product_Type_ID AS Discount_Type_ID,
					CASE WHEN PRCN.Component_Type = 1 THEN 'Delivered' ELSE 'FOB' END AS Delivery_Type
			FROM	Program_Rebates_Component_Data PRCD
					INNER JOIN Program_Rebates_Product_Data PRPD ON
					PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID AND
					PRPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nProgramId#"> AND
					PRPD.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
					INNER JOIN Units_Of_Measure UOM ON
					UOM.Unit_Of_Measure_ID = PRCD.Unit_Of_Measure_ID
					INNER JOIN Program_Rebates_Component PRC ON
					PRC.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID AND
					PRC.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nProgramId#"> AND
					PRC.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
					INNER JOIN Program_Rebates_Component_Name PRCN ON
					PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
					INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = PRPD.Contract_Products_ID AND
					CP.Contract_Main_ID = PRPD.Program_ID AND
					CP.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0"> AND
					CP.Product_Type_ID = <cfqueryparam cfsqltype="CF_SQL_NUMERIC" value="2"> AND
					CP.Is_Group = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
					INNER JOIN BSA_Foodservice_Items_Master BFIM ON BFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			WHERE	PRCD.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			<!--- itemlist only --->
			<cfif itemList neq "">
			AND BFIM.BSA_Foodservice_Items_Master_ID IN (#listqualify(arguments.itemList, "'", ",")#)
			</cfif>
			AND		BFIM.BSA_Foodservice_Items_Master_ID NOT IN (SELECT DISTINCT BSA_Foodservice_Items_Master_ID FROM ##tmp_won_rate_data)
			GROUP BY BFIM.BSA_Foodservice_Items_Master_ID, BFIM.Item, PRCD.Unit_Of_Measure_ID, UOM.Abbreviation_Singular, CP.Product_Type_ID, PRCN.Component_Type

			SELECT	Program_Product_Bid_Info.Shared,
				    Program_Product_Bid_Info.won,
					Program_Product_Bid_Info.Incremental,
					Program_Product_Bid_Info.Specd,
					Program_Product_Bid_Info.Line_number,
					--Program_Product_Bid_Info.Won_by,
					--Program_Product_Bid_Info.Won_UOM,
					Program_Bid_Category.Program_Bid_Category_ID,
					Program_Bid_Category.Program_Bid_Category_Code,
					Program_Bid_Category.Program_Bid_Category_Description,
					Program_Bid_Package.Program_Bid_Package_ID,
					Program_Bid_Package.Program_Bid_Package_Code,
					Program_Bid_Package.Program_Bid_Package_Description,
					BSA_Foodservice_Items_Master.Item,
					BSA_Foodservice_Items_Master.Description,
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
					CASE WHEN(Contract_Products.Product_Group_ID = '' OR Contract_Products.Product_Group_ID is NULL)
					THEN
						tc.Type_Code_Desc_ID
					ELSE
						Contract_Products.Product_Group_ID
					END
					AS Product_Group_ID
			INTO  	##tmp_program_bid_product_info
			FROM  	Contract_Products LEFT JOIN Program_Product_Bid_Info ON
					Contract_Products.contract_main_id = Program_Product_Bid_Info.Program_ID AND Contract_Products.BSA_Foodservice_Items_Master_id = Program_Product_Bid_Info.Product_ID
					AND Program_Product_Bid_Info.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
					LEFT JOIN Program_Bid_Category ON
					Program_Bid_Category.Program_Bid_Category_ID = Program_Product_Bid_Info.Program_Bid_Category_ID
					LEFT JOIN Program_Bid_Package ON
					Program_Bid_Package.Program_Bid_Package_ID = Program_Product_Bid_Info.Program_Bid_Package_ID
					INNER JOIN BSA_Foodservice_Items_Master ON
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					LEFT JOIN Type_Code_Desc tc ON tc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
			WHERE 	Contract_Products.contract_main_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nProgramId#">
			<!--- itemlist only --->
			<cfif itemList neq "">
			AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN (#listqualify(arguments.itemList, "'", ",")#)
			</cfif>
			AND		Contract_Products.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		Contract_Products.Is_Group = <cfqueryparam cfsqltype="cf_sql_bit" value="0">

			SELECT	bidprod.Product_Group_ID, bidprod.BSA_Foodservice_Items_Master_ID,
					All_Product_Group_Types.Group_Number, All_Product_Group_Types.Group_Desc,
					1 AS Added_By_Group
			INTO  	##tmp_program_bid_product_group_info
			FROM  	##tmp_program_bid_product_info bidprod
					inner join contract_products on
					contract_products.contract_main_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nProgramId#"> AND
					CAST(contract_products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) = bidprod.Product_Group_ID AND
					contract_products.Deleted = 0 AND
					contract_products.Is_Group = 1
					inner join All_Product_Group_Types ON
					All_Product_Group_Types.Product_Group_Level_ID = contract_products.Product_Group_Level_ID AND
					All_Product_Group_Types.Group_GUID = contract_products.BSA_Foodservice_Items_Master_ID


		INSERT INTO ##tmp_program_bid_product_group_info
			SELECT	 bidprod.Product_Group_ID,
					bidprod.BSA_Foodservice_Items_Master_ID,
					tc.Type_code_Legacy AS Group_Number,
					tc.Type_Code_Desc AS Group_Desc,
					0
			FROM  	##tmp_program_bid_product_info bidprod
					inner join contract_products cp on
					cp.contract_main_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nProgramId#"> AND
					cp.Deleted = 0 AND (cp.Product_Group_ID = '' OR cp.Product_Group_ID is NULL)
					AND cp.Is_Group = 0
					and cp.BSA_Foodservice_Items_Master_ID = bidprod.BSA_Foodservice_Items_Master_ID
					INNER join BSA_Foodservice_Items_Master bfim on bfim.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID AND cp.Deleted = 0
					INNER JOIN Type_Code_Desc tc ON tc.Type_Code_Desc_ID = bfim.Type_Code_Desc_ID


			SELECT	DISTINCT
					<!--- This field "rowIDInt" creates a incremental integer and is useful when the request comes from "Bid_Info_Search_Qry.cfm".
					Since we only want to retrieve selected records using a range, eg: 100-200, 300-400 etc, "rowIDInt" can be used for that purpose.
					Please leave this column as the first column.
					--->
					identity(INT) As rowIDInt,
					<!--- So that "rowIDInt" increments integers properly, the second column should not have any blank or null value.
					Leave "Item" as the second column, as this column will always have a value.
					--->
					bidprod.Item,
					bidprod.Description,
					Shared,
					won AS won_lost,
					Incremental,
					Specd,
					Line_Number,
					--Won_By,
					--Won_UOM,
					Program_Bid_Category_ID,
					Program_Bid_Category_Code,
					Program_Bid_Category_Description,
					Program_Bid_Package_ID,
					Program_Bid_Package_Code,
					Program_Bid_Package_Description,
					bidprod.BSA_Foodservice_Items_Master_ID,
					(select top 1 grp.Product_Group_ID
						from ##tmp_program_bid_product_group_info grp
						where grp.BSA_Foodservice_Items_Master_ID = bidprod.BSA_Foodservice_Items_Master_ID
					) as Product_Group_ID,
						(select top 1 grp.Group_Desc
							  from ##tmp_program_bid_product_group_info grp
							  where grp.BSA_Foodservice_Items_Master_ID = bidprod.BSA_Foodservice_Items_Master_ID
						) as Group_Desc,
					(select top 1 grp.Added_By_Group
						from ##tmp_program_bid_product_group_info grp
						where grp.BSA_Foodservice_Items_Master_ID = bidprod.BSA_Foodservice_Items_Master_ID
						) as Added_By_Group,
					##tmp_won_rate_data.Rate,
					##tmp_won_rate_data.Unit_Of_Measure_ID,
					##tmp_won_rate_data.Abbreviation_Singular,
					##tmp_won_rate_data.Delivery_Type

			<!--- Insert the products in a temp table. It is useful when we are searching or sorting using AJAX calls and need to
			retrieve data using a range, eg: 100-200, 300-400 etc. A new column with an incremental integer is added to this temp table.
			--->
			INTO  ##tmp_final_program_bid_product_info
			FROM	##tmp_program_bid_product_info bidprod
					LEFT JOIN ##tmp_won_rate_data ON
					##tmp_won_rate_data.BSA_Foodservice_Items_Master_ID = CAST(bidprod.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50))

			<cfif arguments.searchCriteria neq "">
			WHERE
				(bidprod.Item LIKE '%#arguments.searchCriteria#%'
					OR (select top 1 grp.Group_Desc
							  from ##tmp_program_bid_product_group_info grp
							  where grp.BSA_Foodservice_Items_Master_ID = bidprod.BSA_Foodservice_Items_Master_ID
						)  LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchCriteria#%">
					OR bidprod.Description LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchCriteria#%">
					OR Line_Number LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchCriteria#%">
				)
				<cfelse>
				WHERE 1 = 1
			</cfif>

			<!--- When the user searches or sorts from "bid_info.cfm",the call is an AJAX call and the column to be sorted  is used below. --->
			<cfif arguments.source eq "bidInfoPage">
				<cfswitch expression="#arguments.sortColumnNumber#">
					<cfcase value='0'> ORDER BY bidprod.Item #arguments.sortColumnOrder# </cfcase>
					<cfcase value='1'> ORDER BY Group_Desc  #arguments.sortColumnOrder#</cfcase>
					<cfcase value='2'> ORDER BY bidprod.Description  #arguments.sortColumnOrder#</cfcase>
					<cfcase value='3'> ORDER BY Line_Number  #arguments.sortColumnOrder#</cfcase>
				</cfswitch>
			 <cfelse>
			 <!--- This is the default sort order and is not used by the AJAX call. --->
			ORDER BY Item, Description
			 </cfif>

			 <!--- Total number of records BEFORE filtering (if any) based on search.
			 Note:The reason why we are not getting the TOTAL count from "##tmp_final_program_bid_product_info" table is because
			 the query which populates the table may have a search criteris which could restrict the count.
			 --->
			 SELECT @totalCount  = COUNT (*) FROM ##tmp_program_bid_product_info

			  <!--- Total number of records AFTER filtering based on search. --->
			 SELECT @totalDisplayCount = COUNT (*) FROM ##tmp_final_program_bid_product_info

			<!--- When the user searches or sorts from "bid_info.cfm",the call is an AJAX call and the search keyword is used below. --->
			<cfif arguments.source eq "bidInfoPage">
				<!--- The above query results have already been ORDERED when the data was inserted in the temp table.
				We also need the total number of records BEFORE filtering."TotalRecordCount" is that number.
				--->
				SELECT *, @totalCount As TotalRecordCount, @totalDisplayCount As TotalDisplayCount
				FROM ##tmp_final_program_bid_product_info
				<!--- Query usng a range to return what is needed for paging. --->
				WHERE rowIDInt >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.startRow#">
				AND rowIDInt <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.endRow#">
			<cfelse>
				<!--- The above query results have already been ORDERED when the data was inserted in the temp table --->
				SELECT * FROM ##tmp_final_program_bid_product_info
			</cfif>

			SET NOCOUNT OFF
		</cfquery>

		<cfquery name="qDropTables" datasource="#application.datasource#">
			if object_id('tempdb..##tmp_program_bid_product_info') is not null
			drop table ##tmp_program_bid_product_info

			if object_id('tempdb..##tmp_program_bid_product_group_info') is not null
			drop table ##tmp_program_bid_product_group_info

			if object_id('tempdb..##tmp_won_rate_data') is not null
			drop table ##tmp_won_rate_data
		</cfquery>

		<cfreturn local.allProducts />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProgramCompetitiveWonData"output="false" returntype="query" hint="function to return program competitive won data">
		<cfargument name="programID" required="true" type="numeric" />
		<cfargument name="productID" required="true" type="string" />

		<cfquery name="local.CompetitiveWonData" datasource="#application.datasource#">
			SELECT	Program_Competitive_Data.Program_Id,
					Program_Competitive_Data.Product_Id,
					Program_Competitive_Data.Won_Price,
					Program_Competitive_Data.Won_Uom,
					Program_Competitive_Data.Won_Delivery_Type,
					Program_Bid_Won_By.Program_Bid_Won_By_ID,
					Program_Bid_Won_By.Program_Bid_Won_By_Code,
					Program_Bid_Won_By.Program_Bid_Won_By_Description
			FROM	Program_Competitive_Data
					INNER JOIN Program_Bid_Won_By ON
					Program_Bid_Won_By.Program_Bid_Won_By_ID = Program_Competitive_Data.Program_Bid_Won_By_ID
			WHERE	Program_Competitive_Data.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#">
			AND		Program_Competitive_Data.Product_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.productID#">
		</cfquery>

		<cfreturn local.CompetitiveWonData />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getProgramCompetitiveDownloadData" output="true" returntype="query" hint="function to return program competitive download data">

		<cfargument name="programNumber" type="string" required="true" default="" />

		<cfscript>
			//set local variables
			var strProgramNumber	= "";
			var qGetData			= "";
			var qRetData			= "";

			//assign local variables
			strProgramNumber 			= arguments.programNumber;
		</cfscript>



		<cfquery name="qGetData" datasource="#application.datasource#">
	   <!--- EXEC USP_GET_PROGRAM_COMPETITIVE_DATA '#strProgramNumber#'	--->
	   IF OBJECT_ID('tempdb..##TMP_Comp_Won_By_Data') IS NOT NULL
DROP TABLE ##TMP_Comp_Won_By_Data


CREATE  TABLE ##TMP_Comp_Won_By_Data
(
	Program_ID	INT				NULL,
	Product_ID	NVARCHAR(50)	NULL,
	Won_By		NVARCHAR(255)	NULL,
	Won_Price	FLOAT			NULL,
	Won_Uom		INT				NULL,
	Won_Delivery_Type INT		NULL
)


INSERT INTO ##TMP_Comp_Won_By_Data
SELECT	Program_Product_Bid_Info.Program_ID, Program_Product_Bid_Info.Product_ID, Program_Product_Bid_Info.Won_By, Program_Product_Bid_Info.Won_Price, Program_Product_Bid_Info.Won_Uom,
		Program_Product_Bid_Info.Won_Delivery_Type
FROM	Contract_Main
		INNER JOIN Program_Product_Bid_Info ON Program_Product_Bid_Info.Program_ID = Contract_Main.Contract_Main_ID AND
		Program_Product_Bid_Info.Deleted = 0 AND Program_Product_Bid_Info.Won = 1
WHERE	Contract_Main.Contract_Number LIKE  '%#strProgramNumber#%'
AND		Contract_Main.Approved = 1

UNION

SELECT	Program_Product_Bid_Info.Program_ID, Program_Product_Bid_Info.Product_ID, Program_Bid_Won_By.Program_Bid_Won_By_Description AS Won_By, Program_Competitive_Data.Won_Price, Program_Competitive_Data.Won_Uom,
		Program_Competitive_Data.Won_Delivery_Type
FROM	Contract_Main
		INNER JOIN Program_Product_Bid_Info ON Program_Product_Bid_Info.Program_ID = Contract_Main.Contract_Main_ID AND Program_Product_Bid_Info.Deleted = 0
		INNER JOIN Program_Competitive_Data ON Program_Competitive_Data.Program_ID = Program_Product_Bid_Info.Program_ID AND Program_Competitive_Data.Product_ID = Program_Product_Bid_Info.Product_ID
		INNER JOIN Program_Bid_Won_By ON Program_Bid_Won_By.Program_Bid_Won_By_ID = Program_Competitive_Data.Program_Bid_Won_By_ID
WHERE	Contract_Main.Contract_Number LIKE  '%#strProgramNumber#%'
AND		Contract_Main.Approved = 1


 SELECT DISTINCT
		Contract_Main.Contract_Main_ID,
		Contract_Main.Contract_Number AS Program_Number,
		CASE
			WHEN LEN(Contract_Main.revision_version) = 4 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 4)
			WHEN LEN(Contract_Main.revision_version) = 5 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 5)
			ELSE RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 3)
		END AS Version,
		BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description,
		CASE WHEN Contract_Products.Product_Type_ID = 1 THEN 'Fixed Price' ELSE 'Rebate' END AS Discount,
		CASE WHEN Contract_Products.Product_Type_ID = 1 THEN Program_Fixed_Component_Name.Program_Fixed_Component_Name ELSE Program_Rebates_Component_Name.Program_Rebates_Component_Name END AS Component,
		CASE WHEN Contract_Products.Product_Type_ID = 1 THEN CAST(Program_Fixed_Price_Product_Data.Fixed_Price_Value AS DECIMAL(18,2))
			ELSE CAST(Program_Rebates_Component_Data.Rate AS DECIMAL(18,2)) END AS Rate,
		CASE WHEN Contract_Products.Product_Type_ID = 1 THEN (SELECT Abbreviation_Singular FROM	Units_Of_Measure WHERE	Unit_Of_Measure_ID = Program_Fixed_Price_Product_Data.Unit_Of_Measure_ID)
			ELSE (SELECT Abbreviation_Singular from Units_Of_Measure WHERE Unit_Of_Measure_ID = Program_Rebates_Component_Data.Unit_Of_Measure_ID) END AS Rate_UOM,
		CASE WHEN ISNULL(Program_Product_Bid_Info.Won, 0) = 1 THEN 'Yes' ELSE 'No' END AS Won,
		##TMP_Comp_Won_By_Data.Won_By,
		##TMP_Comp_Won_By_Data.Won_Price AS Won_Rate,
		(SELECT Abbreviation_Singular FROM Units_Of_Measure WHERE Unit_Of_Measure_ID = ##TMP_Comp_Won_By_Data.Won_UOM) AS Won_Uom,
		CASE ##TMP_Comp_Won_By_Data.Won_Delivery_Type WHEN 1 THEN 'Delivered' WHEN 2 THEN 'FOB' END AS Delivery_Type,
		Program_Bid_Category.Program_Bid_Category_Description AS Category, Program_Bid_Package.Program_Bid_Package_Description AS Package, CASE Program_Product_Bid_Info.Shared WHEN 1 THEN 'Yes' ELSE 'No' END AS Shared,
		CASE Program_Product_Bid_Info.Incremental WHEN 1 THEN 'Yes' ELSE 'No' END AS Incremental,
		CASE Program_Product_Bid_Info.Specd WHEN 1 THEN 'Yes' ELSE 'No' END AS Specd,
		Program_Bid_Source.Program_Bid_Source_Description AS Source,
		Program_Bid_Source_Type.Program_Bid_Source_Type_Description AS Source_Type,
		CAST(DATEPART(month, Program_Bid_Request.Program_Bid_Source_Date) AS VARCHAR(2)) + '/' + CAST(DATEPART(day, Program_Bid_Request.Program_Bid_Source_Date) AS VARCHAR(2)) + '/' + CAST(DATEPART(year, Program_Bid_Request.Program_Bid_Source_Date) AS VARCHAR(4)) AS Date_Source_Received,
		Program_Product_Volume.Opportunity_Volume_CS,
		Program_Product_Volume.Opportunity_Volume_LB,
		CAST(DATEPART(month, Contract_Main.Approval_Date) AS VARCHAR(2)) + '/' + CAST(DATEPART(day, Contract_Main.Approval_Date) AS VARCHAR(2)) + '/' + CAST(DATEPART(year, Contract_Main.Approval_Date) AS VARCHAR(4)) AS Approval_Date
FROM	Contract_Products
		INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Contract_Products.Contract_Main_ID
		INNER JOIN Program_Bid_Request ON Program_Bid_Request.Program_ID = Contract_Main.Contract_Main_ID
		INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
		/******************* Fixed Price *********************/
		LEFT JOIN Program_Fixed_Price_Product_Data ON Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID AND Program_Fixed_Price_Product_Data.Deleted = 0
		LEFT JOIN Program_Fixed_Component ON Program_Fixed_Component.Program_Fixed_Component_ID = Program_Fixed_Price_Product_Data.Program_Fixed_Component_ID
		LEFT JOIN Program_Fixed_Component_Name ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
		/******************* Rebate *************************/
		LEFT JOIN Program_Rebates_Product_Data ON Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID AND
		Program_Rebates_Product_Data.Program_ID = Contract_Main.Contract_Main_ID AND
		Program_Rebates_Product_Data.Deleted = 0
		LEFT JOIN Program_Rebates_Component ON Program_Rebates_Component.Program_ID = Contract_Main.Contract_Main_ID AND
		Program_Rebates_Component.Deleted = 0
		LEFT JOIN Program_Rebates_Component_Name ON Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
		LEFT JOIN Program_Rebates_Component_Data ON Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID AND
		Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID AND
		Program_Rebates_Component_Data.Deleted = 0
		/******************* Bid Data *************************/
		INNER JOIN Program_Product_Bid_Info ON Program_Product_Bid_Info.Program_ID = Contract_Products.Contract_Main_ID AND
		Program_Product_Bid_Info.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID AND Program_Product_Bid_Info.Deleted = 0
		LEFT JOIN ##TMP_Comp_Won_By_Data ON ##TMP_Comp_Won_By_Data.Program_ID = Program_Product_Bid_Info.Program_ID AND ##TMP_Comp_Won_By_Data.Product_ID = Program_Product_Bid_Info.Product_ID
		LEFT JOIN Program_Bid_Category ON Program_Bid_Category.Program_Bid_Category_ID = Program_Product_Bid_Info.Program_Bid_Category_ID
		LEFT JOIN Program_Bid_Package ON Program_Bid_Package.Program_Bid_Package_ID = Program_Product_Bid_Info.Program_Bid_Package_ID
		--LEFT JOIN Program_Competitive_Data ON Program_Competitive_Data.Product_ID = Program_Product_Bid_Info.Product_ID AND Program_Competitive_Data.Program_ID = Program_Product_Bid_Info.Program_ID
		--LEFT JOIN Program_Bid_Won_By ON Program_Bid_Won_By.Program_Bid_Won_By_ID = Program_Competitive_Data.Program_Bid_Won_By_ID
		LEFT JOIN Program_Bid_Source ON Program_Bid_Source.Program_Bid_Source_ID = Program_Bid_Request.Program_Bid_Source_ID
		LEFT JOIN Program_Bid_Source_Type ON Program_Bid_Source_Type.Program_Bid_Source_Type_ID = Program_Bid_Request.Program_Bid_Source_Type_ID
		LEFT JOIN Program_Product_Volume ON Program_Product_Volume.Program_ID = Contract_Main.Contract_Main_ID AND Program_Product_Volume.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AND Program_Product_Volume.Deleted = 0
WHERE	Contract_Main.Contract_Number LIKE '%#strProgramNumber#%'
--AND		CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) = CASE (ISNULL(Contract_Products.Product_Group_ID, '')) WHEN '' THEN CAST (Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) ELSE CAST (Contract_Products.Product_Group_ID AS NVARCHAR(50)) END
AND		Contract_Main.Approved = 1
AND		Contract_Products.Deleted = 0
AND     Contract_Products.IS_group = 0


IF OBJECT_ID('tempdb..##TMP_Comp_Won_By_Data') IS NOT NULL
DROP TABLE ##TMP_Comp_Won_By_Data
		</cfquery>

		<cfset qRetData = qGetData />

		<cfreturn qRetData />

	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------->
	<cffunction name="saveMassApplyData" output="true">
		<!---pass the whole form scope--->
		<cfargument name="formScope" required="false" default="" />

		<!--- LOOP 1 :: LOOP OVER GROUP(S) SELECTED FOR MASS APPLY START--->
		<cfloop list="#arguments.formScope.productkind#" index="productgroups" >
			<!--- GET ITEM(S) IN PROGRAM --->
			<cfquery name="getItemsOnProgram" datasource="#application.datasource#">
				SELECT	CP.BSA_Foodservice_Items_Master_ID
				FROM 	Contract_Products CP
						INNER JOIN BSA_Foodservice_Items_Master BFIM ON BFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
						LEFT JOIN TYPE_CODE_DESC tc ON tc.Type_Code_desc_Id = BFIM.Type_Code_desc_Id
				WHERE 	CP.Contract_Main_ID = #arguments.formScope.contract_main_id#
				AND 	(CP.Product_Group_ID IN (<cfqueryparam value="#productgroups#" cfsqltype="cf_sql_varchar" list="true"/>)  OR tc.Type_Code_desc_Id in (<cfqueryparam value="#productgroups#" cfsqltype="cf_sql_varchar" list="true"/> ))
				AND 	CP.Deleted = 0
			</cfquery>

			<!--- LOOP 2 :: LOOP ON ITEMS IN THE PROGRAM START --->
			<cfloop query="getItemsOnProgram" >
			<!--- MOVE EXISTING DATA IN "PROGRAM_PRODUCT_BID_INFO" TO "HISTORY_PROGRAM_PRODUCT_BID_INFO" FOR CURRENT PROGRAM--->
				<cfquery name="Delete_PPBI" datasource="#application.datasource#">
					INSERT INTO History_Program_Product_Bid_Info
					(
						Program_Product_Bid_Info_ID
						,Program_ID
						,Product_ID
						,Won
						,Won_By
						,Won_Price
						,Won_Uom
						,Deleted
						,Created_Date
						,Won_Delivery_Type
						,Program_Bid_Won_By_ID
						,Program_Bid_Category_ID
						,Program_Bid_Package_ID
						,Shared
						,Incremental
						,Line_Number
						,Specd
						,Updated_Date
						,Updated_By
						,Updated_By_Billback_ID
					)
					SELECT
						Program_Product_Bid_Info_ID
						,Program_ID
						,Product_ID
						,Won
						,Won_By
						,Won_Price
						,Won_Uom
						,Deleted
						,Created_Date
						,Won_Delivery_Type
						,Program_Bid_Won_By_ID
						,Program_Bid_Category_ID
						,Program_Bid_Package_ID
						,Shared
						,Incremental
						,Line_Number
						,Specd
						,Updated_Date
						,Updated_By
						,Updated_By_Billback_ID
					FROM 	Program_Product_Bid_Info
					WHERE 	program_id = <cfqueryparam value= "#arguments.formScope.contract_main_id#" cfsqltype="cf_sql_integer" >
					AND 	Product_Id = <cfqueryparam value='#BSA_Foodservice_Items_Master_ID#' cfsqltype="cf_sql_varchar" >
					AND 	deleted = 0

					UPDATE	Program_product_bid_info
					SET 	deleted = 1
					WHERE 	program_id = <cfqueryparam value= "#arguments.formScope.contract_main_id#" cfsqltype="cf_sql_integer" >
					AND 	Product_Id = <cfqueryparam value='#BSA_Foodservice_Items_Master_ID#' cfsqltype="cf_sql_varchar" >
					AND 	deleted = 0
				</cfquery>

				<!--- Checks if there are records in Program  Competitive Data START --->
				<cfquery name="check_PCD" datasource="#application.datasource#">
					SELECT	*
					FROM 	Program_Competitive_Data
					WHERE 	program_id = #arguments.formScope.contract_main_id#
					AND 	product_ID = <cfqueryparam value='#BSA_Foodservice_Items_Master_ID#' cfsqltype="cf_sql_varchar" >
				</cfquery>
				<!--- Checks if there are records in Program  Competitive Data END --->

				<!--- DELETE if there are records in Program  Competitive Data START --->
				<cfif check_PCD.recordcount GT 0>
					<cfquery name="Delete_PCD" datasource="#application.datasource#">
						DELETE FROM Program_Competitive_Data
						WHERE program_id = #arguments.formScope.contract_main_id#
						AND product_ID = <cfqueryparam value='#BSA_Foodservice_Items_Master_ID#' cfsqltype="cf_sql_varchar" >
					</cfquery>
				</cfif>
				<!--- DELETE if there are records in Program  Competitive Data END --->

				<!--- INSERT NEW VALUES INTO "PROGRAM_PRODUCT_BID_INFO" FOR CURRENT PROGRAM --->
				<cfquery name="insert_program_product_bid_info" datasource="#application.datasource#">
					INSERT INTO Program_Product_Bid_Info
					(
						Program_ID
						,Product_ID
						,Won
						,Program_Bid_Category_ID
						,Program_Bid_Package_ID
						,Shared
						,Line_Number
						,Incremental
						,Specd
						,Program_Bid_Won_By_ID
						,Won_By
						,Won_Price
						,Won_Uom
						,Won_Delivery_type
						<!---
						<cfif arguments.formScope.won EQ 1>
						,Program_Bid_Won_By_ID
						,Won_By
						,Won_Price
						,Won_Uom
						,Won_Delivery_type
						<cfelseif arguments.formScope.won EQ 0>
						,Program_Bid_Won_By_ID
						,Won_By
						,Won_Price
						<cfelseif arguments.formScope.won EQ 2>
						,Program_Bid_Won_By_ID
						,Won_By
						</cfif>
						--->
						,Updated_Date
						,Updated_By
					)
					VALUES
					(
						#arguments.formScope.contract_main_id#
						,'#BSA_Foodservice_Items_Master_ID#'
						,<cfif arguments.formScope.won_level1 EQ 2>NULL<cfelse>#arguments.formScope.won_level1#</cfif>
						,#arguments.formScope.category#
						,#arguments.formScope.package#
						,#arguments.formScope.shared_level1#
						,<cfif isdefined('arguments.formScope.line_number')>#arguments.formScope.line_number#<cfelse>NULL</cfif>
						,#arguments.formScope.incremental_level1#
						,#arguments.formScope.specd_level1#
						<!---
						,<cfif isdefined('arguments.formScope.shared')>#arguments.formScope.shared#<cfelse>0</cfif>
						,<cfif isdefined('arguments.formScope.line_number')>#arguments.formScope.line_number#<cfelse>NULL</cfif>
						,<cfif isdefined('arguments.formScope.incremental')>#arguments.formScope.incremental#<cfelse>0</cfif>
						,<cfif isdefined('arguments.formScope.specd')>#arguments.formScope.specd#<cfelse>0</cfif>
						--->
						,#arguments.formScope.Client_Bid_ID_level1#
						,<cfqueryparam cfsqltype="cf_sql_varchar" value="#this.getWonByIdBidDesc(arguments.formScope.Client_Bid_ID_level1)#">
						,#arguments.formScope.client_rate_level1#
						,#arguments.formScope.client_uom_level1#
						,#arguments.formScope.client_delivery_level1#
						<!---
						<cfif form.won EQ 1>
						,#arguments.formScope.Client_Bid_ID#
						,'#this.getClientBidDesc()#'
						,#arguments.formScope.client_rate#
						,#arguments.formScope.client_uom#
						,#arguments.formScope.client_delivery#
						<cfelseif arguments.formScope.won EQ 0>
						,#arguments.formScope.Client_Bid_ID#
						,'#this.getClientBidDesc()#'
						,#arguments.formScope.client_rate#
						<cfelseif arguments.formScope.won EQ 2>
						,#arguments.formScope.Client_Bid_ID#
						,'#this.getClientBidDesc()#'
						</cfif>
						--->
						,getdate()
						,'#request.accessstructure.User_ID#'
					)
				</cfquery>

				<!--- LOOP 3 :: LOOP OVER COMPETITORS START --->
				<cfloop from="2" to="#arguments.formScope.competitorFields#" index="cnt">

					<cfif listlen(arguments.formScope.competitor_rate) LT arguments.formScope.competitorFields>
						<cfset arguments.formScope.competitor_rate = listappend(arguments.formScope.competitor_rate, 0,',')>
					</cfif>

					<cfif listgetat(arguments.formScope.competitor_id,cnt)>
					<!---<cfif listgetat(arguments.formScope.competitor_id,cnt) neq this.getClientBidId() and listgetat(arguments.formScope.competitor_id,cnt)>--->
						<cfquery name="Insert_program_Competitive_Data" datasource="#application.datasource#">
						INSERT INTO Program_Competitive_Data
						(
							Program_ID,
							Product_ID,
							Program_Bid_Won_By_ID,
							Won_Price,
							Won_Uom,
							Won_Delivery_Type,
							Won,
							Incremental,
							Shared,
							Specd
						)
						VALUES
						(
							#arguments.formScope.contract_main_id#
							,'#BSA_Foodservice_Items_Master_ID#'
							,#listgetat(arguments.formScope.competitor_id,cnt)#
							,#listgetat(arguments.formScope.competitor_rate,cnt)#
							,#listgetat(arguments.formScope.competitor_uom,cnt)#
							,<cfif listLen(arguments.formScope.competitor_delivery) gte cnt>#listgetat(arguments.formScope.competitor_delivery,cnt)#<cfelse>0</cfif>
							,#listgetat(arguments.formScope.competitor_won,cnt)#
							,<cfif isDefined("arguments.formScope.competitor_Incremental") and listLen(arguments.formScope.competitor_Incremental) gte cnt>#listgetat(arguments.formScope.competitor_Incremental,cnt)#<cfelse>0</cfif>
							,<cfif isDefined("arguments.formScope.competitor_Shared") and listLen(arguments.formScope.competitor_Shared) gte cnt>#listgetat(arguments.formScope.competitor_Shared,cnt)#<cfelse>0</cfif>
							,<cfif isDefined("arguments.formScope.competitor_Specd") and listLen(arguments.formScope.competitor_Specd) gte cnt>#listgetat(arguments.formScope.competitor_Specd,cnt)#<cfelse>0</cfif>
						)
						</cfquery>
					</cfif>

				</cfloop>
				<!--- LOOP 3 :: LOOP OVER COMPETITORS END --->
			</cfloop>
			<!--- LOOP 2 :: LOOP ON ITEMS IN THE PROGRAM END --->
		</cfloop>
		<!--- LOOP 1 :: LOOP OVER GROUP(S) SELECTED FOR MASS APPLY END--->

		<cfset setBidProposalStatus (arguments.formScope.contract_main_id)/>

	</cffunction>

	<cffunction name="getClientWonInfo" output="true">
		<cfargument name="programID" required="true" type="numeric">
		<cfargument name="Group_ID" required="true" type="any">

		<cfquery name="ClientWonInfo" datasource="#application.datasource#">
			if object_id('tempdb..##tmp_won_rate_data') is not null
			drop table ##tmp_won_rate_data

			SELECT	BFIM.BSA_Foodservice_Items_Master_ID,
					BFIM.Item,
					AVG(CAST(PFPPD.Fixed_Price_Value AS FLOAT)) AS Rate,
					PFPPD.Unit_Of_Measure_ID,
					UOM.Abbreviation_Singular,
					CP.Product_Type_ID AS Discount_Type_ID,
					CASE WHEN FCN.Fixed_Component_Type = 1 THEN 'Delivered' ELSE 'FOB' END AS Delivery_Type
			INTO  	##tmp_won_rate_data
			FROM	Program_Fixed_Price_Product_Data PFPPD
			INNER JOIN Units_Of_Measure UOM
			ON UOM.Unit_Of_Measure_ID = PFPPD.Unit_Of_Measure_ID
			INNER JOIN Program_Fixed_Component PFC
			ON PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID
			AND PFC.Deleted = 0
			INNER JOIN Program_Fixed_Component_Name FCN
			ON FCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
			INNER JOIN Contract_Products CP
			ON CP.Contract_Products_ID = PFPPD.Contract_Products_ID
			AND CP.Contract_Main_ID = PFPPD.Program_ID
			AND CP.Deleted = 0
			AND CP.Product_Type_ID = 1
			INNER JOIN BSA_Foodservice_Items_Master BFIM
			ON BFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID

			LEFT JOIN TYPE_CODE_DESC tc
			ON tc.Type_Code_desc_Id = BFIM.Type_Code_desc_Id

			WHERE	PFPPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#">
			AND		PFPPD.Deleted = 0
			<cfif len(arguments.Group_ID)>
			AND (CP.Product_Group_ID IN (<cfqueryparam value="#arguments.Group_ID#" cfsqltype="cf_sql_varchar" list="true"/>)  OR tc.Type_Code_desc_Id in (<cfqueryparam value="#arguments.Group_ID#" cfsqltype="cf_sql_varchar" list="true"/>))
			</cfif>
			GROUP BY BFIM.BSA_Foodservice_Items_Master_ID, BFIM.Item, PFPPD.Unit_Of_Measure_ID, UOM.Abbreviation_Singular, CP.Product_Type_ID, FCN.Fixed_Component_Type

			INSERT INTO ##tmp_won_rate_data
			SELECT	BFIM.BSA_Foodservice_Items_Master_ID,
					BFIM.Item,
					SUM(CAST(PRCD.Rate AS FLOAT)) AS Rate,
					PRCD.Unit_Of_Measure_ID,
					UOM.Abbreviation_Singular,
					CP.Product_Type_ID AS Discount_Type_ID,
					CASE WHEN PRCN.Component_Type = 1 THEN 'Delivered' ELSE 'FOB' END AS Delivery_Type
			FROM	Program_Rebates_Component_Data PRCD
			INNER JOIN Program_Rebates_Product_Data PRPD
			ON PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
			AND PRPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#">
			AND PRPD.Deleted = 0
			INNER JOIN Units_Of_Measure UOM
			ON UOM.Unit_Of_Measure_ID = PRCD.Unit_Of_Measure_ID
			INNER JOIN Program_Rebates_Component PRC
			ON PRC.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID
			AND PRC.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#">
			AND PRC.Deleted = 0
			INNER JOIN Program_Rebates_Component_Name PRCN
			ON PRCN.Program_Rebates_Component_Name_ID = PRC.Program_Rebates_Component_Name_ID
			INNER JOIN Contract_Products CP
			ON CP.Contract_Products_ID = PRPD.Contract_Products_ID
			AND CP.Contract_Main_ID = PRPD.Program_ID
			AND CP.Deleted = 0
			AND CP.Product_Type_ID = 2
			AND CP.Is_Group = 0
			INNER JOIN BSA_Foodservice_Items_Master BFIM
			ON BFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID


			LEFT JOIN TYPE_CODE_DESC tc
			ON tc.Type_Code_desc_Id = BFIM.Type_Code_desc_Id

			WHERE	PRCD.Deleted = 0
			AND		BFIM.BSA_Foodservice_Items_Master_ID NOT IN (SELECT DISTINCT BSA_Foodservice_Items_Master_ID FROM ##tmp_won_rate_data)
			<cfif len(arguments.Group_ID)>
			AND (CP.Product_Group_ID IN (<cfqueryparam value="#arguments.Group_ID#" cfsqltype="cf_sql_varchar" list="true"/>)  OR tc.Type_Code_desc_Id in (<cfqueryparam value="#arguments.Group_ID#" cfsqltype="cf_sql_varchar" list="true"/> ))
			</cfif>
			GROUP BY BFIM.BSA_Foodservice_Items_Master_ID, BFIM.Item, PRCD.Unit_Of_Measure_ID, UOM.Abbreviation_Singular, CP.Product_Type_ID, PRCN.Component_Type

			select * from ##tmp_won_rate_data

			if object_id('tempdb..##tmp_won_rate_data') is not null
			drop table ##tmp_won_rate_data
		</cfquery>
		<cfreturn ClientWonInfo>
	</cffunction>

	<cffunction name="getExistingCompetitor" output="true">
		<cfargument name="programID" required="true" type="numeric">
		<cfargument name="Group_ID" required="true" type="any">

			 <cfquery name="qgetExistingCompetitor" datasource="#application.datasource#">
				SELECT 	PCD.Program_Bid_Won_By_ID,
						ISNULL(PCD.Won_Price, 0) as Won_Price,
						ISNULL(PCD.Won_Uom, 1) as Won_Uom,
						PCD.Won_Delivery_type,
						PBWB.Program_Bid_Won_By_Description,
						ISNULL(PCD.Won, 2) as Won,
						PCD.Shared,
						PCD.Incremental,
						PCD.Specd,
						PBWB.Is_Client,
						1 as Order_By
				FROM 	BSA_Foodservice_Items_Master BFIM
						INNER JOIN Contract_Products CP ON CP.BSA_Foodservice_Items_Master_ID = BFIM.BSA_Foodservice_Items_Master_ID AND CP.Deleted = 0 and CP.Is_Group = 0
						INNER JOIN Program_Product_Bid_Info PCD ON PCD.Program_Id = CP.Contract_Main_ID AND PCD.Product_Id = BFIM.BSA_Foodservice_Items_Master_ID and PCD.Deleted = 0
						INNER JOIN Program_Bid_Won_By PBWB ON PBWB.Program_Bid_Won_By_Id = PCD.Program_Bid_Won_By_ID
				WHERE 	CP.Contract_Main_ID = #arguments.programID#
				AND 	(BFIM.Type_Code_desc_Id IN (<cfqueryparam value="#arguments.group_id#" cfsqltype="cf_sql_varchar" list="true"/>)
						OR CP.Product_Group_ID IN (<cfqueryparam value="#arguments.group_id#" cfsqltype="cf_sql_varchar" list="true"/>))

				UNION

				SELECT 	PCD.Program_Bid_Won_By_ID,
						PCD.Won_Price,
						PCD.Won_Uom,
						PCD.Won_Delivery_type,
						PBWB.Program_Bid_Won_By_Description,
						PCD.Won,
						PCD.Shared,
						PCD.Incremental,
						PCD.Specd,
						PBWB.Is_Client,
						2 as Order_By
				FROM 	BSA_Foodservice_Items_Master BFIM
						INNER JOIN Contract_Products CP ON CP.BSA_Foodservice_Items_Master_ID = BFIM.BSA_Foodservice_Items_Master_ID AND CP.Deleted = 0 and CP.Is_Group = 0
						INNER JOIN Program_Competitive_Data PCD ON PCD.Program_Id = CP.Contract_Main_ID AND PCD.Product_Id = BFIM.BSA_Foodservice_Items_Master_ID
						INNER JOIN Program_Bid_Won_By PBWB ON PBWB.Program_Bid_Won_By_Id = PCD.Program_Bid_Won_By_ID
				WHERE 	CP.Contract_Main_ID = #arguments.programID#
				AND 	(BFIM.Type_Code_desc_Id IN (<cfqueryparam value="#arguments.group_id#" cfsqltype="cf_sql_varchar" list="true"/>)
						OR CP.Product_Group_ID IN (<cfqueryparam value="#arguments.group_id#" cfsqltype="cf_sql_varchar" list="true"/>))
				GROUP BY  PCD.Program_Bid_Won_By_ID	,PCD.Won_Price,PCD.Won_Uom,PCD.Won_Delivery_type,PBWB.Program_Bid_Won_By_Description,PCD.Won,PCD.Shared,PCD.Incremental,PCD.Specd,PBWB.Is_Client
				ORDER BY Order_By
				<!---
				SELECT 	PCD.Program_Bid_Won_By_ID,
						PCD.Won_Price,
						PCD.Won_Uom,
						PCD.Won_Delivery_type,
						PBWB.Program_Bid_Won_By_Description,
						PCD.Won,
						PCD.Shared,
						PCD.Incremental,
						PCD.Specd,
						PBWB.Is_Client
				FROM 	BSA_Foodservice_Items_Master BFIM
						INNER JOIN Contract_Products CP ON CP.BSA_Foodservice_Items_Master_ID = BFIM.BSA_Foodservice_Items_Master_ID AND CP.Deleted = 0
						INNER JOIN Program_Competitive_Data PCD ON PCD.Program_Id = CP.Contract_Main_ID AND PCD.Product_Id = BFIM.BSA_Foodservice_Items_Master_ID
						INNER JOIN Program_Bid_Won_By PBWB ON PBWB.Program_Bid_Won_By_Id = PCD.Program_Bid_Won_By_ID
				WHERE 	CP.Contract_Main_ID = #arguments.programID#
				AND 	(BFIM.Type_Code_desc_Id IN (<cfqueryparam value="#arguments.group_id#" cfsqltype="cf_sql_varchar" list="true"/>)
						OR CP.Product_Group_ID IN (<cfqueryparam value="#arguments.group_id#" cfsqltype="cf_sql_varchar" list="true"/>))
				GROUP BY  PCD.Program_Bid_Won_By_ID	,PCD.Won_Price,PCD.Won_Uom,PCD.Won_Delivery_type,PBWB.Program_Bid_Won_By_Description,PCD.Won,PCD.Shared,PCD.Incremental,PCD.Specd,PBWB.Is_Client
				ORDER BY PBWB.Program_Bid_Won_By_Description
				--->

			</cfquery>

			<cfreturn qgetExistingCompetitor/>
	</cffunction>

	<cffunction name="setBidProposalStatus" output="false">
		<cfargument name="programID" required="true" type="numeric">
		<!--- Update program level bid/proposal status based on product bid/proposal status - Start --->
		<cfquery name="local.qWonLost" datasource="#application.datasource#">
			SELECT 	DISTINCT Program_Product_Bid_Info.won
			FROM 	Contract_Products
			LEFT JOIN 	Program_Product_Bid_Info
			ON			Program_Product_Bid_Info.Program_ID = Contract_Products.Contract_Main_ID
			AND		Program_Product_Bid_Info.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			AND		Program_Product_Bid_Info.Deleted = 0
			WHERE		Contract_Products.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#">
			AND 		Contract_Products.Deleted = 0
			AND		Contract_Products.Is_Group = 0
		</cfquery>

		<cfset local.programBidStatus = 1/>
		<cfif local.qWonLost.recordcount GT 1>
			<cfset local.programBidStatus = 3>
		<cfelseif local.qWonLost.recordcount EQ 1 AND local.qWonLost.won EQ 1>
			<cfset local.programBidStatus = 2>
		<cfelseif local.qWonLost.recordcount EQ 1 AND local.qWonLost.won EQ 0>
			<cfset local.programBidStatus = 4>
		<cfelseif local.qWonLost.recordcount EQ 1 AND local.qWonLost.won EQ "">
			<cfset local.programBidStatus = 1>
		</cfif>

		<cfquery name="local.query" datasource="#application.datasource#">
			UPDATE 	Program_Bid_Request
			SET 			Bid_Request_Status_ID = <cfqueryparam value= "#trim(local.programBidStatus)#" cfsqltype="CF_SQL_INTEGER">,
						Status_Changed_Date = getdate(),
						Status_Changed_By = '#request.accessstructure.User_ID#'
			WHERE		Deleted = 0
			AND		Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.programID#">
		</cfquery>
		<!--- Update program level bid/proposal status based on product bid/proposal status - End --->
	</cffunction>

	<cffunction name="getProgramUOM" output="false">

		<cfargument name="programID" required="true" type="numeric">

		<cfscript>
			//set local vars
			var nProgramId 		= 0;
			var qGetProgramUOM 	= "";
			var nDefault		= 0;

			//assign local vars
			nProgramId = arguments.programID;
		</cfscript>

		<!--- Get UOM from Fixed and Rebate to decipher a default Program UOM --->
		<cfquery name="qGetProgramUOM" datasource="#application.datasource#">
			SELECT	DISTINCT PFPPD.Unit_Of_Measure_ID
			FROM	Program_Fixed_Price_Product_Data PFPPD
					INNER JOIN Program_Fixed_Component PFC ON PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID AND PFC.Deleted = 0
					INNER JOIN Contract_Products CP ON CP.Contract_Products_ID = PFPPD.Contract_Products_ID AND CP.Contract_Main_ID = PFPPD.Program_ID
					AND CP.Deleted = 0 AND CP.Product_Type_ID = 1
			WHERE	PFPPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nProgramId#">
			AND		PFPPD.Deleted = 0
			UNION
			SELECT	DISTINCT PRCD.Unit_Of_Measure_ID
			FROM	Program_Rebates_Component_Data PRCD
					INNER JOIN Program_Rebates_Product_Data PRPD ON PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
					AND PRPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nProgramId#"> AND PRPD.Deleted = 0
					INNER JOIN Program_Rebates_Component PRC
					ON PRC.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID
					AND PRC.Program_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nProgramId#">
					AND PRC.Deleted = 0
					INNER JOIN Contract_Products CP ON CP.Contract_Products_ID = PRPD.Contract_Products_ID AND CP.Contract_Main_ID = PRPD.Program_ID
					AND CP.Deleted = 0 AND CP.Product_Type_ID = 2 AND CP.Is_Group = 0
			WHERE	PRCD.Deleted = 0
		</cfquery>

		<cfif qGetProgramUOM.RecordCount eq 1>
			<cfset nDefault = qGetProgramUOM.Unit_Of_Measure_ID />
		</cfif>

		<cfreturn nDefault />

	</cffunction>

	<cffunction name="getClientBidId" output="true">

		<cfscript>
			//set local vars
			var nClientBidId 	= 0;
			var qGetClientBidId	= "";
		</cfscript>

		<cfquery name="qGetClientBidId" datasource="#application.datasource#">
			SELECT	Program_Bid_Won_By_ID
			FROM	PROGRAM_BID_WON_BY
			WHERE	Is_Client = 1
		</cfquery>

		<cfset nClientBidId = qGetClientBidId.Program_Bid_Won_By_ID />

		<cfreturn nClientBidId />

	</cffunction>

	<cffunction name="getClientBidDesc" output="true">

		<cfscript>
			//set local vars
			var strClientBidDesc 		= 0;
			var qGetClientBidDesc	= "";
		</cfscript>

		<cfquery name="qGetClientBidDesc" datasource="#application.datasource#">
			SELECT	Program_Bid_Won_By_Description
			FROM	PROGRAM_BID_WON_BY
			WHERE	Is_Client = 1
		</cfquery>

		<cfset strClientBidDesc = qGetClientBidDesc.Program_Bid_Won_By_Description />

		<cfreturn strClientBidDesc />

	</cffunction>

	<cffunction name="getWonByIdBidDesc" output="true">

		<cfargument name="programBidWonByID" required="true" type="numeric">

		<cfscript>
			//set local vars
			var nProgramBidWonByID 	= 0;
			var	strWonByBidDesc		= "";
			var qGetWonByBidDesc	= "";

			//assign local variables
			nProgramBidWonByID = arguments.programBidWonByID;
		</cfscript>

		<cfquery name="qGetWonByBidDesc" datasource="#application.datasource#">
			SELECT	Program_Bid_Won_By_Description
			FROM	PROGRAM_BID_WON_BY
			WHERE	Program_Bid_Won_By_ID = '#nProgramBidWonByID#'
		</cfquery>

		<cfset strWonByBidDesc = qGetWonByBidDesc.Program_Bid_Won_By_Description />

		<cfreturn strWonByBidDesc />

	</cffunction>


</cfcomponent>