<!------ market.cfm ----->

<cfif form.subcommand EQ "save">
	<!------ save in database ----->
	
	<cfparam name="form.Director_Record_Count" 	default="">

<cfoutput> #form.Director_Record_Count# <br></cfoutput>	
	<cfif IsNumeric(form.Director_Record_Count)>
		<cfloop index="index" from="1" to="#form.Director_Record_Count#">
			<cfparam name="Form.Director_User_ID_#index#" 	default="">
			<cfparam name="Form.Analyst_User_ID_#index#" 	default="">

			<cfset Director_User_ID = Evaluate("Form.Director_User_ID_#index#") />
			<cfset Supervisor_User_ID_List = Evaluate("Form.Analyst_User_ID_#index#") />
			
			
			<cfif Director_User_ID NEQ "">
					<cfset billbackAssignmentManager.saveDirectorSupervisor(
						directorUserId = Director_User_ID,
						supervisorIdList = Supervisor_User_ID_List,
						byUserId = request.AccessStructure.User_ID) />
			</cfif>
			
		</cfloop>
	</cfif>

	<cfinclude template="nextPage.cfm" />
	<cfset form.command = form.nextCommand />
	<cfset nextPage = "index.cfm?command=#form.command#" />
	<cflocation addtoken="No" url="#nextPage#" />

</cfif>


<cfset qGetDirectors = billbackAssignmentManager.getDirectors() />
<cfset qGetAvailableSupervisors = billbackAssignmentManager.getAvailableSupervisors() />

<cfset showMessage = "" />
<cfif qGetAvailableSupervisors.recordCount GT 0>
	<cfset showMessage = "Please assign supervisor to director" />
</cfif>

<script language="JavaScript">

	document.body.onscroll = new Function("settimeoutScroll()");
	var timeout1 = null;
	var sDiv = "Div_Analyst_User_ID";
	function settimeoutScroll()
	{
		if(timeout1)
		{
			window.clearTimeout(timeout1);
		}
		timeout1 = window.setTimeout("scroll_div()", 0);
	}
	
</script>

<cfoutput><center><font style="color:red;font-weight:bold;">#showMessage#</font></center></cfoutput>
<BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="600" align="center">
<TR>
<TD WIDTH="350"  VALIGN="Top">
<cfoutput><INPUT TYPE="Hidden" NAME="Director_Record_Count" VALUE="#qGetDirectors.recordcount#"></cfoutput>
<cfloop query="qGetDirectors">
	<cfset qGetDirectorSupervisors = billbackAssignmentManager.getDirectorSupervisors(Analyst_User_ID) />
	<cfoutput><INPUT TYPE="Hidden" NAME="Director_User_ID_#currentrow#" VALUE="#Analyst_User_ID#"></cfoutput>
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
			Width="300px">	
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<!--- <TD VALIGN="Top" WIDTH="150" NOWRAP>&nbsp;&nbsp;</TD>			 --->
				<TD VALIGN="Top" WIDTH="250">
					<cfoutput><SELECT NAME="Analyst_User_ID_#currentrow#" SIZE="4" STYLE="WIDTH:250px" MULTIPLE></cfoutput>
						<cfloop QUERY="qGetDirectorSupervisors">
							<cfoutput><OPTION VALUE="#Analyst_User_ID#">#Name_First# #Name_Last#</OPTION></cfoutput>
						</cfloop>
					</SELECT>
				</TD>
				<TD WIDTH="20">&nbsp;</TD>
				<TD VALIGN="Top" WIDTH="27" ALIGN="center">
					<cfoutput><INPUT TYPE="BUTTON" NAME="Add_Analyst_#currentrow#" VALUE="<" ONCLICK="Javascript: Add_Remove_Selected_Users('User_ID','Analyst_User_ID_#currentrow#', 1)" STYLE="WIDTH:25px"></cfoutput><BR>
					<cfoutput><INPUT TYPE="BUTTON" NAME="Remove_Analyst_#currentrow#" VALUE=">" ONCLICK="Javascript:Add_Remove_Selected_Users('Analyst_User_ID_#currentrow#','User_ID', 2)" STYLE="WIDTH:25px"></cfoutput><BR>
					<cfoutput><INPUT TYPE="BUTTON" NAME="Remove_All_#currentrow#" VALUE=">>" ONCLICK="Javascript: remove_all('Analyst_User_ID_#currentrow#','User_ID')" STYLE="WIDTH:25px"></cfoutput><BR>
				</TD>
				<!--- <TD WIDTH="10">&nbsp;</TD> --->
			</TR>
			
		</TABLE>
		</CF_openLayer>
</cfloop>
</TD>
<TD WIDTH="20">&nbsp;</TD>
<TD ALIGN="Left" valign="top">
	<DIV STYLE="display:inline;" ID="Div_Analyst_User_ID">
	<SELECT NAME="User_ID"  SIZE="26" MULTIPLE STYLE="WIDTH: 300px;">
		<cfloop QUERY="qGetAvailableSupervisors">
			<cfoutput><OPTION VALUE="#Analyst_User_ID#">#Name_First# #Name_Last#</OPTION></cfoutput>
		</cfloop>
	</SELECT>
	</DIV>
</TD>
</TR>
</TR>
<TR>
	<TD COLSPAN="100%" ALIGN="Center"><BR>
	<CF_button
			button_name		=	""
			button_caption	=	"Assign Director"
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
