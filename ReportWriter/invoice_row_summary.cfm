<cfif zoneSumOutput EQ 1>  <cfset bgcolor = "##F08080"> </CFIF>
<cfif regionSumOutput EQ 1>  <cfset bgcolor = "##9999CC"> </cfif>
<cfset border_len = 2 >
<TR bordercolor="#FFFFFF">

<cfif regionSumOutput EQ 1 and isDefined("pre_zone_name") >
	<cfif srNotCSV>
		<TD NOWRAP BGCOLOR="White"> </TD>
	<cfelse>
		<cfoutput> ,</cfoutput>
	</cfif>
</cfif>
<cfif zoneSumOutput EQ 1 and isDefined("pre_zone_name")>
	<cfif srNotCSV>
		<TD COLSPAN="3" style="border-top:1px Solid black;" NOWRAP>&nbsp;</TD>
	<cfelse>
		<cfoutput> , , ,</cfoutput>
	</cfif>
</cfif>
<cfif regionSumOutput EQ 1 and isDefined("pre_zone_name") >
	<cfif srNotCSV>
		<TD COLSPAN="2">&nbsp;</TD>
	<cfelse>
		<cfoutput> , ,</cfoutput>
	</cfif>
</cfif>
<!--- 1: period	3: quarter	5: year--->
<CFLOOP INDEX="idx" FROM="1" TO="#ArrayLen(timespanArray)-2#" STEP="2">
	<cfloop index="idx1" FROM="#idx#" TO="#idx+1#" STEP="1">
		<cfif srNotCSV>
			<TD NOWRAP style="border-top:1px Solid black;" align="right"> 
				<cfif regionSumOutput EQ 1>
					<cfif regionLumpSum[timespanArray[Idx1]][#invoice_report_title#] NEQ 0 >
						<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >#NumberFormat(regionLumpSum[timespanArray[Idx1]][invoice_report_title],'_,___,___,___,___')#<cfelse>#DollarFormat(regionLumpSum[timespanArray[Idx1]][invoice_report_title])#</cfif></cfoutput>
					<cfelse>
						0
					</cfif>
				</cfif>
				<cfif zoneSumOutput EQ 1 >
					<cfif zoneLumpSum[timespanArray[Idx1]][#invoice_report_title#] NEQ 0 >
						<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >#NumberFormat(zoneLumpSum[timespanArray[Idx1]][invoice_report_title],'_,___,___,___,___')#<cfelse>#DollarFormat(zoneLumpSum[timespanArray[Idx1]][invoice_report_title])#</cfif></cfoutput>
					<cfelse>
						0
					</cfif>
				</cfif>
			</TD>
		<cfelse>
			<cfif regionSumOutput EQ 1>
				<cfif regionLumpSum[timespanArray[Idx1]][#invoice_report_title#] NEQ 0 >
					<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >"#NumberFormat(regionLumpSum[timespanArray[Idx1]][invoice_report_title],'_,___,___,___,___')#",<cfelse>"#DollarFormat(regionLumpSum[timespanArray[Idx1]][invoice_report_title])#",</cfif></cfoutput>
				<cfelse>
					<cfoutput>0,</cfoutput>
				</cfif>
			</cfif>
			<cfif zoneSumOutput EQ 1 >
				<cfif zoneLumpSum[timespanArray[Idx1]][#invoice_report_title#] NEQ 0 >
					<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >"#NumberFormat(zoneLumpSum[timespanArray[Idx1]][invoice_report_title],'_,___,___,___,___')#",<cfelse>"#DollarFormat(zoneLumpSum[timespanArray[Idx1]][invoice_report_title])#",</cfif></cfoutput>
				<cfelse>
					<cfoutput>0,</cfoutput>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	<cfif regionSumOutput EQ 1>
		<cfset actualVal = regionLumpSum[timespanArray[Idx]][invoice_report_title] >
		<cfset historyVal = regionLumpSum[timespanArray[Idx+1]][invoice_report_title] >
	</cfif>
	<cfif zoneSumOutput EQ 1>
		<cfset actualVal = zoneLumpSum[timespanArray[Idx]][invoice_report_title] >
		<cfset historyVal = zoneLumpSum[timespanArray[Idx+1]][invoice_report_title] >
	</cfif>
	<cfif srNotCSV>
		<TD NOWRAP style="<cfif actualVal LT historyVal>color:#CC0000</cfif>" align="right">
			<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >#NumberFormat(actualVal - historyVal,'_,___,___,___,___')#<cfelse>#DollarFormat(actualVal - historyVal)#</cfif></cfoutput>
		</TD>
	<cfelse>
		<cfoutput><cfif isDefined("Form.Global_UOM") and Form.Global_UOM NEQ 3 >"#NumberFormat(actualVal - historyVal,'_,___,___,___,___')#",<cfelse>"#DollarFormat(actualVal - historyVal)#",</cfif></cfoutput>
	</cfif>
	<cfif srNotCSV>
		<TD NOWRAP style="border-top:1px Solid black;<cfif actualVal LT historyVal and historyVal NEQ 0>color:#CC0000</cfif>" align="right"> 
			<cfif historyVal NEQ 0>
				<cfoutput>#NumberFormat((actualVal - historyVal) / historyVal * 100, '_,___,___,___,___.__')#%</cfoutput>
			<cfelse>
				N/A
			</cfif>
		</TD>
	<cfelse>
		<cfif historyVal NEQ 0>
			<cfoutput>"#NumberFormat((actualVal - historyVal) / historyVal * 100, '_,___,___,___,___.__')#"%,</cfoutput>
		<cfelse>
			<cfoutput>N/A,</cfoutput>
		</cfif>
	</cfif>
</CFLOOP>
</TR>
<cfif srNotCSV is false>
	<cfoutput>#chr(13)##chr(10)#</cfoutput>
</cfif>
<TR bordercolorlight="#008080" style="border-width: thin;"></TR> 
