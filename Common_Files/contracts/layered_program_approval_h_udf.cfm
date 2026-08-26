<!--
  * ====================================================================================================
  *  @Author: Chris Nguyen
  *    @Date: 2021-01-01 07:37:39
  *
  * @Remarks: Layered program approval UDF for Custom_H
  *
  *
  *
  *
  * ====================================================================================================
 -->

<!--- set up variable to avoid loading this file more than once (e.g. in mass approval) --->
<cfset request.layered_program_approval_t_udf = "loaded">

<cfset showItem = appSettings.get_Setting('Display_Item_No')>
<cfset Cont_Margin_Calculation = appSettings.get_Setting('Contribution_Margin_Calculation')>


<cffunction name="big_star" output="true" hint="Returns a big star element with overriding hovering message and a hidden input for previous value">
	<cfargument name="field_name" required="true">
	<cfargument name="product_id" required="false" default="#getAllProductMargins.BSA_Foodservice_Items_Master_ID#">
	<cfargument name="row_counter" required="false" default="#getAllProductMargins.currentRow#">

	<!--- locate previously saved value from a query  --->
	<cfquery name="local.qOverride" dbtype="query">
		SELECT *
		  FROM qMargin_Override
		 WHERE BSA_Foodservice_Items_Master_ID = '#arguments.product_id#'
		 AND   LOWER(Field_Name)               = '#lCase(arguments.field_name)#'
	</cfquery>

	<cfoutput>
	<cfsavecontent variable="local.result">
		<!--- save old value in a hidden input --->
		<input type="hidden" name="old_#lcase(arguments.field_name)#_#arguments.row_counter#" value="#sanitize_input(replace(variables.value,'$',''))#">
		<cfif local.qOverride.recordCount>
				<i class="audit"
					title="Previous value #numberFormat(local.qOverride.Old_Value, request.dollar_format)# was changed by #local.qOverride.User_Name# on #dateFormat(local.qOverride.Created_Date, 'medium')#">
					&bigstar;
				</i>
		</cfif>
	</cfsavecontent>
	</cfoutput>

	<cfreturn application.util.string.compress(local.result)>
</cffunction>


<cffunction name="tabIndex" output="false" hint="Returns tabindex attribute using top to bottom method and disabled attribute based on editing mode">
	<cfargument name="seq">
    <cfargument name="bApprove" default=1>
	<cfreturn "tabindex='#((getAllProductMargins.currentRow * 1000) + arguments.seq)#' " & (isEditing.recordCount &&  getAllProductMargins.Group_ID_Approval ? " " : "disabled=disabled ")>
</cffunction>


<!---------------------------------------------------------------------------------------------------------------------->
<!------- VERTICALPNL() ------------------------------------------------------------------------------------------------>
<!---------------------------------------------------------------------------------------------------------------------->
<cffunction name="verticalPNL">
    <cfinclude template="verticalpnl_hm_udf.cfm">
</cffunction>


<!-------------------------------------------------------------------------------------------------------------------->
<!---  HORIZONTALPNL()  ---------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------------------------------------------------------->
<cffunction name="horizontalPNL">
    <cfinclude template="horizontalpnl_hm_udf.cfm">
</cffunction>



<cffunction name="sanitize_input" output="false" hint="Clean up extra characters in a numeric input">
	<cfargument name="formatted_number" required="true">

	<cfif isEditing.recordCount eq 0>
		<cfreturn application.util.string.stripHTML(arguments.formatted_number)>
	<cfelse>
		<!--- strip out dollar sign --->
		<cfset local.result = replace(arguments.formatted_number, "$", "")>

		<!--- handle negative number --->
		<cfif local.result contains "neg">
			<!--- strip out span tags --->
			<cfset local.result = application.util.string.stripHTML(local.result)>
			<!--- strip out parentheses --->
			<cfset local.result = "-" & replace( replace(local.result, "(", ""), ")", "" )>
		</cfif>
		<cfreturn local.result>
	</cfif>

</cffunction>


<cffunction name="neg_css" output="false">
	<cfargument name="formatted_number" required="true">

	<cfreturn arguments.formatted_number contains "neg" ? "neg" : "">
</cffunction>


<cffunction name="get_cost_detail" output="false">
    <cfargument name="program_id" required="true">

    <cfquery name="local.qCostDetail" datasource="#application.datasource#">
        /*** \common_Files\contracts\layered_program_approval_h_udf.cfm - get_cost_detail() ***/
        SELECT
                CASE ISNULL(CAST(Contract_Product_Margin.Net_weight as FLOAT), 0)
                WHEN 0 THEN 1
                ELSE ISNULL(CAST(Contract_Product_Margin.Net_weight as FLOAT), 0)
                END                                              AS Net_weight
                ,IsNull(fpr_cs, 0)                                AS Fixed_Price_CS
                ,IsNull(rer_cs, 0)                                AS Rebate_Price_CS
                ,IsNull(grr_cs, 0)                                AS Growth_Price_CS
                ,IsNull(kpr_cs, 0)                                AS Formula_Price_CS
                ,IsNull(oer_cs, 0)                                AS Offinvoice_Price_CS
                ,IsNull(LumpSumAmount_cs, 0)                      AS LumpsumAmount_CS
                ,IsNull(LumpSumAmount_lb, 0)                      AS LumpsumAmount_LB
                ,Description
                ,Item
                ,Upc
                ,IsNull(CONTRACT_PRODUCT_MARGIN.Base_Sales_lb, 0)                         AS Base_Sales_LB
                ,IsNull(CONTRACT_PRODUCT_MARGIN.Base_Sales_cs, 0)                         AS Base_Sales_CS
                ,IsNull(Program_Fixed_Price_cs, 0)                AS Program_Fixed_Price_CS
                ,IsNull(Used_Fixed_Price, 0)                      AS Used_Fixed_Price
                ,IsNull(Net_Price_cs, 0)                          AS Net_Price_CS
                ,IsNull(Used_Net_Price, 0)                        AS Used_Net_Price
                ,( IsNull(Item_Allowance_cs, 0)
                + IsNull(LumpSumAmount_cs, 0) )                AS Item_Allowance_CS
                ,( IsNull(Item_Allowance_lb, 0)
                + IsNull(LumpSumAmount_lb, 0) )                AS Item_Allowance_LB
                ,( IsNull(AnnualiZed_Allowance_cs, 0)
                + IsNull(AnnualiZed_LumpSum_Allowance_cs, 0) ) AS Item_Annualized_Allowance_CS
                ,( IsNull(AnnualiZed_Allowance_lb, 0)
                + IsNull(AnnualiZed_LumpSum_Allowance_lb, 0) ) AS Item_Annualized_Allowance_LB
                ,IsNull(tPa_cs, 0)                                AS TPA_CS
                ,IsNull(PullBackAmount_cs, 0)                     AS PullbackAmount_CS
                ,IsNull(Cash_Discount_cs, 0)                      AS Cash_Discount_CS
                ,IsNull(Net_Sales_cs, 0)                          AS Net_Sales_CS
                ,IsNull(Cost_cs, 0)                               AS Cost_CS
                ,IsNull(dIff_Fixed_Price_cs, 0)                   AS Diff_Fixed_Price_CS
                ,IsNull(dIff_Formula_Price_cs, 0)                 AS Diff_Formula_Price_CS
                ,IsNull(var_Man_Cost, 0)                          AS Variable_Mfg_Cost
                ,IsNull(fx_Man_Cost, 0)                           AS Fixed_Mfg_Cost
                ,IsNull(del_frt_Cost, 0)                          AS Del_Frt_Cost
                ,IsNull(del_del_Cost, 0)                          AS Del_Del_Cost
                ,IsNull(del_var_Warhs, 0)                         AS Del_Var_Warhs
                ,IsNull(del_cUst_Pickup, 0)                       AS Del_Cust_Pickup
                ,IsNull(Fob_frt_Cost, 0)                          AS FOB_Frt_Cost
                ,IsNull(Fob_Warhs, 0)                             AS FOB_Warhs
                ,IsNull(cs_Curr_Cost, 0)                          AS Current_Cost
                ,IsNull(Cost_From_Component_cs, 0)                AS Cost_From_Component_CS
                ,Item_DeliveryType
                ,IsNull(TargetMargin, 0)                          AS TargetMargin,
    
                <!--- 66894 Margin Target ENH Forge START --->
                <cfif OperatorProgram>
                ISNULL(Group_ID_Margin_Operator,0)
                <cfelse>
                IsNull(Group_Id_Margin, 0)
                </cfif> AS Margin_Target_Variation
                <!--- 66894 Margin Target ENH Forge END --->
    
                ,GROUP_APPROVAL_RIGHTS.Group_Id_Margin
                ,Product_ID
                ,ISNULL(Allowance_Surcharges_CS, 0) AS Allowance_Surcharges_CS
                ,ISNULL(Allowance_Surcharges_LB, 0) AS Allowance_Surcharges_LB
                ,ISNULL(Customer_Freight_CS, 0) AS Customer_Freight_CS
                ,ISNULL(Customer_Freight_LB, 0) AS Customer_Freight_LB
                ,ISNULL(ISNULL(nullif(cast(CP.case_count as decimal(14,0)),0),I.PACK_QTY),0) AS Case_Count
                ,ISNULL(ISNULL(nullif(cast(CP.case_cube as decimal(14,2)),0),i.Case_Count),0) as Case_Cube
                ,ROUND( (ISNULL(V.Volume_CS, 0) / 7) * 365,0) AS Volume
                ,ISNULL(CONTRACT_PRODUCT_MARGIN.Product_Program_Volume_CS,0) AS Product_Program_Volume_CS
                ,IsNull(FPV_CS, 0)                               AS Current_Price_CS
                ,ISNULL(Contribution_Margin_Alt_CS, 0) AS Contribution_Margin_Alt_CS
                ,ISNULL(SGA_CS, 0) AS	SGA_CS
                ,ISNULL(Operating_Income_CS, 0) AS	Operating_Income_CS
                ,I.Type_Code_desc_Id
        FROM dbo.CONTRACT_PRODUCT_MARGIN
                INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER I
                        ON I.bsa_FoodService_Items_Master_Id = CONTRACT_PRODUCT_MARGIN.Product_Id
                        AND I.Deleted = 0
                INNER JOIN CONTRACT_PRODUCTS CP ON
                        /*--- CP.Contract_Products_ID = CONTRACT_PRODUCT_MARGIN.Contract_Product_ID */
                        CP.Contract_Main_Id = CONTRACT_PRODUCT_MARGIN.Contract_Main_Id AND
                        CP.Bsa_FoodService_Items_Master_Id = I.Bsa_FoodService_Items_Master_Id
                LEFT JOIN Program_Product_Volume V ON
                        I.BSA_Foodservice_Items_Master_ID = V.BSA_Foodservice_Items_Master_ID AND
                        V.Program_Id = CP.Contract_Main_Id
                INNER JOIN TYPE_CODE_DESC
                        ON TYPE_CODE_DESC.Type_Code_desc_Id = I.Type_Code_desc_Id
                        AND TYPE_CODE_DESC.Deleted = 0
                LEFT JOIN GROUP_APPROVAL_RIGHTS
                    ON GROUP_APPROVAL_RIGHTS.Group_Id = TYPE_CODE_DESC.Type_Code_desc_Id
                        AND GROUP_APPROVAL_RIGHTS.User_Profile_Id = #request.Accessstructure.Profiles_ID#
                        AND GROUP_APPROVAL_RIGHTS.Deleted = 0
        WHERE CONTRACT_PRODUCT_MARGIN.Contract_Main_Id = #arguments.program_id# 
               --AND CP.Product_Type_ID = 1
    </cfquery>    

    <cfreturn local.qCostDetail>
</cffunction>


