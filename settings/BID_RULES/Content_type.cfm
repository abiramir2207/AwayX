<cfset this.table 	= application.returned_customer_setting.approval_criteria_table>
<cfset this.ID 		= application.returned_customer_setting.approval_criteria_table_ID>

<cfset typeexclusionlist = "">
<cfquery name="getSelectedTypes" datasource="#application.datasource#">
	SELECT DISTINCT Type_Item_ID
	FROM Bid_Rule_Items
	WHERE Deleted = 0
	<cfif len(BidRule.Basic.Bid_Rule_ID) gt 0>AND Bid_Rule_ID <> '#BidRule.Basic.Bid_Rule_ID#'</cfif>
</cfquery>
<cfset typeexclusionlist = valuelist(getSelectedTypes.Type_Item_ID)>

<cfquery name="getTypes" datasource="#application.datasource#">
	SELECT #this.ID# AS ID, #this.table# AS Type_Desc
	FROM #this.table#
	<cfif listlen(typeexclusionlist) gt 0>WHERE #this.ID# not in('#typeexclusionlist#')</cfif>
	ORDER BY Type_Desc
</cfquery>

<br><br>
<div align="center" style="color: navy; font-weight: bold; font-size: 15px;">
	Select the <cfoutput>#lcase(approval_type_name)#</cfoutput> to be used in this rule
</div>
<hr color="Orange" width="75%">
<div align="center">
<br>
<form action="" method="post" name="MyForm" id="MyForm">
<table width="200px" border="0" cellspacing="0" cellpadding="3" align="center">
		<TR ID="header" BGCOLOR="#ffce84">
			<td width="1"></td>
			<td colspan="99%"><b style="font-size: 13px;"><cfoutput>#approval_type_name#</cfoutput></b></td>
		</tr>
	<cfset columnCount = 0>
	<cfset NumberOfColumns = 3>
	<cfset currentRowCount = 1>
	<TR>
	<cfoutput query="getTypes">
		<CFIF currentRowCount mod 2><cfset BGCOLOR="white"><CFELSE><cfset BGCOLOR="ccffcc"></CFIF>
		<cfif columnCount EQ NumberOfColumns><TR></cfif>
			<td BGCOLOR="#BGCOLOR#"><input type="checkbox" name="Type_#getTypes.currentrow#" value="#getTypes.ID#" <cfif listfind(BidRule.Type.Current_Index,lcase(getTypes.ID)) GT 0>Checked</cfif>></td>
			<td BGCOLOR="#BGCOLOR#" nowrap>#getTypes.Type_Desc#</td>
		<cfset columnCount = columnCount + 1>
		<cfif columnCount EQ NumberOfColumns></TR><cfset columnCount = 0><cfset currentRowCount = currentRowCount + 1></cfif>
	</cfoutput>
</table>

<input type="Hidden" name="SuppliedDataType" 	value="type">
<input type="Hidden" name="sg" 					value="<cfoutput>#BidRule.sessionGUID#</cfoutput>">
<input type="Hidden" name="nextTab" 			value="exceptions">
</form>

<hr color="Orange" width="75%">
<div align="center">
	<CF_button
		button_name		=	""
		button_caption	=	"continue"
		button_action	=	"document.all.MyForm.action = 'packet_modifier.cfm'; document.all.MyForm.submit();"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</div>

