<!--- get operating groups to display --->
<cfparam name="form.state" 	default="0">
<cfif form.state>
	<cfparam name="form.Parent_Operating_Group_ID" 	default="">
	<cfparam name="form.Allowance_Code_ID" 			default="">
	<cfset Current_Operating_Group_Number 		= form.Operating_Group_Number />
	<cfset Current_Operating_Group_Desc 		= form.Operating_Group_Desc />
	<cfset Current_Parent_Operating_Group_ID 	= form.Parent_Operating_Group_ID />
	<cfset Current_Allowance_Code_ID 			= form.Allowance_Code_ID />	
<cfelse>
	<cfif form.id>
		<cfset qGetOperatingGroup = operatingGroupManager.get(form.level, form.id) />
		<cfset Current_Operating_Group_Number = qGetOperatingGroup.Operating_Group_Number />
		<cfset Current_Operating_Group_Desc = qGetOperatingGroup.Operating_Group_Desc />
		<cfset Current_Parent_Operating_Group_ID = Val(qGetOperatingGroup.Parent_Operating_Group_ID) />
		<cfset Current_Allowance_Code_ID = Val(qGetOperatingGroup.Allowance_Code_ID) />	
	<cfelse>
		<cfset Current_Operating_Group_Number = "" />
		<cfset Current_Operating_Group_Desc = "" />
		<cfset Current_Parent_Operating_Group_ID = 0 />
		<cfset Current_Allowance_Code_ID = 0 />	
	</cfif>
</cfif>

<cfset applyAllowanceCode = operatingGroupManager.applyAllowanceCode(form.level) />

<cfoutput>
<script>
var operatingGroupLabel = "#operatingGroupLabel#";

function showSearchWindow(sUrl, FieldName, windowName, groupLevelId)
{
	if(trim(groupLevelId) != "")
	{
		NewWindow(sUrl + '?FormName=#formName#&FieldName=' + FieldName + '&groupLevelId=' + groupLevelId , windowName , 600 , 500 , 'yes' , 'yes');
	}
	else
	{
		alert("Please select a product group type");
	}
	return false;
}

</script>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#operatingGroupLabel# Information</LEGEND>
	<table width="500">
		<TR>
			<TD ALIGN="right"><B>#operatingGroupLabel# Number:</B></TD>
			<TD>
				<span id="Err_Sp_Operating_Group_Number"></span>
				<INPUT NAME="Operating_Group_Number" TYPE="text" value="#HTMLEditFormat(trim(Current_Operating_Group_Number))#" SIZE="30" MAXLENGTH="25">
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>#operatingGroupLabel# Description:</B></TD>
			<TD><span id="Err_Sp_Operating_Group_Desc"></span><INPUT NAME="Operating_Group_Desc" TYPE="text" VALUE="#HTMLEditFormat(trim(Current_Operating_Group_Desc))#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>
		<!------ Select the parent operating group if not top level ----->
		<cfif form.level GT 1>
		<cfset parentLevel = operatingGroupManager.getParentLevelId(form.level) />
		<cfset qGetParentOperatingGroups = operatingGroupManager.get(level = parentLevel, active = 1) />
		<TR>
			<TD ALIGN="right"><B>#operatingGroupManager.getLabel(parentLevel)#:</B></TD>
			<TD><span id="Err_Sp_Parent"></span>
			<select name="Parent_Operating_Group_ID">
				<cfloop query="qGetParentOperatingGroups">
				<option value="#Operating_Group_ID#" <cfif Current_Parent_Operating_Group_ID EQ Operating_Group_ID> selected</cfif>>#Operating_Group_Number# : #Operating_Group_Desc#</option>
				</cfloop>
			</select>
			</TD>
		</TR>
		</cfif>
		<cfif applyAllowanceCode>
			<cfset allowanceCodeManager = CreateObject("component", "components.Operating_Group.AllowanceCodeManager").init() />
			<cfset qGetAllowanceCodes = allowanceCodeManager.getAllowanceCodes() />
			<cfset usedAllowanceCodes = operatingGroupManager.getUsedAllowanceCodes() />
		<TR valign="top">
			<cfset anyAllowanceCodeAvailable = 0 />
			<TD ALIGN="right"><B>Allowance Code:</B></TD>
			<TD><span id="Err_Sp_Allowance_Code"></span>
			<select name="Allowance_Code_ID" style="width:200px">
				<cfloop query="qGetAllowanceCodes">
				<cfif Current_Allowance_Code_ID EQ Allowance_Code_ID OR NOT ListFindNOCase(usedAllowanceCodes, Allowance_Code_ID)>
				<cfset anyAllowanceCodeAvailable = 1 />
				<option value="#Allowance_Code_ID#" <cfif Current_Allowance_Code_ID EQ Allowance_Code_ID> selected</cfif>>#Allowance_Code_Number# : #Allowance_Code_Desc#</option>
				</cfif>
				</cfloop>
			</select>
			<cfif anyAllowanceCodeAvailable EQ 0>			
			<font color="red">No allowance code available.</font>
			</cfif>
			</TD>
		</TR>
		</cfif>
		<cfif operatingGroupManager.getProductGroupSelectLevel() EQ form.level><!------ Display the product Group selection ----->
		<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
		<cfset qGetProductGroups = ProductGroupAttributeManager.getProductGroupAttributes(active=1) />
		
		<cfif NOT form.state>
			<!------ Get the saved values for product group selection ----->
			<cfset qGetProductGroupSelection = operatingGroupManager.getProductGroupSelection(form.id) />
			<cfset arrayProductGroupSelection		= operatingGroupManager.convertProductGroupSelectionToArray(qGetProductGroupSelection) />
			<cfset arrayProductGroupSelectionLen = ArrayLen(arrayProductGroupSelection) />
			<cfloop index="counter" from="1" to="#arrayProductGroupSelectionLen#">
				<cfset curArrayItem = arrayProductGroupSelection[counter] />
				<cfset "form.Operating_Group_Definition_Group_#counter#" = curArrayItem.Product_Group_Level_ID />
				<cfset "form.Operating_Group_Definition_Value_#counter#" = curArrayItem.Group_ID />
			</cfloop>
		</cfif>
		<TR>
			<TD colspan="2">
			<B>#operatingGroupLabel# definition</B>
			<hr color="orange">
			<table cellpadding="2" cellspacing="0" class="MainTable" width="100%">
				<cfloop from="1" to="4" index="counter">
				<cfset bgColor = "FFFFFF" />
				<cfif counter mod 2>
					<cfset bgColor = "CCFFCC" />
				</cfif>
				<tr valign="top" bgcolor="#bgColor#">
					<td>
					<cfparam name="form.Operating_Group_Definition_Group_#counter#" 		default="">
					<cfparam name="form.Operating_Group_Definition_Value_#counter#" 		default="">
					<cfset Operating_Group_Definition_Group_N = Evaluate("form.Operating_Group_Definition_Group_#counter#") />
					<cfset Operating_Group_Definition_Value_N = Evaluate("form.Operating_Group_Definition_Value_#counter#") />
					<select name="Operating_Group_Definition_Group_#counter#" style="width:200px;" selectionOnLoad="#Operating_Group_Definition_Group_N#" onchange="javaScript: changeProductGroupSelectionValues(this, #counter#);">
						<option value="">**** Select product group type ****</option>
						<cfloop query="qGetProductGroups">
						<option value="#Product_Group_Level_ID#" <cfif Operating_Group_Definition_Group_N EQ Product_Group_Level_ID>selected</cfif>>#ProductGroupAttributeManager.getProductGroupLabel(Product_Group_Level_ID)#</option>
						</cfloop>
					</select>
					<input type="Hidden" value="#counter#" name="perating_Group_Definition_List" />
					</td>
					<td id="header">					
					<input type="hidden" name="Operating_Group_Definition_Value_#counter#" value="#Operating_Group_Definition_Value_N#" onLoadValue="#Operating_Group_Definition_Value_N#">
					<!------ 
					>>>>>>>>
					Deamweaver editor users, make sure the following line is never changed automatically by your editor.... 			
					<<<<<<<
					----->					
					<cfset extraParameter = " onClick=""javascript: return showSearchWindow('/Search_Screens/ApprovalGroup_Search.cfm','Operating_Group_Definition_Value_#counter#', 'Select_Product_Group_Group', #formName#.Operating_Group_Definition_Group_#counter#.value);""" />
					&nbsp;&nbsp;
					<CF_smallLink 
						title = "select"
						url = "##"
						parameters = "#extraParameter#"
						>&nbsp;&nbsp;
					</td>
					<td width="40%">
					<cfif Operating_Group_Definition_Value_N NEQ "">
						<cfset productGroupType 	= productGroupAttributeManager.getGroupTypeInfo(groupLevelId=Operating_Group_Definition_Group_N) />
						<cfset qGetGroupValues 		= productGroupAttributeManager.getProductGroupValues(productGroupType = productGroupType, groupList = Operating_Group_Definition_Value_N) />
						<table cellpadding="0" cellspacing="0" class="NotMainTable" id="TR_Group_Detail_#counter#">
						<cfloop query="qGetGroupValues"><tr><td>#Group_Name#</td></tr></cfloop>
						</table>
					</cfif>&nbsp;
					</td>
				</tr>
				</cfloop>
			</table>
			</TD>
		</TR>
		</cfif>
		<TR valign="bottom">
			<TD COLSPAN="100%" ALIGN="center">
			<br><br><br>
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return verifyAndsubmitForm('#form.level#', 'save', '#form.id#');"""
			>
			<CF_smallLink 
				title = "cancel" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('#form.level#', 'cancel');"""
			>
			</TD>
		</TR>
	</table>
</FIELDSET>
<cf_MessageWindow />
<input name="state" type="hidden" value="1" />
</cfoutput>