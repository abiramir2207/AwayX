<cfsilent>
<cfquery name="getUSDAUserStatus" datasource="#application.datasource#">
 	SELECT Is_USDA_User, user_usda_state_id, user_usda_county_id, user_usda_operator_id, user_usda_distributor_id, user_usda_distributor_id_list, user_usda_broker_id_list, user_usda_operator_id_list
	FROM _Users
	WHERE User_ID = '#request.AccessStructure.User_ID#'
  </cfquery>
  
<cfif len(trim(getUSDAUserStatus.user_usda_distributor_id)) GT 0>
<!---Returns operators included on programs that also include the distributor--->
<cfquery name="GetOperators" datasource="#application.datasource#">
SELECT BSA_Operator.Operator_Name, BSA_Operator.BSA_Operator_ID
FROM BSA_Operator
WHERE BSA_Operator.BSA_Operator_ID IN 
	(
	SELECT DISTINCT BSA_Operator_ID
     FROM          dbo.Contract_Operators
     WHERE      Contract_Main_ID IN
	     (
		 SELECT DISTINCT dbo.Program_Rebates_Product_Data.Program_ID
	     FROM          dbo.Program_Rebates_Component 
		 INNER JOIN    dbo.Program_Rebates_Component_Data ON 
	     dbo.Program_Rebates_Component.Program_Rebates_Component_ID =
		 dbo.Program_Rebates_Component_Data.Program_Rebates_Component_ID
		 AND Program_Rebates_Component_Data.Deleted = 0
	     INNER JOIN	   dbo.Program_Rebates_Component_Name ON 
	     dbo.Program_Rebates_Component.Program_Rebates_Component_Name_ID =
		 dbo.Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
	     INNER JOIN   dbo.Program_Rebates_Product_Data ON 
	  	 dbo.Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID =
		 dbo.Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
		 AND Program_Rebates_Product_Data.Deleted = 0
	     INNER JOIN   dbo.Contract_Main ON 
		 dbo.Program_Rebates_Product_Data.Program_ID = dbo.Contract_Main.Contract_Main_ID
		-- AND Contract_Main.Deleted = 0
		 INNER JOIN   Contract_Distributors
		 ON Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
		 AND Contract_Distributors.Deleted = 0
		 AND Contract_Distributors.BSA_Foodservice_Customers_ID = '#getUSDAUserStatus.user_usda_distributor_id#'
	     WHERE      (dbo.Program_Rebates_Component_Name.Is_USDA_NOI_Comp = 1) AND 
		 			((dbo.Contract_Main.Deleted = 0) OR (dbo.Contract_Main.Deleted = 1 and Contract_Main.Contract_Status_Type_IDX = 7))		
		 AND (Contract_Main.Contract_Status_Type_IDX >= 3)
		AND cancelled_by is null
		 )
	 
	AND (Contract_Operators.Deleted = 0)
	) 
AND BSA_Operator.Deleted = 0
ORDER BY Operator_Name
</cfquery>
<cfelseif len(trim(getUSDAUserStatus.user_usda_operator_id_list)) GT 0>
<cfquery name="GetOperators" datasource="#application.datasource#">
SELECT BSA_Operator.Operator_Name, BSA_Operator.BSA_Operator_ID
FROM BSA_Operator
WHERE BSA_Operator.BSA_Operator_ID IN (#listqualify(getUSDAUserStatus.user_usda_operator_id_list, "'")#) 
AND BSA_Operator.Deleted = 0
ORDER BY Operator_Name
</cfquery>
<cfelseif len(trim(getUSDAUserStatus.user_usda_distributor_id_list)) GT 0>
<cfquery name="GetOperators" datasource="#application.datasource#">
SELECT BSA_Operator.Operator_Name, BSA_Operator.BSA_Operator_ID
FROM BSA_Operator
WHERE BSA_Operator.BSA_Operator_ID IN 
	(
	SELECT DISTINCT BSA_Operator_ID
     FROM          dbo.Contract_Operators
     WHERE      Contract_Main_ID IN
	     (
		 SELECT DISTINCT dbo.Program_Rebates_Product_Data.Program_ID
	     FROM          dbo.Program_Rebates_Component 
		 INNER JOIN    dbo.Program_Rebates_Component_Data ON 
	     dbo.Program_Rebates_Component.Program_Rebates_Component_ID =
		 dbo.Program_Rebates_Component_Data.Program_Rebates_Component_ID
		 AND Program_Rebates_Component_Data.Deleted = 0
	     INNER JOIN	   dbo.Program_Rebates_Component_Name ON 
	     dbo.Program_Rebates_Component.Program_Rebates_Component_Name_ID =
		 dbo.Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
	     INNER JOIN   dbo.Program_Rebates_Product_Data ON 
	  	 dbo.Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID =
		 dbo.Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
		 AND Program_Rebates_Product_Data.Deleted = 0
	     INNER JOIN   dbo.Contract_Main ON 
		 dbo.Program_Rebates_Product_Data.Program_ID = dbo.Contract_Main.Contract_Main_ID
		-- AND Contract_Main.Deleted = 0
		 INNER JOIN   Contract_Distributors
		 ON Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
		 AND Contract_Distributors.Deleted = 0
		 AND Contract_Distributors.BSA_Foodservice_Customers_ID IN (#listqualify(getUSDAUserStatus.user_usda_distributor_id_list, "'")#)
	     WHERE      (dbo.Program_Rebates_Component_Name.Is_USDA_NOI_Comp = 1) AND 
		 			((dbo.Contract_Main.Deleted = 0) OR (dbo.Contract_Main.Deleted = 1 and Contract_Main.Contract_Status_Type_IDX = 7))			
		 AND (Contract_Main.Contract_Status_Type_IDX >= 3)
		 AND cancelled_by is null
		 --AND (Contract_Main.Contract_Status_Type_IDX != 7)
		 )
	 
	AND (Contract_Operators.Deleted = 0)
	) 
AND BSA_Operator.Deleted = 0
ORDER BY Operator_Name
</cfquery>
<cfelseif len(trim(getUSDAUserStatus.user_usda_broker_id_list)) GT 0>

<cfquery name="GetOperators" datasource="#application.datasource#">
SELECT BSA_Operator.Operator_Name, BSA_Operator.BSA_Operator_ID
FROM BSA_Operator
WHERE BSA_Operator.BSA_Operator_ID IN 
	(
	SELECT DISTINCT BSA_Operator_ID
     FROM          dbo.Contract_Operators
     WHERE      Contract_Main_ID IN
	     (
		 SELECT DISTINCT dbo.Program_Rebates_Product_Data.Program_ID
	     FROM          dbo.Program_Rebates_Component 
		 INNER JOIN    dbo.Program_Rebates_Component_Data ON 
	     dbo.Program_Rebates_Component.Program_Rebates_Component_ID =
		 dbo.Program_Rebates_Component_Data.Program_Rebates_Component_ID
		 AND Program_Rebates_Component_Data.Deleted = 0
	     INNER JOIN	   dbo.Program_Rebates_Component_Name ON 
	     dbo.Program_Rebates_Component.Program_Rebates_Component_Name_ID =
		 dbo.Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
	     INNER JOIN   dbo.Program_Rebates_Product_Data ON 
	  	 dbo.Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID =
		 dbo.Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
		 AND Program_Rebates_Product_Data.Deleted = 0
	     INNER JOIN   dbo.Contract_Main ON 
		 dbo.Program_Rebates_Product_Data.Program_ID = dbo.Contract_Main.Contract_Main_ID
		-- AND Contract_Main.Deleted = 0
		 INNER JOIN   Contract_Distributors
		 ON Contract_Distributors.Contract_Main_ID = Contract_Main.Contract_Main_ID
		 AND Contract_Distributors.Deleted = 0
		 INNER JOIN BSA_Foodservice_Customers on
		BSA_Foodservice_Customers.BSA_Foodservice_Customers_id = Contract_Distributors.BSA_Foodservice_Customers_id
		 AND BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID IN (#listqualify(getUSDAUserStatus.user_usda_broker_id_list, "'")#)
	     WHERE      (dbo.Program_Rebates_Component_Name.Is_USDA_NOI_Comp = 1) AND 
		 			((dbo.Contract_Main.Deleted = 0) OR (dbo.Contract_Main.Deleted = 1 and Contract_Main.Contract_Status_Type_IDX = 7))			
		 AND (Contract_Main.Contract_Status_Type_IDX >= 3)
		 AND cancelled_by is null
		-- AND (Contract_Main.Contract_Status_Type_IDX != 7)
		 )
	 
	AND (Contract_Operators.Deleted = 0)
	) 
AND BSA_Operator.Deleted = 0
ORDER BY Operator_Name
</cfquery>

<cfquery name="GetDistributors" datasource="#application.datasource#">
	select distinct BSA_Foodservice_Customers.BSA_Foodservice_Customers_id,name
	from Contract_Main inner join 
	contract_distributors on contract_distributors.Contract_Main_id = 
	Contract_Main.Contract_Main_id  inner join 
	BSA_Foodservice_Customers on
	BSA_Foodservice_Customers.BSA_Foodservice_Customers_id = contract_distributors.BSA_Foodservice_Customers_id
	inner join usdanoi_output on
	usdanoi_output.distributor_id = BSA_Foodservice_Customers.BSA_Foodservice_Customers_id
	where cancelled_by is null and contract_distributors.deleted = 0 and BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID IN (#listqualify(getUSDAUserStatus.user_usda_broker_id_list, "'")#)
</cfquery>

</cfif>
</cfsilent>