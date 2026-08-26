<!---Worksheet that allows user to have "components"--->

<cfparam name="Billback_ID" default="">
<cfparam name="Program_ID" default="">
<cfparam name="Product_ID" default="">
<cfif isDefined("blnSubmit")>


<cfset TotalDollar = 0>
<cfset TotalVolume = 0>
<cfset ImageName = form.Image>
<!--- 
<cfloop collection = #Form# item = "FieldNames">
	<cfif left(FieldName,8) IS "counter_">
	</cfif>
</cfloop> --->

<cfset Counter = replace(Counter, ",", "", "all")>
<Cfset Counter = len(Counter)>
	
	<cfquery name="GetCurrentEntries" datasource="#application.datasource#">
	SELECT * FROM
	BB_Worksheet_Volume
	WHERE Billback_ID = '#Billback_ID#'
	AND Program_ID = #Program_ID#
	AND Product_ID = '#Product_ID#'
	</cfquery>
	
	<cfloop query="GetCurrentEntries">
	<cfset Worksheet_ID = replace(GetCurrentEntries.BB_WS_Volume_ID, "-", "_", "all")>
		<cfset F.Pounds = Evaluate("Form.Pounds_#Worksheet_ID#")>
		<cfset F.Cases = Evaluate("Form.Cases_#Worksheet_ID#")>
		<cfset F.isDeleted = Evaluate("Form.isDeleted_#Worksheet_ID#")>
		<cfif len(trim(F.Cases)) IS 0>
			<cfset F.Cases = 0>
		</cfif>
		<cfif len(trim(F.Pounds)) IS 0>
			<cfset F.Pounds = 0>
		</cfif>
			
		<cfif  (F.Cases NEQ 0 AND F.Pounds NEQ 0) AND F.isDeleted NEQ 1>
			<cfquery name="UpdateRecord" datasource="#application.datasource#">
			UPDATE BB_Worksheet_Volume
			SET 
			Billback_ID = '#Form.Billback_ID#',
			Program_ID = #Form.Program_ID#,
			Product_ID = '#Form.Product_ID#',
			Pounds = #F.Pounds#,
			Cases = #F.Cases#
			WHERE BB_WS_Volume_ID = '#GetCurrentEntries.BB_WS_Volume_ID#'
			</cfquery>
		
		<cfelse>
			<cfquery name="DeleteRecord" datasource="#application.datasource#">
			DELETE FROM BB_Worksheet_Volume
			WHERE BB_WS_Volume_ID = '#GetCurrentEntries.BB_WS_Volume_ID#'
			</cfquery>
		</cfif>
	</cfloop>
	
	<cfloop index = "Loopindex" from = "1" to = "#counter#" step = "1">
		<cfoutput>
		<cfset Pounds = Evaluate("Form.Pounds_#LoopIndex#")>
		<cfset Cases = Evaluate("Form.Cases_#LoopIndex#")>
		<cfset isDeleted = Evaluate("Form.isDeleted_#LoopIndex#")>
		<cfif len(trim(Cases)) IS 0>
			<cfset Cases = 0>
		</cfif>
		<cfif len(trim(Pounds)) IS 0>
			<cfset Pounds = 0>
		</cfif>
		</cfoutput>
		
		<cfif (Cases NEQ 0 AND Pounds NEQ 0) AND isDeleted NEQ 1>
		<cfquery name="InsertRecord" datasource="#application.datasource#">
		INSERT INTO BB_Worksheet_Volume
		(		
		Billback_ID,
		Program_ID,
		Product_ID,
		Pounds,
		Cases
		)
		VALUES
		(
		'#Billback_ID#',
		#Program_ID#,
		'#Product_ID#',
		#Pounds#,
		#Cases#
		)
		</cfquery>
		</cfif>
	
	</cfloop>
	
	<!---Check to see if there are any prior ones to display--->
	<cfquery name="Prior_Entries" datasource="#application.datasource#">
	SELECT SUM(Cases) AS Cases, Sum(Pounds) AS Pounds FROM
	BB_Worksheet_Volume
	WHERE Billback_ID = '#Billback_ID#'
	AND Program_ID = #Program_ID#
	AND Product_ID = '#Product_ID#'
	</cfquery>
	
	<cfif Desired_UOM IS 1>
		<cfif Prior_Entries.RecordCount GT 0 AND Prior_Entries.Cases GT 0>
			<cfset VolumetoReturn = Prior_Entries.Cases>
		<cfelse>
			<cfset VolumetoReturn = 0>
		</cfif>
	<cfelse>
		<cfif Prior_Entries.RecordCount GT 0 AND Prior_Entries.Pounds GT 0>
			<cfset VolumetoReturn = Prior_Entries.Pounds>
		<cfelse>
			<cfset VolumetoReturn = 0>
		</cfif>
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
				ReturnValue("#ParentFormName#", "#FieldtoFill#", #VolumetoReturn#, "#ImageName#");
		</cfoutput>
		
		window.close();
	</script>
	<cfabort>
	
<cfelse>

	<!---Check to see if there are any prior ones to display--->
	<cfquery name="Prior_Entries" datasource="#application.datasource#">
	SELECT * FROM
	BB_Worksheet_Volume
	WHERE Billback_ID = '#Billback_ID#'
	AND Program_ID = #Program_ID#
	AND Product_ID = '#Product_ID#'
	</cfquery>
	
	
	<!---Product information--->
	<cfquery name="Product_Info" datasource="#application.datasource#">
	SELECT cast(Net_Weight as float) as Net_Weight, Net_Weight as Weight, Item, Description
	FROM BSA_Foodservice_Items_Master
	WHERE BSA_Foodservice_Items_Master_ID = '#Product_ID#'
	</cfquery>
	<title>Worksheet -- Volume</title>
	
	<table border="0" cellpadding="2" cellspacing="0" width="90%">
	<form action="ws_volume.cfm" method="post" name="WSVolume">
	<input type="hidden" name="blnSubmit" value="1">
	<tr>
		<td>
			<strong>
			<cfoutput>#application.returned_customer_setting.item_label#:&nbsp; <br>
			#application.returned_customer_setting.item_label# Number:&nbsp; &nbsp; <br></cfoutput>
			</strong>
		</td>
		<td colspan="3">
		<cfoutput>
			#trim(Product_Info.Description)#<br>
			#Product_Info.Item#<br>
		</cfoutput>
		</td>
	</tr>
	
<tr><td colspan="4"><hr width="100%" color="orange"></td></tr>
		
	<tr>
		<td bgcolor="#CCFFCC" ><strong>&nbsp;  Cases</strong></td>
		<td bgcolor="#CCFFCC" ><strong>&nbsp; &nbsp; &nbsp;Pounds</strong></td>
		<td  bgcolor="#CCFFCC" nowrap align="right">		
		<img style="cursor: pointer" src="../../Images/plus4.gif" width="13" height="13" title="add row" border="0" onclick="addPeriod();">&nbsp; &nbsp;&nbsp;  </td>
	</tr>
	
	</table>
	<cfset Total_Pounds = 0>
	<cfset Total_Cases = 0>	
	<cfif Prior_Entries.Recordcount GT 0>
		
		<cfoutput query="Prior_Entries">
		<cfset Worksheet_ID = Replace(BB_WS_Volume_ID, "-", "_", "all")>
		<table border="0" cellpadding="0" cellspacing="0" width="90%" class="Maintable">
					
			<tr id="ThisRow" rowName="Row_#Worksheet_ID#">
				<td>&nbsp; </td>
				<td><input type="text" size="10" previous_value="#Cases#" converted_value="0" name="Cases_#Worksheet_ID#" value="#Cases#" onKeyUp="clenseText(this, '0123456789');" onChange="cases_to_pounds(this);"  source="1">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </td>
				<td><input type="text" size="10" previous_value="#Pounds#" name="Pounds_#Worksheet_ID#" value="#Pounds#" converted_value="0" onKeyUp="clenseText(this, '0123456789');" onChange="pounds_to_cases(this);"  source="1">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  </td>
							
		<td>
		<input type="hidden" name="isDeleted_#Worksheet_ID#" value="0">
		<img id="theImage" style="cursor: pointer" onclick="deleteRecord(this);" src="../../Images/scissor.gif" width="14" height="9" title="Remove entry" border="0"></td>
			
			</tr>	
		
			<cfset Total_Pounds = Total_Pounds + Pounds>
			<cfset Total_Cases = Total_Cases + Cases>

		</cfoutput>
	</table>
	</cfif>
	
	<table id="thisTable" border="0" cellpadding="0" cellspacing="0" width="90%" class="Maintable">
	<cfoutput>
	<tr id="ThisRow" rowName="Row_1">
		<td>&nbsp; </td>
		<td><input type="text" size="10" name="Cases_1" value="" converted_value="0" previous_value="0" onKeyUp="clenseText(this, '0123456789');" onChange="cases_to_pounds(this);"  onBlur="addPeriod();" source="2">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </td>
		<td><input type="text" size="10" name="Pounds_1" value="" converted_value="0" previous_value="0" onKeyUp="clenseText(this, '0123456789');" onChange="pounds_to_cases(this);"  onBlur="addPeriod();" source="2">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  </td>
		
		<td>
		<input type="hidden" name="counter" value="1">
		<input type="hidden" name="isDeleted_1" value="0">
		<img id="theImage" style="cursor: pointer" onclick="deleteRecord(this);" src="../../Images/scissor.gif" width="14" height="9" title="Remove entry" border="0"></td>
	</tr>	
	</cfoutput>
	</table>
	<cfoutput>
		<input type="hidden" name="Program_ID" value="#Program_ID#">
		<input type="hidden" name="Billback_ID" value="#Billback_ID#">
		<input type="hidden" name="Product_ID" value="#Product_ID#">
		<input type="hidden" name="NetWeight" value="#Product_Info.Net_Weight#">
		<input type="hidden" name="Desired_UOM" value="#Product_Volume_UOM#">
		<input type="hidden" name="FieldtoFill" value="#FieldtoFill#">
		<input type="hidden" name="ParentFormName" value="#ParentFormName#">
		<input type="hidden" name="Image" value="#Image#">
	</cfoutput>
	<table border="0" width="90%">
	<cfoutput><tr>

		<td><strong>Total Cases: <span id="Total_Cases" total_value="#NumberFormat(Total_Cases, '___,___,___,___')#">#NumberFormat(Total_Cases, '___,___,___,___')#</span></strong></td>
		<td><strong>Total Pounds: <span id="Total_Pounds" total_value="#NumberFormat(Total_Pounds, '___,___,___,___')#">#NumberFormat(Total_Pounds, '___,___,___,___')#</span></strong></td>
	</tr></cfoutput>
	<tr>
		<td colspan="2" align="right">	
		<Br>
		<CF_button
			button_name		=	""
			button_caption	=	"save"
			button_action	=	"document.WSVolume.submit();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Save the contents of this worksheet"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>		</td>
	</tr>
	</table>
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
				//alert(cObj.innerHTML)
				var inputCol = cObj.getElementsByTagName("input");
				for (j=0;j<inputCol.length;j++)
				{
					if (inputCol[j].type == "text")
					{
						inputCol[j].value = "";
						inputCol[j].readOnly = false;
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
		var objCases = getInputObject(trObj.cells[1])
		var objPounds = getInputObject(trObj.cells[2])
		
		var objDeleted = eval("document.all.isDeleted_" + find_counter(objPounds.name));
		
		
		var bDelete = false;
		if(objDeleted.value == 1)
		{
			propogateProperty(trObj, "style.backgroundColor", "#ffffff", false);
			propogateProperty(trObj, "style.textDecoration", "none", false);	
			
			objCases.readOnly = false;
			objPounds.readOnly = false;
			
			objDeleted.value = 0;
			
			thisObj.title = "delete record";
			thisObj.src = deleteImg.src;
		}
		else
		{
			bDelete = true;
			propogateProperty(trObj, "style.backgroundColor", "#DDDDDD", false);
			propogateProperty(trObj, "style.textDecoration", "line-through", false);	

			objCases.readOnly = true;
			objPounds.readOnly = true;
				
			objDeleted.value = 1;
			propogateProperty(trObj.cells[trObj.cells.length - 1], "style.backgroundColor", "#ffffff", false);
			
			thisObj.title = "undo record deletion";
			thisObj.src = undodeleteImg.src;
		}		
		
		adjust_Amount(objPounds,document.all.Total_Pounds,bDelete)	
		adjust_Amount(objCases,document.all.Total_Cases,bDelete)
				
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
	
	function pounds_to_cases(objPounds)
	{	
		var poundValue = parseFloat(objPounds.value);
		var netWeight = <cfoutput>#Product_Info.Net_Weight#</cfoutput>;
		var caseValue = poundValue / netWeight;
		var nextObj = eval("document.all.Cases_" + find_counter(objPounds.name))
		nextObj.value = formatToDecimalPlaces(caseValue, 0);
		adjust_Amount(objPounds,document.all.Total_Pounds)
		adjust_Amount(nextObj,document.all.Total_Cases)
	}
	
	function cases_to_pounds(objCases)
	{
		var caseValue = parseFloat(objCases.value);
		var netWeight = <cfoutput>#Product_Info.Net_Weight#</cfoutput>;
		var poundValue = caseValue * netWeight;
		var nextObj = eval("document.all.Pounds_" + find_counter(objCases.name))
		nextObj.value = formatToDecimalPlaces(poundValue, 0);
		adjust_Amount(nextObj,document.all.Total_Pounds)
		adjust_Amount(objCases,document.all.Total_Cases)
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
		var thisVal = thisObj.value;
		if(bDelete)
		{
			thisVal = 0;
		}
		var curTotal = prevTotal - parseFloat(thisObj.previous_value) + parseFloat(thisVal);
		totObj.innerText = formatWithComma(curTotal, 3);
		totObj.total_value = curTotal;
		thisObj.previous_value = thisVal;
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