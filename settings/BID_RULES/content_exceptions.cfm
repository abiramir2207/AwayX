<cfparam name="form.Product_List" 			default="">
<cfparam name="form.Sort_By" 				default="">
<cfparam name="form.ExistingProductList" 	default="">
<cfparam name="form.creategroup" 			default="0">

<cfset form.ExistingProductList = form.Product_List>

<cfquery name="getGroups" datasource="#application.datasource#">
	SELECT Group_Name, Exception_Group_ID
	FROM Exception_Groups
	WHERE Deleted = 0
	ORDER BY Group_Name
</cfquery>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>

<SCRIPT>
	var GroupProductCountArray = new Array();
	
	function validateGroupLabels() {
		collInputs = document.getElementsByTagName("input");
		for(var x=0; x< collInputs.length; x++){
			t = collInputs[x];
			if(t.type == "text") {
				if(t.value.length == 0) return false
			}
		}
			
		return true;
	}

	function allowProductSearch() {
	<cfif len(trim(BidRule.Type.Current_Index)) EQ 0>
		alert("You can only create excceptions for products within the selected <cfif application.returned_customer_setting.approval_on_type_code EQ 1>Type Codes<cfelse>Type Groups</cfif>. Please select at least one.")
		return false;;	
	</cfif>		
		
		return true;
	}
	
	function showProductSearchWindow(groupID) {
		//alert(getProductExclusionList(3));
			
		if(!allowProductSearch()) {
			return false;
		}
		
		if(!validateGroupLabels()){
			alert("Please enter a name for each group on the screen before adding product.");
			return false;
		}
		else {
			disableNameInput(true);
			document.all.Product_List.value = eval('document.all.Inp_Group_' + groupID + '_ProductList.value');
			document.all.ExistingProductList.value = document.all.Product_List.value;
			document.all.ProductListToExcludeFromSelecting.value = getProductExclusionList(groupID);
			document.all.MyForm.action="packet_modifier.cfm";
			document.all.exception_action.value = "add_product";
			document.all.exception_action_index.value = groupID;
			oRWindow = NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=MyForm", "productwindow", 800, 600, "yes", "yes", 1);
			
			scanForPopupClose();
		}
	}
	
	function scanForPopupClose() {
		
		if(oRWindow.closed) {
			disableNameInput(false);
		}
		else {
			setTimeout("scanForPopupClose()",500);
		}
	}

	
	function createGroup() {
		if(!allowProductSearch()) {
			return false;
		}
				
		if(!validateGroupLabels()){
			alert("Please enter a name for each group on the screen before adding a new group.");
			return false;
		}
		else {
			document.all.creategroup.value = 1;
			document.all.MyForm.action="packet_modifier.cfm";
			document.all.exception_action.value = "add_group";
			document.MyForm.submit();		
		}
	}
	
	
	
	function loadGroup() {
		if(!allowProductSearch()) {
			return false;
		}
		
		document.all.exceptions_list.fireEvent("onclick");
	}
	
	
	function removeGroup(oIndex) {
		document.all.MyForm.action="packet_modifier.cfm";
		document.all.exception_action.value = "remove_group";
		document.all.exception_action_index.value = oIndex;
		document.MyForm.submit();
	}
	
	function removeProduct(oIndex, ID) {
		if(!validateGroupLabels()){
			alert("Please enter a name for each group on the screen before removing products.");
			return false;
		}
		else {
			document.all.MyForm.action="packet_modifier.cfm";
			document.all.exception_action.value = "remove_product";
			document.all.exception_action_index.value = oIndex + "_" + ID;
			document.MyForm.submit();
		}
	}
	
	function disableNameInput(isDisabled) {
		collInputs = document.getElementsByTagName("input");
		for(var x=0; x< collInputs.length; x++){
			t = collInputs[x];
			if(t.type == "text") {
				t.disabled = isDisabled;
			}
		}
}

	function verifyGroupProductMinimum() {
		for(var x=1; x<=<cfoutput>#BidRule.exceptions.index_count#</cfoutput>; x++) {
			if(GroupProductCountArray[x] == 0){
				return false;
			}
		}
		
		return true;
	}
	
	function verifyData() {
		
		if(!validateGroupLabels()) {
			alert("Enter a label for all groups or delete them before continuning")
			return false;
		}
		
		if(!verifyGroupProductMinimum()){
			alert("There should be at least 1 product in every group, otherwise remove te group")
			return false;			
		}

		return true;
	}
	
	function finalVerifyData() {
		if(verifyData()) {
			document.all.MyForm.action="packet_modifier.cfm";
			document.all.exception_action.value = "continue"; //no case in modify packet, default means conitine
			document.all.nextTab.value="modifiers";
			document.all.MyForm.submit();
		}
	}
	
	var ProductListsOfGroups = new Array();
	<cfoutput>
		<cfloop index="x" from="1" to="#BidRule.Exceptions.Index_Count#">
			ProductListsOfGroups[#x#] = '#evaluate("BidRule.Exceptions.Groups.Group_#x#.Product_List")#';
		</cfloop>
	</cfoutput>
	
	function getProductExclusionList(current_group) {
		finalList = "";
		if(ProductListsOfGroups.length != null) {
			for(var x=1; x<ProductListsOfGroups.length; x++) {
				if(x != current_group) {
					if(ProductListsOfGroups[x].length != 0) {
						if(finalList.length == 0) {
							finalList = ProductListsOfGroups[x];
						}
						else {
							finalList = finalList + "," + ProductListsOfGroups[x];
						}
						
					}
				}
			}
		}
		return finalList;
	}	
</SCRIPT>



</head>

<body>

<br><br>
<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">
	Select the SKU's to be included in this rule as exceptions
</div>
<hr color="Orange" width="75%">
<div align="center">

<!--- <CF_button
	button_name		=	""
	button_caption	=	"select products"
	button_action	=	"javascript: showProductSearchWindow();"
	button_type		=	"link"
	button_width	=	"100"
	button_color	=	"Navy"
	button_tip		=	""
	font_color		=	"White"
	font_size		=	"12"
	font_weight		=	"bold"
> --->
<table>
	<tr>
		<td>
			<CF_button
				button_name		=	""
				button_caption	=	"create new group"
				button_action	=	"createGroup();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>		
		</td>
<!---
		<td width="30px"></td>
 		<td>
			<CF_button
				button_name		=	""
				button_caption	=	"open a group"
				button_action	=	"loadGroup();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>		
		</td> --->
	</tr>

</table>

<style type="text/css">
		.oGName {
			border : 1px solid Gray;
			width: 250px;
			color: Red;
			text-align: right;
			text-indent : 5px;
			font-weight : bold;
		}
</style>

<hr color="Orange" width="75%">
<BR>
<FORM ACTION="" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE;" onsubmit="disableNameInput(false);">

<cfoutput>
<cfloop index="x" from="1" to="#BidRule.exceptions.index_count#" step="1">
	<cfset thisID 			= evaluate("BidRule.exceptions.groups.group_#x#.Exception_Group_ID")>
	<cfset thisName 		= evaluate("BidRule.exceptions.groups.group_#x#.name")>
	<cfset thisProductList 	= evaluate("BidRule.exceptions.groups.group_#x#.product_list")>
	
	<script>
		GroupProductCountArray[#x#] = 0;
	</script>
	
	
	<cfif listlen(thisProductList, ",") GT 0>
	<cfquery name="getProductData" datasource="#application.datasource#">
		SELECT Item, UPC, Description, BSA_Foodservice_Items_Master_ID AS ID
		FROM BSA_Foodservice_Items_Master
		WHERE BSA_Foodservice_Items_Master_ID IN(#listqualify(thisProductList, "'")#)
		ORDER BY Description
	</cfquery>
	<cfelse>
		<cfset getProductData = QueryNew("temp")>
	</cfif>

	<table>
		<tr>
			<td valign="bottom">
				<span style="">Group Name:</span><img src="/images/fill.gif" width="38" height="1"><font color="red">[</font><a style="cursor: pointer;" onclick="removeGroup(#x#)">remove group</a><font color="red">]</font>&nbsp;&nbsp;<font color="red">[</font><a style="cursor: hand;" onclick="showProductSearchWindow(#x#)">add products</a><font color="red">]</font><BR>
				<input name="Inp_Group_#x#_Name" type="Text" class="oGName" maxlength="254" value="#thisName#">
				<input name="Inp_Group_#x#_ProductList" type="Hidden" value="#thisProductList#">
			</td>
		</tr>
		<TR>
			<TD>
				<TABLE CLASS="Maintable" WIDTH="500" CELLPADDING="0" CELLSPACING="0">
					<TR BGCOLOR="FFCE84">
						<TD ID="header">&nbsp;</td>
						<TD ID="header"><b>Item</b></td>
						<TD ID="header"><b>UPC</b></td>
						<TD ID="header"><b>Description</b></td>
						<TD ID="header">&nbsp;</td>
					</tr>
				<cfif getProductData.recordcount GT 0>
				<cfloop query="getProductData">
					<script>
						GroupProductCountArray[#x#] = GroupProductCountArray[#x#] + 1;
					</script>
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" <!--- ONMOUSEOVER="menuID=6;URLstring='';an_ID='#searchProducts.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;" --->>
						<TD ID="header">&nbsp;</td>
						<td>#getProductData.Item#</td>
						<td>#getProductData.UPC#</td>
						<td>#getProductData.Description#</td>
						<td><img src="/images/scissor.gif" alt="remove this product" style="cursor: pointer;" onclick="removeProduct(#x#, '#getProductData.ID#')"></td>
					</tr>
				</cfloop>
				<cfelse>
					<tr>
						<td colspan="100%" align="center" bgcolor="ffffff"><span style="color: red; font-size: 12px;">No Products Selected</span></td>
					</tr>
				</cfif>
				</table>
			</TD>
		</TR>
	</table>
	<BR><BR>
</cfloop>

<cfif BidRule.exceptions.index_count EQ 0>
	<div style="color: red; font-weight: bold; font-size: 15px;">No Exception Groups Are Defined</div>
	<br>
</cfif>

</cfoutput>


<script>
	//alert(GroupProductCountArray[1])
</script>

<table style="display: none;">
	<td id="exceptions_list" onclick="tdClick(this)"></td>
</table>

<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="Sort_By" 			VALUE="#form.Sort_By#">
	<INPUT TYPE="Hidden" NAME="Program_ID" 			VALUE="">
	<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="">
	<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="">
	<INPUT TYPE="Hidden" NAME="DTPS_On" 			VALUE="1">
	<INPUT TYPE="Hidden" NAME="DTPS_Program_ID" 	VALUE="">
	<INPUT TYPE="Hidden" NAME="ProductListToExcludeFromSelecting" 	VALUE="">
	
	<INPUT TYPE="Hidden" NAME="creategroup" 		VALUE="0">
	<INPUT TYPE="Hidden" NAME="exception_action" 	VALUE="0">
	<INPUT TYPE="Hidden" NAME="exception_action_index" 	VALUE="">
	<input type="Hidden" name="SudmitFormViaSubmitButton" value="1">
	
	<input type="Hidden" name="Only_Show_Products_From_These_Groups" value="<cfif len(trim(BidRule.Type.Current_Index)) GT 0>#BidRule.Type.Current_Index#<cfelse>666</cfif>"><!--- type code or group --->
		
</CFOUTPUT>

<input type="Hidden" name="SuppliedDataType" 	value="exceptions">
<input type="Hidden" name="sg" 					value="<cfoutput>#BidRule.sessionGUID#</cfoutput>">
<input type="Hidden" name="nextTab" 			value="exceptions">

<input type="submit" name="submitbutton" style="display: none;">
</FORM>

<hr color="Orange" width="75%">
<div align="center">
	<CF_button
		button_name		=	""
		button_caption	=	"continue"
		button_action	=	"navigateAway=0;finalVerifyData();"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</div>

</body>
</html>