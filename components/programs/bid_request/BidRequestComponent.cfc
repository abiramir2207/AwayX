<cfcomponent>

   <cffunction name="set" output="false" returntype="struct">	
   
	  	<cfargument name="compID" type="string" required="true" default="">	
		<cfargument name="compNameId" type="string" required="true" default="">
		<cfargument name="programID" type="numeric" required="true" default=0>
		<cfargument name="compName" type="string" required="true" default="">
		<cfargument name="compUUID" type="string" required="true" default="#CreateUUID()#">
   
   		<cfscript>
		
			tmpStruct = structNew();
			tmpStruct.compID = arguments.compID;
			tmpStruct.compNameId = arguments.compNameId;
			tmpStruct.programID = arguments.programID;
			tmpStruct.compName = arguments.compName;
			tmpStruct.compUUID = arguments.compUUID;

		</cfscript>
		
		<cfreturn tmpStruct />

   </cffunction>
   
   <cffunction name="checkExists" output="false" returntype="boolean">	
   
	  	<cfargument name="aCompToCheck" type="array" required="true" default="">	
		<cfargument name="compID" type="string" required="true" default="">

   
   		<cfscript>
			
			doesExist = false;
			
			for (i=1; i lte ArrayLen(arguments.aCompToCheck); i = i+1)
			{
				if (not CompareNoCase(arguments.aCompToCheck[i].compUUID, arguments.compID))
					doesExist = true;
			}
			
		</cfscript>
		
		<cfreturn doesExist />

   </cffunction>
   
	<cffunction name="getActive" output="false" returntype="query">	
   
		<cfset useLakebaseForqGetActiveComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bidrequest_component_name")>
<cfif useLakebaseForqGetActiveComps>
	<cftry>
		<cfset qGetActiveComps = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bidrequest_component_name", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "program_bidrequest_component_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveComps>
<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_BidRequest_Component_Name
			WHERE 	Deleted = 0
			AND		Active = 1
			ORDER BY 	Program_BidRequest_Component_Name
		</cfquery>
</cfif>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="getComp" output="false" returntype="query">	
   
   		<cfargument name="compId" required="false" default=0 />
		
		<cfset useLakebaseForqGetComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_bidrequest_component_name")>
<cfif useLakebaseForqGetComp>
	<cftry>
		<cfset qGetComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_bidrequest_component_name", {
				"program_bidrequest_component_name_id" = "eq.#arguments.compId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetComp>
<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_BidRequest_Component_Name
			WHERE 	Program_BidRequest_Component_Name_ID = #arguments.compId#	
		</cfquery>
</cfif>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	
	<cffunction name="getInActive" output="false" returntype="query">	
   
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_BidRequest_Component_Name
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Program_BidRequest_Component_Name
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="add" output="false" hint="Function used to add a new component.">
	
		<cfargument name="componentName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="comptype" required="false" default="" />
		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		
		<cfset bCompNameExists = 0 />
		<cfset bProceedWithInsert = 1 />
		
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Program_BidRequest_Component_Name_ID, External_ID
			FROM	Program_BidRequest_Component_Name
			WHERE	Program_BidRequest_Component_Name = '#trim(arguments.componentName)#'
			AND		deleted = 0
		</cfquery>
		
		<cfif qGetActiveComps.RecordCount>
			
			<cfset bProceedWithInsert = 0 />
			
			<!------ if names are same do not have to insert ----->
			<cfset bCompNameExists = 1 />
			
			<!------ if there is any existing component which has same name but different id, notify  ----->
			<cfif application.returned_customer_setting.external_id_on EQ 1>
				<cfloop query="qGetActiveComps">
				
					<cfif External_ID NEQ arguments.externalID>
					
						<cfset bCompNameExists = 2 />
						<cfbreak />
					
					</cfif>					
				
				</cfloop>
			</cfif>		
			
		</cfif>
		
		<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
		<!------ Check if another componet (any discountype) have teh same allowance code ----->
		<cfif bProceedWithInsert EQ 1>
			<!------ going to re-use the code to get list of all component names for diffent discount types ----->			
			<cfset discountTypeList = templateManager.getComponentDiscountTypeList() />
			<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(0, discountTypeList, 0) />	
			<cfset usedAllowanceCodes = ValueList(qGetAllTemplateDiscountComponents.Allowance_Code_ID) />
			<cfif ListFindNOCase(usedAllowanceCodes, arguments.allowanceCodeId) NEQ 0>
				<cfset bProceedWithInsert = 0 />
				<cfset bCompNameExists = 3 />
			</cfif>
		</cfif>		
		
		<cfif bProceedWithInsert>
			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO	Program_BidRequest_Component_Name
					(Program_BidRequest_Component_Name, External_ID,BidRequest_Component_Type, Operating_Group_ID, Allowance_Code_ID)
				VALUES
					('#arguments.componentName#', 
					'#arguments.externalID#',
					#arguments.compType#,
					<cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
					<cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">)
				SELECT Program_BidRequest_Component_Name_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
			<cfset templateManager.saveDiscountComponentTemplates(qGetActiveComps.Program_BidRequest_Component_Name_ID, 10, arguments.selectedTemplateIdList) />
		</cfif>
	
		<cfreturn bCompNameExists />
		
   	</cffunction>
	
	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_BidRequest_Component_Name
			SET		Active = 0
			WHERE	Program_BidRequest_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="activate" output="false" hint="Function used to activate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_BidRequest_Component_Name
			SET		Active = 1
			WHERE	Program_BidRequest_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="delete" output="false" hint="Function used to delete components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_BidRequest_Component_Name
			SET		Deleted = 1
			WHERE	Program_BidRequest_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="update" output="false" hint="Function used to update components." returntype="numeric">
	
		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="compType" required="false" default="1" />
		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
   		
		<cfset bCompNameExists = 0 />
		<cfset bProceedWithUpdate = 1 />	
		
		<!---check to see if the name already exists--->		
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_BidRequest_Component_Name
			WHERE	Program_BidRequest_Component_Name = '#trim(arguments.compName)#'
			AND		Program_BidRequest_Component_Name_ID != #arguments.compId#		
			AND		deleted = 0
		</cfquery>
		
		<!---If the name exists then set does not exist to false--->
		<cfif qCheckCompNames.RecordCount>
		
			<cfset bProceedWithUpdate = 0 />
			<cfset bCompNameExists = 1 />
			
		</cfif>
		
		<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
		<!------ Check if another componet (any discountype) have teh same allowance code ----->
		<cfif bProceedWithUpdate EQ 1>
			<!------ going to re-use the code to get list of all component names for diffent discount types ----->			
			<cfset discountTypeList = templateManager.getComponentDiscountTypeList() />
			<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(0, discountTypeList, 0) />	
			<cfset usedAllowanceCodes = ValueList(qGetAllTemplateDiscountComponents.Allowance_Code_ID) />
			<cfif ListFindNOCase(usedAllowanceCodes, arguments.allowanceCodeId) NEQ 0>
				<!------ check if this allowance cod eis used by teh same component ----->
				<cfquery name="qCheckIfCurrentcomponent" dbtype="query">
					SELECT	Component_ID
					FROM	qGetAllTemplateDiscountComponents
					WHERE	Allowance_Code_ID = #arguments.allowanceCodeId#
					AND		Component_ID = #arguments.compId#
				</cfquery>
				<cfif not qCheckIfCurrentcomponent.recordCount>
					<cfset bProceedWithUpdate = 0 />
					<cfset bCompNameExists = 3 />
				</cfif>
			</cfif>		
		</cfif>		
		
		<cfif bProceedWithUpdate>
			<cfquery datasource="#application.datasource#">
				UPDATE 	Program_BidRequest_Component_Name
				SET		Program_BidRequest_Component_Name = '#arguments.compName#',
						BidRequest_Component_Type = #arguments.comptype#,
						External_ID = '#arguments.externalID#',
						Operating_Group_ID = <cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
						Allowance_Code_ID = <cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">
				WHERE	Program_BidRequest_Component_Name_ID = #arguments.compId#
			</cfquery>
			<cfset templateManager.saveDiscountComponentTemplates(arguments.compId, 10, arguments.selectedTemplateIdList) />
		</cfif>
		
		<cfreturn bCompNameExists />
		
   	</cffunction>
   
	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">	
   
   		<cfargument name="nameID" type="numeric" required="false" default="" />
			
		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Program_BidRequest_Component
			WHERE 	Program_BidRequest_Component_Name_ID = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
			AND 	deleted = 0 
		</cfquery>
		
		<!---if we get a count back from qCheckCompName then set canDelete to false--->
		<cfif qCheckCompName.count>
			<cfset bCanDelete = false />
		<cfelse>
			<cfset bCanDelete = true />
		</cfif>
		
		<cfreturn bCanDelete />
		
   </cffunction>
   

	<cffunction name="getProgFixComp" output="false" returntype="query">	
   
   		<cfargument name="ProgID" required="true" default=0 />
		
		<cfquery name="qgetProgFixComp" datasource="#application.datasource#">
			SELECT  *, N.Program_Fixed_Component_Name_ID,
					N.Fixed_Component_Type,
					N.Program_Fixed_Component_Name,
					C.Program_Fixed_Component_Id, 
					C.Fixed_Component_Paid_to
			FROM Program_Fixed_Component_Name N
			LEFT JOIN Program_Fixed_Component C
					ON C.Program_Fixed_Component_Name_ID = N.Program_Fixed_Component_Name_ID
					AND C.Program_ID = <cfqueryparam value="#arguments.ProgID#" cfsqltype="CF_SQL_INTEGER" />
					AND C.Deleted = 0
			WHERE N.Deleted = 0
				AND N.Active = 1
				and N.Program_Fixed_Component_Name_Id > 2 -- don't know why..found it in other places
			AND N.Program_Fixed_Component_Name_id is not null
			ORDER BY N.Program_Fixed_Component_Name_ID, C.Program_Fixed_Component_Id

		</cfquery>

		<cfreturn qgetProgFixComp />
		
   	</cffunction>

	
	<cffunction name="getProgFixCompProd" output="false" returntype="query">	
   
   		<cfargument name="ProgID" required="true" default=0 />
		<cfargument name="Product_List" required="true" default="" />
		
		<cfquery name="qgetProgFixCompProd" datasource="#application.datasource#">
			SELECT	distinct BSA_Foodservice_Items_Master_ID, description
				FROM	BSA_Foodservice_Items_Master I
			WHERE
						I.Deleted = 0 AND
			<CFIF arguments.Product_List EQ "">
				1=2
			<CFELSE>
				I.BSA_Foodservice_Items_Master_ID
				IN (#ListQualify(arguments.Product_List, "'", ",")#)
			</cfif>
		</cfquery>

		<cfreturn qgetProgFixCompProd />
		
   	</cffunction>
	
	
	<cffunction name="getFixedData" output="false" returntype="struct">	
   
   		<cfargument name="ProgID" required="true" default=0 />
		<cfargument name="Product_List" required="true" default="" />
		
		<cfset qgetProgFixComp = this.getProgFixComp(arguments.ProgID) />
		<cfset qgetProgFixCompProd = this.getProgFixCompProd(arguments.ProgID,arguments.Product_List) />
		<cfset fixedData = StructNew()>
		<Cfset fixedData.aComp = ArrayNew(1)>
		<Cfset fixedData.aProd = ArrayNew(1)>
		<cfloop query="qgetProgFixComp">
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#] = StructNew()>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].hasRules = this.getComp(qgetProgFixComp.Program_Fixed_Component_Name_ID).has_Rules>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].rulesRequired = this.getComp(qgetProgFixComp.Program_Fixed_Component_Name_ID).rule_required>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].CompUUID = qgetProgFixComp.currentrow>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].CompNameId = qgetProgFixComp.Program_Fixed_Component_Name_ID>
			<cfset fixedData.aComp[#evaluate(qgetProgFixComp.currentrow)#].componentPaidTo = qgetProgFixComp.Fixed_Component_Paid_to>
		</cfloop>
		
		<cfloop query="qgetProgFixCompProd">
			<cfset fixedData.aProd[#evaluate(qgetProgFixCompProd.currentrow)#] = StructNew()>
			<cfset fixedData.aProd[#evaluate(qgetProgFixCompProd.currentrow)#].masterItemId = qgetProgFixCompProd.BSA_Foodservice_Items_Master_ID>
			<cfset fixedData.aProd[#evaluate(qgetProgFixCompProd.currentrow)#].description = qgetProgFixCompProd.description>
		</cfloop>

		<cfreturn fixedData />
		
   	</cffunction>
	
		
	<cffunction name="getFixProdRule" output="false" returntype="numeric">	
   
   		<cfargument name="ProdID" required="true" default=0 />
		<cfargument name="compID" required="true" default=0 />
		<cfargument name="progID" required="true" default=0 />
		
		<cfquery name="qgetFixProd" datasource="#application.datasource#">
			SELECT	FD.Program_Fixed_Component_Name_Rule_ID
				FROM	dbo.Program_Fixed_Price_Product_Data FD
					INNER JOIN Contract_Products CP ON 
						FD.Contract_Products_ID = CP.Contract_Products_ID AND
						FD.Deleted = 0  
					INNER JOIN Program_Fixed_Component C
						ON C.Program_ID = CP.Contract_Main_ID
						AND C.Program_Fixed_Component_ID = FD.Program_Fixed_Component_ID
						 and C.DELETED = 0
					INNER JOIN Program_Fixed_Component_Name N
						ON N.Program_Fixed_Component_Name_ID = C.Program_Fixed_Component_Name_ID
						and N.Deleted = 0
					Inner Join Program_Fixed_Component_Name_Rule FNR
					  ON FNR.Program_Fixed_Component_Name_ID = N.Program_Fixed_Component_Name_ID
					Inner Join Program_Fixed_Component_Rule FR
						ON FR.Program_Fixed_Component_Rule_ID = FNR.Program_Fixed_Component_Rule_ID
					
			WHERE
						CP.Deleted = 0
						AND FR.deleted = 0
						AND FD.deleted = 0
						AND FNR.deleted = 0  
						AND CP.Contract_Main_ID =  <cfqueryparam value="#arguments.ProgID#" cfsqltype="CF_SQL_INTEGER" />
						AND CP.product_type_id =1
						AND N.Program_Fixed_Component_Name_ID =  <cfqueryparam value="#arguments.compID#" cfsqltype="CF_SQL_INTEGER" />
						AND CP.BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#arguments.ProdID#"/>
		</cfquery>
		<cfif not isnumeric(qgetFixProd.Program_Fixed_Component_Name_Rule_ID)>
			<cfset theResult = 0>
		 <cfelse>
		 	<cfset theResult = qgetFixProd.Program_Fixed_Component_Name_Rule_ID>
		</cfif>
		<cfreturn theResult />
		
   	</cffunction>

	
</cfcomponent>