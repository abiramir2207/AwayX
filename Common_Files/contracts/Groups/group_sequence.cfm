<cfoutput>
<cfparam name="form.GroupLevelSelect_#levlIndx#" default="" />
<cfparam name="form.Product_Group_ID_#levlIndx#" default="" />
<cfparam name="form.Parent_Product_Hierarchy_ID_#levlIndx#" default="" />
<cfparam name="form.Next_Level_#levlIndx#" default="" />
<cfparam name="qGetProductHierarchy" type="query" default="#QueryNew("")#" />
<cfparam name="isDisabled" default="" />
<cfparam name="lExcludeGroups" default="" />
<cfparam name="url.EZTemplate" default="0">

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">

<!---add filter logic to levels that are greater than 1--->
<cfif levlIndx gt 1>

	<!---get group level id from previous level--->
	<cfset tmpLevelIndx = levlIndx - 1 />
	<cfset qFilterList = GroupDataManager.getAllParentGroupLevelId(form["GroupLevel_#tmpLevelIndx#"]) />
	<cfset lExcludeGroups = ValueList(qFilterList.Product_Group_Level_ID) />
	<!---add to the list any group level id's that are not hierarchal but have been selected--->
	<cfif not ListFindNoCase(lExcludeGroups, form["GroupLevel_#tmpLevelIndx#"])>
		<cfset lExcludeGroups = ListAppend(lExcludeGroups, form["GroupLevel_#tmpLevelIndx#"]) />
	</cfif>

</cfif>

<cfif form.GroupExclusionList neq "">
	<cfset form.lExclusion = ListAppend(form.lExclusion, form.GroupExclusionList) />
</cfif>
<!---query to populate groups --->

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
		SELECT Distinct Product_Group_Level_ID
		FROM Contract_Products
		WHERE Contract_Main_ID = '#FORM.ProgramID#' and Deleted = 0
	</cfquery>
</cfif>
	<cfset ListAllowedGroupLevel = ValueList(qryProductGroupOnProgram.Product_Group_Level_ID) />
</cfif>

<cfset "qGetTopLevelGroups_#levlIndx#" = GroupDataManager.getProductGroupsData(	arAllowGroupLevel = arAllowGroupLevel,
																																																																														FirstParentID  = qGetProgramTemplate.First_Parent_ID,
																																																																														allowInGroupSearch = 1,
																																																																														EZTemplate = url.EZTemplate
																																																																														) />

<!---if we have a parent product hierarchy id then we know they are drilling into a hierarchy so get all parent hierarchies--->
<cfif Len(trim(form["Parent_Product_Hierarchy_ID_#levlIndx#"])) and trim(form["Parent_Product_Hierarchy_ID_#levlIndx#"]) neq "">
	<cfset "qGetProductHierarchy_#levlIndx#" = GroupDataManager.getParentHierarchy(form["Parent_Product_Hierarchy_ID_#levlIndx#"]) />
</cfif>

<cfset productGroupAttributeManager = createobject("component", "components.products.group.ProductGroupAttributeManager")>

<cfset qGetGroupsCurrent = Evaluate("qGetGroups_#levlIndx#") />

<cfif ListFindNoCase(lExcludeGroups, Form["GroupLevelSelect_#levlIndx#"])>
	<cfset isDisabled = "disabled" />
<cfelse>
	<cfif form.SelectSingleSearchResultOnly eq 1 and Evaluate("trim(Form['GroupLevel_#levlIndx#']") neq "">
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
 .links{
 	background-color:##E0E0E0;
 	height:15px;
 	padding:10px;
 	margin-bottom:5px;
 	font-size:12px;
 }
 .links:hover {
  background-color:##FFFFFF;
  !cursor: pointer;
}
</style>

<input name="groupCombinationOn" type="hidden" value="#groupCombinationOn#" />
<input name="GroupLevelSelect_#levlIndx#" type="hidden" value="#form["GroupLevelSelect_#levlIndx#"]#" /><!---????????????????????????????? --->
<input name="Current_Search_Level_#levlIndx#" type="hidden" value="#form["GroupLevelSelect_#levlIndx#"]#" />
<input name="Clear_Level_#levlIndx#" type="hidden" value="0" />
<input name="Next_Level_#levlIndx#" type="hidden" value="" />
<input name="Parent_Product_Hierarchy_ID_#levlIndx#" type="hidden" value="" />

	<cfset qGetTopLevelGroups = Evaluate("qGetTopLevelGroups_#levlIndx#") />

	<cfif Form.GroupLevel_1 EQ 9>
		<cfset Form.GroupLevel_1 = ''>	
	</cfif>
	
	<!---
	SELECT Group_Level_Desc, Product_Group_Level_ID , Product_Group_Level_Type, 
		CASE WHEN Is_PG = 1 THEN 8 ELSE Display_Sequence END AS Display_Sequence,  Is_PG
		FROM qGetTopLevelGroups
		WHERE Display_Sequence != 0
		AND  Active = 1
	--->
	<cfquery name="groupSequence" dbtype="query">
		SELECT Group_Level_Desc, Product_Group_Level_ID , Product_Group_Level_Type, 
		Display_Sequence,  Is_PG
		FROM qGetTopLevelGroups
		WHERE Display_Sequence != 0
		AND  Active = 1

		<cfif len(form["GroupLevel_#levlIndx#"])>
		AND Product_Group_Level_ID = #form["GroupLevel_#levlIndx#"]#			
		</cfif>

		<cfif len(GroupDisplayList)>
		AND Product_Group_Level_ID NOT IN (<cfqueryparam list="yes" value="#GroupDisplayList#">)
		</cfif>

		ORDER BY Display_Sequence , Group_Level_Desc
	</cfquery>


	<cfset selectedGroups = 0 >
	
	<cfloop to ="1" from ="#levlIndx#" index="selLevels" step="-1">
		<cfif len(form["GroupLevel_#selLevels#"]) AND form["GroupLevel_#selLevels#"] NEQ 9>
			<cfset selectedGroups =selLevels><cfbreak>
		</cfif>
	</cfloop>

<cfset currentLevel  = selectedGroups + 1>

<cfloop query="groupSequence">

	<!---get the groups that have already been selected if we have a group level id--->
		<cfif trim(form["GroupLevel_#levlIndx#"]) neq "" and trim(form["Level_#levlIndx#"]) neq "" >
			<cfset "qGetSelectedGroups_#levlIndx#" = GroupDataManager.getByProductGroupData(	prodGroupLevelId = form["GroupLevel_#levlIndx#"],
                                        prodGroupId = form["Level_#levlIndx#"],
                                        programId = form.programId,
                                        lExcludeProdGroup = '',
                                        parentHierarchyId = '',
                                        addParentName = 2,
                                        FirstParentID  = qGetProgramTemplate.First_Parent_ID, <!--- This value already exists in index.cfm where this file is called from --->
                                        IncludeActiveOnly = 1,
                                        IncludeDeleted = 1
                                        )/>
		<cfelse>
			<cfset "qGetSelectedGroups_#levlIndx#" = QueryNew("") />
		</cfif>
		<cfset qGetSelectedGroups = Evaluate("qGetSelectedGroups_#levlIndx#") />

<cfset GroupDisplayList = listappend(GroupDisplayList, Product_Group_Level_ID)>
<cfif len(form["GroupLevel_#levlIndx#"])>
	<cfset GroupDisplayOrder = Display_Sequence>
</cfif>

<div class="links">
	<table border="0">
	<tr>
		<td style="float:left;width:350px;" id="#Product_Group_Level_ID#">
			<a 
				<cfif qGetSelectedGroups.recordcount EQ 0>
					onclick="loadTable(#Product_Group_Level_ID#, #Display_Sequence#)"
				<cfelse>
					onclick="showhide(#Product_Group_Level_ID#);"
				</cfif> style="color: black">#Group_Level_Desc#</a>
		</td>
		<td>
			<img src="/images/asc.png" onclick="showhide(#Product_Group_Level_ID#)" class="up_#Product_Group_Level_ID#" style="display:none;">
			<img src="/images/desc.png" onclick="showhide(#Product_Group_Level_ID#)" class="down_#Product_Group_Level_ID#" style="display:none;">
	</td>
	<td>
		<cfif qGetGroupsCurrent.recordcount AND qGetGroupsCurrent.Product_Group_Level_Type EQ groupSequence.Product_Group_Level_Type>
			<cfif url.userSelectedLevel><cfset currentLevel  = url.userSelectedLevel></cfif>
			<a onClick="javascript: add('#currentLevel#');" style="cursor:pointer;">#application.util.string.actionLinkFormat("add groups to level", 0)#</a>
		</cfif>
		<cfif qGetSelectedGroups.RecordCount>
			<a href="javascript:reloadPage(#levlIndx#, #Product_Group_Level_ID#)">#application.util.string.actionLinkFormat2('get groups')#</a>&nbsp;&nbsp;
			<a onClick="javascript: submitForm('selectMultiLevelView', 'removeFromPricingLevel');">#application.util.string.actionLinkFormat('remove groups')#</a>
		</cfif>
	</td>
	</tr>
	</table>
</div>

<div class="groups_#Product_Group_Level_ID#" >

<cfif qGetGroupsCurrent.recordcount AND qGetGroupsCurrent.Product_Group_Level_Type EQ groupSequence.Product_Group_Level_Type>
<script>$('.up_#Product_Group_Level_ID#').show();</script>
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
			<input name="Level_#levlIndx#" onclick="javscript:removeFromLevel(#levlIndx#, this);" type="<cfif form.SelectSingleSearchResultOnly eq 1>radio<cfelse>checkbox</cfif>" #thisDisabled# value="#Product_Group_ID#" <cfif ListFindNoCase(form["Level_#levlIndx#"], Product_Group_ID)>checked<cfelseif ListFindNoCase(replace(form.itemList,"'","","all"), Group_ID)>checked</cfif>>
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
		<cfif Product_Group_Level_Type eq 2 and form["GroupLevelSelect_#levlIndx#"] neq "">
			<!---get the child group level id for this hierarchy group level--->
			<cfset childGroupLevelId = GroupDataManager.getChildParentGroupLevelId(form["GroupLevelSelect_#levlIndx#"], 1) />
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
</cfif>

		<!---if we have a record set then display list, otherwise show none AND ((url.userSelectedLevel NEQ 0 AND url.userSelectedLevel  NEQ levlIndx) OR url.userSelectedLevel EQ 0 )--->
		<cfif qGetSelectedGroups.RecordCount >
			<script>$('.up_#Product_Group_Level_ID#').show();</script>
		<br>
			<table width="100%" border="0" cellpadding="1" cellspacing="0" style="border:thin" CLASS="Maintable" id="#currentLevel#records">
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
						<input name="Remove_Level_#levlIndx#" type="checkbox" value="#Product_Group_ID#" id="Remove_Level_#levlIndx#"
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
		</table>
			<cfif levlIndx LT 3>
			<hr style="border-top: 2px solid red;">
			</cfif>
		</cfif>
	</div>
</cfloop>

<script>
if ( window.opener.document.all.#url.formname# == null ) {
  alert("The data needed from the parent form isn't available.\nThis window will close!")
  window.close()
}else {
<cfif qGetGroupsCurrent.recordcount GT 14>
  var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .55) * windowHeight;
</cfif>

<cfif qGetGroupsCurrent.recordcount>
  var datagrid = $('table##datagrid_#levlIndx#').dataTable({
      "bServerSide": false
    , "bProcessing": false
    , "bSortClasses": false
    , "bAutoWidth": false
    , "bPaginate": false
	<cfif qGetGroupsCurrent.recordcount GT 14>, "sScrollY": sScrollY</cfif>
   	, "oLanguage": {"sSearch": "<b>Search:</b>"}
    , "sDom": "fprt"
    ,	"aaSorting": [[ 1, "asc" ]] <!--- sort on group name column --->
    ,	"aoColumns": [
	    												{"bSortable":false, "sSortDataType": "dom-checkbox"}
				                    , {"bSortable":true}
				                    , {"bSortable":true}
														]
  });
  $('table##datagrid_#levlIndx# tr').hover (
    function() { $(this).addClass("over"); },
    function() { $(this).removeClass("over"); }
  );
  $(window).resize(function(){
    datagrid.fnAdjustColumnSizing();
  });
  </cfif>
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
	function loadTable(id, ds){
			document.all.GroupLevelSelect_#levlIndx#.value = id;
			document.all.GroupDS.value = ds;
			document.all.CurrentLevel.value = #levlIndx#;
			dhtmlx.message( "Processing" );
			getGroups('#levlIndx#');
	}
	function showhide(id){
			$( '.groups_'+id ).toggle();

			if($( '.up_'+id ).css( "display" ) == 'none'){
				$( '.up_'+id).css("display", "block");
			}else{
				$( '.up_'+id).css("display", "none");
			}
			if($( '.down_'+id ).css( "display" ) == 'none'){
				$('.down_'+id).css("display", "block");
			}else{
				$('.down_'+id).css("display", "none");
			}
	}
		function reloadPage(userSelectedLevel, userSelectedprodGroupId){
			/*
		 * queryParameters -> handles the query string parameters
		 * queryString -> the query string without the fist '?' character
		 * re -> the regular expression
		 * m -> holds the string matching the regular expression
		 */
		var queryParameters = {}, queryString = location.search.substring(1),
		    re = /([^&=]+)=([^&]*)/g, m;

		// Creates a map with the query string parameters
		while (m = re.exec(queryString)) {
		    queryParameters[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
		}

		// Add new parameters or update existing ones

			queryParameters['userSelectedLevel'] = userSelectedLevel;
			queryParameters['userSelectedprodGroupId'] = userSelectedprodGroupId;
		/*
		 * Replace the query portion of the URL.
		 * jQuery.param() -> create a serialized representation of an array or
		 *     object, suitable for use in a URL query string or Ajax request.
		 */
		location.search = $.param(queryParameters); // Causes page to reload
		}
</script>
</cfoutput>