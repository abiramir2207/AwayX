

<cffunction name="getProgramHeader" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="user_id" type="string" required="false" />
	<CFQUERY NAME="qgetProgramHeader" datasource="#application.datasource#">
		SELECT Contract_Main.contract_main_id,
				Contract_Main.contract_number, 
				Contract_Main.contract_start_date,
				Contract_Main.contract_end_date,
				Contract_Main.contract_title,
				Contract_Main.Contract_Created_Date,
				BSA_Foodservice_Customers.Shr_Ship_To,
				template_codes.template_code,
				Lump_Template_Code.template_code as Lump_Spending_Code,
				template_codes.unit_of_measure,
				Business_Segment.Business_Unit_Id,
				Line_Of_Business.Line_Of_Business,
				Payment_Cycle.External_Id as Payment_Cycle,
				Payment_Type.Payment_Type_Legacy_Id,
				U1.user_code as creator_user,
				U2.user_code as responsible_user,
				U3.user_code as approved_user,
				Contract_Main.approval_date
		from Contract_Main
		INNER JOIN Program_Control_Panel_Options
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
		and Program_Control_Panel_Options.deleted = 0
		INNER JOIN template_codes
		ON template_codes.template_code_Id = Program_Control_Panel_Options.program_spending_type
		--LUMP SUM SPENDING TYPE
		LEFT JOIN template_codes Lump_Template_Code
		ON Lump_Template_Code.template_code_Id = Program_Control_Panel_Options.Lumpsum_Spending_Type
		
		LEFT JOIN Payment_Cycle
		ON Payment_Cycle.Payment_Cycle_ID = Contract_Main.PaymentCycle
		LEFT JOIN
		Payment_Type ON
		Payment_Type.Payment_Type_ID = Contract_Main.ClaimMechanics
		and Payment_Type.deleted = 0
		and Payment_Type.Active = 1
		LEFT JOIN Business_Segment
		ON Business_Segment.Business_Segment_ID = Contract_Main.Business_Segment_ID
		and Business_Segment.deleted = 0
		LEFT JOIN Line_Of_Business
		ON Line_Of_Business.Line_Of_Business_ID = Contract_Main.Line_Of_Business_ID
		and Line_Of_Business.deleted = 0
		LEFT JOIN
		BSA_Foodservice_Customers ON
		BSA_Foodservice_Customers.BSA_Foodservice_Customers_Id = Contract_Main.Rebate_Recipient_Customer_ID
		INNER JOIN _Users U1
		ON U1.User_ID = Contract_Main.Creator_ID
		--and U1.deleted = 0
		INNER JOIN _Users U2
		ON U2.User_ID = Contract_Main.Responsible_User_ID
		--and U2.deleted = 0
		INNER JOIN _Users U3
		ON U3.User_ID = <cfif isdefined("arguments.User_Id")>'#arguments.User_Id#'<cfelse>Contract_Main.Approved_By_User_ID</cfif>
		--and U3.deleted = 0
			WHERE Contract_Main.Contract_Main_ID = '#arguments.Program_ID#'
		and Contract_Main.deleted = 0
	</CFQUERY>
<cfreturn qgetProgramHeader />
</cffunction>


<cffunction name="getProgramDiscountTypes" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
<CFQUERY NAME="qgetProgramDiscountTypes" datasource="#application.datasource#">
select distinct Product_Type_ID,Discount_Type_external_Id as Discount_Type
from contract_products
inner join discount_type
ON discount_type.discount_type_Id = contract_products.Product_Type_ID
where contract_main_id = '#arguments.Program_ID#'
and contract_products.deleted = 0
and contract_products.Product_Type_ID IN (2,3,4)
</CFQUERY>
<cfreturn qgetProgramDiscountTypes />
</cffunction>

<cffunction name="getProgramRates" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="discounttype" type="string" required="true" />
	<cfargument name="template_code" type="string" required="true" />
	<cfargument name="component_id" type="string" required="false" />
<CFQUERY NAME="qgetProgramRates" datasource="#application.datasource#">
<cfif arguments.discounttype EQ 2>
	select DISTINCT pricing_level_id,
		Right(RTrim(ph4.product_hierarchy), 3) as Product_Group, 
		max(cast(rate as float)) as rate,
		Program_Rebates_Component.Program_Rebates_Component_Name_ID as Component_Name_ID,
		<cfif trim(arguments.template_code) EQ 'BGRP'>
			'' as Shr_Ship_To,
		<cfelse>
			BSA_Foodservice_Customers.Shr_Ship_To,
		</cfif>
		<cfif trim(arguments.template_code) EQ 'BGRP'>
			Distributor_Buying_Groups.Buying_Group,
		<cfelse>
			'' as Buying_Group,
		</cfif>
		Payment_Cycle.External_Id as Payment_Cycle,
		Payment_Cycle.Payment_Cycle_Id,
		PRCN.External_ID as External_id
	FROM		Contract_Products 
				INNER JOIN	BSA_Foodservice_Items_Master ON 
							Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				INNER join product_hierarchy ph
				on 
				(	----- Group alone
					Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50))
					AND Contract_Products.Is_Group = 1
					AND ph.product_hierarchy_id = BSA_Foodservice_items_master.BSA_Foodservice_Items_Master_ID)
				OR
				(	----- Products alone
					ISNULL(Contract_Products.Product_Group_ID, '') = '' 
					AND Contract_Products.Is_Group = 0
					and (Contract_Products.pricing_level_id = 1 OR Contract_Products.pricing_level_id = 0)
					AND ph.product_hierarchy_id = BSA_Foodservice_items_master.product_hierarchy_id)
				INNER join product_hierarchy ph4
				on ph4.Product_hierarchy_level = 4
				and left(ph4.product_hierarchy, len(ph.product_hierarchy)) = ph.product_hierarchy
	INNER JOIN Contract_Distributors
	ON Contract_Distributors.contract_main_id = contract_products.contract_main_id
	and Contract_Distributors.deleted = 0
	<cfif trim(arguments.template_code) EQ 'BGRP'>
	and Contract_Distributors.is_group =1
	</cfif>
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_Id = Contract_Distributors.BSA_Foodservice_Customers_Id
	INNER JOIN Distributor_Buying_Groups
	ON Distributor_Buying_Groups.Buying_Group_id = BSA_Foodservice_Customers.Buying_Group_id
	INNER JOIN Program_Rebates_Product_Data
				ON Program_Rebates_Product_Data.Contract_Products_ID = contract_products.Contract_Products_ID
				and Program_Rebates_Product_Data.deleted = 0
				and Program_Rebates_Product_Data.Program_ID = contract_products.contract_main_id
	INNER JOIN
	Program_Rebates_Component_Data
	ON Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_Id
	and Program_Rebates_Component_Data.deleted = 0
	<!--- Commented out (SQL comments below) because Templates were not following these rules.  LOC templates had UOM 1 etc... --->
	<cfif trim(arguments.template_code) EQ 'REG' OR trim(arguments.template_code) EQ 'LOC' OR trim(arguments.template_code) EQ 'BGRP'
	OR trim(arguments.template_code) EQ 'CORP'>
	---and Program_Rebates_Component_Data.Unit_Of_Measure_ID = 3
	<cfelseif trim(arguments.template_code) EQ 'DOLL'>
	---and Program_Rebates_Component_Data.Unit_Of_Measure_ID = 1
	<cfelse>
	---and Program_Rebates_Component_Data.Unit_Of_Measure_ID = 3
	</cfif>
	INNER JOIN Program_Rebates_Component
	ON Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID
	and Program_Rebates_Component.deleted = 0
	and Program_Rebates_Component.program_id = contract_products.contract_main_id
	INNER JOIN program_rebates_component_name PRCN ON
		PRCN.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
	INNER JOIN Program_Payment_Cycle
	ON Program_Payment_Cycle.program_id = Contract_Products.Contract_Main_ID
	and Program_Payment_Cycle.Discount_Type_ID = Contract_Products.Product_Type_ID
	and Program_Payment_Cycle.deleted = 0
	INNER JOIN Payment_Cycle
	ON Payment_Cycle.Payment_Cycle_Id = Program_Payment_Cycle.Payment_Cycle_ID
	where
			Contract_Products.Contract_Main_ID = '#arguments.Program_ID#'
			AND dbo.Contract_Products.Deleted = 0
			AND dbo.Contract_Products.Product_Type_ID =  '#arguments.discounttype#'
			--and cast(rate as float) != 0
			and ph4.deleted = 0
	<cfif isdefined("arguments.component_id") and arguments.component_id neq "">
			and Program_Rebates_Component.Program_Rebates_Component_name_id = '#arguments.component_id#'
	</cfif>
	group by Program_Rebates_Component.Program_Rebates_Component_Name_ID,pricing_level_id,
	ph4.product_hierarchy,Buying_Group,BSA_Foodservice_Customers.Shr_Ship_To,Payment_Cycle.External_Id,Payment_Cycle.Payment_Cycle_Id,
	PRCN.External_ID
	order by Program_Rebates_Component.Program_Rebates_Component_Name_ID

<cfelseif arguments.discounttype EQ 3>
	<cfif arguments.template_code EQ 'LUMP'>
	select DISTINCT  Right(RTrim(ph4.product_hierarchy), 3) as Product_Group,
	--BSA_Foodservice_Customers.Shr_Ship_To,Buying_Group,
	<cfif trim(arguments.template_code) EQ 'BGRP'>
	'' as Shr_Ship_To,
	<cfelse>
	BSA_Foodservice_Customers.Shr_Ship_To,
	</cfif>
	<cfif trim(arguments.template_code) EQ 'BGRP'>
	Distributor_Buying_Groups.Buying_Group,
	<cfelse>
	'' as Buying_Group,
	</cfif>
	Program_Lumps_Sum_Ext_Id as Component_Name_ID,
	isnull(cast(Program_Lump_Sums.lump_sum_amount as float),0) as rate,
	'B' as Unit_Of_Measure,Payment_Cycle.External_Id as Payment_Cycle,Payment_Cycle.Payment_Cycle_Id,
	'FLAT' as External_id
	FROM		Contract_Products 
				INNER JOIN	BSA_Foodservice_Items_Master ON 
							Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				INNER join product_hierarchy ph
				on 
				(	----- Group alone
					Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50))
					AND Contract_Products.Is_Group = 1
					AND ph.product_hierarchy_id = BSA_Foodservice_items_master.BSA_Foodservice_Items_Master_ID)
				OR
				(	----- Products alone
					ISNULL(Contract_Products.Product_Group_ID, '') = '' 
					AND Contract_Products.Is_Group = 0
					and (Contract_Products.pricing_level_id = 1 OR Contract_Products.pricing_level_id = 0)
					AND ph.product_hierarchy_id = BSA_Foodservice_items_master.product_hierarchy_id)
				INNER join product_hierarchy ph4
				on ph4.Product_hierarchy_level = 4
				and left(ph4.product_hierarchy, len(ph.product_hierarchy)) = ph.product_hierarchy
	INNER JOIN Contract_Distributors
	ON Contract_Distributors.contract_main_id = contract_products.contract_main_id
	and Contract_Distributors.deleted = 0
	<cfif trim(arguments.template_code) EQ 'BGRP'>
	and Contract_Distributors.is_group =1
	</cfif>
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_Id = Contract_Distributors.BSA_Foodservice_Customers_Id
	INNER JOIN Distributor_Buying_Groups
	ON Distributor_Buying_Groups.Buying_Group_id = BSA_Foodservice_Customers.Buying_Group_id
	INNER JOIN Program_Lump_Sum_Product_Data
	ON Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
	and Program_Lump_Sum_Product_Data.deleted = 0
	INNER JOIN Program_Lump_Sums
	ON Program_Lump_Sums.Program_ID = Contract_Products.Contract_Main_ID
	AND Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
	and Program_Lump_Sums.deleted = 0
	INNER JOIN Program_Payment_Cycle
	ON Program_Payment_Cycle.program_id = Contract_Products.Contract_Main_ID
	and Program_Payment_Cycle.Discount_Type_ID = Contract_Products.Product_Type_ID
	and Program_Payment_Cycle.component_id = Program_Lump_Sums.Program_Lumps_Sum_Ext_Id
	and Program_Payment_Cycle.deleted = 0
	INNER JOIN Payment_Cycle
	ON Payment_Cycle.Payment_Cycle_Id = Program_Payment_Cycle.Payment_Cycle_ID
	and Program_Payment_Cycle.deleted = 0
	where Contract_Products.Contract_Main_ID =  '#arguments.Program_ID#'
	AND dbo.Contract_Products.Deleted = 0
	AND dbo.Contract_Products.Product_Type_ID = 3
	and ph4.deleted = 0
	<cfif isdefined("arguments.component_id") and arguments.component_id neq "">
	and Program_Lump_Sums.Program_Lumps_Sum_Ext_Id = '#arguments.component_id#'
	</cfif>
	order by Program_Lumps_Sum_Ext_Id
<cfelse>
	select DISTINCT  Right(RTrim(ph4.product_hierarchy), 3) as Product_Group,
	Program_Lumps_Sum_Ext_Id as Component_Name_ID,
	isnull(cast(Program_Lump_Sums.lump_sum_amount as float),0) as rate,Payment_Cycle.External_Id as Payment_Cycle,Payment_Cycle.Payment_Cycle_Id,
	'' as External_id
	FROM		Contract_Products 
				INNER JOIN	BSA_Foodservice_Items_Master ON 
							Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				INNER join product_hierarchy ph
				on 
				(	----- Group alone
					Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50))
					AND Contract_Products.Is_Group = 1
					AND ph.product_hierarchy_id = BSA_Foodservice_items_master.BSA_Foodservice_Items_Master_ID)
				OR
				(	----- Products alone
					ISNULL(Contract_Products.Product_Group_ID, '') = '' 
					AND Contract_Products.Is_Group = 0
					and (Contract_Products.pricing_level_id = 1 OR Contract_Products.pricing_level_id = 0)
					AND ph.product_hierarchy_id = BSA_Foodservice_items_master.product_hierarchy_id)
				INNER join product_hierarchy ph4
				on ph4.Product_hierarchy_level = 4
				and left(ph4.product_hierarchy, len(ph.product_hierarchy)) = ph.product_hierarchy
	INNER JOIN Program_Lump_Sum_Product_Data
	ON Program_Lump_Sum_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
	and Program_Lump_Sum_Product_Data.deleted = 0
	INNER JOIN Program_Lump_Sums
	ON Program_Lump_Sums.Program_ID = Contract_Products.Contract_Main_ID
	AND Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
	and Program_Lump_Sums.deleted = 0
	INNER JOIN Program_Payment_Cycle
	ON Program_Payment_Cycle.program_id = Contract_Products.Contract_Main_ID
	and Program_Payment_Cycle.Discount_Type_ID = Contract_Products.Product_Type_ID
	and Program_Payment_Cycle.deleted = 0
	and Program_Payment_Cycle.component_id = Program_Lump_Sums.Program_Lumps_Sum_Ext_Id
	INNER JOIN Payment_Cycle
	ON Payment_Cycle.Payment_Cycle_Id = Program_Payment_Cycle.Payment_Cycle_ID
	where Contract_Products.Contract_Main_ID =  '#arguments.Program_ID#'
	AND dbo.Contract_Products.Deleted = 0
	AND dbo.Contract_Products.Product_Type_ID = 3
	and ph4.deleted = 0
	<cfif isdefined("arguments.component_id") and arguments.component_id neq "">
	and Program_Lump_Sums.Program_Lumps_Sum_Ext_Id = '#arguments.component_id#'
	</cfif>
	order by Program_Lumps_Sum_Ext_Id
	</cfif>
	<cfelseif arguments.discounttype EQ 4>
	select DISTINCT  pricing_level_id,Right(RTrim(ph4.product_hierarchy), 3) as Product_Group,
	--BSA_Foodservice_Customers.Shr_Ship_To,Buying_Group,
	<cfif trim(arguments.template_code) EQ 'BGRP'>
	'' as Shr_Ship_To,
	<cfelse>
	BSA_Foodservice_Customers.Shr_Ship_To,
	</cfif>
	<cfif trim(arguments.template_code) EQ 'BGRP'>
	Distributor_Buying_Groups.Buying_Group,
	<cfelse>
	'' as Buying_Group,
	</cfif>
	Growth_Component_Name_Id as Component_Name_Id,
	max(cast(rate as float)) as Rate,Payment_Cycle.External_Id as Payment_Cycle,Payment_Cycle.Payment_Cycle_Id,
	'FLAT' as External_id
	FROM		Contract_Products 
				INNER JOIN	BSA_Foodservice_Items_Master ON 
							Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
				INNER join product_hierarchy ph
				on 
				(	----- Group alone
					Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50))
					AND Contract_Products.Is_Group = 1
					AND ph.product_hierarchy_id = BSA_Foodservice_items_master.BSA_Foodservice_Items_Master_ID)
				OR
				(	----- Products alone
					ISNULL(Contract_Products.Product_Group_ID, '') = '' 
					AND Contract_Products.Is_Group = 0
					and (Contract_Products.pricing_level_id = 1 OR Contract_Products.pricing_level_id = 0)
					AND ph.product_hierarchy_id = BSA_Foodservice_items_master.product_hierarchy_id)
				INNER join product_hierarchy ph4
				on ph4.Product_hierarchy_level = 4
				and left(ph4.product_hierarchy, len(ph.product_hierarchy)) = ph.product_hierarchy
	INNER JOIN Contract_Distributors
	ON Contract_Distributors.contract_main_id = contract_products.contract_main_id
	and Contract_Distributors.deleted = 0
	<cfif trim(arguments.template_code) EQ 'BGRP'>
	and Contract_Distributors.is_group =1
	</cfif>
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_Id = Contract_Distributors.BSA_Foodservice_Customers_Id
	INNER JOIN Distributor_Buying_Groups
	ON Distributor_Buying_Groups.Buying_Group_id = BSA_Foodservice_Customers.Buying_Group_id
	INNER JOIN Program_Growth_Component_Product_Data
	ON Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
	and Program_Growth_Component_Product_Data.deleted = 0
	INNER JOIN Program_Growth_Component_Product_Tier_Data
	ON Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
	AND Program_Growth_Component_Product_Tier_Data.deleted = 0
	<!--- Commented out (SQL comments below) because Templates were not following these rules.  LOC templates had UOM 1 etc... --->
	<cfif trim(arguments.template_code) EQ 'REG' OR trim(arguments.template_code) EQ 'LOC' OR trim(arguments.template_code) EQ 'BGRP'
	OR trim(arguments.template_code) EQ 'CORP'>
	--and Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID = 3
	<cfelseif trim(arguments.template_code) EQ 'DOLL'>
	--and Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID = 1
	<cfelse>
	--and Program_Growth_Component_Product_Tier_Data.Unit_Of_Measure_ID = 3
	</cfif>
	INNER JOIN Program_Growth_Components
	ON 
	Program_Growth_Components.Program_Growth_Component_ID =Program_Growth_Component_Product_Data.Program_Growth_Component_ID
	and Program_Growth_Components.program_id = Contract_Products.Contract_Main_ID
	and Program_Growth_Components.deleted = 0
	INNER JOIN Program_Payment_Cycle
	ON Program_Payment_Cycle.program_id = Contract_Products.Contract_Main_ID
	and Program_Payment_Cycle.Discount_Type_ID = Contract_Products.Product_Type_ID
	and Program_Payment_Cycle.deleted = 0
	and Program_Payment_Cycle.component_id = Program_Growth_Components.Growth_Component_Name_Id
	INNER JOIN Payment_Cycle
	ON Payment_Cycle.Payment_Cycle_Id = Program_Payment_Cycle.Payment_Cycle_ID
	where
			Contract_Products.Contract_Main_ID =  '#arguments.Program_ID#'
			AND dbo.Contract_Products.Deleted = 0
			AND dbo.Contract_Products.Product_Type_ID = 4
			--and cast(rate as float) != 0
			and ph4.deleted = 0
	<cfif isdefined("arguments.component_id") and arguments.component_id neq "">
	and Growth_Component_Name_Id = '#arguments.component_id#'
	</cfif>
	group by Growth_Component_Name_Id,pricing_level_id,ph4.product_hierarchy,BSA_Foodservice_Customers.Shr_Ship_To,Buying_Group,Payment_Cycle.External_Id,Payment_Cycle.Payment_Cycle_Id
	order by Growth_Component_Name_Id
</cfif>
</CFQUERY>
<cfreturn qgetProgramRates />
</cffunction>

<cffunction name="getProgramStatus" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="product_type_id" type="string" required="true" />
<CFQUERY NAME="qgetProgramStatus" datasource="#application.datasource#">
select *
from Program_WebServices_Detail
where program_id = '#arguments.Program_ID#'
and Program_Discount_Type_ID = '#arguments.product_type_id#'
and deleted = 0
</CFQUERY>
<cfreturn qgetProgramStatus />
</cffunction>

<cffunction name="getProgramsSent" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<CFQUERY NAME="qgetProgramsSent" datasource="#application.datasource#">
	
select distinct
Program_Rebates_Component.Program_Rebates_Component_Name_ID
from
contract_products
INNER JOIN Program_Rebates_Product_Data
ON Program_Rebates_Product_Data.Contract_Products_ID = contract_products.Contract_Products_ID
and Program_Rebates_Product_Data.deleted = 0
and Program_Rebates_Product_Data.Program_ID = contract_products.contract_main_id
INNER JOIN
Program_Rebates_Component_Data
ON Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_Id
and Program_Rebates_Component_Data.deleted = 0
INNER JOIN Program_Rebates_Component
ON Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID
and Program_Rebates_Component.deleted = 0
and Program_Rebates_Component.program_id = contract_products.contract_main_id
where 
contract_products.deleted = 0
and contract_products.contract_main_id =  '#arguments.Program_ID#'
and Contract_Products.product_Type_ID = 2
and 
Program_Rebates_Component.Program_Rebates_Component_Name_ID NOT IN (select distinct Component_Name_ID from Program_WebServices_Detail
	INNEr JOIN Program_WebServices_Error_Detail
	ON Program_WebServices_Error_Detail.BSA_Program_Id = Program_WebServices_Detail.BSA_Program_Id
	and Program_WebServices_Error_Detail.deleted = 0
	and Program_WebServices_Error_Detail.message_type ='S'
	where Program_WebServices_Detail.program_id = contract_products.contract_main_id
	and Program_WebServices_Detail.Program_Discount_Type_ID = Contract_Products.product_Type_ID)

UNION
select distinct
Program_Lumps_Sum_Ext_Id
from
contract_products
INNER JOIN Program_Lump_Sum_Product_Data
ON Program_Lump_Sum_Product_Data.Contract_Products_ID = contract_products.Contract_Products_ID
and Program_Lump_Sum_Product_Data.deleted = 0
INNER JOIN Program_Lump_Sums
ON Program_Lump_Sums.Program_ID = Contract_Products.Contract_Main_ID
AND Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
and Program_Lump_Sums.deleted = 0
where 
contract_products.deleted = 0
and contract_products.contract_main_id =  '#arguments.Program_ID#'
and Contract_Products.product_Type_ID = 3
and 
Program_Lumps_Sum_Ext_Id NOT IN (select distinct Component_Name_ID from Program_WebServices_Detail
	INNEr JOIN Program_WebServices_Error_Detail
	ON Program_WebServices_Error_Detail.BSA_Program_Id = Program_WebServices_Detail.BSA_Program_Id
	and Program_WebServices_Error_Detail.deleted = 0
	and Program_WebServices_Error_Detail.message_type ='S'
	where Program_WebServices_Detail.program_id = contract_products.contract_main_id
	and Program_WebServices_Detail.Program_Discount_Type_ID = Contract_Products.product_Type_ID)
UNION
select distinct
Growth_Component_Name_Id
from
contract_products
INNER JOIN Program_Growth_Component_Product_Data
ON Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
and Program_Growth_Component_Product_Data.deleted = 0
INNER JOIN Program_Growth_Component_Product_Tier_Data
ON Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
AND Program_Growth_Component_Product_Tier_Data.deleted = 0
INNER JOIN Program_Growth_Components
ON 
Program_Growth_Components.Program_Growth_Component_ID =Program_Growth_Component_Product_Data.Program_Growth_Component_ID
and Program_Growth_Components.program_id = Contract_Products.Contract_Main_ID
and Program_Growth_Components.deleted = 0
where 
contract_products.deleted = 0
and contract_products.contract_main_id =  '#arguments.Program_ID#'
and Contract_Products.product_Type_ID = 4
and 
Growth_Component_Name_Id NOT IN (select distinct Component_Name_ID from Program_WebServices_Detail
	INNEr JOIN Program_WebServices_Error_Detail
	ON Program_WebServices_Error_Detail.BSA_Program_Id = Program_WebServices_Detail.BSA_Program_Id
	and Program_WebServices_Error_Detail.deleted = 0
	and Program_WebServices_Error_Detail.message_type ='S'
	where Program_WebServices_Detail.program_id = contract_products.contract_main_id
	and Program_WebServices_Detail.Program_Discount_Type_ID = Contract_Products.product_Type_ID)
	</CFQUERY>
<cfreturn qgetProgramsSent/>
</cffunction>


<cffunction name="getlumpprodsvolume" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<CFQUERY NAME="qgetlumpprodsvolume" datasource="#application.datasource#">
	select cast(ISNULL(cast(sum((volume_cs * (datediff(day,contract_start_date,contract_end_date) + 1))/7) as decimal(20,2)),0) as decimal(20,0)) as volume_cs,Right(RTrim(product_hierarchy), 3) as Product_Group_ID
	 from contract_main
	inner join 
	contract_products on
	contract_products.contract_main_id = contract_main.contract_main_id
	and contract_products.deleted = 0
	inner join
	program_product_volume on
	program_product_volume.program_id = contract_products.Contract_Main_ID and
	program_product_volume.BSA_Foodservice_Items_Master_ID = 	contract_products.BSA_Foodservice_Items_Master_ID
	and program_product_volume.deleted = 0
	INNER JOIN BSA_Foodservice_Items_Master ON 
	program_product_volume.BSA_Foodservice_Items_Master_ID = 		dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID	
	INNER join product_hierarchy on 	
	product_hierarchy.product_hierarchy_id = BSA_Foodservice_Items_Master.product_hierarchy_id
	and product_hierarchy.deleted = 0
	where contract_main.Contract_Main_ID = '#arguments.Program_ID#'
	--and contract_products.deleted = 0
	and Contract_Products.Product_Type_ID = 3
	and ISNULL(volume_cs,0) ! = 0
	group by BSA_Foodservice_Items_Master.product_hierarchy_id,product_hierarchy
	</CFQUERY>
<cfreturn qgetlumpprodsvolume/>
</cffunction>


<cffunction name="getCancelledPrograms" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<CFQUERY NAME="qgetCancelledPrograms" datasource="#application.datasource#">
	select distinct Program_Webservices_Error_Detail.Pactiv_Program_Id,Program_Webservices_Detail.BSA_program_id from
		Program_Webservices_Error_Detail
		INNER JOIN
		Program_Webservices_Detail ON
		Program_Webservices_Detail.Bsa_Program_Id = Program_Webservices_Error_Detail.BSA_program_id
		and Program_Webservices_Detail.deleted = 0
		inner join program_period_dates ON 
		program_period_dates.bsa_program_id = Program_Webservices_Detail.bsa_program_id
		where
		Program_Webservices_Error_Detail.message_type ='S'
		and Program_Webservices_Detail.program_id = '#arguments.Program_ID#'
		and (Program_Webservices_Detail.program_status is null or Program_Webservices_Detail.program_status = 'NULL')
		and Program_Webservices_Detail.SAP_Deleted_Status != 1
		and (getdate() between program_period_dates.period_start_date and program_period_dates.period_end_date
		OR program_period_dates.period_start_date >= getdate())

	</CFQUERY>
	<cfreturn qgetCancelledPrograms/>
</cffunction>

<cffunction name="getPurgedPrograms" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<CFQUERY NAME="qgetPurgedPrograms" datasource="#application.datasource#">
	select distinct Program_Webservices_Error_Detail.Pactiv_Program_Id,Program_Webservices_Detail.BSA_program_id from
		Program_Webservices_Error_Detail
		INNER JOIN
		Program_Webservices_Detail ON
		Program_Webservices_Detail.Bsa_Program_Id = Program_Webservices_Error_Detail.BSA_program_id
		and Program_Webservices_Detail.deleted = 0
		where
		Program_Webservices_Error_Detail.message_type ='S'
		and Program_Webservices_Detail.program_id = '#arguments.Program_ID#'
		and (Program_Webservices_Detail.program_status is null or Program_Webservices_Detail.program_status = 'NULL')
		and Program_Webservices_Detail.SAP_Deleted_Status != 1
	</CFQUERY>
	<cfreturn qgetPurgedPrograms/>
</cffunction>

<cffunction name="getRebateChildren" access="public" returntype="query">
	<cfargument name="programbuffer" type="string" required="false" />
	<cfargument name="bsa_program_id" type="string" required="false" />
	<CFQUERY NAME="qgetRebateChildren" datasource="#application.datasource#">
		select program_period_dates.*,contract_main.approved_by_user_id,external_id
		from program_period_dates
		INNER JOIN
		contract_main ON
		contract_main.contract_main_id = program_period_dates.program_id
		and contract_main.deleted = 0

		left JOIN Program_Rebates_Component prc ON
	   	 prc.program_id = contract_main.contract_main_id
		and prc.deleted = 0
		left JOIN program_rebates_component_name PRCN ON
		PRCN.Program_Rebates_Component_Name_ID = prc.Program_Rebates_Component_Name_ID

		where 0=0
		and SAP_Deleted_Status = 0
		<cfif isdefined("arguments.bsa_program_id") and arguments.bsa_program_id NEQ "">
		and BSA_program_id = '#arguments.bsa_program_id#'
		<cfelse>
		and BSA_program_id NOT IN(
		select BSA_program_id from
		Program_Webservices_Error_Detail
		where
		Program_Webservices_Error_Detail.message_type ='S'
		 and deleted = 0
		 )
		and datediff(d,getdate(),program_period_dates.Period_Start_Date) <= '#arguments.programbuffer#'
		and contract_main.contract_status_type_idx >= 3
		and contract_main.contract_status_type_idx < 7
		</cfif>
		order by program_payment_period, program_period_dates.program_id,BSA_program_id
	</CFQUERY>
	<cfreturn qgetRebateChildren/>
</cffunction>

<cffunction name="getRebateXML" access="public" returntype="query">
	<cfargument name="bsa_program_id" type="string" required="true" />
	<cfargument name="program_id" type="string" required="true" />
	<CFQUERY NAME="getRebateXML" datasource="#application.datasource#">
	select *
	from Program_Webservices_Detail
	where
	bsa_program_id like '%#arguments.bsa_program_id#%'
	and program_id = '#arguments.program_id#'
	and deleted = 0
	</CFQUERY>
	<cfreturn getRebateXML/>
</cffunction>

<cffunction name="getThisProgramsStatus" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<CFQUERY NAME="qgetThisProgramsStatus" datasource="#application.datasource#">
			SELECT Contract_Status_Type_IDX, Revision_Of_Contract_Main_ID, Broker_User_ID, Contract_Number, Contract_Title,Adv_Spending_Amount
			FROM Contract_main
			WHERE Contract_main_ID = #arguments.program_id#
		</CFQUERY>
	<cfreturn qgetThisProgramsStatus />
</cffunction>


<cffunction name="getRebateChildrenDetails" access="public" returntype="query">
<cfargument name="bsa_program_id" type="string" required="false" />
<cfargument name="pactiv_program_id" type="string" required="false" />
<cfargument name="SQL_Sort_by" type="string" required="false" />
<CFQUERY NAME="qgetRebateChildrenDetails" datasource="#application.datasource#">
select distinct program_id,Program_Webservices_Detail.BSA_program_id, max(approved_date) as approved_date, 
cast(isnull(pactiv_program_id, 0) as int) as pactiv_program_id, 
case when message_type = 'E' then
''
else
message_text
end as message_text
,message_type from
Program_Webservices_Detail
left join Program_Webservices_Error_Detail
ON Program_Webservices_Error_Detail.BSA_program_id = Program_Webservices_Detail.BSA_program_id
and (message_type = 'S' OR (message_type = 'E' and not exists (select top 1 * from  Program_Webservices_Error_Detail as PWE where PWE.bsa_program_id = Program_Webservices_Detail.BSA_program_id and PWE.message_type = 'S' and schedule_sent = 1)))
where  schedule_sent = 1
<cfif isdefined("arguments.bsa_program_id") and arguments.bsa_program_id NEQ "">
	and Program_Webservices_Detail.BSA_program_id = '#arguments.bsa_program_id#'
</cfif>
<cfif isdefined("arguments.pactiv_program_id") and arguments.pactiv_program_id NEQ "">
	and Program_Webservices_Error_Detail.pactiv_program_id = '#arguments.pactiv_program_id#'
</cfif>
group by program_id,Program_Webservices_Detail.BSA_program_id, approved_date, 
pactiv_program_id, message_text,message_type
<cfif isdefined("arguments.SQL_Sort_by") and arguments.SQL_Sort_by NEQ "">
order by #arguments.SQL_Sort_by#
<cfelse>
order by approved_date desc, program_id,Program_Webservices_Detail.bsa_program_id,pactiv_program_id,message_text,message_type
</cfif>
	</CFQUERY>
	<cfreturn qgetRebateChildrenDetails />
</cffunction>
<cffunction name="getPaymentHeader" access="public" returntype="query">
	<cfargument name="Billback_Id" type="string" required="yes">
	<CFQUERY NAME="qGetPaymentHeader" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT 
					' ' 						as Active_code,
					U_Approve.user_code 		as approved_By,
					bs.Approved_on 				as approved_Date,
					U_Create.user_code 			as Created_By,
					bs.Created_Date 			as Created_Date,
					Null 						as Credit_Order,
					Null 						as Credit_Order_Date,
					Bppp.bsa_program_id 		as rebate_ID,
					Pwed.pactiv_program_id		as rebate_Ref_ID, 
					NULL						as SAP_Accrual,
					SP_Reason_Code				as settlement_Reason_Code,
					Paid_Amount					as settlement_Total,
					WithHold_Amt				as settlement_Withhold_Amt,
					SP_Reason_code				as settlement_Withhold_Ref,
					bfc.Shr_Ship_To				as shared_ShipTo
				
		FROM 		BB_Approved ba
		LEFT JOIN	BB_Settlement bs 
				ON bs.Billback_ID = ba.Billback_ID
		LEFT JOIN  	BB_ShortPay_Reason bsr 
				ON bsr.BB_ShortPay_Reason_ID = bs.BB_ShortPay_Reason_ID
		LEFT JOIN 	Billback_Program_Payment_Period bppp 
				ON bppp.Billback_ID = ba.Billback_ID
		LEFT JOIN 	Program_Webservices_error_Detail pwed 
				ON pwed.bsa_program_id = bppp.bsa_program_id
		LEFT JOIN 	Contract_Main C 
				ON C.Contract_Main_id = bppp.program_id
		LEFT JOIN 	BSA_Foodservice_Customers bfc 
				ON bfc.BSA_Foodservice_Customers_ID = c.Rebate_Recipient_Customer_ID
		LEFT JOIN _Users U_Approve
				ON U_Approve.User_ID = <cfif isdefined("arguments.User_Id")>'#arguments.User_Id#'<cfelse>bs.Approved_By</cfif>
		LEFT JOIN _Users U_create
				ON U_create.User_ID = <cfif isdefined("arguments.User_Id")>'#arguments.User_Id#'<cfelse>bs.created_Updated_User_id</cfif>
		WHERE 	ba.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>

<cfreturn qGetPaymentHeader>
</cffunction>

<!--- The next one is not used.  we may need something like it for the contract feeder BB's.  htis one does not join on Billback_Program_Payment_Period.
A second solution would br to include manual bb"s (or uploaded) in the Billback_Program_Payment_Period table used by auto auto. --->
<cffunction name="getPaymentHeaderManual" access="public" returntype="query">
	<cfargument name="Billback_Id" type="string" required="yes">
	<CFQUERY NAME="qGetPaymentHeaderManual" DATASOURCE="#Application.Datasource#">
		SELECT 		DISTINCT 
					' ' 						as Active_code,
					U_Approve.user_code 		as approved_By,
					bs.Approved_on 				as approved_Date,
					U_Create.user_code 			as Created_By,
					bs.Created_Date 			as Created_Date,
					Null 						as Credit_Order,
					Null 						as Credit_Order_Date,
					ppd.bsa_program_id 			as rebate_ID,  				---- contract.RR.001
					Pwed.pactiv_program_id		as rebate_Ref_ID,   		---INT  
					NULL						as SAP_Accrual,
					SP_Reason_Code				as settlement_Reason_Code,
					Paid_Amount					as settlement_Total,
					WithHold_Amt				as settlement_Withhold_Amt,
					SP_Reason_code				as settlement_Withhold_Ref,
					bfc.Shr_Ship_To	as shared_ShipTo
		FROM 		BB_Approved ba
		INNER JOIN Billback b on b.Billback_ID = ba.Billback_ID
		LEFT JOIN	BB_Settlement bs ON bs.Billback_ID = ba.Billback_ID
		LEFT JOIN  	BB_ShortPay_Reason bsr ON bsr.BB_ShortPay_Reason_ID = bs.BB_ShortPay_Reason_ID
		---LEFT JOIN Billback_Program_Payment_Period bppp on bppp.Billback_ID = BB_Approved.Billback_ID
		LEFT JOIN Billback_Program bp ON bp.Billback_ID = ba.Billback_ID
		LEFT JOIN program_period_dates ppd ON ppd.program_id = bp.program_id
		LEFT JOIN Program_Webservices_error_Detail pwed ON pwed.bsa_program_id = ppd.bsa_program_id
		LEFT JOIN Contract_Main C ON C.Contract_Main_id = bp.program_id
		LEFT JOIN BSA_Foodservice_Customers bfc on bfc.BSA_Foodservice_Customers_ID = c.Rebate_Recipient_Customer_ID
		LEFT JOIN _Users U_Approve
				ON U_Approve.User_ID = <cfif isdefined("arguments.User_Id")>'#arguments.User_Id#'<cfelse>BB_Settlement.Approved_By</cfif>
		LEFT JOIN _Users U_create
				ON U_create.User_ID = <cfif isdefined("arguments.User_Id")>'#arguments.User_Id#'<cfelse>BB_Settlement.created_Updated_User_id</cfif>
		WHERE 		BB_Approved.Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND BB_Start_Date = period_start_date AND BB_end_Date = period_end_date
	</CFQUERY>

<cfreturn qGetPaymentHeaderManual>
</cffunction>
