<!---
*******************************************************************************
Modified By: Milan Mushran
Modification: Added sorting for "unsuccessful" and "successful" attempts and sorting by "user"/"Date"
Filename: traffic_info.cfm
Modified Date: 9/1/2004
Purpose: For tracking the application traffic
Input Parameters (form): FORM.From_Date, FORM.To_Date, Form.Users,
            Form.optLoginType, Form.optUser_Date
Input Parameters (query): user_array, user_array_un, date_array, user_array_un

Modified By :Anand Rao  Date: 26-May-10
Reworked the whole page for handling different type of Transaction codes
from the new table Audit_User_Transactions
*******************************************************************************
--->

<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset bErrorMessage = 0 />

<HTML>

<BODY>
<cfset jQuery.version ="1.12.4">

<cfinclude template="/Common_Files/jQuery.cfm">

<cf_include files="/script/javascript/chosen/chosen.jquery.min.js, /styles/chosen/chosen.css">
<cfset genSettings = CreateObject("component","components.settings.ApplicationSettingsManager").init() />

<!--- Get the traffic Info. days from the "ApplicationSettingsManager" component --->
<cfset TrafficInfoDays = genSettings.get().getTrafficInfodays()>

<cfset URL.PageTitle="USERS: Traffic Info">

<cfparam name="FORM.optLoginType" default="2">
<cfparam name="FORM.optUser_Date" default="user">
<cfparam name="FORM.From_Date" default="">
<cfparam name="FORM.To_Date" default="">
<cfparam name="FORM.users" default="-1">
<cfparam name="FORM.rdoOption" default="1">

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<STYLE TYPE="text/css">
Body,
TD
{
	font: 12px Arial;
},
a
{
	color: Blue;
	text-decoration: none;
}
</STYLE>

<SCRIPT language="JavaScript">
function validate()
{
	y = document.date_range;
	var today = new Date;

	if(y.From_Date.value != "")
	{
		if(y.To_Date.value == "")
		{
			alert("Please enter date in TO Date");
			y.To_Date.focus();
			return false;
		}
	}
	if(y.To_Date.value != "")
	{
		if(y.From_Date.value == "")
		{
			alert("Please enter date in FROM DATE");
			y.From_Date.focus();
			return false;
		}
	}
	/* if(checkDate(y.To_Date.value,y.From_Date.value) > 7)
	{
		alert("The range should be with in 7 days")
		y.To_Date.focus()
		return false;

	}*/
	if(checkDate(y.To_Date.value,y.From_Date.value)<0)
	{
		alert("Please make the FROM DATE less than or equal to TO DATE");
		y.From_Date.focus();
		return false;
	}
	var dateString = (today.getMonth() + 1) + "/" + today.getDate() + "/" + today.getFullYear();
	if(checkDate(y.To_Date.value, dateString)>=1)
	{
		alert("TO DATE cannot be more than todays date");
		y.To_Date.focus();
		return false;
	}

	return true;

}
</SCRIPT>

<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
<SCRIPT>

function checkDate(dateStr1,dateStr2)
{
	var dateSplit;
	var retVal = null;
	dateSplit = dateStr1.split("/");
	if(dateSplit)
	{
		if(dateSplit.length > 2)
		{
			var date1 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
			dateSplit = dateStr2.split("/");
			if(dateSplit)
			{
				if(dateSplit.length > 2)
				{
					var date2 = new Date(dateSplit[2], dateSplit[0]-1, dateSplit[1]);
					retVal = days_between(date1, date2, true);
				}
			}
		}
	}
return retVal;
}
</SCRIPT>

<!--- Initialize arrays to hold the data --->
<cfset user_array        = ArrayNew(1)>
<cfset user_firstname    = ArrayNew(1)>
<cfset user_lastname     = ArrayNew(1)>
<cfset user_array_un     = ArrayNew(1)>
<cfset user_firstname_un = ArrayNew(1)>
<cfset user_lastname_un  = ArrayNew(1)>
<cfset date_array        = ArrayNew(1)>
<cfset date_array_un     = ArrayNew(1)>

	<cfquery name = "distinct_users" datasource = "#Application.Datasource#">
		SELECT DISTINCT Name_First,Name_Last,AUT.Trans_User_Code dis_user_code
		FROM _Users
		INNER JOIN Audit_User_Transactions AUT
		ON AUT.Trans_User_Code = _Users.User_Code
		<!---Don't show BSA users --->
		<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
		WHERE (_Users.User_Rights_ID IS NULL
		OR _Users.User_Rights_ID != 9999)
		</cfif>
		order by name_first
	</cfquery>


<!--- sort by date --->
<cfif FORM.optUser_Date eq "Date">
<!--- Get the Distinct dates --->
<!----
Unused statuses:
UNSUCCESS-LOGON
ACCESS-LEVEL-CHANGE
SYSTEM-ADMIN-CHANGE
UPDATE-USER
PROFILE-UPDATE
PIN-RESET
UNLOCK-FORCED-LOGOFF
---->
		<CFQUERY name = "distinct_date" datasource="#Application.Datasource#">
				SELECT DISTINCT Month(Trans_DateTime) As LoginMonth, Day(Trans_DateTime) As LoginDay, YEAR(Trans_DateTime) As LoginYear
				FROM Audit_User_Transactions AUT
				INNER JOIN _Users
				<cfif (FORM.rdoOption EQ "9")>
				ON AUT.Trans_By_User_ID = _Users.User_ID
				<cfelse>
				ON AUT.Trans_User_Code = _Users.User_Code
				</cfif>
				<CFIF isdefined("FORM.From_Date") and FORM.From_Date NEQ "" AND FORM.To_Date NEQ "">
				WHERE
				(
				DateDiff(d, <cfqueryparam value="#CreateODBCDate(FORM.From_Date)#" cfsqltype="CF_SQL_DATE">, Trans_DateTime) >= 0
				AND
				DateDiff(d, Trans_DateTime, <cfqueryparam value="#CreateODBCDate(FORM.To_Date)#" cfsqltype="CF_SQL_DATE">) >= 0
				)
				<cfelse>
				WHERE DateDiff(dd, AUT.Trans_DateTime, GetDate()) < <cfqueryparam value="#TrafficInfoDays#" cfsqltype="CF_SQL_INTEGER">
				</cfif>
				<cfif (FORM.rdoOption EQ "1")>
				AND (AUT.Trans_Type = 'LOGON' OR AUT.Trans_Type = 'LOGOFF')
				<cfelseif (FORM.rdoOption EQ "2")>
				AND AUT.Trans_Type = 'LOCKED-OUT'
				<cfelseif (FORM.rdoOption EQ "3")>
				AND AUT.Trans_Type = 'UNLOCK-USER'
				<cfelseif (FORM.rdoOption EQ "4")>
				AND (AUT.Trans_Type = 'PASSWORD-RESET' OR AUT.Trans_Type = 'PIN-RESET')
				<cfelseif (FORM.rdoOption EQ "5")>
				AND AUT.Trans_Type = 'PASSWORD-CHANGE'
				<cfelseif (FORM.rdoOption EQ "6")>
				AND AUT.Trans_Type = 'INACTIVATE-USER'
				<cfelseif (FORM.rdoOption EQ "7")>
				AND AUT.Trans_Type = 'ACTIVATE-USER'
				<cfelseif (FORM.rdoOption EQ "8")>
				AND AUT.Trans_Type = 'CREATE-USER'
				<cfelseif (FORM.rdoOption EQ "9")>
				AND AUT.Trans_Type = 'UNKNOWN-USER'
				</cfif>
				<cfif isdefined("Form.Users") and Form.Users NEQ -1>
				AND _Users.user_code = <cfqueryparam value="#Form.Users#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<!---Don't show BSA users --->
				<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
				AND (_Users.User_Rights_ID IS NULL OR _Users.User_Rights_ID != 9999)
				</cfif>
				ORDER BY YEAR(Trans_DateTime), Month(Trans_DateTime), Day(Trans_DateTime) DESC
		</CFQUERY>

		<CFSET record_count = distinct_date.recordcount>

	<!--- Store the records in an array --->
		<CFOUTPUT query = "distinct_date">
			<CFSET date_array[currentrow] = LoginMonth & '/' & LoginDay & '/' & LoginYear>
		</CFOUTPUT>

	<!--- Sort by user (Also the default value) --->
		<!---
		********************************************************************************************************************************************************
		********************************************************************************************************************************************************
		***********************************************************ELSE SORT BY USER****************************************************************************
		********************************************************************************************************************************************************
		********************************************************************************************************************************************************
		 --->
<cfelse>

		<!--- Get the Distinct users --->
		<CFQUERY name = "distinct_user" datasource = "#Application.Datasource#">
				SELECT DISTINCT Name_First,Name_Last,AUT.Trans_User_Code dis_user_code
				FROM _Users
				INNER JOIN
				Audit_User_Transactions AUT
				<cfif (FORM.rdoOption EQ "9")>
				ON AUT.Trans_By_User_ID = _Users.User_ID
				<cfelse>
				ON (AUT.Trans_User_Code = _Users.User_Code OR AUT.Trans_User_Code = _Users.LDAP_User_Name)
				</cfif>
				<cfif isdefined("FORM.Users") and FORM.Users NEQ -1>
				AND _Users.user_code = <cfqueryparam value="#Form.Users#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<CFIF isdefined("FORM.From_Date") and FORM.From_Date NEQ "" AND FORM.To_Date NEQ "">
				WHERE
				(
				DateDiff(d, <cfqueryparam value="#CreateODBCDate(FORM.From_Date)#" cfsqltype="CF_SQL_DATE">, Trans_DateTime) >= 0
				AND
				DateDiff(d, Trans_DateTime, <cfqueryparam value="#CreateODBCDate(FORM.To_Date)#" cfsqltype="CF_SQL_DATE">) >= 0
				)
				<cfelse>
				WHERE DateDiff(dd, AUT.Trans_DateTime, GetDate()) < <cfqueryparam value="#TrafficInfoDays#" cfsqltype="CF_SQL_INTEGER">
				</cfif>
				<cfif (FORM.rdoOption EQ "1")>
				AND (AUT.Trans_Type = 'LOGON' OR AUT.Trans_Type = 'LOGOFF')
				<cfelseif (FORM.rdoOption EQ "2")>
				AND AUT.Trans_Type = 'LOCKED-OUT'
				<cfelseif (FORM.rdoOption EQ "3")>
				AND AUT.Trans_Type = 'UNLOCK-USER'
				<cfelseif (FORM.rdoOption EQ "4")>
				AND (AUT.Trans_Type = 'PASSWORD-RESET' OR AUT.Trans_Type = 'PIN-RESET')
				<cfelseif (FORM.rdoOption EQ "5")>
				AND AUT.Trans_Type = 'PASSWORD-CHANGE'
				<cfelseif (FORM.rdoOption EQ "6")>
				AND AUT.Trans_Type = 'INACTIVATE-USER'
				<cfelseif (FORM.rdoOption EQ "7")>
				AND AUT.Trans_Type = 'ACTIVATE-USER'
				<cfelseif (FORM.rdoOption EQ "8")>
				AND AUT.Trans_Type = 'CREATE-USER'
				<cfelseif (FORM.rdoOption EQ "9")>
				AND AUT.Trans_Type = 'UNKNOWN-USER'
				</cfif>
				<cfif isdefined("FORM.Users") and FORM.Users NEQ -1>
				AND _Users.user_code = <cfqueryparam value="#Form.Users#" cfsqltype="CF_SQL_VARCHAR">
				</cfif>
				<!---Don't show BSA users --->
				<cfif appSettings.getHide_BSA_Users() IS 1 AND request.AccessStructure.User_Rights_ID NEQ 9999>
				AND (_Users.User_Rights_ID IS NULL OR _Users.User_Rights_ID != 9999)
				</cfif>
				ORDER BY Name_Last, Name_First
		</CFQUERY>

	<CFSET record_count = distinct_user.recordcount>
		<!--- Store the records in an array --->
	<CFOUTPUT query = "distinct_user">
		<CFSET user_array[currentrow] = dis_user_code>
		<CFSET user_firstname[currentrow] = Name_First>
		<CFSET user_Lastname[currentrow] = Name_Last>
	</CFOUTPUT>

</cfif>

<!--- store the code below in a variable --->
<cfsavecontent variable = "Display">
<CFOUTPUT>

	<b><FONT COLOR="red">[</FONT><FONT COLOR="blue">date range</FONT><FONT COLOR="red">]</FONT></b>

	<FORM NAME="date_range" ACTION="Traffic_Info.cfm" METHOD="POST" ONSUBMIT="return validate()">
		<TABLE border="0">
			<TR>
				<TD align="right">From:</TD >
				<TD><CF_EASYDATE FORMNAME="date_range" FIELDNAME="From_Date" FORMAT="mm/dd/yyyy" DEFAULT="#From_Date#"></TD>
				<TD>&nbsp;</TD>
				<TD>To:</TD>
				<TD><CF_EASYDATE FORMNAME="date_range" FIELDNAME="To_Date" FORMAT="mm/dd/yyyy" DEFAULT="#To_Date#"></TD>
				<TD>&nbsp;</TD>
				<TD>Users:</TD>
				<TD> <SELECT name="Users" id="Users" style="width:250px" data-placeholder="Select a User...">
						<OPTION VALUE="-1" SELECTED>--All ----------------------------</OPTION>
						<CFLOOP QUERY="distinct_users">
								<OPTION VALUE="#dis_user_code#" <cfif form.users eq dis_user_code>selected</cfif>>#Name_First# #Name_Last# (#dis_user_code#)</OPTION>
						</CFLOOP>
				</SELECT>
				</TD>
			</TR>
			<TR>
				<TD colspan="8">&nbsp;</TD>
			</TR>
			<TR>
				<TD valign="top" align="right">User/Date:</TD >
				<TD valign="top" colspan="7">
				<input type="radio" name="optUser_Date" value="User" <cfif form.optUser_Date eq "User">checked</cfif>>Sort by User
				<input type="radio" name="optUser_Date" value="Date" <cfif form.optUser_Date eq "Date">checked</cfif>>Sort by Date
				</TD>
        	</TR>

        <TR>
          <TD valign="top">
            <strong>Include:</strong>
          </TD>
          <TD colspan="7">
            <TABLE cellspacing="2" cellpadding="0" border="0">
              <TR>
                <TD valign="middle"><input type="radio" name="rdoOption" value="1" <cfif FORM.rdoOption EQ "1">checked</cfif>> Log In & Off</TD>
                <TD><input type="radio" name="rdoOption" value="2" <cfif FORM.rdoOption EQ "2">checked</cfif>> Locked Out</TD>
                <TD><input type="radio" name="rdoOption" value="3" <cfif FORM.rdoOption EQ "3">checked</cfif>> Unlock User</TD>
                <TD><input type="radio" name="rdoOption" value="4" <cfif FORM.rdoOption EQ "4">checked</cfif>> Password/Pin Reset</TD>
              </TR>
              <TR>
                <TD><input type="radio" name="rdoOption" value="5" <cfif FORM.rdoOption EQ "5">checked</cfif>> Password Change</TD>
                <TD><input type="radio" name="rdoOption" value="6" <cfif FORM.rdoOption EQ "6">checked</cfif>> Inactivate User</TD>
                <TD><input type="radio" name="rdoOption" value="7" <cfif FORM.rdoOption EQ "7">checked</cfif>> Activate User</TD>
                <TD><input type="radio" name="rdoOption" value="8" <cfif FORM.rdoOption EQ "8">checked</cfif>> Create User</TD>
              </TR>
              <TR>
              <TD colspan="4">
                <input type="radio" name="rdoOption" value="9" <cfif FORM.rdoOption EQ "9">checked</cfif>> Unknown User
              </TD>
            </TR>
           </TABLE>
          </TD>
        </TR>
        <TR>
        <TD valign="top" align="right" colspan="8"><INPUT TYPE="submit" VALUE="Get Report" style="font-family: verdana,arial,helvetica; font-size:10px; width:90;">
				<a href="#CGI.SCRIPT_NAME#" style="font-family: verdana,arial,helvetica; font-size: 10px; margin-left:20px;">Reset settings</a>
	    </TD>
			</TR>
		</TABLE>
	</FORM>

<p><strong>Date Range:</strong>&nbsp;&nbsp;&nbsp; <strong>From:</strong>
 <CFIF isdefined("FORM.From_Date") and FORM.From_Date NEQ "" AND FORM.To_Date NEQ ""> #Dateformat(FORM.From_Date,"MM/DD/YYYY")#<cfelse>#Dateformat(Dateadd("d",-(TrafficInfoDays-1),now()),"MM/DD/YYYY")#</cfif>
 &nbsp;&nbsp;&nbsp; <strong>To:</strong>
 <CFIF isdefined("FORM.From_Date") and FORM.From_Date NEQ "" AND FORM.To_Date NEQ ""> #Dateformat(FORM.To_Date,"MM/DD/YYYY")#<cfelse>#Dateformat(now(),"MM/DD/YYYY")#</cfif>
 <!--- Dev Note: drachala; D29000: traffic info same logout time issue  START
 Added/Changed: Added red astrick to point of User logout next day--->
 <br><br><cfif (FORM.rdoOption EQ "1") AND (FORM.optUser_Date NEQ "Date")><font color="red"><B>*</B></font>&nbsp;User logout next day.</cfif>
 <!--- End Dev Note: drachala; D29000: traffic info same logout time issue  --->
 </p>

<!---- START --->

<cfif (FORM.rdoOption EQ "1")>
  <DIV STYLE="background-color: Green; color: White; font: 18px bold;">&nbsp;Log In & Off Successful Attempts</DIV>
 <cfelseif (FORM.rdoOption EQ "2")>
  <DIV STYLE="background-color: Green; color: White; font: 18px bold;">&nbsp;Locked Out</DIV>
<cfelseif (FORM.rdoOption EQ "3")>
  <DIV STYLE="background-color: Green; color: White; font: 18px bold;">&nbsp;Unlock User</DIV>
<cfelseif (FORM.rdoOption EQ "4")>
  <DIV STYLE="background-color: Green; color: White; font: 18px bold;">&nbsp;Password/Pin Reset</DIV>
<cfelseif (FORM.rdoOption EQ "5")>
  <DIV STYLE="background-color: Green; color: White; font: 18px bold;">&nbsp;Password Change</DIV>
<cfelseif (FORM.rdoOption EQ "6")>
  <DIV STYLE="background-color: Green; color: White; font: 18px bold;">&nbsp;Inactivate User</DIV>
<cfelseif (FORM.rdoOption EQ "7")>
  <DIV STYLE="background-color: Green; color: White; font: 18px bold;">&nbsp;Activate User</DIV>
<cfelseif (FORM.rdoOption EQ "8")>
  <DIV STYLE="background-color: Green; color: White; font: 18px bold;">&nbsp;Create User</DIV>
<cfelseif (FORM.rdoOption EQ "9")>
  <DIV STYLE="background-color: Green; color: White; font: 18px bold;">&nbsp;Unknown User</DIV>
</cfif>

		<TABLE width="60%" border="0">
			<cfif record_count eq 0>
				<TR>
					<TD><b>There are no records for this criteria in this date range.</b></TD>
				</TR>
			</cfif>

      <CFLOOP INDEX = "loopcount" FROM = "1" TO = "#record_count#">
			<!--- ******************** Sort by date ******************** --->
<cfif FORM.optUser_Date eq "Date">
			  <!--- Get data for the successful attempts (one day at a time) --->
      <cfset qLogout = QueryNew("Audit_User_Transactions_ID,Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_DateTime,Name_First,Name_Last,Trans_Name_First,Trans_Name_Last,Trans_DateTimeLogout") />
					<CFQUERY name = "qLoginLogout" datasource="#Application.Datasource#">
							SELECT Audit_User_Transactions_ID,
							Trans_Type,Trans_User_Code,
							Browser As Browser_Details,
							Trans_IP_Address,
							Trans_By_User_ID,Trans_DateTime,
							_Users.Name_First, _Users.Name_Last,
							_u2.Name_First AS Trans_Name_First,
							_u2.Name_Last AS Trans_Name_Last,
							null as Trans_DateTimeLogout
							FROM Audit_User_Transactions  AUT
							INNER JOIN _Users
							<cfif (FORM.rdoOption EQ "9")>
							ON AUT.Trans_By_User_ID = _Users.User_ID
							<cfelse>
							ON (AUT.Trans_User_Code = _Users.User_Code OR AUT.Trans_User_Code = _Users.LDAP_User_Name)
							</cfif>
							LEFT JOIN _Users _u2
							ON AUT.Trans_By_User_ID = _u2.User_ID
							WHERE
							( AUT.Trans_DateTime >= '#date_array[loopcount]# 0:00:00 AM'
							AND AUT.Trans_DateTime <= '#date_array[loopcount]# 23:59:59 PM'
							)
							<cfif isdefined("Form.Users") and Form.Users NEQ -1>
							AND _Users.user_code = <cfqueryparam value="#Form.Users#" cfsqltype="CF_SQL_VARCHAR">
							</cfif>
							<cfif (FORM.rdoOption EQ "1")>
							AND (AUT.Trans_Type = 'LOGON' OR AUT.Trans_Type = 'LOGOFF')
							<cfelseif (FORM.rdoOption EQ "2")>
							AND AUT.Trans_Type = 'LOCKED-OUT'
							<cfelseif (FORM.rdoOption EQ "3")>
							AND AUT.Trans_Type = 'UNLOCK-USER'
							<cfelseif (FORM.rdoOption EQ "4")>
							AND (AUT.Trans_Type = 'PASSWORD-RESET' OR AUT.Trans_Type = 'PIN-RESET')
							<cfelseif (FORM.rdoOption EQ "5")>
							AND AUT.Trans_Type = 'PASSWORD-CHANGE'
							<cfelseif (FORM.rdoOption EQ "6")>
							AND AUT.Trans_Type = 'INACTIVATE-USER'
							<cfelseif (FORM.rdoOption EQ "7")>
							AND AUT.Trans_Type = 'ACTIVATE-USER'
							<cfelseif (FORM.rdoOption EQ "8")>
							AND AUT.Trans_Type = 'CREATE-USER'
							<cfelseif (FORM.rdoOption EQ "9")>
							AND AUT.Trans_Type = 'UNKNOWN-USER'
							</cfif>
		 					ORDER BY Trans_DateTime  <cfif (FORM.rdoOption EQ "1")>ASC<cfelse> DESC</cfif>
					</CFQUERY>

              <cfset qLogout = QueryNew("Audit_User_Transactions_ID2,Browser2,Browser_Details2,Trans_Type2,Trans_User_Code2,Trans_IP_Address2,Trans_DateTime2,Name_First2,Name_Last2,Trans_Name_First2,Trans_Name_Last2,Trans_DateTimeLogout2") />
              <cfloop Query="qLoginLogout">
                 <cfset newRow = QueryAddRow(qLogout) />
                 <cfset QuerySetCell(qLogout, "Audit_User_Transactions_ID2", qLoginLogout.Audit_User_Transactions_ID )/>
		 <cfset QuerySetCell(qLogout, "Browser2", request.app_general_functions.getBrowserVersion(qLoginLogout.Browser_Details) )/>
		 <cfset QuerySetCell(qLogout, "Browser_Details2", qLoginLogout.Browser_Details )/>
                 <cfset QuerySetCell(qLogout, "Trans_Type2", qLoginLogout.Trans_Type )/>
                 <cfset QuerySetCell(qLogout, "Trans_User_Code2", qLoginLogout.Trans_User_Code)/>
                 <cfset QuerySetCell(qLogout, "Trans_IP_Address2", qLoginLogout.Trans_User_Code )/>
                 <cfset QuerySetCell(qLogout, "Trans_DateTime2", qLoginLogout.Trans_DateTime)/>
                 <cfset QuerySetCell(qLogout, "Name_First2", qLoginLogout.Name_First)/>
                 <cfset QuerySetCell(qLogout, "Name_Last2", qLoginLogout.Name_Last)/>
                 <cfset QuerySetCell(qLogout, "Trans_Name_First2", qLoginLogout.Trans_Name_First)/>
                 <cfset QuerySetCell(qLogout, "Trans_Name_Last2", qLoginLogout.Trans_Name_Last)/>
                 <cfset QuerySetCell(qLogout, "Trans_DateTimeLogout2", "" )/>
             </cfloop>
              <!--- Sort and make the login and logout pair as one record  --->
              <cfset aryLogPair = ArrayNew(2)>
              <cfset i = 1 />
              <cfif FORM.rdoOption EQ "1">

                <cfloop query="qLoginLogout" >
                  <cfif (qLoginLogout.Trans_Type EQ "LOGON")>
                    <cfset aryLogPair[i][1] =  qLoginLogout.Audit_User_Transactions_ID />
		    <cfset aryLogPair[i][2] =  request.app_general_functions.getBrowserVersion(qLoginLogout.Browser_Details) />
		    <cfset aryLogPair[i][3] =  qLoginLogout.Browser_Details />
                    <cfset aryLogPair[i][4] =  qLoginLogout.Trans_Type />
                    <cfset aryLogPair[i][5] =  qLoginLogout.Trans_User_Code />
                    <cfset aryLogPair[i][6] =  qLoginLogout.Trans_IP_Address />
                    <cfset aryLogPair[i][7] =  qLoginLogout.Trans_DateTime />
                    <cfset aryLogPair[i][8] =  qLoginLogout.Name_First />
                    <cfset aryLogPair[i][9] =  qLoginLogout.Name_Last />
                    <cfset aryLogPair[i][10] =  qLoginLogout.Trans_Name_First />
                    <cfset aryLogPair[i][11] =  qLoginLogout.Trans_Name_Last />
                    <cfset aryLogPair[i][12]= "" />
                    <cfset aryLogPair[i][13]= "" />
                    <cfloop query="qLogout">

                      <cfif (qLogout.Audit_User_Transactions_ID2 NEQ qLoginLogout.Audit_User_Transactions_ID)>
					     <cfif ((qLoginLogout.Trans_User_Code EQ qLogout.Trans_User_Code2) AND (qLogout.Trans_Type2 EQ "LOGOFF") AND ((DateCompare(qLoginLogout.Trans_DateTime,qLogout.Trans_DateTime2,"s") EQ -1)))>
                         	<cfset aryLogPair[i][12] =  qLogout.Trans_DateTime2 />
							<!--- this if is to check if your logout time in same day is less than next login in same day if not we are assigning empty value to array. --->
							 	<cfset j = i - 1>
							 <cfif J>
								 	<cfif #aryLogPair[j][12]# GT #aryLogPair[i][7]#>
								 	 <cfset #aryLogPair[j][12]# = "">
								 	</cfif>
							 </cfif>
						 	<cfbreak />
                         </cfif>
                      </cfif>
                    </cfloop>
                    <cfset i = i+1 />
                  </cfif>
                </cfloop>

              <cfscript>
              qLoginLogout2 = QueryNew("Audit_User_Transactions_ID,Browser,Browser_Details,Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_DateTime,Name_First,Name_Last,Trans_Name_First,Trans_Name_Last,Trans_DateTimeLogout,Next_day");
              for (i=1; i LTE ArrayLen(aryLogPair); i=i+1) {
                 newRow = QueryAddRow(qLoginLogout2);
                 QuerySetCell(qLoginLogout2, "Audit_User_Transactions_ID", #aryLogPair[i][1]# );
		 QuerySetCell(qLoginLogout2, "Browser", #aryLogPair[i][2]# );
		 QuerySetCell(qLoginLogout2, "Browser_Details", #aryLogPair[i][3]# );
                 QuerySetCell(qLoginLogout2, "Trans_Type", #aryLogPair[i][4]# );
                 QuerySetCell(qLoginLogout2, "Trans_User_Code", #aryLogPair[i][5]# );
                 QuerySetCell(qLoginLogout2, "Trans_IP_Address", #aryLogPair[i][6]# );
                 QuerySetCell(qLoginLogout2, "Trans_DateTime", #aryLogPair[i][7]# );
                 QuerySetCell(qLoginLogout2, "Name_First", #aryLogPair[i][8]# );
                 QuerySetCell(qLoginLogout2, "Name_Last", #aryLogPair[i][9]# );
                 QuerySetCell(qLoginLogout2, "Trans_Name_First", #aryLogPair[i][10]# );
                 QuerySetCell(qLoginLogout2, "Trans_Name_Last", #aryLogPair[i][11]# );
                 QuerySetCell(qLoginLogout2, "Trans_DateTimeLogout", #aryLogPair[i][12]# );
                 QuerySetCell(qLoginLogout2, "Next_day", #aryLogPair[i][13]# );
              }
              qLoginLogout = qLoginLogout2;
              </cfscript>

           </cfif>


<cfif (qLoginLogout.RecordCount GTE 1)>
		<TR>
			<TD>&nbsp;&nbsp;&nbsp;</TD>
		</TR>
		<TR>
			<TD colspan="100%">
				<DIV STYLE="border-bottom: 1px solid Orange; font: 14px;">#Date_array[loopcount]#&nbsp;&nbsp;(#qLoginLogout.recordcount#)</DIV>
			</TD>
		</TR>
		<TR>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<cfif (FORM.rdoOption EQ "9")>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="100">User Code</TD>
			<cfelse>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="100">Name</TD>
			</cfif>
			<cfif (FORM.rdoOption EQ "1")>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="150">Browser/OS</TD>
			</cfif>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="100"><cfif rdoOption EQ "1">Log In<cfelse>Time</cfif></TD >
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD >
			<cfif (FORM.rdoOption EQ "1")>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="100">Log Off</TD>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD >
			</cfif>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="150">IP Address</TD>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD >
			<cfif (FORM.rdoOption EQ "3")>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="150">User Unlocked By</TD>
			</cfif>
			<cfif (FORM.rdoOption EQ "4")>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="150">Type</TD>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD >
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="150">Password/Pin Reset By</TD>
			</cfif>
			<cfif (FORM.rdoOption EQ "6")>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="150">User Inactivated By</TD>
			</cfif>
			<cfif (FORM.rdoOption EQ "7")>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="150">User Activated By</TD>
			</cfif>
			<cfif (FORM.rdoOption EQ "8")>
			<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="150">User Created By</TD>
			</cfif>
			<TD width = "80%">&nbsp;</TD >
		</TR>
<CFLOOP query="qLoginLogout">
		<TR>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD >
			<cfif (FORM.rdoOption EQ "9")>
			<TD NOWRAP>#qLoginLogout.Trans_User_Code#</TD >
			<cfelse>
			<TD NOWRAP>#qLoginLogout.name_first#&nbsp;#qLoginLogout.Name_Last#</TD>
			</cfif>
			<cfif (FORM.rdoOption EQ "1")>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD >
			<TD NOWRAP title="#qLoginLogout.browser_details#">#request.app_general_functions.getBrowserVersion(qLoginLogout.Browser_Details)# &nbsp; /&nbsp; #request.app_general_functions.getOperatingSystem(qLoginLogout.Browser_Details)#</TD>
			</cfif>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD >
			<TD NOWRAP>#timeformat(qLoginLogout.Trans_DateTime,"hh:mm:ss tt")#</TD>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD >
			<cfif (FORM.rdoOption EQ "1")>
			<TD NOWRAP>
			<cfif len(timeformat(qLoginLogout.Trans_DateTimeLogout,"hh:mm:ss tt"))>
			#timeformat(qLoginLogout.Trans_DateTimeLogout,"hh:mm:ss tt")#<!---<cfif len(qLoginLogout.Next_day) AND qLoginLogout.Next_day><font color="red">*</font></cfif>--->
			<cfelse>
			*User didn't logout properly*
			</cfif>
			</TD>
			<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD >
			</cfif>
			<TD NOWRAP>#qLoginLogout.Trans_IP_Address#</TD >
			<TD>&nbsp;</TD >
			<cfif (FORM.rdoOption EQ "4")>
			<TD nowrap><cfif qLoginLogout.Trans_Type EQ "PASSWORD-RESET">Password<cfelseif qLoginLogout.Trans_Type EQ "PIN-RESET">Pin</cfif>  </TD>
			<TD>&nbsp;</TD>
			</cfif>
			<cfif ((FORM.rdoOption EQ "3") OR (FORM.rdoOption EQ "4") OR (FORM.rdoOption EQ "6") OR (FORM.rdoOption EQ "7") OR (FORM.rdoOption EQ "8"))>
			<TD NOWRAP>#qLoginLogout.Trans_Name_First# #qLoginLogout.Trans_Name_Last#</TD >
			</cfif>
			<TD>&nbsp;</TD>
		</TR>
</CFLOOP>
		</cfif>
				<!--- ********************* Sort by user ********************* --->
		<!---
		********************************************************************************************************************************************************
		********************************************************************************************************************************************************
		***********************************************************ELSE SORT BY USER****************************************************************************
		********************************************************************************************************************************************************
		********************************************************************************************************************************************************
		 --->
<CFELSE>
				<!--- Get data for the successful attempts (one user at a time) --->
		<CFQUERY name = "qLoginLogout" datasource="#Application.Datasource#">
				SELECT AUT.Audit_User_Transactions_ID, AUT.Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_By_User_ID,Trans_DateTime,_Users.Name_First, _Users.Name_Last,
				<cfif FORM.rdoOption NEQ "1">
				_u2.Name_First AS Trans_Name_First, _u2.Name_Last AS Trans_Name_Last,
				</cfif>
				Browser As Browser_Details,
				null as Trans_DateTimeLogout
				FROM Audit_User_Transactions  AUT
				INNER JOIN _Users
				<cfif (FORM.rdoOption EQ "9")>
				ON AUT.Trans_By_User_ID = _Users.User_ID
				<cfelse>
				ON (AUT.Trans_User_Code = _Users.User_Code OR AUT.Trans_User_Code = _Users.LDAP_User_Name)
				</cfif>
				<cfif FORM.rdoOption EQ "1">
				AND AUT.Trans_User_Code = <cfqueryparam value="#user_array[loopcount]#" cfsqltype="CF_SQL_VARCHAR">
				<cfelse>
				LEFT JOIN _Users _u2
				ON AUT.Trans_By_User_ID = _u2.User_ID
				</cfif>
				<CFIF isdefined("FORM.From_Date") AND FORM.From_Date NEQ "" AND FORM.To_Date NEQ "">
				WHERE
				(
				DateDiff(d, <cfqueryparam value="#CreateODBCDate(FORM.From_Date)#" cfsqltype="CF_SQL_DATE">, Trans_DateTime) >= 0
				AND
				DateDiff(d, Trans_DateTime, <cfqueryparam value="#CreateODBCDate(FORM.To_Date)#" cfsqltype="CF_SQL_DATE">) >= 0
				)
				<CFELSE>
				WHERE DateDiff(dd, AUT.Trans_DateTime, GetDate()) < <cfqueryparam value="#TrafficInfoDays#" cfsqltype="CF_SQL_INTEGER">
				</CFIF>
				<cfif (FORM.rdoOption EQ "1")>
				AND (AUT.Trans_Type = 'LOGON' OR AUT.Trans_Type = 'LOGOFF')
				<cfelseif (FORM.rdoOption EQ "2")>
				AND AUT.Trans_Type = 'LOCKED-OUT'
				<cfelseif (FORM.rdoOption EQ "3")>
				AND AUT.Trans_Type = 'UNLOCK-USER'
				<cfelseif (FORM.rdoOption EQ "4")>
				AND AUT.Trans_Type = 'PASSWORD-RESET' OR AUT.Trans_Type = 'PIN-RESET'
				<cfelseif (FORM.rdoOption EQ "5")>
				AND AUT.Trans_Type = 'PASSWORD-CHANGE'
				<cfelseif (FORM.rdoOption EQ "6")>
				AND AUT.Trans_Type = 'INACTIVATE-USER'
				<cfelseif (FORM.rdoOption EQ "7")>
				AND AUT.Trans_Type = 'ACTIVATE-USER'
				<cfelseif (FORM.rdoOption EQ "8")>
				AND AUT.Trans_Type = 'CREATE-USER'
				<cfelseif (FORM.rdoOption EQ "9")>
				AND AUT.Trans_Type = 'UNKNOWN-USER'
				</cfif>
				AND Trans_User_Code = <cfqueryparam value="#user_array[loopcount]#" cfsqltype="CF_SQL_VARCHAR">
				ORDER BY Trans_DateTime  <cfif (FORM.rdoOption EQ "1")>ASC<cfelse> DESC</cfif>
		</CFQUERY>

              <cfset qLogout = QueryNew("Audit_User_Transactions_ID2,Browser2,Browser_Details2,Trans_Type2,Trans_User_Code2,Trans_IP_Address2,Trans_DateTime2,Name_First2,Name_Last2,Trans_DateTimeLogout2") />
              <cfloop Query="qLoginLogout">

                 <cfset newRow = QueryAddRow(qLogout) />
                 <cfset QuerySetCell(qLogout, "Audit_User_Transactions_ID2", qLoginLogout.Audit_User_Transactions_ID )/>
		 <cfset QuerySetCell(qLogout, "Browser2", request.app_general_functions.getBrowserVersion(qLoginLogout.Browser_Details) )/>
		 <cfset QuerySetCell(qLogout, "Browser_Details2", qLoginLogout.Browser_Details )/>
                 <cfset QuerySetCell(qLogout, "Trans_Type2", qLoginLogout.Trans_Type )/>
                 <cfset QuerySetCell(qLogout, "Trans_User_Code2", qLoginLogout.Trans_User_Code)/>
                 <cfset QuerySetCell(qLogout, "Trans_IP_Address2", qLoginLogout.Trans_IP_Address )/>
                 <cfset QuerySetCell(qLogout, "Trans_DateTime2", qLoginLogout.Trans_DateTime)/>
                 <cfset QuerySetCell(qLogout, "Name_First2", qLoginLogout.Name_First)/>
                 <cfset QuerySetCell(qLogout, "Name_Last2", qLoginLogout.Name_Last)/>
               <!---   <cfset QuerySetCell(qLogout, "Trans_Name_First2", qLoginLogout.Trans_Name_First)/>
                 <cfset QuerySetCell(qLogout, "Trans_Name_Last2", qLoginLogout.Trans_Name_Last)/> --->
                 <cfset QuerySetCell(qLogout, "Trans_DateTimeLogout2", "" )/>
                </cfloop>

              <!--- Sort and make the login and logout pair as one record  --->
              <cfset aryLogPair = ArrayNew(2)>
              <cfset i = 1 />
              <cfif FORM.rdoOption EQ "1">

                <cfloop query="qLoginLogout" >
                  <cfif (qLoginLogout.Trans_Type EQ "LOGON")>
                    <cfset aryLogPair[i][1] =  qLoginLogout.Audit_User_Transactions_ID />
		    <cfset aryLogPair[i][2] =  request.app_general_functions.getBrowserVersion(qLoginLogout.Browser_Details) />
		    <cfset aryLogPair[i][3] =  qLoginLogout.Browser_Details />
                    <cfset aryLogPair[i][4] =  qLoginLogout.Trans_Type />
                    <cfset aryLogPair[i][5] =  qLoginLogout.Trans_User_Code />
                    <cfset aryLogPair[i][6] =  qLoginLogout.Trans_IP_Address />
                    <cfset aryLogPair[i][7] =  qLoginLogout.Trans_DateTime />
                    <cfset aryLogPair[i][8] =  qLoginLogout.Name_First />
                    <cfset aryLogPair[i][9] =  qLoginLogout.Name_Last />
                    <cfset aryLogPair[i][10] =  ""/>
                    <cfset aryLogPair[i][11] =  "" />
                    <cfset aryLogPair[i][12]= "" />

                    <cfloop query="qLogout">

                      <cfif (qLogout.Audit_User_Transactions_ID2 NEQ qLoginLogout.Audit_User_Transactions_ID)>
                        <cfif ((qLoginLogout.Trans_User_Code EQ qLogout.Trans_User_Code2) AND (qLogout.Trans_Type2 EQ "LOGOFF") AND ((DateCompare(qLoginLogout.Trans_DateTime,qLogout.Trans_DateTime2,"s") EQ -1)) AND (DateDiff('h',qLoginLogout.Trans_DateTime,qLogout.Trans_DateTime2) LT 24))>
                         <cfset current = #qLoginLogout.Trans_DateTime#>
                         <cfset aryLogPair[i][12] =  qLogout.Trans_DateTime2 />
						 <!--- this if is to check if your logout time in same day is less than next login in same day if not we are assigning empty value to array. --->
						 <cfset j = i-1>
						 <cfif j GT 1>
							 <cfif #aryLogPair[j][12]# GT #aryLogPair[i][7]#>
							 	 <cfset aryLogPair[j][12] = "">
							 </cfif>
						 </cfif>
								 <cfif dateDiff("d", left(qLoginLogout.Trans_DateTime, 10),left(qLogout.Trans_DateTime2, 10))>
								 	<cfset aryLogPair[i][11] = 1>
								 </cfif>
                         <cfbreak />
                        </cfif>
                      </cfif>
                    </cfloop>
                    <cfset i = i+1 />
                  </cfif>
                </cfloop>
<!--- Dev Note: drachala; D29000: traffic info same logout time issue  START
 Added/Changed: Added value 1 to aryLogPair[i][11] to identify user logout next day--->
              <cfscript>
              qLoginLogout2 = QueryNew("Audit_User_Transactions_ID,Browser,Browser_Details,Trans_Type,Trans_User_Code,Trans_IP_Address,Trans_DateTime,Name_First,Name_Last,Trans_Name_First,Trans_Name_Last,Trans_DateTimeLogout");
              for (i=1; i LTE ArrayLen(aryLogPair); i=i+1) {
                 newRow = QueryAddRow(qLoginLogout2);
                 QuerySetCell(qLoginLogout2, "Audit_User_Transactions_ID", #aryLogPair[i][1]# );
		 QuerySetCell(qLoginLogout2, "Browser", #aryLogPair[i][2]# );
                 QuerySetCell(qLoginLogout2, "Browser_Details", #aryLogPair[i][3]# );
		 QuerySetCell(qLoginLogout2, "Trans_Type", #aryLogPair[i][4]# );
                 QuerySetCell(qLoginLogout2, "Trans_User_Code", #aryLogPair[i][5]# );
                 QuerySetCell(qLoginLogout2, "Trans_IP_Address", #aryLogPair[i][6]# );
                 QuerySetCell(qLoginLogout2, "Trans_DateTime", #aryLogPair[i][7]# );
                 QuerySetCell(qLoginLogout2, "Name_First", #aryLogPair[i][8]# );
                 QuerySetCell(qLoginLogout2, "Name_Last", #aryLogPair[i][9]# );
                 /* QuerySetCell(qLoginLogout2, "Trans_Name_First", #aryLogPair[i][10]# );*/
                 QuerySetCell(qLoginLogout2, "Trans_Name_Last", #aryLogPair[i][11]# );
                 QuerySetCell(qLoginLogout2, "Trans_DateTimeLogout", #aryLogPair[i][12]# );
              }
              qLoginLogout = qLoginLogout2;
              </cfscript>
<!--- End Dev Note: drachala; D29000: traffic info same logout time issue  --->
           </cfif>

<cfif (qLoginLogout.recordcount GTE 1)>
	<TR>
		<TD>&nbsp;&nbsp;&nbsp;</TD>
	</TR>
	<TR>
		<TD colspan="100%">
		<DIV STYLE="border-bottom: 1px solid Orange; font: 14px;">
		<cfif (FORM.rdoOption EQ "9")>
		#user_array[loopcount]#&nbsp;&nbsp;(#qLoginLogout.recordcount#)
		<cfelse>
		#user_firstname[loopcount]#&nbsp;#user_lastname[loopcount]#&nbsp;&nbsp;(#qLoginLogout.recordcount#)
		</cfif>
		</DIV>
		</TD>
	</TR>
	<TR>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<TD NOWRAP STYLE="border-bottom: 1px solid Silver;" WIDTH="100">Date</TD>
		<cfif (FORM.rdoOption EQ "1")>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD >
		<TD NOWRAP STYLE="border-bottom: 1px solid Silver;" WIDTH="100">Browser/OS</TD>
		</cfif>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD >
		<TD NOWRAP STYLE="border-bottom: 1px solid Silver;" WIDTH="100"><cfif rdoOption EQ "1">Log In<cfelse>Time</cfif></TD >
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<cfif (FORM.rdoOption EQ "1")>
		<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="100">Log Off</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		</cfif>
		<TD NOWRAP STYLE="border-bottom: 1px solid Silver;" WIDTH="150">IP Address</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD >
		<cfif (FORM.rdoOption EQ "3")>
		<TD NOWRAP STYLE="border-bottom: 1px solid Silver;" WIDTH="150">User Unlocked By</TD>
		</cfif>
		<cfif (FORM.rdoOption EQ "4")>
		<TD nowrap style="border-bottom: 1px solid Silver;" WIDTH="150">Type</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD >
		<TD NOWRAP STYLE="border-bottom: 1px solid Silver;" WIDTH="150">Password/Pin Reset By</TD>
		</cfif>
		<cfif (FORM.rdoOption EQ "6")>
		<TD NOWRAP STYLE="border-bottom: 1px solid Silver;" WIDTH="150">User Inactivated By</TD>
		</cfif>
		<cfif (FORM.rdoOption EQ "7")>
		<TD NOWRAP STYLE="border-bottom: 1px solid Silver;" WIDTH="150">User Activated By</TD>
		</cfif>
		<cfif (FORM.rdoOption EQ "8")>
		<TD NOWRAP STYLE="border-bottom: 1px solid Silver;" WIDTH="150">User Created By</TD>
		</cfif>
		<TD width="80%">&nbsp;</TD>
	</TR>
<CFLOOP query="qLoginLogout">
	<TR>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<TD nowrap>#dateformat(qLoginLogout.Trans_DateTime,"mm/dd/yyyy")#</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<cfif (FORM.rdoOption EQ "1")>
		<TD nowrap title="#qLoginLogout.browser_details#">#request.app_general_functions.getBrowserVersion(qLoginLogout.Browser_Details)# &nbsp; /&nbsp; #request.app_general_functions.getOperatingSystem(qLoginLogout.Browser_Details)#</TD>
		</cfif>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<TD nowrap>#timeformat(qLoginLogout.Trans_DateTime,"hh:mm:ss tt")#</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		<cfif (FORM.rdoOption EQ "1")>
		<TD NOWRAP>
		<!--- Dev Note: drachala; D29000: traffic info same logout time issue  START
		Added/Changed: Modifed below TD--->
		<cfif len(timeformat(qLoginLogout.Trans_DateTimeLogout,"hh:mm:ss tt"))>
		#timeformat(qLoginLogout.Trans_DateTimeLogout,"hh:mm:ss tt")# <cfif len(qLoginLogout.Trans_Name_Last) AND qLoginLogout.Trans_Name_Last><font color="red">*</font></cfif>
		<cfelse>
		*User didn't logout properly*
		</cfif>
		<!--- End Dev Note: drachala; D29000: traffic info same logout time issue  --->
		</TD>
		<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
		</cfif>
		<TD nowrap>#qLoginLogout.Trans_IP_address#</TD>
		<cfif (FORM.rdoOption EQ "4")>
		<TD>&nbsp;</TD>
		<TD nowrap><cfif qLoginLogout.Trans_Type EQ "PASSWORD-RESET">Password<cfelseif qLoginLogout.Trans_Type EQ "PIN-RESET">Pin</cfif>  </TD>
		</cfif>
		<cfif ((FORM.rdoOption EQ "3") OR (FORM.rdoOption EQ "4") OR (FORM.rdoOption EQ "6") OR (FORM.rdoOption EQ "7") OR (FORM.rdoOption EQ "8"))>
		<TD width = "80">&nbsp;</TD >
		<TD nowrap>#qLoginLogout.Trans_Name_First# #qLoginLogout.Trans_Name_Last#</TD>
		</cfif>
		<TD>&nbsp;</TD>
	</TR>
</CFLOOP>

</cfif>
</cfif>
</cfloop>
</TABLE>
<!--- END --->
<cfif FORM.rdoOption EQ "1">
  <cfinclude template="traffic_unsuccessful_logon.cfm" />
</cfif>
</cfoutput>

<script>
    $("#Users").chosen();
</script>


</cfsavecontent>
<CFOUTPUT>#Display#</CFOUTPUT>
</body>
</html>
