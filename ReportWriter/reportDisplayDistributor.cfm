<cfif rReportOutputType EQ "h">
<CFOUTPUT>
<html>
<head><title>#reportType# Report</title></head>
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
<body>
</CFOUTPUT>
</cfif>

<cfif isDefined("srqueryname")>
	<cfset srQuery=Evaluate(srqueryname)>
	<cfset programColumnHeaderID=ListAppend(fProgramColumnHeaderID,vProgramColumnHeaderID,",")>
	<cfset programColumnFields=ListAppend(fProgramColumnFields,vProgramColumnFields,",")>	
	<cfset programColumnHeaders=ListAppend(fProgramColumnHeaders,vProgramColumnHeaders,",")>	
	
	<cfif rReportOutputType EQ "h">
		<CFOUTPUT><SPAN CLASS="title2">#reportType# created on #DateFormat(Now(),"mm/dd/yyyy")# #TimeFormat(Now(),"hh:mm:ss tt")#</SPAN><cfif Len(reportDescription) GT 0><BR><b>(#UCase(reportDescription)#)</b></cfif><BR><BR></CFOUTPUT>
	</cfif>
	
	<cfif srQuery.recordCount GT 0>
		<cfset extraCols=0>
		<cfset groupByVars="">		
		<cfif srNotCSV>
		<cfoutput>
		<TABLE BORDER="1" CELLPADDING="1" CELLSPACING="0" BGCOLOR="cccccc">
		<THEAD BGCOLOR="999999"><TR>
		</cfoutput>
		</cfif>
				<CFQUERY dbtype="query" name="srFiscalQuery">
				SELECT	distinct fyStartDate,fyEndDate
				FROM	srQuery
				</cfquery>
				<cfset fiscalCount=srFiscalQuery.recordCount>
			<!----<cfloop index="i" list="#sGroupByList#" delimiters=",">---->
				<cfset tempArray=ListToArray(sGroupByList,",")>
				<cfset ArraySet(tempArray, 1, ArrayLen(tempArray), "-")>
				<cfset groupByVars=ArrayToList(tempArray,",")>
				<cfloop index="i" list="#ListAppend(sGroupByList,sHeaderIDList,",")#" delimiters=",">
					<cfswitch expression="#i#">
						<cfcase value="status">
							<cfif srNotCSV>
							<cfoutput><TH ROWSPAN=2>Status</TH></cfoutput>
							<cfelse>
							<cfoutput>Status,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="family">
							<cfif srNotCSV>
							<cfoutput><TH ROWSPAN=2>Family</TH></cfoutput>
							<cfelse>
							<cfoutput>Family,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="buyinggroup">
							<cfif srNotCSV>
							<cfoutput><TH ROWSPAN=2>Buying Group</TH></cfoutput>
							<cfelse>
							<cfoutput>Buying Group,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="distributors">
							<cfif srNotCSV>
							<cfoutput><TH ROWSPAN=2>#application.returned_customer_setting.distributor_label_plural#</TH></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.distributor_label_plural#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="programtype,programnumber,programtitle,volume,uom,startdate,enddate" delimiters=",">
							<cfset hVal=ListGetAt(programColumnHeaders,ListFindNOCase(programColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TH ROWSPAN=2>#hVal#</TH></cfoutput><cfelse>
							<cfoutput>#hVal#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="fiscalvolume,fiscalexpense,fiscalmargin" delimiters=",">
							<cfset hVal=ListGetAt(programColumnHeaders,ListFindNOCase(programColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TH COLSPAN=#srFiscalQuery.recordCount#>#hVal#</TH></cfoutput>
							</cfif>
						</cfcase>
					</cfswitch>
					<cfset groupByVars=ListAppend(groupByVars,"-",",")>
			</cfloop>	
			
		<cfif srNotCSV><cfoutput></TR></cfoutput></cfif>
			<cfif srNotCSV><cfoutput><TR></cfoutput></cfif>
			<cfset loopCnt=1>
			<cfloop index="i" list="#ListAppend(sHeaderIDList,",")#" delimiters=",">
				<cfif ListFindNoCase(vProgramColumnHeaderID,i,",")>
					<cfloop query="srFiscalQuery" startrow=1 endrow=12>
						<cfset extraCols=extraCols+1>
						<cfif srNotCSV><cfoutput><TD BGCOLOR="ffffff"><b><nobr>#DateFormat(fyStartDate,"mm/dd/yyyy")# - #DateFormat(fyEndDate,"mm/dd/yyyy")#</nobr></b></TD></cfoutput><cfelse>
						<cfset fisName=ListGetAt(vProgramColumnHeaders,ListFindNoCase(vProgramColumnHeaderID,i,","),",")>
						<cfif ListLen(fisName," ") GTE 3>
							<cfset fisName=ListGetAt(fisName,3," ")>
						</cfif>
						<cfoutput>#fisName# Period#loopCnt#,</cfoutput>
						</cfif>
					</cfloop>
				</cfif>
				<cfset loopCnt=loopCnt+1>
			</cfloop>
			<cfif srNotCSV><cfoutput></TR></cfoutput></cfif>
			
		<cfif srNotCSV><cfoutput></THEAD><TBODY></cfoutput>
		<cfelse>
		<cfoutput>#chr(13)##chr(10)#</cfoutput>
		</cfif>
		
		<cfset contactNumber="">
		<cfloop query="srQuery">								
				<!--------------show group by column values ----------------------->				
				<cfloop index="i" list="#sGroupByList#" delimiters=",">
					<cfset iPos=ListFindNoCase(sGroupByList,i,",")>
					<cfset srTemp=Evaluate(ListGetAt(sGroupFieldList,iPos,","))>
					<cfif srNotCSV>
						<cfif ListGetAt(groupByVars,iPos,",") NEQ srTemp>
							<cfset contactNumber="">
							<cfset groupByVars=ListSetAt(groupByVars,iPos,srTemp,",")>
							<cfloop index="j" from="#Val(iPos+1)#" to="#ListLen(groupByVars)#">
								<cfset groupByVars=ListSetAt(groupByVars,j,"-",",")>
							</cfloop>
							<cfoutput>						
							<TR BGCOLOR="ffe4b5">
							<cfloop index="j" from="2" to="#ListFindNoCase(sGroupByList,i,",")#">
							<TD>&nbsp;</TD>
							</cfloop>
							<TD COLSPAN="#Val(extraCols-iPos+1)#"><b>#ListGetAt(groupByVars,iPos,",")#</b></TD>
							</TR>												
							</cfoutput>
						</cfif>
					<cfelse>
					<cfset contactNumber="">
					<cfset groupByVars=ListSetAt(groupByVars,iPos,srTemp,",")>
					<cfloop index="j" from="#Val(iPos+1)#" to="#ListLen(groupByVars)#">
						<cfset groupByVars=ListSetAt(groupByVars,j,"-",",")>
					</cfloop>
					<cfoutput>#Trim(srTemp)#,</cfoutput>
					</cfif>
				</cfloop>
				<!--------------show group by column values ----------------------->
				
		<cfif contactNumber NEQ Contract_Number>
			<cfset contactNumber=Contract_Number>
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
					<cfswitch expression="#i#">
						<cfcase value="Contract_Start_Date,Contract_End_Date" delimiters=",">
							<cfset thisColVal=DateFormat(thisColVal,"mm/dd/yyyy")>
						</cfcase>							
					</cfswitch>
					<cfswitch expression="#ListGetAt(sHeaderIDList,ListFindNoCase(sHeaderNameList,i,","),",")#">
						<cfcase value="fiscalvolume,fiscalexpense,fiscalmargin" delimiters=",">
							<cfswitch expression="#ListGetAt(sHeaderIDList,ListFindNoCase(sHeaderNameList,i,","),",")#">
								<cfcase value="fiscalvolume">
									<cfset volPerDay=VolumePerDay>
								</cfcase>
								<cfcase value="fiscalexpense">
									<cfset volPerDay=PTEC>
								</cfcase>
								<cfcase value="fiscalmargin">
									<cfset volPerDay=PTTM>
								</cfcase>								
							</cfswitch>
							
							
							<CFQUERY dbtype="query" name="srFiscalQuery">
								SELECT	distinct fyEndDate,fyStartDate
								FROM	srQuery
								WHERE	Contract_Number='#srQuery.Contract_Number#'
								<cfloop index="gList" list="#sGroupByList#" delimiters=",">
								<cfset iPos=ListFindNoCase(sGroupByList,gList,",")>
								 and #ListGetAt(sGroupFieldList,iPos,",")#='#Trim(ListGetAt(groupByVars,iPos,","))#'
								</cfloop>
							</cfquery>
							<cfset thisCount=0>
							<cfif srFiscalQuery.recordCount GT 0>								
								<cfloop  query="srFiscalQuery" startrow="1" endrow="12">
									<cfset thisCount=thisCount+1>
									<cfif volPerDay EQ "">
										<cfif srNotCSV>
										<cfoutput><TD  HEIGHT="100%" VALIGN=TOP></TD></cfoutput>
											<cfelse>
											<cfoutput>,</cfoutput>
										</cfif>
									<cfelse>
										<cfif DateDiff('d',srQuery.Contract_Start_Date,fyStartDate) GT 0>
											<cfset vStartDate=fyStartDate>
										<cfelse>
											<cfset vStartDate=srQuery.Contract_Start_Date>
										</cfif>
										<cfif DateDiff('d',fyEndDate,srQuery.Contract_End_Date) GT 0>
											<cfset vEndDate=fyEndDate>
										<cfelse>
											<cfset vEndDate=srQuery.Contract_End_Date>
										</cfif>									
										<cfif DateDiff('d',vStartDate,vEndDate) GT 0>
											<cfset fiscalYearVolume=volPerDay*DateDiff('d',vStartDate,vEndDate)>
										<cfelse>
											<cfset fiscalYearVolume=volPerDay>
										</cfif>
										
										<cfset fiscalYearVolume="#numberformat(fiscalYearVolume, '-___.____')#">
										<cfif srNotCSV>
											<cfoutput>
											<TD  HEIGHT="100%" VALIGN=TOP>											
											<nobr>#fiscalYearVolume#</nobr>&nbsp;
											</TD>
											</cfoutput>
											<cfelse>
											<cfoutput>#fiscalYearVolume#,</cfoutput>
										</cfif>					
									</cfif>
								</cfloop>								
							</cfif>
							<cfset colHeaderLen=fiscalCount>							
							<cfset colHeaderLen=colHeaderLen-thisCount>
							<cfloop index="k" from="1" to="#colHeaderLen#">
							<cfif srNotCSV>
								<cfoutput>
								<TD  HEIGHT="100%" VALIGN=TOP>&nbsp;</TD>
								</cfoutput>
								<cfelse>
								<cfoutput>,</cfoutput>
							</cfif>
							</cfloop>
						
						</cfcase>						
						<cfdefaultcase>
							<cfif srNotCSV>
							<cfoutput>
							<TD><nobr>#thisColVal#</nobr></TD>
							</cfoutput>
							<cfelse>
							<cfoutput>#thisColVal#,</cfoutput>
							</cfif>
						</cfdefaultcase>
					</cfswitch>
				</cfloop>					
			
				<cfif srNotCSV>	<cfoutput></TR></cfoutput>
				<cfelse><cfoutput>#chr(13)##chr(10)#</cfoutput></cfif>
			</cfif>
				
		</cfloop>			
			<cfif srNotCSV><cfoutput></TBODY></TABLE></cfoutput></cfif>		
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
<cfoutput>SysError - Queryname is required field</cfoutput>
</cfif>
<cfif (rReportOutputType EQ "h")>
	</body></html>
</cfif>