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
td
{
	font-size: 9px;
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
		<cfoutput><TABLE BORDER="1" CELLPADDING="0" CELLSPACING="0" BGCOLOR="cccccc"><THEAD BGCOLOR="999999"><TR></cfoutput>
		</cfif>
				<!-----<CFQUERY dbtype="query" name="srFiscalQuery">
				SELECT	distinct fyStartDate,fyEndDate
				FROM	srQuery
				</cfquery>------->
				<CFQUERY name="srFiscalQuery">
				SELECT	fy.end_date as fyEndDate, fy.start_date as fyStartDate
				FROM 	Fiscal_Year fy 
				WHERE 	DATEDIFF(day,GetDate(),fy.End_Date) >= 0
						AND fy.Deleted=0
				Order by fy.start_date	
				</cfquery>
				
				<cfset fiscalCount=srFiscalQuery.recordCount>
			<!----<cfloop index="i" list="#sGroupByList#" delimiters=",">---->
				<cfif ListLen(sGroupByList,",") GT 0>
					<cfset tempArray=ListToArray(sGroupByList,",")>
					<cfset ArraySet(tempArray, 1, ArrayLen(tempArray), "-")>
					<cfset groupByVars=ArrayToList(tempArray,",")>
				</cfif>
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
						<cfcase value="zone">
							<cfif srNotCSV>
							<cfoutput><TH ROWSPAN=2>Zone</TH></cfoutput>
							<cfelse>
							<cfoutput>Zone,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="region">
							<cfif srNotCSV>
							<cfoutput><TH ROWSPAN=2>Region</TH></cfoutput>
							<cfelse>
							<cfoutput>Region,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="broker">
							<cfif srNotCSV>
							<cfoutput><TH ROWSPAN=2>Broker</TH></cfoutput>
							<cfelse>
							<cfoutput>Broker,</cfoutput>
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
						<cfcase value="distributor">
							<cfif srNotCSV>
							<cfoutput><TH ROWSPAN=2>#application.returned_customer_setting.distributor_label_plural#</TH></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.distributor_label_plural#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="programtype,programnumber,volume,uom,startdate,enddate" delimiters=",">
							<cfset hVal=ListGetAt(programColumnHeaders,ListFindNOCase(programColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TH ROWSPAN=2>#hVal#</TH></cfoutput><cfelse>
							<cfoutput>#hVal#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="programtitle">
							<cfset hVal=ListGetAt(programColumnHeaders,ListFindNOCase(programColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TH ROWSPAN=2 WIDTH="250"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#hVal#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</nobr></TH></cfoutput><cfelse>
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
			<cfif srNotCSV><cfoutput><TR BGCOLOR="ffffff" ALIGN="CENTER"></cfoutput></cfif>
			
			<cfloop index="i" list="#ListAppend(sHeaderIDList,",")#" delimiters=",">
				<cfif ListFindNoCase(vProgramColumnHeaderID,i,",")>
					<cfset loopCnt=1>
					<cfloop query="srFiscalQuery" startrow=1 endrow=12>
						<cfset extraCols=extraCols+1>
						<cfif srNotCSV><cfoutput><TD>#DateFormat(fyStartDate,"mm/dd/yyyy")#<br>- <br>#DateFormat(fyEndDate,"mm/dd/yyyy")#</TD></cfoutput>
						<cfelse>
						<cfset fisName=ListGetAt(vProgramColumnHeaders,ListFindNoCase(vProgramColumnHeaderID,i,","),",")>
						<cfif ListLen(fisName," ") GTE 3>
							<cfset fisName=ListGetAt(fisName,3," ")>
						</cfif>
						<cfoutput>#fisName# Period#loopCnt#,</cfoutput>
						</cfif>
						<cfset loopCnt=loopCnt+1>
					</cfloop>
				</cfif>				
			</cfloop>
			<cfif srNotCSV><cfoutput></TR></cfoutput></cfif>
			
		<cfif srNotCSV><cfoutput></THEAD><TBODY></cfoutput>
		<cfelse>
		<cfoutput>#chr(13)##chr(10)#</cfoutput>
		</cfif>
		
		<cfset contactNumber="">
		<cfset totalAdded=false>
		<cfloop query="srQuery">
				
				<!--------------show group by column values ----------------------->				
				<cfloop index="i" list="#sGroupByList#" delimiters=",">
					<cfset iPos=ListFindNoCase(sGroupByList,i,",")>					
					<cfset srTemp=Evaluate(ListGetAt(sGroupFieldList,iPos,","))>
					<cfif srTemp EQ "">
						<cfset srTemp = " ">
					</cfif>
					<cfif srNotCSV>
						<cfif ListGetAt(groupByVars,iPos,",") NEQ srTemp>
						<!----------------------------------------------------------------------------------------->
						<cfif totalAdded AND (iPos EQ 1)>
							<cfoutput><TR VALIGN="TOP"></cfoutput>
							<CFOUTPUT><TD COLSPAN="#Evaluate("#ListLen(sGroupByList,",")#+#ListLen(fProgramColumnHeaderID,",")#-1")#"><b>Total for #ListGetAt(groupByVars,1,",")#</b></TD></CFOUTPUT>
							
							
							<cfloop index="k" list="#sHeaderNameList#" delimiters=",">					
								<cfset thisFieldID=ListGetAt(sHeaderIDList,ListFindNoCase(sHeaderNameList,k,","),",")>
									<cfif ListFindNoCase(vProgramColumnHeaderID,thisFieldID,",")>
										<cfset thisFieldName=ListGetAt(vProgramColumnFields,ListFindNoCase(vProgramColumnHeaderID,thisFieldID,","),",")> 
										<cfset thisFieldName=ListLast(thisFieldName,".")>
										<cfloop  query="srFiscalQuery" startrow="1" endrow="12">
											<CFOUTPUT><TD ALIGN=RIGHT TITLE="Total for #Trim(ListGetAt(groupByVars,iPos,","))#"><nobr>#DecimalFormat(Evaluate("#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"))#</nobr></TD></CFOUTPUT>
											<cfset "#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"=0>
										</cfloop>
								</cfif>
							</cfloop>					
							<cfoutput></TR></cfoutput>
						</cfif>
						
						<!----------------------------------------------------------------------------------------->
							<cfset contactNumber="">
							<cfset groupByVars=ListSetAt(groupByVars,iPos,srTemp,",")>
							<cfloop index="j" from="#Val(iPos+1)#" to="#ListLen(groupByVars)#">
								<cfset groupByVars=ListSetAt(groupByVars,j,"-",",")>
							</cfloop>
							<cfoutput><TR BGCOLOR="</cfoutput>
						<cfswitch expression="#iPos#">
							<cfcase value="1">
								<cfset rgbColor="ffe4b5">
							</cfcase>
							<cfcase value="2">
								<cfset rgbColor="90ee90">
							</cfcase>
							<cfcase value="3">
								<cfset rgbColor="99ccff">
							</cfcase>
							<cfcase value="4">
								<cfset rgbColor="ffefd5">
							</cfcase>
							<cfdefaultcase>
								<cfset rgbColor="e0ffff">
							</cfdefaultcase>
						</cfswitch>
						<cfoutput>#rgbColor#"></cfoutput>
							<cfloop index="j" from="2" to="#ListFindNoCase(sGroupByList,i,",")#">
							<CFOUTPUT><TD>&nbsp;</TD></CFOUTPUT>
							</cfloop>
							<cfoutput><TD COLSPAN="#Val(extraCols-iPos+1)#"><b>#Replace(ListGetAt(groupByVars,iPos,",")," ","&nbsp;")#</b></TD></TR></cfoutput>
						</cfif>
					<cfelse>
						<!-----<cfset contactNumber="">------->
						<cfset iPos=ListFindNoCase(sGroupByList,i,",")>
						<cfset groupByVars=ListSetAt(groupByVars,iPos,srTemp,",")>						
						<cfloop index="j" from="#Val(iPos+1)#" to="#ListLen(groupByVars)#">
							<cfset groupByVars=ListSetAt(groupByVars,j,"-",",")>
						</cfloop>
						<cfif contactNumber NEQ Contract_Number>
							<cfoutput>#Trim(srTemp)#,</cfoutput>
						</cfif>
					</cfif>
				</cfloop>
				<!--------------show group by column values ----------------------->
				
		<cfif contactNumber NEQ Contract_Number>
			<cfset contactNumber=Contract_Number>
				<cfif srNotCSV>
				<cfoutput><TR VALIGN="TOP" BGCOLOR="ffffff"></cfoutput>
					<cfloop index="i" list="#sGroupByList#" delimiters=",">
					<CFOUTPUT><TD></TD></CFOUTPUT>
					</cfloop>				
				</cfif>
			
				<cfloop index="i" list="#sHeaderNameList#" delimiters=",">
					<cfset thisColVal=Evaluate(i)>
					<cfswitch expression="#i#">
						<cfcase value="Contract_Start_Date,Contract_End_Date" delimiters=",">
							<cfset thisColVal=DateFormat(thisColVal,"mm/dd/yyyy")>
						</cfcase>							
					</cfswitch>
					<cfset thisFieldID=ListGetAt(sHeaderIDList,ListFindNoCase(sHeaderNameList,i,","),",")>
					<cfswitch expression="#thisFieldID#">
						<cfcase value="fiscalvolume,fiscalexpense,fiscalmargin" delimiters=",">							
							
							<cfset thisCount=0>
							<cfif srFiscalQuery.recordCount GT 0>								
								<cfset thisFieldName=ListGetAt(vProgramColumnFields,ListFindNoCase(vProgramColumnHeaderID,thisFieldID,","),",")> 
								<cfset thisFieldName=ListLast(thisFieldName,".")>
								<cfset volPerDay=Evaluate("#thisFieldName#")>
								
								<cfset C_Start_Date=Contract_Start_Date>
								<cfset C_End_Date=Contract_End_Date>								
								<cfloop  query="srFiscalQuery" startrow="1" endrow="12">
									<cfif NOT IsDefined("#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#")>
										<cfset "#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"=0>
										<cfset totalAdded=true>
									</cfif>
									<cfset thisCount=thisCount+1>									
									<cfif (volPerDay EQ "") OR (fyStartDate EQ "") OR (fyEndDate EQ "")>
										<cfif srNotCSV>
											<cfoutput><TD></TD></cfoutput>
										<cfelse>
											<cfoutput>,</cfoutput>
										</cfif>
									<cfelse>
										<!-----<cfif isDefined("#thisFieldName##ListLast(contactNumber,"-")##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)##Month(fyEndDate)##Day(fyEndDate)##Year(fyEndDate)#")>
											<cfset fiscalYearVolume=evaluate("#thisFieldName##ListLast(contactNumber,"-")##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)##Month(fyEndDate)##Day(fyEndDate)##Year(fyEndDate)#")>
										<cfelse>------->
											<cfif DateDiff('d',C_Start_Date,fyStartDate) GT 0>
												<cfset vStartDate=fyStartDate>
											<cfelse>
												<cfset vStartDate=C_Start_Date>
											</cfif>
											<cfif DateDiff('d',fyEndDate,C_End_Date) GT 0>
												<cfset vEndDate=fyEndDate>
											<cfelse>
												<cfset vEndDate=C_End_Date>
											</cfif>									
											<cfif DateDiff('d',vStartDate,vEndDate) GTE 0>
												<cfset fiscalYearVolume=volPerDay*(DateDiff('d',vStartDate,vEndDate) + 1)>
												<cfset "#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"=Evaluate("#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#")+fiscalYearVolume>
											<cfelse>
												<cfset fiscalYearVolume="">
											</cfif>
											
											<cfif Len(fiscalYearVolume) Gt 0>
												<cfif srNotCSV><cfset fiscalYearVolume="#DecimalFormat(fiscalYearVolume)#"></cfif>
											</cfif>
											<!-----<cfset "#thisFieldName##ListLast(contactNumber,"-")##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)##Month(fyEndDate)##Day(fyEndDate)##Year(fyEndDate)#"=fiscalYearVolume>
										</cfif>------->
										
										<cfif srNotCSV>
											<cfoutput><TD ALIGN=RIGHT TITLE="#ListGetAt(vProgramColumnHeaders,ListFindNOCase(vProgramColumnHeaderID,thisFieldID,","),",")#"><nobr>#fiscalYearVolume#</nobr></TD></cfoutput>
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
								<cfoutput><TD>&nbsp;</TD></cfoutput>
							<cfelse>
								<cfoutput>,</cfoutput>
							</cfif>
							</cfloop>
						
						</cfcase>						
						<cfdefaultcase>							
							<cfif srNotCSV>
								<cfoutput><TD <cfif IsNumeric(thisColVal)> ALIGN="RIGHT"</cfif> TITLE="#ListGetAt(fProgramColumnHeaders,ListFindNoCase(fProgramColumnHeaderID,ListGetAt(sHeaderIDList,ListFindNoCase(sHeaderNameList,i,","),","),","),",")#"> #thisColVal#</TD></cfoutput>
							<cfelse>
								<cfoutput>#Replace(ReplaceList(thisColVal,"#chr(13)#,#chr(10)#"," , "),",","","All")#,</cfoutput>
							</cfif>
						</cfdefaultcase>
					</cfswitch>
				</cfloop>					
			
				<cfif srNotCSV>	<cfoutput></TR></cfoutput>
				<cfelse><cfoutput>#chr(13)##chr(10)#</cfoutput></cfif>
			</cfif>
				
		</cfloop>
		
		<cfif srNotCSV>
		<cfif totalAdded AND (ListLen(sGroupByList) GT 0)>
			<cfoutput><TR VALIGN="TOP"></TR></cfoutput>
			<!-----<cfloop index="i" list="#sGroupByList#" delimiters=",">------->
			<CFOUTPUT><TD COLSPAN="#Evaluate("#ListLen(sGroupByList,",")#+#ListLen(fProgramColumnHeaderID,",")#-1")#"><b>Total for #ListGetAt(groupByVars,1,",")#</b></TD></CFOUTPUT>
			<!-----</cfloop>		------->		
			
			
			<cfloop index="j" list="#sHeaderNameList#" delimiters=",">					
				<cfset thisFieldID=ListGetAt(sHeaderIDList,ListFindNoCase(sHeaderNameList,j,","),",")>
					<cfif ListFindNoCase(vProgramColumnHeaderID,thisFieldID,",")>
						<cfset thisFieldName=ListGetAt(vProgramColumnFields,ListFindNoCase(vProgramColumnHeaderID,thisFieldID,","),",")> 
						<cfset thisFieldName=ListLast(thisFieldName,".")>
						<cfloop  query="srFiscalQuery" startrow="1" endrow="12">
							<CFOUTPUT><TD ALIGN=RIGHT  TITLE="Total for #ListGetAt(groupByVars,1,",")#"><nobr>#DecimalFormat(Evaluate("#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"))#</nobr></TD></CFOUTPUT>
							<cfset "#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"=0>
						</cfloop>
				<!-----<cfelse>
					<CFOUTPUT><TD></TD></CFOUTPUT>------->
				</cfif>
			</cfloop>					
			<cfoutput></TR></cfoutput>
		</cfif>
		</cfif>
			<cfif srNotCSV><cfoutput></TBODY></TABLE></FONT></cfoutput></cfif>		
	<cfelse>
		<cfif rReportOutputType EQ "h">
		<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<CFOUTPUT><FONT SIZE="2"><B>
		Report is Empty
		</B></CFOUTPUT>
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