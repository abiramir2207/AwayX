
<!--- ----------------------------------------------------------------------------------------- --->
<div class="header gradient_fix">

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
        <td valign="middle"><a href="/dashboards/index.cfm"><img src="../images/box_green.png" border="0" vspace="10" hspace="10" /></a></td>
        <td valign="middle" width="100%">
            <div class="header_page_name">
                <cfoutput>#page_name#</cfoutput> 
                
                <cfif uom NEQ "">
                	(<cfoutput>#uom#</cfoutput>)
				<cfelse>
                	&nbsp;
				</cfif>


				        	
				<BR />
				<span class="backtoportal">
				<a href="../index.cfm" style="color: #FFCC00;">
				[&nbsp;back to dashboard portal&nbsp;]
				</a>
				</span>
		



                <cfif cgi.SERVER_NAME EQ "127.0.0.1" OR cgi.SERVER_NAME EQ "10.2.4.42"> - <cfoutput>#content#</cfoutput></cfif>
            </div>
        </td>

        <td style="padding-right:15px;">
		<CFIF FindNoCase('ipad','#CGI.HTTP_USER_AGENT#') GREATER THAN 0 or FindNoCase('AppleWebKit','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>
		<a href="/logoff.cfm"><img src="images/logoff2.png" border="0" /></a>
		</CFIF>
        
		

        
		</td>

    </tr>
</table>

</div>
<!--- ----------------------------------------------------------------------------------------- --->
