<cfcomponent>

	<cffunction name="discountIdentifierOn" output="false" returntype="boolean">	
   
   		<cfset returnValue = 0>
		
		<cfif application.returned_customer_setting.discount_identifier_on EQ 1>
		
			<cfquery name="qGetGeneralSettings" datasource="#application.datasource#">
				SELECT 	TOP 1 	Use_Discount_ID
				FROM 	General_Settings
			</cfquery>
		
			<cfif qGetGeneralSettings.Use_Discount_ID>
				<cfset returnValue = 1>
			</cfif>
			
		</cfif>

		<cfreturn returnValue />
		
   	</cffunction>

   <cffunction name="set" output="false" returntype="struct">	
   
	  <cfargument name="compID" type="string" required="true" default="">	
		<cfargument name="compNameId" type="string" required="true" default="">
		<cfargument name="programID" type="numeric" required="true" default=0>
		<cfargument name="compName" type="string" required="true" default="">
		<cfargument name="compDesc" type="string" required="true" default="">
		<cfargument name="compUUID" type="string" required="true" default="#CreateUUID()#">
   
   		<cfscript>
		
			tmpStruct = structNew();
			tmpStruct.compID = arguments.compID;
			tmpStruct.compNameId = arguments.compNameId;
			tmpStruct.programID = arguments.programID;
			tmpStruct.compName = arguments.compName;
			tmpStruct.compDesc = arguments.compDesc;
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
   		<cfargument name="useCache" required="false" type="numeric" default="0">

		<cfset cacheSpan = CreateTimeSpan(0, 0, 0, 0) />
		<cfif arguments.useCache EQ 1>
			<cfset cacheSpan = CreateTimeSpan(0, 12, 0, 0) />
		</cfif>
			<!--- 
	    Dev Notes: 22308/Anand Rao/04-Feb-10
	    CAG - multi discount type template/ Added 4 columns to the select statements
      --->
		<cfquery name="qGetActiveComps" datasource="#application.datasource#" cachedwithin="#cacheSpan#">
			SELECT 	Discount_Identifier_ID,
					Discount_Identifier_Number,
					Discount_Identifier_Desc,
					IsDefault,
					External_Component_Type,
					External_Customer_Type_ID,
              		Interface_For_FixedPrice,
              		Interface_For_Rebate,
              		Interface_For_LumpSum,
              		Interface_For_Growth,
			  		External_FixedPrice_Component_Type,
					External_Rebate_Component_Type,
					External_LumpSum_Component_Type,
					External_Growth_Component_Type
			FROM 	Discount_Identifier
			WHERE 	Deleted = 0
			AND		Active = 1
			ORDER BY 	Discount_Identifier_Desc
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="getComp" output="false" returntype="query">	
   
   		<cfargument name="compId" required="false" default=0 />
		
		<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	Discount_Identifier_ID,
					Discount_Identifier_Number,
					Discount_Identifier_Desc,
					IsDefault,
					External_Component_Type,
					External_Customer_Type_ID,
              		Interface_For_FixedPrice,
              		Interface_For_Rebate,
              		Interface_For_LumpSum,
              		Interface_For_Growth,
					External_FixedPrice_Component_Type,
					External_Rebate_Component_Type,
					External_LumpSum_Component_Type,
					External_Growth_Component_Type
			FROM 	Discount_Identifier
			WHERE 	Discount_Identifier_ID = #arguments.compId#	
		</cfquery>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	<cffunction name="getCompFromList" output="false" returntype="query">	
   
   		<cfargument name="compIdList" type="string" required="true" />
		
		<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	Discount_Identifier_ID,
					Discount_Identifier_Number,
					Discount_Identifier_Desc,
					IsDefault,
					External_Component_Type,
					External_Customer_Type_ID,
              		Interface_For_FixedPrice,
              		Interface_For_Rebate,
              		Interface_For_LumpSum,
              		Interface_For_Growth,
			  		External_FixedPrice_Component_Type,
					External_Rebate_Component_Type,
					External_LumpSum_Component_Type,
					External_Growth_Component_Type
			FROM 	Discount_Identifier
			WHERE 	Discount_Identifier_ID IN (#arguments.compIdList#)
		</cfquery>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	
	<cffunction name="getInActive" output="false" returntype="query">	
   
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Discount_Identifier_ID,
					Discount_Identifier_Number,
					Discount_Identifier_Desc,
					IsDefault,
					External_Component_Type,
					External_Customer_Type_ID,
					Interface_For_FixedPrice,
					Interface_For_Rebate,
					Interface_For_LumpSum,
					Interface_For_Growth
			FROM 	Discount_Identifier
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Discount_Identifier_Desc
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="add" output="false" hint="Function used to add a new component.">
	
		<cfargument name="componentName" required="false" default="" />	
		<cfargument name="componentDesc" required="false" default="" />
		<cfargument name="externalComponentType" required="false" default="" />
		<cfargument name="externalCustomerType" required="false" default="0" />
    	<cfargument name="infFixedPrice" required="false" default="" />	
   	 	<cfargument name="infRebate" required="false" default="" />
    	<cfargument name="infLumpSum" required="false" default="" />
    	<cfargument name="infGrowth" required="false" default="" />
		<cfargument name="externalFixedPriceComponentType" required="false" default="" /> 
		<cfargument name="externalRebateComponentType" required="false" default="" /> 
		<cfargument name="externalLumpSumComponentType" required="false" default="" /> 
		<cfargument name="externalGrowthComponentType" required="false" default="" /> 
    
		
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Discount_Identifier_Number
			FROM	Discount_Identifier
			WHERE	Discount_Identifier_Number = '#trim(arguments.componentName)#'
			AND		deleted = 0
		</cfquery>
		
		<cfif not qGetActiveComps.RecordCount>
			<!--- 
	    Dev Notes: 22308/Anand Rao/04-Feb-10
	    CAG - multi discount type template/ Added 4 columns to the insert statement
      --->

			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
				SET NOCOUNT ON 
				INSERT INTO	Discount_Identifier
				(
					Discount_Identifier_Number, 
				  	Discount_Identifier_Desc, 
				  	External_Component_Type, 
				  	External_Customer_Type_ID, 
				  	Interface_For_FixedPrice, 
				  	Interface_For_Rebate, 
				  	Interface_For_LumpSum, 
				  	Interface_For_Growth, 
					External_FixedPrice_Component_Type,
					External_Rebate_Component_Type,
					External_LumpSum_Component_Type,
					External_Growth_Component_Type,
				  	Created_Date
				)
				VALUES
				(
					<cfqueryparam value = "#arguments.componentName#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value = "#arguments.componentDesc#" cfsqltype="cf_sql_varchar" />,
				  	<cfqueryparam value = "#arguments.externalComponentType#" cfsqltype="cf_sql_varchar" />,
				  	<cfqueryparam value = "#arguments.externalCustomerType#" cfsqltype="cf_sql_integer" />,
				  	<cfqueryparam value = "#arguments.infFixedPrice#" cfsqltype="cf_sql_varchar" />,
				  	<cfqueryparam value = "#arguments.infRebate#" cfsqltype="cf_sql_varchar" />,
				  	<cfqueryparam value = "#arguments.infLumpSum#" cfsqltype="cf_sql_varchar" />,
				  	<cfqueryparam value = "#arguments.infGrowth#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value = "#arguments.externalFixedPriceComponentType#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value = "#arguments.externalRebateComponentType#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value = "#arguments.externalLumpSumComponentType#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value = "#arguments.externalGrowthComponentType#" cfsqltype="cf_sql_varchar" />,
				  	<cfqueryparam value = "#Now()#" cfsqltype="cf_sql_date" />
				)
				SELECT Discount_Identifier_ID = @@IDENTITY 
				SET NOCOUNT OFF				
			</cfquery>
			
			<cfreturn qGetActiveComps.Discount_Identifier_ID />
			
		</cfif>
	
		<cfreturn 0 />
		
   	</cffunction>
	
	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Discount_Identifier
			SET		Active = 0
			WHERE	Discount_Identifier_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="activate" output="false" hint="Function used to activate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Discount_Identifier
			SET		Active = 1
			WHERE	Discount_Identifier_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="delete" output="false" hint="Function used to delete components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Discount_Identifier
			SET		Deleted = 1
			WHERE	Discount_Identifier_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="update" output="false" hint="Function used to update components." returntype="boolean">
	
		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />	
		<cfargument name="compDesc" required="false" default="" />
		<cfargument name="externalComponentType" required="false" default="" />
		<cfargument name="externalCustomerType" required="false" default="0" />
    	<cfargument name="infFixedPrice" required="false" default="" />	
    	<cfargument name="infRebate" required="false" default="" />
    	<cfargument name="infLumpSum" required="false" default="" />
    	<cfargument name="infGrowth" required="false" default="" />
		<cfargument name="externalFixedPriceComponentType" required="false" default="" /> 
		<cfargument name="externalRebateComponentType" required="false" default="" /> 
		<cfargument name="externalLumpSumComponentType" required="false" default="" /> 
		<cfargument name="externalGrowthComponentType" required="false" default="" /> 
   		
		<cfset bCompNameExists = false />		
				
		<!---check to see if the name already exists--->		
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Discount_Identifier
			WHERE	Discount_Identifier_Number = '#trim(arguments.compName)#'
			AND		Discount_Identifier_ID != #arguments.compId#		
			AND		deleted = 0
		</cfquery>
		
<!--- 		<cfdump var="#qCheckCompNames#"> --->
				
		<!---If the name exists then set does not exist to false--->
		<cfif qCheckCompNames.RecordCount>
		
			<cfset bCompNameExists = true />
			
		<cfelse>
		
			<cfquery datasource="#application.datasource#">
				UPDATE 	Discount_Identifier
				SET		Discount_Identifier_Number 			= <cfqueryparam value = "#arguments.compName#" cfsqltype="cf_sql_varchar" />,
						Discount_Identifier_Desc   			= <cfqueryparam value = "#arguments.compDesc#" cfsqltype="cf_sql_varchar" />,
						External_Component_Type    			= <cfqueryparam value = "#arguments.externalComponentType#" cfsqltype="cf_sql_varchar" />,
						External_Customer_Type_ID  			= <cfqueryparam value = "#arguments.externalCustomerType#" cfsqltype="cf_sql_integer" />,
              			Interface_For_FixedPrice   			= <cfqueryparam value = "#arguments.infFixedPrice#" cfsqltype="cf_sql_varchar" />,
              			Interface_For_Rebate       			= <cfqueryparam value = "#arguments.infRebate#" cfsqltype="cf_sql_varchar" />,
              			Interface_For_LumpSum     	 		= <cfqueryparam value = "#arguments.infLumpSum#" cfsqltype="cf_sql_varchar" />,
              			Interface_For_Growth       			= <cfqueryparam value = "#arguments.infGrowth#" cfsqltype="cf_sql_varchar" />,
						External_FixedPrice_Component_Type 	= <cfqueryparam value = "#arguments.externalFixedPriceComponentType#" cfsqltype="cf_sql_varchar" />,
						External_Rebate_Component_Type 		= <cfqueryparam value = "#arguments.externalRebateComponentType#" cfsqltype="cf_sql_varchar" />,
						External_LumpSum_Component_Type 	= <cfqueryparam value = "#arguments.externalLumpSumComponentType#" cfsqltype="cf_sql_varchar" />,
						External_Growth_Component_Type 		= <cfqueryparam value = "#arguments.externalGrowthComponentType#" cfsqltype="cf_sql_varchar" />
				WHERE	Discount_Identifier_ID     			= <cfqueryparam value = "#arguments.compId#" cfsqltype="cf_sql_integer" />
			</cfquery>
		
		</cfif>
		
		<cfreturn bCompNameExists />
		
   	</cffunction>
   
	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">	
   
   		<cfargument name="nameID" type="numeric" required="false" default="" />
			
		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Discount_Identifier
				INNER JOIN Program_Control_Panel_Options
				ON Program_Control_Panel_Options.Discount_Identifier_ID = Discount_Identifier.Discount_Identifier_ID
			WHERE 	Discount_Identifier.Discount_Identifier_ID = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
			AND 	Discount_Identifier.deleted = 0 
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