<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Blacksmith Applications Survey!</title>
</head>

<body onblur="self.focus();">
<STYLE>
	.txthdr {
		color:maroon;
		font-size:20px;
		font-family: Arial, Verdana;
		text-decoration: none;
		padding-bottom: 1em;
	}
	.txtmsg {
		color:black;
		font-size:15px;
		font-family: Arial, Verdana;
		text-decoration: none;
		padding: 1px;
	}
</STYLE>
<!--- <script>
/*
function askNever(){
	<cfset temp =  CreateObject("component", "components.survey.surveymanager").SurveyUserSaid("#request.AccessStructure.User_ID#", 2) />
	window.close('BlacksmithSurveyPopup');	
}
function askLater(){
	<cfset temp =  CreateObject("component", "components.survey.surveymanager").SurveyUserSaid("#request.AccessStructure.User_ID#", 0) />
	window.close('BlacksmithSurveyPopup');
}
function fillSurvey(){
	<cfset temp =  CreateObject("component", "components.survey.surveymanager").SurveyUserSaid("#request.AccessStructure.User_ID#", 1) />
	window.close('BlacksmithSurveyPopup');
	NewWindow('SurveyDisplay.cfm','BlacksmithSurveyDisplay','700','800','No', 'No');
		
}
*/
</script> --->
<cfif isDefined("URL.SurveyUserAns")>
	<cfif URL.SurveyUserAns EQ 0>
		<cfset temp =  CreateObject("component", "components.survey.surveymanager").SurveyUserSaid("#request.AccessStructure.User_ID#", 0) />
		<script>window.close('BlacksmithSurveyPopup');</script>
	<cfelseif URL.SurveyUserAns EQ 1>
		<script>
			window.close('BlacksmithSurveyPopup');
			NewWindow('SurveyDisplay.cfm','BlacksmithSurveyDisplay','700','800','No', 'No');
		</script>
	<cfelseif URL.SurveyUserAns EQ 2>
		<cfset temp =  CreateObject("component", "components.survey.surveymanager").SurveyUserSaid("#request.AccessStructure.User_ID#", 2) />
		<script>window.close('BlacksmithSurveyPopup');</script>		
	</cfif>
</cfif>
<table align="left" cellspacing="2" cellpadding="2" border="0" frame="vsides">
<tr align="left">
    <th colspan="2" class="txthdr">Your input is important to us.</th>
</tr>
<tr>
    <td colspan="2" class="txtmsg">We'd like your opinion on the Blacksmith application so that we can better serve you.</td>
</tr>
<tr>
    <td colspan="2" class="txtmsg">The survey will take about 15 minutes and will only be used for research purposes.</h5></td>
</tr>
<tr>
    <td align="center"><img src="/images/Blacksmith_logoPrimary.gif" align="middle" border="0" title="Blacksmith Applications"></td>
    <td align="center">
		<a href="SurveyAlert.cfm?SurveyUserAns=1" target="_self"><div align="left"><img src="/images/survey_yes2.gif" title="" border="0"></div></a>
		<a href="SurveyAlert.cfm?SurveyUserAns=0" target="_self"><div align="left"><img src="/images/survey_later2.gif" title="" border="0"></div></a>
		<a href="SurveyAlert.cfm?SurveyUserAns=2" target="_self"><div align="left"><img src="/images/survey_never2.gif" title="" border="0"></div></a>
	</td>
</tr>

</table>
</body>
</html>
