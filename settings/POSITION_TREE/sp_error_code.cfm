<cfparam name="spError.message" default="">
<cfparam name="spError.number" default="">
<cfif len(trim(spError.number)) EQ 0>
	<cfset spError.number = 0>
</cfif>

<cfif spError.number NEQ 0>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<BODY BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">


<cfoutput>
<div align="center" style="color: black; font-weight:bold;">
The error was encountered: <BR><BR><span style="color: red;">#UCASE(spError.message)#</span><BR><BR>
<cfswitch expression="#spError.number#">
	<cfcase value="2">
		Please confirm that neither the NAME or NUMBER of alreadys exists for the item you are adding.<BR>
	</cfcase>
	
	<cfdefaultcase>
		No Specifics Available.
	</cfdefaultcase>
</cfswitch>
</cfoutput>
<BR>
<a style="cursor: pointer;" onclick="history.back(1)">click here to return to the previous page</a>

</div>

</body>
</html>
<cfflush>
<cfabort>
</cfif>
