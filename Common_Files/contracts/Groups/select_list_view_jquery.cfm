<cfoutput>
<cfset ProductGroupLevelTypes = valuelist(qGetTopLevelGroups.Product_Group_Level_Type)>
<cfset productGroupAttributeManager = createobject("component", "components.products.group.ProductGroupAttributeManager")>

<cfif (isDefined("FORM.ItemList") AND FORM.ItemList NEQ "")>
	<cfset qGetGroups = productGroupAttributeManager.getProductGroupsForCreateList(ProductGroupLevelTypes,ListToArray(FORM.ItemList, ",")) />
</cfif>
<input name="groupCombinationOn" type="hidden" value="#groupCombinationOn#" />
<table width="760" border="0" cellpadding="1" cellspacing="0" style="border:thin">
	<tr>
		<td colspan="100%" bgcolor="##EAEAEA" id="header">
			<b>#sPricingLevelDesc#</b>&nbsp;
			<cfif ApplicationSettingsManager.getSearchSequenceOn() AND groupCombinationOn EQ 1>
				<input name="GroupLevel" type="hidden" value="#groupCombinationProductGroupLevelId#" />
				<!------ display the drop downs for the member groups ----->
					<table cellpadding="0" cellspacing="0" style="display:inline;">
							<tr>
									<cfloop query="qGetGroupCombinationDefinitionDetail">
									<cfparam name="FORM.Group_Combination_Member_#Product_Group_Level_Type#" 	default="">
											<td>
													<cfmodule 	template="/Customtags/ProductGroupDropDown.cfm"
															groupLevelType = "#Product_Group_Level_Type#"
															dropDownName = "Group_Combination_Member_#Product_Group_Level_Type#"
															selectedValue = "#Evaluate("FORM.Group_Combination_Member_#Product_Group_Level_Type#")#" />
											</td>
									</cfloop>
							</tr>
					</table>
			<cfelseif ApplicationSettingsManager.getSearchSequenceOn()>
				<cfset qGetSearchSequenceInfo = searchSequenceManager.getSearchSequenceInfo(SearchSequenceId) />
			
				<select name="GroupLevel">
					<option value="">Select Group...</option>
					<cfloop query="qGetTopLevelGroups">
						<cfif searchSequenceManager.enableThisProductGroupSelection(qGetSearchSequenceInfo, Search_Sequence_Field)>
						<option value="#Product_Group_Level_ID#" <cfif Product_Group_Level_ID eq Evaluate("form.GroupLevel_1")>selected</cfif>>#Group_Level_Desc#</option>
						</cfif>
					</cfloop>
				</select>
			<cfelse>
				<select name="GroupLevel" onChange="submitForm('selectListView','getGroups'); " id="GroupLevel"><!--- D30271:simplifiy product group search --->
					<option value="">Select Group...</option>
					<cfloop query="qGetTopLevelGroups">
						<option value="#Product_Group_Level_ID#" <cfif (Product_Group_Level_ID eq form.GroupLevel_1) OR (qGetTopLevelGroups.Recordcount EQ 1)>selected</cfif>>#Group_Level_Desc#</option>
					</cfloop>
				</select>
			</cfif>
			&nbsp;
			<CF_smallLink 
				title = "get groups" 
				url = "##"
				parameters = "onClick=""javascript: submitForm('selectListView','getGroups')"""
			>
			&nbsp;
			<CF_smallLink 
				title = "cancel" 
				url = "##"
				parameters = "onClick=""javascript: window.close();"""
			>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<cfif groupCombinationOn EQ 1>
			<CF_smallLink 
				title = "validate & import groups" 
				url = "##"
				parameters = "onClick=""javascript: OpenProductsMessageWindow('validate_import');"""
			>
			<cfelse>
			<CF_smallLink 
				title = "import groups" 
				url = "##"
				parameters = "onClick=""javascript: OpenProductsMessageWindow('import');"""
			>
			</cfif>
			&nbsp;
			<b>
				<font color="Red">[</font>
				<font color="Blue"><A HREF="javascript:void(0)"  onclick="window.showModalDialog('/Common_Files/createList.cfm?passObj=ProductGroup&passForm=groupDataForm&productGroupLevelTypes=#form.GroupLevel_1#&programID=#url.programId#',window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;" >create list</A></font> 
				<font color="Red">]</font>
			</b>
		</td>
	</tr>
</table>
<br>
</cfoutput>
<cfset lsProductGroups = "" />
<table class="datagrid" id="datagrid">
<thead>
	<tr>
		<th class="mid"><cfif form.SelectSingleSearchResultOnly eq 0><input type="checkbox" id="toggle_all" class="cbox" onClick="javaScript: selectAll(this, 'Level_1');" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>style="background-color: cccccc" DISABLED</cfif>/></cfif></th>
	<cfif (isDefined("FORM.ItemList") AND FORM.ItemList NEQ "")>
		<th>
			Level 1
		</th>
	</cfif>
		<th>Group Number</th>
		<th>Group</th>
	</tr>
</thead>
<tbody>
	<cfoutput>
	<cfset lsProductGroups = "" />
	<cfloop query="qGetGroups">
		<cfif (isDefined("FORM.ItemList") AND FORM.ItemList NEQ "")>
			<cfset productGroupCombo = Product_Group_ID & "," & Product_Group_Level_Type & "," & Product_Group_Level_ID & "|" />
			<cfif lsProductGroups NEQ "">
				<cfset lsProductGroups = lsProductGroups & productGroupCombo />
			<cfelse>
				<cfset lsProductGroups = productGroupCombo />
			</cfif>
		</cfif>	
	<tr>
		<td class="mid">
			<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2>
				<input name="Level_1" onclick="javscript:removeFromLevel(1, this);" type="<cfif form.SelectSingleSearchResultOnly eq 1>radio<cfelse>checkbox</cfif>" value="#Product_Group_ID#" 
				<cfif ListFindNoCase(form.Level_1, Product_Group_ID)>checked="checked"
					<cfif RevisionSettings.Products_Removed eq 2 AND ListFind(ProductItemList,qGetGroups.Product_Group_ID) neq 0>style="background-color: cccccc" DISABLED="disabled"</cfif>
				<cfelse>
					<cfif RevisionSettings.Products_Added eq 2>DISABLED="DISABLED"</cfif>
				</cfif>
			/>&nbsp;&nbsp;
				<cfif RevisionSettings.Products_Removed eq 2 OR RevisionSettings.Products_Added eq 2>	
					<cfif RevisionSettings.Products_Removed eq 2 AND listfind(ProductItemList,qGetGroups.Product_Group_ID) NEQ 0>
						<INPUT type="hidden" name="Level_1" value="#Product_Group_ID#">
					</cfif>
				</cfif>
			<cfelse>
				<input name="Level_1" onclick="javscript:removeFromLevel(1, this);" type="<cfif form.SelectSingleSearchResultOnly eq 1>radio<cfelse>checkbox</cfif>" value="#Product_Group_ID#" <cfif ListFindNoCase(form.Level_1, Product_Group_ID)>checked="checked"</cfif>>
			</cfif>
		</td>
		<cfif (isDefined("FORM.ItemList") AND FORM.ItemList NEQ "")>
			<td>
				#qGetGroups.Parent_Group_Level_Desc#
			</td>
		</cfif>
		<td><a onclick="javascript:NewWindow('group_items.cfm?Group_ID=#Product_Group_ID#&Group_Level_ID=#form.GroupLevel_1#<cfif businessSegManager.isEnabled()>&programId=#url.programId#</cfif>', 'groupitemwindow', 600, 600, 'yes', 'yes');"><cfif isDefined("qGetGroups.Group_ID")>#qGetGroups.Group_ID#</cfif></a></td>
		<td>#qGetGroups.Group_Level_Desc#</td>
	</tr>
	</cfloop>
	</cfoutput>
</tbody>
</table>
<cfoutput>
<input name="ProductsGroupLevels" type="hidden" value="#lsProductGroups#">	
</cfoutput> 
<br>
<cfif groupCombinationOn EQ 1>
<CF_smallLink 
	title = "validate & import groups" 
	url = "##"
	parameters = "onClick=""javascript: OpenProductsMessageWindow('validate_import');"""
>
<cfelse>
<CF_smallLink 
	title = "import groups" 
	url = "##"
	parameters = "onClick=""javascript: OpenProductsMessageWindow('import');"""
>
</cfif>

<CF_smallLink 
	title = "cancel" 
	url = "##"
	parameters = "onClick=""javascript: window.close();"""
>


<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.6.1-min.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.datatables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>

<script>
<cfoutput>
if ( window.opener.document.all.#url.formname# == null ) {
  alert("The data needed from the parent form isn't available.\nThis window will close!")
  window.close()
}
</cfoutput>
else {
  var datagrid = $('table#datagrid').dataTable({
  	 "bAutoWidth": true
  	,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
    ,"sScrollXInner": "70%"    <!--- value should equal to total of all aoColumns --->
    ,"sScrollY": "475px"         <!--- datagrid height --->
    ,"aaSorting": [[ 1, "asc" ]] <!--- sort on group name column --->
    ,"aoColumns": [   {"sWidth": "5%", "sSortDataType": "dom-checkbox"}
	<cfoutput><cfif (isDefined("FORM.ItemList") AND FORM.ItemList NEQ "")>
					, {"sWidth": "10%"}
		</cfif></cfoutput>
	
                    , {"sWidth": "20%"}
                    , {"sWidth": "40%"} ]
  }).fnSetFilteringDelay();
  $('table#datagrid tr').hover (
    function() { $(this).addClass("over"); },
    function() { $(this).removeClass("over"); }
  );
  $(window).resize(function(){
    datagrid.fnAdjustColumnSizing();
  });
  <!---get the list of selected values from parent window--->
  var group_list = <cfoutput>opener.document.all.#url.formname#.Product_List.value;</cfoutput>
  <!---check the selected rows--->
  $('.cbox').each(function(){
    <!---if this checkbox id is in the parent window list check it--->
    if ( $.ListFind(group_list, $(this).attr('id')) ) {
      $(this).attr('checked', 'checked');
    }
  });
}

<!--------------------------------------------------------------------------------------------------------------------->

$('#toggle_all').change(function(e){      <!---listen for the change event on the toggle--->
 if ( this.checked )
  $('.cbox').attr('checked','checked');  <!---if checked, select all the checkboxes--->
 else
  $('.cbox').removeAttr('checked');      <!---if not checked, deselect all the checkboxes--->
 e.stopPropagation();
});
$('input,select').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
$('form select:visible:enabled:first').focus();

<!--- D30271:simplifiy product group search --->
			$(document).ready(function(){
				
		   			var Values = $("select#GroupLevel").val();
					var Values1 = $("input#check").val();
					if ((Values.length != 0) && (Values1 == 0)) {
						document.all.check.value= 1;
						submitForm('selectListView', 'getGroups');
						
					}  
		 		});
<!--- D30271:simplifiy product group search --->
<!--- D30318:Group Product Search Issue START::-- moved below script from top of page to bottom and added "datagrid.fnFilter('');"  --->
function OpenProductsMessageWindow(ImportCriteria)
{
		datagrid.fnFilter(''); 
		<cfif ProductMessages.Message_Settings eq 1>
				winprops = 'height=175,width=250,top=300,left=350,scrollbars=no,resizable=no,toolbar=no,directories=no,location=no,status=no,menubar=no,titlebar=no'
				window.open("/Product_Add_Confirmation_Message.cfm?Program_ID=#PROGRAMID#&Discountype=#Discountype#&ImportCriteria="+ImportCriteria,"ProductMessageWindow",winprops);
		<cfelse>
			   
			submitForm(ImportCriteria);
		</cfif>
}
<!--- D30318:Group Product Search Issue END --->
</script>
