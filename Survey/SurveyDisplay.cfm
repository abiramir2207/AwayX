<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Blacksmith Application Survey!</title>
</head>
<cfset temp =  CreateObject("component", "components.survey.surveymanager").SurveyUserSaid("#request.AccessStructure.User_ID#", 1) />
<cfset SurveyURL =  CreateObject("component", "components.survey.surveymanager").getSurveyURL() />
<body onblur="self.focus();">
<iframe src ="<cfoutput>#SurveyURL#</cfoutput>" width="100%" height="100%"></iframe>

</body>
</html>
