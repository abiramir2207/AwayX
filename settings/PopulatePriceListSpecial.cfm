<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>Price List Special Admin</title>
	</head>
<cfscript>
	cfcAttrsPath = 'priceListSpecialTable';
</cfscript>
<cfparam name="URL.run" default="0">
	<cfif URL.run EQ 1>
		<cfset start = now() />
		<CFQUERY  dataSource="#application.datasource#" NAME="execPopulatePriceListSpecial">
			Exec Populate_Price_list_Special_Caller
		</cfquery>
		<cfset end = now() />
	<cfelse>
		<cfoutput><a href="populatePriceListSpecial.cfm?run=1">#application.util.string.actionLinkFormat( action="Refresh Price List" )#</a></cfoutput>
	</cfif>
	<body>
		Updated By: <cfoutput>#request.accessStructure.name_First# #request.accessStructure.name_last#</cfoutput>
	<table width="100%" border="0" cellspacing="5">
	    <tr>
	        <td><cfif URL.run EQ 1>
	        	<table width="200" border="0">
				    <tr>
				        <td>Start:</td>
				        <td><cfoutput>#start#</cfoutput></td>
				    </tr>
				    <tr>
				        <td>End:</td>
				        <td><cfoutput>#end#</cfoutput></td>
				    </tr>
				</table>
				</cfif>
	        </td>
	    </tr>
	    <tr>
	        <td>
	        	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
				<cfinclude template="\mvc\Views\dataTable.cfm" >
	        </td>
	    </tr>
	</table>	
	</body>
</html>