<cfcomponent displayname="standard_program_approval" hint="standard_program_approval" extends="components.programs.Approval.ApprovalManager">

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
<cfargument name="margin_type" type="string" required="true" />
<cfargument name="formCopy" type="struct" required="false"/>
<cfif isDefined("arguments.formCopy.AgreeList")>
	<cfif arguments.formCopy.AgreeList neq "">
		<cfset agreeList = arguments.formCopy.AgreeList />
	<cfelse>
		<cfset agreeList = arguments.formCopy.preAgreeList />
	</cfif>
</cfif>
<cfif isDefined("arguments.formCopy.ApproveList")>
	<cfif arguments.formCopy.ApproveList neq "">
		<cfset approveList = arguments.formCopy.ApproveList />
	<cfelse>
		<cfset approveList = arguments.formCopy.preApproveList />
	</cfif>
</cfif>
<cfif isDefined("arguments.formCopy.RestrictedList")>
	<cfif arguments.formCopy.RestrictedList neq "">
		<cfset restrictedList = arguments.formCopy.RestrictedList />
	<cfelse>
		<cfset restrictedList = arguments.formCopy.preRestrictedList />
	</cfif>
</cfif>

<cfif #arguments.margin_type# EQ 1>
<CFQUERY NAME="qgetAllProductMargins" datasource="#application.datasource#">
SELECT distinct Contract_Main_ID,Contract_Product_Margin.Product_Id,
ISNULL(Base_Sales_CS,0) as Base_Sales, 
Cash_discount_CS as Cash_discount, 
ISNULL(Net_Sales_CS,0) as Net_Sales, 
Cost_CS as cost,
(ISNULL(Item_Allowance_CS,0) + ISNULL(LumpsumAmount_CS,0)) as Item_Allowance,
ISNULL(TPA_CS,0) as TPA,Pullbackamount_CS as PullbackAmount,
ISNULL(Operating_Income_CS,0) as Operating_Income,
ISNULL(OperatingMargin_percent,0) as OperatingMargin_percent,
BSA_Foodservice_Items_Master.Description,BSA_Foodservice_Items_Master.Item,
ISNULL(Product_Program_Volume_CS,0) as Product_Program_Volume,
group_id,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,
ISNULL(spend_dollar_CS,0) as spend_dollar_CS 
FROM  dbo.Contract_Product_Margin
INNEr JOIN BSA_Foodservice_Items_Master
ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
where contract_main_id = '#arguments.Program_ID#'
and Contract_Product_Margin.deleted = 0
<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Agree") and agreeList neq "">
	and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(agreeList, "'" , ",")#)
</cfif>
<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Approve") and approveList neq "">
	and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(approveList, "'" , ",")#)
</cfif>
<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Restricted") and restrictedList neq "">
	and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(restrictedList, "'" , ",")#)
</cfif>
order by group_id
</CFQUERY>
<cfelse>
<CFQUERY NAME="qgetAllProductMargins" datasource="#application.datasource#">
SELECT distinct Contract_Main_ID,Contract_Product_Margin.Product_Id,
ISNULL(Base_Sales_LB,0) as Base_Sales, 
Cash_discount_LB as Cash_discount, 
ISNULL(Net_Sales_LB,0) as Net_Sales, 
Cost_LB as cost,
(ISNULL(Item_Allowance_LB,0) + ISNULL(LumpsumAmount_LB,0)) as Item_Allowance,
ISNULL(TPA_LB,0) as TPA,Pullbackamount_LB as PullbackAmount,
ISNULL(Operating_Income_LB,0) as Operating_Income,
ISNULL(OperatingMargin_percent,0) as OperatingMargin_percent,
BSA_Foodservice_Items_Master.Description,BSA_Foodservice_Items_Master.Item,
ISNULL(Product_Program_Volume_LB,0) as Product_Program_Volume,
group_id,BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,
ISNULL(spend_dollar_LB,0) as spend_dollar_CS 
FROM  dbo.Contract_Product_Margin
INNEr JOIN BSA_Foodservice_Items_Master
ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
where contract_main_id = '#arguments.Program_ID#'
and Contract_Product_Margin.deleted = 0
<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Agree") and agreeList neq "">
	and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(agreeList, "'" , ",")#)
</cfif>
<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Approve") and approveList neq "">
	and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(approveList, "'" , ",")#)
</cfif>
<cfif isDefined("arguments.formCopy") and Not isDefined("arguments.formCopy.Restricted") and restrictedList neq "">
	and BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID not in (#ListQualify(restrictedList, "'" , ",")#)
</cfif>
order by group_id
</CFQUERY>
</cfif>
<cfreturn qgetAllProductMargins />
</cffunction>


<cffunction name="getAllGroupMargins" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfargument name="Profiles_ID" type="string" required="true" />
<cfargument name="margin_type" type="string" required="true" />
<cfif #arguments.margin_type# EQ 1>
<CFQUERY NAME="qgetAllGroupMargins" datasource="#application.datasource#">
SELECT ISNULL(SUM(Product_Program_Volume_CS),0) as Group_Product_Program_Volume ,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(Sum(Product_Program_Volume_CS * Base_Sales_CS),0)/SUM(Product_Program_Volume_CS)
ELSE
0 END as Group_Base_Sales,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS* Cash_discount_CS),0)/SUM(Product_Program_Volume_CS)
ELSE 0 END as Group_Cash_discount ,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS*TPA_CS),0) /SUM(Product_Program_Volume_CS)
ELSE 0 END as Group_TPA,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS*Pullbackamount_CS),0) /SUM(Product_Program_Volume_CS)
ELSE 0 END as Group_Pullbackamount,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0)/SUM(Product_Program_Volume_CS)
ELSE 0 END  as Group_Net_Sales,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then 
ISNULL(SUM(Product_Program_Volume_CS * Cost_CS),0)/SUM(Product_Program_Volume_CS)
ELSE 0 END as Group_Cost,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS*Operating_Income_CS),0)/SUM(Product_Program_Volume_CS)
ELSE 0 END as Group_Operating_Income,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
(ISNULL(SUM(Product_Program_Volume_CS*Item_Allowance_CS),0) /SUM(Product_Program_Volume_CS)  + ISNULL(SUM(Product_Program_Volume_LB*LumpsumAmount_CS),0) /SUM(Product_Program_Volume_LB))
ELSE 0 END 
as Group_Item_Allowance,
CASE WHEN Round(isnull(SUM(Net_Sales_CS),0),3) = 0
THEN 0
else
case when (ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) < 0 and ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),1) < 0)
then
-((CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
/CASE when ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) ELSE 1 END) * 100) 
else
(CASE when ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Operating_Income_CS),0) ELSE 0 END
/CASE when ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) !=0 then ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0) ELSE 1 END) * 100
end
END as Group_OperatingMargin_percent,Type_Code_Desc.Type_Code_Desc_ID,
Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Target_Margin,Type_Code_Desc.spend_dollar,
ISNULL(Group_ID_Approval,0) as Group_ID_Approval,ISNULL(Group_ID_Margin,0) as Group_ID_Margin,
ISNULL(Group_Id_Spend_Dollar,0) as Group_Id_Spend_Dollar
FROM  dbo.Contract_Product_Margin
INNEr JOIN BSA_Foodservice_Items_Master
ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
INNER JOIN Type_Code_Desc
ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
LEFT JOIN Group_Approval_Rights ON
Group_Approval_Rights.Group_ID = Type_Code_Desc.Type_Code_Desc_ID
and Group_Approval_Rights.User_Profile_ID = #arguments.Profiles_ID#  
and Group_Approval_Rights.deleted = 0
where contract_main_id = #arguments.program_id#
and Contract_Product_Margin.deleted = 0
group by Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Type_Code_Desc_ID,Group_ID_Approval,
Group_ID_Margin,Group_Id_Spend_Dollar,Type_Code_Desc.Target_Margin,Type_Code_Desc.spend_dollar
order by Type_Code_Desc.Type_Code_Desc
</CFQUERY>
<cfelse>
<CFQUERY NAME="qgetAllGroupMargins" datasource="#application.datasource#">
SELECT ISNULL(SUM(Product_Program_Volume_LB),0) as Group_Product_Program_Volume ,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(Sum(Product_Program_Volume_LB * Base_Sales_LB),0)/SUM(Product_Program_Volume_LB)
ELSE
0 END as Group_Base_Sales,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB* Cash_discount_LB),0)/SUM(Product_Program_Volume_LB)
ELSE 0 END as Group_Cash_discount ,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB*TPA_LB),0) /SUM(Product_Program_Volume_LB)
ELSE 0 END as Group_TPA,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB*Pullbackamount_LB),0) /SUM(Product_Program_Volume_LB)
ELSE 0 END as Group_Pullbackamount,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0)/SUM(Product_Program_Volume_LB)
ELSE 0 END  as Group_Net_Sales,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then 
ISNULL(SUM(Product_Program_Volume_LB * Cost_LB),0)/SUM(Product_Program_Volume_LB)
ELSE 0 END as Group_Cost,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB*Operating_Income_LB),0)/SUM(Product_Program_Volume_LB)
ELSE 0 END as Group_Operating_Income,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
(ISNULL(SUM(Product_Program_Volume_LB*Item_Allowance_LB),0) /SUM(Product_Program_Volume_LB) + 
ISNULL(SUM(Product_Program_Volume_LB*LumpsumAmount_LB),0) /SUM(Product_Program_Volume_LB))
ELSE 0 END 
as Group_Item_Allowance,
CASE WHEN Round(isnull(SUM(Net_Sales_LB),0),3) = 0
THEN 0
else
case when (ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) < 0 and ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),1) < 0)
then
-((CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
/CASE when ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) ELSE 1 END) * 100) 
else
(CASE when ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Operating_Income_LB),0) ELSE 0 END
/CASE when ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) !=0 then ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0) ELSE 1 END) * 100
end
END as Group_OperatingMargin_percent,Type_Code_Desc.Type_Code_Desc_ID,
Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Target_Margin,Type_Code_Desc.spend_dollar,
ISNULL(Group_ID_Approval,0) as Group_ID_Approval,ISNULL(Group_ID_Margin,0) as Group_ID_Margin,
ISNULL(Group_Id_Spend_Dollar,0) as Group_Id_Spend_Dollar
FROM  dbo.Contract_Product_Margin
INNEr JOIN BSA_Foodservice_Items_Master
ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
INNER JOIN Type_Code_Desc
ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
LEFT JOIN Group_Approval_Rights ON
Group_Approval_Rights.Group_ID = Type_Code_Desc.Type_Code_Desc_ID
and Group_Approval_Rights.User_Profile_ID = #arguments.Profiles_ID#  
and Group_Approval_Rights.deleted = 0
where contract_main_id = #arguments.program_id#
and Contract_Product_Margin.deleted = 0
group by Type_Code_Desc.Type_Code_Desc,Type_Code_Desc.Type_Code_Desc_ID,Group_ID_Approval,
Group_ID_Margin,Group_Id_Spend_Dollar,Type_Code_Desc.Target_Margin,Type_Code_Desc.spend_dollar
order by Type_Code_Desc.Type_Code_Desc
</CFQUERY>
</cfif>
<cfreturn qgetAllGroupMargins />
</cffunction>

<cffunction name="getapprovedprogramtypecodes" access="public" returntype="query">
<cfargument name="program_id" type="string" required="true" />
<cfquery name="qgetapprovedprogramtypecodes" 			datasource="#application.datasource#">
			SELECT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,isnull(approve,0)
			FROM  dbo.Contract_Product_Margin
			INNEr JOIN BSA_Foodservice_Items_Master
			ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id =
			Contract_Product_Margin.Product_Id
			INNER JOIN Type_Code_Desc
			ON Type_Code_Desc.Type_Code_Desc_ID = 	
			BSA_Foodservice_Items_Master.Type_Code_Desc_ID
			LEFT JOIN Program_Type_Code_Approval_Info
			ON (Program_Type_Code_Approval_Info.Type_Code_Desc_ID =
			Type_Code_Desc.Type_Code_Desc_ID OR 
			Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id)
			AND Program_Type_Code_Approval_Info.program_id = contract_main_id
			AND Program_Type_Code_Approval_Info.deleted = 0
			AND type = 1
			where contract_main_id = #arguments.program_id#
			AND isNULL(approve,0) = 0
			and Contract_Product_Margin.deleted = 0
</cfquery> 
<cfreturn qgetapprovedprogramtypecodes />
</cffunction>

<cffunction name="getagreedprogramtypecodes" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="Exec_Agreement" type="string" required="false" />
	<cfargument name="User_ID" type="string" required="false" />
	<cfargument name="User_Profile" type="numeric" required="false" default="0" />
	<cfargument name="onlyTheTypeCodesUserHaveAccessTo" type="boolean" required="false" default="0" />

	<cfquery name="qgetagreedprogramtypecodes" 			datasource="#application.datasource#">
	select 	cp1.product_id
	from 	Contract_Product_Margin cp1
			<cfif arguments.onlyTheTypeCodesUserHaveAccessTo>
			INNER JOIN 	BSA_Foodservice_Items_Master
			ON 			BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = cp1.Product_Id
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
	and 	cp1.product_id not in
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
<cfargument name="margin_type" type="string" required="true" />
<CFQUERY NAME="qgetProgramMargins" datasource="#application.datasource#">
				SELECT 
<cfif arguments.margin_type EQ 1>
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(Sum(Product_Program_Volume_CS * Base_Sales_CS),0)/SUM(Product_Program_Volume_CS)
ELSE
0 END as Total_BaseSales,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS* Cash_discount_CS),0)/SUM(Product_Program_Volume_CS)
ELSE 0 END as Total_Cash_discount ,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS*TPA_CS),0) /SUM(Product_Program_Volume_CS)
ELSE 0 END as Total_TPA,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS*pullbackamount_CS),0) /SUM(Product_Program_Volume_CS)
ELSE 0 END as Total_Pullbackamount,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS * Net_Sales_CS),0)/SUM(Product_Program_Volume_CS)
ELSE 0 END  as Total_NetSales,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then 
ISNULL(SUM(Product_Program_Volume_CS * Cost_CS),0)/SUM(Product_Program_Volume_CS)
ELSE 0 END as Total_Cost,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS*Operating_Income_CS),0)/SUM(Product_Program_Volume_CS)
ELSE 0 END as Total_OprIncome,
CASE when ISNULL(SUM(Product_Program_Volume_CS),0) !=0 then
ISNULL(SUM(Product_Program_Volume_CS*Item_Allowance_CS),0) /SUM(Product_Program_Volume_CS)
ELSE 0 END 
as TOTAL_Allowance,
CASE WHEN Round(isnull(SUM(Net_Sales_CS),0),3) = 0
THEN 0
else
case when (ISNULL(SUM(Operating_Income_CS),0) < 0 and ISNULL(SUM(Net_Sales_CS),1) < 0)
then -((ISNULL(SUM(Operating_Income_CS),0)/ISNULL(SUM(Net_Sales_CS),1)) * 100) 
else
((ISNULL(SUM(Operating_Income_CS),0)/ISNULL(SUM(Net_Sales_CS),1)) * 100)
end
END as Total_OprMargin,ISNULL(Sum(ISNULL(Round(Product_Program_Volume_CS, 0),0)),0) as TotalProgramVolume 			
<CFELSE>
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(Sum(Product_Program_Volume_LB * Base_Sales_LB),0)/SUM(Product_Program_Volume_LB)
ELSE
0 END as Total_BaseSales,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB* Cash_discount_LB),0)/SUM(Product_Program_Volume_LB)
ELSE 0 END as Total_Cash_discount ,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB*TPA_LB),0) /SUM(Product_Program_Volume_LB)
ELSE 0 END as Total_TPA,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB*pullbackamount_LB),0) /SUM(Product_Program_Volume_LB)
ELSE 0 END as Total_Pullbackamount,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB * Net_Sales_LB),0)/SUM(Product_Program_Volume_LB)
ELSE 0 END  as Total_NetSales,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then 
ISNULL(SUM(Product_Program_Volume_LB * Cost_LB),0)/SUM(Product_Program_Volume_LB)
ELSE 0 END as Total_Cost,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB*Operating_Income_LB),0)/SUM(Product_Program_Volume_LB)
ELSE 0 END as Total_OprIncome,
CASE when ISNULL(SUM(Product_Program_Volume_LB),0) !=0 then
ISNULL(SUM(Product_Program_Volume_LB*Item_Allowance_LB),0) /SUM(Product_Program_Volume_LB) 
ELSE 0 END 
as TOTAL_Allowance,
CASE WHEN Round(isnull(SUM(Net_Sales_LB),0),3) = 0
THEN 0
else
case when (ISNULL(SUM(Operating_Income_LB),0) < 0 and ISNULL(SUM(Net_Sales_LB),1) < 0)
then -((ISNULL(SUM(Operating_Income_LB),0)/ISNULL(SUM(Net_Sales_LB),1)) * 100) 
else
((ISNULL(SUM(Operating_Income_LB),0)/ISNULL(SUM(Net_Sales_LB),1)) * 100)
end
END as Total_OprMargin,Sum(ISNULL(Round(Product_Program_Volume_LB, 0),0)) as TotalProgramVolume,
Sum(ISNULL(Round(Product_Program_Volume_CS, 0),0)) as TotalProgramVolume_CS 	
</cfif>
FROM  dbo.Contract_Product_Margin
INNEr JOIN BSA_Foodservice_Items_Master
ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id = Contract_Product_Margin.Product_Id
INNER JOIN Type_Code_Desc
ON Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
where contract_main_id = '#arguments.program_id#'
and Contract_Product_Margin.deleted = 0
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

<cffunction name="getagreedprograms" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="User_ID" type="string" required="true" />
	<cfquery name="qgetagreedprograms" 			datasource="#application.datasource#">
		select 	distinct cp1.BSA_Foodservice_Items_Master_Id
		from 	Contract_Products cp1
		where 	cp1.contract_main_id = '#arguments.program_id#'
		and 	cp1.deleted = 0 
		and 	cp1.BSA_Foodservice_Items_Master_Id not in
		(SELECT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
					FROM  dbo.Contract_Product_Margin
					INNEr JOIN BSA_Foodservice_Items_Master
					ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id =
					Contract_Product_Margin.Product_Id
					INNER JOIN Type_Code_Desc
					ON Type_Code_Desc.Type_Code_Desc_ID = 	
					BSA_Foodservice_Items_Master.Type_Code_Desc_ID
					LEFT JOIN Program_Type_Code_Approval_Info
					ON (Program_Type_Code_Approval_Info.Type_Code_Desc_ID =
					Type_Code_Desc.Type_Code_Desc_ID OR 
					Program_Type_Code_Approval_Info.product_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id)
					AND Program_Type_Code_Approval_Info.program_id = '#arguments.program_id#'
					AND Program_Type_Code_Approval_Info.deleted = 0
					
					where Contract_Product_Margin.contract_main_id = '#arguments.program_id#'
					AND (isNULL(agree,0) = 1
					OR isNULL(approve,0) = 1
		)
					and Contract_Product_Margin.deleted = 0
					
					 and Program_Type_Code_Approval_Info.User_Id = '#arguments.user_id#'
					)
			
	</CFQUERY>
	<cfreturn qgetagreedprograms />
</cffunction>


<cffunction name="getAnyProgramProducts" access="public" returntype="boolean">
	<cfargument name="program_id" type="string" required="true" />
	
	<cfquery name="qGetAnyProgramProducts" 			datasource="#application.datasource#">
		select 	top 1 cp1.BSA_Foodservice_Items_Master_Id
		from 	Contract_Products cp1
		where 	cp1.contract_main_id = '#arguments.program_id#'
		and 	cp1.deleted = 0 		
	</CFQUERY>
	<cfset bAnyProgramProducts = qGetAnyProgramProducts.recordCount />
	
	<cfreturn bAnyProgramProducts />
	
</cffunction>

<cffunction name="getUsersInfo" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
	<cfargument name="user_id" type="string" required="true" />
	<CFQUERY NAME="qgetUsersInfo" datasource="#application.datasource#">
		SELECT 	U1.user_email as RFA_email, U2.user_email as RSP_email,
		U3.user_email as User_email, U3.name_first + U3.name_last as user_name,
		Contract_Main.contract_title,Contract_Main.contract_number
		FROM 	Contract_Main
				INNER JOIN _Users U1 On
				U1.User_id = broker_user_id
				INNER JOIN _Users U2 On
				U2.User_id = responsible_user_id
				INNER JOIN _Users U3 On
				U3.User_id = '#arguments.User_id#'
				WHERE 	Contract_Main.Contract_Main_ID = '#arguments.Program_ID#'
	</CFQUERY>
	<cfreturn qgetUsersInfo />
</cffunction>

</cfcomponent>