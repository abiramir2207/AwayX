<cfif rReportOutputType EQ "h">
<CFOUTPUT>
<html>
<head><title>#UCase(ReplaceNoCase(reportType,"summary",""))# REPORT</title></head>
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
.negative
{
	color: red;
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
TABLE
{
	background-image: none;
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
		<CFOUTPUT><SPAN CLASS="title2">#UCase(ReplaceNoCase(reportType,"summary"," summary report"))# created on #DateFormat(Now(),"mm/dd/yyyy")# #TimeFormat(Now(),"hh:mm:ss tt")#</SPAN><cfif Len(reportDescription) GT 0><BR><b>(#UCase(reportDescription)#)</b></cfif><BR><BR></CFOUTPUT>
	</cfif>
	<cfif srQuery.recordCount GT 0>
		<!--- <cfoutput>#sGroupByList#, #sHeaderIDList#<br>
		#sGroupFieldList#</cfoutput> --->
	
		<cfset extraCols=1>
		<!-----<cfset groupByVars="">------->		
		<cfif srNotCSV>
		<cfoutput><TABLE BORDER="0" CELLPADDING="3" CELLSPACING="1" BGCOLOR="999999"><THEAD BGCOLOR="999999"><TR ALIGN=CENTER></cfoutput>
		</cfif>
				<cfif isDefined("srQuery.fyPosition")>
				<CFQUERY dbType="query" name="srFiscalQuery">
				SELECT	distinct fyEndDate, fyStartDate, fyPosition
				FROM 	srQuery
				</cfquery>
				</cfif>
				
				<!-----<cfset fiscalCount=srFiscalQuery.recordCount>------->
				
				<cfif ListLen(sGroupByList,",") GT 0>
					<cfset tempArray=ListToArray(sGroupByList,",")>
					<cfset ArraySet(tempArray, 1, ArrayLen(tempArray), "-")>
					<!-----<cfset groupByVars=ArrayToList(tempArray,",")>------->
				</cfif>
				<cfloop index="i" list="#ListAppend(sGroupByList,sHeaderIDList,",")#" delimiters=",">
					<cfswitch expression="#i#">
						<cfcase value="status">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>Status</TD></cfoutput>
							<cfelse>
							<cfoutput>Status,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="zone">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>#application.returned_customer_setting.zone_label_singular#</TD></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.zone_label_singular#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="region">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>#application.returned_customer_setting.region_label_singular#</TD></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.region_label_singular#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="broker">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>#application.returned_customer_setting.broker_label_singular#</TD></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.broker_label_singular#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="family">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>#application.returned_customer_setting.family_name_label_singular#</TD></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.family_name_label_singular#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="buyinggroup">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>#application.returned_customer_setting.buying_group_label_singular#</TD></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.buying_group_label_singular#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="distributor">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>#application.returned_customer_setting.distributor_label_singular#</TD></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.distributor_label_singular#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="programtype,programnumber,volume,uom,startdate,enddate" delimiters=",">
							<cfset hVal=ListGetAt(programColumnHeaders,ListFindNOCase(programColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TD ROWSPAN=2>#hVal#</TD></cfoutput><cfelse>
							<cfoutput>#hVal#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="programtitle">
							<cfset hVal=ListGetAt(programColumnHeaders,ListFindNOCase(programColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TD ROWSPAN=2 WIDTH="250"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#hVal#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</nobr></TD></cfoutput><cfelse>
							<cfoutput>#hVal#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="fiscalvolume,fiscalexpense,fiscalmargin" delimiters=",">
							<cfset hVal=ListGetAt(programColumnHeaders,ListFindNOCase(programColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TD COLSPAN="<cfif srFiscalQuery.recordCount LT 12>#srFiscalQuery.recordCount#<cfelse>12</cfif>">#hVal#</TD><TD ROWSPAN="2"></TD></cfoutput>
							</cfif>
						</cfcase>
					</cfswitch>
					<!-----<cfset groupByVars=ListAppend(groupByVars,"-",",")>------->
			</cfloop>	
		
		<cfset fixedColCount=extraCols>
		<cfif srNotCSV><cfoutput></TR></cfoutput></cfif>
			<cfif srNotCSV><cfoutput><TR BGCOLOR="ffffff" ALIGN="CENTER"></cfoutput></cfif>
			
			<cfloop index="i" list="#ListAppend(sHeaderIDList,",")#" delimiters=",">
				<cfif ListFindNoCase(vProgramColumnHeaderID,i,",")>
					<cfset loopCnt=1>
					<cfloop query="srFiscalQuery" startrow=1 endrow=12>
						<cfset extraCols=extraCols+1>
						<cfset fisName=ListGetAt(vProgramColumnHeaders,ListFindNoCase(vProgramColumnHeaderID,i,","),",")>
						<!-----<cfif ListLen(fisName," ") GTE 3>
							<cfset fisName=ListGetAt(fisName,3," ")>
						</cfif>------->
						<cfif srNotCSV>
						<!-----<cfoutput><TD>#DateFormat(fyStartDate,"mm/dd/yyyy")#<br>- <br>#DateFormat(fyEndDate,"mm/dd/yyyy")#</TD></cfoutput>------->
						<!-----<cfoutput><TD>FP#loopCnt#</TD></cfoutput>------->
						<cfoutput><TD>FP#fyPosition#</TD></cfoutput>
						<cfelse>						
						<!-----<cfoutput>#fisName# FP#loopCnt#,</cfoutput>------->
						<cfoutput>#fisName# FP#fyPosition#,</cfoutput>
						</cfif>
						<cfset loopCnt=loopCnt+1>
					</cfloop>
					<cfset extraCols=extraCols+1>					
				</cfif>				
			</cfloop>
			<cfif srNotCSV><cfoutput></TR></cfoutput></cfif>
	
		<cfif srNotCSV><cfoutput></THEAD><TBODY></cfoutput>
		<cfelse>
		<cfoutput>#chr(13)##chr(10)#</cfoutput>
		</cfif>
		
		<cfset contactNumber="">
		<cfset totalAdded=false>
		
		<cfset sNewGroups=sGroupFieldList>
		<cfif NOT ListFindNoCase(sNewGroups,"Contract_Status_Type_Desc",",")>
			<cfset sNewGroups=ListAppend(sNewGroups,"Contract_Status_Type_Desc",",")>
		</cfif>
		<!-----<cfif NOT ListFindNoCase(sNewGroups,"Created_Type",",")>
			<cfset sNewGroups=ListAppend(sNewGroups,"Created_Type",",")>
		</cfif>------->
		<cfif ListLen(sNewGroups) LT 2>
			<cfset sNewGroups=ListAppend(sNewGroups,"Contract_Number",",")>
		</cfif>
		<cfif ListLen(sNewGroups) LT 3>
			<cfset sNewGroups=ListAppend(sNewGroups,"Contract_Number",",")>
		</cfif>
		<cfif ListLen(sNewGroups) LT 4>
			<cfset sNewGroups=ListAppend(sNewGroups,"Contract_Number",",")>
		</cfif>
		
		
		<cfset totalAdded=false>
		<cfset groupColCount=0>
		<cfset thisPos=0>	
		
		<cfif srNotCSV>
			<cfoutput query="srQuery" group="#ListGetAt(sNewGroups,1,",")#"><cfsilent>
					
				<cfset thisPos=1>			
				<cfif ListLen(sGroupFieldList) GTE thisPos>
					<cfset groupByName=ListGetAt(sGroupFieldList,thisPos,",")>				
					<cfset groupColCount=thisPos>
				<cfelse>
					<cfset groupByName="">
				</cfif>
		<br><br> 
				</cfsilent><cfoutput group="#ListGetAt(sNewGroups,thisPos,",")#"><cfif ListLen(sGroupFieldList) GTE thisPos><cfsilent>
				<cfset thisVal=Evaluate(ListGetAt(sNewGroups,thisPos,","))>
				<cfif thisVal EQ "">
					<cfset groupPos=ListFindNoCase(sGroupFieldList,ListGetAt(sNewGroups,thisPos,","),",")>
					<cfif groupPos>
						<cfset thisVal="'No #ListGetAt(fieldExpansion,ListFindNoCase(fieldShortCut,ListGetAt(sGroupByList,groupPos,","),","),",")# Specified'">
					</cfif>
				</cfif>
				</cfsilent><TR VALIGN="TOP" BGCOLOR="ffe4b5"><cfif thisPos GT 1><TD COLSPAN="#Evaluate("#thisPos#-1")#"></TD></cfif><TD COLSPAN="#Evaluate("#extraCols#-#thisPos#")#">#thisVal#&nbsp;</TD></TR></cfif><cfsilent>
					<!------------------- End ------------------->
					
					<!------------------- Start ------------------->
						<cfset thisPos=2>
						<cfif ListLen(sGroupFieldList) GTE thisPos>
							<cfset groupByName=ListGetAt(sGroupFieldList,thisPos,",")>
							<cfset groupColCount=thisPos>
						<cfelse>
							<cfset groupByName="">
						</cfif>			
						</cfsilent><cfoutput group="#ListGetAt(sNewGroups,thisPos,",")#"><cfif ListLen(sGroupFieldList) GTE thisPos><cfsilent>
							<cfset thisVal=Evaluate(ListGetAt(sNewGroups,thisPos,","))>
							<cfif thisVal EQ "">
								<cfset groupPos=ListFindNoCase(sGroupFieldList,ListGetAt(sNewGroups,thisPos,","),",")>
								<cfif groupPos>
									<cfset thisVal="'No #ListGetAt(fieldExpansion,ListFindNoCase(fieldShortCut,ListGetAt(sGroupByList,groupPos,","),","),",")# Specified'">
								</cfif>
							</cfif>
				</cfsilent><TR VALIGN="TOP" BGCOLOR="ccffcc"><cfif thisPos GT 1><TD COLSPAN="#Evaluate("#thisPos#-1")#"></TD></cfif></TD><TD COLSPAN="#Evaluate("#extraCols#-#thisPos#")#">#thisVal#&nbsp;</TD></TR></cfif><cfsilent>
							<!------------------- End ------------------->
							
							<!------------------- Start ------------------->
							<cfset thisPos=3>
							<cfif ListLen(sGroupFieldList) GTE thisPos>
								<cfset groupByName=ListGetAt(sGroupFieldList,thisPos,",")>
								<cfset groupColCount=thisPos>
							<cfelse>
								<cfset groupByName="">
							</cfif>
							
							
							
							</cfsilent><cfoutput group="#Trim(ListGetAt(sNewGroups,thisPos,","))#"><cfif Len(groupByName) GT 0><TR VALIGN="TOP" BGCOLOR="ffcccc"><cfif thisPos GT 1><TD COLSPAN="#Evaluate("#thisPos#-1")#"></TD></cfif></TD><TD COLSPAN="#Evaluate("#extraCols#-#thisPos#")#">#Evaluate(ListGetAt(sNewGroups,thisPos,","))#&nbsp;</TD></TR></cfif><cfsilent>
							
							<!------------------- End ------------------->
							
							
							<!------------------- Start ------------------->
							<cfset thisPos=4>
							<cfif ListLen(sGroupFieldList) GTE thisPos>
								<cfset groupByName=ListGetAt(sGroupFieldList,thisPos,",")>
								<cfset groupColCount=thisPos>
							<cfelse>
								<cfset groupByName="">
							</cfif>
							
							
							
							</cfsilent><cfoutput group="#Trim(ListGetAt(sNewGroups,thisPos,","))#"><cfif Len(groupByName) GT 0><TR VALIGN="TOP" BGCOLOR="fffacd"><cfif thisPos GT 1><TD COLSPAN="#Evaluate("#thisPos#-1")#"></TD></cfif></TD><TD COLSPAN="#Evaluate("#extraCols#-#thisPos#")#">#Evaluate(ListGetAt(sNewGroups,thisPos,","))#&nbsp;</TD></TR></cfif><cfsilent>
							
							<!------------------- End ------------------->
							</cfsilent><cfoutput group="Contract_Number"><TR VALIGN="TOP" BGCOLOR="FFFFFF"><cfif groupColCount GT 0><TD COLSPAN="#groupColCount#"></TD></cfif><cfsilent>
								</cfsilent><cfloop list="#fProgramColumnFields#" index="j" delimiters=","><cfsilent>
									<cfset thisVal=Evaluate(ListLast(j,"."))>
									<cfif FindNoCase("date", j)>
									<cfif IsDate(thisVal)><cfset thisVal=DateFormat(thisVal,"mm/dd/yyyy")></cfif>
									</cfif>
									</cfsilent><cfif NOT ListFindNoCase(sGroupFieldList,ListLast(j,"."),",")><TD TITLE="#ListGetAt(fProgramColumnHeaders,ListFindNoCase(fProgramColumnFields,j,","),",")#">#thisVal#</TD></cfif></cfloop><cfsilent>
									</cfsilent><cfloop index="i" list="#sHeaderIDList#" delimiters=","><cfif ListFindNoCase(vProgramColumnHeaderID,i,",")><cfsilent>
											<cfset vPos=ListFindNoCase(vProgramColumnHeaderID,i,",")>
											<cfset thisFieldName=ListGetAt(vProgramColumnFields,vPos,",")> 
											<cfset ValuePerDay=Evaluate(thisFieldName)>										
											</cfsilent><cfset fs_Counter=0><cfoutput group="fyStartDate" maxRows="#Evaluate("#loopCnt#-1")#"><cfset fs_Counter = fs_Counter+1><cfif fs_Counter LTE Evaluate("#loopCnt#-1")><cfsilent>
												<cfif fyStartDate eq "" >
													<cfset totalAdded=true>
												<cfelse>
												<cfif NOT IsDefined("#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#")>
													<cfset "#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"=0>
													<cfset totalAdded=true>
												</cfif>
												</cfif>
												</cfsilent><cfif PeriodLength NEQ "" AND ValuePerDay NEQ ""><cfsilent>
													<cfset fiscalYearValue=Evaluate("#PeriodLength#*#ValuePerDay#")>
													<cfset "#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"=Evaluate("#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#")+fiscalYearValue>
													</cfsilent>
													<TD ALIGN=RIGHT TITLE="#ListGetAt(vProgramColumnHeaders,vPos,",")#"<CFIF fiscalYearValue LT 0> CLASS="negative"</CFIF>>
													<CFIF Trim(ListGetAt(vProgramExtra,vPos,",")) EQ "$">#DollarFormat(fiscalYearValue)#<CFELSE>#Trim(ListGetAt(vProgramExtra,vPos,","))##NumberFormat(fiscalYearValue)#</CFIF></TD><cfelse><TD></TD></cfif></cfif></cfoutput>
													<TD BGCOLOR="999999"></TD></cfif></cfloop><cfsilent>
								</cfsilent></TR><cfsilent>
							</cfsilent></cfoutput><cfsilent>
							<cfset thisPos=4>
						</cfsilent></cfoutput><cfsilent>
							<cfset thisPos=3>
						</cfsilent></cfoutput><cfsilent>
							
						<cfset thisPos=2>
					</cfsilent></cfoutput><cfsilent>
					
					<cfset thisPos=1>
						</cfsilent><cfif totalAdded><cfsilent>							
						<cfset thisVal=Evaluate(ListGetAt(sNewGroups,thisPos,","))>
						<cfif thisVal EQ "">
							<cfset groupPos=ListFindNoCase(sGroupFieldList,ListGetAt(sNewGroups,thisPos,","),",")>
							<cfif groupPos>
								<cfset thisVal="'No #ListGetAt(fieldExpansion,ListFindNoCase(fieldShortCut,ListGetAt(sGroupByList,groupPos,","),","),",")# Specified'">
							</cfif>
						<cfelse>
							<cfset thisVal=Trim(thisVal)>
						</cfif>				
							</cfsilent><TR VALIGN="TOP"><TD COLSPAN="#Evaluate("#fixedColCount#-1")#"><b>Total for #thisVal#</b></TD><cfsilent>
							
							</cfsilent><cfloop index="k" list="#sHeaderNameList#" delimiters=","><cfsilent>
								<cfset thisFieldID=ListGetAt(sHeaderIDList,ListFindNoCase(sHeaderNameList,k,","),",")>
								</cfsilent><cfif ListFindNoCase(vProgramColumnHeaderID,thisFieldID,",")><cfsilent>
									<cfset vPos=ListFindNoCase(vProgramColumnHeaderID,thisFieldID,",")>
									<cfset thisFieldName=ListGetAt(vProgramColumnFields,vPos,",")> 
									<cfset thisFieldName=ListLast(thisFieldName,".")>
									</cfsilent>
									<cfset fs_Counter=0>
									<cfoutput group="fyStartDate" maxRows="#Evaluate("#loopCnt#-1")#">
										<cfset fs_Counter = fs_Counter+1><cfif fs_Counter LTE Evaluate("#loopCnt#-1")><cfsilent>
										</cfsilent><TD ALIGN=RIGHT TITLE="Total #ListGetAt(vProgramColumnHeaders,ListFindNoCase(vProgramColumnHeaderID,thisFieldID,","),",")# for #thisVal#"><nobr>#Trim(ListGetAt(vProgramExtra,vPos,","))#<cfif fyStartDate neq "">#NumberFormat(Evaluate("#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"))#<cfelse>0</cfif></nobr></TD><cfsilent>
										<cfif fyStartDate neq "">
										<cfset "#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"=0>
										</cfif>
									</cfsilent></cfif></cfoutput><TD BGCOLOR="999999"></TD></cfif></cfloop><cfsilent>
							</cfsilent></TR><cfsilent>
					</cfsilent></cfif><cfsilent>
				</cfsilent></cfoutput><cfsilent>
				<cfset thisPos=0>
			</cfsilent></cfoutput>
		<cfelse>
			<cfoutput query="srQuery" group="#ListGetAt(sNewGroups,1,",")#"><cfoutput group="Contract_Number"><cfsilent>
			</cfsilent><cfloop index="i" list="#sGroupFieldList#" delimiters=","><cfsilent>
			</cfsilent>#Replace(ReplaceList(Evaluate(i),"#chr(13)#,#chr(10)#"," , "),","," ","All")#,<cfsilent>
			</cfsilent></cfloop><cfsilent>
			</cfsilent><cfloop list="#fProgramColumnFields#" index="j" delimiters=","><cfsilent>
									<cfset thisVal=Evaluate(ListLast(j,"."))>
									<cfif FindNoCase("date", j)>
									<cfif IsDate(thisVal)><cfset thisVal=DateFormat(thisVal,"mm/dd/yyyy")></cfif>
									</cfif>
									</cfsilent><cfif NOT ListFindNoCase(sGroupFieldList,ListLast(j,"."),",")>#Replace(ReplaceList(thisVal,"#chr(13)#,#chr(10)#"," , "),","," ","All")#,</cfif></cfloop><cfloop index="i" list="#sHeaderIDList#" delimiters=","><cfsilent>
				</cfsilent><cfif ListFindNoCase(vProgramColumnHeaderID,i,",")><cfsilent>
					<cfset vPos=ListFindNoCase(vProgramColumnHeaderID,i,",")>
					<cfset thisFieldName=ListGetAt(vProgramColumnFields,vPos,",")> 
					<cfset ValuePerDay=Evaluate(thisFieldName)>										
					</cfsilent><cfoutput group="fyStartDate" maxRows="#Evaluate("#loopCnt#-1")#"><cfsilent>
						</cfsilent><cfif PeriodLength NEQ "" AND ValuePerDay NEQ ""><cfsilent>
							<cfset fiscalYearValue=Evaluate("#PeriodLength#*#ValuePerDay#")>							
</cfsilent>#fiscalYearValue#,<cfsilent>
						</cfsilent><cfelse>,</cfif></cfoutput></cfif></cfloop>#chr(13)##chr(10)#</cfoutput></cfoutput>
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