<!------bb_route.cfm----->

<CFPARAM NAME="URL.BBID"								DEFAULT="">
<CFSET Document_ID=URL.BBID>
<CFSET Route_Document_Type="1">

<CFSET Route_Inbox_URL						=	"bb_route_inbox.cfm?BBID=#Document_ID#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Billback</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<STYLE>

</STYLE>

<CFINCLUDE TEMPLATE="/Route/Route_Sent.cfm">


</BODY>
</HTML>

 