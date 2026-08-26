<!------ distributor.cfm ----->

<cfif form.subcommand EQ "save">
	<!------ save in database ----->
	
	<cfparam name="form.Analyst_Record_Count" 	default="">
	
	<cfif IsNumeric(form.Analyst_Record_Count)>
		<cfloop index="index" from="1" to="#form.Analyst_Record_Count#">
			<cfparam name="Form.Analyst_User_ID_#index#" 	default="">
			<cfparam name="Form.Distributor_ID_#index#" 	default="">
			<cfset Analyst_User_ID = Evaluate("Form.Analyst_User_ID_#index#") />
			<cfset Distributor_ID_List = Evaluate("Form.Distributor_ID_#index#") />
			
			
			<cfif Analyst_User_ID NEQ "">
					<cfset billbackAssignmentManager.saveAnalystDistributors(
						analystUserID = Analyst_User_ID,
						DistributorIDList = Distributor_ID_List,
						byUserId = request.AccessStructure.User_ID) />
			</cfif>
			
		</cfloop>
	</cfif>
	
	<cfinclude template="nextPage.cfm" />
	<cfset form.command = form.nextCommand />
	<cfset nextPage = "index.cfm?command=#form.command#" />
	<cflocation addtoken="No" url="#nextPage#" />
</cfif>
<cfparam name="Form.Assign_New_Distributors_to_Default_Analyst"    default="0">
<cfparam name="Form.saveAssignNewDistributors"   default="0">
<cfoutput>
<cfif  #Form.saveAssignNewDistributors# eq 1 >
	<cfquery name="updateAssign_New_Distributors_to_Default_Analyst" datasource="#application.datasource#">
		update _application_settings
		set Assign_New_Distributors_to_Default_Analyst = #Form.Assign_New_Distributors_to_Default_Analyst#
	</cfquery>
</cfif>
</cfoutput>

<cfif NOT isDefined("qGetAnalysts")><!------ might be already called in nextPage.cfm ----->
<cfset qGetAnalysts = billbackAssignmentManager.getAnalysts() />
</cfif>
<cfset qGetAvailableDistributors = billbackAssignmentManager.getAvailableDistributors() />
<cfset Form.Assign_New_Distributors_to_Default_Analyst = billbackAssignmentManager.getAssignNewDistributorsToDefaultAnalyst() />

<script language="JavaScript">

	document.body.onscroll = new Function("settimeoutScroll()");
	var timeout1 = null;
	var sDiv = "Div_Distributor";
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
<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Assign new distributors to Default Analyst</LEGEND>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="650" >
	<tr valign="top" align="right">
		<td nowrap  style="border-bottom:none;">
		Assign new distributors to Default Analyst <input value="1" type="checkbox" name="Assign_New_Distributors_to_Default_Analyst" <cfif Form.Assign_New_Distributors_to_Default_Analyst eq 1>checked</cfif>>
		</td>	
		<td align="left" valign="bottom">
			<CF_button
			button_name		=	""
			button_caption	=	"save"
			button_action	=	"return updateAssignNewDistributors()"
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
<input type ="hidden" name="saveAssignNewDistributors" value ="0" />

<BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="780" align="center" STYLE="WIDTH: 780px;">
<TR>
<TD WIDTH="375"  VALIGN="Top"  STYLE="WIDTH: 375px;">
<cfoutput><INPUT TYPE="Hidden" NAME="Analyst_Record_Count" VALUE="#qGetAnalysts.recordcount#"></cfoutput>
<cfloop query="qGetAnalysts">
	<cfset qGetAnalystDistributors = billbackAssignmentManager.getAnalystDistributors(Analyst_User_ID) />
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
				<!--- <TD VALIGN="Top" WIDTH="150" NOWRAP>&nbsp;&nbsp;</TD>			 --->
				<TD VALIGN="Top" WIDTH="350">
					<cfoutput><SELECT NAME="Distributor_ID_#currentrow#" SIZE="4" STYLE="WIDTH:350px" MULTIPLE></cfoutput>
						<cfloop QUERY="qGetAnalystDistributors">
							<cfoutput><OPTION VALUE="#qGetAnalystDistributors.Distributor_ID#" title="#qGetAnalystDistributors.Name# [#qGetAnalystDistributors.Shr_Ship_To#] #qGetAnalystDistributors.City#, #qGetAnalystDistributors.State#">#qGetAnalystDistributors.Name# [#qGetAnalystDistributors.Shr_Ship_To#] #qGetAnalystDistributors.City#, #qGetAnalystDistributors.State#</OPTION></cfoutput>
						</cfloop>
					</SELECT>
				</TD>
				<TD WIDTH="20">&nbsp;</TD>
				<TD VALIGN="Top" WIDTH="27" ALIGN="center">
					<cfoutput><INPUT TYPE="BUTTON" NAME="Add_Distributor_#currentrow#" VALUE="<" ONCLICK="Javascript: Add_Remove_Selected_Users('Service_Distributor_ID','Distributor_ID_#currentrow#', 1)" STYLE="WIDTH:26px"></cfoutput><BR>
					<cfoutput><INPUT TYPE="BUTTON" NAME="Remove_Distributor_#currentrow#" VALUE=">" ONCLICK="Javascript:Add_Remove_Selected_Users('Distributor_ID_#currentrow#','Service_Distributor_ID', 2)" STYLE="WIDTH:26px"></cfoutput><BR>
					<cfoutput><INPUT TYPE="BUTTON" NAME="Remove_All_#currentrow#" VALUE=">>" ONCLICK="Javascript: remove_all('Distributor_ID_#currentrow#','Service_Distributor_ID')" STYLE="WIDTH:26px"></cfoutput><BR>
				</TD>
				<!--- <TD WIDTH="10">&nbsp;</TD> --->
			</TR>
			
		</TABLE>
		</CF_openLayer>
</cfloop>
</TD>
<TD WIDTH="20">&nbsp;</TD>
<TD ALIGN="Left" valign="top">
	<DIV STYLE="display:inline;" ID="Div_Distributor">
	<SELECT NAME="Service_Distributor_ID"  SIZE="26" MULTIPLE STYLE="WIDTH: 375px;">
		<cfloop QUERY="qGetAvailableDistributors">
			<cfoutput><OPTION VALUE="#qGetAvailableDistributors.Distributor_ID#" title="#qGetAvailableDistributors.Name# [#qGetAvailableDistributors.Shr_Ship_To#] #qGetAvailableDistributors.City#, #qGetAvailableDistributors.State#">#qGetAvailableDistributors.Name# [#qGetAvailableDistributors.Shr_Ship_To#] #qGetAvailableDistributors.City#, #qGetAvailableDistributors.State#</OPTION></cfoutput>
		</cfloop>
	</SELECT>
	</DIV>
</TD>
</TR>

<TR>
	<TD COLSPAN="100%" ALIGN="Center"><BR>
	<cfoutput>
		<a href="javascript:submitForm('#form.command#', 'save');">#application.util.string.actionLinkFormat2('Assign Distributor')#</a>
		<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export all')#</a>
	</cfoutput>
	</TD>
</TR>

</TABLE>
