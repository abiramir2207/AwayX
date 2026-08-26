<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<!--- ----------------------------------------------------------------------------------------- --->
<!--- This is the master file with all the settings ------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="appsettings.cfm">
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->


<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!--- To indicate that the web application should run in full screen mode on the iPad --------- --->
<meta name = "apple-mobile-web-app-capable" content="yes" />
<!--- used to avoid mobile safari from looking at a 7 digit string as a phone number ---------- --->
<meta name = "format-detection" content = "telephone=no" />


<title>blacksmith applications :: dashboards</title>
</head>

<body>

<div align="center">


<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="_header.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="main_container">
	<div style="width:925px; padding:10px 10px 10px 10px;">
		<cfinclude template=#content#>
	</div>
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="_footer.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

</div>


</body>
</html>

