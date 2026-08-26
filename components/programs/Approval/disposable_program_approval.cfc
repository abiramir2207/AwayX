<cfcomponent displayname="disposable_program_approval" hint="disposable_program_approval" extends="components.programs.Approval.ApprovalManager">

<cffunction name="getProgramSettngs" access="public" returntype="query">
	<cfargument name="ProgramType_ID" type="string" required="true" />
<CFQUERY NAME="qgetProgramSettngs" datasource="#application.datasource#">
	SELECT	*
	FROM	dbo.Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#arguments.ProgramType_ID#'
</CFQUERY>
<cfreturn qgetProgramSettngs />
</cffunction>

<cffunction name="getApprovalSettings" access="public" returntype="query">
	<cfargument name="ProgramType_ID" type="string" required="true" />
	<cfargument name="profile_ID" type="string" required="true" />
	<cfargument name="forbidtype" type="string" required="true" />
	<cfargument name="forbidaccesstype" type="string" required="true" />
<cfset useLakebaseForqgetApprovalSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_forbidden_template")>
<cfif useLakebaseForqgetApprovalSettings>
	<cftry>
		<cfset qgetApprovalSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profile_forbidden_template", {
				"deleted" = "eq.0",
				"template_id" = "eq.#arguments.ProgramType_ID#",
				"forbid_type" = "eq.#arguments.forbidType#",
				"forbid_access_type" = "eq.#arguments.forbidaccesstype#",
				"profile_id" = "eq.#arguments.profile_ID#",
				"select" = "template_id"
			}), "template_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetApprovalSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetApprovalSettings>
<cfquery name="qgetApprovalSettings" datasource="#application.datasource#">
	select 	distinct template_id 
						from 	Profile_Forbidden_Template 
						where 	Deleted = 0
								AND Template_ID = #arguments.ProgramType_ID#
								AND Forbid_Type = #arguments.forbidType#
								AND	Forbid_Access_Type = #arguments.forbidaccesstype#
								AND profile_id = #arguments.profile_ID#
</cfquery>
</cfif>
<cfreturn qgetApprovalSettings />
</cffunction>


<cffunction name="getAllProductMargins" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfargument name="Profiles_ID" type="string" required="true" />
<cfargument name="group_id" type="string" required="false" />
<cfargument name="margin_type" type="string" required="false" default="1"/>
<CFQUERY NAME="qgetAllProductMargins" datasource="#application.datasource#">
<cfif #arguments.margin_type# EQ 1>
SELECT distinct ISNULL(Base_Sales_CS,0) as Base_Sales, ISNULL(Cash_discount_CS,0) as Cash_discount, ISNULL(Net_Sales_CS,0) as Net_Sales, ISNULL(Cost_CS,0) as cost1, ISNULL(Cost2_CS,0) as cost2, (ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0)) as Item_Allowance,ISNULL(ProductVolume_CS,0) as ProductVolume,ISNULL(TPA_CS,0) as TPA,ISNULL(Operating_Income_CS,0) as Operating_Income,ISNULL(Contribution_Margin_CS,0) as Contribution_Margin,
ISNULL(Product_Program_Volume_CS,0) as Product_Program_Volume,
<cfelseif #arguments.margin_type# EQ 3>
SELECT distinct ISNULL(Base_Sales_LB,0) as Base_Sales, ISNULL(Cash_discount_LB,0) as Cash_discount, ISNULL(Net_Sales_LB,0) as Net_Sales, ISNULL(Cost_LB,0) as cost1, ISNULL(Cost2_LB,0) as cost2, (ISNULL(Item_Allowance_LB,0) + ISNULL(LumpsumAmount_LB,0)) as Item_Allowance,ISNULL(ProductVolume_LB,0) as ProductVolume,ISNULL(TPA_LB,0) as TPA,ISNULL(Operating_Income_CS,0) as Operating_Income,ISNULL(Contribution_Margin_LB,0) as Contribution_Margin,
ISNULL(Product_Program_Volume_LB,0) as Product_Program_Volume,
<cfelseif #arguments.margin_type# EQ 4>
SELECT distinct (ISNULL(Base_Sales_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Base_Sales, (ISNULL(Cash_discount_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Cash_discount, (ISNULL(Net_Sales_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Net_Sales, (ISNULL(Cost_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as cost1, (ISNULL(Cost2_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as cost2, ((ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0)) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Item_Allowance,ISNULL(ProductVolume_CS,0) as ProductVolume,(ISNULL(TPA_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as TPA,(ISNULL(Operating_Income_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Operating_Income,ISNULL(Product_Program_Volume_CS,0) as Product_Program_Volume,(ISNULL(Contribution_Margin_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Contribution_Margin,
</cfif>
Contract_Product_Margin.group_id,
ISNULL(Product_Hierarchy.Target_Margin,0) * 100 as Target_Margin,Contract_Main_ID,Contract_Product_Margin.Product_Id,ISNULL(CAST(Contribution_Margin_percent as float),0) as Contribution_Margin_percent ,
ISNULL(OperatingMargin_percent,0) as OperatingMargin_percent ,Type_Group_Desc.Type_Group_Desc,ISNULL(BSA_Foodservice_Items_Master.Net_Weight,0) as Net_Weight,
BSA_Foodservice_Items_Master.Description,BSA_Foodservice_Items_Master.Item,
Type_Group_Desc.Type_Group_Desc_ID,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,
ISNULL(Group_ID_Approval,0) as Group_ID_Approval,ISNULL(Group_ID_Margin,0) as Group_ID_Margin
FROM  dbo.Contract_Product_Margin
INNEr JOIN BSA_Foodservice_Items_Master
ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
INNER JOIN Product_Hierarchy
ON Product_Hierarchy.Product_Hierarchy_Id =  BSA_Foodservice_Items_Master.Product_Hierarchy_Id
and Product_Hierarchy.Product_Hierarchy_Level = 4
and Product_Hierarchy.deleted = 0
INNER JOIN Type_Group_Desc
ON Type_Group_Desc.Type_Group_Desc_ID = BSA_Foodservice_Items_Master.Type_Group_Desc_ID
and Type_Group_Desc.deleted = 0
LEFT JOIN Group_Approval_Rights ON
Group_Approval_Rights.Group_ID = Type_Group_Desc.Type_Group_Desc_ID
and Group_Approval_Rights.User_Profile_ID = #arguments.Profiles_ID# 
and Group_Approval_Rights.deleted = 0
where contract_main_id = '#arguments.Program_ID#'
<!--- and Contract_Product_Margin.group_Id = '#replace(arguments.group_id, "_", "-", "ALL")#' --->
and Contract_Product_Margin.deleted = 0
AND isnull(BASE_SALES_CS,0) != 0
order by Contract_Product_Margin.group_id, BSA_Foodservice_Items_Master.Item
</CFQUERY>
<cfreturn qgetAllProductMargins />
</cffunction>

<!--- <cffunction name="getAllGroupMargins" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfargument name="Profiles_ID" type="string" required="true" />
<CFQUERY NAME="qgetAllGroupMargins" datasource="#application.datasource#">
SELECT Contract_group_Margin.group_id,Product_Program_Volume_CS as Total_Product_Program_Volume ,Base_Sales_CS as
Total_Base_Sales,Cash_discount_CS as Total_Cash_discount,TPA_CS as Total_TPA,Net_Sales_CS as Total_Net_Sales,Cost_CS as Total_Cost1,Cost2_CS as Total_Cost2,Contribution_Margin_CS as Total_Contribution_Margin,Operating_Income_CS as Total_Operating_Income,(ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0)) as Item_Allowance,OperatingMargin_percent as Total_OperatingMargin_percent,Contribution_Margin_percent as Total_Contribution_Margin_percent,
ISNULL((Type_Group_Desc.Target_Margin),0) as Target_Margin,Type_Group_Desc.Type_Group_Desc_ID,
Type_Group_Desc.Type_Group_Desc
,ISNULL(Group_ID_Approval,0) as Group_ID_Approval,ISNULL(Group_ID_Margin,0) as Group_ID_Margin,Product_Hierarchy.Product_Hierarchy_Name as group_name,Right(Product_Hierarchy,3) as group_legacy
FROM  dbo.Contract_group_Margin
inner join Product_Hierarchy on
Product_Hierarchy.Product_Hierarchy_id = Contract_group_Margin.group_id
INNER JOIN Type_Group_Desc
ON Type_Group_Desc.Type_Group_Desc_ID = Product_Hierarchy.Type_Group_Desc_ID
and Type_Group_Desc.deleted = 0
LEFT JOIN Group_Approval_Rights ON
Group_Approval_Rights.Group_ID = Type_Group_Desc.Type_Group_Desc_ID
and Group_Approval_Rights.User_Profile_ID = #arguments.Profiles_ID# 
and Group_Approval_Rights.deleted = 0
where Contract_group_Margin.contract_main_id = #arguments.program_id#
and Contract_group_Margin.deleted = 0
</CFQUERY>
<cfreturn qgetAllGroupMargins />
</cffunction> --->

<cffunction name="getAllGroupMargins" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfargument name="Profiles_ID" type="string" required="true" />
<cfargument name="NoProducts" type="string" required="false" default="0" />
<CFQUERY NAME="qgetAllGroupMargins" datasource="#application.datasource#">
<cfif arguments.NoProducts EQ 0>
SELECT Contract_group_Margin.group_id,Product_Program_Volume_CS as Total_Product_Program_Volume ,Base_Sales_CS as
Total_Base_Sales,Cash_discount_CS as Total_Cash_discount,TPA_CS as Total_TPA,
Net_Sales_CS as Total_Net_Sales,Cost_CS as Total_Cost1,Cost2_CS as Total_Cost2,
Contribution_Margin_CS as Total_Contribution_Margin,
Operating_Income_CS as Total_Operating_Income,
ISNULL(Item_Allowance_CS,0) as Item_Allowance,
OperatingMargin_percent as Total_OperatingMargin_percent,
Contribution_Margin_percent as Total_Contribution_Margin_percent,
ISNULL((Product_Hierarchy.Target_Margin),0) * 100 as Target_Margin,
Type_Group_Desc.Type_Group_Desc_ID,
Type_Group_Desc.Type_Group_Desc
,ISNULL(Group_ID_Approval,0) as Group_ID_Approval,ISNULL(Group_ID_Margin,0) as Group_ID_Margin,Product_Hierarchy.Product_Hierarchy_Name as group_name,Right(Product_Hierarchy,3) as group_legacy
FROM  dbo.Contract_group_Margin
inner join Product_Hierarchy on
Product_Hierarchy.Product_Hierarchy_id = Contract_group_Margin.group_id
INNER JOIN Type_Group_Desc
ON Type_Group_Desc.Type_Group_Desc_ID = Product_Hierarchy.Type_Group_Desc_ID
and Type_Group_Desc.deleted = 0
LEFT JOIN Group_Approval_Rights ON
Group_Approval_Rights.Group_ID = Type_Group_Desc.Type_Group_Desc_ID
and Group_Approval_Rights.User_Profile_ID = #arguments.Profiles_ID# 
and Group_Approval_Rights.deleted = 0
where Contract_group_Margin.contract_main_id = #arguments.program_id#
and Contract_group_Margin.deleted = 0
<cfelse>
select DISTINCT Right(RTrim(ph4.product_hierarchy), 3) as group_legacy, ph4.product_hierarchy_Name AS group_name,
ph4.product_hierarchy_id as group_id,0 as Total_Product_Program_Volume ,0 as
Total_Base_Sales,0 as Total_Cash_discount,0 as Total_TPA,0 as Total_Net_Sales,0 as Total_Cost1,0 as Total_Cost2,0 as Total_Contribution_Margin,0 as Total_Operating_Income,0 as Item_Allowance,0 as Total_OperatingMargin_percent,0 as Total_Contribution_Margin_percent,
ISNULL((ph4.Target_Margin),0) * 100 as Target_Margin,Type_Group_Desc.Type_Group_Desc_ID,
Type_Group_Desc.Type_Group_Desc
,ISNULL(Group_ID_Approval,0) as Group_ID_Approval,ISNULL(Group_ID_Margin,0) as Group_ID_Margin
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
				AND ph.product_hierarchy_id = BSA_Foodservice_items_master.product_hierarchy_id)
			INNER join product_hierarchy ph4
			on ph4.Product_hierarchy_level = 4
			and left(ph4.product_hierarchy, len(ph.product_hierarchy)) = ph.product_hierarchy
			INNER JOIN Type_Group_Desc
			ON Type_Group_Desc.Type_Group_Desc_ID = ph4.Type_Group_Desc_ID
			and Type_Group_Desc.deleted = 0
			LEFT JOIN Group_Approval_Rights ON
			Group_Approval_Rights.Group_ID = Type_Group_Desc.Type_Group_Desc_ID
			and Group_Approval_Rights.User_Profile_ID = #arguments.Profiles_ID# 
			and Group_Approval_Rights.deleted = 0
where
		Contract_Products.Contract_Main_ID = '#arguments.Program_ID#'
		AND dbo.Contract_Products.Deleted = 0
</cfif>
</CFQUERY>
<cfreturn qgetAllGroupMargins />
</cffunction>

<cffunction name="getagreedprogramtypecodes" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfargument name="Exec_Agreement" type="string" required="false" />
<cfquery name="qgetagreedprogramtypecodes" 			datasource="#application.datasource#">
			select cp1.group_id
from Contract_Group_Margin cp1
where cp1.contract_main_id = #arguments.program_id#
and cp1.deleted = 0 
and cp1.group_id not in
(SELECT BSA_Foodservice_Items_Master.Product_Hierarchy_ID
			FROM  dbo.Contract_Group_Margin
			INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.Product_Hierarchy_ID =
			Contract_Group_Margin.group_id
			INNER JOIN Program_Type_Code_Approval_Info
			ON (Program_Type_Code_Approval_Info.Type_Code_Desc_ID =
			BSA_Foodservice_Items_Master.Product_Hierarchy_ID OR 
			Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id)
			AND Program_Type_Code_Approval_Info.program_id = contract_main_id
			AND Program_Type_Code_Approval_Info.deleted = 0
			<cfif isdefined("arguments.Exec_Agreement") and arguments.Exec_Agreement EQ 1>
			INNER JOIN _Users ON
			_Users.User_id = Program_Type_Code_Approval_Info.User_id
			and  _Users.deleted = 0
			inner JOin profiles_settings
			On profiles_settings.profiles_id = _Users.profiles_id
			and profiles_settings.Executive_Agreement = #arguments.Exec_Agreement#
			</cfif>
			where contract_main_id = cp1.contract_main_id
			AND (isNULL(agree,0) = 1
			OR isNULL(approve,0) = 1)
			and Contract_Group_Margin.deleted = 0)
</cfquery> 
<cfreturn qgetagreedprogramtypecodes />
</cffunction> 

<!--- <cffunction name="getagreedprogramtypecodes" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="Exec_Agreement" type="string" required="false" />
	<cfargument name="User_ID" type="string" required="false" />
	<cfargument name="User_Profile" type="numeric" required="false" default="0" />
	<cfargument name="onlyTheTypeCodesUserHaveAccessTo" type="boolean" required="false" default="0" />

	<cfquery name="qgetagreedprogramtypecodes" 			datasource="#application.datasource#">
	select 	cp1.group_id
	from 	Contract_group_Margin cp1
			<cfif arguments.onlyTheTypeCodesUserHaveAccessTo>
			INNER JOIN 	BSA_Foodservice_Items_Master
			ON 			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = cp1.group_id
			INNER JOIN 	Type_Code_Desc
			ON 			Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
			AND			Type_Code_Desc.Type_Code_Desc_ID IN
						(
						SELECT	DISTINCT Type_Code_Desc_ID
						FROM	Type_Code_Desc
								INNER JOIN Group_Approval_Rights Group_Level_Access_Rights			
								ON
								Group_Level_Access_Rights.Deleted = 0 
								AND Group_Level_Access_Rights.Group_ID = Type_Code_Desc.Type_Code_Desc_ID
								AND Group_Level_Access_Rights.Group_Type = 1
								AND	Group_Level_Access_Rights.Group_ID_Approval = 1
								AND Group_Level_Access_Rights.User_Profile_Id = #arguments.User_Profile#
						)
			</cfif>
	where 	cp1.contract_main_id = #arguments.program_id#
	and 	cp1.deleted = 0 
	and 	cp1.group_id not in
				(SELECT 	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
				FROM  		dbo.Contract_Product_Margin
				INNER JOIN 	BSA_Foodservice_Items_Master
				ON 			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
				INNER JOIN 	Type_Code_Desc
				ON 			Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
				INNER JOIN 	Program_Type_Code_Approval_Info
				ON 			(Program_Type_Code_Approval_Info.Type_Code_Desc_ID =	Type_Code_Desc.Type_Code_Desc_ID 
							OR 
							Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
							)
				AND 		Program_Type_Code_Approval_Info.program_id = contract_main_id
				AND 		Program_Type_Code_Approval_Info.deleted = 0
				<cfif isdefined("arguments.Exec_Agreement") and arguments.Exec_Agreement EQ 1>
				INNER JOIN _Users 
				ON			_Users.User_id = Program_Type_Code_Approval_Info.User_id
				and  		_Users.deleted = 0
				inner JOin 	profiles_settings
				On 			profiles_settings.profiles_id = _Users.profiles_id
				and 		profiles_settings.Executive_Agreement = #arguments.Exec_Agreement#
				</cfif>
				where 		contract_main_id = cp1.contract_main_id
				AND 		(isNULL(agree,0) = 1 OR isNULL(approve,0) = 1)
				and Contract_Product_Margin.deleted = 0
				<cfif isdefined("arguments.User_ID")>
				and 		Program_Type_Code_Approval_Info.User_Id = '#arguments.User_ID#'
				</cfif>
				)
	</cfquery> 
	<cfreturn qgetagreedprogramtypecodes />
</cffunction> --->

<cffunction name="checkParentStats" access="public" returntype="query">
<cfargument name="Revision_Of_Contract_Main_ID" type="string" required="true" />
<cfset useLakebaseForqcheckParentStats = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqcheckParentStats>
	<cftry>
		<cfset qcheckParentStats = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.Revision_Of_Contract_Main_ID#",
				"select" = "contract_main_id,contract_status_type_idx"
			}), "contract_main_id,contract_status_type_idx"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqcheckParentStats = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqcheckParentStats>
<CFQUERY NAME="qcheckParentStats" datasource="#application.datasource#">
				SELECT Contract_Main_ID, Contract_Status_Type_IDX
				FROM Contract_Main
				WHERE Contract_Main_ID = #arguments.Revision_Of_Contract_Main_ID#
			</CFQUERY>
</cfif>
	<cfreturn qcheckParentStats />
</cffunction>


<cffunction name="getProgramMargins" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<CFQUERY NAME="qgetProgramMargins" datasource="#application.datasource#">
SELECT ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) as Total_Product_Program_Volume,
CASE when ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) !=0 then
ISNULL(Sum(Round(Product_Program_Volume_CS,0) * Base_Sales_CS),0)/SUM(Round(Product_Program_Volume_CS,0))
ELSE
0 END as Total_BaseSales,
CASE when ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) !=0 then
ISNULL(SUM(Round(Product_Program_Volume_CS,0)* Cash_discount_CS),0)/SUM(Round(Product_Program_Volume_CS,0))
ELSE 0 END as Total_Cash_discount ,
CASE when ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) !=0 then
ISNULL(SUM(Round(Product_Program_Volume_CS,0)*TPA_CS),0) /SUM(Round(Product_Program_Volume_CS,0))
ELSE 0 END as Total_TPA,
CASE when ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) !=0 then
ISNULL(SUM(Round(Product_Program_Volume_CS,0) * Net_Sales_CS),0)/SUM(Round(Product_Program_Volume_CS,0))
ELSE 0 END  as Total_NetSales,
CASE when ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) !=0 then 
ISNULL(SUM(Round(Product_Program_Volume_CS,0) * Cost_CS),0)/SUM(Round(Product_Program_Volume_CS,0))
ELSE 0 END as Total_Cost1,
CASE when ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) !=0 then 
ISNULL(SUM(Round(Product_Program_Volume_CS,0) * Cost2_CS),0)/SUM(Round(Product_Program_Volume_CS,0))
ELSE 0 END as Total_Cost2,
CASE when ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) !=0 then
ISNULL(SUM(Round(Product_Program_Volume_CS,0)*Contribution_Margin_CS),0)/SUM(Round(Product_Program_Volume_CS,0))
ELSE 0 END as Total_ContributionMargin,
CASE WHEN ISNULL(SUM(Net_Sales_CS),0) != 0 and ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) != 0  THEN
CASE when (SUM(Contribution_Margin_CS) < 0 and SUM(Net_Sales_CS) < 0)
then
(ISNULL(SUM(Round(Product_Program_Volume_CS,0)*Contribution_Margin_CS),0)/SUM(Round(Product_Program_Volume_CS,0))) / (ISNULL(SUM(Round(Product_Program_Volume_CS,0) * Net_Sales_CS),0)/SUM(Round(Product_Program_Volume_CS,0))) * 100 * -1
else
(ISNULL(SUM(Round(Product_Program_Volume_CS,0)*Contribution_Margin_CS),0)/SUM(Round(Product_Program_Volume_CS,0))) / (ISNULL(SUM(Round(Product_Program_Volume_CS,0) * Net_Sales_CS),0)/SUM(Round(Product_Program_Volume_CS,0))) * 100
end
else
0
end as TOTAL_CONTRIBUTION_MARGIN_PERCENT ,
CASE when ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) !=0 then
(ISNULL(SUM(Round(Product_Program_Volume_CS,0)*Item_Allowance_CS),0) /SUM(Round(Product_Program_Volume_CS,0)))
ELSE 0 END 
as TOTAL_Allowance,
CASE when ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) !=0 then
ISNULL(SUM(Round(Product_Program_Volume_CS,0)*Operating_Income_CS),0)/SUM(Round(Product_Program_Volume_CS,0))
ELSE 0 END as Total_Operating_Income,

CASE WHEN ISNULL(SUM(Net_Sales_CS),0) != 0 and ISNULL(SUM(Round(Product_Program_Volume_CS,0)),0) != 0   THEN
CASE when (SUM(Operating_Income_CS) < 0 and SUM(Net_Sales_CS) < 0)
then
((ISNULL(SUM(Round(Product_Program_Volume_CS,0)*Operating_Income_CS),0)/SUM(Round(Product_Program_Volume_CS,0)))/(ISNULL(SUM(Round(Product_Program_Volume_CS,0) * Net_Sales_CS),0)/SUM(Round(Product_Program_Volume_CS,0)))) * 100 * -1
else
((ISNULL(SUM(Round(Product_Program_Volume_CS,0)*Operating_Income_CS),0)/SUM(Round(Product_Program_Volume_CS,0)))/(ISNULL(SUM(Round(Product_Program_Volume_CS,0) * Net_Sales_CS),0)/SUM(Round(Product_Program_Volume_CS,0)))) * 100
end
else
0
end as Total_Operating_percent
FROM  dbo.Contract_group_Margin
where contract_main_id = '#arguments.program_id#'
and Contract_group_Margin.deleted = 0
and base_sales_cs != 0
</CFQUERY>
	<cfreturn qgetProgramMargins />
</cffunction>

<cffunction name="getProgramLumpsum" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<CFQUERY NAME="qgetProgramLumpsum" datasource="#application.datasource#">
				select ISNULL(sum(cast(Lump_Sum_Amount as float)),0) as Lumpsum_Amount
from Program_Lump_Sums
where
Program_ID =  #arguments.program_id#
and deleted = 0
</CFQUERY>
	<cfreturn qgetProgramLumpsum />
</cffunction>

<cffunction name="getGrowthproducts" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfset useLakebaseForqgetGrowthproducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqgetGrowthproducts>
	<cftry>
		<cfset qgetGrowthproducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#arguments.program_id#",
				"product_type_id" = "eq.4",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetGrowthproducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetGrowthproducts>
<CFQUERY NAME="qgetGrowthproducts" datasource="#application.datasource#">
select *
from contract_products
where
contract_main_id =  #arguments.program_id#
and Product_Type_ID = 4
and deleted = 0
</CFQUERY>
</cfif>
	<cfreturn qgetGrowthproducts />
</cffunction>


<cffunction name="getAllFamilyGroupMargins" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfargument name="Profiles_ID" type="string" required="true" />
<cfargument name="margin_type" type="string" required="false" default="1" />
<CFQUERY NAME="qgetAllFamilyGroupMargins" datasource="#application.datasource#">
<cfif #arguments.margin_type# EQ 1>
SELECT distinct ISNULL(Base_Sales_CS,0) as Base_Sales, ISNULL(Cash_discount_CS,0) as Cash_discount, ISNULL(Net_Sales_CS,0) as Net_Sales, ISNULL(Cost_CS,0) as cost1, ISNULL(Cost2_CS,0) as cost2, (ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0)) as Item_Allowance,ISNULL(ProductVolume_CS,0) as ProductVolume,ISNULL(TPA_CS,0) as TPA,ISNULL(Operating_Income_CS,0) as Operating_Income,ISNULL(Contribution_Margin_CS,0) as Contribution_Margin,
ISNULL(Product_Program_Volume_CS,0) as Product_Program_Volume,
<cfelseif #arguments.margin_type# EQ 3>
SELECT distinct ISNULL(Base_Sales_LB,0) as Base_Sales, ISNULL(Cash_discount_LB,0) as Cash_discount, ISNULL(Net_Sales_LB,0) as Net_Sales, ISNULL(Cost_LB,0) as cost1, ISNULL(Cost2_LB,0) as cost2, (ISNULL(Item_Allowance_LB,0) + ISNULL(LumpsumAmount_LB,0)) as Item_Allowance,ISNULL(ProductVolume_LB,0) as ProductVolume,ISNULL(TPA_LB,0) as TPA,ISNULL(Operating_Income_CS,0) as Operating_Income,ISNULL(Contribution_Margin_LB,0) as Contribution_Margin,
ISNULL(Product_Program_Volume_LB,0) as Product_Program_Volume,
<cfelseif #arguments.margin_type# EQ 4>
SELECT distinct (ISNULL(Base_Sales_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Base_Sales, (ISNULL(Cash_discount_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Cash_discount, (ISNULL(Net_Sales_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Net_Sales, (ISNULL(Cost_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as cost1, (ISNULL(Cost2_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as cost2, ((ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0)) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Item_Allowance,ISNULL(ProductVolume_CS,0) as ProductVolume,(ISNULL(TPA_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as TPA,(ISNULL(Operating_Income_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Operating_Income,ISNULL(Product_Program_Volume_CS,0) as Product_Program_Volume,(ISNULL(Contribution_Margin_CS,0) * Round(ISNULL(Product_Program_Volume_CS,0),0)) as Contribution_Margin,
</cfif>
CASE WHEN isnull(Net_Sales_CS,0) = 0
THEN 0
else
case when Contribution_Margin_CS < 0 and Net_Sales_CS < 0 then
((ISNULL(Contribution_Margin_CS,0)/(ISNULL(Net_Sales_CS,1) * (-1))) * 100) 
else
((ISNULL(Contribution_Margin_CS,0)/ISNULL(Net_Sales_CS,1)) * 100) 
end
END as Contribution_Margin_percent,
CASE WHEN isnull(Net_Sales_CS,0) = 0
THEN 0
else
case when Operating_Income_CS < 0 and Net_Sales_CS < 0 then
((ISNULL(Operating_Income_CS,0)/(ISNULL(Net_Sales_CS,1) * (-1))) * 100) 
else
((ISNULL(Operating_Income_CS,0)/ISNULL(Net_Sales_CS,1)) * 100) 
end
END as OperatingMargin_percent,
Product_Hierarchy_Name as group_name, Product_Hierarchy.Product_Hierarchy_ID as group_id,
ISNULL(Group_ID_Margin,0) as Group_ID_Margin,Right(Product_Hierarchy,3) 
as group_legacy,ISNULL(Group_ID_Approval,0) as Group_ID_Approval,
ISNULL(Contract_Group_Margin.TargetMargin,0)  as Target_Margin
FROM  dbo.Contract_Group_Margin
INNER JOIN Product_Hierarchy
ON Product_Hierarchy.Product_Hierarchy_Id = Contract_Group_Margin.Group_ID
and Product_Hierarchy.deleted = 0
LEFT JOIN Type_Group_Desc ON
Type_Group_Desc.Type_Group_Desc_id = Product_Hierarchy.Type_Group_Desc_id
LEFT JOIN Group_Approval_Rights ON
Group_Approval_Rights.Group_ID = Type_Group_Desc.Type_Group_Desc_ID
and Group_Approval_Rights.User_Profile_ID = #arguments.Profiles_ID# 
and Group_Approval_Rights.deleted = 0
where contract_main_id = '#arguments.program_id#'
and Product_Hierarchy.deleted = 0
order by Contract_Group_Margin.Group_Id
</CFQUERY>
<cfreturn qgetAllFamilyGroupMargins />
</cffunction>

<cffunction name="getThisProgramsStatus" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfset useLakebaseForqgetThisProgramsStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqgetThisProgramsStatus>
	<cftry>
		<cfset qgetThisProgramsStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.program_id#",
				"select" = "contract_status_type_idx,revision_of_contract_main_id,broker_user_id,contract_number,contract_title,adv_spending_amount"
			}), "contract_status_type_idx,revision_of_contract_main_id,broker_user_id,contract_number,contract_title,adv_spending_amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetThisProgramsStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetThisProgramsStatus>
<CFQUERY NAME="qgetThisProgramsStatus" datasource="#application.datasource#">
			SELECT Contract_Status_Type_IDX, Revision_Of_Contract_Main_ID, Broker_User_ID, Contract_Number, Contract_Title,Adv_Spending_Amount
			FROM Contract_main
			WHERE Contract_main_ID = #arguments.program_id#
		</CFQUERY>
</cfif>
	<cfreturn qgetThisProgramsStatus />
</cffunction>


<cffunction name="getAllGroupMarginsApproved" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<CFQUERY NAME="qgetAllGroupMarginsApproved" datasource="#application.datasource#">
SELECT distinct base_sales_cs,Product_Hierarchy_ID,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,isnull(approve,0)
			FROM  dbo.Contract_Group_Margin
			INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.Product_Hierarchy_ID =
			Contract_Group_Margin.Group_Id
			INNER JOIN
			contract_products ON
			contract_products.BSA_Foodservice_Items_Master_Id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_id
			and contract_products.deleted = 0
			and contract_products.contract_main_id = Contract_Group_Margin.contract_main_id
			inner join program_product_volume
			on program_product_volume.program_id = contract_products.contract_main_id
			AND program_product_volume.BSA_Foodservice_Items_Master_Id = contract_products.BSA_Foodservice_Items_Master_Id
			AND program_product_volume.DELETED = 0
			AND program_product_volume.VOLUME_CS != 0
			INNER JOIN Category ON
			BSA_Foodservice_Items_Master.category_id = Category.category_id
			LEFT JOIN Program_Type_Code_Approval_Info
			ON (Program_Type_Code_Approval_Info.Type_Code_Desc_ID =
			BSA_Foodservice_Items_Master.Product_Hierarchy_ID OR 
			Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id)
			AND Program_Type_Code_Approval_Info.program_id = contract_products.contract_main_id
			AND Program_Type_Code_Approval_Info.deleted = 0
			AND type = 1
			where Contract_Group_Margin.contract_main_id = '#arguments.program_id#'
			and Category.Category = '01'
			and Contract_Group_Margin.deleted = 0
			and BSA_Foodservice_Items_Master.active_code = 'A'
			and Contract_Group_Margin.base_sales_cs != 0
AND isNULL(approve,0) = 0
			
			</CFQUERY>
<cfreturn qgetAllGroupMarginsApproved />
</cffunction>


<cffunction name="getAllGroupsApproved" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<CFQUERY NAME="qgetAllGroupsApproved" datasource="#application.datasource#">
select distinct ph4.product_hierarchy_id
FROM		Contract_Products 
			INNER JOIN	BSA_Foodservice_Items_Master ON 
                      	Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			LEFT JOIN Category on BSA_Foodservice_Items_Master.Category_Id = Category.Category_Id
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
				AND ph.product_hierarchy_id = BSA_Foodservice_items_master.product_hierarchy_id
				AND Category.Category = '01'
			)
			INNER join product_hierarchy ph4
			on ph4.Product_hierarchy_level = 4
			and left(ph4.product_hierarchy, len(ph.product_hierarchy)) = ph.product_hierarchy
			INNER JOIN Type_Group_Desc
			ON Type_Group_Desc.Type_Group_Desc_ID = ph4.Type_Group_Desc_ID
			and Type_Group_Desc.deleted = 0
			LEFT JOIN Program_Type_Code_Approval_Info
			ON (Program_Type_Code_Approval_Info.Type_Code_Desc_ID =
			ph4.product_hierarchy_id OR 
			Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id)
			AND Program_Type_Code_Approval_Info.program_id = contract_main_id
			AND Program_Type_Code_Approval_Info.deleted = 0
			AND type = 1
where Contract_Products.contract_main_id =  '#arguments.program_id#' AND
 Contract_Products.deleted = 0
 AND isNULL(approve,0) = 0
			</CFQUERY>
<cfreturn qgetAllGroupsApproved />
</cffunction>

</cfcomponent>