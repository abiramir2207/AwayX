<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<!--- ----------------------------------------------------------------------------------------- --->
<!--- This is the master file with all the settings ------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="appsettings.cfm">
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<link rel="stylesheet" type="text/css" href="styles.css">

<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<!--- To indicate that the web application should run in full screen mode on the iPad --------- --->
<meta name = "apple-mobile-web-app-capable" content="yes" />
<!--- used to avoid mobile safari from looking at a 7 digit string as a phone number ---------- --->
<meta name = "format-detection" content = "telephone=no" />

<title>blacksmith applications :: dashboards</title>
</head>

<body onload="document.myform.searchfor.focus()">

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




<!--- validates the form to make sure at least one value has been entered in the search boxes --->
<!--- add  onsubmit="return validateForm()" to the form tag --------------------------------- --->
<script type="text/javascript">
function validateForm()
{
var x=document.forms["myform"]["searchfor"].value;
if (x==null || x=="")
  {
  alert("The search field must contain a value");
  return false;
  }
}
</script> 
<!--- ----------------------------------------------------------------------------------------- --->



<style>

div.frame
{
	color:			#FFFFFF;
	font-weight:	bold;
	font-size:		16px;
	width:			75%;
	margin:			40px auto 40px auto;
	padding:		80px 20px 80px 20px;
	border:			0px #8400ff solid;
	text-align:		center;

}

div.frame_inner
{
	color:			#FFFFFF;
	font-weight:	bold;
	font-size:		16px;
	width:			75%;
	margin:			0px auto 0px auto;
	padding:		50px 20px 50px 20px;
	border:			0px #8400ff solid;
	text-align:		center;

background: #222222; /* Old browsers */
/* IE9 SVG, needs conditional override of 'filter' to 'none' */
background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iIzIyMjIyMiIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiM3Nzc3NzciIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
background: -moz-linear-gradient(top,  #222222 0%, #777777 100%); /* FF3.6+ */
background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#222222), color-stop(100%,#777777)); /* Chrome,Safari4+ */
background: -webkit-linear-gradient(top,  #222222 0%,#777777 100%); /* Chrome10+,Safari5.1+ */
background: -o-linear-gradient(top,  #222222 0%,#777777 100%); /* Opera 11.10+ */
background: -ms-linear-gradient(top,  #222222 0%,#777777 100%); /* IE10+ */
background: linear-gradient(to bottom,  #222222 0%,#777777 100%); /* W3C */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#222222', endColorstr='#777777',GradientType=0 ); /* IE6-8 */


}


input.search_field, input.search_button
{
	border:			0px #FFFFFF solid;
	padding:		3px 0px 3px 4px;
	font-size:		14px;
}


input.search_button
{
	color:			#FFFFFF;
	font-size:		12px;
	padding:		5px 5px 5px 5px;
}


</style>


<br />



<!--[if gte IE 9]>
  <style type="text/css">
    div.gradient_fix {filter: none;}
    input.gradient_fix {filter: none;}
  </style>
<![endif]-->

<div class="frame dark_gradient rounded_corners">


<div class="frame_inner dark_gradient">

<form action="search.cfm" method="post" name="myform" onsubmit="return validateForm()">
    <cfset spacer=75>
    <cfoutput>
    <input name="item_type_code" type="radio" value="1,2" checked> All Types<img src="images/clear.png" width="#spacer#" height="1">
    <input name="item_type_code" type="radio" value="1"> Operators<img src="images/clear.png" width="#spacer#" height="1">
    <input name="item_type_code" type="radio" value="2"> Distributors<img src="images/clear.png" width="#spacer#" height="1">
    <!--- <input name="item_type_code" type="radio" value="3"> Prod. Categories --->
    </cfoutput>

    <hr style="margin:20px 20px 20px 20px; color:#8400ff; background-color:#8400ff; height:1px; border:0;" />

    <input name="searchfor" type="text" class="search_field rounded_corners" autocorrect="off" autocapitalize="off">
    <br /><br />
    <input name="" type="submit" value="search snapshots" class="search_button rounded_corners dark_gradient gradient_fix">
    <br /><br />
    <input name="date_period" type="hidden" value="2/1/2012">
</form>


</div>

</div>








</div>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<div class="footer dark_gradient rounded_corners gradient_fix">
	<cfinclude template="_footer.cfm">
</div>
<!--- ----------------------------------------------------------------------------------------- --->

<style>




</style>



</body>
</html>

