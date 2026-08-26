<cfparam name="mt.status" default="0">
<cfparam name="mt.status_text" default="Off">
<cfparam name="mt.color" default="red">
<cfparam name="mt.color_checktext" default="green">
<cfparam name="costvariableslist" default="">
<cfparam name="costvariablesnames" default="">
<cfset maxCols = 2>

<!--- This file is also being used on "common_files\exportAll.cfm" for the CSV file generation. --->
<CFINCLUDE TEMPLATE="/settings/margin_targets/margin_target_queries.cfm">

<cfscript>
	function numberLengthFormat(number, length) {
		thisNumber 	= trim(number);
		tempNumber 	= "";
		thisLength 	= trim(length);
		returnValue = "";

		if(isnumeric(thisNumber) AND isnumeric(thisLength)) {
			neededZeros = thisLength - len(thisNumber);
			if(neededZeros LT 0) {
				returnValue = thisNumber;
			}
			else{
				tempNumber = thisNumber;
				for(loop=neededZeros; loop GT 0; loop=loop-1) {
					tempNumber = "0"&tempNumber;
				}
				return tempNumber;
			}
		}
		else {
			return thisNumber;
		}
	}
</cfscript>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<CFSET PAGE_TITLE="Attach Documents">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
</HEAD>

<BODY>
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<BR />

<cfset getUserName = createObject("component", "components.user.userManager").getUser('#getTargetStatus.PM_LastUpdated_UserId#')>

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style type="text/css">
	.datagrid TBODY TR.even {
		background-color: #eeffee
	}
	.globalvar{
		float:right;
		padding-top: 10px;
	}
	.exportData{
		float:left;
		padding-top: 5px;
		margin-left: 10px;
	}
</style>

<cfsavecontent variable="exportData">
	<b><font color="FF0000">[ </font></b><a href="javascript:exportAll();" id="exportData">export to csv</a><b><font color="FF0000">] </font></b>
</cfsavecontent>
<cfsavecontent variable="massApplyLinks">
<cfoutput>
	<table>
	<tr>
		<td><b>Global Target&nbsp;&nbsp;</b><input type="text" name="allRateBox" size="3" maxlength="7" id="allRateBox">
			<cfif appSettings.getApprovalMarginType() EQ 3>
				<cfquery name="getGlobalUOM" datasource="#application.datasource#">
					SELECT Global_Target_UOM
					FROM General_Settings
				</cfquery>
				<select name="Global_Target_UOM">
					<option value="1" <cfif getGlobalUOM.Global_Target_UOM EQ 1>selected</cfif>>CS</option>
					<option value="2" <cfif getGlobalUOM.Global_Target_UOM EQ 2>selected</cfif>>LB</option>
					<option value="3" <cfif getGlobalUOM.Global_Target_UOM EQ 3>selected</cfif>>Equiv Cs</option>
				</select>
			<cfelse>
				%
			</cfif>
			<b><font color="FF0000">[ </font></b><a style="cursor: pointer;" id="applyRateBox">Apply</a><b><font color="FF0000"> ] </font></b></td>
	<cfif appSettings.getApprovalStandardOn()>
		<td><b>Global Spend&nbsp;&nbsp;</b><input type="text" name="allSpendBox" size="3" maxlength="7" id="allSpendBox">$<b><font color="FF0000">[ </font></b><a style="cursor: pointer;">Apply</a><b><font color="FF0000"> ] </font></b></td>
	</cfif>
	<cfif appSettings.getApprovalMarginType() eq 2>
		<td><b>Global Rate&nbsp;&nbsp;</b><input type="text" name="allCaseRateBox" size="3" maxlength="7" id="allCaseRateBox">&nbsp;<select name="allCaseRateUOMBox"><option value="1" selected>CS</option><option value="2" >LB</option></select><b><font color="FF0000">[ </font></b><a style="cursor: pointer;">Apply</a><b><font color="FF0000"> ] </font></b></td>
	</cfif>
	<cfif listlen(costvariableslist) GT 0>
	<cfset recordCount = listlen(costvariablesnames)>
	<cfset currentRow = 1>
	<cfloop list="#costvariablesnames#" index = "list_name">
		<td><b>#Left(UCase( "#list_name#" ),1)##Right(LCase("#list_name#"), Len("#list_name#") - 1 )#&nbsp;&nbsp;</b>
			<input type="text" name="sequence#ListGetAt(costvariableslist, currentRow,",")#" style="border: 1 solid Silver;" size="3" maxlength="7" id="sequence#ListGetAt(costvariableslist, currentRow,",")#">
			<select name="sequence#ListGetAt(costvariableslist, currentRow,",")#_UOM" id="UOMsequence#ListGetAt(costvariableslist, currentRow,",")#"><option value="1">CS</option><option value="2">LB</option><option value="3">%</option></select>
			<b><font color="FF0000">[ </font></b><a style="cursor: pointer;" id="applySequence#ListGetAt(costvariableslist, currentRow,",")#">Apply</a><b><font color="FF0000"> ] </font></b>
		</td>
		<cfset currentRow = currentRow + 1>
	</cfloop>
	</cfif>

	</tr>
	</table>
</cfoutput>
</cfsavecontent>


<cfif appSettings.getApprovalMarginType() NEQ 3>
    <cfset UOMdisplay = '%'>
<cfelse>
    <cfif getGlobalUOM.Global_Target_UOM EQ 1>    
        <cfset UOMdisplay = 'Per CS'>
    <cfelseif getGlobalUOM.Global_Target_UOM EQ 2>    
        <cfset UOMdisplay = 'Per LB'>
    <cfelseif getGlobalUOM.Global_Target_UOM EQ 3>
        <cfset UOMdisplay = 'Equiv Cs'>
    <cfelse>
        <cfset UOMdisplay = 'Per CS'>
    </cfif>
</cfif>  
        
    
<form action="margin_target_action.cfm" method="post" name="myForm" id="myForm">

<cfoutput>
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0" width="800" align="center">
	<TR><TD><FONT SIZE="2"><B>This setting was last updated on 	#dateformat(getTargetStatus.PM_LastUpdated_Date, 'm/d/yyy')# #timeformat(getTargetStatus.PM_LastUpdated_Date, 'h:mm:ss TT')# by #getUserName.User_Full_Name#</B></FONT>	</TD></TR>
</TABLE>

<div align="center" style="font-weight: bold; font-size: 15px; color: <cfoutput>#mt.color#</cfoutput>">
	margin targets are currently: #ucase(mt.status_text)#
</div>
<hr width="800" color="navy" size="2">
<div align="center">
	<input type="Checkbox" name="mt_status" <cfif lcase(mt.status) EQ 1>CHECKED</cfif>>
	<span style="font-weight: bold; font-size: 12px; color: #mt.color_checktext#;">
	<cfif lcase(mt.status) eq 0>
		check here to enable them
	<cfelse>
		uncheck here to disable them
	</cfif>
	</span>
</div>
</cfoutput>

<table class="datagrid">
  <thead>
    <th style="width:10 px;"><input type="checkbox" name="CheckAll" onClick="javaScript: selectAll(this, 'checkAllProducts');"></th>
    <th class="header"><cfoutput>#approvalGroupType.Label#</cfoutput></th>
    <th class="header"><input type="checkbox" name="Margin">Margin <cfoutput>#UOMdisplay#</cfoutput> - Dist Progs</th>
    <th class="header"><input type="checkbox" name="MarginOpr">Margin <cfoutput>#UOMdisplay#</cfoutput> - Oper Progs</th>
		<th class="header"><input type="checkbox" name="ListPrice">% of List Price</th>
<cfif appSettings.getApprovalStandardOn()>
    <th class="header">$ Spend</th>
</cfif>
<cfif appSettings.getApprovalMarginType() eq 2>
    <th class="header">Rate</th>
</cfif>
<cfif listlen(costvariableslist) GT 0>
	<cfloop query="getcostvariables">
	<th class="header"><cfoutput>#cost_sequence_name#</cfoutput></th>
	</cfloop>
</cfif>
</thead>
<tbody>
<cfoutput query="getAllCodes">
	<cfset target_input_name = "target_" & replace(getAllCodes.ID, "-", "_", "ALL")>
	<cfset target_Opr_input_name = "opr_target_" & replace(getAllCodes.ID, "-", "_", "ALL")>
	<cfset spend_input_name = "spend_" & replace(getAllCodes.ID, "-", "_", "ALL")>
	<cfset target_rate_input_name = "case_rate_" & replace(getAllCodes.ID, "-", "_", "ALL")>
	<cfset target_rate_uom_input_name = "case_rate_uom_" & replace(getAllCodes.ID, "-", "_", "ALL")>
	<cfset target_list_price_name = "list_price_" & replace(getAllCodes.ID, "-", "_", "ALL")>
	<cfset G_id = getAllCodes.ID>

<tr>
	<td>
		<input id="checkAllProducts" type="Checkbox" name="checkAllProducts">
	</td>
	<td valign="middle">#getAllCodes.Name#</td>
	<td>
		<span id="codetargetspan">
		<input type="text" name="#target_input_name#" value="#trim(numberformat(getAllCodes.Target_Margin, '_-___.____'))#" style="border: 1 solid Silver;" size="3" maxlength="7" onKeyUp="clenseText(this, '0123456789-.'); applyNumericCeiling(this); limitXdecimalplaces(4, this);">
		</span><cfif appSettings.getApprovalMarginType() NEQ 3>%</cfif>
	</td>
	<td>
		<span id="codetargetoprspan">
		<input type="text" name="#target_opr_input_name#" value="#trim(numberformat(getAllCodes.Target_Margin_Operator, '_-___.____'))#" style="border: 1 solid Silver;" size="3" maxlength="7" onKeyUp="clenseText(this, '0123456789-.'); applyNumericCeiling(this); limitXdecimalplaces(4, this);">
		</span><cfif appSettings.getApprovalMarginType() NEQ 3>%</cfif>
	</td>
	<td>
		<span id="codetargetlpspan">
		<input type="text" name="#target_list_price_name#" value="#trim(numberformat(getAllCodes.Target_Margin_ListPrice, '_-___.____'))#" style="border: 1 solid Silver;" size="3" maxlength="7" onKeyUp="clenseText(this, '0123456789-.'); applyNumericCeiling(this); limitXdecimalplaces(4, this);">
		</span>%
	</td>	
	<cfif appSettings.getApprovalStandardOn()>
	<td>
		<span id="codespendspan">
		<input type="text" name="#spend_input_name#" value="#trim(numberformat(getAllCodes.spend_dollar, '_-___.____'))#" style="border: 1 solid Silver;" size="3" maxlength="7" onKeyUp="clenseText(this, '0123456789.'); applyNumericCeiling(this); limitXdecimalplaces(4, this);">
		</span> $
	</td>
	</cfif>
	<cfif appSettings.getApprovalMarginType() eq 2>
	<td>
		<span id="codetargetcaserate">
		<input type="text" name="#target_rate_input_name#" value="#trim(numberformat(getAllCodes.Target_Case_Rate, '_-___.__'))#" style="border: 1 solid Silver;" size="3" maxlength="7" onKeyUp="clenseText(this, '0123456789.'); applyNumericCeiling(this); limitXdecimalplaces(2, this);">
		</span>&nbsp;
		<span id="codetargetcaserateuom">
		<select name="#target_rate_uom_input_name#">
			<option value="1" <cfif getAllCodes.Target_Case_Rate_UOM EQ 1> selected</cfif>>CS</option>
			<option value="2" <cfif getAllCodes.Target_Case_Rate_UOM EQ 2> selected</cfif>>LB</option>
		</select>
		</span>
	</td>
	</cfif>
	<cfif listlen(costvariableslist) GT 0>
	<cfloop list="#costvariableslist#" index = "cost_id">
	<cfset id_rate = "getAllCodes.cost"&"#cost_id#"&"_rate">
	<cfset id_uom = "getAllCodes.cost"&"#cost_id#"&"_uom">
	<cfset cost_input_name = "#cost_id#" & "_" & #replace(G_id, "-", "_", "ALL")#>
	<td>
		<span id="span#cost_id#">
		<input type="text" name="#cost_input_name#" value="#evaluate(id_rate)#" style="border: 1 solid Silver;" size="3" maxlength="7" onKeyUp="clenseText(this, '0123456789.'); applyNumericCeiling(this); limitXdecimalplaces(4, this);">
		</span>
		<span id="span#cost_id#_uom">
		<select name="#cost_input_name#_UOM">
			<option value="1" <cfif #evaluate(id_uom)# EQ 1> selected</cfif>>CS</option>
			<option value="2"  <cfif #evaluate(id_uom)# EQ 2> selected</cfif>>LB</option>
			<option value="3"  <cfif #evaluate(id_uom)# EQ 3> selected</cfif>>%</option>
		</select>
		</span>
	</td>
	</cfloop>
	</cfif>
</tr>
</cfoutput>
</tbody>
</table>
</form>
<div align="center" style="padding-top: 10px">
	<a id="formSubmit" style="cursor: hand;"><cfoutput>#application.util.string.actionLinkFormat2("save")#</cfoutput></a></td>
</div>
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script src="/Script/javascript/dhtml.js"></script>

<script>
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
oTable = $('.datagrid').dataTable( {
	"bAutoWidth": true
	,"bPaginate": false
	,"bSortClasses": false
	,"sDom": "f<'exportData'><'globalvar'>t"
	,"sScrollY": sScrollY
    	,"aoColumns": [
    					{"bSearchable": false,  	"bSortable":false}
	                    ,	{"bSearchable": true, 	"bSortable":true}
	                    ,	{"bSearchable": true, 	"bSortable":false}
	                    ,	{"bSearchable": true, 	"bSortable":false}
											,	{"bSearchable": true, 	"bSortable":false}
	                    <cfif appSettings.getApprovalStandardOn()>
	                    ,	{"bSearchable": true, 	"bSortable":false}
	                    </cfif>
	                    <cfif appSettings.getApprovalMarginType() eq 2>
	                    ,	{"bSearchable": true, 	"bSortable":false}
	                    </cfif>
	                    <cfif listlen(costvariableslist) GT 0>
				<cfloop query="getcostvariables">
	                    ,	{"bSearchable": true, 	"bSortable":false}
				</cfloop>
				</cfif>
	                 ]
  }).fnSetFilteringDelay();
//hovering background color switching
$('table.datagrid tbody').on('hover', 'tr', function() {
	$(this).toggleClass("over");
});
<cfoutput>
$('div.exportData').html('#application.util.string.compress(exportData)#');
$('div.globalvar').html('#application.util.string.compress(massApplyLinks)#');
<cfset currentRow = 1>
<cfloop list="#costvariablesnames#" index = "list_name">
$( "##sequence#ListGetAt(costvariableslist, currentRow,",")#").keyup(function() {
	clenseText(this, '0123456789.-');
	limitXdecimalplaces(4, this);
});

$( "##applySequence#ListGetAt(costvariableslist, currentRow,",")#").click(function() {
	applyAll($("##sequence#ListGetAt(costvariableslist, currentRow,",")#" ).val(),'C',#ListGetAt(costvariableslist, currentRow,",")#);
	applyAll($("##UOMsequence#ListGetAt(costvariableslist, currentRow,",")# option:selected" ).val(),'U',#ListGetAt(costvariableslist, currentRow,",")#);
});
<cfset currentRow = currentRow + 1>
</cfloop>
</cfoutput>
$( "#allRateBox, #allSpendBox, #allCaseRateBox" ).keyup(function() {
	clenseText(this, '0123456789.-');
	limitXdecimalplaces(4, this);
});

$( "#applyRateBox" ).click(function() {
 	applyAll($("#allRateBox" ).val(),'T','');
});

$( "#allSpendBox" ).click(function() {
 	applyAll($("#allSpendBox" ).val(),'S','');
});

$( "#allCaseRateBox" ).click(function() {
 	applyAll($("#allCaseRateBox" ).val(),'TARGET_RATE','');
});

$( "#formSubmit" ).click(function() {
  $( "#myForm" ).submit();
});

function selectAll(thisObj, objToChk){
	var chObjs = eval("document.all." + objToChk);
	var bCheck = thisObj.checked;
	var i;
	if(chObjs){
		if(chObjs.length){
			for(i=0;i<chObjs.length;i++){
				chObjs[i].checked = bCheck;
			}
		}
		else{
			chObjs.checked = bCheck;
		}
	}
}

function applyAll(oRate,type,order_id) {
	//var groupchecked = false;
	allRate = oRate;
	if (type == "T"){
		if(document.all.checkAllProducts != null) {
			if(document.all.checkAllProducts.length != null) {
				for(var x=0; x<document.all.checkAllProducts.length;x++) {
					if(document.all.checkAllProducts[x].checked == true) {
						if(document.all.Margin.checked == true){
							getFirstChild(document.all.codetargetspan[x]).value = allRate;
						}
						if(document.all.MarginOpr.checked == true){
							getFirstChild(document.all.codetargetoprspan[x]).value = allRate;
						}
						if(document.all.ListPrice.checked == true){
							getFirstChild(document.all.codetargetlpspan[x]).value = allRate;
						}
						//groupchecked = true;
					}
				}
			}
			else {
					if(document.all.checkAllProducts.checked == true) {
						if(document.all.Margin.checked == true){
							getFirstChild(document.all.codetargetspan[x]).value = allRate;
						}
						if(document.all.MarginOpr.checked == true){
							getFirstChild(document.all.codetargetoprspan[x]).value = allRate;
						}
						if(document.all.ListPrice.checked == true){
							getFirstChild(document.all.codetargetlpspan[x]).value = allRate;
						}					
						//groupchecked = true;
					}
			}
		}
	}
	else if (type == "S"){
		if(document.all.checkAllProducts != null) {
			if(document.all.checkAllProducts.length != null) {
				for(var x=0; x<document.all.checkAllProducts.length;x++) {
					if(document.all.checkAllProducts[x].checked == true) {
						if(document.all.Margin.checked == true){
							getFirstChild(document.all.codetargetspan[x]).value = allRate;
						}
						if(document.all.MarginOpr.checked == true){
							getFirstChild(document.all.codetargetoprspan[x]).value = allRate;
						}
						if(document.all.ListPrice.checked == true){
							getFirstChild(document.all.codetargetlpspan[x]).value = allRate;
						}	
						//groupchecked = true;
					}
				}
			}
			else {
					if(document.all.checkAllProducts.checked == true) {
						if(document.all.Margin.checked == true){
							getFirstChild(document.all.codetargetspan[x]).value = allRate;
						}
						if(document.all.MarginOpr.checked == true){
							getFirstChild(document.all.codetargetoprspan[x]).value = allRate;
						}
						if(document.all.ListPrice.checked == true){
							getFirstChild(document.all.codetargetlpspan[x]).value = allRate;
						}						
						//groupchecked = true;
					}
			}
		}
	}
	else if (type == "TARGET_RATE"){
		if(document.all.checkAllProducts != null) {
			if(document.all.checkAllProducts.length != null) {
				for(var x=0; x<document.all.checkAllProducts.length;x++) {
					if(document.all.checkAllProducts[x].checked == true) {
						getFirstChild(document.all.codetargetcaserate[x]).value = allRate;
						//groupchecked = true;
					}
				}
			}
			else {
					if(document.all.checkAllProducts.checked == true) {
						getFirstChild(document.all.codetargetcaserate).value = allRate;
						//groupchecked = true;
					}
			}
		}
	}//TARGET_RATE
	else if (type == "TARGET_RATE_UOM")
	{

		if(document.all.checkAllProducts != null) {
			if(document.all.checkAllProducts.length != null) {
				for(var x=0; x<document.all.checkAllProducts.length;x++) {
					if(document.all.checkAllProducts[x].checked == true) {
						getFirstChild(document.all.codetargetcaserateuom[x]).value = allRate;
						//groupchecked = true;
					}
				}
			}
			else {
					if(document.all.checkAllProducts.checked == true) {
						getFirstChild(document.all.codetargetcaserateuom).value = allRate;
						//groupchecked = true;
					}
			}
		}
	}//TARGET_RATE_UOM
	else if (type == "C" || type == "U")
	{
		if(type == "C"){
			var rate = allRate;
		}
		if(type == "U"){
			var uom = allRate;
		}
		if ((rate != "" && type == "C") || (type == "U")){
			if(type == "C"){
				var sequence = "span" + order_id;
			}
			if(type == "U"){
				var sequence = "span" + order_id + "_uom";
			}

			if(document.all.checkAllProducts != null) {
				if(document.all.checkAllProducts.length != null) {
					for(var x=0; x<document.all.checkAllProducts.length;x++) {
						if(document.all.checkAllProducts[x].checked == true) {
							var objFirstChild = eval("getFirstChild(document.all." + sequence + "[x])");
							objFirstChild.value = allRate;
						}
					}
				}
				else {
						if(document.all.checkAllProducts.checked == true) {
							var objFirstChild1 = eval("getFirstChild(document.all." + sequence + ")");
							objFirstChild1.value = allRate;

						}
				}
			}
		}
	}
}

function applyNumericCeiling(oInputBox) {
	if(oInputBox > 100) {
		oInputBox.value = 100;
	}
}

exportAll = function() {
	window.open( "/Common_Files/exportAll.cfm?" + "type=getMarginTargetsData"+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('margin_targets_')#</cfoutput>"
		,"_blank","toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
}
</script>

</BODY>
</HTML>