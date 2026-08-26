<cfcomponent>

   <cffunction name="set" output="false" returntype="struct">	
   
	  	<cfargument name="compID" type="string" required="true" default="">	
		<cfargument name="compNameId" type="string" required="true" default="">
		<cfargument name="programID" type="numeric" required="true" default=0>
		<cfargument name="compName" type="string" required="true" default="">
		<cfargument name="compDesc" type="string" required="true" default="">
		<cfargument name="compFlag" type="string" required="true" default="">
		<cfargument name="compBillback" type="boolean" required="true" default="1">
		<cfargument name="compUUID" type="string" required="true" default="#CreateUUID()#">
   
   		<cfscript>
		
			tmpStruct = structNew();
			tmpStruct.compID = arguments.compID;
			tmpStruct.compNameId = arguments.compNameId;
			tmpStruct.programID = arguments.programID;
			tmpStruct.compName = arguments.compName;
			tmpStruct.compDesc = arguments.compDesc;
			tmpStruct.compFlag = arguments.compFlag;
			tmpStruct.compBillback = arguments.compBillback;
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
   
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Accounting_Program_Type_ID,
					APT_Name,
					APT_Reference_Number,
					APT_Use_for_TPA,
					APT_Allow_Billbacks
			FROM 	Accounting_Program_Type
			WHERE 	Deleted = 0
			AND		Active = 1
			ORDER BY 	APT_Name
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="getComp" output="false" returntype="query">	
   
   		<cfargument name="compId" required="false" default=0 />
		
		<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 
					APT_Name,
					APT_Reference_Number,
					APT_Use_for_TPA,
					APT_Allow_Billbacks
			FROM 	Accounting_Program_Type
			WHERE 	Accounting_Program_Type_ID = #arguments.compId#	
		</cfquery>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	<cffunction name="getCompFromList" output="false" returntype="query">	
   
   		<cfargument name="compIdList" type="string" required="true" />
		
		<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	Accounting_Program_Type_ID,
					APT_Name,
					APT_Reference_Number,
					APT_Use_for_TPA,
					APT_Allow_Billbacks
			FROM 	Accounting_Program_Type
			WHERE 	Accounting_Program_Type_ID IN (#arguments.compIdList#)
		</cfquery>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	
	<cffunction name="getInActive" output="false" returntype="query">	
   
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	Accounting_Program_Type_ID,
					APT_Name,
					APT_Reference_Number,
					APT_Use_for_TPA,
					APT_Allow_Billbacks
			FROM 	Accounting_Program_Type
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY APT_Name
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="add" output="false" hint="Function used to add a new component.">
	
		<cfargument name="componentName" required="false" default="" />	
		<cfargument name="componentDesc" required="false" default="" />	
		<cfargument name="componentFlag" required="false" default="" />
		<cfargument name="componentBillbacks" required="false" default="" />
				
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Accounting_Program_Type_ID,
					APT_Name,
					APT_Allow_Billbacks
			FROM	Accounting_Program_Type
			WHERE	APT_Name = '#trim(arguments.componentName)#'
			AND		deleted = 0
		</cfquery>
		
		<cfif not qGetActiveComps.RecordCount>
			
			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SET NOCOUNT ON 
				INSERT INTO	Accounting_Program_Type
					(APT_Name, APT_Reference_Number, APT_Use_for_TPA, APT_Allow_Billbacks, Created_Date)
				VALUES
					('#arguments.componentName#', '#arguments.componentDesc#', '#arguments.componentFlag#', '#arguments.componentBillbacks#', #Now()#)
				SELECT Accounting_Program_Type_ID = @@IDENTITY 
				SET NOCOUNT OFF
			</cfquery>
			
		</cfif>
	
		<cfreturn qGetActiveComps.Accounting_Program_Type_ID />
		
   	</cffunction>
	
	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Accounting_Program_Type
			SET		Active = 0
			WHERE	Accounting_Program_Type_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="activate" output="false" hint="Function used to activate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Accounting_Program_Type
			SET		Active = 1
			WHERE	Accounting_Program_Type_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="delete" output="false" hint="Function used to delete components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Accounting_Program_Type
			SET		Deleted = 1
			WHERE	Accounting_Program_Type_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="update" output="false" hint="Function used to update components." returntype="boolean">
	
		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />	
		<cfargument name="compDesc" required="false" default="" />
   		<cfargument name="compFlag" required="false" default="" />
		<cfargument name="compBillbacks" required="false" default="" />
		<cfset bCompNameExists = false />		
				
		<!---check to see if the name already exists--->		
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Accounting_Program_Type
			WHERE	APT_Name = '#trim(arguments.compName)#'
			AND		Accounting_Program_Type_ID != #arguments.compId#		
			AND		deleted = 0
		</cfquery>
				
		<!---If the name exists then set does not exist to false--->
		<cfif qCheckCompNames.RecordCount>
		
			<cfset bCompNameExists = true />
			
		<cfelse>
	
			<cfquery datasource="#application.datasource#">
				UPDATE 	Accounting_Program_Type
				SET		APT_Name = '#arguments.compName#',
						APT_Reference_Number = '#arguments.compDesc#',
						APT_Use_for_TPA = '#arguments.compFlag#',
						APT_Allow_Billbacks = '#arguments.compBillbacks#'						
				WHERE	Accounting_Program_Type_ID = #arguments.compId#
			</cfquery>
		
		</cfif>
		
		<cfreturn bCompNameExists />
		
   	</cffunction>
   
	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">	
   
   		<cfargument name="nameID" type="numeric" required="false" default="" />
			
		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Accounting_Program_Type
				INNER JOIN APT_Template_Mapping
				ON APT_Template_Mapping.Accounting_Program_Type_ID = Accounting_Program_Type.Accounting_Program_Type_ID
				AND 	APT_Template_Mapping.Deleted = 0
				INNER JOIN Program_Control_Panel_Options
				ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = APT_Template_Mapping.Template_ID
			WHERE 	Accounting_Program_Type.Accounting_Program_Type_ID = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
			AND 	Accounting_Program_Type.deleted = 0 
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