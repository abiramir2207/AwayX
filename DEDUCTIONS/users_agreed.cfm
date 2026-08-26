<cfquery name="getdeductionsuseragreed" datasource="#application.datasource#">
	SELECT 	DISTINCT DD_Agreed_Info.User_Id, Max(DD_Agreed_Info.Created_Date) Agree_DateTime, Name_First, Name_Last
	FROM 	DD_Agreed_Info
	LEFT OUTER JOIN
	_Users 
	ON 
	DD_Agreed_Info.User_ID = _Users.User_ID
	WHERE 	DEDUCTION_ID = '#Deduction_ID#'
	Group By DD_Agreed_Info.User_Id, _Users.Name_First,  _Users.Name_Last
	ORDER BY Agree_DateTime DESC
</CFQUERY>

<cfsilent>
<CFIF getdeductionsuseragreed.recordcount GT 0>
	<cfsavecontent variable="agreed_users">
		<cfoutput query="getdeductionsuseragreed">
		#getdeductionsuseragreed.Name_First# #getdeductionsuseragreed.Name_Last# #Dateformat(getdeductionsuseragreed.Agree_DateTime,"mm/dd/yyyy")# <br/>
		</cfoutput>
	</cfsavecontent>
</cfif>
</cfsilent>