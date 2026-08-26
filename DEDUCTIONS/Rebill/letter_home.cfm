<html>
<body TOPMARGIN="0">

<font size="2"><strong>Create a new rebill letter</strong></font><p></p>

<cfoutput><font color="Red"><Strong>[</font>&nbsp; <a href="compile_letter.cfm?Deduction_ID=#Deduction_ID#">Create Letter</a>&nbsp; <font color="Red">]</STRONG></font>
</cfoutput>
<p></p>
<font size="2"><strong>Prior Rebill Letters</strong></font>

<cfquery name="GetExistingRebillLetters" datasource="#application.datasource#">
SELECT DD_Rebill_Log_ID, File_Location, Created_Date, Name_First, Name_Last FROM DD_Rebill_Log
	INNER JOIN _Users
	ON _Users.User_ID = DD_Rebill_Log.Created_By
WHERE Deduction_ID = '#Deduction_ID#'
</cfquery>

<cfif GetExistingRebillLetters.Recordcount GT 0>
<table>
<tr><td><strong>Created By</strong></td><td><strong>Created On</strong></td><Td>&nbsp; </TD> </tr>
	<cfoutput query="GetExistingRebillLetters">
	<tr><td>#Name_First# #Name_Last#</td><td>#dateformat(Created_Date, 'MM/DD/YYYY')#</td><td><font color="Red"><Strong>[</font>&nbsp; <A href="view_letter.cfm?Deduction_ID=#Deduction_ID#&DD_Rebill_Log_ID=#DD_Rebill_Log_ID#">view</A>&nbsp; <font color="Red">]</STRONG></font></td></tr>
	</cfoutput>
</table>
<cfelse>
There are no prior rebill letters for this deduction.
</cfif>


</body></html>