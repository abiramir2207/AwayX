
<!---
Document Name:	too_old.cfm
Directory:		/help_files/context/billbacks
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	December 19, 2002

Context sensitive help for billbacks 
--->

<html>
<head>
	<title>Days Before a Billback is Considered Too Old</title>
</head>

<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0">

<table width="100%" height="100%" border="0" bgcolor="orange">
<tr><td align="Center" valign="center">

	<table width="99%" height="93%" bgcolor="white" border="0" valign="Center">
	<tr><td>
	<strong>Days Before a Billback is Considered Too Old:</strong><br>
	If a billback is too old, it will automatically be marked as 100% deviated.  For example, if a billback was created three years ago and is being submitted now, and this setting states that after 365 days a billback is considered too old, it will be considered too old. If the field says 900 days, then a 2 year old billback would not be marked as too old, and not be automatically 100% devaited.
<p>
<em>Algorithm:</em><p>
If Today - Billback Day > Days Before a Billback is Considered Too Old <br>
Then the billback will be 100% deviated.
<p>
If Today - Billback Day =< Days Before a Billback is Considered Too Old<br>
No "Too old" deviation
	</td></tr>
	</table>
</td></tr>
</table>

</body>
</html>
