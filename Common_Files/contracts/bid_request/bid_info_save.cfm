<!--- 	
FILENAME:   bid_info_save.cfm 				
CREATED:    07/17/2013 - Milan
--->	
	<cf_cryp type="en" key="#request.key#" string="#form.contract_main_id#">

	<cfset iDisplayStart = form.start_row - 1>

	<!--- If none of the product's line number's was modified by the user. --->
	<cfif form.ListItemLineNumberCombo neq "">

		<!--- Loop through the list of modified products which also has line number appended to it. --->
		<cfloop list="#form.ListItemLineNumberCombo#" index ="prodGUIDAndLineNumber">
	   
			<cfset ProdID =  Replace(Left(prodGUIDAndLineNumber,36),'_','-','ALL')>
			<cfset LineNumber = Mid(prodGUIDAndLineNumber,38,len(prodGUIDAndLineNumber))>

			<!--- Checks if the product's entry exists --->
			<cfquery name="check_PPBI" datasource="#application.datasource#">
				SELECT * 
				FROM Program_product_bid_info 
				WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER"> 
				AND Product_Id = <cfqueryparam value='#trim(ProdID)#' cfsqltype="CF_SQL_VARCHAR">  
				AND deleted = 0
			</cfquery>
			
			
			<cfif check_PPBI.recordcount GT 0>
				<!--- UPDATE --->
				<cfquery name="update_PPBI" datasource="#application.datasource#">
					UPDATE Program_product_bid_info 
					SET Line_Number = '#LineNumber#'
					WHERE program_id = <cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER"> 
					AND Product_Id = <cfqueryparam value='#trim(ProdID)#' cfsqltype="CF_SQL_VARCHAR">  
					AND deleted = 0
				</cfquery>

			<cfelse>
				<!--- INSERT --->
				<cfquery name="insert_PPBI" datasource="#application.datasource#">
					INSERT INTO Program_product_bid_info(Program_ID,Product_ID,line_Number)
					VALUES(<cfqueryparam value= "#trim(FORM.Contract_Main_ID)#" cfsqltype="CF_SQL_INTEGER">,<cfqueryparam value='#trim(ProdID)#' cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value='#LineNumber#' cfsqltype="CF_SQL_VARCHAR">)
				</cfquery>

			</cfif>

		</cfloop>

	</cfif>

	
	<!--- send the user back to form page. --->
	<cflocation url="bid_info.cfm?CID=#cryp.value#&iDisplayStart=#iDisplayStart#">