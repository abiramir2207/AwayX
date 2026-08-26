<CFOUTPUT>
<CFSET formName = "frmOperatorPosition">
<cfparam name="url.doAction" 	default="select">
<cfparam name="form.doAction" 	default="#url.doAction#">

<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<script language="JavaScript">
	function submitForm(sAction)
	{
		var oForm = document.#formName#;
		oForm.doAction.value = sAction;
		oForm.submit();		
		return false;
	} 
	function confirmAssign(recCountObj, destName)
	{
		var recCount = listLength(recCountObj.value, ",");
		if(window.confirm("Do you want to assign all " + recCount + " operator(s) to the position '" + destName + "'"))
		{
			submitForm('save');
			show_please_wait(document.all.Hide_For_Please_Wait);
		}
		return false;
	}	
</script>
<CFPARAM NAME="FORM.Position_List" 	DEFAULT="0">
<CFPARAM NAME="FORM.Operator_List" 	DEFAULT="">
<cfparam name="FORM.sort_by" 	default="Operator Name">
<cfparam name="FORM.sort_order" 	default="ASC">

<cfset position = CreateObject("component", "components.geography.position") />
<cfset getPosition = QueryNew("Position_Label")>
<cfif FORM.Position_List>
	<cfset getPosition = position.getPosition(FORM.Position_List)>
</cfif>

<cfset operator = CreateObject("component","components.customer.operator.operator") />
<cfset StSearch = StructNew()>
<cfset StSearch.idList = form.Operator_List>	
<cfset GetOperators = operator.getOperator(StSearch, form.sort_by, form.sort_order)>	

<form action="#ThisPage#" method="post" name="#formName#">
	<input type="Hidden" name="mode" value="#FORM.mode#">
	<input type="Hidden" name="doAction" value="#FORM.doAction#">
	<INPUT type="Hidden" name="Position_List" value="#FORM.Position_List#">
	<INPUT type="Hidden" name="SelectSingleSearchResultOnly_Position" value="1">
	<INPUT type="Hidden" name="SelectSingleSearchResultOnly" value="0">
	<INPUT type="Hidden" name="Operator_List" value="#FORM.Operator_List#">
<cfif form.doAction EQ "save">
	<cfif IsNumeric(FORM.Position_List)>

		<cfset operator.saveOperatorPosition(FORM.Position_List, FORM.Operator_List)>			
		<script language="JavaScript">
			submitForm('message');
		</script>
		
	</cfif>	
<cfelseif form.doAction EQ "message">
	<BR><BR>
	<center>
	<span class="Title2">The following operators have been assigned successfully to '#getPosition.Position_Label#' position.</span></center>
	<cfset qSource = GetOperators>	
	<cfset fieldName = "Operator_Name">
	<cfset maxRows = 4>
	<cfinclude template="../success_display.cfm">
<cfelse>
	
	<!------ Position ----->
	<SPAN CLASS="Title2">Position - Assign</SPAN>
	<HR COLOR="Orange">
	Select a Position then search for operators that you would like to assign to that Position.
	<p>
	<SPAN CLASS="Title2">Position</SPAN>&nbsp;&nbsp;&nbsp;
	<B><FONT COLOR="FF0000">[</FONT><a HREF="javascript: void(0);" onclick="javaScript: return search_popup('/search_screens/Position_Search.cfm?FormName=#formName#&FieldName=Position_List');">search position</a><FONT COLOR="FF0000">]</FONT></B>
	<TABLE width="75%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="FFCE84">
		<TD STYLE="font-size:11px;"><b>Position</b></TD>
		<TD STYLE="font-size:11px;"><B>Zone</B></TD>
		<td STYLE="font-size:11px;"><B>Region</B></td>
		<td STYLE="font-size:11px;"><B>Market</B></td>
		<td>&nbsp;</td>
	</TR>
	<TR>
	<CFIF getPosition.RecordCount GT 0>
		<td>#getPosition.Position_Label#</td>
		<td>
			<CFIF getPosition.Zone_Name NEQ "">
				#getPosition.Zone_Name#
			<cfelse>
				N/A
			</CFIF>
			</td>
		<td>
			<CFIF getPosition.Region_Name NEQ "">
				#getPosition.Region_Name#
			<cfelse>
				N/A
			</CFIF>
		</td>
		<td>
			<CFIF getPosition.Market_Name NEQ "">
				#getPosition.Market_Name#
			<cfelse>
				N/A
			</CFIF>
		</td>
		<td>
			<A HREF="javascript: void(0);"  OnClick="NewWindow('position/Position_Operators.cfm?UID=#getPosition.User_Positions_ID#', 'Position_Operators', '800', '600', 'Yes', 'No', true);">Operators in this position</A>
		</td>		
	<CFELSE>
		<td colspan="10">NONE SELECTED</td>
	</CFIF>
	</tr>
	</table>
	<br><br>
	<!------ Operator ----->
	<SPAN CLASS="Title2">Operators</SPAN>&nbsp;&nbsp;&nbsp;
	<B><FONT COLOR="FF0000">[</FONT><A HREF="javascript: void(0);"  OnClick="NewWindow('/Billbacks/search_screens/PM_select_operators.cfm?Formname=#formName#', 'Operators', '800', '600', 'Yes', 'No', true);">search operator</a><FONT COLOR="FF0000">]</FONT></B>
	<cfif GetOperators.RecordCount GT 0>
		<cfset pageLength = 8>
		
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

	<cfif FORM.Operator_List NEQ "" AND FORM.Position_List>
		<BR>
		<CENTER><B><FONT COLOR="FF0000">[</FONT><a HREF="javaScript: void(0);" onclick="javaScript: return confirmAssign(document.all.Operator_List, '#getPosition.Position_Label#');">assign</a><FONT COLOR="FF0000">]</FONT></B></CENTER>
	</cfif>	

</cfif>
</form>
</CFOUTPUT>