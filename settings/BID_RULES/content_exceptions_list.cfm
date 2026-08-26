<!--- get list of currently selected groups--->
<cfset list_of_selected_groups = "">
<cfloop index="x" from="1" to="#BidRule.Exceptions.Index_Count#" step="1">
	<cfset currentnode = evaluate("BidRule.Exceptions.Groups.Group_#x#")>
	
	<cfif len(trim(currentnode.exception_group_id)) GT 0>
		<cfset list_of_selected_groups = listappend(list_of_selected_groups, currentnode.exception_group_id)>
	</cfif>
</cfloop>

<cfset useLakebaseForgetExeptionGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("exception_groups")>
<cfif useLakebaseForgetExeptionGroups>
	<cftry>
		<cfset getExeptionGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("exception_groups", {
				"deleted" = "eq.0",
				"order" = "group_name.asc",
				"select" = "exception_group_id,group_name"
			}), "exception_group_id,group_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetExeptionGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetExeptionGroups>
<cfquery name="getExeptionGroups" datasource="#application.datasource#">
	SELECT Exception_Group_ID, Group_Name
	FROM Exception_Groups
	WHERE Deleted = 0
	ORDER By Group_Name
</cfquery>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<script>
		function verifyData() {
			document.MyForm.submit();
		}
	</script>
	
</head>

<body>


<BR><BR>
<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">
	Check a group to include it, uncheck it to remove it.
</div>
<hr color="Orange" width="75%">
<BR>

<form action="packet_modifier.cfm" method="post" name="MyForm" id="MyForm">
<cfif getExeptionGroups.recordcount EQ 0>
	<div align="center" style="color:red; font-weight: bold; font-size: 15px;">There are no existing Exception Groups.</div>
<cfelse>
	<cfloop query="getExeptionGroups">
		<cfset thisException_Group_ID = getExeptionGroups.Exception_Group_ID>
		
		<cfquery name="getProducts" datasource="#application.datasource#">
			SELECT Item, UPC, Description, BSA_Foodservice_Items_Master_ID AS ID
			FROM BSA_Foodservice_Items_Master
			WHERE BSA_Foodservice_Items_Master_ID IN(SELECT Product_ID FROM Exception_Group_Products WHERE Exception_Group_ID = '#thisException_Group_ID#' AND Deleted = 0)
			ORDER BY Description
		</cfquery>
		
	<cfoutput>
	
	<table align="center">
		<tr>
			<td valign="bottom">
				<input type="Checkbox" name="CurrentGroupList" value="#thisException_Group_ID#" <cfif listfind(list_of_selected_groups, thisException_Group_ID) NEQ 0> checked</cfif>><span style="color: Red;  font-weight: bold; font-size: 15px;">#getExeptionGroups.Group_Name#</span>
				<input type="Hidden" name="Group_#thisException_Group_ID#_Name" value="#getExeptionGroups.group_name#">
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
					</tr>
				<cfif getProducts.recordcount GT 0>
				<cfloop query="getProducts">
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" <!--- ONMOUSEOVER="menuID=6;URLstring='';an_ID='#searchProducts.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;" --->>
						<TD ID="header">&nbsp;</td>
						<td>#getProducts.Item#</td>
						<td>#getProducts.UPC#</td>
						<td>#getProducts.Description#</td>
					</tr>
					<input type="Hidden" name="Group_#thisException_Group_ID#_ProductList" value="#valuelist(getProducts.ID)#">
			
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
	</cfoutput>
	</cfloop>
</cfif>

<input type="Hidden" name="SuppliedDataType" 	value="exception_list">
<input type="Hidden" name="sg" 					value="<cfoutput>#BidRule.sessionGUID#</cfoutput>">
<input type="Hidden" name="nextTab" 			value="exceptions">
<input type="Hidden" name="list_of_selected_groups" value="#list_of_selected_groups#">

</form>

<hr color="Orange" width="75%">
<div align="center">
	<CF_button
		button_name		=	""
		button_caption	=	"continue"
		button_action	=	"verifyData();"
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
