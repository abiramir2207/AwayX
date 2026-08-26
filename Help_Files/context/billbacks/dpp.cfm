
<!---
Document Name:	dpp.cfm
Directory:		/help_files/context/billbacks
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	December 19, 2002

Context sensitive help for billbacks 
--->

<html>
<head>
	<title><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Ratio</title>
</head>

<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0">

<table width="100%" height="100%" border="0" bgcolor="orange">
<tr><td align="Center" valign="center">

	<table width="99%" height="93%" bgcolor="white" border="0" valign="Center">
	<tr><td>
	<strong><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Ratio:</strong><br>
	This setting reflects the tolerance around the period a <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> has to make purchases.  The information is based on a ratio of the tolerance you set to the billback period.  For example, if you were to set a 1 to 1 ratio, then the only period that a <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> could purchase products and have them available to see if there is a volume deviation is the period between the billback start date and billback end date.  If you selected a 2 to 1 ratio, the period during which purchases could be made and accepted by the billback is twice as long as the billback period.
<p>
<div align="center"><img src="../images/dpp_ratio.gif"></div>
	</td></tr>
	</table>
</td></tr>
</table>

</body>
</html>
