<CFPARAM NAME="URL.RID" 	DEFAULT="">
<CFPARAM NAME="FORM.Rule_ID" 	DEFAULT="#URL.RID#">
<CFSET Rule_ID = FORM.Rule_ID>
<CFPARAM NAME="FORM.Commodity_List" 	DEFAULT="">

<CFIF FORM.Rule_ID NEQ "">
	<CFSET FORMULA_PAGE_NAME="5">
<CFELSE>
	<CFSET FORMULA_PAGE_NAME="3">
</CFIF>

<cfmodule template="/customTags/layout.cfm"
              layoutID = "formulaPricing"
              formula_page_name = #FORMULA_PAGE_NAME#
              selectedIndex = "2" >

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
		<CFLOCATION ADDTOKEN="No" URL="Formula_Price_Display.cfm?RID=#Rule_ID#">
	</CFIF>
</CFIF>

<CFQUERY NAME="getCommData" datasource="#application.datasource#">
	SELECT 	Commodities_Exchange_Detail.Exchange_Detail_ID, Commodities_Exchange_Detail.Exchange_Detail_Name,
			Commodities_Symbol.Symbol, Commodities_Symbol.Symbol_Description,
			Program_Formula_Pricing_Rule_Comm_Data.Exchange, Program_Formula_Pricing_Rule_Comm_Data.Symbol,
			Program_Formula_Pricing_Rule_Comm_Data.Point_In_Time, Program_Formula_Pricing_Rule_Comm_Data.Point_In_Time_UOM,
			Program_Formula_Pricing_Rule_Comm_Data.Sample_Size, Program_Formula_Pricing_Rule_Comm_Data.Sample_Size_UOM,
			Program_Formula_Pricing_Rule_Comm_Data.Weight, Program_Formula_Pricing_Rule_Comm_Data.Program_Formula_Pricing_Rule_Comm_Data_ID
	FROM 	Commodities_Symbol
			INNER JOIN	Commodities_Exchange_Detail
			ON
			Commodities_Exchange_Detail.Exchange_Detail_Abrev = Commodities_Symbol.Exchange_Detail_Abrev
			LEFT JOIN Program_Formula_Pricing_Rule_Comm_Data
			ON
			Program_Formula_Pricing_Rule_Comm_Data.Symbol = Commodities_Symbol.Symbol
			<CFIF Trim(Rule_ID) NEQ "">
			AND Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			<CFELSE>
			AND 1=2
			</CFIF>
			AND Deleted = 0
			AND Active = 1
	WHERE
			1=1
			<CFIF FORM.Commodity_list NEQ "">
			AND Commodities_Symbol.Symbol IN (#ListQualify(FORM.Commodity_list, "'", ",")#)
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
		<CFQUERY NAME="getNewRule" datasource="#application.datasource#">
			SELECT Number_Of_Comms
			FROM Formula_Pricing_Rule
			WHERE
				Formula_Pricing_Rule_ID = '#Rule_ID#'
		</CFQUERY>
		<CFIF getNewRule.recordCount GT 0>
			<CFSET Number_Of_Comms=getNewRule.Number_Of_Comms>
		</CFIF>
	<CFELSE>
		<CFSET Number_Of_Comms=Form.Number_Of_Comms>
	</CFIF>

	<CFQUERY NAME="getOverageData_Independent" datasource="#application.datasource#">
		SELECT *
		FROM Program_Formula_Pricing_Rule_Overage
		WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND Deleted = 0
		AND Active = 1
		AND Calc_Type = 1<!------ independent ---->
		Order By Overage_Index
	</CFQUERY>
	<CFLOOP QUERY="getOverageData_Independent" endrow="4">
		<CFSET i = Overage_Index>
		<CFSET "INDEPENDENT_DESC_CALC#i#_1" 				= Description>
		<CFSET "independent_amount_calc#i#_1" 				= Amount>
		<CFSET "independent_amount_uom#i#_1" 				= UOM>
	</CFLOOP>

	<CFQUERY NAME="getOverageData_compounded" datasource="#application.datasource#">
		SELECT *
		FROM Program_Formula_Pricing_Rule_Overage
		WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND Deleted = 0
		AND Active = 1
		AND Calc_Type = 2<!------ compounded ---->
		Order By Overage_Index
	</CFQUERY>
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
	<SCRIPT LANGUAGE="JavaScript">
	<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->

	function initPage(){
		//CalculationsSelectIndex3(document.all.independent_desc_calc1_1)
		disableElements3(document.MyForm,true);
		//setDefaultForExchangeAndSymbol();

		//findselectboxes();
	}

/*****************************************************
Added by Deepa
*****************************************************/
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
/*****************************************************
Added by Deepa
*****************************************************/



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
				CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName));
				break;
			case "compounded_amoun":
				nextObjName = "compounded_desc_calc" + objName.substr(22);
				CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj);
				break;
			case "independent_desc":
				nextObjName = "independent_amount_calc" + objName.substr(21);
				CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName));
				break;
			case "independent_amou":
				nextObjName = "independent_desc_calc" + objName.substr(23);
				CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj);
				break;
		}
		switch(objName.substr(0,18))
		{
			case "comm_compounded_de":
				nextObjName = "comm_compounded_amount_calc" + objName.substr(25);
				CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName));
				break;
			case "comm_compounded_am":
				nextObjName = "comm_compounded_desc_calc" + objName.substr(27);
				CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj);
				break;
			case "comm_independent_d":
				nextObjName = "comm_independent_amount_calc" + objName.substr(26);
				CalculationsSelect3(thisObj.form,thisObj,eval("thisObj.form." + nextObjName));
				break;
			case "comm_independent_a":
				nextObjName = "comm_independent_desc_calc" + objName.substr(28);
				CalculationsSelect3(thisObj.form,eval("thisObj.form." + nextObjName),thisObj);
				break;
		}
	}

	function CalculationsSelect3(thisForm,Obj1,Obj2)
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
		switch(objName.substr(0,16))
		{
			case "compounded_desc_":
				nextIndex = objName.substring(20,objName.lastIndexOf("_"));
				nextIndex = parseInt(nextIndex) + 1;
				lastPart = objName.substr(objName.lastIndexOf("_"));
				for(i=nextIndex;i<=4;i++)
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
				for(i=nextIndex;i<=4;i++)
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
				for(i=nextIndex;i<=4;i++)
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
				for(i=nextIndex;i<=4;i++)
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
			disableOverageCombos(i, "compounded_", thisForm, bDis);
			disableOverageCombos(i, "independent_", thisForm, bDis);
		}
		totalCommNo = <CFOUTPUT>#Number_Of_Comms#</CFOUTPUT>;
		for(i=1;i<=totalCommNo;i++)
		{
			disableOverageCombos(i, "comm_compounded_", thisForm, bDis);
			disableOverageCombos(i, "comm_independent_", thisForm, bDis);
		}
	}

	function disableOverageCombos(i, strStart, thisForm, bDis)
	{
		var bThisDis;
		var selObj;
		bThisDis = true;
		j = 1;
		Obj1Name = strStart + "desc_calc" + j + "_" + i;
		Obj2Name = strStart + "amount_calc" + j + "_" + i;
		Obj3Name = strStart + "amount_uom" + j + "_" + i;

		if((j==1) && !isSpace(eval("thisForm." + Obj1Name + ".value")) && isFloat(eval("thisForm." + Obj2Name + ".value")))
		{
			bThisDis=false;
		}
		else if(isSpace(eval("thisForm." + Obj1Name + ".value")) && eval("thisForm." + Obj2Name + ".value")=="0")
		{
			eval("thisForm." + Obj2Name + ".value=''");
		}


		for(j=2;j<=4;j++)
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

<CFQUERY NAME="Get_All_Commodity_Overage" DATASOURCE="#application.datasource#">
	SELECT	*
	FROM	Formula_Pricing_Commodity_Overage
	WHERE
			<CFIF Rule_ID NEQ "">
			Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
			<CFELSE>
			1=2
			</CFIF>
</CFQUERY>

<FORM ACTION="Formula_Price_Step2_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;">
<!------<CFLOOP INDEX="i" FROM="1" TO="#number_of_comms#" STEP="1">----->
<CFSET i = 0>
<CFLOOP QUERY="getCommData">
<CFSET i = i + 1>


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
	</CFOUTPUT>
	<CFOUTPUT>
	<TABLE CELLPADDING="2" CELLSPACING="4" BORDER="0">
		<TR>
			<TD>
				<span id="error_sample_size#i#"></span>&nbsp;Please enter how many periods you would like to select data for:&nbsp;
			</TD>
			<TD>
				<INPUT TYPE="Text" NAME="sample_size_#i#" SIZE="11" VALUE="#sample_size#" onKeyUp="clenseText(this, '0123456789');">
			</TD>
			<TD ROWSPAN="3" VALIGN="TOP">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
			<TD ROWSPAN="3" VALIGN="TOP">
				<span id="error_uom#i#"></span>&nbsp;Period Definition:<br>
				<CFSET thisUOM=sample_size_uom>
				<INPUT TYPE="radio" NAME="Period_UOM_#i#" VALUE="weeks"<CFIF thisUOM EQ "weeks"> CHECKED</CFIF>>Weeks
				<INPUT TYPE="radio" NAME="Period_UOM_#i#" VALUE="days"<CFIF thisUOM EQ "days"> CHECKED</CFIF>>Days
			</TD>
		</TR>
		<TR>
			<TD>
				<span id="error_point_in_time_#i#"></span>&nbsp;Please select how far back in time the sample window should be:&nbsp;
			</TD>
			<TD>
				<INPUT TYPE="Text" NAME="point_in_time_#i#" SIZE="11" VALUE="#Point_In_Time#" onKeyUp="clenseText(this, '0123456789');">
			</TD>
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
		</TR>
	</TABLE>


	<TABLE BORDER="0" WIDTH="660" CELLPADDING="0" CELLSPACING="4">
	<TR>
		<TD STYLE="border-bottom:1px solid orange;"><b>Compounded Calculations</b></TD>
		<TD STYLE="border-bottom:1px solid orange;"><b>Independent Calculations</b></TD>
	</TR>
	<TR>
	<TD>
	<CFQUERY NAME="Get_This_Commodity_Overage" DBTYPE="query">
		SELECT	*
		FROM	Get_All_Commodity_Overage
		WHERE
				Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
				AND
				Calc_Type = 2
		ORDER BY Overage_Index
	</CFQUERY>
	<TABLE WIDTH="330" BORDER="0" ALIGN="center" CELLSPACING="0">
		<TR>
			<TD VALIGN="bottom"><B>Component Description</B></TD>
			<TD VALIGN="bottom"><B>Amount</B></TD>
			<TD VALIGN="bottom"><B>UOM</B></TD>
		</TR>
		<CFSET k = 1>
		<CFLOOP QUERY="Get_This_Commodity_Overage">
			<TR>
				<TD><INPUT TYPE="text" NAME="comm_compounded_desc_calc#k#_#i#" SIZE="40" MAXLENGTH="45" VALUE="#Description#" OnChange="CalculationsSelectIndex3(this)"></TD>
				<TD><input type="text" name="comm_compounded_amount_calc#k#_#i#" size="4" VALUE="#Amount#" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
				<TD><SELECT NAME="comm_compounded_amount_uom#k#_#i#"><OPTION VALUE="$"<CFIF UOM EQ "$"> SELECTED</CFIF>>$</OPTION><OPTION VALUE="%"<CFIF UOM EQ "%"> SELECTED</CFIF>>%</OPTION></SELECT></TD>
			</TR>
			<CFSET k = k + 1>
		</CFLOOP>
		<CFLOOP INDEX="k" FROM="#k#" TO="4">
			<TR>
				<TD><INPUT TYPE="text" NAME="comm_compounded_desc_calc#k#_#i#" SIZE="40" MAXLENGTH="45" VALUE="" OnChange="CalculationsSelectIndex3(this)"></TD>
				<TD><input type="text" name="comm_compounded_amount_calc#k#_#i#" size="4" VALUE="" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
				<TD><SELECT NAME="comm_compounded_amount_uom#k#_#i#"><OPTION VALUE="$">$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
			</TR>
		</CFLOOP>


	</TABLE>
	</TD>

	<TD>
	<CFQUERY NAME="Get_This_Commodity_Overage" DBTYPE="query">
		SELECT	*
		FROM	Get_All_Commodity_Overage
		WHERE
				Program_Formula_Pricing_Rule_Comm_Data_ID = '#Program_Formula_Pricing_Rule_Comm_Data_ID#'
				AND
				Calc_Type = 1
		ORDER BY Overage_Index
	</CFQUERY>
	<TABLE WIDTH="330" BORDER="0" ALIGN="center" CELLSPACING="0">
		<TR>
			<TD VALIGN="bottom"><B>Component Description</B></TD>
			<TD VALIGN="bottom"><B>Amount</B></TD>
			<TD VALIGN="bottom"><B>UOM</B></TD>
		</TR>
		<CFSET k = 1>
		<CFLOOP QUERY="Get_This_Commodity_Overage">
			<TR>
				<TD><INPUT TYPE="text" NAME="comm_independent_desc_calc#k#_#i#" SIZE="40" MAXLENGTH="45" VALUE="#Description#" OnChange="CalculationsSelectIndex3(this)"></TD>
				<TD><input type="text" name="comm_independent_amount_calc#k#_#i#" size="4" VALUE="#Amount#" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
				<TD><SELECT NAME="comm_independent_amount_uom#k#_#i#"><OPTION VALUE="$"<CFIF UOM EQ "$"> SELECTED</CFIF>>$</OPTION><OPTION VALUE="%"<CFIF UOM EQ "%"> SELECTED</CFIF>>%</OPTION></SELECT></TD>
			</TR>
			<CFSET k = k + 1>
		</CFLOOP>
		<CFLOOP INDEX="k" FROM="#k#" TO="4">
			<TR>
				<TD><INPUT TYPE="text" NAME="comm_independent_desc_calc#k#_#i#" SIZE="40" MAXLENGTH="45" VALUE="" OnChange="CalculationsSelectIndex3(this)"></TD>
				<TD><input type="text" name="comm_independent_amount_calc#k#_#i#" size="4" VALUE="" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
				<TD><SELECT NAME="comm_independent_amount_uom#k#_#i#"><OPTION VALUE="$">$</OPTION><OPTION VALUE="%">%</OPTION></SELECT></TD>
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
	<CFIF IsDefined("FORM.Rule_Name")>
		<INPUT TYPE="hidden" NAME="Rule_Name" ID="Rule_Name" VALUE="#FORM.Rule_Name#">
		<CFPARAM NAME="FORM.Show_Details" 	DEFAULT="0">
		<INPUT TYPE="hidden" NAME="Show_Details" ID="Show_Details" VALUE="#FORM.Show_Details#">
	</CFIF>
</CFOUTPUT>

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

	<TABLE WIDTH="330" BORDER="0" ALIGN="center" CELLSPACING="0">
		<TR>
			<TD VALIGN="bottom"><B>Component Description</B></TD>
			<TD VALIGN="bottom"><B>Amount</B></TD>
			<TD VALIGN="bottom"><B>UOM</B></TD>
		</TR>
		<CFOUTPUT>
		<CFLOOP INDEX="i" FROM="1" TO="4" STEP="1">
		<TR>
			<TD><INPUT TYPE="text" NAME="compounded_desc_calc#i#_1" SIZE="40" MAXLENGTH="45" VALUE="#Evaluate("compounded_DESC_CALC#i#_1")#" OnChange="CalculationsSelectIndex3(this)"></TD>
			<TD><input type="text" name="compounded_amount_calc#i#_1" size="4" VALUE="#Evaluate("compounded_amount_calc#i#_1")#" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
			<TD><SELECT NAME="compounded_amount_uom#i#_1"><OPTION VALUE="$"<CFIF Evaluate("compounded_amount_uom#i#_1") EQ "$"> SELECTED</CFIF>>$</OPTION><OPTION VALUE="%"<CFIF Evaluate("compounded_amount_uom#i#_1") EQ "%"> SELECTED</CFIF>>%</OPTION></SELECT></TD>
		</TR>
		</CFLOOP>
		</CFOUTPUT>
	</table>
	</TD>

	<TD>

	<TABLE WIDTH="330" BORDER="0" ALIGN="center" CELLSPACING="0">
		<TR>
			<TD VALIGN="bottom"><B>Component Description</B></TD>
			<TD VALIGN="bottom"><B>Amount</B></TD>
			<TD VALIGN="bottom"><B>UOM</B></TD>
		</TR>
		<CFOUTPUT>
		<CFLOOP INDEX="i" FROM="1" TO="4" STEP="1">
		<TR>
			<TD><INPUT TYPE="text" NAME="independent_desc_calc#i#_1" SIZE="40" MAXLENGTH="45" VALUE="#Evaluate("INDEPENDENT_DESC_CALC#i#_1")#" OnChange="CalculationsSelectIndex3(this)"></TD>
			<TD><input type="text" name="independent_amount_calc#i#_1" size="4" VALUE="#Evaluate("independent_amount_calc#i#_1")#" OnChange="CalculationsSelectIndex3(this)" OnKeyUp="clenseText(this, '0213456789.-')"></TD>
			<TD><SELECT NAME="independent_amount_uom#i#_1"><OPTION VALUE="$"<CFIF Evaluate("independent_amount_uom#i#_1") EQ "$"> SELECTED</CFIF>>$</OPTION><OPTION VALUE="%"<CFIF Evaluate("independent_amount_uom#i#_1") EQ "%"> SELECTED</CFIF>>%</OPTION></SELECT></TD>
		</TR>
		</CFLOOP>
		</CFOUTPUT>
	</table>
	</TD>

	</TR>
	</TABLE>
</FIELDSET>
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
<script>
	initPage()
</script>

<cf_MessageWindow>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script>
	function validateData() {
		ErrorCount = 0;
		//TotalWeight = 0;
		<cfoutput>
		<CFLOOP INDEX="i" FROM="1" TO="#number_of_comms#" STEP="1">
			if(document.all.sample_size_#i#.value.length == 0){
				ErrorCount++;
				queueMessage("Supply The Duration Of The Sample", document.all.error_sample_size#i#);
			}
			else {
				clearQueue(document.all.error_sample_size#i#);
			}

			if(document.all.point_in_time_#i#.value.length == 0){
				ErrorCount++;
				queueMessage("Supply The Sample Size", document.all.error_point_in_time_#i#);
			}
			else {
				clearQueue(document.all.error_point_in_time_#i#);
			}

			if(!Any_Object_Checked(document.all.Period_UOM_#i#)){
				ErrorCount++;
				queueMessage("Supply the period definition", document.all.error_uom#i#);
			}
			else {
				clearQueue(document.all.error_uom#i#);
			}
		// D34480:Commodity Values greater than 100
			/*if(document.all.Comm_weight_#i#.value.length != 0){
				TotalWeight = TotalWeight + parseInt(document.all.Comm_weight_#i#.value);
			}*/
		</CFLOOP>
		</cfoutput>

	// D34480:Commodity Values greater than 100
		/*if(TotalWeight != 100){
			ErrorCount++
			queueMessage("The current commodity weight sum of " + TotalWeight + "% must equal 100%", document.all.weight_1);
		}
		else {
			clearQueue(document.all.weight_1);
		}*/

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
</cfmodule>