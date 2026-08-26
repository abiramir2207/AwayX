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
		
		<CFQUERY NAME="checkOverageData" DATASOURCE="#application.datasource#">
			SELECT Formula_Pricing_Commodity_Overage_Id
			FROM Formula_Pricing_Commodity_Overage
			WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#' AND
					Deleted = 0
		</CFQUERY>
		<!--- IF THERE IS OVERAGE DAT CONFIGURED RUN THE CALCULATION --->
		<CFIF checkCommOverageData.recordcount GT 0 OR checkOverageData.RecordCount GT 0>
				 <cfstoredproc procedure="Formula_Price_RFP_Calculation" datasource="#application.datasource#"> 
					<cfprocparam cfsqltype="CF_SQL_VARCHAR"  
					    		value="#Rule_ID#"> 
					</cfstoredproc>
		</CFIF>
	<CFELSE>
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
		<CFSET Rule_ID=Insert_Rule_Basic_Info.Formula_Pricing_Rule_ID>				
	</CFIF>

