<CFINCLUDE TEMPLATE="view_commodity_queries.cfm">


<!--- 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Calculate the first date to get data for: go back xx days										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET URL.datasize=30>
<CFSET startdate=now()-URL.datasize>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the full name of the Commodity															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Commodity_Name" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
	Select	Symbol_Description
	From	Commodities_Symbol
	Where	Symbol	=	'#URL.Symbol#'
</CFQUERY>



<CFQUERY NAME="Get_Commodity_Data" datasource="#application.datasource#" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
	Select	Comm_Datetime,
			Comm_Last,
			Comm_Previous
	From	Commodities
	Where	Comm_Symbol	=	'#URL.Symbol#'
			and
			Comm_Datetime	>= #createodbcdate(startdate)#
</CFQUERY>


<CFIF Get_Commodity_Data.recordcount EQ 0>
	<BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
	<CENTER><H4>There are no records for this commodity</H4></CENTER>
	<CFABORT>
</CFIF>
 --->

 
 

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decide Which link to show --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!------<CFIF request.TemplateName EQ 'view_commodity_chart.cfm'>
	<!---------
	<CFSET headerlink="<FONT COLOR='Red'><B>[</B></FONT>&nbsp;<A HREF='view_commodity_data.cfm?Symbol=#URL.Symbol#&amp;datasize=#URL.datasize#&amp;start_date=#startdate#&amp;end_date=#enddate#&amp;Comm_Month_Year=#Comm_Month_Year#'>view data</A>&nbsp;<FONT COLOR='Red'><B>]</B></FONT>">
	------------>
	<CFSET headerlink="<FONT COLOR='Red'><B>[</B></FONT>&nbsp;<A HREF='view_commodity_data.cfm?Symbol=#URL.Symbol#&amp;datasize=#URL.datasize#">
	<CFIF startdate NEQ "" AND enddate NEQ "">
		<CFSET headerlink="#headerlink#&amp;start_date=#dateformat(startdate, "mm/dd/yyyy")#&amp;end_date=#dateformat(enddate, "mm/dd/yyyy")#">
	</CFIF>
	<CFSET headerlink="#headerlink#&amp;Comm_Month_Year=#Comm_Month_Year#'>view data</A>&nbsp;<FONT COLOR='Red'><B>]</B></FONT>">
<CFELSE>
	<CFSET headerlink="<FONT COLOR='Red'><B>[</B></FONT>&nbsp;<A HREF='javascript:history.back();'>view graph</A>&nbsp;<FONT COLOR='Red'><B>]</B></FONT>">
</CFIF>
----->


<TABLE CELLPADDING="2" CELLSPACING="2" BORDER="0" WIDTH="100%">
<TR>
	<TD WIDTH="100%">
		<DIV STYLE="font-size:14px; font-weight:bold; background-color: Navy; color: White; padding: 3px;">
		<CFOUTPUT>
			#Get_Commodity_Name.Symbol_Description#<BR>#URL.datasize# days - #dateformat(startdate, 'm/d/yyyy')# - #dateformat(enddate, 'm/d/yyyy')#
		</CFOUTPUT>
		</DIV>	
	</TD>
</TR>
</TABLE>

