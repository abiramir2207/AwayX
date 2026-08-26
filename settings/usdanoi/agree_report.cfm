<cfquery name="AllAgreement" datasource="#application.datasource#">
SELECT USDA_Agreement.User_Agrees, USDA_Agreement.Notes, USDA_Agreement.DateTimeStamp, Contract_Main.Contract_Title, Contract_Main.Contract_Number,  BSA_Operator.Operator_Name, BSA_Operator.Operator_Address, BSA_Operator.Operator_City, BSA_Operator.Operator_State, BSA_Operator.Operator_Zip, _Users.Name_First, _Users.Name_Last, datepart(month, DateTimeStamp) AS Month_No,
CASE 	WHEN datepart(month, DateTimeStamp) = 1 THEN 'January'
	WHEN datepart(month, DateTimeStamp) = 2 THEN 'February'
	WHEN datepart(month, DateTimeStamp) = 3 THEN 'March'
	WHEN datepart(month, DateTimeStamp) = 4 THEN 'April'
	WHEN datepart(month, DateTimeStamp) = 5 THEN 'May'
	WHEN datepart(month, DateTimeStamp) = 6 THEN 'June'
	WHEN datepart(month, DateTimeStamp) = 7 THEN 'July'
	WHEN datepart(month, DateTimeStamp) = 8 THEN 'August'
	WHEN datepart(month, DateTimeStamp) = 9 THEN 'September'
	WHEN datepart(month, DateTimeStamp) = 10 THEN 'October'
	WHEN datepart(month, DateTimeStamp) = 11 THEN 'November'
	WHEN datepart(month, DateTimeStamp) = 12 THEN 'December'
END AS Month_Desc
FROM USDA_Agreement
	INNER JOIN BSA_Operator
	ON BSA_Operator.BSA_Operator_ID = USDA_Agreement.Operator_ID
	INNER JOIN _Users
	ON _Users.User_ID = USDA_Agreement.User_ID
	INNER JOIN Contract_Operators
	ON Contract_Operators.BSA_Operator_ID = BSA_Operator.BSA_Operator_ID
	INNER JOIN Contract_Main 
	ON Contract_Main.Contract_Main_ID = Contract_Operators.Contract_Main_ID
	AND Contract_Main.Deleted = 0
	INNER JOIN Program_Rebates_Component
	ON Program_Rebates_Component.Program_ID = Contract_Main.Contract_Main_ID
	AND Program_Rebates_Component.Deleted = 0
	INNER JOIN Program_Rebates_Component_Name
	ON Program_Rebates_Component.Program_Rebates_Component_Name_ID = Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID
	AND Program_Rebates_Component_Name.Is_USDA_NOI_Comp = 1
WHERE USDA_Agreement.Operator_ID IS NOT Null
ORDER BY USDA_Agreement.User_Agrees,  USDA_Agreement.Month_No,  BSA_Operator.Operator_Name DESC
</cfquery>

<table border="0" id="table1" cellspacing="0" cellpadding="2" width="1000">
		<tr>
			<td colspan="8" style="border-bottom: 2px solid ##FF0000" style="border-bottom: 1px solid navy">
			<p align="left"><b><font size="4">USDA Acknowledgement Report</font></b></td>
		</tr>
		
		<cfoutput query="AllAgreement" group="User_Agrees">
		<tr bgcolor="orange"><td colspan="8" style="border-bottom: 1px solid navy"><strong><font size="3" color="navy"><cfif User_Agrees IS 1>Agreed<cfelse>Rejected</cfif></font></strong></td></tr>
		<cfoutput group="Month_Desc">
		<tr bgcolor="lightsteelblue"><td style="border-bottom: 1px solid navy">&nbsp; </td><td colspan="7" style="border-bottom: 1px solid navy"><strong><font size="3" color="navy">#AllAgreement.Month_Desc#</font></strong></td></tr>
			<cfset thisCurrentrow = 1>
			<cfoutput>
				<tr bgcolor="<CFIF thisCurrentrow mod 2>##CCFFCC<CFELSE>whitesmoke</CFIF>">
					<td style="border-bottom: 1px solid lightsteelblue">&nbsp; </td>
					<td valign="top" style="border-bottom: 1px solid lightsteelblue">#AllAgreement.Operator_Name#<Br>
									#AllAgreement.Operator_Address#<br>
									#AllAgreement.Operator_City#,  #AllAgreement.Operator_State#
									#AllAgreement.Operator_Zip#
					</td>
					<td valign="top" style="border-bottom: 1px solid lightsteelblue">#AllAgreement.Name_First# #AllAgreement.Name_Last#</td>
					<td valign="top" style="border-bottom: 1px solid lightsteelblue">#dateformat(AllAgreement.DateTimeStamp, 'MM/DD/YYYY')#</td>
					<td valign="top" style="border-bottom: 1px solid lightsteelblue"><cfif User_Agrees IS 1>Agreed<cfelse>Rejected</cfif></td>
					<td valign="top"  style="border-bottom: 1px solid lightsteelblue">#Contract_Number# <Br>(#Contract_Title#)</td>
					<td valign="top" style="border-bottom: 1px solid lightsteelblue">#AllAgreement.Notes# &nbsp; </td>
				</tr>
				<cfset thisCurrentrow = thisCurrentrow + 1>
			</cfoutput>
		
		</cfoutput>
		</cfoutput>
</table>