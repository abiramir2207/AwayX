<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<title>Untitled Document</title>
</head>

<body onload="document.myform.searchfor.focus()">

<link rel="stylesheet" type="text/css" href="styles_global.css">
<link rel="stylesheet" type="text/css" href="styles_search.css">

<!--[if gte IE 9]>
  <style type="text/css">
	div.main_div {filter: none;}
  </style>
<![endif]-->	


<!--- validates the form to make sure at least one value has been entered in the search boxes --->
<script type="text/javascript">
function validateAdvSearch() 
{
	var f = document.forms[0];
	var num = f.elements.length;
	var j = 0;
	for (var i=0; i<num; i++) 
		{
			if (f.elements[i].type == 'checkbox') { if (f.elements[i].checked) {j = j+1; } }
			if (f.elements[i].type == 'text') { if (f.elements[i].value) { j = j+1; } }
			else { continue; }
		}
	if (j == 0) { alert('The search field must contain a value'); document.myform.searchfor.focus(); return false;}
}
</script> 
<!--- ----------------------------------------------------------------------------------------- --->


<div class="main_div">
<form action="search.cfm" method="post" name="myform" onsubmit="return validateAdvSearch(this)">

<img src="images/snapshots.png" width="532" height="121">

<table cellpadding="0" cellspacing="0" border="0" align="center">
		<tr>
		<td colspan="2">
		<div class="sub_section_title">Items to retrieve</div>
		<cfset spacer=75>
		<cfoutput>
		<input name="item_type_code" type="radio" value="1,2,3" checked> All Types<img src="images/clear.png" width="#spacer#" height="1">
		<input name="item_type_code" type="radio" value="1"> Operators<img src="images/clear.png" width="#spacer#" height="1">
		<input name="item_type_code" type="radio" value="2"> Distributors<img src="images/clear.png" width="#spacer#" height="1">
		<input name="item_type_code" type="radio" value="3"> Products
		</cfoutput>
		<br /><br />
	</tr>
	<tr>
		<td><input name="searchfor" type="text" class="search_field"></td>
		<td><input name="" type="submit" value="SEARCH SNAPSHOTS" class="search_button"></td>
	</tr>
	<tr>
		<td colspan="100%" align="left">
		</td>
	</tr>
</table>
<input name="date_period" type="hidden" value="2/1/2012">
</form>
</div>

</body>
</html>