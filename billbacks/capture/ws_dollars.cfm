<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<CfSet TabInd = 0>
<!---Worksheet that allows user to have "components"--->
<cfif isDefined("blnSubmit")>


<cfset TotalDollar = 0>

<cfset Counter = replace(Counter, ",", "", "all")>
<Cfset Counter = len(Counter)>
<cfset ImageName = form.Image>
	
	<cfquery name="GetCurrentEntries" datasource="#application.datasource#">
	SELECT * FROM
	BB_Worksheet_Dollars
	WHERE Billback_ID = '#Billback_ID#'
	AND Program_ID = #Program_ID#
	AND Product_ID = '#Product_ID#'
	AND Discount_Type = #Discount_Type#
	<cfif trim(customer_id) neq "">And Customer_ID = '#Customer_ID#'</cfif>
	</cfquery>
	
	<cfif GetCurrentEntries.Recordcount GT 0>
	<cfloop query="GetCurrentEntries">
	
	<cfset Worksheet_ID = replace(GetCurrentEntries.BB_WS_Dollars_ID, "-", "_", "all")>
	
		<cfif isdefined("Form.Dollar_#Worksheet_ID#")>
			<cfset F.Dollar_Amount = Evaluate("Form.Dollar_#Worksheet_ID#")>
		<cfelse>
			<cfset F.Dollar_Amount = 0>
	 	</cfif>
			
		<cfset F.isDeleted = Evaluate("Form.isDeleted_#Worksheet_ID#")>
		
		<cfif len(trim(F.Dollar_Amount)) IS 0>
			<cfset F.Dollar_Amount = 0>
		</cfif>

			
		<cfif  (F.Dollar_Amount NEQ 0) AND F.isDeleted NEQ 1>
			<cfquery name="UpdateRecord" datasource="#application.datasource#">
			UPDATE BB_Worksheet_Dollars
			SET 
			Billback_ID = '#Form.Billback_ID#',
			Program_ID = #Form.Program_ID#,
			Product_ID = '#Form.Product_ID#',
			Discount_Type = #Form.Discount_Type#,
			Dollar_Amount = #F.Dollar_Amount#
			<cfif trim(customer_id) neq "">, Customer_ID = '#Customer_ID#'</cfif>
			WHERE BB_WS_Dollars_ID = '#GetCurrentEntries.BB_WS_Dollars_ID#'
			</cfquery>
		
		<cfelse>
			<cfquery name="DeleteRecord" datasource="#application.datasource#">
			DELETE FROM BB_Worksheet_Dollars
			WHERE BB_WS_Dollars_ID = '#GetCurrentEntries.BB_WS_Dollars_ID#'
				<cfif trim(customer_id) neq "">And Customer_ID = '#Customer_ID#'</cfif>
			</cfquery>
		</cfif>
	</cfloop>
	</cfif>
	
	<cfloop index = "Loopindex" from = "1" to = "#counter#" step = "1">
		<cfoutput>
		
		<cfset Dollar_Amount = Evaluate("Form.Dollar_#LoopIndex#")>
		<cfset isDeleted = Evaluate("Form.isDeleted_#LoopIndex#")>
		<cfif len(trim(Dollar_Amount)) IS 0>
			<cfset Dollar_Amount = 0>
		</cfif>
				
		</cfoutput>
		
		<cfif isDeleted NEQ 1> <!--- (Dollar_Amount NEQ 0) AND --->
		<cfquery name="InsertRecord" datasource="#application.datasource#">
		INSERT INTO BB_Worksheet_Dollars
		(		
		Billback_ID,
		Program_ID,
		Product_ID,
		Discount_Type,
		Dollar_Amount
		<cfif trim(customer_id) neq "">, Customer_ID</cfif>
		)
		VALUES
		(
		'#Billback_ID#',
		#Program_ID#,
		'#Product_ID#',
		#Discount_Type#,
		#Dollar_Amount#
		<cfif trim(customer_id) neq "">, '#Customer_ID#'</cfif>
		)
		</cfquery>
		</cfif>
	
	</cfloop>
	
	<!---Check to see if there are any prior ones to display--->
	<cfquery name="Prior_Entries" datasource="#application.datasource#">
	SELECT Sum(Dollar_Amount) as TotalDollars FROM
	BB_Worksheet_Dollars
	WHERE Billback_ID = '#Billback_ID#'
	AND Program_ID = #Program_ID#
	AND Product_ID = '#Product_ID#'
	AND Discount_Type = #Discount_Type#
	<cfif trim(customer_id) neq "">And Customer_ID = '#Customer_ID#'</cfif>
	</cfquery>
	
	
	<cfif Prior_Entries.RecordCount GT 0 AND isnumeric(Prior_Entries.TotalDollars)>
		<cfif AutoBB EQ 1 and Discount_Type EQ 10><!--- If autoBB and it is a claim adjustment...total the ws claim dollars and subtract from total (passed in) of the other Discount types for this prod. --->
			<cfset TotalDollars = Prior_Entries.TotalDollars - Tot>
		<cfelse>
			<cfset TotalDollars = Prior_Entries.TotalDollars>
		</cfif>	
	<cfelse>
			<cfset TotalDollars = 0>
	</cfif>
	
	
	<script>
			function ReturnValue(formname, formfield, entryvalue, image_name)
		{	
			var oOpener = window.opener;
			if (oOpener)
			{	
				var formObj = eval("oOpener.document." + formname);
				if (formObj)
				{
					var inpObj = eval("formObj." + formfield);
					if (inpObj)
					{	
						oOpener.changeWorksheetImage(image_name);
						inpObj.value = entryvalue;
						inpObj.focus();
					
					}
				}
			}
		}
		
		<cfoutput>
				ReturnValue("#ParentFormName#", "#FieldtoFill#", #TotalDollars#, "#ImageName#");
		</cfoutput>
		
		window.close();
	</script>
	
	<cfabort>
	
<cfelse>
<cfparam name="AutoBB" default="0">
<cfparam name="Tot" default="0">
<cfparam name="Customer_ID" default="">
	<!---Check to see if there are any prior ones to display--->
	<cfquery name="Prior_Entries" datasource="#application.datasource#">
	SELECT * FROM
	BB_Worksheet_Dollars
	WHERE Billback_ID = '#Billback_ID#'
	AND Program_ID = #Program_ID#
	AND Product_ID = '#Product_ID#'
	AND Discount_Type = #Discount_Type#
	<cfif trim(customer_id) neq "">And Customer_ID = '#Customer_ID#'</cfif>
	</cfquery>
	
	<!---Product information--->
	<cfquery name="Product_Info" datasource="#application.datasource#">
	SELECT cast(Net_Weight as float) as Net_Weight, Net_Weight as Weight, Item, Description
	FROM BSA_Foodservice_Items_Master
	WHERE BSA_Foodservice_Items_Master_ID = '#Product_ID#'
	</cfquery>
	<title>Worksheet -- Dollars</title>
	</head>

<body onload="document.WSDollars.Dollar_1.focus()">
	<table border="0" cellpadding="2" cellspacing="0" width="90%">
	<form action="ws_dollars.cfm" method="post" name="WSDollars">
	<input type="hidden" name="blnSubmit" value="1">
	<cfoutput>
		<input type="hidden" name="AutoBB" value="#AutoBB#">
		<input type="hidden" name="Tot" value="#Tot#">
		<input type="hidden" name="Customer_ID" value="#Customer_ID#">
	</cfoutput>
	<tr>
		<td>
			<strong>
			<cfoutput>#application.returned_customer_setting.item_label#:&nbsp; <br>
			#application.returned_customer_setting.item_label# Number:&nbsp; &nbsp; <br></cfoutput>
			Discount Type: &nbsp; &nbsp; 
			</strong>
		</td>
		<td colspan="3">
		<cfoutput>
			#trim(Product_Info.Description)#<br>
			#Product_Info.Item#<br>
			<cfif Discount_Type IS 1>
			Fixed Price
			<cfelseif Discount_Type IS 2>
			#Application.RebateLabel#
			<cfelseif Discount_Type IS 4>
			Growth
			<cfelseif Discount_Type IS 5>
			Formula
			<cfelseif Discount_Type IS 10>
			Claim Adjustment
			</cfif>
		</cfoutput>
		</td>
	</tr>

	<tr><td colspan="4"><hr width="100%" color="orange"></td></tr>
		<!--- <map name="tabMap"><area tabindex="20" coords="0,0,23,23"></map> --->
	<tr>
		<td bgcolor="#CCFFCC" style="border-bottom:solid #CCFFCC 2px; font-size : 12px; font-decoration: bold;">&nbsp; &nbsp; <strong>Dollar Amount</strong></td>
			<td bgcolor="#CCFFCC" style="border-bottom:solid #CCFFCC 2px; font-size : 12px;" align="right">		
		<img src="../../Images/plus4.gif" width="13"  style="cursor: pointer;" height="13" title="add row" border="0" onclick="addPeriod();" usemap="#tabMap">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</td>
	</tr>
	
	</table>

	<cfset Total_Dollars = 0>
	
	<cfif Prior_Entries.Recordcount GT 0>
		
		<cfoutput query="Prior_Entries">
		<cfset Worksheet_ID = Replace(BB_WS_Dollars_ID, "-", "_", "all")>
		<CfSet TabInd = (Prior_Entries.currentRow + 1)>
		<table border="0" cellpadding="0" cellspacing="0" width="90%" class="Maintable">
					
			<tr id="ThisRow" rowName="Row_#Worksheet_ID#">
				<td><input type="text" size="10" previous_value="#Dollar_Amount#" name="Dollar_#Worksheet_ID#" value="#Dollar_Amount#" onKeyUp="clenseText(this, '0123456789.');" onChange="adjust_Dollar_Amount(this)" tabindex="#TabInd#"></td>
										
		<td align="center">
		&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
		<input type="hidden" name="isDeleted_#Worksheet_ID#" value="0">
		<img id="theImage" style="cursor: pointer;" onclick="deleteRecord(this);" src="../../Images/scissor.gif" width="14" height="9" title="Remove entry" border="0"></td>
			
			</tr>	

			<Cfset Total_Dollars = Total_Dollars + Dollar_Amount>
		</cfoutput>
	</table>
	</cfif>
	
	<table id="thisTable" border="0" cellpadding="0" cellspacing="0" width="90%" class="Maintable">
	<cfoutput>
	<CfSet TabInd = (TabInd + 1)>
	<tr id="ThisRow" rowName="Row_1">
		<td><input type="text" size="10" name="Dollar_1" value="" previous_value="0" onKeyUp="clenseText(this, '0123456789.-');" onChange="adjust_Dollar_Amount(this);" onload="this.focus();" tabindex="#TabInd#" <!--- onBlur="addPeriod();" --->></td>
			
		<td align="center">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
		<input type="hidden" name="counter" value="1">
		<input type="hidden" name="isDeleted_1" value="0">
		<img id="theImage"  style="cursor: pointer;" onclick="deleteRecord(this);" src="../../Images/scissor.gif" width="14" height="9" title="Remove entry" border="0"></td>
	</tr>	
	</cfoutput>
	</table>
	<cfoutput>
		<input type="hidden" name="Program_ID" value="#Program_ID#">
		<input type="hidden" name="Billback_ID" value="#Billback_ID#">
		<input type="hidden" name="Product_ID" value="#Product_ID#">
		<input type="hidden" name="Discount_Type" value="#Discount_Type#">
		<input type="hidden" name="FieldtoFill" value="#FieldtoFill#">
		<input type="hidden" name="ParentFormName" value="#ParentFormName#">
		<input type="hidden" name="Image" value="#Image#">

	</cfoutput>
	<table border="0" width="90%">
	<cfoutput><tr>
		<td>&nbsp; &nbsp; <strong>Total:</strong> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  </td>
		<Td>$<strong><span id="Total_Dollars" total_value="#Total_Dollars#">#Total_Dollars#</span></strong></TD>
	</tr></cfoutput>
	<tr>
		<td colspan="2" align="right">	
		<Br>
		<cfoutput>
		<CfSet TabInd = (TabInd + 1)>
		<CF_button
			button_name		=	""
			button_caption	=	"save"
			button_action	=	"document.WSDollars.submit();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Save the contents of this worksheet"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			TabInd		=	"#TabInd#"
		>		</td>
	</tr>
	</table>
	 <CfSet TabInd = (TabInd + 1)>
	<map name="tabMap"><area tabindex="#TabInd#" coords="0,0,20,20"></map>
	</cfoutput>
</form>
</cfif>

<!---Javascript stuff--->
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js, /Script/javascript/string_functions.js">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/format_functions.js, /Common_Files/Delete_Functions.js">

<script>
		 function addPeriod()
		{	
			//var srcObj = event.srcElement;
			//var tabObj = getParentObject(srcObj, "table");
			var tabObj = document.all.thisTable;
			
			//var trObj = getParentObject(srcObj, "tr");
			var lastIndex = tabObj.rows.length - 1;
			//alert(lastIndex);
			addFilterRows(tabObj, tabObj.rows[lastIndex], lastIndex, lastIndex + 2);				
				
		}
		
		function incrementName(checkHTML, replaceNumber, srcIndex)
	 	{
	  		var regExp = new RegExp("((name|id)=.*?_(.*?))[\"\\s>]", "igm");
	  		var arr = checkHTML.match(regExp);
	  		var i;
	  		var newHTML = checkHTML;
			if (arr)
			{
				for(i=0;i<arr.length;i++)
	  			{
	   				var idField = arr[i];
	   				var arr2 = /_([^_]*?)$/.exec(idField);
	   				var indexNumber = RegExp.$1;
	   
	   				newIndexNumber = replaceNumber;
	   				//newIndexNumber = parseFloat(indexNumber);
	   				if(!isNaN(newIndexNumber))
	   				{
	    				//newIndexNumber = newIndexNumber + 1;						
	    				var regExp = new RegExp("_" + indexNumber, "igm");
	    				newIDField = idField.replace(regExp, "_" + newIndexNumber + idField.substr(idField.length-1));
	    				var regExp = new RegExp(idField, "igm");
	    				var newHTML = newHTML.replace(regExp, newIDField); 
	   				}  
				} 
	  		}
			var regExp = new RegExp("Volume_" + srcIndex, "igm");			
	 		var newHTML = newHTML.replace(regExp, "Volume_" + replaceNumber); 
			return newHTML;
	 	}
		
		
		function addFilterRows(pObj, trObj, trIndex, srcIndex)
	    {	
			var rObj = pObj.insertRow(trIndex+1);			
		 	var coLen = trObj.cells.length;
		 	for (i=0;i<coLen;i++)
		 	{
				var cObj = rObj.insertCell(i);
				if (trObj.cells[i].align)
				{
					cObj.align = trObj.cells[i].align;
				}
						
	     		cObj.innerHTML = incrementName(trObj.cells(i).innerHTML, trIndex + 2, srcIndex);	
				
				var inputCol = cObj.getElementsByTagName("input");
				for (j=0;j<inputCol.length;j++)
				{
					if (inputCol[j].type == "text")
					{
						inputCol[j].value = "";
						inputCol[j].readOnly = false;
						inputCol[j].focus();
						if (inputCol[j].previous_value)
						{
							inputCol[j].previous_value = 0;
						}
					}
					
					if (inputCol[j].type == "checkbox")
					{
						inputCol[j].checked = true;
					}
				}
				
				var inputCol = cObj.getElementsByTagName("select");
				for (j=0;j<inputCol.length;j++)
				{
					inputCol[j].selectedIndex = 0;
				}
				
				var inputCol = cObj.getElementsByTagName("div");
				for (j=0;j<inputCol.length;j++)
				{
					inputCol[j].innerText = "";					
				}									
		 	}	
			rObj.all.theImage.title = "delete record";
			rObj.all.theImage.src = deleteImg.src;
			propogateProperty(rObj, "style.backgroundColor", "#ffffff", false);
			propogateProperty(rObj, "style.textDecoration", "none", false);	
		}

	function deleteRecord(thisObj)
	{
		var srcObj = event.srcElement;
		var trObj = getParentObject(srcObj, "tr");	
		var trIndex = trObj.rowIndex;	
		
					
		var objDollars = getInputObject(trObj.cells[0])
		var objDeleted = eval("document.all.isDeleted_" + find_counter(objDollars.name));
		
		var bDelete = false;
		if(objDeleted.value == 1)
		{
			propogateProperty(trObj, "style.backgroundColor", "#ffffff", false);
			propogateProperty(trObj, "style.textDecoration", "none", false);	
			
			objDollars.readOnly = false;
			objDeleted.value = 0;
			
			thisObj.title = "delete record";
			thisObj.src = deleteImg.src;
		}
		else
		{
			bDelete = true;
			propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
			propogateProperty(trObj, "style.textDecoration", "line-through", false);	

			objDollars.readOnly = true;
		
			objDeleted.value = 1;
			//propogateProperty(trObj.cells[trObj.cells.length - 1], "style.backgroundColor", "#ffffff", false);
			
			thisObj.title = "undo record deletion";
			thisObj.src = undodeleteImg.src;
		}		
		
		adjust_Amount(objDollars,document.all.Total_Dollars,bDelete)	
				
	}
	
	function getInputObject(oCell)
	{
		var inpObjs = oCell.getElementsByTagName("INPUT");
		var i, inpLen;
		inpLen = inpObjs.length;
		for(i=0;i<inpLen;i++)
		{
			if(inpObjs[i].type == "text")
			{
				return inpObjs[i];
			}
		}
		
	}

	function find_counter(sname)
	{	
		var arName = sname.split("_");
		arName.splice(0,1);
		return arName.join("_");		
		
	}
	
	
	function adjust_Amount(thisObj,totObj,isDelete)
	{	
		var bDelete = false;
		if(isDelete)
		{
			bDelete = isDelete;
		}		
		var prevTotal =  parseFloat(totObj.total_value);
		prevTotal = parseFloat(prevTotal);
		var thisVal = formatToDecimalPlaces(thisObj.value, 2);
		if(bDelete)
		{
			thisVal = 0;
		}
		
		var curTotal = prevTotal - parseFloat(thisObj.previous_value) + parseFloat(thisVal);
		totObj.innerText = formatWithComma(curTotal, 3);
		totObj.total_value = curTotal;
		thisObj.previous_value = thisVal;
	}
	
	function adjust_Dollar_Amount(thisObj)
	{	
		var totObj = document.all.Total_Dollars;
		var prevTotal =  parseFloat(totObj.total_value);
		prevTotal = parseFloat(prevTotal)
		var curTotal = prevTotal - parseFloat(thisObj.previous_value) + parseFloat(thisObj.value);
		totObj.innerText = formatWithComma(curTotal, 3);
		totObj.total_value = curTotal;
		thisObj.previous_value = thisObj.value;
	}
		
</script>

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}


.normal
{
	font-family : Arial;
	font-size : 8pt;
	color : Black;
}


A, A:LINK, A:VISITED 
{
	color : Blue;
	text-decoration : none;
}

A:FOCUS,A:HOVER 
{
	color : Red;
	text-decoration : underline;
}

A.bold, A.bold:LINK, A.bold:VISITED 
{
	color : Blue;
	font-size : 10pt;
	text-decoration : underline;
	font-weight : bold;
}

A.bold:FOCUS,A.bold:HOVER 
{
	color : Red;
	font-size : 10pt;
	text-decoration : underline;
	font-weight : bold;
}

.biglink {
	text-decoration : none;
	font-size:10pt;
	font-weight:bold;
}


.pageheading 
{
	color : Navy;
	font-size : 14pt;
	font-weight : bold;
	font-style : italic;
}

.textbox_input 
{
	border: 1px solid rgb(192,192,192);
	font: 14px Arial, Arial;
	font-weight: bold;
	color: Navy;
	background-color: rgb(255, 255, 255);
	text-align: right;
}

.input_textbox_input
{
	border: 1px solid rgb(192,192,192);
	font: 14px Arial, Arial;
	font-weight: bold;
	color: Navy;
	background-color: rgb(255, 255, 255);
	text-align: left;
}


.button_typical
{
	cursor: pointer;
	border-bottom: 1 solid rgb(0,0,0);
	border-right: 1 solid rgb(0,0,0);
	border-left: 1 solid rgb(192,192,192);
	border-top: 1 solid rgb(192,192,192);
	background-color: rgb(255, 255, 255);
}

</style>

</body>
</html>
