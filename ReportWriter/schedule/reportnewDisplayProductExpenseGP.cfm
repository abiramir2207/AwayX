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
<cfparam name="program_status" default="">
<cfparam name="PricePerday" default="0">
<cfparam name="ProgramExpense" default="0">
<cfparam name="billbackrate" type="numeric" default="0">
<cfparam name="totalbillbackrate" type="numeric" default="0">

<cfset rUnits = CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").getDatePeriods(2, #Startdate#, #Enddate#, #request.AccessStructure.Company_Main_ID#) />
<cfif isDefined("srqueryname")>
	<cfset srQuery=Evaluate(srqueryname)>	
	
	<cfset productColumnHeaderID=ListAppend(fProductColumnHeaderID,vProductColumnHeaderID,",")>
	<cfset productColumnFields=ListAppend(fProductColumnFields,vProductColumnFields,",")>	
	<cfset productColumnHeaders=ListAppend(fProductColumnHeaders,vProductColumnHeaders,",")>	
	<cfif rReportOutputType EQ "h">
		<CFOUTPUT><SPAN CLASS="title2">#UCase(ReplaceNoCase(reportType,"summary"," summary report"))# created on #DateFormat(Now(),"mm/dd/yyyy")# #TimeFormat(Now(),"hh:mm:ss tt")#</SPAN><cfif Len(reportDescription) GT 0><BR><b>(#UCase(reportDescription)#)</b></cfif><BR><BR></CFOUTPUT>
	</cfif>
	<cfif srQuery.recordCount GT 0>
		
		<cfset extraCols=1>
		<!-----<cfset groupByVars="">------->		
		<cfif srNotCSV>
		<cfoutput><TABLE BORDER="0" CELLPADDING="2" CELLSPACING="1" BGCOLOR="999999"><THEAD BGCOLOR="999999"><TR ALIGN=CENTER></cfoutput>
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
						<cfcase value="typegroup">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>#application.returned_customer_setting.type_group_label_singular#</TD></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.type_group_label_singular#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="qbrand">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>#application.returned_customer_setting.q_brand_label_singular#</TD></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.q_brand_label_singular#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="typecode">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>#application.returned_customer_setting.type_code_label_singular#</TD></cfoutput>
							<cfelse>
							<cfoutput>#application.returned_customer_setting.type_code_label_singular#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="brand">
							<cfif srNotCSV>
							<cfoutput><TD ROWSPAN=2>Brand</TD></cfoutput>
							<cfelse>
							<cfoutput>Brand,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="programtype,programnumber,volume,uom,startdate,enddate" delimiters=",">
							<cfset hVal=ListGetAt(productColumnHeaders,ListFindNOCase(productColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TD ROWSPAN=2>#hVal#</TD></cfoutput><cfelse>
							<cfoutput>#hVal#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="programtitle">
							<cfset hVal=ListGetAt(productColumnHeaders,ListFindNOCase(productColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TD ROWSPAN=2 WIDTH="250"><nobr>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#hVal#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</nobr></TD></cfoutput><cfelse>
							<cfoutput>#hVal#,</cfoutput>
							</cfif>
							<cfset extraCols=extraCols+1>
						</cfcase>
						<cfcase value="fiscalvolume,fiscalexpense,marginaverage,fiscalmargin" delimiters=",">
							<cfset hVal=ListGetAt(productColumnHeaders,ListFindNOCase(productColumnHeaderID,i,","),",")>
							<cfif srNotCSV><cfoutput><TD COLSPAN="#Arraylen(rUnits)#">#hVal#</TD><TD ROWSPAN="2"></TD></cfoutput>
							</cfif>
						</cfcase>
					</cfswitch>
					<!-----<cfset groupByVars=ListAppend(groupByVars,"-",",")>------->
			</cfloop>	
		<cfset fixedColCount=extraCols>
		<cfif srNotCSV><cfoutput></TR></cfoutput></cfif>
			<cfif srNotCSV><cfoutput><TR BGCOLOR="ffffff" ALIGN="CENTER"></cfoutput></cfif>
		
			<cfloop index="i" list="#ListAppend(sHeaderIDList,",")#" delimiters=",">
			
				<cfif ListFindNoCase(vProductColumnHeaderID,i,",")>
					<cfset loopCnt=1>
					<cfloop index="i" from="1" to="#Arraylen(rUnits)#">
						<cfset extraCols=extraCols+1>
						<cfif srNotCSV>
						
				<cfoutput><TD>#Replace(rUnits[i].Desc,"Period ","FP")#<br>#Dateformat(Trim(rUnits[i].STARTDATE),"mm/dd/yyyy")#<br>#Dateformat(Trim(rUnits[i].ENDDATE),"mm/dd/yyyy")#</TD></cfoutput>
						<cfelse>	
						<cfset fisName=ListGetAt(vProductColumnHeaders,ListFindNoCase(vProductColumnHeaderID,i,","),",")>					
						
						<!--- <cfoutput>fis = #fisName# FP#loopCnt#,</cfoutput> --->
						<cfoutput>#fisName# #Replace(rUnits[i].Desc, 
Period, FP)#,</cfoutput>
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
				
				
				
				</cfsilent><cfoutput group="#ListGetAt(sNewGroups,thisPos,",")#"><cfif ListLen(sGroupFieldList) GTE thisPos><cfsilent>
				<cfset thisVal=Evaluate(ListGetAt(sNewGroups,thisPos,","))>
				<cfif Trim(thisVal) EQ "">
					<cfset groupPos=ListFindNoCase(sGroupFieldList,ListGetAt(sNewGroups,thisPos,","),",")>
					<cfif groupPos>
						<cfset thisVal="No #ListGetAt(fieldExpansion,ListFindNoCase(fieldShortCut,ListGetAt(sGroupByList,groupPos,","),","),",")# Specified">
					</cfif>
				</cfif>
				</cfsilent><TR VALIGN="TOP" BGCOLOR="ffe4b5"><TD COLSPAN="#Evaluate("#extraCols#-#thisPos#")#"><cfif ListGetAt(sNewGroups,thisPos,",") EQ "Q_Brand">[#Q_Brand_Legacy#] </cfif>#thisVal#&nbsp;</TD></TR></cfif><cfsilent>
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
						<cfset thisVal="No #ListGetAt(fieldExpansion,ListFindNoCase(fieldShortCut,ListGetAt(sGroupByList,groupPos,","),","),",")# Specified">
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
							</cfsilent><cfoutput group="Contract_Number"><cfsilent>
						<!--- 	<cfinclude template="/ReportWriter/schedule/getProductMarginInfo.cfm"> --->
							</cfsilent><TR VALIGN="TOP" BGCOLOR="FFFFFF"><cfif groupColCount GT 0><TD COLSPAN="#groupColCount#"></TD></cfif><cfsilent>
								</cfsilent><cfset c_startdate = #contract_start_date#>
<cfoutput>
<cfset c_enddate = #contract_end_date#></cfoutput>
<cfsilent>
								</cfsilent><cfloop list="#fProductColumnFields#" index="j" delimiters=","><cfsilent>
									<cfset thisVal=Evaluate(ListLast(j,"."))>
									
									<cfif FindNoCase("contract_start_date", j)>
									<cfif IsDate(thisVal)><cfset thisVal=DateFormat(c_startdate,"mm/dd/yyyy")></cfif>
									</cfif>
									<cfif FindNoCase("contract_end_date", j)>
									<cfif IsDate(thisVal)><cfset thisVal=DateFormat(c_enddate,"mm/dd/yyyy")></cfif>
									</cfif>
									</cfsilent>
									<cfif FindNoCase("contract_num", j)>
									<cfset Contract_Num = #thisVal#>
									</cfif>
									<cfif NOT ListFindNoCase(sGroupFieldList,ListLast(j,"."),",")><TD TITLE="#ListGetAt(fProductColumnHeaders,ListFindNoCase(fProductColumnFields,j,","),",")#">#thisVal#  <!--- <cfif NOT ListFindNoCase(sGroupByList,"distributor",",") and NOT ListFindNoCase(sGroupByList,"operator",",")> <cfif FindNoCase("contract_title", j)><cfoutput group="cust_des"><br>#cust_des#</cfoutput></cfif></cfif> ---> </TD></cfif>
</cfloop>
<cfif c_startdate LT now() and c_enddate LT now()>
	<cfset program_status = 1>
<cfelseif c_startdate LTE now() and DateDiff("d", "#c_startdate#", "#now()#") GT 60 and c_enddate GT now()>
	<cfset program_status = 2>
<cfelseif c_startdate LTE now() and DateDiff("d", "#c_startdate#", "#now()#") LT 60 and c_enddate GT now()>
	<cfset program_status = 3>
<cfelseif c_startdate GT #now()# and c_enddate GT #now()#>
	<cfset program_status = 4>
</cfif>
 <!--- if the program start date and end date are in the history --->
<cfif isDefined("dqueryname") and (Generic_Type_Id is 1 or Generic_Type_Id is 5)>
<cfif program_status IS 1>
	<cfquery name="queryInvoices" dbtype="query">
select Price_Invoiced, Invoice_Date
FROM dgetReport 
WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">  AND Invoice_Date >= <cfqueryparam value="#StartDate#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#enddate#" cfsqltype="CF_SQL_DATE">
 <cfif ListFindNoCase(sGroupByList,"qbrand",",")>
AND Q_Brand_id = '#Q_Brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"brand",",")>
AND brand_id = '#brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typecode",",")>
AND Type_Code_Desc_id='#Type_Code_Desc_id#'
</cfif>
</cfquery>
<!--- if the program start date is in the history and end date is in the future and program started 2months before today's date --->
<cfelseif program_status EQ 2>
<cfquery name="queryfInvoices" dbtype="query">
select  SUM(Price_Invoiced) as TotalPrice
FROM dgetReport 
WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR"> AND Invoice_Date >= <cfqueryparam value="#c_startdate#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_DATE">
<cfif ListFindNoCase(sGroupByList,"qbrand",",")>
AND Q_Brand_id = '#Q_Brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"brand",",")>
AND brand_id = '#brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typecode",",")>
AND Type_Code_Desc_id='#Type_Code_Desc_id#'
</cfif>
</cfquery>
<cfquery name="queryInvoices" dbtype="query">
select Price_Invoiced, Invoice_Date
FROM dgetReport 
WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR"> AND Invoice_Date >= <cfqueryparam value="#c_startdate#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_DATE">
<cfif ListFindNoCase(sGroupByList,"qbrand",",")>
AND Q_Brand_id = '#Q_Brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"brand",",")>
AND brand_id = '#brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typecode",",")>
AND Type_Code_Desc_id='#Type_Code_Desc_id#'
</cfif>
</cfquery>

	<cfif queryfInvoices.TotalPrice IS NOT "">
		<cfset PricePerday = queryfInvoices.TotalPrice/(DateDiff("d", "#c_startdate#", "#now()#")+1)>
	<cfelse> 
		<cfset PricePerday = 0>
	</cfif>
	<!--- if the program start date is in the history and end date is in the future and program start date < 2months from today's date --->
<cfelseif program_status IS 3>

<cfquery name="queryfInvoices" dbtype="query">
	select programExpense
	FROM  q_getReport 
	WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" 	cfsqltype="CF_SQL_VARCHAR">
<cfif ListFindNoCase(sGroupByList,"qbrand",",")>
AND Q_Brand_id = '#Q_Brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"brand",",")>
AND brand_id = '#brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typecode",",")>
AND Type_Code_Desc_id='#Type_Code_Desc_id#'
</cfif>
</cfquery>

<cfquery name="queryInvoices" dbtype="query">
select Price_Invoiced, Invoice_Date
FROM dgetReport 
WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR"> AND Invoice_Date >= <cfqueryparam value="#c_startdate#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_DATE">
<cfif ListFindNoCase(sGroupByList,"qbrand",",")>
AND Q_Brand_id = '#Q_Brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"brand",",")>
AND brand_id = '#brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typecode",",")>
AND Type_Code_Desc_id='#Type_Code_Desc_id#'
</cfif>
</cfquery>
	<cfif programExpense IS NOT "">
		<cfset PricePerday = programExpense/(DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
	<cfelse> <cfset PricePerday = 0>
	</cfif> 
<!--- if the program start date and end date are in the future --->
<cfelseif program_status IS 4>
<cfquery name="queryfInvoices" dbtype="query">
	select programExpense
	FROM  q_getReport 
	WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" 	cfsqltype="CF_SQL_VARCHAR">
<cfif ListFindNoCase(sGroupByList,"qbrand",",")>
AND Q_Brand_id = '#Q_Brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"brand",",")>
AND brand_id = '#brand_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"typecode",",")>
AND Type_Code_Desc_id='#Type_Code_Desc_id#'
</cfif>
</cfquery>
	<cfif queryfInvoices.Recordcount GT 0>
	<cfif queryfInvoices.programExpense IS NOT "">
	<cfset programExpense = queryfInvoices.programExpense></cfif>
	</cfif>

	<cfif programExpense IS NOT ""> 
		<cfset PricePerday = programExpense/(DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
	<cfelse> <cfset PricePerday = 0>
	</cfif>
</cfif>


<cfset PriceArray = ArrayNew(1)>
<cfloop index="i" from="1" to="#Arraylen(rUnits)#">
<cfif ListFindNoCase("1,2,3",program_status)>
<cfquery name="subqueryInvoices" dbtype="query">
select SUM(Price_Invoiced) as TotalPrice
FROM queryInvoices 
WHERE
Invoice_Date >= <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE"></cfquery>
</cfif>

<cfif ListFindNoCase("1,2,3",program_status)>
	<cfif subqueryInvoices.RecordCount EQ 0>
		<cfif program_status EQ 2 OR  program_status EQ 3>
		 <cfif (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# and c_startdate GTE #Trim(rUnits[i].STARTDATE)#)>
	<cfif c_startdate LTE  Trim(rUnits[i].STARTDATE) and c_enddate GTE Trim(rUnits[i].ENDDATE)>
		<cfset PriceArray[i] = Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif c_startdate LTE Trim(rUnits[i].STARTDATE) and c_enddate LTE Trim(rUnits[i].ENDDATE)>

			<cfset PriceArray[i] = Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#c_enddate#")+1)>
		</cfif>
		<cfif c_startdate GTE  Trim(rUnits[i].STARTDATE) and c_enddate LTE Trim(rUnits[i].ENDDATE)>
		<cfset PriceArray[i] =Priceperday * (DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
		</cfif>
		<cfif c_startdate GTE  Trim(rUnits[i].STARTDATE) and c_enddate GTE Trim(rUnits[i].ENDDATE)>

		<cfset PriceArray[i] =  Priceperday * (DateDiff("d", "#c_startdate#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 
		<cfelse>
			<cfset PriceArray[i] = "">
		</cfif>
			<cfelse>
			<cfset PriceArray[i] = "">
		</cfif>
	<cfelse>
		<cfif (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# and c_startdate GTE #Trim(rUnits[i].STARTDATE)#)>
		<cfset PriceArray[i] = "#subqueryInvoices.TotalPrice#">
		<cfelse>
			<cfset PriceArray[i] = "">
		</cfif>
	</cfif>
<cfelseif program_status IS 4>
<cfif (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# and c_startdate GTE #Trim(rUnits[i].STARTDATE)#)>
		<cfif c_startdate LTE  Trim(rUnits[i].STARTDATE) and c_enddate GTE Trim(rUnits[i].ENDDATE)>
		<cfset PriceArray[i] = Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif c_startdate LTE Trim(rUnits[i].STARTDATE) and c_enddate LTE Trim(rUnits[i].ENDDATE)>

			<cfset PriceArray[i] = Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#c_enddate#")+1)>
		</cfif>
		<cfif c_startdate GTE  Trim(rUnits[i].STARTDATE) and c_enddate LTE Trim(rUnits[i].ENDDATE)>
		<cfset PriceArray[i] = Priceperday * (DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
		</cfif>
		<cfif c_startdate GTE  Trim(rUnits[i].STARTDATE) and c_enddate GTE Trim(rUnits[i].ENDDATE)>

		<cfset PriceArray[i] =  Priceperday * (DateDiff("d", "#c_startdate#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 
<cfelse>
	<cfset PriceArray[i] = "">
</cfif>
</cfif>
</cfloop>
</cfif>


<!--- billbacks  --->
<cfif isDefined("oqueryname") and (Generic_Type_Id is 2 or Generic_Type_Id is 3 or Generic_Type_Id is 4)>
	<cfif program_status IS 1>
		<cfquery name="queryBillbacks" dbtype="query">
			select PriceperDay,BB_Start_Date,BB_End_Date
			FROM ogetReport 
			WHERE contract_number =  <cfqueryparam value="#Trim(Contract_Num)#" 		cfsqltype="CF_SQL_VARCHAR">
			<cfif ListFindNoCase(sGroupByList,"qbrand",",")>
			AND Q_Brand_id = '#Q_Brand_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"brand",",")>
			AND brand_id = '#brand_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
			AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"typecode",",")>
			AND Type_Code_Desc_id='#Type_Code_Desc_id#'
			</cfif>
		</cfquery>
<cfelseif program_status IS 2>
<cfset TotalBillbackRate = 0>
		<cfquery name="queryBillbacks" dbtype="query">
			select Item_Total_Paid,BB_Start_Date,BB_End_Date,PriceperDay
			FROM ogetReport 
			WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" 		cfsqltype="CF_SQL_VARCHAR">
			<cfif ListFindNoCase(sGroupByList,"qbrand",",")>
			AND Q_Brand_id = '#Q_Brand_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"brand",",")>
			AND brand_id = '#brand_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
			AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"typecode",",")>
			AND Type_Code_Desc_id='#Type_Code_Desc_id#'
			</cfif>
		</cfquery>
		<cfloop query="queryBillbacks">
		<cfif Item_Total_Paid is not "">
			<cfif BB_Start_Date GTE StartDate AND (BB_End_Date LT EndDate AND BB_End_Date GT StartDate)>
			<cfset TotalBillbackRate = TotalBillbackRate + Item_Total_Paid>
			</cfif>
			<cfif BB_Start_Date LT StartDate AND (BB_End_Date LT EndDate AND BB_End_Date GT StartDate)>
			<cfset TotalBillbackRate = TotalBillbackRate + PriceperDay *(DateDiff("d", "#StartDate#", "#BB_End_Date#")+1)>
			</cfif>
		</cfif>
		</cfloop>
<cfset TotalBillbackRate= TotalBillbackRate>
<cfif TotalBillbackRate GT 0>
	<cfif c_startdate GTE StartDate>
		<cfset BillbackRateperday = TotalBillbackRate/(DateDiff("d", "#c_startdate#", "#now()#")+1)>
	<cfelseif c_startdate LT StartDate>
		<cfset BillbackRateperday = TotalBillbackRate/(DateDiff("d", "#StartDate#", "#now()#")+1)>
	</cfif>
<cfelse>
	<cfset BillbackRateperday = 0>
</cfif>
<cfelseif program_status IS 3 or 4>
<cfquery name="queryBillbacks" dbtype="query">
			select BB_Start_Date,BB_End_Date,Priceperday
			FROM ogetReport 
			WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" 		cfsqltype="CF_SQL_VARCHAR">
			<cfif ListFindNoCase(sGroupByList,"qbrand",",")>
			AND Q_Brand_id = '#Q_Brand_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"brand",",")>
			AND brand_id = '#brand_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
			AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"typecode",",")>
			AND Type_Code_Desc_id='#Type_Code_Desc_id#'
			</cfif>
		</cfquery>

<cfquery name="querypBillbacks" dbtype="query">
	select programExpense
	FROM  q_getReport 
	WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" 	cfsqltype="CF_SQL_VARCHAR">
	<cfif ListFindNoCase(sGroupByList,"qbrand",",")>
	AND Q_Brand_id = '#Q_Brand_id#'
	</cfif>
	<cfif ListFindNoCase(sGroupByList,"brand",",")>
	AND brand_id = '#brand_id#'
	</cfif>
	<cfif ListFindNoCase(sGroupByList,"typegroup",",")>
	AND Type_Group_Desc_id = '#Type_Group_Desc_id#'
	</cfif>
	<cfif ListFindNoCase(sGroupByList,"typecode",",")>
	AND Type_Code_Desc_id='#Type_Code_Desc_id#'
	</cfif>
</cfquery>
<cfif querypBillbacks.Recordcount GT 0>
		<cfif querypBillbacks.programExpense IS NOT "">
			<cfset BillBackRate = querypBillbacks.programExpense>
		</cfif>
</cfif>

	<cfif BillBackRate IS NOT 0> 
		<cfset PricePerday = BillBackRate/(DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
	<cfelse> 
		<cfset PricePerday = 0>
	</cfif>
</cfif>

<cfset PriceArray = ArrayNew(1)>
	<cfloop index="i" from="1" to="#Arraylen(rUnits)#">
<cfif program_status IS 1>
<cfset billbackrate = 0>
			<cfquery name="subqueryBillbacks" dbtype="query">
select Priceperday,BB_Start_Date,BB_End_Date
FROM queryBillbacks 
WHERE
((BB_Start_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_End_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_Start_Date <= <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE">) AND (BB_End_Date >= <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">))
</cfquery>
<cfif subqueryBillbacks.Recordcount GT 0>
	<cfloop query="subqueryBillbacks">
	<cfif Priceperday is NOT "">
		<cfif BB_Start_Date LTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif BB_Start_Date LTE Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>

			<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#BB_Start_Date#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>

		<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#BB_Start_Date#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 
	</cfif> 
	</cfloop>
</cfif>
<cfset PriceArray[i] = billbackrate>

<cfelseif program_status IS 2>
<cfset billbackrate = 0>
			<cfquery name="subqueryBillbacks" dbtype="query">
select Priceperday,BB_Start_Date,BB_End_Date
FROM queryBillbacks 
WHERE
((BB_Start_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_End_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_Start_Date <= <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE">) AND (BB_End_Date >= <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">))
</cfquery>
<cfif subqueryBillbacks.Recordcount GT 0>
	<cfloop query="subqueryBillbacks">
	<cfif Priceperday is NOT "">
		<cfif BB_Start_Date LTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif BB_Start_Date LTE Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>

			<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#BB_Start_Date#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>

		<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#BB_Start_Date#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 
	</cfif> 
	</cfloop>
</cfif>
<!--- <cfset VolumeArray[i] = billbackvolume> --->
<cfif (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)#>
<cfif #Trim(rUnits[i].STARTDATE)# GT now()>
	<cfset PriceArray[i] = billbackrateperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
<cfelse>
	<cfset PriceArray[i] = billbackrate>
</cfif>
<cfelse>
	<cfset PriceArray[i] = "">
</cfif>

<cfelseif program_status IS 3>
<cfset billbackrate = 0>
			<cfquery name="subqueryBillbacks" dbtype="query">
select priceperday,BB_Start_Date,BB_End_Date
FROM queryBillbacks 
WHERE
((BB_Start_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_End_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_Start_Date <= <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE">) AND (BB_End_Date >= <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">))
</cfquery>
<cfif subqueryBillbacks.Recordcount GT 0>
	<cfloop query="subqueryBillbacks">
	<cfif Priceperday is NOT "">
		<cfif BB_Start_Date LTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif BB_Start_Date LTE Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>

			<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#BB_Start_Date#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>

		<cfset billbackrate = billbackrate + Priceperday * (DateDiff("d", "#BB_Start_Date#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 
	</cfif> 
	</cfloop>
</cfif>
<!--- <cfset VolumeArray[i] = billbackvolume> --->
<cfif (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)#>
<cfif #Trim(rUnits[i].STARTDATE)# GT now()>
	<cfif c_startdate LTE  Trim(rUnits[i].STARTDATE) and c_enddate GTE Trim(rUnits[i].ENDDATE)>
		<cfset PriceArray[i] = Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif c_startdate LTE Trim(rUnits[i].STARTDATE) and c_enddate LTE Trim(rUnits[i].ENDDATE)>

			<cfset PriceArray[i] = Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#c_enddate#")+1)>
		</cfif>
		<cfif c_startdate GTE  Trim(rUnits[i].STARTDATE) and c_enddate LTE Trim(rUnits[i].ENDDATE)>
		<cfset PriceArray[i] =Priceperday * (DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
		</cfif>
		<cfif c_startdate GTE  Trim(rUnits[i].STARTDATE) and c_enddate GTE Trim(rUnits[i].ENDDATE)>

		<cfset PriceArray[i] =  Priceperday * (DateDiff("d", "#c_startdate#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 
	<!--- <cfset VolumeArray[i] = VolumePerday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)> --->
<cfelse>
	<cfset PriceArray[i] = billbackrate>
</cfif>
<cfelse>
	<cfset PriceArray[i] = "">
</cfif>


<cfelseif program_status IS 4>

<cfif ((c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)#) OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# and c_startdate GTE #Trim(rUnits[i].STARTDATE)#)>
<cfif c_startdate LTE  Trim(rUnits[i].STARTDATE) and c_enddate GTE Trim(rUnits[i].ENDDATE)>
		<cfset PriceArray[i] = Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif c_startdate LTE Trim(rUnits[i].STARTDATE) and c_enddate LTE Trim(rUnits[i].ENDDATE)>

			<cfset PriceArray[i] = Priceperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#c_enddate#")+1)>
		</cfif>
		<cfif c_startdate GTE  Trim(rUnits[i].STARTDATE) and c_enddate LTE Trim(rUnits[i].ENDDATE)>
		<cfset PriceArray[i] =Priceperday * (DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
		</cfif>
		<cfif c_startdate GTE  Trim(rUnits[i].STARTDATE) and c_enddate GTE Trim(rUnits[i].ENDDATE)>

		<cfset PriceArray[i] =  Priceperday * (DateDiff("d", "#c_startdate#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 

		<!--- <cfset VolumeArray[i] = VolumePerday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)> --->
<cfelse>
<cfset PriceArray[i] = "">
</cfif>
</cfif>
</cfloop>
</cfif>

<!--- <cfdump var="#Trim(Contract_Num)#">
<cfdump var="#VolumeArray#"> --->
<cfif isDefined("PriceArray")>
<cfloop index="i" from="1" to="#Arraylen(PriceArray)#">
<TD ALIGN=RIGHT <CFIF PriceArray[i] LT 0> CLASS="negative"</CFIF>>
<cfif PriceArray[i] NEQ "">
#DecimalFormat(PriceArray[i])#</cfif>
</TD></cfloop>
<td BGCOLOR="999999">&nbsp;</td>
<cfset temp = ArraySet(PriceArray, 1,#Arraylen(PriceArray)#, "")>
</cfif> 
</TR><cfsilent>
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
							<cfif Trim(thisVal) EQ "">
								<cfset groupPos=ListFindNoCase(sGroupFieldList,ListGetAt(sNewGroups,thisPos,","),",")>
								<cfif groupPos>
									<cfset thisVal="No #ListGetAt(fieldExpansion,ListFindNoCase(fieldShortCut,ListGetAt(sGroupByList,groupPos,","),","),",")# Specified">
								</cfif>
							<cfelse>
								<cfset thisVal=Trim(thisVal)>
							</cfif>
							</cfsilent><TR VALIGN="TOP"><TD COLSPAN="#Evaluate("#fixedColCount#-1")#"><b>Total for #thisVal#</b></TD><cfsilent>
							</cfsilent><cfloop index="k" list="#sHeaderNameList#" delimiters=","><cfsilent>
								<cfset thisFieldID=ListGetAt(sHeaderIDList,ListFindNoCase(sHeaderNameList,k,","),",")>
								</cfsilent><cfif ListFindNoCase(vProductColumnHeaderID,thisFieldID,",")><cfsilent>
									<cfset vPos=ListFindNoCase(vProductColumnHeaderID,thisFieldID,",")>
									<cfset thisFieldName=ListGetAt(vProductColumnFields,vPos,",")> 
									<cfset thisFieldName=ListLast(thisFieldName,".")>
									</cfsilent><cfset fs_Counter=0><cfoutput group="fyStartDate" maxRows="#Evaluate("#loopCnt#-1")#"><cfset fs_Counter = fs_Counter+1><cfif fs_Counter LTE Evaluate("#loopCnt#-1")><cfsilent>
										</cfsilent><TD ALIGN=RIGHT TITLE="Total #ListGetAt(vProductColumnHeaders,ListFindNoCase(vProductColumnHeaderID,thisFieldID,","),",")# for #thisVal#"><nobr>#Trim(ListGetAt(vProductExtra,vPos,","))##NumberFormat(Evaluate("#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"))#</nobr></TD><cfsilent>
										<cfset "#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"=0>
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
			</cfsilent><cfloop list="#fProductColumnFields#" index="j" delimiters=","><cfsilent>
									<cfset thisVal=Evaluate(ListLast(j,"."))>
									<cfif FindNoCase("date", j)>
									<cfif IsDate(thisVal)><cfset thisVal=DateFormat(thisVal,"mm/dd/yyyy")></cfif>
									</cfif>
									</cfsilent><cfif NOT ListFindNoCase(sGroupFieldList,ListLast(j,"."),",")>#Replace(ReplaceList(thisVal,"#chr(13)#,#chr(10)#"," , "),","," ","All")#,</cfif></cfloop><cfloop index="i" list="#sHeaderIDList#" delimiters=","><cfsilent>
				</cfsilent><cfif ListFindNoCase(vProductColumnHeaderID,i,",")><cfsilent>
					<cfset vPos=ListFindNoCase(vProductColumnHeaderID,i,",")>
					<cfset thisFieldName=ListGetAt(vProductColumnFields,vPos,",")> 
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