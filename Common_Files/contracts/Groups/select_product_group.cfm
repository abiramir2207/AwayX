<cfoutput>

<b>Select Level:</b>&nbsp;
<!---allow multi level select if it's on--->
<cfif form.Allow_Multi_Levels eq 1>
<select name="Pricing_Level_ID" onChange="checkLevel(this.options[this.selectedIndex].value)">
	<option>Select Level...</option>
	<option value="1">Level 1</option>
	<!---don't allow group levels that have products in them--->
	<cfif form.GroupLevel_2 neq 9>
		<option value="2">Level 2</option>
	</cfif>
	<cfif form.GroupLevel_3 neq 9 and form.GroupLevel_2 neq 9>
		<option value="3">Level 3</option>
	</cfif>
</select>
<cfelse>
	Level 1
	<input type="hidden" name="Pricing_Level_ID" value="1" />
</cfif>


<p>
<table width="760" border="1" cellpadding="1" cellspacing="0" style="border:thin">
	<tr>
		<td colspan="100%" bgcolor="##E1E1FF" id="header"><b>Select Groups:</b>&nbsp;
			<select name="Product_Group_Level_ID" onChange="enableGroupSelect(this.options[this.selectedIndex].value, this.options[this.selectedIndex].id)">
				<option>Select Group...</option>
				<cfloop index="indx" from="1" to="#ArrayLen(objTopGroups)#">
					<option id="#objTopGroups[indx].getProductGroupLevelType()#" value="#objTopGroups[indx].getGroupLevelId()#">#objTopGroups[indx].getGroupLevelDesc()#</option>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<td>
			<table width="760" border="0" cellpadding="1" cellspacing="0">
	
				<tr>
			
					<cfloop index="indx" from="1" to="#ArrayLen(objTopGroups)#">
						
						<!---set the group object for this array element--->
						<cfset thisTopGroup = objTopGroups[indx] />
						
						<td valign="top" id="oGroupTR_#thisTopGroup.getGroupLevelId()#" disabled>

							<b>#thisTopGroup.getGroupLevelDesc()#</b><br>
							
							<cfset objGroupManager2 = CreateObject("component", "components.products.Group.GroupManager").getByProductGroup(thisTopGroup.getGroupLevelId()) />
							<cfset objGroups = objGroupManager2.getGroups() />
							
							<select name="Product_Group_ID" <cfif form.SelectSingleSearchResultOnly eq 0>multiple</cfif> disabled id="oGroupSelect_#thisTopGroup.getGroupLevelId()#" onChange="setGroupLevel(#thisTopGroup.getGroupLevelId()#)">
								
								<cfloop index="indx2" from="1" to="#ArrayLen(objGroups)#">
									
									<cfset thisGroup = objGroups[indx2] />

									<cfif ListFindNoCase(form.Product_List, thisGroup.getProductGroupId())>
										<cfset request.isSelected = "selected" />
									<cfelse>
										<cfset request.isSelected = "" />
									</cfif>

									<option value="#thisGroup.getProductGroupId()#" #request.isSelected#>#thisGroup.getGroupLevelDesc()#</option>
									
									
								</cfloop>
								
							</select>
								
						</td>
						<cfif indx mod 2 eq 0>
						</tr>
						<tr><td colspan="100%">&nbsp;</td></tr>
						<tr>
						</cfif>
						
						<!---append this id to the group list --->
						<cfset form.Product_Group_List = ListAppend(form.Product_Group_List, thisTopGroup.getGroupLevelId()) />
						
					</cfloop>
				
				</tr>
		
			</table>
		</td>
	</tr>
</table>

<br>
<CF_smallLink 
	title = "select group" 
	url = "##"
	parameters = "onClick=""javascript: submitForm('import');"""
>

<CF_smallLink 
	title = "cancel" 
	url = "##"
	parameters = "onClick=""javascript: window.close();"""
>

<CF_smallLink 
	title = "reset" 
	url = "##"
	parameters = "onClick=""javascript: document.groupDataForm.reset();"""
>

</cfoutput>