<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<CFQUERY NAME="Get_program_Data" DATASOURCE="#application.datasource#">
	Select contract_start_date, contract_end_date, contract_title, contract_number, revision_version, contract_status_type_desc, contract_main_id
	from contract_main
	inner join contract_status_types on	contract_status_types.contract_status_type_id =	contract_main.contract_status_type_idx
	where contract_main_id = <cfqueryparam value="#url.program_id#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

<CFQUERY NAME="Get_parent_Data" DATASOURCE="#application.datasource#">
	Select contract_start_date, contract_end_date, contract_title, revision_version, contract_status_type_desc, contract_main_id
	from contract_main
	inner join contract_status_types on	contract_status_types.contract_status_type_id =	contract_main.contract_status_type_idx
	where contract_main_id = <cfqueryparam value="#url.parent_program_id#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

<!--- Distributors --->
<cfquery name="Get_All_Distributors" datasource="#application.datasource#">
	Select distinct shr_ship_to,name,
			contract_distributors.bsa_foodservice_customers_id AS bsa_foodservice_customers_id,
			b.bsa_foodservice_customers_id AS ParentDistributor,
			a.bsa_foodservice_customers_id AS RevisionDistributor
	from contract_distributors
	inner join	bsa_foodservice_customers on bsa_foodservice_customers.bsa_foodservice_customers_id = contract_distributors.bsa_foodservice_customers_id
	LEFT OUTER JOIN (	Select 	contract_distributors.bsa_foodservice_customers_id
						from contract_distributors
						where contract_distributors.contract_main_id = <cfqueryparam value="#url.program_id#" cfsqltype="CF_SQL_INTEGER">
						and contract_distributors.deleted = 0
					) a
	ON contract_distributors.bsa_foodservice_customers_id = a.bsa_foodservice_customers_id
	LEFT OUTER JOIN (	Select contract_distributors.bsa_foodservice_customers_id
						from contract_distributors
						where contract_distributors.contract_main_id = <cfqueryparam value="#url.parent_program_id#" cfsqltype="CF_SQL_INTEGER">
						and contract_distributors.deleted = 0
					) b
	ON contract_distributors.bsa_foodservice_customers_id = b.bsa_foodservice_customers_id
	where contract_distributors.contract_main_id IN (<cfqueryparam value="#url.program_id#" cfsqltype="CF_SQL_INTEGER">,<cfqueryparam value="#url.parent_program_id#" cfsqltype="CF_SQL_INTEGER">)
	and (a.bsa_foodservice_customers_id is null OR b.bsa_foodservice_customers_id is null)
	and contract_distributors.deleted = 0
	order by b.bsa_foodservice_customers_id, name
</cfquery>
<!--- End Distributor Code --->

<!--- Operators --->
<cfquery name="Get_All_Operators" datasource="#application.datasource#">
	Select distinct operator_name,
			bsa_operator.bsa_operator_id AS bsa_operator_id,
			isnull(bsa_operator.Legacy_ID, bsa_operator.bsa_operator_id) as Legacy_ID,
			a.bsa_operator_id AS RevisionOperator,
			b.bsa_operator_id AS ParentOperator
	from contract_operators
	inner join bsa_operator on bsa_operator.bsa_operator_id = contract_operators.bsa_operator_id
	LEFT OUTER JOIN (	Select contract_operators.bsa_operator_id
						from contract_operators
						where contract_operators.contract_main_id = <cfqueryparam value="#url.program_id#" cfsqltype="CF_SQL_INTEGER">
		 				and contract_operators.deleted = 0
		 			) a
	ON contract_operators.bsa_operator_id = a.bsa_operator_id
	LEFT OUTER JOIN (	Select contract_operators.bsa_operator_id
						from contract_operators
						where contract_operators.contract_main_id = <cfqueryparam value="#url.parent_program_id#" cfsqltype="CF_SQL_INTEGER">
		 				and contract_operators.deleted = 0
		 			) b
	ON contract_operators.bsa_operator_id = b.bsa_operator_id
	where contract_operators.contract_main_id IN (<cfqueryparam value="#url.program_id#" cfsqltype="CF_SQL_INTEGER">,<cfqueryparam value="#url.parent_program_id#" cfsqltype="CF_SQL_INTEGER">)
	and (a.bsa_operator_id is null or b.bsa_operator_id is null)
	and contract_operators.deleted =0
	order by  b.bsa_operator_id, operator_name
</cfquery>
<!--- End Operator Code --->


<!--- Lumpsum --->
<cfquery name="Get_All_LumpSum" datasource="#application.datasource#">

	Declare @child_cmid int,
		@parent_cmid int

	set @parent_cmid = <cfqueryparam value="#url.parent_program_id#" cfsqltype="cf_sql_integer">
	set @child_cmid = <cfqueryparam value="#url.program_id#" cfsqltype="cf_sql_integer">

	select	distinct
		parent_lumpsum.Program_Lumps_Sum_Ext_Id as parent_Program_Lumps_Sum_Ext_Id,
		parent_lumpsum.Lump_Revision_Comp_ID as Parent_Lump_Revision_Comp_ID,
		parent_Lump_Sum_Name.Program_Lump_Sum_Name as Parent_Lump_Sum_Name,

		child_lumpsum.Program_Lumps_Sum_Ext_Id as Child_Program_Lumps_Sum_Ext_Id,
		child_lumpsum.Lump_Revision_Comp_ID as Child_Lump_Revision_Comp_ID,
		child_Lump_Sum_Name.Program_Lump_Sum_Name as Child_Lump_Sum_Name,
		'changed' as change_type,

		parent_lumpsum.Lump_Sum_Amount as parent_Lump_Sum_Amount,
		parent_lumpsum.Lump_Sum_Volume as parent_Lump_Sum_Volume,
		parent_Payment_Paid_To_Types.Payment_Paid_To_Type_Name  as parent_Component_Paid_To,
		parent_Payment_Type.Payment_Type_Name as parent_Claim_Mechanics,

		child_lumpsum.Lump_Sum_Amount as child_Lump_Sum_Amount,
		child_lumpsum.Lump_Sum_Volume as child_Lump_Sum_Volume,
		child_Payment_Paid_To_Types.Payment_Paid_To_Type_Name as child_Component_Paid_To,
		child_Payment_Type.Payment_Type_Name as child_Claim_Mechanics


	from	Program_Lump_Sums as parent_lumpsum

	inner join Program_Lump_Sums as child_lumpsum
	on	child_lumpsum.program_id = @child_cmid
	and	child_lumpsum.deleted = 0
	and	(child_lumpsum.Lump_Revision_Comp_ID = parent_lumpsum.Program_Lumps_Sum_Ext_Id or child_lumpsum.Lump_Revision_Comp_ID = parent_lumpsum.Lump_Revision_Comp_ID)

	left join Program_Lump_Sum_Name as parent_Lump_Sum_Name
	on	parent_Lump_Sum_Name.Program_Lump_Sum_Name_ID = parent_lumpsum.Program_Lump_Sum_Name_ID

	left join Program_Lump_Sum_Name as child_Lump_Sum_Name
	on	child_Lump_Sum_Name.Program_Lump_Sum_Name_ID = child_lumpsum.Program_Lump_Sum_Name_ID

	left join Payment_Type as parent_Payment_Type
	on	parent_Payment_Type.Payment_Type_ID = parent_lumpsum.Claim_Mechanics

	left join Payment_Type as child_Payment_Type
	on	child_Payment_Type.Payment_Type_ID =child_lumpsum.Claim_Mechanics

	left join Payment_Paid_To_Types as parent_Payment_Paid_To_Types
	on	parent_Payment_Paid_To_Types.Payment_Paid_To_Type_ID = parent_lumpsum.Component_Paid_To

	left join Payment_Paid_To_Types as child_Payment_Paid_To_Types
	on	child_Payment_Paid_To_Types.Payment_Paid_To_Type_ID =  child_lumpsum.Component_Paid_To

	where	parent_lumpsum.program_id = @parent_cmid
	and	parent_lumpsum.deleted = 0
	and 	parent_lumpsum.lump_sum_amount <> child_lumpsum.lump_sum_amount
	and 	parent_lumpsum.lump_sum_volume <> child_lumpsum.lump_sum_volume
	and 	parent_lumpsum.component_paid_to <> child_lumpsum.component_paid_to
	and 	parent_lumpsum.claim_mechanics <> child_lumpsum.claim_mechanics
	and 	parent_lump_sum_name.program_lump_sum_name <> child_lump_sum_name.program_lump_sum_name

	union

	select	distinct
		parent_lumpsum.Program_Lumps_Sum_Ext_Id as parent_Program_Lumps_Sum_Ext_Id,
		parent_lumpsum.Lump_Revision_Comp_ID as Parent_Lump_Revision_Comp_ID,
		parent_Lump_Sum_Name.Program_Lump_Sum_Name as Parent_Lump_Sum_Name,

		child_lumpsum.Program_Lumps_Sum_Ext_Id as Child_Program_Lumps_Sum_Ext_Id,
		child_lumpsum.Lump_Revision_Comp_ID as Child_Lump_Revision_Comp_ID,
		child_Lump_Sum_Name.Program_Lump_Sum_Name as Child_Lump_Sum_Name,
		'removed' as change_type,

		parent_lumpsum.Lump_Sum_Amount as parent_Lump_Sum_Amount,
		parent_lumpsum.Lump_Sum_Volume as parent_Lump_Sum_Volume,
		parent_Payment_Paid_To_Types.Payment_Paid_To_Type_Name  as parent_Component_Paid_To,
		parent_Payment_Type.Payment_Type_Name as parent_Claim_Mechanics,

		child_lumpsum.Lump_Sum_Amount as child_Lump_Sum_Amount,
		child_lumpsum.Lump_Sum_Volume as child_Lump_Sum_Volume,
		child_Payment_Paid_To_Types.Payment_Paid_To_Type_Name as child_Component_Paid_To,
		child_Payment_Type.Payment_Type_Name as child_Claim_Mechanics

	from	Program_Lump_Sums as parent_lumpsum

	left join Program_Lump_Sums as child_lumpsum
	on	child_lumpsum.program_id = @child_cmid
	and	child_lumpsum.deleted = 0
	and	(child_lumpsum.Lump_Revision_Comp_ID = parent_lumpsum.Program_Lumps_Sum_Ext_Id or child_lumpsum.Lump_Revision_Comp_ID = parent_lumpsum.Lump_Revision_Comp_ID)

	left join Program_Lump_Sum_Name as parent_Lump_Sum_Name
	on	parent_Lump_Sum_Name.Program_Lump_Sum_Name_ID = parent_lumpsum.Program_Lump_Sum_Name_ID

	left join Program_Lump_Sum_Name as child_Lump_Sum_Name
	on	child_Lump_Sum_Name.Program_Lump_Sum_Name_ID = child_lumpsum.Program_Lump_Sum_Name_ID

	left join Payment_Type as parent_Payment_Type
	on	parent_Payment_Type.Payment_Type_ID = parent_lumpsum.Claim_Mechanics

	left join Payment_Type as child_Payment_Type
	on	child_Payment_Type.Payment_Type_ID =child_lumpsum.Claim_Mechanics

	left join Payment_Paid_To_Types as parent_Payment_Paid_To_Types
	on	parent_Payment_Paid_To_Types.Payment_Paid_To_Type_ID = parent_lumpsum.Component_Paid_To

	left join Payment_Paid_To_Types as child_Payment_Paid_To_Types
	on	child_Payment_Paid_To_Types.Payment_Paid_To_Type_ID =  child_lumpsum.Component_Paid_To

	where	parent_lumpsum.program_id = @parent_cmid
	and	parent_lumpsum.deleted = 0
	and	child_lumpsum.Program_Lump_Sum_ID is null

	union

	select	distinct
		parent_lumpsum.Program_Lumps_Sum_Ext_Id as parent_Program_Lumps_Sum_Ext_Id,
		parent_lumpsum.Lump_Revision_Comp_ID as Parent_Lump_Revision_Comp_ID,
		parent_Lump_Sum_Name.Program_Lump_Sum_Name as Parent_Lump_Sum_Name,

		child_lumpsum.Program_Lumps_Sum_Ext_Id as Child_Program_Lumps_Sum_Ext_Id,
		child_lumpsum.Lump_Revision_Comp_ID as Child_Lump_Revision_Comp_ID,
		child_Lump_Sum_Name.Program_Lump_Sum_Name as Child_Lump_Sum_Name,
		'added' as change_type,

		parent_lumpsum.Lump_Sum_Amount as parent_Lump_Sum_Amount,
		parent_lumpsum.Lump_Sum_Volume as parent_Lump_Sum_Volume,
		parent_Payment_Paid_To_Types.Payment_Paid_To_Type_Name  as parent_Component_Paid_To,
		parent_Payment_Type.Payment_Type_Name as parent_Claim_Mechanics,

		child_lumpsum.Lump_Sum_Amount as child_Lump_Sum_Amount,
		child_lumpsum.Lump_Sum_Volume as child_Lump_Sum_Volume,
		child_Payment_Paid_To_Types.Payment_Paid_To_Type_Name as child_Component_Paid_To,
		child_Payment_Type.Payment_Type_Name as child_Claim_Mechanics

	from	Program_Lump_Sums as child_lumpsum

	left join Program_Lump_Sums as parent_lumpsum
	on	parent_lumpsum.program_id = @parent_cmid
	and	parent_lumpsum.deleted = 0
	and	(child_lumpsum.Lump_Revision_Comp_ID = parent_lumpsum.Program_Lumps_Sum_Ext_Id or child_lumpsum.Lump_Revision_Comp_ID = parent_lumpsum.Lump_Revision_Comp_ID)

	left join Program_Lump_Sum_Name as parent_Lump_Sum_Name
	on	parent_Lump_Sum_Name.Program_Lump_Sum_Name_ID = parent_lumpsum.Program_Lump_Sum_Name_ID

	left join Program_Lump_Sum_Name as child_Lump_Sum_Name
	on	child_Lump_Sum_Name.Program_Lump_Sum_Name_ID = child_lumpsum.Program_Lump_Sum_Name_ID

	left join Payment_Type as parent_Payment_Type
	on	parent_Payment_Type.Payment_Type_ID = parent_lumpsum.Claim_Mechanics

	left join Payment_Type as child_Payment_Type
	on	child_Payment_Type.Payment_Type_ID =child_lumpsum.Claim_Mechanics

	left join Payment_Paid_To_Types as parent_Payment_Paid_To_Types
	on	parent_Payment_Paid_To_Types.Payment_Paid_To_Type_ID = parent_lumpsum.Component_Paid_To

	left join Payment_Paid_To_Types as child_Payment_Paid_To_Types
	on	child_Payment_Paid_To_Types.Payment_Paid_To_Type_ID =  child_lumpsum.Component_Paid_To

	where	child_lumpsum.program_id = @child_cmid
	and	child_lumpsum.deleted = 0
	and	parent_lumpsum.Program_Lump_Sum_ID is null


</cfquery>
<!--- End Lumpsum --->

<!--- Growth --->
<cfquery name="Get_All_Growth" datasource="#application.datasource#">
	Declare @parent_ID int,
			@child_ID int

		Set @parent_ID =  <cfqueryparam value="#url.parent_program_id#" cfsqltype="cf_sql_integer">
		Set @child_ID =  <cfqueryparam value="#url.program_id#" cfsqltype="cf_sql_integer">

	Select
		parent_Contract_Products.Contract_Products_ID as parent_Contract_Products_ID,
		parent_Contract_Products.BSA_Foodservice_Items_Master_ID as parent_BSA_Foodservice_Items_Master_ID,

		child_Contract_Products.Contract_Products_ID as child_Contract_Products_ID,
		child_Contract_Products.BSA_Foodservice_Items_Master_ID as child_BSA_Foodservice_Items_Master_ID,

		parent_Program_Growth_Component_Product_Data.Program_Growth_Component_ID as parent_Program_Growth_Component_ID,
		parent_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID as parent_Program_Growth_Component_ID,

		child_Program_Growth_Component_Product_Data.Program_Growth_Component_ID as child_Program_Growth_Component_ID,
		child_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID as child_Program_Growth_Component_Product_Data_ID,

		parent_Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID as parent_Program_Growth_Component_Tier_ID,
		parent_Program_Growth_Component_Tiers.Tier_Number as parent_Tier_Number,

		child_Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID as child_Program_Growth_Component_Tier_ID,
		child_Program_Growth_Component_Tiers.Tier_Number as child_Tier_Number,

		parent_Program_Growth_Component_Product_Tier_Data.Rate as parent_Rate,
		child_Program_Growth_Component_Product_Tier_Data.Rate as child_Rate

	from 		Contract_Products as parent_Contract_Products

	left join 	Contract_Products as child_Contract_Products
		on	child_Contract_Products.Contract_Main_ID = @child_ID
		and 	child_Contract_Products.deleted = 0
		and	child_Contract_Products.Product_Type_ID = 4
		and	(child_Contract_Products.BSA_Foodservice_Items_Master_ID = parent_Contract_Products.BSA_Foodservice_Items_Master_ID)

	inner join 	Program_Growth_Component_Product_Data as parent_Program_Growth_Component_Product_Data
		on 	parent_Program_Growth_Component_Product_Data.Contract_Products_ID = parent_Contract_Products.Contract_Products_ID
		and 	parent_Program_Growth_Component_Product_Data.deleted = 0

	inner join 	Program_Growth_Component_Product_Data as child_Program_Growth_Component_Product_Data
		on 	child_Program_Growth_Component_Product_Data.Contract_Products_ID = child_Contract_Products.Contract_Products_ID
		and 	child_Program_Growth_Component_Product_Data.deleted = 0

	inner join 	Program_Growth_Component_Tiers as parent_Program_Growth_Component_Tiers
		on 	parent_Program_Growth_Component_Tiers.Program_ID = @parent_ID
		and	parent_Program_Growth_Component_Tiers.Program_Growth_Component_ID = parent_Program_Growth_Component_Product_Data.Program_Growth_Component_ID
		and 	parent_Program_Growth_Component_Tiers.deleted = 0

	inner join 	Program_Growth_Component_Tiers as child_Program_Growth_Component_Tiers
		on 	child_Program_Growth_Component_Tiers.Program_ID = @child_ID
		and	child_Program_Growth_Component_Tiers.Program_Growth_Component_ID = child_Program_Growth_Component_Product_Data.Program_Growth_Component_ID
		and	child_Program_Growth_Component_Tiers.Tier_Number =  parent_Program_Growth_Component_Tiers.Tier_Number
		and 	child_Program_Growth_Component_Tiers.deleted = 0

	inner join 	Program_Growth_Component_Product_Tier_Data as parent_Program_Growth_Component_Product_Tier_Data
		on 	parent_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = parent_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
		and	parent_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID  = parent_Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
		and 	parent_Program_Growth_Component_Product_Tier_Data.deleted = 0

	inner join 	Program_Growth_Component_Product_Tier_Data as child_Program_Growth_Component_Product_Tier_Data
		on 	child_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID = child_Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID
		and	child_Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID  = child_Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID
		and 	child_Program_Growth_Component_Product_Tier_Data.deleted = 0

	where		parent_Contract_Products.Contract_Main_ID = @parent_ID
		and 	parent_Contract_Products.deleted = 0
		and 	parent_Contract_Products.Product_Type_ID = 4
		and 	parent_Program_Growth_Component_Product_Tier_Data.Rate <> child_Program_Growth_Component_Product_Tier_Data.Rate

</cfquery>

<cfoutput>
<TABLE BORDER="0" ALIGN="center" CELLPADDING="2" CELLSPACING="0" WIDTH="90%">
	<TR>
		<TD BGCOLOR="Navy" colspan="50%"><FONT SIZE="2" COLOR="White"><B>#Get_program_Data.contract_number#-<cfif len(Get_program_Data.revision_version) eq 4>#right("#Get_program_Data.revision_version#", 4)#<cfelseif len(Get_program_Data.revision_version) eq 5>#right("#Get_program_Data.revision_version#", 5)#<cfelse>#right("000#Get_program_Data.revision_version#", 3)#</cfif>(#Get_parent_Data.contract_status_type_desc#)<br>Original Program</B></FONT></TD>
		<TD>&nbsp;</TD>
		<TD BGCOLOR="Navy" colspan="50%"><FONT SIZE="2" COLOR="White"><B>#Get_program_Data.contract_number#-<cfif len(Get_program_Data.revision_version) eq 4>#right("#Get_program_Data.revision_version#", 4)#<cfelseif len(Get_program_Data.revision_version) eq 5>#right("#Get_program_Data.revision_version#", 5)#<cfelse>#right("000#Get_program_Data.revision_version#", 3)#</cfif>(#Get_program_Data.contract_status_type_desc#)<br>Revised Program</B></FONT></TD>
	</TR>

	<cfif  (Get_parent_Data.contract_title NEQ Get_program_Data.contract_title)
		OR (Get_parent_Data.contract_start_date NEQ Get_program_Data.contract_start_date)
		OR (Get_parent_Data.contract_end_date NEQ Get_program_Data.contract_end_date) >
		<TR>
			<TD BGCOLOR="FFE083" colspan="50%"><b>Title & Delivery Dates</b></TD>
			<TD>&nbsp;</TD>
			<TD BGCOLOR="FFE083" colspan="50%"><b>Title & Delivery Dates</b></TD>
		</TR>
		<!--- Program Title --->
		<cfif Get_parent_Data.contract_title NEQ Get_program_Data.contract_title>
			<TR>
				<TD colspan="50%" BGCOLOR="CCFFCC">#Get_parent_Data.contract_title#</TD>
				<TD>&nbsp;</TD>
				<TD colspan="50%" BGCOLOR="CCFFCC"><span STYLE="color: red;">#Get_program_Data.contract_title#</span></TD>
			</TR>
		</cfif>
		<!--- Program Dates --->
		<cfif (Get_parent_Data.contract_start_date NEQ Get_program_Data.contract_start_date) OR (Get_parent_Data.contract_end_date NEQ Get_program_Data.contract_end_date)>
			<TR>
				<TD colspan="50%" BGCOLOR="CCFFCC">#Dateformat(Get_parent_Data.contract_start_date, "mm/dd/yyyy")# - #Dateformat(Get_parent_Data.contract_end_date, "mm/dd/yyyy")#</TD>
				<TD>&nbsp;</TD>
				<TD colspan="50%" BGCOLOR="CCFFCC">
					<span <cfif Get_parent_Data.contract_start_date NEQ Get_program_Data.contract_start_date>  STYLE="color: red;" </cfif>>#Dateformat(Get_program_Data.contract_start_date, "mm/dd/yyyy")# </span>- <span <cfif Get_parent_Data.contract_end_date NEQ Get_program_Data.contract_end_date> STYLE="color: red;"	</cfif>>#Dateformat(Get_program_Data.contract_end_date, "mm/dd/yyyy")#</span>
				</TD>
			</TR>
		</cfif>
	</cfif>

	<!--- Distributors --->
 	<cfif Get_All_Distributors.RecordCount NEQ 0>
		<TR>
			<TD colspan="50%" BGCOLOR="FFE083"><b>#ucase(application.returned_customer_setting.distributor_label_plural)#</b></TD>
			<TD>&nbsp;</TD>
			<TD colspan="50%" BGCOLOR="FFE083"><b>#ucase(application.returned_customer_setting.distributor_label_plural)#</b></TD>
		</TR>

		<cfloop query="Get_All_Distributors">
			<cfif len(Get_All_Distributors.ParentDistributor) EQ 0>
				<cfset parent_ship_to = "">
			<cfelse>
				<cfset parent_ship_to  = "#name# - #Get_All_Distributors.Shr_Ship_to#">
			</cfif>

			<cfif len(Get_All_Distributors.RevisionDistributor) EQ 0>
				<cfset revision_ship_to = "">
			<cfelse>
				<cfset revision_ship_to = "#name# - #Get_All_Distributors.Shr_Ship_to#">
			</cfif>

			<tr>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;" >#parent_ship_to#</td>
				<td>&nbsp;</td>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#revision_ship_to#</td>
			</tr>
		</cfloop>
	</cfif>

	<!---- Operators --->
	<cfif Get_All_Operators.RecordCount NEQ 0>
		<TR>
			<TD BGCOLOR="FFE083" colspan="50%"><b>#ucase(application.returned_customer_setting.operator_label_plural)#</b></TD>
			<TD>&nbsp;</TD>
			<TD BGCOLOR="FFE083" colspan="50%"><b>#ucase(application.returned_customer_setting.operator_label_plural)#</b></TD>
		</TR>

		<cfloop query="Get_All_Operators">
			<cfif len(Get_All_Operators.ParentOperator) EQ 0>
				<cfset parent_operator = "">
			<cfelse>
				<cfset parent_operator  = "#operator_name# - #Get_All_Operators.Legacy_ID#">
			</cfif>

			<cfif len(Get_All_Operators.RevisionOperator) EQ 0>
				<cfset revision_operator = "">
			<cfelse>
				<cfset revision_operator = "#operator_name# - #Get_All_Operators.Legacy_ID#">
			</cfif>

			<tr>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#parent_operator#</td>
				<td>&nbsp;</td>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#revision_operator#</td>
			</tr>
		</cfloop>
	</cfif>

	<!---- Lump Sum --->
	<cfif Get_All_LumpSum.RecordCount NEQ 0>
		<TR>
			<TD BGCOLOR="FFE083" colspan="50%"><b>Lump Sum</b></TD>
			<TD>&nbsp;</TD>
			<TD BGCOLOR="FFE083" colspan="50%"><b>Lump Sum</b></TD>
		</TR>

		<cfloop query="Get_All_LumpSum">

			<cfif lcase(Get_All_LumpSum.change_type) EQ "added">
				<cfset parent_lumpsum_name = "">
				<cfset child_lumpsum_name = "#Child_Lump_Sum_Name#">

				<cfset parent_Lump_Sum_Amount = "">
				<cfset child_Lump_Sum_Amount = "#Child_Lump_Sum_Amount#">

				<cfset parent_Component_Paid_To = "">
				<cfset child_Component_Paid_To = "#Child_Component_Paid_To#">

				<cfset parent_Claim_Mechanics = "">
				<cfset parent_Claim_Mechanics = "#Child_Claim_Mechanics#">

			<cfelseif  lcase(Get_All_LumpSum.change_type) EQ "removed">
				<cfset parent_lumpsum_name = "#Parent_Lump_Sum_Name#">
				<cfset child_lumpsum_name = "">

				<cfset parent_Lump_Sum_Amount = "#parent_Lump_Sum_Amount#">
				<cfset child_Lump_Sum_Amount = "">

				<cfset parent_Component_Paid_To = "#parent_Component_Paid_To#">
				<cfset child_Component_Paid_To = "">

				<cfset parent_Claim_Mechanics = "#parent_Claim_Mechanics#">
				<cfset parent_Claim_Mechanics = "">

			<cfelseif  lcase(Get_All_LumpSum.change_type) EQ "changed">
				<cfset parent_lumpsum_name = "#Parent_Lump_Sum_Name#">
				<cfset child_lumpsum_name = "#Child_Lump_Sum_Name#">

				<cfset parent_Lump_Sum_Amount = "#parent_Lump_Sum_Amount#">
				<cfset child_Lump_Sum_Amount = "#Child_Lump_Sum_Amount#">

				<cfset parent_Component_Paid_To = "#parent_Component_Paid_To#">
				<cfset child_Component_Paid_To = "#Child_Component_Paid_To#">

				<cfset parent_Claim_Mechanics = "#parent_Claim_Mechanics#">
				<cfset child_Claim_Mechanics = "#Child_Claim_Mechanics#">

			</cfif>

			<tr>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#parent_lumpsum_name# &nbsp; <cfif len(parent_Lump_Sum_Amount) GT 0 >#DollarFormat(parent_Lump_Sum_Amount)#</cfif></td>
				<td>&nbsp;</td>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#child_lumpsum_name# &nbsp; <cfif len(child_Lump_Sum_Amount) GT 0 >#DollarFormat(child_Lump_Sum_Amount)#</cfif></td>
			</tr>
			<tr>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#parent_Component_Paid_To#</td>
				<td>&nbsp;</td>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#child_Component_Paid_To#</td>
			</tr>
			<tr>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#parent_Claim_Mechanics# </td>
				<td>&nbsp;</td>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#child_Claim_Mechanics#</td>
			</tr>
		</cfloop>
	</cfif>

	<!---- Growth --->
	<cfif Get_All_Growth.RecordCount NEQ 0>
		<TR>
			<TD BGCOLOR="FFE083" colspan="50%"><b>Growth</b></TD>
			<TD>&nbsp;</TD>
			<TD BGCOLOR="FFE083" colspan="50%"><b>Growth</b></TD>
		</TR>

		<tr>
			<td colspan="50%" style="color:black;background-color:##CCFFCC;">&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="50%" style="color:black;background-color:##CCFFCC;">Growth Changed</td>
		</tr>

	</cfif>


	<!---32633 - gather program volume information for both parent program & child program--->
	<cfquery name="programVolume.userSetting" datasource="#application.datasource#">
		SELECT Volume_UOT_ID
		  FROM _Users_Settings
		 WHERE User_ID = '#request.AccessStructure.Company_Main_ID#'
	</cfquery>

	<cfscript>
		programVolume.component = CreateObject("component", "components.programs.volume.ProgramVolume");
		
		programVolume.child  = programVolume.component.getProgramQty( Get_program_Data.Contract_Main_ID
		                                                             ,Datediff('d', Get_program_Data.Contract_Start_Date, Get_program_Data.Contract_End_Date) + 1
		                                                             ,programVolume.userSetting.Volume_UOT_ID);
		                                                           
		programVolume.parent = programVolume.component.getProgramQty( Get_parent_Data.Contract_Main_ID
		                                                             ,Datediff('d', Get_parent_Data.Contract_Start_Date, Get_parent_Data.Contract_End_Date) + 1
		                                                             ,programVolume.userSetting.Volume_UOT_ID);
	</cfscript>
	
	<cfif isStruct(programVolume.child) and isStruct(programVolume.child)>
		<!---detect if there are changes in program volume--->
		<cfif (programVolume.child.ProgramQtgCases neq programVolume.parent.ProgramQtgCases)
		   or (programVolume.child.ProgramQtglbs   neq programVolume.parent.ProgramQtglbs)
		   or (programVolume.child.VolumeUOTCases  neq programVolume.parent.VolumeUOTCases)
		   or (programVolume.child.VolumeUOTlbs    neq programVolume.parent.VolumeUOTlbs)>
			<tr>
				<td bgcolor="ffe083" colspan="50%"><b>Program Volume</b></td>
				<td>&nbsp;</td>
				<td bgcolor="ffe083" colspan="50%"><b>Program Volume</b></td>
			</tr>
			
			<cfset programVolume.volumeUOM = application.appSettingsGet.getViewProgramVolumeUOM()>
			
			<!---display volumes from both parent program and child program--->
			<tr>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#showProgramVolume( programVolume.volumeUOM
																																														,programVolume.parent.ProgramQtgCases
																																														,programVolume.parent.ProgramQtglbs)# </td>
				<td>&nbsp;</td>
				<td colspan="50%" style="color:black;background-color:##CCFFCC;">#showProgramVolume( programVolume.volumeUOM
																																														,programVolume.child.ProgramQtgCases
																																														,programVolume.child.ProgramQtglbs)# </td>
			</tr>
		</cfif>
	</cfif>
</table>

<div style="text-align:center;margin-top:15px;">
	<CF_button
		button_name		=	""
		button_caption=	"close window"
		button_action	=	"window.close();"
		button_type		=	"javascript_link"
		button_width	=	"50"
		button_color	=	"Navy"
		button_tip		=	"Close Window"
		font_color		=	"White"
		font_size		  =	"12"
		font_weight		=	"bold"
	>
</div>			
</cfoutput>

<cffunction name="showProgramVolume" output="true">
	<cfargument name="volumeUOM" required="true">
	<cfargument name="ProgramQtgCases" required="true">
	<cfargument name="ProgramQtglbs" required="true">
	
	<cfif arguments.volumeUOM eq 1>
		#trim(numberformat(round(arguments.ProgramQtgCases),'___,___,___,___,___,___'))# Cases
	<cfelseif programVolume.volumeUOM eq 2>
		#trim(numberformat(round(arguments.ProgramQtglbs),'___,___,___,___,___,___'))# Pounds
	<cfelse>
		#trim(numberformat(round(arguments.ProgramQtgCases),'___,___,___,___,___,___'))# Cases / #trim(numberformat(round(arguments.ProgramQtglbs),'___,___,___,___,___,___'))# Pounds
	</cfif>
</cffunction>	
	

</body>
</html>
