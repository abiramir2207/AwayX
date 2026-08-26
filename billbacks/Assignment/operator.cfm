<!------ operators.cfm ----->

<cfif form.subcommand EQ "save">
	<!------ save in database ----->
	
	<cfparam name="form.Analyst_Record_Count" 	default="">
	
	<cfif IsNumeric(form.Analyst_Record_Count)>
		<cfloop index="index" from="1" to="#form.Analyst_Record_Count#">
			<cfparam name="Form.Analyst_User_ID_#index#" 	default="">
			<cfparam name="Form.Operator_ID_#index#" 	default="">
			<cfset Analyst_User_ID = Evaluate("Form.Analyst_User_ID_#index#") />
			<cfset Operator_ID_List = Evaluate("Form.Operator_ID_#index#") />		
			
			<cfif Analyst_User_ID NEQ "">
					<cfset billbackAssignmentManager.saveAnalystOperators(
						analystUserID = Analyst_User_ID,
						OperatorIDList = Operator_ID_List,
						byUserId = request.AccessStructure.User_ID) />
			</cfif>			
		</cfloop>
	</cfif>
	
	<cfinclude template="nextPage.cfm" />
	<cfset form.command = form.nextCommand />
	<cfset nextPage = "index.cfm?command=#form.command#" />
	<cflocation addtoken="No" url="#nextPage#" />
</cfif>
<cfparam name="Form.Assign_New_Operators_to_Default_Analyst"    default="0">
<cfparam name="Form.saveAssignNewOperators"   default="0">
<cfoutput>
<cfif  #Form.saveAssignNewOperators# eq 1 >
	<cfquery name="updateAssign_New_Operators_to_Default_Analyst" datasource="#application.datasource#">
		update _application_settings
		set Assign_New_Operators_to_Default_Analyst = #Form.Assign_New_Operators_to_Default_Analyst#
	</cfquery>
</cfif>
</cfoutput>

<cfif NOT isDefined("qGetAnalysts")><!------ might be already called in nextPage.cfm ----->
<cfset qGetAnalysts = billbackAssignmentManager.getAnalysts() />
</cfif>
<cfset qGetAvailableOperators = billbackAssignmentManager.getAvailableOperators() />
<cfset Form.Assign_New_Operators_to_Default_Analyst = billbackAssignmentManager.getAssignNewOperatorsToDefaultAnalyst() />

<script language="JavaScript">

	document.body.onscroll = new Function("settimeoutScroll()");
	var timeout1 = null;
	var sDiv = "Div_Operator";
	function settimeoutScroll()
	{
		if(timeout1)
		{
			window.clearTimeout(timeout1);
		}
		timeout1 = window.setTimeout("scroll_div()", 0);
	}
	
</script>
<FIELDSET STYLE="padding:8px; border: 1px solid Blue;" width="90%">
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Assign new operators to default analyst</LEGEND>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="650" >
	<tr valign="top" align="right">
		<td nowrap  style="border-bottom:none;">
			Assign New Operators to Default Analyst <input value="1" type="checkbox" name="Assign_New_Operators_to_Default_Analyst" <cfif Form.Assign_New_Operators_to_Default_Analyst eq 1>checked</cfif>>
		</td>	
		<td align="left" valign="bottom">
			<CF_button
			button_name		=	""
			button_caption	=	"save"
			button_action	=	"return updateAssignNewOperators()"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>	
		</td>	
	</tr>
</table>
</FIELDSET>
<input type ="hidden" name="saveAssignNewOperators" value ="0" />

<BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="780" align="center" STYLE="WIDTH: 780px;">
<TR>
<TD WIDTH="375"  VALIGN="Top" STYLE="WIDTH: 375px;">
<cfoutput><INPUT TYPE="Hidden" NAME="Analyst_Record_Count" VALUE="#qGetAnalysts.recordcount#"></cfoutput>
<cfloop query="qGetAnalysts">
	<cfset qGetAnalystOperators = billbackAssignmentManager.getAnalystOperators(Analyst_User_ID) />
	<cfoutput><INPUT TYPE="Hidden" NAME="Analyst_User_ID_#currentrow#" VALUE="#Analyst_User_ID#"></cfoutput>
	<CF_openLayer
			Border="Yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="<CFOUTPUT>#Name_First# #Name_Last#</CFOUTPUT>:"  
			TitleClosed="<CFOUTPUT>#Name_First# #Name_Last#</CFOUTPUT>:"  
			TitleTooltip="Click to Show/Hide Criteria Used"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="Yes"  
			Width="375px">	
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<TD VALIGN="Top" WIDTH="350">
					<cfoutput><SELECT NAME="Operator_ID_#currentrow#" SIZE="4" STYLE="WIDTH:350px" MULTIPLE></cfoutput>
						<cfloop QUERY="qGetAnalystOperators">
							<cfoutput><OPTION VALUE="#qGetAnalystOperators.Operator_ID#" title="#qGetAnalystOperators.Operator_Name# [#qGetAnalystOperators.Operator_Type#] #qGetAnalystOperators.Operator_City#, #qGetAnalystOperators.Operator_State#">#qGetAnalystOperators.Operator_Name# [#qGetAnalystOperators.Operator_Type#] #qGetAnalystOperators.Operator_City#, #qGetAnalystOperators.Operator_State#</OPTION></cfoutput>
						</cfloop>
					</SELECT>
				</TD>
				<TD WIDTH="20">&nbsp;</TD>
				<TD VALIGN="Top" WIDTH="27" ALIGN="center">
					<cfoutput><INPUT TYPE="BUTTON" NAME="Add_Operator_#currentrow#" VALUE="<" ONCLICK="Javascript: Add_Remove_Selected_Users('Service_Operator_ID','Operator_ID_#currentrow#', 1)" STYLE="WIDTH:26px"></cfoutput><BR>
					<cfoutput><INPUT TYPE="BUTTON" NAME="Remove_Operator_#currentrow#" VALUE=">" ONCLICK="Javascript:Add_Remove_Selected_Users('Operator_ID_#currentrow#','Service_Operator_ID', 2)" STYLE="WIDTH:26px"></cfoutput><BR>
					<cfoutput><INPUT TYPE="BUTTON" NAME="Remove_All_#currentrow#" VALUE=">>" ONCLICK="Javascript: remove_all('Operator_ID_#currentrow#','Service_Operator_ID')" STYLE="WIDTH:26px"></cfoutput><BR>
				</TD>
			</TR>
			
		</TABLE>
		</CF_openLayer>
</cfloop>
</TD>
<TD WIDTH="20">&nbsp;</TD>
<TD ALIGN="Left" valign="top">
	<DIV STYLE="display:inline;" ID="Div_Operator">
	<SELECT NAME="Service_Operator_ID"  SIZE="26" MULTIPLE STYLE="WIDTH: 375px;">
		<cfloop QUERY="qGetAvailableOperators">
			<cfoutput><OPTION VALUE="#qGetAvailableOperators.Operator_ID#" title="#qGetAvailableOperators.Operator_Name# [#qGetAvailableOperators.Operator_Type#] #qGetAvailableOperators.Operator_City#, #qGetAvailableOperators.Operator_State#">#qGetAvailableOperators.Operator_Name# [#qGetAvailableOperators.Operator_Type#] #qGetAvailableOperators.Operator_City#, #qGetAvailableOperators.Operator_State#</OPTION></cfoutput>
		</cfloop>
	</SELECT>
	</DIV>
</TD>
</TR>

<TR>
	<TD COLSPAN="100%" ALIGN="Center"><BR>
	<CF_button
			button_name		=	""
			button_caption	=	"Assign Operator"
			button_action	=	"return submitForm('#form.command#', 'save')"
			button_type		=	"javascript_link"
			button_width	=	"100"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
						>
	</TD>
</TR>
</TABLE>
