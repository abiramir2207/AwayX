<!-----------------------------------------------------------------------------

FILE NAME:		traffic_unsuccessful_logon.cfm
DESCRIPTION: This is an include file called from traffic_info.cfm and this 
            displays the unsuccessful logon table.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			Anand Rao	26-May-2010	Created the file.
      
-------------------------------------------------------------------------------> 

<cfif FORM.optUser_Date eq "Date">
<!--- Get the Distinct dates --->			
  <cfquery name = "distinct_date" datasource="#Application.Datasource#">
    SELECT DISTINCT Month(Trans_DateTime) As LoginMonth, Day(Trans_DateTime) As LoginDay, YEAR(Trans_DateTime) As LoginYear 
		FROM Audit_User_Transactions AUT
		INNER JOIN _Users
		ON (AUT.Trans_User_Code = _Users.User_Code OR AUT.Trans_User_Code = _Users.LDAP_User_Name)
		<cfif isdefined("FORM.From_Date") and FORM.From_Date NEQ "" AND FORM.To_Date NEQ "">
		  WHERE  
			(			
			  DateDiff(d, <cfqueryparam value="#CreateODBCDate(FORM.From_Date)#" cfsqltype="CF_SQL_DATE">, AUT.Trans_DateTime) >= 0
				AND
				DateDiff(d, AUT.Trans_DateTime, <cfqueryparam value="#CreateODBCDate(FORM.To_Date)#" cfsqltype="CF_SQL_DATE">) >= 0
			)
		<cfelse>
		  WHERE DateDiff(dd, AUT.Trans_DateTime, GetDate()) < <cfqueryparam value="#TrafficInfoDays#" cfsqltype="CF_SQL_INTEGER">
		</cfif>
    AND AUT.Trans_Type = 'UNSUCCESS-LOGON'
		<cfif isdefined("FORM.Users") and FORM.Users NEQ -1>
		  AND _Users.user_code = <cfqueryparam value="#FORM.Users#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<!---Don't show BSA users --->
		<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
		  AND (_Users.User_Rights_ID IS NULL 
		  OR _Users.User_Rights_ID != 9999)
		</cfif>
			ORDER BY YEAR(Trans_DateTime), Month(Trans_DateTime), Day(Trans_DateTime) DESC
		</cfquery>

		<cfset record_count = distinct_date.recordcount>
	  <!--- Store the records in an array --->		
		<cfoutput query = "distinct_date">
			<cfset date_array[currentrow] = LoginMonth & '/' & LoginDay & '/' & LoginYear>
		</cfoutput>
	  <!--- Sort by user (Also the default value) --->
<cfelse>
	<!--- Get the Distinct users --->
  <cfquery name = "distinct_user" datasource = "#Application.Datasource#">
	  SELECT DISTINCT Name_First,Name_Last,AUT.Trans_User_Code dis_user_code 
		FROM _Users
		INNER JOIN
		Audit_User_Transactions AUT 
		ON (AUT.Trans_User_Code = _Users.user_code OR AUT.Trans_User_Code = _Users.LDAP_User_Name)
		<cfif isdefined("FORM.From_Date") and FORM.From_Date NEQ "" AND FORM.To_Date NEQ "">
			WHERE 
			(
			  DateDiff(d, <cfqueryparam value="#CreateODBCDate(FORM.From_Date)#" cfsqltype="CF_SQL_DATE">, Trans_DateTime) >= 0
			  AND
			  DateDiff(d, Trans_DateTime, <cfqueryparam value="#CreateODBCDate(FORM.To_Date)#" cfsqltype="CF_SQL_DATE">) >= 0
			)
		<cfelse>
			WHERE DateDiff(dd, AUT.Trans_DateTime, GetDate()) < <cfqueryparam value="#TrafficInfoDays#" cfsqltype="CF_SQL_INTEGER">
		</cfif>		
    AND AUT.Trans_Type = 'UNSUCCESS-LOGON'
		<cfif isdefined("FORM.Users") and FORM.Users NEQ -1>
			AND _Users.user_code = <cfqueryparam value="#FORM.Users#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<!---Don't show BSA users --->
		<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
		  AND (_Users.User_Rights_ID IS NULL 
		  OR _Users.User_Rights_ID != 9999)
		</cfif>
		ORDER BY Name_Last, Name_First
	</cfquery>
	
  <cfset record_count = distinct_user.recordcount>
		<!--- Store the records in an array --->
	<cfoutput query = "distinct_user">
		<cfset user_array[currentrow] = dis_user_code>
		<cfset user_firstname[currentrow] = Name_First>
		<cfset user_Lastname[currentrow] = Name_Last>
	</cfoutput>
</cfif>

<br><br>
  <div style="background-color: Red; color: White; font: 18px bold;">&nbsp; Log In Unsuccessful Attempts</DIV>
 	<table width="80%" border="0">
    <cfif record_count eq 0>
		  <tr>
			  <td><b>There are no records for this criteria in this date range.</b></td>
			</tr>
				<!--- If the user is not searching for Unsuccessful attempts, abort the application, as we do not need to 
						search for those records --->
<!--- 				<cfif NOT IsDefined("record_count_un")>
				</table>
				<cfabort>
				</cfif> --->
		</cfif>
			
		<cfloop index = "loopcount" from = "1" to = "#record_count#">
			<!--- ******************** Sort by date ******************** --->
		  <cfif FORM.optUser_Date eq "Date">
			<!--- Get data for the unsuccessful attempts (one day at a time) --->							
			  <cfquery name = "qLoginLogout" datasource="#Application.Datasource#">
				  SELECT Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID,Trans_DateTime,_Users.Name_First, _Users.Name_Last, _u2.Name_First AS Trans_Name_First, _u2.Name_Last AS Trans_Name_Last,
					Browser As Browser_Details

					FROM Audit_User_Transactions  AUT
					INNER JOIN _Users
					ON (AUT.Trans_User_Code = _Users.user_code OR AUT.Trans_User_Code = _Users.LDAP_User_Name)					
          LEFT JOIN _Users _u2
          ON AUT.Trans_By_User_ID = _u2.User_ID							                				
					WHERE
					( 
            AUT.Trans_DateTime >= '#date_array[loopcount]# 0:00:00 AM'
					  AND AUT.Trans_DateTime <= '#date_array[loopcount]# 23:59:59 PM'
					)
					<cfif isdefined("FORM.Users") and FORM.Users NEQ -1>
					  AND _Users.user_code = <cfqueryparam value="#FORM.Users#" cfsqltype="CF_SQL_VARCHAR">
					</cfif>
          AND AUT.Trans_Type = 'UNSUCCESS-LOGON'
					ORDER BY Trans_DateTime DESC
				</cfquery>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;</td>
				</tr>
				<tr>
					<td colspan="100%"><div style="border-bottom: 1px solid Orange; font: 14px;">
					<cfoutput>#Date_array[loopcount]#&nbsp;&nbsp;(#qLoginLogout.recordcount#)</cfoutput> 
					</div></td>
				</tr>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td nowrap style="border-bottom: 1px solid Silver;" width="100">Name</td>
					<cfif (FORM.rdoOption EQ "1")>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td nowrap style="border-bottom: 1px solid Silver;" width="100">Browser</td>
					</cfif>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td nowrap style="border-bottom: 1px solid Silver;" width="100">Time</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td nowrap style="border-bottom: 1px solid Silver;" width="150">IP Address</td>
				  <td width="80%">&nbsp;</td>
			  </tr>
			  <cfloop query="qLoginLogout">
          <cfoutput>
				    <tr>
					    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					    <td nowrap>#qLoginLogout.name_first#&nbsp;#qLoginLogout.Name_Last#</td>
					    <cfif (FORM.rdoOption EQ "1")>
					    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					    <td nowrap title="#qLoginLogout.Browser_Details#">#request.app_general_functions.getBrowserVersion(qLoginLogout.Browser_Details)#</td>
					    </cfif>
					    <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					    <td nowrap>#timeformat(qLoginLogout.Trans_DateTime,"hh:mm:ss tt")#</td>
					    <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>					
					    <td nowrap>#qLoginLogout.Trans_IP_address#</td>
              <td width="80%">&nbsp;</td>           
          	</tr>
          </cfoutput>
				</cfloop>
				<!--- ********************* Sort by user ********************* --->
			<cfelse>							
			  <!--- Get data for the successful attempts (one user at a time) --->
				<cfquery name = "qLoginLogout" datasource="#Application.Datasource#">
				  SELECT AUT.Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID,Trans_DateTime,_Users.Name_First, _Users.Name_Last,
				  	<cfif (FORM.rdoOption EQ "1")>
					CASE 
					WHEN CHARINDEX('MSIE 7.0', Browser) > 0
						THEN 'IE 7'
					WHEN CHARINDEX('MSIE 8.0', Browser) > 0
						THEN 'IE 8'
					WHEN CHARINDEX('MSIE 9.0',Browser) > 0
						THEN 'IE 9'
					WHEN CHARINDEX('MSIE 10.0',Browser) > 0
						THEN 'IE 10'
					WHEN CHARINDEX('Trident/7.0',Browser) > 0
						THEN 'IE 11'
					WHEN CHARINDEX('Chrome', Browser) > 0
						THEN 'Chrome'
					WHEN CHARINDEX('Firefox', Browser) > 0
						THEN 'Firefox'						
					WHEN CHARINDEX('Safari', Browser) > 0
						THEN 'Safari'
					END
					As Browser,
					<cfelse>
					'' As Browser,
					</cfif>
					Browser As Browser_Details

					FROM Audit_User_Transactions  AUT
          INNER JOIN _Users
					ON (AUT.Trans_User_Code = _Users.user_code OR AUT.Trans_User_Code = _Users.LDAP_User_Name)
					<cfif isdefined("FORM.From_Date") AND FORM.From_Date NEQ "" AND FORM.To_Date NEQ "">
					  WHERE
						(
						  DateDiff(d, <cfqueryparam value="#CreateODBCDate(FORM.From_Date)#" cfsqltype="CF_SQL_DATE">, Trans_DateTime) >= 0
							AND
							DateDiff(d, Trans_DateTime, <cfqueryparam value="#CreateODBCDate(FORM.To_Date)#" cfsqltype="CF_SQL_DATE">) >= 0
						)
					<cfelse>
					  WHERE DateDiff(dd, AUT.Trans_DateTime, GetDate()) < <cfqueryparam value="#TrafficInfoDays#" cfsqltype="CF_SQL_INTEGER">
					</cfif>
					AND AUT.Trans_Type = 'UNSUCCESS-LOGON'
					AND Trans_User_Code = <cfqueryparam value="#user_array[loopcount]#" cfsqltype="CF_SQL_VARCHAR">
					ORDER BY Trans_DateTime DESC
				</cfquery>
			  <tr>
				  <td>&nbsp;&nbsp;&nbsp;</td>
				</tr>
				<tr>
				  <td colspan="100%"><cfoutput><div style="border-bottom: 1px solid Orange; font: 14px;">
					  #user_firstname[loopcount]#&nbsp;#user_lastname[loopcount]#&nbsp;&nbsp;(#qLoginLogout.recordcount#)</div></cfoutput>
					</td>
			  </tr>
				<tr>
				  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td nowrap style="border-bottom: 1px solid Silver;" width="100">Date</td>
					<cfif (FORM.rdoOption EQ "1")>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td nowrap style="border-bottom: 1px solid Silver;" width="100">Browser</td>
					</cfif>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td nowrap style="border-bottom: 1px solid Silver;" width="100">Time</td>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
					<td nowrap style="border-bottom: 1px solid Silver;" width="150">IP Address</td>
					<td width = "80%">&nbsp;</td>
				</tr>
				<cfloop query="qLoginLogout">
          <cfoutput>
					  <tr>
						  <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
							<td nowrap>#dateformat(qLoginLogout.Trans_DateTime,"mm/dd/yyyy")#</td>
							<cfif (FORM.rdoOption EQ "1")>
							<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
							<td nowrap title="#qLoginLogout.Browser_Details#">#request.app_general_functions.getBrowserVersion(qLoginLogout.Browser_Details)#</td>
							</cfif>
							<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
							<td nowrap>#timeformat(qLoginLogout.Trans_DateTime,"hh:mm:ss tt")#</td>
							<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>						
							<td nowrap>#qLoginLogout.Trans_IP_address#</td>
              <td width = "80%">&nbsp;</td>
						</tr>
          </cfoutput>
				</cfloop>
			</cfif>
		</cfloop>
	</table>
        