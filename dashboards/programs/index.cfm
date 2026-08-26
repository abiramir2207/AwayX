<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<!--- ----------------------------------------------------------------------------------------- --->
<!--- This is the master file with all the settings ------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="appsettings.cfm">
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<link  href="styles.css" rel="stylesheet" type="text/css">
<link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<!--- To indicate that the web application should run in full screen mode on the iPad --------- --->
<meta name = "apple-mobile-web-app-capable" content="yes" />
<!--- used to avoid mobile safari from looking at a 7 digit string as a phone number ---------- --->
<meta name = "format-detection" content = "telephone=no" />

<script src="http://code.jquery.com/jquery-latest.min.js" type="text/javascript"></script>



<title>blacksmith applications :: dashboards</title>
</head>

<body>

<CFINCLUDE template="../terminology.cfm">



<!--[if gte IE 9]><style type="text/css">div.gradient_fix {filter: none;}</style><![endif]-->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="header dark_gradient rounded_corners gradient_fix">
	<cfinclude template="_header.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="main_container">
	<cfinclude template=#content#>
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="footer dark_gradient rounded_corners gradient_fix">
	<cfinclude template="_footer.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->


</body>
</html>

