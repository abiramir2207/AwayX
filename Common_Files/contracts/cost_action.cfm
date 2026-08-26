<!--
  * ==================================================================================================== 
  *  @Author: Chris Nguyen
  *    @Date: 2018-07-12 07:37:02
  * 
  * @Remarks: Cost popup posting action page for Custom_T
  *
  *
  * 
  *  
  * ==================================================================================================== 
-->

<!--- list of all editable input elements on the page --->
<cfscript>
	param name="form.action" default="";

	field_names = [
					 "cost_cogs_cs"
					,"cost_historical_adjustment_cs"
					,"cost_predicted_adjustment_cs"
					,"cost_production_adjustment_cs"
					,"del_frt_cost"
					,"del_var_warhs"
					,"fob_frt_cost"
					,"fob_warhs"
					,"fx_man_cost"
					,"var_man_cost"
				];
	
	// margin_type = 1 is CS and UOM = 1, margin_type = 3 is LB and UOM = 2, margin_type = 3 is STAT and UOM = 3
	uom  		= (form.margin_type eq "3" ? 2 : (form.margin_type eq "2" ? 3 : form.margin_type)); 
</cfscript>

	
<cfif form.action is "save">
	<cfoutput>	
	<cfquery datasource="#application.datasource#">
		<!--- scan through all possible field names --->
		<cfloop array="#field_names#" item="variables.input_name">
			<!--- save changes only when value is different --->
			<cfif structKeyExists(form, variables.input_name) and val(form[ "old_" & variables.input_name ]) neq val(form[ variables.input_name ]) >
					IF NOT EXISTS(
									SELECT * 
									FROM Contract_Product_Margin_Override
									WHERE Contract_Main_ID                = #form.contract_main_id#
										AND   BSA_Foodservice_Items_Master_ID = '#form.product_id#'
										AND   Field_Name                      = '#variables.input_name#'
										AND Deleted = 0
									)
						INSERT INTO Contract_Product_Margin_Override
									(Contract_Main_ID, BSA_Foodservice_Items_Master_ID, Field_Name, Unit_of_measure)
							VALUES	(#form.contract_main_id#, '#form.product_id#', '#variables.input_name#', #uom#)

					UPDATE Contract_Product_Margin_Override
						SET   Old_Value        = #val(form[ "old_" & variables.input_name ])#
							, New_Value        = #val(form[ variables.input_name ])#
							, Created_By       = '#request.AccessStructure.user_id#'
							, Unit_of_measure  = #uom#						
						WHERE Contract_Main_ID                  = #form.contract_main_id#
							AND BSA_Foodservice_Items_Master_ID = '#form.product_id#'
							AND Field_Name                      = '#variables.input_name#'
							AND Deleted = 0
			</cfif>
		</cfloop>
	</cfquery>
	</cfoutput>	
</cfif>

<script>
	window.close();
</script>