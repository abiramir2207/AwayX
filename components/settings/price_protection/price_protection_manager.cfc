<cfcomponent hint="Price Protection Manager" extends="components.Base">
	<cfset variables.searchForm = "" />

		<cffunction name="init" output="false" returntype="components.settings.price_protection.price_protection_manager">
		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />
		<cfset setSearchForm(arguments.search) />
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getSearchForm" returntype="struct" access="public" output="false">
		<cfreturn variables.searchForm />
	</cffunction>
	<!--- setter ---->
	<cffunction name="setSearchForm" returntype="void" access="package">
		<cfargument name="searchForm" required="true" type="struct">
		<cfset variables.searchForm = arguments.searchForm />
	</cffunction>
	
		
	<cffunction name="search" output="false" returntype="query">
	
		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />
			<!---if the search struct is not empty then set it to that struct--->
		<cfif IsStruct(arguments.search) and not StructIsEmpty(arguments.search)>
			<cfset setSearchForm(arguments.search) />
		</cfif>
		
		<cfset this.search = this.getSearchForm() />
		<cfparam name="this.search.Operator_List" 	default="">
		<cfparam name="this.search.product_search_list" 	default="">
		<cfparam name="this.search.Search_Sequence_ID" 	default="0">
		<cfparam name="this.search.contract_main_ids" 	default="">
		<cfparam name="this.search.eligibleprograms" 	default="1">
		<cfquery name="qGetPrograms" datasource="#application.datasource#">
			select  distinct contract_title, contract_start_date, contract_end_date,
			contract_number,contract_main.contract_main_id, <cfif this.search.eligibleprograms eq 1>bsa_operator_id,
			BSA_Foodservice_Items_Master_ID,</cfif>contract_status_type_desc
			from contract_main
			inner join Program_Control_Panel_Options on
			Program_Control_Panel_Options.ProgramControl_Panel_Options_id = 
			contract_main.programtype_id
			inner join contract_status_types on
			contract_status_types.contract_status_type_id = contract_main.contract_status_type_idx
			inner join contract_operators on
			contract_operators.contract_main_id = contract_main.contract_main_id
			and contract_operators.deleted = 0
			inner join contract_products on
			contract_products.contract_main_id = contract_main.contract_main_id
			and contract_products.deleted = 0
			where contract_main.deleted = 0
			and contract_main.contract_status_type_idx IN (5,6)
			and Program_Control_Panel_Options.price_protection_on = 1
			<cfif this.search.Search_Sequence_ID NEQ "" AND this.search.Search_Sequence_ID NEQ "0">
			and Search_Sequence_ID = #this.search.Search_Sequence_ID#
			</cfif>
			and 
			(<cfif Len(this.search.Operator_List) EQ 0>1=2<cfelse>
			 contract_operators.bsa_operator_id <cfif this.search.eligibleprograms eq 1> in <cfelse> not in </cfif>(#ListQualify(this.search.Operator_List, "'", ",")#)
			</cfif>
			<cfif Len(this.search.product_search_list) NEQ 0>
			<cfif this.search.eligibleprograms eq 1>and contract_products.BSA_Foodservice_Items_Master_ID <cfif this.search.eligibleprograms eq 1> in <cfelse> not in </cfif> (#ListQualify(this.search.product_search_list, "'", ",")#)
			</cfif>
			</cfif>)
			<cfif this.search.eligibleprograms eq 0>
			<cfif Len(this.search.contract_main_ids) NEQ 0>
			and contract_main.contract_main_id in (#ListQualify(this.search.contract_main_ids, "", ",")#)
			</cfif>
			</cfif>
		</cfquery>
		
				<cfreturn qGetPrograms />		
	</cffunction>
	
	<cffunction name="getjobsscheduled" output="false" returntype="query">
	<cfargument name="type" type="numeric" required="true" default="1" />
	<cfargument name="jobid" type="numeric" required="false" default="0" />
	<cfquery name="qgetjobsscheduled" datasource="#application.datasource#">
	select * from 
	Price_Protection_Schedule
	where 
	<cfif arguments.type EQ 1>
	job_finished = 0
	<cfelseif arguments.type EQ 2>
	job_finished = 1
	<cfelseif arguments.type EQ 3>
	job_failed = 1
	</cfif> 
	<cfif isdefined("arguments.jobid") and arguments.jobid NEQ 0>
	and Price_Protection_Schedule_id = '#arguments.jobid#'
	</cfif>
	and deleted = 0
	</cfquery>
	<cfreturn qgetjobsscheduled />		
	
	</cffunction>
	
	<cffunction name="getjobproductdetails" output="false" returntype="query">
	<cfargument name="jobid" type="numeric" required="true" default="0" />
	<cfquery name="qgetjobproductdetails" datasource="#application.datasource#">
	select item,description,BSA_Foodservice_Items_Master_ID from 
	Price_Protection_Schedule
	inner join Price_Protection_Schedule_products on
	Price_Protection_Schedule_products.Price_Protection_Schedule_id = 
	Price_Protection_Schedule.Price_Protection_Schedule_id
	inner join BSA_Foodservice_Items_Master on BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Price_Protection_Schedule_products.product_id
	where Price_Protection_Schedule.Price_Protection_Schedule_id = '#arguments.jobid#'
	</cfquery>
	<cfreturn qgetjobproductdetails />		
	</cffunction>
	
	<cffunction name="getjoboperatordetails" output="false" returntype="query">
	<cfargument name="oprlist" type="string" required="true" default="0" />
	<cfquery name="qgetjoboperatordetails" datasource="#application.datasource#">
	select BSA_Operator_ID,Legacy_ID,operator_name from 
	bsa_operator
	where BSA_Operator_ID IN (#Listqualify(arguments.oprlist,"'")#)
	</cfquery>
	<cfreturn qgetjoboperatordetails />		
	</cffunction>
	
	<cffunction name="getprograms" output="false" returntype="query">
	<cfargument name="jobid" type="numeric" required="true" default="0" />
	<cfquery name="qgetprograms" datasource="#application.datasource#">
	select distinct contract_title, contract_start_date, contract_end_date,
	contract_number,contract_main.contract_main_id,contract_status_type_desc
	from contract_main
	inner join contract_status_types on
	contract_status_types.contract_status_type_id = contract_main.contract_status_type_idx
	inner join Price_Protection_Schedule_Contracts on
	Price_Protection_Schedule_Contracts.program_id = contract_main.contract_main_id
	where Price_Protection_Schedule_Contracts.Price_Protection_Schedule_Id = '#arguments.jobid#'
	</cfquery>
	<cfreturn qgetprograms />		
	</cffunction>
	
	<cffunction name="deletejob" output="false">
	<cfargument name="jobid" type="numeric" required="true" default="0" />
	<cfquery name="deletejob" datasource="#application.datasource#">
		update Price_Protection_Schedule
		set deleted = 1
		where Price_Protection_Schedule_id = '#arguments.jobid#'
	</cfquery>
	<cfquery name="update_contracts" datasource="#application.datasource#">
		update contract_main
		set price_protection_scheduled = 0
		where contract_main_id in (select program_id from
		Price_Protection_Schedule_Contracts
		where Price_Protection_Schedule_Id = '#arguments.jobid#')
	</cfquery>
	</cffunction>
</cfcomponent>
	