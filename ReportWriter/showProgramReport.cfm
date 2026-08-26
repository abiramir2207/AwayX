<!-----------------showReport.cfm----------------->
<!----------------Set Defaults--------->
<cfset srNotCSV=true>
<cfif rReportOutputType EQ "e">
	<cfcontent type="application/unknown">
	<cfheader name="Content-Disposition" value="attachment;filename=programSummaryReport.xls">
<cfelseif rReportOutputType EQ "c">
	<cfcontent type="application/unknown">
	<cfheader name="Content-Disposition" value="attachment;filename=programSummaryReport.csv">
	<cfset srNotCSV=false>
</cfif>
<cfif rReportOutputType EQ "h">
<CFOUTPUT>
<html>
<head><title>#Form.rReportType# Report</title></head>
<style type="text/css">
.Title2
{
	color: Navy;
	font-size: 14px;
	font-weight: bold;
}
</style>
<style type="text/css" media="print">
thead	
{
display: table-header-group;
}

tfoot	
{
display: table-footer-group;
}
</style>
</CFOUTPUT>
</cfif>
<cfif isDefined("srqueryname")>
	<cfset srQuery=Evaluate(srqueryname)>	
	<cfif rReportOutputType EQ "h">
		<CFOUTPUT><SPAN CLASS="title2">#Form.rReportType# created on #DateFormat(Now(),"mm/dd/yyyy")# #TimeFormat(Now(),"hh:mm:ss tt")#</SPAN><BR><b>(#UCase(reportDescription)#)</b><BR><BR></CFOUTPUT>
	</cfif>
	<cfif srQuery.recordCount GT 0>
		<cfset extraCols=3>
		<cfset groupByVars="">		
		<cfif srNotCSV>
		<cfoutput><TABLE BORDER="1" CELLPADDING="1" CELLSPACING="0" WIDTH="90%" BGCOLOR="cccccc">
		<THEAD></cfoutput>
		</cfif>
			<!----<cfloop index="i" list="#sGroupByList#" delimiters=",">---->
			<cfset tempArray=ListToArray(sGroupByList,",")>
			<cfset ArraySet(tempArray, 1, ArrayLen(tempArray), "-")>
			<cfset groupByVars=ArrayToList(tempArray,",")>
			<cfloop index="i" list="#ListAppend(sGroupByList,sHeaderIDList,",")#" delimiters=",">
					<cfswitch expression="#i#">
						<cfcase value="status">							
							<cfif srNotCSV><cfoutput><TH>Status</TH></cfoutput><cfelse>
							<cfoutput>Status,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="zone">
							<cfif srNotCSV><cfoutput><TH>Zone</TH></cfoutput><cfelse>
							<cfoutput>Zone,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="region">
							<cfif srNotCSV><cfoutput><TH>Region</TH></cfoutput><cfelse>
							<cfoutput>Region,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="broker">
							<cfif srNotCSV><cfoutput><TH>Broker</TH></cfoutput><cfelse>
							<cfoutput>Broker,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="programtype,programnumber,programtitle,quantity,uom,startdate,enddate" delimiters=",">
							<cfset hVal=ListGetAt(programColumnHeaders,ListFindNOCase(programColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TH>#hVal#</TH></cfoutput><cfelse>
							<cfoutput>#hVal#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
					</cfswitch>
					<!---<cfset groupByVars=ListAppend(groupByVars,"-",",")>--->
			</cfloop>			
		<cfif srNotCSV><cfoutput></THEAD></cfoutput><cfelse>
		<cfoutput>#chr(13)##chr(10)#</cfoutput>
		</cfif>
		<cfloop query="srQuery">		
				<cfloop index="i" list="#sGroupByList#" delimiters=",">
					<cfset iPos=ListFindNOCase(sGroupByList,i,",")>
					<cfset srTemp=Evaluate(ListGetAt(sGroupFieldList,iPos,","))>
					<cfif srNotCSV>
						<cfif ListGetAt(groupByVars,iPos,",") NEQ srTemp>
						<cfset groupByVars=ListSetAt(groupByVars,iPos,srTemp,",")>
						<cfloop index="j" from="#Val(iPos+1)#" to="#ListLen(groupByVars)#">
							<cfset groupByVars=ListSetAt(groupByVars,j,"-",",")>
						</cfloop>
						<cfoutput>
						<TR BGCOLOR="ffe4b5">
						<cfloop index="j" from="2" to="#ListFIndNoCase(sGroupByList,i,",")#">
						<TD></TD>
						</cfloop>
						<TD COLSPAN="#Val(extraCols-iPos+1)#"><b>#ListGetAt(groupByVars,iPos,",")#</b></TD>
						</TR>
						</cfoutput>
						</cfif>
					<cfelse>
					<cfoutput>#srTemp#,</cfoutput>
					</cfif>
				</cfloop>
				
				<cfif srNotCSV>
				<cfoutput>
				<TR BGCOLOR="ffffff">
					<cfloop index="i" list="#sGroupByList#" delimiters=",">
					<TD>&nbsp;</TD>
					</cfloop>
				</cfoutput>
				</cfif>
				<cfloop index="i" list="#sHeaderNameList#" delimiters=",">
					<cfset thisColVal=Evaluate(i)>
					<cfif srNotCSV>
					<cfoutput>
					<TD>#thisColVal#</TD>
					</cfoutput>
					<cfelse>
					<cfoutput>#thisColVal#,</cfoutput>
					</cfif>
				</cfloop>
				
				<cfif srNotCSV><cfoutput></TR></cfoutput>
				<cfelse>
				<cfoutput>#chr(13)##chr(10)#</cfoutput>
				</cfif>
		</cfloop>		
		<cfif srNotCSV><cfoutput></TABLE></cfoutput></cfif>
		<cfif rReportOutputType EQ "h">	
		<CFOUTPUT><TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" WIDTH="176" HEIGHT="35" BACKGROUND="/images/print_button.gif">
		<TR>
		<TD><A HREF="javascript:void(0);" onClick="javascript:window.print();"><IMG SRC="/images/fill.gif" ALT="" WIDTH="176" HEIGHT="35" BORDER="0"></A></TD>
		</TR>
		</TABLE></CFOUTPUT>	
		</cfif>
	<cfelse>
		<cfif rReportOutputType EQ "h">
		<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		Report is Empty
		</B></FONT></CFOUTPUT>
		</TD>
		</TD>
		</TR>
		</TABLE>
		<cfelse>		
		<cfoutput>Report is Empty</cfoutput>
		</cfif>
	</cfif>
<cfelse>
	SysError - Queryname is required field
</cfif>

<cfif (rReportOutputType EQ "e") OR (rReportOutputType EQ "c")>
	<cfabort>
<cfelse>
	</body></html>
</cfif>