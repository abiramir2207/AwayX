
<cfoutput>
<cfparam name="form.Final_BB_total_BeginningVolume" default="0">
<cfparam name="form.Final_BB_total_Current_1" default="0">
<cfparam name="form.Final_BB_total_Current_2" default="0">
<cfparam name="form.Final_BB_total_Cumulative_2" default="0">
<cfparam name="form.Final_BB_total_Ending_Balance" default="0">
<cfparam name="form.Final_BB_total_Value_Available" default="0">

<cfset UOMString = "&nbsp;cs">

<cfif form.thisReportUOM EQ "rm">
<cfset UOMString = "&nbsp;lbs">
</cfif>


<cfif form.thisReportUOM EQ "1">
	<cfset UOMString = "&nbsp;cs">
</cfif>

<cfif form.thisReportUOM EQ "2">
	<cfset UOMString = "&nbsp;lbs">
</cfif>

<tr bgcolor="##f0f8ff">
	<td colspan="3" align="right"  style="border-top: 1 solid Black;"><b>TOTAL:</b></td>
	<td align="right" style="border-top: 1 solid Black;"><b>#trim(NumberFormat(form.Final_BB_total_BeginningVolume, '__,__,__,__'))##UOMString#</b></td>
	<td align="right" style="border-top: 1 solid Black;"><b>#trim(NumberFormat(form.Final_BB_total_Current_1, '__,__,__,__'))##UOMString#</b></td>
	<td align="right" style="border-top: 1 solid Black;"><b>#trim(NumberFormat(form.Final_BB_total_BeginningVolume, '__,__,__,__'))##UOMString#</b></td>
	<td align="right" style="border-top: 1 solid Black;"><b>#trim(NumberFormat(form.Final_BB_total_Current_2, '__,__,__,__'))##UOMString#</b></td>
	<td align="right" style="border-top: 1 solid Black;"><b>#trim(NumberFormat(form.Final_BB_total_Cumulative_2, '__,__,__,__'))##UOMString#</b></td>
	<td align="right" style="border-top: 1 solid Black;"><b>#trim(NumberFormat(form.Final_BB_total_Ending_Balance, '__,__,__,__'))##UOMString#</b></td>
	<td align="right" style="border-top: 1 solid Black;"><b>$#trim(NumberFormat(form.Final_BB_total_Value_Available, '__,__,__,__.__'))#</b></td>
</tr>
</cfoutput>