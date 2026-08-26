<cfoutput><tr >
		<td bgcolor="##FFFFFF" colspan="2" >
		</td>
		<td bgcolor="##FFFFFF" colspan="1">&nbsp;</td>
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
		<td bgcolor="##FFFFFF" colspan="2" >
		</td>
		<td bgcolor="##FFFFFF" colspan="1" >&nbsp;</td>
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
		<td bgcolor="##FFFFFF"  nowrap colspan="3">
		<b>#application.returned_customer_setting.operator_label_singular#</b>
		</td>
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