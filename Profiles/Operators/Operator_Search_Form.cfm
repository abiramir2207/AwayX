
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=15>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>



<style>
body, table, td
	{
		font-family: Arial;
		font-size: 12px;
	}
input,select, TEXTAREA
	{
		width:	175px;
		font-size: 10px;
	}
TEXTAREA
	{
		width:	400px;
		font-size: 10px;
	}
input.nostyle
	{
		width:	10px;
	}
</style>


<DIV CLASS="title2">Search <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>'s Database</DIV>
<HR COLOR="Orange">



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Location_Type														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForGet_Operator_Location_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_operator")>
<cfif useLakebaseForGet_Operator_Location_Type>
	<cftry>
		<cfset Get_Operator_Location_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_operator", {
				"deleted" = "eq.0",
				"select" = "operator_location_type"
			}), "operator_location_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator_Location_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator_Location_Type>
<CFQUERY NAME="Get_Operator_Location_Type" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#" datasource="#application.datasource#">
Select	distinct Operator_Location_Type
From	BSA_Operator
Where	deleted = 0
</CFQUERY>
</cfif>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Type																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---------------------------------------------------------------------------- 
  Dev Notes: D19761 -Anand Rao 07/28/09
  Changed to query to have a where clause to look for active = 1 and 
  Deleted = 0 and pick the records from awayx_Operator_type table
------------------------------------------------------------------------------>
<cfset useLakebaseForGet_Operator_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("awayx_operator_type")>
<cfif useLakebaseForGet_Operator_Type>
	<cftry>
		<cfset Get_Operator_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("awayx_operator_type", {
				"active" = "eq.1",
				"deleted" = "eq.0",
				"select" = "operator_type"
			}), "operator_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator_Type>
<CFQUERY NAME="Get_Operator_Type" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#" datasource="#application.datasource#">
  SELECT	Distinct Operator_Type
  FROM awayX_Operator_Type
  WHERE Active = 1 AND Deleted = 0
</CFQUERY>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the states																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_States" CACHEDWITHIN="#CreateTimeSpan(0,24,0,0)#" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>


<FORM ACTION="Operator_Search_Action.cfm" METHOD="post" NAME="MyForm" target="mywindowname" onSubmit="setTimeout('window.close()',00000)">


<TABLE>
<TR>
	<TD>
		<B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name:</B><BR>
		<INPUT TYPE="text" NAME="Operator_Name">
	</TD>
	<TD>
		<B>Doing business as:</B><BR>
		<INPUT TYPE="Text" NAME="Operator_DBA" MAXLENGTH="510">
	</TD>
	<TD>
		<B>City:</B><BR>
		<INPUT TYPE="Text" NAME="Operator_City" MAXLENGTH="510">
	</TD>
</TR>
<TR>
	<TD>
		<B>Type of <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>:</B><BR>
		<SELECT NAME="Operator_Type">
		<OPTION VALUE="All" SELECTED>Select <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Type</OPTION>
		<OPTION VALUE="All">All types</OPTION>
		<CFOUTPUT QUERY="Get_Operator_Type"><OPTION VALUE="#Operator_Type#">#Operator_Type#</OPTION></CFOUTPUT>
		</SELECT>
	</TD>
	<TD>
		<B>Location Type:</B><BR>
		<SELECT NAME="Operator_Location_Type">
		<OPTION VALUE="All" SELECTED>Select Location Types</OPTION>
		<OPTION VALUE="All">All Location Types</OPTION>
		<CFOUTPUT QUERY="Get_Operator_Location_Type"><OPTION VALUE="#Operator_Location_Type#">#Operator_Location_Type#</OPTION></CFOUTPUT>
		</SELECT>	
	</TD>
	<TD>
		<B>State:</B><BR>
		<SELECT NAME="Operator_State">
		<OPTION VALUE="All" SELECTED>Select State</OPTION>
		<OPTION VALUE="All">Any State</OPTION>
		<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#">#State_Name#</OPTION></CFOUTPUT>
		</SELECT>	
	</TD>
</TR>
<TR>
	<TD COLSPAN="3">
		<BR>



					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="center" WIDTH="100%">
						<TR>
							<TD NOWRAP VALIGN="top" ALIGN="Left">
								<B>Records per page</B><BR>
								<SELECT NAME="maxrows">
									<OPTION VALUE="10" SELECTED>10</OPTION>
									<OPTION VALUE="25">25</OPTION>
									<OPTION VALUE="50">50</OPTION>
									<OPTION VALUE="100">100</OPTION>
								</SELECT>	
							</TD>
							<TD VALIGN="top" ALIGN="Left" NOWRAP>
								<B>Sort records by</B><BR>
								<SELECT NAME="sortby">
									<OPTION VALUE="Operator_Name"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</OPTION>
									<OPTION VALUE="Operator_City">City</OPTION>
									<OPTION VALUE="Operator_State">State</OPTION>
									<OPTION VALUE="Operator_Number_Of_Locations">Number of locations</OPTION>
								</SELECT>	
							</TD>
							<TD VALIGN="top" ALIGN="left">
								<B>Order Selection</B><BR>
								<SELECT NAME="sortorder">
									<OPTION VALUE="asc">Ascending</OPTION>
									<OPTION VALUE="desc">Descending</OPTION>
								</SELECT>	
							</TD>
						</TR>
					</TABLE>










<!--- 
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
			<TR>
				<TD NOWRAP VALIGN="top">
					<B>Records per page:</B><BR>
					<SELECT NAME="maxrows" STYLE="width:100px;">
						<OPTION VALUE="10" SELECTED>10</OPTION>
						<OPTION VALUE="25">25</OPTION>
						<OPTION VALUE="50">50</OPTION>
						<OPTION VALUE="100">100</OPTION>
					</SELECT>	
				</TD>
				<TD VALIGN="top" ALIGN="left" NOWRAP>
					<BLOCKQUOTE>
					<B>Sort records by:</B><BR>
					<INPUT TYPE="radio" CLASS="nostyle" NAME="sortby" VALUE="Operator_Name" CHECKED>Operator Name&nbsp;&nbsp;
					<INPUT TYPE="radio" CLASS="nostyle" NAME="sortby" VALUE="Operator_City">City&nbsp;&nbsp;
					<INPUT TYPE="radio" CLASS="nostyle" NAME="sortby" VALUE="Operator_State">State&nbsp;&nbsp;
					<INPUT TYPE="radio" CLASS="nostyle" NAME="sortby" VALUE="Operator_Number_Of_Locations">Number of locations
					</BLOCKQUOTE>
				</TD>
				<TD VALIGN="top" ALIGN="left">
					<B>Select the Order:</B><BR>
					<INPUT TYPE="radio" CLASS="nostyle"	NAME="sortorder" VALUE="asc" CHECKED>Ascending order<BR>
					<INPUT TYPE="radio" CLASS="nostyle" NAME="sortorder" VALUE="desc">Descending order
				</TD>
			</TR>
		</TABLE>
 --->


	</TD>
</TR>
</TABLE>


<INPUT type="submit" value="Search..." STYLE="width:100px;">

</FORM>

