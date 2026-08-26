<cfsetting enablecfoutputonly="Yes">
<!------ index_toc_section.cfm ----->
<cfparam name="attributes.url" 	default="">
<cfparam name="attributes.image" 	default="">
<cfparam name="attributes.text" 	default="">
<cfparam name="attributes.last" 	default="0">
<cfparam name="attributes.enabled" 	default="1">
<cfparam name="attributes.parameters" 	default="">
<cfparam name="attributes.showDataExist" 	default="false">

<cfset imgLeft = "/Images/Futures_Pricing/left_link.gif">
<cfif attributes.last>
	<cfset imgLeft = "/Images/Futures_Pricing/bottom_corner.gif">
</cfif>
<cfoutput>
<TR>
	<TD><IMG BORDER="0" SRC="#imgLeft#" WIDTH="25" HEIGHT="28"></TD>
	<TD>
	<cfif attributes.enabled><A HREF="#attributes.url#" TARGET="right" #attributes.parameters#></cfif><IMG BORDER="0" SRC="#attributes.image#" WIDTH="25" HEIGHT="23"><cfif attributes.enabled></A></cfif>
	<TD WIDTH="100%">
	<cfif attributes.enabled><A TARGET="right" HREF="#attributes.url#" CLASS="toc" #attributes.parameters#></cfif><B>#LCase(attributes.text)#</B><cfif attributes.enabled></A></cfif>
	<cfif attributes.showDataExist><sup><font color="red" size="4">*</font></sup></cfif></TD>
</TR>
</cfoutput>
<cfsetting enablecfoutputonly="No">