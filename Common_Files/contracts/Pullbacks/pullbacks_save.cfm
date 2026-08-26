<cfparam name="form.pagetype" default="D">
<cfparam name="form.contract_main_id" default="0">
<cfparam name="form.distributorid" default="">
<cfparam name="form.programid" default="">
<cfparam name="form.distributorlist" default="">
<cfparam name="form.productlist" default="">
<cfparam name="form.programlist" default="">
<cfparam name="url.margincheck" default="0">
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />

<cf_cryp type="en" key="#request.key#" string="#form.contract_main_id#">

<cfif form.contract_main_id NEQ 0>
<cfquery name="getpullbackcontractnumber" datasource="#application.datasource#">
select contract_number, contract_start_date, contract_end_date from
contract_main 
where contract_main_id = <cfqueryparam value="#form.contract_main_id#" cfsqltype="CF_SQL_INTEGER" />
</cfquery>
<!--- If the save button was clicked on the Pullbacks Distributor page,loop over all the available Dis Corp Programs and then loop over all the products from the current program and insert into the pullback_details table with the pullback value of each distributor. --->
<cfif form.pagetype EQ "D">

<cfif listlen(form.distributorlist) GT 0 and listlen(form.productlist) GT 0>
<cfloop list="#form.distributorlist#" index="thisDis">
	<cfset dispullbackId = "form.pullback_#replace(thisDis, "-", "_", "ALL")#" />
	<cfset dispullbackvalue = "form.pullbackvalue_#replace(thisDis, "-", "_", "ALL")#" />
	<cfset dispullbacklevel = "form.pullback_level_#replace(thisDis, "-", "_", "ALL")#" />
	<cfset dispullbackdefaultvalue = "form.pullbackdefaultvalue_#replace(thisDis, "-", "_", "ALL")#" />
	
<cfif isdefined("#dispullbackId#")>
	<cfif isdefined("#dispullbacklevel#")>
	<!--- check if the apply pullback for each distributor is from the distributor page, sometimes the pullbacks can be applied at either program or item level for a given distributor, in such cases the values cannot be overwritten in the pullbacks details table. --->
		<cfif trim(evaluate(dispullbacklevel)) EQ "D">
			<cfset deleteoldpullbackrates = PullbackManager.deleteoldpullbackrates(form.contract_main_id,thisDis)>
<!--- get all the dis corp programs that have pullback from this program On and match the dates and make any enry into the pullback_details table ---> 
			<cfset getDisCorpPorgrams = PullbackManager.getDisCorpPorgrams(thisDis,form.contract_end_date,form.contract_start_date,form.pullback_template_type)>
	<cfif getDisCorpPorgrams.recordcount GT 0>
	<cfloop query="getDisCorpPorgrams">
		<cfloop list="#form.productlist#" index="thisItem">
		<cfquery name="insertDisPullbackRates" datasource="#application.datasource#">
			insert into pullback_details 
			(Customer_id,Customer_program_id,Product_Id,Opr_Program_Id,Pullback,Pullback_Value,pullbacks_created_by,opr_contract_number)
	values('#thisDis#',#getDisCorpPorgrams.contract_main_id#,'#thisItem#',#form.contract_main_id#,
	#evaluate(dispullbackId)#,<cfif trim(evaluate(dispullbackId)) EQ 1>#evaluate(dispullbackvalue)#<cfelse>0</cfif>,'#request.AccessStructure.user_id#','#getpullbackcontractnumber.contract_number#')
		</cfquery>
		</cfloop>
	</cfloop>
	</cfif>
		</cfif>
	</cfif>
<!--- 	Make an entry in the Pullbacks_Levels table for each distributor to indicate that the pullback vlaues are saved at distributor level  --->
	<cfquery name="insertDisPullbackLevelTable" datasource="#application.datasource#">
		delete from Pullbacks_Levels
		where Pullback_Program_Id = <cfqueryparam value="#form.contract_main_id#" cfsqltype="CF_SQL_INTEGER" />
		and Customer_id = <cfqueryparam value="#thisDis#" cfsqltype="CF_SQL_VARCHAR" />
		
		insert into Pullbacks_Levels 
		(Pullback_Program_Id,Customer_id,Pullback_Level,Pullback_level_Description)
		values(#form.contract_main_id#,'#thisDis#','D','Distributor')
	</cfquery>
	</cfif> 
	
	<!--- Save the default pullback values for each distributor, so that if any new Dis Corp or Local Dis deals are created after this Opr program got approved, we would use these default values to make an entry in the pullback_details table when the Dis Corp or Local Dis Deals are approved --->
	<cfquery name="insertDisPullbackfaultsTable" datasource="#application.datasource#">
		delete from Pullbacks_Distributors_Defaults
		where Pullback_Program_Id = <cfqueryparam value="#form.contract_main_id#" cfsqltype="CF_SQL_INTEGER" />
		and Customer_id = <cfqueryparam value="#thisDis#" cfsqltype="CF_SQL_VARCHAR" />
		
		insert into Pullbacks_Distributors_Defaults 
		(Pullback_Program_Id,Customer_id,Pullback,Pullback_Default_Value,created_by)
		values(#form.contract_main_id#,'#thisDis#',1,
		'#evaluate(dispullbackdefaultvalue)#','#request.AccessStructure.user_id#')
	</cfquery>
</cfloop>	
<cfelse>
<cflocation url="pullback_index.cfm?Error=D&CID=#cryp.value#">
</cfif>

<!--- If the pullbacks save is from the program page for a selected distributor,loop over all the available products from the current opr program and insert into the pullback details table with program pullback value --->
<cfelseif form.pagetype EQ "P">
	<cfif form.distributorid NEQ "">
		<cfquery name="qdeleteoldpullbackrates" datasource="#application.datasource#">
			delete 	from pullback_details
			where 	opr_program_id = <cfqueryparam value="#form.contract_main_id#" cfsqltype="CF_SQL_INTEGER" />
			and 	Customer_id = <cfqueryparam value="#form.distributorid#" cfsqltype="CF_SQL_VARCHAR" />
		</cfquery>
		<cfloop list="#form.programlist#" index="thisPrg">
			<cfset prgpullbackId = "form.pullback_#thisPrg#" />
			<cfset prgpullbackvalue = "form.pullbackvalue_#thisPrg#" />
			<cfset prgpullbacklevel = "form.pullback_level_#thisPrg#" />
			
			<!--- check if the pullback rules are applied at program level or an item level. If the pullback rules are applied at item level for a selected program, it will not go through this loop. --->
			<cfif isdefined("#prgpullbackId#")>
				<cfif isdefined("#prgpullbacklevel#")>
					<cfif #evaluate(prgpullbacklevel)# EQ "P">
						
						<cfloop list="#form.productlist#" index="thisItem">
							<cfquery name="insertDisPullbackRates" datasource="#application.datasource#">
								insert into pullback_details 
								(Customer_id,Customer_program_id,Product_Id,Opr_Program_Id,Pullback,Pullback_Value,pullbacks_created_by,opr_contract_number)
								values('#form.distributorid#',#thisPrg#,'#thisItem#',#form.contract_main_id#,
								#evaluate(prgpullbackId)#,<cfif evaluate(prgpullbackId) EQ 1>
								#evaluate(prgpullbackvalue)#<cfelse>0</cfif>,'#request.AccessStructure.user_id#','#getpullbackcontractnumber.contract_number#')
							</cfquery>
						</cfloop>
						
						<!--- 	Insert into the pullback_levels for each program the level at which the pullbacks are applied --->
						<cfquery name="insertDisPullbackLevelTable" datasource="#application.datasource#">
							delete from Pullbacks_Levels
							where Pullback_Program_Id = <cfqueryparam value="#form.contract_main_id#" cfsqltype="CF_SQL_INTEGER" />
							and pullback_from_program_id = <cfqueryparam value="#thisPrg#" cfsqltype="CF_SQL_INTEGER" />
							
							insert into Pullbacks_Levels 
							(Pullback_Program_Id,pullback_from_program_id,Pullback_Level,Pullback_level_Description)
							values(#form.contract_main_id#,'#thisPrg#','P','Program')
						</cfquery>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfquery name="insertDisPullbackLevelTable" datasource="#application.datasource#">
			delete from Pullbacks_Levels
			where Pullback_Program_Id = <cfqueryparam value="#form.contract_main_id#" cfsqltype="CF_SQL_INTEGER" />
			and Customer_id = <cfqueryparam value="#form.distributorid#" cfsqltype="CF_SQL_VARCHAR" />
			
			insert into Pullbacks_Levels 
			(Pullback_Program_Id,Customer_id,Pullback_Level,Pullback_level_Description)
			values(#form.contract_main_id#,'#form.distributorid#','P','Program')
		</cfquery>
	<cfelse>
		<cflocation url="pullback_index.cfm?Error=D&CID=#cryp.value#">
	</cfif>
	<!--- If the pullbacks save is from the Selected Distributor-Program-Item page, insert into the pullback details table for each item pullback value. --->
<cfelseif form.pagetype EQ "I">
	<cfif form.distributorid NEQ "" and form.programid NEQ "" and listlen(form.productlist) GT 0>
		<cfset deleteoldpullbackrates = PullbackManager.deleteoldpullbackrates(form.contract_main_id,form.distributorid,form.programid)>
		<cfloop list="#form.productlist#" index="thisPrd">
			<cfset prdpullbackId = "form.pullback_#replace(thisPrd, "-", "_", "ALL")#" />
			<cfset prdpullbackvalue = "form.pullbackvalue_#replace(thisPrd, "-", "_", "ALL")#" />
			<cfif isdefined("#prdpullbackId#")>
				<cfquery name="insertDisPullbackRates" datasource="#application.datasource#">
				insert into pullback_details 
				(Customer_id,Customer_program_id,Product_Id,Opr_Program_Id,Pullback,Pullback_Value,pullbacks_created_by,opr_contract_number)
				values('#form.distributorid#',#form.programId#,'#thisPrd#',#form.contract_main_id#,
				#evaluate(prdpullbackId)#,<cfif evaluate(prdpullbackId) EQ 1>
				#evaluate(prdpullbackvalue)#<cfelse>0</cfif>,'#request.AccessStructure.user_id#','#getpullbackcontractnumber.contract_number#')
				</cfquery>
			</cfif>
		</cfloop>
	<!---Make any entry into the pullbacks_levels table to  --->
	<cfquery name="insertDisPullbackLevelTable" datasource="#application.datasource#">
		delete from Pullbacks_Levels
		where Pullback_Program_Id = <cfqueryparam value="#form.contract_main_id#" cfsqltype="CF_SQL_INTEGER" />
		and pullback_from_program_id = <cfqueryparam value="#form.programid#" cfsqltype="CF_SQL_INTEGER" />
		<!--- 	Insert into the pullback_levels for each program the level at which the pullbacks are applied --->
		insert into Pullbacks_Levels 
		(Pullback_Program_Id,pullback_from_program_id,Pullback_Level,Pullback_level_Description)
		values(#form.contract_main_id#,'#form.programid#','I','Item')
	</cfquery>
	<cfquery name="insertDisPullbackLevelTable" datasource="#application.datasource#">
		delete from Pullbacks_Levels
		where Pullback_Program_Id = <cfqueryparam value="#form.contract_main_id#" cfsqltype="CF_SQL_INTEGER" />
		and Customer_id = <cfqueryparam value="#form.distributorid#" cfsqltype="CF_SQL_VARCHAR" />
		
		insert into Pullbacks_Levels 
		(Pullback_Program_Id,Customer_id,Pullback_Level,Pullback_level_Description)
		values(#form.contract_main_id#,'#form.distributorid#','I','Item')
	</cfquery>

	<cfelse>
		<cflocation url="pullback_index.cfm?Error=I&CID=#cryp.value#">
	</cfif>
</cfif>
<cfelse>
<cflocation url="pullback_index.cfm?Error=C&CID=#cryp.value#">
</cfif>	

<!--- Update the customer contract number in the pullback_details table using the customer_program_id and this will be helpful in the BB section  for revisions --->
<cfquery name="insertDisPullbackRates" datasource="#application.datasource#">
update pullback_details
set customer_contract_number = contract_main.contract_number
<cfif appsettings.getOnlyAccrualTPAPullbacks()>
,TPA_UseOnly = 
case when Program_Control_Panel_Options.created_type like '%Accrual%' then
1 else 0 end
</cfif>
from pullback_details
inner join contract_main
on contract_main.contract_main_id = pullback_details.customer_program_id
inner join Program_Control_Panel_Options on
Program_Control_Panel_Options.ProgramControl_Panel_Options_id = contract_main.programtype_id
where opr_program_id = #form.contract_main_id#
and pullback_details.deleted = 0
</cfquery>

<!--- If atleast one pullback rule is applied on any of the distributors, this bit is updated on the Contract main table and is used for pullback approval routing. --->
<cfquery name="updatecontractmainifatleastonepullbackapplied" datasource="#application.datasource#">
	update Contract_Main
	set pullback_available = 1
	where Contract_Main_ID = <cfqueryparam value="#form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER" />
</cfquery>

<!--- We copy the pullback rules from the parent program to the revised program, if the revised program had a cutomer or product removed, we should delete the entries made in pullback details table for the child program Id for the deleted product or customer. Otherwise the pullback percentage rules that are calculated on the BB side would be incorrect. --->
<cfset checkifproductsremoved = PullbackManager.checkifproductsremoved(form.Contract_Main_ID)>
<cfset checkifdistributorsremoved = PullbackManager.checkifdistributorsremoved(form.Contract_Main_ID)>

<cfif checkifdistributorsremoved GT 0>
<cfquery name="RemoveDistributorEntries" datasource="#application.datasource#">
	update pullback_details
	set deleted = 1,
	deleted_by = 'distributor removed'
	where deleted = 0 and 
	Opr_Program_Id = <cfqueryparam value="#form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER" />
	and customer_id not in (select bsa_foodservice_customers_id 
	from contract_distributors 
	where contract_distributors.deleted = 0 and
	contract_distributors.contract_main_id = <cfqueryparam value="#form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">)
</cfquery>
<cfquery name="RemoveDistributorDefaults" datasource="#application.datasource#">
	delete from
	Pullbacks_Distributors_Defaults
	where Pullback_Program_Id = <cfqueryparam value="#form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER" />
	and customer_id not in (select bsa_foodservice_customers_id 
	from contract_distributors 
	where contract_distributors.deleted = 0 and
	contract_distributors.contract_main_id = <cfqueryparam value="#form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">)
</cfquery>
</cfif>


<cfif checkifproductsremoved GT 0>
<cfquery name="RemoveproductEntries" datasource="#application.datasource#">
	update pullback_details
	set deleted = 1,
	deleted_by = 'product removed'
	where deleted = 0 and
	Opr_Program_Id = <cfqueryparam value="#form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER" />
	and product_id not in 
	(select distinct contract_products.bsa_foodservice_items_master_id from contract_products
	where contract_products.deleted = 0 and
	contract_products.contract_main_id = <cfqueryparam value="#form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">)
</cfquery>
</cfif>

<cfset qGetDistributorsAddedList = PullbackManager.getDistributorsAddedList(form.Contract_Main_ID)>

<cfif qGetDistributorsAddedList.recordCount GT 0>
	<!--- if there are distributors without pullback applied, check if they have any programs to apply against --->
	<cfset programsAvailable = 0 />
	<cfloop query="qGetDistributorsAddedList">
		<cfset checkDisCorpPorgramsCount = PullbackManager.checkDisCorpPorgramsCount(BSA_Foodservice_Customers_id, getpullbackcontractnumber.contract_end_date, getpullbackcontractnumber.contract_start_date, form.contract_main_id)>
		<cfif checkDisCorpPorgramsCount GT 0>
			<cfset programsAvailable = 1 />
			<cfbreak />
		</cfif>
	</cfloop>
</cfif>

<!--- set applied_pullbacks = 1 when 
	no distributor left to apply pullback (qGetDistributorsAddedList.recordCount EQ 0)
	or when the distributors left to apply pullbacks do not have any program
--->
<cfif qGetDistributorsAddedList.recordCount EQ 0 OR programsAvailable EQ 0>
	<cfquery name="insertDisPullbackRates" datasource="#application.datasource#">
		update 	Contract_Main
		set 	applied_pullbacks = 1
		where 	Contract_Main_ID = <cfqueryparam value="#form.Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER" />
	</cfquery>
</cfif>




<cfif form.pagetype EQ "D">
<cfif url.margincheck EQ 0>
<cflocation url="/common_files/contracts/contract_edit_menu.cfm?CID=#cryp.value#">
<cfelse>
<cflocation url="/Common_Files/Contracts/duplicate_check.cfm?CID=#URL.CID#">
</cfif>
</cfif>

<FORM ACTION="pullback_index.cfm?CID=<CFOUTPUT>#cryp.value#</CFOUTPUT>&margincheck=<cfoutput>#url.margincheck#</cfoutput>" METHOD="post" NAME="PullbackInfo" STYLE="DISPLAY:INLINE">
<input type="hidden" name="pagetype" value="D">
<input type="hidden" name="programId" value="<cfoutput>#form.programid#</cfoutput>">
<input type="hidden" name="distributorid" value="<cfoutput>#form.distributorid#</cfoutput>">
<input type="hidden" name="command" value="edit">
</FORM>
<script>
<cfif form.pagetype EQ "I">
document.all.PullbackInfo.pagetype.value = 'P';
</cfif>
document.all.PullbackInfo.submit();
</script>