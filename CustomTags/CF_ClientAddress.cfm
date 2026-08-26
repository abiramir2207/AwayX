<!---

Client Address Identification Custom Tag
Written by Nemrod Kedem, rudy@home.co.il
Chief Israeli Communication Systems Ltd.
----------------------------------------
This Custom tag allows you to identify Client IP address
even if the client is using a Proxy server to access your site.

The tag returns three variables:

  CLIENT_ADDRESS   - The REAL IP Address of the client.

  CLIENT_PROXYADDR - The IP Address of the proxy server used,
                     or N/A if not available.

  CLIENT_PROXYNAME - The name of the Proxy server used,
                     or N/A if not available.
  					 
If the client is using Proxy server, the CLIENT_PROXY_ADDR will be
the same as the REMOTE_ADDR variable. If not using a Proxy server,
the CLIENT_ADDRESS will be the same as REMOTE_ADDR variable.

To use this tag, place this file (CF_ClientAddress.cfm) in the
CFUSION/CUSTOMTAGS directory, and see the ClientTest.cfm file
for example of the Custon Tag usage.

This Custom Tag was tested on IIS 3.0 server with Squid Proxy server.
Other Proxy servers may have different variables for the 
HTTP_X_FORWARDED_FOR and HTTP_VIA variables below.

// --->

<CFSET outvar1 = "caller.CLIENT_ADDRESS">
<CFSET outvar2 = "caller.CLIENT_PROXYADDR">
<CFSET outvar3 = "caller.CLIENT_PROXYNAME">

<CFIF #ParameterExists(HTTP_X_FORWARDED_FOR)# is "Yes">
  <CFSET result = SetVariable(outvar1, "#HTTP_X_FORWARDED_FOR#")>
  <CFSET result = SetVariable(outvar2, "#REMOTE_ADDR#")>
  <CFSET result = SetVariable(outvar3, "#HTTP_VIA#")>
<CFELSE>
  <CFSET result = SetVariable(outvar1, "#REMOTE_ADDR#")>
  <CFSET result = SetVariable(outvar2, "N/A")>
  <CFSET result = SetVariable(outvar3, "N/A")>
</CFIF>
