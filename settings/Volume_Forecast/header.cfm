
<cf_tabStyle
    selectedBgColor = "##FFE083"
        borderWidth = "2" >

<!---color budget tabs differently--->
<style>
.accrual { background:url('/images/gradhead.png') repeat-x scroll 0 0 #B9C9FE !important; }
</style>

<cfscript>
  headerMenu = [];
  ArrayAppend( headerMenu, {title="class", action="class"} );
  ArrayAppend( headerMenu, {title="group", action="group"} );
  ArrayAppend( headerMenu, {title="labels", action="labels"});
  ArrayAppend( headerMenu, {title="plan", action="plan"});
  ArrayAppend( headerMenu, {title="inv. research", action="research"});
  accrualStyle = "";
</cfscript>

<cfif isdefined("form.command")>
	<cfset command = #form.command#>
	<cfif REFindNoCase("class", form.command)>
		<cfset command = "class">
	<cfelseif REFindNoCase("group", form.command)>
		<cfset command = "group">
	<cfelseif REFindNoCase("labels", form.command)>
		<cfset command = "labels">
	<cfelseif REFindNoCase("plan", form.command)>
		<cfset command = "plan">
	<cfelseif REFindNoCase("research", form.command)>
		<cfset command = "research">
	</cfif>
</cfif>

<table border="0" cellspacing="0" cellpadding="1" width="100%">
<cfsetting enablecfoutputonly="true" >
<cfoutput><tr></cfoutput>
<cfoutput><td class="headerspacer">&nbsp;</td></cfoutput>
<cfloop from="1" to="#ArrayLen(headerMenu)#" index="counter">
 <cfset class_name= "headernotselected">
 <cfset menuItem = headerMenu[counter]>
 <cfif command EQ menuItem.title>
  <cfset class_name= "headerselected">
  </cfif>
 <cfoutput><td class="#class_name# #accrualStyle#" width="88" align="center" nowrap onclick="javascript: return clickheader('#menuItem.action#', 0);"><b>#menuItem.title#</b></td></cfoutput>
 <cfoutput><td class="headerspacer"><img src="/images/fill.gif" width="1" height="1"  title=""></td></cfoutput>
</cfloop>
<cfoutput><td class="headerspacer" width="100%"><img src="/images/fill.gif" width="1" height="1" title=""></td></cfoutput>
<cfoutput></tr></cfoutput>
<cfsetting enablecfoutputonly="false" >
</table>

