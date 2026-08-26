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
<cfparam name="VolumePerday" default="0">
<cfparam name="PricePerday" default="0">
<cfparam name="ProgramVolume" default="0">
<cfparam name="ProgramExpense" default="0">
<cfparam name="billbackvolume" type="numeric" default="0">
<cfparam name="totalbillbackvolume" type="numeric" default="0">

 <cfset rUnits = CreateObject("component", "components.futures_pricing.DistributedVolumeFactory").getDatePeriods(2, #Form.Startdate#, #Form.Enddate#, #request.AccessStructure.Company_Main_ID#) />
<!--- <cfloop index="i" from="1" to="#Arraylen(rUnits)#">
<cfoutput>#Dateformat(Trim(rUnits[i].STARTDATE),"mm/dd/yyyy")# -
#Dateformat(Trim(rUnits[i].ENDDATE),"mm/dd/yyyy")#<br></cfoutput>
</cfloop> --->

<cfif isDefined("srqueryname")>
	<cfset srQuery=Evaluate(srqueryname)>	
	
	<cfset programColumnHeaderID=ListAppend(fProgramColumnHeaderID,vProgramColumnHeaderID,",")>
	<cfset programColumnFields=ListAppend(#Replace(fProgramColumnFields, "cm.", "" , "all")#,vProgramColumnFields,",")>	
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
				<!--- <cfif isDefined("srQuery.fyPosition")>
				<CFQUERY dbType="query" name="srFiscalQuery">
				SELECT	distinct fyEndDate, fyStartDate, fyPosition
				FROM 	srQuery
				</cfquery>
				</cfif> --->
			

				<!-----<cfset fiscalCount=srFiscalQuery.recordCount>------->
				
				<cfif ListLen(sGroupByList,",") GT 0>
					<cfset tempArray=ListToArray(sGroupByList,",")>
					<cfset ArraySet(tempArray, 1, ArrayLen(tempArray), "-")>
					<!-----<cfset groupByVars=ArrayToList(tempArray,",")>------->
				</cfif>
				<!--- <cfoutput>#ListAppend(sGroupByList,sHeaderIDList,",")#</cfoutput>
				<cfabort> --->
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
			
				<cfif ListFindNoCase(vProgramColumnHeaderID,i,",")>
					<cfset loopCnt=1>
					<cfloop index="i" from="1" to="#Arraylen(rUnits)#">
						<cfset extraCols=extraCols+1>
						<cfif srNotCSV>
						
				<cfoutput><TD>#Replace(rUnits[i].Desc,"Period ","FP")#<br>#Dateformat(Trim(rUnits[i].STARTDATE),"mm/dd/yyyy")#<br>#Dateformat(Trim(rUnits[i].ENDDATE),"mm/dd/yyyy")#</TD></cfoutput>
						<cfelse>	
						<cfset fisName=ListGetAt(vProgramColumnHeaders,ListFindNoCase(vProgramColumnHeaderID,i,","),",")>					
						
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
		
		<cfflush>
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
			<cfoutput query="q_getReport" group="#ListGetAt(sNewGroups,1,",")#"><cfsilent>
					
				<cfset thisPos=1>			
				<cfif ListLen(sGroupFieldList) GTE thisPos>
					<cfset groupByName=ListGetAt(sGroupFieldList,thisPos,",")>				
					<cfset groupColCount=thisPos>
				<cfelse>
					<cfset groupByName="">
				</cfif>
		<!--- <br><br> #ListGetAt(sNewGroups,1,",")#	
				<cfabort> --->
			
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
							
							
				<cfoutput>#Trim(ListGetAt(sNewGroups,thisPos,","))#	</cfoutput>		
							</cfsilent><cfoutput group="#Trim(ListGetAt(sNewGroups,thisPos,","))#"><cfif Len(groupByName) GT 0><TR VALIGN="TOP" BGCOLOR="fffacd"><cfif thisPos GT 1><TD COLSPAN="#Evaluate("#thisPos#-1")#"></TD></cfif></TD><TD COLSPAN="#Evaluate("#extraCols#-#thisPos#")#">#Evaluate(ListGetAt(sNewGroups,thisPos,","))#&nbsp;</TD></TR></cfif><cfsilent>
				
							<!------------------- End ------------------->
					<cfset counter = 0>
							</cfsilent><cfoutput group="Contract_Number"><TR VALIGN="TOP" BGCOLOR="FFFFFF"><cfif groupColCount GT 0><TD COLSPAN="#groupColCount#"></TD></cfif> 
<cfset c_startdate = #contract_start_date#>
<cfoutput>
<cfset c_enddate = #contract_end_date#></cfoutput>
<cfsilent>

							
								</cfsilent><cfloop list="#fProgramColumnFields#" index="j" delimiters=","><cfsilent>
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
									<cfif NOT ListFindNoCase(sGroupFieldList,ListLast(j,"."),",")><TD TITLE="#ListGetAt(fProgramColumnHeaders,ListFindNoCase(fProgramColumnFields,j,","),",")#">#thisVal#  <cfif NOT ListFindNoCase(sGroupByList,"distributor",",")> <cfif FindNoCase("contract_title", j)><cfoutput group="cust_des"><br>#cust_des#</cfoutput></cfif></cfif> </TD></cfif>
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
select Pounds_Invoiced, Price, Invoice_Date
FROM dgetReport 
WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">  AND Invoice_Date >= <cfqueryparam value="#Form.StartDate#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#Form.enddate#" cfsqltype="CF_SQL_DATE">
 <cfif ListFindNoCase(sGroupByList,"family",",")>
AND family_id = '#family_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"buyinggroup",",")>
AND buying_id = '#buying_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"distributor",",")>
AND customer_id='#customer_id#'
</cfif>
</cfquery>
<!--- if the program start date is in the history and end date is in the future and program started 2months before today's date --->
<cfelseif program_status IS 2>
		<cfquery name="queryfInvoices" dbtype="query">
select SUM(Pounds_Invoiced) as TotalVolume, SUM(Price) as TotalPrice
FROM dgetReport 
WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR"> AND Invoice_Date >= <cfqueryparam value="#c_startdate#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_DATE">
<cfif ListFindNoCase(sGroupByList,"family",",")>
AND family_id = '#family_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"buyinggroup",",")>
AND buying_id = '#buying_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"distributor",",")>
AND customer_id='#customer_id#'
</cfif>
</cfquery>
<cfquery name="queryInvoices" dbtype="query">
select Pounds_Invoiced, Price, Invoice_Date
FROM dgetReport 
WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR"> AND Invoice_Date >= <cfqueryparam value="#c_startdate#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_DATE">
<cfif ListFindNoCase(sGroupByList,"family",",")>
AND family_id = '#family_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"buyinggroup",",")>
AND buying_id = '#buying_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"distributor",",")>
AND customer_id='#customer_id#'
</cfif>
</cfquery>
	<cfif queryfInvoices.TotalVolume IS NOT "">
		<cfset VolumePerday = queryfInvoices.TotalVolume/(DateDiff("d", "#c_startdate#", "#now()#")+1)>
	<cfelse> 
		<cfset VolumePerday = 0>
	</cfif>
	<cfif queryfInvoices.TotalPrice IS NOT "">
		<cfset PricePerday = queryfInvoices.TotalPrice/(DateDiff("d", "#c_startdate#", "#now()#")+1)>
	<cfelse> 
		<cfset PricePerday = 0>
	</cfif>
	
	<!--- if the program start date is in the history and end date is in the future and program start date < 2months from today's date --->
<cfelseif program_status IS 3>

<cfif ListFindNoCase(sGroupByList,"distributor",",")>
<cfquery name="queryfInvoices" dbtype="query">
	select (programVolume * Program_Weight) as programVolume, (programExpense * 				Program_Weight) as programExpense
	FROM  q_getReport 
	WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" 	cfsqltype="CF_SQL_VARCHAR">
	AND customer_id = '#customer_id#'
</cfquery>
<cfif queryfInvoices.Recordcount GT 0>
<cfif queryfInvoices.programVolume IS NOT "">
<cfset programVolume = queryfInvoices.programVolume></cfif>
<cfif queryfInvoices.programExpense IS NOT "">
<cfset programExpense = queryfInvoices.programExpense></cfif></cfif>

<cfelseif ListFindNoCase(sGroupByList,"family",",")>
<cfquery name="queryfInvoices" dbtype="query">
select programExpense, programVolume,program_fweight
from q_getReport
where contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">
and family_id = '#family_id#'
</cfquery>
<cfif queryfInvoices.Recordcount GT 0>
<cfif queryfInvoices.programVolume IS NOT "">
<cfset programVolume = queryfInvoices.programVolume * program_fweight></cfif>
<cfif queryfInvoices.programExpense IS NOT "">
<cfset programExpense = queryfInvoices.programExpense * program_fweight></cfif></cfif>
<cfelseif ListFindNoCase(sGroupByList,"buyinggroup",",")>
<cfquery name="queryfInvoices" dbtype="query">
select programExpense, programVolume, program_bweight
from q_getReport
where contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">
and buying_id = '#buying_id#'
</cfquery>
<cfif queryfInvoices.Recordcount GT 0>
<cfif queryfInvoices.programVolume IS NOT "">
<cfset programVolume = queryfInvoices.programVolume * program_bweight></cfif>
<cfif queryfInvoices.programExpense IS NOT "">
<cfset programExpense = queryfInvoices.programExpense * program_bweight></cfif></cfif>
<cfelse>
<cfquery name="queryfInvoices" dbtype="query">
	select programExpense, programVolume
	FROM q_getReport 
	WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>
<cfif queryfInvoices.Recordcount GT 0>
<cfif queryfInvoices.programVolume IS NOT "">
<cfset programVolume = queryfInvoices.programVolume></cfif>
<cfif queryfInvoices.programExpense IS NOT "">
<cfset programExpense = queryfInvoices.programExpense></cfif></cfif>
</cfif>

<cfquery name="queryInvoices" dbtype="query">
select Pounds_Invoiced, Price, Invoice_Date
FROM dgetReport 
WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR"> AND Invoice_Date >= <cfqueryparam value="#c_startdate#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#Now()#" cfsqltype="CF_SQL_DATE">
<cfif ListFindNoCase(sGroupByList,"family",",")>
AND family_id = '#family_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"buyinggroup",",")>
AND buying_id = '#buying_id#'
</cfif>
<cfif ListFindNoCase(sGroupByList,"distributor",",")>
AND customer_id='#customer_id#'
</cfif>
</cfquery>

	 <cfif programVolume IS NOT ""> 
		<cfset VolumePerday = programVolume/(DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
	<cfelse> 
		<cfset VolumePerday = 0>
	</cfif>
	<cfif programExpense IS NOT "">
		<cfset PricePerday = programExpense/(DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
	<cfelse> <cfset PricePerday = 0>
	</cfif> 
<!--- if the program start date and end date are in the future --->
<cfelseif program_status IS 4>

<cfif ListFindNoCase(sGroupByList,"distributor",",")>
<cfquery name="queryfInvoices" dbtype="query">
	select (programVolume * Program_Weight) as programVolume, (programExpense * 				Program_Weight) as programExpense
	FROM  q_getReport 
	WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" 	cfsqltype="CF_SQL_VARCHAR">
	AND customer_id = '#customer_id#'
</cfquery>
<cfif queryfInvoices.Recordcount GT 0>
<cfif queryfInvoices.programVolume IS NOT "">
<cfset programVolume = queryfInvoices.programVolume></cfif>
<cfif queryfInvoices.programExpense IS NOT "">
<cfset programExpense = queryfInvoices.programExpense></cfif></cfif>

<cfelseif ListFindNoCase(sGroupByList,"family",",")>
<cfquery name="queryfInvoices" dbtype="query">
select programExpense, programVolume,program_fweight
from q_getReport
where contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">
and family_id = '#family_id#'
</cfquery>
<cfif queryfInvoices.Recordcount GT 0>
<cfif queryfInvoices.programVolume IS NOT "">
<cfset programVolume = queryfInvoices.programVolume * program_fweight></cfif>
<cfif queryfInvoices.programExpense IS NOT "">
<cfset programExpense = queryfInvoices.programExpense * program_fweight></cfif>
</cfif>
<cfelseif ListFindNoCase(sGroupByList,"buyinggroup",",")>
<cfquery name="queryfInvoices" dbtype="query">
select programExpense, programVolume,program_bweight
from q_getReport
where contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">
and buying_id = '#buying_id#'
</cfquery>
	<cfif queryfInvoices.Recordcount GT 0>
	<cfif queryfInvoices.programVolume IS NOT "">
	<cfset programVolume = queryfInvoices.programVolume * program_bweight></cfif>
	<cfif queryfInvoices.programExpense IS NOT "">
	<cfset programExpense = queryfInvoices.programExpense * program_bweight></cfif>
	</cfif>
<cfelse>
<cfquery name="queryfInvoices" dbtype="query">
	select programExpense, programVolume
	FROM q_getReport 
	WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>
	<cfif queryfInvoices.Recordcount GT 0>
	<cfif queryfInvoices.programVolume IS NOT "">
	<cfset programVolume = queryfInvoices.programVolume></cfif>
	<cfif queryfInvoices.programExpense IS NOT "">
	<cfset programExpense = queryfInvoices.programExpense></cfif>
	</cfif>
</cfif>

	<cfif programVolume IS NOT ""> 
		<cfset VolumePerday = programVolume/(DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
	<cfelse> 
		<cfset VolumePerday = 0>
	</cfif>
	<cfif programExpense IS NOT ""> 
		<cfset PricePerday = programExpense/(DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
	<cfelse> <cfset PricePerday = 0>
	</cfif>
</cfif>





 <!--- #program_status# - #contract_num#  --->
<cfset VolumeArray = ArrayNew(1)>
<cfset PriceArray = ArrayNew(1)>
<cfloop index="i" from="1" to="#Arraylen(rUnits)#">
<!--- <cfif program_status IS 1 OR 2 OR 3> --->
<cfif ListFindNoCase("1,2,3",program_status)>
<cfquery name="subqueryInvoices" dbtype="query">
select SUM(Pounds_Invoiced) as TotalVolume, SUM(Price) as TotalPrice
FROM queryInvoices 
WHERE
Invoice_Date >= <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND Invoice_Date <= <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE"></cfquery>
</cfif>

<cfif ListFindNoCase("1,2,3",program_status)>
	<cfif subqueryInvoices.RecordCount EQ 0>
		<cfif program_status EQ 2 AND (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)# OR 3 AND (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)#>
			<cfset VolumeArray[i] = VolumePerday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
			<cfset PriceArray[i] = PricePerday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		<cfelse>
			<cfset VolumeArray[i] = "">
			<cfset PriceArray[i] = "">
		</cfif>
	<cfelse>
		<cfset VolumeArray[i] = "#subqueryInvoices.TotalVolume#">
		<cfset PriceArray[i] = "#subqueryInvoices.TotalPrice#">
	</cfif>
<cfelseif program_status IS 4 AND (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)#>
		<cfset VolumeArray[i] = VolumePerday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		<cfset PriceArray[i] = PricePerday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
<cfelse>
	<cfset VolumeArray[i] = "">
	<cfset PriceArray[i] = "">
</cfif>
</cfloop>
</cfif>


<!--- billbacks  --->
<cfif isDefined("oqueryname") and (Generic_Type_Id is 2 or Generic_Type_Id is 3 or Generic_Type_Id is 4)>
	<cfif program_status IS 1>
		<cfquery name="queryBillbacks" dbtype="query">
			select Volumeperday,BB_Start_Date,BB_End_Date
			FROM ogetReport 
			WHERE contract_number =  <cfqueryparam value="#Trim(Contract_Num)#" 		cfsqltype="CF_SQL_VARCHAR">
			<cfif ListFindNoCase(sGroupByList,"distributor",",")>
				AND customer_id='#customer_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"family",",")>
				AND family_id = '#family_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"buyinggroup",",")>
				AND buying_id = '#buying_id#'
			</cfif>
		</cfquery>
<cfelseif program_status IS 2>
<cfset TotalBillbackVolume = 0>
		<cfquery name="queryBillbacks" dbtype="query">
			select Item_Volume_Approved_LB,BB_Start_Date,BB_End_Date,Volumeperday
			FROM ogetReport 
			WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" 		cfsqltype="CF_SQL_VARCHAR">
			<cfif ListFindNoCase(sGroupByList,"distributor",",")>
				AND customer_id='#customer_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"family",",")>
				AND family_id = '#family_id#'
			</cfif>
			<cfif ListFindNoCase(sGroupByList,"buyinggroup",",")>
				AND buying_id = '#buying_id#'
			</cfif>
		</cfquery>
		<cfloop query="queryBillbacks">
		<cfif Item_Volume_Approved_LB is not "">
			<cfif BB_Start_Date GTE Form.StartDate AND (BB_End_Date LT Form.EndDate AND BB_End_Date GT Form.StartDate)>
			<cfset TotalBillbackVolume = TotalBillbackVolume + Item_Volume_Approved_LB>
			</cfif>
			<cfif BB_Start_Date LT Form.StartDate AND (BB_End_Date LT Form.EndDate AND BB_End_Date GT Form.StartDate)>
			<cfset TotalBillbackVolume = TotalBillbackVolume + Volumeperday *(DateDiff("d", "#Form.StartDate#", "#BB_End_Date#")+1)>
			</cfif>
		</cfif>
		</cfloop>
<cfset totalbillbackVolume= TotalBillbackVolume>
<cfif TotalBillbackVolume GT 0>
	<cfif c_startdate GTE Form.StartDate>
		<cfset BillbackVolumeperday = TotalBillbackVolume/(DateDiff("d", "#c_startdate#", "#now()#")+1)>
	<cfelseif c_startdate LT Form.StartDate>
		<cfset BillbackVolumeperday = TotalBillbackVolume/(DateDiff("d", "#Form.StartDate#", "#now()#")+1)>
	</cfif>
<cfelse>
	<cfset BillbackVolumeperday = 0>
</cfif>
<cfelseif program_status IS 3 or 4>
<cfif ListFindNoCase(sGroupByList,"distributor",",")>
<cfquery name="queryBillbacks" dbtype="query">
	select (programVolume * Program_Weight) as programVolume, (programExpense * 				Program_Weight) as programExpense
	FROM  q_getReport 
	WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" 	cfsqltype="CF_SQL_VARCHAR">
	AND customer_id = '#customer_id#'
</cfquery>
<cfif queryBillbacks.Recordcount GT 0>
		<cfif queryBillbacks.programVolume IS NOT "">
			<cfset BillBackVolume = queryBillbacks.programVolume>
		</cfif>
</cfif>
<cfelseif ListFindNoCase(sGroupByList,"family",",")>
<cfquery name="queryBillbacks" dbtype="query">
select programExpense, programVolume,program_fweight
from q_getReport
where contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">
and family_id = '#family_id#'
</cfquery>
<cfif queryBillbacks.Recordcount GT 0>
	<cfif queryBillbacks.programVolume IS NOT "">
		<cfset BillBackVolume = queryBillbacks.programVolume * program_fweight>
	</cfif>
</cfif>

<cfelseif ListFindNoCase(sGroupByList,"buyinggroup",",")>
<cfquery name="queryBillbacks" dbtype="query">
select programExpense, programVolume,program_bweight
from q_getReport
where contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">
and buying_id = '#buying_id#'
</cfquery>
	<cfif queryBillbacks.Recordcount GT 0>
		<cfif queryBillbacks.programVolume IS NOT "">
			<cfset BillBackVolume = queryBillbacks.programVolume * program_bweight>
		</cfif>
	</cfif>
<cfelse>
<cfquery name="queryBillbacks" dbtype="query">
	select programExpense, programVolume
	FROM q_getReport 
	WHERE contract_number = <cfqueryparam value="#Trim(Contract_Num)#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>
	<cfif queryBillbacks.Recordcount GT 0>
		<cfif queryBillbacks.programVolume IS NOT "">
		<cfset BillBackVolume = queryBillbacks.programVolume>
		</cfif>
	</cfif>
</cfif>
	<cfif BillBackVolume IS NOT 0> 
		<cfset VolumePerday = BillBackVolume/(DateDiff("d", "#c_startdate#", "#c_enddate#")+1)>
	<cfelse> 
		<cfset VolumePerday = 0>
	</cfif>
</cfif>


<cfset VolumeArray = ArrayNew(1)>
	<cfloop index="i" from="1" to="#Arraylen(rUnits)#">
<cfif program_status IS 1>
<cfset billbackvolume = 0>
			<cfquery name="subqueryBillbacks" dbtype="query">
select Volumeperday,BB_Start_Date,BB_End_Date
FROM queryBillbacks 
WHERE
((BB_Start_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_End_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_Start_Date <= <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE">) AND (BB_End_Date >= <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">))
</cfquery>
<cfif subqueryBillbacks.Recordcount GT 0>
	<cfloop query="subqueryBillbacks">
	<cfif Volumeperday is NOT "">
		<cfif BB_Start_Date LTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif BB_Start_Date LTE Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>

			<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#BB_Start_Date#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>

		<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#BB_Start_Date#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 
	</cfif> 
	</cfloop>
</cfif>
<cfset VolumeArray[i] = billbackvolume>

<cfelseif program_status IS 2>
<cfset billbackvolume = 0>
			<cfquery name="subqueryBillbacks" dbtype="query">
select Volumeperday,BB_Start_Date,BB_End_Date
FROM queryBillbacks 
WHERE
((BB_Start_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_End_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_Start_Date <= <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE">) AND (BB_End_Date >= <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">))
</cfquery>
<cfif subqueryBillbacks.Recordcount GT 0>
	<cfloop query="subqueryBillbacks">
	<cfif Volumeperday is NOT "">
		<cfif BB_Start_Date LTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif BB_Start_Date LTE Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>

			<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#BB_Start_Date#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>

		<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#BB_Start_Date#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 
	</cfif> 
	</cfloop>
</cfif>
<!--- <cfset VolumeArray[i] = billbackvolume> --->
<cfif (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)#>
<cfif #Trim(rUnits[i].STARTDATE)# GT now()>
	<cfset VolumeArray[i] = billbackvolumeperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
<cfelse>
	<cfset VolumeArray[i] = billbackvolume>
</cfif>
<cfelse>
	<cfset VolumeArray[i] = "">
</cfif>

<cfelseif program_status IS 3>
<cfset billbackvolume = 0>
			<cfquery name="subqueryBillbacks" dbtype="query">
select Volumeperday,BB_Start_Date,BB_End_Date
FROM queryBillbacks 
WHERE
((BB_Start_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_End_Date BETWEEN <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE"> AND <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">) OR
  (BB_Start_Date <= <cfqueryparam value="#Trim(rUnits[i].STARTDATE)#" cfsqltype="CF_SQL_DATE">) AND (BB_End_Date >= <cfqueryparam value="#Trim(rUnits[i].ENDDATE)#" cfsqltype="CF_SQL_DATE">))
</cfquery>
<cfif subqueryBillbacks.Recordcount GT 0>
	<cfloop query="subqueryBillbacks">
	<cfif Volumeperday is NOT "">
		<cfif BB_Start_Date LTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif>
		<cfif BB_Start_Date LTE Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>

			<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date LTE Trim(rUnits[i].ENDDATE)>
		<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#BB_Start_Date#", "#BB_End_Date#")+1)>
		</cfif>
		<cfif BB_Start_Date GTE  Trim(rUnits[i].STARTDATE) and BB_End_Date GTE Trim(rUnits[i].ENDDATE)>

		<cfset billbackvolume = billbackvolume + Volumeperday * (DateDiff("d", "#BB_Start_Date#", "#Trim(rUnits[i].ENDDATE)#")+1)>
		</cfif> 
	</cfif> 
	</cfloop>
</cfif>
<!--- <cfset VolumeArray[i] = billbackvolume> --->
<cfif (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)#>
<cfif #Trim(rUnits[i].STARTDATE)# GT now()>
	<cfset VolumeArray[i] = VolumePerday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
<cfelse>
	<cfset VolumeArray[i] = billbackvolume>
</cfif>
<cfelse>
	<cfset VolumeArray[i] = "">
</cfif>


<cfelseif program_status IS 4 AND (c_enddate GTE #Trim(rUnits[i].ENDDATE)# OR (c_enddate LTE #Trim(rUnits[i].ENDDATE)# AND c_enddate GTE #Trim(rUnits[i].STARTDATE)#)) AND c_startdate LTE #Trim(rUnits[i].STARTDATE)#>
		<cfset VolumeArray[i] = VolumePerday * (DateDiff("d", "#Trim(rUnits[i].STARTDATE)#", "#Trim(rUnits[i].ENDDATE)#")+1)>
</cfif>
</cfloop>
</cfif>
 <!--- #program_status# - #contract_num# --->
<cfloop index="i" from="1" to="#Arraylen(VolumeArray)#">
<TD ALIGN=RIGHT>
#DecimalFormat(VolumeArray[i])#
</TD></cfloop>
<td BGCOLOR="999999">&nbsp;</td>
<!--- <cfloop index="k" from="1" to="#Arraylen(PriceArray)#">
<TD ALIGN=RIGHT>
#DecimalFormat(PriceArray[k])#
</TD>
</cfloop> --->
<cfflush>
	</cfoutput><cfsilent><cfset thisPos=4>
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
									</cfsilent><cfset fs_Counter=0><cfoutput group="fyStartDate" maxRows="#Evaluate("#loopCnt#-1")#"><cfset fs_Counter = fs_Counter+1><cfif fs_Counter LTE Evaluate("#loopCnt#-1")><cfsilent>
										</cfsilent><TD ALIGN=RIGHT TITLE="Total #ListGetAt(vProgramColumnHeaders,ListFindNoCase(vProgramColumnHeaderID,thisFieldID,","),",")# for #thisVal#"><nobr>#Trim(ListGetAt(vProgramExtra,vPos,","))##NumberFormat(Evaluate("#thisFieldName##Month(fyStartDate)##Day(fyStartDate)##Year(fyStartDate)#"))#</nobr></TD><cfsilent>
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
