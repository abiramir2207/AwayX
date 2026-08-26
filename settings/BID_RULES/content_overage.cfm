<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>

<cfwddx action="CFML2WDDX" input="#BidRule#" output="BidRule_Serialized" usetimezoneinfo="Yes">
<!---<cffile action="WRITE" file="#apppath#\WddxPackets\#url.sg#.ddx" output="#BidRule_Serialized#" addnewline="Yes">
--->
<cffile action="WRITE" file="#Application.Doc_Path#\temp_files\WddxPackets\#url.sg#.ddx" output="#BidRule_Serialized#" addnewline="Yes">

<cfquery name="getUOMDescription" datasource="#application.datasource#">
	SELECT Unit_Of_Measure_Desc
	FROM Units_Of_Measure
	WHERE Unit_Of_Measure_ID = '#BidRule.Basic.Bid_Rule_UOM#'
</cfquery>
<cfset uomDesc = getUOMDescription.Unit_Of_Measure_Desc>
<cfif BidRule.Basic.Bid_Rule_UOM EQ 0>
	<cfset uomDesc = "NOT PROVIDED">
</cfif>

<!--- <cfdump var="#BidRule#">
<cfabort>
 ---><cfoutput>
<script>
	function verifyRanges() {
		//document.all.MyForm.action = 'packet_modifier.cfm';
		//document.all.MyForm.submit();
		//return true;
		ErrorCount = 0;
		thisCollection = document.all.overageAmount;
		errorCollection = document.all.overageAmountError;
		
		previousTextbox 	= "";
		previousErrorSpan 	= "";
		
		for(var x=0; x<thisCollection.length; x++) {
			thisTexbox 		= thisCollection[x].firstChild;
			thisErrorSpan 	= errorCollection[x];
	
			if(thisTexbox.value.length == 0) {
				ErrorCount++
				queueMessage("Enter An Amount (whole numbers only)", thisErrorSpan)
			}
			else {
				clearQueue(thisErrorSpan)
			}
		}

		if(ErrorCount==0){
			document.all.MyForm.action = 'packet_modifier.cfm';
			document.all.MyForm.submit();
		}
		else {
			showMessageWindow();
		}
	}
	
	function applyToRange() {
		currentValue = document.all.globalRangeValue.value;
		currentGroup = document.all.globalRange.selectedIndex+1;
		
		
		if(document.all.ckbox != null) {
			
			//only one type group is listed
			if(document.all.ckbox.length == null){
				if(document.all.ckbox.checked) {
					//currentRange = eval('document.all.Type_1_Group_' + currentGroup);
					currentRange.value = currentValue;
				}
			}
			//more than one type group
			else {
				
				for(var x=0; x<document.all.ckbox.length; x++){
					currentChkBox = document.all.ckbox[x];
					if(currentChkBox.checked) {

						currentRange = eval('document.all.' + currentChkBox.PreFix + 'Group_' + currentGroup);
						//alert('document.all.' + currentChkBox.PreFix + 'Group_' + currentGroup)
						currentRange.value = currentValue;
						
					}
				}
			}
		}
	}
	
	function SelectAll(status) {
		if(document.all.ckbox != null) {
			if(document.all.ckbox.length == null){
				document.all.ckbox.checked = status;
			}
			//more than one type group
			else {
				for(var x=0; x<document.all.ckbox.length; x++){
					document.all.ckbox[x].checked = status;
				}
			}
		}
	}
	
</script>
</cfoutput>
<cf_messagewindow>

<br><br>
<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">
	Supply the overages for the volume groups
</div>
<hr color="Orange" width="75%">
<div align="center">

<table>
	<tr>
		<td align="center" valign="middle">
			<span style="color:Navy; font-size: 14px; font-weight: bold;">Global Rate Applicator</span>
			<hr color="Navy" style="height: 1px;">
			<b>Rate</b>:&nbsp;<input type="text" name="globalRangeValue" size="10" maxlength="20" onkeyup="clenseText(this, '0123456789')">
			&nbsp;<b>Range</b>:&nbsp;
			<select name="globalRange">
				<cfoutput>
				<cfloop index="n" from="1" to="#BidRule.Volumegroups.Index_Count#" step="1">
					<cfset currentnode = evaluate("BidRule.Volumegroups.Group_#n#")>
					<option value=""><cfif n EQ 1>0<cfelse>#currentnode.Range_Start#</cfif> to <cfif n EQ BidRule.Volumegroups.Index_Count>*<cfelse>#currentnode.Range_End#</cfif>&nbsp;#uomDesc#</option>
				</cfloop>
				</cfoutput>
			</select>
			<font color="red" style="font-size: 13px;">[</font><a style="font-size: 13px;" onclick="applyToRange()"><b style="cursor: pointer;">apply</b></a><font color="red" style="font-size: 13px;">]</b>
			<hr color="Navy" style="height: 1px;">
		</td>
	</tr>
</table>
<form action="" method="post" name="MyForm" id="MyForm">
<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">
	<cfoutput>#approval_type_name#</cfoutput> Overages
</div>
<hr color="Orange" width="75%">
<table width="400px" border="0" cellspacing="0" cellpadding="3" align="center">
	<tr BGCOLOR="">
		<td colspan="100%" style="border: 1 solid whitesmoke;"><input type="Checkbox" id="selectAllChkBox" onclick="SelectAll(this.checked)">&nbsp;<b style="color: Black; font-size: 12px;">Select All</b></td>
	</tr>

	<cfset thisCounter = 1>
	<cfloop condition="thisCounter NEQ 0">
		<cfif not isdefined("BidRule.Type.Type_#thisCounter#")>
			<cfset thisCounter = 0>
			<cfbreak>
		</cfif>
		
		<cfset currentnode_type = evaluate("BidRule.Type.Type_#thisCounter#")>
		<cfif currentnode_type.action NEQ 3>
			<CFIF thisCounter mod 2><cfset bgcolor = "##ffce84"><CFELSE><cfset bgcolor = "##ccffcc"></CFIF>
			<tr BGCOLOR="<cfoutput>#bgcolor#</cfoutput>">
				<td colspan="100%" style="border: 1 solid Black;"><input type="Checkbox" id="ckbox" PreFix="<cfoutput>Type_#thisCounter#_</cfoutput>">&nbsp;<b style="color: Navy; font-size: 14px;"><cfoutput>#currentnode_type.description#</cfoutput></b></td>
			</tr>
			<cfloop index="n" from="1" to="#BidRule.Volumegroups.Index_Count#" step="1">
				<CFIF n mod 2><cfset bgcolor = "white"><CFELSE><cfset bgcolor = "##ccffcc"></CFIF>
				<cfset currentnode = evaluate("BidRule.Volumegroups.Group_#n#")>
				<cfoutput>
				<tr bgcolor="white">
					<td BGCOLOR="whitesmoke" width="50px" style="border-left: 1 solid Black;">&nbsp;</td>
					<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; border-left: 1 solid Black; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"	><cfif n EQ 1>0<cfelse>#currentnode.Range_Start#</cfif></td>
					<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"								>to</td>
					<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>" nowrap									><cfif n EQ BidRule.Volumegroups.Index_Count>*<cfelse>#currentnode.Range_End#</cfif>&nbsp;#uomDesc#:</td>
					<td BGCOLOR="#bgcolor#"	style="<cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"												><span id="overageAmountError"></span><span id="overageAmount"><input name="Type_#thisCounter#_Group_#n#" type="text" size="4" style="border: 1 solid Black;" onkeyup="clenseText(this, '0123456789')" value="#evaluate("currentnode_type.OverageAmounts.Group_Overage_#n#")#"></span>&nbsp; 
						<cfset thisUOM = 0>
						<cfif isdefined("currentnode_type.OverageAmounts.Group_Overage_#n#_UOM")>
							<cfset thisUOM = evaluate("currentnode_type.OverageAmounts.Group_Overage_#n#_UOM")>
						</cfif>
						
						<select name="Type_#thisCounter#_Group_#n#_uom">
							<option value="1" <cfif thisUOM EQ 1>selected</cfif>>$</option>
							<option value="2" <cfif thisUOM EQ 2>selected</cfif>>%</option>
						</select>					
					</td>
					<td BGCOLOR="#bgcolor#" style="border-right: 1 solid Black; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"								>&nbsp;</td>
				</tr>
				</cfoutput>
			</cfloop>
			<tr>
				<td colspan="100%" height="15px;" style="border-top: 1 solid Black;">&nbsp;</td>
			</tr>
	</cfif>
	<cfset thisCounter = thisCounter + 1>
	</CFLOOP>
</table>

<!---  --->
<!--- exceptions --->
<!---  --->


<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">
	Exception Overages
</div>
<hr color="Orange" width="75%">
<table width="400px" border="0" cellspacing="0" cellpadding="3" align="center">
<!--- 	<tr BGCOLOR="">
		<td colspan="100%" style="border: 1 solid whitesmoke;"><!--- <input type="Checkbox" id="selectAllChkBox" onclick="SelectAll(this.checked)">&nbsp; ---><b style="color: Black; font-size: 12px;">Select All</b></td>
	</tr> --->
<cfset thisCounter = 1>
<cfloop index="x" from="1" to="#BidRule.Exceptions.index_count#" step="1">
	<cfset currentnode_type = evaluate("BidRule.Exceptions.Groups.Group_#x#")>
	<CFIF x mod 2><cfset bgcolor = "##ffce84"><CFELSE><cfset bgcolor = "##ccffcc"></CFIF>
	<tr BGCOLOR="<cfoutput>#bgcolor#</cfoutput>">
		<td colspan="100%" style="border: 1 solid Black;"><input type="Checkbox" id="ckbox" PreFix="<cfoutput>Exception_#thisCounter#_</cfoutput>">&nbsp;<b style="color: Navy; font-size: 14px;"><cfoutput>#currentnode_type.name#</cfoutput></b></td>
	</tr>
<cfloop index="n" from="1" to="#BidRule.Volumegroups.Index_Count#" step="1">
		<CFIF n mod 2><cfset bgcolor = "white"><CFELSE><cfset bgcolor = "##ccffcc"></CFIF>
		<cfset currentnode = evaluate("BidRule.Volumegroups.Group_#n#")>
		<cfoutput>
		<tr bgcolor="white">
			<td BGCOLOR="whitesmoke" width="50px" style="border-left: 1 solid Black;">&nbsp;</td>
			<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; border-left: 1 solid Black; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"	><cfif n EQ 1>0<cfelse>#currentnode.Range_Start#</cfif></td>
			<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"								>to</td>
			<td BGCOLOR="#bgcolor#" width="1px" style="font-weight:bold; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>" nowrap									><cfif n EQ BidRule.Volumegroups.Index_Count>*<cfelse>#currentnode.Range_End#</cfif>&nbsp;#uomDesc#:</td>
			<td BGCOLOR="#bgcolor#"	style="<cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"												><span id="overageAmountError"></span><span id="overageAmount"><input name="Exception_#thisCounter#_Group_#n#" type="text" size="4" style="border: 1 solid Black;" onkeyup="clenseText(this, '0123456789')" value="#evaluate("currentnode_type.OverageAmounts.Group_Overage_#n#")#"></span>&nbsp; 
				<cfset thisUOM = 0>
				<cfif isdefined("currentnode_type.OverageAmounts.Group_Overage_#n#_UOM")>
					<cfset thisUOM = evaluate("currentnode_type.OverageAmounts.Group_Overage_#n#_UOM")>
				</cfif>
				
				<select name="Exception_#thisCounter#_Group_#n#_uom">
					<option value="1" <cfif thisUOM EQ 1>selected</cfif>>$</option>
					<option value="2" <cfif thisUOM EQ 2>selected</cfif>>%</option>
				</select>					
			</td>
			<td BGCOLOR="#bgcolor#" style="border-right: 1 solid Black; <cfif n NEQ BidRule.Volumegroups.Index_Count>border-bottom: 1 solid Black;</cfif>"								>&nbsp;</td>
		</tr>
		</cfoutput>
	
	</CFLOOP>

	<tr>
		<td colspan="100%" height="15px;" style="border-top: 1 solid Black;">&nbsp;</td>
	</tr>
	<cfset thisCounter = thisCounter + 1>		
</cfloop>
<cfif BidRule.Exceptions.index_count EQ 0>
	<tr>
		<td colspan="100%" align="center"><span style="color: red; font-weight: bold;">No Data Provided</span></td>
	</tr>
</cfif>

</table>


<input type="Hidden" name="SuppliedDataType" 	value="overage">
<input type="Hidden" name="sg" 					value="<cfoutput>#BidRule.sessionGUID#</cfoutput>">
<input type="Hidden" name="nextTab" 			value="summary">
</form>

</div>
<hr color="Orange" width="75%">
<div align="center">
	<CF_button
		button_name		=	""
		button_caption	=	"continue"
		button_action	=	"verifyRanges()"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</div>