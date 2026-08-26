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
		var timeID = setTimeout("location.href= 'logoff.cfm'", 2000)
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
Where		--Name_First		=	'<!--- #form.name_first# --->'
			--and
			--Name_Last		=	'<!--- #form.name_last# --->'
			--and
			User_Email		=	'#form.User_Email#'
</CFQUERY>

<!--- <CFIF 
	Get_User_Data.name_first NEQ form.name_first
	OR
	Get_User_Data.name_last NEQ form.name_last
	OR
	Get_User_Data.User_Email NEQ form.User_Email
	OR
	Get_User_Data.Password_Answer NEQ form.Password_Answer
	 >
 --->
<CFIF 
	Get_User_Data.User_Email NEQ form.User_Email
	 >
		<CENTER>
		<H3>It does appear that you have an account with us. Please contact <CFOUTPUT>#application.CompanyNameFull#</CFOUTPUT>... </H3>
		</CENTER>
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
WHERE		--Name_First		=	'<!--- #form.name_first# --->'
			--and
			--Name_Last		=	'<!--- #form.name_last# --->'
			--and
			User_Email		=	'#form.User_Email#'
			--and
			--Password_Answer	=	'<!--- #form.Password_Answer# --->'
</CFQUERY>

<!---
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Send the login																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFMAIL TO="#Get_User_Data.User_Email#"
	FROM="awayx@awayx.com"
	SUBJECT="Information"
	SERVER="smtp.clipboardsolutions.com"
	TYPE="HTML">
		Your login is:&nbsp;&nbsp;&nbsp;<FONT COLOR="Red"><B>#Get_User_Data.User_Code#</B></FONT>
</CFMAIL>
 --->
 
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

<CENTER>
<H2>Your information has been sent to you...</H2>		
</CENTER>


</BLOCKQUOTE></BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>

