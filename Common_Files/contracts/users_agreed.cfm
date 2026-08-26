<cfquery name="getprogramuseragreed" datasource="#application.datasource#">
	SELECT 	DISTINCT Program_Agree.User_Id, Max(Agree_DateTime) Agree_DateTime, Name_First, Name_Last
	FROM 	Program_Agree
	left join _users on 
	_users.User_Id = Program_Agree.User_Id
	WHERE 	PROGRAMID = #Program_ID#
	and system_agreement = 0
	Group By Program_Agree.User_Id, Name_First, Name_Last
	ORDER BY  Agree_DateTime
</CFQUERY>

<CFIF getprogramuseragreed.recordcount GT 0>
<TABLE width="350">
<TR>
<TD colspan="2" align="center">
<strong>Users who have agreed to this request</strong>
</TR>
<cfoutput query="getprogramuseragreed">
	<TR>
	<TD width="40%" nowrap>
	#Name_First# &nbsp;#Name_Last#
	</TD>
	<TD width="60%" align = "left">	
	#Dateformat(Agree_DateTime,"mm/dd/yyyy")#
	</TD>
	</TR>
</cfoutput>
</TABLE>

</CFIF>


