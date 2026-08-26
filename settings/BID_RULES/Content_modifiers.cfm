<cfoutput>
<script>
	function verifyData() {
		ErrorCount = 0;
		for(var x=1; x<=#bidrule.modifiers.index_count#; x++) {
			currentDesc 	 = eval("document.all.modifier_desc_" + x);
			currentAmount	 = eval("document.all.modifier_amount_" + x);
			currentErrorSpan = eval("document.all.modifier_errorspan_" + x);
			
			thisErrorSpan = currentErrorSpan;
			if(currentDesc.value.length == 0 || currentAmount.value.length == 0) {
				ErrorCount++
				queueMessage("Enter both a full description and amount for this modifier or delete it before continuing", thisErrorSpan)
			}
			else {
				clearQueue(thisErrorSpan);
			}
		}
		
		if(ErrorCount == 0) {
			if(navigateAway == 1) {
				return true;
			}
			document.all.MyForm.action = "packet_modifier.cfm";
			document.all.MyForm.submit();		
		}
		else {
			showMessageWindow();
		}

	}
	
	function deleteMod(modIndex) {
		document.all.MyForm.deleteModifier.value = 1;
		document.all.MyForm.deleteModifierIndex.value = modIndex;
		document.all.MyForm.action = "packet_modifier.cfm";
		document.all.nextTab.value = "modifiers";
		document.all.MyForm.submit();
	}
	
	function formatData(oTxtObj, UOM){
		allowedString = "0123456789";
		decimalPlaces = 0;

		if(UOM == 3) {
			allowedString = "0123456789.";
			decimalPlaces = 1;
		}

		if(UOM == 1) {
			allowedString = "0123456789.";
			decimalPlaces = 2;
		}
				
		clenseText(oTxtObj, allowedString); 
		limitXdecimalplaces(decimalPlaces, oTxtObj);		
	}

	function addMod(ModType) {
		document.all.MyForm.deleteModifier.value = 0;
		if(ModType == 1) {
			document.all.addModifier_iscompound.value 		= 1;
			document.all.addModifier_isindependent.value 	= 0;
		}
		else {
			document.all.addModifier_iscompound.value 		= 0;
			document.all.addModifier_isindependent.value 	= 1;	
		}
		document.all.MyForm.addModifier.value = 1;
		document.all.MyForm.action = "packet_modifier.cfm";
		document.all.nextTab.value = "modifiers";
		document.all.MyForm.submit();
	}
	
</script>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
</cfoutput>
<cf_messagewindow>

<br><br>
<style type="text/css">
	.labelCellStyle {
		text-align : right;
		font-weight: bold;
		font-size: 14px;
	}
</style>

<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">Supply the modifier values and amounts</div>
<hr color="Orange" width="75%">
<div align="center"><span style="color: red; font-weight: bold;">Hint: if you do not enter a decription, amount, and select a unit of measure the modifier will not be saved.</span></div>
<div align="center">
<cfoutput>
<form action="" method="post" name="MyForm" id="MyForm">

<!-- compound -->
<table width="450px" border="0" cellspacing="0" cellpadding="3" align="center">
	<tr>
		<td colspan="100%" STYLE="border-bottom:1px solid orange;" nowrap><b>Compounded Calculations</b></td>
	</tr>
	<TR ID="header">
		<td bgcolor="Whitesmoke">&nbsp;</td>
		<td><b>Description</b></td>
		<td><b>Amount</b></td>
		<td><b>UOM</b></td>
		<td>&nbsp;</td>
	</tr>
<cfset counter = 1>
<cfloop index="x" from="1" to="#BidRule.Modifiers.Index_Count#" step="1">
	<cfset currentnode = evaluate("BidRule.Modifiers.Mod_#x#")>
	<cfif currentnode.iscompound EQ 1>
	<TR <CFIF counter mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<td bgcolor="Whitesmoke"><span id="modifier_errorspan_#x#"></span></td>
		<td><input name="modifier_desc_#x#"    value="#currentnode.modifier_desc#" type="Text" size="60" maxlength="45"></td>
		<td><input name="modifier_amount_#x#"  value="#currentnode.modifier_amount#" type="Text" size="4" maxlength="10" onkeyup="formatData(this, document.all.MyForm.modifier_uom_#x#.value);"></td>
		<td>
			<select name="modifier_uom_#x#">
				<option value="1" <cfif currentnode.modifier_uom EQ 1>selected</cfif>>$</option>
				<option value="2" <cfif currentnode.modifier_uom EQ 2>selected</cfif>>%</option>
			</select>
		</td>
		<td valign="middle"><img src="/images/scissor.gif" alt="click here to clear this modifier" width="12" height="12" border="0" style="cursor: pointer;" onclick="deleteMod(#x#)"></td>
	</TR>
	<cfset counter = counter + 1>
	</cfif>
</cfloop>
	<tr>
		<td colspan="100%" align="center">
			<hr color="Orange" style="height: 1px;" width="75%">
			<b style="color:red; font-weight: normal;">[</b><b style="color: blue; font-weight: normal; cursor: pointer;" onclick="addMod(1)">click here to add a compound modifier</b><b style="color:red; font-weight: normal;">]</b>
		</td>
	</tr>
</table>
<BR><BR>

<!-- independent -->
<table width="450px" border="0" cellspacing="0" cellpadding="3" align="center">
	<tr>
		<td colspan="100%" STYLE="border-bottom:1px solid orange;" nowrap><b>Independant Calculations</b></td>
	</tr>
	<TR ID="header">
		<td bgcolor="Whitesmoke">&nbsp;</td>
		<td><b>Description</b></td>
		<td><b>Amount</b></td>
		<td><b>UOM</b></td>
		<td>&nbsp;</td>
	</tr>
<cfset counter = 1>
<cfloop index="x" from="1" to="#BidRule.Modifiers.Index_Count#" step="1">
	<cfset currentnode = evaluate("BidRule.Modifiers.Mod_#x#")>
	<cfif currentnode.isindependent EQ 1>
	<TR <CFIF counter mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<td bgcolor="Whitesmoke"><span id="modifier_errorspan_#x#"></span></td>
		<td><input name="modifier_desc_#x#"    value="#currentnode.modifier_desc#" type="Text" size="60" maxlength="45"></td>
		<td><input name="modifier_amount_#x#"  value="#currentnode.modifier_amount#" type="Text" size="4" maxlength="10" onkeyup="formatData(this, document.all.MyForm.modifier_uom_#x#.value);"></td>
		<td>
			<select name="modifier_uom_#x#">
				<option value="1" <cfif currentnode.modifier_uom EQ 1>selected</cfif>>$</option>
				<option value="2" <cfif currentnode.modifier_uom EQ 2>selected</cfif>>%</option>
			</select>
		</td>
		<td valign="middle"><img src="/images/scissor.gif" alt="click here to clear this modifier" width="12" height="12" border="0" style="cursor: pointer;" onclick="deleteMod(#x#)"></td>
	</TR>
	<cfset counter = counter + 1>
	</cfif>
</cfloop>
	<tr>
		<td colspan="100%" align="center">
			<hr color="Orange" style="height: 1px;" width="75%">
			<b style="color:red; font-weight: normal;">[</b><b style="color: blue; font-weight: normal; cursor: pointer;" onclick="addMod(2)">click here to add an independent modifier</b><b style="color:red; font-weight: normal;">]</b>
		</td>
	</tr>
</table>


<input type="Hidden" name="SuppliedDataType" 			value="modifiers">
<input type="Hidden" name="sg" 							value="<cfoutput>#BidRule.sessionGUID#</cfoutput>">
<input type="Hidden" name="nextTab" 					value="volumegroups">
<input type="Hidden" name="deleteModifier" 				value="0">
<input type="Hidden" name="deleteModifierIndex"			value="0">
<input type="Hidden" name="addModifier"					value="0">
<input type="Hidden" name="addModifier_iscompound"		value="0">
<input type="Hidden" name="addModifier_isindependent"	value="0">


</form>
</cfoutput>
</div>
<hr color="Orange" width="75%">
<div align="center">
	<CF_button
		button_name		=	""
		button_caption	=	"continue"
		button_action	=	"navigateAway=0;verifyData();"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</div>
