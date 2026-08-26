<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Printer Friendly Billback View</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is the printer friendly page																 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfparam name="url.SHOW_PRINT_VERSION" default="0">
<CFPARAM NAME="URL.BBID"								DEFAULT="">
<CFSET Billback_ID=URL.BBID>
<cfset Print_Version = 1>
<cfif isDefined("URL.Referrer") AND URL.Referrer IS "Payment">
	<cfset ShowButtons="0">
	<cfset url.Billback_ID = Billback_ID>
	<CFSAVECONTENT VARIABLE="Billback.Summary_Content">
		<CFINCLUDE TEMPLATE="../approval/payment_display.cfm">
	</CFSAVECONTENT>
<cfelseif isDefined("URL.Referrer") AND URL.Referrer IS "Deviation">
	<cfset url.BBID = Billback_ID>
	<cfset url.SHOW_PRINT_VERSION = 1>
	<CFSAVECONTENT VARIABLE="Billback.Summary_Content">
		<CFINCLUDE TEMPLATE="/Billbacks/Deviation/Deviation.cfm">
	</CFSAVECONTENT>
<cfelse>
	<cfset url.SHOW_PRINT_VERSION = 1>
	<CFSAVECONTENT VARIABLE="Billback.Summary_Content">
		<CFINCLUDE TEMPLATE="../capture/Billback_Summary_Content.cfm">
	</CFSAVECONTENT>
</cfif> 
<!------ DEV NOTE DRK D9471 - removeforemail is a dummy tag in the summary content page 
so that we can remove this edit link on email/fax/print etc., please don't remove ----->
<cfset baseFunctions = CreateObject("component", "components.Base") />
<CFSET Billback.Summary_Content = baseFunctions.stripHTMLTag(Billback.Summary_Content, "script") />	
<CFSET Billback.Summary_Content = baseFunctions.stripHTMLTag(Billback.Summary_Content, "removeforemail") />

<CFOUTPUT>#Billback.Summary_Content#</CFOUTPUT>


<CFINCLUDE template="/Common_Files/Printer_Friendly_Script.cfm"> 
 

</BODY>
</HTML>

 