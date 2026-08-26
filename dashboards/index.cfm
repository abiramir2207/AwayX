<!DOCTYPE HTML>
<html>
<head>


<!--- standard charset used by iPad ----------------------------------------------------------- --->
<meta charset="utf-8">

<!--- To indicate that the web application should run in full screen mode on the iPad --------- --->
<meta name = "apple-mobile-web-app-capable" content="yes" />

<!--- used to avoid mobile safari from looking at a 7 digit string as a phone number ---------- --->
<meta name = "format-detection" content = "telephone=no" />

<!--- the master style sheet used at this level ----------------------------------------------- --->
<link rel="stylesheet" type="text/css" href="_styles.css" />

<!--- get the correct terms from the db for this customer and convert them to local variables - --->
<cfinclude template="terminology.cfm">

<title>blacksmith applications :: dashboards</title>
</head>


<body>


<div align="center">

<!--- ----------------------------------------------------------------------------------------- --->
<div class="header gradient_fix"><cfinclude template="_header1.cfm"></div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="main_container"><cfinclude template="index_content.cfm"></div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="footer gradient_fix"><cfinclude template="_footer.cfm"></div>
<!--- ----------------------------------------------------------------------------------------- --->

</div>
</body>
</html>


