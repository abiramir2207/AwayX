<!------bb_route.cfm----->

<cfparam name="URL.Route_Document_Type" 	default=1>
<CFSET Route_Document_Type="#URL.Route_Document_Type#">
<CFINCLUDE TEMPLATE="Billback_Access.cfm">
<CFSET PAGE_TITLE=	"Inbox">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Billback</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<STYLE>

</STYLE>
<CFINCLUDE TEMPLATE="/includes/header.cfm">

<CFINCLUDE TEMPLATE="/Route/Route_Inbox.cfm">

<CFINCLUDE TEMPLATE="/includes/footer.cfm">

</BODY>
</HTML>

 