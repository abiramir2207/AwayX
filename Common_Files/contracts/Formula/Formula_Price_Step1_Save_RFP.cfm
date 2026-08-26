<!------Old_Number_Of_Comms----->
<!------Formula_Price_Step1_Save.cfm----->
<!---	<CFPARAM NAME="FORM.Show_Details" 	DEFAULT="0">
	<CFIF FORM.Show_Details EQ "">
		<CFSET FORM.Show_Details = 0>
	</CFIF> --->
	<cfparam name="Form.FP_Formula_Type_ID" DEFAULT="0">
	<CFPARAM NAME="FORM.Saved" 	DEFAULT="0">
	<cfscript>
		appSettings = application.appSettingsGet;
	</cfscript> 
<!--- 	<cfdump var="#Form#">
	<cfabort> --->
	<CFIF Rule_ID NEQ "">
		<CFQUERY NAME="Save_Rule_Basic_Info" DATASOURCE="#application.datasource#">
			UPDATE 	Program_Formula_Pricing_Rules
			SET		Rule_Name	=	'#FORM.Rule_Name#',
					FP_Formula_Type_ID= #Form.FP_Formula_Type_ID#,
				<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 0>
					FP_Schedule_Option_ID = #Form.FP_Schedule_Option_ID#,
				</cfif>
					Saved = #Form.Saved#,
					Program_Fixed_Component_Id = #Form.Program_Fixed_Component_Id#,
					Program_Fixed_Component_Name_Id = #Form.Program_Fixed_Component_Name_Id#
			WHERE
					Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		</CFQUERY>
		
		<CFQUERY NAME="checkCommOverageData" DATASOURCE="#application.datasource#">
			SELECT Program_Formula_Pricing_Rule_Comm_Data_Id
			FROM Program_Formula_Pricing_Rule_Comm_Data
			WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#' AND
					Deleted = 0
		</CFQUERY>
		
		<cfset useLakebaseForcheckOverageData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_pricing_commodity_overage")>
<cfif useLakebaseForcheckOverageData>
	<cftry>
		<cfset checkOverageData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("formula_pricing_commodity_overage", {
				"program_formula_pricing_rule_id" = "eq.#Rule_ID#",
				"deleted" = "eq.0",
				"select" = "formula_pricing_commodity_overage_id"
			}), "formula_pricing_commodity_overage_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckOverageData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckOverageData>
<CFQUERY NAME="checkOverageData" DATASOURCE="#application.datasource#">
			SELECT Formula_Pricing_Commodity_Overage_Id
			FROM Formula_Pricing_Commodity_Overage
			WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#' AND
					Deleted = 0
		</CFQUERY>
</cfif>
		<!--- IF THERE IS OVERAGE DAT CONFIGURED RUN THE CALCULATION --->
		<CFIF checkCommOverageData.recordcount GT 0 OR checkOverageData.RecordCount GT 0>
				 <cfstoredproc procedure="Formula_Price_RFP_Calculation" datasource="#application.datasource#"> 
					<cfprocparam cfsqltype="CF_SQL_VARCHAR"  
					    		value="#Rule_ID#"> 
					</cfstoredproc>
		</CFIF>
	<CFELSE>
		<cfset useLakebaseForInsert_Rule_Basic_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rules")>
<cfif useLakebaseForInsert_Rule_Basic_Info>
	<cftry>
		<cfset application.oLakebase.insertRow("program_formula_pricing_rules", {
			"program_id" = "#Form.Program_Id#",
			"rule_name" = "#FORM.Rule_Name#",
			"number_of_comms" = "#Form.FP_Schedule_Option_ID#",
			"fp_schedule_option_id" = "#Form.FP_Formula_Type_ID#",
			"fp_formula_type_id" = "#FORM.Number_Of_Comms#",
			"active" = "1",
			"saved" = "#Form.Saved#",
			"program_fixed_component_id" = "#Form.Program_Fixed_Component_Id#",
			"program_fixed_component_name_id" = "#Form.Program_Fixed_Component_Name_Id#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsert_Rule_Basic_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsert_Rule_Basic_Info>
<CFQUERY NAME="Insert_Rule_Basic_Info" DATASOURCE="#application.datasource#">
			INSERT	INTO	
			Program_Formula_Pricing_Rules	
						(
						Program_Id,
						Rule_Name, 
						Number_Of_Comms, 
						FP_Schedule_Option_ID,
						FP_Formula_Type_ID,
						Active,
						Saved,
						Program_Fixed_Component_Id,
						Program_Fixed_Component_Name_Id
						)
			VALUES 		(
						#Form.Program_Id#,
						'#FORM.Rule_Name#', 
						'#Form.FP_Schedule_Option_ID#',
						'#Form.FP_Formula_Type_ID#',
						#FORM.Number_Of_Comms#, 
						1,
						#Form.Saved#,
						#Form.Program_Fixed_Component_Id#,
						#Form.Program_Fixed_Component_Name_Id#
						)
		</CFQUERY>
</cfif>
		<CFSET Rule_ID=Insert_Rule_Basic_Info.Formula_Pricing_Rule_ID>				
	</CFIF>

