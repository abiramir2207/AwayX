<cfoutput>
<cfparam name="form.GroupLevelSelect_#levlIndx#" default="" />
<cfparam name="form.Product_Group_ID_#levlIndx#" default="" />
<cfparam name="form.Parent_Product_Hierarchy_ID_#levlIndx#" default="" />
<cfparam name="form.Next_Level_#levlIndx#" default="" />
<cfparam name="qGetProductHierarchy" type="query" default="#QueryNew("")#" />
<cfparam name="isDisabled" default="" />
<cfparam name="lExcludeGroups" default="" />
<cfparam name="url.EZTemplate" default="0">

<!---get all selected groups--->
<!------ move out into index.cfm, so that it is common for selectListView and selectMultiLevelView ----->

<!---add filter logic to levels that are greater than 1--->
<cfif levlIndx gt 1>
	
	<!---get group level id from previous level--->
	<cfset tmpLevelIndx = levlIndx - 1 />
	<cfset qFilterList = GroupDataManager.getAllParentGroupLevelId(Evaluate("form.GroupLevel_#tmpLevelIndx#")) />
	<cfset lExcludeGroups = ValueList(qFilterList.Product_Group_Level_ID) />
	<!---add to the list any group level id's that are not hierarchal but have been selected--->
	<cfif not ListFindNoCase(lExcludeGroups, Evaluate("form.GroupLevel_#tmpLevelIndx#"))>
		<cfset lExcludeGroups = ListAppend(lExcludeGroups, Evaluate("form.GroupLevel_#tmpLevelIndx#")) />
	</cfif>

</cfif>
<cfif form.GroupExclusionList neq "">
	<cfset form.lExclusion = ListAppend(form.lExclusion, form.GroupExclusionList) />
</cfif>
<!---query to populate drop down--->
<!--- 
D26433:PG Modifications & Bug Fixes/Anand Rao/02-Mar-2011
Added the two fields FirstParentID and allowInGroupSearch
 --->
  
 
<cfset ListAllowedGroupLevel = ""/>
<cfif GetSettings.EZButton_On EQ 1 and url.EZTemplate EQ 0 and IsDefined("FORM.ProgramID") and GetSettings.Discount_Rebate_Max_Rate_On EQ 0>
	<cfset useLakebaseForqryProductGroupOnProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqryProductGroupOnProgram>
	<cftry>
		<cfset qryProductGroupOnProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#FORM.ProgramID#",
				"deleted" = "eq.0",
				"select" = "product_group_level_id"
			}), "product_group_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryProductGroupOnProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryProductGroupOnProgram>
<cfquery name="qryProductGroupOnProgram" datasource="#application.datasource#">
		SELECT Distinct Product_Group_Level_ID FROM Contract_Products  WHERE Contract_Main_ID = '#FORM.ProgramID#' and Deleted = 0
	</cfquery>
</cfif>
	<cfset ListAllowedGroupLevel = ValueList(qryProductGroupOnProgram.Product_Group_Level_ID) />
</cfif>  
 
<cfset "qGetTopLevelGroups_#levlIndx#" = GroupDataManager.getProductGroupsData(arAllowGroupLevel = arAllowGroupLevel,  
																																							FirstParentID  = qGetProgramTemplate.First_Parent_ID,
																																							allowInGroupSearch = 1,
																																							EZTemplate = url.EZTemplate
																																							) />
	
<!---if we have a parent product hierarchy id then we know they are drilling into a hierarchy so get all parent hierarchies--->
<cfif Len(trim(Evaluate("form.Parent_Product_Hierarchy_ID_#levlIndx#"))) and trim(Evaluate("form.Parent_Product_Hierarchy_ID_#levlIndx#")) neq "">
	<cfset "qGetProductHierarchy_#levlIndx#" = GroupDataManager.getParentHierarchy(Evaluate("form.Parent_Product_Hierarchy_ID_#levlIndx#")) />
</cfif>

<cfset productGroupAttributeManager = createobject("component", "components.products.group.ProductGroupAttributeManager")>

<!---if we have a record count from the product hierarchy query then loop over and show the levels--->
<cfif isDefined("qGetProductHierarchy_#levlIndx#") and Evaluate("qGetProductHierarchy_#levlIndx#").RecordCount and Evaluate("form.Next_Level_#levlIndx#") eq levlIndx>

	<cfloop query="qGetProductHierarchy_#levlIndx#">
	
		<!---if it's the first record then the parent group level is always the child of the top level node--->
		<cfif CurrentRow eq 1>
			<!--- <cfset parentGroupLevelId = GroupDataManager.getChildParentGroupLevelId(Evaluate("form.GroupLevel_#levlIndx#"), 3) /> --->
			<cfset parentGroupLevelId = GroupDataManager.getChildParentGroupLevelId(Evaluate("form.GroupLevelSelect_#levlIndx#"), 3) />
		<!---if it's the last record then the parent group id id going to be the current group level id--->
		<cfelseif CurrentRow eq Evaluate("qGetProductHierarchy_#levlIndx#").RecordCount>
			<cfset parentGroupLevelId = Evaluate("form.GroupLevelSelect_#levlIndx#") />
		<cfelse>
			<!--- <cfset parentGroupLevelId = GroupDataManager.getChildParentGroupLevelId(Evaluate("form.GroupLevel_#levlIndx#"), 2) /> --->
			<cfset parentGroupLevelId = GroupDataManager.getChildParentGroupLevelId(Evaluate("form.GroupLevelSelect_#levlIndx#"), 2) />
		</cfif>
		
			<a href="javascript:getNextLevel('#levlIndx#', '#Product_Hierarchy_ID#', '#parentGroupLevelId#');">#Product_Hierarchy_Name#</a>
			<cfif CurrentRow neq RecordCount>\</cfif>
			
	</cfloop>
	
</cfif>

<cfset qGetGroupsCurrent = Evaluate("qGetGroups_#levlIndx#") />
<!---set whether or not to disable checkboxes/radio--->
<!--- 	76386 :: Ability to add [product group] when items already exist
	Evaluate("Form.GroupLevelSelect_#levlIndx#") neq Evaluate("Form.GroupLevel_#levlIndx#") and Evaluate("trim(Form.GroupLevel_#levlIndx#)") neq "" or  ---->
<cfif ListFindNoCase(lExcludeGroups, Evaluate("Form.GroupLevelSelect_#levlIndx#"))>
	<cfset isDisabled = "disabled" />
<cfelse>
	<cfif form.SelectSingleSearchResultOnly eq 1 and Evaluate("trim(Form.GroupLevel_#levlIndx#)") neq "">
		<cfset isDisabled = "disabled" />
	<cfelse>
		<cfset isDisabled = "" />
	</cfif>		
</cfif>

<style>
	.dataTables_wrapper{
	   _height: 80px;
	   min-height: 80px;	
	}
	.header{
		text-align: left;
	}
	.dataTables_scrollHeadInner{
		width:100%;
	}
</style>

<input name="groupCombinationOn" type="hidden" value="#groupCombinationOn#" />
<table width="100%" border="0" cellpadding="5" cellspacing="0" style="border:thin;padding-bottom:3px">
	<tr>
		<td colspan="100%" bgcolor="##EAEAEA" id="header">
			<b>#sPricingLevelDesc#</b>&nbsp;
			<cfif ApplicationSettingsManager.getSearchSequenceOn() AND groupCombinationOn EQ 1>
				<input name="GroupLevelSelect_#levlIndx#" type="hidden" value="#groupCombinationProductGroupLevelId#" />
				<!------ display the drop downs for the member groups ----->
		
					<cfloop query="qGetGroupCombinationDefinitionDetail">
						<cfparam name="FORM.Group_Combination_Member_#Product_Group_Level_Type#" 	default="">
							<cfmodule 	template="/Customtags/ProductGroupDropDown.cfm"
												groupLevelType = "#Product_Group_Level_Type#"
												dropDownName = "Group_Combination_Member_#Product_Group_Level_Type#"
												selectedValue = "#Evaluate("FORM.Group_Combination_Member_#Product_Group_Level_Type#")#" />
					</cfloop>
		
			<cfelseif ApplicationSettingsManager.getSearchSequenceOn()>
				<cfset qGetSearchSequenceInfo = searchSequenceManager.getSearchSequenceInfo(SearchSequenceId) />
				<select name="GroupLevelSelect_#levlIndx#" onchange="checkEnableLink();>
					<option value="">Select Group...</option>
					<cfloop query="qGetTopLevelGroups_#levlIndx#">
						<cfset DisplayProdLevel = 1 />
						<cfif (ListAllowedGroupLevel NEQ "" AND ListFindNoCase(ListAllowedGroupLevel,Product_Group_Level_ID) EQ 0)>
							<cfset DisplayProdLevel = 0 />
						</cfif>					
						<cfif searchSequenceManager.enableThisProductGroupSelection(qGetSearchSequenceInfo, Search_Sequence_Field) AND DisplayProdLevel EQ 1>
							<option value="#Product_Group_Level_ID#" <cfif Product_Group_Level_ID eq Evaluate("form.GroupLevelSelect_#levlIndx#")>selected</cfif>>#Group_Level_Desc#</option>
						</cfif>
					</cfloop>
				</select>
			<cfelse>
				<select name="GroupLevelSelect_#levlIndx#" onchange="checkEnableLink();">
					<option value="">Select Group...</option>
					<cfloop query="qGetTopLevelGroups_#levlIndx#">
						<cfset DisplayProdLevel = 1 />
						<cfif (ListAllowedGroupLevel NEQ "" AND ListFindNoCase(ListAllowedGroupLevel,Product_Group_Level_ID) EQ 0)>
							<cfset DisplayProdLevel = 0 />
						</cfif>			
						<cfif DisplayProdLevel EQ 1>		
							<option value="#Product_Group_Level_ID#" <cfif Product_Group_Level_ID eq Evaluate("form.GroupLevelSelect_#levlIndx#")>selected</cfif>>#Group_Level_Desc#</option>
						</cfif>
					</cfloop>
				</select>
			</cfif>&nbsp;
				<a onClick="javascript: getGroups('#levlIndx#');" style="cursor:pointer;">#application.util.string.actionLinkFormat("get groups")#</a>&nbsp;&nbsp;
				<a onClick="javascript: window.close();" style="cursor:pointer;">#application.util.string.actionLinkFormat("cancel")#</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<cfif qGetGroupsCurrent.recordcount>
					<span id="crListEn">
						<A HREF="javascript:void(0)" id="aCrList" onclick = "javascript:setCrLink();">#application.util.string.actionLinkFormat("create list")#</a>	
					</span>	
				<cfelse>		
					<span id="crListDis" title='Select a group from the dropdown to use create list' style="cursor:hand;">
						#application.util.string.actionLinkFormat("create list")#
					</span>
				</cfif>
		</td>
	</tr>
</table>


	
<table class="datagrid" id="datagrid_#levlIndx#">
<thead>
	<tr>
		<th align="center" width="50px">
			<cfif form.SelectSingleSearchResultOnly eq 0>
				<input type="checkbox" id="toggle_all" class="cbox" onClick="javaScript: selectAll(this, 'Level_1');" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>style="background-color: cccccc" DISABLED</cfif>/>
			</cfif>
		</th>
		<th class="header" width="300px">Group Number</th>
		<th class="header" width="300px">Group</th>
	</tr>
</thead>
<tbody>

	<cfloop query="qGetGroupsCurrent">
	<tr>
		<td>	
			<cfif ListFindNoCase(form.lExclusion, Product_Group_ID)>
				<cfset thisDisabled = "disabled" />
			<cfelse>
				<cfset thisDisabled = isDisabled />
			</cfif>	
			<input name="Level_#levlIndx#" onclick="javscript:removeFromLevel(#levlIndx#, this);" type="<cfif form.SelectSingleSearchResultOnly eq 1>radio<cfelse>checkbox</cfif>" #thisDisabled# value="#Product_Group_ID#" <cfif ListFindNoCase(Evaluate("form.Level_#levlIndx#"), Product_Group_ID)>checked<cfelseif ListFindNoCase(replace(form.itemList,"'","","all"), Group_ID)>checked</cfif>>							
		</td>
		<td>
			<a onclick="javascript:NewWindow('group_items.cfm?Group_ID=#Product_Group_ID#&Group_Level_ID=#Evaluate("form.GroupLevelSelect_#levlIndx#")#<cfif businessSegManager.isEnabled()>&programId=#url.programId#</cfif>&EZTemplate=#url.EZTemplate#', 'groupitemwindow', 600, 600, 'yes', 'yes');">
				#qGetGroupsCurrent.Group_ID#
			</a>
		</td>
		<td>
			<a onclick="javascript:NewWindow('group_items.cfm?Group_ID=#Product_Group_ID#&Group_Level_ID=#Evaluate("form.GroupLevelSelect_#levlIndx#")#<cfif businessSegManager.isEnabled()>&programId=#url.programId#</cfif>&EZTemplate=#url.EZTemplate#', 'groupitemwindow', 600, 600, 'yes', 'yes');">
				#qGetGroupsCurrent.Group_Level_Desc#
			</a>			
		<!---filter if Product_Group_Level_Type is not 2 (hierarchy) --->
		<cfif Product_Group_Level_Type eq 2 and Evaluate("form.GroupLevelSelect_#levlIndx#") neq "">
			<!---get the child group level id for this hierarchy group level--->
			<cfset childGroupLevelId = GroupDataManager.getChildParentGroupLevelId(Evaluate("form.GroupLevelSelect_#levlIndx#"), 1) />
			&nbsp;
			<cfif childGroupLevelId neq "">
				<cfset allowThisLevel = 1 />
				<cfset arLen = ArrayLen(arAllowGroupLevel) />
				<cfloop from="1" to="#arLen#" index="i">
					<cfif ListFindNoCase(arAllowGroupLevel[i], childGroupLevelId) eq 0>
						<cfset allowThisLevel = 0 />
						<cfbreak />
					</cfif>
				</cfloop>
				<cfif allowThisLevel>
				<a href="javascript:getNextLevel('#levlIndx#', '#Product_Group_ID#', '#childGroupLevelId#');">(Next Level)</a>
				</cfif>								
			</cfif>
		</cfif>				
		</td>
	</tr>
	</cfloop>

</tbody>
</table>

<input name="Current_Search_Level_#levlIndx#" type="hidden" value="#Evaluate("form.GroupLevelSelect_#levlIndx#")#" />
<input name="Clear_Level_#levlIndx#" type="hidden" value="0" />
<input name="Next_Level_#levlIndx#" type="hidden" value="" />
<input name="Parent_Product_Hierarchy_ID_#levlIndx#" type="hidden" value="" />

<div align="left" style="margin-top:5px;">
	<a onClick="javascript: add('#levlIndx#');" style="cursor:pointer;">#application.util.string.actionLinkFormat("add to pricing level #levlIndx#")#</a>
</div>

<!---get the groups that have already been selected if we have a group level id--->
	<cfif trim(Evaluate("form.GroupLevel_#levlIndx#")) neq "" and trim(Evaluate("form.Level_#levlIndx#")) neq "">
		<cfset "qGetSelectedGroups_#levlIndx#" = GroupDataManager.getByProductGroupData(	prodGroupLevelId = Evaluate("form.GroupLevel_#levlIndx#"), 
																																						prodGroupId = Evaluate("form.Level_#levlIndx#"), 
																																						programId = form.programId, 
																																						lExcludeProdGroup = '', 
																																						parentHierarchyId = '', 
																																						addParentName = 2,
																																						FirstParentID  = qGetProgramTemplate.First_Parent_ID, <!--- This value already exists in index.cfm where this file is called from --->
																																						IncludeActiveOnly = 1
																																						)/>	
	<cfelse>
		<cfset "qGetSelectedGroups_#levlIndx#" = QueryNew("") />
	</cfif>
	<cfset qGetSelectedGroups = Evaluate("qGetSelectedGroups_#levlIndx#") />
	<!---if we have a record set then display list, otherwise show none--->
	<cfif qGetSelectedGroups.RecordCount>
	<br>
		<table width="100%" border="0" cellpadding="1" cellspacing="0" style="border:thin" CLASS="Maintable">
		<tr BGCOLOR="##FFCE84">
			<td id="header" colspan="100%">
				<input name="" type="checkbox" id="all_#levlIndx#" value="" onClick="javaScript: removeFromGroup(#levlIndx#, this.value,1); selectAll(this, 'Remove_Level_#levlIndx#');" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2>style="background-color: cccccc" DISABLED</cfif>/>&nbsp;&nbsp;
				<b>Level #levlIndx# Groups</b>
			</td>
		</tr>		
		<!---check to see if the record count is even or odd--->
		<cfset oddEvenCount2 = Evaluate(Evaluate("qGetSelectedGroups_#levlIndx#.RecordCount") mod 2) />		
		<tr>		
			<cfloop query="qGetSelectedGroups">
				<cfset sStyle = "" />
				<cfif CurrentRow eq RecordCount or oddEvenCount2 eq 0 and CurrentRow eq RecordCount - 1 and Product_Group_Level_Type neq 2>
					<cfset sStyle = "border-bottom:none" />
				</cfif>
				<td style="#sStyle#" nowrap>
				<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Removed eq 2>
					<input name="Remove_Level_#levlIndx#" type="checkbox" value="#Product_Group_ID#"					
					<cfif ListFindNoCase(Evaluate("form.Level_"&levlIndx), Product_Group_ID) neq 0>
						<cfif RevisionSettings.Products_Removed eq 2 AND ListFind(ProductItemList,Product_Group_ID) neq 0>
							style="background-color: cccccc" DISABLED="disabled"
						</cfif>
					<cfelse>
						<cfif RevisionSettings.Products_Added eq 2>DISABLED="DISABLED"</cfif>
					</cfif>>&nbsp;&nbsp;
				<cfelse>				
					<input name="Remove_Level_#levlIndx#" type="checkbox" value="#Product_Group_ID#" onclick="removeFromGroup(#levlIndx#, this.value,0);" id="Remove_Level_#Product_Group_ID#"/>&nbsp;&nbsp;
				</cfif>
				
				<cfset url_var = '?Group_ID=#Product_Group_ID#&Group_Level_ID=#Evaluate("form.GroupLevel_#levlIndx#")#'>
				<cfif businessSegManager.isEnabled()>
					<cfset url_var = url_var&'&programId=#url.programId#'>
				</cfif>
				
					<a onclick="javascript:NewWindow('group_items.cfm#url_var#', 'groupitemwindow', 600, 600, 'yes', 'yes');">
						<cfif isDefined("qGetSelectedGroups.Group_ID")>#Group_ID# - </cfif>#Group_Level_Desc#
					</a>
				</td>
	<!---we only want one column if it's a hierarchy--->
<cfif Product_Group_Level_Type eq 2>
		</tr>
	<!---otherwise end table row for every other row--->
<cfelse>
	<cfif not CurrentRow Mod 2>
		</tr>
	</cfif>
</cfif>
		</cfloop>
		</tr>
		<tr>
			<td align="left" style="border:none;font-size:11px;" colspan="2"><br>				
				<a onClick="javascript: submitForm('selectMultiLevelView', 'removeFromPricingLevel');">#application.util.string.actionLinkFormat('remove from pricing level #levlIndx#')#</a>
			</td>
		</tr>
		</table>
		<cfif levlIndx LT 3>
		<hr style="border-top: 2px solid red;">
		</cfif>
	</cfif>


<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">

<script>
if ( window.opener.document.all.#url.formname# == null ) {
  alert("The data needed from the parent form isn't available.\nThis window will close!")
  window.close()
}

else {
<cfif qGetGroupsCurrent.recordcount GT 14>
  var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;	
</cfif>
  var datagrid = $('table##datagrid_#levlIndx#').dataTable({
      "bServerSide": false
    , "bProcessing": false
    , "bSortClasses": false
    , "bAutoWidth": false
    , "bPaginate": false
	<cfif qGetGroupsCurrent.recordcount GT 14>, "sScrollY": sScrollY</cfif>
   , "oLanguage": {"sSearch": "<b>Search:</b>"}
    , "sDom": "fprt"
    ,"aaSorting": [[ 1, "asc" ]] <!--- sort on group name column --->
    ,"aoColumns": [     {"bSortable":false, "sSortDataType": "dom-checkbox"}
			                    , {"bSortable":true}
			                    , {"bSortable":true} 
							]
  });
  $('table##datagrid tr').hover (
    function() { $(this).addClass("over"); },
    function() { $(this).removeClass("over"); }
  );
  $(window).resize(function(){
    datagrid.fnAdjustColumnSizing();
  });
  }

/*
	64286: Create List for Product Groups not recognizing values
	Added code to dynamically disable/enable create list link and 
	change the value passed to the create list over the URL.
*/
function checkEnableLink(){
	if (document.all.groupDataForm.GroupLevelSelect_#levlIndx#.selectedIndex != ''){
		document.getElementById('crListEn').style.display = ''; 
		document.getElementById('crListDis').style.display = 'none'; 
	}else{
		document.getElementById('crListEn').style.display = 'none'; 
		document.getElementById('crListDis').style.display = ''; 
	}
}

/* create an array for sending the Group Level Types */
var arTypes = [];
<cfloop query="qGetTopLevelGroups_#levlIndx#">
	arTypes[#Product_Group_Level_ID#] = #Product_Group_Level_ID#	
</cfloop>

function setCrLink(){
	var e = document.all.groupDataForm.GroupLevelSelect_#levlIndx#;
	urlLink = '/Common_Files/createList.cfm?passObj=ProductGroup&passForm=groupDataForm&productGroupLevelTypes=' + arTypes[e.options[e.selectedIndex].value] + '&programID=#url.programId#';
	window.showModalDialog(urlLink,window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); 
} 

function removeFromGroup(level, id, all){
	if(all ==1){
		if (document.getElementById("all_"+level).checked) {
			document.getElementById('RemoveFromLevel_' + level).value = document.getElementById("Level_" + level + "_Hidden").value;
		}else{
			document.getElementById('RemoveFromLevel_' + level).value ='';
		}
	}else{
		if (document.getElementById("Remove_Level_" + id).checked) {
			//concat GUID to hidden form variable which store removed groups value
			var str1 = document.getElementById('RemoveFromLevel_' + level).value;
			if (str1.length == 0) {
				document.getElementById('RemoveFromLevel_' + level).value = id;
			}
			else {
				str1 = str1.concat(',').concat(id);
				document.getElementById('RemoveFromLevel_' + level).value = str1;
			}
		}else{
			document.getElementById("all_"+level).checked = false;
			var oLevelObj = document.getElementById("RemoveFromLevel_" + level);
			if(oLevelObj)
			{
				var iLevelNewValue, iLevelValue = oLevelObj.value;
				iLevelNewValue = ListDeleteItem(iLevelValue, ",", id, 1);
				oLevelObj.value = iLevelNewValue;
			}			
		}
	}
}
</script>
</cfoutput>