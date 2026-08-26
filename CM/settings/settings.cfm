<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<!------ settings.cfm ----->
<style>
	.divHead
	{
		padding:1px;
	}
	.divLinks
	{
		padding:0px;
		padding-left:30px;
	}
</style>
<cfset handlerString = "/cm/handler.cfm?command=">
<CFOUTPUT>

<div class="divHead">
<h4>Activity</h4>
</div>
	<div class="divLinks">
	<a href="#handlerString#ceActivityTemplate">template</a><br>
	</div>

</CFOUTPUT>
</body>
</html>
