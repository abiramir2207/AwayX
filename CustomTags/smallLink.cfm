<!--- 
    two rendering methods available:
        1. classic (default) - utilizes many elements: span, font, b
        2. modern - minimized # of elements and call function defined application.util object 
--->
<cfparam name="request.style" default="classic">

<cfsetting enablecfoutputonly="No">
<!------ smallLink.cfm ----->
<!------ 
This is how u make it a link for search products
<CF_smallLink 
	title = "get products" 
	url = "##"
	parameters = "onClick=""javascript: return showProductSearchWindow('dataForm');"""
>
 ----->
 
<cfparam name="attributes.title" 	default="">
<cfparam name="attributes.url" 	default="">
<cfparam name="attributes.parameters" 	default="">
<cfparam name="attributes.outerTextColor" 	default="##FF0000">
<cfparam name="attributes.innerTextColor" 	default="##0000FF">
<cfparam name="attributes.enabled" 	default="1">
<cfparam name="attributes.disabledInnerTextColor" 	default="gray">
<cfparam name="attributes.hide" default="0">
<cfparam name="attributes.LinkName" default="">
<cfparam name="attributes.mouseovernotes" default="">

<cfoutput>
<cfif request.style is "classic">
    <span id ="#attributes.LinkName#" <cfif attributes.hide eq 1>style="visibility:hidden";</cfif>><FONT COLOR="#attributes.outerTextColor#"><B>[ </B></FONT>
    <cfif attributes.enabled OR attributes.Hide eq 1>
        <A HREF="#attributes.url#"  STYLE="COLOR:#attributes.innerTextColor#; "#attributes.parameters# title="#attributes.mouseovernotes#"><B>#attributes.title#</B></A>
    <cfelse>
        <B style="color:#attributes.disabledInnerTextColor#" #attributes.parameters#>#attributes.title#</B>
    </cfif>
        <FONT COLOR="#attributes.outerTextColor#"><B> ]</B></FONT></span>
<cfelse>
    <A <cfif attributes.mouseovernotes neq ''>
            HREF="#attributes.url#"
        </cfif>
        
        <cfif attributes.hide eq 1>style="visibility:hidden";</cfif>
        #attributes.parameters#
        <cfif attributes.mouseovernotes neq ''>
            title="#attributes.mouseovernotes#">
        </cfif>
        >
        #application.util.string.linkFormat( attributes.title )#
    </A>
</cfif>
</cfoutput>
<cfsetting enablecfoutputonly="No">