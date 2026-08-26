<!------ scorecard_header_item.cfm ----->
<cfsetting enablecfoutputonly="Yes" />
<cfparam name="Attributes.title" 	default="">
<cfparam name="Attributes.width" 	default="">
<cfparam name="Attributes.sortToken" 	default="">
<cfparam name="Attributes.currentSortImage" 	default="">

<cfoutput><td class="tableheaders" width="#Attributes.width#" id="TD_#Attributes.sortToken#">
<a href="##" onclick="javascript: return setsorthref('#Attributes.sortToken#');">
#Attributes.title#</a>
<span id="SP_SP" <cfif UCase(Attributes.currentSort) NEQ UCase(Attributes.sortToken)> style="visibility:hidden"</cfif>>&nbsp;<img id="S_IMG" border="0" src="\images\#Attributes.currentSortImage#"></span>
</td></cfoutput>
<cfsetting enablecfoutputonly="No" />