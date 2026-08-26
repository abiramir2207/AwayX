<cfoutput><tr >
		<td bgcolor="##FFFFFF" >
		</td>
		<td bgcolor="##FFFFFF" colspan="2">&nbsp;</td>
		<td colspan="6" bgcolor="##FFFFFF" >
		<p align="center"><b>Measured in <cfswitch expression="#form.thisReportUOM#">
											<!--- case --->
											<cfcase value="1">Cases</cfcase>
											<cfcase value="2">Pounds</cfcase>
											<cfcase value="rm">Raw Materials</cfcase>
		</cfswitch></b></td>
		<td bgcolor="##FFFFFF" >&nbsp;</td>
	</tr>
	<tr  >
		<td bgcolor="##FFFFFF" >
		</td>
		<td bgcolor="##FFFFFF" colspan="2" >&nbsp;</td>
		<td colspan="3" bgcolor="##FFFFFF" >
		<p align="center"><b>Allocation of Commodity</b></td>
		<td colspan="2" bgcolor="##FFFFFF" >
		<p align="center"><b>Use of Commodity</b></td>
		<td bgcolor="##FFFFFF" >
		<b>Ending</b></td>
		<td bgcolor="##FFFFFF" >
		<b>Value</b></td>
	</tr>
	<tr  >
		<td bgcolor="##FFFFFF"  nowrap>
		<b>Item ##</b></td>
		<td bgcolor="##FFFFFF" nowrap>
		<b>Item Description</b></td>
		<td bgcolor="##FFFFFF" nowrap title="pass through value">
		<b>PTV</b></td>
		<td bgcolor="##FFFFFF" nowrap>
		<b>Beginning</b></td>
		<td bgcolor="##FFFFFF" nowrap>
		<b>Current</b></td>
		<td bgcolor="##FFFFFF" nowrap>
		<b>Cumulative</b></td>
		<td bgcolor="##FFFFFF" nowrap>
		<b>Current</b></td>
		<td bgcolor="##FFFFFF" nowrap>
		<b>Cumulative</b></td>
		<td bgcolor="##FFFFFF" nowrap>
		<b>Balance</b></td>
		<td bgcolor="##FFFFFF" nowrap>
		<b>Available</b></td>
	</tr></cfoutput>