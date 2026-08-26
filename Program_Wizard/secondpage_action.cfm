<!----
/Program_Wizard/secondpage_action.cfm

Created By: Brenda Flynn
			bflynn@awayx.com
Created On: May 5, 2003
			Feliz Cinco de Mayo
Modified By: RBL 12/10/08
Last Modified On:
-----------------------------

Processes form information from the previous page.

--->

<!---Default parameters--->
<cfparam name="Form.RateTypeOption_1" 			default="0">
<cfparam name="Form.RateTypeOption_2" 			default="0">
<cfparam name="Form.RateTypeOption_3" 			default="0">
<cfparam name="Form.RateTypeOption_4" 			default="0"><!---63887 --->
<cfparam name="Form.RateTypeOption_5" 			default="0"><!---76541 --->
<cfparam name="Form.RateTypeOption_6" 			default="0"><!---82429 --->
<cfparam name="Form.RateTypeDefault" 			default="0">

<cfparam name="Form.Group_Programs_UOM" 		default="0">
<cfparam name="Form.Groups_UOM_1" 				default="0">
<cfparam name="Form.Groups_UOM_2" 				default="0">
<cfparam name="Form.Groups_UOM_3" 				default="0">
<cfparam name="Form.Groups_UOM_Default" 		default="0">

<cfparam name="Form.Restrict_On_Inventory_UOM_Pound" 	default="0">
<cfparam name="Form.Restrict_On_Inventory_UOM_Case" 	default="0">

<!---
<cfparam name="Form.ClaimMechOption_2" 			default="0">
<cfparam name="Form.ClaimMechOption_3" 			default="0">
<cfparam name="Form.ClaimMechOption_4" 			default="0">
<cfparam name="Form.ClaimMechOption_5" 			default="0">
<cfparam name="Form.ClaimMechOption_6" 			default="0">
<cfparam name="Form.ClaimMechOption_7" 			default="0">
--->
<cfparam name="Form.ClaimMechDefaultOption" 	default="0">
<cfparam name="Form.CurrencyDefaultOption" 		default="0">
<cfparam name="Form.LabelSetDefaultOption" 		default="">
<cfparam name="Form.Default_Payment_Type" 		default="0">

<cfparam name="Form.PayCycleOption_1"		 	default="0">
<cfparam name="Form.PayCycleOption_2"		 	default="0">
<cfparam name="Form.PayCycleOption_3"		 	default="0">
<cfparam name="Form.PayCycleOption_4"		 	default="0">
<cfparam name="Form.PayCycleOption_5"		 	default="0">
<cfparam name="Form.PayCycleOption_6"		 	default="0">
<cfparam name="Form.PayCycleOption_7"		 	default="0">
<cfparam name="Form.PayCycleOption_8"		 	default="0">
<cfparam name="Form.PayCycleOption_9"		 	default="0">
<cfparam name="Form.PayCycleOption_10"		 	default="0">
<cfparam name="Form.PayCycleOption_11"		 	default="0">
<cfparam name="Form.PayCycleOption_12"		 	default="0"><!---Dinesh --->
<cfparam name="Form.PayCycleOption_13"		 	default="0">
<cfparam name="Form.PayCycleOption_14"		 	default="0">
<cfparam name="Form.PayCycleOption_15"		 	default="0">
<cfparam name="Form.PayCycleDefaultOption"	 	default="0">

<cfparam name="Form.Discount_Fixed_Prices"	 	default="0">
<cfparam name="Form.Fixed_Type" 				default="0">
<cfparam name="Form.Fixed_Type_Explanation"		default="">
<cfparam name="Form.Discount_Rebates"		 	default="0">
<cfparam name="Form.Discount_Lump_Sums"		 	default="0">
<cfparam name="Form.Discount_Lump_Sums_Item_Mandated" default="0">
<cfparam name="Form.Discount_Lump_Sums_Distributor_Mandated" default="0">
<cfparam name="Form.Discount_Lump_Sums_Document_Attachment_Mandated" default="0">
<cfparam name="Form.Discount_Growth"		 	default="0">
<cfparam name="Form.Allow_Growth_Multi_Rate" 	default="0">
<cfparam name="Form.Discount_Formula_Pricing" 	default="0">
<cfparam name="Form.Discount_BidRequest"		 	default="0">

<cfparam name="Line_Item_On"					default="3">
<cfparam name="Bid_Line_Item_Option_Default"	default="1">

<!--- While adding products in the discount pages, we may get a pop-up message. These variables store those messages --->
<cfparam name="Form.Discount_Fixed_Prices_Product_Message"		default="">
<cfparam name="Form.Discount_Rebates_Product_Message"		default="">
<cfparam name="Form.Discount_Lump_Sums_Product_Message"		default="">
<cfparam name="Form.Discount_Growth_Product_Message"		default="">
<cfparam name="Form.Discount_Formula_Pricing_Product_Message"		default="">
<cfparam name="Form.Discount_BidRequest_Product_Message"		default="">
<cfparam name="Form.Discount_OffInvoice_Product_Message"		default="">

<!---Minimum and maximums--->
<cfparam name="Form.Max_Fixed_Pound"	 		default="">
<cfparam name="Form.Min_Fixed_Pound"	 		default="">
<cfparam name="Form.Min_Fixed_Case"	 			default="">
<cfparam name="Form.Max_Fixed_Case" 			default="">

<cfparam name="Form.Min_Rebate_Case"	 		default="">
<cfparam name="Form.Min_Rebate_Pound"	 		default="">
<cfparam name="Form.Min_Rebate_Percent"	 		default="">
<cfparam name="Form.Max_Rebate_Pound"	 		default="">
<cfparam name="Form.Max_Rebate_Case"	 		default="">
<cfparam name="Form.Max_Rebate_Percent"	 		default="">

<cfparam name="Form.Min_Growth_Case"	 		default="">
<cfparam name="Form.Min_Growth_Pound"	 		default="">
<cfparam name="Form.Min_Growth_Percent"	 		default="">
<cfparam name="Form.Max_Growth_Pound"	 		default="">
<cfparam name="Form.Max_Growth_Case"	 		default="">
<cfparam name="Form.Max_Growth_Percent"	 		default="">

<cfparam name="Form.Min_Formula_Pound"	 		default="">
<cfparam name="Form.Min_Formula_Percent"	 	default="">
<cfparam name="Form.Max_Formula_Percent"		default="">
<cfparam name="Form.Max_Formula_Pound" 			default="">

<cfparam name="Form.Min_OffInvoice_Case"	 	default="">
<cfparam name="Form.Min_OffInvoice_Pound"	 	default="">
<cfparam name="Form.Min_OffInvoice_Percent"	 	default="">
<cfparam name="Form.Max_OffInvoice_Pound"	 	default="">
<cfparam name="Form.Max_OffInvoice_Case"	 	default="">
<cfparam name="Form.Max_OffInvoice_Percent"	 	default="">

<cfparam name="Form.Min_BidRequest_Case"	 	default="">
<cfparam name="Form.Min_BidRequest_Pound"	 	default="">
<cfparam name="Form.Max_BidRequest_Case"	 	default="">
<cfparam name="Form.Max_BidRequest_Pound" 		default="">


<!---group and item levels--->
<cfparam name="Form.Discount_Rebates_Item_Level"	default="0" />
<cfparam name="Form.Discount_Rebates_Group_Level" 	default="0" />
<cfparam name="Form.Discount_Fixed_Item_Level"	default="0" />
<cfparam name="Form.Discount_Fixed_Group_Level" 	default="0" />
<cfparam name="Form.Discount_Lump_Sums_Item_Level"	default="0" />
<cfparam name="Form.Discount_Lump_Sums_Group_Level"	default="0" />
<cfparam name="Form.Discount_Growth_Item_Level" 	default="0" />
<cfparam name="Form.Discount_Growth_Group_Level" 	default="0" />

<!---Group Options--->
<cfparam name="Form.Allow_Multi" 					default="0" />
<cfparam name="Form.Allow_Single" 					default="0" />
<cfparam name="Form.Allow_Stairway" 				default="0" />
<cfparam name="Form.Allow_XofY" 					default="0" />
<cfparam name="Form.Allow_Volume_Pool_Seperation" 	default="0" />
<cfparam name="Form.Growth_Auto_Pay" 	default="0" />	<!--- D35731 Growth Auto Pay --->
<cfparam name="Form.Bonus_Field" 					default="0" />
<cfparam name="Form.Growth_Min_Purchase" 	default="0" />	<!--- 45068 Growth � Minimum $ Purchase --->

<cfparam name="Form.Product_List" 					default="">

<cfparam name="Form.Bid_Rule_Option"		 	default="0">

<cfparam name="Form.IsDominant"					default="0">
<cfparam name="error"							default="0">
<cfparam name="Form.Program_Spending_Type" 	default="0" />
<cfparam name="Form.Lumpsum_Spending_Type" 	default="0" />
<cfparam name="Form.Category_ID" 	default="" />
<cfparam name="Form.display_Bidrequest_basesales" 	default="0" />
<cfparam name="Form.display_FixedPrice_basesales" 	default="0" />

<cfparam name="Form.minPerfRequirements" default="0" />
<cfparam name="Form.maxPerfRequirements" default="*" />
<cfparam name="Form.MinPerfRequirementsOn" default="0" />
<cfparam name="Form.MaxPerfRequirementsOn" default="0" />

<cfparam name="form.Discount_Fixed_Prices_Freight" default="0" />
<cfparam name="form.Fixed_Price_Populates_Price_List_Special" default=0/>
<cfparam name="form.price_list_type" default="0"/><!--- 71241 --->

<!---- Added for D19117 Start ---->
<cfparam name="FORM.Operator_Off_Invoice_Volume"            default="0" />
<cfparam name="FORM.Operator_Billback_Volume"                 default="0" />
<cfparam name="FORM.Distributor_Off_Invoice_Volume"  default="0" />
<cfparam name="FORM.Distributor_Billback_Volume"                 default="0" />
<cfparam name="FORM.Adjust_For_Credits"                       default="0" />

<cfparam name="FORM.Volume_Distributor_Template_GroupB_Default" default="4" />
<cfparam name="FORM.Volume_Operator_Template_GroupB_Default"    default="2" />

<!---- Added for D19117 End ---->
<cfparam name="FORM.Display_FixedPrice_Basesales_On_Approval"	default="0" />

<cfparam name="FORM.Fixed_Rebate_Grid_Option"	default="0" />
<cfparam name="FORM.Market_Price"	default="0" />
<cfparam name="FORM.Market_Price_Update_Process"	default="0" />
<cfparam name="FORM.Custom_Fixed_Price_Options"	default="0" />

<!--- Program Qualification --->
<cfparam name="FORM.Enable_Program_Qualifications"	default="0" />
<cfparam name="FORM.Program_Qualifications_Doc_Attach_Req"	default="0" />
<cfparam name="FORM.Program_Qualifications_Doc_Msg"	default="" />
<cfparam name="form.qualification_ids" default="">
<cfparam name="form.Volume_Page_UOM_CS" default="0">
<cfparam name="form.Volume_Page_UOM_LB" default="0">
<cfparam name="form.qualification_row_ids" default="">
<cfparam name="Form.RFP_Process" default="0">
<cfparam name="Form.Formula_Pricing_Type" default="0">

<cfparam name="Form.Ideal_Price" default="0"> <!--- 114617 :: Ideal Price  --->
<cfparam name="FORM.Planner_Perf_Types_ID" default="">

<!--- If "Fixed_Price_Populates_Price_List_Special" checkbox is OFF, Set "price list type" to 0, as "price list type" is dependant on "Fixed_Price_Populates_Price_List_Special". --->
<cfif form.Fixed_Price_Populates_Price_List_Special eq 0>
	<cfset form.price_list_type = 0>
</cfif>

<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />

<!---Do only if they're using X Material--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif appSettings.getUseXMaterial() IS 1 AND len(trim(Form.Product_List)) GT 0>
	<cfset UpdateProduct = 1>
<cfelse>
	<cfset UpdateProduct = 0>
</cfif>

<!---For bid request --->
<cfparam name="Line_Item_On"					default="3">
<cfparam name="Bid_Line_Item_Option_Default"	default="1">
<cfif listlen(Line_Item_On) GT 1>
	<cfset Bid_Line_Item_Option = 3>
<cfelse>
	<cfset Bid_Line_Item_Option = Line_Item_On>
</cfif>

<cfif isDefined("ID")>

<!--- if market price, we need the Rstes Grid --->
<cfif trim(form.Market_Price) eq 1>
	<cfset form.Fixed_Rebate_Grid_Option = 1 />
</cfif>
<!--- if Fixed/Rebate Grid is checked then we have to turn on the Fixed and Rebate discount types --->
<cfif trim(form.Fixed_Rebate_Grid_Option) eq 1>
<!---	<cfset form.Discount_Fixed_Prices = 1 />
	<cfset form.Discount_Rebates = 1 />--->
	<cfset form.Discount_Rebates_Item_Level = 1 />
</cfif>
<!--- 114617 :: Ideal Price START --->
<cfquery name="getTemplateParentID" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID =  <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
</cfquery>
<cfif ! form.Discount_Fixed_Prices>
	<cfset Ideal_Price = 0>
	<cfset useLakebaseForUpdData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ideal_price_template_list")>
<cfif useLakebaseForUpdData>
	<cftry>
		<cfset application.oLakebase.updateRows("ideal_price_template_list",
			{
				"first_parent_id" = "eq.#getTemplateParentID.First_Parent_ID#"
			},
			{
				"deleted" = "1",
				"deleted_date" = "#now()#",
				"deleted_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdData>
<cfquery name="UpdData" datasource="#application.datasource#">
		UPDATE Ideal_Price_Template_List
		SET Deleted =1, Deleted_Date = getdate(), Deleted_By = '#request.AccessStructure.User_ID#'
		WHERE First_Parent_ID = #getTemplateParentID.First_Parent_ID#
	</cfquery>
</cfif>
</cfif>
<!--- 114617 :: Ideal Price END --->

<!--- Get Current Data For Auditing --->
<cfset variables.qOriginal = getTemplateParentID>

<cfquery name="UpdateTemplate" datasource="#application.datasource#">
	UPDATE 	Program_Control_Panel_Options
	SET
			RateTypeOption_1 		= 	<cfqueryparam value="#Form.RateTypeOption_1#" cfsqltype="cf_sql_integer">,
			RateTypeOption_2 		= 	<cfqueryparam value="#Form.RateTypeOption_2#" cfsqltype="cf_sql_integer">,
			RateTypeOption_3		=	<cfqueryparam value="#Form.RateTypeOption_3#" cfsqltype="cf_sql_integer">,
			RateTypeOption_4		=	<cfqueryparam value="#Form.RateTypeOption_4#" cfsqltype="cf_sql_integer">,<!---63887--->
			RateTypeOption_5		=	<cfqueryparam value="#Form.RateTypeOption_5#" cfsqltype="cf_sql_integer">,<!---76541--->
			RateTypeOption_6		=	<cfqueryparam value="#Form.RateTypeOption_6#" cfsqltype="cf_sql_integer">,<!---82429 --->
			RateTypeDefault			=	<cfqueryparam value="#Form.RateTypeDefault#" cfsqltype="cf_sql_integer">,
			Group_Programs_UOM		=	<cfqueryparam cfsqltype="CF_SQL_BIT" value="#Form.Group_Programs_UOM#">,
			Groups_UOM_1			=	<cfqueryparam cfsqltype="CF_SQL_BIT" value="#Form.Groups_UOM_1#">,
			Groups_UOM_2			=	<cfqueryparam cfsqltype="CF_SQL_BIT" value="#Form.Groups_UOM_2#">,
			Groups_UOM_3			=	<cfqueryparam cfsqltype="CF_SQL_BIT" value="#Form.Groups_UOM_3#">,
			Groups_UOM_Default		=	<cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Form.Groups_UOM_Default#">,
			ClaimMechDefaultOption 	= 	<cfqueryparam value="#Form.ClaimMechDefaultOption#" cfsqltype="cf_sql_integer">,
			PayCycleOption_1		= 	<cfqueryparam value="#Form.PayCycleOption_1#" cfsqltype="cf_sql_integer">,
			PayCycleOption_2		= 	<cfqueryparam value="#Form.PayCycleOption_2#" cfsqltype="cf_sql_integer">,
			PayCycleOption_3		= 	<cfqueryparam value="#Form.PayCycleOption_3#" cfsqltype="cf_sql_integer">,
			PayCycleOption_4		= 	<cfqueryparam value="#Form.PayCycleOption_4#" cfsqltype="cf_sql_integer">,
			PayCycleOption_5		= 	<cfqueryparam value="#Form.PayCycleOption_5#" cfsqltype="cf_sql_integer">,
			PayCycleOption_6		= 	<cfqueryparam value="#Form.PayCycleOption_6#" cfsqltype="cf_sql_integer">,
			PayCycleOption_7		= 	<cfqueryparam value="#Form.PayCycleOption_7#" cfsqltype="cf_sql_integer">,
			PayCycleOption_8		= 	<cfqueryparam value="#Form.PayCycleOption_8#" cfsqltype="cf_sql_integer">,
			PayCycleOption_9		= 	<cfqueryparam value="#Form.PayCycleOption_9#" cfsqltype="cf_sql_integer">,
			PayCycleOption_10		= 	<cfqueryparam value="#Form.PayCycleOption_10#" cfsqltype="cf_sql_integer">,
			PayCycleOption_11		= 	<cfqueryparam value="#Form.PayCycleOption_11#" cfsqltype="cf_sql_integer">,
			PayCycleOption_12		= 	<cfqueryparam value="#Form.PayCycleOption_12#" cfsqltype="cf_sql_integer">,<!------D47825 :: Payment frequency:  Add fiscal year option --->
			PayCycleOption_13		= 	<cfqueryparam value="#Form.PayCycleOption_13#" cfsqltype="cf_sql_integer">,
			PayCycleOption_14		= 	<cfqueryparam value="#Form.PayCycleOption_14#" cfsqltype="cf_sql_integer">,
			PayCycleOption_15		= 	<cfqueryparam value="#Form.PayCycleOption_15#" cfsqltype="cf_sql_integer">,
			PayCycleDefaultOption	= 	<cfqueryparam value="#Form.PayCycleDefaultOption#" cfsqltype="cf_sql_integer">,
			Discount_Fixed_Prices	= 	<cfqueryparam value="#Form.Discount_Fixed_Prices#" cfsqltype="cf_sql_integer">,
			Fixed_Type				= 	<cfqueryparam value="#Form.Fixed_Type#" cfsqltype="CF_SQL_FLOAT">,
			Fixed_Type_Explanation 	=	<cfqueryparam value="#Form.Fixed_Type_Explanation#" cfsqltype="cf_sql_varchar">,
			Discount_Rebates		= 	<cfqueryparam value="#Form.Discount_Rebates#" cfsqltype="cf_sql_integer">,
			Discount_Lump_Sums		= 	<cfqueryparam value="#Form.Discount_Lump_Sums#" cfsqltype="cf_sql_integer">,
			Discount_BidRequest     =   <cfqueryparam value="#Form.Discount_BidRequest#" cfsqltype="cf_sql_integer">,
			Discount_Lump_Sums_Item_Mandated = <cfqueryparam value="#Form.Discount_Lump_Sums_Item_Mandated#" cfsqltype="cf_sql_integer">,
			Discount_Lump_Sums_Distributor_Mandated = <cfqueryparam value="#Form.Discount_Lump_Sums_Distributor_Mandated#" cfsqltype="cf_sql_integer">,
			Discount_Lump_Sums_Document_Attachment_Mandated = <cfqueryparam value="#Discount_Lump_Sums_Document_Attachment_Mandated#" cfsqltype="cf_sql_bit">,
			Discount_Growth			= 	<cfqueryparam value="#Form.Discount_Growth#" cfsqltype="cf_sql_integer">,
			Discount_Formula_Pricing=	<cfqueryparam value="#Form.Discount_Formula_Pricing#" cfsqltype="cf_sql_integer">,
			Bid_Line_Item_Option	= 	<cfqueryparam value="#Bid_Line_Item_Option#" cfsqltype="CF_SQL_FLOAT" null="#Bid_Line_Item_Option EQ ""#">,
			Bid_Line_Item_Option_Default=<cfqueryparam value="#Bid_Line_Item_Option_Default#" cfsqltype="CF_SQL_FLOAT" null="#Bid_Line_Item_Option_Default EQ ""#">,

			Min_Fixed_Pound 		=	<cfqueryparam value="#Form.Min_Fixed_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Fixed_Pound EQ ""#">,
			Max_Fixed_Pound 		=	<cfqueryparam value="#Form.Max_Fixed_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Fixed_Pound EQ ""#">,
			Min_Fixed_Case 			=	<cfqueryparam value="#Form.Min_Fixed_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Fixed_Case EQ ""#">,
			Max_Fixed_Case 			=	<cfqueryparam value="#Form.Max_Fixed_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Fixed_Case EQ ""#">,
			Min_Rebate_Pound 		=	<cfqueryparam value="#Form.Min_Rebate_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Rebate_Pound EQ ""#">,
			Min_Rebate_Case 		=	<cfqueryparam value="#Form.Min_Rebate_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Rebate_Case EQ ""#">,
			Min_Rebate_Percent 		=	<cfqueryparam value="#Form.Min_Rebate_Percent#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Rebate_Percent EQ ""#">,
			Max_Rebate_Pound 		=	<cfqueryparam value="#Form.Max_Rebate_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Rebate_Pound EQ ""#">,
			Max_Rebate_Case 		=	<cfqueryparam value="#Form.Max_Rebate_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Rebate_Case EQ ""#">,
			Max_Rebate_Percent 		=	<cfqueryparam value="#Form.Max_Rebate_Percent#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Rebate_Percent EQ ""#">,
			Min_Growth_Pound 		=	<cfqueryparam value="#Form.Min_Growth_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Growth_Pound EQ ""#">,
			Min_Growth_Case 		=	<cfqueryparam value="#Form.Min_Growth_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Growth_Case EQ ""#">,
			Min_Growth_Percent 		=	<cfqueryparam value="#Form.Min_Growth_Percent#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Growth_Percent EQ ""#">,
			Max_Growth_Pound 		=	<cfqueryparam value="#Form.Max_Growth_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Growth_Pound EQ ""#">,
			Max_Growth_Case 		=	<cfqueryparam value="#Form.Max_Growth_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Growth_Case EQ ""#">,
			Max_Growth_Percent 		=	<cfqueryparam value="#Form.Max_Growth_Percent#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Growth_Percent EQ ""#">,
			Min_Formula_Pound 		=	<cfqueryparam value="#Form.Min_Formula_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Formula_Pound EQ ""#">,
			Max_Formula_Pound 		=	<cfqueryparam value="#Form.Max_Formula_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Formula_Pound EQ ""#">,
			Min_Formula_Percent 	=	<cfqueryparam value="#Form.Min_Formula_Percent#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_Formula_Percent EQ ""#">,
			Max_Formula_Percent 	=	<cfqueryparam value="#Form.Max_Formula_Percent#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_Formula_Percent EQ ""#">,
			Min_OffInvoice_Pound 	=	<cfqueryparam value="#Form.Min_OffInvoice_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_OffInvoice_Pound EQ ""#">,
			Min_OffInvoice_Case 	=	<cfqueryparam value="#Form.Min_OffInvoice_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_OffInvoice_Case EQ ""#">,
			Min_OffInvoice_Percent 	=	<cfqueryparam value="#Form.Min_OffInvoice_Percent#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_OffInvoice_Percent EQ ""#">,
			Max_OffInvoice_Pound 	=	<cfqueryparam value="#Form.Max_OffInvoice_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_OffInvoice_Pound EQ ""#">,
			Max_OffInvoice_Case 	=	<cfqueryparam value="#Form.Max_OffInvoice_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_OffInvoice_Case EQ ""#">,
			Max_OffInvoice_Percent 	=	<cfqueryparam value="#Form.Max_OffInvoice_Percent#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_OffInvoice_Percent EQ ""#">,
			Min_BidRequest_Pound 	=	<cfqueryparam value="#Form.Min_BidRequest_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_BidRequest_Pound EQ ""#">,
			Max_BidRequest_Pound 	=	<cfqueryparam value="#Form.Max_BidRequest_Pound#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_BidRequest_Pound EQ ""#">,
			Min_BidRequest_Case 	=	<cfqueryparam value="#Form.Min_BidRequest_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Min_BidRequest_Case EQ ""#">,
			Max_BidRequest_Case 	=	<cfqueryparam value="#Form.Max_BidRequest_Case#" cfsqltype="CF_SQL_FLOAT" null="#Form.Max_BidRequest_Case EQ ""#">,

			Bid_Rule_Option			=	<cfqueryparam value="#Form.Bid_Rule_Option#" cfsqltype="cf_sql_integer">,
			Updated_By				=	<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="cf_sql_varchar">,
			Discount_Rebates_Item_Level 	= 	<cfqueryparam value="#Form.Discount_Rebates_Item_Level#" cfsqltype="cf_sql_integer">,
			Discount_Rebates_Group_Level 	= 	<cfqueryparam value="#Form.Discount_Rebates_Group_Level#" cfsqltype="cf_sql_integer">,
			Discount_Fixed_Item_Level 	= 	<cfqueryparam value="#Form.Discount_Fixed_Item_Level#" cfsqltype="cf_sql_integer">,
			Discount_Fixed_Group_Level 	= 	<cfqueryparam value="#Form.Discount_Fixed_Group_Level#" cfsqltype="cf_sql_integer">,
			Discount_Lump_Sums_Item_Level 	= 	<cfqueryparam value="#Form.Discount_Lump_Sums_Item_Level#" cfsqltype="cf_sql_integer">,
			Discount_Lump_Sums_Group_Level 	= 	<cfqueryparam value="#Form.Discount_Lump_Sums_Group_Level#" cfsqltype="cf_sql_integer">,
			Discount_Growth_Item_Level 		= 	<cfqueryparam value="#Form.Discount_Growth_Item_Level#" cfsqltype="cf_sql_integer">,
			Discount_Growth_Group_Level 	= 	<cfqueryparam value="#Form.Discount_Growth_Group_Level#" cfsqltype="cf_sql_integer">,
			Program_Spending_Type   		= 	<cfqueryparam value="#Form.Program_Spending_Type#" cfsqltype="cf_sql_integer">,
			Lumpsum_Spending_Type			= 	<cfqueryparam value="#Form.Lumpsum_Spending_Type#" cfsqltype="cf_sql_integer">,
			display_Bidrequest_basesales  	=  	<cfqueryparam value="#form.display_Bidrequest_basesales#" cfsqltype="cf_sql_integer">,
			display_FixedPrice_basesales  	= 	<cfqueryparam value="#form.display_FixedPrice_basesales#" cfsqltype="cf_sql_integer">
			<cfif UpdateProduct IS 1>
				,Default_Product					=	<cfqueryparam value="#Form.Product_List#" cfsqltype="cf_sql_idstamp">
			</cfif>

				,Allow_Multi 					= <cfqueryparam value="#Form.Allow_Multi#" cfsqltype="cf_sql_integer">
				,Allow_Growth_Multi_Rate			= <cfqueryparam value="#Form.Allow_Multi#" cfsqltype="cf_sql_integer">
				,Allow_Single 					= <cfqueryparam value="#Form.Allow_Single#" cfsqltype="cf_sql_integer">
				,Allow_Stairway 					= <cfqueryparam value="#Form.Allow_Stairway#" cfsqltype="cf_sql_integer">
				,Allow_XofY	 					= <cfqueryparam value="#Form.Allow_XofY#" cfsqltype="cf_sql_integer">
				,Allow_Volume_Pool_Seperation 	= <cfqueryparam value="#Form.Allow_Volume_Pool_Seperation#" cfsqltype="cf_sql_integer">

			<cfif Form.Discount_Rebates_Group_Level eq 1 or Form.Discount_Lump_Sums_Group_Level eq 1 or Form.Discount_Growth_Group_Level eq 1 OR Form.Discount_Fixed_Group_Level eq 1>
				,Group_Deal = 1
			</cfif>
			,Discount_Fixed_Prices_Product_Message	=<cfqueryparam value="#Form.Discount_Fixed_Prices_Product_Message#" cfsqltype="cf_sql_varchar" />
			,Discount_Rebates_Product_Message = <cfqueryparam value="#Form.Discount_Rebates_Product_Message#" cfsqltype="cf_sql_varchar" />
			,Discount_Lump_Sums_Product_Message = <cfqueryparam value="#Form.Discount_Lump_Sums_Product_Message#" cfsqltype="cf_sql_varchar" />
			,Discount_Growth_Product_Message = <cfqueryparam value="#Form.Discount_Growth_Product_Message#" cfsqltype="cf_sql_varchar" />
			,Discount_Formula_Pricing_Product_Message = <cfqueryparam value="#Form.Discount_Formula_Pricing_Product_Message#" cfsqltype="cf_sql_varchar" />
			,Discount_BidRequest_Product_Message = <cfqueryparam value="#Form.Discount_BidRequest_Product_Message#" cfsqltype="cf_sql_varchar" />
			,Discount_OffInvoice_Product_Message = <cfqueryparam value="#Form.Discount_OffInvoice_Product_Message#" cfsqltype="cf_sql_varchar" />
			,MinPerfRequirementsOn = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#Form.minPerfRequirementsOn#" />
			,MaxPerfRequirementsOn = <cfqueryparam cfsqltype="CF_SQL_BIT" value="#Form.maxPerfRequirementsOn#" />
			,MinPerfRequirements = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Form.minPerfRequirements#" />
			,MaxPerfRequirements = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Form.maxPerfRequirements#" />
			,Discount_Fixed_Prices_Freight =  <cfqueryparam value="#form.Discount_Fixed_Prices_Freight#" cfsqltype="cf_sql_integer">
			,Fixed_Price_Populates_Price_List_Special = <cfqueryparam value="#form.Fixed_Price_Populates_Price_List_Special#" cfsqltype="cf_sql_integer" />
			,CurrencyDefaultOption 	= 	<cfqueryparam value="#Form.CurrencyDefaultOption#" cfsqltype="cf_sql_integer">
			,Label_Set_Default	= 	<cfqueryparam value="#Form.LabelSetDefaultOption#" cfsqltype="cf_sql_varchar">

			,Operator_Off_Invoice_Volume = <cfqueryparam value="#FORM.Operator_Off_Invoice_Volume#"cfsqltype="CF_SQL_BIT" />
			,Operator_Billback_Volume = <cfqueryparam value="#FORM.Operator_Billback_Volume#" cfsqltype="CF_SQL_BIT" />
			,Distributor_Off_Invoice_Volume = <cfqueryparam value="#FORM.Distributor_Off_Invoice_Volume#" cfsqltype="CF_SQL_BIT" />
			,Distributor_Billback_Volume = <cfqueryparam value="#FORM.Distributor_Billback_Volume#" cfsqltype="CF_SQL_BIT" />
			,Adjust_For_Credits = <cfqueryparam value="#FORM.Adjust_For_Credits#" cfsqltype="CF_SQL_BIT" />
			,Volume_Distributor_Template_GroupB_Default = <cfqueryparam value="#FORM.Volume_Distributor_Template_GroupB_Default#" cfsqltype="CF_SQL_INTEGER" />
			,Volume_Operator_Template_GroupB_Default = <cfqueryparam value="#FORM.Volume_Operator_Template_GroupB_Default#" cfsqltype="CF_SQL_INTEGER" />
			,Display_FixedPrice_Basesales_On_Approval = <cfqueryparam value="#FORM.Display_FixedPrice_Basesales_On_Approval#"cfsqltype="CF_SQL_BIT" />
			,Fixed_Rebate_Grid_Option = <cfqueryparam value="#FORM.Fixed_Rebate_Grid_Option#"cfsqltype="CF_SQL_BIT" />
			,Market_Price = <cfqueryparam value="#FORM.Market_Price#"cfsqltype="CF_SQL_BIT" />
			,Market_Price_Update_Process = <cfqueryparam value="#FORM.Market_Price_Update_Process#"cfsqltype="CF_SQL_BIT" />
			,Growth_Auto_pay =  <cfqueryparam value="#FORM.Growth_Auto_Pay#"cfsqltype="CF_SQL_BIT" />	<!--- D35731 Growth Auto Pay --->
			,Growth_Min_Purchase = <cfqueryparam value="#FORM.Growth_Min_Purchase#"cfsqltype="CF_SQL_BIT" />
			,Custom_Fixed_Price_Options = <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Custom_Fixed_Price_Options#">
			,Enable_Program_Qualifications = <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Enable_Program_Qualifications#">
			,Bonus_Field = <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Bonus_Field#">
			,Program_Qualifications_Doc_Attach_Req	= <cfqueryparam value="#Program_Qualifications_Doc_Attach_Req#" cfsqltype="cf_sql_integer">
			,Program_Qualifications_Doc_Msg = <cfqueryparam value="#left(trim(Form.Program_Qualifications_Doc_Msg),75)#" cfsqltype="cf_sql_varchar" />
			,Volume_Page_UOM_CS = <cfqueryparam value="#FORM.Volume_Page_UOM_CS#" cfsqltype="CF_SQL_INTEGER" />
			,Volume_Page_UOM_LB = <cfqueryparam value="#FORM.Volume_Page_UOM_LB#" cfsqltype="CF_SQL_INTEGER" />
			,Restrict_On_Inventory_UOM_Pound =	<cfqueryparam value="#Form.Restrict_On_Inventory_UOM_Pound#" cfsqltype="CF_SQL_BIT">
			,Restrict_On_Inventory_UOM_Case =	<cfqueryparam value="#Form.Restrict_On_Inventory_UOM_Case#" cfsqltype="CF_SQL_BIT">
			,Price_List_Type = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.price_list_type#"><!--- 71241/73454 --->
			,RFP_Process =  <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.RFP_Process#">
			,Formula_Pricing_Type =  <cfqueryparam cfsqltype="CF_SQL_INTEGER" value="#Form.Formula_Pricing_Type#">
			,Ideal_Price = <cfqueryparam cfsqltype="cf_sql_bit" value="#Form.Ideal_Price#"><!--- 114617 :: Ideal Price  --->
		WHERE 	ProgramControl_Panel_Options_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfquery name="variables.qUpdated" datasource="#application.datasource#">
	SELECT * 
	FROM Program_Control_Panel_Options
	WHERE 	ProgramControl_Panel_Options_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
</cfquery>
<cfscript>
	variables.udf = createObject( "component", "components.udf" );
	variables.udf.WriteSettingsAudit( variables.qOriginal, variables.qUpdated, "Program_Control_Panel_Options", ID, "#variables.qUpdated.Created_Type# - #variables.qUpdated.Program_Description#", "Updated_By,Date_Updated" );
</cfscript>

<!---Action is defined--->
<cfif isDefined("form.Action")>

	<!---Action is edit--->
	<cfif Form.Action IS "Edit">
		<!------ *********************** retroactiveley update old versions of the template *********************** ----->
		<!------
		Date: 03/22/2005 by Deepa Kunnath
		Here is the logic to retroactively make the changes to all versions of this template.
		Right now we are only adding few fields from the main table to this list, may be in future we need more....
		If the fields you need to add are in the main table (Program_Control_Panel_Options), just add it to the array and will be taken care of
		But if you need to do the same of a mapping table, you need to write the code for it,
			anyway please try to code in a common way so that it can be reused if we want to add more items into that list,
			but if it gets too complicated it can be done custom.
		 ----->
		<cfif Form.Active IS 1><!------ Only if the template is active it will have multiple versions ----->
			<!--- Dev Note: KAL; D15737: Make letter settings retroactive, Code changes to retroactive saving --->
			<!------ **** Update Master Table **** ----->
			<cfset MainTableFieldsToUpdate = ArrayNew(2) />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Discount_Fixed_Prices_Product_Message" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Discount_Fixed_Prices_Product_Message#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Discount_Rebates_Product_Message" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Discount_Rebates_Product_Message#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Discount_Lump_Sums_Product_Message" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Discount_Lump_Sums_Product_Message#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Discount_Growth_Product_Message" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Discount_Growth_Product_Message#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Discount_Formula_Pricing_Product_Message" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Discount_Formula_Pricing_Product_Message#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Discount_BidRequest_Product_Message" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Discount_BidRequest_Product_Message#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Discount_OffInvoice_Product_Message" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Discount_OffInvoice_Product_Message#" />
			<!--- Dev Note: Kal; 9588 --->
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Group_Programs_UOM" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Group_Programs_UOM#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Groups_UOM_1" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Groups_UOM_1#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Groups_UOM_2" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Groups_UOM_2#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Groups_UOM_3" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Groups_UOM_3#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Groups_UOM_Default" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Groups_UOM_Default#" />
      <!--- Added for 19117 Start --->
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Operator_Off_Invoice_Volume" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Operator_Off_Invoice_Volume#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Operator_Billback_Volume" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Operator_Billback_Volume#" />
      <cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Distributor_Off_Invoice_Volume" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Distributor_Off_Invoice_Volume#" />
      <cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Distributor_Billback_Volume" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Distributor_Billback_Volume#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Adjust_For_Credits" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Adjust_For_Credits#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Volume_Distributor_Template_GroupB_Default" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Volume_Distributor_Template_GroupB_Default#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Volume_Operator_Template_GroupB_Default" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Volume_Operator_Template_GroupB_Default#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Growth_Min_Purchase" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Growth_Min_Purchase#" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)+1][1] 	= "Formula_Pricing_Type" />
			<cfset MainTableFieldsToUpdate[ArrayLen(MainTableFieldsToUpdate)][2] 	= "#Formula_Pricing_Type#" />
      <!--- Added for 19117 End --->


			<cfinclude template ="rectroactive_update.cfm">
			<!------ **** Update Master Table **** ----->

		</cfif>
	</cfif>
</cfif>

<!---if product category filter is on then save for any categories that may have been selected--->
<cfif isDefined("application.returned_customer_setting.product_category_filter") and application.returned_customer_setting.product_category_filter>
	<cfset CreateObject("component", "components.products.Category.ProductCategory").saveCategoryFilters(ID, form.Category_ID) />
</cfif>

<!--- Dev Notes: D23601/Anand Rao/04-Aug-10; Margin Page, Items to Exclude --->
<cfif appSettings.getMarginItemsExclude()>
  <cfset ExcludeItemsManager    = CreateObject("component","components.settings.ExcludeItemsManager") />
  <cfset qGetActiveExcludeItems = ExcludeItemsManager.getActiveItemsExclude() />

  <cfquery name="Delete_Current_Exclues" datasource="#application.datasource#">
  	DELETE FROM Margin_Item_Exclusion_Template WHERE Program_Template_ID = <cfqueryparam value="#getTemplateParentID.First_Parent_ID#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfloop query="qGetActiveExcludeItems">
    <cfif isDefined("Form.excludeItems_#Evaluate(Margin_Item_Exclusion_ID)#")>
      <cfquery name="qInsAddItemsExcludeTemplate" datasource="#application.datasource#">
        INSERT INTO Margin_Item_Exclusion_Template
        (
          Margin_Item_Exclusion_ID,
          Program_Template_ID
        )
        VALUES
        (
           <cfqueryparam value="#qGetActiveExcludeItems.Margin_Item_Exclusion_ID#" cfsqltype="cf_sql_integer"/>,
           <cfqueryparam value="#getTemplateParentID.First_Parent_ID#" cfsqltype="cf_sql_varchar"/>
        )
      </cfquery>
    </cfif>
  </cfloop>
</cfif>
<!--- End Margin Page, Items to Exclude --->

<!---Performance Requirements--->
<cfquery name="GetPerformanceRequirements" datasource="#application.datasource#">
	DELETE FROM Program_Perf_Mapping WHERE Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">

	SELECT *
	 FROM Program_Perf_Req
	WHERE Deleted = 0
</cfquery>

<cfquery datasource="#application.datasource#">
	<cfloop query="GetPerformanceRequirements">
		<cfparam name="form.requirement_#GetPerformanceRequirements.Program_Perf_Req_ID#" default="0">
		<cfif form[ "requirement_" & GetPerformanceRequirements.Program_Perf_Req_ID ] eq "1">
			INSERT INTO Program_Perf_Mapping
						(
							Template_ID,
							Program_Perf_Req_ID,
							Program_Perf_Req_Checked
						)
				VALUES
						(
							<cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">,
							<cfqueryparam value="#GetPerformanceRequirements.Program_Perf_Req_ID#" cfsqltype="cf_sql_integer">,
												<cfqueryparam value="#form['Requirement_' & GetPerformanceRequirements.Program_Perf_Req_ID & '_Display']#" cfsqltype="cf_sql_tinyint">
						)
		</cfif>
	</cfloop>
	/* this select statement prevents an event error due no performance requirement was selected (an empty query) - do not delete it */
	SELECT 1 WHERE 1 = 0
</cfquery>

<!---Payment types--->
<cfquery name="Delete_Current_PTs" datasource="#application.datasource#">
	DELETE FROM Payment_Template_Mapping WHERE Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset useLakebaseForGetPaymentTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_type")>
<cfif useLakebaseForGetPaymentTypes>
	<cftry>
		<cfset GetPaymentTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_type", {
				"deleted" = "eq.0",
				"active" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPaymentTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPaymentTypes>
<cfquery name="GetPaymentTypes" datasource="#application.datasource#">
	SELECT distinct *
	FROM Payment_Type
	WHERE Deleted = 0
	AND Active = 1
</cfquery>
</cfif>

<cfloop query="GetPaymentTypes">
	<cfif isDefined("Form.Payment_Type_#Evaluate(Payment_Type_ID)#") AND Form['Payment_Type_#Payment_Type_ID#'] EQ 1>
		<cfquery name="InsertPaymentRecord" datasource="#application.datasource#">
		INSERT INTO Payment_Template_Mapping
		(
			Template_ID,
			Payment_Type_ID
		)
		VALUES
		(
			<cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">,
			<cfqueryparam value="#Payment_Type_ID#" cfsqltype="cf_sql_integer">
		)
		</cfquery>
	</cfif>
</cfloop>


<!--- Currency --->
<cfquery name="Delete_Current_Currencies" datasource="#application.datasource#">
	DELETE FROM Currency_Mapping WHERE Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset useLakebaseForGetCurrencies = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("currency")>
<cfif useLakebaseForGetCurrencies>
	<cftry>
		<cfset GetCurrencies = application.oLakebase.toQuery(
			application.oLakebase.selectRows("currency", {
				"deleted" = "eq.0",
				"active" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCurrencies = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCurrencies>
<cfquery name="GetCurrencies" datasource="#application.datasource#">
	SELECT distinct *
	FROM Currency
	WHERE Deleted = 0
	AND Active = 1
</cfquery>
</cfif>

<cfloop query="GetCurrencies">
	<cfif isDefined("Form.Currency_#Evaluate(Currency_ID)#")>
		<cfquery name="InsertPaymentRecord" datasource="#application.datasource#">
		INSERT INTO Currency_Mapping
		(
			Template_ID,
			Currency_ID
		)
		VALUES
		(
			<cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">,
			<cfqueryparam value="#Currency_ID#" cfsqltype="cf_sql_integer">
		)
		</cfquery>
	</cfif>
</cfloop>

<cfquery name="getTemplateGenericType" datasource="#application.datasource#">
	SELECT Generic_Type,ISNULL(EZ_Contract_Id,0) AS EZ_Contract_ID,EZButton_On,Discount_Fixed_Prices,
	Discount_Rebates,Discount_Lump_Sums,Discount_BidRequest,Discount_Growth, Retail_Planner 
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- START:: 116758: Performance Type for non-retail programs/ Anand Rao / 24-Aug-2022 --->
<cfif (getTemplateGenericType.Retail_Planner NEQ "1")>
	<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
	<cfset template = templateManager.get(ID)>
	<cfset templateProgramPlanner = templateManager.getTemplateProgramPlanner(ID) />
	<cfset FirstParentID =  	template.getFirstParentID()>
	
	<cfquery name="qDeletePerfTypes" DATASOURCE="#application.datasource#">
		UPDATE	Template_Planner_Settings_Perf_Types
		SET		Deleted = 1,
				Deleted_Date = getDate()
		WHERE	First_Parent_ID = <cfqueryparam value="#FirstParentID#" cfsqltype="cf_sql_integer">
		AND	Deleted = 0
	</cfquery>
	<!---Loop over selected entries and insert --->
	<cfloop list="#FORM.Planner_Perf_Types_ID#" index="idx">
		<cfquery name="qInsertPerfTypes" DATASOURCE="#application.datasource#">
			INSERT INTO	Template_Planner_Settings_Perf_Types
				(Planner_Perf_Types_ID, First_Parent_ID)
			VALUES
				(<cfqueryparam value="#idx#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#FirstParentID#" cfsqltype="cf_sql_integer">)
		</cfquery>
	</cfloop>
</cfif>
<!--- END:: 116758:	Performance Type for non-retail programs/ Anand Rao / 24-Aug-2022 --->

<cfif getTemplateGenericType.EZButton_On EQ 1>
<cfset discounttype_list = "0">
<cfif getTemplateGenericType.Discount_Fixed_Prices EQ 0>
	<cfset discounttype_list = listappend(discounttype_list,1,',')>
	<cfquery NAME="deletefixedproductdata" datasource="#application.datasource#">
	UPDATE Program_Fixed_Price_Product_Data
	set deleted = 1
	where Program_ID = <cfqueryparam value="#getTemplateGenericType.EZ_Contract_Id#" cfsqltype="cf_sql_integer">
	</cfquery>

	<cfquery NAME="deletefixedcomponentdata" datasource="#application.datasource#">
	UPDATE Program_Fixed_Component
	set deleted = 1
	where Program_ID = <cfqueryparam value="#getTemplateGenericType.EZ_Contract_Id#" cfsqltype="cf_sql_integer">
	</cfquery>
</cfif>
<cfif getTemplateGenericType.Discount_Rebates EQ 0>
	<cfset discounttype_list = listappend(discounttype_list,2,',')>
	<cfquery datasource="#application.datasource#">
		UPDATE 	Program_Rebates_Product_Data
		SET 	Deleted = 1
		WHERE	program_id = <cfqueryparam value="#getTemplateGenericType.EZ_Contract_Id#" cfsqltype="cf_sql_integer">
		AND		Deleted = 0
	</cfquery>
	<cfquery name="qGetCompIds" datasource="#application.datasource#">
		SELECT 	Program_Rebates_Component_ID
		FROM	Program_Rebates_Component
		WHERE	Program_ID = <cfqueryparam value="#getTemplateGenericType.EZ_Contract_Id#" cfsqltype="cf_sql_integer">
	</cfquery>
	<cfif qGetCompIds.RecordCount>

	<cfquery datasource="#application.datasource#">
		UPDATE 	Program_Rebates_Component_Data
		SET 	Deleted = 1
		WHERE	Program_Rebates_Component_ID in (#QuotedValueList(qGetCompIds.Program_Rebates_Component_ID)#)
		AND		Deleted = 0
	</cfquery>
	</cfif>
	<cfquery datasource="#application.datasource#">
		UPDATE 	Program_Rebates_Component
		SET 	Deleted = 1
		WHERE	Program_ID = <cfqueryparam value="#getTemplateGenericType.EZ_Contract_Id#" cfsqltype="cf_sql_integer">
		AND		Deleted = 0
	</cfquery>
	<cfif FILEEXISTS("#request.app_general_functions.Get_Document_Path()#\data_files\created\contracts\RebateData\#getTemplateGenericType.EZ_Contract_Id#.xml")>
		<cffile action="delete" file="#request.app_general_functions.Get_Document_Path()#\data_files\created\contracts\RebateData\#getTemplateGenericType.EZ_Contract_Id#.xml">
	</cfif>
</cfif>
<cfif getTemplateGenericType.Discount_Lump_Sums EQ 0>
	<cfset discounttype_list = listappend(discounttype_list,3,',')>
	<cfquery name="qGetLumpCompIds" datasource="#application.datasource#">
		SELECT 	Program_Lump_Sum_ID
		FROM	Program_Lump_Sums
		WHERE	Program_ID = <cfqueryparam value="#getTemplateGenericType.EZ_Contract_Id#" cfsqltype="cf_sql_integer">
	</cfquery>
	<cfif qGetLumpCompIds.RecordCount>
	<cfquery datasource="#application.datasource#">
		UPDATE 	Program_Lump_Sum_Product_Data
		SET 	Deleted = 1
		WHERE 	Program_Lump_Sum_ID in (<cfqueryparam value="#QuotedValueList(qGetLumpCompIds.Program_Lump_Sum_ID)#" cfsqltype="cf_sql_idstamp" list="true">)
		AND		Deleted = 0
	</cfquery>
	</cfif>
	<cfquery NAME="deletecomponent" datasource="#application.datasource#">
		UPDATE 	Program_Lump_Sums
		SET 	Deleted = 1
		WHERE 	Program_ID = <cfqueryparam value="#getTemplateGenericType.EZ_Contract_Id#" cfsqltype="cf_sql_integer">
	</cfquery>
</cfif>
<cfquery name="deleteproducts_discounttypesremoved" datasource="#application.datasource#">
	update contract_products
	set deleted = 1
	where contract_main_id = <cfqueryparam value="#getTemplateGenericType.EZ_Contract_Id#" cfsqltype="cf_sql_integer" />
	and product_type_id IN (<cfqueryparam value="#discounttype_list#" cfsqltype="cf_sql_integer" list="true" separator="," />)
</cfquery>

</cfif>


<cfquery datasource="#application.datasource#">
	DELETE FROM Qualification_Template_Mapping WHERE Template_ID = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">

	<cfset row_counter = 0>
	<cfloop list="#form.qualification_row_ids#" index="variables.qualification_id">
		<cfset row_counter = row_counter + 1>
		/* disabled answer is required checkbox would not be included in the form - set it to zero */
		<cfparam name="form.qualification_answer_required_#row_counter#" default="0">
		<cfparam name="form.qualification_is_included_#row_counter#" default="0">

		INSERT INTO Qualification_Template_Mapping (
				Template_ID
				,Program_Qualification_Id
				,Answer_Required
				,Display_Sequence
				,Is_Included
			)
		VALUES (
				  <cfqueryparam value = "#ID#">
				, <cfqueryparam value = "#variables.qualification_id#">
				, <cfqueryparam value = "#(form[ "qualification_answer_required_" & row_counter] neq "0" ? 1 : 0)#">
				, <cfqueryparam value = "#form[ "qualification_display_sequence_" & row_counter]#">
				, <cfqueryparam value = "#(form[ "qualification_is_included_" & row_counter] neq "0" ? 1 : 0)#">
			)
	</cfloop>
</cfquery>


<!---Redirects back to previous page if they only added a default product--->

<cfif len(trim(Form.Product_List)) GT 0>
		<cfoutput>
		<form action="secondpage.cfm" method="post" name="NextPage">
			<input type="hidden" name="Action" value="Edit">
			<input type="hidden" name="Generic_type" value="#Generic_type#">
			<input type="hidden" name="Created_Type" value="#Created_Type#">
			<input type="hidden" name="ID" value="#ID#">
			<input type="hidden" name="Active" value="#Active#">
		</form>
	</cfoutput>

	<script>
		document.NextPage.submit();
	</script>
<cfabort>
</cfif>

<!--- Not required for simple clauses --->
<cfif appSettings.getSimpleClause() eq 0>
   <cfset clauseTemplateManager = CreateObject("component", "components.clause_library.ClauseTemplateManager").init() />
   <cfset clauseTemplateManager.importRequiredClause(ID, request.AccessStructure.User_ID)>
</cfif>

</cfif>

<!------ Redirect to next page ----->
<cfset pageName = "secondpage">
<cfinclude template="Next_Page.cfm" />
