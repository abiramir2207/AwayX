<cfoutput><tr >
		<td bgcolor="##FFFFFF" >
		</td>
		<td bgcolor="##FFFFFF" colspan="2">&nbsp;</td>
		<td colspan="7" bgcolor="##FFFFFF" >
		<p align="center"><b>Measured in <cfswitch expression="#form.thisReportUOM#">
											<!--- case --->
											<cfcase value="1">Cases</cfcase>
											<cfcase value="2">Net Pounds</cfcase>
											<cfcase value="rm">Raw Materials</cfcase>
		</cfswitch></b></td>
		<td bgcolor="##FFFFFF" >&nbsp;</td>
	</tr>
	<tr >
		<td bgcolor="##f0fff0" style="border-top:1px double ##000080;">&nbsp;</td>
		<td bgcolor="##f0fff0" colspan="3" style="border-top:1px double ##000080;">&nbsp;</td>
		<cfif lcase(url.ReportType) EQ "operator-month-item" OR lcase(url.ReportType) EQ "operator-item"> 
			<td colspan="4" bgcolor="##f0fff0" align="center" style="border-left:1px double ##000080; border-top:1px double ##000080;"><b>Use of Commodity</b></th>
			<td COLSPAN="2" bgcolor="##f0fff0" align="center" style="border-left:1px double ##000080; border-top:1px double ##000080; "><b>Balance</b></th>
		<cfelse>
			<td colspan="4" bgcolor="##f0fff0" align="center" style="border-left:1px double ##000080; border-top:1px double ##000080; "><b>Use of Commodity</b></td>
			<td colspan="2" bgcolor="##f0fff0" align="right" style="border-left:1px double ##000080; border-top:1px double ##000080; "><b>Ending</b></td>
		</cfif>
	</tr>
	<tr >
		<td bgcolor="##f0fff0"  nowrap style="border-bottom:1px double ##000080;"><b>Inv. Date</b></td>
		<td bgcolor="##f0fff0"  nowrap style="border-bottom:1px double ##000080;"><b>Item ##</b></td>
		<td bgcolor="##f0fff0" nowrap style="border-bottom:1px double ##000080;"><b>Item Description</b></td>
		<td bgcolor="##f0fff0" nowrap title="pass through value" align="right" style="border-bottom:1px double ##000080;"><b>PTV/Allocation</b></td>
		
		<cfif lcase(url.ReportType) NEQ "item" AND  lcase(url.ReportType) NEQ "operator-item" AND  lcase(url.ReportType) NEQ "operator-month-item">
			<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Beginning</b></td>
			<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Current</b></td>
			<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Cumulative</b></td>
		</cfif>

		<td bgcolor="##f0fff0" nowrap align="right" style="border-left:1px double ##000080; border-bottom:1px double ##000080;"><b>Current</b></td>
		<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Cases</b></td>
		<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Value Used</b></td>
		<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Cumulative</b></td>

		<cfif lcase(url.ReportType) EQ "operator-month-item" OR lcase(url.ReportType) EQ "operator-item"> 
			<td bgcolor="##f0fff0" nowrap align="right" style="border-left:1px double ##000080; border-bottom:1px double ##000080;"><b>Available</b></td>
			<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Avail Value</b></td>
		<cfelse>
			<td bgcolor="##f0fff0" COLSPAN="2" nowrap align="right" style="border-left:1px double ##000080; border-bottom:1px double ##000080;"><b>Balance</b></td>
		</cfif>
	</tr>
	<tr><td COLSPAN="100%">&nbsp;</td></tr>
</cfoutput>