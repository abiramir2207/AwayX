<!---------------------------------------------------------------------------------------------------------------------
      Template: \GL_Code\Vendor_Management\header.cfm
      Date:     October 25, 2011
      Author:   Dinesh Rachala
      Purpose:  Vendor Management - Control Panel Settings
----------------------------------------------------------------------------------------------------------------------->
<cf_tabStyle
    selectedBgColor = "##FFE083"
        borderWidth = "2" >

<cfscript>
  headerMenu = [];
  ArrayAppend( headerMenu, {title="Vendor Xref ", action="listvendorxref"} );
  ArrayAppend( headerMenu, {title="Vendor Master", action="listvendormaster"} );
  accrualStyle = "";
</cfscript>

<cfoutput>
<table border="0" cellspacing="0" cellpadding="1" width="100%">
<cfsetting enablecfoutputonly="true" >
<tr>
<td class="headerspacer">&nbsp;</td>
<cfloop from="1" to="#ArrayLen(headerMenu)#" index="counter">
 <cfset menuItem = headerMenu[counter]>
<td class="<cfif #url.tabvalue# EQ '#menuItem.action#'>headerselected <cfelse>headernotselected</cfif>" width="125" align="center" nowrap><a href="index.cfm?tabvalue=#menuItem.action#"><b>#menuItem.title#</b></a></td>
<td class="headerspacer"><img src="/images/fill.gif" width="1" height="1"  alt=""></td>
</cfloop>
<td class="headerspacer" width="100%"><img src="/images/fill.gif" width="1" height="1" alt=""></td>
</tr>
<cfsetting enablecfoutputonly="false" >
</table>
</cfoutput>

