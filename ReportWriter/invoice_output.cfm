<cfif srNotCSV>
	<STYLE>
		.td_region_bgcolor
		{
			background-color: #ffe4b5;
		}
		.td_zone_bgcolor
		{
			 background-color: #CCCCCC; 
		}
		.td_customer_bgcolor
		{
			background-color: #ffffff;
		}
	
		.td_region_sum_bgcolor
		{
			background-color: #00FFFF;
		
		}
		.td_zone_sum_bgcolor
		{
			background-color: #FF0000;
		}
	
		TD, body
		{
			font-family : "Arial";
			font-size : 10px;
		}
		TH, .header1{
				font-family : "Arial";
				font-size : 10px;
				font-weight : bold;
			}
	</STYLE>
</cfif>
<cfset invoice_header_title = ArrayNew(1) >
<cfif isDefined("Form.Global_UOM") and Form.Global_UOM EQ 1 >
	<cfset invoice_header_title[1] = "Actual<BR>Cases<BR>Invoiced" >
	<cfset invoice_header_title[2] = "History Cases<BR>Invoiced YAG">
	<cfset invoice_header_title[3] = "Variation<BR>Cases" >
	<cfset invoice_header_title[4] = "Variation<BR>Cases %" >
</cfif>
<cfif isDefined("Form.Global_UOM") and Form.Global_UOM EQ 2 >
	<cfset invoice_header_title[1] = "Actual<BR>Lbs<BR>Invoiced" >
	<cfset invoice_header_title[2] = "History Lbs<BR>Invoiced YAG" >
	<cfset invoice_header_title[3] = "Variation<BR>Lbs." >
	<cfset invoice_header_title[4] = "Variation<BR>Lbs. %" >
</cfif>
<cfif isDefined("Form.Global_UOM") and Form.Global_UOM EQ 3 >
	<cfset invoice_header_title[1] = "Actual<BR>Dollars<BR>Invoiced" >
	<cfset invoice_header_title[2] = "History Dollars<BR>Invoiced YAG" >
	<cfset invoice_header_title[3] = "Variation<BR>Dollars." >
	<cfset invoice_header_title[4] = "Variation<BR>Dollars. %" >
</cfif>
<cfset invoice_timestamp = "#VOL_OUTPUT_PAGE_TITLE# created on " & DateFormat(Now(),"mm/dd/yyyy") & " " & TimeFormat(Now(),"hh:mm:ss tt")>
<cfif srNotCSV is false >
	<cfoutput>#chr(13)##chr(10)#</cfoutput>
	<cfoutput>#invoice_timestamp#</cfoutput>
<cfelse>
	<CFOUTPUT><SPAN CLASS="title2">#invoice_timestamp#</SPAN><BR></CFOUTPUT>
</cfif> 
<cfinclude template="invoice_filter_summary.cfm" >
<BR><BR>
<!--- check if it's empty structure, if so, abort the process--->
<cfif StructIsEmpty(QueryOutputStuct.Two_Fiscal_Year)>
	<strong><BIG>Report is empty!</BIG></strong>
	<cfexit>
</cfif>
<!--- output --->
<cfset topLevelHeaderArray = ArrayNew(1) >
<cfset topLevelColumnSpanArray = ArrayNew(1) >
<cfset colorPaletteArray = ArrayNew(1) >
<cfset HeaderArray = ArrayNew(1) >
<cfset colorPaletteArray[1] = "OldLace" >
<cfset topLevelColumnSpanArray[1] = 3 >
<cfset topLevelHeaderArray[1] = " ">
<cfset HeaderArray[1] = "Zone" >
<cfset HeaderArray[2] = "Region" >
<cfset HeaderArray[3] = "Distributor" >
<cfset headerCount = 4 >
<cfset count = 2 >
<CFLOOP From = "1" To = "#ListLen(form.history_period)#" INDEX = "Counter">
	<cfset currItem = trim(ListGetAt(form.history_period, Counter)) >
	<cfif  currItem EQ "fiscal_period">
		<cfset topLevelHeaderArray[count] = "Current Period">
		<cfset colorPaletteArray[count] = "##FFFFFF" >
	</cfif>
	<cfif  currItem EQ "fiscal_quarter">
		<cfset topLevelHeaderArray[count] = "Current Quarter">
		<cfset colorPaletteArray[count] = "MintCream" >
	</cfif>
	<cfif  currItem EQ "fiscal_year">
		<cfset topLevelHeaderArray[count] = "Current Year">
		<cfset colorPaletteArray[count] = "WhiteSmoke" >
	</cfif>
	<cfset topLevelColumnSpanArray[count] = 4>
	<cfset HeaderArray[headerCount] = invoice_header_title[1] > 
	<cfset HeaderArray[headerCount+1] = invoice_header_title[2] > 
	<cfset HeaderArray[headerCount+2] = invoice_header_title[3] >
	<cfset HeaderArray[headerCount+3] = invoice_header_title[4] >
	<cfset count = count + 1 >
	<cfset headerCount = headerCount + 4 >
</cfloop>
<cfset topLevelHeaderList = ArrayToList(topLevelHeaderArray, ",") >
<cfset topLevelColumnSpanList = ArrayToList(topLevelColumnSpanArray, ",") >
<cfset colorPaletteList = ArrayToList(colorPaletteArray, ",") >
<cfset HeaderList = ArrayToList(HeaderArray, ",") >
<cfif srNotCSV is false>
	<cfset currCount = 1 >
	<cfloop condition="ListFind(HeaderList, invoice_header_title[1], ',') GE 1" >
		<cfset new_title1 = topLevelHeaderArray[currCount+1] & " - " & invoice_header_title[1] >
		<cfset new_title2 = topLevelHeaderArray[currCount+1]& " - " & invoice_header_title[2] >
		<cfset new_title3 = topLevelHeaderArray[currCount+1] & " - " & invoice_header_title[3] >
		<cfset new_title4 = topLevelHeaderArray[currCount+1] & " - " & invoice_header_title[4] >
		<cfset HeaderList = ListSetAt(HeaderList, ListFind(HeaderList,invoice_header_title[1], ","),  #new_title1#) >
		<cfset HeaderList = ListSetAt(HeaderList, ListFind(HeaderList,invoice_header_title[2], ","), # new_title2#) >
		<cfset HeaderList = ListSetAt(HeaderList, ListFind(HeaderList,invoice_header_title[3], ","), # new_title3#) >
		<cfset HeaderList = ListSetAt(HeaderList, ListFind(HeaderList,invoice_header_title[4], ","), # new_title4#) >
		<cfset currCount = currCount + 1 >
	</cfloop> 
	<cfset HeaderList = #Replace(HeaderList, "<BR>"," ","ALL")# >
	<cfoutput>#chr(13)##chr(10)#</cfoutput>
	<cfoutput>#HeaderList#</cfoutput>
	<cfoutput>#chr(13)##chr(10)#</cfoutput>
</cfif>
<!--- <cfdump var = #QueryOutputStuct#> --->
<!--- put the selected date type as the header of the output report --->
<cfif srNotCSV>
	<TABLE CLASS="invoiceOutput" ID="invoiceOutput" CELLPADDING="2" CELLSPACING="0"  BORDER="1">
</cfif>
<cfif srNotCSV>
	<TR> 
		<CFLOOP index="myIndex" from="1" to="#Arraylen(topLevelHeaderArray)#" STEP="1">
			<TD ALIGN="center" COLSPAN="<cfoutput>#topLevelColumnSpanArray[myIndex]#</cfoutput>">

<!--- 			<TD style="background-color:<cfoutput>#colorPaletteArray[myIndex]#</cfoutput>" class="header1" ALIGN="center" COLSPAN="<cfoutput>#topLevelColumnSpanArray[myIndex]#</cfoutput>" NOWRAP> --->


				<strong><cfoutput>#topLevelHeaderArray[myIndex]#</cfoutput></strong>
			</TD>
		</CFLOOP>
	</TR>
</cfif>
<cfif srNotCSV>
	<TR>
		<CFLOOP index="myIndex" from="1" to="#Arraylen(HeaderArray)#" STEP="1">
			<TH NOWRAP>
				<cfoutput>#HeaderArray[myIndex]#</cfoutput>
			</TH>
		</CFLOOP>
	</TR>
</cfif>
<cfset row_count = 0 >
<cfset count = 0>
<cfset zone_flag = 0 >
<cfset region_flag = 0 >
<!--- for zone --->
<cfset zoneArray = ArrayNew(1)>
<cfset zoneArray = StructKeyArray(QueryOutputStuct.Two_Fiscal_Year)>
<cfloop INDEX="i" FROM="1" TO="#ArrayLen(timespanArray)#" STEP="1"> 
	<cfset "#trim(timespanArray[i])#_Struct" = StructNew() >
	<cfscript>
		StructAppend(evaluate(trim(timespanArray[i]) & "_Struct"), evaluate("QueryOutputStuct." & trim(timespanArray[i])));
	</cfscript>
</cfloop>
<cfloop INDEX="myIdx" FROM="1" TO="#ArrayLen(timespanArray)#" STEP="1">
	<cfset zoneLumpSum[timespanArray[myIdx]] = StructNew() >
	<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Pounds_Invoiced'] = StructNew() >
	<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Cases_Invoiced'] = StructNew() >
	<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Sales'] = StructNew() >
	<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Pounds_Invoiced'] = 0 >
	<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Cases_Invoiced'] = 0 >
	<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Sales'] = 0 >
	<cfset regionLumpSum[timespanArray[myIdx]] = StructNew() >
	<cfset regionLumpSum[timespanArray[myIdx]]['Total_Pounds_Invoiced'] = StructNew() >
	<cfset regionLumpSum[timespanArray[myIdx]]['Total_Cases_Invoiced'] = StructNew() >
	<cfset regionLumpSum[timespanArray[myIdx]]['Total_Sales'] = StructNew() >
	<cfset regionLumpSum[timespanArray[myIdx]]['Total_Pounds_Invoiced'] = 0 >
	<cfset regionLumpSum[timespanArray[myIdx]]['Total_Cases_Invoiced'] = 0 >
	<cfset regionLumpSum[timespanArray[myIdx]]['Total_Sales'] = 0 >
</cfloop>
<cfset regionSumOutput = 0 >
<cfset regionSumFlag = 0 >
<cfset zoneSumOutput = 0 >
<cfset zoneSumFlag = 0>
<cfset currZone = 1 >
<cfset currRegion = 1>
<cfloop INDEX="i" FROM="1" TO="#ArrayLen(zoneArray)#" STEP="1">
	<!--- for region --->
	<cfset regionArray = ArrayNew(1)>
	<cfset regionArray = StructKeyArray(QueryOutputStuct.Two_Fiscal_Year[zoneArray[i]])>
	<cfset zone_name = Trim(zoneArray[i]) >
	<cfloop INDEX="j" FROM="1" TO="#ArrayLen(regionArray)#" STEP="1">
		<cfset regionCount = 1>
		<cfset region_name = Trim(regionArray[j]) >
		<!--- for customer --->
		<cfset CustomerArray = ArrayNew(1)>
		<cfset CustomerArray = StructKeyArray(QueryOutputStuct.Two_Fiscal_Year[#zone_name#][#region_name#]) >
		<cfloop INDEX="z" FROM="1" TO="#ArrayLen(CustomerArray)#" STEP="1">
			<cfset customer_name = trim(CustomerArray[z]) >
			<CFIF count GT 0 and count mod 500 EQ 0>
				<cfif srNotCSV>
					</TABLE>
					<BR>
				</cfif>
				<cfif srNotCSV>
					<TABLE CLASS="invoiceOutput" ID="invoiceOutput" CELLPADDING="2" CELLSPACING="0"  BORDER="1"  STYLE="">
				</cfif>
				<cfif srNotCSV>
					<TR>                                 
						<CFLOOP index="myIndex" from="1" to="#Arraylen(topLevelHeaderArray)#" STEP="1">
							<TD style="background-color:<cfoutput>#colorPaletteArray[myIndex]#</cfoutput>" class="td_customer_bgcolor" ALIGN="center" COLSPAN="<cfoutput>#topLevelColumnSpanArray[myIndex]#</cfoutput>" NOWRAP>
							<cfoutput>#topLevelHeaderArray[myIndex]#</cfoutput>								  </TD>
						</CFLOOP>
					</TR>
				</cfif>
				<cfif srNotCSV>
					<TR>
						<CFLOOP index="myIndex" from="1" to="#Arraylen(HeaderArray)#" STEP="1">
							<TH NOWRAP>
								<cfoutput>#HeaderArray[myIndex]#</cfoutput>
							</TH>
						</CFLOOP>
					</TR>	
				</cfif>
			</CFIF>
			<!--- sum up for the zone --->
			<cfif currZone NEQ i>
				<!---- not in the same zone, reset region to 1--->
					<cfset currZone = i >
					<cfset currRegion = 1>
					<cfset regionSumFlag = 1 >
					<cfset zoneSumFlag = 1 >
			<cfelse>
				<cfset zoneSumFlag = 0 >
				<!--- same zone --->
				<!--- check if it's the same region --->
				<cfif currRegion NEQ j>
					<!--- not in the same region --->
					<cfset currRegion = j>
					<cfset regionSumFlag = 1 >
				<cfelse>
					<!--- in the same region --->
					<cfset regionSumFlag = 0 >
				</cfif>
			</cfif>
			<cfif regionSumFlag EQ 1 >
				<cfset region_flag = 1 >
				<cfset regionSumOutput = 1 >
				<CFINCLUDE TEMPLATE="invoice_row_summary.cfm">
				<!--- reset the region sum count --->
				<cfloop INDEX="myIdx" FROM="1" TO="#ArrayLen(timespanArray)#" STEP="1">
					<cfset regionLumpSum[timespanArray[myIdx]]['Total_Pounds_Invoiced'] = 0 >
					<cfset regionLumpSum[timespanArray[myIdx]]['Total_Cases_Invoiced'] = 0 >
					<cfset regionLumpSum[timespanArray[myIdx]]['Total_Sales'] = 0 >
				</cfloop>
				<!--- reset region sum output --->
				<cfset regionSumOutput = 0>
			</cfif>
			<cfif zoneSumFlag EQ 1>
				<cfset zone_flag = 1 >
				<cfset zoneSumOutput = 1 >
				<CFINCLUDE TEMPLATE="invoice_row_summary.cfm">
				<cfloop INDEX="myIdx" FROM="1" TO="#ArrayLen(timespanArray)#" STEP="1">
					<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Pounds_Invoiced'] = 0 >
					<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Cases_Invoiced'] = 0 >
					<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Sales'] = 0 >
				</cfloop>
				<cfset zoneSumOutput = 0 >
			</cfif>
			<CFINCLUDE TEMPLATE="invoice_row_output.cfm">
			<cfset region_flag = 0 >
			<cfset zone_flag = 0 >
			<cfset count = count + 1>
			<!--- keep records for previous zone and region name --->
			<cfset pre_zone_name = zone_name>
			<cfset pre_region_name = region_name >
		</cfloop>
	</cfloop>
</CFLOOP>
<!--- sum up the last zone and region --->
<cfset regionSumFlag = 1 >
<cfset zoneSumFlag = 1 >
<cfif regionSumFlag EQ 1 >
	<cfset regionSumOutput = 1 >
	<CFINCLUDE TEMPLATE="invoice_row_summary.cfm">
	<!--- reset the region sum count --->
	<cfloop INDEX="myIdx" FROM="1" TO="#ArrayLen(timespanArray)#" STEP="1">
		<cfset regionLumpSum[timespanArray[myIdx]]['Total_Pounds_Invoiced'] = 0 >
		<cfset regionLumpSum[timespanArray[myIdx]]['Total_Cases_Invoiced'] = 0 >
		<cfset regionLumpSum[timespanArray[myIdx]]['Total_Sales'] = 0 >
	</cfloop>
	<!--- reset region sum output --->
	<cfset regionSumOutput = 0>
</cfif>
<cfif zoneSumFlag EQ 1>
	<cfset zoneSumOutput = 1 >
	<CFINCLUDE TEMPLATE="invoice_row_summary.cfm">
	<cfloop INDEX="myIdx" FROM="1" TO="#ArrayLen(timespanArray)#" STEP="1">
		<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Pounds_Invoiced'] = 0 >
		<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Cases_Invoiced'] = 0 >
		<cfset zoneLumpSum[timespanArray[myIdx]]['Total_Sales'] = 0 >
	</cfloop>
	<cfset zoneSumOutput = 0 >
</cfif>
<cfif srNotCSV> 
	<!--- table data --->
	</TABLE>
</cfif>