
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" type="text/css" href="/common_files/contracts/subModal/style.css" />
<title>Edit <cfoutput>#Ucase(left(appsettings.getPullbackLabel(),1))##replace(appsettings.getPullbackLabel(),left(appsettings.getPullbackLabel(),1),"",1)# </cfoutput> Rates?</title>
<style type="text/css">
<!--
input.btn{
   color:#050;
   font-family:'trebuchet ms',helvetica,sans-serif;
   font-size:110%;
   font-weight:bold;
   background-color:#fed;
   border:1px solid;
   border-top-color:#696;
   border-left-color:#696;
   border-right-color:#363;
   border-bottom-color:#363;
   filter:progid:DXImageTransform.Microsoft.Gradient
      (GradientType=0,StartColorStr='#ffffffff',EndColorStr='#ffeeddaa');}

-->
</style>
</head>

<script>
function returnChoice(theChoice)
{
  var x = theChoice;
 // window.returnValue = x;
 // parent.document.all.showPullbacks = x;
  parent.editClawbacks(x);
  parent.hidePopWin('false');
}
function loader()
{
 window.returnValue = -1;
 window.top.showPullbacks = -1;
}
</script>
<body bgcolor="#CCCCCC" onload="loader();">

<form action="" method="post">
<table width="200" border="0" cellspacing="6" cellpadding="6" align="center">
  <tr>
  	<cfoutput>
    <td align="center"><input class="btn" name="Edit" type="button" value="Edit #Ucase(left(appsettings.getPullbackLabel(),1))##replace(appsettings.getPullbackLabel(),left(appsettings.getPullbackLabel(),1),"",1)# Rates"  onclick="returnChoice(1)" /></td>
  </tr>
  <tr>
	<td align="center"><input class="btn" name="Accept_Defaults" type="button" value="Accept Current #Ucase(left(appsettings.getPullbackLabel(),1))##replace(appsettings.getPullbackLabel(),left(appsettings.getPullbackLabel(),1),"",1)# Rates and Continue" onclick="returnChoice(0)" /></td>
	</cfoutput>
  </tr>
 
</table>
</form>
</body>
</html>
