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


span.backtoportal
{
	font-size:		10px;
	text-transform: uppercase;
}

</style>


<FORM NAME="go">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td valign="middle"><a href="../index.cfm"><img src="../images/box_red.png" border="0" vspace="10" hspace="10" /></a></td>
        <td valign="middle" width="100%"><div class="header_page_name" style="text-transform:capitalize;"><cfoutput>#page_name#</cfoutput>

		<BR />
		<span class="backtoportal">
		<a href="../index.cfm" style="color: #FFCC00;">
		[&nbsp;back to dashboard portal&nbsp;]
		</a>
		</span>

		<cfif cgi.SERVER_NAME EQ "127.0.0.1" OR cgi.SERVER_NAME EQ "10.2.4.42"> - <cfoutput>#content#</cfoutput></cfif>

        </div>

        </td>

		<td>
			
			<!--- ----------------------------------------------------------------------------------------- --->
			<!--- comment/uncomment to hide/show the info button --->
			<!--- ----------------------------------------------------------------------------------------- --->

<!--- 
            <style>            
            #overlay             
            {            
            	z-index:			1000;		
            	position:			absolute;

            	top:				20%;		
            	right:				20%;            
            	bottom:				20%;		
            	left:				20%;            

            	width:				55%;			
            	height:				60%;            

            	padding:			20px 20px 20px 20px;											
	           	
	           	color: 				#FFFFFF;		
	           	background-color:	#333333;

				-webkit-box-shadow: 0 0 6px 4px #000000;
				box-shadow:			0 0 6px 4px #000000;

				-webkit-border-radius:	8px 8px 8px 8px;
				border-radius: 			8px 8px 8px 8px;
	           	            
            	opacity:			0.95;		
            	-moz-opacity:		0.95;			
            	filter:				alpha(opacity=95);            
            	visibility:			hidden;		
            	text-align:			left;			
            	
            	overflow-y:			auto;            
            }
            hr
            {
            	color: 				#FFFF00;
            	background-color: 	#FFFF00;
            	height: 			2px;
            	border:				0px #FFFF00 solid;
            }             
            </style>            
            
            <script type="text/javascript">            
            function showOverlay() {            
            var o = document.getElementById('overlay');            
            o.style.visibility = 'visible';            
            }            
            function hideOverlay() {            
            var o = document.getElementById('overlay');            
            o.style.visibility = 'hidden';            
            }            
            </script>             

			
			<a href="javascript:showOverlay();"><img src="../images/info.png"></a>    
			
            <div id="overlay">
            	<div style="text-align:right"><a href="javascript:hideOverlay();" style="color:#ffff00;">[close this window]</a></div>
            	<hr>
            	<br/>
            	<span style="color:#ffff00; font-size:14px; text-transform:capitalize; margin:10px 0px 10px 0px;"><cfoutput>#page_name#<br/>Dashboard Information</cfoutput><br/><br/></span>
            	<cfinclude template="#info_name#">
            	<hr>
            	<div style="text-align:right"><a href="javascript:hideOverlay();" style="color:#ffff00;">[close this window]</a><br/><br/></div>
            </div>
            
 --->                     
            
			
			
			
			
			
			
			
			
			
			
			
			
		</td>
    
        <td style="padding-right:15px;">
		<CFIF FindNoCase('ipad','#CGI.HTTP_USER_AGENT#') GREATER THAN 0 or FindNoCase('AppleWebKit','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>
		<a href="/logoff.cfm"><img src="images/logoff2.png" border="0" /></a>
		</CFIF>
		</td>


    </tr>
</table>
</FORM>



<!--- ----------------------------------------------------------------------------------------- --->







