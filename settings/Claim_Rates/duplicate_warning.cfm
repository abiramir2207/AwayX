<!-----------------------------------------------------------------------------

FILE NAME:		duplicate_warning.cfm
DESCRIPTION:		???
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	23-Oct-2014	Created 
							
------------------------------------------------------------------------------> 
<html>
<head>
	<title>Duplicate Warning!!!</title>
</head>

<body>
<cfoutput>
<center>
<br>
<br>

<strong>A duplicate Claim name '#URL.sName#' aleady exists!! Please select a different name.</strong>
</center><br>  
<br>
<br>

<div align="center">
<input type="button" value="Close" onclick="window.opener.location.href='list.cfm';window.close();" align="center">
</div>
 
</cfoutput>
<script>
    window.onunload = refreshParent;
    function refreshParent() {
       window.opener.location.href='list.cfm';
    }
</script>
</body>
</html>
<strong></strong>