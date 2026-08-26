<cfset useLakebaseForgetAllSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_settings")>
<cfif useLakebaseForgetAllSettings>
	<cftry>
		<cfset getAllSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAllSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAllSettings>
<cfquery name="getAllSettings" datasource="#application.datasource#">
	SELECT * 
	FROM Customer_Settings
</cfquery>
</cfif>

<cfscript>
	setting_struct = [
											["Distributor_Label", "distributor_label_singular"]
	                  , ["Distributor_Label_Plural", "distributor_label_plural"]
	                  , ["Broker_Label", "broker_label_singular"]
	                  , ["broker_label_plural", "broker_label_plural"]
	                  , ["market_label_singular", "market_label_singular"]
	                  , ["market_label_plural", "market_label_plural"]
	                  , ["company_name", "company_name"]
	                  , ["confidentiality_switch", "confidentiality_switch"]
	                  , ["confidentiality_content", "confidentiality_content"]
	                  , ["upc_switch", "upc_switch"]
	                  , ["upc_search_switch", "upc_search_switch"]
	                  , ["Line_Business_Label", "lob_label_singular"]
	                  , ["Line_Business_Label_Plural", "lob_label_plural"]
	                  , ["Line_Business_Search_Switch", "lob_search_switch"]
	                  , ["buying_group_label_singular", "buying_group_label_singular"]
	                  , ["buying_group_label_plural", "buying_group_label_plural"]
	                  , ["FamilyName_Label", "family_name_label_singular"]
	                  , ["FamilyName_Label_Plural", "Family_Name_Label_Plural"]
	                  , ["zone_label", "zone_label_singular"]
	                  , ["Zone_Label_Plural", "Zone_Label_Plural"]
	                  , ["Region_Label", "region_label_singular"]
	                  , ["Region_Label_Plural", "region_label_plural"]
	                  , ["q_brand_label_singular", "q_brand_label_singular"]
	                  , ["q_brand_label_plural", "q_brand_label_plural"]
	                  , ["type_group_label_singular", "type_group_label_singular"]
	                  , ["type_group_label_plural", "type_group_label_plural"]
	                  , ["type_group_show_column", "type_group_show_column"]
	                  , ["type_code_show_column", "type_code_show_column"]
	                  , ["type_code_label_singular", "type_code_label_singular"]
	                  , ["type_code_label_plural", "type_code_label_plural"]
	                  , ["operator_label", "operator_label_singular"]
	                  , ["operator_label_plural", "operator_label_plural"]
	                  , ["ProfileTitle_FS1", "ProfileTitle_FS1"]
	                  , ["ProfileTitle_FS2", "ProfileTitle_FS2"]
	                  , ["ProfileTitle_HA1", "ProfileTitle_HA1"]
	                  , ["ProfileTitle_HA2", "ProfileTitle_HA2"]
	                  , ["ProfileTitle_HQ", "ProfileTitle_HQ"]
	                  , ["ProfileTitle_Broker", "ProfileTitle_Broker"]
	                  , ["Company_Logo", "Company_Logo"]
	                  , ["qry_type_group", "qry_type_group_syntax"]
	                  , ["show_PDA", "show_PDA"]
	                  , ["qry_product_search", "qry_product_search_location"]
	                  , ["show_delivered", "show_delivered"]
	                  , ["qry_product_detail_popup", "qry_product_detail_popup"]
	                  , ["qry_product_price_list_detail", "qry_product_price_list_detail"]
	                  , ["qry_product_price_list_detail_special", "qry_product_price_list_detail_special"]
	                  , ["show_product_price_list_detail_special", "show_product_price_list_detail_special"]
	                  , ["allow_MA_to_more_than_one_broker", "allow_MA_to_more_than_one_broker"]
	                  , ["qry_q_brand_list", "qry_q_brand_list"]
                    , ["qry_q_brand_report_join_clause", "qry_q_brand_report_join_clause"]
                    , ["show_dataintegration", "show_dataintegration"]
                    , ["approval_group_count", "approval_group_count"]
                    , ["db_name", "db_name"]
                    , ["Line_Business_Default", "Line_Business_Default"]
                    , ["Category_List", "Category_List"]
                    , ["Program_Start_Date", "Program_Start_Date"]
                    , ["Payby_awayX", "Payby_awayX"]
                    , ["qry_customer_name_font_start", "qry_customer_name_font_start"]
                    , ["tree_access_zone", "tree_access_zone"]
                    , ["tree_access_region", "tree_access_region"]
                    , ["tree_access_market", "tree_access_market"]
                    , ["tree_access_broker", "tree_access_broker"]
                    , ["tree_access_distributor", "tree_access_distributor"]
                    , ["approval_criteria_groups_table", "approval_criteria_groups_table"]
                    , ["approval_criteria_table", "approval_criteria_table"]
                    , ["approval_criteria_table_id", "approval_criteria_table_id"]
                    , ["approval_on_type_code", "approval_on_type_code"]
                    , ["approval_on_type_group", "approval_on_type_group"]
                    , ["customer_keyword", "customer_keyword"]
                    , ["shared_invoice", "shared_invoice"]
                    , ["invoice_order_quantity", "invoice_order_quantity"]
                    , ["Permit_Ship_Date", "Permit_Ship_Date"]
                    , ["Trade_Label", "Trade_Label"]
                    , ["standard_pricelist", "standard_pricelist"]
                    , ["business_segments_on", "business_segments_on"]
                    , ["external_id_on", "external_id_on"]
                    , ["Show_BB_Payment_GLCode", "Show_BB_Payment_GLCode"]
                    , ["discount_identifier_on", "discount_identifier_on"]
                    , ["reference_number_label", "reference_number_label"]
                    , ["reference_number_editable", "reference_number_editable"]
                    , ["reference_number_2_label", "reference_number_2_label"]
                    , ["reference_number_2_editable", "reference_number_2_editable"]
                    , ["display_legacy_id", "display_legacy_id"]
                    , ["display_bid_id", "display_bid_id"]
                    , ["display_generic_type", "display_generic_type"]
                    , ["show_news", "show_news"]
                    , ["show_XM", "show_XM"]
                    , ["Show_Billback_Payment_Tab", "Show_Billback_Payment_Tab"]
                    , ["Responsible_Person", "Responsible_Person"]
                    , ["bid_id_editable", "bid_id_editable"]
                    , ["lumpsum_product_mandatory", "lumpsum_product_mandatory"]
                    , ["use_product_q_brand", "use_product_q_brand"]
                    , ["check_duplicate_program", "check_duplicate_program"]
                    , ["DD_Assignment_Based_On_Customer", "DD_Assignment_Based_On_Customer"]
                    , ["Upload_GL_Code", "Upload_GL_Code"]
                    , ["DD_Show_Operator_For_RC_Of_Accrual", "DD_Show_Operator_For_RC_Of_Accrual"]
                    , ["DD_Show_IsTrade_Box_and_Associate_a_Program", "DD_Show_IsTrade_Box_and_Associate_a_Program"]
                    , ["Show_Fund_Settings", "Show_Fund_Settings"]
                    , ["Group_Deals", "Group_Deals"]
                    , ["Shard_Ship_To_Label", "Shard_Ship_To_Label"]
                    , ["Customer_Id_Label", "Customer_Id_Label"]
                    , ["Upload_Billback", "Upload_Billback"]
                    , ["BillTo_Label", "BillTo_Label"]
                    , ["UPC_Label", "UPC_Label"]
                    , ["ITEM_Label", "ITEM_Label"]
                    , ["Legacy_Ship_To_Label", "Legacy_Ship_To_Label"]
                    , ["Operator_Legacy_Id_label", "Operator_Legacy_Id_label"]
                    , ["Show_Pay_Multi_BB_Link", "Show_Pay_Multi_BB_Link"]
                    , ["Accounting_Specialist", "Accounting_Specialist"]
                    , ["Program_Number_Label", "Program_Number_Label"]
                    , ["Program_Quantity_Label", "Program_Quantity_Label"]
                    , ["DD_Allow_Trade_Non_Trade_Type", "DD_Allow_Trade_Non_Trade_Type"]
                    , ["Product_Category_Filter", "Product_Category_Filter"]
                    , ["Operator_Legacy_Id_On", "Operator_Legacy_Id_On"]
                    , ["DD_Show_Rebill", "DD_Show_Rebill"]
                    , ["DD_Show_Distributor", "DD_Show_Distributor"]
                    , ["Billback_Payee_Label", "Billback_Payee_Label"]
                    , ["BB_PC_GL_reason_codes_on", "BB_PC_GL_reason_codes_on"]
                    , ["Distributor_Label_Default", "Distributor_Label_Default"]
                    , ["Total_Volume_label", "Total_Volume_label"]
                   ];
</cfscript>
                   
<cfset useLakebaseForgetGroupLabels = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("group_labels")>
<cfif useLakebaseForgetGroupLabels>
	<cftry>
		<cfset getGroupLabels = application.oLakebase.toQuery(
			application.oLakebase.selectRows("group_labels", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGroupLabels = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGroupLabels>
<cfquery name="getGroupLabels" datasource="#application.datasource#">
	SELECT *
	FROM Group_Labels
</cfquery>
</cfif>

<cfloop index="x" from="1" to="#getGroupLabels.approval_group_count#" step="1">
	<cfset numCount = 3 - len(x)>
	<CFSET labelIndex = "">
	<cfloop index="z" from="1" to="#numCount#" step="1">
		<cfset labelIndex = labelIndex & "0">
	</cfloop>
	<cfset labelIndex = labelIndex & x>
	<cfset arrayAppend ( setting_struct, [ "Approval_group_count_#labelIndex#_Label", "Approval_group_count_#labelIndex#_Label" ] )>
</cfloop>

<cfquery name="Get_Margin_Group_Profile_Approval_Margins" datasource="#application.datasource#">
	select max(Group_ID) as max_group_id
	from Margin_Group_Profile_Approval_Margins
</cfquery>

<cfif  len(trim(getGroupLabels.approval_group_count)) EQ 0 OR len(trim(Get_Margin_Group_Profile_Approval_Margins.max_group_id)) EQ 0>
	<cfset theGroupCountDiff = 0>
<cfelse>
	<cfset theGroupCountDiff = getGroupLabels.approval_group_count - Get_Margin_Group_Profile_Approval_Margins.max_group_id>
</cfif>


<!--- delete old groups --->
<cfif theGroupCountDiff LT 0>
	<cfquery name="deleteOldGroups" datasource="#application.datasource#">
		DELETE FROM Margin_Group_Profile_Approval_Margins
		WHERE Group_ID > #getGroupLabels.approval_group_count#
	</cfquery>

	<!--- delete product associtation with these unused groups  --->
	<cfquery name="deleteGrouping" datasource="#application.datasource#">
		DELETE
		FROM #application.returned_customer_setting.approval_criteria_groups_table#
		WHERE Margin_Group_ID > #getGroupLabels.approval_group_count#
	</cfquery>
</cfif>


<cfset Get_Profile_Settings = CreateObject("component", "components.settings.profiles.profile").getAllProfiles()>
<!--- add new groups --->
<cfif theGroupCountDiff NEQ 0>
	<cfset fromValue = Get_Margin_Group_Profile_Approval_Margins.max_group_id + 1>
	<cfloop index="x" from="#fromValue#" to="#getGroupLabels.approval_group_count#" step="1">
		<cfloop query="Get_Profile_Settings">
		<cfset n = Get_Profile_Settings.Profiles_ID>
			<cfquery name="saveNewGroups" datasource="#application.datasource#">
				INSERT INTO Margin_Group_Profile_Approval_Margins
				(Group_ID, Profile_ID)
				VALUES
				(#x#,#n#)
			</cfquery>
		</cfloop>
	</cfloop>
</cfif>

<cfset application_include_content = "<cfset application.returned_customer_setting.customer_setting_error_string = 'Default Label'>#chr(13)#">
<cfset query_count = 1>
<cfset opt_var_struct = "application.returned_customer_setting.">

<cfset datafilelocation = "settings\customer_settings\Memory_Data\Data">

<cfloop index="a" from="1" to="#arraylen(setting_struct)#" step="1">
	<cfset variable_column_name = lcase(setting_struct[a][1])>
	<cfset return_variable_name = lcase(setting_struct[a][2])>
	
	<cfloop index="b" list="#lcase(getAllSettings.columnlist)#">
		<cfset query_column_name = lcase(b)>
		<cfset setting_value = getAllSettings[query_column_name]>
		<cfif query_column_name EQ variable_column_name>
			<cfif left(return_variable_name,4) EQ "qry_">
				<cfset file_path = "\#datafilelocation#\query_"&query_count&".cfm">
				<cffile action="WRITE" file="#Application.Doc_Path#\data_files\created\#file_path#" output="<cfoutput>#setting_value#</cfoutput>" addnewline="Yes">
				<cfset setting_value = file_path>
				<cfset query_count = query_count + 1>
			</cfif>
			<CFSET application_include_content = application_include_content & "<cfset #opt_var_struct##return_variable_name# = ""#setting_value#"">#chr(13)#">
		</cfif>
	</cfloop>
	
	<cfloop index="b" list="#lcase(getGroupLabels.columnlist)#">
		<cfset query_column_name = lcase(b)>
		<cfset setting_value = getGroupLabels[query_column_name]>
		<cfif query_column_name EQ variable_column_name>
			<CFSET application_include_content = application_include_content & "<cfset #opt_var_struct##return_variable_name# = ""#setting_value#"">#chr(13)#">
		</cfif>
	</cfloop>
	
</cfloop>

<cffile action="WRITE" file="#Application.Doc_Path#\data_files\created\#datafilelocation#\application_include.cfm" output="#application_include_content#" addnewline="Yes">

<cfinclude template="#Application.Doc_Mapping#/data_files/created/#datafilelocation#/application_include.cfm" />
