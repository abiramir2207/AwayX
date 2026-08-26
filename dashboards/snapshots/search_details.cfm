<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">


<!--- To indicate that the web application should run in full screen mode on the iPad --------- --->
<meta name = "apple-mobile-web-app-capable" content="yes" />
<!--- used to avoid mobile safari from looking at a 7 digit string as a phone number ---------- --->
<meta name = "format-detection" content = "telephone=no" />



<title>Snapshots :: Details</title>
</head>

<body>

<link rel="stylesheet" type="text/css" href="styles.css">
<cfinclude template="appsettings.cfm">



<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
    input.gradient_fix {filter: none;}
  </style>
<![endif]-->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="header dark_gradient rounded_corners gradient_fix">
	<cfinclude template="_header.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->




<!--- ----------------------------------------------------------------------------------------- --->
<div class="main_container">




<!--- redirect the flow to the correct item: operator, distributor or product --->
<cfswitch expression="#url.item_type_code#">
    <cfcase value="1">
		<cfset #color#=oper_color>
        <cfset logo = "images/operators.png">
        <cfinclude template="index_operators.cfm">
    </cfcase>
    <cfcase value="2">
		<cfset #color#=dist_color>
        <cfset logo = "images/distributors.png">
        <cfinclude template="index_distributors.cfm">
    </cfcase>
    <cfdefaultcase>
        &nbsp;
    </cfdefaultcase>
</cfswitch>


</div>
<!--- ----------------------------------------------------------------------------------------- --->




<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
  </style>
<![endif]-->

<!--- ----------------------------------------------------------------------------------------- --->
<div class="footer dark_gradient rounded_corners gradient_fix">
	<cfinclude template="_footer.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->

</body>
</html>




