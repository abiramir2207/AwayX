<cfoutput>
<script>
	function verifyData() {
		ErrorCount = 0;

		thisErrorObject = document.all.Bid_Rule_Name;
		thisErrorSpan = document.all.Bid_Rule_Name_ERRORSPAN;
		if(thisErrorObject.value.length == 0) {
			ErrorCount++
			queueMessage("Enter A Rule Name", thisErrorSpan)
		}
		else {
			clearQueue(thisErrorSpan)
		}		

		
		thisErrorObject = document.all.Bid_Rule_Desc;
		thisErrorSpan = document.all.Bid_Rule_Desc_ERRORSPAN;
		if(thisErrorObject.value.length == 0) {
			ErrorCount++
			queueMessage("Enter A Rule Description", thisErrorSpan)
		}
		else {
			clearQueue(thisErrorSpan)
		}		

		thisErrorObject = document.all.Bid_Rule_UOM;
		thisErrorSpan = document.all.Bid_Rule_UOM_ERRORSPAN;
		if(thisErrorObject.selectedIndex == 0) {
			ErrorCount++
			queueMessage("Please select a Unit Of Measure", thisErrorSpan)
		}
		else {
			clearQueue(thisErrorSpan)
		}		

		if(ErrorCount==0){
			document.all.MyForm.action = "packet_modifier.cfm";
			document.all.MyForm.submit();
		}
		else {
			showMessageWindow();
		}
	}
</script>
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

<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">
	Enter the basic information for this rule
</div>
<hr color="Orange" width="75%">
<div align="center">
<cfoutput>
<form action="" method="post" name="MyForm" id="MyForm">
<table>
	<tr>
		<td class="labelCellStyle">Name:<span id="Bid_Rule_Name_ERRORSPAN"></span></td>
		<td rowspan="3"></td>
		<td><input type="text" name="Bid_Rule_Name" size="64" maxlength="254" value="#BidRule.Basic.Bid_Rule_Name#"></td>
	</tr>
	<tr>
		<td class="labelCellStyle">Description:<span id="Bid_Rule_Desc_ERRORSPAN"></span></td>
		<td>
			<textarea cols="66" rows="3" name="Bid_Rule_Desc">#BidRule.Basic.Bid_Rule_Desc#</textarea>
		</td>
	</tr>
	<tr>
		<td class="labelCellStyle">UOM:<span id="Bid_Rule_UOM_ERRORSPAN"></span></td>
		<td>
			<cf_uom_dropdown
				default_option_on		=	"1"
				default_option_text		=	"Choose"
				default_option_value	=	"0"
				dropdown_name			=	"Bid_Rule_UOM"
				selected_uom_id			=	"#BidRule.Basic.Bid_Rule_UOM#"
				text_before_tag_close	=	"STYLE=""width: 100px;"""
				uom_id_exclusion_list	=	"3"
				uom_id_inclusion_list	=	""
			>		
		</td>
	</tr>
</table>

<input type="Hidden" name="SuppliedDataType" 	value="basic">
<input type="Hidden" name="sg" 					value="<cfoutput>#BidRule.sessionGUID#</cfoutput>">
<input type="Hidden" name="nextTab" 			value="type">
</form>
</cfoutput>
</div>
<hr color="Orange" width="75%">
<div align="center">
	<CF_button
		button_name		=	""
		button_caption	=	"continue"
		button_action	=	"verifyData()"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</div>
