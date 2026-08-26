
<cfif isdefined("form.contractIds")>
<cfif listlen(form.contractIds) GT 0>
<cfquery name="lockcontracts" datasource="#application.datasource#">
	update contract_main
	set price_protection_scheduled = 1
	where contract_main_id in (#form.contractIds#)
</cfquery> 
</cfif>
</cfif>

<cfquery name="createschedule" datasource="#application.datasource#">
SET NOCOUNT ON
insert into Price_Protection_Schedule
(job_name,Search_Sequence_Id,Price_Protection_Rate,Price_Protection_UOM,opr_list)
values ('#form.price_protection_job_name#',#form.Search_Sequence_Id#,#form.Price_Protection_Rate#,#form.Price_Protection_UOM#,'#form.Operator_List#')
SELECT Price_Protection_Schedule_Id = @@IDENTITY
SET NOCOUNT OFF
</cfquery>

<cfif form.contractIds neq "">
<cfloop list="#form.contractIds#" index="contract">
<cfset useLakebaseForaddcontractids = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("price_protection_schedule_contracts")>
<cfif useLakebaseForaddcontractids>
	<cftry>
		<cfset application.oLakebase.insertRow("price_protection_schedule_contracts", {
			"price_protection_schedule_id" = "#createschedule.Price_Protection_Schedule_Id#",
			"program_id" = "#contract#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForaddcontractids = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForaddcontractids>
<cfquery name="addcontractids" datasource="#application.datasource#">
	insert into Price_Protection_Schedule_Contracts
	(Price_Protection_Schedule_Id,program_id)
	values(#createschedule.Price_Protection_Schedule_Id#,#contract#)
</cfquery>
</cfif> 
</cfloop>
</cfif>

<cfif form.product_search_list neq "">
<cfloop list="#form.product_search_list#" index="prod">
<cfset useLakebaseForaddproducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("price_protection_schedule_products")>
<cfif useLakebaseForaddproducts>
	<cftry>
		<cfset application.oLakebase.insertRow("price_protection_schedule_products", {
			"price_protection_schedule_id" = "#createschedule.Price_Protection_Schedule_Id#",
			"product_id" = "#prod#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForaddproducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForaddproducts>
<cfquery name="addproducts" datasource="#application.datasource#">
	insert into Price_Protection_Schedule_Products
	(Price_Protection_Schedule_Id,Product_Id)
	values(#createschedule.Price_Protection_Schedule_Id#,'#prod#') 
</cfquery>
</cfif>
</cfloop>
</cfif>
<cflocation url="price_protection_jobs_scheduled.cfm?type=1">