<CFPARAM name="URL.ShowCid" default="0">
<cfif URL.ShowCid>
	<cfoutput>#URL.CID#</cfoutput>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
	<cfoutput>
		<cfset redirectURL = "#URL.DESTINATION#?CID=#URL.CID#&RO=1&RID=#createuuid()#&ShowVolumePage=1" />
		<cfif structKeyExists(url,"pop019") >
			<cfset redirectURL &= "&pop019=qualifications" />
		</cfif>
	</cfoutput>
	<SCRIPT>
		<CFOUTPUT> document.location.href = "#redirectURL#" </CFOUTPUT>
	</SCRIPT>

</body>
</html>
