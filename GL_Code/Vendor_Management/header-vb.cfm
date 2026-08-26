<!---------------------------------------------------------------------------------------------------------------------
      Template: \GL_Code\Vendor_Management\header-vb.cfm
      Date:     2013 Aug
      Author:   Chris Nguyen
      Purpose:  Display tabs in the classic style

			Remarks:  
----------------------------------------------------------------------------------------------------------------------->
<cf_tabStyle
    selectedBgColor = "##FFE083"
        borderWidth = "2" >

<cfscript>
  headerMenu = [];
  ArrayAppend( headerMenu, {title=billBackLabels["Vendor"], action="", href="vendorBatching.cfm"} );
  ArrayAppend( headerMenu, {title=billBackLabels["Billback"], action="", href="billBackBatching.cfm"} );
  accrualStyle = "";
</cfscript>

<cfoutput>
<table border="0" cellspacing="0" cellpadding="1" width="100%">
<cfsetting enablecfoutputonly="true" >
<tr>
	<td class="headerspacer">&nbsp;</td>
	<cfloop from="1" to="#ArrayLen(headerMenu)#" index="counter">
		<cfset menuItem = headerMenu[counter]>
		<td class="<cfif cgi.script_name contains menuItem.href>headerselected <cfelse>headernotselected</cfif>" width="125" align="center" nowrap><a href="#menuItem.href#"><b>#menuItem.title#</b></a></td>
		<td class="headerspacer"><img src="/images/fill.gif" width="1" height="1"  alt=""></td>
	</cfloop>
	<td class="headerspacer" width="100%"><img src="/images/fill.gif" width="1" height="1" alt=""></td>
</tr>
<cfsetting enablecfoutputonly="false" >
</table>
</cfoutput>

