<cfoutput>
	<tr>
		<td colspan="100%" bgcolor="##f0fff0" align="center">
			<p align="center"><b>Measured in 
			<cfswitch expression="#form.thisReportUOM#">
											<!--- case --->
											<cfcase value="1">Cases</cfcase>
											<cfcase value="2">Net Pounds</cfcase>
											<cfcase value="rm">Raw Materials</cfcase>
			</cfswitch></b>
		</td>
	</tr>
	<tr  >
		<cfif url.ReportBBDetail EQ 1><td colspan="2" bgcolor="##f0fff0" style="border-top:1px double ##000080;">&nbsp;</td></cfif>
		<td colspan="1" bgcolor="##f0fff0" style="border-top:1px double ##000080;">&nbsp; </td>
		<td bgcolor="##f0fff0"  nowrap colspan="1" align="right" title="Pass Through Value" style="border-top:1px double ##000080;"><b>PTV/ &nbsp;&nbsp;</b></td>
		<td colspan="4" bgcolor="##f0fff0" align="center" style="border-left:1px double ##000080; border-top:1px double ##000080;"><b>Use of Commodity</b></td>
		<td colspan="2" bgcolor="##f0fff0" align="center" style="border-left:1px double ##000080; border-top:1px double ##000080;"><b>Ending</b></td>
		<!--- <td bgcolor="##f0fff0" align="right"><b>Value</b></td> --->
	</tr>
	<tr  >
		<td bgcolor="##f0fff0"  nowrap colspan="1" style="border-bottom:1px double ##000080;"><b>Operator</b></td>
		<cfif url.ReportBBDetail EQ 1>	<!--- Dev Note: KAL; 8453 --->
			<td bgcolor="##f0fff0"  nowrap colspan="1" align="right" style="border-bottom:1px double ##000080;"><b>Inv. Date</b></td>
			<td bgcolor="##f0fff0"  nowrap colspan="1" align="right" style="border-bottom:1px double ##000080;"><b>Item Number</b></td>
		</cfif>
		<td bgcolor="##f0fff0"  nowrap colspan="1" align="right" title="Pass Through Value" style="border-bottom:1px double ##000080;"><b>Total Allocation</b></td>
		<!--- <td bgcolor="##f0fff0"  style="border-bottom:1px double ##000080;">&nbsp; </td> --->
		<td bgcolor="##f0fff0" nowrap align="right" style="border-left:1px double ##000080; border-bottom:1px double ##000080;"><b>Current</b></td>
		<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Cases</b></td>
		<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Value</b></td>
		<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Cumulative</b></td>
		<td bgcolor="##f0fff0" nowrap align="right" style="border-left:1px double ##000080; border-bottom:1px double ##000080;"><b>Balance</b></td>
		<td bgcolor="##f0fff0" nowrap align="right" style="border-bottom:1px double ##000080;"><b>Bal. Value</b></td>
	</tr>
	<tr><td COLSPAN="100%">&nbsp;</td></tr>
	</cfoutput>