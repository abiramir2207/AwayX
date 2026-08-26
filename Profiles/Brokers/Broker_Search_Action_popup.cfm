
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=11>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<STYLE>
body, table, td
	{
		font-family: Arial;
		font-size: 12px;
	}
input,select, TEXTAREA
	{
		width:	240px;
		font-size: 12px;
	}
TEXTAREA
	{
		width:	400px;
		font-size: 12px;
	}
input.nostyle
	{
		width:	150px;
		width:	12px;
	}

</STYLE>

<BR><BR>



<DIV CLASS="title2">Search the Brokers' Database</DIV>
<HR COLOR="Orange">



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get Market Area																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Market_Area" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
	SELECT DISTINCT Market_Area
	FROM BSA_Foodservice_Brokers
	WHERE deleted = 0
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get States																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_State" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
Select	distinct 
		_states.*, BSA_Foodservice_Brokers.state
From 	BSA_Foodservice_Brokers, _states
Where 	BSA_Foodservice_Brokers.deleted = 0
		and
		_states.State_Code	=	BSA_Foodservice_Brokers.state
</CFQUERY>


<FORM NAME="SearchForm">


		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<TD COLSPAN="100%" COLSPAN="2">
					<B>Search String:</B><BR>
					<INPUT TYPE="Text" NAME="searchstring" STYLE="width: 485px;">
					<BR>
				</TD>
			</TR>
			<TR>
				<TD NOWRAP ALIGN="left">
					<B>Market Area</B><BR>
					<SELECT NAME="Market_Area">
						<OPTION VALUE="All">**ALL** Market Areas</OPTION>
						<CFOUTPUT QUERY="Get_Market_Area"><OPTION VALUE="#Market_Area#">#Market_Area#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
					
					
				</TD>
				<TD NOWRAP ALIGN="left">
					<B>State</B><BR>
					<SELECT NAME="State">
						<OPTION VALUE="All">**ALL** States</OPTION>
						<CFOUTPUT QUERY="Get_State"><OPTION VALUE="#State_Code#">#trim(State_Name)#</OPTION></CFOUTPUT>
					</SELECT>
					<BR><BR>
				</TD>
			<TR>
			<TR>
				<TD COLSPAN="2">
					<BR>
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="center" WIDTH="100%">
						<TR>
							<TD NOWRAP VALIGN="top" ALIGN="left">
								<B>Records per page</B><BR>
								<SELECT NAME="maxrows" STYLE="width:160px;">
									<OPTION VALUE="10">10</OPTION>
									<OPTION VALUE="25" SELECTED>25</OPTION>
									<OPTION VALUE="50">50</OPTION>
									<OPTION VALUE="100">100</OPTION>
								</SELECT>	
							</TD>
							<TD VALIGN="top" ALIGN="left" NOWRAP>
								<B>Sort records by</B><BR>
								<SELECT NAME="sortby" STYLE="width:160px;">
									<OPTION VALUE="Broker_Name" SELECTED>Broker Name</OPTION>
									<OPTION VALUE="State">State</OPTION>
									<OPTION VALUE="Market_Area">Market Area</OPTION>
								</SELECT>	
							</TD>
							<TD VALIGN="top" ALIGN="left">
								<B>Order Selection</B><BR>
								<SELECT NAME="sortorder" STYLE="width:160px;">
									<OPTION VALUE="asc" SELECTED>Ascending</OPTION>
									<OPTION VALUE="desc">Descending</OPTION>
								</SELECT>	
							</TD>
						</TR>
					</TABLE>
					<BR><BR>
					&nbsp;&nbsp;
					<!--- <INPUT TYPE="button" VALUE="Search..." STYLE="width:100px;" ONCLICK="opener.transportFormElementsFromPopupToParentPage()"> --->

					<CF_button
						button_name		=	""
						button_caption	=	"search"
						button_action	=	"javascript: opener.transportFormElementsFromPopupToParentPage();"
						button_type		=	"link"
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

</FORM>
<SCRIPT>
	opener.reSelectOptionsInSearchForm()
</SCRIPT>