<!---  operator_category_assign.cfm --->
<CFOUTPUT>
<cfparam name="form.Operator_List" 	default="">
<cfparam name="form.sort_by" 	default="Operator Name">
<cfparam name="form.sort_order" 	default="ASC">


<INPUT type="Hidden" name="Operator_List" value="#form.Operator_List#"><!------ operator id ----->
<cfif form.id>
	<cfset qThisCat = category.getCategory(form.id)>	
</cfif>
<cfset operator = CreateObject("component","components.customer.operator.operator") />
<cfset StSearch = StructNew()>
<cfset StSearch.idList = form.Operator_List>	
<cfset GetOperators = operator.getOperator(StSearch, form.sort_by, form.sort_order)>

<cfif form.doAction EQ "assignCategoryAction">
	<!------ save ----->
	<cfset category.assignCategory(form.id, form.Operator_List)>
	<script language="JavaScript">
	gotoSuccessPage();
	function gotoSuccessPage()
	{
		submitForm('assignCategorySuccess', #form.id#);
	}
	</script>
	<!------ <cflocation addtoken="No" url="#ThisPage#?doAction=assignCategorySuccess&mode=3"> ----->
<cfelseif form.doAction EQ "assignCategorySuccess">
	<cfif form.id>
		<!------ display category info ----->		
		<br><br><br>
		<center>
		<span class="Title2">
		The following operators have been successfully assigned to '<B>#qThisCat.Category_Label#</B>' category		
		</span></center>
		
		<br><br>
		<cfset qSource = GetOperators>	
		<cfset fieldName = "Operator_Name">
		<cfset maxRows = 4>
		<cfinclude template="../success_display.cfm">
	</cfif>	
<cfelse>


<INPUT type="Hidden" name="state" value="assign_start">
<INPUT type="Hidden" name="SelectSingleSearchResultOnly" value="0">

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script language="JavaScript">	
	function confirmAssign(recCountObj, catName, id)
	{
		var recCount = listLength(recCountObj.value, ",");
		if(window.confirm("Do you want to assign all " + recCount + " operators to the category '" + catName + "'"))
		{
			submitForm('assignCategoryAction', id);
			show_please_wait(document.all.Hide_For_Please_Wait);
		}
		return false;
	}
</script>

<!------ category ----->
Select an operator category, then search for operators that you would like to assign to that category.
<p>
<SPAN CLASS="Title2">Operator Categories</SPAN>&nbsp;&nbsp;&nbsp;
<B><FONT COLOR="FF0000">[</FONT><a HREF="javascript: void(0);" onclick="NewWindow('category/operator_category_select.cfm?Formname=#formName#&fieldName=id&importType=single', 'Operator_Category', '400', '500', 'Yes', 'No', true);">select operator category</a><FONT COLOR="FF0000">]</FONT></B>
<BR>
<TABLE width="40%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="FFCE84">
		<TD STYLE="font-size:11px;">
			<b>Category</b>
		</TD>
		<TD>&nbsp;
			
		</TD>
	</TR>
	<TR>
<cfif form.id>
	<!------ display category info ----->	
	<td>#qThisCat.Category_Label#</td>
	<td>
		<a href="javascript: void(0);"  OnClick="NewWindow('category/category_operators.cfm?id=#form.id#', 'Operators', '800', '600', 'Yes', 'No', true);">view operators</a>	
	</td>	
<cfelse>
	<td>NONE SELECTED</td>
	<td>&nbsp;</td>
</cfif>
	</tr>
</TABLE>
<BR><BR>
<SPAN CLASS="Title2">Operators</SPAN>&nbsp;&nbsp;&nbsp;
<B><FONT COLOR="FF0000">[</FONT><A HREF="javascript: void(0);"  OnClick="NewWindow('/Billbacks/search_screens/PM_select_operators.cfm?Formname=#formName#', 'Operators', '800', '600', 'Yes', 'No', true);">search operator</a><FONT COLOR="FF0000">]</FONT></B>
<cfif form.Operator_List NEQ "">
	<BR>
	<CFSET pageLength = 8>
	<CFSET showDelete  = true>
	<CFSET inputName = "Operator_List">
	<CFSET skeyword = "operator">
	<cfinclude template="/settings/operator_tree/displayOperatorList.cfm">
<cfelse>
	<TABLE width="90%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
		<TR ID="HEADER" BGCOLOR="FFCE84">
			<TD STYLE="font-size:11px;">
				<b>Operators</b>
			</TD>
		</TR>
		<tr>
			<td>NONE SELECTED</td>
		</tr>
	</table>
</cfif>

<cfif form.Operator_List NEQ "" AND form.id>
	<BR>
	<CENTER><B><FONT COLOR="FF0000">[</FONT><a HREF="javaScript: void(0);" onclick="javaScript: return confirmAssign(document.all.Operator_List, '#qThisCat.Category_Label#', #form.id#);">assign</a><FONT COLOR="FF0000">]</FONT></B></CENTER>
</cfif>
</cfif>
</CFOUTPUT>
