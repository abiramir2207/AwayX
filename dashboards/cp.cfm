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
<link rel="stylesheet" type="text/css" href="_iPhone_buttons_styles.css"/>

<!--- get the correct terms from the db for this customer and convert them to local variables - --->
<cfinclude template="terminology.cfm">

<title>blacksmith applications :: dashboards</title>
</head>

<body>
<div align="center">

<!--- ----------------------------------------------------------------------------------------- --->
<div class="header"><cfinclude template="_header1.cfm"></div>
<!--- ----------------------------------------------------------------------------------------- --->

<div class="main_container"><cfinclude template="cp_content.cfm"></div>

<!--- ----------------------------------------------------------------------------------------- --->
<div class="footer"><cfinclude template="_footer.cfm"></div>
<!--- ----------------------------------------------------------------------------------------- --->

</div>
</body>
</html>


