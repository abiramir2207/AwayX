<!--- ----------------------------------------------------------------------------------------- --->
<CFPARAM NAME="page_name" DEFAULT='dashboards'>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->

<style type="text/css">
a.links
{
	margin: 0px 0px 0px 0px;
	padding: 3px 0px 3px 0px;
	border-bottom: 0px silver dotted;
}
</style>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td valign="middle"><a href="index.cfm"><img src="images/logo3_small.png" border="0" vspace="3" hspace="10" /></a></td>
        <td valign="middle" width="100%"><div class="header_page_name"><cfoutput>#page_name#</cfoutput><cfinclude template="dollars_note.cfm"></td>
        
        <td style="padding-right:15px;"><a href="/logoff.cfm"><img src="images/logoff2.png" border="0" /></a></td>
    </tr>
</table>

<!--- ----------------------------------------------------------------------------------------- --->

<!--- math funtions used everywhere ----------------------------------------------------------- --->
<cfinclude template="udf_functions.cfm">
<!--- ----------------------------------------------------------------------------------------- --->
