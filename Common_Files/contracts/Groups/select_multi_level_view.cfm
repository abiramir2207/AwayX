<cfoutput>
<script language="javascript">
function OpenProductsMessageWindow(ImportCriteria)
{
		<cfif ProductMessages.Message_Settings eq 1>
				winprops = 'height=175,width=250,top=300,left=350,scrollbars=no,resizable=no,toolbar=no,directories=no,location=no,status=no,menubar=no,titlebar=no'
				window.open("/Product_Add_Confirmation_Message.cfm?Program_ID=#PROGRAMID#&Discountype=#Discountype#&ImportCriteria="+ImportCriteria,"ProductMessageWindow",winprops);
		<cfelse>
			submitForm(ImportCriteria);
			opener.callSpinner();
		</cfif>
}
</script>
<!---Moved logic to build level list to index.cfm

Select a Pricing Level to work with:<br><br>--->

<!---loop over all the levels and list layers--->
<cfset GroupDisplayList = "" />
<cfset GroupDisplayOrder = "" />
<cfset highestLevel = ArrayMax(ListToArray(request.lLevelList))>

<cfif ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') eq '1'>
	<cfif form.command EQ "selectMultiLevelView" AND url.userSelectedLevel>
			<!---get all the groups for this category--->
			<cfset qGetGroups = GroupDataManager.getByProductGroupData(
																						prodGroupLevelId = url.userSelectedprodGroupId,
																						prodGroupId =  '',
																						programId = form.programId,
																						lExcludeProdGroup = currentExclusion,
																						FirstParentID  = qGetProgramTemplate.First_Parent_ID,
																						setGroupTemplateSelectionOn = 1,
																						businessSegmentId = productGroupFilterBusinessSegmentId,
																						IncludeActiveOnly = 1,
																						EZTemplate = URL.EZTemplate,
																						plannerId = form.plannerId
																						) />
			<cfset "qGetGroups_#url.userSelectedLevel#" = qGetGroups />
			<cfset form.Pricing_Level_ID = url.userSelectedLevel>
			<cfset 'form.GroupLevelSelect_#url.userSelectedLevel#' = url.userSelectedprodGroupId>
	</cfif>
			<!---BELOW CODE IN IF CONDITION IS USED TO RE-ARRANGE LEVELS WHEN USER ADD HIGHER LEVEL GROUPS WHEN LOWER LEVEL GROUPS EXISTS---->
			<cfset curlevel = form.Currentlevel>

			<cfif form.GroupDS LT curlevel AND len(evaluate("form.Level_#curlevel#"))>
				<!--- TEMP STORGAGE OF CURRENT GROUP LEVEL VALUES--->
				<cfset tempLevel = evaluate("form.Level_#curlevel#")>
				<cfset tempLevelID = evaluate("form.GroupLevel_#curlevel#")>

				<!--- EMPTY CURRENT LEVEL LEVEL AS CURRENT LEVEL VALUE --->
				<cfset "form.Level_#curlevel#" = ''>
				<cfset "form.GroupLevel_#curlevel#" = ''> 

				<!--- LOOP FROM 8 TO 1 TO REARRANGE LEVELS --->
				<cfset lastLevel = request.AccessStructure.numberOfProductGroupLevels - 1>
				<cfloop from="#lastLevel#" to="#GroupDS#" step="-1" index="levl">
					<cfset nextLevl = levl + 1>
					<cfset "form.Level_#nextLevl#" = Evaluate("form.Level_#levl#")>
					<cfset "form.GroupLevel_#nextLevl#" = Evaluate("form.GroupLevel_#levl#")>
				</cfloop>
				
				<!--- ASSIGN NEW GROUP AND GROUP LEVEL ID  TO CORRECT DISPLAY ORDER LEVEL ---->
				<cfset "form.Level_#GroupDS#" = tempLevel>
				<cfset "form.GroupLevel_#GroupDS#" = tempLevelID>

			</cfif>

	</cfif>


<cfloop index="levlIndx" list="#request.lLevelList#">

	<cfparam name="form.Remove_Level_#levlIndx#" default="" />

	<!---loop over the remove list to see if there are any groups to remove only if remove from pricing level was selected--->
	<cfif not compareNoCase(form.sub_command, "removeFromPricingLevel")>

		<cfloop index="reLevelIndx" list="#Evaluate("form.Remove_Level_#levlIndx#")#">
			<cfif  ListFindNoCase(Evaluate("form.Level_#levlIndx#"), reLevelIndx)>
				<cfset "form.Level_#levlIndx#" = ListDeleteAt(Evaluate("form.Level_#levlIndx#"), ListFindNoCase(Evaluate("form.Level_#levlIndx#"), reLevelIndx)) />
				<cfif len(form.Product_List) AND ListFindNoCase(form.Product_List, reLevelIndx) AND ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') eq '1'>
					<cfset form.Product_List = ListDeleteAt(form.Product_List, ListFindNoCase(form.Product_List, reLevelIndx)) />
				</cfif>
			</cfif>
		</cfloop>

			<cfif ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') eq '1'>
			<!---BELOW CODE IN IF CONDITION IS USED TO RE-ARRANGE LEVELS WHEN USER DELETES HIGHER LEVEL GROUPS WHEN LOWER LEVEL GROUPS EXISTS---->				
			<cfif len(Evaluate("form.Remove_Level_#levlIndx#"))>
				<cfloop from ="#levlIndx#" to="#highestLevel#" index="levelChange">
					<cfset nextLevel = levelChange + 1>
					<cfif len(form['Level_#nextLevel#'])>	
					<cfset "form.Level_#levelChange#" = "">
					<cfset "form.Level_#levelChange#" = form['Level_#nextLevel#']/>
					<cfset "form.GroupLevel_#levelChange#" = form['GroupLevel_#nextLevel#']/>				
					</cfif>
				</cfloop>
			</cfif>
				<cfset "form.RemovefromLevel_#levlIndx#" = "">
	</cfif>
	</cfif>
	<!---hidden field to maintain the open/closed state of the layer--->
	<cfparam name="form.Layer_State_#levlIndx#" default="yes" />
	<input type="hidden" name="Layer_State_#levlIndx#" value="#Evaluate("form.Layer_State_#levlIndx#")#" />

	<!---if the level is empty then we have to empty the gorup level--->
	<cfif trim(Evaluate("form.Level_#levlIndx#")) eq "">
		<cfset "form.GroupLevel_#levlIndx#" = "" />
	</cfif>
	<cfset sPricingLevelDesc = GroupDataManager.getPricingLevelDesc(levlIndx) />

	<cfif ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') eq '1'>
		<cfinclude template="group_sequence.cfm" />
	<cfelse>
		<!---D50884 :: Improvements to the Rebate/Fixed/Lumpsum Pages inside a Program        8.0 Release START--->
			<cfinclude template="select_multi_level_view_jquery.cfm" />
		<!---D50884 :: Improvements to the Rebate/Fixed/Lumpsum Pages inside a Program        8.0 Release END--->
	</cfif>

</cfloop>
<br>

<hr style="border-top: 2px solid red;">
<cfif groupCombinationOn EQ 1>
	<A onClick="javascript: OpenProductsMessageWindow('validate_import');">#application.util.string.actionLinkFormat('validate & import groups')#</A>
<cfelse>
	<A onClick="javascript: OpenProductsMessageWindow('import');">#application.util.string.actionLinkFormat('import groups')#</A>
</cfif>
	<A onClick="javascript: window.close();">#application.util.string.actionLinkFormat('cancel')#</A>

</cfoutput>
