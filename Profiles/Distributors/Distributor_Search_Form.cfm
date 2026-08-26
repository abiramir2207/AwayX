
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=13>
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



<DIV CLASS="title2">Search the <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> Database</DIV>
<HR COLOR="Orange">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get Market family names																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Family_Names = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGet_Family_Names>
	<cftry>
		<cfset Get_Family_Names = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"deleted" = "eq.0",
				"select" = "family_name"
			}), "family_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Family_Names = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Family_Names>
<cfquery name="Get_Family_Names" datasource="#application.datasource#">
	SELECT DISTINCT	Family_Name
	FROM 			BSA_Foodservice_Customers
	WHERE			deleted = 0
</cfquery>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get brokers																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfquery name="Get_Brokers" datasource="#application.datasource#">
	SELECT	DISTINCT
				BSA_Foodservice_Brokers.Broker_Name, 
				BSA_Foodservice_Brokers.Broker_Legcy_Shard,
				BSA_Foodservice_Customers.Std_Broker
	FROM		BSA_Foodservice_Brokers,
				BSA_Foodservice_Customers
	WHERE		BSA_Foodservice_Customers.deleted = 0
				and
				BSA_Foodservice_Brokers.deleted = 0
				and
				BSA_Foodservice_Brokers.Broker_Legcy_Shard = BSA_Foodservice_Customers.Std_Broker
	ORDER BY	BSA_Foodservice_Brokers.Broker_Name
</cfquery>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get States																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_State" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#">
Select	distinct 
		_states.*,
		BSA_Foodservice_Customers.state
From 	BSA_Foodservice_Customers,
		_states
Where 	BSA_Foodservice_Customers.deleted = 0
		and
		_states.State_Code	=	BSA_Foodservice_Customers.state
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get Market Areas																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfquery name="Get_Market_Areas" datasource="#application.datasource#">
	SELECT	DISTINCT
				BSA_Foodservice_Brokers.Market_Area, 
				BSA_Foodservice_Brokers.Broker_Legcy_Shard,
				BSA_Foodservice_Customers.Std_Broker
	FROM		BSA_Foodservice_Brokers,
				BSA_Foodservice_Customers
	WHERE		BSA_Foodservice_Customers.deleted = 0
				and
				BSA_Foodservice_Brokers.deleted = 0
				and
				BSA_Foodservice_Brokers.Broker_Legcy_Shard = BSA_Foodservice_Customers.Std_Broker
	ORDER BY	BSA_Foodservice_Brokers.Market_Area
</cfquery>


<FORM ACTION="/profiles/Distributors/Distributor_Search_Action.cfm" METHOD="post" NAME="MyForm" target="mywindowname" onSubmit="setTimeout('window.close()',0000)">
	<TABLE>
		<TR>
			<TD COLSPAN="2">
				<B>Search String:</B><BR>
				<INPUT TYPE="Text" NAME="searchstring" VALUE="" style="width: 490px;">
			</TD>
		<TR>
		<TR>
			<TD>
				<B>Family Name:</B><BR>
				<SELECT NAME="Family_Name" style="width: 240px;">
					<OPTION VALUE="All">**ALL** Family Names</OPTION>
					<CFOUTPUT QUERY="Get_Family_Names"><OPTION VALUE="#trim(Family_Name)#">#trim(Family_Name)#</OPTION></CFOUTPUT>
				</SELECT>					
			</TD>
			<TD>
				<B>Broker Name:</B><BR>
				<SELECT NAME="Std_Broker" style="width: 240px;">
					<OPTION VALUE="All">**ALL** Brokers</OPTION>
					<CFOUTPUT QUERY="Get_Brokers"><OPTION VALUE="#Std_Broker#">#Broker_Name#</OPTION></CFOUTPUT>
				</SELECT>	
			</TD>
		<TR>
		</TR>
			<TD>
				<B>State:</B><BR>
				<SELECT NAME="State" style="width: 240px;">
					<OPTION VALUE="All">**ALL** States</OPTION>
					<CFOUTPUT QUERY="Get_State"><OPTION VALUE="#state_code#">#state_name#</OPTION></CFOUTPUT>
				</SELECT>					
			</TD>
			<TD>
				<B>Market Area:</B><BR>
				<SELECT NAME="Market_Area" style="width: 240px;">
					<OPTION VALUE="All">**ALL** Broker Market Areas</OPTION>
					<CFOUTPUT QUERY="Get_Market_Areas"><OPTION VALUE="#Std_Broker#">#Market_Area#</OPTION></CFOUTPUT>
				</SELECT>					
			</TD>
		</TR>
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
									<OPTION VALUE="Name" SELECTED><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name</OPTION>
									<OPTION VALUE="Family_Name">Family Name</OPTION>
									<OPTION VALUE="State">State</OPTION>
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
					<INPUT TYPE="submit" VALUE="Search..." STYLE="width:150px;">
				</TD>
			</TR>
	</TABLE>

</FORM>


