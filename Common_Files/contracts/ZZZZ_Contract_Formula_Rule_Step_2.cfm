<cfparam name="FORM.Rule_ID" 	default="">
<cfparam name="URL.Rule_ID" 	default="#FORM.Rule_ID#">

<CF_cryp type="de" key="#request.key#" string="#URL.Rule_ID#">
<CFSET Rule_ID=cryp.value>

<CF_cryp type="de" key="#request.key#" string="#URL.CID#">

<CFPARAM NAME="FORM.UPDATE" DEFAULT="0">

<!------<CFLOOP INDEX="i" FROM="1" TO="4" STEP="1">
	<CFSET "default_exch_#i#" = "">
	<CFSET "default_comm_#i#" = "">
	<CFSET "default_sample_size_#i#" = "">
	<CFSET "default_sample_size_uom_#i#" = "">	
	<CFSET "default_sample_pit_#i#" = "">
	<CFSET "default_sample_pit_uom_#i#" = "">	
</CFLOOP>----->


<CFIF FORM.UPDATE EQ 0>
	<CFQUERY NAME="getNewRule" datasource="#application.datasource#">
		SELECT *
		FROM Program_Formula_Pricing_Rules
		WHERE 
			Program_ID = '#cryp.value#'
		AND 
			Deleted = 0
		AND 
			Active = 0
	</CFQUERY>
	
	<CFSET getCommData = QueryNew("deleted")>
	<CFSET getOverageData = QueryNew("deleted")>
	
	
	<CFSET Number_Of_Comms=getNewRule.Number_Of_Comms>
<CFELSE>
	<!------<CF_Cryp type="de" key="#request.key#" string="#FORM.RULE_ID#" Return="decrypRuleID">
	-------->
	<CFIF NOT isDefined("Form.Number_Of_Comms")>
		<CFQUERY NAME="getNewRule" datasource="#application.datasource#">
			SELECT Number_Of_Comms
			FROM Program_Formula_Pricing_Rules
			WHERE 
				Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		</CFQUERY>
		<CFIF getNewRule.recordCount GT 0>
			<CFSET Number_Of_Comms=getNewRule.Number_Of_Comms>
		</CFIF>
	<CFELSE>
		<CFSET Number_Of_Comms=Form.Number_Of_Comms>
	</CFIF>
	<cfparam name="Number_Of_Comms" 	default=0>

	<CFQUERY NAME="getCommData" datasource="#application.datasource#">
		SELECT *
		FROM Program_Formula_Pricing_Rule_Comm_Data
		WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND Deleted = 0
		AND Active = 1
		ORDER BY COMM_COUNT
	</CFQUERY>

	<CFLOOP QUERY="getCommData">
		<CFSET i = getCommData.Comm_Count>
		<CFSET "default_exch_#i#" 				= getCommData.exchange>
		<CFSET "default_comm_#i#" 				= getCommData.symbol>
		<CFSET "default_sample_size_#i#" 		= getCommData.sample_size>
		<CFSET "default_sample_size_uom_#i#" 	= getCommData.sample_size_uom>	
		<CFSET "default_sample_pit_#i#" 		= getCommData.Point_In_Time>
		<CFSET "default_sample_pit_uom_#i#" 	= getCommData.Point_In_Time_UOM>
		<CFSET "default_weight_#i#"			 	= getCommData.weight>		
	</CFLOOP>
	
	<CFQUERY NAME="getOverageData" datasource="#application.datasource#">
		SELECT *
		FROM Program_Formula_Pricing_Rule_Overage
		WHERE Program_Formula_Pricing_Rule_ID = '#Rule_ID#'
		AND Deleted = 0
		AND Active = 1
		Order By Overage_Index
	</CFQUERY>
	<CFLOOP QUERY="getOverageData" endrow="4">
		<CFSET i = getOverageData.Overage_Index>
		<CFSET "INDEPENDENT_DESC_CALC#i#_1" 				= getOverageData.Description>
		<CFSET "independent_amount_calc#i#_1" 				= getOverageData.Amount>
		<CFSET "independent_amount_uom#i#_1" 				= getOverageData.UOM>
	</CFLOOP>
		
</CFIF>


<CFSET StartIndex = getOverageData.recordcount+1>
<CFLOOP INDEX="i" FROM="#StartIndex#" TO="4" STEP="1">
	<CFSET "INDEPENDENT_DESC_CALC#i#_1" 				= "">
	<CFSET "independent_amount_calc#i#_1" 				= "">
	<CFSET "independent_amount_uom#i#_1" 				= "$">	
</CFLOOP>

<CFSET StartIndex = getCommData.recordcount+1>
<CFLOOP INDEX="i" FROM="#StartIndex#" TO="4" STEP="1">
	<CFSET "default_exch_#i#" 				= "">
	<CFSET "default_comm_#i#" 				= "">
	<CFSET "default_sample_size_#i#" 		= "">
	<CFSET "default_sample_size_uom_#i#" 	= "weeks">
	<CFSET "default_sample_pit_#i#" 		= "">
	<CFSET "default_sample_pit_uom_#i#" 	= "weeks">
	<CFSET "default_weight_#i#"			 	= "">
</CFLOOP>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the exchange & commodity data																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="get_data" datasource="#application.datasource#">
	Select		Commodities_Symbol.*,
				Commodities_Exchange_Detail.*
				
	From		Commodities_Symbol,
				Commodities_Exchange_Detail
				
	Where		Commodities_Symbol.Exchange_Detail_Abrev	=	Commodities_Exchange_Detail.Exchange_Detail_Abrev
	
	Order by	Commodities_Symbol.Exchange_Detail_Abrev, Commodities_Symbol.Symbol
</CFQUERY>

<CFSET PAGE_TITLE="Formula pricing Rule : Step 2">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT LANGUAGE="JavaScript">
	<!--- <CFINCLUDE TEMPLATE="/script/javascript/string_functions.js"> --->

	function initPage(){
		//CalculationsSelectIndex3(document.all.independent_desc_calc1_1)
		disableElements3(document.MyForm,true);
		setDefaultForExchangeAndSymbol();
		findselectboxes();
	}
	
/*****************************************************
Added by Deepa
*****************************************************/
<CFOUTPUT>
	function setDefaultForExchangeAndSymbol()
	{
		var activeCount = #getCommData.recordCount#;
		var comCount = #number_of_comms#;
		var maxCount = (comCount < activeCount)?comCount:activeCount;
		var i;
		
		<CFLOOP index="j" from="1" to="#getCommData.recordCount#">
			var defaulEx#j# = "#Evaluate("default_exch_#j#")#";
			var defaulComm#j# = "#Evaluate("default_comm_#j#")#";
		</CFLOOP>
		for(i=1;i<=maxCount;i++)
		{			
			setDefaultForSelect(eval("document.all.Exchange_" + i),eval("defaulEx" + i));
			eval("MyFormExchange_" + i + "ChangeMenu()");
			setDefaultForSelect(eval("document.all.Commodity_" + i),eval("defaulComm" + i));
		}
	}
	
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
		
	}
	
	function disableElements3(thisForm,bDis)
	{
		
		var bThisDis;
		var totalCommNo = 1;
		var selObj;
		var startIndex = 1;
		if(totalCommNo == 0)
			startIndex = 0;
		
		for(i=startIndex;i<=totalCommNo;i++)
		{	
			bThisDis = true;
			j=1;
			Obj1Name = "independent_desc_calc" + j + "_" + i;
			Obj2Name = "independent_amount_calc" + j + "_" + i;
			Obj3Name = "independent_amount_uom" + j + "_" + i;
			
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
				Obj1Name = "independent_desc_calc" + j + "_" + i;
				Obj2Name = "independent_amount_calc" + j + "_" + i;
				Obj3Name = "independent_amount_uom" + j + "_" + i;
				
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
	}
	</SCRIPT>	
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula"> 
<CFSET Help_URL="/help_files/manual/createprogram/page13.cfm##pr">
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">

<BLOCKQUOTE><BLOCKQUOTE>
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfinclude template="minimal_contract_info.cfm">
<BR>
<!------<CFIF FORM.UPDATE EQ 0>
	<FORM ACTION="Contract_Formula_Rule_Step_2_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<CFELSE>
	<FORM ACTION="Contract_Forumla_Confirm_Step_2.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
</CFIF>----->
<FORM ACTION="Contract_Formula_Rule_Step_2_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<CFLOOP INDEX="i" FROM="1" TO="#number_of_comms#" STEP="1">

<FIELDSET STYLE="padding:5px; width: 750px; border: 1px solid Silver;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Commodity <CFOUTPUT>#i# of #number_of_comms#</CFOUTPUT></LEGEND>
	<BR>
	<CFIF getCommData.recordcount GT 0 AND evaluate("default_exch_#i#") NEQ "" AND evaluate("default_comm_#i#") NEQ "">

	 	<CFQUERY NAME="getPreviousExchange" DBTYPE="query">
				SELECT Exchange_Detail_Name, Symbol_Description
				FROM get_data
				WHERE 
					Exchange_Detail_ID = #trim(evaluate("default_exch_#i#"))#
					AND
					SYMBOL = '#trim(evaluate("default_comm_#i#"))#'
		</CFQUERY>
	
		<TABLE>
			<CFOUTPUT>
			<TR>
				<TD ALIGN="right"><B>Current Exchange:</B></TD>
				<TD  STYLE="color: red;" VALIGN="bottom"><CFIF getPreviousExchange.recordcount GT 0><B>#getPreviousExchange.Exchange_Detail_Name#</B><CFELSE><B>SELECT ONE</B></CFIF></TD>
			</TR>
			<TR>
				<TD ALIGN="right"><B>Current Commodity:</B></TD>
				<TD STYLE="color: red;" VALIGN="bottom"><CFIF getPreviousExchange.recordcount GT 0><B>#getPreviousExchange.Symbol_Description#</B><CFELSE><B>SELECT ONE</B></CFIF></TD>
			</TR>
			<TR>
				<TD COLSPAN="100%" VALIGN="top">
					<HR>
				</TD>
			</TR>
			</CFOUTPUT>
		</TABLE>
	</CFIF>
<CFOUTPUT></CFOUTPUT>

	<CF_TwoSelectsRelated
		QUERY="get_data"
		NAME1="Exchange_#i#"
		NAME2="Commodity_#i#"
		ForceWidth1="275"
		ForceWidth2="275"
		DISPLAY1="Exchange_Detail_Name"
		DISPLAY2="Symbol_Description"
		VALUE1="Exchange_Detail_ID"
		VALUE2="Symbol"
		SIZE1="1"
		SIZE2="1"
		HTMLBETWEEN=""
		AUTOSELECTFIRST="Yes"
		FORMNAME="MyForm">
			
		<BR><BR>
		<CFOUTPUT><INPUT TYPE="HIDDEN" NAME="commoditySelection#i#" ID="commoditySelection#i#" VALUE=""></CFOUTPUT>
	
	<CFOUTPUT>	
	
	<TABLE CELLPADDING="5" CELLSPACING="5" BORDER="0">
		<TR>
			<TD>
				<span id="error_sample_size#i#"></span>&nbsp;Please enter how many periods you would like to select data for:<BR>
				<INPUT TYPE="Text" NAME="sample_size_#i#" SIZE="11" VALUE="#evaluate("default_sample_size_#i#")#" onKeyUp="clenseText(this, '0123456789');">
	<!--- 
				&nbsp;&nbsp;&nbsp;&nbsp;
				<INPUT TYPE="radio" NAME="Time_UOM_sample_size_#i#" VALUE="days" CHECKED>Days
	 --->
				
			</TD>
			<TD ROWSPAN="2" VALIGN="TOP">
				Period Definition:<br>
				<CFSET thisUOM=Evaluate("default_sample_size_uom_#i#")>
				<INPUT TYPE="radio" NAME="Period_UOM_#i#" VALUE="weeks"<CFIF thisUOM EQ "weeks"> CHECKED</CFIF>>Weeks
				<INPUT TYPE="radio" NAME="Period_UOM_#i#" VALUE="days"<CFIF thisUOM EQ "days"> CHECKED</CFIF>>Days
			</TD>
		</TR>
		<TR>
			<TD>
				<span id="error_point_in_time_#i#"></span>&nbsp;Please select how far back in time the sample window should be:<BR>
				<INPUT TYPE="Text" NAME="point_in_time_#i#" SIZE="11" VALUE="#evaluate("default_sample_pit_#i#")#" onKeyUp="clenseText(this, '0123456789');">
	<!--- 
				&nbsp;&nbsp;&nbsp;&nbsp;
				<INPUT TYPE="radio" NAME="Time_UOM_point_in_time_#i#" VALUE="days" CHECKED>Days
	 --->
				<!------&nbsp;&nbsp;&nbsp;&nbsp;
				<INPUT TYPE="radio" NAME="Time_UOM_point_in_time_#i#" VALUE="weeks" CHECKED>Weeks----->
			</TD>
		<CFIF Number_Of_Comms GT 1>
			<TR>
				<TD COLSPAN="100%">
					<span id="weight_#i#"></span>&nbsp;Please weight this commodity (0% - 100%) in relation to the others:&nbsp;<BR>
					<SPAN ID="weightSpan"><INPUT TYPE="text" NAME="Comm_weight_#i#" VALUE="#evaluate("default_weight_#i#")#" SIZE="1" MAXLENGTH="3" onKeyUp="clenseText(this, '0123456789');"></SPAN>%
				</TD>
			</TR>
		</CFIF>
		</TR>
	</TABLE>
	<CFIF Number_Of_Comms EQ 1>
		<INPUT TYPE="Hidden" NAME="Comm_weight_#i#" SIZE="11" VALUE="100">
	</CFIF>
	</CFOUTPUT>
</FIELDSET>
<BR><BR>
</CFLOOP>

<CFOUTPUT>
	<CFIF getCommData.recordcount GT 0>
		<CFSET FORM.Update = 1>
	<CFELSE>
		<CFSET FORM.Update = 0>
	</CFIF>
	<INPUT TYPE="hidden" NAME="Update" ID="Update" VALUE="#FORM.Update#">
	<!------<INPUT TYPE="hidden" NAME="Program_Formula_Pricing_Rule_ID" ID="Program_Formula_Pricing_Rule_ID" VALUE="#getNewRule.Program_Formula_Pricing_Rule_ID#">----->
	<INPUT TYPE="hidden" NAME="Program_Formula_Pricing_Rule_ID" ID="Program_Formula_Pricing_Rule_ID" VALUE="#Rule_ID#">	
	<INPUT TYPE="hidden" NAME="Number_Of_Comms" ID="Number_Of_Comms" VALUE="#Number_Of_Comms#">
	<INPUT TYPE="hidden" NAME="Program_ID" ID="Program_ID" VALUE="#URL.CID#">
</CFOUTPUT>

<BR>
<FIELDSET STYLE="padding:5px; width: 750px; border: 1px solid Silver;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Modifications</LEGEND>
	<BR>
	<TABLE WIDTH="330" BORDER="0" ALIGN="center">
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


<cf_MessageWindow>
<script>
	function validateData() {
		ErrorCount = 0;
		TotalWeight = 0;
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
		
			if(document.all.Comm_weight_#i#.value.length != 0){
				TotalWeight = TotalWeight + parseInt(document.all.Comm_weight_#i#.value);
			}
		</CFLOOP>
		</cfoutput>
		
	
		if(TotalWeight != 100){
			ErrorCount++
			queueMessage("The current commodity weight sum of " + TotalWeight + "% must equal 100%", document.all.weight_1);
		}		
		else {
			clearQueue(document.all.weight_1);
		}

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

<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

<script>
	initPage()
</script>

</BODY>
</HTML>
