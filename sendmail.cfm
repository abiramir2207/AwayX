<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#application.CompanyName#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="style.css">

<!---Gets correct "From" address--->
<cfinclude template="/get_Contact_Admin_Email_Address.cfm">
	
<SCRIPT>
<!--
function autoChange()
	{
		var timeID = setTimeout("location.href= 'logoff.cfm'", 5000)
	}
//-->
</SCRIPT>

</HEAD>

<BODY onLoad="autoChange();"  BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE><BLOCKQUOTE>
<BR><BR>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve the login and password that match the provided settings								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_User_Data" datasource="#application.datasource#">
Select		*
From		_Users
Where		Name_First		=	<cfqueryparam value="#form.name_first#" cfsqltype="CF_SQL_VARCHAR">
			and
			Name_Last		=	<cfqueryparam value="#form.name_last#" cfsqltype="CF_SQL_VARCHAR">
			and
			User_Email		=	<cfqueryparam value="#form.User_Email#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<CFIF 
	Get_User_Data.name_first NEQ form.name_first
	OR
	Get_User_Data.name_last NEQ form.name_last
	OR
	Get_User_Data.User_Email NEQ form.User_Email
	 >
<!--- <CFIF 
	Get_User_Data.User_Email NEQ form.User_Email
	 > --->


<TABLE border="0" cellspacing="0" cellpadding="0">
	<TR>
		<TD><A HREF="/index.htm"><IMG border="0" src="/images/logon_telus/TELUS_Trade_Promotion_Management_Logo.svg" height="14" BORDER="0"></A></TD>
		<TD width="100%">
			
			<FONT color="#21008C"><B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<CFLOOP INDEX="dots" FROM="1" TO="30">
				<CFOUTPUT>&nbsp;&nbsp; .</CFOUTPUT>
			</CFLOOP>
			</B></FONT>
		</TD>
	</TR>
	<TR>
		<TD>
			<P align="center"><FONT color="#21008C"><B><BR>
			.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>
			</B></FONT>
		</TD>
		<TD width="100%" valign="top"><BR><BR><BR><BR>
			<B>It does not appear that you have an account with us. Please contact <CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT>... </B>
		</TD>
	</TR>
</TABLE>


	<CFABORT>
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generate a new password and encode it															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <CFSET password=left(hash(createuuid()),10)> --->
	<!--- Login info --->
	<CFSET alphastring = "ABCDEFGHIJKLMNOPQRSTUVWXYZ">
	<cfset tempPassword ="">
	<CFLOOP INDEX="LoopCount" FROM="1" TO="10" STEP="1">
		<CFSET tempPassword=tempPassword&mid(alphastring, randrange(1, len(alphastring)), 1)>
	</CFLOOP>
	<CFSET password = tempPassword>
<CFSET hash=hash(password)>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Save new password to database																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Save_password" datasource="#application.datasource#">
UPDATE		_Users
SET 		User_Password = '#hash#'
WHERE		Name_First		=	<cfqueryparam value="#form.name_first#" cfsqltype="CF_SQL_VARCHAR">
			and
			Name_Last		=	<cfqueryparam value="#form.name_last#" cfsqltype="CF_SQL_VARCHAR">
			and
			User_Email		=	<cfqueryparam value="#form.User_Email#" cfsqltype="CF_SQL_VARCHAR">
			--and
			--Password_Answer	=	'<!--- #form.Password_Answer# --->'
</CFQUERY>


 
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send the password																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- <cfset password = hash(Get_User_Data.User_Password)> --->
<CFMAIL TO="#Get_User_Data.User_Email#"
	FROM="#Contact_Admin_Email_Address#"
	SUBJECT="Information"
	TYPE="HTML">
		Your new password is:&nbsp;&nbsp;&nbsp;<FONT COLOR="Red"><B>#password#</B></FONT><BR>
		It is CASE SENSISTIVE. Once you have logged in you may change your password.
</CFMAIL>


<TABLE border="0" cellspacing="0" cellpadding="0">
	<TR>
		<TD ROWSPAN="100%" WIDTH="100">&nbsp;</TD>
		<TD><A HREF="/index.htm"><IMG border="0" src="/images/logon_telus/TELUS_Trade_Promotion_Management_Logo.svg" height="14" BORDER="0"></A></TD>
		<TD class="mainpageDots">
			
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<CFLOOP INDEX="dots" FROM="1" TO="30">
				<CFOUTPUT>&nbsp;&nbsp; .</CFOUTPUT>
			</CFLOOP>			
		</TD>
	</TR>
	<TR>
		<TD class="mainpageDots">
			<P align="center"><BR>
			.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>.<BR>			
		</TD>
		<TD valign="top"><BR><BR><BR><BR>
			<B>Your information has been sent to you...</B>
		</TD>
	</TR>
</TABLE>




</BLOCKQUOTE></BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>

