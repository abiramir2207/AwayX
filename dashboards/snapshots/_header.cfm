<!--- ----------------------------------------------------------------------------------------- --->
<CFPARAM NAME="page_name" DEFAULT='No Data'>
<CFPARAM NAME="logo_name" DEFAULT='ios_logo2.png'>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->
<style type="text/css">

select
{
	font-size:		15px;
	width:			275px;
	margin:			0px 15px 0px 0px;
}
a.links
{
	margin: 0px 0px 0px 0px;
	padding: 3px 0px 3px 0px;
	border-bottom: 0px silver dotted;
}
</style>



<FORM NAME="go">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td valign="middle"><a href="../index.cfm"><img src="../images/box_purple.png" border="0" vspace="7" hspace="10" /></a></td>
        <td valign="middle" width="100%">
        <div class="header_page_name">Snapshots</div>
        </td>

		<td>&nbsp;</td>
    
        <td style="padding-right:15px;">
		<CFIF FindNoCase('ipad','#CGI.HTTP_USER_AGENT#') GREATER THAN 0 or FindNoCase('AppleWebKit','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>
		<a href="/logoff.cfm"><img src="../images/logoff2.png" border="0" /></a>
		</CFIF>
		</td>

    </tr>
</table>
</FORM>

<!--- ----------------------------------------------------------------------------------------- --->







