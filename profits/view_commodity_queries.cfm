<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Calculate the first date to get data for: go back xx days										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF (IsDefined("start_date") AND IsDefined("end_date")) AND (start_date NEQ "" AND end_date NEQ "")>
 	<CFSET startdate=start_date> 	
	<CFSET enddate =end_date>
	<CFSET URL.datasize = DateDiff("d", startdate, enddate)+1>
	<CFSET startdate=start_date> 
<CFELSE>
	<CFPARAM NAME="URL.datasize" DEFAULT="60">
	<CFSET startdate=DateAdd("d", Evaluate((URL.datasize*(-1))+1), now())>
	<CFSET enddate =Now()>	
</CFIF>


<CFPARAM NAME="FORM.Symbol" DEFAULT="">
<CFPARAM NAME="URL.Symbol" DEFAULT="#FORM.Symbol#">




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the full name of the Commodity															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Commodity_Name" datasource="#application.datasource#">
	Select	Symbol_Description
	From	Commodities_Symbol
	Where	Symbol	=	'#URL.Symbol#'
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the data for this commodity for the period selected										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Commodity_Data" datasource="#application.datasource#">
	Select	Comm_Datetime,
			Comm_Last,
			Comm_Previous
	From	Commodities
	Where	Comm_Symbol	=	'#URL.Symbol#'
			and
			Comm_Datetime	>= #createodbcdate(startdate)#
			and
			Comm_Datetime	<= #createodbcdate(enddate)#			
			<CFIF Comm_Month_Year NEQ "">
			and
			Comm_Month_Year	=	'#Comm_Month_Year#'
			</CFIF>
	Order by Comm_Datetime
</CFQUERY>


<CFIF Get_Commodity_Data.recordcount EQ 0>

	<!--- Get the maturity month and year --->
	<CFSET MONTH=LEFT(Comm_Month_Year,1)>
	<CFSET YEAR=200&left(reverse(Comm_Month_Year),1)>

	<CFQUERY NAME="Get_Maturity_Date_Code" datasource="#application.datasource#">
	Select COMMODITIES_DATECODE_NAME FROM Commodities_Datecode WHERE COMMODITIES_DATECODE='#MONTH#'
	</CFQUERY>

	<BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
	<CENTER>
		<H4>
			<CFOUTPUT>
			There are no records for '<B>#Get_Commodity_Name.Symbol_Description#</B>'<BR>
			for the period of #dateformat(startdate, 'm/d/yy')# to #dateformat(now(), 'm/d/yy')#
			<!------<BR>
			that mature in #Get_Maturity_Date_Code.COMMODITIES_DATECODE_NAME# of #year#----->
			</CFOUTPUT>
		</H4>
		
		<BR><BR>
		<CFSET SUBMIT_TITLE = "try a different period">
		<CFINCLUDE TEMPLATE="commodity_date_form.cfm">
		<BR><BR><BR>
			<!------<FONT COLOR="Red"><B>[</B></FONT>&nbsp;<A HREF="javascript:history.back();">try a different period</A>&nbsp;<FONT COLOR="Red"><B>]</B></FONT>----->
		<B><FONT COLOR="ff0000" SIZE="2"><B>[</B></FONT>
		<A HREF="javascript:self.close();">close this window</A>
		<FONT COLOR="ff0000" SIZE="2"><B>]</B></FONT></B>
		</CENTER>
	<CFABORT>
</CFIF>

