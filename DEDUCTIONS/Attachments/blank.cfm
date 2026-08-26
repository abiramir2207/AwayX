<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>OnBase Document Viewer</title>
	</head>
	<body>
		<cfparam name="url.loader" default="1" />
		<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
		    <tr>
		        <td style="text-align: center; vertical-align: middle;" width="100%" height="50%">
		        	<cfif url.loader eq 1>
						<h2 style="color:#800000;" width="100%" height="100%">Waiting for OnBase to Generate Document</h2><br>
						<img src="/Images/ajax-loader_red.gif" title="retrieving document from OnBase" align="center" />
					<cfelse>
						&nbsp;
					</cfif>
		        </td>
		    </tr>
		</table>
	</body>
</html>