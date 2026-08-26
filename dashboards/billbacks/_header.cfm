<!--- ----------------------------------------------------------------------------------------- --->

<CFPARAM NAME="period" DEFAULT='0'>

<cfif period EQ 3>
	<CFPARAM NAME="page_name" DEFAULT='billbacks: Monthly Summary'>	
<cfelseif period EQ 5>
	<CFPARAM NAME="page_name" DEFAULT='billbacks: Yearly Summary'>	
<cfelseif period EQ 4>
	<CFPARAM NAME="page_name" DEFAULT='billbacks: Quarterly Summary'>	
<cfelse>
	<CFPARAM NAME="page_name" DEFAULT='billbacks'>
</cfif>



<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->

<style type="text/css">
a.links
{
	margin: 0px 0px 0px 0px;
	padding: 3px 0px 3px 0px;
	border-bottom: 0px silver dotted;
}




span.backtoportal
{
	font-size:		10px;
	text-transform: uppercase;
}




</style>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td valign="middle"><a href="/dashboards/index.cfm"><img src="../images/box_blue.png" border="0" vspace="10" hspace="10" /></a></td>
        <td valign="middle" width="100%"><div class="header_page_name"><cfoutput>#page_name#</cfoutput><cfinclude template="/dashboards/dollars_note.cfm">
        	
		<BR />
		<span class="backtoportal">
		<a href="../index.cfm" style="color: #FFCC00;">
		[&nbsp;back to dashboard portal&nbsp;]
		</a>
		</span>

        	
        	
        	
        </td>
        <td style="padding-right:15px;">
		<CFIF FindNoCase('ipad','#CGI.HTTP_USER_AGENT#') GREATER THAN 0 or FindNoCase('AppleWebKit','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>
		<a href="/logoff.cfm"><img src="images/logoff2.png" border="0" /></a>
		</CFIF>
		</td>

    </tr>
</table>

<!--- ----------------------------------------------------------------------------------------- --->

<!--- math funtions used everywhere ----------------------------------------------------------- --->
<cfinclude template="/dashboards/udf_functions.cfm">
<!--- ----------------------------------------------------------------------------------------- --->



