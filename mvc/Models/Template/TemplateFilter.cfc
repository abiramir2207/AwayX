<cfcomponent output="false" alias="mvc.Models.Template.TemplateFilter" hint="template filter Object is a Property of Template">

	<cfproperty name="Template_Filters_Id" type="numeric" default="0">
	<cfproperty name="Template_Id" type="numeric" default="0">
	<cfproperty name="Parent_Template_Id" type="numeric" default="0">
	<cfproperty name="Name" type="string" default="">
	<cfproperty name="Desc" type="string" default="">
	<cfproperty name="Status" type="numeric" default="0">
	<cfproperty name="CreatedUserId" type="guid">
	<!--- array of Position Ids --->
	<cfproperty name="arrPositionFilter" type="array">
	<!--- array of Customer Ids --->
	<cfproperty name="arrCustomerFilter" type="array">
	<!--- array of Item Id's ---> 
	<cfproperty name="arrItemFilter" type="array"> 
	<!--- array of Prodrate Objects --->
	<cfproperty name="arrMarketPrice" type="array"> 
	
	<cfscript>
		//Initialize the CFC with the default properties values.
		this.Template_Filters_Id = 0;
		this.Template_Id = 0;
		this.Parent_Template_Id = 0;
		this.Name =  "";
		this.Desc =  "";
		this.Status =  "";
		this.CreatedUserId = "";
		this.arrPositionFilter = arrayNew(1);
		this.arrCustomerFilter =  arrayNew(1);
		this.arrItemFilter =  arrayNew(1);
		this.arrMarketPrice = arrayNew(1);
	</cfscript>

	<cffunction name="init" output="false" >
		<cfargument name="TemplateFiltersId" default="0"/>
		<cfscript>
			if(arguments.TemplateFiltersId){
				this.Template_Filters_Id = arguments.TemplateFiltersId;
				this.getTemplateFilter();
			}
		</cfscript>
		<cfreturn this>
	</cffunction>
	
	<!--- getTemplateFilters get a filter --->
	<cffunction name="getTemplateFilter" output="false" >
		<!---<cfargument name="TemplateFiltersId" default="0"/>--->
		<cfset var objMarketPriceManager = CreateObject("component","mvc.Models.Template.MarketPriceManager") />
		<cfset var objPositionFilterManager = CreateObject("component","mvc.Models.Template.UserPositionFilterManager")/>
		<!--- get 1 template filter based on Id --->
		<cfquery name="qGetTemplateFilter" datasource="#application.datasource#">
			SELECT 	Template_Filters_Id,
					Template_Id,
					Parent_Template_Id,
					Name,
					Description,
					Status,
					Created_User_Id
					--,Created_Date
			FROM	Template_Filters
			WHERE 	Template_Filters_Id = #this.Template_Filters_Id#			
		</cfquery>
		
		<cfoutput query="qGetTemplateFilter">
			<!---<cflog text="TemplateFilter cfc id = #qGetTemplateFilter.Template_Filters_Id#"/>--->
			<cfscript>
				//build  Object
				this.Template_Filters_Id = qGetTemplateFilter.Template_Filters_Id;
				this.Template_Id = qGetTemplateFilter.Template_Id;
				this.Parent_Template_Id = qGetTemplateFilter.Parent_Template_Id;
				this.Name = qGetTemplateFilter.Name;
				this.Desc = qGetTemplateFilter.Description;
				this.Status = qGetTemplateFilter.Status;
				this.CreatedUserId = qGetTemplateFilter.Created_User_Id;
				this.arrMarketPrice = objMarketPriceManager.getMarketPriceLists(this.Template_Filters_Id,'mpType','Active');
				this.arrPositionFilter = objPositionFilterManager.getUserPositionFilterArray(this.Template_Filters_Id);
			</cfscript>
		</cfoutput>
		
		<cfreturn this>
	</cffunction>
	
	<!--- insertTemplateFilters get all filters for a template --->
	<!---<cffunction name="setTemplateFilter" output="false" >
		<cfargument name="TemplateFilter" type="mvc.Models.Template.TemplateFilter" />	
		
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
				#arguments.TemplateFilter.Template_Id#,
				#arguments.TemplateFilter.Parent_Template_Id#,
				'#arguments.TemplateFilter.Name#',
				'#arguments.TemplateFilter.Desc#',
				'#arguments.TemplateFilter.Status#',
				'#arguments.TemplateFilter.CreatedUserId#'
				)
				SELECT @@identity as Template_Filters_Id		
		</cfquery>
			
	</cffunction>--->
	<cffunction name="saveDB" access="public" output="false">
		<cfscript>
			if(this.Template_Filters_Id){
				//update in DB
				this.updateTemplateFilter();
			}
			else{
				//insert in DB
				this.insertTemplateFilter();
			}
		</cfscript>
  	</cffunction>
	<!---  INSERT :: Template Filter --->
  	<cffunction name="insertTemplateFilter" access="public" output="false">
  		<!---<cfargument name="TemplateFilter" type="mvc.Models.Template.TemplateFilter" required="true" />--->
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
				#this.Template_Id#,
				#this.Parent_Template_Id#,
				'#this.Name#',
				'#this.Desc#',
				'#this.Status#',
				'#request.accessStructure.user_Id#'
				)
				SELECT @@identity as Template_Filters_Id		
		</cfquery>
		<cfset this.Template_Filters_Id = qInsertTemplateFilter.Template_Filters_Id />
  	</cffunction>
	
	<!--- UPDATE :: Template Filter --->
	<cffunction name="updateTemplateFilter" access="public" output="false">
  		<!---<cfargument name="TemplateFilter" type="mvc.Models.Template.TemplateFilter" required="true" />--->
		<cfquery name="qUpdateTemplateFilter" datasource="#application.datasource#">
			UPDATE Template_Filters
			SET
				--Template_Id = #this.Template_Id#,
				--Parent_Template_Id = #this.Parent_Template_Id#,
				Name = '#this.Name#',
				Description = '#this.Desc#',
				Status = '#this.Status#'
			WHERE 	Template_Filters_Id = #this.Template_Filters_Id#	
		</cfquery>
		
  	</cffunction>
	
	<!---DELETE Filter Pack--->
	<cffunction name="deleteDB" access="public" output="false">
		<cfquery name="qDeleteTemplateFilter" datasource="#application.datasource#">
			UPDATE Template_Filters
			SET Deleted = 1
			WHERE 	Template_Filters_Id = #this.Template_Filters_Id#	
		</cfquery>
  	</cffunction>
	
	<!--- Getter Setter --->
	<cffunction name="setArrMarketPrice" access="public" output="false">
		<cfargument name="TemplateFiltersId" default="0"/>
		<cfscript>
			var arrRates = arrayNew(1);
			var arrProdRate = arrayNew(1);
			var qGetMPData = "";
			objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
			objMarketPriceRate		= CreateObject("component","mvc.Models.Template.MarketPriceRate");//ok
			
			//qGetMPData = objMarketPriceRate.getProductRate(arguments.TemplateFiltersId,1,'active');
		</cfscript>
		<!---<cfoutput query="qComponentData" group="componentId">
			<cfscript>
				arrProdRate = objMarketPriceRate.getProductRateDataStruct(qGetMPData, componentId);
			</cfscript>
		</cfoutput>--->
		<cfset this.arrMarketPrice = arrProdRate />
	</cffunction>
	
	<cffunction name="getProgramList" hint="return query of programs using this filter pack" returntype="query">
    	<!---<cfargument name="x" type="string" required="true"/>--->
		<cfset var qGetProgramList = "" />
		<cfquery name="qGetProgramList" datasource="#application.datasource#">
			SELECT 	CM.Contract_Title as Title,
					CM.Contract_Number as Number
			FROM Contract_Main CM
			--JOIN Template_Filters TF ON
			--	TF.Template_Filters_Id = CM.Template_Filters_Id
			WHERE 	CM.Template_Filters_Id = #this.Template_Filters_Id#			
		</cfquery>	
    	<cfreturn qGetProgramList />
    </cffunction>
    
	<cffunction name="getArrMarketPrice" access="public" returntype="" output="false">
		<cfreturn this.arrMarketPrice />
	</cffunction>
	
	<!--- Getter Setter --->
	<!---<cffunction name="set" access="public" output="false">
		<cfargument name="" type="" required="true" />
		<cfset this. = arguments. />
	</cffunction>
	<cffunction name="get" access="public" returntype="" output="false">
		<cfreturn this. />
	</cffunction>--->
	
</cfcomponent>