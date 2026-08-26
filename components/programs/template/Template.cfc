<!--- 
FILE: 		
FILENAME: 	components\programs\templates\Template.cfc
CREATED: 	??/??/200? - ??
EDITED:		10/14/2008 - RBL [17289 > 16314: Margin Analysis - Add Contract Price - follow-up]

FUNCTIONALITY: 
DEPENDENCIES:

--->

<cfcomponent hint="Program Template" extends="components.Base">

	<cfproperty name="TemplateFilters" type="array" />
	<cfproperty name="Specify_Operators" type="boolean" />
	
	<cfset this.id 					= 0 />
	<cfset this.genericType			= "" />
	<cfset this.createdType			= "" />
	<cfset this.allowDuplicate		= 0 />
    <!--- 17289 > 16314 follow up (Discount_Fixed_Prices) [begin] --->
    <cfset this.Discount_Fixed_Prices = 0 />
    <!--- 17289 > 16314 follow up (Discount_Fixed_Prices) [end] --->
	<cfset this.duplicate_program_action = 0 />
	<cfset this.dupAction = 0 />
	<cfset this.revisionNotAllowed = 0 />
	<cfset this.EZButton_On = 0 />
	<cfset this.EZ_Contract_Id = 0 />
	<cfset this.EZprogram_editcomponent = 0 />
	<cfset this.Pullbacks_On = 0>
	<cfset this.iscorporatedeal = 0 />
	<cfset this.BB_D_Purchase_Period_OverRide = 0 />
	<cfset this.Discount_Fixed_Freight = 0>
	<cfset this.FirstParentID = 0>
	<cfset this.TemplateParentID = 0>
	<cfset this.Market_Price = 0>
	<cfset this.TemplateFilters = arrayNew(1)>
	<cfset this.Specify_Operators = 0>

	<cffunction name="init" output="false" returntype="components.programs.template.Template">
		
		<cfreturn this />
		
	</cffunction>
	
	
	<!--- id setter--->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" type="numeric" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter--->
	<cffunction name="getId" access="public" returntype="string" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- genericType setter--->
	<cffunction name="setGenericType" access="public" output="false">
		<cfargument name="genericType" type="string" required="true" />
		<cfset this.genericType = arguments.genericType />
	</cffunction>
	<!--- genericType getter--->
	<cffunction name="getGenericType" access="public" returntype="string" output="false">
		<cfreturn this.genericType />
	</cffunction>
	
	<!--- createdType setter--->
	<cffunction name="setCreatedType" access="public" output="false">
		<cfargument name="createdType" type="string" required="true" />
		<cfset this.createdType = arguments.createdType />
	</cffunction>
	<!--- createdType getter--->
	<cffunction name="getCreatedType" access="public" returntype="string" output="false">
		<cfreturn this.createdType />
	</cffunction>
	
	<!--- active setter--->
	<cffunction name="setActive" access="public" output="false">
		<cfargument name="active" type="string" required="true" />
		<cfset this.active = arguments.active />
	</cffunction>
	<!--- active getter--->
	<cffunction name="getActive" access="public" returntype="string" output="false">
		<cfreturn this.active />
	</cffunction>

    <!--- 17289 > 16314 follow up (Discount_Fixed_Prices) [begin] --->
    <!--- set flag for displaying fixed_pricing --->
	<cffunction name="setDiscount_Fixed_Prices" access="public" output="false">
		<cfargument name="Discount_Fixed_Prices" type="boolean" required="true" />
		<cfset this.Discount_Fixed_Prices = arguments.Discount_Fixed_Prices />
	</cffunction>
	<!--- retrieve flag for displaying fixed_pricing --->
	<cffunction name="getDiscount_Fixed_Prices" access="public" returntype="boolean" output="false">
		<cfreturn this.Discount_Fixed_Prices />
	</cffunction>
    <!--- 17289 > 16314 follow up (Discount_Fixed_Prices) [end] --->

	<!--- set flag for check duplicate program--->
	<cffunction name="setDuplicate" access="public" output="false">
		<cfargument name="duplicate" type="string" required="true" />
		<cfset this.allowDuplicate = arguments.duplicate />
	</cffunction>
	<!--- retrieve check duplicate program flag--->
	<cffunction name="getDuplicate" access="public" returntype="string" output="false">
		<cfreturn this.allowDuplicate />
	</cffunction>
	<!--- set flag for check duplicate action--->
	<cffunction name="setDupAction" access="public" output="false">
		<cfargument name="dupAction" type="string" required="true" />
		<cfset this.duplicate_program_action = arguments.dupAction />
	</cffunction>
	<!--- retrieve check duplicate program action--->
	<cffunction name="getDupAction" access="public" returntype="string" output="false">
		<cfreturn this.duplicate_program_action />
	</cffunction>
	<!--- set flag for revisionNotAllowed --->
	<cffunction name="setRevisionNotAllowed" access="public" output="false">
		<cfargument name="revisionNotAllowed" type="string" required="true" />
		<cfset this.revisionNotAllowed = arguments.revisionNotAllowed />
	</cffunction>
	<!--- retrieve revisionNotAllowed --->
	<cffunction name="getRevisionNotAllowed" access="public" returntype="string" output="false">
		<cfreturn this.revisionNotAllowed />
	</cffunction>
	
			<!--- set flag for EZ Button --->
	<cffunction name="setEZButtonOn" access="public" output="false">
		<cfargument name="EZButton_On" type="string" required="true" />
		<cfset this.EZButton_On = arguments.EZButton_On />
	</cffunction>
	<!--- retrieve EZ Button --->
	<cffunction name="getEZButtonOn" access="public" returntype="string" output="false">
		<cfreturn this.EZButton_On />
	</cffunction>
	<!--- set flag for EZ Button --->
	<cffunction name="setEZContractId" access="public" output="false">
		<cfargument name="EZ_Contract_Id" type="string" required="true" />
		<cfset this.EZ_Contract_Id = arguments.EZ_Contract_Id />
	</cffunction>
	<!--- retrieve EZ Button Contract ID --->
	<cffunction name="getEZContractId" access="public" returntype="string" output="false">
		<cfreturn this.EZ_Contract_Id />
	</cffunction>
		<!--- set flag for EZ Button --->
	<cffunction name="setEZprogrameditcomponent" access="public" output="false">
		<cfargument name="EZprogram_editcomponent" type="string" required="true" />
		<cfset this.EZprogram_editcomponent = arguments.EZprogram_editcomponent />
	</cffunction>
	<!--- retrieve EZ Button Contract ID --->
	<cffunction name="getEZprogrameditcomponent" access="public" returntype="string" output="false">
		<cfreturn this.EZprogram_editcomponent />
	</cffunction>
	
		<!--- set flag for Pullbacks --->
	<cffunction name="setPullbacksOn" access="public" output="false">
		<cfargument name="Pullbacks_On" type="string" required="true" />
		<cfset this.Pullbacks_On = arguments.Pullbacks_On />
	</cffunction>
	<!--- retrieve Pullbacks --->
	<cffunction name="getPullbacksOn" access="public" returntype="string" output="false">
		<cfreturn this.Pullbacks_On />
	</cffunction>
	
		<!--- set flag for setcorporatedeal --->
	<cffunction name="setcorporatedeal" access="public" output="false">
		<cfargument name="iscorporatedeal" type="string" required="true" />
		<cfset this.iscorporatedeal = arguments.iscorporatedeal />
	</cffunction>
	<!--- retrieve setcorporatedeal --->
	<cffunction name="getcorporatedeal" access="public" returntype="string" output="false">
		<cfreturn this.iscorporatedeal />
	</cffunction>
	<!--- BBDPurchasePeriodOverRide  set and get--->
	<cffunction name="setBBDPurchasePeriodOverRide" access="public" output="false">
		<cfargument name="BB_D_Purchase_Period_OverRide" type="string" required="true" />
		<cfset this.BB_D_Purchase_Period_OverRide = arguments.BB_D_Purchase_Period_OverRide />
	</cffunction>
	<cffunction name="getBBDPurchasePeriodOverRide" access="public" returntype="string" output="false">
		<cfreturn this.BB_D_Purchase_Period_OverRide />
	</cffunction>
	
	<!--- Discount_Fixed_Freight  set and get--->
	<cffunction name="setFixedFreight" access="public" output="false">
		<cfargument name="Discount_Fixed_Freight" type="string" required="true" />
		<cfset this.Discount_Fixed_Freight = arguments.Discount_Fixed_Freight />
	</cffunction>
	<cffunction name="getFixedFreight" access="public" returntype="string" output="false">
		<cfreturn this.Discount_Fixed_Freight />
	</cffunction>
	
	<!--- FirstParentID  set and get--->
	<cffunction name="setFirstParentID" access="public" output="false">
		<cfargument name="FirstParentID" type="string" required="true" />
		<cfset this.FirstParentID = arguments.FirstParentID />
	</cffunction>
	<cffunction name="getFirstParentID" access="public" returntype="string" output="false">
		<cfreturn this.FirstParentID />
	</cffunction>
	
	<!--- TemplateParentID  set and get--->
	<cffunction name="setTemplateParentID" access="public" output="false">
		<cfargument name="TemplateParentID" type="string" required="true" />
		<cfset this.TemplateParentID = arguments.TemplateParentID />
	</cffunction>
	<cffunction name="getTemplateParentID" access="public" returntype="string" output="false">
		<cfreturn this.TemplateParentID />
	</cffunction>
  
  	<!--- DiscountRebateMaxRateOn  set and get--->
	<cffunction name="setDiscountRebateMaxRateOn" access="public" output="false">
		<cfargument name="DiscountRebateMaxRateOn" type="string" required="true" />
		<cfset this.DiscountRebateMaxRateOn = arguments.DiscountRebateMaxRateOn />
	</cffunction>
	<cffunction name="getDiscountRebateMaxRateOn" access="public" returntype="string" output="false">
		<cfreturn this.DiscountRebateMaxRateOn />
	</cffunction>

	<cffunction name="setEzButtonUpdateWithLatestTemplateSettingsOnRevise" access="public" output="false">
		<cfargument name="EzButtonUpdateWithLatestTemplateSettingsOnRevise" type="string" required="true" />
		<cfset this.EzButtonUpdateWithLatestTemplateSettingsOnRevise = arguments.EzButtonUpdateWithLatestTemplateSettingsOnRevise />
	</cffunction>
	<cffunction name="getEzButtonUpdateWithLatestTemplateSettingsOnRevise" access="public" returntype="string" output="false">
		<cfreturn this.EzButtonUpdateWithLatestTemplateSettingsOnRevise />
	</cffunction>
	
  	<!---Market Price  set and get--->
	<cffunction name="setMarketPrice" access="public" output="false">
		<cfargument name="MarketPrice" type="boolean" required="true" />
		<cfset this.MarketPrice = arguments.MarketPrice />
	</cffunction>
	<cffunction name="getMarketPrice" access="public" returntype="boolean" output="false">
		<cfreturn this.MarketPrice />
	</cffunction>
	
	<!---Template Filters  set and get--->
	<cffunction name="setTemplateFilters" access="public" output="false">
		<cfset var arrTemplateFilters = arrayNew(1) />
		<cfset var TemplateFilter = '' />
		<!--- Get all filters for this template --->
		<cfquery name="qGetTemplateFilters" datasource="#application.datasource#">
			SELECT 	Template_Filters_Id
			FROM	Template_Filters
			WHERE 	--Template_Id = #this.id# AND
					Parent_Template_Id = #this.FirstParentID# AND
					Deleted = 0	
		</cfquery>

		<cfloop query="qGetTemplateFilters">
			<!---<cflog text="template cfc id = #qGetTemplateFilters.Template_Filters_Id#"/>--->
			<cfscript>
				TemplateFilter = CreateObject("component", "mvc.models.Template.TemplateFilter").init(qGetTemplateFilters.Template_Filters_Id);
				arrayAppend(arrTemplateFilters,TemplateFilter);
			</cfscript>
		</cfloop>

		<cfset this.TemplateFilters = arrTemplateFilters />
	</cffunction>
	
	<cffunction name="getTemplateFilters" access="public" returntype="Array" output="false">
		<cfreturn this.TemplateFilters />
	</cffunction>
	

	<!--- 57305: Retail Planner/08-Mar-2016/Anand Rao --->

	<cffunction name="setPlannerProgram" access="public" output="false">
		<cfargument name="Retail_Planner" type="string" required="true" />
		<cfset this.Retail_Planner = arguments.Retail_Planner />
	</cffunction>
	<!--- retrieve Retail Planner --->
	<cffunction name="getPlannerProgram" access="public" returntype="string" output="false">
		<cfreturn this.Retail_Planner />
	</cffunction>
  
  	<!---  ADD Template Filter :: includes db insert --->
  	<cffunction name="saveTemplateFilter" access="public" output="false">
  		<cfargument name="TemplateFilter" type="mvc.Models.Template.TemplateFilter" required="true" />
		<cfscript>
			var TF = arguments.TemplateFilter;
				TF.Template_Id = this.id;
				TF.Parent_Template_Id = this.FirstParentID;
				TF.saveDB();
			//update Template Obj array of template filters
			this.setTemplateFilters();
		</cfscript>
  	</cffunction>
	<!---  Delete Template Filter :: includes db insert --->
  	<cffunction name="deleteTemplateFilter" access="public" output="false">
  		<cfargument name="TemplateFilter" type="mvc.Models.Template.TemplateFilter" required="true" />
		<cfscript>
			var TF = arguments.TemplateFilter;
				TF.Template_Id = this.id;
				TF.Parent_Template_Id = this.FirstParentID;
				TF.deleteDB();
			//update Template Obj array of template filters
			this.setTemplateFilters();
		</cfscript>
  	</cffunction>
	<!---
	<!---  INSERT :: Template Filter --->
  	<cffunction name="insertTemplateFilter" access="public" output="false">
  		<cfargument name="TemplateFilter" type="mvc.Models.Template.TemplateFilter" required="true" />
		<cfset useLakebaseForqInsertTemplateFilter = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_filters")>
<cfif useLakebaseForqInsertTemplateFilter>
	<cftry>
		<cfset application.oLakebase.insertRow("template_filters", {
			"template_id" = "#this.id#",
			"parent_template_id" = "#this.FirstParentID#",
			"name" = "#arguments.TemplateFilter.Name#",
			"description" = "#arguments.TemplateFilter.Desc#",
			"status" = "#arguments.TemplateFilter.Status#",
			"created_user_id" = "#request.accessStructure.user_Id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertTemplateFilter = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertTemplateFilter>
<cfquery name="qInsertTemplateFilter" datasource="#application.datasource#">
			INSERT INTO Template_Filters (
				Template_Id,
				Parent_Template_Id,
				Name,
				Description,
				Status,
				Created_User_Id
				)
				VALUES(
				#this.id#,
				#this.FirstParentID#,
				'#arguments.TemplateFilter.Name#',
				'#arguments.TemplateFilter.Desc#',
				'#arguments.TemplateFilter.Status#',
				'#request.accessStructure.user_Id#'
				)
				SELECT @@identity as Template_Filters_Id		
		</cfquery>
</cfif>
		
  	</cffunction>
	
	<!--- UPDATE :: Template Filter --->
	<cffunction name="updateTemplateFilter" access="public" output="false">
  		<cfargument name="TemplateFilter" type="mvc.Models.Template.TemplateFilter" required="true" />
		<cfset useLakebaseForqUpdateTemplateFilter = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("template_filters")>
<cfif useLakebaseForqUpdateTemplateFilter>
	<cftry>
		<cfset application.oLakebase.updateRows("template_filters",
			{
				"template_filters_id" = "eq.#arguments.TemplateFilter.Template_Filters_Id#"
			},
			{
				"template_id" = "#arguments.TemplateFilter.Template_Id#",
				"parent_template_id" = "#arguments.TemplateFilter.Parent_Template_Id#",
				"name" = "#arguments.TemplateFilter.Name#",
				"description" = "#arguments.TemplateFilter.Desc#",
				"status" = "#arguments.TemplateFilter.Status#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateTemplateFilter = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateTemplateFilter>
<cfquery name="qUpdateTemplateFilter" datasource="#application.datasource#">
			UPDATE Template_Filters
			SET
				Template_Id = #arguments.TemplateFilter.Template_Id#,
				Parent_Template_Id = #arguments.TemplateFilter.Parent_Template_Id#,
				Name = '#arguments.TemplateFilter.Name#',
				Description = '#arguments.TemplateFilter.Desc#',
				Status = '#arguments.TemplateFilter.Status#'
			WHERE 	Template_Filters_Id = #arguments.TemplateFilter.Template_Filters_Id#	
		</cfquery>
</cfif>
		
  	</cffunction>--->
      
  
</cfcomponent>
