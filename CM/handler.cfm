
<html>
<head>
<script language="JavaScript" src="common/javascript/common.js"></script>

<title>Call Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="/cm/common/style/cm.css" rel="stylesheet" type="text/css" />
</head>

<cfparam name="url.command" default="ceCampaign" />
<cfparam name="form.command" default="#url.command#" />

<!---global variable for which handler to use--->
<cfset cmHandler = "handler.cfm" />
<cfinclude template="common/udf/common.cfm" />
<body>
<SCRIPT language=JavaScript1.2 src="/common_files/scripts/demenu.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language=JavaScript1.2 src="/cm/common/javascript/layer_selectboxes.js"></SCRIPT>

<!------ 
ce = create edit
sv = save
s  = search
sp  = search pick list
qp = quick profile
dp = detail profile
 ----->

<!---switch case for command--->
<!---each case statement has a commandSuffix variable that's used in each module--->
<cfswitch expression="#form.command#">

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// Activity section ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
	
	<!------ Activity ----->
	<cfcase value="ceActivityTemplate" delimiters=",">
		<cfset commandSuffix = "Activity">
		<cfinclude template="activity/handler.cfm" />
	</cfcase>
	
	<!------ Campaign ----->
	<cfcase value="ceCampaign,svCampaign,sCampaign" delimiters=",">
		<cfset commandSuffix = "Campaign">
		<cfinclude template="campaign/handler.cfm" />
	</cfcase>	
	
</cfswitch>	
<script language="JavaScript">
	findselectboxes();
</script>
</body>
</html>
