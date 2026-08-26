<CFQUERY NAME="getFiscalCalendar" datasource="#application.datasource#">
	SELECT *
	FROM Fiscal_Year
	WHERE Deleted = 0 AND Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
	ORDER BY Start_Date 
</CFQUERY>


<SPAN CLASS="title2">Current Saved Settings<Span style="Color:red;font-size: 12pt;font-weight: bold;">*</Span><BR>
<HR COLOR="Orange">

<!--- Number of columns to display --->
<CFSET number_of_columns=2>

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="2">
	<CFSET tablecounter=0>
	<TR>	
	<CFOUTPUT>
	<CFLOOP QUERY="getFiscalCalendar">
		<TD>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
				<TR>					
					<TD NOWRAP WIDTH="60">Period #Evaluate(tablecounter+1)#:&nbsp;&nbsp;</TD>
					<TD><INPUT STYLE="width: 75px; border: Solid 0px;" TYPE="text" READONLY value="#DateFormat(getFiscalCalendar.start_date,"mm/dd/yyyy")#"><INPUT STYLE="width: 75px; border: Solid 0px;" TYPE="text" value="#DateFormat(getFiscalCalendar.end_date,"mm/dd/yyyy")#"></TD>
				</TR>
			</TABLE>
		</TD>
		<CFSET tablecounter=tablecounter+1>
		#IIf(tablecounter Mod number_of_columns,DE(''),DE('</TR><TR>'))#
	</CFLOOP>
	</CFOUTPUT>
	<TR>
		<TD colspan="2">
			<Span style="font-size: 10pt;">(<Span style="Color:red;font-size: 12pt;font-weight: bold;">*</Span> Changes made to the fiscal calendar are not retroactive.  In order to update Auto Pay Program Pay Periods, the program must be revised to get the new dates.)</SPAN>
		</TD>
	</TR>
</TABLE>

