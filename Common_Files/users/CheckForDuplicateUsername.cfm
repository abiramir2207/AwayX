<CFQUERY NAME="CheckUsername" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT Name_First
	FROM _Users
	WHERE user_code = '#URL.Username#'
</CFQUERY>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>

<body>


<CFIF CheckUsername.Recordcount EQ 0>
	<SCRIPT>
		parent.validUsername('<CFOUTPUT>#URL.Username#</CFOUTPUT>')
	</SCRIPT>
<CFELSE>
	<CFSET NumberList = "">
	<CFSET StopLoop = 0>
		<CFLOOP CONDITION="StopLoop EQ 0">
			<CFSET temp = RandRange(0, 9)&RandRange(0, 9)>
			<CFIF NOT listfind(NumberList, temp)>
				<CFSET NumberList = ListAppend(NumberList, temp)>
			</CFIF>
			<CFIF listlen(NumberList) EQ 5>
				<CFSET StopLoop = 1>
			</CFIF>		
		</CFLOOP>
	<BR><BR>
	<TABLE ALIGN="center">
		<TR>
			<TD VALIGN="top" STYLE="color: Blue; font-size: 10pt;">Duplicate Username Found. Please Select an alternate username:</TD>
		</TR>
		<TR>
			<TD ALIGN="center">
				<CFLOOP INDEX="number" LIST="#NumberList#">
					<CFSET newUsername = URL.FI&URL.LN&number>
					<CFOUTPUT><INPUT TYPE="radio" NAME="Radio" ONCLICK="parent.validUsername('#newUsername#')">#newUsername#</CFOUTPUT>
				</CFLOOP>
			</TD>
		</TR>
	</TABLE>
</CFIF>


</body>
</html>

