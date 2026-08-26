<CFPARAM NAME="URL.RID" 	DEFAULT="">
<CFPARAM NAME="FORM.Rule_ID" 	DEFAULT="#URL.RID#">
<CFSET Rule_ID = FORM.Rule_ID>
<CFPARAM NAME="FORM.Commodity_List" 	DEFAULT="">
<CFPARAM NAME="URL.Program_Id" 	DEFAULT="0">
<CFPARAM NAME="FORM.Program_Id" 	DEFAULT="#URL.Program_Id#">

<CFPARAM NAME="URL.FP_Schedule_Option_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.FP_Schedule_Option_ID" 	DEFAULT="#URL.FP_Schedule_Option_ID#">

<CFPARAM NAME="URL.FP_Formula_Type_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.FP_Formula_Type_ID" 	DEFAULT="#URL.FP_Formula_Type_ID#">
<CFPARAM NAME="FORM.Saved" 	DEFAULT="0">
<CFPARAM NAME="FORM.Comm_Count" 	DEFAULT="4">
<CFPARAM NAME="form.Program_Fixed_Component_ID_Component_Name_ID" 	DEFAULT="">
<CFPARAM NAME="form.Contract_Products_Id" 	DEFAULT="0">


<CFIF FORM.Rule_ID NEQ "">
	<CFSET FORMULA_PAGE_NAME="5">
<CFELSE>
	<CFSET FORMULA_PAGE_NAME="3">
</CFIF>

<CFIF FORM.Program_Id EQ 0 AND len(FORM.Rule_ID) LT 30>
	BAD PROGRAM DATA
	<cfdump var="#FORM#">
	<cfabort>
</CFIF>

<cf_include files="/common_Files/jQuery.cfm, /styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css, /script/javascript/ajax_js/jqueryui-1.8.10.min.js, /script/javascript/numeric/jquery.numeric.min.js">
<cfscript>
		compId = "";
		compNameId = "";
		if (trim(form.Program_Fixed_Component_ID_Component_Name_ID) neq ""){
			compId = ListGetAt(form.Program_Fixed_Component_ID_Component_Name_ID,2, "_");
			compNameId = ListGetAt(form.Program_Fixed_Component_ID_Component_Name_ID,1, "_");
		}
		oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
		oFormula.saveProgramFormula(#Form.Program_Id#, ListLen(Form.Commodity_List),#Rule_ID#, #form.Contract_Products_Id#, compId, compNameId);
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
		<CFINCLUDE TEMPLATE="Formula_Price_Step1_Save.cfm">
		<CFLOCATION ADDTOKEN="No" URL="Formula_Display.cfm?Formula_ID=#Rule_ID#&Program_Id=#Form.Program_Id#">
	</CFIF>
</CFIF>

<cfquery NAME="getCommData" datasource="#application.datasource#">
	SELECT 	Commodities_Exchange_Detail.Exchange_Detail_ID, Commodities_Exchange_Detail.Exchange_Detail_Name,
			Commodities_Symbol.Symbol, Commodities_Symbol.Commodities_Symbol_ID ,Commodities_Symbol.Symbol_Description,
			Program_Formula_Pricing_Rule_Comm_Data.Exchange, Program_Formula_Pricing_Rule_Comm_Data.Symbol,
			Program_Formula_Pricing_Rule_Comm_Data.Point_In_Time, Program_Formula_Pricing_Rule_Comm_Data.Point_In_Time_UOM,
			Program_Formula_Pricing_Rule_Comm_Data.Sample_Size, Program_Formula_Pricing_Rule_Comm_Data.Sample_Size_UOM,
			ISNULL(Program_Formula_Pricing_Rule_Comm_Data.Weight,100) as weight,
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
</cfquery>
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
			<cfquery NAME="getNewRule" datasource="#application.datasource#">
				SELECT Number_Of_Comms
				FROM Formula_Pricing_Rule
				WHERE
					Formula_Pricing_Rule_ID = '#Rule_ID#'
			</cfquery>
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
<cfquery NAME="getOverageData_Independent" datasource="#application.datasource#">
		SELECT *
		FROM Program_Formula_Pricing_Rule_Overage
		WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND Deleted = 0
		AND Active = 1
		AND Calc_Type = 1<!------ independent ---->
		Order By Overage_Index
	</cfquery>
</cfif>
	<CFLOOP QUERY="getOverageData_Independent" endrow="#getOverageData_Independent.RecordCount#">
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
<cfquery NAME="getOverageData_compounded" datasource="#application.datasource#">
		SELECT *
		FROM Program_Formula_Pricing_Rule_Overage
		WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND Deleted = 0
		AND Active = 1
		AND Calc_Type = 2<!------ compounded ---->
		Order By Overage_Index
	</cfquery>
</cfif>
	<CFLOOP QUERY="getOverageData_compounded" endrow="#getOverageData_compounded.RecordCount#">
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

<!---This variable will be used below to determine the number of Compounded and	Independent Calculation records made in the Modifications section--->
<cfset thisModCommCount = 4 />
<cfset thisModCommLoopCount = 4 />
<!---Rows can now exceed 4. Adding code to handle for rows that were added dynamically beyond 4. --->
<cfif getOverageData_Independent.RecordCount gt 4 or getOverageData_compounded.RecordCount gt 4>
	<cfif getOverageData_Independent.RecordCount gt getOverageData_compounded.RecordCount>
		<cfset thisModCommCount = getOverageData_Independent.RecordCount + 1 />
		<cfset thisModCommLoopCount = getOverageData_Independent.RecordCount />
	<cfelse>
		<cfset thisModCommCount = getOverageData_compounded.RecordCount + 1 />
		<cfset thisModCommLoopCount = getOverageData_compounded.RecordCount />
	</cfif>
</cfif>

<CFSET StartIndex = getOverageData_Independent.recordcount+1>
<CFLOOP INDEX="i" FROM="#StartIndex#" TO="#thisModCommCount#" STEP="1">
	<CFSET "INDEPENDENT_DESC_CALC#i#_1" 				= "">
	<CFSET "independent_amount_calc#i#_1" 				= "">
	<CFSET "independent_amount_uom#i#_1" 				= "$">
</CFLOOP>
<CFSET StartIndex = getOverageData_compounded.recordcount+1>
<CFLOOP INDEX="i" FROM="#StartIndex#" TO="#thisModCommCount#" STEP="1">
	<CFSET "compounded_DESC_CALC#i#_1" 				= "">
	<CFSET "compounded_amount_calc#i#_1" 				= "">
	<CFSET "compounded_amount_uom#i#_1" 				= "$">
</CFLOOP>

	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT LANGUAGE="JavaScript">
	<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->

	function initPage(){
		//CalculationsSelectIndex3(document.all.independent_desc_calc1_1)
		disableElements3(document.MyForm,true);
		//setDefaultForExchangeAndSymbol();
		//findselectboxes();
	}


<CFOUTPUT>
	function setDefaultForSelect(oSelect,defaultValue)
	{
		var optLen = oSelect.options.length;
		var i;
		for(i=0;i<optLen;i++)
		{
			if(oSelect.options[i].value == defaultValue)
			{
				oSelect.selectedIndex = i;
				return;
			}
		}
	}
</CFOUTPUT>

	function enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear)
	{
		try
		{
			if(!isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
			{
				allClear=true;
			}
			eval("thisForm." + Obj1Name + ".readOnly=" + (!allClear));
			eval("thisForm." + Obj2Name + ".readOnly=" + (!allClear));
			eval("thisForm." + Obj3Name + ".readOnly=" + (!allClear));


			var selObj = eval("thisForm." + Obj3Name);

			if(selObj.tagName == "SELECT")
			{
				selObj.disabled=(!allClear);
			}

			if(allClear)
			{
				var col = "\"ffffff\"";
			}
			else
			{
				var col = "\"cccccc\"";
			}
			eval("thisForm." + Obj1Name + ".style.backgroundColor=" + col);
			eval("thisForm." + Obj2Name + ".style.backgroundColor=" + col);
			eval("thisForm." + Obj3Name + ".style.backgroundColor=" + col);
		}
		catch(e)
		{
			alert(e.description);
		}
		//enableDisableAdd();
		return allClear;
	}

	function isSpace(sStr)
	{
		var re = /^[\s\t]*$/ig;
		if (re.test(sStr))
			return true;
		else
			return false;
	}

	function isFloat(sVal,noMinus)
	{
		var sValTemp = parseFloat(sVal);
		//if((!isNaN(sValTemp) && sValTemp+"" == sVal))

		if(!isNaN(sValTemp) && (/^[+-]?\d*(\.(\d)+)?$/.test(sVal)))
		{
			if(noMinus) return /^\d*(\.(\d)+)?$/.test(sVal);
			return true;
		}
		else
		{
			return false;
		}

		//return (/^[+-]?\d*(\.(\d)+)?$/.test(sVal));
	}

	function CalculationsSelectIndex3(thisObj)
	{
		var objName = thisObj.name;
		var nextObjName="";
		switch(objName.substr(0,16))
		{
			case "compounded_desc_":
				nextObjName = "compounded_amount_calc" + objName.substr(20);
				CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName), true);
				break;
			case "compounded_amoun":
				nextObjName = "compounded_desc_calc" + objName.substr(22);
				CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj, true);
				break;
			case "independent_desc":
				nextObjName = "independent_amount_calc" + objName.substr(21);
				CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName), true);
				break;
			case "independent_amou":
				nextObjName = "independent_desc_calc" + objName.substr(23);
				CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj, true);
				break;
		}
		switch(objName.substr(0,18))
		{
			case "comm_compounded_de":
				nextObjName = "comm_compounded_amount_calc" + objName.substr(25);
				CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName), false);
				break;
			case "comm_compounded_am":
				nextObjName = "comm_compounded_desc_calc" + objName.substr(27);
				CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj, false);
				break;
			case "comm_independent_d":
				nextObjName = "comm_independent_amount_calc" + objName.substr(26);
				CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName), false);
				break;
			case "comm_independent_a":
				nextObjName = "comm_independent_desc_calc" + objName.substr(28);
				CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj, false);
				break;
		}
	}

	function CalculationsSelect3(thisForm,Obj1,Obj2, bModifications)
	{
		var objCount = 1;
		var allClear=true;
		if(isSpace(Obj1.value))
		{
			allClear = allClear && false;
		}

		if(!isFloat(Obj2.value))
		{
			allClear = allClear && false;
		}
		objName = Obj1.name;
		
		/* 
			Logic below is to find the number of records for each calculation section.
			Prior to these new changes the number of records was always 4. 
			But now that users can add records dynamically we have to find the numbers of records for each calculation section. 
		*/
		len = objName.length - 1;
		idx = objName.substring(len);
		//if calculation entries are from the modification section then get the count from the dyn_mod_comm_count_1001 hidden field.
		if(bModifications){
			count = thisForm.dyn_mod_comm_count_1001.value;
		}
		//otherwise get the count from the hidden field for the given section.
		else{
			count = eval("thisForm.dyn_comm_count_" + idx + ".value");
		}

		switch(objName.substr(0,16))
		{
			case "compounded_desc_":
				nextIndex = objName.substring(20,objName.lastIndexOf("_"));
				nextIndex = parseInt(nextIndex) + 1;
				lastPart = objName.substr(objName.lastIndexOf("_"));
				for(i=nextIndex;i<=count;i++)
				{
					Obj1Name = "compounded_desc_calc" + i + lastPart;
					Obj2Name = "compounded_amount_calc" + i + lastPart;
					Obj3Name = "compounded_amount_uom" + i + lastPart;
					if(enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear) && allClear)
						break;
				}
				break;
			case "independent_desc":
				nextIndex = objName.substring(21,objName.lastIndexOf("_"));
				nextIndex = parseInt(nextIndex) + 1;
				lastPart = objName.substr(objName.lastIndexOf("_"));
				for(i=nextIndex;i<=count;i++)
				{
					Obj1Name = "independent_desc_calc" + i + lastPart;
					Obj2Name = "independent_amount_calc" + i + lastPart;
					Obj3Name = "independent_amount_uom" + i + lastPart;
					if(enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear) && allClear)
						break;
				}
				break;
		}
		switch(objName.substr(0,18))
		{
			case "comm_compounded_de":
				nextIndex = objName.substring(25,objName.lastIndexOf("_"));
				nextIndex = parseInt(nextIndex) + 1;
				lastPart = objName.substr(objName.lastIndexOf("_"));
				for(i=nextIndex;i<=count;i++)
				{
					Obj1Name = "comm_compounded_desc_calc" + i + lastPart;
					Obj2Name = "comm_compounded_amount_calc" + i + lastPart;
					Obj3Name = "comm_compounded_amount_uom" + i + lastPart;
					if(enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear) && allClear)
						break;
				}
				break;
			case "comm_independent_d":
				nextIndex = objName.substring(26,objName.lastIndexOf("_"));
				nextIndex = parseInt(nextIndex) + 1;
				lastPart = objName.substr(objName.lastIndexOf("_"));
				for(i=nextIndex;i<=count;i++)
				{
					Obj1Name = "comm_independent_desc_calc" + i + lastPart;
					Obj2Name = "comm_independent_amount_calc" + i + lastPart;
					Obj3Name = "comm_independent_amount_uom" + i + lastPart;
					if(enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,allClear) && allClear)
						break;
				}
				break;
		}

	}

	function disableElements3(thisForm,bDis)
	{
		var totalCommNo = 1;
		var startIndex = 1;
		if(totalCommNo == 0)
			startIndex = 0;

		for(i=startIndex;i<=totalCommNo;i++)
		{
			disableOverageCombos(i, "compounded_", thisForm, bDis, true);
			disableOverageCombos(i, "independent_", thisForm, bDis, true);
		}
		totalCommNo = <CFOUTPUT>#Number_Of_Comms#</CFOUTPUT>;
		for(i=1;i<=totalCommNo;i++)
		{
			disableOverageCombos(i, "comm_compounded_", thisForm, bDis, false);
			disableOverageCombos(i, "comm_independent_", thisForm, bDis, false);
		}
	}

	function disableOverageCombos(i, strStart, thisForm, bDis, bModifications)
	{
		var bThisDis;
		var selObj;
		bThisDis = true;
		j = 1;
		Obj1Name = strStart + "desc_calc" + j + "_" + i;
		Obj2Name = strStart + "amount_calc" + j + "_" + i;
		Obj3Name = strStart + "amount_uom" + j + "_" + i;
	
		len = Obj1Name.length - 1;
		idx = Obj1Name.substring(len);
		//if from modification section get the count from dyn_mod_comm_count_1001 hidden field
		if(bModifications){
			count = thisForm.dyn_mod_comm_count_1001.value;
		}
		//otherwise get the count from the hidden field for the given section. 
		else{
			count = eval("thisForm.dyn_comm_count_" + idx + ".value");
		}

		if((j==1) && !isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
		{
			bThisDis=false;
		}
		else if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value")=="0")
		{
			eval("thisForm." + Obj2Name + ".value=''");
		}


		for(j=2;j<=count;j++)
		{
			Obj1Name = strStart + "desc_calc" + j + "_" + i;
			Obj2Name = strStart + "amount_calc" + j + "_" + i;
			Obj3Name = strStart + "amount_uom" + j + "_" + i;

			if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value") == 0)
			{
				//alert("0");
				eval("thisForm." + Obj1Name + ".value = '';");
				eval("thisForm." + Obj2Name + ".value = '';");
			}

			if(!isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
			{
				bThisDis=false;
				continue;
			}

			if(bThisDis && bDis)
				bThisDis=!enableNextGroup(thisForm,Obj1Name,Obj2Name,Obj3Name,!bThisDis);
			else
				bThisDis=!bThisDis;
			if(!bDis)
			{
				selObj = eval("thisForm." + Obj3Name);
				if(selObj.tagName == "SELECT")
				{
					selObj.disabled=bDis;
				}
			}
		}
	}
	</SCRIPT>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Formula Pricing List Page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<cfquery NAME="Get_All_Commodity_Overage" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Formula_Pricing_Commodity_Overage
	WHERE	<CFIF Rule_ID NEQ "">
				Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			<CFELSE>
				1=2
			</CFIF>
	AND		DELETED = 0
</cfquery>
	
<FORM ACTION="Formula_Price_Step2_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;">
	<cfoutput>
		<INPUT TYPE="Hidden" NAME="Program_Id" VALUE="#Form.Program_Id#">
		<INPUT TYPE="Hidden" NAME="saved" VALUE="#Form.saved#">
    </cfoutput>
<!------<CFLOOP INDEX="i" FROM="1" TO="#number_of_comms#" STEP="1">----->
<CFSET i = 0>
<cfscript>
	appSettings = application.appSettingsGet;
	oFormula    = CreateObject("component", "mvc.Models.Program.Component.Formula");
	qTypes = oFormula.getFormulaTypes();
</cfscript>
<CFLOOP QUERY="getCommData">
<!--------------------------------Compounded Calculations Query--------------------------------->
<cfset useLakebaseForGet_This_Compounded_Commodity_Overage = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all_commodity_overage")>
<cfif useLakebaseForGet_This_Compounded_Commodity_Overage>
	<cftry>
		<cfset Get_This_Compounded_Commodity_Overage = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all_commodity_overage", {
				"program_formula_pricing_rule_comm_data_id" = "eq.#Program_Formula_Pricing_Rule_Comm_Data_ID#",
				"calc_type" = "eq.2",
				"order" = "overage_index.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_This_Compounded_Commodity_Overage = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_This_Compounded_Commodity_Overage>
<cfquery name="Get_This_Compounded_Commodity_Overage" DBTYPE="query">
	SELECT	*
	FROM	Get_All_Commodity_Overage
	WHERE
			Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
			AND
			Calc_Type = 2
	ORDER BY Overage_Index
</cfquery>
</cfif>
<!--------------------------------Compounded Independent Query--------------------------------->
<cfset useLakebaseForGet_This_Independent_Commodity_Overage = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all_commodity_overage")>
<cfif useLakebaseForGet_This_Independent_Commodity_Overage>
	<cftry>
		<cfset Get_This_Independent_Commodity_Overage = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all_commodity_overage", {
				"program_formula_pricing_rule_comm_data_id" = "eq.#Program_Formula_Pricing_Rule_Comm_Data_ID#",
				"calc_type" = "eq.1",
				"order" = "overage_index.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_This_Independent_Commodity_Overage = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_This_Independent_Commodity_Overage>
<cfquery NAME="Get_This_Independent_Commodity_Overage" DBTYPE="query">
		SELECT	*
		FROM	Get_All_Commodity_Overage
		WHERE
				Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
				AND
				Calc_Type = 1
		ORDER BY Overage_Index
</cfquery>
</cfif>

<CFSET i = i + 1>
<!---Rows can now exceed 4. Adding code to handle for rows that were added dynamically beyond 4. --->
<cfif Get_This_Compounded_Commodity_Overage.RecordCount gt 4>
	<cfset toComp = Get_This_Compounded_Commodity_Overage.RecordCount + 1 />
<cfelse>
	<cfset toComp = 4 />
</cfif>

<!---Rows can now exceed 4. Adding code to handle for rows that were added dynamically beyond 4. --->
<cfif Get_This_Independent_Commodity_Overage.RecordCount gt 4>
	<cfset toInde = Get_This_Independent_Commodity_Overage.RecordCount + 1 />
<cfelse>
	<cfset toInde = 4 />
</cfif>
<!---Add hidden input to keep track of the number of rows for each commodify. This form variable will be used on the action page to determine how many entries into Formula_Pricing_Commodity_Overage --->
<cfif toComp gt toInde>
	<cfset thisCommCount = toComp />
<cfelse>
	<cfset thisCommCount = toInde />
</cfif>
<cfoutput>
<INPUT TYPE="hidden" NAME="dyn_comm_count_#i#" id="dyn_comm_count_#i#" VALUE="#thisCommCount#">
</cfoutput>

<FIELDSET STYLE="padding:5px; width: 750px; border: 1px solid Silver;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Commodity <CFOUTPUT>#i# of #number_of_comms#</CFOUTPUT></LEGEND>
	<CFIF getCommData.recordcount GT 0 AND symbol NEQ "">
		<TABLE BORDER="0" WIDTH="90%">
			<CFOUTPUT>
			<TR>
				<TD ALIGN="right"><B>Exchange:</B></TD>
				<TD  STYLE="color: red;" VALIGN="bottom"><B>#Exchange_Detail_Name#</B></TD>
			</TR>
			<TR>
				<TD ALIGN="right"><B>Commodity:</B></TD>
				<TD STYLE="color: red;" VALIGN="bottom"><B>#Symbol_Description#</B></TD>
				<TD WIDTH="50%">&nbsp;</TD>
			</TR>
			<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 1>
				<TR VALIGN="top">
					<TD ALIGN="right"><span id="Formula_Type_#i#"></span><B>Type:</B></TD>
					<TD VALIGN="top">
						<SELECT NAME="FP_Formula_Type_ID_#i#">
							<OPTION VALUE="0">Select a formula type</OPTION>
							<cfloop query="qTypes">
								<cfset s = "">
								<cfif getCommData.FP_Formula_Type_ID eq qTypes.FP_Formula_Type_ID> <cfset s = "selected"></cfif>
								<OPTION VALUE="#qTypes.FP_Formula_Type_ID#" #s#>#qTypes.Formula_Type_Description#</OPTION>
							</cfloop>
						</SELECT>
					</TD>
					<TD WIDTH="50%">&nbsp;</TD>
				</TR>
			</cfif>
			<TR>
				<TD COLSPAN="3" VALIGN="top">
					<HR COLOR="orange">
				</TD>
			</TR>
			</CFOUTPUT>
		</TABLE>
	</CFIF>

	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Exchange_#i#" VALUE="#Exchange_Detail_ID#">
	<INPUT TYPE="Hidden" NAME="Commodity_#i#" VALUE="#Symbol#">
	<INPUT TYPE="Hidden" NAME="Commodities_Symbol_ID_#i#" VALUE="#Commodities_Symbol_ID#">
	</CFOUTPUT>
	<CFOUTPUT>
	<TABLE CELLPADDING="2" CELLSPACING="4" BORDER="0">
		<CFIF Number_Of_Comms GT 1>
			<TR>
				<TD>
					<span id="weight_#i#"></span>&nbsp;Please weight this commodity in relation to the others:&nbsp;&nbsp;
				</TD>
				<TD>
					<SPAN ID="weightSpan">
						<!---
							D34480:Commodity Values greater than 100
							<INPUT TYPE="text" NAME="Comm_weight_#i#" VALUE="#weight#" SIZE="1" MAXLENGTH="3" onKeyUp="clenseText(this, '0123456789');">%--->
						<INPUT TYPE="text" NAME="Comm_weight_#i#" VALUE="#weight#" SIZE="11" >
					</SPAN>
				</TD>
			</TR>
		</CFIF>
	</TABLE>


	<TABLE BORDER="0" WIDTH="660" CELLPADDING="0" CELLSPACING="4">
	<TR>
		<TD STYLE="border-bottom:1px solid orange;"><b>Compounded Calculations</b></TD>
		<TD STYLE="border-bottom:1px solid orange;"><b>Independent Calculations</b></TD>
	</TR>
	<TR>
		<!----------------------------------------------------------------------------------------------->
		<!--------------------------------Compounded Calculations Column--------------------------------->
		<!----------------------------------------------------------------------------------------------->
		<TD>			
			<TABLE WIDTH="330" BORDER="0" ALIGN="center" CELLSPACING="0" id="compoundedTable_#i#">
				<TR>
					<TD VALIGN="bottom"><B>Component Description</B></TD>
					<TD VALIGN="bottom"><B>Amount</B></TD>
					<TD VALIGN="bottom"><B>UOM</B></TD>
				</TR>
				<CFSET k = 1>
				<CFLOOP QUERY="Get_This_Compounded_Commodity_Overage">
					<tr>
						<TD><INPUT TYPE="text" NAME="comm_compounded_desc_calc#k#_#i#" SIZE="40" MAXLENGTH="45" VALUE="#Description#" OnChange="CalculationsSelectIndex3(this)"></TD>
						<TD><input type="text" name="comm_compounded_amount_calc#k#_#i#" size="4" VALUE="#Amount#" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
						<TD><SELECT NAME="comm_compounded_amount_uom#k#_#i#"><OPTION VALUE="$"<CFIF UOM EQ "$"> SELECTED</CFIF>>$</OPTION><OPTION VALUE="%"<CFIF UOM EQ "%"> SELECTED</CFIF>>%</OPTION></SELECT></TD>
					</TR>
					<CFSET k = k + 1>
				</CFLOOP>
				<CFLOOP INDEX="k" FROM="#k#" TO="#thisCommCount#">
					<tr>
						<TD><INPUT TYPE="text" NAME="comm_compounded_desc_calc#k#_#i#" SIZE="40" MAXLENGTH="45" VALUE="" OnChange="CalculationsSelectIndex3(this)"></TD>
						<TD><input type="text" name="comm_compounded_amount_calc#k#_#i#" size="4" VALUE="" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
						<TD><SELECT NAME="comm_compounded_amount_uom#k#_#i#"><OPTION VALUE="$">$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
					</TR>
				</CFLOOP>
			</TABLE>
		</TD>
		<!------------------------------------------------------------------------------------------------->
		<!---------------------------------Independent  Calculations Column-------------------------------->
		<!------------------------------------------------------------------------------------------------->
		<TD valign="top">
			<TABLE WIDTH="330" BORDER="0" ALIGN="center" CELLSPACING="0" id="independentTable_#i#">
				<TR>
					<TD VALIGN="bottom"><B>Component Description</B></TD>
					<TD VALIGN="bottom"><B>Amount</B></TD>
					<TD VALIGN="bottom"><B>UOM</B></TD>
				</TR>
				<CFSET k = 1>
				<CFLOOP QUERY="Get_This_Independent_Commodity_Overage">
					<tr>
						<TD><INPUT TYPE="text" NAME="comm_independent_desc_calc#k#_#i#" SIZE="40" MAXLENGTH="45" VALUE="#Description#" OnChange="CalculationsSelectIndex3(this)"></TD>
						<TD><input type="text" name="comm_independent_amount_calc#k#_#i#" size="4" VALUE="#Amount#" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
						<TD><SELECT NAME="comm_independent_amount_uom#k#_#i#"><OPTION VALUE="$"<CFIF UOM EQ "$"> SELECTED</CFIF>>$</OPTION><OPTION VALUE="%"<CFIF UOM EQ "%"> SELECTED</CFIF>>%</OPTION></SELECT></TD>
						<cfif k eq thisCommCount>
							<td> <img class="clone_add" name="clone_add_comm_#i#" src="/images/plus4.gif" border="0" id="#i#" trCount="#k#"><td>
						</cfif>
					</TR>
					<CFSET k = k + 1>
				</CFLOOP>
				<CFLOOP INDEX="k" FROM="#k#" TO="#thisCommCount#">
					<tr>
						<TD><INPUT TYPE="text" NAME="comm_independent_desc_calc#k#_#i#" SIZE="40" MAXLENGTH="45" VALUE="" OnChange="CalculationsSelectIndex3(this)"></TD>
						<TD><input type="text" name="comm_independent_amount_calc#k#_#i#" size="4" VALUE="" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
						<TD><SELECT NAME="comm_independent_amount_uom#k#_#i#"><OPTION VALUE="$">$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
						<cfif k eq thisCommCount>
							<td><img class="clone_add" name="clone_add_comm_#i#" src="/images/plus4.gif" border="0" id="#i#" trCount="#k#"><td>
						</cfif>
					</TR>
				</CFLOOP>
			</table>
			</TD>
		</TR>
	</TABLE>
	<CFIF Number_Of_Comms EQ 1>
		<INPUT TYPE="Hidden" NAME="Comm_weight_#i#" SIZE="11" VALUE="100">
	</CFIF>
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
	<cfif appSettings.get_Setting('Formula_Price_Item_Level_Config') eq 0>
		<INPUT TYPE="hidden" NAME="FP_Formula_Type_ID" ID="FP_Formula_Type_ID" VALUE="#FORM.FP_Formula_Type_ID#"/>
	</cfif>
	<CFIF IsDefined("FORM.Rule_Name")>
		<INPUT TYPE="hidden" NAME="Rule_Name" ID="Rule_Name" VALUE="#FORM.Rule_Name#">
	</CFIF>
</CFOUTPUT>
<!------------------------------------------------------------------------------------------------->
<!---------------------------------Modification Calculations Column-------------------------------->
<!------------------------------------------------------------------------------------------------->
<BR>
<FIELDSET STYLE="padding:5px; width: 750px; border: 1px solid Silver;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Modifications</LEGEND>
	<TABLE BORDER="0" WIDTH="660" CELLPADDING="0" CELLSPACING="4">
	<TR>
		<TD STYLE="border-bottom:2px solid orange;"><b>Compounded Calculations</b></TD>
		<TD STYLE="border-bottom:2px solid orange;"><b>Independent Calculations</b></TD>
	</TR>
	<TR>
		<TD>
			<TABLE WIDTH="330" BORDER="0" ALIGN="center" CELLSPACING="0" id="modificationCompoundedTable_1001">
				<TR>
					<TD VALIGN="bottom"><B>Component Description</B></TD>
					<TD VALIGN="bottom"><B>Amount</B></TD>
					<TD VALIGN="bottom"><B>UOM</B></TD>
				</TR>
				<CFOUTPUT>
				<CFLOOP INDEX="i" FROM="1" TO="#thisModCommCount#" STEP="1">
				<TR>
					<TD><INPUT TYPE="text" NAME="compounded_desc_calc#i#_1" SIZE="40" MAXLENGTH="45" VALUE="#Evaluate("compounded_DESC_CALC#i#_1")#" OnChange="CalculationsSelectIndex3(this)"></TD>
					<TD><input type="text" name="compounded_amount_calc#i#_1" size="4" VALUE="#Evaluate("compounded_amount_calc#i#_1")#" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
					<TD>
						<SELECT NAME="compounded_amount_uom#i#_1">
							<OPTION VALUE="$"<CFIF Evaluate("compounded_amount_uom#i#_1") EQ "$"> SELECTED</CFIF>>$</OPTION>
							<OPTION VALUE="%"<CFIF Evaluate("compounded_amount_uom#i#_1") EQ "%"> SELECTED</CFIF>>%</OPTION>
							<OPTION VALUE="/"<CFIF Evaluate("compounded_amount_uom#i#_1") EQ "/"> SELECTED</CFIF>>/</OPTION>
						</SELECT>
					</TD>
				</TR>
				</CFLOOP>
				</CFOUTPUT>
			</table>
			</TD>
			<TD>
			<TABLE WIDTH="330" BORDER="0" ALIGN="center" CELLSPACING="0" id="modificationIndependentTable_1001">
				<TR>
					<TD VALIGN="bottom"><B>Component Description</B></TD>
					<TD VALIGN="bottom"><B>Amount</B></TD>
					<TD VALIGN="bottom"><B>UOM</B></TD>
				</TR>
				<CFOUTPUT>
				<CFLOOP INDEX="i" FROM="1" TO="#thisModCommCount#" STEP="1">
				<TR>
					<TD><INPUT TYPE="text" NAME="independent_desc_calc#i#_1" SIZE="40" MAXLENGTH="45" VALUE="#Evaluate("INDEPENDENT_DESC_CALC#i#_1")#" OnChange="CalculationsSelectIndex3(this)"></TD>
					<TD><input type="text" name="independent_amount_calc#i#_1" size="4" VALUE="#Evaluate("independent_amount_calc#i#_1")#" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
					<TD>
						<SELECT NAME="independent_amount_uom#i#_1">
							<OPTION VALUE="$"<CFIF Evaluate("independent_amount_uom#i#_1") EQ "$"> SELECTED</CFIF>>$</OPTION>
							<OPTION VALUE="%"<CFIF Evaluate("independent_amount_uom#i#_1") EQ "%"> SELECTED</CFIF>>%</OPTION>
						</SELECT>
					</TD>
					<cfif i eq thisModCommCount>
						<td>
							<img class="clone_add" name="clone_add_mod" src="/images/plus4.gif" border="0" id="1001" trCount="#i#">
						</td>
					</cfif>
				</TR>
				</CFLOOP>
				</CFOUTPUT>
			</table>
		</TD>
	</TR>
	</TABLE>
</FIELDSET>
<cfoutput>

<INPUT TYPE="hidden" NAME="dyn_mod_comm_count_1001" id="dyn_comm_count_1001" VALUE="#thisModCommCount#">
</cfoutput>
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

			if(document.all.FP_Formula_Type_ID_#i#.value == 0){
				ErrorCount++
				queueMessage("Select a commodity type", document.all.Formula_Type_#i#);
			}
			else {
				clearQueue(document.all.Formula_Type_#i#);
			}
			
		</CFLOOP>
		</cfoutput>

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

//function to enable and disable add icon
function enableDisableAdd(){

	var commNum =  $( "input#Number_Of_Comms" ).val();
	for (var i = 1; i <= commNum; i++) {
		$("#independentTable_" + i).find('tr:last td').each( function () {
			var $inpComm = $(this).find("input[name*='comm_independent_desc_calc']").attr("readonly");
			var $addIcon = $(this).parent().find("img.clone_add");
		
			if($inpComm == 'readonly'){
				$($addIcon).addClass("disabled");
				return false;
			}
			else{
				$($addIcon).removeClass("disabled");
				return false;
			}
		});
	}

	$("#modificationIndependentTable_1001").find('tr:last td').each( function () {
		var $inpModComm = $(this).find("input[name*='independent_desc_calc']").attr("readonly");
		var $addIcon = $(this).parent().find("img.clone_add");
	
		if($inpModComm == 'readonly'){
			$($addIcon).addClass("disabled");
			return false;
		}
		else{
			$($addIcon).removeClass("disabled");
			return false;
		}
	});
}

$("img.clone_add").live('click', function() {
	//get the id of the current row
	var id = parseInt($(this).attr("trCount")) + 1;
	var commId = parseInt($(this).attr("id"));
	//build new row for compounded table
    $("#compoundedTable_" + this.id + "").each(function () {
		var tds = '<tr>';
		jQuery.each($('tr:last td', this), function () {
			var $content = $(this).clone();
			$content.find("input[name*='comm_compounded_desc_calc']").attr('name',  'comm_compounded_desc_calc' + id + '_' + commId);
			$content.find("input[name*='comm_compounded_amount_calc']").attr('name',  'comm_compounded_amount_calc' + id + '_' + commId);
			$content.find("select[name*='comm_compounded_amount_uom']").attr('name',  'comm_compounded_amount_uom' + id + '_' + commId);
            tds += '<td>' + $content.html().replace("value", "").replace("selected", "") + '</td>';
		});
		tds += '</tr>';
		//add new row
		$('tbody', this).append(tds);
     });
	 //build new row for independent table
	$("#independentTable_" + this.id + "").each(function () {
		var tds = '<tr>';
		jQuery.each($('tr:last td', this), function () {
			var $content = $(this).clone();
			$content.find("input[name*='comm_independent_desc_calc']").attr('name',  'comm_independent_desc_calc' + id + '_' + commId);
			$content.find("input[name*='comm_independent_amount_calc']").attr('name',  'comm_independent_amount_calc' + id + '_' + commId);
			$content.find("select[name*='comm_independent_amount_uom']").attr('name',  'comm_independent_amount_uom' + id + '_' + commId);
			$content.find("img").attr('trCount', id );
            tds += '<td>' + $content.html().replace("value", "").replace("selected", "") + '</td>';
		});		
		tds += '</tr>';
		//add new row
		$('tbody', this).append(tds);		 
     });
	//build new row for modification compounded table
	$("#modificationCompoundedTable_" + this.id + "").each(function () {
		var tds = '<tr>';
		jQuery.each($('tr:last td', this), function () {
			var $content = $(this).clone();
			$content.find("input[name*='compounded_desc_calc']").attr('name',  'compounded_desc_calc' + id + '_1');
			$content.find("input[name*='compounded_amount_calc']").attr('name',  'compounded_amount_calc' + id + '_1');
			$content.find("select[name*='compounded_amount_uom']").attr('name',  'compounded_amount_uom' + id + '_1');
			$content.find("img").attr('trCount', id );
            tds += '<td>' + $content.html().replace("value", "").replace("selected", "") + '</td>';
		});		
		tds += '</tr>';
		//add new row
		$('tbody', this).append(tds);		 
     });
	 //build new row for modification independent table
	$("#modificationIndependentTable_" + this.id + "").each(function () {
		var tds = '<tr>';
		jQuery.each($('tr:last td', this), function () {
			var $content = $(this).clone();
			$content.find("input[name*='independent_desc_calc']").attr('name',  'independent_desc_calc' + id + '_1');
			$content.find("input[name*='independent_amount_calc']").attr('name',  'independent_amount_calc' + id + '_1');
			$content.find("select[name*='independent_amount_uom']").attr('name',  'independent_amount_uom' + id + '_1');
			$content.find("img").attr('trCount', id );
            tds += '<td>' + $content.html().replace("value", "").replace("selected", "") + '</td>';
		});		
		tds += '</tr>';
		//add new row
		$('tbody', this).append(tds);		 
     });
	var countVal = eval("document.all.MyForm.dyn_comm_count_" + this.id);
	countVal.value = id;
	//remove add icon from the previous row so we only show one add icon
	$(this).remove();
});

initPage();
</script>
<!---</cfmodule>--->