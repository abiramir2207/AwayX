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
   
		<cfset useLakebaseForqGetActiveComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_codes")>
<cfif useLakebaseForqGetActiveComps>
	<cftry>
		<cfset qGetActiveComps = application.oLakebase.toQuery(
			application.oLakebase.selectRows("template_codes", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "template_code.asc",
				"select" = "template_code,template_code_desc,template_code_id,external_id"
			}), "template_code,template_code_desc,template_code_id,external_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveComps>
<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	Template_Code,
					Template_Code_Desc,
					Template_Code_Id,
					External_ID
			FROM 	Template_Codes
			WHERE 	Deleted = 0
			AND		Active = 1
			ORDER BY 	Template_Code
		</cfquery>
</cfif>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="getComp" output="false" returntype="query">	
   
   		<cfargument name="compId" required="false" default=0 />
		
		<cfset useLakebaseForqGetComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_codes")>
<cfif useLakebaseForqGetComp>
	<cftry>
		<cfset qGetComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("template_codes", {
				"template_code_id" = "eq.#arguments.compId#",
				"select" = "template_code,template_code_desc,template_code_id,external_id"
			}), "template_code,template_code_desc,template_code_id,external_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetComp>
<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	Template_Code,
					Template_Code_Desc,
					Template_Code_Id,
					External_ID
			FROM 	Template_Codes
			WHERE 	Template_Code_Id = #arguments.compId#	
		</cfquery>
</cfif>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	
	<cffunction name="getInActive" output="false" returntype="query">	
   
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	Template_Code,
					Template_Code_Desc,
					Template_Code_Id,
					External_ID
			FROM 	Template_Codes
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Template_Code
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="add" output="false" hint="Function used to add a new component.">
	
		<cfargument name="componentName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
		<cfargument name="componentDesc" required="false" default="" />
		<cfset bCompNameExists = 0 />
		
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Template_Code_Id, External_ID
			FROM	Template_Codes
			WHERE	Template_Code = '#trim(arguments.componentName)#'
			AND		deleted = 0
		</cfquery>
		
		<cfif not qGetActiveComps.RecordCount>
			
			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
				INSERT INTO	Template_Codes
					(Template_Code,Template_Code_Desc,External_ID)
				VALUES
					('#arguments.componentName#','#arguments.componentDesc#', '#arguments.externalID#')
			</cfquery>
			
		<cfelse>
		
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
	
		<cfreturn bCompNameExists />
		
   	</cffunction>
	
	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Template_Codes
			SET		Active = 0
			WHERE	Template_Code_Id IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="activate" output="false" hint="Function used to activate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Template_Codes
			SET		Active = 1
			WHERE	Template_Code_Id IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="delete" output="false" hint="Function used to delete components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Template_Codes
			SET		Deleted = 1
			WHERE	Template_Code_Id IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="update" output="false" hint="Function used to update components." returntype="boolean">
	
		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />
		<cfargument name="externalID" required="false" default="" />
   		<cfargument name="compNameDesc" required="false" default="" />
		<cfset bCompNameExists = false />		
		
		<!---check to see if the name already exists--->		
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Template_Codes
			WHERE	Template_Code = '#trim(arguments.compName)#'
			AND		Template_Code_Id != #arguments.compId#		
			AND		deleted = 0
		</cfquery>
		
		<!---If the name exists then set does not exist to false--->
		<cfif qCheckCompNames.RecordCount>
		
			<cfset bCompNameExists = true />
			
		<cfelse>
		
			<cfquery datasource="#application.datasource#">
				UPDATE 	Template_Codes
				SET		Template_Code = '#arguments.compName#',
						Template_Code_Desc = '#arguments.compNameDesc#',
						External_ID = '#arguments.externalID#'
				WHERE	Template_Code_Id = #arguments.compId#
			</cfquery>
		
		</cfif>
		
		<cfreturn bCompNameExists />
		
   	</cffunction>
   
	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">	
   
   		<cfargument name="nameID" type="numeric" required="false" default="" />
			
		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Template_Codes
			WHERE 	Template_Code_Id = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
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