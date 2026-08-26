
<cfset This.name = "#hash( ExpandPath( "/" ) )#">
<cfset This.clientManagement ="yes">
<cfset This.clientStorage = "cookie">
<cfset This.setDomainCookies = "no">
<cfset This.sessionManagement ="yes">
<cfset This.setClientCookies = "yes">
<cfset This.sessionTimeout = "#createtimespan(0,10,0,0)#">
<cfset This.applicationTimeout ="#createtimespan(5,0,0,0)#">

