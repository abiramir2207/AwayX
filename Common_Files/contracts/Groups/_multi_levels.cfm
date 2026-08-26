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
																																							EZTemplate = URL.EZTemplate
																																							) />
	
<!---if we have a parent product hierarchy id then we know they are drilling into a hierarchy so get all parent hierarchies--->
<cfif Len(trim(Evaluate("form.Parent_Product_Hierarchy_ID_#levlIndx#"))) and trim(Evaluate("form.Parent_Product_Hierarchy_ID_#levlIndx#")) neq "">
	<cfset "qGetProductHierarchy_#levlIndx#" = GroupDataManager.getParentHierarchy(Evaluate("form.Parent_Product_Hierarchy_ID_#levlIndx#")) />
</cfif>

<cfset productGroupAttributeManager = createobject("component", "components.products.group.ProductGroupAttributeManager")>


<CF_smallLink 
	title = "add to pricing level" 
	url = "##"
	parameters = "onClick=""javascript: add('#levlIndx#');"""
>
<br>
<input name="groupCombinationOn" type="hidden" value="#groupCombinationOn#" />
<table width="700" border="0" cellpadding="1" cellspacing="0" style="border:thin">
	<tr>
		<td colspan="100%" bgcolor="##EAEAEA" id="header">			
			<b>#sPricingLevelDesc#</b>&nbsp;
			<cfif ApplicationSettingsManager.getSearchSequenceOn() AND groupCombinationOn EQ 1>
				<input name="GroupLevelSelect_#levlIndx#" type="hidden" value="#groupCombinationProductGroupLevelId#" />
				<!------ display the drop downs for the member groups ----->
				<table cellpadding="0" cellspacing="0" style="display:inline;"><tr>
				<cfloop query="qGetGroupCombinationDefinitionDetail">
				<cfparam name="FORM.Group_Combination_Member_#Product_Group_Level_Type#" 	default="">
				<td>
				<cfmodule 	template="/Customtags/ProductGroupDropDown.cfm"
						groupLevelType = "#Product_Group_Level_Type#"
						dropDownName = "Group_Combination_Member_#Product_Group_Level_Type#"
						selectedValue = "#Evaluate("FORM.Group_Combination_Member_#Product_Group_Level_Type#")#" />
				</td>
				</cfloop>
				</tr></table>
			<cfelseif ApplicationSettingsManager.getSearchSequenceOn()>
				<cfset qGetSearchSequenceInfo = searchSequenceManager.getSearchSequenceInfo(SearchSequenceId) />
				<select name="GroupLevelSelect_#levlIndx#">
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
				<select name="GroupLevelSelect_#levlIndx#">
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
			<CF_smallLink 
				title = "get groups" 
				url = "##"
				parameters = "onClick=""javascript: getGroups('#levlIndx#');"""
			>
		</td>
	</tr>
	<tr>
		<td style="border-bottom:none" colspan="100%">

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
			
			&nbsp;
			
		</td>
	</tr>
	
	<!---set whether or not to disable checkboxes/radio--->
	<cfif Evaluate("Form.GroupLevelSelect_#levlIndx#") neq Evaluate("Form.GroupLevel_#levlIndx#") and Evaluate("trim(Form.GroupLevel_#levlIndx#)") neq "" or ListFindNoCase(lExcludeGroups, Evaluate("Form.GroupLevelSelect_#levlIndx#"))>
		<cfset isDisabled = "disabled" />
	<cfelse>
		<cfif form.SelectSingleSearchResultOnly eq 1 and Evaluate("trim(Form.GroupLevel_#levlIndx#)") neq "">
			<cfset isDisabled = "disabled" />
		<cfelse>
			<cfset isDisabled = "" />
		</cfif>
		
	</cfif>
	
	<tr>
		<td style="border-top:none">
			<table width="700" border="0" cellpadding="0" cellspacing="0" CLASS="Maintable" style="border:thin">
				<tr BGCOLOR="##FFCE84">
					<td id="header" colspan="100%">
						<cfif form.SelectSingleSearchResultOnly eq 0>
							<input name="" type="checkbox" #isDisabled# value="" onClick="javaScript: selectAll(this, 'Level_#levlIndx#');" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>style="background-color: cccccc" DISABLED</cfif>/>
						</cfif>&nbsp;&nbsp;
						<b>Groups</b>
					</td>
				</tr>
				<cfset qGetGroupsCurrent = Evaluate("qGetGroups_#levlIndx#") />
				<!---if we have a record set then display list, otherwise show none--->
				<cfif qGetGroupsCurrent.RecordCount>
				
					<!---check to see if the record count is even or odd--->
					<cfset oddEvenCount = Evaluate(Evaluate("qGetGroups_#levlIndx#.RecordCount") mod 2) />
					
					<tr>
					
					<cfloop query="qGetGroupsCurrent">
						<cfset sStyle = "" />
						<cfif CurrentRow eq RecordCount or oddEvenCount eq 0 and CurrentRow eq RecordCount - 1 and Product_Group_Level_Type neq 2>
						<cfset sStyle = "border-bottom:none" />
						</cfif>
						<td style="#sStyle#" nowrap>
							<cfif ListFindNoCase(form.lExclusion, Product_Group_ID)>
								<cfset thisDisabled = "disabled" />
							<cfelse>
								<cfset thisDisabled = isDisabled />
							</cfif>	
							
							<input name="Level_#levlIndx#" onclick="javscript:removeFromLevel(#levlIndx#, this);" type="<cfif form.SelectSingleSearchResultOnly eq 1>radio<cfelse>checkbox</cfif>" #thisDisabled# value="#Product_Group_ID#" <cfif ListFindNoCase(Evaluate("form.Level_#levlIndx#"), Product_Group_ID)>checked</cfif>>&nbsp;&nbsp;							
							<a href="javascript:NewWindow('group_items.cfm?Group_ID=#Product_Group_ID#&Group_Level_ID=#Evaluate("form.GroupLevelSelect_#levlIndx#")#<cfif businessSegManager.isEnabled()>&programId=#url.programId#</cfif>&EZTemplate=#url.EZTemplate#', 'groupitemwindow', 600, 600, 'yes', 'yes');"><cfif isDefined("qGetGroupsCurrent.Group_ID")>#Group_ID# - </cfif>#Group_Level_Desc#</a>
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
							<!--- TSF - Label 11712: Remove product count for groups--->
<!--- 							<cfif IsDefined("Product_Count")>
								(#NumberFormat(Product_Count, "_")# products)
							</cfif> --->
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
				
				<cfelse>
				
					<tr>
						<td colspan="100%" style="border-bottom:none">
							No Groups
						</td>
					</tr>
					
				</cfif>
			</table>
		</td>
	</tr>
	
</table>

<CF_smallLink 
	title = "add to pricing level" 
	url = "##"
	parameters = "onClick=""javascript: add('#levlIndx#');"""
>
<input name="Current_Search_Level_#levlIndx#" type="hidden" value="#Evaluate("form.GroupLevelSelect_#levlIndx#")#" />
<input name="Clear_Level_#levlIndx#" type="hidden" value="0" />
<input name="Next_Level_#levlIndx#" type="hidden" value="" />
<input name="Parent_Product_Hierarchy_ID_#levlIndx#" type="hidden" value="" />
</cfoutput>

 