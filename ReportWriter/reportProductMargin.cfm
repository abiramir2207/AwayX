<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxProduct Summaryxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!-----<CFINCLUDE TEMPLATE="#reportProductLookup#">------->
<cfoutput>
<cfif isDefined("rID")>
<!-----------------------------------------------------------------------
	Get Prev record from DB
	--------------------------------------------------------------------------->
	<CFQUERY NAME="q_getPrevReport" datasource="#application.datasource#">
	Select 	top 1 Report_Type_ID
	From	Report_Type
	Where	Report_Type_ID < #rID#
	Order By Report_Type_ID DESC
	</CFQUERY>
	<!-----------------------------------------------------------------------
	End - Get Prev record from DB
	--------------------------------------------------------------------------->
	
	<!-----------------------------------------------------------------------
	Get Prev record from DB
	--------------------------------------------------------------------------->
	<CFQUERY NAME="q_getNextReport" datasource="#application.datasource#">
	Select 	top 1 Report_Type_ID
	From	Report_Type
	Where	Report_Type_ID > #rID#
	Order By Report_Type_ID ASC
	</CFQUERY>
	<!-----------------------------------------------------------------------
	End - Get Prev record from DB
	--------------------------------------------------------------------------->
	
		
	<CFIF q_getPrevReport.recordCount GT 0>
		<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
				<A HREF="#reportDetailsPage#?rID=#q_getPrevReport.Report_Type_ID#">
					< Prev
				</A>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
	</CFIF>
	
	<CFIF q_getNextReport.recordCount GT 0>
		<B>
		<FONT SIZE="2" COLOR="Red">[</FONT>
		<FONT SIZE="2" COLOR="Blue">
				<A HREF="#reportDetailsPage#?rID=#q_getNextReport.Report_Type_ID#">
					Next > 
				</A>
		</FONT>
		<FONT SIZE="2" COLOR="Red">]</FONT>
		</B>
	</CFIF>
<cfelse>
	<SPAN CLASS="title2">Create Product Margin Report
</cfif>
</SPAN>
</cfoutput>

<HR COLOR="Orange" SIZE="1">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
<CFINCLUDE TEMPLATE="#reportProductMarginForm#">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	
