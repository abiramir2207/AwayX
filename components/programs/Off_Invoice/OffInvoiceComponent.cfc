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
		<cfargument name="arAllowList" type="array" required="false" default="#ArrayNew(1)#" />	
		<cfargument name="arDisAllowList" type="array" required="false" default="#ArrayNew(1)#" />	
   
   		<cfset arAllowListLen = ArrayLen(arguments.arAllowList) />
		<cfset arDisAllowListLen = ArrayLen(arguments.arDisAllowList) />
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	Program_OffInvoice_Component_Name.*,
					Allowance_Code.Allowance_Code_Number, Allowance_Code.Allowance_Code_Desc
			FROM 	Program_OffInvoice_Component_Name
			
			LEFT JOIN Allowance_Code
			ON	Allowance_Code.Allowance_Code_ID = Program_OffInvoice_Component_Name.Allowance_Code_ID
			
			WHERE 	Program_OffInvoice_Component_Name.Deleted = 0
			AND		Program_OffInvoice_Component_Name.Active = 1
			<cfloop from="1" to="#arAllowListLen#" index="i">
			<cfset lAllowList = arguments.arAllowList[i] />
			<cfif Len(lAllowList) EQ 0>
			AND 1=2
			<cfelse>
			AND	Program_OffInvoice_Component_Name_ID IN (#lAllowList#)
			</cfif>
			</cfloop>
			<cfloop from="1" to="#arDisAllowListLen#" index="i">
			<cfset lDisAllowList = arguments.arDisAllowList[i] />
			<cfif Len(lDisAllowList) GT 0>
			AND	Program_OffInvoice_Component_Name_ID NOT IN (#lDisAllowList#)
			</cfif>
			</cfloop>			
			ORDER BY 	Program_OffInvoice_Component_Name
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="getComp" output="false" returntype="query">	
   
   		<cfargument name="compId" required="false" default=0 />
		
		<cfset useLakebaseForqGetComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_offinvoice_component_name")>
<cfif useLakebaseForqGetComp>
	<cftry>
		<cfset qGetComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_offinvoice_component_name", {
				"program_offinvoice_component_name_id" = "eq.#arguments.compId#"
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
			FROM 	Program_OffInvoice_Component_Name
			WHERE 	Program_OffInvoice_Component_Name_ID = #arguments.compId#	
		</cfquery>
</cfif>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	
	<cffunction name="getInActive" output="false" returntype="query">	
   
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Program_OffInvoice_Component_Name
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Program_OffInvoice_Component_Name
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="add" output="false" hint="Function used to add a new component.">
	
		<cfargument name="componentName" required="false" default="" />	
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="requiredEffectiveRatePercent" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		
		<cfset bCompNameExists = 0 />
		<cfset bProceedWithInsert = 1 />
		
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Program_OffInvoice_Component_Name_ID, External_ID
			FROM	Program_OffInvoice_Component_Name
			WHERE	Program_OffInvoice_Component_Name = '#trim(arguments.componentName)#'
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
				INSERT INTO	Program_OffInvoice_Component_Name
					(Program_OffInvoice_Component_Name, External_ID, Operating_Group_ID, Allowance_Code_ID, Required_Effective_Rate_Percent)
				VALUES
					('#arguments.componentName#', 
					'#arguments.externalID#',
					<cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
					<cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">,
					<cfqueryparam value="#arguments.requiredEffectiveRatePercent#" cfsqltype="CF_SQL_INTEGER">)
				SELECT Program_OffInvoice_Component_Name_ID = @@IDENTITY 
				SET NOCOUNT OFF
			</cfquery>
			<cfset templateManager.saveDiscountComponentTemplates(qGetActiveComps.Program_OffInvoice_Component_Name_ID, 8, arguments.selectedTemplateIdList) />
		</cfif>
	
		<cfreturn bCompNameExists />
		
   	</cffunction>
	
	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_OffInvoice_Component_Name
			SET		Active = 0
			WHERE	Program_OffInvoice_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="activate" output="false" hint="Function used to activate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_OffInvoice_Component_Name
			SET		Active = 1
			WHERE	Program_OffInvoice_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="delete" output="false" hint="Function used to delete components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Program_OffInvoice_Component_Name
			SET		Deleted = 1
			WHERE	Program_OffInvoice_Component_Name_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="update" output="false" hint="Function used to update components." returntype="numeric">
	
		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
   		<cfargument name="operatingGroupId" required="false" default="0" />
		<cfargument name="allowanceCodeId" required="false" default="0" />
		<cfargument name="requiredEffectiveRatePercent" required="false" default="0" />
		<cfargument name="selectedTemplateIdList" required="false" default="" />
		
		<cfset bCompNameExists = 0 />		
		<cfset bProceedWithUpdate = 1 />
		
		<!---check to see if the name already exists--->		
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_OffInvoice_Component_Name
			WHERE	Program_OffInvoice_Component_Name = '#trim(arguments.compName)#'
			AND		Program_OffInvoice_Component_Name_ID != #arguments.compId#		
			AND		deleted = 0
		</cfquery>
		
		<!---If the name exists then set does not exist to false--->
		<cfif qCheckCompNames.RecordCount>
		
			<cfset bCompNameExists = 1 />
			<cfset bProceedWithUpdate = 0 />
			
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
				<cfset useLakebaseForqCheckIfCurrentcomponent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetalltemplatediscountcomponents")>
<cfif useLakebaseForqCheckIfCurrentcomponent>
	<cftry>
		<cfset qCheckIfCurrentcomponent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetalltemplatediscountcomponents", {
				"allowance_code_id" = "eq.#arguments.allowanceCodeId#",
				"component_id" = "eq.#arguments.compId#",
				"select" = "component_id"
			}), "component_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckIfCurrentcomponent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckIfCurrentcomponent>
<cfquery name="qCheckIfCurrentcomponent" dbtype="query">
					SELECT	Component_ID
					FROM	qGetAllTemplateDiscountComponents
					WHERE	Allowance_Code_ID = #arguments.allowanceCodeId#
					AND		Component_ID = #arguments.compId#
				</cfquery>
</cfif>
				<cfif not qCheckIfCurrentcomponent.recordCount>
					<cfset bProceedWithUpdate = 0 />
					<cfset bCompNameExists = 3 />
				</cfif>
			</cfif>		
		</cfif>		
		
		<cfif bProceedWithUpdate>
			<cfquery datasource="#application.datasource#">
				UPDATE 	Program_OffInvoice_Component_Name
				SET		Program_OffInvoice_Component_Name = '#arguments.compName#',
						External_ID = '#arguments.externalID#',
						Operating_Group_ID = <cfqueryparam value="#arguments.operatingGroupId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.operatingGroupId EQ 0#">,
						Allowance_Code_ID = <cfqueryparam value="#arguments.allowanceCodeId#" cfsqltype="CF_SQL_INTEGER" null="#arguments.allowanceCodeId EQ 0#">,
						Required_Effective_Rate_Percent = <cfqueryparam value="#arguments.requiredEffectiveRatePercent#" cfsqltype="CF_SQL_INTEGER">
				WHERE	Program_OffInvoice_Component_Name_ID = #arguments.compId#
			</cfquery>
			<cfset templateManager.saveDiscountComponentTemplates(arguments.compId, 8, arguments.selectedTemplateIdList) />
		</cfif>
		
		<cfreturn bCompNameExists />
		
   	</cffunction>
   
	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">	
   
   		<cfargument name="nameID" type="numeric" required="false" default="" />
			
		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Program_OffInvoice_Component_Name
			WHERE 	Program_OffInvoice_Component_Name_ID = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
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
   
</cfcomponent>