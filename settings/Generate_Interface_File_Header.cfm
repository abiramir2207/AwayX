<!------ Generate_Interface_File_Header.cfm ----->
<table bgcolor="cccccc" cellpadding="2" cellspacing="2" width="90%" align="center">
<colgroup>
<col span="4" width="25%">
</colgroup>
<tr>
<td bgcolor="ffffff"><a href="Generate_Interface_File.cfm"><B>4354 - Extract File</B></a></td>
<td bgcolor="ffffff"><a href="Generate_Interface_File_Feedback_File.cfm"><B>4354 - Load feedback file</B></a></td>
<td bgcolor="ffffff"><a href="Generate_Interface_4354_Change_File.cfm"><B>4602 - Extract  File</B></a></td>
<td bgcolor="ffffff"><a href="Generate_Interface_Change_File_Feedback_File.cfm"><B>4602 - Load feedback file</B></a></td>
</tr>
</table>

<br>
<cfswitch expression="#CGI.SCRIPT_NAME#">
<cfcase value="/settings/Generate_Interface_File.cfm"><B>4354 - Extract File</B></cfcase>
<cfcase value="/settings/Generate_Interface_File_Feedback_File.cfm"><B>4354 - Load feedback file</B></cfcase>
<cfcase value="/settings/Generate_Interface_4354_Change_File.cfm"><B>4602 - Extract  File</B></cfcase>
<cfcase value="/settings/Generate_Interface_Change_File_Feedback_File.cfm"><B>4602 - Load feedback file</B></cfcase>
</cfswitch>
<hr color="orange">