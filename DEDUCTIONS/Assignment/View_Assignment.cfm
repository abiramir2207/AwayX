
<CFQUERY NAME="Get_Analyst" DATASOURCE="#Application.Datasource#">
	SELECT 		Analyst_User_ID,
				Default_Analyst,
				Is_Default_Supervisor,
				Name_First,
				Name_last
				 
	FROM 		DD_Analyst
	INNER JOIN	_Users ON _Users.User_ID = DD_Analyst.Analyst_User_ID
	WHERE 		DD_Analyst.Deleted = 0 AND _Users.Deleted = 0
	ORDER BY 	Name_First
</CFQUERY>

<cfset useLakebaseForGetDefault = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForGetDefault>
	<cftry>
		<cfset GetDefault = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", {
				"default_analyst" = "eq.1",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetDefault = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDefault>
<CFQUERY NAME="GetDefault" DATASOURCE="#Application.Datasource#">
	SELECT * FROM DD_Analyst WHERE Default_Analyst = 1 AND Deleted = 0
</CFQUERY>
</cfif>

<CFQUERY NAME="CheckUnAssignedMarket" DATASOURCE="#Application.Datasource#">
	SELECT 		Top 1 *
	
	FROM 		Service_Markets 
	
	WHERE 		Deleted = 0 AND 
				Service_Market_ID Not in (	SELECT 	Service_Market_ID 
											FROM 	DD_Assignment 
											WHERE 	Deleted = 0	AND Service_Market_ID is not null	)

	ORDER BY	Market_Name
</CFQUERY>

<CFIF GetDefault.recordcount EQ 0 AND CheckUnAssignedMarket.recordcount Gt 0>
	<CFLOCATION URL="index2.cfm?Show_Step=5" ADDTOKEN="No">
</CFIF>
<STYLE>
TABLE.underline TD 
{
	border-bottom:solid #C0C0C0 1px; 
}
</STYLE>

<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="100%" CLASS="underline">	
	<cfoutput><TR BGCOLOR="FFE083">
		<TD WIDTH="200"><B>Analyst</B></TD>
		<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>
		<TD><B>Assigned #application.returned_customer_setting.distributor_label_plural#</B></TD>
		<CFELSE>
		<TD WIDTH="250"><B>Assigned Markets</B></TD>
		<TD><B>Assigned #application.returned_customer_setting.distributor_label_plural#</B></TD>
		</CFIF>
	</TR></cfoutput>
	<CFLOOP QUERY="Get_Analyst">	
	<CFQUERY NAME="Get_Market" DATASOURCE="#Application.Datasource#">
		SELECT 		DD_Assignment.Service_Market_ID,
					Market_Name
					
		FROM 		DD_Assignment
		
		INNER JOIN	Service_Markets ON Service_Markets.Service_Market_ID = DD_Assignment.Service_Market_ID
		
		WHERE 		Analyst_User_ID	= 	'#Analyst_User_ID#' AND DD_Assignment.Deleted = 0 AND Service_Markets.Deleted = 0 
		ORDER BY 	Market_Name
	</CFQUERY>
	<CFQUERY NAME="Get_Customer" DATASOURCE="#Application.Datasource#">
		SELECT 		DD_Assignment.Family_ID,
					Family_Name 
					
		FROM 		DD_Assignment		
		INNER JOIN 	Distributor_Family ON Distributor_Family.Family_ID = DD_Assignment.FAmily_ID

		WHERE 		Analyst_User_ID	= 	'#Analyst_User_ID#' AND	
					DD_Assignment.Deleted=0 AND 
					Distributor_Family.Deleted=0
					
		ORDER BY 	Family_Name
		
	</CFQUERY>
	<CFQUERY NAME="Get_Distributor" DATASOURCE="#Application.Datasource#">
		SELECT 		DD_Assignment.Customer_ID,
					Name
					
		FROM 		DD_Assignment
		INNER JOIN	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = DD_Assignment.Customer_ID
		
		WHERE		DD_Assignment.Analyst_User_ID	= 	'#Analyst_User_ID#' AND	
					DD_Assignment.Deleted=0 AND 
					BSA_Foodservice_Customers.Deleted = 0
		ORDER BY 	Name
	</CFQUERY>
	
	<tr <CFOUTPUT>BGCOLOR="#IIf(currentrow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>><!---  --->
		<TD VALIGN="Top"><B><CFOUTPUT>#Name_First# #Name_last# </CFOUTPUT></B><CFIF Default_Analyst EQ 1><BR><B><FONT COLOR="red">( Default Analyst )</FONT></B></CFIF><CFIF Is_Default_Supervisor EQ 1><BR><B><FONT COLOR="red">( Default Supervisor )</FONT></B></CFIF></TD>
		<CFIF application.returned_customer_setting.DD_Assignment_Based_On_Customer EQ 1>
		<TD VALIGN="Top">
		<CFIF Get_Distributor.Recordcount GT 0>
		<CF_openLayer
			Border="Yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="Hide Customers:"  
			TitleClosed="Show Customers:"  
			TitleTooltip="Click to Show/Hide Criteria Used"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="Yes"  
			Width="100%">		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
				<CFOUTPUT Query="Get_Distributor">
				<TR>
					<TD VALIGN="Top">#Name#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CF_openLayer>
		<CFELSE>
		&nbsp;
		</CFIF>
		</TD>
		<CFELSE>
		<TD VALIGN="Top">
		<CFIF Get_Market.Recordcount GT 0>
		<CF_openLayer
			Border="Yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="Hide Markets:"  
			TitleClosed="Show Markets:"  
			TitleTooltip="Click to Show/Hide Criteria Used"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="Yes"  
			Width="100%">		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
				<CFOUTPUT Query="Get_Market">
				<TR>
					<TD VALIGN="Top">#Market_Name#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CF_openLayer>
		<CFELSE>
		&nbsp;
		</CFIF>
		</TD>
		<TD valign="top" >
		<CFIF Get_Customer.recordcount GT 0 AND appSettings.getDDAssignmentBasedOnShrShipto() NEQ 1>
		<CF_openLayer
			Border="Yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="Hide Customers:"  
			TitleClosed="Show Customers:"  
			TitleTooltip="Click to Show/Hide Criteria Used"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="Yes"  
			Width="100%">	
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
				<CFOUTPUT QUERY="Get_Customer">
				<TR>
					<TD VALIGN="Top">#Family_Name#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CF_openLayer>
		<CFELSEIF appSettings.getDDAssignmentBasedOnShrShipto() AND Get_Distributor.RecordCount GT 0>
		<CF_openLayer
			Border="Yes"
			BorderSize="1"  
			BorderColor="orange"  
			Image="/images/plus2.gif"
			ImageOpen="/images/minus2.gif"
			Title="Hide Customers:"  
			TitleClosed="Show Customers:"  
			TitleTooltip="Click to Show/Hide Criteria Used"  
			TitleFont="font"  
			TitleColor="Blue"  
			TitleSize="9"  
			IsClosed="Yes"  
			Width="100%">		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="95%">
				<CFOUTPUT Query="Get_Distributor">
				<TR>
					<TD VALIGN="Top">#Name#</TD>
				</TR>
				</CFOUTPUT>
			</TABLE>
		</CF_openLayer>
		<CFELSE>
		&nbsp;
		</CFIF>
		</TD>		
		</CFIF>
	</TR>
	</CFLOOP>	
</TABLE>

