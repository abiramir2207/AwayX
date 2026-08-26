<CfSet TabInd = 0>
<cfparam name="CurrentCounter" default="0">
<cfif form.command EQ "sClassCodes">
	<!---save business segment--->
	<cfset rClassCodeId = businessSegManager.saveClassCode(form.id, form.Class_Code_ID, form.Class_Code_Desc, form.Business_Segment_ID,form.materials_for_settlement) />

	<cfif form.id eq 0>
		<cfset form.id = rClassCodeId />
	</cfif>
	<!--- Save Lumpsum allocation --->
	<cftransaction>
		<cfset Counter = replace(Counter, ",", "", "all")>
		<Cfset Counter = len(Counter) + form.PreviousEntries>
	
		<Cfquery name="DeletePrevious" datasource="#application.datasource#">
		UPDATE Class_Code_Lump_Sum_Assoc
		SET Deleted = 1
		WHERE Class_Code_ID = '#form.ID#'
		</CFQUERY>
		<cfloop index = "Loopindex" from = "1" to = "#counter#" step = "1">
		<cfif isDefined("Form.Dollar_#LoopIndex#")>
			<cfset Percent = Evaluate("Form.Dollar_#LoopIndex#")>
			<cfset Value = Evaluate("Form.Value_#LoopIndex#")>
			
			<Cfif Percent GT 0 AND len(trim(Percent)) IS NOT 0>
				<cfquery name="InsertIntoClassCode" datasource="#application.datasource#">
				INSERT INTO Class_Code_Lump_Sum_Assoc
				(
					Class_Code_ID,
					Class_Code_Assoc_Value,
					Class_Code_Assoc_Percent,
					Created_By,
					Created_Date
				)
				VALUES
				(
					'#form.ID#',
					'#Value#',
					'#Percent#',
					'#request.AccessStructure.User_ID#',
					#now()#
				)
				</cfquery>
			</CFIF>
		</cfif>
		</cfloop> 
	
	</cftransaction>
	<!--- End Lumpsum allocation --->
	<cflocation url="index.cfm?command=#form.returnCommand#" />
	<cfabort>
</cfif>
<cfset qGetClassCodes = businessSegManager.getClasscode(form.id) />

<cfparam name="qGetClassCodes.Class_Code" default="" />
<cfparam name="qGetClassCodes.Class_Code_Desc" default="" />

<cfoutput>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Class Code Information</LEGEND>
	<table border="0">
		<TR>
			<TD ALIGN="right"><B>Class Code ID:</B></TD>
			<TD>
				<span id="Err_Sp_Unit_ID"></span>
				<INPUT NAME="Class_Code_ID" TYPE="text" value="#HTMLEditFormat(trim(qGetClassCodes.Class_Code))#" SIZE="30" MAXLENGTH="25">
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Class Code:</B></TD>
			<TD><span id="Err_Sp_Desc"></span><INPUT NAME="Class_Code_Desc" TYPE="text" VALUE="#HTMLEditFormat(trim(qGetClassCodes.Class_Code_Desc))#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>
		<tr>
			<td ALIGN="right"><b>Materials for Settlement:</b></td>
			<td><INPUT NAME="materials_for_settlement" TYPE="text" VALUE="#HTMLEditFormat(trim(qGetClassCodes.External_Id))#" SIZE="30" MAXLENGTH="20"></td>
		</tr>
		<TR>
			<TD ALIGN="right"><B>#appSettings.getbusiness_segment_label()#:</B></TD>
			<TD>
			<cfset qGetBusSegments = businessSegManager.getActive() />
			<cfset classcodeBusinessSegementId = qGetClassCodes.Business_Segment_ID />
			<SELECT id="Business_Segment_ID" name="Business_Segment_ID">
				<cfloop query="qGetBusSegments">
				<option value="#Business_Segment_ID#"<cfif Business_Segment_ID EQ classcodeBusinessSegementId> SELECTED</cfif>>#Business_Unit_Desc#</option>
				</cfloop>
			</SELECT>
			</TD>
		</TR>
		</cfoutput>

		<cfquery name="Prior_Entries" datasource="#application.datasource#">
		SELECT * FROM Class_Code_Lump_Sum_Assoc
		WHERE	Class_Code_ID = '#form.id#'
		AND 	Deleted = 0
		ORDER BY Class_Code_Assoc_Value
		</cfquery>
		<cfparam name="PercentTotal" default="0">
		
		<!---- Lump sum allocation --->
		<tr>
			<td align="right"><strong><cfoutput>#Application.LumpsumLabel#</cfoutput> Allocation</strong>:</td>
			<td align="right"><img src="/Images/plus4.gif" width="13"  style="cursor: pointer;" height="13" title="add row" border="0" onclick="addPeriod();" usemap="#tabMap">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</td>
		</tr>
		<tr><td>&nbsp; </td><td>
		
		<table id="thisTable" border="0" cellpadding="0" cellspacing="0" width="90%" class="Maintable">
		<tr><th><font size="1">Value</font></th><th><font size="1">Percent</font></th><!--- <td>&nbsp; </td> ---></tr>
		<cfif Prior_Entries.Recordcount GT 0>
		
		<cfoutput query="Prior_Entries">
		
			<CfSet TabInd = (Prior_Entries.currentRow + 1)>
		
			<tr id="ThisRow" rowName="Row_#TabInd#">
			<TD><input type="text" size="20" name="Value_#TabInd#" value="#Class_Code_Assoc_Value#" previous_value="Value_#TabInd#" tabindex="#TabInd#" maxlength="50">&nbsp;</TD>
				<td align="right"><input type="text" size="10" previous_value="#Class_Code_Assoc_Percent#" name="Dollar_#TabInd#" value="#Class_Code_Assoc_Percent#" onKeyUp="clenseText(this, '0123456789.');" onChange="adjust_Dollar_Amount(this)" tabindex="#TabInd#"></td>
										
		<!--- <td align="center">
		&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
		<input type="hidden" name="isDeleted_#Worksheet_ID#" value="0">
		<img id="theImage" style="cursor: pointer;" onclick="deleteRecord(this);" src="../../Images/scissor.gif" width="14" height="9" alt="Remove entry" border="0"></td> --->
			
			</tr>	
			<cfset PercentTotal = PercentTotal + Class_Code_Assoc_Percent>
			 
		</cfoutput>
		<cfset CurrentCounter = Prior_Entries.Recordcount +1>
	</cfif>
	
	<cfoutput>
	<CfSet TabInd = (TabInd + 1)>
	<tr id="ThisRow" rowName="Row_1">
		<TD><input type="text" size="20" name="Value_1" value="" previous_value="0" tabindex="#TabInd#" maxlength="50">&nbsp;</TD>
		<td align="right"><input type="text" size="10" name="Dollar_1" value="0" previous_value="0" onKeyUp="clenseText(this, '0123456789.');" onChange="adjust_Dollar_Amount(this);" tabindex="#TabInd#" <!--- onBlur="addPeriod();" --->>
<input type="hidden" name="counter" value="1">
</td>
			
		<!--- <td align="right" valign="center" nowrap>
		
		<input type="hidden" name="isDeleted_1" value="0">
		<img id="theImage"  style="cursor: pointer;" onclick="deleteRecord(this);" src="/Images/scissor.gif" width="14" height="9" alt="Remove entry" border="0"></td> --->
	</tr>	
	</cfoutput>
	
	</table>
	<table>
	<cfoutput><tr>
		<td align="right">&nbsp; &nbsp; <strong>Percent Total:</strong>  </td>
		<Td><strong><span id="Total_Dollars" total_value="#PercentTotal#">#PercentTotal#</span></strong>%</TD>
	</tr></cfoutput>
	</table>	
			
			</td>
			
		</tr>
		<input type="hidden" name="PreviousEntries" value="<cfoutput>#CurrentCounter#</cfoutput>">
			
		
		
		<tr>
			<td align="right"><font color="red">*</font></td>
			<Td align="left"><font color="red">To remove a row leave it blank or put a 0 in it</font></TD>
		</tr>
		
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
			<cfif not form.id>
				<CF_smallLink 
					title = "save" 
					url = "##"
					parameters = "onClick=""javascript: return submitCCForm('sClassCodes','#form.id#');"""
				>
			</cfif>
			<CF_smallLink 
				title = "cancel" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('cancel');"""
			>
			</TD>
		</TR>
	</table>
	


</FIELDSET>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>
<script>
 function addPeriod()
{	
	var tabObj = document.all.thisTable;
	var lastIndex = tabObj.rows.length - 1;
	addFilterRows(tabObj, tabObj.rows[lastIndex], lastIndex, lastIndex + 2);				
}

	function find_counter(sname)
	{	
		var arName = sname.split("_");
		arName.splice(0,1);
		return arName.join("_");		
		
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
			
			thisObj.title = "undo record deletion";
			thisObj.src = undodeleteImg.src;
		}		
		
		adjust_Amount(objDollars,document.all.Total_Dollars,bDelete)
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
					
	     		cObj.innerHTML = incrementName(trObj.cells(i).innerHTML, trIndex + 1, srcIndex);	
				
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
			<!--- rObj.all.theImage.title = "delete record";
			rObj.all.theImage.src = deleteImg.src; --->
			propogateProperty(rObj, "style.backgroundColor", "#ffffff", false);
			propogateProperty(rObj, "style.textDecoration", "none", false);	
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
		alert(thisObj.value);
		if(bDelete)
		{
			thisVal = 0;
		}
		var amtToDelete = parseFloat(thisObj.previous_value) + parseFloat(thisVal);
		alert(amtToDelete)
		var curTotal = prevTotal - amtToDelete;

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
	
	function submitCCForm(command, id)
	{
		if (document.all.Total_Dollars.getAttribute('total_value') == 100 || document.all.Total_Dollars.getAttribute('total_value') == 0 )
		{
			document.DataForm.command.value = command;
			document.DataForm.submit();
			return false;
		}
		else
		{	
			alert("If you enter any <cfoutput>#Application.LumpsumLabel#</cfoutput> allocations, they must equal 100%");
			return false;
		}
	}
		
</script>

<cf_MessageWindow />
