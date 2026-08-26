<cfoutput>
<script language="javascript">
function OpenProductsMessageWindow(ImportCriteria)
{
		<cfif ProductMessages.Message_Settings eq 1>
				winprops = 'height=175,width=250,top=300,left=350,scrollbars=no,resizable=no,toolbar=no,directories=no,location=no,status=no,menubar=no,titlebar=no'
				window.open("/Product_Add_Confirmation_Message.cfm?Program_ID=#PROGRAMID#&Discountype=#Discountype#&ImportCriteria="+ImportCriteria,"ProductMessageWindow",winprops);
		<cfelse>
			submitForm(ImportCriteria);
		</cfif>
}
</script>
<cfset productGroupAttributeManager = createobject("component", "components.products.group.ProductGroupAttributeManager")>
<input name="groupCombinationOn" type="hidden" value="#groupCombinationOn#" />
<table width="760" border="1" cellpadding="1" cellspacing="0" style="border:thin">
	<tr>
		<td colspan="100%" bgcolor="##EAEAEA" id="header">
			<b>#sPricingLevelDesc#</b>&nbsp;
			<cfif ApplicationSettingsManager.getSearchSequenceOn() AND groupCombinationOn EQ 1>
				<input name="GroupLevel" type="hidden" value="#groupCombinationProductGroupLevelId#" />
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
			
				<select name="GroupLevel">
					<option value="">Select Group...</option>
					<cfloop query="qGetTopLevelGroups">
						<cfif searchSequenceManager.enableThisProductGroupSelection(qGetSearchSequenceInfo, Search_Sequence_Field)>
						<option value="#Product_Group_Level_ID#" <cfif Product_Group_Level_ID eq Evaluate("form.GroupLevel_1")>selected</cfif>>#Group_Level_Desc#</option>
						</cfif>
					</cfloop>
				</select>
			<cfelse>
				<select name="GroupLevel">
					<option value="">Select Group...</option>
					<cfloop query="qGetTopLevelGroups">
						<option value="#Product_Group_Level_ID#" <cfif Product_Group_Level_ID eq form.GroupLevel_1>selected</cfif>>#Group_Level_Desc#</option>
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
		</td>
	</tr>
</table>
<br>
<table width="760" border="1" cellpadding="1" cellspacing="0" style="border:thin">
	<tr>
		<td style="border-bottom:none" colspan="100%">
			<font color="##000066" size="2"><b>Groups</b></font>
			&nbsp;
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
		</td>
	</tr>
	<tr>
		<td style="border-top:none">
			<table width="760" border="0" cellpadding="0" cellspacing="0" style="border:thin" CLASS="Maintable">
				<tr BGCOLOR="##FFCE84">
					<td id="header" colspan="100%">
						<cfif form.SelectSingleSearchResultOnly eq 0>					
							<input name="" type="checkbox" value="" onClick="javaScript: selectAll(this, 'Level_1');" <cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Products_Added eq 2>style="background-color: cccccc" DISABLED</cfif>/>
						</cfif>&nbsp;&nbsp;
						<b>Group</b>
					</td>
				</tr>
				<!---if we have a record set then display list, otherwise show none--->
				<cfif qGetGroups.RecordCount>
					
					<!---check to see if the record count is even or odd--->
					<cfset oddEvenCount = Evaluate(qGetGroups.RecordCount mod 2) />
					
					<tr>
					<cfloop query="qGetGroups">
						<cfset sStyle = "" />
						<cfif CurrentRow eq RecordCount or oddEvenCount eq 0 and CurrentRow eq RecordCount - 1>
							<cfset sStyle = "border-bottom:none" />
						</cfif>
						<td style="#sStyle#" nowrap>
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
							<a href="javascript:NewWindow('group_items.cfm?Group_ID=#Product_Group_ID#&Group_Level_ID=#form.GroupLevel_1#<cfif businessSegManager.isEnabled()>&programId=#url.programId#</cfif>', 'groupitemwindow', 600, 600, 'yes', 'yes');"><cfif isDefined("qGetGroups.Group_ID")>#Group_ID# - </cfif>#Group_Level_Desc#
							<!--- TSF - Label 11712: Remove product count for groups--->
<!--- 							<cfif IsDefined("Product_Count")>
								(#NumberFormat(Product_Count, "_")# products)
							</cfif> ---></a>
						</td>
						<!---end table row for every other row--->
						<cfif not CurrentRow Mod 2>

							</tr>
							
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
<br>
<CF_smallLink 
	title = "cancel" 
	url = "##"
	parameters = "onClick=""javascript: window.close();"""
>
</cfoutput>