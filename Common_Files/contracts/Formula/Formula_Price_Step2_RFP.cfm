<CFPARAM NAME="URL.RID" 	DEFAULT="">
<CFPARAM NAME="FORM.Rule_ID" 	DEFAULT="#URL.RID#">
<CFSET Rule_ID = FORM.Rule_ID>
<CFPARAM NAME="FORM.Commodity_List" 	DEFAULT="">
<CFPARAM NAME="URL.Program_Id" 	DEFAULT="0">
<CFPARAM NAME="FORM.Program_Id" 	DEFAULT="#URL.Program_Id#">

<CFPARAM NAME="URL.Contract_Products_Id" 	DEFAULT="0">
<CFPARAM NAME="FORM.Contract_Products_Id" 	DEFAULT="#URL.Contract_Products_Id#">

<CFPARAM NAME="URL.FP_Schedule_Option_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.FP_Schedule_Option_ID" 	DEFAULT="#URL.FP_Schedule_Option_ID#">

<CFPARAM NAME="URL.FP_Formula_Type_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.FP_Formula_Type_ID" 	DEFAULT="#URL.FP_Formula_Type_ID#">
<CFPARAM NAME="FORM.Saved" 	DEFAULT="0">

<CFPARAM NAME="URL.Program_Fixed_Component_Id" 	DEFAULT="0">
<CFPARAM NAME="FORM.Program_Fixed_Component_Id" 	DEFAULT="#URL.Program_Fixed_Component_Id#">

<CFPARAM NAME="URL.Program_Fixed_Component_Name_Id" 	DEFAULT="0">
<CFPARAM NAME="FORM.Program_Fixed_Component_Name_Id" 	DEFAULT="#URL.Program_Fixed_Component_Name_Id#">

<CFIF FORM.Rule_ID NEQ "">
	<CFSET FORMULA_PAGE_NAME="5">
<CFELSE>
	<CFSET FORMULA_PAGE_NAME="3">
</CFIF>

<CFIF FORM.Program_Id EQ 0 AND len(FORM.Rule_ID) LT 30>
	BAD PROGRAM DATA
	<cfdump var="#FORM#">
	<cfabort>
</CFIF><!--- <cfdump var="#FORM#">
<cfdump var="#url#"> --->
<!---
<cfmodule template="/customTags/layout.cfm"
              layoutID = "formulaPricing"
              formula_page_name = #FORMULA_PAGE_NAME#
              selectedIndex = "2" >
--->
<!------Original_Rule_Name
Original_Comm_Count----->

<!----- From Step1 - Rule Name Edit alone ----->
<!------
<CFIF Rule_ID NEQ "" AND IsDefined("FORM.Old_Number_Of_Comms")>
	<!---- there was # of comms ------>
	<CFIF FORM.Old_Number_Of_Comms NEQ "">
		<!---- # of comms same ----->
		<CFIF FORM.Old_Number_Of_Comms EQ FORM.Number_Of_Comms>
			<CFINCLUDE TEMPLATE="Formula_Price_Step1_Save.cfm">
			<CFLOCATION ADDTOKEN="No" URL="Formula_Price_Display.cfm?RID=#Rule_ID#">
		</CFIF>
	</CFIF>
</CFIF>
----->
<cfscript>
		oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
		oFormula.saveProgramFormula(#Form.Program_Id#, ListLen(Form.Commodity_List),#Rule_ID#);
</cfscript> 
<CFIF IsDefined("FORM.From_Step_1")>
	<!---- there was # of comms ------>
	<CFSET Step_1_Only = true>
	<CFIF ListLen(FORM.Old_Commodity_List) NEQ ListLen(Form.Commodity_List)>
		<CFSET Step_1_Only = false>
	<CFELSE>
		<CFLOOP LIST="#FORM.Old_Commodity_List#" INDEX="Old_Comm">
			<CFIF NOT ListFindNoCase(Form.Commodity_List, Old_Comm, ",")>
				<CFSET Step_1_Only = false>
				<CFBREAK>
			</CFIF>
		</CFLOOP>
	</CFIF>
	<CFIF Step_1_Only>
		<CFINCLUDE TEMPLATE="Formula_Price_Step1_Save_RFP.cfm">
		<CFLOCATION ADDTOKEN="No" URL="Formula_Display_RFP.cfm?Formula_ID=#Rule_ID#&Program_Id=#Form.Program_Id#&Contract_Products_Id=#Form.Contract_Products_Id#">
	</CFIF>
</CFIF>

<CFQUERY NAME="getCommData" datasource="#application.datasource#">
	SELECT 	Commodities_Exchange_Detail.Exchange_Detail_ID, Commodities_Exchange_Detail.Exchange_Detail_Name,
			Commodities_Symbol.Symbol, Commodities_Symbol.Commodities_Symbol_ID ,Commodities_Symbol.Symbol_Description,
			Program_Formula_Pricing_Rule_Comm_Data.Exchange, Program_Formula_Pricing_Rule_Comm_Data.Symbol,
			Program_Formula_Pricing_Rule_Comm_Data.Point_In_Time, Program_Formula_Pricing_Rule_Comm_Data.Point_In_Time_UOM,
			Program_Formula_Pricing_Rule_Comm_Data.Sample_Size, Program_Formula_Pricing_Rule_Comm_Data.Sample_Size_UOM,
			ISNULL(Program_Formula_Pricing_Rule_Comm_Data.Weight,1.00) as weight,
			 Program_Formula_Pricing_Rule_Comm_Data.Program_Formula_Pricing_Rule_Comm_Data_ID,
			Program_Formula_Pricing_Rule_Comm_Data.FP_Formula_Type_ID
	FROM 	Commodities_Symbol
			INNER JOIN	Commodities_Exchange_Detail
			ON
			Commodities_Exchange_Detail.Exchange_Detail_ID = Commodities_Symbol.Exchange_Detail_ID
			LEFT JOIN Program_Formula_Pricing_Rule_Comm_Data
			ON
			Program_Formula_Pricing_Rule_Comm_Data.Commodities_Symbol_id = Commodities_Symbol.Commodities_Symbol_id
			<CFIF Trim(Rule_ID) NEQ "">
			AND Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			<CFELSE>
			AND 1=2
			</CFIF>
			AND Program_Formula_Pricing_Rule_Comm_Data.Deleted = 0
			AND Program_Formula_Pricing_Rule_Comm_Data.Active = 1
	WHERE
			1=1
			--AND Commodities_Exchange_Detail.Active = 1
			<CFIF FORM.Commodity_list NEQ "">
			AND Commodities_Symbol.Commodities_Symbol_id IN (#ListQualify(FORM.Commodity_list, "'", ",")#)
			<CFELSEIF Trim(Rule_ID) NEQ "">
			AND Program_Formula_Pricing_Rule_Comm_Data.Program_Formula_Pricing_Rule_Comm_Data_ID IS NOT NULL
			<CFELSE>
			AND 1=2
			</CFIF>

	ORDER BY COMM_COUNT
</CFQUERY>
<CFSET Form.Number_Of_Comms = getCommData.RecordCount>

<CFIF Trim(Rule_ID) NEQ "">
	<CFIF NOT isDefined("Form.Number_Of_Comms")>
		<cfset useLakebaseForGetNewRule = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("formula_pricing_rule")>
		<cfif useLakebaseForGetNewRule>
			<cftry>
				<cfset getNewRule = application.oLakebase.toQuery(
					application.oLakebase.selectRows("formula_pricing_rule", { "formula_pricing_rule_id" = "eq.#Rule_ID#", "select" = "number_of_comms" })
				)>
				<cfcatch type="any">
					<cfset useLakebaseForGetNewRule = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetNewRule>
			<CFQUERY NAME="getNewRule" datasource="#application.datasource#">
				SELECT Number_Of_Comms
				FROM Formula_Pricing_Rule
				WHERE
					Formula_Pricing_Rule_ID = '#Rule_ID#'
			</CFQUERY>
		</cfif>
		<CFIF getNewRule.recordCount GT 0>
			<CFSET Number_Of_Comms=getNewRule.Number_Of_Comms>
		</CFIF>
	<CFELSE>
		<CFSET Number_Of_Comms=Form.Number_Of_Comms>
	</CFIF>

	<cfset useLakebaseForgetOverageData_Independent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_overage")>
<cfif useLakebaseForgetOverageData_Independent>
	<cftry>
		<cfset getOverageData_Independent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_rule_overage", {
				"program_formula_pricing_rule_id" = "eq.#Rule_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"calc_type" = "eq.1",
				"order" = "overage_index.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetOverageData_Independent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetOverageData_Independent>
<CFQUERY NAME="getOverageData_Independent" datasource="#application.datasource#">
		SELECT *
		FROM Program_Formula_Pricing_Rule_Overage
		WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND Deleted = 0
		AND Active = 1
		AND Calc_Type = 1<!------ independent ---->
		Order By Overage_Index
	</CFQUERY>
</cfif>
	<CFLOOP QUERY="getOverageData_Independent" endrow="4">
		<CFSET i = Overage_Index>
		<CFSET "INDEPENDENT_DESC_CALC#i#_1" 				= Description>
		<CFSET "independent_amount_calc#i#_1" 				= Amount>
		<CFSET "independent_amount_uom#i#_1" 				= UOM>
	</CFLOOP>

	<cfset useLakebaseForgetOverageData_compounded = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_rule_overage")>
<cfif useLakebaseForgetOverageData_compounded>
	<cftry>
		<cfset getOverageData_compounded = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_rule_overage", {
				"program_formula_pricing_rule_id" = "eq.#Rule_ID#",
				"deleted" = "eq.0",
				"active" = "eq.1",
				"calc_type" = "eq.2",
				"order" = "overage_index.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetOverageData_compounded = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetOverageData_compounded>
<CFQUERY NAME="getOverageData_compounded" datasource="#application.datasource#">
		SELECT *
		FROM Program_Formula_Pricing_Rule_Overage
		WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND Deleted = 0
		AND Active = 1
		AND Calc_Type = 2<!------ compounded ---->
		Order By Overage_Index
	</CFQUERY>
</cfif>
	<CFLOOP QUERY="getOverageData_compounded" endrow="4">
		<CFSET i = Overage_Index>
		<CFSET "compounded_DESC_CALC#i#_1" 				= Description>
		<CFSET "compounded_amount_calc#i#_1" 				= Amount>
		<CFSET "compounded_amount_uom#i#_1" 				= UOM>
	</CFLOOP>
<CFELSE>
	<CFSET getOverageData_Independent = QueryNew("")>
	<CFSET getOverageData_compounded = QueryNew("")>
	<!------<CFSET getCommData = QueryNew("")>----->
</CFIF>


<CFSET StartIndex = getOverageData_Independent.recordcount+1>
<CFLOOP INDEX="i" FROM="#StartIndex#" TO="4" STEP="1">
	<CFSET "INDEPENDENT_DESC_CALC#i#_1" 				= "">
	<CFSET "independent_amount_calc#i#_1" 				= "">
	<CFSET "independent_amount_uom#i#_1" 				= "$">
</CFLOOP>
<CFSET StartIndex = getOverageData_compounded.recordcount+1>
<CFLOOP INDEX="i" FROM="#StartIndex#" TO="4" STEP="1">
	<CFSET "compounded_DESC_CALC#i#_1" 				= "">
	<CFSET "compounded_amount_calc#i#_1" 				= "">
	<CFSET "compounded_amount_uom#i#_1" 				= "$">
</CFLOOP>


	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Formula Pricing List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFQUERY NAME="Get_All_Commodity_Overage" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Formula_Pricing_Commodity_Overage
	WHERE
			<CFIF Rule_ID NEQ "">
			Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			<CFELSE>
			1=2
			</CFIF>
			AND DELETED = 0
</CFQUERY>

<FORM ACTION="Formula_Price_Step2_action_RFP.cfm" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;">
	<cfoutput>
		<INPUT TYPE="Hidden" NAME="Program_Id" VALUE="#Form.Program_Id#">
		<INPUT TYPE="Hidden" NAME="saved" VALUE="#Form.saved#">
		<INPUT TYPE="hidden" NAME="Contract_Products_Id" VALUE="#Form.Contract_Products_Id#">
    </cfoutput>
<!------<CFLOOP INDEX="i" FROM="1" TO="#number_of_comms#" STEP="1">----->
<CFSET i = 0>
<cfscript>
	appSettings = application.appSettingsGet;
	oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
	qTypes = oFormula.getFormulaTypes();
</cfscript>
<CFLOOP QUERY="getCommData">
<CFSET i = i + 1>
<FIELDSET STYLE="padding:5px; width: 750px; border: 1px solid Silver;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Commodity <CFOUTPUT>#i# of #number_of_comms#</CFOUTPUT></LEGEND>
	<CFIF getCommData.recordcount GT 0 AND symbol NEQ "">
		<TABLE BORDER="0" WIDTH="90%">
			<CFOUTPUT>
			<TR>
				<TD ALIGN="right" width='125'><B>Exchange:</B></TD>
				<TD  STYLE="color: red;" VALIGN="bottom"><B>#Exchange_Detail_Name#</B></TD>
				<TD WIDTH="25%">&nbsp;</TD>
			</TR>
			<TR>
				<TD ALIGN="right"><B>Commodity:</B></TD>
				<TD STYLE="color: red;" VALIGN="bottom"><B>#Symbol_Description#</B></TD>
				<TD WIDTH="25%">&nbsp;</TD>
			</TR>
				<TR VALIGN="top">
					<TD ALIGN="right" width='125'><B>Type:</B></TD>
					<TD VALIGN="top">
						<SELECT NAME="FP_Formula_Type_ID_#i#">
							<cfloop query="qTypes">
								<cfset s = "">
								<cfif getCommData.FP_Formula_Type_ID eq qTypes.FP_Formula_Type_ID> <cfset s = "selected"></cfif>
								<OPTION VALUE="#qTypes.FP_Formula_Type_ID#" #s#>#qTypes.Formula_Type_Description#</OPTION>
							</cfloop>
						</SELECT>
					</TD>
					<TD WIDTH="50%">&nbsp;</TD>
				</TR>
			<CFIF FindNoCase('energy',Exchange_Detail_Name) NEQ 0 OR FindNoCase('power',Exchange_Detail_Name) NEQ 0>
			<TR>
				<TD ALIGN="right" width='125'><B>Energy Converter:</B></TD>
				<TD VALIGN="top"><INPUT TYPE="text" NAME="Comm_weight_#i#" VALUE="#weight#" SIZE="11" ></TD>
				<TD WIDTH="25%">&nbsp;</TD>
			</TR>
			<CFELSE>
				<INPUT TYPE="hidden" NAME="Comm_weight_#i#" VALUE="1" >
			</CFIF>

			</CFOUTPUT>
		</TABLE>
	</CFIF>

	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Exchange_#i#" VALUE="#Exchange_Detail_ID#">
	<INPUT TYPE="Hidden" NAME="Commodity_#i#" VALUE="#Symbol#">
	<INPUT TYPE="Hidden" NAME="Commodities_Symbol_ID_#i#" VALUE="#Commodities_Symbol_ID#">
	</CFOUTPUT>
</FIELDSET>
</CFLOOP>

<CFOUTPUT>
	<CFIF getCommData.recordcount GT 0>
		<CFSET FORM.Update = 1>
	<CFELSE>
		<CFSET FORM.Update = 0>
	</CFIF>
	<INPUT TYPE="hidden" NAME="Program_Formula_Pricing_Rule_ID" ID="Program_Formula_Pricing_Rule_ID" VALUE="#Rule_ID#">
	<INPUT TYPE="hidden" NAME="Number_Of_Comms" ID="Number_Of_Comms" VALUE="#Number_Of_Comms#">
	<INPUT TYPE="hidden" NAME="FP_Schedule_Option_ID" ID="FP_Schedule_Option_ID" VALUE="#FORM.FP_Schedule_Option_ID#">
	<INPUT TYPE="hidden" NAME="PROGRAM_FIXED_COMPONENT_ID" ID="PROGRAM_FIXED_COMPONENT_ID" VALUE="#FORM.PROGRAM_FIXED_COMPONENT_ID#">
	<INPUT TYPE="hidden" NAME="PROGRAM_FIXED_COMPONENT_NAME_ID" ID="PROGRAM_FIXED_COMPONENT_NAME_ID" VALUE="#FORM.PROGRAM_FIXED_COMPONENT_NAME_ID#">
	<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 0>
		<INPUT TYPE="hidden" NAME="FP_Formula_Type_ID" ID="FP_Formula_Type_ID" VALUE="#FORM.FP_Formula_Type_ID#"/>
	</cfif>
	<CFIF IsDefined("FORM.Rule_Name")>
		<INPUT TYPE="hidden" NAME="Rule_Name" ID="Rule_Name" VALUE="#FORM.Rule_Name#">
<!---		<CFPARAM NAME="FORM.Show_Details" 	DEFAULT="0">
		<INPUT TYPE="hidden" NAME="Show_Details" ID="Show_Details" VALUE="#FORM.Show_Details#">--->
	</CFIF>
</CFOUTPUT>

<BR>

</FORM>
<BR><BR>
<CF_button
	button_name		=	""
	button_caption	=	"continue"
	button_action	=	"submitForm();"
	button_type		=	"javascript_link"
	button_width	=	"75"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
>

<cf_MessageWindow>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script>
	function validateData() {
		ErrorCount = 0;
		TotalWeight = 0;
		<cfoutput>
		<CFLOOP INDEX="i" FROM="1" TO="#number_of_comms#" STEP="1">
			
			/*
			if(document.all.Comm_weight_#i#.value.length != 0){
				TotalWeight = TotalWeight + parseInt(document.all.Comm_weight_#i#.value);
			}
			*/
			
			if(isNaN(document.all.Comm_weight_#i#.value) || document.all.Comm_weight_#i#.value.length == 0){
				ErrorCount++
				queueMessage("The current commodity weight of " + document.all.Comm_weight_#i#.value + "% must be numeric", document.all.weight_#i#);
			}
			else {
				clearQueue(document.all.weight_#i#);
			}
	
		</CFLOOP>
		</cfoutput>

	// D34480:Commodity Values greater than 100
	/*	if(TotalWeight != 100){
			ErrorCount++
			queueMessage("The current commodity weight sum of " + TotalWeight + "% must equal 100%", document.all.weight_1);
		}
		else {
			clearQueue(document.all.weight_1);
		} 
	*/

		if(ErrorCount == 0){
			return true;
		}
		else{
			showMessageWindow()
			return false;
		}
	}


	function submitForm(){
		if(validateData()) {
			document.all.MyForm.submit();
		}

	}
</script>
<!---</cfmodule>--->