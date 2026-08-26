<!------ director.cfm ----->

<cfif form.subcommand EQ "save">
	<!------ save in database ----->
	
	<cfparam name="form.Analyst_ID" 	default="">
	<cfparam name="form.New_Analyst" 	default="">

<cfoutput>form.Analyst_ID: #form.Analyst_ID#<br>
form.New_Analyst:#form.New_Analyst#<br>
form.command: #form.command#<br>
</cfoutput>

	
	<cfset billbackAssignmentManager.saveDirectors(
				directorUserIDList = form.Analyst_ID,
				byUserId = request.AccessStructure.User_ID) />

	
	<cfinclude template="nextPage.cfm" />
	<cfset form.command = form.nextCommand />
	<cfset nextPage = "index.cfm?command=#form.command#" />
	<cflocation addtoken="No" url="#nextPage#" />

</cfif>

<cfif NOT isDefined("qGetDirectors")><!------ might be already called in nextPage.cfm ----->
<cfset qGetDirectors = billbackAssignmentManager.getDirectors() />
</cfif>
<cfif NOT isDefined("qGetAvailableSupervisors")><!------ might be already called in nextPage.cfm ----->
<!---
<cfset qGetAvailableSupervisors = billbackAssignmentManager.getSupervisorsForDirector(bNonDirector=1) />
--->
<cfset qGetAvailableSupervisors = billbackAssignmentManager.getSupervisors(bNonDirector=1) />
</cfif>
<cfquery name="qGetDefaultDirector" dbtype="query">
	SELECT	Analyst_User_ID
	FROM	qGetDirectors
	WHERE	Is_Default_Director = 1
</cfquery>

<cfset showMessage = "" />
<!--- removed by 32466
<cfif qGetDirectors.recordCount EQ 0>
	<cfset showMessage = "Please select atleast one director" />
<cfelseif qGetDefaultDirector.recordCount EQ 0>
	<cfset showMessage = "Please select a default director" />
</cfif>
--->

<cfif qGetDefaultDirector.recordCount>
<cfoutput>
<INPUT TYPE="Hidden" NAME="Def_Analyst_ID" VALUE="#qGetDefaultDirector.Analyst_User_ID#">
</cfoutput>
</cfif>



<cfoutput><center><font style="color:red;font-weight:bold;">#showMessage#</font></center></cfoutput>
<BR>
<INPUT TYPE="Hidden" NAME="aaaaaa" VALUE="1">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="465">	
	<TR  HEIGHT="4">
		<TD VALIGN="Top" BGCOLOR="Navy">&nbsp;<FONT COLOR="WHITE"><B>Director List</B></FONT><BR>
			<SELECT NAME="Analyst_ID" SIZE="22" STYLE="WIDTH:200px" MULTIPLE>
				<CFOUTPUT QUERY="qGetDirectors">
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
		<TD VALIGN="Top" BGCOLOR="Navy">&nbsp;<FONT COLOR="White"><B>Supervisor List</B></FONT><BR>
			<SELECT NAME="User_ID" SIZE="22" STYLE="WIDTH:200px" MULTIPLE>
				<CFOUTPUT QUERY="qGetAvailableSupervisors">
					<OPTION VALUE="#Analyst_User_ID#">#Name_First# #Name_Last#</OPTION>
				</CFOUTPUT>
			</SELECT>
		</TD>
	</TR>	
</TABLE>
<BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="465">	
	<!---
	<CFIF qGetDirectors.Recordcount GT 0>
	<TR>
		<TD><B>If you removed any Analysts assign all their billbacks to:</B></TD>				
		<TD>
			<SELECT NAME="New_Analyst" STYLE="WIDTH:200px">
				<CFOUTPUT QUERY="qGetDirectors">						
					<OPTION VALUE="#Analyst_User_ID#" <CFIF Is_Default_Director EQ 1>SELECTED</CFIF>>#Name_First# #Name_Last#&nbsp;&nbsp;<CFIF Is_Default_Director EQ 1>(Default)</CFIF></OPTION>
				</CFOUTPUT>
			</SELECT>
		</TD>
	</TR>
	</CFIF>
--->
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
