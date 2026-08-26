
<!---1: blacksmithlogin.cfm 		copy index2.cfm --->
<!---2: blacksmithlogin_enter.cfm  	copy enter.cfm 	--->


<!--- CHECK:: Is_First_Time, Is_Locked if users have Is_First_Time = 1 or Is_Locked = 1 				---> 
<!--- select Is_First_Time, Is_Locked,* from _Users where (Is_First_Time = 1 or Is_Locked = 1) and deleted = 0   	--->
<CFQUERY NAME="Set_Is_First_Time" datasource="#application.datasource#">
	--UPDATE	_Users
	--SET 	Is_First_Time = 0, Is_Locked = 0
	select Is_First_Time, Is_Locked,* from _Users where (Is_First_Time = 1 or Is_Locked = 1) and deleted = 0 
</CFQUERY>

<CFQUERY NAME="AppUsersNow" datasource="#application.datasource#">
	Select DateDiff("n", Session_Date_Time_Stamp, GetDate()) AS idleMinutes,Session_Tracker.Session_User_ID,_Users.Name_First,_Users.Name_Last,User_Code
	From		Session_Tracker,_Users
	Where		(Session_Tracker.Session_ID <> 'NULL')
	AND (Session_Tracker.Session_User_ID	=	_Users.User_ID	)
	AND DateDiff(n, Session_Date_Time_Stamp, GetDate()) < (Select  TOP 1 Session_Expiration_Length * 24 * 60 	From	General_Settings)
	AND DateDiff("n", Session_Date_Time_Stamp, GetDate()) < 200
	Order by	idleMinutes,Name_First
</CFQUERY>


<style type="text/css">
.usertbl  {border-collapse:collapse;border-spacing:0;}
.usertbl td{font-family:Arial, sans-serif;font-size:8pt;padding:5px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.usertbl th{font-family:Arial, sans-serif;font-size:8pt;font-weight:normal;padding:5px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
</style>

<cfif AppUsersNow.recordcount GT 10>
	<TABLE>	<TR><TD valign ="TOP">
</cfif>

<br><b>Below users are currently working on the application:</b><br>
<table class="usertbl">
	<tr><th>Idle Mins</th> <th>Login</th> <th>User</th></tr>
	<cfoutput query="AppUsersNow">
		<tr>
			<td align="center">#idleMinutes#</td><td style="font-weight: bold;color:maroon">#User_Code#</td> <td>#Name_First# #Name_Last#</td>
		</tr>
	</cfoutput>
</table>

<cfif AppUsersNow.recordcount GT 10>
	</TD><TD>
</cfif>
<!--- copy index2.cfm below and change enter.cfm to blacksmithlogin_enter.cfm--->
<!--- index2.cfm Start --->




<!--- index2.cfm End --->
<cfif AppUsersNow.recordcount GT 10>
	</TD></TR></TABLE>
</cfif>