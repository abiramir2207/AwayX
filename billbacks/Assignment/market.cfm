<!------ market.cfm ----->

<cfif form.subcommand EQ "save">
	<!------ save in database ----->
	
	<cfparam name="form.Analyst_Record_Count" 	default="">
	
	<cfif IsNumeric(form.Analyst_Record_Count)>
		<cfloop index="index" from="1" to="#form.Analyst_Record_Count#">
			<cfparam name="Form.Analyst_User_ID_#index#" 	default="">
			<cfparam name="Form.Market_ID_#index#" 	default="">
			<cfset Analyst_User_ID = Evaluate("Form.Analyst_User_ID_#index#") />
			<cfset Market_ID_List = Evaluate("Form.Market_ID_#index#") />
			
			
			<cfif Analyst_User_ID NEQ "">
					<cfset billbackAssignmentManager.saveAnalystMarkets(
						analystUserID = Analyst_User_ID,
						marketIDList = Market_ID_List,
						byUserId = request.AccessStructure.User_ID) />
			</cfif>
			
		</cfloop>
	</cfif>
	
	<cfinclude template="nextPage.cfm" />
	<cfset form.command = form.nextCommand />
	<cfset nextPage = "index.cfm?command=#form.command#" />
	<cflocation addtoken="No" url="#nextPage#" />
</cfif>

<cfif NOT isDefined("qGetAnalysts")><!------ might be already called in nextPage.cfm ----->
<cfset qGetAnalysts = billbackAssignmentManager.getAnalysts() />
</cfif>
<cfif NOT isDefined("qGetAvailableMarkets")><!------ might be already called in nextPage.cfm ----->
<cfset qGetAvailableMarkets = billbackAssignmentManager.getAvailableMarkets() />
</cfif>

<cfset showMessage = "" />
<cfif qGetAvailableMarkets.recordCount GT 0>
	<cfset showMessage = "Please assign markets to analysts" />
</cfif>

<script language="JavaScript">

	document.body.onscroll = new Function("settimeoutScroll()");
	var timeout1 = null;
	var sDiv = "Div_Service_Market_ID";
	function settimeoutScroll()
	{
		if(timeout1)
		{
			window.clearTimeout(timeout1);
		}
		timeout1 = window.setTimeout("scroll_div()", 0);
	}
	
</script>

<BR>
<cfoutput><center><font style="color:red;font-weight:bold;">#showMessage#</font></center></cfoutput>
<BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="900" align="center">
<TR>
<TD WIDTH="350"  VALIGN="Top">
<cfoutput><INPUT TYPE="Hidden" NAME="Analyst_Record_Count" VALUE="#qGetAnalysts.recordcount#"></cfoutput>
<cfloop query="qGetAnalysts">
	<cfset qGetAnalystMarkets = billbackAssignmentManager.getAnalystMarkets(Analyst_User_ID) />
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
			Width="400px">	
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<!--- <TD VALIGN="Top" WIDTH="150" NOWRAP>&nbsp;&nbsp;</TD>			 --->
				<TD VALIGN="Top" WIDTH="350">
					<cfoutput><SELECT NAME="Market_ID_#currentrow#" SIZE="4" STYLE="WIDTH:350px" MULTIPLE></cfoutput>
						<cfloop QUERY="qGetAnalystMarkets">
							<cfoutput><OPTION VALUE="#qGetAnalystMarkets.Service_Market_ID#">#trim(qGetAnalystMarkets.Market_Name)# <cfif len(trim(qGetAnalystMarkets.Position_Label))>[#trim(qGetAnalystMarkets.Position_Label)#, #trim(qGetAnalystMarkets.Market_Number)#]</cfif></OPTION></cfoutput>
						</cfloop>
					</SELECT>
				</TD>
				<TD WIDTH="20">&nbsp;</TD>
				<TD VALIGN="Top" WIDTH="27" ALIGN="center">
					<cfoutput><INPUT TYPE="BUTTON" NAME="Add_Market_#currentrow#" VALUE="<" ONCLICK="Javascript: Add_Remove_Selected_Users('Service_Market_ID','Market_ID_#currentrow#', 1)" STYLE="WIDTH:25px"></cfoutput><BR>
					<cfoutput><INPUT TYPE="BUTTON" NAME="Remove_Market_#currentrow#" VALUE=">" ONCLICK="Javascript:Add_Remove_Selected_Users('Market_ID_#currentrow#','Service_Market_ID', 2)" STYLE="WIDTH:25px"></cfoutput><BR>
					<cfoutput><INPUT TYPE="BUTTON" NAME="Remove_All_#currentrow#" VALUE=">>" ONCLICK="Javascript: remove_all('Market_ID_#currentrow#','Service_Market_ID')" STYLE="WIDTH:25px"></cfoutput><BR>
				</TD>
				<!--- <TD WIDTH="10">&nbsp;</TD> --->
			</TR>
			
		</TABLE>
		</CF_openLayer>
</cfloop>
</TD>
<TD WIDTH="20">&nbsp;</TD>
<TD ALIGN="Left" valign="top">
	<DIV STYLE="display:inline;" ID="Div_Service_Market_ID">
	<SELECT NAME="Service_Market_ID"  SIZE="26" MULTIPLE STYLE="WIDTH: 440px;">
		<cfloop QUERY="qGetAvailableMarkets">
			<cfoutput><OPTION VALUE="#qGetAvailableMarkets.Service_Market_ID#">#trim(qGetAvailableMarkets.Market_Name)# <cfif len(trim(qGetAvailableMarkets.Position_Label))>[#trim(qGetAvailableMarkets.Position_Label)#, #trim(qGetAvailableMarkets.Market_Number)#]</cfif></OPTION></cfoutput>
		</cfloop>
	</SELECT>
	</DIV>
</TD>
</TR>
<TR>
	<TD COLSPAN="100%" ALIGN="Center"><BR>
	<CF_button
			button_name		=	""
			button_caption	=	"Assign Market"
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
