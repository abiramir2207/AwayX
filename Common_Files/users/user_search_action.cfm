<CFPARAM NAME="URL.Company_Main_ID" DEFAULT="0">
<CFPARAM NAME="URL.Name_First" DEFAULT="0">
<CFPARAM NAME="URL.Name_Last" DEFAULT="0">
<CFPARAM NAME="URL.Name_Last_Criteria" DEFAULT="0">
<CFPARAM NAME="URL.NAC" DEFAULT="0">


<CFQUERY NAME="GetUsers" datasource="#application.datasource#" DBTYPE="ODBC">
		SELECT dbo.Company_Main.Company_Name, dbo._Users.*
		FROM dbo.Company_Main INNER JOIN
			 dbo._Users ON 
			 dbo.Company_Main.Company_Main_ID = dbo._Users.Company_Main_ID
		WHERE
			_Users.Deleted = 0
			<CFIF URL.Company_Main_ID NEQ "0">
				AND
				_Users.Company_Main_ID = '#URL.Company_Main_ID#'
			</CFIF>

			<CFIF URL.Name_Last NEQ "0" AND URL.Name_Last_Criteria NEQ "0">
				<CFSWITCH EXPRESSION="#URL.Name_Last_Criteria#">
					<CFCASE VALUE="contains">
						AND
						Name_Last LIKE '%#URL.Name_Last#%'
					</CFCASE>

					<CFCASE VALUE="begins with">
						AND
						Name_Last LIKE '#URL.Name_Last#%'
					</CFCASE>

					<CFCASE VALUE="ends with">
						AND
						Name_Last LIKE '%#URL.Name_Last#'
					</CFCASE>

					<CFCASE VALUE="is">
						AND
						Name_Last = '#URL.Name_Last#'
					</CFCASE>
				
				</CFSWITCH>
			
			</CFIF>
</CFQUERY>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Untitled</title>

	<SCRIPT>
		function editUser(User_ID) {
			parent.location.href = "user_summary.cfm?User_ID=" + User_ID
		}
		
		function changeBackgoundColor(rowObject) {
			alert(changeBackgoundColor)
		}

	</SCRIPT>
</head>

<body>
	<CFIF GetUsers.RecordCount EQ 0>
		<BR><BR><DIV ALIGN='center' STYLE='color: red; font-size: larger; font-weight: bolder;'>NO MATCHES</DIV>
	<CFELSE>
		<TABLE BORDERCOLOR="FFFFFF" bordercolorlight="#C0C0C0" bordercolordark="#FFFFFF" BORDER="1" CELLSPACING="0" CELLPADDING="3" STYLE="cursor: pointer">
		<CFOUTPUT QUERY="GetUsers">
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ccffcc'))#" ONCLICK="editUser('#GetUsers.User_ID#');" ONMOUSEOVER="this.bgColor = 'cccccc'" ONMOUSEOUT="this.bgColor = '#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ccffcc'))#'">
				<TD WIDTH="194" STYLE="color: Blue;">#Name_First# #Name_Last#</TD>
				<TD WIDTH ="273" STYLE="color: Blue;">#Company_Name#</TD>
			</TR>
		</CFOUTPUT>
		</TABLE>
	</CFIF>
	
</body>
</html>

