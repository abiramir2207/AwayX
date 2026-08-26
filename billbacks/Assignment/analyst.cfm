<!------ analyst.cfm ----->

<cfif form.subcommand EQ "save">
	<!------ save in database ----->
	
	<cfparam name="form.Analyst_ID" 	default="">
	<cfparam name="form.New_Analyst" 	default="">
	
	<cfset billbackAssignmentManager.saveAnalysts(
				analystUserIDList = form.Analyst_ID,
				defaultAnalystUserID = form.New_Analyst,
				byUserId = request.AccessStructure.User_ID) />

	<cfinclude template="nextPage.cfm" />
	<cfset form.command = form.nextCommand />
	<cfset nextPage = "index.cfm?command=#form.command#" />
	<cflocation addtoken="No" url="#nextPage#" />
</cfif>

<cfset qGetAnalysts = billbackAssignmentManager.getAnalysts() />
<cfset qGetAvailableUsers = billbackAssignmentManager.getAvailableUsers() />
<cfset useLakebaseForqGetDefaultAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetanalysts")>
<cfif useLakebaseForqGetDefaultAnalyst>
	<cftry>
		<cfset qGetDefaultAnalyst = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetanalysts", {
				"default_analyst" = "eq.1",
				"select" = "analyst_user_id"
			}), "analyst_user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDefaultAnalyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDefaultAnalyst>
<cfquery name="qGetDefaultAnalyst" dbtype="query">
	SELECT	Analyst_User_ID
	FROM	qGetAnalysts
	WHERE	Default_Analyst = 1
</cfquery>
</cfif>

<cfset showMessage = "" />
<cfif qGetAnalysts.recordCount EQ 0>
	<cfset showMessage = "Please select atleast one analyst" />
<cfelseif qGetDefaultAnalyst.recordCount EQ 0>
	<cfset showMessage = "Please select a default analyst" />
</cfif>

<cfif qGetDefaultAnalyst.recordCount>
<cfoutput>
<INPUT TYPE="Hidden" NAME="Def_Analyst_ID" VALUE="#qGetDefaultAnalyst.Analyst_User_ID#">
</cfoutput>
</cfif>
<cfoutput><center><font style="color:red;font-weight:bold;">#showMessage#</font></center></cfoutput>
<BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="465" style="margin-top:10px;">	
	<TR  HEIGHT="4">
		<TD VALIGN="Top" BGCOLOR="Navy">&nbsp;<FONT COLOR="WHITE"><B>Analyst List</B></FONT><BR>
			<SELECT NAME="Analyst_ID" SIZE="22" STYLE="WIDTH:200px" MULTIPLE>
				<CFOUTPUT QUERY="qGetAnalysts">
					<OPTION VALUE="#Analyst_User_ID#">#Name_First# #Name_Last#</OPTION> 
				</CFOUTPUT>
			</SELECT>
		</TD>
		<TD WIDTH="20">&nbsp;</TD>
		<TD VALIGN="Top"><BR><BR><BR>					
			<INPUT TYPE="BUTTON" NAME="Add_Analyst" VALUE="<" ONCLICK="Javascript: Add_Remove_Selected_Users('User_ID','Analyst_ID')" STYLE="WIDTH:25px"><BR><BR>
			<INPUT TYPE="BUTTON" NAME="Remove_Analyst" VALUE=">" ONCLICK="Javascript:Add_Remove_Selected_Users('Analyst_ID','User_ID')" STYLE="WIDTH:25px"><BR><BR>
			<INPUT TYPE="BUTTON" NAME="Remove_All" VALUE=">>" ONCLICK="Javascript: remove_all('Analyst_ID','User_ID')" STYLE="WIDTH:25px"><BR><BR>
		</TD>
		<TD WIDTH="20">&nbsp;</TD>
		<TD VALIGN="Top" BGCOLOR="Navy">&nbsp;<FONT COLOR="White"><B>User List</B></FONT><BR>
			<SELECT NAME="User_ID" SIZE="22" STYLE="WIDTH:200px" MULTIPLE>
				<CFOUTPUT QUERY="qGetAvailableUsers">
					<OPTION VALUE="#User_ID#">#Name_First# #Name_Last#</OPTION>
				</CFOUTPUT>
			</SELECT>
		</TD>
	</TR>	
</TABLE>
<BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="465">	
	<CFIF qGetAnalysts.Recordcount GT 0>
	<TR>
		<TD><B>If you removed any Analysts assign all their billbacks to:</B></TD>				
		<TD>
			<SELECT NAME="New_Analyst" STYLE="WIDTH:200px">
				<CFOUTPUT QUERY="qGetAnalysts">						
					<OPTION VALUE="#Analyst_User_ID#" <CFIF Default_Analyst EQ 1>SELECTED</CFIF>>#Name_First# #Name_Last#&nbsp;&nbsp;<CFIF Default_Analyst EQ 1>(Default)</CFIF></OPTION>
				</CFOUTPUT>
			</SELECT>
		</TD>
	</TR>
	</CFIF>
	<TR>
		<TD COLSPAN="100%" ALIGN="Center"><BR><BR>
			<cfoutput>
				<CF_button
					button_name	=	""
					button_caption	=	"save selection"
					button_action	=	"return submitForm('#form.command#', 'save')"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
								>
			</cfoutput>
		</TD>
	</TR>
</TABLE>
