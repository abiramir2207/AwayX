<!---BidRequestProductManager.cfc--->
<cfcomponent>
	<cfset qProgramProductBidInfo = QueryNew("Product_ID,Won") />
	
	<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" returntype="components.programs.bid_request.BidRequestProductStatusManager" output="false">	
		<cfreturn this />
	</cffunction>
	
	<cffunction name="loadProgramProducts" output="false">
		<cfargument name="programId" required="true" type="numeric" />
		
		<cfquery name="qGetAllProducts" datasource="#application.datasource#">

			SELECT 	DISTINCT 
					cp.contract_main_id Program_ID,
					ISNULL(Program_Product_Bid_Info.Won, 0) Won,
					Program_Product_Bid_Info.Won_By,
					Program_Product_Bid_Info.Won_Price,
					Program_Product_Bid_Info.Won_Uom,
					cfim.BSA_Foodservice_Items_Master_ID Product_ID,
					<!--- This has been added for display purpose only. The products added on revision were shwowing lost status,
					      based on Won column above
					--->
					Program_Product_Bid_Info.Won As Won_Status
			FROM 	Contract_Products cp					
					INNER JOIN BSA_Foodservice_Items_Master cfim ON
					cfim.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
					LEFT JOIN Program_Product_Bid_Info
					ON	Program_Product_Bid_Info.Deleted = 0
					AND	Program_Product_Bid_Info.Program_ID = cp.contract_main_id
					AND	Program_Product_Bid_Info.Product_ID = cp.BSA_Foodservice_Items_Master_ID
			where 	cp.Deleted = 0
			AND 	cp.contract_main_id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />
		
		</cfquery>
		
		<cfset qProgramProductBidInfo = qGetAllProducts />
		
	</cffunction>
	
	<cffunction name="getProgramProductInfo" output="false" returntype="query">
		<cfargument name="productId" required="true" />
		
		<cfset useLakebaseForqGetProductInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qprogramproductbidinfo")>
<cfif useLakebaseForqGetProductInfo>
	<cftry>
		<cfset qGetProductInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qprogramproductbidinfo", {
				"product_id" = "eq.#arguments.productId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProductInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProductInfo>
<cfquery name="qGetProductInfo" dbtype="query">

			SELECT	*
			FROM	qProgramProductBidInfo
			WHERE	Product_ID = '#arguments.productId#'
		
		</cfquery>
</cfif>
		
		<cfreturn qGetProductInfo />
		
	</cffunction>
	
	<cffunction name="getProgramProductWonInfo" output="false" returntype="string">
		<cfargument name="productId" required="true" />
		
		<cfset retrunValue = 0 />
		<cfset qGetProductInfo = getProgramProductInfo(arguments.productId) />
		<cfif qGetProductInfo.recordCount>
			<cfset retrunValue = qGetProductInfo.Won_Status />
		</cfif>
		
		<cfreturn retrunValue />
		
	</cffunction>	
		
	<cffunction name="saveBidRequestProductSplits" output="false">
	
		<cfargument name="bidRequestObj" required="false" default="" type="components.programs.bid_request.BidRequest" />
		<cfargument name="bidStatusId" required="false" default="3" />
		
		<!---open transaction--->
		<cftransaction>
			
			<!---since the only way this function can get called is if the status is being set to won then apply status of won to this bid request--->
			<cfset CreateObject("component", "components.programs.bid_request.BidRequestManager").applyStatus(arguments.bidRequestObj.getProgramId(), arguments.bidStatusId) />

		<!--- Variable to check the status of all the products --->
		<CFSET CheckProductStatus = 0>

			<cfset bidRequestProductObj = arguments.bidRequestObj.getBidRequestProducts() />

			<!---now loop over products and insert or update depending if the product already exists--->
			<cfloop index="prodIndx" from="1" to="#ArrayLen(bidRequestProductObj)#">

      <cfif bidRequestProductObj[prodIndx].getWonByID() EQ "">
       <cfset WonIDNull="Yes" />
      <cfelse>
       <cfset WonIDNull="No" /> 
      </cfif>
      
      <cfif bidRequestProductObj[prodIndx].getCategoryID() EQ "">
        <cfset catIDNull="Yes" />
      <cfelse>
        <cfset catIDNull="No" /> 
      </cfif>
      <cfif bidRequestProductObj[prodIndx].getPackageID() EQ "">
        <cfset packIDNull="Yes" />
      <cfelse>
        <cfset packIDNull="No" /> 
      </cfif>
				<!---get the contract product id, only needed for bid request fixed price --->
				<cfquery name="qGetContractProdId" datasource="#application.datasource#">
					SELECT 	Contract_Products_ID
					FROM	Contract_Products
					WHERE	Deleted = 0
					AND		Contract_Products.Product_Type_ID = 10
					AND		BSA_Foodservice_Items_Master_ID = '#bidRequestProductObj[prodIndx].getItemMasterId()#'
					AND		Contract_Main_ID = #arguments.bidRequestObj.getProgramId()#					
				</cfquery>
				
				<!------ Populate Program_Product_Bid_Info ----->
				<cfquery name="qPopulateProgramProductBidInfo" datasource="#application.datasource#">
					UPDATE	Program_Product_Bid_Info
					SET		Deleted = 1					
					WHERE	Program_ID = <cfqueryparam value="#arguments.bidRequestObj.getProgramId()#" cfsqltype="CF_SQL_INTEGER" />
					AND		Product_ID = <cfqueryparam value="#bidRequestProductObj[prodIndx].getItemMasterId()#" cfsqltype="CF_SQL_LONGVARCHAR" />
					AND		Deleted = 0
					/* NOW INSERT */
					INSERT INTO Program_Product_Bid_Info (Program_ID, Product_ID, Won, Won_By, Won_Price, Won_Uom, Won_Delivery_Type,Program_Bid_Won_By_ID, Program_Bid_Category_ID, Program_Bid_Package_ID)
					VALUES (<cfqueryparam value="#arguments.bidRequestObj.getProgramId()#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getItemMasterId()#" cfsqltype="CF_SQL_LONGVARCHAR" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getWon()#" cfsqltype="CF_SQL_BIT" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getWonBy()#" cfsqltype="CF_SQL_VARCHAR" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getWonPrice()#" cfsqltype="CF_SQL_FLOAT" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getWonUom()#" cfsqltype="CF_SQL_INTEGER" />,
							<cfqueryparam value="#bidRequestProductObj[prodIndx].getWonDeliveryType()#" cfsqltype="CF_SQL_VARCHAR" />,
              <cfqueryparam value="#bidRequestProductObj[prodIndx].getWonByID()#" cfsqltype="CF_SQL_INTEGER"  null="#WonIDNull#" />,
              <cfqueryparam value="#bidRequestProductObj[prodIndx].getCategoryID()#" cfsqltype="CF_SQL_INTEGER" null="#catIDNull#"  />,
              <cfqueryparam value="#bidRequestProductObj[prodIndx].getPackageID()#" cfsqltype="CF_SQL_INTEGER" null="#packIDNull#" />
              )
				</cfquery>	
				
				<!---set the contract product id--->
				<cfset bidRequestProductObj[prodIndx].setContractProductId(qGetContractProdId.Contract_Products_ID) />
				
				<cfif isNumeric(bidRequestProductObj[prodIndx].getContractProductId())><!------ only for bid request fixed price products ----->
				
				<!---st whether the bid request product was won or lost--->
				<cfquery datasource="#application.datasource#" name="qSetBidReqWonLost">
				
					UPDATE 	Program_Bid_Request_Product
					SET 	Won = <cfqueryparam value="#bidRequestProductObj[prodIndx].getWon()#" cfsqltype="CF_SQL_BIT" />,
							Won_By = <cfqueryparam value="#bidRequestProductObj[prodIndx].getWonBy()#" cfsqltype="CF_SQL_VARCHAR" />,
							Won_Price = <cfqueryparam value="#bidRequestProductObj[prodIndx].getWonPrice()#" cfsqltype="CF_SQL_FLOAT" />,
							Won_Uom = <cfqueryparam value="#bidRequestProductObj[prodIndx].getWonUom()#" cfsqltype="CF_SQL_INTEGER" />
					WHERE	Deleted = 0
					AND		Program_ID = #arguments.bidRequestObj.getProgramId()#
					AND		Contract_Products_ID = #bidRequestProductObj[prodIndx].getContractProductId()#
					
				</cfquery>
				
				</cfif>
			
					<!--- Check to see the bid status of the product. (1 means won and 0 meaans lost).
					      If all the products are of the "lost" status, then the final value of the variable
					      will be 0					  
					--->						
					<cfset CheckProductStatus = CheckProductStatus + bidRequestProductObj[prodIndx].getWon()>
			
			</cfloop>

				<!--- If all the products have a "lost" status, set the status to "lost" on the program side --->
				<cfif CheckProductStatus eq 0>
					<cfquery datasource="#application.datasource#" name="qUpdateProgramStatus">
					 Update Contract_Main
					 SET Contract_Status_type_IDX = 8
					 WHERE Contract_Main_ID = #arguments.bidRequestObj.getProgramId()#
					</cfquery>

				<!--- If all the products have a "lost" status, set the status to "lost" on the bid request table --->
					<cfquery datasource="#application.datasource#" name="qUpdateProgramStatus">
					 Update Program_Bid_request
					 SET Bid_Request_Status_ID = 4
					 WHERE Program_ID = #arguments.bidRequestObj.getProgramId()# 
					 AND Deleted = 0
					</cfquery>
				</cfif>
			
			<!---call SP to update program product volume --->
			<cfstoredproc procedure="PROGRAM_PRODUCT_VOLUME_UPD" datasource="#application.datasource#">
				
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#arguments.bidRequestObj.getProgramId()#" null="no">
				   
			</cfstoredproc>

			<!---call SP to update program contract quantity --->
			<cfstoredproc procedure="Update_Program_Volume" datasource="#application.datasource#">

				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Contract_Main_ID" value = "#arguments.bidRequestObj.getProgramId()#" null="no">

			</cfstoredproc>
			

			
			<!---now adjust the program quantity based on won products if the bidRequestStatus isn't lost--->
			<cfif arguments.bidStatusId neq 4>
			<!---  
            Dev Notes: D24583/Anand Rao/27-Aug-10
            Setting proposal status to Split causes volume to show as 0 in prog search 
            Commented a section in the the below Query
      --->
				<cfquery datasource="#application.datasource#" name="qGetProgramSum">
				
					UPDATE 	Contract_Main
					SET 	Contract_Quantity = 
					ISNULL((
						SELECT 	CASE 
								WHEN Contract_Main.Contract_Quantity_UOM_IDX = 1 THEN 
									ROUND((SUM(Program_Product_Volume.Volume_CS) * (DATEDIFF(d,Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date) + 1) / 7), 0)
								WHEN Contract_Main.Contract_Quantity_UOM_IDX = 2 THEN
									ROUND((SUM(Program_Product_Volume.Volume_LB) * (DATEDIFF(d,Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date) + 1) / 7), 0)
								ELSE (SELECT Contract_Quantity FROM Contract_Main WHERE Deleted = 0 AND Contract_Main.Contract_Main_ID = #arguments.bidRequestObj.getProgramId()#)
								END as Program_Sum
						FROM 	Program_Product_Volume
								INNER JOIN Contract_Main ON
								Contract_Main.Contract_Main_ID = Program_Product_Volume.Program_ID
								AND Contract_Main.Deleted = 0
								INNER JOIN Contract_Products ON
								Contract_Products.Contract_Main_ID = Program_Product_Volume.Program_ID
								AND Contract_Products.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
								AND Contract_Products.Deleted = 0
								/* INNER JOIN Program_Bid_Request_Product ON
								Program_Bid_Request_Product.Program_ID = Program_Product_Volume.Program_ID
								AND Program_Bid_Request_Product.Contract_Products_ID = Contract_Products.Contract_Products_ID
								AND Program_Bid_Request_Product.Deleted = 0
								AND Program_Bid_Request_Product.Won = 1 */
						WHERE 	Program_Product_Volume.Program_ID = #arguments.bidRequestObj.getProgramId()#
						AND		Program_Product_Volume.Deleted = 0
						
						GROUP BY Contract_Main.Contract_Quantity_UOM_IDX, Contract_Main.Contract_Start_Date,  Contract_Main.Contract_End_Date
					), 0)
					WHERE 	Contract_Main_ID = #arguments.bidRequestObj.getProgramId()#
					AND	Deleted = 0
					
				</cfquery>
				
			</cfif>
			
		</cftransaction>
		
	</cffunction>
	
	<cffunction name="saveBidRequestProductStatus" output="false">
	
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="bidStatusId" required="true" type="numeric" />
		<cfset won = 0 />
		<cfif arguments.bidStatusId eq 2>
			<cfset won = 1 />
		</cfif>
			<cfquery name="qPopulateProgramProductBidInfo" datasource="#application.datasource#">
				UPDATE	Program_Product_Bid_Info
				SET		Deleted = 1					
				WHERE	Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />
				AND		Deleted = 0
				/* NOW INSERT */
				INSERT INTO Program_Product_Bid_Info 
					(Program_ID, Product_ID, Won)
				SELECT #arguments.programId#,
						cp.BSA_Foodservice_Items_Master_ID,
						#won#
				FROM  Contract_Products CP
				WHERE  CP.Deleted = 0 AND
						CP.contract_main_id = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />
			</cfquery>
	</cffunction>
	
	<cffunction name="setStatusOnRevision" output="false">
	
		<cfargument name="programId" required="true" type="numeric" />
		
		<cfset status = "" />
		<cfset appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
		
		<!--- WR 45235 - Bid flags now flipping correctly: Setting to not update bid products on revise --->
		<cfif appSettings.getDontSetBidProductStatusRevise() EQ 1>
			<cfreturn />
		</cfif>
		
		<!---get the status of the bid request at the program level--->
		<cfset useLakebaseForqGetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bid_request")>
<cfif useLakebaseForqGetStatus>
	<cftry>
		<cfset qGetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bid_request", {
				"program_id" = "eq.#arguments.programId#",
				"select" = "bid_request_status_id"
			}), "bid_request_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetStatus>
<cfquery name="qGetStatus" datasource="#application.datasource#">
			SELECT	Bid_Request_Status_ID 
			FROM	Program_Bid_Request
			WHERE	Program_ID = '#arguments.programId#'
		</cfquery>
</cfif>
		
		<cfset status = qGetStatus.Bid_Request_Status_ID />
		
		<cfif status eq 4>
			<cfset won = 0 />
		<cfelseif status eq 2>
			<cfset won = 1 />
		<cfelse>
			<cfset won = "" />
		</cfif>

		<cfif won neq "">
			
			<!------ Populate Program_Product_Bid_Info ----->
			<cfquery name="qPopulateProgramProductBidInfo" datasource="#application.datasource#">
				INSERT INTO Program_Product_Bid_Info (Program_ID, Product_ID, Won)
				SELECT DISTINCT '#arguments.programId#',
						BSA_Foodservice_Items_Master_ID,
						'#Won#'
				FROM	Contract_Products
				WHERE	Deleted = 0
				AND		Contract_Main_ID = #arguments.programId#
				AND		BSA_Foodservice_Items_Master_ID NOT IN (SELECT Product_ID FROM Program_Product_Bid_Info WHERE Program_ID = #arguments.programId# AND Deleted = 0)
			</cfquery>
		
		</cfif>
						
	</cffunction>
	
</cfcomponent>

