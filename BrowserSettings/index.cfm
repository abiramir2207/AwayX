<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<CFSET PAGE_TITLE="Browser Settings">
<html>
<head>
	<title><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">


<cfparam name="URL.PG" 	default="">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
<cfparam name="URL.PG" 	default="">
	<CFIF URL.PG EQ "2">
		<CFINCLUDE TEMPLATE="AdvancedTab.cfm">		
	<CFELSEIF URL.PG EQ "1">		
		<CFINCLUDE TEMPLATE="securityTab.cfm">
	<CFELSE>
		<CFINCLUDE TEMPLATE="about.cfm">
	</CFIF>	
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<!--- 
<iframe id="oIframe" src="index2.cfm"  style="position:relative; width:950; height:500; z-index:1" SCROLLING="No" allowTransparency="true"></iframe>
 --->
<CENTER>
<IFRAME SRC="index2.cfm" NAME="oIframe" ID="oIframe" WIDTH="950" HEIGHT="500" SCROLLING="yes" FRAMEBORDER="0"></IFRAME>
</CENTER>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


</BODY>

</html>
