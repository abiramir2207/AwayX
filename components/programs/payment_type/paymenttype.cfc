<cfcomponent>

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
<!----------------------------------------------------------------------------- 
    Dev Notes: D18281 - Solo - Add new closing method on billback entry	
  	Added the fields from Billback_Closing_Methods table in select, insert and 
    update statements as the closing method values now come from the DB based on 
    the settings in the settings panel 
  -Anand Rao/29-May-09
------------------------------------------------------------------------------>
   <cffunction name="get" output="false" returntype="query">
   		<cfargument name="id" type="numeric" required="false" default="0" />
   
		<cfquery name="qGetPaymentTypes" datasource="#application.datasource#">
			SELECT	Payment_Type_ID,
					Payment_Type_Name,
					Is_Auto_Pay,
					Off_Invoice,
					Restrict_From_Billback,
					Program_Lock_Type_ID,
					Include_Claim_Rates_Report,
					Include_Pricing_Report,
          Billback_Closing_Method_ID          
			FROM 	Payment_Type
			WHERE 	Deleted = 0
			<cfif arguments.id>
			AND		Payment_Type_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER" />
			</cfif>
			ORDER BY 	Payment_Type_Name
		</cfquery>

		<cfreturn qGetPaymentTypes />
		
   	</cffunction>
	
	 <cffunction name="getDesc" output="false" returntype="string">
   		<cfargument name="id" type="numeric" required="false" default="0" />
   
		<cfset qGetPaymentTypes = get(arguments.id) />

		<cfreturn qGetPaymentTypes.Payment_Type_Name />
		
   	</cffunction>
	
	<cffunction name="getActive" output="false" returntype="query">
   
		<cfset useLakebaseForqGetActiveComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_type")>
<cfif useLakebaseForqGetActiveComps>
	<cftry>
		<cfset qGetActiveComps = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_type", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"order" = "payment_type_name.asc",
				"select" = "payment_type_id,payment_type_name,is_auto_pay,off_invoice,restrict_from_billback,program_lock_type_id,include_claim_rates_report,include_pricing_report,billback_closing_method_id"
			}), "payment_type_id,payment_type_name,is_auto_pay,off_invoice,restrict_from_billback,program_lock_type_id,include_claim_rates_report,include_pricing_report,billback_closing_method_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveComps>
<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Payment_Type_ID,
					Payment_Type_Name,
					Is_Auto_Pay,
					Off_Invoice,
					Restrict_From_Billback,
					Program_Lock_Type_ID,
					Include_Claim_Rates_Report,
					Include_Pricing_Report,
          Billback_Closing_Method_ID
			FROM 	Payment_Type
			WHERE 	Deleted = 0
			AND		Active = 1
			ORDER BY 	Payment_Type_Name
		</cfquery>
</cfif>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="getComp" output="false" returntype="query">	
   
   		<cfargument name="compId" required="false" default=0 />
		
		<cfset useLakebaseForqGetComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_type")>
<cfif useLakebaseForqGetComp>
	<cftry>
		<cfset qGetComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_type", {
				"payment_type_id" = "eq.#arguments.compId#",
				"select" = "payment_type_id,payment_type_name,is_auto_pay,off_invoice,restrict_from_billback,program_lock_type_id,include_claim_rates_report,include_pricing_report,last_edited_by,last_edited_date,billback_closing_method_id"
			}), "payment_type_id,payment_type_name,is_auto_pay,off_invoice,restrict_from_billback,program_lock_type_id,include_claim_rates_report,include_pricing_report,last_edited_by,last_edited_date,billback_closing_method_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetComp>
<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	Payment_Type_ID,
					Payment_Type_Name,
					Is_Auto_Pay, 
					Off_Invoice,
					Restrict_From_Billback,
					Program_Lock_Type_ID,
					Include_Claim_Rates_Report,
					Include_Pricing_Report,
					Last_Edited_By,
					Last_Edited_Date,
          Billback_Closing_Method_ID
			FROM 	Payment_Type
			WHERE 	Payment_Type_ID = #arguments.compId#	
		</cfquery>
</cfif>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	<cffunction name="getCompFromList" output="false" returntype="query">	
   
   		<cfargument name="compIdList" type="string" required="true" />
		
		<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	Payment_Type_ID,
					Payment_Type_Name,
					Is_Auto_Pay 
			FROM 	Payment_Type
			WHERE 	Payment_Type_ID IN (#arguments.compIdList#)
		</cfquery>

		<cfreturn qGetComp />
		
   	</cffunction>
	
	
	<cffunction name="getInActive" output="false" returntype="query">	
   
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 	Payment_Type_ID,
					Payment_Type_Name,
					Is_Auto_Pay,
					Off_Invoice,
					Restrict_From_Billback,
					Program_Lock_Type_ID,
					Include_Claim_Rates_Report,
					Include_Pricing_Report,
          Billback_Closing_Method_ID
			FROM 	Payment_Type
			WHERE 	Deleted = 0
			AND		Active = 0
			ORDER BY Payment_Type_Name
		</cfquery>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="add" output="false" hint="Function used to add a new component.">
	
		<cfargument name="componentName" required="false" default="" />	
		<cfargument name="componentDesc" required="false" default="" />	
		<cfargument name="Off_Invoice" required="false" default="0" />	
		<cfargument name="Restrict_From_Billback" required="false" default="" />	
		<cfargument name="User_ID" required="false" default="" />
		<cfargument name="Program_Lock_Type_ID" required="false" default="0" />	
		<cfargument name="Include_Claim_Rates_Report" required="false" default="0" />
		<cfargument name="Include_Pricing_Report" required="false" default="0" />
 		<cfargument name="BBClosingMethod" required="false" default="0" />

		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Payment_Type_ID, Payment_Type_Name
			FROM	Payment_Type
			WHERE	Payment_Type_Name = '#trim(arguments.componentName)#'
			AND		deleted = 0
		</cfquery>
		
		<cfif not qGetActiveComps.RecordCount>
			
			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SET NOCOUNT ON 
				INSERT INTO	Payment_Type
					(Payment_Type_Name, Is_Auto_Pay, Created_Date, Off_Invoice, Restrict_From_Billback, Include_Claim_Rates_Report, Include_Pricing_Report, Last_Edited_By, Last_Edited_Date, Program_Lock_Type_ID, Billback_Closing_Method_ID)
				VALUES
					('#arguments.componentName#', '#arguments.componentDesc#', getdate(),
					<cfqueryparam value="#arguments.Off_Invoice#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Restrict_From_Billback#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Include_Claim_Rates_Report#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.Include_Pricing_Report#" cfsqltype="CF_SQL_INTEGER">,
					<cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
					getdate(),
					<cfqueryparam value="#arguments.Program_Lock_Type_ID#" cfsqltype="CF_SQL_INTEGER">,
          <cfif arguments.componentDesc EQ 1>
            <cfqueryparam value="#arguments.BBClosingMethod#" cfsqltype="CF_SQL_INTEGER">
          <cfelse>
            0
          </cfif>
					)
				SELECT Payment_Type_ID = @@IDENTITY 
				SET NOCOUNT OFF
			</cfquery>
			
		</cfif>
	
		<cfreturn qGetActiveComps.Payment_Type_ID />
		
   	</cffunction>
	
	<cffunction name="deactivate" output="false" hint="Function used to deactivate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Payment_Type
			SET		Active = 0
			WHERE	Payment_Type_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="activate" output="false" hint="Function used to activate components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Payment_Type
			SET		Active = 1
			WHERE	Payment_Type_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="delete" output="false" hint="Function used to delete components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Payment_Type
			SET		Deleted = 1
			WHERE	Payment_Type_ID IN(#arguments.compIds#)
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="update" output="false" hint="Function used to update components." returntype="boolean">
	
		<cfargument name="compId" required="false" default="" />
		<cfargument name="compName" required="false" default="" />	
		<cfargument name="compDesc" required="false" default="" />
		<cfargument name="Off_Invoice" required="false" default="0" />	
		<cfargument name="Restrict_From_Billback" required="false" default="" />	
		<cfargument name="User_ID" required="false" default="" />
		<cfargument name="Program_Lock_Type_ID" required="false" default="1" />
		<cfargument name="Include_Claim_Rates_Report" required="false" default="0" />
		<cfargument name="Include_Pricing_Report" required="false" default="0" />
 		<cfargument name="BBClosingMethod" required="false" default="0" />
   		
		<cfset bCompNameExists = false />		
				
		<!---check to see if the name already exists--->		
		<cfquery name="qCheckCompNames" datasource="#application.datasource#">
			SELECT	*
			FROM	Payment_Type
			WHERE	Payment_Type_Name = '#trim(arguments.compName)#'
			AND		Payment_Type_ID != #arguments.compId#		
			AND		deleted = 0
		</cfquery>
				
		<!---If the name exists then set does not exist to false--->
		<cfif qCheckCompNames.RecordCount>
		
			<cfset bCompNameExists = true />
			
		<cfelse>
		
			<cfquery datasource="#application.datasource#">
				UPDATE 	Payment_Type
				SET		Payment_Type_Name = '#arguments.compName#',
						Is_Auto_Pay = '#arguments.compDesc#',
						Off_Invoice = <cfqueryparam value="#arguments.Off_Invoice#" cfsqltype="CF_SQL_INTEGER">,
						Restrict_From_Billback = <cfqueryparam value="#arguments.Restrict_From_Billback#" cfsqltype="CF_SQL_INTEGER">,
						Last_Edited_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Last_Edited_Date = getdate(),
						Program_Lock_Type_ID = <cfqueryparam value="#arguments.Program_Lock_Type_ID#" cfsqltype="CF_SQL_INTEGER">,
						Include_Claim_Rates_Report = <cfqueryparam value="#arguments.Include_Claim_Rates_Report#" cfsqltype="CF_SQL_INTEGER">,
						Include_Pricing_Report = <cfqueryparam value="#arguments.Include_Pricing_Report#" cfsqltype="CF_SQL_INTEGER">,
            <cfif arguments.compDesc EQ 1>
            Billback_closing_method_id = <cfqueryparam value="#arguments.BBClosingMethod#" cfsqltype="CF_SQL_INTEGER">
            <cfelse>
            Billback_closing_method_id = 0
            </cfif>
				WHERE	Payment_Type_ID = #arguments.compId#
			</cfquery>
		
		</cfif>
		
		<cfreturn bCompNameExists />
		
   	</cffunction>
   
	<cffunction name="canDelete" output="false" returntype="boolean" hint="Function used to verify if a component can be deleted or not.">	
   
   		<cfargument name="nameID" type="numeric" required="false" default="" />
			
		<cfquery name="qCheckCompName" datasource="#application.datasource#">
			SELECT 	count(*) as count
			FROM 	Payment_Type
				INNER JOIN Payment_Template_Mapping
				ON Payment_Template_Mapping.Payment_Type_ID = Payment_Type.Payment_Type_ID
				AND 	Payment_Template_Mapping.Deleted = 0
				INNER JOIN Program_Control_Panel_Options
				ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Payment_Template_Mapping.Template_ID
			WHERE 	Payment_Type.Payment_Type_ID = <cfqueryparam value="#arguments.nameID#" cfsqltype="CF_SQL_INTEGER" />
			AND 	Payment_Type.deleted = 0 
		</cfquery>
		
		<!---if we get a count back from qCheckCompName then set canDelete to false--->
		<cfif qCheckCompName.count>
			<cfset bCanDelete = false />
		<cfelse>
			<cfset bCanDelete = true />
		</cfif>
		
		<cfreturn bCanDelete />
		
   </cffunction>

	<cffunction name="GetPaymentTypesforTemplate" output="false" returntype="query">	
   
   		<cfargument name="Template_ID" type="numeric" required="true" />
		<cfargument name="Discount_Type_ID" type="numeric" required="true" />
		<cfargument name="Component_Name_ID" type="numeric" required="true" />
		<cfargument name="Allow_Off_Invoice" type="boolean" required="true" />
		<cfargument name="Allow_Auto_Payment" type="boolean" required="true" />
		<cfargument name="bAllowLSAutoPay" 	type="boolean" required="true" default="0" />
		<cfargument name="Auto_Pay" type="boolean" required="false" default="0"><!--- D35731 Growth Auto Pay --->	
		<cfset bAllowLSAutoPay = application.appsettingsGet.getBBAutoPayLumpSum() />
			
		<cfquery name="GetPaymentTypesforTemplate" datasource="#application.datasource#">
			SELECT DISTINCT Payment_Type.Payment_Type_Name, Payment_Type.Payment_Type_ID, Payment_Type.Is_Auto_pay
			FROM Payment_Template_Mapping 
			INNER JOIN Payment_Type
				ON Payment_Type.Payment_Type_ID = Payment_Template_Mapping.Payment_Type_ID 
			<cfif arguments.Discount_Type_ID neq "">
			<cfif arguments.Discount_Type_ID eq 1>
			INNER JOIN Program_Fixed_Component_Name
				ON Program_Fixed_Component_Name.Off_Invoice_On = Payment_Type.Off_Invoice
			WHERE Program_Fixed_Component_Name_ID = '#arguments.Component_Name_ID#'
			<cfelseif arguments.Discount_Type_ID eq 2>
			INNER JOIN Program_Rebates_Component_Name
			ON Program_Rebates_Component_Name.Off_Invoice_On = Payment_Type.Off_Invoice
			WHERE Program_Rebates_Component_Name_ID = '#arguments.Component_Name_ID#'
			<!--- D17644 legacy <cfelseif Attributes.Discount_Type_ID eq 4 OR Attributes.Discount_Type_ID eq 3>
			AND Payment_Type.Off_Invoice = '#Attributes.Allow_Off_Invoice#' --->
		    
		    <!--- D17644 RBL 12/4/08 [begin] --->
			<cfelseif arguments.Discount_Type_ID eq 3 >
			AND Payment_Type.Off_Invoice = '#arguments.Allow_Off_Invoice#'
			<cfif bAllowLSAutoPay EQ 0 >
				AND Payment_Type.Is_Auto_Pay = 0
			</cfif>
		    <cfelseif arguments.Discount_Type_ID eq 4>
			AND Payment_Type.Off_Invoice = '#arguments.Allow_Off_Invoice#'
		    <!--- D17644 RBL 12/4/08 [end] --->
				<!--- D35731 Growth Auto Pay START--->	
					<cfif arguments.Auto_Pay>
					AND Payment_Type.Is_Auto_Pay = 1
					</cfif>
				<!--- D35731 Growth Auto Pay END--->	
			</cfif>
			</cfif>
			AND Payment_Template_Mapping.Template_ID = '#arguments.Template_ID#'
			AND Payment_Template_Mapping.Deleted = 0
		
			<!---Restrict Auto Payment--->
			<cfif arguments.Allow_Auto_Payment eq 0>
			AND Payment_Type.Is_Auto_Pay != 1
			</cfif>
			ORDER BY Payment_Type.Payment_Type_Name
		</cfquery>
		
		<cfreturn GetPaymentTypesforTemplate />
		
   </cffunction>
   
</cfcomponent>