<CFPARAM NAME="FORM.Operator_List" 	DEFAULT="">
<CFPARAM NAME="FORM.Product_List" 	DEFAULT="">
<CFPARAM NAME="FORM.item_List" 	DEFAULT="">
<CFPARAM NAME="FORM.GroupLevel_1" 	DEFAULT="0">
<cfparam name="FORM.opr_sort_by" 	default="Operator Name">
<cfparam name="FORM.opr_sort_order" 	default="ASC">
<cfparam name="FORM.prod_sort_by" 	default="item">
<cfparam name="FORM.prod_sort_order" 	default="ASC">
<cfparam name="form.Search_Sequence_ID"  default="1">
<cfparam name="Form.Item_level_Available" default ="0">
<cfparam name="Form.group_level_Available" default ="0">
<cfparam name="Legacy_ID" default="">
<cfparam name="FORM.GroupLevel" default="">
<cfparam name="FORM.GroupID" default="">

<SCRIPT language=JavaScript1.2 src="/common_files/scripts/demenu.js"></SCRIPT>

<cfmodule template="/customTags/layout.cfm"
							layoutID = "priceProtection"
							selectedIndex = "" >

<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />

<!--- START:  D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012 ---->
<cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsDataNoPG() />
<!--- END: D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012 ---->

<cfset formname = "PriceProtection">
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfinclude template="/includes/right_click_menu_code.cfm">
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<cfset operator = CreateObject("component","components.customer.operator.operator") />
<cfset StSearchopr = StructNew()>
<cfset StSearchopr.idList = form.Operator_List>
<cfset GetOperators = operator.getOperator(StSearchopr,form.opr_sort_by, form.opr_sort_order)>

<cfset productManager = CreateObject("component", "components.products.ProductManager")>
<CFPARAM NAME="pageName" 		DEFAULT="createjob">
<!--- <cfinclude template="header.cfm"> --->

<br>
<cfoutput><FORM ACTION="price_protection_index.cfm" METHOD="post" NAME="#formname#" ID="#formname#" style="display:inline">
<b>
<CF_smallLink
		title = "Select Operators"
		url = "##"
		parameters = "onClick=""javascript: return showOperatorSearchWindow();"""
	></b>
	<TABLE width="90%" BORDER="0" CELLPADDING="1" CELLSPACING="1">
	<TR BGCOLOR="FFCE84" colspan="100%">
				<TD STYLE="font-size:11px;" colspan="100%">
					<b>Operators</b>
				</TD>
			</TR>
<tr>
<cfif GetOperators.RecordCount GT 0>
		<CFLOOP QUERY="getOperators">
		<TD CLASS="dataStyle" WIDTH="10%" VALIGN="top" BGCOLOR="F2F2F2" STYLE="cursor: help;" ONMOUSEOVER="menuID=5;URLstring='';an_ID='#getOperators.BSA_Operator_ID#';doNotRelocate=1;" ONMOUSEOUT="menuID=0;">
										<span>
											<FONT SIZE="1">
											#ucase(trim(getOperators.Operator_Name))#
											<cfif application.returned_customer_setting.Operator_Legacy_Id_On EQ 1 AND Legacy_ID NEQ "">
											(#Legacy_ID#)</cfif>
											</FONT>
										</span>
									</TD>
									<CFIF getOperators.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
								</CFLOOP>
	<cfelse>

				<td>NONE SELECTED</td>

	</cfif>
	</tr>

	<tr><td colspan="100%">&nbsp;</td></tr>
<cfif appSettings.getSearchSequenceOn()>
<TR colspan="100%">
				<TD STYLE="font-size:11px;" >
					<b>Search Sequence:</b><br>
	<cfset searchSequenceManager 			= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
			<cfset SearchSequence = searchSequenceManager.getSearchSequenceInfo() />
			<cfif SearchSequence.Recordcount GT 0>
			<select name="Search_Sequence_ID" onchange="submitthisselection();">
						<cfloop query="SearchSequence">
							<option value="#Search_Sequence_ID#" <cfif Search_Sequence_ID IS Form.Search_Sequence_ID>selected</cfif>>#Search_Sequence_Legacy# #Search_Sequence_Desc#</option>
						</cfloop>
					</select>
				</cfif>
			</td>

<cfif form.Search_Sequence_ID NEQ 0>
<cfset 	Program_Search_Sequence 	= SearchSequenceManager.getSearchSequenceInfo(form.Search_Sequence_ID) />
 <cfset 	Form.Item_level_Available =  SearchSequenceManager.enableProductSelection(Program_Search_Sequence) />
	<cfset 	Form.Group_Level_Available = SearchSequenceManager.enableGroupSelection(Program_Search_Sequence) />
 </cfif>
<cfelse>
<cfset 	Form.Item_level_Available = 1>
<cfset 	Form.Group_Level_Available = 1>
</cfif>
<tr><td>&nbsp;</td></tr>
<tr>
<td colspan="100%">
<cfif Form.Item_level_Available eq 1>
	<cfset getProducts = productManager.GetProducts(form.Item_List)>
	<CF_smallLink
		title = "select products"
		url = "##"
		parameters = "onClick=""javascript: return showProductSearchWindow();"""
	>
</cfif>
&nbsp;&nbsp;&nbsp;&nbsp;
<cfif Form.Group_Level_Available eq 1>
	<cfset getGroups = productManager.GetProducts(form.Product_List)>
	<select name="GroupLevel" id="GroupLevel">
  			<option value="">Select Group...</option>
  			<cfloop query="qGetTopLevelGroups">
  				<option value="#Product_Group_Level_ID#" <cfif FORM.GroupLevel EQ Product_Group_Level_ID>selected</cfif>>#Group_Level_Desc#</option>
			</cfloop>
	</select>&nbsp;
  	<cfset extraParameter = " onClick=""javascript: return showSearchWindow('/Search_Screens/ApprovalGroup_Search.cfm?groupLevelId=' + document.PriceProtection.GroupLevel.options[document.PriceProtection.GroupLevel.selectedIndex].value, 'Allow_Approval_group',document.PriceProtection.GroupLevel.options[document.PriceProtection.GroupLevel.selectedIndex].value,document.PriceProtection);""" />
  	<CF_smallLink
  			title = "add group"
			url = "##"
			parameters = "#extraParameter#"
	>
<cfelse>
        <input type="hidden" name="GroupLevel" value="" />
</cfif>
<input type="hidden" name="GroupID" value="<cfoutput>#Form.GROUPID#</cfoutput>" />
</td>
</tr>



<cfif Form.Item_level_Available eq 1>
<TR BGCOLOR="FFCE84" colspan="100%">
				<TD STYLE="font-size:11px;" colspan="100%">
					<b>Products</b>
				</TD>
			</TR>
<tr>
<cfif getProducts.RecordCount GT 0>
		<CFLOOP QUERY="getProducts">
		<TD CLASS="dataStyle" WIDTH="10%" VALIGN="top" BGCOLOR="F2F2F2" STYLE="cursor: help;" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#getProducts.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" ONMOUSEOUT="menuID=0;">
										<span>
											<FONT SIZE="1">
											#ucase(trim(getProducts.item))#<br>
											#getProducts.description#
											</FONT>
										</span>
									</TD>
									<CFIF getProducts.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
								</CFLOOP>
	<cfelse>

				<td>NONE SELECTED</td>

	</cfif>
	</tr>
</cfif>
<cfif Form.Group_level_Available eq 1>
	<TR BGCOLOR="FFCE84" colspan="100%">
				<TD STYLE="font-size:11px;" colspan="100%">
					<b>Groups</b>
				</TD>
	</TR>
	<tr>
	<cfif Form.GroupID NEQ "" and FORM.GroupLevel NEQ "">
		<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init() />
		<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(form.GROUPLEVEL) />
		<cfset qGetApprovalGroups = approvalGroupManager.getApprovalGroups(Form.GroupID)>
		<cfif qGetApprovalGroups.RecordCount GT 0>
			<CFLOOP QUERY="qGetApprovalGroups">
				<cfset request.theMOId = "#getGroups.BSA_Foodservice_Items_Master_ID#&Group_Level_ID=#form.grouplevel_1#&producttype_id=2" />
				<TD CLASS="dataStyle" WIDTH="10%" VALIGN="top" BGCOLOR="F2F2F2" STYLE="cursor: help;" ONMOUSEOVER="menuID=11;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" ONMOUSEOUT="menuID=0;">
					<span>
						<FONT SIZE="1">
						Level 1/<script>document.write(document.PriceProtection.GroupLevel.options[document.PriceProtection.GroupLevel.selectedIndex].text)</script>; &nbsp;#Group_Name#
						</FONT>
					</span>
				</TD>
				<CFIF qGetApprovalGroups.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
			</CFLOOP>
		<cfelse>
			<td>NONE SELECTED</td>
		</cfif>
	</cfif>
	</tr>
</cfif>
<tr><td>&nbsp;</td></tr>
<tr><td align="center" colspan="100%"><CF_smallLink
		title = "Get Programs"
		url = "##"
		parameters = "onClick=""javascript:submitform();"""
	>
</td></tr>

</table>
<INPUT type="Hidden" name="SelectSingleSearchResultOnly" value="0">
<INPUT type="Hidden" name="Operator_List" value="#FORM.Operator_List#">
<INPUT TYPE="Hidden" NAME="ExistingProductList" VALUE="#Form.Item_List#">
<INPUT TYPE="Hidden" NAME="Product_List" 		VALUE="#Form.Product_List#">
<INPUT TYPE="Hidden" NAME="Level_1" 		VALUE="#Form.Product_List#">
<INPUT TYPE="Hidden" NAME="GroupLevel_1" 		VALUE="#form.GroupLevel_1#">
<INPUT TYPE="Hidden" NAME="Item_List" 		VALUE="#form.Item_List#">
</cfoutput>
</form>
<script>
function submitthisselection()
{
document.all.Product_List.value = "";
document.all.Item_List.value = "";
PriceProtection.submit();
}
	function showOperatorSearchWindow() {
			 NewWindow('/Billbacks/search_screens/PM_select_operators.cfm?Formname=PriceProtection', 'Operators', '800', '600', 'Yes', 'No', true);
		}
	function showProductSearchWindow()
	{
	NewWindow('/common_files/contracts/product_Select_V1.cfm?Formname=PriceProtection&Return_Value_Field_Name=Item_List', "productwindow", 800, 600, "yes", "yes");
	}
		function showGroupSearchWindow()
	{
				NewWindow("/common_files/contracts/Groups/index.cfm?formName=PriceProtection&search_sequence_id=<cfoutput>#form.Search_Sequence_ID#</cfoutput>", "groupwindow", 800, 600, "yes", "yes");
	}
	function showSearchWindow(sUrl, FieldName,bChecker,dataForm)
	{
	    if (bChecker == '')
	    {
	      alert("Pick a Group from the left!");
	      return false;
	    }
	    else
	    {
	  		NewWindow(sUrl + '&FormName=PriceProtection&FieldName=' + FieldName , 'select_restrict_group_level_value' , 1000 , 800 , 'yes' , 'yes');
	  		return false;
	    }
	}
	function submitform()
	{
		<cfif listlen(Form.Operator_List) EQ 0>
			alert("Please select an operator");
			return;
		</cfif>
		<cfif listlen(Form.Item_List) EQ 0 and form.Item_level_Available EQ 1 and form.group_level_Available EQ 0>
			alert("Please select products");
			return;
		</cfif>
		<cfif listlen(Form.Product_List) EQ 0 and form.group_level_Available EQ 1 and form.Item_level_Available EQ 0>
			alert("Please select groups");
			return;
		</cfif>
		<cfif listlen(Form.Item_List) NEQ 0 and listlen(Form.Product_List) NEQ 0>
			alert("You cannot select both products and groups");
			return;
		</cfif>
		PriceProtection.action = "get_programs.cfm";
		PriceProtection.submit();
	}
</script>
</cfmodule>