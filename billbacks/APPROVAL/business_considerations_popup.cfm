<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Disagree with Billback</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<cfparam name="txtaDisagreeReason" default="">
<cfparam name="BBID" default="">

<script language="JavaScript">
function verify()
{
	if(window.confirm("This billback will be reset to work in progress. Do you want to proceed?") == 0)
	{
		return false;
	}
	else
	{
		frmDisagreeReason.submit();
		opener.location='/billbacks/common/BB_Reset2.cfm?Billback_ID=<cfoutput>#BBID#</cfoutput>&resetBillback=1&IsBillbackApproved=0'
		self.close();
	}
}
</script>

<!--- Set the Disgreed comments --->
<cfif txtaDisagreeReason neq "">
	<cfquery name="setReason" datasource="#application.datasource#">
		UPDATE Billback
		SET BB_Disagree = 1,
			BB_Disagree_Date = GetDate(),
			BB_Disagree_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
			Comments = <cfqueryparam value="#txtaDisagreeReason#" cfsqltype="CF_SQL_LONGVARCHAR">
		WHERE Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
<cfelse>

<!--- Get the Disgreed comments --->
	<cfquery name="getReason" datasource="#application.datasource#">
		SELECT Comments 
		FROM Billback
		WHERE Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

<body>
	<form method="post" action="#cgi.SCRIPT_NAME#?BBID=#BBID#" name="frmDisagreeReason">
	<table align="center" border="0">
		<tr>
			<td valign="top" colspan="2" align="center"><STRONG>Business Considerations</STRONG></td> 	
		</tr>
	
		<tr>
			<td><textarea name="txtaDisagreeReason" cols="50" rows="10"><cfoutput>#getReason.Comments#</cfoutput></textarea></td> 
		</tr>	
		
		<tr>
			<td align="center">
				<b><span style="color:red;">[</span> 
					<a href="#" onclick="verify(); return false;">Save</a> 
				<span style="color:red;">]</span></b>
			</td>
		</tr>
		
	</table>
	</form>
</body>
</cfif>
</html>
