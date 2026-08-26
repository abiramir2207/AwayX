<!DOCTYPE HTML>
<html lang="en">
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8">
  <cfparam name="url.title" default="">
  <cfoutput><title>#url.title#&nbsp;</title></cfoutput>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
</head>

<body>
<cfif fileExists(url.file)>
  <cffile action = "read"
      file = "#url.file#"
      variable = "Message">
<cfelse>
  <cfoutput><cfset Message = "An unexpected event has occurred, please try again later.<br><br>"></cfoutput>
</cfif>

<cfoutput><!--- #application.util.string.compress(Message)# --->
#Message#
<br><a href="##" onclick="javascript:window.close();" >#application.util.string.actionLinkFormat("close window")#</a>
</cfoutput>
</body>
</html>


