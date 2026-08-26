<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">

<!--- To indicate that the web application should run in full screen mode on the iPad --------- --->
<meta name = "apple-mobile-web-app-capable" content="yes" />
<!--- used to avoid mobile safari from looking at a 7 digit string as a phone number ---------- --->
<meta name = "format-detection" content = "telephone=no" />
<!--- the style sheet used everywhere --------------------------------------------------------- --->
<link rel="stylesheet" type="text/css" href="_styles.css"/>
<!--- get the correct terms from the db for this customer and convert them to local variables - --->
<cfinclude template="/dashboards/terminology.cfm">

<title>blacksmith applications :: dashboards</title>
</head>

<body>
<div align="center">


<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
  </style>
<![endif]-->


<!--- ----------------------------------------------------------------------------------------- --->
<div class="header gradient_fix"><cfinclude template="_header.cfm"></div>
<!--- ----------------------------------------------------------------------------------------- --->

<div class="main_container"><cfinclude template="bb_summary_data_period_content.cfm"></div>

<!--- ----------------------------------------------------------------------------------------- --->
<div class="footer gradient_fix"><cfinclude template="_footer.cfm"></div>
<!--- ----------------------------------------------------------------------------------------- --->

</div>
</body>
</html>


